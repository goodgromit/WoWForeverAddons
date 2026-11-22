-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local P = FF.ScanPlanner
local YAW_RATE = 24
local HOME_TOLERANCE = 0.12
local MARKER_DEFAULT_HEIGHT = 247
FF.cameraMarkerDefaultHeight = MARKER_DEFAULT_HEIGHT
local MARKER_HIT_HALF_SIZE = 12 -- 24 x 24, centered with ten units inset per edge of the 44 x 44 artwork.
local MARKER_MEDIA = "Interface\\AddOns\\ForeverFishing\\Media\\Cursor\\"
FF.cameraMarkerOptions = {
    { id = "option1", label = "Option 1: Gold corners", texture = MARKER_MEDIA .. "Option1" },
    { id = "option2", label = "Option 2: Blue ring", texture = MARKER_MEDIA .. "Option2" },
    { id = "option3", label = "Option 3: Soft corners", texture = MARKER_MEDIA .. "Option3" },
    { id = "option4", label = "Option 4: Bold gold corners", texture = MARKER_MEDIA .. "Option4" },
    { id = "option5", label = "Option 5: Ornate corners", texture = MARKER_MEDIA .. "Option5" },
}
FF.scanTuning = {
    { key = "cameraScanSpeed", label = "Scan speed", min = 0.1, max = 5, step = 0.1, default = 3, unit = "x",
        note = "Speed of all scan camera movement, including zoom, tilt, passes, turns, and returning to the prepared view. Applies to the next cast. Faster scans may miss small bobbers." },
    { key = "cameraSweepReach", label = "Width", min = 2, max = 30, settingsMin = 6, settingsMax = 12, step = 1, default = 8, unit = "deg each side",
        note = "Horizontal reach to each side of center. Settings allow 6 to 12 degrees; wider developer values can take longer to search." },
    { key = "cameraSweepSpacing", label = "Vertical spacing", developerOnly = true, min = 0.25, max = 6, step = 0.25, default = 3.75, unit = "deg",
        note = "Gap between rows. Large gaps can skip bobbers completely. Keep the profile default for normal fishing; this is a developer control." },
}
-- Extra view and coverage controls remain available in /fish dev.
FF.sweepTuning = {
    { key = "cameraSweepZoom", label = "Zoom distance", min = 1, max = 40, step = 1, default = 40, unit = "camera units",
        note = "Camera distance for a new fishing view. Nearby objects and your normal camera zoom limit can keep it closer. Use Rebuild fishing view to prepare it again." },
    { key = "cameraSweepTilt", label = "Camera tilt", min = -80, max = 80, step = 0.5, default = 25, unit = "deg",
        note = "Higher values tilt down toward the water; negative values tilt up. Sets the prepared view." },
    { key = "cameraSweepRows", label = "Rows down", min = 1, max = 24, step = 1, default = 11, unit = "rows",
        note = "Rows below the first horizontal pass." },
    { key = "cameraSweepStart", label = "Start below center", min = 0, max = 20, step = 0.25, default = 0, unit = "deg",
        note = "Move the first search row lower in the prepared view." },
    { key = "cameraPyramidStep", label = "Pyramid widening", min = 0.25, max = 6, step = 0.25, default = 1, unit = "deg per side",
        note = "Extra width on each side for every lower line. Used only by Pyramid Path." },
}
local OBSOLETE_SCAN_SETTINGS = { "cameraScanPath", "cameraBalancedRows", "cameraRowsUp", "cameraRowsBeforeSwitch",
    "cameraBalancedSpacing", "cameraBalancedReach", "cameraFastRows", "cameraHistoryLength", "cameraResetFailures",
    "cameraEdgeExtension", "cameraEdgeRows", "cameraSweepOffset", "cameraScanSpacing", "cameraIdleReset",
    "cameraPriority", "cameraEdgeEnabled", "cameraTravelSmoothing", "cameraTravelSpeed" }
local CLOSE_SCAN_DEFAULTS = { cameraSweepZoom = 15, cameraSweepTilt = 17, cameraSweepReach = 7,
    cameraPyramidStep = 0.75, cameraSweepSpacing = 3, cameraSweepRows = 18, cameraMarkerHeight = 339 }
FF.cameraScanProfileOptions = {
    { id = "close", label = "Adaptive (current path)" },
    { id = "standard", label = "Long range camera", developerOnly = true },
    { id = "test1", label = "Test profile 1", developerOnly = true },
    { id = "test2", label = "Test profile 2", developerOnly = true },
    { id = "test3", label = "Test profile 3", developerOnly = true },
}
local function InitializeTuning(db, options, defaults)
    for _, option in ipairs(options) do
        local default = defaults and defaults[option.key] or option.default
        local value = tonumber(db[option.key]) or default
        if value ~= value then value = default end
        value = math.max(option.min, math.min(option.max, value))
        db[option.key] = math.floor(value / option.step + 0.5) * option.step
    end
end

local PROFILE_KEYS = { "cameraPyramidPath", "cameraRoundedTurns", "cameraRacetrackTurns", "cameraSavedView", "cameraMarkerHeight", "cameraMarkerStyle", "cameraSmartAdjustment" }
local function CopyScanProfile(self, source)
    local profile = {}
    for _, options in ipairs({ self.scanTuning, self.sweepTuning, self.viewTuning, self.smartTuning }) do
        for _, option in ipairs(options) do profile[option.key] = source[option.key] end
    end
    for _, key in ipairs(PROFILE_KEYS) do profile[key] = source[key] end
    return profile
end

local function ApplyScanProfile(self, profile)
    for _, options in ipairs({ self.scanTuning, self.sweepTuning, self.viewTuning, self.smartTuning }) do
        for _, option in ipairs(options) do self.db[option.key] = profile[option.key] end
    end
    for _, key in ipairs(PROFILE_KEYS) do self.db[key] = profile[key] end
end

local function DefaultScanProfile(self, close, source)
    local profile
    if source then profile = CopyScanProfile(self, source)
    else
        profile = { cameraPyramidPath = true, cameraRoundedTurns = false, cameraRacetrackTurns = false,
            cameraSavedView = true, cameraSmartAdjustment = true,
            cameraMarkerHeight = MARKER_DEFAULT_HEIGHT, cameraMarkerStyle = "option4" }
        for _, options in ipairs({ self.scanTuning, self.sweepTuning, self.viewTuning, self.smartTuning }) do
            for _, option in ipairs(options) do profile[option.key] = option.default end
        end
    end
    if close then
        for key, value in pairs(CLOSE_SCAN_DEFAULTS) do profile[key] = value end
    else
        profile.cameraSmartAdjustment = false
    end
    return profile
end

function FF:CameraScanProfileOption(id)
    for _, option in ipairs(self.cameraScanProfileOptions) do
        if option.id == id then return option end
    end
end
function FF:CameraScanProfileName()
    local option = self:CameraScanProfileOption(self.db.cameraProfile)
    if option then return option.label end
    return self.db.cameraCloseScan and "Adaptive (current path)" or "Standard camera scan"
end

function FF:SaveCameraScanProfile()
    if type(self.db.cameraScanProfiles) ~= "table" then return end
    local key = self.db.cameraProfile or (self.db.cameraCloseScan and "close" or "standard")
    self.db.cameraScanProfiles[key] = CopyScanProfile(self, self.db)
end

function FF:InitializeCameraScanProfiles()
    -- The flat settings remain the active profile, including edits from older
    -- releases. Snapshots only restore the other profile when switching.
    if type(self.db.cameraScanProfiles) ~= "table" then
        local standard = CopyScanProfile(self, self.db)
        standard.cameraSmartAdjustment = false
        local close = DefaultScanProfile(self, true, standard)
        close.cameraSmartAdjustment = true
        self.db.cameraScanProfiles = { standard = standard, close = close }
        self.db.cameraProfile = "close"
        self.db.cameraCloseScan = true
        ApplyScanProfile(self, close)
        self:InvalidateSavedFishingView("Close scan defaults; next scan prepares its fishing view")
    end
    if not self:CameraScanProfileOption(self.db.cameraProfile) then
        self.db.cameraProfile = self.db.cameraCloseScan == false and "standard" or "close"
    end
    if self.db.cameraSmartCloseLinkVersion ~= 1 then
        local standard = self.db.cameraScanProfiles.standard
        local close = self.db.cameraScanProfiles.close
        if type(standard) == "table" then standard.cameraSmartAdjustment = false end
        if type(close) == "table" then close.cameraSmartAdjustment = true end
        if self.db.cameraProfile == "standard" or self.db.cameraProfile == "close" then
            self.db.cameraSmartAdjustment = self.db.cameraProfile == "close"
        end
        self.db.cameraSmartCloseLinkVersion = 1
    end
    self.db.cameraCloseScan = self.db.cameraProfile ~= "standard"
    self:SaveCameraScanProfile()
    for _, option in ipairs(self.cameraScanProfileOptions) do
        if type(self.db.cameraScanProfiles[option.id]) ~= "table" then
            self.db.cameraScanProfiles[option.id] = DefaultScanProfile(self, option.id ~= "standard")
        end
    end
    self.cameraMarkerDefaultHeight = self.db.cameraCloseScan and CLOSE_SCAN_DEFAULTS.cameraMarkerHeight or MARKER_DEFAULT_HEIGHT
    if self.SyncLongRangeCameraDistance then self:SyncLongRangeCameraDistance() end
end

function FF:SetCameraScanProfile(id)
    if not self:CameraScanProfileOption(id) or self.db.cameraProfile == id then return end
    if InCombatLockdown() then
        self:Print("Change camera scan profiles after combat.")
        return
    end
    self:SaveCameraScanProfile()
    local profile = self.db.cameraScanProfiles and self.db.cameraScanProfiles[id]
    if type(profile) ~= "table" then profile = DefaultScanProfile(self, id ~= "standard") end
    -- Stop the old profile without starting a return to its camera preset.
    self:EndCameraMarkerDrag(false)
    self:InvalidateScanHome("Camera scan profile changed")
    self:StopCameraAssist("Camera scan profile changed", true)
    self.cameraHome = nil
    self:ResetSmartCameraAdjustment("Profile changed; base preset 4", true)
    self:InvalidateSavedFishingView("Profile changed; next scan prepares its fishing view")
    self.cameraSweepAchievedZoom = nil
    self.db.cameraProfile = id
    self.db.cameraCloseScan = id ~= "standard"
    ApplyScanProfile(self, profile)
    if id == "close" or id == "standard" then
        self.db.cameraSmartAdjustment = id == "close"
    end
    self:InitializeScanConfig()
    self:SetCameraMarkerStyle(self.db.cameraMarkerStyle)
    self:PositionCameraMarker()
    if self.settingsPanel then
        self:RefreshFishingModeSetting()
        self:RefreshCameraScanSetting()
    end
    if self.scanDevPanel then self.scanDevPanel:RefreshControls() end
    if self.active and self.UpdateBobberStatus then self:UpdateBobberStatus() end
    self:RefreshUI()
end
function FF:SetCloseCameraScan(enabled)
    -- Compatibility entry point: the Settings menu selects the same profile
    -- directly as Adaptive (close) or Long range (standard).
    self:SetCameraScanProfile(enabled and "close" or "standard")
end

function FF:InitializeScanConfig()
    -- Retire the native pitch experiment: CVar acceptance did not establish
    -- the requested CenterCamera angle in live Forever tests.
    self.db.cameraNativeCenter = nil
    self:InitializeSmartCameraSettings()
    self:InitializeSavedFishingViewSettings()
    -- Apply the selected release artwork once; later developer choices persist.
    if self.db.cameraMarkerStyleVersion ~= 1 then
        self.db.cameraMarkerStyle = "option4"
        self.db.cameraMarkerStyleVersion = 1
    end
    self.db.cameraMarkerStyle = self:CameraMarkerOption(self.db.cameraMarkerStyle).id
    local defaults = self.db.cameraCloseScan and CLOSE_SCAN_DEFAULTS
    InitializeTuning(self.db, self.scanTuning, defaults)
    InitializeTuning(self.db, self.sweepTuning, defaults)
    for _, key in ipairs(OBSOLETE_SCAN_SETTINGS) do self.db[key] = nil end
    self.db.cameraScanLogging = self.db.cameraScanLogging == true
    if self.db.cameraPyramidPath == nil then self.db.cameraPyramidPath = true end
    self.db.cameraPyramidPath = self.db.cameraPyramidPath == true
    -- Retire the old Scan settings choice once. Later choices in /fish dev persist.
    if self.db.cameraRoundedDevOnly ~= true then self.db.cameraRoundedTurns = false end
    self.db.cameraRoundedDevOnly = true
    self.db.cameraRoundedTurns = self.db.cameraRoundedTurns == true
    if self.db.cameraPyramidPath then self.db.cameraRoundedTurns = false end
    self.db.cameraRacetrackTurns = self.db.cameraRacetrackTurns == true
    if self.db.cameraRacetrackTurns then self.db.cameraRoundedTurns = false end
    local height = tonumber(self.db.cameraMarkerHeight)
    if not height or height ~= height or math.abs(height) == math.huge then
        height = defaults and defaults.cameraMarkerHeight or MARKER_DEFAULT_HEIGHT
    end
    self.db.cameraMarkerHeight = height
    self:InitializeCameraScanProfiles()
end
function FF:ResetScanSettings()
    self:ResetSavedFishingViewSettings()
    for _, option in ipairs(self.scanTuning) do self.db[option.key] = option.default end
    for _, option in ipairs(self.sweepTuning) do self.db[option.key] = option.default end
    self.db.cameraScanLogging = false
    self.db.cameraRoundedTurns = false
    self.db.cameraRacetrackTurns = false
    self.db.cameraPyramidPath = true
    self.db.cameraMarkerHeight = MARKER_DEFAULT_HEIGHT
    self.db.cameraMarkerStyle = "option4"
    self.db.cameraScanProfiles = nil
    self.db.cameraProfile = nil
    self:InitializeCameraScanProfiles()
    self:SetCameraMarkerStyle("option4")
    self:PositionCameraMarker()
end
function FF:CameraMarkerOption(id)
    for _, option in ipairs(self.cameraMarkerOptions) do if option.id == id then return option end end
    return self.cameraMarkerOptions[4]
end

function FF:SetCameraMarkerStyle(id)
    local option = self:CameraMarkerOption(id)
    self.db.cameraMarkerStyle = option.id
    if self.cameraMarker and self.cameraMarker.artwork then self.cameraMarker.artwork:SetTexture(option.texture) end
    self:SaveCameraScanProfile()
end

function FF:UpdateCameraMarkerInfo()
    local marker = self.cameraMarker
    if not marker or not marker.info then return end
    self:UpdateCameraOnboardingTip()
    local show = self.db.cameraAssist and marker:IsShown() and self.active and self.cameraAssistNeeded
        and not self.cameraMarkerDrag and not self:CameraMarkerHasCursor() or false
    if marker.info:IsShown() ~= show then marker.info:SetShown(show) end
end

function FF:UpdateCameraOnboardingTip()
    local marker = self.cameraMarker
    local tip = marker and marker.onboarding
    if not tip then return end
    local show = self.db.cameraAssist and marker:IsShown() and self.active and self.cameraAssistNeeded
        and (self.db.cameraAssistOnboardingFailures or 0) >= 2
        and not self.db.cameraAssistOnboardingComplete or false
    if show then
        local binding = self.GetFishingInputKey and self:GetFishingInputKey() or (not self.db.gamepadMode and self.db.key)
        if tip.binding ~= binding or not tip.key then
            local key = self.GetFishingBindingLabel and self:GetFishingBindingLabel() or binding or self:LocalizedText("binding.display.empty")
            tip.binding = binding
            tip.key = key
            tip.hook:SetText(self:LocalizedText("camera.help.hook", key))
            local previous, height = tip.title, 14 + tip.title:GetStringHeight()
            for index, line in ipairs(tip.instructions) do
                local gap = (index == 1 or line == tip.warning) and 9 or 5
                line:ClearAllPoints()
                line:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -gap)
                height = height + gap + line:GetStringHeight()
                previous = line
            end
            tip:SetHeight(math.ceil(height + 5 + tip.footer:GetStringHeight() + 12))
        end
    end
    if tip:IsShown() ~= show then tip:SetShown(show) end
