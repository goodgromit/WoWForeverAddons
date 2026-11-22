-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Action IDs are separate from retired flyout assignments: a saved menu key
-- must never become a consumable-use key without a deliberate assignment.
local function L(key,...) return FF:LocalizedText(key,...) end
function FF:IsFishingGamepadMode()
    return self.db and (self.db.gamepadMode==true or self.gamepadModePending==true) or false
end
local function SavedGamepadFishingKey(self)
    local key=type(self.db.gamepadBindings)=="table" and self.db.gamepadBindings.fishing
    return self:IsFishingGamepadActionKey("fishing",key) and key or nil
end
local gamepadNames={PAD1="a",PAD2="b",PAD3="x",PAD4="y",PADDUP="up",PADDDOWN="down",PADDLEFT="left",PADDRIGHT="right",
    PADLSTICK="left-stick",PADRSTICK="right-stick",PADLSHOULDER="lb",PADRSHOULDER="rb"}
local gamepadModifiers={"ALT","CTRL","SHIFT"}
local physicalModifiers={"PADLTRIGGER","PADRTRIGGER","PADLSHOULDER","PADRSHOULDER"}
local modifierLabels={PADLTRIGGER="lt",PADRTRIGGER="rt",PADLSHOULDER="lb",PADRSHOULDER="rb"}
local function IsShoulderButton(key)
    return key=="PADLSHOULDER" or key=="PADRSHOULDER"
end
local function FishingGamepadBase(key)
    for _,modifier in ipairs(gamepadModifiers) do key=key:gsub("^"..modifier.."%-","") end
    return key
end
local function FishingTriggerChord(key)
    if type(key)~="string" then return end
    local base,left=key:gsub("^PADLTRIGGER%-","")
    local right
    base,right=base:gsub("^PADRTRIGGER%-","")
    if left+right>0 and gamepadNames[base] and not IsShoulderButton(base) then
        return base,left==1,right==1
    end
end
local function NativeGamepadUI()
    if not (InputUtil and type(InputUtil.IsGamepadUIEnabled)=="function") then return false end
    local ok,native=pcall(InputUtil.IsGamepadUIEnabled)
    if ok and not (issecretvalue and issecretvalue(native)) and type(native)=="boolean" then return native end
end
function FF:GetFishingGamepadButtonDown(button)
    if type(IsKeyDown)~="function" then return end
    local ok,held=pcall(IsKeyDown,button)
    if ok and not (issecretvalue and issecretvalue(held)) and type(held)=="boolean" then return held end
end
local function IsControllerBindingToken(key)
    -- Binding tokens have their own namespace after modifiers. NUMPAD keys
    -- arrive as keyboard input even when a mouse is mapped to send them.
    return type(key)=="string" and (key:match("^PAD[%u%d]+$")~=nil or key:match("%-PAD[%u%d]+$")~=nil)
end
local function KeyboardBindingKey(key)
    if type(key)=="string" and key~="" and not IsControllerBindingToken(key) then return key end
end
function FF:GetFishingInputKey()
    if not self.db then return end
    if self:IsFishingGamepadMode() then return SavedGamepadFishingKey(self) end
    return KeyboardBindingKey(self.db.key)
end
function FF:GetFishingGamepadModifierButton(modifier)
    local suffix=modifier=="CTRL" and "Ctrl" or modifier=="ALT" and "Alt" or "Shift"
    local read=C_CVar and C_CVar.GetCVar or GetCVar
    if type(read)~="function" then return end
    local ok,value=pcall(read,"GamePadEmulate"..suffix)
    if ok and not (issecretvalue and issecretvalue(value)) and type(value)=="string" and value:match("^PAD") then return value end
end
function FF:GetFishingLeftTriggerChord(button)
    local prefix=""
    for _,modifier in ipairs(gamepadModifiers) do
        if self:GetFishingGamepadModifierButton(modifier)=="PADLTRIGGER" then prefix=prefix..modifier.."-" end
    end
    if prefix~="" then return prefix..button end
end
function FF:IsFishingGamepadKey(key)
    if type(key)~="string" then return false end
    local base=FishingGamepadBase(key)
    return FishingTriggerChord(key)~=nil or gamepadNames[base]~=nil
end
function FF:IsFishingGamepadActionKey(action,key)
    if not self:IsFishingGamepadKey(key) then return false end
    local base=FishingGamepadBase(key)
    if action=="fishing" then return base==key or FishingTriggerChord(key)~=nil end
    if FishingTriggerChord(key) or key=="PAD1" then return false end
    if IsShoulderButton(base) and key~=base then return false end
    return base==key or action=="jump" or action=="close"
end
local function NativeGamepadLabel(key)
    if not GetBindingText then return end
    local ok,text=pcall(GetBindingText,key,"KEY_")
    if ok and not (issecretvalue and issecretvalue(text)) and type(text)=="string" and text~="" and text~=key then
        return text
    end
