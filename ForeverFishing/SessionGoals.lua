-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local function L(key, ...) return FF:LocalizedText(key, ...) end
local MAX_TARGET = 999999 -- Six readable digits; rejects overflow, exponents and fractional inputs.
FF.sessionGoalLimit = MAX_TARGET
local STATS_MEDIA = "Interface\\AddOns\\ForeverFishing\\Media\\Stats\\"
local CUSTOM_GOALS = {
    {id="custom:catches", nameKey="goals.custom.catches", unit="count", icon="CatchCount",
        noteKey="goals.custom.catches-help"},
    {id="custom:vendor", nameKey="goals.custom.vendor", unit="currency", icon="Vendor",
        noteKey="goals.custom.vendor-help"},
    {id="custom:time", nameKey="goals.custom.time", unit="minutes", icon="TimeFishing",
        noteKey="goals.custom.time-help"},
    {id="custom:casts", nameKey="goals.custom.casts", unit="count", icon="Casts",
        noteKey="goals.custom.casts-help"},
    {id="custom:auction", nameKey="goals.custom.auction", unit="currency", icon="Auction",
        noteKey="goals.custom.auction-help"},
}
local CUSTOM_BY_ID = {}
for _, goal in ipairs(CUSTOM_GOALS) do CUSTOM_BY_ID[goal.id] = goal end
function FF:RefreshSessionGoalLanguage()
    for _, goal in ipairs(CUSTOM_GOALS) do
        goal.name, goal.note = L(goal.nameKey), L(goal.noteKey)
    end
end
FF:RefreshSessionGoalLanguage()


local function GoalID(id) return CUSTOM_BY_ID[id] and id or tonumber(id) end

local function Owner() return UnitGUID and UnitGUID("player") end
local function Count(value)
    value = tonumber(value)
    return value and value == value and value < math.huge and math.max(0,math.floor(value)) or 0
end
local function FactionText(value, faction)
    if type(value) == "table" then return value[faction] end
    return value
end

