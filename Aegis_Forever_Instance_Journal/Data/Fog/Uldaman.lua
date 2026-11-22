local _, ns = ...

--[[ Uldaman's fog: the journal's own pictures of its two floors (Media/Maps/Classic/Uldaman.blp and
     Uldaman1.blp: the client's map scaled to 1000 x 667, the visible part Data/Instances must draw,
     artRight = 1000 / 1024, artBottom = 667 / 1024). Pieces are fractions of the visible picture, as the
     boss spots are; each is a mask, Media/Fog/Uldaman/<floor>/<piece>.tga, traced from the picture and
     split into rooms by Dev/maps/FogBuilder/fogbuild.py from Dev/maps/UldamanFog/fog_spec.py. ]]
ns.AddFog("Uldaman", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["Uldaman"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.4550, 0.4888, 0.7500, 0.9475 },       -- the Hall of the Keepers but its west wing's middle, and the stub of the passage to Dig Two
				back_door = { 0.1940, 0.5607, 0.3970, 0.9145 },       -- the back way in: the swirl under Echomok Cavern and the rock lobe south of it
				eric = { 0.4460, 0.7661, 0.6970, 1.0000 },       -- Dig Two and its passage: the Lost Dwarves' room (one fight)
				map_chamber = { 0.3280, 0.5262, 0.5560, 0.9070 },       -- the Map Chamber and its name
				ironaya = { 0.2980, 0.6237, 0.4520, 0.8531 },
				caves = { 0.2340, 0.1364, 0.5610, 0.7586 },       -- the caves between the Map Chamber and the rooms (one piece)
				ancient_stone_keeper = { 0.3720, 0.2669, 0.5750, 0.6207 },
				grimlok = { 0.1510, 0.0585, 0.3560, 0.3703 },
				revelosh = { 0.4520, 0.5757, 0.6130, 0.8786 },       -- the west wing's middle, his cross room and the corridor to the Map Chamber
				obsidian_sentinel = { 0.1460, 0.4498, 0.4190, 0.7586 },
				galgann_firehammer = { 0.1940, 0.1319, 0.3780, 0.4978 },
				archaedas = { 0.3190, 0.0000, 0.6020, 0.3913 },
				banner = { 0.5320, 0.0540, 0.9410, 0.2069 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "back_door", start = true, pieces = { "back_door" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "eric", boss = "Eric \"The Swift\"", pieces = { "eric" }, back = "entrance", way = { "entrance" } },
				{ id = "olaf", boss = "Olaf", pieces = { "eric" }, back = "entrance", way = { "entrance" } },
				{ id = "ironaya", boss = "Ironaya", pieces = { "ironaya" }, back = "revelosh", way = { "map_chamber" } },
				{ id = "ancient_stone_keeper", boss = "Ancient Stone Keeper", pieces = { "ancient_stone_keeper" }, back = "revelosh", way = { "caves", "map_chamber" } },
				{ id = "grimlok", boss = "Grimlok", pieces = { "grimlok" }, back = "revelosh", way = { "caves", "map_chamber" } },
				{ id = "baelog", boss = "Baelog", pieces = { "eric" }, back = "entrance", way = { "entrance" } },
				{ id = "revelosh", boss = "Revelosh", pieces = { "revelosh" }, back = "entrance", way = {} },
				{ id = "obsidian_sentinel", boss = "Obsidian Sentinel", pieces = { "obsidian_sentinel" }, back = "revelosh", way = { "caves", "map_chamber" } },
				{ id = "galgann_firehammer", boss = "Galgann Firehammer", pieces = { "galgann_firehammer" }, back = "revelosh", way = { "caves", "map_chamber" } },
				{ id = "archaedas", boss = "Archaedas", pieces = { "archaedas" }, back = "revelosh", way = { "caves", "map_chamber" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance back_door eric map_chamber ironaya caves ancient_stone_keeper grimlok revelosh obsidian_sentinel galgann_firehammer archaedas banner entrance+eric entrance+revelosh back_door+obsidian_sentinel map_chamber+ironaya map_chamber+caves map_chamber+revelosh caves+ancient_stone_keeper caves+obsidian_sentinel caves+galgann_firehammer caves+archaedas grimlok+galgann_firehammer caves+grimlok+galgann_firehammer",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "54.4L67.", "52.7L66.", "49.10L66.", "47.13L65.", "46.14L11.1M2.2M6.1M18.2M22.",
				"45.16L7.9M1.9M10.8M20.", "45.16L6.41M17.", "45.16L7.42M15.", "45.17L8.45M10.", "30.3H13.16L7.47M9.",
				"29.5H12.16L6.48M9.", "26.11H9.17L5.48M9.", "26.11H9.17L4.4M2.17M1.2M1.18M1.4M8.",
				"26.12H7.19L3.3M3.2M1.1M31.3M3.3M8.", "27.12H6.19L4.3M42.3M9.", "26.12H1X2F5.19L60.",
				"25.12H1X1Y4F3.19L60.", "24.13H2Y5F2.1F20L58.", "24.12H2Y11F4L4W11L57.", "24.10H2X1Y1V12F1L10W7L57.",
				"24.10H2X3V18F5W7L56.", "24.9H2X2K2V21F1W9L55.", "24.8H2X4K2V20F1W9L55.", "24.7H2X6K1V20F2W7L56.",
				"26.4H1K1X7K1V21F2W62.", "29.10K1V21F1W1F62.", "29.9K2V23F62.", "29.9K2V18F1T3F63.", "29.8K2V14F6T2F64.",
				"29.8K4V11F3T11G59.", "30.9K2V11F3T11G59.", "30.10K2V10F3T11G59.", "30.9K2V12F3T10G59.",
				"30.7K2V15F2T9G60.", "34.1F2V17F2T9G60.", "34.20F2T9G60.", "34.20F2T9G60.", "35.19F2T9G60.",
				"35.19F2T9G60.", "35.19F2T9G60.", "35.19F2T10G59.", "37.17F2T10G59.", "38.1F1U15F6T4G60.",
				"24.15J1U18F5T2G60.", "24.15J1U22F3T60.", "33.5J3U22F1T61.", "32.7J2U23F61.", "32.7J2U23F8.4A49.",
				"32.8J1U24F6.11A43.", "32.8J2U10F7R6F1.1A1.15A42.", "31.10J4U6F5R1D2R6F19A41.", "32.11J4U5F1R5D2R4F21A40.",
				"32.13J2U5F1R6D3R2F21A40.", "33.5J2P5J2U5F2R6D2R2S7O14A40.", "32.1B8P4J2U5F2R8D2S6I1O14A40.",
				"32.6B4P3J2U4F2R9D1S7I1O14A40.", "31.8B3P3J2U3F2R10D1S7I1O14A40.", "31.12B7E12D1S7I1O15A39.",
				"32.11B7E1Q11D1S7I1O15A39.", "32.10B8E1Q11D1S7I1O16A38.", "33.9B8E1Q11D1S7I1O16A38.",
				"34.8B8E1Q11D1S7I1O15A39.", "33.9B8E1Q11D1S7I1O15A39.", "32.9B2.5E3Q11D1S7I1O14A40.",
				"32.9B3.3E3Q12D2S6I1O14A40.", "31.9B7.2Q13D1S7I1O14A40.", "32.7B8.12D5.7O14A40.", "32.5B10.13D4.21A40.",
				"33.2B12.12D5.9A2N10A40.", "56.1D8.4A7N8A41.", "68.8N7A42.", "69.4N6C2A44.", "68.13C44.", "67.14C44.",
				"63.19C43.", "61.21C43.", "61.21C43.", "62.19C44.", "68.13C44.", "68.12C45.", "69.10C46.", "70.6C49.",
				"125.",
			},
		},
		["Uldaman1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.5600, 0.2969, 0.7490, 0.5757 },
				ramp = { 0.5000, 0.4033, 0.7710, 0.7691 },       -- the hall down from the way in, the ledge beside it and the cross room before the chamber
				archaedas = { 0.4120, 0.2099, 0.6780, 0.6912 },
				banner = { 0.5320, 0.0540, 0.9410, 0.2069 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "archaedas", boss = "Archaedas", pieces = { "archaedas" }, back = "way_in", way = { "ramp" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in ramp archaedas banner way_in+ramp way_in+archaedas ramp+archaedas way_in+ramp+archaedas",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "125.", "125.", "125.", "70.2D1.3D25.2D22.", "69.8D1.9D10.9D19.", "68.39D18.", "68.42D15.",
				"70.44D11.", "69.46D10.", "68.48D9.", "68.49D8.", "67.4D2.17D1.2D1.18D1.4D8.", "68.2D3.4D31.3D3.3D8.",
				"68.3D42.3D9.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "61.6C58.", "60.8C57.", "58.11C56.",
				"57.12C56.", "57.13C55.", "57.13C55.", "57.14C54.", "56.14C55.", "57.13C55.", "57.16C8.2A42.",
				"58.17C3.7A40.", "58.19C1.8A39.", "59.18C1.8A39.", "60.18C8A39.", "60.18C1F7A39.", "59.19C1F7A39.",
				"59.19C1H8E38.", "59.19C1G8E1B37.", "58.20C1G8E1B37.", "58.20C1G9B37.", "58.20C1G10B36.", "58.20C1G10B36.",
				"58.19C2G11B35.", "58.19C2G11B35.", "58.19C2G12B34.", "60.17C2G12B34.", "61.15C2G13B34.",
				"62.7C2G2C4G14B34.", "63.5C8G14B35.", "65.3C2G18B37.", "67.19B39.", "67.16B42.", "67.14B44.", "68.12B45.",
				"68.11B46.", "69.8B48.", "71.4B50.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.",
			},
		},
	},
})
