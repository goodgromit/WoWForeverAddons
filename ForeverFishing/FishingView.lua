-- Forever Fishing
-- Copyright Â© 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF=_G.ForeverFishing
local FADE_SECONDS,RESTORE_DELAY,MINIMAL_EXTRA_DELAY=.18,.5,.8
local NATIVE_RESTORE_DELAY=1.5
local function Combat() return InCombatLockdown and InCombatLockdown() end
function FF:UpdateFishingViewPhase()
    local open=self.bar and self.bar:IsShown()
    local active=open and self.active and tonumber(self.castStart) and tonumber(self.castEnd)
        and self.castEnd>self.castStart or false
    local phase=self.fishingViewPhase
    if not open then self.fishingViewPhase=nil; return false end
    if active then
        phase=phase or {}; phase.channel=true; phase.endedAt=nil; phase.restoreAt=nil; phase.nativeRestoreAt=nil
        self.fishingViewPhase=phase
    elseif phase then
        local now=GetTime()
        if phase.channel then
            phase.channel=false; phase.endedAt=now; phase.nativeRestoreAt=now+NATIVE_RESTORE_DELAY
        end
        -- Keep the Blizzard deadline independent of the Minimal HUD fade.
        phase.restoreAt=phase.endedAt+RESTORE_DELAY+(self.db.minimalFishingCastView and MINIMAL_EXTRA_DELAY or 0)
        if now>=phase.nativeRestoreAt and not self.minimalViewState then
            self.fishingViewPhase=nil
        end
    end
    return active
end
function FF:GetFishingHUDOpacity()
    if Combat() then return 1 end
    local state=self.minimalViewState
    local p=state and state.progress or 1
    return p*p*(3-2*p)
end
function FF:SetMinimalFishingCastView(enabled)
    if not self.db then return end
    self.db.minimalFishingCastView=enabled==true
    self:ReapplyFishingViewSettings()
    if self.settingsPanel then self.settingsPanel:RefreshFishingViewControls() end
end
function FF:EnsureMinimalFishingView()
    if self.minimalCastFrame or Combat() or not (self.toolBar and self.closeButton and self.bindButton) then return end
    local frame=CreateFrame("Frame",nil,self.visibilityRoot,"SecureHandlerBaseTemplate")
    frame:SetSize(180,10); frame:SetPoint("CENTER",self.bar,"CENTER",0,0)
    frame:SetClampedToScreen(true); frame:EnableMouse(false)
    local track=frame:CreateTexture(nil,"BACKGROUND")
    track:SetAllPoints(frame); track:SetColorTexture(.045,.037,.025,.94)
    local fill=frame:CreateTexture(nil,"ARTWORK"); fill:SetPoint("LEFT",frame,"LEFT",1,0)
    fill:SetSize(178,8); fill:SetColorTexture(.69,.50,.22,.94)
    for _,edge in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
        local line=frame:CreateTexture(nil,"OVERLAY"); line:SetPoint(edge,frame,edge)
        line:SetSize((edge=="TOP" or edge=="BOTTOM") and 180 or 1,
            (edge=="TOP" or edge=="BOTTOM") and 1 or 10)
        line:SetColorTexture(.52,.35,.14,.98)
    end
    frame.fill,frame.trackWidth=fill,178; frame:Hide()
    self.minimalCastFrame=frame
    local guard=CreateFrame("Frame",nil,self.visibilityRoot,"SecureHandlerStateTemplate")
    if RegisterStateDriver then
        guard:SetFrameRef("session",self.bar); guard:SetFrameRef("tools",self.toolBar); guard:SetFrameRef("minimal",frame)
        for i,field in ipairs({"castButton","bindButton","closeButton"}) do guard:SetFrameRef("info-"..i,self[field]) end
        guard:SetAttribute("_onstate-combat",[[
            if newstate=="combat" and self:GetAttribute("minimal-active") then
                self:GetFrameRef("minimal"):Hide()
                self:GetFrameRef("tools"):SetAlpha(self:GetAttribute("restore-tool-alpha") or 1)
                if self:GetFrameRef("session"):IsShown() then
                    if self:GetAttribute("restore-tools") then self:GetFrameRef("tools"):Show() end
                    local enabled=self:GetAttribute("restore-information")
                    for i=1,3 do
                        local control=self:GetFrameRef("info-"..i)
                        control:SetAlpha(enabled and 1 or 0)
                        control:EnableMouse(enabled and true or false)
                    end
                end
                self:SetAttribute("minimal-active",nil)
            end
        ]])
        guard.minimalReady=pcall(RegisterStateDriver,guard,"combat","[combat]combat;peace")
    end
    self.minimalCastGuard=guard
    self.bar:HookScript("OnHide",function() self:SyncMinimalFishingView() end)
