-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

-- Borrow the native cast-bar display switch, leaving its events, timing,
-- anchors, parent and Show/Hide decisions with Blizzard. Its public setter
-- reconciles the current native cast on release (including an unrelated cast).
function FF:ReleaseFishingCastBars(preserveCookingHold)
    if not preserveCookingHold then self.fishingCookingBarHold=nil end
    local states=self.fishingCastBarStates
    if not states then return end
    self.fishingCastBarChanging=true
    for frame,state in pairs(states) do
        states[frame]=nil
        if frame.showCastbar==false then
            local ok=pcall(frame.SetAndUpdateShowCastbar,frame,state.original)
            -- The native setter's UpdateIsShown only resumes ordinary casts.
            -- Re-enter its own current-cast reader for an active channel too;
            -- never force Show or invent timing/visibility state.
            if ok and state.original and type(frame.OnEvent)=="function" and type(UnitChannelInfo)=="function" then
                local readable,name=pcall(UnitChannelInfo,"player")
                if readable and not (issecretvalue and issecretvalue(name)) and type(name)=="string" then
                    pcall(frame.OnEvent,frame,"PLAYER_ENTERING_WORLD")
                end
            end
            if not ok and frame.showCastbar==false then states[frame]=state end
        end
    end
    self.fishingCastBarChanging=nil
end
function FF:CanReplaceFishingCastBar(cast)
    local button=self.castButton
    local options=self:GetFishingInformationOptions()
    local mode=options.hideCastBars
    return cast and self.db and not self.informationWorldSuspended and not InCombat()
        and self.bar and self.bar:IsShown() and options.enabled and options.progressMode~="off"
        and (mode=="both" or mode==cast.kind) and not self.captureVisibility
        and button and button:IsVisible() and (not button.GetEffectiveAlpha or button:GetEffectiveAlpha()>=.99)
        and (not self.GetFishingHUDOpacity or self:GetFishingHUDOpacity()>=1)
        and not (self.minimalFishingViewActive and self.minimalCastFrame and self.minimalCastFrame:IsShown())
end
function FF:SyncFishingCastBarVisibility(cast)
    if self.fishingCastBarChanging then return false end
    local hold=self.fishingCookingBarHold
    if not cast and hold and hold.finished and not hold.suspended and hold.db==self.db and hold.bar==self.bar
        and self:CanReplaceFishingCastBar(hold.cast) then
        -- STOP/interrupt is the authoritative end. A partially cleared native
        -- tuple must not restore its finish animation. New START events yield
        -- immediately; positive foreign-cast observations also yield safely.
        local live=self.informationCastObservation
        local same=live and live.spell==hold.cast.spell and live.source==hold.cast.source
            and ((live.guid and hold.cast.guid and live.guid==hold.cast.guid)
                or (not (live.guid and hold.cast.guid) and live.start==hold.cast.start))
        if not live or same then
            -- Keep only switches already owned by the qualified cooking cast.
            -- Do not re-enable Blizzard's interrupted/finish animation between
            -- crafts, nor acquire a foreign/pre-disabled bar during this hold.
            local hidden=false
            for frame in pairs(self.fishingCastBarStates or {}) do
                if (frame.IsProtected and frame:IsProtected()) or frame.isInEditMode then
                    self:ReleaseFishingCastBars();return false
                end
                if frame.showCastbar==false and not frame:IsShown() then hidden=true end
            end
            return hidden
        end
        hold.suspended=true;self:ReleaseFishingCastBars(true);return false
    end
    if not self:CanReplaceFishingCastBar(cast) then self:ReleaseFishingCastBars();return false end
    self.fishingCastBarStates=self.fishingCastBarStates or {}
    self.fishingCastBarHooks=self.fishingCastBarHooks or {}
    self.fishingCastBarBlocked=self.fishingCastBarBlocked or {}
    local hidden=false
    for _,name in ipairs({"PlayerCastingBarFrame","CastingBarFrame","OverlayPlayerCastingBarFrame"}) do
        local frame=_G[name]
        if frame and frame.unit=="player" and type(frame.SetAndUpdateShowCastbar)=="function"
            and not (frame.IsProtected and frame:IsProtected()) and not frame.isInEditMode then
            local blocked=self.fishingCastBarBlocked[frame]
            if blocked and (blocked.spell~=cast.spell or blocked.start~=cast.start or blocked.source~=cast.source) then
                self.fishingCastBarBlocked[frame]=nil;blocked=nil
            end
            local state=self.fishingCastBarStates[frame]
            if not state and not blocked and frame.showCastbar==true and hooksecurefunc then
                if not self.fishingCastBarHooks[frame] then
                    local ok=pcall(hooksecurefunc,frame,"SetAndUpdateShowCastbar",function()
                        if self.fishingCastBarChanging then return end
                        local owned=self.fishingCastBarStates[frame]
                        if owned then
                            self.fishingCastBarStates[frame]=nil
                            self.fishingCastBarBlocked[frame]=owned.cast
                        end
                    end)
                    self.fishingCastBarHooks[frame]=ok and true or nil
                end
                if self.fishingCastBarHooks[frame] then
                    state={original=frame.showCastbar,cast=cast}
                    self.fishingCastBarStates[frame]=state
                    self.fishingCastBarChanging=true
                    local ok=pcall(frame.SetAndUpdateShowCastbar,frame,false)
                    self.fishingCastBarChanging=nil
                    if frame.showCastbar~=false then self.fishingCastBarStates[frame]=nil;state=nil end
                    if not ok then self:ReleaseFishingCastBars();state=nil end
                end
            end
            if state and frame.showCastbar==false and not frame:IsShown() then
                state.cast=cast;hidden=true
                if cast.kind=="cooking" then self.fishingCookingBarHold={db=self.db,bar=self.bar,cast=cast} end
            end
        elseif frame and self.fishingCastBarStates[frame] then
            self:ReleaseFishingCastBars()
        end
    end
    return hidden
