local _, ns = ...

--[[
	Old Ironforge, the level beneath Ironforge where the Hall of Thanes has its portal. It is
	not instanced, and the client has no map of it: it reports a player down there on the
	Ironforge map itself. So the Ironforge map shows an entrance (a building's, the delve icon)
	where the way down is, and the dungeon's own icon above its portal; and when the player is
	below, the world map shows our picture of Old Ironforge instead, with the portal and the
	player on it.

	way          the entrance on the Ironforge map
	icon         "building": its way in shows retail's delve entrance, not the cave's
	calibration  two spots, each as read in game with /aegis where (map) and on the
	             picture (picture): the first, taken as the arrival at the bottom of the way
	             down though it lies by the top of it on the 2026-11-05 readings, and the portal
	areas        what the client calls the area down there. The owner's readings on the live
	             client (/aegis where, map 1455), 2026-11-05: the bottom of the way down (42.5, 46.7),
	             the middle of Old Ironforge (34.3, 50.0) and the spot by the Hall of Thanes' portal
	             (27.9, 47.9) all read "Ironforge"; the top of the way down, where the picture
	             starts (46.2, 58.1), reads "The High Seat"; the street outside the bank above
	             (34.4, 61.9), inside the picture's rectangle, reads "Vault of Ironforge".
	             2026-11-06: a street hallway of the city above (33.5, 50.7) reads "Ironforge" with
	             "height 0.0", right over the middle of Old Ironforge: the same name on the same spot,
	             and Forever gives addons no height to tell them apart; the top of the way down,
	             where the owner wants the picture to start, reads "The High Seat" again (46.1, 58.3).
	             Forever's own model of the city names about a third of the streets inside the
	             picture's rectangle "Ironforge" too (the spot outside the bank where the picture
	             showed by itself, 30.1, 61.6, live 0.39.2, among them). So neither the name nor
	             the spot tells below from above: being below is remembered, from how the player
	             got there (wayDown)
	             A spot the client names nothing ("", for a moment: no spot in Forever's model of
	             the city has no name) changes nothing (ways.Walked)
	sharedAreas  the way down's name: from the foot of the throne room's stair to the foot of
	             the hall it reads "The High Seat", like the throne room itself
	wayDown      the way down on the picture, as boxes (left, top, right, bottom) as tight as its
	             hall: the foot of the throne room's stair (from 3 yards above the owner's top of
	             the way down; the stair above it, from the throne room, keeps Ironforge's map) and
	             the landing, the hall north, then west down to its foot, and about 10 yards of Old
	             Ironforge's floor past it. "The High Seat" in them shows the picture; "Ironforge"
	             read in them right after it means the player walked down, and being below is then
	             remembered for the character (through a /reload and the next session). No street
	             named "Ironforge" or nothing lies in them at any height in Forever's model of the
	             city, nor any doorway of the throne room onto one, so a walk from the throne room
	             into a street never counts as going down. Being below ends where the area reads
	             anything else (The High Seat outside the way down, a street, the bank) and when the
	             player leaves Ironforge; coming out of the Hall of Thanes at its portal (exits) puts
	             them below again. The rule is ways.Walked in UI/DungeonMap.lua
	wayOver      where the throne room lies over the way down, in the same name (its stair over the
	             hall's side, its passage to The Great Forge over the hall's foot): "The High Seat"
	             there tells nothing new, and the player is still what they were seen last, on the
	             way down or in the throne room
	exits        for each dungeon, where a player coming out of it stands: boxes around its portal.
	             The Hall of Thanes': 10 yards round the portal's reading (27.9, 47.9), less the
	             street named "Ironforge" 3 yards south of it on the flat map (40 yards up in Forever's
	             model), so a summons out of the dungeon onto that street is not taken for below
	instances    where each dungeon's portal is on the picture (a list of points for a dungeon
	             with several doors on it)
]]

ns.AddSubMap({
	key = "OldIronforge",
	name = "Old Ironforge",
	parentMapID = 1455,
	icon = "building",
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\OldIronforge",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { x = 0.435, y = 0.52 },
	calibration = {
		{ map = { 0.4599, 0.5935 }, picture = { 0.765, 0.88 } },
		{ map = { 0.2815, 0.4775 }, picture = { 0.21, 0.52 } },
	},
	areas = { ["Ironforge"] = true },
	sharedAreas = { ["The High Seat"] = true },
	wayDown = {
		{ 0.74, 0.825, 0.84, 0.93 },  -- the foot of the throne room's stair, the landing, the hall's top
		{ 0.81, 0.628, 0.85, 0.825 }, -- the hall north, beside the stair
		{ 0.795, 0.545, 0.85, 0.628 }, -- the hall at its turn west
		{ 0.70, 0.455, 0.85, 0.56 },  -- the hall west, down to the throne room's passage
		{ 0.62, 0.455, 0.70, 0.49 },  -- the hall's foot and Old Ironforge's floor past it
	},
	wayOver = {
		{ 0.785, 0.628, 0.81, 0.825 }, -- the throne room's stair over the hall's side
		{ 0.62, 0.49, 0.70, 0.56 },   -- its passage to The Great Forge over the hall's foot
	},
	exits = { HallOfThanes = {
		{ 0.17, 0.46, 0.25, 0.54 },   -- round the portal, north of the street above
		{ 0.225, 0.54, 0.25, 0.58 },  -- south of it, east of the street
	} },
	instances = { HallOfThanes = { x = 0.21, y = 0.52 } },
})

-- The Hall of Thanes's icon on the Ironforge map stands over its portal, and says the way
-- in is through Old Ironforge.
if ns.GetInstance("HallOfThanes") then
	ns.AmendInstance("HallOfThanes", {
		zoneEntrance = { mapID = 1455, x = 0.2815, y = 0.4775 },
		via = "OldIronforge",
	})
end

--[[
	The Defias Hideout, the mine beneath Moonbrook that leads to the Deadmines. The client has
	no map of it, nor of the Moonbrook house the way down starts in: it reports a player there
	on the Eastern Kingdoms map itself (1415), while the streets above are on Westfall's (1436).
	So the way down is the house's door, read on Westfall, and the picture is placed on the
	continent (the picture, Media/Maps/DeadminesApproach, is the user's, Blizzard's map art).

	calibration  the picture's corners on the continent (2026-11-07, Dev/maps/DeadminesApproachFit).
	             The mine and the hideout above it are one model, placed the same in Forever's client
	             as in retail's, from the same files. Retail's own map of this picture lays it over
	             that model as a rectangle of 450 x 300 yards (the picture's 1.5 : 1), its top left at
	             world (X -11055, Y 1792.5); Forever's own rectangle for the continent's map carries
	             it onto map 1415. Forever's floor drawn through it lies on the drawn cave, within
	             about a yard of its walls by eye. The owner's readings land where they should: the
	             start of the cave (41.25, 79.19) where the hideout's tunnel meets the drawn top room,
	             the portal (40.69, 79.58) on the swirl, about 3 yards east of its middle, and the
	             hideout (41.12, 79.02) just above the top room, over the way down the picture does
	             not draw (the client names that part "Defias Hideout", all the picture draws "The
	             Deadmines"). The two spots used before, the portal and an estimated way in, made the
	             picture's aspect 10 to 15 % off, and the arrow drifted off the cave.
]]
ns.AddSubMap({
	key = "DeadminesApproach",
	name = "Defias Hideout",
	parentMapID = 1415,
	icon = "building",
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DeadminesApproach",
	artRight = 1000 / 1024,
	artBottom = 667 / 1024,
	way = { mapID = 1436, x = 0.4254, y = 0.7176 },
	calibration = {
		{ map = { 0.403623, 0.789275 }, picture = { 0, 0 } },
		{ map = { 0.416407, 0.802059 }, picture = { 1, 1 } },
	},
	areas = { ["Defias Hideout"] = true, ["The Deadmines"] = true },
	instances = { TheDeadmines = { x = 0.248, y = 0.5097 } },
})

if ns.GetInstance("TheDeadmines") then
	ns.AmendInstance("TheDeadmines", {
		zoneEntrance = { mapID = 1415, x = 0.4069, y = 0.7958 },
		via = "DeadminesApproach",
	})
end

--[[
	The Deeprun Tram's station room (the picture, Media/Maps/DeeprunTram, is the user's,
	Blizzard's map art). The client gives no map and no position anywhere in the tram:
	/aegis where reads map nil at both its Stormwind and its Ironforge end. So the picture is
	known by the zone's name instead, and shows without the player's arrow; and since the two
	stations are alike and cannot be told apart, it serves both.

	zones      the zone names that mean the player is inside
	enteredBy  the kind of transport whose icons on the city maps lead into it: a left click
	           on any tram icon shows this map
]]
ns.AddSubMap({
	key = "DeeprunTram",
	name = "Deeprun Tram",
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DeeprunTram",
	artRight = 1000 / 1024,
	artBottom = 667 / 1024,
	zones = { ["Deeprun Tram"] = true },
	enteredBy = "tram",
})

--[[
	The Wailing Caverns' cave, below the Barrens, on Blizzard's own drawn map of it: the client's
	tiles (retail's microdungeon map 11, the same files and the same cave in Forever's client), so
	nothing is shipped. Where the picture lies was worked out from the game's data: its corners are
	retail's map region for it, read on the continent and on the Barrens. The cave's area is not
	under the Barrens, so the client is expected to report a player in it on Kalimdor (1414), as it
	reports the Defias Hideout on the Eastern Kingdoms; it is set up on the Barrens (1413) too, in
	case it says that instead. Its rooms read "The Wailing Caverns", the pool's "Cavern of Mists".
	The way in is the cave's mouth in the ravine; the portal, the picture's swirl.
]]
local WAILING_TILES = "Interface\\WorldMap\\MicroDungeon\\Barrens\\WailingCavernsBarrens\\WailingCavernsBarrens20_"
local WAILING_AREAS = { ["The Wailing Caverns"] = true, ["Cavern of Mists"] = true, ["Wailing Caverns"] = true }
local WAILING_PORTAL = { WailingCaverns = { x = 0.548, y = 0.669 } }

ns.AddSubMap({
	key = "WailingCavernsApproach",
	name = "Wailing Caverns",
	parentMapID = 1414,
	tiles = WAILING_TILES,
	way = { mapID = 1413, x = 0.4597, y = 0.3625 },
	calibration = {
		{ map = { 0.515467, 0.541711 }, picture = { 0, 0 } },
		{ map = { 0.530957, 0.557200 }, picture = { 1, 1 } },
	},
	areas = WAILING_AREAS,
	instances = WAILING_PORTAL,
})

-- The same cave, should the client report it on the Barrens; its way in is the one above.
ns.AddSubMap({
	key = "WailingCavernsApproachBarrens",
	name = "Wailing Caverns",
	parentMapID = 1413,
	tiles = WAILING_TILES,
	calibration = {
		{ map = { 0.446587, 0.311193 }, picture = { 0, 0 } },
		{ map = { 0.502837, 0.367438 }, picture = { 1, 1 } },
	},
	areas = WAILING_AREAS,
	instances = WAILING_PORTAL,
})

if ns.GetInstance("WailingCaverns") then
	ns.AmendInstance("WailingCaverns", {
		zoneEntrance = { mapID = 1414, x = 0.5239, y = 0.5525 },
		via = "WailingCavernsApproach",
	})
end

--[[
	Blackfathom Deeps' way in on the Zoram Strand: the sunken temple's court, the well with its ledges
	going down round it, and the flooded caves under the hill to the dungeon's portal. The picture
	(Media/Maps/BlackfathomApproach) is our own map of it, drawn in Blizzard's style from Forever's
	model of the place, with the whole Blackfathom map's title scroll, the Scarlet Monastery hall's
	gold corners and Torchlite's signature (Dev/maps/BlackfathomApproach builds it; LICENSE-MAPS.md).
	It is north up at 2 pixels a yard, its corners the world's (4372.5, 1018.5) and (4038.5, 517.5),
	read on the continent and on Ashenvale. The court and the caves are one building of the game's. In
	Classic Era its area is 2797, "Blackfathom Deeps", under Ashenvale, and the client reported
	Ashenvale (1440) all the way in, from the court to the last room (the owner's walk, 2026-10-28,
	readings 503-525; the owner found the picture lined up there). Forever names the building area
	719, the dungeon's own, under no zone, so Forever is expected to report a player in it on Kalimdor
	(1414), as at Gnomeregan's way in and Maraudon's caves: it is set up on both, as the Wailing
	Caverns are, until the owner reads it in Forever. The court is the building's one outdoor part and
	reads "Blackfathom Deeps" as well, the sand round it "The Zoram Strand", so the picture shows only
	indoors (indoors = true), from the ledges' head down: the owner's minimap turned there, between
	(4130.5, 865.5) out and (4130.7, 866.1) and (4131.2, 867.7) in (readings 512, 511 and 515), while
	the top of the ledges a step back still read outdoors. After a loading screen in there Classic Era
	reported Kalimdor for a moment (readings 530, 712 and 714, the owner's later readings in
	Dev/maps/BlackfathomApproach/research), and logging in by the portal it named nothing for 2
	seconds (714): so on Kalimdor's map a spot named nothing counts too, indoors (the ground under the
	picture outside the building, the sand, is Ashenvale's); on Ashenvale's map such a spot is
	Ashenvale's own ground. Out of the portal the dungeon's room inside (The Pool of Ask'ar, 530) is
	still named for a moment, under a second: the picture comes with the next name. Indoors is Classic
	Era's reading: Forever's rows for the court and the well's bottom (the building's groups 319 and
	320) carry the flag servers read as outdoors (0x4), Classic Era's none, so Forever may call the
	ledges and the pool outdoors, the picture showing only from the tunnel on. To read in Forever
	(from 2026-11-04): the map the client reports in there, and where the minimap turns indoors on the
	ledges and by the pool. The way in, with the cave icon, is on Ashenvale's map, where a player
	outside stands, at the turn walking in (reading 511), the other two within 0.0003 of it. The
	dungeon's door is on the picture at the portal's swirl, 8 yards from Classic Era's portal trigger
	(257). Its icon on Ashenvale's map stands over the same swirl (world 4249.81, 749.6, through
	Forever's region of Ashenvale), 167 yards from the way in, as Uldaman's and the Wailing Caverns'
	stand over theirs, and says the way in is through the caves: its waypoint goes to the way in (the
	owner's decision, 2026-10-29). At the dungeon's own spot (Data/Instances/BlackfathomDeeps.lua),
	4 yards from the way in, the two icons lay one on the other, and only one of them could be
	clicked.
]]
local BLACKFATHOM_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\BlackfathomApproach"
local BLACKFATHOM_PORTAL = { BlackfathomDeeps = { x = 0.5367, y = 0.3673 } }

ns.AddSubMap({
	key = "BlackfathomApproach",
	name = "Blackfathom Deeps",
	parentMapID = 1414,
	-- Shown inside only: the court before the ledges has the same area name.
	indoors = true,
	art = BLACKFATHOM_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1440, x = 0.1446, y = 0.1411 },
	calibration = {
		{ map = { 0.436092, 0.343510 }, picture = { 0, 0 } },
		{ map = { 0.449706, 0.357124 }, picture = { 1, 1 } },
	},
	-- Named nothing too, as a moment after a loading screen in there.
	areas = { [""] = true, ["Blackfathom Deeps"] = true },
	instances = BLACKFATHOM_PORTAL,
})

-- The same way in on Ashenvale, where Classic Era reports it; its way in is the one above. A spot
-- named nothing here is Ashenvale's own ground.
ns.AddSubMap({
	key = "BlackfathomApproachAshenvale",
	name = "Blackfathom Deeps",
	parentMapID = 1440,
	indoors = true,
	art = BLACKFATHOM_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.118179, 0.078157 }, picture = { 0, 0 } },
		{ map = { 0.205058, 0.165051 }, picture = { 1, 1 } },
	},
	areas = { ["Blackfathom Deeps"] = true },
	instances = BLACKFATHOM_PORTAL,
})

