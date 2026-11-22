-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
FF.guideLinkColor = "345f6b"
FF.journalQuestColor = "934600"

function FF:JournalQuestTitleText(text, canonical)
    local title = text:match("^%[(.-)%]$") or text
    local quest=self:GetJournalQuestReference(canonical or title)
    if quest then return "["..self:GetJournalQuestDisplayName(quest.questID,title).."]" end
    return text
end

function FF:GetJournalGuideLinkColor(target)
    return self:GetJournalQuestReference(target.label) and self.journalQuestColor or self.guideLinkColor
end
local STATIC_LINK_LIMIT = 256

-- Each point uses the zone map shown in Forever and coordinates written in
-- the guide or verified against the Forever zone map. Do not infer a position
-- from an NPC name at runtime: names may have multiple spawns or map layers.
local locations = {
    { "Old Man Heming", 1434, 27.4, 77.2 },
    { "Jang", 1434, 27.4, 76.8 },
    { "Lee Brown", 1429, 47.6, 62.2 },
    { "Gubber Blump", 1439, 36.1, 44.9 },
    { "Wizbang Cranktoggle", 1439, 37.0, 44.1 },
    { "Nat Pagle", 1445, 59, 60 },
    { "Katoom the Angler", 1425, 80.2, 81.4 },
    { "Kelsey Yance", 1434, 28.2, 74.3 },
    { "(27.4, 77)", 1434, 27.4, 77 },
    { "(59, 60)", 1445, 59, 60 },
    { "(62, 51)", 1444, 62, 51 },
    { "(90, 72)", 1435, 90, 72 },
    { "(25, 77)", 1443, 25, 77 },
    { "(33, 32)", 1434, 33, 32 },
    { "(80.2, 81.4)", 1425, 80.2, 81.4 },
}