end
function FF:UpdateCameraMarkerRightClick()
    if InCombatLockdown and InCombatLockdown() then return end
    local marker = self.cameraMarker
    if not marker then return end
    -- A right click on the marker can reactivate WoW without starting mouselook.
    -- Once the bobber is found, let right clicks reach the world to loot it.
    if self.db.cameraAssist and self.cameraAssistNeeded and marker:IsShown() and not self:CameraBobberLocated()
        and not self.cameraScanFailed then
        marker:SetPassThroughButtons("MiddleButton", "Button4", "Button5")
    else
        marker:SetPassThroughButtons("RightButton", "MiddleButton", "Button4", "Button5")
    end
end
function FF:CameraPlanConfig()
    local config = { down = self.db.cameraSweepRows, spacing = self.db.cameraSweepSpacing,
        reach = self.db.cameraSweepReach, start = self.db.cameraSweepStart, pyramid = self.db.cameraPyramidPath,
        pyramidStep = self.db.cameraPyramidStep,
        rounded = self.db.cameraRoundedTurns and not self.db.cameraPyramidPath,
        racetrack = self.db.cameraRacetrackTurns,
        tilt = self.db.cameraSweepTilt }
    self:ApplySmartCameraTilt(config)
    return config
end

function FF:SetCameraScanShape(shape, enabled)
    enabled = enabled == true
    if shape == "pyramid" then
        self.db.cameraPyramidPath = enabled
        if enabled then self.db.cameraRoundedTurns = false end
    elseif shape == "rounded" then
        self.db.cameraRoundedTurns = enabled
        if enabled then self.db.cameraPyramidPath = false; self.db.cameraRacetrackTurns = false end
    elseif shape == "racetrack" then
        self.db.cameraRacetrackTurns = enabled
        if enabled then self.db.cameraRoundedTurns = false end
    else return end
    self:SaveCameraScanProfile()
    if self.settingsPanel then self:RefreshCameraScanSetting() end
    if self.scanDevPanel then self.scanDevPanel:RefreshControls() end
end

function FF:ScanLog(format, ...)
    if not self.db.cameraScanLogging then return end
    local message = string.format(format, ...)
    self:TraceTransition("camera: " .. message)
    self:Print("Scan: " .. message)
end
function FF:ResetCameraStatistics()
    self.cameraStats = { casts = 0, attempts = 0, detections = 0, failures = 0, cancelled = 0,
        timeTotal = 0, worst = 0, samples = {}, sampleIndex = 1, revision = 0,
        rows = 0, finished = 0, homeResets = 0,
        travel = 0, scanDistance = 0 }
    -- Restart the measurement window if Reset is clicked during an unfinished scan.
    local cast = self.cameraCast
    if cast and cast.scanStarted and not cast.finished and self.active and self.cameraAssistNeeded then
        cast.scanStarted, cast.rows = GetTime(), 0
        self.cameraStats.casts, self.cameraStats.attempts = 1, 1
    end
end


local function Round(value)
    return value < 0 and math.ceil(value - 0.5) or math.floor(value + 0.5)
end
local function Plain(value)
    return not (type(issecretvalue) == "function" and issecretvalue(value))
end
local function CameraSpeed(cvar)
    if type(GetCVar) ~= "function" then return nil end
    local ok, value = pcall(GetCVar, cvar)
    if not ok or not Plain(value) or (type(value) ~= "string" and type(value) ~= "number") then return nil end
    value = tonumber(value)
    if not value or value <= 0 or value == math.huge or value ~= value then return nil end
    return value
end
-- Names are accepted only after a standard-ID observation in this login.
-- Two bounded aliases cover native soft-target and world-tooltip presentation.
function FF:RememberFishingBobberName(guid, name)
    if not Plain(guid) or type(guid) ~= "string"
        or guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-") ~= "35591"
        or not Plain(name) or type(name) ~= "string" or #name == 0 or #name > 160 then return end
    if (self.cameraBobberNameCount or 0) >= 2 then return end
    local normalized = name:lower()
    local names = self.cameraBobberNames
    if names and names[normalized] then return end
    names = names or {}; self.cameraBobberNames = names
    names[normalized] = true
    self.cameraBobberNameCount = (self.cameraBobberNameCount or 0) + 1
end

function FF:IsFishingBobberName(name, softTarget, requireExact)
    if not Plain(name) or type(name) ~= "string" then return false end
    local normalized = name:lower()
    if self.cameraBobberNames and self.cameraBobberNames[normalized] then return true end
    if requireExact then return normalized == "fishing bobber" end
    -- Preserve the existing English compatibility paths, including soft targeting.
    return normalized:find(softTarget and "bobber" or "fishing bobber", 1, true) ~= nil
end

local function SafeNumber(value)
    if not Plain(value) or type(value) ~= "number" then return nil end
    return value == value and math.abs(value) ~= math.huge and value or nil
end
local function ReadNumber(callback)
    if not Plain(callback) then return nil, "inaccessible" end
    if type(callback) ~= "function" then return nil, "unavailable" end
    local ok, value = pcall(callback)
    if not ok then return nil, "error" end
    if not Plain(value) then return nil, "inaccessible" end
    value = SafeNumber(value)
    if value == nil then return nil, "invalid" end
    return value
end
local function ReadZoom()
    local value, outcome = ReadNumber(GetCameraZoom)
    if value and value < 0 then return nil, "invalid" end
    return value, outcome
end
function FF:ReadCameraCursor(optional)
    local callback = GetCursorPosition
    if not Plain(callback) then
        if not optional then self:RecordCameraInputOutcome("cursor", "inaccessible") end
        return nil
    end
    if type(callback) ~= "function" then
        if not optional then self:RecordCameraInputOutcome("cursor", "unavailable") end
        return nil
    end
    local ok, x, y = pcall(callback)
    local outcome = not ok and "error" or ((not Plain(x) or not Plain(y)) and "inaccessible")
    if not outcome then
        x, y = SafeNumber(x), SafeNumber(y)
        if x == nil or y == nil then outcome = "invalid" end
    end
    if not optional then self:RecordCameraInputOutcome("cursor", outcome) end
    if outcome then return nil end
    return x, y
end
local function Fingerprint(target)
    local zoom, zoomError = ReadZoom()
    local facing, facingError = ReadNumber(GetPlayerFacing)
    FF:RecordCameraInputOutcome("facing", facingError)
    local x, y, z, instance
    if Plain(UnitPosition) and type(UnitPosition) == "function" then
        local ok, a, b, c, d = pcall(UnitPosition, "player")
        if ok then x, y, z, instance = SafeNumber(a), SafeNumber(b), SafeNumber(c), SafeNumber(d) end
        FF:RecordCameraInputOutcome("position", not ok and "error" or nil)
    end
    target = target or {}
    target.zoom, target.facing = zoom, facing
    target.x, target.y, target.z, target.instance = x, y, z, instance
    target.zoomError = zoomError
    return target
end
local guardFingerprint = {}
local function FingerprintChanged(old, ignoreZoom)
    if not old then return false end
    local now = Fingerprint(guardFingerprint)
    if now.zoomError then return false, now.zoomError end
    if not ignoreZoom and old.zoom and now.zoom and math.abs(old.zoom - now.zoom) > 0.25 then return true end
    if old.facing and now.facing then
        local delta = math.abs(old.facing - now.facing) % (2 * math.pi)
        if math.min(delta, 2 * math.pi - delta) > 0.1 then return true end
    end
    if old.instance and now.instance and old.instance ~= now.instance then return true end
    if old.x and old.y and now.x and now.y and ((old.x - now.x)^2 + (old.y - now.y)^2) > 1 then return true end
    if old.z and now.z and math.abs(old.z - now.z) > 1 then return true end
    return false
end

local function WorldCursorQuery()
    if not Plain(C_TooltipInfo) then return nil, "inaccessible" end
    if C_TooltipInfo == nil then return nil, "unavailable" end
    if type(C_TooltipInfo) ~= "table" then return nil, "invalid" end
    local callback = rawget(C_TooltipInfo, "GetWorldCursor")
    if not Plain(callback) then return nil, "inaccessible" end
    if type(callback) ~= "function" then return nil, "unavailable" end
    return callback
end

function FF:CursorOnFishingBobber()
    local query, unavailable = WorldCursorQuery()
    if not query then
        self:RecordCameraCursorOutcome(unavailable)
        return false
    end
    local cast = self.cameraCast
    if cast and self.active and self.cameraAssistNeeded and not self:CameraBobberLocated() then
        local now = GetTime()
        cast.cursorSamples = (cast.cursorSamples or 0) + 1
        if cast.lastCursorSample then
            local gap = math.max(0, now - cast.lastCursorSample)
            cast.maxCursorGap = math.max(cast.maxCursorGap or 0, gap)
            local motion = self.cameraMotion
            if motion and motion.startedAt then
                local travel = math.sqrt(motion.vx * motion.vx + motion.vy * motion.vy) * gap
                cast.maxSampleTravel = math.max(cast.maxSampleTravel or 0, travel)
            end
        end
        cast.lastCursorSample = now
    end
    local started = cast and self.db.cameraScanLogging and debugprofilestop and debugprofilestop()
    local ok, data = pcall(query)
    if started then cast.maxCursorCPU = math.max(cast.maxCursorCPU or 0, debugprofilestop() - started) end
    if not ok then self:RecordCameraCursorOutcome("error"); return false end
    if not Plain(data) then self:RecordCameraCursorOutcome("inaccessible"); return false end
    if type(data) ~= "table" then
        self:RecordCameraCursorOutcome(data == nil and "empty" or "invalid")
        return false
    end
    local guid = rawget(data, "guid")
    local readableGUID = Plain(guid)
    if readableGUID and guid ~= nil and type(guid) ~= "string" then self:RecordCameraCursorOutcome("invalid"); return false end
    if readableGUID and guid and guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-") == "35591" then
        local lines = rawget(data, "lines")
        if Plain(lines) and type(lines) == "table" then
            local first = rawget(lines, 1)
            if Plain(first) and type(first) == "table" then
                self:RememberFishingBobberName(guid, rawget(first, "leftText"))
            end
        end
        self:RecordCameraTraceObject(guid, rawget(data, "type"), self:CameraTraceTooltipName(data), "standard object ID")
        self:RecordCameraCursorOutcome("bobber")
        return true
    end
    local objectType, tooltipType = 4, rawget(data, "type")
    if Plain(Enum) and type(Enum) == "table" then
        local types = rawget(Enum, "TooltipDataType")
        if Plain(types) and type(types) == "table" then objectType = SafeNumber(rawget(types, "Object")) or 4 end
    end
    if not Plain(tooltipType) then self:RecordCameraCursorOutcome("inaccessible"); return false end
    if tooltipType == nil and not readableGUID then self:RecordCameraCursorOutcome("inaccessible"); return false end
    if tooltipType == nil and guid == nil then
        local emptyLines = rawget(data, "lines")
        if not Plain(emptyLines) then self:RecordCameraCursorOutcome("inaccessible"); return false end
        if emptyLines == nil then self:RecordCameraCursorOutcome("empty"); return false end
    end
    if SafeNumber(tooltipType) == nil then self:RecordCameraCursorOutcome("invalid"); return false end
    if tooltipType ~= objectType then self:RecordCameraCursorOutcome("other"); return false end
    self.cameraScanObjectSamples = (self.cameraScanObjectSamples or 0) + 1
    local lines = rawget(data, "lines")
    if not Plain(lines) then self:RecordCameraCursorOutcome("inaccessible"); return false end
    if lines ~= nil and type(lines) ~= "table" then self:RecordCameraCursorOutcome("invalid"); return false end
    local first = lines and rawget(lines, 1)
    if not Plain(first) then self:RecordCameraCursorOutcome("inaccessible"); return false end
    if first ~= nil and type(first) ~= "table" then self:RecordCameraCursorOutcome("invalid"); return false end
    local name = first and rawget(first, "leftText")
    if not Plain(name) then self:RecordCameraCursorOutcome("inaccessible"); return false end
    if name ~= nil and type(name) ~= "string" then self:RecordCameraCursorOutcome("invalid"); return false end
    if name then self.cameraScanLastObject = name:sub(1, 160) end
    local nonGameObject = readableGUID and type(guid) == "string" and not guid:match("^GameObject%-")
    local found = not nonGameObject and self:IsFishingBobberName(name)
    self:RecordCameraTraceObject(readableGUID and guid or nil, tooltipType, name,
        found and self:CameraTraceNameRoute(name) or "not a recognized bobber")
    self:RecordCameraCursorOutcome(found and "bobber" or "object")
    return found
end

function FF:CameraMarkerHasCursor()
    if self.cameraMarkerDrag or not self.cameraMarker then return false end
    local x, y = self:ReadCameraCursor()
    local cx, cy = self.cameraMarker:GetCenter()
    cx, cy = SafeNumber(cx), SafeNumber(cy)
    if x == nil or y == nil or cx == nil or cy == nil then return false end
    local scale = SafeNumber(self.cameraMarker:GetEffectiveScale())
    if not scale or scale <= 0 then return false end
    local halfSize = MARKER_HIT_HALF_SIZE * scale
    return math.abs(x - cx * scale) <= halfSize and math.abs(y - cy * scale) <= halfSize
end

function FF:PositionCameraMarker(height)
    local marker = self.cameraMarker
    if not marker then return end
    local screenScale = UIParent:GetEffectiveScale()
    local markerScale = marker:GetEffectiveScale()
    -- Anchoring offsets use the marker's scale; store height in screen UI units.
    local ratio = screenScale / markerScale
    local halfHeight = UIParent:GetHeight() / 2
    local margin = 44 * ratio
    height = tonumber(height) or self.db.cameraMarkerHeight or self.cameraMarkerDefaultHeight
    height = math.max(-halfHeight + margin, math.min(halfHeight - margin, height))
    self.db.cameraMarkerHeight = height
    self:SaveCameraScanProfile()
    marker:ClearAllPoints()
    marker:SetPoint("CENTER", UIParent, "CENTER", 0, height * ratio)
    if marker.info then
        local below = height + (22 + 8 + marker.info:GetHeight() + 6) / ratio > halfHeight
        if marker.info.below ~= below then
            marker.info.below = below
            marker.info:ClearAllPoints()
            marker.info:SetPoint(below and "TOP" or "BOTTOM", marker, below and "BOTTOM" or "TOP", 0, below and -8 or 8)
        end
        self:UpdateCameraMarkerInfo()
    end
end

function FF:BeginCameraMarkerDrag()
    if InCombatLockdown() or self.cameraMarkerDrag then return end
    local _, y = self:ReadCameraCursor()
    if not y then return end
    local scale = SafeNumber(UIParent:GetEffectiveScale())
    if not scale or scale <= 0 then return end
    self:FinishCameraAttempt("cancelled")
    self:EndCameraAttemptDiagnostics("Cursor marker moved")
    self:InvalidateScanHome("Cursor marker moved")
    self.cameraMarkerDrag = { mouseY = y, height = self.db.cameraMarkerHeight,
        scale = scale }
    self.cameraScanFrame:SetScript("OnUpdate", nil)
    self:CameraState("DRAG_MARKER")
    self:UpdateCameraMarkerInfo()
    self.cameraMarker:SetScript("OnUpdate", function()
        local drag = self.cameraMarkerDrag
        local _, cursorY = self:ReadCameraCursor()
        if drag and cursorY then self:PositionCameraMarker(drag.height + (cursorY - drag.mouseY) / drag.scale) end
    end)
end

