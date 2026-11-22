-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local INK, SOFT = { .23,.14,.075 }, { .31,.21,.12 }

local function Font(font, size)
    local path=font:GetFont()
    FF:SetDisplayFont(font, path,size*FF:GetJournalTextScale(),"")
    font:SetShadowColor(0,0,0,0); font:SetShadowOffset(0,0)
end
local function Distance(point)
    return point.distance and FF:LocalizedText("journal.link.distance" ,math.floor(math.sqrt(point.distance)+.5)) or "?"
end
function FF:GetSelectedJournalRouteSource(key,rank)
    local panel=self.journalPanel
    local points=panel and panel.routeTrainingSources and panel.routeTrainingSources[rank] or {}
    return points[1],1
end
function FF:CloseJournalRoutePicker()
    local p=self.journalPanel
    if p and p.routePicker then p.routePicker:Hide() end
end

-- All inputs are Journal-local UI units, with Y increasing downward.
function FF:GetJournalRoutePickerPlacement(width,height,x,y,anchorHeight,wantedWidth,wantedHeight)
    local margin,gap=6,4
    local w=math.max(1,math.min(wantedWidth,width-margin*2))
    local below=math.max(1,height-y-anchorHeight-gap-margin)
    local above=math.max(1,y-gap-margin)
    local up=below<math.min(wantedHeight,180) and above>below
    local h=math.max(1,math.min(wantedHeight,264,up and above or below,height-margin*2))
    local left=math.max(margin,math.min(width-w-margin,x))
    local top=up and y-gap-h or y+anchorHeight+gap
    top=math.max(margin,math.min(height-h-margin,top))
    return left,top,w,h,up
end

local function Picker(panel,paper)
    if panel.routePicker then return panel.routePicker end
    local menu=CreateFrame("Frame","ForeverFishingJournalRoutePicker",panel)
    menu:SetFrameLevel(panel:GetFrameLevel()+100); menu:EnableMouse(true)
    local fill=menu:CreateTexture(nil,"BACKGROUND"); fill:SetAllPoints(menu)
    fill:SetColorTexture(.83,.71,.51,1); menu.fill=fill
    menu.paper=paper and paper(menu)
    menu.border=FF:CreateJournalFrame(menu)
    menu.scroll=CreateFrame("ScrollFrame",nil,menu)
    menu.scroll:SetPoint("TOPLEFT",menu,"TOPLEFT",8,-8)
    menu.scroll:SetPoint("BOTTOMRIGHT",menu,"BOTTOMRIGHT",-8,8)
    menu.content=CreateFrame("Frame",nil,menu.scroll); menu.scroll:SetScrollChild(menu.content)
    menu.rows={}
    menu.catchRows={}
    local function Wheel(_,delta)
        local s=menu.scroll
        s:SetVerticalScroll(math.max(0,math.min(s:GetVerticalScrollRange(),s:GetVerticalScroll()-delta*40)))
    end
    menu:EnableMouseWheel(true); menu:SetScript("OnMouseWheel",Wheel)
    menu.scroll:EnableMouseWheel(true); menu.scroll:SetScript("OnMouseWheel",Wheel)
    menu.Wheel=Wheel
    menu:SetScript("OnEvent",function(_,event)
        if event~="GLOBAL_MOUSE_DOWN" or not (menu:IsMouseOver() or menu.owner and menu.owner:IsMouseOver()) then menu:Hide() end
    end)
    menu:SetScript("OnKeyDown",function(_,key)
        if InCombatLockdown and InCombatLockdown() then menu:Hide(); return end
        menu:SetPropagateKeyboardInput(key~="ESCAPE")
        if key=="ESCAPE" then menu:Hide() end
    end)
    menu:SetScript("OnShow",function()
        menu:EnableKeyboard(true); menu:SetPropagateKeyboardInput(true)
        menu:RegisterEvent("GLOBAL_MOUSE_DOWN"); menu:RegisterEvent("PLAYER_REGEN_DISABLED")
        menu:RegisterEvent("PLAYER_LEAVING_WORLD")
    end)
    menu:SetScript("OnHide",function()
        menu:UnregisterAllEvents(); menu:EnableKeyboard(false)
        if menu.owner then
            menu.owner.icon:SetTexCoord(0,1,1,0)
            menu.owner=nil
        end
        GameTooltip:Hide()
    end)
    panel:HookScript("OnHide",function() menu:Hide() end)
    panel.scroll:HookScript("OnVerticalScroll",function() menu:Hide() end)
    panel.routePicker=menu; menu:Hide()
    return menu