end
local function RestoreFlyoutAlpha(state)
    for _,entry in ipairs(state.flyouts or {}) do
        if entry.frame:GetAlpha()==entry.applied then entry.frame:SetAlpha(entry.alpha) end
    end
end
function FF:FinishMinimalFishingView()
    local state,guard=self.minimalViewState,self.minimalCastGuard
    if not state or Combat() then return end
    self.minimalCastChanging=true
    guard:SetScript("OnUpdate",nil); guard:SetAttribute("minimal-active",nil)
    self.minimalCastFrame:Hide()
    RestoreFlyoutAlpha(state)
    self.minimalViewState,self.minimalFishingViewActive=nil,nil
    self.toolBar:SetAlpha(state.toolAlpha)
    if state.toolsShown and self.bar:IsShown() then self.toolBar:Show() end
    self:ApplyFishingInformationLayout()
    self:UpdateFishingFlyoutWatch()
    self:UpdateCompactFishingBarWatch()
    self.minimalCastChanging=nil
end
function FF:PaintMinimalFishingView()
    local state=self.minimalViewState
    if not state or Combat() then return end
    self.minimalCastChanging=true
    local alpha=self:GetFishingHUDOpacity()
    if alpha>0 then
        self.toolBar:SetAlpha(state.toolAlpha*alpha)
        if state.toolsShown and self.bar:IsShown() and not self.toolBar:IsShown() then self.toolBar:Show() end
        for _,entry in ipairs(state.flyouts or {}) do
            if entry.frame:IsShown() and (entry.applied==nil or entry.frame:GetAlpha()==entry.applied) then
                entry.applied=entry.alpha*alpha; entry.frame:SetAlpha(entry.applied)
            end
        end
    else
        -- Hide before resetting alpha: no zero-alpha toolbar/flyout hit areas.
        self.toolBar:Hide(); self.toolBar:SetAlpha(state.toolAlpha)
        for _,entry in ipairs(state.flyouts or {}) do
            if entry.frame==self.masterChefTray and entry.frame:IsShown() then self:CloseFishingQuickTray(true)
            else entry.frame:Hide() end
        end
        RestoreFlyoutAlpha(state); state.flyouts=nil
    end
    self:ApplyFishingInformationLayout()
    self.minimalCastChanging=nil
end
function FF:WatchMinimalFishingView()
    local guard=self.minimalCastGuard
    if guard:GetScript("OnUpdate") then return end
    guard:SetScript("OnUpdate",function(_,elapsed)
        if Combat() then guard:SetScript("OnUpdate",nil); return end
        self:SyncMinimalFishingView()
        local state=self.minimalViewState
        if not state then
            if not self.fishingViewPhase or self.fishingViewPhase.channel then guard:SetScript("OnUpdate",nil) end
            return
        end
        local fadeElapsed=elapsed
        if state.restoreAt and GetTime()>=state.restoreAt then
            fadeElapsed=math.min(elapsed,math.max(0,GetTime()-state.restoreAt))
            state.progress=0; state.restoreAt=nil; state.target=1
        end
        local previous=state.progress
        local direction=state.target==1 and 1 or -1
        state.progress=math.max(0,math.min(1,state.progress+direction*fadeElapsed/FADE_SECONDS))
        if state.progress~=previous then self:PaintMinimalFishingView() end
        if state.progress==1 and state.target==1 then
            self:FinishMinimalFishingView()
            if self.toolBar:IsShown() and self:FishingBarPointerWithin() then self:EnsureFishingBarExpanded() end
            self:SyncMinimalFishingView()
        elseif state.progress==0 and state.target==0 and not state.restoreAt then guard:SetScript("OnUpdate",nil) end
    end)
