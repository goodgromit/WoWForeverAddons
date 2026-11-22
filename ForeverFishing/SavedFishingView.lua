-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local BLEND_CVAR = "cameraViewBlendStyle"
FF.viewTuning = {
    { key = "cameraViewSlot", label = "Saved view preset", min = 2, max = 4, step = 1, default = 4, unit = "preset",
        note = "Replaces this camera preset when a fishing view is prepared. Smart camera adjustment uses presets 4 and 3 instead. Preset 5 is left for Forever Ruler." },
    { key = "cameraViewDelay", label = "View settle delay", min = 0.2, max = 2, step = 0.05, default = 0.4, unit = "s",
        note = "Wait before scanning after a saved view is loaded. Increase if the view is still moving when scanning starts. The client has no transition-complete event." },
}
FF.smartTuning = {
    { key = "cameraSmartOffset", label = "Smart adjust offset", min = -24, max = 24, step = 0.25, default = -2.5, unit = "lines",
        note = "Offset from the deepest bobber position found in 0.25-line steps. Negative values start above it to leave room for longer casts. Uses preset 3; moving resets to preset 4." },
    { key = "cameraSmartTrigger", label = "Smart adjust offset trigger", min = 0, max = 24, step = 1, default = 0, unit = "lines",
        note = "The first scan line that can activate the regular Smart adjust offset. The second offset trigger takes priority when both are reached. Line zero is the first scan line." },
    { key = "cameraSmartSecondTrigger", label = "Smart adjust 2nd offset trigger", min = 0, max = 24, step = 1, default = 7, unit = "lines",
        note = "On the first bobber find after Smart camera adjustment resets, use the second offset if the bobber is found on this line or lower. Line zero is the first scan line." },
    { key = "cameraSmartSecondOffset", label = "Smart adjust 2nd offset", min = -24, max = 24, step = 0.25, default = -4.5, unit = "lines",
        note = "Used when the first bobber find reaches the trigger line. Stays active until Smart camera adjustment resets." },
}

-- Camera context is sampled at lifecycle boundaries, without per-frame polling.
local ENVIRONMENT_CVARS = { "cameraFov", "test_cameraOverShoulder",
    "test_cameraTargetFocusInteractEnable", "test_cameraTargetFocusInteractStrengthPitch",
    "test_cameraTargetFocusInteractStrengthYaw", "test_cameraHeadMovementStrength",
    "CameraKeepCharacterCentered", "CameraReduceUnexpectedMovement" }
local ENVIRONMENT_KEYS = {}
for _, key in ipairs(ENVIRONMENT_CVARS) do ENVIRONMENT_KEYS[key:lower()] = key end
local function EnvironmentNumber(value)
    if issecretvalue and issecretvalue(value) then return nil end
    if type(value) ~= "string" and type(value) ~= "number" then return nil end
    local number = tonumber(value)
    if not number or number ~= number or math.abs(number) == math.huge then return nil end
    return number
end
local function EnvironmentValue(key)
    if type(GetCVar) == "function" then
        local ok, value = pcall(function() return EnvironmentNumber(GetCVar(key)) end)
        if ok and value ~= nil then return value end
    end
    if not (issecretvalue and issecretvalue(C_CVar)) and type(C_CVar) == "table" then
        local getter = rawget(C_CVar, "GetCVar")
        if type(getter) == "function" then
            local ok, value = pcall(function() return EnvironmentNumber(getter(key)) end)
            if ok then return value end
        end
    end
end
local function ValidEnvironment(environment)
    return not (issecretvalue and issecretvalue(environment)) and type(environment) == "table"
        and EnvironmentNumber(rawget(environment, "version")) == 1
end
local function ViewEnvironment(view)
    if not (issecretvalue and issecretvalue(view)) and type(view) == "table" then return rawget(view, "environment") end
end
function FF:ReadCameraEnvironment()
    local environment = { version = 1 }
    for _, key in ipairs(ENVIRONMENT_CVARS) do environment[key] = EnvironmentValue(key) end
    return environment
end
function FF:ReadFishingFOV()
    return EnvironmentValue("cameraFov")
