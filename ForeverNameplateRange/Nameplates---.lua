local addonName, ns = ...
local db, ticker, lastError
local active, labels = {}, setmetatable({}, { __mode = "k" })

local defaults = {
    enabled = true,
    size = 12,
    gap = 8,
    x = -8,
    y = 0,
    minimapAngle = math.rad(190),
    referenceByClass = {}
}

local function Safe(frame)
    return frame and not (frame.IsForbidden and frame:IsForbidden())
end

local function Public(value)
    return not (issecretvalue and issecretvalue(value))
end

local function Style(entry)
    if not db then return end
    local font = STANDARD_TEXT_FONT or select(1, GameFontNormal:GetFont())
    entry.text:SetFont(font, db.size or 12, "OUTLINE")
    entry.text:SetShadowColor(0, 0, 0, 1)
    entry.text:SetShadowOffset(1, -1)
    entry.text:ClearAllPoints()
    -- 저장된 db.x와 db.y를 이름표 앵커에 즉시 반영
    entry.text:SetPoint("RIGHT", entry.anchor, "LEFT", db.x or -8, db.y or 0)
end

local function Remove(unit)
    local entry = active[unit]
    if entry and entry.unit == unit then
        entry.text:Hide()
        entry.unit = nil
    end
    active[unit] = nil
end

local function UpdateUnit(unit)
    if not db or not db.enabled or not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then
        Remove(unit)
        return
    end
    local exists, hostile = UnitExists(unit), UnitCanAttack("player", unit)
    if not Public(exists) or not Public(hostile) or not exists or not hostile then Remove(unit); return end
    local dead = UnitIsDeadOrGhost(unit)
    if not Public(dead) or dead then Remove(unit); return end

    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not Safe(plate) then Remove(unit); return end
    local unitFrame = plate.UnitFrame
    if not Safe(unitFrame) then Remove(unit); return end
    local anchor = unitFrame.healthBar or (unitFrame.HealthBarsContainer and unitFrame.HealthBarsContainer.healthBar)
    if not Safe(anchor) then Remove(unit); return end

    local entry = labels[plate]
    if not entry or entry.anchor ~= anchor then
        if entry then entry.text:Hide() end
        local text = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetJustifyH("RIGHT")
        entry = { text = text, anchor = anchor }
        labels[plate] = entry
        Style(entry)
    end

    if entry.unit and entry.unit ~= unit then active[entry.unit] = nil end
    if active[unit] and active[unit] ~= entry then Remove(unit) end
    entry.unit, active[unit] = unit, entry
    entry.plateUnit = plate.namePlateUnitToken or unitFrame.unit

    local lib = LibStub and LibStub("LibRangeCheck-3.0", true)
    local low, high
    if lib and type(lib.GetRange) == "function" then
        local ok, a, b = pcall(lib.GetRange, lib, unit, true, false, 0.2)
        if ok then low, high = a, b else lastError = tostring(a) end
    else
        lastError = "LibRangeCheck-3.0 사용 불가"
    end

    local text, known = ns.FormatRange(low, high)
    entry.text:SetText(text)

    local rangeState = "unknown"
    if ns.ReferenceState and Public(low) and Public(high) then
        local ok, value = pcall(ns.ReferenceState, unit, low, high)
        if ok then rangeState = value else lastError = tostring(value) end
    end

    if rangeState == "out" then entry.text:SetTextColor(1, 0.15, 0.15, 1)
    elseif rangeState == "near" then entry.text:SetTextColor(1, 0.55, 0.1, 1)
    elseif rangeState == "in" then entry.text:SetTextColor(1, 0.86, 0.55, 1)
    else entry.text:SetTextColor(0.65, 0.65, 0.65, 1) end

    entry.text:Show()
end

local function TryUpdate(unit)
    local ok, err = pcall(UpdateUnit, unit)
    if not ok then
        lastError = tostring(err)
        Remove(unit)
    end
end

local function Rescan() TryUpdate("target") end
local function Refresh() TryUpdate("target") end

local function Restyle()
    for _, entry in pairs(labels) do Style(entry) end
    Rescan()
end

function ns.GetSettings() return db end

function ns.ApplySettings()
    ForeverNameplateRangeDB = db
    Restyle()
    Refresh()
end

SLASH_FOREVERNAMEPLATERANGE1 = "/npr"
SlashCmdList.FOREVERNAMEPLATERANGE = function(message)
    if not db then return end
    local command, value = (message or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    if command == "off" then
        db.enabled = false
        ns.ApplySettings()
    elseif command == "on" then
        db.enabled = true
        ns.ApplySettings()
    elseif command == "size" or command == "gap" then
        local n = tonumber(value)
        local minimum, maximum = command == "size" and 8 or 0, command == "size" and 24 or 60
        if not n or n ~= n or n < minimum or n > maximum then
            print(command == "size" and "/npr size 8~24" or "/npr gap 0~60")
            return
        end
        db[command] = n
        if command == "gap" then db.x = -n end
        ns.ApplySettings() -- 명령어로 변경 시에도 디스크 영구 저장 호출
    elseif command == "" and ns.ToggleOptions then
        ns.ToggleOptions()
    else
        Rescan()
        local count = 0
        for _ in pairs(active) do count = count + 1 end
        print("Forever Nameplate Range 1.1.0 · 표시 중 " .. count .. "개")
        if ns.ReferenceName then print(ns.ReferenceName()) end
        if lastError then print("최근 오류: " .. lastError) end
    end
end

local events = CreateFrame("Frame")
for _, event in ipairs({
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_LOGOUT", "PLAYER_ENTERING_WORLD",
    "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "UNIT_FACTION",
    "PLAYER_TARGET_CHANGED", "SPELLS_CHANGED", "UPDATE_SHAPESHIFT_FORM"
}) do
    events:RegisterEvent(event)
end

events:SetScript("OnEvent", function(_, event, unit)
    if event == "ADDON_LOADED" and unit == addonName then
        ForeverNameplateRangeDB = ForeverNameplateRangeDB or {}
        db = ForeverNameplateRangeDB

        -- DB 안전 병합 (x, y 포함 기본값 확실한 보정)
        for k, v in pairs(defaults) do
            if db[k] == nil then db[k] = v end
        end

    elseif event == "PLAYER_LOGIN" then
        if ns.InitOptions then ns.InitOptions() end
        if ns.RefreshReference then ns.RefreshReference() end
        Rescan()
        if not ticker then
            ticker = C_Timer.NewTicker(0.2, Refresh)
        end

    elseif event == "PLAYER_LOGOUT" then
        ns.ApplySettings()

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        if active.target and active.target.plateUnit == unit then Remove("target") end

    elseif event == "NAME_PLATE_UNIT_ADDED" then
        C_Timer.After(0, Rescan)

    elseif event == "PLAYER_TARGET_CHANGED" then
        Remove("target")
        Rescan()

    elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
        if ns.RefreshReference then
            local ok, err = pcall(ns.RefreshReference)
            if not ok then lastError = tostring(err) end
        end
        Rescan()

    elseif event == "UNIT_FACTION" and unit == "target" then
        Rescan()
    end
end)