end

function FF:GetBlizzardUIHideMode()
    local mode=self.db and self.db.blizzardUIHideMode
    if mode=="never" or mode=="fishing" or mode=="casts" then return mode end
    return self.db and self.db.hideBlizzardUIWhileFishing==true and "fishing" or "never"
end
function FF:InitializeFishingViewSettings()
    self.db.blizzardUIHideMode=self:GetBlizzardUIHideMode()
    -- Compatibility for the older fallback settings surface. The mode owns policy.
    self.db.hideBlizzardUIWhileFishing=self.db.blizzardUIHideMode~="never"
end

function FF:ShouldHideFishingBlizzardUI()
    if not (self.bar and self.bar:IsShown()) then return false end
    local mode=self:GetBlizzardUIHideMode()
    if mode=="fishing" then return true end
    if mode~="casts" then return false end
    local phase=self.fishingViewPhase
    return phase and (phase.channel or GetTime()<phase.nativeRestoreAt)
end

-- Prepare native tooltip parents before UIParent is hidden. Waiting for a
-- successful SetOwner is too late if the hidden parent prevents that setup.
local function Under(frame, ancestor)
    for _=1,64 do
        if frame==ancestor then return true end
        frame=frame and frame.GetParent and frame:GetParent()
        if not frame then return false end
    end
    return false
end
-- Borrow only the native minimap hierarchy, never Show a native frame or
-- change tracking. The transparent root is outside the Minimal HUD fade.
function FF:ReleaseFishingMinimap()
    local state=self.fishingMinimapState
    if not state or self.fishingMinimapChanging then return end
    if InCombat() then self.fishingMinimapRestorePending=true; return end
    self.fishingMinimapChanging=true
    local frame=state.frame
    if frame:GetParent()==state.root then
        local strata,level=frame:GetFrameStrata(),frame:GetFrameLevel()
        if frame:GetScale()==state.appliedScale then frame:SetScale(state.scale) end
        frame:SetParent(state.parent)
        frame:SetFrameStrata(strata==state.appliedStrata and state.strata or strata)
        frame:SetFrameLevel(level==state.appliedLevel and state.level or level)
    end
    state.root:Hide()
    self.fishingMinimapState,self.fishingMinimapRestorePending=nil,nil
    self.fishingMinimapChanging=nil
end
local function MinimapShown(frame)
    -- UIParent may already be addon-hidden when the preference is enabled.
    -- Every native child/intermediate parent must still be logically shown.
    for _=1,64 do
        if frame==UIParent then return not frame.GetAlpha or frame:GetAlpha()>0 end
        if not frame or not frame:IsShown() or (frame.GetAlpha and frame:GetAlpha()<=0) then return false end
        frame=frame:GetParent()
    end
    return false
end
function FF:SyncFishingMinimapVisibility(hiding)
    if self.fishingMinimapChanging then return end
    local active=self.db and self.db.showFishingMinimap==true and self:GetBlizzardUIHideMode()~="never"
        and self.bar and self.bar:IsShown() and not self.fishingUIManualOverride
        and UIParent and (hiding or (self.fishingUIHiddenByAddon and not UIParent:IsShown()))
    if not active or self.fishingMinimapRestorePending then
        self:ReleaseFishingMinimap()
        if not active or self.fishingMinimapState then return end
    end
    -- Existing records retain identity, hidden state and later external edits.
    if self.fishingMinimapState or InCombat() then return end
    local frame=MinimapCluster or Minimap
    if not (frame and Minimap and self.visibilityRoot and self.visibilityRoot:GetParent()~=UIParent)
        or not Under(Minimap,frame) or not Under(frame,UIParent) or not MinimapShown(Minimap) then return end
    local rootAlpha=self.visibilityRoot.GetEffectiveAlpha and self.visibilityRoot:GetEffectiveAlpha() or 1
    if rootAlpha<=0 then return end
    local root=self.fishingMinimapRoot or CreateFrame("Frame",nil,self.visibilityRoot,"SecureHandlerBaseTemplate")
    root:SetAllPoints(UIParent); root:EnableMouse(false)
    local state={frame=frame,root=root,parent=frame:GetParent(),scale=frame:GetScale(),
        strata=frame:GetFrameStrata(),level=frame:GetFrameLevel()}
    state.appliedScale=frame:GetEffectiveScale()/root:GetEffectiveScale()
    -- Preserve native parent opacity as well as the frame's own alpha.
    local parentAlpha=state.parent.GetEffectiveAlpha and state.parent:GetEffectiveAlpha() or 1
    root:SetAlpha(parentAlpha/rootAlpha); root:Show()
    self.fishingMinimapChanging=true
    self.fishingMinimapRoot,self.fishingMinimapState=root,state
    frame:SetParent(root); frame:SetScale(state.appliedScale)
    frame:SetFrameStrata(state.strata); frame:SetFrameLevel(state.level)
    state.appliedScale=frame:GetScale()
    state.appliedStrata,state.appliedLevel=frame:GetFrameStrata(),frame:GetFrameLevel()
    self.fishingMinimapChanging=nil
end
function FF:SetFishingMinimapShown(enabled)
    if not self.db then return end
    self.db.showFishingMinimap=enabled==true
    self:ReapplyFishingViewSettings()
    if self.settingsPanel and self.settingsPanel.RefreshFishingViewControls then self.settingsPanel:RefreshFishingViewControls() end
