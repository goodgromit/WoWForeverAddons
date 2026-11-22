-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local SOUND_KEYS = { range = "rangeSound", recast = "recastReminderSound", catch = "catchConfirmedSound",
    escape = "fishEscapedSound", cooking = "cookingCompleteSound", bagsFull = "fullBagsSound" }
local LOOP_KEYS = { range = "rangeSoundLoop", recast = "recastReminderLoop", bagsFull = "fullBagsSoundLoop" }
FF.recastReminderTiming = { min = 1, max = 60, step = 1, default = 10 }
FF.soundRepeatTiming = { min = 1, max = 15, step = 0.5, default = 3 }
FF.voiceVolumeTiming = { min = 0, max = 100, step = 10, default = 50 }

local function ClampReminderDelay(value)
    local timing = FF.recastReminderTiming
    value = tonumber(value) or timing.default
    if value ~= value then value = timing.default end
    return math.floor(math.max(timing.min, math.min(timing.max, value)) + 0.5)
end

local function ClampRepeatInterval(value)
    local timing = FF.soundRepeatTiming
    value = tonumber(value) or timing.default
    if value ~= value then value = timing.default end
    value = math.max(timing.min, math.min(timing.max, value))
    return math.floor(value / timing.step + 0.5) * timing.step
end

function FF:InitializeSoundSettings()
    if not self:RangeSoundChoice(self.db.rangeSound) then self.db.rangeSound = "ping" end
    if self.db.recastReminderSound == nil then
        -- An enabled old channel cue becomes a reminder; Off stays Off.
        if self.db.channelSound ~= nil then
            self.db.recastReminderSound = self.db.channelSound ~= "off" and "ping" or "off"
        else
            self.db.recastReminderSound = "off"
        end
    end
    if not self:RangeSoundChoice(self.db.recastReminderSound) then self.db.recastReminderSound = "off" end
    if not self:RangeSoundChoice(self.db.catchConfirmedSound) then self.db.catchConfirmedSound = "off" end
    if self.db.fishEscapedSound == nil then self.db.fishEscapedSound = self.db.catchConfirmedSound end
    if not self:RangeSoundChoice(self.db.fishEscapedSound) then self.db.fishEscapedSound = "off" end
    if not self:RangeSoundChoice(self.db.cookingCompleteSound) then self.db.cookingCompleteSound = "chime" end
    local fullBags = self:RangeSoundChoice(self.db.fullBagsSound)
    if not fullBags or fullBags.voice then self.db.fullBagsSound = "ping" end
    self.db.fullBagsSoundLoop = self.db.fullBagsSoundLoop == true
    if self.db.enableAlertSounds == nil then self.db.enableAlertSounds = true end
    self.db.channelSound = nil
    if self.db.rangeSoundLoop == nil then self.db.rangeSoundLoop = true end
    self.db.rangeSoundLoop = self.db.rangeSoundLoop == true
    self.db.recastReminderLoop = self.db.recastReminderLoop == true
    self.db.recastReminderDelay = ClampReminderDelay(self.db.recastReminderDelay)
    self.db.soundRepeatInterval = ClampRepeatInterval(self.db.soundRepeatInterval)
    if not self.db.voiceVolumeDefaultVersion then
        -- Earlier releases saved 100 as the default. Move that default once;
        -- leave lower custom values and later explicit choices untouched.
        if self.db.voiceVolume == 100 then self.db.voiceVolume = 50 end
        self.db.voiceVolumeDefaultVersion = 1
    end
    local volume = tonumber(self.db.voiceVolume)
    if not volume or volume ~= volume then volume = self.voiceVolumeTiming.default end
    self.db.voiceVolume = math.floor(math.max(0, math.min(100, volume)) / 10 + 0.5) * 10
end

function FF:NotificationRepeatEnabled()
    return self.db.rangeSoundLoop or self.db.recastReminderLoop or self.db.fullBagsSoundLoop
end

function FF:SoundRepeatDelay(choice)
    return math.max(self.db.soundRepeatInterval, choice and choice.minimumRepeatDelay or 0)
end

local function State(self, kind)
    self.soundAlerts = self.soundAlerts or {}
    self.soundAlerts[kind] = self.soundAlerts[kind] or { token = 0 }
    return self.soundAlerts[kind]
end

local function StopHandle(handle)
    if type(handle) == "number" and StopSound then pcall(StopSound, handle, 120) end
end

local function CancelTimer(state)
    state.token = state.token + 1
    if state.timer then state.timer:Cancel() end
    state.timer = nil
end

