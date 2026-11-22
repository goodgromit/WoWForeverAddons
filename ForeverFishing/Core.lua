-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local addonName = ...
local FF = {}
_G.ForeverFishing = FF

local FISHING_SPELL = 131474
local FISHING_CAST = 131476
local MEDIA = "Interface\\AddOns\\ForeverFishing\\Media\\"
local ICON = MEDIA .. "Square"
local MACRO_NAME = "FF Fishing Cast"
local DEFAULT_FISHING_KEY = "SPACE"
-- Independent SavedVariables baselines. A public data-format change advances
-- only the data version; a public visual/settings reset advances only the UI version.
local DATA_SCHEMA_VERSION = 1
local UI_SCHEMA_VERSION = 6
local BACKGROUND_SOUND_CVAR = "Sound_EnableSoundWhenGameIsInBG"
local PET_SOUND_CVAR = "Sound_EnablePetSounds"
local BOBBER_PROBE_SECONDS = 0.05
local MISSING_CONFIRM_SECONDS = 0.2
local OTHER_TARGET_SETTLE_SECONDS = 0.75
local OTHER_TARGET_CONFIRM_SECONDS = 0.3
local UNKNOWN_TARGET_SETTLE_SECONDS = 1
local SOFT_BOBBER_CONFIRM_SECONDS = 0.3
local BIND_OWNER = CreateFrame("Frame", nil, WorldFrame, "SecureHandlerBaseTemplate")
local INTERACT_OWNER = CreateFrame("Frame", nil, WorldFrame, "SecureHandlerBaseTemplate")
local GLOBAL_BIND_OWNER
local events = CreateFrame("Frame", nil, WorldFrame)

FF.icon = ICON
FF.roundIcon = MEDIA .. "Round"
FF.lureIcon = MEDIA .. "LureNoBoarder"
FF.castbarIcon = MEDIA .. "Castbar"
FF.fishingGearIcon = MEDIA .. "Buttons\\FishingGear"
FF.fishingGearPurchaseIcon = MEDIA .. "Buttons\\FishingRodPurchase"
FF.lurePurchaseIcon = MEDIA .. "Buttons\\PurchaseLure"
FF.journalIcon = MEDIA .. "Buttons\\Journal"
FF.settingsIcon = MEDIA .. "Buttons\\Settings"
FF.doubleRightClickKey = "DOUBLE_RIGHT_CLICK"

-- Public UI upgrades reset replaceable settings only. Gear/lure choices,
-- minimap position, temporary CVar ownership records, and every earned fishing
-- record stay in the existing SavedVariables table.
local UI_SCHEMA_RESET_KEYS = {
    "key", "keyInitialized", "actionBindings", "gamepadMode", "gamepadBindings", "language", "showMinimapIcon", "interactAssist", "soundFocus", "soundFocusVolumes", "mutePets", "hideLureGlowWhenOutOfLures",
    "autoEquipGear", "autoEquipLures", "manualGearAndLures", "autoOpenFishingBar",
    "autoRestoreGear", "journalFaction", "campMilestones", "fastAutoLoot", "fastNativeAutoLoot", "fasterRecast", "catchRecap",
    "hideBlizzardUIWhileFishing", "blizzardUIHideMode", "fishingChatMode", "showFishingMinimap", "minimalFishingCastView",
    "position", "toolsPosition", "barScale", "toolsScale", "catchRecapPosition",
    "windowLayouts", "journalTextScale", "iconBarSpacing", "fishingBarMode", "lastCompactBarMode", "fishingBarOrientation", "fishingBarAutoCollapse", "flyoutGrid", "fishingInformation", "showUtilityButton", "utilityItems", "utilityHidden", "utilitySelectedItem", "flyoutLayouts", "flyoutDefaults",
    "layoutCoordinateVersion", "toolsIconCountVersion", "settingsLayoutVersion",
    "rangeSound", "rangeSoundLoop", "recastReminderSound", "recastReminderLoop",
    "recastReminderDelay", "catchConfirmedSound", "fishEscapedSound", "cookingCompleteSound", "fullBagsSound", "fullBagsSoundLoop",
    "enableAlertSounds", "soundRepeatInterval", "voiceVolume", "voiceVolumeDefaultVersion",
    "channelSound",
    "cameraAssist", "cameraModeDefaultsVersion", "cameraProfile", "cameraCloseScan",
    "cameraScanProfiles", "cameraSmartCloseLinkVersion", "cameraSavedView",
    "cameraSavedViewRecordVersion", "cameraFishingView", "cameraSmartBaseView",
    "cameraScanSpeed", "cameraSweepReach", "cameraSweepSpacing", "cameraSweepZoom",
    "cameraSweepTilt", "cameraSweepRows", "cameraSweepStart", "cameraPyramidStep",
    "cameraViewSlot", "cameraViewDelay", "cameraSmartAdjustment", "cameraSmartOffset",
    "cameraSmartTrigger", "cameraSmartSecondTrigger", "cameraSmartSecondOffset",
    "cameraMarkerHeight", "cameraMarkerStyle", "cameraMarkerStyleVersion",
    "cameraPyramidPath", "cameraRoundedTurns", "cameraRoundedDevOnly",
    "cameraRacetrackTurns", "cameraScanLogging", "cameraNativeCenter",
    "rangeDelay", "recastDelay", "hookDelay", "pressLock", "recastTimings", "cameraTimings",
    "timingDefaultsVersion", "cameraRecastDefaultsVersion", "cameraHookDefaultsVersion",
}

function FF:InitializeSavedVariableSchemaVersions(hadSavedState)
    local db = self.db
    if hadSavedState == nil then hadSavedState = next(db) ~= nil end
    if type(db.dataSchemaVersion) ~= "number" then
        db.dataSchemaVersion = DATA_SCHEMA_VERSION
    end
    local priorUI = db.uiSchemaVersion
    if type(priorUI) == "number" and priorUI >= UI_SCHEMA_VERSION then return end
    if hadSavedState then
        for _, key in ipairs(UI_SCHEMA_RESET_KEYS) do db[key] = nil end
    end
    db.uiSchemaVersion = UI_SCHEMA_VERSION
    return true -- Fresh settings or the existing public settings-reset boundary.
end

function FF:GetJournalFaction()
    local choice = self.db and self.db.journalFaction
    if choice == "Alliance" or choice == "Horde" then return choice end
    local playerFaction = UnitFactionGroup and UnitFactionGroup("player")
    return playerFaction == "Horde" and "Horde" or "Alliance"
end

function FF:SetJournalFaction(choice)
    if choice ~= "Auto" and choice ~= "Alliance" and choice ~= "Horde" then return end
    if self.db.journalFaction == choice then return end
    self.db.journalFaction = choice
    local settings = self.settingsPanel
    if settings and settings.journalFactionButton then settings.journalFactionButton:Refresh() end
    local journal = self.journalPanel
    if journal and journal:IsShown() and self.SelectJournalTab then
        self:SelectJournalTab(self.journalTab or "catch")
    end
end