if ns.GetInstance("BlackfathomDeeps") then
	ns.AmendInstance("BlackfathomDeeps", {
		zoneEntrance = { mapID = 1440, x = 0.1648, y = 0.1101 },
		via = "BlackfathomApproach",
	})
end

--[[
	Gnomeregan's way in, beneath Dun Morogh: from the gate a ramp and the lift go down to the Train
	Depot's halls; the Loading Room is west of their round hall, the back portal, on the Workshop's
	side, north of it, and the front portal at the end of the long tunnel to the south-west. The
	picture (Media/Maps/GnomereganApproach) is our own map of it, made on Blizzard's drawn map of the
	way in (retail's microdungeon map 30, drawn for retail's newer tunnels): its sheet, frame corners,
	sketches and title scroll, and its drawing of the round hall and the Loading Room, fitted onto
	Forever's model of the tunnels; the rest drawn true to that model in its style, each portal's
	corridor fading into the parchment at map 30's swirl; and Torchlite's signature
	(Dev/maps/GnomereganApproach/composite builds it; LICENSE-MAPS.md). It is north up at 1.55
	pixels a yard, its corners the world's (-4792.28, 1064.11) and (-5223.25, 417.66), read on the
	continent. The tunnels are one building of the game's, every room of it in the dungeon's own
	area (721, "Gnomeregan"), under no zone, so the client reports a player in there on the Eastern
	Kingdoms (1415), as it does the Defias Hideout: in game (Classic Era, the owner's walks of
	2026-10-27 and 28, Dev/maps/GnomereganApproach/testing: readings_2026-10-27.lua, the afternoon's,
	readings_2026-10-27_evening.lua and readings_2026-10-28.lua) it read 1415 from the gate in, and
	Dun Morogh (1426) on the ground before it, which reads "Gnomeregan" too (area 133, under Dun
	Morogh). So there is no copy on Dun Morogh's map. Inside, the rooms read "Gnomeregan", "Train
	Depot" or "Loading Room", and past the back portal's swirl, where the owner did not go, "Workshop
	Entrance" (the game's table of the building's rooms); the gate's hall, the building's one outdoor
	part, reads "Gnomeregan" or nothing. The owner's minimap turned at the gate, at (-5182.7, 611.9), a
	moment before the client named the room (within a second), and after a loading screen in the
	tunnels it named nothing for 2 to 4 seconds (readings 234 and 691). Out of the front portal the
	dungeon's room inside (The Clockwerk Run, reading 38) is still named for a moment, under a second:
	the picture comes with the next name. Until 0.39.20 the picture showed only indoors, Classic Era's
	reading; but Forever's rows for every room of the tunnels carry the flag servers read as outdoors
	(0x4), Classic Era's none, and Forever says outdoors there: the owner's reading in the Train Depot
	(2026-11-11: map 1415 at 0.4338, 0.5336, area and minimap "Train Depot", IsIndoors false), where the
	picture did not show by itself. So it goes by name and place: the rooms' own names (the Train
	Depot, the Loading Room, the Workshop Entrance) anywhere on the picture, indoors or out, and the
	dungeon's name or none (boxedAreas) indoors, as before, or in its box (boxes), the whole picture but its last
	strip east of the continent's x 0.43715, half way between the gate's two readings on the client's
	4 decimals (inside 0.4371, outside 0.4372: world y 612.35, where the minimap turned). So the gate's
	mouth and the ground before it, which the client reported on the continent's map at the gate (the
	owner's "gate outside", 0.4372, 0.539, nothing or "Gnomeregan") and once logging in on the ground
	east of it (reading 274, 0.4418, 0.5393, nothing), show no picture; the ground outside reads Dun
	Morogh's map everywhere else (all the owner's readings there), where the picture is not set up.
	The way in, with a building's icon, is on Dun
	Morogh's map at the gate (the building's mouth, world -5183.45, 606.65), within 2 yards of where
	the client's map turned from Dun Morogh's to the continent's walking in. The dungeon's door is on
	the picture twice, at each portal's swirl: the front one 3 yards from where the owner stood at
	it, the back one past the halls to the north. Its icon on Dun Morogh's map stands over the front
	portal's swirl (world -5162.72, 930.76, through Forever's region of Dun Morogh), 325 yards from
	the gate, as Uldaman's and the Wailing Caverns' stand over theirs, and says the way in is through
	the tunnels: its waypoint goes to the gate (the owner's decision, 2026-10-29). At the dungeon's own
	spot (Data/Instances/Gnomeregan.lua), at the gate, 1.4 yards from the way in, the two icons lay
	one on the other, and only one of them could be clicked.
]]
local GNOMEREGAN_DOORS = {
	-- the front portal's swirl, world (-5162.72, 930.76); the back portal's, world (-4858.40, 776.07)
	Gnomeregan = { { x = 0.2063, y = 0.8596 }, { x = 0.4456, y = 0.1534 } },
}

ns.AddSubMap({
	key = "GnomereganApproach",
	name = "Gnomeregan",
	parentMapID = 1415,
	icon = "building",
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\GnomereganApproach",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1426, x = 0.2427, y = 0.3979 },
	calibration = {
		{ map = { 0.424316, 0.522397 }, picture = { 0, 0 } },
		{ map = { 0.442681, 0.540762 }, picture = { 1, 1 } },
	},
	-- The rooms' own names, anywhere on the picture, indoors or out.
	areas = { ["Train Depot"] = true, ["Loading Room"] = true, ["Workshop Entrance"] = true },
	-- The dungeon's name, and none (as at the minimap's turn at the gate and a moment after a loading screen), indoors,
	-- or in the tunnels: west of the gate's mouth (the continent's x 0.43715).
	boxedAreas = { [""] = true, ["Gnomeregan"] = true },
	boxes = { { 0, 0, (0.43715 - 0.424316) / (0.442681 - 0.424316), 1 } },
	instances = GNOMEREGAN_DOORS,
})

--[[
	Techbot stands in the tunnels, not in the dungeon (his spawn: Dun Morogh, 19.78, 31.93): in the small room west of
	the Train Depot's big oval, where the owner found him (2026-11-11, Dun Morogh's map shown: 19.8, 31.8). His pin is
	there on the way in's picture, at the owner's spot carried by Forever's region of Dun Morogh (world -4921.2, 826.9)
	and the picture's frame; none inside.
]]
if ns.GetInstance("Gnomeregan") then
	ns.AmendInstance("Gnomeregan", {
		zoneEntrance = { mapID = 1426, x = 0.1769, y = 0.3916 },
		via = "GnomereganApproach",
		bosses = { ["Techbot"] = { wayInPin = { subMap = "GnomereganApproach", x = 0.3669, y = 0.2991 } } },
	})
end