end
function FF:GetFishingMinimapTooltipOwner(owner)
    local state=self.fishingMinimapState
    if owner==UIParent and state and state.frame:GetParent()==state.root
        and Minimap and Under(Minimap,state.frame) and Minimap:IsVisible()
        and Minimap.IsMouseOver and Minimap:IsMouseOver() then return Minimap end
    return owner
end
local function TooltipFrames()
    local frames,seen={},{}
    local function Add(frame)
        if frame and not seen[frame] then seen[frame]=true; frames[#frames+1]=frame end
    end
    Add(GameTooltip)
    for _,frame in ipairs(GameTooltip and GameTooltip.shoppingTooltips or {}) do Add(frame) end
    for index=1,3 do Add(_G["ShoppingTooltip"..index]) end
    return frames
end
local function CanMoveTooltip(frame)
    return not (InCombat() and frame.IsProtected and frame:IsProtected())
end
function FF:ReleaseFishingTooltipParents(hideComparisons)
    local state=self.fishingUITooltipState
    if not state or self.fishingUITooltipChanging then return end
    self.fishingUITooltipChanging=true
    for frame,record in pairs(state.frames) do
        if CanMoveTooltip(frame) then
            if hideComparisons and frame~=state.tip then frame:Hide() end
            -- A later parent/scale change by another owner wins.
            if frame:GetParent()==record.appliedParent then
                local strata=frame:GetFrameStrata()
                local level=frame:GetFrameLevel()
                if strata==record.appliedStrata then strata=record.strata end
                if level==record.appliedLevel then level=record.level end
                if frame:GetScale()==record.appliedScale then frame:SetScale(record.scale) end
                frame:SetParent(record.parent)
                -- SetParent can inherit the new parent's drawing order.
                frame:SetFrameStrata(strata)
                frame:SetFrameLevel(level)
            end
            state.frames[frame]=nil
        end
    end
    self.fishingUITooltipChanging=nil
    if not next(state.frames) then self.fishingUITooltipState=nil end
end
function FF:InstallFishingTooltipHooks()
    if not (GameTooltip and hooksecurefunc) then return end
    self.fishingUITooltipHooks=self.fishingUITooltipHooks or {}
    for _,tip in ipairs(TooltipFrames()) do
        if not self.fishingUITooltipHooks[tip] then
            self.fishingUITooltipHooks[tip]=true
            -- Include comparison frames created after the initial preparation.
            hooksecurefunc(tip,"SetOwner",function(frame,owner,anchor,...)
                -- Native marker hover uses hidden UIParent as owner. Substitute
                -- the visible map before native content is filled, preserving
                -- its exact cursor anchor/offsets; never reset content on Show.
                if frame==GameTooltip and not self.fishingUIMinimapTooltipChanging and CanMoveTooltip(frame) then
                    local visible=self:GetFishingMinimapTooltipOwner(owner)
                    if visible~=owner then
                        self.fishingUIMinimapTooltipChanging=true
                        frame:SetOwner(visible,anchor,...)
                        self.fishingUIMinimapTooltipChanging=nil
                    end
                end
                self:SyncFishingTooltipVisibility()
            end)
            hooksecurefunc(tip,"Show",function() self:SyncFishingTooltipVisibility() end)
            tip:HookScript("OnShow",function() self:SyncFishingTooltipVisibility() end)
            if tip==GameTooltip then
                tip:HookScript("OnHide",function()
                    -- Keep the group ready for the next hover while UI is hidden.
                    if self.fishingUITooltipChanging then return end
                    for _,compare in ipairs(TooltipFrames()) do
                        if compare~=GameTooltip and CanMoveTooltip(compare) then compare:Hide() end
                    end
                end)
            end
        end
    end
    if type(GameTooltip_ShowCompareItem)=="function"
        and self.fishingUITooltipCompareHook~=GameTooltip_ShowCompareItem then
        hooksecurefunc("GameTooltip_ShowCompareItem",function() self:SyncFishingTooltipVisibility() end)
        self.fishingUITooltipCompareHook=GameTooltip_ShowCompareItem
    end
end
function FF:SyncFishingTooltipVisibility(hiding)
    if self.fishingUITooltipChanging then return end
    local tip,root=GameTooltip,self.visibilityRoot
    local owner=tip and tip.GetOwner and tip:GetOwner()
    -- Native Minimap_OnUpdate anchors marker tooltips to UIParent. Permit
    -- this owner only over the still-owned, visible native minimap.
    owner=self:GetFishingMinimapTooltipOwner(owner)
    local state=self.fishingUITooltipState
    local active=self:GetBlizzardUIHideMode()~="never" and self.bar and self.bar:IsShown()
        and UIParent and (hiding or not UIParent:IsShown())
        and root and root:GetParent()~=UIParent
    if state and (not active or state.tip~=tip) then
        self:ReleaseFishingTooltipParents(state.tip~=tip)
        state=self.fishingUITooltipState
    end
    if not active then return end
    self:InstallFishingTooltipHooks()
    local allowed=owner and owner:IsVisible() and Under(owner,root)
    -- Borrowing the parent must not reveal Blizzard/other-addon tooltips.
    if not allowed then
        for _,frame in ipairs(TooltipFrames()) do
            if frame:IsShown() and CanMoveTooltip(frame) then frame:Hide() end
        end
    end
    if allowed then
        self.fishingUITooltipOwnerHooks=self.fishingUITooltipOwnerHooks or setmetatable({},{__mode="k"})
        if not self.fishingUITooltipOwnerHooks[owner] then
            self.fishingUITooltipOwnerHooks[owner]=true
            owner:HookScript("OnHide",function(hidden)
                local current=GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner()
                local state=self.fishingUITooltipState
                if (current==hidden or (current==UIParent and hidden==Minimap and state and state.owner==hidden))
                    and CanMoveTooltip(GameTooltip) then GameTooltip:Hide() end
            end)
        end
    end
    if not state then state={tip=tip,frames={}}; self.fishingUITooltipState=state end
    state.owner=allowed and owner or nil
    self.fishingUITooltipChanging=true
    for _,frame in ipairs(TooltipFrames()) do
        if not state.frames[frame] and Under(frame,UIParent) and CanMoveTooltip(frame) then
            local parent,scale=frame:GetParent(),frame:GetScale()
            local effective,rootScale=frame:GetEffectiveScale(),root:GetEffectiveScale()
            local applied=effective/rootScale
            state.frames[frame]={parent=parent,scale=scale,strata=frame:GetFrameStrata(),level=frame:GetFrameLevel(),
                appliedParent=root,appliedScale=applied}
            frame:SetParent(root)
            frame:SetScale(applied)
        end
        local record=state.frames[frame]
        if record and frame:GetParent()==record.appliedParent and CanMoveTooltip(frame) then
            -- Native owner setup and reparenting can inherit a window's layer.
            -- The whole group must draw above that window, including Journal.
            local level=math.max(record.level,root:GetFrameLevel()+10,allowed and owner:GetFrameLevel()+10 or 0)
            record.appliedStrata,record.appliedLevel="TOOLTIP",level
            if frame:GetFrameStrata()~="TOOLTIP" then frame:SetFrameStrata("TOOLTIP") end
            if frame:GetFrameLevel()~=level then frame:SetFrameLevel(level) end
        end
    end
    self.fishingUITooltipChanging=nil
end

function FF:ForEachFishingBagFrame(visit)
    if _G.ContainerFrameCombinedBags and visit(_G.ContainerFrameCombinedBags) then return true end
    for index = 1, NUM_CONTAINER_FRAMES or 13 do
        local frame = _G["ContainerFrame" .. index]
        if frame and visit(frame) then return true end
    end
    return false
end

local function BagOpen()
    return FF:ForEachFishingBagFrame(function(frame) return frame.IsShown and frame:IsShown() end)
end

local function LootNeedsUIParent(self)
    local nativeParent = LootFrame and Under(LootFrame, UIParent)
    if self.fishingNativeLootPending == "automatic" and LootFrame then return nativeParent end
    return self.fishingNativeLootPending ~= nil or (nativeParent and LootFrame:IsShown())
end

local function TemporaryPanelOpen(self)
    return LootNeedsUIParent(self)
        or (WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()) or BagOpen()
end

local function CommandPanelOpen(name)
    if name=="ToggleWorldMap" or name=="OpenWorldMap" then
        return WorldMapFrame and WorldMapFrame:IsShown()
    end
    return BagOpen()
end

-- Native Camelot bindings, not assumed B/M keys. Observe before the native
-- binding runs; never replace it or invoke a second toggle from this handler.
local PANEL_BINDINGS={TOGGLEWORLDMAP={"ToggleWorldMap"},TOGGLEBACKPACK={"ToggleBackpack"},
    OPENALLBAGS={"ToggleAllBags"},TOGGLEBAG1={"ToggleBag",4},TOGGLEBAG2={"ToggleBag",3},
    TOGGLEBAG3={"ToggleBag",2},TOGGLEBAG4={"ToggleBag",1},TOGGLEREAGENTBAG1={"ToggleBag",5}}
function FF:SyncFishingTemporaryPanelInput()
    local active=self.fishingUIHiddenByAddon and self:GetBlizzardUIHideMode()~="never"
        and self.bar and self.bar:IsShown() and UIParent and not UIParent:IsShown()
        and not self.fishingUIManualOverride
    local watch=self.fishingUIPanelKeyWatcher
    if active and not watch and not InCombat() and GetBindingAction and self.visibilityRoot then
        watch=CreateFrame("Frame",nil,self.visibilityRoot)
        watch:EnableMouse(false)
        watch:EnableKeyboard(true)
        watch:SetPropagateKeyboardInput(true)
        watch:SetScript("OnKeyDown",function(_,key)
            if not (self.fishingUIHiddenByAddon and self:GetBlizzardUIHideMode()~="never"
                and self.bar and self.bar:IsShown()) or UIParent:IsShown() then return end
            if self.journalInputFocus or self.settingsKeyboardFocus or (self.capture and self.capture:IsShown())
                or (GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()) then return end
            if IsShiftKeyDown and IsShiftKeyDown() then key="SHIFT-"..key end
            if IsControlKeyDown and IsControlKeyDown() then key="CTRL-"..key end
            if IsAltKeyDown and IsAltKeyDown() then key="ALT-"..key end
            -- Include overrides: a fishing action or another addon wins.
            local action=GetBindingAction(key,true)
            if self.RevealFishingChatForBinding and self:RevealFishingChatForBinding(action) then return end
            local command=PANEL_BINDINGS[action]
            if command and not self:RevealFishingUIForTemporaryPanel() and self.fishingUIRevealPending then
                self.fishingUIPanelRetryPending={name=command[1],args={command[2]},key=key,action=action}
            end
        end)
        self.bar:HookScript("OnHide",function() watch:Hide() end)
        self.fishingUIPanelKeyWatcher=watch
    end
    if watch then watch:SetShown(active and true or false) end
end

function FF:ScheduleFishingTemporaryPanelSync()
    if self.fishingUITemporarySyncQueued then return end
    self.fishingUITemporarySyncQueued = true
    local function Sync()
        self.fishingUITemporarySyncQueued = nil
        if TemporaryPanelOpen(self) then return end
        self.fishingUITemporaryReveal = nil
        self:SyncFishingUIVisibility()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0, Sync) else Sync() end
