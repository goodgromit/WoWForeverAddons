local addonName, ns = ...

--[[
	The classic dungeons' maps, from foreverchanges.pro (2026-10-09): its picture of each floor
	(the client's own map, 1002 x 668, with the painted boss skulls taken off), the floors it
	shows and their names, and where it places each boss.

	Each picture keeps the client's map frame in the top-left of a 1024 square, unscaled, so the
	player's position on the client's map (uiMapID) and the site's spots fit it as they are. One
	file per floor, in Media/Maps/Dungeons, named as the site names them.

	A dungeon may have Blizzard's own drawn map of the whole of it as well (Blackfathom Deeps,
	2026-10-27, the owner's picture): its levels drawn together on one sheet, its boss skulls and
	room names painted on, 1000 x 667 in the top-left of a 1024 square (Media/Maps/Dungeons, named
	"-full"). It comes first, what the map shows by itself, the site's floors after it in the floor
	menu. It is no client map of its own (no uiMapID), and is named after the dungeon.

	floors   each floor, in the menu's order: the client's map (false for the whole dungeon's map),
	         the picture, the name, and for a whole map not 1000 x 667, its width and height; and
	         areas, the English names the client gives (GetSubZoneText, else the minimap's name)
	         on that floor: inside the dungeon the map opens on the floor of the area the player is
	         in and follows it (UI/DungeonMap.lua, follow.Floor). A name the client gives on two
	         floors goes on neither, unless it is that floor's nearly everywhere and the other's only
	         on the way between them (The Deadmines' own name, below)
	spots    { boss, floor, x, y }: a boss with several is not always in the same place, and gets
	         a pin on each. On the whole dungeon's map a boss has a spot of its own as well, listed
	         first, and is sure on each map: only several spots on one map make a maybe. Bosses the
	         site does not place keep the spot they had (listed in kept below), on the floor of the
	         same client map.
	entrance where the dungeon is entered, where the whole dungeon's map shows it
	followFromLevel  true for a dungeon whose map opens on its whole map and follows the rooms only once the player
	         has picked a level floor (Gnomeregan's, below: UI/DungeonMap.lua, follow.Floor)
	The ways between floors are the journal's own (Data/Instances), moved to the new floors by their
	client maps.
]]

local FOLDER = "Interface\\AddOns\\" .. addonName .. "\\Media\\Maps\\Dungeons\\"
local ART_RIGHT, ART_BOTTOM = 1002 / 1024, 668 / 1024
local WHOLE_RIGHT, WHOLE_BOTTOM = 1000 / 1024, 667 / 1024

local function UseMaps(key, spec)
	local instance = ns.GetInstance(key)
	if not (instance and instance.map) then return end
	local map = instance.map

	-- The new floors; a floor the journal had keeps its table (tiles and all).
	local old, oldMapOf, newIndexOf = map.floors or {}, {}, {}
	for index, floor in ipairs(old) do oldMapOf[index] = floor.uiMapID end
	local floors, names = {}, {}
	for index, entry in ipairs(spec.floors) do
		local mapID, floor = entry[1], nil
		if mapID then
			for _, candidate in ipairs(old) do
				if candidate.uiMapID == mapID then floor = candidate end
			end
			floor = floor or { uiMapID = mapID }
			floor.art, floor.artRight, floor.artBottom = FOLDER .. entry[2], ART_RIGHT, ART_BOTTOM
			newIndexOf[mapID] = index
			if entry.areas then
				floor.areas = {}
				for _, name in ipairs(entry.areas) do floor.areas[name] = true end
			end
		else
			-- The whole dungeon's map: only a picture, which nothing of the old floors moves to.
			floor = { art = FOLDER .. entry[2], whole = true,
				artRight = entry[4] and entry[4] / 1024 or WHOLE_RIGHT, artBottom = entry[5] and entry[5] / 1024 or WHOLE_BOTTOM }
		end
		floors[index], names[index] = floor, entry[3]
	end
	local function Moved(point)
		if not point then return nil end
		local index = newIndexOf[oldMapOf[point.floor or 1]]
		if not index then return nil end
		point.floor = index
		return point
	end
	map.floors = floors
	map.followFromLevel = spec.followFromLevel
	instance.floorNames = #floors > 1 and names or nil

	-- Spots kept where the site places nobody, moved to the new floors; dropped if their floor is gone.
	local byName = {}
	for _, boss in ipairs(instance.bosses) do
		byName[boss.name] = boss
		boss.mapPin = Moved(boss.mapPin)
		boss.mapPins = nil
	end
	map.entrance = spec.entrance or Moved(map.entrance)
	local transitions = {}
	for _, link in ipairs(map.transitions or {}) do
		local from, to = newIndexOf[oldMapOf[link.floor]], newIndexOf[oldMapOf[link.to]]
		if from and to then transitions[#transitions + 1] = { floor = from, to = to, x = link.x, y = link.y } end
	end
	map.transitions = #transitions > 0 and transitions or nil

	-- The site's spots.
	local spots = {}
	for _, spot in ipairs(spec.spots) do
		local name, floor, x, y = spot[1], spot[2], spot[3], spot[4]
		assert(byName[name], "ClassicMaps: " .. key .. " has no boss named " .. name)
		spots[name] = spots[name] or {}
		table.insert(spots[name], { x = x, y = y, floor = floor })
	end
	for name, list in pairs(spots) do
		local boss = byName[name]
		boss.mapPin = list[1]
		boss.mapPins = #list > 1 and list or nil
	end
	for name, spot in pairs(spec.kept or {}) do
		assert(byName[name], "ClassicMaps: " .. key .. " has no boss named " .. name)
		byName[name].mapPin = spot
	end
end

UseMaps("RagefireChasm", {
	floors = { { 213, "ragefire-chasm" } },
	spots = {
		{ "Oggleflint", 1, 0.561, 0.380 }, { "Taragaman the Hungerer", 1, 0.410, 0.577 },
		{ "Jergosh the Invoker", 1, 0.330, 0.845 }, { "Bazzalan", 1, 0.415, 0.862 },
	},
})

--[[
	Wailing Caverns (2026-11-10, the owner's report that its pins and map were off): the picture is the owner's map
	of the caverns as Forever has them, with the Winding Chasm, which patch 4.1 took out of the game (warcraft.wiki.gg)
	and so out of the drawing the client's tiles and the site's picture have. It is drawn in the same frame: its
	western part lines up with that drawing to the pixel. Each spot is the boss's skull on it, found by shape. Lady
	Anacondra, Lord Cobrahn, Lord Serpentis, Verdan and Mutanus are where the later drawing has them, and where
	the retail Adventure Guide's own pins put them (JournalEncounter, read with Dev's CASC reader). Lord Pythas and
	Skum are back in the Winding Chasm: Pythas at its northern end, about half way up (a player's comment on his
	Wowhead Classic page, 2005), so Skum is the red room's skull to the south-east (by elimination). Kresh, who
	wanders the river, has no skull: he keeps the Adventure Guide's spot in it. The Deviate Faerie Dragon, a rare,
	keeps the spot the earlier maps' sources agreed on.
]]
UseMaps("WailingCaverns", {
	floors = { { 279, "wailing-caverns" } },
	spots = {
		{ "Lord Cobrahn", 1, 0.158, 0.567 }, { "Lady Anacondra", 1, 0.305, 0.431 },
		{ "Kresh", 1, 0.384, 0.351 }, { "Lord Pythas", 1, 0.855, 0.289 },
		{ "Skum", 1, 0.927, 0.789 }, { "Lord Serpentis", 1, 0.614, 0.536 },
		{ "Verdan the Everliving", 1, 0.550, 0.466 }, { "Mutanus the Devourer", 1, 0.342, 0.138 },
	},
	kept = {
		["Deviate Faerie Dragon"] = { x = 0.129, y = 0.333, floor = 1 },
	},
})

--[[
	The Deadmines' whole map (Media/Maps/Dungeons/the-deadmines-full, Dev/maps/DeadminesTurtle,
	2026-10-30) is Turtle WoW's own map of it, 1002 x 668, made Forever's: the mine, the foundry and
	Ironclad Cove on one sheet, drawn to scale from the game's geometry (one fit carries Forever's
	world onto it, median error about a pixel: survey/fit.json). Turtle's two extra wings, the Zanzil
	Laboratory and the Harvest Golem Foundry, and their corridors and skulls are painted out, and the
	foundry's north door shaft is back at Forever's width. It carries Torchlite's signature
	(LICENSE-MAPS.md). Its seven skulls are Forever's seven fights, and each boss sits on his: Sneed
	and his Shredder share the Mast Room's, side by side. Miner Johnson, a rare with no skull, is at the
	round end of his side passage, where his classic spot carries to. Its entrance is the painted
	swirl at the top left. The two classic floors follow it as they were, one down.

	The floors' areas (2026-11-07): the owner's readings inside, with no position (Map nil), give
	"The Deadmines" at the entrance, "Goblin Foundry" in Gilnid's foundry and "Ironclad Cove" in the
	cove, as area and minimap alike. "Mast Room" is Sneed's room (Forever's own room names, the
	WMOAreaTable; the room is on the mine's floor). "The Deadmines" is the mine: read at the entrance,
	the owner's own account ("it changes from deadmines to ironcove"), and Forever's data, which gives
	every mine room no name of its own but the area The Deadmines. Best guesses, waiting for readings,
	left out: which floor "Goblin Foundry" is on (the name is confirmed): it lies on both, the upper
	part the mine's and the lower the cove's, and the game gives no height inside to tell them apart,
	so it keeps the floor shown (the whole map when the map opens there); and
	the tunnel from the foundry down to the cove and the cove's far exit are likely "The Deadmines"
	too, though drawn on the cove's floor, so the map may turn to the mine there a little early.
]]
UseMaps("TheDeadmines", {
	floors = {
		{ false, "the-deadmines-full", "The Deadmines", 1002, 668 },
		{ 291, "the-deadmines-1", "The Deadmines", areas = { "The Deadmines", "Mast Room" } },
		{ 292, "the-deadmines-2", "Ironclad Cove", areas = { "Ironclad Cove" } },
	},
	spots = {
		{ "Rhahk'Zor", 1, 0.176, 0.531 }, { "Miner Johnson", 1, 0.317, 0.441 },
		{ "Sneed", 1, 0.296, 0.746 }, { "Sneed's Shredder", 1, 0.296, 0.746 },
		{ "Gilnid", 1, 0.389, 0.514 }, { "Mr. Smite", 1, 0.711, 0.116 }, { "Captain Greenskin", 1, 0.755, 0.221 },
		{ "Edwin VanCleef", 1, 0.756, 0.281 }, { "Cookie", 1, 0.808, 0.246 },

		{ "Rhahk'Zor", 2, 0.386, 0.609 }, { "Miner Johnson", 2, 0.527, 0.505 },
		{ "Sneed", 2, 0.450, 0.889 }, { "Sneed's Shredder", 2, 0.485, 0.924 },
		{ "Gilnid", 3, 0.119, 0.731 }, { "Mr. Smite", 3, 0.561, 0.265 }, { "Captain Greenskin", 3, 0.617, 0.359 },
		{ "Edwin VanCleef", 3, 0.606, 0.459 }, { "Cookie", 3, 0.697, 0.420 },
	},
	entrance = { x = 0.120, y = 0.121, floor = 1 },
})

--[[
	Shadowfang Keep's whole map (Media/Maps/Dungeons/shadowfang-keep-full, Dev/maps/ShadowfangKeepWhole,
	2026-11-06) is Turtle WoW's own map of the whole keep, 1002 x 668, made Forever's: all seven floors drawn
	together on one sheet, to scale from the game's geometry (one fit carries Forever's world onto it, median
	error 1.6 pixels: survey/fit.json). Turtle's extra west wing, its skull and its corridor are painted out,
	and the keep's west wall is drawn across the gap. It carries Torchlite's signature, under the sketch at
	the middle left, the one clear place (LICENSE-MAPS.md). A boss whose skull the sheet paints sits on its
	middle, measured on the shipped picture.
	Three bosses' rooms lie under another floor: the sheet draws Rethilgore's skull and Fenrus's as outlines
	(the Voidwalkers share Fenrus's room), and Razorclaw's room not at all. Their pins there are drawn like
	every other, with nothing to mark them. Bosses with no skull of the sheet's (Fel Steed, Razorclaw, Odo, the
	Deathsworn Captain) take their floor spots carried by the fit, Odo on Forever's own skull carried.
	Its entrance is the painted swirl at the gate.
	The Lower Observatory (shadowfang-keep-4, the client's map 313, Dev/maps/ShadowfangKeepWhole/floor4) is
	Forever's own picture of that floor, from the client's tiles, with its painted skull taken off, and signed
	too. Its name is the client's name for map 313 in today's game (Forever's own floor names could not be
	read), a best guess. Fenrus is in its green room, Nandos on the skull in his yellow room before Arugal's,
	and Springvale on his hall's skull: the owner's annotated map of the keep (2026-11-06; used only for which
	room each boss is in, nothing of it copied) puts them there, on the skulls Forever's own floor pictures
	paint. The Voidwalkers are in Fenrus's room too: four come once Fenrus dies, when Arugal appears for a
	moment and calls them (the owner, 2026-11-06). They share his floor; their exact spot in the room, west
	of him, is approximate. On the whole map their pin is 30 pixels west of his, the journal's spacing for
	pins side by side, so neither hides the other. Silverlaine and Odo sit on the skulls Forever paints in
	their rooms, as the owner's map points. Still to confirm in Forever: the floors of Fenrus, Nandos and
	Springvale, and the ways between floors (Data/Instances/ShadowfangKeep.lua). Inside Forever's dungeons
	the game gives no position, so /aegis where shows each floor's map ID and area but not a spot.
	Dev/maps/ShadowfangKeepWhole/settle.md has the readings and how each spot was found.
]]
UseMaps("ShadowfangKeep", {
	floors = {
		{ false, "shadowfang-keep-full", "Shadowfang Keep", 1002, 668 },
		{ 310, "shadowfang-keep-1", "The Courtyard" }, { 311, "shadowfang-keep-2", "Dining Hall" },
		{ 316, "shadowfang-keep-7", "The Wall Walk" }, { 313, "shadowfang-keep-4", "Lower Observatory" },
		{ 315, "shadowfang-keep-6", "Arugal's Chamber" },
	},
	spots = {
		{ "Rethilgore", 1, 0.826, 0.773 }, { "Fel Steed / Shadow Charger", 1, 0.521, 0.671 },
		{ "Commander Springvale", 1, 0.470, 0.661 }, { "Razorclaw the Butcher", 1, 0.472, 0.559 },
		{ "Baron Silverlaine", 1, 0.372, 0.815 }, { "Odo the Blindwatcher", 1, 0.799, 0.722 },
		{ "Deathsworn Captain", 1, 0.822, 0.512 }, { "Fenrus the Devourer", 1, 0.689, 0.345 },
		{ "Arugal's Voidwalker", 1, 0.659, 0.345 }, { "Wolf Master Nandos", 1, 0.704, 0.290 },
		{ "Archmage Arugal", 1, 0.737, 0.070 },

		{ "Rethilgore", 2, 0.661, 0.711 }, { "Fel Steed / Shadow Charger", 2, 0.331, 0.626 },
		{ "Commander Springvale", 2, 0.278, 0.599 },
		{ "Razorclaw the Butcher", 3, 0.480, 0.290 }, { "Baron Silverlaine", 3, 0.303, 0.767 },
		{ "Odo the Blindwatcher", 4, 0.596, 0.826 }, { "Deathsworn Captain", 4, 0.630, 0.525 },
		{ "Fenrus the Devourer", 5, 0.543, 0.534 }, { "Arugal's Voidwalker", 5, 0.487, 0.557 },
		{ "Wolf Master Nandos", 6, 0.560, 0.624 }, { "Archmage Arugal", 6, 0.639, 0.200 },
	},
	entrance = { x = 0.903, y = 0.690, floor = 1 },
})

--[[
	Blackfathom Deeps' whole map (Media/Maps/Dungeons/blackfathom-deeps-full, Dev/maps/BlackfathomDeepsAlt)
	draws the site's three floors (the client's maps 221-223) at one scale, 0.73 of their own, none of
	them turned: each floor's spots are carried onto it by its fit (fit.py, two methods agreeing within
	a pixel), and a boss whose skull the sheet paints sits on that skull (Ghamoo-ra, Lady Sarevess,
	Gelihast, Kelris, Old Serra'kis and Aku'mai; Lady Sarevess and Gelihast move some 20 and 16 pixels,
	from their rooms' edges to the skulls in the middle). Lorgus Jett's four spots and Baron Aquanis
	have no skull of their own, and keep the carried ones. The sheet's Temple of Elune and its skull
	are on none of the client's floors and have no boss of the journal's: the wing is painted
	out of the picture (2026-10-27), which carries Torchlite's signature at its lower left
	(LICENSE-MAPS.md). Its entrance is the painted swirl at the top.
]]
UseMaps("BlackfathomDeeps", {
	floors = {
		{ false, "blackfathom-deeps-full", "Blackfathom Deeps" },
		{ 221, "blackfathom-deeps-1", "The Pool of Ask'Ar" }, { 222, "blackfathom-deeps-2", "Moonshrine Sanctum" },
		{ 223, "blackfathom-deeps-3", "The Forgotten Pool" },
	},
	spots = {
		{ "Ghamoo-ra", 1, 0.224, 0.406 }, { "Lady Sarevess", 1, 0.065, 0.257 }, { "Gelihast", 1, 0.379, 0.381 },
		{ "Lorgus Jett", 1, 0.432, 0.424 }, { "Lorgus Jett", 1, 0.471, 0.449 },
		{ "Lorgus Jett", 1, 0.407, 0.631 }, { "Lorgus Jett", 1, 0.395, 0.806 },
		{ "Baron Aquanis", 1, 0.452, 0.829 }, { "Twilight Lord Kelris", 1, 0.534, 0.872 }, { "Aku'mai", 1, 0.776, 0.906 },
		{ "Old Serra'kis", 1, 0.533, 0.778 },

		{ "Ghamoo-ra", 2, 0.329, 0.602 }, { "Lady Sarevess", 2, 0.101, 0.360 }, { "Gelihast", 2, 0.523, 0.551 },
		{ "Lorgus Jett", 3, 0.388, 0.200 }, { "Lorgus Jett", 3, 0.441, 0.234 },
		{ "Lorgus Jett", 3, 0.354, 0.483 }, { "Lorgus Jett", 3, 0.338, 0.723 },
		{ "Baron Aquanis", 3, 0.415, 0.754 }, { "Twilight Lord Kelris", 3, 0.519, 0.816 }, { "Aku'mai", 3, 0.856, 0.866 },
		{ "Old Serra'kis", 4, 0.606, 0.312 },
	},
	entrance = { x = 0.315, y = 0.054, floor = 1 },
})

UseMaps("TheStockade", {
	floors = { { 225, "the-stockade" } },
	spots = {
		{ "Targorr the Dread", 1, 0.499, 0.242 }, { "Targorr the Dread", 1, 0.424, 0.464 },
		{ "Targorr the Dread", 1, 0.578, 0.552 }, { "Targorr the Dread", 1, 0.333, 0.375 },
		{ "Kam Deepfury", 1, 0.692, 0.309 }, { "Hamhock", 1, 0.782, 0.457 },
		{ "Dextren Ward", 1, 0.146, 0.214 }, { "Dextren Ward", 1, 0.250, 0.165 }, { "Dextren Ward", 1, 0.175, 0.417 },
		{ "Bazil Thredd", 1, 0.857, 0.510 },
		{ "Bruegal Ironknuckle", 1, 0.381, 0.240 }, { "Bruegal Ironknuckle", 1, 0.295, 0.447 },
		{ "Bruegal Ironknuckle", 1, 0.616, 0.483 }, { "Bruegal Ironknuckle", 1, 0.615, 0.251 },
	},
})

--[[
	Gnomeregan's whole map (Media/Maps/Dungeons/gnomeregan-full, 2026-11-12, the owner's call: "i kinda like having just
	the large over map as the main map but letting users drill down when needed") is Turtle WoW's own map of the whole
	dungeon (Dev/maps/TurtleMaps/Gnomeregan.png), 1002 x 668, used as it is: laid over the client's four floors (226-229)
	it draws no room Forever lacks (the Clockwerk Run and its swirl, the Hall of Gears, the cave, the Clean Zone, the
	Dormitory, the Launch Bay ring, Tinkers' Court, the Engineering Labs and the corridor east to the second swirl are
	all the floors' own), so nothing is painted out and it carries no signature. It comes first, the four floors after it.
	Its five skulls are Forever's five fights, each boss on his: Viscous Fallout on the Hall of Gears' (his room, the
	owner's of 2026-11-11), Grubbis on the cave's, Electrocutioner 6000 on the Launch Bay's, Crowd Pummeler 9-60 on the
	Engineering Labs' and Mekgineer Thermaplugg on Tinkers' Court's, each measured on the picture. The Dark Iron
	Ambassador, a rare with no skull, takes his floor spot carried by its fit (each floor's fit onto this map, matched
	rooms, about 6 pixels' error: the 2026-11-11 marking sheets' fit.json). Its entrance is the painted swirl at the top.
	The swirl at the end of the east corridor is on the Launch Bay floor's map too: by Forever's way in, the back door
	from the Workshop (a best guess, for the owner to confirm).

	The floors' areas (the owner's run of 2026-11-11, and Forever's room names, the WMOAreaTable, with each named room's
	height in the dungeon's model): the client names the rooms "The Clockwerk Run", "The Hall of Gears", "The Dormitory",
	"The Clean Zone", "Launch Bay", "Tinkers' Court" and "Engineering Labs" (the client's own ends in a space), and every
	other room "Gnomeregan". Four of them lie on two floors and are drawn on both: the Hall of Gears (the ring at the top,
	floor 1, and the red hall below it, floor 2), the Dormitory (floors 1 and 2), Launch Bay (the ring, floor 2, and the
	bay below it, floor 3) and the Engineering Labs (floors 3 and 4); so they go on neither and keep the floor shown. The
	Clockwerk Run and the Clean Zone are the first floor's alone, Tinkers' Court the fourth's.
	The map opens on the whole map, as Blackfathom Deeps' does, and follows the rooms only once the player has picked
	a level floor (followFromLevel): from then on it turns between the level floors as they walk, and while the whole map
	is shown it stays on it.
]]
UseMaps("Gnomeregan", {
	floors = {
		{ false, "gnomeregan-full", "Gnomeregan", 1002, 668 },
		{ 226, "gnomeregan-1", "The Hall of Gears", areas = { "The Clockwerk Run", "The Clean Zone" } },
		{ 227, "gnomeregan-2", "The Dormitory" },
		{ 228, "gnomeregan-3", "Launch Bay" }, { 229, "gnomeregan-4", "Tinkers' Court", areas = { "Tinkers' Court" } },
	},
	followFromLevel = true,
	spots = {
		{ "Grubbis", 1, 0.867, 0.377 }, { "Viscous Fallout", 1, 0.656, 0.296 },
		{ "Electrocutioner 6000", 1, 0.322, 0.411 }, { "Crowd Pummeler 9-60", 1, 0.445, 0.882 },
		{ "Dark Iron Ambassador", 1, 0.1454, 0.5812 }, { "Mekgineer Thermaplugg", 1, 0.171, 0.384 },

		-- Viscous Fallout is in the Hall of Gears, the red room of the second floor's map (the owner, 2026-11-11,
		-- and their run's reading there, "The Hall of Gears"): the first floor's map only looks down into it.
		{ "Grubbis", 2, 0.819, 0.651 }, { "Viscous Fallout", 3, 0.760, 0.469 },
		{ "Electrocutioner 6000", 3, 0.248, 0.679 }, { "Crowd Pummeler 9-60", 4, 0.438, 0.865 },
		{ "Dark Iron Ambassador", 5, 0.295, 0.540 }, { "Mekgineer Thermaplugg", 5, 0.313, 0.300 },
	},
	entrance = { x = 0.779, y = 0.106, floor = 1 },
})

UseMaps("RazorfenKraul", {
	floors = { { 301, "razorfen-kraul" } },
	spots = {
		{ "Aggem Thorncurse", 1, 0.808, 0.545 }, { "Death Speaker Jargba", 1, 0.879, 0.414 }, { "Roogug", 1, 0.648, 0.421 },
		{ "Overlord Ramtusk", 1, 0.569, 0.298 }, { "Razorfen Spearhide", 1, 0.534, 0.355 },
		{ "Agathelos the Raging", 1, 0.112, 0.724 }, { "Blind Hunter", 1, 0.110, 0.303 },
		{ "Charlga Razorflank", 1, 0.264, 0.324 }, { "Earthcaller Halmgar", 1, 0.494, 0.471 },
	},
})

-- The graveyard's three rares share six places: one of them, at one of the six, about one run in three.
local GRAVEYARD_RARE_SPOTS = {
	{ 0.416, 0.679 }, { 0.409, 0.466 }, { 0.367, 0.439 }, { 0.355, 0.664 }, { 0.262, 0.691 }, { 0.217, 0.572 },
}
local graveyardSpots = { { "Interrogator Vishas", 1, 0.715, 0.589 }, { "Bloodmage Thalnos", 1, 0.244, 0.508 } }
for _, rare in ipairs({ "Azshir the Sleepless", "Fallen Champion", "Ironspine" }) do
	for _, spot in ipairs(GRAVEYARD_RARE_SPOTS) do graveyardSpots[#graveyardSpots + 1] = { rare, 1, spot[1], spot[2] } end
end
UseMaps("ScarletMonasteryGraveyard", { floors = { { 302, "scarlet-monastery-graveyard" } }, spots = graveyardSpots })

UseMaps("ScarletMonasteryLibrary", {
	floors = { { 303, "scarlet-monastery-library" } },
	spots = { { "Houndmaster Loksey", 1, 0.308, 0.878 }, { "Arcanist Doan", 1, 0.832, 0.745 } },
})

UseMaps("ScarletMonasteryArmory", {
	floors = { { 304, "scarlet-monastery-armory" } },
	spots = { { "Herod", 1, 0.786, 0.108 } },
})

UseMaps("ScarletMonasteryCathedral", {
	floors = { { 305, "scarlet-monastery-cathedral" } },
	spots = {
		{ "High Inquisitor Fairbanks", 1, 0.554, 0.261 }, { "Scarlet Commander Mograine", 1, 0.491, 0.272 },
		{ "High Inquisitor Whitemane", 1, 0.490, 0.169 },
	},
})
