-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local ICONS = {guide="Interface\\Icons\\INV_Misc_Book_09",seller="Interface\\Icons\\INV_Misc_Coin_01",
    achievement="Interface\\Icons\\Achievement_General",history="Interface\\Icons\\INV_Misc_PocketWatch_01"}
local function Plain(text)
    return tostring(text or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("|H.-|h(.-)|h","%1"):gsub("|T.-|t","")
end
local function Flatten(value,faction,parts,seen)
    parts = parts or {}; seen = seen or {}
    if type(value) == "string" or type(value) == "number" then parts[#parts+1] = Plain(value)
    elseif type(value) == "table" and not seen[value] then
        seen[value] = true
        if value.Alliance or value.Horde then Flatten(value[faction],faction,parts,seen)
        else for key,item in pairs(value) do
            if key ~= "icon" and key ~= "texture" and key ~= "recipeID" then Flatten(item,faction,parts,seen) end
        end end
    end
    return table.concat(parts," ")
end
local function ViewKey(tab, chef, history)
    return tab == "chef" and "chef:"..(chef or "campfire") or tab == "session" and history and "session:history" or tab
end
function FF:GetJournalSearchView()
    local panel = self.journalPanel
    return ViewKey(self.journalTab or "catch",panel and panel.chefView,panel and panel.sessionHistoryShown)
end
local function Verified(point)
    return point and type(point.mapID) == "number" and point.mapID > 0
        and type(point.x) == "number" and point.x >= 0 and point.x <= 1
        and type(point.y) == "number" and point.y >= 0 and point.y <= 1
end

function FF:GetJournalSearchIndex()
    if not self.db then return {} end
    self:RefreshPendingNativeJournalNames()
    self:WarmJournalFoodEffects()
    local faction = self:GetJournalFaction()
    local owner = UnitGUID and UnitGUID("player") or ""
    local mapID, zone = self:GetNearbyContext()
    local revision = table.concat({faction,owner,tostring(self.catchRevision),tostring(self.sessionHistoryRevision),
        self:GetResolvedLocale(),tostring(self.achievementRevision),tostring(self.journalFoodEffectRevision),tostring(mapID),tostring(zone),tostring(self.db.campMilestones),
        tostring(math.floor((GetServerTime and GetServerTime() or time())/3600))},"/")
    revision=revision.."/"..tostring(self.nativeJournalNameRevision or 0)
    if self.journalSearchIndex and self.journalSearchIndexRevision == revision then return self.journalSearchIndex end
    local items, seen = {}, {}
    local function Add(key,label,context,content,destination,views,icon,map,locationTerms)
        if seen[key] then return seen[key] end
        local displayLabel,displayContext,terms=self:GetJournalSearchDisplay(key,label,context,destination)
        displayContext=self:LocalizeJournalReferenceText(displayContext)
        local native=self:GetNativeGuideTargetName(destination,label)
        local clientName=self:GetClientGuideTargetName(destination,label)
        if displayLabel==label then displayLabel=self:LocalizeJournalReferenceText(native) end
        local item = {key=key,label=Plain(displayLabel),context=displayContext,destination=destination,views=views,
            icon=icon or ICONS.guide,map=Verified(map) and map or nil}
        item.name = self:FoldSearchText(item.label)
        local searchable = Flatten(content,faction)
        item.text = self:FoldSearchText(item.label.." "..(displayContext or "").." "..searchable)
        if self:GetResolvedLocale()~="enUS" or native~=label or clientName~=label then
            item.text=item.text.." "..self:FoldSearchText(Plain(label).." "..(context or "").." "..(terms or "").." "..self:LocalizeJournalReferenceText(searchable).." "..clientName)
        end
        if locationTerms and locationTerms:match("%S") then
            item.text = item.text.." "..self:FoldSearchText(locationTerms)
        end
        seen[key],items[#items+1] = item,item
        return item
    end
    local catalogue,catchByID = self:GetSessionGoalCatalogue()
    for _, catch in ipairs(catalogue) do
        local record = self.db.journal[catch.id] or self.db.journal[tostring(catch.id)]
        local views = {catch=true}
        for place in pairs(record and record.locations or {}) do
            if self:FishingLocationMatchesZone(place,zone) then views.nearby = true end
        end
        Add("catch:"..catch.id,catch.name,"Catch Journal",{catch.context,record,self:GetJournalCatchFoodSearchText(catch.id),self:GetResolvedLocale()~="enUS" and {self:GetJournalCatchUseSearchText(catch.id),self:GetJournalCatchReferenceSearchText(self:GetJournalCatchDefinition(catch.id),faction)}},
            {kind="fish",id=catch.id},views,self:GetJournalItemIcon(catch.id),nil,self:GetFishingLocationSearchText(record and record.locations))
    end
    for _,entry in ipairs(self.journalCatchReferences or {}) do
        Add("catch:"..entry[1],entry[2],"Catch Journal",{entry[3],self:GetJournalCatchFoodSearchText(entry[1]),self:GetResolvedLocale()~="enUS" and {self:GetJournalCatchUseSearchText(entry[1]),self:GetJournalCatchReferenceSearchText(entry,faction)}},{kind="fish",id=entry[1]},
            {catch=true},self:GetJournalItemIcon(entry[1]))
    end
    for _,group in ipairs(self:BuildNearbyData().groups) do
        for _,entry in ipairs(group.items) do
            if seen["catch:"..entry[1]] then seen["catch:"..entry[1]].views.nearby=true end
        end
    end
    for _, tab in ipairs(self.guideTabs or {}) do
        if tab.blocks then
            for index,block in ipairs(tab.blocks) do
                local fishingRoute = tab.id == "leveling"
                local label = fishingRoute and self:GetFishingReferenceText("route",block,"heading",faction) or tab.id=="rares" and self:GetRareGuideDisplayText(block,"heading") or tab.id=="gear" and self:GetGearOverviewText(block,"heading") or block.heading
                local translated = self:GetResolvedLocale()~="enUS" and (fishingRoute and self:GetFishingRouteSearchText(block,faction) or tab.id=="rares" and self:GetRareGuideSearchText(block) or tab.id=="gear" and self:GetGearOverviewSearchText(block,faction))
                Add("guide:"..tab.id..":"..index,label,tab.title,block.items and {self:GetJournalGearReferenceText(block,faction),self:GetResolvedLocale()~="enUS" and {self:GetJournalGearQuestSearchText(block,faction),translated,self:GetGearDetailSearchText(block,faction)}} or {block,translated},
                    {kind="guide",tab=tab.id,heading=block.heading},{[tab.id]=true})
                for _,entry in ipairs(block.items and self:GetJournalGearReferences(block,faction) or {}) do
                    Add("gear:"..entry.key,entry.name,"Gear & Skill • "..block.heading,{entry,self:UsesJournalDisplayNames() and self:GetJournalItemDisplayName(entry.id,entry.name),self:GetResolvedLocale()~="enUS" and {self:GetJournalGearQuestEntrySearchText(entry),self:GetGearReferenceSearchText(entry),self:GetGearDetailDisplayText(entry,faction)}},
                        {kind="guide",tab="gear",heading=block.heading,itemKey=entry.key},{gear=true},entry.id and self:GetJournalItemIcon(entry.id) or entry.icon)
                end
            end
        elseif tab.id == "nearby" then
            local displayZone = self:GetZoneDisplayName(zone)
            Add("page:nearby",self:LocalizedText("journal.guide.nearby.label"),"Field Guide",{zone,"Recipe sellers recorded catches locations",
                self:GetResolvedLocale()~="enUS" and {self:LocalizedText("nearby.heading.conditions"),self:LocalizedText("nearby.heading.gallery"),self:LocalizedText("nearby.heading.supplies"),self:LocalizedText("nearby.tools"),
                self:GetNearbyRoleDisplayText({["Fishing trainer"]=true,["Fishing book"]=true,["Artisan quest"]=true,
                    ["Fishing pole quest"]=true,["Recipes"]=true,["Fishing supplies"]=true}),self:LocalizedText("nearby.service.fishing-ranks"),self:LocalizedText("nearby.records.title"),self:LocalizedText("nearby.family.heading")}},
                {kind="page",tab="nearby"},{nearby=true},nil,nil,displayZone ~= zone and displayZone or nil)
            for _, entry in ipairs(self:GetNearbyZones()) do
                local display = self:GetZoneDisplayName(entry.name)
                Add("zone:"..entry.name,display,self:LocalizedText("journal.guide.nearby.label"),
                    {entry.name,self:GetCanonicalZoneName(entry.name)~=entry.name and self:GetCanonicalZoneName(entry.name) or nil},
                    {kind="zone",name=entry.name},{nearby=true})
            end
        end
    end
    if self.db.campMilestones ~= false then
        for index,block in ipairs(self.masterChefCampMilestones or {}) do
            local translated = self:GetResolvedLocale()~="enUS" and self:GetFishingReferenceText("milestone",block,"body",faction)
            Add("milestone:"..index,self:GetFishingReferenceText("milestone",block,"heading",faction),"Fishing 1–300",{block,translated},
                {kind="guide",tab="leveling",heading=block.heading},{leveling=true})
        end
    end
    for _,stage in ipairs(self.masterChefRoute or {}) do
        local sources = {}
        for _, source in ipairs(self:GetMasterChefRouteSourceRows(stage, faction)) do
            sources[#sources+1] = source.label
            for _, point in ipairs(source.points) do sources[#sources+1] = point.label end
        end
        local translated = self:GetResolvedLocale()~="enUS" and {
            self:GetMasterChefReferenceText("route",stage,"fish",faction),self:GetMasterChefReferenceText("route",stage,"recipe",faction),
            self:GetMasterChefReferenceText("route",stage,string.lower(faction),faction) }
        Add("cooking:"..stage.heading,self:GetMasterChefReferenceText("route",stage,"heading",faction),"Cooking guide",{stage.fish,stage.recipe,stage[string.lower(faction)],translated,sources},
            {kind="guide",tab="chef",chef="guide",heading=stage.heading},{["chef:guide"]=true})
    end
    for _,meal in ipairs(self.masterChefMeals or {}) do
        Add("meal:"..meal.id,meal.name,"Master Chef • Grilling",{meal,self:GetJournalFoodDisplayEffects(meal.id).search,self:GetResolvedLocale()~="enUS" and {self:GetMasterChefReferenceText("meal",meal,"extra"),self:GetMasterChefReferenceText("meal",meal,"recipe",faction),self:GetMasterChefReferenceText("meal",meal,"waters",faction)}},
            {kind="meal",id=meal.id},{["chef:meals"]=true},self:GetJournalItemIcon(meal.id))
        for _,point in ipairs(self:GetMealRecipeMapPoints(meal.id,faction) or {}) do
            if Verified(point) then
                local key = "seller:"..point.mapID..":"..point.name
                local row = Add(key,point.name,"Recipe seller • "..(point.label or point.name),{point.label,meal.name,meal.recipe,self:GetResolvedLocale()~="enUS" and self:GetMasterChefReferenceText("meal",meal,"recipe",faction)},
                    {kind="seller",id=meal.id},{["chef:meals"]=true},ICONS.seller,point)
                row.text = row.text.." "..self:FoldSearchText(meal.name)
            end
        end
    end
    local nearby = self:GetNearbyRecipeVendors(mapID,faction)
    for _,point in ipairs(nearby) do
        local key = "seller:"..point.mapID..":"..point.name
        if seen[key] then seen[key].views.nearby = true end
    end
    for _,camp in ipairs(self:GetMasterChefCampEntries() or {}) do
        local effect=self:GetJournalFoodDisplayEffects(camp.id)
        Add("camp:"..camp.id,camp.name,"Master Chef • Campfire",{camp,self.masterChefCampEffects and self.masterChefCampEffects[camp.id],effect and effect.search,self:GetResolvedLocale()~="enUS" and {self:GetMasterChefReferenceText("camp",camp,"benefit"),self:GetMasterChefReferenceText("camp",camp,"source")}},
            {kind="camp",id=camp.id},{["chef:campfire"]=true,["chef:meals"]=camp.basic == true},self:GetJournalItemIcon(camp.id))
    end
    for _,definition in ipairs(self.achievementDefinitions or {}) do
        Add("achievement:"..definition.id,self:GetAchievementDisplayText(definition,"title"),self:LocalizedText("achievement.search-context"),{definition,self:GetResolvedLocale()~="enUS" and {self:GetAchievementSearchText(definition),definition.metric=="recipes" and self:GetAchievementRecipeDetail()}},
            {kind="achievement",id=definition.id},{achievements=true},ICONS.achievement)
    end
    for index,entry in ipairs(self.db.sessionHistory and self.db.sessionHistory[owner] or {}) do
        if self:SessionHasConfirmedCatches(entry) then
            local content = {entry}
            local locations = {self:GetFishingLocationSearchText(entry.locations)}
            for id, saved in pairs(entry.records or {}) do
                locations[#locations+1] = self:GetFishingLocationSearchText(type(saved) == "table" and saved.locations or nil)
                local record = self.db.journal[id] or self.db.journal[tostring(id)]
                content[#content+1] = record and record.name or (GetItemInfo and GetItemInfo(id)) or "Item "..id
                if catchByID[tonumber(id)] then content[#content+1]=catchByID[tonumber(id)].name end
            end
            local label = type(entry.endedAt) == "number" and date("%d %b %Y • %H:%M",entry.endedAt) or self:LocalizedText("journal.saved-session")
            if self:GetResolvedLocale() ~= "enUS" and type(entry.endedAt) == "number" then
                content[#content+1] = label -- Retain the native/canonical date alias.
                label = self:FormatTimestampDisplay(entry.endedAt,"history")
            end
            Add("history:"..index,label,"Session History • "..entry.catches.." catches",content,
                {kind="history",entry=entry},{["session:history"]=true},ICONS.history,nil,table.concat(locations," "))
        end
    end
    for _,event in ipairs(self:GetUpcomingFishingEvents() or {}) do
        -- Canonical definitions carry guidance even when their rows are collapsed.
        Add("event:"..tostring(event.id or event.name),event.name or self:GetFishingEventDisplayText(event,"title"),self:LocalizedText("events.search.upcoming"),{event,self:GetResolvedLocale()~="enUS" and {self:GetFishingEventSearchText(event),self:GetFishingEventTimeDisplay(event)}},
            {kind="event",id=event.id},{events=true},ICONS.guide)
    end
    Add("page:session","Session stats","Current fishing session","Rod time Casts Catches Success rate Catches per hour Average cast to first loot Vendor Auction estimates End Reset History Goals",
        {kind="page",tab="session"},{session=true},ICONS.history)
    Add("page:lifetime","Lifetime stats","All recorded fishing","Time fishing Casts Catch count Success rate Catches per hour Average cast to loot Sessions Unique catches Vendor Auction estimates",
        {kind="page",tab="lifetime"},{lifetime=true},ICONS.history)
    Add("page:events",self:LocalizedText("journal.events-tab"),self:LocalizedText("events.search.calendar"),self:LocalizedText("events.search.help"),
        {kind="page",tab="events"},{events=true},ICONS.guide)
    self.journalSearchIndex,self.journalSearchIndexRevision = items,revision
    self.journalSearchBuilds = (self.journalSearchBuilds or 0)+1
    return items
end

function FF:SearchJournal(query,scope)
    query = self:NormalizeJournalFoodSearch(self:FoldSearchText(Plain(query)):match("^%s*(.-)%s*$"))
    if query == "" then return {} end
    local results = {}
    local tokens = {}; for token in query:gmatch("%S+") do tokens[#tokens+1] = token end
    for _,item in ipairs(self:GetJournalSearchIndex()) do
        if not scope or item.views[scope] then
            local matches = true
            for _,token in ipairs(tokens) do if not item.text:find(token,1,true) then matches=false; break end end
            if matches then
                local score = item.name == query and 0 or item.name:sub(1,#query) == query and 1 or item.name:find(query,1,true) and 2 or 3
                results[#results+1]={item=item,score=score}
            end
        end
    end
    table.sort(results,function(a,b) return a.score < b.score or a.score == b.score and (a.item.name < b.item.name or a.item.name == b.item.name and a.item.key < b.item.key) end)
    local items = {}; for _,result in ipairs(results) do items[#items+1]=result.item end
    return items
end

function FF:GetJournalSearchState()
    local panel = self.journalPanel
    if not panel or not panel.searchInput then return end
    return {query=panel.searchInput:GetText() or "",current=panel.searchCurrent:GetChecked() == true,scope=panel.searchOriginView}
end
function FF:RestoreJournalSearchState(state)
    local panel = self.journalPanel
    if not panel or not panel.searchInput then return end
    panel.restoringSearch = true
    panel.searchOriginView = state and state.scope
    panel.searchCurrent:SetChecked(state and state.current or false)
    panel.searchInput:SetText(state and state.query or "")
    panel.restoringSearch = nil
    if state and state.query ~= "" then self:RefreshJournalSearchResults() else self:DismissJournalSearch(false) end
end
function FF:DismissJournalSearch(clear)
    local panel = self.journalPanel
    if not panel or not panel.searchInput then return end
    panel.searchDropdown:Hide(); panel.searchInput:ClearFocus()
    if clear then
        panel.searchOriginView=nil; panel.searchInput:SetText("")
    end
end
local function ScrollTo(panel,row)
    if not row then return end
    if panel.scroll.UpdateScrollChildRect then panel.scroll:UpdateScrollChildRect() end
    panel.scroll:SetVerticalScroll(math.min(row.contentY or 0,panel.scroll:GetVerticalScrollRange()))
end
function FF:OpenJournalSearchResult(item,mapAction)
    if not item or (InCombatLockdown and InCombatLockdown()) or (self.IsCameraSearchPending and self:IsCameraSearchPending()) then return end
    local panel = self.journalPanel
    local d = item.destination
    if mapAction and item.map then
        self:RememberJournalPage(); self:DismissJournalSearch(false); self:OpenGuideMapPoint(item.map); return
    end
    if self.BringFishingWindowForward then self:BringFishingWindowForward(panel) end
    self:DismissJournalSearch(false)
    if d.kind == "fish" then self:OpenGuideCatch(d.id)
    elseif d.kind == "meal" or d.kind == "seller" then
        self:OpenGuideMeal(d.id)
        if d.kind == "seller" then panel.expandedRecipeVendorMeal=d.id; self:RenderMasterChefMeals() end
    elseif d.kind == "camp" then
        self:OpenGuideCamp(d.id); panel.expandedCamp=d.id; self:RenderMasterChefCampfire()
        ScrollTo(panel,panel.campRows and panel.campRows[d.id])
    else
        self:RememberJournalPage()
        if d.kind == "zone" then
            self:SetNearbyZone(d.name)
        elseif d.kind == "achievement" then
            panel.expandedAchievements=panel.expandedAchievements or {}; panel.expandedAchievements[d.id]=true
            panel.focusedAchievement=d.id; self:SelectJournalTab("achievements")
            ScrollTo(panel,panel.achievementRows[self.achievementsByID[d.id].order])
        elseif d.kind == "history" then
            panel.sessionHistoryShown=true; panel.expandedHistoryEntry=d.entry; self:SelectJournalTab("session")
            for _,row in ipairs(panel.historyCards or {}) do if row.entry == d.entry then ScrollTo(panel,row); break end end
        elseif d.kind == "guide" then
            panel.chefView = d.chef or panel.chefView
            self:ExpandJournalGuideHeading(d.tab,d.heading)
            if d.tab=="gear" and d.itemKey then self:ExpandJournalGearReference(d.heading,nil,d.itemKey) end
            self:SelectJournalTab(d.tab)
            if d.tab=="gear" and d.itemKey then
                for _,card in ipairs(panel.guideCards or {}) do for _,row in ipairs(card.gearItems or {}) do
                    if row:IsShown() and row.reference.key==d.itemKey then ScrollTo(panel,row); return end
                end end
            end
            for _,row in ipairs(panel.guideCards or {}) do if row.blockKey == (d.tab == "chef" and "cooking" or d.tab)..":"..d.heading
                or row:IsShown() and row.guideHeadings and row.guideHeadings[d.heading] then ScrollTo(panel,row); break end end
        elseif d.kind == "event" then
            panel.expandedEvent=d.id; self:SelectJournalTab("events")
            for _,row in ipairs(panel.eventRows or {}) do if row.event and row.event.id == d.id then ScrollTo(panel,row); break end end
        else
            if d.tab == "session" then panel.sessionHistoryShown=false end
            self:SelectJournalTab(d.tab)
        end
    end
end

local function Label(parent,template,x,y,text)
    local label = parent:CreateFontString(nil,"OVERLAY",template)
    label:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y); label:SetText(text or ""); label:SetJustifyH("LEFT")
    return label
end
function FF:RefreshJournalSearchResults()
    local panel = self.journalPanel
    if not panel or not panel.searchInput or panel.restoringSearch then return end
    if (InCombatLockdown and InCombatLockdown()) or (self.IsCameraSearchPending and self:IsCameraSearchPending()) then self:DismissJournalSearch(false); return end
    local query = panel.searchInput:GetText() or ""
    if query:match("^%s*$") then panel.searchDropdown:Hide(); panel.searchOriginView=nil; return end
    panel.searchOriginView = panel.searchOriginView or self:GetJournalSearchView()
    local scope = panel.searchCurrent:GetChecked() and panel.searchOriginView or nil
    local results = self:SearchJournal(query,scope)
    local drop = panel.searchDropdown
    drop.caption:SetText(FF:LocalizedPlural(scope and "journal.search-current" or "journal.search-whole",#results,#results))
    drop.empty:SetShown(#results == 0); drop.empty:SetText(FF:LocalizedText("journal.search-empty"))
    local width = drop:GetWidth()-38
    local y,scale = 0,self:GetJournalTextScale()
    for index,item in ipairs(results) do
        local row = drop.rows[index]
        if not row then
            row=CreateFrame("Button",nil,drop.content); row:RegisterForClicks("LeftButtonUp")
            row:EnableMouseWheel(true)
            row:SetScript("OnMouseWheel",function(_,delta) drop.scroll:SetVerticalScroll(math.max(0,math.min(drop.scroll:GetVerticalScrollRange(),drop.scroll:GetVerticalScroll()-delta*56))) end)
            row.icon=row:CreateTexture(nil,"ARTWORK"); row.icon:SetSize(26,26); row.icon:SetPoint("LEFT",row,"LEFT",2,0)
            row.name=Label(row,"GameFontNormalSmall",36,-6,""); row.name:SetWordWrap(true)
            row.context=Label(row,"GameFontHighlightSmall",36,-24,""); row.context:SetWordWrap(true)
            row.map=CreateFrame("Button",nil,row); row.map:SetSize(24,30); row.map:SetPoint("RIGHT",row,"RIGHT",-2,0)
            local pin=row.map:CreateTexture(nil,"ARTWORK"); pin:SetAllPoints(row.map); pin:SetTexture(self.journalAssets.U01)
            row.map:SetScript("OnClick",function() FF:OpenJournalSearchResult(row.result,true) end)
            row.map:SetScript("OnEnter",function(button) GameTooltip:SetOwner(button,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("journal.search-map")); GameTooltip:Show() end)
            row.map:SetScript("OnLeave",function() GameTooltip:Hide() end)
            row:SetScript("OnClick",function() FF:OpenJournalSearchResult(row.result) end)
            drop.rows[index]=row
        end
        row.result=item; row.icon:SetTexture(item.icon); row:SetWidth(width)
        local fish=item.destination.kind=="fish"
        if fish then
            self:RoundJournalItemIcon(row.icon)
            local layout=self:FrameJournalItemIcon(row,row.icon,item.destination.id,20,false)
            row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT",row,"LEFT",12,layout.centerY)
        else
            row.icon:SetSize(26,26); row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT",row,"LEFT",2,0)
            self:ClearJournalItemIconFrame(row,row.icon)
        end
        row:SetScript("OnEnter",function(button)
            if button.result.destination.kind=="fish" then
                FF:ShowJournalCatchTooltip(button,button.result.destination.id,FF:LocalizedText("journal.chrome.search.open-catch"))
            end
        end)
        row:SetScript("OnLeave",function(button) FF:HideJournalItemTooltip(button) end)
        local textX=fish and 46 or 36
        row.name:ClearAllPoints(); row.name:SetPoint("TOPLEFT",row,"TOPLEFT",textX,-6)
        row.name:SetWidth(width-textX-34); row.context:SetWidth(width-textX-34)
        local font,_,flags=row.name:GetFont(); FF:SetDisplayFont(row.name, font,13*scale,flags)
        font,_,flags=row.context:GetFont(); FF:SetDisplayFont(row.context, font,11*scale,flags)
        row.name:SetText(item.label); row.context:SetText(item.context)
        row.context:ClearAllPoints(); row.context:SetPoint("TOPLEFT",row,"TOPLEFT",textX,-10-row.name:GetStringHeight())
        local iconHeight=fish and FF:GetJournalCatchIconLayout(item.destination.id,20).height+16 or 48
        row:SetHeight(math.max(48,iconHeight,18+row.name:GetStringHeight()+row.context:GetStringHeight()))
        row:ClearAllPoints(); row:SetPoint("TOPLEFT",drop.content,"TOPLEFT",0,-y)
        y=y+row:GetHeight()
        row.map:SetShown(item.map ~= nil); row:Show()
    end
    for index=#results+1,#drop.rows do drop.rows[index]:Hide() end
    drop.content:SetHeight(math.max(1,y))
    drop:SetHeight(math.min(math.max(90,38+y),math.min(350,math.max(100,panel:GetHeight()-85))))
    drop.scroll:SetVerticalScroll(0); drop:Show()
end
function FF:LayoutJournalSearch(panel)
    if not panel.searchInput then return end
    local compact = panel.compactChef
    panel.searchControls:SetShown(not compact)
    if compact then panel.searchDropdown:Hide(); return end
    local scale=self:GetJournalTextScale()
    local label=panel.searchCurrentLabel
    local labelFont,_,labelFlags=label:GetFont()
    FF:SetDisplayFont(label, labelFont,12*scale,labelFlags)
    label:SetWidth(0); label:SetWordWrap(false)
    local labelWidth=(label.GetStringWidth and label:GetStringWidth() or #label:GetText()*7*scale)+2
    label:SetWidth(labelWidth)
    local reserved=32+labelWidth
    local width=math.max(110,math.min(215,panel:GetWidth()*0.23))
    panel.searchInput:SetWidth(width)
    panel.searchInput:ClearAllPoints(); panel.searchInput:SetPoint("RIGHT",panel.searchControls,"RIGHT",-reserved,0)
    panel.searchControls:SetSize(width+reserved,24)
    -- Shift the whole group right/down, stopping above the unchanged divider.
    local top=math.min(45,panel.fullHeader:GetHeight()-panel.searchControls:GetHeight()-2)
    panel.searchControls:ClearAllPoints(); panel.searchControls:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-12,-top)
    panel.searchDropdown:SetWidth(math.min(410,panel:GetWidth()-215))
    panel.searchDropdown.content:SetWidth(panel.searchDropdown:GetWidth()-38)
    local textWidth=math.max(1,panel:GetWidth()-panel.searchControls:GetWidth()-127)
    panel.headerTitle:SetWidth(0); panel.headerTitle:SetWordWrap(false)
    panel.headerTitle:SetText(FF:LocalizedText("journal.header"))
    local font,_,flags=panel.headerTitle:GetFont()
    local titleSize=(panel:GetWidth()>=770 and 26 or panel:GetWidth()>=710 and 24 or 22)*scale
    FF:SetDisplayFont(panel.headerTitle, font,titleSize,flags)
    -- Fit the complete larger title into its own fixed column, independently
    -- of Back visibility. Measuring text adds no input or idle update owner.
    if panel.headerTitle.GetStringWidth then
        local measured=panel.headerTitle:GetStringWidth()
        if measured>textWidth then
            if self:GetResolvedLocale()=="enUS" then
                -- Retain the established English header fit.
                FF:SetDisplayFont(panel.headerTitle, font,titleSize*textWidth/measured,flags)
            else
                -- Translated chrome has an authored compact title; do not make
                -- other scripts unreadable by shrinking them into this column.
                panel.headerTitle:SetText(self:LocalizedText("journal.header-short"))
            end
        end
    end
    panel.headerTitle:SetWidth(textWidth)
    panel.backButton:ClearAllPoints(); panel.backButton:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-42,-14)
    panel.backButton:SetSize(112,24)
end
function FF:CreateJournalSearch(panel)
    local controls=CreateFrame("Frame",nil,panel)
    controls:SetSize(340,30); controls:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-42,-12)
    controls:SetFrameLevel(panel:GetFrameLevel()+6)
    panel.searchControls=controls
    local edit=self:CreateJournalEditBox(controls,170,FF:LocalizedText("journal.search-placeholder"))
    edit:SetPoint("RIGHT",controls,"RIGHT",-118,0); panel.searchInput=edit
    if edit.SetTextInsets then edit:SetTextInsets(3,21,0,0) end
    local clear=CreateFrame("Button",nil,controls); clear:SetSize(20,22); clear:SetPoint("RIGHT",edit,"RIGHT",0,0)
    clear:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    clear:SetScript("OnClick",function() FF:DismissJournalSearch(true) end)
    local current=CreateFrame("CheckButton",nil,controls,"UICheckButtonTemplate")
    current:SetSize(24,24); current:SetPoint("RIGHT",edit,"RIGHT",30,0); current:SetChecked(false)
    local label=Label(current,"GameFontHighlightSmall",25,-6,FF:LocalizedText("journal.search-current"))
    label:SetTextColor(panel.headerTitle:GetTextColor())
    label:ClearAllPoints(); label:SetPoint("LEFT",current,"RIGHT",2,0)
    panel.searchCurrentLabel=label
    panel.searchCurrent=current
    current:SetScript("OnClick",function() FF:RefreshJournalSearchResults() end)
    local drop=CreateFrame("Frame",nil,panel)
    drop:SetSize(370,240); drop:SetPoint("TOPRIGHT",controls,"BOTTOMRIGHT",0,-9)
    drop:SetFrameLevel(panel:GetFrameLevel()+20); drop:EnableMouse(true)
    local fill=drop:CreateTexture(nil,"BACKGROUND"); fill:SetAllPoints(drop); fill:SetColorTexture(0.09,0.19,0.23,0.99)
    drop.border=self:CreateJournalFrame(drop)
    drop.caption=Label(drop,"GameFontNormalSmall",12,-12,"")
    drop.empty=Label(drop,"GameFontHighlightSmall",12,-44,"")
    drop.scroll=CreateFrame("ScrollFrame",nil,drop,"UIPanelScrollFrameTemplate")
    drop.scroll:SetPoint("TOPLEFT",drop,"TOPLEFT",10,-33); drop.scroll:SetPoint("BOTTOMRIGHT",drop,"BOTTOMRIGHT",-27,9)
    drop.content=CreateFrame("Frame",nil,drop.scroll); drop.content:SetSize(340,1); drop.scroll:SetScrollChild(drop.content)
    drop.scroll:EnableMouseWheel(true); drop.scroll:SetScript("OnMouseWheel",function(_,delta) drop.scroll:SetVerticalScroll(math.max(0,math.min(drop.scroll:GetVerticalScrollRange(),drop.scroll:GetVerticalScroll()-delta*56))) end)
    drop.rows={}; panel.searchDropdown=drop; drop:Hide()
    edit:HookScript("OnTextChanged",function() FF:RefreshJournalSearchResults() end)
    edit:HookScript("OnEditFocusGained",function() panel.searchOriginView=panel.searchOriginView or FF:GetJournalSearchView(); FF:RefreshJournalSearchResults() end)
    edit:SetScript("OnEscapePressed",function() FF:DismissJournalSearch(false) end)
    edit:SetScript("OnEnterPressed",function() if drop.rows[1] and drop.rows[1]:IsShown() then FF:OpenJournalSearchResult(drop.rows[1].result) end; edit:ClearFocus() end)
    panel:HookScript("OnHide",function() FF:DismissJournalSearch(true); current:SetChecked(false) end)
    self:LayoutJournalSearch(panel)
end