end

-- Route and Nearby menus share inner parchment and a thin bronze rim.
-- Legacy outer slices and the old frame remain hidden on every open.
local function RouteMenuSkin(menu,route)
    menu.border:SetShown(not route)
    if menu.paper then for _,texture in pairs(menu.paper) do texture:SetShown(not route) end end
    if route and not menu.routeBorder then
        menu.routeBorder=FF:CreateJournalFrame(menu,false,6)
        local info=C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("QuestBG-Parchment")
        if info and info.width and info.height and info.width>80 and info.height>80 then
            local t=menu:CreateTexture(nil,"BACKGROUND",nil,1)
            if info.file or info.filename then t:SetTexture(info.file or info.filename) else t:SetAtlas("QuestBG-Parchment") end
            local du=(info.rightTexCoord-info.leftTexCoord)/info.width
            local dv=(info.bottomTexCoord-info.topTexCoord)/info.height
            t:SetTexCoord(info.leftTexCoord+36*du,info.rightTexCoord-36*du,
                info.topTexCoord+36*dv,info.bottomTexCoord-36*dv)
            t:SetVertexColor(1,.94,.83,1)
            t:SetPoint("TOPLEFT",menu,"TOPLEFT",1,-1); t:SetPoint("BOTTOMRIGHT",menu,"BOTTOMRIGHT",-1,1)
            menu.routePaper=t
        end
    end
    if menu.routeBorder then menu.routeBorder:SetShown(route) end
    if menu.routePaper then menu.routePaper:SetShown(route) end
end

function FF:GetJournalRouteMenuWidth(pageWidth,contentWidth)
    return math.max(1,math.min(pageWidth-12,288,math.max(180,(contentWidth or 0)+16)))
end