function FF:StopFishingSound(kind, reset)
    local state = State(self, kind)
    CancelTimer(state)
    StopHandle(state.handle)
    state.handle = nil
    if reset then state.played, state.success, state.noticePlayedAt, state.heldLootPlayedAt = nil, nil, nil, nil end
end

function FF:StopFishingSoundPreview()
    self.soundPreviewSerial = (self.soundPreviewSerial or 0) + 1
    if self.soundPreviewTimer then self.soundPreviewTimer:Cancel() end
    self.soundPreviewTimer = nil
    StopHandle(self.soundPreviewHandle)
    self.soundPreviewHandle = nil
end

function FF:StopFishingSounds(keepBagAlert)
    self:StopFishingSound("range", true)
    self:StopFishingSound("recast", true)
    self:StopFishingSound("catch", true)
    self:StopFishingSound("escape", true)
    self:StopFishingSound("cooking", true)
    if not keepBagAlert then self:StopFishingSound("bagsFull", true) end
    self:CancelPendingCastSound()
    self.soundIdleSince, self.soundCastWaitUntil = nil, nil
    self:StopFishingSoundPreview()
end

function FF:SuspendFishingSounds()
    self.soundAlertsSuspended = true
    self:StopFishingSounds()
end

function FF:CancelPendingCastSound()
    self.soundCastSerial = (self.soundCastSerial or 0) + 1
    if self.soundCastTimer then self.soundCastTimer:Cancel() end
    self.soundCastTimer = nil
    self.soundCastPending = nil
end

local function CueFor(kind, self)
    if kind == "cooking" then return "cooking_complete" end
    if kind == "catch" then return "catch" end
    if kind == "escape" then return "away" end
    if kind == "recast" then return "recast" end
    return self.db and self.db.cameraAssist and "cursor" or "range"
end

local function PlayNativeSound(choice, cue, voiceVolume)
    if choice and choice.voice and PlaySoundFile then
        voiceVolume = voiceVolume or 100
        if voiceVolume <= 0 then return false end
        local folder = voiceVolume < 100 and ("Volume" .. voiceVolume .. "\\") or ""
        local path = "Interface\\AddOns\\ForeverFishing\\Media\\Voices\\" .. folder .. choice.voice .. "_" .. cue .. ".ogg"
        local ok, playing, handle = pcall(PlaySoundFile, path, "Master")
        return ok and playing == true, type(handle) == "number" and handle or nil
    end
    if not choice or not choice.kit or not PlaySound then return false end
    local kit = SOUNDKIT and SOUNDKIT[choice.kit] or choice.fallback
    if not kit then return false end
    local ok, playing, handle = pcall(PlaySound, kit, "Master")
    return ok and playing == true, type(handle) == "number" and handle or nil
end

local function BagsFullChoice(self)
    if not self.db or self.db.enableAlertSounds == false or self.soundAlertsSuspended
        or not self.bar or not self.bar:IsShown() then return end
    local choice = self:RangeSoundChoice(self.db.fullBagsSound)
    if choice and choice.kit then return choice end
end

function FF:PlayFishingBagsFullAlert()
    if not BagsFullChoice(self) then return end
    local state = State(self, "bagsFull")
    -- The same bag-capacity failure can also have just shown the banner.
    if state.noticePlayedAt and GetTime() - state.noticePlayedAt < 0.15 then return end
    if self:PlayFishingSoundAlert("bagsFull") then state.heldLootPlayedAt = GetTime() end
end

function FF:SyncFishingBagsFullAlert(play)
    local choice = BagsFullChoice(self)
    if not choice or not self.fishingBagsFullNotice or not self.fishingBagsFullNotice:IsShown()
        or self.fishingBagsFullNoticeState ~= "shown" then
        self:StopFishingSound("bagsFull", true)
        return
    end
    local state = State(self, "bagsFull")
    if play then
        local now = GetTime()
        if (state.heldLootPlayedAt and now - state.heldLootPlayedAt < 0.15) or self:PlayFishingSoundAlert("bagsFull") then
            state.noticePlayedAt = now
        end
    end
    if self.db.fullBagsSoundLoop then
        if not state.timer then
            self:ScheduleFishingSound("bagsFull", self:SoundRepeatDelay(choice), function()
                self:SyncFishingBagsFullAlert(true)
            end)
        end
    elseif state.timer then CancelTimer(state) end
end

