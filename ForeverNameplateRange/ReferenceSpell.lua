local _, ns = ...
-- Reference choices, not a DPS/spec recommendation. Never hard-code spell range.
local candidates = {
    WARRIOR = {78, 1715, "MELEE"}, ROGUE = {1752, 53, "MELEE"},
    HUNTER = {75, 3044, 1978, "MELEE"}, MAGE = {116, 133, 2136},
    WARLOCK = {686, 348, 172}, PRIEST = {585, 8092, 15407, 589},
    SHAMAN = {403, 8042, "MELEE"}, PALADIN = {"MELEE", 35395, 20271},
    DRUID = {5176, 2912, 8921, 1082, 6807, "MELEE"},
}
local choices, class, selected = {}, nil, nil
local function SpellInfo(id)
    if C_Spell and C_Spell.GetSpellInfo then
        local s = C_Spell.GetSpellInfo(id)
        if s then return s.name, s.minRange or 0, s.maxRange end
    elseif GetSpellInfo then
        local name, _, _, _, minimum, maximum = GetSpellInfo(id)
        return name, minimum or 0, maximum
    end
end
local function Book()
    local found = {}
    if GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemName then
        for tab=1, GetNumSpellTabs() do
            local _, _, offset, count = GetSpellTabInfo(tab)
            for i=(offset or 0)+1, (offset or 0)+(count or 0) do
                local name = GetSpellBookItemName(i, BOOKTYPE_SPELL or "spell")
                local kind, id
                if GetSpellBookItemInfo then kind, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL or "spell") end
                if name and (not kind or kind == "SPELL") then found[name] = {index=i,id=id} end
            end
        end
    elseif C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
        local bank = Enum.SpellBookSpellBank.Player
        for tab=1,C_SpellBook.GetNumSpellBookSkillLines() do
            local line=C_SpellBook.GetSpellBookSkillLineInfo(tab)
            for i=line.itemIndexOffset+1,line.itemIndexOffset+line.numSpellBookItems do
                local info=C_SpellBook.GetSpellBookItemInfo(i,bank)
                if info and info.spellID and not info.isPassive then
                    local name=SpellInfo(info.spellID)
                    if name then found[name]={index=i,id=info.spellID} end
                end
            end
        end
    end
    return found
end
function ns.RefreshReference()
    local db=ns.GetSettings and ns.GetSettings()
    if not db then return end
    local _, token=UnitClass("player");class=token
    choices={};selected=nil
    local learned=Book()
    for _, id in ipairs(candidates[class] or {}) do
        if id == "MELEE" then
            choices[#choices+1]={key=id,name="근접 5 (거리 추정)",melee=true}
        else
            local name=SpellInfo(id)
            local entry=name and learned[name]
            if entry then
                local actual=entry.id or id
                local _, minimum=SpellInfo(actual)
                choices[#choices+1]={key=id,id=actual,index=entry.index,name=name,minimum=minimum or 0}
            end
        end
    end
    local custom=db.referenceByClass and db.referenceByClass[class]
    if custom then
        for _, entry in ipairs(choices) do if entry.key == custom then selected=entry;break end end
        -- A missing manually selected spell must not silently change the reference.
        if not selected then return end
    elseif class == "DRUID" and UnitPowerType then
        local power=UnitPowerType("player")
        local wanted=power==3 and 1082 or (power==1 and 6807)
        if wanted then
            for _, entry in ipairs(choices) do if entry.key==wanted then selected=entry;break end end
            if not selected then for _,entry in ipairs(choices) do if entry.melee then selected=entry;break end end end
        end
    end
    selected=selected or choices[1]
end
function ns.ReferenceName()
    local db=ns.GetSettings()
    local manual=db.referenceByClass and db.referenceByClass[class]
    return (manual and "직접: " or "자동: ") .. (selected and selected.name or "판별 가능한 기술 없음")
end
function ns.CycleReference(reset)
    local db=ns.GetSettings()
    if not class then ns.RefreshReference() end
    if not class then return end
    db.referenceByClass=db.referenceByClass or {}
    if reset then db.referenceByClass[class]=nil
    else
        local current=db.referenceByClass[class]
        local nextIndex=1
        for i,entry in ipairs(choices) do if entry.key==current then nextIndex=i+1;break end end
        db.referenceByClass[class]=choices[nextIndex] and choices[nextIndex].key or nil
    end
    ns.RefreshReference()
    ns.ApplySettings()
end
function ns.ReferenceState(unit, low, high)
    if not selected then return "unknown" end
    if selected.melee then
        if type(high)=="number" and high<=5 then return "in" end
        if type(low)=="number" and low>=5 then return "out" end
        return "unknown"
    end
    local ok,value
    if IsSpellInRange and selected.index then
        ok,value=pcall(IsSpellInRange,selected.index,BOOKTYPE_SPELL or "spell",unit)
    elseif C_Spell and C_Spell.IsSpellInRange then
        ok,value=pcall(C_Spell.IsSpellInRange,selected.id,unit)
    end
    if not ok or (issecretvalue and issecretvalue(value)) then return "unknown" end
    if value==true or value==1 then return "in" end
    if value==false or value==0 then
        if selected.minimum>0 then
            if type(high)=="number" and high<selected.minimum then return "near" end
            if type(low)~="number" or low<selected.minimum then return "unknown" end
        end
        return "out"
    end
    return "unknown"
end