--[[
	Razorfen Downs' way in, on the Barrens' border with Thousand Needles, on two pictures of our own,
	drawn in Blizzard's style from Forever's model of the place, each with a climbing bramble border,
	the sketches of a quillboar and of Amnennar, the Scarlet Monastery hall's gold corners and
	Torchlite's signature, as the owner approved them (2026-10-29; Dev/maps/RazorfenDownsApproach/maze
	and closeup build them; LICENSE-MAPS.md): the maze (Media/Maps/RazorfenDownsApproach), the whole
	Razorfen Downs part from the Southern Gold Road to the portal, north up at 0.92 pixels a yard, its
	corners the world's (-4206.0, -1802.4) and (-4932.09, -2891.53); and a close-up
	(Media/Maps/RazorfenDownsSkull) of Agamaggan's skull with its tusks, the plank bridge, the thorn
	vines and the thorn path to the swirl, north up at 2.80 pixels a yard, its corners the world's
	(-4554.68, -2242.82) and (-4793.25, -2600.68) (their frames: research2/plan for the maze,
	research2/switch for the close-up). The ground is the Barrens' subzone Razorfen Downs (area 1316),
	so the client reports a player there on the Barrens (1413); the skull and the path are one building
	of the game's (WMO 1055) whose area is the dungeon's own (722), under no zone, so on its floors the
	client reports Kalimdor (1414), the subzone blank (a blank subzone finds an entry for no name:
	areas[""], 59a8979). On the owner's walk (Classic Era, 2026-10-29, readings 830-870) the map turned
	between the two twelve times, eight of them between readings half a yard to three yards apart, at
	the skull's back door and at its south-east tusk's tip, where its floor meets the ground at one
	height. So the pictures are switched by the player's position, not by the map the client reports,
	and each is set up on both maps.
	The close-up shows as the player steps into the skull and the maze as they step out, at one line on
	the ground round the skull and the path (research2/switch/s2_territory.py): across the mouth, at the
	snout's open front, and round the tusks, the flanks and the back four yards or more out from every
	place where the skull's or the path's floor meets the ground, or a player stepping off them lands
	(under the floor model's three ground rules: 50 degrees, a hop at 60, the first survey's step), so the
	client's map turns only on ground the close-up holds whatever came before. The two pictures are an
	area's two levels (a menu of them, as Fargodeep Mine's, the maze first): the close-up's names count
	first on its own ground (claims, boxes on its picture); round the line a band two to five yards wide
	keeps the picture the player came from (the claims reach one to two and a half yards over the line,
	the overlaps one to two and a half yards in, each edge a staircase of boxes), on every slope a player
	can stand on, the steep ones round the path too, where a player slides; so walking along the line,
	over it slantwise or sliding down a slope across it never turns the map back and forth. The band keeps
	clear of every place where the client's map turns (each four yards or more inside the line, the
	building's own thorns on the steep slopes round the path too, or eight and more outside it), as the
	levels' hold is the entry's, not the level's: a turn there would drop it. The one place it cannot
	is under the thorn canopy's south edge, 26 to 48 yards up the hill, where a player who falls off the canopy lands in the band and sees the maze once.
	The maze has none and shows everywhere else. The map turns 0.4 to 4.9 yards past the line walking in
	(median 2.1), 0.6 to 4.8 walking out (median 2.0), at a run or mounted, where the
	player leaves the band (the staircases, the client's rounding of the position to 4 places, and the
	player followed every 0.2 seconds), and nowhere else (87008 walks on the floor model,
	research2/switch/s7_walks.py). On Kalimdor's map the close-up takes the same claims and no overlaps:
	there the client reports only the building, all of it a player can walk to inside the line. A player
	seen on neither picture (logged in or reloaded) in the band is shown the close-up until they walk out
	of it.
	With the world map open it follows the player from one map to the other as the client's map turns
	(UI/DungeonMap.lua's FollowToMap); where it cannot turn, in combat or on a client that refuses the
	turn, the same picture stays up as placed on the map shown (SamePictureOn), the player's arrow by
	their own entry, so the close-up does not give way to the plain Barrens map at each turn.
	The journal's Show Map for Razorfen Downs opens on the maze with its door pulsing, as Blackrock
	Mountain's dungeons open on their level; a click on the door shows the dungeon's own map. The way in,
	with a building's icon, is on the Barrens' map where the subzone turned to Razorfen Downs as the owner
	stepped off the Southern Gold Road (reading 837); the dungeon's door is at the swirl on both
	pictures, and its icon on the Barrens' map moves there from the hillside the owner could not reach
	(Data/Instances/RazorfenDowns.lua).
	To read in Forever (from 2026-11-04): the map the client reports on the skull and the path (its rows
	carry the flag servers read as outdoors, 0x4), and whether the subzone stays blank at the swirl.
]]
local RFD_LEVELS = { "Razorfen Downs", "Agamaggan's Skull" }
local RFD_AREAS = { ["Razorfen Downs"] = true }
-- On Kalimdor's map the building names nothing (and, in Classic Era, the swirl's doorway Razorfen Downs).
local RFD_WMO_AREAS = { [""] = true, ["Razorfen Downs"] = true }
local RFD_MAZE_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\RazorfenDownsApproach"
local RFD_SKULL_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\RazorfenDownsSkull"
local RFD_MAZE_DOOR = { RazorfenDowns = { x = 0.6686, y = 0.6268 } }     -- the swirl, world (-4661.12, -2530.59)
local RFD_SKULL_DOOR = { RazorfenDowns = { x = 0.8041, y = 0.4462 } }    -- the swirl
-- The close-up's claims: the skull and its tusks, the path, the ground under and round them inside the line,
-- and one to two and a half yards over it (research2/switch/s4_claims.py, which checks them on every node of
-- the floor model with the client's rounding).
local RFD_SKULL_CLAIMS = {
	{ 0.4550, 0.1796, 0.4771, 0.6557 },   -- middle: the plank bridge
	{ 0.4451, 0.1826, 0.4791, 0.1857 },   -- top middle: the band by the path's north bank
	{ 0.4411, 0.1856, 0.4851, 0.1917 },   -- top middle: the band by the path's north bank
	{ 0.4371, 0.1916, 0.4931, 0.2006 },   -- top middle: the band by the path's north bank
	{ 0.4770, 0.1976, 0.4971, 0.6108 },   -- middle: the plank bridge, the path's north bank
	{ 0.4351, 0.2005, 0.5010, 0.2396 },   -- top middle: the path's north bank
	{ 0.4091, 0.2095, 0.4212, 0.2126 },   -- top middle: the band by the path's north bank
	{ 0.4011, 0.2125, 0.5030, 0.2306 },   -- top middle: the path's north bank
	{ 0.6227, 0.2155, 0.6328, 0.5629 },   -- middle: the causeway
	{ 0.3892, 0.2185, 0.4012, 0.6827 },   -- middle: WMO portal 2
	{ 0.6327, 0.2185, 0.6408, 0.5659 },   -- middle: the causeway
	{ 0.6546, 0.2185, 0.6627, 0.5480 },   -- middle: the causeway
	{ 0.6147, 0.2215, 0.6667, 0.5420 },   -- middle: the causeway
	{ 0.3493, 0.2245, 0.3733, 0.2276 },   -- top middle: the band by the path's north bank
	{ 0.3852, 0.2245, 0.4072, 0.6797 },   -- middle: WMO portal 2
	{ 0.6107, 0.2245, 0.6148, 0.6018 },   -- middle: the causeway
	{ 0.3453, 0.2275, 0.3773, 0.2306 },   -- top middle: the band by the path's north bank
	{ 0.6087, 0.2275, 0.6707, 0.5390 },   -- middle: the causeway
	{ 0.3413, 0.2305, 0.4352, 0.2396 },   -- top middle: the band by the path's north bank
	{ 0.5968, 0.2335, 0.6767, 0.5270 },   -- middle: the causeway
	{ 0.3393, 0.2395, 0.5030, 0.2486 },   -- top middle: the path's north bank
	{ 0.5888, 0.2395, 0.6827, 0.2456 },   -- top middle: the band by the causeway
	{ 0.4930, 0.2425, 0.5090, 0.6617 },   -- middle: the plank bridge
	{ 0.5808, 0.2425, 0.6028, 0.6138 },   -- middle: the causeway
	{ 0.4910, 0.2455, 0.5130, 0.6557 },   -- middle: the plank bridge
	{ 0.5389, 0.2455, 0.5490, 0.2486 },   -- top middle: the band by the path's north bank
	{ 0.5728, 0.2455, 0.6867, 0.5150 },   -- middle: the causeway
	{ 0.3373, 0.2485, 0.5210, 0.5869 },   -- middle: the back door (E1), WMO portal 2, the plank bridge
	{ 0.5329, 0.2485, 0.5549, 0.6288 },   -- middle: the path's south bank
	{ 0.5628, 0.2485, 0.6887, 0.2605 },   -- top middle: the causeway
	{ 0.4530, 0.2514, 0.6208, 0.5899 },   -- middle: the plank bridge, the path's south bank
	{ 0.6866, 0.2604, 0.6907, 0.2665 },   -- top right: the band by the causeway
	{ 0.3353, 0.2664, 0.6967, 0.3294 },   -- top middle: the path's north bank
	{ 0.6966, 0.2694, 0.7006, 0.2755 },   -- top right: the band by the causeway
	{ 0.6966, 0.2754, 0.7046, 0.2875 },   -- top right: the band by the causeway
	{ 0.7045, 0.2844, 0.7066, 0.2875 },   -- top right: the band by the causeway
	{ 0.6966, 0.2874, 0.7106, 0.3084 },   -- top right: the band by the causeway
	{ 0.7105, 0.2964, 0.7226, 0.3084 },   -- top right: the band by the causeway
	{ 0.7225, 0.3023, 0.7306, 0.3084 },   -- top right: the band by the causeway
	{ 0.6966, 0.3083, 0.7326, 0.3294 },   -- top right: the causeway
	{ 0.7085, 0.3173, 0.7366, 0.5150 },   -- middle right: the causeway
	{ 0.3313, 0.3293, 0.7386, 0.3563 },   -- middle: the path's north bank
	{ 0.7165, 0.3413, 0.7426, 0.5390 },   -- middle right: the causeway
	{ 0.7425, 0.3473, 0.7486, 0.3533 },   -- middle right: the band by the causeway
	{ 0.3293, 0.3502, 0.3613, 0.6947 },   -- middle: the south-east flank, the back door (E1)
	{ 0.7345, 0.3532, 0.7545, 0.5569 },   -- middle right: the swirl
	{ 0.3273, 0.3562, 0.7565, 0.4911 },   -- middle: WMO portal 2, the plank bridge, the causeway
	{ 0.7544, 0.3622, 0.7625, 0.5539 },   -- middle right: the swirl
	{ 0.7305, 0.3682, 0.7645, 0.5509 },   -- middle right: the swirl
	{ 0.3253, 0.3712, 0.3553, 0.7006 },   -- middle: the south-east flank, the back door (E1)
	{ 0.7265, 0.3712, 0.7685, 0.5480 },   -- middle right: the swirl
	{ 0.7205, 0.3742, 0.7745, 0.5450 },   -- middle right: the swirl
	{ 0.3193, 0.3772, 0.3334, 0.8384 },   -- middle left: the south-east tusk's tip (E4)
	{ 0.7744, 0.3802, 0.7765, 0.5390 },   -- middle right: the swirl
	{ 0.7105, 0.3832, 0.7845, 0.5300 },   -- middle right: the swirl
	{ 0.3173, 0.3862, 0.3374, 0.8354 },   -- middle left: the south-east tusk's tip (E4)
	{ 0.7844, 0.3892, 0.7865, 0.5240 },   -- middle right: the swirl
	{ 0.7864, 0.3892, 0.7885, 0.4911 },   -- middle right: the swirl
	{ 0.3133, 0.3922, 0.7925, 0.4851 },   -- middle: WMO portal 2, the plank bridge
	{ 0.7924, 0.3952, 0.7985, 0.4821 },   -- middle right: the swirl
	{ 0.7984, 0.4011, 0.8064, 0.4851 },   -- middle right: the swirl
	{ 0.8063, 0.4071, 0.8104, 0.4821 },   -- middle right: the swirl
	{ 0.3113, 0.4101, 0.8184, 0.4731 },   -- middle: WMO portal 2, the plank bridge, the swirl
	{ 0.8183, 0.4161, 0.8224, 0.4641 },   -- middle right: the band by the swirl
	{ 0.8223, 0.4221, 0.8264, 0.4521 },   -- middle right: the band by the swirl
	{ 0.3093, 0.4251, 0.8284, 0.4432 },   -- middle: the plank bridge
	{ 0.3053, 0.4341, 0.8144, 0.4791 },   -- middle: WMO portal 2, the plank bridge, the swirl
	{ 0.3013, 0.4431, 0.3074, 0.7935 },   -- middle left: the ground under the skull
	{ 0.2415, 0.4670, 0.2615, 0.4731 },   -- middle left: the band by the skull's top from the hill
	{ 0.2395, 0.4730, 0.2635, 0.5270 },   -- middle left: the band by the skull's top from the hill
	{ 0.2874, 0.4730, 0.2955, 0.7635 },   -- middle left: the north-west flank (E5), the skull's top from the hill
	{ 0.2954, 0.4730, 0.3394, 0.7815 },   -- middle left: the ground under the skull
	{ 0.2754, 0.4760, 0.2875, 0.7575 },   -- middle left: the north-west flank (E5)
	{ 0.2355, 0.4790, 0.6807, 0.5240 },   -- middle: the plank bridge
	{ 0.2315, 0.4880, 0.2356, 0.5180 },   -- middle left: the band by the skull's top from the hill
	{ 0.2295, 0.4910, 0.7885, 0.5120 },   -- middle: the plank bridge
	{ 0.2475, 0.5239, 0.6747, 0.5330 },   -- middle: the plank bridge
	{ 0.7145, 0.5299, 0.7805, 0.5360 },   -- middle right: the band by the swirl
	{ 0.2694, 0.5329, 0.6587, 0.5539 },   -- middle: the back door (E1)
	{ 0.2674, 0.5538, 0.2755, 0.7515 },   -- middle left: the north-west flank (E5)
	{ 0.6207, 0.5538, 0.6507, 0.5599 },   -- middle: the band by the path's south bank
	{ 0.2574, 0.5598, 0.2675, 0.7426 },   -- middle left: the mouth
	{ 0.6207, 0.5598, 0.6228, 0.5629 },   -- middle: the band by the path's south bank
	{ 0.2495, 0.5628, 0.2575, 0.7366 },   -- middle left: the north-west tusk
	{ 0.2475, 0.5688, 0.3793, 0.6617 },   -- middle left: the north-west flank (E5), the south-east flank, the ground under the skull
	{ 0.2455, 0.5718, 0.2476, 0.5749 },   -- middle left: the band by the north-west tusk
	{ 0.2415, 0.5748, 0.2476, 0.5839 },   -- middle left: the band by the north-west tusk
	{ 0.2375, 0.5808, 0.2416, 0.5839 },   -- middle left: the band by the north-west tusk
	{ 0.2335, 0.5838, 0.4092, 0.6587 },   -- middle left: the north-west flank (E5), the ground under the skull
	{ 0.5129, 0.5898, 0.6108, 0.6048 },   -- middle: the path's south bank
	{ 0.6147, 0.5898, 0.6188, 0.5959 },   -- middle: the band by the path's south bank
	{ 0.2295, 0.5928, 0.2336, 0.6048 },   -- middle left: the band by the north-west tusk
	{ 0.2255, 0.5988, 0.2296, 0.6048 },   -- middle left: the band by the north-west tusk
	{ 0.2235, 0.6047, 0.2336, 0.6677 },   -- middle left: the band by the north-west tusk
	{ 0.5189, 0.6047, 0.6088, 0.6108 },   -- middle: the band by the path's south bank
	{ 0.2195, 0.6107, 0.2396, 0.6647 },   -- middle left: the band by the north-west tusk
	{ 0.4510, 0.6107, 0.4911, 0.6198 },   -- middle: the path's south bank
	{ 0.5249, 0.6107, 0.5989, 0.6168 },   -- middle: the band by the path's south bank
	{ 0.5269, 0.6167, 0.5689, 0.6228 },   -- middle: the band by the path's south bank
	{ 0.5748, 0.6167, 0.5949, 0.6228 },   -- middle: the band by the path's south bank
	{ 0.2175, 0.6197, 0.2196, 0.6587 },   -- middle left: the band by the north-west tusk
	{ 0.4510, 0.6197, 0.5150, 0.6527 },   -- middle: the band by the path's south bank
	{ 0.2135, 0.6227, 0.2176, 0.6557 },   -- middle left: the band by the north-west tusk
	{ 0.5309, 0.6227, 0.5609, 0.6258 },   -- middle: the band by the path's south bank
	{ 0.4491, 0.6257, 0.4511, 0.6438 },   -- middle: the band by the hill south of the skull
	{ 0.2115, 0.6317, 0.4112, 0.6498 },   -- middle left: the north-west tusk
	{ 0.3792, 0.6497, 0.4112, 0.6737 },   -- middle: the band by the south-east flank
	{ 0.3612, 0.6616, 0.3653, 0.6857 },   -- bottom middle: the band by the south-east flank
	{ 0.3732, 0.6616, 0.3793, 0.6677 },   -- middle: the band by the south-east flank
	{ 0.2475, 0.6706, 0.2496, 0.6737 },   -- bottom left: the band by the north-west tusk
	{ 0.2435, 0.6736, 0.2496, 0.7306 },   -- bottom left: the band by the mouth
	{ 0.2395, 0.6766, 0.3414, 0.7246 },   -- bottom left: the mouth
	{ 0.2375, 0.6796, 0.2396, 0.7156 },   -- bottom left: the band by the mouth
	{ 0.2335, 0.6826, 0.3434, 0.7126 },   -- bottom left: the mouth
	{ 0.2634, 0.7425, 0.2675, 0.7486 },   -- bottom left: the band by the mouth
	{ 0.3133, 0.7634, 0.3414, 0.8324 },   -- bottom left: the south-east tusk's tip (E4)
	{ 0.3093, 0.7784, 0.3434, 0.8264 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.2974, 0.7814, 0.3014, 0.7875 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.3073, 0.7814, 0.3454, 0.8174 },   -- bottom left: the band by the south-east tusk's tip (E4)
}
-- Its overlaps: the band round the line where a player can stand, one to two and a half yards in from it, cut
-- back where the building's thorns meet the slopes round the path, and the claims over it.
local RFD_SKULL_OVERLAPS = {
	{ 0.4371, 0.1796, 0.4631, 0.1947 },   -- top middle: the band by the path's north bank
	{ 0.4630, 0.1796, 0.4771, 0.1917 },   -- top middle: the band by the path's north bank
	{ 0.4770, 0.1796, 0.4891, 0.1977 },   -- top middle: the band by the path's north bank
	{ 0.4890, 0.1916, 0.4971, 0.2066 },   -- top middle: the band by the path's north bank
	{ 0.4091, 0.1946, 0.4432, 0.2156 },   -- top middle: the band by the path's north bank
	{ 0.4431, 0.1946, 0.4452, 0.1977 },   -- top middle: the band by the path's north bank
	{ 0.4850, 0.1976, 0.4891, 0.2036 },   -- top middle: the band by the path's north bank
	{ 0.4970, 0.1976, 0.5929, 0.2515 },   -- top middle: the band by the path's north bank
	{ 0.4930, 0.2065, 0.4971, 0.2156 },   -- top middle: the band by the path's north bank
	{ 0.3892, 0.2125, 0.4092, 0.2246 },   -- top middle: the band by the path's north bank
	{ 0.4091, 0.2155, 0.4392, 0.2216 },   -- top middle: the band by the path's north bank
	{ 0.6147, 0.2155, 0.6308, 0.2306 },   -- top middle: the band by the causeway
	{ 0.6307, 0.2155, 0.6368, 0.2276 },   -- top middle: the band by the causeway
	{ 0.4930, 0.2185, 0.6148, 0.2426 },   -- top middle: the band by the path's north bank
	{ 0.6367, 0.2185, 0.6647, 0.2336 },   -- top middle: the band by the causeway
	{ 0.4231, 0.2215, 0.4372, 0.2246 },   -- top middle: the band by the path's north bank
	{ 0.6646, 0.2215, 0.6847, 0.2426 },   -- top right: the band by the causeway
	{ 0.3473, 0.2245, 0.3973, 0.2336 },   -- top middle: the band by the path's north bank
	{ 0.3972, 0.2245, 0.4032, 0.2276 },   -- top middle: the band by the path's north bank
	{ 0.4291, 0.2245, 0.4312, 0.2276 },   -- top middle: the band by the path's north bank
	{ 0.3373, 0.2275, 0.3474, 0.2605 },   -- top middle: the band by WMO portal 2
	{ 0.6147, 0.2305, 0.6188, 0.2366 },   -- top middle: the band by the causeway
	{ 0.3473, 0.2335, 0.3913, 0.2366 },   -- top middle: the band by the path's north bank
	{ 0.3732, 0.2365, 0.3893, 0.2426 },   -- top middle: the band by the path's north bank
	{ 0.4950, 0.2425, 0.6088, 0.2486 },   -- top middle: the band by the path's north bank
	{ 0.6087, 0.2425, 0.6108, 0.2456 },   -- top middle: the band by the causeway
	{ 0.6686, 0.2425, 0.6707, 0.2456 },   -- top right: the band by the causeway
	{ 0.6706, 0.2425, 0.6787, 0.2486 },   -- top right: the band by the causeway
	{ 0.6786, 0.2425, 0.6867, 0.2545 },   -- top right: the band by the causeway
	{ 0.6866, 0.2455, 0.7026, 0.2755 },   -- top right: the band by the causeway
	{ 0.5049, 0.2514, 0.5849, 0.2575 },   -- top middle: the band by the path's north bank
	{ 0.6826, 0.2544, 0.6867, 0.2695 },   -- top right: the band by the causeway
	{ 0.5169, 0.2574, 0.5370, 0.2605 },   -- top middle: the band by the path's north bank
	{ 0.5489, 0.2574, 0.5669, 0.2635 },   -- top middle: the band by the path's north bank
	{ 0.3353, 0.2604, 0.3414, 0.3384 },   -- top middle: the band by WMO portal 2
	{ 0.3413, 0.2604, 0.3434, 0.3264 },   -- top middle: the band by WMO portal 2
	{ 0.5229, 0.2604, 0.5330, 0.2665 },   -- top middle: the band by the path's north bank
	{ 0.5329, 0.2604, 0.5350, 0.2635 },   -- top middle: the band by the path's north bank
	{ 0.6926, 0.2754, 0.6947, 0.2785 },   -- top right: the band by the causeway
	{ 0.6946, 0.2754, 0.7066, 0.2845 },   -- top right: the band by the causeway
	{ 0.6986, 0.2844, 0.7046, 0.2875 },   -- top right: the band by the causeway
	{ 0.7045, 0.2844, 0.7066, 0.2995 },   -- top right: the band by the causeway
	{ 0.7065, 0.2844, 0.7226, 0.3054 },   -- top right: the band by the causeway
	{ 0.7005, 0.2874, 0.7046, 0.2965 },   -- top right: the band by the causeway
	{ 0.7225, 0.2964, 0.7346, 0.3144 },   -- top right: the band by the causeway
	{ 0.7105, 0.3053, 0.7226, 0.3114 },   -- top right: the band by the causeway
	{ 0.7265, 0.3143, 0.7286, 0.3204 },   -- top right: the band by the causeway
	{ 0.7285, 0.3143, 0.7386, 0.3354 },   -- top right: the band by the causeway
	{ 0.3253, 0.3293, 0.3354, 0.3743 },   -- middle left: the band by WMO portal 2
	{ 0.7385, 0.3293, 0.7565, 0.3563 },   -- middle right: the band by the causeway
	{ 0.7305, 0.3353, 0.7346, 0.3444 },   -- middle right: the band by the causeway
	{ 0.7345, 0.3353, 0.7386, 0.3533 },   -- middle right: the band by the causeway
	{ 0.3353, 0.3383, 0.3374, 0.3563 },   -- middle: the band by WMO portal 2
	{ 0.3373, 0.3383, 0.3394, 0.3444 },   -- middle: the band by WMO portal 2
	{ 0.7425, 0.3562, 0.7486, 0.3623 },   -- middle right: the band by the causeway
	{ 0.7485, 0.3562, 0.7585, 0.3683 },   -- middle right: the band by the swirl
	{ 0.7584, 0.3622, 0.7765, 0.3803 },   -- middle right: the band by the swirl
	{ 0.7544, 0.3682, 0.7585, 0.3743 },   -- middle right: the band by the swirl
	{ 0.3233, 0.3742, 0.3294, 0.3893 },   -- middle left: the band by WMO portal 2
	{ 0.3293, 0.3742, 0.3334, 0.3833 },   -- middle left: the band by WMO portal 2
	{ 0.3133, 0.3772, 0.3234, 0.4042 },   -- middle left: the band by WMO portal 2
	{ 0.7644, 0.3802, 0.7725, 0.3863 },   -- middle right: the band by the swirl
	{ 0.7724, 0.3802, 0.7765, 0.3923 },   -- middle right: the band by the swirl
	{ 0.7764, 0.3802, 0.7945, 0.3953 },   -- middle right: the band by the swirl
	{ 0.7824, 0.3952, 0.7905, 0.4012 },   -- middle right: the band by the swirl
	{ 0.7904, 0.3952, 0.8024, 0.4072 },   -- middle right: the band by the swirl
	{ 0.8023, 0.4011, 0.8204, 0.4162 },   -- middle right: the band by the swirl
	{ 0.3133, 0.4041, 0.3214, 0.4162 },   -- middle left: the band by WMO portal 2
	{ 0.7964, 0.4071, 0.8024, 0.4132 },   -- middle right: the band by the swirl
	{ 0.3013, 0.4101, 0.3134, 0.4462 },   -- middle left: the band by WMO portal 2
	{ 0.3133, 0.4161, 0.3174, 0.4402 },   -- middle left: the band by WMO portal 2
	{ 0.8083, 0.4161, 0.8164, 0.4222 },   -- middle right: the band by the swirl
	{ 0.8163, 0.4161, 0.8304, 0.4282 },   -- middle right: the band by the swirl
	{ 0.8203, 0.4281, 0.8304, 0.4462 },   -- middle right: the band by the swirl
	{ 0.2435, 0.4461, 0.3074, 0.4791 },   -- middle left: the band by the skull's top from the hill
	{ 0.3073, 0.4461, 0.3094, 0.4731 },   -- middle left: the band by WMO portal 2
	{ 0.8163, 0.4461, 0.8284, 0.4641 },   -- middle right: the band by the swirl
	{ 0.8123, 0.4550, 0.8164, 0.4641 },   -- middle right: the band by the swirl
	{ 0.8083, 0.4640, 0.8244, 0.4761 },   -- middle right: the band by the swirl
	{ 0.2315, 0.4670, 0.2436, 0.4911 },   -- middle left: the band by the skull's top from the hill
	{ 0.7864, 0.4700, 0.8084, 0.4761 },   -- middle right: the band by the swirl
	{ 0.7824, 0.4760, 0.8164, 0.5330 },   -- middle right: the band by the swirl
	{ 0.2435, 0.4790, 0.2456, 0.4821 },   -- middle left: the band by the skull's top from the hill
	{ 0.2574, 0.4790, 0.3054, 0.4821 },   -- middle left: the band by the skull's top from the hill
	{ 0.2594, 0.4820, 0.3014, 0.4881 },   -- middle left: the band by the skull's top from the hill
	{ 0.2654, 0.4880, 0.2755, 0.4911 },   -- middle left: the band by the skull's top from the hill
	{ 0.2295, 0.4910, 0.2396, 0.5000 },   -- middle left: the band by the skull's top from the hill
	{ 0.2235, 0.5000, 0.2336, 0.6108 },   -- middle left: the band by the north-west tusk
	{ 0.2335, 0.5000, 0.2376, 0.6018 },   -- middle left: the band by the skull's top from the hill
	{ 0.6826, 0.5000, 0.7066, 0.5030 },   -- middle right: the band by the causeway
	{ 0.6786, 0.5029, 0.7146, 0.5090 },   -- middle right: the band by the causeway
	{ 0.7804, 0.5059, 0.7825, 0.5180 },   -- middle right: the band by the swirl
	{ 0.6746, 0.5089, 0.7186, 0.5210 },   -- middle right: the band by the causeway
	{ 0.2375, 0.5119, 0.2416, 0.5959 },   -- middle left: the band by the skull's top from the hill
	{ 0.2415, 0.5149, 0.2476, 0.5899 },   -- middle left: the band by the skull's top from the hill
	{ 0.6706, 0.5149, 0.6747, 0.5210 },   -- middle right: the band by the causeway
	{ 0.2475, 0.5179, 0.2496, 0.5839 },   -- middle left: the band by the skull's top from the hill
	{ 0.7764, 0.5179, 0.7825, 0.5330 },   -- middle right: the band by the swirl
	{ 0.2495, 0.5209, 0.2695, 0.5719 },   -- middle left: the band by the skull's top from the hill
	{ 0.6666, 0.5209, 0.7206, 0.5300 },   -- middle right: the band by the causeway
	{ 0.2694, 0.5269, 0.2735, 0.5689 },   -- middle left: the band by the skull's top from the hill
	{ 0.7724, 0.5269, 0.7765, 0.5330 },   -- middle right: the band by the swirl
	{ 0.2734, 0.5299, 0.2775, 0.5599 },   -- middle left: the band by the skull's top from the hill
	{ 0.6586, 0.5299, 0.7266, 0.5360 },   -- middle right: the band by the causeway
	{ 0.7684, 0.5329, 0.7825, 0.5480 },   -- middle right: the band by the swirl
	{ 0.6566, 0.5359, 0.7306, 0.5390 },   -- middle right: the band by the causeway
	{ 0.7624, 0.5359, 0.7685, 0.5420 },   -- middle right: the band by the swirl
	{ 0.6526, 0.5389, 0.7366, 0.5450 },   -- middle right: the band by the causeway
	{ 0.7524, 0.5419, 0.7685, 0.5480 },   -- middle right: the band by the swirl
	{ 0.6506, 0.5449, 0.7525, 0.5480 },   -- middle right: the band by the causeway
	{ 0.6427, 0.5479, 0.7705, 0.5629 },   -- middle right: the band by the swirl
	{ 0.6167, 0.5508, 0.6428, 0.5689 },   -- middle: the band by the path's south bank
	{ 0.6127, 0.5568, 0.6228, 0.5959 },   -- middle: the band by the path's south bank
	{ 0.2495, 0.5718, 0.2535, 0.5809 },   -- middle left: the band by the skull's top from the hill
	{ 0.2534, 0.5718, 0.2555, 0.5749 },   -- middle left: the band by the skull's top from the hill
	{ 0.4051, 0.5748, 0.4551, 0.6498 },   -- middle: the band by the south-east flank
	{ 0.4011, 0.5808, 0.4571, 0.6468 },   -- middle: the band by the south-east flank
	{ 0.4570, 0.5838, 0.4611, 0.6198 },   -- middle: the band by the path's south bank
	{ 0.6087, 0.5898, 0.6128, 0.5959 },   -- middle: the band by the path's south bank
	{ 0.5089, 0.5958, 0.5250, 0.6018 },   -- middle: the band by the path's south bank
	{ 0.6027, 0.5958, 0.6208, 0.6168 },   -- middle: the band by the path's south bank
	{ 0.5049, 0.6017, 0.5290, 0.6228 },   -- middle: the band by the path's south bank
	{ 0.5968, 0.6017, 0.6028, 0.6108 },   -- middle: the band by the path's south bank
	{ 0.5069, 0.6077, 0.5330, 0.6647 },   -- middle: the band by the path's south bank
	{ 0.5668, 0.6077, 0.5969, 0.6108 },   -- middle: the band by the path's south bank
	{ 0.2135, 0.6107, 0.2236, 0.6318 },   -- middle left: the band by the north-west tusk
	{ 0.2235, 0.6107, 0.2256, 0.6258 },   -- middle left: the band by the north-west tusk
	{ 0.2255, 0.6107, 0.2296, 0.6198 },   -- middle left: the band by the north-west tusk
	{ 0.5568, 0.6107, 0.6028, 0.6288 },   -- middle: the band by the path's south bank
	{ 0.5329, 0.6137, 0.5350, 0.6318 },   -- middle: the band by the path's south bank
	{ 0.5349, 0.6167, 0.5569, 0.6318 },   -- middle: the band by the path's south bank
	{ 0.2115, 0.6317, 0.2196, 0.6438 },   -- middle left: the band by the north-west tusk
	{ 0.4770, 0.6407, 0.4911, 0.6438 },   -- middle: the band by the path's south bank
	{ 0.2115, 0.6437, 0.2216, 0.6527 },   -- middle left: the band by the north-west tusk
	{ 0.4550, 0.6437, 0.4951, 0.6498 },   -- middle: the band by the path's south bank
	{ 0.2375, 0.6467, 0.2535, 0.6527 },   -- middle left: the band by the north-west tusk
	{ 0.3632, 0.6497, 0.3753, 0.6557 },   -- middle: the band by the south-east flank
	{ 0.4031, 0.6497, 0.5070, 0.6767 },   -- middle: the band by the hill south of the skull
	{ 0.2135, 0.6526, 0.2236, 0.6557 },   -- middle left: the band by the north-west tusk
	{ 0.2355, 0.6526, 0.2575, 0.6707 },   -- middle left: the band by the north-west tusk
	{ 0.2135, 0.6556, 0.2555, 0.6797 },   -- bottom left: the band by the north-west tusk
	{ 0.3612, 0.6556, 0.3793, 0.6587 },   -- middle: the band by the south-east flank
	{ 0.3572, 0.6586, 0.3833, 0.6647 },   -- middle: the band by the south-east flank
	{ 0.3572, 0.6646, 0.3893, 0.6767 },   -- bottom middle: the band by the south-east flank
	{ 0.3892, 0.6676, 0.3933, 0.6767 },   -- bottom middle: the band by the south-east flank
	{ 0.3932, 0.6706, 0.4032, 0.6767 },   -- bottom middle: the band by the south-east flank
	{ 0.3552, 0.6766, 0.4092, 0.7036 },   -- bottom middle: the band by the south-east flank
	{ 0.2335, 0.6796, 0.2496, 0.6857 },   -- bottom left: the band by the north-west tusk
	{ 0.2335, 0.6856, 0.2436, 0.6887 },   -- bottom left: the band by the north-west tusk
	{ 0.3532, 0.6856, 0.3553, 0.6887 },   -- bottom middle: the band by the south-east flank
	{ 0.2335, 0.6886, 0.2416, 0.7066 },   -- bottom left: the band by the mouth
	{ 0.3393, 0.6886, 0.3553, 0.8354 },   -- bottom middle: the band by the south-east tusk's tip (E4)
	{ 0.3373, 0.6946, 0.3394, 0.8204 },   -- bottom middle: the band by the south-east tusk's tip (E4)
	{ 0.3333, 0.7005, 0.3374, 0.7815 },   -- bottom middle: the band by the south-east tusk's tip (E4)
	{ 0.2335, 0.7065, 0.2456, 0.7156 },   -- bottom left: the band by the mouth
	{ 0.2375, 0.7155, 0.2496, 0.7336 },   -- bottom left: the band by the mouth
	{ 0.2495, 0.7215, 0.2575, 0.7276 },   -- bottom left: the band by the mouth
	{ 0.3313, 0.7245, 0.3334, 0.7545 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.2495, 0.7275, 0.2615, 0.7336 },   -- bottom left: the band by the mouth
	{ 0.2495, 0.7335, 0.2675, 0.7515 },   -- bottom left: the band by the mouth
	{ 0.2674, 0.7365, 0.2735, 0.7486 },   -- bottom left: the band by the mouth
	{ 0.2734, 0.7425, 0.2855, 0.7486 },   -- bottom left: the band by the mouth
	{ 0.2674, 0.7485, 0.2895, 0.7515 },   -- bottom left: the band by the mouth
	{ 0.2674, 0.7514, 0.2975, 0.7845 },   -- bottom left: the band by the mouth
	{ 0.2974, 0.7574, 0.2995, 0.7605 },   -- bottom left: the band by the mouth
	{ 0.2974, 0.7604, 0.3034, 0.7845 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.3033, 0.7814, 0.3054, 0.7845 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.2974, 0.7844, 0.3114, 0.8294 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.3113, 0.7904, 0.3154, 0.8204 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.3113, 0.8203, 0.3194, 0.8384 },   -- bottom left: the band by the south-east tusk's tip (E4)
	{ 0.3333, 0.8203, 0.3394, 0.8414 },   -- bottom middle: the band by the south-east tusk's tip (E4)
	{ 0.3193, 0.8263, 0.3334, 0.8414 },   -- bottom left: the band by the south-east tusk's tip (E4)
}

-- The maze, with the way in, on the Barrens' map.
ns.AddSubMap({
	key = "RazorfenDownsApproach",
	name = "Razorfen Downs",
	parentMapID = 1413,
	levels = RFD_LEVELS,
	level = 1,
	icon = "building",
	art = RFD_MAZE_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1413, x = 0.4463, y = 0.8890 },   -- off the Southern Gold Road, where the subzone turned (reading 837)
	calibration = {
		{ map = { 0.436709, 0.861203 }, picture = { 0, 0 } },
		{ map = { 0.544189, 0.968672 }, picture = { 1, 1 } },
	},
	areas = RFD_AREAS,
	instances = RFD_MAZE_DOOR,
})
-- The same picture on Kalimdor's map, where the client reports the building; its way in is the one above.
ns.AddSubMap({
	key = "RazorfenDownsApproachKalimdor",
	name = "Razorfen Downs",
	parentMapID = 1414,
	levels = RFD_LEVELS,
	level = 1,
	art = RFD_MAZE_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.512747, 0.693179 }, picture = { 0, 0 } },
		{ map = { 0.542343, 0.722775 }, picture = { 1, 1 } },
	},
	areas = RFD_WMO_AREAS,
	instances = RFD_MAZE_DOOR,
})
-- The close-up, on the Barrens' map: the ground in the skull and round it, inside the line.
ns.AddSubMap({
	key = "RazorfenDownsSkull",
	name = "Razorfen Downs",
	parentMapID = 1413,
	levels = RFD_LEVELS,
	level = 2,
	art = RFD_SKULL_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.480171, 0.912811 }, picture = { 0, 0 } },
		{ map = { 0.515486, 0.948122 }, picture = { 1, 1 } },
	},
	areas = RFD_AREAS,
	claims = RFD_SKULL_CLAIMS,
	overlaps = RFD_SKULL_OVERLAPS,
	instances = RFD_SKULL_DOOR,
})
-- And on Kalimdor's map, the skull's and the path's floors: the same claims, no band.
ns.AddSubMap({
	key = "RazorfenDownsSkullKalimdor",
	name = "Razorfen Downs",
	parentMapID = 1414,
	levels = RFD_LEVELS,
	level = 2,
	art = RFD_SKULL_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.524715, 0.707392 }, picture = { 0, 0 } },
		{ map = { 0.534440, 0.717116 }, picture = { 1, 1 } },
	},
	areas = RFD_WMO_AREAS,
	claims = RFD_SKULL_CLAIMS,
	instances = RFD_SKULL_DOOR,
})

