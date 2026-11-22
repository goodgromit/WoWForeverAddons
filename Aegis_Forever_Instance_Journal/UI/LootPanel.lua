local _, ns = ...
local L = ns.L

--[[
	The Loot tab's right page: retail's LootContainer, with its item rows (EncounterItemTemplate),
	divider rows, the filter dropdowns in the page header and the filter bar beneath them.

	On a boss page it lists that boss's loot; on the dungeon's own page it lists everything,
	each row naming its boss, as retail does. A faction's page works the same way, with its
	standings in place of bosses, and a quartermaster's card listing the rewards he sells.
	On top of retail:
	  - a star on each row marks a favourite; favourites sort to the top, and the class menu
	    can show favourites only
	  - right-click pins an item; a dungeon's pinned items stay at the top of every loot page
	    in that dungeon, whatever the filters say
	In Adventure Mode (Core/Discovery.lua) a dungeon's pages list only what the character has seen
	drop, item by item: off that boss on a boss's page, anywhere in the dungeon on its own page, its
	trash's and its recipes' (ns.IsLootSection). A row names its boss only once the item was seen off it
	and the boss is met; else it says the item drops in the dungeon. Pins and favourites stay saved,
	hidden while their item is unseen.
	The Recipes page (recipes = true) lists the dungeon's recipes, a boss's own too, which his page lists
	as well. On the dungeon's own page an item is listed once, by the first that lists it: a boss's recipe
	by its boss, so one listed by the recipes alone drops off the trash, and its row says so, as the
	trash's rows do. A Trash page's row the dungeon's bosses and rares drop instead (offBosses, the Drowned
	City's Linken's Boots of Iron: Data/Authored/Upcoming.lua's OffBosses) names them where it would name the
	trash, and its tooltip says so on either page; a Recipes page's row its bosses drop, not its trash (offBosses =
	"bosses": Forever's shared recipes, Data/Authored/SiteLoot.lua's AnyBoss) says "Any boss" the same way
	(ns.OffBossesText). A row kept though no drop of it is recorded yet (notSeen: SiteLoot.lua's NotSeen) says so
	in its tooltip, in gray, on any page; not in Adventure Mode, where a row shows only once the character has seen
	it drop.
	A faction's page lists the rewards seen at its quartermaster.
]]

local LootPanel = {}
ns.LootPanel = LootPanel

local Items = ns.Items

local BOSS_ROW_HEIGHT, INSTANCE_ROW_HEIGHT, DIVIDER_HEIGHT = 45, 64, 45
local ROW_WIDTH = 321
local FAVORITE_ATLAS = "PetJournal-FavoritesIcon"
local PIN_ATLAS = "Waypoint-MapPin-Tracked"
local QUESTION_MARK = "Interface\\Icons\\INV_Misc_QuestionMark"
local REACHED_COLOR = { 0.08, 0.42, 0.05 }
local ALL = "ALL"

------------------------------------------------------------------------------------------
-- Saved choices (per character)
------------------------------------------------------------------------------------------

-- Counts filter changes, so the filter menus are rebuilt only after one.
local filterVersion = 0

local function Filters()
	local filters = ns.charDB.lootFilters
	if not filters then
		local _, classFile = UnitClass("player")
		-- Retail opens the loot list filtered to the player's own class.
		filters = { class = classFile or ALL, armor = ALL, slot = ALL, favoritesOnly = false }
		ns.charDB.lootFilters = filters
	end
	-- The Type menu (kind of item, and a recipe's profession) came later than the others; a slot
	-- chosen before it is equipment's.
	if filters.kind == nil then filters.kind = filters.slot ~= ALL and "EQUIPMENT" or ALL end
	filters.profession = filters.profession or ALL
	return filters
end

local function ClearFilters()
	local filters = Filters()
	filters.class, filters.armor, filters.slot, filters.kind, filters.profession = ALL, ALL, ALL, ALL, ALL
	filters.favoritesOnly = false
	filterVersion = filterVersion + 1
end

local function Favorites()
	ns.charDB.favorites = ns.charDB.favorites or {}
	return ns.charDB.favorites
end

-- Pins remember where the item came from: [itemID] = { instance = key, boss = name }.
local function Pins()
	ns.charDB.pins = ns.charDB.pins or {}
	return ns.charDB.pins
end

function LootPanel:IsFavorite(itemID) return Favorites()[itemID] == true end
function LootPanel:IsPinned(itemID) return Pins()[itemID] ~= nil end

function LootPanel:ToggleFavorite(itemID)
	Favorites()[itemID] = not Favorites()[itemID] or nil
	ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON")
	self:RefreshShown()
end

function LootPanel:TogglePin(itemID, instanceKey, bossName)
	local pins = Pins()
	if pins[itemID] then
		pins[itemID] = nil
	else
		pins[itemID] = { instance = instanceKey, boss = bossName }
	end
	ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON")
	self:RefreshShown()
end

------------------------------------------------------------------------------------------
-- What to list
------------------------------------------------------------------------------------------

local function ClassName(classFile)
	if classFile == ALL then return L.ALL_CLASSES end
	for _, class in ipairs(Items:Classes()) do
		if class.classFile == classFile then return class.name end
	end
	return classFile
end

-- Every loot entry of the page: one boss's, or the whole dungeon's. The data never
-- changes, so each list is built once and kept.
local entriesCache = setmetatable({}, { __mode = "k" })

--[[
	A faction's "Any standing" wares (ns.ANY_STANDING), on every vendor's page, by profession, then cost (the owner's
	call of 2026-11-12): the recipes, plans and patterns by their profession's name (the client's, as the Type menu
	gives it), the rest after them; then those priced in gold, cheapest first, then those that cost something else
	(Merchant's Favor), by the amount; then as captured. entries[first] on are one standing's.
]]
local function CostOrder(row)
	local amount = tonumber(tostring(row.cost or ""):match("^%s*(%d+)"))
	if amount then return 1, amount end
	return 0, row.price or 0
end

local function SortAnyStanding(entries, first)
	local keyed = {}
	for index = first, #entries do
		local entry = entries[index]
		local kind, amount = CostOrder(entry.row)
		keyed[#keyed + 1] = { entry = entry, profession = entry.info.profession, kind = kind, amount = amount,
			at = index }
	end
	table.sort(keyed, function(a, b)
		if (a.profession ~= nil) ~= (b.profession ~= nil) then return a.profession ~= nil end
		if a.profession ~= b.profession then return a.profession < b.profession end
		if a.kind ~= b.kind then return a.kind < b.kind end
		if a.amount ~= b.amount then return a.amount < b.amount end
		return a.at < b.at
	end)
	for offset, item in ipairs(keyed) do entries[first + offset - 1] = item.entry end
end
LootPanel.SortAnyStanding = SortAnyStanding   -- (for the tests)

--[[
	A currency vendor's wares (Core/Registry.lua's currency vendors): gear first, by slot in the Type menu's order (the
	client's slot, known at once), then the rest; within a slot the cheapest first, then as captured. entries[first]
	on are one vendor's.
]]
local SLOT_RANK = {}
for index, slot in ipairs(Items.SLOT_ORDER) do SLOT_RANK[slot] = index end

