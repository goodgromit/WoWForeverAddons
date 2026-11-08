-- The front page every Forever addon shares: what the addon does, a tile for each of its settings pages, and the
-- other Forever addons with the one you're in marked. The same file ships in every Forever addon; keep the copies equal.
local addonName, ns = ...
-- Translations where the addon ships them (ns.L from its Locale.lua), the English text otherwise.
local L = ns.L or setmetatable({}, { __index = function(_, k) return k end })
local Kit = ns.Kit

-- Every Forever addon ships all five logos, so the family row shows the real ones whichever addons are installed.
local function Logo(key) return "Interface/AddOns/" .. addonName .. "/Media/Family/" .. key end

-- Every Forever addon, in the order the family row shows them. open: the global an older version offers instead.
local FAMILY = {
    { "ForeverImmersion", "Forever Immersion", Logo("ForeverImmersion"),
        L["Fades your UI out of the way until you need it."], "ForeverImmersion_OpenSettings" },
    { "ForeverJournal", "Forever Journal", Logo("ForeverJournal"),
        L["A journal of your character's story, with goals."], "ForeverJournal_OpenSettings" },
    { "ForeverQuestMark", "Forever Quest Mark", Logo("ForeverQuestMark"),
        L["Quest icons on the nameplates of mobs you need."], "ForeverQuestMark_OpenSettings" },
    { "ForeverPaladinCooldownTracker", "Forever Cooldown Tracker", Logo("ForeverPaladinCooldownTracker"),
        L["Cooldowns, buff timers and reminders for every class."], "ForeverPaladinCooldownTracker_OpenSettings" },
    { "ForeverMove", "Forever Move", Logo("ForeverMove"),
        L["Drag any Blizzard window, and it stays where you put it."], "ForeverMove_OpenSettings" },
}
Kit.FAMILY = FAMILY

-- Front pages register here by addon name, so each addon can open the others' settings.
ForeverFamily = ForeverFamily or {}

local PAD, GAP = 16, 8
local GOLD = { 1, 0.82, 0 }

local function Box(parent, a, edge)
    local f = CreateFrame("Button", nil, parent)
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetColorTexture(1, 1, 1, a)
    f.edges = {}
    for _, s in ipairs({ { "TOPLEFT", "TOPRIGHT", false }, { "BOTTOMLEFT", "BOTTOMRIGHT", false }, { "TOPLEFT", "BOTTOMLEFT", true }, { "TOPRIGHT", "BOTTOMRIGHT", true } }) do
        local t = f:CreateTexture(nil, "BORDER")
        t:SetColorTexture(edge[1], edge[2], edge[3], edge[4])
        t:SetPoint(s[1]); t:SetPoint(s[2])
        if s[3] then t:SetWidth(1) else t:SetHeight(1) end
        f.edges[#f.edges + 1] = t
    end
    return f
end

local function Icon(parent, size, path)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetSize(size, size)
    -- Blizzard icons carry a baked-in border worth trimming; our logos have their own rounded frame, so show them whole
    if not (type(path) == "string" and path:find("^Interface/AddOns/")) then t:SetTexCoord(0.07, 0.93, 0.07, 0.93) end
    t:SetTexture(path)
    return t
end

local function Hover(b)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.06)
end

local function Loaded(name)
    if not (C_AddOns and C_AddOns.IsAddOnLoaded) then return false end
    local ok, v = pcall(C_AddOns.IsAddOnLoaded, name)
    return ok and v and true or false
end

local function Meta(name, field)
    if not (C_AddOns and C_AddOns.GetAddOnMetadata) then return nil end
    local ok, v = pcall(C_AddOns.GetAddOnMetadata, name, field)
    return ok and v or nil
end

local function OpenCategory(cat)
    if cat and Settings and Settings.OpenToCategory then Settings.OpenToCategory(cat:GetID()) end
end

local function OpenAddon(entry)
    local page = ForeverFamily[entry[1]]
    if page and page.category then OpenCategory(page.category)
    elseif type(_G[entry[5]]) == "function" then _G[entry[5]]() end
end

local function Heading(page, title)
    local b = page:AddBlock(30, 16)
    local t = b:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    t:SetPoint("BOTTOMLEFT", PAD + 4, 6)
    t:SetText(title)
    return b
end