function FF:EndCameraMarkerDrag(resume)
    if not self.cameraMarkerDrag then return end
    self.cameraMarkerDrag = nil
    self.cameraMarker:SetScript("OnUpdate", nil)
    if not (InCombatLockdown and InCombatLockdown()) then self:PositionCameraMarker() end
    if resume and self.db.cameraAssist and self.active and self.cameraAssistNeeded
        and not self:CameraBobberLocated()
        and self.bar:IsShown() and self.castEnd and self.castEnd > GetTime() and not InCombatLockdown() then
        -- Restart against the new cursor height, without carrying old find/row data.
        if self.cameraCast then
            self.cameraCast.scanStarted, self.cameraCast.finished, self.cameraCast.rows = nil, nil, 0
            self.cameraCast.scanExhausted = nil
        end
        self.cameraScanFailed, self.cameraScanStarted = false, false
        self:StartCameraAttemptDiagnostics(self.cameraAssistReason)
        self:CameraState("WAIT_CURSOR")
        self:ApplyBindings()
        self:ArmCameraTick()
    end
end

-- Two bounded, per-login summaries only. No saved facts, extra probes or timers.
function FF:StartCameraAttemptDiagnostics(reason)
    if self.cameraAttemptDiagnostics then return end
    local now, cast = GetTime(), self.cameraCast
    self.cameraAttemptDiagnostics = { startedAt = now, updatedAt = now,
        castID = cast and cast.id, state = self.cameraState or "WAIT_CURSOR",
        entryReason = Plain(reason) and type(reason) == "string" and reason:sub(1, 160) or "unknown",
        preparationTime = 0, scanTime = 0, pausedTime = 0, waitingTime = 0,
        baseFrames = cast and cast.scanFrames or 0, baseChecks = cast and cast.cursorSamples or 0,
        baseEvents = cast and cast.cursorEvents or 0,
        context = self:CameraTraceContext(), lastObject = {},
        queries = { unavailable = 0, error = 0, inaccessible = 0, empty = 0,
            invalid = 0, other = 0, object = 0, bobber = 0 } }
end

function FF:UpdateCameraAttemptDiagnostics()
    local record = self.cameraAttemptDiagnostics
    if not record then return end
    local now = GetTime()
    local elapsed = math.max(0, now - record.updatedAt)
    local field = record.state == "PREPARE_VIEW" and "preparationTime"
        or (record.state == "NORMAL" and "scanTime")
        or (record.state == "PAUSED" and "pausedTime")
        or ((record.state == "WAIT_CURSOR" or record.state == "WAIT_HOME" or record.state == "IDLE") and "waitingTime")
    if field then record[field] = record[field] + elapsed end
    record.updatedAt = now
    local cast = self.cameraCast
    if cast and cast.id == record.castID then
        record.frames = math.max(0, (cast.scanFrames or 0) - record.baseFrames)
        record.checks = math.max(0, (cast.cursorSamples or 0) - record.baseChecks)
        record.events = math.max(0, (cast.cursorEvents or 0) - record.baseEvents)
        record.maxFrameDelta, record.maxCursorGap = cast.maxFrameDelta, cast.maxCursorGap
        record.maxSampleTravel, record.completedSteps = cast.maxSampleTravel, self.cameraScanCompletedSteps
        record.exhausted = cast.scanExhausted
        record.remainingAtLastUpdate = self.castEnd and math.max(0, self.castEnd - now) or nil
    end
end

function FF:FailCameraInput(reason)
    if self:CameraBobberLocated() and self.cameraState ~= "RESTORE_HOME" then return end
    if self.cameraScanFailed and self.cameraInputFailureReason then return end
    self.cameraInputFailureReason = reason
    local record = self.cameraAttemptDiagnostics
    if record and not record.outcome then record.outcome, record.reason = "failed", reason end
    if self.cameraCast and self.cameraAssistNeeded then self.cameraCast.inputFailed = reason end
    self:FinishCameraAttempt("failed")
    self.cameraScanFailed = true
    self:InvalidateScanHome(reason)
    self:CameraState("FAILED")
    if self.cameraScanFrame then
        self.cameraScanFrame:SetScript("OnUpdate", nil)
        pcall(self.cameraScanFrame.UnregisterEvent, self.cameraScanFrame, "WORLD_CURSOR_TOOLTIP_UPDATE")
        pcall(self.cameraScanFrame.UnregisterEvent, self.cameraScanFrame, "CURSOR_CHANGED")
    end
end

function FF:RecordCameraInputOutcome(kind, outcome)
    local searching = self.active and self.cameraAssistNeeded and not self:CameraBobberLocated()
    local record = searching and self.cameraAttemptDiagnostics
    if record and outcome and kind ~= "tooltip" then
        record.inputFaults = record.inputFaults or { cursor = 0, facing = 0, position = 0 }
        record.inputFaults[kind] = record.inputFaults[kind] + 1
    end
    if kind ~= "tooltip" and kind ~= "cursor" then return end
    if not searching or self.cameraScanFailed then return end
    local failures = self.cameraInputFailures
    if not outcome then
        if failures then failures[kind] = nil end
        return
    end
    failures = failures or {}; self.cameraInputFailures = failures
    local fault = failures[kind]
    if not fault then fault = { started = GetTime(), count = 0 }; failures[kind] = fault end
    fault.count = fault.count + 1
    -- Empty/valid responses clear the streak. Events cannot accelerate this
    -- elapsed-time gate; isolated read failures never end an otherwise good scan.
    if outcome == "unavailable" or (fault.count >= 5 and GetTime() - fault.started >= 0.5) then
        self:FailCameraInput("Camera " .. kind .. " input " .. outcome)
    end
end

function FF:RecordCameraCursorOutcome(outcome)
    local record = self.cameraAttemptDiagnostics
    if record and self.active and self.cameraAssistNeeded and not self:CameraBobberLocated() then
        record.queries[outcome] = record.queries[outcome] + 1
    end
    self:RecordCameraInputOutcome("tooltip",
        (outcome == "unavailable" or outcome == "error" or outcome == "inaccessible" or outcome == "invalid") and outcome or nil)
end

function FF:EndCameraAttemptDiagnostics(reason)
    local record = self.cameraAttemptDiagnostics
    if not record then return end
    self:UpdateCameraAttemptDiagnostics()
    record.endedAt = record.updatedAt
    record.endReason = Plain(reason) and type(reason) == "string" and reason:sub(1, 160) or "unspecified"
    record.outcome = record.outcome or (self.cameraScanFailed and "failed" or "cancelled")
    self.cameraLastAttemptDiagnostics = record
    self.cameraAttemptDiagnostics = nil
end