end

function FF:RevealFishingUIForTemporaryPanel()
    if not (self:GetBlizzardUIHideMode()~="never" and self.bar and self.bar:IsShown())
        or self.fishingUIManualOverride or not (UIParent and UIParent.IsShown and UIParent.Show) then return false end
    if self.fishingUITemporaryReveal and UIParent:IsShown() then return true end
    if not self.fishingUIHiddenByAddon or UIParent:IsShown() then return false end
    if InCombat() then self.fishingUIRevealPending = true; return false end
    self.fishingUIChangeInProgress = true
    pcall(UIParent.Show, UIParent)
    self.fishingUIChangeInProgress = nil
    if not UIParent:IsShown() then self.fishingUIRevealPending = true; return false end
    self.fishingUIHiddenByAddon = nil
    self.fishingUITemporaryReveal = true
    self.fishingUIRevealPending = nil
    return true
end

-- Let Blizzard present automatic fishing loot outside the hidden UIParent.
-- Moving a shown frame back under a hidden parent would trigger native OnHide and CloseLoot.
local function RestoreFishingLootFrame(self)
    local owner = self.fishingLootFrameOwner
    if not owner or self.fishingLootFrameChanging then return end
    local frame = owner.frame
    if frame:GetParent() ~= owner.root then self.fishingLootFrameOwner = nil; return end
    if InCombat() or (frame:IsShown() and not UIParent:IsShown()) then return end
    self.fishingLootFrameChanging = true
    local strata, level = frame:GetFrameStrata(), frame:GetFrameLevel()
    pcall(frame.SetParent, frame, UIParent)
    if frame:GetParent() == UIParent then
        if frame:GetScale() == owner.appliedScale then frame:SetScale(owner.scale) end
        frame:SetFrameStrata(strata)
        frame:SetFrameLevel(level)
        self.fishingLootFrameOwner = nil
    end
    self.fishingLootFrameChanging = nil