end
function FF:WriteFishingFOV(value)
    local setter = type(SetCVar) == "function" and SetCVar
    if not setter and not (issecretvalue and issecretvalue(C_CVar)) and type(C_CVar) == "table" then
        setter = rawget(C_CVar, "SetCVar")
    end
    if type(setter) ~= "function" then return false end
    return pcall(setter, "cameraFov", tostring(value))
end
function FF:CameraEnvironmentDifference(a, b)
    if not ValidEnvironment(a) or not ValidEnvironment(b) then return nil end
    for _, key in ipairs(ENVIRONMENT_CVARS) do
        local old, new = EnvironmentNumber(rawget(a, key)), EnvironmentNumber(rawget(b, key))
        -- Unavailable values are unverified, not evidence of an external change.
        if old and new and math.abs(old - new) > 0.0001 then return key, old, new end
    end
end
function FF:CameraEnvironmentMatches(a, b)
    return ValidEnvironment(a) and ValidEnvironment(b) and not self:CameraEnvironmentDifference(a, b)
end
function FF:CameraEnvironmentChanged(key, old, new, boundary)
    local reason = "Camera environment changed: " .. key
    self:ResetSmartCameraAdjustment(reason .. "; base preset 4 next scan", true)
    self:InvalidateSavedFishingView(reason .. "; rebuilding next scan")
    if self.cameraSweepPreparation or self.cameraCenteredReturn or (self.cameraHome and self.cameraHome.valid) then
        local searching = self.cameraAssistNeeded and not self:CameraBobberLocated()
        self:InvalidateScanHome(reason)
        if searching then self.cameraEnvironmentCancelled = true; self.cameraScanFailed = true end
        if self.cameraScanFrame then self.cameraScanFrame:SetScript("OnUpdate", nil) end
        if self.UpdateCameraAssistStatus then self:UpdateCameraAssistStatus() end
        if self.UpdateRangeNotice then self:UpdateRangeNotice() end
    end
    self:TraceTransition(reason .. " (" .. tostring(old) .. " -> " .. tostring(new) .. "; " .. boundary .. ")")
end
function FF:CheckCameraEnvironment(boundary)
    local current = self:ReadCameraEnvironment()
    local previous = self.cameraEnvironment or ViewEnvironment(self.cameraFishingView)
        or ViewEnvironment(self.db.cameraFishingView) or ViewEnvironment(self.db.cameraSmartBaseView)
    local key, old, new = self:CameraEnvironmentDifference(previous, current)
    if not key then key, old, new = self:CameraEnvironmentDifference(ViewEnvironment(self.cameraFishingView), current) end
    if not key then key, old, new = self:CameraEnvironmentDifference(ViewEnvironment(self.db.cameraFishingView), current) end
    if not key then key, old, new = self:CameraEnvironmentDifference(ViewEnvironment(self.db.cameraSmartBaseView), current) end
    self.cameraEnvironment = current
    if key then self:CameraEnvironmentChanged(key, old, new, boundary); return false end
    return true
end
function FF:CameraEnvironmentCVarChanged(name)
    local key = ENVIRONMENT_KEYS[name]
    if not key or not self.db then return end
    if key == "cameraFov" then
        if self.cameraOwnFOV then return end
        if self.RelinquishFishingFOV then self:RelinquishFishingFOV() end
    end
    -- Once relinquished, foreign animations need no repeated reads/cleanup.
    if not (self.cameraSmartTarget or self.cameraFishingView or self.db.cameraFishingView
        or self.cameraSmartBaseView or self.db.cameraSmartBaseView or self.cameraSweepPreparation
        or self.cameraCenteredReturn or (self.cameraHome and self.cameraHome.valid)) then return end
    local previous = self.cameraEnvironment or ViewEnvironment(self.cameraFishingView)
        or ViewEnvironment(self.db.cameraFishingView) or ViewEnvironment(self.db.cameraSmartBaseView)
    if not ValidEnvironment(previous) then return end
    local value = EnvironmentValue(key)
    if value == nil then return end
    local current = { version = 1 }
    for _, field in ipairs(ENVIRONMENT_CVARS) do current[field] = EnvironmentNumber(rawget(previous, field)) end
    local old = current[key]
    if not old then
        -- A briefly unreadable boundary must not erase retained evidence.
        local retained = ViewEnvironment(self.cameraFishingView) or ViewEnvironment(self.db.cameraFishingView)
            or ViewEnvironment(self.db.cameraSmartBaseView)
        if ValidEnvironment(retained) then old = EnvironmentNumber(rawget(retained, key)) end
    end
    current[key], self.cameraEnvironment = value, current
    if old and math.abs(old - value) > 0.0001 then self:CameraEnvironmentChanged(key, old, value, "CVar event") end
