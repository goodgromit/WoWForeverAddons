local _, ns = ...

--[[ The Deadmines' fog: its three floors as the journal draws them (Media/Maps/Dungeons/): the-deadmines-full,
     the whole dungeon's map, traced from the picture; the-deadmines-1 and the-deadmines-2, the client's maps 291
     and 292, traced from the game's own tiles. Pieces are fractions of the visible picture, as the boss spots are;
     each is a mask, Media/Fog/TheDeadmines/<floor>/<piece>.tga, split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/DeadminesFog/fog_spec.py. Each boss's way runs back to the
     boss before him (the doors keep the run's order); Gilnid has a room on the mine's map (the foundry's
     gallery) though his spot is on the cove's. ]]
ns.AddFog("TheDeadmines", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["the-deadmines-full"] = {
			extent = true,              -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = { { 0.2794, 0.8832, 0.5689, 0.9281 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.0000, 0.0000, 0.2096, 0.4251 },
				tunnels = { 0.0120, 0.2365, 0.2445, 0.5823 },
				rhahk_zor = { 0.0758, 0.4057, 0.2754, 0.6527 },
				junction = { 0.1677, 0.3353, 0.4182, 0.7560 },
				sneed = { 0.0908, 0.5958, 0.3812, 0.8907 },
				foundry_passage = { 0.2585, 0.5674, 0.4960, 0.8847 },
				gilnid = { 0.2126, 0.3922, 0.5619, 0.7919 },
				cove = { 0.4501, 0.0000, 1.0000, 0.6707 },
				tunnel = { 0.3134, 0.2320, 0.5609, 0.5389 },
				mr_smite = { 0.6297, 0.0000, 0.7934, 0.2395 },
				ship_deck = { 0.6317, 0.0015, 0.8772, 0.4805 },
				captain_greenskin = { 0.6756, 0.0988, 0.8383, 0.3249 },
				edwin_vancleef = { 0.6756, 0.1781, 0.8373, 0.4042 },
				cookie = { 0.7315, 0.1347, 0.9232, 0.3787 },
				banner = { 0.1357, 0.0180, 0.5559, 0.1617 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "rhahk_zor", boss = "Rhahk'Zor", pieces = { "rhahk_zor" }, back = "entrance", way = { "tunnels" } },
				{ id = "sneed", boss = "Sneed", pieces = { "sneed" }, back = "rhahk_zor", way = { "junction" } },
				{ id = "sneed_s_shredder", boss = "Sneed's Shredder", pieces = { "sneed" }, back = "rhahk_zor", way = { "junction" } },
				{ id = "gilnid", boss = "Gilnid", pieces = { "gilnid" }, back = "sneed", way = { "foundry_passage" } },
				{ id = "mr_smite", boss = "Mr. Smite", pieces = { "mr_smite" }, back = "gilnid", way = { "cove", "tunnel" } },
				{ id = "captain_greenskin", boss = "Captain Greenskin", pieces = { "captain_greenskin" }, back = "mr_smite", way = { "ship_deck", "cove" } },
				{ id = "edwin_vancleef", boss = "Edwin VanCleef", pieces = { "edwin_vancleef" }, back = "mr_smite", way = { "ship_deck", "cove" } },
				{ id = "cookie", boss = "Cookie", pieces = { "cookie" }, back = "mr_smite", way = { "ship_deck", "cove" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance tunnels rhahk_zor junction sneed foundry_passage gilnid cove tunnel mr_smite ship_deck captain_greenskin edwin_vancleef cookie banner entrance+tunnels entrance+banner tunnels+rhahk_zor rhahk_zor+junction junction+sneed junction+gilnid junction+tunnel sneed+foundry_passage sneed+gilnid foundry_passage+gilnid gilnid+tunnel cove+tunnel cove+mr_smite cove+ship_deck cove+cookie cove+banner mr_smite+ship_deck ship_deck+captain_greenskin ship_deck+edwin_vancleef ship_deck+cookie captain_greenskin+edwin_vancleef captain_greenskin+cookie edwin_vancleef+cookie junction+sneed+gilnid junction+gilnid+tunnel sneed+foundry_passage+gilnid cove+mr_smite+ship_deck cove+ship_deck+cookie ship_deck+captain_greenskin+edwin_vancleef ship_deck+captain_greenskin+cookie ship_deck+edwin_vancleef+cookie captain_greenskin+edwin_vancleef+cookie",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "79.1H46.", "31.1O44.16H34.", "28.31O6.3O1e29H28.", "28.33O3.3O2e36H6.9H6.",
				"22.4O2.39O2e18H5b29H5.", "20.47O1e18H3b2J2b1H3c24H5.", "8.10A1.48O1e17H2b5J1b1p3c24H5.",
				"7.11A49O1e17H1b7J2p4c22H5.", "7.11A1Q3O1.44O1e17H1b7J2f2K3c22H4.",
				"7.11A1Q2O3.4O28.7O3.2e17H1b7J2f4K2c21H4.", "7.12A2O44.3e17H2b6J1f6K2c21H3.",
				"7.11A46.2H1e18H3b4J2f7K2c20H3.", "7.9A48.22H1b2p4f9K2c20H2.", "6.10A48.23H1c1p2f1K7g3K2c20H2.",
				"6.10A48.22H2c3K2g4L2g4K2c19H2.", "6.11A46.23H2c3K2g5L2g3K2c19H2.", "3.15A45.23H2c3K1g6L1g1s4i1q19H2.",
				"2.16A45.23H1c4K1g7L1k4N6d14H2.", "2.17A44.23H1c3K2g7L1k4N7d13H2.", "2.17A43.24H1c3K1g1r7j1k9N2d12H3.",
				"2.17A43.24H1c3K1h1r7j1u3N8d12H3.", "5.14A43.23H2c3K2h7M1l3N2d17H4.", "6.12A44.23H2c4K1h6M2l3N1d18H4.",
				"7.11A43.1I23H2c4K2h5M2l2N2d18H4.", "7.11A1.3B37.3I2a21H2c4K2h4M1h1t3i2q18H4.",
				"7.4P7A6B35.4I2a20H2c5K2h2M3h3K2c18H4.", "7.11P7B30.8I2a21H2c5K5h3K2c19H4.",
				"7.10P9B28.10I1a21H2c7K1h4K3c19H4.", "7.19B25.13I2a21H2c11K2c20H4.", "7.18B23.17I2.3H2.15H2c10K2c20H5.",
				"8.17B21.18I9.13H2c10K2c21H5.", "8.17B20.18I11.13H2c1K10c21H5.", "9.15B14.4D3.17I12.14H10c23H5.",
				"11.10B15.7D2.17I13.13H3c30H5.", "11.9B14.11D2V13I15.45H6.", "11.7B15.12D2V6I22.43H8.",
				"11.6B15.13D2V6I22.42H9.", "11.7B14.13D1V1n4Z1I23.41H10.", "12.7B4C8.5D10U1n4Z3G21.35H16.",
				"12.6B1R8C1.8D11U8G19.35H17.", "12.4B3R9C1S6D2U28G9.34H18.", "13.2B3R10C1S6D2U28G10.33H18.",
				"14.1B1R12C1S6D2U28G11.32H18.", "16.12C1S7D2U27G11.32H18.", "17.11C1S7D2U27G12.31H18.",
				"17.11C1S7D2U20G18.31H19.", "18.11C7D3U19G19.6H1.22H20.", "18.11C8D2U18G22.1H4.12H6.3H21.",
				"21.3C1.3C9D2U18G27.12H30.", "27.7D5U18G29.9H31.", "27.6D5U17G71.", "27.5D3U19G72.", "27.5D2U13G4Y2G73.",
				"26.7D2U10G7Y1F73.", "26.2D1T4D2U9G2Y7F73.", "27.3T2D2U10G2Y7F73.", "27.2E3T2m1G3X2o4G2Y6F74.",
				"27.5E4X3E2o4G2Y6F73.", "27.6E2X4E1W2o5Y7F72.", "17.24E2o4Y8F71.", "17.24E1W14F70.", "17.24E1W15F69.",
				"18.23E1W15F69.", "27.14E1W16F68.", "27.14E1W15F69.", "27.15E15F69.", "27.14E6.10F69.", "27.14E9.6F70.",
				"29.1E7.2E87.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
				"126.", "126.", "126.",
			},
		},
		["the-deadmines-1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.1627, 0.0015, 0.3872, 0.2740 },
				tunnels = { 0.1327, 0.0883, 0.4421, 0.6677 },
				rhahk_zor = { 0.2605, 0.4731, 0.4790, 0.7590 },
				junction = { 0.3623, 0.3967, 0.6068, 0.8787 },
				sneed = { 0.2804, 0.7186, 0.5898, 1.0000 },
				foundry_passage = { 0.4920, 0.6766, 0.7305, 1.0000 },
				gilnid = { 0.4182, 0.4266, 0.7325, 0.9147 },
				banner = { 0.3273, 0.0180, 0.7435, 0.1692 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "rhahk_zor", boss = "Rhahk'Zor", pieces = { "rhahk_zor" }, back = "entrance", way = { "tunnels" } },
				{ id = "sneed", boss = "Sneed", pieces = { "sneed" }, back = "rhahk_zor", way = { "junction" } },
				{ id = "sneed_s_shredder", boss = "Sneed's Shredder", pieces = { "sneed" }, back = "rhahk_zor", way = { "junction" } },
				{ id = "gilnid", boss = "Gilnid", pieces = { "gilnid" }, back = "sneed", way = { "foundry_passage" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance tunnels rhahk_zor junction sneed foundry_passage gilnid banner entrance+tunnels tunnels+rhahk_zor rhahk_zor+junction junction+sneed junction+gilnid sneed+foundry_passage sneed+gilnid foundry_passage+gilnid junction+sneed+gilnid sneed+foundry_passage+gilnid",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "56.2H20.2H46.", "53.30H43.", "51.34H41.", "43.3H1.42H37.", "42.49H35.", "30.2A10.49H35.",
				"29.8A1.2A3.49H34.", "28.13A2.50H33.", "27.15A1.10H29.5H3.3H33.", "27.15A1.5H41.3H34.",
				"28.14A2.4H42.1H35.", "28.3I11A84.", "27.1B6I8A84.", "27.1B6I4B88.", "27.4B3I4B88.", "28.11B87.",
				"27.13B86.", "24.16B86.", "23.17B86.", "22.19B85.", "22.19B85.", "22.19B85.", "23.18B85.", "26.15B85.",
				"27.13B86.", "28.12B86.", "28.13B2.3B80.", "28.19B79.", "28.20B78.", "27.22B77.", "27.23B76.", "27.23B76.",
				"28.23B75.", "29.22B75.", "29.21B76.", "30.20B76.", "31.16B19.2D58.", "32.13B18.6D57.", "34.11B16.9D56.",
				"33.9B17.11D1.13G42.", "33.7B18.12D1.14G41.", "33.7B18.12D1.14G41.", "33.8B17.11D2M13G42.",
				"33.9B10C5.13D2M10G44.", "34.7B1J11C9D9M13G42.", "34.6B2J11C9D9M14G41.", "35.4B2J11C2K8D1M22G41.",
				"36.2B2J12C2K7D2M23G40.", "37.1B1J13C2K7D2M24G39.", "39.13C2K8D1M24G39.", "40.12C3K7D1M24G39.",
				"40.14C1K7D1M24G39.", "41.14C7D2M23G39.", "41.14C7D2M23G39.", "42.12C9D2M22G39.", "44.9C10D2M22G39.",
				"45.2C3.2C7D5M23G39.", "52.6D3M25G40.", "51.7D2M25G41.", "51.7D2M24G42.", "51.7D2M14G6P4G42.",
				"51.7D2M13G8P1G44.", "51.7D2M13G2P6F45.", "51.7D2M13G2P7F44.", "51.3L4D2M13G2P6F45.", "52.6L2Q7O6G2P6F45.",
				"52.2E5L9O5G2P7F44.", "42.25E2O4G2P8F43.", "41.26E2R5P10F42.", "41.26E2N16F41.", "41.26E2N17F40.",
				"52.15E2N18F39.", "52.15E2N18F39.", "52.15E2N18F39.", "52.16E1N18F39.", "52.16E2.17F39.", "51.16E9.10F40.",
				"52.15E10.9F40.", "53.5E3.1E1.3E12.7F41.", "126.", "126.", "126.",
			},
		},
		["the-deadmines-2"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.0200, 0.7410, 0.2206, 1.0000 },
				gilnid = { 0.0000, 0.6003, 0.3234, 1.0000 },
				cove = { 0.2006, 0.0075, 0.9531, 0.9611 },
				tunnel = { 0.0469, 0.4147, 0.3323, 0.7575 },
				mr_smite = { 0.4800, 0.1437, 0.6437, 0.3877 },
				ship_deck = { 0.4591, 0.2231, 0.7385, 0.6901 },
				bow = { 0.5299, 0.1048, 0.7455, 0.4476 },
				captain_greenskin = { 0.5180, 0.2171, 0.7046, 0.4790 },
				edwin_vancleef = { 0.5180, 0.3308, 0.7036, 0.5988 },
				cookie = { 0.5998, 0.2964, 0.8094, 0.5434 },
				banner = { 0.2904, 0.0180, 0.7086, 0.1692 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "gilnid", boss = "Gilnid", pieces = { "gilnid" }, back = "way_in", way = {} },
				{ id = "mr_smite", boss = "Mr. Smite", pieces = { "mr_smite" }, back = "gilnid", way = { "cove", "tunnel" } },
				{ id = "captain_greenskin", boss = "Captain Greenskin", pieces = { "captain_greenskin" }, back = "mr_smite", way = { "ship_deck", "bow", "cove" } },
				{ id = "edwin_vancleef", boss = "Edwin VanCleef", pieces = { "edwin_vancleef" }, back = "mr_smite", way = { "ship_deck", "bow", "cove" } },
				{ id = "cookie", boss = "Cookie", pieces = { "cookie" }, back = "mr_smite", way = { "ship_deck", "bow", "cove" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in gilnid cove tunnel mr_smite ship_deck bow captain_greenskin edwin_vancleef cookie banner way_in+gilnid gilnid+tunnel cove+tunnel cove+mr_smite cove+ship_deck cove+bow cove+cookie cove+banner mr_smite+ship_deck mr_smite+bow mr_smite+captain_greenskin ship_deck+captain_greenskin ship_deck+edwin_vancleef ship_deck+cookie bow+captain_greenskin bow+cookie captain_greenskin+edwin_vancleef captain_greenskin+cookie edwin_vancleef+cookie cove+mr_smite+ship_deck cove+mr_smite+bow cove+ship_deck+cookie cove+bow+cookie mr_smite+ship_deck+captain_greenskin mr_smite+bow+captain_greenskin ship_deck+captain_greenskin+edwin_vancleef ship_deck+edwin_vancleef+cookie bow+captain_greenskin+cookie captain_greenskin+edwin_vancleef+cookie",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "51.1K21.2K51.", "49.29K48.", "46.35K45.", "38.47K1.3C37.", "38.47K1S7C33.",
				"38.13K25S9K2S7C32.", "38.6K44S11C27.", "38.4K46S12C26.", "38.1K9S31C4S2C3S12C26.", "38.6S41C3S12C26.",
				"38.2C3S42C2S14C25.", "37.66C23.", "37.39C2Q26C22.", "37.38C4Q29C18.", "36.38C2Q1G2Q30C17.",
				"36.33C3O1C3Q2G2Q29C17.", "35.32C5O2f1Q3G4Q28C16.", "35.31C3O4E2U5G3Q28C15.", "36.30C2O6E1U6G3Q27C15.",
				"36.30C1O7E2U6G3Q26C15.", "36.30C1O7E2U7G2Q28C13.", "36.30C2O6E2U8G2Q28C12.", "36.30C2e5E2j7Z3G2Q28C11.",
				"36.30C1P1e2T2E2V1Z5H3Z2G2Q28C11.", "36.29C2P1F3T2i8H2Z3G2Q27C11.", "36.29C2P4F2W9H1Z3G2Q27C11.",
				"36.29C2P4F2W9H1Z4G1Q27C11.", "35.29C2P5F1W10H1Z4G2Q25C12.", "35.29C2P5F1W10H1Z1G3a1h1Q25C12.",
				"35.29C2P5F1W10H1m4a1h8R18C12.", "35.29C2P5F1W10H1c5J8R17C13.", "35.29C2P5F1k10b1n12J2R13C16.",
				"35.29C2P5F1k10b1n8J5R13C17.", "35.29C2P5F1X10I1d7J6R13C17.", "33.30C2P6F1X9I2d7J2R17C17.",
				"32.31C2P6F1X9I2d6J2R18C17.", "31.32C2P6F2X8I1l3Y1J4R20C16.", "31.33C1P6F2X8I1X4Y2g23C15.",
				"30.2N32C1P7F1X7I2X4F2P23C15.", "29.2D2N31C1P7F2X6I2X3F2P24C15.", "28.4D2N30C2P6F2X5I2X4F2P24C15.",
				"23.10D2N29C3P6F7X4F2P25C15.", "22.12D2N29C2P7F5X5F2P24C16.", "22.12D2N29C2P16F2P24C17.",
				"17.18D2N29C2P14F2P25C17.", "14.21D2N28C2P14F3P24C18.", "12.22D8.23C2P4F1P8F3P24C19.",
				"11.23D8.24C2P2F12P24C20.", "11.22D9.24C15P24C21.", "11.21D11.2C1.21C4P33C22.", "11.20D15.23C1P32C24.",
				"11.19D17.54C25.", "11.10D27.51C27.", "11.10D27.50C28.", "12.8D1.13B14.49C29.", "12.8M15B12.50C29.",
				"10.25B11.50C30.", "9.25B11.51C30.", "8.16B20.51C31.", "7.18B19.49C33.", "6.19B19.49C33.", "6.20B18.48C34.",
				"5.21B18.48C34.", "4.23B16.48C35.", "4.23B17.46C36.", "4.23B17.45C37.", "4.23B18.41C40.",
				"4.8B6L9B20.29C4.3C43.", "4.7B9L7B22.27C50.", "5.5B10L7B23.25C51.", "5.5B3L4A4L5B25.23C52.",
				"5.4B3L6A3L4B27.20C54.", "6.3B3L6A3L4B31.11C59.", "7.2B3L6A3L3B36.3C63.", "8.1B3L6A3L2B103.",
				"9.4L5A3L1B104.", "10.3L5A2L1B105.", "13.4A109.", "126.", "126.", "126.", "126.",
			},
		},
	},
})
