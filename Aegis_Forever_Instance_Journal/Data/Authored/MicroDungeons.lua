local _, ns = ...

--[[
	Micro dungeons: mines, caves, a tunnel and a keep in the starting zones, and Orgrimmar's Cleft of
	Shadow, each on Blizzard's own drawn map of it: the owner's pictures of retail's microdungeon
	maps and, for the Cleft, of the city's second map (the reference folder's Maps/Micro Dungeon
	Maps, 1002 x 668 each), unchanged, and so not signed, but for the Cleft's and Night Web's
	Hollow's (below). Each is placed by retail's map region for it, its UiMapAssignment rectangle, the
	calibration's two spots the picture's corners, read on the zone's map through Forever's region of
	that zone. They are WMOs on the zone's ground, so the client reports a player in them on the
	zone's own map. The owner walked every one in game (Classic Era, whose floors are Forever's,
	2026-10-27, Durotar's, Orgrimmar's and Teldrassil's 2026-10-28, Tirisfal's 2026-10-29) with these
	placements. Every one but the Cleft reads its own name on the ground outside its doors too, so
	each of those pictures shows only indoors (indoors = true), from the doorway in, where the minimap
	turns. The ways in, with the cave icon (the keep's, a building's, with the delve icon: icon =
	"building"), are where the owner's minimap turned at the doors (the Cleft's, where its name
	turns and, for its left way, at the owner's notes; Dev/maps/MicroDungeons/ways_from_readings.md),
	but for Jasperlode's and Echo Ridge's. Only the Cleft leads to a dungeon: Ragefire Chasm's door is on its
	picture.
]]

--[[
	Elwynn Forest's mines (retail's maps 38 and 39, Fargodeep Mine's two levels; 40, Jasperlode
	Mine; 426, Echo Ridge Mine; Media/Maps/Elwynn*, made by Dev/maps/ElwynnMines/make.py). Forever's
	floors of each mine land on the drawn floor: within 1 yard for 96-99% of it, the shift that fits
	best half a yard or less (Dev/maps/ElwynnMines/geometry, which reads Forever's own model of the
	mines). Every room reads the mine's name, and so does the ground before its doors (the owner's
	readings at Fargodeep; the terrain's areas at all three).
	Fargodeep Mine has two levels, as retail has them (a menu of them, retail's names, Fargodeep
	Mine and Lower Mines). Retail's maps split the mine by its groups, and the levels meet at one
	place only: the ramp at the north end, between the upper level's arm and the lower level's long
	passage east (WMO portal 7). The upper level lies over the lower in much of the mine, and the
	client gives no height, so the rule is Blackrock's middle level's: the lower level's name counts
	first on its own floors (claims, boxes on its picture); where the upper level's floors lie over
	or beside them (overlaps), the level the player was last seen on keeps them; the upper level has
	none and shows everywhere else. On the ramp the map swaps at the owner's mark (world -9758.1,
	149.3, 2026-10-27), 1.6 yards up from the levels' joint: the line runs through it along the
	joint, and round it a band 1.2 to 3.4 yards wide keeps the level the player came from (the
	claims reach over the line, the overlaps over it the other way, each edge a staircase of boxes:
	the joint slants across the picture), so walking along the mark, or over it slantwise, never
	turns the map back and forth. So the map turns there walking down and walking up, 0.3 to 4.1
	yards past the mark's line, whichever way the player walks, where they leave the band (the
	staircases, the client's rounding of the position to 4 places, and the player followed every 0.2
	seconds), and nowhere else (checked on every floor cell, and on 9216 walks at 7 and 9.8 yards a
	second, along the mark too). A player seen on no level (logged in or reloaded in the mine) on
	the upper floor over the lower level's, and the band at the mark (1891 square yards, the
	overlaps), is shown the lower level until they walk out of the overlaps, or over the ramp. Each
	level's picture has a link to the other at the mark.
	The mine's one way in is its top doorway, the mine-cart track, where the owner's minimap turned
	walking in (the owner's pick): the lower doorway below it, where it turned walking out (0.3846,
	0.8147), has none, though walking in there shows the lower level, whose claims hold it.
	Jasperlode and Echo Ridge are one level each; their ways in are their doorways in Forever's
	model (WMO portals 12 and 9), and the owner found both mines lined up in game.
]]
local FARGODEEP_LEVELS = { "Fargodeep Mine", "Lower Mines" }
local FARGODEEP_AREAS = { ["Fargodeep Mine"] = true }
ns.AddSubMap({
	key = "FargodeepMine",
	name = "Fargodeep Mine",
	parentMapID = 1429,
	levels = FARGODEEP_LEVELS,
	level = 1,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\ElwynnFargodeepMine",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1429, x = 0.3892, y = 0.8217 },
	calibration = {
		{ map = { 0.361200, 0.760576 }, picture = { 0, 0 } },
		{ map = { 0.430348, 0.829703 }, picture = { 1, 1 } },
	},
	areas = FARGODEEP_AREAS,
	links = { { x = 0.5519, y = 0.3631, level = 2 } },   -- the ramp down, at the owner's mark
})

