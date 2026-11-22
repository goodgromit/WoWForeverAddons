-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local Recorder = {}
Recorder.__index = Recorder
local RECORDING_EVENTS = { "PLAYER_STARTED_MOVING", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED" }
local STEPS = { "1. Close cast — Hover over the bobber", "2. Long cast — Keep your cursor still", "3. Repeat — Try another long cast" }
local STEP_TITLES = { "1. Close cast", "2. Long cast", "3. Repeat" }
local STEP_ACTIONS = {
    { "Cast nearby.", "Hover over the bobber.", "At the splash, press your Fishing Key." },
    { "Place your cursor inside the scan box.", "Keep your character and mouse still.",
      "Once the bobber is found, press your Fishing Key.", "If no bobber is found, wait for the scan to end,", "then press your Fishing Key." },
    { "Please complete another long cast." },
}
local GUIDE_HEX = { grey = "9cadba", yellow = "ffC452", green = "6be3a1", orange = "ff9f45", red = "ff6666" }
local function Colour(text, state) return "|cff" .. GUIDE_HEX[state] .. text .. "|r" end
local function PaintText(line, text)
    if line.diagnosticText ~= text then line.diagnosticText = text; line:SetText(text) end
end
local function PaintColour(line, color)
    if line.diagnosticColor ~= color then line.diagnosticColor = color; line:SetTextColor(unpack(color)) end
end
local function PaintShown(frame, shown)
    shown = not not shown
    if frame:IsShown() ~= shown then frame:SetShown(shown) end
end
local AMBER, GREY, GREEN = { 1, .77, .32 }, { .61, .68, .73 }, { .42, .89, .63 }
local RED = { 1, .4, .4 }
local function Plain(value) return not (issecretvalue and issecretvalue(value)) end
local function Text(value, limit)
    return Plain(value) and type(value) == "string" and value:sub(1, limit or 160):gsub("[%c]", " "):gsub("|", "/") or nil
end
local function Copy(value, depth)
    if not Plain(value) then return nil end
    if type(value) ~= "table" then
        if type(value) == "string" then return Text(value) end
        return (type(value) == "number" or type(value) == "boolean") and value or nil
    end
    if (depth or 0) >= 3 then return nil end
    local result = {}
    for key, item in pairs(value) do
        if type(key) == "string" or type(key) == "number" then result[key] = Copy(item, (depth or 0) + 1) end
    end
    return result
end
local function Number(value)
    if not Plain(value) or (type(value) ~= "number" and type(value) ~= "string") then return nil end
    local number = tonumber(value)
    return number and number == number and math.abs(number) ~= math.huge and number or nil
end
local function ReadNumber(fn, argument)
    if type(fn) ~= "function" then return nil, "API unavailable" end
    local ok, value
    if argument == nil then ok, value = pcall(fn) else ok, value = pcall(fn, argument) end
    if not ok then return nil, "API error" end
    local number = Number(value)
    return number, number and "readable" or "unavailable/inaccessible/invalid"
end
local function ReadViewCVar(name)
    local value, state = ReadNumber(GetCVar, name)
    if value == nil and Plain(C_CVar) and type(C_CVar) == "table" then
        local alternate, alternateState = ReadNumber(rawget(C_CVar, "GetCVar"), name)
        if alternate ~= nil then return alternate, alternateState end
    end
    return value, state
end
local function ViewFact(view)
    if not Plain(view) or type(view) ~= "table" then return {} end
    local fact = {}
    for _, key in ipairs({ "slot", "version", "tilt", "zoom", "requestedZoom" }) do fact[key] = Number(rawget(view, key)) end
    fact.nativeSaved = rawget(view, "nativeSaved") == true
    local preset = rawget(view, "preset")
    if Plain(preset) and type(preset) == "table" then
        fact.preset = { pitch = Number(rawget(preset, "pitch")), yaw = Number(rawget(preset, "yaw")), distance = Number(rawget(preset, "distance")) }
    end
    return fact
end
local function NPCInteraction()
    local states = {}
    local manager = Plain(C_PlayerInteractionManager) and type(C_PlayerInteractionManager) == "table" and C_PlayerInteractionManager
    local kinds = Plain(Enum) and type(Enum) == "table" and rawget(Enum, "PlayerInteractionType")
    local callback = manager and rawget(manager, "IsInteractingWithNpcOfType")
    for _, name in ipairs({ "Gossip", "QuestGiver" }) do
        local kind = Plain(kinds) and type(kinds) == "table" and Number(rawget(kinds, name))
        local ok, value
        if type(callback) == "function" and kind then ok, value = pcall(callback, kind) end
        states[#states+1] = name .. "=" .. (ok and Plain(value) and type(value) == "boolean" and tostring(value) or "unavailable")
    end
    return table.concat(states, "; ")
end
-- Snapshot only at explicit recording start. Never enumerate from a scan tick
-- or report renderer, and never load/enable addons to inspect them.
local function AddonRead(name, ...)
    local api = Plain(C_AddOns) and type(C_AddOns) == "table" and C_AddOns
    local callback = api and rawget(api, name)
    if Plain(callback) and type(callback) == "function" then
        local ok, a, b, c, d, e, f, g = pcall(callback, ...)
        if ok then return true, a, b, c, d, e, f, g end
    end
    local fallback = rawget(_G, name)
    if Plain(fallback) and type(fallback) == "function" and (not Plain(callback) or fallback ~= callback) then return pcall(fallback, ...) end
    return false
end
local function Boolean(value)
    if not Plain(value) then return nil end
    if type(value) == "boolean" then return value end
    if type(value) == "number" and (value == 0 or value == 1) then return value == 1 end
end
local function AddonInventory()
    local ok, count = AddonRead("GetNumAddOns")
    count = ok and Number(count)
    if not count or count < 0 or count ~= math.floor(count) then return "Addon inventory unavailable (client API unreadable)." end
    -- Protect against faulty replacement APIs while retaining every normal
    -- client-listed addon. Explicitly report any defensive truncation.
    local maximum = math.min(count, 4096)
    local rows, active, inactive, unknown = {}, 0, 0, 0
    for index = 1, maximum do
        local readable, name, _, _, a, b, c, d = AddonRead("GetAddOnInfo", index)
        local loadable, reason
        if readable and Plain(name) and type(name) == "table" then
            local info = name
            name, loadable, reason = rawget(info, "name"), Boolean(rawget(info, "loadable")), Text(rawget(info, "reason"))
        elseif readable then
            -- Older global clients also returned enabled before loadable.
            if Boolean(b) ~= nil or Text(d) then loadable, reason = Boolean(b), Text(c)
            else loadable, reason = Boolean(a), Text(b) end
        end
        if not Text(name, 256) then
            local found, alternate = AddonRead("GetAddOnName", index)
            name = found and Text(alternate, 256) or nil
        end
        local label = Text(name, 256) or ("[unreadable addon #" .. index .. "]")
        local status, loading, version, demand = "status unavailable", nil, nil, nil
        if name then
            local loadedOK, present, complete = AddonRead("IsAddOnLoaded", name)
            if loadedOK then
                local loaded, current = Boolean(complete), Boolean(present)
                if loaded == nil then loaded = current end
                if loaded ~= nil then status = loaded and "active" or "inactive" end
                loading = current == true and Boolean(complete) == false
            end
            local versionOK, value = AddonRead("GetAddOnMetadata", name, "Version")
            version = versionOK and Text(value, 96)
            local demandOK, value = AddonRead("IsAddOnLoadOnDemand", name)
            if demandOK then demand = Boolean(value) end
        end
        if status == "active" then active = active+1
        elseif status == "inactive" then inactive = inactive+1 else unknown = unknown+1 end
        rows[#rows+1] = label .. " (" .. status .. (loading and "; loading" or "") .. "); version " .. (version or "unavailable")
            .. "; load-on-demand " .. (demand == nil and "unavailable" or tostring(demand))
            .. "; loadable " .. (loadable == nil and "unavailable" or tostring(loadable))
            .. (reason and reason ~= "" and ("; reason " .. reason) or "")
    end
    table.sort(rows)
    local header = string.format("Installed addon inventory at recording start: %d client-listed; %d active; %d inactive; %d unreadable status.",
        count, active, inactive, unknown)
    if count > maximum then header = header .. " Defensive limit: only the first " .. maximum .. " entries captured." end
    return header .. "\nActive = loaded in this session; inactive = not loaded. Load-on-demand addons may be enabled but inactive.\n"
        .. "Snapshot only; later loads/enable changes are not monitored. Listing is not cause attribution.\n" .. table.concat(rows, "\n")
end
local CLIENT_SETTING_GROUPS = {
    { "Camera controls", "cameraYawMoveSpeed", "cameraPitchMoveSpeed", "cameraZoomSpeed", "cameraDistanceMoveSpeed",
      "cameraDistanceMaxZoomFactor", "cameraSmoothStyle", "cameraSmoothTrackingStyle", "cameraViewBlendStyle", "pitchlimit",
      "test_cameraDynamicPitch", "test_cameraDynamicPitchBaseFovPad", "test_cameraDynamicPitchBaseFovPadFlying",
      "test_cameraDynamicPitchSmartPivotCutoffDist", "test_cameraTargetFocusEnemyEnable",
      "test_cameraTargetFocusEnemyStrengthPitch", "test_cameraTargetFocusEnemyStrengthYaw", "cameraWaterCollision" },
    { "Display and frame limits", "gxWindow", "gxMaximize", "gxResolution", "useUiScale", "uiScale", "renderScale",
      "maxFPS", "maxFPSBk", "vsync", "ResampleQuality" },
    { "Object/water visibility", "graphicsLiquidDetail", "graphicsParticleDensity", "farclip", "graphicsOutlineMode", "Outline" },
}
local function SettingValue(value)
    local text = Text(value, 80)
    if text and text ~= "" then return text end
    local number = Number(value)
    if number then return tostring(number) end
end
local function ClientSetting(name)
    if Plain(GetCVar) and type(GetCVar) == "function" then
        local ok, value = pcall(GetCVar, name)
        local text = ok and SettingValue(value)
        if text then return text end
    end
    local api = Plain(C_CVar) and type(C_CVar) == "table" and C_CVar
    local callback = api and rawget(api, "GetCVar")
    if Plain(callback) and type(callback) == "function" and (not Plain(GetCVar) or callback ~= GetCVar) then
        local ok, value = pcall(callback, name)
        local text = ok and SettingValue(value)
        if text then return text end
    end
    return "unavailable"
end
local function ClientSettings(ff)
    local lines = { "Additional client settings at recording start (read-only snapshot; unsupported values are unavailable):" }
    for _, group in ipairs(CLIENT_SETTING_GROUPS) do
        lines[#lines+1] = group[1] .. ":"
        for index = 2, #group do lines[#lines+1] = "  " .. group[index] .. "=" .. ClientSetting(group[index]) end
    end
    local width = ReadNumber(function() return UIParent and UIParent:GetWidth() end)
    local height = ReadNumber(function() return UIParent and UIParent:GetHeight() end)
    local scale = ReadNumber(function() return ff.cameraMarker and ff.cameraMarker:GetEffectiveScale() end)
    lines[#lines+1] = "UIParent dimensions: " .. tostring(width or "unavailable") .. " x " .. tostring(height or "unavailable")
        .. " UI units; cursor-box effective scale " .. tostring(scale or "unavailable")
    return table.concat(lines, "\n")
end
local function EnvironmentText(environment)
    local fields = {}
    for key, value in pairs(environment or {}) do
        if key ~= "version" then fields[#fields+1] = key .. "=" .. tostring(value) end
    end
    table.sort(fields)
    return (#fields > 0 and table.concat(fields, "; ") or "unavailable") .. "; missing fields are unverified"
end
local function FOVFact(ff)
    local state = ff.cameraFOVState
    if not Plain(state) or type(state) ~= "table" then return {} end
    return { original = Number(rawget(state, "original")), requested = Number(rawget(state, "requested")),
        achieved = Number(rawget(state, "achieved")), status = Text(rawget(state, "status")) }
end
local function FOVText(fact)
    fact = fact or {}
    return "original " .. tostring(fact.original or "unavailable") .. "; requested " .. tostring(fact.requested or "unavailable")
        .. "; last achieved " .. tostring(fact.achieved or "unavailable") .. "; " .. (fact.status or "not sampled")
end
function Recorder:ViewSnapshot(view, slot, observe)
    local ff = self.ff
    local snapshot = { at = GetTime(), view = ViewFact(view) }
    snapshot.slot = Number(slot) or snapshot.view.slot
    if observe then
        snapshot.environment = ff:ReadCameraEnvironment()
        snapshot.fov = FOVFact(ff)
        snapshot.interaction = NPCInteraction()
        snapshot.zoom, snapshot.zoomState = ReadNumber(GetCameraZoom)
        snapshot.blend, snapshot.blendState = ReadViewCVar("cameraViewBlendStyle")
        local ok, signature, state = pcall(ff.ReadFishingPresetSignature, ff, snapshot.slot, snapshot.view.preset)
        snapshot.signature, snapshot.signatureState = ok and signature or nil, ok and state or "snapshot unavailable (unverified)"
        local restore = ff.db.cameraViewBlendRestore
        local entry = Plain(restore) and type(restore) == "table" and rawget(restore, "cameraViewBlendStyle")
        if Plain(entry) and type(entry) == "table" then snapshot.blendOld, snapshot.blendApplied = Number(rawget(entry, "old")), Number(rawget(entry, "applied")) end
    end
    return snapshot
end
function Recorder:ViewEvent(message, slot)
    if not self.recording then return end
    local events = self.viewEvents
    if #events == 8 then table.remove(events, 1); self.omittedViewEvents = (self.omittedViewEvents or 0)+1 end
    events[#events+1] = { seconds = GetTime()-self.startedAt, castID = Number(self.ff.channelStartSerial),
        between = self.current == nil, message = Text(message), slot = Number(slot) }
end
function Recorder:ViewCycle()
    local record = self.current
    if self.recording and not self.endingCast and record and record.castID == self.ff.channelStartSerial then return record.viewCycle end
end
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function InteractCVars()
    local facts = {}
    for _, key in ipairs({ "softTargetInteract", "SoftTargetInteractArc", "SoftTargetInteractRange",
        "cameraYawMoveSpeed", "cameraPitchMoveSpeed", "cameraSmoothStyle", "cameraDistanceMaxZoomFactor" }) do
        if type(GetCVar) == "function" then
            local ok, value = pcall(GetCVar, key)
            facts[key] = ok and Text(value) or "unavailable"
        end
    end
    return facts
end
local function Font(parent, text, size, x, y, width, height)
    local line = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line:SetFont("Fonts\\FRIZQT__.TTF", size, "")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    line:SetSize(width, height); line:SetJustifyH("LEFT"); line:SetJustifyV("MIDDLE")
    line:SetTextColor(.88, .93, .96); line:SetText(text)
    return line
end
local function Bubble(parent, file, outset, color, layer)
    local coordinates = { 0, .25, .75, 1 }
    for row = 1, 3 do for col = 1, 3 do
        local texture = parent:CreateTexture(nil, layer)
        texture:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\" .. file)
        texture:SetTexCoord(coordinates[col], coordinates[col+1], coordinates[row], coordinates[row+1])
        texture:SetVertexColor(unpack(color))
        local corner = 24 + outset
        local left = col == 1 and -outset or corner-outset
        local top = row == 1 and outset or outset-corner
        local anchor = (row == 3 and "BOTTOM" or "TOP") .. (col == 3 and "RIGHT" or "LEFT")
        texture:SetPoint(anchor, parent, anchor, col == 3 and outset or left, row == 3 and -outset or top)
        if col == 2 then texture:SetPoint(row == 3 and "BOTTOMRIGHT" or "TOPRIGHT", parent,
            row == 3 and "BOTTOMRIGHT" or "TOPRIGHT", outset-corner, row == 3 and -outset or top)
        else texture:SetWidth(corner) end
        if row == 2 then texture:SetPoint(col == 3 and "BOTTOMRIGHT" or "BOTTOMLEFT", parent,
            col == 3 and "BOTTOMRIGHT" or "BOTTOMLEFT", col == 3 and outset or left, corner-outset)
        else texture:SetHeight(corner) end
    end end
end
local function Button(parent, label, width, click)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 25); button:SetText(label); button:SetScript("OnClick", click)
    return button
end
function FF:EnsureScanDiagnosticsUI()
    if self.scanDiagnosticsPanel then return self.scanDiagnosticsPanel end
    -- An ordinary passive frame, never a protected marker or full-screen catcher.
    local panel = CreateFrame("Frame", "ForeverFishingScanDiagnostics", self:EnsureFishingVisibilityRoot())
    panel:SetSize(338, 344)
    -- Read chat geometry only at construction; never track it during fishing.
    local x, y = 38, 235
    local chat = ChatFrame1
    if chat and chat:IsShown() and chat.GetLeft and chat.GetTop then
        local left, top = chat:GetLeft(), chat:GetTop()
        local scale = chat:GetEffectiveScale() / UIParent:GetEffectiveScale()
        if Plain(left) and Plain(top) and type(left) == "number" and type(top) == "number" then
            x, y = math.max(16, left * scale), top * scale + 24
        end
    end
    panel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    panel:SetClampedToScreen(true); panel:EnableMouse(false); panel:SetFrameStrata("HIGH")
    Bubble(panel, "CameraOnboardingGlow", 7, { .28, .52, .75, .18 }, "BACKGROUND")
    Bubble(panel, "CameraOnboardingFill", 0, { 1, 1, 1, .94 }, "BACKGROUND")
    Bubble(panel, "CameraOnboardingEdge", 0, { .45, .66, .80, .42 }, "BORDER")
    panel.title = Font(panel, "Scan Diagnostics", 16, 17, 14, 275, 24)
    panel.status = Font(panel, "Recording • 0/3", 12, 17, 43, 302, 20)
    panel.steps, panel.instructions, panel.indicators = {}, {}, {}
    local rows = { 70, 136, 232 }
    for i, label in ipairs(STEP_TITLES) do
        panel.steps[i] = Font(panel, label, 12, 40, rows[i], 281, 20)
        panel.instructions[i] = Font(panel, table.concat(STEP_ACTIONS[i], "\n"), 11, 40, rows[i]+21, 281, i == 2 and 72 or (i == 1 and 42 or 18))
        panel.instructions[i]:SetJustifyV("TOP")
        local indicator = panel:CreateTexture(nil, "OVERLAY")
        indicator:SetPoint("CENTER", panel, "TOPLEFT", 24, -rows[i]-10)
        panel.indicators[i] = indicator
    end
    panel.footer = Font(panel, "Recording scan activity...", 10, 17, 278, 304, 24)
    panel.message = Font(panel, "Your report is ready.", 12, 17, 70, 304, 20)
    panel.send = Font(panel, "Please copy and send your report to Hamish336", 12, 17, 99, 304, 18)
    panel.send:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    panel.send:SetTextColor(.98, .97, .90)
    panel.destination = Font(panel, "via the Forever Fishing CurseForge page.", 11, 17, 120, 304, 18)
    panel.appreciation = Font(panel, "Every report is appreciated and helps make fishing better for everyone!", 10, 17, 147, 304, 28)
    panel.appreciation:SetTextColor(.67, .76, .83)
    panel.appreciation:SetJustifyV("TOP")
    panel.message:Hide(); panel.send:Hide(); panel.destination:Hide(); panel.appreciation:Hide()
    local controls = CreateFrame("Frame", nil, panel)
    controls:SetAllPoints(panel); controls:EnableMouse(false); panel.controls = controls
    local close = Button(controls, "×", 24, function() self:CancelScanDiagnostics() end)
    close:SetPoint("TOPRIGHT", controls, "TOPRIGHT", -10, -10)
    local move = CreateFrame("Button", nil, controls)
    move:SetPoint("TOPLEFT", controls, "TOPLEFT", 8, -5); move:SetSize(282, 32)
    panel:SetMovable(true); move:RegisterForDrag("LeftButton")
    move:SetScript("OnDragStart", function() panel:StartMoving() end)
    move:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)
    -- Keep the report label visible during tests; disabled mouse input must
    -- pass through to the world even while the other controls are hidden.
    panel.view = Button(panel, "View Report", 171, function() self:ViewScanDiagnosticsReport() end)
    panel.view:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 13)
    panel.view:SetEnabled(false); panel.view:EnableMouse(false)
    panel.resume = Button(controls, "Resume", 115, function() self:ResumeScanDiagnostics() end)
    panel.resume:SetPoint("BOTTOMRIGHT", controls, "BOTTOMRIGHT", -16, 13)
    panel.resume:Hide()
    panel:Hide()
    panel:SetScript("OnHide", function()
        if self.scanDiagnostics and not self.scanDiagnostics.hiding then self:CancelScanDiagnostics() end
    end)
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames+1] = "ForeverFishingScanDiagnostics" end
    self.scanDiagnosticsPanel = panel
    return panel
end
function Recorder:HideInteractive()
    if self.closed then return end
    local ff = self.ff
    if ff.scanDiagnosticsPanel then
        ff.scanDiagnosticsPanel:StopMovingOrSizing()
        ff.scanDiagnosticsPanel.controls:Hide()
        local view = ff.scanDiagnosticsPanel.view
        if view.diagnosticEnabled ~= false then
            view.diagnosticEnabled = false; view:SetEnabled(false); view:EnableMouse(false)
        end
    end
    if ff.settingsPanel and ff.settingsPanel:IsShown() then ff.settingsPanel:Hide() end
    if ff.tracePanel and ff.tracePanel:IsShown() then
        self.viewing = false
        self.hiding = true; ff.tracePanel:Hide(); self.hiding = false
    end
    -- Hide only the tooltip owned by the diagnostic/settings entry we just used.
    if GameTooltip and GameTooltip.GetOwner then
        local owner = GameTooltip:GetOwner()
        if owner == ff.settingsPanel or owner == (ff.settingsPanel and ff.settingsPanel.scanIssueButton) then GameTooltip:Hide() end
    end
end
function Recorder:HideNoteUI()
    local ff = self.ff
    self.viewing = false
    if ff.scanDiagnosticsNote then
        ff.scanDiagnosticsNote:ClearFocus(); ff.scanDiagnosticsNote:Hide(); ff.scanDiagnosticsNote.caption:Hide()
        ff.scanDiagnosticsNote.scroll:Hide(); ff.scanDiagnosticsNote.field:Hide()
        if ff.StopScanReportNoteAnimation then ff:StopScanReportNoteAnimation() end
    end
    if ff.traceScroll then ff.traceScroll:SetPoint("TOPLEFT", ff.tracePanel, "TOPLEFT", 22, -82) end
end
function Recorder:Paint()
    if self.closed then return end
    local panel = self.ff.scanDiagnosticsPanel
    if not panel then return end
    PaintText(panel.title, self.complete and "Diagnostics Complete!" or "Scan Diagnostics")
    PaintText(panel.status, (self.complete and "Recorded" or (self.recording and "Recording" or "Paused")) .. " • " .. self.count .. "/3")
    PaintColour(panel.status, self.complete and GREEN or AMBER)
    local height = self.complete and 222 or 344
    if panel.diagnosticHeight ~= height then panel.diagnosticHeight = height; panel:SetHeight(height) end
    -- Paused/completed guide contents cannot change until recording resumes.
    -- Keep cast/combat UI safety live without rebuilding these cached strings.
    local staticGuide = not self.recording and (self.complete and "complete" or "paused") or nil
    if not staticGuide or self.staticGuide ~= staticGuide then
        for i, line in ipairs(panel.steps) do
            local done, active = i <= self.count, self.recording and i == self.count+1
            local record = self.results[i] or (active and (self.current or self.pendingClose or self.pendingLong))
            if record and record.guideInvalid then record = nil end
            local entry = record and (i == 1 and record.nativeVerified or (i > 1 and record.assistedEntry))
            local titleColor = (done or entry) and GREEN or (active and AMBER or GREY)
            if i == 3 then
                titleColor = done and GREEN or (self.stepThreeMovementWarning and RED or (self.count == 2 and AMBER or GREY))
            end
            PaintShown(line, not self.complete); PaintColour(line, titleColor)
            local actions = {}
            if i == 1 then
                local native = record and record.nativeVerified
                local hover = native and record.hover
                local reeled = record and self:ReelConfirmed(record)
                actions[1] = Colour(STEP_ACTIONS[i][1], (done or native) and "green" or (active and "yellow" or "grey"))
                actions[2] = Colour(STEP_ACTIONS[i][2], (done or hover) and "green" or (active and native and "yellow" or "grey"))
                actions[3] = Colour(STEP_ACTIONS[i][3], (done or reeled) and "green" or (active and hover and "yellow" or "grey"))
            elseif i == 2 then
                local begun = record and record.scanInitiated
                local outcome = record and record.longOutcome
                local found = outcome == "found"
                local other = outcome and not found
                local searching = begun and not outcome
                local action = record and (found and self:ReelConfirmed(record) or (other and record.recastConfirmed))
                actions[1] = Colour(STEP_ACTIONS[i][1], begun and "green" or (active and "yellow" or "grey"))
                actions[2] = Colour(STEP_ACTIONS[i][2], self.stepTwoMovementWarning and "red" or (outcome and "green" or (active and begun and "yellow" or "grey")))
                actions[3] = Colour(STEP_ACTIONS[i][3], found and (action and "green" or "yellow") or (searching and "yellow" or "grey"))
                actions[4] = Colour(STEP_ACTIONS[i][4], other and "green" or (searching and "orange" or "grey"))
                actions[5] = Colour(STEP_ACTIONS[i][5], other and (action and "green" or "yellow") or (searching and "orange" or "grey"))
            else
                if done then actions[1] = Colour(STEP_ACTIONS[i][1], "green")
                else
                    local color = self.count == 2 and "yellow" or "grey"
                    local castColor = entry and not self.stepThreeMovementWarning and "green" or color
                    actions[1] = Colour("Please complete another ", color) .. Colour("long cast", castColor) .. Colour(".", color)
                end
            end
            PaintShown(panel.instructions[i], not self.complete)
            PaintText(panel.instructions[i], table.concat(actions, "\n"))
            -- A green heading/action does not turn the whole-step indicator green.
            local indicator = panel.indicators[i]
            PaintShown(indicator, not self.complete)
            if indicator.diagnosticDone ~= done then
                indicator.diagnosticDone = done
                indicator:SetTexture(done and "Interface\\Buttons\\UI-CheckBox-Check" or "Interface\\Buttons\\WHITE8X8")
                indicator:SetSize(done and 18 or 6, done and 18 or 6)
            end
            local color = done and GREEN or (active and AMBER or GREY)
            if i == 3 then color = titleColor end
            if indicator.diagnosticColor ~= color then indicator.diagnosticColor = color; indicator:SetVertexColor(unpack(color)) end
        end
        self.staticGuide = staticGuide
    end
    PaintShown(panel.message, self.complete); PaintShown(panel.send, self.complete)
    PaintShown(panel.destination, self.complete); PaintShown(panel.appreciation, self.complete)
    PaintShown(panel.footer, not self.complete)
    PaintText(panel.footer, self.notice or (self.ff.active and "Recording scan activity... Esc cancels." or "Recording scan activity..."))
    PaintText(panel.view, self.count == 2 and not self.complete and "View Partial Report" or "View Report")
    PaintShown(panel.resume, self.reportPaused and not self.complete)
    local enabled = self.count >= 2 and not self.suspended and not self.ff.active and not Combat()
    if panel.view.diagnosticEnabled ~= enabled then
        panel.view.diagnosticEnabled = enabled; panel.view:SetEnabled(enabled); panel.view:EnableMouse(enabled)
    end
    PaintShown(panel.controls, not self.ff.active and not Combat())
end
function Recorder:LongFacts(record)
    local ff = self.ff
    local a = ff.cameraAttemptDiagnostics or ff.cameraLastAttemptDiagnostics
    if not a or a.castID ~= record.castID then a = record.assisted end
    if not a then return end
    local cursor = (record.markerInside or 0) > 0
    local found = a.outcome == "found" and a.queries.bobber > 0
    local begun = cursor and (a.scanContext ~= nil or found)
    local cast = ff.cameraCast
    local checks = cast and cast.id == record.castID and (cast.cursorSamples or 0)-(a.baseChecks or 0) or (a.checks or 0)
    local sampled = begun and (checks > 0 or found)
    local outcome
    if sampled and not record.scanInterrupted then
        if found then outcome = "found"
        elseif a.exhausted or (cast and cast.id == record.castID and cast.scanExhausted) then outcome = "missed"
        elseif a.outcome == "failed" and (record.assistedInputFailure or ff.cameraInputFailureReason) then outcome = "input failure"
        elseif record.endReason == "UNIT_SPELLCAST_CHANNEL_STOP" and (record.remainingBeforeEnd or 30) <= .25
            and not record.manualInput and not record.scanCancelledBeforeEnd and a.scanTime > 0 then outcome = "timeout" end
    end
    return a, begun, outcome
end
function Recorder:ObserveGuide()
    local record = self.current
    if not record or not self.recording then return end
    if record.step == 1 then
        if self.ff.cameraAssistNeeded and not record.assistedCast then
            record.assistedCast = true; self:InterruptGuide(record)
        end
        return
    end
    local a, begun, outcome = self:LongFacts(record)
    if not a then return end
    local changed = false
    if not record.assistedEntry then record.assistedEntry = true; changed = true end
    if begun and not record.scanInitiated then
        record.scanInitiated = true; changed = true
        local cursor = self.ff.cameraAttemptCursor
        if cursor then record.scanCursorX, record.scanCursorY = cursor[1], cursor[2] end
    end
    if outcome and not record.longOutcome then
        record.longOutcome = outcome; changed = true
        self.notice = outcome == "found" and "Bobber found. Use your Fishing Key."
            or "Scan ended. Press your Fishing Key to continue."
    elseif a.outcome == "cancelled" and not self.endingCast and not record.longOutcome and not record.guideInvalid then
        record.scanInterrupted, record.guideInvalid = true, true; changed = true
    end
    if changed then self:Paint() end
end
function Recorder:InterruptGuide(record, movement)
    if not record then return end
    local warningKey = record.step == 2 and "stepTwoMovementWarning" or (record.step == 3 and "stepThreeMovementWarning")
    local warningChanged = movement and warningKey and not self[warningKey]
    if warningChanged then self[warningKey] = true end
    if record.guideInvalid then
        if warningChanged then self:Paint() end
        return
    end
    if record.step > 1 and not record.longOutcome then record.scanInterrupted = true end
    record.guideInvalid = true
    self.notice = "Test interrupted. Retry this cast."
    self:Paint()
end
function Recorder:Transition(message)
    local current = self.current
    message = Text(message)
    if not current or not message then return end
    local events = current.transitions
    if #events < 24 then events[#events+1] = { seconds = GetTime()-current.startedAt, message = message }
    else current.omittedTransitions = (current.omittedTransitions or 0)+1 end
end
function Recorder:StartCast(resumed)
    if not self.recording then return end
    local ff = self.ff
    local input = self.recastInput
    if not resumed and input and input.record.castID ~= ff.channelStartSerial and GetTime()-input.at <= 1.5 then
        -- Native start may arrive synchronously before the secure PostClick.
        self:ConfirmRecast(input.record)
    end
    if not self.recording or resumed then return end
    self.stepTwoMovementWarning = nil -- A fresh native cast clears the latched visual warning.
    self.stepThreeMovementWarning = nil
    self.recastInput, self.pendingLong = nil, nil
    self.pendingClose = nil -- A fresh cast replaces the previous loot/action owner.
    self.current = { channelStartedAt = ff.castStart, castID = ff.channelStartSerial, step = self.count+1, startedAt = GetTime(),
        context = ff:CameraTraceContext(), key = Text((ff.GetFishingInputKey and ff:GetFishingInputKey() or ff.db.key)), mode = ff.db.cameraAssist and "Camera-assisted backup" or "Native bobber interaction",
        rangeDelay = ff.currentRangeDelay, recastDelay = ff.currentRecastDelay, hookDelay = ff.currentHookDelay,
        transitions = {}, softStates = {}, closeQueries = {}, closeProbeCount = 0 }
    self.current.entryAction = Text(ff:BindingMode())
    if type(GetBindingAction) == "function" then
        local ok, action = pcall(GetBindingAction, (ff.GetFishingInputKey and ff:GetFishingInputKey() or ff.db.key), true)
        if ok then self.current.binding = Text(action) end
    end
    self.notice = nil
    self:Paint()
end
function Recorder:ObserveClose(state)
    local current, ff = self.current, self.ff
    if not current or not self.recording then return end
    if not current.interact then
        current.interact = InteractCVars()
        if current.step == 1 and type(GetCameraZoom) == "function" then
            local ok, value = pcall(GetCameraZoom)
            if ok and Plain(value) and type(value) == "number" and value == value and math.abs(value) ~= math.huge then current.closeZoom = value end
        end
    end
    if type(state) == "string" then current.softStates[state] = (current.softStates[state] or 0)+1 end
    if current.step == 1 and state == "bobber" and not ff.cameraAssistNeeded and not current.nativeVerified then
        current.nativeVerified = true; self:Paint()
    end
    local reference = ff.cameraNativeBobberReference
    if reference and reference.castID == current.castID and not current.nativeReference then current.nativeReference = Copy(reference) end
    -- No extra probes during assisted scans, other steps, or after a verified hover.
    if current.step ~= 1 or current.hover or ff.cameraAssistNeeded then return end
    local now = GetTime()
    if current.lastCloseProbe and now-current.lastCloseProbe < .2 then return end
    current.lastCloseProbe = now
    local cursor = ff:ReadDiagnosticCursorSample()
    current.closeProbeCount = current.closeProbeCount+1
    local outcome = cursor.state or "unknown"
    current.closeQueries[outcome] = (current.closeQueries[outcome] or 0)+1
    -- Do not retain names of units, players or unrelated tooltip types.
    if cursor.tooltipType ~= 4 and cursor.id ~= "35591" then cursor.name = nil end
    current.lastCloseCursor = Copy(cursor)
    if cursor.state == "bobber" then
        current.hover = Copy(cursor); current.hoverSeconds = now-current.startedAt
        self.notice = "Hover recorded. Reel in with your Fishing Key."
        self:Paint()
    end
end
function Recorder:CaptureAssisted()
    local ff, current = self.ff, self.current
    if not current then return end
    local record = ff.cameraAttemptDiagnostics or ff.cameraLastAttemptDiagnostics
    if record and record.castID == current.castID then
        current.assisted = Copy(record)
        current.assistedInputFailure = Text(ff.cameraInputFailureReason)
    end
end
-- These facts belong to the same native channel serial; a ready binding or
-- channel stop alone never proves a player hook. Reuse qualified loot, and the
-- specific native "not hooked" response for an unsuccessful reel attempt.
function Recorder:ReelConfirmed(record)
    if record.reelEvidence == "qualified fishing loot" then return true end
    return record.reelErrorAt and record.endedAt and record.endReason == "UNIT_SPELLCAST_CHANNEL_STOP" and not record.manualInput
        and (record.remainingBeforeEnd or 0) > 1 and math.abs(record.endedAt-record.reelErrorAt) <= .5
end
function Recorder:CloseEvidence(record)
    if not record.hover or not record.nativeVerified or record.assisted or record.assistedCast or not self:ReelConfirmed(record) then return nil end
    return record.reelEvidence or "native unsuccessful reel response"
end
function Recorder:LongEvidence(record)
    if not record.longOutcome or record.scanInterrupted then return end
    if record.longOutcome == "found" then
        if self:ReelConfirmed(record) then return "cursor-box assisted detection and reel action recorded" end
    elseif record.recastConfirmed then return "completed scan " .. record.longOutcome .. " and fishing recast action recorded" end
end
function Recorder:Promote(record)
    local evidence = record.step == 1 and self:CloseEvidence(record) or self:LongEvidence(record)
    if not evidence then return end
    for i, extra in ipairs(self.skipped) do if extra == record then table.remove(self.skipped, i); break end end
    self:Accept(record, evidence); self:Paint()
end
function Recorder:ConfirmRecast(record)
    if not self.recording or record.step ~= self.count+1 or not record.longOutcome or record.longOutcome == "found"
        or record.scanInterrupted then return end
    record.recastConfirmed = true; record.guideInvalid = nil
    if record.endedAt then self:Promote(record) else self:Paint() end
end
function Recorder:Accept(record, evidence)
    if not self.recording or record.step ~= self.count+1 or record.castID == self.lastAcceptedCastID then return end
    record.validation = evidence
    record.guideInvalid = nil
    self.count = self.count+1; self.results[self.count] = record; self.lastAcceptedCastID = record.castID
    self.pendingClose, self.pendingLong, self.recastInput = nil, nil, nil; self.notice = nil
    if self.count == 3 then self.complete = true; self.recording = false; self:RemoveObservers(true) end
end
function Recorder:KeepPartial(record, reason)
    record.validation = "Incomplete test: " .. reason
    if #self.skipped == 2 then table.remove(self.skipped, 1); self.omittedExtras = (self.omittedExtras or 0)+1 end
    self.skipped[#self.skipped+1] = record
    self.notice = reason .. " Retry this test."
end
function Recorder:ConfirmReel(evidence)
    if not self.recording then return end
    local record = self.current or self.pendingClose or self.pendingLong
    if not record or record.castID ~= self.ff.channelStartSerial then return end
    if record.step == 1 then
        if not record.hover or not record.nativeVerified or record.assisted or record.assistedCast or self.ff.cameraAssistNeeded then return end
    elseif record.longOutcome ~= "found" or record.scanInterrupted then return end
    if record.endedAt and GetTime()-record.endedAt > 1.5 then return end
    if evidence == "qualified fishing loot" then record.reelEvidence = evidence
    else record.reelErrorAt = GetTime() end
    if record.endedAt then self:Promote(record) else self:Paint() end
end
function Recorder:FinishCast(reason)
    local current = self.current
    if not current or not self.recording then return end
    if current.viewCycle then
        local home = self.ff.cameraHome
        current.viewCycle.ended = self:ViewSnapshot(home and home.savedView, current.viewCycle.target, true)
    end
    self:CaptureAssisted()
    current.endedAt, current.endReason = GetTime(), Text(reason) or "channel ended"
    current.remainingBeforeEnd = current.remainingBeforeEnd or (self.ff.castEnd and self.ff.castEnd-GetTime())
    current.location = self.ff.statsCast and Text(self.ff.statsCast.location)
    current.finalAction = Text(self.ff:BindingMode())
    local evidence, retry
    if current.step == 1 then
        evidence = self:CloseEvidence(current)
        retry = current.assisted and "This was an assisted cast; try a nearby bobber."
            or (not current.hover and "Bobber hover was not verified.")
            or (not current.nativeVerified and "Native bobber interaction was not verified.")
            or "Reel-in was not confirmed."
    else
        local a, begun, outcome = self:LongFacts(current)
        current.assistedEntry = a ~= nil
        current.scanInitiated = current.scanInitiated or begun
        current.longOutcome = current.longOutcome or outcome
        evidence = self:LongEvidence(current)
        retry = current.longOutcome and "Fishing action was not confirmed."
            or (not begun and "Camera scan did not begin in the cursor box.")
            or "Scan interrupted before its outcome."
    end
    if evidence then self:Accept(current, evidence)
    else
        self:KeepPartial(current, retry)
        if current.step == 1 and current.hover and current.nativeVerified and not current.assisted
            and current.endReason == "UNIT_SPELLCAST_CHANNEL_STOP" then self.pendingClose = current end
        if current.step > 1 and current.longOutcome and not current.scanInterrupted and not current.guideInvalid
            and current.endReason == "UNIT_SPELLCAST_CHANNEL_STOP" then
            self.pendingLong = current
            self.notice = current.longOutcome == "found" and "Reel-in not confirmed. Retry this cast."
                or "Scan ended. Press your Fishing Key to continue."
        end
    end
    self.current = nil
    self:Paint()
end
function Recorder:Wrap(name, wrapper, observer)
    if self.hooks[name] or type(self.ff[name]) ~= "function" then return end
    local original = self.ff[name]
    local installed = wrapper(original)
    self.hooks[name] = { original = original, installed = installed, observer = observer }
    self.ff[name] = installed
end
function Recorder:RemoveObservers(onlyRecording)
    local events = self.ff.scanDiagnosticsEvents
    if events then for _, event in ipairs(RECORDING_EVENTS) do events:UnregisterEvent(event) end end
    for name, hook in pairs(self.hooks) do
        if not onlyRecording or hook.observer then
            if self.ff[name] == hook.installed then self.ff[name] = hook.original end
            self.hooks[name] = nil
        end
    end
end
function Recorder:Install()
    local r = self
    if self.recording and self.ff.scanDiagnosticsEvents then
        for _, event in ipairs(RECORDING_EVENTS) do self.ff.scanDiagnosticsEvents:RegisterEvent(event) end
    end
    self:Wrap("CameraEnvironmentChanged", function(original) return function(ff, key, old, new, boundary)
        if r.recording then
            local events = r.environmentEvents
            if #events == 8 then table.remove(events, 1); r.omittedEnvironmentEvents = (r.omittedEnvironmentEvents or 0)+1 end
            events[#events+1] = { at = GetTime()-r.startedAt, castID = Number(ff.channelStartSerial),
                key = Text(key), old = Number(old), new = Number(new), boundary = Text(boundary), interaction = NPCInteraction() }
        end
        original(ff, key, old, new, boundary)
    end end, true)
    self:Wrap("BeginSweepPreparation", function(original) return function(ff)
        local record = r.current
        local cycle
        if r.recording and record and record.castID == ff.channelStartSerial then
            record.views = record.views or { cycles = {} }
            if #record.views.cycles < 2 then
                cycle = { at = GetTime(), configured = Number(ff.db.cameraViewSlot), delay = Number(ff.db.cameraViewDelay),
                    smart = ff.db.cameraSmartAdjustment == true, before = r:ViewSnapshot(ff.cameraFishingView or ff.db.cameraFishingView, nil, true),
                    saveAPI = type(SaveView) == "function", loadAPI = type(SetView) == "function" }
                record.views.cycles[#record.views.cycles+1] = cycle
            else record.views.omitted = (record.views.omitted or 0)+1 end
            record.viewCycle = cycle
        end
        original(ff)
        if cycle and r.current == record and record.castID == ff.channelStartSerial then
            local prep, config = ff.cameraSweepPreparation, ff.cameraHome and ff.cameraHome.scanConfig
            if config then cycle.target = Number(ff:FishingViewSlot(config)); cycle.plannedTilt = Number(config.tilt) end
            cycle.path = prep and prep.savedView and (prep.smartAdjustment and "Smart reference + relative tilt" or "reused saved view")
                or (cycle.load and "saved load rejected; fresh preparation/fallback" or "fresh preparation/fallback")
        end
    end end, true)
    self:Wrap("LoadPreparedFishingView", function(original) return function(ff, view)
        local cycle = r:ViewCycle()
        local load = cycle and not cycle.scan and not cycle.load and { before = r:ViewSnapshot(view, nil, true) }
        if load then cycle.load = load end
        local accepted = original(ff, view)
        if load then
            load.accepted, load.finishedAt, load.status = accepted == true, GetTime(), Text(ff.cameraSavedViewStatus)
            load.blend, load.blendState = ReadViewCVar("cameraViewBlendStyle")
            local restore = ff.db.cameraViewBlendRestore
            local entry = Plain(restore) and type(restore) == "table" and rawget(restore, "cameraViewBlendStyle")
            if Plain(entry) and type(entry) == "table" then load.blendOld, load.blendApplied = Number(rawget(entry, "old")), Number(rawget(entry, "applied")) end
        end
        r:ViewEvent(accepted and "View load accepted; physical angle/settling unverified" or "View load rejected/fallback", ViewFact(view).slot)
        return accepted
    end end, true)
    self:Wrap("SavePreparedFishingView", function(original) return function(ff, config, zoom, requested)
        local saved = original(ff, config, zoom, requested)
        local cycle = r:ViewCycle()
        if cycle and not cycle.scan and not cycle.saved then
            cycle.saved = { at = GetTime(), accepted = saved ~= nil, view = ViewFact(saved), status = Text(ff.cameraSavedViewStatus) }
        end
        r:ViewEvent(saved and "Prepared preset save accepted; physical angle unverified" or ("Preset save/fallback: " .. (Text(ff.cameraSavedViewStatus) or "unavailable")), ViewFact(saved).slot)
        return saved
    end end, true)
    self:Wrap("BeginCameraScan", function(original) return function(ff)
        local started, cycle = ff.cameraScanStarted, r:ViewCycle()
        original(ff)
        if cycle and r:ViewCycle() == cycle and not started and ff.cameraScanStarted and not cycle.scan then
            local home = ff.cameraHome
            cycle.scan = r:ViewSnapshot(home and home.savedView, nil, true)
            cycle.scan.status = Text(ff.cameraSavedViewStatus)
        end
    end end, true)
    self:Wrap("InvalidateSavedFishingView", function(original) return function(ff, reason)
        local slot = ViewFact(ff.cameraFishingView or ff.db.cameraFishingView).slot
        original(ff, reason); r:ViewEvent("Preset invalidated: " .. (Text(reason) or "unspecified"), slot)
    end end, true)
    self:Wrap("ResetSmartCameraAdjustment", function(original) return function(ff, reason, clearBase)
        original(ff, reason, clearBase); r:ViewEvent("Smart reset: " .. (Text(reason) or "unspecified"), clearBase and 4 or nil)
    end end, true)
    self:Wrap("CameraCastStarted", function(original) return function(ff, resumed)
        r:HideInteractive(); original(ff, resumed); r:StartCast(resumed)
    end end)
    self:Wrap("StopChannel", function(original) return function(ff, reason, ...)
        if not r.recording then original(ff, reason, ...); r:Paint(); return end
        local serial, active = ff.channelStartSerial, ff.active
        local before = active and Text(ff:BindingMode())
        local remaining = active and ff.castEnd and ff.castEnd-GetTime()
        local attempt = ff.cameraAttemptDiagnostics or ff.cameraLastAttemptDiagnostics
        if r.current and attempt and attempt.castID == r.current.castID then
            r.current.scanCancelledBeforeEnd = attempt.outcome == "cancelled"
        end
        r.endingCast = active
        original(ff, reason, ...)
        r.endingCast = nil
        if active and not ff.active and r.current and r.current.castID == serial then
            r.current.actionBeforeEnd = before; r.current.remainingBeforeEnd = remaining; r:FinishCast(reason)
        end
        r:Paint()
    end end)
    self:Wrap("ShowModernSettings", function(original) return function(ff, ...)
        if r.closed then return original(ff, ...) end
        if not ff.active then return original(ff, ...) end
    end end)
    self:Wrap("ShowTraceWindow", function(original) return function(ff, report, title, subtitle)
        if r.closed then return original(ff, report, title, subtitle) end
        if not ff.active then
            if title ~= "Scan Diagnostics Report" then r:HideNoteUI() end
            return original(ff, report, title, subtitle)
        end
    end end)
    if not self.recording then return end
    self:Wrap("OnCastButtonPreClick", function(original) return function(ff, ...)
        original(ff, ...)
        r:ObserveGuide()
        local record = r.current or r.pendingLong
        r.recastInput = nil
        if r.recording and record and record.step > 1 and record.longOutcome and record.longOutcome ~= "found"
            and not record.scanInterrupted and not record.guideInvalid and ff.castClickArmed
            and ff.castClickAction == "cast" and ff.castClickChannelSerial == record.castID then
            r.recastInput = { record = record, at = GetTime() }
        end
    end end, true)
    self:Wrap("OnCastButtonPostClick", function(original) return function(ff, ...)
        local input, armed = r.recastInput, ff.castClickArmed
        original(ff, ...)
        if input and r.recastInput == input and armed and ff.lastCastButtonPressAt and ff.lastCastButtonPressAt >= input.at
            and GetTime()-input.at <= 1.5 then r:ConfirmRecast(input.record) end
        if r.recastInput == input then r.recastInput = nil end
    end end, true)
    self:Wrap("SetCameraAssistNeeded", function(original) return function(ff, ...)
        original(ff, ...); r:ObserveGuide()
    end end, true)
    self:Wrap("FinishCameraAttempt", function(original) return function(ff, ...)
        original(ff, ...); r:ObserveGuide()
    end end, true)
    self:Wrap("RecordLoot", function(original) return function(ff, ...)
        local cast = ff.statsCast
        local successful = cast and cast.success
        original(ff, ...)
        local record = r.current or r.pendingClose or r.pendingLong
        if record and cast and ff.statsCast == cast and not successful and cast.success and cast.verified
            and cast.started == record.channelStartedAt and record.castID == ff.channelStartSerial then
            r:ConfirmReel("qualified fishing loot")
        end
    end end, true)
    self:Wrap("OnFishingEscapeMessage", function(original) return function(ff, message)
        -- Escaped/timeout messages and generic UI errors cannot prove a hook.
        if Plain(message) and type(message) == "string" and ERR_FISH_NOT_HOOKED and message == ERR_FISH_NOT_HOOKED then
            r:ConfirmReel("native unsuccessful reel response")
        end
        return original(ff, message)
    end end, true)
    self:Wrap("BobberInteractState", function(original) return function(ff, ...)
        local state, label = original(ff, ...); r:ObserveClose(state); return state, label
    end end, true)
    self:Wrap("CameraState", function(original) return function(ff, state)
        local previous = ff.cameraState
        original(ff, state)
        if previous ~= ff.cameraState then
            r:Transition("Camera state: " .. (ff.cameraState or "unknown"))
            r:ObserveGuide()
        end
    end end, true)
    self:Wrap("CameraMarkerHasCursor", function(original) return function(ff, ...)
        local inside = original(ff, ...)
        local current = r.current
        if current then
            local key = inside and "markerInside" or "markerOutside"
            current[key] = (current[key] or 0)+1
            if not inside and (current.scanInitiated or (current.step == 3 and (current.markerInside or 0) > 0)) then
                if not current.longOutcome then r:InterruptGuide(current, true)
                else
                    -- Keep a completed scan's validation facts; this is only a visual warning.
                    local key = current.step == 2 and "stepTwoMovementWarning" or (current.step == 3 and "stepThreeMovementWarning")
                    if key and not r[key] then r[key] = true; r:Paint() end
                end
            end
        end
        return inside
    end end, true)
    self:Wrap("ReadCameraCursor", function(original) return function(ff, ...)
        local x, y = original(ff, ...)
        local current = r.current
        if current and x and y then
            current.cursorStartX, current.cursorStartY = current.cursorStartX or x, current.cursorStartY or y
            current.cursorX, current.cursorY = x, y
            current.maxCursorDrift = math.max(current.maxCursorDrift or 0, math.abs(x-current.cursorStartX)+math.abs(y-current.cursorStartY))
            if current.scanInitiated and not current.longOutcome and current.scanCursorX
                and math.abs(x-current.scanCursorX)+math.abs(y-current.scanCursorY) > 8 then r:InterruptGuide(current, true) end
        end
        return x, y
    end end, true)
    self:Wrap("TraceTransition", function(original) return function(ff, message)
        original(ff, message); r:Transition(message)
    end end, true)
    self:Wrap("EndCameraAttemptDiagnostics", function(original) return function(ff, reason)
        original(ff, reason); r:CaptureAssisted(); r:ObserveGuide()
    end end, true)
    self:Wrap("StopCameraAssist", function(original) return function(ff, reason, endSession)
        original(ff, reason, endSession)
        if endSession and r.current then r:CaptureAssisted(); r.notice = "Fishing bar closed. Reopen it to continue the tests." end
    end end, true)
end
local function ViewNumber(value)
    local number = Number(value)
    return number and string.format("%.2f", number) or "unavailable"
end
local function SignatureText(signature)
    if not signature then return "unavailable" end
    return "pitch/yaw/distance " .. ViewNumber(signature.pitch) .. "/" .. ViewNumber(signature.yaw) .. "/" .. ViewNumber(signature.distance)
end
local function AppendViewSnapshot(lines, label, snapshot)
    if not snapshot then return end
    if snapshot.environment then
        lines[#lines+1] = label .. " camera environment: " .. EnvironmentText(snapshot.environment)
        lines[#lines+1] = "  Fishing FOV normalization: " .. FOVText(snapshot.fov)
        lines[#lines+1] = "  NPC interaction: " .. (snapshot.interaction or "unavailable")
    end
    local view = snapshot.view
    lines[#lines+1] = label .. ": slot " .. tostring(snapshot.slot or "unavailable")
        .. "; record version " .. tostring(view.version or "unavailable") .. "; nativeSaved " .. tostring(view.nativeSaved)
        .. "; retained tilt/achieved/requested zoom " .. ViewNumber(view.tilt) .. "/" .. ViewNumber(view.zoom) .. "/" .. ViewNumber(view.requestedZoom)
    lines[#lines+1] = "  Observed zoom " .. ViewNumber(snapshot.zoom) .. " (" .. (snapshot.zoomState or "not sampled")
        .. "); blend " .. ViewNumber(snapshot.blend) .. " (" .. (snapshot.blendState or "not sampled") .. ")"
    lines[#lines+1] = "  Native preset signature: " .. (snapshot.signatureState or "not sampled")
        .. "; retained " .. SignatureText(view.preset) .. "; observed " .. SignatureText(snapshot.signature)
end
function Recorder:AppendViewReport(lines, record)
    if not record.views then
        lines[#lines+1] = "Camera presets: no view preparation observed for this cast."
        return
    end
    for i, cycle in ipairs(record.views.cycles) do
        lines[#lines+1] = "Camera preset preparation " .. i .. ": " .. (cycle.path or "pending")
        lines[#lines+1] = "  Configured/selected/loaded/prepared slots " .. tostring(cycle.configured or "unavailable")
            .. "/" .. tostring(cycle.target or "unavailable") .. "/" .. tostring(cycle.load and cycle.load.before.slot or "not loaded")
            .. "/" .. tostring(cycle.scan and cycle.scan.view.slot or "not observed")
            .. "; Smart " .. tostring(cycle.smart) .. "; planned tilt " .. ViewNumber(cycle.plannedTilt)
            .. "; configured settle delay " .. ViewNumber(cycle.delay) .. "s"
        lines[#lines+1] = "  SaveView/SetView APIs available " .. tostring(cycle.saveAPI) .. "/" .. tostring(cycle.loadAPI)
        AppendViewSnapshot(lines, "  Before preparation", cycle.before)
        local load = cycle.load
        if load then
            AppendViewSnapshot(lines, "  Before load", load.before)
            lines[#lines+1] = "  Load accepted " .. tostring(load.accepted) .. "; " .. (load.status or "status unavailable")
                .. "; blend old/applied/observed after load " .. ViewNumber(load.blendOld) .. "/" .. ViewNumber(load.blendApplied) .. "/" .. ViewNumber(load.blend)
        else lines[#lines+1] = "  Load: not attempted in this preparation." end
        if cycle.saved then
            lines[#lines+1] = "  Save accepted " .. tostring(cycle.saved.accepted) .. "; slot " .. tostring(cycle.saved.view.slot or "unavailable")
                .. "; " .. (cycle.saved.status or "status unavailable")
        end
        local scan = cycle.scan
        if scan then
            AppendViewSnapshot(lines, "  At scan start", scan)
            lines[#lines+1] = "  Observed preparation-to-scan " .. ViewNumber(scan.at-cycle.at) .. "s"
                .. (load and ("; load-to-scan " .. ViewNumber(scan.at-load.before.at) .. "s") or "")
            -- Compare retained achieved zoom, never the requested distance: collision is normal.
            local expected = scan.view.zoom or (load and load.accepted and load.before.view.zoom)
            if scan.zoom and expected then
                local delta = scan.zoom-expected
                lines[#lines+1] = "  Observed zoom minus retained achieved zoom " .. ViewNumber(delta)
                    .. (math.abs(delta) > .05 and "; observed mismatch, cause unverified" or "; within 0.05 reporting tolerance")
            else lines[#lines+1] = "  Retained/observed zoom comparison: unavailable (unverified)." end
        else lines[#lines+1] = "  Scan start: not observed for this preparation." end
        AppendViewSnapshot(lines, "  At channel end (may include normal view return)", cycle.ended)
        lines[#lines+1] = "  Native signature values describe a stored preset, not the live camera angle. Physical pitch/yaw and view settling: unverified."
    end
    if record.views.omitted then lines[#lines+1] = "Additional preparations omitted: " .. record.views.omitted end
end
function Recorder:Report()
    local ff = self.ff
    local lines = { "Forever Fishing — Guided Scan Diagnostics", "Environment at recording start:", self.environment,
        "Result: " .. self.count .. "/3 recorded; " .. (self.complete and "complete" or "partial"),
        "Requested close/long labels are instructions; physical distance and bobber ownership are not measured.",
        "Green means an attempt was recorded, not that detection or catching succeeded.",
        "Recorder: existing assisted probes/events; close-only hover reads at most 5/sec until recognition. No diagnostic CPU profiling.",
        "Player description: " .. (Text(self.description, 400) or "not supplied"), "" }
    lines[#lines+1] = "Camera environment at recording start: " .. EnvironmentText(self.initialCameraEnvironment)
    lines[#lines+1] = "Fishing FOV at recording start: " .. FOVText(self.initialFishingFOV)
    lines[#lines+1] = self.clientSettings or "Additional client settings unavailable."
    lines[#lines+1] = ""
    lines[#lines+1] = self.addonInventory or "Addon inventory unavailable."
    lines[#lines+1] = ""
    for _, event in ipairs(self.environmentEvents or {}) do
        lines[#lines+1] = string.format("Camera environment change +%.2fs; cast %s; %s %s -> %s; %s; NPC %s",
            event.at, tostring(event.castID), event.key or "unavailable", tostring(event.old), tostring(event.new),
            event.boundary or "unavailable", event.interaction)
    end
    if self.omittedEnvironmentEvents then lines[#lines+1] = "Earlier camera environment changes omitted: " .. self.omittedEnvironmentEvents end
    local aliases = {}
    for name in pairs(ff.cameraBobberNames or {}) do aliases[#aliases+1] = Text(name) or "unavailable" end
    table.sort(aliases)
    lines[#lines+1] = "Verified name aliases this login: " .. (#aliases > 0 and table.concat(aliases, "; ") or "none")
    local function attempt(record, label)
        lines[#lines+1] = label
        if not record then lines[#lines+1] = "Not recorded."; lines[#lines+1] = ""; return end
        lines[#lines+1] = "Test validation: " .. (record.validation or "pending; required evidence not yet settled")
            .. "; requested test " .. record.step
        lines[#lines+1] = string.format("Cast %s; duration %.2fs; end %s; location %s", tostring(record.castID),
            (record.endedAt or GetTime())-record.startedAt, record.endReason or "still open", record.location or record.context.location or "unavailable")
        lines[#lines+1] = string.format("Key %s; mode %s; entry delays range/recast/hook %s/%s/%s; final action %s",
            record.key or "none", record.mode, tostring(record.rangeDelay), tostring(record.recastDelay), tostring(record.hookDelay), record.finalAction or "not ended")
        lines[#lines+1] = "Entry key action: " .. (record.entryAction or "unavailable") .. "; binding " .. (record.binding or "unavailable")
            .. "; action before end " .. (record.actionBeforeEnd or "not ended")
        lines[#lines+1] = string.format("Marker observations: inside %d; outside/unavailable %d; maximum cursor drift %s physical pixels",
            record.markerInside or 0, record.markerOutside or 0, tostring(record.maxCursorDrift or "unavailable"))
        local vars = {}
        for key, value in pairs(record.interact or {}) do vars[#vars+1] = key .. "=" .. value end
        table.sort(vars); lines[#lines+1] = "CVars at first status sample: " .. table.concat(vars, "; ")
        lines[#lines+1] = string.format("Cast settings: %s; speed %s; width %s; spacing %s; rows %s; zoom %s; tilt %s; channel budget %s",
            record.context.profile or "unknown", tostring(record.context.speed), tostring(record.context.width), tostring(record.context.spacing),
            tostring(record.context.rows), tostring(record.context.zoom), tostring(record.context.tilt), tostring(record.context.remaining))
        self:AppendViewReport(lines, record)
        local states = {}
        for state, count in pairs(record.softStates) do states[#states+1] = state .. "=" .. count end
        table.sort(states); lines[#lines+1] = "Native status samples: " .. table.concat(states, "; ")
        lines[#lines+1] = "Native standard-ID reference: " .. (record.nativeReference and record.nativeReference.identity or "not observed")
        if record.step == 1 then
            lines[#lines+1] = "Close hover reads: " .. record.closeProbeCount .. "; verified hover " .. (record.hover and "yes" or "not observed")
            lines[#lines+1] = "Actual close-view zoom: " .. tostring(record.closeZoom or "unavailable") .. "; angle not measured"
            local cursor = record.hover or record.lastCloseCursor
            if cursor then lines[#lines+1] = string.format("Cursor: %s; %s; type %s; name %s; route %s; title %s",
                cursor.state, cursor.identity or "none", tostring(cursor.tooltipType), cursor.name or "unavailable", cursor.route or "unavailable", cursor.nameStatus or "unavailable") end
            local outcomes = {}
            for state, count in pairs(record.closeQueries) do outcomes[#outcomes+1] = state .. "=" .. count end
            table.sort(outcomes); lines[#lines+1] = "Close query outcomes: " .. table.concat(outcomes, "; ")
        end
        local assisted = record.assisted
        if assisted then
            lines[#lines+1] = "Assisted outcome: " .. (assisted.outcome or "pending") .. "; reason " .. (assisted.reason or "none")
                .. "; state " .. assisted.state .. "; end " .. (assisted.endReason or "not ended")
            ff:AppendCameraTraceAttempt(lines, assisted)
            lines[#lines+1] = string.format("Time preparation/scan/pause/wait: %.2f/%.2f/%.2f/%.2fs; frames/checks/events %d/%d/%d",
                assisted.preparationTime, assisted.scanTime, assisted.pausedTime, assisted.waitingTime, assisted.frames or 0, assisted.checks or 0, assisted.events or 0)
            local q = assisted.queries
            lines[#lines+1] = string.format("Queries: bobber %d; object %d; other %d; empty %d; unavailable %d; error %d; inaccessible %d; invalid %d",
                q.bobber, q.object, q.other, q.empty, q.unavailable, q.error, q.inaccessible, q.invalid)
            local faults = assisted.inputFaults
            if faults then lines[#lines+1] = string.format("Input read faults: cursor %d; optional facing %d; optional position %d",
                faults.cursor, faults.facing, faults.position) end
        else lines[#lines+1] = "Assisted entry: not observed; scan-start failure cannot be distinguished from native handling using this cast alone." end
        for _, event in ipairs(record.transitions) do lines[#lines+1] = string.format("  +%.2fs %s", event.seconds, event.message) end
        if record.omittedTransitions then lines[#lines+1] = "Additional transitions omitted: " .. record.omittedTransitions end
        lines[#lines+1] = ""
    end
    for i, label in ipairs(STEPS) do attempt(self.results[i], label) end
    if self.current then attempt(self.current, "Open attempt (incomplete)") end
    for i, skipped in ipairs(self.skipped) do attempt(skipped, "Extra cast that did not qualify for its test " .. i) end
    if self.omittedExtras then lines[#lines+1] = "Earlier nonqualifying attempts omitted: " .. self.omittedExtras end
    for _, event in ipairs(self.castFailures) do lines[#lines+1] = event end
    lines[#lines+1] = "Preset lifecycle events (bounded, including between attempts):"
    for _, event in ipairs(self.viewEvents) do
        lines[#lines+1] = string.format("  +%.2fs cast %s; %s; slot %s; %s", event.seconds, tostring(event.castID or "unavailable"),
            event.between and "between attempts" or "during attempt", tostring(event.slot or "unavailable"), event.message or "unavailable")
    end
    if self.omittedViewEvents then lines[#lines+1] = "Earlier preset events omitted: " .. self.omittedViewEvents end
    lines[#lines+1] = "Copy this report and PM Hamish336 on the Forever Fishing CurseForge page."
    return table.concat(lines, "\n")
end
function FF:BeginScanDiagnostics()
    if Combat() then return end
    if self.scanDiagnostics then self:EnsureScanDiagnosticsUI():Show(); self.scanDiagnostics:Paint(); return end
    local recorder = setmetatable({ ff = self, recording = true, count = 0, results = {}, skipped = {}, hooks = {},
        environment = self:FishingTraceEnvironment(), castFailures = {}, viewEvents = {}, startedAt = GetTime(),
        addonInventory = AddonInventory(), clientSettings = ClientSettings(self),
        initialCameraEnvironment = self:ReadCameraEnvironment(), initialFishingFOV = FOVFact(self), environmentEvents = {} }, Recorder)
    self.scanDiagnostics = recorder
    self:EnsureScanDiagnosticsUI()
    recorder:HideInteractive()
    if self.CloseFishingFlyouts then self:CloseFishingFlyouts(true) end
    recorder:Install()
    local events = self.scanDiagnosticsEvents or CreateFrame("Frame")
    self.scanDiagnosticsEvents = events
    events:SetScript("OnEvent", function(_, event, unit, _, spellID)
        if event == "PLAYER_LOGOUT" then self:CancelScanDiagnostics()
        elseif event == "PLAYER_LEAVING_WORLD" then
            if recorder.current then recorder:FinishCast("World transition") end
            recorder.pendingClose, recorder.pendingLong, recorder.recastInput = nil, nil, nil; recorder.recording = false; recorder.suspended = not recorder.complete and not recorder.reportPaused; recorder:RemoveObservers(true); recorder.notice = recorder.reportPaused and "Recording paused. Resume to try the final cast." or "Waiting for the world to load..."
            recorder:HideInteractive(); recorder:Paint()
        elseif event == "PLAYER_ENTERING_WORLD" then
            if recorder.suspended and not recorder.complete then
                recorder.suspended = nil; recorder.recording = true; recorder.notice = "World changed. Retry the current test."
                recorder:Install(); recorder:HideInteractive(); recorder:Paint()
            end
        elseif event == "PLAYER_STARTED_MOVING" then
            if recorder.current then recorder.current.manualInput = true; recorder:Transition("Player moved"); recorder:InterruptGuide(recorder.current, true) end
            if recorder.pendingClose then recorder.pendingClose.manualInput = true; recorder:InterruptGuide(recorder.pendingClose, true) end
            if recorder.pendingLong then recorder.pendingLong.manualInput = true; recorder:InterruptGuide(recorder.pendingLong, true) end
        elseif event == "PLAYER_REGEN_DISABLED" then recorder:HideInteractive(); recorder:Transition("Combat started")
        elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
            if recorder.recording and Plain(unit) and unit == "player" and Plain(spellID)
                and (spellID == 131474 or spellID == 131476 or spellID == 7620) then
                if #recorder.castFailures == 4 then table.remove(recorder.castFailures, 1) end
                recorder.castFailures[#recorder.castFailures+1] = "Native fishing event: " .. event
                    .. "; active diagnostic cast " .. (recorder.current and "yes" or "no; start/end ordering unverified")
            end
        else recorder:Paint() end
    end)
    for _, event in ipairs({ "PLAYER_STARTED_MOVING", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "PLAYER_LEAVING_WORLD", "PLAYER_ENTERING_WORLD", "PLAYER_LOGOUT",
        "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED" }) do events:RegisterEvent(event) end
    if self.active then recorder.notice = "Finish your current cast; the next cast starts test 1." end
    self.scanDiagnosticsPanel:Show(); recorder:Paint()
end
function FF:ResumeScanDiagnostics()
    local recorder = self.scanDiagnostics
    if not recorder or not recorder.reportPaused or recorder.complete or recorder.count ~= 2 or self.active or Combat() then return end
    recorder:HideNoteUI(); recorder:HideInteractive()
    recorder.pendingClose, recorder.pendingLong, recorder.recastInput = nil, nil, nil
    recorder.reportPaused, recorder.suspended = nil, nil
    recorder.recording = true; recorder.notice = nil; recorder:Install(); recorder:Paint()
end
function FF:ViewScanDiagnosticsReport()
    local recorder = self.scanDiagnostics
    if not recorder or recorder.count < 2 or recorder.suspended or self.active or Combat() then return end
    recorder.pendingClose, recorder.pendingLong, recorder.recastInput = nil, nil, nil; recorder.recording = false; recorder:RemoveObservers(true)
    recorder.reportPaused = not recorder.complete
    if recorder.reportPaused then recorder.notice = "Recording paused. Resume to try the final cast." end
    recorder:Paint()
    self:ShowTraceWindow(recorder:Report(), "Scan Diagnostics Report", "please message this report to Hamish336 via the Forever Fishing CurseForge page")
    recorder.viewing = true
    local panel = self.tracePanel
    if not panel then return end
    if not self.scanDiagnosticsNote then
        local field = CreateFrame("Frame", nil, panel)
        field:SetSize(510, 26); field:SetPoint("TOPLEFT", panel, "TOPLEFT", 160, -68)
        local background = field:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints(field); background:SetColorTexture(.025, .055, .075, .96)
        local function Edge(first, last, horizontal)
            local edge = field:CreateTexture(nil, "BORDER")
            edge:SetColorTexture(.46, .38, .25, .85)
            edge:SetPoint(first, field, first, 0, 0); edge:SetPoint(last, field, last, 0, 0)
            if horizontal then edge:SetHeight(1) else edge:SetWidth(1) end
        end
        Edge("TOPLEFT", "TOPRIGHT", true); Edge("BOTTOMLEFT", "BOTTOMRIGHT", true)
        Edge("TOPLEFT", "BOTTOMLEFT", false); Edge("TOPRIGHT", "BOTTOMRIGHT", false)
        local scroll = CreateFrame("ScrollFrame", nil, field)
        scroll:SetSize(498, 14); scroll:SetPoint("TOPLEFT", field, "TOPLEFT", 6, -6)
        local note = CreateFrame("EditBox", nil, scroll)
        note:SetMultiLine(true); note:SetSize(498, 14)
        note:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
        note:SetAutoFocus(false); note:SetMaxLetters(400); note:SetFontObject(GameFontHighlightSmall)
        note:SetTextColor(.88, .93, .96)
        scroll:SetScrollChild(note)
        local caption = Font(panel, "User Description", 11, 20, 70, 132, 20)
        local placeholder = Font(scroll, "Briefly describe the issue you experienced... (Optional)", 11, 0, 0, 498, 14)
        placeholder:SetJustifyV("TOP"); placeholder:SetTextColor(.55, .65, .70)
        local measure = field:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        measure:SetWidth(498); measure:Hide()
        note.caption, note.scroll, note.placeholder, note.field = caption, scroll, placeholder, field
        local function Layout(immediate)
            local r = self.scanDiagnostics
            immediate = immediate or not r or not r.viewing
            local value = note:GetText() or ""
            measure:SetText(value)
            local measured = measure.GetStringHeight and Number(measure:GetStringHeight())
            if not measured or measured <= 0 then
                local lines = 0
                for line in (value .. "\n"):gmatch("([^\n]*)\n") do lines = lines+math.max(1, math.ceil(#line/82)) end
                measured = lines*14
            end
            note.contentHeight = math.max(14, measured)
            note:SetHeight(note.contentHeight)
            scroll:SetVerticalScroll(math.min(scroll:GetVerticalScroll(), math.max(0, note.contentHeight-scroll:GetHeight())))
            note.expanded = note.editing or value:find("\n", 1, true) ~= nil or note.contentHeight > 18
            local height = note.expanded and 68 or 26
            if self.SetScanReportNoteHeight then self:SetScanReportNoteHeight(height, immediate)
            else field:SetHeight(height); scroll:SetHeight(height-12) end
        end
        note.Layout = Layout
        field:EnableMouse(true); field:SetScript("OnMouseDown", function() note:SetFocus() end)
        scroll:EnableMouse(true); scroll:SetScript("OnMouseDown", function() note:SetFocus() end)
        scroll:EnableMouseWheel(true)
        scroll:SetScript("OnMouseWheel", function(_, delta)
            local maximum = math.max(0, note.contentHeight-scroll:GetHeight())
            scroll:SetVerticalScroll(math.max(0, math.min(maximum, scroll:GetVerticalScroll()-delta*14)))
        end)
        note:SetScript("OnEscapePressed", function() note:ClearFocus() end)
        note:SetScript("OnEditFocusGained", function() note.editing = true; Layout(false) end)
        note:SetScript("OnCursorChanged", function(_, x, y, width, height)
            local top, caret = scroll:GetVerticalScroll(), -y
            -- Include the caret's current line even before the native text height settles.
            note.contentHeight = math.max(note.contentHeight or 14, caret+height)
            if caret < top then scroll:SetVerticalScroll(math.max(0, caret))
            elseif caret+height > top+scroll:GetHeight() then
                scroll:SetVerticalScroll(caret+height-scroll:GetHeight())
            end
        end)
        note:SetScript("OnTextChanged", function()
            local r = self.scanDiagnostics
            local value = note:GetText()
            placeholder:SetShown(value == nil or value == "")
            -- Preserve line breaks in the temporary input; Report sanitizes the
            -- description with the same existing Text boundary when exported.
            if r then r.description = Plain(value) and type(value) == "string" and value:sub(1, 400) or nil end
            Layout(false)
        end)
        note:SetScript("OnEditFocusLost", function()
            local r = self.scanDiagnostics
            note.editing = false; Layout(not r or not r.viewing)
            if not r or not r.viewing then return end
            local value = note:GetText()
            r.description = Plain(value) and type(value) == "string" and value:sub(1, 400) or nil
            self:ShowTraceWindow(r:Report(), "Scan Diagnostics Report",
                "please message this report to Hamish336 via the Forever Fishing CurseForge page")
        end)
        self.scanDiagnosticsNote = note
    end
    self.scanDiagnosticsNote:SetText(recorder.description or "")
    self.scanDiagnosticsNote:Show(); self.scanDiagnosticsNote.caption:Show()
    self.scanDiagnosticsNote.field:Show(); self.scanDiagnosticsNote.Layout(true)
    self.scanDiagnosticsNote.scroll:Show(); self.scanDiagnosticsNote.scroll:SetVerticalScroll(0)
    self.scanDiagnosticsNote.placeholder:SetShown(not recorder.description or recorder.description == "")
    if not recorder.reportHideOriginal then
        recorder.reportHideOriginal = panel:GetScript("OnHide")
        recorder.reportHideWrapper = function(...)
            recorder.viewing = false -- Losing description focus must not reopen a closing report.
            if recorder.reportHideOriginal then recorder.reportHideOriginal(...) end
            if self.scanDiagnosticsNote then self.scanDiagnosticsNote:ClearFocus() end
            if not recorder.hiding then recorder:Paint() end
        end
        panel:SetScript("OnHide", recorder.reportHideWrapper)
    end
end
function FF:CancelScanDiagnostics()
    local recorder = self.scanDiagnostics
    if not recorder then return end
    recorder.recording = false; recorder:RemoveObservers()
    if self.scanDiagnosticsEvents then self.scanDiagnosticsEvents:UnregisterAllEvents(); self.scanDiagnosticsEvents:SetScript("OnEvent", nil) end
    recorder.hiding = true
    local viewing = recorder.viewing
    if self.tracePanel and recorder.reportHideWrapper and self.tracePanel:GetScript("OnHide") == recorder.reportHideWrapper then
        self.tracePanel:SetScript("OnHide", recorder.reportHideOriginal)
    end
    recorder:HideNoteUI()
    if self.scanDiagnosticsNote then self.scanDiagnosticsNote:SetText("") end
    if viewing and self.tracePanel then self.tracePanel:Hide() end
    recorder.closed = true
    recorder.current, recorder.pendingClose, recorder.pendingLong, recorder.recastInput, recorder.results, recorder.skipped, recorder.castFailures = nil, nil, nil, nil, nil, nil, nil
    recorder.environment, recorder.description, recorder.suspended, recorder.stepTwoMovementWarning, recorder.reportPaused = nil, nil, nil, nil, nil
    recorder.stepThreeMovementWarning = nil
    recorder.viewEvents = nil
    self.scanDiagnostics = nil
    if self.scanDiagnosticsPanel then self.scanDiagnosticsPanel:Hide() end
end
