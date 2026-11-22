-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local ACCENT = { 0.18, 0.78, 0.82 }
local AMBER = { 1, 0.69, 0.28 }
local DANGER = { 1, 0.35, 0.34 }
local PANEL = { 0.035, 0.055, 0.075, 0.97 }
local IDLE_CAST_SURFACE = { 0.035, 0.105, 0.15, 0.98 }
-- UI owns these cast-status surfaces. Retain rendered values on the
-- button, never readiness facts: all gameplay checks still run before painting.
local CAST_STYLES = {
    idle = { x = 86, width = 245, text = { 0.75, 0.84, 0.87 },
        surface = IDLE_CAST_SURFACE, stripe = ACCENT },
    bagsFull = { x = 86, width = 245, text = DANGER, surface = IDLE_CAST_SURFACE, stripe = ACCENT },
    camera = { x = 110, width = 220, icon = "Interface\\RaidFrame\\ReadyCheck-Waiting",
        text = AMBER, surface = { 0.14, 0.085, 0.035, 0.98 }, stripe = AMBER },
    recast = { x = 110, width = 220, icon = "Interface\\RaidFrame\\ReadyCheck-NotReady",
        text = DANGER, surface = { 0.15, 0.045, 0.055, 0.98 }, stripe = DANGER },
    good = { x = 110, width = 220, icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
        text = { 0.39, 0.94, 0.43 }, surface = { 0.035, 0.105, 0.15, 0.98 },
        stripe = { 0.30, 0.82, 0.35 } },
    checking = { x = 110, width = 220, icon = "Interface\\RaidFrame\\ReadyCheck-Waiting",
        text = { 0.94, 0.69, 0.33 }, surface = { 0.035, 0.105, 0.15, 0.98 }, stripe = AMBER },
}
local CHEF_HINT_COLOR = { 0.92, 0.76, 0.49 }
local STATUS_TEXT_Y = -40

local function LayoutFishingStatusText(button)
    local hint = button.hint
    local style = button.paintedCastStyle
    local x = (not button.paintedChefOverlay and style and style.x) or 86
    local y = STATUS_TEXT_Y
    -- Keep wrapped messages above the countdown when both are shown.
    if button.fishingSeconds and button.fishingSeconds:IsShown() and hint:GetStringHeight() > 21 then
        y = -37
    end
    if x == button.statusTextX and y == button.statusTextY then return end
    button.statusTextX, button.statusTextY = x, y
    hint:ClearAllPoints()
    hint:SetPoint("TOPLEFT", button, "TOPLEFT", x, y)
    button.statusIcon:ClearAllPoints()
    button.statusIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 86, y + 1)
end

local function PaintCastStatus(self, style, hint)
    local button = self.castButton
    if not button or not button.hint then return end
    button.castStatusStyle, button.castStatusHint = style, hint
    local message = self.masterChefQuickStatus and self.masterChefTray
        and self.masterChefTray:IsShown() and self:GetMasterChefMessage("masterChefQuickStatus") or nil
    local overlay = message ~= nil
    if not style and not overlay then return end
    local text = message or hint
    local styleChanged = button.paintedCastStyle ~= style
    local layoutChanged = styleChanged or button.paintedChefOverlay ~= overlay
    local textChanged = button.paintedCastText ~= text
    if layoutChanged then
        button.hint:SetWidth(overlay and 245 or style.width)
        if overlay or not style.icon then
            button.statusIcon:Hide()
        else
            button.statusIcon:SetTexture(style.icon)
            button.statusIcon:Show()
        end
        button.hint:SetTextColor(unpack(overlay and CHEF_HINT_COLOR or style.text))
    end
    if textChanged then button.hint:SetText(text) end
    if style and styleChanged then
        button.surface:SetColorTexture(unpack(style.surface))
        button.stripe:SetColorTexture(unpack(style.stripe))
    end
    if self.GetFishingInformationOptions then
        local options=self:GetFishingInformationOptions()
        if not options.enabled then button.hint:Hide(); button.statusIcon:Hide() end
    end
    button.paintedCastStyle, button.paintedCastText, button.paintedChefOverlay = style, text, overlay
    if layoutChanged or textChanged then LayoutFishingStatusText(button) end
end

local HUD_STRATA = "FULLSCREEN"
local WINDOW_STRATA = "FULLSCREEN_DIALOG"
local HUD_LEVEL = 160
local WINDOW_LEVEL = 320
local WINDOW_LEVEL_GAP = 150
local STRATA_BELOW = {
    BACKGROUND = "BACKGROUND", LOW = "BACKGROUND", MEDIUM = "LOW",
    HIGH = "MEDIUM", DIALOG = "HIGH", FULLSCREEN = "DIALOG", FULLSCREEN_DIALOG = "FULLSCREEN",
}
local STRATA_ORDER = {
    BACKGROUND = 1, LOW = 2, MEDIUM = 3, HIGH = 4, DIALOG = 5, FULLSCREEN = 6, FULLSCREEN_DIALOG = 7,
}
local HUD_SURFACES = {
    "bar", "toolBar", "rangeNotice", "fishingRodNotice", "fishingBagsFullNotice", "catchRecapPanel", "achievementNotice",
    "gearPicker", "lurePicker", "masterChefTray", "utilityPicker", "settingsPicker", "journalPicker",
    "quickTrayDismiss", "minimalCastFrame",
}
local EXTRA_BLIZZARD_PANELS = {
    "WorldMapFrame", "PlayerTalentFrame", "SpellBookFrame",
    "PlayerSpellsFrame", "ClassTalentFrame", "GameMenuFrame", "SettingsPanel",
    "StaticPopup1", "StaticPopup2", "StaticPopup3", "StaticPopup4",
    "AuctionHouseFrame", "AuctionFrame",
}
local INTERACTION_PANELS = {
    "GossipFrame", "QuestFrame", "MerchantFrame", "ClassTrainerFrame", "ItemTextFrame", "DressUpFrame",
}
local LAYOUT_DEFAULTS = {
    bar = { x = 0, y = -244, scale = 1 },
    tools = { x = -112, y = -323.9, scale = 1.006 },
}
local FLOATING_DEFAULTS = {
    sessionGoals = { x = 0, y = 0, scale = 1 },
    sessionTracker = { x = 455, y = 65, scale = 1 },
    -- Keep enough scale precision to match the rounded sizes in /fish changes.
    settings = { x = 1.2, y = 132.1, scale = 0.869 },
    journal = { x = -17.8, y = 129.2, scale = 1.1374 },
    masterChef = { x = -633.5, y = 101, scale = 1 },
}
local FLOATING_SIZE_BOUNDS = {
    sessionGoals = { width = 402, height = 326, minWidth = 220, minHeight = 180,
        maxWidth = 760, maxHeight = 840 },
    sessionTracker = { width = 224, height = 210, minWidth = 192, minHeight = 112,
        maxWidth = 760, maxHeight = 840 },
    journal = { width = 750, height = 560, minWidth = 630, minHeight = 460,
        maxWidth = 1040, maxHeight = 850 },
    masterChef = { width = 517, height = 519, minWidth = 460, minHeight = 390,
        maxWidth = 850, maxHeight = 800 },
}
local LEGACY_TOOLS_OFFSET_Y = -120
local OLD_TOOLS_WIDTH = 338
local FIVE_ICON_TOOLS_WIDTH = 280
local DEFAULT_ICON_SPACING = 8
local FLYOUT_DEFAULTS = { size = 48, spacing = 8, columns = 5 }
local function LayoutNumber(value, bounds, fallback)
    value = tonumber(value)
    if not value then return fallback end
    return math.max(bounds[1], math.min(bounds[2], math.floor(value + 0.5)))
end

function FF:GetIconBarSpacing()
    return LayoutNumber(self.db and self.db.iconBarSpacing, { 2, 20 }, DEFAULT_ICON_SPACING)
end

local PREVIOUS_TOOLS_DEFAULT_X = -26.1
local PREVIOUS_FOUR_ICON_DEFAULT_X = -1
local PREVIOUS_THREE_ICON_DEFAULT_X = -2
local FOUR_ICON_CENTER_SHIFT = PREVIOUS_FOUR_ICON_DEFAULT_X - PREVIOUS_TOOLS_DEFAULT_X
local THREE_ICON_CENTER_SHIFT = PREVIOUS_THREE_ICON_DEFAULT_X - PREVIOUS_FOUR_ICON_DEFAULT_X

function FF:ConfigureCombatWeaponButton(button, closing)
    button.combatWeaponButton = true
    button:SetAttribute("useOnKeyDown", false)
    button:SetAttribute("pressAndHoldAction", false)
    button:SetAttribute("_onstate-combat", [[
        self:SetAttribute("type1", newstate == "combat" and "macro" or nil)
    ]])
    RegisterStateDriver(button, "combat", "[combat]combat;peace")
    if not closing then return end
    button:SetFrameRef("bar", self.bar)
    button:SetFrameRef("tools", self.toolBar)
    self:ConfigureCombatCloseBindings(button)
    -- Keep the native OnClick inherited and unwrapped, like the Gear button.
    -- Secure cleanup belongs to PostClick, after the native weapon action.
    -- WrapScript requires a string pre-handler. Its second return value must
    -- be non-nil to dispatch the post-handler after the native action.
    SecureHandlerWrapScript(button, "PostClick", button, "return nil, true", [[
        if button == "LeftButton" and not down and self:GetAttribute("state-combat") == "combat" then
            -- A weapon sequence blocked by a live channel must retain retry UI.
            if self:GetAttribute("macrotext1") and SecureCmdOptionParse("[channeling] blocked") == "blocked" then return end
            local owner = self:GetFrameRef("castBindings")
            if owner then owner:ClearBindings() end
            owner = self:GetFrameRef("interactBindings")
            if owner then owner:ClearBindings() end
            owner = self:GetFrameRef("doubleBindings")
            if owner then owner:ClearBindings() end
            owner = self:GetFrameRef("gamepadChordBindings")
            if owner then owner:ClearBindings() end
            local panel = self:GetFrameRef("flyout-gear")
            if panel then panel:Hide() end
            panel = self:GetFrameRef("flyout-lure")
            if panel then panel:Hide() end
            panel = self:GetFrameRef("flyout-utility")
            if panel then panel:Hide() end
            panel = self:GetFrameRef("flyout-chef")
            if panel then panel:Hide() end
            self:GetFrameRef("tools"):Hide()
            self:GetFrameRef("bar"):Hide()
        end
    ]])
end

function FF:FinishFishingBarClose()
    if InCombatLockdown and InCombatLockdown() then return end
    self.pendingFishingBarClose = nil
    if self.bar and self.bar:IsShown() then return end
    if self.CloseSessionTracker then self:CloseSessionTracker(true) end
    if self.CloseSessionGoals then self:CloseSessionGoals(true) end
    self:SyncBobberInteractIcon()
    if self.fishingUpdateFrame then self.fishingUpdateFrame:SetScript("OnUpdate", nil) end
    if self.StopCameraAssist then self:StopCameraAssist("Fishing bar closed", true) end
    if self.ReleaseFishingFOV then self:ReleaseFishingFOV() end
    if self.toolBar then self.toolBar:Hide() end
    if self.quickTrayDismiss then self.quickTrayDismiss:Hide() end
    self:ApplyBindings()
    self:UpdateRangeNotice()
    if self.gearPicker then self.gearPicker:Hide() end
    if self.lurePicker then self.lurePicker:Hide() end
    self:CloseFishingQuickTray()
    if self.utilityPicker then self.utilityPicker:Hide() end
    if self.settingsPicker then self.settingsPicker:Hide() end
    if self.journalPicker then self.journalPicker:Hide() end
    if self.HideCatchRecap then self:HideCatchRecap() end
    if self.ReleaseFishingUIVisibility then self:ReleaseFishingUIVisibility(true) end
end

function FF:RegisterCombatCloseWindow(kind, panel)
    if InCombatLockdown and InCombatLockdown() then
        self.pendingCombatCloseWindows = self.pendingCombatCloseWindows or {}
        self.pendingCombatCloseWindows[kind] = panel
        return
    end
    -- A restricted snippet cannot dereference an ordinary frame handle in
    -- combat. Each registered root uses SecureHandlerStateTemplate and hides
    -- itself, so no other frame handle is needed. The peace state never shows
    -- it again; only a deliberate user action can do that.
    panel:SetAttribute("_onstate-combat", [[if newstate == "combat" then self:Hide() end]])
    RegisterStateDriver(panel, "combat", "[combat]combat;peace")
end

function FF:RegisterPendingCombatCloseWindows()
    local pending = self.pendingCombatCloseWindows
    if not pending or (InCombatLockdown and InCombatLockdown()) then return end
    self.pendingCombatCloseWindows = nil
    for kind, panel in pairs(pending) do self:RegisterCombatCloseWindow(kind, panel) end
end

function FF:UpdateFishingVisibilityRoot()
    local root = self.visibilityRoot
    if not root then return end
    local parent = root:GetParent()
    local uiScale = UIParent:GetEffectiveScale()
    root:SetScale(uiScale / (parent and parent:GetEffectiveScale() or 1))
    root:SetSize(UIParent:GetWidth(), UIParent:GetHeight())
end

function FF:EnsureFishingVisibilityRoot()
    if self.visibilityRoot then return self.visibilityRoot end
    local root = CreateFrame("Frame", "ForeverFishingVisibilityRoot", UIParent)
    -- Detach before creating any protected descendants. The surface keeps the
    -- screen UI's coordinate space and stays visible when UIParent is hidden.
    root:SetParent(nil)
    -- The shared parent draws nothing. Leave both higher and lower layers
    -- available to the surfaces that actually render.
    root:SetFrameStrata("BACKGROUND")
    if root.SetFixedFrameStrata then root:SetFixedFrameStrata(true) end
    root:SetPoint("CENTER", UIParent, "CENTER")
    root:EnableMouse(false)
    self.visibilityRoot = root
    self:UpdateFishingVisibilityRoot()
    return root
end

-- Every drawing frame in an owned surface follows its surface's strata. A
-- previously observed child strata can be stale after a native panel restack.
local function SetFishingSurfaceLayer(frame, strata, level)
    local oldLevel = frame:GetFrameLevel()
    local children = {}
    local highest = 0
    local function Collect(parent)
        for _, child in ipairs({ parent:GetChildren() }) do
            local offset = child:GetFrameLevel() - oldLevel
            highest = math.max(highest, offset)
            children[#children + 1] = { frame = child, offset = offset }
            Collect(child)
        end
    end
    Collect(frame)
    level = level or oldLevel
    if frame:GetFrameStrata() ~= strata then frame:SetFrameStrata(strata) end
    if frame:GetFrameLevel() ~= level then frame:SetFrameLevel(level) end
    for _, child in ipairs(children) do
        if child.frame:GetFrameStrata() ~= strata then child.frame:SetFrameStrata(strata) end
        local childLevel = level + child.offset
        if child.frame:GetFrameLevel() ~= childLevel then child.frame:SetFrameLevel(childLevel) end
    end
    return level + highest
end

local function ParkedProfessionPanel(self, frame)
    local cooking, camp = self.masterChefCookingPanel, self.masterChefCampPanel
    if (cooking and cooking.frame == frame) or (camp and camp.frame == frame) then
        local point, parent, relative, _, y = frame:GetPoint(1)
        return point == "TOPLEFT" and parent == (WorldFrame or UIParent)
            and relative == "BOTTOMLEFT" and y == -100
    end
end

local function FishingLayerBounds(frame, getRect)
    if not getRect then return end
    local x, y, width, height = getRect(frame)
    local scale = frame:GetEffectiveScale()
    if issecretvalue and (issecretvalue(x) or issecretvalue(y) or issecretvalue(width)
        or issecretvalue(height) or issecretvalue(scale)) then return end
    if not (x and y and width and height and scale) or width <= 0 or height <= 0 or scale <= 0 then return end
    return { left = x * scale, right = (x + width) * scale, bottom = y * scale, top = (y + height) * scale }
end

local function FishingNativePanelLayers(self)
    local panels, seen = {}, {}
    local function Consider(frame, onlyOverlap)
        if not frame or seen[frame] or not frame.IsVisible or not frame.GetFrameStrata
            or (frame.IsForbidden and frame:IsForbidden()) then return end
        seen[frame] = true
        local visible = frame:IsVisible()
        if (issecretvalue and issecretvalue(visible)) or not visible or ParkedProfessionPanel(self, frame) then return end
        local current = frame:GetFrameStrata()
        if issecretvalue and issecretvalue(current) then return end
        local below = STRATA_BELOW[current]
        if below then
            local bounds = onlyOverlap and (FishingLayerBounds(frame, frame.GetBoundsRect)
                or FishingLayerBounds(frame, frame.GetRect))
            panels[#panels + 1] = { strata = below, bounds = bounds }
            if onlyOverlap then self.fishingOverlapPanelVisible = true end
        end
    end
    -- NPC panels and bags only need priority where they meet a Fishing surface.
    self.fishingOverlapPanelVisible = nil
    if self.ForEachFishingBagFrame then
        self:ForEachFishingBagFrame(function(frame) Consider(frame, true) end)
    end
    for _, name in ipairs(INTERACTION_PANELS) do Consider(_G[name], true) end
    for name in pairs(UIPanelWindows or {}) do Consider(_G[name]) end
    for _, name in ipairs(EXTRA_BLIZZARD_PANELS) do Consider(_G[name]) end
    if StaticPopup_ForEachShownDialog then
        StaticPopup_ForEachShownDialog(function(dialog) Consider(dialog) end)
    end
    return panels
end

local function FishingStrataBelowNativePanels(bounds, strata, panels)
    for _, panel in ipairs(panels) do
        local other = panel.bounds
        if STRATA_ORDER[panel.strata] < STRATA_ORDER[strata]
            and (not bounds or not other or (bounds.left < other.right and bounds.right > other.left
                and bounds.bottom < other.top and bounds.top > other.bottom)) then
            strata = panel.strata
        end
    end
    return strata
end

local function FishingSurfaceBounds(self, frame, field)
    if field == "toolBar" then
        -- The toolbar's anchor is only one icon wide. Its other controls can
        -- extend outside that rectangle, including while sliding open.
        local motion = self.compactBarMotion
        if motion then
            local left, right, bottom, top = unpack(motion.bounds)
            return { left = left, right = right, bottom = bottom, top = top }
        end
        return FishingLayerBounds(frame, frame.GetBoundsRect) or FishingLayerBounds(frame, frame.GetRect)
    end
    return FishingLayerBounds(frame, frame.GetRect)
end

function FF:BlizzardPanelOpen(visibleOnly, ignoredFrame)
    local function PanelOpen(frame)
        if not frame or frame == ignoredFrame then return false end
        if visibleOnly and frame.IsVisible then return frame:IsVisible() end
        return frame.IsShown and frame:IsShown()
    end
    for name in pairs(UIPanelWindows or {}) do
        if PanelOpen(_G[name]) then return true end
    end
    for _, name in ipairs(EXTRA_BLIZZARD_PANELS) do
        if PanelOpen(_G[name]) then return true end
    end
    return false
end

function FF:MasterChefExternalPanelOpen()
    local function External(frame)
        return frame and frame ~= _G.ProfessionsFrame and frame ~= _G.TradeSkillFrame
            and frame.IsShown and frame:IsShown()
    end
    for name in pairs(UIPanelWindows or {}) do
        if External(_G[name]) then return true end
    end
    for _, name in ipairs(EXTRA_BLIZZARD_PANELS) do
        if External(_G[name]) then return true end
    end
    return false
end

function FF:RefreshFishingLayer()
    if InCombatLockdown and InCombatLockdown() then
        self.fishingLayerPending = true
        return
    end
    self.fishingLayerPending = nil
    local nativePanelOpen=self:BlizzardPanelOpen()
    local panelChanged=self.fishingNativePanelOpen~=nativePanelOpen
    self.fishingNativePanelOpen=nativePanelOpen
    local panels = FishingNativePanelLayers(self)
    local reset = self.fishingResetInput and self.fishingResetConfirmation
    local windowStrata = self.fishingResetInput and HUD_STRATA or WINDOW_STRATA
    local hudStrata = HUD_STRATA
    local resetStrata
    if reset then
        -- The reset shield covers the screen, so it yields to every native panel.
        resetStrata = FishingStrataBelowNativePanels(nil, WINDOW_STRATA, panels)
        if STRATA_ORDER[resetStrata] < STRATA_ORDER[HUD_STRATA] then
            hudStrata, windowStrata = resetStrata, resetStrata
        end
    end
    for _, field in ipairs(HUD_SURFACES) do
        local frame = self[field]
        if frame then
            local bounds = self.fishingOverlapPanelVisible and FishingSurfaceBounds(self, frame, field)
            SetFishingSurfaceLayer(frame, FishingStrataBelowNativePanels(bounds, hudStrata, panels))
        end
    end
    -- Keep the floating windows in a shared stack so the active one wins
    -- even when only part of the stack overlaps a native panel.
    for _, window in ipairs(self.floatingWindows or {}) do
        if window:IsShown() then
            local bounds = self.fishingOverlapPanelVisible and FishingLayerBounds(window, window.GetRect)
            windowStrata = FishingStrataBelowNativePanels(bounds, windowStrata, panels)
        end
    end
    for _, window in ipairs(self.floatingWindows or {}) do
        if window:IsShown() then SetFishingSurfaceLayer(window, windowStrata) end
    end
    if reset then
        SetFishingSurfaceLayer(reset, resetStrata, (self.windowLevel or WINDOW_LEVEL) + WINDOW_LEVEL_GAP)
    end
    if panelChanged and self.RefreshFishingGamepadInput then self:RefreshFishingGamepadInput() end
end

function FF:RefreshFishingLayerAfterNativePanel()
    self:RefreshFishingLayer()
    if self.fishingLayerRefreshQueued or not (C_Timer and C_Timer.After) then return end
    self.fishingLayerRefreshQueued = true
    -- Native panel layout can finish after its OnShow or OnHide handlers.
    C_Timer.After(0, function()
        self.fishingLayerRefreshQueued = nil
        self:RefreshFishingLayer()
    end)
end

function FF:InstallBlizzardPanelHooks(afterTransition)
    self.blizzardPanelHooks = self.blizzardPanelHooks or {}
    local function HookFrame(frame, layerOnly)
        if not frame or not frame.HookScript or self.blizzardPanelHooks[frame]
            or (frame.IsForbidden and frame:IsForbidden()) then return end
        self.blizzardPanelHooks[frame] = true
        frame:HookScript("OnShow", function()
            if not layerOnly and FF.SuspendMasterChefForExternalPanel then
                FF:SuspendMasterChefForExternalPanel(frame)
            end
            FF:RefreshFishingLayerAfterNativePanel()
        end)
        frame:HookScript("OnHide", function() FF:RefreshFishingLayerAfterNativePanel() end)
    end
    for name in pairs(UIPanelWindows or {}) do HookFrame(_G[name]) end
    for _, name in ipairs(EXTRA_BLIZZARD_PANELS) do HookFrame(_G[name]) end
    for _, name in ipairs(INTERACTION_PANELS) do HookFrame(_G[name], true) end
    if self.ForEachFishingBagFrame then
        self:ForEachFishingBagFrame(function(frame) HookFrame(frame, true) end)
    end
    -- Modern StaticPopup frames are pooled and need not have a global name.
    if PopupEventManager and not self.fishingPopupLayerHooks then
        local function Refresh() FF:RefreshFishingLayerAfterNativePanel() end
        PopupEventManager:RegisterCallback("PopupOpened", Refresh, self)
        PopupEventManager:RegisterCallback("PopupClosed", Refresh, self)
        self.fishingPopupLayerHooks = true
    end
    if hooksecurefunc then
        self.blizzardPanelFunctionHooks = self.blizzardPanelFunctionHooks or {}
        -- Opening another bag can move or resize bags that are already open.
        if not self.blizzardPanelFunctionHooks.UpdateContainerFrameAnchors
            and type(UpdateContainerFrameAnchors) == "function" then
            hooksecurefunc("UpdateContainerFrameAnchors", function()
                FF:RefreshFishingLayerAfterNativePanel()
            end)
            self.blizzardPanelFunctionHooks.UpdateContainerFrameAnchors = true
        end
        for _, name in ipairs({ "ShowUIPanel", "HideUIPanel" }) do
            if not self.blizzardPanelFunctionHooks[name] and type(_G[name]) == "function" then
                hooksecurefunc(name, function(frame)
                    FF:InstallBlizzardPanelHooks(true)
                    if name == "ShowUIPanel" and FF.SuspendMasterChefForExternalPanel then
                        FF:SuspendMasterChefForExternalPanel(frame)
                    end
                end)
                self.blizzardPanelFunctionHooks[name] = true
            end
        end
    end
    if afterTransition then self:RefreshFishingLayerAfterNativePanel() else self:RefreshFishingLayer() end
end

local function CenterOffset(frame)
    local x, y = frame:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not x or not y or not parentX or not parentY then return nil end
    local relativeScale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    return x * relativeScale - parentX, y * relativeScale - parentY
end

local function SetCenterOffset(frame, x, y)
    local relativeScale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x / relativeScale, y / relativeScale)
end

local function BindingLabels(key)
    local gamepad=FF.GetFishingGamepadLabel and FF:GetFishingGamepadLabel(key)
    if gamepad then return {gamepad},gamepad,"" end
    if FF:GetResolvedLocale()~="enUS" then return FF:GetLocalizedFishingBindingLabels(key) end
    if key == FF.doubleRightClickKey then
        return { "Double right click", "Double right", "Double RC", "2x right" }, "Double right click", ""
    end
    local base = key:gsub("ALT%-", ""):gsub("CTRL%-", ""):gsub("SHIFT%-", "")
    local fullMods, shortMods = {}, {}
    for _, modifier in ipairs({ { "ALT-", "Alt", "A" }, { "CTRL-", "Ctrl", "C" }, { "SHIFT-", "Shift", "S" } }) do
        if key:find(modifier[1], 1, true) then
            fullMods[#fullMods + 1] = modifier[2]
            shortMods[#shortMods + 1] = modifier[3]
        end
    end
    local fullPrefix = #fullMods > 0 and (table.concat(fullMods, " + ") .. " + ") or ""
    local shortPrefix = #shortMods > 0 and (table.concat(shortMods, "+") .. "+") or ""
    local fullBase, shortBase, tinyBase, descriptionBase
    if base == "MOUSEWHEELUP" or base == "MOUSEWHEELDOWN" then
        local direction = base == "MOUSEWHEELUP" and "up" or "down"
        fullBase, shortBase = "Wheel " .. direction, "W " .. direction
        tinyBase = base == "MOUSEWHEELUP" and "WU" or "WD"
        descriptionBase = "mouse wheel " .. direction
    elseif base:match("^BUTTON%d+$") then
        local number = base:match("%d+$")
        fullBase, shortBase, tinyBase = "Mouse button " .. number, "Button " .. number, "B" .. number
        descriptionBase = "mouse button " .. number
    else
        local numpad = base:match("^NUMPAD(.+)$")
        fullBase = numpad and ("Numpad " .. (numpad:gsub("[A-Z]",string.lower)))
            or (base:find("[\128-\255]") and base or (base:sub(1, 1) .. base:sub(2):lower()))
        shortBase = ({ BACKSPACE = "Bksp", PAGEDOWN = "Pg dn", PAGEUP = "Pg up" })[base] or fullBase
        tinyBase = shortBase
        descriptionBase = fullBase
    end
    local description = #fullMods > 0 and (fullPrefix .. descriptionBase)
        or (descriptionBase:gsub("^[a-z]",string.upper))
    return { fullPrefix .. fullBase, shortPrefix .. fullBase, shortPrefix .. shortBase, shortPrefix .. tinyBase }, description, shortPrefix
end

local function SetBindingLabel(button, key, emptyText)
    local font = button:GetFontString()
    if font and font.SetFontHeight and button.fishingKeyFontHeight then font:SetFontHeight(button.fishingKeyFontHeight) end
    if not key or key == "" then button:SetText(emptyText); return end
    local candidates, _, shortPrefix = BindingLabels(key)
    local available = button:GetWidth() - 14
    for _, label in ipairs(candidates) do
        button:SetText(label)
        if not font or font:GetStringWidth() <= available then return end
    end
    local base = candidates[#candidates]:sub(#shortPrefix + 1)
    while #base > 1 do
        local shorter=base:match("^(.*)[%z\1-\127\194-\244][\128-\191]*$")
        if not shorter or shorter=="" then break end
        base=shorter
        button:SetText(shortPrefix .. base .. ".")
        if not font or font:GetStringWidth() <= available then return end
    end
    button:SetText(shortPrefix .. base)
end

function FF:FitFishingBindingButton(button,key,emptyText)
    SetBindingLabel(button,key,emptyText)
end

local function BindingDescription(key)
    local _, description = BindingLabels(key)
    return description
end

function FF:GetFishingBindingLabel(key)
    key = key or (self.db and self:GetFishingInputKey())
    return key and key ~= "" and BindingDescription(key) or FF:LocalizedText("binding.display.empty")
end

-- Keep popup glyphs close to the adjacent 20-point text in either native
-- device state. Footer glyphs leave extra room inside the themed border.
function FF:GetFishingGamepadPopupIcon(key,role)
    local height=role=="footer" and 19 or 21
    local label
    if self.GetFishingGamepadLabel then
        local ok,value=pcall(self.GetFishingGamepadLabel,self,key)
        if ok then label=value end
    end
    if not label and type(GetBindingText)=="function" then
        local ok,value=pcall(GetBindingText,key,"KEY_")
        if ok then label=value end
    end
    if (issecretvalue and issecretvalue(label)) or type(label)~="string" or label=="" or label==key then
        local fallback={PAD1="gamepad.button.a",PAD2="gamepad.button.b",PADLTRIGGER="gamepad.modifier.lt",
            PADRTRIGGER="gamepad.modifier.rt",PADBACK="gamepad.button.back"}
        label=fallback[key] and self:LocalizedText(fallback[key]) or self:GetFishingBindingLabel(key)
    end
    local function Size(asset,h,w,tail,atlas)
        h,w=tonumber(h),tonumber(w)
        if (not h or h<=0 or not w or w<=0) and atlas and C_Texture and type(C_Texture.GetAtlasInfo)=="function" then
            local ok,info=pcall(C_Texture.GetAtlasInfo,asset)
            if ok and not (issecretvalue and issecretvalue(info)) and type(info)=="table"
                and not (issecretvalue and (issecretvalue(info.height) or issecretvalue(info.width)))
                and type(info.height)=="number" and type(info.width)=="number" then h,w=info.height,info.width end
        end
        local width=h and h>0 and w and w>0 and height*w/h or height
        -- Native binding offsets target other font sizes. Centre on this
        -- popup's text line while preserving later UV/crop or colour fields.
        local _,_,rest=tail:match("^:([^:]*):([^:]*)(.*)$")
        return (atlas and "|A:" or "|T")..asset..":"..height..":"..string.format("%g",width)..":0:0"..(rest or "")..(atlas and "|a" or "|t")
    end
    local function Icon(data,atlas)
        local asset,h,w,tail=data:match("^([^:]+):([^:]*):([^:]*)(.*)$")
        if not asset then asset,h=data:match("^([^:]+):([^:]*)$");tail="" end
        return Size(asset or data,h,w,tail or "",atlas)
    end
    label=label:gsub("|A:([^|]+)|a",function(data)return Icon(data,true)end)
    label=label:gsub("|T([^|]+)|t",function(data)return Icon(data,false)end)
    return label
end

local function Backdrop(frame)
    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetColorTexture(unpack(PANEL))
    frame.background = background
    local edge = frame:CreateTexture(nil, "BORDER")
    edge:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    edge:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    edge:SetHeight(1)
    edge:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.72)
    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bottom:SetHeight(1)
    bottom:SetColorTexture(0.17, 0.24, 0.29, 0.75)
    return edge
end

local function Text(parent, template, x, y, value)
    local label = parent:CreateFontString(nil, "OVERLAY", template)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetText(value or "")
    return label
end

local function StyleButtonSurface(frame, primary)
    local surface = frame:CreateTexture(nil, "BACKGROUND")
    surface:SetAllPoints(frame)
    surface:SetColorTexture(primary and 0.09 or 0.075, primary and 0.19 or 0.12, primary and 0.23 or 0.16, 0.98)
    frame.surface = surface
end

local function StyleButton(button, label, primary)
    StyleButtonSurface(button, primary)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(button)
    highlight:SetColorTexture(0.21, 0.73, 0.79, primary and 0.18 or 0.11)
    button:SetHighlightTexture(highlight)
    if label then
        local font = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        font:SetPoint("CENTER", button, "CENTER", 0, 0)
        font:SetTextColor(0.9, 0.95, 0.96)
        button:SetFontString(font)
        button:SetText(label)
    end
end

local function OrnateBorder(parent, padding, edgeSize)
    local border = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    border:SetPoint("TOPLEFT", parent, "TOPLEFT", -padding, padding)
    border:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", padding, -padding)
    border:EnableMouse(false)
    if border.SetBackdrop then
        border:SetBackdrop({
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = edgeSize,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        })
        border:SetBackdropBorderColor(0.95, 0.76, 0.43, 0.95)
    end
    return border
end

function FF:StyleFishingBarFrame(frame, interactive)
    if interactive then
        StyleButton(frame, nil, true)
    else
        StyleButtonSurface(frame, true)
    end
    frame.surface:SetColorTexture(unpack(CAST_STYLES.idle.surface))
    return OrnateBorder(frame, 5, 22)
end

function FF:PlaceFishingBarCloseButton(button, surface)
    button:SetSize(22, 22)
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", surface, "TOPRIGHT", -2, -2)
end

local function PlainButton(parent, label, width, height, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height)
    StyleButton(button, label)
    if onClick then button:SetScript("OnClick", onClick) end
    return button
end

local function StyleSmartIcon(button, icon, fullTexture)
    button:SetSize(48, 48)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    -- Bleed under the Blizzard quickslot border to avoid a hairline gap on
    -- its left and bottom edges at large UI scales.
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -3)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 2)
    button.icon:SetTexture(icon)
    button.icon:SetTexCoord(fullTexture and 0 or 0.07, fullTexture and 1 or 0.93,
        fullTexture and 0 or 0.07, fullTexture and 1 or 0.93)
    local shade = button:CreateTexture(nil, "OVERLAY")
    shade:SetPoint("TOPLEFT", button.icon, "TOPLEFT")
    shade:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT")
    shade:SetColorTexture(0, 0, 0, 0.08)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(83, 83)
    border:SetPoint("CENTER", button, "CENTER", 0, -1)
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    button.quickslotBorder = border
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("TOPLEFT", button.icon, "TOPLEFT")
    highlight:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT")
    highlight:SetColorTexture(1, 0.82, 0.38, 0.18)
    button:SetHighlightTexture(highlight)
    button.procGlow = button:CreateTexture(nil, "OVERLAY")
    button.procGlow:SetPoint("TOPLEFT", button, "TOPLEFT", -9, 9)
    button.procGlow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 9, -9)
    button.procGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    button.procGlow:SetTexCoord(0.0078125, 0.5078125, 0.53515625, 0.78515625)
    button.procGlow:SetBlendMode("ADD")
    button.procGlow:SetVertexColor(1, 0.68, 0.16, 1)
    button.procGlow:Hide()
    button.glowAnimation = button.procGlow:CreateAnimationGroup()
    button.glowAnimation:SetLooping("REPEAT")
    local fadeOut = button.glowAnimation:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.55)
    fadeOut:SetDuration(0.65)
    fadeOut:SetOrder(1)
    local fadeIn = button.glowAnimation:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.55)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.65)
    fadeIn:SetOrder(2)