function FF:PreviewFishingSound(kind, id)
    self:StopFishingSoundPreview()
    local choice = self:RangeSoundChoice(id)
    if not choice or not (choice.kit or choice.voice) then return end
    local state = State(self, kind)
    local first = CueFor(kind, self)
    -- Changing a sound can start its active alert. Reuse that first cue, then
    -- preview the second voice line without speaking the first one twice.
    if not (state.lastSound == id and state.lastPlayAt and GetTime() - state.lastPlayAt < 0.15) then
        local _, handle = PlayNativeSound(choice, first, self.db.voiceVolume)
        self.soundPreviewHandle = handle
    end
    if not choice.voice or not C_Timer or not C_Timer.NewTimer then return end
    -- Short voice packs preview only the cue used by the current range mode.
    -- Recast mode still uses its separate out-of-range recording.
    if kind == "range" and choice.singleRangePreview then return end
    local second = kind == "recast" and "failed" or kind == "escape" and "not_hooked"
        or kind == "range" and (first == "cursor" and "range" or "cursor")
    if not second then return end
    local serial = self.soundPreviewSerial
    self.soundPreviewTimer = C_Timer.NewTimer(choice.previewDelay or 1.8, function()
        if serial ~= self.soundPreviewSerial then return end
        self.soundPreviewTimer = nil
        local _, handle = PlayNativeSound(choice, second, self.db.voiceVolume)
        self.soundPreviewHandle = handle
    end)
end

function FF:PlayFishingSoundAlert(kind)
    local state = State(self, kind)
    StopHandle(state.handle)
    local id = self.db[SOUND_KEYS[kind]]
    local played, handle = PlayNativeSound(self:RangeSoundChoice(id), CueFor(kind, self), self.db.voiceVolume)
    state.handle, state.success = handle, played
    if played then state.lastSound, state.lastPlayAt = id, GetTime() end
    return played
end

function FF:ScheduleFishingSound(kind, delay, callback)
    if not C_Timer or not C_Timer.NewTimer then return end
    local state = State(self, kind)
    CancelTimer(state)
    local token = state.token
    state.timer = C_Timer.NewTimer(math.max(0.01, delay), function()
        if state.token ~= token then return end
        state.timer = nil
        callback()
    end)
end

function FF:RangeSoundTitle()
    return self:LocalizedText(self.db.cameraAssist and "sound.cursor-reminder" or "sound.out-of-range")
end

function FF:RangeSoundWanted()
    if self.soundAlertsSuspended or not self.db or self.db.enableAlertSounds == false or not self.active or not self.bar or not self.bar:IsShown()
        or (not self.recastReady and not self.cameraAssistNeeded) then return false end
    if self.soundCastWaitUntil and GetTime() < self.soundCastWaitUntil then return false end
    local fishing, _, ends = self:IsFishingChannelActive()
    if not fishing or (ends and GetTime() >= ends) then return false end
    if self.db.cameraAssist then
        if not self.cameraAssistNeeded or self.cameraScanFailed or self:CameraBobberLocated()
            or self.cameraAssistBobber or self.cameraMarkerDrag then return false end
        local cursorInside = self:CameraMarkerHasCursor()
        return not cursorInside, cursorInside
    end
    return self.recastReady == true
end

function FF:SyncRangeSound(repeatPing)
    local state = State(self, "range")
    local choice = self.db and self:RangeSoundChoice(self.db.rangeSound)
    local wanted, cursorInside
    if choice and (choice.kit or choice.voice) then wanted, cursorInside = self:RangeSoundWanted() end
    if not choice or not (choice.kit or choice.voice) or not wanted then
        -- Returning to the marker re-arms one reminder for this cast. Leaving
        -- it again should prompt even when Repeat Sound is disabled.
        if cursorInside then self.rangeSoundPlayed = false end
        self:StopFishingSound("range")
        return
    end
    if not self.rangeSoundPlayed or repeatPing or (self.db.rangeSoundLoop and state.success == nil) then
        self.rangeSoundPlayed = true
        self:PlayFishingSoundAlert("range")
    end
    if self.db.rangeSoundLoop and state.success then
        if not state.timer then
            self:ScheduleFishingSound("range", self:SoundRepeatDelay(choice), function() self:SyncRangeSound(true) end)
        end
    elseif state.timer then CancelTimer(state) end
end

-- Only pending casts need a short wake-up check. Active fishing has no audio timer.
function FF:FishingAudioBusy()
    local fishing, _, ends = self:IsFishingChannelActive()
    if fishing and (not ends or GetTime() < ends) then return true end
    if UnitCastingInfo then
        local name, _, _, _, castingEnds, _, _, _, spellID = UnitCastingInfo("player")
        if name and (spellID == 7620 or spellID == 131474 or spellID == 131476 or name == self:FishingName()) then
            return true, math.max(0.1, (tonumber(castingEnds) or GetTime() * 1000) / 1000 - GetTime() + 0.05)
        end
    end
    if self.soundCastWaitUntil and GetTime() < self.soundCastWaitUntil then
        return true, self.soundCastWaitUntil - GetTime()
    end
    return false
