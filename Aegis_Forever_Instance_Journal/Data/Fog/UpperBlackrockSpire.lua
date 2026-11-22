local _, ns = ...

--[[ Upper Blackrock Spire's fog: its three floors as the journal draws them, its own pictures
     (Media/Maps/Classic/UpperBlackrockSpire, UpperBlackrockSpire1 and UpperBlackrockSpire2: Dragonspire Hall,
     The Rookery, Hall of Blackhand). Each picture draws the whole Spire, the floor's own rooms light or in colour:
     those are the pieces; the rest of the Spire stays fogged until the whole fog goes. Pieces are fractions of
     the visible picture, as the boss spots are; each is a mask, Media/Fog/UpperBlackrockSpire/<floor>/<piece>.tga,
     traced from the picture and split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/UpperBlackrockSpireFog/fog_spec.py. The Beast's and General Drakkisath's ways run back to the
     boss before them (the doors keep the run's order); every other boss's to the way in. Solakar Flamewreath
     (summoned) and Jed Runewatcher (a rare) hold back no fog: their places clear with the rooms round them. ]]
ns.AddFog("UpperBlackrockSpire", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Solakar Flamewreath"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["UpperBlackrockSpire"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.2620, 0.1064, 0.4870, 0.4468 },       -- Dragonspire Hall's round hall (the way in), its side rooms and stairs
				pyroguard_emberseer = { 0.2160, 0.0255, 0.4570, 0.3388 },       -- Pyroguard Emberseer's room (on the Rookery's map the Rookery too: Solakar holds no fog)
				banner = { 0.2030, 0.0000, 0.8590, 0.1394 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "pyroguard_emberseer", boss = "Pyroguard Emberseer", pieces = { "pyroguard_emberseer" }, back = "entrance", way = { "entrance" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance pyroguard_emberseer banner entrance+pyroguard_emberseer pyroguard_emberseer+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "38.17C1.13C2.8C1.15C30.", "34.64C27.", "31.71C23.", "28.76C21.", "27.79C19.", "27.79C19.",
				"26.17C2B1E60C19.", "26.3C3.3C1E11B15.30C1.8C3.2C19.", "27.3C5.15B53.3C19.", "28.2C5.16B52.2C20.",
				"35.17B73.", "35.17B73.", "35.17B73.", "35.16B74.", "35.8B8D74.", "35.7B9D74.", "33.11B7D74.",
				"33.11B1D7A73.", "33.11B1D9A71.", "35.6B4D9A71.", "35.6B4D9A71.", "40.1A2D11A71.", "41.12A72.", "41.12A72.",
				"41.12A72.", "41.12A72.", "41.11A73.", "42.9A74.", "44.6A75.", "48.1A76.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["UpperBlackrockSpire1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.2240, 0.0435, 0.3870, 0.2909 },
				pyroguard_emberseer = { 0.1810, 0.0825, 0.4440, 0.5577 },       -- Pyroguard Emberseer's room (on the Rookery's map the Rookery too: Solakar holds no fog)
				banner = { 0.2030, 0.0000, 0.8590, 0.1394 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "pyroguard_emberseer", boss = "Pyroguard Emberseer", pieces = { "pyroguard_emberseer" }, back = "way_in", way = {} },
			},
			where = { cols = 125, rows = 84, keys = "way_in pyroguard_emberseer banner way_in+pyroguard_emberseer",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "38.31C2.8C1.15C30.", "34.64C27.", "31.71C23.", "28.77C20.", "27.79C19.", "27.79C19.", "26.80C19.",
				"26.3C3.8C21.31C1.8C3.2C19.", "27.3C73.3C19.", "28.1C75.1C20.", "36.5A84.", "35.6A84.", "35.1A1D4A84.",
				"29.7B1D4A84.", "28.8B4D1A84.", "28.8B4D3B82.", "28.16B81.", "29.15B81.", "32.12B81.", "32.12B81.",
				"32.12B81.", "32.12B81.", "32.12B81.", "32.12B81.", "32.12B81.", "32.16B77.", "32.17B76.", "34.15B76.",
				"34.16B75.", "33.18B74.", "34.17B74.", "34.17B74.", "34.16B75.", "34.16B75.", "34.15B76.", "35.7B1.5B77.",
				"36.3B5.4B77.", "36.4B4.4B77.", "36.4B4.3B78.", "36.4B85.", "37.2B86.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["UpperBlackrockSpire2"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.2040, 0.2609, 0.3750, 0.5337 },
				junctions = { 0.3640, 0.2339, 0.6360, 0.5262 },       -- the junctions under the stadium, the dark block west of the Furnace, the passage down
				hall = { 0.2220, 0.1454, 0.4660, 0.5052 },       -- the Hall of Blackhand: its corridors (Jed's spot too: a rare holds no fog) and the gallery over the Rookery
				gyth = { 0.3450, 0.0180, 0.6610, 0.4198 },       -- Blackrock Stadium, the halls either side of it, the Blackwing Lair passage and their names
				furnace_door = { 0.4430, 0.3613, 0.6340, 0.5877 },       -- the room before the Furnace
				the_beast = { 0.5320, 0.1934, 0.7160, 0.5862 },       -- the Furnace
				goraluk_anvilcrack = { 0.2260, 0.1484, 0.3740, 0.3673 },       -- the west end of the Hall of Blackhand
				general_drakkisath = { 0.2330, 0.3463, 0.5420, 0.6522 },       -- the Spire Throne, the passage east of it and its name
				banner = { 0.2030, 0.0000, 0.8590, 0.1394 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "gyth", boss = "Gyth", pieces = { "gyth" }, back = "way_in", way = { "junctions", "hall" } },
				{ id = "the_beast", boss = "The Beast", pieces = { "the_beast" }, back = "gyth", way = { "furnace_door", "junctions" } },
				{ id = "goraluk_anvilcrack", boss = "Goraluk Anvilcrack", pieces = { "goraluk_anvilcrack" }, back = "way_in", way = { "hall" } },
				{ id = "warchief_rend_blackhand", boss = "Warchief Rend Blackhand", pieces = { "gyth" }, back = "way_in", way = { "junctions", "hall" } },
				{ id = "general_drakkisath", boss = "General Drakkisath", pieces = { "general_drakkisath" }, back = "the_beast", way = {} },
			},
			where = { cols = 125, rows = 84, keys = "way_in junctions hall gyth furnace_door the_beast goraluk_anvilcrack general_drakkisath banner way_in+hall way_in+general_drakkisath junctions+hall junctions+gyth junctions+furnace_door junctions+the_beast junctions+general_drakkisath hall+gyth hall+goraluk_anvilcrack hall+general_drakkisath gyth+banner furnace_door+the_beast furnace_door+general_drakkisath way_in+hall+general_drakkisath junctions+hall+gyth junctions+hall+general_drakkisath junctions+furnace_door+the_beast junctions+furnace_door+general_drakkisath",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "38.31I2.8I1.15I30.", "34.64I27.", "31.71I23.", "28.77I20.", "27.79I19.", "27.79I19.",
				"26.26I10T44I19.", "26.3I3.8I12.9D8T23I1.8I3.2I19.", "27.3I22.17D34.3I19.", "28.1I23.17D35.1I20.",
				"53.17D55.", "55.15D55.", "55.22D48.", "51.26D48.", "51.26D48.", "49.27D49.", "36.1G11.27D50.",
				"35.6G7C2Q21D54.", "34.6G1R8C2Q20D54.", "33.7G1R8C2Q20D54.", "33.7G1R8C2Q20D9.2F43.",
				"34.6G1R8C2Q20D7.6F41.", "34.5G2R8C4Q18D6.7F41.", "35.2G3R10C2Q19D6.7F41.", "34.17C1Q3D2M7D3M4D5.8F41.",
				"33.18C1Q2D3M7D4M3D5.9F40.", "33.18C1X8M2D7M1D1M1B4.9F40.", "33.3J15C1X2M2B9M1B5M2B1F2.8F41.",
				"33.3J15C1X1M6B4M9B1O11F41.", "32.1A4J14C1L21B1O10F41.", "33.3A1J14C1L20B2O10F41.",
				"33.3A2J13C1L20B1O11F41.", "32.5A1J13C1L20B1O11F41.", "33.4A2J12C1Y20B2O9F42.", "33.5A1W12S1Y4P16B2O9F42.",
				"33.1A5K13S2H7P1a10N2O9F42.", "34.27H1V9E1N1Z1U9F42.", "34.27H1V9E1N2Z9F42.", "34.27H1V10E2U9F42.",
				"35.25H2V10E2U9F42.", "35.18H2.5H1.1V10E2U9F42.", "35.18H11.9E10F42.", "35.18H11.9E9F43.", "35.18H72.",
				"35.18H72.", "35.18H72.", "37.15H73.", "37.13H75.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.",
			},
		},
	},
})