-- Its door on the Barrens: the portal's swirl (Classic Era's trigger 442 is 8 yards past it, Map 129's corpse
-- point 6), not the hillside south of the path the journal had (world -4716.7, -2450), 57 yards past where the
-- owner could climb.
if ns.GetInstance("RazorfenDowns") then
	ns.AmendInstance("RazorfenDowns", {
		zoneEntrance = { mapID = 1413, world = { 1, -4661.12, -2530.59 } },
		via = "RazorfenDownsApproach",
	})
end

--[[
	The Temple of Atal'Hakkar's way in, on two pictures (Dev/maps/TempleOfAtalHakkarApproach: plan.md,
	pool/ and halls/): level 1, the Pool of Tears seen from above with the temple's crown and the
	doorway in its pit; level 2, the halls under the pool from the doorway to the portal. Classic Era
	reports the Eastern Kingdoms (1415) on the crown and in the halls, the crown outdoors with "The
	Temple of Atal'Hakkar" or nothing, the halls indoors from the doorway on, with their room names
	(the owner's walk, 2026-10-30: research/readings/readings_2026-10-30.md). The halls come first:
	indoors both name the same spots, and the first named picture wins.
	To read in Forever (from 2026-11-04): the map it reports inside (1435 expected), its room names
	(Hall of Faces and Den of the Unholy), and where its portal is.
]]
local TOAH_LEVELS = { "Pool of Tears", "The Temple of Atal'Hakkar" }
local TOAH_POOL_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TempleOfAtalHakkarPool"
local TOAH_HALLS_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\TempleOfAtalHakkarHalls"
local TOAH_DOOR = { TempleOfAtalHakkar = { x = 0.7450, y = 0.2043 } }   -- Classic Era's swirl (-10171.00, -3996.04)
local TOAH_POOL_LINKS = { { x = 0.3227, y = 0.5641, level = 2 } }       -- the doorway in the crown's pit
local TOAH_HALLS_LINKS = { { x = 0.4354, y = 0.9248, level = 1 } }      -- the doorway at the tower's head
local TOAH_HALL_NAMES = { "The Broken Hall", "Hall of Masks", "Hall of Faces", "The Butchery", "Hall of Ritual",
	"Den of the Caller", "Den of the Unholy", "Chamber of Blood", "Hall of Bones" }
local function TempleAreas(...)
	local areas = { [""] = true, ["The Temple of Atal'Hakkar"] = true }
	for _, name in ipairs(TOAH_HALL_NAMES) do areas[name] = true end
	for i = 1, select("#", ...) do areas[select(i, ...)] = true end
	return areas
end

-- Level 2, the halls, indoors, on the Eastern Kingdoms' map; the way in is the doorway.
ns.AddSubMap({
	key = "TempleOfAtalHakkarHalls",
	name = "The Temple of Atal'Hakkar",
	parentMapID = 1415,
	levels = TOAH_LEVELS,
	level = 2,
	icon = "building",
	indoors = true,
	art = TOAH_HALLS_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1435, x = 0.6999, y = 0.5299 },   -- WMO portal 33, the doorway
	calibration = {
		{ map = { 0.556608, 0.748461 }, picture = { 0, 0 } },
		{ map = { 0.571995, 0.763848 }, picture = { 1, 1 } },
	},
	areas = TempleAreas(),
	instances = TOAH_DOOR,
	links = TOAH_HALLS_LINKS,
})
-- And on the swamp's map, if the client reports it inside (Forever is expected to): its unnamed halls
-- read the ground's names there.
ns.AddSubMap({
	key = "TempleOfAtalHakkarHallsSwamp",
	name = "The Temple of Atal'Hakkar",
	parentMapID = 1435,
	levels = TOAH_LEVELS,
	level = 2,
	indoors = true,
	art = TOAH_HALLS_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.597107, 0.311540 }, picture = { 0, 0 } },
		{ map = { 0.833235, 0.547669 }, picture = { 1, 1 } },
	},
	areas = TempleAreas("Pool of Tears", "Sorrowmurk"),
	instances = TOAH_DOOR,
	links = TOAH_HALLS_LINKS,
})
-- Level 1, the pool, on the Eastern Kingdoms' map: the crown reads the temple's name or nothing.
ns.AddSubMap({
	key = "TempleOfAtalHakkarPool",
	name = "The Temple of Atal'Hakkar",
	parentMapID = 1415,
	levels = TOAH_LEVELS,
	level = 1,
	art = TOAH_POOL_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.558341, 0.754011 }, picture = { 0, 0 } },
		{ map = { 0.573727, 0.769398 }, picture = { 1, 1 } },
	},
	areas = { [""] = true, ["The Temple of Atal'Hakkar"] = true },
	links = TOAH_POOL_LINKS,
})
-- On the swamp's map the crown reads Pool of Tears, as the whole lake does: from the levels menu only.
ns.AddSubMap({
	key = "TempleOfAtalHakkarPoolSwamp",
	name = "The Temple of Atal'Hakkar",
	parentMapID = 1435,
	levels = TOAH_LEVELS,
	level = 1,
	art = TOAH_POOL_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.623701, 0.396711 }, picture = { 0, 0 } },
		{ map = { 0.859829, 0.632839 }, picture = { 1, 1 } },
	},
	links = TOAH_POOL_LINKS,
})

