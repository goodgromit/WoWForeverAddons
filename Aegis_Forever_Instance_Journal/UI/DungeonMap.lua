local _, ns = ...
local L = ns.L

--[[
	Dungeon maps on Blizzard's world map (M).

	Classic dungeons have maps of their own in the client (uiMapIDs such as the Deadmines'
	291 and 292). Where the world map can show one, it does as the player is inside, with the
	player's arrow and its own floor menu, and the journal's boss pins are added on top as a map
	data provider, the way retail's journal does it.

	Forever's own dungeons have no map in the client, and the client will not say where the
	player is inside them. Their map (Media/Maps) is laid over the world map's canvas instead,
	with the same pins and the area the player is in lit up, whenever the player is inside
	one or the journal's Show Map asks for it. A classic dungeon whose map this client cannot
	show gets the same overlay, drawn from the client's own map tiles, and so does any dungeon
	the journal's Show Map asks for: it is drawn over the map that shows, which the journal
	never turns (the rule above OpenWorld). Right-click the overlay to see the world map beneath.

	Boss pins: the creature's portrait in the journal's round frame, dimmed and crossed out
	once killed on this run; a click opens the boss in the journal. A boss one of the player's
	quests needs wears the game's quest badge at his portrait's foot (UI/QuestMap.lua's StyleBadge).
]]

local DungeonMap = {}
ns.DungeonMap = DungeonMap

local BOSS_PIN_TEMPLATE = "AegisJournalBossPinTemplate"
local SHEET = "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
-- Retail's EncounterJournalPinTemplate cuts of the journal sheet.
local PIN_NORMAL = { 0.84960938, 0.97070313, 0.42871094, 0.48828125 }
local PIN_PUSHED = { 0.77734375, 0.89843750, 0.26953125, 0.32910156 }
local PIN_HIGHLIGHT = { 0.68945313, 0.81054688, 0.33300781, 0.39257813 }
local PIN_WIDTH, PIN_HEIGHT, PORTRAIT_SIZE = 50, 49, 36
-- The pins' size, for the quest marks kept clear of them (UI/QuestMap.lua's ClearOfPins) and the tests.
DungeonMap.PIN_WIDTH, DungeonMap.PIN_HEIGHT = PIN_WIDTH, PIN_HEIGHT
local NO_PORTRAIT_SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local DEFEATED_ATLAS = "Map-MarkedDefeated"
local TRANSITION_HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"

