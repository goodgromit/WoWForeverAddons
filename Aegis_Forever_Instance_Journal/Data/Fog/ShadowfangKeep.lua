local _, ns = ...

--[[ Shadowfang Keep's fog: its six floors as the journal draws them (Media/Maps/Dungeons/):
     shadowfang-keep-full, the whole keep's map, traced from the picture, its rooms carried from the five
     floors; shadowfang-keep-1, -2, -7, -4 and -6, the client's maps 310, 311, 316, 313 and 315, traced from
     the game's own tiles. Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/ShadowfangKeep/<floor>/<piece>.tga, split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/ShadowfangKeepFog/fog_spec.py. Each floor's way in is the way the run comes onto it; its way on
     to the next floor clears with the boss it leads to. The Voidwalkers Arugal calls as Fenrus dies share his
     room; called up (summoned, Data/Authored/ShadowfangKeep.lua), they hold nothing back. ]]
ns.AddFog("ShadowfangKeep", {
	-- false: never holds the fog back (his room, if he has one, still clears with his kill; a rare,
	-- a summoned boss or one the owner named holds no fog and has none); true: holds it back
	counts = { ["Arugal's Voidwalker"] = false, ["Fel Steed / Shadow Charger"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["shadowfang-keep-full"] = {
			extent = true,              -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = { { 0.0469, 0.5060, 0.3423, 0.5479 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.7854, 0.5090, 0.9830, 0.8443 },
				gate = { 0.6806, 0.4506, 0.9281, 0.7979 },
				east_room_west = { 0.6826, 0.6033, 0.8383, 0.9147 },
				rethilgore = { 0.7196, 0.6003, 0.9351, 0.9251 },
				west_wing = { 0.2236, 0.3728, 0.5299, 1.0000 },
				courtyard = { 0.4082, 0.2605, 0.7984, 0.7829 },
				commander_springvale = { 0.3862, 0.5299, 0.6327, 0.8982 },
				razorclaw_hall = { 0.3752, 0.4177, 0.5599, 0.6916 },
				razorclaw = { 0.3912, 0.4371, 0.5539, 0.6856 },
				baron_silverlaine = { 0.2784, 0.4985, 0.5060, 0.9611 },
				ramp = { 0.5010, 0.5734, 0.7904, 0.8653 },
				odo = { 0.7295, 0.6183, 0.8703, 0.8293 },
				junction = { 0.5629, 0.3054, 0.7585, 0.5823 },
				north_walk = { 0.6457, 0.3757, 0.8623, 0.6213 },
				north_walk_east = { 0.7395, 0.3892, 0.9870, 0.6931 },
				fenrus = { 0.5778, 0.1332, 0.8094, 0.4880 },
				rings = { 0.5389, 0.1527, 0.7226, 0.4925 },
				wolf_master_nandos = { 0.6347, 0.1856, 0.7754, 0.3952 },
				archmage_arugal = { 0.6287, 0.0000, 0.9012, 0.3353 },
				banner = { 0.4371, 0.8443, 0.8932, 0.9835 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "rethilgore", boss = "Rethilgore", pieces = { "rethilgore" }, back = "entrance", way = { "gate", "east_room_west" } },
				{ id = "commander_springvale", boss = "Commander Springvale", pieces = { "commander_springvale" }, back = "entrance", way = { "west_wing", "courtyard", "gate" } },
				{ id = "razorclaw", boss = "Razorclaw the Butcher", pieces = { "razorclaw" }, back = "entrance", way = { "razorclaw_hall", "courtyard", "gate" } },
				{ id = "baron_silverlaine", boss = "Baron Silverlaine", pieces = { "baron_silverlaine" }, back = "razorclaw", way = {} },
				{ id = "odo", boss = "Odo the Blindwatcher", pieces = { "odo" }, back = "commander_springvale", way = { "east_room_west", "ramp" } },
				{ id = "fenrus", boss = "Fenrus the Devourer", pieces = { "fenrus" }, back = "odo", way = { "junction", "north_walk", "north_walk_east" } },
				{ id = "wolf_master_nandos", boss = "Wolf Master Nandos", pieces = { "wolf_master_nandos" }, back = "fenrus", way = { "rings" } },
				{ id = "archmage_arugal", boss = "Archmage Arugal", pieces = { "archmage_arugal" }, back = "wolf_master_nandos", way = {} },
			},
			where = { cols = 84, rows = 56, keys = "entrance gate east_room_west rethilgore west_wing courtyard commander_springvale razorclaw baron_silverlaine ramp odo junction north_walk north_walk_east fenrus rings wolf_master_nandos archmage_arugal banner entrance+gate entrance+rethilgore entrance+north_walk_east gate+east_room_west gate+rethilgore gate+courtyard gate+ramp gate+north_walk gate+north_walk_east east_room_west+rethilgore east_room_west+ramp rethilgore+odo rethilgore+banner west_wing+courtyard west_wing+commander_springvale west_wing+razorclaw_hall west_wing+baron_silverlaine courtyard+commander_springvale courtyard+razorclaw_hall courtyard+razorclaw courtyard+ramp courtyard+junction courtyard+north_walk courtyard+rings commander_springvale+razorclaw commander_springvale+baron_silverlaine commander_springvale+ramp razorclaw_hall+razorclaw razorclaw_hall+baron_silverlaine junction+north_walk junction+fenrus junction+rings north_walk+north_walk_east fenrus+rings fenrus+wolf_master_nandos fenrus+archmage_arugal entrance+gate+rethilgore entrance+gate+north_walk_east gate+east_room_west+rethilgore gate+east_room_west+ramp gate+courtyard+ramp gate+courtyard+north_walk gate+north_walk+north_walk_east west_wing+courtyard+razorclaw_hall west_wing+razorclaw_hall+razorclaw west_wing+razorclaw_hall+baron_silverlaine courtyard+commander_springvale+razorclaw courtyard+commander_springvale+ramp courtyard+razorclaw_hall+razorclaw courtyard+junction+north_walk courtyard+junction+rings commander_springvale+razorclaw_hall+baron_silverlaine junction+fenrus+rings",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"60.4R20.", "59.7R18.", "59.10R15.", "59.12R13.", "58.14R12.", "58.14R12.", "58.14R12.", "58.14R12.",
				"57.14R13.", "57.14R13.", "56.14R14.", "56.3$11R14.", "55.1P1!1O2$10R14.", "53.3P1!2O3$7R15.",
				"52.4P1!1O3#1O2$5R15.", "50.4P2!1O1#2Q1#4O19.", "49.4P2!2O1#3Q3O20.", "49.4P1!3O2#1Q1#3O20.",
				"42.5F2.3P1!6O1#4O20.", "41.8F1q2P1!11O20.", "40.9F1q2P1!10O21.", "39.10F2q1P1y1[1x8O21.",
				"39.11F1q2y1L4x1O1x1O23.", "39.12F1?5L3x24.", "32.2E4.13F2o7L1.3M1.1M18.", "31.7E1g13F2o4L2w7M2z15.",
				"31.7E2g13F2o3L1w8M1z4N12.", "30.8E2i1-1l12F3o1L1>1p6M1z7N10.", "30.6E2i3u2l13F3o2p5M1z9N8.",
				"29.7E1i1u3H1=1l17F2p2*1a1M1z12N5.", "29.6E1i1/1u4H1m19F1Y2B1a1,1b12N4.", "29.6E1i1/5H1m19F1Y4B3b10N4.",
				"27.6E2j1:1v1u4H1m19F1Y7B3b6N5.", "25.7E2j2I1v2u1H1r1;20F1Y8B1T2&2V3N5.",
				"24.8E1j4I1v1@2r1k20F1Y8B2T1&3V7.", "24.8E1j3I2s3G1k20F1Y8B1T5A7.", "24.7E2j3I1s5G1k2F1k1<4n10F2Y7B2T4A8.",
				"25.6E1j4I2s4G1k2F1k1t4J4n5F1n1Y1B1W2B3X1B2T6A6.", "24.7E1j5I1s4G1k2F1k1t7J4n1F2n1)3W1'2e2X2T6A6.",
				"24.6E1j6I1s5G2k1G2t10J2n1J1Z1(1C1c1e2K1e1X2T6A6.", "23.7E1j6I1s10G2t1.11J1d1C1c1e2K1e1D1X1%5A7.",
				"23.6E2j5I2s12G2.9J2d1C1c1e2K1e2D4U9.", "23.6E1j6I1j2h11G3.8J1d3C1c2e7D9.",
				"22.7E1j5I1j2E1h10G5.7J1d4C1c8D9.", "22.6E1j6I1j3E1h6G11.4J5C1c8D9.", "22.6E1j5I2j3E6G16.6C8D9.",
				"23.4E2j5I1j4E3G20.4C3.6D9.", "23.4E1j6I1j3E26.2C4.4D10.", "23.4E1j5I1j4E6.14S3.2S2.6S1f2S10.",
				"22.6E6j4E1.35S10.", "23.14E37S10.", "25.12E37S10.", "27.10E5S1.31S10.", "28.8E1.2S2.1S42.", "30.6E48.",
				"32.3E49.",
			},
		},
		["shadowfang-keep-1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.6098, 0.4626, 0.7794, 0.7350 },
				gate_passage = { 0.4910, 0.4207, 0.6916, 0.7784 },
				entrance_hall_1 = { 0.5369, 0.3503, 0.7914, 0.6976 },
				rethilgore = { 0.5439, 0.5449, 0.7595, 0.8368 },
				west_wing = { 0.0100, 0.3234, 0.3613, 1.0000 },
				courtyard = { 0.2136, 0.1781, 0.6387, 0.7964 },
				commander_springvale = { 0.1936, 0.4760, 0.4182, 0.8578 },
				banner = { 0.2236, 0.0269, 0.7974, 0.1707 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "rethilgore", boss = "Rethilgore", pieces = { "rethilgore" }, back = "entrance", way = { "gate_passage", "entrance_hall_1" } },
				{ id = "commander_springvale", boss = "Commander Springvale", pieces = { "commander_springvale" }, back = "entrance", way = { "west_wing", "courtyard", "gate_passage", "entrance_hall_1" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance gate_passage entrance_hall_1 rethilgore west_wing courtyard commander_springvale banner entrance+entrance_hall_1 entrance+rethilgore gate_passage+entrance_hall_1 gate_passage+rethilgore gate_passage+courtyard entrance_hall_1+rethilgore entrance_hall_1+courtyard west_wing+courtyard west_wing+commander_springvale courtyard+commander_springvale entrance+entrance_hall_1+rethilgore gate_passage+entrance_hall_1+rethilgore gate_passage+entrance_hall_1+courtyard",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "126.", "41.8H31.9H37.", "39.51H36.", "36.56H34.", "32.65H29.", "30.68H28.", "30.69H27.",
				"29.70H27.", "29.4H2.15H9.2H8.4H4.17H2.4H26.", "29.3H3.2H54.3H2.3H27.", "30.2H64.3H27.", "126.", "126.",
				"126.", "126.", "126.", "126.", "126.", "40.4F2.1F79.", "39.10F77.", "37.13F76.", "36.14F76.", "35.15F76.",
				"35.16F75.", "34.17F75.", "34.18F74.", "34.19F73.", "33.21F72.", "33.21F72.", "32.23F12.7F52.",
				"23.2E3.3E1.1P22F12.7F52.", "22.10E3P21F10.8F52.", "21.12E4P19F10.8F3.3C46.", "21.14E3P21F6.9F1.9C42.",
				"21.15E4P22F3.9F11C41.", "20.18E2P34F14C38.", "20.18E2P34F1O15C36.", "19.19E2P33F2O17C34.",
				"19.18E2P34F2O19C32.", "18.8E2.7E2.36F2U2K17C32.", "18.8E5.4E3.34F2M4K16C32.", "17.8E12.35F2M2B4K14C32.",
				"14.11E12.36F1M4B2K14C32.", "12.13E11.2R35F1M5B3K5C3I4C32.", "11.14E8.4G2R34F2M4B3K3C7I1C33.",
				"11.14E6.7G1R34F2M5B2K2C8I1C33.", "11.15E4.8G1R34F2M5B2K2C4I2A1I1C34.", "11.15E3.9G2R32F2M6B2K1C4I4A35.",
				"11.15E3.10G1R32F2M6B2K1C3I5A35.", "12.14E4.8G2R31F2M7B2T1N2S1I5A35.", "12.13E5.8G2R31F2M6B2L1T3N1S2J3A35.",
				"12.13E5.8G2R29F3M7B2L5D3J1D36.", "11.14E6.8G2R2F3R22F3M8B1L10D36.", "10.14E7.9G4R3G21F2M9B1L11D35.",
				"10.12E9.10G2R5G3.16F2M6B5L10D36.", "10.11E10.17G6.13F2M5B5L11D36.", "9.12E9.17G8.10F2.2M5B1L14D37.",
				"9.11E9.1E1Q15G10.8F5.5B15D37.", "9.11E9.1E3Q12G13.6F10.15D37.", "8.11E9.3E4Q9G15.4F12.13D38.",
				"8.11E9.5E2Q9G35.9D38.", "8.11E8.7E1Q9G36.8D38.", "8.10E9.7E10G39.4D39.", "8.10E8.8E8G84.",
				"9.9E8.8E2.3G87.", "8.9E9.8E92.", "8.8E9.8E93.", "7.9E9.8E93.", "7.10E7.8E94.", "6.14E4.8E94.",
				"6.16E1.8E95.", "7.24E95.", "7.24E95.", "9.21E96.", "12.18E96.", "15.15E96.", "17.12E97.", "20.9E97.",
				"22.7E97.", "24.3E99.", "126.", "126.",
			},
		},
		["shadowfang-keep-2"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.4830, 0.0000, 0.7006, 0.2874 },
				razorclaw_hall = { 0.3343, 0.0299, 0.6168, 0.4970 },
				razorclaw = { 0.3972, 0.1662, 0.5639, 0.4162 },
				dining_hall = { 0.1996, 0.2874, 0.5419, 0.9431 },
				baron_silverlaine = { 0.1836, 0.6377, 0.3902, 0.9476 },
				banner = { 0.2236, 0.8353, 0.7974, 0.9835 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "razorclaw", boss = "Razorclaw the Butcher", pieces = { "razorclaw" }, back = "way_in", way = { "razorclaw_hall" } },
				{ id = "baron_silverlaine", boss = "Baron Silverlaine", pieces = { "baron_silverlaine" }, back = "way_in", way = { "dining_hall", "razorclaw_hall" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in razorclaw_hall razorclaw dining_hall baron_silverlaine banner way_in+razorclaw_hall razorclaw_hall+razorclaw razorclaw_hall+dining_hall dining_hall+baron_silverlaine",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "126.", "126.", "76.2A48.", "72.7A47.", "69.11A46.", "68.12A46.", "67.3G10A46.",
				"65.2B3G10A46.", "64.4B2G11A45.", "62.6B3G10A45.", "61.7B4G9A45.", "59.10B3G9A45.", "57.12B3G9A45.",
				"56.13B3G7A47.", "55.15B2G3A51.", "53.19B54.", "52.20B54.", "50.10B1H11B54.", "50.7B7H7B55.",
				"49.8B2H3C3H5B56.", "49.7B2H5C2H5B56.", "48.8B1H7C1H5B56.", "48.7B2H7C2H3B57.", "48.8B1H7C1H4B57.",
				"47.9B2H5C2H4B57.", "47.10B3H2C3H3B58.", "47.11B5H5B58.", "43.4D3B1I9B1H7B58.", "42.7D4I14B59.",
				"41.10D3I13B59.", "41.11D4I10B60.", "40.14D5I7B60.", "40.16D6I3B61.", "40.19D4I2B61.", "40.22D1I63.",
				"39.23D64.", "38.20D68.", "38.20D68.", "37.20D69.", "37.20D69.", "37.19D70.", "37.19D70.", "36.20D70.",
				"36.19D71.", "35.20D71.", "34.21D71.", "34.20D72.", "34.20D72.", "34.20D72.", "34.19D73.", "33.20D73.",
				"32.20D74.", "32.20D74.", "31.20D75.", "31.20D75.", "31.20D75.", "31.19D76.", "31.4D4J11D76.",
				"30.3J2D6J9D76.", "29.2E5J3E3J7D77.", "29.4E2J6E3J5D77.", "29.13E2J4D78.", "28.14E1J5D78.", "28.13E2J5D78.",
				"28.13E2J4D79.", "28.12E2J5D79.", "28.12E2J4D80.", "28.11E2J5D80.", "28.9E3J5D81.",
				"28.8E2J7D10F2.4F23.2F40.", "28.8E2J6D46F36.", "29.7E2J3D51F34.", "30.1E65F30.", "31.67F28.", "30.69F27.",
				"30.69F27.", "29.71F26.", "29.3F3.4F1.1F48.5F2.4F26.", "30.2F64.3F27.", "31.1F65.1F28.", "126.", "126.",
			},
		},
		["shadowfang-keep-7"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.1517, 0.6138, 0.3473, 0.8847 },
				odo_hall_1 = { 0.4501, 0.5689, 0.7784, 1.0000 },
				passage_1 = { 0.3124, 0.6826, 0.5719, 0.9895 },
				ramp = { 0.2226, 0.6437, 0.4371, 0.9042 },
				odo = { 0.5130, 0.7006, 0.6796, 0.9506 },
				round_tower = { 0.3483, 0.2650, 0.5369, 0.5659 },
				north_walk = { 0.3842, 0.3488, 0.6148, 0.7156 },
				deathsworn_captain_hall = { 0.4601, 0.3533, 0.8523, 0.7590 },
				east_walk = { 0.6058, 0.5853, 0.8024, 0.8907 },
				fenrus = { 0.3373, 0.0584, 0.5938, 0.4401 },
				banner = { 0.2236, 0.0120, 0.7974, 0.1557 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "odo", boss = "Odo the Blindwatcher", pieces = { "odo" }, back = "way_in", way = { "odo_hall_1", "passage_1", "ramp" } },
				{ id = "fenrus", boss = "Fenrus the Devourer", pieces = { "fenrus" }, back = "odo", way = { "round_tower", "north_walk", "deathsworn_captain_hall", "east_walk" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in odo_hall_1 passage_1 ramp odo round_tower north_walk deathsworn_captain_hall east_walk fenrus banner way_in+ramp odo_hall_1+passage_1 odo_hall_1+odo odo_hall_1+deathsworn_captain_hall odo_hall_1+east_walk passage_1+ramp round_tower+north_walk round_tower+fenrus north_walk+deathsworn_captain_hall deathsworn_captain_hall+east_walk fenrus+banner odo_hall_1+north_walk+deathsworn_captain_hall",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "40.12K26.11K37.", "38.53K35.", "34.61K31.", "31.66K29.", "30.68K28.",
				"30.18K5V1K4V9K3V29K27.", "29.18K25V27K27.", "29.4K2.9K3.24J1V10K3.9K2.4K26.", "29.3K16.24J4K1.2K17.3K27.",
				"30.2K17.22J25.3K27.", "49.21J56.", "48.21J57.", "48.21J57.", "48.22J56.", "48.21J57.", "48.21J57.",
				"49.20J57.", "50.18J58.", "50.18J58.", "49.18J59.", "49.18J59.", "49.17J60.", "48.18J60.", "48.17J61.",
				"47.18J61.", "48.16J62.", "49.5J4S6J62.", "50.4J8S1J63.", "50.5S3F5S63.", "50.1F2S10F63.", "51.11F64.",
				"50.12F64.", "50.11F6.1G58.", "49.11F11G1T4H50.", "49.5F6R10G2T8H46.", "49.5F4R12G2T12H42.",
				"49.5F2R14G2T13H41.", "50.4F2R14G2T15H39.", "50.4F2R14G2T17H37.", "51.3F2R13G2T19H36.",
				"54.1F1G1.12G2T22H33.", "59.9G2T27H29.", "60.7G2T30H27.", "60.7G2T31H26.", "62.4G2T33H25.", "63.2G3T34H24.",
				"64.3T35H24.", "64.3T35H24.", "63.1G2T36H24.", "63.3T36H24.", "63.3T36H24.", "63.2W6O30H25.",
				"63.2W9O26H26.", "64.7B5O9H6U8H27.", "64.10B2O6H4U2I6U1H1U30.", "64.12B2.4H3U7I4U30.", "64.12B6.1U13I30.",
				"28.7A2L1D26.11B9.12I30.", "27.8A2L5D21.12B10.10I31.", "26.8A3L10D16.12B9.10I32.",
				"26.8A3L12D1Q12.15B7.9I33.", "27.7A3L11D2Q3C7.2C1M16B5.9I33.", "27.6A3L12D2Q5C4.3C2M10B2N6B1.9I34.",
				"28.5A3L11D2Q14C2M7B6N5B2P7I34.", "28.4A4.11D2Q14C2M6B3N3E2N5B2P6I34.", "39.8D1Q16C2M5B1N6E2N5B5P2I34.",
				"43.3D2Q16C2M4B2N6E2N6B6P34.", "44.3Q18C2M3B2N7E1N13B33.", "44.2Q19C2M3B2N6E2N13B33.",
				"45.19C2M5B2N5E2N13B33.", "47.16C2M6B3N2E3N14B33.", "47.16C2M7B6N14B34.", "48.15C2M27B34.", "51.13C28B34.",
				"54.10C29B33.", "56.3C1.3C30B33.", "63.30B33.", "63.30B33.", "64.11B4.14B33.", "65.10B5.13B33.",
				"67.7B6.12B34.", "126.",
			},
		},
		["shadowfang-keep-4"] = {
			extent = true,              -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = { { 0.6487, 0.9177, 0.9481, 0.9641 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3952, 0.6347, 0.6228, 1.0000 },
				fenrus = { 0.3523, 0.2620, 0.7236, 0.8189 },
				wolf_master_nandos = { 0.2685, 0.1482, 0.7076, 0.8862 },
				banner = { 0.2236, 0.0120, 0.7974, 0.1557 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "fenrus", boss = "Fenrus the Devourer", pieces = { "fenrus" }, back = "way_in", way = {} },
				{ id = "wolf_master_nandos", boss = "Wolf Master Nandos", pieces = { "wolf_master_nandos" }, back = "way_in", way = {} },
			},
			where = { cols = 126, rows = 84, keys = "way_in fenrus wolf_master_nandos banner way_in+fenrus way_in+wolf_master_nandos fenrus+wolf_master_nandos way_in+fenrus+wolf_master_nandos",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "40.12D26.11D37.", "38.53D35.", "34.61D31.", "31.66D29.", "30.68D28.", "30.69D27.",
				"29.70D27.", "29.4D2.9D27.11D3.9D2.4D26.", "29.3D40.4D1.2D17.3D27.", "30.2D64.3D27.", "126.", "126.",
				"126.", "126.", "126.", "65.2C59.", "58.15C53.", "55.21C50.", "53.26C47.", "51.31C44.", "50.33C43.",
				"49.35C42.", "48.36C42.", "47.37C42.", "45.39C42.", "45.24C2G12C43.", "44.19C10G10C43.",
				"43.17C6G2B1G2B3G8C44.", "43.15C5G9B6G4C44.", "42.14C4G15B3G2B46.", "42.13C3G22B46.", "41.13C2G25B45.",
				"41.12C2G27B44.", "40.12C2G29B43.", "40.11C3G30B42.", "40.11C2G31B42.", "40.11C2G32B41.", "39.12C1G33B41.",
				"39.11C2G33B41.", "39.11C2G34B40.", "39.11C2G34B40.", "39.11C2G34B40.", "39.11C2G34B40.", "39.11C2G34B40.",
				"39.11C2G34B40.", "39.12C1G34B40.", "39.12C2G33B40.", "40.11C2G33B40.", "40.11C2G32B41.", "40.12C2G31B41.",
				"41.12C2G30B41.", "41.12C2G29B42.", "41.13C2G28B42.", "42.12C3G26B43.", "42.13C3G24B44.", "43.13C2G23B45.",
				"43.14C3G20B46.", "44.14C3G18B47.", "45.13C1F2H5E12B48.", "46.11C3F1H5E9B51.", "47.10C3F5E2A1B58.",
				"48.9C3F8A58.", "49.8C3F8A58.", "50.6C4F9A57.", "51.5C3F11A56.", "53.3C3F11A56.", "55.1C3F12A55.",
				"57.1C13A55.", "60.11A55.", "61.10A55.", "62.9A55.", "61.10A55.", "62.9A55.", "62.9A55.", "63.7A56.",
				"64.6A56.", "65.4A57.", "66.2A58.", "126.", "126.", "126.", "126.",
			},
		},
		["shadowfang-keep-6"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3234, 0.7051, 0.5399, 1.0000 },
				wolf_master_nandos_hall = { 0.4072, 0.3967, 0.7136, 0.9401 },
				way_in_hall = { 0.3962, 0.7665, 0.5709, 1.0000 },
				wolf_master_nandos = { 0.4770, 0.5000, 0.6437, 0.7500 },
				archmage_arugal = { 0.4760, 0.0374, 0.8872, 0.6602 },
				banner = { 0.2236, 0.0120, 0.7974, 0.1557 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "wolf_master_nandos", boss = "Wolf Master Nandos", pieces = { "wolf_master_nandos" }, back = "way_in", way = { "wolf_master_nandos_hall", "way_in_hall" } },
				{ id = "archmage_arugal", boss = "Archmage Arugal", pieces = { "archmage_arugal" }, back = "way_in", way = { "wolf_master_nandos_hall", "way_in_hall" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in wolf_master_nandos_hall way_in_hall wolf_master_nandos archmage_arugal banner way_in+way_in_hall wolf_master_nandos_hall+way_in_hall wolf_master_nandos_hall+wolf_master_nandos wolf_master_nandos_hall+archmage_arugal archmage_arugal+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "40.12F26.11F37.", "38.53F35.", "34.61F31.", "31.66F29.", "30.68F28.", "30.69F27.",
				"29.50F1K1E1K17F27.", "29.4F2.9F31.1F8E1.9F2.4F26.", "29.3F43.10E11.3F27.", "30.2F42.13E9.3F27.",
				"73.17E36.", "73.19E34.", "72.21E33.", "72.25E29.", "71.29E26.", "71.31E24.", "71.34E21.", "71.35E20.",
				"70.37E19.", "71.36E19.", "71.36E19.", "70.37E19.", "70.36E20.", "70.36E20.", "69.36E21.", "69.36E21.",
				"68.37E21.", "68.36E22.", "67.36E23.", "67.36E23.", "67.36E23.", "66.36E24.", "65.37E24.", "65.36E25.",
				"65.36E25.", "65.36E25.", "65.35E26.", "63.4B3J30E26.", "62.6B2J30E26.", "61.7B2J30E26.", "61.7B3J28E27.",
				"61.8B4J26E27.", "61.10B4J23E28.", "60.13B5J3E1J16E28.", "60.15B8J14E29.", "60.10B1I7B3J3B2.11E29.",
				"61.7B6I10B4.9E29.", "60.7B2I3D3I10B6.5E30.", "58.8B2I5D2I10B41.", "58.8B2I6D1I10B41.", "57.8B2I7D2I8B42.",
				"57.9B2I6D1I9B42.", "57.9B2I5D2I8B43.", "56.11B2I3D3I8B43.", "56.12B6I8B44.", "56.14B1I10B45.", "57.24B45.",
				"58.23B45.", "58.23B45.", "60.21B45.", "62.19B45.", "62.18B46.", "61.19B46.", "61.18B47.",
				"52.2A7.9B3.3B50.", "50.5A5.9B57.", "49.7A4.9B57.", "48.9A3.9B57.", "48.11A1B4H4B58.", "48.11A1G5H3B58.",
				"48.11A2G3C2H1B59.", "49.10A3G2C2H1B59.", "50.8A3G6C59.", "51.7A3G6C59.", "52.4A4G7C59.", "54.1A5G7C59.",
				"56.2G8C60.", "57.9C60.", "59.7C60.", "62.3C61.", "126.", "126.",
			},
		},
	},
})