-- The lower level, with no way in of its own. Its claims hold its floors (groups 4, 5, 7, 9-14, 17,
-- 18) and the ramp below the mark and up to 2.2 yards above it, at the top; its overlaps, the upper
-- level's floors over or beside them, and the band round the mark
-- (Dev/maps/ElwynnMines/geometry/step7_claims.py, which checks them on every floor cell).
ns.AddSubMap({
	key = "FargodeepMineLower",
	name = "Fargodeep Mine",
	parentMapID = 1429,
	levels = FARGODEEP_LEVELS,
	level = 2,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\ElwynnFargodeepMineLower",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.359040, 0.764897 }, picture = { 0, 0 } },
		{ map = { 0.432509, 0.838344 }, picture = { 1, 1 } },
	},
	areas = FARGODEEP_AREAS,
	claims = {
		{ 0.5508, 0.0898, 0.6188, 0.3084 },   -- top middle: groups 14, 18, the ramp below the mark
		{ 0.7664, 0.1317, 0.8464, 0.7575 },   -- middle right: groups 4, 5, 9, 10
		{ 0.7225, 0.1407, 0.7665, 0.1827 },   -- top right: groups 10
		{ 0.6806, 0.1826, 0.7665, 0.5150 },   -- top right: groups 5, 9, 10, 13, 14
		{ 0.5369, 0.1946, 0.6807, 0.2755 },   -- top middle: groups 14, 18, the ramp below the mark
		{ 0.5429, 0.2754, 0.5450, 0.2785 },   -- top middle: the band round the mark
		{ 0.5449, 0.2754, 0.6807, 0.2965 },   -- top middle: groups 14, the ramp below the mark
		{ 0.5568, 0.2964, 0.6627, 0.3204 },   -- top middle: groups 14, the ramp below the mark
		{ 0.6487, 0.3712, 0.6807, 0.5150 },   -- middle: groups 9, 13
		{ 0.6167, 0.5149, 0.7286, 0.5659 },   -- middle: groups 9, 13
		{ 0.5289, 0.5658, 0.7486, 0.6707 },   -- middle: groups 13
		{ 0.3313, 0.6137, 0.5010, 0.7366 },   -- bottom left: groups 11, 12, the lower doorway
		{ 0.4670, 0.6706, 0.7665, 0.9252 },   -- bottom middle: groups 4, 7, 11, 13, 17
	},
	overlaps = {
		{ 0.5908, 0.1377, 0.8084, 0.6228 },   -- middle: upper level's groups 8, 19, 20, 21
		{ 0.5349, 0.2485, 0.5450, 0.2755 },   -- top middle: the ramp above the mark
		{ 0.5449, 0.2664, 0.5490, 0.2755 },   -- top middle: the ramp above the mark
		{ 0.5349, 0.2754, 0.5549, 0.3024 },   -- top middle: the ramp above the mark
		{ 0.5548, 0.2934, 0.5589, 0.3024 },   -- top middle: the ramp above the mark
		{ 0.3672, 0.3023, 0.5649, 0.7575 },   -- middle: upper level's groups 1, 3, 6, 8, the ramp
		{ 0.5648, 0.5628, 0.5909, 0.6258 },   -- middle: upper level's groups 8
	},
	links = { { x = 0.5488, y = 0.2829, level = 1 } },   -- the ramp up, at the owner's mark
})

ns.AddSubMap({
	key = "JasperlodeMine",
	name = "Jasperlode Mine",
	parentMapID = 1429,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\ElwynnJasperlodeMine",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1429, x = 0.6165, y = 0.5362 },   -- its doorway (WMO portal 12)
	calibration = {
		{ map = { 0.570840, 0.451665 }, picture = { 0, 0 } },
		{ map = { 0.663974, 0.544771 }, picture = { 1, 1 } },
	},
	areas = { ["Jasperlode Mine"] = true },
})

ns.AddSubMap({
	key = "EchoRidgeMine",
	name = "Echo Ridge Mine",
	parentMapID = 1429,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\ElwynnEchoRidgeMine",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1429, x = 0.4773, y = 0.3164 },   -- its doorway (WMO portal 9)
	calibration = {
		{ map = { 0.450156, 0.242124 }, picture = { 0, 0 } },
		{ map = { 0.530540, 0.322484 }, picture = { 1, 1 } },
	},
	areas = { ["Echo Ridge Mine"] = true },
})