end

function FF:SetSmartGlow(button, visible)
    if not button or not button.procGlow then return end
    if visible then
        button.procGlow:Show()
        if button.glowAnimation and not button.glowAnimation:IsPlaying() then button.glowAnimation:Play() end
    else
        if button.glowAnimation and button.glowAnimation:IsPlaying() then button.glowAnimation:Stop() end
        button.procGlow:Hide()
    end
end

local function AddCaret(button, rightInset)
    local caret = CreateFrame("Frame", nil, button)
    caret:SetSize(28, 26)
    caret:SetPoint("RIGHT", button, "RIGHT", rightInset or -9, 0)
    caret:EnableMouse(false)
    local texture = caret:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints(caret)
    function caret:SetDirection(up)
        texture:SetTexture(up and "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up"
            or "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    end
    caret:SetDirection(false)
    return caret
end

local function DropArrow(parent, owner, onClick, tooltip)
    local arrow = CreateFrame("Button", nil, parent)
    arrow:SetSize(30, 30)
    arrow:SetHitRectInsets(0,7,0,7) -- Transparent outer padding must not cover the next vertical icon.
    -- The Blizzard scroll-button art has transparent padding. Position its
    -- visible corner against the icon frame rather than its padded texture.
    arrow:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", 7, -7)
    arrow:SetFrameLevel(owner:GetFrameLevel() + 8)
    arrow:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    arrow:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
    arrow:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight", "ADD")
    arrow:SetScript("OnClick", onClick)
    arrow:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip)
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return arrow
end

local function TimingSlider(parent, x, y, width, minimum, maximum, step)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetSize(width, 18)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step or 0.1)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", slider, "LEFT", 0, 0)
    track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
    track:SetHeight(5)
    track:SetColorTexture(0.035, 0.075, 0.10, 0.98)
    local fill = slider:CreateTexture(nil, "BORDER")
    fill:SetPoint("LEFT", slider, "LEFT", 0, 0)
    fill:SetHeight(5)
    fill:SetColorTexture(0.16, 0.65, 0.79, 0.98)
    slider.fill = fill
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:GetThumbTexture():SetVertexColor(1, 0.79, 0.43)
    slider:GetThumbTexture():SetSize(19, 23)
    return slider
end

function FF:LayoutFishingBindingCapture()
    local panel=self.captureDialog
    local y=0
    local globalConfirm=self.captureCanConfirm and (self.keyCaptureAction=="open" or self.captureConflictAction=="open")
    local function TextRow(field,gap)
        local text=self[field]
        text:ClearAllPoints();text:SetPoint("TOPLEFT",panel,"TOPLEFT",0,-y)
        text:SetSize(560,1000);text:SetWordWrap(true)
        local hasText=text:GetText() and text:GetText()~=""
        text:SetShown(hasText and true or false)
        local height=hasText and math.max(18,math.ceil(text:GetStringHeight())) or 0
        text:SetHeight(height)
        if hasText then y=y+height+(gap or 12) end
    end
    for _,row in ipairs(self.captureGamepadRows or {}) do row.control:Hide();row.action:Hide() end
    if self.captureGamepadQuestion then self.captureGamepadQuestion:SetShown(self.captureGamepadDefaults==true) end
    if self.captureGamepadDefaults then
        TextRow("captureTitle")
        -- Keep the complete localized copy on captureInstruction; present its
        -- three rows in measured columns without inventing/replacing wording.
        local entries={}
        for line in self.captureInstruction:GetText():gmatch("[^\n]+") do
            local control,action=line:match("^(.-) (· .+)$")
            if not control then entries={};break end
            entries[#entries+1]={control,action}
        end
        if #entries==3 then
            self.captureInstruction:Hide()
            self.captureGamepadRows=self.captureGamepadRows or {}
            local controls,actions=0,0
            for i,entry in ipairs(entries) do
                local row=self.captureGamepadRows[i]
                if not row then
                    row={}
                    for _,field in ipairs({"control","action"}) do
                        local text=panel:CreateFontString(nil,"OVERLAY")
                        self:SetDisplayFont(text,"Fonts\\2002.TTF",20,"")
                        text:SetTextColor(.94,.95,.95);text:SetShadowColor(0,0,0,.9);text:SetShadowOffset(1,-1)
                        text:SetJustifyV("MIDDLE");row[field]=text
                    end
                    self.captureGamepadRows[i]=row
                end
                row.control:SetText(entry[1]);row.action:SetText(entry[2])
                row.control:SetWidth(0);row.action:SetWidth(0)
                controls=math.max(controls,math.ceil(row.control:GetStringWidth()))
                actions=math.max(actions,math.ceil(row.action:GetStringWidth()))
            end
            local left=math.max(0,(560-controls-16-actions)/2)
            local height=38
            for _,row in ipairs(self.captureGamepadRows) do
                row.action:SetWidth(math.max(1,560-left-controls-16));row.action:SetWordWrap(true)
                height=math.max(height,math.ceil(row.action:GetStringHeight()))
            end
            for _,row in ipairs(self.captureGamepadRows) do
                row.control:ClearAllPoints();row.action:ClearAllPoints()
                row.control:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
                row.action:SetPoint("TOPLEFT",panel,"TOPLEFT",left+controls+16,-y)
                row.control:SetSize(controls,height);row.action:SetSize(math.max(1,560-left-controls-16),height)
                row.control:SetJustifyH("RIGHT");row.action:SetJustifyH("LEFT")
                row.control:SetWordWrap(false);row.action:SetWordWrap(true)
                row.control:Show();row.action:Show();y=y+height+8
            end
            y=y+4
        else TextRow("captureInstruction") end
        TextRow("captureDetail",32) -- One extra line above the entry question.
        TextRow("captureGamepadQuestion",8)
        self.captureScope:Hide();self.captureEscape:Hide()
        local width=self.captureConfirm:GetWidth()+self.captureCancel:GetWidth()+16
        local left=(560-width)/2
        self.captureConfirm:ClearAllPoints();self.captureCancel:ClearAllPoints()
        self.captureConfirm:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
        self.captureCancel:SetPoint("TOPLEFT",panel,"TOPLEFT",left+self.captureConfirm:GetWidth()+16,-y)
        panel:SetHeight(y+math.max(self.captureConfirm:GetHeight(),self.captureCancel:GetHeight()))
        return
    end
    for _,field in ipairs({"captureTitle","captureInstruction","captureScope","captureDetail"}) do TextRow(field) end
    if not globalConfirm then TextRow("captureEscape") end
    if self.captureCanConfirm then
        self.captureConfirm:ClearAllPoints();self.captureCancel:ClearAllPoints()
        if globalConfirm then
            self.captureConfirm:SetPoint("TOPLEFT",panel,"TOPLEFT",(560-self.captureConfirm:GetWidth())/2,-y)
            y=y+self.captureConfirm:GetHeight()+8
            TextRow("captureEscape")
        else
            local width=self.captureCancel:GetWidth()+self.captureConfirm:GetWidth()+16
            local left=(560-width)/2
            self.captureCancel:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
            self.captureConfirm:SetPoint("TOPLEFT",panel,"TOPLEFT",left+self.captureCancel:GetWidth()+16,-y)
            y=y+math.max(self.captureConfirm:GetHeight(),self.captureCancel:GetHeight())+6
        end
    end
    panel:SetHeight(math.max(1,y-6))
end
function FF:RestoreBindingCaptureVisibility()
    local state=self.captureVisibility
    self.captureVisibility=nil
    if not state then return end
    for _,entry in ipairs(state) do
        -- Alpha is transient presentation only: never Show/Hide the session,
        -- native parent or another window, and relinquish later external edits.
        if entry.frame:GetAlpha()==0 then entry.frame:SetAlpha(entry.alpha) end
    end
end
function FF:BeginKeyCapture(action,gamepadDefaults)
    if InCombatLockdown and InCombatLockdown() then self:Print(FF:LocalizedText("binding.choose-outside-combat"));return end
    action=action or "fishing"
    local entry=self.fishingActions[action];if not entry then return end
    if self.captureVisibility then self:InterruptKeyCapture() end
    self.captureGamepadDefaults=gamepadDefaults==true
    self.captureDB=self.db
    self.captureGamepadEntry=nil
    if self.gamepadModePending then
        local profile=self.db.gamepadBindings
        self.captureGamepadEntry={profile=profile,key=type(profile)=="table" and profile.fishing}
    end
    self.keyCaptureSerial=(self.keyCaptureSerial or 0)+1
    local serial=self.keyCaptureSerial
    self.keyCaptureAction=action;self.captureGamepadMode=self:IsFishingGamepadMode();self.captureInputReady=nil;self.captureCommitPending=nil
    self.captureGamepadModifiers={}
    self.captureShoulderTap=nil
    self.capturePressedKey,self.captureCandidate,self.captureCanConfirm,self.captureConflictAction=nil,nil,nil,nil
    self.captureRightAt=nil;self.captureEnding=nil
    self.captureTitle:SetText(entry.label)
    self.captureInstruction:SetText(self:GetFishingCaptureInstruction(action))
    self.captureScope:SetText(entry.scope~="always" and self:LocalizedText("binding.session-only") or "")
    self.captureScope:SetTextColor(.80,.84,.84);self.captureDetail:SetText("")
    self.captureEscape:SetText(self:LocalizedText("binding.escape"))
    self.captureConfirm:Hide();self.captureCancel:Hide()
    self.captureConfirm=self.captureGamepadMode and self.captureGamepadConfirm or self.captureNormalConfirm
    self.captureCancel=self.captureGamepadMode and self.captureGamepadCancel or self.captureNormalCancel
    self.captureConfirm:SetText(self:LocalizedText("binding.assign"));self.captureCancel:SetText(self:LocalizedText("binding.cancel"))
    self:SetDisplayFont(self.captureInstruction,"Fonts\\2002.TTF",22,"")
    self.captureInstruction:SetSpacing(0)
    self:SetDisplayFont(self.captureDetail,"Fonts\\2002.TTF",16,"")
    self.captureDetail:SetTextColor(1,.80,.39)
    if self.captureGamepadMode then
        local cancel=self:GetFishingGamepadPopupIcon("PADBACK","footer")
        self.captureEscape:SetText(self:LocalizedText("gamepad.capture-cancel",cancel))
        self.captureCancel:SetText(self:LocalizedText("gamepad.defaults-cancel",cancel))
    end
    if self.captureGamepadDefaults then
        local accept=self:GetFishingGamepadPopupIcon("PAD1")
        local cancel=self:GetFishingGamepadPopupIcon("PAD2")
        local trigger=self:GetFishingGamepadPopupIcon("PADLTRIGGER")
        self.captureTitle:SetText(self:LocalizedText("gamepad.defaults-title"))
        self.captureInstruction:SetText(self:LocalizedText("gamepad.defaults-bindings",accept,trigger.." + "..accept,trigger.." + "..cancel))
        self.captureDetail:SetText(self:LocalizedText("gamepad.defaults-note"))
        self.captureGamepadQuestion:SetText(self:LocalizedText("gamepad.defaults-question"))
        self:SetDisplayFont(self.captureInstruction,"Fonts\\2002.TTF",20,"")
        self.captureInstruction:SetSpacing(8) -- Keep the larger inline icons clear of adjacent rows.
        self:SetDisplayFont(self.captureDetail,"Fonts\\2002.TTF",14,"")
        self.captureDetail:SetTextColor(.80,.84,.84)
        self.captureCandidate="PAD1";self.captureCanConfirm=true
        self.captureConfirm:SetText(self:LocalizedText("gamepad.defaults-enter",self:GetFishingGamepadPopupIcon("PAD1","footer")))
        self.captureCancel:SetText(self:LocalizedText("gamepad.defaults-cancel",self:GetFishingGamepadPopupIcon("PAD2","footer")))
        self.captureConfirm:SetEnabled(true);self.captureConfirm:Show();self.captureCancel:Show()
    end
    GameTooltip:Hide();self:LayoutFishingBindingCapture()
    self.captureVisibility={}
    for _,frame in ipairs({UIParent,self.visibilityRoot}) do
        self.captureVisibility[#self.captureVisibility+1]={frame=frame,alpha=frame:GetAlpha()}
        frame:SetAlpha(0)
    end
    SetFishingSurfaceLayer(self.capture, "TOOLTIP", (self.windowLevel or 500) + 50)
    self.capture:Show();self.captureDialog:Show();self.capture:SetPropagateKeyboardInput(false)
    if self.captureDimAnimation then self.captureDimAnimation:Stop();self.captureDimAnimation:Play() end
    if self.ResetDoubleClick then self:ResetDoubleClick(true) end
    self:ApplyBindings()
    local function Arm()
        if self.keyCaptureSerial~=serial or not self.capture:IsShown() then return end
        if action=="fishing" and not self.captureGamepadMode then
            self.capture:RegisterEvent("GLOBAL_MOUSE_UP")
        end
        self.captureInputReady=true
    end
    if C_Timer and C_Timer.After then C_Timer.After(0,Arm) else Arm() end
end
function FF:FinishKeyCapture(key,interrupted,other)
    if not self.captureVisibility then return end
    if self.captureEnding and not interrupted then return end
    local action=self.keyCaptureAction or "fishing"
    if interrupted or (InCombatLockdown and InCombatLockdown()) then key=nil;other=nil end
    self.keyCaptureSerial=(self.keyCaptureSerial or 0)+1
    local serial=self.keyCaptureSerial
    self.captureInputReady=nil;self.captureEnding=true;self.captureCommitPending=true
    -- Keep the input shield through the complete key-up/click dispatch. In
    -- particular Escape must not reach Settings or the native game menu.
    local function Complete()
        if self.keyCaptureSerial~=serial then return end
        local entry=self.captureGamepadEntry
        if key and (self.db~=self.captureDB or self:IsFishingGamepadMode()~=self.captureGamepadMode
            or (InCombatLockdown and InCombatLockdown()) or (self.captureGamepadDefaults and key~="PAD1")) then
            key=nil;other=nil
        end
        if key and entry then
            local profile=self.db.gamepadBindings
            if not self.gamepadModePending or profile~=entry.profile or (type(profile)=="table" and profile.fishing)~=entry.key then
                key=nil;other=nil
            end
        end
        if key then
            local ok
            if other then ok=self:ReplaceFishingActionBinding(action,key,other)
            else ok=self:SetFishingActionBinding(action,key) end
            if self.keyCaptureSerial~=serial then return end
            if not ok then
                self.captureEnding=nil;self.captureCommitPending=nil;self.captureInputReady=true
                self:ReviewFishingBinding(key);return
            end
            if entry and self.gamepadModePending and self.db==self.captureDB and self:GetFishingInputKey()==key then
                self.db.gamepadMode=true
            end
        end
        self.gamepadModePending=nil;self.captureGamepadMode=nil;self.captureGamepadModifiers=nil;self.captureShoulderTap=nil
        self.captureGamepadDefaults=nil;self.captureDB=nil;self.captureGamepadEntry=nil
        self.keyCaptureAction,self.capturePressedKey,self.captureCandidate,self.captureCanConfirm,self.captureConflictAction=nil,nil,nil,nil,nil
        self.captureRightAt=nil;self.captureEnding=nil;self.captureCommitPending=nil
        self.captureChanging=true;self.capture:Hide();self.captureChanging=nil
        if self.captureDimAnimation then self.captureDimAnimation:Stop() end
        self:RestoreBindingCaptureVisibility()
        self:ApplyBindings();self:RefreshUI()
        if self.settingsPanel and self.settingsPanel.RefreshBindingControls then self.settingsPanel:RefreshBindingControls() end
    end
    if interrupted then Complete()
    elseif C_Timer and C_Timer.After then C_Timer.After(0,Complete) else Complete() end
end
function FF:InterruptKeyCapture()
    self:FinishKeyCapture(nil,true)
end

local function MakePanel(name, width, height)
    local panel = CreateFrame("Frame", name, FF:EnsureFishingVisibilityRoot())
    panel:SetSize(width, height)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata(WINDOW_STRATA)
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel.topEdge = Backdrop(panel)
    OrnateBorder(panel, 1, 27)
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
    close:SetScript("OnClick", function() panel:Hide() end)
    panel.closeButton = close
    panel:Hide()
    return panel
end

local function ClampFloatingScale(width, height, value)
    local fitWidth = (UIParent:GetWidth() - 36) / width
    local fitHeight = (UIParent:GetHeight() - 36) / height
    return math.max(0.7, math.min(1.8, fitWidth, fitHeight, value))
end

local function ClampFloatingSize(panel, key, width, height)
    local bounds = FLOATING_SIZE_BOUNDS[key]
    if not bounds then return width, height end
    local scale = panel:GetScale()
    if not scale or scale <= 0 then scale = 1 end
    local maxWidth = math.min(bounds.maxWidth, (UIParent:GetWidth() - 36) / scale)
    local maxHeight = math.min(bounds.maxHeight, (UIParent:GetHeight() - 36) / scale)
    local minWidth = math.min(bounds.minWidth, maxWidth)
    local minHeight = math.min(bounds.minHeight, maxHeight)
    return math.max(minWidth, math.min(maxWidth, tonumber(width) or bounds.width)),
        math.max(minHeight, math.min(maxHeight, tonumber(height) or bounds.height))
end

local function SaveFloatingLayout(owner, panel, key)
    -- Store UIParent-unit offsets like the fishing bars; GetCenter() alone is
    -- expressed in the floating frame's effective scale and drifts on restore.
    local x, y = CenterOffset(panel)
    if not (x and y) then return end
    local expanded=type(panel.floatingExpandedSize)=="table" and panel.floatingExpandedSize or nil
    if expanded then
        local relative=panel:GetEffectiveScale()/UIParent:GetEffectiveScale()
        y=y-(expanded.height-panel:GetHeight())*relative/2
    end
    local record = { x = x, y = y, scale = panel:GetScale() }
    if FLOATING_SIZE_BOUNDS[key] then
        record.width, record.height = expanded and expanded.width or panel:GetWidth(), expanded and expanded.height or panel:GetHeight()
    end
    owner.db.windowLayouts = type(owner.db.windowLayouts) == "table" and owner.db.windowLayouts or {}
    owner.db.windowLayouts[key] = record
end

-- Temporary heading strips retain the expanded top edge and save expanded
-- geometry, including after dragging/closing/logout while minimized.
function FF:SetFloatingWindowMinimized(panel,minimized,height)
    if not panel or (InCombatLockdown and InCombatLockdown()) then return false end
    local expanded=type(panel.floatingExpandedSize)=="table" and panel.floatingExpandedSize or nil
    if (minimized and expanded) or (not minimized and not expanded) then return true end
    local grip=panel.scaleGrip
    if grip and grip.scaling==true then
        grip.scaling=nil;grip:SetScript("OnUpdate",nil);panel:StopMovingOrSizing()
    end
    local oldHeight=panel:GetHeight()
    local x,y=CenterOffset(panel)
    local relative=panel:GetEffectiveScale()/UIParent:GetEffectiveScale()
    local width,newHeight
    if minimized then
        expanded={width=panel:GetWidth(),height=oldHeight}; panel.floatingExpandedSize=expanded
        width,newHeight=expanded.width,height or 38
    else
        width,newHeight=ClampFloatingSize(panel,panel.floatingLayoutKey,expanded.width,expanded.height)
    end
    panel.floatingSizeChanging=true
    panel:SetSize(width,newHeight)
    if x and y then SetCenterOffset(panel,x,y+(oldHeight-newHeight)*relative/2) end
    if not minimized then panel.floatingExpandedSize=nil end
    panel.floatingSizeChanging=nil
    return true
end

function FF:CommitOpenFloatingWindowLayouts()
    local function Commit(panel)
        if panel and panel.floatingWasShown and panel:IsShown() then
            SaveFloatingLayout(self, panel, panel.floatingLayoutKey)
        end
    end
    Commit(self.settingsPanel)
    Commit(self.journalPanel)
    Commit(self.sessionGoalsPanel)
    Commit(self.sessionTrackerPanel)
end

function FF:StyleFishingQuickIcon(button, icon, fullTexture)
    StyleSmartIcon(button, icon, fullTexture)
end

function FF:PrepareFloatingWindow(panel, key, dragHandle)
    self.db.windowLayouts = type(self.db.windowLayouts) == "table" and self.db.windowLayouts or {}
    local saved = type(self.db.windowLayouts[key]) == "table" and self.db.windowLayouts[key] or nil
    local defaults = FLOATING_DEFAULTS[key] or { x = 0, y = 0, scale = 1 }
    panel.floatingLayoutKey = key
    SetFishingSurfaceLayer(panel, WINDOW_STRATA)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    local function ClampScale(value)
        return ClampFloatingScale(panel:GetWidth(), panel:GetHeight(), value)
    end
    local bounds = FLOATING_SIZE_BOUNDS[key]
    if bounds then panel:SetSize(saved and tonumber(saved.width) or bounds.width,
        saved and tonumber(saved.height) or bounds.height) end
    local initialScale = saved and tonumber(saved.scale) or defaults and defaults.scale or 1
    -- Dimension-only windows fit their viewport, never shrink their type/icons
    -- merely because previously saved dimensions exceed this screen.
    panel:SetScale(panel.floatingResizeOnly == true and math.max(0.7, math.min(1.8, initialScale)) or ClampScale(initialScale))
    if bounds then panel:SetSize(ClampFloatingSize(panel, key, panel:GetWidth(), panel:GetHeight())) end
    if saved then
        SetCenterOffset(panel, tonumber(saved.x) or defaults.x, tonumber(saved.y) or defaults.y)
    elseif defaults then
        SetCenterOffset(panel, defaults.x, defaults.y)
    end
    local function SaveLayout()
        SaveFloatingLayout(self, panel, panel.floatingLayoutKey or key)
    end
    dragHandle = dragHandle or panel
    dragHandle:EnableMouse(true)
    dragHandle:HookScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then self:BringFishingWindowForward(panel) end
    end)
    dragHandle:RegisterForDrag("LeftButton")
    local function StartWindowDrag()
        if not InCombatLockdown or not InCombatLockdown() then panel:StartMoving() end
    end
    local function StopWindowDrag()
        panel:StopMovingOrSizing()
        local x, y = CenterOffset(panel)
        if x and y then SetCenterOffset(panel, x, y) end
        SaveLayout()
        self:RefreshFishingLayer()
    end
    dragHandle:SetScript("OnDragStart", StartWindowDrag)
    dragHandle:SetScript("OnDragStop", StopWindowDrag)
    panel.floatingDragStart, panel.floatingDragStop = StartWindowDrag, StopWindowDrag
    local grip = CreateFrame("Button", nil, panel)
    grip:SetSize(30, 30)
    grip:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -4, 4)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight", "ADD")
    grip:RegisterForDrag("LeftButton")
    grip:SetScript("OnDragStart", function(button)
        if InCombatLockdown and InCombatLockdown() then return end
        self:BringFishingWindowForward(panel)
        button.startX, button.startY = GetCursorPosition()
        button.startScale = panel:GetScale()
        button.startWidth, button.startHeight = panel:GetWidth(), panel:GetHeight()
        button.startCenterX, button.startCenterY = CenterOffset(panel)
        button.resizeDimensions = FLOATING_SIZE_BOUNDS[panel.floatingLayoutKey] ~= nil
            and (panel.floatingResizeOnly == true or not (IsControlKeyDown and IsControlKeyDown()))
        button.scaling = true
        button:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            if button.resizeDimensions then
                local effective = panel:GetEffectiveScale()
                if not effective or effective <= 0 then effective = 1 end
                local width, height = ClampFloatingSize(panel, panel.floatingLayoutKey,
                    button.startWidth + (x - button.startX) / effective,
                    button.startHeight + (button.startY - y) / effective)
                panel:SetSize(width, height)
                if panel.floatingResizeFromTopLeft == true and button.startCenterX and button.startCenterY then
                    local relative = effective / UIParent:GetEffectiveScale()
                    SetCenterOffset(panel, button.startCenterX + (width - button.startWidth) * relative / 2,
                        button.startCenterY - (height - button.startHeight) * relative / 2)
                end
            else
                local delta = ((x - button.startX) - (y - button.startY)) / 450
                panel:SetScale(ClampScale(button.startScale + delta))
                if button.startCenterX and button.startCenterY then
                    SetCenterOffset(panel, button.startCenterX, button.startCenterY)
                end
            end
        end)
    end)
    grip:SetScript("OnDragStop", function(button)
        if not button.scaling then return end
        button.scaling = nil
        button:SetScript("OnUpdate", nil)
        if panel.OnFloatingResizeFinished then panel:OnFloatingResizeFinished() end
        SaveLayout()
        self:RefreshFishingLayer()
    end)
    grip:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(panel.floatingResizeOnly == true and FF:LocalizedText("window.resize-dimensions") or FLOATING_SIZE_BOUNDS[panel.floatingLayoutKey]
            and FF:LocalizedText("window.resize-scale") or FF:LocalizedText("window.scale"))
        GameTooltip:Show()
    end)
    grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
    panel.scaleGrip = grip
    panel:HookScript("OnHide", function()
        if panel.floatingWasShown then SaveLayout() end
    end)
end

function FF:UseFloatingWindowLayout(panel, key, width, height)
    if not (panel and self.db) then return end
    self.db.windowLayouts = type(self.db.windowLayouts) == "table" and self.db.windowLayouts or {}
    local prior = panel.floatingLayoutKey
    if prior and prior ~= key then
        SaveFloatingLayout(self, panel, prior)
    end
    panel.floatingLayoutKey = key
    local saved = type(self.db.windowLayouts[key]) == "table" and self.db.windowLayouts[key] or nil
    local defaults = FLOATING_DEFAULTS[key] or { x = 0, y = 0, scale = 1 }
    local bounds = FLOATING_SIZE_BOUNDS[key]
    if bounds then
        panel:SetSize(saved and tonumber(saved.width) or bounds.width,
            saved and tonumber(saved.height) or bounds.height)
    elseif width and height then panel:SetSize(width, height) end
    panel:SetScale(ClampFloatingScale(panel:GetWidth(), panel:GetHeight(),
        saved and tonumber(saved.scale) or defaults.scale))
    if bounds then panel:SetSize(ClampFloatingSize(panel, key, panel:GetWidth(), panel:GetHeight())) end
    if saved then
        SetCenterOffset(panel, tonumber(saved.x) or defaults.x,
            tonumber(saved.y) or defaults.y)
    else
        SetCenterOffset(panel, defaults.x, defaults.y)
    end
end

function FF:ResetFishingLayouts()
    self.db.position, self.db.toolsPosition = nil, nil
    self.db.catchRecapPosition = nil
    self.db.barScale, self.db.toolsScale = nil, nil
    if type(self.db.windowLayouts) == "table" then
        self.db.windowLayouts.settings = nil
        self.db.windowLayouts.journal = nil
        self.db.windowLayouts.masterChef = nil
        self.db.windowLayouts.sessionGoals = nil
        self.db.windowLayouts.sessionTracker = nil
    end
    for _, layout in ipairs({
        { self.bar, LAYOUT_DEFAULTS.bar },
        { self.toolBar, LAYOUT_DEFAULTS.tools },
        { self.settingsPanel, FLOATING_DEFAULTS.settings },
        { self.journalPanel, self.journalPanel and self.journalPanel.compactChef == true
            and FLOATING_DEFAULTS.masterChef or FLOATING_DEFAULTS.journal },
        { self.sessionGoalsPanel, FLOATING_DEFAULTS.sessionGoals },
        { self.sessionTrackerPanel, FLOATING_DEFAULTS.sessionTracker },
    }) do
        local frame, defaults = layout[1], layout[2]
        if frame then
            if frame == self.journalPanel then
                local bounds = FLOATING_SIZE_BOUNDS[frame.compactChef and "masterChef" or "journal"]
                frame:SetSize(bounds.width, bounds.height)
            elseif frame == self.sessionGoalsPanel then
                if frame.floatingExpandedSize and self.SetSessionGoalsMinimized then self:SetSessionGoalsMinimized(false) end
                local bounds = FLOATING_SIZE_BOUNDS.sessionGoals
                frame:SetSize(bounds.width, bounds.height)
            elseif frame == self.sessionTrackerPanel then
                local bounds = FLOATING_SIZE_BOUNDS.sessionTracker
                frame:SetSize(bounds.width, bounds.height)
            end
            local scale = defaults.scale
            if frame == self.settingsPanel or frame == self.journalPanel or frame == self.sessionGoalsPanel
                or frame == self.sessionTrackerPanel then
                scale = ClampFloatingScale(frame:GetWidth(), frame:GetHeight(), scale)
            end
            frame:SetScale(scale)
            SetCenterOffset(frame, defaults.x, defaults.y)
        end
    end
    if self.PositionCatchRecap then self:PositionCatchRecap() end
end