end
function FF:SyncMinimalFishingView()
    if self.minimalCastChanging or self.fishingViewSyncing then return end
    self.fishingViewSyncing=true
    self:UpdateFishingViewPhase()
    self:SyncMinimalFishingViewState()
    if self:GetBlizzardUIHideMode()=="casts" then self:SyncFishingUIVisibility() end
    self.fishingViewSyncing=nil
end
function FF:SyncMinimalFishingViewState()
    if Combat() then
        -- The restricted endpoint owns protected visibility/input in combat.
        if self.minimalCastGuard then self.minimalCastGuard:SetScript("OnUpdate",nil) end
        return
    end
    local eligible=self.db and self.db.minimalFishingCastView==true and self.bar and self.bar:IsShown() or false
    local phase=self.fishingViewPhase
    local active=phase and phase.channel or false
    local guard,state=self.minimalCastGuard,self.minimalViewState
    if state and (not eligible or not guard:GetAttribute("minimal-active")) then
        self:FinishMinimalFishingView(); state=nil
    end
    if not eligible or not (active or state) then
        if phase and not active and GetTime()<phase.nativeRestoreAt and self:GetBlizzardUIHideMode()=="casts" then
            self:EnsureMinimalFishingView()
            if self.minimalCastGuard then self:WatchMinimalFishingView() end
        elseif guard then guard:SetScript("OnUpdate",nil) end
        return
    end
    if active then
        self:EnsureMinimalFishingView(); guard=self.minimalCastGuard
        if not (guard and guard.minimalReady) then return end
        if not state then
            self.minimalCastChanging=true
            self:FinishFishingBarTransition(true)
            state={progress=1,target=0,toolsShown=self.toolBar:IsShown(),toolAlpha=self.toolBar:GetAlpha() or 1,flyouts={}}
            for _,field in ipairs({"masterChefTray","gearPicker","lurePicker","utilityPicker","settingsPicker","journalPicker"}) do
                local panel=self[field]
                if panel and panel:IsShown() then state.flyouts[#state.flyouts+1]={frame=panel,alpha=panel:GetAlpha() or 1} end
            end
            self.minimalViewState=state; self.minimalFishingViewActive=true
            if self.quickTrayDismiss then self.quickTrayDismiss:SetScript("OnUpdate",nil) end
            self:UpdateCompactFishingBarWatch()
            guard:SetAttribute("restore-tools",state.toolsShown)
            guard:SetAttribute("restore-tool-alpha",state.toolAlpha)
            guard:SetAttribute("restore-information",self:GetFishingInformationOptions().enabled)
            guard:SetAttribute("minimal-active",true)
            self.minimalCastChanging=nil
        end
        if not state.channel then
            state.channel=true; state.restoreAt=nil; state.target=0
            self.minimalCastFrame:SetScale(self.bar:GetScale()); self.minimalCastFrame:Show()
            if self.RefreshFishingLayer then self:RefreshFishingLayer() end
            self:WatchMinimalFishingView()
        end
    elseif state and state.channel then
        state.channel=false; state.target=0; state.restoreAt=phase.restoreAt
        self.minimalCastFrame:Hide(); self:WatchMinimalFishingView()
    elseif state and state.restoreAt then
        state.restoreAt=phase.restoreAt
    end
end
function FF:SyncFishingViewVisibility(hiding)
    self:SyncFishingChatVisibility(hiding)
    if not hiding then self:SyncMinimalFishingView() end
end