end

function FF:SyncRecastReminder(repeatPing)
    local state = State(self, "recast")
    local choice = self.db and self:RangeSoundChoice(self.db.recastReminderSound)
    if self.soundAlertsSuspended or self.db.enableAlertSounds == false or not choice or not (choice.kit or choice.voice)
        or not self.bar or not self.bar:IsShown() then
        self:StopFishingSound("recast", true)
        self.soundIdleSince = nil
        return
    end
    local busy, wake = self:FishingAudioBusy()
    if busy then
        self:StopFishingSound("recast", true)
        self.soundIdleSince = nil
        if wake then self:ScheduleFishingSound("recast", wake, function() self:SyncRecastReminder() end) end
        return
    end
    if self.FishingRodEquippedNow and self:FishingRodEquippedNow() == false then
        self:StopFishingSound("recast", true)
        self.soundIdleSince = nil
        return
    end
    local now = GetTime()
    self.soundIdleSince = self.soundIdleSince or now
    local remaining = self.soundIdleSince + self.db.recastReminderDelay - now
    if remaining > 0 then
        if not state.timer then self:ScheduleFishingSound("recast", remaining, function() self:SyncRecastReminder() end) end
        return
    end
    if not state.played or repeatPing then
        state.played = true
        self:PlayFishingSoundAlert("recast")
    end
    if self.db.recastReminderLoop and state.success then
        if not state.timer then
            self:ScheduleFishingSound("recast", self:SoundRepeatDelay(choice), function() self:SyncRecastReminder(true) end)
        end
    elseif state.timer then CancelTimer(state) end
end

function FF:SyncFishingSounds()
    self:SyncRangeSound()
    self:SyncRecastReminder()
end

function FF:OnFishingSoundCastSent()
    local now = GetTime()
    if self.soundCastPending and now - self.soundCastPending < 0.2 then return end
    if self.HideFishingRodWarning then self:HideFishingRodWarning() end
    -- A new cast does not dismiss a still-visible bags warning.
    self:StopFishingSounds(true)
    self.lastFishingCastAttemptAt = now
    self.soundFailureNotified = nil
    self.soundCastWaitUntil = now + 2
    if not self.active and C_Timer and C_Timer.NewTimer then
        self.soundCastPending = now
        local serial = self.soundCastSerial
        local function check()
            if serial ~= self.soundCastSerial then return end
            self.soundCastTimer = nil
            if self.active or self:IsFishingChannelActive() then
                self:CancelPendingCastSound()
            else
                local busy, wake = self:FishingAudioBusy()
                if busy and wake then
                    self.soundCastTimer = C_Timer.NewTimer(math.max(0.05, wake), check)
                else
                    self:OnFishingCastFailed()
                end
            end
        end
        self.soundCastTimer = C_Timer.NewTimer(2, check)
    end
    self:SyncRecastReminder()
end

function FF:PlayCookingCompleteAlert()
    if not self.db or self.db.enableAlertSounds == false then return false end
    return self:PlayFishingSoundAlert("cooking")
end

-- A missing pole is a gear instruction, so it cancels the pending failure
-- cue and the idle recast reminder instead of sounding like a bad cast.
function FF:OnFishingRodRequired(fromGameError)
    local now = GetTime()
    if not self.bar or not self.bar:IsShown() then return end
    if not fromGameError and (not self.lastFishingCastAttemptAt
        or now - self.lastFishingCastAttemptAt > 5) then return end
    self.soundFailureNotified = true
    self:CancelPendingCastSound()
    self.soundCastWaitUntil = nil
    self.soundIdleSince = nil
    self:SyncRecastReminder()
    local manual = self.db and self.db.autoEquipGear == false
    if self.lastFishingRodWarningAt and now - self.lastFishingRodWarningAt < 0.5
        and self.lastFishingRodWarningManual == manual then return end
    self.lastFishingRodWarningAt = now
    self.lastFishingRodWarningManual = manual
    if self.ShowFishingRodWarning then self:ShowFishingRodWarning() end
end

