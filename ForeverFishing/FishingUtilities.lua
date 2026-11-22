-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF=_G.ForeverFishing
FF.utilityCatalogue={
    {id=286732,name="Shiny Silver Coin"},
    {id=19979,name="Hook of the Master Angler"},
    {id=276274,name="Surfer Shoes"},
}
local function Count(id)
    local query=C_Item and C_Item.GetItemCount or GetItemCount
    local ok,count
    if query then ok,count=pcall(query,id,false) end
    if ok and type(count)=="number" and not (issecretvalue and issecretvalue(count)) and count>=0 and count<math.huge then return count end
    return 0
end
local function Name(id,fallback)
    local query=C_Item and C_Item.GetItemInfo or GetItemInfo
    if query then local ok,name=pcall(query,id); if ok and name then return name end end
    return fallback or ("Item "..id)
end
function FF:IsFishingUtilityExcluded(id)
    for _,entry in ipairs(self.masterChefMeals or {}) do if entry.id==id then return true end end
    for _,entry in ipairs(self.masterChefCamps or {}) do if entry.id==id then return true end end
    for _,entry in ipairs(self.availableLures or {}) do if entry.id==id then return true end end
    if self.IsKnownFishingLure and self:IsKnownFishingLure(id) then return true end
    local query=C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if query then
        local ok,_,_,_,_,_,class,subclass=pcall(query,id)
        if ok and class==2 and subclass==20 then return true end
    end
    return false
end
function FF:AddFishingUtility(id)
    id=tonumber(id)
    if not id or id%1~=0 or id<1 or id>10000000 or not self.db or InCombatLockdown and InCombatLockdown() then return false end
    if self:IsFishingUtilityExcluded(id) then self:Print(FF:LocalizedText("utility.excluded")); return false end
    local query=C_Item and C_Item.GetItemSpell or GetItemSpell
    local ok,spell
    if query then ok,spell=pcall(query,id) end
    if not ok or not spell then
        if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
        self:Print(FF:LocalizedText("utility.unready"))
        return false
    end
    if type(self.db.utilityItems)~="table" then self.db.utilityItems={} end
    self.db.utilityItems[id]=true
    if self.db.utilityHidden then self.db.utilityHidden[id]=nil end
    if self.utilityPicker then self.utilityPicker.flyoutEntries=nil; self.utilityPicker.flyoutGeometryLocked=nil end
    self:RefreshUtilityPicker()
    return true
end
function FF:SetFishingUtilitiesShown(shown)
    self.db.showUtilityButton=shown==true
    if not shown and self.utilityPicker and not (InCombatLockdown and InCombatLockdown()) then self.utilityPicker:Hide() end
    self:ApplyIconBarSpacing()
