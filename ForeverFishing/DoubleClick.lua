-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local CLICK_WINDOW = 0.4
local MAX_HOLD = 0.2
local MAX_TRAVEL = 12 -- Physical cursor pixels, independent of UI scale.

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function Unmodified()
    return not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown()
end

function FF:DoubleClickEnabled()
    return self.db and self:GetFishingInputKey() == self.doubleRightClickKey and self.bar and self.bar:IsShown()
        and not self.settingsKeyboardFocus and not (self.capture and self.capture:IsShown())
        and not self.journalInputFocus and not self.fishingResetInput
end

function FF:DoubleClickArmed()
    local press = self.doubleClickPress
    local secondHeld = press and press.second and GetTime() - press.at < MAX_HOLD
    return self:DoubleClickEnabled() and not InCombat() and self.doubleClickUntil
        and (GetTime() < self.doubleClickUntil or secondHeld) or false
end

local function WorldClick(self)
    if not Unmodified() then return false end
    local capacityRecast = self.HasFishingCapacityRecast and self:HasFishingCapacityRecast()
    if self.BlizzardPanelOpen and self:BlizzardPanelOpen(false, capacityRecast and LootFrame) then return false end
    if GetMouseFoci then
        local foci = GetMouseFoci() or {}
        for _, focus in ipairs(foci) do
            if focus ~= WorldFrame and focus ~= self.cameraMarker then return false end
        end
        return #foci > 0 or IsMouselooking() or (WorldFrame and WorldFrame:IsMouseOver()) or false
    end
    local focus = GetMouseFocus and GetMouseFocus()
    return focus == WorldFrame or (focus ~= nil and focus == self.cameraMarker) or (focus == nil and IsMouselooking())
end

function FF:ResetDoubleClick(releaseMouseLook)
    self.doubleClickSerial = (self.doubleClickSerial or 0) + 1
    self.doubleClickUntil, self.doubleClickPress, self.doubleClickOrigin = nil, nil, nil
    if self.doubleClickBindingOwner and not InCombat() then ClearOverrideBindings(self.doubleClickBindingOwner) end
    -- Only release mouse look that we started for the overridden second press.
    if self.doubleClickMouseLook and (releaseMouseLook or not IsMouseButtonDown("RightButton")) then
        self.doubleClickMouseLook = nil
        if IsMouselooking() then MouselookStop() end
    end
end

function FF:RefreshDoubleClickWatcher()
    local frame = self.doubleClickWatcher
    if not frame then return end
    local enabled = self:DoubleClickEnabled()
    if frame.enabled == enabled then return end
    frame.enabled = enabled
    self:ResetDoubleClick(not enabled)
    for _, event in ipairs({ "GLOBAL_MOUSE_DOWN", "GLOBAL_MOUSE_UP", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "PLAYER_LEAVING_WORLD" }) do
        if enabled then frame:RegisterEvent(event) else frame:UnregisterEvent(event) end
    end
end

function FF:HandleDoubleClick(event, button)
    if event ~= "GLOBAL_MOUSE_DOWN" and event ~= "GLOBAL_MOUSE_UP" then
        self:ResetDoubleClick(event == "PLAYER_LEAVING_WORLD")
        return
    end
    if button ~= "RightButton" then
        -- Another mouse action breaks the pair, including UI clicks and marker drags.
        if event == "GLOBAL_MOUSE_DOWN" then self:ResetDoubleClick() end
        return
    end
    if event == "GLOBAL_MOUSE_UP" and self.doubleClickMouseLook then
        self.doubleClickMouseLook = nil
        if IsMouselooking() then MouselookStop() end
    end
    if not self:DoubleClickEnabled() or InCombat() or not WorldClick(self) then self:ResetDoubleClick(); return end
    local now = GetTime()
    local x, y = GetCursorPosition()
    if event == "GLOBAL_MOUSE_DOWN" then
        local origin = self.doubleClickOrigin
        local second = self:DoubleClickArmed() and origin
            and (x - origin.x)^2 + (y - origin.y)^2 <= MAX_TRAVEL^2
        if not second then self:ResetDoubleClick() end
        local press = { at = now, x = x, y = y, second = second }
        self.doubleClickPress = press
        -- A held right button is camera control, not a fishing gesture. The
        -- timer exists only during a press; there is no idle update loop.
        -- Do not start mouse look for a short overridden second click: hiding
        -- the world cursor can remove the bobber's mouseover before hooking.
        C_Timer.After(MAX_HOLD, function()
            if self.doubleClickPress == press then
                if press.second and IsMouseButtonDown("RightButton") and not IsMouselooking() then
                    MouselookStart()
                    self.doubleClickMouseLook = true
                end
                self:ResetDoubleClick()
            end
        end)
    else
        local press = self.doubleClickPress
        self.doubleClickPress = nil
        if not press or press.second or now - press.at >= MAX_HOLD
            or (x - press.x)^2 + (y - press.y)^2 > MAX_TRAVEL^2 then
            self:ResetDoubleClick()
            return
        end
        self.doubleClickOrigin = { x = x, y = y }
        self.doubleClickUntil = now + CLICK_WINDOW
        local serial = self.doubleClickSerial
        self:ApplyBindings()
        C_Timer.After(CLICK_WINDOW, function()
            local secondHeld = self.doubleClickPress and self.doubleClickPress.second
            if self.doubleClickSerial == serial and not secondHeld then self:ResetDoubleClick() end
        end)
    end
end

function FF:InitializeDoubleClickBinding()
    if self.doubleClickBindingOwner then return end
    local owner = CreateFrame("Frame", nil, WorldFrame, "SecureHandlerStateTemplate")
    -- Secure cleanup releases BUTTON2 even if combat begins during the brief
    -- armed window, when ordinary Lua cannot change override bindings.
    owner:SetAttribute("_onstate-combat", [[if newstate == "combat" then self:ClearBindings() end]])
    RegisterStateDriver(owner, "combat", "[combat]combat;peace")
    self.doubleClickBindingOwner = owner
    local watcher = CreateFrame("Frame", nil, WorldFrame)
    watcher:SetScript("OnEvent", function(_, event, button) self:HandleDoubleClick(event, button) end)
    self.doubleClickWatcher = watcher
end
