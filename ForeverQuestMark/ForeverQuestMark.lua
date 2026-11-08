-- ForeverQuestMark: quest icon on nameplates. Reads the unit tooltip data for quest objective lines.
local _, ns = ...
local icons = {}
local Relayout -- defined below, referenced by the event handler
-- Saved variables load after this file runs, so adopt them on ADDON_LOADED (see bottom).
local DEFAULTS = { kill = "Crosshair_Attack_32", loot = "Crosshair_pickup_32", anchor = "RIGHT", ox = 34, oy = 0, size = 20,
    enabled = true, progress = true, hideInInstances = false }
local DB = setmetatable({}, { __index = DEFAULTS })

-- The "N/M" count of an objective line, in any locale: English puts it first ("3/8 Boar slain"), French last
-- ("Sanglier tués : 3/8"). A count at either end wins over digits inside a name; else the last one in the line.
local function CountOf(text)
    local have, need = text:match("^%s*(%d+)%s*/%s*(%d+)")
    if not have then have, need = text:match("(%d+)%s*/%s*(%d+)%s*$") end
    if not have then
        for h, n in text:gmatch("(%d+)%s*/%s*(%d+)") do have, need = h, n end
    end
    return tonumber(have), tonumber(need)
end
ns.CountOf = CountOf

-- The client's own kill-objective format (QUEST_MONSTERS_KILLED, "%2$d/%3$d %1$s slain" in English) as Lua patterns,
-- or nil when the locale's kill and loot formats can't be told apart.
local function FormatPattern(fmt)
    local pat = fmt:gsub("%%%d*%$?([sd])", "\1%1"):gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
    pat = pat:gsub("\1s", ".-"):gsub("\1d", "%%d+"):gsub("%s+", "%%s*")
    return "^%s*" .. pat .. "%s*$"
end
-- frFR ends in "|4personnage tué:personnages tués;", a singular:plural choice the client fills in: one pattern per word
local function FormatPatterns(fmt)
    if type(fmt) ~= "string" or fmt == "" then return end
    local one, many = fmt:gsub("|4([^:;]*):?([^;]*);", "%1"), fmt:gsub("|4([^:;]*):?([^;]*);", "%2")
    return { FormatPattern(one), FormatPattern(many) }
end
local killPatterns
local function IsKillText(text)
    if killPatterns == nil then
        local kill, loot = FormatPatterns(QUEST_MONSTERS_KILLED), FormatPatterns(QUEST_OBJECTS_FOUND)
        killPatterns = kill and not (loot and kill[1] == loot[1]) and kill or false
    end
    if not killPatterns then return false end
    for _, pat in ipairs(killPatterns) do if text:find(pat) then return true end end
    return false
end
ns.IsKillText = IsKillText

-- The objective kind ("monster", "item"...) of a tooltip objective line, from the quest log objective with the same
-- text; failing that, the same words once the count, spaces and punctuation are left out ("Sanglier tués 3/8" and
-- "Sanglier tués : 3/8" are one objective).
local function Bare(text) return (text:gsub("%d+%s*/%s*%d+", ""):gsub("[%p%s]", ""):lower()) end
-- The quest log objective with the same text (see above), or nil.
local function ObjectiveOf(text)
    local bare, loose = Bare(text)
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader then
            for _, o in ipairs(C_QuestLog.GetQuestObjectives(info.questID) or {}) do
                if o.text == text then return o end
                if not loose and o.text and bare ~= "" and Bare(o.text) == bare then loose = o end
            end
        end
    end
    return loose
end
local function KindOf(text)
    local o = ObjectiveOf(text)
    return o and o.type
end

-- True when a group tooltip's player header names you. Forever gives characters a first and a last name, and UnitName
-- returns them apart ("El", "Beskido") while the header shows "El Beskido"; elsewhere the second value is a realm.
local function IsMe(who)
    who = who:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s*%-?%s*", ""):gsub("%s*:?%s*$", "")
    local first, last = UnitName("player")
    if last and last ~= "" and (who == first .. " " .. last or who == first .. "-" .. last) then return true end
    return who == first
end

-- True when the client hides a value from addons (instances, combat restrictions): it can't be matched or branched on.
local function IsSecret(v) return issecretvalue ~= nil and issecretvalue(v) end