end

function FF:InitializeSmartCameraSettings()
    if self.db.cameraSmartAdjustment == nil then self.db.cameraSmartAdjustment = true end
    self.db.cameraSmartAdjustment = self.db.cameraSmartAdjustment == true
    for _, option in ipairs(self.smartTuning) do
        local value = tonumber(self.db[option.key])
        if not value or value ~= value then value = option.default end
        self.db[option.key] = math.floor(math.max(option.min, math.min(option.max, value)) / option.step + 0.5) * option.step
    end
end

function FF:ResetSmartCameraAdjustment(reason, clearBase)
    self.cameraSmartTarget = nil
    self.cameraSmartStatus = reason or "Waiting for a bobber; base preset 4"
    if clearBase then
        self.cameraSmartBaseView = nil
        self.db.cameraSmartBaseView = nil
    end
end

function FF:SetSmartCameraAdjustment(enabled)
    enabled = enabled == true
    if self.db.cameraSmartAdjustment == enabled then return end
    if InCombatLockdown() then self:Print("Change smart camera adjustment after combat."); return end
    self:EndCameraMarkerDrag(false)
    self:InvalidateScanHome("Smart camera adjustment changed")
    self:StopCameraAssist("Smart camera adjustment changed", true)
    self.cameraHome = nil
    self.db.cameraSmartAdjustment = enabled
    self:ResetSmartCameraAdjustment(enabled and "Waiting for a bobber; base preset 4" or "Off")
    self:SaveCameraScanProfile()
    if self.settingsPanel then self:RefreshFishingModeSetting() end
    if self.scanDevPanel then self.scanDevPanel:RefreshControls() end
    if self.active and self.UpdateBobberStatus then self:UpdateBobberStatus() end
    self:RefreshUI()
end

local function SmartContextMatches(a, b)
    return a.baseTilt == b.baseTilt and a.spacing == b.spacing and a.start == b.start
        and a.offset == b.offset and a.trigger == b.trigger and a.secondTrigger == b.secondTrigger
        and a.secondOffset == b.secondOffset and a.markerHeight == b.markerHeight and a.zoom == b.zoom
        and a.close == b.close and FF:CameraEnvironmentMatches(a.environment, b.environment)
end

function FF:ApplySmartCameraTilt(config)
    config.baseTilt = config.tilt
    config.smartContext = { baseTilt = config.tilt, spacing = config.spacing, start = config.start,
        offset = self.db.cameraSmartOffset, trigger = self.db.cameraSmartTrigger,
        secondTrigger = self.db.cameraSmartSecondTrigger,
        secondOffset = self.db.cameraSmartSecondOffset, markerHeight = self.db.cameraMarkerHeight,
        zoom = self.db.cameraSweepZoom, close = self.db.cameraCloseScan, environment = self.cameraEnvironment }
    if not self.db.cameraSmartAdjustment or config.rounded or not self.db.cameraSavedView then return end
    local target = self.cameraSmartTarget
    if target and not SmartContextMatches(target.context, config.smartContext) then
        self:ResetSmartCameraAdjustment("Settings changed; base preset 4")
        target = nil
    end
    if target then config.tilt, config.smart = target.tilt, true end
end