end

local function PrepareFishingLootFrame(self)
    local frame, root = LootFrame, self.visibilityRoot
    if self.fishingNativeLootPending ~= "automatic" or self.fishingLootFrameOwner
        or not (self.bar and self.bar:IsShown() and self:ShouldHideFishingBlizzardUI())
        or not (self.fishingUIHiddenByAddon or UIParent:IsShown())
        or self.fishingUIManualOverride or InCombat()
        or not (frame and root and root:IsVisible() and frame:GetParent() == UIParent and not Under(root, UIParent))
        or self.captureVisibility or frame.isInEditMode then return end
    local scale, strata, level = frame:GetScale(), frame:GetFrameStrata(), frame:GetFrameLevel()
    local appliedScale = frame:GetEffectiveScale() / root:GetEffectiveScale()
    self.fishingLootFrameChanging = true
    pcall(frame.SetParent, frame, root)
    if frame:GetParent() == root then
        frame:SetScale(appliedScale)
        frame:SetFrameStrata(strata)
        frame:SetFrameLevel(level)
        self.fishingLootFrameOwner = {frame=frame, root=root, scale=scale, appliedScale=frame:GetScale()}
    end
    self.fishingLootFrameChanging = nil
end

function FF:BeginFishingLootVisibility(automaticFishing, manual)
    if manual or not self.fishingNativeLootPending then
        self.fishingNativeLootPending = automaticFishing and not manual and "automatic" or "native"
    end
    PrepareFishingLootFrame(self)
    if self.fishingUIHiddenByAddon and LootNeedsUIParent(self) then self:RevealFishingUIForTemporaryPanel() end
    if self.fishingNativeLootPending == "native" then RestoreFishingLootFrame(self) end
end

function FF:EndFishingLootVisibility()
    local pending = self.fishingNativeLootPending
    self.fishingNativeLootPending = nil
    RestoreFishingLootFrame(self)
    if pending or self.fishingUITemporaryReveal then self:ScheduleFishingTemporaryPanelSync() end
end

