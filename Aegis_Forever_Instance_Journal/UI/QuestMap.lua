local _, ns = ...
local L = ns.L

--[[
	The journal's quests on the maps, as the client marks its own: a "!" where a dungeon or
	raid quest starts, greyed while the player cannot take it yet (its chain's earlier steps, the
	level, the quest it needs in the log still to come: its tooltip says which), and that only while
	the level it can be taken at is at most two above theirs (LOCKED_LEVELS: none further off, the
	owner's call of 2026-11-07), on the zone and continent maps; inside a dungeon at any level (the
	owner's call of 2026-11-11: "the exception to that rule is dungeons", Mark's inside); none once
	it is grey for their level, as the client hides those by default; a "?" where it is handed in,
	once it is ready to; nothing while it is under way, or once it is done. The Quests tab still
	lists them all.

	The "!" follows the journal's own rules and its own switch, the map legend's Quest entry
	(UI/MapLegend.lua, ns.db.mapHidden.quest), never a game setting: the game's switch for quests on
	offer (questPOILocalStory) is in no menu on Forever, and the journal's legend set it from 0.34.0
	to 0.39.1. The "?" follows the game's Quest Objectives filter (questPOI), in the
	map's filter menu and the game's settings, as the client's own marks of the quests in the log
	do (UI/MapLegend.lua).

	On Blizzard's world map the marks stand where each quest's giver does (the quest's start,
	as the Quests tab's Show Start has it); quests that start inside a dungeon have their mark
	on the journal's map of it (startInside: x, y and floor on its picture). Their state is the
	Quests tab's, from the player's own quest log and history, and follows it as it changes.

	A left click opens the quest in the journal; a right click sets a waypoint (on the world
	map) or puts the dungeon's map away (on it), as the journal's other marks do. Where the
	client already marks a quest itself, it is left to the client's mark.

	Inside a dungeon (the owner's go of 2026-11-11, on the dungeons' floor pictures; on a dungeon's whole map too, the
	owner's of 2026-11-12, each at its place there: InsideMarks), its givers' and takers' "!" and "?" (startInside,
	endInside), and what is looted, used or explored for
	a quest (objectivesInside: Data/Authored/InsideQuestSpots.lua) with the game's own In Progress mark, the dark
	disc with three yellow dots (OBJECTIVE_ART): never "?", which means hand in. It follows the quest log
	(ObjectiveMark): full while the quest is in the log and not done, faded before it is taken (by the "!"'s own
	rules: where the "!" would show, greyed while locked), and gone once done, once ready to hand in (its "?" takes
	over), or once that thing's item is in the bags or the log counts it found. Its tooltip names the thing (white), the quest (gold) and what to do there after the game's dash, then
	the click line. One mark for each person or thing, the first of its quests' (Rank); different ones on one spot
	stand side by side (INSIDE_SPACING), and beside a boss's pin rather than over it (ClearOfPins).

	A way in's picture shows the marks of what stands there for its dungeons' quests (a spot with wayIn, the picture's
	key: Gnomeregan's tunnels, 2026-11-12), by the same rules (InsideMarks with its key: UI/DungeonMap.lua's
	DrawWayInPins). A machine that trades one item for the next (a Matrix Punchograph: input, output) names both on its
	tooltip in short words, what goes in, then what comes out ("Yellow > Blue": each one's short, a key of the strings;
	the owner's call of 2026-11-12, in words for color-blind players too), and its mark goes once the player holds what it
	gives or anything made from that later (doneWith); a spot may add a note (note: a key of the strings, with what goes
	in named: where the White Punch Card drops). A spot may show its own icon in place of the In Progress mark (icon:
	RINGED_SIZE, below), by the same rules otherwise. A machine used again once its quest is done keeps the game's
	repeatable turn-in mark (repeatInside: RepeatMark, below; the Sparklematic 5200).

	A quest the player can't take yet says why in each mark's tooltip, the world map's grey "!" too (the owner's
	call of 2026-11-11): "Requires level X" and "Requires: <quest>", a line for each step the player can do next
	(QuestsPanel:Requirements, worked out as the tooltip shows).

	A boss a quest needs (to kill, for his drop, for a drop that starts it, or giving or taking it there) wears the
	game's quest badge on his pins and in the boss list, by the same rules: "The quest badge on a boss", below.
]]

local QuestMap = {}
ns.QuestMap = QuestMap

local QUEST_PIN_TEMPLATE = "AegisJournalQuestPinTemplate"
-- The client's own marks, which carry their quest's id: the quests on offer (QuestOfferDataProvider)
-- and the quests in the player's log, a "?" once one can be handed in (QuestDataProvider).
local CLIENT_TEMPLATES = { "QuestOfferPinTemplate", "QuestPinTemplate" }
local START_ATLAS, TURN_IN_ATLAS = "QuestNormal", "QuestTurnin"
-- The game's blue mark of a repeatable quest to hand in (Forever's atlas tables, ObjectIconsAtlas, read 2026-11-12;
-- not yet seen in a running game): RepeatMark's, the "?" where the client lacks it.
local REPEAT_ATLAS = "QuestRepeatableTurnin"
local LOCKED_ALPHA = 0.8
local RED, GREEN = { 1, 0.3, 0.3 }, { 0.1, 1, 0.1 }
local HIGHLIGHT_ALPHA = 0.4
local REFRESH_DELAY = 0.2
-- How far below the player's level a quest goes grey, where the client does not say.
local GREY_RANGE = 5
-- How many levels above the player's a quest not open yet may need and still have its grey "!".
local LOCKED_LEVELS = 2
-- How near two marks stand to be one spot, as a share of the map's width or height: the same giver's
-- quests often differ by a hair (0.6790 and 0.6792), and marks this near cover each other anyway.
local SAME_SPOT = 0.01
--[[
	The objective mark inside a dungeon: the game's In Progress mark as its quest pins draw it (its POIButtonTemplate,
	read in Forever's client files 2026-11-11), on a button of the journal's own, never that template, whose code goes
	through the game's quest managers: a 20 x 20 button, its art 32 x 32, the dark disc under the three yellow dots and
	the inner glow added between them while pointed at. Each atlas is in Forever's atlas tables, not yet seen in a running
	game: where the client lacks one, the template's own picture with its cuts for the disc and the glow, and the game's
	yellow dot, smaller, for the dots; with neither, plain colors, so that the mark still shows.
]]
local OBJECTIVE_ART = {
	{ key = "Disc", atlas = "UI-QuestPoi-QuestNumber", file = "Interface\\WorldMap\\UI-QuestPoi-NumberIcons",
		coords = { 0.875, 1, 0.875, 1 }, color = { 0.2, 0.06, 0.04, 0.9 }, plain = 18 },
	{ key = "Glow", atlas = "UI-QuestPoi-InnerGlow", file = "Interface\\WorldMap\\UI-QuestPoi-NumberIcons",
		coords = { 0.625, 0.75, 0.375, 0.5 }, color = { 1, 1, 1, 0.3 }, plain = 18 },
	{ key = "Dots", atlas = "Quest-In-Progress-Icon-yellow", file = "Interface\\COMMON\\Indicator-Yellow", size = 14,
		color = { 1, 0.82, 0, 1 }, plain = 6 },
}
local OBJECTIVE_SIZE, OBJECTIVE_ART_SIZE, GIVER_SIZE = 20, 32, 24
-- An objective of a quest not taken yet: faded (the owner's call of 2026-11-11).
local OBJECTIVE_FADED_ALPHA = 0.5
-- Different marks within SAME_SPOT of each other on one floor stand side by side, this far apart (the boss pins' way,
-- UI/DungeonMap.lua's SHARED_SPOT_SPACING, for marks this size).
local INSIDE_SPACING = 22
--[[
	An objective's own icon (spot.icon: a file id or an atlas), in place of the In Progress mark: masked round (the
	journal's CIRCLE_MASK) inside the minimap tracking button's gold ring, Interface/Minimap/MiniMap-TrackingBorder (file
	136430), cut to the ring and its shadow (RING_COORDS: x 1.5 to 39.5, y 1 to 39 of its 64 x 64 file, the ring's
	centre in the middle), the ring's art RING_ART_SIZE (its gold about 28 across), the icon RING_ICON_SIZE under it, on a
	RINGED_SIZE button: as the owner's pick of 2026-11-12 drew it (Data Rescue's Matrix Punchographs, each the punch card
	it takes: Data/Authored/InsideQuestSpots.lua). Pointed at, the minimap buttons' own highlight over it. Its larger
	size counts where marks stand side by side (InsideMarks) and keep clear of the pins (ClearOfPins).
]]
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local RING_FILE = "Interface\\Minimap\\MiniMap-TrackingBorder"
local RING_COORDS = { 1.5 / 64, 39.5 / 64, 1 / 64, 39 / 64 }
local RING_HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
local RINGED_SIZE, RING_ART_SIZE, RING_ICON_SIZE = 30, 32, 20

local provider

------------------------------------------------------------------------------------------
-- What each quest shows
------------------------------------------------------------------------------------------

-- How many levels below the player's a quest goes grey: the client's own rule.
local function GreyRange()
	for _, name in ipairs({ "UnitQuestTrivialLevelRange", "GetQuestGreenRange" }) do
		local rule = _G[name]
		if type(rule) == "function" then
			local ok, range = pcall(rule, "player")
			if ok and type(range) == "number" then return range end
		end
	end
	return GREY_RANGE
end

-- Grey for the player, as the quest log greys it: too far below their level to be worth taking.
function QuestMap.IsGrey(quest)
	local ok, level = pcall(UnitLevel, "player")
	return type(quest.level) == "number" and ok and type(level) == "number" and level - quest.level > GreyRange()
end

-- Too far off for a grey "!": the level the quest can be taken at (its requiredLevel, the one the Quests
-- tab locks it by) more than LOCKED_LEVELS above the player's. A quest with no such level is not.
function QuestMap.IsFarOff(quest)
	local ok, level = pcall(UnitLevel, "player")
	return type(quest.requiredLevel) == "number" and ok and type(level) == "number"
		and quest.requiredLevel > level + LOCKED_LEVELS
end

--[[
	A quest's mark now, or nil: { kind = "start" or "turnin", point = its place on the world
	map (or nil), inside = its spot on the dungeon's map (or nil), locked = why the player cannot
	take it yet (or nil: its tooltip's lines are QuestsPanel:Requirements', worked out only as it shows,
	AddRequirements) }. A start for a quest not grey for the player: greyed while locked, and none
	while locked and its level is more than LOCKED_LEVELS above theirs (QuestMap.IsFarOff), whatever
	else it still needs.
	inside: true for a mark inside a dungeon (its map's "!", "?" and objective marks, its bosses' badges on their
	pins and in the boss list): there a quest not open yet shows at any level, greyed, its tooltip saying
	"Requires level X" (the owner's call of 2026-11-11: the two-level rule is the zone and continent maps' only).
]]
function QuestMap:Mark(quest, inside)
	local panel = ns.QuestsPanel
	local status = panel:Status(quest)
	if status == "ready" then
		-- The game's Quest Objectives filter, as the map legend's Turn In entry shows it.
		if not ns.MapLegend.Shows("turnin") then return nil end
		return { kind = "turnin", point = panel:EndPoint(quest), inside = quest.endInside }
	end
	if (status ~= "available" and status ~= "locked") or QuestMap.IsGrey(quest) then return nil end
	-- The legend's Quest entry, the journal's own switch for its "!" marks, everywhere.
	if not ns.MapLegend.Shows("quest") then return nil end
	-- Given only while another quest is in the log, and that one is done: it cannot open any more.
	if status == "locked" and quest.parentQuest and panel:IsDone(quest.parentQuest.questID) then return nil end
	-- Not open yet and its level still more than two away: no grey "!" until the player is nearer; inside a dungeon, one.
	if status == "locked" and not inside and QuestMap.IsFarOff(quest) then return nil end
	local mark = { kind = "start", point = panel:StartPoint(quest), inside = quest.startInside }
	if status == "locked" then mark.locked = panel:LockedReason(quest) end
	return mark