-- Lays tiles out in columns across block b whenever its width changes.
local function Grid(b, tiles, cols, tileH)
    local function Place(w)
        if not w or w <= 0 then return end
        local tileW = (w - 2 * PAD - (cols - 1) * GAP) / cols
        for i, t in ipairs(tiles) do
            local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", PAD + col * (tileW + GAP), -row * (tileH + GAP))
            t:SetSize(tileW, tileH)
        end
    end
    b:SetHeight(math.ceil(#tiles / cols) * (tileH + GAP) - GAP)
    b:SetScript("OnSizeChanged", function(_, w) Place(w) end)
end

-- spec = { key = "ForeverQuestMark", tagline = "what it does", sections = { { page, icon, title, text } } }
-- Call it first on the addon's main page; settings the main page had belong on a section page now.
function Kit.Overview(page, spec)
    ForeverFamily[spec.key] = page
    local me
    for _, f in ipairs(FAMILY) do if f[1] == spec.key then me = f end end

    -- Top: the addon's icon, what it does and its version.
    local top = page:AddBlock(62, 0)
    local icon = Icon(top, 48, spec.icon or (me and me[3]))
    icon:SetPoint("TOPLEFT", PAD + 4, -4)
    local tag = top:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tag:SetPoint("TOPLEFT", icon, "TOPRIGHT", 14, -4)
    tag:SetPoint("RIGHT", top, "RIGHT", -PAD, 0)
    tag:SetJustifyH("LEFT")
    tag:SetText(spec.tagline or (me and me[4]) or "")
    local ver = top:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    ver:SetPoint("TOPLEFT", tag, "BOTTOMLEFT", 0, -6)
    local v = Meta(spec.key, "Version")
    ver:SetText(v and ("Version " .. v) or "")

    -- Middle: a tile for each settings page of this addon.
    if spec.sections and #spec.sections > 0 then
        Heading(page, L["Settings"])
        local b = page:AddBlock(1, 4)
        local tiles = {}
        for _, s in ipairs(spec.sections) do
            local t = Box(b, 0.03, { 1, 1, 1, 0.08 })
            Hover(t)
            local ic = Icon(t, 32, s[2])
            ic:SetPoint("LEFT", 12, 0)
            local name = t:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            name:SetPoint("TOPLEFT", ic, "TOPRIGHT", 12, 1)
            name:SetPoint("RIGHT", -28, 0)
            name:SetJustifyH("LEFT")
            name:SetText(s[3])
            local d = t:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            d:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
            d:SetPoint("RIGHT", -28, 0)
            d:SetJustifyH("LEFT")
            d:SetJustifyV("TOP")
            d:SetMaxLines(2)
            d:SetText(s[4] or "")
            local arrow = t:CreateTexture(nil, "OVERLAY")
            arrow:SetAtlas("common-icon-forwardarrow")
            arrow:SetSize(14, 14)
            arrow:SetPoint("RIGHT", -10, 0)
            arrow:SetAlpha(0.6)
            t:SetScript("OnClick", function() OpenCategory(s[1].category) end)
            tiles[#tiles + 1] = t
        end
        Grid(b, tiles, 2, 58)
    end

    -- Bottom: the whole family, this addon marked, the others one click away (or greyed when not installed).
    Heading(page, L["Forever addons"])
    local b = page:AddBlock(1, 4)
    local tiles = {}
    for _, f in ipairs(FAMILY) do
        local here = f[1] == spec.key
        local t = Box(b, here and 0.06 or 0.02, here and { GOLD[1], GOLD[2], GOLD[3], 0.7 } or { 1, 1, 1, 0.07 })
        local ic = Icon(t, 36, f[3])
        ic:SetPoint("TOP", 0, -12)
        local name = t:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        name:SetPoint("TOP", ic, "BOTTOM", 0, -6)
        name:SetPoint("LEFT", 6, 0)
        name:SetPoint("RIGHT", -6, 0)
        name:SetText((f[2]:gsub("^Forever ", "")))
        local state = t:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        state:SetPoint("BOTTOM", 0, 9)
        t.icon, t.name, t.state, t.entry, t.here = ic, name, state, f, here
        if not here then Hover(t) end
        t:SetScript("OnClick", function(self) if not self.here and Loaded(f[1]) then OpenAddon(f) end end)
        t:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(f[2])
            GameTooltip:AddLine(f[4], 1, 1, 1, true)
            if not self.here and not Loaded(f[1]) then
                GameTooltip:AddLine(L["Not installed. Find it on CurseForge by its name."], 0.6, 0.6, 0.6, true)
            end
            GameTooltip:Show()
        end)
        t:SetScript("OnLeave", function() GameTooltip:Hide() end)
        tiles[#tiles + 1] = t
    end
    Grid(b, tiles, #FAMILY, 96)
    page:OnRefresh(function()
        for _, t in ipairs(tiles) do
            local on = t.here or Loaded(t.entry[1])
            t.state:SetText(t.here and L["|cffffd100You are here|r"] or on and L["Open"] or L["Not installed"])
            t.icon:SetDesaturated(not on)
            t.icon:SetAlpha(on and 1 or 0.45)
            t.name:SetTextColor(on and GOLD[1] or 0.5, on and GOLD[2] or 0.5, on and GOLD[3] or 0.5)
        end
    end)
end