-- This catalogue contains only curated direct catches and positively recorded
-- Journal items. No inventory/recipe/container scan can make an item eligible.
function FF:GetSessionGoalCatalogue()
    self:RefreshPendingNativeJournalNames()
    local faction = self:GetJournalFaction()
    local cache = self.sessionGoalCatalogue
    local locale=self:GetResolvedLocale()
    if cache and cache.revision == self.catchRevision and cache.faction == faction and cache.locale == locale and cache.nativeRevision==(self.nativeJournalNameRevision or 0) then return cache.items, cache.byID end
    local items, byID = {}, {}
    local function Add(id, name, detail, record)
        id = tonumber(id)
        if not id or id < 1 or id ~= math.floor(id) then return end
        local item = byID[id]
        if not item then
            item = {id=id,name=name or (GetItemInfo and GetItemInfo(id)) or (L("common.item-id",id)),context=detail or ""}
            byID[id],items[#items+1] = item,item
        end
        local places = self:GetFishingLocationSearchText(record and record.locations)
        local native=self:GetJournalItemDisplayName(id,item.name)
        if native~=item.name then item.displayName=native end
        item.search = self:FoldSearchText(item.name.." "..(record and record.name or "").." "..item.context.." "..places)
        if native~=item.name then item.search=item.search.." "..self:FoldSearchText(native) end
        local clientName=self:GetNativeItemName(id,item.name)
        if clientName~=item.name and clientName~=native then item.search=item.search.." "..self:FoldSearchText(clientName) end
        if locale~="enUS" then item.search=item.search.." "..self:FoldSearchText(self:GetJournalCatchReferenceSearchText(self:GetJournalCatchDefinition(id),faction)) end
    end
    for _, entry in ipairs(self.catchCollection or {}) do
        local guide = entry[3] or {}
        Add(entry[1], entry[2], table.concat({FactionText(guide.waters,faction) or "",guide.method or "",FactionText(guide.condition,faction) or ""}," "))
    end
    for id, record in pairs(self.db and self.db.journal or {}) do
        if type(record) == "table" and Count(record.count) > 0 then Add(id,record.name,nil,record) end
    end
    table.sort(items,function(a,b) return a.name < b.name or (a.name == b.name and a.id < b.id) end)
    self.sessionGoalCatalogue = {items=items,byID=byID,revision=self.catchRevision,faction=faction,locale=locale,nativeRevision=self.nativeJournalNameRevision or 0}
    return items,byID
end

function FF:GetSessionGoalPlan(create)
    local owner = Owner()
    if not owner or not self.db then return end
    local plans = self.db.sessionGoals
    if type(plans) ~= "table" then
        if not create then return end
        plans = {}; self.db.sessionGoals = plans
    end
    local plan = plans[owner]
    if type(plan) ~= "table" then
        if not create then return end
        plan = {targets={},order={}}; plans[owner] = plan
    end
    if create then
        if type(plan.targets) ~= "table" then plan.targets = {} end
        if type(plan.order) ~= "table" then plan.order = {} end
    end
    return plan
end

function FF:GetSessionGoalCaught(id)
    -- Always read the current canonical session, including before goal creation.
    -- Ended casts can only modify their original session; this is never a loot owner.
    local record = self.session and self.session.records and self.session.records[tonumber(id)]
    return Count(record and record.count)
end

function FF:GetSessionGoalProgress(id, values)
    if id == "custom:catches" then return Count(self.session and self.session.catches) end
    if id == "custom:casts" then return Count(self.session and self.session.casts) end
    if id == "custom:time" then return Count(self:CurrentSessionSeconds()) end
    if id == "custom:vendor" or id == "custom:auction" then
        values = values or self:GetCatchValues(false)
        if id == "custom:auction" and not values.hasAuctionSource then return nil end
        return Count(id == "custom:vendor" and values.vendor or values.auction)
    end
    return self:GetSessionGoalCaught(id)
end

local function FormatGoal(id, value)
    if value == nil then return L("common.unavailable") end
    value = Count(value)
    local goal = CUSTOM_BY_ID[id]
    if goal and goal.unit == "currency" then
        if GetCoinTextureString then return GetCoinTextureString(value, 12) end
        if C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then return C_CurrencyInfo.GetCoinTextureString(value, 12) end
        if FF:GetResolvedLocale() ~= "enUS" then
            return L("format.currency-numbers", FF:FormatDisplayCount(math.floor(value / 10000)),
                string.format("%02d", math.floor(value % 10000 / 100)), string.format("%02d", value % 100))
        end
        return string.format(L("format.currency"), math.floor(value / 10000), math.floor(value % 10000 / 100), value % 100)
    end
    if goal and goal.unit == "minutes" then
        return FF:FormatElapsedDisplay(value, true)
    end
    return FF:FormatDisplayCount(value)
end

function FF:ValidateCustomSessionGoalTarget(id, value)
    local goal = CUSTOM_BY_ID[id]
    if not goal then return nil,L("goals.choose-custom") end
    if goal.unit == "currency" then
        if type(value) ~= "table" then return nil,L("goals.enter-currency") end
        local amounts = {}
        for index, field in ipairs({"gold", "silver", "copper"}) do
            local text = tostring(value[field] or "")
            if text == "" then text = "0" end
            local number = text:match("^%d+$") and tonumber(text)
            if not number or number > (index == 1 and MAX_TARGET or 99) then
                return nil,L("goals.currency-range")
            end
            amounts[index] = number
        end
        local target = amounts[1] * 10000 + amounts[2] * 100 + amounts[3]
        if target < 1 then return nil,L("goals.positive-value") end
        return target
    end
    local target,error = self:ValidateSessionGoalTarget(value)
    return target and (goal.unit == "minutes" and target * 60 or target),error
end

function FF:GetCustomSessionGoalCatalogue(values)
    values = values or self:GetCatchValues(false)
    local plan = self:GetSessionGoalPlan()
    local targets = plan and plan.targets or {}
    local goals = {}
    for _, goal in ipairs(CUSTOM_GOALS) do
        if goal.id ~= "custom:auction" or targets[goal.id]
            or (values.hasAuctionSource and Count(self.session and self.session.catches) > values.auctionMissing) then
            goals[#goals+1] = goal
        end
    end
    return goals
end

function FF:ValidateSessionGoalTarget(value)
    local text = tostring(value or "")
    if not text:match("^%d+$") then return nil,L("goals.target-range",MAX_TARGET) end
    local target = tonumber(text)
    if not target or target < 1 or target > MAX_TARGET then return nil,L("goals.target-range",MAX_TARGET) end
    return target
end

function FF:SetSessionGoal(id, value)
    id = GoalID(id)
    local _, catalogue = self:GetSessionGoalCatalogue()
    local custom = CUSTOM_BY_ID[id]
    if not id or not (custom or catalogue[id]) then return false,L("goals.choose-catch") end
    if id == "custom:auction" then
        local eligible = false
        for _, goal in ipairs(self:GetCustomSessionGoalCatalogue()) do if goal.id == id then eligible = true end end
        if not eligible then return false,L("goals.auction-unavailable") end
    end
    local target, error
    if custom then target,error = self:ValidateCustomSessionGoalTarget(id,value)
    else target,error = self:ValidateSessionGoalTarget(value) end
    if not target then return false,error end
    local plan = self:GetSessionGoalPlan(true)
    if not plan then return false,L("goals.owner-unavailable") end
    if not plan.targets[id] then plan.order[#plan.order+1] = id end
    plan.targets[id] = target
    self:RefreshSessionGoals()
    return true
end

function FF:RemoveSessionGoal(id)
    local plan = self:GetSessionGoalPlan()
    if not plan or type(plan.targets) ~= "table" then return end
    id = GoalID(id)
    if not id then return end
    plan.targets[id] = nil
    for index = #(plan.order or {}),1,-1 do
        if plan.order[index] == id then table.remove(plan.order,index) end
    end
    self:RefreshSessionGoals()
end

local SESSION_PALETTE = {
    text = {0.92, 0.85, 0.73},
    gold = {1, 0.84, 0.52},
    separator = {0.76, 0.49, 0.20},
}
FF.sessionWindowPalette = SESSION_PALETTE

local function Text(parent, x,y, text, template)
    local font = parent:CreateFontString(nil,"OVERLAY",template or "GameFontHighlightSmall")
    font:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y); font:SetText(text or "")
    font:SetJustifyH("LEFT"); font:SetWordWrap(true)
    font:SetTextColor(unpack(SESSION_PALETTE.text))
    return font
end
local function Button(parent,label,width,height,click)
    local button = CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    button:SetSize(width,height); button:SetText(label); button:SetScript("OnClick",click)
    return button
end

local function ClearEditorFocus(panel)
    for _, key in ipairs({"targetInput", "silverInput", "copperInput"}) do
        if panel[key] then panel[key]:ClearFocus() end
    end
end

local function EditorValue(panel)
    local goal = CUSTOM_BY_ID[panel.expandedID]
    if goal and goal.unit == "currency" then
        return {gold=panel.targetInput:GetText(), silver=panel.silverInput:GetText(), copper=panel.copperInput:GetText()}
    end
    return panel.targetInput:GetText()
end

local function ValidateEditor(panel)
    if not panel.expandedID then return end
    local target,error
    if CUSTOM_BY_ID[panel.expandedID] then target,error = FF:ValidateCustomSessionGoalTarget(panel.expandedID,EditorValue(panel))
    else target,error = FF:ValidateSessionGoalTarget(EditorValue(panel)) end
    panel.commit:SetEnabled(target ~= nil); panel.error:SetText(target and "" or error)
end

function FF:SetSessionGoalsMode(mode)
    local panel = self.sessionGoalsPanel
    if not panel then return end
    panel.mode, panel.expandedID = mode == "list" and "list" or "tracking",nil
    panel.revealEditorID=nil
    ClearEditorFocus(panel); panel.editor:Hide()
    if panel.search then panel.search:ClearFocus() end
    self:RenderSessionGoals()
end

function FF:EditSessionGoal(id)
    local panel = self.sessionGoalsPanel
    if not panel or panel.mode ~= "list" then return end
    ClearEditorFocus(panel)
    panel.expandedID = panel.expandedID ~= id and id or nil
    panel.initializingEditor=true
    local plan = self:GetSessionGoalPlan()
    local target = plan and plan.targets and plan.targets[id]
    local goal = CUSTOM_BY_ID[id]
    if goal and goal.unit == "currency" then
        target = target or 10000
        panel.targetInput:SetText(tostring(math.floor(target / 10000)))
        panel.silverInput:SetText(tostring(math.floor(target % 10000 / 100)))
        panel.copperInput:SetText(tostring(target % 100))
    else
        panel.targetInput:SetText(tostring(target and goal and goal.unit == "minutes" and target / 60 or target or 1))
    end
    panel.error:SetText("")
    panel.initializingEditor=nil; panel.revealEditorID=panel.expandedID
    self:RenderSessionGoals()
end

function FF:CommitSessionGoalEditor()
    local panel = self.sessionGoalsPanel
    if not panel or not panel.expandedID then return end
    local ok,error = self:SetSessionGoal(panel.expandedID,EditorValue(panel))
    if not ok then panel.error:SetText(error); return end
    ClearEditorFocus(panel); panel.expandedID = nil
    panel.error:SetText(""); self:RenderSessionGoals()
end

local function Row(panel, index)
    local row = panel.rows[index]
    if row then return row end
    row = CreateFrame("Button",nil,panel.content); row:SetWidth(360); row:RegisterForClicks("LeftButtonUp")
    row:EnableMouseWheel(true)
    row:SetScript("OnMouseWheel",function(_,delta)
        panel.scroll:SetVerticalScroll(math.max(0,math.min(panel.scroll:GetVerticalScrollRange(),panel.scroll:GetVerticalScroll()-delta*45)))
    end)
    row.icon = row:CreateTexture(nil,"ARTWORK"); row.icon:SetSize(28,28); row.icon:SetPoint("TOPLEFT",row,"TOPLEFT",2,-7)
    row.name = Text(row,38,-6,""); row.name:SetWidth(198)
    row.count = Text(row,38,-23,"")
    row.remove = Button(row,"−",22,22,function() FF:RemoveSessionGoal(row.itemID) end)
    row.remove:SetPoint("TOPRIGHT",row,"TOPRIGHT",-1,-9)
    row.check = row:CreateTexture(nil,"ARTWORK"); row.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    row.check:SetSize(20,20); row.check:SetPoint("TOPRIGHT",row,"TOPRIGHT",-26,-10)
    row.chevron = row:CreateTexture(nil,"ARTWORK"); row.chevron:SetSize(16,9)
    row.chevron:SetPoint("TOPRIGHT",row,"TOPRIGHT",-2,-13.5)
    row.line = row:CreateTexture(nil,"BORDER"); row.line:SetPoint("BOTTOMLEFT"); row.line:SetPoint("BOTTOMRIGHT"); row.line:SetHeight(1)
    local separator = SESSION_PALETTE.separator
    row.line:SetColorTexture(separator[1], separator[2], separator[3], 0.3)
    row:SetScript("OnClick",function() if panel.mode == "list" then FF:EditSessionGoal(row.itemID) end end)
    row:SetScript("OnEnter",function(frame)
        GameTooltip:SetOwner(frame,"ANCHOR_RIGHT")
        if frame.goal then
            GameTooltip:SetText(frame.fullName)
            GameTooltip:AddLine(frame.goal.note, 0.8, 0.8, 0.8, true)
            if frame.valueNote then GameTooltip:AddLine(frame.valueNote, 0.8, 0.8, 0.8, true) end
        else
            FF:BeginJournalItemTooltip(frame,frame.itemID,frame.fullName)
        end
        if frame.goal then GameTooltip:Show() else FF:FinishJournalItemTooltip(frame) end
    end)
    row:SetScript("OnLeave",function(frame) FF:HideJournalItemTooltip(frame) end)
    panel.rows[index] = row
    return row
end

function FF:SyncSessionGoalsClock()
    local panel = self.sessionGoalsPanel
    local plan = self:GetSessionGoalPlan()
    local needed = panel and panel:IsShown() and not panel.goalsMinimized and (not panel.IsVisible or panel:IsVisible())
        and self.session and self.session.activeStarted
        and ((panel.mode == "tracking" and plan and plan.targets and plan.targets["custom:time"])
            or panel.expandedID == "custom:time")
    if not needed and self.sessionGoalsClock then
        self.sessionGoalsClock:Cancel(); self.sessionGoalsClock = nil
    elseif needed and not self.sessionGoalsClock and C_Timer and C_Timer.NewTicker then
        -- A visible display clock only. Canonical session time accrues when hidden.
        self.sessionGoalsClock = C_Timer.NewTicker(1, function()
            local current = FF.sessionGoalsPanel
            if current and current:IsShown() and (not current.IsVisible or current:IsVisible()) then
                FF:RefreshSessionGoals()
            else
                if FF.sessionGoalsClock then FF.sessionGoalsClock:Cancel(); FF.sessionGoalsClock = nil end
            end
        end)
    end
end

local function LayoutGoalEditor(panel, row, target, progress, width, inset)
    local goal = row.goal
    local currency = goal and goal.unit == "currency"
    panel.editor:ClearAllPoints(); panel.editor:SetPoint("TOPLEFT",row,"TOPLEFT",inset,-row.headerHeight-2)
    panel.editor:SetWidth(width); panel.editor:Show()
    panel.targetLabel:SetText(currency and L("goals.currency-target") or goal and goal.unit == "minutes" and L("goals.minutes-target") or L("goals.target"))
    panel.targetLabel:SetWidth(width)
    local inputTop=math.ceil(panel.targetLabel:GetStringHeight())+8
    panel.silverInput:SetShown(currency); panel.copperInput:SetShown(currency)
    for _, label in ipairs(panel.currencyLabels) do label:SetShown(currency) end
    panel.unitLabel:SetShown(not currency)
    local bottom=inputTop+24
    if currency then
        local x,y=0,inputTop
        for index,field in ipairs({panel.targetInput,panel.silverInput,panel.copperInput}) do
            local fieldWidth=index==1 and 80 or 46
            local label=panel.currencyLabels[index]
            local groupWidth=fieldWidth+math.max(22,math.ceil(label:GetStringWidth())+10)
            if x>0 and x+groupWidth>width then x=0; y=y+30 end
            field:SetWidth(fieldWidth);field:ClearAllPoints();field:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",x,-y)
            label:ClearAllPoints();label:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",x+fieldWidth+5,-y-6)
            x=x+groupWidth+8;bottom=y+24
        end
    else
        panel.targetInput:SetWidth(65);panel.targetInput:ClearAllPoints();panel.targetInput:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",0,-inputTop)
        panel.unitLabel:SetText(goal and goal.unit == "minutes" and L("goals.unit-minutes") or L("goals.unit-count"))
        panel.unitLabel:ClearAllPoints();panel.unitLabel:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",73,-inputTop-6)
    end
    panel.commit:SetText(target and L("goals.update") or L("goals.add"))
    local actionFont=panel.commit.GetFontString and panel.commit:GetFontString()
    local measure=panel.headerMeasure
    if actionFont and actionFont.GetFont then FF:CopyDisplayFont(measure,actionFont) end
    measure:SetWidth(0);measure:SetWordWrap(false);measure:SetText(panel.commit:GetText())
    local actionWidth=math.min(width,math.max(117,math.ceil(measure:GetStringWidth())+20))
    panel.commit:SetWidth(actionWidth)
    measure:SetWidth(math.max(1,actionWidth-20));measure:SetWordWrap(true)
    panel.commit:SetHeight(math.max(24,math.ceil(measure:GetStringHeight())+10))
    if actionFont then actionFont:SetWidth(math.max(1,actionWidth-20));actionFont:SetWordWrap(true) end
    local unitWidth=not currency and math.ceil(panel.unitLabel:GetStringWidth()) or 0
    local inline=not currency and width>=73+unitWidth+12+panel.commit:GetWidth()
    local commitTop=inline and inputTop or bottom+6
    panel.commit:ClearAllPoints()
    panel.commit:SetPoint(inline and "TOPRIGHT" or "TOPLEFT",panel.editor,inline and "TOPRIGHT" or "TOPLEFT",inline and -1 or 0,-commitTop)
    panel.editor.actionTop=0;panel.editor.actionBottom=commitTop+panel.commit:GetHeight()
    panel.editor.commitTop=commitTop
    local currentTop=math.max(bottom,panel.editor.actionBottom)+8
    panel.editorCaught:ClearAllPoints(); panel.editorCaught:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",0,-currentTop)
    panel.editorCaught:SetWidth(width)
    panel.editorCaught:SetText(L(goal and "goals.session-progress" or "goals.catch-progress",progress))
    ValidateEditor(panel)
    panel.error:ClearAllPoints()
    panel.error:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",0,-currentTop-panel.editorCaught:GetStringHeight()-5)
    panel.error:SetWidth(width)
    local height = currentTop + panel.editorCaught:GetStringHeight() + 12
        + (panel.error:GetText() ~= "" and panel.error:GetStringHeight()+5 or 0)
    panel.editor:SetHeight(height)
    return height + 8
end

local function HeaderHelp(owner,text)
    owner:SetScript("OnEnter",function(button)
        GameTooltip:SetOwner(button,"ANCHOR_RIGHT");GameTooltip:SetText(type(text)=="function" and text() or text,nil,nil,nil,nil,true);GameTooltip:Show()
    end)
    owner:SetScript("OnLeave",function() GameTooltip:Hide() end)
end

function FF:CreateSessionHeaderAccent(parent)
    local accent = parent:CreateTexture(nil, "ARTWORK")
    accent:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -9); accent:SetSize(2, 16)
    accent:SetColorTexture(0.18, 0.78, 0.82, 0.95)
    return accent
end

function FF:CreateSessionWindow(name, width, height, title, moveHelp, closeHelp)
    local panel = CreateFrame("Frame", name, self:EnsureFishingVisibilityRoot(), "SecureHandlerStateTemplate")
    panel:SetSize(width, height); panel:SetPoint("CENTER"); panel:EnableMouse(true)
    panel.border = self:StyleFishingBarFrame(panel)
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT"); header:SetPoint("TOPRIGHT"); header:SetHeight(36)
    if title then
        panel.title = Text(header, 17, -11, title, "GameFontNormal")
        panel.title:SetTextColor(unpack(SESSION_PALETTE.gold)); panel.title:SetWordWrap(false)
        self:CreateSessionHeaderAccent(header)
    end
    HeaderHelp(header, moveHelp)
    panel.close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    panel.close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
    panel.close:SetScript("OnClick", function() panel:Hide() end)
    HeaderHelp(panel.close, closeHelp)
    return panel, header
end

function FF:ShowFloatingSessionWindow(panel, explicitOpen)
    if explicitOpen then
        self:ShowFloatingWindow(panel)
    else
        -- Resume without changing the order of existing windows or closing trays.
        if not panel.floatingWasShown then
            self:BringFishingWindowForward(panel)
            panel.floatingWasShown = true
        end
        panel:Show()
        self:RefreshFishingLayer()
    end
end

function FF:ResolveSessionWindowNativeHide(panel, sync, close)
    if panel:IsShown() or self.dataResetPendingReload then return end
    if InCombatLockdown and InCombatLockdown() then close(self); return end
    -- Escape and Alt+Z both close special windows. A UIParent visibility
    -- transition will restore a requested window and cancel this dismissal.
    local db, dismissal = self.db, {}
    local field = panel.floatingLayoutKey .. "Panel"
    panel.sessionWindowDismissal = dismissal
    C_Timer.After(0, function()
        if self.db ~= db or self[field] ~= panel or panel.sessionWindowDismissal ~= dismissal
            or self.dataResetPendingReload then return end
        panel.sessionWindowDismissal = nil
        if UIParent and not UIParent:IsShown() then sync(self)
        else close(self) end
    end)
end

local function LayoutGoalsHeader(panel)
    local list=panel.mode=="list"
    local addShown=not list and not panel.goalsMinimized
    panel.plus:SetShown(addShown)
    local measure=panel.headerMeasure
    measure:SetWidth(0);measure:SetWordWrap(false)
    local font=panel.plus.GetFontString and panel.plus:GetFontString()
    if font and font.GetFont then FF:CopyDisplayFont(measure,font) end
    local function ButtonWidth(label,minimum)
        measure:SetText(label);return math.max(minimum,math.ceil(measure:GetStringWidth())+22)
    end
    local addWidth=ButtonWidth(L("goals.add-heading"),74)
    panel.title:SetWidth(1000);panel.title:SetText(L("goals.title-command"))
    local fullTitle=panel.title:GetStringWidth()
    local right=addShown and 71+addWidth or 63
    if addShown and fullTitle>panel:GetWidth()-17-right-8 then
        addWidth=ButtonWidth(L("goals.add-short"),42);panel.plus:SetText(L("goals.add-short"))
    else panel.plus:SetText(L("goals.add-heading")) end
    panel.plus:SetWidth(addWidth)
    right=addShown and 71+addWidth or 63
    local available=math.max(1,panel:GetWidth()-17-right-8)
    for _,label in ipairs({L("goals.title-command"),L("goals.title"),L("goals.title-short")}) do
        panel.title:SetText(label)
        if panel.title:GetStringWidth()<=available then break end
    end
    panel.title:SetWidth(available)
    panel.minimizeButton:SetText(panel.goalsMinimized and "+" or "−")
end

function FF:SetSessionGoalsMinimized(minimized)
    local panel=self.sessionGoalsPanel
    if not panel or (InCombatLockdown and InCombatLockdown()) then return end
    minimized=minimized==true
    if minimized==panel.goalsMinimized then return end
    if minimized then
        panel.minimizedScroll=panel.scroll:GetVerticalScroll()
        local focus=self.journalInputFocus
        if focus==panel.search or focus==panel.targetInput or focus==panel.silverInput or focus==panel.copperInput then panel.minimizedFocus=focus end
        panel.search:ClearFocus();ClearEditorFocus(panel)
    end
    if not self:SetFloatingWindowMinimized(panel,minimized,38) then return end
    panel.goalsMinimized=minimized
    if not minimized and panel.minimizedScroll then
        panel.scroll:SetVerticalScroll(panel.minimizedScroll);panel.minimizedScroll=nil
    end
    self:RenderSessionGoals()
    if not minimized then
        local focus=panel.minimizedFocus;panel.minimizedFocus=nil
        if focus and panel:IsShown() and not self.journalInputFocus and panel.mode=="list"
            and (focus==panel.search or panel.expandedID) then focus:SetFocus() end
    end
end

-- Called once after the selected entry and scroll child are fully measured.
-- Over-tall editors prioritize their commit action; all other controls remain
-- reachable through the same ordinary scroll owner. Updates/typing never arm it.
local function RevealGoalEditor(panel,top,bottom,commitTop)
    local height=panel.scroll:GetHeight()
    if not height or height<=0 then return end
    local scroll=panel.scroll:GetVerticalScroll()
    local wanted=scroll
    if bottom-top>height-8 then top=commitTop end
    if top<scroll+4 then wanted=top-4
    elseif bottom>scroll+height-4 then wanted=bottom-height+4 end
    wanted=math.max(0,math.min(panel.scroll:GetVerticalScrollRange(),wanted))
    if math.abs(wanted-scroll)>.01 then panel.scroll:SetVerticalScroll(wanted) end
end

function FF:RenderSessionGoals()
    local panel = self.sessionGoalsPanel
    if not panel or not panel:IsShown() or panel.floatingSizeChanging then return end
    LayoutGoalsHeader(panel)
    panel.scaleGrip:SetShown(not panel.goalsMinimized)
    if panel.goalsMinimized then
        panel.scroll:Hide();panel.search:Hide();panel.done:Hide();panel.editor:Hide()
        self:SyncSessionGoalsClock();return
    end
    panel.scroll:Show()
    local scroll = panel.scroll:GetVerticalScroll()
    local list = panel.mode == "list"
    local catalogue,byID = self:GetSessionGoalCatalogue()
    local plan = self:GetSessionGoalPlan()
    local targets = plan and plan.targets or {}
    local items = {}
    local needsValues = list or targets["custom:vendor"] or targets["custom:auction"]
    local values = needsValues and self:GetCatchValues(false)
    local catchCount = 0
    if list then
        for _, goal in ipairs(self:GetCustomSessionGoalCatalogue(values)) do items[#items+1] = goal end
        local query = self:FoldSearchText(panel.search:GetText() or "")
        for _, item in ipairs(catalogue) do
            if query == "" or item.search:find(query,1,true) then items[#items+1] = item; catchCount = catchCount + 1 end
        end
    else
        for _, id in ipairs(plan and plan.order or {}) do
            if targets[id] then items[#items+1] = CUSTOM_BY_ID[id] or byID[id] or {id=id,name=L("common.item-id",id)} end
        end
    end
    local width = math.max(1, panel:GetWidth()-42)
    panel.content:SetWidth(width)
    panel.search:SetWidth(panel:GetWidth()-51)
    panel.done:SetWidth(panel:GetWidth()-52)
    panel.empty:SetWidth(width-8)
    panel.scroll:ClearAllPoints()
    panel.scroll:SetPoint("TOPLEFT",panel,"TOPLEFT",12,list and -76 or -39)
    panel.scroll:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-30,list and 42 or 30)
    panel.search:SetShown(list); panel.done:SetShown(list); panel.plus:SetShown(not list)
    panel.empty:SetShown(list and catchCount == 0 or not list and #items == 0)
    panel.empty:SetText(list and L("goals.no-matches") or L("goals.empty",panel.plus:GetText()))
    panel.customHeading:SetShown(list); panel.catchHeading:SetShown(list)
    panel.customHeading:SetWidth(width); panel.catchHeading:SetWidth(width)
    local y, editRow, actionTop, actionBottom, commitTop = 0
    if list then y = panel.customHeading:GetStringHeight()+12 end
    local catchHeadingPlaced = false
    for index,item in ipairs(items) do
        local row = Row(panel,index)
        local goal = CUSTOM_BY_ID[item.id]
        if list and not goal and not catchHeadingPlaced then
            panel.catchHeading:ClearAllPoints(); panel.catchHeading:SetPoint("TOPLEFT",panel.content,"TOPLEFT",4,-y-6)
            y = y + panel.catchHeading:GetStringHeight()+18; catchHeadingPlaced = true
        end
        row.itemID,row.fullName = item.id,item.displayName or item.name
        row.goal = goal
        row:SetWidth(width); row.name:SetWidth(width-38-(list and 24 or 52))
        row.count:SetWidth(width-38-(list and 24 or 52))
        row.icon:SetTexture(goal and STATS_MEDIA..goal.icon or self:GetJournalItemIcon(item.id))
        row.name:SetText(item.displayName or item.name)
        local caught = self:GetSessionGoalProgress(item.id, values)
        local target = targets[item.id]
        local progress = FormatGoal(item.id,caught)
        row.valueNote = nil
        if goal and goal.unit == "currency" then
            local missing = item.id == "custom:vendor" and values.vendorMissing or values.auctionMissing
            if missing > 0 then
                progress = progress .. "*"
                row.valueNote = item.id == "custom:vendor" and L("goals.vendor-loading")
                    or L("goals.auction-fallback")
            end
        end
        row.count:SetText(list and (target and L("goals.saved-target",FormatGoal(item.id,target)) or "") or progress.." / "..FormatGoal(item.id,target))
        local complete = not list and caught ~= nil and caught >= target
        if complete then
            row.count:SetTextColor(0.4, 0.95, 0.46)
        else
            row.count:SetTextColor(unpack(SESSION_PALETTE.gold))
        end
        row.check:SetShown(complete)
        row.remove:SetShown(not list)
        row.chevron:SetShown(list)
        self:SetJournalChevron(row.chevron, panel.expandedID ~= item.id)
        row:ClearAllPoints(); row:SetPoint("TOPLEFT",panel.content,"TOPLEFT",0,-y)
        row.count:ClearAllPoints(); row.count:SetPoint("TOPLEFT",row,"TOPLEFT",38,-9-row.name:GetStringHeight())
        local headerHeight=math.max(44,16+row.name:GetStringHeight()+row.count:GetStringHeight())
        row.headerHeight=headerHeight
        -- Only the header toggles. The sibling editor is outside this click region.
        row:SetHeight(headerHeight)
        row:Show()
        if list and panel.expandedID == item.id then
            editRow = row
            local inset=width<270 and 4 or 38
            local editorHeight=LayoutGoalEditor(panel,row,target,progress,width-inset,inset)
            local editorTop=y+headerHeight+2
            actionTop,actionBottom=editorTop+panel.editor.actionTop,editorTop+panel.editor.actionBottom
            commitTop=editorTop+panel.editor.commitTop
            y = y + editorHeight
        end
        y = y + headerHeight+1
    end
    for index=#items+1,#panel.rows do panel.rows[index]:Hide() end
    if not editRow then panel.editor:Hide() end
    if list and not catchHeadingPlaced then
        panel.catchHeading:ClearAllPoints(); panel.catchHeading:SetPoint("TOPLEFT",panel.content,"TOPLEFT",4,-y-6)
        y = y + panel.catchHeading:GetStringHeight()+18
    end
    panel.empty:ClearAllPoints(); panel.empty:SetPoint("TOPLEFT",panel.content,"TOPLEFT",4,-y-8)
    if panel.empty:IsShown() then y = y + panel.empty:GetStringHeight()+18 end
    panel.content:SetHeight(math.max(1,y))
    if panel.scroll.UpdateScrollChildRect then panel.scroll:UpdateScrollChildRect() end
    panel.scroll:SetVerticalScroll(math.min(scroll,panel.scroll:GetVerticalScrollRange()))
    local reveal=panel.revealEditorID;panel.revealEditorID=nil
    if editRow and reveal==panel.expandedID then RevealGoalEditor(panel,actionTop,actionBottom,commitTop) end
    panel.renderedStatsRevision = self.statsRevision
    self:SyncSessionGoalsClock()
end

function FF:RefreshSessionGoals()
    local panel = self.sessionGoalsPanel
    if panel and panel:IsShown() then
        if self.IsCameraSearchPending and self:IsCameraSearchPending() then self:CloseSessionGoals(); return end
        self:RenderSessionGoals()
    end
end

function FF:CloseSessionGoals(remember)
    self.sessionGoalsRequested = nil
    if not remember and self.db and not self.dataResetPendingReload then self.db.sessionGoalsOpen = nil end
    local panel = self.sessionGoalsPanel
    if not panel then return end
    panel.sessionWindowDismissal = nil
    panel.search:ClearFocus(); ClearEditorFocus(panel)
    panel.expandedID, panel.mode, panel.revealEditorID = nil, "tracking", nil
    panel.minimizedFocus, panel.minimizedScroll = nil, nil
    panel.editor:Hide()
    if panel:IsShown() then panel:Hide() end
end

function FF:RestoreSessionGoals()
    if not self.db or self.db.sessionGoalsOpen ~= true or self.dataResetPendingReload then return end
    self.sessionGoalsRequested = true
    self:SyncSessionGoalsVisibility()
end

function FF:ShowSessionGoals(preserveView)
    if not self.db or self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown())
        or (self.IsCameraSearchPending and self:IsCameraSearchPending()) then return end
    self.sessionGoalsRequested = true
    self.db.sessionGoalsOpen = true
    self:SyncSessionGoalsVisibility(true, preserveView)
end

function FF:SyncSessionGoalsVisibility(explicitOpen, preserveView)
    if not self.sessionGoalsRequested or self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown()) then return end
    local panel = self.sessionGoalsPanel
    local alreadyOpen = panel and panel:IsShown()
    if alreadyOpen and not explicitOpen then return end
    if self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
    if not panel then
        local header
        panel, header = self:CreateSessionWindow("ForeverFishingSessionGoals", 402, 326,
            L("goals.title-command"), L("goals.move-help"), L("goals.close"))
        panel:Hide()
        panel.close:SetScript("OnClick", function() self:CloseSessionGoals() end)
        panel.floatingResizeOnly = true
        panel.headerMeasure=Text(header,0,0,"");panel.headerMeasure:Hide()
        panel.plus = Button(header,L("goals.add-heading"),74,24,function() FF:SetSessionGoalsMode("list") end)
        panel.plus:SetPoint("TOPRIGHT",header,"TOPRIGHT",-71,-6)
        panel.addGoal=panel.plus
        HeaderHelp(panel.plus,L("goals.add-help"))
        panel.minimizeButton=Button(header,"−",24,24,function() FF:SetSessionGoalsMinimized(not panel.goalsMinimized) end)
        panel.minimizeButton:SetPoint("TOPRIGHT", panel.close, "TOPLEFT", -4, 0)
        HeaderHelp(panel.minimizeButton,function() return panel.goalsMinimized and L("goals.expand") or L("goals.minimize-help") end)
        panel.search = self:CreateJournalEditBox(panel,351,L("goals.search"))
        panel.search:SetPoint("TOPLEFT",panel,"TOPLEFT",19,-47)
        panel.search:HookScript("OnTextChanged",function()
            panel.expandedID=nil;panel.revealEditorID=nil; ClearEditorFocus(panel); panel.scroll:SetVerticalScroll(0); FF:RenderSessionGoals()
        end)
        panel.scroll = CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate")
        panel.content = CreateFrame("Frame",nil,panel.scroll); panel.content:SetSize(360,1)
        panel.scroll:SetScrollChild(panel.content); panel.scroll:EnableMouseWheel(true)
        panel.scroll:SetScript("OnMouseWheel",function(_,delta) panel.scroll:SetVerticalScroll(math.max(0,math.min(panel.scroll:GetVerticalScrollRange(),panel.scroll:GetVerticalScroll()-delta*45))) end)
        panel.rows = {}
        panel.empty = Text(panel.content,4,-8,""); panel.empty:SetWidth(330)
        panel.customHeading = Text(panel.content,4,-4,L("goals.custom-heading"),"GameFontNormal")
        panel.customHeading:SetTextColor(unpack(SESSION_PALETTE.gold))
        panel.catchHeading = Text(panel.content,4,0,L("goals.catches-heading"),"GameFontNormal")
        panel.catchHeading:SetTextColor(unpack(SESSION_PALETTE.gold))
        panel.done = Button(panel,L("goals.done"),366,23,function() FF:SetSessionGoalsMode("tracking") end)
        panel.done:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",12,10)
        panel.editor = CreateFrame("Frame",nil,panel.content); panel.editor:SetSize(294,88)
        panel.targetLabel = Text(panel.editor,0,-1,L("goals.target"))
        panel.targetInput = self:CreateJournalEditBox(panel.editor,65,"")
        panel.targetInput:SetMaxLetters(12); panel.targetInput:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",95,4)
        panel.silverInput = self:CreateJournalEditBox(panel.editor,46,"")
        panel.silverInput:SetMaxLetters(12); panel.silverInput:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",111,-22)
        panel.copperInput = self:CreateJournalEditBox(panel.editor,46,"")
        panel.copperInput:SetMaxLetters(12); panel.copperInput:SetPoint("TOPLEFT",panel.editor,"TOPLEFT",188,-22)
        panel.currencyLabels = {Text(panel.editor,85,-28,L("currency.gold-short")), Text(panel.editor,162,-28,L("currency.silver-short")), Text(panel.editor,239,-28,L("currency.copper-short"))}
        panel.unitLabel = Text(panel.editor,73,-28,L("goals.unit-count"))
        panel.commit = Button(panel.editor,L("goals.add"),117,24,function() FF:CommitSessionGoalEditor() end)
        panel.commit:SetPoint("TOPRIGHT",panel.editor,"TOPRIGHT",-1,4)
        panel.editorCaught = Text(panel.editor,0,-29,"")
        panel.error = Text(panel.editor,0,-47,""); panel.error:SetWidth(290); panel.error:SetTextColor(1,0.4,0.3)
        for _, input in ipairs({panel.targetInput,panel.silverInput,panel.copperInput}) do
            input:HookScript("OnTextChanged",function() if panel.expandedID and not panel.initializingEditor then FF:RenderSessionGoals() end end)
            input:SetScript("OnEnterPressed",function() FF:CommitSessionGoalEditor() end)
        end
        panel:HookScript("OnHide",function()
            panel.search:ClearFocus(); ClearEditorFocus(panel); panel.minimizedFocus=nil
            if panel.scaleGrip then panel.scaleGrip.scaling = nil; panel.scaleGrip:SetScript("OnUpdate",nil) end
            FF:SyncSessionGoalsClock()
            if self.sessionGoalsRequested then
                self:ResolveSessionWindowNativeHide(panel, self.SyncSessionGoalsVisibility, self.CloseSessionGoals)
            end
        end)
        self.sessionGoalsPanel = panel
        self:PrepareFloatingWindow(panel,"sessionGoals",header)
        panel.scaleGrip:SetSize(20,20)
        panel:SetScript("OnSizeChanged",function() FF:RenderSessionGoals() end)
        panel:HookScript("OnShow",function()
            panel.sessionWindowDismissal = nil
            FF:RenderSessionGoals()
        end)
        panel.OnFloatingResizeFinished = function() FF:RenderSessionGoals() end
        self:RegisterCombatCloseWindow("sessionGoals",panel)
        if UISpecialFrames then UISpecialFrames[#UISpecialFrames+1]="ForeverFishingSessionGoals" end
    end
    if explicitOpen and panel.goalsMinimized then self:SetSessionGoalsMinimized(false) end
    self:ShowFloatingSessionWindow(panel, explicitOpen)
    if explicitOpen and not (preserveView and alreadyOpen) then self:SetSessionGoalsMode("tracking") end
end

SLASH_FOREVERFISHINGGOALS1 = "/goals"
SlashCmdList.FOREVERFISHINGGOALS = function() FF:ShowSessionGoals() end