function FF:BringFishingWindowForward(panel)
    if not panel or self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown()) then return end
    if self.settingsPanel and panel ~= self.settingsPanel and self.settingsKeyboardFocus then
        self.settingsKeyboardFocus = nil
        if self.settingsPanel.SetSettingsFocus then self.settingsPanel:SetSettingsFocus(nil) end
        self:ApplyBindings()
    end
    local order = self.floatingWindows or {}
    if order[#order] == panel then return end
    for index = #order, 1, -1 do
        if order[index] == panel then table.remove(order, index) end
    end
    order[#order + 1] = panel
    self.floatingWindows = order
    local level = WINDOW_LEVEL
    for _, window in ipairs(order) do
        local highest = SetFishingSurfaceLayer(window, window:GetFrameStrata(), level)
        self.windowLevel = highest
        level = math.max(level + WINDOW_LEVEL_GAP, highest + 1)
    end
end

function FF:ShowFloatingWindow(panel)
    if self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown()) then return end
    if self.gearPicker then self.gearPicker:Hide() end
    if self.lurePicker then self.lurePicker:Hide() end
    if self.utilityPicker then self.utilityPicker:Hide() end
    if self.settingsPicker then self.settingsPicker:Hide() end
    if self.journalPicker then self.journalPicker:Hide() end
    if self.CloseFishingQuickTray then self:CloseFishingQuickTray() end
    self:BringFishingWindowForward(panel)
    panel.floatingWasShown = true
    panel:Show()
    self:RefreshFishingLayer()
end

function FF:ShowFishingBugReport()
    if not self.db or self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown()) then return end
    local report, url = self:BuildFishingBugReport()
    local panel = self.bugReportPanel
    if not panel then
        panel = MakePanel("ForeverFishingBugReport", 700, 490)
        self.bugReportPanel = panel
        local function CopyField(parent, multiline)
            local field = CreateFrame("EditBox", nil, parent, not multiline and "InputBoxTemplate" or nil)
            field:SetMultiLine(multiline)
            field:SetAutoFocus(false)
            field:SetFontObject(GameFontHighlightSmall)
            field:EnableMouse(true)
            field:SetScript("OnTextChanged", function(box, userInput)
                if userInput then box:SetText(box.bugReportText or "") end
            end)
            field:SetScript("OnEditFocusGained", function(box) self:SetJournalInputFocus(box, true) end)
            field:SetScript("OnEditFocusLost", function(box) self:SetJournalInputFocus(box, false) end)
            field:SetScript("OnEscapePressed", function() panel:Hide() end)
            return field
        end
        local function SetCopyText(field, value)
            field.bugReportText = value
            field:SetText(value)
        end
        panel.SetCopyText = SetCopyText
        local function SelectAll(field)
            field:SetFocus()
            field:HighlightText()
        end
        local title = Text(panel, "GameFontNormalLarge", 18, -16, self:LocalizedText("bug-report.title"))
        title:SetTextColor(unpack(ACCENT))
        local instructions = Text(panel, "GameFontHighlight", 18, -43,
            self:LocalizedText("bug-report.instructions", "|cffffcc64In-game diagnostics (preferred)|r")
            .. "\n" .. self:LocalizedText("bug-report.github-account")
            .. "\n" .. self:LocalizedText("bug-report.curseforge-pm"))
        instructions:SetWidth(664)
        instructions:SetJustifyH("LEFT")
        instructions:SetWordWrap(true)

        local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", instructions, "BOTTOMLEFT", 4, -17)
        scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -34, 124)
        panel.reportScroll = scroll
        panel.reportEdit = CopyField(scroll, true)
        panel.reportEdit:SetWidth(644)
        scroll:SetScrollChild(panel.reportEdit)
        local background = panel:CreateTexture(nil, "BORDER")
        background:SetPoint("TOPLEFT", scroll, "TOPLEFT", -5, 5)
        background:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 5, -5)
        background:SetColorTexture(.018, .035, .05, .95)

        local status = Text(panel, "GameFontHighlightSmall", 18, 0, "")
        status:ClearAllPoints()
        status:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 18, 89)
        status:SetWidth(664)
        status:SetJustifyH("LEFT")
        status:SetWordWrap(true)
        panel.copyStatus = status
        panel.linkEdit = CopyField(panel, false)
        panel.linkEdit:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 57)
        panel.linkEdit:SetSize(658, 23)
        panel.linkEdit:SetScript("OnMouseUp", SelectAll)
        panel.linkEdit:Hide()

        local function Hint(key)
            local shortcut = IsMacClient and IsMacClient() and "Command+C" or "Ctrl+C"
            status:SetText(self:LocalizedText(key, shortcut))
        end
        panel.copyButton = self:CreateFishingBindingDialogButton(panel, "bug-report.copy", 172, 36, function()
            -- Addons cannot write to the clipboard through CopyToClipboard on Forever.
            SelectAll(panel.reportEdit)
            Hint("bug-report.manual-copy")
        end)
        panel.copyButton:ClearAllPoints()
        panel.copyButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 18, 13)
        panel.openButton = self:CreateFishingBindingDialogButton(panel, "bug-report.open", 230, 36, function()
            panel.linkEdit:Show()
            SelectAll(panel.linkEdit)
            Hint("bug-report.manual-link")
        end)
        panel.openButton:ClearAllPoints()
        panel.openButton:SetPoint("LEFT", panel.copyButton, "RIGHT", 12, 0)
        panel.linkEdit:SetScript("OnHide", function(box) box:ClearFocus() end)
        panel:SetScript("OnHide", function()
            panel.reportEdit:ClearFocus()
            panel.linkEdit:ClearFocus()
            SetCopyText(panel.reportEdit, "")
            SetCopyText(panel.linkEdit, "")
        end)
        if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "ForeverFishingBugReport" end
        self:RegisterCombatCloseWindow("bugReport", panel)
    end
    local estimatedLines = 0
    for line in (report .. "\n"):gmatch("([^\n]*)\n") do
        estimatedLines = estimatedLines + math.max(1, math.ceil(#line / 84))
    end
    panel.reportEdit:SetHeight(math.max(280, estimatedLines * 16 + 20))
    panel.SetCopyText(panel.reportEdit, report)
    panel.SetCopyText(panel.linkEdit, url)
    panel.linkEdit:Hide()
    panel.copyStatus:SetText("")
    panel:SetScale(ClampFloatingScale(panel:GetWidth(), panel:GetHeight(), 1))
    self:ShowFloatingWindow(panel)
    panel.reportScroll:SetVerticalScroll(0)
end

function FF:ShowTraceWindow(report, titleText, subtitleText)
    if not self.tracePanel then
        local panel = MakePanel("ForeverFishingTracePanel", 700, 430)
        self:PrepareFloatingWindow(panel, "report", panel)
        local title = Text(panel, "GameFontNormalLarge", 18, -17, "Fishing trace")
        title:SetTextColor(unpack(ACCENT))
        local subtitle = Text(panel, "GameFontHighlightSmall", 18, -43, "Recent cast events and current interaction state")
        subtitle:SetTextColor(0.68, 0.78, 0.81)
        self.reportTitle = title
        self.reportSubtitle = subtitle

        local body = panel:CreateTexture(nil, "BORDER")
        body:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -74)
        body:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -14, 54)
        body:SetColorTexture(0.018, 0.035, 0.05, 0.95)
        local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 22, -82)
        scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -34, 62)
        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal or GameFontHighlightSmall)
        edit:SetTextColor(0.88, 0.94, 0.96)
        edit:SetWidth(620)
        edit:SetHeight(280)
        edit:SetScript("OnEscapePressed", function() panel:Hide() end)
        scroll:SetScrollChild(edit)
        panel:SetScript("OnHide", function()
            edit:ClearFocus()
            local note = self.scanDiagnosticsNote
            if note and note.field then note.field:SetScript("OnUpdate", nil) end
        end)

        local selectAll = PlainButton(panel, "Select all", 94, 27, function()
            if self.traceDiagnostics and self.scanDiagnostics and self.scanDiagnostics.viewing then
                if self.scanDiagnosticsNote then self.scanDiagnosticsNote:ClearFocus() end
                local report = self.scanDiagnostics:Report()
                if edit:GetText() ~= report then
                    self:ShowTraceWindow(report, "Scan Diagnostics Report", self.reportSubtitle:GetText())
                end
            end
            edit:SetFocus()
            edit:HighlightText()
        end)
        selectAll:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 15, 13)
        local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("LEFT", selectAll, "RIGHT", 13, 0)
        hint:SetText("Press Ctrl+C to copy, then paste the report here.")
        hint:SetTextColor(0.67, 0.78, 0.82)
        local thanks = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        thanks:SetPoint("BOTTOM", panel, "BOTTOM", 0, 13)
        thanks:SetText("Thank you for helping make fishing better for everyone!")
        thanks:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
        thanks:SetTextColor(0.67, 0.78, 0.82)
        thanks:Hide()
        self.tracePanel = panel
        self.traceEdit = edit
        self.traceScroll = scroll
        self.traceBody = body
        self.traceSelectAll = selectAll
        self.traceCopyHint = hint
        self.traceThanks = thanks
    end

    self.reportTitle:SetText(titleText or "Fishing trace")
    self.reportSubtitle:SetText(subtitleText or "Recent cast events and current interaction state")
    local diagnostics = titleText == "Scan Diagnostics Report"
    self.traceDiagnostics = diagnostics
    if diagnostics then self.reportSubtitle:SetTextColor(unpack(ACCENT))
    else self.reportSubtitle:SetTextColor(0.68, 0.78, 0.81) end
    self.tracePanel.topEdge:SetShown(not diagnostics)
    self.traceThanks:SetShown(diagnostics)
    self.traceSelectAll:SetText(diagnostics and "Select All" or "Select all")
    self.traceCopyHint:SetText(diagnostics and "Press Ctrl+C to copy the report." or "Press Ctrl+C to copy, then paste the report here.")
    self.traceSelectAll:SetPoint("BOTTOMLEFT", self.tracePanel, "BOTTOMLEFT", diagnostics and 20 or 15, diagnostics and 35 or 13)
    -- Leave room for the diagnostic description and footer within this panel.
    local note = self.scanDiagnosticsNote
    local descriptionHeight = note and note.field and note.field:GetHeight() or 26
    local bodyTop = diagnostics and -(80 + descriptionHeight) or -74
    self.traceBody:SetPoint("TOPLEFT", self.tracePanel, "TOPLEFT", 14, bodyTop)
    self.traceBody:SetPoint("BOTTOMRIGHT", self.tracePanel, "BOTTOMRIGHT", -14, diagnostics and 70 or 54)
    self.traceScroll:SetPoint("TOPLEFT", self.tracePanel, "TOPLEFT", 22, bodyTop-8)
    self.traceScroll:SetPoint("BOTTOMRIGHT", self.tracePanel, "BOTTOMRIGHT", -34, diagnostics and 78 or 62)
    local estimatedLines = 0
    for line in (report .. "\n"):gmatch("([^\n]*)\n") do
        estimatedLines = estimatedLines + math.max(1, math.ceil(#line / 90))
    end
    self.traceEdit:SetHeight(math.max(280, estimatedLines * 16 + 20))
    self.traceEdit:SetText(report)
    self:ShowFloatingWindow(self.tracePanel)
    self.traceScroll:SetVerticalScroll(0)
    self.traceEdit:SetFocus()
    self.traceEdit:HighlightText()
end

function FF:StopScanReportNoteAnimation()
    local note = self.scanDiagnosticsNote
    if note and note.field then note.field:SetScript("OnUpdate", nil) end
end

function FF:SetScanReportNoteHeight(height, immediate)
    local note = self.scanDiagnosticsNote
    if not note or not note.field then return end
    local field, scroll = note.field, note.scroll
    if field.targetHeight == height and not immediate then return end
    field.targetHeight = height
    field:SetScript("OnUpdate", nil)
    local function Apply(value)
        field:SetHeight(value); scroll:SetHeight(value-12)
        local maximum = math.max(0, (note.contentHeight or 14)-scroll:GetHeight())
        scroll:SetVerticalScroll(math.min(scroll:GetVerticalScroll(), maximum))
        if self.traceDiagnostics then
            self.traceBody:SetPoint("TOPLEFT", self.tracePanel, "TOPLEFT", 14, -(80+value))
            self.traceScroll:SetPoint("TOPLEFT", self.tracePanel, "TOPLEFT", 22, -(88+value))
        end
    end
    local start = field:GetHeight()
    if immediate or math.abs(start-height) < .1 then Apply(height); return end
    -- A report-only 0.14s animation; detached at completion or report departure.
    local elapsed = 0
    field:SetScript("OnUpdate", function(_, dt)
        elapsed = math.min(.14, elapsed+dt)
        local progress = elapsed/.14
        progress = progress*progress*(3-2*progress)
        Apply(start+(height-start)*progress)
        if elapsed >= .14 then field:SetScript("OnUpdate", nil) end
    end)
end

function FF:ShowLayoutChanges()
    if not self.bar or not self.toolBar then return end
    local function Position(frame, saved, defaults)
        if frame then
            local x, y = CenterOffset(frame)
            if x and y then return x, y end
        end
        if type(saved) ~= "table" then saved = nil end
        return saved and (tonumber(saved.x) or defaults.x) or defaults.x,
            saved and (tonumber(saved.y) or defaults.y) or defaults.y
    end
    local barX, barY = Position(self.bar, self.db.position, LAYOUT_DEFAULTS.bar)
    local toolX, toolY = Position(self.toolBar, self.db.toolsPosition, LAYOUT_DEFAULTS.tools)
    local barScale, toolScale = self.bar:GetScale(), self.toolBar:GetScale()
    local markerDefaults = { x = 0, y = self.cameraMarkerDefaultHeight }
    local markerSaved = { x = 0, y = tonumber(self.db.cameraMarkerHeight) or markerDefaults.y }
    local markerX, markerY = markerSaved.x, markerSaved.y
    if self.cameraMarker then markerX, markerY = Position(self.cameraMarker, markerSaved, markerDefaults) end
    local lines = {
        "Forever Fishing layout changes",
        string.format("Game UI: %.0f x %.0f units; UI scale %.3f", UIParent:GetWidth(), UIParent:GetHeight(), UIParent:GetScale()),
        "Position is measured from screen center in game UI units; positive X is right, positive Y is up.",
        "",
        "Cast control",
        string.format("Center offset: X %.1f, Y %.1f", barX, barY),
        string.format("Default offset: X %.1f, Y %.1f", LAYOUT_DEFAULTS.bar.x, LAYOUT_DEFAULTS.bar.y),
        string.format("Position change: X %+.1f, Y %+.1f", barX - LAYOUT_DEFAULTS.bar.x, barY - LAYOUT_DEFAULTS.bar.y),
        string.format("Scale: %.3f (default %.3f; change %+.3f)", barScale, LAYOUT_DEFAULTS.bar.scale, barScale - LAYOUT_DEFAULTS.bar.scale),
        string.format("Frame size: %.0f x %.0f UI units", self.bar:GetWidth(), self.bar:GetHeight()),
        string.format("Scaled size: %.0f x %.0f UI units", self.bar:GetWidth() * barScale, self.bar:GetHeight() * barScale),
        "",
        "Icon bar",
        string.format("Center offset: X %.1f, Y %.1f", toolX, toolY),
        string.format("Default offset: X %.1f, Y %.1f", LAYOUT_DEFAULTS.tools.x, LAYOUT_DEFAULTS.tools.y),
        string.format("Position change: X %+.1f, Y %+.1f", toolX - LAYOUT_DEFAULTS.tools.x, toolY - LAYOUT_DEFAULTS.tools.y),
        string.format("Scale: %.3f (default %.3f; change %+.3f)", toolScale, LAYOUT_DEFAULTS.tools.scale, toolScale - LAYOUT_DEFAULTS.tools.scale),
        string.format("Frame size: %.0f x %.0f UI units; %d category icons; mode %s", self.toolBar:GetWidth(), self.toolBar:GetHeight(), self:GetFishingBarCategoryCount(), self:GetFishingBarOrientation()),
        string.format("Configured full category width: %.0f UI units", self:GetFishingFullBarWidth()),
        string.format("Scaled size: %.0f x %.0f UI units", self.toolBar:GetWidth() * toolScale, self.toolBar:GetHeight() * toolScale),
        "",
        "Cursor box",
        string.format("Center offset: X %.1f, Y %.1f", markerX, markerY),
        string.format("Default offset: X %.1f, Y %.1f", markerDefaults.x, markerDefaults.y),
        string.format("Position change: X %+.1f, Y %+.1f", markerX - markerDefaults.x, markerY - markerDefaults.y),
    }
    local function AddFloatingWindow(title, frame, key, defaultWidth, defaultHeight)
        local saved = type(self.db.windowLayouts) == "table" and self.db.windowLayouts[key] or nil
        if type(saved) ~= "table" then saved = nil end
        local configured = FLOATING_DEFAULTS[key] or { x = 0, y = 0, scale = 1 }
        local defaults = { x = configured.x, y = configured.y,
            scale = ClampFloatingScale(defaultWidth, defaultHeight, configured.scale) }
        local x, y = Position(frame, saved, defaults)
        local width = frame and frame:GetWidth() or defaultWidth
        local height = frame and frame:GetHeight() or defaultHeight
        local scale = frame and frame:GetScale()
            or ClampFloatingScale(width, height, saved and tonumber(saved.scale) or defaults.scale)
        lines[#lines + 1] = ""
        lines[#lines + 1] = title
        lines[#lines + 1] = string.format("Center offset: X %.1f, Y %.1f", x, y)
        lines[#lines + 1] = string.format("Default offset: X %.1f, Y %.1f", defaults.x, defaults.y)
        lines[#lines + 1] = string.format("Position change: X %+.1f, Y %+.1f", x - defaults.x, y - defaults.y)
        lines[#lines + 1] = string.format("Scale: %.3f (default %.3f; change %+.3f)", scale, defaults.scale, scale - defaults.scale)
        lines[#lines + 1] = string.format("Frame size: %.0f x %.0f UI units", width, height)
        lines[#lines + 1] = string.format("Scaled size: %.0f x %.0f UI units", width * scale, height * scale)
    end
    AddFloatingWindow("Fishing settings window", self.settingsPanel, "settings", 1148, 768)
    if self.journalPanel and self.journalPanel.compactChef == true then
        AddFloatingWindow("Master Chef window", self.journalPanel, "masterChef", 517, 519)
    else
        AddFloatingWindow("Fishing journal window", self.journalPanel, "journal", 750, 560)
    end
    self:ShowTraceWindow(table.concat(lines, "\n"), "Fishing layout", "Copy this report and paste it into the chat")
end

function FF:ToggleFishingJournal()
    if self.journalPicker and not (InCombatLockdown and InCombatLockdown()) then self.journalPicker:Hide() end
    if self.journalPanel and self.journalPanel:IsShown() and not self.journalPanel.compactChef then
        self.journalPanel:Hide()
    else self:ShowJournal(true) end
end

function FF:InitializeUI()
    self:InitializeFishingPresentationSettings()
    local visibilityRoot = self:EnsureFishingVisibilityRoot()
    local barScale = math.max(0.65, math.min(1.5, tonumber(self.db.barScale) or LAYOUT_DEFAULTS.bar.scale))
    local toolsScale = math.max(0.65, math.min(1.5, tonumber(self.db.toolsScale) or LAYOUT_DEFAULTS.tools.scale))
    if self.db.layoutCoordinateVersion ~= 2 then
        local parentX, parentY = UIParent:GetCenter()
        if parentX and parentY then
            local function ConvertOldOffset(saved, relativeScale)
                if type(saved) ~= "table" then return end
                if tonumber(saved.x) then saved.x = (parentX + tonumber(saved.x)) * relativeScale - parentX end
                if tonumber(saved.y) then saved.y = (parentY + tonumber(saved.y)) * relativeScale - parentY end
            end
            ConvertOldOffset(self.db.position, barScale)
            ConvertOldOffset(self.db.toolsPosition, toolsScale)
            self.db.layoutCoordinateVersion = 2
        end
    end
    local removedIconShift = (OLD_TOOLS_WIDTH - FIVE_ICON_TOOLS_WIDTH) * toolsScale / 2
    if (tonumber(self.db.toolsIconCountVersion) or 0) < 5 then
        if type(self.db.toolsPosition) == "table" and tonumber(self.db.toolsPosition.x) then
            self.db.toolsPosition.x = tonumber(self.db.toolsPosition.x) - removedIconShift
        end
        self.db.toolsIconCountVersion = 5
    end
    if (tonumber(self.db.toolsIconCountVersion) or 0) < 6 then
        if type(self.db.toolsPosition) == "table" and tonumber(self.db.toolsPosition.x) then
            self.db.toolsPosition.x = tonumber(self.db.toolsPosition.x) + FOUR_ICON_CENTER_SHIFT
        end
        self.db.toolsIconCountVersion = 6
    end
    if (tonumber(self.db.toolsIconCountVersion) or 0) < 7 then
        if type(self.db.toolsPosition) == "table" and tonumber(self.db.toolsPosition.x) then
            self.db.toolsPosition.x = tonumber(self.db.toolsPosition.x) + THREE_ICON_CENTER_SHIFT
        end
        self.db.toolsIconCountVersion = 7
    end
    -- The three-icon bar was already centered. Keep its saved center when
    -- restoring the fourth icon so existing layouts remain in place.
    if (tonumber(self.db.toolsIconCountVersion) or 0) < 8 then
        self.db.toolsIconCountVersion = 8
    end
    -- The icon bar is anchored by its center, so adding Camera Assist does
    -- not change the saved position of either bar.
    if (tonumber(self.db.toolsIconCountVersion) or 0) < 9 then
        self.db.toolsIconCountVersion = 9
    end
    -- The four-icon migration and the new Master Chef icon keep the saved center.
    self.db.toolsIconCountVersion = 11
    local bar = CreateFrame("Frame", "ForeverFishingBar", visibilityRoot, "SecureHandlerBaseTemplate")
    bar:SetSize(450, 102)
    bar:SetScale(barScale)
    local barPosition = type(self.db.position) == "table" and self.db.position or nil
    SetCenterOffset(bar,
        barPosition and (tonumber(barPosition.x) or LAYOUT_DEFAULTS.bar.x) or LAYOUT_DEFAULTS.bar.x,
        barPosition and (tonumber(barPosition.y) or LAYOUT_DEFAULTS.bar.y) or LAYOUT_DEFAULTS.bar.y)
    bar:SetFrameStrata(HUD_STRATA)
    bar:SetFrameLevel(HUD_LEVEL)
    bar:SetClampedToScreen(true)
    bar:SetMovable(true)
    bar:Hide()
    self.bar = bar
    if self.InstallFishingUIVisibilityHook then self:InstallFishingUIVisibilityHook() end
    local guard = CreateFrame("Button", "ForeverFishingGuardButton", visibilityRoot)
    guard:SetSize(1, 1)
    guard:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    guard:SetAlpha(0)
    guard:RegisterForClicks("AnyUp")
    guard:SetScript("OnClick", function() if self.OnFishingGuardClick then self:OnFishingGuardClick() end end)
    self.guardButton = guard
    local notice = CreateFrame("Frame", nil, visibilityRoot)
    notice:SetSize(580, 30)
    notice:SetPoint("TOP", UIParent, "TOP", 0, -95)
    notice:SetFrameStrata(HUD_STRATA)
    notice:EnableMouse(false)
    local noticeText = notice:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    noticeText:SetPoint("CENTER", notice, "CENTER")
    noticeText:SetText(FF:LocalizedText("status.bobber-not-visible"))
    noticeText:SetTextColor(unpack(AMBER))
    noticeText:SetShadowColor(0, 0, 0, 0.85)
    noticeText:SetShadowOffset(1, -1)
    self.rangeNoticeText = noticeText
    notice:Hide()
    self.rangeNotice = notice
    local rodNotice = CreateFrame("Frame", nil, visibilityRoot)
    rodNotice:SetSize(980, 54)
    rodNotice:SetPoint("TOP", UIParent, "TOP", 0, -79)
    rodNotice:SetFrameStrata(HUD_STRATA)
    rodNotice:EnableMouse(false)
    local rodNoticeText = rodNotice:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rodNoticeText:SetPoint("CENTER", rodNotice, "CENTER")
    rodNoticeText:SetSize(960, 50)
    rodNoticeText:SetJustifyH("CENTER")
    rodNoticeText:SetJustifyV("MIDDLE")
    rodNoticeText:SetTextColor(unpack(AMBER))
    rodNoticeText:SetShadowColor(0, 0, 0, 0.85)
    rodNoticeText:SetShadowOffset(1, -1)
    rodNotice:Hide()
    self.fishingRodNotice = rodNotice
    self.fishingRodNoticeText = rodNoticeText
    bar:SetScript("OnShow", function()
        self:SyncBobberInteractIcon()
        if self.SyncFishingFOV then self:SyncFishingFOV() end
        if self.RememberWornFishingGear then self:RememberWornFishingGear(true) end
        if self.toolBar then self.toolBar:Show() end
        self:RefreshFishingLayer()
        self:ApplyBindings()
        if self.RefreshFishingBagSpace then self:RefreshFishingBagSpace() end
        self:UpdateUI()
        self:WarnRangeOnce()
        self:FocusSplashSound()
        self:SyncBackgroundFPS()
        self:SyncAutoLoot()
        self:SyncFishingSounds()
        if self.SyncFishingUIVisibility then self:SyncFishingUIVisibility() end
        if self.RestoreSessionTracker then self:RestoreSessionTracker() end
        if self.RestoreSessionGoals then self:RestoreSessionGoals() end
        if self.RefreshFishingGoldPerHour then self:RefreshFishingGoldPerHour() end
    end)
    bar:SetScript("OnHide", function()
    self.fishingReelLootHandoff,self.fishingReelLootWindow=nil,nil
    if self.InvalidateFishingCapacityRecast then self:InvalidateFishingCapacityRecast() end
        self.cookingInformationCast=nil;self.informationCastEnded=nil;self.informationCastExpected=nil
        if self.ReleaseFishingCastBars then self:ReleaseFishingCastBars() end
        -- Release essential session audio before optional visual cleanup.
        self:FocusSplashSound()
        if self.ClearFishingChannelRecovery then self:ClearFishingChannelRecovery() end
        if self.ClearFishingLureApplication then self:ClearFishingLureApplication() end
        self.bobberStatusWarning = nil
        self:SyncBobberInteractIcon()
        if self.fishingUpdateFrame then self.fishingUpdateFrame:SetScript("OnUpdate", nil) end
        self.gearOpenEquipPending = nil
        self:HideFishingRodWarning()
        self.lastFishingRodWarningAt = nil
        self.lastFishingRodWarningManual = nil
        self.fishingGearNoticeState = nil
        self.fishingBagsFull = nil
        if self.fishingBagsFullNotice then self.fishingBagsFullNotice:Hide() end
        if self.masterChefPreparationNotice and self.masterChefPreparationNotice.kind == "gear" then
            self.masterChefPreparationNotice:Hide()
        end
        self:SyncBackgroundFPS()
        self:SyncAutoLoot()
        self:StopFishingSounds()
        if self.RefreshFishingGoldPerHour then self:RefreshFishingGoldPerHour() end
        if InCombatLockdown and InCombatLockdown() then
            if self.StopCameraAssist then self:StopCameraAssist("Fishing bar closed", true) end
            if self.ReleaseFishingFOV then self:ReleaseFishingFOV(true) end
            self.pendingFishingBarClose = true
            return
        end
        self:FinishFishingBarClose()
    end)
    local toolBar = CreateFrame("Frame", "ForeverFishingTools", visibilityRoot, "SecureHandlerBaseTemplate")
    local iconSpacing = self:GetIconBarSpacing()
    toolBar:SetSize(self:GetFishingFullBarWidth(), 70)
    toolBar:SetFrameStrata(HUD_STRATA)
    toolBar:SetFrameLevel(HUD_LEVEL)
    toolBar:SetClampedToScreen(true)
    toolBar:SetMovable(true)
    toolBar:EnableMouse(false)
    toolBar:SetScale(toolsScale)
    local toolsPosition = type(self.db.toolsPosition) == "table" and self.db.toolsPosition or nil
    local toolsX, toolsY
    if toolsPosition then
        toolsX = tonumber(toolsPosition.x) or LAYOUT_DEFAULTS.tools.x
        toolsY = tonumber(toolsPosition.y) or LAYOUT_DEFAULTS.tools.y
    elseif barPosition then
        -- Preserve the old relative icon-bar placement for bar-only saved layouts.
        toolsX = (tonumber(barPosition.x) or 0) * toolsScale - removedIconShift + FOUR_ICON_CENTER_SHIFT + THREE_ICON_CENTER_SHIFT
        toolsY = ((tonumber(barPosition.y) or 0) + LEGACY_TOOLS_OFFSET_Y) * toolsScale
    else
        toolsX, toolsY = LAYOUT_DEFAULTS.tools.x, LAYOUT_DEFAULTS.tools.y
    end
    SetCenterOffset(toolBar, toolsX, toolsY)
    toolBar:Hide()
    self.toolBar = toolBar

    local function SaveBarPosition()
        local x, y = CenterOffset(bar)
        if x and y then self.db.position = { x = x, y = y } end
    end
    local function SaveToolPosition()
        local x, y = CenterOffset(toolBar)
        if x and y then self.db.toolsPosition = { x = x, y = y } end
    end
    local function SyncGroupedPosition(primary)
        local group = primary.groupMove
        if not group then return end
        local x, y = CenterOffset(primary)
        if x and y then
            SetCenterOffset(group.other, group.otherX + x - group.startX, group.otherY + y - group.startY)
        end
    end
    local function BeginMoving(primary, other)
        primary.groupMove = nil
        if other then
            local startX, startY = CenterOffset(primary)
            local otherX, otherY = CenterOffset(other)
            if startX and startY and otherX and otherY then
                primary.groupMove = { other = other, startX = startX, startY = startY, otherX = otherX, otherY = otherY }
            end
        end
        primary.moving = true
        primary:StartMoving()
        if primary.groupMove then
            primary:SetScript("OnUpdate", function() SyncGroupedPosition(primary) end)
        end
    end
    local function PositionOpenPickers()
        self:ApplyFishingBarPresentation()
        if self.PositionFishingPicker and self.gearPicker and self.gearPicker:IsShown() then
            self.gearPicker.flyoutGeometryLocked = nil
            self:PositionFishingPicker(self.gearPicker, self.gearButton)
        end
        if self.PositionFishingPicker and self.lurePicker and self.lurePicker:IsShown() then
            self.lurePicker.flyoutGeometryLocked = nil
            self:PositionFishingPicker(self.lurePicker, self.lureButton)
        end
        if self.masterChefTray and self.masterChefTray:IsShown() then
            self.masterChefTray.flyoutGeometryLocked = nil
            self:PositionFishingFlyout(self.masterChefTray, self.gearButton)
        end
        if self.utilityPicker and self.utilityPicker:IsShown() then
            self.utilityPicker.flyoutGeometryLocked = nil
            self:PositionFishingFlyout(self.utilityPicker, self.utilityButton)
        end
        if self.settingsPicker and self.settingsPicker:IsShown() then
            self.settingsPicker.flyoutGeometryLocked = nil
            self:PositionFishingFlyout(self.settingsPicker, self.settingsButton)
        end
        if self.journalPicker and self.journalPicker:IsShown() then
            self.journalPicker.flyoutGeometryLocked = nil
            self:PositionFishingFlyout(self.journalPicker, self.journalButton)
        end
    end
    local function StopMoving(primary)
        primary:StopMovingOrSizing()
        SyncGroupedPosition(primary)
        if primary.groupMove then primary:SetScript("OnUpdate", nil); primary.groupMove = nil end
        primary.moving = nil
        SaveBarPosition()
        SaveToolPosition()
        PositionOpenPickers()
        self:RefreshFishingLayer()
    end
    local function StopToolDrag()
        if toolBar.moving then
            StopMoving(toolBar)
        end
        if toolBar.scaling then
            toolBar.scaling = nil
            toolBar:SetScript("OnUpdate", nil)
            self.db.toolsScale = toolBar:GetScale()
            self:SyncMatchedFishingFlyoutScales()
            SaveToolPosition()
            PositionOpenPickers()
            self:RefreshFishingLayer()
        end
    end
    local function BeginToolDrag()
        if InCombatLockdown and InCombatLockdown() then return end
        if IsShiftKeyDown() then
            BeginMoving(toolBar, bar)
        elseif IsAltKeyDown() then
            BeginMoving(toolBar)
        elseif IsControlKeyDown() then
            toolBar.scaling = true
            toolBar.scaleStartX = GetCursorPosition()
            toolBar.scaleStart = toolBar:GetScale()
            toolBar.scaleCenterX, toolBar.scaleCenterY = CenterOffset(toolBar)
            toolBar:SetScript("OnUpdate", function()
                local x = GetCursorPosition()
                toolBar:SetScale(math.max(0.65, math.min(1.5, toolBar.scaleStart + (x - toolBar.scaleStartX) / 300)))
                self:SyncMatchedFishingFlyoutScales()
                if toolBar.scaleCenterX and toolBar.scaleCenterY then
                    SetCenterOffset(toolBar, toolBar.scaleCenterX, toolBar.scaleCenterY)
                end
            end)
        end
    end
    local function ToolDrag(button)
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnDragStart", BeginToolDrag)
        button:SetScript("OnDragStop", StopToolDrag)
    end

    -- Key and mouse use the same secure cast button, so every input can start
    -- the rapid-press lock before another cast reaches the client.
    self:CreateFishingActionControls(visibilityRoot)
    local cast = CreateFrame("Button", "ForeverFishingStatusButton", bar, "SecureActionButtonTemplate")
    cast:SetSize(438, 82)
    cast:SetPoint("CENTER", bar, "CENTER")
    cast:RegisterForClicks("AnyUp")
    cast:SetAttribute("useOnKeyDown", false)
    cast:SetAttribute("type", "click")
    cast:SetAttribute("clickbutton", self.castActionButton)
    self:StyleFishingBarFrame(cast, true)
    local stripe = cast:CreateTexture(nil, "ARTWORK")
    stripe:SetPoint("TOPLEFT", cast, "TOPLEFT", 0, 0)
    stripe:SetPoint("BOTTOMLEFT", cast, "BOTTOMLEFT", 0, 0)
    stripe:SetWidth(3)
    stripe:SetColorTexture(unpack(ACCENT))
    cast.stripe = stripe
    local icon = cast:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(self.castbarIcon)
    icon:SetSize(64, 64)
    icon:SetPoint("LEFT", cast, "LEFT", 10, 0)
    cast.label = Text(cast, "GameFontNormalLarge", 86, -14, "Forever Fishing")
    cast.label:SetTextColor(1, 0.84, 0.52)
    cast.hint = Text(cast, "GameFontHighlight", 86, STATUS_TEXT_Y, FF:LocalizedText("status.choose-key"))
    cast.hint:SetWidth(245)
    cast.hint:SetHeight(24)
    cast.hint:SetJustifyV("TOP")
    cast.hint:SetJustifyH("LEFT")
    cast.hint:SetTextColor(0.65, 0.75, 0.79)
    cast.statusIcon = cast:CreateTexture(nil, "OVERLAY")
    cast.statusIcon:SetSize(18, 18)
    cast.statusIcon:SetPoint("TOPLEFT", cast, "TOPLEFT", 86, STATUS_TEXT_Y + 1)
    cast.statusIcon:Hide()
    cast.LayoutFishingStatusText = LayoutFishingStatusText
    local bind = CreateFrame("Button", "ForeverFishingBindButton", bar, "SecureHandlerBaseTemplate")
    bind:SetSize(90, 30)
    bind:SetPoint("BOTTOMRIGHT", cast, "BOTTOMRIGHT", -14, 16)
    bind:SetFrameLevel(cast:GetFrameLevel() + 4)
    bind:RegisterForClicks("LeftButtonUp")
    StyleButton(bind, nil)
    bind.surface:SetColorTexture(0.025, 0.09, 0.12, 0.96)
    local bindBorder = CreateFrame("Frame", nil, bind, BackdropTemplateMixin and "BackdropTemplate" or nil)
    bindBorder:SetAllPoints(bind)
    bindBorder:EnableMouse(false)
    if bindBorder.SetBackdrop then
        bindBorder:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
        bindBorder:SetBackdropBorderColor(0.28, 0.70, 0.78, 0.9)
    end
    function bind:SetFishingKeyUnbound(unbound)
        local font=self:GetFontString()
        font:SetTextColor(unpack(unbound and {1,.18,.18} or ACCENT))
        if font.SetFontHeight and self.fishingKeyFontHeight then
            font:SetFontHeight(self.fishingKeyFontHeight)
            local width=font:GetStringWidth()
            local available=self:GetWidth()-14
            if unbound and width>available then font:SetFontHeight(self.fishingKeyFontHeight*(available-1)/width) end
        end
        if not bindBorder.SetBackdropBorderColor then return end
        if unbound then bindBorder:SetBackdropBorderColor(1, 0.18, 0.18, 0.95)
        else bindBorder:SetBackdropBorderColor(0.28, 0.70, 0.78, 0.9) end
    end
    local bindText = bind:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bindText:SetPoint("CENTER")
    bindText:SetTextColor(unpack(ACCENT))
    bind:SetFontString(bindText)
    -- Assigning a FontString to a button must retain all alphabet members.
    if bind.SetNormalFontObject then bind:SetNormalFontObject("GameFontNormalSmall") end
    bindText:SetFontObject("GameFontNormalSmall")
    bindText:SetTextColor(unpack(ACCENT))
    local _,bindingFontHeight=bindText:GetFont()
    bind.fishingKeyFontHeight=bindingFontHeight
    bind:SetText(FF:LocalizedText("binding.unassigned"))
    bind:SetScript("OnClick", function() self:BeginKeyCapture() end)
    bind:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("settings.fishing-key"))
        GameTooltip:AddLine(FF:LocalizedText("bar.cast-input-help"), 1, 1, 1, true)
        local needed,jump=self:GetFishingJumpState()
        if needed and jump then GameTooltip:AddLine(self:LocalizedText("binding.jump-help",self:GetFishingBindingLabel(jump)),.8,.82,.72,true) end
        GameTooltip:Show()
    end)
    bind:SetScript("OnLeave", function() GameTooltip:Hide() end)
    cast.keyText = bind
    self.bindButton = bind
    local close = CreateFrame("Button", nil, bar,
        "UIPanelCloseButtonNoScripts,SecureActionButtonTemplate,SecureHandlerStateTemplate")
    -- Artwork-only close template preserves the inherited secure OnClick.
    self:PlaceFishingBarCloseButton(close, cast)
    close:SetFrameLevel(cast:GetFrameLevel() + 4)
    close:RegisterForClicks("LeftButtonUp")
    close:SetScript("PreClick", function(button, _, down)
        if not down and InCombatLockdown and InCombatLockdown() and self.db.autoRestoreGear then
            self:BeginCombatWeaponRestore(button)
        end
    end)
    close:SetScript("PostClick", function(button, mouseButton, down)
        if down then return end
        if not (InCombatLockdown and InCombatLockdown()) then
            self:ToggleUI()
        elseif mouseButton == "LeftButton" and button:GetAttribute("macrotext1") and SecureCmdOptionParse
            and SecureCmdOptionParse("[channeling] blocked") == "blocked" then
            self:Print(FF:LocalizedText("runtime.close-stop-cast"))
        end
    end)
    self:ConfigureCombatWeaponButton(close, true)
    close:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("bar.close"))
        GameTooltip:Show()
    end)
    close:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.closeButton = close
    self:ConfigureFishingToggleAction(close)
    self:ConfigureFishingCloseAction(close)
    cast:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("bar.title-command"))
        self:AddFishingInformationTooltip()
        GameTooltip:AddLine(FF:LocalizedText("bar.preparation-help"), 1, 1, 1, true)
        GameTooltip:AddLine(FF:LocalizedText("bar.move-both"), 0.8, 0.82, 0.72, true)
        GameTooltip:AddLine(FF:LocalizedText("bar.move-main"), 0.8, 0.82, 0.72, true)
        GameTooltip:AddLine(FF:LocalizedText("bar.resize-main"), 0.8, 0.82, 0.72, true)
        GameTooltip:Show()
    end)
    cast:SetScript("OnLeave", function(button) if GameTooltip:GetOwner()==button then GameTooltip:Hide() end end)
    local function BeginBarDrag()
        if InCombatLockdown and InCombatLockdown() then return end
        if IsShiftKeyDown() then
            BeginMoving(bar, toolBar)
        elseif IsAltKeyDown() then
            BeginMoving(bar)
        elseif IsControlKeyDown() then
            bar.scaling = true
            bar.scaleStartX = GetCursorPosition()
            bar.scaleStart = bar:GetScale()
            bar.scaleCenterX, bar.scaleCenterY = CenterOffset(bar)
            bar:SetScript("OnUpdate", function()
                local x = GetCursorPosition()
                bar:SetScale(math.max(0.65, math.min(1.5, bar.scaleStart + (x - bar.scaleStartX) / 300)))
                if bar.scaleCenterX and bar.scaleCenterY then
                    SetCenterOffset(bar, bar.scaleCenterX, bar.scaleCenterY)
                end
            end)
        end
    end
    local function EndBarDrag()
        if bar.moving then
            StopMoving(bar)
            return
        elseif bar.scaling then
            bar.scaling = nil
            bar:SetScript("OnUpdate", nil)
            self.db.barScale = bar:GetScale()
        else
            return
        end
        SaveBarPosition()
        self:RefreshFishingLayer()
    end
    for _, dragHandle in ipairs({ cast, bind, close }) do
        dragHandle:RegisterForDrag("LeftButton")
        dragHandle:SetScript("OnDragStart", BeginBarDrag)
        dragHandle:SetScript("OnDragStop", EndBarDrag)
    end
    self.castButton = cast
    self:InitializeFishingInformation()

    local gear = CreateFrame("Button", "ForeverFishingGearActionButton", toolBar, "SecureActionButtonTemplate,SecureHandlerStateTemplate")
    gear:SetPoint("TOPLEFT", toolBar, "TOPLEFT", 0, 0)
    gear:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    StyleSmartIcon(gear, self.fishingGearIcon, true)
    self:StyleFishingFlyoutOwner(gear)
    self:ConfigureCombatWeaponButton(gear)
    gear:SetScript("PreClick", function(button, mouseButton, down)
        if not down then self:HandleGearClick(button, mouseButton) end
    end)
    gear:SetScript("OnReceiveDrag", function()
        local kind, id, link = GetCursorInfo()
        if kind == "item" and tonumber(id) and self:AddFishingGearItem(tonumber(id), link) then ClearCursor() end
    end)
    gear:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        if not (self.fishingRodEquipped or self.fishingRodInBags) then
            GameTooltip:SetText(FF:LocalizedText("gear.none-found"))
            GameTooltip:AddLine(FF:LocalizedText("gear.vendor-help"), 1, 0.72, 0.4, true)
            GameTooltip:Show()
            return
        end
        GameTooltip:SetText(FF:LocalizedText("gear.name"))
        GameTooltip:AddLine(FF:LocalizedText("gear.equip-restore"), 1, 1, 1, true)
        GameTooltip:AddLine(FF:LocalizedText("gear.arrow-help"), 0.76, 0.82, 0.8, true)
        GameTooltip:AddLine(FF:LocalizedText("gear.remove-help"), 0.76, 0.82, 0.8, true)
        GameTooltip:Show()
    end)
    gear:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ToolDrag(gear)
    self.gearButton = gear
    self.gearArrow = DropArrow(toolBar, gear, function() self:ShowGearPicker() end, FF:LocalizedText("gear.management"))

    local lure = CreateFrame("Button", "ForeverFishingLureActionButton", toolBar, "SecureActionButtonTemplate")
    lure:SetPoint("LEFT", gear, "RIGHT", iconSpacing, 0)
    -- Match the working Cast button's secure click direction. Some clients
    -- default to actions on mouse-down and silently ignore an up-only click.
    lure:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp")
    lure:SetAttribute("useOnKeyDown", false)
    StyleSmartIcon(lure, "Interface\\Icons\\INV_Misc_Fish_14")
    self:StyleFishingFlyoutOwner(lure)
    lure:SetScript("PreClick", function()
        if self.ValidateSelectedLureSlot then self:ValidateSelectedLureSlot() end
    end)
    lure:SetScript("PostClick", function(_, mouseButton, down)
        if mouseButton == "LeftButton" and not down then
            self.lastLureClick = GetTime()
            self.lastLureTargeting = SpellIsTargeting and SpellIsTargeting() or false
        end
    end)
    lure:SetScript("OnReceiveDrag", function()
        local kind, id = GetCursorInfo()
        if kind == "item" and tonumber(id) then
            self:SetLure(tonumber(id))
            ClearCursor()
        end
    end)
    lure:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(button.selectedName or FF:LocalizedText("lure.name"))
        local hasLures = self.availableLures and self.availableLures[1]
        local selected
        for _, entry in ipairs(self.availableLures or {}) do
            if entry.id == self.db.lure then selected = entry; break end
        end
        if selected then
            local remaining = self:LureSeconds()
            if remaining and remaining > 0 then GameTooltip:AddLine(FF:LocalizedText("lure.rod-seconds",math.ceil(remaining)), 1, 1, 1) end
            GameTooltip:AddLine(FF:LocalizedText("lure.apply-help"), 1, 1, 1, true)
        else
            if not hasLures then
                GameTooltip:AddLine(FF:LocalizedText("lure.vendor-help"), 1, 0.72, 0.4, true)
            else
                GameTooltip:AddLine(FF:LocalizedText("lure.selected-missing"), 1, 0.72, 0.4, true)
            end
        end
        GameTooltip:AddLine(hasLures and FF:LocalizedText("lure.choose-arrow") or FF:LocalizedText("lure.add-arrow"), 0.76, 0.82, 0.8)
        if self.lureMacroError then GameTooltip:AddLine(self.lureMacroError, 1, 0.55, 0.4, true) end
        GameTooltip:Show()
    end)
    lure:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ToolDrag(lure)
    self.lureButton = lure
    self.lureArrow = DropArrow(toolBar, lure, function() self:ShowLurePicker() end, FF:LocalizedText("lure.choose-tooltip"))

    local chef = CreateFrame("Button", nil, toolBar)
    chef:SetPoint("LEFT", lure, "RIGHT", iconSpacing, 0)
    StyleSmartIcon(chef, "Interface\\AddOns\\ForeverFishing\\Media\\Cooking1", true)
    self:StyleFishingFlyoutOwner(chef)
    chef:SetScript("OnClick",function(_,mouse)
        if mouse=="RightButton" then
            if self.masterChefTray and self.masterChefTray:IsShown() then self:CloseFishingQuickTray()
            else self:ShowMasterChefQuickTray(false,true) end
        else self:ShowMasterChefQuickTray() end
    end)
    chef:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("flyout.chef"))
        GameTooltip:AddLine(FF:LocalizedText("chef.quick-help"), 1, 1, 1, true)
        GameTooltip:AddLine(FF:LocalizedText("chef.close-help-legacy"), 0.76, 0.82, 0.8, true)
        GameTooltip:Show()
    end)
    chef:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ToolDrag(chef)
    self.masterChefButton = chef
    chef:RegisterForClicks("LeftButtonUp","RightButtonUp")

    local journal = CreateFrame("Button", nil, toolBar)
    journal:SetPoint("LEFT", chef, "RIGHT", iconSpacing, 0)
    StyleSmartIcon(journal, self.journalIcon, true)
    self:StyleFishingFlyoutOwner(journal)
    journal:SetScript("OnClick", function() self:ToggleFishingJournal() end)
    journal:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("journal.button-title"))
        GameTooltip:AddLine(FF:LocalizedText("journal.toggle-help"), 1, 1, 1, true)
        GameTooltip:AddLine(FF:LocalizedText("journal.button-help"), 0.76, 0.82, 0.8, true)
        GameTooltip:Show()
    end)
    journal:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ToolDrag(journal)
    self.journalButton = journal
    self.journalArrow = DropArrow(toolBar, journal, function() self:ShowJournalPicker() end, FF:LocalizedText("journal.quick"))

    local settings = CreateFrame("Button", nil, toolBar)
    settings:SetPoint("LEFT", journal, "RIGHT", iconSpacing, 0)
    StyleSmartIcon(settings, self.settingsIcon, true)
    self:StyleFishingFlyoutOwner(settings)
    settings:RegisterForClicks("LeftButtonUp","RightButtonUp")
    settings:SetScript("OnClick", function(_,mouse)
        self:CloseFishingFlyouts()
        if self.settingsPanel and self.settingsPanel:IsShown() then self.settingsPanel:Hide()
        else self:ShowSettings() end
    end)
    settings:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("settings.title"))
        GameTooltip:AddLine(FF:LocalizedText("settings.toggle-help"), 1, 1, 1, true)
        GameTooltip:AddLine(FF:LocalizedText("bar.move-both"), 0.76, 0.82, 0.8, true)
        GameTooltip:AddLine(FF:LocalizedText("bar.move-tools"), 0.76, 0.82, 0.8, true)
        GameTooltip:AddLine(FF:LocalizedText("bar.resize-tools"), 0.76, 0.82, 0.8, true)
        GameTooltip:Show()
    end)
    settings:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ToolDrag(settings)
    self.settingsButton = settings
    self.settingsArrow = DropArrow(toolBar, settings, function() self:ShowSettingsPicker() end, FF:LocalizedText("settings.quick"))
    self.utilitiesIcon="Interface\\AddOns\\ForeverFishing\\Media\\ConsumablesToys1"
    local utility=CreateFrame("Button","ForeverFishingUtilityActionButton",toolBar,"SecureActionButtonTemplate")
    StyleSmartIcon(utility,self.utilitiesIcon,true)
    self:StyleFishingFlyoutOwner(utility)
    ToolDrag(utility); self.utilityButton=utility
    self:InitializeFishingUtilityButton(utility)
    self.utilityArrow=DropArrow(toolBar,utility,function() self:ShowUtilityPicker() end,self:LocalizedText("utility.choose"))
    self:InitializeFishingCompactBar()

    -- Share the detached frame stack with Settings so the masked window
    -- cannot intercept mouse input below the shield.
    local capture=CreateFrame("Frame",nil,visibilityRoot)
    capture:SetAllPoints(visibilityRoot)
    capture:SetIgnoreParentAlpha(true)
    capture:SetFrameStrata("TOOLTIP")
    if capture.SetFixedFrameStrata then capture:SetFixedFrameStrata(true) end
    capture:EnableKeyboard(true);capture:EnableMouse(true);capture:EnableMouseWheel(true)
    capture:SetPropagateKeyboardInput(false)
    local shade=capture:CreateTexture(nil,"BACKGROUND");shade:SetAllPoints(capture);shade:SetColorTexture(0,0,0,.30)
    local animation=shade:CreateAnimationGroup();local fade=animation:CreateAnimation("Alpha")
    fade:SetFromAlpha(0);fade:SetToAlpha(1);fade:SetDuration(.15)
    self.captureDimAnimation=animation
    local dialog=CreateFrame("Frame",nil,capture);dialog:SetSize(560,1);dialog:SetPoint("CENTER",capture,"CENTER")
    dialog:SetFrameLevel(capture:GetFrameLevel()+1)
    dialog:EnableMouse(true);self.captureDialog=dialog
    local function Copy(field,size,r,g,b)
        local text=dialog:CreateFontString(nil,"OVERLAY")
        FF:SetDisplayFont(text,"Fonts\\2002.TTF",size,"");text:SetJustifyH("CENTER");text:SetTextColor(r,g,b)
        text:SetShadowColor(0,0,0,.9);text:SetShadowOffset(1,-1);self[field]=text
    end
    Copy("captureTitle",20,1,.80,.39);Copy("captureInstruction",22,.94,.95,.95)
    Copy("captureScope",16,1,.84,.2);Copy("captureDetail",16,1,.80,.39);Copy("captureEscape",14,.80,.84,.84)
    Copy("captureGamepadQuestion",22,1,.80,.39)
    self:SetDisplayFont(self.captureGamepadQuestion,"Fonts\\FRIZQT__.TTF",22,"OUTLINE")
    self.captureGamepadQuestion:Hide()
    local function CaptureButton(label,width,click,height)
        height=height or 36
        local button=self.CreateFishingBindingDialogButton
            and self:CreateFishingBindingDialogButton(dialog,label,width,height,click)
        if not button then
            button=PlainButton(dialog,label,width,height,click)
            OrnateBorder(button,1,18)
        end
        button:SetFrameLevel(dialog:GetFrameLevel()+1)
        return button
    end
    self.captureConfirm=CaptureButton(self:LocalizedText("binding.assign"),220,function()
        if self.captureInputReady and self.captureCanConfirm then self:FinishKeyCapture(self.captureCandidate,false,self.captureConflictAction) end
    end)
    self.captureCancel=CaptureButton(self:LocalizedText("binding.cancel"),160,function() self:FinishKeyCapture() end)
    self.captureNormalConfirm,self.captureNormalCancel=self.captureConfirm,self.captureCancel
    -- Dedicated presentation buttons retain the exact callbacks while leaving
    -- ordinary/global binding picker dimensions and padding unchanged.
    self.captureGamepadConfirm=CaptureButton("",220,self.captureConfirm:GetScript("OnClick"),46)
    self.captureGamepadCancel=CaptureButton("",220,self.captureCancel:GetScript("OnClick"),46)
    for _,button in ipairs({self.captureGamepadConfirm,self.captureGamepadCancel}) do
        local label=button:GetFontString()
        self:SetDisplayFont(label,"Fonts\\2002.TTF",20,"")
        label:ClearAllPoints();label:SetPoint("CENTER",button,"CENTER",0,0);label:SetSize(192,44)
        label:SetJustifyH("CENTER");label:SetJustifyV("MIDDLE");label:SetWordWrap(true)
        button:Hide()
    end
    self.captureConfirm:Hide();self.captureCancel:Hide()
    local function Modified(key)
        if IsShiftKeyDown() then key="SHIFT-"..key end
        if IsControlKeyDown() then key="CTRL-"..key end
        if IsAltKeyDown() then key="ALT-"..key end
        return key
    end
    local function Modifier(key)
        return key=="LSHIFT" or key=="RSHIFT" or key=="LCTRL" or key=="RCTRL"
            or key=="LALT" or key=="RALT" or key=="LMETA" or key=="RMETA" or key=="UNKNOWN"
    end
    capture:SetScript("OnKeyDown",function(_,key)
        if not self.captureInputReady or Modifier(key) then return end
        if self.captureGamepadDefaults and key~="ESCAPE" then return end
        if self.captureGamepadMode and key~="ESCAPE" and not (key=="ENTER" and self.captureCanConfirm) then return end
        self.captureRightAt=nil
        self.capturePressedKey={base=key,key=Modified(key),cancel=key=="ESCAPE",confirm=key=="ENTER" and self.captureCanConfirm}
    end)
    capture:SetScript("OnKeyUp",function(_,key)
        local pressed=self.capturePressedKey
        if not self.captureInputReady or not pressed or pressed.base~=key then return end
        self.capturePressedKey=nil
        if pressed.cancel then self:FinishKeyCapture()
        elseif pressed.confirm then self:FinishKeyCapture(self.captureCandidate,false,self.captureConflictAction)
        else self:ReviewFishingBinding(pressed.key) end
    end)
    -- Native releases let the modal recognise a pair regardless of which
    -- frame WoW delivers OnMouseUp to. The shield still owns mouse blocking.
    capture:SetScript("OnEvent",function(frame,_,button)
        if not self.captureInputReady or not frame:IsShown() or self.captureGamepadMode or self.keyCaptureAction~="fishing" then return end
        if button~="RightButton" or IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() then
            self.captureRightAt=nil
            return
        end
        local now=GetTime();local previous=self.captureRightAt;self.captureRightAt=now
        if previous and now-previous<=.4 then self:ReviewFishingBinding(self.doubleRightClickKey) end
    end)
    local function Mouse(_,button)
        if not self.captureInputReady or self.captureGamepadMode or button=="RightButton" then return end
        self.captureRightAt=nil
        local number=button=="MiddleButton" and 3 or tonumber(button and button:match("^Button(%d+)$"))
        if number and number>=3 then self:ReviewFishingBinding(Modified("BUTTON"..number)) end
    end
    local function Wheel(_,delta)
        self.captureRightAt=nil
        if self.captureInputReady and not self.captureGamepadMode and delta~=0 then self:ReviewFishingBinding(Modified(delta>0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN")) end
    end
    capture:SetScript("OnMouseUp",Mouse);dialog:SetScript("OnMouseUp",Mouse)
    capture:SetScript("OnMouseWheel",Wheel);dialog:EnableMouseWheel(true);dialog:SetScript("OnMouseWheel",Wheel)
    -- Gamepad is captured only by this transient shield. Gameplay continues
    -- through native override bindings, never through these raw callbacks.
    if type(capture.EnableGamePadButton)=="function" then
        local modifiers={PADLTRIGGER=true,PADRTRIGGER=true,PADLSHOULDER=true,PADRSHOULDER=true}
        local function ControllerButtonHeld(button)
            if self.captureGamepadModifiers[button] then return true end
            if type(IsKeyDown)~="function" then return false end
            local ok,down=pcall(IsKeyDown,button)
            return ok and not (issecretvalue and issecretvalue(down)) and down==true
        end
        local function PadDown(_,key)
            if not self.captureInputReady or not self.captureGamepadMode then return end
            if (issecretvalue and issecretvalue(key)) or type(key)~="string" then return end
            if modifiers[key] then
                self.captureGamepadModifiers[key]=true
                self.captureShoulderTap=nil
                if not self.captureGamepadDefaults and (key=="PADLSHOULDER" or key=="PADRSHOULDER") then
                    local alone=true
                    for button in pairs(modifiers) do
                        if button~=key and ControllerButtonHeld(button) then alone=false;break end
                    end
                    if alone and not self.capturePressedKey then self.captureShoulderTap=key end
                end
                return
            end
            self.captureShoulderTap=nil
            local ok,native=true,false
            if InputUtil and type(InputUtil.IsGamepadUIEnabled)=="function" then
                ok,native=pcall(InputUtil.IsGamepadUIEnabled)
            end
            local invalid=not ok or (issecretvalue and issecretvalue(native)) or type(native)~="boolean"
            native=not invalid and native==true
            local flags={ALT=IsAltKeyDown(),CTRL=IsControlKeyDown(),SHIFT=IsShiftKeyDown()}
            local allowed,chord={},""
            local left=ControllerButtonHeld("PADLTRIGGER")
            local right=ControllerButtonHeld("PADRTRIGGER")
            local triggerChord=not self.captureGamepadDefaults and self.keyCaptureAction=="fishing" and (left or right)
            for _,modifier in ipairs({"ALT","CTRL","SHIFT"}) do
                local button=self:GetFishingGamepadModifierButton(modifier)
                if button then allowed[button]=true end
                local held=button and ControllerButtonHeld(button)
                local down=flags[modifier]
                if issecretvalue and issecretvalue(down) then invalid=true;down=false end
                -- Native controller dispatch uses the physical chord. A keyboard
                -- modifier alone cannot produce that controller shortcut.
                if triggerChord then
                    if down and not (button=="PADLTRIGGER" and left or button=="PADRTRIGGER" and right) then invalid=true end
                else
                    if native and down and not held then invalid=true end
                    if held or (not native and down) then chord=chord..modifier.."-" end
                end
            end
            if triggerChord then
                if ControllerButtonHeld("PADLSHOULDER") or ControllerButtonHeld("PADRSHOULDER") then invalid=true end
                chord=(left and "PADLTRIGGER-" or "")..(right and "PADRTRIGGER-" or "")
            else
                for button in pairs(modifiers) do
                    if not allowed[button] and (self.captureGamepadModifiers[button] or (native and ControllerButtonHeld(button))) then
                        invalid=true;break
                    end
                end
            end
            local useCircleToCancel=self.captureGamepadDefaults or self.captureCanConfirm or self.gamepadModePending
            local cancel=not invalid and chord=="" and (key=="PAD2" and useCircleToCancel
                or key=="PADBACK" and not self.captureGamepadDefaults)
            self.capturePressedKey={base=key,key=chord..key,gamepad=true,cancel=cancel,confirm=not invalid and chord=="" and key=="PAD1" and self.captureCanConfirm,modified=invalid}
            if self.captureGamepadDefaults and not (self.capturePressedKey.confirm or self.capturePressedKey.cancel) then self.capturePressedKey=nil end
        end
        local function PadUp(_,key)
            if (issecretvalue and issecretvalue(key)) or type(key)~="string" then return end
            if self.captureGamepadModifiers then self.captureGamepadModifiers[key]=nil end
            if self.captureShoulderTap==key then
                self.captureShoulderTap=nil
                if self.captureInputReady then self:ReviewFishingBinding(key) end
                return
            end
            local pressed=self.capturePressedKey
            if not self.captureInputReady or not pressed or not pressed.gamepad or pressed.base~=key then return end
            self.capturePressedKey=nil
            if pressed.cancel then self:FinishKeyCapture()
            elseif pressed.confirm and not pressed.modified then self:FinishKeyCapture(self.captureCandidate,false,self.captureConflictAction)
            elseif pressed.modified then self.captureDetail:SetText(self:LocalizedText("gamepad.release-modifiers"));self:LayoutFishingBindingCapture()
            else self:ReviewFishingBinding(pressed.key) end
        end
        local ok=pcall(capture.SetScript,capture,"OnGamePadButtonDown",PadDown)
        ok=pcall(capture.SetScript,capture,"OnGamePadButtonUp",PadUp) and ok
        self.gamepadCaptureAvailable=ok and pcall(capture.EnableGamePadButton,capture,true) or false
    end
    capture:SetScript("OnHide",function(frame)
        frame:UnregisterEvent("GLOBAL_MOUSE_UP")
        if not self.captureChanging then self:InterruptKeyCapture() end
    end)
    capture:Hide();self.capture=capture

    self:UpdateUI()
end

function FF:ToggleUI()
    if self.dataResetPendingReload then return self:Print(self:LocalizedText("reset.reload-needed")) end
    if not self.bar or self.fishingStartupFailed then return self:ReportFishingStartupFailure() end
    if InCombatLockdown and InCombatLockdown() then
        self:Print(self.bar:IsShown() and FF:LocalizedText("runtime.close-combat")
            or FF:LocalizedText("runtime.open-combat"))
        return
    end
    if self.bar:IsShown() then
        self.gearOpenEquipPending = nil
        self.bar:Hide()
        if self.db.autoRestoreGear and not self.pendingGearRestore then
            -- A manually equipped pole can reopen the bar without going
            -- through the addon's gear swap. Recover its normal weapons first.
            if not self.db.gearSwapActive then self:RememberWornFishingGear() end
            if self.db.gearSwapActive or self.combatWeaponRestore then
                -- A queued fishing equip must not run after the restore begins.
                self:CancelGearOperation()
                self:RestoreRememberedGear()
            end
        end
    else
        -- PLAYER_LOGIN can precede readable bags/item data. Explicit opening
        -- refreshes once before the first native equip, never via idle polling.
        local scan = self.ScanFishingInventory and self:ScanFishingInventory()
        self.bar:Show()
        if self.db.autoEquipGear then self:EquipFishingGearOnOpen(scan) end
    end
end

function FF:SyncCastAction()
    if InCombatLockdown and InCombatLockdown() then return end
    local button = self:GetFishingCastButton()
    if not button then return end
    -- Discard the temporary macro from a previous physical cast click.
    if button:GetAttribute("macrotext") ~= nil then button:SetAttribute("macrotext", nil) end
    local channelReady = not self.active
    if self.db.cameraAssist then
        channelReady = self:CameraRecastReady() or (not self.cameraAssistNeeded
            and (not self.active or self.recastReady or self.recastWindow))
    end
    local ready = channelReady and self:IsFishingSessionOpen() and not self.journalInputFocus
        and not self:FishingKeyReelLootPending()
        and (not self.FishingGamepadInputAvailable or self:FishingGamepadInputAvailable())
        and not (self.capture and self.capture:IsShown()) and not self:CastInputLocked()
    local action, lureMacro = self:NextFishingAction()
    self.castAction = ready and action or nil
    local desired = ready and (action == "lure" and lureMacro or action == "cast" and self.castMacroIndex) and "macro" or nil
    local macro = action == "lure" and lureMacro or self.castMacroIndex
    if button:GetAttribute("type") == desired and button:GetAttribute("macro") == macro then return end
    button:SetAttribute("type", desired)
    button:SetAttribute("macro", macro)
end

function FF:UpdateRangeNotice()
    if not self.rangeNotice then return end
    local show
    if self.db.cameraAssist and self.cameraAssistNeeded then
        local exhausted = self.cameraCast and self.cameraCast.scanExhausted
        show = exhausted and not self.cameraMarkerDrag and not self:CameraBobberLocated()
        if show then
            local npc = self.bobberStatusWarning and self.bobberStatusWarning.clearNPCTarget
            self.rangeNoticeText:SetText(FF:LocalizedText(npc and "status.clear-npc-target" or "status.bobber-not-found-adjust"))
        end
    else
        self.rangeNoticeText:SetText(FF:LocalizedText("status.bobber-not-visible"))
        show = self.db.cameraAssist and self.recastReady
    end
    show = show and self.active and self.bar and self.bar:IsShown()
        and not (self.fishingRodNotice and self.fishingRodNotice:IsShown()) or false
    if self.rangeNotice:IsShown() ~= show then self.rangeNotice:SetShown(show) end
end

local QUICK_TRAY_VISIBLE_ROWS = 3
local QUICK_TRAY_INSET = 5

function FF:ApplyIconBarSpacing()
    if not (self.toolBar and self.gearButton and self.settingsButton) then return end
    if InCombatLockdown and InCombatLockdown() then
        self.iconBarSpacingPending = true
        return
    end
    self.iconBarSpacingPending = nil
    self:ApplyFishingBarPresentation()
    for _, entry in ipairs({ { self.gearPicker, self.gearButton },
        { self.lurePicker, self.lureButton }, {self.utilityPicker,self.utilityButton}, {self.settingsPicker,self.settingsButton},
        {self.journalPicker,self.journalButton}, { self.masterChefTray, self.gearButton } }) do
        if entry[1] and entry[1]:IsShown() then entry[1].flyoutGeometryLocked = nil; self:PositionFishingFlyout(entry[1], entry[2]) end
    end
end

function FF:SetIconBarSpacing(value)
    self.db.iconBarSpacing = LayoutNumber(value, { 2, 20 }, DEFAULT_ICON_SPACING)
    self:ApplyIconBarSpacing()

end

local PREPARATION_NOTICE_Y = -94

local function CreateMiniStatusBanner(parent, persistent)
    local banner = CreateFrame(persistent and "Button" or "Frame", nil, parent)
    banner:SetSize(320, 38)
    banner:SetPoint("TOP", parent, "TOP", 0, PREPARATION_NOTICE_Y)
    banner:SetFrameStrata("DIALOG")
    banner:SetFrameLevel(100)
    banner:EnableMouse(persistent == true)

    -- The cap image has a real alpha-masked point. Its straight edge has the
    -- same pixels as the centre image; the three textures touch without any
    -- translucent geometry beneath another piece during the parent fade.
    local media = "Interface\\AddOns\\ForeverFishing\\Media\\MiniBanner"
    banner.leftCap = banner:CreateTexture(nil, "BACKGROUND")
    banner.leftCap:SetSize(16, 38)
    banner.leftCap:SetPoint("TOPLEFT", banner, "TOPLEFT")
    banner.leftCap:SetTexture(media .. "Cap")
    banner.leftCap:SetTexCoord(0, 0.5, 0, 38 / 64)
    banner.center = banner:CreateTexture(nil, "BACKGROUND")
    banner.center:SetPoint("TOPLEFT", banner, "TOPLEFT", 16, 0)
    banner.center:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", -16, 0)
    banner.center:SetTexture(media .. "Center")
    banner.center:SetTexCoord(0, 1, 0, 38 / 64)
    banner.rightCap = banner:CreateTexture(nil, "BACKGROUND")
    banner.rightCap:SetSize(16, 38)
    banner.rightCap:SetPoint("TOPRIGHT", banner, "TOPRIGHT")
    banner.rightCap:SetTexture(media .. "Cap")
    banner.rightCap:SetTexCoord(0.5, 0, 0, 38 / 64)

    banner.text = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    banner.text:SetPoint("CENTER", banner, "CENTER", 0, 0)
    banner.text:SetJustifyH("CENTER")
    if banner.text.SetWordWrap then banner.text:SetWordWrap(true) end
    local font = banner.text:GetFont()
    if font then FF:SetDisplayFont(banner.text, font, 18, "OUTLINE") end
    banner.text:SetTextColor(0.96, 0.78, 0.42)
    banner.text:SetShadowColor(0, 0, 0, 0.85)
    banner.text:SetShadowOffset(1, -1)
    function banner:SetMessage(message)
        self.text:SetWidth(1000)
        self.text:SetText(message)
        local measured = self.text:GetStringWidth()
        if not measured or measured <= 0 then measured = #message * 9 end
        local available = math.max(220, parent:GetWidth() - 80)
        local width = math.min(available, math.max(220, math.ceil(measured + 72)))
        self:SetWidth(width)
        self.text:SetWidth(width - 64)
        -- Reuse the existing banner; wrap long translated notices at the
        -- available width without shrinking text or changing notice ownership.
        if self.text.SetHeight then self.text:SetHeight(0) end
        local textHeight=self.text.GetStringHeight and self.text:GetStringHeight() or 18
        local height=math.max(38,math.ceil(textHeight)+16)
        self:SetHeight(height)
        self.leftCap:SetHeight(height); self.rightCap:SetHeight(height)
        if self.text.SetHeight then self.text:SetHeight(height-16) end
    end
    if not persistent then
        banner:SetScript("OnUpdate", function(frame, elapsed)
            frame.age = (frame.age or 0) + elapsed
            local duration = frame.duration or 1.8
            local fade = duration * (0.55 / 1.8)
            if frame.age >= duration then
                frame:Hide()
            elseif frame.age > duration - fade then
                frame:SetAlpha((duration - frame.age) / fade)
            end
        end)
    end
    banner:Hide()
    return banner
end

local function PositionPreparationStatusNotice(self)
    local notice = self.masterChefPreparationNotice
    if not notice then return end
    local bags = self.fishingBagsFullNotice
    local offset = bags and bags:IsShown() and bags:GetHeight() + 6 or 0
    if (notice.bagsNoticeOffset or 0) == offset then return end
    notice.bagsNoticeOffset = offset
    notice:ClearAllPoints()
    notice:SetPoint("TOP", UIParent, "TOP", 0, PREPARATION_NOTICE_Y - offset)
end

function FF:RefreshFishingBagSpace(suspended)
    if not self.visibilityRoot or not self.ReadFishingBagsFull then return end
    if suspended ~= nil then self.fishingBagSpaceSuspended = suspended end
    local open = self.bar and self.bar:IsShown() and not self.dataResetPendingReload
    local wasFull = self.fishingBagsFull == true
    if self.fishingBagSpaceSuspended then
        self.fishingBagsFull = nil
    elseif open or self.fishingBagsFullNoticeState then
        local reading = self:ReadFishingBagsFull()
        if reading ~= nil then self.fishingBagsFull = reading end
        if reading == false then self.fishingBagsFullNoticeState = nil end
    end
    local full = self.fishingBagsFull == true
    if open and not self.active and full ~= wasFull then self:UpdateIdleFishingStatus() end

    local notice = self.fishingBagsFullNotice
    if not (open and full and self.fishingBagsFullNoticeState ~= "dismissed") then
        if notice and notice:IsShown() then notice:Hide() end
        return
    end
    if not notice then
        notice = CreateMiniStatusBanner(self.visibilityRoot, true)
        self.fishingBagsFullNotice = notice
        notice:SetMessage(self:LocalizedText("status.bags-full"))
        notice:RegisterForClicks("LeftButtonUp")
        notice:SetScript("OnClick", function(button, key)
            if key ~= "LeftButton" then return end
            self.fishingBagsFullNoticeState = "dismissed"
            button:Hide()
        end)
        notice:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
            GameTooltip:SetText(self:LocalizedText("status.bags-full-help"), nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        local function HideTooltip(button)
            if GameTooltip:GetOwner() == button then GameTooltip:Hide() end
        end
        notice:SetScript("OnLeave", HideTooltip)
        notice:SetScript("OnHide", function(button)
            HideTooltip(button)
            if self.StopFishingSound then self:StopFishingSound("bagsFull", true) end
            PositionPreparationStatusNotice(self)
        end)
    end
    if not notice:IsShown() then
        local firstShow = not self.fishingBagsFullNoticeState
        self.fishingBagsFullNoticeState = "shown"
        notice:Show()
        PositionPreparationStatusNotice(self)
        self:RefreshFishingLayer()
        if self.SyncFishingBagsFullAlert then self:SyncFishingBagsFullAlert(firstShow) end
    end
end

function FF:ShowPreparationStatusNotice(message, kind)
    local notice = self.masterChefPreparationNotice
    if not notice then
        notice = CreateMiniStatusBanner(UIParent)
        self.masterChefPreparationNotice = notice
    end
    notice.kind = kind
    notice.duration = (kind == "gear" or kind == "gearFailure" or kind == "gearRestore") and 3.6 or 1.8
    notice:SetMessage(message)
    notice.age = 0
    notice:SetAlpha(1)
    PositionPreparationStatusNotice(self)
    notice:Show()
    return true
end

function FF:ShowMasterChefPreparationNotice(profession, action, preparing)
    if not profession or (action ~= "cook" and action ~= "craft") then return end
    local key="chef.notice."..(preparing and "preparing-" or "prepared-")..action
    return self:ShowPreparationStatusNotice(self:LocalizedText(key,profession), "chef")
end

function FF:ShowGearSwapFailure(message)
    -- Close-time failures use the same preparation banner, independent of the
    -- fishing bar's gear-status owner. Never suppress native errors or voices.
    if self.ShowPreparationStatusNotice then
        self:ShowPreparationStatusNotice(message, "gearFailure")
    end
end

function FF:ShowFishingGearStatus(state)
    if not self.bar or not self.bar:IsShown() then return false end
    if self.fishingGearNoticeState == state then return true end
    local messages = {
        fallback = FF:LocalizedText("gear.status-fallback"),
        noRod = FF:LocalizedText("gear.status-no-rod"),
        manual = FF:LocalizedText("gear.status-manual"),
        failed = FF:LocalizedText("gear.status-failed"),
    }
    local message = messages[state]
    if not message then return false end
    -- One shared banner replaces conflicting messages; never claim a failed
    -- equip is a successful fallback. Repeated native errors do not spam it.
    self:HideFishingRodWarning()
    self.fishingGearNoticeState = state
    return self:ShowPreparationStatusNotice(message, "gear")
end

local function QuickTrayIcon(itemID)
    return C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID)
        or GetItemIcon and GetItemIcon(itemID)
        or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function FF:SetMasterChefQuickStatus(message)
    if not (self.masterChefTray and self.masterChefTray:IsShown()) then return end
    self.masterChefQuickStatus = message
    if self.ApplyMasterChefQuickStatus then self:ApplyMasterChefQuickStatus() end
    if self.UpdateFishingInformation then self:UpdateFishingInformation() end
end

function FF:ApplyMasterChefQuickStatus()
    if not (self.masterChefQuickStatus and self.masterChefTray
        and self.masterChefTray:IsShown() and self.castButton and self.castButton.hint) then return end
    PaintCastStatus(self, self.castButton.castStatusStyle, self.castButton.castStatusHint)
end

function FF:CreateFishingQuickTray(name, onHide, kind)
    -- Shared grid sizes use UI units on the existing visibility root.
    local tray = CreateFrame("Frame", name,
        self.visibilityRoot or self.toolBar:GetParent() or self.toolBar,
        "SecureHandlerStateTemplate")
    tray:SetFrameStrata(HUD_STRATA)
    tray:SetFrameLevel(self.toolBar:GetFrameLevel() + 20)
    tray:SetClampedToScreen(true)
    tray:EnableMouse(true)
    tray:SetPoint("TOPLEFT", self.toolBar, "TOPLEFT", -QUICK_TRAY_INSET, -52)
    local scroll = CreateFrame("ScrollFrame", nil, tray)
    scroll:SetPoint("TOPLEFT", tray, "TOPLEFT", QUICK_TRAY_INSET, -QUICK_TRAY_INSET)
    scroll:EnableMouseWheel(true)
    local content = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnMouseWheel", function(_, delta) self:ScrollFishingQuickTray(tray, delta) end)
    tray.scroll, tray.content, tray.buttons = scroll, content, {}
    -- Overflow keeps every item in the scroll child and docks the provider's
    -- final fixed action outside it. Visible arrows make overflow discoverable.
    for _, direction in ipairs({ 1, -1 }) do
        local button = CreateFrame("Button", nil, tray)
        button:SetSize(16, 16)
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        button.flyoutScrollIcon = icon
        icon:SetTexture("Interface\\Buttons\\UI-ScrollBar-Scroll"
            .. (direction == 1 and "Up" or "Down") .. "Button-Up")
        button:SetScript("OnClick", function() self:ScrollFishingQuickTray(tray, direction) end)
        button:SetScript("OnEnter", function(row)
            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetText(FF:LocalizedText("flyout.scroll-help"), 1, 0.82, 0.45)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:Hide()
        if direction == 1 then tray.scrollUp = button else tray.scrollDown = button end
    end
    tray.flyoutKind = kind
    local layout = self:GetFishingFlyoutLayout(kind)
    tray:SetScale(layout.scale)
    tray.flyoutIconSize = layout.size
    tray.flyoutStep = layout.size + layout.spacing
    tray.flyoutColumns = layout.columns
    tray.flyoutContentInset = QUICK_TRAY_INSET
    function tray:SizeForRows(count, maxVisible)
        self.rowCount = count
        FF:LayoutFishingQuickTray(self, count, maxVisible)
    end
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = name end
    tray:Hide()
    if onHide then tray:SetScript("OnHide", onHide) end
    -- Every tray contains protected controls. Let its secure root close itself
    -- at combat entry; ordinary toggle handlers cannot hide it under lockdown.
    local combatOwner = kind=="utility" and "utilityPicker" or kind == "chef" and "masterChefTray"
        or (kind == "gear" or kind == "lure" or kind == "settings" or kind == "journal") and (kind .. "Picker")
    if combatOwner then self:RegisterCombatCloseWindow(combatOwner, tray) end
    return tray
end

function FF:GetFishingQuickTrayScroll(tray)
    return tray.flyoutTransposed and tray.scroll:GetHorizontalScroll() or tray.scroll:GetVerticalScroll()
end
function FF:SetFishingQuickTrayScroll(tray,value)
    if tray.flyoutTransposed then tray.scroll:SetHorizontalScroll(value)
    else tray.scroll:SetVerticalScroll(value) end
end
function FF:GetFishingQuickTrayScrollLimit(tray)
    return math.max(0,tray.flyoutTransposed and (tray.content:GetWidth()-tray.scroll:GetWidth())
        or (tray.content:GetHeight()-tray.scroll:GetHeight()))
end
function FF:UpdateFishingQuickTrayScrollControls(tray)
    local limit = self:GetFishingQuickTrayScrollLimit(tray)
    if not tray.scrollUp then return end
    local overflow = limit > 0
    tray.scrollUp:SetShown(overflow); tray.scrollDown:SetShown(overflow)
    local value = self:GetFishingQuickTrayScroll(tray)
    tray.scrollUp:SetAlpha(value > 0 and 1 or 0.3)
    tray.scrollDown:SetAlpha(value < limit and 1 or 0.3)
end

function FF:ScrollFishingQuickTray(tray, delta)
    if InCombatLockdown and InCombatLockdown() then return end
    local limit = self:GetFishingQuickTrayScrollLimit(tray)
    self:SetFishingQuickTrayScroll(tray,math.max(0,math.min(limit,
        self:GetFishingQuickTrayScroll(tray) - delta * tray.flyoutStep)))
    self:UpdateFishingQuickTrayScrollControls(tray)
end

function FF:LayoutFishingQuickTray(tray, count, maxVisible)
    local vertical=self:GetFishingBarOrientation()=="vertical"
    if tray.flyoutTransposed~=vertical then
        tray.flyoutAxisScroll=self:GetFishingQuickTrayScroll(tray)
        if vertical then tray.scroll:SetVerticalScroll(0) else tray.scroll:SetHorizontalScroll(0) end
        tray.flyoutTransposed=vertical
    end
    local span=UIParent and (vertical and UIParent:GetHeight() or UIParent:GetWidth())
    local rules=self:GetFishingFlyoutLayout(tray.flyoutKind)
    if span and span>0 then span=span/rules.scale else span=nil end
    if tray.flyoutAvailableWidth then span=math.min(span or tray.flyoutAvailableWidth,tray.flyoutAvailableWidth) end
    local layout=self:ResolveFishingFlyoutGeometry(tray.flyoutKind,count,maxVisible,span,tray.flyoutMaxColumns)
    tray.flyoutIconSize,tray.flyoutStep,tray.flyoutColumns=layout.size,layout.size+layout.spacing,layout.columns
    local step,columns=tray.flyoutStep,tray.flyoutColumns
    local along=math.max(1,(math.min(count,columns)-1)*(tray.flyoutAlongStep or step)+layout.size)
    local rows=math.ceil(count/columns)
    local visibleRows=math.min(rows,math.max(1,maxVisible or rows))
    local pinned=tray.flyoutFixedButton and rows>visibleRows
    if pinned then visibleRows=math.max(2,visibleRows) end
    local contentRows=math.ceil((count-(pinned and 1 or 0))/columns)
    local visibleContentRows=visibleRows-(pinned and 1 or 0)
    local visibleDepth=math.max(1,(visibleContentRows-1)*step+layout.size)
    local contentDepth=math.max(1,(contentRows-1)*step+layout.size)
    local depth=(visibleRows-1)*step+layout.size+2*QUICK_TRAY_INSET
    local breadth=along+2*QUICK_TRAY_INSET+(contentRows>visibleContentRows and 18 or 0)
    tray.flyoutPinnedAction=pinned and true or false
    tray.flyoutContentRows,tray.flyoutVisibleRows=contentRows,visibleRows
    tray:SetSize(vertical and depth or breadth,vertical and breadth or depth)
    tray.scroll:SetSize(vertical and visibleDepth or along,vertical and along or visibleDepth)
    tray.content:SetSize(vertical and contentDepth or along,vertical and along or contentDepth)
    self:SetFishingQuickTrayScroll(tray,math.min(self:GetFishingQuickTrayScroll(tray),self:GetFishingQuickTrayScrollLimit(tray)))
    self:UpdateFishingQuickTrayScrollControls(tray)
end

local FISHING_ACTION_BARS = {
    "MainMenuBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarLeft", "MultiBarRight",
    "MultiBar5", "MultiBar6", "MultiBar7", "MultiBar8", "ExtraActionBarFrame",
    "ExtraActionButton1", "OverrideActionBar", "BonusActionBarFrame", "VehicleMenuBar",
    "PossessBarFrame", "PetActionBarFrame",
    "PetActionBar", "StanceBarFrame", "ShapeshiftBarFrame",
}
local FISHING_ACTION_BUTTONS = {
    { "ActionButton", 12 }, { "BonusActionButton", 12 },
    { "MultiBarBottomLeftButton", 12 }, { "MultiBarBottomRightButton", 12 },
    { "MultiBarLeftButton", 12 }, { "MultiBarRightButton", 12 },
    { "MultiBar5Button", 12 }, { "MultiBar6Button", 12 },
    { "MultiBar7Button", 12 }, { "MultiBar8Button", 12 },
    { "PetActionButton", 10 }, { "ShapeshiftButton", 10 },
    { "StanceButton", 10 }, { "PossessButton", 2 },
    { "ExtraActionButton", 1 }, { "OverrideActionBarButton", 12 },
}

local function FishingActionControlOverlaps(frame, left, right, bottom, top)
    if not frame or not ((frame.IsVisible and frame:IsVisible())
        or (not frame.IsVisible and frame.IsShown and frame:IsShown())) then return false end
    local alpha = frame.GetEffectiveAlpha and frame:GetEffectiveAlpha()
    local scale = frame.GetEffectiveScale and frame:GetEffectiveScale()
    local frameLeft = frame.GetLeft and frame:GetLeft()
    local frameRight = frame.GetRight and frame:GetRight()
    local frameBottom = frame.GetBottom and frame:GetBottom()
    local frameTop = frame.GetTop and frame:GetTop()
    return (not alpha or alpha > 0) and scale and scale > 0
        and frameLeft and frameRight and frameBottom and frameTop
        and left < frameRight * scale and right > frameLeft * scale
        and bottom < frameTop * scale and top > frameBottom * scale
end

local function FlyoutOverlapsActionBar(left, right, bottom, top)
    if not (UIParent and UIParent.IsShown and UIParent:IsShown()) then return false end
    for _, name in ipairs(FISHING_ACTION_BARS) do
        if FishingActionControlOverlaps(_G[name], left, right, bottom, top) then return true end
    end
    -- Some clients draw their bars through the individual buttons while the
    -- decorative/container frame is hidden or has no usable bounds.
    for _, group in ipairs(FISHING_ACTION_BUTTONS) do
        for index = 1, group[2] do
            if FishingActionControlOverlaps(_G[group[1] .. index], left, right, bottom, top) then
                return true
            end
        end
    end
    return false
end

local function PlaceFishingFlyoutIcons(panel, reversed)
    if not (panel.flyoutStep and panel.flyoutColumns and panel.content) then return end
    local vertical=panel.flyoutTransposed
    local count=panel.rowCount or 0
    local rows=panel.flyoutContentRows or math.ceil(count/panel.flyoutColumns)
    local inset=panel.flyoutContentInset or 0
    local depthInset=inset+(reversed and panel.flyoutPinnedAction and panel.flyoutStep or 0)
    panel.scroll:ClearAllPoints()
    panel.scroll:SetPoint("TOPLEFT",panel,"TOPLEFT",vertical and depthInset or inset,-(vertical and inset or depthInset))
    panel.scrollUp:ClearAllPoints(); panel.scrollDown:ClearAllPoints()
    if vertical then
        panel.scrollUp:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",depthInset,1)
        panel.scrollDown:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",depthInset+panel.scroll:GetWidth()-16,1)
    else
        panel.scrollUp:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-1,-depthInset)
        panel.scrollDown:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-1,-depthInset-panel.scroll:GetHeight()+16)
    end
    for _,button in ipairs({panel.scrollUp,panel.scrollDown}) do
        if button.flyoutScrollIcon and button.flyoutScrollIcon.SetRotation then
            button.flyoutScrollIcon:SetRotation(vertical and math.pi/2 or 0)
        end
    end
    local pickerRows=type(panel.rows)=="table" and panel.rows or nil
    local actionButtons=type(panel.buttons)=="table" and panel.buttons or nil
    for index=1,count do
        local button=pickerRows and pickerRows[index]
        if not button and actionButtons then button=index==count and panel.plusButton or actionButtons[index] end
        if button then
            local along=((index-1)%panel.flyoutColumns)*(panel.flyoutAlongStep or panel.flyoutStep)
            local row=math.floor((index-1)/panel.flyoutColumns)
            button.flyoutScrollOwner=panel; button:ClearAllPoints()
            local parent=panel.content
            if panel.flyoutPinnedAction and button==panel.flyoutFixedButton then
                parent=panel
                along=inset+(panel.flyoutColumns-1)*panel.flyoutStep
                row=inset+(reversed and 0 or panel.flyoutVisibleRows-1)*panel.flyoutStep
            else row=(reversed and rows-1-row or row)*panel.flyoutStep end
            if button:GetParent()~=parent then button:SetParent(parent) end
            button:SetPoint("TOPLEFT",parent,"TOPLEFT",vertical and row or along,-(vertical and along or row))
        end
    end
end

local function FlyoutFrameRect(frame,scale)
    if not frame or not frame:IsShown() then return end
    local l,r,b,t=frame:GetLeft(),frame:GetRight(),frame:GetBottom(),frame:GetTop()
    if not (l and r and b and t) then return end
    local s=frame:GetEffectiveScale()
    if s and s>0 then
        return {left=l*s/scale,right=r*s/scale,bottom=b*s/scale,top=t*s/scale}
    end
end

function FF:PositionFishingFlyout(panel, owner)
    if not (panel and owner) then return end
    if InCombatLockdown and InCombatLockdown() then self.flyoutLayoutPending=true; return end
    if panel.flyoutKind=="lure" then owner=self.gearButton or owner end
    if self.FinishFishingBarTransition then self:FinishFishingBarTransition(true) end
    if panel.flyoutGeometryLocked then return end
    panel:SetScale(1)
    local vertical=self:GetFishingBarOrientation()=="vertical"
    local scale=panel:GetEffectiveScale()
    local screenScale=UIParent:GetEffectiveScale()
    local sl,sr,sb,st=UIParent:GetLeft(),UIParent:GetRight(),UIParent:GetBottom(),UIParent:GetTop()
    local screen,rect,choice,gear,anchor,bar
    local size=self:GetFishingFlyoutLayout(panel.flyoutKind).size
    panel.flyoutMaxColumns, panel.flyoutAlongStep = nil, nil
    if sl and sr and sb and st and scale and scale>0 then
        screen={left=sl*screenScale/scale,right=sr*screenScale/scale,bottom=sb*screenScale/scale,top=st*screenScale/scale}
        rect=FlyoutFrameRect(owner,scale); gear=FlyoutFrameRect(self.gearButton,scale)
        if rect then
            anchor=rect
            for _,entry in ipairs(self:GetFishingBarCategories()) do
                local box=FlyoutFrameRect(self[entry.field],scale)
                if box then
                    if not bar then bar={left=box.left,right=box.right,bottom=box.bottom,top=box.top}
                    else
                        bar.left=math.min(bar.left,box.left);bar.right=math.max(bar.right,box.right)
                        bar.bottom=math.min(bar.bottom,box.bottom);bar.top=math.max(bar.top,box.top)
                    end
                end
            end
            bar=bar or rect
            if panel.flyoutKind=="utility" and (panel.rowCount or 0)>1 and gear then
                local centers=(vertical and bar.top-bar.bottom-(rect.top-rect.bottom) or bar.right-bar.left-(rect.right-rect.left))
                panel.flyoutMaxColumns=math.max(1,math.floor(centers/(size+self:GetFishingFlyoutLayout(panel.flyoutKind).spacing))+1)
            elseif panel.flyoutKind == "journal" then
                -- The first tile aligns with Journal. Leave it there and wrap if the second tile would hit the edge.
                local step = size + self:GetFishingFlyoutLayout("journal").spacing
                local center = vertical and -(rect.top + rect.bottom) / 2 or (rect.left + rect.right) / 2
                local edge = vertical and -screen.bottom or screen.right
                local settings = not vertical and FlyoutFrameRect(self.settingsButton, scale)
                if settings then
                    step = math.max(step, (settings.left + settings.right) / 2 - center)
                    panel.flyoutAlongStep = step
                end
                if center + step + size / 2 + QUICK_TRAY_INSET > edge then panel.flyoutMaxColumns = 1 end
            end
            local origin=gear or rect
            local preferRight=origin.left+origin.right<screen.left+screen.right
            choice=self:ResolveFishingFlyoutPlacement(panel.rowCount or 1,bar,screen,panel.flyoutFixedButton~=nil,panel.flyoutKind,panel.flyoutMaxColumns,preferRight)
        end
    end
    local previous=panel.flyoutAxisScroll or self:GetFishingQuickTrayScroll(panel)
    local wasReversed=panel.flyoutRowsReversed==true
    panel.flyoutAvailableWidth=choice and choice.width or nil
    panel:SizeForRows(panel.rowCount or 1,choice and choice.maxVisible)
    panel.flyoutAxisScroll=nil
    panel:ClearAllPoints()
    local side=choice and choice.side or (vertical and "right" or "below")
    if choice then
        local width,height=panel:GetWidth(),panel:GetHeight()
        local along=vertical and -(anchor.top+anchor.bottom)/2 or (anchor.left+anchor.right)/2
        if panel.flyoutKind=="utility" and (panel.rowCount or 0)>1 and gear then
            local g=vertical and -(gear.top+gear.bottom)/2 or (gear.left+gear.right)/2
            if g<=along then
                along=math.max(g,along-(math.min(panel.rowCount or 1,panel.flyoutColumns)-1)*panel.flyoutStep)
            end
            local half=(vertical and rect.top-rect.bottom or rect.right-rect.left)/2
            local low=(vertical and -bar.top or bar.left)+half
            local high=(vertical and -bar.bottom or bar.right)-half-(math.min(panel.rowCount or 1,panel.flyoutColumns)-1)*panel.flyoutStep
            along=math.max(low,math.min(high,along))
        end
        local x,y=along-size/2-QUICK_TRAY_INSET,bar.bottom-4
        if vertical then
            x,y=bar.right+4,-along+size/2+QUICK_TRAY_INSET
            if side=="left" then x=bar.left-4-width end
        else
            if side=="below" and screen.top-bar.top>=height+4
                and FlyoutOverlapsActionBar(x*scale,(x+width)*scale,(y-height)*scale,y*scale) then side="above" end
            if side=="above" then y=bar.top+4+height
            elseif side=="right" then x,y=bar.right+4,bar.top+5
            elseif side=="left" then x,y=bar.left-4-width,bar.top+5 end
        end
        x=math.max(screen.left,math.min(screen.right-width,x))
        y=math.max(screen.bottom+height,math.min(screen.top,y))
        panel:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",x-screen.left,y-screen.bottom)
    else panel:SetPoint("TOPLEFT",owner,"BOTTOMLEFT",-5,-4) end
    local reversed=vertical and side=="left" or not vertical and side=="above"
    PlaceFishingFlyoutIcons(panel,reversed)
    local limit=self:GetFishingQuickTrayScrollLimit(panel)
    if reversed~=wasReversed then previous=limit-previous end
    self:SetFishingQuickTrayScroll(panel,math.max(0,math.min(previous,limit)))
    self:UpdateFishingQuickTrayScrollControls(panel)
    panel.flyoutRowsReversed=reversed;panel.flyoutRowsAbove=not vertical and reversed
    panel.flyoutAbove=side=="above";panel.flyoutSide=side
    panel.flyoutLaidOutCount=panel.rowCount;panel.flyoutLaidOutVisibleRows=panel.flyoutVisibleRows
    panel:SetFrameLevel(math.max(self.bar and self.bar:GetFrameLevel() or 0,self.toolBar and self.toolBar:GetFrameLevel() or 0)+30)
    panel.flyoutGeometryLocked=panel:IsShown() and true or nil
end

local FLYOUT_ROUNDED_FILL = "Interface\\AddOns\\ForeverFishing\\Media\\FlyoutRoundedFill"
local FLYOUT_ROUNDED_EDGE = "Interface\\AddOns\\ForeverFishing\\Media\\FlyoutRoundedEdge"
local FLYOUT_ACTIVE_GLOW = "Interface\\AddOns\\ForeverFishing\\Media\\FlyoutActiveGlow"
local MINI_CHEF_SQUARE = "Interface\\AddOns\\ForeverFishing\\Media\\MiniMasterChefSquare"

function FF:StyleFishingFlyoutOwner(button)
    local glow = button:CreateTexture(nil, "OVERLAY")
    glow:SetSize(64, 64)
    glow:SetPoint("CENTER", button, "CENTER")
    glow:SetTexture(FLYOUT_ACTIVE_GLOW)
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(1, 0.68, 0.27, 0.20)
    glow:Hide()
    button.activeFlyoutGlow = glow

    local edge = button:CreateTexture(nil, "OVERLAY")
    edge:SetAllPoints(button)
    edge:SetTexture(FLYOUT_ROUNDED_EDGE)
    edge:SetVertexColor(0.95, 0.69, 0.32, 0.92)
    edge:Hide()
    button.activeFlyoutEdge = edge
end

function FF:CloseFishingFlyouts(forScan)
    if InCombatLockdown and InCombatLockdown() then self.masterChefTrayResume = nil; return end
    if self.UpdateFishingFlyoutWatch then self:UpdateFishingFlyoutWatch() end
    -- Collapsing/switching trays is presentation only. Input yielding also
    -- dismisses independent windows and belongs only to an explicit scan start.
    if forScan then
        if self.YieldJournalInputsForScan then self:YieldJournalInputsForScan() end
        if self.SuspendAchievementNoticeForScan then self:SuspendAchievementNoticeForScan() end
    end
    if self.utilityPicker and self.utilityPicker:IsShown() then self.utilityPicker:Hide() end
    if self.settingsPicker and self.settingsPicker:IsShown() then self.settingsPicker:Hide() end
    if self.journalPicker and self.journalPicker:IsShown() then self.journalPicker:Hide() end
    if self.gearPicker and self.gearPicker:IsShown() then self.gearPicker:Hide() end
    if self.lurePicker and self.lurePicker:IsShown() then self.lurePicker:Hide() end
    if self.masterChefTrayResume or self.masterChefTray and self.masterChefTray:IsShown() then self:CloseFishingQuickTray() end
    if self.quickTrayDismiss then self.quickTrayDismiss:Hide() end
end

function FF:SyncFishingFlyoutState()
    local gearOpen = self.gearPicker and self.gearPicker:IsShown()
    local lureOpen = self.lurePicker and self.lurePicker:IsShown()
    local utilityOpen=self.utilityPicker and self.utilityPicker:IsShown()
    local settingsOpen=self.settingsPicker and self.settingsPicker:IsShown()
    local journalOpen=self.journalPicker and self.journalPicker:IsShown()
    local chefOpen = self.masterChefTray and self.masterChefTray:IsShown()
    for _, pair in ipairs({ { self.gearButton, gearOpen },
        { self.lureButton, lureOpen }, { self.utilityButton,utilityOpen }, { self.masterChefButton, chefOpen },
        { self.settingsButton, settingsOpen }, { self.journalButton, journalOpen } }) do
        local button, isOpen = pair[1], pair[2]
        local border = button and button.quickslotBorder
        if border then
            if isOpen then border:SetVertexColor(1, 0.77, 0.39, 1)
            else border:SetVertexColor(1, 1, 1, 1) end
        end
        if button and button.activeFlyoutEdge then button.activeFlyoutEdge:SetShown(isOpen and true or false) end
        if button and button.activeFlyoutGlow then button.activeFlyoutGlow:SetShown(isOpen and true or false) end
    end
    local open = gearOpen or lureOpen or chefOpen or utilityOpen or settingsOpen or journalOpen or self.masterChefTrayResume
    if open and not self.quickTrayDismiss and self.toolBar then
        local dismiss = CreateFrame("Frame", nil, self.visibilityRoot or self:EnsureFishingVisibilityRoot(),
            "SecureHandlerStateTemplate")
        dismiss:SetAllPoints(UIParent)
        dismiss:SetFrameStrata(HUD_STRATA)
        local inCombat = InCombatLockdown and InCombatLockdown()
        dismiss:SetFrameLevel(inCombat and math.max(0, self.toolBar:GetFrameLevel() - 1)
            or self.toolBar:GetFrameLevel() + 5)
        dismiss:EnableMouse(false) -- Lifecycle monitor; bag/world clicks pass through.
        dismiss:SetScript("OnEvent", function(_,event)
            if event == "PLAYER_LEAVING_WORLD" then self:CloseFishingFlyouts() end
        end)
        dismiss:Hide()
        dismiss:SetScript("OnHide", function(frame)
            frame:SetScript("OnUpdate",nil); frame:UnregisterAllEvents()
            self.masterChefTrayResume = nil
        end)
        self.quickTrayDismiss = dismiss
        self:RegisterCombatCloseWindow("quickTrayDismiss", dismiss)
    end
    if self.quickTrayDismiss and not (InCombatLockdown and InCombatLockdown()) then
        self.quickTrayDismiss:SetShown(open and true or false)
    end
end

function FF:BindFishingFlyoutOwner(panel)
    if self.closeButton and panel.flyoutKind then
        self.closeButton:SetFrameRef("flyout-" .. panel.flyoutKind, panel)
    end
    panel:HookScript("OnShow", function()
        -- Also cover direct Show calls and delayed Master Chef Place restoration.
        if self.IsCameraSearchPending and self:IsCameraSearchPending() then
            self:CloseFishingFlyouts()
            return
        end
        self:ActivateFishingFlyout(panel)
        panel.flyoutGeometryLocked = panel.flyoutEntries and true or nil
        self:SyncFishingFlyoutState()
        self:UpdateFishingFlyoutWatch()
        self:RefreshFishingLayer()
    end)
    panel:HookScript("OnHide", function()
        self:ReleaseFishingFlyout(panel)
        self:SyncFishingFlyoutState()
    end)
end

local function MaskFishingFlyoutTexture(button, texture)
    if not (button.CreateMaskTexture and texture.AddMaskTexture) then return end
    local mask = button:CreateMaskTexture(nil, "ARTWORK")
    mask:SetAllPoints(texture)
    mask:SetTexture(FLYOUT_ROUNDED_FILL, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask)
    return mask
end

function FF:StyleFishingFlyoutIcon(button, panel)
    button:SetSize(panel and panel.flyoutIconSize or FLYOUT_DEFAULTS.size,
        panel and panel.flyoutIconSize or FLYOUT_DEFAULTS.size)
    if panel and panel.scroll then
        button:EnableMouseWheel(true)
        button:SetScript("OnMouseWheel", function(row, delta) self:ScrollFishingQuickTray(row and row.flyoutScrollOwner or panel, delta) end)
    end
    local surface = button:CreateTexture(nil, "BACKGROUND")
    surface:SetAllPoints(button)
    surface:SetTexture(FLYOUT_ROUNDED_FILL)
    surface:SetVertexColor(0.12, 0.08, 0.035, 0.94)
    button.flyoutSurface = surface
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button.flyoutIconMask = MaskFishingFlyoutTexture(button, button.icon)
    local edge = button:CreateTexture(nil, "OVERLAY")
    edge:SetAllPoints(button)
    edge:SetTexture(FLYOUT_ROUNDED_EDGE)
    edge:SetVertexColor(0.72, 0.52, 0.25, 0.88)
    button.flyoutEdge = edge
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    highlight:SetTexture(FLYOUT_ROUNDED_FILL)
    highlight:SetVertexColor(1, 0.82, 0.49, 0.16)
    button:SetHighlightTexture(highlight)
end

-- Shared Gear/Lure/Utilities add glyph on the existing rounded flyout tile.
function FF:StyleFishingFlyoutAddButton(button)
    button.plusHorizontal = button:CreateTexture(nil, "ARTWORK")
    button.plusHorizontal:SetSize(19, 3)
    button.plusHorizontal:SetPoint("CENTER")
    button.plusHorizontal:SetColorTexture(1, 0.72, 0.25)
    button.plusVertical = button:CreateTexture(nil, "ARTWORK")
    button.plusVertical:SetSize(3, 19)
    button.plusVertical:SetPoint("CENTER")
    button.plusVertical:SetColorTexture(1, 0.72, 0.25)
end

function FF:SetFishingFlyoutSelectionGlow(button, selected)
    if selected and not button.flyoutSelectionGlow then
        local glow = button:CreateTexture(nil, "OVERLAY")
        -- Crop the halo to the icon tile; the full texture can spill onto the main bar.
        glow:SetSize(button:GetWidth(), button:GetHeight())
        glow:SetPoint("CENTER", button, "CENTER")
        glow:SetTexture(FLYOUT_ACTIVE_GLOW)
        glow:SetTexCoord(0.125, 0.875, 0.125, 0.875)
        glow:SetBlendMode("ADD")
        glow:SetVertexColor(1, 0.76, 0.34, 0.70)
        button.flyoutSelectionGlowMask = MaskFishingFlyoutTexture(button, glow)
        button.flyoutSelectionGlow = glow
    end
    if button.flyoutSelectionGlow then button.flyoutSelectionGlow:SetShown(selected and true or false) end
end

function FF:ShowSettingsPicker()
    if InCombatLockdown and InCombatLockdown() then return end
    if not self:CanRevealFishingFlyout() then return end
    self:EnsureFishingBarExpanded()
    if self.settingsPicker and self.settingsPicker:IsShown() then self.settingsPicker:Hide(); return end
    self:CloseFishingFlyouts()
    if not self.settingsPicker then
        local panel = self:CreateFishingQuickTray("ForeverFishingSettingsPicker", nil, "settings")
        panel.rows = {}
        panel.plusButton = false
        local row = CreateFrame("Button", nil, panel.content)
        self:StyleFishingFlyoutIcon(row, panel)
        row:RegisterForClicks("LeftButtonUp")
        row.flyoutOffOverlay = row:CreateTexture(nil, "ARTWORK", nil, 1)
        row.flyoutOffOverlay:SetAllPoints(row.icon)
        row.flyoutOffOverlay:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\LU03_Off_Overlay")
        row:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText(FF:LocalizedText("gamepad.title"))
            GameTooltip:AddLine(button.tooltipLine, .84, .81, .72, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:SetScript("OnClick", function(_, mouse)
            if mouse ~= "LeftButton" then return end
            if self:SetFishingGamepadMode(not self:IsFishingGamepadMode())
                and panel:IsShown() and GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(row) then
                local enter = row:GetScript("OnEnter")
                if enter then enter(row) end
            end
        end)
        panel.rows[1] = row
        self.settingsPicker = panel
        self:BindFishingFlyoutOwner(panel)
    end
    self:RefreshSettingsPicker()
    self:RefreshFishingLayer()
    self:PositionFishingFlyout(self.settingsPicker, self.settingsButton)
    self.settingsPicker:Show()
end

function FF:RefreshSettingsPicker()
    if InCombatLockdown and InCombatLockdown() then return end
    local panel = self.settingsPicker
    if not panel then return end
    local row = panel.rows[1]
    panel.flyoutEntries = self:ResolveFishingFlyoutEntries(panel, {{id="gamepad-mode"}})
    local enabled = self.db.gamepadMode == true -- Pending binding capture is not a committed mode.
    row.icon:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\GP01_Gamepad_Glossy")
    row.icon:SetTexCoord(0, 1, 0, 1)
    row.flyoutOffOverlay:SetShown(not enabled)
    self:SetFishingFlyoutSelectionGlow(row, enabled)
    row.flyoutEdge:SetVertexColor(enabled and 1 or .72, enabled and .77 or .52,
        enabled and .39 or .25, enabled and 1 or .88)
    row.tooltipLine = FF:LocalizedText(enabled and "gamepad.flyout-on" or "gamepad.flyout-off")
    row:Show()
    if not panel.flyoutGeometryLocked then panel:SizeForRows(1) end
    if panel:IsShown() then self:PositionFishingFlyout(panel, self.settingsButton) end
end

local JOURNAL_FLYOUT = {
    { icon = "JF02_Goals", title = "journal.goals-button", help = "journal.quick-goals", action = "ShowSessionGoals" },
    { icon = "JF01_Stats", title = "journal.tracker-button", help = "journal.quick-tracker", action = "ShowSessionTracker" },
}

function FF:ShowJournalPicker()
    if self.dataResetPendingReload or not self:CanRevealFishingFlyout() then return end
    self:EnsureFishingBarExpanded()
    local panel = self.journalPicker
    if panel and panel:IsShown() then panel:Hide(); return end
    self:CloseFishingFlyouts()
    if not panel then
        panel = self:CreateFishingQuickTray("ForeverFishingJournalPicker", nil, "journal")
        panel.rows = {}
        panel.plusButton = false
        for index, entry in ipairs(JOURNAL_FLYOUT) do
            local row = CreateFrame("Button", nil, panel.content)
            self:StyleFishingFlyoutIcon(row, panel)
            row.icon:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\" .. entry.icon)
            row.icon:SetTexCoord(0, 1, 0, 1)
            row:RegisterForClicks("LeftButtonUp")
            row:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(self:LocalizedText(entry.title))
                GameTooltip:AddLine(self:LocalizedText(entry.help), .84, .81, .72, true)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            row:SetScript("OnClick", function(_, mouse)
                if mouse ~= "LeftButton" or not panel:IsShown() or not self:CanRevealFishingFlyout() then return end
                self:FinishFishingFlyoutSelection(panel)
                GameTooltip:Hide()
                self[entry.action](self, true)
            end)
            panel.rows[index] = row
        end
        panel.rowCount = #panel.rows
        self.journalPicker = panel
        self:BindFishingFlyoutOwner(panel)
    end
    panel.flyoutEntries = JOURNAL_FLYOUT
    self:PositionFishingFlyout(panel, self.journalButton)
    panel:Show()
end

function FF:RefreshFishingFlyoutLayout(kind)
    if InCombatLockdown and InCombatLockdown() then
        self.flyoutLayoutPending = true
        return
    end
    if (kind == "settings" and not self.settingsPicker) or (kind == "journal" and not self.journalPicker) then return end
    local panel = kind == "gear" and self.gearPicker
        or kind == "lure" and self.lurePicker or kind == "utility" and self.utilityPicker
        or kind == "settings" and self.settingsPicker or kind == "journal" and self.journalPicker or self.masterChefTray
    if not panel then return end
    panel.flyoutGeometryLocked, panel.flyoutEntries = nil,nil -- Deliberate layout edit.
    local layout = self:GetFishingFlyoutLayout(kind)
    panel:SetScale(layout.scale)
    panel.flyoutIconSize = layout.size
    panel.flyoutStep = layout.size + layout.spacing
    panel.flyoutColumns = layout.columns
    for _, button in ipairs(panel.rows or panel.buttons or {}) do
        button:SetSize(layout.size, layout.size)
        if button.flyoutSelectionGlow then
            button.flyoutSelectionGlow:SetSize(layout.size, layout.size)
        end
    end
    if panel.plusButton then panel.plusButton:SetSize(layout.size, layout.size) end
    if kind == "gear" then self:RefreshGearPicker()
    elseif kind == "lure" then self:RefreshLurePicker()
    elseif kind == "utility" then self:RefreshUtilityPicker()
    elseif kind == "settings" then self:RefreshSettingsPicker()
    elseif kind == "journal" and panel:IsShown() then self:PositionFishingFlyout(panel, self.journalButton)
    elseif kind == "chef" and panel:IsShown() then self:RefreshMasterChefQuickTray(true)
    elseif panel.rowCount then panel:SizeForRows(panel.rowCount) end
end

function FF:SyncMatchedFishingFlyoutScales()
    if InCombatLockdown and InCombatLockdown() then return end
    for _, entry in ipairs({
        { "gear", self.gearPicker }, { "lure", self.lurePicker },
        { "chef", self.masterChefTray }, {"utility",self.utilityPicker}, {"settings",self.settingsPicker},
        { "journal", self.journalPicker },
    }) do
        local kind, panel = entry[1], entry[2]
        if panel then
            local layout = self:GetFishingFlyoutLayout(kind)
            panel.flyoutGeometryLocked = nil
            panel:SetScale(layout.scale)
            local owner = kind=="lure" and self.lureButton or kind=="utility" and self.utilityButton
                or kind=="settings" and self.settingsButton or kind=="journal" and self.journalButton or self.gearButton
            if panel:IsShown() then self:PositionFishingFlyout(panel, owner) end
        end
    end
end

function FF:ApplyPendingFishingLayouts()
    if self.fishingInformationPending then self:ApplyFishingInformationLayout() end
    if self.compactBarLayoutPending then self:ApplyFishingBarPresentation() end
    if self.iconBarSpacingPending then self:ApplyIconBarSpacing() end
    if self.flyoutLayoutPending then
        self.flyoutLayoutPending = nil
        self:RefreshAllFishingFlyoutLayouts()
    end
end

local function MasterChefTrayButton(chef, tray, index, plain)
    local button
    if plain then button = tray.plusButton
    else button = tray.buttons[index] end
    if button then return button end
    local template
    if not plain then template = "SecureActionButtonTemplate" end
    button = CreateFrame("Button", nil, tray.content, template)
    button:RegisterForClicks("LeftButtonUp")
    if not plain then button:SetAttribute("useOnKeyDown", false) end
    chef:StyleFishingFlyoutIcon(button, tray)
    local dim = button:CreateTexture(nil, "OVERLAY")
    dim:SetAllPoints(button.icon)
    dim:SetColorTexture(0.12, 0.08, 0.05, 0.58)
    button.dim = dim
    button.flyoutDimMask = MaskFishingFlyoutTexture(button, dim)
    local h = button:CreateTexture(nil, "OVERLAY")
    h:SetSize(20, 3); h:SetPoint("CENTER")
    h:SetColorTexture(0.96, 0.76, 0.43)
    local v = button:CreateTexture(nil, "OVERLAY")
    v:SetSize(3, 20); v:SetPoint("CENTER")
    v:SetColorTexture(0.96, 0.76, 0.43)
    button.plusH, button.plusV = h, v
    button:SetScript("OnEnter", function(row)
        local entry = row.entry
        if not entry then return end
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        if entry.kind == "plus" then
            GameTooltip:SetText(FF:LocalizedText("chef.open-mini"), 1, 0.82, 0.45)
        elseif entry.kind == "camp" then
            local camp, status = entry.camp, entry.status
            if not status or status.owned < 1 and not entry.craftable then
                if chef.ShowMasterChefMaterialsTooltip then
                    chef.ShowMasterChefMaterialsTooltip(row, FF:LocalizedText("chef.need-materials"),
                        status and status.ingredients, status and status.counts,
                        camp.toolID and (camp.toolName or FF:LocalizedText("chef.tool")),
                        status and status.toolCount)
                end
                if status and not status.learned then
                    GameTooltip:AddLine(FF:LocalizedText("chef.recipe-unlearned"), 1, 0.39, 0.34, true)
                end
            else
                FF:BeginJournalItemTooltip(row, camp.id,
                    (entry.smart and FF:LocalizedText("chef.smart-camp-name",camp.name) or camp.name))
                GameTooltip:AddLine(status.owned > 0 and FF:LocalizedText("chef.place") or FF:LocalizedText("chef.craft-one"),
                    0.83, 0.72, 0.52)
                if chef.masterChefCampPreparing == camp.id
                    or chef.masterChefCampPreparedRecipeID == camp.recipeID then
                    GameTooltip:AddLine(FF:LocalizedText("chef.again-ready"), 0.83, 0.72, 0.52, true)
                end
            end
        else
            FF:BeginJournalItemTooltip(row, entry.meal.id, entry.meal.name)
            GameTooltip:AddLine(FF:LocalizedText("chef.cook-all"), 0.83, 0.72, 0.52, true)
            GameTooltip:AddLine(FF:LocalizedText("chef.available-count",tostring(chef:GetMasterChefAvailableCrafts(entry.meal.id))), 0.83, 0.72, 0.52)
        end
        if entry.kind == "camp" then
            local state = chef.masterChefStatus and chef.masterChefStatus.campfire
            if state and GetTime and GetTime() < state.untilTime then
                GameTooltip:AddLine(state.text, state.error and 1 or 0.83,
                    state.error and 0.39 or 0.72, state.error and 0.34 or 0.52)
            end
        end
        if FF.journalItemTooltipOwner == row then FF:FinishJournalItemTooltip(row)
        else GameTooltip:Show() end
    end)
    button:SetScript("OnLeave", function(row) FF:HideJournalItemTooltip(row) end)
    if plain then
        button:SetScript("OnClick", function()
            chef:OpenCompactMasterChefFromQuickTray()
        end)
        tray.plusButton = button
        return button
    end
    button:SetScript("PreClick", function(row, mouse)
        local entry = row.entry
        if mouse ~= "LeftButton" or not entry or entry.kind ~= "camp"
            or not entry.status or entry.status.owned < 1 then return end
        chef:ArmMasterChefCampPlacement(entry.camp.id, "campfire", row)
    end)
    button:SetScript("PostClick", function(row, mouse, down)
        if mouse ~= "LeftButton" or down then return end
        local attempt = chef.masterChefCampPlaceAttempt
        if attempt and attempt.button == row then
            -- Bag/recipe refreshes inside the item action may change this row.
            -- Finish the issued Place click, never reinterpret it as Craft.
            chef:BeginMasterChefCampPlacement(attempt.itemID)
            return
        end
        local entry = row.entry
        if not entry then return end
        if entry.kind == "camp" then
            local camp, status = entry.camp, entry.status
            if status.owned > 0 then
                chef:BeginMasterChefCampPlacement(camp.id)
            elseif entry.craftable then
                local hadCampSession = chef.masterChefOwnsCampSession
                chef.masterChefTrayPreparingCampID = camp.id
                local started = chef:CraftMasterChefCamp(camp.id)
                if not hadCampSession and chef.masterChefOwnsCampSession then
                    chef.masterChefTrayOwnsCampPreparation = true
                end
                if started and chef.masterChefCampCrafting == camp.id then
                    chef.masterChefTrayPreparingCampID = nil
                    chef:SetMasterChefQuickStatus(FF:LocalizedText("chef.quick-crafting",camp.name))
                elseif started and chef.masterChefCampPreparedRecipeID == camp.recipeID then
                    chef.masterChefTrayPreparingCampID = nil
                    chef:SetMasterChefQuickStatus(FF:LocalizedText("chef.quick-prepared",camp.profession or FF:LocalizedText("food.fishing-short")))
                elseif started then
                    chef:SetMasterChefQuickStatus(FF:LocalizedText("chef.quick-preparing",camp.profession or FF:LocalizedText("food.fishing-short")))
                else
                    chef.masterChefTrayPreparingCampID = nil
                end
                chef:RefreshMasterChefQuickTray(true)
            end
        elseif entry.kind == "meal" then
            local count = chef:GetMasterChefAvailableCrafts(entry.meal.id)
            if count < 1 then chef:RefreshMasterChefQuickTray(true); return end
            local started = chef:QuickCookMasterChefMeal(entry.meal.id, count)
            if not chef.masterChefOwnsCampSession then
                chef.masterChefTrayOwnsCampPreparation = nil
                chef.masterChefTrayPreparingCampID = nil
            end
            if started and chef.masterChefCookingActive == entry.meal.id then
                chef:SuspendMasterChefQuickTray()
            else
                if started and chef.masterChefCookingQuickPending then
                    chef:SetMasterChefQuickStatus(FF:LocalizedText("chef.preparing-cooking"))
                end
                chef:RefreshMasterChefQuickTray(true)
            end
        end
    end)
    tray.buttons[index] = button
    return button
end

function FF:RefreshMasterChefQuickTray(immediate)
    if InCombatLockdown and InCombatLockdown() then return end
    self:SyncMasterChefQuickTrayOperation()
    local tray = self.masterChefTray
    if not tray or not tray:IsShown() then return end
    if self.DeferScanRefresh and self:DeferScanRefresh("RefreshMasterChefQuickTray", immediate) then return end
    local display = self:CreateMasterChefDisplaySnapshot()
    local camp, status, campRank, camps = self:GetMasterChefQuickCamps(display)
    local entries = { { kind = "camp", camp = camp, status = status,
        craftable = campRank == 2, smart = true } }
    for _, available in ipairs(camps) do
        entries[#entries + 1] = { kind = "camp", camp = available.camp,
            status = available.status, craftable = available.craftable }
    end
    for _, meal in ipairs(self:GetMasterChefQuickMeals(immediate, display)) do
        entries[#entries + 1] = { kind = "meal", meal = meal }
    end
    entries[#entries + 1] = { kind = "plus" }
    entries = self:ResolveFishingFlyoutEntries(tray,entries)
    tray.entries = entries
    tray.placeItems = {}
    for index, entry in ipairs(entries) do
        local plus = entry.kind == "plus"
        local button = MasterChefTrayButton(self, tray, index, plus)
        button.entry = entry
        if not tray.flyoutGeometryLocked then
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", tray.content, "TOPLEFT",
                ((index - 1) % tray.flyoutColumns) * tray.flyoutStep,
                -math.floor((index - 1) / tray.flyoutColumns) * tray.flyoutStep)
        end
        local campStatus = entry.status
        local disabled = entry.flyoutUnavailable or entry.kind == "camp" and (not campStatus
            or campStatus.owned < 1 and not entry.craftable)
        local icon = plus and MINI_CHEF_SQUARE or QuickTrayIcon(
            entry.kind == "camp" and entry.camp.id or entry.meal.id)
        button.icon:SetTexture(icon)
        button.icon:SetShown(true)
        button.icon:SetTexCoord(plus and 0 or 0.07, plus and 1 or 0.93,
            plus and 0 or 0.07, plus and 1 or 0.93)
        button.plusH:Hide(); button.plusV:Hide()
        button.dim:SetShown(disabled or false)
        if button.icon.SetDesaturated then button.icon:SetDesaturated(disabled or false) end
        button:SetEnabled(not entry.flyoutUnavailable)
        local placeItem = not entry.flyoutUnavailable and entry.kind == "camp" and campStatus
            and campStatus.owned > 0 and entry.camp.id or nil
        if placeItem then tray.placeItems[placeItem] = true end
        if not plus then
            button:SetAttribute("type", placeItem and "item" or nil)
            button:SetAttribute("type1", placeItem and "item" or nil)
            button:SetAttribute("item", placeItem and "item:" .. placeItem or nil)
            button:SetAttribute("item1", placeItem and "item:" .. placeItem or nil)
        end
        button:Show()
    end
    -- The last entry is the separate + button. A secure action button may
    -- still occupy that slot after the available actions shrink.
    for index = #entries, #tray.buttons do tray.buttons[index]:Hide() end
    tray.flyoutFixedButton = tray.plusButton
    if not tray.flyoutGeometryLocked then tray:SizeForRows(#entries) end
    self:PositionFishingFlyout(tray, self.gearButton)
end

function FF:CloseFishingQuickTray(preservePreparation, operation)
    if self.closingMasterChefTray then return end
    if not operation then self.masterChefTrayResume = nil end
    self.closingMasterChefTray = true
    if self.masterChefTray and self.masterChefTray:IsShown() then self.masterChefTray:Hide() end
    if not preservePreparation and self.masterChefTrayOwnsPreparation
        and self.masterChefOwnsCookingSession
        and not self.masterChefCookingActive
        and not (self.masterChefCookingQueue or {})[1] then
        self:ReleaseMasterChefCookingSession()
    end
    if not preservePreparation and self.masterChefTrayOwnsCampPreparation
        and self.masterChefOwnsCampSession
        and not self.masterChefCampCrafting then
        self:ReleaseMasterChefCampSession()
    end
    if not preservePreparation then
        self.masterChefTrayOwnsPreparation = nil
        self.masterChefTrayOwnsCampPreparation = nil
    end
    self.masterChefQuickStatus = nil
    self.closingMasterChefTray = nil
    self:SyncFishingFlyoutState()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function() self:UpdateUI() end)
    end
end

function FF:OpenCompactMasterChefFromQuickTray()
    self:CloseFishingQuickTray(true)
    -- The compact window now owns this preparation. ShowFloatingWindow closes
    -- any tray a second time, so clear the tray-only release flags first.
    self.masterChefTrayOwnsPreparation = nil
    self.masterChefTrayOwnsCampPreparation = nil
    self:ShowCompactMasterChef(true, true)
end

function FF:PrepareRevealedMasterChefTray()
    self.masterChefTray.flyoutChefActivated = true
    self.masterChefTrayOwnsPreparation = not self.masterChefOwnsCookingSession
    local prepared = self:PrepareMasterChefQuickTray()
    if prepared and self.masterChefCookingPrepared then self:SetLocalizedMasterChefQuickStatus("chef.message.cooking-prepared") end
end

function FF:ShowMasterChefQuickTray(restoring, passive)
    if self.IsCameraSearchPending and self:IsCameraSearchPending() then
        -- Place has finished, but the tray cannot reclaim world mouse input.
        -- Finish its normal idle-preparation cleanup instead of leaving a
        -- hidden tray owning a profession until the preparation watchdog.
        if restoring then self:CloseFishingQuickTray() end
        return
    end
    local resume = self.masterChefTrayResume
    if restoring then
        if not resume then return end
        if self:IsMasterChefQuickTrayBusy() or SpellIsTargeting and SpellIsTargeting()
            or UnitCastingInfo and UnitCastingInfo("player")
            or UnitChannelInfo and UnitChannelInfo("player") then return end
        if not (self.bar and self.bar:IsShown()) or not self:CanRevealFishingFlyout()
            or self.activeFishingFlyout then self:CloseFishingQuickTray(); return end
    elseif resume then
        -- The button also dismisses an operation-hidden tray, without stopping
        -- the operation. Its later completion must not reopen this intent.
        self:CloseFishingQuickTray(); return
    end
    if not self.toolBar or not self.toolBar:IsShown() then return end
    if InCombatLockdown and InCombatLockdown() then
        self:Print(FF:LocalizedText("chef.open-after-combat"))
        return
    end
    self:EnsureFishingBarExpanded()
    if self.masterChefTray and self.masterChefTray:IsShown() then
        if not restoring and not passive then
            if not self.masterChefTray.flyoutChefActivated then
                self:PrepareRevealedMasterChefTray()
            else self:CloseFishingQuickTray() end
        end
        return
    end
    if not self.masterChefTray then
        self.masterChefTray = self:CreateFishingQuickTray("ForeverFishingMasterChefTray",
            function() self:CloseFishingQuickTray() end, "chef")
        self.masterChefTray.plusButton = false
        self:BindFishingFlyoutOwner(self.masterChefTray)
    end
    if self.gearPicker then self.gearPicker:Hide() end
    if self.lurePicker then self.lurePicker:Hide() end
    if self.utilityPicker then self.utilityPicker:Hide() end
    if self.settingsPicker then self.settingsPicker:Hide() end
    if self.journalPicker then self.journalPicker:Hide() end
    self:RefreshFishingLayer()
    self.masterChefTrayResume = nil
    self.masterChefTray:Show()
    self.masterChefTray.flyoutChefActivated = resume and resume.activated or nil
    self:RefreshMasterChefQuickTray(true)
    if not restoring and not passive then
        self:PrepareRevealedMasterChefTray()
    elseif not passive and self.masterChefOwnsCookingSession and self.masterChefCookingPrepared then
        self:SetLocalizedMasterChefQuickStatus("chef.message.cooking-prepared")
    end
end

function FF:HideFishingRodWarning()
    self.fishingRodNoticeSerial = (self.fishingRodNoticeSerial or 0) + 1
    if self.fishingRodNotice then self.fishingRodNotice:Hide() end
end

function FF:ShowFishingWarning(message)
    if not self.fishingRodNotice or not self.bar or not self.bar:IsShown() then return false end
    self.fishingRodNoticeText:SetText(message)
    if self.rangeNotice then self.rangeNotice:Hide() end
    self.fishingRodNotice:Show()
    self.fishingRodNoticeSerial = (self.fishingRodNoticeSerial or 0) + 1
    local serial = self.fishingRodNoticeSerial
    if C_Timer and C_Timer.After then
        C_Timer.After(5, function()
            if serial ~= self.fishingRodNoticeSerial then return end
            self:HideFishingRodWarning()
            self:UpdateRangeNotice()
        end)
    end
    return true
end

function FF:ShowFishingRodWarning()
    local rodAvailable = self.fishingRodEquipped or self.fishingRodInBags
    return self:ShowFishingGearStatus(rodAvailable and self.db and self.db.autoEquipGear == false
        and "manual" or "noRod")
end

function FF:ShowFishingGearWarning()
    return self:ShowFishingGearStatus((self.fishingRodEquipped or self.fishingRodInBags) and "failed" or "noRod")
end

function FF:UpdateCameraAssistStatus()
    if not self.db.cameraAssist or not self.cameraAssistNeeded or not self.castButton then return end
    local hint
    if self.cameraMarkerDrag then
        hint = FF:LocalizedText("status.adjusting-marker")
    elseif self.cameraAssistBobber then
        hint = FF:LocalizedText("status.bobber-found-key")
    elseif self:CameraBobberLocated() then
        hint = FF:LocalizedText("status.bobber-found-marker")
    elseif self.cameraState == "RESTORE_HOME" then
        hint = FF:LocalizedText("status.centering")
    elseif self.cameraScanFailed then
        if self.cameraInputFailureReason then
            hint = FF:LocalizedText("status.camera-unavailable")
        elseif self.cameraManualCancelled then
            hint = FF:LocalizedText("status.scan-manual-cancel")
        elseif self.cameraEnvironmentCancelled then
            hint = FF:LocalizedText("status.scan-environment-cancel")
        elseif self.bobberStatusWarning and self.bobberStatusWarning.clearNPCTarget then
            hint = FF:LocalizedText("status.clear-npc-target")
        else
            hint = FF:LocalizedText("status.bobber-not-found")
        end
    elseif self.cameraState == "PAUSED" and (self.cameraScanStarted or self.cameraSweepPreparation) then
        hint = FF:LocalizedText("status.paused-marker")
    elseif self.cameraSweepPreparation then
        hint = FF:LocalizedText("status.preparing-view")
    elseif self.cameraScanStarted then
        hint = FF:LocalizedText("status.scanning")
    else
        hint = FF:LocalizedText("status.long-cast")
    end
    PaintCastStatus(self, CAST_STYLES.camera, hint)
end

function FF:IsFishingControllerAimPaused(state)
    local db=self.db
    if state~="missing" or not db or db.gamepadMode~=true or db.cameraAssist
        or self.gamepadDisconnected then return false end
    -- Read only the native input/cursor presentation. A missing soft target
    -- stays missing; this cannot enable interaction or acquire a bobber.
    for _,entry in ipairs({{IsUsingMouse,true},{IsUsingGamepad,false},{IsCursorVisible,true}}) do
        if type(entry[1])~="function" then return false end
        local ok,value=pcall(entry[1])
        if not ok or (issecretvalue and issecretvalue(value)) or value~=entry[2] then return false end
    end
    return self.db==db and db.gamepadMode==true and not db.cameraAssist and not self.gamepadDisconnected
end

function FF:UpdateBobberStatus()
    if not self.castButton or not self.active or (self.bar and not self.bar:IsShown()) then
        self.bobberStatusWarning = nil
        return
    end
    local serial, started = self.channelStartSerial, self.bobberCheckStartedAt
    local state, _, blockingGUID = self:BobberInteractState()
    local clearNPCTarget = state == "blocked" and self:IsSelectedFishingNPC(blockingGUID)
    -- Native callbacks may replace/end a channel while a sample is read.
    if not self.active or serial ~= self.channelStartSerial or started ~= self.bobberCheckStartedAt
        or (self.bar and not self.bar:IsShown()) then return end
    local now = GetTime()
    local status = self.bobberStatusWarning
    if not status or status.serial ~= serial or status.started ~= started then
        status = { serial = serial, started = started }
        self.bobberStatusWarning = status
    end
    local missing = state == "missing" or state == "blocked"
    status.clearNPCTarget = clearNPCTarget or nil
    if missing then status.missingSince = status.missingSince or now
    else status.missingSince = nil end
    if state == "bobber" then
        status.seenBobber, status.targetLostAt, status.channelKindAtLoss = true, nil, nil
    elseif status.seenBobber and not status.targetLostAt then
        status.targetLostAt = now
        if not self.db.cameraAssist and self:IsFasterRecastEnabled() then
            local db, bar = self.db, self.bar
            if self:PollFishingChannelEnd(true) or not self.active or self.bobberStatusWarning ~= status
                or self.db ~= db or self.bar ~= bar then return end
        end
    end
    -- Presentation only: retain the existing classification, readiness and
    -- input paths below. The selected NPC only changes the warning text.
    local settled = now - (started or self.castStart or now) >= .3
    -- Native reel-in can remove the target before its STOP event arrives.
    -- Quiet only this short loss after acquisition; readiness/bindings below
    -- still change immediately. Initial bad casts retain their existing grace.
    local endProbe = self:IsFasterRecastEnabled() and self.fishingChannelEndProbe
    local confirmingEnd = endProbe and endProbe.serial == serial and endProbe.db == self.db and endProbe.bar == self.bar
        and now - endProbe.at <= .25
    local targetSettling = not self.db.cameraAssist and status.targetLostAt
        and (now - status.targetLostAt < .25 or confirmingEnd)
    local nativeWarning = missing and settled and not targetSettling
    local nativeReady = state == "bobber"
    local restrictedReel = state == "restricted-reel" or nil
    local nativeChanged = self.nativeBobberReady ~= nativeReady or self.restrictedFishingReel ~= restrictedReel
    self.nativeBobberReady = nativeReady
    self.restrictedFishingReel = restrictedReel
    if state == "missing" or state == "blocked" or state == "unavailable" then
        if self.db.cameraAssist then
            self:SetRecastReady(false)
            self:SetCameraAssistNeeded(true, state)
        else
            self:SetCameraAssistNeeded(false)
            self:SetRecastReady(false)
        end
    elseif state == "bobber" then
        self:SetCameraAssistNeeded(false)
        self:SetRecastReady(false)
    end
    -- Reuse this sample for both verified and restricted dungeon targets.
    if nativeChanged and not self:CanKeepEmptyReelCastBinding() then self:ApplyBindings() end
    self:RefreshLocatedBobberHover()
    self:UpdateActionReadiness()
    self:SyncFishingSounds()
    self:UpdateRangeNotice()
    local aimPaused=self.IsFishingControllerAimPaused and self:IsFishingControllerAimPaused(state)
    if not self.active or serial ~= self.channelStartSerial or started ~= self.bobberCheckStartedAt
        or (self.bar and not self.bar:IsShown()) then return end
    if self.db.cameraAssist and self.cameraAssistNeeded then
        self:UpdateCameraAssistStatus()
        self:ApplyMasterChefQuickStatus()
        return
    end
    if aimPaused and settled and not targetSettling then
        PaintCastStatus(self, CAST_STYLES.idle, FF:LocalizedText("gamepad.aim-paused"))
        self:ApplyMasterChefQuickStatus()
        return
    end
    if (self.recastReady or missing) and (self.db.cameraAssist or nativeWarning) then
        PaintCastStatus(self, CAST_STYLES.recast, FF:LocalizedText(clearNPCTarget and "status.clear-npc-target" or "status.bobber-not-visible"))
        self:ApplyMasterChefQuickStatus()
        return
    end
    local rangeDelay = self.currentRangeDelay or self.db.rangeDelay
    local rangeCheckReady = self.bobberCheckStartedAt and GetTime() - self.bobberCheckStartedAt >= rangeDelay
    local goodCast = state == "bobber" and (not self.db.cameraAssist or rangeCheckReady)
    local hint, checking
    if goodCast then
        hint = self:GetFishingInputKey() and FF:LocalizedText("status.good-key") or FF:LocalizedText("status.good-mouse")
    elseif restrictedReel and self:GetFishingInputKey() and self:IsRestrictedFishingReelAvailable()
        and not self:CastInputLocked() and not self:FishingReelLootPending() then
        hint = FF:LocalizedText("status.dungeon-interact")
    elseif state == "unknown" and rangeCheckReady and self:GetFishingInputKey() and (self.db.cameraAssist or settled) then
        hint = FF:LocalizedText("status.check-interact")
    else
        hint = FF:LocalizedText("status.checking")
        checking = true
    end
    local style = goodCast and CAST_STYLES.good or CAST_STYLES.checking
    if not self.db.cameraAssist and checking then
        -- Quiet native landing/gaps, without claiming the bobber is ready.
        hint, style = "", CAST_STYLES.idle
    end
    PaintCastStatus(self, style, hint)
    self:ApplyMasterChefQuickStatus()
end

function FF:UpdateIdleFishingStatus()
    local key = self:GetFishingInputKey()
    local hint = self.castMacroIndex and (key and FF:LocalizedText("status.click-key") or FF:LocalizedText("status.click-set-key"))
        or (key and FF:LocalizedText("status.press-key") or FF:LocalizedText("status.free-macro-slot"))
    if self:FishingKeyReelLootPending() then
        hint = ""
    elseif self.fishingBagsFull then
        PaintCastStatus(self, CAST_STYLES.bagsFull, self:LocalizedText("status.bags-full"))
        return
    elseif self.castAction == "gear" then
        hint = FF:LocalizedText("status.equip-gear")
    elseif self.castAction == "lure" then
        hint = FF:LocalizedText("status.apply-lure")
    elseif self.castAction == "wait" then
        hint = FF:LocalizedText("status.preparing")
    end
    PaintCastStatus(self, CAST_STYLES.idle, hint)
end

function FF:UpdateUI(skipJournal)
    if not self.bar then return end
    if self.RecoverFishingChannel then self:RecoverFishingChannel(false) end
    local active = self.active
    if active then self:UpdateBobberStatus() end
    if self.RefreshSmartButtons then self:RefreshSmartButtons() end
    if self.settingsPicker and self.settingsPicker:IsShown() then self:RefreshSettingsPicker() end
    if self.RefreshFishingUtilityButton then self:RefreshFishingUtilityButton() end
    self:SyncCastAction()
    if not self.active then self:UpdateIdleFishingStatus() end
    self:ApplyMasterChefQuickStatus()
    self:UpdateRangeNotice()
    SetBindingLabel(self.castButton.keyText, self:GetFishingInputKey(), FF:LocalizedText("bar.key"))
    self:UpdateFishingKeyWarning(self.castButton.keyText,self:GetFishingInputKey())
    local updateOwner = self.fishingUpdateFrame or self.castButton
    if self.GetFishingInformationProgress then self:GetFishingInformationProgress() end
    if (active or self.cookingInformationCast) and self:IsFishingSessionOpen() then
        if not updateOwner.fishingStatusTick then
            updateOwner.fishingStatusTick = function(_, elapsed)
                if self.cookingInformationCast then
                    self:UpdateCookingInformationProgress()
                    if not self.active and not self.cookingInformationCast then return end
                end
                if self.active and self.db.cameraAssist then self:UpdateCameraMarkerInfo() end
                self.readinessElapsed = (self.readinessElapsed or 0) + elapsed
                if self.readinessElapsed >= 0.05 then
                    self.readinessElapsed = 0
                    if self.active and self.PollFishingChannelEnd and self:PollFishingChannelEnd() then return end
                    if self.active then self:UpdateActionReadiness() end
                    if self.UpdateFishingInformation then self:UpdateFishingInformation() end
                    if not self.active and not self.cookingInformationCast then self:UpdateUI();return end
                end
                if not self.active then return end
                self.bobberElapsed = (self.bobberElapsed or 0) + elapsed
                local castElapsed = self.bobberCheckStartedAt and GetTime() - self.bobberCheckStartedAt or 0
                local lowDelay = (self.currentRangeDelay or self.db.rangeDelay) < 0.5 or (self.currentRecastDelay or self.db.recastDelay) < 0.5 or (self.currentHookDelay or self.db.hookDelay) < 0.5
                local interval = lowDelay and castElapsed < 1 and 0.05 or 0.2
                if self.bobberElapsed >= interval then
                    self.bobberElapsed = 0
                    self:UpdateBobberStatus()
                end
            end
        end
        updateOwner:SetScript("OnUpdate", updateOwner.fishingStatusTick)
    else
        updateOwner:SetScript("OnUpdate", nil)
        self.readinessElapsed = nil
    end
    if self.UpdateFishingInformation then self:UpdateFishingInformation(true) end
    local remaining = self:LureSeconds()
    local expires = remaining and remaining > 0 and GetTime() + remaining or nil
    if expires and (not self.lureTimerEnd or math.abs(expires - self.lureTimerEnd) > 2) then
        self.lureTimerEnd = expires
        if C_Timer and C_Timer.After then
            local token = expires
            C_Timer.After(remaining + 0.1, function()
                if self.lureTimerEnd == token then self:UpdateUI() end
            end)
        end
    elseif not expires then
        self.lureTimerEnd = nil
    end
    if not skipJournal and self.journalPanel and self.journalPanel:IsShown() then self:RefreshJournal() end
    if self.settingsPanel and self.settingsPanel:IsShown() then
        SetBindingLabel(self.settingsPanel.keyButton, self:GetFishingInputKey(), FF:LocalizedText("binding.display.unbound"))
        self:UpdateFishingKeyWarning(self.settingsPanel.keyButton,self:GetFishingInputKey())
    end
end

local function SettingsFont(parent, template, size, anchor, relative, relativeAnchor, x, y, value, color)
    local label = parent:CreateFontString(nil, "OVERLAY", template)
    local path, _, flags = label:GetFont()
    if path and size then label:SetFont(path, size, flags) end
    label:SetPoint(anchor, relative, relativeAnchor, x, y)
    label:SetText(value or "")
    if color then label:SetTextColor(unpack(color)) end
    return label
end

local function SettingsIcon(parent, path, size, x, y, fullTexture)
    local icon = parent:CreateTexture(nil, "ARTWORK")
    icon:SetSize(size, size)
    icon:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    icon:SetTexture(path)
    icon:SetTexCoord(fullTexture and 0 or 0.07, fullTexture and 1 or 0.93,
        fullTexture and 0 or 0.07, fullTexture and 1 or 0.93)
    if icon.AddMaskTexture and parent.CreateMaskTexture then
        local mask = parent:CreateMaskTexture(nil, "ARTWORK")
        mask:SetAllPoints(icon)
        mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        icon:AddMaskTexture(mask)
    end
    return icon
end

local function SettingsSection(panel, top, height)
    local section = CreateFrame("Frame", nil, panel)
    section:SetSize(500, height)
    section:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, top)
    local surface = section:CreateTexture(nil, "BACKGROUND")
    surface:SetAllPoints(section)
    surface:SetColorTexture(0.025, 0.075, 0.105, 0.92)
    OrnateBorder(section, 0, 16)
    return section
end

local function SettingsToggle(parent, y, label, tooltip, callback, tooltipOnly)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(466, 34)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 17, y)
    local surface = row:CreateTexture(nil, "BACKGROUND")
    surface:SetAllPoints(row)
    surface:SetColorTexture(0.075, 0.14, 0.18, 0.58)
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(row)
    highlight:SetColorTexture(0.20, 0.52, 0.58, 0.18)
    row:SetHighlightTexture(highlight)
    local box = CreateFrame("Frame", nil, row, BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetSize(21, 21)
    box:SetPoint("LEFT", row, "LEFT", 12, 0)
    box:EnableMouse(false)
    if box.SetBackdrop then
        box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 11 })
        box:SetBackdropColor(0.025, 0.055, 0.075, 1)
        box:SetBackdropBorderColor(0.75, 0.57, 0.31, 0.9)
    end
    local check = box:CreateTexture(nil, "OVERLAY")
    check:SetSize(25, 25)
    check:SetPoint("CENTER", box, "CENTER", 0, 1)
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetVertexColor(1, 0.77, 0.30)
    local title = SettingsFont(row, "GameFontHighlight", 15, "LEFT", box, "RIGHT", 14, 0, label, { 0.91, 0.91, 0.86 })
    local state = SettingsFont(row, "GameFontNormal", 15, "RIGHT", row, "RIGHT", -16, 0, "", { 0.91, 0.91, 0.86 })
    function row:SetState(enabled)
        check:SetShown(enabled == true)
        state:SetText(enabled == nil and "N/A" or (enabled and "On" or "Off"))
        state:SetTextColor(enabled and 0.97 or 0.72, enabled and 0.82 or 0.76, enabled and 0.39 or 0.78)
    end
    row:SetScript("OnClick", callback)
    row:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        if tooltipOnly then
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
        else
            GameTooltip:SetText(label)
            for line in tooltip:gmatch("[^\n]+") do
                GameTooltip:AddLine(line, 1, 1, 1, true)
            end
        end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return row
