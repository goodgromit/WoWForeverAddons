-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- A separate, input-transparent binding legend only. Blizzard owns every HUD
-- slot, icon, action and binding stack; never draw over or update its buttons.
local function Read(fn,...)
    if type(fn)~="function" then return end
    local ok,value=pcall(fn,...)
    if ok and not (issecretvalue and issecretvalue(value)) then return value end
end
function FF:ClearFishingGamepadHUD()
    self.gamepadHUDPending=nil
    self.gamepadHUDLease=nil
    if self.gamepadHUDListener then self.gamepadHUDListener:SetScript("OnUpdate",nil) end
    if self.gamepadHUDLegend then self.gamepadHUDLegend:Hide() end
end

function FF:PositionFishingGamepadHUDLegend()
    local legend=self.gamepadHUDLegend
    if not legend then return end
    local scale=Read(UIParent.GetEffectiveScale,UIParent)
    local rootScale=Read(WorldFrame.GetEffectiveScale,WorldFrame)
    scale=type(scale)=="number" and scale>0 and scale or 1
    rootScale=type(rootScale)=="number" and rootScale>0 and rootScale or 1
    -- Numeric screen geometry avoids anchoring our frame to protected native
    -- frames. Follow both visible XP/reputation containers, including scaling.
    local bottom=Read(WorldFrame.GetBottom,WorldFrame) or 0
    local offset=8
    local manager=StatusTrackingBarManager
    for _,bar in pairs(manager and manager.barContainers or {}) do
        if Read(bar.IsVisible,bar)==true then
            local top=Read(bar.GetTop,bar);local barScale=Read(bar.GetEffectiveScale,bar)
            if type(top)=="number" and type(barScale)=="number" then
                offset=math.max(offset,(top*barScale-bottom*rootScale)/scale+6)
            end
        end
    end
    local screenWidth=Read(WorldFrame.GetWidth,WorldFrame)
    local width=math.min(1000,math.max(200,(type(screenWidth)=="number" and screenWidth*rootScale/scale or 1024)-32))
    if legend.displayScale==scale/rootScale and legend.displayWidth==width and legend.bottomOffset==offset then return end
    legend.displayScale,legend.displayWidth,legend.bottomOffset=scale/rootScale,width,offset
    legend:SetScale(scale/rootScale)
    legend:ClearAllPoints();legend:SetPoint("BOTTOM",WorldFrame,"BOTTOM",0,offset)
    legend.text:SetWidth(width-16)
    local height=math.max(18,math.ceil(legend.text:GetStringHeight()))
    legend.text:SetHeight(height);legend:SetSize(width,height+8)
end

function FF:UpdateFishingGamepadHUDPresentation()
    local lease=self.gamepadHUDLease
    if not lease or lease.db~=self.db or lease.bar~=self.bar or not self.db.gamepadMode
        or self.gamepadHUDLeavingWorld or not self:IsFishingSessionOpen()
        or not UIParent:IsVisible() or (InCombatLockdown and InCombatLockdown()) then
        self:ClearFishingGamepadHUD();return
    end
    -- Visual geometry/alpha only: no binding refresh, gameplay or cast scan.
    self:PositionFishingGamepadHUDLegend()
    local alpha=Read(UIParent.GetEffectiveAlpha,UIParent)
    self.gamepadHUDLegend:SetAlpha(type(alpha)=="number" and alpha or 1)
end

function FF:GetFishingGamepadHUDPlan()
    local plan={};local needed,jump=self:GetFishingJumpState()
    local primaryAlias=false
    for _,key in ipairs({needed and jump or false,self:GetFishingActionKey("close") or false}) do
        if key then
            local alias=self:GetFishingNativeGamepadChordKey(key)
            local actual=alias and Read(GetBindingAction,alias,true)
            if alias==self:GetFishingInputKey() and (actual=="JUMP" or actual=="CLICK ForeverFishingCloseControlsActionButton:LeftButton") then primaryAlias=true end
        end
    end
    for _,action in ipairs(self.fishingActionOrder) do
        local definition=self.fishingActions[action]
        local key
        if action=="jump" then key=needed and jump or nil else key=self:GetFishingActionKey(action) end
        if key and definition.scope~="always" and not self:FishingActionBindingConflict(action,key) then
            local effectiveKey=key
            local chordOwner
            if action=="fishing" then effectiveKey,chordOwner=self:GetFishingPrimaryBindingKey(key) end
            local binding=effectiveKey and Read(GetBindingAction,effectiveKey,true)
            local expected=definition.target and ("CLICK "..definition.target..":LeftButton")
            local owns=action=="jump" and binding=="JUMP" or expected and binding==expected
            local alias=self:GetFishingNativeGamepadChordKey(key)
            if alias and Read(GetBindingAction,alias,true)~=binding then owns=false end
            if action=="fishing" then
                -- A valid native chord only owns the face button while its
                -- triggers are held. Show the assigned chord so players know what to press.
                owns=(chordOwner and not effectiveKey) or primaryAlias or binding==expected or binding=="CLICK ForeverFishingGuardButton:LeftButton"
                    or binding=="INTERACTTARGET" or binding=="INTERACTMOUSEOVER"
                    or binding=="SPELL "..self:FishingName()
            end
            if self:IsFishingGamepadKey(key) and owns then
                local title=action=="fishing" and self:LocalizedText("settings.fishing-key") or definition.label
                plan[#plan+1]={action=action,key=key,title=title,
                    waiting=action=="fishing" and binding=="CLICK ForeverFishingGuardButton:LeftButton"}
            end
        end
    end
    return plan