-- A classic map's tiles: 4 x 3 squares of 256, of which the top-left 1002 x 668 is the map.
local TILE_COLUMNS, TILE_ROWS, TILE_SIZE = 4, 3, 256
local TILE_MAP_WIDTH, TILE_MAP_HEIGHT = 1002, 668
-- Above other addons' dungeon overlays on the same canvas (MapUtils draws at 3000).
local OVERLAY_LEVEL = 5000
local DUNGEON_ATLAS, RAID_ATLAS = "Dungeon", "Raid"
-- What answers the mouse on a door or cave pin: the icon itself. The client's atlases draw it with
-- room around it, and a pin the atlas's size caught the cursor well off the swirl (a player's
-- report, 2026-10-20): the pin is this size, its art keeps its own, centred over it.
local PIN_HIT_SIZE = 22
-- The player's arrow on a sub-map's picture, and how often it follows the player.
local PLAYER_ARROW_ATLAS, PLAYER_ARROW_FILE = "WorldMapArrow", "Interface\\WorldMap\\WorldMapArrow"
local PLAYER_ARROW_SIZE, PLAYER_ARROW_SECONDS = 24, 0.1
-- Where an area's levels meet (Blackrock Mountain's): retail's map links between floors, a door with
-- an arrow up or down the levels' menu, the first of these the client has (Forever's has them all,
-- read in its atlas table 2026-10-27), no larger than this.
local LINK_ATLASES = {
	up = { "poi-door-up", "poi-door-arrow-up", "CaveUnderground-Up" },
	down = { "poi-door-down", "poi-door-arrow-down", "CaveUnderground-Down" },
}
local LINK_SIZE = 24
-- Retail's cave entrance, the first of these the client has: on the zones' maps, the way down to an area below
-- the zone (its pins, below); on a dungeon's map, the way down into a cave floor (a transition's icon = "cave").
local CAVE_ATLASES = { "CaveUnderground-Up", "CaveUnderground-Down" }
-- How often the player's position is followed while they are on one of an area's levels (Blackrock
-- Mountain's), on one picture placed twice (Maraudon's caves) or by a way down under the name of the
-- rooms above (Old Ironforge's, in The High Seat), map open or closed: what shows can change with no
-- new area name, and a walk crosses the north room stair's 4 yards of ring floor in about half a second.
local FOLLOW_SECONDS = 0.2

local provider, overlay
local forced, dismissed, homeMapID
local chosenFloor = {}
-- This opening of the map: follow.picked, a floor picked by the player (the menu, a way between floors,
-- the journal asking for one), and follow.key and follow.index, the floor last followed by the area the
-- player is in (follow.Floor, below). One table, as the file is at Lua's 200 locals.
local follow = {}

-- The maps of the way in (areas below a zone, a building's halls, Blackrock Mountain's levels), and
-- their doors on the world map: off with the way-in maps in the journal's style (Core/Style.lua). The
-- dungeons' own maps stay.
local function WayInsOn()
	return ns.Style:On("wayInMaps")
end

------------------------------------------------------------------------------------------
-- Which dungeon, which floor
------------------------------------------------------------------------------------------

local function Floors(instance)
	return instance and instance.map and instance.map.floors or nil
end

-- The instance the player is inside, if the journal has it.
local function CurrentInstance()
	local ok, _, _, _, _, _, _, _, instanceID = pcall(GetInstanceInfo)
	instanceID = ok and ns.Readable(instanceID) or nil
	return instanceID and ns.GetInstanceByInstanceID(instanceID) or nil
end

local floorsByMapID
local function FloorByMapID(mapID)
	if not floorsByMapID then
		floorsByMapID = {}
		for _, kind in ipairs({ "dungeon", "raid" }) do
			for _, instance in ipairs(ns.GetInstances(kind)) do
				for index, floor in ipairs(Floors(instance) or {}) do
					if floor.uiMapID then floorsByMapID[floor.uiMapID] = { instance = instance, index = index } end
				end
			end
		end
	end
	return mapID and floorsByMapID[mapID] or nil
end

--[[
	Inside a dungeon, the floor of the area the player is in: the one whose areas (Data/Authored/
	ClassicMaps.lua) hold the name the client gives (GetSubZoneText, in any language: ns.AreaIn). The
	client gives no position inside the classic dungeons, but it names their rooms (The Deadmines' cove,
	"Ironclad Cove"). Where it gives no room's name, the name the minimap shows is read instead: the
	zone's own (a room of The Deadmines with no name of its own is the mine's). Not where the map says
	roomsOnly: City of Dalaran's zone name is also one city room's (and reads as Dalaran's in four
	languages), so the minimap's name where no room is named, maybe at the sewers' way in, could turn
	the map to the city. A name of no floor's
	(one on two floors, none at all) keeps the floor last followed in this opening of the map, else
	gives nil, and the map shows what it would have. Read as the map opens and on each change of area
	while it is open (ZONE_EVENTS, below), until the player picks a floor themselves; the next opening
	follows again. Only the journal's overlay turns, never the map.
	A map marked followFromLevel (Gnomeregan's: Data/Authored/ClassicMaps.lua) opens on its whole map and
	follows only while a level floor is the one picked (this opening, or the last one): then the next room of
	another level floor turns it, and a floor picked shows until the player walks into another room
	(follow.seen, the room it was picked in: follow.Picked); with the whole map picked, it stays on it.
]]
function follow.Floor(instance)
	if instance ~= CurrentInstance() then return nil end
	local fromLevel = instance.map and instance.map.followFromLevel
	if follow.picked and not fromLevel then return nil end
	local name
	for step, fn in ipairs({ GetSubZoneText, GetMinimapZoneText }) do
		if step == 2 and instance.map and instance.map.roomsOnly then break end
		local ok, text = pcall(fn)
		text = ok and ns.Readable(text) or nil
		-- A few of the client's names end in a space ("Engineering Labs ").
		name = type(text) == "string" and text:match("^(.-)%s*$") or nil
		if name and name ~= "" then break end
	end
	if fromLevel then
		local floors, picked = Floors(instance) or {}, chosenFloor[instance.key]
		if not (floors[picked] and not floors[picked].whole) then return nil end
		-- (the room the floor was picked in, or last read: no new room, no turn)
		if follow.seen ~= nil and follow.seen == (name or "") then
			return follow.key == instance.key and follow.index or nil
		end
		follow.seen = name or ""
	end
	if name and name ~= "" then
		for index, floor in ipairs(Floors(instance) or {}) do
			if ns.AreaIn(floor.areas, name) then
				follow.key, follow.index = instance.key, index
				break
			end
		end
	end
	return follow.key == instance.key and follow.index or nil
end

-- A floor picked by the player (the menu, a way between floors) on a map that follows from a level floor: it shows
-- until the player walks into another room, the room it was picked in (follow.seen) turning nothing.
function follow.Picked(instance)
	if not (instance and instance.map and instance.map.followFromLevel) then return end
	follow.key, follow.index = nil, nil
	local ok, text = pcall(GetSubZoneText)
	text = ok and ns.Readable(text) or nil
	if type(text) ~= "string" or text:match("^%s*$") then
		ok, text = pcall(GetMinimapZoneText)
		text = ok and ns.Readable(text) or nil
	end
	follow.seen = type(text) == "string" and text:match("^(.-)%s*$") or ""
end

-- Whether Blizzard's world map can show this floor itself. A floor the journal has a picture of
-- is drawn from that picture all the same: the client's maps of the dungeons rebuilt in
-- Cataclysm mark the new bosses' rooms (Data/Authored/ClassicMaps.lua).
local native = {}
function DungeonMap:IsNative(floor)
	if not (floor and floor.uiMapID and C_Map) or floor.art then return false end
	if native[floor.uiMapID] == nil then
		local okInfo, info = pcall(C_Map.GetMapInfo, floor.uiMapID)
		local okLayers, layers = pcall(C_Map.GetMapArtLayers, floor.uiMapID)
		native[floor.uiMapID] = okInfo and info ~= nil and okLayers and type(layers) == "table" and #layers > 0
	end
	return native[floor.uiMapID]
end

function DungeonMap:HasMap(instance)
	local floors = Floors(instance)
	return floors ~= nil and #floors > 0
end

-- A dungeon the world map cannot show by itself.
local function NeedsOverlay(instance)
	local floors = Floors(instance)
	return floors ~= nil and #floors > 0 and not DungeonMap:IsNative(floors[1])
end

-- "Dungeon  Level 13-20", as the entrance pins and their area label say it.
local function EntranceDescription(instance)
	local kind = instance.kind == "raid" and L.ENTRANCE_RAID or L.ENTRANCE_DUNGEON
	if not instance.levelMin then return kind end
	return kind .. "  " .. string.format(L.LEVEL_RANGE, instance.levelMin, instance.levelMax or instance.levelMin)
end

-- Blizzard's map of a whole dungeon (whole: Blackfathom Deeps', Maraudon's) is named after the
-- dungeon, in the journal's language. A floor's own name is looked up among the levels' names
-- (L.SUBMAP_LEVELS: the Temple of Atal'Hakkar's Lower Level), else shown as written.
local function FloorName(instance, index)
	local floor = Floors(instance)[index]
	if floor.whole then return instance.name end
	local authored = instance.floorNames and instance.floorNames[index]
	if authored then return L.SUBMAP_LEVELS and L.SUBMAP_LEVELS[authored] or authored end
	if floor.uiMapID and C_Map and C_Map.GetMapInfo then
		local ok, info = pcall(C_Map.GetMapInfo, floor.uiMapID)
		if ok and info and info.name and info.name ~= "" and info.name ~= instance.name then return info.name end
	end
	return string.format(L.MAP_FLOOR, index)
end
DungeonMap.FloorName = FloorName

------------------------------------------------------------------------------------------
-- Bosses killed on this run
------------------------------------------------------------------------------------------

--[[
	By dungeon, the bosses killed on this run, kept with the character (AegisJournalCharDB.defeated) so a /reload
	or a login inside the dungeon keeps them: the owner's report of 2026-11-08, four of Blackfathom Deeps' kills gone
	after a /reload. A new run, coming in from outside, clears its dungeon's (PLAYER_ENTERING_WORLD below), unless
	the player stepped out less than SAME_RUN_SECONDS ago. Before the character's saved data is there, a table of
	the session's own.
]]
local unsaved = {}
local function Defeated()
	local db = ns.charDB
	if not db then return unsaved end
	db.defeated = db.defeated or {}
	return db.defeated
end

local function BossNamed(instance, name)
	if not (instance and name) then return nil end
	for _, boss in ipairs(instance.bosses) do
		if ns.NamedAs(boss, name) then return boss end
		for _, alias in ipairs(boss.aliases or {}) do
			if alias == name then return boss end
		end
	end
	return nil
end

-- The bosses an encounter ended for: each boss with the encounter's id where the journal knows it
-- (two where they share one fight: Sneed's Shredder and Sneed, ns.BossesForEncounter), else the one
-- the fight is named for. The client's name for a fight is not always the boss's (Magmatus's is
-- "Infurnus"), nor each boss's where two share it.
local function BossesForEncounter(instance, encounterID, name)
	local bosses = ns.BossesForEncounter(instance, encounterID)
	if #bosses == 0 then bosses[1] = BossNamed(instance, name) end
	return bosses
end

-- Half an hour: about how long the game keeps an empty instance. Coming back in sooner is taken as the same run
-- (the owner, 2026-11-10: stepping out to repair or to wait for the group cleared the marks); the game gives
-- addons no way to tell that instance from a fresh one, but for the message of a reset (below the events).
DungeonMap.SAME_RUN_SECONDS = 30 * 60

-- A run's kills show only inside its dungeon; from anywhere else the dungeon's map is clean (the owner,
-- 2026-11-10: last night's marks, seen from Stormwind, looked like a mistake). They are kept for coming back in.
-- A quest target (boss.questTarget: the Excavation Site's Highland Horror) is done by his quest as well (the owner,
-- 2026-11-11: what he drops for it in the bags, or its objective complete in the log: UI/QuestMap.lua's TargetDone).
function DungeonMap:IsDefeated(instance, boss)
	local here = CurrentInstance()
	if not (here and instance and here.instanceID == instance.instanceID) then return false end
	local killed = Defeated()[instance.key]
	if killed ~= nil and killed[boss.name] == true then return true end
	return boss.questTarget == true and ns.QuestMap ~= nil and ns.QuestMap:TargetDone(instance, boss)
end

function DungeonMap:MarkDefeated(instance, boss)
	local defeated = Defeated()
	defeated[instance.key] = defeated[instance.key] or {}
	defeated[instance.key][boss.name] = true
	-- The run block's clock and lines go by these same kills (Core/Run.lua).
	if ns.Run then ns.Run:Killed(instance, boss) end
	self:Refresh()
end

-- This run's kills in one dungeon or wing, as kept (by boss name), wherever the player is: for the run block's
-- record of its run (Core/Run.lua). Nil where none.
function DungeonMap:Kills(instance)
	return instance and Defeated()[instance.key] or nil
end

-- A new run: the kills of every part of that copy of the dungeon go, the parts walked between without a loading
-- screen (Stratholme's halves, Blackrock Spire's, Dire Maul's: Core/Run.lua's SameCopy); a Scarlet Monastery wing's
-- alone, as each is its own copy.
function DungeonMap:ClearRun(instance)
	if not instance then return end
	for _, wing in ipairs(ns.Run and ns.Run.SameCopy(instance) or {}) do
		Defeated()[wing.key] = nil
	end
	Defeated()[instance.key] = nil
end

--[[
	One of the creatures of an entry that is several at once (together, with members: the Sunken Temple's six
	balcony trolls, Data/Authored/RunTracker.lua) seen dead, by its creature id or its name: kept with the run's
	kills (as "entry#member"), and true once every one of them is, when the entry itself is marked.
]]
function DungeonMap:MemberDown(instance, boss, key)
	local defeated = Defeated()
	defeated[instance.key] = defeated[instance.key] or {}
	local killed = defeated[instance.key]
	for _, member in ipairs(boss.members or {}) do
		if key ~= nil and (member.npcID == key or member.name == key or member.clientName == key) then
			killed[boss.name .. "#" .. member.name] = true
		end
	end
	for _, member in ipairs(boss.members or {}) do
		if not killed[boss.name .. "#" .. member.name] then return false end
	end
	return true
end

--[[
	A boss the game holds no encounter for (the Excavation Site's Highland Horror, a rare) ends no
	fight, so ENCOUNTER_END never names it. Forever keeps the combat log from addons: registering
	COMBAT_LOG_EVENT_UNFILTERED, or even unregistering it, is a forbidden action, which pcall does
	not catch. So the boss is marked when the player sees him lying dead: as their target, focus or
	mouseover (as its health or flags change, as the target or mouseover changes, and once combat
	ends, should the client have kept it back during the fight), or as his corpse is looted. Known
	by his creature id where the journal knows it, else by his name. Watched only inside a dungeon
	that has such a boss.
]]
local deaths = CreateFrame("Frame")
local DEATH_EVENTS = { "UNIT_HEALTH", "UNIT_FLAGS", "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT",
	"PLAYER_REGEN_ENABLED", "LOOT_OPENED" }
local LOOKED_AT = { "target", "focus", "mouseover" }
local watched, watchedInstance

local function CreatureID(guid)
	local kind, _, _, _, _, id = strsplit("-", guid or "")
	if kind == "Creature" or kind == "Vehicle" then return tonumber(id) end
	return nil
end

local function WatchDeaths(instance)
	watched, watchedInstance = nil, instance
	for _, boss in ipairs(instance and instance.bosses or {}) do
		if not boss.encounterID and not boss.trash then
			watched = watched or {}
			if boss.npcID then watched[boss.npcID] = boss end
			watched[boss.name] = boss
			if boss.enName then watched[boss.enName] = boss end
			if boss.clientName then watched[boss.clientName] = boss end
			for _, member in ipairs(boss.members or {}) do
				if member.npcID then watched[member.npcID] = boss end
				watched[member.name] = boss
				if member.clientName then watched[member.clientName] = boss end
			end
		end
	end
	if watched then
		ns.RegisterEvents(deaths, unpack(DEATH_EVENTS))
	else
		ns.UnregisterEvents(deaths, unpack(DEATH_EVENTS))
	end
end

-- key: the creature id or name it was known by, for an entry of several (DungeonMap:MemberDown). Kept as this run's
-- kill unless it already is: by the run's own kills (Kills), not IsDefeated, which counts a quest target done by his
-- quest too (his item in the bags), and would leave his corpse unkept, so that he stood again once his quest was
-- handed in on the same run (the review of 3cc3416).
local function Fallen(boss, key)
	if boss and boss.members and not DungeonMap:MemberDown(watchedInstance, boss, key) then return end
	local killed = boss and DungeonMap:Kills(watchedInstance)
	if boss and not (killed and killed[boss.name] == true) then DungeonMap:MarkDefeated(watchedInstance, boss) end
end

-- A unit the player has at hand, if it is a watched boss lying dead. What the client keeps back
-- counts as not known.
local function LooksDead(unit)
	local ok, dead = pcall(UnitIsDead, unit)
	if not ok or ns.Readable(dead) ~= true then return end
	local id, name = CreatureID(ns.Readable(UnitGUID(unit))), ns.Readable(UnitName(unit))
	if id and watched[id] then Fallen(watched[id], id) else Fallen(watched[name or ""], name) end
end

deaths:SetScript("OnEvent", function(_, event, unit)
	if not (watched and watchedInstance) then return end
	if event == "LOOT_OPENED" then
		-- Each slot names the corpses it comes from: guid, count, guid, count, ...
		for slot = 1, GetNumLootItems() do
			local sources = { pcall(GetLootSourceInfo, slot) }
			for index = 2, sources[1] and #sources or 0, 2 do
				local id = CreatureID(ns.Readable(sources[index]))
				Fallen(watched[id or 0], id)
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		for _, looked in ipairs(LOOKED_AT) do LooksDead(looked) end
	elseif event == "PLAYER_TARGET_CHANGED" then
		LooksDead("target")
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		LooksDead("mouseover")
	elseif type(unit) == "string" then
		LooksDead(unit)
	end
end)

------------------------------------------------------------------------------------------
-- Boss pins
------------------------------------------------------------------------------------------

local function Masked(owner, texture)
	if owner.CreateMaskTexture and texture.AddMaskTexture then
		local mask = owner:CreateMaskTexture()
		mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetAllPoints(texture)
		texture:AddMaskTexture(mask)
	end
	return texture
end

local function SetSheetTexture(texture, coords)
	texture:SetTexture(SHEET)
	texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
end

--[[
	A boss's round face, as its pin shows it: the creature's portrait masked round, the target skull on a dark disc
	for one the client has no portrait of, and, once killed, a shade and the map's defeated mark. Built on any frame
	at any size (the pin's portrait is PORTRAIT_SIZE): the run block's circles are the same faces (UI/RunTracker.lua).
]]
function DungeonMap.BuildFace(owner, size)
	owner.Portrait = Masked(owner, owner:CreateTexture(nil, "BACKGROUND"))
	owner.Portrait:SetPoint("CENTER")
	owner.Skull = owner:CreateTexture(nil, "ARTWORK")
	owner.Skull:SetTexture(NO_PORTRAIT_SKULL)
	owner.Skull:SetPoint("CENTER")
	owner.Skull:Hide()
	owner.Shade = Masked(owner, owner:CreateTexture(nil, "OVERLAY"))
	owner.Shade:SetPoint("TOPLEFT", owner.Portrait, "TOPLEFT", -1, 1)
	owner.Shade:SetPoint("BOTTOMRIGHT", owner.Portrait, "BOTTOMRIGHT", 1, -1)
	owner.Shade:SetColorTexture(0, 0, 0, 0.4)
	owner.Cross = owner:CreateTexture(nil, "OVERLAY", nil, 2)
	owner.Cross:SetAtlas(DEFEATED_ATLAS, true)
	DungeonMap.SizeFace(owner, size)
end

-- The face at another size, all of it in proportion to the pin's: the skull 20 on its 36, the mark at its own 32,
-- its corner 4 past the 50 x 49 pin's (so 11 and 10.5 past the portrait's).
function DungeonMap.SizeFace(owner, size)
	local scale = size / PORTRAIT_SIZE
	owner.Portrait:SetSize(size, size)
	owner.Skull:SetSize(20 * scale, 20 * scale)
	owner.Cross:SetSize(32 * scale, 32 * scale)
	owner.Cross:ClearAllPoints()
	owner.Cross:SetPoint("BOTTOMRIGHT", owner.Portrait, "BOTTOMRIGHT", 11 * scale, -10.5 * scale)
end

-- The face of a boss, alive or dead.
function DungeonMap.ShowFace(owner, boss, dead)
	local hasPortrait = false
	if boss.displayID and type(SetPortraitTextureFromCreatureDisplayID) == "function" then
		hasPortrait = pcall(SetPortraitTextureFromCreatureDisplayID, owner.Portrait, boss.displayID)
	end
	if not hasPortrait then owner.Portrait:SetColorTexture(0.1, 0.07, 0.04, 1) end
	owner.Skull:SetShown(not hasPortrait)
	owner.Shade:SetShown(dead)
	owner.Cross:SetShown(dead)
	owner.Portrait:SetDesaturated(dead)
	owner.Skull:SetDesaturated(dead)
end

-- Retail's EncounterJournalPinTemplate, built on any button.
local function BuildBossPin(pin)
	pin:SetSize(PIN_WIDTH, PIN_HEIGHT)
	DungeonMap.BuildFace(pin, PORTRAIT_SIZE)
	-- The quest badge at the portrait's foot (UI/QuestMap.lua's BuildBadge, StyleBadge): hidden until SetBossPin shows it.
	if ns.QuestMap then pin.QuestBadge = ns.QuestMap:BuildBadge(pin, "pin", pin.Portrait) end

	pin:SetNormalTexture(SHEET)
	SetSheetTexture(pin:GetNormalTexture(), PIN_NORMAL)
	pin:SetPushedTexture(SHEET)
	SetSheetTexture(pin:GetPushedTexture(), PIN_PUSHED)
	pin:SetHighlightTexture(SHEET, "ADD")
	SetSheetTexture(pin:GetHighlightTexture(), PIN_HIGHLIGHT)
end

local function SetBossPin(pin, instance, boss)
	pin.instance, pin.boss = instance, boss
	DungeonMap.ShowFace(pin, boss, DungeonMap:IsDefeated(instance, boss))
	if pin.QuestBadge then ns.QuestMap:StyleBadge(pin.QuestBadge, instance, boss) end
end

--[[
	Where a boss may be on the map: most have one spot (mapPin); one that is not always in the
	same place (a Fanglord, a prisoner in one of several cells) gives all of them (mapPins), and
	has a pin on each. So does one shown on a dungeon's whole map as well as on its own floor's.
]]
local function BossSpots(boss)
	if boss.mapPins then return boss.mapPins end
	return boss.mapPin and { boss.mapPin } or {}
end
DungeonMap.BossSpots = BossSpots

--[[
	Those spots are maybes: each gets a smaller, faded pin, so the bosses that always stand in
	one place read first. Pointing at one lights up every spot of that boss at full size, and
	fades the other bosses' maybes further; the bosses with one spot stay as they are.
]]
local MAYBE_SCALE, MAYBE_ALPHA, MAYBE_DIMMED_ALPHA = 0.65, 0.6, 0.3

-- A boss's spots on one floor. A boss on a dungeon's whole map and on its own floor's (Blackfathom
-- Deeps', Maraudon's) has a spot on each, and is sure on both: only several on one floor are maybes.
local function SpotsOn(boss, floor)
	local count = 0
	for _, point in ipairs(BossSpots(boss)) do
		if (point.floor or 1) == floor then count = count + 1 end
	end
	return count
end

-- An entry that is several creatures at once (together = true: the Sunken Temple's six balcony
-- trolls) has a pin on each of their spots, every one sure. A boss that is one of several that
-- may come to one place (maybe = true: Blackrock Depths' arena challengers) is a maybe too.
local function IsMaybe(boss, floor)
	return boss.maybe == true or (not boss.together and SpotsOn(boss, floor) > 1)
end

-- How faded a pin is, given the boss whose spots are lit (if any).
local function MaybeAlpha(pin, litBoss)
	if not pin.maybe or pin.boss == litBoss then return 1 end
	return litBoss and MAYBE_DIMMED_ALPHA or MAYBE_ALPHA
end

local function ShowBossTooltip(pin)
	local boss = pin.boss
	GameTooltip:SetOwner(pin, "ANCHOR_LEFT")
	GameTooltip:SetText(boss.name, 1, 0.82, 0)
	if boss.level then GameTooltip:AddLine(string.format(L.MAP_LEVEL, boss.level), 1, 1, 1) end
	-- (a quest's mob, on the map only: Data/Authored/ExcavationSiteWetlands.lua, GnomereganQuests.lua)
	if boss.questTarget then GameTooltip:AddLine(L.QUEST_TARGET, 0.8, 0.8, 0.8) end
	local spots = SpotsOn(boss, pin.floor)
	if spots > 1 and not boss.together then GameTooltip:AddLine(string.format(L.MAP_ONE_OF, spots), 0.8, 0.8, 0.8, true) end
	if DungeonMap:IsDefeated(pin.instance, boss) then GameTooltip:AddLine(L.MAP_DEFEATED, 1, 0.13, 0.13) end
	if boss.description and boss.description ~= "" then GameTooltip:AddLine(boss.description, 1, 1, 1, true) end
	-- A quest target's notes on the fight, here as well as on his page, which no boss list leads to (his pin opens his
	-- quest: OpenPin)
	for _, note in ipairs(boss.questTarget and boss.notes or {}) do GameTooltip:AddLine(note, 1, 1, 1, true) end
	-- His quests, where his badge shows (UI/QuestMap.lua's AddBadgeLines).
	if pin.QuestBadge and pin.QuestBadge:IsShown() then ns.QuestMap:AddBadgeLines(pin.instance, boss) end
	GameTooltip:AddLine(L.MAP_PIN_OPEN, 0.5, 0.8, 1)
	GameTooltip:Show()
end

-- Opens the boss in the journal, putting the world map away first (out of combat only).
function DungeonMap:OpenBoss(instance, boss)
	ns.PlaySoundKit("IG_SPELLBOOK_OPEN")
	if WorldMapFrame and WorldMapFrame:IsShown() and not InCombatLockdown() and type(HideUIPanel) == "function" then
		pcall(HideUIPanel, WorldMapFrame)
	end
	ns.Journal:Show()
	ns.Journal:OpenBoss(instance, boss)
end

-- What a click on a boss's pin opens: a quest target's quest (a quest's mob on the map only, off the boss list: the
-- owner's call of 2026-11-12; UI/QuestMap.lua's TargetQuest), else the boss's page (his own, for a quest target with no
-- quest of the player's).
function DungeonMap:OpenPin(instance, boss)
	local quest = ns.QuestMap and ns.QuestMap:TargetQuest(instance, boss)
	if quest then
		ns.QuestMap:Open(instance, quest)
	else
		self:OpenBoss(instance, boss)
	end
end

-- The template's mixin, which the map canvas pin mixin joins once the world map exists. Like every pin
-- the journal puts on the map, it is a frame of the journal's own on the map's canvas (UI/CanvasPins.lua).
AegisJournalBossPinMixin = {}

local BossPinMethods = {}

function BossPinMethods:OnLoad()
	BuildBossPin(self)
	self:SetScalingLimits(1, 0.7, 1.3)
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ENCOUNTER")
end

function BossPinMethods:OnAcquired(instance, boss, floor)
	SetBossPin(self, instance, boss)
	self.floor = floor
	self.maybe = IsMaybe(boss, floor)
	self:SetScalingLimits(self.maybe and MAYBE_SCALE or 1, 0.7, 1.3)
	self:SetAlpha(MaybeAlpha(self, nil))
end

-- On the client's own map the lit spots only lose their fading; their size stays.
local function LightNativePins(litBoss)
	for pin in ns.CanvasPins:Enumerate(BOSS_PIN_TEMPLATE) do pin:SetAlpha(MaybeAlpha(pin, litBoss)) end
end

function BossPinMethods:OnMouseEnter()
	if self.maybe then LightNativePins(self.boss) end
	ShowBossTooltip(self)
end

function BossPinMethods:OnMouseLeave()
	GameTooltip:Hide()
	if self.maybe then LightNativePins(nil) end
end

function BossPinMethods:OnMouseClickAction(button)
	if button == "LeftButton" then DungeonMap:OpenPin(self.instance, self.boss) end
end

------------------------------------------------------------------------------------------
-- The overlay, for dungeons the world map cannot show
------------------------------------------------------------------------------------------

local function Canvas()
	if not WorldMapFrame then return nil end
	if WorldMapFrame.GetCanvas then
		local ok, canvas = pcall(WorldMapFrame.GetCanvas, WorldMapFrame)
		if ok and canvas then return canvas end
	end
	return WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child or nil
end

local function Container()
	return WorldMapFrame and WorldMapFrame.ScrollContainer or WorldMapFrame
end

local function Dismiss()
	dismissed, forced = true, nil
	DungeonMap:Refresh()
end

-- A level's name, in the journal's language (its English name is the key: retail's for the ring
-- and the way down, the client's for the middle level's corridor).
local function LevelName(name)
	return L.SUBMAP_LEVELS and L.SUBMAP_LEVELS[name] or name
end

--[[
	A place's other pictures (views: Maraudon's caves, on the one picture of both or on either
	cave's own map), a menu of them as an area's levels have: the keys of their sub-maps, the
	first the picture that shows by itself. The others are views only (viewOnly): never the
	player's map, with no way in of their own on the zone maps, shown only when picked from the
	menu. Another placement of the first picture (the purple cave's) is its entry too.
]]
local function ViewIndex(subMap)
	for index, key in ipairs(subMap.views) do
		if key == subMap.key then return index end
	end
	return 1
end

-- A view's name in the menu: its sub-map's, in the journal's language (SUBMAP_NAMES).
local function ViewName(views, index)
	local view = ns.GetSubMap(views[index])
	return view and view.name or views[index]
end

-- The floor menu's choices: an area's levels (Blackrock Mountain), a place's views (Maraudon's
-- caves), or a dungeon's floors.
local function FillFloorMenu(_, root)
	local subMap = overlay.subMap
	if subMap and subMap.levels then
		for index, name in ipairs(subMap.levels) do
			root:CreateRadio(LevelName(name),
				function() return overlay.subMap and overlay.subMap.level == index end,
				function() DungeonMap:ShowLevel(subMap, index) end)
		end
		return
	end
	if subMap and subMap.views then
		for index in ipairs(subMap.views) do
			root:CreateRadio(ViewName(subMap.views, index),
				function()
					local shown = overlay.subMap
					return shown ~= nil and shown.views == subMap.views and ViewIndex(shown) == index
				end,
				function() DungeonMap:ShowView(subMap, index) end)
		end
		return
	end
	local instance = overlay.instance
	if not instance then return end
	for index in ipairs(Floors(instance)) do
		root:CreateRadio(FloorName(instance, index),
			function() return overlay.floor == index end,
			function()
				chosenFloor[instance.key], follow.picked = index, true
				follow.Picked(instance)
				DungeonMap:Refresh()
			end)
	end
end

-- The journal's own menus (UI/Art.lua's ns.Menus), never the game's: one the journal built there tainted the
-- game's unit menus after it (the owner's taint log of 2026-11-08).
local function CreateFloorDropdown()
	local dropdown = ns.Menus:NewDropdown(Container(), 200)
	-- Forever keeps the map pin button in the canvas's top-left corner; the menu sits beside it.
	local pinButton = rawget(WorldMapFrame, "WorldMapTrackingPinButton")
	if pinButton then
		dropdown:SetPoint("LEFT", pinButton, "RIGHT", 6, 0)
	else
		dropdown:SetPoint("TOPLEFT", Container(), "TOPLEFT", 6, -6)
	end
	dropdown:SetFrameLevel(overlay:GetFrameLevel() + 100)
	dropdown:SetupMenu(FillFloorMenu)
	dropdown:Hide()
	return dropdown
end

--[[
	The floor menu as one more step of the world map's location bar, after the zone's ("World >
	Eastern Kingdoms > Burning Steppes > Blackrock Spire"), its choices on the step's arrow, as the
	bar's own steps have theirs. The step is a button of the bar's own template, but the journal's,
	beside the bar's list of steps and never in it: the bar's menus clear every step after their
	own, and the world map takes no taint from the journal this way (it only reads the bar, and
	sets its own button and the zone step's look). The zone's step turns back into a link, as the
	bar's earlier steps are, its click showing the zone's own map. Each time the bar lays itself
	out again (NavBar_CheckLength, on a new map) or changes size, the step follows its last.
	The bar counts only its own steps when it folds them into its overflow button, so the step
	fits in the room they leave (counted as the bar counts, by their widths), its name cut short
	(the whole of it on the mouse) when it must be; with too little room, the bar folded already,
	or no bar, the menu stays beside the map pin button. Over a zone not its own (shown from the
	journal where the player stands, its door not on that zone or unknown) it is a step all the same,
	as the pre-instance maps' is, and names its place after the floor ("Ironforge > The Sewers (City
	of Dalaran)", StepName), so it never reads as a level of that zone; the floor first, so a name
	cut short still shows it.
]]
local CRUMB_EXTRA = 53         -- a step's width beyond its text, with a menu arrow (NavBar_AddButton)
local CRUMB_TIP = 21           -- the step's own arrow's tip, past its right edge (arrowUp)
local CRUMB_MIN_TEXT = 40      -- less room for its name than this: the menu beside the pin button
local crumb, menuText, crumbZone
local hookedSteps = setmetatable({}, { __mode = "k" })

-- The map's location bar and its last step, the zone's.
local function LocationBar()
	local bar = WorldMapFrame and rawget(WorldMapFrame, "NavBar")
	local steps = bar and rawget(bar, "navList")
	return bar, steps and steps[#steps], steps
end

-- The zone's step clicked: known before its click is handled (PreClick), as handling it may lay
-- the bar out again and hand its button to another step.
local function ZoneStepClicked(self, button)
	if self == crumbZone and menuText and button == "LeftButton" then Dismiss() end
end

-- The room the bar's shown steps leave after them, counted by their widths as the bar counts.
local function RoomLeft(bar, steps)
	local used = 0
	for index, step in ipairs(steps) do
		if step:IsShown() then
			used = used + step:GetWidth()
			if index < #steps then used = used + (step.xoffset or 0) end
		end
	end
	return bar:GetWidth() - used - (steps[#steps].xoffset or 0) - CRUMB_TIP
end

-- The zone's step as the bar leaves its last: the current one, not a link.
local function RestoreZoneStep()
	local _, last = LocationBar()
	if crumbZone and crumbZone == last then
		crumbZone:Disable()
		if crumbZone.selected then crumbZone.selected:Show() end
	end
	crumbZone = nil
end

local function MakeCrumb(bar)
	local ok, step = pcall(CreateFrame, "Button", nil, bar, rawget(bar, "template") or "NavButtonTemplate")
	if not (ok and step and step.text and step.MenuArrowButton) then return nil end
	-- Not the template's own menu (NavButtonTemplate_OnShow): it would clear the bar's steps. Its arrow is the
	-- journal's own, with the journal's menu (ns.Menus:StepArrow): the template's opens the game's menu, which
	-- asks the step for a list it doesn't have (the owner's error on Shadowfang Keep's floor step, 2026-11-08).
	step:SetScript("OnShow", nil)
	ns.Menus:StepArrow(step, FillFloorMenu):Show()
	-- The step the map is at, as the bar's last one is; a name cut short, whole on the mouse.
	if step.selected then step.selected:Show() end
	step:Disable()
	if type(NavBar_ButtonOnEnter) == "function" then step:SetScript("OnEnter", NavBar_ButtonOnEnter) end
	if type(NavBar_ButtonOnLeave) == "function" then step:SetScript("OnLeave", NavBar_ButtonOnLeave) end
	return step
end

-- The step on the bar for menuText, if the bar has room for it: true when it shows.
local function PlaceCrumb()
	local bar, last, steps = LocationBar()
	if not (menuText and last) then return false end
	local overflow = rawget(bar, "overflowButton")
	if overflow and overflow:IsShown() then return false end
	crumb = crumb or MakeCrumb(bar)
	if not crumb then return false end
	crumb:SetText(menuText)
	crumb.text:SetWidth(0)
	local full = crumb.text:GetStringWidth()
	local width = math.min(full, RoomLeft(bar, steps) - CRUMB_EXTRA)
	if width < math.min(full, CRUMB_MIN_TEXT) then
		crumb:Hide()
		return false
	end
	crumb.text:SetWidth(width < full and width or 0)
	crumb:SetWidth(width + CRUMB_EXTRA)
	crumb:ClearAllPoints()
	crumb:SetPoint("LEFT", last, "RIGHT", last.xoffset or 0, 0)
	-- Under the zone's step, whose arrow's tip lies over it, as each step's does over the next.
	crumb:SetFrameLevel(math.max(last:GetFrameLevel() - 1, bar:GetFrameLevel()))
	ns.Menus:Generate(crumb.JournalArrow)
	crumb:Show()
	if crumbZone and crumbZone ~= last then RestoreZoneStep() end
	last:Enable()
	if last.selected then last.selected:Hide() end
	if not hookedSteps[last] then
		hookedSteps[last] = true
		last:HookScript("PreClick", ZoneStepClicked)
	end
	crumbZone = last
	return true
end

-- The floor menu where it fits: the bar's step, else beside the map pin button, else none.
local function UpdateFloorMenu()
	local menuOnBar = menuText ~= nil and PlaceCrumb()
	if not menuOnBar then
		if crumb then crumb:Hide() end
		RestoreZoneStep()
	end
	local dropdown = overlay and overlay.FloorDropdown
	if not dropdown then return end
	dropdown:SetShown(menuText ~= nil and not menuOnBar)
	if menuText and not menuOnBar then
		if dropdown.GenerateMenu then dropdown:GenerateMenu() end
		if dropdown.SetText then dropdown:SetText(menuText) end
	end
end

-- Follows the bar as it lays itself out again (a new map) or changes size (the map maximized).
local barWatched
local function WatchBar()
	local bar = LocationBar()
	if barWatched or not bar then return end
	barWatched = true
	hooksecurefunc("NavBar_CheckLength", function(laidOut)
		if menuText and laidOut == (LocationBar()) then UpdateFloorMenu() end
	end)
	bar:HookScript("OnSizeChanged", function() if menuText then UpdateFloorMenu() end end)
end

-- The floor menu, with the current floor's name (or none: hidden).
local function ShowFloorMenu(text)
	WatchBar()
	menuText = text
	UpdateFloorMenu()
end

-- The step's name: the floor's or level's, and over a zone not its own (elsewhere) its place's
-- after it, unless the name says the place already (a dungeon's whole map, Maraudon's caves).
local function StepName(place, name, elsewhere)
	if not (name and elsewhere and place and place ~= "") or name:find(place, 1, true) then return name end
	return string.format(L.MAP_STEP_ELSEWHERE or "%s (%s)", name, place)
end

--[[
	Other addons' map pins drawn in a higher strata than the map's own (RareScanner's are HIGH
	and DIALOG) would show through the dungeon map, since a higher strata always draws on top.
	While it is up they are moved into its strata, beneath it, and given their own back when it
	closes. Pools reuse their pins and their owners raise them again as they show, so each moved
	pin is moved again whenever it shows while the map is up. Only the canvas's own pins are
	touched, never the map's buttons.
]]
local STRATA_RANK = {
	BACKGROUND = 1, LOW = 2, MEDIUM = 3, HIGH = 4, DIALOG = 5, FULLSCREEN = 6, FULLSCREEN_DIALOG = 7, TOOLTIP = 8,
}
local tucked = {}                                    -- frame -> { strata, level } it had
local tuckWatched = setmetatable({}, { __mode = "k" })

local function TuckUnder(frame)
	if not (overlay and overlay:IsShown()) or frame == overlay then return end
	local strata, own = frame:GetFrameStrata(), overlay:GetFrameStrata()
	if (STRATA_RANK[strata] or 0) <= (STRATA_RANK[own] or 0) then return end
	-- Its owner raised the strata again; the level is still the one this moved it to.
	local was = tucked[frame]
	tucked[frame] = { strata, was and was[2] or frame:GetFrameLevel() }
	frame:SetFrameStrata(own)
	if frame:GetFrameLevel() >= overlay:GetFrameLevel() then frame:SetFrameLevel(overlay:GetFrameLevel() - 1) end
	if not tuckWatched[frame] then
		tuckWatched[frame] = true
		frame:HookScript("OnShow", TuckUnder)
	end
end

-- The canvas's pins, and the pins of layers other addons put on it.
local function TuckForeignPins()
	local canvas = Canvas()
	if not (canvas and overlay and overlay:IsShown()) then return end
	for _, child in ipairs({ canvas:GetChildren() }) do
		if child ~= overlay then
			TuckUnder(child)
			for _, pin in ipairs({ child:GetChildren() }) do TuckUnder(pin) end
		end
	end
end

--[[
	The map's own buttons over the canvas (the quest log's toggle in its corner, the filter and pin
	buttons, the floor menu) stay above the dungeon map, so they can still be pointed at and clicked
	while it shows: one the overlay would sit over is lifted just above it, and put back as it was
	when the overlay goes. Only their strata and level change.
]]
local lifted = {}                                    -- frame -> { strata, level } it had
local MAX_FRAME_LEVEL = 10000

local function LiftMapButtons()
	if not (overlay and overlay:IsShown() and WorldMapFrame) then return end
	local buttons = {}
	for _, frame in ipairs(WorldMapFrame.overlayFrames or {}) do buttons[#buttons + 1] = frame end
	if WorldMapFrame.SidePanelToggle then buttons[#buttons + 1] = WorldMapFrame.SidePanelToggle end
	local strata, level = overlay:GetFrameStrata(), overlay:GetFrameLevel()
	local own = STRATA_RANK[strata] or 0
	for _, frame in ipairs(buttons) do
		local rank = STRATA_RANK[frame:GetFrameStrata()] or 0
		if rank < own or (rank == own and frame:GetFrameLevel() <= level) then
			lifted[frame] = lifted[frame] or { frame:GetFrameStrata(), frame:GetFrameLevel() }
			if rank < own then frame:SetFrameStrata(strata) end
			frame:SetFrameLevel(math.min(level + 20, MAX_FRAME_LEVEL))
		end
	end
end

local function DropMapButtons()
	for frame, was in pairs(lifted) do
		frame:SetFrameStrata(was[1])
		frame:SetFrameLevel(was[2])
		lifted[frame] = nil
	end
end

local function UntuckForeignPins()
	DropMapButtons()
	for frame, was in pairs(tucked) do
		frame:SetFrameStrata(was[1])
		frame:SetFrameLevel(was[2])
		tucked[frame] = nil
	end
end

-- After drawing: and once more on the next frame, for providers that refresh after this one.
local function TuckAfterDraw()
	TuckForeignPins()
	LiftMapButtons()
	if C_Timer and C_Timer.After then C_Timer.After(0, TuckForeignPins) end
end

local function CreateOverlay()
	local canvas = Canvas()
	if not canvas then return nil end
	overlay = CreateFrame("Frame", nil, canvas)
	overlay:SetAllPoints(canvas)
	overlay:SetFrameLevel(canvas:GetFrameLevel() + OVERLAY_LEVEL)
	overlay:EnableMouse(true)
	overlay:SetScript("OnHide", UntuckForeignPins)
	overlay:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" then Dismiss() end
	end)
	overlay.Background = overlay:CreateTexture(nil, "BACKGROUND")
	overlay.Background:SetAllPoints()
	overlay.Background:SetColorTexture(0, 0, 0, 1)

	-- The picture, cut to the map's own shape so tiles past its edge do not show.
	local art = CreateFrame("Frame", nil, overlay)
	art:SetPoint("CENTER")
	if art.SetClipsChildren then art:SetClipsChildren(true) end
	art.Picture = art:CreateTexture(nil, "ARTWORK")
	art.Picture:SetAllPoints()
	art.Tiles = {}
	overlay.Art = art

	-- Where the player is, by area name: the client gives no position in these dungeons.
	local here = CreateFrame("Frame", nil, overlay)
	here:SetFrameLevel(overlay:GetFrameLevel() + 5)
	here.Glow = Masked(here, here:CreateTexture(nil, "ARTWORK"))
	here.Glow:SetAllPoints()
	here.Glow:SetColorTexture(1, 0.82, 0.2, 0.35)
	here.Ring = here:CreateTexture(nil, "OVERLAY")
	here.Ring:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	here.Ring:SetBlendMode("ADD")
	here.Ring:SetAllPoints()
	here.Label = here:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalOutline", "GameFontNormal"))
	here.Label:SetPoint("BOTTOM", here, "TOP", 0, 2)
	here.Label:SetText(L.MAP_YOU_ARE_HERE)
	local pulse = here.CreateAnimationGroup and here:CreateAnimationGroup()
	local fade = pulse and pulse:CreateAnimation("Alpha")
	if fade then
		pulse:SetLooping("BOUNCE")
		fade:SetFromAlpha(1)
		fade:SetToAlpha(0.35)
		fade:SetDuration(0.9)
		here.pulse = pulse
	end
	here:Hide()
	overlay.Here = here

	overlay.Pins, overlay.Transitions, overlay.Doors, overlay.QuestSpots, overlay.Links = {}, {}, {}, {}, {}

	-- The player's own arrow, for the areas below a zone where the client gives a position.
	local player = CreateFrame("Frame", nil, overlay)
	player:SetSize(PLAYER_ARROW_SIZE, PLAYER_ARROW_SIZE)
	player:SetFrameLevel(overlay:GetFrameLevel() + 20)
	player.Arrow = player:CreateTexture(nil, "OVERLAY")
	player.Arrow:SetAllPoints()
	if not ns.SetAtlasOrFile(player.Arrow, PLAYER_ARROW_ATLAS, PLAYER_ARROW_FILE) then
		player.Arrow:SetTexture(PLAYER_ARROW_FILE)
	end
	player:Hide()
	overlay.PlayerPin = player

	overlay.FloorDropdown = CreateFloorDropdown()
	overlay:Hide()
	return overlay
end

local RestyleBossPins -- below, once pins can be placed

local function OverlayPin(index)
	local pin = overlay.Pins[index]
	if not pin then
		pin = CreateFrame("Button", nil, overlay)
		BuildBossPin(pin)
		pin:SetFrameLevel(overlay:GetFrameLevel() + 10)
		pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		pin:SetScript("OnEnter", function(self)
			if self.maybe then
				overlay.litBoss = self.boss
				RestyleBossPins()
			end
			ShowBossTooltip(self)
		end)
		pin:SetScript("OnLeave", function()
			GameTooltip:Hide()
			if overlay.litBoss then
				overlay.litBoss = nil
				RestyleBossPins()
			end
		end)
		pin:SetScript("OnClick", function(self, button)
			if button == "RightButton" then Dismiss() else DungeonMap:OpenPin(self.instance, self.boss) end
		end)
		overlay.Pins[index] = pin
	end
	return pin
end

--[[
	A spot where the dungeon carries on to another floor (the art prints the arrow). The way down into a cave floor
	(icon = "cave": Shaper's Terrace's Prismatic Talus, whose map draws only a mark of its own there) shows retail's
	cave entrance on it, as the zones' caves do; where the client has none of its pictures, the spot is as the others.
]]
local function TransitionPin(index, icon)
	local spot = overlay.Transitions[index]
	if not spot then
		spot = CreateFrame("Button", nil, overlay)
		spot:SetSize(30, 30)
		spot:SetFrameLevel(overlay:GetFrameLevel() + 8)
		spot:SetHighlightTexture(TRANSITION_HIGHLIGHT, "ADD")
		spot.Icon = spot:CreateTexture(nil, "ARTWORK")
		spot.Icon:SetPoint("CENTER")
		spot.Icon:Hide()
		spot:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(string.format(L.MAP_GO_TO, FloorName(self.instance, self.to)), 1, 1, 1)
			GameTooltip:Show()
		end)
		spot:SetScript("OnLeave", function() GameTooltip:Hide() end)
		spot:SetScript("OnClick", function(self)
			ns.PlaySoundKit("IG_MAINMENU_OPTION")
			chosenFloor[self.instance.key], follow.picked = self.to, true
			follow.Picked(self.instance)
			DungeonMap:Refresh()
		end)
		overlay.Transitions[index] = spot
	end
	local atlas
	for _, name in ipairs(icon == "cave" and CAVE_ATLASES or {}) do
		if not atlas and ns.AtlasExists(name) then atlas = name end
	end
	spot.Icon:SetShown(atlas ~= nil)
	if atlas then
		-- At the picture's own size, as the zones' cave pins; what answers the mouse is the icon (PIN_HIT_SIZE).
		spot.Icon:SetAtlas(atlas, true)
		local width, height = spot.Icon:GetSize()
		if not width or width <= 0 or not height or height <= 0 then width, height = 32, 32 end
		spot.Icon:SetSize(width, height)
		spot:SetSize(math.min(width, PIN_HIT_SIZE), math.min(height, PIN_HIT_SIZE))
	else
		spot:SetSize(30, 30)
	end
	return spot
end

-- Where a quest starts (or is handed in) inside the dungeon, as on the world map, and what is looted, used
-- or explored for one (UI/QuestMap.lua, which builds and draws the art: BuildInsideSpot, StyleInsideSpot):
-- a click opens it in the journal, a right click puts the map away.
local function QuestSpot(index)
	local spot = overlay.QuestSpots[index]
	if not spot then
		spot = CreateFrame("Button", nil, overlay)
		spot:SetSize(24, 24)
		spot:SetFrameLevel(overlay:GetFrameLevel() + 12)
		ns.QuestMap:BuildInsideSpot(spot)
		spot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		spot:SetScript("OnEnter", function(self) ns.QuestMap:InsideEnter(self) end)
		spot:SetScript("OnLeave", function(self) ns.QuestMap:InsideLeave(self) end)
		spot:SetScript("OnClick", function(self, button)
			if button == "RightButton" then Dismiss() else ns.QuestMap:Open(self.instance, self.quest) end
		end)
		overlay.QuestSpots[index] = spot
	end
	return spot
end

-- Lays the floor's picture into the canvas, as large as fits.
local function LayoutArt(floor)
	local canvas = overlay:GetParent()
	local width, height = canvas:GetWidth(), canvas:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return false end
	-- Width over height: a square picture cut at artRight and artBottom, or the tiles' visible map.
	local ratio = floor.art and (floor.artRight or 1) / (floor.artBottom or 1) or TILE_MAP_WIDTH / TILE_MAP_HEIGHT
	local artWidth, artHeight = width, width / ratio
	if artHeight > height then artHeight, artWidth = height, height * ratio end
	overlay.Art:SetSize(artWidth, artHeight)
	overlay.artWidth, overlay.artHeight = artWidth, artHeight
	return true
end

-- The files of a client map's own tiles (its first layer), in the same 4 x 3 order as a map's named tiles.
local function NativeTiles(floor)
	if not (floor.uiMapID and C_Map and C_Map.GetMapArtLayerTextures) then return nil end
	local ok, textures = pcall(C_Map.GetMapArtLayerTextures, floor.uiMapID, 1)
	return ok and type(textures) == "table" and #textures > 0 and textures or nil
end

-- Draws the floor's picture; skipped when the same floor is already drawn at the same size.
local function DrawArt(floor)
	local art = overlay.Art
	if art.floor == floor and art.width == overlay.artWidth and art.height == overlay.artHeight then return end
	art.floor, art.width, art.height = floor, overlay.artWidth, overlay.artHeight
	for _, tile in ipairs(art.Tiles) do tile:Hide() end
	if floor.art then
		art.Picture:SetTexture(floor.art)
		art.Picture:SetTexCoord(0, floor.artRight or 1, 0, floor.artBottom or 1)
		art.Picture:Show()
		return
	end
	art.Picture:Hide()
	-- The client's own tiles, numbered 1-12 left to right, top to bottom: by their files' names, or for a
	-- dungeon the world map can show itself, drawn over the map that shows (DungeonMap:Show), as the
	-- client lists that map's own.
	local textures = not floor.tiles and NativeTiles(floor)
	if not (floor.tiles or textures) then return end
	local tileWidth = overlay.artWidth * TILE_SIZE / TILE_MAP_WIDTH
	local tileHeight = overlay.artHeight * TILE_SIZE / TILE_MAP_HEIGHT
	for index = 1, TILE_COLUMNS * TILE_ROWS do
		local tile = art.Tiles[index]
		if not tile then
			tile = art:CreateTexture(nil, "ARTWORK")
			art.Tiles[index] = tile
		end
		local column, row = (index - 1) % TILE_COLUMNS, math.floor((index - 1) / TILE_COLUMNS)
		-- A client map that lists fewer tiles leaves the rest empty.
		local file
		if textures then file = textures[index] else file = floor.tiles .. index end
		if file then
			tile:SetTexture(file)
			tile:SetSize(tileWidth, tileHeight)
			tile:ClearAllPoints()
			tile:SetPoint("TOPLEFT", art, "TOPLEFT", column * tileWidth, -row * tileHeight)
			tile:Show()
		end
	end
end

-- Pins keep their size on screen as the map zooms.
local function PinScale()
	local scale = overlay:GetParent():GetScale()
	if not scale or scale <= 0 then return 1 end
	return 1 / scale
end

local function Place(frame, x, y, scale, shift)
	frame:SetScale(scale)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", overlay.Art, "TOPLEFT", x * overlay.artWidth / scale + (shift or 0), -y * overlay.artHeight / scale)
end

-- Pins of bosses sharing a spot (the Graveyard's rares, one of which may stand there) sit side by side.
local SHARED_SPOT_SPACING = 30

-- A boss pin's size, fading and place, from its spot and the boss whose spots are lit.
local function StyleBossPin(pin)
	local lit = pin.boss == overlay.litBoss
	pin:SetAlpha(MaybeAlpha(pin, overlay.litBoss))
	pin:SetFrameLevel(overlay:GetFrameLevel() + (lit and 11 or 10))
	local size = pin.maybe and not lit and MAYBE_SCALE or 1
	Place(pin, pin.point.x, pin.point.y, overlay.pinScale * size, pin.shift)
end

function RestyleBossPins()
	for _, pin in ipairs(overlay.Pins) do
		if pin:IsShown() then StyleBossPin(pin) end
	end
end

local function DrawPins(instance, index)
	local scale = PinScale()
	local spots, together, litHere = {}, {}, false
	for _, boss in ipairs(instance.bosses) do
		if not boss.trash and not ns.Items:HidesBoss(boss) then
			for _, point in ipairs(BossSpots(boss)) do
				if (point.floor or 1) == index then
					local key = string.format("%.3f:%.3f", point.x, point.y)
					together[key] = (together[key] or 0) + 1
					spots[#spots + 1] = { boss = boss, point = point, key = key, place = together[key] }
					litHere = litHere or boss == overlay.litBoss
				end
			end
		end
	end
	-- Lit spots belong to the floor they were lit on.
	if not litHere then overlay.litBoss = nil end
	overlay.pinScale = scale
	for count, spot in ipairs(spots) do
		local pin = OverlayPin(count)
		SetBossPin(pin, instance, spot.boss)
		pin.maybe, pin.point, pin.floor = IsMaybe(spot.boss, index), spot.point, index
		pin.shift = (spot.place - (together[spot.key] + 1) / 2) * SHARED_SPOT_SPACING
		StyleBossPin(pin)
		pin:Show()
	end
	local count = #spots
	for extra = count + 1, #overlay.Pins do overlay.Pins[extra]:Hide() end

	local spots = 0
	for _, transition in ipairs(instance.map.transitions or {}) do
		if transition.floor == index and Floors(instance)[transition.to] then
			spots = spots + 1
			local spot = TransitionPin(spots, transition.icon)
			spot.instance, spot.to = instance, transition.to
			Place(spot, transition.x, transition.y, scale)
			spot:Show()
		end
	end
	for extra = spots + 1, #overlay.Transitions do overlay.Transitions[extra]:Hide() end

	local marks = ns.QuestMap and ns.QuestMap:InsideMarks(instance, index) or {}
	-- (beside the boss pins shown, not over them: QuestMap:ClearOfPins)
	local shown = {}
	for _, pin in ipairs(overlay.Pins) do
		if pin:IsShown() and pin.point then shown[#shown + 1] = pin end
	end
	if ns.QuestMap then ns.QuestMap:ClearOfPins(marks, shown, overlay.artWidth, overlay.artHeight, scale) end
	for count, entry in ipairs(marks) do
		local spot = QuestSpot(count)
		spot.instance, spot.quest, spot.mark, spot.where = instance, entry.quest, entry.mark, entry.spot
		ns.QuestMap:StyleInsideSpot(spot, entry.mark)
		-- (marks of different givers or things on one spot side by side: QuestMap:InsideMarks)
		Place(spot, entry.x, entry.y, scale, entry.shift)
		spot:Show()
	end
	for extra = #marks + 1, #overlay.QuestSpots do overlay.QuestSpots[extra]:Hide() end
end

-- The area the player stands in, where the journal knows where that area is on the map.
local function DrawHere(instance, index)
	local here = overlay.Here
	local area
	if instance == CurrentInstance() then
		local ok, subzone = pcall(GetSubZoneText)
		subzone = ok and ns.Readable(subzone) or nil
		area = subzone and ns.AreaIn(instance.mapAreas, subzone)
	end
	if not area or (area.floor or 1) ~= index then
		here:Hide()
		if here.pulse then here.pulse:Stop() end
		return
	end
	local size = (area.radius or 0.05) * 2 * overlay.artWidth
	here:SetSize(size, size)
	here:ClearAllPoints()
	here:SetPoint("CENTER", overlay.Art, "TOPLEFT", area.x * overlay.artWidth, -area.y * overlay.artHeight)
	here:Show()
	if here.pulse and not here.pulse:IsPlaying() then here.pulse:Play() end
end

------------------------------------------------------------------------------------------
-- Areas below a zone (Old Ironforge): their picture, the dungeons in them, the player
------------------------------------------------------------------------------------------

-- The picture's place for a position on the zone's own map, or nil when it is off the picture
-- (or the picture is of a place the client gives no position in).
local function OnSubMap(subMap, x, y)
	local bounds = subMap.bounds
	if not bounds then return nil end
	local px, py = (x - bounds.left) / bounds.width, (y - bounds.top) / bounds.height
	if px < 0 or px > 1 or py < 0 or py > 1 then return nil end
	return px, py
end

-- The area below a zone the player was last seen in.
local playerBelow
-- A way down under the name of the rooms above it (Old Ironforge's): what the player did there
-- (ways.Walked, below), and whether they were last seen by it, in that name (ways.near: The High
-- Seat), where the map turns with no new name. One table, as the file is at Lua's 200 locals.
local ways = {}
-- Starts or stops following the player's position where the map turns with no new name (the
-- Events section below).
local Follow

-- The zone's name, as the minimap shows it, else the zone's own.
local function ZoneName()
	for _, fn in ipairs({ GetMinimapZoneText, GetRealZoneText }) do
		local ok, name = pcall(fn)
		name = ok and ns.Readable(name) or nil
		if type(name) == "string" and name ~= "" then return name end
	end
	return nil
end

-- Indoors, as the client says: its minimap switches with it.
local function PlayerIndoors()
	if type(IsIndoors) ~= "function" then return false end
	local ok, inside = pcall(IsIndoors)
	inside = ok and ns.Readable(inside)
	return inside == true or inside == 1
end

-- Whether a spot on the picture is in one of these boxes ({ left, top, right, bottom }): its claims,
-- its overlaps, its way down.
local function InBoxes(boxes, px, py)
	for _, box in ipairs(boxes or {}) do
		if px >= box[1] and py >= box[2] and px <= box[3] and py <= box[4] then return true end
	end
	return false
end

-- Where another level of the same area lies over this one's floors (overlaps), the level the
-- player was last seen on keeps them.
local function OtherLevelKeeps(subMap, px, py)
	return playerBelow ~= nil and playerBelow ~= subMap and subMap.levels ~= nil and playerBelow.levels == subMap.levels
		and InBoxes(subMap.overlaps, px, py)
end

-- The same picture as placed on another map: a way in the client reports on two maps, its picture set up on
-- both (Razorfen Downs': the Barrens on the ground, Kalimdor on the skull's floors; Blackrock Mountain's ring on
-- Burning Steppes and Searing Gorge), the same level of it.
local function SamePictureOn(subMap, mapID)
	for _, other in ipairs(ns.GetSubMaps()) do
		if other ~= subMap and other.parentMapID == mapID and not other.viewOnly and (other.art or other.tiles)
			and other.art == subMap.art and other.tiles == subMap.tiles and other.levels == subMap.levels
			and other.level == subMap.level then
			return other
		end
	end
	return nil
end

--[[
	Old Ironforge lies under streets of its own name ("Ironforge") on the very same spots (a street
	hallway right over its middle), and Forever gives addons no height: the name and the spot cannot
	tell below from above. So for a picture with a way down (wayDown), being below is what the player
	did, remembered for the character (AegisJournalCharDB.whereBelow, by the picture's key): "top" on
	the way down under its name (sharedAreas: The High Seat, inside wayDown); "below" once the area's
	own name (areas) is read inside the way down right after the top (they walked down), or at a
	dungeon's door (exits) right after its inside; the dungeon's
	key while inside one of its dungeons (the Hall of Thanes). Being below ends where the area reads
	anything else on the picture's map (the way's name outside the way down, a street, the bank, or
	the area's name off the picture), and on another map or in another dungeon. A dungeon's key holds
	on another map and with no position (the loading screen out of the Hall of Thanes may first give
	the continent's map, or none): only a reading on the picture's own map, with a position and a name,
	decides what the player is once out of it (at its portal, below; anywhere else, nothing: a hearth
	or a summons out). Where rooms above lie
	over the way down under the same name (wayOver: the throne room's stair and passage), the way's
	name keeps what the player was. With no position, or no name (the client's "" for a moment: no
	spot of the city is nameless in Forever's model), nothing changes, the following neither. The
	picture shows on the way down and below.
]]
function ways.Where(subMap)
	local saved = ns.charDB and ns.charDB.whereBelow
	return saved and saved[subMap.key] or nil
end

function ways.Remember(subMap, state)
	local was = ways.Where(subMap)
	if not ns.charDB or was == state then return end
	local saved = ns.charDB.whereBelow or {}
	saved[subMap.key] = state
	ns.charDB.whereBelow = next(saved) and saved or nil
	ways.Note(subMap, was, state)
end

--[[
	For /aegis where (Core/Perf.lua): the last few changes of what the player is remembered as, this
	session only (ways.log, never saved), each when it happens and nothing between: the time, what read
	the player (ways.cause: the event, the following, the retry, else the map; read only in the frame
	it was stamped in, ways.causeAt, so one an error left set is not read later), the reading (map, area, position)
	and the change.
]]
ways.LOG_SIZE = 6
function ways.Note(subMap, was, state)
	local mapID, x, y = ns.PlayerMapPosition()
	local ok, area = pcall(GetSubZoneText)
	ways.log = ways.log or {}
	table.insert(ways.log, { key = subMap.key, at = type(date) == "function" and date("%H:%M:%S") or "?",
		by = ways.cause and ways.causeAt == GetTime() and ways.cause or "map", mapID = mapID, area = ok and ns.Readable(area) or nil, x = x, y = y, was = was,
		now = state })
	if #ways.log > ways.LOG_SIZE then table.remove(ways.log, 1) end
end

-- What a remembered state reads as: below, at the top of the way, a dungeon's name, or nothing.
function ways.StateName(state)
	if state == nil then return L.WHERE_BELOW_NOTHING end
	if state == "below" then return L.WHERE_BELOW_BELOW end
	if state == "top" then return L.WHERE_BELOW_TOP end
	local instance = ns.GetInstance(state)
	return instance and instance.name or tostring(state)
end

-- /aegis where's lines for each picture with a way down: what the player is remembered as, and its
-- last changes this session.
function DungeonMap:BelowLines()
	local lines = {}
	local function Coord(value) return value and string.format("%.4f", value) or "-" end
	for _, subMap in ipairs(ns.GetSubMaps()) do
		if subMap.wayDown then
			lines[#lines + 1] = string.format(L.WHERE_BELOW, subMap.name or subMap.key, ways.StateName(ways.Where(subMap)))
			for _, entry in ipairs(ways.log or {}) do
				if entry.key == subMap.key then
					lines[#lines + 1] = string.format(L.WHERE_BELOW_CHANGE, entry.at, entry.by, tostring(entry.mapID or "-"),
						entry.area or "", Coord(entry.x), Coord(entry.y), ways.StateName(entry.was), ways.StateName(entry.now))
				end
			end
		end
	end
	return lines
end

-- playerMap and x: the player's map and whether it gives their position; area: the client's name for the
-- spot; px, py: the spot on the picture, nil off it. Whether the picture shows.
function ways.Walked(subMap, playerMap, x, area, px, py)
	local state = ways.Where(subMap)
	local instance = CurrentInstance()
	if instance then
		state = subMap.instances[instance.key] and instance.key or nil
	elseif playerMap and playerMap ~= subMap.parentMapID then
		-- (a dungeon's key holds: above)
		if not (state and subMap.instances[state]) then state = nil end
	elseif playerMap and x and area and area ~= "" then
		local onWay = px ~= nil and InBoxes(subMap.wayDown, px, py)
		local overWay = px ~= nil and InBoxes(subMap.wayOver, px, py)
		if ns.AreaIn(subMap.sharedAreas, area) then
			if onWay then
				state = "top"
			elseif not overWay then
				state = nil
			end
		elseif px and ns.AreaIn(subMap.areas, area) then
			if state == "top" then
				state = (onWay or overWay) and "below" or nil
			elseif state and state ~= "below" then
				state = InBoxes(subMap.exits and subMap.exits[state], px, py) and "below" or nil
			end
		else
			state = nil
		end
	end
	ways.Remember(subMap, state)
	return state == "top" or state == "below"
end

--[[
	The area below `mapID` the player is in: inside its picture, in a spot the streets above do
	not name. Some spots below share a name with a street above (sharedAreas): once the player
	has been seen below, those keep them there, as a spot the client names nothing does for a
	picture marked unnamed (the door of Blackrock Depths). Where streets above share both the name
	and the spot of the area below (Old Ironforge's "Ironforge"), being below is remembered from
	the way the player got there (wayDown: ways.Walked, above), and nothing else counts for that
	picture. A building's map (indoors = true) shows only inside it, the ground before
	its doors reading the same area name; names in boxedAreas count only in its boxes, or indoors
	(Gnomeregan's tunnels, where Forever's client says outdoors: the dungeon's name and none, inside
	the tunnels and not at the gate's mouth, where the ground outside reads them too); names in indoorAreas
	count only there (Blackrock Mountain's tunnels, named like the ground outside), and on a picture
	with claims only in them (the middle level's corridor, named like the tunnels, or in Forever's
	model like the Blackrock Stronghold outside). Two pictures over the same ground with the same
	name (Maraudon's two caves, Blackrock Mountain's ring and middle level): the one with claims
	takes the spots in them, the other the rest; but where another of its area's levels lies over
	its floors (overlaps: the ring's high walkway over the middle level's corridor), the level the
	player was last seen on keeps them. Of the pictures over a spot, one whose claims take it comes
	first, then one the player is kept in (come up from the Grinding Quarry, the doorway named
	"Blackrock Mountain" is still the way down's), then one that names it, and last one with claims
	that do not take it. Where the client gives no map at all (the Deeprun Tram), the zone's name
	tells the place (zones), over any map. A view only (viewOnly: one cave of Maraudon's on its own
	map) is never the player's: it shows only when picked from its menu.
]]
local function PlayerSubMap(mapID)
	local playerMap, x, y = ns.PlayerMapPosition()
	local below, near
	if x then
		local ok, area = pcall(GetSubZoneText)
		area = ok and ns.Readable(area) or nil
		local claimed, kept, yielding
		for _, subMap in ipairs(ns.GetSubMaps()) do
			local px, py
			if subMap.parentMapID == playerMap and not subMap.viewOnly then px, py = OnSubMap(subMap, x, y) end
			if subMap.wayDown then
				if ways.Walked(subMap, playerMap, x, area, px, py) and px then below = below or subMap end
				if area == "" and playerMap == subMap.parentMapID then
					near = near or ways.near
				else
					near = near or (px ~= nil and ns.AreaIn(subMap.sharedAreas, area) ~= nil)
				end
			elseif area and subMap.areas and px and (not subMap.indoors or PlayerIndoors()) then
				local inClaims = subMap.claims ~= nil and InBoxes(subMap.claims, px, py)
				local named = ns.AreaIn(subMap.areas, area) or (ns.AreaIn(subMap.indoorAreas, area) and PlayerIndoors()
					and (not subMap.claims or inClaims))
				or (ns.AreaIn(subMap.boxedAreas, area) and (InBoxes(subMap.boxes, px, py) or PlayerIndoors()))
				if not named and subMap == playerBelow
					and (ns.AreaIn(subMap.sharedAreas, area) or (subMap.unnamed and area == "")) then
					kept = subMap
				elseif named and not subMap.claims then
					below = below or subMap
				elseif named and inClaims and not OtherLevelKeeps(subMap, px, py) then
					claimed = claimed or subMap
				elseif named then
					yielding = yielding or subMap
				end
			end
		end
		below = claimed or kept or below or yielding
	else
		-- No position: inside one of a way down's dungeons, or off its map
		for _, subMap in ipairs(ns.GetSubMaps()) do
			if subMap.wayDown then ways.Walked(subMap, playerMap) end
		end
		if not playerMap then
			local zone = ZoneName()
			for _, subMap in ipairs(ns.GetSubMaps()) do
				if zone and not subMap.viewOnly and ns.AreaIn(subMap.zones, zone) then
					below = subMap
					break
				end
			end
		end
	end
	playerBelow = below
	ways.near = near
	if below and (below.parentMapID == mapID or not below.parentMapID) then return below end
	-- The client turned to the other map with the world map open on this one (a step onto Razorfen Downs'
	-- skull from the ground, and back): the same picture, as placed on this one, stays.
	if below and mapID then return SamePictureOn(below, mapID) end
	return nil
end

--[[
	Doors that close on the map shown are one icon: the Scarlet Monastery's four wings share one
	door, and the dungeons inside Blackrock Mountain another. Its tooltip lists them all, and a
	left click offers them to choose from. So do a picture's doors (the Spire's, for Lower and
	Upper Blackrock Spire).
]]

-- What a shared door is called: the building its wings are named after ("Scarlet Monastery:
-- Library"), else the place they all are (Blackrock Mountain).
local function Building(name)
	return name:match("^(.-)%s*\239\188\154") or name:match("^(.-)%s*:")
end

local function SharedDoorName(instances)
	local building, location = Building(instances[1].name), instances[1].location
	for _, instance in ipairs(instances) do
		if Building(instance.name) ~= building then building = nil end
		if instance.location ~= location then location = nil end
	end
	return building or location or instances[1].name
end
DungeonMap.SharedDoorName = SharedDoorName

-- Each dungeon behind a shared door on its own line, with its level range.
local function AddDoorLines(instances)
	for _, instance in ipairs(instances) do
		local range = instance.levelMin and string.format(L.LEVEL_RANGE, instance.levelMin, instance.levelMax or instance.levelMin) or ""
		GameTooltip:AddDoubleLine(instance.name, range, 1, 1, 1, 1, 0.82, 0)
	end
end

-- A left click on a shared door: a menu of its dungeons, the journal's own (ns.Menus).
local function ChooseDoor(owner, instances)
	GameTooltip:Hide()
	ns.Menus:OpenContext(owner, function(_, root)
		root:CreateTitle(SharedDoorName(instances))
		for _, instance in ipairs(instances) do
			root:CreateButton(instance.name, function() DungeonMap:OpenInstance(instance) end)
		end
	end)
	return true
end

-- What a door's dungeons hold that the player should know before going in (doorNotes: the keys of
-- the journal's strings; the Spire's: one instance for both its dungeons, their group sizes), each
-- once, in the dungeons' order.
function DungeonMap:DoorNotes(instances)
	local notes, seen = {}, {}
	for _, instance in ipairs(instances) do
		for _, key in ipairs(instance.doorNotes or {}) do
			if L[key] and not seen[key] then
				seen[key] = true
				notes[#notes + 1] = L[key]
			end
		end
	end
	return notes
end

-- A dungeon's door on a sub-map's picture: retail's dungeon icon; a click opens the journal.
local function SubMapDoor(index)
	local door = overlay.Doors[index]
	if not door then
		door = CreateFrame("Button", nil, overlay)
		door:SetSize(32, 32)
		door:SetFrameLevel(overlay:GetFrameLevel() + 10)
		door.Texture = door:CreateTexture(nil, "ARTWORK")
		door.Texture:SetAllPoints()
		door.Texture:SetAtlas(DUNGEON_ATLAS)
		door:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
		door:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		-- One door to several dungeons (Lower and Upper Blackrock Spire): each by name, a left
		-- click to choose from them, as on the zone maps. What the door holds, beneath.
		door:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if #self.instances > 1 then
				GameTooltip:SetText(SharedDoorName(self.instances), 1, 1, 1)
				AddDoorLines(self.instances)
			else
				GameTooltip:SetText(self.instance.name, 1, 1, 1)
				GameTooltip:AddLine(EntranceDescription(self.instance), 1, 0.82, 0)
			end
			for _, note in ipairs(DungeonMap:DoorNotes(self.instances)) do GameTooltip:AddLine(note, 1, 1, 1, true) end
			GameTooltip:AddLine(#self.instances > 1 and L.ENTRANCE_CHOOSE_LEFT_CLICK or L.ENTRANCE_LEFT_CLICK, 0.1, 1, 0.1)
			GameTooltip:Show()
		end)
		door:SetScript("OnLeave", function() GameTooltip:Hide() end)
		door:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				Dismiss()
			elseif not (#self.instances > 1 and ChooseDoor(self, self.instances)) then
				DungeonMap:OpenInstance(self.instance)
			end
		end)
		overlay.Doors[index] = door
	end
	return door
end

-- The way to another of an area's levels: an arrow up or down its menu, the level's name on the
-- mouse; a left click shows that level, a right click puts the map away. False where the client has
-- none of the atlases: then it does not show.
local function SetLinkArt(link, way)
	for _, atlas in ipairs(LINK_ATLASES[way]) do
		if ns.AtlasExists(atlas) then
			link.Texture:SetAtlas(atlas, true)
			link.Highlight:SetAtlas(atlas, true)
			local width, height = link.Texture:GetSize()
			if not width or width <= 0 or not height or height <= 0 then width, height = LINK_SIZE, LINK_SIZE end
			local fit = math.min(1, LINK_SIZE / math.max(width, height))
			link.Texture:SetSize(width * fit, height * fit)
			link:SetSize(math.min(width * fit, PIN_HIT_SIZE), math.min(height * fit, PIN_HIT_SIZE))
			return true
		end
	end
	return false
end

local function LevelLink(index)
	local link = overlay.Links[index]
	if not link then
		link = CreateFrame("Button", nil, overlay)
		link:SetSize(PIN_HIT_SIZE, PIN_HIT_SIZE)
		link:SetFrameLevel(overlay:GetFrameLevel() + 9)
		link.Texture = link:CreateTexture(nil, "ARTWORK")
		link.Texture:SetPoint("CENTER")
		link.Highlight = link:CreateTexture(nil, "HIGHLIGHT")
		link.Highlight:SetBlendMode("ADD")
		link.Highlight:SetAlpha(0.4)
		link.Highlight:SetAllPoints(link.Texture)
		link:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		link:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(string.format(L.MAP_GO_TO, LevelName(self.subMap.levels[self.to])), 1, 1, 1)
			GameTooltip:AddLine(L.MAP_LEVEL_LINK_CLICK, 0.1, 1, 0.1)
			GameTooltip:Show()
		end)
		link:SetScript("OnLeave", function() GameTooltip:Hide() end)
		link:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				Dismiss()
			else
				ns.PlaySoundKit("IG_MAINMENU_OPTION")
				DungeonMap:ShowLevel(self.subMap, self.to)
			end
		end)
		overlay.Links[index] = link
	end
	return link
end

local function StopPlayerArrow()
	if overlay and overlay.playerTicker then
		overlay.playerTicker:Cancel()
		overlay.playerTicker = nil
	end
	if overlay then overlay.PlayerPin:Hide() end
end

-- The player's arrow on a sub-map: the client reports the position on the zone's map, and
-- the calibration places it on the picture. It moves only while the picture shows.
local function UpdatePlayerArrow()
	local subMap = overlay and overlay:IsShown() and overlay.subMap
	if not subMap then return StopPlayerArrow() end
	local pin = overlay.PlayerPin
	local mapID, x, y = ns.PlayerMapPosition()
	-- One picture placed twice (Maraudon's caves): the player by the placement of the part they
	-- are in, whichever was opened. A cave's own map picked from the menu (a view) has its own.
	local placed = subMap
	if playerBelow and playerBelow ~= subMap and playerBelow.art and playerBelow.art == subMap.art
		and playerBelow.parentMapID == subMap.parentMapID then
		placed = playerBelow
	end
	-- The same picture as placed on the map the client reports now (SamePictureOn): the player by that one.
	if placed == subMap and playerBelow and playerBelow ~= subMap and playerBelow.parentMapID == mapID
		and SamePictureOn(subMap, mapID) == playerBelow then
		placed = playerBelow
	end
	local px, py
	if placed.parentMapID and mapID == placed.parentMapID and x then px, py = OnSubMap(placed, x, y) end
	-- Another level than the player's, chosen from the menu: they are not on it.
	if px and subMap.levels and playerBelow and playerBelow.levels == subMap.levels and playerBelow.level ~= subMap.level then
		px = nil
	end
	if not px then
		pin:Hide()
		return
	end
	Place(pin, px, py, PinScale())
	local ok, facing = pcall(GetPlayerFacing)
	facing = ok and ns.Readable(facing) or nil
	if facing then pin.Arrow:SetRotation(facing) end
	pin:Show()
end

--[[
	A way in's own pins and marks (Gnomeregan's tunnels, 2026-11-12): a boss who stands in his dungeon's way in, outside
	it (wayInPin, with the picture's key: Techbot), has his pin there, wearing his quest badge as on the dungeon's
	floors; and what is given, taken, used or looted there for its dungeons' quests has its mark (UI/QuestMap.lua's
	InsideMarks with the picture's key), kept beside the pins (ClearOfPins). scale: the pins' (PinScale).
]]
function DungeonMap:DrawWayInPins(subMap, scale)
	local keys, pins, marks = {}, {}, {}
	for key in pairs(subMap.instances or {}) do keys[#keys + 1] = key end
	table.sort(keys)
	overlay.pinScale, overlay.litBoss = scale, nil
	for _, key in ipairs(keys) do
		local instance = ns.GetInstance(key)
		for _, boss in ipairs(instance and instance.bosses or {}) do
			local point = boss.wayInPin
			if point and point.subMap == subMap.key and not boss.trash and not ns.Items:HidesBoss(boss) then
				local pin = OverlayPin(#pins + 1)
				SetBossPin(pin, instance, boss)
				pin.maybe, pin.point, pin.floor, pin.shift = false, point, nil, 0
				StyleBossPin(pin)
				pin:Show()
				pins[#pins + 1] = pin
			end
		end
		for _, entry in ipairs(instance and ns.QuestMap and ns.QuestMap:InsideMarks(instance, nil, subMap.key) or {}) do
			entry.instance = instance
			marks[#marks + 1] = entry
		end
	end
	if ns.QuestMap then ns.QuestMap:ClearOfPins(marks, pins, overlay.artWidth, overlay.artHeight, scale) end
	for count, entry in ipairs(marks) do
		local spot = QuestSpot(count)
		spot.instance, spot.quest, spot.mark, spot.where = entry.instance, entry.quest, entry.mark, entry.spot
		ns.QuestMap:StyleInsideSpot(spot, entry.mark)
		Place(spot, entry.x, entry.y, scale, entry.shift)
		spot:Show()
	end
end

local function DrawSubMap(subMap)
	overlay.instance, overlay.subMap = nil, subMap
	if not LayoutArt(subMap) then return false end
	DrawArt(subMap)
	for _, pin in ipairs(overlay.Pins) do pin:Hide() end
	for _, spot in ipairs(overlay.Transitions) do spot:Hide() end
	for _, spot in ipairs(overlay.QuestSpots) do spot:Hide() end
	overlay.Here:Hide()
	-- Levels (Blackrock Mountain's) or views (Maraudon's caves): a menu of them, as a dungeon's
	-- floors have. One held over a zone it is not in (a level picked there) names its place on the
	-- step too, as a dungeon's floors do (UpdateOverlay).
	local shownMapID = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
	local elsewhere = forced and forced.subMap == subMap and subMap.parentMapID ~= shownMapID
	ShowFloorMenu(StepName(subMap.name, subMap.levels and LevelName(subMap.levels[subMap.level])
		or subMap.views and ViewName(subMap.views, ViewIndex(subMap)) or nil, elsewhere))
	-- Dungeons that share a door on the picture are one door, their names in order; a dungeon with
	-- several doors on it (a list of points: Dire Maul's west and east wings) has an icon on each.
	local spots = {}
	for key, points in pairs(subMap.instances) do
		local instance = ns.GetInstance(key)
		for _, point in ipairs(instance and (points[1] and points or { points }) or {}) do
			local spot
			for _, other in ipairs(spots) do
				if other.x == point.x and other.y == point.y then spot = other end
			end
			if not spot then
				spot = { x = point.x, y = point.y, instances = {} }
				spots[#spots + 1] = spot
			end
			spot.instances[#spot.instances + 1] = instance
		end
	end
	table.sort(spots, function(a, b) return a.x < b.x or (a.x == b.x and a.y < b.y) end)
	local scale = PinScale()
	for index, spot in ipairs(spots) do
		table.sort(spot.instances, function(a, b) return a.name < b.name end)
		local door = SubMapDoor(index)
		door.instance, door.instances = spot.instances[1], spot.instances
		Place(door, spot.x, spot.y, scale)
		door:Show()
	end
	for extra = #spots + 1, #overlay.Doors do overlay.Doors[extra]:Hide() end
	-- Where its levels meet: the way up or down the levels' menu to each.
	local links = 0
	for _, way in ipairs(subMap.levels and subMap.links or {}) do
		if subMap.levels[way.level] and way.level ~= subMap.level then
			links = links + 1
			local link = LevelLink(links)
			link.subMap, link.to = subMap, way.level
			Place(link, way.x, way.y, scale)
			link:SetShown(SetLinkArt(link, way.level < subMap.level and "up" or "down"))
		end
	end
	for extra = links + 1, #overlay.Links do overlay.Links[extra]:Hide() end
	DungeonMap:DrawWayInPins(subMap, scale)
	overlay:Show()
	UpdatePlayerArrow()
	if not overlay.playerTicker and C_Timer.NewTicker then
		overlay.playerTicker = C_Timer.NewTicker(PLAYER_ARROW_SECONDS, UpdatePlayerArrow)
	end
	return true
end

-- What the overlay should show now: a dungeon, a sub-map, or neither.
local function OverlayTarget(mapID)
	if forced and forced.subMap and not WayInsOn() then forced = nil end
	if forced then
		if forced.mapID == mapID then return forced.instance, forced.subMap end
		forced = nil
	end
	if dismissed then return nil end
	-- Over the map the world map opened on, not while the player browses elsewhere. So a player who walks
	-- into a way in the client reports on another map with the world map open (from Dun Morogh's ground
	-- into Gnomeregan's tunnels, on the continent's) sees its picture once they open the map again, or on
	-- this map where the same picture is set up on both (SamePictureOn): the journal never turns the map
	-- (the rule above OpenWorld, below).
	homeMapID = homeMapID or mapID
	if mapID ~= homeMapID then return nil end
	local instance = CurrentInstance()
	if instance then
		if NeedsOverlay(instance) then return instance end
		return nil
	end
	if not WayInsOn() then return nil end
	local below = PlayerSubMap(mapID)
	Follow()
	return nil, below
end

local function UpdateOverlay()
	local mapID = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
	local instance, subMap = OverlayTarget(mapID)
	if not (instance or subMap) then
		if overlay then
			overlay:Hide()
			overlay.instance, overlay.subMap = nil, nil
			ShowFloorMenu(nil)
			StopPlayerArrow()
		end
		return
	end
	if not (overlay or CreateOverlay()) then return end
	if subMap then
		if DrawSubMap(subMap) then TuckAfterDraw() end
		return
	end
	StopPlayerArrow()
	overlay.subMap = nil
	for _, door in ipairs(overlay.Doors) do door:Hide() end
	for _, link in ipairs(overlay.Links) do link:Hide() end

	local floors = Floors(instance)
	local index = follow.Floor(instance) or chosenFloor[instance.key] or (forced and forced.floor) or 1
	if not floors[index] then index = 1 end
	local floor = floors[index]
	overlay.instance, overlay.floor = instance, index
	if not LayoutArt(floor) then return end
	DrawArt(floor)
	DrawPins(instance, index)
	DrawHere(instance, index)
	overlay:Show()
	TuckAfterDraw()

	-- A step of the location bar wherever it shows; held over a zone not the dungeon's own (shown from
	-- the journal where the player stands, its door not on that zone or unknown), the step names the
	-- dungeon too: "Ironforge > The Sewers (City of Dalaran)", not a level of Ironforge. Its own: the
	-- player inside it, the dungeon's own map shown, or the zone its door's pin shows on (The Deadmines'
	-- door, given on the continent, is Westfall's), so the same map reads the same however it opened.
	local elsewhere = forced and forced.instance == instance
	if elsewhere then
		local inside, shown = CurrentInstance(), FloorByMapID(mapID)
		elsewhere = not (inside and inside.instanceID == instance.instanceID or shown and shown.instance == instance
			or DungeonMap:DoorOnZone(DungeonMap:Entrance(instance), mapID))
	end
	ShowFloorMenu(#floors > 1 and StepName(instance.name, FloorName(instance, index), elsewhere) or nil)
end

------------------------------------------------------------------------------------------
-- The data provider
------------------------------------------------------------------------------------------

local ProviderMethods = {}

-- The area the player stands in matters only while the map is open: listen only then.
-- MINIMAP_UPDATE_ZOOM: the player stepping indoors or out, as the minimap follows it.
local ZONE_EVENTS = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "MINIMAP_UPDATE_ZOOM" }
local zoneWatch = CreateFrame("Frame")
-- Walking down into an area below the zone, or back up, changes what the map shows; so does walking into a
-- room of another floor inside a dungeon (follow.Floor: the journal's overlay turns to it). Walking onto
-- another map does not turn the open map: the journal never sets the map's map (the rule above OpenWorld, below).
zoneWatch:SetScript("OnEvent", function() UpdateOverlay() end)

function ProviderMethods:OnShow()
	ns.RegisterEvents(zoneWatch, unpack(ZONE_EVENTS))
end

-- What one opening of the map chose (a dungeon shown, the overlay put away, the map it opened on)
-- ends as it closes: the client draws the map before it tells its providers it shows.
function ProviderMethods:OnHide()
	ns.UnregisterEvents(zoneWatch, unpack(ZONE_EVENTS))
	forced, dismissed, homeMapID = nil, false, nil
	follow.picked, follow.key, follow.index, follow.seen = false, nil, nil, nil
	if overlay then overlay:Hide() end
	ShowFloorMenu(nil)
	StopPlayerArrow()
end

function ProviderMethods:RemoveAllData()
	ns.CanvasPins:ReleaseAll(BOSS_PIN_TEMPLATE)
end

function ProviderMethods:RefreshAllData()
	self:RemoveAllData()
	local map = self:GetMap()
	local found = FloorByMapID(map:GetMapID())
	if found and DungeonMap:IsNative(Floors(found.instance)[found.index]) then
		for _, boss in ipairs(found.instance.bosses) do
			if not boss.trash then
				for _, point in ipairs(BossSpots(boss)) do
					if (point.floor or 1) == found.index then
						local pin = ns.CanvasPins:Acquire(map, BOSS_PIN_TEMPLATE, found.instance, boss, found.index)
						pin:SetPosition(point.x, point.y)
					end
				end
			end
		end
	end
	UpdateOverlay()
end

-- The map's zoom and canvas size: the overlay drawn again, and every pin the journal has on the map
-- (UI/CanvasPins.lua) sized and placed again.
function ProviderMethods:OnCanvasScaleChanged()
	ns.CanvasPins:OnCanvasScaleChanged()
	if overlay and overlay:IsShown() then UpdateOverlay() end
end

function ProviderMethods:OnCanvasSizeChanged()
	ns.CanvasPins:OnCanvasSizeChanged()
	if overlay and overlay:IsShown() then UpdateOverlay() end
end

------------------------------------------------------------------------------------------
-- Dungeon and raid entrances on zone and continent maps, as retail draws them
------------------------------------------------------------------------------------------

--[[
	Retail's own entrance provider is on Forever's world map too, but the client has no
	entrances to give it. These pins are retail's: the "Dungeon" and "Raid" icons at their
	own size, the same highlight and area label, at the same frame level. A left click opens
	the instance in the journal, a right click sets a waypoint to the door.

	The entrance is the one the Record tab captured on the way in, if there is one, else the
	data's. It shows on its own zone's map and on the maps above it (the continent), placed
	there through the client's world coordinates. Blizzard's "Dungeon Entrances" map
	tracking option (the showDungeonEntrancesOnMap setting) turns them off and on.
]]
local ENTRANCE_PIN_TEMPLATE = "AegisJournalEntrancePinTemplate"
local ENTRANCE_CVAR = "showDungeonEntrancesOnMap"
local MAP_TYPE_CONTINENT, MAP_TYPE_ZONE = 2, 3
-- Retail's cave entrance (its map legend's "Cave"), for the way down to an area below a zone
-- (CAVE_ATLASES, at the top of the file: a dungeon's way down into a cave floor has it too);
-- a building's way in (icon = "building": the Scarlet Monastery's hall) shows retail's delve
-- entrance, or the cave where the client lacks it.
local CAVE_PIN_TEMPLATE = "AegisJournalCavePinTemplate"
local BUILDING_ATLASES = { "delves-regular", "CaveUnderground-Up", "CaveUnderground-Down" }

-- A building's way in, not a cave's way down.
local function IsBuilding(subMap)
	return subMap ~= nil and subMap.icon == "building"
end

-- Its legend entry's kind: "building" (Entrance) or "cave" (Cave Entrance).
local function WayKind(subMap)
	return IsBuilding(subMap) and "building" or "cave"
end

-- A dungeon reached through an area below the zone, or a building, says where the way in is.
local function AddViaLine(instance)
	local via = instance.via and ns.GetSubMap(instance.via)
	if not via then return end
	GameTooltip:AddLine(string.format(IsBuilding(via) and L.ENTRANCE_VIA_BUILDING or L.ENTRANCE_VIA, via.name), 1, 1, 1, true)
end
local LEGEND_GLOW_ATLAS = "UI-QuestPoi-OuterGlow"

--[[
	A door may be given by its place in the world (world = { continent, x, y }, as the game's
	own data gives it) instead of on its zone's map: the client puts it on the zone's map once.
	The axis order is the one that lands on that map; a door that lands on neither is not shown.
]]
local function OnZoneMap(entrance)
	if not entrance or entrance.x or not entrance.world then return entrance end
	if entrance.unplaced or not (C_Map and C_Map.GetMapPosFromWorldPos and CreateVector2D) then return nil end
	local continent, a, b = entrance.world[1], entrance.world[2], entrance.world[3]
	for _, order in ipairs({ { a, b }, { b, a } }) do
		local ok, _, position = pcall(C_Map.GetMapPosFromWorldPos, continent, CreateVector2D(order[1], order[2]), entrance.mapID)
		if ok and position then
			local x, y = position:GetXY()
			if x and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
				entrance.x, entrance.y = x, y
				return entrance
			end
		end
	end
	entrance.unplaced = true
	return nil
end

-- Where the instance's door stands outside: { mapID, x, y }.
function DungeonMap:Entrance(instance)
	-- Wings that share one instance id share one recording too, which could be either's door.
	if instance.sharesInstanceID then return OnZoneMap(instance.zoneEntrance) end
	local recorded = ns.Recorder and ns.Recorder:GetState()
	recorded = recorded and recorded.entrances and instance.instanceID and recorded.entrances[instance.instanceID]
	if recorded and recorded.mapID and recorded.x then return recorded end
	return OnZoneMap(instance.zoneEntrance)
end

local mapInfoCache = {}
local function MapInfo(mapID)
	if mapInfoCache[mapID] == nil then
		local ok, info = pcall(C_Map.GetMapInfo, mapID)
		mapInfoCache[mapID] = ok and info or false
	end
	return mapInfoCache[mapID] or nil
end

-- Whether `ancestor` contains `mapID`, walking up the map tree.
local function IsAncestor(ancestor, mapID)
	local info = MapInfo(mapID)
	for _ = 1, 8 do
		if not info or not info.parentMapID or info.parentMapID == 0 then return false end
		if info.parentMapID == ancestor then return true end
		info = MapInfo(info.parentMapID)
	end
	return false
end

-- The entrance's place on another map, up the map tree (a zone's door on its continent) or
-- down it (a spot the client reports on the continent, as in Moonbrook's mine, on its zone):
-- through world coordinates, kept once worked out.
local positionCache = setmetatable({}, { __mode = "k" })
local function EntranceOn(entrance, mapID)
	if entrance.mapID == mapID then return entrance.x, entrance.y end
	local cache = positionCache[entrance]
	if not cache then
		cache = {}
		positionCache[entrance] = cache
	end
	local cached = cache[mapID]
	if cached == nil then
		cached = false
		if (IsAncestor(mapID, entrance.mapID) or IsAncestor(entrance.mapID, mapID)) and C_Map.GetWorldPosFromMapPos
			and C_Map.GetMapPosFromWorldPos and CreateVector2D then
			local ok, continentID, world = pcall(C_Map.GetWorldPosFromMapPos, entrance.mapID, CreateVector2D(entrance.x, entrance.y))
			if ok and continentID and world then
				local found, _, position = pcall(C_Map.GetMapPosFromWorldPos, continentID, world, mapID)
				if found and position then
					local x, y = position:GetXY()
					if x and x >= 0 and x <= 1 and y >= 0 and y <= 1 then cached = { x, y } end
				end
			end
		end
		cache[mapID] = cached
	end
	if cached then return cached[1], cached[2] end
	return nil
end

-- Whether a door is on the map shown as its pin is: on that very map, or on a zone it lies in
-- (a door given on the continent, or recorded there, on its zone).
function DungeonMap:DoorOnZone(entrance, mapID)
	if not (entrance and mapID) then return false end
	if entrance.mapID == mapID then return true end
	local info = MapInfo(mapID)
	return info ~= nil and info.mapType == MAP_TYPE_ZONE and EntranceOn(entrance, mapID) ~= nil
end

--[[
	Where an area below a zone's way down shows, and its place there: way = { x, y } on the
	map the client reports the area on (parentMapID), or on way.mapID; shown on way.showOn,
	else that same map. Moonbrook's mine is reported on the continent, but its way down shows
	on Westfall. A place entered some other way (the Deeprun Tram, by its tram icons) has none.
	A place with several ways in (Coldridge Pass, a tunnel with one at each end) has a list of
	them, as a dungeon with several doors on a picture has a list of points: an icon on each.
]]
local function Ways(subMap)
	local way = subMap.way
	if not way then return {} end
	return way[1] and way or { way }
end

-- One of its ways in (`way`), else its first.
local function WayPoint(subMap, way)
	way = way or Ways(subMap)[1]
	if not way then return nil end
	if not way.point then way.point = { mapID = way.mapID or subMap.parentMapID, x = way.x, y = way.y } end
	local showOn = way.showOn or way.point.mapID
	local x, y = EntranceOn(way.point, showOn)
	return showOn, x, y
end

local function EntrancesShown()
	local value = GetCVar and GetCVar(ENTRANCE_CVAR)
	return value == nil or value == "1"
end

--[[
	The pin's name at the top of the map, by the map's own SetAreaLabel and ClearAreaLabel callbacks: the
	one exception among the pins' writes, which otherwise go only to the journal's own frames (it writes
	the map's area label and its record of the events running). Nothing the client protects is called
	from there, and the map's quest pins never read them (UI/CanvasPins.lua).
]]
local function SetAreaLabel(pin, name, description)
	local map = pin:GetMap()
	if map and map.TriggerEvent and MAP_AREA_LABEL_TYPE then
		pcall(map.TriggerEvent, map, "SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, name, description)
	end
end

local function ClearAreaLabel(pin)
	local map = pin:GetMap()
	if map and map.TriggerEvent and MAP_AREA_LABEL_TYPE then
		pcall(map.TriggerEvent, map, "ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI)
	end
end

-- Doors closer than this on the map shown are one icon (a shared door, above).
local SHARED_DOOR = 0.01

-- "Dungeons  Level 30-45": the range they span together.
local function SharedDoorDescription(instances)
	local low, high
	for _, instance in ipairs(instances) do
		if instance.levelMin then
			low = math.min(low or instance.levelMin, instance.levelMin)
			high = math.max(high or 0, instance.levelMax or instance.levelMin)
		end
	end
	local kind = instances[1].kind == "raid" and L.ENTRANCE_RAIDS or L.ENTRANCE_DUNGEONS
	if not low then return kind end
	return kind .. "  " .. string.format(L.LEVEL_RANGE, low, high)
end

local function ShowSharedDoorTooltip(pin)
	local instances = pin.instances
	local name, description = SharedDoorName(instances), SharedDoorDescription(instances)
	SetAreaLabel(pin, name, description)
	GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(description, 1, 0.82, 0)
	AddDoorLines(instances)
	AddViaLine(instances[1])
	GameTooltip:AddLine(L.ENTRANCE_CHOOSE_LEFT_CLICK, 0.1, 1, 0.1)
	GameTooltip:AddLine(L.ENTRANCE_RIGHT_CLICK, 0.1, 1, 0.1)
	GameTooltip:Show()
end

local function ShowEntranceTooltip(pin)
	if #pin.instances > 1 then return ShowSharedDoorTooltip(pin) end
	local instance = pin.instance
	local description = EntranceDescription(instance)
	SetAreaLabel(pin, instance.name, description)
	GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
	GameTooltip:SetText(instance.name, 1, 1, 1)
	GameTooltip:AddLine(description, 1, 0.82, 0)
	AddViaLine(instance)
	GameTooltip:AddLine(L.ENTRANCE_LEFT_CLICK, 0.1, 1, 0.1)
	GameTooltip:AddLine(L.ENTRANCE_RIGHT_CLICK, 0.1, 1, 0.1)
	GameTooltip:Show()
end

-- Opens the instance in the journal, putting the world map away first (out of combat only).
function DungeonMap:OpenInstance(instance)
	ns.PlaySoundKit("IG_SPELLBOOK_OPEN")
	if WorldMapFrame and WorldMapFrame:IsShown() and not InCombatLockdown() and type(HideUIPanel) == "function" then
		pcall(HideUIPanel, WorldMapFrame)
	end
	ns.Journal:Show()
	ns.Journal:OpenInstance(instance)
end

--[[
	A waypoint: the client's own, where its waypoints work, else the journal's pin (UI/MapPin.lua).

	The journal never sets the client's waypoint itself. C_Map.SetUserWaypoint fires USER_WAYPOINT_UPDATED,
	an event the client hands out inside the call that caused it, and the map's own code hears it even
	while the map is closed: its map pin button (WorldMapTrackingPinButtonMixin) turns itself off and tells
	the map's waypoint provider, which keeps that as the state of its Ctrl+click placing. From the
	journal's call those writes carry the journal's taint, so the player's next pin placed on the map is
	set, and its pin drawn, from the journal's taint; with the map open, the map's waypoint pin is drawn
	again inside the journal's code at once. In combat the client then refuses the map's own pins
	(SetPassThroughButtons) and blames the journal (ADDON_ACTION_BLOCKED).

	So the journal offers the spot in the chat as the client's own map pin link: a click on it runs the
	client's code, which sets the waypoint and opens the map on it. While the map is open the spot is
	marked with the journal's own pin meanwhile. Once the client says the waypoint is there (heard on the
	journal's own frame), the journal's pin gives way and the journal says what was set (`said`). It does
	not track the waypoint (C_SuperTrack.SetSuperTrackedUserWaypoint): that is a write to the client's
	state whose SUPER_TRACKING_CHANGED the open map's waypoint provider answers by drawing its pin again,
	which from the journal's code would be the same taint, and the client's own map pins are left
	untracked as well (its Ctrl+click and its map pin link): the player clicks the pin to track it.

	The quest page's Show Start and Show End are that link themselves, over the whole button
	(UI/QuestsPanel.lua's link faces, written with WaypointLinkText): a click on one runs the client's
	own code, which sets the waypoint and opens the map on it, and says nothing, as the client's own map
	pin links do. None of the journal's own scripts or event handlers runs inside that click but the
	journal's OnHide and the face's OnLeave where the opening map puts the journal away (UI/QuestsPanel.lua);
	the map's own calls into the journal's map providers and hooks, made as on any opening of the map
	(M too), run under the client's secure execution. While the mouse is over a face a waiting chat
	offer is not heard (HoldOffer): the client hands its event out inside the click.
]]
local offered

-- The client's map pin link for a point (as C_Map.GetUserWaypointHyperlink writes one: the map, then
-- the point in ten-thousandths), named for the place.
local function WaypointLink(mapID, x, y, title)
	return string.format("|cffffff00|Hworldmap:%d:%d:%d|h[%s]|h|r", mapID, math.floor(x * 10000 + 0.5),
		math.floor(y * 10000 + 0.5), title or "")
end

-- The link's point, as the client reads it back.
local LINK_PRECISION = 0.00015

local waypointWatch = CreateFrame("Frame")
waypointWatch:SetScript("OnEvent", function()
	local waiting = offered
	if not (waiting and C_Map.GetUserWaypoint) then return end
	local ok, point = pcall(C_Map.GetUserWaypoint)
	local position = ok and point and point.position
	if not (position and point.uiMapID == waiting.mapID and math.abs(position.x - waiting.x) < LINK_PRECISION
		and math.abs(position.y - waiting.y) < LINK_PRECISION) then
		return
	end
	offered = nil
	ns.UnregisterEvents(waypointWatch, "USER_WAYPOINT_UPDATED")
	-- The journal's pin stood for it; the client's waypoint takes over.
	if waiting.marked and ns.MapPin:Target() == waiting.marked then ns.MapPin:Clear() end
	if waiting.said then ns.Print(waiting.said) end
end)

local function SetWaypointAt(mapID, x, y, title, said)
	local canSet = C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.GetUserWaypoint
	if canSet then
		local ok, allowed = pcall(C_Map.CanSetUserWaypointOnMap, mapID)
		canSet = ok and allowed
	end
	if not canSet then
		ns.MapPin:Show({ mapID = mapID, x = x, y = y }, title)
		if said then ns.Print(said) end
		return
	end
	local marked
	if WorldMapFrame and WorldMapFrame:IsShown() then marked = ns.MapPin:Put({ mapID = mapID, x = x, y = y }, title) end
	offered = { mapID = mapID, x = x, y = y, marked = marked, said = said }
	ns.RegisterEvents(waypointWatch, "USER_WAYPOINT_UPDATED")
	ns.PlaySoundKit("UI_MAP_WAYPOINT_CONTROL_CLICK")
	ns.Print(string.format(L.WAYPOINT_OFFER, WaypointLink(mapID, x, y, title)))
end

-- The waypoint the chat offers, for the smoke test: { mapID, x, y }, or nil.
function DungeonMap:OfferedWaypoint()
	return offered
end

-- The chat offer's event not heard while the mouse is over a link face (`by` held), heard again once
-- it is over none (above): one face shown or let go does not free the one the mouse is on.
local holding = {}
function DungeonMap:HoldOffer(by, held)
	holding[by] = held or nil
	if next(holding) then
		ns.UnregisterEvents(waypointWatch, "USER_WAYPOINT_UPDATED")
	elseif offered then
		ns.RegisterEvents(waypointWatch, "USER_WAYPOINT_UPDATED")
	end
end

-- The client's map pin link for a point, its text `text` as written (UI/QuestsPanel.lua's link faces),
-- or nil where the client allows no waypoint on that map.
function DungeonMap:WaypointLinkText(mapID, x, y, text)
	if not (mapID and x and y and C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.GetUserWaypoint) then return nil end
	local ok, allowed = pcall(C_Map.CanSetUserWaypointOnMap, mapID)
	if not (ok and allowed) then return nil end
	return string.format("|Hworldmap:%d:%d:%d|h%s|h", mapID, math.floor(x * 10000 + 0.5), math.floor(y * 10000 + 0.5), text or "")
end

-- For the journal's other map pins (UI/TravelMap.lua).
function DungeonMap:MapInfo(mapID) return MapInfo(mapID) end
-- A point { mapID, x, y } on another map, or nil when it is not on it.
function DungeonMap:PositionOn(point, mapID) return EntranceOn(point, mapID) end
-- A waypoint offered on a point, titled `title`; `said` is said once it is set.
function DungeonMap:SetWaypointAt(mapID, x, y, title, said) SetWaypointAt(mapID, x, y, title, said) end
function DungeonMap:SetAreaLabel(pin, name, description) SetAreaLabel(pin, name, description) end
function DungeonMap:ClearAreaLabel(pin) ClearAreaLabel(pin) end

-- A waypoint to the instance's door; for one reached through an area below the zone, to the
-- way down (its first, where it has several), since the door itself cannot be walked to from the
-- streets. `title` names a door several share (the Scarlet Monastery's).
function DungeonMap:SetWaypoint(instance, title)
	local via = instance.via and ns.GetSubMap(instance.via)
	if via then
		local wayMapID, x, y = WayPoint(via)
		if not x then return false end
		local said
		if IsBuilding(via) then
			said = string.format(L.ENTRANCE_WAYPOINT_SET, title or via.name)
		elseif via.name == instance.name then
			-- A way in named for the dungeon itself (Maraudon's caves): the name once.
			said = string.format(L.CAVE_WAYPOINT_SET, via.name)
		else
			said = string.format(L.ENTRANCE_WAYPOINT_VIA, via.name, instance.name)
		end
		SetWaypointAt(wayMapID, x, y, via.name, said)
		return true
	end
	local entrance = self:Entrance(instance)
	if not entrance then return false end
	SetWaypointAt(entrance.mapID, entrance.x, entrance.y, title or instance.name,
		string.format(L.ENTRANCE_WAYPOINT_SET, title or instance.name))
	return true
end

-- Shows an area below a zone over the world map, as retail's cave links do.
function DungeonMap:ShowSubMap(subMap)
	if not (provider and WorldMapFrame:IsShown() and WayInsOn()) then return false end
	forced = { subMap = subMap, mapID = WorldMapFrame:GetMapID() }
	dismissed = false
	ns.PlaySoundKit("IG_QUEST_LOG_OPEN")
	provider:RefreshAllData()
	return true
end

-- Another level of an area below a zone, from its menu: that level's picture over the map shown,
-- the one the client places on this zone where the level has one here. The player's own level is
-- not held: the map goes on following them from level to level.
function DungeonMap:ShowLevel(subMap, index)
	if not WayInsOn() then return false end
	local mapID = WorldMapFrame:GetMapID()
	local choice
	for _, other in ipairs(ns.GetSubMaps()) do
		if other.levels == subMap.levels and other.level == index then
			if other.parentMapID == mapID then
				choice = other
				break
			end
			choice = choice or other
		end
	end
	if choice and provider and WorldMapFrame:IsShown() and choice == PlayerSubMap(mapID) then
		forced, dismissed, homeMapID = nil, false, mapID
		ns.PlaySoundKit("IG_QUEST_LOG_OPEN")
		provider:RefreshAllData()
		return true
	end
	return choice ~= nil and self:ShowSubMap(choice)
end

-- Another of a place's pictures, from its menu (views): a view only shows, held while the map is
-- open, as a level picked from a menu is. The picture that shows by itself, where the player is
-- in the place, is not held: the map goes on following them (between Maraudon's two placements).
function DungeonMap:ShowView(subMap, index)
	if not WayInsOn() then return false end
	local choice = subMap.views and ns.GetSubMap(subMap.views[index])
	if not choice then return false end
	local mapID = WorldMapFrame:GetMapID()
	local below = not choice.viewOnly and provider and WorldMapFrame:IsShown() and PlayerSubMap(mapID)
	if below and below.views == subMap.views then
		forced, dismissed, homeMapID = nil, false, mapID
		ns.PlaySoundKit("IG_QUEST_LOG_OPEN")
		provider:RefreshAllData()
		return true
	end
	return self:ShowSubMap(choice)
end

-- The art at the atlas's size (32 when the client gives none), the pin no bigger than the icon in it.
local function SizeToIcon(pin)
	local width, height = pin.Texture:GetSize()
	if not width or width <= 0 then width, height = 32, 32 end
	pin.Texture:SetSize(width, height)
	pin:SetSize(math.min(width, PIN_HIT_SIZE), math.min(height, PIN_HIT_SIZE))
end

AegisJournalEntrancePinMixin = {}
local EntrancePinMethods = {}

function EntrancePinMethods:OnLoad()
	self.Texture = self:CreateTexture(nil, "ARTWORK")
	self.Texture:SetPoint("CENTER")
	self.HighlightTexture = self:CreateTexture(nil, "HIGHLIGHT")
	self.HighlightTexture:SetBlendMode("ADD")
	self.HighlightTexture:SetAlpha(0.4)
	self.HighlightTexture:SetAllPoints(self.Texture)
	self:SetScalingLimits(1, 1.0, 1.2)
	self:UseFrameLevelType("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
end

-- Retail's glow for a pin its map legend points at (shared with the journal's other pins).
function EntrancePinMethods:ShowMapLegendGlow()
	if not self.legendGlow then
		self.legendGlow = self:CreateTexture(nil, "BACKGROUND")
		self.legendGlow:SetPoint("TOPLEFT", self, "TOPLEFT", -18, 18)
		self.legendGlow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 18, -18)
		self.legendGlow:SetAtlas(LEGEND_GLOW_ATLAS)
	end
	self.legendGlow:Show()
end

function EntrancePinMethods:HideMapLegendGlow()
	if self.legendGlow then self.legendGlow:Hide() end
end

DungeonMap.ShowMapLegendGlow = EntrancePinMethods.ShowMapLegendGlow
DungeonMap.HideMapLegendGlow = EntrancePinMethods.HideMapLegendGlow

function EntrancePinMethods:LegendKind()
	return self.isRaid and "raid" or "dungeon"
end

-- `together`: every instance behind this door, when several share it (in the journal's order).
function EntrancePinMethods:OnAcquired(instance, x, y, together)
	self.instance, self.instances = instance, together or { instance }
	self.isRaid = instance.kind == "raid"
	self:HideMapLegendGlow()
	local atlas = self.isRaid and RAID_ATLAS or DUNGEON_ATLAS
	self.Texture:SetAtlas(atlas, true)
	self.HighlightTexture:SetAtlas(atlas, true)
	SizeToIcon(self)
	self:SetPosition(x, y)
end

-- Both buttons belong to the pin: right-click sets the waypoint instead of zooming out.
function EntrancePinMethods:ShouldMouseButtonBePassthrough() return false end

function EntrancePinMethods:OnMouseEnter()
	ShowEntranceTooltip(self)
	ns.MapLegend:PinEnter(self:LegendKind())
end

function EntrancePinMethods:OnMouseLeave()
	ClearAreaLabel(self)
	GameTooltip:Hide()
	ns.MapLegend:PinLeave(self:LegendKind())
end

function EntrancePinMethods:OnMouseClickAction(button)
	local instances = self.instances
	if button == "RightButton" then
		DungeonMap:SetWaypoint(self.instance, #instances > 1 and SharedDoorName(instances) or nil)
	elseif not (#instances > 1 and ChooseDoor(self, instances)) then
		DungeonMap:OpenInstance(self.instance)
	end
end

-- The way into an area below a zone: retail's cave entrance, or a building's delve entrance
-- (icon = "building"). A left click shows the area's map, a right click sets a waypoint to its
-- way in, the one this icon stands on where it has several.
AegisJournalCavePinMixin = {}
local CavePinMethods = {}

CavePinMethods.OnLoad = EntrancePinMethods.OnLoad
CavePinMethods.ShowMapLegendGlow = EntrancePinMethods.ShowMapLegendGlow
CavePinMethods.HideMapLegendGlow = EntrancePinMethods.HideMapLegendGlow
-- Its legend entry, Cave Entrance or Entrance (a building's); the journal's legend hook matches it by style.
function CavePinMethods:LegendKind() return WayKind(self.subMap) end
function CavePinMethods:GetStyle() return self:LegendKind() end

function CavePinMethods:OnAcquired(subMap, x, y)
	self.subMap, self.wayX, self.wayY = subMap, x, y
	self:HideMapLegendGlow()
	for _, atlas in ipairs(IsBuilding(subMap) and BUILDING_ATLASES or CAVE_ATLASES) do
		if ns.AtlasExists(atlas) then
			self.Texture:SetAtlas(atlas, true)
			self.HighlightTexture:SetAtlas(atlas, true)
			break
		end
	end
	SizeToIcon(self)
	self:SetPosition(x, y)
end

CavePinMethods.ShouldMouseButtonBePassthrough = EntrancePinMethods.ShouldMouseButtonBePassthrough

function CavePinMethods:OnMouseEnter()
	local subMap = self.subMap
	SetAreaLabel(self, subMap.name, IsBuilding(subMap) and L.BUILDING_LABEL or L.CAVE_LABEL)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(subMap.name, 1, 1, 1)
	-- Each dungeon it leads to, by name (the Scarlet Monastery's hall leads to four), with those
	-- further in, on another of its pictures (alsoLeadsTo: Blackrock Depths, below the ring).
	local leadsTo = {}
	for key in pairs(subMap.instances) do
		local instance = ns.GetInstance(key)
		if instance then leadsTo[#leadsTo + 1] = instance.name end
	end
	for _, key in ipairs(subMap.alsoLeadsTo or {}) do
		local instance = ns.GetInstance(key)
		if instance then leadsTo[#leadsTo + 1] = instance.name end
	end
	table.sort(leadsTo)
	for _, name in ipairs(leadsTo) do GameTooltip:AddLine(string.format(L.CAVE_LEADS_TO, name), 1, 0.82, 0) end
	GameTooltip:AddLine(string.format(L.CAVE_LEFT_CLICK, subMap.name), 0.1, 1, 0.1)
	GameTooltip:AddLine(L.ENTRANCE_RIGHT_CLICK, 0.1, 1, 0.1)
	GameTooltip:Show()
	ns.MapLegend:PinEnter(self:LegendKind())
end

CavePinMethods.OnMouseLeave = EntrancePinMethods.OnMouseLeave

function CavePinMethods:OnMouseClickAction(button)
	local subMap = self.subMap
	if button == "RightButton" then
		SetWaypointAt(self:GetMap():GetMapID(), self.wayX, self.wayY, subMap.name,
			string.format(IsBuilding(subMap) and L.ENTRANCE_WAYPOINT_SET or L.CAVE_WAYPOINT_SET, subMap.name))
	else
		DungeonMap:ShowSubMap(subMap)
	end
end

--[[
	No events through the map. A provider's RegisterEvent counts each event in one table the map keeps
	for all its providers (MapCanvasMixin's dataProviderEventsCount), which the client's own providers
	read as they register theirs; a count the journal wrote is tainted, and so is everything the client's
	quest provider then registers on the strength of it, so its quest pins can come to be drawn from
	the journal's taint and be blocked in combat. The "Dungeon Entrances" setting is heard by the
	journal's own frame instead (UI/MapLegend.lua: DungeonMap:SettingChanged).
]]
local EntranceProviderMethods = {}

function EntranceProviderMethods:RemoveAllData()
	ns.CanvasPins:ReleaseAll(ENTRANCE_PIN_TEMPLATE)
	ns.CanvasPins:ReleaseAll(CAVE_PIN_TEMPLATE)
end

function EntranceProviderMethods:RefreshAllData()
	self:RemoveAllData()
	if not EntrancesShown() then return end
	local map = self:GetMap()
	local mapID = map:GetMapID()
	local info = mapID and MapInfo(mapID)
	if not info or (info.mapType ~= MAP_TYPE_CONTINENT and info.mapType ~= MAP_TYPE_ZONE) then return end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		local doors = {}
		-- Hidden from the map legend: none of this kind.
		for _, instance in ipairs(ns.MapLegend.Shows(kind) and ns.GetInstances(kind) or {}) do
			local entrance = DungeonMap:Entrance(instance)
			local x, y
			if entrance then x, y = EntranceOn(entrance, mapID) end
			if x then
				local shared
				for _, door in ipairs(doors) do
					if math.abs(door.x - x) < SHARED_DOOR and math.abs(door.y - y) < SHARED_DOOR then
						shared = door
						break
					end
				end
				if shared then
					shared.instances[#shared.instances + 1] = instance
				else
					doors[#doors + 1] = { x = x, y = y, instances = { instance } }
				end
			end
		end
		for _, door in ipairs(doors) do
			ns.CanvasPins:Acquire(map, ENTRANCE_PIN_TEMPLATE, door.instances[1], door.x, door.y, door.instances)
		end
	end
	-- Caves and buildings' entrances show on their own zone's map only, as on retail; each kind
	-- hidden from the map legend on its own. A view only (one cave of Maraudon's on its own map) has
	-- none: it is reached from its place's menu. Each of a place's ways in has its icon.
	for _, subMap in ipairs(ns.GetSubMaps()) do
		for _, way in ipairs(subMap.viewOnly and {} or Ways(subMap)) do
			local wayMapID, x, y = WayPoint(subMap, way)
			if wayMapID == mapID and x and ns.MapLegend.Shows(WayKind(subMap)) then
				ns.CanvasPins:Acquire(map, CAVE_PIN_TEMPLATE, subMap, x, y)
			end
		end
	end
end

local entranceProvider

-- Joins the world map once it exists.
local function SetUp()
	if provider then return true end
	if not (WorldMapFrame and WorldMapFrame.AddDataProvider and MapCanvasDataProviderMixin and MapCanvasPinMixin) then
		return false
	end
	local canvasPin = ns.CanvasPins.Methods
	Mixin(AegisJournalBossPinMixin, MapCanvasPinMixin, canvasPin, BossPinMethods)
	Mixin(AegisJournalEntrancePinMixin, MapCanvasPinMixin, canvasPin, EntrancePinMethods)
	Mixin(AegisJournalCavePinMixin, MapCanvasPinMixin, canvasPin, CavePinMethods)
	provider = CreateFromMixins(MapCanvasDataProviderMixin, ProviderMethods)
	entranceProvider = CreateFromMixins(MapCanvasDataProviderMixin, EntranceProviderMethods)
	WorldMapFrame:AddDataProvider(provider)
	WorldMapFrame:AddDataProvider(entranceProvider)
	return true
end

function DungeonMap:Refresh()
	if provider and WorldMapFrame:IsShown() then provider:RefreshAllData() end
end

-- The dungeon and raid doors and the caves drawn again (a legend switch).
function DungeonMap:RefreshEntrances()
	if entranceProvider and WorldMapFrame:IsShown() then entranceProvider:RefreshAllData() end
end

-- A game setting changed (CVAR_UPDATE, heard by UI/MapLegend.lua's own frame): the client's "Dungeon
-- Entrances" map option turns the doors off and on.
function DungeonMap:SettingChanged(name)
	if name == ENTRANCE_CVAR then self:RefreshEntrances() end
end

------------------------------------------------------------------------------------------
-- From the journal
------------------------------------------------------------------------------------------

--[[
	The journal never sets which map the world map shows; it only opens the map, and draws over the map
	that shows. The client hands some events out inside the call that caused them (its docs mark them
	synchronous), and their handlers then run inside the caller's code: WORLD_MAP_OPEN, which
	C_Map.OpenWorldMap fires, CVAR_UPDATE (SetCVar), USER_WAYPOINT_UPDATED (C_Map.SetUserWaypoint). So
	C_Map.OpenWorldMap(mapID), the global OpenWorldMap(mapID) and WorldMapFrame:SetMapID, called from the
	journal, all run the map's own SetMapID inside the journal's code, which writes the map's mapID from
	the journal's taint. That mapID is read again each time the map opens (WorldMapMixin:OnShow's
	SetMapID reads it before it writes it), so every later opening, even by the M key, redraws the
	client's own pins from the journal's taint; in combat the client then refuses their
	SetPassThroughButtons and blames the journal (ADDON_ACTION_BLOCKED), until the next /reload.
	ShowUIPanel(WorldMapFrame), what the client's OpenWorldMap does with no map asked for, opens it on the
	player's own map through the window manager's secure code; it is refused in combat, as is any addon's.
	Those calls of the client's (C_Map.OpenWorldMap, SetCVar on its map filters, C_Map.SetUserWaypoint, and
	the map's own pin calls: UI/CanvasPins.lua) are for the player's own clicks and the client's own code,
	never the journal's (Tools/wow_mock.lua notes each as a map taint, and the smoke test wants none).
]]
local function OpenWorld()
	if not WorldMapFrame then return false end
	if WorldMapFrame:IsShown() then return true end
	if InCombatLockdown() or type(ShowUIPanel) ~= "function" then return false end
	pcall(ShowUIPanel, WorldMapFrame)
	return WorldMapFrame:IsShown() == true
end

-- Opens the world map on the player's own map, or keeps the one open (UI/MapPin.lua).
function DungeonMap:OpenWorld()
	return OpenWorld()
end

-- Shows the dungeon's map over the world map: the map that shows, or the player's own as it opens. A
-- dungeon the client has a map of is drawn from that map's own tiles; where the map shows that dungeon
-- already (the player is inside it), its own floor menu stays. The journal's Show Map: always the
-- dungeon's own map, wherever the player is (the owner, 2026-11-11), never the picture of its way in
-- first; those stay a click away on their zone's map, by their cave's or building's icon.
function DungeonMap:Show(instance, floorIndex)
	local floors = Floors(instance)
	if not floors or #floors == 0 then return false end
	if InCombatLockdown() then
		ns.Print(L.MAP_PIN_COMBAT)
		return false
	end
	if not SetUp() or not OpenWorld() then return false end
	local shown = FloorByMapID(WorldMapFrame:GetMapID())
	if shown and shown.instance == instance and self:IsNative(floors[shown.index]) then
		-- Its own map: another dungeon shown over it before goes.
		if forced then
			forced, dismissed = nil, false
			provider:RefreshAllData()
		end
		return true
	end
	chosenFloor[instance.key] = floorIndex or chosenFloor[instance.key]
	follow.picked = follow.picked or floorIndex ~= nil
	if floorIndex then follow.Picked(instance) end
	forced = { instance = instance, mapID = WorldMapFrame:GetMapID(), floor = floorIndex or 1 }
	dismissed = false
	provider:RefreshAllData()
	return true
end

-- The overlay's state, for the smoke test.
function DungeonMap:Overlay()
	return overlay
end

-- The floor menu's step on the map's location bar, once made.
function DungeonMap:FloorStep()
	return crumb
end

------------------------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------------------------

-- Being below a zone depends on the streets the player walked through, so inside a zone with
-- an area below, its streets are followed even while the map is closed. On an area's levels
-- (Blackrock Mountain's) the level can change with no new name (the north room's stair reads
-- "Blackrock Spire" from the room up to the ring's high walkway), and where one level lies over
-- another the level the player was last seen on keeps them; on one picture placed twice
-- (Maraudon's caves, follow = true) the placement changes with no new name too. By a way down
-- under the name of the rooms above (Old Ironforge's, in The High Seat: the throne room and the
-- way down alike) the step onto it or off it brings no new name, and the walk down is told by
-- where the player was just before. There their position is followed (FOLLOW_SECONDS), and an
-- open map turns as they reach another level, placement or way; below, with the area's own name,
-- only a new name changes anything, and the following stops.
local BELOW_EVENTS = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "MINIMAP_UPDATE_ZOOM" }
-- The watch on the streets (its events) and its following (a ticker, while one runs) live in ways: the file
-- is at Lua's 200 locals.
ways.watch = CreateFrame("Frame")

-- What an open map shows for the area the player is below: its level, or the sub-map itself.
local function ShownFor(subMap)
	if subMap and subMap.levels then return subMap.level end
	return subMap
end

function Follow()
	local following = ways.near or (playerBelow ~= nil and (playerBelow.levels ~= nil or playerBelow.follow == true))
	if following and not ways.follow and C_Timer and C_Timer.NewTicker then
		ways.follow = C_Timer.NewTicker(FOLLOW_SECONDS, function()
			local before = playerBelow
			ways.cause, ways.causeAt = "following", GetTime()
			PlayerSubMap()
			ways.cause = nil
			-- Only a new level or placement redraws: the ring's copy on Searing Gorge for the one on
			-- Burning Steppes is the same level, as a zone change leaves it. A step onto a way down (from
			-- the throne room onto Old Ironforge's) turns an open map that shows the zone's own map too.
			local turned = ShownFor(playerBelow) ~= ShownFor(before)
			if turned and overlay and overlay:IsShown() and overlay.subMap then
				UpdateOverlay()
			elseif turned and ((playerBelow and playerBelow.wayDown) or (before and before.wayDown))
				and WorldMapFrame and WorldMapFrame:IsShown() then
				UpdateOverlay()
			end
			Follow()
		end)
	elseif not following and ways.follow then
		ways.follow:Cancel()
		ways.follow = nil
	end
end

ways.watch:SetScript("OnEvent", function(_, event)
	ways.cause, ways.causeAt = event, GetTime()
	PlayerSubMap()
	Follow()
	ways.cause = nil
end)

--[[
	Out of a dungeon whose key a way down keeps (the Hall of Thanes), the first readings after the loading
	screen may give another map or none, and the zone change into the city may already be past: the
	streets' events stay heard while the key is kept, and the reading is tried again a little later
	(ways.RETRY_SECONDS, at most ways.RETRIES times after each zone change, a timer that ends by itself),
	so that the player is read at the portal before they walk off it.
]]
ways.RETRY_SECONDS, ways.RETRIES = 1, 3
local function WatchBelow(retry)
	if not retry then ways.retries = 0 end
	local on = WayInsOn()
	local mapID = on and ns.PlayerMapPosition()
	local watched = false
	for _, subMap in ipairs(ns.GetSubMaps()) do
		if mapID and subMap.parentMapID == mapID then
			ns.RegisterEvents(ways.watch, unpack(BELOW_EVENTS))
			PlayerSubMap()
			watched = true
			break
		end
	end
	if not watched then
		ns.UnregisterEvents(ways.watch, unpack(BELOW_EVENTS))
		playerBelow, ways.near = nil, nil
		-- Off any picture's map: inside one of a way down's dungeons, or gone (ways.Walked). With the way-in
		-- maps off nothing follows the player, and what they were there is forgotten.
		for _, subMap in ipairs(ns.GetSubMaps()) do
			if subMap.wayDown then
				if on then ways.Walked(subMap, mapID or nil) else ways.Remember(subMap, nil) end
			end
		end
	end
	-- Out of the dungeon with its key still kept, on whatever map (above).
	local kept = false
	for _, subMap in ipairs(ns.GetSubMaps()) do
		local state = subMap.wayDown and subMap.instances and ways.Where(subMap)
		if state and subMap.instances[state] then kept = true end
	end
	if on and kept and not CurrentInstance() then
		ns.RegisterEvents(ways.watch, unpack(BELOW_EVENTS))
		if not ways.retrying and (ways.retries or 0) < ways.RETRIES and C_Timer and C_Timer.After then
			ways.retries = (ways.retries or 0) + 1
			ways.retrying = true
			C_Timer.After(ways.RETRY_SECONDS, function()
				ways.retrying = nil
				local cause, causeAt = ways.cause, ways.causeAt
				ways.cause, ways.causeAt = "retry", GetTime()
				WatchBelow(true)
				ways.cause, ways.causeAt = cause, causeAt
			end)
		end
	end
	Follow()
end

-- The journal's style changed (UI/MapLegend.lua): the player's area below a zone followed or not, and
-- the overlay and the doors drawn again.
function DungeonMap:StyleChanged()
	ways.cause, ways.causeAt = "style", GetTime()
	WatchBelow()
	ways.cause = nil
	self:Refresh()
	self:RefreshEntrances()
end

local events = CreateFrame("Frame")
local wasInside = false
ns.RegisterEvents(events, "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_END")
events:SetScript("OnEvent", function(_, event, ...)
	ways.cause, ways.causeAt = event, GetTime()
	if event == "PLAYER_LOGIN" then
		SetUp()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		WatchBelow()
	elseif event == "PLAYER_ENTERING_WORLD" then
		local login, reload = ...
		SetUp()
		WatchBelow()
		-- A new run starts on coming in from outside; a corpse run back in keeps its kills, and so do a /reload,
		-- a login inside (the server puts a player whose run is gone at the way in, outside) and coming back
		-- within SAME_RUN_SECONDS of stepping out (when each dungeon was left is kept with the character).
		local instance = CurrentInstance()
		local ghost = UnitIsDeadOrGhost and UnitIsDeadOrGhost("player")
		local stayed = ns.Readable(login) == true or ns.Readable(reload) == true
		local now, db = time(), ns.charDB
		local leftAt = db and db.defeatedLeftAt or {}
		if db then db.defeatedLeftAt = leftAt end
		if wasInside and wasInside ~= (instance and instance.key) then leftAt[wasInside] = now end
		-- Left by any part of the same copy (Stratholme's other gate): the latest of them.
		local copy = instance and ns.Run and ns.Run.SameCopy(instance) or { instance }
		local left
		for _, part in ipairs(copy) do
			if leftAt[part.key] and not (left and left > leftAt[part.key]) then left = leftAt[part.key] end
		end
		local sameRun = left and now >= left and now - left <= DungeonMap.SAME_RUN_SECONDS
		-- A new run clears every part of that copy (DungeonMap:ClearRun), and starts the run block's clock.
		local newRun = instance and not wasInside and not ghost and not stayed and not sameRun
		if newRun then DungeonMap:ClearRun(instance) end
		for _, part in ipairs(copy) do leftAt[part.key] = nil end
		wasInside = instance and instance.key or false
		WatchDeaths(instance)
		if ns.Run then ns.Run:Entered(instance, newRun and true or false, login, reload) end
		DungeonMap:Refresh()
	elseif event == "ENCOUNTER_END" then
		local encounterID, name, _, _, success = ...
		if ns.Readable(success) == 1 then
			local instance = CurrentInstance()
			for _, boss in ipairs(BossesForEncounter(instance, ns.Readable(encounterID), ns.Readable(name))) do
				DungeonMap:MarkDefeated(instance, boss)
			end
		end
	end
	ways.cause = nil
end)

-- A reset makes every dungeon the player has left a fresh one, so coming back in is a new run however soon: the
-- client's "%s has been reset." (INSTANCE_RESET_SUCCESS) forgets when each was left (the release review of
-- 2026-11-10). A raid keeps its time, as a reset leaves raids as they are. Best guess: whether the party's other
-- members get the message when their leader resets; if not, theirs still waits out the half hour.
local RESET_TEXT
do
	local text = type(INSTANCE_RESET_SUCCESS) == "string" and INSTANCE_RESET_SUCCESS or "%s has been reset."
	text = text:gsub("%%%d?%$?s", "\001") -- the dungeon's name, wherever the language puts it
	text = text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
	RESET_TEXT = "^" .. text:gsub("\001", ".+") .. "$"
end
local resets = CreateFrame("Frame")
ns.RegisterEvents(resets, "CHAT_MSG_SYSTEM")
resets:SetScript("OnEvent", function(_, _, text)
	text = ns.Readable(text)
	local leftAt = ns.charDB and ns.charDB.defeatedLeftAt
	if not (leftAt and type(text) == "string" and text:find(RESET_TEXT)) then return end
	for key in pairs(leftAt) do
		local instance = ns.GetInstance(key)
		if not (instance and instance.kind == "raid") then leftAt[key] = nil end
	end
	-- The run block's run, left outside, is over too (Core/Run.lua).
	if ns.Run then ns.Run:Reset() end
end)