end

-- What looting an objective's thing gives (its item), in the client's words once it has them, else the data's.
local function ItemName(spot)
	if not spot.item then return spot.itemName end
	local info = ns.Items:Get(spot.item, { name = spot.itemName })
	return info and info.name or spot.itemName
end

-- Whether the quest log counts a part of a quest done: the first objective that names one of names, finished
-- ("Shattered Necklace Ruby: 1/1", "Bazzalan slain: 1/1", in the client's words). False where none names one.
local function LoggedDone(quest, names)
	local objectives = C_QuestLog and C_QuestLog.GetQuestObjectives
	if type(objectives) ~= "function" then return false end
	local ok, list = pcall(objectives, quest.questID)
	if not ok or type(list) ~= "table" then return false end
	for _, objective in ipairs(list) do
		local text = type(objective) == "table" and ns.Readable(objective.text)
		if type(text) == "string" then
			for _, name in ipairs(names) do
				if type(name) == "string" and name ~= "" and text:find(name, 1, true) then
					return ns.Readable(objective.finished) == true
				end
			end
		end
	end
	return false
end

-- Whether the player carries an item (bags, as the client counts them).
local function InBags(itemID)
	if type(itemID) ~= "number" then return false end
	local count = C_Item and C_Item.GetItemCount or GetItemCount
	if type(count) ~= "function" then return false end
	local ok, held = pcall(count, itemID)
	held = ok and ns.Readable(held) or nil
	return type(held) == "number" and held > 0
end

-- Whether this thing's own part of the quest is done: what is looted there in the bags, as a boss's badge goes once his
-- item is (the review of 3cc3416), or the quest log's objective that names its item finished (by the item's name in the
-- client's words). An item to use there is not looted from it: only the log says. Where neither says, the mark stays
-- until the quest is ready to hand in.
local function ObjectiveDone(quest, spot)
	-- (a machine's step: done once what it gives, or what is made from that later, is in the bags)
	for _, itemID in ipairs(spot.doneWith or {}) do
		if InBags(itemID) then return true end
	end
	if not spot.item then return false end
	if spot.act == "loot" and InBags(spot.item) then return true end
	return LoggedDone(quest, { ItemName(spot) })
end

--[[
	An objective's mark inside a dungeon now (a thing to loot or use, a place to explore: a spot of the quest's
	objectivesInside), or nil, by the quest log (the owner's call of 2026-11-11): { kind = "objective", spot = the
	spot }, full while the quest is in the log, not done and not ready, as the game's own In Progress marks show it
	(the game's Quest Objectives filter, MapLegend's In Progress); none once this thing's part is counted done
	(ObjectiveDone). Before the quest is taken: faded = true, where its "!" inside would show and as it would (Mark:
	the legend's Quest entry, its level, greyed with locked while it can't be taken, at any level). None once done or
	ready to hand in: its "?" takes over.
]]
function QuestMap:ObjectiveMark(quest, spot)
	local status = ns.QuestsPanel:Status(quest)
	if status == "active" then
		if not ns.MapLegend.Shows("inprogress") or ObjectiveDone(quest, spot) then return nil end
		return { kind = "objective", spot = spot }
	end
	if status ~= "available" and status ~= "locked" then return nil end
	local start = self:Mark(quest, true)
	if not (start and start.kind == "start") then return nil end
	return { kind = "objective", spot = spot, faded = true, locked = start.locked }
end

--[[
	A machine used again once its quest is done (the quest's repeatInside: { spot, item, itemName }; The Sparklematic
	5200, which cleans another Grime-Encrusted Object as often as the player brings one: the owner's call of 2026-11-12),
	or nil: { kind = "repeat", inside = its spot, again = repeatInside }, in the game's repeatable turn-in look
	(REPEAT_ATLAS), once the quest is done (any of its versions: QuestsPanel's Status), by the "!"'s own rules otherwise
	(the legend's Quest entry; none once the quest is grey for the player's level). Below a quest that can be taken or
	handed in there now, over one not open yet (Rank): the machine can be used now, and the grey "!" of the ring's
	Return of the Ring would stand there until its ring is found. The repeatable quest itself has no row in the journal
	(More Sparklematic Action, out since the owner's call of 2026-11-12): a click opens the quest that was done.
]]
function QuestMap:RepeatMark(quest)
	local again = quest.repeatInside
	if not (again and again.spot) or ns.QuestsPanel:Status(quest) ~= "done" then return nil end
	if QuestMap.IsGrey(quest) or not ns.MapLegend.Shows("quest") then return nil end
	return { kind = "repeat", inside = again.spot, again = again }
end

-- Which of two marks of one spot stands for it: a "?" or an objective under way first, then a quest that can be
-- taken now, then a machine to use again, then a quest not open yet.
local function Rank(mark)
	if mark.kind == "repeat" then return 0.5 end
	if mark.kind == "turnin" or (mark.kind == "objective" and not mark.faded) then return 2 end
	return mark.locked and 0 or 1
end

local function Outranks(mark, other)
	return Rank(mark) > Rank(other)
end

-- An objective's own icon (spot.icon), where the client can draw it: a file id, or an atlas it has; else nil (the In
-- Progress mark then).
local function SpotIcon(spot)
	local icon = spot and spot.icon
	if type(icon) == "number" or (type(icon) == "string" and ns.AtlasExists(icon)) then return icon end
	return nil
end

-- A mark's size on the map, in the pins' units: a "!" or "?", the In Progress mark, or an icon in its ring.
local function MarkSize(mark)
	if mark.kind ~= "objective" then return GIVER_SIZE end
	return SpotIcon(mark.spot) and RINGED_SIZE or OBJECTIVE_SIZE
end

-- How much wider than the In Progress mark an icon in its ring is on each side: marks side by side stand that much
-- further apart for it (none for the others, as before).
local function Wider(mark)
	return mark.kind == "objective" and SpotIcon(mark.spot) and (RINGED_SIZE - OBJECTIVE_SIZE) / 2 or 0
end

--[[
	Which quests may have a mark on a map, so that a map looks at its own few rather than every
	quest of every dungeon: by the maps their start and end are on, rebuilt when the data changes
	(the registry then hands out new lists). Places the Record tab saw are looked up as the map is
	drawn: there are few.
]]
local index = {}

local function AddOn(byMap, mapID, entry)
	local list = byMap[mapID]
	if not list then
		list = {}
		byMap[mapID] = list
	end
	if list[#list] ~= entry then list[#list + 1] = entry end
end

local function Index()
	local dungeons, raids = ns.GetInstances("dungeon"), ns.GetInstances("raid")
	if index.byMap and index.dungeons == dungeons and index.raids == raids then return index end
	local byMap, byQuestID = {}, {}
	for _, list in ipairs({ dungeons, raids }) do
		for _, instance in ipairs(list) do
			for _, quest in ipairs(instance.quests or {}) do
				-- A quest several dungeons list (the paladin's Tome of Valor parts, a monastery quest
				-- in each wing it sends you to) has one mark, opening the first of them.
				if not byQuestID[quest.questID] then
					local entry = { instance = instance, quest = quest }
					byQuestID[quest.questID] = entry
					if quest.startMap and quest.startMap.mapID then AddOn(byMap, quest.startMap.mapID, entry) end
					if quest.endMap and quest.endMap.mapID then AddOn(byMap, quest.endMap.mapID, entry) end
				end
			end
		end
	end
	index.dungeons, index.raids, index.byMap, index.byQuestID = dungeons, raids, byMap, byQuestID
	return index
end

-- The dungeon and raid quests of this character's with a mark on this map: { instance, quest, mark, x, y }.
-- None while the journal's world-map markers are off in its style (Core/Style.lua); the marks on a
-- dungeon's own map (InsideMarks) are the journal's, and stay.
function QuestMap:MarksOn(mapID)
	if not ns.Style:On("mapMarkers") then return {} end
	local known = Index()
	local candidates, seen = {}, {}
	for _, entry in ipairs(known.byMap[mapID] or {}) do
		candidates[#candidates + 1], seen[entry] = entry, true
	end
	local state = ns.Recorder and ns.Recorder:GetState()
	for questID, recorded in pairs(state and state.quests or {}) do
		local entry = known.byQuestID[questID]
		if entry and not seen[entry] then
			for _, step in ipairs({ recorded.pickup or false, recorded.turnin or false }) do
				if step and step.place and step.place.mapID == mapID and not seen[entry] then
					candidates[#candidates + 1], seen[entry] = entry, true
				end
			end
		end
	end
	-- Quests of one name whose marks would stand on one spot are one mark (the four dungeons' The Left Piece of
	-- Lord Valthalak's Amulet, each given by Bodley in Blackrock Mountain, stood four deep): a "?" if one of them
	-- can be handed in, else the first that can be taken now, else the first; its tooltip names each dungeon
	-- (also: the others).
	local spots, order = {}, {}
	for _, entry in ipairs(candidates) do
		if ns.QuestsPanel:IsForPlayer(entry.quest) then
			local mark = self:Mark(entry.quest)
			local point = mark and mark.point
			if point and point.mapID == mapID and point.x then
				local spot = (entry.quest.enName or entry.quest.name or "") .. "|" .. point.x .. "|" .. tostring(point.y)
				if not spots[spot] then
					spots[spot] = {}
					order[#order + 1] = spot
				end
				local same = spots[spot]
				same[#same + 1] = { instance = entry.instance, quest = entry.quest, mark = mark, x = point.x, y = point.y }
			end
		end
	end
	local merged, kept = {}, {}
	for _, spot in ipairs(order) do
		local same = spots[spot]
		local shown = same[1]
		for _, entry in ipairs(same) do
			if Outranks(entry.mark, shown.mark) then shown = entry end
		end
		if #same > 1 then
			shown.also = {}
			for _, entry in ipairs(same) do
				if entry ~= shown then shown.also[#shown.also + 1] = entry end
			end
		end
		merged[#merged + 1] = shown
		if not shown.mark.locked then kept[#kept + 1] = shown end
	end
	-- One grey "!" to a spot at most, and none where a quest that can be taken or handed in now has its mark
	-- (a giver of several steps of a chain): the open one is the giver's mark, not hidden under a grey one, and
	-- of several grey ones the first, the step the dungeon lists first. One spot: marks within SAME_SPOT of each
	-- other across and down. The Quests tab lists the others.
	local list = {}
	for _, entry in ipairs(merged) do
		local free = true
		if entry.mark.locked then
			for _, other in ipairs(kept) do
				if math.abs(other.x - entry.x) < SAME_SPOT and math.abs((other.y or 0) - (entry.y or 0)) < SAME_SPOT then
					free = false
					break
				end
			end
			if free then kept[#kept + 1] = entry end
		end
		if free then list[#list + 1] = entry end
	end
	return list
end

--[[
	The marks inside one dungeon, on one floor of its map: { quest, mark, x, y, spot, shift }. A quest whose
	start lies in one of several places (an item that is not always in the same spot) gives
	startInside as a list of spots, and has a mark on each, its tooltip saying how many. What is
	looted, used or explored for a quest has its objective mark (ObjectiveMark); a machine used again once its quest is
	done, its repeatable mark (RepeatMark).

	One mark for each person or thing (a spot's table: Data/Authored/InsideQuestSpots.lua gives the quests of one
	the same table), the first of its quests' by Rank, as the game puts one mark over a person with several quests;
	marks of different ones within SAME_SPOT of each other stand side by side, shift (in the pins' own units) from
	their spot, INSIDE_SPACING apart.

	A dungeon's whole map (a floor marked whole, first in its floor menu: Data/Authored/ClassicMaps.lua) shows the marks
	of every floor, by the same rules (the owner's call of 2026-11-12): a spot on a level floor stands at its place on
	the whole map (spot.whole: Data/Authored/InsideQuestSpots.lua), one on the whole map's own picture where it is.

	wayIn: a way in's key (Data/Authored/SubMaps.lua) for the marks on its picture instead, those of the spots there
	(spot.wayIn), on none of the dungeon's floors.
]]
function QuestMap:InsideMarks(instance, floorIndex, wayIn)
	local list, at = {}, {}
	local floors = instance.map and instance.map.floors
	local onWhole = floors and floors[floorIndex] and floors[floorIndex].whole
	-- (where a spot stands on this floor, or on the way in's picture, or nil)
	local function Place(spot)
		if wayIn or spot.wayIn then return spot.wayIn == wayIn and spot or nil end
		if (spot.floor or 1) == floorIndex then return spot end
		return onWhole and spot.whole or nil
	end
	local function Add(quest, mark, spot, place)
		local same = at[spot]
		if not same then
			at[spot] = { quest = quest, mark = mark, x = place.x, y = place.y, spot = spot }
			list[#list + 1] = at[spot]
		elseif Outranks(mark, same.mark) then
			same.quest, same.mark = quest, mark
		end
	end
	for _, quest in ipairs(instance.quests or {}) do
		if ns.QuestsPanel:IsForPlayer(quest) then
			local mark = self:Mark(quest, true)
			local inside = mark and mark.inside
			local spots = inside and (inside.x and { inside } or inside) or {}
			if #spots > 1 then mark.places = #spots end
			for _, spot in ipairs(spots) do
				local place = Place(spot)
				if place then Add(quest, mark, spot, place) end
			end
			for _, spot in ipairs(quest.objectivesInside or {}) do
				local place = Place(spot)
				local objective = place and self:ObjectiveMark(quest, spot)
				if objective then Add(quest, objective, spot, place) end
			end
			local again = self:RepeatMark(quest)
			local place = again and Place(again.inside)
			if place then Add(quest, again, again.inside, place) end
		end
	end
	for index, entry in ipairs(list) do
		if not entry.shift then
			local together = { entry }
			for later = index + 1, #list do
				local other = list[later]
				if not other.shift and math.abs(other.x - entry.x) < SAME_SPOT and math.abs(other.y - entry.y) < SAME_SPOT then
					together[#together + 1] = other
				end
			end
			-- (centred on their spot, INSIDE_SPACING apart, and further by what an icon in its ring adds: Wider)
			local offsets = { 0 }
			for place = 2, #together do
				offsets[place] = offsets[place - 1] + INSIDE_SPACING + Wider(together[place - 1].mark) + Wider(together[place].mark)
			end
			for place, member in ipairs(together) do
				member.shift, member.group = offsets[place] - offsets[#together] / 2, together
			end
		end
	end
	return list
end

--[[
	Inside marks clear of the boss pins (the review of 3cc3416): a spot set beside a boss's portrait
	(the Fathom Stone at Baron Aquanis's) drew its mark over his portrait, above his pin, and took his pointer, his
	badge's lines with it. A mark within a pin's round frame (its centre nearer the pin's than the pin's half width and
	its own half size) moves across, with the marks at its side (InsideMarks' group), to the side the group leans to,
	PIN_GAP clear of the ring, as boss pins sharing a spot stand side by side; twice over, should the first move land
	it on the next pin. One near the ring and not over it (the Crests of Lordaeron's) stays. A group with an icon in its
	ring (RINGED_SIZE: larger than the rest) then keeps clear of the other marks near it the same way, and of the pins
	again, once those have their places: at the windowed map's size a Punchograph's ring on Gnomeregan's whole map came
	within a pixel of the Sparklematic 5200's "!". Two marks of the In Progress or "!" size near each other stay as
	before. marks: InsideMarks' entries, their shift set again; pins: the frames shown, each with its point and shift
	(DungeonMap.Place's); width and height, the floor's picture's; scale, the marks'.
]]
local PIN_GAP = 2

-- One group of marks side by side moved across, PIN_GAP clear of each round thing in its way (things: x and y, its
-- centre, and reach, its half width, in the canvas's units), to the side the group leans to; twice over.
local function ClearGroup(group, things, width, height, scale)
	local y = group[1].y * height
	for _ = 1, 2 do
		for _, thing in ipairs(things) do
			local dy = math.abs(thing.y - y)
			local centre = 0
			for _, member in ipairs(group) do centre = centre + member.x * width + member.shift * scale end
			local side = centre / #group >= thing.x and 1 or -1
			local move = 0
			for _, member in ipairs(group) do
				local reach = thing.reach + MarkSize(member.mark) / 2 * scale
				local across = (member.x * width + member.shift * scale - thing.x) * side
				if across * across + dy * dy < reach * reach then
					-- (how far across from the thing's centre it clears it, at its height)
					move = math.max(move, math.sqrt(reach * reach - dy * dy) + PIN_GAP - across)
				end
			end
			if move > 0 then
				for _, member in ipairs(group) do member.shift = member.shift + side * move / scale end
			end
		end
	end
end

function QuestMap:ClearOfPins(marks, pins, width, height, scale)
	local things = {}
	for _, pin in ipairs(pins) do
		local pinScale = pin:GetScale()
		things[#things + 1] = { x = pin.point.x * width + (pin.shift or 0) * pinScale, y = pin.point.y * height,
			reach = ns.DungeonMap.PIN_WIDTH / 2 * pinScale }
	end
	local groups, done = {}, {}
	for _, entry in ipairs(marks) do
		local group = entry.group or { entry }
		if not done[group] then
			done[group] = true
			groups[#groups + 1] = group
			ClearGroup(group, things, width, height, scale)
		end
	end
	for _, group in ipairs(groups) do
		local ringed, mine = false, {}
		for _, member in ipairs(group) do
			mine[member] = true
			ringed = ringed or MarkSize(member.mark) == RINGED_SIZE
		end
		if ringed then
			local around = {}
			for _, thing in ipairs(things) do around[#around + 1] = thing end
			for _, other in ipairs(marks) do
				if not mine[other] then
					around[#around + 1] = { x = other.x * width + other.shift * scale, y = other.y * height,
						reach = MarkSize(other.mark) / 2 * scale }
				end
			end
			ClearGroup(group, around, width, height, scale)
		end
	end
end

-- A quest not open yet: its "!" desaturated and a little faded, as the Quests tab's lock icon is. alpha: the
-- texture's own (a highlight's), 1 if not given. A machine to use again: the game's repeatable turn-in mark.
function QuestMap:SetMarkTexture(texture, mark, alpha)
	local atlas = mark.kind == "turnin" and TURN_IN_ATLAS or START_ATLAS
	if mark.kind == "repeat" then atlas = ns.AtlasExists(REPEAT_ATLAS) and REPEAT_ATLAS or TURN_IN_ATLAS end
	texture:SetAtlas(atlas)
	texture:SetDesaturated(mark.locked ~= nil)
	texture:SetAlpha((alpha or 1) * (mark.locked and LOCKED_ALPHA or 1))
end

-- An inside mark's art, on the journal's own button (UI/DungeonMap.lua's QuestSpot): the "!" or "?" (Texture), and the
-- objective mark's disc, glow and dots (OBJECTIVE_ART), each centred, the glow added; and an objective's own icon
-- (Icon), round, under its ring (Ring), the highlight added over both while pointed at (RINGED_SIZE).
function QuestMap:BuildInsideSpot(spot)
	spot.Texture = spot:CreateTexture(nil, "ARTWORK")
	spot.Texture:SetAllPoints()
	spot.Disc = spot:CreateTexture(nil, "BACKGROUND")
	spot.Glow = spot:CreateTexture(nil, "BORDER")
	spot.Glow:SetBlendMode("ADD")
	spot.Dots = spot:CreateTexture(nil, "ARTWORK", nil, 1)
	for _, art in ipairs(OBJECTIVE_ART) do spot[art.key]:SetPoint("CENTER") end
	spot.Glow:Hide()
	spot.Icon = spot:CreateTexture(nil, "ARTWORK")
	spot.Icon:SetSize(RING_ICON_SIZE, RING_ICON_SIZE)
	spot.Icon:SetPoint("CENTER")
	if spot.CreateMaskTexture and spot.Icon.AddMaskTexture then
		local mask = spot:CreateMaskTexture()
		mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetAllPoints(spot.Icon)
		spot.Icon:AddMaskTexture(mask)
	end
	spot.Ring = spot:CreateTexture(nil, "OVERLAY")
	spot.Ring:SetTexture(RING_FILE)
	spot.Ring:SetTexCoord(RING_COORDS[1], RING_COORDS[2], RING_COORDS[3], RING_COORDS[4])
	spot.Ring:SetSize(RING_ART_SIZE, RING_ART_SIZE)
	spot.Ring:SetPoint("CENTER")
	spot.Highlight = spot:CreateTexture(nil, "OVERLAY", nil, 1)
	spot.Highlight:SetTexture(RING_HIGHLIGHT)
	spot.Highlight:SetBlendMode("ADD")
	spot.Highlight:SetSize(RINGED_SIZE, RINGED_SIZE)
	spot.Highlight:SetPoint("CENTER")
	spot.Icon:Hide()
	spot.Ring:Hide()
	spot.Highlight:Hide()
end

-- One piece of the objective mark: its atlas, else the file with its cut, else its plain color, at its size.
local function SetObjectiveArt(texture, art)
	local size = OBJECTIVE_ART_SIZE
	if ns.AtlasExists(art.atlas) then
		texture:SetAtlas(art.atlas)
	elseif ns.FileExists(art.file) then
		texture:SetTexture(art.file)
		local cut = art.coords or { 0, 1, 0, 1 }
		texture:SetTexCoord(cut[1], cut[2], cut[3], cut[4])
		size = art.size or size
	else
		texture:SetColorTexture(art.color[1], art.color[2], art.color[3], art.color[4])
		texture:SetTexCoord(0, 1, 0, 1)
		size = art.plain
	end
	texture:SetSize(size, size)
end

-- An inside mark drawn for its mark: a "!" or "?" as on the world map (SetMarkTexture), at GIVER_SIZE; an objective
-- the game's In Progress mark at OBJECTIVE_SIZE, or its own icon in the ring at RINGED_SIZE, faded before its quest is
-- taken, desaturated and a little more faded while it can't be taken, as a grey "!".
function QuestMap:StyleInsideSpot(spot, mark)
	local objective = mark.kind == "objective"
	local icon = objective and SpotIcon(mark.spot) or nil
	spot.Texture:SetShown(not objective)
	spot.Disc:SetShown(objective and not icon)
	spot.Dots:SetShown(objective and not icon)
	spot.Icon:SetShown(icon ~= nil)
	spot.Ring:SetShown(icon ~= nil)
	spot.Glow:Hide()
	spot.Highlight:Hide()
	if not objective then
		spot:SetSize(GIVER_SIZE, GIVER_SIZE)
		self:SetMarkTexture(spot.Texture, mark)
		return
	end
	local alpha = (mark.faded and OBJECTIVE_FADED_ALPHA or 1) * (mark.locked and LOCKED_ALPHA or 1)
	if icon then
		spot:SetSize(RINGED_SIZE, RINGED_SIZE)
		if type(icon) == "number" then
			spot.Icon:SetTexture(icon)
			spot.Icon:SetTexCoord(0, 1, 0, 1)
		else
			spot.Icon:SetAtlas(icon)
		end
		spot.Icon:SetDesaturated(mark.locked ~= nil)
		spot.Icon:SetAlpha(alpha)
		spot.Ring:SetDesaturated(mark.locked ~= nil)
		spot.Ring:SetAlpha(alpha)
		return
	end
	spot:SetSize(OBJECTIVE_SIZE, OBJECTIVE_SIZE)
	for _, art in ipairs(OBJECTIVE_ART) do
		local texture = spot[art.key]
		SetObjectiveArt(texture, art)
		texture:SetDesaturated(mark.locked ~= nil)
		texture:SetAlpha(art.key == "Glow" and 1 or alpha)
	end
end

--[[
	The world map's legend lights up the entry of a quest mark pointed at: Quest for a "!", Turn In
	for a "?" (UI/MapLegend.lua), as the journal's other pins do; In Progress for an objective's mark under way,
	Quest for a faded one (its quest still to take), and for a machine to use again (its repeatable step to take).
]]
local function LegendKind(mark)
	if mark.kind == "turnin" then return "turnin" end
	if mark.kind == "objective" and not mark.faded then return "inprogress" end
	return "quest"
end

function QuestMap:LegendEnter(mark)
	ns.MapLegend:PinEnter(LegendKind(mark))
end

function QuestMap:LegendLeave()
	ns.MapLegend:PinLeave("quest")
	ns.MapLegend:PinLeave("turnin")
	ns.MapLegend:PinLeave("inprogress")
end

-- also: the other quests of its name the mark stands for (QuestMap:MarksOn). The mark's own dungeon comes
-- first, with "ready to hand in" right under it when its quest is (the one the "?" is for), then the
-- others' dungeons, in gray.
local function DungeonLine(instance)
	local kind = instance.kind == "raid" and L.QUESTMAP_RAID_QUEST or L.QUESTMAP_DUNGEON_QUEST
	return string.format(kind, instance.name)
end

-- Why a quest can't be taken yet, in red: each line of QuestsPanel:Requirements (worked out here, as the tooltip shows,
-- not for every mark drawn), else its lock line.
local function AddRequirements(quest, mark)
	local lines = ns.QuestsPanel:Requirements(quest)
	if not lines[1] then lines = { mark.locked } end
	for _, line in ipairs(lines) do GameTooltip:AddLine(line, RED[1], RED[2], RED[3], true) end
end

-- A machine's card (a spot's input or output), in the client's words once it has them.
local function CardName(item)
	return ItemName({ item = item.item, itemName = item.itemName }) or ""
end

-- What to do at an objective's spot, after the game's dash: "- Take the Lorgalis Manuscript" (its item, "Take The
-- Book of Ur" where the name takes no "the", "Take “Of Love and Family”" for a title, quoted: in the language's
-- quotation marks, QUESTMAP_TITLE_QUOTED), "- Use the Scarlet Archive", "- Explore this place". A machine's, what goes
-- in, then what comes out, in their short words and no dash: "Yellow > Blue" (each one's short, a key of the strings:
-- the owner's words of 2026-11-12, "make the tooltip say blue > red").
local function ObjectiveLine(instance, spot)
	local text
	local into = spot.input and spot.input.short and L[spot.input.short]
	local out = spot.output and spot.output.short and L[spot.output.short]
	if spot.act == "use" and into and out then
		return string.format(L.QUESTMAP_OBJECTIVE_STEP, into, out)
	elseif spot.act == "explore" then
		text = L.QUESTMAP_OBJECTIVE_EXPLORE
	elseif spot.act == "use" then
		text = string.format(L.QUESTMAP_OBJECTIVE_USE, spot.name or "")
	else
		local name = ItemName(spot) or spot.name or ""
		if spot.quoted then name = string.format(L.QUESTMAP_TITLE_QUOTED, name) end
		local take = (spot.article == false or spot.quoted) and L.QUESTMAP_OBJECTIVE_TAKE_NAMED or L.QUESTMAP_OBJECTIVE_TAKE
		text = string.format(take, name)
	end
	return L.QUESTMAP_OBJECTIVE_DASH .. text
end

-- An objective's mark: what stands there (white), its quest (gold), what to do there, what the player still needs to
-- take the quest (red), then the click lines. A place to explore has no name of its own: the quest heads it.
local function ShowObjectiveTooltip(instance, quest, mark, clickLines)
	local name = mark.spot.name
	if name then
		GameTooltip:SetText(name, 1, 1, 1)
		GameTooltip:AddLine(quest.name, 1, 0.82, 0)
	else
		GameTooltip:SetText(quest.name, 1, 0.82, 0)
	end
	GameTooltip:AddLine(ObjectiveLine(instance, mark.spot), 1, 1, 1, true)
	local note = mark.spot.note and L[mark.spot.note]
	if note then GameTooltip:AddLine(string.format(note, mark.spot.input and CardName(mark.spot.input) or ""), 0.8, 0.8, 0.8, true) end
	if mark.locked then AddRequirements(quest, mark) end
	for _, line in ipairs(clickLines) do GameTooltip:AddLine(line, 0.1, 1, 0.1) end
	GameTooltip:Show()
end

-- A machine to use again (RepeatMark): the machine (white), the quest done there (gold), that it takes another of what
-- it cleans (its item, in the client's words once it has them), then the click lines.
local function ShowRepeatTooltip(quest, mark, clickLines)
	local again = mark.again
	GameTooltip:SetText(again.spot.name or quest.name, 1, 1, 1)
	GameTooltip:AddLine(quest.name, 1, 0.82, 0)
	local item = ItemName({ item = again.item, itemName = again.itemName }) or ""
	GameTooltip:AddLine(string.format(L.QUESTMAP_REPEAT_AGAIN, item), 1, 1, 1, true)
	for _, line in ipairs(clickLines) do GameTooltip:AddLine(line, 0.1, 1, 0.1) end
	GameTooltip:Show()
end

-- where: the spot inside a dungeon a mark stands on (QuestMap:InsideMarks), whose name is the giver's or taker's
-- line there, in place of its world-map point's.
function QuestMap:ShowTooltip(owner, instance, quest, mark, clickLines, also, where)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	if mark.kind == "objective" then return ShowObjectiveTooltip(instance, quest, mark, clickLines) end
	if mark.kind == "repeat" then return ShowRepeatTooltip(quest, mark, clickLines) end
	GameTooltip:SetText(quest.name, 1, 0.82, 0)
	GameTooltip:AddLine(DungeonLine(instance), 1, 1, 1)
	if mark.kind == "turnin" then
		GameTooltip:AddLine(L.QUEST_STATUS_READY, GREEN[1], GREEN[2], GREEN[3])
	elseif mark.locked then
		AddRequirements(quest, mark)
	end
	-- Each dungeon once: parts of one chain that share a name are often of one dungeon.
	local named = { [instance] = true }
	for _, entry in ipairs(also or {}) do
		if not named[entry.instance] then
			named[entry.instance] = true
			GameTooltip:AddLine(DungeonLine(entry.instance), 0.8, 0.8, 0.8)
		end
	end
	local place = where and where.name or mark.point and mark.point.label
	if place then GameTooltip:AddLine(place, 0.8, 0.8, 0.8, true) end
	if mark.places then GameTooltip:AddLine(string.format(L.QUESTMAP_ONE_OF, mark.places), 0.8, 0.8, 0.8, true) end
	for _, line in ipairs(clickLines) do GameTooltip:AddLine(line, 0.1, 1, 0.1) end
	GameTooltip:Show()
end

-- An inside mark pointed at (UI/DungeonMap.lua's QuestSpot): the objective mark's inner glow, as the game's own lights
-- up; its tooltip, with the click line that opens the quest; its legend entry lit.
function QuestMap:InsideEnter(spot)
	local mark = spot.mark
	if mark.kind == "objective" then (SpotIcon(mark.spot) and spot.Highlight or spot.Glow):Show() end
	self:ShowTooltip(spot, spot.instance, spot.quest, mark, { L.QUESTMAP_LEFT_CLICK }, nil, spot.where)
	self:LegendEnter(mark)
end

function QuestMap:InsideLeave(spot)
	spot.Glow:Hide()
	spot.Highlight:Hide()
	GameTooltip:Hide()
	self:LegendLeave()
end

-- Opens the quest in the journal, putting the world map away first (out of combat only).
function QuestMap:Open(instance, quest)
	ns.PlaySoundKit("IG_SPELLBOOK_OPEN")
	if WorldMapFrame and WorldMapFrame:IsShown() and not InCombatLockdown() and type(HideUIPanel) == "function" then
		pcall(HideUIPanel, WorldMapFrame)
	end
	ns.QuestsPanel:Open(instance, quest)
end

------------------------------------------------------------------------------------------
-- The quest badge on a boss
------------------------------------------------------------------------------------------

--[[
	A boss a quest has business with (his questLinks, worked out from the quest data: Data/Generated/QuestLinks.lua) wears
	the game's own quest badge, the one its target frame puts at the foot of a quest boss's portrait (BADGE_ATLAS, its
	TargetFrame.xml read in Forever's client files 2026-11-11; the atlas is in its tables, not yet seen in a running
	game): on his pins on the dungeon maps (UI/DungeonMap.lua's BuildBossPin and SetBossPin) and on his button in the
	journal's boss list (UI/EncounterPage.lua), at BADGE_SIZE. It follows the quest log, as the marks inside do (the
	owner's call of 2026-11-11; BossMark):
	  full    a quest under way he is still needed for (none once what he drops for it is in the bags, or the log counts
	          his part done: PartDone); one he gives, or that starts from his drop, once taken and under way (the
	          owner's call at the 0.39.20 release), all of these only with the game's Quest Objectives filter on; one
	          ready to hand in to him
	  faded   one he is needed for, gives, or that starts from his drop, not taken yet, where its "!" inside would show
	          (Mark: the legend's Quest entry, not grey for the player's level), grey while it can't be taken yet, at
	          any level ("Requires level X")
	  none    done; ready to hand in elsewhere (its "?" takes over); his part done; a start whose item is in the bags,
	          not taken yet (his part done)
	The badge is as bright as the brightest of his quests (StyleBadge). His tooltip adds each, in the dungeon's quest
	order: the quest (gold), what he is to it (BadgeLine), why it can't be taken yet (red: AddRequirements).
]]
local BADGE_ATLAS = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest"
-- Where the client lacks it: the "!" the map's quest givers wear, else the gossip window's own "!".
local BADGE_FILE = "Interface\\GossipFrame\\AvailableQuestIcon"
-- The game's size for it (20, its atlas's own) on the boss list's portraits, near the target frame's; a little larger
-- than that size's share of the pins' smaller portraits, so that it still reads on the map.
local BADGE_SIZE = { list = 20, pin = 16 }

-- A dungeon's quest by its id, from a table kept for each list of quests (a list changed is a new table).
local questsByID = setmetatable({}, { __mode = "k" })

local function InstanceQuest(instance, questID)
	local list = instance.quests or {}
	local byID = questsByID[list]
	if not byID then
		byID = {}
		for _, quest in ipairs(list) do byID[quest.questID] = byID[quest.questID] or quest end
		questsByID[list] = byID
	end
	return byID[questID]
end

-- Whether the player is done with a boss for a quest under way: what he drops for it is in the bags, or the quest log
-- counts his part done (the objective that names his item, or him).
local function PartDone(quest, boss, link)
	if link.item and InBags(link.item) then return true end
	-- (a list with no gap: a kill has no item, and a list starting with nil names nothing to ipairs)
	local names = {}
	if link.item then names[#names + 1] = ItemName(link) end
	names[#names + 1] = boss.name
	names[#names + 1] = boss.enName
	return LoggedDone(quest, names)
end

--[[
	What a boss's badge shows for one of his quests now (the rules above), or nil: { faded, locked }, as
	an objective's mark has them (ObjectiveMark). link: one of his questLinks.
]]
function QuestMap:BossMark(quest, boss, link)
	local act = link.act
	if act == "kill" or act == "drop" then
		local status = ns.QuestsPanel:Status(quest)
		if status == "active" then
			-- (the game's Quest Objectives filter, as for the marks of things to loot)
			if not ns.MapLegend.Shows("inprogress") or PartDone(quest, boss, link) then return nil end
			return {}
		end
		if status ~= "available" and status ~= "locked" then return nil end
		local start = self:Mark(quest, true)
		if not (start and start.kind == "start") then return nil end
		return { faded = true, locked = start.locked }
	end
	local mark = self:Mark(quest, true)
	if act == "takes" then return mark and mark.kind == "turnin" and {} or nil end
	-- gives, start: full once taken, while under way (the owner's call at the 0.39.20 release), as the game's Quest
	-- Objectives filter lets the marks of quests under way show; before, faded where its "!" would show and as it
	-- would. A start whose item is in the bags already has nothing more to give.
	if ns.QuestsPanel:Status(quest) == "active" then return ns.MapLegend.Shows("inprogress") and {} or nil end
	if not (mark and mark.kind == "start") or (act == "start" and InBags(link.item)) then return nil end
	return { faded = true, locked = mark.locked }
end

--[[
	A quest target (boss.questTarget: Gnomeregan's Techbot, the Excavation Site's Highland Horror) is a quest's mob, on
	the map only, off the boss list (the owner's call of 2026-11-12): his pin wears the badge whatever his quests' state,
	as the mark that he is there for a quest. A quest of his to kill him or loot him for that has nothing to show now
	(done, not open to the player yet, grey for the level, his part done) is a quiet one (QUIET): grey and faded, named
	in his tooltip all the same; with no quest of the player's (the other side's), the badge is that grey one alone.
]]
local QUIET = { faded = true, quiet = true }

-- A boss's quests with something to show now, in the dungeon's quest order: { quest, link, mark }; a quest target's
-- quests to kill or loot him too, quiet where they have nothing to show (above). None for trash, a faction's standing,
-- or quests not of the player's side and class.
function QuestMap:BossQuests(instance, boss)
	local entries = {}
	if not (instance and type(boss) == "table") or boss.trash or boss.standing then return entries end
	for _, link in ipairs(boss.questLinks or {}) do
		local quest = InstanceQuest(instance, link.questID)
		if quest and ns.QuestsPanel:IsForPlayer(quest) then
			local mark = self:BossMark(quest, boss, link)
			if not mark and boss.questTarget and (link.act == "kill" or link.act == "drop") then mark = QUIET end
			if mark then entries[#entries + 1] = { quest = quest, link = link, mark = mark } end
		end
	end
	return entries
end

-- The quest a quest target's pin opens (the first of his quests to kill or loot him that is the player's), or nil: then
-- his own page (UI/DungeonMap.lua's OpenPin).
function QuestMap:TargetQuest(instance, boss)
	if not (boss and boss.questTarget) then return nil end
	for _, entry in ipairs(self:BossQuests(instance, boss)) do
		if entry.link.act == "kill" or entry.link.act == "drop" then return entry.quest end
	end
	return nil
end

--[[
	Whether a quest target (boss.questTarget: the Excavation Site's Highland Horror, a quest's mob more than a boss) is done
	by his quest, as well as by his corpse (UI/DungeonMap.lua's IsDefeated, the owner's call of 2026-11-11): what he
	drops for a quest of the player's in the bags, or that quest ready to hand in, or its log counting his part done.
]]
function QuestMap:TargetDone(instance, boss)
	for _, link in ipairs(boss.questLinks or {}) do
		if link.act == "kill" or link.act == "drop" then
			local quest = InstanceQuest(instance, link.questID)
			if quest and ns.QuestsPanel:IsForPlayer(quest) then
				local status = ns.QuestsPanel:Status(quest)
				if status == "ready" or (status == "active" and PartDone(quest, boss, link)) then return true end
			end
		end
	end
	return false
end

-- The badge on a portrait: parent's own texture, its centre on the portrait's foot (anchor's bottom, or x, y from
-- anchor's left), as the target frame wears it. size: "list" or "pin".
function QuestMap:BuildBadge(parent, size, anchor, x, y)
	local badge = parent:CreateTexture(nil, "OVERLAY", nil, size == "pin" and 3 or 0)
	badge:SetSize(BADGE_SIZE[size], BADGE_SIZE[size])
	if x then
		badge:SetPoint("CENTER", anchor, "LEFT", x, y)
	else
		badge:SetPoint("CENTER", anchor, "BOTTOM")
	end
	badge:Hide()
	return badge
end

-- A badge drawn for a boss now: shown as bright as the brightest of his quests (a full one, a faded one), grey
-- while every one of them can't be taken yet or is quiet (QUIET); hidden with none, but on a quest target, whose badge
-- is grey and faded then. Returns his quests (BossQuests).
function QuestMap:StyleBadge(badge, instance, boss)
	local entries = self:BossQuests(instance, boss)
	if #entries == 0 and not (type(boss) == "table" and boss.questTarget) then
		badge:Hide()
		return entries
	end
	local alpha, locked = 0, true
	for _, entry in ipairs(entries) do
		local mark = entry.mark
		local dim = (mark.locked or mark.quiet) and LOCKED_ALPHA or 1
		alpha = math.max(alpha, (mark.faded and OBJECTIVE_FADED_ALPHA or 1) * dim)
		locked = locked and (mark.locked ~= nil or mark.quiet == true)
	end
	if #entries == 0 then alpha = OBJECTIVE_FADED_ALPHA * LOCKED_ALPHA end
	if ns.AtlasExists(BADGE_ATLAS) then
		badge:SetAtlas(BADGE_ATLAS)
	elseif ns.AtlasExists(START_ATLAS) then
		badge:SetAtlas(START_ATLAS)
	else
		badge:SetTexture(BADGE_FILE)
		badge:SetTexCoord(0, 1, 0, 1)
	end
	badge:SetDesaturated(locked)
	badge:SetAlpha(alpha)
	badge:Show()
	return entries
end

-- An item's name with no "the" before it in English: one of someone's ("Razorflank's Medallion"), one that has its own
-- article ("An Unsent Letter", "The Emerald Dream"), or one the link says so of (article = false: "Ironfel").
local function Named(link, name)
	return link.article == false or name:find("'s ", 1, true) ~= nil or name:find("^The ") ~= nil
		or name:find("^An? ") ~= nil
end

--[[
	What a boss is to a quest, in his tooltip (the owner's lines of 2026-11-11): "Kill for this quest", "Drops the Horrible
	Rootcore", "Drops the Titan Relic: it starts a quest"; one who gives or takes it there, "Gives this quest" and "Hand it
	in here", or by name for someone else at his spot ("Zaetar's Spirit gives this quest here").
]]
local function BadgeLine(instance, link)
	local act = link.act
	if act == "kill" then return L.QUEST_BADGE_KILL end
	if act == "drop" or act == "start" then
		local name = ItemName(link) or ""
		local named = Named(link, name)
		if act == "start" then
			return string.format(named and L.QUEST_BADGE_STARTS_NAMED or L.QUEST_BADGE_STARTS, name)
		end
		return string.format(named and L.QUEST_BADGE_DROPS_NAMED or L.QUEST_BADGE_DROPS, name)
	end
	local who = link.who
	if act == "gives" then return who and string.format(L.QUEST_BADGE_GIVES_WHO, who) or L.QUEST_BADGE_GIVES end
	return who and string.format(L.QUEST_BADGE_TAKES_WHO, who) or L.QUEST_BADGE_TAKES
end

-- A boss's quests in his tooltip (entries: BossQuests'). Returns whether it added any.
function QuestMap:AddBadgeLines(instance, boss, entries)
	entries = entries or self:BossQuests(instance, boss)
	for _, entry in ipairs(entries) do
		-- (with its part where the Quests tab numbers it: two parts of one name may stand here)
		GameTooltip:AddLine(ns.QuestsPanel:PartName(entry.quest), 1, 0.82, 0)
		GameTooltip:AddLine(BadgeLine(instance, entry.link), 1, 1, 1, true)
		if entry.mark.locked then AddRequirements(entry.quest, entry.mark) end
	end
	return #entries > 0
end

------------------------------------------------------------------------------------------
-- The marks on Blizzard's world map
------------------------------------------------------------------------------------------

AegisJournalQuestPinMixin = {}
local PinMethods = {
	ShowMapLegendGlow = ns.DungeonMap.ShowMapLegendGlow,
	HideMapLegendGlow = ns.DungeonMap.HideMapLegendGlow,
}

-- Both buttons belong to the mark: a right click sets the waypoint instead of zooming out.
function PinMethods:ShouldMouseButtonBePassthrough() return false end

function PinMethods:OnLoad()
	self.Texture = self:CreateTexture(nil, "ARTWORK")
	self.Texture:SetAllPoints()
	self.HighlightTexture = self:CreateTexture(nil, "HIGHLIGHT")
	self.HighlightTexture:SetAllPoints()
	self.HighlightTexture:SetBlendMode("ADD")
	self:SetScalingLimits(1, 1.0, 1.2)
	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_OFFER")
end

function PinMethods:OnAcquired(instance, quest, mark, x, y, also)
	self.instance, self.quest, self.mark, self.also = instance, quest, mark, also
	self:HideMapLegendGlow()
	QuestMap:SetMarkTexture(self.Texture, mark)
	QuestMap:SetMarkTexture(self.HighlightTexture, mark, HIGHLIGHT_ALPHA)
	self:SetPosition(x, y)
end

function PinMethods:OnMouseEnter()
	ns.DungeonMap:SetAreaLabel(self, self.quest.name, self.instance.name)
	QuestMap:ShowTooltip(self, self.instance, self.quest, self.mark, { L.QUESTMAP_LEFT_CLICK, L.ENTRANCE_RIGHT_CLICK },
		self.also)
	QuestMap:LegendEnter(self.mark)
end

function PinMethods:OnMouseLeave()
	ns.DungeonMap:ClearAreaLabel(self)
	GameTooltip:Hide()
	QuestMap:LegendLeave()
end

function PinMethods:OnMouseClickAction(button)
	if button == "RightButton" then
		local point = self.mark.point
		local title = point.label or self.quest.name
		ns.DungeonMap:SetWaypointAt(point.mapID, point.x, point.y, title, string.format(L.QUESTMAP_WAYPOINT_SET, self.quest.name))
		return
	end
	QuestMap:Open(self.instance, self.quest)
end

local ProviderMethods = {}

function ProviderMethods:RemoveAllData()
	ns.CanvasPins:ReleaseAll(QUEST_PIN_TEMPLATE)
end

function ProviderMethods:RefreshAllData()
	self:RemoveAllData()
	local map = self:GetMap()
	local mapID = map:GetMapID()
	if not mapID then return end
	local clientMarks = {}
	if map.EnumeratePinsByTemplate then
		for _, template in ipairs(CLIENT_TEMPLATES) do
			for pin in map:EnumeratePinsByTemplate(template) do
				if pin.questID then clientMarks[pin.questID] = true end
			end
		end
	end
	for _, entry in ipairs(QuestMap:MarksOn(mapID)) do
		if not clientMarks[entry.quest.questID] then
			ns.CanvasPins:Acquire(map, QUEST_PIN_TEMPLATE, entry.instance, entry.quest, entry.mark, entry.x, entry.y, entry.also)
		end
	end
end

function QuestMap:SetUp()
	if provider then return true end
	if not (WorldMapFrame and WorldMapFrame.AddDataProvider and MapCanvasDataProviderMixin and MapCanvasPinMixin) then
		return false
	end
	-- A frame of the journal's own on the map's canvas (UI/CanvasPins.lua).
	Mixin(AegisJournalQuestPinMixin, MapCanvasPinMixin, ns.CanvasPins.Methods, PinMethods)
	provider = CreateFromMixins(MapCanvasDataProviderMixin, ProviderMethods)
	WorldMapFrame:AddDataProvider(provider)
	return true
end

-- The marks follow the quest log and the player's level (a grey "!" turns normal once its quest opens, and
-- one shows once its level is within two of theirs), and the bosses' badges and the marks of things looted inside the
-- bags too (what a boss drops for a quest, or a chest holds, looted: BAG_UPDATE_DELAYED, once a burst of bag changes is
-- over): redrawn once a moment after any changes, if a map is open; the boss list's badges, if the journal is. The bags
-- alone redraw only those (bagsOnly): the dungeon's map and the boss list, not the world map's quest marks, which no
-- bag changes (the review of 3cc3416). PLAYER_LEVEL_UP comes before the client has the new level; PLAYER_LEVEL_CHANGED,
-- after.
local queued, bagsOnly = false, true
local function Redraw()
	local all = not bagsOnly
	queued, bagsOnly = false, true
	if provider and WorldMapFrame and WorldMapFrame:IsShown() then
		if all then provider:RefreshAllData() end
		ns.DungeonMap:Refresh()
	end
	if ns.EncounterPage then ns.EncounterPage:PaintQuestBadges() end
end

-- Drawn again now (a legend switch).
function QuestMap:Refresh()
	bagsOnly = false
	Redraw()
end

local events = CreateFrame("Frame")
ns.RegisterEvents(events, "PLAYER_LOGIN", "QUEST_LOG_UPDATE", "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED",
	"PLAYER_LEVEL_UP", "PLAYER_LEVEL_CHANGED", "BAG_UPDATE_DELAYED")
events:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		QuestMap:SetUp()
		return
	end
	if event ~= "BAG_UPDATE_DELAYED" then bagsOnly = false end
	if not queued then
		queued = true
		C_Timer.After(REFRESH_DELAY, Redraw)
	end
end)