end
function FF:GetFishingGamepadLabel(key)
    if not self:IsFishingGamepadKey(key) then return end
    local face,left,right=FishingTriggerChord(key)
    if face then
        local labels={}
        if left then labels[#labels+1]=NativeGamepadLabel("PADLTRIGGER") or L("gamepad.modifier.lt") end
        if right then labels[#labels+1]=NativeGamepadLabel("PADRTRIGGER") or L("gamepad.modifier.rt") end
        labels[#labels+1]=self:GetFishingGamepadLabel(face)
        return table.concat(labels," + ")
    end
    local base=key;local labels={}
    for _,modifier in ipairs(gamepadModifiers) do
        if base:find("^"..modifier.."%-") then
            base=base:sub(#modifier+2)
            local button=self:GetFishingGamepadModifierButton(modifier)
            labels[#labels+1]=(button and NativeGamepadLabel(button)) or L("gamepad.modifier."..(modifierLabels[button] or modifier:lower()))
        end
    end
    if base~=key then
        labels[#labels+1]=self:GetFishingGamepadLabel(base)
        return table.concat(labels," + ")
    end
    return NativeGamepadLabel(key) or L(modifierLabels[key] and "gamepad.modifier."..modifierLabels[key] or "gamepad.button."..gamepadNames[key])
end
function FF:IsFishingGamepadModified()
    if InputUtil and type(InputUtil.IsGamepadUIEnabled)=="function" then
        local ok,enabled=pcall(InputUtil.IsGamepadUIEnabled)
        if ok and enabled==false then return IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() end
    end
    for _,name in ipairs({"IsHUDBindingModifierDown","IsTargetingModifierDown","IsLeftModifierDown","IsRightModifierDown"}) do
        local query=GamepadMode and GamepadMode[name]
        if type(query)=="function" then
            local ok,down=pcall(query)
            if not ok or (issecretvalue and issecretvalue(down)) or down then return true end
        end
    end
    return false
end
function FF:FishingGamepadInputAvailable(allowFishingLoot)
    if self.fishingResetInput then return false end
    if not self:IsFishingGamepadMode() then return true end
    if self.gamepadInputLeavingWorld then return false end
    if self.gamepadInputStartupFailed or self.gamepadDisconnected then return false end
    if not (C_GamePad and type(C_GamePad.IsEnabled)=="function") then return false end
    if C_GamePad and type(C_GamePad.IsEnabled)=="function" then
        local ok,enabled=pcall(C_GamePad.IsEnabled)
        if not ok or (issecretvalue and issecretvalue(enabled)) or not enabled then return false end
    end
    local nativeMode=false
    if InputUtil and type(InputUtil.IsGamepadUIEnabled)=="function" then
        local ok,enabled=pcall(InputUtil.IsGamepadUIEnabled)
        if not ok or (issecretvalue and issecretvalue(enabled)) then return false end
        nativeMode=enabled==true
    end
    -- Controller input is independent of the selected native UI. Only the
    -- native gamepad interface owns this contextual binding stack/modifiers.
    if nativeMode then
        for _,name in ipairs({"IsHUDBindingModifierDown","IsTargetingModifierDown"}) do
            local query=GamepadMode and GamepadMode[name]
            if type(query)=="function" then
                local ok,down=pcall(query)
                if not ok or (issecretvalue and issecretvalue(down)) or down then return false end
            end
        end
        local manager=GamepadSharedUtility and GamepadSharedUtility.InputBindingManager
        if not (manager and type(manager.IsOnlyCoreBindingSetActive)=="function") then return false end
        local ok,core=pcall(manager.IsOnlyCoreBindingSetActive,manager)
        if not ok or (issecretvalue and issecretvalue(core)) or not core then return false end
    end
    if GetCurrentKeyBoardFocus then
        local ok,focus=pcall(GetCurrentKeyBoardFocus)
        if not ok or (issecretvalue and issecretvalue(focus)) or focus then return false end
    end
    -- A also confirms native dialogs. Yield the fishing override when a native
    -- panel is open, including in the standard keyboard/mouse UI.
    if (self.BlizzardPanelOpen and self:BlizzardPanelOpen(false, allowFishingLoot and LootFrame))
        or (not allowFishingLoot and LootFrame and LootFrame:IsShown()) then return false end
    return true
end
local function CanAssignShoulder(self,key)
    for _,modifier in ipairs(gamepadModifiers) do
        if self:GetFishingGamepadModifierButton(modifier)==key then return false end
    end
    if NativeGamepadUI()==false then return true end
    if type(GetBindingKey)~="function" then return false end
    for _,action in ipairs({"GAMEPADLEFTMOD","GAMEPADRIGHTMOD","GAMEPADLEFTTARGETMODIFIER","GAMEPADRIGHTTARGETMODIFIER"}) do
        local ok,first,second=pcall(GetBindingKey,action,1)
        if not ok or (issecretvalue and (issecretvalue(first) or issecretvalue(second)))
            or first==key or second==key then return false end
    end
    return true
end
function FF:FishingGamepadBindingAvailable(key)
    if not self:IsFishingGamepadMode() then return true end
    if self:IsFishingGamepadModified() and not (key and key:find("-",1,true)) then return false end
    return not IsShoulderButton(key) or CanAssignShoulder(self,key)
end
local function MappedFishingTriggerChord(self,key)
    local base,left,right=FishingTriggerChord(key)
    if not base then return end
    local prefix,hasLeft,hasRight=""
    for _,modifier in ipairs(gamepadModifiers) do
        local button=self:GetFishingGamepadModifierButton(modifier)
        if left and button=="PADLTRIGGER" then prefix=prefix..modifier.."-";hasLeft=true
        elseif right and button=="PADRTRIGGER" then prefix=prefix..modifier.."-";hasRight=true end
    end
    if (not left or hasLeft) and (not right or hasRight) then return prefix..base end
end
local function FishingGamepadBindingIdentity(self,key)
    local physical=FishingTriggerChord(key)
    if physical then return key end
    if type(key)~="string" or not key:find("-",1,true) then return key end
    local base=FishingGamepadBase(key)
    if not gamepadNames[base] then return key end
    local left,right=false,false
    for _,modifier in ipairs(gamepadModifiers) do
        if key:find(modifier.."-",1,true) then
            local button=self:GetFishingGamepadModifierButton(modifier)
            if button=="PADLTRIGGER" then left=true
            elseif button=="PADRTRIGGER" then right=true
            else return key end
        end
    end
    return (left and "PADLTRIGGER-" or "")..(right and "PADRTRIGGER-" or "")..base
end
local function NativeTriggerCanNotify(button)
    if type(GetBindingKey)~="function" or not GamepadMode
        or type(GamepadMode.RegisterCrossBarModifierStateChanged)~="function" then return false end
    for _,action in ipairs({"GAMEPADLEFTMOD","GAMEPADRIGHTMOD"}) do
        -- The native action bar uses this context to observe trigger down/up.
        local ok,first,second=pcall(GetBindingKey,action,1)
        if ok and not (issecretvalue and (issecretvalue(first) or issecretvalue(second)))
            and (first==button or second==button) then return true end
    end
    return false
end
local function FishingTriggerCanNotify(left,right)
    return (not left or NativeTriggerCanNotify("PADLTRIGGER"))
        and (not right or NativeTriggerCanNotify("PADRTRIGGER"))
end
function FF:GetFishingNativeGamepadChordKey(key)
    if not self:IsFishingGamepadMode() or not self:IsFishingSessionOpen()
        or (InCombatLockdown and InCombatLockdown()) or not self:IsFishingGamepadKey(key)
        or not key:find("-",1,true) or NativeGamepadUI()~=true then return end
    local base=key:match("(PAD[A-Z0-9]+)$")
    if not base then return end
    local face,left,right=FishingTriggerChord(key)
    if face then
        if not FishingTriggerCanNotify(left,right) then return end
        local expected={PADLTRIGGER=left,PADRTRIGGER=right}
        for _,button in ipairs(physicalModifiers) do
            if self:GetFishingGamepadButtonDown(button)~=(expected[button]==true) then return end
            expected[button]=expected[button]==true
        end
        for _,modifier in ipairs(gamepadModifiers) do
            local button=self:GetFishingGamepadModifierButton(modifier)
            if button and expected[button]==nil and self:GetFishingGamepadButtonDown(button)~=false then return end
        end
        return face
    end
    local prefix=""
    local observed={}
    for _,modifier in ipairs(gamepadModifiers) do
        local button=self:GetFishingGamepadModifierButton(modifier)
        if button then
            local held=self:GetFishingGamepadButtonDown(button)
            if held==nil then return end
            observed[button]=true
            if held then prefix=prefix..modifier.."-" end
        end
    end
    for _,button in ipairs(physicalModifiers) do
        if not observed[button] then
            if self:GetFishingGamepadButtonDown(button)~=false then return end
        end
    end
    -- Native gamepad action bars consume bare face keys and choose their own
    -- layer from held triggers. Match an exact physical chord, not Shift state.
    if prefix~="" and prefix..base==key then return base end
end
function FF:GetFishingPrimaryBindingKey(key)
    if not self:IsFishingGamepadMode() or not FishingTriggerChord(key) then return key end
    local native=NativeGamepadUI()
    if native==true and self.gamepadChordBindingOwner and not self.gamepadInputLeavingWorld then
        return self:GetFishingNativeGamepadChordKey(key),self.gamepadChordBindingOwner
    elseif native==false then
        return MappedFishingTriggerChord(self,key)
    end
end
function FF:RefreshFishingGamepadModifiers()
    if self.gamepadInputStartupFailed or not self.db or not self:IsFishingGamepadMode() or (self.capture and self.capture:IsShown()) then return end
    -- This isolated hardware-modifier notification must reconcile before the
    -- following face-key event. Focus/popup notifications remain deferred.
    self:ApplyBindings()
end
function FF:ShouldDeferFishingLauncherBindings()
    return not self.gamepadInputStartupFailed and self:IsFishingGamepadMode() and NativeGamepadUI()==true
end
function FF:RefreshFishingGamepadInput()
    if self.gamepadInputStartupFailed or self.fishingLauncherBindingHandoff
        or not self.db or not self:IsFishingGamepadMode() then return end
    if self.capture and self.capture:IsShown() then return end
    if self.gamepadBindingRefresh then return end
    -- Never rewrite bindings/secure attributes within Blizzard's focus or
    -- popup dispatcher. One next-frame refresh owns only our binding frames.
    local request={db=self.db,bar=self.bar,open=self:IsFishingSessionOpen()}
    self.gamepadBindingRefresh=request
    C_Timer.After(0,function()
        if self.gamepadBindingRefresh~=request then return end
        self.gamepadBindingRefresh=nil
        if self.db~=request.db or self.bar~=request.bar or self:IsFishingSessionOpen()~=request.open
            or not self:IsFishingGamepadMode() or (InCombatLockdown and InCombatLockdown())
            or (self.capture and self.capture:IsShown()) then return end
        self:ApplyBindings()
    end)
end
function FF:InitializeFishingGamepadInput()
    if not self.gamepadFocusRegistered and EventRegistry and type(EventRegistry.RegisterCallback)=="function" then
        self.gamepadFocusRegistered=true
        -- CallbackRegistry isolates addon callbacks. Never append to the native
        -- binding manager's raw listener array: its dispatcher has no barrier.
        for _,event in ipairs({"Gamepad.RefreshFrameFocus","Gamepad.ShowMainMenu","Gamepad.HideMainMenu"}) do
            EventRegistry:RegisterCallback(event,function() self:RefreshFishingGamepadInput() end,self)
        end
    end
    if self.gamepadModifierOwner~=GamepadMode and GamepadMode then
        self.gamepadModifierOwner=GamepadMode
        for _,name in ipairs({"RegisterInputModifierStateChangeCallback","RegisterTargetModifierChanged","RegisterCrossBarModifierStateChanged"}) do
            if type(GamepadMode[name])=="function" then
                if name=="RegisterCrossBarModifierStateChanged" then
                    GamepadMode[name](function() self:RefreshFishingGamepadModifiers() end,self)
                else GamepadMode[name](function() self:RefreshFishingGamepadInput() end,self) end
            end
        end
    end
end
function FF:SetFishingGamepadMode(enabled)
    if not self.db or (InCombatLockdown and InCombatLockdown()) then return false end
    if self.captureVisibility then self:InterruptKeyCapture() end
    if not enabled then self.gamepadModePending=nil end
    if enabled and self.gamepadInputStartupFailed then
        self:Print(L("startup.gamepad"));return false
    end
    if enabled and self.gamepadCaptureAvailable~=true then
        self:Print(L("gamepad.unavailable"));return false
    end
    if enabled and not SavedGamepadFishingKey(self) then
        -- A first assignment is a transaction: cancel leaves the old mode live.
        self.gamepadModePending=true
        self:BeginKeyCapture("fishing", type(self.db.gamepadBindings)~="table")
        if not self.captureVisibility then self.gamepadModePending=nil;return false end
    else
        self.db.gamepadMode=enabled==true
        if self.ResetDoubleClick then self:ResetDoubleClick(true) end
        self:ApplyBindings();self:RefreshUI()
    end
    if self.settingsPanel and self.settingsPanel.RefreshBindingControls then self.settingsPanel:RefreshBindingControls() end
    return true
end
FF.fishingActions = {
    fishing = {labelKey="action.fishing",label=L("action.fishing"),target="ForeverFishingCastActionButton"},
    recast = {labelKey="action.recast",label=L("action.recast"),target="ForeverFishingQuickRecastButton"},
    gear = {labelKey="action.gear",label=L("action.gear"),target="ForeverFishingGearActionButton"},
    lure = {labelKey="action.lure",label=L("action.lure"),target="ForeverFishingLureActionButton"},
    ["chef-menu"] = {labelKey="action.chef",label=L("action.chef"),target="ForeverFishingChefFlyoutActionButton",method="ShowMasterChefQuickTray"},
    ["utility-menu"] = {labelKey="utility.open",label=L("utility.open"),target="ForeverFishingUtilityFlyoutActionButton",method="ShowUtilityPicker"},
    journal = {labelKey="action.journal",label=L("action.journal"),target="ForeverFishingJournalActionButton",method="ToggleFishingJournal"},
    jump = {labelKey="action.jump",label=L("action.jump")},
    close = {labelKey="action.close",label=L("action.close"),target="ForeverFishingCloseControlsActionButton",gamepadOnly=true},
    open = {labelKey="action.toggle",label=L("action.toggle"),target="ForeverFishingOpenControlsActionButton",scope="always"},
}
FF.fishingActionOrder={"fishing","recast","gear","lure","chef-menu","utility-menu","journal","jump","close","open"}
function FF:InitializeFishingActionBindings()
    -- Retired development mode; controller choices have their own profile.
    self.db.rightClickFishing=nil
    local keys=self.db.actionBindings
    if type(keys)=="table" then keys["gear-menu"]=nil; keys["lure-menu"]=nil end
end
function FF:RefreshFishingActionLanguage()
    for _,entry in pairs(self.fishingActions) do entry.label=L(entry.labelKey) end
end
function FF:GetFishingPreparationSummary()
    local kind=self.db.autoEquipGear and (self.db.autoEquipLures and "gear-lure" or "gear")
        or (self.db.autoEquipLures and "lure" or "cast")
    return L("preparation."..kind)..(self.db.cameraAssist and L("preparation.camera") or "")
end
function FF:GetFishingActionKey(action)
    if not self.db then return end
    if action=="fishing" then return self:GetFishingInputKey() end
    if self:IsFishingGamepadMode() then
        local key=type(self.db.gamepadBindings)=="table" and self.db.gamepadBindings[action]
        if action=="close" and key==nil then key=self:GetFishingLeftTriggerChord("PAD2") end
        return self:IsFishingGamepadActionKey(action,key) and key or nil
    end
    if action=="close" then return end
    local key=type(self.db.actionBindings)=="table" and self.db.actionBindings[action]
    return KeyboardBindingKey(key)
end
function FF:GetFishingCaptureInstruction(action)
    if self:IsFishingGamepadMode() then
        if action=="fishing" then
            return L("gamepad.capture-fishing-prompt",self:GetFishingGamepadPopupIcon("PADLTRIGGER"),
                self:GetFishingGamepadPopupIcon("PADRTRIGGER"))
        end
        return L((action=="jump" or action=="close") and "gamepad.capture-chord-prompt" or "gamepad.capture-prompt")
    end
    return L(action=="fishing" and "binding.capture-fishing-prompt" or "binding.capture-prompt")
end
function FF:UpdateFishingKeyWarning(button,key)
    if not button then return end
    local unbound=not key or key==""
    if unbound then button:SetText(L("binding.unassigned")) end
    if button.SetFishingKeyUnbound then button:SetFishingKeyUnbound(unbound) end
end
local function ReservedMouse(key)
    local base=key and key:gsub("ALT%-",""):gsub("CTRL%-",""):gsub("SHIFT%-","")
    return base=="BUTTON1" or base=="BUTTON2" or key=="BUTTON4"
end
function FF:GetFishingJumpState(action,candidate)
    local gamepad=self:IsFishingGamepadMode()
    local used={}
    for _,id in ipairs(self.fishingActionOrder) do
        if id~="jump" then
            local key=id==action and candidate or self:GetFishingActionKey(id)
            if id==action and candidate==nil then key=nil end
            if key then used[gamepad and FishingGamepadBindingIdentity(self,key) or key]=true end
        end
    end
    if gamepad then
        local needed=used.PAD1==true
        if GetBindingKey then
            local ok,first,second=pcall(GetBindingKey,"JUMP")
            if ok then for _,key in pairs({first,second}) do
                if self:IsFishingGamepadKey(key) and used[FishingGamepadBindingIdentity(self,key)] then needed=true end
            end end
        end
        if not needed then return false,nil end
        local preferred=action=="jump" and candidate or self:GetFishingActionKey("jump")
        if action=="jump" and candidate==nil then preferred=nil end
        local function Available(key)
            return self:IsFishingGamepadActionKey("jump",key) and not used[FishingGamepadBindingIdentity(self,key)]
        end
        if Available(preferred) then return true,preferred end
        local choices={"PADDUP","PADDDOWN","PADDLEFT","PADDRIGHT","PADLSTICK","PADRSTICK"}
        local trigger=self:GetFishingLeftTriggerChord("PAD1")
        if Available(trigger) then return true,trigger end
        for _,key in ipairs(choices) do
            local ok,assigned=true,""
            if GetBindingAction then ok,assigned=pcall(GetBindingAction,key,true) end
            if Available(key) and ok and not (issecretvalue and issecretvalue(assigned))
                and (assigned=="" or assigned=="JUMP") then return true,key end
        end
        -- Like the keyboard Jump alternative, this is a session-only override.
        for _,key in ipairs(choices) do if Available(key) then return true,key end end
        for _,key in ipairs({"PAD3","PAD4","PAD2"}) do if Available(key) then return true,key end end
        return true,nil
    end
    local native={}
    if GetBindingKey then
        local ok,first,second=pcall(GetBindingKey,"JUMP")
        if ok then
            if first and not IsControllerBindingToken(first) then native[#native+1]=first end
            if second and not IsControllerBindingToken(second) then native[#native+1]=second end
        end
    end
    local needed=false
    for _,key in ipairs(native) do if used[key] then needed=true end end
    local preferred=action=="jump" and candidate or self:GetFishingActionKey("jump")
    if action=="jump" and candidate==nil then preferred=nil end
    if preferred and not used[preferred] and not IsControllerBindingToken(preferred) and not ReservedMouse(preferred) then
        return needed,preferred
    end
    local choices={"SHIFT-SPACE"}
    for _,key in ipairs(native) do choices[#choices+1]=key end
    for _,key in ipairs({"CTRL-SPACE","ALT-SPACE","CTRL-SHIFT-SPACE","ALT-SHIFT-SPACE","CTRL-J","ALT-J","SHIFT-J","CTRL-SHIFT-J","ALT-SHIFT-J","ALT-CTRL-J"}) do choices[#choices+1]=key end
    for _,key in ipairs(choices) do
        local assignment=GetBindingAction and GetBindingAction(key,true) or ""
        if not used[key] and not ReservedMouse(key) and (assignment=="" or assignment=="JUMP") then return needed,key end
    end
    -- As with an explicitly chosen fishing shortcut, an ordinary game action
    -- may be overridden temporarily. Prefer free/native Jump keys first, but
    -- never strand Jump merely because those game keys are already assigned.
    for _,key in ipairs(choices) do
        if not used[key] and not ReservedMouse(key) then return needed,key end
    end
    return needed,nil
end
function FF:FishingActionBindingConflict(action,key)
    if not key then
        if action=="jump" then local needed,fallback=self:GetFishingJumpState(action,nil);if needed and not fallback then return L("binding.jump-required"),nil,true end end
        return
    end
    if not self.fishingActions[action] then return L("binding.unknown-action"),nil,true end
    if type(key)~="string" or key=="" then return self:GetFishingCaptureInstruction(action),nil,true end
    local gamepad=self:IsFishingGamepadMode()
    if gamepad then
        if key=="PAD1" and action~="fishing" then
            return L("gamepad.a-fishing-only",self:GetFishingGamepadPopupIcon("PAD1")),nil,true
        end
        if not self:IsFishingGamepadActionKey(action,key) then
            return L("gamepad.reserved"),nil,true
        end
        if IsShoulderButton(key) and not CanAssignShoulder(self,key) then
            return L("gamepad.shoulder-modifier"),nil,true
        end
        local face,left,right=FishingTriggerChord(key)
        if face then
            local native=NativeGamepadUI()
            local available=native==true and FishingTriggerCanNotify(left,right)
                or native==false and MappedFishingTriggerChord(self,key)
            if not available then return L("gamepad.fishing-trigger-needs-mapping"),nil,true end
        end
    elseif action=="close" or IsControllerBindingToken(key) then
        -- Native keyboard names such as NUMPAD1 must remain keyboard keys.
        return L("gamepad.choose-mode"),nil,true
    end
    if key==self.doubleRightClickKey then
        if action=="fishing" then return end
        return L("binding.world-mouse")
    end
    if ReservedMouse(key) and not (action=="fishing" and key:match("BUTTON4$")) then return key:match("BUTTON4$") and L("binding.journal-back") or L("binding.world-mouse") end
    local identity=gamepad and FishingGamepadBindingIdentity(self,key) or key
    for _,id in ipairs(self.fishingActionOrder) do
        if id~=action then
            local existing=self:GetFishingActionKey(id)
            if (gamepad and FishingGamepadBindingIdentity(self,existing) or existing)==identity then
                return self.fishingActions[id].label,id
            end
        end
    end
    local needed,fallback=self:GetFishingJumpState()
    local willNeed,willFallback=self:GetFishingJumpState(action,key)
    if action~="jump" and needed and willNeed
        and (gamepad and FishingGamepadBindingIdentity(self,fallback) or fallback)==identity then
        return L("action.jump"),"jump"
    end
    if willNeed and not willFallback then return L("binding.jump-required"),nil,true end
    -- Native game assignments are intentionally overridden temporarily. Only
    -- our own actions and reserved UI/world inputs are assignment conflicts.
end
function FF:GetFishingGameBindingName(key)
    local assigned=GetBindingAction and GetBindingAction(key,true) or ""
    if assigned=="" then assigned=GetBindingAction and GetBindingAction(key) or "" end
    if assigned=="" then return end
    local label=_G["BINDING_NAME_"..assigned] or (GetBindingText and GetBindingText(assigned,"BINDING_NAME_"))
    if label and label~="" and label~=assigned then return label end
    local target=assigned:match("^CLICK ([^:]+):")
    if target then
        for _,entry in pairs(self.fishingActions) do if entry.target==target then return entry.label end end
        return L("binding.addon-shortcut")
    end
    return L("binding.game-shortcut")
end
function FF:ReviewFishingBinding(key)
    if not self.captureInputReady or not self.capture:IsShown() then return end
    local action=self.keyCaptureAction or "fishing"
    local conflict,other,guidance=self:FishingActionBindingConflict(action,key)
    self.captureCandidate,self.captureCanConfirm,self.captureConflictAction=key,nil,nil
    self.captureConfirm:Hide();self.captureCancel:Hide()
    local gamepad=self:IsFishingGamepadMode()
    if gamepad then
        self.captureEscape:SetText(L("gamepad.capture-cancel",self:GetFishingGamepadPopupIcon("PADBACK","footer")))
    end
    local function BindingLabel()
        return gamepad and self:GetFishingGamepadPopupIcon(key) or self:GetFishingBindingLabel(key)
    end
    self.captureInstruction:SetText(self:GetFishingCaptureInstruction(action))
    self.captureScope:SetText(action~="open" and self:LocalizedText("binding.session-only") or "")
    self.captureScope:SetTextColor(.80,.84,.84);self.captureDetail:SetText("")
    if conflict then
        local message=guidance and conflict
            or (other and L("binding.replace-conflict",BindingLabel(),conflict) or L("binding.conflict",conflict))
        self.captureDetail:SetText(message)
        if other then
            self.captureConflictAction=other;self.captureCanConfirm=true
            self.captureConfirm:SetText(L("binding.replace"))
        end
    elseif action=="open" then
        self.captureCanConfirm=true
        self.captureConfirm:SetText(L("binding.assign"))
        self.captureDetail:SetText(L("binding.global-candidate",BindingLabel()))
    else self:FinishKeyCapture(key);return end
    if self.captureCanConfirm then
        if gamepad then
            self.captureConfirm:SetText(L("gamepad.capture-action",self:GetFishingGamepadPopupIcon("PAD1","footer"),
                self.captureConfirm:GetFontString():GetText()))
            self.captureEscape:SetText(L("gamepad.capture-review-cancel",
                self:GetFishingGamepadPopupIcon("PAD2","footer"),self:GetFishingGamepadPopupIcon("PADBACK","footer")))
        end
        if action=="open" or other=="open" then
            self.captureScope:SetText(L("binding.global-warning"))
            self.captureScope:SetTextColor(1,.84,.2)
            local assigned=self:GetFishingGameBindingName(key)
            if assigned then self.captureDetail:SetText(self.captureDetail:GetText().."\n"..L("binding.override-game",assigned)) end
        end
        self.captureConfirm:SetEnabled(true);self.captureConfirm:Show()
        if action~="open" and other~="open" then self.captureCancel:Show() end
    end
    self:LayoutFishingBindingCapture()
end
function FF:ReplaceFishingActionBinding(action,key,other)
    if not self.db or (InCombatLockdown and InCombatLockdown()) then return false end
    local _,current=self:FishingActionBindingConflict(action,key)
    -- The offer names one exact assignment. Never clear a newer/different one.
    if current~=other or not self.fishingActions[other] or action==other then return false end
    if self:IsFishingGamepadMode() then
        local old=self.db.gamepadBindings
        local bindings={}
        if type(old)=="table" then for id,value in pairs(old) do bindings[id]=value end end
        bindings[other]=nil
        if other=="close" then bindings.close=false end
        bindings[action]=key;self.db.gamepadBindings=bindings
        local conflict=self:FishingActionBindingConflict(action,key)
        if conflict then self.db.gamepadBindings=old;return false,conflict end
        if self.captureCommitPending then return true end
        self:ApplyBindings();self:RefreshUI()
        if self.settingsPanel and self.settingsPanel.RefreshBindingControls then self.settingsPanel:RefreshBindingControls() end
        return true
    end
    local oldKey=self.db.key
    local oldBindings=self.db.actionBindings
    local bindings={}
    if type(oldBindings)=="table" then for id,value in pairs(oldBindings) do bindings[id]=value end end
    self.db.actionBindings=bindings
    if other=="fishing" then self.db.key=nil else bindings[other]=nil end
    if action=="fishing" then self.db.key=key else bindings[action]=key end
    -- Validate the complete proposed state before any override/UI side effects.
    -- Replacing automatic Jump lets the existing resolver choose another chord.
    local conflict=self:FishingActionBindingConflict(action,key)
    if conflict then self.db.key,self.db.actionBindings=oldKey,oldBindings;return false,conflict end
    local ok,reason=self:SetFishingActionBinding(action,key)
    if not ok then self.db.key,self.db.actionBindings=oldKey,oldBindings;return false,reason end
    return true
end
function FF:SetFishingActionBinding(action,key)
    local entry=self.fishingActions[action]
    if not entry or (InCombatLockdown and InCombatLockdown()) then return false end
    local conflict=self:FishingActionBindingConflict(action,key)
    if conflict then return false,conflict end
    local gamepad=self:IsFishingGamepadMode()
    if gamepad then
        self.db.gamepadBindings=type(self.db.gamepadBindings)=="table" and self.db.gamepadBindings or {}
        self.db.gamepadBindings[action]=key
        if action=="close" and key==nil then self.db.gamepadBindings.close=false end
    elseif action=="fishing" then self:SetKey(key)
    else
        self.db.actionBindings=type(self.db.actionBindings)=="table" and self.db.actionBindings or {}
        self.db.actionBindings[action]=key
    end
    -- FinishKeyCapture reapplies overrides and refreshes the UI after releasing
    -- the input shield and restoring the windows masked by capture.
    if self.captureCommitPending then return true end
    if gamepad or action~="fishing" then self:ApplyBindings();self:RefreshUI() end
    if self.settingsPanel and self.settingsPanel.RefreshBindingControls then self.settingsPanel:RefreshBindingControls() end
    return true
end
function FF:ApplyAdditionalFishingBindings(owner,globalOwner)
    local primaryAliased=false
    local chordOwner=self.gamepadChordBindingOwner
    for _,action in ipairs(self.fishingActionOrder) do
        local entry=self.fishingActions[action]
        local key=self:GetFishingActionKey(action)
        if action~="fishing" and action~="jump" and key and (self:IsFishingSessionOpen() or entry.scope=="always")
            and self:FishingGamepadBindingAvailable(key)
            and not self:FishingActionBindingConflict(action,key) then
            local target=action=="recast" and self.quickRecastButton or action=="gear" and self.gearButton
                or action=="lure" and self.lureButton or (self.fishingActionButtons and self.fishingActionButtons[action])
            if target then SetOverrideBindingClick(entry.scope=="always" and globalOwner or owner,true,key,entry.target,"LeftButton") end
            if action=="close" and target and chordOwner then
                local alias=self:GetFishingNativeGamepadChordKey(key)
                if alias then
                    SetOverrideBindingClick(chordOwner,true,alias,entry.target,"LeftButton")
                    primaryAliased=primaryAliased or alias==self:GetFishingInputKey()
                end
            end
        end
    end
    local needed,jump=self:GetFishingJumpState()
    if self:IsFishingSessionOpen() and needed and jump and self:FishingGamepadBindingAvailable(jump) then pcall(SetOverrideBinding,owner,true,jump,"JUMP") end
    if self:IsFishingSessionOpen() and needed and jump and chordOwner then
        local alias=self:GetFishingNativeGamepadChordKey(jump)
        if alias then
            SetOverrideBinding(chordOwner,true,alias,"JUMP")
            primaryAliased=primaryAliased or alias==self:GetFishingInputKey()
        end
    end
    return primaryAliased
end
function FF:ConfigureFishingCloseAction(close)
    local button=self.fishingActionButtons and self.fishingActionButtons.close
    if not button or not close then return end
    button:SetFrameRef("session",self.bar)
    button:SetAttribute("clickbutton1",close)
    if button.fishingCloseWrapped==true then return end
    button.fishingCloseWrapped=true
    SecureHandlerWrapScript(button,"OnClick",button,[[
        self:SetAttribute("type1",nil)
        if down then return false end
        if self:GetFrameRef("session"):IsShown() then self:SetAttribute("type1","click") end
    ]])
end
function FF:ConfigureFishingToggleAction(close)
    local toggle=self.fishingActionButtons and self.fishingActionButtons.open
    if not toggle or not close then return end
    toggle:SetFrameRef("session",self.bar)
    toggle:SetAttribute("clickbutton1",close)
    if toggle.fishingToggleWrapped==true then return end
    toggle.fishingToggleWrapped=true
    SecureHandlerWrapScript(toggle,"OnClick",toggle,[[
        self:SetAttribute("type1",nil)
        if down then return false end
        if SecureCmdOptionParse("[combat]combat") then
            if self:GetFrameRef("session"):IsShown() then self:SetAttribute("type1","click") end
        end
    ]])
end

function FF:QuickRecastAllowed()
    if not self:FishingGamepadInputAvailable() then return false end
    if self.FishingReelLootPending and self:FishingReelLootPending() then return false end
    if not self.db or not self:IsFishingSessionOpen() or self.journalInputFocus or self.settingsKeyboardFocus
        or self.captureCommitPending or (self.capture and self.capture:IsShown())
        or (InCombatLockdown and InCombatLockdown()) then return false end
    if UnitCastingInfo and UnitCastingInfo("player") then return false end
    -- Live native state wins over a delayed CHANNEL_START/STOP event. A Chef
    -- channel, lure or any other spell must never be stopped by this action.
    local fishing, _, _, channel = self:IsFishingChannelActive()
    if not fishing and channel ~= "absent" and channel ~= "unavailable" then return false end
    -- An already-issued gear operation must finish, but rotation preparation
    -- and timing/readiness never gate this explicit repositioning action.
    return not (self.pendingFishingGear or self.pendingGearRestore)
end

function FF:FishingStopAndCastMacro()
    local name = self:FishingName()
    -- The client can still report Fishing after /stopcasting in the same
    -- secure click. Allow the new cast in either Fishing or idle state.
    local fishingChannel = "[nocombat,channeling:" .. name .. "]"
    return "/stopcasting " .. fishingChannel .. "\n/cast [nocombat,nochanneling]" .. fishingChannel .. " " .. name
end

function FF:SyncQuickRecastAction()
    if not self.quickRecastButton or (InCombatLockdown and InCombatLockdown()) then return false end
    local allowed = self:QuickRecastAllowed()
    self.quickRecastButton:SetAttribute("type", allowed and "macro" or nil)
    self.quickRecastButton:SetAttribute("macrotext", self:FishingStopAndCastMacro())
    return allowed
end

function FF:CreateFishingActionControls(parent)
    local chordOwner=CreateFrame("Frame",nil,parent,"SecureHandlerStateTemplate")
    chordOwner:SetAttribute("_onstate-combat", [[
        if newstate == "combat" then self:ClearBindings() end
    ]])
    RegisterStateDriver(chordOwner,"combat","[combat]combat;peace")
    self.gamepadChordBindingOwner=chordOwner
    local cast = CreateFrame("Button", "ForeverFishingCastActionButton", parent, "SecureActionButtonTemplate")
    cast:SetSize(1, 1)
    cast:SetPoint("TOPLEFT", parent, "TOPLEFT")
    cast:EnableMouse(false)
    cast:RegisterForClicks("AnyUp")
    cast:SetAttribute("useOnKeyDown", false)
    cast:SetScript("PreClick", function(button) self:OnCastButtonPreClick(button) end)
    cast:SetScript("PostClick", function() self:OnCastButtonPostClick() end)
    self.castActionButton = cast

    local capacityRecast = CreateFrame("Button", "ForeverFishingCapacityRecastButton", parent, "SecureActionButtonTemplate")
    capacityRecast:SetSize(1, 1)
    capacityRecast:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    capacityRecast:EnableMouse(false)
    capacityRecast:RegisterForClicks("AnyUp")
    capacityRecast:SetAttribute("useOnKeyDown", false)
    capacityRecast:SetScript("PreClick", function(button) self:PrepareFishingCapacityRecast(button) end)
    capacityRecast:SetScript("PostClick", function(button) self:FinishFishingCapacityRecast(button) end)
    self.capacityRecastButton = capacityRecast

    local recast = CreateFrame("Button", "ForeverFishingQuickRecastButton", parent, "SecureActionButtonTemplate")
    recast:SetSize(1, 1)
    recast:SetPoint("TOPLEFT", parent, "TOPLEFT")
    recast:EnableMouse(false)
    recast:RegisterForClicks("AnyUp")
    recast:SetAttribute("useOnKeyDown", false)
    recast:SetScript("PreClick", function()
        self.recastClickArmed = self:SyncQuickRecastAction()
        self.castClickInProgress = self.recastClickArmed or nil
    end)
    recast:SetScript("PostClick", function()
        self.castClickInProgress = nil
        if not self.recastClickArmed then return end
        self.recastClickArmed = nil
        -- Share only native SENT-event deduplication/sound bookkeeping.
        -- Never create a normal-rotation lock or wait for a successful channel;
        -- a rejected attempt leaves the next fresh input immediately eligible.
        self.lastCastButtonPressAt = GetTime()
        self:OnFishingSoundCastSent()
    end)
    self.quickRecastButton = recast
    self.fishingActionButtons = {}
    for _,id in ipairs({"open","close","chef-menu","utility-menu","journal"}) do
        local entry=self.fishingActions[id]
        local button=CreateFrame("Button",entry.target,parent,(id=="open" or id=="close") and "SecureActionButtonTemplate,SecureHandlerBaseTemplate" or nil)
        button:SetSize(1,1);button:SetPoint("TOPLEFT",parent,"TOPLEFT");button:EnableMouse(false)
        button:RegisterForClicks("AnyUp");button:SetAttribute("useOnKeyDown",false)
        if id~="close" then button:SetScript(id=="open" and "PostClick" or "OnClick",function(_,_,down)
            if down or (InCombatLockdown and InCombatLockdown()) or self.journalInputFocus or self.settingsKeyboardFocus
                or (self.capture and self.capture:IsShown()) or not self:FishingGamepadInputAvailable() then return end
            if id=="open" then self:ToggleUI()
            elseif self:IsFishingSessionOpen() then self[entry.method](self) end
        end) end
        self.fishingActionButtons[id]=button
    end
    -- This session-owned update frame survives hiding any status artwork.
    self.fishingUpdateFrame = CreateFrame("Frame", nil, parent)
end