function FF:LearnSmartCameraTilt()
    if not self:CheckCameraEnvironment("bobber acquisition") then return end
    local home = self.cameraHome
    local config = home and home.scanConfig
    if not self.db.cameraSmartAdjustment or not self.db.cameraSavedView or not self.cameraScanStarted
        or not home or not home.valid or not config or config.rounded or not config.smartContext then return end
    local current = self:CameraPlanConfig()
    if not SmartContextMatches(config.smartContext, current.smartContext) then return end
    -- The first pass is row zero. Estimate the nearest reached row rather than
    -- taking the destination row of a still-incomplete vertical movement.
    local row = math.max(0, math.floor((home.y - config.start) / config.spacing + 0.5))
    -- Compare absolute angles: each scan may already start from learned preset
    -- 3. Keep the deepest detection separately so shallower catches cannot undo
    -- it, and the offset is applied once rather than accumulated between casts.
    local detectedTilt = home.tilt + config.start + row * config.spacing
    local target = self.cameraSmartTarget
    if not target and row < config.smartContext.trigger and row < config.smartContext.secondTrigger then
        self.cameraSmartStatus = string.format("Bobber found on line %d; waiting for Smart adjust trigger", row)
        return
    end
    if target and SmartContextMatches(target.context, config.smartContext)
        and detectedTilt <= target.deepestTilt + 0.001 then
        self.cameraSmartStatus = string.format("Keeping deepest bobber %.2f; starting tilt %.2f", target.deepestTilt, target.tilt)
        return
    end
    -- Keep the first find's offset choice for this location. Switching to the
    -- primary offset on a later find can pull preset 3 farther down than intended.
    local second
    if target then
        second = target.second == true
    else
        second = row >= config.smartContext.secondTrigger
    end
    local offset = second and config.smartContext.secondOffset or config.smartContext.offset
    local adjusted = row + offset
    local tilt = math.max(config.baseTilt, math.min(80, detectedTilt + offset * config.spacing))
    if target then tilt = math.max(target.tilt, tilt) end
    self.cameraSmartTarget = { tilt = tilt, deepestTilt = detectedTilt, row = row, adjusted = adjusted,
        offsetUsed = offset, second = second, context = config.smartContext }
    self.cameraSmartStatus = string.format("Deepest bobber %.2f; offset %+g lines%s; starting tilt %.2f; preset 3 after this cast",
        detectedTilt, offset, second and " (2nd)" or "", tilt)
    self:TraceTransition("smart camera: " .. self.cameraSmartStatus)
end

function FF:FishingViewSlot(config)
    if self.db.cameraSmartAdjustment and not config.rounded then return config.smart and 3 or 4 end
    return self.db.cameraViewSlot
end

function FF:InitializeSavedFishingViewSettings()
    if self.cameraLegacySavedView == nil then
        self.cameraLegacySavedView = self.db.cameraSavedView == true
            and type(self.db.cameraViewSlot) == "number" and type(self.db.cameraViewDelay) == "number"
    end
    if self.db.cameraSavedView == nil then self.db.cameraSavedView = true end
    self.db.cameraSavedView = self.db.cameraSavedView == true
    for _, option in ipairs(self.viewTuning) do
        local value = tonumber(self.db[option.key]) or option.default
        if value ~= value then value = option.default end
        value = math.max(option.min, math.min(option.max, value))
        self.db[option.key] = math.floor(value / option.step + 0.5) * option.step
    end
end

function FF:ReleaseFishingViewBlend()
    if not self.db or not self.db.cameraViewBlendRestore then return end
    self.cameraOwnViewCVar = true
    self:RestoreCVars("cameraViewBlendRestore")
    self.cameraOwnViewCVar = nil
end

function FF:InvalidateSavedFishingView(reason)
    self:ReleaseFishingViewBlend()
    self.cameraFishingView = nil
    self.db.cameraFishingView = nil
    self.cameraSavedViewStatus = reason or "Needs preparation"
end

function FF:ResetSavedFishingViewSettings()
    self.db.cameraSavedView = true
    for _, option in ipairs(self.viewTuning) do self.db[option.key] = option.default end
    self:InvalidateSavedFishingView("Settings reset")
    self.db.cameraSmartAdjustment = true
    for _, option in ipairs(self.smartTuning) do self.db[option.key] = option.default end
    self:ResetSmartCameraAdjustment("Settings reset", true)
