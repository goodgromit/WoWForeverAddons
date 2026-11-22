local _, ns = ...
local L = ns.L

--[[
	An instance's open book: the boss list on the left page, the side tabs on the right edge,
	and the right page showing the selected tab. Frame names, sizes and anchors follow the
	encounter frame in Blizzard_EncounterJournal.xml (EncounterJournal.encounter).

	The right page shows:
	  Overview, no boss chosen   the instance's picture, name and lore (retail's instance frame)
	  Overview, a boss chosen    the boss's lore (else its description) and an Overview section of bullets
	  Loot, Abilities, Model     their panels (UI/LootPanel.lua, UI/AbilitiesPanel.lua, UI/ModelPanel.lua)
	  Quests                     both pages (UI/QuestsPanel.lua)
]]

local EncounterPage = {}
ns.EncounterPage = EncounterPage

-- Retail's four tabs in its order, then the journal's own Quests tab.
local TAB_OVERVIEW, TAB_LOOT, TAB_ABILITIES, TAB_MODEL, TAB_QUESTS = 1, 2, 3, 4, 5

local SIDE_TABS = {
	{ id = TAB_OVERVIEW, tooltip = L.TAB_OVERVIEW, selected = "Tab-BossIcon-Selected", unselected = "Tab-BossIcon-UnSelected" },
	{ id = TAB_LOOT, tooltip = L.TAB_LOOT, selected = "Tab-LootIcon-Selected", unselected = "Tab-LootIcon-UnSelected" },
	{ id = TAB_ABILITIES, tooltip = L.TAB_ABILITIES, selected = "Tab-AbilitiesIcon-Selected", unselected = "Tab-AbilitiesIcon-UnSelected" },
	{ id = TAB_MODEL, tooltip = L.TAB_MODEL, selected = "Tab-ModelIcon-Selected", unselected = "Tab-ModelIcon-UnSelected" },
	-- Retail has no quest tab; its icon is the client's own quest-giver "!".
	{ id = TAB_QUESTS, tooltip = L.TAB_QUESTS, atlas = "QuestNormal" },
}

-- Text for a tab whose page is not built yet; every tab has its page now.
local PLACEHOLDERS = {}

local BOOK = "Interface\\EncounterJournal\\UI-EJ-JournalBG"
local BOOK_COORDS = { 0, 0.766601562, 0, 0.830078125 }
local DEFAULT_BOSS = "Interface\\EncounterJournal\\UI-EJ-BOSS-Default"
-- The Recipes entry's picture in the boss list (ns.IsLootSection): the client's own recipe scroll, the icon its
-- recipes, plans and patterns wear (FileDataID 134939), cut inside its frame for the round portrait, as a faction's
-- crest is.
EncounterPage.RECIPES_ICON = "Interface\\Icons\\INV_Scroll_03"
local RECIPES_ICON_COORDS = { 0.07, 0.93, 0.07, 0.93 }
local REACHED_ICON = "Interface\\Buttons\\UI-CheckBox-Check"
local STATUS_BAR = "Interface\\TargetingFrame\\UI-StatusBar"
local STANDING_BAR_TEMPLATE = "ColoredProgressBarTemplate"
local MAP_BUTTON = "Interface\\QuestFrame\\UI-QuestMap_Button"
-- The round glow the game lights its round buttons with under the mouse (the minimap's).
local ROUND_HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
local BOSS_NAME_COLOR = { 0.827, 0.659, 0.463 }
-- The "not yet tested" note on a placeholder dungeon's overview: a dark red that reads on the lore box.
local UNTESTED_COLOR = "|cff8c1a1a"
-- "New in WoW: Forever" on the overview: a deep blue, which stands out from the parchment
-- (a gold one sank into it).
local FOREVER_COLOR = "|cff123a6e"

--[[
	Adventure Mode (Core/Discovery.lua). A dungeon not entered is a rumour: its pictures darkened by
	RUMOUR_SHADE, its name, place and level only. An unmet boss is the journal's own unknown-boss picture
	(DEFAULT_BOSS, as for a boss with no portrait), "???" for its name: nothing of its look until it is met.
]]
local RUMOUR_SHADE = 0.35

-- The top padding leaves room for the first portrait's circle, which stands a little taller than its plate.
local BOSS_BUTTON_HEIGHT, BOSS_SPACING, BOSS_TOP_PADDING, BOSS_BOTTOM_PADDING = 55, 15, 6, 20

--[[
	The boss list's side rows: where a dungeon has several doors and its bosses say which side they stand on (side,
	the index of the door: Stratholme's Main Gate and Service Gate), a row with the door's name above each side's
	bosses, on the journal's own section bar (Header-Overview, as a boss page's "Overview" and Before you go have
	it): the bar's height, and the list's top padding below it, so the first portrait's circle clears the bar's line
	as it clears the list's top. The game's own journal has no such rows: the owner's try of 2026-11-12. This
	is the one switch: false gives one list, the sides in the same order, as the game's journal has it.
]]
EncounterPage.SIDE_HEADERS = true
local SIDE_HEADER_HEIGHT = 30