function FF:InstallFishingTemporaryPanelHooks()
    if WorldMapFrame and WorldMapFrame.HookScript and not self.fishingUIMapVisibilityHooked then
        self.fishingUIMapVisibilityHooked = true
        WorldMapFrame:HookScript("OnShow", function()
            if self.fishingUIHiddenByAddon then self:RevealFishingUIForTemporaryPanel() end
        end)
        WorldMapFrame:HookScript("OnHide", function() self:ScheduleFishingTemporaryPanelSync() end)
    end
    self.fishingUIPanelFrameHooks = self.fishingUIPanelFrameHooks or {}
    local function HookFrame(frame, loot)
        if not (frame and frame.HookScript) or self.fishingUIPanelFrameHooks[frame] then return end
        self.fishingUIPanelFrameHooks[frame] = true
        frame:HookScript("OnShow", function()
            if self.fishingUIChangeInProgress or (loot and self.fishingLootFrameChanging) then return end
            if self.fishingUIHiddenByAddon and (not loot or LootNeedsUIParent(self)) then
                self:RevealFishingUIForTemporaryPanel()
            end
            self:ScheduleFishingTemporaryPanelSync()
        end)
        frame:HookScript("OnHide", function()
            if loot and self.fishingNativeLootPending ~= "automatic" then RestoreFishingLootFrame(self) end
            self:ScheduleFishingTemporaryPanelSync()
        end)
        if loot and hooksecurefunc then
            hooksecurefunc(frame, "SetParent", function()
                if self.fishingLootFrameChanging then return end
                local owner = self.fishingLootFrameOwner
                if owner and owner.frame == frame and frame:GetParent() ~= owner.root then
                    self.fishingLootFrameOwner = nil
                end
                if self.fishingNativeLootPending == "automatic" and frame:GetParent() == UIParent then
                    -- A loot addon can return its frame to Blizzard to offer manual pickup.
                    self:BeginFishingLootVisibility(false, true)
                end
            end)
        end
    end
    HookFrame(LootFrame, true)
    self:ForEachFishingBagFrame(HookFrame)
    if not hooksecurefunc then return end
    self.fishingUIPanelCommandHooks = self.fishingUIPanelCommandHooks or {}
    for _, name in ipairs({ "ToggleBackpack", "ToggleBag", "OpenBackpack", "OpenBag",
        "OpenAllBags", "ToggleAllBags", "CloseBackpack", "CloseBag", "CloseAllBags",
        "ToggleWorldMap", "OpenWorldMap" }) do
        if not self.fishingUIPanelCommandHooks[name] and type(_G[name]) == "function" then
            local hookedName = name
            local ok = pcall(hooksecurefunc, name, function(...)
                if self.fishingUIPanelRetrying then return end
                self:InstallFishingTemporaryPanelHooks()
                if self.fishingUIHiddenByAddon and hookedName ~= "CloseBackpack"
                    and hookedName ~= "CloseBag" and hookedName ~= "CloseAllBags" then
                    local args = { ... }
                    if self:RevealFishingUIForTemporaryPanel() then
                        if not CommandPanelOpen(hookedName) then
                            self.fishingUIPanelRetrying = true
                            pcall(_G[hookedName], unpack(args))
                            self.fishingUIPanelRetrying = nil
                            self:InstallFishingTemporaryPanelHooks()
                        end
                    elseif self.fishingUIRevealPending then
                        self.fishingUIPanelRetryPending = { name = hookedName, args = args }
                    end
                end
                self:ScheduleFishingTemporaryPanelSync()
            end)
            if ok then self.fishingUIPanelCommandHooks[name] = true end
        end
    end
end

local function GetFishingCombatRevealDriver(self)
    if self.fishingUICombatRevealDriver then return self.fishingUICombatRevealDriver end
    if self.fishingUICombatRevealUnavailable or InCombat()
        or not (RegisterStateDriver and UIParent and UIParent.IsProtected and UIParent:IsProtected())
        or (UIParent.IsForbidden and UIParent:IsForbidden()) then return end
    local ok, driver = pcall(function()
        local frame = CreateFrame("Frame", nil, self.visibilityRoot, "SecureHandlerStateTemplate")
        frame:SetFrameRef("nativeUI", UIParent)
        frame:SetAttribute("_onstate-combat", [[
            if newstate ~= "combat" or not self:GetAttribute("owns-ui-hide") then return end
            self:SetAttribute("owns-ui-hide", nil)
            local ui = self:GetFrameRef("nativeUI")
            if ui and not ui:IsShown() then
                self:SetAttribute("revealing-ui", true)
                ui:Show(true)
                self:SetAttribute("revealing-ui", nil)
            end
        ]])
        RegisterStateDriver(frame, "combat", "[combat]combat;peace")
        return frame
    end)
    if not ok then self.fishingUICombatRevealUnavailable = true; return end
    self.fishingUICombatRevealDriver = driver
    return driver
end

function FF:InstallFishingUIVisibilityHook()
    self:InstallFishingTooltipHooks()
    if self.fishingUIVisibilityHooked or not (UIParent and UIParent.HookScript) then return end
    local ok = pcall(UIParent.HookScript, UIParent, "OnShow", function()
        local driver = FF.fishingUICombatRevealDriver
        if driver and not InCombat() then driver:SetAttribute("owns-ui-hide", nil) end
        FF.fishingUIRestorePending = nil
        if FF.fishingUIChangeInProgress then return end
        local combatReveal = driver and driver:GetAttribute("revealing-ui")
        FF.fishingUIHiddenByAddon = nil
        FF.fishingUITemporaryReveal = nil
        FF.fishingUIRevealPending = nil
        FF.fishingUIPanelRetryPending = nil
        if not combatReveal and FF:GetBlizzardUIHideMode() ~= "never" and FF.bar and FF.bar:IsShown() then
            -- A player reveal pauses clean view. A combat reveal only suspends it.
            FF.fishingUIManualOverride = true
        end
    end)
    self.fishingUIVisibilityHooked = ok
    if ok then
        GetFishingCombatRevealDriver(self)
        UIParent:HookScript("OnShow",function()
            if FF.SyncSessionTrackerVisibility then FF:SyncSessionTrackerVisibility() end
            if FF.SyncSessionGoalsVisibility then FF:SyncSessionGoalsVisibility() end
            if FF.RefreshFishingLayer then FF:RefreshFishingLayer() end
            FF:SyncFishingMinimapVisibility()
            FF:SyncFishingTooltipVisibility()
            FF:SyncFishingTemporaryPanelInput()
            if FF.SyncFishingViewVisibility then FF:SyncFishingViewVisibility() end
        end)
        UIParent:HookScript("OnHide", function()
            if FF.SyncSessionTrackerVisibility then FF:SyncSessionTrackerVisibility() end
            if FF.SyncSessionGoalsVisibility then FF:SyncSessionGoalsVisibility() end
            if FF.RefreshFishingLayer then FF:RefreshFishingLayer() end
            if not FF.fishingUIChangeInProgress then
                -- Alt+Z show/hide is a pause/resume within this fishing session.
                -- Do not claim UI that was already hidden before fishing opened.
                if not InCombat() and (FF.fishingUIManualOverride or FF.fishingUITemporaryReveal)
                    and FF:ShouldHideFishingBlizzardUI() then
                    local driver = GetFishingCombatRevealDriver(FF)
                    if driver then
                        driver:SetAttribute("owns-ui-hide", true)
                        FF.fishingUIManualOverride = nil
                        FF.fishingUIHiddenByAddon = true
                    end
                end
                FF.fishingUITemporaryReveal = nil
                FF.fishingUIRevealPending = nil
                FF.fishingUIPanelRetryPending = nil
            end
            FF:SyncFishingMinimapVisibility(FF.fishingUIChangeInProgress)
            FF:SyncFishingTooltipVisibility()
            FF:SyncFishingTemporaryPanelInput()
            if FF.SyncFishingViewVisibility then FF:SyncFishingViewVisibility(FF.fishingUIChangeInProgress) end
        end)
    end
    self:InstallFishingTemporaryPanelHooks()
