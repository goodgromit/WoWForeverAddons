local addonName, ns = ...
local L = ns.L

--[[
	Fog of war on the dungeon maps (0.40 Adventure Mode). A dungeon with fog data (Data/Fog, one file a
	dungeon, ns.AddFog) is drawn under fog, the map's name and the way in clear; each boss this character
	kills clears its room and the way back to what was clear already; once every boss that holds the fog back
	(Counts) on one of its maps is dead that map clears whole, and once every one in the dungeon is the whole fog
	goes (the owner's rules of 2026-11-13: Resolve's standing and whole, State's floorClear). A boss not yet
	killed has no pin of its own: a hint waits at its spot instead, a round picture in the boss list's gold band:
	the game's own unknown-boss picture (UNKNOWN_BOSS)
	while the character has not met it, its real portrait once met (as the journal's boss list names it:
	Core/Discovery.lua's Unmet, so outside Adventure Mode every boss reads as met). On in Adventure
	Mode; in the other styles a box in the options turns it on for the character (charDB.dungeonFog). Kills
	are Core/Discovery.lua's (killed: the fight won, or the boss's own loot taken), kept for the character, so
	what is clear stays clear. On a dungeon with no fog, in Adventure Mode, a boss not met yet waits as the same
	hint with the unknown-boss picture, and has its pin once met (HintsBoss).

	Everything here is the journal's own: a frame in the dungeon map's overlay (UI/DungeonMap.lua) holding
	the journal's own parchment (the game's book page, UI-EJ-JournalBG, a 3:2 crop of its right page tinted
	toward the map's paper, opaque) under one shared mask that keeps the map sheet's own frame in sight
	(Media/Fog/Frame: its torn rim, burnt margin and gold corners, the same on every classic map), and, for
	each piece of the map that is clear, a clean copy of the floor's picture under that piece's mask; and
	buttons of its own for the hints, built as the boss pins are (UI/DungeonMap.lua's BuildBossPin). No
	map setter, no pin of the map's, nothing written into the world map: it is drawn from inside the map's
	refresh, in combat too (the rules above UI/DungeonMap.lua's OpenWorld and in UI/CanvasPins.lua).

	The fog data's format is Dev/maps/RagefireChasmFog/spec.md's (section 3, less its wash and opacity, gone with
	the October look; the look is Dev/maps/FogBuilder/README.md's): floors by picture name or
	client map ID, pieces as boxes of the visible picture, nodes in a tree from the start ones, each cleared
	by its boss's kill, with the way back to its `back` node; a floor's extent (where fog lies at all, its
	rects kept clear baked in) masks the parchment as well. The masks, the frame's among them, and the
	previews of this look are Dev/maps/FogBuilder's (fogcore.py's "The look" holds the same numbers).
]]

local DungeonFog = {}
ns.DungeonFog = DungeonFog

local FOLDER = "Interface\\AddOns\\" .. addonName .. "\\Media\\Fog\\"
-- The parchment (the owner's pick, 2026-11-06): the journal's own book page (file 521750), a 3:2 crop of its
-- right page, so the grain stretches evenly over the 1002 x 668 map, tinted toward the map's paper, opaque.
local PARCHMENT = "Interface\\EncounterJournal\\UI-EJ-JournalBG"
local PARCHMENT_COORDS = { 0.4668, 0.7334, 0.0781, 0.4336 }
local PARCHMENT_TINT = { 0.90, 0.92, 0.80 }
-- The map sheet's frame kept in sight: 0 on its torn rim, burnt margin and gold corners, the parchment fading in
-- 5 to 32 px inside them. One for every floor, made from the game's own map art.
local FRAME_MASK = FOLDER .. "Frame"
--[[
	A boss not met (the owner's pick, 2026-11-06): the journal's own unknown-boss picture (file 521744, 128 x 64:
	a black creature with a red rim and a red "?"), cut to the portrait's circle with the circle's centre on its
	pixel (x, y) and a radius of `radius` of its pixels: the "?" a little below the middle, the top of the rim
	arcing across the upper part, the picture's bottom edge out of sight. Where the circle reaches past the
	picture (above its top), a black disc shows beneath.
]]
local UNKNOWN_BOSS = { file = "Interface\\EncounterJournal\\UI-EJ-BOSS-Default", width = 128, height = 64,
	x = 62, y = 26, radius = 31 }
-- The boss list's gold band round a hint's portrait (ns.PortraitBand): its width at the pins' portrait size.
local BAND = 3
-- Above the overlay: the picture is +1, the fog +2, the player's area +5, the floors' ways (drawn in every state) and
-- the places worth knowing (map spots: only where the fog has cleared, Covers) +8, the hints +9, the boss pins +10 and
-- +11.
local FOG_LEVEL, HINT_LEVEL = 2, 9
-- A piece's mask is 0 on its edge texels; past them it stays 0.
local PIECE_WRAP = "CLAMPTOBLACKADDITIVE"
-- A classic map's tiles: 4 x 3 squares of 256, of which the top-left 1002 x 668 is the map.
local TILE_COLUMNS, TILE_ROWS, TILE_SIZE = 4, 3, 256
local TILE_MAP_WIDTH, TILE_MAP_HEIGHT = 1002, 668
-- What a dungeon with no fog, or a floor with nothing cleared, reads as: one table, never written, so the
-- zoom path makes none.
local NONE = {}
--[[
	A floor's where grid (Covers; Dev/maps/FogBuilder/where.py): the visible picture cut into cols x rows cells, one
	string a row of runs <count><symbol>, "." where no piece is, else the symbol's place here naming the word of the
	grid's keys at that place: one piece, or several joined by "+" where their masks overlap at a seam. Built from the
	masks as the game draws them, so a cell reads clear only where a piece shown lies at half or more.
]]
local WHERE_SYMBOLS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&'()*,-/:;<=>?@[]^_`{|}~"
local WHERE_INDEX = {}
for position = 1, #WHERE_SYMBOLS do WHERE_INDEX[WHERE_SYMBOLS:sub(position, position)] = position end

------------------------------------------------------------------------------------------
-- On or off
------------------------------------------------------------------------------------------

-- Always in Adventure Mode; in any other style, the character's own box in the options.
function DungeonFog:On()
	if ns.Style:Adventure() then return true end
	return ns.charDB ~= nil and ns.charDB.dungeonFog == true
end

-- The character's own choice, outside Adventure Mode (the options' box, UI/Options.lua, and the map legend's Fog of
-- War switch, UI/MapLegend.lua): an open map drawn again with it.
function DungeonFog:SetChosen(on)
	if not ns.charDB then return end
	ns.charDB.dungeonFog = on and true or nil
	ns.DungeonMap:Refresh()
end

local function PlayerFaction()
	if type(UnitFactionGroup) ~= "function" then return nil end
	local ok, faction = pcall(UnitFactionGroup, "player")
	return ok and ns.Readable(faction) or nil
end

local function BossKey(boss)
	return ns.Discovery.BossKey(boss)
end

--[[
	Whether a boss holds the fog back (a map clears once every one of these on it is dead, the whole fog once
	every one in the dungeon is): one of the dungeon's bosses that may never be recorded killed holds nothing
	back (the owner's rule of 2026-11-13), by the journal's own flags, never by name: not its trash, not a rare
	(he may not be there), a maybe, one called up (summoned), a quest's target (questTarget: the Excavation
	Site's Highland Horror), one outside the run, one left uncounted or one coming soon (Core/Run.lua's Counted,
	plus summoned, the fog's own); not one the journal hides as not in the game yet; and one this side can meet
	(faction). The data's counts map has the last word for a boss by name (spared, quest-locked, never
	recorded). With faction nil, either side's. Such a boss's own room still clears with his kill: he only never
	keeps the rest fogged.
]]
local function Counts(spec, boss, faction)
	local key = BossKey(boss)
	local counts = type(spec.counts) == "table" and spec.counts or nil
	if counts and counts[key] ~= nil then return counts[key] == true end
	if ns.IsLootSection(boss) or boss.rare or boss.maybe or boss.summoned or boss.questTarget or boss.outsideRun
		or boss.uncounted
		or boss.comingSoon then
		return false
	end
	if ns.Items:HidesBoss(boss) then return false end
	if boss.faction and faction and boss.faction ~= faction then return false end
	return true
end
DungeonFog.Counts = Counts

------------------------------------------------------------------------------------------
-- The data, read and checked the first time it is needed
------------------------------------------------------------------------------------------

-- The last part of a picture's path: the name a floor's fog is keyed by.
local function PictureName(path)
	return type(path) == "string" and path:match("([^\\/]+)$") or nil
end

-- A piece's box, x0, y0, x1, y1 (fractions of the visible picture), or nil when it is no box: each of the
-- four a number from 0 to 1 (a gap among them too is no box), and nothing after them.
local function Box(piece)
	if piece == true then return 0, 0, 1, 1 end
	if type(piece) ~= "table" or piece[5] ~= nil then return nil end
	for i = 1, 4 do
		local value = piece[i]
		if type(value) ~= "number" or value < 0 or value > 1 then return nil end
	end
	local x0, y0, x1, y1 = piece[1], piece[2], piece[3], piece[4]
	if not (x0 < x1 and y0 < y1) then return nil end
	return x0, y0, x1, y1
end
DungeonFog.Box = Box

local function ResolveFloor(instance, floorKey, spec, bossByKey, Problem)
	local entry = { key = floorKey, spec = spec, pieces = {}, nodes = {}, byId = {}, nodesOf = {},
		dir = FOLDER .. instance.key .. "\\" .. tostring(floorKey) .. "\\" }
	local where = "floor " .. tostring(floorKey)
	for name, piece in pairs(type(spec.pieces) == "table" and spec.pieces or {}) do
		if type(name) == "string" and Box(piece) then
			entry.pieces[name] = piece
		else
			Problem("%s: piece %s is not a box inside the picture", where, tostring(name))
		end
	end
	if type(spec.keepClear) == "table" and #spec.keepClear > 0 and not spec.extent then
		Problem("%s: keepClear has rects but there is no extent", where)
	end
	if spec.frame == false and not spec.extent then Problem("%s: frame = false but there is no extent", where) end
	local function Names(list, node, field)
		local names = {}
		for _, name in ipairs(type(list) == "table" and list or {}) do
			if entry.pieces[name] then
				names[#names + 1] = name
			else
				Problem("%s: node %s's %s names no piece %s", where, tostring(node.id), field, tostring(name))
			end
		end
		return names
	end
	for position, node in ipairs(type(spec.nodes) == "table" and spec.nodes or {}) do
		local id = type(node) == "table" and node.id
		if type(id) ~= "string" then
			Problem("%s: node %d has no id", where, position)
		elseif entry.byId[id] then
			Problem("%s: node id %s is used twice", where, id)
		else
			local conditions = (node.start and 1 or 0) + (node.boss ~= nil and 1 or 0) + (node.area ~= nil and 1 or 0)
				+ (node.at ~= nil and 1 or 0)
			local boss = node.boss ~= nil and bossByKey[node.boss] or nil
			if conditions ~= 1 then
				Problem("%s: node %s has %d of start, boss, area and at, not one", where, id, conditions)
			elseif node.boss ~= nil and not boss then
				Problem("%s: node %s names no boss %s of %s", where, id, tostring(node.boss), instance.key)
			else
				local made = { id = id, start = node.start == true, boss = boss, area = node.area, at = node.at,
					back = node.back, pieces = Names(node.pieces, node, "pieces"), way = Names(node.way, node, "way") }
				entry.nodes[#entry.nodes + 1] = made
				entry.byId[id] = made
				if boss then
					entry.nodesOf[boss] = entry.nodesOf[boss] or {}
					table.insert(entry.nodesOf[boss], made)
				end
			end
		end
	end
	-- Each way back: its node there, and a start reached within as many steps as there are nodes.
	for _, node in ipairs(entry.nodes) do
		if node.back ~= nil then
			node.backNode = entry.byId[node.back]
			if not node.backNode then Problem("%s: node %s goes back to no node %s", where, node.id, tostring(node.back)) end
		end
	end
	for _, node in ipairs(entry.nodes) do
		local current, reached = node, false
		for _ = 1, #entry.nodes do
			if current.start then
				reached = true
				break
			end
			current = current.backNode
			if not current then break end
		end
		if not reached then
			Problem("%s: node %s's way back reaches no start node within %d steps", where, node.id, #entry.nodes)
		end
	end
	-- Where each piece is clear (Covers): its numbers and keys checked here, each row when Covers first reads it
	-- (WhereRow). A bad one is a problem, and Covers goes back to the boxes on that floor.
	local grid = spec.where
	if grid ~= nil then
		local ok = type(grid) == "table" and type(grid.cols) == "number" and type(grid.rows) == "number"
			and grid.cols >= 1 and grid.rows >= 1 and grid.cols % 1 == 0 and grid.rows % 1 == 0 and type(grid.keys) == "string"
		if not ok then
			Problem("%s: where has no whole cols, rows and keys", where)
		else
			if #grid ~= grid.rows then
				Problem("%s: where has %d rows, not %d", where, #grid, grid.rows)
				ok = false
			end
			for row = 1, grid.rows do
				if type(grid[row]) ~= "string" then
					Problem("%s: where's row %d is not a string", where, row)
					ok = false
					break
				end
			end
			local keys = {}
			for word in grid.keys:gmatch("%S+") do
				local owners = {}
				for name in word:gmatch("[^+]+") do
					if entry.pieces[name] then
						owners[#owners + 1] = name
					else
						Problem("%s: where's key %s names no piece %s", where, word, name)
						ok = false
					end
				end
				keys[#keys + 1] = owners
			end
			if #keys > #WHERE_SYMBOLS then
				Problem("%s: where has %d keys, more than its %d symbols", where, #keys, #WHERE_SYMBOLS)
				ok = false
			end
			if ok then entry.where = { cols = grid.cols, rows = grid.rows, keys = keys, text = grid, decoded = {} } end
		end
	end
	entry.Problem = Problem
	return entry
end

--[[
	A row of a floor's where grid (1 to rows), decoded the first time it is asked for and kept: its runs, each
	{ last column, key } (key 0: no piece there), or false when the row is bad (not runs of <count><symbol>, a symbol of
	no key, or not cols cells), which is said once as a problem and takes the floor's grid out of use.
]]
local function WhereRow(entry, row)
	local grid = entry.where
	if not grid then return false end
	local runs = grid.decoded[row]
	if runs ~= nil then return runs end
	local text = grid.text[row]
	local ends, owners, column, read = {}, {}, 0, 0
	runs = { ends = ends, owners = owners }
	for count, symbol in text:gmatch("(%d+)(%D)") do
		local key = symbol == "." and 0 or WHERE_INDEX[symbol]
		local cells = tonumber(count)
		if not key or (key > 0 and not grid.keys[key]) or cells < 1 then
			runs = false
			break
		end
		column, read = column + cells, read + #count + 1
		ends[#ends + 1], owners[#owners + 1] = column, key
	end
	if runs and (column ~= grid.cols or read ~= #text) then runs = false end
	grid.decoded[row] = runs
	if not runs then
		entry.Problem("floor %s: where's row %d is not %d cells of its keys", tostring(entry.key), row, grid.cols)
		entry.where = nil
	end
	return runs
end
DungeonFog.WhereRow = WhereRow

-- The pieces that own the cell of a floor's where grid at a spot (x, y: fractions of the visible picture, kept to
-- the grid's edges), none for a cell no piece owns; nil when the floor has no grid in use.
local function WhereOwners(entry, x, y)
	local grid = entry.where
	if not grid then return nil end
	local row = math.min(grid.rows - 1, math.max(0, math.floor(y * grid.rows))) + 1
	local column = math.min(grid.cols - 1, math.max(0, math.floor(x * grid.cols))) + 1
	local runs = WhereRow(entry, row)
	if not runs then return nil end
	for position, last in ipairs(runs.ends) do
		if column <= last then
			local key = runs.owners[position]
			return key > 0 and grid.keys[key] or NONE
		end
	end
	return NONE
end

--[[
	The dungeon's fog data, its floors matched to the dungeon's floors (a picture name to the floor whose
	picture or tiles end in it, a client map ID to the floor of that map drawn from the client's own tiles),
	its nodes to their bosses, and a list of what is wrong with it. In the game a bad piece, node or way is
	left out; but a floor key that finds no floor of the dungeon (its picture renamed), or finds one the client
	draws itself (where no fog is drawn yet), leaves the whole dungeon unfogged (resolved.unusable, Usable
	below) rather than fogged with nothing clear. The smoke test wants the list empty for every dungeon the
	journal ships with fog. Kept on the data. Nil (and no problems) for a dungeon with no fog.
]]
function DungeonFog:Resolve(instance)
	local spec = type(instance) == "table" and instance.fog
	if type(spec) ~= "table" then return nil, NONE end
	if spec.resolved then return spec.resolved, spec.resolved.problems end
	local problems = {}
	local function Problem(text, ...) problems[#problems + 1] = string.format(text, ...) end
	local resolved = { byFloor = {}, problems = problems }
	local floors = instance.map and instance.map.floors or {}
	local bossByKey = {}
	for _, boss in ipairs(instance.bosses or {}) do bossByKey[BossKey(boss)] = boss end
	if type(spec.floors) ~= "table" then Problem("no floors") end
	local keys = {}
	for floorKey in pairs(type(spec.floors) == "table" and spec.floors or {}) do keys[#keys + 1] = floorKey end
	table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
	for _, floorKey in ipairs(keys) do
		local matches = {}
		for index, floor in ipairs(floors) do
			local picture = floor.art or floor.tiles
			if (type(floorKey) == "string" and PictureName(picture) == floorKey)
				or (type(floorKey) == "number" and floor.uiMapID == floorKey and not picture) then
				matches[#matches + 1] = index
			end
		end
		local floorSpec = spec.floors[floorKey]
		if #matches ~= 1 then
			Problem("floor %s matches %d of the dungeon's floors, not one", tostring(floorKey), #matches)
			resolved.unusable = true
		elseif type(floorSpec) ~= "table" then
			Problem("floor %s is not a table", tostring(floorKey))
			resolved.unusable = true
		elseif ns.DungeonMap:IsNative(floors[matches[1]]) then
			-- On a floor the client draws itself (UI/DungeonMap.lua's RefreshAllData) nothing draws the fog
			-- or hides a pin yet (spec section 1b).
			Problem("floor %s is one the client draws itself, where no fog is drawn yet", tostring(floorKey))
			resolved.unusable = true
		else
			resolved.byFloor[matches[1]] = ResolveFloor(instance, floorKey, floorSpec, bossByKey, Problem)
		end
	end
	-- Every boss that holds the fog back can be recorded killed, and has a node on each fogged floor it is on.
	-- Each spot of a boss with nodes lies in the box of one of its nodes' own pieces: its kill clears where its pin
	-- is (a fog traced over an earlier drawing of the map would clear somewhere else).
	for _, boss in ipairs(instance.bosses or {}) do
		for _, point in ipairs(ns.DungeonMap.BossSpots(boss)) do
			local entry = resolved.byFloor[point.floor or 1]
			local nodes = entry and entry.nodesOf[boss]
			if nodes and type(point.x) == "number" and type(point.y) == "number" then
				local inside = false
				for _, node in ipairs(nodes) do
					for _, name in ipairs(node.pieces) do
						local x0, y0, x1, y1 = Box(entry.pieces[name])
						if x0 and point.x >= x0 and point.x <= x1 and point.y >= y0 and point.y <= y1 then inside = true end
					end
				end
				if not inside then
					Problem("floor %s: %s's spot (%.3f, %.3f) lies in none of its rooms", tostring(entry.key), BossKey(boss),
						point.x, point.y)
				end
			end
		end
		if Counts(spec, boss, nil) then
			if not (boss.encounterID or boss.encounter == true or (type(boss.loot) == "table" and #boss.loot > 0)) then
				Problem("%s holds the fog back but no kill of it can be recorded (no encounterID, encounter or loot)", BossKey(boss))
			end
			for _, point in ipairs(ns.DungeonMap.BossSpots(boss)) do
				local entry = resolved.byFloor[point.floor or 1]
				if entry and not entry.nodesOf[boss] then
					Problem("floor %s: %s has a spot but no node", tostring(entry.key), BossKey(boss))
				end
			end
		end
	end
	-- The counts map names bosses of the dungeon (a name of none is a typo, and holds nothing).
	if type(spec.counts) == "table" then
		local names = {}
		for name in pairs(spec.counts) do
			if bossByKey[name] == nil then names[#names + 1] = tostring(name) end
		end
		table.sort(names)
		for _, name in ipairs(names) do Problem("counts names no boss %s of %s", name, instance.key) end
	elseif spec.counts ~= nil then
		Problem("counts is not a table")
	end
	--[[
		Which map clears when (the owner's rule of 2026-11-13). On each of the dungeon's floors, fogged or not, the
		bosses who stand there (standing): each with a spot on it, and on a fogged floor each with a node that has
		pieces there (a room with no spot of his counts; a node with no pieces does not). A floor is the whole map
		(whole) when the data marks it whole, or when it holds a spot of every boss that holds the fog back (for
		either side) and has a spot anywhere; a dungeon's one floor always is. A whole map clears with the whole fog; any other floor is a section, which
		clears completely once every boss standing on it that holds the fog back is dead (State's floorClear).
	]]
	local standing, spotsOn, spotted = {}, {}, {}
	for index in ipairs(floors) do standing[index], spotsOn[index] = {}, {} end
	for _, boss in ipairs(instance.bosses or {}) do
		local holds = Counts(spec, boss, nil)
		for _, point in ipairs(ns.DungeonMap.BossSpots(boss)) do
			local index = point.floor or 1
			if standing[index] then
				standing[index][boss], spotsOn[index][boss] = true, true
				if holds then spotted[boss] = true end
			end
		end
	end
	for index, entry in pairs(resolved.byFloor) do
		for _, node in ipairs(entry.nodes) do
			if node.boss and #node.pieces > 0 and standing[index] then standing[index][node.boss] = true end
		end
	end
	-- A floor the data marks whole (the whole dungeon's map: `whole = true` in Data/Instances or ClassicMaps' entry
	-- with no map) is the whole map whatever its spots: the Temple of Atal'Hakkar's waits for Spawn of Hakkar, who
	-- stands only on the lower level (the owner: the larger map clears once every boss is killed).
	local whole = {}
	for index in ipairs(floors) do
		local all = true
		if floors[index].whole ~= true and #floors > 1 then
			for boss in pairs(spotted) do
				if not spotsOn[index][boss] then
					all = false
					break
				end
			end
		end
		whole[index] = all
	end
	resolved.standing, resolved.whole = standing, whole
	spec.resolved = resolved
	return resolved, problems
end

------------------------------------------------------------------------------------------
-- What is killed, cached until a kill, another record or another style
------------------------------------------------------------------------------------------

local state = {}

-- The dungeon's fog as the game uses it: none for a dungeon with no fog data (one field test), nor for one
-- whose data no longer fits its floors.
local function Usable(instance)
	if type(instance) ~= "table" or type(instance.fog) ~= "table" then return nil end
	local resolved = DungeonFog:Resolve(instance)
	if resolved and not resolved.unusable then return resolved end
	return nil
end

--[[
	The dungeon's killed bosses, the ones still hidden (every boss not killed), whether every boss that holds the
	fog back is dead (clear: the whole fog gone), and each floor's own clear (floorClear[index]): a whole map's is
	the whole fog's; a section's, once at least one boss standing on it holds the fog back for this side and every
	such one is dead (a section where none does clears only with the whole fog). Called only for a dungeon whose fog
	the game can draw (Usable).
]]
local function State(instance)
	local stamp, on, faction = ns.Discovery:KillStamp(), DungeonFog:On(), PlayerFaction()
	if state.instance == instance and state.stamp == stamp and state.on == on and state.faction == faction then
		return state
	end
	local killed, hidden, clear = {}, {}, true
	for _, boss in ipairs(instance.bosses or {}) do
		if ns.Discovery:Killed(instance, boss) then
			killed[boss] = true
		else
			hidden[boss] = true
			if Counts(instance.fog, boss, faction) then clear = false end
		end
	end
	local resolved, floorClear = Usable(instance), {}
	for index, bosses in pairs(resolved and resolved.standing or NONE) do
		local cleared = clear
		if not cleared and not resolved.whole[index] then
			local holding = false
			cleared = true
			for boss in pairs(bosses) do
				if Counts(instance.fog, boss, faction) then
					holding = true
					if not killed[boss] then
						cleared = false
						break
					end
				end
			end
			cleared = cleared and holding
		end
		floorClear[index] = cleared
	end
	state = { instance = instance, stamp = stamp, on = on, faction = faction, killed = killed, hidden = hidden, clear = clear,
		floorClear = floorClear, shown = {} }
	return state
end

-- Whether a boss's pin is hidden by the fog (a hint at its spot instead): the fog on, the dungeon fogged,
-- and the boss not killed by this character. A rare keeps its hint after the whole fog has gone, until it dies.
function DungeonFog:HidesBoss(instance, boss)
	if not (instance and instance.fog) or not self:On() or not Usable(instance) then return false end
	return State(instance).hidden[boss] == true
end

--[[
	Whether a boss waits as a hint at its spot instead of its pin (UI/DungeonMap.lua's DrawPins): the fog hides it
	(HidesBoss), or, on the map of a dungeon with no fog (no data, or data that no longer fits), it is a boss this
	character has not met in Adventure Mode, whose pin would give away the portrait and name the journal keeps
	back (the owner's pick, 2026-11-07). Once met, such a boss has its pin. Unmet is false outside Adventure Mode,
	so there a dungeon with no fog keeps every pin. HidesBoss alone still means the fog itself. Only the journal's own
	map (the overlay) asks: the pins on a floor the client draws itself (DungeonMap's RefreshAllData) do not, and no
	dungeon has such a floor now; one added would need its bosses not met left out there.
]]
function DungeonFog:HintsBoss(instance, boss)
	if self:HidesBoss(instance, boss) then return true end
	return not Usable(instance) and ns.Discovery:Unmet(instance, boss) == true
end

-- Whether the dungeon has fog the game can draw (its data fits its floors), on or off.
function DungeonFog:Has(instance)
	return Usable(instance) ~= nil
end

-- Whether the whole fog has gone for this character (every boss that holds it back killed).
function DungeonFog:Cleared(instance)
	return Usable(instance) ~= nil and State(instance).clear
end

-- Whether one map of the dungeon (its floor index) has cleared completely for this character: a section once every
-- boss on it that holds the fog back is dead, the whole map with the whole fog (State's floorClear).
function DungeonFog:FloorCleared(instance, index)
	return Usable(instance) ~= nil and State(instance).floorClear[index] == true
end

-- The pieces shown on a floor: each clear node's, and the way back from each clear node to the nearest one
-- already clear (the passage back to where the player had cleared), in the data's order.
local function ShownPieces(entry, killed)
	local clear = {}
	for _, node in ipairs(entry.nodes) do clear[node] = node.start or (node.boss ~= nil and killed[node.boss] == true) end
	local list, seen = {}, {}
	local function Add(names)
		for _, name in ipairs(names) do
			if not seen[name] then
				seen[name] = true
				list[#list + 1] = name
			end
		end
	end
	for _, node in ipairs(entry.nodes) do
		if clear[node] then
			Add(node.pieces)
			if not node.start then
				local current = node
				for _ = 1, #entry.nodes do
					Add(current.way)
					local nextNode = current.backNode
					if not nextNode or clear[nextNode] then break end
					current = nextNode
				end
			end
		end
	end
	return list
end
DungeonFog.ShownPieces = ShownPieces

--[[
	Whether the fog lies over a spot of a floor (x, y: fractions of the floor's picture, as boss spots are), for
	what must not show through it: Adventure Mode's faint quest marks (UI/QuestMap.lua's InsideMarks), and a map's
	places worth knowing in every style the fog is drawn in (UI/DungeonMap.lua's MapSpot: the Drowned City's hidden
	chest). Not while
	the fog is off, on a dungeon or floor with none, once the whole fog or that floor's own has gone (floorClear),
	nor on a spot kept clear of it (keepClear). Otherwise, on a floor with a where grid (the owner's rule of
	2026-11-13: decided by where the masks are clear, not by the padded boxes), the spot is clear when a piece that
	owns its cell is shown (ShownPieces), and fogged in a cell no piece owns. On a floor without one (older data),
	by the boxes: clear only inside the box of a piece shown and inside no box of a piece still fogged (the boxes of
	rooms side by side overlap, and a spot in both is taken as fogged, so nothing shows through the fog before its
	room is clear); a box is a little larger than its room's mask, so a spot just outside a clear room, in no other
	room's box, counts as clear.
]]
function DungeonFog:Covers(instance, index, x, y)
	if type(x) ~= "number" or type(y) ~= "number" or not (instance and instance.fog) or not self:On() then return false end
	local resolved = Usable(instance)
	local entry = resolved and resolved.byFloor[index]
	if not entry then return false end
	local now = State(instance)
	if now.clear or now.floorClear[index] then return false end
	for _, rect in ipairs(type(entry.spec.keepClear) == "table" and entry.spec.keepClear or NONE) do
		local x0, y0, x1, y1 = Box(rect)
		if x0 and x >= x0 and x <= x1 and y >= y0 and y <= y1 then return false end
	end
	-- The pieces shown on this floor, worked out once a kill (State is made again on each).
	local shown = now.shown[entry]
	if not shown then
		shown = {}
		for _, name in ipairs(ShownPieces(entry, now.killed)) do shown[name] = true end
		now.shown[entry] = shown
	end
	local owners = WhereOwners(entry, x, y)
	if owners then
		for _, name in ipairs(owners) do
			if shown[name] then return false end
		end
		return true
	end
	local clear = false
	for name, piece in pairs(entry.pieces) do
		local x0, y0, x1, y1 = Box(piece)
		if x0 and x >= x0 and x <= x1 and y >= y0 and y <= y1 then
			if not shown[name] then return true end
			clear = true
		end
	end
	return not clear
end

------------------------------------------------------------------------------------------
-- Drawing
------------------------------------------------------------------------------------------

-- The overlay's fog and hints, and the fog's extent, once made: read raw, as a field a frame has not got
-- may answer otherwise (a method of the same name).
local function Field(frame, key)
	return rawget(frame, key)
end

local function CreateFog(overlay)
	-- A child of the picture's frame, which cuts it to the picture; set above it explicitly.
	local fog = CreateFrame("Frame", nil, overlay.Art)
	fog:SetAllPoints(overlay.Art)
	fog:SetFrameLevel(overlay:GetFrameLevel() + FOG_LEVEL)
	-- The parchment over the whole picture, under the frame's mask: set once, the same on every floor.
	fog.Parchment = fog:CreateTexture(nil, "BACKGROUND", nil, 0)
	fog.Parchment:SetAllPoints(fog)
	fog.Parchment:SetTexture(PARCHMENT)
	fog.Parchment:SetTexCoord(PARCHMENT_COORDS[1], PARCHMENT_COORDS[2], PARCHMENT_COORDS[3], PARCHMENT_COORDS[4])
	fog.Parchment:SetVertexColor(PARCHMENT_TINT[1], PARCHMENT_TINT[2], PARCHMENT_TINT[3])
	fog.FrameMask = fog:CreateMaskTexture()
	fog.FrameMask:SetAllPoints(fog)
	fog.FrameMask:SetTexture(FRAME_MASK, "CLAMP", "CLAMP")
	fog.Parchment:AddMaskTexture(fog.FrameMask)
	fog.frameOn = true
	fog.Copies = {}
	fog:Hide()
	overlay.Fog = fog
	return fog
end

-- A clearing's slot: its copies of the art (one, or a tile's each) and its one mask, made once and reused.
local function Slot(fog, index)
	local slot = fog.Copies[index]
	if not slot then
		slot = { textures = {}, mask = fog:CreateMaskTexture() }
		fog.Copies[index] = slot
	end
	return slot
end

local function SlotTexture(fog, slot, index)
	local texture = slot.textures[index]
	if not texture then
		texture = fog:CreateTexture(nil, "ARTWORK", nil, 0)
		texture:AddMaskTexture(slot.mask)
		slot.textures[index] = texture
	end
	return texture
end

local function Put(region, fog, x0, y0, x1, y1, width, height)
	region:ClearAllPoints()
	region:SetPoint("TOPLEFT", fog, "TOPLEFT", x0 * width, -y0 * height)
	region:SetSize((x1 - x0) * width, (y1 - y0) * height)
end

-- One piece cleared: the floor's own art in its box, under its mask.
local function DrawPiece(fog, slot, entry, name, floor, width, height)
	local x0, y0, x1, y1 = Box(entry.pieces[name])
	slot.mask:SetTexture(entry.dir .. name, PIECE_WRAP, PIECE_WRAP)
	Put(slot.mask, fog, x0, y0, x1, y1, width, height)
	local used = 0
	if floor.art then
		used = 1
		local copy = SlotTexture(fog, slot, 1)
		local right, bottom = floor.artRight or 1, floor.artBottom or 1
		copy:SetTexture(floor.art)
		copy:SetTexCoord(x0 * right, x1 * right, y0 * bottom, y1 * bottom)
		Put(copy, fog, x0, y0, x1, y1, width, height)
		copy:Show()
	else
		-- The client's tiles, as UI/DungeonMap.lua's DrawArt lays them: only those the box touches, each
		-- trimmed to it, all under the piece's one mask.
		local textures = not floor.tiles and ns.DungeonMap.NativeTiles(floor)
		for index = 1, TILE_COLUMNS * TILE_ROWS do
			local column, row = (index - 1) % TILE_COLUMNS, math.floor((index - 1) / TILE_COLUMNS)
			local tx0, tx1 = column * TILE_SIZE / TILE_MAP_WIDTH, (column + 1) * TILE_SIZE / TILE_MAP_WIDTH
			local ty0, ty1 = row * TILE_SIZE / TILE_MAP_HEIGHT, (row + 1) * TILE_SIZE / TILE_MAP_HEIGHT
			local ix0, ix1, iy0, iy1 = math.max(x0, tx0), math.min(x1, tx1), math.max(y0, ty0), math.min(y1, ty1)
			local file
			if textures then file = textures[index] elseif floor.tiles then file = floor.tiles .. index end
			if file and ix1 > ix0 and iy1 > iy0 then
				used = used + 1
				local copy = SlotTexture(fog, slot, used)
				copy:SetTexture(file)
				copy:SetTexCoord((ix0 - tx0) / (tx1 - tx0), (ix1 - tx0) / (tx1 - tx0), (iy0 - ty0) / (ty1 - ty0), (iy1 - ty0) / (ty1 - ty0))
				Put(copy, fog, ix0, iy0, ix1, iy1, width, height)
				copy:Show()
			end
		end
	end
	for extra = used + 1, #slot.textures do slot.textures[extra]:Hide() end
end

local function HideSlot(slot)
	for _, texture in ipairs(slot.textures) do texture:Hide() end
end

-- The extent (a floor with never-fogged rects) on the parchment, and the clearings. The parchment is the same on
-- every floor (CreateFog), and so is its frame mask, but on a floor whose picture is not drawn on the classic map
-- sheet (frame = false: the Hall of Thanes, its own frame kept clear by its extent), where it is taken off.
local function DrawLayers(fog, overlay, entry, floor, killed)
	local width, height = overlay.artWidth, overlay.artHeight
	local spec = entry and entry.spec or NONE
	local parchment = fog.Parchment
	if spec.frame == false then
		if fog.frameOn then parchment:RemoveMaskTexture(fog.FrameMask); fog.frameOn = false end
	elseif not fog.frameOn then
		parchment:AddMaskTexture(fog.FrameMask); fog.frameOn = true
	end
	if spec.extent then
		local extent = Field(fog, "Extent")
		if not extent then
			extent = fog:CreateMaskTexture()
			extent:SetAllPoints(fog)
			fog.Extent = extent
		end
		-- Clamped, so its outer texels reach the picture's edges and no further: the Hall of Thanes' are 0, which
		-- keeps the parchment off Santiago Reyes's frame.
		extent:SetTexture(entry.dir .. "extent", "CLAMP", "CLAMP")
		if not fog.extentOn then
			parchment:AddMaskTexture(extent)
			fog.extentOn = true
		end
	elseif fog.extentOn then
		parchment:RemoveMaskTexture(fog.Extent)
		fog.extentOn = false
	end
	local names = entry and ShownPieces(entry, killed) or NONE
	for index, name in ipairs(names) do
		local slot = Slot(fog, index)
		slot.piece = name
		DrawPiece(fog, slot, entry, name, floor, width, height)
	end
	for extra = #names + 1, #fog.Copies do
		fog.Copies[extra].piece = nil
		HideSlot(fog.Copies[extra])
	end
end

-- The fog and its hints put away: a way-in picture, a dungeon with no fog, the fog off. The next draw of a
-- fogged floor draws it all again.
function DungeonFog:Hide(overlay)
	if not overlay then return end
	local fog = Field(overlay, "Fog")
	if fog then
		fog:Hide()
		fog.key, fog.shownForKey = nil, nil
	end
	for _, hint in ipairs(Field(overlay, "FogHints") or NONE) do hint:Hide() end
end

--[[
	The fog over a dungeon's floor (UI/DungeonMap.lua's UpdateOverlay, after its picture and before its
	pins). Drawn again only when something it shows could change: another dungeon, floor, size or picture,
	a kill, another record, the fog turned on or off, another side. Its hints are drawn with the pins
	(ShowHints).
]]
function DungeonFog:Draw(overlay, instance, index, floor)
	local resolved = instance and instance.fog and self:On() and Usable(instance)
	if not resolved then
		self:Hide(overlay)
		return
	end
	local fog = Field(overlay, "Fog")
	local key = table.concat({ instance.key, index, tostring(floor.art or floor.tiles), tostring(overlay.artWidth),
		tostring(overlay.artHeight), ns.Discovery:KillStamp(), PlayerFaction() or "" }, ":")
	if fog and fog.key == key and fog:IsShown() == fog.shownForKey then return end
	fog = fog or CreateFog(overlay)
	local now = State(instance)
	fog.key = key
	if now.clear or now.floorClear[index] then
		-- Every boss that holds it back is dead: the whole map, its drawing too, on every floor; or every one on this
		-- map (a section of the dungeon): this map whole, no pocket, wall or name left under fog.
		fog:Hide()
		fog.shownForKey = false
		return
	end
	DrawLayers(fog, overlay, resolved.byFloor[index], floor, now.killed)
	fog:Show()
	fog.shownForKey = true
end

------------------------------------------------------------------------------------------
-- The hints
------------------------------------------------------------------------------------------

local function ShowHintTooltip(hint)
	GameTooltip:SetOwner(hint, "ANCHOR_LEFT")
	for position, boss in ipairs(hint.bosses) do
		local title = ns.Discovery:BossTitle(hint.instance, boss)
		if position == 1 then GameTooltip:SetText(title, 1, 0.82, 0) else GameTooltip:AddLine(title, 1, 0.82, 0) end
	end
	-- On a map with no fog the hint stands for a boss not met yet (HintsBoss): there is no fog to clear.
	GameTooltip:AddLine(hint.fogless and L.MAP_UNMET_HINT or L.MAP_FOG_HINT, 1, 1, 1, true)
	GameTooltip:Show()
end

--[[
	The unknown-boss picture over the hint's round portrait: only the part of the picture inside the cut's square
	(its texture coordinates, kept within the picture), at the portrait's scale (its radius to the cut's), set
	where that part falls in the square. Cut to the portrait's circle by a mask on the portrait.
]]
local function CutUnknown(texture, portrait, radius)
	local cut = UNKNOWN_BOSS
	local scale = radius / cut.radius
	local left, right = math.max(cut.x - cut.radius, 0), math.min(cut.x + cut.radius, cut.width)
	local top, bottom = math.max(cut.y - cut.radius, 0), math.min(cut.y + cut.radius, cut.height)
	texture:SetTexture(cut.file)
	texture:SetTexCoord(left / cut.width, right / cut.width, top / cut.height, bottom / cut.height)
	texture:SetSize((right - left) * scale, (bottom - top) * scale)
	texture:SetPoint("TOPLEFT", portrait, "TOPLEFT", (left - (cut.x - cut.radius)) * scale,
		-(top - (cut.y - cut.radius)) * scale)
end

-- (the run block's circles wear it too for a boss not met, Adventure Mode: UI/RunTracker.lua)
DungeonFog.CutUnknown = CutUnknown

local function Hint(overlay, index)
	overlay.FogHints = Field(overlay, "FogHints") or {}
	local hint = overlay.FogHints[index]
	if hint then return hint end
	hint = CreateFrame("Button", nil, overlay)
	-- The boss pin's round portrait, skull and lit look (UI/DungeonMap.lua), with neither the pin's ring nor its
	-- shade or cross (a boss under the fog is not killed): the boss list's gold band beneath the portrait instead,
	-- and the unknown-boss picture over it, shown while the boss is not met.
	local DungeonMap = ns.DungeonMap
	DungeonMap.BuildBossPin(hint, true)
	local radius = DungeonMap.PORTRAIT_SIZE / 2
	hint.Rim, hint.Edge = ns.PortraitBand(hint, "BACKGROUND", -2, radius, BAND, "CENTER", hint.Portrait, "CENTER", 0, 0)
	-- The picture shares the portrait's own circle mask: the same circle on the same region.
	hint.Unknown = hint:CreateTexture(nil, "ARTWORK", nil, -1)
	if hint.Portrait.CircleMask then hint.Unknown:AddMaskTexture(hint.Portrait.CircleMask) end
	CutUnknown(hint.Unknown, hint.Portrait, radius)
	hint.Unknown:Hide()
	hint:SetFrameLevel(overlay:GetFrameLevel() + HINT_LEVEL)
	-- A right click puts the dungeon map away, as on a boss pin; a left click opens the boss.
	hint:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	hint:SetScript("OnEnter", ShowHintTooltip)
	hint:SetScript("OnLeave", function() GameTooltip:Hide() end)
	hint:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			ns.DungeonMap.Dismiss()
		elseif self.bosses and self.bosses[1] then
			ns.DungeonMap:OpenBoss(self.instance, self.bosses[1])
		end
	end)
	overlay.FogHints[index] = hint
	return hint
end

--[[
	A hint's face, the first of its bosses': while the character has not met that boss, the unknown-boss picture
	on a black disc; once met, its portrait as its pin draws it (or the pin's skull on a dark disc). Set only when
	its boss or the meeting has changed, so a redraw with nothing new sets nothing.
]]
local function SetFace(hint)
	local boss = hint.bosses[1]
	local unmet = ns.Discovery:Unmet(hint.instance, boss) == true
	if hint.faceBoss == boss and hint.faceID == boss.displayID and hint.faceUnmet == unmet then return end
	hint.faceBoss, hint.faceID, hint.faceUnmet = boss, boss.displayID, unmet
	if unmet then
		hint.Portrait:SetColorTexture(0, 0, 0, 1)
		hint.Skull:Hide()
	else
		ns.DungeonMap.SetPinPortrait(hint, boss)
	end
	hint.Unknown:SetShown(unmet)
end

--[[
	A hint for each entry DrawPins made of the bosses the fog hides, or on a map with no fog of the bosses not met
	(HintsBoss; fogless): one for all of them at one spot (the first one's face), placed beside any portrait at the
	same spot as pins sharing a spot are (together: how many share each). The rest put away.
]]
function DungeonFog:ShowHints(overlay, instance, hints, together, scale)
	local DungeonMap = ns.DungeonMap
	local fogless = #hints > 0 and not (self:On() and Usable(instance))
	for index, entry in ipairs(hints) do
		local hint = Hint(overlay, index)
		hint.instance, hint.bosses, hint.point, hint.fogless = instance, entry.bosses, entry.point, fogless
		SetFace(hint)
		local size = entry.maybe and DungeonMap.MAYBE_SCALE or 1
		hint:SetAlpha(entry.maybe and DungeonMap.MAYBE_ALPHA or 1)
		hint.shift = (entry.place - ((together[entry.key] or 1) + 1) / 2) * DungeonMap.SHARED_SPOT_SPACING
		DungeonMap.Place(hint, entry.point.x, entry.point.y, scale * size, hint.shift)
		hint:Show()
	end
	local made = Field(overlay, "FogHints") or NONE
	for extra = #hints + 1, #made do made[extra]:Hide() end
end

-- A first kill redraws an open map, only in a dungeon with fog and with the fog on: otherwise nothing it
-- shows changes (UI/DungeonMap.lua redraws on the fight's end for its own reasons).
ns.Discovery:OnKill(function(instanceKey)
	local instance = ns.GetInstance(instanceKey)
	if instance and instance.fog and DungeonFog:On() then ns.DungeonMap:Refresh() end
end)

-- A boss met (Core/Discovery.lua's finds, told once a burst is over, in Adventure Mode, where only a meeting turns
-- a hint's face): the hints shown take their faces again at once, the unknown-boss picture giving way to the
-- portrait, a pull with no kill included. Nothing else is drawn again, and a face with nothing new is not set
-- (SetFace). On a map with no fog a hint stands for bosses not met, so once one of a shown hint's bosses is met
-- the open map is drawn again (its pin in place of the hint), as a first kill redraws it under fog (OnKill above,
-- in combat too); otherwise not.
ns.Discovery:OnChange(function()
	local overlay = ns.DungeonMap:Overlay()
	local redraw = false
	for _, hint in ipairs(overlay and Field(overlay, "FogHints") or NONE) do
		if hint:IsShown() and hint.bosses and hint.bosses[1] then
			SetFace(hint)
			if hint.fogless and not redraw then
				for _, boss in ipairs(hint.bosses) do
					if not ns.Discovery:Unmet(hint.instance, boss) then
						redraw = true
						break
					end
				end
			end
		end
	end
	if redraw and overlay:IsShown() then ns.DungeonMap:Refresh() end
end)