end

local function Number(value)
    if issecretvalue and issecretvalue(value) then return nil end
    local number = tonumber(value)
    if not number or number ~= number or math.abs(number) == math.huge then return nil end
    return number
end

local function ReadPreset(slot)
    local suffix = string.char(64 + slot) -- Forever uses A-E for presets 1-5.
    local values = {}
    for _, part in ipairs({ "Pitch", "Yaw", "Distance" }) do
        local name = "camera" .. part .. suffix
        if type(GetCVar) == "function" then
            local ok, value = pcall(function() return Number(GetCVar(name)) end)
            values[part] = ok and value or nil
        end
        if not values[part] and C_CVar and type(C_CVar.GetCVar) == "function" then
            local ok, value = pcall(function() return Number(C_CVar.GetCVar(name)) end)
            values[part] = ok and value or nil
        end
        if not values[part] then return nil end
    end
    if math.abs(values.Pitch) > 90 or values.Distance <= 0 then return nil end
    return { pitch = values.Pitch, yaw = values.Yaw, distance = values.Distance }
end

local function ValidPreset(preset)
    if type(preset) ~= "table" then return false end
    local pitch, yaw, distance = Number(preset.pitch), Number(preset.yaw), Number(preset.distance)
    return pitch and math.abs(pitch) <= 90 and yaw and distance and distance > 0 or false
end

local function SamePreset(a, b)
    if not ValidPreset(a) or not ValidPreset(b) then return false end
    local turn = math.abs(Number(a.yaw) - Number(b.yaw)) % 360
    return math.abs(Number(a.pitch) - Number(b.pitch)) < 0.02 and math.min(turn, 360 - turn) < 0.02
        and math.abs(Number(a.distance) - Number(b.distance)) < 0.02
end

local function PresetChanged(view)
    local current = ReadPreset(view.slot)
    -- Forever can retain native views while hiding all three preset CVars.
    -- Compare readable signatures; absent values do not mean the view was lost.
    return view.preset ~= nil and current ~= nil and not SamePreset(view.preset, current)
end

-- Explicit guided diagnostics only. This shares the owner's signature rules
-- without restoring records, loading/saving views or changing camera state.
function FF:ReadFishingPresetSignature(slot, retained)
    slot = Number(slot)
    if not slot or slot < 2 or slot > 4 or slot ~= math.floor(slot) then return nil, "invalid slot (unverified)" end
    local current = ReadPreset(slot)
    if not current then return nil, "unavailable/invalid (unverified)" end
    if not ValidPreset(retained) then return current, "readable; no retained signature (unverified)" end
    return current, SamePreset(retained, current) and "matches retained signature" or "differs from retained signature"
end

local function ValidViewRecord(record)
    if type(record) ~= "table" or (record.version ~= 1 and record.version ~= 2) then return false end
    local slot, tilt, zoom, requestedZoom = Number(record.slot), Number(record.tilt), Number(record.zoom), Number(record.requestedZoom)
    return slot and slot >= 2 and slot <= 4 and slot == math.floor(slot) and tilt and math.abs(tilt) <= 80
        and zoom and zoom > 0 and requestedZoom and requestedZoom >= 1 and requestedZoom <= 40
        and (record.version ~= 1 or ValidPreset(record.preset))
        and (record.version ~= 2 or record.nativeSaved == true)
        and (record.preset == nil or ValidPreset(record.preset)) and not PresetChanged(record)
        and FF:CameraEnvironmentMatches(record.environment, FF.cameraEnvironment) or false
end

