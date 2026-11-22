-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF=_G.ForeverFishing
-- Parsed records are canonical; selected-language wording is projected on read.
local function CanonicalFoodText(key,...) return string.format(FF.englishStrings[key],...) end
local function Public(value) return not (issecretvalue and issecretvalue(value)) end
local function Plain(text)
    return text:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("|H.-|h(.-)|h","%1")
        :gsub("|T.-|t",""):gsub("|A.-|a",""):gsub("|n"," ")
        :gsub("\194\160"," "):gsub("\226\128\175"," "):gsub("\226\128\137"," "):gsub("%s+"," "):match("^%s*(.-)%s*$")
end
local function FinishedMeal(id)
    for _,meal in ipairs(FF.masterChefMeals or {}) do if meal.id==id then return true end end
    return false
end
local function CampOutput(id) return id==279967 or id==279965 end
local function Trim(text) return text:match("^%s*(.-)%s*$"):gsub("[%.;]+$","") end
local function TimeUnit(unit)
    return ({sec=true,secs=true,second=true,seconds=true,min=true,mins=true,minute=true,minutes=true,
        hr=true,hrs=true,hour=true,hours=true,day=true,days=true})[unit:lower():gsub("%.","")]
end
-- Native use metadata must be removed before punctuation/benefit splitting.
-- Match a complete cooldown label, never an arbitrary duration/parenthesis or
-- an effect such as reducing spell cooldowns. English parsing is locale-gated.
local function DurationOnly(text)
    text=text:lower():gsub("%-"," "):gsub(","," "):gsub("%f[%a]and%f[%A]"," ")
    if text:match("^%d+:%d%d$") or text:match("^%d+:%d%d:%d%d$") then return true end
    local count=0
    text=text:gsub("(%d+%.?%d*)%s*([%a]+)%.?",function(amount,unit)
        if TimeUnit(unit) then count=count+1; return "" end
        return amount.." "..unit
    end)
    return count>0 and text:match("^%s*$")~=nil
end
local function CooldownLabel(text)
    text=Plain(text):gsub("·"," "):lower():gsub("cool%s+down","cooldown"):gsub(";"," ")
        :gsub("^[%s%(%[]+", ""):gsub("[%s%)%]%.]+$", "")
    text=text:gsub(" shared cooldown$"," cooldown"):gsub(" use cooldown$"," cooldown")
    if text=="no cooldown" then return true end
    local duration=text:match("^(.-)%s*cooldown$")
        or text:match("^cooldown%s*:%s*(.+)$") or text:match("^cooldown%s+of%s+(.+)$")
        or text:match("^cooldown%s+(.+)$") or text:match("^use cooldown%s+(.+)$")
        or text:match("^recast%s*:%s*(.+)$") or text:match("^recharge%s*:%s*(.+)$")
        or text:match("^use cooldown%s*:%s*(.+)$") or text:match("^shared cooldown%s*:%s*(.+)$")
        or text:match("^this item has a cooldown of%s+(.+)$")
        or text:match("^has a cooldown of%s+(.+)$")
        or text:match("^all camping features share a cooldown of%s+(.+)$")
    return duration and DurationOnly(duration) or false
end
local function WithoutUseCooldown(text)
    text=Plain(text)
    local function Annotation(part) return CooldownLabel(part) and "" or part end
    text=text:gsub("%b()",Annotation):gsub("%b[]",Annotation)
    if CooldownLabel(text) then return "" end
    -- Unbracketed labels must occupy a whole trailing sentence/clause.
    -- The numeric amount in a real cooldown-reduction effect is preserved.
    for index=1,#text do
        if text:sub(index,index):match("[%.;]") and CooldownLabel(text:sub(index+1)) then
            text=text:sub(1,index); break
        end
    end
    -- A truncated native annotation may end at '(1 Sec.' before the remaining
    -- cooldown label arrives. Only an unclosed, numeric time-only tail qualifies.
    text=text:gsub("%(%s*%d+%.?%d*%s*[%a%.]+%s*$",function(part)
        local unit=part:match("^%(%s*%d+%.?%d*%s*([%a%.]+)%s*$")
        return unit and TimeUnit(unit) and "" or part
    end)
    return Plain(text):gsub("%s*·%s*$","")
