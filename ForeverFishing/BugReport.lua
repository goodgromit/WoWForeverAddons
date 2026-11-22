-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local ADDON_NAME = (...) or "ForeverFishing"
local BUG_FORM = "https://github.com/Hamish336/ForeverFishing-Issues/issues/new?template=01-bug.yml"

local function Public(value)
    return not (issecretvalue and issecretvalue(value))
end

local function PublicValue(value)
    if Public(value) then return value end
end

local function Read(reader, ...)
    if type(reader) ~= "function" then return end
    local ok, value, second, third, fourth = pcall(reader, ...)
    if ok then
        return PublicValue(value), PublicValue(second), PublicValue(third), PublicValue(fourth)
    end
end

-- Keep third-party metadata on one plain-text line and out of WoW's markup parser.
local function Metadata(value)
    if type(value) ~= "string" or #value > 160 or value:find("|", 1, true) then return end
    value = value:gsub("%c", " "):match("^%s*(.-)%s*$")
    if value ~= "" then return value end
end

local function AddValue(lines, name, value)
    if not Public(value) then return end
    if type(value) == "boolean" then value = value and "On" or "Off" end
    if type(value) == "number" and value > -math.huge and value < math.huge then value = tostring(value) end
    if type(value) == "string" and value ~= "" then lines[#lines + 1] = name .. ": " .. value end
end

-- These lists are the export boundary. Keep strings to known setting values
-- and never walk arbitrary SavedVariables, binding tables or CVar names.
local NUMERIC_CVARS = {
    "autoLootDefault", "autoLootRate", "lootUnderMouse", "softTargetInteract",
    "SoftTargetInteractArc", "SoftTargetInteractRange", "SoftTargetIconGameObject",
    "GamePadEnable", "cameraDistanceMaxZoomFactor", "cameraSmoothStyle",
    "Sound_EnableAllSound", "Sound_EnableSound", "Sound_EnableSFX", "Sound_EnableMusic",
    "Sound_EnableAmbience", "Sound_EnableDialog",
    "Sound_EnableSoundWhenGameIsInBG", "Sound_MasterVolume", "Sound_SFXVolume",
    "Sound_MusicVolume", "Sound_AmbienceVolume", "Sound_DialogVolume",
}
local MODIFIER_CVARS = { "GamePadEmulateAlt", "GamePadEmulateCtrl", "GamePadEmulateShift" }
local MODIFIER_VALUES = {
    none = true, PADLTRIGGER = true, PADRTRIGGER = true, PADLSHOULDER = true, PADRSHOULDER = true,
}
local ADDON_TOGGLES = {
    { "Auto open Fishing Bar", "autoOpenFishingBar" }, { "Auto equip gear", "autoEquipGear" },
    { "Auto equip lures", "autoEquipLures" }, { "Auto restore gear", "autoRestoreGear" },
    { "Camera Assist", "cameraAssist" }, { "Minimal cast view", "minimalFishingCastView" },
    { "Catch Recap", "catchRecap" }, { "Show minimap while fishing", "showFishingMinimap" },
    { "Focus splash sound", "soundFocus" }, { "Alert sounds", "enableAlertSounds" },
    { "Range sound repeat", "rangeSoundLoop" }, { "Recast reminder repeat", "recastReminderLoop" },
}
local ADDON_NUMBERS = {
    { "Range delay (s)", "rangeDelay" }, { "Recast delay (s)", "recastDelay" },
    { "Hook delay (s)", "hookDelay" }, { "Press lock (s)", "pressLock" },
    { "Recast reminder delay (s)", "recastReminderDelay" },
    { "Sound repeat interval (s)", "soundRepeatInterval" }, { "Voice volume", "voiceVolume" },
}
local ENABLE_STATE = { [0] = "Disabled", [1] = "Enabled for some characters", [2] = "Enabled" }
local FISHING_KEYS = {
    SPACE = true, TAB = true, BACKSPACE = true, ENTER = true, INSERT = true, DELETE = true,
    HOME = true, END = true, PAGEUP = true, PAGEDOWN = true, UP = true, DOWN = true,
    LEFT = true, RIGHT = true, MOUSEWHEELUP = true, MOUSEWHEELDOWN = true, DOUBLE_RIGHT_CLICK = true,
    PADDUP = true, PADDDOWN = true, PADDLEFT = true, PADDRIGHT = true, PADLSTICK = true, PADRSTICK = true,
    PADLSHOULDER = true, PADRSHOULDER = true, PADLTRIGGER = true, PADRTRIGGER = true,
}

local function FishingKey(key)
    if type(key) ~= "string" or #key > 48 then return end
    local base = key
    for _, prefix in ipairs({"ALT-", "CTRL-", "SHIFT-", "PADLTRIGGER-", "PADRTRIGGER-"}) do
        if base:sub(1, #prefix) == prefix then base = base:sub(#prefix + 1) end
    end
    if FISHING_KEYS[base] or base:match("^[A-Z0-9]$") or base:match("^F%d%d?$")
        or base:match("^BUTTON%d%d?$") or base:match("^PAD[1-4]$") or base:match("^NUMPAD%d$") then
        return key
    end
end

function FF:GetInstalledFishingVersion()
    local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return Metadata(Read(metadata, ADDON_NAME, "Version"))
end

function FF:BuildFishingBugReport()
    local addons = C_AddOns or {}
    local metadata = addons.GetAddOnMetadata or GetAddOnMetadata
    local version = self:GetInstalledFishingVersion()
    local client, build, _, interface = Read(GetBuildInfo)
    local lines = { "Forever Fishing diagnostics" }
    AddValue(lines, "Forever Fishing version", version)
    AddValue(lines, "WoW Forever version", Metadata(client))
    AddValue(lines, "WoW Forever build", type(build) == "number" and build or Metadata(build))
    AddValue(lines, "WoW interface", type(interface) == "number" and interface or Metadata(interface))

    lines[#lines + 1] = "\nWoW fishing settings"
    local cvar = (C_CVar and C_CVar.GetCVar) or GetCVar
    for _, name in ipairs(NUMERIC_CVARS) do
        local value = Read(cvar, name)
        if type(value) == "string" or type(value) == "number" then AddValue(lines, name, tonumber(value)) end
    end
    for _, name in ipairs(MODIFIER_CVARS) do
        local value = Read(cvar, name)
        if type(value) == "string" and MODIFIER_VALUES[value] then AddValue(lines, name, value) end
    end
    AddValue(lines, "Blizzard gamepad interface", Read(InputUtil and InputUtil.IsGamepadUIEnabled))

    lines[#lines + 1] = "\nForever Fishing settings"
    local db = self.db or {}
    for _, setting in ipairs(ADDON_TOGGLES) do
        local value = db[setting[2]]
        if Public(value) and type(value) == "boolean" then AddValue(lines, setting[1], value) end
    end
    for _, setting in ipairs(ADDON_NUMBERS) do
        local value = db[setting[2]]
        if Public(value) and type(value) == "number" then AddValue(lines, setting[1], value) end
    end
    if self.db then
        AddValue(lines, "Fishing Bar open", Read(self.IsFishingSessionOpen, self))
        AddValue(lines, "In combat", Read(InCombatLockdown))
        AddValue(lines, "Fishing audio recovery pending", Read(self.HasPendingSoundRecovery, self))
        AddValue(lines, "Gamepad Mode", Read(self.IsFishingGamepadMode, self))
        AddValue(lines, "Fishing key", FishingKey(Read(self.GetFishingInputKey, self)))
        AddValue(lines, "Fast Auto Loot", Read(self.IsFastNativeAutoLootEnabled, self))
        AddValue(lines, "Hide Blizzard UI", Read(self.GetBlizzardUIHideMode, self))
        AddValue(lines, "Fishing Bar orientation", Read(self.GetFishingBarOrientation, self))
        AddValue(lines, "Fishing Bar auto-collapse", Read(self.GetFishingBarAutoCollapse, self))
        local options = Read(self.GetFishingInformationOptions, self)
        if type(options) == "table" then
            AddValue(lines, "Fishing information", options.enabled)
            AddValue(lines, "Cast progress", options.progressMode)
            AddValue(lines, "Hide Blizzard cast bars", options.hideCastBars)
        end
    end

    local installed = {}
    local count = Read(addons.GetNumAddOns or GetNumAddOns)
    local getName = addons.GetAddOnName or addons.GetAddOnInfo or GetAddOnInfo
    if type(count) == "number" and count >= 0 and count < math.huge then
        for index = 1, count do
            local name = Metadata(Read(getName, index))
            if name and name:lower() ~= ADDON_NAME:lower() then
                local state
                if addons.GetAddOnEnableState then state = Read(addons.GetAddOnEnableState, index)
                else state = Read(GetAddOnEnableState, nil, index) end
                local otherVersion = Metadata(Read(metadata, index, "Version"))
                local status = type(state) == "number" and ENABLE_STATE[state]
                local row = name .. (otherVersion and (" — " .. otherVersion) or "")
                installed[#installed + 1] = row .. (status and (" [" .. status .. "]") or "")
            end
        end
    end
    if #installed > 0 then
        table.sort(installed, function(a, b) return a:lower() < b:lower() end)
        lines[#lines + 1] = "\nOther installed addons"
        for _, row in ipairs(installed) do lines[#lines + 1] = "- " .. row end
    end

    local url = BUG_FORM
    if version then
        local encoded = version:gsub("([^A-Za-z0-9._~-])", function(byte)
            return ("%%%02X"):format(byte:byte())
        end)
        url = url .. "&version=" .. encoded
    end
    return table.concat(lines, "\n"), url
end