-- Returns texture path and progress text for the first incomplete objective, or nil. A third value, "secret", means the
-- tooltip can't be read and the caller should use LogGuess.
-- Locale-free: the count is found anywhere in the line, and kill vs loot comes from the quest log objective's type,
-- falling back to the client's localized kill format. The tooltip only says which objective the unit belongs to; the
-- count comes from the quest log, which is current when the tooltip is stale (combat, groups).
local function QuestInfo(unit)
    local data = C_TooltipInfo and C_TooltipInfo.GetUnit and C_TooltipInfo.GetUnit(unit)
    if not data then return end
    if TooltipUtil and TooltipUtil.SurfaceArgs then TooltipUtil.SurfaceArgs(data) end
    local types = Enum.TooltipDataLineType
    local mine = true -- in a group, the tooltip lists each member's lines under their name; only yours count
    for _, line in ipairs(data.lines or {}) do
        if TooltipUtil and TooltipUtil.SurfaceArgs then TooltipUtil.SurfaceArgs(line) end
        if IsSecret(line.leftText) then return nil, nil, "secret" end
        if types.QuestPlayer and line.type == types.QuestPlayer and line.leftText then
            mine = IsMe(line.leftText)
        elseif mine and line.type == types.QuestObjective and line.leftText then
            local text = line.leftText
            local have, need = CountOf(text)
            local o = ObjectiveOf(text)
            if o and o.numRequired and o.numRequired > 1 and o.numFulfilled then
                have, need = o.numFulfilled, o.numRequired
            end
            if not (o and o.finished) and (not have or have < need) then
                local kind = o and o.type
                local kill = kind == "monster" or (kind == nil and IsKillText(text))
                return kill and DB.kill or DB.loot, have and (have .. "/" .. need) or ""
            end
        end
    end
end

-- Instance fallback: tooltips are secret there, so guess the objective kind from the quest log.
-- Picks the incomplete objective whose text names the unit, else one kind if all quests on this map agree.
-- Returns atlas and progress text ("" when unsure which objective it is).
local function LogGuess(unit)
    local name = UnitName(unit)
    if issecretvalue and issecretvalue(name) then name = nil end
    local kinds, only, count = {}, nil, 0
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and info.isOnMap then
            for _, o in ipairs(C_QuestLog.GetQuestObjectives(info.questID) or {}) do
                if not o.finished and (o.type == "monster" or o.type == "item") then
                    local icon = o.type == "monster" and DB.kill or DB.loot
                    local prog = o.numRequired and o.numRequired > 1 and (o.numFulfilled .. "/" .. o.numRequired) or ""
                    if name and o.text and o.text:find(name, 1, true) then return icon, prog end
                    kinds[icon] = true
                    count = count + 1
                    only = { icon, prog }
                end
            end
        end
    end
    if count == 1 then return only[1], only[2] end
    if kinds[DB.kill] and not kinds[DB.loot] then return DB.kill, "" end
    if kinds[DB.loot] and not kinds[DB.kill] then return DB.loot, "" end
    return DB.loot, "" -- mixed or unknown: loot is the likelier kind for a named-but-unmatched mob
end

-- Where the mark sits, relative to the nameplate's health bar. Each spot: the mark's point, the bar's point, the gap a new
-- pick starts from, and which side of the mark the progress text goes.
local SPOTS = {
    LEFT     = { "RIGHT", "LEFT", -6, 0, "LEFT" },
    TOPLEFT  = { "BOTTOMLEFT", "TOPLEFT", 0, 16, "RIGHT" },
    TOP      = { "BOTTOM", "TOP", 0, 16, "RIGHT" },
    TOPRIGHT = { "BOTTOMRIGHT", "TOPRIGHT", 0, 16, "RIGHT" },
    RIGHT    = { "LEFT", "RIGHT", 34, 0, "RIGHT" },   -- clear of the level badge (set in game)
}
ns.SPOTS = SPOTS

-- The plate's health bar (Blizzard_NamePlates: UnitFrame.HealthBarsContainer, on retail and Forever alike); the plate
-- itself when another nameplate addon replaced it.
local function BarOf(plate)
    local uf = plate.UnitFrame
    local bar = uf and uf.HealthBarsContainer
    return type(bar) == "table" and bar.GetObjectType and bar or plate
end