function FF:RestoreSavedFishingViewRecord()
    if self.cameraSavedViewRestored then return end
    if not self.cameraEnvironment then self:CheckCameraEnvironment("retained view check") end
    self.cameraSavedViewRestored = true
    local record = self.db.cameraFishingView
    if type(record) ~= "table" or (record.version ~= 1 and record.version ~= 2) then self.db.cameraFishingView = nil; return end
    if not ValidViewRecord(record) then
        self.db.cameraFishingView = nil
        self.cameraSavedViewStatus = "Saved preset changed or unavailable; needs preparation"
        return
    end
    self.cameraFishingView = record
    self.cameraSavedViewStatus = "Retained preset " .. record.slot
        .. (ReadPreset(record.slot) and "" or "; native angle unavailable")
end

function FF:CameraSmartBaseView(config)
    local base = self.cameraSmartBaseView or self.db.cameraSmartBaseView
    if not ValidViewRecord(base) or base.slot ~= 4 or base.tilt ~= config.baseTilt
        or base.requestedZoom ~= self.db.cameraSweepZoom then return nil end
    self.cameraSmartBaseView = base
    return base
end

function FF:SmartFishingViewReference(config)
    if not config.smart or not self.db.cameraSmartAdjustment then return nil end
    self:RestoreSavedFishingViewRecord()
    local view = self.cameraFishingView
    if not ValidViewRecord(view) or (view.slot ~= 3 and view.slot ~= 4)
        or view.requestedZoom ~= self.db.cameraSweepZoom then view = self:CameraSmartBaseView(config) end
    if not view then return nil end
    self.cameraFishingView, self.db.cameraFishingView = view, view
    return view
end

function FF:SmartCameraReturnConfig(home)
    if self.cameraEndSessionAfterRestore or self.cameraScanFailed or not self.cameraSmartTarget
        or not home or not ValidViewRecord(home.savedView) then return nil end
    local config = self:CameraPlanConfig()
    if not config.smart or (home.savedView.slot == 3 and home.tilt == config.tilt) then return nil end
    return config
end

function FF:MigratePreviousFishingView()
    -- The previous test saved the native preset but no ownership record. Adopt
    -- its centered, readable preset once for existing test profiles only.
    if self.db.cameraSavedViewRecordVersion then return end
    self.db.cameraSavedViewRecordVersion = 1
    if not self.cameraLegacySavedView or self.db.cameraFishingView then return end
    local preset = ReadPreset(self.db.cameraViewSlot)
    if not preset then return end
    local yaw = math.abs((preset.yaw + 180) % 360 - 180)
    if yaw > 1 or preset.distance > self.db.cameraSweepZoom + 0.5 then return end
    self.db.cameraFishingView = { version = 1, slot = self.db.cameraViewSlot, tilt = self.db.cameraSweepTilt,
        requestedZoom = self.db.cameraSweepZoom, zoom = preset.distance, preset = preset }
    self.cameraSavedViewStatus = "Retained previous fishing preset " .. self.db.cameraViewSlot
end

function FF:ReusableFishingView(config)
    if not self.db.cameraSavedView or config.rounded then return nil end
    self:MigratePreviousFishingView()
    self:RestoreSavedFishingViewRecord()
    local view = self.cameraFishingView
    local slot = self:FishingViewSlot(config)
    if slot == 4 and (not view or view.slot ~= 4 or view.tilt ~= config.tilt) then
        local base = self:CameraSmartBaseView(config)
        if base then view = base; self.cameraFishingView, self.db.cameraFishingView = base, base end
    end
    if not view then return nil end
    if view.slot ~= slot or view.tilt ~= config.tilt
        or view.requestedZoom ~= self.db.cameraSweepZoom then return nil end
    if PresetChanged(view) then
        self:InvalidateSavedFishingView("Fishing preset changed; rebuilding")
        return nil
    end
    if self.db.cameraSmartAdjustment and slot == 4 then
        self.cameraSmartBaseView, self.db.cameraSmartBaseView = view, view
    end
    return view
end