--[[
	Dun Morogh's caves and its tunnel (retail's maps 28, Coldridge Pass; 29, The Grizzled Den; 31,
	Gol'Bolar Quarry, the quarry's mine; 428, Frostmane Hovel; Media/Maps/DunMorogh*, made by
	Dev/maps/DunMoroghCaves/make.py, which works out the calibrations). Forever's Dun Morogh is
	classic's, not retail's: its region (Dev/AegisMapCheck/Regions.lua) reaches less far west and
	south than retail's map 27, so the rectangles are read on it. Inside, each reads its own name, as
	the ground outside its doors does: Coldridge Pass, The Grizzled Den, Gol'Bolar Quarry (the
	quarry's mine, whose way in is in the quarry; the owner lined it up in game with this placement).
	Frostmane Hovel has no name of its own in classic: inside it reads Coldridge Valley, as the valley
	outside does, so it shows indoors under that name inside its picture's rectangle, where the only
	building of Forever's is the hovel itself (its WMO, every group named by the ground under it). At
	the back of the cave that ground is Dun Morogh's own, which names nothing (a subzone of ""), so
	there the picture keeps a player already on it (unnamed), as the Depths' door does. Coldridge
	Pass, the tunnel from Coldridge Valley to Kharanos, has a way in at each end, far apart (a list of
	them): the south end, from the valley, and the north end, toward Kharanos. The Grizzled Den's way
	in is between the two ends of its door the owner read. Frostmane Hold (retail's map 470) is left
	out: the owner found its inside nothing like the picture.
]]
ns.AddSubMap({
	key = "ColdridgePass",
	name = "Coldridge Pass",
	parentMapID = 1426,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DunMoroghColdridgePass",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = {
		{ mapID = 1426, x = 0.3412, y = 0.7149 },   -- the south end, from Coldridge Valley
		{ mapID = 1426, x = 0.3567, y = 0.6597 },   -- the north end, toward Kharanos
	},
	calibration = {
		{ map = { 0.316159, 0.652665 }, picture = { 0, 0 } },
		{ map = { 0.383164, 0.719670 }, picture = { 1, 1 } },
	},
	areas = { ["Coldridge Pass"] = true },
})

ns.AddSubMap({
	key = "GrizzledDen",
	name = "The Grizzled Den",
	parentMapID = 1426,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DunMoroghGrizzledDen",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1426, x = 0.4210, y = 0.5335 },
	calibration = {
		{ map = { 0.359256, 0.437335 }, picture = { 0, 0 } },
		{ map = { 0.461895, 0.539975 }, picture = { 1, 1 } },
	},
	areas = { ["The Grizzled Den"] = true },
})

ns.AddSubMap({
	key = "GolBolarQuarry",
	name = "Gol'Bolar Quarry",
	parentMapID = 1426,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DunMoroghGolBolarQuarry",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1426, x = 0.7074, y = 0.5627 },
	calibration = {
		{ map = { 0.679204, 0.490278 }, picture = { 0, 0 } },
		{ map = { 0.755145, 0.566219 }, picture = { 1, 1 } },
	},
	areas = { ["Gol'Bolar Quarry"] = true },
})

ns.AddSubMap({
	key = "FrostmaneHovel",
	name = "Frostmane Hovel",
	parentMapID = 1426,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DunMoroghFrostmaneHovel",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1426, x = 0.2692, y = 0.8018 },
	calibration = {
		{ map = { 0.262708, 0.782311 }, picture = { 0, 0 } },
		{ map = { 0.316818, 0.836420 }, picture = { 1, 1 } },
	},
	areas = { ["Coldridge Valley"] = true },
	unnamed = true,
})

--[[
	Durotar's Burning Blade Coven (retail's map 2; Media/Maps/DurotarBurningBladeCoven, made by
	Dev/maps/DurotarCaves/make.py, which works out the calibration). Forever's Durotar is retail's:
	its region (Dev/AegisMapCheck/Regions.lua) is retail's map 1's to a hundredth of a yard, so the
	rectangle is read on it as retail has it. Inside, the cave reads its own name, as the ground
	before its door does, on the picture's bottom edge and further out (the owner's readings,
	Classic Era, 2026-10-28). Its way in is where the owner's minimap turned at the door, the end of
	the passage the picture draws at its bottom: seven turns, all within 0.0003 of it. Retail's
	Spitescale Cavern (map 464) is left out: it is not in the game (the owner).
]]
ns.AddSubMap({
	key = "BurningBladeCoven",
	name = "Burning Blade Coven",
	parentMapID = 1411,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DurotarBurningBladeCoven",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1411, x = 0.4534, y = 0.5593 },
	calibration = {
		{ map = { 0.416832, 0.511442 }, picture = { 0, 0 } },
		{ map = { 0.467140, 0.561749 }, picture = { 1, 1 } },
	},
	areas = { ["Burning Blade Coven"] = true },
})

