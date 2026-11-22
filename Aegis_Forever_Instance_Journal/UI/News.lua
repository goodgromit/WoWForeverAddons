local _, ns = ...
local L = ns.L

--[[
	Adventure Mode's news (Core/Style.lua): what the character finds that is new to its journal is told in
	one line in the chat, "New in your journal: <names>", and lights the journal's minimap button
	(UI/MinimapButton.lua's glow) until the journal is next opened. Each has its own box in the options
	(UI/Options.lua), ticked unless unticked, for the whole account; neither does anything in another style.

	What counts is what Core/Discovery.lua tells (OnFind): a dungeon entered, a boss met, an item first seen
	to drop in a dungeon, a quest first offered, a faction met, a faction's reward seen at its quartermaster,
	and a flight path the client itself says is new. Never the character's past, read at login (the quests
	done before, the flight paths known, the factions met): Discovery tells nothing of it. Not told either:
	what no page of the journal shows: a reward of a faction not met yet (its page is not the character's
	yet), a boss with no page of its own (the hidden ones Before you go names), an item its loot page leaves
	out (the trash's greens and whites, one hidden until confirmed: Listed), and a step of a chain many
	dungeons share, which no Quests tab shows (QuestHome).

	A burst of finds (a boss's loot, a roll's items, a quartermaster's wares) is one line, DELAY after the
	first: its names in the order found, MAX_NAMES of them, then how many more ("and 3 more"). Each name with
	a page is a link to it: a dungeon, a boss and a faction their pages; an item its loot page, where the
	search opens it; a quest its dungeon's Quests tab, its row chosen. Pages are in the color the game gives
	its own journal's links, items in their quality's. A flight path has no page: its name alone, in brackets.

	The links are the client's own kind for an addon's ("addon:"), which the client hands to addons when one
	is clicked, through EventRegistry's "SetItemRef", each listener run apart from the client's own code
	(secureexecuterange). The journal opens as for its minimap button, and the page as a search result's
	(UI/Search.lua's Search:Open). A modified click on an item (Shift, Ctrl) is the game's own item click, as on
	the loot pages (ns.Gamepad:ItemClick). No timer runs but the one for each burst's line.
]]

local News = {}
ns.News = News

-- Seconds after a burst's first find before its line is said: a loot window's items, a roll's and the loot
-- lines in the chat come within it.
News.DELAY = 1
-- Names in one line; past these, how many more.
News.MAX_NAMES = 5

-- The game's own color for its journal's links (GetFixedLink's "journal" links).
local PAGE_COLOR = "|cff66bbff"
-- The journal's links: "addon:<this addon's folder>:<kind>:...".
local PREFIX = "addon:" .. tostring(ns.name) .. ":"

------------------------------------------------------------------------------------------
-- The boxes, and what is unseen
------------------------------------------------------------------------------------------

-- The chat line's and the glow's boxes: the account's, on unless unticked (saved false; ticked, nil).
function News.ChatOn()
	return not (ns.db and ns.db.adventureChat == false)
end

function News.SetChatOn(on)
	if on then ns.db.adventureChat = nil else ns.db.adventureChat = false end
end

function News.GlowOn()
	return not (ns.db and ns.db.adventureGlow == false)
end

function News.SetGlowOn(on)
	if on then ns.db.adventureGlow = nil else ns.db.adventureGlow = false end
	ns.MinimapButton:UpdateGlow()
end

-- Whether the minimap button glows: in Adventure Mode with its box ticked, something found since the journal
-- was last opened (the character's own: newFinds), and the journal shut.
function News:Glows()
	local db = ns.charDB
	return db ~= nil and db.newFinds == true and ns.Style:Adventure() and News.GlowOn() and not ns.Journal:IsShown()
end

-- The journal opened: what was new is seen.
function News:Seen()
	if ns.charDB then ns.charDB.newFinds = nil end
	ns.MinimapButton:UpdateGlow()
end

------------------------------------------------------------------------------------------
-- What a find is called
------------------------------------------------------------------------------------------

-- A boss of a dungeon by its key (Discovery.BossKey), with its place in the list.
local function BossOf(instance, bossKey)
	for index, boss in ipairs(instance.bosses or {}) do
		if not ns.IsLootSection(boss) and ns.Discovery.BossKey(boss) == bossKey then return boss, index end
	end
	return nil
end

-- An item's row in a boss's loot, else in any of the dungeon's (or of a faction's standings), with its boss.
local function RowOf(instance, boss, itemID)
	for _, candidate in ipairs(boss and { boss } or instance.bosses or {}) do
		for _, row in ipairs(candidate.loot or {}) do
			if row.itemID == itemID then return row, candidate end
		end
	end
	return nil
end

--[[
	An item's row where the page its link opens lists it, as that page does (UI/LootPanel.lua): a boss's loot,
	else the whole dungeon's, none of the item's rows there left out (one hidden until confirmed, a name-only
	one given way, the trash's greens and whites: Core/Items.lua). Nil where that page doesn't list it.
]]
local function Listed(instance, boss, itemID)
	local listed
	for _, candidate in ipairs(boss and { boss } or instance.bosses or {}) do
		for _, row in ipairs(candidate.loot or {}) do
			if row.itemID == itemID then
				ns.Items:Get(itemID, row)
				if ns.Items:IsHidden(itemID) or ns.Items:Superseded(candidate, row) or ns.Items:Unremarkable(candidate, row) then
					return nil
				end
				listed = listed or row
			end
		end
	end
	return listed
end

-- The dungeon whose Quests tab lists a quest for this character (the one the player is in first), else the one
-- whose chains hold it as a step where the tab shows it: in a chain of a quest for this character, the tab's own
-- rule (QuestsPanel:ChainStepHere: a step many dungeons' chains share is shown on none); and the quest's name there.
local function QuestHome(questID)
	local here = ns.CurrentInstance(true)
	local listed, step
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances(kind)) do
			for _, quest in ipairs(instance.quests or {}) do
				local name = quest.questID == questID and quest.name
				for _, version in ipairs(quest.oneOf or {}) do
					if version.questID == questID then name = version.name or quest.name end
				end
				if name and ns.QuestsPanel:IsForPlayer(quest) and (not listed or instance == here) then
					listed = { instance = instance, name = name }
				end
				for _, prerequisite in ipairs(quest.prerequisites or {}) do
					local stepName = prerequisite.questID == questID and prerequisite.name
					for _, version in ipairs(prerequisite.oneOf or {}) do
						if version.questID == questID then stepName = version.name or prerequisite.name end
					end
					if stepName and not step and ns.QuestsPanel:IsForPlayer(quest)
						and ns.QuestsPanel:ChainStepHere(prerequisite, select(2, ns.QuestsPanel:Rows(instance))) then
						step = { instance = instance, name = stepName }
					end
				end
			end
		end
	end
	local found = listed or step
	if not found then return nil end
	return found.instance, found.name
end

--[[
	A find as the line will say it: { data (its link's, none for no page), name, or itemID and row }. Nil for
	what is not told. An item's name is asked for when the line is said (Text): it may come in meanwhile.
]]
local RESOLVE = {
	instance = function(key)
		local instance = ns.GetInstance(key)
		return instance and { data = "instance:" .. key, name = instance.name }
	end,
	boss = function(key, bossKey)
		local instance = ns.GetInstance(key)
		local boss, index = nil, nil
		if instance then boss, index = BossOf(instance, bossKey) end
		return boss and { data = "boss:" .. key .. ":" .. index, name = boss.name }
	end,
	item = function(itemID, key, bossKey)
		local instance = ns.GetInstance(key)
		local boss, index = nil, nil
		if instance and bossKey then boss, index = BossOf(instance, bossKey) end
		local row = instance and Listed(instance, boss, itemID)
		if not row then return nil end
		return { data = "item:" .. key .. ":" .. (index or 0) .. ":" .. itemID, itemID = itemID, row = row }
	end,
	quest = function(questID)
		local instance, name = QuestHome(questID)
		return instance and { data = "quest:" .. instance.key .. ":" .. questID, name = name }
	end,
	faction = function(factionID)
		local faction = ns.GetInstance("Faction" .. tostring(factionID))
		return faction and { data = "faction:" .. factionID, name = faction.name }
	end,
	reward = function(factionID, itemID)
		local faction = ns.GetInstance("Faction" .. tostring(factionID))
		if not (faction and ns.Discovery:FactionKnown(faction)) then return nil end
		local row, standing = RowOf(faction, nil, itemID)
		if not row then return nil end
		local index = 0
		for at, candidate in ipairs(faction.bosses) do
			if candidate == standing then index = at end
		end
		return { data = "reward:" .. factionID .. ":" .. index .. ":" .. itemID, itemID = itemID, row = row }
	end,
	flight = function(_, name)
		return type(name) == "string" and name ~= "" and { name = name } or nil
	end,
}

-- A find's text in the line: a link to its page, else its name in brackets, in the line's color (a flight path's
-- has a comma of its own: "[Ironforge, Dun Morogh]"); nil while an item has no name yet.
local function Text(find)
	if not find.itemID then
		if not find.data then return "[" .. find.name .. "]" end
		return PAGE_COLOR .. "|H" .. PREFIX .. find.data .. "|h[" .. find.name .. "]|h|r"
	end
	local info = ns.Items:Get(find.itemID, find.row)
	local name = info and info.name or find.row.name
	if not name then return nil end
	local color = "|cffffffff"
	local _, _, _, hex = ns.Items:QualityColor(info and info.quality or find.row.quality)
	if type(hex) == "string" then color = hex:sub(1, 2) == "|c" and hex or ("|c" .. hex) end
	return color .. "|H" .. PREFIX .. find.data .. "|h[" .. name .. "]|h|r"
end

------------------------------------------------------------------------------------------
-- The line
------------------------------------------------------------------------------------------

local pending, queued = {}, false

-- The burst's line: its names in order, each once, MAX_NAMES of them and how many more.
local function Say()
	queued = false
	local finds = pending
	pending = {}
	if not (ns.Style:Adventure() and News.ChatOn()) then return end
	local names, more, said = {}, 0, {}
	for _, find in ipairs(finds) do
		local text = Text(find)
		local key = find.data or find.name
		if text and not said[key] then
			said[key] = true
			if #names < News.MAX_NAMES then names[#names + 1] = text else more = more + 1 end
		end
	end
	if #names == 0 then return end
	if more > 0 then names[#names + 1] = string.format(L.AND_MORE, more) end
	DEFAULT_CHAT_FRAME:AddMessage(string.format(L.ADVENTURE_NEWS, table.concat(names, L.QUEST_LIST_COMMA)), 1, 0.82, 0)
end

ns.Discovery:OnFind(function(kind, ...)
	if not (ns.charDB and ns.Style:Adventure()) then return end
	local resolve = RESOLVE[kind]
	local find = resolve and resolve(...)
	if not find then return end
	-- (found with the journal open: seen there)
	if not ns.Journal:IsShown() then
		ns.charDB.newFinds = true
		ns.MinimapButton:UpdateGlow()
	end
	if not News.ChatOn() then return end
	pending[#pending + 1] = find
	if queued then return end
	queued = true
	if C_Timer and C_Timer.After then C_Timer.After(News.DELAY, Say) else Say() end
end)

------------------------------------------------------------------------------------------
-- A link clicked
------------------------------------------------------------------------------------------

--[[
	A link of the line, clicked: the journal opened on its page, as a search result opens it (Search:Open).
	A modified click on an item is the game's own item click (it links the item in the chat, or tries it on),
	where the client has the item's link. Any other link is left alone. True when it was the journal's.
]]
function News:OpenLink(link)
	if type(link) ~= "string" or link:sub(1, #PREFIX) ~= PREFIX then return false end
	local kind, a, b, c = strsplit(":", link:sub(#PREFIX + 1))
	local entry
	if kind == "instance" then
		local instance = ns.GetInstance(a)
		entry = instance and { kind = "instance", instance = instance }
	elseif kind == "faction" then
		local faction = ns.GetInstance("Faction" .. tostring(a))
		entry = faction and { kind = "faction", instance = faction }
	elseif kind == "boss" then
		local instance = ns.GetInstance(a)
		local boss = instance and instance.bosses[tonumber(b)]
		entry = boss and { kind = "boss", instance = instance, boss = boss }
	elseif kind == "item" or kind == "reward" then
		local instance = ns.GetInstance(kind == "reward" and ("Faction" .. tostring(a)) or a)
		local itemID, boss = tonumber(c), nil
		if instance then boss = instance.bosses[tonumber(b)] end
		if instance and itemID and not boss then boss = select(2, RowOf(instance, nil, itemID)) end
		entry = boss and { kind = "item", instance = instance, boss = boss, itemID = itemID,
			atDungeon = kind == "item" and tonumber(b) == 0 or nil }
		if entry and type(IsModifiedClick) == "function" and IsModifiedClick()
			and ns.Gamepad:ItemClick(ns.Items:Link(itemID)) then
			return true
		end
	elseif kind == "quest" then
		-- (its row on the tab, for this character; a step of a chain alone: the tab, nothing chosen)
		local instance, questID = ns.GetInstance(a), tonumber(b)
		local rowOf = instance and questID and select(2, ns.QuestsPanel:Rows(instance))
		entry = rowOf and { kind = "quest", instance = instance, quest = rowOf[questID] }
	end
	if entry then
		ns.Journal:Show()
		ns.Search:Open(entry)
	end
	return true
end

-- The client hands each addon link clicked to EventRegistry's "SetItemRef" (its handler for "addon:" links).
if EventRegistry and EventRegistry.RegisterCallback then
	EventRegistry:RegisterCallback("SetItemRef", function(_, link) News:OpenLink(link) end, News)
end

-- The journal opened, whichever way: its news seen.
hooksecurefunc(ns.Journal, "Show", function()
	if ns.Journal:IsShown() then News:Seen() end
end)

-- Adventure Mode on or off: the glow follows.
ns.Style:OnChange(function() ns.MinimapButton:UpdateGlow() end)