end


function FF:RefreshFishingGamepadHUD()
    if self.fishingStartupFailed or self.gamepadHUDStartupFailed then return end
    self:ClearFishingGamepadHUD()
    if self.gamepadHUDLeavingWorld or not self.db or not self.db.gamepadMode or not self:IsFishingSessionOpen()
        or (InCombatLockdown and InCombatLockdown()) or not UIParent:IsVisible()
        or not self:FishingGamepadInputAvailable() or self.journalInputFocus or self.settingsKeyboardFocus
        or self.fishingResetInput or self.captureCommitPending or (self.capture and self.capture:IsShown()) then return end
    local captions={}
    for _,item in ipairs(self:GetFishingGamepadHUDPlan()) do
        captions[#captions+1]=self:GetFishingBindingLabel(item.key).." · "..item.title
    end
    if #captions==0 then return end
    if not self.gamepadHUDLegend then
        local legend=CreateFrame("Frame",nil,WorldFrame);legend:EnableMouse(false)
        legend:SetFrameStrata("HIGH");legend:SetFrameLevel(10);legend:SetClampedToScreen(true)
        local text=legend:CreateFontString(nil,"OVERLAY")
        self:SetDisplayFont(text,"Fonts\\2002.TTF",13,"")
        text:SetTextColor(1,.84,.39);text:SetWordWrap(true);text:SetJustifyH("CENTER")
        text:SetPoint("TOPLEFT",legend,"TOPLEFT",8,-4);legend.text=text
        self.gamepadHUDLegend=legend
    end
    local legend=self.gamepadHUDLegend
    legend.text:SetText(table.concat(captions,"   •   "))
    legend.displayWidth=nil -- Re-measure when binding text/language changes.
    self.gamepadHUDLease={db=self.db,bar=self.bar}
    self:UpdateFishingGamepadHUDPresentation();legend:Show()
    local elapsed=0
    self.gamepadHUDListener:SetScript("OnUpdate",function(_,delta)
        elapsed=elapsed+delta
        if elapsed<.1 then return end
        elapsed=0;self:UpdateFishingGamepadHUDPresentation()
    end)
end

function FF:QueueFishingGamepadHUD()
    if self.fishingStartupFailed or self.gamepadHUDStartupFailed or self.gamepadHUDPending then return end
    local request={};self.gamepadHUDPending=request
    C_Timer.After(0,function()
        if self.gamepadHUDPending~=request then return end
        self:RefreshFishingGamepadHUD()
    end)
end

function FF:InitializeFishingGamepadHUD()
    if self.gamepadHUDListener or type(hooksecurefunc)~="function" then return end
    local listener=CreateFrame("Frame",nil,WorldFrame);self.gamepadHUDListener=listener
    hooksecurefunc(self,"ApplyBindings",function() self:RefreshFishingGamepadHUD() end)
    -- Only root visibility, not native action-bar pages/buttons/overrides. A
    -- dungeon or a changed native crossbar layout cannot veto a valid legend.
    UIParent:HookScript("OnShow",function() self:QueueFishingGamepadHUD() end)
    UIParent:HookScript("OnHide",function() self:ClearFishingGamepadHUD() end)
    for _,event in ipairs({"ADDON_LOADED","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","PLAYER_LEAVING_WORLD","PLAYER_LOGOUT",
        "PLAYER_ENTERING_WORLD","INPUT_DEVICE_INTERFACE_TRANSITION","GAME_PAD_CONNECTED","GAME_PAD_DISCONNECTED","UPDATE_BINDINGS","CVAR_UPDATE"}) do
        listener:RegisterEvent(event)
    end
    listener:SetScript("OnEvent",function(_,event,name)
        if event=="CVAR_UPDATE" and (issecretvalue and issecretvalue(name) or type(name)~="string"
            or not (name:lower():match("^gamepad") or name:lower()=="inputdeviceinterfacestyle")) then return end
        if event=="PLAYER_LEAVING_WORLD" or event=="PLAYER_LOGOUT" then self.gamepadHUDLeavingWorld=true end
        if event=="PLAYER_ENTERING_WORLD" then self.gamepadHUDLeavingWorld=nil end
        if event=="PLAYER_REGEN_DISABLED" or self.gamepadHUDLeavingWorld then self:ClearFishingGamepadHUD();return end
        self:QueueFishingGamepadHUD()
    end)
    self:QueueFishingGamepadHUD()
end