end

function FF:RefreshBackgroundSoundSetting()
    if not self.settingsPanel then return end
    local enabled = self:BackgroundSoundEnabled()
    self.settingsPanel.backgroundSoundButton:SetState(enabled)
end

function FF:RefreshSoundSettings()
    local panel = self.settingsPanel
    if not panel then return end
    for _, option in ipairs(panel.soundOptions) do
        if option.kind == "range" then
            option.title = self:RangeSoundTitle()
            option.titleText:SetText(option.title)
        end
        local selected = option.find(self.db[option.key]) or option.choices[1]
        option.button:SetText(selected.label)
        for _, entry in ipairs(option.rows) do entry.check:SetShown(entry.choice.id == selected.id) end
        if option.loopButton then option.loopButton:SetState(self.db[option.loopKey]) end
    end
    panel.updatingReminder = true
    panel.reminderSlider:SetValue(self.db.recastReminderDelay)
    panel.reminderValue:SetText(string.format("%d s", self.db.recastReminderDelay))
    local timing = self.recastReminderTiming
    panel.reminderSlider.fill:SetWidth(math.max(1, (self.db.recastReminderDelay - timing.min) / (timing.max - timing.min) * panel.reminderSlider:GetWidth()))
    panel.updatingReminder = false
    local enabled = self.db.recastReminderSound ~= "off"
    panel.reminderSlider:SetEnabled(enabled)
    panel.reminderSlider:SetAlpha(enabled and 1 or 0.35)
    panel.reminderLabel:SetTextColor(enabled and 0.93 or 0.48, enabled and 0.94 or 0.49, enabled and 0.92 or 0.48)
    panel.reminderValue:SetTextColor(enabled and 0.93 or 0.48, enabled and 0.94 or 0.49, enabled and 0.92 or 0.48)
    panel.updatingRepeat = true
    panel.repeatSlider:SetValue(self.db.soundRepeatInterval)
    panel.repeatValue:SetText(string.format("%g s", self.db.soundRepeatInterval))
    local repeatTiming = self.soundRepeatTiming
    panel.repeatSlider.fill:SetWidth(math.max(1, (self.db.soundRepeatInterval - repeatTiming.min) / (repeatTiming.max - repeatTiming.min) * panel.repeatSlider:GetWidth()))
    panel.updatingRepeat = false
    local repeatEnabled = self:NotificationRepeatEnabled()
    panel.repeatSlider:SetEnabled(repeatEnabled)
    panel.repeatSlider:SetAlpha(repeatEnabled and 1 or 0.35)
    panel.repeatLabel:SetTextColor(repeatEnabled and 0.93 or 0.48, repeatEnabled and 0.94 or 0.49, repeatEnabled and 0.92 or 0.48)
    panel.repeatValue:SetTextColor(repeatEnabled and 0.93 or 0.48, repeatEnabled and 0.94 or 0.49, repeatEnabled and 0.92 or 0.48)
    panel.updatingVoiceVolume = true
    panel.voiceVolumeSlider:SetValue(self.db.voiceVolume)
    panel.voiceVolumeValue:SetText(string.format("%d%%", self.db.voiceVolume))
    panel.voiceVolumeSlider.fill:SetWidth(math.max(1, self.db.voiceVolume / 100 * panel.voiceVolumeSlider:GetWidth()))
    panel.updatingVoiceVolume = false
