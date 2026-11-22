-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Reference-only catches never extend the fixed Session Goals/achievement
-- requirement sets. IDs/locations are curated Forever item records, not guesses
-- from item quality, price, weight-name matching, inventory or player mastery.
-- See docs/journal-reference-sources.md for provenance and incomplete coverage.
local function Reference(id,name,zones,condition,kind,faction)
    return {id,name,{waters=zones and table.concat(zones,", ") or "Exact waters not verified",
        zones=zones,method="Exact fishing method not verified",condition=condition},
        trophy=kind=="trophy",quest=kind=="quest",faction=faction,referenceOnly=true}
end
FF.journalCatchReferences = {
    Reference(6292,"10 Pound Mud Snapper",{"Dun Morogh","Durotar","Elwynn Forest","Mulgore","Teldrassil","Tirisfal Glades","Zephras Isle"},nil,"trophy"),
    Reference(6295,"15 Pound Mud Snapper",{"Elwynn Forest","Mulgore","Teldrassil","Dun Morogh","Durotar","Tirisfal Glades","The Barrens","Zephras Isle"},nil,"trophy"),
    Reference(6294,"12 Pound Mud Snapper",{"Elwynn Forest","Mulgore","Tirisfal Glades","Teldrassil","Durotar","Dun Morogh","Zephras Isle"},nil,"trophy"),
    Reference(6309,"17 Pound Catfish",{"Stormwind City","Darnassus","Orgrimmar","Ashenvale","Dustwallow Marsh","Darkshore","Redridge Mountains","Stranglethorn Vale","Undercity","Hillsbrad Foothills","Alterac Mountains","The Barrens","Thunder Bluff","Stonetalon Mountains","Arathi Highlands","Desolace","Loch Modan"},nil,"trophy"),
    Reference(6310,"19 Pound Catfish",{"Stormwind City","Ashenvale","Dustwallow Marsh","Redridge Mountains","Darkshore","Alterac Mountains","Hillsbrad Foothills","Orgrimmar","Stranglethorn Vale","Darnassus","The Barrens","Thunder Bluff","Loch Modan","Desolace","Arathi Highlands","Undercity","Stonetalon Mountains"},nil,"trophy"),
    Reference(6311,"22 Pound Catfish",{"Dustwallow Marsh","Ashenvale","Hillsbrad Foothills","Redridge Mountains","Desolace","Stormwind City","Arathi Highlands","Orgrimmar","Stonetalon Mountains","The Barrens","Darnassus","Stranglethorn Vale","Thunder Bluff","Alterac Mountains","Swamp of Sorrows","Darkshore","Thousand Needles","Loch Modan","Undercity","Westfall"},nil,"trophy"),
    Reference(6363,"26 Pound Catfish",{"Desolace","Dustwallow Marsh","Redridge Mountains","Ashenvale","Stranglethorn Vale","Alterac Mountains","Stonetalon Mountains","Arathi Highlands","Hillsbrad Foothills","Duskwood","Wetlands","Swamp of Sorrows"},nil,"trophy"),
    Reference(6364,"32 Pound Catfish",{"Dustwallow Marsh","Arathi Highlands","Desolace","Redridge Mountains","Ashenvale"},nil,"trophy"),
    Reference(13882,"42 Pound Redgill",{"Moonglade","Western Plaguelands","Feralas","The Hinterlands","Azshara","Felwood"},nil,"trophy"),
    Reference(13883,"45 Pound Redgill",{"Western Plaguelands","Moonglade","Feralas","The Hinterlands","Azshara","Felwood","Un'Goro Crater","Eastern Plaguelands"},nil,"trophy"),
    Reference(13884,"49 Pound Redgill",{"Feralas","Western Plaguelands","Moonglade","The Hinterlands","Un'Goro Crater","Azshara","Felwood"},nil,"trophy"),
    Reference(13885,"34 Pound Redgill",{"Un'Goro Crater","Felwood","Feralas","Moonglade","The Hinterlands","Western Plaguelands","Azshara"},nil,"trophy"),
    Reference(13886,"37 Pound Redgill",{"Western Plaguelands","Moonglade","Feralas","The Hinterlands","Azshara","Felwood","Un'Goro Crater"},nil,"trophy"),
    Reference(13887,"52 Pound Redgill",{"Western Plaguelands","Feralas","Azshara","Moonglade","The Hinterlands","Un'Goro Crater"},nil,"trophy"),
    Reference(13902,"18 Pound Salmon",{"Eastern Plaguelands","Winterspring","Alterac Valley"},nil,"trophy"),
    Reference(13904,"25 Pound Salmon",{"Winterspring","Deadwind Pass","Eastern Plaguelands","Mount Hyjal"},nil,"trophy"),
    Reference(13905,"29 Pound Salmon",{"Eastern Plaguelands","Winterspring","Alterac Valley"},nil,"trophy"),
    Reference(13915,"85 Pound Mightfish",{"Azshara"},nil,"trophy"),
    Reference(13914,"70 Pound Mightfish",nil,"Exact Forever waters are not fully documented.","trophy"),
    Reference(13916,"92 Pound Mightfish",{"Azshara"},nil,"trophy"),
    Reference(13917,"103 Pound Mightfish",nil,"Availability in Forever is not fully documented.","trophy"),
    Reference(13876,"40 Pound Yellowtail",{"The Hinterlands","Feralas","Azshara","Tanaris","Stranglethorn Vale"},nil,"trophy"),
    Reference(13877,"47 Pound Yellowtail",{"Tanaris","Azshara","Feralas","The Hinterlands"},nil,"trophy"),
    Reference(13878,"53 Pound Yellowtail",{"Azshara","Tanaris","Feralas","The Hinterlands"},nil,"trophy"),
    Reference(13879,"59 Pound Yellowtail",{"Azshara","Tanaris","Feralas","The Hinterlands","Stranglethorn Vale"},nil,"trophy"),
    Reference(13880,"68 Pound Yellowtail",{"Azshara","Tanaris","Feralas","The Hinterlands"},nil,"trophy"),
    Reference(16967,"Feralas Ahi",{"Feralas"},"Nat Pagle, Angler Extreme must be active; fish the Verdantis River.","quest"),
    Reference(16968,"Sar'theris Striker",{"Desolace"},"Nat Pagle, Angler Extreme must be active; fish the western coast.","quest"),
    Reference(16969,"Savage Coast Blue Sailfin",{"Stranglethorn Vale"},"Nat Pagle, Angler Extreme must be active; fish the Savage Coast.","quest"),
    Reference(16970,"Misty Reed Mahi Mahi",{"Swamp of Sorrows"},"Nat Pagle, Angler Extreme must be active; fish the eastern coast.","quest"),
    Reference(6717,"Gaffer Jack",{"Darkshore"},"For the Gaffer Jacks quest.","quest","Alliance"),
    Reference(6718,"Electropeller",{"Darkshore"},"For the Electropellers quest.","quest","Alliance"),
    Reference(21243,"Bloated Glossy Mightfish",{"Tanaris","Riverglades"}),
    Reference(118,"Minor Healing Potion",{"Elwynn Forest","Mulgore","Tirisfal Glades","Teldrassil","Durotar","Zephras Isle","Dun Morogh"}),
    Reference(288206,"Recipe: Draught of Water Walking",{"Mount Hyjal"}),
}
FF.journalCatchReferenceByID={}
for _,entry in ipairs(FF.journalCatchReferences) do FF.journalCatchReferenceByID[entry[1]]=entry end
local bloated={ [6643]=true,[6645]=true,[6647]=true,[8366]=true,[13881]=true,[13891]=true,[21163]=true,[21164]=true,[21243]=true }
local events={ [19807]=true,[19803]=true,[19805]=true,[19806]=true,[19808]=true }
function FF:GetJournalCatchDefinition(id)
    id=tonumber(id)
    return self.catchCollectionByID[id] or self.journalCatchReferenceByID[id]