function FF:SavePreparedFishingView(config, zoom, requestedZoom)
    if not self:CheckCameraEnvironment("preset save") then return nil end
    if not self.db.cameraSavedView then self.cameraSavedViewStatus = "Off"; return nil end
    if config.rounded then self.cameraSavedViewStatus = "Rounded development path uses existing preparation"; return nil end
    if type(SaveView) ~= "function" or type(SetView) ~= "function" then
        self.cameraSavedViewStatus = "Saved-view controls unavailable; using existing method"
        return nil
    end
    local slot = self:FishingViewSlot(config)
    local home, environment = self.cameraHome, self.cameraEnvironment
    if not self:CallCamera(SaveView, slot) then
        self:InvalidateSavedFishingView("Save failed; using existing method")
        return nil
    end
    if self.cameraHome ~= home or (home and not home.valid)
        or not self:CameraEnvironmentMatches(environment, self.cameraEnvironment) then return nil end
    local view = { version = 2, nativeSaved = true, slot = slot, tilt = config.tilt, zoom = zoom,
        requestedZoom = requestedZoom, preset = ReadPreset(slot), environment = environment }
    self.cameraFishingView = view
    self.cameraSavedViewRestored = true
    self.db.cameraFishingView = view
    if self.db.cameraSmartAdjustment and slot == 4 then
        self.cameraSmartBaseView, self.db.cameraSmartBaseView = view, view
    end
    self.cameraSavedViewStatus = "Prepared preset " .. view.slot .. "; retained between sessions"
        .. (view.preset and "" or "; native angle unavailable")
    self:TraceTransition("saved fishing view: preset " .. view.slot .. "; tilt " .. view.tilt)
    return view
end

local function BlendValue()
    if type(GetCVar) ~= "function" then return nil end
    local ok, raw = pcall(GetCVar, BLEND_CVAR)
    if not ok or (issecretvalue and issecretvalue(raw)) then return nil end
    local value = tonumber(raw)
    if value ~= 1 and value ~= 2 then return nil end
    return value, tostring(raw)
end

function FF:FishingViewBlendChanged()
    local snapshot = self.db.cameraViewBlendRestore
    local entry = snapshot and snapshot[BLEND_CVAR]
    if not entry then return false end
    -- CVAR_UPDATE can arrive after our setter returns. Compare the actual
    -- value so delayed notifications from our own change do not cancel scans.
    return BlendValue() ~= tonumber(entry.applied)
end

function FF:LoadPreparedFishingView(view)
    if not self.db.cameraSavedView or self.cameraFishingView ~= view or type(SetView) ~= "function" then return false end
    if not self:CameraEnvironmentMatches(view.environment, self.cameraEnvironment) then return false end
    if PresetChanged(view) then
        self:InvalidateSavedFishingView("Fishing preset changed; rebuilding")
        return false
    end
    self:ReleaseFishingViewBlend()
    local blend, old = BlendValue()
    if not blend or self.db.cameraViewBlendRestore then
        self.cameraSavedViewStatus = "Blend setting unavailable; using existing method"
        return false
    end
    if blend ~= 1 then
        if type(SetCVar) ~= "function" then return false end
        self.db.cameraViewBlendRestore = { [BLEND_CVAR] = { old = old, applied = "1" } }
        self.cameraOwnViewCVar = true
        local ok = pcall(SetCVar, BLEND_CVAR, "1")
        self.cameraOwnViewCVar = nil
        if not ok or BlendValue() ~= 1 then
            self:ReleaseFishingViewBlend()
            self.cameraSavedViewStatus = "Smooth view rejected; using existing method"
            return false
        end
    end
    -- A third-party callback may have relinquished the view during our setter.
    if self.cameraFishingView ~= view
        or not self:CameraEnvironmentMatches(view.environment, self.cameraEnvironment) then return false end
    -- Exactly one call: repeated SetView calls can turn the blend into a snap.
    if not self:CallCamera(SetView, view.slot) then
        self:InvalidateSavedFishingView("Load failed; using existing method")
        return false
    end
    if self.cameraFishingView ~= view
        or not self:CameraEnvironmentMatches(view.environment, self.cameraEnvironment) then return false end
    self.cameraSavedViewStatus = "Loading preset " .. view.slot .. "; actual angle unverified"
    self:TraceTransition("loading saved fishing view: preset " .. view.slot)
    return true
end

function FF:SavedFishingViewReady(view, now)
    if now < view.readyAt then return false end
    return true
end
