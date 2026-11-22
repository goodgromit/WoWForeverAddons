-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Forever owns fishing audio when both addons are installed. Change only
-- the two known Fishing Log options. Guard its known Music entry point before
-- it can recapture our mix; never intercept global CVars or unrelated features.
local FF = _G.ForeverFishing
local state
local claimedAPI, claimingAPI
local musicGuard, splashAPI, splashClaiming

local function SuppressSupportedSoundHelper()
    -- Fishing Log releases its own FishFry claim when its splash option is
    -- disabled. Hold our own claim so that handoff cannot enable a third owner.
    local peer = _G.FishFry
    local api = type(peer) == "table" and peer.Compat
    if type(api) ~= "table" or type(api.GetAPIVersion) ~= "function"
        or type(api.IsFeatureSupported) ~= "function" or type(api.Suppress) ~= "function" then return true end
    if claimedAPI == api then return true end
    if claimingAPI then return false end
    local ok, version = pcall(api.GetAPIVersion, api)
    if not ok or (tonumber(version) or 0) < 1 then return true end
    local supported
    ok, supported = pcall(api.IsFeatureSupported, api, "sound.fishingHelper")
    if not ok or supported ~= true then return true end
    claimingAPI = api
    local result
    ok, result = pcall(api.Suppress, api, "ForeverFishing", "sound.fishingHelper")
    claimingAPI = nil
    if not ok or result ~= true then return false end
    claimedAPI = api
    return true, true
end

local function RememberChoice(self, key, value)
    if self.db.audioAddonOriginals == nil then self.db.audioAddonOriginals = {} end
    local originals = self.db.audioAddonOriginals
    if type(originals) ~= "table" then return end
    if originals.TheFishingLog == nil then originals.TheFishingLog = {} end
    local saved = originals.TheFishingLog
    if type(saved) == "table" and saved[key] == nil then saved[key] = value end
end

local function CurrentMusic()
    if type(GetCVar) ~= "function" then return end
    local ok, value = pcall(GetCVar, "Sound_MusicVolume")
    if not ok or (issecretvalue and issecretvalue(value)) then return end
    value = tonumber(value)
    if value and value == value and value >= 0 and value <= 1 then return value end
end

local function FishingLogVersion()
    local get = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    if type(get) ~= "function" then return end
    local ok, version = pcall(get, "TheFishingLog", "Version")
    if ok then return version end
end

local function GuardFishingLogMusic(self, peer)
    if musicGuard and musicGuard.peer == peer then
        -- Another addon may wrap or replace the method later. Never overwrite
        -- that replacement or add another wrapper around it.
        return
    end
    if FishingLogVersion() ~= "1.0.3" or type(peer.UpdateFishingMusic) ~= "function" then return end
    local original = peer.UpdateFishingMusic
    local guard = {peer=peer, original=original}
    guard.wrapper = function(owner, ...)
        if owner == peer and self.db and type(owner.db) == "table"
            and type(owner.db.settings) == "table" and owner.db.settings.muteMusicWithPole == true then
            RememberChoice(self, "muteMusicWithPole", true)
            owner.db.settings.muteMusicWithPole = false
        end
        -- Keep the original release/combat/return behavior. There is no
        -- session handoff, recapture, resume step or new volume write here.
        return original(owner, ...)
    end
    musicGuard = guard
    peer.UpdateFishingMusic = guard.wrapper
end

local function SuppressFishingLogSplash(peer)
    local api = peer.Compat
    if type(api) ~= "table" or type(api.GetAPIVersion) ~= "function"
        or type(api.IsFeatureSupported) ~= "function" or type(api.Suppress) ~= "function" then return true end
    if splashAPI == api then return true end
    if splashClaiming then return false end
    local ok, version = pcall(api.GetAPIVersion, api)
    if not ok or (tonumber(version) or 0) < 1 then return true end
    local supported
    ok, supported = pcall(api.IsFeatureSupported, api, "sound.fishingHelper")
    if not ok or supported ~= true then return true end
    splashClaiming = api
    local result
    ok, result = pcall(api.Suppress, api, "ForeverFishing", "sound.fishingHelper")
    splashClaiming = nil
    if not ok or result ~= true then return false end
    splashAPI = api
    return true, true
end

function FF:PrepareFocusAudioCompatibility()
    local peer = _G.TheFishingLog
    if not self.db then return true end
    if type(peer) ~= "table" then return SuppressSupportedSoundHelper() end
    -- ADDON_LOADED can precede the peer's saved-data initialization. Protect
    -- its entry point before a login/equipment callback can borrow our mix.
    GuardFishingLogMusic(self, peer)
    if type(peer.db) ~= "table" or type(peer.db.settings) ~= "table" then
        local splashReady, splashChanged = SuppressFishingLogSplash(peer)
        local helperReady, helperChanged = SuppressSupportedSoundHelper()
        return splashReady and helperReady, splashChanged or helperChanged
    end
    if not state or state.peer ~= peer or state.db ~= peer.db then
        state = {peer=peer, db=peer.db}
    end
    if state.preparing then return false end
    local settings, changed = peer.db.settings, false
    for _, key in ipairs({"muteMusicWithPole", "loudSplash"}) do
        if settings[key] == true then
            RememberChoice(self, key, true)
            settings[key] = false
            changed = true
            if key == "loudSplash" then state.splashReleased = nil end
        end
    end
    state.preparing = true
    -- Retire an existing borrowed mix before Forever captures any baseline.
    -- The peer keeps its own Music receipt if combat/native failure blocks it.
    local ready = true
    if peer.db.musicVolumeRestore ~= nil then
        changed = true
        local current = CurrentMusic()
        local snapshot = self.db.soundRestore
        local entry = type(snapshot) == "table" and snapshot.Sound_MusicVolume
        local ours = type(entry) == "table" and current and
            (tonumber(entry.applied) == current or tonumber(entry.pendingTarget) == current)
        if not current then ready = false
        elseif current ~= 0 and not ours then
            -- The peer only applies zero. A readable later edit is sovereign;
            -- preserve its obsolete receipt without letting it overwrite that edit.
            RememberChoice(self, "retiredMusicOriginal", peer.db.musicVolumeRestore)
            peer.db.musicVolumeRestore = nil
        elseif type(peer.UpdateFishingMusic) == "function" then
            local ok = pcall(peer.UpdateFishingMusic, peer, true)
            ready = ok and peer.db.musicVolumeRestore == nil
        else ready = false end
    end
    if not state.splashReleased and type(peer.RestoreSplashVolume) == "function" then
        local ok = pcall(peer.RestoreSplashVolume, peer)
        state.splashReleased = ok
        ready = ready and ok
        changed = true
    end
    local splashReady, splashChanged = SuppressFishingLogSplash(peer)
    local helperReady, helperChanged = SuppressSupportedSoundHelper()
    state.preparing = nil
    return ready and splashReady and helperReady, changed or splashChanged or helperChanged
end

function FF:OtherFishingAudioLoaded(name)
    if (name ~= "TheFishingLog" and name ~= "FishFry") or not self.db then return end
    self:FocusSplashSound()
    local peer = name == "TheFishingLog" and _G.TheFishingLog or _G.FishFry
    if type(peer) == "table" and not peer.db and C_Timer and C_Timer.After then
        local db = self.db
        C_Timer.After(0, function()
            local current = name == "TheFishingLog" and _G.TheFishingLog or _G.FishFry
            if self.db == db and current == peer then self:FocusSplashSound() end
        end)
    end
end