end

function FF:RefreshCameraScanSetting()
    local panel = self.settingsPanel
    if not panel then return end
    panel.updatingCameraScan = true
    for _, row in ipairs(panel.cameraScanRows) do
        local option, value = row.option, self.db[row.option.key]
        local minimum, maximum = row.minimum, row.maximum
        local displayed = math.max(minimum, math.min(maximum, value))
        row.slider:SetValue(displayed)
        row.value:SetText(string.format(option.step < 1 and "%.2f %s" or "%d %s", value, option.unit))
        row.slider.fill:SetWidth(math.max(1, (displayed - minimum) / (maximum - minimum) * row.slider:GetWidth()))
    end
    panel.updatingCameraScan = false
end

function FF:RefreshFishingModeSetting()
    local panel = self.settingsPanel
    if panel then
        panel:RefreshTimingControls()
        self:RefreshSoundSettings()
    end
end

function FF:ShowSettings()
    if self.dataResetPendingReload then return self:Print(self:LocalizedText("reset.reload-needed")) end
    if self.fishingStartupFailed then return self:ReportFishingStartupFailure() end
    if self.ShowModernSettings then return self:ShowModernSettings() end
    if not self.settingsPanel then
        local panel = MakePanel("ForeverFishingSettings", 540, 946)
        if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "ForeverFishingSettings" end
        local brandIcon = panel:CreateTexture(nil, "ARTWORK")
        brandIcon:SetSize(62, 62)
        brandIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 22, -13)
        brandIcon:SetTexture(self.roundIcon)
        SettingsFont(panel, "GameFontNormalHuge", 26, "TOPLEFT", panel, "TOPLEFT", 96, -18, "Fishing settings", { 1, 0.81, 0.42 })
        SettingsFont(panel, "GameFontHighlight", 13, "TOPLEFT", panel, "TOPLEFT", 100, -54, "Forever Fishing /fish", { 0.82, 0.67, 0.43 })

        -- Keep the title, close control and reset footer fixed. Only the options
        -- scroll, using a plain ScrollFrame with no scrollbar or idle updates.
        local scroll = CreateFrame("ScrollFrame", nil, panel)
        scroll:SetSize(540, 812)
        scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -80)
        scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 54)
        scroll:EnableMouseWheel(true)
        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(540, 812)
        scroll:SetScrollChild(content)
        panel.optionsScroll, panel.optionsContent = scroll, content
        function panel:ClampSettingsScroll(value)
            local maximum = math.max(0, content:GetHeight() - scroll:GetHeight())
            scroll:SetVerticalScroll(math.max(0, math.min(maximum, value or scroll:GetVerticalScroll())))
        end
        function panel:RevealSettingsRange(top, height)
            local offset, visible = scroll:GetVerticalScroll(), scroll:GetHeight()
            if top < offset then self:ClampSettingsScroll(top - 6)
            elseif top + height > offset + visible then self:ClampSettingsScroll(top + height - visible + 6) end
        end
        scroll:SetScript("OnMouseWheel", function(_, delta)
            for _, option in ipairs(panel.soundOptions) do option.menu:Hide() end
            panel:ClampSettingsScroll(scroll:GetVerticalScroll() - delta * 44)
        end)
        scroll:SetScript("OnSizeChanged", function(_, width)
            content:SetWidth(width)
            panel:ClampSettingsScroll()
        end)
        scroll:SetScript("OnScrollRangeChanged", function() panel:ClampSettingsScroll() end)

        local keySection = SettingsSection(content, 0, 80)
        local keyIcon = SettingsIcon(keySection, "Interface\\Icons\\INV_Misc_Key_14", 29, 17, 0)
        keyIcon:ClearAllPoints()
        keyIcon:SetPoint("LEFT", keySection, "LEFT", 17, 0)
        SettingsFont(keySection, "GameFontNormal", 17, "LEFT", keySection, "LEFT", 56, 0, "Fishing key", { 1, 0.82, 0.47 })
        local bind = PlainButton(keySection, "", 225, 37, nil)
        bind:SetPoint("RIGHT", keySection, "RIGHT", -20, 8)
        OrnateBorder(bind, 0, 14)
        local bindFont = bind:GetFontString()
        local bindPath, _, bindFlags = bindFont:GetFont()
        if bindPath then bindFont:SetFont(bindPath, 18, bindFlags) end
        bind:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        bind:SetScript("OnClick", function(_, button)
            if button == "RightButton" then self:SetKey(nil) else self:BeginKeyCapture() end
        end)
        bind:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Fishing key")
            if self:GetFishingInputKey() then GameTooltip:AddLine(BindingDescription(self:GetFishingInputKey()), 1, 1, 1) end
            GameTooltip:AddLine("Click: Set binding", 1, 1, 1)
            GameTooltip:AddLine("Right click: Clear binding", 0.76, 0.82, 0.8)
            GameTooltip:Show()
        end)
        bind:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.keyButton = bind
        SettingsFont(keySection, "GameFontHighlight", 13, "TOP", bind, "BOTTOM", 0, -3, "click to bind", { 0.78, 0.81, 0.79 })

        local general = SettingsSection(content, -90, 392)
        SettingsIcon(general, self.settingsIcon, 29, 17, -9, true)
        SettingsFont(general, "GameFontNormal", 17, "TOPLEFT", general, "TOPLEFT", 56, -14, "General options", { 1, 0.82, 0.47 })
        panel.soundButton = SettingsToggle(general, -43, "Focus splash sound", "Make splashes easier to hear while fishing.\nMute music, ambience and dialogue.\nRestore your audio settings when the bar closes.", function(button)
            self.db.soundFocus = not self.db.soundFocus
            self:FocusSplashSound()
            button:SetState(self.db.soundFocus)
        end)
        panel.backgroundSoundButton = SettingsToggle(general, -77, "Sound in Background", "Keep WoW audio playing\nwhen the game is in the background.", function()
            local enabled = self:BackgroundSoundEnabled()
            if enabled == nil or not self:SetBackgroundSoundEnabled(not enabled) then
                self:Print("Blizzard's Sound in Background setting is unavailable on this client.")
            end
            self:RefreshBackgroundSoundSetting()
        end)
        panel.autoOpenButton = SettingsToggle(general, -111, "Auto Open", "Auto open fishing bar when fishing rod is equipped", function(button)
            self:SetFishingRodAutoOpen(not self.db.autoOpenFishingBar)
            button:SetState(self.db.autoOpenFishingBar)
        end)
        panel.fasterRecastButton = SettingsToggle(general, -145, self:LocalizedText("settings.faster-recast") .. "|cffffcc64*|r",
            self:LocalizedText("settings.faster-recast.help"), function(button)
                self:SetFasterRecast(not self:IsFasterRecastEnabled())
                button:SetState(self:IsFasterRecastEnabled())
            end, true)
        panel.hideLureGlowButton = SettingsToggle(general, -179, "Hide Lure Glow When Out of Lures", "Hide the lure glow when\nno lures are in your bags.", function(button)
            self.db.hideLureGlowWhenOutOfLures = not self.db.hideLureGlowWhenOutOfLures
            button:SetState(self.db.hideLureGlowWhenOutOfLures)
            self:RefreshSmartButtons()
        end)
        panel.autoEquipGearButton = SettingsToggle(general, -213, self:LocalizedText("settings.auto-equip-and-restore-gear"),
            self:LocalizedText("settings.auto-equip-and-restore-gear.help"), function(button)
                self:SetAutoEquipGear(not self.db.autoEquipGear)
                button:SetState(self.db.autoEquipGear)
            end)
        panel.autoEquipLuresButton = SettingsToggle(general, -247, "Auto Equip Lures", "Include selected lure use in the one-button fishing rotation.", function(button)
            self:SetAutoEquipLures(not self.db.autoEquipLures)
            button:SetState(self.db.autoEquipLures)
        end)
        SettingsFont(general, "GameFontNormal", 17, "TOPLEFT", general, "TOPLEFT", 17, -285,
            "Clean Fishing View", { 1, 0.82, 0.47 })
        panel.generalHideBlizzardUIWhileFishingButton = SettingsToggle(general, -315, "Hide Blizzard UI While Fishing",
            "Hide the Blizzard UI while fishing and restore its previous state when the bar closes.", function()
                self:SetHideBlizzardUIWhileFishing(not self.db.hideBlizzardUIWhileFishing)
        end)
        panel.generalCatchRecapButton = SettingsToggle(general, -349, "Catch Recap",
            "Briefly show items from successful fishing catches.", function()
                self:SetCatchRecapEnabled(not self.db.catchRecap)
        end)
        panel.generalCatchRecapRecommended = SettingsFont(panel.generalCatchRecapButton, "GameFontNormal", 13,
            "RIGHT", panel.generalCatchRecapButton, "RIGHT", -53, 0, "Recommended", { 0.45, 0.94, 0.55 })

        local soundSection = SettingsSection(content, -492, 48)
        local soundButton = CreateFrame("Button", nil, soundSection)
        soundButton:SetPoint("TOPLEFT")
        soundButton:SetPoint("TOPRIGHT")
        soundButton:SetHeight(47)
        local soundHighlight = soundButton:CreateTexture(nil, "HIGHLIGHT")
        soundHighlight:SetAllPoints(soundButton)
        soundHighlight:SetColorTexture(0.22, 0.45, 0.52, 0.14)
        soundButton:SetHighlightTexture(soundHighlight)
        local speaker = soundButton:CreateTexture(nil, "ARTWORK")
        speaker:SetSize(29, 29)
        speaker:SetPoint("TOPLEFT", soundButton, "TOPLEFT", 17, -9)
        speaker:SetTexture("Interface\\Common\\VoiceChat-Speaker")
        speaker:SetVertexColor(1, 0.80, 0.44)
        SettingsFont(soundButton, "GameFontNormal", 17, "LEFT", soundButton, "LEFT", 56, 0, "Notification Sounds", { 1, 0.82, 0.47 })
        panel.soundCaret = AddCaret(soundButton, -13)
        soundButton:SetScript("OnClick", function() panel:SetSoundExpanded(not panel.soundExpanded) end)
        local sound = CreateFrame("Frame", nil, soundSection)
        sound:SetSize(500, 501)
        sound:SetPoint("TOPLEFT", soundSection, "TOPLEFT")
        sound:Hide()
        panel.soundPanel = sound
        panel.soundOptions = {}
        local function SoundOption(title, key, kind, loopKey, y)
            local choices = self.rangeSoundChoices
            local find = function(id) return self:RangeSoundChoice(id) end
            local selectSound = function(id) self:SetFishingSound(kind, id) end
            local previewSound = function(id) self:PreviewFishingSound(kind, id) end
            local titleText = SettingsFont(sound, "GameFontHighlight", 15, "TOPLEFT", sound, "TOPLEFT", 19, y,
                title, { 0.93, 0.94, 0.92 })
            local loop = loopKey and CreateFrame("Button", nil, sound)
            if loop then
            loop:SetSize(138, 25)
            loop:SetPoint("TOPRIGHT", sound, "TOPRIGHT", -17, y + 4)
            local box = loop:CreateTexture(nil, "ARTWORK")
            box:SetSize(23, 23)
            box:SetPoint("LEFT", loop, "LEFT", 0, 0)
            box:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
            local check = loop:CreateTexture(nil, "OVERLAY")
            check:SetSize(23, 23)
            check:SetPoint("CENTER", box, "CENTER")
            check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            check:SetVertexColor(1, 0.77, 0.30)
            SettingsFont(loop, "GameFontHighlight", 14, "LEFT", box, "RIGHT", 6, 0, "Repeat Sound", { 0.91, 0.91, 0.86 })
            function loop:SetState(enabled) check:SetShown(enabled == true) end
            loop:SetScript("OnClick", function()
                self:SetFishingSoundLoop(kind, not self.db[loopKey])
                self:RefreshSoundSettings()
            end)
            loop:SetScript("OnEnter", function(control)
                GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
                local reason = kind == "range" and (self.db.cameraAssist
                    and "the cursor returns to the box or scanning ends." or "the cast is corrected.") or "you cast again."
                local choice = self:RangeSoundChoice(self.db[key])
                local delay = self:SoundRepeatDelay(choice)
                GameTooltip:SetText(string.format("Repeat every %g seconds until %s", delay, reason))
                if delay > self.db.soundRepeatInterval then
                    GameTooltip:AddLine("Long voice lines finish before repeating.", 0.76, 0.82, 0.8)
                end
                GameTooltip:Show()
            end)
            loop:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
            local button = CreateFrame("Button", nil, sound)
            button:SetSize(386, 36)
            button:SetPoint("TOPLEFT", sound, "TOPLEFT", 18, y - 24)
            StyleButton(button, nil)
            OrnateBorder(button, 0, 14)
            local text = SettingsFont(button, "GameFontHighlight", 15, "LEFT", button, "LEFT", 15, 0, "", { 0.94, 0.95, 0.93 })
            button:SetFontString(text)
            AddCaret(button, -8)
            local menu = CreateFrame("Frame", nil, content)
            menu:SetSize(386, #choices * 29 + 8)
            menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -3)
            menu:SetFrameLevel(panel:GetFrameLevel() + 40)
            menu:EnableMouse(true)
            Backdrop(menu)
            OrnateBorder(menu, 0, 13)
            local option = { key = key, kind = kind, title = title, titleText = titleText,
                choices = choices, find = find, button = button, menu = menu, rows = {}, loopButton = loop, loopKey = loopKey }
            panel.soundOptions[#panel.soundOptions + 1] = option
            button:SetScript("OnClick", function()
                local show = not menu:IsShown()
                for _, entry in ipairs(panel.soundOptions) do entry.menu:Hide() end
                menu:SetShown(show)
                if show then panel:RevealSettingsRange(356 - y + 63, menu:GetHeight()) end
            end)
            local preview = PlainButton(sound, nil, 60, 36, function() previewSound(self.db[key]) end)
            preview:SetPoint("LEFT", button, "RIGHT", 13, 0)
            OrnateBorder(preview, 0, 14)
            local icon = preview:CreateTexture(nil, "ARTWORK")
            icon:SetSize(28, 28)
            icon:SetPoint("CENTER")
            icon:SetTexture("Interface\\Common\\VoiceChat-Speaker")
            icon:SetVertexColor(1, 0.80, 0.44)
            preview:SetScript("OnEnter", function(control)
                GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
                local selected = self:RangeSoundChoice(self.db[key])
                local both = selected and selected.voice and not (kind == "range" and selected.singleRangePreview)
                GameTooltip:SetText(both and "Preview both " .. option.title:lower() .. " voice lines"
                    or "Preview " .. option.title:lower())
                GameTooltip:Show()
            end)
            preview:SetScript("OnLeave", function() GameTooltip:Hide() end)
            option.preview = preview
            for index, choice in ipairs(choices) do
                local row = PlainButton(menu, choice.label, 374, 27, function()
                    selectSound(choice.id)
                    menu:Hide()
                    self:RefreshSoundSettings()
                    previewSound(choice.id)
                end)
                row:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, -5 - (index - 1) * 29)
                local label = row:GetFontString()
                label:ClearAllPoints()
                label:SetPoint("LEFT", row, "LEFT", 32, 0)
                label:SetJustifyH("LEFT")
                local check = row:CreateTexture(nil, "OVERLAY")
                check:SetSize(19, 19)
                check:SetPoint("LEFT", row, "LEFT", 7, 0)
                check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                check:SetVertexColor(1, 0.80, 0.44)
                option.rows[#option.rows + 1] = { button = row, choice = choice, check = check }
            end
            menu:Hide()
        end
        SoundOption("Out of range sound", "rangeSound", "range", "rangeSoundLoop", -47)
        SoundOption("Catch confirmed sound", "catchConfirmedSound", "catch", nil, -124)
        SoundOption("Recast reminder sound", "recastReminderSound", "recast", "recastReminderLoop", -201)
        panel.reminderLabel = SettingsFont(sound, "GameFontHighlight", 15, "TOPLEFT", sound, "TOPLEFT", 19, -283,
            "Idle player recast reminder delay", { 0.93, 0.94, 0.92 })
        panel.reminderValue = SettingsFont(sound, "GameFontHighlight", 14, "TOPRIGHT", sound, "TOPRIGHT", -19, -283,
            "", { 0.93, 0.94, 0.92 })
        local reminderTiming = self.recastReminderTiming
        panel.reminderSlider = TimingSlider(sound, 24, -317, 454, reminderTiming.min, reminderTiming.max, reminderTiming.step)
        panel.reminderSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingReminder or self.db.recastReminderSound == "off" then return end
            self:SetRecastReminderDelay(value)
            self:RefreshSoundSettings()
        end)
        panel.reminderSlider:SetScript("OnEnter", function(control)
            GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.db.recastReminderSound == "off" and "Choose a recast reminder sound to adjust its delay." or "Remind me after this many seconds without a bobber.")
            GameTooltip:AddLine("Only while the fishing bar is open.", 0.76, 0.82, 0.8)
            GameTooltip:Show()
        end)
        panel.reminderSlider:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.repeatLabel = SettingsFont(sound, "GameFontHighlight", 15, "TOPLEFT", sound, "TOPLEFT", 19, -347,
            "Repeat interval", { 0.93, 0.94, 0.92 })
        panel.repeatValue = SettingsFont(sound, "GameFontHighlight", 14, "TOPRIGHT", sound, "TOPRIGHT", -19, -347,
            "", { 0.93, 0.94, 0.92 })
        local repeatTiming = self.soundRepeatTiming
        panel.repeatSlider = TimingSlider(sound, 24, -381, 454, repeatTiming.min, repeatTiming.max, repeatTiming.step)
        panel.repeatSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingRepeat or not self:NotificationRepeatEnabled() then return end
            self:SetSoundRepeatInterval(value)
            self:RefreshSoundSettings()
        end)
        panel.repeatSlider:SetScript("OnEnter", function(control)
            GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
            GameTooltip:SetText(self:NotificationRepeatEnabled() and "Time between repeated notification sounds."
                or "Turn on Repeat Sound to adjust the interval.")
            GameTooltip:Show()
        end)
        panel.repeatSlider:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.voiceVolumeLabel = SettingsFont(sound, "GameFontHighlight", 15, "TOPLEFT", sound, "TOPLEFT", 19, -414,
            "Voice volume", { 0.93, 0.94, 0.92 })
        panel.voiceVolumeValue = SettingsFont(sound, "GameFontHighlight", 14, "TOPRIGHT", sound, "TOPRIGHT", -19, -414,
            "", { 0.93, 0.94, 0.92 })
        local voiceVolumeTiming = self.voiceVolumeTiming
        panel.voiceVolumeSlider = TimingSlider(sound, 24, -448, 454, voiceVolumeTiming.min, voiceVolumeTiming.max, voiceVolumeTiming.step)
        panel.voiceVolumeSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingVoiceVolume then return end
            self:SetVoiceVolume(value)
            self:RefreshSoundSettings()
        end)
        panel.voiceVolumeSlider:SetScript("OnEnter", function(control)
            GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
            GameTooltip:SetText("Volume for Forever Fishing voice options only.")
            GameTooltip:Show()
        end)
        panel.voiceVolumeSlider:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel:SetScript("OnHide", function()
            for _, option in ipairs(panel.soundOptions) do option.menu:Hide() end
            self:StopFishingSoundPreview()
        end)

        local scanSection = SettingsSection(content, -550, 48)
        scanSection:ClearAllPoints()
        scanSection:SetPoint("TOPLEFT", soundSection, "BOTTOMLEFT", 0, -10)
        local scanButton = CreateFrame("Button", nil, scanSection)
        scanButton:SetPoint("TOPLEFT")
        scanButton:SetPoint("TOPRIGHT")
        scanButton:SetHeight(47)
        local highlight = scanButton:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(scanButton)
        highlight:SetColorTexture(0.22, 0.45, 0.52, 0.14)
        scanButton:SetHighlightTexture(highlight)
        SettingsIcon(scanButton, "Interface\\Icons\\Ability_Hunter_EagleEye", 29, 17, -9)
        SettingsFont(scanButton, "GameFontNormal", 17, "LEFT", scanButton, "LEFT", 56, 0, "Scan settings", { 1, 0.82, 0.47 })
        panel.scanSettingsCaret = AddCaret(scanButton, -13)
        scanButton:SetScript("OnClick", function() panel:SetScanSettingsExpanded(not panel.scanSettingsExpanded) end)
        local scan = CreateFrame("Frame", nil, scanSection)
        local settingsOptions = {}
        for _, option in ipairs(self.scanTuning) do
            if not option.developerOnly then settingsOptions[#settingsOptions + 1] = option end
        end
        local scanHeight = 24 + #settingsOptions * 54
        scan:SetSize(500, scanHeight)
        scan:SetPoint("TOPLEFT", scanSection, "TOPLEFT", 0, -48)
        scan:Hide()
        panel.scanSettingsPanel = scan
        panel.scanSettingsHeight = scanHeight
        panel.cameraScanRows = {}
        for index, option in ipairs(settingsOptions) do
            local minimum, maximum = option.settingsMin or option.min, option.settingsMax or option.max
            local row = CreateFrame("Frame", nil, scan)
            row:SetSize(500, 54)
            row:SetPoint("TOPLEFT", scan, "TOPLEFT", 0, -12 - (index - 1) * 54)
            SettingsFont(row, "GameFontHighlight", 15, "TOPLEFT", row, "TOPLEFT", 20, 0,
                option.label, { 0.93, 0.94, 0.92 })
            local value = SettingsFont(row, "GameFontHighlight", 14, "TOPRIGHT", row, "TOPRIGHT", -19, 0,
                "", { 0.93, 0.94, 0.92 })
            local slider = TimingSlider(row, 24, -26, 454, minimum, maximum, option.step)
            slider:SetScript("OnValueChanged", function(_, nextValue)
                if panel.updatingCameraScan then return end
                nextValue = math.max(minimum, math.min(maximum, nextValue))
                self.db[option.key] = math.floor(nextValue / option.step + 0.5) * option.step
                self:SaveCameraScanProfile()
                self:RefreshCameraScanSetting()
            end)
            slider:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(option.label)
                GameTooltip:AddLine(option.note, 1, 1, 1, true)
                GameTooltip:AddLine("Applies to the next scan.", 0.76, 0.82, 0.8)
                GameTooltip:Show()
            end)
            slider:SetScript("OnLeave", function() GameTooltip:Hide() end)
            panel.cameraScanRows[#panel.cameraScanRows + 1] = { slider = slider, value = value, option = option, minimum = minimum, maximum = maximum }
        end

        local experimentalHeight = 122
        local experimentalSection = SettingsSection(content, -608, 48)
        experimentalSection:ClearAllPoints()
        experimentalSection:SetPoint("TOPLEFT", scanSection, "BOTTOMLEFT", 0, -10)
        local experimentalButton = CreateFrame("Button", nil, experimentalSection)
        experimentalButton:SetPoint("TOPLEFT")
        experimentalButton:SetPoint("TOPRIGHT")
        experimentalButton:SetHeight(47)
        local experimentalHighlight = experimentalButton:CreateTexture(nil, "HIGHLIGHT")
        experimentalHighlight:SetAllPoints(experimentalButton)
        experimentalHighlight:SetColorTexture(0.22, 0.45, 0.52, 0.14)
        experimentalButton:SetHighlightTexture(experimentalHighlight)
        SettingsIcon(experimentalButton, "Interface\\Icons\\Trade_Alchemy", 29, 17, -9)
        SettingsFont(experimentalButton, "GameFontNormal", 17, "LEFT", experimentalButton, "LEFT", 56, 0,
            "Experimental", { 1, 0.82, 0.47 })
        panel.experimentalCaret = AddCaret(experimentalButton, -13)
        experimentalButton:SetScript("OnClick", function() panel:SetExperimentalExpanded(not panel.experimentalExpanded) end)
        local experimental = CreateFrame("Frame", nil, experimentalSection)
        experimental:SetSize(500, experimentalHeight)
        experimental:SetPoint("TOPLEFT", experimentalSection, "TOPLEFT", 0, -48)
        experimental:Hide()
        panel.experimentalPanel = experimental
        panel.fastNativeAutoLootButton = SettingsToggle(experimental, -5, self:LocalizedText("settings.fast-native-auto-loot"),
            self:LocalizedText("settings.fast-native-auto-loot.help"), function(button)
                self:SetFastNativeAutoLoot(not self:IsFastNativeAutoLootEnabled())
                button:SetState(self:IsFastNativeAutoLootEnabled())
            end, true)
        panel.hideBlizzardUIWhileFishingButton = SettingsToggle(experimental, -39, "Hide Blizzard UI While Fishing",
            "Hide the main game UI while the Fishing bar is open.\nShowing your UI manually keeps it visible until the bar closes.\nOther addon windows attached to the game UI may also hide.", function()
                self:SetHideBlizzardUIWhileFishing(not self.db.hideBlizzardUIWhileFishing)
            end)
        panel.catchRecapButton = SettingsToggle(experimental, -73, "Catch Recap",
            "Briefly show the items from a confirmed fishing catch. Useful when the Blizzard UI is hidden.", function()
                self:SetCatchRecapEnabled(not self.db.catchRecap)
            end)
        panel.catchRecapRecommended = SettingsFont(panel.catchRecapButton, "GameFontNormal", 13,
            "RIGHT", panel.catchRecapButton, "RIGHT", -53, 0, "Recommended", { 0.45, 0.94, 0.55 })
        local advancedSection = SettingsSection(content, -666, 48)
        advancedSection:ClearAllPoints()
        advancedSection:SetPoint("TOPLEFT", experimentalSection, "BOTTOMLEFT", 0, -10)
        local advancedButton = CreateFrame("Button", nil, advancedSection)
        advancedButton:SetPoint("TOPLEFT")
        advancedButton:SetPoint("TOPRIGHT")
        advancedButton:SetHeight(47)
        local advancedHighlight = advancedButton:CreateTexture(nil, "HIGHLIGHT")
        advancedHighlight:SetAllPoints(advancedButton)
        advancedHighlight:SetColorTexture(0.22, 0.45, 0.52, 0.14)
        advancedButton:SetHighlightTexture(advancedHighlight)
        SettingsIcon(advancedButton, "Interface\\Icons\\INV_Misc_PocketWatch_01", 29, 17, -9)
        SettingsFont(advancedButton, "GameFontNormal", 17, "LEFT", advancedButton, "LEFT", 56, 0, "Advanced timing", { 1, 0.82, 0.47 })
        panel.advancedCaret = AddCaret(advancedButton, -13)
        advancedButton:SetScript("OnClick", function() panel:SetAdvancedExpanded(not panel.advancedExpanded) end)
        panel.advancedButton = advancedButton
        local advanced = CreateFrame("Frame", nil, advancedSection)
        advanced:SetSize(500, 240)
        advanced:SetPoint("TOPLEFT", advancedSection, "TOPLEFT", 0, -48)
        advanced:Hide()
        panel.advancedPanel = advanced
        panel.advancedHeight = 240
        SettingsFont(advanced, "GameFontNormal", 15, "TOPLEFT", advanced, "TOPLEFT", 18, -5, "Cast timing", { 0.29, 0.84, 0.9 })
        local timingRule = advanced:CreateTexture(nil, "BORDER")
        timingRule:SetPoint("TOPLEFT", advanced, "TOPLEFT", 137, -16)
        timingRule:SetPoint("TOPRIGHT", advanced, "TOPRIGHT", -18, -16)
        timingRule:SetHeight(1)
        timingRule:SetColorTexture(0.19, 0.65, 0.73, 0.6)
        local function TimingRow(label, y, minimum, maximum, step)
            local row = CreateFrame("Frame", nil, advanced)
            row:SetSize(500, 47)
            row:SetPoint("TOPLEFT", advanced, "TOPLEFT", 0, y)
            local title = SettingsFont(row, "GameFontHighlight", 15, "TOPLEFT", row, "TOPLEFT", 22, 0, label, { 0.93, 0.94, 0.92 })
            local value = SettingsFont(row, "GameFontHighlight", 14, "TOPRIGHT", row, "TOPRIGHT", -19, 0, "", { 0.93, 0.94, 0.92 })
            local slider = TimingSlider(row, 24, -23, 378, minimum, maximum, step)
            return slider, value, row, title
        end
        panel.rangeSlider, panel.rangeValue, panel.rangeTimingRow = TimingRow("Too far warning delay", -32, self.timing.rangeMin, self.timing.rangeMax, 0.05)
        panel.recastSlider, panel.recastValue, panel.recastTimingRow, panel.recastTimingLabel = TimingRow("Good cast recast delay", -79, self.timing.recastMin, self.timing.recastMax)
        panel.hookSlider, panel.hookValue, panel.hookTimingRow = TimingRow("Hook key delay", -126, self.timing.hookMin, self.timing.hookMax)
        panel.pressSlider, panel.pressValue, panel.pressTimingRow = TimingRow("Rapid press lock (0 = off)", -173, self.timing.pressMin, self.timing.pressMax, 0.05)
        local timingNote = SettingsFont(advanced, "GameFontHighlight", 13, "TOPLEFT", advanced, "TOPLEFT", 22, -221,
            "Delays start when a cast begins.", { 0.79, 0.84, 0.83 })
        function panel:RefreshTimingControls()
            local camera = FF.db.cameraAssist
            self.rangeTimingRow:SetShown(not camera)
            self.pressTimingRow:Hide()
            self.recastTimingLabel:SetText(camera and "Recast delay" or "Good cast recast delay")
            self.recastTimingRow:ClearAllPoints()
            self.recastTimingRow:SetPoint("TOPLEFT", advanced, "TOPLEFT", 0, camera and -32 or -79)
            self.hookTimingRow:ClearAllPoints()
            self.hookTimingRow:SetPoint("TOPLEFT", advanced, "TOPLEFT", 0, camera and -79 or -126)
            timingNote:ClearAllPoints()
            timingNote:SetPoint("TOPLEFT", advanced, "TOPLEFT", 22, camera and -127 or -221)
            local height = camera and 146 or 240
            if self.advancedHeight ~= height then
                self.advancedHeight = height
                advanced:SetHeight(height)
                advancedSection:SetHeight(48 + (self.advancedExpanded and height or 0))
                self:RefreshExpandedHeight()
            end
            self.updatingTiming = true
            self.rangeSlider:SetValue(FF.db.rangeDelay)
            self.recastSlider:SetValue(FF.db.recastDelay)
            self.hookSlider:SetValue(FF.db.hookDelay)
            self.pressSlider:SetValue(FF.db.pressLock)
            self.rangeValue:SetText(string.format("%.2f s", FF.db.rangeDelay))
            self.recastValue:SetText(string.format("%.1f s", FF.db.recastDelay))
            self.hookValue:SetText(string.format("%.1f s", FF.db.hookDelay))
            self.pressValue:SetText(string.format("%.2f s", FF.db.pressLock))
            self.rangeSlider.fill:SetWidth(math.max(1, (FF.db.rangeDelay - FF.timing.rangeMin) / (FF.timing.rangeMax - FF.timing.rangeMin) * self.rangeSlider:GetWidth()))
            self.recastSlider.fill:SetWidth(math.max(1, (FF.db.recastDelay - FF.timing.recastMin) / (FF.timing.recastMax - FF.timing.recastMin) * self.recastSlider:GetWidth()))
            self.hookSlider.fill:SetWidth(math.max(1, (FF.db.hookDelay - FF.timing.hookMin) / (FF.timing.hookMax - FF.timing.hookMin) * self.hookSlider:GetWidth()))
            self.pressSlider.fill:SetWidth(math.max(1, (FF.db.pressLock - FF.timing.pressMin) / (FF.timing.pressMax - FF.timing.pressMin) * self.pressSlider:GetWidth()))
            self.updatingTiming = false
        end
        function panel:RefreshExpandedHeight()
            content:SetHeight(714 + (self.soundExpanded and 453 or 0) + (self.scanSettingsExpanded and self.scanSettingsHeight or 0) + (self.experimentalExpanded and experimentalHeight or 0) + (self.advancedExpanded and (self.advancedHeight or 240) or 0))
            scroll:UpdateScrollChildRect()
            self:ClampSettingsScroll()
        end
        function panel:SetSoundExpanded(expanded)
            self.soundExpanded = expanded
            self.soundPanel:SetShown(expanded)
            self.soundCaret:SetDirection(expanded)
            soundSection:SetHeight(expanded and 501 or 48)
            if not expanded then
                for _, option in ipairs(self.soundOptions) do option.menu:Hide() end
                FF:StopFishingSoundPreview()
            end
            self:RefreshExpandedHeight()
            if expanded then self:RevealSettingsRange(492, soundSection:GetHeight()) end
        end
        function panel:SetScanSettingsExpanded(expanded)
            self.scanSettingsExpanded = expanded
            self.scanSettingsPanel:SetShown(expanded)
            self.scanSettingsCaret:SetDirection(expanded)
            scanSection:SetHeight(48 + (expanded and self.scanSettingsHeight or 0))
            self:RefreshExpandedHeight()
            if expanded then self:RevealSettingsRange(550 + (self.soundExpanded and 453 or 0), scanSection:GetHeight()) end
        end
        function panel:SetExperimentalExpanded(expanded)
            self.experimentalExpanded = expanded
            self.experimentalPanel:SetShown(expanded)
            self.experimentalCaret:SetDirection(expanded)
            experimentalSection:SetHeight(expanded and 48 + experimentalHeight or 48)
            self:RefreshExpandedHeight()
            if expanded then
                self:RevealSettingsRange(608 + (self.soundExpanded and 453 or 0) + (self.scanSettingsExpanded and self.scanSettingsHeight or 0), experimentalSection:GetHeight())
            end
        end
        function panel:SetAdvancedExpanded(expanded)
            self.advancedExpanded = expanded
            self.advancedPanel:SetShown(expanded)
            self.advancedCaret:SetDirection(expanded)
            advancedSection:SetHeight(48 + (expanded and (self.advancedHeight or 240) or 0))
            self:RefreshExpandedHeight()
            if expanded then
                self:RevealSettingsRange(666 + (self.soundExpanded and 453 or 0) + (self.scanSettingsExpanded and self.scanSettingsHeight or 0) + (self.experimentalExpanded and experimentalHeight or 0), advancedSection:GetHeight())
            end
        end
        panel.rangeSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingTiming or self.db.cameraAssist then return end
            self.db.rangeDelay = math.floor(value * 20 + 0.5) / 20
            self:SaveTimingProfile()
            panel:RefreshTimingControls()
        end)
        panel.recastSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingTiming then return end
            self.db.recastDelay = math.floor(value * 10 + 0.5) / 10
            self:SaveTimingProfile()
            panel:RefreshTimingControls()
        end)
        panel.hookSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingTiming then return end
            self.db.hookDelay = math.floor(value * 10 + 0.5) / 10
            self:SaveTimingProfile()
            panel:RefreshTimingControls()
        end)
        panel.pressSlider:SetScript("OnValueChanged", function(_, value)
            if panel.updatingTiming or self.db.cameraAssist then return end
            self.db.pressLock = math.floor(value * 20 + 0.5) / 20
            self:SaveTimingProfile()
            panel:RefreshTimingControls()
        end)
        local footerRule = panel:CreateTexture(nil, "BORDER")
        footerRule:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 24, 54)
        footerRule:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 54)
        footerRule:SetHeight(1)
        footerRule:SetColorTexture(0.66, 0.47, 0.25, 0.6)
        local reset = PlainButton(panel, "Reset to defaults", 186, 36, function()
            self:ShowSettingsResetConfirmation()
        end)
        reset:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
        reset.surface:SetColorTexture(0.055, 0.115, 0.15, 0.98)
        OrnateBorder(reset, 0, 14)
        local resetFont = reset:GetFontString()
        local resetPath, _, resetFlags = resetFont:GetFont()
        if resetPath then resetFont:SetFont(resetPath, 15, resetFlags) end
        resetFont:SetTextColor(1, 0.82, 0.48)
        reset:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Reset fishing settings")
            GameTooltip:AddLine("Restores the key, options, sound and timing.", 1, 1, 1)
            GameTooltip:AddLine("Records, layouts and WoW audio stay as set.", 0.76, 0.82, 0.8)
            GameTooltip:Show()
        end)
        reset:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.resetButton = reset
        panel:SetSoundExpanded(false)
        panel:SetScanSettingsExpanded(false)
        panel:SetExperimentalExpanded(false)
        panel:SetAdvancedExpanded(false)
        self:PrepareFloatingWindow(panel, "settings", panel)
        self.settingsPanel = panel
    end
    SetBindingLabel(self.settingsPanel.keyButton, self:GetFishingInputKey(), FF:LocalizedText("binding.display.unbound"))
    self:UpdateFishingKeyWarning(self.settingsPanel.keyButton,self:GetFishingInputKey())
    self.settingsPanel:RefreshTimingControls()
    self.settingsPanel.soundButton:SetState(self.db.soundFocus)
    self.settingsPanel.autoOpenButton:SetState(self.db.autoOpenFishingBar)
    self.settingsPanel.hideLureGlowButton:SetState(self.db.hideLureGlowWhenOutOfLures)
    self.settingsPanel.autoEquipGearButton:SetState(self.db.autoEquipGear)
    self.settingsPanel.autoEquipLuresButton:SetState(self.db.autoEquipLures)
    self.settingsPanel.fasterRecastButton:SetState(self:IsFasterRecastEnabled())
    self.settingsPanel.fastNativeAutoLootButton:SetState(self:IsFastNativeAutoLootEnabled())
    self.settingsPanel.hideBlizzardUIWhileFishingButton:SetState(self.db.hideBlizzardUIWhileFishing)
    self.settingsPanel.generalHideBlizzardUIWhileFishingButton:SetState(self.db.hideBlizzardUIWhileFishing)
    self:RefreshCatchRecapSetting()
    self:RefreshFishingModeSetting()
    self:RefreshCameraScanSetting()
    self:RefreshBackgroundSoundSetting()
    self:RefreshSoundSettings()
    self:ShowFloatingWindow(self.settingsPanel)