end

local function SyncFishingUIVisibility(self)
    self:SyncFishingMinimapVisibility()
    if self.SyncFishingViewVisibility then self:SyncFishingViewVisibility() end
    if self.fishingUIDeferredRestore then return end
    if not self:ShouldHideFishingBlizzardUI() then
        self.fishingUIHidePending=nil
        if self.fishingUIHiddenByAddon or self.fishingUIRestorePending then self:ReleaseFishingUIVisibility(false)
        else
            RestoreFishingLootFrame(self)
            self:SyncFishingTooltipVisibility()
            self:SyncFishingTemporaryPanelInput()
        end
        return
    end
    self:SyncFishingTooltipVisibility()
    self:SyncFishingTemporaryPanelInput()
    if self.fishingNativeLootPending ~= "automatic" then RestoreFishingLootFrame(self) end
    local panelOpen = TemporaryPanelOpen(self)
    if panelOpen and self.fishingUIHiddenByAddon then self:RevealFishingUIForTemporaryPanel() end
    if not self.fishingUIVisibilityHooked or self.fishingUIRestorePending
        or not (self:GetBlizzardUIHideMode()~="never")
        or not (self.bar and self.bar:IsShown()) or self.fishingUIManualOverride
        or self.fishingUIHiddenByAddon or self.fishingUITemporaryReveal or panelOpen
        or not (UIParent and UIParent.IsShown and UIParent.Hide)
        or not UIParent:IsShown() then return end
    -- Never hide the ancestor that contains Forever Fishing's own controls.
    if not (self.visibilityRoot and self.visibilityRoot.GetParent)
        or self.visibilityRoot:GetParent() == UIParent then return end
    if InCombat() then self.fishingUIHidePending = true; return end
    self.fishingUIHidePending = nil
    -- Keep the native HUD available unless its combat return can be armed.
    local driver = GetFishingCombatRevealDriver(self)
    if not driver then return end
    driver:SetAttribute("owns-ui-hide", true)
    self.fishingUIChangeInProgress = true
    self:SyncFishingMinimapVisibility(true)
    self:SyncFishingTooltipVisibility(true)
    if self.SyncFishingViewVisibility then self:SyncFishingViewVisibility(true) end
    local ok = pcall(UIParent.Hide, UIParent)
    self:SyncFishingTooltipVisibility()
    self.fishingUIChangeInProgress = nil
    if not UIParent:IsShown() then
        self.fishingUIHiddenByAddon = true
    else
        driver:SetAttribute("owns-ui-hide", nil)
        if ok then
            -- A different UI controller immediately showed it again.
            self.fishingUIManualOverride = true
        end
    end
    self:SyncFishingTemporaryPanelInput()
    if self.SyncFishingViewVisibility then self:SyncFishingViewVisibility() end
end

function FF:SyncFishingUIVisibility()
    if self.fishingUISyncing or self.fishingUIChangeInProgress then return end
    self.fishingUISyncing=true
    SyncFishingUIVisibility(self)
    self.fishingUISyncing=nil
end

function FF:ReleaseFishingUIVisibility(endSession)
    self.fishingUIHidePending = nil
    self.fishingUITemporaryReveal = nil
    self.fishingUIRevealPending = nil
    self.fishingUIPanelRetryPending = nil
    if endSession then
        self.fishingNativeLootPending=nil
        self.fishingUIDeferredRestore=nil
        self.fishingViewPhase=nil
        self.fishingUISettingsRestoreSerial = (self.fishingUISettingsRestoreSerial or 0) + 1
    end
    local restore = self.fishingUIHiddenByAddon or self.fishingUIRestorePending
    self.fishingUIHiddenByAddon = nil
    self:SyncFishingMinimapVisibility()
    if self.SyncFishingViewVisibility then self:SyncFishingViewVisibility() end
    self:SyncFishingTemporaryPanelInput()
    if endSession then self.fishingUIManualOverride = nil end
    if not restore then RestoreFishingLootFrame(self); self:SyncFishingTooltipVisibility(); return end
    if not (UIParent and UIParent.IsShown and UIParent.Show) then return end
    if UIParent:IsShown() then
        self.fishingUIRestorePending = nil
        RestoreFishingLootFrame(self)
        self:SyncFishingTooltipVisibility()
        return
    end
    if InCombat() then self.fishingUIRestorePending = true; return end
    -- Return tooltip parents only after showing UIParent; an intermediate
    -- parent hide would clear a live native comparison during the toggle.
    self.fishingUIChangeInProgress = true
    pcall(UIParent.Show, UIParent)
    self.fishingUIChangeInProgress = nil
    self.fishingUIRestorePending = not UIParent:IsShown() or nil
    RestoreFishingLootFrame(self)
    self:SyncFishingTooltipVisibility()