local function AddToken(tokens, targets, label, kind, id, mapID, x, y)
    local key = #targets + 1
    targets[key] = { label = label, kind = kind, id = id, mapID = mapID,
        x = x and x / 100, y = y and y / 100 }
    tokens[#tokens + 1] = { text = label, search = FF:FoldSearchText(label), key = key }
end

function FF:PrepareGuideLinks()
    if self.guideLinkTokens then self:RefreshPendingNativeJournalNames();self:RefreshNativeGuideNames();return end
    local tokens, targets, names = {}, {}, {}
    for _, entry in ipairs(self.GetJournalCatchCatalogue and self:GetJournalCatchCatalogue() or self.catchCollection or {}) do
        if not names[entry[2]] then
            AddToken(tokens, targets, entry[2], "fish", entry[1])
            names[entry[2]] = true
        end
    end
    for _, meal in ipairs(self.masterChefMeals or {}) do
        if not names[meal.name] then
            AddToken(tokens, targets, meal.name, "meal", meal.id)
            names[meal.name] = true
        end
    end
    for _, camp in ipairs(self.masterChefCamps or {}) do
        if (not camp.profession or camp.profession == "Fishing") and not names[camp.name] then
            AddToken(tokens, targets, camp.name, "camp", camp.id)
            names[camp.name] = true
        end
    end
    for _,entry in ipairs({{6256,"Fishing Pole"},{6365,"Strong Fishing Pole"},{6366,"Darkwood Fishing Pole"},
        {12225,"Blump Family Fishing Pole"},{6367,"Big Iron Fishing Pole"},{19022,"Nat Pagle's Extreme Angler FC-5000"},
        {19970,"Arcanite Fishing Pole"},{19972,"Lucky Fishing Hat"},{19969,"Nat Pagle's Extreme Anglin' Boots"},
        {19971,"High Test Eternium Fishing Line"},{6529,"Shiny Bauble"},{6530,"Nightcrawlers"},{6532,"Bright Baubles"},
        {6811,"Aquadynamic Fish Lens"},{6533,"Aquadynamic Fish Attractor"},{7307,"Flesh Eating Worm"},
        {8959,"Raw Spinefin Halibut"},{286732,"Shiny Silver Coin"},{4471,"Flint and Tinder"},{4470,"Simple Wood"},
        {285094,"Ravaged Fishing Pole"},{7996,"Worn Fishing Hat"},{19979,"Hook of the Master Angler"},{276274,"Surfer Shoes"},
        {250189,"Recipe: Clam Linguine"},{286153,"Recipe: Plated Armorfish"},{274972,"Recipe: Briny Seafood Stew"}}) do
        if not names[entry[2]] then AddToken(tokens,targets,entry[2],"item",entry[1]); names[entry[2]]=true end
    end
    AddToken(tokens,targets,"Wide-Brimmed Fishing Hat","spell",1265220)
    for _, quest in ipairs(self.journalQuestReferences) do
        -- Camping 101 already has an information target; retain that ID/kind.
        if quest.title ~= "Camping 101: Fishing" then
            AddToken(tokens, targets, quest.title, "quest", quest.questID)
        end
    end
    for _, point in ipairs(locations) do
        if not names[point[1]] then
            AddToken(tokens, targets, point[1], "map", nil, point[2], point[3], point[4])
            names[point[1]] = true
        end
    end
    AddToken(tokens, targets, "Build a Campfire", "campinfo", 279981)
    AddToken(tokens, targets, "Iron Oven", "campinfo", 279982)
    AddToken(tokens, targets, "Expert Fishing – The Bass and You", "item", 16083)
    AddToken(tokens, targets, "Camping 101: Fishing", "info", 97920)
    targets[#targets].tooltip = "A level 4+ starting-zone camping quest that teaches Fish Bowl at Fishing 20. Follow the introductory camping chain (The Adventurer, then The Great Outdoors), then take Camping 101: Fishing from your starting-zone camping guide. Alliance guides: Sam Sarsaparilla in Elwynn Forest, Eric Brighthammer in Dun Morogh, or Lyreena Duskblade in Teldrassil. Horde guides: Brakk in Durotar, Eleanor Shackleton in Tirisfal Glades, or Kaga Wildhoof in Mulgore. Skyborne: Raan Wildwind on Zephras Isle. Finish the quest at its named Fishing trainer. A campfire is required before placing the bowl; learn Basic Campfire from a Cooking trainer."
    -- A full quest name can replace an older linked NPC substring. Preserve
    -- that exact map destination; direct guide-use links keep their own action.
    for _, target in ipairs(targets) do
        local quest = self:GetJournalQuestReference(target.label)
        if quest and quest.mapLabel then
            for _, point in ipairs(targets) do
                if point.kind == "map" and point.label == quest.mapLabel then target.questMapTarget = point; break end
            end
        end
    end
    table.sort(tokens, function(a, b)
        return #a.text > #b.text or (#a.text == #b.text and a.text < b.text)
    end)
    self.guideLinkTokens, self.guideLinkTargets = tokens, targets
    self.guideCanonicalTokens=tokens
    self:RefreshNativeGuideNames()
end

function FF:RefreshNativeGuideNames()
    local locale=tostring(self:GetClientLocale()).."/"..self:GetResolvedLocale()
    if self.guideNativeLocale==locale and not self.guideNativeNamesDirty and self.guideNativeNamesReady then return end
    self.guideNativeLocale,self.guideNativeNamesDirty,self.guideNativeNamesReady=locale,nil,true
    local canonical=self.guideCanonicalTokens or self.guideLinkTokens
    if not self:UsesJournalDisplayNames() then self.guideLinkTokens=canonical;return end
    local tokens,occupied,aliases={},{},{}
    for _,token in ipairs(canonical) do tokens[#tokens+1]=token;occupied[token.search]=true end
    for _,token in ipairs(canonical) do
        local target=self.guideLinkTargets[token.key]
        for _,name in ipairs({self:GetNativeGuideTargetName(target,target.label),self:GetClientGuideTargetName(target,target.label)}) do
        if name and name~=target.label then
            local folded=self:FoldSearchText(name)
            if folded~="" and not occupied[folded] then
                local existing=aliases[folded]
                if existing==nil then aliases[folded]={text=name,search=folded,key=token.key,nativeAlias=true}
                elseif existing then
                    local previous=self.guideLinkTargets[existing.key]
                    if previous.kind~=target.kind or previous.id~=target.id then aliases[folded]=false end
                end
            end
        end
    end
        end
    for _,alias in pairs(aliases) do if alias then tokens[#tokens+1]=alias end end
    table.sort(tokens,function(a,b) return #a.text>#b.text or (#a.text==#b.text and a.text<b.text) end)
    self.guideLinkTokens=tokens
end

-- Latin/Cyrillic letters and combining marks continue a word. CJK/Hangul
-- prose may adjoin a canonical name without spaces; those are link boundaries.
-- ASCII boundary behavior (including punctuation/underscores) stays unchanged.
local function IsWordAt(text, at, previous)
    local byte = text:byte(at)
    if not byte then return false end
    if previous then
        while byte and byte >= 128 and byte <= 191 do at=at-1; byte=text:byte(at) end
    end
    if not byte then return false end
    if byte < 128 then
        return (byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
    end
    local b,c,d = text:byte(at+1,at+3)
    local point = byte < 224 and b and (byte-192)*64+b-128
        or byte < 240 and b and c and (byte-224)*4096+(b-128)*64+c-128
        or b and c and d and (byte-240)*262144+(b-128)*4096+(c-128)*64+d-128
    if not point then return true end
    if point==0xD7 or point==0xF7 then return false end
    return (point>=0xC0 and point<=0x2AF) or (point>=0x300 and point<=0x52F)
        or (point>=0x1AB0 and point<=0x1AFF) or (point>=0x1C80 and point<=0x1DBF)
        or (point>=0x1DC0 and point<=0x1EFF) or (point>=0x20D0 and point<=0x20FF)
        or (point>=0x2C60 and point<=0x2C7F) or (point>=0x2DE0 and point<=0x2DFF)
        or (point>=0xA640 and point<=0xA69F) or (point>=0xA720 and point<=0xA7FF)
        or (point>=0xAB30 and point<=0xAB6F) or (point>=0xFE20 and point<=0xFE2F)
end

-- Direct links reuse canonical navigation without adding prose tokens or
-- replacing their cache identities. Targets are stable for this login.
function FF:GuideTargetLink(target, text)
    self:PrepareGuideLinks()
    local registry = self.guideDirectLinks
    if not registry or registry.targets ~= self.guideLinkTargets then
        registry = { targets = self.guideLinkTargets, keys = {} }
        self.guideDirectLinks = registry
    end
    local identity = table.concat({ target.kind, target.id or "", target.mapID or "",
        target.x or "", target.y or "", target.label }, "/")
    local key = registry.keys[identity]
    if not key then
        key = #self.guideLinkTargets + 1
        self.guideLinkTargets[key] = target
        registry.keys[identity] = key
    end
    if text==target.label then text=self:GetNativeGuideTargetName(target,text) end
    if self:GetJournalQuestReference(target.label) then text = self:JournalQuestTitleText(text,target.label) end
    return "|cff" .. self:GetJournalGuideLinkColor(self.guideLinkTargets[key]) .. "|Hffguide:" .. key .. "|h" .. text .. "|h|r"
end

-- Hold native markup in one pass so placeholders never nest. Texture/atlas
-- payloads and escaped pipes must not become authored-name matches.
local function ProtectGuideMarkup(source, hold)
    local parts, cursor = {}, 1
    while cursor <= #source do
        local at = source:find("|",cursor,true)
        if not at then parts[#parts+1]=source:sub(cursor); break end
        local code=source:sub(at,at+1)
        local first,last
        if code=="||" then first,last=at,at+1
        else
            first,last=source:find("^|c%x%x%x%x%x%x%x%x|H.-|h.-|h|r",at)
            if not first then first,last=source:find("^|H.-|h.-|h",at) end
            if not first then first,last=source:find("^|T.-|t",at) end
            if not first then first,last=source:find("^|A.-|a",at) end
            if not first and (code=="|H" or code=="|T" or code=="|A") then first,last=at,#source end
        end
        if first then
            local before=source:sub(at-1,at-1)=="[" and at>cursor and "[" or ""
            local after=source:sub(last+1,last+1)=="]" and "]" or ""
            parts[#parts+1]=source:sub(cursor,at-1-#before)
            parts[#parts+1]=hold(before,source:sub(at,last),after)
            cursor=last+1+#after
        else
            parts[#parts+1]=source:sub(cursor,at);cursor=at+1
        end
    end
    return table.concat(parts)
end

function FF:GuideLinkText(source, staticText, questOnly)
    if type(source) ~= "string" or source == "" then return source end
    self:PrepareGuideLinks()
    -- Authored prose keeps canonical tokens until its names are projected.
    -- A translated category can equal an unrelated item name; it must not
    -- acquire a new destination merely because the selected language changed.
    local linkTokens=staticText and self.guideCanonicalTokens or self.guideLinkTokens
    -- Only canonical guide prose opts in. Live statuses and skill colouring
    -- stay outside this bounded per-login formatting cache.
    local cache
    if staticText and not questOnly and #source <= 8192 and not source:find("|", 1, true) then
        cache = self.guideLinkTextCache
        if not cache or cache.tokens ~= self.guideLinkTokens
            or cache.targets ~= self.guideLinkTargets or cache.color ~= self.guideLinkColor
            or cache.questColor ~= self.journalQuestColor or cache.locale ~= self:GetResolvedLocale() then
            cache = { tokens = self.guideLinkTokens, targets = self.guideLinkTargets,
                color = self.guideLinkColor, questColor = self.journalQuestColor, locale = self:GetResolvedLocale(), values = {}, keys = {}, next = 1 }
            self.guideLinkTextCache = cache
        end
        if cache.values[source] ~= nil then return cache.values[source] end
    end
    -- Existing links are atomic. Never tokenize their payload/display again,
    -- including item/NPC links whose names happen to contain a quest title.
    local held = {}
    local function Hold(before, value, after)
        local link, display = value:match("|H(.-)|h(.-)|h")
        local target = self:GuideLinkTarget(link)
        if target and self:GetJournalQuestReference(target.label) then
            value = "|cff"..self.journalQuestColor.."|H"..link.."|h"..self:JournalQuestTitleText(display,target.label).."|h|r"
            if before == "[" and after == "]" then before, after = "", "" end
        end
        held[#held+1] = (before or "")..value..(after or "")
        return "\001"..#held.."\002"
    end
    source = ProtectGuideMarkup(source, Hold)
    local lowerSource, starts, ends, offsets = self:FoldGuideLinkText(source)
    local result, cursor = {}, 1
    while cursor <= #source do
        local first, last, chosen, matchAt
        for _, token in ipairs(linkTokens) do
            if not questOnly or self:GetJournalQuestReference(self.guideLinkTargets[token.key].label) then
                local startAt = offsets and offsets[cursor] or cursor
                while true do
                    local a, b = lowerSource:find(token.search, startAt, true)
                    if not a or (matchAt and a > matchAt) then break end
                    local sourceFirst, sourceLast
                    if starts then sourceFirst, sourceLast = starts[a], ends[b] else sourceFirst, sourceLast = a, b end
                    local compound=token.nativeAlias and (source:sub((sourceFirst or 1)-1,(sourceFirst or 1)-1)=="-"
                        or source:sub((sourceLast or 0)+1,(sourceLast or 0)+1)=="-")
                    if sourceFirst and sourceLast and not compound and not IsWordAt(source,sourceFirst-1,true) and not IsWordAt(source,sourceLast+1) then
                        if not first or sourceFirst < first or (sourceFirst == first and sourceLast > last) then
                            first, last, chosen, matchAt = sourceFirst, sourceLast, token, a
                        end
                        break
                    end
                    startAt = a + 1
                end
            end
        end
        if not first then result[#result + 1] = self:LocalizeJournalReferenceText(source:sub(cursor)); break end
        local target, display = self.guideLinkTargets[chosen.key], source:sub(first, last)
        display=self:GetNativeGuideTargetName(target,display)
        if self:GetJournalQuestReference(target.label) then
            display = "["..display.."]"
            if source:sub(first-1,first-1) == "[" and source:sub(last+1,last+1) == "]" then
                first, last = first-1, last+1
            end
        end
        if first > cursor then result[#result + 1] = self:LocalizeJournalReferenceText(source:sub(cursor, first - 1)) end
        result[#result + 1] = "|cff" .. self:GetJournalGuideLinkColor(target) .. "|Hffguide:" .. chosen.key .. "|h"
            .. display .. "|h|r"
        cursor = last + 1
    end
    local text = table.concat(result):gsub("\001(%d+)\002", function(index) return held[tonumber(index)] end)
    if cache then
        local slot = cache.next
        local old = cache.keys[slot]
        if old then cache.values[old] = nil end
        cache.keys[slot], cache.values[source] = source, text
        cache.next = slot % STATIC_LINK_LIMIT + 1
    end
    return text
end

function FF:GuideLinkTarget(link)
    local key = type(link) == "string" and tonumber(link:match("^ffguide:(%d+)$"))
    return key and self.guideLinkTargets and self.guideLinkTargets[key]
end

-- Read-only, demand-driven enrichment. Never select a quest, open a quest UI
-- or treat the item IDs used by guide navigation as quest IDs.
local function QuestValue(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, value = pcall(fn, ...)
    if ok and not (issecretvalue and issecretvalue(value)) then return value end
end

function FF:GetJournalQuestID(quest)
    local api = C_QuestLog
    if not (issecretvalue and issecretvalue(api)) and type(api)=="table" then
        local count = QuestValue(api.GetNumQuestLogEntries)
        for index = 1, type(count) == "number" and count>=0 and count<=10000 and count or 0 do
            local info = QuestValue(api.GetInfo, index)
            if type(info) == "table" and not (issecretvalue and
                (issecretvalue(info.title) or issecretvalue(info.questID)))
                and type(info.questID) == "number" and info.questID > 0 and info.questID<math.huge and info.questID==math.floor(info.questID)
                and (info.title == quest.title or info.questID==quest.questID) then
                return info.questID
            end
        end
    end
    return quest.questID
end

function FF:AddJournalQuestTooltipLines(tooltip, quest, id, failed)
    tooltip:SetText(self:GetJournalQuestDisplayName(id,quest.title), 1, .82, .45)
    tooltip:AddLine(self:LocalizeJournalReferenceText(self:GetJournalQuestDisplayText(quest,"summary")) or self:LocalizedText("journal.link.quest-unavailable"), .8,.8,.8,true)
    local objectives = not failed and id and C_QuestLog and QuestValue(C_QuestLog.GetQuestObjectives, id)
    local count = 0
    if type(objectives) == "table" then
        for _, objective in ipairs(objectives) do
            local text = not (issecretvalue and issecretvalue(objective)) and type(objective) == "table" and objective.text
            if not (issecretvalue and issecretvalue(text)) and type(text) == "string" and text ~= "" then
                if count == 0 then tooltip:AddLine(self:LocalizedText("journal.link.objectives"), 1,.82,.45) end
                tooltip:AddLine(text, .8,.8,.8,true); count = count + 1
                if count == 6 then break end
            end
        end
    end
    if quest.requirements then tooltip:AddLine(self:LocalizedText("journal.link.requires" ,self:LocalizeJournalReferenceText(self:GetJournalQuestDisplayText(quest,"requirements"))), .8,.8,.8,true) end
    if quest.rewards then tooltip:AddLine(self:LocalizedText("journal.link.rewards" ,self:LocalizeJournalReferenceText(self:GetJournalQuestDisplayText(quest,"rewards"))), .8,.8,.8,true) end
    if quest.note then tooltip:AddLine(self:LocalizeJournalReferenceText(self:GetJournalQuestDisplayText(quest,"note")), .78,.71,.57,true) end
    if failed then tooltip:AddLine(self:LocalizedText("journal.link.quest-client-unavailable"), .78,.71,.57,true) end
    return count > 0
end

function FF:ClearJournalQuestHover(owner)
    if owner.journalQuestUnderline then owner.journalQuestUnderline:Hide() end
end

function FF:SetJournalQuestHover(owner, link, quest, bounds)
    self:ClearJournalQuestHover(owner)
    -- Do not SetText on a live hyperlink: rebuilding native hit regions from
    -- inside enter/leave can invalidate the very hover that owns the tooltip.
    -- Link offsets use the text region's TOPLEFT, not its paragraph bottom.
    -- Keep the native segment width/offset when a title wraps onto another line.
    local region, left, bottom, width
    if bounds then
        region, left, bottom, width = bounds.region, bounds.left, bounds.bottom, bounds.width
    elseif not link and owner.label then
        region, left, bottom = owner.label, 0, 0
        width = math.min(region:GetWidth(), region:GetStringWidth())
    end
    if not region or type(left) ~= "number" or type(bottom) ~= "number"
        or type(width) ~= "number" or width <= 0 then return end
    local line = owner.journalQuestUnderline
    if not line then line = owner:CreateTexture(nil,"OVERLAY"); owner.journalQuestUnderline = line end
    local color = self.journalQuestColor
    line:SetColorTexture(tonumber(color:sub(1,2),16)/255, tonumber(color:sub(3,4),16)/255,
        tonumber(color:sub(5,6),16)/255, .8)
    line:SetSize(width,1)
    line:ClearAllPoints()
    line:SetPoint("BOTTOMLEFT",region,bounds and "TOPLEFT" or "BOTTOMLEFT",left,bottom)
    line:Show()
end
