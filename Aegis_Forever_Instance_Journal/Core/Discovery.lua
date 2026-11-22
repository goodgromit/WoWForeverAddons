local _, ns = ...

--[[
	What this character has found of the journal, for Adventure Mode (Core/Style.lua): kept for the
	character alone in AegisJournalCharDB.discovered, and filled as it plays in every style, so a
	character that turns Adventure Mode on later already has its finds. Everything the journal shows
	will ask one question of it, Knows; for a character not in Adventure Mode the answer is always
	yes, so the journal stays as it is.

	Keyed by what no language changes: a dungeon's key (each wing its own), a boss's English name, an
	item's id, a quest's id, a flight master's node id and a way in's key.

	  version    the record's shape (Discovery.VERSION)
	  instances  [instanceKey] = true: entered
	  bosses     [instanceKey][bossKey] = 1 met, 2 fought, 3 killed; each counts as the ones before
	  items      [itemID][instanceKey] = { [bossKey] = true }: seen to drop there, off those bosses
	             (an empty table: seen there, its boss not known)
	  quests     [questID] = 1 offered, 2 taken, 3 done; each counts as the ones before
	  flights    [nodeID] = true: flight paths known
	  subMaps    [subMapKey] = true: ways in walked
	  rewards    [factionID][itemID] = true: a faction's reward seen at its quartermaster (version 2)
	  factions   [factionID] = true: met, listed on the character's Reputation tab (version 3)

	What counts, and where it is heard (the listener below):
	  entered    the dungeon's id (GetInstanceInfo) on entering the world and on each change of zone
	             or area. A wing of a dungeon that shares its id with others (Scarlet Monastery's)
	             counts only once its area or map names it (Core/Registry.lua), and so does a wing
	             one of its bosses was met in.
	  met        the fight starting (ENCOUNTER_START); or the boss at hand (target, focus, mouseover)
	             alive and fighting, or lying dead. A corpse is only a meeting: someone else may have
	             killed it.
	  fought     the fight ending (ENCOUNTER_END), won or not
	  killed     the fight won (ENCOUNTER_END's success, 1 or true), or the boss's own loot (something
	             the journal has it drop) taken from its corpse: only the group that killed it may. Its
	             skin, ore or herbs anyone may take, and a living boss's pockets are no kill. And every
	             kill the dungeon map counts (UI/DungeonMap.lua's MarkDefeated: a fight's end it heard, a
	             corpse it watched), so a boss the run block crosses out has his name there.
	  items      the loot window, off the boss it names; the loot lines in chat, the group's rolls and
	             the loot history (off the boss it names). One that comes with no boss, or off a boss the
	             journal does not have drop it (a Trash page's row the bosses and rares drop: the Drowned
	             City's Linken's Boots of Iron, off Zul'Alai's corpse), goes to the one
	             boss of this dungeon the journal has it drop from, else to the one wing all its
	             droppers here are in, else to the dungeon where the place names the wing. Only items
	             the journal lists somewhere are kept.
	  quests     offered (QUEST_DETAIL), taken (QUEST_ACCEPTED) and done (QUEST_TURNED_IN): the
	             journal's own quests only
	  flights    a flight master's map (TAXIMAP_OPENED), the client's "New flight path discovered!"
	             (UI_INFO_MESSAGE: the flight master where the player stands, NewFlightPath), and the
	             client's list of the continent's flight masters where it marks the ones not found yet.
	             The points of that list Forever has no flight master for (ns.NOT_ON_FOREVER_TAXI,
	             Core/Compat.lua) never count
	  ways in    the dungeon map's PlayerSubMap (UI/DungeonMap.lua), with the way-in maps on or off
	  rewards    a shop open (MERCHANT_SHOW, and MERCHANT_UPDATE as its wares come in): its wares that are
	             a faction's rewards, where the shop is that faction's quartermaster (Quartermaster below)
	  factions   the journal's factions on the Reputation tab's list (UPDATE_FACTION; ReadFactions below).
	             Not GetFactionDataByID's answer: Forever gives a faction never met there too, at Neutral 0
	And at login, once a session, from the character's past: the journal's quests done or in the quest
	log, the flight paths the client says are known, and the factions on the Reputation tab; and, as the
	addon loads, the kills the journal kept itself, the dungeon map's and the run block's runs, which a
	build before this record kept too (BringKeptKills). Other old kills and old loot cannot be known, and
	are not made up.

	Each thing new to the journal is also told as it is found (OnFind), for Adventure Mode's line in the
	chat and the minimap button's glow (UI/News.lua): never what the character's past brings, nor the
	flight paths read off a list (Found below).

	Forever keeps the combat log from addons (registering it is a forbidden action), so none of this
	reads it. Inside dungeons enemies' guids may be held back (ns.Readable): names do the matching
	then. Every call the client may lack is asked for first, and each that may fail is pcalled.
]]

local Discovery = {}
ns.Discovery = Discovery

Discovery.VERSION = 3
Discovery.BOSS_LEVELS = { met = 1, fought = 2, killed = 3 }
Discovery.QUEST_LEVELS = { offered = 1, taken = 2, done = 3 }
local BOSS_LEVELS, QUEST_LEVELS = Discovery.BOSS_LEVELS, Discovery.QUEST_LEVELS

-- Knows' kinds, and the list each is kept in.
local LISTS = { instance = "instances", boss = "bosses", item = "items", quest = "quests", flight = "flights",
	subMap = "subMaps", reward = "rewards", faction = "factions" }
local KINDS = { "instances", "bosses", "items", "quests", "flights", "subMaps", "rewards", "factions" }

-- The continents whose flight masters are asked about at login: Kalimdor and the Eastern Kingdoms,
-- with the one the player is on.
local FLIGHT_MAPS = { 1414, 1415 }
local MAP_TYPE_CONTINENT = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
-- Seconds after login before the character's past is read: the client's quest history is ready by then.
local BACKFILL_DELAY = 5
-- A burst of finds (a loot window, the login's quests) is told once, this long after the first.
local CHANGE_DELAY = 0.2

local Call = ns.Call

------------------------------------------------------------------------------------------
-- The record
------------------------------------------------------------------------------------------

-- The character's record, made on first use. Nil before ADDON_LOADED sets ns.charDB.
local function Store()
	local db = ns.charDB
	if not db then return nil end
	local store = db.discovered
	if type(store) ~= "table" then
		store = {}
		db.discovered = store
	end
	for _, kind in ipairs(KINDS) do
		if type(store[kind]) ~= "table" then store[kind] = {} end
	end
	-- Where a later shape of the record needs the older one changed, it is done here, from the version
	-- it was saved with. Version 1 is the first shape: one with no version is taken as it. Version 2 adds
	-- the rewards list (made above, empty, for a record of version 1): nothing kept before changes. Version 3
	-- adds the factions list the same way (empty for an older record, and filled by the login's reading of
	-- the Reputation tab: ReadFactions).
	if type(store.version) ~= "number" or store.version < Discovery.VERSION then store.version = Discovery.VERSION end
	return store
end

-- Whether the character was in Adventure Mode at the last change of style (below).
local wasAdventure

function Discovery:Init()
	local store = Store()
	-- The 0.40 test builds could keep flight points Forever has no flight master for: they go.
	if store then
		for nodeID in pairs(ns.NOT_ON_FOREVER_TAXI) do store.flights[nodeID] = nil end
	end
	wasAdventure = ns.Style:Adventure()
end

-- What changed is told once a burst is over; Version goes up at every find.
local version, listeners, queued = 0, {}, false

local function Tell()
	queued = false
	for _, fn in ipairs(listeners) do
		local ok, problem = pcall(fn)
		if not ok then geterrorhandler()(problem) end
	end
end

-- A find tells only a character in Adventure Mode, the one Knows answers change for; always = true
-- (Adventure Mode turned on or off) tells any.
local function Changed(always)
	if not always and not ns.Style:Adventure() then return end
	version = version + 1
	if queued then return end
	queued = true
	if C_Timer and C_Timer.After then C_Timer.After(CHANGE_DELAY, Tell) else Tell() end
end

-- Goes up each time a character in Adventure Mode finds something, and as Adventure Mode is turned
-- on or off:
-- whatever is worked out from Knows is worked out again.
function Discovery:Version()
	return version
end

-- fn(): called once after a burst of finds in Adventure Mode, and after it is turned on or off.
function Discovery:OnChange(fn)
	listeners[#listeners + 1] = fn
end

-- How many new things of a kind have been found this session, in any style: "quest", a quest first offered,
-- taken or done (Quest); "flight", a flight path (LearnedFlight). What is drawn from one kind alone (the world
-- map's flight points and quest marks, UI/TravelMap.lua and UI/QuestMap.lua) is drawn again after a burst of
-- finds only when its count has moved: a boss met or killed, or its loot, leaves it as it is.
Discovery.finds = { quest = 0, flight = 0 }
function Discovery:Finds(kind)
	return self.finds[kind] or 0
end

local function InstanceKey(instance)
	if type(instance) == "table" then return instance.key end
	return instance
end

-- A boss by its English name, whatever the client's language.
local function BossKey(boss)
	if type(boss) == "table" then return boss.enName or boss.name end
	return boss
end
Discovery.BossKey = BossKey

-- Kills, for the dungeon maps' fog (UI/DungeonFog.lua), which follows them in every style: count goes up at
-- each first kill and as the record changes (another character's, or a new one), store is the record count
-- was last taken for, and listeners hear each first kill at once. One table: this file is near Lua's limit
-- of top-level locals.
local kills = { count = 0, listeners = {} }

-- fn(instanceKey, bossKey): called as a boss is first recorded killed, in every style.
function Discovery:OnKill(fn)
	kills.listeners[#kills.listeners + 1] = fn
end

-- A number that changes whenever any kill could read differently: a first kill, or another record.
function Discovery:KillStamp()
	local db = ns.charDB
	local store = db and db.discovered
	if store ~= kills.store then
		kills.store = store
		kills.count = kills.count + 1
	end
	return kills.count
end

--[[
	Test mode's pretend kills and finds (UI/FogTest.lua; its panel, UI/TestPanel.lua: /aegis test): nil but while
	test mode is on, then
	  bosses   [instanceKey][bossKey] = true (pretend defeated) or false (pretend standing, a real kill too)
	  entered  [instanceKey] = true: shown as found (the panel's "Show as found", a pretend walk in), or a boss of it
	           pretend defeated
	  items    [itemID][instanceKey][bossKey] = true: the loot of the bosses pretend defeated
	Kept in this table alone, for the session: never in the record, never told as a find (OnFind, OnKill). While
	it is there Killed answers by it where it has the boss, and Knows (Adventure Mode) answers yes as well for a
	boss pretend defeated (met, fought and killed), its dungeon (entered) and its loot (seen off it), so the
	journal shows the boss as a kill would unlock it. What the character really found stays known.
]]
Discovery.pretend = nil

-- The fog test's pretend kills set (a table as above, or nil), and everything worked out from kills and finds
-- worked out again: the fog (KillStamp) at once, the pages after the burst (Changed, in every style).
function Discovery:Pretend(pretend)
	self.pretend = pretend
	kills.count = kills.count + 1
	Changed(true)
end

-- Whether Knows answers yes by the pretend kills alone (Discovery.pretend there).
function Discovery:Pretended(kind, a, b, c)
	local pretend = self.pretend
	if kind == "boss" then
		local bosses = pretend.bosses[InstanceKey(a)]
		return bosses ~= nil and bosses[BossKey(b)] == true
	elseif kind == "instance" then
		return pretend.entered[InstanceKey(a)] == true
	elseif kind == "item" then
		local seen = pretend.items[a]
		if not seen then return false end
		if b == nil then return true end
		local at = seen[InstanceKey(b)]
		if not at then return false end
		return c == nil or at[BossKey(c)] == true
	end
	return false
end

-- What the character itself knows or killed, test mode's pretend kills and finds put aside a moment (UI/TestPanel.lua:
-- its "Show as found" box for a dungeon really found, its readout's real kills). Only read. (Fields, not locals: the
-- file is near Lua's limit of top-level locals.)
function Discovery:Really(method, ...)
	local pretend = self.pretend
	self.pretend = nil
	local ok, answer = pcall(method, self, ...)
	self.pretend = pretend
	return ok and answer or false
end
function Discovery:KnowsReally(kind, a, b, c) return self:Really(self.Knows, kind, a, b, c) end
function Discovery:KilledReally(instance, boss) return self:Really(self.Killed, instance, boss) end

-- Whether this character has killed a boss, in any style (Knows answers yes to everything outside
-- Adventure Mode). Each value's type is asked as it is read, as Knows does. While the fog test is on, a boss
-- it has (pretend) reads as it says.
function Discovery:Killed(instance, boss)
	local pretend = self.pretend
	if pretend then
		local bosses = pretend.bosses[InstanceKey(instance)]
		local dead = bosses and bosses[BossKey(boss)]
		if dead ~= nil then return dead end
	end
	local db = ns.charDB
	local store = db and db.discovered
	local list = type(store) == "table" and store.bosses
	local bosses = type(list) == "table" and list[InstanceKey(instance)]
	local level = type(bosses) == "table" and bosses[BossKey(boss)]
	return type(level) == "number" and level >= BOSS_LEVELS.killed
end

--[[
	Whether this character knows a thing. Always true for a character not in Adventure Mode. Asked
	thousands of times by the search and the Gear Finder, so it is table lookups only.
	  Knows("instance", instance)              entered
	  Knows("boss", instance, boss, level)     met, or "fought" or "killed" (level; none is "met")
	  Knows("item", itemID)                    seen to drop anywhere
	  Knows("item", itemID, instance)          seen to drop in that dungeon
	  Knows("item", itemID, instance, boss)    seen to drop off that boss
	  Knows("quest", questID, level)           offered, or "taken" or "done" (level)
	  Knows("flight", nodeID)                  flight path known
	  Knows("subMap", subMap)                  way in walked
	  Knows("reward", faction, itemID)         a faction's reward seen at its quartermaster
	  Knows("faction", faction)                met: on the character's Reputation tab
	An instance, a boss and a way in may be given as the journal's own entry or by its key; a faction as
	its entry or its id.
]]
function Discovery:Knows(kind, a, b, c)
	if not ns.Style:Adventure() then return true end
	-- (the fog test's pretend kills, while it is on: one field read otherwise)
	if self.pretend and self:Pretended(kind, a, b, c) then return true end
	local store = ns.charDB.discovered
	local list = store and store[LISTS[kind]]
	if not list then return false end
	-- Each value's type is asked as it is read: one bad entry (a saved file edited by hand) is not known,
	-- and breaks nothing that asks.
	if kind == "boss" then
		local bosses = list[InstanceKey(a)]
		local level = type(bosses) == "table" and bosses[BossKey(b)]
		return type(level) == "number" and level >= (BOSS_LEVELS[c] or 1)
	elseif kind == "item" then
		local seen = list[a]
		if type(seen) ~= "table" then return false end
		if b == nil then return true end
		local at = seen[InstanceKey(b)]
		if type(at) ~= "table" then return false end
		if c == nil then return true end
		return at[BossKey(c)] == true
	elseif kind == "quest" then
		local level = list[a]
		return type(level) == "number" and level >= (QUEST_LEVELS[b] or 1)
	elseif kind == "instance" then
		return list[InstanceKey(a)] == true
	elseif kind == "subMap" then
		return list[type(a) == "table" and a.key or a] == true
	elseif kind == "reward" then
		local seen = list[type(a) == "table" and a.factionID or a]
		return type(seen) == "table" and seen[b] == true
	elseif kind == "faction" then
		return list[type(a) == "table" and a.factionID or a] == true
	end
	return list[a] == true
end

------------------------------------------------------------------------------------------
-- What the journal's pages ask (UI/Journal.lua, UI/EncounterPage.lua, UI/LootPanel.lua)
------------------------------------------------------------------------------------------

-- What an unmet boss is called, in every language.
Discovery.UNKNOWN = "???"
local UNKNOWN = Discovery.UNKNOWN

--[[
	Whether a dungeon of the lists is still a rumour to this character: in Adventure Mode and not
	entered. A faction is no dungeon, and a raid not open yet (comingSoon) can't be entered: each
	page shows as in every other style (a coming-soon raid's door is a rumour: DoorRumoured).
]]
function Discovery:Rumour(instance)
	if not ns.Style:Adventure() or type(instance) ~= "table" or instance.kind == "faction" or instance.comingSoon then
		return false
	end
	return not self:Knows("instance", instance)
end

--[[
	Whether a dungeon's world-map door is a rumour (the door helpers below and UI/DungeonMap.lua): in
	Adventure Mode and not entered, as its page is (Rumour), and a raid not open yet (comingSoon) too,
	whose door is on the map (Onyxia's Lair, the owner's call of 2026-11-07): its door says no name
	either, while its journal page stays as in every other style.
]]
function Discovery:DoorRumoured(instance)
	if not ns.Style:Adventure() or type(instance) ~= "table" or instance.kind == "faction" then return false end
	return not self:Knows("instance", instance)
end

-- Whether a boss is still a stranger: in Adventure Mode and not met. A dungeon's trash and recipes
-- (ns.IsLootSection) and a faction's standings are no bosses.
function Discovery:Unmet(instance, boss)
	if type(boss) ~= "table" or ns.IsLootSection(boss) or boss.standing or not ns.Style:Adventure() then return false end
	return not self:Knows("boss", instance, boss)
end

--[[
	Whether a dungeon's Recipes entry (recipes = true: ns.IsLootSection) is kept from the character: in Adventure Mode,
	until one of its recipes is seen to drop in that dungeon (Knows: anywhere in it). Shown, it lists the ones seen
	(UI/LootPanel.lua's Seen). Before that its row would tell that recipes drop there at all (the owner's call of
	2026-11-19): its row in the boss list (UI/EncounterPage.lua's BossesOf) and its page (UI/Journal.lua's OpenBoss
	opens the dungeon instead, so no breadcrumb reaches it) wait. The search finds only recipes seen, and an item's
	tooltip names only where it was seen (UI/Search.lua's Discovered, UI/ItemTooltip.lua's SourceText), so neither
	tells of it either. The trash's entry never waits: every dungeon has trash. Outside Adventure Mode, and for
	anything but a Recipes entry, false.
]]
function Discovery:RecipesHidden(instance, boss)
	if type(boss) ~= "table" or not boss.recipes or not ns.Style:Adventure() then return false end
	for _, row in ipairs(boss.loot or {}) do
		if row.itemID and self:Knows("item", row.itemID, instance) then return false end
	end
	return true
end

-- Whether a boss's fight is known (its abilities): always, outside Adventure Mode, and for the trash, the recipes and
-- standings.
function Discovery:Fought(instance, boss)
	if type(boss) ~= "table" or ns.IsLootSection(boss) or boss.standing then return true end
	return self:Knows("boss", instance, boss, "fought")
end

-- A boss's name as the journal's pages give it: "???" until met.
function Discovery:BossTitle(instance, boss)
	if self:Unmet(instance, boss) then return UNKNOWN end
	return ns.BossTitle(boss)
end

--[[
	A world-map door (UI/DungeonMap.lua) of a dungeon still a rumour says what is heard of it, never its
	name: "A rumor", its line of rumour (DoorRumour) and its level range. Where its name would stand (a
	shared door's lines and menu, a waypoint), "Rumored dungeon" or "Rumored raid" (DoorName); two of
	one kind behind one door (instances) are numbered in the door's order, the same in its tooltip and its
	menu, so they can be told apart. A dungeon entered, and every door outside Adventure Mode, as it was.
]]
function Discovery:DoorName(instance, instances)
	if not self:DoorRumoured(instance) then return instance.name end
	local L, raid = ns.L, instance.kind == "raid"
	local name = raid and L.ADVENTURE_DOOR_RAID or L.ADVENTURE_DOOR_DUNGEON
	local count, nth = 0, nil
	for _, other in ipairs(instances or {}) do
		if (other.kind == "raid") == raid and self:DoorRumoured(other) then
			count = count + 1
			if other == instance then nth = count end
		end
	end
	if count > 1 and nth then return string.format(L.ADVENTURE_DOOR_NTH, name, nth) end
	return name
end

-- Its line of rumour in the language's quotation marks: the data's (instance.rumour, translated at load,
-- with nothing in it the character has not found), else that little is known of it yet. door: one of the dungeon's
-- several doors, with a line of its own (Stratholme's Service Gate, door.rumour: Data/Authored/Rumours.lua).
function Discovery:DoorRumour(instance, door)
	local L, line = ns.L, type(door) == "table" and door.rumour or instance.rumour
	if type(line) == "string" and line ~= "" then
		line = self:MaskPage(instance, line, self:Untold(instance))
	else
		line = L.ADVENTURE_DOOR_UNKNOWN
	end
	return string.format(L.ADVENTURE_DOOR_LINE, line)
end

-- Whether every dungeon behind a door is a rumour: the door is then called "A rumor".
function Discovery:DoorUnknown(instances)
	for _, instance in ipairs(instances) do
		if not self:DoorRumoured(instance) then return false end
	end
	return #instances > 0
end

--[[
	A way in (a cave's or a building's sub-map, UI/DungeonMap.lua) many of which are named after the
	dungeon they lead to: while every dungeon it leads to is a rumour, its icon, its map's floor step and
	its waypoint name none of them. Its levels or views (Blackrock Mountain's, Maraudon's caves) are one
	place, so all of them count: one entered names them all again. A way in that leads to no dungeon
	(Coldridge Pass) keeps its name.
]]
function Discovery:WayUnknown(subMap)
	if type(subMap) ~= "table" or not ns.Style:Adventure() then return false end
	local group = subMap.levels or subMap.views
	local any = false
	for _, other in ipairs(group and ns.GetSubMaps() or { subMap }) do
		if other == subMap or (group and (other.levels == group or other.views == group)) then
			for key in pairs(other.instances or {}) do
				local instance = ns.GetInstance(key)
				if instance then
					if not self:DoorRumoured(instance) then return false end
					any = true
				end
			end
			for _, key in ipairs(other.alsoLeadsTo or {}) do
				local instance = ns.GetInstance(key)
				if instance then
					if not self:DoorRumoured(instance) then return false end
					any = true
				end
			end
		end
	end
	return any
end

-- A way in's name: its own, else (WayUnknown) `unnamed`, what the caller has for it (Cave Entrance, Entrance).
function Discovery:WayName(subMap, unnamed)
	if self:WayUnknown(subMap) then return unnamed end
	return subMap.name
end

-- A level or view of a way in, on the map's floor step and menu: its name, else (WayUnknown) its number, as
-- a dungeon's floors with no name are.
function Discovery:WayStep(subMap, index, name)
	if name and index and self:WayUnknown(subMap) then return string.format(ns.L.MAP_FLOOR, index) end
	return name
end

-- The journal's language: the one previewed, else the client's.
local function Locale()
	return ns.previewLocale or (GetLocale and GetLocale()) or "enUS"
end

-- Chinese is written without spaces: there a name is found as it is written, never as a word.
local function Spaced()
	local locale = Locale()
	return locale ~= "zhCN" and locale ~= "zhTW"
end

-- How many characters a text has (UTF-8: a character is its first byte).
local function Chars(text)
	local _, count = text:gsub("[^\128-\191]", "")
	return count
end

-- Whether a character is a letter or a digit: not a space, nor a mark (an apostrophe, a quote, a dash).
local function Letter(char)
	if char == "" then return false end
	local first, second = char:byte(1, 2)
	if first < 128 then return char:find("^%w") ~= nil end
	-- No-break space, quotes and the dot between names; dashes and curly quotes; the full stops and
	-- commas of Chinese and Korean.
	if first == 0xC2 or first == 0xE2 or first == 0xEF or (first == 0xE3 and second == 0x80) then return false end
	return true
end

-- The character that ends just before position at, and the end of the word that goes on from it.
local function CharBefore(text, at)
	local from = at - 1
	while from > 1 and text:byte(from) >= 128 and text:byte(from) < 192 do from = from - 1 end
	return text:sub(from, at - 1)
end
local function WordEnd(text, at)
	while at <= #text do
		local stop = at
		while stop < #text and text:byte(stop + 1) >= 128 and text:byte(stop + 1) < 192 do stop = stop + 1 end
		if not Letter(text:sub(at, stop)) then break end
		at = stop + 1
	end
	return at - 1
end

-- Whether a word of a name starts with a capital, as names do and common words don't (Latin and
-- Cyrillic letters; the other scripts have no capitals).
local function Capital(word)
	local first, second = word:byte(1, 2)
	if first < 128 then return first >= 65 and first <= 90 end
	if first == 0xC3 then return second <= 0x9E end
	if first == 0xD0 then return second <= 0xAF end
	if first == 0xD1 then return false end
	return true
end

-- A text in small letters, each letter the same length as before: ASCII, Latin-1 and Cyrillic capitals.
-- (each capital's small letter, looked up: no function call for each letter)
local SMALL_CYRILLIC, SMALL_LATIN = {}, {}
for byte = 128, 175 do
	local small = byte >= 160 and ("\209" .. string.char(byte - 32)) or byte >= 144 and ("\208" .. string.char(byte + 32))
		or ("\209" .. string.char(byte + 16))
	SMALL_CYRILLIC["\208" .. string.char(byte)] = small
end
for byte = 128, 158 do SMALL_LATIN["\195" .. string.char(byte)] = "\195" .. string.char(byte + 32) end
local function Fold(text)
	text = text:lower()
	if text:find("\208[\128-\175]") then text = text:gsub("\208[\128-\175]", SMALL_CYRILLIC) end
	if text:find("\195[\128-\158]") then text = text:gsub("\195[\128-\158]", SMALL_LATIN) end
	return text
end

-- A word of a name as a line may say it alone: without the marks after it ("Malor," of the Portuguese
-- "Malor, o Zeloso"; "Eranikus'"), Korean's "of" after it, or French's "de" or article elided before it
-- ("d'Argelaine").
local function Bare(word)
	local last, second = word:byte(-1), word:byte(2)
	-- (most words: a letter last, no elided "d'" or "l'")
	if last and last ~= 152 and last ~= 153 and second ~= 39 and second ~= 226 and (last >= 128 or (last >= 97 and last <= 122)
		or (last >= 65 and last <= 90) or (last >= 48 and last <= 57)) then
		return word
	end
	if last and (last == 153 or (last < 128 and word:find("%p$"))) then
		word = word:gsub("%p+$", ""):gsub("\226\128\153$", "")
	end
	-- (Korean's "의" after a name: "키르토노스의", of Kirtonos)
	if last == 152 and Locale() == "koKR" and Chars(word) >= 3 then word = word:gsub("\236\157\152$", "") end
	second = word:byte(2)
	if second == 39 or second == 226 then
		local rest = word:match("^[dlDL]'(.+)$") or word:match("^[dlDL]\226\128\153(.+)$")
		if rest and Capital(rest) then return rest end
	end
	return word
end

--[[
	The words of bosses' names that are no names of their own, per language: titles, in many bosses'
	names ("Lord", "Captain"); the words of the journal's adds' and abilities' names ("Mana",
	"Twilight", "Blood"); and those its own words write in small letters somewhere ("hunter"), looked for
	in its words (corpus) as each is asked (IsCommon below). Gathered once, on the first page that asks.
	Each word is counted as a line may say it alone (Bare): "Gesetzes:" of the German Ring of Law's
	challengers is the "Gesetzes" six bosses share.
]]
local common, commonFor
-- (of, de, von: before a name. Not "do", "du", "del", "da" nor "des", which hold an article: "Sombra do
-- Arquimago", Shade of the Archmage, ends in a title)
local OWNERS = { of = true, de = true, von = true }
-- Whether a name's word at index is the name it is named after: last, after "of", or with "de" elided
-- before it ("d'Arugal"); or first, with Korean's "of" after it where the English has it so ("아루갈의",
-- of Arugal's Voidwalker; "키르토노스의", of Blood Steward of Kirtonos: english, the English name).
local function Owner(list, index, english)
	local word = list[index]
	if index == 1 and #list > 1 and type(english) == "string" and (english:find("^%S+'s ") or english:find(" of %u%S*$"))
		and word:find("\236\157\152$") then
		return true
	end
	if index < 2 or index ~= #list then return false end
	return OWNERS[list[index - 1]:lower()] == true or word:find("^[dD]'%S") ~= nil or word:find("^[dD]\226\128\153") ~= nil
end
local function Common()
	local locale = Locale()
	if common and commonFor == locale then return common end
	local names, count, words, texts = {}, {}, {}, {}
	-- (an add's or an ability's name: not the name it is named after, last after "of": the Spanish for
	-- Arugal's Voidwalker, "Abisario de Arugal", has Archmage Arugal's own; nor one with Korean's "of" after
	-- it, "아루갈의", which is whose it is)
	-- (each name taken apart once for each boss that has it: many abilities share one. Whose each word is, where
	-- one boss's abilities and adds alone have it, "Rhahk'Zor" of Rhahk'Zor Slam; false where two bosses' have it,
	-- "Bolt": owned)
	local done, owned = {}, {}
	local function Own(word, boss)
		if owned[word] == nil then owned[word] = boss or false elseif owned[word] ~= boss then owned[word] = false end
	end
	local function Named(name, english, boss)
		if type(name) ~= "string" then return end
		local key = (english and (name .. "\0" .. english) or name) .. "\0" .. tostring(boss)
		if done[key] then return end
		done[key] = true
		local list = {}
		for word in name:gsub("\194\183", " "):gmatch("%S+") do list[#list + 1] = word end
		for index, word in ipairs(list) do
			if not Owner(list, index, english) then
				words[word] = true
				Own(word, boss)
				if not word:find("\236\157\152$") then
					words[Bare(word)] = true
					Own(Bare(word), boss)
				end
			end
		end
	end
	local function Text(text)
		if type(text) == "string" then texts[#texts + 1] = text end
	end
	local function Abilities(rows, boss)
		for _, row in ipairs(rows or {}) do
			Named(row.name, nil, boss)
			Text(row.text)
		end
	end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			Text(instance.description)
			for _, boss in ipairs(instance.bosses or {}) do
				if type(boss.name) == "string" then names[boss.name] = boss.enName or boss.name end
				Text(boss.description)
				Text(boss.fightNote)
				for _, note in ipairs(boss.notes or {}) do Text(note) end
				for _, stage in ipairs(boss.stages or {}) do Text(stage.description) end
				Abilities(boss.abilities, boss.name)
				for _, entry in ipairs(boss.extraAbilities or {}) do
					Named(entry.title, nil, boss.name)
					Text(entry.description)
				end
				for _, add in ipairs(boss.adds or {}) do
					Named(add.name, add.enName, boss.name)
					Abilities(add.abilities, boss.name)
				end
			end
		end
	end
	-- (not the name a boss is named after, last after "of": "Arugal" of the Spanish "Abisario de Arugal",
	-- Arugal's Voidwalker, is Archmage Arugal's own)
	for name, english in pairs(names) do
		local seen, list = {}, {}
		for word in name:gsub("\194\183", " "):gmatch("%S+") do list[#list + 1] = word end
		for index, word in ipairs(list) do
			local owner = Owner(list, index, english)
			word = Bare(word)
			if word ~= "" and not seen[word] and not owner then
				seen[word] = true
				count[word] = (count[word] or 0) + 1
				if count[word] > 1 then words[word] = true end
			end
		end
	end
	common, commonFor = { words = words, owned = owned, corpus ="\n" .. table.concat(texts, "\n"), asked = {} }, locale
	return common
end

--[[
	Every dungeon's and raid's name, in the journal's language: the lists show them all, rumours too, so
	no line has them put out, nor a boss's name one of them holds (Onyxia, of Onyxia's Lair).
]]
local dungeonNames, dungeonNamesFor, foldedDungeonNames
local function DungeonNames()
	local locale = Locale()
	if dungeonNames and dungeonNamesFor == locale then return dungeonNames, foldedDungeonNames end
	local names = {}
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			if type(instance.name) == "string" then names[#names + 1] = instance.name end
		end
	end
	dungeonNames, dungeonNamesFor = table.concat(names, "\n"), locale
	-- (and in small letters: Fold)
	foldedDungeonNames = Fold(dungeonNames)
	return dungeonNames, foldedDungeonNames
end

-- Whether a dungeon's name holds a boss's: as it is, or with another ending (a letter cut off a long name
-- of a spaced script: the Russian for Onyxia's Lair declines her name).
local function InDungeonName(name)
	local names = DungeonNames()
	if names:find(name, 1, true) then return true end
	if Spaced() and name:byte(1) < 0xE0 and Chars(name) >= 5 then
		local stem = name:sub(1, #name - #name:match("[%z\1-\127\192-\255][\128-\191]*$"))
		return names:find(stem, 1, true) ~= nil
	end
	return false
end

--[[
	The journal's quests' names, and who gives and takes them, in small letters, a line each, in the
	journal's language: what a word of another dungeon's boss is not taken for where one of them has it
	without the boss's whole name ("Champion", of the Fallen Champion, in The Champion of the Horde; the
	Russian for "Bloody", of a boss's, in Warlord Goretooth's). Gathered once for each language, with the
	dungeon each is of (homes: its key, or true for several).
]]
local questNames, questNamesFor, inQuestName, questHomes, questStarts, questHeads
local QuestData
-- (a word's first three letters; and a run of letters: Latin, Cyrillic)
local HEAD_OF = "^[%z\1-\127\192-\255][\128-\191]*[%z\1-\127\192-\255][\128-\191]*[%z\1-\127\192-\255][\128-\191]*"
local function QuestNames()
	local locale = Locale()
	if questNames and questNamesFor == locale then return questNames, questHomes, questStarts, questHeads end
	-- (gathered with the quests' names: QuestData; and where each line starts, in order: questStarts)
	local data = QuestData()
	local names, homes = data.lines, data.homes
	questNames, questNamesFor, inQuestName = "\n" .. Fold(table.concat(names, "\n")) .. "\n", locale, {}
	-- (each line's dungeon by the line, then by its place in the list)
	local byLine, lines = {}, {}
	questHomes, questStarts = {}, {}
	local index = 0
	for at, line in questNames:sub(2):gmatch("()([^\n]*)\n") do
		index = index + 1
		questStarts[index], lines[index] = at + 1, line
		local home, was = homes[names[index]], byLine[line]
		byLine[line] = (was == nil or was == home) and home or true
	end
	for at, line in ipairs(lines) do questHomes[at] = byLine[line] end
	-- (in a spaced script, the lines that have a word starting with each three letters: InQuestName)
	questHeads = {}
	if Spaced() then
		for at, line in ipairs(lines) do
			for word in line:gmatch("[%w\195-\223][%w\128-\191\195-\223]*") do
				local head = word:match(HEAD_OF)
				if head then
					local list = questHeads[head]
					if not list then
						questHeads[head] = { at }
					elseif list[#list] ~= at then
						list[#list + 1] = at
					end
				end
			end
		end
	end
	return questNames, questHomes, questStarts, questHeads
end

--[[
	Whether a quest's name has a word of a boss's name (cut short to stem) but not the boss's whole name:
	each of its words, a long one of a spaced script cut short by a letter (Russian declines them all). Not
	a quest of the boss's own dungeon (home) alone, nor someone's there: one named after the boss is about
	the boss (Arugal Must Die, of Shadowfang Keep). In a spaced script, only the lines with a word that
	starts as the stem does (QuestNames's heads) are looked in: a line is masked where a word starts.
]]
local function InQuestName(stem, name, home)
	local all, homes, starts, heads = QuestNames()
	local key = stem .. "\n" .. name .. "\n" .. tostring(home)
	local answer = inQuestName[key]
	if answer ~= nil then return answer end
	answer = false
	local wanted, words = Fold(stem), {}
	for word in Fold(name):gsub("\194\183", " "):gmatch("%S+") do
		if Spaced() and word:byte(1) < 0xE0 and Chars(word) >= 5 then
			word = word:sub(1, #word - #word:match("[%z\1-\127\192-\255][\128-\191]*$"))
		end
		words[#words + 1] = word
	end
	local function Lacks(line)
		for _, word in ipairs(words) do
			if not line:find(word, 1, true) then return true end
		end
		return false
	end
	local head = Spaced() and wanted:byte(1) < 0xE0 and wanted:find("^[%w\195-\223]") and wanted:match(HEAD_OF)
	if head and head:find("^[%w\195-\223][%w\128-\191\195-\223]*$") then
		for _, index in ipairs(heads[head] or {}) do
			if homes[index] ~= home then
				local first = starts[index]
				local line = all:sub(first, all:find("\n", first, true) - 1)
				if line:find(wanted, 1, true) and Lacks(line) then
					answer = true
					break
				end
			end
		end
		inQuestName[key] = answer
		return answer
	end
	local start = all:find(wanted, 1, true)
	while start do
		-- (the line it is in: the last to start before it)
		local low, high = 1, #starts
		while low < high do
			local middle = math.floor((low + high + 1) / 2)
			if starts[middle] <= start then low = middle else high = middle - 1 end
		end
		local first, last = starts[low], all:find("\n", start, true)
		if homes[low] ~= home then
			local line = all:sub(first, last - 1)
			for _, word in ipairs(words) do
				if not line:find(word, 1, true) then
					answer = true
					break
				end
			end
		end
		if answer then break end
		start = all:find(wanted, last, true)
	end
	inQuestName[key] = answer
	return answer
end

-- (the quotes a word may start after: « „ “ ‘; and what a byte before a word may not be: a letter or a digit)
local QUOTE_ENDS = { ["\194\171"] = true, ["\226\128\158"] = true, ["\226\128\156"] = true, ["\226\128\152"] = true }
local ALNUM = {}
for byte = 0, 127 do ALNUM[byte] = string.char(byte):find("%w") ~= nil end
-- A pattern's magic characters, escaped.
local function Plain(text)
	return (text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

-- Whether a word of a boss's name (cut short to stem) is a common one (Common above).
local function IsCommon(word, stem)
	local known = Common()
	if known.words[word] then return true end
	if word:byte(1) >= 0xE0 then return false end
	local answer = known.asked[stem]
	if answer == nil then
		-- (a word of the journal's that starts with it in small letters, as written: after a space, a mark
		-- or a quote. Looked for from its second byte where the first is a letter's lead byte, as every
		-- Russian letter starts with one of two: a search that way stops at far fewer places.)
		answer = false
		local wanted, corpus = Fold(stem), known.corpus
		local skip = wanted:byte(1) >= 0xC0 and #wanted > 1 and 1 or 0
		local rest, lead = wanted:sub(skip + 1), wanted:sub(1, skip)
		local at = corpus:find(rest, 1, true)
		while at do
			at = at - skip
			local before = corpus:byte(at - 1)
			if corpus:sub(at, at + skip - 1) == lead and before and ((before < 128 and not ALNUM[before])
				or (before >= 128 and (QUOTE_ENDS[corpus:sub(at - 3, at - 1)] or QUOTE_ENDS[corpus:sub(at - 2, at - 1)]))) then
				answer = true
				break
			end
			at = corpus:find(rest, at + skip + 1, true)
		end
		known.asked[stem] = answer
	end
	return answer
end

-- A text's characters, each a string (UTF-8).
local function Letters(text)
	local list = {}
	for char in text:gmatch("[%z\1-\127\192-\255][\128-\191]*") do list[#list + 1] = char end
	return list
end

-- The longest run of characters two texts share (the first found, where two are as long); kept while
-- BareNames works, which asks of the same two many times.
-- (each text's characters taken once, and two rows of lengths used over and over)
local shared, letters, rowA, rowB = {}, {}, {}, {}
local function Shared(a, b)
	local key = a .. "\0" .. b
	local answer = shared[key]
	if answer then return answer end
	local x, y = letters[a], letters[b]
	if not x then
		x = Letters(a)
		letters[a] = x
	end
	if not y then
		y = Letters(b)
		letters[b] = y
	end
	local best, bestEnd, previous, row = 0, 0, rowA, rowB
	for j = 0, #y do previous[j] = 0 end
	for i = 1, #x do
		local char = x[i]
		row[0] = 0
		for j = 1, #y do
			if char == y[j] then
				local length = previous[j - 1] + 1
				row[j] = length
				if length > best then best, bestEnd = length, i end
			else
				row[j] = 0
			end
		end
		previous, row = row, previous
	end
	answer = best == 0 and "" or table.concat(x, "", bestEnd - best + 1, bestEnd)
	shared[key] = answer
	return answer
end

-- A name with a piece cut off its start or its end (and the "的" or "之" that joined them), or nil.
local function CutOff(text, piece)
	if text:sub(1, #piece) == piece then
		return (text:sub(#piece + 1):gsub("^\231\154\132", ""):gsub("^\228\185\139", ""))
	elseif #text > #piece and text:sub(-#piece) == piece then
		return (text:sub(1, #text - #piece):gsub("\231\154\132$", ""):gsub("\228\185\139$", ""))
	end
	return nil
end

--[[
	Chinese writes a boss's name and its title as one word ("被诅咒的塞雷布拉斯", Celebras the Cursed), and
	a line may say the name alone. The names alone, for each boss's name, worked out from the journal's
	own names and their English (enName), each boss's the first time a page asks for it (BareOf below). Which English word is the name:
	the one before "the" (Celebras the Cursed), after "of" (Shade of Eranikus), before "'s" (Arugal's
	Voidwalker); of two words, the one no other boss has (General Drakkisath); a word is a name only
	where every boss that has it has it so (Kirtonos the Herald, Blood Steward of Kirtonos; not
	Archmage, of Archmage Arugal). Then:
	  "X the Y" and "Y of X", written "Y的X" and "X的Y": the side of "的" that is the name;
	  a title other bosses have too ("General", "Devourer"): the name less what it shares with theirs
	    ("达基萨斯将军" less "将军");
	  the name's word: what the name shares most with the other names that have that word ("塞雷布拉斯节杖",
	    The Scepter of Celebras), three characters or more.
	Each two characters or more, not the whole name, and no title. None in a spaced script.
]]
local bare, bareFor, bareBase
-- What every boss's names alone are worked out from, once for each language: each boss's and add's
-- English words counted (count), the words of their names that are names (wanted), the names that have
-- each such word (byWord: bosses, adds, dungeons, quests and steps), and the bosses by name (byName).
local function BareBase()
	local locale = Locale()
	if bareBase and bareBase.locale == locale then return bareBase end
	shared, letters = {}, {}
	local bosses, count, byWord, byName, isBossName = {}, {}, {}, {}, false
	-- (each word without an "'s": "Arugal's Voidwalker" has Arugal; counted as written, so Arugal stays
	-- Archmage Arugal's own. Each English name taken apart once: a chain's steps are in many quests.)
	local wordsOf = {}
	local function Words(english)
		local made = wordsOf[english]
		if not made then
			made = { raw = {} }
			local seen = {}
			for word in english:gmatch("[%a][%w'%-]*") do
				made.raw[#made.raw + 1] = word
				word = word:gsub("'s$", "")
				if not seen[word] then
					seen[word] = true
					made[#made + 1] = word
				end
			end
			wordsOf[english] = made
		end
		if isBossName then
			for _, word in ipairs(made.raw) do count[word] = (count[word] or 0) + 1 end
		end
		return made
	end
	-- The words of an English name in a name's place, as a set (each name's once: the counts are made first).
	local nameWordsOf = {}
	local function NameWords(english, words)
		local names = nameWordsOf[english]
		if names then return names end
		names = {}
		nameWordsOf[english] = names
		local before = english:match("^(%S+) the ") or english:match(" (%S+) the ")
		local after = english:match(" of the (%S+)") or english:match(" of (%S+)")
		local owner = english:match("^(%S+)'s ") or english:match(" (%S+)'s ")
		if before then
			names[before] = true
		elseif after then
			names[after] = true
		elseif owner then
			names[owner] = true
		elseif #words == 2 and not english:find("[^%w%s'%-]") then
			local first, second = count[words[1]] or 0, count[words[2]] or 0
			if first >= 2 and second == 1 then names[words[2]] = true end
			if second >= 2 and first == 1 then names[words[1]] = true end
		end
		return names
	end
	-- (a quest's name and its English taken once: a chain's steps are in many quests. The bosses' words
	-- are counted first, so another name is kept only for the words a boss's name has as a name: wanted)
	local entered, wanted = {}, nil
	local function Valid(entry)
		return type(entry) == "table" and type(entry.name) == "string" and type(entry.enName) == "string"
			and entry.name ~= entry.enName
	end
	local function Entry(entry, isBoss)
		if not Valid(entry) then return end
		local names = entered[entry.enName]
		if not names then
			names = {}
			entered[entry.enName] = names
		end
		if not isBoss and names[entry.name] then return end
		local words = Words(entry.enName)
		if not isBoss then
			names[entry.name] = true
			local any = false
			for _, word in ipairs(words) do any = any or wanted[word] == true end
			if not any then return end
		end
		local made = { en = entry.enName, name = entry.name, words = words }
		for _, word in ipairs(made.words) do
			if isBoss or wanted[word] then
				byWord[word] = byWord[word] or {}
				table.insert(byWord[word], made)
			end
		end
		if isBoss then
			bosses[#bosses + 1] = made
			byName[made.name] = byName[made.name] or {}
			table.insert(byName[made.name], made)
		end
	end
	local all = {}
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do all[#all + 1] = instance end
	end
	isBossName = true
	for _, instance in ipairs(all) do
		for _, boss in ipairs(instance.bosses or {}) do
			if Valid(boss) then Words(boss.enName) end
			for _, add in ipairs(boss.adds or {}) do
				if Valid(add) then Words(add.enName) end
			end
		end
	end
	isBossName = false
	wanted = {}
	local function Want(entry)
		if Valid(entry) then
			for word in pairs(NameWords(entry.enName, Words(entry.enName))) do wanted[word] = true end
		end
	end
	for _, instance in ipairs(all) do
		for _, boss in ipairs(instance.bosses or {}) do
			Want(boss)
			for _, add in ipairs(boss.adds or {}) do Want(add) end
		end
	end
	for _, instance in ipairs(all) do
		Entry(instance)
		for _, boss in ipairs(instance.bosses or {}) do
			Entry(boss, true)
			for _, add in ipairs(boss.adds or {}) do Entry(add, true) end
		end
	end
	-- (the quests' and steps' names, each once with its English, as the quests' masking gathers them)
	for _, quest in ipairs(QuestData().names) do
		if quest.en and not quest.form then Entry({ name = quest.name, enName = quest.en }) end
	end
	-- (a word is a name only where every boss that has it has it as one)
	local notName = {}
	for _, boss in ipairs(bosses) do
		boss.names = NameWords(boss.en, boss.words)
		boss.isBoss = true
		for _, word in ipairs(boss.words) do
			if not boss.names[word] then notName[word] = true end
		end
	end
	-- (the titles other bosses have too, "General", "Devourer", each with the bosses whose title it is:
	-- what two of them share is no name alone)
	local titled = {}
	for _, boss in ipairs(bosses) do
		if Chars(boss.name) >= 3 and next(boss.names) then
			for _, word in ipairs(boss.words) do
				if not boss.names[word] and word:find("^%u") and (count[word] or 0) >= 2 then
					titled[word] = titled[word] or {}
					table.insert(titled[word], boss)
				end
			end
		end
	end
	bareBase = { locale = locale, count = count, byWord = byWord, byName = byName, notName = notName, titled = titled }
	return bareBase
end

-- Whether a piece of a name is what two bosses of one title share (BareBase's titled): no name alone.
local function Title(base, piece)
	for word, bosses in pairs(base.titled) do
		for _, boss in ipairs(bosses) do
			if boss.name:find(piece, 1, true) then
				for _, other in ipairs(base.byWord[word]) do
					if other.isBoss and other ~= boss and other.name ~= boss.name and other.name:find(piece, 1, true)
						and Shared(boss.name, other.name) == piece then
						return true
					end
				end
			end
		end
	end
	return false
end

-- A boss's names alone (BareNames), worked out the first time a page asks for them.
local function BareOf(name)
	local base = BareBase()
	local count, byWord, notName = base.count, base.byWord, base.notName
	local names = {}
	local function Keep(candidate)
		if type(candidate) ~= "string" then return end
		candidate = candidate:gsub("^\231\154\132", ""):gsub("\231\154\132$", "")
		if candidate == name or Chars(candidate) < 2 then return end
		for _, known in ipairs(names) do
			if known == candidate then return end
		end
		names[#names + 1] = candidate
	end
	for _, boss in ipairs(base.byName[name] or {}) do
		if Chars(name) >= 3 and next(boss.names) then
			-- the side of "的" that is the name
			if boss.en:find(" the ", 1, true) then
				Keep(name:match("^.*\231\154\132(.+)$"))
			elseif boss.en:find(" of ", 1, true) or boss.en:find("'s ", 1, true) then
				Keep(name:match("^(.-)\231\154\132"))
			end
			for _, word in ipairs(boss.words) do
				if boss.names[word] then
					-- the name's word: what the name shares most with the other names that have it
					if not notName[word] then
						local votes, best, most = {}, nil, 0
						for _, other in ipairs(byWord[word]) do
							if other ~= boss and other.name ~= name then
								local piece = Shared(name, other.name):gsub("^\231\154\132", ""):gsub("\231\154\132$", "")
								if Chars(piece) >= 3 and piece ~= name then
									votes[piece] = (votes[piece] or 0) + 1
									if votes[piece] > most or (votes[piece] == most and #piece > #best) then
										best, most = piece, votes[piece]
									end
								end
							end
						end
						Keep(best)
					end
				elseif word:find("^%u") and (count[word] or 0) >= 2 then
					-- a title other bosses have too: the name less what it shares with theirs
					for _, other in ipairs(byWord[word]) do
						if other.isBoss and other ~= boss and other.name ~= name then
							local piece = Shared(name, other.name)
							if Chars(piece) >= 2 then Keep(CutOff(name, piece)) end
						end
					end
				end
			end
		end
	end
	local kept = {}
	for _, candidate in ipairs(names) do
		if not Title(base, candidate) then kept[#kept + 1] = candidate end
	end
	return kept[1] and kept or nil
end

--[[
	The names alone of a boss's name (BareOf above): bare[name], each boss's worked out as it is first asked
	for, none in a spaced script. Made once for each language.
]]
local function BareNames()
	local locale = Locale()
	if bare and bareFor == locale then return bare end
	local spaced = Spaced()
	bare, bareFor = setmetatable({}, { __index = function(made, name)
		local names = not spaced and type(name) == "string" and BareOf(name) or false
		rawset(made, name, names)
		return names or nil
	end }), locale
	return bare
end

-- (for the tests)
Discovery.BareNames = BareNames

-- The articles a name may start with ("The Seven"): a name that does is found only as it is written.
local ARTICLES = {}
for _, word in ipairs({ "the", "a", "an", "le", "la", "les", "el", "los", "las", "lo", "o", "os", "as", "der", "die",
	"das", "den", "dem", "des", "un", "une", "ein", "eine" }) do
	ARTICLES[word] = true
end

-- A set of the words of a list.
local function Words(list)
	local set = {}
	for word in list:gmatch("%S+") do set[word] = true end
	return set
end

-- The particles Korean writes after a name ("헐레이를", "아루갈의", "아루갈에게서"), which stay after a "???"; the
-- quoting ones too ("쇠퇴송곳니라고 불리는", called Witherfang, in his Spoken story: the review of 2026-11-18).
local KO_PARTICLES = Words("은 는 이 가 을 를 의 에 에서 에게 에게서 한테 께 께서 와 과 도 로 으로 만 까지 부터 처럼 보다 라고 이라고 "
	.. "이나 나 랑 이랑 이며 며 이고 고 이다 다 이라 라 이라는 라는 이란 란 으로서 로서 으로써 로써 에는 에서는 에게는 와는 과는 "
	.. "와의 과의 에서의 에의 으로의 로의 에도 에서도 에게도 와도 과도 로도 으로도 이야 야 이여 여 뿐 마저 조차 이든 든 인 입니다")
local function Particle(ending)
	return ending == "" or KO_PARTICLES[ending] == true
end
-- (for the tests)
Discovery.Particle = Particle

--[[
	The articles a quest's name may start with in the languages that write a name in small letters
	mid-sentence or change its article there (ARTICLES_OF), and what a line may write in that article's
	place (STANDS_FOR): another case's article, or the article and "of" or "to" in one ("au gambit de
	l'Aube", of "Le gambit de l'Aube"; "der Defiasbruderschaft", of "Die Defiasbruderschaft").
]]
local ARTICLES_OF, STANDS_FOR = {}, {}
ARTICLES_OF.deDE, STANDS_FOR.deDE = Words("der die das"), Words("der die das den dem des")
ARTICLES_OF.frFR, STANDS_FOR.frFR = Words("le la les"), Words("le la les au aux du des")
ARTICLES_OF.esES, STANDS_FOR.esES = Words("el la los las"), Words("el la los las lo al del")
ARTICLES_OF.esMX, STANDS_FOR.esMX = ARTICLES_OF.esES, STANDS_FOR.esES
ARTICLES_OF.ptBR = Words("o a os as")
STANDS_FOR.ptBR = Words("o a os as ao aos à às do da dos das no na nos nas pelo pela pelos pelas")

-- What the language's data adds to these rules (Locales/*_content.lua; English's in Locales/enUS.lua):
-- MASK_BOSS_FORMS, a boss's other forms by its English name, where a line says it in a way no rule
-- finds (a Chinese name alone, without its title); MASK_QUEST_FORMS, the same for a quest, by its id;
-- MASK_GROUP_WORDS, the words of bosses' names that name their group or their rank ("Twilight", of
-- Twilight Lord Kelris), put out only as part of the boss's whole name; MASK_PLACES, places named after
-- a boss, whose names are never put out ("Grim Guzzler"); MASK_NAMES, others' names (a faction's, a
-- group's, a word) that are a quest's in the language, never put out as the quest on a boss's page or in a
-- dungeon's description (Discovery:MaskPage).
local function MaskData(field)
	local value = ns.L and ns.L[field]
	return type(value) == "table" and value or {}
end

-- The group words (MaskData), in small letters, as a set; and the places, in small letters. Made once
-- for each language.
local groupWords, maskPlaces, groupWordsFor
local function GroupWords()
	local locale = Locale()
	if groupWords and groupWordsFor == locale then return groupWords, maskPlaces end
	groupWords, maskPlaces, groupWordsFor = {}, {}, locale
	for _, word in ipairs(MaskData("MASK_GROUP_WORDS")) do
		if type(word) == "string" then groupWords[Fold(word)] = true end
	end
	for _, place in ipairs(MaskData("MASK_PLACES")) do
		if type(place) == "string" and place ~= "" then maskPlaces[#maskPlaces + 1] = Fold(place) end
	end
	return groupWords, maskPlaces
end

--[[
	The hidden bosses a dungeon's Before you go names with no page of their own (an entry's boss, no boss
	of its list: Theldren, Hurley Blackbreath): { key, name, full, summons } each: its English name, its name
	in the language (entry.bossName, from Core/Registry.lua's ns.ApplyLocale) or the English, without the
	article it starts with; that name with its article (full), where it has one, put out whole with it as
	the English name is ("Le seigneur Valthalak, un boss caché"); and the quests that call it up (its
	entries' summons): only those tell it, or meeting it (StillHidden below).
]]
local hiddenOf = setmetatable({}, { __mode = "k" })
local function HiddenOf(instance)
	local hidden = hiddenOf[instance]
	if hidden then return hidden end
	hidden = {}
	local seen = {}
	for _, entry in ipairs(instance.prepare or {}) do
		local key = entry.boss
		if type(key) == "string" and seen[key] then
			-- (one for each side, as Hurley Blackbreath's: each side's quests call him up)
			for _, questID in ipairs(entry.summons or {}) do table.insert(seen[key].summons, questID) end
		elseif type(key) == "string" then
			local page = false
			for _, boss in ipairs(instance.bosses or {}) do
				if boss.enName == key or boss.name == key then page = true end
			end
			if not page then
				-- (without an article it starts with: "seigneur Valthalak", of the French "Le seigneur Valthalak",
				-- as a line says "du seigneur Valthalak")
				local name, full = entry.bossName or key, nil
				local article, rest = name:match("^(%S+)%s+(.+)$")
				if article and ARTICLES[article:lower()] then name, full = rest, name end
				local made = { key = key, name = name, full = full, summons = {} }
				for _, questID in ipairs(entry.summons or {}) do made.summons[#made.summons + 1] = questID end
				seen[key] = made
				hidden[#hidden + 1] = made
			end
		end
	end
	hiddenOf[instance] = hidden
	return hidden
end

-- Each boss's other forms (MaskData) by its name in the journal's language, made once for each language.
local shortForms, shortFormsFor
local function ShortForms()
	local locale = Locale()
	if shortForms and shortFormsFor == locale then return shortForms end
	shortForms, shortFormsFor = {}, locale
	local byEnglish = MaskData("MASK_BOSS_FORMS")
	if not next(byEnglish) then return shortForms end
	local function Add(english, name)
		local forms = byEnglish[english]
		if type(forms) == "table" and type(name) == "string" then shortForms[name] = forms end
	end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			for _, boss in ipairs(instance.bosses or {}) do Add(boss.enName or boss.name, boss.name) end
			for _, hidden in ipairs(HiddenOf(instance)) do
				Add(hidden.key, hidden.name)
				if hidden.full then Add(hidden.key, hidden.full) end
			end
		end
	end
	return shortForms
end

--[[
	A word of Russian cut to the stem its other endings share, so a name is found however a sentence
	declines it (the other languages don't decline names: a word there is its own stem): an adjective's
	two-letter ending (Военный, Военного) and the vowel a few nouns drop (Огнеборец, Огнеборца) cut off; a
	last vowel, "й" or soft sign (Вождь, вождя) cut off; a last consonant kept (Аругал, Аругала).
]]
local LAST = "[%z\1-\127\192-\255][\128-\191]*$"
local RU_TWO, RU_ONE = {}, {}
for _, ending in ipairs({ "ый", "ий", "ой", "ая", "яя", "ое", "ее", "ые", "ие", "ец", "ок", "ек" }) do RU_TWO[ending] = true end
for _, ending in ipairs({ "а", "я", "о", "е", "ё", "ы", "и", "у", "ю", "ь", "й" }) do RU_ONE[ending] = true end
-- (the two-letter endings of these that are an adjective's)
local RU_ADJECTIVE = {}
for _, ending in ipairs({ "ый", "ий", "ой", "ая", "яя", "ое", "ее", "ые", "ие" }) do RU_ADJECTIVE[ending] = true end
local stems = {}
local function Stem(word, russian)
	if not russian then return word end
	local made = stems[word]
	if made then return made end
	made = word
	local chars = Chars(word)
	local last = word:match(LAST)
	local before = word:sub(1, #word - #last)
	local two = before:match(LAST) or ""
	if chars >= 5 and RU_TWO[two .. last] then
		made = before:sub(1, #before - #two)
	elseif chars >= 4 and RU_ONE[last] then
		made = before
	end
	stems[word] = made
	return made
end


--[[
	A run of a name's words (first to last) as a phrase for PutOutPhrase: each word's stem (Stem) with
	any ending of its own, in Russian every word; in the other languages a word of four letters or more,
	cut short by a letter. loose: found whatever the case of its first letter (a name with a name of its
	own in it: Russian writes a title in small letters mid-sentence, "архимага Аругала"). whole: outside
	Russian, each word as it is, with a plural's ending at most (Plural), as a name of an article and one
	word is ("du Baron", "der Bestie"; not "a seta" for the Portuguese The Seven).
]]
-- (a word's ending: letters only, of ASCII and the two-byte scripts, so not a quote or a dash after it)
local RUN_ON = "[%w\128-\191\195-\223]*"
-- (a run of letters: from a letter's first byte on; and the first three letters of one)
local LETTERS = "[%w\195-\223][%w\128-\191\195-\223]*"
-- (the word just before a space at a text's end, without a quote before it: "„Das " has "das")
local WORD_BEFORE = "(" .. LETTERS .. ")%s+$"
local THREE = "^[%z\1-\127\192-\255][\128-\191]*[%z\1-\127\192-\255]?[\128-\191]*[%z\1-\127\192-\255]?[\128-\191]*"
local function Phrase(words, first, last, russian, loose, whole)
	local pattern, cut, lengths, head = {}, {}, {}, nil
	-- (German declines an article inside a name: "Alzzin dem Wildformer", of Alzzin der Wildformer)
	local german = Locale() == "deDE"
	for index = first, last do
		local word, at = words[index], index - first + 1
		local folded = Fold(word)
		local stem = folded
		if russian then
			stem = Fold(Stem(word, true))
		elseif german and at > 1 and ARTICLES[folded] and folded:sub(1, 1) == "d" then
			stem = "d"
		elseif Chars(word) >= 4 and not whole then
			stem = folded:sub(1, #folded - #folded:match(LAST))
		end
		cut[at] = russian or whole or stem ~= folded
		lengths[at] = #stem
		if at == 1 then head = stem end
		pattern[at] = Plain(stem) .. (cut[at] and RUN_ON or "")
	end
	-- (key: its first three letters, where its first word starts with three, to look it up by: Mask)
	local run = head:match("^" .. LETTERS)
	-- (words apart or joined by a dash: "Mor-Grauhuf-Fassungen", Mor Grayhoof's settings)
	return { first = words[first]:match("^[%z\1-\127\192-\255][\128-\191]*"), loose = loose, cut = cut,
		plural = whole and not russian or nil,
		lengths = lengths, head = head, pattern = table.concat(pattern, "[%s%-]+"),
		key = run and Chars(run) >= 3 and run:match(THREE) or nil }
end

--[[
	A boss's name taken apart for Forms, once for each language: whether the whole name is put out (not
	one a dungeon's name holds: InDungeonName); and each word of it that is a name of its own ("Jergosh"
	of "Jergosh the Invoker", "Pythas" of "Lord Pythas"), cut to its stem (Stem), so a declined name is
	found too; not a common word (Common above), nor a group word (MaskData). A word of three letters is
	one in Russian (Вун, Лин), and a word an elided "d'" starts is the word after it; a Russian adjective
	is one only in a phrase (below). In Chinese, the name without its title too (BareNames); and the
	language's own other forms (MaskData). A name of an article and one word ("The Seven", "Die Bestie")
	has none: it is that word after the article (a phrase: PutOutPhrase).
	elsewhere: another dungeon's boss, whose words a quest's name or someone's has without the boss's
	whole name are left alone (InQuestName, but for a quest of its own dungeon, home: its key); they
	still make its phrases. In a spaced script, a name of two words or more is a phrase too, each word's
	ending free, so a declined name of common words is found ("Тени Архимага", of "Тень Архимага"); and so
	is each run of two of its words or more, from a capital to a capital, that holds a name of its own
	("Ренда Чернорука", of "Вождь Ренд Чернорук"), with that name's stems (stems: Forms leaves a run
	whose names a place has). loose: the name is found whatever the case of its first letter (PutOut), as
	it holds a name of its own or starts with no article (a title in small letters mid-sentence: "du roi
	Gordok").
]]
local parts, partsFor = {}, nil
local function Parts(name, elsewhere, home)
	local locale = Locale()
	if partsFor ~= locale then parts, partsFor = {}, locale end
	local key = (elsewhere and "\1" or "\2") .. tostring(home) .. "\1" .. name
	local made = parts[key]
	if made then return made end
	local spaced, russian, group = Spaced(), locale == "ruRU", GroupWords()
	made = { whole = not InDungeonName(name) }
	local words, distinct, capital = {}, {}, {}
	for word in name:gsub("\194\183", " "):gmatch("%S+") do words[#words + 1] = word end
	-- (an article and one word, "The Seven", "Die Bestie": that word is no name alone, "Seven Dark Iron
	-- ghosts", "die Verlassenen", the Forsaken; the name is found after its article: Phrase, PutOutPhrase)
	local article = spaced and #words == 2 and ARTICLES[Fold(words[1])] and Fold(words[1]) or nil
	for index, word in ipairs(words) do
		local own = Bare(word)
		local wide = own ~= "" and own:byte(1) >= 0xE0
		local chars = Chars(own)
		capital[index] = own ~= "" and (wide or Capital(own))
		if not article and capital[index] and chars >= (wide and 2 or russian and 3 or 4) and not group[Fold(own)]
			and not group[Fold(word)] then
			local stem = (spaced and not wide) and Stem(own, russian) or own
			if not IsCommon(own, stem) then
				distinct[index] = stem
				-- (a Russian adjective, "Глубинная" of Кам Глубинная Ярость, is no name alone: the Fathom Stone
				-- is "Глубинный камень"; it is found with the word after it, a phrase below)
				local adjective = russian and #words > 1 and RU_ADJECTIVE[stem ~= own and own:sub(#stem + 1) or ""]
				if not adjective and not (elsewhere and InQuestName(stem, name, home)) then made[#made + 1] = stem end
			end
		end
	end
	-- (another dungeon's boss named with one word that other bosses' abilities or adds have, "Bolt" of Shadow Bolt:
	-- its whole name is no name of its own on this page, where "Shadow Bolt" or "Bolts of Runecloth" says that
	-- word; its own page, home, still has it whole. A word only the boss's own abilities have, "Rhahk'Zor" of
	-- Rhahk'Zor Slam, is still his name, and so is a title other bosses' names have, the Russian "Барон", The Baron)
	if elsewhere and made.whole and #words == 1 and not distinct[1] then
		local owner = Common().owned[Bare(words[1])]
		if owner ~= nil and owner ~= name then made.whole = false end
	end
	-- (a Russian name of one common word, "Чудовище", the Beast: declined too, with its capital)
	if russian and #words == 1 and made.whole and capital[1] and not distinct[1] and Chars(words[1]) >= 4 then
		local stem = Stem(words[1], true)
		if stem ~= words[1] then made[#made + 1] = stem end
	end
	for _, alone in ipairs(BareNames()[name] or {}) do
		if not IsCommon(alone, alone) and not (elsewhere and InQuestName(alone, name, home)) then made[#made + 1] = alone end
	end
	for _, form in ipairs(ShortForms()[name] or {}) do
		if type(form) == "string" and form ~= "" then made[#made + 1] = form end
	end
	made.loose = next(distinct) ~= nil or (#words > 1 and not ARTICLES[Fold(words[1])])
	made.phrases = {}
	if article and made.whole and name:byte(1) < 0xE0 then
		-- (with its capital, as the language writes the name: "du Baron", of Le Baron; "le baron", "la bestia
		-- salvaje", "les sept nains" are no names)
		made.phrases[1] = Phrase(words, 2, 2, russian, false, true)
		made.phrases[1].article = article
	elseif spaced and made.whole and #words >= 2 and name:byte(1) < 0xE0 then
		made.phrases[1] = Phrase(words, 1, #words, russian, made.loose)
		for first = 1, #words - 1 do
			for last = first + 1, #words do
				local stems = {}
				for index = first, last do stems[#stems + 1] = distinct[index] end
				-- (another dungeon's: not a run a quest's or someone's name has without the boss's, as its words
				-- alone: "Witch Doctor", of Witch Doctor Zum'rah, in Witch Doctor Uzer'i)
				if stems[1] and capital[first] and capital[last] and not (first == 1 and last == #words)
					and not (elsewhere and InQuestName(table.concat(words, " ", first, last), name, home)) then
					local phrase = Phrase(words, first, last, russian, true)
					phrase.stems = stems
					made.phrases[#made.phrases + 1] = phrase
				end
			end
		end
	end
	parts[key] = made
	return made
end

--[[
	What a boss's name must be in a line for it to be looked for there at all (Forms below), in small
	letters: the stem a phrase looks for (Phrase) of each of its words that is a name of
	its own (not a common or group word), else of its longest word; and its other forms (MaskData). In a
	script with no spaces, every two characters of it. Any form Parts makes of it holds one. Made once for
	each name and language.
]]
local keysOf, keysFor = {}, nil
local function Keys(name)
	local locale = Locale()
	if keysFor ~= locale then keysOf, keysFor = {}, locale end
	local keys = keysOf[name]
	if keys then return keys end
	keys = {}
	-- (where the text has two Chinese or Korean characters side by side, only such pairs: every form of it
	-- holds one, its names alone too, and "斯·" is in many names)
	local function Pairs(text)
		local letters = Letters(text)
		local pure = text:find("[\224-\239][\128-\191][\128-\191][\224-\239]") ~= nil
		for index = 1, math.max(#letters - 1, 1) do
			local last = math.min(index + 1, #letters)
			if not pure or (last > index and #letters[index] == 3 and #letters[last] == 3) then
				keys[#keys + 1] = table.concat(letters, "", index, last)
			end
		end
	end
	local forms = ShortForms()[name] or {}
	if not Spaced() then
		Pairs(name)
		for _, form in ipairs(forms) do Pairs(form) end
	else
		local known, group, russian, longest = Common().words, GroupWords(), locale == "ruRU", ""
		-- (the name in small letters once: each word's are the same bytes of it)
		local text = name:find("\194\183", 1, true) and name:gsub("\194\183", " ") or name
		local small = Fold(text)
		for at, word in text:gmatch("()(%S+)") do
			local own = Bare(word)
			if own == "" then own = word end
			local whole = small:sub(at, at + #word - 1)
			local from = own == word and 1 or word:find(own, 1, true) or 1
			local wide, folded = own:byte(1) >= 0xE0, own == word and whole or whole:sub(from, from + #own - 1)
			local stem = folded
			if russian then
				stem = Stem(folded, true)
			elseif not wide and Chars(own) >= 4 then
				stem = stem:sub(1, #stem - #stem:match(LAST))
			end
			if #stem > #longest then longest = stem end
			if (wide or Capital(own)) and not known[own] and not group[folded] and (own == word or not group[whole]) then
				keys[#keys + 1] = stem
			end
		end
		if #keys == 0 then keys[1] = longest end
		for _, form in ipairs(forms) do keys[#keys + 1] = Fold(form) end
	end
	keysOf[name] = keys
	return keys
end

-- The keys of a line (folded: Fold) a key (KeyHead below) must be among for it to be looked for there:
-- the first three letters of each of its words (a run of letters, as Phrase's); and each two characters
-- side by side of Chinese and Korean.
local function LineKeys(text, folded)
	local keys = {}
	for word in folded:gmatch(LETTERS) do keys[word:match(THREE)] = true end
	local at = text:find("[\224-\239]")
	while at do
		local after = text:byte(at + 3)
		if after and after >= 224 and after <= 239 then keys[text:sub(at, at + 5)] = true end
		at = text:find("[\224-\239]", at + 3)
	end
	return keys
end

-- What a line's keys (LineKeys) must hold for a text (a key of Keys, in small letters) to be in it: two
-- characters of Chinese or Korean side by side in it, else the first three letters of a word of it of
-- three letters or more; nil where it has neither (looked for in every line).
local function KeyHead(key)
	local pair = key:match("[\224-\239][\128-\191][\128-\191][\224-\239][\128-\191][\128-\191]")
	if pair then return pair end
	for run in key:gmatch(LETTERS) do
		if Chars(run) >= 3 then return run:match(THREE) end
	end
	return nil
end

--[[
	Every boss's name, hidden ones too, by its keys (Keys) and their heads (KeyHead): a page makes a boss's
	forms only once a line holds one of its keys (Wake below), and a line asks only for the names its own
	keys may hold. Made once for each language.
]]
local bossIndex
local function BossIndex()
	local locale = Locale()
	if bossIndex and bossIndex.locale == locale then return bossIndex end
	local index = { heads = {}, always = {}, seen = {}, locale = locale }
	local function Add(name)
		if type(name) ~= "string" or name == "" or index.seen[name] then return end
		index.seen[name] = true
		for _, key in ipairs(Keys(name)) do
			local entry, head = { name = name, key = key }, KeyHead(key)
			if head then
				index.heads[head] = index.heads[head] or {}
				table.insert(index.heads[head], entry)
			else
				index.always[#index.always + 1] = entry
			end
		end
	end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			for _, boss in ipairs(instance.bosses or {}) do Add(boss.name) end
			for _, hidden in ipairs(HiddenOf(instance)) do
				Add(hidden.full)
				Add(hidden.name)
			end
		end
	end
	bossIndex = index
	return index
end

-- (an empty list, read only)
local EMPTY = {}

-- Each form as Forms keeps it: { form, folded (its small letters: Fold), first (its first letter) }, made
-- once for each language and shared by every page's forms.
local formEntries, formEntriesFor = {}, nil
local function FormEntry(form)
	local locale = Locale()
	if formEntriesFor ~= locale then formEntries, formEntriesFor = {}, locale end
	local entry = formEntries[form]
	if not entry then
		entry = { form = form, folded = Fold(form), first = form:match("^[%z\1-\127\192-\255][\128-\191]*") }
		formEntries[form] = entry
	end
	return entry
end

-- A page's forms longest first, as they were made where two are as long: each length's in a bucket of
-- its own (a dungeon's items make a list of hundreds).
local function Longer(list)
	local buckets, most = {}, 0
	for _, entry in ipairs(list) do
		local length = #entry.form
		local bucket = buckets[length]
		if not bucket then
			bucket = {}
			buckets[length] = bucket
			if length > most then most = length end
		end
		bucket[#bucket + 1] = entry
	end
	local at = 0
	for length = most, 1, -1 do
		for _, entry in ipairs(buckets[length] or EMPTY) do
			at = at + 1
			list[at] = entry
		end
	end
end

-- Whether a word is in the name of a boss a page shows anyway (made.shown).
local function Shown(made, word)
	for _, name in ipairs(made.shown) do
		if name:find(word, 1, true) then return true end
	end
	return false
end

-- A form for a page's lines (made.list): any (any case: an ability's, an add's or an item's name) and
-- loose (any case of its first letter: PutOut) kept for the page in made.any and made.loose.
local function AddForm(made, form, any, loose)
	if form == "" then return end
	if not made.added[form] then
		made.added[form] = true
		local list, entry = made.list, FormEntry(form)
		if made.sorted then
			-- (once the page's list is in order, longest first, each form made later goes in its place)
			local low, high, length = 1, #list + 1, #form
			while low < high do
				local middle = math.floor((low + high) / 2)
				if #list[middle].form >= length then low = middle + 1 else high = middle end
			end
			table.insert(list, low, entry)
		else
			list[#list + 1] = entry
		end
	end
	if any then
		made.any = made.any or {}
		made.any[form] = true
	end
	if loose then
		made.loose = made.loose or {}
		made.loose[form] = true
	end
end

-- A boss's forms (Parts) for a page, but for a word its places or a boss shown have; its phrases too, in
-- the order of the bosses they are of (rank: Forms's), whenever each is made.
local function AddBoss(made, name, elsewhere, home, rank)
	local parts = Parts(name, elsewhere, home)
	if parts.whole then AddForm(made, name, false, parts.loose and name:find("%s") ~= nil) end
	if parts.whole and parts.phrases[1] and parts.phrases[1].article then
		made.alone = made.alone or {}
		made.alone[name] = true
	end
	for _, stem in ipairs(parts) do
		if not made.places:find(stem, 1, true) and not Shown(made, stem) then AddForm(made, stem) end
	end
	for order, phrase in ipairs(parts.phrases) do
		local named = not phrase.stems
		for _, stem in ipairs(phrase.stems or {}) do
			named = named or not (made.places:find(stem, 1, true) or Shown(made, stem))
		end
		if named and not made.rank[phrase] then
			made.rank[phrase] = rank * 1000 + order
			made.phrases[#made.phrases + 1] = phrase
		end
	end
end

--[[
	What a line must not say of a dungeon: each unmet boss's name and its parts (Parts above), but for
	what is shown anyway: a word of a dungeon's name or of one of this dungeon's places ("Crag of the
	Everliving"), or of a met boss's name (the page's own "Sneed's Shredder"). Then the other names given
	(Discovery:Unseen), whole; its hidden bosses not told yet (extra.hidden), as its own bosses; and other
	dungeons' unmet bosses (extra.bosses: Discovery:Untold), as this dungeon's own are. A boss's forms are
	made only once a line holds one of its keys (BossIndex), so a page makes forms for the bosses its lines
	name and no other (Wake below). Longest first; and the phrases of the names of several words, in the
	order of the bosses: this dungeon's, its hidden ones, then the others.
]]
local function Forms(self, instance, extra)
	local made = { list = {}, phrases = {}, pending = {}, waiting = 0, ranks = 0, rank = {}, added = {}, shown = {},
		places = (instance.name or "") .. "\n" .. DungeonNames(), spaced = Spaced(), particles = Locale() == "koKR" }
	for _, boss in ipairs(instance.bosses or {}) do
		if type(boss.area) == "string" then made.places = made.places .. "\n" .. boss.area end
		if type(boss.name) == "string" and not self:Unmet(instance, boss) then made.shown[#made.shown + 1] = boss.name end
	end
	local index = BossIndex()
	-- (each waits for a line that holds one of its keys; one the index lacks is made now)
	local function Wait(name, elsewhere, home)
		if made.pending[name] then return end
		made.ranks = made.ranks + 1
		if index.seen[name] then
			made.pending[name] = { elsewhere = elsewhere, home = home, rank = made.ranks }
			made.waiting = made.waiting + 1
		else
			AddBoss(made, name, elsewhere, home, made.ranks)
		end
	end
	for _, boss in ipairs(instance.bosses or {}) do
		local name = boss.name
		if type(name) == "string" and name ~= "" and self:Unmet(instance, boss) and not Shown(made, name) then
			Wait(name, false, instance.key)
		end
	end
	-- Chinese and Korean names are short: two characters there say as much as four letters.
	for _, name in ipairs(extra or {}) do
		-- (not one a place's name holds, which the lists show: the sword Shadowfang, of Shadowfang Keep)
		if type(name) == "string" and Chars(name) >= (name:byte(1) >= 0xE0 and 2 or 4) and not made.places:find(name, 1, true) then
			AddForm(made, name, true)
		end
	end
	for _, name in ipairs(extra and extra.hidden or {}) do Wait(name, false, instance.key) end
	-- (each with its dungeon's key, extra.homes: InQuestName)
	local homes = extra and extra.homes or {}
	for _, name in ipairs(extra and extra.bosses or {}) do
		if not Shown(made, name) then Wait(name, true, homes[name]) end
	end
	Longer(made.list)
	made.sorted = true
	table.sort(made.phrases, function(a, b) return made.rank[a] < made.rank[b] end)
	return made
end

-- The bosses a line may name (made.pending: a key of theirs in it, keys: LineKeys's), made as one does: each
-- made once.
local function Wake(made, folded, keys)
	local index, woke = BossIndex(), false
	local function Try(list)
		for _, entry in ipairs(list) do
			local wait = made.pending[entry.name]
			if wait and folded:find(entry.key, 1, true) then
				made.pending[entry.name] = nil
				made.waiting = made.waiting - 1
				AddBoss(made, entry.name, wait.elsewhere, wait.home, wait.rank)
				woke = true
			end
		end
	end
	for head in pairs(keys) do
		local list = index.heads[head]
		if list then Try(list) end
	end
	Try(index.always)
	if woke then table.sort(made.phrases, function(a, b) return made.rank[a] < made.rank[b] end) end
end

--[[
	A text with a form put out as "???", found whatever the case of its letters but its first (a
	place's name may write a name's inner capital otherwise); loose: whatever the case of its first too (a
	boss's whole name with a name of its own in it: Parts); any: any case at all, for the names of
	abilities, adds and items. In a spaced script only where a word starts, and with the ending of that
	word ("Rhahk'Zora", "Kelris's"); a word that goes on for more than an ending is another word (the
	German for a captain's cabin begins with the German for captain). In a language of the Latin letters
	the ending is a plural's or a genitive's ("s", "en") only, so "Heal" is not found in "health", nor
	"Skul" in "Skull"; Russian's are any three letters at most; Korean's are its particles only
	(KO_PARTICLES), so "스컬지", the Scourge, is no "스컬" (Skul). Korean's particles stay after the "???"
	(particles): they are words of their own.
]]
local ENDING = 3
-- (German's take "n" and "en" too, and a quest's name or an add's, ability's or item's "e" ("Skelettfragmente",
-- "Manaphantome"); a boss's no "e", nor English's but an "s", so "Marduke" is no "Marduk")
-- (its lists in a block of their own: this file's main chunk is near Lua's 200 locals)
local Plural
do
	local PLURALS = { [""] = true, s = true, es = true }
	local GERMAN_PLURALS = { [""] = true, s = true, es = true, n = true, en = true }
	local GERMAN_QUEST_PLURALS = { [""] = true, s = true, es = true, e = true, n = true, en = true }
	function Plural(ending, locale, quest)
		if locale == "deDE" then return (quest and GERMAN_QUEST_PLURALS or GERMAN_PLURALS)[ending] == true end
		return PLURALS[ending] == true
	end
end
local function Fits(ending, any)
	local locale = Locale()
	if locale == "ruRU" then return Chars(ending) <= ENDING end
	if locale == "koKR" then return Particle(ending) end
	return Plural(ending:lower(), locale, any)
end
local function PutOut(text, folded, form, spaced, particles, any, loose, alone)
	local wanted, first = form.folded, form.first
	local out, from = {}, 1
	local start, stop = folded:find(wanted, 1, true)
	while start do
		local ending = spaced and WordEnd(text, stop + 1)
		-- (alone: a name of an article and a word, not with a name of its own after it: "The Baron Aquanis")
		local after = alone and text:match("^ +(" .. LETTERS .. ")", (ending or stop) + 1)
		if (spaced and (Letter(CharBefore(text, start)) or not Fits(text:sub(stop + 1, ending), any)))
			or not (any or loose or text:sub(start, start + #first - 1) == first)
			or (after and Capital(after) and not after:find("^%d")) then
			start, stop = folded:find(wanted, start + 1, true)
		else
			if spaced and not particles then stop = ending end
			out[#out + 1] = text:sub(from, start - 1)
			out[#out + 1] = UNKNOWN
			from = stop + 1
			start, stop = folded:find(wanted, from, true)
		end
	end
	if from == 1 then return text end
	out[#out + 1] = text:sub(from)
	return table.concat(out)
end

--[[
	A text with a name of several words put out as "???" (or what put gives for name and the words found),
	each word with an ending of its own
	(Phrase), where a word starts and its first letter as the name has it (any case, for a loose phrase);
	quoted: only just after an opening quote. A name of an article and a word (Parts: phrase.article) is
	its word after that article, in any case, or in German, French, Spanish and Portuguese after any of
	their articles, as a case changes it or "of" or "to" joins it ("der Bestie", of Die Bestie; "du
	Voracien", of Le Voracien); the article stays; and not with a word of a name after it ("le Baron
	Aquanis" is Baron Aquanis).
]]
local CONTRACTS = { deDE = true, frFR = true, esES = true, esMX = true, ptBR = true }
local function PutOutPhrase(text, folded, phrase, put, name, quoted)
	-- (its first word's stem looked for first: most lines have none of these names)
	if not folded:find(phrase.head, 1, true) then return text, folded end
	local start, stop = folded:find(phrase.pattern)
	while start do
		local before = CharBefore(text, start)
		local fits = not Letter(before) and (not quoted or QUOTE_ENDS[before] == true)
			and (phrase.loose or text:sub(start, start + #phrase.first - 1) == phrase.first)
		if fits and phrase.article then
			local locale = Locale()
			local word = folded:sub(math.max(1, start - 8), start - 1):match(WORD_BEFORE)
			fits = word == phrase.article or (word ~= nil and CONTRACTS[locale] and STANDS_FOR[locale][word] == true)
			-- (not with a name of its own after it: "le Baron Aquanis", "Die Verlassene Höhle" are others')
			local after = fits and text:match("^ +(" .. LETTERS .. ")", stop + 1)
			if after and Capital(after) and not after:find("^%d") then fits = false end
		end
		if fits then
			-- each word's ending a few letters at most (the pattern lets a word run on)
			local index = 0
			for word in folded:sub(start, stop):gmatch("[^%s%-]+") do
				index = index + 1
				local ending = phrase.cut[index] and word:sub(phrase.lengths[index] + 1)
				if ending and (phrase.plural and not Plural(ending, Locale()) or not phrase.plural and Chars(ending) > ENDING) then
					fits = false
				end
			end
		end
		if fits then
			local replace = put and put(name, text:sub(start, stop)) or UNKNOWN
			text = text:sub(1, start - 1) .. replace .. text:sub(stop + 1)
			folded = Fold(text)
			start, stop = folded:find(phrase.pattern, start + #replace)
		else
			start, stop = folded:find(phrase.pattern, start + 1)
		end
	end
	return text, folded
end

--[[
	A line of the journal's own words with what the character has not found of the dungeon put out as
	"???": the names of its unmet bosses (Forms above), and the names given in extra (Discovery:Unseen:
	a boss's abilities and adds not fought yet, items not seen, hidden bosses not told; Discovery:Untold:
	other dungeons' unmet bosses). A name the page shows anyway stays: a met boss's ("Sneed" of "Sneed's
	Shredder", once he is met). Outside Adventure Mode, the line as it is.
]]
-- The forms made for each extra given (or the dungeon, with none): a page's lines all ask with the same one.
local masks = setmetatable({}, { __mode = "k" })

function Discovery:Mask(instance, text, extra)
	if type(text) ~= "string" or text == "" or not ns.Style:Adventure() or type(instance) ~= "table" then return text end
	-- The forms are made once for a page's lines, and again after a find.
	local locale = Locale()
	local made = masks[extra or instance]
	if not (made and made.instance == instance and made.version == self:Version() and made.locale == locale
		and made.store == ns.charDB.discovered) then
		made = Forms(self, instance, extra)
		made.instance, made.version, made.locale, made.store = instance, self:Version(), locale, ns.charDB.discovered
		masks[extra or instance] = made
	end
	-- (a line masked already with these forms: as it was, as a page draws its lines on every click)
	local original = text
	if made.done and made.done[original] then return made.done[original] end
	local folded = Fold(text)
	-- A place named after a boss (MaskData) is kept out of the way, then put back as it was.
	local kept
	for _, place in ipairs(select(2, GroupWords())) do
		local start, stop = folded:find(place, 1, true)
		while start do
			kept = kept or {}
			kept[#kept + 1] = text:sub(start, stop)
			local token = "\1" .. ("\2"):rep(#kept) .. "\1"
			text = text:sub(1, start - 1) .. token .. text:sub(stop + 1)
			folded = folded:sub(1, start - 1) .. token .. folded:sub(stop + 1)
			start, stop = folded:find(place, start + #token, true)
		end
	end
	-- (the bosses its keys may name made now: Wake)
	local keys = (made.waiting > 0 or made.phrases[1]) and LineKeys(text, folded)
	if made.waiting > 0 then Wake(made, folded, keys) end
	-- The phrases first: a declined name of several words is put out whole.
	-- (each looked for only where a word starts with its first three letters)
	if made.phrases[1] then
		for _, phrase in ipairs(made.phrases) do
			if not phrase.key or keys[phrase.key] then text, folded = PutOutPhrase(text, folded, phrase) end
		end
	end
	for _, form in ipairs(made.list) do
		if folded:find(form.folded, 1, true) then
			text = PutOut(text, folded, form, made.spaced, made.particles, made.any and made.any[form.form],
				made.loose and made.loose[form.form], made.alone and made.alone[form.form])
			folded = Fold(text)
		end
	end
	-- Two words of one name side by side, each put out: one "???".
	local joined
	repeat
		text, joined = text:gsub("%?%?%?%s+%?%?%?", UNKNOWN)
	until joined == 0
	if kept then text = text:gsub("\1(\2+)\1", function(count) return kept[#count] end) end
	made.done = made.done or {}
	made.done[original] = text
	return text
end

-- (a text's first character)
local FIRST = "^[%z\1-\127\192-\255][\128-\191]*"
-- (the quotes Chinese opens a quest's name with: “ 「 『)
local CHINESE_QUOTES = { ["\226\128\156"] = true, ["\227\128\140"] = true, ["\227\128\142"] = true }
-- (a quest's name kept: "\3", as many "\4" as its place in the list, "\3")
local function Mark(kept, name)
	kept[#kept + 1] = name
	return "\3" .. ("\4"):rep(#kept) .. "\3"
end

--[[
	The journal's quests in its language, for MaskQuests, gathered once for each language in one pass over
	every dungeon's quests and their chains' steps (each list of steps once), with nothing worked out yet
	that a line may never ask for:
	  names    each name once: { name, ids, en, order, form, head, also }; form: one of a quest's other
	           forms (MaskData), which counts as its name whoever has it; head and also: what a line's keys
	           (LineKeys) must hold for the name to be looked for in it
	  heads    the names by head; always, those with none
	  byID     every name of each quest id (a quest's and each step's)
	  offer    each id's side and class (faction, classOnly), where the quest or a step says them
	  lines    every quest's and step's name, and who gives and takes each, once, with the dungeon each is
	           of (homes: its key, true for several): InQuestName's
	  givers   who gives and takes each quest, as its line says it before the place
	  zones    the places those lines name after the giver ("Burning Steppes"): Placed below
]]
local questData
-- (a name's article and the name without it, in the languages that change a name's article mid-sentence
-- (ARTICLES_OF), "l'" for an elided one; but not a dungeon's name: "Les profondeurs de Rochenoire")
local function CoreOf(folded, locale)
	if not ARTICLES_OF[locale] then return folded, nil end
	local article, rest = folded:match("^(%S+)%s+(.+)$")
	if not (article and ARTICLES_OF[locale][article]) then
		article, rest = folded:match("^(l)['\226](.+)$")
		if rest then rest = rest:gsub("^\128\153", "") end
	end
	if rest and Chars(rest) >= 4 and not select(2, DungeonNames()):find(rest, 1, true) then return rest, article end
	return folded, nil
end
function QuestData()
	local locale = Locale()
	if questData and questData.locale == locale then return questData end
	local data = { names = {}, heads = {}, always = {}, byID = {}, offer = {}, lines = {}, homes = {}, givers = {},
		zones = {}, locale = locale }
	local byName, lines, homes, current = {}, data.lines, data.homes, nil
	local function Line(name)
		local home = homes[name]
		if home == nil then
			homes[name] = current
			lines[#lines + 1] = name
		elseif home ~= current and home ~= true then
			homes[name] = true
		end
	end
	-- (who gives or takes a quest, as its line says it before the place: "Shadowmage Vivian Lagrave", of
	-- "Shadowmage Vivian Lagrave, Badlands"; in Chinese before its "，". Each line read once.)
	local givers, read = data.givers, {}
	local function Person(entry, field)
		local text = entry and entry[field]
		if type(text) ~= "string" or entry.startItem or entry.startObject then return end
		local name = read[text]
		if not name then
			local place
			local comma = text:find(",", 1, true)
			if comma then
				name, place = text:sub(1, comma - 1), text:sub(text:byte(comma + 1) == 32 and comma + 2 or comma + 1)
			else
				name = text
			end
			comma = name:find("\239\188\140", 1, true)
			if comma then
				place = place or name:sub(comma + 3)
				name = name:sub(1, comma - 1)
			end
			if place and place ~= "" then data.zones[place] = true end
			read[text] = name
			givers[name] = true
		end
		Line(name)
	end
	local forms = MaskData("MASK_QUEST_FORMS")
	local names, byID, offer = data.names, data.byID, data.offer
	local function Named(name, questID, form, english)
		local entry = byName[name]
		if not entry then
			entry = { name = name, ids = {}, idSet = {}, en = english, order = #names + 1 }
			byName[name] = entry
			names[#names + 1] = entry
		end
		if form then entry.form = true end
		if english and not entry.en then entry.en = english end
		if not entry.idSet[questID] then
			entry.idSet[questID] = true
			entry.ids[#entry.ids + 1] = questID
		end
	end
	-- (a chain's steps are in many quests' lists: each name and id is taken once; byID's lists hold their
	-- names as keys too)
	local function Add(entry)
		local name, questID = entry.name, entry.questID
		if type(name) ~= "string" then return end
		local home = homes[name]
		if home == nil then
			homes[name] = current
			lines[#lines + 1] = name
		elseif home ~= current and home ~= true then
			homes[name] = true
		end
		if type(questID) ~= "number" then return end
		if not offer[questID] and (entry.faction or entry.classOnly) then
			offer[questID] = { faction = entry.faction, classOnly = entry.classOnly }
		end
		local of = byID[questID]
		if of and of[name] then return end
		if not of then
			of = {}
			byID[questID] = of
		end
		of[#of + 1], of[name] = name, true
		-- (its other forms whatever its own name is: a boss's, as the Korean for The God Hakkar is)
		if type(forms[questID]) == "table" then
			for _, form in ipairs(forms[questID]) do
				if type(form) == "string" and form ~= "" then Named(form, questID, true) end
			end
		end
		Named(name, questID, nil, type(entry.enName) == "string" and entry.enName or nil)
	end
	local lists, asked = {}, {}
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			current = instance.key
			for _, quest in ipairs(instance.quests or {}) do
				Person(quest, "pickup")
				Person(quest, "turnin")
				Add(quest)
				-- (a list of steps several quests share is taken once; its names are of each dungeon that has it)
				local steps = quest.prerequisites
				if steps and lists[steps] and lists[steps] ~= true and lists[steps] ~= current then
					lists[steps] = true
					for _, step in ipairs(steps) do
						if type(step.name) == "string" then Line(step.name) end
					end
				elseif steps and not lists[steps] then
					lists[steps] = current
					-- (most steps are in many lists: one taken already, and of this dungeon already, is passed
					-- over as it is found)
					for _, step in ipairs(steps) do
						local name, questID, versions = step.name, step.questID, step.oneOf
						local of, home = byID[questID], homes[name]
						if versions or not (of and of[name] and asked[questID] and (home == current or home == true)) then
							if questID and not asked[questID] then
								asked[questID] = true
								local known = ns.GetQuestStep and ns.GetQuestStep(questID)
								Person(known, "pickup")
								Person(known, "turnin")
							end
							Add(step)
							if versions then
								for _, version in ipairs(versions) do Add(version) end
							end
						end
					end
				end
			end
		end
	end
	-- Each name's keys (its small letters and the rest are made as a line first may hold it: QuestFolded):
	-- the first three letters of its longest word, and of its next longest (head, also), but an article
	-- it starts with, so of its name without the article, as PutOutQuoted finds it, a declined word keeping
	-- them; in Chinese and Korean, its first two characters side by side, and its last two.
	local articles = ARTICLES_OF[locale]
	for _, entry in ipairs(names) do
		local name = entry.name
		local head, also = name:match("[\224-\239][\128-\191][\128-\191][\224-\239][\128-\191][\128-\191]"), nil
		if head then
			also = name:match(".*([\224-\239][\128-\191][\128-\191][\224-\239][\128-\191][\128-\191])")
		else
			local longest, next, first = "", "", true
			for word in name:gmatch(LETTERS) do
				if not (first and articles and articles[Fold(word)]) and Chars(word) >= 3 then
					if #word > #longest then
						longest, next = word, longest
					elseif #word > #next then
						next = word
					end
				end
				first = false
			end
			head = longest ~= "" and Fold(longest:match(THREE)) or nil
			also = next ~= "" and Fold(next:match(THREE)) or nil
		end
		entry.head, entry.also = head, also ~= head and also or nil
		if head then
			data.heads[head] = data.heads[head] or {}
			table.insert(data.heads[head], entry)
		else
			data.always[#data.always + 1] = entry
		end
	end
	questData = data
	return data
end

--[[
	Whether a quest's name is looked for in a line at all, worked out the first time one may hold it, once
	for each language: not a name a dungeon or a boss has too (the pages name those as they do), nor a short
	one, nor one that is someone's name, who gives or takes a quest (Vivian Lagrave, of Shadowmage Vivian
	Lagrave), as the language or the English writes it (Emberstrife, whose step the translations leave in
	English): a line naming that one names the giver (but for a quest's notes that name it as a quest:
	Discovery:MaskAll's named). In Chinese, written without spaces, a name a giver's ends with (the giver's
	name, a title written before it as one word). A quest's other forms (MaskData) count, whoever has them.
]]
local questSkip, questPeople
local function QuestSkip()
	if questSkip and questSkip.locale == Locale() then return questSkip end
	local skip = { locale = Locale() }
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			if type(instance.name) == "string" then skip[instance.name] = true end
			for _, boss in ipairs(instance.bosses or {}) do
				if type(boss.name) == "string" then skip[boss.name] = true end
			end
			-- (a hidden boss's name too, as the Alliance's Hurley Blackbreath quest has: its own rules say when)
			for _, hidden in ipairs(HiddenOf(instance)) do
				skip[hidden.name] = true
				if hidden.full then skip[hidden.full] = true end
			end
		end
	end
	questSkip = skip
	return skip
end
-- (each run of words of a giver's name, "Vivian Lagrave" of "Shadowmage Vivian Lagrave", "Leonid
-- Barthalomew" of "Leonid Barthalomew the Revered"; in Chinese, each end of it)
local function QuestPeople(data)
	if questPeople and questPeople.data == data then return questPeople end
	local people, spaced = { data = data }, Spaced()
	for name in pairs(data.givers) do
		if not spaced then
			for at in name:gmatch("()[%z\1-\127\192-\255]") do people[name:sub(at)] = true end
		end
		local words = {}
		for word in name:gmatch("%S+") do words[#words + 1] = word end
		for first = 1, #words do
			for last = first, #words do people[table.concat(words, " ", first, last)] = true end
		end
	end
	questPeople = people
	return people
end
-- A name's small letters (folded), and without the article it starts with (core, article: CoreOf), made
-- the first time a line may hold it.
local function QuestFolded(entry)
	if not entry.folded then
		entry.folded = Fold(entry.name)
		entry.core, entry.article = CoreOf(entry.folded, Locale())
	end
	return entry
end
local function Kept(data, entry)
	local kept = entry.kept
	if kept == nil then
		local name = entry.name
		if entry.form then
			kept = true
		else
			local skip = QuestSkip()
			-- (nor one that is a boss's after its article: the Portuguese "O Barão Aquanis", of Baron Aquanis)
			local article, rest = name:match("^(%S+)%s+(.+)$")
			kept = not skip[name] and not (article and ARTICLES[article:lower()] and skip[rest])
				and Chars(name) >= (name:byte(1) >= 0xE0 and 2 or 4)
			if kept then
				local people = QuestPeople(data)
				kept = not (people[name] or (entry.en and people[entry.en]))
			end
		end
		entry.kept = kept
	end
	return kept
end

--[[
	The places a quest's name is never found inside, in small letters (Placed below): every dungeon's and
	raid's name, the places its bosses stand in, every boss's own name ("Atrexis the Grave Knight" holds
	The Grave Knight), the places the quests' givers are in, and the language's places named after a boss
	(MaskData); and apart (page), the language's names of others that are a quest's too (MASK_NAMES: the
	Defias Brotherhood, a faction, in Chinese), looked for on a boss's page alone. With an index of them by
	the heads of their words (WordHeads), so a quest's name found is checked against the places that share
	a word with it alone. Made once for each language, the first time a line holds a quest's name.
]]
-- The heads of a text's words (folded: its small letters), as a set: the first three letters of each word
-- of three letters or more, and each two characters side by side of Chinese and Korean.
local function WordHeads(text, folded)
	local heads = {}
	for word in folded:gmatch(LETTERS) do
		if Chars(word) >= 3 then heads[word:match(THREE)] = true end
	end
	local at = text:find("[\224-\239]")
	while at do
		local after = text:byte(at + 3)
		if after and after >= 224 and after <= 239 then heads[text:sub(at, at + 5)] = true end
		at = text:find("[\224-\239]", at + 3)
	end
	return heads
end
local placeData
local function PlaceData()
	local locale = Locale()
	if placeData and placeData.locale == locale then return placeData end
	local data, seen = { heads = {}, always = {}, locale = locale, page = { heads = {}, always = {} } }, {}
	local function Add(place, into)
		if type(place) ~= "string" or place == "" then return end
		local folded = Fold(place)
		if seen[folded] then return end
		seen[folded] = true
		local any = false
		for head in pairs(WordHeads(place, folded)) do
			any = true
			into.heads[head] = into.heads[head] or {}
			table.insert(into.heads[head], folded)
		end
		if not any then into.always[#into.always + 1] = folded end
	end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
			Add(instance.name, data)
			for _, boss in ipairs(instance.bosses or {}) do
				Add(boss.area, data)
				Add(boss.name, data)
			end
			for _, hidden in ipairs(HiddenOf(instance)) do
				Add(hidden.name, data)
				Add(hidden.full, data)
			end
		end
	end
	for place in pairs(QuestData().zones) do Add(place, data) end
	for _, place in ipairs(MaskData("MASK_PLACES")) do Add(place, data) end
	for _, name in ipairs(MaskData("MASK_NAMES")) do Add(name, data.page) end
	-- (the lists Placed looks in: on any page, and on a boss's page)
	data.lists, data.pageLists = { data }, { data, data.page }
	placeData = data
	return data
end
-- Whether the words from start to stop of a line (folded: its small letters) are inside a place's name
-- there, not the whole of it ("в Глубины Черной горы" holds the Russian Into the Depths): a place that
-- shares a word with them. On a boss's page and in a dungeon's description (page), the whole of it too
-- ("Found in The Forgotten Pool": a place there, whose name is a quest's in Spanish), and of the
-- language's names of others (PlaceData's page): those name no quest.
local function Placed(folded, start, stop, page)
	local data = PlaceData()
	local function Inside(place)
		local from, to = folded:find(place, 1, true)
		while from do
			if from <= stop and to >= start
				and (not (start <= from and stop >= to) or (page and start == from and stop == to)) then
				return true
			end
			from, to = folded:find(place, from + 1, true)
		end
		return false
	end
	local words = folded:sub(start, stop)
	local heads = WordHeads(words, words)
	for _, list in ipairs(page and data.pageLists or data.lists) do
		for head in pairs(heads) do
			for _, place in ipairs(list.heads[head] or EMPTY) do
				if Inside(place) then return true end
			end
		end
		for _, place in ipairs(list.always) do
			if Inside(place) then return true end
		end
	end
	return false
end

-- A quest's name as a phrase (Phrase above), for Russian, which declines it, made once for each name.
local questPhrases = {}
local function QuestPhrase(name)
	if questPhrases.locale ~= Locale() then questPhrases = { locale = Locale() } end
	local phrase = questPhrases[name]
	if phrase == nil then
		local words = {}
		for word in name:gmatch("%S+") do words[#words + 1] = word end
		phrase = Phrase(words, 1, #words, true, true)
		questPhrases[name] = phrase
	end
	return phrase
end

-- (the quotes a quest's name may be written in, in the languages of the Latin letters: « „ “ ‘, and " or
-- ' where no letter is before it)
local function Quoted(text, at)
	local before = CharBefore(text, at)
	if QUOTE_ENDS[before] then return true end
	if before == "\"" or before == "'" then return not Letter(CharBefore(text, at - 1)) end
	-- (French's « with a space after it: "« Le défi »")
	if before == " " or before == "\194\160" or before == "\226\128\175" then
		return CharBefore(text, at - #before) == "\194\171"
	end
	return false
end

--[[
	A quest's name (entry: QuestData's) put out as put says (for the name and the words found) in a line
	(folded: its small letters) of the Latin-letter languages but English, as English finds it: as it is
	written, its first letter too, where a word starts, its last word with a plural's or a case's ending
	("Skelettfragmenten", of "Skelettfragmente"), its article with it where it has one; and in quotes in any
	case, where any of that language's articles may stand before it in the quotes, put out with it ("„der
	Defiasbruderschaft“", "« au gambit de l'Aube »"). So an object a quest is named after ("das Herz des
	Berges", "der Steinkreis") stays as it is. placed: whether words found are inside a place's name.
]]
local function PutOutQuoted(text, folded, entry, locale, put, placed)
	local name = entry.name
	local named = Letter(CharBefore(name, #name + 1))
	local start, stop = text:find(name, 1, true)
	while start do
		local ending = named and WordEnd(text, stop + 1) or stop
		if not (Letter(CharBefore(text, start)) and Letter(name:match(FIRST)))
			and (ending == stop or Plural(text:sub(stop + 1, ending), locale, true)) and not placed(folded, start, ending) then
			local replace = put(name, text:sub(start, ending))
			text = text:sub(1, start - 1) .. replace .. text:sub(ending + 1)
			folded = Fold(text)
			start, stop = text:find(name, start + #replace, true)
		else
			start, stop = text:find(name, start + 1, true)
		end
	end
	local core = entry.core
	named = Letter(CharBefore(core, #core + 1))
	start, stop = folded:find(core, 1, true)
	while start do
		local ending = named and WordEnd(text, stop + 1) or stop
		local from
		if not Letter(CharBefore(text, start)) and (ending == stop or Plural(folded:sub(stop + 1, ending), locale, true)) then
			if Quoted(text, start) then
				from = start
			else
				-- (an article between the quote and the name: "l'" elided, or a word of its own)
				local before = CharBefore(text, start)
				if before == "'" or before == "\226\128\153" then
					local at = start - #before - 1
					if at >= 1 and folded:sub(at, at) == "l" and Quoted(text, at) then from = at end
				else
					local word, gap = folded:sub(math.max(1, start - 12), start - 1):match("(" .. LETTERS .. ")(%s+)$")
					local at = word and start - #gap - #word
					if word and STANDS_FOR[locale][word] and not Letter(CharBefore(text, at)) and Quoted(text, at) then
						from = at
					end
				end
			end
		end
		if from and not placed(folded, from, ending) then
			local replace = put(name, text:sub(from, ending))
			text = text:sub(1, from - 1) .. replace .. text:sub(ending + 1)
			folded = Fold(text)
			start, stop = folded:find(core, from + #replace, true)
		else
			start, stop = folded:find(core, start + 1, true)
		end
	end
	return text, folded
end

--[[
	A quest's name put out as put says in a Russian line (folded, its small letters): as written, in any
	case, where a word starts and ends (a declined name is found in quotes: Discovery:MaskQuests).
]]
local function PutOutExact(text, folded, entry, put, placed)
	local core = entry.folded
	local start, stop = folded:find(core, 1, true)
	while start do
		local ending = WordEnd(text, stop + 1)
		local named = Letter(CharBefore(core, #core + 1))
		if not Letter(CharBefore(text, start)) and (ending == stop or not named) and not placed(folded, start, stop) then
			local replace = put(entry.name, text:sub(start, stop))
			text = text:sub(1, start - 1) .. replace .. text:sub(stop + 1)
			folded = Fold(text)
			start, stop = folded:find(core, start + #replace, true)
		else
			start, stop = folded:find(core, start + 1, true)
		end
	end
	return text, folded
end

--[[
	A line of the journal's own words (Before you go's titles and notes, a quest's notes and who gives it)
	with the names of the journal's quests the character has not been offered put out as "???", as the
	Quests tab shows them: a chain's next steps are not told. Only a quest the character's side and class
	could be offered is put out: another's (the Alliance's Overmaster Pyron, for the Horde) stays as it is.
	A name is found as it is written, in a spaced script where a word starts and ends; in Korean with a
	particle after it, which stays; in the other Latin-letter languages as PutOutQuoted says; in Russian in
	any case, and declined in quotes, with each word's ending free ("«Войну буровых»", of "Война буровых").
	Never inside a place's name (Placed). A name is looked for only in a line that has its keys (QuestData's
	head and also, LineKeys), longest first. The names of the quests offered are put out as a mark each, kept in order in
	the list returned with the line (Discovery:MaskAll puts them back: nothing else is to put out of them).
]]
-- What the character may be offered and has been, worked out as lines ask, once for each find, language,
-- side and class: whether each name's quests were offered (known), whether each quest may be (offered),
-- and each line masked (done).
local quests = {}
local function QuestState(self, locale)
	local _, faction = pcall(UnitFactionGroup, "player")
	local _, _, class = pcall(UnitClass, "player")
	if not (quests.version == self:Version() and quests.locale == locale and quests.store == ns.charDB.discovered
		and quests.faction == faction and quests.class == class) then
		quests = { version = self:Version(), locale = locale, store = ns.charDB.discovered, faction = faction,
			class = class, done = {}, known = {}, offered = {} }
	end
	return quests
end
-- Whether the character has been offered one of a name's quests.
local function Offered(self, state, entry)
	local known = state.known[entry]
	if known == nil then
		known = false
		for _, questID in ipairs(entry.ids) do
			if self:Knows("quest", questID) then
				known = true
				break
			end
		end
		state.known[entry] = known
	end
	return known
end
-- Whether the character could be offered a quest: its side's and class's (QuestData's offer, else the
-- step the journal keeps for it).
local function Offerable(state, data, questID)
	local answer = state.offered[questID]
	if answer == nil then
		local info = data.offer[questID] or (ns.GetQuestStep and ns.GetQuestStep(questID)) or {}
		local faction = info.faction
		answer = (not faction or faction == "Both" or not state.faction or faction == state.faction)
			and ns.ForClass(info.classOnly, state.class)
		state.offered[questID] = answer
	end
	return answer
end
local function AnyOfferable(state, data, ids)
	for _, questID in ipairs(ids) do
		if Offerable(state, data, questID) then return true end
	end
	return false
end
local function Longest(a, b)
	if #a.name ~= #b.name then return #a.name > #b.name end
	return a.order < b.order
end
local function MaskQuests(self, text, named, page)
	local locale = Locale()
	local state = QuestState(self, locale)
	-- (a line masked already, as a page draws its lines on every click: as it was)
	local original = named and (text .. "\0" .. table.concat(named, ",")) or text
	if page then original = original .. "\0page" end
	local was = state.done[original]
	if was then return was[1], was[2] end
	local data = QuestData()
	local kept, known, held = {}, {}, {}
	-- (a name found: "???", or a mark for the words found, for a quest offered; and for a quest the character
	-- can't be offered, a mark of its own, put back below, before the bosses are put out: no shorter quest's
	-- name is looked for in it, "Corruption" in Researching the Corruption)
	local function Put(name, found)
		local what = known[name]
		if what == "held" then
			held[#held + 1] = found
			return "\5" .. ("\6"):rep(#held) .. "\5"
		end
		if not what then return UNKNOWN end
		return Mark(kept, found)
	end
	local folded = Fold(text)
	local keys = LineKeys(text, folded)
	local function InPlace(now, start, stop) return Placed(now, start, stop, page) end
	-- The names to look for, in order: those of the quests named, not offered (quests named after someone,
	-- which Kept leaves out), then the names the line may hold, longest first.
	local list = {}
	if named then
		for _, questID in ipairs(named) do
			if not self:Knows("quest", questID) and Offerable(state, data, questID) then
				for _, name in ipairs(data.byID[questID] or EMPTY) do list[#list + 1] = QuestFolded({ name = name, order = 0 }) end
			end
		end
	end
	local found, seen = {}, {}
	local function Take(entry)
		if seen[entry] then return end
		seen[entry] = true
		if Kept(data, entry) then
			local offered = Offered(self, state, entry)
			found[#found + 1] = QuestFolded(entry)
			known[entry.name] = offered or (not AnyOfferable(state, data, entry.ids) and "held") or nil
		end
	end
	for head in pairs(keys) do
		for _, entry in ipairs(data.heads[head] or EMPTY) do
			if not entry.also or keys[entry.also] then Take(entry) end
		end
	end
	for _, entry in ipairs(data.always) do Take(entry) end
	table.sort(found, Longest)
	for _, entry in ipairs(found) do list[#list + 1] = entry end
	if not list[1] then
		state.done[original] = { text, kept }
		return text, kept
	end
	if locale == "ruRU" then
		for _, entry in ipairs(list) do
			if folded:find(entry.folded, 1, true) then text, folded = PutOutExact(text, folded, entry, Put, InPlace) end
		end
		-- (a name declined in quotes: its first word's first three letters just after a quote)
		local quoted
		for _, quote in ipairs({ "\194\171", "\226\128\158", "\226\128\156" }) do
			local at = folded:find(quote, 1, true)
			while at do
				local word = folded:match("^" .. LETTERS, at + #quote)
				if word then
					quoted = quoted or {}
					quoted[word:match(THREE)] = true
				end
				at = folded:find(quote, at + #quote, true)
			end
		end
		if quoted then
			for _, entry in ipairs(found) do
				local first = entry.folded:match(LETTERS)
				if not first or quoted[first:match(THREE)] then
					text, folded = PutOutPhrase(text, folded, QuestPhrase(entry.name), Put, entry.name, true)
				end
			end
		end
	elseif ARTICLES_OF[locale] then
		for _, entry in ipairs(list) do
			if folded:find(entry.core, 1, true) then text, folded = PutOutQuoted(text, folded, entry, locale, Put, InPlace) end
		end
	else
		local spaced, particles = Spaced(), locale == "koKR"
		for _, entry in ipairs(list) do
			local name = entry.name
			local start, stop = text:find(name, 1, true)
			local quoted
			while start do
				-- (Chinese: a name of three characters or fewer only in its quotes, as the notes write a quest's,
				-- or first, as a title starts with it: "挑战", The Challenge, is in "向他挑战" too)
				if quoted == nil then quoted = not spaced and Chars(name) <= 3 end
				local ending = WordEnd(text, stop + 1)
				if (quoted and start > 1 and not CHINESE_QUOTES[CharBefore(text, start)])
					or (spaced and ((Letter(CharBefore(text, start)) and Letter(name:match(FIRST)))
					or (ending > stop and Letter(CharBefore(name, #name + 1))
						and not (particles and Particle(text:sub(stop + 1, ending))))))
					or InPlace(folded, start, stop) then
					start, stop = text:find(name, stop + 1, true)
				else
					local replace = Put(name, name)
					text = text:sub(1, start - 1) .. replace .. text:sub(stop + 1)
					folded = Fold(text)
					start, stop = text:find(name, start + #replace, true)
				end
			end
		end
	end
	if held[1] then text = text:gsub("\5(\6+)\5", function(marks) return held[#marks] end) end
	state.done[original] = { text, kept }
	return text, kept
end

--[[
	A line of the journal's own words about a dungeon (Before you go's titles and notes, a quest's notes
	and who gives and takes it, a boss's notes and abilities, the dungeon's description) with nothing put
	out the character has not found: the quests not offered first (MaskQuests), whole, then the rest
	(Discovery:Mask, with extra). A quest's name the character has been offered stays as the Quests tab
	shows it, whatever it holds: its name is the game's. Outside Adventure Mode, the line as it is. named:
	the ids of quests the line names as quests that are named after someone (MaskQuests leaves those out:
	"then Hamuul Runetotem and Nara Wildmane", of the Barrens oasis chain), put out as quests too.
]]
function Discovery:MaskAll(instance, text, extra, named, page)
	if type(text) ~= "string" or text == "" or not ns.Style:Adventure() then return text end
	local kept
	text, kept = MaskQuests(self, text, named, page)
	if type(instance) == "table" then text = self:Mask(instance, text, extra) end
	if kept[1] then text = text:gsub("\3(\4+)\3", function(marks) return kept[#marks] end) end
	return text
end

-- The same with no dungeon: only the quests not offered put out.
function Discovery:MaskQuests(text)
	return self:MaskAll(nil, text)
end

--[[
	The same for a boss's page (its notes, place, description and abilities) and a dungeon's description,
	which name a quest seldom and a faction, a group or a place often: a quest's name that is the whole of
	a place's there, or one of the language's names of others (MASK_NAMES), is that, not the quest (Placed).
]]
function Discovery:MaskPage(instance, text, extra)
	return self:MaskAll(instance, text, extra, nil, true)
end

--[[
	The language's lists the masking reads (its common words, every boss's keys, the quests' names and
	their givers, the places, Chinese's names alone), made ahead in Adventure Mode, one a frame, a moment
	after logging in or as the style is chosen: so the first page opened makes only its own forms, not
	these too. Each is made once for each language whenever it is first wanted anyway.
]]
function Discovery:Prepare()
	local locale = Locale()
	if not ns.Style:Adventure() or self.prepared == locale then return end
	self.prepared = locale
	local steps = {
		function()
			DungeonNames()
			GroupWords()
			ShortForms()
		end,
		Common,
		BossIndex,
		QuestData,
		function()
			QuestNames()
			QuestPeople(QuestData())
			QuestSkip()
		end,
		PlaceData,
		function()
			if not Spaced() then BareBase() end
		end,
	}
	local index = 0
	local Next
	local function Later()
		if C_Timer and C_Timer.After then C_Timer.After(0, Next) else Next() end
	end
	Next = function()
		index = index + 1
		-- (stopped with the style: started again once it is chosen again)
		if not ns.Style:Adventure() or Locale() ~= locale then
			self.prepared = nil
			return
		end
		if not steps[index] then return end
		local ok, problem = pcall(steps[index])
		if not ok then
			geterrorhandler()(problem)
			return
		end
		Later()
	end
	Later()
end

-- (the dungeons that have a hidden boss: Jarien and Sothos are in both of Stratholme's, and met in one,
-- they are known in both)
local Wings
do
	local wings
	function Wings(key)
		if not wings then
			wings = {}
			for _, kind in ipairs({ "dungeon", "raid" }) do
				for _, instance in ipairs(ns.GetInstances and ns.GetInstances(kind) or {}) do
					for _, hidden in ipairs(HiddenOf(instance)) do
						wings[hidden.key] = wings[hidden.key] or {}
						table.insert(wings[hidden.key], instance)
					end
				end
			end
		end
		return wings[key] or EMPTY
	end
end

--[[
	Whether a hidden boss with no page (HiddenOf) is still unknown to the character: not met by its name
	(Discovery:Boss, under its English name), and none of the quests that call it up offered (its entries'
	summons). Nothing else tells it: a quest's name that shares a word with its own says nothing of it.
]]
local function StillHidden(self, instance, hidden)
	if self:Knows("boss", instance, hidden.key) then return false end
	for _, wing in ipairs(Wings(hidden.key)) do
		if self:Knows("boss", wing, hidden.key) then return false end
	end
	for _, questID in ipairs(hidden.summons) do
		if self:Knows("quest", questID) then return false end
	end
	return true
end

-- Every dungeon's and raid's unmet bosses, { instance, name } each, hidden ones too: made once for each
-- find and language.
local unmet = {}
local function UnmetAll(self, locale)
	if unmet.version == self:Version() and unmet.locale == locale and unmet.store == ns.charDB.discovered then
		return unmet
	end
	unmet = { version = self:Version(), locale = locale, store = ns.charDB.discovered }
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, other in ipairs(ns.GetInstances(kind)) do
			for _, boss in ipairs(other.bosses or {}) do
				local name = boss.name
				if type(name) == "string" and name ~= "" and self:Unmet(other, boss) then
					unmet[#unmet + 1] = { instance = other, name = name }
				end
			end
			for _, hidden in ipairs(HiddenOf(other)) do
				if StillHidden(self, other, hidden) then
					if hidden.full then unmet[#unmet + 1] = { instance = other, name = hidden.full } end
					unmet[#unmet + 1] = { instance = other, name = hidden.name }
				end
			end
		end
	end
	return unmet
end

--[[
	The names of what the character has not found of a boss and its dungeon, for Discovery:Mask: until
	the boss is fought, its abilities' and adds' names (not the headings written for what it does, such
	as "Curses and diseases"); the names of the dungeon's items not seen to drop there yet; in hidden, its
	hidden bosses with no page still unknown (StillHidden above); and in bosses, the unmet bosses of every
	other dungeon and raid, hidden ones too, with the key of each one's dungeon in homes, as a note may
	name one (Lyn the Ignored's names Archmage Arugal, of Shadowfang Keep). Made once for each find and
	language, and again once the client gives an item's name: a page asks on every click, and the lines
	it masks with the same names are masked once (Discovery:Mask). Nil outside Adventure Mode.
]]
local unseen = setmetatable({}, { __mode = "k" })
-- (whether the client gives the items' names it gave when they were made: probe, an item's id and its
-- name then, or false, in turn)
local function ItemsAsMade(probe)
	for index = 1, #probe, 2 do
		local info = ns.Items and ns.Items:Peek(probe[index])
		if ((info and info.name) or false) ~= probe[index + 1] then return false end
	end
	return true
end
-- (what is the same for every boss of a dungeon: its items not seen, its hidden bosses not told and the
-- other dungeons' unmet bosses, made once for each find, language and item names given; byBoss.shared)
local function UnseenShared(self, instance, byBoss, locale)
	local shared = byBoss.shared
	if shared and shared.version == self:Version() and shared.locale == locale and shared.store == ns.charDB.discovered
		and ItemsAsMade(shared.probe) then
		return shared
	end
	local items, probe = {}, {}
	for _, other in ipairs(instance.bosses or {}) do
		for _, row in ipairs(other.loot or {}) do
			if row.itemID and not self:Knows("item", row.itemID, instance) then
				local info = ns.Items and ns.Items:Peek(row.itemID)
				items[#items + 1] = info and info.name or row.name
				if row.name and info and info.name ~= row.name then items[#items + 1] = row.name end
				probe[#probe + 1] = row.itemID
				probe[#probe + 1] = (info and info.name) or false
			end
		end
	end
	local hidden
	for _, entry in ipairs(HiddenOf(instance)) do
		if StillHidden(self, instance, entry) then
			hidden = hidden or {}
			if entry.full then hidden[#hidden + 1] = entry.full end
			hidden[#hidden + 1] = entry.name
		end
	end
	local bosses, homes = {}, {}
	for _, entry in ipairs(UnmetAll(self, locale)) do
		if entry.instance ~= instance then
			bosses[#bosses + 1] = entry.name
			homes[entry.name] = homes[entry.name] or entry.instance.key
		end
	end
	shared = { version = self:Version(), locale = locale, store = ns.charDB.discovered, probe = probe, items = items,
		hidden = hidden, bosses = bosses, homes = homes }
	byBoss.shared = shared
	return shared
end
function Discovery:Unseen(instance, boss)
	if not ns.Style:Adventure() or type(instance) ~= "table" or instance.kind == "faction" then return nil end
	local locale = Locale()
	local byBoss = unseen[instance]
	if not byBoss then
		byBoss = {}
		unseen[instance] = byBoss
	end
	local key = type(boss) == "table" and boss or false
	local made = byBoss[key]
	if made and made.version == self:Version() and made.locale == locale and made.store == ns.charDB.discovered
		and ItemsAsMade(made.probe) then
		return made.names
	end
	local names = {}
	if type(boss) == "table" and not self:Fought(instance, boss) then
		local function Spell(row)
			local name = row.name
			if C_Spell and C_Spell.GetSpellInfo and row.spellID then
				local ok, info = pcall(C_Spell.GetSpellInfo, row.spellID)
				if ok and info and info.name then name = info.name end
			end
			if name then names[#names + 1] = name end
			if row.name and row.name ~= name then names[#names + 1] = row.name end
		end
		for _, row in ipairs(boss.abilities or {}) do Spell(row) end
		for _, add in ipairs(boss.adds or {}) do
			names[#names + 1] = add.name
			for _, row in ipairs(add.abilities or {}) do Spell(row) end
		end
	end
	local shared = UnseenShared(self, instance, byBoss, locale)
	for _, name in ipairs(shared.items) do names[#names + 1] = name end
	names.hidden, names.bosses, names.homes = shared.hidden, shared.bosses, shared.homes
	byBoss[key] = { version = self:Version(), locale = locale, store = ns.charDB.discovered, probe = shared.probe,
		names = names }
	return names
end

--[[
	The names a dungeon's overview must not say yet, for Discovery:Mask: Unseen's for the dungeon (its items
	not seen, its hidden bosses not told, and every other dungeon's unmet bosses: Onyxia's Lair's attunement
	names General Drakkisath, of Upper Blackrock Spire). Nil outside Adventure Mode.
]]
function Discovery:Untold(instance)
	return self:Unseen(instance)
end

--[[
	Whether the character knows a faction (its entry or its id): it has been on the character's Reputation
	tab (ReadFactions below), and stays known. Not whether the client gives a standing with it
	(Core/Reputation.lua's Player): Forever gives one, Neutral 0, for a faction never met. Always, outside
	Adventure Mode.
]]
function Discovery:FactionKnown(faction)
	if not ns.Style:Adventure() then return true end
	if type(faction) ~= "table" and type(faction) ~= "number" then return false end
	return self:Knows("faction", faction)
end

-- Whether some of a faction's rewards are still to be seen at its quartermaster (Adventure Mode only).
function Discovery:RewardsHidden(faction)
	if not ns.Style:Adventure() or type(faction) ~= "table" then return false end
	for _, standing in ipairs(faction.bosses or {}) do
		for _, row in ipairs(standing.loot or {}) do
			if not self:Knows("reward", faction, row.itemID) then return true end
		end
	end
	return false
end

-- The record itself, for the tests and for /aegis checks: nil before the saved data is there.
function Discovery:Record()
	return Store()
end

--[[
	Each thing new to the journal, told as it is found, in every style, for Adventure Mode's line in the chat
	and the minimap button's glow (UI/News.lua): fn(kind, ...), with
	  "instance", key                  a dungeon (a wing) entered
	  "boss", key, bossKey             a boss first met (or first fought or killed, where no meeting was heard)
	  "item", itemID, key, bossKey     an item first seen to drop in a dungeon (wing), off that boss where known
	  "quest", questID                 one of the journal's quests first offered (or taken or done, unoffered)
	  "reward", factionID, itemID      a faction's reward first seen at its quartermaster
	  "faction", factionID             a faction first on the Reputation tab
	  "flight", nodeID, name           a flight path the client itself says is new ("New flight path
	                                   discovered!": NewFlightPath), even where a flight master's map read it
	                                   a moment before
	Never what the character's past brings: nothing is told until it has been read at login (ReadPast:
	the quests done before, the flight paths known, the factions met, and the finds of those first moments,
	ready), nor while it is read again; nor the flight paths read off a flight master's map or the client's
	list, which hold the character's past too, nor the factions a shut heading of the Reputation tab shows
	once opened (ReadFactions: found.shut, the headings shut at its last read). A boss fought or killed
	again, an item seen off its boss where it was seen in the dungeon before, a quest taken or done after
	its offer: nothing new. Ways in walked are the world map's, not the journal's pages: not told. One
	table: this file is near Lua's limit of top-level locals.
]]
Discovery.found = { listeners = {}, ready = false }

function Discovery:OnFind(fn)
	local listeners = self.found.listeners
	listeners[#listeners + 1] = fn
end

-- Tells the listeners of a find (each pcalled, as Tell does), once the character's past has been read.
function Discovery:Found(kind, ...)
	if not self.found.ready then return end
	for _, fn in ipairs(self.found.listeners) do
		local ok, problem = pcall(fn, kind, ...)
		if not ok then geterrorhandler()(problem) end
	end
end

------------------------------------------------------------------------------------------
-- Finds
------------------------------------------------------------------------------------------

-- A dungeon (a wing) entered. True when it is new.
function Discovery:Entered(instance)
	local store, key = Store(), InstanceKey(instance)
	if not (store and type(key) == "string") or store.instances[key] then return false end
	store.instances[key] = true
	Changed()
	self:Found("instance", key)
	return true
end

-- A boss met, fought or killed (level), in its own dungeon (wing). The dungeon's trash and recipes are no boss.
function Discovery:Boss(instance, boss, level)
	local store, key, rank = Store(), InstanceKey(instance), BOSS_LEVELS[level]
	local bossKey = BossKey(boss)
	if not (store and type(key) == "string" and bossKey and rank) or ns.IsLootSection(boss) then
		return false
	end
	local bosses = store.bosses[key]
	if type(bosses) ~= "table" then bosses = nil end
	local was = bosses and bosses[bossKey]
	if type(was) == "number" and was >= rank then return false end
	if not bosses then
		bosses = {}
		store.bosses[key] = bosses
	end
	bosses[bossKey] = rank
	-- Its wing has been entered, whatever the area's name said (told as Entered tells it, before the boss).
	local newWing = not store.instances[key]
	store.instances[key] = true
	Changed()
	if newWing then self:Found("instance", key) end
	if type(was) ~= "number" then self:Found("boss", key, bossKey) end
	-- A first kill: the fog's listeners told at once, in any style (each pcalled, as Tell does).
	if rank >= BOSS_LEVELS.killed then
		kills.count = kills.count + 1
		for _, fn in ipairs(kills.listeners) do
			local ok, problem = pcall(fn, key, bossKey)
			if not ok then geterrorhandler()(problem) end
		end
	end
	return true
end

-- An item seen to drop in a dungeon, off a boss when known.
function Discovery:SawItem(itemID, instance, boss)
	local store, key = Store(), InstanceKey(instance)
	if not (store and type(itemID) == "number" and type(key) == "string") then return false end
	local bossKey = boss and BossKey(boss)
	local seen = store.items[itemID]
	if type(seen) ~= "table" then seen = nil end
	local at = seen and seen[key]
	if type(at) ~= "table" then at = nil end
	if at and (not bossKey or at[bossKey]) then return false end
	-- (new to this dungeon's pages: told; one seen here before, now off its boss, is not)
	local fresh = at == nil
	if not seen then
		seen = {}
		store.items[itemID] = seen
	end
	if not at then
		at = {}
		seen[key] = at
	end
	if bossKey then at[bossKey] = true end
	Changed()
	if fresh then self:Found("item", itemID, key, bossKey) end
	return true
end

-- The journal's quest ids (ns.JournalQuestIDs), made once for each version of the data.
local journalQuests, journalQuestsFor
local function JournalQuests()
	local dataVersion = ns.DataVersion and ns.DataVersion() or 0
	if not journalQuests or journalQuestsFor ~= dataVersion then
		journalQuests, journalQuestsFor = ns.JournalQuestIDs(), dataVersion
	end
	return journalQuests
end

-- One of the journal's quests offered, taken or done (level). Any other quest is not kept: the record
-- would grow with every quest of the character's levelling, and nothing the journal shows asks of it.
function Discovery:Quest(questID, level)
	local store, rank = Store(), QUEST_LEVELS[level]
	questID = ns.Readable(questID)
	if not (store and type(questID) == "number" and rank and JournalQuests()[questID]) then return false end
	local was = store.quests[questID]
	if type(was) == "number" and was >= rank then return false end
	store.quests[questID] = rank
	if type(was) ~= "number" then self.finds.quest = self.finds.quest + 1 end
	Changed()
	if type(was) ~= "number" then self:Found("quest", questID) end
	return true
end

-- A flight path known, by the client's node id. One Forever has no flight master for is never kept.
function Discovery:LearnedFlight(nodeID)
	local store = Store()
	nodeID = ns.Readable(nodeID)
	if not (store and type(nodeID) == "number") or store.flights[nodeID] or not ns.ForeverTaxiNode(nodeID) then
		return false
	end
	store.flights[nodeID] = true
	self.finds.flight = self.finds.flight + 1
	Changed()
	return true
end

-- A faction's reward seen at its quartermaster (the faction given as its entry or its id).
function Discovery:SawReward(faction, itemID)
	local store = Store()
	local factionID = type(faction) == "table" and faction.factionID or faction
	if not (store and type(factionID) == "number" and type(itemID) == "number") then return false end
	local seen = store.rewards[factionID]
	if type(seen) ~= "table" then
		seen = {}
		store.rewards[factionID] = seen
	end
	if seen[itemID] then return false end
	seen[itemID] = true
	Changed()
	self:Found("reward", factionID, itemID)
	return true
end

-- A way in walked (UI/DungeonMap.lua's PlayerSubMap, every few moments there: known ones cost a lookup).
function Discovery:WalkedSubMap(subMap)
	local key = type(subMap) == "table" and subMap.key or subMap
	local db = ns.charDB
	local store = db and db.discovered
	if type(key) ~= "string" or (store and store.subMaps and store.subMaps[key]) then return false end
	store = Store()
	if not store then return false end
	store.subMaps[key] = true
	Changed()
	return true
end

------------------------------------------------------------------------------------------
-- Where the player is
------------------------------------------------------------------------------------------

--[[
	The dungeon the player is in, while it is one the journal has: its client id, the wings that id
	stands for, the wing guessed (instance), and its bosses by creature id and by every name the
	client may give them (the journal's, the English, the client's own, the others in aliases), with
	the wing each is in; and the hidden bosses its Before you go names with no page (HiddenOf), by their
	names (the journal's and the English; each of two that come together, "Jarien and Sothos"). Nil
	outside.
]]
local here
local sight = CreateFrame("Frame")
local SIGHT_EVENTS = { "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "PLAYER_FOCUS_CHANGED", "UNIT_FLAGS",
	"PLAYER_REGEN_DISABLED" }

local function Lookup(wings)
	local byNpc, byName, byAlias, wingOf, hidden = {}, {}, {}, {}, {}
	for _, wing in ipairs(wings) do
		for _, entry in ipairs(HiddenOf(wing)) do
			local found = { wing = wing, key = entry.key }
			for _, name in ipairs({ entry.key, entry.name, entry.key:match("^(.-) and "), entry.key:match(" and (.+)$") }) do
				hidden[name] = hidden[name] or found
			end
		end
		for _, boss in ipairs(wing.bosses) do
			if not ns.IsLootSection(boss) then
				wingOf[boss] = wing
				if boss.npcID then byNpc[boss.npcID] = byNpc[boss.npcID] or boss end
				for _, name in ipairs({ boss.name, boss.enName, boss.clientName }) do
					if name then byName[name] = byName[name] or boss end
				end
				for _, alias in ipairs(boss.aliases or {}) do byAlias[alias] = byAlias[alias] or boss end
			end
		end
	end
	return byNpc, byName, byAlias, wingOf, hidden
end

--[[
	The dungeon the player is inside that the journal has no client instance id for yet (Forever's new
	dungeons, Data/Authored/Upcoming.lua, until a recorded run gives theirs): by the name the client gives
	it (its journal name, English or client name). Keyed by that name in place of an id; nil elsewhere.
]]
function Discovery.UnindexedHere()
	local ok, name, kind, _, _, _, _, _, instanceID = pcall(GetInstanceInfo)
	if not ok or type(name) ~= "string" or name == "" or (kind ~= "party" and kind ~= "raid") then return nil end
	if ns.Readable(instanceID) and ns.GetInstancesByInstanceID(ns.Readable(instanceID))[1] then return nil end
	for _, list in ipairs({ ns.GetInstances("dungeon"), ns.GetInstances("raid") }) do
		for _, instance in ipairs(list) do
			if not instance.instanceID and not instance.comingSoon and ns.NamedAs(instance, name) then
				return instance, "name:" .. name
			end
		end
	end
	return nil
end

-- Where the player is now: a new dungeon found, a wing named by its area. Bosses are watched for
-- only inside a dungeon the journal has.
local function Arrive()
	-- Only a look: the wing guessed where nothing names one stays the map's and the Recorder's.
	local instance, placed, instanceID = ns.CurrentInstance(true)
	local wings
	if not instance then
		instance, instanceID = Discovery.UnindexedHere()
		placed, wings = instance ~= nil, instance and { instance }
	end
	if not instance then
		if here then
			here = nil
			ns.UnregisterEvents(sight, unpack(SIGHT_EVENTS))
		end
		return
	end
	if not here or here.instanceID ~= instanceID then
		wings = wings or ns.GetInstancesByInstanceID(instanceID)
		here = { instanceID = instanceID, wings = wings }
		here.byNpc, here.byName, here.byAlias, here.wingOf, here.hidden = Lookup(wings)
		if next(here.byName) or next(here.hidden) then ns.RegisterEvents(sight, unpack(SIGHT_EVENTS)) end
	end
	here.instance, here.placed = instance, placed
	if placed then Discovery:Entered(instance) end
end

-- The bosses of this dungeon a fight is for (Core/Registry.lua's ns.BossesForFight: two where they
-- share one, The Deadmines' Sneed's Shredder and Sneed), in the first of its wings that has any, with
-- the wing. Empty where none; the dungeon's trash and recipes are none.
local function EncounterBosses(encounterID, name)
	for _, wing in ipairs(here and here.wings or {}) do
		local bosses = {}
		for _, boss in ipairs(ns.BossesForFight(wing, encounterID, name)) do
			if not ns.IsLootSection(boss) then bosses[#bosses + 1] = boss end
		end
		if #bosses > 0 then return bosses, wing end
	end
	return {}
end

--[[
	The boss of this dungeon a unit at hand is: by its creature id where the client gives it; by its
	name where the id is kept back, or for a boss the journal has no creature id for. A creature of a
	boss's own name the client gives another id is not it; one of its other names (aliases) is, as an
	entry may stand for two creatures (Shadowfang Keep's Fel Steed and Shadow Charger), and that id is
	then kept for this visit, so its corpse's loot window names it too. So is the id of a boss the
	journal has no creature id for, once met by its name. A player, or anything a player controls (a pet
	named like a boss), is no boss.
]]
local function BossAt(unit)
	if not here or Call(UnitIsPlayer, unit) == true or Call(UnitPlayerControlled, unit) == true then return nil end
	local guid = Call(UnitGUID, unit)
	local npcID = ns.NpcIDFromGUID(guid)
	if type(guid) == "string" and not npcID then return nil end
	local boss = npcID and here.byNpc[npcID]
	if boss then return boss end
	local name = Call(UnitName, unit)
	if type(name) ~= "string" then return nil end
	boss = here.byName[name]
	if boss then
		if npcID and boss.npcID and boss.npcID ~= npcID then return nil end
		if npcID and not boss.npcID then here.byNpc[npcID] = here.byNpc[npcID] or boss end
		return boss
	end
	boss = here.byAlias[name]
	if boss and npcID then here.byNpc[npcID] = boss end
	return boss
end

-- Whether a unit is in a fight: its own flag where the client says, else the player's.
local function Fighting(unit)
	local fighting = Call(UnitAffectingCombat, unit)
	if fighting == nil then fighting = Call(UnitAffectingCombat, "player") end
	if fighting == nil then return InCombatLockdown() == true end
	return fighting == true or fighting == 1
end

-- A boss at hand alive in a fight, or lying dead: met. Its corpse is not counted a kill here: only the dungeon
-- map's watch counts one, for a boss with no fight or whose fight never ends (UI/DungeonMap.lua's Fallen). A hidden boss
-- with no page is known by its name alone, and kept under its English name.
local function Sighted(unit)
	local boss = BossAt(unit)
	local met = Call(UnitIsDead, unit) == true or Fighting(unit)
	if boss then
		if met then Discovery:Boss(here.wingOf[boss], boss, "met") end
		return
	end
	local name = Call(UnitName, unit)
	local hidden = type(name) == "string" and here.hidden[name]
	if hidden and met and Call(UnitIsPlayer, unit) ~= true and Call(UnitPlayerControlled, unit) ~= true then
		Discovery:Boss(hidden.wing, hidden.key, "met")
	end
end

local LOOKED_AT = { target = true, focus = true, mouseover = true }

sight:SetScript("OnEvent", function(_, event, unit)
	if not here then return end
	if event == "PLAYER_TARGET_CHANGED" then
		Sighted("target")
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		Sighted("mouseover")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		Sighted("focus")
	elseif event == "PLAYER_REGEN_DISABLED" then
		for looked in pairs(LOOKED_AT) do Sighted(looked) end
	elseif LOOKED_AT[unit] then
		Sighted(unit)
	end
end)

------------------------------------------------------------------------------------------
-- Loot
------------------------------------------------------------------------------------------

-- Whether the journal has a boss drop an item.
local function Drops(boss, itemID)
	for _, dropper in ns.ItemDrops(itemID) do
		if dropper == boss then return true end
	end
	return false
end

--[[
	Where in this dungeon (any wing) the journal has an item drop: the one boss that drops it, with its
	wing; else, where several do, the one wing they are all in; nil where none do, or in several wings.
	A dungeon's Recipes row lists a boss's own recipe again, so it counts only where no other row here
	has the item: a boss's recipe seen with no source (a roll, a chat line) is still the boss's.
]]
local function DroppedHere(itemID)
	local wings, found, foundIn, several = {}, nil, nil, false
	local recipes, recipesIn
	for _, wing in ipairs(here.wings) do wings[wing] = true end
	for _, boss, instance in ns.ItemDrops(itemID) do
		if wings[instance] then
			if boss.recipes then
				if not recipes then recipes, recipesIn = boss, instance end
			elseif not found then
				found, foundIn = boss, instance
			elseif boss ~= found then
				if instance ~= foundIn then return nil, nil end
				several = true
			end
		end
	end
	if not found then return recipes, recipesIn end
	if several then return nil, foundIn end
	return found, foundIn
end

--[[
	An item seen in this dungeon: off the boss when known and the journal has him drop it, else the one
	boss that drops it here, else the one wing all its droppers here are in, else the dungeon where the
	place itself names the wing (a wing only guessed is not taken: the item would be said to drop where
	the journal has it nowhere). Only an item the journal lists somewhere. (A boss whose list lacks it is
	no source: the find kept under him would be on no page of his, and the chat line and the minimap
	button's glow, which ask for its row there (UI/News.lua), would never come. So the Drowned City's
	Linken's Boots of Iron, off Zul'Alai's corpse, goes to the Trash page's row that lists it.)
]]
local function SeeItem(itemID, boss)
	if not (here and type(itemID) == "number" and ns.HasDrops(itemID)) then return end
	if boss and Drops(boss, itemID) then
		Discovery:SawItem(itemID, here.wingOf[boss] or here.instance, boss)
		return
	end
	local only, wing = DroppedHere(itemID)
	if only then
		Discovery:SawItem(itemID, wing, only)
	elseif wing then
		Discovery:SawItem(itemID, wing)
	elseif here.placed then
		Discovery:SawItem(itemID, here.instance)
	end
end

local AT_HAND = { "target", "focus", "mouseover" }

-- The boss a loot slot's creature is: by its id, or by the corpse at hand of that id, for a boss the
-- journal has no creature id for (BossAt then keeps the id for this visit).
local function SourceBoss(npcID)
	local boss = here.byNpc[npcID]
	if boss then return boss end
	for _, unit in ipairs(AT_HAND) do
		if ns.NpcIDFromGUID(Call(UnitGUID, unit)) == npcID and Call(UnitIsDead, unit) == true then return BossAt(unit) end
	end
	return nil
end

--[[
	The loot window: each slot's creatures (Core/Recorder.lua's ns.LootSlotSources). A boss among
	them gives what it holds, and was killed where that is something the journal has it drop: only
	the group that killed it may take its own loot, while its skin, ore or herbs anyone may, from a
	corpse another group left. A boss still standing at hand (its pockets picked) gives nothing and is
	no kill. Where the client keeps every source back (enemy guids inside dungeons), the corpse at hand
	stands in: the one under the mouse, else the target where no corpse is under the mouse, when it is
	a boss of this dungeon and the window holds something the journal has it drop.
]]
local function LootOpened()
	if not here then return end
	local standing = {}
	for _, unit in ipairs(AT_HAND) do
		local npcID = ns.NpcIDFromGUID(Call(UnitGUID, unit))
		if npcID and type(UnitIsDead) == "function" and Call(UnitIsDead, unit) ~= true then standing[npcID] = true end
	end
	local slots, killed, named = {}, {}, false
	for slot = 1, Call(GetNumLootItems) or 0 do
		local itemID = ns.ItemIDFromLink(Call(GetLootSlotLink, slot))
		local source
		for _, npcID in ipairs(ns.LootSlotSources(slot)) do
			if npcID then
				named = true
				local boss = SourceBoss(npcID)
				if boss and not standing[npcID] then
					source = source or boss
					if itemID and Drops(boss, itemID) then killed[boss] = true end
				end
			end
		end
		if itemID then slots[#slots + 1] = { itemID = itemID, boss = source } end
	end
	if not named then
		for _, unit in ipairs({ "mouseover", "target" }) do
			if Call(UnitIsDead, unit) == true then
				-- The first corpse at hand is the one looted, a boss or not.
				local boss = BossAt(unit)
				for _, slot in ipairs(boss and slots or {}) do
					if Drops(boss, slot.itemID) then
						slot.boss = boss
						killed[boss] = true
					end
				end
				break
			end
		end
	end
	for boss in pairs(killed) do Discovery:Boss(here.wingOf[boss], boss, "killed") end
	for _, slot in ipairs(slots) do SeeItem(slot.itemID, slot.boss) end
end

-- A group roll: the item rolled for (from the roll's start, or from the roll frame being set up).
local function Rolled(rollID)
	rollID = ns.Readable(rollID)
	if not here or rollID == nil then return end
	SeeItem(ns.ItemIDFromLink(Call(GetLootRollItemLink, rollID)))
end

-- A drop in the loot history, off the boss its fight is named for where that is one of this dungeon's.
local function HistoryDrop(encounterID, lootListID)
	if not here then return end
	local itemID = ns.LootHistoryItem(encounterID, lootListID)
	if not itemID then return end
	encounterID = ns.Readable(encounterID)
	-- Off a fight two bosses share, the item is not said to be either's: the one that drops it here.
	local bosses = EncounterBosses(encounterID, ns.LootHistoryBossName(encounterID))
	SeeItem(itemID, #bosses == 1 and bosses[1] or nil)
end

------------------------------------------------------------------------------------------
-- Flight paths
------------------------------------------------------------------------------------------

-- The continents to ask: Kalimdor, the Eastern Kingdoms, and the one the player is on.
local function FlightMaps()
	local maps, seen = {}, {}
	local function Add(mapID)
		if type(mapID) == "number" and not seen[mapID] then
			seen[mapID] = true
			maps[#maps + 1] = mapID
		end
	end
	for _, mapID in ipairs(FLIGHT_MAPS) do Add(mapID) end
	local mapID = ns.PlayerMapPosition()
	for _ = 1, 10 do
		local info = type(mapID) == "number" and C_Map and Call(C_Map.GetMapInfo, mapID)
		if type(info) ~= "table" then break end
		if info.mapType == MAP_TYPE_CONTINENT then
			Add(mapID)
			break
		end
		mapID = info.parentMapID
	end
	return maps
end

-- The client's list of a continent's flight masters, or an empty one, without the points Forever has no
-- flight master for: they are never known, and never lend their marks or names to the others (below).
local function TaxiNodes(mapID)
	local list = C_TaxiMap and Call(C_TaxiMap.GetTaxiNodesForMap, mapID)
	local nodes = {}
	for _, node in ipairs(type(list) == "table" and list or {}) do
		if type(node) == "table" and ns.ForeverTaxiNode(ns.Readable(node.nodeID)) then nodes[#nodes + 1] = node end
	end
	return nodes
end

--[[
	The flight paths the client's list marks known: those not marked undiscovered, on a list that marks
	some. A list that marks none says nothing of this character (or the client leaves the mark out), so
	nothing is taken from it.
]]
local function ReadMarkedNodes()
	for _, mapID in ipairs(FlightMaps()) do
		local nodes = TaxiNodes(mapID)
		local marks = false
		for _, node in ipairs(nodes) do
			if ns.Readable(node.isUndiscovered) == true then
				marks = true
				break
			end
		end
		if marks then
			for _, node in ipairs(nodes) do
				if not ns.Readable(node.isUndiscovered) then Discovery:LearnedFlight(node.nodeID) end
			end
		end
	end
end

--[[
	A flight master's map, open: each of its flight paths the client marks as one this character has
	(any kind but "NONE"), known by node id from the taxi map's own slots where the client lists them,
	else by its name in the continents' lists.
]]
local function ReadFlightMaster()
	local count = Call(NumTaxiNodes)
	if type(count) ~= "number" or type(TaxiNodeGetType) ~= "function" then return end
	local bySlot, byName = {}, {}
	local taxiMap = Call(GetTaxiMapID)
	if taxiMap and C_TaxiMap and C_TaxiMap.GetAllTaxiNodes then
		local list = Call(C_TaxiMap.GetAllTaxiNodes, taxiMap)
		for _, node in ipairs(type(list) == "table" and list or {}) do
			local slot, nodeID = ns.Readable(node.slotIndex), ns.Readable(node.nodeID)
			if slot and nodeID then bySlot[slot] = nodeID end
			if node.name and nodeID then byName[node.name] = nodeID end
		end
	end
	for _, mapID in ipairs(FlightMaps()) do
		for _, node in ipairs(TaxiNodes(mapID)) do
			if node.name and node.nodeID and not byName[node.name] then byName[node.name] = node.nodeID end
		end
	end
	for index = 1, count do
		local kind = Call(TaxiNodeGetType, index)
		if type(kind) == "string" and kind ~= "NONE" then
			Discovery:LearnedFlight(bySlot[index] or byName[Call(TaxiNodeName, index) or ""])
		end
	end
end

--[[
	"New flight path discovered!" (UI_INFO_MESSAGE with the client's ERR_NEWTAXIPATH, or its message type
	LE_GAME_ERR_NEWTAXIPATH): a flight master spoken to for the first time, which may teach its path with no
	flight master's map shown (the next map read, TAXIMAP_OPENED, would find it too). The path is that flight
	master's, where the player stands: the nearest point of the client's list for the player's map (Forever's
	own points only, TaxiNodes) that serves the player's side or both, no further than NEW_FLIGHT_NEAR of the
	map across or down (each point stands within a few yards of its flight master: Core/Compat.lua). None
	that near, no place for the player, or another message: nothing is learned. Any other UI_INFO_MESSAGE
	costs a few comparisons.
]]
Discovery.NEW_FLIGHT_NEAR = 0.04

-- Whether a UI_INFO_MESSAGE's text is the client's ERR_NEWTAXIPATH: its second value, or its first where a
-- client gives the text alone, a color code round it or not.
function Discovery:SaysNewFlightPath(text)
	text = ns.Readable(text)
	if type(text) ~= "string" or type(ERR_NEWTAXIPATH) ~= "string" then return false end
	if text == ERR_NEWTAXIPATH then return true end
	return text:find("|", 1, true) ~= nil and (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) == ERR_NEWTAXIPATH
end

function Discovery:NewFlightPath(messageType, message)
	local byType = type(LE_GAME_ERR_NEWTAXIPATH) == "number" and ns.Readable(messageType) == LE_GAME_ERR_NEWTAXIPATH
	if not byType and not (self:SaysNewFlightPath(message) or self:SaysNewFlightPath(messageType)) then return end
	local mapID, x, y = ns.PlayerMapPosition()
	if not (mapID and x and y) then return end
	local SIDES = Enum and Enum.FlightPathFaction or { Neutral = 0, Horde = 1, Alliance = 2 }
	local player = Call(UnitFactionGroup, "player")
	local best, nearest = nil, self.NEW_FLIGHT_NEAR
	for _, node in ipairs(TaxiNodes(mapID)) do
		local position = type(node.position) == "table" and node.position or nil
		local ok, nodeX, nodeY = false, nil, nil
		if position and position.GetXY then ok, nodeX, nodeY = pcall(position.GetXY, position) end
		nodeX, nodeY = ok and ns.Readable(nodeX), ok and ns.Readable(nodeY)
		-- (its side from its icon where the client leaves the field out, as the world map reads it)
		local side, atlas = ns.Readable(node.faction), ns.Readable(node.atlasName)
		if side == nil and type(atlas) == "string" then
			side = atlas:find("Alliance", 1, true) and SIDES.Alliance or atlas:find("Horde", 1, true) and SIDES.Horde or nil
		end
		local serves = side == nil or side == SIDES.Neutral or player == nil
			or (side == SIDES.Alliance and player == "Alliance") or (side == SIDES.Horde and player == "Horde")
		if serves and type(nodeX) == "number" and type(nodeY) == "number" then
			local distance = math.max(math.abs(nodeX - x), math.abs(nodeY - y))
			if distance <= nearest then best, nearest = node, distance end
		end
	end
	if best then
		self:LearnedFlight(best.nodeID)
		-- (new by the client's word: told, even where a flight master's map read it a moment before)
		self:Found("flight", ns.Readable(best.nodeID), ns.Readable(best.name))
	end
end

------------------------------------------------------------------------------------------
-- Quartermasters
------------------------------------------------------------------------------------------

--[[
	Whether the shop open is a faction's quartermaster: by its creature id where the data keeps the
	faction's quartermasters by theirs (Core/Registry.lua's faction.quartermasters, from the captures),
	else by name (one kept by its name alone, or the shop's id kept back by the client). A faction the
	data keeps no quartermaster for yet is known by its rewards alone: the shop that sells them is its
	quartermaster.
]]
local function Quartermaster(faction, npcID, name)
	local known = faction.quartermasters
	if type(known) ~= "table" or next(known) == nil then return true end
	for key, vendor in pairs(known) do
		if npcID and key == npcID then return true end
		if type(name) == "string" and type(vendor) == "table" and vendor.name == name and not (npcID and type(key) == "number") then
			return true
		end
	end
	return false
end

-- A shop open: each faction's rewards among its wares, where it is that faction's quartermaster.
local function ShopOpen()
	local wares, any = {}, false
	for index = 1, Call(GetMerchantNumItems) or 0 do
		local itemID = ns.ItemIDFromLink(Call(GetMerchantItemLink, index))
		if itemID then wares[itemID], any = true, true end
	end
	if not any then return end
	local npcID, name = ns.NpcIDFromGUID(Call(UnitGUID, "npc")), Call(UnitName, "npc")
	for _, faction in ipairs(ns.GetFactions and ns.GetFactions() or {}) do
		local rewards
		for _, standing in ipairs(faction.bosses or {}) do
			for _, row in ipairs(standing.loot or {}) do
				if wares[row.itemID] then
					rewards = rewards or {}
					rewards[#rewards + 1] = row.itemID
				end
			end
		end
		if rewards and Quartermaster(faction, npcID, name) then
			for _, itemID in ipairs(rewards) do Discovery:SawReward(faction, itemID) end
		end
	end
end

-- The shop open read again: after the Reputation tab's Capture, whose wares may be a faction's rewards now.
function Discovery:ReadShop()
	local ok, problem = pcall(ShopOpen)
	if not ok then geterrorhandler()(problem) end
end

------------------------------------------------------------------------------------------
-- Factions met
------------------------------------------------------------------------------------------

--[[
	The journal's factions on the character's Reputation tab (C_Reputation.GetNumFactions and
	GetFactionDataByIndex): those it has met, each kept for good. Its headings are read as the player left
	them, never opened or shut here (that is the player's own view): a faction under a shut one may be
	missed until it is opened again, and one gone from the list is not forgotten. Told (Changed) only where
	one is new; and to the chat line (Found) only where it is met now: not where a heading shut at the last
	read has been opened, nor at the session's first read with a list (the character's past). At login
	with the character's past (ReadPast), and on UPDATE_FACTION, a moment after the first of a burst
	(Discovery.FACTION_DELAY): the client sends one for each gain of reputation.
]]
Discovery.FACTION_DELAY = 1
function Discovery:ReadFactions()
	local store = Store()
	local count = store and C_Reputation and Call(C_Reputation.GetNumFactions)
	if type(count) ~= "number" or count < 1 then return end
	local journal = {}
	for _, faction in ipairs(ns.GetFactions and ns.GetFactions() or {}) do journal[faction.factionID] = true end
	local new, shut = {}, {}
	for index = 1, count do
		local data = Call(C_Reputation.GetFactionDataByIndex, index)
		local factionID = type(data) == "table" and ns.Readable(data.factionID)
		-- (a heading of its own is no faction, but one with a standing of its own is)
		local heading = type(data) == "table" and ns.Readable(data.isHeader) == true and ns.Readable(data.isHeaderWithRep) ~= true
		if type(data) == "table" and ns.Readable(data.isHeader) == true and ns.Readable(data.isCollapsed) == true then
			shut[tostring(factionID) .. ":" .. tostring(ns.Readable(data.name))] = true
		end
		if factionID and journal[factionID] and not heading and store.factions[factionID] ~= true then
			store.factions[factionID] = true
			new[#new + 1] = factionID
		end
	end
	-- (factions on the list because a heading shut at the last read is open now, or at the session's first read
	-- with a list, are the character's past: kept, not told, Found)
	local past = self.found.shut == nil
	for key in pairs(self.found.shut or {}) do past = past or not shut[key] end
	self.found.shut = shut
	if #new == 0 then return end
	Changed()
	if past then return end
	for _, factionID in ipairs(new) do self:Found("faction", factionID) end
end

-- UPDATE_FACTION heard: the list read once, FACTION_DELAY after the first of a burst.
function Discovery:QueueFactions()
	if self.factionsQueued then return end
	self.factionsQueued = true
	-- (let go by the waiting read alone: a read at login in between starts no second wait)
	if C_Timer and C_Timer.After then
		C_Timer.After(self.FACTION_DELAY, function()
			Discovery.factionsQueued = nil
			Discovery:ReadFactions()
		end)
	else
		self.factionsQueued = nil
		self:ReadFactions()
	end
end

------------------------------------------------------------------------------------------
-- The character's past
------------------------------------------------------------------------------------------

local readPast = false

-- The journal's quests this character has done or has in its quest log (taken before the journal kept
-- this, or with it off), the flight paths the client says it knows, and the factions on its Reputation
-- tab (ReadFactions). Once a session (again = true reads it once more).
function Discovery:ReadPast(again)
	if readPast and not again then return end
	readPast = true
	if not Store() then return end
	-- (none of it told: the finds are told once it has been read, Found)
	self.found.ready = false
	local done = C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted
	local inLog = C_QuestLog and C_QuestLog.GetLogIndexForQuestID
	-- (each part apart: one that fails leaves the others read, and the finds told after it, its error
	-- shown once they are)
	local problems = {}
	local function Part(read)
		local ok, problem = pcall(read)
		if not ok then problems[#problems + 1] = problem end
	end
	Part(function()
		if type(done) ~= "function" and type(inLog) ~= "function" then return end
		for questID in pairs(JournalQuests()) do
			if Call(done, questID) == true then
				self:Quest(questID, "done")
			else
				local index = Call(inLog, questID)
				if type(index) == "number" and index > 0 then self:Quest(questID, "taken") end
			end
		end
	end)
	Part(ReadMarkedNodes)
	Part(function() self:ReadFactions() end)
	self.found.ready = true
	for _, problem in ipairs(problems) do geterrorhandler()(problem) end
end

--[[
	The kills the journal kept itself, read into the record as the addon loads (Core/Init.lua: once the journal's words
	are laid over the data, as each kill was kept under the boss's name in them, so it is found in any language): the
	dungeon map's (charDB.defeated, UI/DungeonMap.lua) and the run block's open and last run (charDB.run and
	charDB.lastRun, Core/Run.lua). A build before this record (0.39.24 and older) kept them all the same, and a run
	carried into a build with it read "1/1 ??? defeated" for each boss in Adventure Mode: the strong guess at the
	owner's Drowned City run of 2026-11-18. Each boss of that dungeon (wing) a kept name finds (its trash and the members
	of an entry of several, "entry#member", none) is killed, and his dungeon entered. Without a word, as the character's
	past is read: no find told (so no line in chat, no glow), no first kill for the fog's listeners; what is worked out
	from finds and kills is only worked out again. A level the record has already, or higher, stays. True when it
	changed anything. (A method, not a local: this file is near Lua's limit of top-level locals.)
]]
function Discovery:BringKeptKills()
	local store, db = Store(), ns.charDB
	if not store then return false end
	local changed = false
	local function Bring(key, names)
		local instance = type(key) == "string" and type(names) == "table" and ns.GetInstance(key)
		if not instance then return end
		for name, kept in pairs(names) do
			if kept and type(name) == "string" and not name:find("#", 1, true) then
				for _, boss in ipairs(instance.bosses or {}) do
					if not ns.IsLootSection(boss) and ns.NamedAs(boss, name) then
						local bosses = store.bosses[instance.key]
						if type(bosses) ~= "table" then
							bosses = {}
							store.bosses[instance.key] = bosses
						end
						local bossKey = BossKey(boss)
						local was = bosses[bossKey]
						if not (type(was) == "number" and was >= BOSS_LEVELS.killed) then
							bosses[bossKey], changed = BOSS_LEVELS.killed, true
						end
						if store.instances[instance.key] ~= true then
							store.instances[instance.key], changed = true, true
						end
					end
				end
			end
		end
	end
	if type(db.defeated) == "table" then
		for key, names in pairs(db.defeated) do Bring(key, names) end
	end
	for _, field in ipairs({ "run", "lastRun" }) do
		local run = db[field]
		if type(run) == "table" and type(run.kills) == "table" then
			for key, names in pairs(run.kills) do Bring(key, names) end
		end
	end
	if changed then
		version = version + 1
		kills.count = kills.count + 1
	end
	return changed
end

------------------------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------------------------

local function QuestOffered()
	Discovery:Quest(Call(GetQuestID), "offered")
end

-- QUEST_ACCEPTED gives the quest's id, after the log's index on clients that give both.
local function QuestTaken(first, second)
	first, second = ns.Readable(first), ns.Readable(second)
	Discovery:Quest(type(second) == "number" and second or first, "taken")
end

local HANDLERS = {
	PLAYER_ENTERING_WORLD = Arrive,
	ZONE_CHANGED_NEW_AREA = Arrive,
	ZONE_CHANGED = Arrive,
	ZONE_CHANGED_INDOORS = Arrive,
	ENCOUNTER_START = function(encounterID, name)
		name = ns.Readable(name)
		local bosses, wing = EncounterBosses(ns.Readable(encounterID), name)
		local hidden = #bosses == 0 and here and type(name) == "string" and here.hidden[name]
		for _, boss in ipairs(bosses) do Discovery:Boss(wing, boss, "met") end
		if hidden then
			Discovery:Boss(hidden.wing, hidden.key, "met")
		end
	end,
	-- With no ENCOUNTER_START before it (a client that sends none), the end alone counts.
	ENCOUNTER_END = function(encounterID, name, _, _, success)
		local bosses, wing = EncounterBosses(ns.Readable(encounterID), ns.Readable(name))
		local level = ns.EncounterWon(success) and "killed" or "fought"
		for _, boss in ipairs(bosses) do Discovery:Boss(wing, boss, level) end
	end,
	LOOT_OPENED = LootOpened,
	-- With auto loot the window may be gone before it is drawn; the items are ready first.
	LOOT_READY = LootOpened,
	CHAT_MSG_LOOT = function(text)
		if here then SeeItem((ns.LootLineItem(text))) end
	end,
	START_LOOT_ROLL = Rolled,
	LOOT_HISTORY_UPDATE_DROP = HistoryDrop,
	QUEST_DETAIL = QuestOffered,
	QUEST_ACCEPTED = QuestTaken,
	QUEST_TURNED_IN = function(questID) Discovery:Quest(questID, "done") end,
	MERCHANT_SHOW = ShopOpen,
	-- The wares' links come in after the shop opens on a client that had not cached them.
	MERCHANT_UPDATE = ShopOpen,
	-- Reputation gained, or a faction met: the Reputation tab's list read again (a burst read once).
	UPDATE_FACTION = function() Discovery:QueueFactions() end,
	TAXIMAP_OPENED = function()
		ReadFlightMaster()
		ReadMarkedNodes()
	end,
	-- "New flight path discovered!", which may come with no flight master's map (NewFlightPath).
	UI_INFO_MESSAGE = function(messageType, message) Discovery:NewFlightPath(messageType, message) end,
	PLAYER_LOGIN = function()
		if C_Timer and C_Timer.After then
			C_Timer.After(BACKFILL_DELAY, function() Discovery:ReadPast() end)
			C_Timer.After(1, function() Discovery:Prepare() end)
		else
			Discovery:ReadPast()
		end
	end,
}

-- Always listening, whatever the style and whether recording or not. Never the combat log.
local events = CreateFrame("Frame")
Discovery.events = events
for event in pairs(HANDLERS) do ns.RegisterEvents(events, event) end
events:SetScript("OnEvent", function(_, event, ...)
	if not ns.charDB then return end
	local ok, problem = pcall(HANDLERS[event], ...)
	if not ok then geterrorhandler()(problem) end
end)

-- A roll's item as its frame is set up, for a client that has the frame but not START_LOOT_ROLL.
if type(GroupLootFrame_SetupItemDisplay) == "function" and type(hooksecurefunc) == "function" then
	hooksecurefunc("GroupLootFrame_SetupItemDisplay", function(frame)
		if ns.charDB and type(frame) == "table" then pcall(Rolled, frame.rollID) end
	end)
end

-- Adventure Mode turned on or off: what Knows says changes for everything at once.
ns.Style:OnChange(function()
	local adventure = ns.Style:Adventure()
	if adventure ~= wasAdventure then
		wasAdventure = adventure
		Changed(true)
		if adventure then Discovery:Prepare() end
	end
end)