-- Crops of a Forever loading screen: square for the round icon, wide for the lore picture.
local ICON_COORDS = { 0.32, 0.68, 0.15, 0.85 }
local BUTTON_IMAGE_ICON_COORDS = { 0.156, 0.527, 0, 0.742 }
local LORE_COORDS = { 0.20, 0.80, 0.15, 0.85 }
-- Blizzard's lore picture (its art fills 390 x 336 of 512 x 512, with a painted edge about 9 wide down each side)
-- cut inside that edge to the frame's shape (332 x 196), from its middle: every dungeon's overview in the one
-- framed size (the owner's call, 2026-11-09).
local LORE_IMAGE_COORDS = { 0.0176, 0.7441, 0.1137, 0.5426 }
local FACTION_CREST_COORDS = { 0.07, 0.93, 0.07, 0.93 }
local FALLBACK_ART = "Interface\\EncounterJournal\\UI-EJ-LOREBG-Default"

------------------------------------------------------------------------------------------
-- Small helpers
------------------------------------------------------------------------------------------

local function SetColor(fontString, color)
	fontString:SetTextColor(color[1], color[2], color[3])
end

local function ParchmentText(parent, width)
	local text = parent:CreateFontString(nil, "ARTWORK", "GameFontBlack")
	text:SetWidth(width)
	text:SetJustifyH("LEFT")
	SetColor(text, ns.PARCHMENT_TEXT_COLOR)
	return text
end

local function SetCroppedArt(texture, art, coords)
	texture:SetTexture(art or FALLBACK_ART)
	if art then
		texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
	else
		texture:SetTexCoord(0, 1, 0, 1)
	end
end

-- Rounds a texture with a separate mask object (UI/Art.lua): shape, when given, is the region the
-- circle fills, for a texture larger than its circle.
local Masked = ns.CircleMasked

local function BreakUp(value)
	if type(BreakUpLargeNumbers) == "function" then
		local ok, text = pcall(BreakUpLargeNumbers, value)
		if ok and text then return text end
	end
	return tostring(value)
end

--[[
	The bosses listed: not a creature listed only for loot that is hidden until confirmed
	(Core/Items.lua), nor a quest target (a quest's mob, on the map only: the owner's call of 2026-11-12,
	Gnomeregan's Techbot and the Excavation Site's Highland Horror; his page stays, with his notes, abilities
	and loot, opened from his loot and abilities found elsewhere: UI/DungeonMap.lua's OpenPin); then the
	dungeon's trash, as one more entry at the end, when any of its drops is worth listing (rare and epic
	ones, recipes, quest items: Items:Unremarkable), and its recipes after it, where it has any shown
	(ns.IsLootSection: entries of its loot, in the data's order, after every boss); in Adventure Mode, the recipes
	only once one of them is seen in the dungeon (Discovery:RecipesHidden).
]]
local function BossesOf(instance)
	local list, sections = {}, {}
	for _, boss in ipairs(instance.bosses) do
		if ns.IsLootSection(boss) then
			if ns.Items:ListsTrash(boss) and not ns.Discovery:RecipesHidden(instance, boss) then
				sections[#sections + 1] = boss
			end
		elseif not ns.Items:HidesBoss(boss) and not boss.questTarget then
			list[#list + 1] = boss
		end
	end
	for _, boss in ipairs(sections) do list[#list + 1] = boss end
	return list
end

local function NameList(rows, limit)
	local names = {}
	for index, row in ipairs(rows) do
		if index > limit then
			names[#names + 1] = string.format(L.AND_MORE, #rows - limit)
			break
		end
		names[#names + 1] = row.name or "?"
	end
	return table.concat(names, ", ")
end

------------------------------------------------------------------------------------------
-- Left page: instance header and boss list
------------------------------------------------------------------------------------------

--[[
	A boss's portrait is a full circle that starts the button, ringed like the faction cards'
	crests: a gold band, then a thin dark edge. PORTRAIT gives its centre (from the button's left
	edge, on the plate's middle), the portrait's radius and the band's width.

	The plate starts behind the circle, so nothing of it shows to the portrait's left. Its own
	round cap, made for retail's pictures, is left off: the plate's art is taken from PLATE.from
	(measured on an in-game screenshot, where the cap's dark hollow ends) and drawn from PLATE.at,
	where the circle covers its cut end top to bottom. The rest of the plate is stretched a tenth
	to make up the length.
]]
local PORTRAIT = { x = 33.5, radius = 27, band = 3 }
local PLATE = { width = 325, from = 72, at = 45, art = { "BossButton-Up", "BossButton-Down", "BossButton-Highlight" } }

-- The plate's normal, pushed and highlight art without its cap.
local function DropPlateCap(button)
	local textures = { button:GetNormalTexture(), button:GetPushedTexture(), button:GetHighlightTexture() }
	for index, texture in ipairs(textures) do
		local left, right, top, bottom = ns.ArtCoords(PLATE.art[index])
		texture:SetTexCoord(left + (right - left) * PLATE.from / PLATE.width, right, top, bottom)
		texture:ClearAllPoints()
		texture:SetPoint("TOPLEFT", PLATE.at, 0)
		texture:SetPoint("BOTTOMRIGHT")
	end
end

--[[
	A boss's level, as Forever's target frame shows a creature's: its small round badge
	(UI-HUD-UnitFrame-SmallCircle, Blizzard_UnitFrame/Camelot) on the portrait's rim at the bottom
	right, the number in the colour the client gives that level against the player's own, grey
	to red. Shown unless the player turns it off in the journal's options (UI/Options.lua).
]]
local LEVEL_BADGE_ATLAS = "UI-HUD-UnitFrame-SmallCircle"
local LEVEL_BADGE_OFFSET = 19   -- right of and below the portrait's centre: on its rim

function EncounterPage.ShowsBossLevels()
	return not (ns.db and ns.db.hideBossLevels)
end

function EncounterPage.SetShowsBossLevels(shown)
	ns.db.hideBossLevels = not shown or nil
	EncounterPage:PaintLevels()
end

-- The level a creature turns grey to the player at, classic's rule, for a client without its own.
local function GreyLevel(level)
	if level <= 5 then return 0 end
	if level <= 39 then return level - math.floor(level / 10) - 5 end
	if level <= 59 then return level - math.floor(level / 5) - 1 end
	return level - 9
end

function EncounterPage.LevelColor(level)
	if type(GetCreatureDifficultyColor) == "function" then
		local ok, color = pcall(GetCreatureDifficultyColor, level)
		if ok and type(color) == "table" and type(color.r) == "number" then return color.r, color.g, color.b end
	end
	local player = UnitLevel("player") or 1
	local above = level - player
	if above >= 5 then return 1, 0.1, 0.1 end
	if above >= 3 then return 1, 0.5, 0.25 end
	if above >= -2 then return 1, 1, 0 end
	if level > GreyLevel(player) then return 0.25, 0.75, 0.25 end
	return 0.5, 0.5, 0.5
end

local function CreateLevelBadge(button, holder)
	local badge = holder:CreateTexture(nil, "OVERLAY", nil, 1)
	if ns.AtlasExists(LEVEL_BADGE_ATLAS) then
		badge:SetAtlas(LEVEL_BADGE_ATLAS, true)
	else
		badge:SetSize(24, 24)
		badge:SetColorTexture(0.05, 0.04, 0.02, 1)
		Masked(holder, badge)
	end
	badge:SetPoint("CENTER", button, "LEFT", PORTRAIT.x + LEVEL_BADGE_OFFSET, -LEVEL_BADGE_OFFSET)
	badge.Text = holder:CreateFontString(nil, "OVERLAY", ns.Font("WhiteLargeNumberFont", "NumberFontNormal"))
	-- Text and textures share the sublevels: the number above its circle.
	badge.Text:SetDrawLayer("OVERLAY", 2)
	badge.Text:SetPoint("CENTER", badge, "CENTER", 0, -0.5)
	return badge
end

local function SetLevelBadge(button)
	local boss, badge = button.boss, button.Level
	local level = boss and not boss.standing and not button.unmet and tonumber(boss.level) or nil
	local shown = level ~= nil and level > 0 and EncounterPage.ShowsBossLevels()
	badge:SetShown(shown)
	badge.Text:SetShown(shown)
	if shown then
		badge.Text:SetText(level)
		badge.Text:SetTextColor(EncounterPage.LevelColor(level))
	end
end

-- A circle of the given radius, centred on the portrait.
local function PortraitCircle(button, holder, subLevel, radius)
	local texture = Masked(holder, holder:CreateTexture(nil, "ARTWORK", nil, subLevel))
	texture:SetSize(radius * 2, radius * 2)
	texture:SetPoint("CENTER", button, "LEFT", PORTRAIT.x, 0)
	return texture
end

local function CreateBossButton(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(325, BOSS_BUTTON_HEIGHT)
	ns.SetButtonArt(button, "BossButton-Up", "BossButton-Down", "BossButton-Highlight")
	DropPlateCap(button)

	-- The creature's own portrait, where the client knows its model; otherwise Blizzard's
	-- default boss picture in the same circle, its figure's shoulders on the circle's foot (in Adventure
	-- Mode also a boss not met: the unknown-boss picture).
	local holder = CreateFrame("Frame", nil, button)
	holder:SetAllPoints()
	-- The gold band and its dark edge (UI/Art.lua's, which the fog's bosses on the dungeon maps wear too).
	button.Rim, button.Edge = ns.PortraitBand(holder, "ARTWORK", 1, PORTRAIT.radius, PORTRAIT.band, "CENTER", button, "LEFT",
		PORTRAIT.x, 0)
	button.Portrait = PortraitCircle(button, holder, 3, PORTRAIT.radius)
	button.DefaultArt = Masked(holder, holder:CreateTexture(nil, "ARTWORK", nil, 4), button.Portrait)
	button.DefaultArt:SetTexture(DEFAULT_BOSS)
	button.DefaultArt:SetSize(128, 64)
	button.DefaultArt:SetPoint("BOTTOMLEFT", button, "LEFT", PORTRAIT.x - 37.5, -PORTRAIT.radius)
	button.Level = CreateLevelBadge(button, holder)
	-- The quest badge at the portrait's foot, as the target frame wears it (UI/QuestMap.lua's BuildBadge), under the
	-- level's badge where they meet; pointed at, the boss's quests (PaintQuestBadge).
	button.QuestBadge = ns.QuestMap:BuildBadge(holder, "list", button, PORTRAIT.x, -PORTRAIT.radius)
	button:SetScript("OnEnter", function(self)
		if not self.QuestBadge:IsShown() then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.boss.name, 1, 0.82, 0)
		ns.QuestMap:AddBadgeLines(self.instance, self.boss)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
	end)

	button.Name = button:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalMed3", "GameFontNormal"))
	button.Name:SetJustifyH("LEFT")
	SetColor(button.Name, BOSS_NAME_COLOR)

	-- A faction's standings say how many rewards each holds, and tick the ones reached.
	button.Detail = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	button.Detail:SetJustifyH("LEFT")
	button.Detail:SetTextColor(0.75, 0.68, 0.58)
	button.Detail:SetWordWrap(false)
	button.Reached = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.Reached:SetTexture(REACHED_ICON)
	button.Reached:SetSize(22, 22)
	button.Reached:SetPoint("RIGHT", -18, 0)

	button:SetScript("OnClick", function(self)
		ns.PlaySoundKit("IG_ABILITY_PAGE_TURN")
		-- A standing shows only its own rewards, and a currency's vendor only theirs; clicking it again shows them all.
		if (self.boss.standing or self.boss.vendor) and self.selected then
			ns.Journal:OpenInstance(self.instance)
		else
			ns.Journal:OpenBoss(self.instance, self.boss)
		end
	end)
	return button
end

-- The quest badge on a boss's portrait (UI/QuestMap.lua's StyleBadge): never on a boss not met (Adventure Mode).
local function PaintQuestBadge(button)
	if button.unmet or not button.boss then
		button.QuestBadge:Hide()
	else
		ns.QuestMap:StyleBadge(button.QuestBadge, button.instance, button.boss)
	end
end

-- A boss's name in the list: tagged as a rare; a hidden boss the players summon (summoned) has no tag, as the other
-- hidden bosses. (A quest target is in no list: BossesOf.)
local function ListName(boss)
	if boss.rare then return boss.name .. L.RARE_SUFFIX end
	return ns.BossTitle(boss)
end

-- A side's row in the boss list (EncounterPage.SIDE_HEADERS, above): the bar, and the door's name on it as the
-- "Overview" bar's label sits.
local function CreateSideHeader(parent)
	local header = CreateFrame("Frame", nil, parent)
	header:SetSize(325, SIDE_HEADER_HEIGHT)
	header.Bar = header:CreateTexture(nil, "ARTWORK")
	ns.Art(header.Bar, "Header-Overview")
	header.Bar:SetPoint("BOTTOMLEFT")
	header.Label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	header.Label:SetPoint("BOTTOMLEFT", header.Bar, "BOTTOMLEFT", 8, 6)
	SetColor(header.Label, ns.HEADER_LABEL_COLOR)
	return header
end

-- The door whose side a boss is listed under, where the rows show (nil for the trash and the recipes, both sides').
local function SideOf(instance, boss)
	if not (EncounterPage.SIDE_HEADERS and instance.doors and boss.side) or ns.IsLootSection(boss) then return nil end
	return instance.doors[boss.side]
end

-- A vendor's card: the name and the zone from 80, nearer the crest than a boss's name (105) for the room Show Map takes
-- (the owner, 2026-11-14), Show Map 16 in from the right, and 6 between them.
local VENDOR_TEXT_LEFT, VENDOR_MAP_RIGHT, VENDOR_GAP = 80, 16, 6
-- The line under the name (a standing's rewards, a vendor's zone): 105 in on a standing (VENDOR_TEXT_LEFT on a vendor's
-- card), 11 below the middle.
local DETAIL_LEFT, DETAIL_Y = 105, -11

-- unmet: in Adventure Mode, a boss the character has not met: "???", the unknown-boss picture, no level.
local function SetBossButton(button, instance, boss, unmet)
	button.instance, button.boss, button.unmet = instance, boss, unmet == true or nil
	if unmet then
		button.Name:SetText(ns.Discovery.UNKNOWN)
	else
		button.Name:SetText(ListName(boss))
	end
	button.Name:ClearAllPoints()
	button.Detail:ClearAllPoints()

	local hasPortrait = false
	if boss.standing then
		button.Name:SetSize(160, 20)
		button.Name:SetPoint("LEFT", 105, 7)
		button.Detail:SetPoint("LEFT", DETAIL_LEFT, DETAIL_Y)
		button.Detail:SetWidth(160)
		-- (in Adventure Mode, the rewards seen at the faction's quartermaster)
		local count = 0
		for _, row in ipairs(boss.loot or {}) do
			if ns.Discovery:Knows("reward", instance, row.itemID) then count = count + 1 end
		end
		button.Detail:SetText(count == 1 and L.REP_REWARD_ONE or string.format(L.REP_REWARDS, count))
		local badge = ns.Reputation:Badge(boss.reaction)
		if badge then
			button.Portrait:SetTexture(badge)
			button.Portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			hasPortrait = true
		end
	elseif boss.vendor then
		-- A currency vendor (Core/Registry.lua), or a quartermaster's card on a faction's page (its FACTION_VENDOR_CARDS):
		-- the currency's icon or the faction's crest, their name, the zone they stand in, and Show Map,
		-- the quest page's own map button (its link face sets the client's waypoint on them).
		local map = boss.mapID and ns.DungeonMap:MapInfo(boss.mapID)
		button.Detail:SetText(map and map.name or "")
		button.Portrait:SetTexture(ns.Reputation:Crest(instance))
		button.Portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		hasPortrait = true
		-- (made the first time, on a vendor's button alone; rawget: the field is the journal's own)
		if not rawget(button, "VendorMap") then
			button.VendorMap = ns.QuestsPanel:CreateMapButton(button, L.MAP_SHOW)
			button.VendorMap:SetPoint("RIGHT", -VENDOR_MAP_RIGHT, 0)
		end
		button.Name:SetPoint("LEFT", VENDOR_TEXT_LEFT, 7)
		button.Detail:SetPoint("LEFT", VENDOR_TEXT_LEFT, DETAIL_Y)
		-- (Show Map's width, the name's and the zone's room and Show Map's place: FitVendorCards, once the page's cards
		-- are all set)
	else
		button.Name:SetSize(160, 40)
		button.Name:SetPoint("LEFT", 105, -3)
		if boss.recipes then
			-- The dungeon's recipes: the recipe scroll in the portrait's circle (the trash keeps the default boss picture).
			button.Portrait:SetTexture(EncounterPage.RECIPES_ICON)
			button.Portrait:SetTexCoord(RECIPES_ICON_COORDS[1], RECIPES_ICON_COORDS[2], RECIPES_ICON_COORDS[3],
				RECIPES_ICON_COORDS[4])
			hasPortrait = true
		elseif not unmet and boss.displayID and type(SetPortraitTextureFromCreatureDisplayID) == "function" then
			button.Portrait:SetTexCoord(0, 1, 0, 1)
			hasPortrait = pcall(SetPortraitTextureFromCreatureDisplayID, button.Portrait, boss.displayID)
		end
	end
	button.Detail:SetShown(boss.standing == true or boss.vendor == true)
	if rawget(button, "VendorMap") then button.VendorMap:SetShown(boss.vendor == true) end
	button.Reached:SetShown(boss.standing == true and ns.Reputation:Reached(instance, boss.reaction))
	button.Portrait:SetShown(hasPortrait)
	button.DefaultArt:SetShown(not hasPortrait)
	SetLevelBadge(button)
	PaintQuestBadge(button)
end

--[[
	The vendors' cards on a page, once they are all set: Show Map the size and font of the quest page's Show End in the
	client's language (UI/QuestsPanel.lua's MapButtonWidth: 112 in English), wider only where its own label needs it,
	never narrower. The name and the zone end 6 short of it: one longer still ends in "...", not run under it
	("Stranglethorn Vale" fits with 20 to spare in English, "Schlingendorntal" with 13 in German). Then each card's place
	on the button (its link face is made at the button's width).
]]
local function FitVendorCards(buttons, count)
	for index = 1, count do
		local button = buttons[index]
		local boss = button.boss
		if boss and boss.vendor and rawget(button, "VendorMap") then
			-- (its label's room with it: the client does not widen the label with the button, UI/QuestsPanel.lua)
			local width = ns.QuestsPanel:MapButtonWidth(button.VendorMap)
			ns.QuestsPanel:SetMapButtonWidth(button.VendorMap, width)
			local room = button:GetWidth() - VENDOR_TEXT_LEFT - VENDOR_MAP_RIGHT - VENDOR_GAP - width
			button.Name:SetSize(room, 20)
			button.Detail:SetWidth(room)
			local map = boss.mapID and ns.DungeonMap:MapInfo(boss.mapID)
			local point = boss.mapID and boss.x and boss.y and { mapID = boss.mapID, x = boss.x, y = boss.y } or nil
			ns.QuestsPanel:SetMapButton(button.VendorMap, point, boss.name,
				map and map.name and (boss.name .. ", " .. map.name) or boss.name)
		end
	end
end

-- The page's vendor cards laid out again as they read now (the smoke test's long zone names, written onto a card).
function EncounterPage:FitVendorCards(page)
	local buttons, count = page.Bosses.Buttons, 0
	while buttons[count + 1] and buttons[count + 1]:IsShown() do count = count + 1 end
	FitVendorCards(buttons, count)
end

--[[
	The bar itself: Forever's own reputation bar from the character panel (its framed track,
	fill and mask), or a plain status bar on a client without that template.
]]
local function CreateStandingBar(parent)
	if ns.HasTemplate(STANDING_BAR_TEMPLATE) then
		local ok, bar = pcall(CreateFrame, "Frame", nil, parent, STANDING_BAR_TEMPLATE)
		if ok and bar and rawget(bar, "Fill") then return bar end
	end
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetStatusBarTexture(STATUS_BAR)
	bar.Background = bar:CreateTexture(nil, "BACKGROUND")
	bar.Background:SetAllPoints()
	bar.Background:SetColorTexture(0, 0, 0, 0.6)
	bar.Text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bar.Text:SetPoint("CENTER", 0, 1)
	return bar
end

local function SetStandingBar(bar, standing)
	local r, g, b = ns.Reputation:Color(standing.reaction)
	local max = math.max(1, standing.max)
	local text = string.format(L.REP_PROGRESS, BreakUp(standing.value), BreakUp(standing.max))
	if rawget(bar, "Fill") then
		-- Forever's bar: its white fill, tinted the standing's colour.
		if bar.SetFillTextureByColorType and bar.ColorType then
			pcall(bar.SetFillTextureByColorType, bar, bar.ColorType.White)
		end
		bar.Fill:SetVertexColor(r, g, b)
		bar:SetFillPercent(standing.value / max)
		bar.Text:SetText(text)
	else
		bar:SetMinMaxValues(0, max)
		bar:SetValue(standing.value)
		bar:SetStatusBarColor(r, g, b)
		bar.Text:SetText(text)
	end
end

--[[
	Beneath a faction's standings, on the same plate as they sit on: the handshake of the
	player's standing now, its name, and how far through it they are.
]]
local function CreateFactionStanding(page)
	local holder = CreateFrame("Frame", nil, page.Bosses.Child)
	holder:SetSize(325, BOSS_BUTTON_HEIGHT)
	holder.Plate = holder:CreateTexture(nil, "BACKGROUND")
	ns.Art(holder.Plate, "BossButton-Up")
	holder.Plate:SetAllPoints()

	holder.Badge = Masked(holder, holder:CreateTexture(nil, "OVERLAY", nil, 5))
	holder.Badge:SetSize(48, 48)
	holder.Badge:SetPoint("CENTER", holder, "LEFT", 46, 0)
	holder.Ring = holder:CreateTexture(nil, "OVERLAY", nil, 6)
	ns.Art(holder.Ring, "BossModelButton", true)
	holder.Ring:SetSize(77, 73)
	holder.Ring:SetPoint("CENTER", holder.Badge)

	holder.Label = holder:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalMed3", "GameFontNormal"))
	holder.Label:SetSize(205, 16)
	holder.Label:SetJustifyH("LEFT")
	SetColor(holder.Label, BOSS_NAME_COLOR)

	-- At the template's own height, which its fill and mask art are cut for.
	holder.Bar = CreateStandingBar(holder)
	holder.Bar:SetSize(205, 29)
	holder.Bar:SetPoint("TOPLEFT", 100, -21)

	-- Standings change as the player earns reputation; a currency's count as their bags change (a currency vendor's
	-- page: the same plate, saying how many they have).
	holder:RegisterEvent("UPDATE_FACTION")
	holder:RegisterEvent("BAG_UPDATE_DELAYED")
	holder:SetScript("OnEvent", function(self, event)
		local instance = page.instance
		if self:IsVisible() and instance and (event == "BAG_UPDATE_DELAYED") == (instance.kind == "currency")
			and ns.IsRewardsPage(instance) then
			EncounterPage:RefreshStanding(page, true)
		end
	end)
	holder:Hide()
	page.FactionStanding = holder

	-- A currency vendor's page: where the currency comes from, beneath the vendors (ns.CurrencyNote).
	local note = CreateFrame("Frame", nil, page.Bosses.Child)
	note:SetSize(325, 40)
	note.Text = ParchmentText(note, 300)
	note.Text:SetPoint("TOPLEFT", 14, -6)
	note:Hide()
	page.CurrencyNote = note
end

--[[
	Beneath a placeholder's list (a raid or dungeon not open in Forever yet): what it waits on,
	and our Discord, where a recorded run can be sent.
]]
local COMING_SOON_HEIGHT = 128

local function CreateComingSoon(page)
	local box = CreateFrame("Frame", nil, page.Bosses.Child)
	box:SetSize(325, COMING_SOON_HEIGHT)
	box.Title = box:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalMed3", "GameFontNormal"))
	box.Title:SetPoint("TOPLEFT", 14, -6)
	box.Title:SetText(L.COMING_SOON)
	SetColor(box.Title, ns.PARCHMENT_TEXT_COLOR)
	box.Text = ParchmentText(box, 300)
	box.Text:SetPoint("TOPLEFT", box.Title, "BOTTOMLEFT", 0, -6)
	box.Link = ns.CreateDiscordLink(box, 190, true)
	box.Link:SetPoint("TOPLEFT", box.Text, "BOTTOMLEFT", 6, -8)
	box:Hide()
	page.ComingSoon = box
end

-- redrawLoot: the reward list's standing colours change too (reputation was earned); a page
-- being opened draws its list once, afterwards.
function EncounterPage:RefreshStanding(page, redrawLoot)
	local faction, holder = page.instance, page.FactionStanding
	if faction.kind == "currency" then
		-- A currency vendor's page: the currency's icon and how many the player has, no bar.
		holder.Badge:SetTexture(ns.Reputation:Crest(faction))
		holder.Badge:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		holder.Badge:SetDesaturated(false)
		local held = ns.FactionSelect.CurrencyHeld(faction)
		holder.Label:SetText(held and string.format(L.CURRENCY_YOU_HAVE, held) or "")
		holder.Bar:Hide()
		holder.Label:ClearAllPoints()
		holder.Label:SetPoint("LEFT", 102, 0)
		return
	end
	local standing = ns.Reputation:Player(faction.factionID)
	local badge = ns.Reputation:Badge(standing and standing.reaction or 4)
	holder.Badge:SetTexture(badge or ns.Reputation:Crest(faction))
	holder.Badge:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	holder.Badge:SetDesaturated(standing == nil)
	if standing then
		holder.Label:SetText(string.format(L.REP_YOUR_STANDING, ns.Reputation:Label(standing.reaction)))
		holder.Bar:Show()
		SetStandingBar(holder.Bar, standing)
		holder.Label:ClearAllPoints()
		holder.Label:SetPoint("TOPLEFT", 102, -6)
	else
		holder.Label:SetText(L.REP_NOT_MET)
		holder.Bar:Hide()
		holder.Label:ClearAllPoints()
		holder.Label:SetPoint("LEFT", 102, 0)
	end
	for _, button in ipairs(page.Bosses.Buttons) do
		if button:IsShown() and button.boss.standing then
			button.Reached:SetShown(ns.Reputation:Reached(faction, button.boss.reaction))
		end
	end
	if redrawLoot and page.Loot:IsShown() then ns.LootPanel:Refresh(page.Loot) end
end

local function CreateLeftPage(page, info)
	info.LeftShadow = info:CreateTexture(nil, "BACKGROUND", nil, 3)
	ns.Art(info.LeftShadow, "LeftPageHeader")
	info.LeftShadow:SetPoint("TOPLEFT", 0, -11)

	-- The dungeon's round icon: a click goes back to its overview, the page it opens on (the owner's ask of
	-- 2026-11-04), from any of its pages; lit under the mouse with the round glow of the game's round buttons,
	-- its tooltip the dungeon's name and what a click does. A faction's crest opens its rewards, its only page.
	local instanceButton = CreateFrame("Button", nil, info)
	instanceButton:SetSize(64, 61)
	instanceButton:SetPoint("TOPLEFT", 0, -3)
	instanceButton.Icon = Masked(instanceButton, instanceButton:CreateTexture(nil, "BACKGROUND", nil, 6))
	instanceButton.Icon:SetSize(40, 40)
	instanceButton.Icon:SetPoint("CENTER")
	ns.SetButtonArt(instanceButton, "BossModelButton")
	instanceButton:SetHighlightTexture(ROUND_HIGHLIGHT, "ADD")
	local glow = instanceButton:GetHighlightTexture()
	glow:ClearAllPoints()
	glow:SetSize(48, 48)
	glow:SetPoint("CENTER", instanceButton.Icon)
	instanceButton:SetScript("OnClick", function()
		ns.PlaySoundKit("IG_ABILITY_PAGE_TURN")
		EncounterPage:ShowOverview(page)
	end)
	instanceButton:SetScript("OnEnter", function(self)
		local instance = page.instance
		if not instance then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(instance.name or "", 1, 1, 1)
		if not ns.IsRewardsPage(instance) then GameTooltip:AddLine(L.INSTANCE_ICON_OVERVIEW, 0.1, 1, 0.1, true) end
		GameTooltip:Show()
	end)
	instanceButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	info.InstanceButton = instanceButton

	info.InstanceTitle = info:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	info.InstanceTitle:SetSize(290, 12)
	info.InstanceTitle:SetPoint("TOPLEFT", 65, -20)
	info.InstanceTitle:SetJustifyH("LEFT")
	SetColor(info.InstanceTitle, ns.PAGE_TITLE_COLOR)

	-- The list scrolls below the dungeon's icon, so a portrait's circle never shows round it.
	local bosses = ns.CreateScrollFrame(info, 5, -5, 5)
	bosses:SetSize(338, 364)
	bosses:SetPoint("BOTTOMLEFT", 25, 1)
	bosses.Child:SetWidth(325)
	bosses.Buttons, bosses.Headers = {}, {}
	page.Bosses = bosses
	CreateFactionStanding(page)
	CreateComingSoon(page)
end

------------------------------------------------------------------------------------------
-- Right page
------------------------------------------------------------------------------------------

-- Retail's instance frame: picture, name banner and lore, over the right page.
local function CreateInstanceOverview(page, info)
	local overview = CreateFrame("Frame", nil, page)
	overview:SetSize(390, 425)
	overview:SetPoint("BOTTOMRIGHT", -1, 2)
	overview:SetFrameLevel(info:GetFrameLevel() + 2)

	overview.PictureBorder = overview:CreateTexture(nil, "BACKGROUND")
	overview.PictureBorder:SetColorTexture(0.12, 0.08, 0.04, 0.85)
	overview.PictureBorder:SetSize(336, 200)
	overview.PictureBorder:SetPoint("TOP", 3, -22)
	overview.Picture = overview:CreateTexture(nil, "BORDER")
	overview.Picture:SetPoint("TOPLEFT", overview.PictureBorder, 2, -2)
	overview.Picture:SetPoint("BOTTOMRIGHT", overview.PictureBorder, -2, 2)

	overview.TitleBackground = overview:CreateTexture(nil, "ARTWORK")
	ns.Art(overview.TitleBackground, "DungeonNameBg")
	overview.TitleBackground:SetPoint("TOP", overview.PictureBorder, "TOP", 0, -14)
	overview.Title = overview:CreateFontString(nil, "OVERLAY", ns.Font("QuestFont_Super_Huge", "GameFontNormalHuge"))
	overview.Title:SetSize(320, 35)
	overview.Title:SetPoint("CENTER", overview.TitleBackground, "CENTER", 0, 2)
	overview.Title:SetJustifyH("CENTER")

	local lore = ns.CreateScrollFrame(overview, 9, -6, 6)
	lore:SetSize(315, 178)
	lore:SetPoint("BOTTOMLEFT", 35, 10)
	lore.Child:SetWidth(315)
	lore.Text = ParchmentText(lore.Child, 310)
	lore.Text:SetPoint("TOPLEFT", 2, -2)
	-- Before you go's line under the facts, where the player's side has notes: how many, and that they are on
	-- the Quests tab, which a click opens (the owner's call of 2026-11-13: the notes moved there). In the
	-- facts' own font, in the blue of "New in WoW: Forever".
	local pointer = CreateFrame("Button", nil, lore.Child)
	pointer.Text = ParchmentText(pointer, 310)
	pointer.Text:SetPoint("TOPLEFT")
	pointer:SetScript("OnClick", function()
		ns.PlaySoundKit("IG_ABILITY_PAGE_TURN")
		EncounterPage:SetTab(page, TAB_QUESTS)
	end)
	pointer:Hide()
	lore.Pointer = pointer
	-- The dungeon's lore (Spoken's story), else its description, beneath the facts (EncounterPage:LayoutLore). Its
	-- text set through UI/SpokenWords.lua, which lights Spoken's words as Spoken reads them.
	lore.Description = ParchmentText(lore.Child, 310)
	-- Spoken's story of the dungeon, played where the player has Spoken (UI/SpokenButton.lua): at the lore box's top
	-- right, on the facts' first line, which stops short of it (FillInstanceOverview).
	lore.Play = ns.SpokenButton.Create(lore.Child, "dungeon", overview, lore.Description)
	lore.Play:SetPoint("TOPRIGHT", -2, -1)
	overview.Lore = lore

	-- Retail's Show Map: the quest log's map icon on a dark strip, above the lore.
	local mapButton = CreateFrame("Button", nil, overview)
	mapButton:SetSize(48, 32)
	mapButton:SetFrameLevel(overview:GetFrameLevel() + 5)
	mapButton.Shadow = mapButton:CreateTexture(nil, "BACKGROUND")
	ns.Art(mapButton.Shadow, "ShowMapBG")
	mapButton.Shadow:SetPoint("LEFT", -3, 5)
	mapButton.Icon = mapButton:CreateTexture(nil, "ARTWORK")
	mapButton.Icon:SetTexture(MAP_BUTTON)
	mapButton.Icon:SetTexCoord(0.125, 0.875, 0, 0.5)
	mapButton.Icon:SetSize(48, 32)
	mapButton.Icon:SetPoint("RIGHT")
	mapButton.Text = mapButton:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	mapButton.Text:SetPoint("LEFT", mapButton, "RIGHT", 2, 0)
	mapButton.Text:SetText(L.MAP_SHOW)
	mapButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	local highlight = mapButton:GetHighlightTexture()
	if highlight then
		highlight:ClearAllPoints()
		highlight:SetSize(36, 25)
		highlight:SetPoint("RIGHT", -7, 0)
	end
	mapButton:SetScript("OnMouseDown", function(self) self.Icon:SetTexCoord(0.125, 0.875, 0.5, 1) end)
	mapButton:SetScript("OnMouseUp", function(self) self.Icon:SetTexCoord(0.125, 0.875, 0, 0.5) end)
	-- The dungeon's own map, wherever the player is; the maps of its way in stay on their zone's map. In test mode, the
	-- test's panel goes to the dungeon shown (UI/TestPanel.lua's FollowMap), its buttons then acting on the map's.
	mapButton:SetScript("OnClick", function()
		ns.PlaySoundKit("IG_MAINMENU_OPTION")
		if ns.DungeonMap:Show(page.instance) and ns.TestPanel then ns.TestPanel:FollowMap(page.instance) end
	end)
	overview.MapButton = mapButton

	page.InstanceOverview = overview
end

--[[
	The boss Overview's lore: 315 wide at retail's 2, -8 on its 320-wide scroll child, Spoken's Play (14 square, its hit
	2 more each side) in the margin to its right, 3 past it. The margin ends at the scroll bar: retail's bar is 8 wide, its
	left 15 back from the scroll's right (335 of 350: Blizzard_EncounterJournal.xml:1816-1822), its up arrow 17 wide
	centred on it from its top, 6 down (MinimalScrollBar.xml's Back), so 330.5 to 347.5. Play at the child's right edge
	(320 to 334) was over that arrow by 3.5 (the owner's picture, 2026-11-19); 6 back from it (314 to 328, its hit to 330)
	it is clear, the lore beside it 6 narrower so the gap stays 3. Where no Play shows, the lore keeps its full width.
]]
local BOSS_LORE_WIDTH, BOSS_PLAY_X = 315, -6
local BOSS_LORE_WIDTH_BESIDE_PLAY = BOSS_LORE_WIDTH + BOSS_PLAY_X

-- The boss Overview: lore (else the description), the "Overview" header bar and bullets beneath it.
local function CreateBossOverview(page, info)
	local scroll = ns.CreateScrollFrame(info, -15, -6, 6)
	scroll:SetSize(350, 383)
	scroll:SetPoint("BOTTOMRIGHT", -5, 1)
	scroll.Child:SetWidth(320)
	local child = scroll.Child

	-- In Adventure Mode, a boss not met: his line of rumour, else a plain line, on top, his lore beneath it
	-- (FillBossOverview, which places both).
	child.Unmet = ParchmentText(child, BOSS_LORE_WIDTH)
	child.Unmet:SetPoint("TOPLEFT", 2, -8)
	child.Unmet:Hide()
	child.Description = ParchmentText(child, BOSS_LORE_WIDTH)
	child.Description:SetPoint("TOPLEFT", 2, -8)
	-- Spoken's story of the boss, played where the player has Spoken (UI/SpokenButton.lua): beside the first line on
	-- top (his lore's, or an unmet boss's line above it), in the margin to its right, clear of the scroll bar's up arrow
	-- (BOSS_PLAY_X; FillBossOverview narrows the lines beside it). His lore's words lit as Spoken reads them
	-- (UI/SpokenWords.lua).
	child.Play = ns.SpokenButton.Create(child, "boss", scroll, child.Description)
	child.Play:SetPoint("TOPLEFT", child, "TOPRIGHT", BOSS_PLAY_X, -7)

	child.Header = child:CreateTexture(nil, "ARTWORK")
	ns.Art(child.Header, "Header-Overview")
	child.Header:SetPoint("TOPLEFT", child.Description, "BOTTOMLEFT", -6, -6)
	child.HeaderLabel = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	child.HeaderLabel:SetPoint("BOTTOMLEFT", child.Header, "BOTTOMLEFT", 8, 6)
	child.HeaderLabel:SetText(L.TAB_OVERVIEW)
	SetColor(child.HeaderLabel, ns.HEADER_LABEL_COLOR)

	child.Bullets = {}
	page.BossOverview = scroll
end

local function CreatePlaceholder(page, info)
	local placeholder = CreateFrame("Frame", nil, info)
	placeholder:SetSize(350, 383)
	placeholder:SetPoint("BOTTOMRIGHT", -5, 1)
	placeholder.Text = ParchmentText(placeholder, 315)
	placeholder.Text:SetPoint("TOPLEFT", 2, -8)
	page.Placeholder = placeholder
end

--[[
	The side tabs' frame level. Retail's (EncounterTabTemplate, frameLevel 510: Blizzard_EncounterJournal.xml:652) are
	drawn over the window's border, its NineSlice (NineSlicePanelTemplate, frameLevel 500: Blizzard_SharedXML/Mainline/
	SharedUIPanelTemplates.xml:381, 573), whose right edge their left side lies on: a tab starts 20 inside the window's
	right edge (the book 8 in, the tab 12 in from the book's) and sticks out 43 past it (UI/Journal.lua's DOCK_LAYOUT).
	Till 0.40.1 they were 30 above the book and under the border, whose edge then hid about 7 of each tab's left side, its
	rim and all (the owner's picture beside retail's, 2026-11-19: the tabs "digging into the border"). 10 above the
	border, as retail's; 30 above the book in a window without one. The highest border of the frames the book is in: the
	window's, not its inset's (InsetFrameTemplate has a NineSlice too, at the inset's own level: the same file, :389-401).
]]
local BORDER_KEY, ABOVE_BORDER, ABOVE_BOOK = "NineSlice", 10, 30

local function SideTabLevel(info)
	local level = info:GetFrameLevel() + ABOVE_BOOK
	local owner = info:GetParent()
	while owner do
		local border = rawget(owner, BORDER_KEY)
		if type(border) == "table" and border.GetFrameLevel then
			level = math.max(level, border:GetFrameLevel() + ABOVE_BORDER)
		end
		owner = owner.GetParent and owner:GetParent() or nil
	end
	return level
end

local function CreateSideTabs(page, info)
	page.Tabs = {}
	local level = SideTabLevel(info)
	for index, definition in ipairs(SIDE_TABS) do
		local tab = CreateFrame("Button", nil, info)
		tab:SetSize(63, 57)
		tab:SetID(definition.id)
		tab:SetFrameLevel(level)
		ns.SetButtonArt(tab, "Tab-UnSelected", "Tab-Selected", "Tab-Highlight", "Tab-UnSelected")
		if index == 1 then
			tab:SetPoint("TOPLEFT", info, "TOPRIGHT", -12, -35)
		else
			tab:SetPoint("TOP", page.Tabs[index - 1], "BOTTOM", 0, 2)
		end

		tab.unselected = tab:CreateTexture(nil, "OVERLAY")
		tab.selected = tab:CreateTexture(nil, "OVERLAY")
		if definition.atlas then
			for _, icon in ipairs({ tab.unselected, tab.selected }) do
				icon:SetAtlas(definition.atlas)
				icon:SetSize(32, 32)
			end
			tab.unselected:SetPoint("RIGHT", -14, 0)
			tab.unselected:SetVertexColor(0.75, 0.75, 0.75)
		else
			ns.Art(tab.unselected, definition.unselected)
			ns.Art(tab.selected, definition.selected)
			tab.unselected:SetPoint("RIGHT", -6, 0)
		end
		tab.selected:SetPoint("CENTER", tab.unselected, "CENTER")

		tab.tooltip = definition.tooltip
		tab:SetScript("OnClick", function(self)
			ns.PlaySoundKit("IG_ABILITY_PAGE_TURN")
			EncounterPage:SetTab(page, self:GetID())
		end)
		tab:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
			GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
			-- Closed in Adventure Mode until the boss is met or fought: why.
			if self.closedWhy then
				GameTooltip:AddLine(self.closedWhy, 1, 1, 1, true)
				GameTooltip:Show()
			end
		end)
		tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
		page.Tabs[index] = tab
	end
end

------------------------------------------------------------------------------------------
-- Building the page
------------------------------------------------------------------------------------------

local pages = {}

function EncounterPage:Create(parent)
	local page = CreateFrame("Frame", nil, parent)
	page:SetPoint("TOPLEFT")
	page:SetPoint("BOTTOMRIGHT", -3, 0)
	page:Hide()
	page.tab = TAB_OVERVIEW
	pages[#pages + 1] = page

	local info = CreateFrame("Frame", nil, page)
	info:SetSize(785, 425)
	info:SetPoint("BOTTOMRIGHT", -1, 2)
	page.info = info

	info.Book = info:CreateTexture(nil, "BACKGROUND")
	info.Book:SetSize(785, 425)
	info.Book:SetPoint("BOTTOMRIGHT")
	info.Book:SetTexture(BOOK)
	info.Book:SetTexCoord(BOOK_COORDS[1], BOOK_COORDS[2], BOOK_COORDS[3], BOOK_COORDS[4])

	info.RightShadow = info:CreateTexture(nil, "BACKGROUND", nil, 3)
	ns.Art(info.RightShadow, "RightPageHeader")
	info.RightShadow:SetPoint("TOPRIGHT", 0, -11)
	info.EncounterTitle = info:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	info.EncounterTitle:SetSize(220, 12)
	info.EncounterTitle:SetPoint("BOTTOMLEFT", info, "TOPRIGHT", -350, -36)
	info.EncounterTitle:SetJustifyH("LEFT")
	SetColor(info.EncounterTitle, ns.PAGE_TITLE_COLOR)

	CreateLeftPage(page, info)
	CreateBossOverview(page, info)
	CreatePlaceholder(page, info)
	page.Loot = ns.LootPanel:Create(page, info)
	page.Abilities = ns.AbilitiesPanel:Create(page, info)
	page.Model = ns.ModelPanel:Create(page, info)
	ns.QuestsPanel:Create(page, info)
	CreateInstanceOverview(page, info)
	CreateSideTabs(page, info)
	return page
end

------------------------------------------------------------------------------------------
-- Filling it
------------------------------------------------------------------------------------------

-- A rumour has no list: nothing of the dungeon is known but where it is.
local NO_BOSSES = {}

-- Adventure Mode: where a faction's rewards not seen yet are seen, naming its quartermasters where the
-- data has them ("A or B").
local function QuartermasterLine(faction)
	local names = {}
	for _, vendor in pairs(faction.quartermasters or {}) do
		if type(vendor) == "table" and type(vendor.name) == "string" then names[#names + 1] = vendor.name end
	end
	if #names == 0 then return L.ADVENTURE_REP_SEEN end
	table.sort(names)
	local list = #names == 1 and names[1]
		or table.concat(names, L.QUEST_LIST_COMMA, 1, #names - 1) .. L.QUEST_OR .. names[#names]
	return string.format(L.ADVENTURE_REP_SEEN_AT, list)
end

local function FillBossList(page)
	local bosses, child = page.Bosses, page.Bosses.Child
	local list = page.rumour and NO_BOSSES or BossesOf(page.instance)
	-- From the top down: a side's row above its first boss (SIDE_HEADERS), each boss a plate and a gap.
	local top, side, headers = BOSS_TOP_PADDING, nil, 0
	for index, boss in ipairs(list) do
		local door = SideOf(page.instance, boss)
		if door and door ~= side then
			headers = headers + 1
			local header = bosses.Headers[headers]
			if not header then
				header = CreateSideHeader(child)
				bosses.Headers[headers] = header
			end
			header:ClearAllPoints()
			header:SetPoint("TOPLEFT", 0, -top)
			header.Label:SetText(door.name)
			header.door = door
			header:Show()
			top = top + SIDE_HEADER_HEIGHT + BOSS_TOP_PADDING
			side = door
		end
		local button = bosses.Buttons[index]
		if not button then
			button = CreateBossButton(child)
			bosses.Buttons[index] = button
		end
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", 0, -top)
		SetBossButton(button, page.instance, boss, ns.Discovery:Unmet(page.instance, boss))
		button:Show()
		top = top + BOSS_BUTTON_HEIGHT + BOSS_SPACING
	end
	for index = #list + 1, #bosses.Buttons do
		bosses.Buttons[index]:Hide()
	end
	FitVendorCards(bosses.Buttons, #list)
	for index = headers + 1, #bosses.Headers do
		bosses.Headers[index]:Hide()
	end
	-- (top: where another plate would go, one gap below the last)
	local height = top - (#list > 0 and BOSS_SPACING or 0) + BOSS_BOTTOM_PADDING

	-- A faction's list ends with the player's own standing; a currency vendor's, with how many the player has.
	local holder = page.FactionStanding
	holder:SetShown(page.instance.kind == "faction"
		or (page.instance.kind == "currency" and ns.CurrencyCount(page.instance.currency) ~= nil))
	if holder:IsShown() then
		-- Where another standing would go, one gap further down.
		holder:ClearAllPoints()
		holder:SetPoint("TOPLEFT", 0, -(top + BOSS_SPACING))
		height = top + BOSS_SPACING + BOSS_BUTTON_HEIGHT + BOSS_BOTTOM_PADDING
		EncounterPage:RefreshStanding(page)
	end

	-- A currency vendor's list ends with where the currency comes from, where the journal knows.
	local currencyNote = page.instance.kind == "currency" and ns.CurrencyNote(page.instance.currency)
	page.CurrencyNote:SetShown(currencyNote and true or false)
	if currencyNote then
		local noteTop = top + BOSS_SPACING + (holder:IsShown() and (BOSS_BUTTON_HEIGHT + BOSS_SPACING) or 0)
		page.CurrencyNote.Text:SetText(currencyNote)
		page.CurrencyNote:ClearAllPoints()
		page.CurrencyNote:SetPoint("TOPLEFT", 0, -noteTop)
		local noteHeight = 6 + page.CurrencyNote.Text:GetStringHeight()
		page.CurrencyNote:SetHeight(noteHeight)
		height = noteTop + noteHeight + BOSS_BOTTOM_PADDING
	end

	-- A placeholder's list ends with what it waits on, and where to send a run; a faction with no
	-- quartermaster captured yet, beneath the player's standing, with how to capture one. In Adventure Mode a
	-- faction with rewards not seen yet says there where they are seen: at its quartermaster.
	local soon, instance = page.ComingSoon, page.instance
	local uncaptured = instance.kind == "faction" and not ns.FactionCaptured(instance)
	local unseen = instance.kind == "faction" and ns.Discovery:RewardsHidden(instance)
	soon:SetShown(not page.rumour and (instance.comingSoon == true or instance.untested == true or uncaptured or unseen))
	if soon:IsShown() then
		if uncaptured or unseen then
			top = top + BOSS_SPACING + BOSS_BUTTON_HEIGHT + BOSS_SPACING
		end
		-- (no run to send for rewards to find: no Discord box)
		soon.Link:SetShown(not unseen)
		if unseen then
			soon.Title:SetText(L.ADVENTURE_REP_TITLE)
			soon.Text:SetText(QuartermasterLine(instance))
		elseif uncaptured then
			if ns.FactionListed(instance) then
				soon.Title:SetText(L.REP_NOT_CAPTURED)
				soon.Text:SetText(L.REP_LISTED_TEXT)
			else
				soon.Title:SetText(instance.forever and L.COMING_SOON or L.REP_NOT_CAPTURED)
				soon.Text:SetText(instance.forever and L.REP_COMING_SOON_TEXT or L.REP_NOT_CAPTURED_TEXT)
			end
		else
			soon.Title:SetText(L.COMING_SOON)
			soon.Text:SetText(#list > 0 and L.COMING_SOON_PARTLY or L.COMING_SOON_TEXT)
		end
		soon:ClearAllPoints()
		soon:SetPoint("TOPLEFT", 0, -top)
		height = top + COMING_SOON_HEIGHT + BOSS_BOTTOM_PADDING
	end
	child:SetHeight(height)
	bosses:SetVerticalScroll(0)
end

local function HighlightSelectedBoss(page)
	for _, button in ipairs(page.Bosses.Buttons) do
		button.selected = button:IsShown() and button.boss == page.boss
		if button.selected then
			button:LockHighlight()
		else
			button:UnlockHighlight()
		end
	end
end

-- Two layouts: retail's own, for dungeons with Blizzard's lore picture (390x330 at the top
-- of the page, the name banner over it, a short lore box beneath); and a framed crop of the
-- loading screen, for Forever's dungeons, which have no journal art.
-- The overview: the picture in its frame, the name across it, Show Map at its foot, the lore below. The same
-- for every dungeon (the owner's call of 2026-11-09: retail's tall picture is gone for those with Blizzard's
-- lore art, cut to the frame instead: LORE_IMAGE_COORDS).
local function LayoutInstanceOverview(overview)
	overview.PictureBorder:Show()
	overview.Picture:ClearAllPoints()
	overview.TitleBackground:ClearAllPoints()
	overview.Lore:ClearAllPoints()
	overview.MapButton:ClearAllPoints()
	overview.Picture:SetPoint("TOPLEFT", overview.PictureBorder, 2, -2)
	overview.Picture:SetPoint("BOTTOMRIGHT", overview.PictureBorder, -2, 2)
	overview.TitleBackground:SetPoint("TOP", overview.PictureBorder, "TOP", 0, -14)
	overview.Lore:SetSize(315, 178)
	overview.Lore:SetPoint("BOTTOMLEFT", 35, 10)
	overview.MapButton:SetPoint("BOTTOMLEFT", overview.PictureBorder, "BOTTOMLEFT", 6, 8)
end

--[[
	The overview's text: the dungeon's facts (with its description's practical words where lore shows in
	its place: overviewNote), then the line pointing to Before you go on the Quests tab
	(UI/BeforeYouGo.lua) where the player's side has notes, then its lore (else its description: LoreText).
	With neither, the facts end the page, with no gap left beneath them.
]]
local LORE_GAP, POINTER_GAP = 12, 2
-- The facts' width: the lore's, less room for Spoken's Play at the box's top right (CreateInstanceOverview) where it shows.
local FACTS_WIDTH, FACTS_WIDTH_BESIDE_PLAY = 310, 310 - 18

--[[
	A dungeon's or boss's lore, else its description. Its lore is Spoken's story of it, word for word,
	wherever Spoken tells one (Core/SpokenLore.lua; the owner's decision of 2026-11-14), and nothing
	else: where Spoken has no story, the description shows, as before (the owner's decision of
	2026-11-17: "match what spoken has or leave it blank"). nil when it has neither. Only the journal's
	Overview shows lore: the map's boss pin keeps the short description (UI/DungeonMap.lua), and the
	Abilities tab only the fight note (UI/AbilitiesPanel.lua).
]]
local function HasText(text) return type(text) == "string" and text ~= "" end
-- Its lore alone (instance's, or boss's where boss is given): Spoken's story; nil where Spoken has none.
local function Lore(instance, boss)
	if boss and ns.IsLootSection(boss) then return nil end
	local spoken = ns.SpokenLore.Text(instance, boss)
	if HasText(spoken) then return spoken end
	return nil
end
local function LoreText(instance, boss)
	local lore = Lore(instance, boss)
	if lore then return lore end
	local entry = boss or instance
	if HasText(entry.description) then return entry.description end
	return nil
end
--[[
	The lore as Adventure Mode shows it (LoreText's, the boss's where boss is given): Spoken's story with only a boss
	not met and an item not seen put out (Discovery:Mask), as the CHANGELOG says. Its words name a quest only by chance
	(the Defias Brotherhood, Ramstein the Gorger's own name), so no quest's name is put out of it: the quests' mask would
	leave a story with everything found still masked, its words never lit. The journal's own description, where Spoken
	has no story, is masked as the page's other lines are (Discovery:MaskPage: its quests too).
]]
local function MaskLore(instance, text, extra, boss)
	if text ~= nil and text == Lore(instance, boss) then return ns.Discovery:Mask(instance, text, extra) end
	return ns.Discovery:MaskPage(instance, text, extra)
end

-- The lore's FontString's text (the Overview's, a boss's), set through UI/SpokenWords.lua, the one owner of it: it
-- lights Spoken's words there as Spoken reads them, only where the text is Spoken's story itself. Set before the Play
-- button beside it, whose listening asks which it is.
local function SetLoreText(fontString, text, instance, boss)
	ns.SpokenWords.SetText(fontString, text or "", text ~= nil and text == ns.SpokenLore.Text(instance, boss))
end

function EncounterPage:LayoutLore(lore)
	local y = 2 + lore.Text:GetStringHeight()
	local pointer = lore.Pointer
	if pointer:IsShown() then
		pointer:ClearAllPoints()
		pointer:SetPoint("TOPLEFT", 2, -(y + POINTER_GAP))
		local height = pointer.Text:GetStringHeight()
		pointer:SetSize(math.min(310, pointer.Text:GetStringWidth() + 2), height)
		y = y + POINTER_GAP + height
	end
	local description = lore.Description
	description:ClearAllPoints()
	description:SetPoint("TOPLEFT", 2, -(y + LORE_GAP))
	local hasText = HasText(description:GetText())
	description:SetShown(hasText)
	if hasText then y = y + LORE_GAP + description:GetStringHeight() end
	lore.Child:SetHeight(y + 4)
end

local function FillInstanceOverview(page)
	local instance, overview = page.instance, page.InstanceOverview
	LayoutInstanceOverview(overview)
	if instance.loreImage then
		SetCroppedArt(overview.Picture, instance.loreImage, LORE_IMAGE_COORDS)
	else
		SetCroppedArt(overview.Picture, instance.buttonArt, instance.loreArtCoords or LORE_COORDS)
	end
	local rumour = page.rumour == true
	ns.TintInstanceArt(overview.Picture, instance, rumour and RUMOUR_SHADE or nil)
	overview.Title:SetText(instance.name)
	overview.TitleBackground:SetWidth(math.min(380, overview.Title:GetStringWidth() + 80))
	-- (a rumour's too while the fog test is on, UI/FogTest.lua: any dungeon's map, from anywhere)
	overview.MapButton:SetShown((not rumour or (ns.FogTest ~= nil and ns.FogTest:On())) and ns.DungeonMap:HasMap(instance))

	local lore = overview.Lore
	lore.instance, lore.rumour = instance, rumour or nil
	-- A rumour: where it is and its level, nothing more.
	if rumour then
		local lines = {}
		if instance.location then lines[#lines + 1] = string.format(L.LOCATION_LINE, instance.location) end
		if instance.levelMin then
			lines[#lines + 1] = string.format(L.LEVEL_RANGE, instance.levelMin, instance.levelMax or instance.levelMin)
		end
		lore.Text:SetWidth(FACTS_WIDTH)
		lore.Text:SetText(table.concat(lines, "\n"))
		-- (no lore, so no Play beside it, and no line for Before you go: a rumour has no Quests tab)
		SetLoreText(lore.Description, nil, instance)
		ns.SpokenButton.Clear(lore.Play)
		lore.Pointer:Hide()
		EncounterPage:LayoutLore(lore)
		lore:SetVerticalScroll(0)
		return
	end

	local lines = {}
	if instance.forever then lines[#lines + 1] = ns.ForeverIconText(16) .. " " .. FOREVER_COLOR .. L.FOREVER_LINE .. "|r" end
	if instance.location then lines[#lines + 1] = string.format(L.LOCATION_LINE, instance.location) end
	if instance.levelMin then
		lines[#lines + 1] = string.format(L.LEVEL_RANGE, instance.levelMin, instance.levelMax or instance.levelMin)
	end
	-- What its door holds, as the door on the map says it (the Spire's: one instance for both its
	-- dungeons, and their group sizes), by the page's own rule of rumour.
	local notes = ns.DungeonMap:DoorNotes({ instance }, true)
	if #notes > 0 then
		lines[#lines + 1] = ""
		for _, note in ipairs(notes) do lines[#lines + 1] = note end
	end
	-- Where lore (Spoken's story) takes the description's place, the description's practical words stay in the facts
	-- (the owner's lore rule of 2026-11-13): its overviewNote, or with true the whole description (a wing's, which
	-- tells it from the others that share its dungeon's one story).
	local overviewNote = instance.overviewNote == true and instance.description or instance.overviewNote
	if HasText(overviewNote) and Lore(instance) then
		lines[#lines + 1] = ""
		-- (in Adventure Mode naming nothing not found yet, as the lore beneath)
		lines[#lines + 1] = ns.Discovery:MaskPage(instance, overviewNote, ns.Discovery:Untold(instance))
	end
	if instance.untested then
		lines[#lines + 1] = ""
		lines[#lines + 1] = UNTESTED_COLOR .. L.UNTESTED_NOTE .. "|r"
	end
	-- Spoken's Play beside the lore, where there is lore or a description to sit beside: Spoken's story is the
	-- dungeon's, and where Spoken has it, the lore is that story's words. In Adventure Mode the words name no boss not
	-- met and no item not seen (MaskLore); Spoken's words then light only where none was masked (SetLoreText: a masked
	-- text is not Spoken's story itself).
	local loreText = LoreText(instance)
	local hasLore = loreText ~= nil
	SetLoreText(lore.Description, MaskLore(instance, loreText, ns.Discovery:Untold(instance)), instance)
	if hasLore then ns.SpokenButton.Set(lore.Play, instance) else ns.SpokenButton.Clear(lore.Play) end
	lore.Text:SetWidth(hasLore and FACTS_WIDTH_BESIDE_PLAY or FACTS_WIDTH)
	lore.Text:SetText(table.concat(lines, "\n"))
	local notes = #ns.BeforeYouGo:Entries(instance)
	lore.Pointer:SetShown(notes > 0)
	lore.Pointer.Text:SetText(notes > 0 and FOREVER_COLOR
		.. (notes == 1 and L.PREPARE_POINTER_ONE or string.format(L.PREPARE_POINTER, notes)) .. "|r" or "")
	EncounterPage:LayoutLore(lore)
	lore:SetVerticalScroll(0)
end

--[[
	Hand-written notes first, then quick facts from the data. A hidden boss the players summon (summoned = true) is
	no rare and no chance meeting: where his data gives his page the bullet (summonedBullet: Lyn the Ignored, the
	owner's call of 2026-11-17), it says so where his Before you go note, above, says how (the bullet points to it).
	Where that note is no hidden boss's but a plain one naming several (the Shaper's Terrace's console bosses: "they
	arent really hidden", the owner, 2026-11-19), the bullet says you summon him, not that he is hidden.
	The fog's own summoned flag (0.40.0: Kirtonos, Gahz'rilla and the other bosses players call up, so they hold no
	fog back) gives no bullet by itself.
	In Adventure Mode (Core/Discovery.lua) an unmet boss has no notes, no level and no word of being
	rare, its abilities and adds wait until it is fought, and its loot shows only what has been seen to
	drop; the notes and its place say nothing not found yet (Discovery:Mask): no unmet boss's name, no
	ability or add before the fight, no item not seen.
]]
local function BossBullets(boss, instance)
	local Discovery = ns.Discovery
	local unmet = instance ~= nil and Discovery:Unmet(instance, boss)
	local fought = instance == nil or Discovery:Fought(instance, boss)
	local unseen = instance and Discovery:Unseen(instance, boss)
	local bullets = {}
	-- A boss with lore (Spoken's story) keeps his short description (where he waits, what he drops) at the head of
	-- the bullets, as retail keeps its practical words under the bar: the lore has its place on top. (In Adventure
	-- Mode not before he is met: his page has a line of rumour in its place.)
	if not unmet and Lore(instance, boss) and HasText(boss.description) then
		bullets[1] = Discovery:MaskPage(instance, boss.description, unseen)
	end
	if not unmet then
		for _, note in ipairs(boss.notes or {}) do bullets[#bullets + 1] = Discovery:MaskPage(instance, note, unseen) end
	end
	if boss.area then bullets[#bullets + 1] = Discovery:MaskPage(instance, string.format(L.BULLET_AREA, boss.area), unseen) end
	-- (the summoned bullet where the data gives his page one, summonedBullet: Lyn the Ignored's, since 0.39.23; the 0.40
	-- fog's summoned flag alone, on the bosses players call up, changes no page)
	if boss.summoned and not unmet then
		local note = boss.summonedBullet and instance and ns.BeforeYouGo:BossNote(instance, boss)
		if note then bullets[#bullets + 1] = note.hiddenBoss and L.BULLET_SUMMONED or L.BULLET_CALLED_UP end
	elseif boss.rare and not unmet then
		bullets[#bullets + 1] = L.BULLET_RARE
	end
	if boss.questTarget and not unmet then bullets[#bullets + 1] = L.BULLET_QUEST_TARGET end
	if boss.level and not unmet then bullets[#bullets + 1] = string.format(L.BULLET_LEVEL, boss.level) end
	if fought and boss.abilities and #boss.abilities > 0 then
		bullets[#bullets + 1] = string.format(L.BULLET_ABILITIES, NameList(boss.abilities, 6))
	end
	if fought and boss.adds and #boss.adds > 0 then
		bullets[#bullets + 1] = string.format(L.BULLET_ADDS, NameList(boss.adds, 4))
	end
	local loot = {}
	for _, row in ipairs(boss.loot or {}) do
		if not ns.Items:Unremarkable(boss, row) and (instance == nil or ns.LootPanel:Seen(instance, boss, row.itemID)) then
			loot[#loot + 1] = row
		end
	end
	if #loot > 0 then
		bullets[#bullets + 1] = string.format(L.BULLET_LOOT, #loot, NameList(loot, 4))
	end
	if #bullets == 0 then bullets[1] = L.BULLET_NOTHING_YET end
	return bullets
end

local FillBossOverview

-- A boss's note from Before you go (how to summon it: a hidden boss's, or one naming several bosses), under the
-- lore, open until the player folds it; nil and hidden for any other boss. Returns how tall it is.
local function PlaceBossNote(page, top)
	local child = page.BossOverview.Child
	local Discovery = ns.Discovery
	-- In Adventure Mode, none until the boss is met, and no unmet boss named in it (as Before you go masks it).
	local note
	if not Discovery:Unmet(page.instance, page.boss) then
		note = ns.BeforeYouGo:BossNote(page.instance, page.boss)
		if note and ns.Style:Adventure() then
			local unseen = Discovery:Unseen(page.instance, page.boss)
			note.title = Discovery:MaskAll(page.instance, note.title, unseen)
			note.description = Discovery:MaskAll(page.instance, note.description, unseen)
		end
	end
	if note and not child.bossNote then
		child.bossNote = ns.PaperHeader.Create(child, function()
			child.noteClosed = not child.noteClosed
			FillBossOverview(page)
		end)
	end
	if child.bossNote then child.bossNote:SetShown(note ~= nil) end
	if not note then return 0 end
	child.bossNote:ClearAllPoints()
	child.bossNote:SetPoint("TOPLEFT", 0, -top)
	child.bossNote:SetWidth(310)
	return ns.PaperHeader.Set(child.bossNote, note, 0, not child.noteClosed) + 9
end

FillBossOverview = function(page)
	local child = page.BossOverview.Child
	local boss = page.boss
	if child.noteBoss ~= boss then child.noteBoss, child.noteClosed = boss, false end
	-- On top, where retail's journal puts a boss's lore (its loreDescription, at 2, -8): his lore, else his
	-- description; the trash's line for the trash, the recipes' for the recipes. The hidden boss's note and the
	-- "Overview" bar come beneath.
	-- In Adventure Mode a boss not met has first one line of rumour (boss.rumour) where the data has one, else a plain
	-- line that he is not met yet; then, beneath it, his lore (Spoken's story) alone, never the journal's description
	-- (his notes wait until he is met), with every name not found yet as "???", his own too, as a dungeon's lore has
	-- them (MaskLore; the owner's call of 2026-11-18: "we can still play the lore"; the mask as it is: a full name goes,
	-- but a lone given name that is also a plain word may stay, "Cobrahn", "Rend"). A met boss's lore names no boss
	-- not met and no item not seen (MaskLore). Spoken's words light only where none was masked (SetLoreText).
	local description, unmetLine
	local unseen = ns.Discovery:Unseen(page.instance, boss)
	if ns.Discovery:Unmet(page.instance, boss) then
		unmetLine = ns.Discovery:MaskPage(page.instance, boss.rumour, unseen) or L.ADVENTURE_BOSS_UNMET
		description = MaskLore(page.instance, Lore(page.instance, boss), unseen, boss)
	else
		description = MaskLore(page.instance, LoreText(page.instance, boss), unseen, boss)
			or (boss.recipes and L.RECIPES_DESCRIPTION) or (boss.trash and L.TRASH_DESCRIPTION) or nil
	end
	local hasDescription = HasText(description)
	-- Spoken's Play beside his lore or description, and beside an unmet boss's line: his story is his, met or not, and
	-- Play reads all of it (the owner's call of 2026-11-18). None beside the trash's or the recipes' line, no boss's.
	-- The lines beside it narrower, clear of it (BOSS_LORE_WIDTH_BESIDE_PLAY); at full width where it does not show.
	local hasText = hasDescription or unmetLine ~= nil
	local width = (hasText and not ns.IsLootSection(boss)) and BOSS_LORE_WIDTH_BESIDE_PLAY or BOSS_LORE_WIDTH
	child.Unmet:SetWidth(width)
	child.Description:SetWidth(width)
	child.Unmet:SetText(unmetLine or "")
	child.Unmet:SetShown(unmetLine ~= nil)
	local top = 8 + (unmetLine and child.Unmet:GetStringHeight() + LORE_GAP or 0)
	child.Description:ClearAllPoints()
	child.Description:SetPoint("TOPLEFT", 2, -top)
	SetLoreText(child.Description, description, page.instance, boss)
	if hasText and not ns.IsLootSection(boss) then
		ns.SpokenButton.Set(child.Play, page.instance, boss)
	else
		ns.SpokenButton.Clear(child.Play)
	end
	if hasDescription then
		top = top + child.Description:GetStringHeight() + 6
	elseif unmetLine then
		top = top - LORE_GAP + 6
	else
		top = 4
	end
	top = top + PlaceBossNote(page, top)
	child.Header:ClearAllPoints()
	child.Header:SetPoint("TOPLEFT", hasText and -4 or 0, -top)

	local previous = child.Header
	local height = top + 30 + 3
	local bullets = BossBullets(boss, page.instance)
	for index, text in ipairs(bullets) do
		local bullet = child.Bullets[index]
		if not bullet then
			bullet = CreateFrame("Frame", nil, child)
			bullet:SetSize(300, 15)
			bullet.Icon = bullet:CreateTexture(nil, "ARTWORK")
			ns.Art(bullet.Icon, "PaperOverlay-Bullet")
			bullet.Icon:SetPoint("TOPLEFT")
			bullet.Text = ParchmentText(bullet, 290)
			bullet.Text:SetPoint("TOPLEFT", bullet.Icon, "TOPRIGHT", 4, 0)
			child.Bullets[index] = bullet
		end
		bullet:ClearAllPoints()
		bullet:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", index == 1 and 10 or 0, index == 1 and -9 or -6)
		bullet.Text:SetText(text)
		bullet:SetHeight(math.max(15, bullet.Text:GetStringHeight()))
		bullet:Show()
		height = height + bullet:GetHeight() + 6
		previous = bullet
	end
	for index = #bullets + 1, #child.Bullets do
		child.Bullets[index]:Hide()
	end
	child:SetHeight(height)
	page.BossOverview:SetVerticalScroll(0)
end

local function SetTabEnabled(tab, enabled)
	tab:SetEnabled(enabled)
	local disabled = tab:GetDisabledTexture()
	if disabled then disabled:SetDesaturated(not enabled) end
	tab.unselected:SetDesaturated(not enabled)
end

-- A tab closed in Adventure Mode says why: a disabled button hears the mouse only when asked to.
local function SetClosedWhy(tab, why)
	tab.closedWhy = why
	if tab.SetMotionScriptsWhileDisabled then tab:SetMotionScriptsWhileDisabled(why ~= nil) end
end

local function UpdateTabStates(page)
	local tabs = page.Tabs
	-- A rumour (Adventure Mode) has no side tabs: only its overview.
	local open = not page.rumour
	SetTabEnabled(tabs[TAB_OVERVIEW], true)
	SetTabEnabled(tabs[TAB_LOOT], open)
	-- As on retail, abilities belong to a boss: the tab waits until one is chosen. Trash and recipes have none. In
	-- Adventure Mode they wait until the boss is fought, all at once (the client can't tell which spells it
	-- used), and the model until it is met; the tab says why.
	local boss, Discovery = page.boss, ns.Discovery
	local hasAbilities = open and boss ~= nil and not ns.IsLootSection(boss)
	local fought = not hasAbilities or Discovery:Fought(page.instance, boss)
	SetTabEnabled(tabs[TAB_ABILITIES], hasAbilities and fought)
	SetClosedWhy(tabs[TAB_ABILITIES], not fought and L.ADVENTURE_ABILITIES_CLOSED or nil)
	-- The model, too, needs a boss, and one whose creature the client can draw.
	local hasModel = open and #ns.ModelPanel:Creatures(boss) > 0
	local met = not hasModel or not Discovery:Unmet(page.instance, boss)
	SetTabEnabled(tabs[TAB_MODEL], hasModel and met)
	SetClosedWhy(tabs[TAB_MODEL], not met and L.ADVENTURE_MODEL_CLOSED or nil)
	-- The quests, and Before you go's notes at their top: a dungeon with notes alone has the tab too.
	SetTabEnabled(tabs[TAB_QUESTS], open and (#page.instance.quests > 0 or #ns.BeforeYouGo:Entries(page.instance) > 0))
end

function EncounterPage:SetTab(page, tabID)
	-- (a page with nothing opened on it yet has no tabs to set)
	if not page.instance then return end
	if ns.IsRewardsPage(page.instance) then tabID = TAB_LOOT end
	if not page.Tabs[tabID] or not page.Tabs[tabID]:IsEnabled() then tabID = TAB_OVERVIEW end
	page.tab = tabID
	for _, tab in ipairs(page.Tabs) do
		local isSelected = tab:GetID() == tabID
		tab.selected:SetShown(isSelected)
		tab.unselected:SetShown(not isSelected)
		if isSelected then tab:LockHighlight() else tab:UnlockHighlight() end
	end

	local instancePage = tabID == TAB_OVERVIEW and not page.boss
	local lootPage = tabID == TAB_LOOT
	page.InstanceOverview:SetShown(instancePage)
	page.BossOverview:SetShown(tabID == TAB_OVERVIEW and page.boss ~= nil)
	page.Placeholder:SetShown(PLACEHOLDERS[tabID] ~= nil)
	page.Placeholder.Text:SetText(PLACEHOLDERS[tabID] or "")

	-- An already open page still needs redrawing for a new boss or dungeon.
	if lootPage and page.Loot:IsShown() then ns.LootPanel:Refresh(page.Loot) end
	page.Loot:SetShown(lootPage)
	local abilitiesPage = tabID == TAB_ABILITIES
	if abilitiesPage and page.Abilities:IsShown() then ns.AbilitiesPanel:Refresh(page.Abilities) end
	page.Abilities:SetShown(abilitiesPage)
	local modelPage = tabID == TAB_MODEL
	if modelPage then ns.ModelPanel:Refresh(page.Model, page.boss) end
	page.Model:SetShown(modelPage)
	-- The quests take both pages: their list replaces the boss list on the left.
	local questsPage = tabID == TAB_QUESTS
	ns.QuestsPanel:Show(page, questsPage)

	local info = page.info
	-- The right page's dark header band; the quest page goes without, as on the classic journals,
	-- and the model fills the page, its name along the bottom, as on retail.
	info.RightShadow:SetShown(not instancePage and not questsPage and not modelPage)
	-- On the loot page the header holds the filters instead, as on retail; a quest has its own title.
	info.EncounterTitle:SetShown(not instancePage and not lootPage and not questsPage and not modelPage)
	info.EncounterTitle:SetText(page.boss and ns.Discovery:BossTitle(page.instance, page.boss) or page.instance.name)
end

--[[
	A faction opens on its rewards alone: no side tabs, the Loot page on the right. The tab
	the reader had in the dungeons is kept for when they go back to one.
]]
local function SwitchKind(page, previous, instance)
	local wasFaction = ns.IsRewardsPage(previous)
	local isFaction = ns.IsRewardsPage(instance)
	if isFaction and not wasFaction then
		page.dungeonTab = page.keptTab or page.tab
		page.keptTab = nil
	elseif wasFaction and not isFaction then
		page.tab = page.dungeonTab or TAB_OVERVIEW
	end
	for _, tab in ipairs(page.Tabs) do tab:SetShown(not isFaction) end
	if isFaction then page.tab = TAB_LOOT end
end

--[[
	rumour: in Adventure Mode, a dungeon the character has not entered (UI/Journal.lua's gate decides):
	its overview alone, with no boss list and no side tabs. What the character knows is drawn as of
	Discovery:Version(): a page drawn before a find is drawn again.
]]
function EncounterPage:ShowInstance(page, instance, rumour)
	local previous = page.instance
	rumour = rumour == true
	local version = ns.Discovery:Version()
	local changed = previous ~= instance or page.rumour ~= rumour or page.drawnVersion ~= version
	page.instance, page.boss = instance, nil
	if changed then
		page.rumour, page.drawnVersion = rumour, version
		if previous ~= instance then SwitchKind(page, previous, instance) end
		for _, tab in ipairs(page.Tabs) do tab:SetShown(not ns.IsRewardsPage(instance) and not rumour) end
		local info = page.info
		info.InstanceTitle:SetText(instance.name)
		if ns.IsRewardsPage(instance) then
			SetCroppedArt(info.InstanceButton.Icon, ns.Reputation:Crest(instance), FACTION_CREST_COORDS)
		elseif instance.buttonImage then
			-- A square from the middle of Blizzard's button picture (its art fills 174x95 of 256x128).
			SetCroppedArt(info.InstanceButton.Icon, instance.buttonImage, BUTTON_IMAGE_ICON_COORDS)
		else
			SetCroppedArt(info.InstanceButton.Icon, instance.buttonArt, instance.iconArtCoords or ICON_COORDS)
		end
		-- Its tint, darkened for a rumour
		ns.TintInstanceArt(info.InstanceButton.Icon, instance, rumour and RUMOUR_SHADE or nil)
		FillBossList(page)
		if not ns.IsRewardsPage(instance) then FillInstanceOverview(page) end
	end
	HighlightSelectedBoss(page)
	UpdateTabStates(page)
	-- A rumour shows its overview alone; the tab the reader was on is kept for the next dungeon open.
	if rumour then
		page.keptTab = page.keptTab or page.tab
		self:SetTab(page, TAB_OVERVIEW)
	else
		local tab = page.keptTab or page.tab
		page.keptTab = nil
		self:SetTab(page, tab)
	end
	page:Show()
end

-- The dungeon's overview, as opening it from the list shows it (the dungeon's round icon: CreateLeftPage): no
-- boss chosen, the Overview tab, its boss list and its overview at their tops. A faction's page is its rewards.
function EncounterPage:ShowOverview(page)
	local instance = page.instance
	if not instance then return end
	ns.Journal:OpenInstance(instance)
	if not ns.IsRewardsPage(instance) then self:SetTab(page, TAB_OVERVIEW) end
	page.Bosses:SetVerticalScroll(0)
	if page.InstanceOverview and page.InstanceOverview.Lore then page.InstanceOverview.Lore:SetVerticalScroll(0) end
end

function EncounterPage:ShowBoss(page, instance, boss)
	-- Passing through another dungeon's overview (or a rumour's) must not lose the tab the reader was on.
	local wantedTab = page.keptTab or page.tab
	if page.instance ~= instance then
		local previous = page.instance
		self:ShowInstance(page, instance)
		if ns.IsRewardsPage(instance) then
			wantedTab = TAB_LOOT
		elseif ns.IsRewardsPage(previous) then
			wantedTab = page.dungeonTab or TAB_OVERVIEW
		end
	elseif page.rumour or page.drawnVersion ~= ns.Discovery:Version() then
		-- The same dungeon, drawn before a find (Adventure Mode) or as a rumour: its list again.
		self:ShowInstance(page, instance)
	end
	page.boss = boss
	-- The trash is its drops, the recipes theirs: each opens on them.
	if ns.IsLootSection(boss) then wantedTab = TAB_LOOT end
	HighlightSelectedBoss(page)
	FillBossOverview(page)
	UpdateTabStates(page)
	self:SetTab(page, wantedTab)
	page:Show()
end

EncounterPage.TAB_OVERVIEW, EncounterPage.TAB_LOOT = TAB_OVERVIEW, TAB_LOOT
EncounterPage.TAB_ABILITIES, EncounterPage.TAB_QUESTS = TAB_ABILITIES, TAB_QUESTS
EncounterPage.TAB_MODEL = TAB_MODEL

-- The boss list's level badges again: shown or not, and their colours for the player's level.
function EncounterPage:PaintLevels()
	for _, page in ipairs(pages) do
		for _, button in ipairs(page.Bosses and page.Bosses.Buttons or {}) do
			if button:IsShown() then SetLevelBadge(button) end
		end
	end
end

-- The boss list's quest badges again, as the quest log, the bags or the level change (UI/QuestMap.lua's redraw), while
-- the journal is open.
function EncounterPage:PaintQuestBadges()
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			for _, button in ipairs(page.Bosses and page.Bosses.Buttons or {}) do
				if button:IsShown() then PaintQuestBadge(button) end
			end
		end
	end
end

-- A new level changes what each boss's level means. PLAYER_LEVEL_UP comes before the client has
-- the new level; PLAYER_LEVEL_CHANGED, after.
local levelEvents = CreateFrame("Frame")
ns.RegisterEvents(levelEvents, "PLAYER_LEVEL_CHANGED")
levelEvents:SetScript("OnEvent", function() EncounterPage:PaintLevels() end)