--[[
	Tiragarde Keep (retail's maps 3 and 4, its two levels; Media/Maps/DurotarTiragardeKeep and
	DurotarTiragardeKeepGreatHall, made by Dev/maps/DurotarCaves/make.py). The keep is one WMO on
	Durotar's ground, so the client reports a player in it on Durotar (1411); its name set names
	nothing, so every room reads the ground's area, Tiragarde Keep, as the ground around it does
	(the owner's readings, 2026-10-28): each picture shows only indoors (indoors = true), from the
	front door in. Both pictures have retail's one rectangle, and Forever's floors of each level
	land on its drawn floor: within 1 yard for 95% of map 3's and 99% of map 4's, the shift that
	fits best a yard or so and barely better than none (Dev/maps/DurotarKeep/geometry, which reads
	Forever's own model of the keep; indoors, Classic Era's floors, where the owner walked it, are
	Forever's to half a yard).
	It has two levels, as retail has them (a menu of them, retail's names, Great Hall and Tiragarde
	Keep, top to bottom, as the journal's other areas list theirs; retail's lists the keep's first):
	the ground floor with the corridor over its north side, and the great hall over the ground floor
	with the room at the head of the war room's stair and the tower's top. They meet at two stairs
	up from the corridor, and the owner marked both (2026-10-28). At the war room's stair the map
	swaps at the owner's mark (world -230.0, -5097.5), 1.5 yards past the stair's head: the claims'
	edge runs through it along the stair's head, straight on through the room under the stair's
	head. The tower's stair climbs in four flights round a well, its floors over one another in
	plan, and retail splits it by height (map 4 from z 44, on the third flight), which the client
	does not give. The one split every walk up or down the tower crosses is the head of the first
	flight, where it meets the landing: the map swaps there, and the landing, the flights above it
	and the top floor are the Great Hall's. The owner's mark (world -220.4, -5128.1) is 4.6 yards
	on, over the landing and under the top floor (the owner's walk fits either), so it shows the
	Great Hall on both. The great hall lies over the ground floor, so the rule is Fargodeep's: the
	keep's level counts first on its own floors (claims, boxes on its picture); where the Great
	Hall's floors lie over or beside them (overlaps), the level the player was last seen on keeps
	them; the Great Hall has none and shows everywhere else. So the map turns at both swaps walking
	up and walking down, within 0.2 yards before the swap's line and 2.5 yards after it (the
	client's rounding of the position to 4 places, and the player followed every 0.2 seconds), and
	nowhere else (checked on every floor cell, and on 3168 walks at 7 and 9.8 yards a second), but
	that a player walking down the first flight along its east wall, under the fourth flight's edge,
	keeps the Great Hall down it, over the tower's foot and through its door 2 or 3 yards into the
	corridor. The back of the small room under the head of the war room's stair, beyond the mark (18
	square yards), shows the Great Hall: the player walking up and the player in that room stand on
	the same spot there, and one who walks in there keeps the Great Hall under the great hall until
	they reach floor of the keep's level alone. A player seen on no level (logged in or reloaded in
	the keep) on the great hall's floor or the tower's upper floors over its foot (1025 square
	yards, the overlaps) is shown the keep's level until they walk out of the overlaps, or over a
	swap; one come in from the roof by the tower's door sees the Great Hall at once: the door's
	first yards are no claims, so the corridor's end under them (4.5 square yards) shows the Great
	Hall too. Each level's picture has a link to the other at both marks. The way in is the front
	door, where the owner's minimap turned walking in, the four times at one spot, with a building's
	icon (icon = "building"). The roof walk the Great Hall's picture draws along its top, out of the
	tower's door, is outdoors: the zone's map shows there, as on the ground round the walls.
]]
-- Its levels, top to bottom (retail's menu lists the keep's first).
local TIRAGARDE_LEVELS = { "Great Hall", "Tiragarde Keep" }
local TIRAGARDE_AREAS = { ["Tiragarde Keep"] = true }
-- The keep's level, with the way in. Its claims hold its floors (the ground floor, the corridor,
-- the war room's stair up to the mark, the tower's foot and its first flight) and the front door's
-- first yards; its overlaps, the Great Hall's floors over or beside them
-- (Dev/maps/DurotarKeep/geometry/step7_claims.py, which checks them on every floor cell).
ns.AddSubMap({
	key = "TiragardeKeep",
	name = "Tiragarde Keep",
	parentMapID = 1411,
	levels = TIRAGARDE_LEVELS,
	level = 2,
	indoors = true,
	icon = "building",
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DurotarTiragardeKeep",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1411, x = 0.5910, y = 0.5831 },
	calibration = {
		{ map = { 0.584397, 0.570685 }, picture = { 0, 0 } },
		{ map = { 0.608038, 0.594326 }, picture = { 1, 1 } },
	},
	areas = TIRAGARDE_AREAS,
	claims = {
		{ 0.3632, 0.2395, 0.5430, 0.2575 },   -- top middle: the stair, the corridor, ...
		{ 0.5628, 0.2455, 0.5709, 0.2515 },   -- top middle: the rounding's margin
		{ 0.5668, 0.2514, 0.5909, 0.2575 },   -- top middle: the rounding's margin
		{ 0.3632, 0.2574, 0.5390, 0.2695 },   -- top middle: the corridor, the stair, ...
		{ 0.5668, 0.2574, 0.6028, 0.2755 },   -- top middle: the tower's foot
		{ 0.6107, 0.2574, 0.6308, 0.2755 },   -- top right: the tower's foot, flight A
		{ 0.6027, 0.2634, 0.6108, 0.2755 },   -- top right: the tower's foot, flight A
		{ 0.3632, 0.2694, 0.5430, 0.3893 },   -- top middle: the corridor, the stair, ...
		{ 0.5429, 0.2754, 0.5470, 0.3893 },   -- top middle: the corridor, the east hall
		{ 0.5628, 0.2754, 0.6308, 0.3474 },   -- top middle: the tower's foot, flight A, ...
		{ 0.5469, 0.2814, 0.5629, 0.3474 },   -- top middle: the corridor
		{ 0.5469, 0.3473, 0.6428, 0.3893 },   -- middle: the tower's foot, the east hall, ...
		{ 0.3273, 0.3712, 0.3394, 0.8563 },   -- middle left: the rear storeroom, ...
		{ 0.3393, 0.3772, 0.3474, 0.3833 },   -- middle left: the room under group 1
		{ 0.3393, 0.3832, 0.3553, 0.8563 },   -- middle left: the entry hall, ...
		{ 0.3552, 0.3892, 0.6667, 0.8983 },   -- bottom middle: the east hall, the rear tower, ...
		{ 0.2395, 0.4491, 0.3274, 0.5929 },   -- middle left: the entry, the front door's step
		{ 0.2914, 0.7365, 0.3274, 0.8563 },   -- bottom left: the rear storeroom
	},
	overlaps = {
		{ 0.5588, 0.2395, 0.6348, 0.2575 },   -- top middle: the tower's upper floors
		{ 0.5469, 0.2574, 0.6068, 0.2995 },   -- top middle: the tower's upper floors
		{ 0.6267, 0.2574, 0.6468, 0.3533 },   -- top right: the tower's upper floors
		{ 0.5469, 0.2994, 0.5869, 0.3054 },   -- top middle: the tower's upper floors
		{ 0.5469, 0.3053, 0.6268, 0.3593 },   -- top middle: the tower's upper floors
		{ 0.2794, 0.3652, 0.3593, 0.6767 },   -- middle left: the great hall, the room at the stair
		{ 0.3672, 0.3652, 0.6228, 0.6827 },   -- middle: the great hall
		{ 0.3592, 0.3712, 0.3673, 0.6767 },   -- middle left: the great hall
	},
	links = {
		{ x = 0.3600, y = 0.3200, level = 1 },   -- up the war room's stair, at the owner's mark
		{ x = 0.6048, y = 0.2048, level = 1 },   -- up the tower, at the owner's mark
	},
})

-- The Great Hall, with no way in of its own: the tower's door out to the roof is reached only from
-- inside.
ns.AddSubMap({
	key = "TiragardeKeepGreatHall",
	name = "Tiragarde Keep",
	parentMapID = 1411,
	levels = TIRAGARDE_LEVELS,
	level = 1,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DurotarTiragardeKeepGreatHall",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.584397, 0.570685 }, picture = { 0, 0 } },
		{ map = { 0.608038, 0.594326 }, picture = { 1, 1 } },
	},
	areas = TIRAGARDE_AREAS,
	links = {
		{ x = 0.3600, y = 0.3200, level = 2 },   -- down the war room's stair, at the owner's mark
		{ x = 0.6048, y = 0.2048, level = 2 },   -- down the tower, at the owner's mark
	},
})