end

function FF:ResumeFishingUIVisibility()
    if self.fishingUIRestorePending then
        if self:ShouldHideFishingBlizzardUI() and not self.fishingUIManualOverride
            and not UIParent:IsShown() and not TemporaryPanelOpen(self) then
            -- A new cast can supersede a return blocked by combat.
            self.fishingUIRestorePending = nil
            self.fishingUIHiddenByAddon = true
        else self:ReleaseFishingUIVisibility(false) end
    end
    if self.fishingNativeLootPending == "automatic" then PrepareFishingLootFrame(self)
    else RestoreFishingLootFrame(self) end
    local retry = self.fishingUIPanelRetryPending
    if retry and retry.key and GetBindingAction(retry.key,true)~=retry.action then
        retry=nil
        self.fishingUIPanelRetryPending=nil
    end
    if self.fishingUIRevealPending and (retry or TemporaryPanelOpen(self)) then
        if self:RevealFishingUIForTemporaryPanel() and retry and not CommandPanelOpen(retry.name) then
            self.fishingUIPanelRetrying = true
            pcall(_G[retry.name], unpack(retry.args))
            self.fishingUIPanelRetrying = nil
            self:InstallFishingTemporaryPanelHooks()
        end
    end
    self.fishingUIRevealPending = nil
    self.fishingUIPanelRetryPending = nil
    if self.fishingUIHidePending or (self:GetBlizzardUIHideMode()~="never") then
        self:SyncFishingUIVisibility()
    end
    self:ScheduleFishingTemporaryPanelSync()
    self:SyncFishingMinimapVisibility()
    self:SyncFishingTooltipVisibility()
end

-- Only an accepted new channel ends a manual reveal. The normal channel
-- refresh then applies current policy, temporary-panel and combat safeguards.
function FF:ResumeFishingUIHidingOnCast(resumed)
    if self.fishingUIManualOverride and not resumed and self.bar and self.bar:IsShown()
        and self:GetBlizzardUIHideMode()~="never" then
        self.fishingUIManualOverride = nil
        self:SyncFishingUIVisibility()
    end
end

-- Deliberate edits reconcile parent ownership and both subordinate views.
-- Routine sync never clears a player's temporary manual-show override.
function FF:ReapplyFishingViewSettings()
    if not self.db then return end
    if self:GetBlizzardUIHideMode()~="never" then
        if UIParent and UIParent:IsShown() then self.fishingUIHiddenByAddon = nil end
        self.fishingUIManualOverride = nil
        self.fishingUIRevealPending = nil
        self.fishingUIPanelRetryPending = nil
        if not TemporaryPanelOpen(self) then self.fishingUITemporaryReveal = nil end
        if self.fishingUIRestorePending and not InCombat() then self:ReleaseFishingUIVisibility(false) end
        self:SyncFishingUIVisibility()
    else self:SyncFishingUIVisibility() end
end

function FF:SetBlizzardUIHideMode(mode)
    if not self.db then return end
    if mode~="never" and mode~="fishing" and mode~="casts" then return end
    self.fishingUISettingsRestoreSerial = (self.fishingUISettingsRestoreSerial or 0) + 1
    self.fishingUIDeferredRestore=nil
    local serial = self.fishingUISettingsRestoreSerial
    local settings = self.settingsPanel
    local keepSettingsOpen = settings and settings:IsShown()
    self.db.blizzardUIHideMode=mode
    self.db.hideBlizzardUIWhileFishing=mode~="never"
    if self.UpdateFishingViewPhase then self:UpdateFishingViewPhase() end
    local deferRestore = not self:ShouldHideFishingBlizzardUI() and keepSettingsOpen and self.fishingUIHiddenByAddon
        and C_Timer and C_Timer.After
    self:SyncFishingTemporaryPanelInput()
    if deferRestore then
        self.fishingUIDeferredRestore=serial
        -- Let the toggle click finish before bringing UIParent back. Reassert
        -- the Settings window afterward if Blizzard's show path displaced it.
        C_Timer.After(0, function()
            if self.fishingUISettingsRestoreSerial ~= serial or not self.db then return end
            self.fishingUIDeferredRestore=nil
            if self:ShouldHideFishingBlizzardUI() then self:SyncFishingUIVisibility(); return end
            local reopen = self.settingsPanel == settings and settings:IsShown()
            self:ReleaseFishingUIVisibility(false)
            if reopen and self.settingsPanel == settings and self.ShowFloatingWindow then
                self:ShowFloatingWindow(settings)
            end
        end)
    else self:ReapplyFishingViewSettings() end
    if self.settingsPanel and self.settingsPanel.hideBlizzardUIWhileFishingButton then
        self.settingsPanel.hideBlizzardUIWhileFishingButton:SetState(self.db.hideBlizzardUIWhileFishing)
    end
    if self.settingsPanel and self.settingsPanel.generalHideBlizzardUIWhileFishingButton then
        self.settingsPanel.generalHideBlizzardUIWhileFishingButton:SetState(self.db.hideBlizzardUIWhileFishing)
    end
    if self.SyncFishingViewVisibility then self:SyncFishingViewVisibility() end
    if self.settingsPanel and self.settingsPanel.RefreshFishingViewControls then self.settingsPanel:RefreshFishingViewControls() end
    if self.RefreshCatchRecapSetting then self:RefreshCatchRecapSetting() end
end

function FF:SetHideBlizzardUIWhileFishing(enabled)
    self:SetBlizzardUIHideMode(enabled==true and "fishing" or "never")
end
