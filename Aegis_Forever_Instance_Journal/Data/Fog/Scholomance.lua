local _, ns = ...

--[[ Scholomance's fog: its floors, the journal's own pictures (Media/Maps/Classic/Scholomance, Scholomance1, ...).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/Scholomance/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/ScholomanceFog/fog_spec.py, which holds the touch-ups. Each
     floor has its own frame (frame = false: the extent keeps the parchment inside the picture's own frame).
     The Reliquary's way in is the dungeon's entrance; the other floors' are read from the art. ]]
ns.AddFog("Scholomance", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Death Knight Darkreaver"] = false, ["Kirtonos the Herald"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["Scholomance"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3120, 0.4228, 0.5190, 0.7766 },
				hall = { 0.1680, 0.3118, 0.6480, 0.7961 },
				blood_steward_of_kirtonos = { 0.5500, 0.2399, 0.9220, 0.8441 },
				banner = { 0.2310, 0.0315, 0.8100, 0.1889 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "blood_steward_of_kirtonos", boss = "Blood Steward of Kirtonos", pieces = { "blood_steward_of_kirtonos" }, back = "entrance", way = { "hall" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance hall blood_steward_of_kirtonos banner entrance+hall hall+blood_steward_of_kirtonos",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "125.", "125.", "83.7D35.", "40.13D3.4D10.4D3.13D35.", "38.53D34.", "34.63D28.",
				"32.67D26.", "31.69D25.", "30.70D25.", "30.70D25.", "30.3D2.7D38.2D5.7D3.3D25.", "30.3D63.3D26.",
				"31.2D64.1D27.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"82.4C10.3C26.", "75.26C24.", "74.28C23.", "74.28C23.", "74.28C23.", "74.28C23.", "68.2B4.28C23.",
				"27.23B8.16B28C23.", "26.25B6.17B33C18.", "26.26B1.21B35C16.", "26.49B35C15.", "26.49B35C15.",
				"26.49B35C15.", "26.49B35C15.", "26.49B35C15.", "26.49B35C15.", "26.49B35C15.", "26.20B12E17B35C15.",
				"26.19B13E16B2F34C15.", "26.19B14E15B2F34C15.", "26.19B3E8A3E15B2F34C15.", "26.19B3E8A3E15B2F34C15.",
				"26.19B3E8A3E15B2F34C15.", "26.19B3E2A9E15B1F35C15.", "26.19B3E2A8E17B35C15.", "26.19B3E2A3E22B35C15.",
				"26.19B3E2A2E23B35C15.", "26.19B3E2A2E23B35C15.", "26.19B3E2A2E23B35C15.", "26.19B3E2A2E23B35C15.",
				"26.19B3E2A2E23B35C15.", "26.19B7E23B34C16.", "26.19B7E22B29C22.", "26.20B5E1B3.19B28C23.",
				"26.25B5.16B2.28C23.", "27.23B7.5B12.29C22.", "28.6B2.4B18.3B13.29C22.", "74.28C23.", "75.27C23.",
				"75.26C24.", "80.5C8.4C28.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["Scholomance1"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3850, 0.2654, 0.6380, 0.6582 },
				marduk_blackpool = { 0.3450, 0.4273, 0.7140, 1.0000 },
				l_hall = { 0.1850, 0.0960, 0.6160, 0.6627 },
				rattlegore = { 0.1140, 0.5097, 0.4450, 1.0000 },
				chamber = { 0.3450, 0.0000, 0.6190, 0.4348 },
				jandice_barov = { 0.5140, 0.1424, 0.6980, 0.3853 },
				banner = { 0.4430, 0.8351, 0.9820, 0.9805 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "marduk_blackpool", boss = "Marduk Blackpool", pieces = { "marduk_blackpool" }, back = "way_in", way = {} },
				{ id = "vectus", boss = "Vectus", pieces = { "marduk_blackpool" }, back = "way_in", way = {} },
				{ id = "rattlegore", boss = "Rattlegore", pieces = { "rattlegore" }, back = "way_in", way = { "l_hall" } },
				{ id = "jandice_barov", boss = "Jandice Barov", pieces = { "jandice_barov" }, back = "way_in", way = { "chamber", "l_hall" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in marduk_blackpool l_hall rattlegore chamber jandice_barov banner way_in+marduk_blackpool way_in+l_hall way_in+chamber marduk_blackpool+l_hall marduk_blackpool+rattlegore marduk_blackpool+banner l_hall+rattlegore l_hall+chamber chamber+jandice_barov way_in+marduk_blackpool+l_hall way_in+l_hall+chamber marduk_blackpool+l_hall+rattlegore",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "59.6E60.", "58.8E59.", "57.10E58.", "57.10E58.", "57.10E58.", "57.10E58.", "56.11E58.",
				"52.15E58.", "48.19E58.", "48.19E58.", "48.19E58.", "48.23E54.", "48.2O22E53.", "42.6C2O22E53.",
				"41.8C1O22E53.", "40.9C1O22E53.", "39.10C1O20E1P1E8F45.", "39.10C1O20E2P10F43.", "39.10C1O20E1P11F43.",
				"39.10C1O20E1P11F43.", "39.10C1O20E1P11F43.", "39.10C1O20E1P11F43.", "30.6C3.10C1O20E1P11F43.",
				"29.20C1O20E2P10F43.", "28.21C1O21E1P9F44.", "28.21C1O23E2.5F45.", "29.20C1O22E53.", "29.20C1O22E53.",
				"28.21C2O4E14J1R1J1E53.", "28.21C6O16R1A53.", "28.26C3I16A52.", "28.26C3I16A52.", "28.26C3I16A52.",
				"28.26C3I16A52.", "28.26C5I13A53.", "28.27C4I13A53.", "29.26C4I13A53.", "29.27C3I13A53.", "29.27C3I13A53.",
				"29.28C2I13A53.", "29.28C2I14A6B46.", "29.28C2I13A9B44.", "30.27C2I13A10B43.", "35.22C2I13A10B43.",
				"35.22C2I13A11B42.", "35.17C5K14Q1I10B43.", "30.22C2K4B6K8Q10B43.", "29.21N2C1K11B6H10B45.",
				"28.1D20N1S4K26B45.", "28.21D1L30B45.", "28.21D1L30B45.", "28.21D1L30B45.", "28.21D1L30B45.",
				"28.21D1L30B45.", "28.21D1L30B45.", "20.29D1L31B44.", "19.30D1L31B44.", "19.30D1L31B44.", "19.30D1L30B45.",
				"19.30D1L30B45.", "19.30D1L31B44.", "28.21D1L34B41.", "29.20D1L34B41.", "29.20D1L34B41.", "28.21D1L34B41.",
				"28.21D1L34B41.", "29.20D1L34B41.", "29.20D1L24B51.", "29.20D1L24B51.", "30.19D1L24B51.",
				"31.18D1L25B1G26.8G15.", "33.16D1L9B2G3B1M9B39G12.", "33.16D1L8B59G8.", "33.16D1L7B1M61G6.",
				"33.16D1L7B1M63G4.", "33.16D1L7B1M63G4.", "33.16D9B64G3.", "33.16D8B2G2.15G8.1G7.4G2.19G1.4G3.",
				"33.17D1B1.3B1.3G3.1G1.2G36.1G11.2G3.3G3.", "33.17D7.2G60.2G4.", "33.17D75.", "33.16D76.", "125.",
			},
		},
		["Scholomance2"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.5120, 0.4768, 0.7080, 0.7616 },
				jandice_barov = { 0.2190, 0.0255, 0.6290, 0.3943 },
				study = { 0.5040, 0.2534, 0.8510, 0.6567 },
				doctor_theolen_krastinov = { 0.7470, 0.2999, 1.0000, 0.6702 },
				rattlegore = { 0.1700, 0.4018, 0.4660, 1.0000 },
				instructor_malicia = { 0.6370, 0.4993, 0.8150, 0.9130 },
				lorekeeper_polkelt = { 0.6150, 0.0000, 0.8580, 0.4348 },
				banner = { 0.1550, 0.0045, 0.7130, 0.1289 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "jandice_barov", boss = "Jandice Barov", pieces = { "jandice_barov" }, back = "way_in", way = {} },
				{ id = "doctor_theolen_krastinov", boss = "Doctor Theolen Krastinov", pieces = { "doctor_theolen_krastinov" }, back = "way_in", way = { "study" } },
				{ id = "rattlegore", boss = "Rattlegore", pieces = { "rattlegore" }, back = "way_in", way = {} },
				{ id = "instructor_malicia", boss = "Instructor Malicia", pieces = { "instructor_malicia" }, back = "way_in", way = { "study" } },
				{ id = "lorekeeper_polkelt", boss = "Lorekeeper Polkelt", pieces = { "lorekeeper_polkelt" }, back = "way_in", way = { "study" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in jandice_barov study doctor_theolen_krastinov rattlegore instructor_malicia lorekeeper_polkelt banner way_in+study study+doctor_theolen_krastinov study+instructor_malicia study+lorekeeper_polkelt",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "31.6H34.5H49.", "28.51H46.", "26.55H44.", "22.64H39.", "21.66H4.11G23.", "20.68H1.13G23.",
				"20.13H4B28H5B18H14G23.", "21.2H1.8H6B26H7B13H1.2H15G23.", "25.2H5.40B8.3H1.18G23.", "33.40B11.18G23.",
				"33.41B9.19G23.", "33.41B8.17G26.", "33.40B9.17G26.", "34.38B10.16G27.", "34.33B15.16G27.",
				"34.33B16.15G27.", "34.33B15.17G26.", "33.34B15.17G26.", "33.34B16.15G27.", "33.34B16.15G27.",
				"33.34B16.16G26.", "34.33B15.17G26.", "34.33B15.16G27.", "34.33B16.14G28.", "34.33B17.12G29.",
				"34.32B3.16C11G29.", "38.2B5.1B22.17C11G29.", "68.18C7G2L4C26.", "68.19C1L4G2L6C25.",
				"68.18C7L8C5.2D2.3D1.3D8.", "68.33C2.16D6.", "69.32C1.18D5.", "80.21C19D5.", "80.21C19D5.",
				"75.2C2.20C2J21D3.", "74.25C2J22D2.", "73.26C2J22D2.", "73.26C2J23D1.", "35.8E30.26C2J22D2.",
				"35.8E30.26C2J22D2.", "34.10E1.1E27.26C2J21D3.", "27.24E22.26C2J20D4.", "26.26E21.28C20D4.",
				"26.27E20.29C18D5.", "26.27E20.28C2.16D6.", "26.27E20.1C6I21C3.14D7.", "26.27E20.8I6C6K8C4.12D8.",
				"26.27E20.1A7I6C7K6C5.12D8.", "27.26E20.8A3.2C7F2K3C7.12D8.", "27.26E19.9A5.10F9.12D8.",
				"26.27E18.10A5.10F29.", "26.27E18.10A4.11F29.", "26.27E18.10A4.11F29.", "27.26E19.9A4.12F28.",
				"26.27E19.9A4.12F28.", "26.27E21.5A6.12F28.", "26.27E32.12F28.", "26.27E32.12F28.", "27.26E31.13F28.",
				"26.27E32.12F28.", "26.27E32.12F28.", "26.27E32.12F28.", "26.27E32.12F28.", "26.27E32.12F28.",
				"27.26E32.12F28.", "27.25E33.12F28.", "29.19E37.11F29.", "31.17E38.10F29.", "31.17E40.6F31.",
				"31.17E41.4F32.", "31.17E42.2F33.", "31.17E77.", "31.18E76.", "31.17E77.", "31.17E77.", "31.18E76.",
				"31.18E76.", "32.16E77.", "33.14E78.", "125.", "125.", "125.", "125.",
			},
		},
		["Scholomance3"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3950, 0.4543, 0.5710, 0.7271 },
				lab_corridor = { 0.3310, 0.4933, 0.5120, 0.7106 },
				ras_frostwhisper = { 0.3000, 0.5637, 0.5970, 1.0000 },
				darkmaster_gandling_hall = { 0.5610, 0.1439, 0.7850, 0.4573 },
				the_ravenian = { 0.4890, 0.3073, 0.7780, 0.6402 },
				lady_illucia_barov = { 0.5880, 0.0000, 0.8420, 0.2984 },
				lord_alexei_barov = { 0.6830, 0.1694, 0.9420, 0.4753 },
				darkmaster_gandling = { 0.5900, 0.1769, 0.7570, 0.4273 },
				banner = { 0.0800, 0.0225, 0.6420, 0.1649 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "ras_frostwhisper", boss = "Ras Frostwhisper", pieces = { "ras_frostwhisper" }, back = "way_in", way = { "lab_corridor" } },
				{ id = "the_ravenian", boss = "The Ravenian", pieces = { "the_ravenian" }, back = "way_in", way = { "darkmaster_gandling_hall" } },
				{ id = "lady_illucia_barov", boss = "Lady Illucia Barov", pieces = { "lady_illucia_barov" }, back = "way_in", way = { "darkmaster_gandling_hall" } },
				{ id = "lord_alexei_barov", boss = "Lord Alexei Barov", pieces = { "lord_alexei_barov" }, back = "way_in", way = { "darkmaster_gandling_hall" } },
				{ id = "darkmaster_gandling", boss = "Darkmaster Gandling", pieces = { "darkmaster_gandling" }, back = "way_in", way = { "darkmaster_gandling_hall" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in lab_corridor ras_frostwhisper darkmaster_gandling_hall the_ravenian lady_illucia_barov lord_alexei_barov darkmaster_gandling banner way_in+lab_corridor lab_corridor+ras_frostwhisper darkmaster_gandling_hall+the_ravenian darkmaster_gandling_hall+lady_illucia_barov darkmaster_gandling_hall+lord_alexei_barov darkmaster_gandling_hall+darkmaster_gandling lady_illucia_barov+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "82.4F39.", "80.8F37.", "21.13I24.13I9.8F37.", "19.55I6.19F26.", "15.62I3.20F25.", "13.65I1.21F25.",
				"12.66I1P21F25.", "11.68I21F25.", "11.68I21F25.", "11.3I2.10I42.7I3.1I21F25.", "11.3I64.12F35.",
				"12.2I65.10F36.", "79.10F36.", "79.11F35.", "79.11F35.", "79.11F35.", "77.2D9F1M1D35.", "76.3D10M3D33.",
				"75.5D9M4D1.3G7.1G20.", "75.8D2O6D2N15G17.", "75.6D6O4D1N16G17.", "75.5D3O3H2O3D1N16G17.",
				"75.5D2O5H2O2D1N16G17.", "76.3D2O6H2O2D1N16G17.", "76.3D2O7H1O2D1N16G17.", "76.3D2O6H2O2D1N16G17.",
				"75.5D2O5H2O2D1N20G13.", "75.5D3O2H3O3D1N21G12.", "75.6D6O4D2N20G12.", "75.9D1O8D20G12.",
				"76.2D13L2D6.14G12.", "77.15L7.14G12.", "76.1E1L13E8.14G12.", "66.24E10.12G13.", "66.24E35.", "66.25E34.",
				"66.26E33.", "66.26E33.", "66.26E33.", "76.16E33.", "77.15E33.", "77.15E33.", "77.15E33.", "78.14E33.",
				"58.5A17.9E36.", "51.3B2.1B7A16.9E36.", "48.8B3J5A17.7E37.", "47.9B3J5A18.5E38.", "46.10B3J5A61.",
				"46.10B3J6A60.", "46.10B3J5A61.", "46.10B3J5A61.", "44.4C8K1B2J4A62.", "43.15C67.", "43.15C67.",
				"43.16C66.", "43.16C66.", "43.15C67.", "43.15C67.", "43.15C67.", "43.16C66.", "43.16C66.", "43.16C66.",
				"43.26C56.", "43.27C55.", "43.27C55.", "43.27C55.", "43.27C55.", "43.26C56.", "43.16C66.", "43.16C66.",
				"43.16C66.", "43.16C66.", "43.16C66.", "43.16C66.", "43.16C66.", "43.16C66.", "43.16C66.", "43.16C66.",
				"43.16C66.", "43.16C66.", "44.15C66.", "125.",
			},
		},
	},
})