--[[
	Skull Rock (retail's map 5; Media/Maps/DurotarSkullRock, made by Dev/maps/DurotarCaves/make.py), a
	cave on Durotar's ground, placed as the coven is: retail's rectangle for it read on Durotar (1411).
	Inside, the cave reads its own name, as the ground before its door does, on the picture's bottom
	edge and further out (the owner's readings, Classic Era, 2026-10-28), so it shows only indoors, as
	the owner found it in game. Its way in is where the owner's minimap turned at the door, the end of
	the passage the picture draws at its right, between the owner's two notes there (outside and
	inside the entrance): three turns at the one spot, and the turn walking out within 0.0003 of it.
	Retail's Dustwind Cave (map 6) is left out: it is not in the game, its ground classic's Drygulch
	Ravine (the owner).
]]
ns.AddSubMap({
	key = "SkullRock",
	name = "Skull Rock",
	parentMapID = 1411,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DurotarSkullRock",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1411, x = 0.5483, y = 0.0947 },
	calibration = {
		{ map = { 0.504303, 0.064634 }, picture = { 0, 0 } },
		{ map = { 0.555366, 0.115697 }, picture = { 1, 1 } },
	},
	areas = { ["Skull Rock"] = true },
})

--[[
	Orgrimmar's Cleft of Shadow (retail's map 86, the city's second map, its Cataclysm drawing of the
	Cleft; Media/Maps/OrgrimmarCleftOfShadow, made by Dev/maps/OrgrimmarCleft/build.py). Forever's
	Orgrimmar is classic's city, not retail's rebuilt one: its region (Dev/AegisMapCheck/Regions.lua) is
	its own, so retail's rectangle is read on it. The drawing fits Forever's Cleft but for a prong at the
	bottom left the owner flagged (2026-10-28), where the client has no floor: it is painted out in the
	map's own style, the bend's floor ending on a wall there, and so this picture is signed. Elsewhere
	it draws less than there is (the left way's passage past where it fades, the cave past Ragefire
	Chasm's portal, walls up to 7 yards inside the floor), left as drawn
	(Dev/maps/OrgrimmarCleft/cleft.md). The Cleft is part of the city's own WMO, outdoors all through,
	and its name is the WMO's own (WMOAreaTable): no area of the game's bears it, so it has no area
	id, and a client in another language knows it by its translation (the locales' AREA_NAMES).
	Nothing outside it reads that name, so the picture shows under it, indoors or out (no indoors), as
	the owner found it in game ("works great"), from where the name turns at its two ways in (the
	owner's readings, Classic Era, 2026-10-28), each with the cave icon. The left way, down from the
	gate road, turns at the foot of its passage, where it meets the bend (five turns within 0.0006);
	its icon is at the passage's mouth on the gate road, 37 yards up it, between the owner's two notes
	there ("Left entrance ... outside / inside", both still reading Orgrimmar), where a player on the
	city's map turns off the road (the main session's pick for the owner, 2026-10-28). The right
	way, down from the Drag, turns near its top as the picture draws it, between the owner's two notes
	there: four turns, stepping back and forth, within 0.0002 of it. Ragefire Chasm's door is on the
	picture where it draws the dungeon's portal, the owner's mark (world 1812.6, -4413.4): the
	game's own entrance (Classic Era's area trigger 2230, world 1818.4, -4427.3) is about 15 yards
	east-north-east of it, at the mouth of the cave past the portal, which the picture does not draw.
	The dungeon's icon on the Orgrimmar map stays its own (Data/Instances/RagefireChasm.lua).
]]
ns.AddSubMap({
	key = "CleftOfShadow",
	name = "Cleft of Shadow",
	parentMapID = 1454,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\OrgrimmarCleftOfShadow",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = {
		{ mapID = 1454, x = 0.4060, y = 0.5388 },   -- the left way, at its mouth on the gate road
		{ mapID = 1454, x = 0.5303, y = 0.4077 },   -- the right way, from the Drag
	},
	calibration = {
		{ map = { 0.344623, 0.365193 }, picture = { 0, 0 } },
		{ map = { 0.602778, 0.623249 }, picture = { 1, 1 } },
	},
	areas = { ["Cleft of Shadow"] = true },
	instances = { RagefireChasm = { x = 0.6889, y = 0.4958 } },
})