end

function FF:ShowCameraDeveloper()
    if not self.scanDevPanel then
        local panel = MakePanel("ForeverFishingScanDeveloper", 1050, 740)
        SettingsFont(panel, "GameFontNormalHuge", 25, "TOPLEFT", panel, "TOPLEFT", 25, -20,
            "Fishing camera development /fish dev", { 1, 0.81, 0.42 })
        SettingsFont(panel, "GameFontHighlight", 13, "TOPLEFT", panel, "TOPLEFT", 27, -52,
            "Adjust the Sweep view and coverage. Settings apply to the next scan; statistics last this session.", { 0.8, 0.84, 0.83 })
        local buttons = {}
        local function OptionButton(x, y, callback)
            local button = PlainButton(panel, "", 318, 31, callback)
            button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
            OrnateBorder(button, 0, 13)
            return button
        end
        buttons.assist = OptionButton(25, -76, function()
            self:SetCameraAssistEnabled(not self.db.cameraAssist)
            panel:RefreshControls()
        end)
        panel.recastModeButton = buttons.assist
        buttons.assist:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Camera-assisted backup")
            GameTooltip:AddLine("Experimental backup for problems reaching a bobber with the normal fishing key. Normally leave it disabled; scanning may not work with the latest client.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        buttons.assist:SetScript("OnLeave", function() GameTooltip:Hide() end)
        buttons.logging = OptionButton(365, -76, function()
            self.db.cameraScanLogging = not self.db.cameraScanLogging
            panel:RefreshControls()
        end)
        local profileButton = OptionButton(705, -76)
        AddCaret(profileButton, -8)
        local profileMenu = CreateFrame("Frame", nil, panel)
        profileMenu:SetSize(318, #self.cameraScanProfileOptions * 34 + 10)
        profileMenu:SetPoint("TOPLEFT", profileButton, "BOTTOMLEFT", 0, -3)
        profileMenu:SetFrameLevel(panel:GetFrameLevel() + 40)
        profileMenu:EnableMouse(true)
        Backdrop(profileMenu)
        OrnateBorder(profileMenu, 0, 13)
        panel.cameraProfileRows = {}
        for index, option in ipairs(self.cameraScanProfileOptions) do
            local row = PlainButton(profileMenu, option.label, 306, 32, function()
                profileMenu:Hide()
                self:SetCameraScanProfile(option.id)
            end)
            row:SetPoint("TOPLEFT", profileMenu, "TOPLEFT", 6, -5 - (index - 1) * 34)
            panel.cameraProfileRows[#panel.cameraProfileRows + 1] = { button = row, option = option }
        end
        profileButton:SetScript("OnClick", function() profileMenu:SetShown(not profileMenu:IsShown()) end)
        profileMenu:Hide()
        panel.cameraProfileButton = profileButton
        panel.cameraProfileMenu = profileMenu
        buttons.rounded = OptionButton(25, -117, function()
            self:SetCameraScanShape("rounded", not self.db.cameraRoundedTurns)
        end)
        panel.roundedTurnsButton = buttons.rounded
        buttons.pyramid = OptionButton(365, -117, function()
            self:SetCameraScanShape("pyramid", not self.db.cameraPyramidPath)
        end)
        panel.pyramidPathButton = buttons.pyramid
        buttons.racetrack = OptionButton(705, -117, function()
            self:SetCameraScanShape("racetrack", not self.db.cameraRacetrackTurns)
        end)
        panel.racetrackTurnsButton = buttons.racetrack
        buttons.racetrack:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Racetrack turns")
            GameTooltip:AddLine("Rounds the ends of each scan line. Works with Pyramid widening and the current scan settings. Applies to the next scan.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        buttons.racetrack:SetScript("OnLeave", function() GameTooltip:Hide() end)
        buttons.savedView = OptionButton(25, -158, function()
            self.db.cameraSavedView = not self.db.cameraSavedView
            self:SaveCameraScanProfile()
            self:ReleaseFishingViewBlend()
            panel:RefreshControls()
        end)
        panel.savedViewButton = buttons.savedView
        buttons.savedView:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Saved fishing view (test)")
            GameTooltip:AddLine("Keep the prepared angle and zoom after movement and reload. Replaces the selected camera preset. A new view needs one automatic preparation. Off uses the existing method.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        buttons.savedView:SetScript("OnLeave", function() GameTooltip:Hide() end)
        buttons.rebuildView = OptionButton(365, -158, function()
            self:ResetSmartCameraAdjustment("Rebuild requested; base preset 4", true)
            self:InvalidateSavedFishingView("Rebuild requested; next scan prepares a new view")
            panel:RefreshControls()
        end)
        buttons.rebuildView:SetText("Rebuild fishing view")
        buttons.rebuildView:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Rebuild fishing view")
            GameTooltip:AddLine("Prepare and save a new view on the next scan, using Camera tilt and Zoom distance.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        buttons.rebuildView:SetScript("OnLeave", function() GameTooltip:Hide() end)
        buttons.smart = OptionButton(705, -158, function()
            self:SetSmartCameraAdjustment(not self.db.cameraSmartAdjustment)
        end)
        panel.smartCameraButton = buttons.smart
        buttons.smart:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Smart camera adjustment")
            GameTooltip:AddLine("Adjusts the starting camera tilt after bobber detection to improve scan efficiency across changes in fishing height", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        buttons.smart:SetScript("OnLeave", function() GameTooltip:Hide() end)
        SettingsFont(panel, "GameFontHighlight", 14, "TOPLEFT", panel, "TOPLEFT", 29, -210,
            "Cursor marker", { 0.93, 0.94, 0.92 })
        local markerButton = PlainButton(panel, nil, 348, 34, nil)
        markerButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 165, -198)
        OrnateBorder(markerButton, 0, 13)
        local markerPreview = markerButton:CreateTexture(nil, "ARTWORK")
        markerPreview:SetSize(26, 26)
        markerPreview:SetPoint("LEFT", markerButton, "LEFT", 8, 0)
        markerPreview:SetTexCoord(0, 1, 0, 1)
        local markerText = SettingsFont(markerButton, "GameFontHighlight", 14, "LEFT", markerButton, "LEFT", 42, 0,
            "", { 0.94, 0.95, 0.93 })
        markerText:SetWidth(265)
        markerText:SetJustifyH("LEFT")
        AddCaret(markerButton, -8)
        local markerMenu = CreateFrame("Frame", nil, panel)
        markerMenu:SetSize(348, #self.cameraMarkerOptions * 36 + 10)
        markerMenu:SetPoint("TOPLEFT", markerButton, "BOTTOMLEFT", 0, -3)
        markerMenu:SetFrameLevel(panel:GetFrameLevel() + 40)
        markerMenu:EnableMouse(true)
        Backdrop(markerMenu)
        OrnateBorder(markerMenu, 0, 13)
        panel.cameraMarkerStyleButton = markerButton
        panel.cameraMarkerStyleMenu = markerMenu
        panel.cameraMarkerStyleRows = {}
        for index, option in ipairs(self.cameraMarkerOptions) do
            local row = PlainButton(markerMenu, option.label, 336, 34, function()
                self:SetCameraMarkerStyle(option.id)
                markerMenu:Hide()
                panel:RefreshControls()
            end)
            row:SetPoint("TOPLEFT", markerMenu, "TOPLEFT", 6, -5 - (index - 1) * 36)
            local text = row:GetFontString()
            text:ClearAllPoints()
            text:SetPoint("LEFT", row, "LEFT", 40, 0)
            text:SetJustifyH("LEFT")
            local preview = row:CreateTexture(nil, "ARTWORK")
            preview:SetSize(28, 28)
            preview:SetPoint("LEFT", row, "LEFT", 6, 0)
            preview:SetTexture(option.texture)
            preview:SetTexCoord(0, 1, 0, 1)
            panel.cameraMarkerStyleRows[#panel.cameraMarkerStyleRows + 1] = { button = row, option = option }
        end
        markerButton:SetScript("OnClick", function() markerMenu:SetShown(not markerMenu:IsShown()) end)
        markerMenu:Hide()
        local function ScrollArea(x, y, width, height)
            local scroll = CreateFrame("ScrollFrame", nil, panel)
            scroll:SetSize(width, height)
            scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
            local child = CreateFrame("Frame", nil, scroll)
            child:SetSize(width, height)
            scroll:SetScrollChild(child)
            scroll:EnableMouseWheel(true)
            scroll:SetScript("OnMouseWheel", function(_, delta)
                local maximum = math.max(0, child:GetHeight() - scroll:GetHeight())
                scroll:SetVerticalScroll(math.max(0, math.min(maximum, scroll:GetVerticalScroll() - delta * 44)))
            end)
            return scroll, child
        end
        local controlScroll, controls = ScrollArea(25, -254, 488, 449)
        panel.rows = {}
        local options = {}
        for _, group in ipairs({ self.scanTuning, self.sweepTuning, self.viewTuning, self.smartTuning }) do
            for _, option in ipairs(group) do options[#options + 1] = option end
        end
        options[#options + 1] = { key = "rangeDelay", label = "Bobber classification delay", min = self.timing.rangeMin,
            max = self.timing.rangeMax, step = .05, unit = "s", timing = true,
            note = "Retained classification tuning. Verified native bobbers do not wait for Hook/Recast delays." }
        options[#options + 1] = { key = "recastDelay", label = "Legacy recast delay (active profile)", min = self.timing.recastMin,
            max = self.timing.recastMax, step = .1, unit = "s", timing = true,
            note = "Camera backup uses this delay. Native mode retains its own unused legacy value; each mode loads its saved timing profile." }
        options[#options + 1] = { key = "hookDelay", label = "Legacy hook delay (active profile)", min = self.timing.hookMin,
            max = self.timing.hookMax, step = .1, unit = "s", timing = true,
            note = "Camera backup uses this delay. Native mode retains its own unused legacy value; each mode loads its saved timing profile." }
        options[#options + 1] = { key = "pressLock", label = "Rapid press lock (active fishing mode)",
            min = self.timing.pressMin, max = self.timing.pressMax, step = 0.05, unit = "s", timing = true,
            note = "Blocks repeat presses briefly after a cast. Default: 0.35 s; 0 turns it off. Each fishing mode remembers its own value. This does not change scan speed or hook/recast delays." }
        for index, option in ipairs(options) do
            local y = -(index - 1) * 55
            SettingsFont(controls, "GameFontHighlight", 14, "TOPLEFT", controls, "TOPLEFT", 4, y,
                option.label, { 0.93, 0.94, 0.92 })
            local value = SettingsFont(controls, "GameFontHighlight", 13, "TOPRIGHT", controls, "TOPRIGHT", -12, y,
                "", { 1, 0.82, 0.47 })
            local slider = TimingSlider(controls, 9, y - 25, 452, option.min, option.max, option.step)
            slider:SetScript("OnValueChanged", function(_, nextValue)
                if panel.refreshing then return end
                if option.key == "pressLock" then self:SetRapidPressLock(nextValue)
                elseif option.timing then
                    self.db[option.key] = math.floor(nextValue / option.step + .5) * option.step
                    self:SaveTimingProfile()
                else
                    self.db[option.key] = math.floor(nextValue / option.step + 0.5) * option.step
                    self:SaveCameraScanProfile()
                end
                panel:RefreshControls()
            end)
            slider:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(option.label)
                GameTooltip:AddLine(string.format("Range: %g to %g. Changes apply to the next %s.", option.min, option.max,
                    option.timing and "cast" or "search"), 1, 1, 1, true)
                GameTooltip:AddLine(option.note, 0.76, 0.82, 0.8, true)
                GameTooltip:Show()
            end)
            slider:SetScript("OnLeave", function() GameTooltip:Hide() end)
            panel.rows[#panel.rows + 1] = { option = option, slider = slider, value = value }
        end
        controls:SetHeight(#options * 55 + 8)
        local reportScroll, reportChild = ScrollArea(542, -204, 483, 312)
        local report = SettingsFont(reportChild, "GameFontHighlight", 13, "TOPLEFT", reportChild, "TOPLEFT", 4, 0, "", { 0.91, 0.92, 0.87 })
        report:SetWidth(468)
        report:SetJustifyH("LEFT")
        report:SetJustifyV("TOP")
        report:SetShadowOffset(0, 0)
        panel.report = report
        local actions = { { "Reset Statistics", "statistics" }, { "Copy Current State", "state" },
            { "Copy Sweep", "path" }, { "Export profile", "export" } }
        for index, action in ipairs(actions) do
            local button = PlainButton(panel, action[1], 232, 31, function()
                self:CameraDevAction(action[2])
                panel:RefreshControls()
            end)
            button:SetPoint("TOPLEFT", panel, "TOPLEFT", 542 + ((index - 1) % 2) * 249, -534 - math.floor((index - 1) / 2) * 39)
            OrnateBorder(button, 0, 13)
            if action[2] == "export" then panel.exportProfileButton = button end
        end
        if self.BuildCameraBackupSoundControls then self:BuildCameraBackupSoundControls(panel) end
        function panel:RefreshControls()
            self.refreshing = true
            profileButton:SetText("Profile: " .. FF:CameraScanProfileName())
            for _, entry in ipairs(self.cameraProfileRows) do
                entry.button:GetFontString():SetTextColor(unpack(entry.option.id == FF.db.cameraProfile
                    and { 1, 0.82, 0.47 } or { 0.94, 0.95, 0.93 }))
            end
            local selectedMarker = FF:CameraMarkerOption(FF.db.cameraMarkerStyle)
            markerText:SetText(selectedMarker.label)
            markerPreview:SetTexture(selectedMarker.texture)
            for _, entry in ipairs(self.cameraMarkerStyleRows) do
                entry.button:GetFontString():SetTextColor(unpack(entry.option.id == selectedMarker.id
                    and { 1, 0.82, 0.47 } or { 0.94, 0.95, 0.93 }))
            end
            buttons.assist:SetText("Camera backup: " .. (FF.db.cameraAssist and "Active" or "Disabled"))
            buttons.logging:SetText("Diagnostic logging: " .. (FF.db.cameraScanLogging and "On" or "Off"))
            buttons.rounded:SetText("Rounded turns: " .. (FF.db.cameraRoundedTurns and "On" or "Off"))
            buttons.pyramid:SetText("Pyramid Path: " .. (FF.db.cameraPyramidPath and "On" or "Off"))
            buttons.racetrack:SetText("Racetrack turns: " .. (FF.db.cameraRacetrackTurns and "On" or "Off"))
            buttons.savedView:SetText("Saved fishing view (test): " .. (FF.db.cameraSavedView and "On" or "Off"))
            buttons.smart:SetText("Smart camera adjustment: " .. (FF.db.cameraSmartAdjustment and "On" or "Off"))
            for _, row in ipairs(self.rows) do
                local o, value = row.option, FF.db[row.option.key]
                value = tonumber(value) or o.default or o.min
                row.slider:SetValue(value)
                row.value:SetText(string.format(o.step < 1 and "%.2f %s" or "%d %s", value, o.unit or ""))
                row.slider.fill:SetWidth(math.max(1, (value - o.min) / (o.max - o.min) * row.slider:GetWidth()))
            end
            self.refreshing = false
            if FF.RefreshCameraBackupSoundControls then FF:RefreshCameraBackupSoundControls() end
            report:SetText(FF:CameraDeveloperReport())
            reportChild:SetHeight(math.max(312, report:GetStringHeight() + 14))
        end
        panel:SetScript("OnShow", function()
            panel.elapsed = 0
            panel:SetScript("OnUpdate", function(_, elapsed)
                panel.elapsed = panel.elapsed + elapsed
                if panel.elapsed < 0.25 then return end
                panel.elapsed = 0
                report:SetText(self:CameraDeveloperReport())
                reportChild:SetHeight(math.max(312, report:GetStringHeight() + 14))
            end)
        end)
        panel:SetScript("OnHide", function()
            profileMenu:Hide()
            markerMenu:Hide()
            if panel.openMenu then panel.openMenu:Hide(); panel.openMenu = nil end
            if self.StopFishingSoundPreview then self:StopFishingSoundPreview() end
            panel:SetScript("OnUpdate", nil)
        end)
        self:PrepareFloatingWindow(panel, "scanDev", panel)
        self.scanDevPanel = panel
    end
    self.scanDevPanel:RefreshControls()
    self:ShowFloatingWindow(self.scanDevPanel)
end