end
function FF:GetFishingUtilityEntries()
    local entries,seen={},{}
    local hidden=self.db.utilityHidden or {}
    local function Add(id,fallback)
        if not seen[id] and not hidden[id] and not self:IsFishingUtilityExcluded(id) then
            seen[id]=true
            local count=Count(id)
            if count>0 then entries[#entries+1]={id=id,name=Name(id,fallback),count=count} end
        end
    end
    for _,entry in ipairs(self.utilityCatalogue) do Add(entry.id,entry.name) end
    local ids={}
    for id,enabled in pairs(self.db.utilityItems or {}) do if enabled and type(id)=="number" then ids[#ids+1]=id end end
    table.sort(ids); for _,id in ipairs(ids) do Add(id) end
    entries[#entries+1]={add=true}
    return entries
end
local function RefreshCooldown(button,id)
    local query=C_Item and C_Item.GetItemCooldown or GetItemCooldown
    local ok,start,duration
    if id and query then ok,start,duration=pcall(query,id) end
    if ok and type(start)=="table" then duration=start.duration; start=start.startTime end
    if ok and not (issecretvalue and (issecretvalue(start) or issecretvalue(duration)))
        and type(start)=="number" and type(duration)=="number" and duration>0 then
        button.cooldown:SetCooldown(start,duration); button.cooldown:Show()
    else button.cooldown:Hide() end
end
local function Icon(self,id)
    return id and ((C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id)) or GetItemIcon and GetItemIcon(id)) or self.utilitiesIcon
end
function FF:GetSelectedFishingUtility()
    local id=self.db and self.db.utilitySelectedItem
    if type(id)~="number" or id%1~=0 or id<1 or id>10000000
        or self.db.utilityHidden and self.db.utilityHidden[id] or self:IsFishingUtilityExcluded(id) then return end
    local known=self.db.utilityItems and self.db.utilityItems[id]
    local fallback
    for _,entry in ipairs(self.utilityCatalogue) do
        if entry.id==id then known=true; fallback=entry.name; break end
    end
    if known then return {id=id,name=Name(id,fallback),count=Count(id)} end
end
function FF:SetSelectedFishingUtility(id)
    if not self.db or InCombatLockdown and InCombatLockdown() then return false end
    for _,entry in ipairs(self:GetFishingUtilityEntries()) do
        if entry.id==id and entry.count>0 then
            self.db.utilitySelectedItem=id
            self:RefreshFishingUtilityButton()
            return true
        end
    end
    return false
end
function FF:RefreshFishingUtilityButton()
    local button=self.utilityButton
    if not button or not self.db then return end
    local item=self:GetSelectedFishingUtility()
    local available=item and item.count>0
    -- Selection is saved independently of availability. Depletion, inventory
    -- refresh and bar animation must never select or activate a replacement.
    if not (InCombatLockdown and InCombatLockdown()) then
        button:SetAttribute("type1",available and "item" or nil)
        button:SetAttribute("item1",available and "item:"..item.id or nil)
    end
    button.icon:SetTexture(Icon(self,item and item.id) or self.utilitiesIcon)
    button.icon:SetTexCoord(item and .07 or 0,item and .93 or 1,item and .07 or 0,item and .93 or 1)
    local shade=(not item or available) and 1 or .45
    button.icon:SetVertexColor(shade,shade,shade)
    button.count:SetText(item and tostring(item.count) or "")
    RefreshCooldown(button,item and item.id)
end
function FF:InitializeFishingUtilityButton(button)
    button:RegisterForClicks("LeftButtonDown","LeftButtonUp")
    button:SetAttribute("useOnKeyDown",false)
    button.count=button:CreateFontString(nil,"OVERLAY","NumberFontNormalSmall")
    button.count:SetPoint("BOTTOMLEFT",button,"BOTTOMLEFT",3,3)
    button.cooldown=CreateFrame("Cooldown",nil,button,"CooldownFrameTemplate")
    button.cooldown:SetAllPoints(button); button.cooldown:EnableMouse(false)
    button:SetScript("PreClick",function() self:RefreshFishingUtilityButton() end)
    button:SetScript("PostClick",function(_,_,down) if not down then self:RefreshFishingUtilityButton() end end)
    button:SetScript("OnEnter",function(owner)
        local item=self:GetSelectedFishingUtility()
        if item then
            self:BeginJournalItemTooltip(owner,item.id,item.name)
            GameTooltip:AddLine(self:LocalizedText(item.count>0 and "utility.use-selected" or "utility.selected-unavailable"),.83,.72,.52,true)
            GameTooltip:AddLine(self:LocalizedText("utility.owner-tooltip"),.76,.82,.8,true)
            GameTooltip:AddLine(self:LocalizedText("utility.requirements"),.76,.82,.8,true)
            self:FinishJournalItemTooltip(owner)
        else
            GameTooltip:SetOwner(owner,"ANCHOR_RIGHT"); GameTooltip:SetText(self:LocalizedText("utility.title"),1,.82,.45)
            GameTooltip:AddLine(self:LocalizedText("utility.no-selection"),.76,.82,.8,true); GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave",function(owner) self:HideJournalItemTooltip(owner) end)
    local function Shown(owner)
        for _,event in ipairs({"BAG_UPDATE_DELAYED","PLAYER_EQUIPMENT_CHANGED","SPELL_UPDATE_COOLDOWN","BAG_UPDATE_COOLDOWN","GET_ITEM_INFO_RECEIVED","PLAYER_REGEN_ENABLED"}) do owner:RegisterEvent(event) end
        self:RefreshFishingUtilityButton()
    end
    button:SetScript("OnEvent",function() self:RefreshFishingUtilityButton() end)
    button:HookScript("OnShow",Shown)
    button:HookScript("OnHide",function(owner) owner:UnregisterAllEvents(); self:HideJournalItemTooltip(owner) end)
    if button:IsShown() then Shown(button) end
end
function FF:RefreshUtilityPicker()
    local panel=self.utilityPicker
    if not panel or not panel:IsShown() or InCombatLockdown and InCombatLockdown() then return end
    local entries=self:ResolveFishingFlyoutEntries(panel,self:GetFishingUtilityEntries())
    panel.rows={}
    for index,entry in ipairs(entries) do
        local row=entry.add and panel.utilityAddButton or panel.utilityItemButtons[index]
        if not row then
            row=CreateFrame("Button",nil,panel.content)
            row:RegisterForClicks("LeftButtonUp","RightButtonUp"); row:SetAttribute("useOnKeyDown",false)
            self:StyleFishingFlyoutIcon(row,panel)
            if entry.add then self:StyleFishingFlyoutAddButton(row) end
            row.count=row:CreateFontString(nil,"OVERLAY","NumberFontNormalSmall"); row.count:SetPoint("BOTTOMRIGHT",row,"BOTTOMRIGHT",-3,3)
            row.cooldown=CreateFrame("Cooldown",nil,row,"CooldownFrameTemplate"); row.cooldown:SetAllPoints(row); row.cooldown:EnableMouse(false)
            row:SetScript("OnEnter",function(button)
                local item=button.entry
                if item.add then
                    GameTooltip:SetOwner(button,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("utility.add"),1,.82,.45)
                    GameTooltip:AddLine(FF:LocalizedText("utility.add-tooltip"),.76,.82,.8,true)
                    if panel.rowCount==1 then GameTooltip:AddLine(FF:LocalizedText("utility.empty"),.76,.82,.8,true) end
                    GameTooltip:Show()
                else
                    self:BeginJournalItemTooltip(button,item.id,item.name)
                    GameTooltip:AddLine(item.flyoutUnavailable and FF:LocalizedText("utility.unavailable") or FF:LocalizedText("utility.action-tooltip"),.83,.72,.52,true)
                    GameTooltip:AddLine(FF:LocalizedText("utility.requirements"),.76,.82,.8,true)
                    self:FinishJournalItemTooltip(button)
                end
            end)
            row:SetScript("OnLeave",function(button) self:HideJournalItemTooltip(button) end)
            local function AddDropped()
                local kind,id=GetCursorInfo()
                if kind=="item" and self:AddFishingUtility(id) then ClearCursor() end
            end
            row:SetScript("OnReceiveDrag",function(button) if button.entry.add then AddDropped() end end)
            if entry.add then
                row:SetScript("OnClick",function(_,mouse) if mouse=="LeftButton" then AddDropped() end end)
                panel.utilityAddButton=row
            else
                -- Plain selection controls have no secure use attributes. The
                -- opener arrow and choosing an item can never activate it.
                row:SetScript("OnClick",function(button,mouse)
                    if InCombatLockdown and InCombatLockdown() then return end
                    if mouse=="RightButton" then
                        if type(self.db.utilityHidden)~="table" then self.db.utilityHidden={} end
                        self.db.utilityHidden[button.entry.id]=true
                        if self.db.utilityItems then self.db.utilityItems[button.entry.id]=nil end
                        if self.db.utilitySelectedItem==button.entry.id then self.db.utilitySelectedItem=nil end
                        self:RefreshFishingUtilityButton(); self:RefreshUtilityPicker()
                    elseif mouse=="LeftButton" then
                        if self:SetSelectedFishingUtility(button.entry.id) then self:FinishFishingFlyoutSelection(panel)
                        else self:RefreshUtilityPicker() end
                    end
                end)
                panel.utilityItemButtons[index]=row
            end
        end
        panel.rows[index]=row
        row.entry=entry
        local available=not entry.flyoutUnavailable and (entry.add or Count(entry.id)>0)
        row:SetEnabled(available and true or false); row:SetAlpha(available and 1 or .35)
        local icon=not entry.add and ((C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(entry.id)) or GetItemIcon and GetItemIcon(entry.id))
        row.icon:SetTexture(not entry.add and (icon or self.utilitiesIcon) or nil); row.icon:SetTexCoord(0,1,0,1)
        row.icon:SetShown(not entry.add)
        row.count:SetText(entry.add and "" or tostring(available and Count(entry.id) or 0))
        RefreshCooldown(row,not entry.add and entry.id or nil)
        self:SetFishingFlyoutSelectionGlow(row,not entry.add and entry.id==self.db.utilitySelectedItem)
        row:Show()
    end
    for _,button in pairs(panel.utilityItemButtons) do
        local used=false
        for _,visible in ipairs(panel.rows) do if button==visible then used=true; break end end
        if not used then button:Hide() end
    end
    panel.flyoutFixedButton=panel.rows[#entries]
    if not panel.flyoutGeometryLocked then panel:SizeForRows(#entries) end
    self:PositionFishingFlyout(panel,self.utilityButton)
end
function FF:ShowUtilityPicker()
    if InCombatLockdown and InCombatLockdown() then return end
    if self.db.showUtilityButton~=true or not self.toolBar or not self.toolBar:IsShown()
        or self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
    self:EnsureFishingBarExpanded()
    if self.utilityPicker and self.utilityPicker:IsShown() then
        self.utilityPicker:Hide()
        return
    end
    self:CloseFishingFlyouts()
    if not self.utilityPicker then
        self.utilityPicker=self:CreateFishingQuickTray("ForeverFishingUtilitiesPicker",nil,"utility")
        self.utilityPicker.rows={}; self.utilityPicker.utilityItemButtons={}; self:BindFishingFlyoutOwner(self.utilityPicker)
        self.utilityPicker:SetScript("OnEvent",function() self:RefreshUtilityPicker() end)
        self.utilityPicker:HookScript("OnShow",function(frame)
            for _,event in ipairs({"BAG_UPDATE_DELAYED","PLAYER_EQUIPMENT_CHANGED","SPELL_UPDATE_COOLDOWN","BAG_UPDATE_COOLDOWN","GET_ITEM_INFO_RECEIVED"}) do frame:RegisterEvent(event) end
        end)
        self.utilityPicker:HookScript("OnHide",function(frame) frame:UnregisterAllEvents() end)
    end
    self.utilityPicker:Show(); self:RefreshUtilityPicker()
end
