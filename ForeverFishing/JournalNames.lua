-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Display resources never replace action IDs, canonical source labels or saves.
local function ResourceName(self,kind,id,locale)
    local data=self.journalNameData
    local record=data and data.records[kind] and data.records[kind][id]
    if not record then return end
    return locale=="enUS" and record.english or record[locale] or record.english
end
local function ClientLocale(self)
    local locale=self:GetClientLocale()
    return (not locale or locale=="enGB") and "enUS" or locale
end
function FF:UsesJournalDisplayNames()
    return self:GetResolvedLocale()~="enUS" or self:UsesNativeJournalNames()
end
function FF:GetJournalItemDisplayName(id,fallback)
    local locale=self:GetResolvedLocale()
    local name=ResourceName(self,"item",id,locale)
    if locale=="enUS" and ClientLocale(self)=="enUS" then return fallback or name end
    if locale==ClientLocale(self) then return self:GetNativeItemName(id,name or fallback) end
    return name or self:GetNativeItemName(id,fallback)
end
function FF:GetJournalSpellDisplayName(id,fallback)
    local locale=self:GetResolvedLocale()
    local name=ResourceName(self,"spell",id,locale)
    if locale=="enUS" and ClientLocale(self)=="enUS" then return fallback or name end
    if locale==ClientLocale(self) then return self:GetNativeSpellName(id,name or fallback) end
    return name or self:GetNativeSpellName(id,fallback)
end
function FF:GetJournalNamedReference(kind,name)
    local data=self.journalNameData
    local record=data and data.byName[kind] and data.byName[kind][name]
    if not record then return name end
    local locale=self:GetResolvedLocale()
    return locale=="enUS" and name or record[locale] or name
end
function FF:GetJournalNPCDisplayName(name)
    return self:GetJournalNamedReference("npc",name)
end
function FF:GetJournalQuestDisplayName(id,fallback)
    local locale=self:GetResolvedLocale()
    local name=ResourceName(self,"quest",id,locale) or self:GetJournalNamedReference("quest",fallback)
    if locale=="enUS" and ClientLocale(self)=="enUS" then return fallback or name end
    if locale==ClientLocale(self) then return self:GetNativeQuestName(id,name or fallback) end
    return name or self:GetNativeQuestName(id,fallback)
end
local familyKeys={ ["Mud Snapper"]="mud-snapper",Catfish="catfish",Redgill="redgill",
    Salmon="salmon",Mightfish="mightfish",Yellowtail="yellowtail" }
function FF:GetJournalFamilyDisplayName(name)
    local key=familyKeys[name]
    return key and self:LocalizedText("nearby.family.name."..key) or name
end
function FF:GetJournalPoolDisplayName(name)
    if name=="Floating Debris & Wreckage" then return self:LocalizedText("nearby.pool.wreckage-group") end
    local display=self:GetJournalNamedReference("object",name)
    if name=="Floating Wreckage" and display==name then return self:LocalizedText("nearby.pool.floating-wreckage") end
    return display
end

-- Reference-only names are matched longest first, with the same English word
-- boundaries as the curated prose. Callers supply plain text or unlinked runs.
local nameTokens,tokenOwner
local function Tokens(self)
    if tokenOwner==self.journalNameData and nameTokens then return nameTokens end
    tokenOwner=self.journalNameData; nameTokens={}
    for kind,records in pairs(tokenOwner and tokenOwner.byName or {}) do
        for name in pairs(records) do
            local word=name:match("^[%w']+")
            if word then
                local list=nameTokens[word] or {};nameTokens[word]=list
                list[#list+1]={name=name,kind=kind}
            end
        end
    end
    for _,list in pairs(nameTokens) do table.sort(list,function(a,b)
        return #a.name>#b.name or #a.name==#b.name and a.kind<b.kind
    end) end
    return nameTokens
end
function FF:LocalizeJournalReferenceText(text)
    if type(text)~="string" then return text end
    local tokens=Tokens(self)
    local parts,cursor={},1
    for start,word in text:gmatch("()(%u[%w']*)") do
        if start>=cursor and not text:sub(start-1,start-1):match("[%w']") then
            for _,token in ipairs(tokens[word] or {}) do
                local after=start+#token.name
                if text:sub(start,after-1)==token.name and not text:sub(after,after):match("[%w']") then
                    local name=self:GetJournalNamedReference(token.kind,token.name)
                    if start>cursor then parts[#parts+1]=self:LocalizeReferenceZones(text:sub(cursor,start-1)) end
                    parts[#parts+1]=name;cursor=after;break
                end
            end
        end
    end
    if cursor==1 then return self:LocalizeReferenceZones(text) end
    parts[#parts+1]=self:LocalizeReferenceZones(text:sub(cursor))
    return table.concat(parts)
end
