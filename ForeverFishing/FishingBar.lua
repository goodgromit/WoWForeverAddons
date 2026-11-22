-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local BAR_MOTION_SECONDS = .16
local function InCombat() return InCombatLockdown and InCombatLockdown() end
local function MouseHeld()
    return IsMouseButtonDown and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton"))
end
FF.fishingBarCategories = {
    {id="gear",field="gearButton",arrow="gearArrow",keepActionShown=true},
    {id="lure",field="lureButton",arrow="lureArrow",keepActionShown=true},
    {id="chef",field="masterChefButton"},
    {id="journal",field="journalButton",arrow="journalArrow"},
    {id="utility",field="utilityButton",arrow="utilityArrow",enabled=function(self) return self.db and self.db.showUtilityButton==true end},
    {id="settings",field="settingsButton",arrow="settingsArrow"},
}
function FF:GetFishingBarCategories()
    local result = {}
    for _,entry in ipairs(self.fishingBarCategories) do
        if not entry.enabled or entry.enabled(self) then result[#result+1]=entry end
    end
    return result
end
function FF:GetFishingBarCategoryCount() return #self:GetFishingBarCategories() end

function FF:GetFishingBarOrientation()
    return self.db and self.db.fishingBarOrientation == "vertical" and "vertical" or "horizontal"
end
function FF:GetFishingBarAutoCollapse()
    if not self.db then return false end
    if type(self.db.fishingBarAutoCollapse)=="boolean" then return self.db.fishingBarAutoCollapse end
    -- Prior development compact choices become one hover policy; no saved facts reset.
    return self.db.fishingBarMode=="hover" or self.db.fishingBarMode=="click"
end
local function Refresh(self)
    self.compactBarExpanded,self.compactBarAway,self.compactBarAnchorField=nil,nil,nil
    self:ApplyIconBarSpacing()
    if self.settingsPanel and self.settingsPanel.RefreshFlyoutControls then self.settingsPanel:RefreshFlyoutControls() end
end
function FF:SetFishingBarOrientation(value)
    if not self.db or (value~="horizontal" and value~="vertical") then return false end
    self.db.fishingBarOrientation=value; Refresh(self); return true
end
function FF:SetFishingBarAutoCollapse(value)
    if not self.db then return false end
    self.db.fishingBarAutoCollapse=value==true; Refresh(self); return true
end
-- These are the exact attention results used by RefreshSmartButtons, not a
-- second inventory/lure eligibility policy. Only collapsed presentation follows
-- changes; the chosen anchor/order is held throughout an expanded interaction.
function FF:RefreshFishingBarAttention(gear, lure)
    local changed=self.compactBarGearAttention~=gear or self.compactBarLureAttention~=lure
    self.compactBarGearAttention,self.compactBarLureAttention=gear,lure
    if changed and self.compactBarWatch and self:GetFishingBarAutoCollapse()
        and not self.compactBarExpanded and not self.compactBarMotion and not self:HasOpenFishingFlyout() then
        self:ApplyFishingBarPresentation()
    end
end
function FF:GetCollapsedFishingBarField()
    return not self.compactBarGearAttention and self.compactBarLureAttention and "lureButton" or "gearButton"
end
local function Bounds(frame, viewport)
    if not frame or not frame.IsVisible or not (viewport or frame:IsVisible()) then return end
    local l,r,b,t,s=frame:GetLeft(),frame:GetRight(),frame:GetBottom(),frame:GetTop(),frame:GetEffectiveScale()
    if l and r and b and t and s and s>0 then return l*s,r*s,b*s,t*s end
end
function FF:FishingBarPointerWithin()
    if not GetCursorPosition then return false end
    local x,y=GetCursorPosition()
    if not x or not y then return false end
    local motion=self.compactBarMotion
    local area=motion and motion.bounds
    if area and x>=area[1]-6 and x<=area[2]+6 and y>=area[3]-6 and y<=area[4]+6 then return true end
    local l,r,b,t
    local function Include(frame)
        local fl,fr,fb,ft=Bounds(frame)
        if fl then l,r,b,t=math.min(l or fl,fl),math.max(r or fr,fr),math.min(b or fb,fb),math.max(t or ft,ft) end
    end
    Include(self[self.compactBarAnchorField or "gearButton"])
    if not self:GetFishingBarAutoCollapse() or self.compactBarExpanded then
        for _,entry in ipairs(self:GetFishingBarCategories()) do Include(self[entry.field]); Include(self[entry.arrow]) end
    end
    if l and x>=l-6 and x<=r+6 and y>=b-6 and y<=t+6 then return true end
    local owner=GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner()
    if owner then
        local owned=false
        for _,entry in ipairs(self:GetFishingBarCategories()) do
            if owner==self[entry.field] or owner==self[entry.arrow] then owned=true end
        end
        local tl,tr,tb,tt=Bounds(GameTooltip)
        return owned and tl and x>=tl and x<=tr and y>=tb and y<=tt or false
    end
    return false
end
function FF:UpdateCompactFishingBarWatch()
    local watch=self.compactBarWatch
    if not watch then return end
    local visible=self.toolBar:IsShown() and self:GetFishingBarAutoCollapse() and not self.minimalFishingViewActive
    if visible then watch:RegisterEvent("PLAYER_REGEN_DISABLED"); watch:RegisterEvent("PLAYER_LEAVING_WORLD")
    else watch:UnregisterAllEvents() end
    local ticking=visible and (self.compactBarMotion or (self.compactBarExpanded and not self:HasOpenFishingFlyout()))
        and not (InCombatLockdown and InCombatLockdown())
    if not ticking then watch:SetScript("OnUpdate",nil); return end
    if not watch:GetScript("OnUpdate") then
        watch:SetScript("OnUpdate",function(_,elapsed)
            if InCombatLockdown and InCombatLockdown() then watch:SetScript("OnUpdate",nil); return end
            local motion=self.compactBarMotion
            if motion then
                if motion.target==0 and self:FishingBarPointerWithin() then self:EnsureFishingBarExpanded() end
                if self:HasOpenFishingFlyout() or self.toolBar.moving or self.toolBar.scaling or MouseHeld() then
                    self:FinishFishingBarTransition(true)
                    return
                end
                motion.progress=math.max(0,math.min(1,motion.progress+(motion.target==1 and 1 or -1)*elapsed/BAR_MOTION_SECONDS))
                self:PaintFishingBarTransition(motion)
                if motion.progress==motion.target then self:FinishFishingBarTransition() end
            end
            if not self.compactBarExpanded then return end
            if self:HasOpenFishingFlyout() or self.toolBar.moving or self.toolBar.scaling
                or MouseHeld() or self:FishingBarPointerWithin() then self.compactBarAway=nil; return end
            self.compactBarAway=(self.compactBarAway or 0)+elapsed
            if self.compactBarAway>=.3 then self:CollapseFishingBar() end
        end)
    end
end
-- Moving controls have no mouse input. The original selected Gear/Lure control
-- is excluded, keeping its anchor, tooltip and native click unchanged.
function FF:PaintFishingBarTransition(motion)
    if InCombat() then return end
    local p=motion.progress
    local eased=p*p*(3-2*p)
    self.compactBarProgress=p
    for _,entry in ipairs(motion.frames) do
        if not entry.anchor then
            local frame=entry.frame
            frame:SetAlpha(eased)
            if entry.x then
                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT",self.toolBar,"TOPLEFT",entry.x*eased,entry.y*eased)
            end
        end
    end
end
function FF:FinishFishingBarTransition(expanded)
    if not self.compactBarMotion or InCombat() then return end
    local target=expanded and 1 or self.compactBarMotion.target
    self.compactBarMotion=nil
    self.compactBarWatch:SetAttribute("bar-moving",nil)
    self.compactBarExpanded=target==1 and true or nil
    if target==0 then self.compactBarAnchorField=nil end
    self:ApplyFishingBarPresentation()
end
-- Offsets for the remaining buttons; the selected Gear/Lure owns (0, 0).
function FF:ResolveFishingBarOffsets(count, room)
    local step=48+self:GetIconBarSpacing()
    room=room or {left=10000,right=10000,above=10000,below=10000}
    local vertical=self:GetFishingBarOrientation()=="vertical"
    local before,after=vertical and room.above or room.left,vertical and room.below or room.right
    local direction=(after>=count*step or after>=before) and 1 or -1
    local primary=math.max(1,math.min(count,math.floor((direction==1 and after or before)/step)))
    local secondaryRoom=vertical and {room.right,room.left} or {room.below,room.above}
    local bands=math.ceil(count/primary)
    local cross=(secondaryRoom[1]>=(bands-1)*step or secondaryRoom[1]>=secondaryRoom[2]) and 1 or -1
    local offsets={}
    for index=1,count do
        local along=((index-1)%primary)+1
        local across=math.floor((index-1)/primary)
        offsets[index]=vertical and {cross*across*step,-direction*along*step}
            or {direction*along*step,-cross*across*step}
    end
    return offsets
end
function FF:ApplyFishingBarPresentation(animate)
    local bar=self.toolBar
    if not bar then return end
    if InCombatLockdown and InCombatLockdown() then self.compactBarLayoutPending=true; return end
    self.compactBarLayoutPending=nil
    if not self.compactBarWatch or not self.gearButton or not self.lureButton then return end
    local expanded=not self:GetFishingBarAutoCollapse() or self.compactBarExpanded or self:HasOpenFishingFlyout()
    if expanded and self:GetFishingBarAutoCollapse() then self.compactBarExpanded=true end
    local motion=self.compactBarMotion
    if motion and animate then
        motion.target=expanded and 1 or 0
        self:UpdateCompactFishingBarWatch()
        return
    end
    if motion then
        self.compactBarMotion=nil
        self.compactBarWatch:SetAttribute("bar-moving",nil)
    end
    local moving=animate and self:GetFishingBarAutoCollapse() and self.toolBar:IsShown()
        and self.compactBarWatch.compactBarMotionReady and self.compactBarProgress~=nil
        and self.compactBarProgress~=(expanded and 1 or 0) and not self:HasOpenFishingFlyout()
        and not self.toolBar.moving and not self.toolBar.scaling and not MouseHeld()
    local anchor="gearButton"
    if self:GetFishingBarAutoCollapse() then
        anchor=expanded and self.compactBarAnchorField or self:GetCollapsedFishingBarField()
        anchor=anchor or self:GetCollapsedFishingBarField()
        if moving then anchor=self.compactBarAnchorField or anchor end
    end
    self.compactBarAnchorField=anchor
    bar:SetSize(48,70)
    local room
    local l,r,b,t=Bounds(bar)
    if t then b=t-48*bar:GetEffectiveScale() end
    local sl,sr,sb,st=Bounds(UIParent,true)
    local scale=bar:GetEffectiveScale()
    if l and sl and scale and scale>0 then
        room={left=(l-sl)/scale,right=(sr-r)/scale,above=(st-t)/scale,below=(b-sb)/scale}
    end
    local entries=self:GetFishingBarCategories()
    local offsets=self:ResolveFishingBarOffsets(#entries-1,room)
    moving=moving and l and sl and scale and scale>0
    for _,entry in ipairs(self.fishingBarCategories) do
        if entry.enabled and not entry.enabled(self) then
            if self[entry.field] then self[entry.field]:Hide() end
            if self[entry.arrow] then self[entry.arrow]:Hide() end
        end
    end
    if moving then
        motion={progress=self.compactBarProgress,target=expanded and 1 or 0,frames={},bounds={l,r,b,t}}
        local index=0
        for _,entry in ipairs(entries) do
            local selected=entry.field==anchor
            if not selected then index=index+1 end
            local offset=selected and {0,0} or offsets[index]
            local button,arrow=self[entry.field],self[entry.arrow]
            if button then
                motion.frames[#motion.frames+1]={frame=button,x=offset[1],y=offset[2],anchor=selected}
                local fl,ft=l+offset[1]*scale,t+offset[2]*scale
                motion.bounds[1]=math.min(motion.bounds[1],fl)
                motion.bounds[2]=math.max(motion.bounds[2],fl+button:GetWidth()*scale+7*scale)
                motion.bounds[3]=math.min(motion.bounds[3],ft-70*scale)
                motion.bounds[4]=math.max(motion.bounds[4],ft)
            end
            if arrow then motion.frames[#motion.frames+1]={frame=arrow} end
        end
        local watch=self.compactBarWatch
        watch:SetAttribute("motion-count",#motion.frames)
        for index,entry in ipairs(motion.frames) do
            watch:SetFrameRef("motion-"..index,entry.frame)
            watch:SetAttribute("motion-x-"..index,entry.x)
            watch:SetAttribute("motion-y-"..index,entry.y)
            if not entry.anchor then
                local owner=GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner()
                if owner==entry.frame then GameTooltip:Hide() end
                entry.frame:EnableMouse(false)
                entry.frame:SetAlpha(0)
                entry.frame:Show()
            end
        end
        watch:SetAttribute("bar-moving",true)
        self.compactBarMotion=motion
        self:PaintFishingBarTransition(motion)
        self:UpdateCompactFishingBarWatch()
        if self.fishingOverlapPanelVisible then self:RefreshFishingLayer() end
        return
    end
    local index=0
    for _,entry in ipairs(entries) do
        local selected=entry.field==anchor
        if not selected then index=index+1 end
        local offset=selected and {0,0} or offsets[index]
        local visible=expanded or selected
        local button=self[entry.field]
        if button then
            button:ClearAllPoints(); button:SetPoint("TOPLEFT",bar,"TOPLEFT",offset[1],offset[2])
            if entry.keepActionShown then
                button:Show(); button:SetAlpha(visible and 1 or 0); button:EnableMouse(visible and true or false)
            else button:SetAlpha(1); button:EnableMouse(true); button:SetShown(expanded and true or false) end
        end
        if self[entry.arrow] then
            self[entry.arrow]:SetAlpha(1); self[entry.arrow]:EnableMouse(true)
            self[entry.arrow]:SetShown(expanded and true or false)
        end
    end
    self.compactBarProgress=expanded and 1 or 0
    self:UpdateCompactFishingBarWatch()
    if self.fishingOverlapPanelVisible then self:RefreshFishingLayer() end
end
function FF:EnsureFishingBarExpanded()
    if not self.compactBarWatch or self.compactBarExpanded or not self:CanRevealFishingFlyout() then return end
    self.compactBarExpanded=true; self.compactBarAway=nil; self:ApplyFishingBarPresentation(true)
end
function FF:SyncCompactFishingBarForFlyout()
    if self:HasOpenFishingFlyout() then self:EnsureFishingBarExpanded() end
    self:UpdateCompactFishingBarWatch()
end
function FF:CollapseFishingBar(immediate)
    if not self.compactBarWatch or InCombatLockdown and InCombatLockdown() then return end
    if not immediate and MouseHeld() then return end
    self:CloseFishingFlyouts()
    self.compactBarExpanded,self.compactBarAway=nil,nil
    if immediate then self.compactBarAnchorField=nil end
    self:ApplyFishingBarPresentation(not immediate)
end
function FF:InitializeFishingCompactBar()
    -- Hover reveals only the bar. Category flyouts require an explicit click;
    -- these hooks leave the original Gear/Lure actions and tooltips intact.
    for _,button in ipairs({self.gearButton,self.lureButton}) do
        button:HookScript("OnEnter",function() self:EnsureFishingBarExpanded() end)
    end
    local watch=CreateFrame("Frame",nil,self.visibilityRoot,"SecureHandlerStateTemplate")
    if RegisterStateDriver and watch.SetFrameRef and watch.SetAttribute then
        watch:SetFrameRef("tools",self.toolBar)
        -- Lockdown may begin between animation frames. Restricted code settles
        -- the precomputed expanded pose; ordinary Lua never moves protected
        -- controls or changes their mouse flags during combat.
        watch:SetAttribute("_onstate-combat",[[
            if newstate=="combat" and self:GetAttribute("bar-moving") then
                for i=1,(self:GetAttribute("motion-count") or 0) do
                    local button=self:GetFrameRef("motion-"..i)
                    local x=self:GetAttribute("motion-x-"..i)
                    if x then
                        button:ClearAllPoints()
                        button:SetPoint("TOPLEFT",self:GetFrameRef("tools"),"TOPLEFT",x,self:GetAttribute("motion-y-"..i))
                    end
                    button:SetAlpha(1)
                    button:EnableMouse(true)
                    button:Show()
                end
                self:SetAttribute("bar-moving",nil)
            end
        ]])
        watch.compactBarMotionReady=pcall(RegisterStateDriver,watch,"combat","[combat]combat;peace")
    end
    watch:SetScript("OnEvent",function(_,event)
        if self.compactBarMotion and event=="PLAYER_REGEN_DISABLED" then
            self.compactBarMotion=nil; self.compactBarExpanded=true; self.compactBarProgress=1
        end
        watch:SetScript("OnUpdate",nil); watch:UnregisterAllEvents(); self.compactBarLayoutPending=true
        if event=="PLAYER_LEAVING_WORLD" then self:CollapseFishingBar(true) end
    end)
    self.compactBarWatch=watch
    self.toolBar:HookScript("OnHide",function()
        self.compactBarExpanded,self.compactBarAway,self.compactBarAnchorField=nil,nil,nil
        self.compactBarMotion,self.compactBarProgress=nil,nil
        if not InCombat() then watch:SetAttribute("bar-moving",nil) end
        watch:SetScript("OnUpdate",nil); watch:UnregisterAllEvents()
    end)
    self.toolBar:HookScript("OnShow",function() self:ApplyFishingBarPresentation() end)
    self:ApplyFishingBarPresentation()
end