--[[
	Teldrassil's caves (retail's maps 58, Shadowthread Cave; 59, Fel Rock; 60 and 61, Ban'ethil
	Barrow Den's two levels; Media/Maps/Teldrassil*, made by Dev/maps/TeldrassilCaves/make.py, which
	works out the calibrations). Forever's Teldrassil is classic's, not retail's: its region
	(Dev/AegisMapCheck/Regions.lua) reaches less far every way than retail's map 57, so the
	rectangles are read on it. Each cave is one WMO on Teldrassil's ground, the one retail's rows
	name (Forever's files are retail's; Classic Era's, where the owner walked them, have the same
	floors), so the client reports a player in it on Teldrassil (1438). Inside, each reads its own
	name, and so does its mouth outside the door, the WMO's outdoor part (the owner's readings,
	Classic Era, 2026-10-28): each picture shows only indoors (indoors = true), from the door in.
	Forever's floors land on the drawn floor (Dev/maps/TeldrassilCaves, which reads Forever's own
	models of the caves): within 1 yard for 90% of Shadowthread's and 95% of Fel Rock's, the shift
	that fits best half a yard or none. The ways in are where the owner's minimap turned at the
	doors: Shadowthread's two turns in within 0.0001 of it, Fel Rock's three at one spot.
]]
ns.AddSubMap({
	key = "ShadowthreadCave",
	name = "Shadowthread Cave",
	parentMapID = 1438,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TeldrassilShadowthreadCave",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1438, x = 0.5674, y = 0.3134 },
	calibration = {
		{ map = { 0.525286, 0.234622 }, picture = { 0, 0 } },
		{ map = { 0.619558, 0.328913 }, picture = { 1, 1 } },
	},
	areas = { ["Shadowthread Cave"] = true },
})

ns.AddSubMap({
	key = "FelRock",
	name = "Fel Rock",
	parentMapID = 1438,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TeldrassilFelRock",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1438, x = 0.5460, y = 0.5209 },
	calibration = {
		{ map = { 0.503722, 0.477215 }, picture = { 0, 0 } },
		{ map = { 0.558635, 0.532140 }, picture = { 1, 1 } },
	},
	areas = { ["Fel Rock"] = true },
})

