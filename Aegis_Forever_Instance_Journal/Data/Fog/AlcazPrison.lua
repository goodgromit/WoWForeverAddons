local _, ns = ...

--[[ Alcaz Prison's fog: the journal's own pictures (Media/Maps/AlcazPrison.tga and
     AlcazPrisonMaximumSecurity.tga, Santiago Reyes's maps, each under his own frame: the parchment lies only
     inside it and off his credit, the floor's extent, with no shared Frame mask). Pieces are fractions of the
     visible picture, as the boss spots are; each is a mask, Media/Fog/AlcazPrison/<floor>/<piece>.tga, made by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/AlcazPrisonFog/fog_spec.py. The way in (the swirl and its
     stairs down to the crossing), the west stairs down to the Maximum Security Unit and the way back up
     from it are clear at the start;
     each boss clears his wing: the Main Unit once Overseer Wrex, The Questioner and Tidemistress Ca'zass are
     dead, the Maximum Security Unit once Katerina the Cleaner and Blazeroar are, the whole fog with all five. ]]
ns.AddFog("AlcazPrison", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["AlcazPrison"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6289, 0.9239, 0.9766, 0.9751 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.2441, 0.0000, 0.4727, 0.4714 },       -- the swirl, its stairs down and the crossing below them
				west_stairs = { 0.1670, 0.2767, 0.3252, 0.6486 },       -- the west stairs down to the Maximum Security Unit
				overseer_wrex = { 0.3271, 0.0542, 0.8350, 0.6310 },       -- the east wing: the barred gate, the cell block, his hub and the three rooms off it
				the_questioner = { 0.0566, 0.0307, 0.3877, 0.4495 },       -- the west wing: the barred gate, the green room and his octagon
				tidemistress_ca_zass = { 0.1631, 0.3045, 0.5469, 1.0000 },       -- the main corridor south, her hub and its three rooms
				banner = { 0.4268, 0.7877, 0.9980, 0.9634 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "west_stairs", start = true, pieces = { "west_stairs" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "overseer_wrex", boss = "Overseer Wrex", pieces = { "overseer_wrex" }, back = "entrance", way = {} },
				{ id = "the_questioner", boss = "The Questioner", pieces = { "the_questioner" }, back = "entrance", way = {} },
				{ id = "tidemistress_ca_zass", boss = "Tidemistress Ca'zass", pieces = { "tidemistress_ca_zass" }, back = "entrance", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance west_stairs overseer_wrex the_questioner tidemistress_ca_zass banner entrance+overseer_wrex entrance+the_questioner entrance+tidemistress_ca_zass west_stairs+the_questioner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "128.", "39.14A75.", "38.16A74.", "28.8D2.16A74.", "26.11D1.16A74.",
				"26.12D1H15A24.8C42.", "25.13D3H13A24.9C41.", "24.14D3H12A25.9C41.", "24.14D4H11A25.9C41.",
				"24.15D3H10A4.7C2.7C6.9C41.", "24.16D3H8A4.18C5.9C41.", "24.16D4H6A5.18C5.9C41.", "24.17D3H6A5.18C5.9C41.",
				"24.17D3H5A6.18C5.9C41.", "25.17D2H5A6.18C5.9C41.", "26.16D2H5A6.18C5.9C41.", "27.15D2H5A6.18C5.9C41.",
				"28.14D2H5A6.18C4.10C41.", "28.14D2H5A6.18C3.12C40.", "28.13D3H5A6.18C2.14C39.",
				"13.12D3.13D3H5A5.19C1.27C27.", "12.29D3H4A2G52C26.", "12.29D3H3A3G52C26.", "12.29D3H3A3G52C26.",
				"12.29D3H3A3G52C26.", "12.17D6J6D3H3A3G52C26.", "12.16D7J6D3H3A3G52C26.", "12.16D7J7D6I2G52C26.",
				"13.11D4.7B7.7I6.18C2.26C27.", "28.7B7.7E6.18C3.12C40.", "28.7B7.7E6.18C4.10C41.", "28.7B7.7E6.18C5.8C42.",
				"28.7B7.7E6.18C5.9C41.", "28.7B7.7E6.18C5.9C41.", "28.7B7.7E6.18C5.9C41.", "28.7B7.7E6.18C5.9C41.",
				"28.7B7.7E6.18C5.9C41.", "28.7B7.7E6.18C5.9C41.", "28.7B7.7E6.18C5.9C41.", "28.7B7.7E7.6C3.6C7.9C41.",
				"28.7B7.7E29.9C41.", "28.6B8.7E29.9C41.", "29.5B8.7E29.9C41.", "30.3B9.7E29.8C42.", "42.7E79.", "42.7E79.",
				"42.7E79.", "42.7E79.", "42.7E79.", "41.9E78.", "40.11E77.", "39.13E76.", "28.9E1.25E65.", "26.39E63.",
				"26.39E63.", "26.39E63.", "26.39E63.", "26.39E63.", "26.39E63.", "26.39E63.", "26.39E63.", "38.14E76.",
				"40.11E77.", "40.10E78.", "41.9E19.42F17.", "41.9E19.42F17.", "41.9E19.42F17.", "41.9E9.7F2.53F7.",
				"41.9E8.64F6.", "41.9E7.66F5.", "41.9E7.67F4.", "41.9E6.69F3.", "41.9E6.70F2.", "41.9E6.4F4.62F2.",
				"41.9E6.5F4.5F41.6F5.5F1.", "42.8E6.4F63.4F1.", "43.5E10.2F64.1F3.", "128.", "128.", "128.", "128.",
			},
		},
		["AlcazPrisonMaximumSecurity"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6289, 0.8931, 0.9805, 0.9634 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.0400, 0.4173, 0.3623, 0.7467 },       -- the west crossing, where the stairs from the Main Unit come down, and the cell west of it
				katerina = { 0.2510, 0.1640, 0.6045, 0.9517 },       -- the corridors to her hub, the cell at the long corridor's top and the two rooms east
				blazeroar = { 0.5078, 0.4846, 0.8154, 0.9473 },       -- the big room at the far end
				banner = { 0.0371, 0.0878, 0.6084, 0.2635 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "katerina", boss = "Katerina the Cleaner", pieces = { "katerina" }, back = "way_in", way = {} },
				{ id = "blazeroar", boss = "Blazeroar", pieces = { "blazeroar" }, back = "katerina", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "way_in katerina blazeroar banner way_in+katerina katerina+blazeroar",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "19.42D67.", "19.42D67.",
				"12.1D6.42D67.", "9.7D2.53D57.", "8.65D55.", "7.67D54.", "7.68D53.", "6.69D53.", "6.70D52.",
				"6.5D3.8D17.30D1.6D52.", "6.5D5.3D28.6B8.5D6.5D51.", "7.3D36.8B19.4D51.", "9.1D36.8B74.", "46.8B74.",
				"46.8B74.", "46.8B74.", "46.8B74.", "46.8B74.", "46.8B74.", "46.8B74.", "46.8B74.", "46.8B74.", "46.8B74.",
				"47.6B75.", "47.6B75.", "47.6B75.", "47.6B75.", "46.8B74.", "45.10B73.", "45.10B73.", "45.10B73.",
				"45.9B74.", "47.6B75.", "47.6B75.", "14.3A1.6A5.5A13.6B75.", "12.13A3.10A6.9B75.", "12.25A3E13B75.",
				"12.25A3E15B73.", "12.25A3E15B5.8B13.8C39.", "12.25A3E15B4.9B12.10C38.", "12.25A3E14B5.9B10.13C37.",
				"12.26A2E13B6.9B10.13C37.", "13.11A4.7A11.7B6.9B9.15C36.", "28.7A12.6B6.9B9.15C36.",
				"28.7A12.6B6.9B9.16C35.", "29.5A12.8B5.9B6.21C33.", "29.5A11.10B4.9B5.24C31.", "30.3A11.12B3.9B4.26C30.",
				"43.14B2.9B3.28C29.", "43.27B29C29.", "42.28B2F27C29.", "42.28B2F28C28.", "42.28B2F28C28.",
				"42.28B2F28C28.", "42.29B1F28C28.", "42.28B1F28C29.", "43.14B2.9B2.29C29.", "43.14B2.9B3.27C30.",
				"44.12B3.9B4.25C31.", "45.10B4.9B5.23C32.", "47.6B6.9B7.19C34.", "59.9B8.17C35.", "59.9B8.16C36.",
				"59.9B8.16C36.", "59.9B8.16C36.", "59.9B9.15C36.", "59.9B9.14C37.", "60.7B12.11C38.", "128.", "128.",
				"128.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
	},
})