-- A rejected Fishing spell can report failure immediately. The pending timer
-- covers clients that report no failure event when the cast misses water.
function FF:OnFishingCastFailed()
    if self.soundFailureNotified or not self.lastFishingCastAttemptAt
        or GetTime() - self.lastFishingCastAttemptAt > 5 then return end
    if self.FishingRodEquippedNow and self:FishingRodEquippedNow() == false then
        self:OnFishingRodRequired()
        return
    end
    self.soundFailureNotified = true
    self:CancelPendingCastSound()
    if self.soundAlertsSuspended or self.db.enableAlertSounds == false or not self.bar or not self.bar:IsShown() then return end
    local choice = self:RangeSoundChoice(self.db.recastReminderSound)
    if choice and (choice.kit or choice.voice) then
        StopHandle(State(self, "recast").handle)
        local _, handle = PlayNativeSound(choice, "failed", self.db.voiceVolume)
        State(self, "recast").handle = handle
    end
    self.soundCastWaitUntil = nil
    self.soundIdleSince = nil
    self:SyncRecastReminder()
end

function FF:OnFishingCatchRecorded()
    if self.soundAlertsSuspended or self.db.enableAlertSounds == false or not self.bar or not self.bar:IsShown() then return end
    local choice = self:RangeSoundChoice(self.db.catchConfirmedSound)
    StopHandle(State(self, "catch").handle)
    local _, handle = PlayNativeSound(choice, "catch", self.db.voiceVolume)
    State(self, "catch").handle = handle
end

function FF:OnFishingEscapeMessage(message)
    if self.soundAlertsSuspended or self.db.enableAlertSounds == false or not self.bar or not self.bar:IsShown() then return end
    if message ~= ERR_FISH_ESCAPED and message ~= ERR_FISH_NOT_HOOKED then return end
    if not self.active and not (self.lastFishingHookAt and GetTime() - self.lastFishingHookAt < 1.5) then return end
    if self.statsCast and self.statsCast.success then return end
    local now = GetTime()
    if self.lastFishingEscapeAt and now - self.lastFishingEscapeAt < 0.5 then return end
    self.lastFishingEscapeAt = now
    local choice = self:RangeSoundChoice(self.db.fishEscapedSound)
    StopHandle(State(self, "escape").handle)
    local cue = message == ERR_FISH_NOT_HOOKED and "not_hooked" or "away"
    local _, handle = PlayNativeSound(choice, cue, self.db.voiceVolume)
    State(self, "escape").handle = handle
end

function FF:SetAlertSoundsEnabled(enabled)
    self.db.enableAlertSounds = enabled == true
    if self.db.enableAlertSounds then
        self:SyncFishingSounds()
        self:SyncFishingBagsFullAlert()
    else
        self:StopFishingSounds()
    end
    if self.RefreshSoundSettings then self:RefreshSoundSettings() end
end

function FF:SetFishingSound(kind, id)
    local choice = self:RangeSoundChoice(id)
    if not SOUND_KEYS[kind] or not choice or (kind == "bagsFull" and choice.voice) then return end
    self.db[SOUND_KEYS[kind]] = id
    self:StopFishingSound(kind)
    if kind == "range" then State(self, kind).success = nil end
    if kind == "range" then self:SyncRangeSound()
    elseif kind == "recast" then self:SyncRecastReminder()
    elseif kind == "bagsFull" then self:SyncFishingBagsFullAlert() end
end

function FF:SetFishingSoundLoop(kind, enabled)
    if not LOOP_KEYS[kind] then return end
    self.db[LOOP_KEYS[kind]] = enabled == true
    if kind == "range" then self:SyncRangeSound()
    elseif kind == "recast" then self:SyncRecastReminder()
    elseif kind == "bagsFull" then self:SyncFishingBagsFullAlert() end
end

function FF:SetRecastReminderDelay(value)
    self.db.recastReminderDelay = ClampReminderDelay(value)
    self:StopFishingSound("recast", true)
    self.soundIdleSince = nil
    self:SyncRecastReminder()
end

function FF:SetSoundRepeatInterval(value)
    local interval = ClampRepeatInterval(value)
    if self.db.soundRepeatInterval == interval then return end
    self.db.soundRepeatInterval = interval
    -- Replace pending repeats without replaying alerts or restarting the idle delay.
    CancelTimer(State(self, "range"))
    CancelTimer(State(self, "recast"))
    CancelTimer(State(self, "bagsFull"))
    self:SyncFishingSounds()
    self:SyncFishingBagsFullAlert()
end

function FF:SetVoiceVolume(value)
    local volume = tonumber(value) or self.voiceVolumeTiming.default
    self.db.voiceVolume = math.floor(math.max(0, math.min(100, volume)) / 10 + 0.5) * 10
    self:StopFishingSoundPreview()
end