--[[
	Ban'ethil Barrow Den (retail's maps 60 and 61, its two levels;
	Media/Maps/TeldrassilBanethilBarrowDen and TeldrassilBanethilBarrowDenLower). Retail's two
	pictures have rectangles of their own: the Lower Den's is drawn smaller and reaches further
	every way, round the Upper Den's. Forever's floors of each level land on its picture: within 1
	yard for 82% of the Lower Den's, and 80% of the Upper Den's but the room the second mark is in
	and the passage to it (Rm02 and Hall02, groups 4 and 10), which its picture draws as a dark
	faded passage running off at its bottom left; the shift that fits best half a yard or none.
	It has two levels, as retail has them (a menu of them, retail's names, Upper Den and Lower Den,
	top to bottom, as retail's menu lists them too): the way in and the halls below it, and the
	deeper halls, which lie mostly 20 to 40 yards under the Upper Den's where the two are over one
	another (529 square yards in plan). They meet at two places only, and the owner marked both
	(2026-10-28). At the first, between Hall12 and Hall05, the floor is level (z 1293 on both
	sides), and the owner's mark (world 9828.4, 1558.2) is on the joint. At the second, the head of
	a ramp down from Rm02 to the Lower Den, the owner's mark (world 9739.3, 1622.6) is 2.3 yards
	down the ramp. The map swaps at each mark: the claims' edge runs along the joint through it, a
	staircase of boxes (both joints slant across the picture), and round each mark's line a band two
	to four yards wide keeps the level the player came from (the claims reach over the line, the
	overlaps over it the other way), so walking along a mark never turns the map back and forth. The
	rule is Fargodeep's and the keep's: the Upper Den's level counts first on its own floors
	(claims, boxes on its picture); where the Lower Den's floors lie under or beside them
	(overlaps), the level the player was last seen on keeps them; the Lower Den has none and shows
	everywhere else, its picture's rectangle round the Upper Den's. So the map turns at both marks
	walking down and walking up, 0.6 to 4.1 yards past the mark's line, whichever way the player
	walks, where they leave the band (the staircase, the client's rounding of the position to 4
	places, and the player followed every 0.2 seconds), and nowhere else (checked on every floor
	cell, and on 6432 walks at 7 and 9.8 yards a second, along the marks too). A player seen on no
	level (logged in or reloaded in the den) on the Lower Den's floors under the Upper Den's (Hall05
	and Hall10 under the way in, Hall08 and Hall09 under Hall03 and Hall11, and the band at each
	mark: 980 square yards, the overlaps) is shown the Upper Den until they walk out of the
	overlaps, 13 yards at most, or over a mark. Each level's picture has a link to the other at both
	marks. The way in is the door, where the owner's minimap turned walking in, the three times at
	one spot, in the Upper Den's first room. The ledge outside the door, the WMO's outdoor part, is
	outdoors: the zone's map shows there.
]]
-- Its levels, top to bottom (as retail's menu lists them).
local BANETHIL_LEVELS = { "Upper Den", "Lower Den" }
local BANETHIL_AREAS = { ["Ban'ethil Barrow Den"] = true }
-- The Upper Den, with the way in. Its claims hold its floors (the way in, the halls below it, up to
-- each mark and a yard or two past it) and the door's first yards; its overlaps, the Lower Den's
-- floors under or beside them, and the band round each mark
-- (Dev/maps/TeldrassilCaves/step7_claims.py, which checks them on every floor cell).
ns.AddSubMap({
	key = "BanethilBarrowDen",
	name = "Ban'ethil Barrow Den",
	parentMapID = 1438,
	levels = BANETHIL_LEVELS,
	level = 1,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TeldrassilBanethilBarrowDen",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1438, x = 0.4433, y = 0.5794 },
	calibration = {
		{ map = { 0.418248, 0.574462 }, picture = { 0, 0 } },
		{ map = { 0.463422, 0.619645 }, picture = { 1, 1 } },
	},
	areas = BANETHIL_AREAS,
	claims = {
		{ 0.4910, 0.0778, 0.5789, 0.1557 },   -- top middle: the door's room, Entry01, Entry02, Rm03
		{ 0.4670, 0.1377, 0.5230, 0.2935 },   -- top middle: Entry02, ext01, Rm03, ...
		{ 0.2674, 0.1556, 0.5549, 0.2875 },   -- top middle: Entry02, Entry03, ext01, Rm03, ...
		{ 0.1836, 0.2754, 0.2635, 0.9521 },   -- middle left: Rm02, Hall14, the ramp's head
		{ 0.2634, 0.2754, 0.2675, 0.9462 },   -- middle left: Hall14, Rm02, the ramp's head
		{ 0.2674, 0.2874, 0.2875, 0.9282 },   -- middle left: Hall14, Rm02, the ramp's head, Hall02
		{ 0.2874, 0.2874, 0.2995, 0.9162 },   -- middle left: Hall14, Hall02, Rm02, ...
		{ 0.2994, 0.2874, 0.4871, 0.8923 },   -- middle left: Hall15, Hall11, Hall14, Hall02, ...
		{ 0.5149, 0.3113, 0.5190, 0.3174 },   -- top middle: the rounding's margin
		{ 0.5109, 0.3173, 0.5270, 0.3354 },   -- top middle: Hall12
		{ 0.5269, 0.3233, 0.5350, 0.3294 },   -- top middle: the rounding's margin
		{ 0.5269, 0.3293, 0.5430, 0.3354 },   -- top middle: Hall12
		{ 0.4870, 0.3353, 0.5549, 0.7066 },   -- middle: Hall15, Hall12, Hall03
		{ 0.5548, 0.3473, 0.5709, 0.3953 },   -- middle: Hall12
		{ 0.5708, 0.3532, 0.5749, 0.3713 },   -- middle: Hall12
		{ 0.5508, 0.6047, 0.5989, 0.7426 },   -- bottom middle: Hall03
		{ 0.5988, 0.6167, 0.6228, 0.7126 },   -- bottom right: Hall03
		{ 0.2674, 0.9281, 0.2755, 0.9402 },   -- bottom left: the ramp's head
		{ 0.2315, 0.9520, 0.2515, 0.9641 },   -- bottom left: the ramp's head
	},
	overlaps = {
		{ 0.4231, 0.1137, 0.5190, 0.3294 },   -- top middle: Hall10, Hall05
		{ 0.5189, 0.1257, 0.5549, 0.3354 },   -- top middle: Hall05, Hall12
		{ 0.5548, 0.1437, 0.5789, 0.3653 },   -- top middle: Hall05, Hall12
		{ 0.5309, 0.3353, 0.5549, 0.3474 },   -- top middle: Hall05, Hall12
		{ 0.5469, 0.3473, 0.5549, 0.3593 },   -- top middle: Hall05, Hall12
		{ 0.5668, 0.3652, 0.5749, 0.3713 },   -- middle: the rounding's margin
		{ 0.2914, 0.5209, 0.6028, 0.9042 },   -- bottom middle: Hall08, Hall09
		{ 0.2794, 0.9041, 0.3034, 0.9162 },   -- bottom left: the ramp below the mark
		{ 0.2674, 0.9161, 0.3034, 0.9521 },   -- bottom left: the ramp below the mark
		{ 0.2554, 0.9281, 0.2675, 0.9402 },   -- bottom left: the ramp below the mark
		{ 0.2435, 0.9401, 0.2675, 0.9521 },   -- bottom left: the ramp below the mark
		{ 0.2355, 0.9520, 0.2675, 0.9701 },   -- bottom left: the ramp below the mark
	},
	links = {
		{ x = 0.5513, y = 0.3474, level = 2 },   -- down to Hall05, at the owner's first mark
		{ x = 0.2713, y = 0.9285, level = 2 },   -- down the ramp from Rm02, at the owner's second mark
	},
})

-- The Lower Den, with no way in of its own.
ns.AddSubMap({
	key = "BanethilBarrowDenLower",
	name = "Ban'ethil Barrow Den",
	parentMapID = 1438,
	levels = BANETHIL_LEVELS,
	level = 2,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TeldrassilBanethilBarrowDenLower",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.408428, 0.559729 }, picture = { 0, 0 } },
		{ map = { 0.483062, 0.634378 }, picture = { 1, 1 } },
	},
	areas = BANETHIL_AREAS,
	links = {
		{ x = 0.4653, y = 0.4076, level = 1 },   -- up to Hall12, at the owner's first mark
		{ x = 0.2958, y = 0.7593, level = 1 },   -- up the ramp to Rm02, at the owner's second mark
	},
})