function FF:OpenJournalRoutePicker(button)
    local panel=self.journalPanel
    local nearby=button and button.target and button.target.rank:sub(1,7)=="Nearby:" and self.journalTab=="nearby"
    local gear=button and button.target and button.target.rank:sub(1,5)=="Gear:" and self.journalTab=="gear"
    local cooking=button and button.target and button.target.rank:sub(1,5)=="Chef:"
        and self.journalTab=="chef" and panel and panel.chefView=="guide"
    if not panel or not button or not button:IsVisible() or (self.journalTab~="leveling" and not nearby and not gear and not cooking)
        or InCombatLockdown and InCombatLockdown()
        or self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
    if self.DismissJournalSearch then self:DismissJournalSearch(false) end
    local menu=Picker(panel,button.paper)
    if menu:IsShown() and menu.owner==button then menu:Hide(); return end
    menu:Hide(); RouteMenuSkin(menu,true)
    if panel.nearbyZoneControls then panel.nearbyZoneControls.menu:Hide() end
    for _,row in ipairs(menu.catchRows) do row:Hide() end
    -- Reuse the verified provider and ordering, refreshing distance only on open.
    local rank=button.target.rank
    local points=cooking and self:GetCookingRouteSources(rank,self:GetJournalFaction())
        or gear and self:GetJournalGearSources(panel.gearSourceEntries[rank],self:GetJournalFaction())
        or nearby and panel.routeTrainingSources[rank] or rank=="Supplier" and self:GetFishingPoleSources(self:GetJournalFaction())
        or self:GetFishingTrainingSources(rank,self:GetJournalFaction())
    if nearby then
        for _,point in ipairs(points) do point.distance=nil end
        self:GetOrderedGuideMapPoints(points,true)
    end
    if #points<2 then return end
    panel.routeTrainingSources[rank]=points
    local page=panel.page
    local pageWidth,pageHeight=page:GetWidth(),page:GetHeight()
    if pageWidth<=0 then pageWidth=panel:GetWidth()-180 end
    if pageHeight<=0 then pageHeight=panel:GetHeight()-100 end
    local pageLeft,pageTop=page:GetLeft() or 0,page:GetTop() or pageHeight
    local anchor=button.anchor
    local x=(anchor:GetLeft() or pageLeft+12)-pageLeft
    local y=pageTop-(anchor:GetTop() or pageTop-20)
    local anchorHeight=anchor:GetHeight()
    if not menu.measure then menu.measure=menu:CreateFontString(nil,"OVERLAY","GameFontNormal"); menu.measure:Hide() end
    local contentWidth=0
    for _,point in ipairs(points) do
        Font(menu.measure,13); menu.measure:SetText(self:GetJournalNPCDisplayName(point.name)); local nameWidth=menu.measure:GetStringWidth()
        Font(menu.measure,12); menu.measure:SetText(Distance(point)); local distanceWidth=menu.measure:GetStringWidth()
        menu.measure:SetText(self:GetJournalSourceLocationText(point))
        contentWidth=math.max(contentWidth,nameWidth+distanceWidth+18,math.min(256,menu.measure:GetStringWidth()+10))
    end
    local width=self:GetJournalRouteMenuWidth(pageWidth,contentWidth)
    local rowWidth=width-16
    local total=0
    for index,point in ipairs(points) do
        local row=menu.rows[index]
        if not row then
            row=CreateFrame("Button",nil,menu.content); row:RegisterForClicks("LeftButtonUp")
            row.bg=row:CreateTexture(nil,"BACKGROUND"); row.bg:SetAllPoints(row)
            local hi=row:CreateTexture(nil,"HIGHLIGHT"); hi:SetAllPoints(row); hi:SetColorTexture(.48,.30,.13,.14)
            row.name=row:CreateFontString(nil,"OVERLAY","GameFontNormal")
            row.name:SetJustifyH("LEFT"); row.name:SetWordWrap(true); row.name:SetTextColor(unpack(INK))
            row.location=row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
            row.location:SetJustifyH("LEFT"); row.location:SetWordWrap(true); row.location:SetTextColor(unpack(SOFT))
            row.distance=row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
            row.distance:SetJustifyH("LEFT"); row.distance:SetWordWrap(false); row.distance:SetTextColor(unpack(SOFT))
            local rule=row:CreateTexture(nil,"BORDER"); rule:SetHeight(1)
            rule:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",4,0); rule:SetPoint("BOTTOMRIGHT",row,"BOTTOMRIGHT",-4,0)
            rule:SetColorTexture(.48,.30,.13,.22)
            row:EnableMouseWheel(true); row:SetScript("OnMouseWheel",menu.Wheel)
            row:SetScript("OnEnter",function(r)
                GameTooltip:SetOwner(r,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:GetGuideMapLabel(r.point))
                GameTooltip:AddLine(r.point.distance and FF:LocalizedText("journal.link.picker-distance" ,Distance(r.point)) or FF:LocalizedText("journal.link.picker-distance-unavailable"),.8,.8,.8,true)
                if r.point.sourceKind or r.point.rank then GameTooltip:AddLine(FF:GetJournalSourceKindText(r.point),.8,.8,.8) end
                if r.point.roleText then GameTooltip:AddLine(FF:GetJournalSourceRoleText(r.point,menu.owner and menu.owner.target.rank),.8,.8,.8,true) end
                if r.point.serviceSummary then GameTooltip:AddLine(FF:GetJournalSourceServicesText(r.point),.8,.8,.8,true) end
                if r.nearbySource and r.point.x and r.point.y then GameTooltip:AddLine(FF:FormatCoordinateDisplay(r.point.x*100,r.point.y*100),.7,.7,.7) end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave",function() GameTooltip:Hide() end)
            row:SetScript("OnClick",function(r)
                local owner=menu.owner
                if not owner then return end
                local point=r.point; menu:Hide(); FF:OpenGuideMapPoint(point)
            end)
            menu.rows[index]=row
        end
        row.point=point; row.nearbySource=nearby; row:SetWidth(rowWidth)
        row.name:SetTextColor(.12,.32,.58)
        Font(row.name,13); Font(row.location,12); Font(row.distance,12)
        row.distance:SetText(Distance(point)); row.distance:Show()
        local distanceWidth=row.distance:GetStringWidth()+1
        if self:GetResolvedLocale()~="enUS" then
            distanceWidth=math.min(distanceWidth,math.max(1,(rowWidth-28)*.45)); row.distance:SetWordWrap(true)
        end
        row.name:SetWidth(0); row.name:SetText(self:GetJournalNPCDisplayName(point.name))
        local nameWidth=math.min(row.name:GetStringWidth()+1,rowWidth-distanceWidth-18)
        row.name:SetWidth(math.max(1,nameWidth))
        row.distance:SetWidth(distanceWidth)
        row.location:SetWidth(rowWidth-10); row.location:SetText(self:GetJournalSourceLocationText(point))
        local firstHeight=math.max(row.name:GetStringHeight(),row.distance:GetStringHeight())
        row.name:ClearAllPoints(); row.name:SetPoint("TOPLEFT",row,"TOPLEFT",5,-5)
        row.location:ClearAllPoints(); row.location:SetPoint("TOPLEFT",row,"TOPLEFT",5,-8-firstHeight)
        row.distance:ClearAllPoints(); row.distance:SetPoint("TOPLEFT",row,"TOPLEFT",5+nameWidth+8,-5)
        row:SetHeight(math.max(32,13+firstHeight+row.location:GetStringHeight()))
        row:ClearAllPoints(); row:SetPoint("TOPLEFT",menu.content,"TOPLEFT",0,-total)
        row.bg:SetColorTexture(.48,.30,.13,0)
        row:Show(); total=total+row:GetHeight()+2
    end
    for index=#points+1,#menu.rows do menu.rows[index]:Hide() end
    local left,top,w,h,up=self:GetJournalRoutePickerPlacement(pageWidth,pageHeight,x,y,anchorHeight,width,total+16)
    menu.content:SetSize(rowWidth,math.max(1,total)); menu.scroll:SetSize(rowWidth,h-16)
    menu:SetSize(w,h); menu:ClearAllPoints(); menu:SetPoint("TOPLEFT",page,"TOPLEFT",left,-top)
    menu.opensUp=up; menu.owner=button; button.icon:SetTexCoord(0,1,0,1)
    menu.scroll:SetVerticalScroll(0); menu:Show()
end

function FF:GetJournalFloatingPicker(panel,paper) return Picker(panel,paper) end

function FF:OpenJournalNearbyList(button,entries,kind)
    local panel=self.journalPanel
    if not panel or self.journalTab~="nearby" or not button or not button:IsVisible()
        or not entries or #entries<(kind=="zone" and 1 or 2)
        or InCombatLockdown and InCombatLockdown()
        or self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
    if self.DismissJournalSearch then self:DismissJournalSearch(false) end
    local menu=Picker(panel,button.paper)
    if menu:IsShown() and menu.owner==button then menu:Hide(); return end
    menu:Hide(); RouteMenuSkin(menu,true)
    if panel.nearbyZoneControls then panel.nearbyZoneControls.menu:Hide() end
    for _,row in ipairs(menu.rows) do row:Hide() end
    local page=panel.page
    local pageWidth=page:GetWidth()>0 and page:GetWidth() or panel:GetWidth()-180
    local pageHeight=page:GetHeight()>0 and page:GetHeight() or panel:GetHeight()-100
    local pageLeft,pageTop=page:GetLeft() or 0,page:GetTop() or pageHeight
    local anchor=button.anchor or button
    if not menu.measure then menu.measure=menu:CreateFontString(nil,"OVERLAY","GameFontNormal"); menu.measure:Hide() end
    Font(menu.measure,13); local widest=0
    for _,entry in ipairs(entries) do menu.measure:SetText(kind=="zone" and self:GetZoneDisplayName(entry.name) or self:GetJournalItemDisplayName(entry[1] or entry.id,entry[2] or entry.name)); widest=math.max(widest,menu.measure:GetStringWidth()+12) end
    local width=self:GetJournalRouteMenuWidth(pageWidth,widest)
    local total=0
    for index,entry in ipairs(entries) do
        local row=menu.catchRows[index]
        if not row then
            row=CreateFrame("Button",nil,menu.content); row:RegisterForClicks("LeftButtonUp")
            local hi=row:CreateTexture(nil,"HIGHLIGHT"); hi:SetAllPoints(row); hi:SetColorTexture(.48,.30,.13,.14)
            row.name=row:CreateFontString(nil,"OVERLAY","GameFontHighlight")
            row.name:SetJustifyH("LEFT"); row.name:SetWordWrap(true); row.name:SetTextColor(unpack(INK))
            local rule=row:CreateTexture(nil,"BORDER"); rule:SetHeight(1)
            rule:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",4,0); rule:SetPoint("BOTTOMRIGHT",row,"BOTTOMRIGHT",-4,0)
            rule:SetColorTexture(.48,.30,.13,.22)
            row:EnableMouseWheel(true); row:SetScript("OnMouseWheel",menu.Wheel)
            row:SetScript("OnEnter",function(r)
                if r.zoneName then
                    GameTooltip:SetOwner(r,"ANCHOR_RIGHT"); GameTooltip:SetText(r.zoneDisplayName or r.zoneName)
                    GameTooltip:AddLine(FF:LocalizedText("journal.link.browse-zone"),.8,.8,.8,true); GameTooltip:Show()
                else FF:ShowJournalCatchTooltip(r,r.itemID,FF:LocalizedText("journal.link.weighted-catch")) end
            end)
            row:SetScript("OnLeave",function() GameTooltip:Hide() end)
            row:SetScript("OnClick",function(r)
                local id,zone=r.itemID,r.zoneName; menu:Hide()
                if zone then FF:SetNearbyZone(zone) else FF:OpenGuideCatch(id) end
            end)
            menu.catchRows[index]=row
        end
        row.itemID=entry[1]; row.zoneName=kind=="zone" and entry.name or nil
        row.zoneDisplayName=kind=="zone" and self:GetZoneDisplayName(entry.name) or nil
        Font(row.name,13); row.name:SetWidth(width-28); row.name:SetText(row.zoneDisplayName or self:GetJournalItemDisplayName(entry[1] or entry.id,entry[2] or entry.name))
        row.name:ClearAllPoints(); row.name:SetPoint("TOPLEFT",row,"TOPLEFT",6,-6)
        row:SetSize(width-16,math.max(28,row.name:GetStringHeight()+12))
        row:ClearAllPoints(); row:SetPoint("TOPLEFT",menu.content,"TOPLEFT",0,-total)
        row:Show(); total=total+row:GetHeight()+1
    end
    for index=#entries+1,#menu.catchRows do menu.catchRows[index]:Hide() end
    local left,top,w,h,up=self:GetJournalRoutePickerPlacement(pageWidth,pageHeight,
        (anchor:GetLeft() or pageLeft+12)-pageLeft,pageTop-(anchor:GetTop() or pageTop-20),anchor:GetHeight(),width,total+16)
    menu.content:SetSize(width-16,math.max(1,total)); menu.scroll:SetSize(width-16,h-16)
    menu:SetSize(w,h); menu:ClearAllPoints(); menu:SetPoint("TOPLEFT",page,"TOPLEFT",left,-top)
    menu.opensUp=up; menu.owner=button; button.icon:SetTexCoord(0,1,0,1)
    menu.scroll:SetVerticalScroll(0); menu:Show()
end

function FF:OpenJournalCatchVariants(button) return self:OpenJournalNearbyList(button,button and button.variants,"catch") end
function FF:OpenJournalNearbyZonePicker(button) return self:OpenJournalNearbyList(button,self:GetNearbyZones(),"zone") end

-- Route-only inline flow: use native font measurements and pooled line regions.
-- Controls reserve real 24x22/20x22 hit rectangles; there is no guessed glyph
-- offset, whole-paragraph link or dependency on native character-span APIs.
local function Atoms(text)
    local atoms,color,link,space={},nil,nil,false
    local i=1
    while i<=#text do
        local code=text:sub(i,i+1)
        if code=="|c" and text:sub(i+2,i+9):match("^%x%x%x%x%x%x%x%x$") then color=text:sub(i,i+9); i=i+10
        elseif code=="|r" then color=nil; i=i+2
        elseif code=="|H" then
            local endAt=text:find("|h",i+2,true)
            if not endAt then break end
            link=text:sub(i+2,endAt-1); i=endAt+2
        elseif code=="|h" then link=nil; i=i+2
        elseif code=="|T" then
            local endAt=text:find("|t",i+2,true)
            if not endAt then break end
            atoms[#atoms+1]={text=text:sub(i,endAt+1),color=color,link=link,space=space,texture=true}
            i=endAt+2; space=false
        elseif text:sub(i,i):match("%s") then
            if text:sub(i,i)=="\n" then atoms[#atoms+1]={newline=true} end
            space=true; i=i+1
        else
            local finish=i
            while finish<=#text and not text:sub(finish,finish):match("[%s|]") do finish=finish+1 end
            if finish==i then finish=i+1 end
            atoms[#atoms+1]={text=text:sub(i,finish-1),color=color,link=link,space=space}
            i=finish; space=false
        end
    end
    return atoms
end
local function Rich(atom)
    local text=atom.text
    if atom.link then text="|H"..atom.link.."|h"..text.."|h" end
    return (atom.color or "")..text..(atom.color and "|r" or "")
end
-- Link text and skill colours remain native FontStrings. Each source owns a
-- measured name/control group, rather than splitting controls into word flow.
local function TextRun(atoms)
    local rendered,group={},nil
    local function Flush()
        if group then rendered[#rendered+1]=Rich(group); group=nil end
    end
    for _,a in ipairs(atoms) do
        if a.newline then Flush(); rendered[#rendered+1]="\n"
        elseif group and group.link==a.link and group.color==a.color then
            group.text=group.text..(a.space and " " or "")..a.text
        else
            Flush()
            if #rendered>0 and a.space then rendered[#rendered+1]=" " end
            group={text=a.text,link=a.link,color=a.color}
        end
    end
    Flush(); return table.concat(rendered)
end
local function SourceControl(flow,index)
    local b=flow.controls[index]
    if b then return b end
    b=CreateFrame("Button",nil,flow); b:RegisterForClicks("LeftButtonUp")
    b.icon=b:CreateTexture(nil,"ARTWORK"); b.icon:SetPoint("CENTER",b,"CENTER",0,0)
    b:SetScript("OnClick",function(button)
        if button.target.kind=="routepicker" then FF:OpenJournalRoutePicker(button)
        else
            FF:CloseJournalRoutePicker()
            local point=FF:GetJournalRouteSource(button.target)
            if point then FF:OpenGuideMapPoint(point) end
        end
    end)
    b:SetScript("OnEnter",function(button)
        GameTooltip:SetOwner(button,"ANCHOR_RIGHT")
        GameTooltip:SetText(button.target.kind=="routepicker" and FF:GetJournalSourcePickerTitle(button.target.rank) or FF:LocalizedText("journal.link.show-map"))
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave",function() GameTooltip:Hide() end)
    b:EnableMouseWheel(true); b:SetScript("OnMouseWheel",function(_,delta)
        local s=FF.journalPanel.scroll
        s:SetVerticalScroll(math.max(0,math.min(s:GetVerticalScrollRange(),s:GetVerticalScroll()-delta*48)))
    end)
    flow.controls[index]=b; return b
end
function FF:LayoutJournalRouteInline(owner,font,text,width,heading,links,paper)
    local atoms=Atoms(text); local hasSource=false
    for _,a in ipairs(atoms) do
        a.target=a.link and self:GuideLinkTarget(a.link)
        if a.target and a.target.kind=="routesource" then hasSource=true end
    end
    local flow=owner.routeInline
    if not hasSource then
        if flow then flow:Hide() end
        font:Show(); return font:GetStringHeight()
    end
    if not flow then
        flow=CreateFrame("Frame",nil,owner); flow.lines={}; flow.controls={}; flow.groups={}
        flow.measure=flow:CreateFontString(nil,"OVERLAY","GameFontHighlight"); flow.measure:Hide()
        links(flow,self.journalPanel); owner.routeInline=flow
    end
    flow:ClearAllPoints(); flow:SetPoint("TOPLEFT",font,"TOPLEFT",0,0); flow:SetWidth(width)
    for _,line in ipairs(flow.lines) do line:Hide() end
    for _,control in ipairs(flow.controls) do control:Hide() end
    for _,group in ipairs(flow.groups) do group:Hide() end
    local path,size=font:GetFont()
    FF:CopyDisplayFont(flow.measure,font,size,""); flow.measure:SetWordWrap(false); flow.measure:SetWidth(0)
    flow.measure:SetText("Ag"); local lineHeight=flow.measure:GetStringHeight()
    local function Natural(value) flow.measure:SetText(value); return flow.measure:GetStringWidth() end
    local y,lineIndex,controlIndex,groupIndex=0,0,0,0
    local function Label(value,w,x,top,relative)
        lineIndex=lineIndex+1
        local label=flow.lines[lineIndex]
        if not label then label=flow:CreateFontString(nil,"OVERLAY","GameFontHighlight"); flow.lines[lineIndex]=label end
        FF:CopyDisplayFont(label,font,size,""); label:SetShadowColor(0,0,0,0); label:SetShadowOffset(0,0)
        label:SetWordWrap(true); label:SetJustifyH("LEFT"); label:SetTextColor(unpack(heading and INK or SOFT))
        label:SetWidth(math.max(1,w)); label:SetText(value)
        label:ClearAllPoints(); label:SetPoint("TOPLEFT",relative or flow,"TOPLEFT",x or 0,-top)
        label:Show(); return label
    end
    local pending={}
    local function Prose()
        if #pending==0 then return end
        if pending[#pending].text then pending[#pending].text=pending[#pending].text:gsub(";$","") end
        local value=TextRun(pending)
        if value:match("%S") then
            local label=Label(value,width,0,y)
            y=y+label:GetStringHeight()+3
        end
        pending={}
    end
    local i=1
    while i<=#atoms do
        local a=atoms[i]; local target=a.target
        if target and target.kind=="routesource" and not a.texture then
            Prose(); local picker; local j=i
            while j<=#atoms do
                local nextTarget=atoms[j].target
                if nextTarget and nextTarget.kind=="routesource" and nextTarget.rank==target.rank and nextTarget.name==target.name then
                    j=j+1
                elseif nextTarget and nextTarget.kind=="routepicker" and nextTarget.rank==target.rank then
                    picker=nextTarget; j=j+1
                else break end
            end
            if atoms[j] and atoms[j].text=="." then j=j+1 end
            local point=self:GetJournalRouteSource(target)
            local name=self:GetJournalNPCDisplayName(point and point.name or target.name)
            local location=point and self:GetJournalSourceLocationText(point) or target.label
            groupIndex=groupIndex+1
            local group=flow.groups[groupIndex]
            if not group then group=CreateFrame("Frame",nil,flow); group:EnableMouse(false); flow.groups[groupIndex]=group end
            group.target=target
            group:ClearAllPoints(); group:SetPoint("TOPLEFT",flow,"TOPLEFT",0,-y)
            local controls=(picker and 26 or 0)+20
            local textWidth=math.max(1,width-controls-6)
            local sourceAtoms=Atoms(self:GuideTargetLink(target,name).." • "..self:GuideTargetLink(target,location))
            local line,used,top,lastWidth,lastTop,lastLabel={},0,math.max(0,(22-lineHeight)/2),0,0,nil
            group.textLines={}
            local function FlushSource()
                if #line==0 then return end
                local label=Label(TextRun(line),textWidth,0,top,group)
                group.textLines[#group.textLines+1]=label
                lastWidth=math.min(textWidth,used); lastTop=top+math.max(0,label:GetStringHeight()-lineHeight)
                lastLabel=label; top=top+math.max(22,label:GetStringHeight())+2
                line,used={},0
            end
            for _,atom in ipairs(sourceAtoms) do
                local gap=#line>0 and atom.space and Natural(" ") or 0
                local w=Natural(atom.text)
                if #line>0 and used+gap+w>textWidth then FlushSource(); gap=0 end
                line[#line+1]=atom; used=used+gap+w
            end
            FlushSource()
            group.name,group.location=group.textLines[1],lastLabel
            local controlX=lastWidth+6
            local controlTop=lastTop-(22-lineHeight)/2
            local function Control(t,isPicker)
                controlIndex=controlIndex+1; local b=SourceControl(flow,controlIndex)
                b.target=t; b.paper=paper; b.flow=flow; b.anchor=group; b.displayedName=name
                b:SetSize(isPicker and 24 or 20,22); b:ClearAllPoints()
                b:SetPoint("TOPLEFT",group,"TOPLEFT",controlX,-controlTop)
                if isPicker then
                    self:SetJournalChevron(b.icon,false); b.icon:SetSize(12,7)
                    self.journalPanel.routeSelectors[t.id]=b
                else
                    b.icon:SetTexture(self.journalAssets.U01); b.icon:SetTexCoord(0,1,0,1); b.icon:SetSize(14,14); b.icon:SetVertexColor(1,1,1,1)
                end
                b:Show(); controlX=controlX+b:GetWidth()+2
            end
            Control(target,false); if picker then Control(picker,true) end
            local height=math.max(lastTop+lineHeight,controlTop+22)
            group:SetSize(math.min(width,math.max(textWidth,controlX-2)),height)
            group:Show(); y=y+height+3; i=j
        else pending[#pending+1]=a; i=i+1 end
    end
    Prose(); local height=math.max(lineHeight,y-3)
    flow:SetHeight(height); font:Hide(); flow:Show(); return height
end