-- Its door on the swamp's map: Classic Era's swirl, reached through the halls.
if ns.GetInstance("TempleOfAtalHakkar") then
	ns.AmendInstance("TempleOfAtalHakkar", {
		zoneEntrance = { mapID = 1435, world = { 0, -10171.00, -3996.04 } },
		via = "TempleOfAtalHakkarHalls",
	})
end

--[[
	Uldaman's dig: the excavation cave below the Badlands' northern cliffs that leads to the
	dungeon, on Blizzard's own drawn map of it (retail's microdungeon map 16, the client's tiles, the
	same cave in Forever's client). Its area is a subzone of the Badlands, so the client reports it
	there (1418). Its rooms are named (Excavation Center, Dig One, the Hall of the Keepers, the North
	and South Common Halls, The Sealed Hall), the rest reading "Uldaman"; no ground outside uses these
	names (it reads The Maker's Terrace or the Badlands themselves). The way in is the cave's mouth;
	the portal, the picture's swirl. The dungeon's back door, far to the east, is not on it.
]]
ns.AddSubMap({
	key = "UldamanApproach",
	name = "Uldaman",
	parentMapID = 1418,
	tiles = "Interface\\WorldMap\\MicroDungeon\\Badlands\\Uldaman\\Uldaman18_",
	way = { mapID = 1418, x = 0.4445, y = 0.1216 },
	calibration = {
		{ map = { 0.269179, 0.039447 }, picture = { 0, 0 } },
		{ map = { 0.495310, 0.265578 }, picture = { 1, 1 } },
	},
	areas = {
		["Uldaman"] = true, ["Excavation Center"] = true, ["Dig One"] = true, ["Hall of the Keepers"] = true,
		["North Common Hall"] = true, ["South Common Hall"] = true, ["The Sealed Hall"] = true,
	},
	instances = { Uldaman = { x = 0.3667, y = 0.2680 } },
})

if ns.GetInstance("Uldaman") then
	ns.AmendInstance("Uldaman", {
		zoneEntrance = { mapID = 1418, x = 0.3521, y = 0.1001 },
		via = "UldamanApproach",
	})
end

--[[
	Maraudon's two caves in Desolace, the orange and the purple, on one picture: the owner's,
	Blizzard's drawn maps of both caves (retail's microdungeon maps 67 and 68) set on one sheet
	(Media/Maps/MaraudonCaves, Dev/maps/Maraudon). Both caves are one building of the game's, whose
	area is Maraudon's own, not a part of Desolace, so the client reports a player in them on
	Kalimdor (1414), as it does the Defias Hideout on the Eastern Kingdoms; every room reads
	"Maraudon", a name no ground outside has. They share the mouth, in the orange cave's shrine, so
	only the orange has the way in.
	The sheet sets each cave at about 71% of its own map, but Blizzard drew the purple one 7% larger
	than the orange, and the sheet sets it some 26 yards off the orange cave: one placement cannot
	hold both. So the picture is placed twice, once a cave (Dev/maps/Maraudon/placement.py fits each
	cave's own map to the sheet and carries its place in the world through): the purple placement
	takes the purple cave's floor (claims, checked on the game's 2-yard floor cells where the client
	reports them, rounded: 8,651 of its 8,692; the 41 left, at the join under the mouth, keep the
	orange's, at most 9 yards off), the orange placement the rest. Both show the same picture, with
	both portals, where the game's triggers for them are, and the player's arrow is always by the
	placement of the cave they are in, whichever was opened. Walking between the caves changes the
	placement with no new area name, so the player's position is followed there (follow).
	The caves' menu on the world map's location bar (views, the owner's wish, 2026-10-27): the one
	picture first, what shows by itself, then the pictures the caves had before it, Blizzard's map
	of each cave alone (the client's tiles), for players who would rather see one cave by itself.
	Those two are views only (viewOnly): never the player's map, no way in of their own on Desolace
	or Kalimdor, shown only when picked from the menu (held while the map is open), each with its
	portal and the player's arrow by its own placement, worked out before from the game's data.
	Picking the one picture again, the map follows the player between its placements again.
]]
local MARAUDON_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\MaraudonCaves"
local MARAUDON_DOORS = { Maraudon = { { x = 0.7142, y = 0.7049 }, { x = 0.4244, y = 0.1498 } } }
local MARAUDON_VIEWS = { "MaraudonOrange", "MaraudonOrangeCave", "MaraudonPurpleCave" }
ns.AddSubMap({
	key = "MaraudonOrange",
	name = "Maraudon",
	parentMapID = 1414,
	art = MARAUDON_ART,
	artRight = 1000 / 1024,
	artBottom = 667 / 1024,
	way = { mapID = 1443, x = 0.2886, y = 0.6254 },
	calibration = {
		{ map = { 0.376209, 0.566200 }, picture = { 0, 0 } },
		{ map = { 0.399215, 0.588943 }, picture = { 1, 1 } },
	},
	areas = { ["Maraudon"] = true },
	follow = true,
	instances = MARAUDON_DOORS,
	views = MARAUDON_VIEWS,
})
ns.AddSubMap({
	key = "MaraudonPurple",
	name = "Maraudon",
	parentMapID = 1414,
	art = MARAUDON_ART,
	artRight = 1000 / 1024,
	artBottom = 667 / 1024,
	calibration = {
		{ map = { 0.376876, 0.566703 }, picture = { 0, 0 } },
		{ map = { 0.398373, 0.588157 }, picture = { 1, 1 } },
	},
	areas = { ["Maraudon"] = true },
	claims = {
		{ 0.1828, 0.2774, 0.4660, 0.5327 },
		{ 0.3881, 0.5281, 0.4731, 0.6533 },
		{ 0.0412, 0.0000, 0.7492, 0.2837 },
		{ 0.0412, 0.0000, 0.1417, 0.6888 },
		{ 0.1805, 0.2729, 0.1892, 0.2909 },
		{ 0.1805, 0.2822, 0.1892, 0.3048 },
		{ 0.3713, 0.5292, 0.3939, 0.5472 },
		{ 0.3713, 0.5991, 0.3939, 0.6125 },
		{ 0.4596, 0.5152, 0.4683, 0.5286 },
		{ 0.4596, 0.5199, 0.4683, 0.5379 },
	},
	follow = true,
	instances = MARAUDON_DOORS,
	views = MARAUDON_VIEWS,
})

-- Each cave on its own map, a view only: Blizzard's (retail's microdungeon maps 67 and 68, the
-- client's tiles), placed on Kalimdor and with its portal as before the one picture.
local MARAUDON_TILES = "Interface\\WorldMap\\MicroDungeon\\Desolace\\MaraudonOutside\\MaraudonOutside"
ns.AddSubMap({
	key = "MaraudonOrangeCave",
	name = "Maraudon (Orange)",
	parentMapID = 1414,
	tiles = MARAUDON_TILES .. "21_",
	calibration = {
		{ map = { 0.379923, 0.572689 }, picture = { 0, 0 } },
		{ map = { 0.396228, 0.588994 }, picture = { 1, 1 } },
	},
	instances = { Maraudon = { x = 0.7799, y = 0.5852 } },
	views = MARAUDON_VIEWS,
	viewOnly = true,
})
ns.AddSubMap({
	key = "MaraudonPurpleCave",
	name = "Maraudon (Purple)",
	parentMapID = 1414,
	tiles = MARAUDON_TILES .. "22_",
	calibration = {
		{ map = { 0.377763, 0.566262 }, picture = { 0, 0 } },
		{ map = { 0.392981, 0.581480 }, picture = { 1, 1 } },
	},
	instances = { Maraudon = { x = 0.5412, y = 0.2401 } },
	views = MARAUDON_VIEWS,
	viewOnly = true,
})

-- Its door on Desolace: the orange cave's portal (the game's trigger 3133), below the mouth.
if ns.GetInstance("Maraudon") then
	ns.AmendInstance("Maraudon", {
		zoneEntrance = { mapID = 1443, world = { 1, -1484.07, 2617.57 } },
		via = "MaraudonOrange",
	})
end

--[[
	Inside Blackrock Mountain, on Blizzard's own drawn maps of it, its three levels as retail has them
	(a menu of them, as a dungeon's floors have one):
	  the ring (retail's map 33: the chained ring over the lava, Forgewright's Tomb, the Spire's
	  corridors), redrawn for classic (Media/Maps/BlackrockMountainRing): retail's two Spire doors,
	  their swirls and labels, painted out, one "BLACKROCK SPIRE" label set at classic's door as
	  Blizzard sets its labels, and the rooms past that door, inside the instance in classic, faded to
	  the grey of Blizzard's lower floors;
	  the middle level (map 34, Media/Maps/BlackrockMountainMiddle): its corridor and rooms are in
	  Forever's model of the mountain, the Blackrock Caverns beyond them are not, so their label and
	  swirl are painted out and the corridor closed where Forever's wall stands;
	  the way down to Blackrock Depths (map 35, the client's tiles).
	Dev/maps/BlackrockMountainRing and Dev/maps/BlackrockMountainMiddle make the two pictures, with
	these edits and Torchlite's signature (LICENSE-MAPS.md); where things are on them comes from
	Forever's own model of the mountain
	(Dev/maps/BlackrockMountain_2026-10-27). The game has no map of the mountain: the client reports
	a player in it on the zone of the ground below, Burning Steppes (1428) under most of it, Searing
	Gorge (1427) under its gate's tunnel, the Masonary, the Depths' door and the Quarry's north end.
	So the ring's picture is on both (only the tunnel on Searing Gorge's), the lower one too; the
	middle level lies over Burning Steppes' ground alone.
	The ring's rooms read The Molten Span, Blackrock Spire or Forgewright's Tomb; the lower level's,
	The Grinding Quarry or The Masonary. The Molten Span is one room of the game's that reaches down
	to the Molten Core's ledge too: it shows the ring. The tunnels from the gates read "Blackrock
	Mountain", like the ground outside them, but every room inside the mountain is indoors and
	the gates' fronts are not: so the ring counts that name indoors only (indoorAreas; its own
	names count anywhere). Before that, the map turned only at the tunnels' inner ends, the
	player's readings there (2026-10-21) 1428 (0.2748, 0.2318) and (0.2796, 0.3509), The Molten
	Span. The doorway by the Molten Core's ledge, "Blackrock Mountain" too, keeps a player come up
	from the Quarry below on the lower map; and the Depths' door, named nothing at all (unnamed),
	keeps one come from the Masonary.
	The ways in, with a building's icon (the player's pick), show at both gates, where the
	player's /aegis where read 1428 (0.2940, 0.3829) and 1427 (0.3485, 0.8583) as the minimap
	turned to the mountain (2026-10-21); each names all three dungeons (alsoLeadsTo: the Depths'
	door is on the lower picture).
	The Spire's door is where classic has it, as the owner marked it: Lower and Upper Blackrock
	Spire are one instance (the game's map 229, up to 10 players) behind one portal, where the
	Spire's corridor leaves the ring; Upper Blackrock Spire is further in, behind a sealed door that
	needs the Seal of Ascension. Its icon stands on the portal's swirl in Forever's model (world
	-7523.07, -1231.99; 1428 0.3296, 0.2519), the same spot through either calibration. Retail's door
	to Upper Blackrock Spire, where the journal had the icon before (0.7894, 0.3308), is inside the
	instance in classic. Its notes (doorNotes, below) say so on the door and on both dungeons' pages.
	The middle level: its corridor leaves the ring's east walkway through a doorway, and on the way
	to the Spire's door it climbs the north room's stair to the ring's high walkway (in Forever's
	model the only walk from the gates to that door). The corridor has no name in Forever's tables,
	so the client names the ground below it, as it does the tunnels: in game (Classic Era, whose
	floors are Forever's, 2026-10-27) the curved corridor read "Blackrock Mountain" (area 254; the
	model had guessed Blackrock Stronghold, 252, which stays counted), and its rooms further in
	"Blackrock Spire", like the ring's Spire side. The ring's high walkway, the corridor east of the
	junction and the threshold of the Spire's hall off that corridor run over its rooms, with that
	name too, and the client gives no height. So the middle level takes its names only on its own
	floors (claims, boxes on its picture measured on Forever's floors), where its names count before
	the ring's, and the corridor's ground names count only there, indoors (the Blackrock Stronghold
	outside has buildings of its own); where the ring's floors lie over or beside its own
	(overlaps), the level the player was last seen on keeps them. The north room's stair climbs from
	the room, past its stairwell, to a landing over the room and on to the high walkway; the owner
	walked it in game and set where the map turns, halfway up its upper flight where it comes out
	from over the stairwell (2026-10-27, world -7528.6, -1287.0): above that line the stair is the
	ring's, out of the claims, and its landing over the room an overlap, so the map turns at the
	line going up and coming down. Outside the overlaps the claims hold none of the floors a walk
	from the gates reaches on the ring's side; they do hold the Spire's hall and the rooms
	north-east of it, high above the middle level's rooms, which that walk reaches only through the
	room behind the Spire's portal (inside the instance in classic). The claims and overlaps are
	read from the model.
	Where the levels meet (links: a spot on a level's picture, and the level the way leads to): the
	doorway between the ring's east walkway and the middle level's corridor, at one height, and the
	north room's stair up to the high walkway, both where the owner stood in game (2026-10-27);
	Forgewright's Tomb on the island, whose stair leads down to the chain path (from the model); and
	the rock at the chain's top by the Molten Core's ledge, where the lower level begins (the
	owner's pick). Each shows on both pictures as retail's map link between floors, a door with its
	arrow up or down the levels' menu; a click shows the other level.
]]
local BLACKROCK_LOWER_TILES = "Interface\\WorldMap\\MicroDungeon\\SearingGorge\\BlackrockMountain\\BlackrockMountain16_"
local BLACKROCK_DEPTHS_DOOR = { BlackrockDepths = { x = 0.3922, y = 0.1766 } }
local BLACKROCK_SPIRE_DOOR = {
	LowerBlackrockSpire = { x = 0.6607, y = 0.4170 },
	UpperBlackrockSpire = { x = 0.6607, y = 0.4170 },
}
-- Its levels, top to bottom: retail's own names for the ring and the way down; the middle level by
-- the name the client gives its curved corridor in game, Blackrock Mountain (retail's, Blackrock
-- Caverns, is the part Forever lacks).
local BLACKROCK_LEVELS = { "Blackrock Spire", "Blackrock Mountain", "Blackrock Depths" }
-- Where the levels meet, on each one's picture.
local BLACKROCK_RING_LINKS = {
	{ x = 0.6795, y = 0.6109, level = 2 },   -- the doorway off the east walkway into the middle level
	{ x = 0.7437, y = 0.4265, level = 2 },   -- the north room's stair, up to the high walkway
	{ x = 0.5092, y = 0.5601, level = 3 },   -- Forgewright's Tomb, the way down
}
local BLACKROCK_MIDDLE_LINKS = {
	{ x = 0.3937, y = 0.7953, level = 1 },   -- the doorway onto the ring's east walkway
	{ x = 0.5729, y = 0.2801, level = 1 },   -- the north room's stair, up to the ring
}
local BLACKROCK_LOWER_LINKS = {
	{ x = 0.5868, y = 0.8743, level = 1 },   -- the rock at the chain's top by the Molten Core's ledge (the owner's pick)
}
-- Retail's map 33 with both Spire doors painted out, classic's one labelled, the rooms past it
-- faded and Torchlite's signature (Dev/maps/BlackrockMountainRing).
local BLACKROCK_RING_ART = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\BlackrockMountainRing"
ns.AddSubMap({
	key = "BlackrockMountain",
	name = "Blackrock Mountain",
	parentMapID = 1428,
	levels = BLACKROCK_LEVELS,
	level = 1,
	icon = "building",
	art = BLACKROCK_RING_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1428, x = 0.2940, y = 0.3829 },
	calibration = {
		{ map = { 0.1688, 0.1505 }, picture = { 0, 0 } },
		{ map = { 0.4121, 0.3938 }, picture = { 1, 1 } },
	},
	areas = { ["The Molten Span"] = true, ["Blackrock Spire"] = true, ["Forgewright's Tomb"] = true },
	indoorAreas = { ["Blackrock Mountain"] = true },
	instances = BLACKROCK_SPIRE_DOOR,
	alsoLeadsTo = { "BlackrockDepths" },
	links = BLACKROCK_RING_LINKS,
})
ns.AddSubMap({
	key = "BlackrockMountainGorge",
	name = "Blackrock Mountain",
	parentMapID = 1427,
	levels = BLACKROCK_LEVELS,
	level = 1,
	icon = "building",
	art = BLACKROCK_RING_ART,
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	way = { mapID = 1427, x = 0.3485, y = 0.8583 },
	calibration = {
		{ map = { 0.1965, 0.8235 }, picture = { 0, 0 } },
		{ map = { 0.5158, 1.1429 }, picture = { 1, 1 } },
	},
	areas = {},
	indoorAreas = { ["Blackrock Mountain"] = true },
	instances = BLACKROCK_SPIRE_DOOR,
	alsoLeadsTo = { "BlackrockDepths" },
	links = BLACKROCK_RING_LINKS,
})

-- The middle level, on Burning Steppes only: its corners are retail's map region for map 34, read
-- on Burning Steppes as the ring's and the lower level's are. Its claims, top to bottom: the north
-- room's west arm under the stair's landing, its inner ramp under the landing's edge, the stair up
-- to the owner's line with the room east of the ramp, the cobbled room with the room east of the
-- junction, the corridor north, the curved corridor; its overlaps: the high walkway over the
-- corridor north, the corridor east of the junction over the junction, the Spire's corridors and
-- the Molten Span by the corridor's two ends, the Spire hall's threshold off the corridor east of
-- the junction, over the cobbled room, and the stair's landing over the north room
-- (Dev/maps/BlackrockMountain_2026-10-27/journal/claims.py, which checks them on every floor a
-- walk from the gates reaches).
ns.AddSubMap({
	key = "BlackrockMountainMiddle",
	name = "Blackrock Mountain",
	parentMapID = 1428,
	levels = BLACKROCK_LEVELS,
	level = 2,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\BlackrockMountainMiddle",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	calibration = {
		{ map = { 0.299858, 0.229883 }, picture = { 0, 0 } },
		{ map = { 0.386913, 0.316969 }, picture = { 1, 1 } },
	},
	areas = { ["Blackrock Spire"] = true },
	indoorAreas = { ["Blackrock Stronghold"] = true, ["Blackrock Mountain"] = true },
	claims = {
		{ 0.4770, 0.2246, 0.5409, 0.4147 },
		{ 0.5409, 0.3084, 0.5569, 0.4147 },
		{ 0.5569, 0.2246, 0.6537, 0.4147 },
		{ 0.5639, 0.3234, 0.7236, 0.6272 },
		{ 0.4910, 0.3982, 0.5749, 0.6272 },
		{ 0.3792, 0.6063, 0.5868, 0.8832 },
	},
	overlaps = {
		{ 0.4910, 0.3982, 0.5589, 0.5210 },
		{ 0.4910, 0.5030, 0.6287, 0.6272 },
		{ 0.3792, 0.6063, 0.5050, 0.6542 },
		{ 0.3792, 0.6063, 0.4092, 0.8832 },
		{ 0.6158, 0.4940, 0.6477, 0.6018 },
		{ 0.4770, 0.2246, 0.5569, 0.4147 },
	},
	links = BLACKROCK_MIDDLE_LINKS,
})

-- The mountain's door on Searing Gorge, its three dungeons', a little into the mountain from the
-- gate's way in (the player's request, 2026-10-21), so both icons show.
for _, key in ipairs({ "BlackrockDepths", "LowerBlackrockSpire", "UpperBlackrockSpire" }) do
	if ns.GetInstance(key) then ns.AmendInstance(key, { zoneEntrance = { mapID = 1427, x = 0.328, y = 0.888 } }) end
end
ns.AddSubMap({
	key = "BlackrockDepthsApproach",
	name = "Blackrock Mountain",
	parentMapID = 1427,
	levels = BLACKROCK_LEVELS,
	level = 3,
	tiles = BLACKROCK_LOWER_TILES,
	calibration = {
		{ map = { 0.1365, 0.6633 }, picture = { 0, 0 } },
		{ map = { 0.4771, 1.0039 }, picture = { 1, 1 } },
	},
	areas = { ["The Masonary"] = true, ["The Grinding Quarry"] = true },
	unnamed = true,
	instances = BLACKROCK_DEPTHS_DOOR,
	links = BLACKROCK_LOWER_LINKS,
})
ns.AddSubMap({
	key = "BlackrockDepthsApproachSteppes",
	name = "Blackrock Mountain",
	parentMapID = 1428,
	levels = BLACKROCK_LEVELS,
	level = 3,
	tiles = BLACKROCK_LOWER_TILES,
	calibration = {
		{ map = { 0.1232, 0.0284 }, picture = { 0, 0 } },
		{ map = { 0.3826, 0.2879 }, picture = { 1, 1 } },
	},
	areas = { ["The Grinding Quarry"] = true },
	sharedAreas = { ["Blackrock Mountain"] = true },
	instances = BLACKROCK_DEPTHS_DOOR,
	links = BLACKROCK_LOWER_LINKS,
})

-- What the Spire's door holds, on its icon and on both dungeons' pages: the strings' keys (Locales).
for key, own in pairs({ LowerBlackrockSpire = "DOOR_SPIRE_LOWER", UpperBlackrockSpire = "DOOR_SPIRE_UPPER" }) do
	if ns.GetInstance(key) then ns.AmendInstance(key, { doorNotes = { "DOOR_SPIRE_ONE_INSTANCE", own } }) end
end

--[[
	The Scarlet Monastery's hall, where the doors of its four wings are. The picture
	(Media/Maps/ScarletMonasteryHall) is Blizzard's map of the hall, drawn for the classic
	monastery: retail's has only its two newer doors, so the passages to the Cathedral and the
	Armory are drawn back in and its door names left off (the journal names each wing's door
	itself), with sketches of a Scarlet crusader and the Ashbringer in the empty parchment, the
	gold frame of Blizzard's classic Scarlet Monastery wing maps at its corners, and Torchlite's
	signature (Dev/maps/ScarletMonasteryHall builds it; LICENSE-MAPS.md). Where it lies comes from
	the game's data: retail's map region for the hall, read on Tirisfal and on the continent, and
	the four doors are the game's own portals. The monastery is an area of its own, not under
	Tirisfal, so the client may report a player in the hall on the Eastern Kingdoms (1415), as it
	reports the Defias Hideout; it is set up on Tirisfal (1420) too. In game (2026-10-21) the
	client reports Tirisfal there, the steps and the way in reading "Terrace of Repose" (a Tirisfal
	area, 161, as is "Whispering Gardens", 160, beside it); the hall may read "Scarlet Monastery",
	its vestibule "The Grand Vestibule". The ground before the gate reads "Terrace of Repose" too,
	so the map shows only indoors, as the minimap switches to the building's: from the stair
	corridor in (the player's readings: outdoors at the gate, indoors at 0.8371, 0.3221). The
	building's way in is marked on Tirisfal where the wings' shared door stood, and each wing's
	door moves to its own portal in the hall.
]]
local SCARLET_HALL = {
	name = "Scarlet Monastery",
	-- A building's way in: retail's delve entrance, not the cave's.
	icon = "building",
	-- Shown inside only: the terrace before its gate has the same area name.
	indoors = true,
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\ScarletMonasteryHall",
	artRight = 1002 / 1024,
	artBottom = 668 / 1024,
	areas = { ["Terrace of Repose"] = true, ["Whispering Gardens"] = true, ["Scarlet Monastery"] = true,
		["The Grand Vestibule"] = true },
	instances = {
		ScarletMonasteryGraveyard = { x = 0.6753, y = 0.1789 },
		ScarletMonasteryCathedral = { x = 0.7831, y = 0.1731 },
		ScarletMonasteryArmory = { x = 0.8745, y = 0.5184 },
		ScarletMonasteryLibrary = { x = 0.7972, y = 0.6147 },
	},
}
local function ScarletHall(key, parentMapID, topLeft, bottomRight)
	local subMap = { key = key, parentMapID = parentMapID }
	for field, value in pairs(SCARLET_HALL) do subMap[field] = value end
	subMap.calibration = {
		{ map = topLeft, picture = { 0, 0 } },
		{ map = bottomRight, picture = { 1, 1 } },
	}
	ns.AddSubMap(subMap)
end
ScarletHall("ScarletMonasteryHall", 1420, { 0.817334, 0.294994 }, { 0.862701, 0.340359 })
ns.GetSubMap("ScarletMonasteryHall").way = { mapID = 1420, x = 0.826, y = 0.338 }
-- The same hall, should the client report it on the continent; its way in is the one above.
ScarletHall("ScarletMonasteryHallContinent", 1415, { 0.473297, 0.192519 }, { 0.479121, 0.198343 })

-- The wings' shared door on Tirisfal moves into the hall, amid their portals (the game's portal
-- triggers, a few yards apart: one icon for the four, as before), the way in marking the entrance.
for _, key in ipairs({ "ScarletMonasteryGraveyard", "ScarletMonasteryLibrary",
	"ScarletMonasteryArmory", "ScarletMonasteryCathedral" }) do
	if ns.GetInstance(key) then
		ns.AmendInstance(key, {
			zoneEntrance = { mapID = 1420, x = 0.8529, y = 0.3118 },
			via = "ScarletMonasteryHall",
		})
	end
end

--[[
	The ruins of Dire Maul in Feralas, outside the dungeon: the courtyard with its arena (The Maul),
	Eldreth Row's hall and rooms south of it, and the doors of the three wings. The picture
	(Media/Maps/DireMaulRuins) is the player's, Blizzard's drawn map of the ruins, 1000 x 667 at the
	top left of a 1024 x 1024 texture (Dev/maps). Retail's map of it has no place in the world, so
	where it lies comes from the game's data: Forever's model of the ruins fitted to the drawing at
	one scale, 0.766 px a yard (the hall's pillars, the courtyard's walls, the arena, the south-east
	tunnel), 1305 x 870 yards. The ruins stand on Feralas's ground and none of their rooms has an
	area of its own, so the client reports a player there on Feralas (1444). The hall and the rooms
	south of it read "Eldreth Row", the courtyard's paving and the passages up from the hall
	"Eldre' Thalas", the arena "The Maul": names no ground outside has. The courtyard's grass, the
	wings' doorways and the tunnels read nothing, like the Feralas ground around them, so they only
	keep a player already on the picture (unnamed). The way in is the foot of the great stair, where
	the road up the valley reaches the ruins, about 165 yards south of the picture. Every swirl is a
	door and has its icon: the north wing's; the west wing's two doorways; the east wing's main door
	and its side door at the end of the south-east tunnel (classic's trigger 3184, which leads into
	the Warpwood Quarter too). Feralas' map keeps one door a wing; the east wing's back door by
	Lariss Pavilion is on neither.
]]
ns.AddSubMap({
	key = "DireMaulRuins",
	name = "Dire Maul",
	parentMapID = 1444,
	icon = "building",
	art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\DireMaulRuins",
	artRight = 1000 / 1024,
	artBottom = 667 / 1024,
	way = { mapID = 1444, x = 0.5913, y = 0.4475 },
	calibration = {
		{ map = { 0.495224, 0.223780 }, picture = { 0, 0 } },
		{ map = { 0.683018, 0.411668 }, picture = { 1, 1 } },
	},
	areas = { ["Eldre' Thalas"] = true, ["Eldreth Row"] = true, ["The Maul"] = true },
	unnamed = true,
	instances = {
		DireMaulNorth = { x = 0.7023, y = 0.1379 },
		DireMaulEast = { { x = 0.8160, y = 0.4074 }, { x = 0.9438, y = 0.6664 } },
		DireMaulWest = { { x = 0.5754, y = 0.3939 }, { x = 0.5754, y = 0.5003 } },
	},
})

--[[
	Dire Maul's three wings, each door over its own portal in the ruins on Feralas, where the
	game's own triggers stand (classic's 3189 for the north wing, 3183 for the east, and 3186 and
	3187 for the west wing's two doorways side by side: its door between them, as retail's later
	single trigger 6369 has it). Their data had all three at one spot well south of the ruins. The
	way to each is through the ruins: their waypoint goes to the foot of the great stair.
]]
for key, world in pairs({
	DireMaulNorth = { 1, -3519.95, 1089.93 },
	DireMaulEast = { 1, -3759.69, 934.93 },
	DireMaulWest = { 1, -3790.0, 1247.0 },
}) do
	if ns.GetInstance(key) then
		ns.AmendInstance(key, { zoneEntrance = { mapID = 1444, world = world }, via = "DireMaulRuins" })
	end
end