-- Forever's level badge, when it shows. Blizzard shrinks the bar to make room for it and puts it right of the bar
-- (Camelot NameplateLevelFrame: LEFT on the bar's RIGHT, 5px gap), so the plate's right end is the badge, not the bar.
local function EdgeOf(plate)
    local uf = plate.UnitFrame
    local lvl = uf and uf.PlayerLevelDiffFrame
    if type(lvl) ~= "table" or not lvl.IsShown then return end
    local ok, shown = pcall(lvl.IsShown, lvl)
    if not ok or shown ~= true then return end
    local pok, _, _, relPoint = pcall(lvl.GetPoint, lvl, 1)
    if pok and relPoint == "RIGHT" then return lvl end
end
ns.BarOf, ns.EdgeOf = BarOf, EdgeOf

-- Puts mark f by the plate the way the settings say: around a box from the bar's left end to the badge's right end (the
-- bar's when there's no badge). The settings preview places its sample marks with this too.
local function Place(f, bar, edge)
    local s = SPOTS[DB.anchor] or SPOTS.RIGHT
    local box = f.box
    if not box then
        box = CreateFrame("Frame", nil, f:GetParent())
        f.box = box
    end
    box:ClearAllPoints()
    -- the badge is centred on the bar's height, so left and right middles line up
    local ok = pcall(box.SetPoint, box, "LEFT", bar, "LEFT")
    ok = ok and pcall(box.SetPoint, box, "RIGHT", edge or bar, "RIGHT")
    local hok, h = pcall(bar.GetHeight, bar)
    box:SetHeight(hok and type(h) == "number" and not (issecretvalue and issecretvalue(h)) and h > 0 and h or 13)
    if not ok then box:ClearAllPoints(); box:SetAllPoints(f:GetParent()) end
    f:SetSize(DB.size, DB.size)
    f:ClearAllPoints()
    f:SetPoint(s[1], box, s[2], DB.ox, DB.oy)
    f.text:ClearAllPoints()
    if s[5] == "LEFT" then f.text:SetPoint("RIGHT", f, "LEFT", -2, 0) else f.text:SetPoint("LEFT", f, "RIGHT", 2, 0) end
end
ns.Place = Place

local function GetIcon(plate)
    if icons[plate] then return icons[plate] end
    local f = CreateFrame("Frame", nil, plate)
    f.tex = f:CreateTexture(nil, "OVERLAY")
    f.tex:SetAllPoints()
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    Place(f, BarOf(plate), EdgeOf(plate))
    icons[plate] = f
    return f
end

-- Optional: turn marks off inside instances, where the icon kind is only a guess (see LogGuess).
local function Suppressed()
    if not DB.enabled then return true end
    if not DB.hideInInstances then return false end
    local _, instanceType = IsInInstance()
    return instanceType and instanceType ~= "none"
end

local function Update(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end
    local icon = GetIcon(plate)
    Place(icon, BarOf(plate), EdgeOf(plate))   -- the badge comes and goes with the unit
    if Suppressed() then icon:Hide(); return end
    if UnitIsUnit(unit, "player") then icon:Hide(); return end
    local ok, tex, progress, secret = pcall(QuestInfo, unit)
    if ok and not secret then
        if tex then
            icon.tex:SetAtlas(tex)
            icon.text:SetText(DB.progress and progress or "")
            icon:Show()
        else
            icon:Hide()
        end
        return
    end
    -- Tooltip lines are secret (seen in dungeons), or reading them failed: fall back to a yes/no quest check, no kind or progress.
    local related = C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(unit)
    local gok, atlas, prog = pcall(LogGuess, unit)
    icon.tex:SetAtlas(gok and atlas or DB.loot)
    icon.text:SetText(gok and DB.progress and prog or "")
    if issecretvalue and issecretvalue(related) then
        -- can't branch on a secret boolean, but SetShown may accept one; hide if it doesn't
        if not pcall(icon.SetShown, icon, related) then icon:Hide() end
    else
        icon:SetShown(related and true or false)
    end
end

-- Runs at most every 0.2s: a burst of QUEST_LOG_UPDATE (or the 0.3s re-run after one) coalesces into one trailing pass.
local lastRun, queued = -1, false
local shownUnits = {}   -- nameplate unit tokens on screen now (NAME_PLATE_UNIT_ADDED until _REMOVED)
local function UpdateAll()
    local wait = lastRun + 0.2 - GetTime()
    if wait > 0 then
        if not queued then
            queued = true
            C_Timer.After(wait, function() queued = false; UpdateAll() end)
        end
        return
    end
    lastRun = GetTime()
    -- the units we were told about, not plate.namePlateUnitToken: the client doesn't always fill that in, and then a
    -- mark drawn when the plate appeared kept its first count for good
    for unit in pairs(shownUnits) do Update(unit) end
end

-- Before 1.4 the mark sat right of the whole plate (x, y from its right edge). The bar, or the level badge after it, ends
-- 12px in from that edge and sits about 8px below the plate's middle, so a moved mark stays about where it was.
local function Migrate(t)
    if t.x == nil and t.y == nil then return end
    if rawget(t, "anchor") == nil then
        t.anchor = "RIGHT"
        t.ox = (tonumber(t.x) or 4) + 12
        t.oy = (tonumber(t.y) or -8) + 8
    end
    t.x, t.y = nil, nil
end

ns.Kit.StampOnLogout(function() return DB end)
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("NAME_PLATE_UNIT_ADDED")
ev:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
ev:RegisterEvent("QUEST_LOG_UPDATE")
ev:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
ev:RegisterEvent("PLAYER_ENTERING_WORLD") -- zoning in or out of an instance
ev:RegisterEvent("PLAYER_REGEN_ENABLED") -- tooltips go stale during combat; refresh once it ends
ev:SetScript("OnEvent", function(_, event, unit)
    if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
        -- adopt the saved table; some clients deliver it later than ADDON_LOADED
        if event == "PLAYER_LOGIN" or unit == "ForeverQuestMark" then
            -- account-wide saved variables do not load at login on this client; a per-character mirror does
            local src = ns.Kit.PickSaved(DB, ForeverQuestMarkDB, ForeverQuestMarkDBC)   -- newest copy (see Kit.lua)
            if src then Mixin(DB, src) end
            Migrate(DB)
            ForeverQuestMarkDB, ForeverQuestMarkDBC = DB, DB
            if next(icons) then Relayout() end
        end
        -- marks sit on nameplates; with enemy nameplates off (V) there is nothing to show them on
        if event == "PLAYER_LOGIN" and DB.enabled and C_CVar and not C_CVar.GetCVarBool("nameplateShowEnemies") then
            print("|cff33ff99ForeverQuestMark|r: enemy nameplates are turned off, so quest marks can't show. Press V to turn them on.")
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then shownUnits[unit] = true; Update(unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        shownUnits[unit] = nil
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate and icons[plate] then icons[plate]:Hide() end
    else
        UpdateAll()
        -- the log's counts land a moment after the event; look again
        if event == "QUEST_LOG_UPDATE" then C_Timer.After(0.3, UpdateAll) end
    end
end)

function Relayout()
    for plate, f in pairs(icons) do Place(f, BarOf(plate), EdgeOf(plate)) end
    UpdateAll()
end

-- Settings (Options > AddOns) ----------------------------------------------------------------------------------------
-- One page in the Forever look: on/off with what's happening now, a preview of two nameplates where the mark can be put
-- by clicking a spot or dragged, then placement, icons and instances. Built with the shared kit (Kit.lua, KitUI.lua).
local Kit = ns.Kit
local Make, Tooltip = Kit.Make, Kit.Tooltip
local front = Kit.NewPage("Forever Quest Mark")
local page = Kit.NewPage("Marks")
ns.page, ns.front = page, front
local function Set(key) return function(v) DB[key] = v; Relayout() end end
local function Get(key) return function() return DB[key] end end
local function Px(v) return ("%d px"):format(v) end

-- Moves the mark to another spot, starting from that spot's own gap.
local function PickSpot(key)
    local s = SPOTS[key]
    DB.anchor, DB.ox, DB.oy = key, s[3], s[4]
    Relayout()
    page:Refresh()
end
ns.PickSpot = PickSpot

local SPOT_LABELS = {
    { "LEFT", "Left", "Left of the bar." }, { "TOPLEFT", "Above left", "Over the left end of the bar." },
    { "TOP", "Above", "Over the middle of the bar, under or over the name." },
    { "TOPRIGHT", "Above right", "Over the right end of the bar." }, { "RIGHT", "Right", "Right of the bar." },
}

-- Blizzard atlases that read well as a quest mark; ones missing on this client are skipped.
local ICONS = { "Crosshair_Attack_32", "Crosshair_pickup_32", "Crosshair_Quest_32", "Crosshair_lootall_32",
    "Crosshair_Interact_32", "QuestNormal", "QuestDaily", "QuestBonusObjective", "Islands-QuestBang" }
local function IconOptions()
    local out, seen = {}, {}
    for _, atlas in ipairs(ICONS) do
        if C_Texture.GetAtlasInfo(atlas) then
            out[#out + 1] = { atlas, ("|A:%s:18:18|a  %s"):format(atlas, atlas) }
            seen[atlas] = true
        end
    end
    -- keep a custom atlas set by /fqm selectable
    for _, key in ipairs({ "kill", "loot" }) do
        if not seen[DB[key]] then out[#out + 1] = { DB[key], ("|A:%s:18:18|a  %s"):format(DB[key], DB[key]) }; seen[DB[key]] = true end
    end
    return out
end

-- What's happening right now, in one line.
local function StatusLine()
    if not DB.enabled then return "|cff9d9d9dQuest marks are off.|r" end
    if C_CVar and not C_CVar.GetCVarBool("nameplateShowEnemies") then
        return "|cffffd100Enemy nameplates are off|r, so there's nothing to put marks on. Press V to turn them on."
    end
    if Suppressed() then return "Inside an instance: marks are hidden here (see Instances below)." end
    local shown = 0
    for _, f in pairs(icons) do if f:IsShown() and f:GetParent():IsShown() then shown = shown + 1 end end
    return ("Right now: |cffffd100%d|r %s on nameplates around you."):format(shown, shown == 1 and "mark" or "marks")
end

page:Card(nil, 70, function(card, pg)
    pg:CheckAt(card, 10, -8, "Enabled", Get("enabled"), Set("enabled"), "Show quest marks on nameplates.")
    local now = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    now:SetPoint("TOPLEFT", 16, -44)
    now:SetPoint("RIGHT", -14, 0)
    now:SetJustifyH("LEFT")
    local t = 0
    card:SetScript("OnUpdate", function(_, dt) t = t - dt; if t <= 0 then t = 0.5; now:SetText(StatusLine()) end end)
    pg:OnRefresh(function() now:SetText(StatusLine()) end)
end)

-- The preview: two nameplates drawn with Blizzard's own art the way Forever lays them out (Blizzard_NamePlates,
-- Camelot): the name in white over the bar, the bar in UI-HUD-CoolDownManager-Bar on its -BG frame, the level badge 5px
-- right of the bar. With a nameplate on screen the samples copy its size and scale; without one, Forever's defaults.
-- Each mark is placed by the same Place() as the real ones.
local DEFAULT_LOOK = { barW = 133, barH = 20, lvlW = 28, lvlH = 23, gap = 5, badge = true, scale = 1 }
local function Num(v) return type(v) == "number" and not (issecretvalue and issecretvalue(v)) and v end
-- the size of a real nameplate on screen, in its own units, and how much bigger the game draws it than this page
local function LiveLook(stage)
    for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do
        local bar = BarOf(plate)
        local ok, w, h = pcall(function() return bar:GetWidth(), bar:GetHeight() end)
        w, h = ok and Num(w), ok and Num(h)
        if bar ~= plate and w and h and w > 20 and h > 2 and plate:IsShown() then
            local look = { barW = w, barH = h, live = true, badge = false }
            local lvl = EdgeOf(plate)
            if lvl then
                local _, _, _, gap = lvl:GetPoint(1)
                look.badge, look.lvlW, look.lvlH, look.gap = true, Num(lvl:GetWidth()) or 28, Num(lvl:GetHeight()) or 23, Num(gap) or 5
            end
            local pe, se = Num(bar:GetEffectiveScale()), Num(stage:GetEffectiveScale())
            look.scale = pe and se and se > 0 and pe / se or 1
            return look
        end
    end
    return DEFAULT_LOOK
end
ns.LiveLook = LiveLook

local SAMPLES = {
    { name = "Kobold Vermin", icon = "kill", progress = "3/8", health = 0.72, diff = 0 },
    { name = "Defias Thug", icon = "loot", progress = "1/5", health = 0.4, diff = 2 },
}
local dragging   -- the sample mark being dragged: { f, x, y, ox, oy } at the start

local function Atlas(tex, name, fallback)
    if C_Texture.GetAtlasInfo(name) then tex:SetAtlas(name) else tex:SetColorTexture(unpack(fallback)) end
end

local function SamplePlate(stage, s)
    local plate = CreateFrame("Frame", nil, stage)
    plate:SetSize(190, 60)
    local bar = CreateFrame("Frame", nil, plate)
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    Atlas(bg, "UI-HUD-CoolDownManager-Bar-BG", { 0, 0, 0, 0.8 })
    bg:SetPoint("TOPLEFT", -2, 3)
    bg:SetPoint("BOTTOMRIGHT", 6, -6)
    bar.fill = bar:CreateTexture(nil, "ARTWORK")
    Atlas(bar.fill, "UI-HUD-CoolDownManager-Bar", { 1, 1, 1, 1 })
    bar.fill:SetVertexColor(1, 0, 0)   -- a hostile NPC's bar (CompactUnitFrame_UpdateHealthColor)
    bar.fill:SetPoint("TOPLEFT")
    bar.fill:SetPoint("BOTTOMLEFT")
    plate.bar = bar

    local lvl = CreateFrame("Frame", nil, plate)
    lvl:SetPoint("LEFT", bar, "RIGHT", 5, 0)
    local icon = lvl:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    Atlas(icon, "ui-hud-nameplates-levelindicator", { 0.1, 0.1, 0.1, 0.9 })
    lvl.text = lvl:CreateFontString(nil, "OVERLAY", _G.SystemFont_NamePlateLevel and "SystemFont_NamePlateLevel" or "GameFontNormalSmall")
    lvl.text:SetPoint("CENTER")
    local level = (UnitLevel("player") or 1) + s.diff
    lvl.text:SetText(level)
    local c = s.diff >= 3 and _G.DIFFICULT_DIFFICULTY_COLOR or _G.FAIR_DIFFICULTY_COLOR
    if c then lvl.text:SetTextColor(c.r, c.g, c.b) end
    plate.lvl = lvl

    -- the name: Forever centres it over the bar and badge, white with an outline
    local name = plate:CreateFontString(nil, "OVERLAY", _G.SystemFont_NamePlate and "SystemFont_NamePlate" or "GameFontNormal")
    local font, size = name:GetFont()
    if font then name:SetFont(font, size, "OUTLINE") end
    name:SetTextColor(1, 1, 1)
    name:SetJustifyH("CENTER")
    name:SetWordWrap(false)
    name:SetText(s.name)
    plate.name = name

    local f = CreateFrame("Frame", nil, plate)
    f:SetFrameLevel(lvl:GetFrameLevel() + 3)
    f.tex = f:CreateTexture(nil, "OVERLAY")
    f.tex:SetAllPoints()
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f:EnableMouse(true)
    f:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local x, y = GetCursorPosition()
        dragging = { self, x, y, DB.ox, DB.oy }
    end)
    f:SetScript("OnMouseUp", function() dragging = nil; page:Refresh() end)
    Tooltip(f, "Quest mark", "Drag to move it. Click a dot around the bar to put it somewhere else.")
    plate.mark = f

    -- the spots, as small dots where a mark would land from each
    plate.spots = {}
    for _, sp in ipairs(SPOT_LABELS) do
        local key = sp[1]
        local b = CreateFrame("Button", nil, plate)
        b:SetSize(14, 14)
        b:SetFrameLevel(f:GetFrameLevel() + 1)
        b.dot = b:CreateTexture(nil, "ARTWORK")
        b.dot:SetSize(8, 8)
        b.dot:SetPoint("CENTER")
        b.dot:SetColorTexture(1, 1, 1, 1)
        if b.dot.SetRotation then b.dot:SetRotation(math.pi / 4) end
        b:SetScript("OnClick", function() PickSpot(key); PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end)
        Tooltip(b, sp[2], sp[3])
        b.key = key
        plate.spots[#plate.spots + 1] = b
    end
    return plate
end

-- Lays a sample out like the look says.
local function Shape(p, look)
    local bar, lvl = p.bar, p.lvl
    bar:SetSize(look.barW, look.barH)
    bar:ClearAllPoints()
    bar:SetPoint("LEFT", p, "LEFT", 12, -8)
    bar.fill:SetWidth(math.max(1, look.barW * p.sample.health))
    lvl:SetShown(look.badge)
    lvl:SetSize(look.lvlW or 28, look.lvlH or 23)
    lvl:ClearAllPoints()
    lvl:SetPoint("LEFT", bar, "RIGHT", look.gap or 5, 0)
    local right = look.badge and lvl or bar
    p.name:ClearAllPoints()
    p.name:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 2)
    p.name:SetPoint("RIGHT", right, "RIGHT", 0, 0)
    p.edge = look.badge and lvl or nil
end

page:Preview(250, function(stage)
    if not stage.plates then
        stage.plates = {}
        for i, s in ipairs(SAMPLES) do
            local p = SamplePlate(stage, s)
            p.sample = s
            stage.plates[i] = p
        end
        local hint = stage:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("BOTTOMLEFT", 10, 8)
        hint:SetPoint("RIGHT", -10, 0)
        hint:SetJustifyH("LEFT")
        stage.hint = hint
    end
    if dragging then
        local f, x0, y0, ox, oy = unpack(dragging)
        local x, y = GetCursorPosition()
        local scale = f:GetEffectiveScale()
        if not IsMouseButtonDown or IsMouseButtonDown("LeftButton") then
            DB.ox = math.max(-60, math.min(60, math.floor(ox + (x - x0) / scale + 0.5)))
            DB.oy = math.max(-60, math.min(60, math.floor(oy + (y - y0) / scale + 0.5)))
            Relayout()
        else
            dragging = nil
            page:Refresh()
        end
    end
    local look = LiveLook(stage)
    stage.hint:SetText((look.live and "Drawn like the nameplates on your screen, at their size."
        or "Drawn at Forever's default nameplate size. With a nameplate on screen, the preview copies it.")
        .. "  Click a dot to move the mark, or drag it.")
    -- one plate per row, as big as the game draws them unless that wouldn't fit
    local w, h = stage:GetWidth(), stage:GetHeight()
    if not (Num(w) and w > 0 and Num(h) and h > 0) then return end
    local n = #stage.plates
    local content = look.barW + (look.badge and (look.gap + look.lvlW) or 0)
    local rowH = (h - 24) / n
    local scale = math.max(0.3, math.min(look.scale or 1, w / (content + 2 * (DB.size + 40)), rowH / (look.barH + DB.size + 34)))
    for i, p in ipairs(stage.plates) do
        Shape(p, look)
        p:SetScale(scale)
        p:ClearAllPoints()
        -- bar and badge centred across the stage, the bar a little below the middle of its row (room for the name)
        local cx, cy = w / 2, -(rowH * (i - 1) + rowH * 0.62)
        p:SetPoint("LEFT", stage, "TOPLEFT", cx / scale - 12 - content / 2, (cy + 8 * scale) / scale)
        local f = p.mark
        Place(f, p.bar, p.edge)
        f.tex:SetAtlas(DB[p.sample.icon])
        f.text:SetText(DB.progress and p.sample.progress or "")
        f:SetAlpha(DB.enabled and 1 or 0.35)
        -- each dot where a mark of this size would land from that spot; the chosen spot is the mark itself
        local halfSize = DB.size / 2
        for _, b in ipairs(p.spots) do
            local at = SPOTS[b.key]
            local dx = at[1]:find("LEFT") and halfSize or at[1]:find("RIGHT") and -halfSize or 0
            local dy = at[1]:find("BOTTOM") and halfSize or at[1]:find("TOP") and -halfSize or 0
            b:ClearAllPoints()
            b:SetPoint("CENTER", f.box, at[2], at[3] + dx, at[4] + dy)
            b:SetShown(i == 1 and b.key ~= DB.anchor)
            b.dot:SetVertexColor(1, 0.82, 0, 0.7)
        end
    end
end)

-- A row of small tabs, gold when chosen (the look of Forever Immersion's switches).
local function Tabs(parent, items, get, pick)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(22)
    row.tabs = {}
    local x = 0
    for _, it in ipairs(items) do
        local tab = CreateFrame("Button", nil, row)
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tab.text:SetPoint("CENTER")
        tab.text:SetText(it[2])
        tab:SetSize(math.max(46, tab.text:GetStringWidth() + 18), 22)
        tab:SetPoint("LEFT", x, 0)
        x = x + tab:GetWidth() + 4
        tab.fill = tab:CreateTexture(nil, "BACKGROUND")
        tab.fill:SetAllPoints()
        local hl = tab:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 1, 1, 0.08)
        tab:SetScript("OnClick", function() pick(it[1]); PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON); row:Paint() end)
        if it[3] then Tooltip(tab, it[2], it[3]) end
        tab.key = it[1]
        row.tabs[#row.tabs + 1] = tab
    end
    row:SetWidth(x)
    function row:Paint()
        local cur = get()
        for _, tab in ipairs(self.tabs) do
            local on = cur == tab.key
            tab.fill:SetColorTexture(1, on and 0.82 or 1, on and 0 or 1, on and 0.22 or 0.05)
            tab.text:SetTextColor(on and 1 or 0.75, on and 0.82 or 0.75, on and 0 or 0.75)
        end
    end
    row:Paint()
    return row
end

local function Slider(card, pg, x, y, label, minV, maxV, step, get, set, fmt)
    return pg:SliderAt(card, x, y, label, minV, maxV, step, get, set, 170, fmt, 140)
end

page:Card("Placement", 162, function(card, pg)
    local l = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    l:SetPoint("TOPLEFT", 14, -36)
    l:SetText("Next to the bar")
    local tabs = Tabs(card, SPOT_LABELS, Get("anchor"), PickSpot)
    tabs:SetPoint("TOPLEFT", 154, -31)
    pg:OnRefresh(function() tabs:Paint() end)
    Slider(card, pg, 14, -66, "Size", 10, 48, 1, Get("size"), Set("size"), Px)
    Slider(card, pg, 14, -96, "Sideways", -60, 60, 1, Get("ox"), Set("ox"), Px)
    Slider(card, pg, 14, -126, "Up and down", -60, 60, 1, Get("oy"), Set("oy"), Px)
end)

page:Card("Icons", 132, function(card, pg)
    pg:DropdownAt(card, 14, -34, "Kill objective", IconOptions, Get("kill"), Set("kill"), 220)
    pg:DropdownAt(card, 14, -66, "Loot objective", IconOptions, Get("loot"), Set("loot"), 220)
    pg:CheckAt(card, 10, -96, "Show progress", Get("progress"), Set("progress"), "Show the objective count (e.g. 3/8) next to the icon.")
end)

page:Card("Instances", 100, function(card, pg)
    pg:CheckAt(card, 10, -28, "Hide inside instances", Get("hideInInstances"), Set("hideInInstances"),
        "Turn marks off in dungeons, raids, battlegrounds and arenas.")
    local h = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    h:SetPoint("TOPLEFT", 16, -60)
    h:SetPoint("RIGHT", -14, 0)
    h:SetJustifyH("LEFT")
    h:SetText("Inside instances the game hides quest lines from addons, so the icon kind is guessed from your quest log. It can be wrong when kill and loot quests mix.")
end)

page:Card("Start over", 70, function(card, pg)
    local t = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    t:SetPoint("TOPLEFT", 14, -32)
    t:SetText("Each character keeps its own settings.")
    local reset = Make("Button", card, "UIPanelButtonTemplate")
    reset:SetSize(170, 22)
    reset:SetPoint("RIGHT", -12, 0)
    reset:SetText("Reset all settings")
    reset:SetScript("OnClick", function() wipe(DB); Relayout(); pg:Refresh() end)
    Tooltip(reset, "Reset all settings", "Back to the defaults: the mark right of the bar, 20 px, with progress.")
end)

Kit.Overview(front, {
    key = "ForeverQuestMark",
    tagline = "Puts a quest icon on the nameplate of every mob you still need for a quest: a sword to kill, a bag to loot, with your progress.",
    sections = {
        { page, "Interface/Icons/INV_Misc_QuestionMark", "Marks", "Turn marks on, where they sit on the nameplate, the icons, and instances." },
    },
})
Kit.Register(front)
Kit.Register(page, front.category)

function ForeverQuestMark_OpenSettings() Kit.Open(front) end

SLASH_FOREVERQUESTMARK1 = "/fqm"
SlashCmdList.FOREVERQUESTMARK = function(msg)
    local cmd, arg = msg:match("^(%S+)%s*(.-)$")
    if (cmd == "x" or cmd == "y") and tonumber(arg) then
        DB[cmd == "x" and "ox" or "oy"] = tonumber(arg)
    elseif cmd == "size" and tonumber(arg) then
        DB.size = tonumber(arg)
    elseif cmd == "side" and SPOTS[arg:upper()] then
        local s = SPOTS[arg:upper()]
        DB.anchor, DB.ox, DB.oy = arg:upper(), s[3], s[4]
    elseif (cmd == "kill" or cmd == "loot") and arg ~= "" then
        if not C_Texture.GetAtlasInfo(arg) then print("ForeverQuestMark: no atlas named " .. arg); return end
        DB[cmd] = arg
    elseif cmd == "reset" then
        wipe(DB)
    elseif cmd == "debug" then
        -- dump what the tooltip API returns for the target, to see why marks fail (e.g. in instances)
        local p = function(...) print("|cff33ff99FQM|r", ...) end
        local _, itype = IsInInstance()
        p("instance:", tostring(itype), "suppressed:", tostring(Suppressed()), "exists:", tostring(UnitExists("target")))
        local ok, data = pcall(C_TooltipInfo.GetUnit, "target")
        if not ok then p("GetUnit error:", data); return end
        if not data then p("GetUnit returned nil"); return end
        p("lines:", data.lines and #data.lines or "none")
        for i, line in ipairs(data.lines or {}) do
            local secret = issecretvalue and (issecretvalue(line.leftText) or issecretvalue(line.type))
            if secret then p(i, "<secret>")
            else p(i, "type", tostring(line.type), tostring(line.leftText)) end
        end
        local rel = C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest("target")
        if issecretvalue and issecretvalue(rel) then
            p("RelatedToQuest: <secret>, SetShown accepts it:", tostring((pcall(UIParent.SetShown, CreateFrame("Frame"), rel))))
        else p("RelatedToQuest:", tostring(rel)) end
        p("LogGuess:", pcall(LogGuess, "target"))
        local qok, tex, prog = pcall(QuestInfo, "target")
        p("QuestInfo:", tostring(qok), tostring(tex), tostring(prog))
        return
    else
        Kit.Open(page)
        return
    end
    Relayout()
    page:Refresh()
end