end
-- Split only top-level clauses; punctuation inside a restriction or duration
-- remains intact. A time abbreviation followed by 'for/while' is not a sentence.
local function EffectParts(text,sentences)
    local parts,start,depth={},1,0
    for index=1,#text do
        local char=text:sub(index,index)
        if char=="(" or char=="[" then depth=depth+1
        elseif char==")" or char=="]" then depth=math.max(0,depth-1) end
        local split=not sentences and char==";" and depth==0
        if sentences and char=="." and depth==0 and (index==#text or text:sub(index+1,index+1):match("%s")) then
            local unit=text:sub(1,index-1):match("([%a]+)$")
            local nextWord=text:sub(index+1):match("^%s*(%a+)")
            split=not (unit and TimeUnit(unit) and ({["for"]=true,["while"]=true,when=true,per=true,every=true,["and"]=true})[nextWord])
        end
        if split then parts[#parts+1]=text:sub(start,index-1);start=index+1 end
    end
    parts[#parts+1]=text:sub(start)
    return parts
end
local function Flavour(text)
    return ({["eat me"]=true,["drink me"]=true,["you feel funny"]=true})[Trim(text):lower()] == true
end
-- The only installed semantic supplements: the two currently catalogued vague
-- cooked disguises. Forever spell records and Blizzard's beta notes verify
-- forms/duration; see docs/journal-reference-sources.md. Never borrow raw-fish
-- effects or Classic's old random combat effects/Whimsyfin placeholder forms.
local vagueEffects={
    [6657]={spellID=8213,bonus="Ninja or pirate disguise for 1 hour",
        search="appearance transformation ninja pirate disguise"},
    [251525]={spellID=1252576,bonus="Orc ninja or pirate disguise for 1 hour",
        search="appearance transformation orc ninja pirate disguise"},
}
local function VagueBenefits(uses,id)
    local entry=vagueEffects[id]
    if not entry then return end
    local found=false
    for _,body in ipairs(uses) do for _,part in ipairs(EffectParts(WithoutUseCooldown(body),true)) do
        part=Trim(part)
        if Flavour(part) then found=true elseif part~="" then return end
    end end
    if not found then return end
    local get=Public(C_Item) and type(C_Item)=="table" and rawget(C_Item,"GetItemSpell") or GetItemSpell
    if Public(get) and type(get)=="function" then
        local ok,_,spell=pcall(get,id)
        if not ok or not Public(spell) or (spell and spell~=entry.spellID) then return end
    end
    return nil,entry.bonus,true,entry.search
end
local function ShortDuration(text)
    return text:gsub("%f[%a]seconds?%f[%A]", "sec"):gsub("%f[%a]minutes?%f[%A]", "min")
end
local function ShortStat(text)
    local lower=text:lower()
    if lower=="attack power" then return CanonicalFoodText("food.attack-power-short") end
    if lower=="fishing skill" then return CanonicalFoodText("food.fishing-short") end
    return text
end
local function CompactBonus(text)
    local effect,duration=text:match("^(.-)%s+for%s+(%d+%.?%d*%s+%a+)$")
    if duration then
        local unit=duration:match("%s+(%a+)$"):lower()
        if not ({sec=true,secs=true,second=true,seconds=true,min=true,mins=true,minute=true,minutes=true,hr=true,hrs=true,hour=true,hours=true,day=true,days=true})[unit] then effect,duration=nil,nil end
    end
    if not effect then effect=text end
    local lower=effect:lower()
    local value=lower:match("^experience gained from kills is increased by (%d+%.?%d*%%)$")
        or lower:match("^experience from kills is increased by (%d+%.?%d*%%)$")
    local result
    if value then
        result="+"..value.." "..CanonicalFoodText("food.kill-xp-short")
    else
        value=lower:match("^restores? (%d+%.?%d*) mana every 5 seconds?$")
            or lower:match("^restores? (%d+%.?%d*) mana per 5 seconds?$")
        if value then result="+"..value.." "..CanonicalFoodText("food.mana-regen-short") end
    end
    if not result then
        local stat,amount=effect:match("^[Ii]ncreases?%s+(.+)%s+by%s+(%d+%.?%d*%%?)$")
        if stat then
            stat=stat:gsub("^[Yy]our%s+", "")
            result="+"..amount.." "..ShortStat(stat)
        else
            amount,stat=effect:match("^(%d+%.?%d*%%?)%s+(.+)$")
            -- A leading number alone does not prove an unfamiliar effect is a
            -- stat increase. Restrict this shorthand to recognised stat names.
            if stat then
                local known=stat:lower()
                if ({["attack power"]=true,["spell damage"]=true,["armor"]=true,["fishing skill"]=true,
                    ["fishing"]=true,["stamina"]=true,["spirit"]=true,["strength"]=true,
                    ["agility"]=true,["intellect"]=true,["stamina and spirit"]=true})[known] then
                    result="+"..amount.." "..ShortStat(stat)
                end
            end
        end
    end
    -- Unfamiliar effects stay native; never drop their amounts or infer a duration.
    result=result or effect
    return result..(duration and (" ("..ShortDuration(duration)..")") or "")
end
local function CompactBonuses(text)
    if not text then return nil end
    local parts={}
    for _,clause in ipairs(EffectParts(WithoutUseCooldown(text),false)) do
        clause=Trim(WithoutUseCooldown(clause))
        if clause~="" then parts[#parts+1]=CompactBonus(clause) end
    end
    return #parts>0 and table.concat(parts,CanonicalFoodText("food.effect-separator")) or nil
end
-- These two outputs have their own native camp-use wording. Never read their
-- ingredient's effects, infer lure amounts, or copy another output's bonuses.
local function CampBenefits(uses,id)
    local body=WithoutUseCooldown(table.concat(uses," "))
    local effect=body:match("^(.-)%.%s+[Rr]equires a [Cc]ampfire") or body
    if id==279967 then
        local amount=effect:match("allows you and others sitting nearby to gain (%d+%.?%d*%%) increased stats")
        if amount and effect:find("mutually exclusive with Blessing of Kings",1,true) then
            return nil,CanonicalFoodText("food.camp-bowl-stats",amount),true,effect
        end
    elseif id==279965 then
        local duration=effect:match("ability to catch uncommon fish for (%d+%.?%d*%s+%a+)")
        local unit=duration and duration:match("%s+(%a+)$")
        if unit and TimeUnit(unit) and effect:find("provides Fishing Skill lures",1,true)
            and effect:find("provides all of the benefits of a Fish Bowl",1,true) then
            return nil,table.concat({CanonicalFoodText("food.camp-uncommon-fish",ShortDuration(duration)),
                CanonicalFoodText("food.camp-lures"),CanonicalFoodText("food.camp-bowl-benefits")},"; "),true,effect
        end
    end
end
-- Keep numbers, durations and unfamiliar effects native. Only remove known
-- English eating instructions; other client wording is never guessed as zero.
local function Summarize(uses,id)
    if GetLocale then
        local ok,locale=pcall(GetLocale)
        if not ok or not Public(locale) or (locale~="enUS" and locale~="enGB") then return nil end
    end
    if CampOutput(id) then return CampBenefits(uses,id) end
    local restores,bonuses,seen={},{},{}
    local understood=false
    for _,body in ipairs(uses) do
        body=WithoutUseCooldown(body)
        for _,sentence in ipairs(EffectParts(body,true)) do
            sentence=Trim(WithoutUseCooldown(sentence))
            sentence=sentence:gsub("[Mm]ust remain seated while eating and drinking","")
                :gsub("[Mm]ust remain seated while eating",""):gsub("[Mm]ust remain seated while drinking","")
            sentence=Trim(sentence)
            local lower=sentence:lower()
            if sentence~="" and not Flavour(sentence) then
                local gain=sentence:match("[Ww]ell fed and (.+)")
                    or sentence:match("[Ww]ell%-fed and (.+)")
                if gain then sentence=Trim(gain):gsub("^[Gg]ain%s+",""); lower=sentence:lower(); understood=true end
                sentence=sentence:gsub("^[Aa]dditionally,%s*",""):gsub("^[Aa]lso%s+","")
                lower=sentence:lower()
                local restoration=lower:match("^restores? .+ over .+")
                    and (lower:find("health",1,true) or lower:find("mana",1,true))
                    and not lower:match("every%s+%d")
                if restoration then
                    local value=sentence:gsub("^[Rr]estores?%s+","")
                    if not seen[value] then restores[#restores+1]=value; seen[value]=true end
                    understood=true
                elseif sentence~="" then
                    -- A conditional effect not understood in full stays intact;
                    -- do not silently discard additional XP/transformation/etc.
                    if not seen[sentence] then bonuses[#bonuses+1]=sentence; seen[sentence]=true end
                    if gain or lower:match("%d") or lower:find("transform",1,true) then understood=true end
                end
            end
        end
    end
    if not understood then return VagueBenefits(uses,id) end
    return #restores>0 and table.concat(restores,"; ") or nil,#bonuses>0 and table.concat(bonuses,"; ") or nil,true
end
local function SearchText(restores,bonuses)
    local text=string.lower((restores or "").." "..(bonuses or ""))
    local bonus=string.lower(bonuses or "")
    if bonus:find("mana",1,true) and (bonus:match("every%s+5%s+sec") or bonus:match("per%s+5%s+sec") or bonus:match("mp5")) then
        text=text.." mana regeneration mana regen mp5 mana per 5 seconds mana every 5 seconds"
    end
    if bonus:find("experience",1,true) and bonus:find("kill",1,true) then text=text.." kill xp experience from kills" end
    return text
end
-- One canonical token keeps phrase aliases from matching unrelated numbers
-- elsewhere in a recipe (for example the 5% XP on ordinary restorative food).
function FF:NormalizeJournalFoodSearch(query)
    return query:gsub("mana%s+per%s+5%s+seconds?","mp5"):gsub("mana%s+every%s+5%s+seconds?","mp5")
        :gsub("mana%s+per%s+5%s+secs?","mp5"):gsub("mana%s+every%s+5%s+secs?","mp5")
        :gsub("mp/5","mp5")
end
function FF:ScheduleJournalFoodEffectRefresh()
    self.journalFoodEffectRevision=(self.journalFoodEffectRevision or 0)+1
    if self.journalFoodRefreshQueued then return end
    self.journalFoodRefreshQueued=true
    local function Refresh()
        self.journalFoodRefreshQueued=nil
        if self.RefreshJournal then self:RefreshJournal() end
        local panel=self.journalPanel
        if panel and panel:IsShown() and panel.searchInput and panel.searchInput:GetText()~="" and self.RefreshJournalSearchResults then
            self:RefreshJournalSearchResults()
        end
    end
    if C_Timer and C_Timer.After then C_Timer.After(0,Refresh) else Refresh() end
end
function FF:JournalFoodItemDataReceived(id,success)
    if not Public(id) or not Public(success) or not self.journalFoodRequests or not self.journalFoodRequests[id] then return end
    self.journalFoodEffects[id]=nil
    -- Retry a failed request only on a later deliberate display/search pass.
    if not success then self.journalFoodRequests[id]=GetTime()+1 end
    self:ScheduleJournalFoodEffectRefresh()
end
local function WatchData(self,id,dataID)
    if not Public(dataID) or type(dataID)~="number" then return end
    self.journalFoodDataIDs=self.journalFoodDataIDs or {}
    for previous,item in pairs(self.journalFoodDataIDs) do if item==id then self.journalFoodDataIDs[previous]=nil end end
    self.journalFoodDataIDs[dataID]=id
    if self.journalFoodDataWatcher then return end
    local watch=CreateFrame("Frame")
    watch:RegisterEvent("TOOLTIP_DATA_UPDATE")
    watch:SetScript("OnEvent",function(_,_,instance)
        if not Public(instance) then return end
        local item=instance and self.journalFoodDataIDs[instance]
        if not item then return end
        self.journalFoodEffects[item]=nil
        self:ScheduleJournalFoodEffectRefresh()
    end)
    self.journalFoodDataWatcher=watch
end
local function ReadUses(self,id)
    if not Public(C_TooltipInfo) then return end
    local getter=type(C_TooltipInfo)=="table" and rawget(C_TooltipInfo,"GetHyperlink")
    if not Public(getter) or type(getter)~="function" then return end
    local ok,info=pcall(getter,"item:"..id)
    if not ok or not Public(info) or type(info)~="table" then return end
    WatchData(self,id,rawget(info,"dataInstanceID"))
    local lines=rawget(info,"lines")
    if not Public(lines) or type(lines)~="table" then return end
    local uses={}
    local prefix=Public(ITEM_SPELL_TRIGGER_ONUSE) and type(ITEM_SPELL_TRIGGER_ONUSE)=="string" and Plain(ITEM_SPELL_TRIGGER_ONUSE) or "Use:"
    for _,line in ipairs(lines) do
        if not Public(line) or type(line)~="table" then return end
        local text=rawget(line,"leftText")
        if not Public(text) then return end
        if type(text)=="string" then
            text=Plain(text)
            if text==RETRIEVING_ITEM_INFO then return end
            if text:sub(1,#prefix)==prefix then
                local body=text:sub(#prefix+1):match("^%s*(.-)%s*$")
                local right=rawget(line,"rightText")
                if Public(right) and type(right)=="string" then
                    right=Plain(right)
                    if not CooldownLabel(right) and right:lower():find("cooldown",1,true) then body=body.." "..right end
                end
                if body~="" then uses[#uses+1]=body end
            elseif #uses>0 and (text:match("^[Aa]dditionally,") or text:match("^[Aa]lso ")
                or text:match("^[Ii]f you spend ") or text:match("^[Ee]xperience gained from kills")
                or CooldownLabel(text) or text:match("^%(")
                or text:lower():match("^cooldown%s*%)$")) then
                -- Some native layouts put the remaining effect in another line.
                -- Metadata and other items' descriptions are never inherited.
                uses[#uses]=uses[#uses].." "..text
            end
        end
    end
    if #uses>0 then return uses end
end
-- Spell descriptions are native effect bodies, not item tooltip metadata.
-- Keep them literal: no translated grammar, stat inference, or disguise facts.
local function FoodClientLocale()
    if not GetLocale then return "enUS" end
    local ok,locale=pcall(GetLocale)
    if ok and Public(locale) and type(locale)=="string" and locale~="" then return locale end
    return "unavailable"
end
local function WatchFoodSpell(self,id,spellID)
    self.journalFoodSpellIDs=self.journalFoodSpellIDs or {}
    self.journalFoodSpellIDs[id]=spellID
    if self.journalFoodSpellWatcher or self.journalFoodSpellWatchUnavailable then return end
    local watch=CreateFrame("Frame")
    -- Older clients may lack this optional completion event. Deliberate display
    -- passes still retry unavailable data through the existing one-second gate.
    if not pcall(watch.RegisterEvent,watch,"SPELL_TEXT_UPDATE") then
        self.journalFoodSpellWatchUnavailable=true;return
    end
    watch:SetScript("OnEvent",function(_,_,changed)
        if not Public(changed) or type(changed)~="number" or not self.journalFoodEffects then return end
        local refresh=false
        for item,spell in pairs(self.journalFoodSpellIDs) do
            if spell==changed then self.journalFoodEffects[item]=nil;refresh=true end
        end
        if refresh then self:ScheduleJournalFoodEffectRefresh() end
    end)
    self.journalFoodSpellWatcher=watch
end
local function NativeFoodDescription(self,id)
    local locale=FoodClientLocale()
    if locale=="enUS" or locale=="enGB" or locale=="unavailable" then return end
    local itemAPI=Public(C_Item) and type(C_Item)=="table" and rawget(C_Item,"GetItemSpell")
    local spellAPI=Public(C_Spell) and type(C_Spell)=="table" and rawget(C_Spell,"GetSpellDescription")
    local itemReaders={itemAPI,GetItemSpell}
    local spellReaders={spellAPI,GetSpellDescription}
    local spellID
    for slot=1,2 do
        local reader=itemReaders[slot]
        if Public(reader) and type(reader)=="function" then
            local ok,_,value=pcall(reader,id)
            if ok and Public(value) and type(value)=="number" and value>0
                and value<math.huge and value==math.floor(value) then spellID=value;break end
        end
    end
    if not spellID then return end
    if not ((Public(spellAPI) and type(spellAPI)=="function")
        or (Public(GetSpellDescription) and type(GetSpellDescription)=="function")) then return end
    WatchFoodSpell(self,id,spellID)
    for slot=1,2 do
        local reader=spellReaders[slot]
        if Public(reader) and type(reader)=="function" then
            local ok,text=pcall(reader,spellID)
            if ok and Public(text) and type(text)=="string" then
                text=Plain(text)
                -- Incomplete formula tokens must never look like known values.
                if text~="" and text~=RETRIEVING_ITEM_INFO and not text:find("%$[%w{]") then return text end
            end
        end
    end
end

function FF:GetJournalFoodEffects(id)
    id=Public(id) and tonumber(id)
    if not id or not (FinishedMeal(id) or CampOutput(id)) then return nil end
    self.journalFoodEffects=self.journalFoodEffects or {}
    self.journalFoodRequests=self.journalFoodRequests or {}
    local previous=self.journalFoodEffects[id]
    local level=UnitLevel and UnitLevel("player")
    if not Public(level) then level=nil end
    local locale=FoodClientLocale()
    local context=tostring(locale).."/"..tostring(level)
    local now=GetTime()
    if previous and previous.context==context and (previous.available or now<previous.retryAt) then return previous end
    -- Retry missing text only on a later display/search pass, at most once per
    -- second per output; there is no retry timer or idle tooltip scan.
    local record={available=false,summary=CanonicalFoodText(CampOutput(id) and "food.item-effects-unavailable" or "food.effects-unavailable"),search="",retryAt=now+1,context=context}
    -- Arm before native requests: item events may arrive synchronously.
    self.journalFoodEffects[id]=record
    local uses=ReadUses(self,id)
    if uses then
        local restores,bonuses,available,nativeSearch=Summarize(uses,id)
        if available then
            record.available=true
            record.restores=restores and ShortDuration(restores)
            record.bonuses=CompactBonuses(bonuses)
            record.summary=record.bonuses or CanonicalFoodText("food.restores-summary",record.restores)
            record.search=SearchText(restores,bonuses).." "..(record.restores or "").." "..(record.bonuses or "").." "..(nativeSearch or "")
            if previous then self:ScheduleJournalFoodEffectRefresh() end
            return record
        end
    end
    local description=NativeFoodDescription(self,id)
    if description then
        record.available=true
        record.nativeEffects=description
        record.summary=description
        record.search=description
        if previous then self:ScheduleJournalFoodEffectRefresh() end
        return record
    end
    local request=Public(C_Item) and type(C_Item)=="table" and rawget(C_Item,"RequestLoadItemDataByID")
    local requested=self.journalFoodRequests[id]
    local retry=type(requested)=="number" and now>=requested
    if Public(request) and type(request)=="function" and (not requested or retry) then
        self.journalFoodRequests[id]=true
        local ok=pcall(request,id)
        if not ok then self.journalFoodRequests[id]=now+1 end
    end
    return record
end
function FF:WarmJournalFoodEffects()
    for _,meal in ipairs(self.masterChefMeals or {}) do self:GetJournalFoodEffects(meal.id) end
    for _,id in ipairs({279967,279965}) do self:GetJournalFoodEffects(id) end
end
function FF:GetJournalCatchFoodSearchText(id)
    local parts={}
    for _,use in ipairs(self:GetJournalCatchUses(id)) do
        if use.target.kind=="meal" or (use.target.kind=="campinfo" and CampOutput(use.target.id)) then
            local effect=self:GetJournalFoodDisplayEffects(use.target.id)
            if effect and effect.available then parts[#parts+1]=use.target.label.." "..effect.search end
        end
    end
    return table.concat(parts," ")
end
