local _, ns = ...

--[[ Dire Maul: Capital Gardens' fog: its three floors as the journal draws them, the journal's own pictures
     (Media/Maps/Classic/DireMaulWest.blp, DireMaulWest1.blp, DireMaulWest2.blp: the Capital Gardens, the
     Court of the Highborne, the Prison of Immol'thar), traced from the pictures. Pieces are fractions of the
     visible picture, as the boss spots are; each is a mask, Media/Fog/DireMaulWest/<floor>/<piece>.tga, split
     into rooms by Dev/maps/FogBuilder/fogbuild.py from Dev/maps/DireMaulWestFog/fog_spec.py. Every boss's way
     runs back to the floor's way in. ]]
ns.AddFog("DireMaulWest", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["DireMaulWest"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.8260, 0.2849, 1.0000, 0.9400 },       -- the portal bay, both swirls
				gardens = { 0.4130, 0.0405, 0.9540, 1.0000 },       -- the gardens' hall round the pool, and the passage between it and the gallery: both kills' way
				tendris_warpwood = { 0.2010, 0.2564, 0.5120, 0.8081 },       -- his building: the gallery, his room and its stairs
				illyanna_ravenoak = { 0.0660, 0.0375, 0.5820, 1.0000 },       -- the court round the gallery (her spot in its south-west corner)
				banner = { 0.2330, 0.0000, 0.8070, 0.1379 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "tendris_warpwood", boss = "Tendris Warpwood", pieces = { "tendris_warpwood" }, back = "entrance", way = { "gardens" } },
				{ id = "illyanna_ravenoak", boss = "Illyanna Ravenoak", pieces = { "illyanna_ravenoak" }, back = "entrance", way = { "gardens" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance gardens tendris_warpwood illyanna_ravenoak banner entrance+gardens gardens+tendris_warpwood gardens+illyanna_ravenoak gardens+banner tendris_warpwood+illyanna_ravenoak illyanna_ravenoak+banner gardens+tendris_warpwood+illyanna_ravenoak gardens+illyanna_ravenoak+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"43.1E41.1E39.", "40.50E35.", "37.55E33.", "34.62E29.", "32.66E27.", "31.2E33K30I3E26.", "30.33K6M31I25.",
				"29.1D4K1D28K7M30I1B24.", "28.2D3K3D3K24D7H7B4I8B5I3B3I2B23.", "27.4D2K31D5H28B2I6B20.",
				"15.17D1K32D3H29B1I15B12.", "14.52D1H47B11.", "14.52D1H47B11.", "14.52D1H47B11.", "14.52D1H47B11.",
				"14.52D1H47B11.", "14.52D1H47B11.", "14.52D1H47B11.", "14.52D1H47B11.", "14.52D1H47B11.", "14.52D1H47B11.",
				"14.52D1H47B11.", "13.44D7H2D1H47B11.", "14.43D7H2D1H47B11.", "14.43D2H3B2H2D1H47B11.",
				"14.43D2H3B5H47B11.", "14.43D2H4B4H47B11.", "14.16D27J2L55B11.", "13.17D3J24C2G55B11.",
				"13.17D2J25C2G55B11.", "14.16D2J25C2G53B1F1B11.", "13.17D2J25C2G52B3F11.", "13.17D2J25C2G51B4F6A5.",
				"13.17D2J25C2G51B3F8A4.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.",
				"13.17D2J25C2G51B2F10A3.", "14.16D2J25C2G51B2F10A3.", "14.16D2J25C2G51B2F10A3.", "14.16D2J25C2G51B2F10A3.",
				"13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F9A4.", "13.17D2J25C2G51B2F9A4.", "13.17D2J25C2G51B2F10A3.",
				"13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.",
				"13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "14.16D2J25C2G51B2F10A3.",
				"13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.",
				"13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F10A3.", "13.17D2J25C2G51B2F9A4.", "14.16D2J25C2G51B2F9A4.",
				"13.17D27J2L51B2F10A3.", "13.18D26J1L1H4B4H43B2F10A3.", "13.44D2H3B5H43B2F10A3.",
				"13.44D2H3B2H2D1H43B2F10A3.", "13.44D7H2D1H43B2F10A3.", "13.44D7H2D1H43B2F10A3.", "13.53D1H43B2F10A3.",
				"13.53D1H43B2F10A3.", "13.53D1H43B3F9A3.", "13.53D1H43B4F8A3.", "13.53D1H44B3F7A4.", "13.53D1H47B11.",
				"13.53D1H47B11.", "13.53D1H47B11.", "13.53D1H47B11.", "13.53D1H47B11.", "14.52D1H47B11.", "14.52D1H46B12.",
				"16.49D1.1D29B2.7B1.6B13.", "125.", "125.", "125.", "125.",
			},
		},
		["DireMaulWest1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.4290, 0.0000, 0.7030, 0.3928 },
				top_hall = { 0.2110, 0.0315, 0.5440, 0.3658 },       -- the north gallery and its stairwell, Tsu'zee's corner too (a rare holds no fog): Kalendris's way
				magister_kalendris = { 0.2070, 0.2009, 0.6090, 1.0000 },       -- the west and south galleries
				banner = { 0.2200, 0.0045, 0.7950, 0.1349 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "magister_kalendris", boss = "Magister Kalendris", pieces = { "magister_kalendris" }, back = "way_in", way = { "top_hall" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in top_hall magister_kalendris banner way_in+top_hall way_in+banner top_hall+magister_kalendris top_hall+banner way_in+top_hall+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "38.51D36.", "35.56D34.", "31.64D30.", "30.3D2H2D3H9D1H9D2H36D28.", "29.2D33H34D27.",
				"29.1D31H4I15F18D27.", "28.1D3H2B15H10B1H2E6A4F6A3F12D2.3D27.", "29.2H30B2E18A9.2D3.3D27.",
				"29.3H28B3E18A14.3D27.", "29.31B3E18A44.", "30.30B3E18A44.", "31.29B3E18A44.", "31.29B3E18A44.",
				"31.29B3E18A44.", "31.29B3E18A44.", "31.29B3E18A44.", "31.29B3E18A44.", "31.29B3E18A44.", "31.29B3E18A44.",
				"31.29B3E18A44.", "31.29B3E18A44.", "31.21G8B3E18A44.", "31.22G7B3E18A44.", "32.19C2G7B3E17A45.",
				"33.20C8B1E17A46.", "33.20C72.", "33.20C72.", "33.20C72.", "33.20C72.", "33.20C72.", "33.20C72.",
				"33.20C72.", "33.20C72.", "33.20C72.", "33.20C72.", "33.21C71.", "33.21C71.", "33.21C71.", "33.21C71.",
				"33.21C71.", "33.21C71.", "33.21C71.", "33.21C71.", "33.21C71.", "33.20C72.", "33.21C71.", "33.21C71.",
				"33.21C71.", "33.21C71.", "33.21C71.", "33.21C71.", "33.20C72.", "33.21C71.", "33.21C71.", "33.21C71.",
				"33.21C71.", "33.21C71.", "32.38C55.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.",
				"31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.",
				"31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "31.40C54.", "32.38C55.", "125.", "125.",
				"125.", "125.", "125.",
			},
		},
		["DireMaulWest2"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.6280, 0.2594, 0.8210, 0.5547 },
				prison_hall = { 0.0540, 0.1349, 0.6880, 0.9595 },       -- the prison's floor round the dais: both kills' way
				passage = { 0.5430, 0.2159, 0.8180, 0.7106 },       -- the passage in to the prison, and the rock between it and the Athenaeum: both kills' way
				prince_tortheldrin = { 0.4990, 0.0000, 0.9250, 0.4618 },       -- the Athenaeum and the ramp up to it from the prison
				immol_thar = { 0.1980, 0.3493, 0.5020, 0.8051 },       -- the dais (a pocket: Prince Tortheldrin's way crosses the prison round it)
				banner = { 0.2270, 0.8501, 0.8010, 0.9955 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "prince_tortheldrin", boss = "Prince Tortheldrin", pieces = { "prince_tortheldrin" }, back = "way_in", way = { "prison_hall", "passage" } },
				{ id = "immol_thar", boss = "Immol'thar", pieces = { "immol_thar" }, back = "way_in", way = { "prison_hall", "passage" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in prison_hall passage prince_tortheldrin immol_thar banner way_in+passage prison_hall+passage prison_hall+prince_tortheldrin prison_hall+immol_thar prison_hall+banner passage+prince_tortheldrin prison_hall+passage+prince_tortheldrin",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "125.", "125.", "71.3D4.2D4.2D3.1D3.1D2.12D17.", "70.40D15.", "69.41D15.", "69.41D15.",
				"69.42D14.", "69.42D14.", "69.42D14.", "69.41D15.", "68.43D14.", "69.42D14.", "69.41D15.", "69.41D15.",
				"39.2B28.41D15.", "36.9B1.1B1.1B3.6B11.41D15.", "35.25B9.41D15.", "33.29B6.42D15.", "32.31B5.42D15.",
				"30.35B3.42D15.", "29.38B1.43D14.", "27.41B1I13D2L26D15.", "26.42B1I12D4L25D15.", "24.44B1I8D5L2C11L15D15.",
				"21.47B2I6D5L4C1L1C8L14D16.", "20.48B2I6D2L16C3L4D3.1D1.2D17.", "19.50B2I5D2L9C6G2C2L28.",
				"18.51B2I4D2L9C9G1C1L28.", "18.52B2I2D2L9C11G1C28.", "18.52B3I2L10C3G6A1G1A29.", "18.53B2I2M10C3G7A30.",
				"18.56B2H9C3G7A30.", "17.57B2H10C3G7A29.", "17.20B14J24B1H10C4G6A29.", "16.19B3J12E2J23B2H10C4G5A29.",
				"16.19B2J14E2J22B2H11C5G2A30.", "16.18B2J16E2J22B1H12C5G31.", "15.18B2J18E2J21B2H12C4G31.",
				"15.17B2J20E2J20B2H15C32.", "14.17B2J22E2J20B2H13C33.", "14.16B2J24E1J20B2H13C33.",
				"14.16B2J24E1J19B2H14C33.", "13.17B2J24E1J19B2H14C33.", "12.18B2J24E1J19B2H14C33.",
				"12.18B2J24E1J19B2H14C33.", "12.18B2J24E1J19B2H14C33.", "12.18B2J24E1J19B2H13C34.",
				"12.18B2J24E1J19B2H12C35.", "12.18B2J24E1J19B3H10C36.", "13.17B2J24E1J20B2H9C37.",
				"14.16B2J24E1J21B2H7C38.", "14.16B2J24E1J21B3H5C39.", "15.15B2J23E2J24B44.", "15.16B2J21E3J24B44.",
				"15.17B2J19E3J24B45.", "16.17B2J17E3J25B45.", "16.18B2J15E3J26B45.", "17.18B2J13E3J26B46.",
				"17.19B2J11E3J27B46.", "17.20B14J27B47.", "18.60B47.", "18.59B48.", "18.59B48.", "18.58B49.", "18.57B50.",
				"18.56B51.", "19.55B51.", "20.53B52.", "20.52B53.", "24.48B53.", "26.46B12.2F39.", "27.12B34K17F35.",
				"29.8B35K20F1.1F31.", "29.4B6K14F2K6F10K26F28.", "29.2B7K60F27.", "30.7K62F26.", "30.4K65F26.", "29.70F26.",
				"29.3F3.4F1.1F48.5F2.3F26.", "30.3F63.3F26.", "31.1F64.2F27.", "125.",
			},
		},
	},
})