function FF:AppendCameraAttemptDiagnostics(lines)
    self:UpdateCameraAttemptDiagnostics()
    for index = 1, 2 do
        local record
        if index == 1 then record = self.cameraAttemptDiagnostics else record = self.cameraLastAttemptDiagnostics end
        local label = index == 1 and "Current assisted attempt" or "Last ended assisted attempt"
        if not record then
            lines[#lines + 1] = label .. ": none this login"
        else
            lines[#lines + 1] = string.format("%s: cast %s; state %s; outcome %s; entry %s", label,
                tostring(record.castID or "unknown"), record.state, record.outcome or "search pending", record.entryReason)
            lines[#lines + 1] = string.format("  Reason: %s; end: %s", record.reason or "none", record.endReason or "not ended")
            lines[#lines + 1] = string.format("  Time: preparing %.2fs; scanning %.2fs; paused %.2fs; waiting %.2fs; frames %d; checks %d; cursor events %d",
                record.preparationTime, record.scanTime, record.pausedTime, record.waitingTime,
                record.frames or 0, record.checks or 0, record.events or 0)
            self:AppendCameraTraceAttempt(lines, record)
            local q = record.queries
            lines[#lines + 1] = string.format("  Cursor outcomes: bobber %d; other object %d; other tooltip %d; empty %d (normal); API unavailable %d; API errors %d; inaccessible %d; invalid payload %d",
                q.bobber, q.object, q.other, q.empty, q.unavailable, q.error, q.inaccessible, q.invalid)
            local faults = record.inputFaults
            if faults then
                lines[#lines + 1] = string.format("  External read faults: cursor %d; optional facing %d; optional position %d",
                    faults.cursor, faults.facing, faults.position)
            end
        end
    end
end

function FF:CameraState(state)
    if self.cameraState == state then return end
    self:UpdateCameraAttemptDiagnostics()
    local record = self.cameraAttemptDiagnostics
    if record then
        record.state = state
        if state == "FAILED" and not record.outcome then record.outcome = "failed" end
    end
    self.cameraState = state
    self:ScanLog("State: %s", state)
    if self.UpdateCameraAssistStatus then self:UpdateCameraAssistStatus() end
end

function FF:CallCamera(fn, value)
    if not fn then return false end
    local previousOwnCall = self.cameraOwnCall
    self.cameraOwnCall = true
    local ok
    if value == nil then ok = pcall(fn) else ok = pcall(fn, value) end
    self.cameraOwnCall = previousOwnCall
    return ok
end

function FF:AccountCameraMotion(now)
    local motion, home = self.cameraMotion, self.cameraHome
    if not motion or not motion.startedAt or not home or not home.valid then return end
    local dt = math.max(0, now - motion.accountedAt)
    home.x, home.y = home.x + motion.vx * dt, home.y + motion.vy * dt
    motion.accountedAt = now
    local distance = (math.abs(motion.vx) + math.abs(motion.vy)) * dt
    local stats = self.cameraStats
    if motion.step.kind == "travel" then stats.travel = stats.travel + distance
    else stats.scanDistance = stats.scanDistance + distance end
end

function FF:StopCameraMotion()
    if not self.cameraMotion then return end
    if self.cameraCast then self.cameraCast.lastCursorSample = nil end
    self:AccountCameraMotion(GetTime())
    if self.cameraMotion.path and self.cameraMotion.startedAt and self.cameraRun then
        self.cameraRun.elapsed = self.cameraMotion.elapsedBase + GetTime() - self.cameraMotion.startedAt
    end
    self:CallCamera(MoveViewLeftStop)
    self:CallCamera(MoveViewRightStop)
    self:CallCamera(MoveViewUpStop)
    self:CallCamera(MoveViewDownStop)
    self.cameraMotion = nil
end

function FF:CaptureScanHome(reason)
    self:StopCameraMotion()
    self.cameraHome = { valid = true, x = 0, y = 0, fingerprint = Fingerprint(),
        reason = reason or "Session origin", established = GetTime(), status = "Prepared fishing view", centered = true, tilt = self.db.cameraSweepTilt }
    self.cameraHome.speed = self.db.cameraScanSpeed
    self.cameraFrameMaximum = 0
    self.cameraStats.homeResets = self.cameraStats.homeResets + 1
    self:ScanLog("HOME established: %s", self.cameraHome.reason)
end

function FF:StopPreparationZoom()
    local prep = self.cameraSweepPreparation
    if prep and prep.zooming then
        -- Cancel the native zoom destination as well as continuous motion.
        self:CallCamera(MoveViewOutStart, 0)
        self:CallCamera(MoveViewInStart, 0)
        self:CallCamera(MoveViewInStop)
        self:CallCamera(MoveViewOutStop)
        prep.zooming = false
    end
    if self.RestoreCVars then self:RestoreCVars("cameraZoomRestore") end
end

local function OwnsSweepPreparation(self, prep, home)
    return prep and self.cameraSweepPreparation == prep and home
        and self.cameraHome == home and home.valid
end

function FF:StartPreparationZoom(prep, zoom, now)
    local home = self.cameraHome
    if not OwnsSweepPreparation(self, prep, home) then return false end
    local delta = prep.target - zoom
    local distance = math.abs(delta)
    prep.zoomStarted, prep.stableAt, prep.progressZoom = now, now, zoom
    if distance <= 0.05 then return true end
    local speed = CameraSpeed("cameraZoomSpeed")
    if not OwnsSweepPreparation(self, prep, home) then return false end
    -- Keep the captured scan speed, but let native zoom own the endpoint.
    -- Bound zoom speed and restore the preference
    -- with the same ownership checks used for the saved-view blend setting.
    if speed and type(SetCVar) == "function" and self.RestoreCVars then
        self:RestoreCVars("cameraZoomRestore")
        if not OwnsSweepPreparation(self, prep, home) then return false end
        if not self.db.cameraZoomRestore then
            local applied = math.min(50, speed * 4 * home.speed)
            local restore = { cameraZoomSpeed = { old = tostring(speed), applied = tostring(applied) } }
            self.db.cameraZoomRestore = restore
            local ok = pcall(SetCVar, "cameraZoomSpeed", applied)
            -- Native callbacks can cancel preparation and restore/remove this
            -- record before the setter returns. Never continue the old owner.
            if not OwnsSweepPreparation(self, prep, home) or self.db.cameraZoomRestore ~= restore then return false end
            local actual = CameraSpeed("cameraZoomSpeed")
            if not OwnsSweepPreparation(self, prep, home) or self.db.cameraZoomRestore ~= restore then return false end
            if ok and actual then
                restore.cameraZoomSpeed.applied = tostring(actual)
            else self:RestoreCVars("cameraZoomRestore") end
        end
    end
    speed = CameraSpeed("cameraZoomSpeed") or speed or 20
    if not OwnsSweepPreparation(self, prep, home) then return false end
    prep.zoomReadyAt = now + distance / speed
    prep.zoomTimeout = prep.zoomReadyAt + 0.5
    prep.zooming = true
    local ok = self:CallCamera(delta > 0 and CameraZoomOut or CameraZoomIn, distance)
    if not OwnsSweepPreparation(self, prep, home) then return false end
    if not ok then
        self:InvalidateScanHome("Camera zoom unavailable")
        self.cameraScanFailed = true
        return false
    end
    return true
end

function FF:StopSweepPreparation()
    self:StopPreparationZoom()
    if self.cameraSweepPreparation and self.cameraSweepPreparation.savedView then self:ReleaseFishingViewBlend() end
    self.cameraSweepPreparation = nil
end

function FF:BeginSweepPreparation()
    if self.SyncFishingFOV and not self:SyncFishingFOV() then self:FailCameraInput("Fishing FOV preparation unavailable or NPC interaction active"); return end
    if not self:CheckCameraEnvironment("preparation start") then return end
    self:StopCameraMotion()
    if self.SyncLongRangeCameraDistance then self:SyncLongRangeCameraDistance() end
    if type(CenterCamera) ~= "function" or type(CameraZoomOut) ~= "function" or type(CameraZoomIn) ~= "function"
        or type(MoveViewOutStart) ~= "function" or type(MoveViewInStart) ~= "function"
        or type(MoveViewOutStop) ~= "function" or type(MoveViewInStop) ~= "function" or type(GetCameraZoom) ~= "function" then
        self:FailCameraInput("Camera preparation controls unavailable")
        return
    end
    local now, fingerprint = GetTime(), Fingerprint()
    if not fingerprint.zoom then
        self:FailCameraInput("Camera zoom input " .. (fingerprint.zoomError or "invalid"))
        return
    end
    self.cameraRun = nil
    self.cameraHome = { valid = true, centered = true, x = 0, y = 0, fingerprint = fingerprint,
        reason = "Sweep preparation", status = "Centered fishing view", established = now, tilt = self.db.cameraSweepTilt }
    self.cameraHome.speed = self.db.cameraScanSpeed
    self.cameraHome.scanConfig = self:CameraPlanConfig()
    self.cameraSweepPreparation = { started = now, lastZoom = fingerprint.zoom, stableAt = now,
        target = self.db.cameraSweepZoom, tilt = self.cameraHome.scanConfig.tilt,
        requestedZoom = self.db.cameraSweepZoom }
    if self.cameraCast and not self.cameraCast.scanStarted then
        self.cameraCast.scanStarted = now
        self.cameraStats.attempts = self.cameraStats.attempts + 1
    end
    self.cameraAttemptSpacing = self.db.cameraSweepSpacing
    local view = self:ReusableFishingView(self.cameraHome.scanConfig)
    local reference = not view and self:SmartFishingViewReference(self.cameraHome.scanConfig)
    view = view or reference
    local prep, home = self.cameraSweepPreparation, self.cameraHome
    local loaded = view and self:LoadPreparedFishingView(view)
    if self.cameraSweepPreparation ~= prep or self.cameraHome ~= home or not home.valid then return end
    if loaded then
        self.cameraSweepPreparation.savedView = view
        self.cameraSweepPreparation.readyAt = now + self.db.cameraViewDelay
        if reference then
            self.cameraSweepPreparation.smartAdjustment = { tilt = self.cameraHome.scanConfig.tilt - reference.tilt }
        end
        self:CameraState("PREPARE_VIEW")
        self:ArmCameraTick()
        return
    end
    self.cameraFishingView = nil
    if not self:CallCamera(CenterCamera) then
        self:InvalidateScanHome("Camera centering unavailable")
        self.cameraScanFailed = true
        return
    end
    if self.cameraSweepPreparation ~= prep or self.cameraHome ~= home or not home.valid then return end
    self:CameraState("PREPARE_VIEW")
    self:ArmCameraTick()
end

function FF:AdvanceSweepTilt(view, now)
    if view.tiltDone then return now >= view.tiltDone end
    local motion = self.cameraMotion
    if not motion then
        -- Tilt starts from a fresh native center or a settled saved reference.
        -- The same bounded movement engine owns each preparation.
        local moved = self:StartCameraMove({ x = 0, y = view.tilt or 0, kind = "travel", tilt = true,
            stage = self.cameraState == "RESTORE_HOME" and "RESTORE_HOME" or "NORMAL" })
        if not moved then return self.cameraHome and self.cameraHome.valid end
    elseif not motion.startedAt then
        self:BeginCameraMotion(motion, now)
    elseif math.abs(motion.step.y - self.cameraHome.y) <= HOME_TOLERANCE then
        self:StopCameraMotion()
        view.tiltDone = now + 0.08
    else
        self:UpdateSweepTiltMotion(motion, now)
    end
    return false
end

function FF:UpdateSweepTiltMotion(motion, now)
    local home = self.cameraHome
    -- Aim at the next frame of a smooth vertical move. AccountCameraMotion
    -- already integrated the previous rate; reduce speed near the endpoint.
    local frame = math.max(1 / 60, self.cameraFrameDelta or 0, self.cameraFrameMaximum or 0)
    local t = math.min(1, (now - motion.startedAt + frame) / motion.duration)
    local eased = t * t * (3 - 2 * t)
    local target = motion.tiltOrigin + (motion.step.y - motion.tiltOrigin) * eased
    local velocity = (target - home.y) / frame
    velocity = math.max(-motion.tiltRate, math.min(motion.tiltRate, velocity))
    return self:SetCameraRates(motion, 0, velocity)
end

function FF:UpdateSweepPreparation(now)
    local prep = self.cameraSweepPreparation
    -- One check after the native load deadline, before relative Smart tilt.
    if prep.savedView and not prep.environmentChecked and self:SavedFishingViewReady(prep, now) then
        prep.environmentChecked = true
        if not self:CheckCameraEnvironment("preparation completion") then return end
    end
    if prep.savedView then
        if not self:SavedFishingViewReady(prep, now) then return end
        local view, config, speed = prep.savedView, self.cameraHome.scanConfig, self.cameraHome.speed
        local zoom, zoomError = ReadZoom()
        if not zoom or zoom <= 0 then
            self:FailCameraInput("Camera zoom input " .. (zoomError or "invalid"))
            return
        end
        local saved = view
        if prep.smartAdjustment then
            if not prep.smartCentered then
                prep.smartCentered = true
                self:ReleaseFishingViewBlend()
                self.cameraHome.x, self.cameraHome.y = 0, 0
                self.cameraHome.savedView, self.cameraHome.tilt = view, view.tilt
            end
            if not self:AdvanceSweepTilt(prep.smartAdjustment, now) then return end
            local home = self.cameraHome
            saved = self:SavePreparedFishingView(config, zoom, self.db.cameraSweepZoom)
            if self.cameraHome ~= home or not home.valid then return end
            if not saved then self:ResetSmartCameraAdjustment("Preset 3 save failed; base preset 4 next scan") end
        end
        self:StopSweepPreparation()
        self:CaptureScanHome("Saved fishing view")
        self.cameraHome.tilt, self.cameraHome.savedView = config.tilt, saved
        self.cameraHome.speed, self.cameraHome.scanConfig = speed, config
        self.cameraSweepReady, self.cameraSweepAchievedZoom = true, zoom
        self:BeginCameraScan()
        return
    end
    if not prep.zoomComplete then
        local zoom, zoomError = ReadZoom()
        if not zoom then self:FailCameraInput("Camera zoom input " .. zoomError); return end
        -- Accumulate small changes: a slow zoom at high FPS can advance less
        -- than the threshold each frame while still making steady progress.
        if math.abs(zoom - (prep.progressZoom or prep.lastZoom)) > 0.02 then
            prep.stableAt, prep.progressZoom = now, zoom
        end
        prep.lastZoom = zoom
        -- The first preparation centers and zooms before capturing its view.
        if now - prep.started < 0.2 then return end
        if not prep.zoomStarted then
            self:StartPreparationZoom(prep, zoom, now)
            return
        end
        if prep.zooming then
            if math.abs(zoom - prep.target) <= 0.05 then
                -- GetCameraZoom may report the destination before animation
                -- finishes. Wait its bounded travel time before saving it.
                if now < prep.zoomReadyAt then return end
            elseif now < prep.zoomTimeout and now - prep.stableAt < 0.2 then return end
        end
        self:StopPreparationZoom()
        prep.zoomComplete = true
    end
    local config = self.cameraHome.scanConfig
    if not config.rounded and not self:AdvanceSweepTilt(prep, now) then return end
    local zoom, tilt, requestedZoom = prep.lastZoom, prep.tilt, prep.requestedZoom
    local speed = self.cameraHome.speed
    self:StopSweepPreparation()
    self:CaptureScanHome("Prepared Sweep view")
    self.cameraHome.centered, self.cameraHome.status = true, "Centered fishing view"
    self.cameraHome.tilt = tilt
    self.cameraHome.speed, self.cameraHome.scanConfig = speed, config
    self.cameraSweepReady, self.cameraSweepAchievedZoom = true, zoom
    local home = self.cameraHome
    home.savedView = self:SavePreparedFishingView(config, zoom, requestedZoom)
    if self.cameraHome ~= home or not home.valid then return end
    self:ScanLog("Sweep prepared at zoom %.2f; tilt %.2f", zoom, tilt)
    self:BeginCameraScan()
end

function FF:InvalidateScanHome(reason, manualInput)
    local record = self.cameraAttemptDiagnostics
    if record and not record.outcome then
        record.outcome = "cancelled"
        record.reason = Plain(reason) and type(reason) == "string" and reason:sub(1, 160) or "Camera home invalidated"
    end
    if manualInput and self.cameraAssistNeeded and not self:CameraBobberLocated()
        and not self.cameraCenteredReturn then self.cameraManualCancelled = true end
    -- Cancel the active search without discarding its reusable angle/zoom.
    self:ReleaseFishingViewBlend()
    local prepared = self.cameraSweepPreparation or (self.cameraHome and self.cameraHome.centered)
    self:StopSweepPreparation()
    self.cameraCenteredReturn = nil
    self.cameraSweepReady = nil
    self:StopCameraMotion()
    if self.cameraHome then self.cameraHome.valid = false; self.cameraHome.reason = reason end
    self.cameraRun = nil
    self.cameraAssistBobber = false
    self.cameraScanStarted = false
    self.cameraReturnStartedAt = nil
    self.cameraEndSessionAfterRestore = nil
    if prepared then self.cameraScanFailed = true end
    self:UpdateCameraMarkerRightClick()
    self:CameraState(prepared and "FAILED" or "WAIT_HOME")
    if self.ApplyBindings then self:ApplyBindings() end
    if not self.cameraAssistNeeded then self.cameraScanFrame:SetScript("OnUpdate", nil) end
    if self.fishingFOVReleasePending then self:ReleaseFishingFOV(true) end
end

-- Stop callbacks only matter while their axis/control is owned by this operation.
function FF:CameraControlCanInterrupt(name)
    if name == "MoveViewLeftStop" or name == "MoveViewRightStop"
        or name == "MoveViewUpStop" or name == "MoveViewDownStop" then
        local motion = self.cameraMotion
        local axis = motion and motion.axes and motion.axes[
            (name == "MoveViewLeftStop" or name == "MoveViewRightStop") and 1 or 2]
        return axis ~= nil and axis.start ~= nil and (axis.speed or 0) > 0
    end
    if name == "MoveViewInStop" or name == "MoveViewOutStop" then
        local prep, returning = self.cameraSweepPreparation, self.cameraCenteredReturn
        local now = GetTime()
        return (prep ~= nil and (prep.zooming == true
            or (prep.savedView ~= nil and now < (prep.readyAt or 0))))
            or (returning ~= nil and returning.savedView ~= nil and now < (returning.readyAt or 0))
    end
    return self.cameraSweepPreparation ~= nil or self.cameraCenteredReturn ~= nil
        or (self.cameraHome ~= nil and self.cameraHome.valid == true)
end

function FF:ExternalCameraControl(name)
    if self.cameraOwnCall or self.cameraExternalControlCleanup or not self:CameraControlCanInterrupt(name) then return end
    self.cameraExternalControlCleanup = true
    self:InvalidateScanHome("External camera control: " .. name, true)
    -- Relinquish this attempt. Never return over the external view or restart its search.
    self.cameraScanFailed = true
    if self.cameraScanFrame then self.cameraScanFrame:SetScript("OnUpdate", nil) end
    self.cameraExternalControlCleanup = nil
end

function FF:InstallCameraControlHooks()
    if self.cameraControlHooksInstalled or type(hooksecurefunc) ~= "function"
        or (InCombatLockdown and InCombatLockdown()) then return end
    self.cameraControlHooksInstalled = true
    for _, name in ipairs({ "SaveView", "ResetView" }) do
        if type(_G[name]) == "function" then
            hooksecurefunc(name, function(slot)
                local view = self.cameraFishingView
                if not self.cameraOwnCall and self.db.cameraSmartAdjustment and (tonumber(slot) == 3 or tonumber(slot) == 4) then
                    self:ResetSmartCameraAdjustment("Camera preset overwritten; base preset 4 next scan", tonumber(slot) == 4)
                end
                if not self.cameraOwnCall and view and tonumber(slot) == view.slot then
                    self:InvalidateSavedFishingView("Fishing preset overwritten externally; rebuilding next scan")
                end
            end)
        end
    end
    for _, name in ipairs({ "MoveViewLeftStart", "MoveViewRightStart", "MoveViewUpStart", "MoveViewDownStart",
        "SetView", "NextView", "PrevView", "CameraZoomIn", "CameraZoomOut", "CenterCamera",
        "MoveViewOutStart", "MoveViewInStart", "MoveViewLeftStop", "MoveViewRightStop",
        "MoveViewUpStop", "MoveViewDownStop", "MoveViewInStop", "MoveViewOutStop", "FlipCameraYaw" }) do
        if type(_G[name]) == "function" then
            local controlName = name
            hooksecurefunc(controlName, function() self:ExternalCameraControl(controlName) end)
        end
    end
end

function FF:EnsureCameraAssistUI()
    self:InstallCameraControlHooks()
    if self.cameraMarker then return end
    local marker = CreateFrame("Frame", nil, self.bar)
    marker:SetSize(44, 44)
    marker:RegisterForDrag("LeftButton")
    marker:SetScript("OnDragStart", function() self:BeginCameraMarkerDrag() end)
    marker:SetScript("OnDragStop", function() self:EndCameraMarkerDrag(true) end)
    marker:SetScript("OnMouseUp", function(_, button) if button == "LeftButton" then self:EndCameraMarkerDrag(true) end end)
    marker:SetScript("OnHide", function()
        self:EndCameraMarkerDrag(false)
        if marker.info then marker.info:Hide() end
        if marker.onboarding then marker.onboarding:Hide() end
    end)
    marker:SetScript("OnShow", function() self:PositionCameraMarker() end)
    local artwork = marker:CreateTexture(nil, "ARTWORK")
    artwork:SetAllPoints(marker)
    artwork:SetTexCoord(0, 1, 0, 1)
    marker.artwork = artwork
    local info = CreateFrame("Frame", nil, marker, "BackdropTemplate")
    info:EnableMouse(false)
    if info.SetBackdrop then
        info:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        info:SetBackdropColor(0.14, 0.085, 0.035, 0.98)
        info:SetBackdropBorderColor(0.95, 0.75, 0.36, 0.95)
    end
    local label = info:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- Lift one unit to balance the font's baseline inside the border.
    label:SetPoint("CENTER", info, "CENTER", 0, 1)
    label:SetTextColor(1, 0.69, 0.28)
    label:SetShadowOffset(0, 0)
    label:SetText(self:LocalizedText("camera.help.marker"))
    -- Measure once: equal padding around the text, with no fixed empty width.
    local padding = 8
    info:SetSize(math.ceil(label:GetStringWidth()) + padding * 2,
        math.ceil(label:GetStringHeight()) + padding * 2)
    marker.label = label
    marker.info = info
    local tip = CreateFrame("Frame", nil, marker)
    tip:EnableMouse(false)
    tip:SetClampedToScreen(true)
    -- Clear the centered drag helper even when it flips below the box.
    local helperGap = math.max(20, math.ceil(info:GetWidth() / 2) - marker:GetWidth() / 2 + 12)
    tip:SetPoint("TOPLEFT", marker, "BOTTOMRIGHT", helperGap + 125, 87)
    tip:SetSize(380, 150)
    -- Use dedicated antialiased bubble artwork as nine slices. Only the middles
    -- stretch when the binding changes height; corner radii stay constant.
    local media = "Interface\\AddOns\\ForeverFishing\\Media\\"
    local function BubbleLayer(file, r, g, b, alpha, outset, layer, sublevel, additive)
        local corner = 30 + outset
        local slices = {
            { "TOPLEFT", -outset, outset, corner, corner },
            { "TOPLEFT", corner-outset, outset, nil, corner, "TOPRIGHT", outset-corner, outset },
            { "TOPRIGHT", outset, outset, corner, corner },
            { "TOPLEFT", -outset, outset-corner, corner, nil, "BOTTOMLEFT", -outset, corner-outset },
            { "TOPLEFT", corner-outset, outset-corner, nil, nil, "BOTTOMRIGHT", outset-corner, corner-outset },
            { "TOPRIGHT", outset, outset-corner, corner, nil, "BOTTOMRIGHT", outset, corner-outset },
            { "BOTTOMLEFT", -outset, -outset, corner, corner },
            { "BOTTOMLEFT", corner-outset, -outset, nil, corner, "BOTTOMRIGHT", outset-corner, -outset },
            { "BOTTOMRIGHT", outset, -outset, corner, corner },
        }
        local coords = { 0, 0.25, 0.75, 1 }
        for index, slice in ipairs(slices) do
            local texture = tip:CreateTexture(nil, layer, nil, sublevel)
            texture:SetTexture(media .. file)
            local col, row = (index - 1) % 3 + 1, math.floor((index - 1) / 3) + 1
            texture:SetTexCoord(coords[col], coords[col+1], coords[row], coords[row+1])
            texture:SetPoint(slice[1], tip, slice[1], slice[2], slice[3])
            if slice[4] then texture:SetWidth(slice[4]) end
            if slice[5] then texture:SetHeight(slice[5]) end
            if slice[6] then texture:SetPoint(slice[6], tip, slice[6], slice[7], slice[8]) end
            texture:SetVertexColor(r, g, b, alpha)
            if additive then texture:SetBlendMode("ADD") end
        end
    end
    BubbleLayer("CameraOnboardingGlow", 0, 0, 0, 0.25, 8, "BACKGROUND", -8)
    BubbleLayer("CameraOnboardingGlow", 0.28, 0.52, 0.75, 0.20, 8, "BACKGROUND", -7, true)
    BubbleLayer("CameraOnboardingFill", 1, 1, 1, 0.92, 0, "BACKGROUND", -6)
    BubbleLayer("CameraOnboardingEdge", 0.45, 0.66, 0.80, 0.36, 0, "BORDER", 0)
    local function TipLine(text, size, r, g, b)
        local line = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        FF:SetDisplayFont(line,"Fonts\\ARIALN.TTF", size, "")
        line:SetWidth(352)
        line:SetJustifyH("CENTER")
        line:SetWordWrap(true)
        line:SetSpacing(2)
        line:SetShadowColor(0, 0, 0, 0.60)
        line:SetShadowOffset(0, -1)
        line:SetTextColor(r, g, b)
        line:SetText(text)
        return line
    end
    tip.title = TipLine(self:LocalizedText("camera.help.title"), 15, 0.88, 0.94, 1)
    tip.title:SetPoint("TOP", tip, "TOP", 0, -14)
    tip.hook = TipLine("", 14, 0.96, 0.97, 1)
    tip.warning = TipLine(self:LocalizedText("camera.help.warning"), 13, 0.96, 0.81, 0.45)
    FF:SetDisplayFont(tip.warning,"Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    tip.instructions = {
        TipLine(self:LocalizedText("camera.help.cursor"), 14, 0.95, 0.96, 0.98),
        TipLine(self:LocalizedText("camera.help.scan"), 14, 0.95, 0.96, 0.98),
        tip.hook,
        tip.warning,
    }
    tip.footer = TipLine(self:LocalizedText("camera.help.footer"), 10, 0.51, 0.56, 0.60)
    tip.footer:SetPoint("TOP", tip.warning, "BOTTOM", 0, -5)
    tip:Hide()
    marker.onboarding = tip
    -- Configure after mouse scripts, which can implicitly enable mouse motion.
    -- Capture left drags, but leave world hover and other buttons available.
    marker:EnableMouse(true)
    marker:SetMouseMotionEnabled(false)
    marker:SetPropagateMouseMotion(true)
    marker:SetPassThroughButtons("RightButton", "MiddleButton", "Button4", "Button5")
    marker:Hide()
    self.cameraMarker = marker
    self:SetCameraMarkerStyle(self.db.cameraMarkerStyle)
    self:PositionCameraMarker()
    local frame = CreateFrame("Frame", nil, self:EnsureFishingVisibilityRoot())
    self.cameraScanFrame = frame
    self.cameraTick = function(_, elapsed)
        local cast = self.cameraCast
        local started = self.db.cameraScanLogging and debugprofilestop and debugprofilestop()
        self:CameraAssistTick(elapsed)
        if started and cast then
            cast.maxTickCPU = math.max(cast.maxTickCPU or 0, debugprofilestop() - started)
        end
    end
    self.cameraMouseHeld = {}
    for _, event in ipairs({ "PLAYER_STARTED_MOVING", "ZONE_CHANGED_NEW_AREA", "PLAYER_LEAVING_WORLD",
        "PLAYER_REGEN_DISABLED", "GLOBAL_MOUSE_DOWN", "GLOBAL_MOUSE_UP" }) do
        pcall(frame.RegisterEvent, frame, event)
    end
    frame:SetScript("OnEvent", function(_, event, button)
        if event == "PLAYER_STARTED_MOVING" then self:ResetSmartCameraAdjustment("Player moved; base preset 4 next scan") end
        if event == "WORLD_CURSOR_TOOLTIP_UPDATE" or event == "CURSOR_CHANGED" then
            local cast = self.cameraCast
            if cast then cast.cursorEvents = (cast.cursorEvents or 0) + 1 end
            if not self.active or not self.cameraAssistNeeded or self.cameraState == "RESTORE_HOME"
                or self.cameraSweepPreparation then self:UpdateCameraMarkerInfo(); return end
            if self:CameraMarkerHasCursor() and self:CursorOnFishingBobber() then self:SetCameraAssistBobber(true)
            elseif self.cameraAssistBobber then self:SetCameraAssistBobber(false) end
            self:UpdateCameraMarkerInfo()
        elseif event == "GLOBAL_MOUSE_UP" then
            self.cameraMouseHeld[button] = nil
            if button == "LeftButton" then self:EndCameraMarkerDrag(true) end
        elseif event == "GLOBAL_MOUSE_DOWN" then
            if button ~= "RightButton" and button ~= "LeftButton" then return end
            self.cameraMouseHeld[button] = true
            if not self.db.cameraAssist or not (self.cameraSweepPreparation or (self.cameraHome and self.cameraHome.valid)) then return end
            if C_Timer and C_Timer.After then
                C_Timer.After(0.12, function()
                    if self.cameraMouseHeld[button] and IsMouselooking and IsMouselooking()
                        and (self.cameraSweepPreparation or (self.cameraHome and self.cameraHome.valid)) then self:InvalidateScanHome("Manual camera movement", true) end
                end)
            end
        elseif self.cameraMarkerDrag or self.cameraSweepPreparation or (self.cameraHome and self.cameraHome.valid) then
            self:EndCameraMarkerDrag(false)
            self:InvalidateScanHome(event == "PLAYER_STARTED_MOVING" and "Player moved" or event)
            if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_LEAVING_WORLD" then
                self.cameraScanFrame:SetScript("OnUpdate", nil)
            end
        end
    end)
end

function FF:InitializeCameraScanning()
    self:InitializeScanConfig()
    self:ResetCameraStatistics()
    self:EnsureCameraAssistUI()
    self:CameraState("IDLE")
end

function FF:ArmCameraTick()
    self:EnsureCameraAssistUI()
    self.cameraScanFrame:SetScript("OnUpdate", self.cameraTick)
end

function FF:FinishCameraAttempt(outcome, stage)
    local record = self.cameraAttemptDiagnostics
    if record and (not record.outcome or outcome == "found") then
        record.outcome = outcome
        record.reason = outcome == "found" and "Bobber located (not catch confirmation)"
            or (outcome == "failed" and "Scan ended without locating bobber" or "Search cancelled")
    end
    local cast, stats = self.cameraCast, self.cameraStats
    if not cast or not cast.scanStarted or cast.finished then return end
    cast.finished = true
    local rows = cast.rows or 0
    if outcome == "found" and self.cameraMotion and self.cameraMotion.step.kind == "scan" then rows = rows + 1 end
    stats.rows, stats.finished = stats.rows + rows, stats.finished + 1
    if outcome == "found" then
        local elapsed = GetTime() - cast.scanStarted
        stats.detections, stats.timeTotal = stats.detections + 1, stats.timeTotal + elapsed
        stats.worst = math.max(stats.worst, elapsed)
        stats.samples[stats.sampleIndex] = elapsed
        stats.sampleIndex = stats.sampleIndex % 200 + 1
        stats.revision = stats.revision + 1
        self.cameraLastDetectionTime = elapsed
    elseif outcome == "failed" then
        stats.failures = stats.failures + 1
    else stats.cancelled = stats.cancelled + 1 end
end

function FF:StartCameraMove(step)
    self:StopCameraMotion()
    local home = self.cameraHome
    if not home or not home.valid then return false end
    local yaw, pitch = CameraSpeed("cameraYawMoveSpeed"), CameraSpeed("cameraPitchMoveSpeed")
    if not yaw or not pitch then
        self:InvalidateScanHome("Camera speed CVars unavailable")
        self.cameraScanFailed = true
        self.cameraScanFrame:SetScript("OnUpdate", nil)
        return false
    end
    local dx, dy = step.x - home.x, step.y - home.y
    if math.abs(dx) + math.abs(dy) < 0.0001 then return false end
    local rate = YAW_RATE * home.speed
    local yr, pr = rate, rate
    local duration = math.sqrt(dx * dx + dy * dy) / rate
    if step.tilt then duration = math.max(0.18, duration * 1.5) end
    if step.kind == "travel" then
        -- Tiny row steps must not jump past their destination in one frame.
        duration = math.max(duration, 4 * math.max(1 / 60, self.cameraFrameDelta or 0))
    end
    local vx, vy = dx / duration, dy / duration
    local motions = {}
    -- Keep the same tested camera API directions. Logical +Y denotes Down.
    if dx < 0 then motions[#motions + 1] = { start = MoveViewRightStart, speed = -vx / yaw }
    elseif dx > 0 then motions[#motions + 1] = { start = MoveViewLeftStart, speed = vx / yaw } end
    if dy > 0 then motions[#motions + 1] = { start = MoveViewUpStart, speed = vy / pitch }
    elseif dy < 0 then motions[#motions + 1] = { start = MoveViewDownStart, speed = -vy / pitch } end
    self.cameraMotion = { step = step, duration = duration, vx = vx, vy = vy, motions = motions,
        originX = home.x, originY = home.y, yawRate = yaw, pitchRate = pitch, maxVX = yr, maxVY = pr,
        profile = not step.tilt, rate = rate }
    if step.tilt then
        self.cameraMotion.tiltOrigin, self.cameraMotion.tiltRate, self.cameraMotion.pitchRate = home.y, pr, pitch
    end
    -- Every movement uses the same native rate setter and one vector limit.
    self.cameraMotion.vx, self.cameraMotion.vy = 0, 0
    self.cameraMotion.axes = {
            { positive = MoveViewLeftStart, negative = MoveViewRightStart, stopPositive = MoveViewLeftStop, stopNegative = MoveViewRightStop, rate = yaw },
            { positive = MoveViewUpStart, negative = MoveViewDownStart, stopPositive = MoveViewUpStop, stopNegative = MoveViewDownStop, rate = pitch },
    }
    -- Preserve the proven zero-speed priming frame to prevent camera jumps.
    for _, motion in ipairs(motions) do
        if not self:CallCamera(motion.start, 0) then self:InvalidateScanHome("Camera movement unavailable"); return false end
    end
    self:ArmCameraTick()
    return true
end

local function OwnsCameraMotion(self, motion, home)
    return motion and self.cameraMotion == motion and home
        and self.cameraHome == home and home.valid
end

function FF:SetCameraRates(motion, vx, vy)
    local home = self.cameraHome
    if not OwnsCameraMotion(self, motion, home) then return false end
    local length = math.sqrt(vx * vx + vy * vy)
    if length > motion.rate then
        vx, vy = vx * motion.rate / length, vy * motion.rate / length
    end
    if math.abs(vx) < 0.000001 then vx = 0 end
    if math.abs(vy) < 0.000001 then vy = 0 end
    for index = 1, 2 do
        local velocity = index == 1 and vx or vy
        local axis = motion.axes[index]
        -- A resting axis has no direction. In particular, a horizontal pass
        -- must not restart pitch movement because of a tiny rounding residual.
        if velocity == 0 then
            if axis.start and (axis.speed or 0) > 0 then
                self:CallCamera(axis.start == axis.positive and axis.stopPositive or axis.stopNegative)
                if not OwnsCameraMotion(self, motion, home) then return false end
            end
            axis.start, axis.speed = nil, 0
        else
            local start = velocity >= 0 and axis.positive or axis.negative
            local speed = math.abs(velocity) / axis.rate
            if axis.start and axis.start ~= start then
                self:CallCamera(axis.stopPositive)
                if not OwnsCameraMotion(self, motion, home) then return false end
                self:CallCamera(axis.stopNegative)
                if not OwnsCameraMotion(self, motion, home) then return false end
            end
            if axis.start ~= start or math.abs((axis.speed or 0) - speed) > 0.000001 then
                local ok = self:CallCamera(start, speed)
                -- Cancellation may have stopped both axes inside this call.
                -- Do not restart the other axis or update stale motion state.
                if not OwnsCameraMotion(self, motion, home) then return false end
                if not ok then
                    self:InvalidateScanHome("Camera movement unavailable")
                    return false
                end
            end
            axis.start, axis.speed = start, speed
        end
    end
    motion.vx, motion.vy = vx, vy
    return true
end

function FF:UpdateCameraMotion(motion, now)
    local home = self.cameraHome
    local frame = 1.5 * math.max(1 / 60, self.cameraFrameDelta or 0, self.cameraFrameMaximum or 0)
    local progress = math.max(0, math.min(1, (now - motion.startedAt + frame) / motion.duration))
    local x = motion.originX + (motion.step.x - motion.originX) * progress
    local y = motion.originY + (motion.step.y - motion.originY) * progress
    return self:SetCameraRates(motion, (x - home.x) / frame, (y - home.y) / frame)
end

function FF:StartCameraPath()
    local run = self.cameraRun
    local yaw, pitch = CameraSpeed("cameraYawMoveSpeed"), CameraSpeed("cameraPitchMoveSpeed")
    if not yaw or not pitch then self:InvalidateScanHome("Camera speed CVars unavailable"); return end
    local _, _, index = P.Sample(run.steps, run.elapsed)
    self.cameraMotion = { path = true, step = run.steps[index], duration = run.duration - run.elapsed,
        elapsedBase = run.elapsed, vx = 0, vy = 0, rate = run.rate,
        axes = {
            { positive = MoveViewLeftStart, negative = MoveViewRightStart, stopPositive = MoveViewLeftStop, stopNegative = MoveViewRightStop, rate = yaw },
            { positive = MoveViewUpStart, negative = MoveViewDownStart, stopPositive = MoveViewUpStop, stopNegative = MoveViewDownStop, rate = pitch },
        } }
    -- Prime only when starting or resuming the complete path, never at a join.
    for _, axis in ipairs(self.cameraMotion.axes) do
        if not self:CallCamera(axis.positive, 0) then self:InvalidateScanHome("Camera movement unavailable"); return end
    end
    self:CameraState("NORMAL")
    self:ArmCameraTick()
end

function FF:CompleteCameraScanMiss()
    if self.cameraHome and self.cameraHome.scanConfig and self.cameraHome.scanConfig.smart then
        self:ResetSmartCameraAdjustment("Smart scan missed; base preset 4 next scan")
    end
    self.cameraScanFailed = true
    if self.cameraCast then self.cameraCast.scanExhausted = true end
    self:UpdateCameraMarkerRightClick()
    self:FinishCameraAttempt("failed")
    self:TraceTransition("camera assist scan ended without a bobber")
    self:ScanLog("Complete scan failed")
    self:RestoreScanHome()
    if self.UpdateRangeNotice then self:UpdateRangeNotice() end
end

function FF:UpdateCameraPathMotion(motion, now)
    local run, home = self.cameraRun, self.cameraHome
    local elapsed = motion.elapsedBase + now - motion.startedAt
    local frame = math.max(1 / 240, self.cameraFrameDelta or 1 / 60)
    if elapsed + frame >= run.duration then
        frame = 1.5 * math.max(1 / 60, frame, self.cameraFrameMaximum or 0)
    end
    local x, y, targetIndex, progress = P.Sample(run.steps, elapsed + frame)
    local _, _, index = P.Sample(run.steps, elapsed)
    -- Anchor each new horizontal row to the pitch actually reached by the
    -- camera. Do not correct the remaining curve error on a straight pass.
    -- Subsequent arcs inherit that origin and still use the selected spacing.
    local step = run.steps[index]
    if not step.turn and not step.curve and step.kind == "scan" and index ~= run.pitchRow then
        run.pitchRow = index
        run.pitchOffset = home.y - step.y
    end
    local targetStep = run.steps[targetIndex]
    if targetStep.turn or targetStep.curve then
        -- Spread any small row offset through the next arc, with zero slope
        -- at either end. This keeps spacing from drifting after many rows.
        local blend = progress * progress * (3 - 2 * progress)
        y = y + (run.pitchOffset or 0) * (1 - blend)
    elseif (not step.turn and not step.curve) or targetIndex == index then
        y = y + (run.pitchOffset or 0)
    end
    motion.step, run.index = run.steps[index], index
    self.cameraScanCompletedSteps = index - 1
    while run.completed < #run.steps and elapsed >= run.steps[run.completed + 1].ends do
        run.completed = run.completed + 1
        if run.steps[run.completed].rowEnd and self.cameraCast then self.cameraCast.rows = self.cameraCast.rows + 1 end
    end
    local last = run.steps[#run.steps]
    if elapsed >= run.duration and math.abs(last.x - home.x) + math.abs(last.y + (run.pitchOffset or 0) - home.y) < 0.005 then
        self:StopCameraMotion()
        self:CompleteCameraScanMiss()
        return
    end
    local vx, vy = (x - home.x) / frame, (y - home.y) / frame
    if not step.turn and not step.curve and step.kind == "scan" and targetIndex == index then
        vy = 0
    elseif step.turn or step.curve then
        -- Quarter entries can point upward. Row turns always move down.
        local direction = step.y >= step.fromY and 1 or -1
        local remaining = direction * (step.y - home.y)
        local safeFrame = 1.3 * math.max(frame, self.cameraFrameMaximum or frame)
        vy = direction * math.max(0, math.min(direction * vy, remaining / safeFrame))
    end
    self:SetCameraRates(motion, vx, vy)
end

function FF:OnCameraHomeRestored()
    local home = self.cameraHome
    if home then home.lastRestored = GetTime() end
    if self.cameraReturnStartedAt then self.cameraLastReturnTime = GetTime() - self.cameraReturnStartedAt end
    self.cameraReturnStartedAt = nil
    self:ScanLog("Fishing view recentered")
    if self.cameraEndSessionAfterRestore then
        self.cameraEndSessionAfterRestore = nil
        if home then home.valid = false; home.reason = "Fishing session ended" end
    end
    if self.active and self.cameraAssistNeeded and not self.cameraScanFailed then
        self:CameraState("WAIT_CURSOR")
    else
        self:CameraState(self.cameraScanFailed and "FAILED" or "IDLE")
        self.cameraScanFrame:SetScript("OnUpdate", nil)
    end
    if self.fishingFOVReleasePending then self:ReleaseFishingFOV(true) end
end

function FF:RestoreScanHome()
    if not self:CheckCameraEnvironment("camera return") then return end
    self:StopCameraMotion()
    self.cameraRun = nil
    self.cameraAssistBobber = false
    if self.ApplyBindings then self:ApplyBindings() end
    local home = self.cameraHome
    if not home or not home.valid then
        self:StopSweepPreparation()
        self.cameraEndSessionAfterRestore = nil
        self:CameraState("IDLE")
        self.cameraScanFrame:SetScript("OnUpdate", nil)
        return
    end
    if self.cameraCenteredReturn then return end
    self.cameraSweepReady = nil
    self.cameraReturnStartedAt = self.cameraReturnStartedAt or GetTime()
    self:CameraState("RESTORE_HOME")
    local prep = self.cameraSweepPreparation
    if prep and prep.savedView and prep.savedView == self.cameraFishingView and not prep.smartCentered then
        -- The native load is already returning to HOME. Transfer ownership,
        -- including its blend setting and original deadline, without SetView
        -- again or a center/tilt fallback when this cast is interrupted.
        self.cameraSweepPreparation = nil
        home.savedView = prep.savedView
        home.tilt = prep.savedView.tilt
        self.cameraCenteredReturn = { readyAt = prep.readyAt,
            tilt = prep.tilt or 0, savedView = prep.savedView }
        home.fingerprint = Fingerprint()
        self:ArmCameraTick()
        return
    end
    self:StopSweepPreparation()
    local loaded = home.savedView and self:LoadPreparedFishingView(home.savedView)
    if self.cameraHome ~= home or not home.valid then return end
    if loaded then
        self.cameraCenteredReturn = { readyAt = GetTime() + self.db.cameraViewDelay,
            tilt = home.tilt or 0, savedView = home.savedView,
            smartConfig = self:SmartCameraReturnConfig(home) }
        home.fingerprint = Fingerprint()
        self:ArmCameraTick()
        return
    end
    if not self:CallCamera(CenterCamera) then self:InvalidateScanHome("Camera centering unavailable"); return end
    if self.cameraHome ~= home or not home.valid then return end
    home.fingerprint = Fingerprint()
    self.cameraCenteredReturn = { readyAt = GetTime() + 0.25, tilt = home.tilt or 0 }
    self:ArmCameraTick()
end

function FF:StopCameraAssist(reason, endSession)
    self:EndCameraMarkerDrag(false)
    self:FinishCameraAttempt("cancelled")
    self:EndCameraAttemptDiagnostics(reason)
    self:StopCameraMotion()
    self.cameraAssistNeeded, self.cameraAssistBobber = false, false
    self.cameraScanStarted, self.cameraScanFailed = false, false
    self.cameraAssistReason = nil
    self.cameraManualCancelled = nil
    self.cameraEnvironmentCancelled = nil
    if self.cameraMarker and not (InCombatLockdown and InCombatLockdown()) then self.cameraMarker:Hide() end
    self:UpdateCameraMarkerRightClick()
    if self.cameraScanFrame then
        pcall(self.cameraScanFrame.UnregisterEvent, self.cameraScanFrame, "WORLD_CURSOR_TOOLTIP_UPDATE")
        pcall(self.cameraScanFrame.UnregisterEvent, self.cameraScanFrame, "CURSOR_CHANGED")
    end
    if endSession then self.cameraEndSessionAfterRestore = true end
    if self.cameraScanFrame and InCombatLockdown and InCombatLockdown() then
        -- A secure bar close/channel end can arrive under lockdown. Stop the
        -- search without hiding/moving protected marker controls or returning
        -- the camera; the ordinary peace cleanup finishes the hidden marker.
        self:InvalidateScanHome("Combat")
        self.cameraScanFrame:SetScript("OnUpdate", nil)
    elseif self.cameraScanFrame then self:RestoreScanHome() else self:StopSweepPreparation() end
end

function FF:CameraCastStarted(resumed)
    if self.db.cameraAssist then self:CheckCameraEnvironment("cast start") end
    self:EndCameraAttemptDiagnostics("Replaced by next cast")
    self:StopSweepPreparation()
    self.cameraSweepReady = nil
    local now = GetTime()
    if self.cameraHome and (self.cameraHome.valid or self.cameraHome.reason == "Fishing FOV released") then
        local changed, zoomError = FingerprintChanged(self.cameraHome.fingerprint)
        if zoomError then
            self:InvalidateScanHome("Camera zoom input " .. zoomError)
        elseif changed then
            self:ResetSmartCameraAdjustment("Player position changed; base preset 4 next scan")
            self:InvalidateScanHome("Player position, facing or zoom changed")
        end
    end
    self.cameraLastCastAt = now
    self.cameraCast = { id = self.channelStartSerial, started = now, rows = 0 }
    self.cameraInputFailures, self.cameraInputFailureReason = nil, nil
    self.cameraManualCancelled = nil
    self.cameraEnvironmentCancelled = nil
    self.cameraAttemptSpacing = nil
    if self.db.cameraAssist and not resumed then self.cameraStats.casts = self.cameraStats.casts + 1 end
    self.cameraAssistNeeded, self.cameraAssistBobber = false, false
    self:UpdateCameraMarkerRightClick()
    self.cameraScanFailed, self.cameraScanStarted = false, false
    self.cameraScanObjectSamples, self.cameraScanCompletedSteps = 0, 0
    self.cameraScanLastObject = nil
    if self.cameraState ~= "RESTORE_HOME" then self:CameraState("IDLE") end
end

function FF:CameraChannelEnded(reason)
    if self.cameraCast then self.cameraCast.endedAt = GetTime() end
    if self.cameraCast and self.cameraCast.scanStarted and not self.cameraCast.finished then
        local expired = self.castEnd and GetTime() >= self.castEnd - 0.3
        self:FinishCameraAttempt(expired and "failed" or "cancelled")
    end
    self:StopCameraAssist(reason)
end



function FF:CameraBobberLocated()
    return self.cameraCast and self.cameraCast.bobberLocated == true or false
end

function FF:IsCameraSearchPending()
    -- Flyouts must yield before the first cursor probe, and remain closed
    -- while waiting for the marker or paused between moving scan updates.
    -- Keep this separate from the narrower background-refresh busy boundary.
    return self.active and self.cameraAssistNeeded and self.db.cameraAssist
        and self.bar and self.bar:IsShown() and not self:CameraBobberLocated()
        and not self.cameraScanFailed and not (InCombatLockdown and InCombatLockdown()) or false
end

function FF:IsCameraSearchBusy()
    -- Background skill events can ask before PLAYER_LOGIN attaches saved settings.
    return self.db and self.db.cameraAssist and self.active and self.cameraAssistNeeded and not self:CameraBobberLocated()
        and not self.cameraScanFailed and self.cameraState ~= "RESTORE_HOME"
        and (self.cameraMotion ~= nil or self.cameraSweepPreparation ~= nil) or false
end

function FF:RefreshLocatedBobberHover()
    if not self.db.cameraAssist or not self:CameraBobberLocated() or not self.active or not self.cameraAssistNeeded
        or self.cameraState == "RESTORE_HOME" or self.cameraMarkerDrag then return end
    self:SetCameraAssistBobber(self:CameraMarkerHasCursor() and self:CursorOnFishingBobber())
end

function FF:SetCameraAssistBobber(found)
    found = found == true
    if self.cameraAssistBobber == found then return end
    if found then
        if not self:CameraBobberLocated() then
            -- The cursor event can find a bobber before the first movement tick.
            -- That is a valid row-zero acquisition, not an untracked detection.
            if not self.cameraHome or not self.cameraHome.valid then self:CaptureScanHome("Current fishing view") end
            if self.cameraCast and not self.cameraCast.scanStarted then
                self.cameraCast.scanStarted = GetTime()
                self.cameraAttemptSpacing = self.db.cameraSweepSpacing
                self.cameraStats.attempts = self.cameraStats.attempts + 1
            end
            self:AccountCameraMotion(GetTime())
            local motion = self.cameraMotion
            local stage = motion and motion.step.stage or self.cameraState
            if stage ~= "NORMAL" then stage = "NORMAL" end
            self:FinishCameraAttempt("found", stage)
            self:StopSweepPreparation()
            self:StopCameraMotion()
            local home = self.cameraHome
            self:LearnSmartCameraTilt()
            local row = home and Round(home.y / (self.cameraAttemptSpacing or self.db.cameraSweepSpacing)) or 0
            if motion and motion.path then row = math.max(0, motion.step.row or 0) end
            local x = home and home.x
            if self.cameraAttemptCursor then
                local cx, cy = self:ReadCameraCursor(true)
                if not cx or not cy or math.abs(cx - self.cameraAttemptCursor[1]) + math.abs(cy - self.cameraAttemptCursor[2]) > 8 then x = nil end
            end
            self.cameraLastFound = { row = row, x = x, y = home and home.y, stage = stage, time = GetTime() }
            if self.cameraCast then self.cameraCast.bobberLocated = true end
            -- Attach the existing verified acquisition to this statistics cast.
            -- STOP-before-LOOT and reload must not lose which cast was assisted.
            local catch = self.statsCast
            if catch and not catch.ended and catch.started == self.castStart then
                catch.cameraAssisted = true
                local saved = self.db.pendingFishingCast
                if saved and saved.token == catch.token then saved.cameraAssisted = true end
            end
            self:UpdateCameraMarkerRightClick()
            -- Finding the bobber completes this cast's search. Keep hover state
            -- separate for safe hooking, but never resume the abandoned path.
            self.cameraRun = nil
            self.cameraScanFrame:SetScript("OnUpdate", nil)
            self:ScanLog("Bobber found at row %+d", row)
            self:TraceTransition("camera assist found bobber under cursor; row " .. row .. "; " .. stage)
        end
        self.cameraAssistBobber = true
        self:CameraState("FOUND")
    else
        self.cameraAssistBobber = false
        self:CameraState(self:CameraBobberLocated() and "FOUND_WAIT_CURSOR" or "PAUSED")
    end
    self:ApplyBindings()
    if self.UpdateRangeNotice then self:UpdateRangeNotice() end
    if self.UpdateCameraAssistStatus then self:UpdateCameraAssistStatus() end
    if self.SyncRangeSound then self:SyncRangeSound() end
end

function FF:AdvanceCameraScan()
    local run = self.cameraRun
    if not run then return end
    run.index = run.index + 1
    local step = run.steps[run.index]
    self.cameraScanCompletedSteps = run.index - 1
    if not step then
        self:CompleteCameraScanMiss()
        return
    end
    if run.stage ~= step.stage then
        run.stage = step.stage
        self:CameraState(step.stage)
    end
    if step.kind == "scan" and step.row ~= nil then self:ScanLog("Scanning row %+d", step.row) end
    if not self:StartCameraMove(step) and self.cameraHome and self.cameraHome.valid then self:AdvanceCameraScan() end
end

function FF:BeginCameraScan()
    if self.cameraEnvironmentCancelled then return end
    if self:CameraBobberLocated() then return end
    if not self.cameraSweepReady then
        if not self.cameraSweepPreparation then self:BeginSweepPreparation() end
        return
    end
    local home = self.cameraHome
    if not home or not home.valid then return end
    if not self:CheckCameraEnvironment("scan start") then return end
    if math.max(math.abs(home.x), math.abs(home.y)) > HOME_TOLERANCE then self:RestoreScanHome(); return end
    local config = home.scanConfig or self:CameraPlanConfig()
    local cx, cy = self:ReadCameraCursor()
    if not cx or not cy then return end
    self.cameraAttemptCursor = { cx, cy }
    local steps = P.Build(config)
    self.cameraRun = { steps = steps, index = 0, rate = YAW_RATE * home.speed,
        path = config.rounded or config.racetrack, elapsed = 0, completed = 0 }
    if self.cameraRun.path then
        self.cameraRun.duration = P.Time(steps, self.cameraRun.rate)
    end
    self.cameraAttemptSpacing = config.spacing
    self.cameraScanSteps = steps
    if self.cameraCast and not self.cameraCast.scanStarted then
        self.cameraCast.scanStarted = GetTime()
        self.cameraStats.attempts = self.cameraStats.attempts + 1
    end
    self.cameraScanStarted = true
    local record = self.cameraAttemptDiagnostics
    if record and not record.scanContext then record.scanContext = self:CameraTraceContext(true) end
    if self.cameraRun.path then self:StartCameraPath() else self:AdvanceCameraScan() end
end

function FF:BeginCameraMotion(motion, now)
    motion.startedAt, motion.accountedAt = now, now
    if motion.path then return self:UpdateCameraPathMotion(motion, now) end
    if motion.profile then return self:UpdateCameraMotion(motion, now) end
    if motion.step.tilt then return self:UpdateSweepTiltMotion(motion, now) end
    for _, part in ipairs(motion.motions) do
        if not self:CallCamera(part.start, part.speed) then
            self:InvalidateScanHome("Camera movement unavailable")
            self.cameraScanFailed = true
            self.cameraScanFrame:SetScript("OnUpdate", nil)
            return false
        end
    end
    return true
end

function FF:CameraAssistTick(elapsed)
    if self.cameraMarkerDrag then return end
    elapsed = SafeNumber(elapsed)
    if not elapsed or elapsed < 0 then self:FailCameraInput("Camera frame interval invalid"); return end
    self.cameraFrameDelta = elapsed
    local cast = self.cameraCast
    if cast and self:IsCameraSearchBusy() then
        cast.scanFrames = (cast.scanFrames or 0) + 1
        cast.maxFrameDelta = math.max(cast.maxFrameDelta or 0, elapsed)
    end
    if self.cameraMotion and self.cameraMotion.startedAt then
        if elapsed > 0.25 then
            self:InvalidateScanHome("Large frame gap; camera movement cancelled")
            return
        end
        -- Keep a recent hitch briefly for endpoint safety, then recover as
        -- frames stabilize. A single slow frame must not slow the whole cast.
        self.cameraFrameMaximum = math.max(elapsed, (self.cameraFrameMaximum or 0) - elapsed)
    end
    local now = GetTime()
    if IsMouselooking and IsMouselooking() then
        if self.cameraHome and self.cameraHome.valid then self:InvalidateScanHome("Manual camera movement", true) end
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        self:InvalidateScanHome("Combat")
        self.cameraScanFrame:SetScript("OnUpdate", nil)
        return
    end
    self.cameraGuardElapsed = (self.cameraGuardElapsed or 0) + elapsed
    if self.cameraGuardElapsed >= 0.2 then
        self.cameraGuardElapsed = 0
        if self.cameraHome and self.cameraHome.valid then
            local changed, zoomError = FingerprintChanged(self.cameraHome.fingerprint, self.cameraSweepPreparation ~= nil or (self.cameraCenteredReturn and self.cameraCenteredReturn.savedView) ~= nil)
            if zoomError then self:FailCameraInput("Camera zoom input " .. zoomError); return end
            if changed then
                self:ResetSmartCameraAdjustment("Player position changed; base preset 4 next scan")
                self:InvalidateScanHome("Player position, facing or camera zoom changed", true)
                return
            end
        end
    end
    self:AccountCameraMotion(now)
    local motion = self.cameraMotion
    if self.cameraState == "RESTORE_HOME" then
        if self.cameraCenteredReturn then
            local view = self.cameraCenteredReturn
            if now < view.readyAt then return end
            if not view.centered then
                view.centered = true
                self.cameraHome.x, self.cameraHome.y = 0, 0
            end
            if view.savedView then
                local zoom, zoomError = ReadZoom()
                if not zoom or zoom <= 0 then
                    self:FailCameraInput("Camera zoom input " .. (zoomError or "invalid"))
                    return
                end
            end
            if view.smartConfig then
                -- The first verified find can prepare preset 3 as this cast
                -- ends. Load its known source view once, then reuse the same
                -- bounded relative tilt used by scan preparation.
                local config = view.smartConfig
                if not view.smartAdjustment then
                    self:ReleaseFishingViewBlend()
                    view.smartAdjustment = { tilt = config.tilt - self.cameraHome.tilt }
                end
                if not self:AdvanceSweepTilt(view.smartAdjustment, now) then return end
                local zoom, zoomError = ReadZoom()
                if not zoom then self:FailCameraInput("Camera zoom input " .. zoomError); return end
                local saved = self:SavePreparedFishingView(config, zoom, self.db.cameraSweepZoom)
                self.cameraHome.tilt, self.cameraHome.savedView = config.tilt, saved
                self.cameraHome.scanConfig = config
                if saved then self.cameraSmartStatus = string.format("Prepared preset 3; tilt %.2f", config.tilt)
                else self:ResetSmartCameraAdjustment("Preset 3 save failed; base preset 4 next scan") end
                view.smartConfig = nil
            end
            if view.savedView or self:AdvanceSweepTilt(view, now) then
                self:ReleaseFishingViewBlend()
                self.cameraCenteredReturn = nil
                self.cameraHome.x, self.cameraHome.y = 0, 0
                self.cameraHome.fingerprint = Fingerprint()
                self:OnCameraHomeRestored()
            end
        end
        return
    end
    if not self.active or not self.cameraAssistNeeded or not self.db.cameraAssist or not self.bar:IsShown() then
        self:StopCameraAssist("Fishing controls inactive")
        return
    end
    if self:CameraBobberLocated() then
        self:RefreshLocatedBobberHover()
        self.cameraScanFrame:SetScript("OnUpdate", nil)
        return
    end
    local markerHasCursor = self:CameraMarkerHasCursor()
    if self.cameraScanFailed and self.cameraInputFailureReason then return end
    if not markerHasCursor then
        if self.cameraSweepPreparation and self.cameraSweepPreparation.zooming then
            self:StopPreparationZoom()
            self.cameraSweepPreparation.zoomStarted = nil
        end
        self:StopCameraMotion()
        if self.cameraAssistBobber then self:SetCameraAssistBobber(false) end
        self:CameraState("PAUSED")
        return
    end
    if self.cameraSweepPreparation then
        self:CameraState("PREPARE_VIEW")
        self:UpdateSweepPreparation(now)
        return
    end
    if self.cameraAssistBobber then return end
    if self:CursorOnFishingBobber() then self:SetCameraAssistBobber(true); return end
    if self.cameraScanFailed then return end
    if motion then
        if not motion.startedAt then
            self:BeginCameraMotion(motion, now)
        elseif motion.path then
            self:UpdateCameraPathMotion(motion, now)
        elseif now - motion.startedAt + 0.000001 >= motion.duration
            and math.abs(motion.step.x - self.cameraHome.x) + math.abs(motion.step.y - self.cameraHome.y) < 0.005 then
            local step = motion.step
            self:StopCameraMotion()
            if step.rowEnd and self.cameraCast then self.cameraCast.rows = self.cameraCast.rows + 1 end
            self:AdvanceCameraScan()
        elseif motion.profile then
            self:UpdateCameraMotion(motion, now)
        end
    elseif self.cameraRun and self.cameraState == "PAUSED" then
        if self.cameraRun.path then self:StartCameraPath(); return end
        local step = self.cameraRun.steps[self.cameraRun.index]
        if step then
            self:CameraState(step.stage)
            if not self:StartCameraMove(step) then self:AdvanceCameraScan() end
        else self:BeginCameraScan() end
    else self:BeginCameraScan() end
end

function FF:SetCameraAssistNeeded(needed, reason)
    needed = needed == true and self.db.cameraAssist == true and self.active and self.bar and self.bar:IsShown()
    -- A soft-target update must not recenter or restart an acquired cast.
    if not needed and self:CameraBobberLocated() and self.db.cameraAssist and self.active
        and self.bar and self.bar:IsShown() then return end
    if not needed then
        if self.cameraAssistNeeded then self:StopCameraAssist("Soft bobber available") end
        return
    end
    self.cameraAssistReason = reason
    -- The existing range decision identifies this cast as needing assistance,
    -- even if the player never gets as far as acquiring its bobber.
    local catch = self.statsCast
    if catch and not catch.ended and catch.started == self.castStart then
        catch.cameraAssistAttempt = true
        local saved = self.db.pendingFishingCast
        if saved and saved.token == catch.token then saved.cameraAssistAttempt = true end
    end
    if self.cameraAssistNeeded then
        -- Reuse the active cast's range checks to prompt once if the cursor leaves.
        self:WarnRangeOnce()
        return
    end
    self.cameraAssistNeeded = true
    self:StartCameraAttemptDiagnostics(reason)
    -- The shared full-screen flyout dismiss surface captures world mouse input.
    -- Close through the UI owner before showing the marker or enabling probes.
    if self.CloseFishingFlyouts then self:CloseFishingFlyouts(true) end
    self.cameraEndSessionAfterRestore = nil
    self:EnsureCameraAssistUI()
    self.cameraMarker:Show()
    self:UpdateCameraMarkerRightClick()
    pcall(self.cameraScanFrame.RegisterEvent, self.cameraScanFrame, "WORLD_CURSOR_TOOLTIP_UPDATE")
    pcall(self.cameraScanFrame.RegisterEvent, self.cameraScanFrame, "CURSOR_CHANGED")
    local query, unavailable = WorldCursorQuery()
    if not query and unavailable == "unavailable" then
        self:RecordCameraCursorOutcome(unavailable)
        return
    end
    if self.cameraCast and self.cameraCast.inputFailed then self:FailCameraInput(self.cameraCast.inputFailed); return end
    if self.cameraState ~= "RESTORE_HOME" then self:CameraState("WAIT_CURSOR") end
    if not self:CameraBobberLocated() then self:ArmCameraTick() end
    self:ApplyBindings()
    if self.SyncCastAction then self:SyncCastAction() end
    self:WarnRangeOnce()
end

function FF:CameraCVarChanged(name)
    name = type(name) == "string" and name:lower() or ""
    self:CameraEnvironmentCVarChanged(name)
    if name == "cameraviewblendstyle" and not self.cameraOwnViewCVar and self:FishingViewBlendChanged() then
        self:InvalidateScanHome("Saved-view blend changed externally")
        return
    end
    if self.cameraHome and self.cameraHome.valid and
        (name == "camerayawmovespeed" or name == "camerapitchmovespeed" or name == "camerasmoothstyle") then
        self:InvalidateScanHome("Camera setting changed")
    end
end

function FF:CameraDevAction(action)
    if action == "statistics" then self:ResetCameraStatistics()
    elseif action == "state" or action == "path" then
        self:ShowTraceWindow(self:CameraDeveloperReport(action == "path", true), "Camera scan report", "Copy this report for testing")
    elseif action == "export" then
        self:ShowTraceWindow(self:CameraScanProfileExport(), "Fishing scan profile", "Selected profile settings • Ctrl+C to copy")
    end
end

function FF:CameraScanProfileExport()
    self:SaveCameraScanProfile()
    local id = self.db.cameraProfile or (self.db.cameraCloseScan and "close" or "standard")
    local profile = self.db.cameraScanProfiles and self.db.cameraScanProfiles[id] or CopyScanProfile(self, self.db)
    local lines = { "FOREVER FISHING SCAN PROFILE", "Profile: " .. self:CameraScanProfileName() .. " (" .. id .. ")",
        "Camera assisted fishing: " .. (self.db.cameraAssist and "On" or "Off"), "" }
    for _, group in ipairs({ self.scanTuning, self.sweepTuning, self.viewTuning, self.smartTuning }) do
        for _, option in ipairs(group) do
            lines[#lines + 1] = string.format("%s (%s): %g %s", option.label, option.key,
                tonumber(profile[option.key]) or option.default, option.unit or "")
        end
    end
    lines[#lines + 1] = string.format("Cursor marker height (cameraMarkerHeight): %g UI units",
        tonumber(profile.cameraMarkerHeight) or self.cameraMarkerDefaultHeight)
    local marker = self:CameraMarkerOption(profile.cameraMarkerStyle)
    lines[#lines + 1] = "Cursor marker style (cameraMarkerStyle): " .. marker.label .. " (" .. marker.id .. ")"
    for _, entry in ipairs({ { "Pyramid Path", "cameraPyramidPath" }, { "Rounded turns", "cameraRoundedTurns" },
        { "Racetrack turns", "cameraRacetrackTurns" }, { "Saved fishing view", "cameraSavedView" },
        { "Smart camera adjustment", "cameraSmartAdjustment" } }) do
        lines[#lines + 1] = entry[1] .. " (" .. entry[2] .. "): " .. (profile[entry[2]] and "On" or "Off")
    end
    return table.concat(lines, "\n")
end

function FF:CameraDeveloperReport(includePath, includeSettings)
    local home, stats = self.cameraHome, self.cameraStats
    if stats.medianRevision ~= stats.revision then
        local samples = {}
        for _, value in ipairs(stats.samples) do samples[#samples + 1] = value end
        stats.median = P.Median(samples) or 0
        stats.medianRevision = stats.revision
    end
    local lines = { "Forever Fishing camera scan", "State: " .. (self.cameraState or "IDLE"),
        "Scan profile: " .. self:CameraScanProfileName(),
        "Smart camera adjustment: " .. (self.db.cameraSmartAdjustment and "On; " .. (self.cameraSmartStatus or "Waiting for a bobber; base preset 4") or "Off"),
        "Deepest smart detection: " .. (self.cameraSmartTarget and string.format("%.2f degrees; starting tilt %.2f", self.cameraSmartTarget.deepestTilt, self.cameraSmartTarget.tilt) or "none"),
        string.format("Smart adjust offset: %+g lines", self.db.cameraSmartOffset),
        string.format("Smart adjust offset trigger: line %d or lower", self.db.cameraSmartTrigger),
        string.format("Smart adjust 2nd offset trigger: line %d or lower", self.db.cameraSmartSecondTrigger),
        string.format("Smart adjust 2nd offset: %+g lines", self.db.cameraSmartSecondOffset),
        "Scan path: " .. (self.db.cameraRacetrackTurns and (self.db.cameraPyramidPath and "Pyramid Path with Racetrack turns" or "Sweep with Racetrack turns")
            or (self.db.cameraPyramidPath and "Pyramid Path" or (self.db.cameraRoundedTurns and "Rounded turns (development)" or "Sweep"))),
        string.format("Cursor marker: centered; height %+.1f UI units", self.db.cameraMarkerHeight or self.cameraMarkerDefaultHeight),
        "Saved fishing view: " .. (self.db.cameraSavedView and "On" or "Off") .. "; " .. (self.cameraSavedViewStatus or "not prepared this login"),
        "Camera view: " .. (home and home.valid and home.status or (home and ("Invalid: " .. home.reason) or "Not prepared")),
        string.format("Last recenter: %.2fs", self.cameraLastReturnTime or 0),
        string.format("Zoom: requested %.1f; achieved %s", self.db.cameraSweepZoom,
            self.cameraSweepAchievedZoom and string.format("%.2f", self.cameraSweepAchievedZoom) or "not prepared"),
        string.format("Camera rate CVars: yaw %.2f; pitch %.2f; frame %.3fs", CameraSpeed("cameraYawMoveSpeed") or 0,
            CameraSpeed("cameraPitchMoveSpeed") or 0, self.cameraFrameDelta or 0),
        string.format("Last cast sampling: %d frames; %d cursor checks; %d cursor events; longest frame %.1fms; longest check gap %.1fms; estimated maximum travel/check %.2f deg; deferred refreshes %d",
            self.cameraCast and self.cameraCast.scanFrames or 0, self.cameraCast and self.cameraCast.cursorSamples or 0,
            self.cameraCast and self.cameraCast.cursorEvents or 0,
            1000 * (self.cameraCast and self.cameraCast.maxFrameDelta or 0),
            1000 * (self.cameraCast and self.cameraCast.maxCursorGap or 0),
            self.cameraCast and self.cameraCast.maxSampleTravel or 0,
            self.cameraCast and self.cameraCast.deferredRefreshes or 0),
        "Own camera tick CPU (scan logging only): " .. (self.cameraCast and self.cameraCast.maxTickCPU
            and string.format("worst %.3fms", self.cameraCast.maxTickCPU) or "not measured"),
        "World cursor query CPU (scan logging only): " .. (self.cameraCast and self.cameraCast.maxCursorCPU
            and string.format("worst %.3fms", self.cameraCast.maxCursorCPU) or "not measured"),
        home and string.format("Estimated scan offset: X %+.2f deg; Y %+.2f deg", home.x, home.y) or "Scan offset: unknown",
        self.cameraLastFound and string.format("Last found: row %d; %.2fs", self.cameraLastFound.row, self.cameraLastDetectionTime or 0) or "Last found: none",
        string.format("Casts: %d; scanned: %d; detections: %d; failures: %d; cancelled: %d", stats.casts, stats.attempts, stats.detections, stats.failures, stats.cancelled),
        string.format("Detection seconds: average %.2f; median (last 200) %.2f; worst %.2f", stats.detections > 0 and stats.timeTotal / stats.detections or 0, stats.median or 0, stats.worst),
        string.format("Average rows: %.2f; view preparations: %d", stats.finished > 0 and stats.rows / stats.finished or 0, stats.homeResets),
    }
    self:AppendCameraAttemptDiagnostics(lines)
    if self.cameraInputFailureReason then lines[#lines + 1] = "Camera input failure: " .. self.cameraInputFailureReason end
    if includePath or includeSettings then
        lines[#lines + 1] = "Settings:"
        lines[#lines + 1] = "Rounded turns: " .. (self.db.cameraRoundedTurns and "on" or "off")
        lines[#lines + 1] = "Racetrack turns: " .. (self.db.cameraRacetrackTurns and "on" or "off")
        lines[#lines + 1] = "Pyramid Path: " .. (self.db.cameraPyramidPath and string.format("on (+%.2f degrees per side per row)", self.db.cameraPyramidStep) or "off")
        for _, options in ipairs({ self.scanTuning, self.sweepTuning, self.viewTuning }) do
            for _, option in ipairs(options) do
                lines[#lines + 1] = string.format("%s: %g %s", option.label, self.db[option.key], option.unit or "")
            end
        end
    end
    if includePath then
        lines[#lines + 1] = "Planned sweep:"
        local planned = self.cameraRun and self.cameraRun.steps or P.Build(self:CameraPlanConfig())
        for index, step in ipairs(planned) do
            lines[#lines + 1] = string.format("%d. %s -> X %+.2f Y %+.2f", index, step.kind, step.x, step.y)
        end
    end
    return table.concat(lines, "\n")
end


-- On-request trace snapshots. Bounded per-login facts; never saved or polled.
local function TraceText(value)
    if not Plain(value) or type(value) ~= "string" or value == "" then return nil end
    return value:sub(1, 160):gsub("[%c]", " "):gsub("|", "/")
end
local function TraceRead(callback, ...)
    if not Plain(callback) or type(callback) ~= "function" then return nil, "API unavailable" end
    local ok, a, b, c, d = pcall(callback, ...)
    if not ok then return nil, "API error" end
    if not Plain(a) then return nil, "inaccessible" end
    return a, b, c, d
end
local function TraceIdentity(guid)
    if not Plain(guid) then return "inaccessible" end
    if guid == nil then return "none" end
    if type(guid) ~= "string" then return "invalid" end
    local id = guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    if id then return "GameObject ID " .. id:sub(1, 12), id end
    return guid:match("^GameObject%-") and "GameObject; ID unreadable" or "non-GameObject"
end
function FF:CameraTraceTooltipName(data)
    local lines = rawget(data, "lines")
    if not Plain(lines) then return nil, "inaccessible lines" end
    if lines == nil then return nil, "no lines" end
    if type(lines) ~= "table" then return nil, "invalid lines" end
    local first = rawget(lines, 1)
    if not Plain(first) then return nil, "inaccessible first line" end
    if first == nil then return nil, "no first line" end
    if type(first) ~= "table" then return nil, "invalid first line" end
    local name = rawget(first, "leftText")
    if not Plain(name) then return nil, "inaccessible title" end
    if name == nil then return nil, "no title" end
    if type(name) ~= "string" then return nil, "invalid title" end
    return name, "readable"
end
function FF:CameraTraceNameRoute(name)
    if not Plain(name) or type(name) ~= "string" then return "no readable name" end
    return self.cameraBobberNames and self.cameraBobberNames[name:lower()]
        and "verified localized name" or "English name fallback"
end
function FF:CameraTraceContext(scanning)
    local db, home = self.db, scanning and self.cameraHome
    local config = home and home.scanConfig
    local context = { profile = TraceText(self:CameraScanProfileName()), speed = home and home.speed or db.cameraScanSpeed,
        width = config and config.reach or db.cameraSweepReach,
        spacing = config and config.spacing or db.cameraSweepSpacing, rows = config and config.down or db.cameraSweepRows,
        zoom = db.cameraSweepZoom, tilt = db.cameraSweepTilt, start = db.cameraSweepStart,
        pyramid = config and config.pyramid or db.cameraPyramidPath,
        widening = config and config.pyramidStep or db.cameraPyramidStep,
        rounded = config and config.rounded or db.cameraRoundedTurns,
        racetrack = config and config.racetrack or db.cameraRacetrackTurns,
        savedView = db.cameraSavedView, preset = db.cameraViewSlot, smart = db.cameraSmartAdjustment,
        smartStatus = TraceText(self.cameraSmartStatus), markerHeight = db.cameraMarkerHeight,
        actualTilt = config and config.tilt, actualStart = config and config.start,
        achievedZoom = scanning and self.cameraSweepAchievedZoom,
        remaining = self.castEnd and math.max(0, self.castEnd - GetTime()),
        location = self.statsCast and TraceText(self.statsCast.location) }
    if config then
        context.pyramid, context.widening = config.pyramid, config.pyramidStep
        context.rounded, context.racetrack = config.rounded, config.racetrack
    end
    return context
end
function FF:RecordNativeBobberReference(guid)
    local identity, id = TraceIdentity(guid)
    if id ~= "35591" then return end
    self.cameraNativeReferenceCast = self.channelStartSerial
    self.cameraNativeBobberReference = { castID = self.channelStartSerial, at = GetTime(),
        identity = identity, context = self:CameraTraceContext(), route = "standard object ID (native soft target)" }
end
function FF:RecordCameraTraceObject(guid, tooltipType, name, route)
    local record = self.cameraAttemptDiagnostics
    if not record or not self.active or not self.cameraAssistNeeded or self:CameraBobberLocated() then return end
    -- Reuse one small object record, including the standard-ID fast path.
    local object = record.lastObject
    object.identity = TraceIdentity(guid)
    object.tooltipType, object.name = SafeNumber(tooltipType), TraceText(name)
    object.route, object.at = route, GetTime()
end
local function TraceContextLine(context)
    local function number(value) return SafeNumber(value) and string.format("%g", value) or "unavailable" end
    return string.format("%s; speed %sx; width %s; spacing %s; rows %s; zoom %s; tilt %s; start %s; channel remaining %ss",
        context.profile or "unknown", number(context.speed), number(context.width), number(context.spacing),
        number(context.rows), number(context.zoom), number(context.tilt), number(context.start), number(context.remaining))
end
function FF:AppendCameraTraceAttempt(lines, record)
    if not record.context then return end
    lines[#lines + 1] = "  Settings at assisted entry: " .. TraceContextLine(record.context)
    local context = record.scanContext or record.context
    lines[#lines + 1] = string.format("  Entry view: saved %s; preset %s; smart %s; marker height %s; location %s",
        context.savedView and "on" or "off", tostring(context.preset or "unavailable"),
        context.smart and "on" or "off", tostring(context.markerHeight or "default"), context.location or "unavailable")
    lines[#lines + 1] = string.format("  Path at entry: pyramid %s; widening %s; rounded %s; racetrack %s",
        context.pyramid and "on" or "off", tostring(context.widening or "unavailable"),
        context.rounded and "on" or "off", context.racetrack and "on" or "off")
    if record.scanContext then
        lines[#lines + 1] = "  Settings at scan start: " .. TraceContextLine(context)
        lines[#lines + 1] = string.format("  Prepared view: achieved zoom %s; planned tilt %s; planned start %s; %s",
            tostring(context.achievedZoom or "unavailable"), tostring(context.actualTilt or "unavailable"),
            tostring(context.actualStart or "unavailable"), context.smartStatus or "no smart adjustment recorded")
    end
    local conclusion = record.outcome == "found" and "bobber identified; catch not established"
        or (record.exhausted and "scan path exhausted without detection")
        or (record.outcome == "cancelled" and "search cancelled; see reason/end event")
        or (record.reason and record.reason:find("input", 1, true) and "input fault; see reason")
        or (record.endedAt and not record.scanContext and "ended before scan started")
        or (record.endedAt and "ended before path completed; see reason/end event") or "attempt still open"
    lines[#lines + 1] = "  Interpretation: " .. conclusion
    lines[#lines + 1] = string.format("  This attempt: completed steps %d; longest frame %.1fms; longest check gap %.1fms; maximum travel/check %.2f deg",
        record.completedSteps or 0, 1000 * (record.maxFrameDelta or 0), 1000 * (record.maxCursorGap or 0), record.maxSampleTravel or 0)
    local object = record.lastObject
    if object and object.at then
        lines[#lines + 1] = string.format("  Last readable object: %s; tooltip type %s; name %s; route %s; %.2fs after entry",
            object.identity, tostring(object.tooltipType or "unavailable"), object.name or "unavailable",
            object.route, math.max(0, object.at - record.startedAt))
    else lines[#lines + 1] = "  Last readable object: none in this attempt" end
end
function FF:FishingTraceEnvironment()
    local metadata = GetAddOnMetadata
    if Plain(C_AddOns) and type(C_AddOns) == "table" then metadata = rawget(C_AddOns, "GetAddOnMetadata") or metadata end
    local version = TraceText(TraceRead(metadata, "ForeverFishing", "Version")) or "unavailable"
    local client, build, date, interface = TraceRead(GetBuildInfo)
    local width, height = TraceRead(GetPhysicalScreenSize)
    local scale = TraceRead(function() return UIParent and UIParent:GetEffectiveScale() end)
    local fps = TraceRead(GetFramerate)
    local locale = TraceText(TraceRead(GetLocale)) or "unavailable"
    local window = TraceText(TraceRead(GetCVar, "gxWindow")) or "unavailable"
    local zone = TraceText(TraceRead(GetRealZoneText)) or TraceText(TraceRead(GetZoneText)) or "unavailable"
    local sub = TraceText(TraceRead(GetSubZoneText)) or "none"
    return string.format("Addon: %s; client %s; build %s; interface %s; locale %s\nDisplay now: %sx%s physical pixels; UI scale %s; FPS %s; gxWindow %s\nLocation now: %s; subzone %s",
        version, TraceText(client) or "unavailable", TraceText(build) or (SafeNumber(build) and tostring(build)) or "unavailable",
        SafeNumber(interface) and tostring(interface) or "unavailable", locale,
        SafeNumber(width) and tostring(width) or "unavailable", SafeNumber(height) and tostring(height) or "unavailable",
        SafeNumber(scale) and string.format("%.3f", scale) or "unavailable",
        SafeNumber(fps) and string.format("%.1f", fps) or "unavailable", window, zone, sub)
end
function FF:ReadDiagnosticCursorSample()
    local query, fault = WorldCursorQuery()
    local data, queryFault = TraceRead(query)
    local cursor = {}
    cursor.state = fault or queryFault
    if not cursor.state then
        if data == nil then cursor.state = "empty"
        elseif type(data) ~= "table" then cursor.state = "invalid payload"
        else
            local objectGUID, tooltipType = rawget(data, "guid"), rawget(data, "type")
            cursor.identity, cursor.id = TraceIdentity(objectGUID)
            local rawName, nameStatus = self:CameraTraceTooltipName(data)
            cursor.tooltipType, cursor.name = SafeNumber(tooltipType), TraceText(rawName)
            cursor.nameStatus = nameStatus
            local objectType = 4
            if Plain(Enum) and type(Enum) == "table" then
                local types = rawget(Enum, "TooltipDataType")
                if Plain(types) and type(types) == "table" then objectType = SafeNumber(rawget(types, "Object")) or 4 end
            end
            local nonObject = cursor.identity == "non-GameObject"
            cursor.route = cursor.id == "35591" and "standard object ID"
                or (not nonObject and cursor.tooltipType == objectType and self:IsFishingBobberName(rawName)
                    and self:CameraTraceNameRoute(rawName)) or "not a recognized bobber"
            cursor.state = cursor.route ~= "not a recognized bobber" and "bobber" or "unverified tooltip"
        end
    end
    return cursor
end
function FF:CaptureFishingTraceSnapshot()
    local guid, guidFault = TraceRead(UnitGUID, "softinteract")
    local name = TraceText(TraceRead(UnitName, "softinteract"))
    local identity, id = TraceIdentity(guid)
    local soft = { identity = identity, name = name,
        state = (guidFault == "API error" or guidFault == "API unavailable" or guidFault == "inaccessible")
            and "unavailable" or (id == "35591" and "bobber" or (guid == nil and "missing" or "unverified target")) }
    if id ~= "35591" and soft.state ~= "unavailable" and identity ~= "non-GameObject" and self:IsFishingBobberName(name, true) then
        soft.state = "bobber name fallback"
    end
    if not self.active then soft.state = "idle (snapshot only)" end
    -- This report-only sample must not acquire, learn aliases, settle readiness,
    -- increment scan counters, move the camera or mark a catch/onboarding fact.
    local sample = { at = GetTime(), soft = soft, castID = self.channelStartSerial,
        active = self.active, context = self:CameraTraceContext(), cursor = {},
        viewZoom = SafeNumber(TraceRead(GetCameraZoom)) }
    local cursor = self:ReadDiagnosticCursorSample()
    sample.cursor = cursor
    if sample.active and cursor.state == "bobber" and cursor.id == "35591" then
        -- One explicit hover reference, replaced only by another verified hover.
        self.cameraTraceHoverReference = sample
    end
    return sample
end
local function TraceMarkerCursor(self)
    if not self.cameraMarker or self.cameraMarkerDrag then return nil end
    local x, y = self:ReadCameraCursor(true)
    local cx, cy = TraceRead(function() return self.cameraMarker:GetCenter() end)
    local scale = TraceRead(function() return self.cameraMarker:GetEffectiveScale() end)
    cx, cy, scale = SafeNumber(cx), SafeNumber(cy), SafeNumber(scale)
    if not x or not y or not cx or not cy or not scale or scale <= 0 then return nil end
    local half = MARKER_HIT_HALF_SIZE * scale
    return math.abs(x - cx * scale) <= half and math.abs(y - cy * scale) <= half,
        x, y, cx * scale, cy * scale, half
end
function FF:AppendFishingTraceSnapshot(lines, sample)
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Report-only comparison (read before trace window opens):"
    local cursor = sample.cursor
    lines[#lines + 1] = string.format("Cursor now: %s; %s; tooltip type %s; name %s; route %s",
        cursor.state, cursor.identity or "no readable identity", tostring(cursor.tooltipType or "unavailable"),
        cursor.name or "unavailable", cursor.route or "unavailable")
    if cursor.nameStatus then lines[#lines + 1] = "Cursor title payload: " .. cursor.nameStatus end
    lines[#lines + 1] = "Soft target now: " .. sample.soft.identity .. "; " .. (sample.soft.name or "name unavailable")
    lines[#lines + 1] = "Actual camera zoom now: " .. tostring(sample.viewZoom or "unavailable") .. "; angle not measured"
    local inside, x, y, cx, cy, half = TraceMarkerCursor(self)
    local combat = TraceRead(InCombatLockdown)
    lines[#lines + 1] = "Cursor/marker now: " .. (inside == nil and "unavailable/dragging" or (inside and "inside" or "outside"))
        .. "; combat " .. (combat == nil and "unavailable" or (combat and "yes" or "no"))
    if x then
        lines[#lines + 1] = string.format("Cursor/marker geometry now: pointer %.1f/%.1f px; centre %.1f/%.1f px; hit half-size %.1f px",
            x, y, cx, cy, half)
    end
    local aliases = {}
    for name in pairs(self.cameraBobberNames or {}) do aliases[#aliases + 1] = TraceText(name) or "unavailable" end
    table.sort(aliases)
    lines[#lines + 1] = "Verified name aliases this login: " .. (#aliases > 0 and table.concat(aliases, "; ") or "none")
    local reference = self.cameraNativeBobberReference
    lines[#lines + 1] = reference and string.format("Native close-cast reference: cast %s; %.1fs ago; %s; %s",
        tostring(reference.castID or "unknown"), math.max(0, GetTime() - reference.at), reference.identity, reference.route)
        or "Native close-cast reference: none this login"
    if reference then
        lines[#lines + 1] = "  Reference settings: " .. TraceContextLine(reference.context)
        lines[#lines + 1] = "  Reference location: " .. (reference.context.location or "unavailable")
    end
    reference = self.cameraTraceHoverReference
    if reference then
        lines[#lines + 1] = string.format("Verified manual hover reference: cast %s; %.1fs ago; %s; type %s; name %s",
            tostring(reference.castID or "unknown"), math.max(0, GetTime() - reference.at), reference.cursor.identity,
            tostring(reference.cursor.tooltipType or "unavailable"), reference.cursor.name or "unavailable")
        lines[#lines + 1] = "  Hover settings: " .. TraceContextLine(reference.context)
        lines[#lines + 1] = "  Hover actual zoom: " .. tostring(reference.viewZoom or "unavailable")
            .. "; location " .. (reference.context.location or "unavailable")
    else lines[#lines + 1] = "Verified manual hover reference: none this login" end
    lines[#lines + 1] = "References identify client-exposed bobbers, not ownership, distance, bite or catch. Report-time FPS/location are not past-cast measurements."
end