end
function FF:GetJournalCatchCatalogue()
    if not self.journalCatchCatalogue then
        local entries={}
        for _,entry in ipairs(self.catchCollection) do entries[#entries+1]=entry end
        for _,entry in ipairs(self.journalCatchReferences) do entries[#entries+1]=entry end
        table.sort(entries,function(a,b) return a[2]<b[2] end)
        self.journalCatchCatalogue=entries
    end
    return self.journalCatchCatalogue
end
function FF:GetJournalCatchClassifications(id)
    id=tonumber(id); local entry=self:GetJournalCatchDefinition(id)
    return {rarity=entry and entry.rareTier,trophy=entry and entry.trophy==true or false,
        bloated=bloated[id]==true,quest=id==12238 or entry and entry.quest==true or false,event=events[id]==true}
end
function FF:AddJournalCatchClassifications(tooltip,id)
    local state=self:GetJournalCatchClassifications(id)
    if state.rarity then tooltip:AddLine(self:LocalizedText(state.rarity=="ultra" and "catch.class.ultra" or "catch.class.rare"),.77,.59,.25) end
    for _,kind in ipairs({{"trophy","catch.class.trophy"},{"bloated","catch.class.bloated"},{"quest","catch.class.quest"},{"event","catch.class.event"}}) do
        if state[kind[1]] then tooltip:AddLine(self:LocalizedText(kind[2]),.68,.57,.37) end
    end
end

local function FactionText(value,faction)
    if type(value)=="table" then return value[faction] end
    return value
end
local artisanUse={"leveling","Artisan Fishing  •  Skill 225, Level 35 required","Nat Pagle, Angler Extreme"}
local lensUse={"gear","Lures","Aquadynamic Fish Lens"}
local guideUses={
    [12238]={"gear","Fishing poles","The Family and the Fishing Pole"},
    [19807]={"rares","Stranglethorn Fishing Extravaganza","Fishing tournament"},
    [19803]={"gear","Fishing gear and upgrades","Nat Pagle's Extreme Anglin' Boots"},
    [19805]={"gear","Fishing gear and upgrades","Lucky Fishing Hat"},
    [19806]={"gear","Fishing gear and upgrades","High Test Eternium Fishing Line"},
    [16967]=artisanUse,[16968]=artisanUse,[16969]=artisanUse,[16970]=artisanUse,
    [6717]=lensUse,[6718]=lensUse,
}
-- Canonical ingredient names map to existing catch IDs exactly. Live recipe
-- ingredients only supplement that relation after the output has been verified
-- by Master Chef's existing discovery owner. No recipe/item scan is introduced.
function FF:GetJournalCatchUses(id)
    id=tonumber(id); local uses,seen={},{}
    local entry=self:GetJournalCatchDefinition(id)
    local function Add(target,skill,priority,detail)
        local key=target.kind..":"..target.id
        if seen[key] then return end; seen[key]=true
        uses[#uses+1]={target=target,skill=skill or 0,priority=priority or 100,detail=detail}
    end
    for _,meal in ipairs(self.masterChefMeals or {}) do
        local matched=false
        if entry then for name in tostring(meal.ingredients or ""):gmatch("[^,]+") do
            name=name:gsub("^%s*%d+%s+",""):gsub("^%s+",""):gsub("%s+$","")
            if name==entry[2] then matched=true end
        end end
        local recipe=self.masterChefRecipes and self.masterChefRecipes[meal.id]
        for _,ingredient in ipairs(recipe and recipe.ingredients or {}) do if ingredient.id==id then matched=true end end
        if matched then
            local heading = meal.skill and "Cooking "..meal.skill or "Ingredients"
            Add({kind="meal",id=meal.id,label=meal.name},meal.skill or math.huge,meal.usePriority or 10,
                heading.." • "..meal.ingredients.."\n"..(FactionText(meal.recipe,self:GetJournalFaction()) or "Source not verified"))
        end
    end
    for _,camp in ipairs(self.masterChefCamps or {}) do
        if not camp.faction or camp.faction==self:GetJournalFaction() then
            for _,ingredient in ipairs(camp.ingredients or {}) do if ingredient.id==id then
                Add({kind="campinfo",id=camp.id,label=camp.name},camp.skill,20,camp.source)
            end end
        end
    end
    local use=guideUses[id]
    if id==13755 or id==13756 then
        Add({kind="campinfo",id=279966,label="Seasonal Fish Steaks → Fishing Hut"},300,30,
            "At level 35 and Fishing 275, use a Chef's Knife on Raw Winter Squid or Raw Summer Bass to prepare Seasonal Fish Steaks for the Fishing Hut.")
        use=nil
    end
    if use and (not entry or not entry.faction or entry.faction==self:GetJournalFaction()) then
        Add({kind="guideuse",id=id,label=use[3],tab=use[1],heading=use[2]},0,30,"Open the verified Journal instructions.")
    end
    table.sort(uses,function(a,b)
        if a.priority~=b.priority then return a.priority<b.priority end
        if a.skill~=b.skill then return a.skill<b.skill end
        return a.target.label<b.target.label or a.target.label==b.target.label and a.target.id<b.target.id
    end)
    return uses
end

-- Zone aliases refer only to existing guide leads. New-zone UI IDs are resolved
-- from the client map tree; no guessed map positions or full loot tables.
local zones={
    {"Elwynn Forest",1429},{"Durotar",1411},{"Dun Morogh",1426},{"Mulgore",1412},{"Teldrassil",1438},{"Tirisfal Glades",1420},
    {"Stormwind City",1453,"Stormwind"},{"Orgrimmar",1454},{"Thunder Bluff",1456},{"Darnassus",1457},{"Ironforge",1455},{"Undercity",1458},
    {"Loch Modan",1432},{"Westfall",1436},{"Darkshore",1439},{"The Barrens",1413},{"Silverpine Forest",1421},
    {"Redridge Mountains",1433,"Redridge"},{"Wetlands",1437},{"Ashenvale",1440},{"Hillsbrad Foothills",1424,"Hillsbrad"},
    {"Stonetalon Mountains",1442,"Stonetalon"},{"Duskwood",1431},{"Alterac Mountains",1416},{"Arathi Highlands",1417},
    {"Desolace",1443},{"Dustwallow Marsh",1445},{"Stranglethorn Vale",1434,"Stranglethorn"},{"Swamp of Sorrows",1435},{"Thousand Needles",1441},
    {"Feralas",1444},{"Tanaris",1446},{"The Hinterlands",1425},{"Felwood",1448},{"Moonglade",1450},
    {"Un'Goro Crater",1449,"Un'Goro"},{"Western Plaguelands",1422},{"Eastern Plaguelands",1423},{"Winterspring",1452},{"Azshara",1447},
    {"Deadwind Pass",1430},{"Silithus",1451},{"Mount Hyjal",2482},
    {"Zephras Isle","Zephras Isle"},{"Riverglades","Riverglades"},
    {"Blackfathom Deeps","Blackfathom Deeps"},{"Wailing Caverns","Wailing Caverns"},{"Zul'Gurub","Zul'Gurub"},
}
local zoneByName={}
for _,zone in ipairs(zones) do zoneByName[zone[1]]=zone end
local fishingZoneSkills={}
for _,tier in ipairs({
    {1,25,{"Dun Morogh","Durotar","Elwynn Forest","Mulgore","Teldrassil","Tirisfal Glades","Zephras Isle"}},
    {1,75,{"The Barrens","Darkshore","Darnassus","Ironforge","Loch Modan","Orgrimmar","Silverpine Forest","Stormwind City","Thunder Bluff","Undercity","Westfall","Blackfathom Deeps","Wailing Caverns"}},
    {55,150,{"Ashenvale","Duskwood","Hillsbrad Foothills","Redridge Mountains","Stonetalon Mountains","Wetlands"}},
    {130,225,{"Alterac Mountains","Arathi Highlands","Desolace","Dustwallow Marsh","Stranglethorn Vale","Swamp of Sorrows","Thousand Needles"}},
    {205,300,{"Azshara","Felwood","Feralas","The Hinterlands","Moonglade","Tanaris","Un'Goro Crater","Western Plaguelands"}},
    {330,425,{"Eastern Plaguelands","Winterspring","Zul'Gurub"}},
}) do for _,name in ipairs(tier[3]) do fishingZoneSkills[name]={minimum=tier[1],reliable=tier[2]} end end
local zoneCaveats={
    ["Azshara"]="Bay of Storms, Hetaera's Clutch and Scalebeard's Cave need 330 minimum / 425 reliable effective skill.",
    ["Feralas"]="Jademir Lake needs 330 minimum / 425 reliable effective skill.",
    ["Stranglethorn Vale"]="Jaguero Isle needs 205 minimum / 300 reliable effective skill.",
    ["Ironforge"]="Some Ironforge water may not be fishable on modern Classic clients.",
}
function FF:GetNearbyZones()
    local result,seen={},{}
    for _,zone in ipairs(zones) do
        result[#result+1]={name=zone[1],mapID=self:GetGuideMapID(zone[2])}; seen[zone[1]]=true
    end
    for _,record in pairs(self.db and self.db.journal or {}) do
        for location in pairs(record.locations or {}) do
            local name=self:GetFishingLocationZone(location)
            if name and not seen[name] and not seen[self:GetCanonicalZoneName(name)] then
                result[#result+1]={name=name}; seen[name]=true
            end
        end
    end
    table.sort(result,function(a,b) return a.name<b.name end); return result
end
local currentContext=FF.GetNearbyContext
function FF:GetNearbyContext()
    local selected=self.journalPanel and self.journalPanel.nearbySelectedZone
    if selected then
        for _,zone in ipairs(self:GetNearbyZones()) do if zone.name==selected then return zone.mapID,zone.name,self:GetJournalFaction() end end
    end
    return currentContext(self)
end
function FF:SetNearbyZone(name)
    local panel=self.journalPanel
    if not panel then return end
    panel.nearbySelectedZone=name; panel.expandedGuides=panel.expandedGuides or {}
    self:SelectJournalTab("nearby"); panel.scroll:SetVerticalScroll(0)
end
local function InZone(point,mapID)
    local seen={}; local id=mapID
    while id and not seen[id] do
        if point.mapID==id then return true end
        seen[id]=true
        local ok,info
        if C_Map and C_Map.GetMapInfo then ok,info=pcall(C_Map.GetMapInfo,id) end
        id=ok and info and info.parentMapID; if id==0 then id=nil end
    end
    return false
end
local function RecordedCount(self,record,zone)
    local count=0
    if zone then for location,facts in pairs(record and record.locations or {}) do
        if self:FishingLocationMatchesZone(location,zone) then count=count+(facts.count or 0) end
    end end
    return count
end
-- Ordinary fish identities, independent of item quality. Special classifications
-- still win; this set never changes fixed collection/goal requirements.
local ordinaryFish={}
for _,id in ipairs({6291,6303,6289,6317,6522,6358,6361,6308,6359,6362,21071,21153,8365,
    4603,13422,13754,13755,13756,13758,13759,13760,13889,13888,13893,13757,13890,6299,6458,251524}) do ordinaryFish[id]=true end
function FF:IsNearbyCommonCatch(id)
    local state=self:GetJournalCatchClassifications(id)
    return ordinaryFish[tonumber(id)]==true and not (state.rarity or state.bloated or state.trophy or state.quest or state.event)
end
-- Positive Forever Fishing Locations records supplement the short best-water
-- recommendations. Zone-wide presence says nothing about every sub-water, pool,
-- season or drop rate. Provenance/coverage: docs/journal-reference-sources.md.
local verifiedCatchZones={
    [3820]={"Riverglades"},
    [6289]={"Dun Morogh"},
    [6358]={"Riverglades"},
    [6359]={"Riverglades","Mount Hyjal"},
    [8366]={"Riverglades"},
    [13422]={"Riverglades"},
    [21150]={"Riverglades"},
    [21151]={"Riverglades"},
    [21153]={"Riverglades"},
    [21228]={"Riverglades"},
    [6643]={"Dun Morogh","Zephras Isle"},
    [6291]={"Elwynn Forest","Stormwind City","Mulgore","Durotar","Teldrassil","Tirisfal Glades","Darnassus","Orgrimmar","Darkshore","The Barrens","Thunder Bluff","Silverpine Forest","Undercity","Westfall","Dun Morogh","Loch Modan","Duskwood","Tanaris","Zephras Isle"},
    [6361]={"Wetlands","Westfall","Darkshore","Hillsbrad Foothills","The Barrens","Ashenvale","Silverpine Forest"},
    [8365]={"Western Plaguelands","Dustwallow Marsh","Moonglade","Alterac Mountains","Stranglethorn Vale","Feralas","Arathi Highlands","The Hinterlands","Desolace","Swamp of Sorrows","Azshara","Thousand Needles","Un'Goro Crater","Felwood","Ashenvale","Eastern Plaguelands","Hillsbrad Foothills","Riverglades"},
    [13757]={"Deadwind Pass","Silithus","Mount Hyjal"},
    [13758]={"Western Plaguelands","Moonglade","The Hinterlands","Feralas","Un'Goro Crater","Felwood","Azshara","Deadwind Pass","Eastern Plaguelands","Winterspring","Ashenvale","Silithus","Alterac Valley","Mount Hyjal"},
    [13759]={"Deadwind Pass","Silithus","Mount Hyjal"},
    [13760]={"Western Plaguelands","Moonglade","Feralas","The Hinterlands","Eastern Plaguelands","Azshara","Felwood","Un'Goro Crater","Deadwind Pass","Winterspring","Ashenvale","Silithus","Alterac Valley","Mount Hyjal"},
    [13889]={"Deadwind Pass","Silithus","Mount Hyjal"},
    [13890]={"Eastern Plaguelands","Deadwind Pass","Feralas","Winterspring","Silithus","Alterac Valley","Mount Hyjal"},
    [13891]={"Deadwind Pass"},
    -- Existing MasterChefData route explicitly recommends Stormwind catfish.
    [6308]={"Stormwind City"},
}
local verifiedCatchesByZone={}
for id,names in pairs(verifiedCatchZones) do
    for _,name in ipairs(names) do
        local catches=verifiedCatchesByZone[name] or {}
        catches[id]=true
        verifiedCatchesByZone[name]=catches
    end
end
-- Current Forever NPC sells tables, checked 16 October 2026. Static positive
-- stock limits identify limited supply; they never describe live availability.
-- Provenance and deliberately curated coverage: docs/journal-reference-sources.md.
local fishingSupplierStock = {
    ["Baelann Swiftcurrent"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Catherine Leland"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Gretta Ganter"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Katoom the Angler"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Khara Deepwater"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Lindea Rabonne"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Lizbeth Cromwell"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Nessa Shadowsong"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Sewa Mistrunner"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Stuart Fleming"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Tansy Puddlefizz"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Tharynn Bouden"]={{id=6256,label="Fishing Pole"},{id=6529,label="Shiny Bauble"}},
    ["Wik'Tar"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
    ["Zansoa"]={{id=6256,label="Fishing Pole"},{id=6365,label="Strong Fishing Pole",limited=true},{id=6529,label="Shiny Bauble"},{id=6530,label="Nightcrawlers"},{id=6532,label="Bright Baubles"},{id=6533,label="Aquadynamic Fish Attractor",limited=true},{id=273636,label="Chef's Knife"}},
}

-- Gear references reuse positive supplier stock and the existing verified map
-- provider. Selling a pole does not imply that a supplier sells every lure.
function FF:GetFishingItemSuppliers(id, faction)
    local points = {}
    for _,point in ipairs(self:GetFishingPoleSources(faction)) do
        for _,item in ipairs(fishingSupplierStock[point.name] or {}) do
            if item.id == id then
                point.roleText = "Sells "..item.label..(item.limited and " (limited stock; live availability unknown)." or ".")
                points[#points+1]=point; break
            end
        end
    end
    return points
end

function FF:BuildNearbyData()
    local mapID,zone,faction=self:GetNearbyContext()
    local data={mapID=mapID,zone=zone,faction=faction,groups={},catches={},pools={},people={},supplies={},records={},skill=fishingZoneSkills[zone],caveat=zoneCaveats[zone]}
    local groups={ordinary={},rare={},trophy={},bloated={}}; local available,poolAvailable={},{}; local methods,conditions={},{}
    local alias=zoneByName[self:GetCanonicalZoneName(zone)]; local seen={}
    if not alias and mapID then
        for _,candidate in ipairs(zones) do if self:GetGuideMapID(candidate[2])==mapID then alias=candidate; break end end
    end
    local canonical=alias and alias[1] or self:GetCanonicalZoneName(zone)
    local verifiedCatches=verifiedCatchesByZone[canonical]
    data.skill=fishingZoneSkills[canonical]; data.caveat=zoneCaveats[canonical]
    for _,entry in ipairs(self:GetJournalCatchCatalogue()) do
        local id=entry[1]; local guide=entry[3]; local waters=FactionText(guide.waters,faction) or ""
        local match=false
        if guide.zones then for _,name in ipairs(guide.zones) do if name==zone or name==canonical then match=true end end
        elseif alias then
            for _,name in ipairs({canonical,alias[3]}) do if waters:find(name,1,true) then match=true end end
        end
        -- A recorded fish or zone-wide loot entry alone cannot establish a
        -- named school in that zone. Preserve independently curated pool leads.
        local eligible=not entry.faction or entry.faction==faction
        if match and eligible then poolAvailable[id]=true end
        local common=self:IsNearbyCommonCatch(id)
        -- Faction-specific best-water advice is not faction-exclusive loot.
        if common and alias and type(guide.waters)=="table" then for _,lead in pairs(guide.waters) do
            for _,name in ipairs({canonical,alias[3]}) do if lead:find(name,1,true) then match=true end end
        end end
        -- Reuse positive, exact-zone saved catches for known ordinary fish.
        local recorded=common and RecordedCount(self,self.db.journal and self.db.journal[id],zone)>0
        if eligible and (match or recorded or (verifiedCatches and verifiedCatches[id])) then
            local state=self:GetJournalCatchClassifications(id)
            local kind=state.bloated and "bloated" or state.trophy and "trophy" or state.rarity and "rare" or "ordinary"
            groups[kind][#groups[kind]+1]=entry; available[id]=true
            data.catches[#data.catches+1]=entry
            -- Catch presence can retain broad open-water guidance and its
            -- conditions. Specific methods need a curated local lead.
            local method=guide.method
            local broadWater=method=="Inland open water" or method=="Coastal open water"
            if not entry.referenceOnly and (match or broadWater) then methods[method]=true end
            local condition=FactionText(guide.condition,faction)
            if (match or broadWater) and condition and not state.bloated and not condition:lower():find("rare",1,true) then conditions[condition]=true end
        end
    end
    for _,kind in ipairs({{"ordinary","Catches here"},{"rare","Rare catches"},{"trophy","Trophy fish"},{"bloated","Bloated fish"}}) do
        if #groups[kind[1]]>0 then data.groups[#data.groups+1]={id=kind[1],title=kind[2],items=groups[kind[1]]} end
    end
    local waters={}; for method in pairs(methods) do waters[#waters+1]=method end; table.sort(waters)
    data.waters=#waters>0 and table.concat(waters," • ") or "No verified fishing-water leads are listed for this zone yet."
    data.methodDetails=data.waters
    local waterKinds={}
    for _,method in ipairs(waters) do
        local lower=method:lower()
        if lower:find("inland",1,true) then waterKinds.inland=true end
        if lower:find("coastal",1,true) then waterKinds.coastal=true end
        if lower=="open water" then waterKinds.open=true end
    end
    local compact={}
    if waterKinds.inland then compact[#compact+1]="Inland water" end
    if waterKinds.coastal then compact[#compact+1]="Coastal water" end
    if waterKinds.open then compact[#compact+1]="Open water" end
    data.waterTypes=compact
    local notes={}; for note in pairs(conditions) do notes[#notes+1]=note end; table.sort(notes)
    data.notes=table.concat(notes,"\n")
    -- These pool-to-catch relationships are already explicit in curated methods.
    local poolSpecs={{"School of Deviate Fish",6522},{"Oily Blackmouth School",6358},{"Firefin Snapper School",6359},
        {"Sagefish School",21071},{"Greater Sagefish School",21153},{"Stonescale Eel Swarm",13422},{"Oil Spill",6458},
        {"Whimsyfin School",251524},{"Schools of Tastyfish",19807}}
    for _,spec in ipairs(poolSpecs) do
        local entry=self:GetJournalCatchDefinition(spec[2])
        if poolAvailable[spec[2]] and (entry[3].method:lower():find("school",1,true) or entry[3].method:find("pool",1,true)) then
            local catches={entry}
            if spec[2]==19807 then for _,id in ipairs({19803,19805,19806,19808}) do if available[id] then catches[#catches+1]=self:GetJournalCatchDefinition(id) end end end
            if spec[2]==6359 and available[21163] then catches[#catches+1]=self:GetJournalCatchDefinition(21163) end
            data.pools[#data.pools+1]={name=spec[1],iconID=spec[2],catches=catches,
                note="Cast so your bobber lands inside the pool. Listed catches are verified leads; pool spawn positions are not tracked."}
        end
    end
    local wreckage={}
    for _,entry in ipairs(self:GetJournalCatchCatalogue()) do
        local method=entry[3].method:lower()
        if poolAvailable[entry[1]] and (method:find("wreckage",1,true) or method:find("debris",1,true)) then
            wreckage[#wreckage+1]=entry
        end
    end
    if #wreckage>0 then data.pools[#data.pools+1]={name="Floating Debris & Wreckage",iconID=wreckage[1][1],catches=wreckage,
        note="Fish inside the visible debris or wreckage ring. These are curated catch leads, not an exhaustive loot table or inventory contents."} end
    data.essentialMethods={}
    for _,method in ipairs(waters) do
        if method:find("only",1,true) then
            local represented=false
            for _,pool in ipairs(data.pools) do for _,entry in ipairs(pool.catches) do
                if entry[3].method==method then represented=true end
            end end
            if not represented then data.essentialMethods[#data.essentialMethods+1]=method end
        end
    end
    local function Person(point,role,services)
        if not mapID or not InZone(point,mapID) then return end
        point.label=point.label or point.name..", "..point.location
        -- Merge roles at the same verified spawn, not different locations that
        -- happen to share an NPC name. This is a transient presentation key.
        local key=table.concat({point.name,point.mapID,point.x or "?",point.y or "?"},":")
        local person=seen[key]
        if not person then person={key=key,point=point,roles={},services={}}; data.people[#data.people+1]=person; seen[key]=person end
        person.roles[role]=true
        for _,service in ipairs(services or {}) do
            local duplicate=false
            for _,existing in ipairs(person.services) do if existing.kind==service.kind and existing.id==service.id then duplicate=true end end
            if not duplicate then person.services[#person.services+1]=service end
        end
    end
    for _,vendor in ipairs(self:GetNearbyRecipeVendors(mapID,faction)) do
        local services={}
        for _,meal in ipairs(vendor.meals) do
            local target={kind="meal",id=meal.id,label=meal.name}
            services[#services+1]=target; data.supplies["meal:"..meal.id]=target
        end
        Person(vendor,"Recipes",services)
    end
    for _,point in ipairs(self:GetFishingTrainingSources("Apprentice",faction)) do
        Person(point,"Fishing trainer",{{kind="info",id=point.name,label="Apprentice and Journeyman Fishing",tooltip="Apprentice: cap 75. Journeyman: Skill 50, Level 10; cap 150."}})
    end
    -- These book/quest points reuse the accepted GuideLinks locations; they
    -- are not ordinary teachers and never enter the trainer dropdowns.
    Person({name="Old Man Heming",location="Booty Bay, Stranglethorn Vale",mapID=1434,x=.274,y=.772},"Fishing book",
        {{kind="item",id=16083,label="Expert Fishing – The Bass and You"}})
    Person({name="Nat Pagle",location="Dustwallow Marsh",mapID=1445,x=.59,y=.60},"Artisan quest",
        {{kind="guideuse",id=16967,tab="leveling",heading="Artisan Fishing  •  Skill 225, Level 35 required",label="Nat Pagle, Angler Extreme"}})
    if faction=="Alliance" then Person({name="Gubber Blump",location="Auberdine, Darkshore",mapID=1439,x=.361,y=.449},"Fishing pole quest",
        {{kind="guideuse",id=12238,tab="gear",heading="Fishing poles",label="The Family and the Fishing Pole"}}) end
    for _,point in ipairs(self:GetFishingPoleSources(faction)) do
        local services={}
        for _,item in ipairs(fishingSupplierStock[point.name] or {{id=6256,label="Fishing Pole"}}) do
            local service={kind="item",id=item.id,label=item.label,limited=item.limited}
            services[#services+1]=service
            if InZone(point,mapID) then data.supplies[item.id]=service end
        end
        Person(point,"Fishing supplies",services)
    end
    table.sort(data.people,function(a,b) return a.point.name<b.point.name end)
    -- A person appears once, under their first verified role below. Secondary
    -- roles and inventories stay attached to that person, never unioned.
    data.serviceGroups={}; local serviceGroups={}
    for _,person in ipairs(data.people) do
        local roles={}; for role in pairs(person.roles) do roles[#roles+1]=role end; table.sort(roles)
        person.point.roleText=table.concat(roles," • ")
        local key
        for _,role in ipairs({"Fishing trainer","Fishing book","Artisan quest","Fishing pole quest","Recipes","Fishing supplies"}) do
            if person.roles[role] then key=role; break end
        end
        local services={}; for _,service in ipairs(person.services) do services[#services+1]=service.label end
        person.point.serviceSummary=table.concat(services," • ")
        local group=serviceGroups[key]
        if not group then group={key=key,people={},points={}}; serviceGroups[key]=group; data.serviceGroups[#data.serviceGroups+1]=group end
        group.people[#group.people+1]=person; group.points[#group.points+1]=person.point
    end
    table.sort(data.serviceGroups,function(a,b) return a.key<b.key end)
    local recordSeen={}
    for id,record in pairs(self.db.journal or {}) do
        local count=RecordedCount(self,record,zone); id=tonumber(id)
        if id and count>0 and not recordSeen[id] then
            data.records[#data.records+1]={id=id,name=record.name or "Item "..id,count=count}; recordSeen[id]=true
        end
    end
    table.sort(data.records,function(a,b) return a.name<b.name or a.name==b.name and a.id<b.id end)
    data.recordTypes=#data.records; data.recordQuantity=0
    for _,record in ipairs(data.records) do data.recordQuantity=data.recordQuantity+record.count end
    return data
end

-- Explicit families from the verified ID table in journal-reference-sources.md.
-- Local membership still comes solely from the existing zone availability query.
local trophyFamilies={
    {name="Mud Snapper",ids={6292,6294,6295}},
    {name="Catfish",ids={6309,6310,6311,6363,6364}},
    {name="Redgill",ids={13885,13886,13882,13883,13884,13887}},
    {name="Salmon",ids={13902,13904,13905}},
    {name="Mightfish",ids={13914,13915,13916,13917}},
    {name="Yellowtail",ids={13876,13877,13878,13879,13880}},
}
local trophyFamilyByID={}
for _,family in ipairs(trophyFamilies) do for _,id in ipairs(family.ids) do trophyFamilyByID[id]=family end end
function FF:GetNearbyCatchGallery(data,filter)
    local tiles,available,seen={}, {}, {}; local filters={all=true,rare=true,trophy=true,common=true}
    for _,entry in ipairs(data.catches or {}) do
        available[entry[1]]=entry
    end
    if not filters[filter] then filter="all" end
    local function Included(entry)
        local state=self:GetJournalCatchClassifications(entry[1])
        return filter=="all" or filter=="rare" and (state.rarity or state.bloated)
            or filter=="common" and self:IsNearbyCommonCatch(entry[1]) or filter=="trophy" and state.trophy
    end
    for _,entry in ipairs(data.catches or {}) do if Included(entry) then
        local family=self:GetJournalCatchClassifications(entry[1]).trophy and trophyFamilyByID[entry[1]]
        local key=family or entry[1]
        if not seen[key] then
            seen[key]=true
            local variants={}
            if family then for _,id in ipairs(family.ids) do
                if available[id] and Included(available[id]) then variants[#variants+1]=available[id] end
            end else variants[1]=entry end
            local representative=variants[1]
            tiles[#tiles+1]={id=representative[1],name=family and family.name or entry[2],
                variants=family and variants or nil,family=family and family.name}
        end
    end end
    table.sort(tiles,function(a,b) return a.name<b.name or a.name==b.name and a.id<b.id end)
    return tiles,filters,filter
end