--[[
	Tirisfal Glades' Night Web's Hollow, the cave by Deathknell (retail's map 466, one level;
	Media/Maps/TirisfalNightWebsHollow, made by Dev/maps/TirisfalCaves/make.py, which works out the
	calibration). The picture is Blizzard's drawing as the owner had it edited (2026-10-29): the
	Scarlet Monastery hall's corners, a cobweb border and a spider, so it is signed. Forever's Tirisfal
	Glades is classic's: its region (Dev/AegisMapCheck/Regions.lua) is Classic Era's, and retail's
	rectangle is read on it. The cave is one WMO on Tirisfal's ground (Forever's files are retail's;
	Classic Era's have the same groups and portals, their floors within a yard or two), so the client
	reports a player in it on Tirisfal Glades (1420). Forever's floors land on the drawn floor
	(Dev/maps/TirisfalCaves, which reads Forever's own model of the cave): within 1 yard for 92% of
	them, 3 yards for all but a sliver, the shift that fits best none. Inside it reads its own name,
	and so do its mouth outside the door, the WMO's outdoor part, and the ground out to 26 yards and
	more (the owner's readings, Classic Era, 2026-10-29): the picture shows only indoors (indoors =
	true), from the door in. On the owner's walk every dot was on the floor walked, and on the drawn
	floor or on the steps, wall line or walkway drawn beside it, 1.2 yards off at most. The way in is
	the door (WMO portal 12), where the owner's minimap turned walking in: seven turns within 0.0001
	of it, a quarter of a yard outside the doorway, half a yard from the portal's centre.
]]
ns.AddSubMap({
	key = "NightWebsHollow",
	name = "Night Web's Hollow",
	parentMapID = 1420,
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TirisfalNightWebsHollow",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1420, x = 0.2671, y = 0.5946 },
	calibration = {
		{ map = { 0.224251, 0.569018 }, picture = { 0, 0 } },
		{ map = { 0.272937, 0.617704 }, picture = { 1, 1 } },
	},
	areas = { ["Night Web's Hollow"] = true },
})