function FF:GetFishingMinimapSnapshot()
    if self.dataResetPendingReload then return { self:LocalizedText("reset.reload-needed") } end
    if not self.db then return {} end
    local lines = {}
    local session = self.session
    if session and type(session.casts) == "number" and type(session.catches) == "number" then
        lines[#lines + 1] = FF:LocalizedText("minimap.session", session.catches, session.casts)
        if self.CurrentSessionSeconds then
            local seconds = math.floor(self:CurrentSessionSeconds())
            lines[#lines + 1] = FF:LocalizedText("minimap.rod-time", math.floor(seconds / 3600), math.floor(seconds / 60) % 60)
        end
    end
    local lifetime = self.db.lifetime
    if lifetime and type(lifetime.catchCount) == "number" then lines[#lines + 1] = FF:LocalizedText("minimap.lifetime", lifetime.catchCount) end
    local location = self.GetFishingLocation and self:GetFishingLocation()
    if location then lines[#lines + 1] = FF:LocalizedText("minimap.location", self:GetFishingLocationDisplay(location)) end
    local equipped = self.FishingRodEquippedNow and self:FishingRodEquippedNow()
    if equipped == true then
        local itemID = GetInventoryItemID and GetInventoryItemID("player", 16)
        local name = itemID and GetItemInfo and GetItemInfo(itemID)
        lines[#lines + 1] = FF:LocalizedText("minimap.pole", name or FF:LocalizedText("minimap.equipped"))
        local seconds = self:LureSeconds()
        lines[#lines + 1] = seconds and seconds > 0 and FF:LocalizedText("minimap.lure-time", math.floor(seconds / 60), math.floor(seconds) % 60)
            or seconds == 0 and FF:LocalizedText("minimap.lure-none") or FF:LocalizedText("minimap.lure-unavailable")
    elseif equipped == false then lines[#lines + 1] = FF:LocalizedText("minimap.pole-none") end
    if self.db.lure then
        local name = GetItemInfo and GetItemInfo(self.db.lure)
        lines[#lines + 1] = FF:LocalizedText("minimap.selected-lure", name or self:LocalizedText("common.item-id",self.db.lure))
    end
    return lines
end

FF.session = {} -- Initialized from Statistics.lua after SavedVariables are ready.
FF.active = false
FF.recastReady = false
FF.recastWindow = false
FF.hookReady = false
FF.lastChannelEnd = 0
FF.recentTransitions = {}
FF.timing = { rangeMin = 0.05, rangeMax = 1.5, rangeDefault = 0.05,
    recastMin = 0.1, recastMax = 4, recastDefault = 0.2,
    hookMin = 0.1, hookMax = 4, hookDefault = 0.2,
    pressMin = 0, pressMax = 1.5, pressDefault = 0.25 }
FF.rangeSoundChoices = {
    { id = "off", label = "Off", labelKey = "sound.off" },
    { id = "soft", label = "Battle.net notification", labelKey = "sound.soft", kit = "UI_BNET_TOAST", fallback = 18019 },
    { id = "ping", label = "Soft ping", labelKey = "sound.ping", kit = "MAP_PING", fallback = 3175 },
    { id = "chime", label = "Chime", labelKey = "sound.chime", kit = "ALARM_CLOCK_WARNING_3", fallback = 12889 },
    { id = "raid", label = "Raid warning", labelKey = "sound.raid", kit = "RAID_WARNING", fallback = 8959 },
    { id = "male", label = "Male Voice", labelKey = "sound.male", voice = "male", singleRangePreview = true },
    { id = "female", label = "Female Voice", labelKey = "sound.female", voice = "female", singleRangePreview = true },
}

local function ClampTenth(value, minimum, maximum, default)
    value = tonumber(value) or default
    if value ~= value then value = default end
    return math.floor(math.max(minimum, math.min(maximum, value)) * 10 + 0.5) / 10
end

local function ClampTwentieth(value, minimum, maximum, default)
    value = tonumber(value) or default
    if value ~= value then value = default end
    return math.floor(math.max(minimum, math.min(maximum, value)) * 20 + 0.5) / 20
end

-- Keep the flat timing fields as the active profile for the existing cast
-- state machine. Each mode owns its saved sliders independently.
function FF:SaveTimingProfile()
    local key = self.db.cameraAssist and "cameraTimings" or "recastTimings"
    local profile = self.db[key]
    if type(profile) ~= "table" then profile = {}; self.db[key] = profile end
    for _, field in ipairs({ "rangeDelay", "recastDelay", "hookDelay", "pressLock" }) do
        profile[field] = self.db[field]
    end
end

function FF:ActivateTimingProfile()
    local profile = self.db[self.db.cameraAssist and "cameraTimings" or "recastTimings"]
    if type(profile) ~= "table" then self:InitializeTimingProfiles(); return end
    for _, field in ipairs({ "rangeDelay", "recastDelay", "hookDelay", "pressLock" }) do
        self.db[field] = profile[field]
    end
end

function FF:InitializeTimingProfiles()
    local timing = self.timing
    if type(self.db.recastTimings) ~= "table" then
        -- Existing adjustments belong to the original recast rotation.
        self.db.recastTimings = { rangeDelay = self.db.rangeDelay, recastDelay = self.db.recastDelay,
            hookDelay = self.db.hookDelay, pressLock = self.db.pressLock }
    end
    if type(self.db.cameraTimings) ~= "table" then self.db.cameraTimings = {} end
    if self.db.cameraRecastDefaultsVersion ~= 1 then
        if tonumber(self.db.cameraTimings.recastDelay) == 1 then self.db.cameraTimings.recastDelay = 0.6 end
        self.db.cameraRecastDefaultsVersion = 1
    end
    if self.db.cameraHookDefaultsVersion ~= 1 then
        if tonumber(self.db.cameraTimings.hookDelay) == 1 then self.db.cameraTimings.hookDelay = 0.6 end
        self.db.cameraHookDefaultsVersion = 1
    end
    for _, key in ipairs({ "recastTimings", "cameraTimings" }) do
        local profile = self.db[key]
        local camera = key == "cameraTimings"
        profile.rangeDelay = camera and 0.2 or ClampTwentieth(profile.rangeDelay, timing.rangeMin, timing.rangeMax, timing.rangeDefault)
        profile.recastDelay = ClampTenth(profile.recastDelay, timing.recastMin, timing.recastMax, camera and 0.6 or timing.recastDefault)
        profile.hookDelay = ClampTenth(profile.hookDelay, timing.hookMin, timing.hookMax, camera and 0.6 or timing.hookDefault)
        profile.pressLock = ClampTwentieth(profile.pressLock, timing.pressMin, timing.pressMax, timing.pressDefault)
    end
    self:ActivateTimingProfile()
end

function FF:ResetTimingProfiles()
    self.db.recastTimings, self.db.cameraTimings = nil, nil
    self.db.rangeDelay, self.db.recastDelay = self.timing.rangeDefault, self.timing.recastDefault
    self.db.hookDelay, self.db.pressLock = self.timing.hookDefault, self.timing.pressDefault
    self:InitializeTimingProfiles()
end

function FF:SetRapidPressLock(value)
    if InCombatLockdown and InCombatLockdown() then return false end
    if issecretvalue and issecretvalue(value) then return false end
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then return false end
    self.db.pressLock = ClampTwentieth(value, self.timing.pressMin, self.timing.pressMax, self.timing.pressDefault)
    self:SaveTimingProfile()
    self:ApplyBindings()
    if self.SyncCastAction then self:SyncCastAction() end
    return true
end

function FF:CameraRecastReady()
    return self.db.cameraAssist and self.active and self.bobberCheckStartedAt
        and GetTime() - self.bobberCheckStartedAt >= (self.currentRecastDelay or self.db.recastDelay) or false
end

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then
        local name = C_Spell.GetSpellName(id)
        if name then return name end
    end
    if GetSpellInfo then return GetSpellInfo(id) end
end

-- Native recognition is independent of the selected addon language. Read
-- actual client names/identities; never translate a recognition key or action.
local function NativeText(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, value = pcall(fn, ...)
    if ok and not (issecretvalue and issecretvalue(value)) and type(value)=="string" and value~="" then return value end
end

function FF:GetNativeProfessionName(skillLineID, canonical)
    if skillLineID==356 then return self:FishingName() end
    local api=C_TradeSkillUI
    local name=NativeText(api and api.GetTradeSkillDisplayName,skillLineID)
    if name then return name end
    if GetProfessions and GetProfessionInfo then
        local ok,a,b,c,d,e,f=pcall(GetProfessions)
        if ok then
            local indices={a,b,c,d,e,f}
            for slot=1,6 do
                local index=indices[slot]
                if not (issecretvalue and issecretvalue(index)) and type(index)=="number" then
                    local valid,value,_,_,_,_,_,id=pcall(GetProfessionInfo,index)
                    if valid and not (issecretvalue and (issecretvalue(id) or issecretvalue(value)))
                        and id==skillLineID and type(value)=="string" and value~="" then return value end
                end
            end
        end
    end
    if skillLineID==185 then
        return NativeText(C_Spell and C_Spell.GetSpellName,2550) or NativeText(GetSpellInfo,2550) or canonical
    end
    return canonical
end

function FF:GetNativeErrorName(errorID)
    if issecretvalue and issecretvalue(errorID) then return end
    if type(errorID)~="number" or errorID<=0 or errorID>=math.huge or errorID~=math.floor(errorID) then return end
    return NativeText(GetGameMessageInfo,errorID)
end

function FF:MatchesNativeError(message, names, errorID)
    if issecretvalue and issecretvalue(message) then return false end
    if type(message)~="string" then return false end
    local identity=self:GetNativeErrorName(errorID)
    for _,name in ipairs(names) do
        if identity==name then return true end
        -- Retain native text fallback for custom/client-specific error identities.
        do
            local native=_G[name]
            if not (issecretvalue and issecretvalue(native)) and type(native)=="string" and native~="" then
                if message==native then return true end
                local pattern, fields=native:gsub("%%%d*%$?[sd]","\001")
                if fields>0 then
                    pattern=pattern:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])","%%%1"):gsub("\001",".+")
                    if message:match("^"..pattern.."$") then return true end
                end
            end
        end
    end
    return false
end

function FF:FishingName()
    if GetProfessions and GetProfessionInfo then
        local _, _, _, fishing = GetProfessions()
        if fishing then
            local name = GetProfessionInfo(fishing)
            if name and name ~= "" then return name end
        end
    end
    return SpellName(7620) or SpellName(FISHING_SPELL) or SpellName(FISHING_CAST) or _G.FISHING or "Fishing"
end

local function IsFishingChannel()
    if type(UnitChannelInfo) ~= "function" then return false, nil, nil, "unavailable" end
    local ok, name, _, _, started, ends, _, _, spellID = pcall(UnitChannelInfo, "player")
    if not ok then return false, nil, nil, "error" end
    local restricted = false
    if issecretvalue then
        if issecretvalue(name) then name, restricted = nil, true end
        if issecretvalue(spellID) then spellID, restricted = nil, true end
        if issecretvalue(started) then started, restricted = nil, true end
        if issecretvalue(ends) then ends, restricted = nil, true end
    end
    if spellID == FISHING_SPELL or spellID == FISHING_CAST or (type(name) == "string" and name == FF:FishingName()) then
        local function Seconds(value)
            local number = tonumber(value)
            if number and number == number and math.abs(number) ~= math.huge then return number / 1000 end
        end
        return true, Seconds(started), Seconds(ends), "fishing"
    end
    if restricted then return false, nil, nil, "restricted" end
    if name == nil and started == nil and ends == nil and spellID == nil then return false, nil, nil, "absent" end
    if type(name) == "string" and name ~= "" then return false, nil, nil, "other" end
    return false, nil, nil, "unknown"
end

function FF:IsFishingChannelActive()
    return IsFishingChannel()
end

local function SafeOutOfCombat()
    return not InCombatLockdown or not InCombatLockdown()
end

function FF:Print(message)
    print("|cffffc947Forever Fishing|r: " .. message)
end

function FF:RangeSoundChoice(id)
    for _, choice in ipairs(self.rangeSoundChoices) do
        if choice.id == id then return choice end
    end
end

function FF:PlayRangeSound(id)
    self:PreviewFishingSound("range", id)
end

function FF:WarnRangeOnce()
    self:SyncRangeSound()
end

local function SelectedFishingKey(self)
    if self.GetFishingInputKey then return self:GetFishingInputKey() end
    return self.db and not self.db.gamepadMode and self.db.key or nil
end

local function BindingAction(key)
    if key == FF.doubleRightClickKey then
        if not FF:DoubleClickArmed() then return "Double right click (waiting for first click)" end
        key = "BUTTON2"
    end
    if not key or not GetBindingAction then return "unknown" end
    local ok, action = pcall(GetBindingAction, key, true)
    if not ok or (issecretvalue and issecretvalue(action)) then return "unknown" end
    return type(action) == "string" and action ~= "" and action or "none"
end

local function ReadCVar(name)
    if not GetCVar then return nil end
    local ok, value = pcall(GetCVar, name)
    return ok and value or nil
end

-- Unknown identity is not proof of an out-of-range bobber. In Camera Assist,
-- offer the ordinary cursor-controlled search only after a full quiet second;
-- leave Recast mode and immediate native Interact recognition unchanged.
local function UnknownBobberState(self, now, label)
    self.cameraSoftBobberSince = nil
    self.bobberUnknownSince = self.bobberUnknownSince or now
    if self.db.cameraAssist and SafeOutOfCombat() and self.bobberCheckStartedAt
        and now - self.bobberCheckStartedAt >= UNKNOWN_TARGET_SETTLE_SECONDS
        and now - self.bobberUnknownSince >= UNKNOWN_TARGET_SETTLE_SECONDS then
        return "unavailable", label
    end
    return "unknown", label
end

local function ConfirmSoftBobber(self, now, label)
    self.bobberUnknownSince = nil
    -- A one-sample native target must not hide/recenter an unfinished search.
    -- Verified cursor acquisition still wins immediately in CameraAssist.
    if self.cameraAssistNeeded and not (self.cameraCast and self.cameraCast.bobberLocated) then
        self.cameraSoftBobberSince = self.cameraSoftBobberSince or now
        if now - self.cameraSoftBobberSince < SOFT_BOBBER_CONFIRM_SECONDS then
            return "landing", "confirming bobber target"
        end
    else self.cameraSoftBobberSince = nil end
    return "bobber", label
end

local function ReadSoftInteractFact(reader, unit)
    if type(reader) ~= "function" then return nil, "unavailable" end
    local ok, value = pcall(reader, unit or "softinteract")
    if not ok then return nil, "error" end
    if issecretvalue and issecretvalue(value) then return nil, "restricted" end
    return value, value == nil and "absent" or "readable"
end

local function CanDelegateDungeonReel(self)
    if self.db.cameraAssist or self.gamepadInputLeavingWorld or not SafeOutOfCombat()
        or type(IsInInstance) ~= "function" then return false end
    local ok, inside, kind = pcall(IsInInstance)
    if not ok or (issecretvalue and (issecretvalue(inside) or issecretvalue(kind)))
        or inside ~= true or kind ~= "party" then return false end
    -- A selected unit can take priority over the soft interaction target.
    if ReadSoftInteractFact(UnitExists, "target") ~= false then return false end
    local live, started, ends = IsFishingChannel()
    return live and (not started or started == self.castStart) and (not ends or ends > GetTime())
end

-- Fishing bobbers are game objects. On the Forever beta, UnitExists can be
-- false even while a bobber is selectable. UnitGUID distinguishes the tested
-- close cast (Fishing Bobber GUID) from a tested unhookable long cast (nil).
function FF:BobberInteractState()
    if not self.active then return "idle", "none" end
    local now = GetTime()
    local elapsed = self.bobberCheckStartedAt and now - self.bobberCheckStartedAt or 0
    if elapsed < BOBBER_PROBE_SECONDS then
        return "landing", "checking bobber"
    end
    local guid, guidState = ReadSoftInteractFact(UnitGUID)
    if guidState ~= "readable" and guidState ~= "absent" then
        self.bobberMissingSince = nil
        self.bobberBlockedSince = nil
        -- The native object predicate and a known exact name together can
        -- confirm a bobber even when the GUID itself cannot be used.
        if ReadSoftInteractFact(UnitIsGameObject) == true then
            local name, nameState = ReadSoftInteractFact(UnitName)
            if self:IsFishingBobberName(name, true, true) then
                return ConfirmSoftBobber(self, now, "known bobber name and game object")
            end
            if guidState == "restricted" and nameState == "restricted" and CanDelegateDungeonReel(self) then
                -- WoW resolves the object when the player presses Interact.
                -- The public object type does not prove a bobber's identity.
                return "restricted-reel", "game object identity restricted"
            end
        end
        return UnknownBobberState(self, now, "target identity unavailable")
    end
    -- The ordinary bobber is identified without a second API call on every
    -- status sample. Read its name only for other possible bobber types.
    if type(guid) == "string" and guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-") == "35591" then
        self.bobberMissingSince = nil
        self.bobberBlockedSince = nil
        -- One optional name read per login, only after the standard ID proves it.
        if not self.cameraBobberNameRead and self.RememberFishingBobberName then
            self.cameraBobberNameRead = true
            if type(UnitName) == "function" then
                local nameOK, bobberName = pcall(UnitName, "softinteract")
                if nameOK then self:RememberFishingBobberName(guid, bobberName) end
            end
        end
        -- Snapshot the native close-cast identity once, reusing this read.
        if not self.cameraAssistNeeded and self.cameraNativeReferenceCast ~= self.channelStartSerial
            and self.RecordNativeBobberReference then
            self:RecordNativeBobberReference(guid)
        end
        return ConfirmSoftBobber(self, now, "Fishing Bobber (35591)")
    end
    local name = ReadSoftInteractFact(UnitName)
    local label = name or (guid and "GUID available") or "none"
    -- A known NPC/player identity takes precedence over the name fallback.
    local nonGameObject = type(guid) == "string" and not guid:match("^GameObject%-")
    if not nonGameObject and self:IsFishingBobberName(name, true) then
        self.bobberMissingSince = nil
        self.bobberBlockedSince = nil
        return ConfirmSoftBobber(self, now, label)
    end
    self.cameraSoftBobberSince = nil
    -- An NPC can win soft targeting even when the bobber is closer. Confirm
    -- that it remains selected after the bobber has had time to land. Unknown
    -- game objects get a delayed Camera Assist fallback; their identity never
    -- establishes that a bobber was acquired or that it can be hooked.
    if nonGameObject then
        self.bobberUnknownSince = nil
        self.bobberMissingSince = nil
        self.bobberBlockedSince = self.bobberBlockedSince or now
        if elapsed >= math.max(self.currentRangeDelay or self.db.rangeDelay, OTHER_TARGET_SETTLE_SECONDS)
            and now - self.bobberBlockedSince >= OTHER_TARGET_CONFIRM_SECONDS then
            return "blocked", label, guid
        end
        return "landing", "waiting for bobber target"
    end
    self.bobberBlockedSince = nil
    if not guid then
        self.bobberUnknownSince = nil
        self.bobberMissingSince = self.bobberMissingSince or now
        local rangeDelay = self.currentRangeDelay or self.db.rangeDelay
        local confirmSeconds = math.min(MISSING_CONFIRM_SECONDS, math.max(BOBBER_PROBE_SECONDS, rangeDelay - BOBBER_PROBE_SECONDS))
        if elapsed < rangeDelay or now - self.bobberMissingSince < confirmSeconds then
            return "landing", "confirming no target"
        end
        return "missing", "none"
    end
    self.bobberMissingSince = nil
    return UnknownBobberState(self, now, label)
end

function FF:TraceTransition(message)
    local entries = self.recentTransitions
    entries[#entries + 1] = { at = GetTime(), message = message }
    if #entries > 8 then table.remove(entries, 1) end
end

function FF:GetFishingCastButton()
    return self.castActionButton or self.castButton
end

function FF:IsFishingSessionOpen()
    return self.bar and self.bar:IsShown() or false
end

-- Keep the handoff even with Faster Recast enabled so native loot can claim
-- its window when fishing identity is unreadable and Quick Recast keeps its guard.
function FF:FishingReelLootPending()
    local handoff = self.fishingReelLootHandoff
    return self.fishingReelLootWindow or (handoff and handoff.db == self.db and handoff.bar == self.bar
        and GetTime() < handoff.expires)
end

function FF:IsFasterRecastEnabled()
    return self.db and self.db.fasterRecast == true
end

function FF:FishingKeyReelLootPending()
    return self.fishingReelLootWindow or (not self:IsFasterRecastEnabled() and self:FishingReelLootPending())
end

function FF:RefreshFishingReelLootInput()
    if not self.db or not self:IsFishingSessionOpen() then return end
    if SafeOutOfCombat() then
        local key = SelectedFishingKey(self)
        local before = BindingAction(key)
        self:ApplyBindings()
        if self.SyncCastAction then self:SyncCastAction() end
        local after = BindingAction(key)
        if after ~= before then self:TraceTransition("reel/loot input refreshed; binding " .. after) end
    end
    if not self.active and self.UpdateIdleFishingStatus then self:UpdateIdleFishingStatus() end
end

function FF:SetFasterRecast(enabled)
    if not self.db or not SafeOutOfCombat() then return false end
    enabled = enabled == true
    local changed = self:IsFasterRecastEnabled() ~= enabled
    self.db.fasterRecast = enabled
    if changed then
        -- A pending native event belongs to the cast, even if its verification mode changes.
        local pending = self.fishingChannelStopPending
        self.fishingEmptyReel = nil
        self.fishingChannelStopPending = nil
        self.fishingChannelEndProbe, self.fishingChannelEndCheckAt = nil, nil
        if pending and self.active and pending.db == self.db and pending.serial == self.channelStartSerial
            and (not pending.bar or pending.bar == self.bar) then
            self:StopChannel(pending.reason, pending.guid, pending.spell)
        end
    end
    self:RefreshFishingReelLootInput()
    return true
end

local function WaitForFishingReelLoot(self)
    if self.fishingReelLootWindow or not (C_Timer and C_Timer.After) then return end
    local handoff = { db = self.db, bar = self.bar, expires = GetTime() + 0.25 }
    self.fishingReelLootHandoff = handoff
    C_Timer.After(0.25, function()
        if self.fishingReelLootHandoff ~= handoff then return end
        self.fishingReelLootHandoff = nil
        if self.db == handoff.db and self.bar == handoff.bar then self:RefreshFishingReelLootInput() end
    end)
end

function FF:BindingMode()
    if self:FishingKeyReelLootPending() then return "waiting for loot" end
    if self:CastInputLocked() then return "rapid press lock" end
    if not self.active then return "cast" end
    if self.db.cameraAssist and self.cameraAssistNeeded then
        if self.cameraAssistBobber and self.hookReady then return "camera mouseover" end
        if self:CameraRecastReady() then return "camera recast" end
        return self.cameraCast and self.cameraCast.bobberLocated and "camera waiting for cursor" or "camera scan"
    end
    if self.db.cameraAssist and self.recastReady then return "native bobber recast" end
    if self.db.cameraAssist and self.recastWindow then return "good cast recast" end
    if self:IsRestrictedFishingReelAvailable() then return "dungeon interact" end
    return self.nativeBobberReady and (not self.db.cameraAssist or self.hookReady) and "interact" or "settling"
end

function FF:IsRestrictedFishingReelAvailable()
    return self.active and self.restrictedFishingReel and not self.db.cameraAssist
        and not self.gamepadInputLeavingWorld and self.gamepadChordBindingOwner and SafeOutOfCombat()
end

function FF:ShowTrace()
    local channel, _, ends = IsFishingChannel()
    local remaining = channel and ends and string.format("%.1fs", math.max(0, ends - GetTime())) or "none"
    local traceSnapshot = self:CaptureFishingTraceSnapshot()
    local bobberState, bobberTarget = traceSnapshot.soft.state, traceSnapshot.soft.name or traceSnapshot.soft.identity
    local lureEntry
    for _, entry in ipairs(self.availableLures or {}) do
        if entry.id == self.db.lure then lureEntry = entry; break end
    end
    local lureButton = self.lureButton
    local lureMacro = lureButton and lureButton:GetAttribute("macro1")
    local lureBody = lureMacro and GetMacroBody and GetMacroBody(lureMacro)
    local castSlot = self:GetFishingCastButton() and self:GetFishingCastButton():GetAttribute("macro")
    local lines = {
        "Forever Fishing trace",
        self:FishingTraceEnvironment(),
        "Key: " .. (SelectedFishingKey(self) or "none"),
        "Fishing bar: " .. (self.bar and self.bar:IsShown() and "open" or "closed"),
        "Fishing mode: " .. (self.db.cameraAssist and "Camera-assisted backup" or "Native bobber interaction"),
        "Key action: " .. self:BindingMode(),
        "Actual key binding: " .. BindingAction(SelectedFishingKey(self)),
        "Cast macro: button slot " .. tostring(castSlot) .. "; verified slot " .. tostring(self:CastMacroIndex()),
        "Fishing channel remaining: " .. remaining,
        "Soft interact: " .. (ReadCVar("softTargetInteract") or "unknown"),
        "Interact arc: " .. (ReadCVar("SoftTargetInteractArc") or "unknown"),
        "Interact range: " .. (ReadCVar("SoftTargetInteractRange") or "unknown"),
        string.format("Range check delay: %.2fs", self.currentRangeDelay or self.db.rangeDelay),
        string.format((self.db.cameraAssist and "Recast delay: %.1fs" or "Good cast recast delay: %.1fs"), self.currentRecastDelay or self.db.recastDelay),
        string.format("Hook delay: %.1fs", self.currentHookDelay or self.db.hookDelay),
        string.format("Rapid press lock: %.2fs; %.2fs remaining", self.db.pressLock, self:CastInputLockRemaining()),
        self:RangeSoundTitle() .. ": " .. (self:RangeSoundChoice(self.db.rangeSound) or self.rangeSoundChoices[1]).label,
        "Recast reminder sound: " .. (self:RangeSoundChoice(self.db.recastReminderSound) or self.rangeSoundChoices[1]).label,
        "Catch confirmed sound: " .. (self:RangeSoundChoice(self.db.catchConfirmedSound) or self.rangeSoundChoices[1]).label,
        "Fish escaped sound: " .. (self:RangeSoundChoice(self.db.fishEscapedSound) or self.rangeSoundChoices[1]).label,
        "Alert sounds: " .. (self.db.enableAlertSounds and "on" or "off"),
        string.format("Recast reminder delay: %ds; repeat: %s", self.db.recastReminderDelay, self.db.recastReminderLoop and "on" or "off"),
        self:RangeSoundTitle() .. " repeat: " .. (self.db.rangeSoundLoop and "on" or "off"),
        string.format("Repeat interval: %g s", self.db.soundRepeatInterval),
        "Soft target snapshot (not readiness): " .. bobberState,
        "Soft interact target: " .. bobberTarget,
        "Camera assist: " .. (self.db.cameraAssist and (self.cameraAssistNeeded and
            ((self.cameraAssistBobber or (self.cameraCast and self.cameraCast.bobberLocated)) and "bobber found"
                or (self.cameraState == "RESTORE_HOME" and "returning view")
                or (self.cameraScanFailed and "scan failed/cancelled")
                or (self.cameraState == "PAUSED" and "paused")
                or (self.cameraSweepPreparation and "preparing view")
                or (self.cameraScanStarted and "scanning") or "waiting for cursor") or "waiting") or "off"),
        string.format("Scan speed: %.1fx; this cast: %.1fx", self.db.cameraScanSpeed, self.cameraHome and self.cameraHome.speed or self.db.cameraScanSpeed),
        "Rounded turns: " .. (self.db.cameraRoundedTurns and "on" or "off"),
        "Racetrack turns: " .. (self.db.cameraRacetrackTurns and "on" or "off"),
        "Scan profile: " .. self:CameraScanProfileName(),
        "Saved fishing view: " .. (self.db.cameraSavedView and "On" or "Off") .. "; " .. (self.cameraSavedViewStatus or "not prepared this login"),
        string.format("Sweep: zoom %.1f (achieved %s); home tilt %+.1f degrees; %.2f degree spacing; %d degrees each side; %d rows down; start %.2f degrees down",
            self.db.cameraSweepZoom, self.cameraSweepAchievedZoom and string.format("%.2f", self.cameraSweepAchievedZoom) or "not prepared",
            self.db.cameraSweepTilt, self.db.cameraSweepSpacing, self.db.cameraSweepReach, self.db.cameraSweepRows, self.db.cameraSweepStart),
        "Camera scan: step " .. tostring(self.cameraScanCompletedSteps or 0) .. "; other object samples " .. tostring(self.cameraScanObjectSamples or 0) .. "; last object " .. tostring(self.cameraScanLastObject or "none"),
        "Lure: " .. tostring(self.db.lure or "none") .. (self.db.lureManual and " (manual)" or " (automatic)"),
        "Lure bag slot: " .. (lureEntry and (lureEntry.bag .. "/" .. lureEntry.slot) or "none"),
        "Lure click: " .. (lureButton and ("type " .. tostring(lureButton:GetAttribute("type1")) .. "; macro " .. tostring(lureMacro) .. "; on key down " .. tostring(lureButton:GetAttribute("useOnKeyDown"))) or "button unavailable"),
        "Lure macro body: " .. (lureBody and lureBody:gsub("\n", " | ") or "none"),
        "Lure button error: " .. (self.lureMacroError or "none"),
        "Lure last click: " .. (self.lastLureClick and string.format("%.1fs ago; targeting %s", GetTime() - self.lastLureClick, tostring(self.lastLureTargeting)) or "none this login"),
        "Equipped main hand: " .. tostring(GetInventoryItemID and GetInventoryItemID("player", 16) or "none"),
        "",
        "Recent transitions (oldest first):",
    }
    if #self.recentTransitions == 0 then
        lines[#lines + 1] = "No fishing transitions this login."
    else
        for _, entry in ipairs(self.recentTransitions) do
            lines[#lines + 1] = string.format("%.1fs ago: %s", GetTime() - entry.at, entry.message)
        end
    end
    self:AppendFishingTraceSnapshot(lines, traceSnapshot)
    local report = table.concat(lines, "\n")
    if self.CameraDeveloperReport then report = report .. "\n\n" .. self:CameraDeveloperReport(false, true) end
    if self.ShowTraceWindow then self:ShowTraceWindow(report) else self:Print(report) end
end

-- Profession Fishing may not cast from a SecureActionButton spell attribute on
-- modern clients. Both the visible button and its key binding use a real /cast
-- macro so the cast input can be observed before the next press.
function FF:CastMacroIndex()
    if not GetMacroIndexByName or not GetMacroBody then return nil end
    local index = GetMacroIndexByName(MACRO_NAME)
    if not index or index <= 0 then return nil end
    local body = (GetMacroBody(index) or ""):match("^%s*(.-)%s*$")
    return body == "/cast " .. self:FishingName() and index or nil
end

function FF:EnsureCastMacro()
    if not GetMacroIndexByName or not GetMacroBody or not CreateMacro then return nil end
    local validIndex = self:CastMacroIndex()
    if validIndex then return validIndex end
    local index = GetMacroIndexByName(MACRO_NAME)
    if index and index > 0 then
        self:Print(FF:LocalizedText("runtime.macro-conflict", MACRO_NAME))
        return nil
    end
    if not SafeOutOfCombat() then return nil end
    local ok, result = pcall(CreateMacro, MACRO_NAME, 134400, "/cast " .. self:FishingName(), true)
    if ok and result then return self:CastMacroIndex() end
    self:Print(FF:LocalizedText("runtime.macro-slots-full"))
    return nil
end

-- Creating or deleting any character macro can renumber the secure button's
-- numeric macro slot. Never keep a slot unless it still contains our cast.
function FF:RefreshCastMacro()
    if not SafeOutOfCombat() then return end
    local index = self:CastMacroIndex()
    if index == self.castMacroIndex and (not self:GetFishingCastButton() or self:GetFishingCastButton():GetAttribute("macro") == index) then return end
    self.castMacroIndex = index
    if self.castButton then self:SyncCastAction() end
    if self.db then self:ApplyBindings() end
end

function FF:ShowStatus()
    local key = SelectedFishingKey(self)
    local channel, _, ends = IsFishingChannel()
    local remaining = channel and ends and string.format("%.1fs", math.max(0, ends - GetTime())) or "none"
    self:Print("Key " .. (key or "none") .. "; bar " .. (self.bar and self.bar:IsShown() and "open" or "closed") .. "; addon mode " .. self:BindingMode() .. "; actual binding " .. BindingAction(key) .. "; fishing channel " .. remaining .. ".")
    self:Print("Soft interact " .. (ReadCVar("softTargetInteract") or "unknown") .. "; arc " .. (ReadCVar("SoftTargetInteractArc") or "unknown") .. "; range " .. (ReadCVar("SoftTargetInteractRange") or "unknown") .. ".")
    self:Print(string.format("Rapid press lock %.2fs; range check %.2fs; good cast recast %.1fs; hook ready %.1fs after cast start.", self.db.pressLock, self.currentRangeDelay or self.db.rangeDelay, self.currentRecastDelay or self.db.recastDelay, self.currentHookDelay or self.db.hookDelay))
    self:Print(self:RangeSoundTitle() .. ": " .. (self:RangeSoundChoice(self.db.rangeSound) or self.rangeSoundChoices[1]).label .. ".")
    self:Print("Camera assist: " .. (self.db.cameraAssist and (self.cameraAssistNeeded and ((self.cameraAssistBobber or (self.cameraCast and self.cameraCast.bobberLocated)) and "bobber found" or (self.cameraScanFailed and "scan failed" or "scanning")) or "waiting") or "off") .. ".")
    local bobberState, bobberTarget = self:BobberInteractState()
    self:Print("Bobber interact state " .. bobberState .. "; soft interact target " .. bobberTarget .. ".")
end

function FF:ShowFishingReelTrace()
    local _, started, ends, channel = IsFishingChannel()
    local _, guidState = ReadSoftInteractFact(UnitGUID)
    local name, nameState = ReadSoftInteractFact(UnitName)
    local object, objectState = ReadSoftInteractFact(UnitIsGameObject)
    if object == true then objectState = "yes" elseif object == false then objectState = "no" end
    local instance = "unknown"
    if type(IsInInstance) == "function" then
        local ok, _, kind = pcall(IsInInstance)
        if ok and not (issecretvalue and issecretvalue(kind)) and type(kind) == "string" then instance = kind end
    end
    self:Print("Reel trace | instance " .. instance .. " | combat " .. (SafeOutOfCombat() and "no" or "yes")
        .. " | native channel " .. channel .. " | start/end " .. (started and "readable" or "unavailable")
        .. "/" .. (ends and "readable" or "unavailable") .. " | tracked " .. (self.active and "yes" or "no")
        .. " | binding " .. BindingAction(SelectedFishingKey(self)))
    local guard = self.lastFishingGuardAt and string.format("%.1fs ago", math.max(0, GetTime() - self.lastFishingGuardAt)) or "none"
    self:Print("Soft target | GUID " .. guidState .. " | name " .. nameState
        .. " | known bobber name " .. (self:IsFishingBobberName(name, true, true) and "yes" or "no")
        .. " | game object " .. objectState .. " | reel ready " .. (self.nativeBobberReady and "yes" or "no")
        .. " | dungeon fallback " .. (self:IsRestrictedFishingReelAvailable() and "yes" or "no")
        .. " | last guard press " .. guard)
    if #self.recentTransitions > 0 then
        self:Print("Recent fishing transitions (oldest first):")
        for _, entry in ipairs(self.recentTransitions) do
            self:Print(string.format("%.2fs ago: %s", math.max(0, GetTime() - entry.at), entry.message))
        end
    end
end

function FF:ToggleFishingRecastTrace()
    local trace = self.fishingLootTrace
    if trace then
        if not trace.recast then self:Print("Finish /fish loottrace before starting a recast trace."); return end
        self.fishingLootTrace = nil
        self.fishingRecastTraceFrame:SetScript("OnUpdate", nil)
        local report = "Forever Fishing recast trace\n" .. table.concat(trace, "\n")
        if self.ShowTraceWindow then
            self:ShowTraceWindow(report, "Recast trace", "Copy this report after the missed recast.")
        else
            self:Print(report)
        end
        return
    end
    if not self.db or not self:IsFishingSessionOpen() or SelectedFishingKey(self) ~= "SPACE" or not IsKeyDown then
        self:Print("Open the Fishing Bar with Space as the Fishing Key to trace a recast.")
        return
    end
    local db, bar, deadline = self.db, self.bar, GetTime() + 90
    trace = { started = GetTime(), recast = true }
    self.fishingLootTrace = trace
    self:TraceFishingLoot("Faster Recast " .. (self:IsFasterRecastEnabled() and "on" or "off"))
    self.fishingRecastTraceFrame = self.fishingRecastTraceFrame or CreateFrame("Frame")
    local wasDown
    self.fishingRecastTraceFrame:SetScript("OnUpdate", function(frame)
        if self.fishingLootTrace ~= trace then frame:SetScript("OnUpdate", nil); return end
        if self.db ~= db or self.bar ~= bar or not self:IsFishingSessionOpen()
            or SelectedFishingKey(self) ~= "SPACE" or GetTime() >= deadline then
            frame:SetScript("OnUpdate", nil)
            self:TraceFishingLoot("Space sampling ended. Use /fish recasttrace to view the report.")
            return
        end
        local ok, down = pcall(IsKeyDown, "SPACE", true)
        if not ok or (issecretvalue and issecretvalue(down)) then return end
        down = down == true
        local changed = wasDown ~= nil and down ~= wasDown
        wasDown = down
        if not changed or (GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()) then return end
        local _, _, _, channel = IsFishingChannel()
        self:TraceFishingLoot(string.format("Space %s | %s | %s | active %s | native %s | bobber %s | lock %.0f ms",
            down and "down" or "up", BindingAction("SPACE"), self:BindingMode(), self.active and "yes" or "no",
            channel, self.nativeBobberReady and "ready" or "unavailable", self:CastInputLockRemaining() * 1000))
    end)
    self:Print("Recast trace started. Reproduce the stall, then enter /fish recasttrace again to copy the report.")
end

local function SameCVarValue(a, b)
    if a == nil or b == nil then return false end
    if tostring(a) == tostring(b) then return true end
    local x, y = tonumber(a), tonumber(b)
    return x ~= nil and y ~= nil and math.abs(x - y) < 0.000001
end

local function ChangeCVar(name, value, snapshot)
    if not SetCVar then return end
    local old = ReadCVar(name)
    if not old or old == "" or SameCVarValue(old, value) then return end
    local ok = pcall(SetCVar, name, tostring(value))
    local applied = ok and ReadCVar(name)
    if SameCVarValue(applied, value) then
        local entry = snapshot[name]
        snapshot[name] = { old = type(entry) == "table" and entry.old or old, applied = applied }
    end
end

function FF:RestoreCVars(field)
    if field == "soundRestore" then
        self:SyncFishingPetSounds(true)
        return self:RestoreFocusSoundSnapshot()
    end
    local snapshot = self.db and self.db[field]
    if type(snapshot) ~= "table" then return end
    -- Interaction CVars can be protected in combat. pcall cannot suppress
    -- ADDON_ACTION_BLOCKED; retain the owned snapshot for regeneration/login.
    if field == "interactRestore" and not SafeOutOfCombat() then return end
    if SetCVar then
        for name, entry in pairs(snapshot) do
            if type(entry) == "table" and entry.old then
                local current = ReadCVar(name)
                if field == "bobberIconRestore" and (current == nil or current == "") then
                    -- Keep the old value until the client exposes this CVar.
                elseif SameCVarValue(current, entry.applied) then
                    local ok = pcall(SetCVar, name, entry.old)
                    if ok and SameCVarValue(ReadCVar(name), entry.old) then snapshot[name] = nil end
                else
                    -- Keep later changes made by the player or another addon.
                    snapshot[name] = nil
                end
            else snapshot[name] = nil end
        end
    end
    if not next(snapshot) then self.db[field] = nil end
end

function FF:SyncBackgroundFPS()
    if not self.db then return end
    if not self.bar or not self.bar:IsShown() then
        self:RestoreCVars("backgroundFPSRestore")
        return
    end
    if type(self.db.backgroundFPSRestore) == "table" then return end
    local enabled = ReadCVar("useMaxFPSBk")
    if enabled ~= nil and enabled ~= "" and tonumber(enabled) ~= 1 then return end
    local limit = tonumber(ReadCVar("maxFPSBk"))
    if not limit or limit <= 0 or limit >= 60 then return end
    local snapshot = {}
    ChangeCVar("maxFPSBk", 60, snapshot)
    if next(snapshot) then self.db.backgroundFPSRestore = snapshot end
end

local FAST_LOOT_RATE_CVAR = "autoLootRate"
local FAST_LOOT_RATE = 50
local FAST_LOOT_RATE_WINDOW = 1

local function ReadFastLootValue(reader, ...)
    if type(reader) ~= "function" then return end
    local ok, value = pcall(reader, ...)
    if ok and not (issecretvalue and issecretvalue(value)) then return value end
end

local function PolestarHandlesFastLoot()
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if ReadFastLootValue(isLoaded, "Polestar") ~= true then return false end
    local polestar = _G.Polestar
    local getter = not (issecretvalue and issecretvalue(polestar)) and type(polestar) == "table" and polestar.Get
    -- An unreadable setting on a loaded provider is not permission to compete.
    return ReadFastLootValue(getter, "qol.fastLoot") ~= false
end

local function OtherAddonHandlesFastLoot()
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    local exists = C_AddOns and C_AddOns.DoesAddOnExist
    return PolestarHandlesFastLoot() or (ReadFastLootValue(exists, "SpeedyAutoLoot") ~= false
        and ReadFastLootValue(isLoaded, "SpeedyAutoLoot") ~= false)
end

local function ReadFastLootRate(api)
    local value = ReadFastLootValue(api.GetCVar, FAST_LOOT_RATE_CVAR)
    local rate = tonumber(value)
    if rate and rate > 0 and rate < math.huge then return rate end
end

function FF:IsFastNativeAutoLootEnabled()
    return self.db ~= nil and (self.db.fastNativeAutoLoot == nil or self.db.fastNativeAutoLoot == true)
end

function FF:ReleaseFastAutoLootRate()
    local owner = self.fastAutoLootRateOwner
    if not owner then return end
    owner.releaseRequested = true
    if owner.busy then return end
    owner.busy = true
    local current = ReadFastLootRate(owner.api)
    -- On an unverified write, the original read can mean the client did not
    -- expose its temporary layer. Remove that attempt while it is still ours.
    if current == owner.applied or (owner.unverified and current == owner.original) then
        local ok, result = pcall(owner.api.RemoveTempCVar, FAST_LOOT_RATE_CVAR)
        if ok and result ~= false then
            owner.unverified = nil
            current = ReadFastLootRate(owner.api)
        else
            current = nil
        end
    end
    owner.busy = nil
    if current and current ~= owner.applied then
        self.fastAutoLootRateOwner = nil
    elseif not owner.retried and C_Timer and C_Timer.After then
        owner.retried = true
        pcall(C_Timer.After, 0.2, function()
            if self.fastAutoLootRateOwner == owner then self:ReleaseFastAutoLootRate() end
        end)
    end
end

function FF:ObserveFastAutoLoot(event, autoLoot, fromItem)
    local window = self.fastAutoLootWindow
    local first = not window
    if first then
        window = {}
        self.fastAutoLootWindow = window
    end
    if not (self.fastAutoLootRateOwner or self:IsFastNativeAutoLootEnabled()) then return end
    local automatic = not (issecretvalue and (issecretvalue(autoLoot) or issecretvalue(fromItem)))
        and autoLoot == true and fromItem ~= true
    if not automatic or ReadFastLootValue(IsFishingLoot) ~= true then
        window.cancelled = true
        self:ReleaseFastAutoLootRate()
        return
    end
    if event == "LOOT_OPENED" and self.fastAutoLootRateOwner and PolestarHandlesFastLoot() then
        window.cancelled = true
        self:ReleaseFastAutoLootRate()
        return
    end
    if not first or event ~= "LOOT_READY" or self.fastAutoLootRateOwner then return end
    if OtherAddonHandlesFastLoot() then
        window.cancelled = true
        self:TraceFishingLoot("Fast Auto Loot yielded to another addon")
        return
    end
    return window
end

local function TryFastFishingLootRate(self, window)
    local api, db, bar = C_CVar, self.db, self.bar
    if self.fastAutoLootWindow ~= window or window.cancelled or self.fastAutoLootRateOwner
        or not (self:IsFastNativeAutoLootEnabled() and bar and bar:IsShown() and SafeOutOfCombat()
        and api and type(api.GetCVarInfo) == "function" and type(api.SetTempCVar) == "function"
        and type(api.RemoveTempCVar) == "function" and C_Timer and type(C_Timer.After) == "function") then return end
    local ok, value, default, _, _, locked, secure, readOnly = pcall(api.GetCVarInfo, FAST_LOOT_RATE_CVAR)
    if not ok or (issecretvalue and (issecretvalue(value) or issecretvalue(default)
        or issecretvalue(locked) or issecretvalue(secure) or issecretvalue(readOnly)))
        or locked ~= false or secure ~= false or readOnly ~= false then return end
    local rate = ReadFastLootRate(api)
    if not rate or rate <= FAST_LOOT_RATE or rate ~= tonumber(value) or rate ~= tonumber(default)
        or ReadFastLootValue(IsFishingLoot) ~= true or self.fastAutoLootWindow ~= window or window.cancelled
        or self.db ~= db or not self:IsFastNativeAutoLootEnabled() or self.bar ~= bar or not bar:IsShown()
        or not SafeOutOfCombat() then return end

    -- Keep the native timing fallback for loot the early pass leaves to WoW.
    local owner = { api = api, original = rate, applied = FAST_LOOT_RATE, busy = true }
    self.fastAutoLootRateOwner = owner
    local applied, result = pcall(api.SetTempCVar, FAST_LOOT_RATE_CVAR, tostring(FAST_LOOT_RATE))
    local current = ReadFastLootRate(api)
    owner.busy = nil
    owner.unverified = applied and result ~= false and current ~= FAST_LOOT_RATE
    if current and current ~= rate then owner.applied = current end
    if not applied or result == false or current ~= FAST_LOOT_RATE or owner.releaseRequested
        or self.fastAutoLootWindow ~= window or window.cancelled then
        self:ReleaseFastAutoLootRate()
        return
    end
    local scheduled = pcall(C_Timer.After, FAST_LOOT_RATE_WINDOW, function()
        if self.fastAutoLootRateOwner == owner then self:ReleaseFastAutoLootRate() end
    end)
    if not scheduled then self:ReleaseFastAutoLootRate(); return end
    self:TraceTransition("fast auto-loot: temporary native rate applied")
end

local function IsOrdinaryFastLootRow(slot, observed)
    local itemSlotType = Enum and Enum.LootSlotType and Enum.LootSlotType.Item
    if not observed or itemSlotType == nil or ReadFastLootValue(GetLootSlotType, slot) ~= itemSlotType then return false end
    local ok, _, _, quantity, currency, quality, locked, quest, questID = pcall(GetLootSlotInfo, slot)
    if not ok or (issecretvalue and (issecretvalue(quantity) or issecretvalue(currency)
        or issecretvalue(quality) or issecretvalue(locked) or issecretvalue(quest) or issecretvalue(questID))) then return false end
    return ReadFastLootValue(GetLootSlotLink, slot) == observed.link
        and quantity == observed.quantity and (currency == nil or currency == 0)
        and (quality == 0 or quality == 1) and (locked == nil or locked == false)
        and (quest == nil or quest == false) and (questID == nil or questID == 0)
end

-- A capacity error has no loot-slot ID. Only consider it for a stable,
-- automatic window containing one positively identified ordinary item.
do
    local settleSeconds, errorWindow = 0.5, 2
    local errors = { "ERR_INV_FULL", "ERR_BAG_FULL", "ERR_INVENTORY_FULL" }

    function FF:InvalidateFishingCapacityRecast()
        local owner = self.fastAutoLootWindow
        if not owner then return end
        local capacity = owner.capacityRecast
        owner.capacityRecast = false
        if capacity and capacity.rejectedAt then self:RefreshFishingReelLootInput() end
    end

    local function NotifyBlockedFishingLoot(self)
        if self.PlayFishingBagsFullAlert then self:PlayFishingBagsFullAlert() end
        self:RefreshFishingReelLootInput()
    end

    function FF:ObserveFishingCapacityLoot(owner, event, automatic, window, snapshot)
        if not owner or self.fastAutoLootWindow ~= owner or owner.capacityRecast == false then return end
        local row = snapshot and snapshot.complete and snapshot.count == 1 and snapshot.rows[1]
        local previous = owner.capacityRecast
        if not automatic or not self.fishingReelLootWindow or not (row and row.quantity == 1)
            or not window or window ~= self.fishingLootWindow or window.snapshot ~= snapshot
            or window.cast ~= self.statsCast or window.db ~= self.db or not IsOrdinaryFastLootRow(1, row)
            or (previous and (previous.window ~= window or previous.row.link ~= row.link)) then
            self:InvalidateFishingCapacityRecast()
            return
        end
        local capacity = previous or { window = window, row = row, startedAt = GetTime(), bar = self.bar }
        owner.capacityRecast = capacity
        if event == "LOOT_OPENED" and not capacity.openedAt then
            capacity.openedAt = GetTime()
            if capacity.rejectedAt then NotifyBlockedFishingLoot(self) end
        end
    end

    local function CurrentCapacityLoot(self)
        local owner = self.fastAutoLootWindow
        local capacity = owner and owner.capacityRecast
        local window = capacity and capacity.window
        if not (window and window == self.fishingLootWindow and window.db == self.db
            and window.cast == self.statsCast and not window.cast.closed and capacity.bar == self.bar
            and self.fishingReelLootWindow and self:IsFishingSessionOpen()) then return end
        return capacity
    end

    local function CapacityRowStillOffered(row)
        return ReadFastLootValue(IsFishingLoot) == true
            and ReadFastLootValue(GetNumLootItems) == 1 and IsOrdinaryFastLootRow(1, row)
    end

    function FF:ObserveFishingCapacityError(message, errorID)
        local capacity = CurrentCapacityLoot(self)
        if not capacity or capacity.rejectedAt or not SafeOutOfCombat()
            or GetTime() - capacity.startedAt > errorWindow or self.gearOperation
            or not self:MatchesNativeError(message, errors, errorID)
            or not CapacityRowStillOffered(capacity.row)
            or not self:FishingItemHasNoBagRoom(capacity.row.id)
            or CurrentCapacityLoot(self) ~= capacity then return end
        capacity.rejectedAt = GetTime()
        self:TraceFishingLoot("Fishing loot blocked by bag capacity")
        if capacity.openedAt then NotifyBlockedFishingLoot(self) end
    end

    function FF:HasFishingCapacityRecast()
        local capacity = CurrentCapacityLoot(self)
        return self.capacityRecastButton and capacity and capacity.openedAt and capacity.rejectedAt and true or false
    end

    function FF:PrepareFishingCapacityRecast(button)
        if not SafeOutOfCombat() then return end
        button:SetAttribute("type", nil)
        if GetCurrentKeyBoardFocus then
            local ok, focus = pcall(GetCurrentKeyBoardFocus)
            if not ok or (issecretvalue and issecretvalue(focus)) or focus then return end
        end
        local capacity = CurrentCapacityLoot(self)
        local key = SelectedFishingKey(self)
        local now, previousPress = GetTime(), self.lastFishingGuardAt
        self.lastFishingGuardAt = now
        if not (key and capacity and capacity.openedAt and capacity.rejectedAt and not self.active)
            or now - math.max(capacity.openedAt, capacity.rejectedAt) < settleSeconds
            or (key:find("MOUSEWHEEL", 1, true) and previousPress and now - previousPress < settleSeconds)
            or self:CastInputLocked() or self.journalInputFocus or self.settingsKeyboardFocus
            or self.fishingResetInput or self.captureCommitPending or (self.capture and self.capture:IsShown())
            or self.journalBackBindingApplied or not self:FishingGamepadInputAvailable(true)
            or (self.BlizzardPanelOpen and self:BlizzardPanelOpen(false, LootFrame))
            or not LootFrame or not LootFrame:IsVisible() or LootFrame.isInEditMode
            or (key == self.doubleRightClickKey and not self:DoubleClickArmed())
            or not self:FishingGamepadBindingAvailable(key)
            or self:NextFishingAction() ~= "cast"
            or not CapacityRowStillOffered(capacity.row)
            or not self:FishingItemHasNoBagRoom(capacity.row.id)
            or CurrentCapacityLoot(self) ~= capacity or not SafeOutOfCombat() then return end
        -- The same physical press runs Blizzard's ordinary Fishing cast.
        -- A combat transition after PreClick must still leave it inert.
        button:SetAttribute("macrotext", "/cast [nocombat] " .. self:FishingName())
        button:SetAttribute("type", "macro")
        self.capacityRecastClickArmed = true
        self.castClickInProgress = true
        self.castClickChannelSerial = self.channelStartSerial or 0
        self:TraceFishingLoot("Fishing Key: recast with blocked loot")
    end

    function FF:FinishFishingCapacityRecast(button)
        if SafeOutOfCombat() then
            button:SetAttribute("type", nil)
            button:SetAttribute("macrotext", nil)
        end
        if not self.capacityRecastClickArmed then return end
        self.capacityRecastClickArmed = nil
        self.castClickAction, self.castClickArmed = "cast", true
        self:OnCastButtonPostClick()
    end
end

local function HasFastLootBagSpace(snapshot)
    local freeInBag = C_Container and C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots
    if type(freeInBag) ~= "function" then return false end
    -- Budget a generic slot per item as a conservative upper bound. Native
    -- pickup still handles partial stacks and specialty bags when space is tight.
    local needed = 0
    for _, row in pairs(snapshot.rows) do needed = needed + row.quantity end
    for bag = 0, 4 do
        local ok, free, family = pcall(freeInBag, bag)
        if ok and not (issecretvalue and (issecretvalue(free) or issecretvalue(family)))
            and family == 0 and type(free) == "number" and free >= 0 and free < math.huge then
            needed = needed - math.floor(free)
            if needed <= 0 then return true end
        end
    end
    return false
end

local function RequestEarlyFishingLoot(self, window, recorded, snapshot)
    local db, bar, cast = self.db, self.bar, self.statsCast
    local takeSlot = LootSlot
    if type(takeSlot) ~= "function" or not (Enum and Enum.LootSlotType and Enum.LootSlotType.Item)
        or not (snapshot and snapshot.complete and snapshot.count > 0 and recorded.cast == cast)
        or not SafeOutOfCombat() or not self:IsFishingSessionOpen()
        or not (self:IsFastNativeAutoLootEnabled() and self.fishingReelLootWindow) then return end
    if self.fishingLootWindow ~= recorded or recorded.snapshot ~= snapshot or not HasFastLootBagSpace(snapshot) then return end
    for slot = 1, snapshot.count do
        if not IsOrdinaryFastLootRow(slot, snapshot.rows[slot]) then return end
    end
    if ReadFastLootValue(GetNumLootItems) ~= snapshot.count or recorded.snapshot ~= snapshot then return end

    -- Descending slots remain valid when the client compacts earlier pickups.
    -- Native callbacks can close or change the window during a request.
    local logRequest = true
    for slot = snapshot.count, 1, -1 do
        local count = ReadFastLootValue(GetNumLootItems)
        if type(count) ~= "number" or count < slot or count > snapshot.count
            or OtherAddonHandlesFastLoot() or not IsOrdinaryFastLootRow(slot, snapshot.rows[slot])
            or ReadFastLootValue(IsFishingLoot) ~= true or not SafeOutOfCombat()
            or self.db ~= db or self.bar ~= bar or self.statsCast ~= cast or cast.closed
            or not self:IsFastNativeAutoLootEnabled() or not bar:IsShown()
            or self.fastAutoLootWindow ~= window or window.cancelled or self.fishingLootWindow ~= recorded then return end
        if logRequest then
            self:TraceFishingLoot("Fast Auto Loot: early slot pass")
            logRequest = false
        end
        local ok, result = pcall(takeSlot, slot)
        if not ok or result == false then return end
    end
end

function FF:SetFastNativeAutoLoot(enabled)
    self.db.fastNativeAutoLoot = enabled == true
    if not self.db.fastNativeAutoLoot then self:ReleaseFastAutoLootRate() end
end

function FF:SyncAutoLoot()
    if not self.db then return end
    local shown = self.bar and self.bar:IsShown()
    if not shown then
        self:ReleaseFastAutoLootRate()
        self:RestoreCVars("autoLootRestore")
        return
    end
    if type(self.db.autoLootRestore) == "table" then return end
    if tonumber(ReadCVar("autoLootDefault")) ~= 0 then return end
    local snapshot = {}
    ChangeCVar("autoLootDefault", 1, snapshot)
    if next(snapshot) then self.db.autoLootRestore = snapshot end
end

-- The icon is a bar-owned native interaction aid. Keep its original value in
-- the same recoverable CVar format as the other temporary fishing settings.
function FF:SyncBobberInteractIcon()
    if not self.db then return end
    if not self.bar or not self.bar:IsShown() then
        self:RestoreCVars("bobberIconRestore")
        return
    end
    local name = "SoftTargetIconGameObject"
    local current = ReadCVar(name)
    if current == nil or current == "" then return end
    local snapshot = self.db.bobberIconRestore
    local entry = type(snapshot) == "table" and snapshot[name]
    if type(entry) == "table" then
        if SameCVarValue(current, entry.applied) then return end
        -- A changed value is now the player's preference, not our old one.
        snapshot[name] = nil
        self.db.bobberIconRestore = nil
    end
    if SameCVarValue(current, 1) or not SetCVar then return end
    snapshot = { [name] = { old = current, applied = "1" } }
    self.db.bobberIconRestore = snapshot -- arm before the native callback
    pcall(SetCVar, name, "1")
    if self.db.bobberIconRestore ~= snapshot then return end
    local applied = ReadCVar(name)
    if applied ~= nil and applied ~= "" and not SameCVarValue(applied, 1) then
        self.db.bobberIconRestore = nil
    end
end

function FF:SyncLongRangeCameraDistance()
    if not self.db then return end
    if self.db.cameraProfile ~= "standard" then
        self:RestoreCVars("cameraDistanceRestore")
        return
    end
    local snapshot = self.db.cameraDistanceRestore
    local entry = type(snapshot) == "table" and snapshot.cameraDistanceMaxZoomFactor
    if type(entry) == "table" and SameCVarValue(ReadCVar("cameraDistanceMaxZoomFactor"), entry.applied) then return end
    -- A later change is the new preference to restore after this scan path.
    self.db.cameraDistanceRestore = nil
    snapshot = {}
    ChangeCVar("cameraDistanceMaxZoomFactor", 2, snapshot)
    if next(snapshot) then self.db.cameraDistanceRestore = snapshot end
end

-- One calibrated projection for all fishing paths; never enforce it per frame.
FF.fishingFOVTarget = 90
local function FOVNumber(value)
    if issecretvalue and issecretvalue(value) then return nil end
    if type(value) ~= "number" and type(value) ~= "string" then return nil end
    local number = tonumber(value)
    if number and number == number and math.abs(number) ~= math.huge then return number end
end
local function FOVEntry(self)
    local snapshot = self.db and self.db.cameraFOVRestore
    if issecretvalue and issecretvalue(snapshot) then return end
    if type(snapshot) ~= "table" then return end
    local entry = rawget(snapshot, "cameraFov")
    if issecretvalue and issecretvalue(entry) then return end
    if type(entry) == "table" then return FOVNumber(rawget(entry, "old")), FOVNumber(rawget(entry, "applied")) end
end
local function WantsFishingFOV(self)
    return self.db and self.db.cameraAssist and self.bar and self.bar:IsShown()
end
local function NPCCameraActive()
    if issecretvalue and (issecretvalue(C_PlayerInteractionManager) or issecretvalue(Enum)) then return false end
    local api = type(C_PlayerInteractionManager) == "table" and rawget(C_PlayerInteractionManager, "IsInteractingWithNpcOfType")
    local kinds = type(Enum) == "table" and rawget(Enum, "PlayerInteractionType")
    if issecretvalue and issecretvalue(kinds) then return false end
    if type(api) ~= "function" or type(kinds) ~= "table" then return false end
    for _, name in ipairs({ "Gossip", "QuestGiver" }) do
        local kind = FOVNumber(rawget(kinds, name))
        if kind then
            local ok, active = pcall(api, kind)
            if ok and not (issecretvalue and issecretvalue(active)) and active == true then return true end
        end
    end
    return false
end
function FF:RelinquishFishingFOV()
    local old, applied = FOVEntry(self)
    if not old or not applied then return end
    local actual = self:ReadFishingFOV()
    if old and applied and actual and math.abs(actual - applied) > 0.0001 then
        self.db.cameraFOVRestore = nil
        self.cameraFOVState = { original = old, requested = self.fishingFOVTarget, achieved = actual, status = "external change; relinquished" }
    end
end
function FF:ReleaseFishingFOV(force)
    if not self.db or self.cameraOwnFOV then return end
    if not force and self.cameraCenteredReturn and self.cameraEndSessionAfterRestore then
        self.fishingFOVReleasePending = true
        return
    end
    self.fishingFOVReleasePending = nil
    local old, applied = FOVEntry(self)
    if not old or not applied then self.db.cameraFOVRestore = nil; return end
    local actual = self:ReadFishingFOV()
    if not actual then return end -- Preserve recovery metadata until readable.
    if math.abs(actual - applied) > 0.0001 then self:RelinquishFishingFOV(); return end
    self.cameraOwnFOV = true
    -- World/combat cancellation must not leave old motion under restored FOV.
    if self.cameraHome and self.cameraHome.valid then self:InvalidateScanHome("Fishing FOV released") end
    self:WriteFishingFOV(old)
    actual = self:ReadFishingFOV()
    self.cameraOwnFOV = nil
    if actual and math.abs(actual - old) < 0.0001 then
        self.db.cameraFOVRestore = nil
        self.cameraFOVState = { original = old, requested = self.fishingFOVTarget, achieved = actual, status = "restored" }
    elseif actual and math.abs(actual - applied) > 0.0001 then self:RelinquishFishingFOV() end
end
function FF:SyncFishingFOV()
    if not self.db or self.cameraOwnFOV then return false end
    if not WantsFishingFOV(self) then self:ReleaseFishingFOV(); return true end
    if not self.ReadFishingFOV then return true end
    self.fishingFOVReleasePending = nil
    if NPCCameraActive() then
        self.cameraFOVState = { requested = self.fishingFOVTarget, status = "NPC interaction active; deferred" }
        return false
    end
    local actual = self:ReadFishingFOV()
    local old, applied = FOVEntry(self)
    if not actual then
        self.cameraFOVState = { original = old, requested = self.fishingFOVTarget, status = "unavailable; unverified" }
        return true -- Optional API absence must not disable otherwise working fishing.
    end
    if old and applied then self:RelinquishFishingFOV() end
    if math.abs(actual - self.fishingFOVTarget) < 0.0001 then
        self.cameraFOVState = { original = old or actual, requested = self.fishingFOVTarget, achieved = actual,
            status = old and applied and "owned" or "already calibrated" }
        return true
    end
    if InCombatLockdown and InCombatLockdown() then return false end
    -- Arm before the native call so a reentrant bar close can restore safely.
    local snapshot = { cameraFov = { old = tostring(actual), applied = tostring(self.fishingFOVTarget) } }
    self.db.cameraFOVRestore = snapshot
    self.cameraOwnFOV = true
    self:WriteFishingFOV(self.fishingFOVTarget)
    self.cameraOwnFOV = nil
    local achieved = self:ReadFishingFOV()
    if self.db.cameraFOVRestore ~= snapshot or not WantsFishingFOV(self) then self:ReleaseFishingFOV(true); return false end
    self.cameraFOVState = { original = actual, requested = self.fishingFOVTarget, achieved = achieved, status = "write unverified" }
    if achieved and math.abs(achieved - self.fishingFOVTarget) < 0.0001 then
        self.cameraFOVState.status = "owned"
        self:CheckCameraEnvironment("fishing FOV prepared")
        return true
    end
    self:ReleaseFishingFOV(true)
    return false
end

function FF:AutoLootCVarChanged(name)
    if (issecretvalue and issecretvalue(name)) or type(name) ~= "string" then return end
    name = name:lower()
    if name == "autolootrate" then
        local owner = self.fastAutoLootRateOwner
        if owner and not owner.busy then
            local current = ReadFastLootRate(owner.api)
            if self.fastAutoLootRateOwner == owner and current and current ~= owner.applied
                and (not owner.unverified or current ~= owner.original) then
                self.fastAutoLootRateOwner = nil
            end
        end
        return
    end
    if name ~= "autolootdefault" then return end
    local snapshot = self.db and self.db.autoLootRestore
    if type(snapshot) ~= "table" then return end
    local entry = snapshot.autoLootDefault
    if type(entry) == "table" and not SameCVarValue(ReadCVar("autoLootDefault"), entry.applied) then
        -- A later change to the player's setting ends our ownership of it.
        self.db.autoLootRestore = nil
    end
end

function FF:PrepareInteract()
    if self.db.interactAssist == false or not SafeOutOfCombat() then return end
    -- A newer channel may inherit a restore deferred by combat. Keep its
    -- original baseline only while the corresponding applied value is ours.
    local snapshot = type(self.db.interactRestore) == "table" and self.db.interactRestore or {}
    for name, entry in pairs(snapshot) do
        if type(entry) ~= "table" or not SameCVarValue(ReadCVar(name), entry.applied) then
            snapshot[name] = nil
        end
    end
    local flags = Enum and Enum.SoftTargetEnableFlags
    ChangeCVar("softTargetInteract", flags and flags.Any or 3, snapshot)
    local arc = tonumber(ReadCVar("SoftTargetInteractArc"))
    if arc and arc < 2 then ChangeCVar("SoftTargetInteractArc", 2, snapshot) end
    local range = tonumber(ReadCVar("SoftTargetInteractRange"))
    if range and range < 30 then ChangeCVar("SoftTargetInteractRange", 30, snapshot) end
    self.db.interactRestore = next(snapshot) and snapshot or nil
end

-- One logical bar session owns the temporary mix; preferences are independent.
local function FocusMixVolume(self, name, fallback)
    local profile = self.db and self.db.soundFocusVolumes
    local value = type(profile) == "table" and tonumber(profile[name])
    if not value or value ~= value or value == math.huge or value == -math.huge then return fallback or 0 end
    return math.max(0, math.min(1, value))
end

local function RememberFocusVolume(self, name, value)
    if not self.db then return end
    local profile = self.db.soundFocusVolumes
    if type(profile) ~= "table" then profile = {}; self.db.soundFocusVolumes = profile end
    profile[name] = value
end

local function SoundValue(name, value)
    if (issecretvalue and issecretvalue(value)) or (type(value) ~= "string" and type(value) ~= "number") then return end
    if value == "true" then value = "1" elseif value == "false" then value = "0" end
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge or number < 0 or number > 1 then return end
    return tostring(value)
end

local function ReadSoundValue(name) return SoundValue(name, ReadCVar(name)) end
local function SoundNow() return GetTime and GetTime() or 0 end
local function SoundWanted(self)
    return not not (self.db and self.db.soundFocus and self.bar and self.bar:IsShown() and not self.soundAlertsSuspended)
end
local function PetSoundsWanted(self)
    return not not (self.db and self.db.mutePets == true and self.bar and self.bar:IsShown()
        and not self.soundAlertsSuspended)
end
local function SoundOwnerCurrent(self, owner)
    return self[owner.slot] == owner and self.db == owner.db and self.bar == owner.bar
end
local function SoundWrite(self, name, value)
    local previous = self.changingSplashCVars
    self.changingSplashCVars = true
    local ok = SetCVar and pcall(SetCVar, name, value)
    self.changingSplashCVars = previous
    return ok
end
local function SoundOwner(self, wanted, fresh, pet)
    local slot = pet and "petSoundOwner" or "soundFocusOwner"
    local field = pet and "petSoundRestore" or "soundRestore"
    local owner = self[slot]
    if fresh or not owner or owner.db ~= self.db or owner.bar ~= self.bar or owner.wanted ~= wanted then
        if owner and owner.timer then owner.timer:Cancel() end
        owner = {db=self.db, bar=self.bar, slot=slot, field=field, pet=pet, wanted=wanted,
            pending={}, targets={}, remember={}, attempts=0}
        self[slot] = owner
    end
    if not pet then self.soundFocusSession = wanted and true or nil end
    return owner
end
local function SoundSnapshot(self, owner)
    local snapshot = self.db[owner.field]
    if type(snapshot) ~= "table" then snapshot = {}; self.db[owner.field] = snapshot end
    return snapshot
end
local function PruneSoundSnapshot(self, owner, snapshot)
    if self.db and self.db[owner.field] == snapshot and not next(snapshot) then self.db[owner.field] = nil end
end
local function ClearPendingWrite(entry)
    entry.pendingTarget, entry.pendingUntil, entry.profileTarget = nil, nil, nil
end

local PROFILE_SOUND_VOLUMES = {
    Sound_MasterVolume = true, Sound_MusicVolume = true,
    Sound_AmbienceVolume = true, Sound_DialogVolume = true,
}
local function RememberSoundWrite(self, owner, name, entry, current)
    if not PROFILE_SOUND_VOLUMES[name] then return end
    local target = SoundValue(name, entry.profileTarget)
    if target and SameCVarValue(current, target) then
        -- A real slider choice may be acknowledged after Close/Off replaces
        -- the transient owner. The request receipt still proves that choice.
        RememberFocusVolume(self, name, tonumber(current))
        if SameCVarValue(current, owner.remember[name]) then owner.remember[name] = nil end
    end
end

-- applied always means observed native state. The optional pending target is
-- persisted before a request, so a delayed/unknown acknowledgement keeps old.
local function SettleSoundWrite(self, owner, snapshot, name, entry, current)
    if not entry.pendingTarget then return true end
    if SameCVarValue(current, entry.pendingTarget) then
        RememberSoundWrite(self, owner, name, entry, current)
        entry.applied = current
        ClearPendingWrite(entry)
        return true
    end
    if not current then owner.pending[name] = "read"; return false end
    if not SameCVarValue(current, entry.applied) then
        snapshot[name], owner.pending[name], owner.remember[name] = nil, nil, nil
        return false -- A readable later change wins.
    end
    local deadline = tonumber(entry.pendingUntil)
    if not deadline or deadline > SoundNow() + 1.5 then deadline = SoundNow() + 1.5; entry.pendingUntil = deadline end
    if SoundNow() < deadline then owner.pending[name] = "settling"; return false end
    ClearPendingWrite(entry)
    return true -- The bounded acknowledgement window expired unchanged.
end

local function ApplySoundValue(self, owner, name, target)
    local snapshot = SoundSnapshot(self, owner)
    local entry, current = snapshot[name], ReadSoundValue(name)
    if type(entry) == "table" and entry.pendingTarget then
        if not SettleSoundWrite(self, owner, snapshot, name, entry, current) then PruneSoundSnapshot(self, owner, snapshot); return end
        entry = snapshot[name]
    end
    if not current then owner.pending[name] = "read"; PruneSoundSnapshot(self, owner, snapshot); return end
    if entry then
        if type(entry) ~= "table" or not SoundValue(name, entry.old) or not SoundValue(name, entry.applied) then
            owner.pending[name] = "record"; return
        end
        if not SameCVarValue(current, entry.applied) then snapshot[name], entry = nil, nil end
    end
    if name == "Sound_SFXVolume" and not entry then
        target = math.max(tonumber(current),0.9);owner.targets[name] = target
    end
    if SameCVarValue(current, target) then
        owner.pending[name] = nil
        if owner.remember[name] then RememberFocusVolume(self, name, tonumber(current)); owner.remember[name] = nil end
        PruneSoundSnapshot(self, owner, snapshot)
        return
    end
    entry = entry or {old=current, applied=current}
    snapshot[name] = entry
    entry.pendingTarget, entry.pendingUntil = tostring(target), SoundNow() + 1.5
    entry.profileTarget = owner.remember[name] and tostring(owner.remember[name]) or nil
    local ok = SoundWrite(self, name, tostring(target))
    if not SoundOwnerCurrent(self, owner) then return end
    local applied = ReadSoundValue(name)
    if SameCVarValue(applied, target) then
        RememberSoundWrite(self, owner, name, entry, applied)
        entry.applied = applied; ClearPendingWrite(entry); owner.pending[name] = nil
        if owner.remember[name] then RememberFocusVolume(self, name, tonumber(applied)); owner.remember[name] = nil end
    elseif not applied then owner.pending[name] = "read"
    elseif not ok then
        ClearPendingWrite(entry)
        if SameCVarValue(entry.old, entry.applied) then snapshot[name] = nil end
        owner.pending[name] = "apply"
    elseif applied and not SameCVarValue(applied, current) then
        snapshot[name], owner.pending[name], owner.remember[name] = nil, nil, nil
    else owner.pending[name] = "settling" end
    PruneSoundSnapshot(self, owner, snapshot)
end

function FF:HasPendingSoundRecovery()
    local function Pending(owner, wanted, field)
        local snapshot = self.db and self.db[field]
        return owner and owner.db == self.db and next(owner.pending)
            or not wanted and type(snapshot) == "table" and next(snapshot)
    end
    return not not (Pending(self.soundFocusOwner, SoundWanted(self), "soundRestore")
        or Pending(self.petSoundOwner, PetSoundsWanted(self), "petSoundRestore"))
end

local function RefreshSoundRecovery(self)
    if self.RefreshGameSoundSliders then self:RefreshGameSoundSliders()
    elseif self.RefreshSoundRecoveryControl then self:RefreshSoundRecoveryControl() end
end

local SOUND_RECOVERY_DELAYS = {0.15, 0.4, 1.0}
local RestoreSoundValues
function FF:QueueSoundRecovery(owner)
    if not SoundOwnerCurrent(self, owner) then return end
    if not next(owner.pending) then
        if owner.timer then owner.timer:Cancel(); owner.timer = nil end
        owner.notified = nil
        RefreshSoundRecovery(self)
        return
    end
    RefreshSoundRecovery(self)
    if owner.timer then return end
    local delay = SOUND_RECOVERY_DELAYS[owner.attempts + 1]
    if not delay then
        if not owner.notified and self.LocalizedText and self.Print then
            owner.notified = true
            self:Print(self:LocalizedText("sound.recovery.pending"))
        end
        return
    end
    if not (C_Timer and C_Timer.NewTimer) then return end
    owner.timer = C_Timer.NewTimer(delay, function()
        owner.timer = nil
        local wanted
        if owner.pet then wanted = PetSoundsWanted(self) else wanted = SoundWanted(self) end
        if not SoundOwnerCurrent(self, owner) or wanted ~= owner.wanted then return end
        owner.attempts = owner.attempts + 1
        if owner.compatibilityPending then self:FocusSplashSound(); return end
        if owner.wanted then
            local names = {}
            for name in pairs(owner.pending) do names[#names+1] = name end
            for _, name in ipairs(names) do
                if not SoundOwnerCurrent(self, owner) then return end
                if owner.pending[name] and owner.targets[name] ~= nil then ApplySoundValue(self, owner, name, owner.targets[name]) end
            end
            self:QueueSoundRecovery(owner)
        elseif owner.pet then RestoreSoundValues(self, owner)
        else self:RestoreFocusSoundSnapshot() end
    end)
end

RestoreSoundValues = function(self, owner)
    local snapshot = self.db[owner.field]
    if type(snapshot) ~= "table" then owner.pending = {}; self:QueueSoundRecovery(owner); return end
    for name, entry in pairs(snapshot) do
        if not SoundOwnerCurrent(self, owner) then return end
        local current = type(name) == "string" and ReadSoundValue(name)
        if type(entry) ~= "table" or type(name) ~= "string" or not SoundValue(name, entry.old) or not SoundValue(name, entry.applied) then
            owner.pending[name] = "record" -- Preserve a recoverable original; never guess its value.
        elseif SettleSoundWrite(self, owner, snapshot, name, entry, current) and snapshot[name] == entry then
            if not current then owner.pending[name] = "read"
            elseif SameCVarValue(current, entry.old) then snapshot[name], owner.pending[name] = nil, nil
            elseif SameCVarValue(current, entry.applied) then
                local ok = SoundWrite(self, name, entry.old)
                if not SoundOwnerCurrent(self, owner) then return end
                local restored = ReadSoundValue(name)
                if SameCVarValue(restored, entry.old) then snapshot[name], owner.pending[name] = nil, nil
                elseif restored and not SameCVarValue(restored, entry.applied) then snapshot[name], owner.pending[name] = nil, nil
                else owner.pending[name] = ok and "restore" or "write" end
            else snapshot[name], owner.pending[name] = nil, nil end
        end
    end
    PruneSoundSnapshot(self, owner, snapshot)
    self:QueueSoundRecovery(owner)
end

function FF:RestoreFocusSoundSnapshot(fresh)
    if not self.db then return end
    local owner = SoundOwner(self, false, fresh)
    if self.PrepareFocusAudioCompatibility and not self:PrepareFocusAudioCompatibility() then
        owner.compatibilityPending, owner.pending.compatibility = true, "handoff"
        self:QueueSoundRecovery(owner)
        return
    end
    owner.compatibilityPending, owner.pending.compatibility = nil, nil
    RestoreSoundValues(self, owner)
end

function FF:SyncFishingPetSounds(release, fresh)
    if not self.db then return end
    local wanted = not release and PetSoundsWanted(self)
    if not wanted and not self.petSoundOwner and not self.db.petSoundRestore then return end
    local owner = SoundOwner(self, wanted, fresh, true)
    if not wanted then RestoreSoundValues(self, owner); return end
    if owner.mixPrepared then return end
    -- Do not try a broad SFX fallback on clients without the native switch.
    if not ReadSoundValue(PET_SOUND_CVAR) and not self.db.petSoundRestore then return end
    owner.targets[PET_SOUND_CVAR], owner.mixPrepared = 0, true
    ApplySoundValue(self, owner, PET_SOUND_CVAR, 0)
    self:QueueSoundRecovery(owner)
end

function FF:FocusSplashSound()
    self:SyncFishingPetSounds()
    if not SoundWanted(self) then self:RestoreFocusSoundSnapshot(); return end
    local prepared, changed = true, false
    if self.PrepareFocusAudioCompatibility then prepared, changed = self:PrepareFocusAudioCompatibility() end
    if not prepared then
        local owner = SoundOwner(self, true)
        owner.compatibilityPending, owner.pending.compatibility = true, "handoff"
        self:QueueSoundRecovery(owner)
        return
    end
    local previous = self.soundFocusOwner
    if not changed and self.soundFocusSession and previous and previous.db == self.db and previous.bar == self.bar
        and previous.wanted and previous.mixPrepared and not previous.compatibilityPending then return end
    local owner = SoundOwner(self, true, true)
    local snapshot = SoundSnapshot(self, owner)
    -- A new explicit session reconciles a prior failed release before capturing
    -- its normal baseline. Do not carry an older baseline over a readable edit.
    for name, entry in pairs(snapshot) do
        local current = type(name) == "string" and ReadSoundValue(name)
        if type(entry) == "table" and current and not entry.pendingTarget and not SameCVarValue(current, entry.applied) then snapshot[name] = nil end
    end
    local targets = {Sound_EnableAllSound=1, Sound_EnableSFX=1,
        Sound_DialogVolume=FocusMixVolume(self,"Sound_DialogVolume"),
        Sound_MusicVolume=FocusMixVolume(self,"Sound_MusicVolume"),
        Sound_AmbienceVolume=FocusMixVolume(self,"Sound_AmbienceVolume")}
    if ReadSoundValue("Sound_EnableSound") then targets.Sound_EnableSound = 1 end
    local master = ReadSoundValue("Sound_MasterVolume")
    local profile = self.db.soundFocusVolumes
    local masterTarget = type(profile) == "table" and tonumber(profile.Sound_MasterVolume)
    local validMaster = masterTarget and masterTarget == masterTarget and masterTarget ~= math.huge and masterTarget ~= -math.huge
    if master or validMaster then
        targets.Sound_MasterVolume = FocusMixVolume(self,"Sound_MasterVolume",tonumber(master))
    end
    local sfx = ReadSoundValue("Sound_SFXVolume")
    targets.Sound_SFXVolume = math.max(tonumber(sfx) or 0.9,0.9)
    owner.targets = targets
    owner.mixPrepared = true
    for name, value in pairs(targets) do
        if not SoundOwnerCurrent(self, owner) then return end
        ApplySoundValue(self, owner, name, value)
    end
    PruneSoundSnapshot(self, owner, snapshot)
    self:QueueSoundRecovery(owner)
end

function FF:RetryFocusSoundRecovery()
    local owner = self.soundFocusOwner
    if owner and owner.timer then owner.timer:Cancel() end
    self.soundFocusOwner, self.soundFocusSession = nil, nil
    self:SyncFishingPetSounds(false, true)
    self:FocusSplashSound()
    if self.RefreshGameSoundSliders then self:RefreshGameSoundSliders() end
end

function FF:ResumeFishingSoundRestores()
    if not self.db then return end
    if self.soundFocusOwner and self.soundFocusOwner.compatibilityPending then
        return self:RetryFocusSoundRecovery()
    end
    -- A Close near combat can use up its retry budget before the client is
    -- ready. Give only outstanding releases a fresh budget at regeneration.
    if not SoundWanted(self) and type(self.db.soundRestore) == "table" and next(self.db.soundRestore) then
        self:RestoreFocusSoundSnapshot(true)
    end
    if not PetSoundsWanted(self) and type(self.db.petSoundRestore) == "table" and next(self.db.petSoundRestore) then
        self:SyncFishingPetSounds(true, true)
    end
end

function FF:CanAdjustFocusSound()
    local owner = self.soundFocusOwner
    return not not (SoundWanted(self) and self.soundFocusSession and owner and SoundOwnerCurrent(self, owner)
        and owner.wanted and owner.mixPrepared and not owner.compatibilityPending)
end

function FF:SetFocusSplashVolume(name, value)
    -- These controls only edit the active fishing mix. Late input after
    -- Close/Off must never become a normal game-volume change.
    if not self:CanAdjustFocusSound() then return end
    if not PROFILE_SOUND_VOLUMES[name] then return end
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge or not SetCVar then return end
    value = math.max(0, math.min(1, value))
    local owner = self.soundFocusOwner
    owner.targets[name], owner.remember[name] = value, value
    local snapshot = self.db and self.db.soundRestore
    local entry = type(snapshot) == "table" and snapshot[name]
    if type(entry) == "table" and entry.pendingTarget then entry.profileTarget = tostring(value) end
    ApplySoundValue(self,owner,name,value)
    self:QueueSoundRecovery(owner)
end

function FF:SplashSoundCVarChanged(name)
    if self.changingSplashCVars or type(name) ~= "string" or not self.db then return end
    local pet = name:lower() == PET_SOUND_CVAR:lower()
    local snapshot = pet and self.db.petSoundRestore or not pet and self.db.soundRestore
    if type(snapshot) ~= "table" then return end
    local wanted
    if pet then wanted = PetSoundsWanted(self) else wanted = SoundWanted(self) end
    local owner = SoundOwner(self, wanted, false, pet)
    for key, entry in pairs(snapshot) do
        if type(key) == "string" and key:lower() == name:lower() and type(entry) == "table" then
            local current = ReadSoundValue(key)
            if not current then owner.pending[key] = "read"
            elseif entry.pendingTarget then
                SettleSoundWrite(self,owner,snapshot,key,entry,current)
                if snapshot[key] and not entry.pendingTarget then
                    if owner.wanted then
                        owner.pending[key] = not SameCVarValue(current,owner.targets[key]) and "apply" or nil
                    else owner.pending[key] = "restore" end
                end
            elseif not SameCVarValue(current,entry.applied) then snapshot[key], owner.pending[key], owner.remember[key] = nil, nil, nil
            elseif owner.wanted and SameCVarValue(current,owner.targets[key]) then owner.pending[key] = nil end
            break
        end
    end
    PruneSoundSnapshot(self, owner, snapshot)
    self:QueueSoundRecovery(owner)
end


-- This is the same CVar as Blizzard's Audio > Sound in Background checkbox.
-- Treat it as the user's game setting, rather than a temporary fishing override.
function FF:BackgroundSoundEnabled()
    local value = ReadCVar(BACKGROUND_SOUND_CVAR)
    if value == nil or value == "" then return nil end
    return value == "1" or value == "true"
end

function FF:SetBackgroundSoundEnabled(enabled)
    if not SetCVar or self:BackgroundSoundEnabled() == nil then return false end
    local ok = pcall(SetCVar, BACKGROUND_SOUND_CVAR, enabled and "1" or "0")
    if not ok or self:BackgroundSoundEnabled() ~= enabled then return false end
    local snapshot = self.db and self.db.soundRestore
    if type(snapshot) == "table" then
        snapshot[BACKGROUND_SOUND_CVAR] = nil
        if not next(snapshot) then self.db.soundRestore = nil end
    end
    return true
end

function FF:CastInputLockRemaining()
    return math.max(0, (self.castInputLockUntil or 0) - GetTime())
end

function FF:CastInputLocked()
    -- A fresh attempt must be protected while the old channel may still
    -- report a too-far bobber. A confirmed too-far result from the new cast
    -- can bypass this short lock once that channel starts.
    return (self.db.pressLock or 0) > 0 and self:CastInputLockRemaining() > 0
        and (self.castAttemptPending or not (self.db.cameraAssist and self.recastReady))
end

function FF:BeginCastInputLock(channelStarted)
    local duration = self.db.pressLock or 0
    if duration <= 0 then return end
    self.castAttemptPending = not channelStarted
    self.castInputLockUntil = GetTime() + duration
    self.castInputLockToken = (self.castInputLockToken or 0) + 1
    local token = self.castInputLockToken
    self:ApplyBindings()
    if self.SyncCastAction then self:SyncCastAction() end
    self:TraceTransition(string.format("cast button pressed; rapid press lock %.2fs", duration))
    if C_Timer and C_Timer.After then
        C_Timer.After(duration + 0.02, function()
            if self.castInputLockToken ~= token then return end
            self.castAttemptPending = nil
            self:ApplyBindings()
            if self.SyncCastAction then self:SyncCastAction() end
            self:RefreshUI()
        end)
    end
end

function FF:SetAutoEquipGear(enabled)
    if not SafeOutOfCombat() then
        self:Print(FF:LocalizedText("runtime.gear-combat"))
        return false
    end
    enabled = enabled == true
    self.db.autoEquipGear, self.db.autoRestoreGear = enabled, enabled
    self:RefreshUI()
    return true
end

function FF:SetAutoEquipLures(enabled)
    if not SafeOutOfCombat() then
        self:Print(FF:LocalizedText("runtime.lure-combat"))
        return false
    end
    self.db.autoEquipLures = enabled == true
    self:RefreshUI()
    if self.settingsPanel and self.settingsPanel.autoEquipLuresButton then
        self.settingsPanel.autoEquipLuresButton:SetState(self.db.autoEquipLures)
    end
    if self.lurePicker and self.lurePicker:IsShown() then self:RefreshLurePicker() end
    return true
end

local function CastTargetFact(name, ...)
    local callback = rawget(_G, name)
    if (issecretvalue and issecretvalue(callback)) or type(callback) ~= "function" then return nil end
    local ok, value = pcall(callback, ...)
    if not ok or (issecretvalue and issecretvalue(value)) then return nil end
    return value
end

local function IsNearbyNonHostileNPC(guid)
    return type(guid) == "string" and (guid:match("^Creature%-") or guid:match("^Vehicle%-"))
        and CastTargetFact("UnitPlayerControlled", "target") == false
        and CastTargetFact("UnitCanAttack", "player", "target") == false
        and CastTargetFact("UnitIsDeadOrGhost", "target") == false
        and CastTargetFact("CheckInteractDistance", "target", 4) == true
end

-- Presentation only. The soft-interact blocker must also be the selected NPC
-- before suggesting that the player clear their target.
function FF:IsSelectedFishingNPC(blockingGUID)
    return not (issecretvalue and issecretvalue(blockingGUID)) and type(blockingGUID) == "string"
        and CastTargetFact("UnitGUID", "target") == blockingGUID
        and IsNearbyNonHostileNPC(blockingGUID) and CastTargetFact("UnitGUID", "target") == blockingGUID
end

function FF:CloseFishingNPCInteraction(button)
    if not self.castClickArmed or not self.castClickInProgress or not SafeOutOfCombat()
        or not self.bar or not self.bar:IsShown() or not button or button ~= self:GetFishingCastButton()
        or button:GetAttribute("type") ~= "macro" or not self.castMacroIndex
        or button:GetAttribute("macro") ~= self.castMacroIndex then return end
    if issecretvalue and (issecretvalue(C_PlayerInteractionManager) or issecretvalue(Enum)) then return end
    local api = type(C_PlayerInteractionManager) == "table" and C_PlayerInteractionManager
    local kinds = type(Enum) == "table" and rawget(Enum, "PlayerInteractionType")
    if not api or (issecretvalue and issecretvalue(kinds)) or type(kinds) ~= "table" then return end
    local query, close = rawget(api, "IsInteractingWithNpcOfType"), rawget(api, "ClearInteraction")
    if issecretvalue and (issecretvalue(query) or issecretvalue(close)) then return end
    if type(query) ~= "function" or type(close) ~= "function" then return end
    -- End the native session, not just its frame. Replacement dialogue UIs also
    -- receive the native close event. Never close unrelated panels/interactions.
    for _, name in ipairs({ "Merchant", "Gossip" }) do
        local kind = FOVNumber(rawget(kinds, name))
        if kind then
            local ok, active = pcall(query, kind)
            if ok and not (issecretvalue and issecretvalue(active)) and active == true then
                local guid = CastTargetFact("UnitGUID", "npc")
                local selected = CastTargetFact("UnitGUID", "target")
                if not SafeOutOfCombat() or not self.castClickArmed or not self.castClickInProgress
                    or not self.bar:IsShown() then return end
                -- Only one close request; callbacks may synchronously replace
                -- the interaction or refresh bindings and secure attributes.
                local closed = pcall(close, kind)
                if closed then
                    local checked, stillActive = pcall(query, kind)
                    if checked and not (issecretvalue and issecretvalue(stillActive)) and stillActive == false then
                        self:TraceTransition("cast click: closed native " .. name .. " interaction")
                        return guid, selected, true
                    end
                end
                return nil, selected, true
            end
        end
    end
end

function FF:PrepareBlockingFishingTargetClear(button, closedNPCGUID)
    if not self.castClickArmed or not self.castClickInProgress or not SafeOutOfCombat()
        or not self.bar or not self.bar:IsShown() or button ~= self:GetFishingCastButton()
        or button:GetAttribute("type") ~= "macro"
        or not self.castMacroIndex or button:GetAttribute("macro") ~= self.castMacroIndex then return false end
    local guid = CastTargetFact("UnitGUID", "target")
    if not IsNearbyNonHostileNPC(guid) then return false end
    -- Closing a verified NPC session can remove its soft-interact identity.
    -- Retain only that click's native npc GUID, never a name or stale frame.
    if CastTargetFact("UnitGUID", "softinteract") ~= guid and closedNPCGUID ~= guid then return false end
    if not SafeOutOfCombat() or not self.castClickArmed or not self.bar:IsShown()
        or CastTargetFact("UnitGUID", "target") ~= guid then return false end
    -- ClearTarget is protected even from ordinary PreClick Lua. Only the native
    -- secure macro action may execute it, on this player's already-armed click.
    -- Numeric macro takes precedence over macrotext, so clear it for this click.
    -- Do not edit the saved cast macro or call any protected targeting API here.
    button:SetAttribute("macrotext", "/cleartarget [nocombat]\n/cast " .. self:FishingName())
    button:SetAttribute("macro", nil)
    self:TraceTransition("cast click: prepared secure blocking NPC target clear")
    return true
end

local function FishingGuardInputReady(self)
    return SafeOutOfCombat() and self.db and self:IsFishingSessionOpen()
        and (not self.FishingGamepadInputAvailable or self:FishingGamepadInputAvailable())
        and SelectedFishingKey(self) and not self.journalInputFocus and not self.settingsKeyboardFocus
        and not self.journalBackBindingApplied and not self.captureCommitPending
        and not (self.capture and self.capture:IsShown()) and not self:CastInputLocked()
end

local function CurrentFishingEmptyReel(self, emptyReel)
    if emptyReel and emptyReel.db == self.db and emptyReel.bar == self.bar
        and emptyReel.serial == self.channelStartSerial and GetTime() < emptyReel.expires
        and not self.fishingReelLootWindow and not self.lootRecorded then return emptyReel end
end

local function CanCheckFishingEndOnPress(self)
    if not (self.active and self:IsFasterRecastEnabled() and self.castActionButton and not self.db.cameraAssist
        and not self:IsRestrictedFishingReelAvailable()
        and not self:FishingKeyReelLootPending() and not self:CastInputLocked()) then return false end
    if CurrentFishingEmptyReel(self, self.fishingEmptyReel) then return true end
    local status = self.bobberStatusWarning
    return not self.nativeBobberReady and (self.fishingChannelStopPending
        or (status and status.serial == self.channelStartSerial and status.targetLostAt))
end

function FF:CanKeepEmptyReelCastBinding(emptyReel)
    emptyReel = CurrentFishingEmptyReel(self, emptyReel or self.fishingEmptyReel)
    if not (emptyReel and emptyReel.castKey and self.castMacroIndex and self:IsFasterRecastEnabled()
        and not self.db.cameraAssist and not (self.IsFishingGamepadMode and self:IsFishingGamepadMode())
        and FishingGuardInputReady(self) and not self:FishingKeyReelLootPending()
        and SelectedFishingKey(self) == emptyReel.castKey
        and (not self.active or CanCheckFishingEndOnPress(self))) then return false end
    local action = BindingAction(emptyReel.castKey)
    return action == "CLICK ForeverFishingCastActionButton:LeftButton" or action == "CLICK ForeverFishingCastActionButton"
end

local function PrepareEmptyReelRecast(self, button)
    local emptyReel, status = self.fishingEmptyReel, self.bobberStatusWarning
    if not (emptyReel and not emptyReel.recastAttempted and status and status.seenBobber
        and status.serial == self.channelStartSerial and status.targetLostAt and not self.nativeBobberReady
        and self:CanKeepEmptyReelCastBinding(emptyReel))
        or self.fishingChannelStartPending or self:FishingReelLootPending()
        or (LootFrame and LootFrame:IsShown()) then return false end

    -- The game explicitly reported an empty reel, but its channel reader
    -- may still show the same cast. Only this release can replace it.
    local fishing, started = IsFishingChannel()
    if not fishing or not started or started ~= self.castStart or self:NextFishingAction() ~= "cast"
        or self.fishingEmptyReel ~= emptyReel or self.bobberStatusWarning ~= status or self.nativeBobberReady
        or self.fishingChannelStartPending or self:FishingReelLootPending() or (LootFrame and LootFrame:IsShown())
        or not self:CanKeepEmptyReelCastBinding(emptyReel) then return false end

    emptyReel.recastAttempted = true
    button:SetAttribute("macro", nil)
    button:SetAttribute("macrotext", self:FishingStopAndCastMacro())
    button:SetAttribute("type", "macro")
    self.castClickAction, self.castClickArmed, self.castClickInProgress = "cast", true, true
    self.castClickChannelSerial = self.channelStartSerial or 0
    if self.fishingLootTrace then self:TraceFishingLoot("Empty reel: same-press stop and cast") end
    return true
end

function FF:OnCastButtonPreClick(button)
    if self.fishingLootTrace and self.db then
        self.fishingLootTrace.lastGuardMode = nil
        self:TraceFishingLoot("Fishing cast button pressed: " .. self:BindingMode())
    end
    if self.FishingGamepadInputAvailable and not self:FishingGamepadInputAvailable() then
        if SafeOutOfCombat() and button then button:SetAttribute("type",nil) end
        self.castClickArmed=nil;self.castClickInProgress=nil;return
    end
    if button == self.castActionButton and CanCheckFishingEndOnPress(self) and FishingGuardInputReady(self) then
        local db, bar = self.db, self.bar
        local ended = self:PollFishingChannelEnd(false, false, true)
        if not ended and PrepareEmptyReelRecast(self, button) then return end
        if not ended and self.fishingLootTrace and self.fishingLootTrace.recast then
            self:TraceFishingLoot("Cast press waiting for channel confirmation")
        end
        -- An unsuccessful check still behaves like the ordinary guard.
        if not ended then self:OnFishingGuardClick() end
        if not ended or self.active or self.db ~= db or self.bar ~= bar or not FishingGuardInputReady(self)
            or self:FishingKeyReelLootPending() then
            if SafeOutOfCombat() then button:SetAttribute("type", nil) end
            self.castClickAction, self.castClickArmed, self.castClickInProgress = nil, nil, nil
            return
        end
    end
    -- A missed channel event must never turn the reel input into another cast.
    -- Recovery only reconciles state/bindings; this click cannot auto-interact.
    self:RecoverFishingChannel(true)
    if self.db.autoEquipLures and SafeOutOfCombat() then
        local changed = self.RefreshAutomaticLureChoice and self:RefreshAutomaticLureChoice()
        local moved = self.ValidateSelectedLureSlot and self:ValidateSelectedLureSlot()
        if changed or moved then self:RefreshSmartButtons() end
    end
    -- Last chance to catch a slot change before the secure macro action runs.
    if self:CastMacroIndex() ~= self.castMacroIndex or button:GetAttribute("macro") ~= self.castMacroIndex then
        self:RefreshCastMacro()
    end
    self:SyncCastAction()
    self.castClickAction = self.castAction
    if self.castClickAction == "lure" and button:GetAttribute("type") == "macro"
        and self.BeginFishingLureApplication then self:BeginFishingLureApplication() end
    if self.castClickAction == "gear" and not (InCombatLockdown and InCombatLockdown()) then
        self:EquipConfiguredFishingGear(true)
        -- Equipping may refresh the UI before this secure click resolves.
        button:SetAttribute("type", nil)
    end
    self.castClickInProgress = true
    self.castClickArmed = self.castClickAction == "cast" and button:GetAttribute("type") == "macro" and not self:CastInputLocked()
    self.castClickChannelSerial = self.channelStartSerial or 0
    if self.castClickArmed then
        local closedNPCGUID, selectedGUID, closeAttempted = self:CloseFishingNPCInteraction(button)
        -- Native close callbacks may change combat, bar/action or macro state.
        if closeAttempted then
            self:SyncCastAction()
            self.castClickAction = self.castAction
            self.castClickArmed = SafeOutOfCombat() and self.bar and self.bar:IsShown()
                and self.castClickAction == "cast" and button:GetAttribute("type") == "macro" and not self:CastInputLocked()
        end
        if self.castClickArmed then
            if not closeAttempted or CastTargetFact("UnitGUID", "target") == selectedGUID then
                self:PrepareBlockingFishingTargetClear(button, closedNPCGUID)
            end
        elseif closeAttempted and SafeOutOfCombat() then
            button:SetAttribute("type", nil)
        end
    end
end

local function ObserveGuardFishingChannel()
    local _, started, ends, kind = IsFishingChannel()
    return { kind = kind, started = started, ends = ends }
end

local function RecoverExpiredFishingChannel(self, observed)
    local now, started, ended = GetTime(), self.castStart, self.castEnd
    local pending = self.fishingChannelStartPending
    if pending and pending.db == self.db and pending.bar == self.bar
        and type(pending.expires) == "number" and pending.expires >= now then
        self.expiredFishingChannelProbe = nil
        return false -- A newly observed START still has its bounded read window.
    end
    if not self.active or observed.kind ~= "absent" or type(started) ~= "number"
        or type(ended) ~= "number" or started ~= started or ended ~= ended
        or math.abs(started) == math.huge or math.abs(ended) == math.huge
        or ended <= started or now < ended + .25 then
        self.expiredFishingChannelProbe = nil
        return false
    end
    local probe = self.expiredFishingChannelProbe
    if not probe or probe.db ~= self.db or probe.bar ~= self.bar or probe.serial ~= self.channelStartSerial
        or probe.started ~= started or probe.ended ~= ended or probe.guid ~= self.fishingChannelGUID
        or now < probe.at or now - probe.at > 2 then
        self.expiredFishingChannelProbe = { db = self.db, bar = self.bar, serial = self.channelStartSerial,
            started = started, ended = ended, guid = self.fishingChannelGUID, at = now }
        return false
    end
    if now - probe.at < .15 then return false end
    -- Two separate guarded inputs observed absence after this owner's native
    -- deadline. Retire addon state only; a later player input may cast again.
    self:StopChannel("expired channel recovery")
    return true
end

function FF:OnFishingGuardClick()
    local trace = self.fishingLootTrace
    if trace and self.db then
        local mode = self:BindingMode()
        if trace.lastGuardMode ~= mode or trace.lastGuardCast ~= self.channelStartSerial then
            trace.lastGuardMode, trace.lastGuardCast = mode, self.channelStartSerial
            self:TraceFishingLoot("Fishing Key guarded: " .. mode)
        end
    end
    if self:IsFishingSessionOpen() and not self.journalBackBindingApplied then self.lastFishingGuardAt = GetTime() end
    if self:FishingReelLootPending() then return end
    if not FishingGuardInputReady(self) then self.expiredFishingChannelProbe = nil; return end
    local db, bar = self.db, self.bar
    local observed = ObserveGuardFishingChannel()
    if self.db ~= db or self.bar ~= bar or not FishingGuardInputReady(self) then
        self.expiredFishingChannelProbe = nil
        return
    end
    if observed.kind ~= "fishing" then
        RecoverExpiredFishingChannel(self, observed)
        return
    end
    self.expiredFishingChannelProbe = nil
    self:RecoverFishingChannel(true, observed)
    if not self.active or self.db ~= db or self.bar ~= bar or not FishingGuardInputReady(self) then return end
    -- Reacquire interaction only on an explicit input, not a CVar-change loop.
    -- Keep the ordinary still-owned restoration rules for an external change.
    self:PrepareInteract()
    self:SyncBobberInteractIcon()
    if self.UpdateBobberStatus then self:UpdateBobberStatus() end
    self:ApplyBindings()
end

function FF:OnCastButtonPostClick()
    self.castClickInProgress = nil
    if self:GetFishingCastButton() and self:GetFishingCastButton():GetAttribute("macrotext") then self:SyncCastAction() end
    if self.castClickAction == "lure" then
        self:RefreshUI()
    elseif self.castClickAction == "gear" then
        self:RefreshUI()
    end
    if self.fishingLootTrace then
        local message = self.castClickArmed and "Fishing cast action attempted" or "Fishing cast action not armed"
        if self.fishingLootTrace.recast and not self.castClickArmed then
            message = message .. " | action " .. (self.castClickAction or "none") .. " | " .. self:BindingMode()
        end
        self:TraceFishingLoot(message)
    end
    self.castClickAction = nil
    if not self.castClickArmed then return end
    self.castClickArmed = nil
    self.lastCastButtonPressAt = GetTime()
    if self.OnFishingRodRequired and self.FishingRodEquippedNow
        and self:FishingRodEquippedNow() == false then
        self.lastFishingCastAttemptAt = GetTime()
        self:OnFishingRodRequired()
        return
    end
    self:OnFishingSoundCastSent()
    self:BeginCastInputLock((self.channelStartSerial or 0) ~= self.castClickChannelSerial)
end

function FF:OnFishingCastSent(spellID)
    if not self.bar or not self.bar:IsShown() or not SafeOutOfCombat() then return end
    if issecretvalue and issecretvalue(spellID) then return end
    local id = tonumber(spellID)
    if id ~= 7620 and id ~= FISHING_SPELL and id ~= FISHING_CAST then
        if not id or SpellName(id) ~= self:FishingName() then return end
    end
    if self.TraceFishingLoot then self:TraceFishingLoot("Fishing cast sent") end
    self:OnFishingSoundCastSent()
    -- A click on our secure cast button is recorded at the input point. The
    -- spell event is only a fallback for casts from a separate Fishing button.
    if self.castClickInProgress or GetTime() - (self.lastCastButtonPressAt or -100) < 0.2 then return end
    if self.fishingLootTrace and self.fishingLootTrace.recast then self:TraceFishingLoot("Native SENT started input lock") end
    self:BeginCastInputLock(false)
end

function FF:ConfigureCombatCloseBindings(button)
    if not button or not button.SetFrameRef or not SafeOutOfCombat() then return end
    button:SetFrameRef("castBindings", BIND_OWNER)
    button:SetFrameRef("interactBindings", INTERACT_OWNER)
    if self.gamepadChordBindingOwner then button:SetFrameRef("gamepadChordBindings",self.gamepadChordBindingOwner) end
    if self.doubleClickBindingOwner then button:SetFrameRef("doubleBindings", self.doubleClickBindingOwner) end
end

function FF:ApplyBindings()
    if self.fishingStartupFailed or self.fishingLauncherBindingHandoff or not SafeOutOfCombat() then return end
    self.gamepadBindingRefresh=nil
    if self.fishingEmptyReel then self.fishingEmptyReel.castKey = nil end
    ClearOverrideBindings(BIND_OWNER)
    ClearOverrideBindings(INTERACT_OWNER)
    if self.gamepadChordBindingOwner then ClearOverrideBindings(self.gamepadChordBindingOwner) end
    if not GLOBAL_BIND_OWNER then GLOBAL_BIND_OWNER=CreateFrame("Frame", nil, WorldFrame, "SecureHandlerBaseTemplate") end
    ClearOverrideBindings(GLOBAL_BIND_OWNER)
    local key = SelectedFishingKey(self)
    if key == self.doubleRightClickKey then self:InitializeDoubleClickBinding() end
    if self.doubleClickBindingOwner then
        self:RefreshDoubleClickWatcher()
        ClearOverrideBindings(self.doubleClickBindingOwner)
    end
    if self.dataResetPendingReload then return end
    self:ConfigureCombatCloseBindings(self.closeButton)
    if self.journalInputFocus or self.settingsKeyboardFocus or self.fishingResetInput or self.captureCommitPending or (self.capture and self.capture:IsShown()) then return end
    -- Override the player's normal action-bar binding only while the main
    -- Fishing bar is visible. Closing it restores the original key action.
    local capacityRecast = self:HasFishingCapacityRecast()
    local normalInput = not self.FishingGamepadInputAvailable or self:FishingGamepadInputAvailable()
    if not normalInput and not (capacityRecast and self:FishingGamepadInputAvailable(true)) then return end
    local primaryAliased
    if normalInput and self.ApplyAdditionalFishingBindings then
        primaryAliased=self:ApplyAdditionalFishingBindings(BIND_OWNER, GLOBAL_BIND_OWNER)
    end
    if not self:IsFishingSessionOpen() then return end
    if not key or key == "" then return end
    if primaryAliased then return end
    if self.FishingGamepadBindingAvailable and not self:FishingGamepadBindingAvailable(key) then return end
    if key == "BUTTON4" and self.journalBackBindingApplied then return end
    local bindOwner, interactOwner = BIND_OWNER, INTERACT_OWNER
    if self.GetFishingPrimaryBindingKey then
        local chordOwner
        key, chordOwner = self:GetFishingPrimaryBindingKey(key)
        if not key then return end
        if chordOwner then bindOwner, interactOwner = chordOwner, chordOwner end
    end
    if key == self.doubleRightClickKey then
        if not self:DoubleClickArmed() then return end
        key = "BUTTON2"
        bindOwner, interactOwner = self.doubleClickBindingOwner, self.doubleClickBindingOwner
    end
    local cameraRecast = self:CameraRecastReady()
    local nativeChannel = self.active and not self.db.cameraAssist
    local dungeonReel = self:IsRestrictedFishingReelAvailable()
    if capacityRecast then
        SetOverrideBindingClick(bindOwner, true, key, "ForeverFishingCapacityRecastButton", "LeftButton")
    elseif CanCheckFishingEndOnPress(self) and FishingGuardInputReady(self) then
        -- Keep this next press on the secure cast button. It stays inert
        -- until PreClick verifies that the old channel really ended.
        SetOverrideBindingClick(bindOwner, true, key, "ForeverFishingCastActionButton", "LeftButton")
        local emptyReel = CurrentFishingEmptyReel(self, self.fishingEmptyReel)
        if emptyReel and bindOwner == BIND_OWNER then emptyReel.castKey = key end
    elseif self:FishingKeyReelLootPending() or self:CastInputLocked() or (nativeChannel and not (self.nativeBobberReady or dungeonReel))
        or (self.db.cameraAssist and self.cameraAssistNeeded and (not self.cameraAssistBobber or not self.hookReady) and not cameraRecast)
        or (self.db.cameraAssist and self.active and not self.cameraAssistNeeded and not self.recastReady
            and not self.recastWindow and (not self.hookReady or not self.nativeBobberReady)) then
        SetOverrideBindingClick(bindOwner, true, key, "ForeverFishingGuardButton", "LeftButton")
    elseif self.db.cameraAssist and self.cameraAssistNeeded and self.cameraAssistBobber and self.hookReady then
        SetOverrideBinding(interactOwner, true, key, "INTERACTMOUSEOVER")
    elseif dungeonReel then
        -- Both the chord and double-click owners clear securely in combat.
        local owner = interactOwner == INTERACT_OWNER and self.gamepadChordBindingOwner or interactOwner
        SetOverrideBinding(owner, true, key, "INTERACTTARGET")
        if self.bobberStatusWarning then self.bobberStatusWarning.restrictedReelArmed = true end
    elseif nativeChannel or (self.active and not self.cameraAssistNeeded and not self.recastReady and not self.recastWindow) then
        SetOverrideBinding(interactOwner, true, key, "INTERACTTARGET")
    else
        if self.castMacroIndex or (self.NextFishingAction and self:NextFishingAction() ~= "cast") then
            SetOverrideBindingClick(bindOwner, true, key, "ForeverFishingCastActionButton", "LeftButton")
        elseif SetOverrideBindingSpell then
            SetOverrideBindingSpell(bindOwner, true, key, self:FishingName())
        end
    end

end

function FF:UpdateActionReadiness()
    if not self.active or not SafeOutOfCombat() then return end
    local elapsed = GetTime() - self.bobberCheckStartedAt
    local recastDelay = self.currentRecastDelay or self.db.recastDelay
    local hookDelay = self.currentHookDelay or self.db.hookDelay
    -- Native interaction is gated by verified identity and the input lock,
    -- never by the legacy recast/hook workaround sliders.
    local hookReady = not self.db.cameraAssist or elapsed >= hookDelay
    local recastWindow = self.db.cameraAssist and elapsed >= recastDelay and elapsed < hookDelay or false
    local cameraRecast = self:CameraRecastReady()
    if self.hookReady == hookReady and self.recastWindow == recastWindow and self.cameraRecastAvailable == cameraRecast then return end
    self.hookReady = hookReady
    self.recastWindow = recastWindow
    self.cameraRecastAvailable = cameraRecast
    if not self.recastReady then
        self:ApplyBindings()
        if self.SyncCastAction then self:SyncCastAction() end
        local state = cameraRecast and self.cameraAssistNeeded and not self.cameraAssistBobber and "camera recast available"
            or (recastWindow and (self.db.cameraAssist and "recast window" or "good cast recast window") or (hookReady and "hook ready" or "input lock"))
        self:TraceTransition(state .. "; binding " .. BindingAction(SelectedFishingKey(self)))
    end
end

function FF:SetRecastReady(ready, reason)
    ready = ready and self.active and self.db.cameraAssist or false
    self.recastReason = ready and reason or nil
    if self.recastReady == ready or not SafeOutOfCombat() then return end
    self.recastReady = ready
    self:ApplyBindings()
    if self.SyncCastAction then self:SyncCastAction() end
    if ready then self:WarnRangeOnce() end
    local transition = ready and (reason == "blocked" and "another interact target blocks the bobber" or "bobber unavailable to native interaction") or "bobber target returned"
    self:TraceTransition(transition .. "; binding " .. BindingAction(SelectedFishingKey(self)))
end

function FF:InitializeFishingMode()
    if self.db.cameraModeDefaultsVersion ~= 2 then
        -- One transition from the old camera-first default. Keep all tuning.
        self.db.cameraAssist = false
        self.db.cameraModeDefaultsVersion = 2
    else self.db.cameraAssist = self.db.cameraAssist == true end
end

function FF:SetCameraAssistEnabled(enabled)
    enabled = enabled == true
    if self.db.cameraAssist == enabled then return end
    self:SaveTimingProfile()
    self.db.cameraAssist = enabled
    self:ActivateTimingProfile()
    self.db.cameraModeDefaultsVersion = 2
    if self.active then
        self.currentRangeDelay, self.currentRecastDelay, self.currentHookDelay = self.db.rangeDelay, self.db.recastDelay, self.db.hookDelay
        self:UpdateActionReadiness()
    end
    if not enabled then self:StopCameraAssist("Camera assist disabled", true) end
    self:SyncFishingFOV()
    if self.settingsPanel then self:RefreshFishingModeSetting() end
    if self.scanDevPanel then self.scanDevPanel:RefreshControls() end
    if self.active and self.UpdateBobberStatus then self:UpdateBobberStatus() end
    self:ApplyBindings()
    if self.SyncCastAction then self:SyncCastAction() end
    self:RefreshUI()
end

function FF:SetKey(key)
    if not SafeOutOfCombat() then self:Print(FF:LocalizedText("binding.choose-outside-combat")); return end
    if self.FishingActionBindingConflict then
        local conflict, _, guidance = self:FishingActionBindingConflict("fishing", key)
        if conflict then self:Print(guidance and conflict or FF:LocalizedText("binding.unchanged-conflict", conflict)); return end
    end
    if self.ResetDoubleClick and not self.captureCommitPending then self:ResetDoubleClick(true) end
    if self.IsFishingGamepadMode and self:IsFishingGamepadMode() then
        return self:SetFishingActionBinding("fishing",key)
    end
    self.db.key = key
    if self.captureCommitPending then return end
    self:ApplyBindings()
    self:RefreshUI()
    if self.settingsPanel and self.settingsPanel.RefreshBindingControls then self.settingsPanel:RefreshBindingControls() end
end

local function FishingEventSpell(spellID)
    return type(spellID) == "number" and not (issecretvalue and issecretvalue(spellID))
        and (spellID == 7620 or spellID == FISHING_SPELL or spellID == FISHING_CAST
            or SpellName(spellID) == FF:FishingName())
end

function FF:ClearFishingChannelRecovery()
    self.fishingChannelStartPending, self.fishingChannelStopPending = nil, nil
    self.fishingEmptyReel = nil
    self.fishingChannelEndProbe, self.fishingChannelEndCheckAt = nil, nil
    self.expiredFishingChannelProbe = nil
end

function FF:PollFishingChannelEnd(targetJustLost, nativeStop, playerPress)
    if not self:IsFasterRecastEnabled() then return end
    local now, db, bar, serial, started = GetTime(), self.db, self.bar, self.channelStartSerial, self.castStart
    if not self.active or not db or type(started) ~= "number" or not self:IsFishingSessionOpen() then return end
    local starting = self.fishingChannelStartPending
    if starting and starting.db == db and starting.bar == bar and now <= starting.expires then
        self.fishingChannelEndProbe = nil
        return
    end
    local stopping = self.fishingChannelStopPending
    if stopping and (stopping.db ~= db or stopping.bar ~= bar or stopping.serial ~= serial) then
        self.fishingChannelStopPending = nil
        stopping = nil
    end
    local emptyReel = CurrentFishingEmptyReel(self, self.fishingEmptyReel)
    if self.fishingEmptyReel and not emptyReel then
        local routed = self.fishingEmptyReel.castKey
        self.fishingEmptyReel = nil
        if routed then self:ApplyBindings() end
    end
    if not stopping and not emptyReel and now - started < .2 then return end
    local status = not db.cameraAssist and self.bobberStatusWarning
    local targetLost = status and status.serial == serial and status.targetLostAt
        and now - status.targetLostAt < .50
    local checkNow = targetJustLost and targetLost and not self.fishingChannelEndProbe
    if not (checkNow or nativeStop or playerPress) and now < (self.fishingChannelEndCheckAt or 0) then return end
    local _, _, _, kind = IsFishingChannel()
    if not self.active or self.db ~= db or self.bar ~= bar or self.channelStartSerial ~= serial
        or self.castStart ~= started or self.fishingChannelStartPending ~= starting or not self:IsFishingSessionOpen() then return end
    local ended = kind == "absent" or kind == "other"
    local interval = (ended or targetLost or emptyReel or (stopping and now - stopping.at < 1)) and .05 or .20
    self.fishingChannelEndCheckAt = now + interval
    if targetLost and status.channelKindAtLoss ~= kind then
        status.channelKindAtLoss = kind
        local message = "bobber target lost; native channel " .. kind
        self:TraceTransition(message)
        if self.fishingLootTrace then self:TraceFishingLoot(message) end
    end
    if not ended then
        self.fishingChannelEndProbe = nil
        return
    end
    -- An explicit empty reel corroborates a fresh read of native absence.
    -- A live or restricted native channel still needs to settle.
    local confirmedEmpty = kind == "absent" and emptyReel and self.fishingEmptyReel == emptyReel
        and not self.fishingReelLootWindow and not self.lootRecorded
    if not confirmedEmpty and not ((nativeStop or playerPress) and stopping) then
        local probe = self.fishingChannelEndProbe
        if not probe or probe.db ~= db or probe.bar ~= bar or probe.serial ~= serial or probe.started ~= started
            or now < probe.at or now - probe.at > .25 then
            self.fishingChannelEndProbe = { db = db, bar = bar, serial = serial, started = started, at = now }
            return
        end
        if now < probe.at + .05 then return end
    end
    if self.fishingLootTrace then
        if confirmedEmpty then self:TraceFishingLoot("Native channel ended after empty reel")
        elseif playerPress then self:TraceFishingLoot("Native channel end confirmed on Fishing Key press") end
    end
    self:TraceTransition(confirmedEmpty and "native channel end confirmed after empty reel"
        or (stopping and "native channel end confirmed after ambiguous stop" or "native channel end confirmed without stop event"))
    -- An unobserved end may still be a reel with delayed loot. Use the normal
    -- channel stop path so attribution and both loot guards retain ownership.
    self:StopChannel(stopping and stopping.reason or "UNIT_SPELLCAST_CHANNEL_STOP",
        nil, stopping and stopping.spell, true)
    return true
end

local EMPTY_FISHING_REEL_MESSAGES = { "ERR_FISH_NOT_HOOKED", "ERR_FISH_ESCAPED" }

function FF:ObserveFishingEmptyReel(message, errorID)
    if not (self.active and self:IsFasterRecastEnabled() and not self.db.cameraAssist
        and SafeOutOfCombat() and self:IsFishingSessionOpen())
        or self.fishingReelLootWindow or self.lootRecorded then return end
    local status = self.bobberStatusWarning
    if not (self.nativeBobberReady or (status and status.serial == self.channelStartSerial and status.seenBobber))
        or not self:MatchesNativeError(message, EMPTY_FISHING_REEL_MESSAGES, errorID) then return end
    local emptyReel = CurrentFishingEmptyReel(self, self.fishingEmptyReel)
    if not emptyReel then
        self.fishingEmptyReel = { db = self.db, bar = self.bar, serial = self.channelStartSerial, expires = GetTime() + .5 }
    end
    if self.fishingLootTrace then self:TraceFishingLoot("Native empty reel message") end
    self.fishingChannelEndCheckAt = nil
    if self:PollFishingChannelEnd() then return end
    -- Route the next key-down before the native target or channel settles.
    -- The secure button checks the native end on key release before casting.
    if CanCheckFishingEndOnPress(self) and not self:CanKeepEmptyReelCastBinding() then self:ApplyBindings() end
    if self.nativeBobberReady and self.UpdateBobberStatus then self:UpdateBobberStatus() end
end

function FF:RecoverFishingChannel(allowUnobserved, observed)
    if not self.db or not self:IsFishingSessionOpen() then return false end
    local pending = self.fishingChannelStartPending
    if pending and (pending.db ~= self.db or pending.bar ~= self.bar or GetTime() > pending.expires) then
        self.fishingChannelStartPending = nil
        pending = nil
    end
    if not pending and not allowUnobserved then return false end
    local active, started, ends
    if observed then active, started, ends = observed.kind == "fishing", observed.started, observed.ends
    else active, started, ends = IsFishingChannel() end
    if not active or type(started) ~= "number" or not ends or ends <= GetTime()
        or started == self.lastStoppedFishingStart then return false end
    if self.active and self.castStart == started then
        self.castEnd = ends
        return false
    end
    if pending then
        -- Correlate a delayed native read with the observed START, not an older
        -- channel still exposed by the client or an unrelated later cast.
        if started < pending.at - 1 or started > pending.at + .25 then return false end
        self:StartChannel(pending.resumed, pending.guid, pending.spell)
    else
        -- No START proof: use the existing reload/resume accounting boundary.
        self:StartChannel(true)
    end
    return self.active == true and self.castStart == started
end

function FF:QueueFishingChannelStart(resumed, castGUID, spellID)
    if not self.db or not self:IsFishingSessionOpen() or not FishingEventSpell(spellID)
        or type(castGUID) ~= "string" or (issecretvalue and issecretvalue(castGUID)) then return end
    local previous = self.fishingChannelStartPending
    if previous and previous.db == self.db and previous.guid == castGUID then return end
    local pending = { db = self.db, bar = self.bar, at = GetTime(), expires = GetTime() + 1.1,
        guid = castGUID, spell = spellID, resumed = resumed }
    self.fishingChannelStartPending = pending
    if not (C_Timer and C_Timer.After) then return end
    local delays, index = { .05, .15, .3, .5 }, 1
    local function retry()
        if self.fishingChannelStartPending ~= pending then return end
        if pending.db ~= self.db or pending.bar ~= self.bar or not self:IsFishingSessionOpen()
            or GetTime() > pending.expires then self.fishingChannelStartPending = nil; return end
        self:RecoverFishingChannel(false)
        if self.fishingChannelStartPending ~= pending then return end
        index = index + 1
        if delays[index] then C_Timer.After(delays[index], retry)
        else self.fishingChannelStartPending = nil end
    end
    C_Timer.After(delays[index], retry)
end

function FF:StartChannel(resumed, castGUID, spellID)
    local active, started, ends = IsFishingChannel()
    if not active then self:QueueFishingChannelStart(resumed, castGUID, spellID); return end
    self:ClearFishingChannelRecovery()
    self.lastStoppedFishingStart = nil
    local eventGUID = not (issecretvalue and issecretvalue(castGUID)) and type(castGUID) == "string" and castGUID or nil
    local eventSpell = not (issecretvalue and issecretvalue(spellID)) and type(spellID) == "number" and spellID or nil
    if self.active and (not started or self.castStart == started) then
        -- A resumed channel may receive its native identity after login.
        if not self.fishingChannelGUID then self.fishingChannelGUID = eventGUID end
        if not self.fishingChannelSpell then self.fishingChannelSpell = eventSpell end
        return
    end
    if self.active then self:StopChannel() end
    self.active = true
    self.fishingReelLootHandoff = nil
    self.fishingChannelGUID, self.fishingChannelSpell = eventGUID, eventSpell
    self.channelStartSerial = (self.channelStartSerial or 0) + 1
    self.bobberStatusWarning = nil
    self.nativeBobberReady = false
    self.restrictedFishingReel = nil
    self.castAttemptPending = nil
    self.recastReady = false
    self.recastReason = nil
    self.recastWindow = false
    self.cameraRecastAvailable = false
    self.hookReady = false
    self.rangeSoundPlayed = false
    self.castStart = started or GetTime()
    self.bobberCheckStartedAt = GetTime()
    self.bobberMissingSince = nil
    self.bobberBlockedSince = nil
    self.bobberUnknownSince, self.cameraSoftBobberSince = nil, nil
    self.currentRangeDelay = self.db.rangeDelay
    self.currentRecastDelay = self.db.recastDelay
    self.currentHookDelay = self.db.hookDelay
    self.castEnd = ends
    self.lastFishingHookAt = nil
    self.soundCastWaitUntil = nil
    self:CancelPendingCastSound()
    self.lootRecorded = false
    self:CameraCastStarted(resumed)
    if self.HideFishingRodWarning then self:HideFishingRodWarning() end
    self:BeginFishingStatistics(resumed)
    self:PrepareInteract()
    self:FocusSplashSound()
    self:SyncFishingSounds()
    self:ApplyBindings()
    if self.ResumeFishingUIHidingOnCast then self:ResumeFishingUIHidingOnCast(resumed) end
    self:TraceTransition("channel start; binding " .. BindingAction(SelectedFishingKey(self)) .. "; interact " .. (ReadCVar("softTargetInteract") or "?") .. "/" .. (ReadCVar("SoftTargetInteractArc") or "?") .. "/" .. (ReadCVar("SoftTargetInteractRange") or "?"))
    self:RefreshUI()
end

function FF:StopChannel(reason, castGUID, spellID, resolved)
    -- Only native stop/interruption events carry identity. Explicit bar/world
    -- cleanup still uses the ordinary unconditional lifecycle.
    if self.active and (reason == "UNIT_SPELLCAST_CHANNEL_STOP" or reason == "UNIT_SPELLCAST_INTERRUPTED") then
        local eventGUID = not (issecretvalue and issecretvalue(castGUID)) and type(castGUID) == "string" and castGUID or nil
        local eventSpell = not (issecretvalue and issecretvalue(spellID)) and type(spellID) == "number" and spellID or nil
        if eventGUID and self.fishingChannelGUID and eventGUID ~= self.fishingChannelGUID then
            self:TraceTransition("ignored stale fishing channel stop")
            return
        end
        if eventSpell and eventSpell ~= self.fishingChannelSpell and eventSpell ~= 7620
            and eventSpell ~= FISHING_SPELL and eventSpell ~= FISHING_CAST
            and SpellName(eventSpell) ~= self:FishingName() then return end
        if self:IsFasterRecastEnabled() then
            if not (eventGUID and self.fishingChannelGUID) and not resolved and self:IsFishingSessionOpen() then
                if not self.fishingChannelStopPending then
                    self.fishingChannelStopPending = { db = self.db, bar = self.bar, serial = self.channelStartSerial,
                        reason = reason, guid = eventGUID, spell = eventSpell, at = GetTime() }
                    self.fishingChannelEndCheckAt = nil
                    self:TraceTransition("ambiguous fishing stop; checking native channel")
                elseif reason == "UNIT_SPELLCAST_CHANNEL_STOP" then
                    self.fishingChannelStopPending.reason, self.fishingChannelStopPending.guid = reason, eventGUID
                end
                if not self:PollFishingChannelEnd(false, true) and CanCheckFishingEndOnPress(self) then self:ApplyBindings() end
                return
            end
        elseif not eventGUID and not resolved then
            local function ChannelEnded(start)
                local live, started, _, kind = IsFishingChannel()
                return kind == "absent" or kind == "other" or (live and started and started ~= start)
            end
            if not ChannelEnded(self.castStart) then
                -- Some terminal notifications have no cast identity. Allow the
                -- native cache one frame to settle before ending this owner.
                if not self.fishingChannelStopPending and C_Timer and C_Timer.After then
                    local pending = { db = self.db, serial = self.channelStartSerial, started = self.castStart,
                        reason = reason, spell = spellID }
                    self.fishingChannelStopPending = pending
                    local delays, index = { .05, .15, .3, .5 }, 1
                    local function settle()
                        if self.fishingChannelStopPending ~= pending then return end
                        if self.db ~= pending.db or not self.active or self.channelStartSerial ~= pending.serial then
                            self.fishingChannelStopPending = nil; return
                        end
                        if ChannelEnded(pending.started) then
                            self:StopChannel(pending.reason, nil, pending.spell, true)
                        else
                            index = index + 1
                            if delays[index] then C_Timer.After(delays[index], settle)
                            else self.fishingChannelStopPending = nil end
                        end
                    end
                    C_Timer.After(delays[index], settle)
                elseif self.fishingChannelStopPending then
                    self.fishingChannelStopPending.reason, self.fishingChannelStopPending.spell = reason, spellID
                end
                return
            end
        end
    end
    local pending = self.fishingChannelStartPending
    if pending and (reason == "UNIT_SPELLCAST_CHANNEL_STOP" or reason == "UNIT_SPELLCAST_INTERRUPTED") then
        local readableGUID = not (issecretvalue and issecretvalue(castGUID)) and type(castGUID) == "string" and castGUID or nil
        local readableSpell = not (issecretvalue and issecretvalue(spellID)) and type(spellID) == "number" and spellID or nil
        if (readableGUID and readableGUID ~= pending.guid) or (readableSpell and not FishingEventSpell(readableSpell)) then return end
    end
    local bobber = self.bobberStatusWarning
    local hadReelTarget = self.nativeBobberReady or (bobber and (bobber.seenBobber or bobber.restrictedReelArmed))
        or (self.cameraAssistBobber and self.hookReady)
    local emptyReel = CurrentFishingEmptyReel(self, self.fishingEmptyReel)
    self:ClearFishingChannelRecovery()
    self.bobberStatusWarning = nil
    self:StopFishingSound("range", true)
    if not self.active then return end
    if self.TraceFishingLoot then self:TraceFishingLoot("Fishing channel ended (" .. (reason or "state change") .. ")") end
    self.lastStoppedFishingStart = self.castStart
    self:CameraChannelEnded(reason)
    self:EndFishingStatistics(reason)
    local remaining = self.castEnd and string.format("%.1fs", self.castEnd - GetTime()) or "unknown"
    self.lastFishingHookAt = self.castEnd and self.castEnd - GetTime() > 1 and GetTime() or nil
    if reason == "UNIT_SPELLCAST_CHANNEL_STOP" and hadReelTarget and not self.lootRecorded
        and (not self.castEnd or self.lastFishingHookAt) and self:IsFishingSessionOpen() then
        WaitForFishingReelLoot(self)
    end
    self.active = false
    self.nativeBobberReady = false
    self.restrictedFishingReel = nil
    self.fishingChannelGUID, self.fishingChannelSpell = nil, nil
    self.recastReady = false
    self.recastReason = nil
    self.recastWindow = false
    self.cameraRecastAvailable = false
    self.hookReady = false
    self.rangeSoundPlayed = false
    self.lastChannelEnd = GetTime()
    self.castEnd = nil
    self.soundCastWaitUntil = nil
    self.bobberCheckStartedAt = nil
    self.bobberMissingSince = nil
    self.bobberBlockedSince = nil
    self.bobberUnknownSince, self.cameraSoftBobberSince = nil, nil
    self.currentRangeDelay = nil
    self.currentRecastDelay = nil
    self.currentHookDelay = nil
    self:RestoreCVars("interactRestore")
    self:FocusSplashSound()
    -- A press can already be held on the correct secure button. Keep the
    -- same override in place across the stop when the input context agrees.
    if not self:CanKeepEmptyReelCastBinding(emptyReel) then self:ApplyBindings() end
    self:TraceTransition("channel stop (" .. (reason or "state change") .. "); time left " .. remaining .. "; binding " .. BindingAction(SelectedFishingKey(self)))
    self:RefreshUI()
    self:SyncFishingSounds()
end

function FF:LureSeconds()
    if GetWeaponEnchantInfo then
        local has, remaining = GetWeaponEnchantInfo()
        if has then
            remaining = tonumber(remaining)
            return remaining and math.max(0, remaining / 1000) or nil
        end
        return 0
    end
    if C_PaperDollInfo and C_PaperDollInfo.GetTemporaryEnchantmentInfo then
        local info = C_PaperDollInfo.GetTemporaryEnchantmentInfo(16)
        if not info then return 0 end
        if type(info) == "table" then
            if info.hasEnchant == false then return 0 end
            local remaining = info.expiration or info.expirationTime or info.remainingTime
            remaining = tonumber(remaining)
            if remaining then return math.max(0, remaining / 1000) end
        end
    end
    return nil
end

-- Only replaceable discovery/presentation work belongs here. Gameplay events,
-- saved catch facts, bindings and profession ownership always run immediately.
function FF:DeferScanRefresh(method, urgent)
    local pending = self.scanRefreshPending
    if urgent or not (self.IsCameraSearchBusy and self:IsCameraSearchBusy())
        or not (C_Timer and C_Timer.After) then
        if pending then pending[method] = nil end
        return false
    end
    if not pending then pending = {}; self.scanRefreshPending = pending end
    if not pending[method] then
        pending[method] = true
        local cast = self.cameraCast
        if cast then cast.deferredRefreshes = (cast.deferredRefreshes or 0) + 1 end
    end
    if not self.scanRefreshPump then
        self.scanRefreshPump = function()
            self.scanRefreshScheduled = nil
            if not next(self.scanRefreshPending) then return end
            if not self:IsCameraSearchBusy() then
                -- Discovery precedes its views; drain at most one job per tick.
                local key = self.scanRefreshPending.RefreshMasterChefCookingFromEvent
                    and "RefreshMasterChefCookingFromEvent" or next(self.scanRefreshPending)
                self.scanRefreshPending[key] = nil
                if self[key] then self[key](self) end
            end
            if next(self.scanRefreshPending) and not self.scanRefreshScheduled then
                self.scanRefreshScheduled = true
                C_Timer.After(0.1, self.scanRefreshPump)
            end
        end
    end
    if not self.scanRefreshScheduled then
        self.scanRefreshScheduled = true
        C_Timer.After(0.1, self.scanRefreshPump)
    end
    return true
end

function FF:RefreshUI(skipJournal)
    if self.UpdateUI then self:UpdateUI(skipJournal) end
end

function FF:CancelFishingItemRefresh(suspend)
    self.fishingItemRefreshPending = nil
    if suspend ~= nil then self.fishingItemRefreshSuspended = suspend end
end

function FF:QueueFishingItemRefresh()
    if self.fishingItemRefreshSuspended then return end
    local owner = self.GearCharacterKey and self:GearCharacterKey()
    local previous = self.fishingItemRefreshPending
    if previous and previous.db == self.db and previous.owner == owner then return end
    local pending = {db=self.db,owner=owner}
    self.fishingItemRefreshPending = pending
    local function Refresh()
        if self.fishingItemRefreshPending ~= pending then return end
        self.fishingItemRefreshPending = nil
        if self.db ~= pending.db or self.GearCharacterKey and self:GearCharacterKey() ~= pending.owner then return end
        -- Only item-derived presentation is batched. Catch accounting, normal
        -- hand capture, recap/quality and live action preparation stay immediate.
        self:InvalidateFishingStats()
        self:RefreshJournal()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0,Refresh) else Refresh() end
end

function FF:ToggleMainWindow(fromLauncher)
    if self.fishingStartupFailed then return self:ReportFishingStartupFailure() end
    if not self.ToggleUI then return end
    if not (fromLauncher and self.bar and not self.bar:IsShown() and SafeOutOfCombat()
        and self.ShouldDeferFishingLauncherBindings and self:ShouldDeferFishingLauncherBindings()) then
        self:ToggleUI()
        return
    end
    -- Opening from Blizzard's launcher can run inside native menu dispatch.
    -- Keep the player-driven open and gear path, but let UI focus settle before
    -- clearing or rebuilding overrides and updating secure Close frame refs.
    self.gamepadBindingRefresh = nil
    self.fishingLauncherBindingHandoff = true
    local ok, failure = pcall(self.ToggleUI, self)
    self.fishingLauncherBindingHandoff = nil
    if not ok then error(failure, 0) end
    self:RefreshFishingGamepadInput()
end

function FF:ResetAllData()
    if self.dataResetPendingReload then return end
    if not SafeOutOfCombat() then
        self:Print(FF:LocalizedText("reset.all-combat"))
        return
    end
    -- Keep the live table for native-state restoration. SavedVariables gets
    -- the empty table now and the next login will build fresh addon frames.
    self.dataResetPendingReload = true
    ForeverFishingDB = {}
    self:CancelFishingItemRefresh(true)
    if self.scanRefreshPending then wipe(self.scanRefreshPending) end
    if self.InvalidateFishingInventoryCache then self:InvalidateFishingInventoryCache() end
    if self.CancelNormalWeaponCapture then self:CancelNormalWeaponCapture() end
    self:ClearFishingChannelRecovery()
    if self.ClearFishingLureApplication then self:ClearFishingLureApplication() end
    if self.InterruptKeyCapture then self:InterruptKeyCapture() end
    if self.SuspendGearOperation then self:SuspendGearOperation() end
    if self.CancelScanDiagnostics then self:CancelScanDiagnostics() end
    -- Hide the bar directly. The normal toggle can equip remembered gear.
    for _, panel in pairs({ self.bar, self.journalPanel, self.settingsPanel,
        self.sessionGoalsPanel, self.sessionTrackerPanel, self.tracePanel, self.scanDevPanel }) do
        if panel:IsShown() then panel:Hide() end
    end
    self:ApplyBindings()
    if self.ReleaseMasterChefCampSession then self:ReleaseMasterChefCampSession() end
    if self.ReleaseMasterChefCookingSession then self:ReleaseMasterChefCookingSession() end
    if self.HideAchievementNotice then self:HideAchievementNotice(true) end
    if self.HideCatchRecap then self:HideCatchRecap() end
    if self.ResetFishingLootObservation then self:ResetFishingLootObservation() end
    self.fishingReelLootHandoff, self.fishingReelLootWindow = nil, nil
    self.fastAutoLootWindow = nil
    self:ReleaseFastAutoLootRate()
    self:StopChannel("data reset")
    self:SuspendFishingSounds()
    self:RestoreCVars("interactRestore")
    self:RestoreCVars("bobberIconRestore")
    self:RestoreCVars("soundRestore")
    self:RestoreCVars("backgroundFPSRestore")
    self:RestoreCVars("autoLootRestore")
    self:RestoreCVars("cameraCenterRestore")
    self:RestoreCVars("cameraViewBlendRestore")
    self:RestoreCVars("cameraZoomRestore")
    self:RestoreCVars("cameraDistanceRestore")
    self:ReleaseFishingFOV(true)
    if self.ReleaseFishingCastBars then self:ReleaseFishingCastBars() end
    if self.ReleaseFishingUIVisibility then self:ReleaseFishingUIVisibility(true) end
    self:Print(FF:LocalizedText("reset.reload-needed"))
end

-- Seed only fresh/reset settings: missing values in existing saves can mean
-- deliberately cleared bindings or a retained legacy view preference.
function FF:ResetFishingInputViewDefaults()
    if self.captureVisibility and self.InterruptKeyCapture then self:InterruptKeyCapture() end
    self.db.gamepadMode=nil;self.db.gamepadBindings=nil;self.gamepadModePending=nil
    self.db.actionBindings = { jump="SHIFT-SPACE", recast="CTRL-SPACE" }
    self.db.fishingInformation = { progressMode="always", hideCastBars="both" }
    self.db.fishingChatMode = "whispers"
end

function FF:ResetSettingsToDefaults(skipSettingsReopen)
    if self.dataResetPendingReload then return end
    if not SafeOutOfCombat() then
        self:Print(FF:LocalizedText("reset.settings-combat"))
        return
    end
    self:ClearFishingChannelRecovery()
    self:CancelFishingItemRefresh()
    if self.InvalidateFishingInventoryCache then self:InvalidateFishingInventoryCache() end
    if self.CancelNormalWeaponCapture then self:CancelNormalWeaponCapture() end
    if self.ClearFishingLureApplication then self:ClearFishingLureApplication() end
    self.db.uiSchemaVersion = UI_SCHEMA_VERSION
    self.db.key = DEFAULT_FISHING_KEY
    self.db.keyInitialized = true
    self.db.rightClickFishing = nil -- Retired development mode.
    self:ResetFishingInputViewDefaults()
    self.db.language = nil
    self.db.showMinimapIcon = nil
    if self.SyncMinimapIconVisibility then self:SyncMinimapIconVisibility() end
    self.db.interactAssist = true
    self.soundFocusSession = nil
    self.db.mutePets = nil
    self:RestoreCVars("soundRestore")
    self.db.soundFocusVolumes = nil
    self.db.soundFocus = true
    self.db.hideLureGlowWhenOutOfLures = true
    self.db.autoEquipGear = true
    self.db.autoEquipLures = true
    self.db.manualGearAndLures = nil
    self.db.autoOpenFishingBar = true
    self.db.autoRestoreGear = true
    self.db.journalFaction = "Auto"
    self.db.campMilestones = true
    self.db.journalTextScale = 1
    self.db.iconBarSpacing = nil
    self.db.fishingBarMode, self.db.lastCompactBarMode = nil,nil
    self.db.fishingBarOrientation,self.db.fishingBarAutoCollapse,self.db.flyoutGrid=nil,nil,nil
    self.db.showUtilityButton,self.db.utilityItems,self.db.utilityHidden=nil,nil,nil
    if self.utilityPicker and not (InCombatLockdown and InCombatLockdown()) then self.utilityPicker:Hide() end
    if self.settingsPicker and not (InCombatLockdown and InCombatLockdown()) then self.settingsPicker:Hide() end
    if self.journalPicker and not (InCombatLockdown and InCombatLockdown()) then self.journalPicker:Hide() end
    self.db.minimalFishingCastView=nil
    self.db.showFishingMinimap=nil
    if self.ApplyFishingInformationLayout then self:ApplyFishingInformationLayout() end
    self.db.flyoutLayouts = nil
    self.db.flyoutDefaults = nil
    self.db.fastNativeAutoLoot = nil
    self.db.fasterRecast = nil
    self:ReleaseFastAutoLootRate()
    self:SyncAutoLoot()
    self.db.catchRecap = true
    if self.SetHideBlizzardUIWhileFishing then self:SetHideBlizzardUIWhileFishing(false) end
    if self.HideCatchRecap then self:HideCatchRecap() end
    self.db.cameraAssist = false
    self.db.cameraModeDefaultsVersion = 2
    self:ResetScanSettings()
    self.db.rangeSound = "ping"
    self.db.rangeSoundLoop = true
    self.db.recastReminderSound = "off"
    self.db.catchConfirmedSound = "off"
    self.db.fishEscapedSound = "off"
    self.db.fullBagsSound, self.db.fullBagsSoundLoop = "ping", false
    self.db.cookingCompleteSound = "chime"
    self.db.enableAlertSounds = true
    self.db.recastReminderLoop = false
    self.db.recastReminderDelay = self.recastReminderTiming.default
    self.db.soundRepeatInterval = self.soundRepeatTiming.default
    self.db.voiceVolume = self.voiceVolumeTiming.default
    self.db.voiceVolumeDefaultVersion = 1
    self:StopFishingSounds()
    self:SyncFishingSounds()
    self:ResetTimingProfiles()
    self.db.timingDefaultsVersion = 2
    self.db.sessionTrackerHidden = nil
    if self.LayoutSessionTracker then self:LayoutSessionTracker() end
    if self.ResetFishingLayouts then self:ResetFishingLayouts() end
    if self.ApplyIconBarSpacing then self:ApplyIconBarSpacing() end
    if self.ApplyJournalTextSize then self:ApplyJournalTextSize() end
    if self.RefreshAllFishingFlyoutLayouts and self.RefreshFishingFlyoutLayout then self:RefreshAllFishingFlyoutLayouts() end
    if self.StopCameraAssist then self:StopCameraAssist("Settings reset", true) end
    self:SyncFishingFOV()
    if self.active then self:PrepareInteract() end
    self:FocusSplashSound()
    self:ApplyBindings()
    self:RefreshUI()
    if self.settingsPanel then
        if self.settingsPanel.flyoutEditScope then self.settingsPanel.flyoutEditScope = "all" end
        if not skipSettingsReopen then self:ShowSettings() end
    end
    self:Print(FF:LocalizedText("reset.settings-done"))
end

function FF:ShowSettingsResetConfirmation()
    if self.dataResetPendingReload then return end
    if not SafeOutOfCombat() then
        self:Print(FF:LocalizedText("reset.settings-combat"))
        return
    end
    self:ShowFishingOwnedResetConfirmation(false)
end

function FF:ShowResetConfirmation()
    if self.dataResetPendingReload then return end
    if not SafeOutOfCombat() then
        self:Print(FF:LocalizedText("reset.all-combat"))
        return
    end
    self:ShowFishingOwnedResetConfirmation(true)
end

SLASH_FOREVERFISHING1 = "/fish"
SLASH_FOREVERFISHINGGEAR1 = "/fishgear"
SlashCmdList.FOREVERFISHINGGEAR = function(message)
    if FF.dataResetPendingReload then return FF:Print(FF:LocalizedText("reset.reload-needed")) end
    if FF.fishingStartupFailed then return FF:ReportFishingStartupFailure() end
    if FF.HandleFishingGearRecovery then FF:HandleFishingGearRecovery(message) end
end
SlashCmdList.FOREVERFISHING = function(message)
    if FF.dataResetPendingReload then return FF:Print(FF:LocalizedText("reset.reload-needed")) end
    if FF.fishingStartupFailed then return FF:ReportFishingStartupFailure() end
    local command, arg = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = command:lower()
    if command == "bind" then
        FF:BeginKeyCapture(arg ~= "" and arg:lower() or "fishing")
    elseif command == "unbind" then
        FF:SetFishingActionBinding(arg ~= "" and arg:lower() or "fishing", nil)
    elseif command == "pin" then
        FF:Print(FF:LocalizedText("runtime.flyout-help-legacy"))
    elseif command == "gear" then
        FF:ShowGearPicker()
    elseif command == "lure" then
        FF:SetLure(tonumber(arg))
    elseif command == "settings" then
        FF:ShowSettings()
    elseif command == "dev" then
        FF:ShowCameraDeveloper()
    elseif command == "repair" then
        FF.castMacroIndex = FF:EnsureCastMacro()
        FF:RefreshCastMacro()
        FF:RefreshUI()
    elseif command == "status" then
        FF:ShowStatus()
    elseif command == "trace" then
        FF:ShowTrace()
    elseif command == "reeltrace" then
        FF:ShowFishingReelTrace()
    elseif command == "skilltrace" and FF.ShowFishingSkillTrace then
        FF:ShowFishingSkillTrace()
    elseif command == "loottrace" then
        FF:ToggleFishingLootTrace()
    elseif command == "recasttrace" then
        FF:ToggleFishingRecastTrace()
    elseif command == "changes" then
        FF:ShowLayoutChanges()
    elseif command == "reset" then
        FF:ShowResetConfirmation()
    else
        FF:ToggleMainWindow()
    end
end

events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("ZONE_CHANGED_INDOORS")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("PLAYER_LEAVING_WORLD")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UNIT_SPELLCAST_SENT")
events:RegisterEvent("UNIT_SPELLCAST_START")
events:RegisterEvent("UNIT_SPELLCAST_DELAYED")
events:RegisterEvent("UNIT_SPELLCAST_STOP")
events:RegisterEvent("UNIT_SPELLCAST_FAILED")
pcall(events.RegisterEvent, events, "UNIT_SPELLCAST_FAILED_QUIET")
events:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
events:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
events:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
events:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
events:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
events:RegisterEvent("UI_INFO_MESSAGE")
events:RegisterEvent("UI_ERROR_MESSAGE")
events:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
events:RegisterEvent("LOOT_READY")
events:RegisterEvent("LOOT_BIND_CONFIRM")
events:RegisterEvent("LOOT_SLOT_CHANGED")
events:RegisterEvent("LOOT_SLOT_CLEARED")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
pcall(events.RegisterEvent,events,"ITEM_DATA_LOAD_RESULT")
pcall(events.RegisterEvent,events,"TOOLTIP_DATA_UPDATE")
events:RegisterEvent("LOOT_OPENED")
events:RegisterEvent("LOOT_CLOSED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("UPDATE_BINDINGS")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("UNIT_INVENTORY_CHANGED")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("SKILL_LINES_CHANGED")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("TRADE_SKILL_SHOW")
events:RegisterEvent("TRADE_SKILL_CLOSE")
events:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
pcall(events.RegisterEvent, events, "UPDATE_TRADESKILL_CAST_STOPPED")
pcall(events.RegisterEvent, events, "NEW_RECIPE_LEARNED")
pcall(events.RegisterEvent, events, "TRADE_SKILL_UPDATE")
pcall(events.RegisterEvent, events, "TRADE_SKILL_DATA_SOURCE_CHANGED")
events:RegisterEvent("UNIT_AURA")
events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
events:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
events:RegisterEvent("EQUIPMENT_SETS_CHANGED")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("UPDATE_MACROS")
events:RegisterEvent("CVAR_UPDATE")
events:RegisterEvent("UI_SCALE_CHANGED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
for _,event in ipairs({"INPUT_DEVICE_INTERFACE_TRANSITION","GAME_PAD_CONNECTED","GAME_PAD_DISCONNECTED","MODIFIER_STATE_CHANGED"}) do
    pcall(events.RegisterEvent,events,event)
end
-- Keep optional integrations from aborting login while reporting the original
-- error through WoW's handler with the failing call stack still available.
local function RunFishingStartupStep(step, initialize)
    return xpcall(function() initialize(FF) end, function(err)
        local detail = not (issecretvalue and issecretvalue(err)) and type(err) == "string" and err or "Lua error"
        if geterrorhandler then
            pcall(geterrorhandler(), "Forever Fishing [" .. step .. "]: " .. detail)
        end
    end)
end

local startupLocalizationReady

function FF:ReportFishingStartupFailure()
    local message = self.englishStrings and self.englishStrings["startup.bar"] or "Fishing could not start. Reload the UI."
    if startupLocalizationReady then message = self:LocalizedText("startup.bar") end
    self:Print(message)
end

local function ClearFailedStartupBindings()
    if not SafeOutOfCombat() then return end
    for _, owner in pairs({ BIND_OWNER, INTERACT_OWNER, GLOBAL_BIND_OWNER,
        FF.gamepadChordBindingOwner, FF.doubleClickBindingOwner }) do
        pcall(ClearOverrideBindings, owner)
    end
    return true
end

local function InitializeFishingGamepadSupport()
    if not FF.gamepadHUDStartupFailed and FF.InitializeFishingGamepadHUD
        and not RunFishingStartupStep("Gamepad HUD", FF.InitializeFishingGamepadHUD) then
        FF.gamepadHUDStartupFailed = true
    end
    if not FF.gamepadInputStartupFailed and FF.InitializeFishingGamepadInput
        and not RunFishingStartupStep("Gamepad input", FF.InitializeFishingGamepadInput) then
        FF.gamepadInputStartupFailed = true
        -- This can also happen when Blizzard's gamepad module loads after login.
        if FF.db.gamepadMode then
            ClearFailedStartupBindings()
            FF:Print(FF:LocalizedText("startup.gamepad"))
        end
    end
end

local function InitializeFishingAtLogin()
    if type(ForeverFishingDB) ~= "table" then ForeverFishingDB = {} end
    FF.db = ForeverFishingDB
    local hadSavedState = next(FF.db) ~= nil
    FF.masterChefCookingQueue = {}
    FF.masterChefCampCraftQueue = {}
    if type(FF.db.journal) ~= "table" then FF.db.journal = {} end
    FF:InitializeLifetimeStats()
    FF:RegisterAuctionPriceUpdates()
    FF:RestoreCVars("interactRestore")
    FF:RestoreCVars("bobberIconRestore")
    FF:RestoreCVars("soundRestore")
    FF:RestoreCVars("backgroundFPSRestore")
    FF:RestoreCVars("autoLootRestore")
    FF:RestoreCVars("cameraCenterRestore")
    FF:RestoreCVars("cameraViewBlendRestore")
    FF:RestoreCVars("cameraZoomRestore")
    FF:RestoreCVars("cameraDistanceRestore")
    FF:ReleaseFishingFOV(true)
    -- Restore addon-owned game state before the one-time settings upgrade;
    -- build every setting and frame from the new UI schema afterward.
    if FF:InitializeSavedVariableSchemaVersions(hadSavedState) then FF:ResetFishingInputViewDefaults() end
    FF:InitializeLocalization()
    startupLocalizationReady = true
    if FF.db.keyInitialized == nil then
        if FF.db.key == nil then FF.db.key = DEFAULT_FISHING_KEY end
        FF.db.keyInitialized = true
    end
    FF.db.interactAssist = true
    if FF.db.soundFocus == nil then FF.db.soundFocus = true end
    if FF.db.hideLureGlowWhenOutOfLures == nil then FF.db.hideLureGlowWhenOutOfLures = true end
    local wasAutomatic = FF.db.manualGearAndLures ~= true
    if FF.db.autoEquipGear == nil then FF.db.autoEquipGear = wasAutomatic end
    if FF.db.autoEquipLures == nil then FF.db.autoEquipLures = wasAutomatic end
    FF.db.manualGearAndLures = nil
    if FF.db.autoOpenFishingBar == nil then FF.db.autoOpenFishingBar = true end
    if FF.db.autoRestoreGear == nil then FF.db.autoRestoreGear = true end
    -- Respect either old opt-out when combining the two options.
    local automaticGear = FF.db.autoEquipGear == true and FF.db.autoRestoreGear == true
    FF.db.autoEquipGear, FF.db.autoRestoreGear = automaticGear, automaticGear
    if FF.db.journalFaction ~= "Alliance" and FF.db.journalFaction ~= "Horde" then
        FF.db.journalFaction = "Auto"
    end
    if FF.db.campMilestones == nil then FF.db.campMilestones = true end
    if FF.db.catchRecap == nil then FF.db.catchRecap = true end
    if FF.db.hideBlizzardUIWhileFishing == nil then FF.db.hideBlizzardUIWhileFishing = false end
    FF:InitializeFishingViewSettings()
    FF:InitializeFishingActionBindings()
    InitializeFishingGamepadSupport()
    FF:InitializeFishingMode()
    FF:InitializeScanConfig()
    FF.db.lureWarning = nil
    FF:InitializeSoundSettings()
    local timing = FF.timing
    if (tonumber(FF.db.timingDefaultsVersion) or 0) < 2 then
        if tonumber(FF.db.recastDelay) == 2.5 then FF.db.recastDelay = timing.recastDefault end
        if tonumber(FF.db.hookDelay) == 2.5 then FF.db.hookDelay = timing.hookDefault end
        if tonumber(FF.db.pressLock) == 0.25 then FF.db.pressLock = timing.pressDefault end
        FF.db.timingDefaultsVersion = 2
    end
    FF.db.rangeDelay = ClampTwentieth(FF.db.rangeDelay, timing.rangeMin, timing.rangeMax, timing.rangeDefault)
    FF.db.recastDelay = ClampTenth(FF.db.recastDelay, timing.recastMin, timing.recastMax, timing.recastDefault)
    FF.db.hookDelay = ClampTenth(FF.db.hookDelay, timing.hookMin, timing.hookMax, timing.hookDefault)
    FF.db.pressLock = ClampTwentieth(FF.db.pressLock, timing.pressMin, timing.pressMax, timing.pressDefault)
    FF:InitializeTimingProfiles()
    if FF.InitializeFishingSystems then FF:InitializeFishingSystems() end
    if FF.RefreshFishingAchievements then FF:RefreshFishingAchievements(false, true) end
    if FF.QueueNormalWeaponCapture then FF:QueueNormalWeaponCapture() end
    FF.castMacroIndex = FF:EnsureCastMacro()
    FF:InitializeUI()
    FF:InitializeCameraScanning()
    FF:InstallBlizzardPanelHooks()
    FF:ApplyBindings()
end

events:SetScript("OnEvent", function(_, event, unit, target, castGUID, spellID)
    if FF.dataResetPendingReload and event ~= "PLAYER_LOGOUT" then return end
    if FF.fishingStartupFailed then
        if event == "PLAYER_REGEN_ENABLED" and FF.fishingStartupBindingsPending then
            FF.fishingStartupBindingsPending = not ClearFailedStartupBindings() or nil
        end
        if event ~= "PLAYER_LEAVING_WORLD" and event ~= "PLAYER_LOGOUT" then return end
    end
    -- Unreadable loot intent keeps the native visibility fallback. Row
    -- observation and the reel hold have independent qualification rules.
    if event == "LOOT_READY" or event == "LOOT_OPENED" then
        local fishing = ReadFastLootValue(IsFishingLoot)
        if not FF.fishingReelLootWindow and FF:IsFishingSessionOpen() then
            if fishing == true or (fishing == nil and FF:FishingReelLootPending()) then
                FF.fishingReelLootHandoff = nil
                FF.fishingEmptyReel = nil
                FF.fishingReelLootWindow = true
                FF:RefreshFishingReelLootInput()
            end
        end
        local automatic = not (issecretvalue and (issecretvalue(unit) or issecretvalue(target)))
            and unit == true and target ~= true
        if FF.BeginFishingLootVisibility then
            FF:BeginFishingLootVisibility(automatic and fishing == true,
                event == "LOOT_OPENED" and not automatic)
        end
        local fastWindow = FF:ObserveFastAutoLoot(event, unit, target)
        local owner = FF.fastAutoLootWindow
        local recorded, snapshot = FF:RecordLoot(event, unit)
        FF:ObserveFishingCapacityLoot(owner, event, automatic and fishing == true, recorded, snapshot)
        if fastWindow and FF.fastAutoLootWindow == fastWindow and not fastWindow.cancelled then
            if OtherAddonHandlesFastLoot() then
                fastWindow.cancelled = true
                FF:TraceFishingLoot("Fast Auto Loot yielded to another addon")
            else
                RequestEarlyFishingLoot(FF, fastWindow, recorded, snapshot)
                if FF.fastAutoLootWindow == fastWindow and not OtherAddonHandlesFastLoot() then
                    TryFastFishingLootRate(FF, fastWindow)
                end
            end
        end
        if event == "LOOT_OPENED" and FF.RefreshFishingGamepadInput then FF:RefreshFishingGamepadInput() end
        return
    elseif event == "LOOT_BIND_CONFIRM" then
        FF:InvalidateFishingCapacityRecast()
        if FF.fishingNativeLootPending and FF.BeginFishingLootVisibility then
            FF:BeginFishingLootVisibility(false, true)
        end
        return
    elseif event == "LOOT_SLOT_CHANGED" or event == "LOOT_SLOT_CLEARED" then
        FF:InvalidateFishingCapacityRecast()
        FF:RecordLoot(event, unit)
        return
    elseif event == "PLAYER_SOFT_INTERACT_CHANGED" then
        -- The GUID payload can be secret. Resample only the supported APIs.
        if FF.active and FF.UpdateBobberStatus then FF:UpdateBobberStatus() end
        return
    end
    -- A native first payload is not always a readable unit token (including
    -- events received while Fishing is closed). Never compare private values.
    if issecretvalue and issecretvalue(unit) then return end
    if event:match("^UNIT_SPELLCAST_") then
        if unit ~= "player" then return end
        if issecretvalue then
            if event == "UNIT_SPELLCAST_SENT" then
                -- SENT's target name is unused; its GUID/spell follow it.
                if issecretvalue(castGUID) or issecretvalue(spellID) then return end
            else
                -- Ordinary events are (unit, GUID, spellID, castBarID).
                if issecretvalue(target) or issecretvalue(castGUID) then
                    -- An opaque event GUID must never reach the cast consumers.
                    -- A readable Fishing spell can prompt the existing native
                    -- channel recovery or identity-free stop confirmation.
                    if FF.db and FF:IsFishingSessionOpen() and FishingEventSpell(castGUID) then
                        if event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
                            FF:RecoverFishingChannel(true)
                        elseif FF.active and (event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED") then
                            FF:StopChannel(event, nil, castGUID)
                        end
                    end
                    return
                end
                if castGUID == nil and issecretvalue(spellID) then return end
            end
        end
    end
    -- Presentation only; normal cast events use (unit, GUID, spellID), unlike SENT.
    if FF.db and FF.OnFishingInformationEvent then FF:OnFishingInformationEvent(event,unit,target,castGUID) end
    -- Support legacy message-only errors alongside (errorID, message).
    if event == "UI_ERROR_MESSAGE" and type(target) ~= "string" and type(unit) == "string"
        and not (issecretvalue and issecretvalue(unit)) then
        target, unit = unit, nil
    end
    if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        FF:UpdateFishingVisibilityRoot()
        if FF.ApplyIconBarSpacing then FF:ApplyIconBarSpacing() end
        return
    elseif event == "ADDON_LOADED" then
        if unit == "Blizzard_Settings" and startupLocalizationReady and FF.RegisterFishingWelcomePage then
            RunFishingStartupStep("welcome page", FF.RegisterFishingWelcomePage)
        end
        if unit == "SpeedyAutoLoot" or (unit == "Polestar" and PolestarHandlesFastLoot()) then
            if FF.fastAutoLootWindow then FF.fastAutoLootWindow.cancelled = true end
            FF:ReleaseFastAutoLootRate()
        end
        if FF.db then InitializeFishingGamepadSupport() end
        if FF.db and FF.RefreshFishingGamepadInput then FF:RefreshFishingGamepadInput() end
        if FF.OtherFishingAudioLoaded then FF:OtherFishingAudioLoaded(unit) end
        if FF.db and FF.InstallBlizzardPanelHooks then FF:InstallBlizzardPanelHooks() end
        if FF.db and FF.InstallFishingTemporaryPanelHooks then FF:InstallFishingTemporaryPanelHooks() end
        if FF.db and FF.RegisterAuctionPriceUpdates then FF:RegisterAuctionPriceUpdates() end
        if FF.db and (unit == "Auctionator" or unit == "TradeSkillMaster") then FF:InvalidateFishingStats() end
        return
    elseif event == "PLAYER_LOGIN" then
        if not RunFishingStartupStep("Fishing Bar", InitializeFishingAtLogin) then
            FF.fishingStartupFailed = true
            FF.fishingStartupBindingsPending = not ClearFailedStartupBindings() or nil
            FF:ReportFishingStartupFailure()
        else
            if not RunFishingStartupStep("rod auto-open", function() FF:CheckFishingRodAutoOpen(true) end) then
                FF.rodAutoOpenStartupFailed = true
                FF.rodAutoOpenPending, FF.rodAutoOpenItemInfo = nil, nil
                FF:Print(FF:LocalizedText("startup.rod-auto-open"))
            end
            RunFishingStartupStep("channel recovery", function()
                if IsFishingChannel() then FF:StartChannel(true) end
            end)
        end
        if startupLocalizationReady and FF.InitializeMinimapIcon and not RunFishingStartupStep("minimap", FF.InitializeMinimapIcon) then
            FF.fishingMinimapStartupFailed = true
            FF:Print(FF:LocalizedText("runtime.minimap-unavailable"))
        end
        if startupLocalizationReady and FF.RegisterFishingWelcomePage then
            RunFishingStartupStep("welcome page", FF.RegisterFishingWelcomePage)
        end
        return
    elseif event == "PLAYER_LEAVING_WORLD" then
        if FF.RefreshFishingBagSpace then FF:RefreshFishingBagSpace(true) end
        FF.restrictedFishingReel = nil
        FF.fishingReelLootHandoff, FF.fishingReelLootWindow = nil, nil
        if FF.EndFishingLootVisibility then FF:EndFishingLootVisibility() end
        FF.fastAutoLootWindow = nil
        FF:ReleaseFastAutoLootRate()
        if FF.ResetFishingLootObservation then FF:ResetFishingLootObservation() end
        FF.gamepadBindingRefresh=nil
        FF.gamepadInputLeavingWorld=true
        if FF.gamepadChordBindingOwner and SafeOutOfCombat() then ClearOverrideBindings(FF.gamepadChordBindingOwner) end
        FF:CancelFishingItemRefresh(true)
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache() end
        if FF.CancelNormalWeaponCapture then FF:CancelNormalWeaponCapture() end
        FF:ClearFishingChannelRecovery()
        if FF.ClearFishingLureApplication then FF:ClearFishingLureApplication() end
        if FF.InterruptKeyCapture then FF:InterruptKeyCapture() end
        FF:RestoreCVars("bobberIconRestore")
        if FF.SuspendGearOperation then FF:SuspendGearOperation() end
        if FF.InvalidateMasterChefRecipeCatalogs then FF:InvalidateMasterChefRecipeCatalogs() end
        if FF.ReleaseMasterChefCampSession then FF:ReleaseMasterChefCampSession() end
        if FF.masterChefCookingActive then
            local quick = FF.masterChefCookingQuickActive
            FF.masterChefCookingActive = nil
            FF.masterChefCookingRemaining = nil
            FF.masterChefCraftToken = (FF.masterChefCraftToken or 0) + 1
            if quick then
                FF:SetMasterChefMessage("masterChefQuickMessage", "chef.message.cooking-stopped-click")
            else
                FF:SetMasterChefMessage("masterChefQueueMessage", "chef.message.cooking-stopped-start")
            end
        end
        if FF.ReleaseMasterChefCookingSession then FF:ReleaseMasterChefCookingSession() end
        FF:RestoreCVars("cameraCenterRestore")
        FF:RestoreCVars("cameraViewBlendRestore")
        FF:RestoreCVars("cameraZoomRestore")
        FF:RestoreCVars("cameraDistanceRestore")
        FF:ReleaseFishingFOV(true)
        FF:SuspendFishingSounds()
        FF:FocusSplashSound()
        return
    elseif event == "PLAYER_ENTERING_WORLD" then
        FF.gamepadInputLeavingWorld=nil
        if FF.RefreshFishingGamepadInput then FF:RefreshFishingGamepadInput() end
        FF:CancelFishingItemRefresh(false)
        FF:SyncBobberInteractIcon()
        FF.gearWorldInterrupted = nil
        if FF.InvalidateMasterChefRecipeCatalogs then FF:InvalidateMasterChefRecipeCatalogs() end
        if FF.RefreshFishingAchievements then FF:RefreshFishingAchievements(false, true) end
        FF.soundAlertsSuspended = false
        FF:SyncLongRangeCameraDistance()
        FF:SyncFishingFOV()
        FF:FocusSplashSound()
        FF:SyncFishingSounds()
        if FF.RefreshFishingBagSpace then FF:RefreshFishingBagSpace(false) end
        -- Equipped items can become readable after PLAYER_LOGIN on a fresh login.
        -- A repeated check keeps the same-rod guard, so zoning will not reopen
        -- a fishing bar the player closed manually.
        FF:CheckFishingRodAutoOpen(FF.rodAutoOpenItemInfo ~= nil)
        if FF.journalTab == "nearby" and FF.RefreshJournal then FF:RefreshJournal() end
        return
    elseif event == "PLAYER_LOGOUT" then
        FF.fishingReelLootHandoff, FF.fishingReelLootWindow = nil, nil
        FF.fastAutoLootWindow = nil
        FF:ReleaseFastAutoLootRate()
        FF:CancelFishingItemRefresh(true)
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache() end
        if FF.CancelNormalWeaponCapture then FF:CancelNormalWeaponCapture() end
        FF:ClearFishingChannelRecovery()
        if FF.ClearFishingLureApplication then FF:ClearFishingLureApplication() end
        if FF.InterruptKeyCapture then FF:InterruptKeyCapture() end
        if FF.SuspendGearOperation then FF:SuspendGearOperation() end
        if not FF.dataResetPendingReload and FF.CommitOpenFloatingWindowLayouts then FF:CommitOpenFloatingWindowLayouts() end
        if FF.ReleaseMasterChefCampSession then FF:ReleaseMasterChefCampSession() end
        if FF.ReleaseMasterChefCookingSession then FF:ReleaseMasterChefCookingSession() end
        FF:RestoreCVars("cameraCenterRestore")
        FF:RestoreCVars("cameraViewBlendRestore")
        FF:RestoreCVars("cameraZoomRestore")
        FF:RestoreCVars("cameraDistanceRestore")
        FF:SuspendFishingSounds()
        FF:StopCameraMotion()
        FF:ReleaseFishingFOV(true)
        if not (FF.fishingStartupFailed or FF.dataResetPendingReload) then
            if FF.RememberNormalWeapons then FF:RememberNormalWeapons() end
            FF:AccrueLifetimeFishingTime()
            FF:FinishHistoricalSession("logout")
        end
        FF:RestoreCVars("interactRestore")
        FF:RestoreCVars("bobberIconRestore")
        FF:RestoreCVars("soundRestore")
        FF:RestoreCVars("backgroundFPSRestore")
        FF:RestoreCVars("autoLootRestore")
        if FF.ReleaseFishingUIVisibility then FF:ReleaseFishingUIVisibility(true) end
        return
    end
    if event == "CURRENT_SPELL_CAST_CHANGED" and FF.CheckMasterChefCampPlacement then
        FF:CheckMasterChefCampPlacement(event, unit)
    elseif (event == "UI_INFO_MESSAGE" or event == "UI_ERROR_MESSAGE") and type(target) == "string"
        and not (issecretvalue and issecretvalue(target)) then
        if event == "UI_ERROR_MESSAGE" then
            local gearHandled = FF.OnGearSwapUIError and FF:OnGearSwapUIError(target, unit)
            if not gearHandled then
                local handled = FF.OnMasterChefCraftUIError and FF:OnMasterChefCraftUIError(target, unit)
                local placementHandled = not handled and FF.OnMasterChefUIError and FF:OnMasterChefUIError(target, unit)
                if not handled and not placementHandled then FF:ObserveFishingCapacityError(target, unit) end
                if handled and FF.RefreshMasterChefQuickTray then FF:RefreshMasterChefQuickTray() end
            end
        end
        FF:OnFishingEscapeMessage(target)
        FF:ObserveFishingEmptyReel(target, unit)
        local lower = (target:gsub("[A-Z]",string.lower))
        local identity=FF:GetNativeErrorName(unit)
        local nativeRodError=identity=="SPELL_FAILED_EQUIPPED_ITEM_CLASS"
            and FF.lastFishingCastAttemptAt and GetTime()-FF.lastFishingCastAttemptAt<=5
            and FF.FishingRodEquippedNow and FF:FishingRodEquippedNow()==false
        if event == "UI_ERROR_MESSAGE" and (nativeRodError or (lower:find("fishing pole", 1, true) and lower:find("equip", 1, true))) then
            FF:OnFishingRodRequired(true)
        elseif FF:MatchesNativeError(target,{"SPELL_FAILED_NOT_FISHABLE","SPELL_FAILED_TOO_SHALLOW","SPELL_FAILED_NO_FISH"},unit)
            or (target == (SPELL_FAILED_TOO_SHALLOW or "Water too shallow")) then
            FF:OnFishingCastFailed()
        end
    elseif event == "UNIT_SPELLCAST_SENT" and unit == "player" then
        if FF.fishingChannelStartPending and (spellID ~= FF.fishingChannelStartPending.spell
            or castGUID ~= FF.fishingChannelStartPending.guid) then FF:ClearFishingChannelRecovery() end
        if FF.OnFishingLureEvent then FF:OnFishingLureEvent(event, spellID, castGUID) end
        if FF.OnAchievementLureEvent then FF:OnAchievementLureEvent(event, spellID, castGUID) end
        FF:OnFishingCastSent(spellID)
        if FF.OnMasterChefCraftSent then FF:OnMasterChefCraftSent(spellID, castGUID) end
    elseif event == "UNIT_SPELLCAST_FAILED_QUIET" and unit == "player" then
        if FF.fishingLootTrace and FF.fishingLootTrace.recast and FishingEventSpell(castGUID) then
            FF:TraceFishingLoot("Native Fishing cast rejected quietly")
        end
        if FF.OnFishingLureEvent and FF:OnFishingLureEvent(event, castGUID, target) then FF:RefreshUI() end
        if FF.OnAchievementLureEvent then FF:OnAchievementLureEvent(event, castGUID, target) end
        -- Quiet rejection is a terminal craft failure too; keep this separate
        -- from the fishing/lure routing of ordinary cast events.
        if FF.OnMasterChefCraftFailed then FF:OnMasterChefCraftFailed(castGUID, target) end
        if FF.OnMasterChefCampCraftEvent then
            FF:OnMasterChefCampCraftEvent("UNIT_SPELLCAST_FAILED", castGUID, target)
        end
        if FF.RefreshMasterChefQuickTray then FF:RefreshMasterChefQuickTray() end
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" and unit == "player" then
        if FishingEventSpell(castGUID) then FF:RecoverFishingChannel(true) end
        local active,started,ends=IsFishingChannel()
        if FF.active and active and started==FF.castStart then
            FF.castEnd=ends or FF.castEnd
            if FF.UpdateFishingInformation then FF:UpdateFishingInformation() end
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" and unit == "player" then
        if FF.fishingLootTrace and FF.fishingLootTrace.recast and FishingEventSpell(castGUID) then
            FF:TraceFishingLoot("Native Fishing channel start")
        end
        FF:StartChannel(nil, target, castGUID)
    elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED") and unit == "player" then
        if FF.OnAchievementLureEvent then FF:OnAchievementLureEvent(event, castGUID, target) end
        FF:StopChannel(event, target, castGUID)
        if FF.ShowNextAchievementNotice then FF:ShowNextAchievementNotice() end
        if event == "UNIT_SPELLCAST_INTERRUPTED" then
            if FF.OnMasterChefCampCraftEvent then FF:OnMasterChefCampCraftEvent(event, castGUID, target) end
            if FF.OnMasterChefCampPlacementEvent then FF:OnMasterChefCampPlacementEvent(event, castGUID) end
        end
        if event == "UNIT_SPELLCAST_INTERRUPTED" and FF.OnMasterChefCraftFailed then
            FF:OnMasterChefCraftFailed(castGUID, target)
        end
        if event == "UNIT_SPELLCAST_INTERRUPTED" and FF.OnFishingLureEvent
            and FF:OnFishingLureEvent(event, castGUID, target) then FF:RefreshUI() end
    elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SUCCEEDED") and unit == "player" then
        -- UNIT_SPELLCAST_* uses (unit, castGUID, spellID, castBarID).
        -- SENT instead has a target before the cast GUID.
        local failedSpellID = castGUID or spellID
        if FF.fishingLootTrace and event == "UNIT_SPELLCAST_FAILED" and FishingEventSpell(failedSpellID) then
            FF:TraceFishingLoot("Native Fishing cast failed")
        end
        local lureChanged = FF.OnFishingLureEvent and FF:OnFishingLureEvent(event, failedSpellID, target)
        if FF.OnAchievementLureEvent then FF:OnAchievementLureEvent(event, failedSpellID, target) end
        if event == "UNIT_SPELLCAST_START" and FF.OnMasterChefCraftStarted then
            FF:OnMasterChefCraftStarted(failedSpellID, target)
        end
        if FF.OnMasterChefCampCraftEvent then FF:OnMasterChefCampCraftEvent(event, failedSpellID, target) end
        if FF.OnMasterChefCampPlacementEvent then FF:OnMasterChefCampPlacementEvent(event, failedSpellID) end
        if event == "UNIT_SPELLCAST_SUCCEEDED" and FF.OnMasterChefCraftSucceeded then
            FF:OnMasterChefCraftSucceeded(failedSpellID, target)
        elseif event == "UNIT_SPELLCAST_FAILED" and FF.OnMasterChefCraftFailed then
            FF:OnMasterChefCraftFailed(failedSpellID, target)
        end
        if (event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_FAILED")
            and FF.RefreshMasterChefQuickTray then FF:RefreshMasterChefQuickTray() end
        if event == "UNIT_SPELLCAST_FAILED" and FF.soundCastPending and type(failedSpellID) == "number"
            and not (issecretvalue and issecretvalue(failedSpellID))
            and (failedSpellID == 7620 or failedSpellID == FISHING_SPELL or failedSpellID == FISHING_CAST) then
            FF:OnFishingCastFailed()
        end
        if lureChanged or (FF.db and (FF.db.autoEquipGear or FF.db.autoEquipLures)
            and FF.bar and FF.bar:IsShown()) then FF:RefreshUI() end
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache(unit) end
        if target and FF.NormalWeaponItemDataReceived then FF:NormalWeaponItemDataReceived(unit) end
        if FF.JournalFoodItemDataReceived then FF:JournalFoodItemDataReceived(unit,target) end
        FF.combatWeaponPlanDirty = true
        FF:RefreshCatchItemName(unit, target)
        if target and FF.RefreshCatchRecapItem then FF:RefreshCatchRecapItem(unit) end
        local qualityRequested = FF.requestedCatchQualityItems and FF.requestedCatchQualityItems[unit]
        if qualityRequested then FF.requestedCatchQualityItems[unit] = nil end
        if not target and FF.requestedCatchValueItems then FF.requestedCatchValueItems[unit] = nil end
        if target and FF.db and FF.db.journal and FF.db.journal[unit] then
            FF:QueueFishingItemRefresh()
        end
        if qualityRequested and target and FF.RefreshCatchItemQuality then FF:RefreshCatchItemQuality(unit) end
        if unit == FF.rodAutoOpenItemInfo then
            FF.rodAutoOpenItemInfo = nil
            if target then FF:CheckFishingRodAutoOpen(true) end
        end
    elseif event == "ITEM_DATA_LOAD_RESULT" then
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache(unit) end
    elseif event == "TOOLTIP_DATA_UPDATE" then
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache(nil,unit) end
    elseif event == "LOOT_CLOSED" then
        local resumeReelInput = FF.fishingReelLootHandoff or FF.fishingReelLootWindow
        FF.fishingReelLootHandoff, FF.fishingReelLootWindow = nil, nil
        FF:TraceFishingLoot(event)
        FF.fastAutoLootWindow = nil
        FF:ReleaseFastAutoLootRate()
        if FF.EndFishingLootVisibility then FF:EndFishingLootVisibility() end
        FF:CloseFishingLoot()
        if resumeReelInput then FF:RefreshFishingReelLootInput() end
        if FF.fishingLootTrace and resumeReelInput then
            FF.fishingLootTrace.lastGuardMode = nil
            FF:TraceFishingLoot("Fishing Key after loot close: " .. FF:BindingMode()
                .. "; binding " .. BindingAction(SelectedFishingKey(FF)))
        end
        if FF.RefreshFishingGamepadInput then FF:RefreshFishingGamepadInput() end
    elseif event == "PLAYER_REGEN_DISABLED" then
        FF:ReleaseFastAutoLootRate()
        if FF.gearOperation then FF:StopLocalizedGearOperation(FF.gearOperation,
            "gear.failure.combat") end
        if FF.InterruptKeyCapture then FF:InterruptKeyCapture() end
        if FF.HideAchievementNotice then FF:HideAchievementNotice() end
        if FF.SuspendMasterChefPreparation then FF:SuspendMasterChefPreparation("combat") end
    elseif event == "MODIFIER_STATE_CHANGED" then
        FF:RefreshFishingGamepadModifiers()
    elseif event == "INPUT_DEVICE_INTERFACE_TRANSITION" or event == "GAME_PAD_CONNECTED" or event == "GAME_PAD_DISCONNECTED" then
        if event == "GAME_PAD_CONNECTED" then FF.gamepadDisconnected=nil
        elseif event == "GAME_PAD_DISCONNECTED" then
            local connected=false
            if C_GamePad and type(C_GamePad.GetAllDeviceIDs)=="function" then
                local ok,ids=pcall(C_GamePad.GetAllDeviceIDs);connected=ok and type(ids)=="table" and next(ids)~=nil
            end
            FF.gamepadDisconnected=not connected
        end
        -- The default prompt only accepts plain A/B. Its paired release
        -- remains valid when WoW changes interfaces during the press.
        if FF.captureVisibility and FF.captureGamepadMode and FF.InterruptKeyCapture
            and not (event == "INPUT_DEVICE_INTERFACE_TRANSITION" and FF.captureGamepadDefaults) then
            FF:InterruptKeyCapture()
        end
        if FF.RefreshFishingGamepadInput then FF:RefreshFishingGamepadInput() end
    elseif event == "UPDATE_BINDINGS" then
        if not FF.db or not SafeOutOfCombat() then return end
        FF:ApplyBindings()
        if FF.settingsPanel and FF.settingsPanel.RefreshBindingControls then FF.settingsPanel:RefreshBindingControls() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if FF.fastAutoLootRateOwner and FF.fastAutoLootRateOwner.releaseRequested then FF:ReleaseFastAutoLootRate() end
        FF:ResumeFishingSoundRestores()
        if FF.pendingFishingBarClose and FF.FinishFishingBarClose then FF:FinishFishingBarClose() end
        -- Reconcile current channel/session intent before draining old CVar
        -- ownership; never restore underneath a newer active fishing channel.
        if FF.active and FF.db and FF.db.interactAssist ~= false and FF.bar and FF.bar:IsShown() then
            FF:PrepareInteract()
        else
            FF:RestoreCVars("interactRestore")
        end
        if FF.pendingSettingsMenuClose then
            FF.pendingSettingsMenuClose:Hide()
            FF.pendingSettingsMenuClose = nil
        end
        if FF.ApplyPendingFishingLayouts then FF:ApplyPendingFishingLayouts() end
        if FF.RegisterPendingCombatCloseWindows then FF:RegisterPendingCombatCloseWindows() end
        if FF.ResumeMasterChefWindowClose then FF:ResumeMasterChefWindowClose() end
        if FF.ResumeFishingUIVisibility then FF:ResumeFishingUIVisibility() end
        if FF.SyncSessionTrackerVisibility then FF:SyncSessionTrackerVisibility() end
        if FF.SyncSessionGoalsVisibility then FF:SyncSessionGoalsVisibility() end
        if FF.ShowPendingJournalPresentation then FF:ShowPendingJournalPresentation() end
        if FF.ShowNextAchievementNotice then FF:ShowNextAchievementNotice() end
        FF:TryFishingRodAutoOpen()
        FF:RefreshFishingLayer()
        if FF.active and FF.UpdateBobberStatus then FF:UpdateBobberStatus() end
        FF:RefreshCastMacro()
        FF:ApplyBindings()
        if FF.SyncCastAction then FF:SyncCastAction() end
        FF:RefreshUI()
        if FF.RefreshMasterChefQuickTray then FF:RefreshMasterChefQuickTray() end
    elseif event == "CVAR_UPDATE" then
        if type(unit)=="string" and unit:lower():match("^gamepademulate") then
            if FF.captureVisibility and FF.captureGamepadMode and FF.InterruptKeyCapture then FF:InterruptKeyCapture() end
            FF:RefreshFishingGamepadInput()
            if FF.settingsPanel and FF.settingsPanel.RefreshBindingControls then FF.settingsPanel:RefreshBindingControls() end
        end
        FF:SplashSoundCVarChanged(unit)
        FF:AutoLootCVarChanged(unit)
        FF:CameraCVarChanged(unit)
        if FF.active and type(unit) == "string" and FF.castStart and GetTime() - FF.castStart > 0.2 then
            local name = unit:lower()
            if name == "softtargetinteract" or name == "softtargetinteractarc" or name == "softtargetinteractrange" then
                FF:TraceTransition("interact setting changed: " .. unit .. "=" .. (ReadCVar(unit) or "?"))
            end
        end
        if type(unit) == "string" and unit:lower() == BACKGROUND_SOUND_CVAR:lower() and FF.RefreshBackgroundSoundSetting then
            FF:RefreshBackgroundSoundSetting()
        end
        if type(unit) == "string" and FF.RefreshGameSoundSliders then
            local name = unit:lower()
            if name == "sound_mastervolume" or name == "sound_ambiencevolume" or name == "sound_musicvolume"
                or name == "sound_dialogvolume" then
                FF:RefreshGameSoundSliders()
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if FF.restrictedFishingReel and FF.UpdateBobberStatus then FF:UpdateBobberStatus() end
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
        FF.journalLocationRevision = (FF.journalLocationRevision or 0) + 1
        if FF.journalPanel and FF.journalPanel:IsShown() then FF:RefreshJournal() end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if unit == "player" then
            FF:CheckFishingRodAutoOpen(FF.rodAutoOpenItemInfo ~= nil)
            if FF.SyncSessionRodTime then FF:SyncSessionRodTime() end
            FF:RefreshUI()
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if FF.UpdateFishingInformation then FF:UpdateFishingInformation(true, unit) end
    elseif event == "SKILL_LINES_CHANGED" or (event == "UNIT_AURA" and unit == "player") then
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache() end
        if FF.UpdateFishingInformation then FF:UpdateFishingInformation(true) end
        if event == "SKILL_LINES_CHANGED" then FF.journalSearchIndexRevision = nil end
        if event == "SKILL_LINES_CHANGED" and FF.InvalidateMasterChefRecipeCatalogs then FF:InvalidateMasterChefRecipeCatalogs() end
        if event == "SKILL_LINES_CHANGED" and FF.ScanMasterChefCooking then FF:ScanMasterChefCooking() end
        if event == "SKILL_LINES_CHANGED" and FF.RefreshFishingAchievements then FF:RefreshFishingAchievements(true, true) end
        if FF.RefreshJournal then FF:RefreshJournal() end
        if event == "SKILL_LINES_CHANGED" and FF.RefreshMasterChefQuickTray then
            FF:RefreshMasterChefQuickTray()
        end
    elseif event == "TRADE_SKILL_CLOSE" then
        if FF.InvalidateMasterChefRecipeCatalogs then FF:InvalidateMasterChefRecipeCatalogs() end
        if FF.OnMasterChefCampSessionEvent then FF:OnMasterChefCampSessionEvent(event) end
        if FF.OnMasterChefCookingSessionClosed then FF:OnMasterChefCookingSessionClosed() end
    elseif event == "UPDATE_TRADESKILL_CAST_STOPPED" then
        if FF.OnMasterChefCraftStopped then FF:OnMasterChefCraftStopped() end
        if FF.OnMasterChefCampCraftStopped then FF:OnMasterChefCampCraftStopped() end
    elseif event == "NEW_RECIPE_LEARNED" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_LIST_UPDATE"
        or event == "TRADE_SKILL_UPDATE"
        or event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
        FF.journalSearchIndexRevision = nil
        if FF.InvalidateMasterChefRecipeCatalogs then FF:InvalidateMasterChefRecipeCatalogs() end
        if FF.OnMasterChefCampSessionEvent then FF:OnMasterChefCampSessionEvent(event) end
        if FF.RefreshMasterChefCookingFromEvent then FF:RefreshMasterChefCookingFromEvent() end
        if FF.RefreshFishingAchievements then FF:RefreshFishingAchievements(true, true) end
        if FF.ReviewMasterChefCookingSession then FF:ReviewMasterChefCookingSession(event) end
        if FF.RefreshMasterChefQuickTray then FF:RefreshMasterChefQuickTray() end
    elseif event == "BAG_UPDATE_DELAYED" then
        if FF:HasFishingCapacityRecast() then FF:InvalidateFishingCapacityRecast() end
        FF.combatWeaponPlanDirty = true
        if FF.RefreshFishingInventoryOnBagUpdate then FF:RefreshFishingInventoryOnBagUpdate()
        elseif FF.ScanFishingInventory then FF:ScanFishingInventory() end
        if FF.RefreshFishingBagSpace then FF:RefreshFishingBagSpace() end
        FF:RefreshUI(true)
        if FF.RefreshJournal then FF:RefreshJournal() end
        if FF.RefreshMasterChefQuickTray then FF:RefreshMasterChefQuickTray() end
    elseif event == "UPDATE_MACROS" then
        FF:RefreshCastMacro()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache() end
        if unit == 16 and FF.ClearFishingLureApplication then FF:ClearFishingLureApplication() end
        FF.combatWeaponPlanDirty = true
        if FF.OnGearEquipmentChanged then FF:OnGearEquipmentChanged(unit) end
        if unit == 16 then
            FF:CheckFishingRodAutoOpen()
            if FF.SyncSessionRodTime then FF:SyncSessionRodTime() end
            -- A manually equipped pole may already be on an open bar. Save its
            -- restore pair before a later manual weapon change replaces it.
            if FF.bar and FF.bar:IsShown() and FF.RememberWornFishingGear then FF:RememberWornFishingGear(true) end
        end
        if (unit == 16 or unit == 17) and FF.QueueNormalWeaponCapture then FF:QueueNormalWeaponCapture() end
        FF:RefreshUI()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        FF:CancelFishingItemRefresh()
        if FF.InvalidateFishingInventoryCache then FF:InvalidateFishingInventoryCache() end
        FF.combatWeaponPlanDirty = true
        if FF.QueueNormalWeaponCapture then FF:QueueNormalWeaponCapture() end
    elseif event == "EQUIPMENT_SWAP_FINISHED" then
        FF.combatWeaponPlanDirty = true
        if (unit == true or unit == 1) and FF.QueueNormalWeaponCapture then FF:QueueNormalWeaponCapture(target) end
    elseif event == "EQUIPMENT_SETS_CHANGED" then
        FF.combatWeaponPlanDirty = true
        if FF.QueueNormalWeaponCapture then FF:QueueNormalWeaponCapture() end
    end
end)