local function SortVendorWares(entries, first)
	local keyed = {}
	for index = first, #entries do
		local entry = entries[index]
		local kind, amount = CostOrder(entry.row)
		local slot = entry.info.kind == "EQUIPMENT" and SLOT_RANK[entry.info.slot] or #Items.SLOT_ORDER + 1
		keyed[#keyed + 1] = { entry = entry, slot = slot, kind = kind, amount = amount, at = index }
	end
	table.sort(keyed, function(a, b)
		if a.slot ~= b.slot then return a.slot < b.slot end
		if a.kind ~= b.kind then return a.kind < b.kind end
		if a.amount ~= b.amount then return a.amount < b.amount end
		return a.at < b.at
	end)
	for offset, item in ipairs(keyed) do entries[first + offset - 1] = item.entry end
end
LootPanel.SortVendorWares = SortVendorWares   -- (for the tests)

-- How many rows the sources hold, and the wares a quartermaster's card sells: a list kept for fewer is built again (a
-- capture added to a faction or a vendor).
local function RowCount(sources, sells)
	local count = 0
	for _, source in ipairs(sources) do count = count + #(source.loot or {}) end
	for _ in pairs(sells or {}) do count = count + 1 end
	return count
end

local function Entries(instance, boss)
	local key = boss or instance
	-- A quartermaster's card on a faction's page (Core/Registry.lua's FACTION_VENDOR_CARDS): the faction's rewards he
	-- sells, each under its standing, which its row names as on the faction's own list.
	local sells = boss and boss.vendor and instance.kind == "faction" and boss.sells or nil
	local sources = (boss and not sells) and { boss } or instance.bosses
	local entries = entriesCache[key]
	if entries and entries.rowCount == RowCount(sources, sells) then return entries end
	entries = {}
	for _, source in ipairs(sources) do
		local first = #entries + 1
		for _, row in ipairs(source.loot or {}) do
			if not sells or sells[row.itemID] then
				entries[#entries + 1] = { itemID = row.itemID, row = row, boss = source, info = Items:Get(row.itemID, row) }
			end
		end
		if source.standing and source.reaction == ns.ANY_STANDING then SortAnyStanding(entries, first) end
		if source.vendor then SortVendorWares(entries, first) end
	end
	entries.rowCount = RowCount(sources, sells)
	entriesCache[key] = entries
	return entries
end

local function Wipe(list)
	for key in pairs(list) do list[key] = nil end
	return list
end

--[[
	Whether the character has seen an item drop where a page lists it (always, outside Adventure Mode):
	off a boss, or anywhere in the dungeon for its own page (no boss), its trash's and its recipes'; a
	faction's reward, at its quartermaster.
]]
function LootPanel:Seen(instance, boss, itemID)
	if instance.kind == "faction" then return ns.Discovery:Knows("reward", instance, itemID) end
	if boss and not ns.IsLootSection(boss) then return ns.Discovery:Knows("item", itemID, instance, boss) end
	return ns.Discovery:Knows("item", itemID, instance)
end

-- Whether a row may name its boss: seen off it, and the boss met. A faction's reward names its standing.
local function NamesBoss(instance, entry)
	if entry.boss.standing then return true end
	return ns.Discovery:Knows("item", entry.itemID, instance, entry.boss) and not ns.Discovery:Unmet(instance, entry.boss)
end

--[[
	The class shows what it can use (Items:ClassCanUse). The armor type narrows only the pieces that come in one
	(info.armor: cloth, leather, mail or plate): weapons, shields, jewelry, cloaks, trinkets, off-hands and anything
	not worn stay, for the class to judge. A shield is no armor type: the classes that carry one wear more than one as
	they level (a shaman leather, then mail; a warrior or paladin mail, then plate).
]]
local function PassesFilters(entry, filters)
	local info = entry.info
	if filters.favoritesOnly and not LootPanel:IsFavorite(entry.itemID) then return false end
	if filters.class ~= ALL and not Items:ClassCanUse(filters.class, info) then return false end
	if filters.armor ~= ALL and info.armor and info.armor ~= filters.armor then return false end
	if filters.kind ~= ALL and info.kind ~= filters.kind then return false end
	if filters.slot ~= ALL and info.slot ~= filters.slot then return false end
	if filters.profession ~= ALL and info.profession ~= filters.profession then return false end
	return true
end

-- Scratch lists, reused by every redraw rather than made anew; only one page shows at a time.
local pinned, favorites, others, seen, rows = {}, {}, {}, {}, {}
local pinnedHeader, restHeader = { header = L.LOOT_PINNED }, {}
-- Adventure Mode: whether the page's loot is the character's finds; the entries not seen yet; on the
-- dungeon's own page, the entry each item is listed by (one off a boss it was seen off).
local gated = false
local unseen, listedBy, pinnedAt = {}, {}, {}

-- The rows to draw: pinned items of this dungeon first, then the filtered list with
-- favourites at the top. Each row is an entry or a divider { header = text }.
local function BuildRows(instance, boss)
	local filters = Filters()
	local pins = Pins()
	Wipe(pinned)
	Wipe(favorites)
	Wipe(others)
	Wipe(seen)
	Wipe(rows)
	Wipe(unseen)
	Wipe(listedBy)
	Wipe(pinnedAt)
	gated = ns.Style:Adventure()

	-- Items:Get keeps each item's info, and brings in a name the server has sent since.
	local all = Entries(instance, boss)
	for _, entry in ipairs(all) do
		if entry.info.pending then Items:Get(entry.itemID, entry.row) end
	end

	-- Items the server knows nothing of stay hidden until confirmed, and a name-only item gives
	-- way to its real one once that has come in (Core/Items.lua).
	for _, entry in ipairs(all) do
		if Items:IsHidden(entry.itemID) or Items:Superseded(entry.boss, entry.row) or Items:Unremarkable(entry.boss, entry.row) then
			seen[entry.itemID] = true
		end
	end
	-- Adventure Mode: what has not been seen drop is left out as those are. On the dungeon's own page an
	-- item many bosses drop is listed by one it was seen off, where there is one.
	local found = 0
	if gated then
		for _, entry in ipairs(all) do
			if not LootPanel:Seen(instance, boss, entry.itemID) then
				unseen[entry] = true
			elseif not seen[entry.itemID] then
				found = found + 1
				if not boss then
					local first = listedBy[entry.itemID]
					if not first or (not NamesBoss(instance, first) and NamesBoss(instance, entry)) then
						listedBy[entry.itemID] = entry
					end
				end
			end
		end
	end

	-- Pinned items come from the whole dungeon, so they show on every boss's page. In Adventure Mode one
	-- seen in the dungeon, listed by a boss it was seen off where there is one.
	for _, entry in ipairs(Entries(instance, nil)) do
		local pin = pins[entry.itemID]
		if pin and pin.instance == instance.key and not seen[entry.itemID] and not Items:IsHidden(entry.itemID)
			and not (gated and not LootPanel:Seen(instance, nil, entry.itemID)) then
			pinned[#pinned + 1] = entry
			pinnedAt[entry.itemID] = #pinned
			seen[entry.itemID] = true
		elseif gated and pin and pinnedAt[entry.itemID] then
			local at = pinnedAt[entry.itemID]
			if not NamesBoss(instance, pinned[at]) and NamesBoss(instance, entry) then pinned[at] = entry end
		end
	end

	for _, entry in ipairs(all) do
		local by = listedBy[entry.itemID]
		if not seen[entry.itemID] and not unseen[entry] and (not by or by == entry) and PassesFilters(entry, filters) then
			if LootPanel:IsFavorite(entry.itemID) then
				favorites[#favorites + 1] = entry
			else
				others[#others + 1] = entry
			end
			seen[entry.itemID] = true
		end
	end

	if #pinned > 0 then
		rows[#rows + 1] = pinnedHeader
		for _, entry in ipairs(pinned) do rows[#rows + 1] = entry end
		if #favorites + #others > 0 then
			restHeader.header = boss and (ns.Discovery:Unmet(instance, boss) and ns.Discovery.UNKNOWN or boss.name)
				or (ns.IsRewardsPage(instance) and L.REP_ALL_REWARDS or L.LOOT_ALL)
			rows[#rows + 1] = restHeader
		end
	end
	for _, entry in ipairs(favorites) do rows[#rows + 1] = entry end
	for _, entry in ipairs(others) do rows[#rows + 1] = entry end
	return rows, all, not gated or found > 0
end

------------------------------------------------------------------------------------------
-- Rows
------------------------------------------------------------------------------------------

local function ShowTooltip(row)
	-- The row names its boss: the item's tooltip names only the other dungeons it drops in. A Trash page's row that
	-- the bosses and rares drop says so here, on the Trash page as on the dungeon's own.
	ns.ItemTooltip:UseSource(row, row.itemID, row.instanceKey and ns.GetInstance(row.instanceKey))
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	if row.link then
		GameTooltip:SetHyperlink(row.link)
	elseif row.unidentified then
		-- Known by name only: the client has nothing to show for it.
		GameTooltip:SetText(row.Name:GetText() or "", 1, 1, 1)
		if row.slotText and row.slotText ~= "" then GameTooltip:AddLine(row.slotText, 1, 1, 1) end
		GameTooltip:AddLine(L.LOOT_UNIDENTIFIED_TOOLTIP, 0.6, 0.6, 0.6, true)
	elseif row.unavailable then
		-- The client's tooltip would say "Retrieving item information" for ever.
		GameTooltip:SetText(row.Name:GetText() or "", 1, 1, 1)
		GameTooltip:AddLine(L.LOOT_NO_DATA_TOOLTIP, 0.6, 0.6, 0.6, true)
	else
		GameTooltip:SetItemByID(row.itemID)
	end
	local _, offNote = ns.OffBossesText(row)
	if offNote then GameTooltip:AddLine(offNote, 1, 0.82, 0, true) end
	if row.notSeen then GameTooltip:AddLine(L.LOOT_NOT_SEEN_NOTE, 0.6, 0.6, 0.6, true) end
	GameTooltip:AddLine(" ")
	if LootPanel:IsPinned(row.itemID) then
		GameTooltip:AddLine(L.LOOT_TOOLTIP_UNPIN, 0.5, 0.8, 1)
	else
		GameTooltip:AddLine(L.LOOT_TOOLTIP_PIN, 0.5, 0.8, 1)
	end
	GameTooltip:Show()
	if type(GameTooltip_ShowCompareItem) == "function" and IsModifiedClick and IsModifiedClick("COMPAREITEMS") then
		pcall(GameTooltip_ShowCompareItem)
	end
end

local function CreateItemRow(parent)
	local row = CreateFrame("Button", nil, parent)
	row:SetSize(ROW_WIDTH, BOSS_ROW_HEIGHT)
	row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	row.Icon = row:CreateTexture(nil, "BACKGROUND")
	row.Icon:SetSize(42, 42)
	row.Icon:SetPoint("TOPLEFT", 2, -2)

	row.BossFrame = row:CreateTexture(nil, "BORDER")
	ns.Art(row.BossFrame, "DungeonLootFrame")
	row.BossFrame:SetPoint("LEFT")
	row.Frame = row:CreateTexture(nil, "BORDER")
	ns.Art(row.Frame, "LootFrame")
	row.Frame:SetPoint("LEFT")

	row.IconBorder = row:CreateTexture(nil, "OVERLAY", nil, 1)
	row.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
	row.IconBorder:SetAllPoints(row.Icon)

	row.Name = row:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalMed3", "GameFontNormal"))
	row.Name:SetSize(250, 12)
	row.Name:SetPoint("TOPLEFT", row.Icon, "TOPRIGHT", 7, -7)
	row.Name:SetJustifyH("LEFT")

	row.ArmorType = row:CreateFontString(nil, "OVERLAY", "GameFontBlack")
	row.ArmorType:SetHeight(12)
	row.ArmorType:SetPoint("BOTTOMRIGHT", row.Name, "TOPLEFT", 264, -30)
	row.ArmorType:SetJustifyH("RIGHT")
	row.Slot = row:CreateFontString(nil, "OVERLAY", "GameFontBlack")
	row.Slot:SetHeight(12)
	row.Slot:SetPoint("BOTTOMLEFT", row.Icon, "BOTTOMRIGHT", 7, 5)
	row.Slot:SetPoint("BOTTOMRIGHT", row.ArmorType, "BOTTOMLEFT", -15, 0)
	row.Slot:SetJustifyH("LEFT")
	row.Boss = row:CreateFontString(nil, "OVERLAY", "GameFontBlack")
	row.Boss:SetHeight(12)
	row.Boss:SetPoint("TOPLEFT", row.Icon, "BOTTOMLEFT", 0, -3)
	row.Boss:SetJustifyH("LEFT")
	for _, text in ipairs({ row.ArmorType, row.Slot, row.Boss }) do
		local color = ns.PARCHMENT_TEXT_COLOR
		text:SetTextColor(color[1], color[2], color[3])
	end

	-- The favourite star: always shown on favourites, faintly on the row under the mouse.
	row.Star = CreateFrame("Button", nil, row)
	row.Star:SetSize(18, 18)
	row.Star:SetPoint("TOPRIGHT", -4, -4)
	row.Star.Icon = row.Star:CreateTexture(nil, "OVERLAY")
	row.Star.Icon:SetAllPoints()
	row.Star.Icon:SetAtlas(FAVORITE_ATLAS)
	row.Star:SetScript("OnClick", function() LootPanel:ToggleFavorite(row.itemID) end)
	row.Star:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(LootPanel:IsFavorite(row.itemID) and L.LOOT_UNFAVORITE or L.LOOT_FAVORITE)
		GameTooltip:Show()
		row.Star:SetAlpha(1)
	end)
	row.Star:SetScript("OnLeave", function()
		GameTooltip:Hide()
		LootPanel:UpdateStar(row, false)
	end)

	row.Pin = row:CreateTexture(nil, "OVERLAY", nil, 3)
	row.Pin:SetAtlas(PIN_ATLAS)
	row.Pin:SetSize(16, 16)
	row.Pin:SetPoint("RIGHT", row.Star, "LEFT", -2, 0)

	-- A brief glow when a search brings the row into view.
	row.Flash = row:CreateTexture(nil, "OVERLAY", nil, 4)
	row.Flash:SetAllPoints()
	row.Flash:SetColorTexture(1, 0.82, 0.2, 0.3)
	row.Flash:SetBlendMode("ADD")
	row.Flash:Hide()

	row:SetScript("OnEnter", function(self)
		ShowTooltip(self)
		LootPanel:UpdateStar(self, true)
	end)
	row:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		LootPanel:UpdateStar(self, false)
	end)
	row:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			LootPanel:TogglePin(self.itemID, self.instanceKey, self.bossName)
		elseif not ns.Gamepad:ItemClick(self.link) then
			ns.PlaySoundKit("IG_MAINMENU_OPTION")
		end
	end)
	return row
end

function LootPanel:UpdateStar(row, hovered)
	local favorite = self:IsFavorite(row.itemID)
	row.Star:SetShown(favorite or hovered)
	row.Star.Icon:SetDesaturated(not favorite)
	row.Star:SetAlpha(favorite and 1 or 0.45)
end

-- What a faction's reward costs at its quartermaster: coins, then any other cost; nil if unknown.
-- What a row that is not equipment shows where a slot would go, in the client's words: "Recipe, Alchemy", "Mount",
-- "Quest Item" (the line the game's tooltip gives a quest item); nil where the client cannot describe it.
local function KindText(info)
	if info.kind == "RECIPE" then
		local recipe = info.itemType or L.LOOT_RECIPE
		return info.profession and (recipe .. ", " .. info.profession) or recipe
	end
	if info.kind == "MOUNT" or info.kind == "PET" or info.kind == "TOY" then return L.LOOT_KIND_ONE[info.kind] end
	if info.kind == "QUEST" then return Items:QuestItemText() end
	if info.itemType and info.subType and info.subType ~= "" and info.subType ~= info.itemType then
		return info.itemType .. ", " .. info.subType
	end
	return info.itemType ~= "" and info.itemType or nil
end

local function CostText(lootRow)
	local parts = {}
	if type(lootRow.price) == "number" and lootRow.price > 0 then parts[#parts + 1] = ns.MoneyText(lootRow.price) end
	-- A currency as the merchant shows it, its amount and its icon; anything else in words.
	if lootRow.cost then parts[#parts + 1] = ns.CostIcons(lootRow.enCost or lootRow.cost) or lootRow.cost end
	return #parts > 0 and table.concat(parts, " + ") or nil
end

--[[
	Fills a row for an entry. A row remembers what it drew last (row.drawn*), and only what
	changed is set again: redraws mostly come from item data arriving or a filter changing,
	and leave most rows as they were. reaction is the player's standing with the faction on
	a faction's page, else nil.
]]
local function SetItemRow(row, entry, instanceView, instance, reaction)
	local info = entry.info
	row.itemID, row.link = entry.itemID, info.link
	row.instanceKey, row.bossName = instance.key, entry.boss.name
	-- (the data's slot words in the player's language, for an item known by its name alone: its tooltip)
	row.unavailable, row.unidentified = info.unavailable, info.unidentified
	row.slotText = info.unidentified and Items:Words(entry.row.slot) or nil

	local reached = entry.boss.standing and reaction ~= nil and reaction >= entry.boss.reaction or false
	-- In Adventure Mode a boss is named only once the item was seen off it and the boss met.
	local section = ns.IsLootSection(entry.boss)
	row.offBosses = section and entry.row.offBosses or nil
	-- (not seen dropping yet: no such line in Adventure Mode, whose rows are the character's own finds)
	row.notSeen = not gated and entry.row.notSeen or nil
	local inDungeon = gated and not section and not NamesBoss(instance, entry)
	if row.drawnEntry ~= entry or row.drawnView ~= instanceView or row.drawnReached ~= reached
		or row.drawnInDungeon ~= inDungeon then
		row.drawnEntry, row.drawnView, row.drawnReached, row.drawnName = entry, instanceView, reached, nil
		row.drawnInDungeon = inDungeon
		row:SetHeight(instanceView and INSTANCE_ROW_HEIGHT or BOSS_ROW_HEIGHT)
		row.BossFrame:SetShown(instanceView)
		row.Frame:SetShown(not instanceView)
		row.Boss:SetShown(instanceView)
		if entry.boss.standing or entry.boss.vendor then
			-- A faction's reward names the standing it needs, green once the player has it; a currency vendor's ware,
			-- the vendor.
			row.Boss:SetText(entry.boss.name)
		elseif inDungeon then
			row.Boss:SetText(string.format(L.ADVENTURE_LOOT_IN_DUNGEON, instance.name))
		else
			-- (the recipes' own: off the trash, as a boss's recipe is listed by its boss: above; a Trash page's row the
			-- bosses and rares drop: them; a Recipes page's row the bosses drop: "Any boss")
			local source = section and (ns.OffBossesText(row) or L.LOOT_TRASH) or entry.boss.name
			row.Boss:SetText(string.format(L.LOOT_BOSS_LINE, source))
		end
		local lineColor = reached and REACHED_COLOR or ns.PARCHMENT_TEXT_COLOR
		row.Boss:SetTextColor(lineColor[1], lineColor[2], lineColor[3])
		row.Icon:SetTexture(info.icon or QUESTION_MARK)
		-- The client's words for what the item is; the data's, in the player's language, only where it has none.
		local slot = info.equipLoc and _G[info.equipLoc] or KindText(info) or Items:Words(entry.row.slot)
		local cost = (entry.boss.standing or entry.boss.vendor) and CostText(entry.row)
		if cost then
			-- A faction's reward: what its quartermaster asks, where the armour type would go.
			local kind = info.equipLoc and info.subType ~= "" and info.subType or nil
			row.Slot:SetText(slot and kind and (slot .. ", " .. kind) or slot or kind or "")
			row.ArmorType:SetText(cost)
		else
			row.Slot:SetText(slot or "")
			row.ArmorType:SetText(info.equipLoc and info.subType or "")
		end
	end

	-- The name and its colour change when the server's answer comes in.
	local name = info.name or (info.unavailable and string.format(L.LOOT_NO_DATA, entry.itemID)) or L.LOOT_RETRIEVING
	if row.drawnName ~= name or row.drawnQuality ~= info.quality then
		row.drawnName, row.drawnQuality = name, info.quality
		local r, g, b = Items:QualityColor(info.quality)
		row.Name:SetText(name)
		row.Name:SetTextColor(r, g, b)
		row.IconBorder:SetVertexColor(r, g, b)
		row.IconBorder:SetShown(info.quality ~= nil and info.quality >= 2)
	end

	row.Pin:SetShown(LootPanel:IsPinned(entry.itemID))
	LootPanel:UpdateStar(row, false)
end

local function CreateDivider(parent)
	local divider = CreateFrame("Frame", nil, parent)
	divider:SetSize(ROW_WIDTH, DIVIDER_HEIGHT)
	divider.Name = divider:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalMed3", "GameFontNormal"))
	divider.Name:SetPoint("TOPLEFT", 0, -22)
	divider.Name:SetJustifyH("LEFT")
	return divider
end

------------------------------------------------------------------------------------------
-- Dropdowns and the filter bar
------------------------------------------------------------------------------------------

local function SetFilter(key, value)
	Filters()[key] = value
	filterVersion = filterVersion + 1
	LootPanel:RefreshShown()
end

local function Radio(root, text, key, value)
	root:CreateRadio(text, function() return Filters()[key] == value end, function() SetFilter(key, value) end)
end

-- The journal's own dropdown (UI/Art.lua's ns.Menus), never the game's: one the journal built there tainted the
-- game's unit menus after it (the owner's taint log of 2026-11-08).
local function CreateDropdown(parent, width, generator)
	local dropdown = ns.Menus:NewDropdown(parent, width)
	dropdown:SetupMenu(generator)
	return dropdown
end

local function CreateFilters(container, info)
	container.ClassFilter = CreateDropdown(container, 110, function(_, root)
		Radio(root, L.ALL_CLASSES, "class", ALL)
		for _, class in ipairs(Items:Classes()) do
			Radio(root, class.name, "class", class.classFile)
		end
		if root.CreateDivider then root:CreateDivider() end
		if root.CreateCheckbox then
			root:CreateCheckbox(L.LOOT_FAVORITES_ONLY, function() return Filters().favoritesOnly end,
				function() SetFilter("favoritesOnly", not Filters().favoritesOnly) end)
		end
	end)
	container.ArmorFilter = CreateDropdown(container, 95, function(_, root)
		Radio(root, L.ALL_ARMOR, "armor", ALL)
		local present = container.presentArmor or {}
		for _, subclassID in ipairs(Items.ARMOR_ORDER) do
			if present[subclassID] or Filters().armor == subclassID then
				Radio(root, Items:ArmorName(subclassID), "armor", subclassID)
			end
		end
	end)
	--[[
		What kind of item: equipment (by slot, in place of retail's slot menu), recipes (by
		profession), consumables, mounts, pets, toys and the rest. Each choice sets the kind, and
		the slot or profession under it; only what the page's loot has is offered.
	]]
	container.TypeFilter = CreateDropdown(container, 105, function(_, root)
		local function Choose(parent, text, kind, slot, profession)
			slot, profession = slot or ALL, profession or ALL
			parent:CreateRadio(text, function()
				local filters = Filters()
				return filters.kind == kind and filters.slot == slot and filters.profession == profession
			end, function()
				local filters = Filters()
				filters.kind, filters.slot, filters.profession = kind, slot, profession
				filterVersion = filterVersion + 1
				LootPanel:RefreshShown()
			end)
		end
		local filters = Filters()
		local kinds = container.presentKinds or {}
		Choose(root, L.ALL_TYPES, ALL)
		for _, kind in ipairs(Items.KIND_ORDER) do
			if kinds[kind] or filters.kind == kind then
				if kind == "EQUIPMENT" or kind == "RECIPE" then
					local menu = root.CreateButton and root:CreateButton(L.LOOT_KIND[kind]) or root
					Choose(menu, L.LOOT_KIND_ALL[kind], kind)
					if kind == "EQUIPMENT" then
						local slots = container.presentSlots or {}
						for _, slot in ipairs(Items.SLOT_ORDER) do
							if slots[slot] or filters.slot == slot then Choose(menu, Items.SLOT_NAMES[slot], kind, slot) end
						end
					else
						for _, profession in ipairs(container.presentProfessions or {}) do
							Choose(menu, profession, kind, nil, profession)
						end
					end
				else
					Choose(root, L.LOOT_KIND[kind], kind)
				end
			end
		end
	end)

	-- In the right page's header, where retail places its class and slot filters.
	container.Dropdowns = {}
	for _, dropdown in ipairs({ container.ClassFilter, container.ArmorFilter, container.TypeFilter }) do
		if dropdown then container.Dropdowns[#container.Dropdowns + 1] = dropdown end
	end
	for index, dropdown in ipairs(container.Dropdowns) do
		if index == 1 then
			dropdown:SetPoint("TOPLEFT", info, "TOPRIGHT", -348, -13)
		else
			dropdown:SetPoint("LEFT", container.Dropdowns[index - 1], "RIGHT", 6, 0)
		end
	end

	-- Retail's "Class Filter: X" strip, here naming every active filter, with its clear button.
	local bar = CreateFrame("Frame", nil, container)
	bar:SetSize(355, 28)
	bar:SetPoint("BOTTOM", container, "TOP", -10, -27)
	bar:EnableMouse(true)
	bar.Background = bar:CreateTexture(nil, "BACKGROUND")
	ns.Art(bar.Background, "FilterBar")
	bar.Background:SetSize(380, 28)
	bar.Background:SetPoint("CENTER", -5, 0)
	bar.Text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bar.Text:SetPoint("LEFT", 25, 2)
	bar.Text:SetTextColor(0.973, 0.902, 0.581)
	bar.Clear = CreateFrame("Button", nil, bar)
	bar.Clear:SetSize(20, 20)
	bar.Clear:SetPoint("RIGHT", -20, 2)
	bar.Clear.Icon = bar.Clear:CreateTexture(nil, "ARTWORK")
	bar.Clear.Icon:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
	bar.Clear.Icon:SetSize(17, 17)
	bar.Clear.Icon:SetPoint("TOPLEFT")
	bar.Clear.Icon:SetAlpha(0.8)
	bar.Clear:SetScript("OnEnter", function(self) self.Icon:SetAlpha(1) end)
	bar.Clear:SetScript("OnLeave", function(self) self.Icon:SetAlpha(0.8) end)
	bar.Clear:SetScript("OnClick", function()
		ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON")
		ClearFilters()
		LootPanel:RefreshShown()
	end)
	container.FilterBar = bar
end

local function FilterSummary()
	local filters, parts = Filters(), {}
	if filters.class ~= ALL then parts[#parts + 1] = ClassName(filters.class) end
	if filters.armor ~= ALL then parts[#parts + 1] = Items:ArmorName(filters.armor) end
	-- The kind, or what narrows it: "Head" says equipment, "Alchemy" says recipes.
	if filters.slot ~= ALL then
		parts[#parts + 1] = Items.SLOT_NAMES[filters.slot]
	elseif filters.profession ~= ALL then
		parts[#parts + 1] = filters.profession
	elseif filters.kind ~= ALL then
		parts[#parts + 1] = L.LOOT_KIND[filters.kind]
	end
	if filters.favoritesOnly then parts[#parts + 1] = L.LOOT_FAVORITES end
	if #parts == 0 then return nil end
	return string.format(L.LOOT_FILTER_BAR, table.concat(parts, ", "))
end

------------------------------------------------------------------------------------------
-- The container
------------------------------------------------------------------------------------------

function LootPanel:Create(page, info)
	local container = CreateFrame("Frame", nil, info)
	container:SetSize(345, 382)
	container:SetPoint("BOTTOMRIGHT", -5, 1)
	container:SetFrameLevel(info:GetFrameLevel() + 5)
	container:Hide()
	container.page = page

	CreateFilters(container, info)

	local scroll = ns.CreateScrollFrame(container, 5, -5, 5)
	scroll:SetPoint("BOTTOMRIGHT", -20, 1)
	scroll.Child:SetWidth(ROW_WIDTH)
	container.Scroll = scroll
	container.Rows, container.Dividers = {}, {}

	container.Empty = scroll.Child:CreateFontString(nil, "OVERLAY", "GameFontBlack")
	container.Empty:SetPoint("TOPLEFT", 2, -8)
	container.Empty:SetWidth(300)
	container.Empty:SetJustifyH("LEFT")
	local color = ns.PARCHMENT_TEXT_COLOR
	container.Empty:SetTextColor(color[1], color[2], color[3])

	container:SetScript("OnShow", function() LootPanel:Refresh(container) end)

	-- Names and icons arrive from the server a moment after first being asked for.
	container:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	container:SetScript("OnEvent", function(self)
		if self:IsVisible() and not self.refreshQueued then
			self.refreshQueued = true
			C_Timer.After(0.1, function()
				self.refreshQueued = nil
				if self:IsVisible() then LootPanel:Refresh(self) end
			end)
		end
	end)

	LootPanel.container = container
	return container
end

function LootPanel:RefreshShown()
	local container = self.container
	if container and container:IsVisible() then self:Refresh(container) end
end

local function ShownRow(container, itemID)
	for _, row in ipairs(container.Rows) do
		if row:IsShown() and row.itemID == itemID then return row end
	end
	return nil
end

--[[
	Brings an item's row into view and makes it glow for a moment, for the search. An item
	the filters hide is shown by clearing them, as the filter bar would.
]]
function LootPanel:Reveal(itemID)
	local container = self.container
	if not (container and container:IsShown()) then return false end
	local row = ShownRow(container, itemID)
	if not row then
		-- In Adventure Mode an item not seen yet has no row: the filters stay as the reader set them.
		local page = container.page
		if ns.Style:Adventure() and page and page.instance and not self:Seen(page.instance, page.boss, itemID) then
			return false
		end
		ClearFilters()
		self:Refresh(container)
		row = ShownRow(container, itemID)
		if not row then return false end
	end
	container.revealedItemID = itemID
	-- The scroll range is known once the client has laid the list out.
	C_Timer.After(0, function()
		local scroll = container.Scroll
		scroll:SetVerticalScroll(math.min(row.drawnY or 0, scroll:GetVerticalScrollRange()))
	end)
	row.Flash:Show()
	C_Timer.After(1.5, function() row.Flash:Hide() end)
	return true
end

function LootPanel:Refresh(container)
	local page = container.page
	local instance, boss = page.instance, page.boss
	if not instance then return end
	local instanceView = boss == nil

	local rows, all, anySeen = BuildRows(instance, boss)
	local standing = instance.kind == "faction" and ns.Reputation:Player(instance.factionID)
	local reaction = standing and standing.reaction or nil

	-- The armour and type menus offer only what this page's loot actually has.
	container.presentArmor = Wipe(container.presentArmor or {})
	container.presentSlots = Wipe(container.presentSlots or {})
	container.presentKinds = Wipe(container.presentKinds or {})
	container.presentProfessions = Wipe(container.presentProfessions or {})
	local professions = {}
	for _, entry in ipairs(all) do
		if not Items:IsHidden(entry.itemID) and not Items:Superseded(entry.boss, entry.row)
			and not Items:Unremarkable(entry.boss, entry.row) and not unseen[entry] then
			local info = entry.info
			if info.armor then container.presentArmor[info.armor] = true end
			container.presentKinds[info.kind] = true
			if info.kind == "EQUIPMENT" then container.presentSlots[info.slot] = true end
			if info.profession and not professions[info.profession] then
				professions[info.profession] = true
				container.presentProfessions[#container.presentProfessions + 1] = info.profession
			end
		end
	end
	local chosen = Filters().profession
	if chosen ~= ALL and not professions[chosen] then
		container.presentProfessions[#container.presentProfessions + 1] = chosen
	end
	table.sort(container.presentProfessions)
	-- The menus only change with the page or the filters.
	if container.menuInstance ~= instance or container.menuBoss ~= boss or container.menuFilters ~= filterVersion then
		container.menuInstance, container.menuBoss, container.menuFilters = instance, boss, filterVersion
		for _, dropdown in ipairs(container.Dropdowns) do
			if dropdown.GenerateMenu then dropdown:GenerateMenu() end
		end
	end

	local summary = FilterSummary()
	container.FilterBar:SetShown(summary ~= nil)
	container.FilterBar.Text:SetText(summary or "")
	container.Scroll:ClearAllPoints()
	container.Scroll:SetPoint("BOTTOMRIGHT", -20, 1)
	if summary then
		container.Scroll:SetPoint("TOPLEFT", container.FilterBar, "BOTTOMLEFT", 14, 7)
	else
		container.Scroll:SetPoint("TOPLEFT", 0, 0)
	end

	local child = container.Scroll.Child
	local y, rowIndex, dividerIndex = 0, 0, 0
	for _, entry in ipairs(rows) do
		local frame
		if entry.header then
			dividerIndex = dividerIndex + 1
			frame = container.Dividers[dividerIndex] or CreateDivider(child)
			container.Dividers[dividerIndex] = frame
			frame.Name:SetText(entry.header)
		else
			rowIndex = rowIndex + 1
			frame = container.Rows[rowIndex] or CreateItemRow(child)
			container.Rows[rowIndex] = frame
			SetItemRow(frame, entry, instanceView or entry.boss ~= boss, instance, reaction)
		end
		if frame.drawnY ~= y then
			frame.drawnY = y
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", 0, -y)
		end
		frame:Show()
		y = y + frame:GetHeight()
	end
	for index = rowIndex + 1, #container.Rows do container.Rows[index]:Hide() end
	for index = dividerIndex + 1, #container.Dividers do container.Dividers[index]:Hide() end

	container.Empty:SetShown(#rows == 0)
	-- Adventure Mode: nothing seen to drop yet.
	container.Empty:SetText(#all == 0 and L.LOOT_NONE
		or not anySeen and (instance.kind == "faction" and L.ADVENTURE_REP_NONE_SEEN or L.ADVENTURE_LOOT_NONE)
		or L.LOOT_NO_MATCH)
	child:SetHeight(math.max(1, y))
	container.rows = rows
end
