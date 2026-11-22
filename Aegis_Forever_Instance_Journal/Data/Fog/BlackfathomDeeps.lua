local _, ns = ...

--[[ Blackfathom Deeps' fog: its four floors as the journal draws them (Media/Maps/Dungeons/):
     blackfathom-deeps-full, the whole dungeon's map, traced from the picture; blackfathom-deeps-1 to -3, the
     client's maps 221 to 223, traced from the game's own tiles. Pieces are fractions of the visible picture, as
     the boss spots are; each is a mask, Media/Fog/BlackfathomDeeps/<floor>/<piece>.tga, split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/BlackfathomDeepsFog/fog_spec.py. Every boss's way runs back
     to the way in but Aku'mai's, which runs back through Twilight Lord Kelris's Sanctum (its braziers open his
     door); the trident on the Pool of Ask'ar's map is Lorgus Jett's room there, though his spots are on the
     other maps. ]]
ns.AddFog("BlackfathomDeeps", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Baron Aquanis"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["blackfathom-deeps-full"] = {
			extent = true,              -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = { { 0.1070, 0.8921, 0.4100, 0.9265 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.2450, 0.0000, 0.4500, 0.2699 },
				pool = { 0.0490, 0.1514, 0.3830, 0.6447 },
				sacellum = { 0.2130, 0.0825, 0.6070, 0.4843 },
				ghamoo_ra = { 0.1440, 0.2729, 0.3100, 0.5352 },
				lady_sarevess = { 0.0000, 0.1274, 0.2160, 0.3958 },
				loop = { 0.1280, 0.4033, 0.5120, 0.7541 },
				gelihast = { 0.1780, 0.2534, 0.4640, 0.7016 },
				lorgus_jett_1 = { 0.3620, 0.3208, 0.5090, 0.5562 },
				lorgus_jett_2 = { 0.3760, 0.3448, 0.5400, 0.6177 },
				passage = { 0.3030, 0.4348, 0.5040, 0.8051 },
				lorgus_jett_3 = { 0.3390, 0.5262, 0.4770, 0.7361 },
				ruins = { 0.2710, 0.6087, 0.5590, 1.0000 },
				lorgus_jett_4 = { 0.3250, 0.7001, 0.4670, 0.9130 },
				twilight_lord_kelris = { 0.4230, 0.7361, 0.6260, 1.0000 },
				aku_mai = { 0.5200, 0.7286, 0.8700, 1.0000 },
				old_serra_kis = { 0.4580, 0.6432, 0.6590, 0.8936 },
				banner = { 0.3830, 0.0180, 0.9570, 0.1754 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "ghamoo_ra", boss = "Ghamoo-ra", pieces = { "ghamoo_ra" }, back = "entrance", way = { "pool", "sacellum" } },
				{ id = "lady_sarevess", boss = "Lady Sarevess", pieces = { "lady_sarevess" }, back = "entrance", way = { "pool", "sacellum" } },
				{ id = "gelihast", boss = "Gelihast", pieces = { "gelihast" }, back = "entrance", way = { "loop", "pool", "sacellum" } },
				{ id = "lorgus_jett_1", boss = "Lorgus Jett", pieces = { "lorgus_jett_1" }, back = "entrance", way = { "loop", "pool", "sacellum" } },
				{ id = "lorgus_jett_2", boss = "Lorgus Jett", pieces = { "lorgus_jett_2" }, back = "entrance", way = { "loop", "pool", "sacellum" } },
				{ id = "lorgus_jett_3", boss = "Lorgus Jett", pieces = { "lorgus_jett_3" }, back = "entrance", way = { "passage", "loop", "pool", "sacellum" } },
				{ id = "lorgus_jett_4", boss = "Lorgus Jett", pieces = { "lorgus_jett_4" }, back = "entrance", way = { "ruins", "passage", "loop", "pool", "sacellum" } },
				{ id = "twilight_lord_kelris", boss = "Twilight Lord Kelris", pieces = { "twilight_lord_kelris" }, back = "entrance", way = { "ruins", "passage", "loop", "pool", "sacellum" } },
				{ id = "aku_mai", boss = "Aku'mai", pieces = { "aku_mai" }, back = "twilight_lord_kelris", way = {} },
				{ id = "old_serra_kis", boss = "Old Serra'kis", pieces = { "old_serra_kis" }, back = "entrance", way = { "ruins", "passage", "loop", "pool", "sacellum" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance pool sacellum ghamoo_ra lady_sarevess loop gelihast lorgus_jett_1 lorgus_jett_2 passage lorgus_jett_3 ruins lorgus_jett_4 twilight_lord_kelris aku_mai old_serra_kis banner entrance+sacellum pool+sacellum pool+ghamoo_ra pool+lady_sarevess pool+loop pool+gelihast sacellum+gelihast loop+gelihast loop+lorgus_jett_2 loop+passage loop+lorgus_jett_3 gelihast+lorgus_jett_1 lorgus_jett_1+lorgus_jett_2 passage+lorgus_jett_3 passage+ruins ruins+lorgus_jett_4 ruins+twilight_lord_kelris ruins+old_serra_kis twilight_lord_kelris+aku_mai twilight_lord_kelris+old_serra_kis pool+sacellum+gelihast pool+loop+gelihast loop+gelihast+lorgus_jett_1 loop+lorgus_jett_1+lorgus_jett_2 loop+passage+lorgus_jett_3 ruins+twilight_lord_kelris+old_serra_kis",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "39.4A82.", "38.6A17.2Q62.", "38.7A13.25Q1.1Q2.7Q1.13Q17.", "38.8A12.51Q16.",
				"38.9A5.4Q2.51Q2.3Q11.", "39.8A4.65Q9.", "39.8A3.68Q7.", "40.8A1.69Q7.", "41.7A1.70Q6.",
				"42.7A9Q5.7Q5.8Q16.2Q5.1Q1.5Q2.4Q6.", "43.6A3Q11.8Q4.7Q33.3Q7.", "43.4A2R14.7Q5.6Q34.2Q8.",
				"41.1C1R2A4R14.4Q1.1Q6.6Q44.", "41.8R1C75.", "40.1C6R4C74.", "5.4E5.4E19.15C73.", "4.6E2.7E16.18C72.",
				"4.6E2.8E6.5B4.19C5.5C61.", "4.17E4.7B2.36C55.", "4.12E3U3E3.7B2.36C55.", "4.11E5U2E2.9B37C55.",
				"4.11E2U1B3U1E2.9B37C55.", "5.10E1U3B3U10B1S23C69.", "5.10E2U15B1S23C69.", "6.10E3U13B2S22C69.",
				"7.10E2U13B2S21C70.", "12.5E1U14B3S8C7X2C73.", "12.14B3T4B3S6C5X5G73.", "11.14B6T4B4S3C1X9G73.",
				"11.13B3T2D3T4B5S1l1X10G72.", "11.13B1T6D1T8B1S1l1X10G72.", "12.11B2T6D2T8B1l2X9G3H69.",
				"12.11B2T7D1T8B1l1X9G5H68.", "16.7B2T7D1T7B2l9G2c4H1d3I64.", "16.7B2T6D2T7B2W9G1c4H2d4I63.",
				"15.9B1T6D2T7B1W10G1c4H2d4I63.", "14.10B2T4D2T8B1W10G1c4H1d6I62.", "13.12B6T9B2W9G1c3H2d6I62.",
				"12.15B2T11B1W6G2Y1G1Y1n3H2d5I63.", "12.22B4W1B2W4G6Y1n4o1Z5I63.", "12.22B7W4G4Y6F2Z4I64.",
				"12.18B3W1B2W9G5Y1F3a2F1Z4I64.", "12.18B6W12G2Y1F4a1F2Z3I64.", "12.18B1W2G2W12G2Y2F1a2J2a1F2Z2I64.",
				"13.16B2W16G2Y2F1a2J3a1Z3I64.", "14.13B1V2m17G2Y2F1a6J2I65.", "15.5B2.6V1m1Y14G4Y2F2a6J67.",
				"22.1F4V1F1Y14G4Y3F2a6J67.", "22.6F2Y13G2Y5F2a6J67.", "22.6F6Y9G1Y5F1b2p1e4J68.",
				"21.7F8Y4G4Y4F2b2K2e3J68.", "21.13F9Y5F1b3K2e3J68.", "21.16F2Y9F5K1e3J68.", "22.26F4K2e3J68.",
				"23.24F2J4e3J69.", "31.12F2.9J1f4L66.", "32.8F5.8J7L65.", "44.7J2f9L63.", "43.7J3f10L62.",
				"43.1f3J4f13L13P48.", "43.6f14L2i12P48.", "43.20L1i13P48.", "43.20L1i13P48.", "43.5L3g12L1i10P51.",
				"44.3L5g11L1i7P54.", "45.1L2g3M2g10L1i7P54.", "45.1L2g3M2g10L1q8P2.2O15.9O25.",
				"46.2g3M2g9L1h1q7k2j6O12.9O25.", "40.6L3g1M3g9L2h7N1j8O11.9O25.", "39.8L5g8L3h8N1j8O9.11O25.",
				"39.9L2g10L2h9N1j8O2.1O5.14O23.", "40.20L2h9N1j30O23.", "43.6L1.10L2h9N1j31O22.", "51.9L1h10N1j32O21.",
				"52.8L1h10N1j32O21.", "52.8L2h9N1j32O21.", "53.7L2h9N2j30O22.", "54.5L3h9N1j31O22.",
				"55.3L3h11N2.9O5.15O22.", "58.2h12N5.5O8.12O23.", "60.12N6.2O13.8O24.", "61.10N24.4O26.", "125.",
			},
		},
		["blackfathom-deeps-1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.2485, 0.0000, 0.5888, 0.2949 },
				pool = { 0.1118, 0.2859, 0.5299, 0.8982 },
				sacellum = { 0.3333, 0.1048, 0.7425, 0.5853 },
				ghamoo_ra = { 0.2385, 0.4521, 0.4331, 0.7530 },
				lady_sarevess = { 0.0369, 0.2575, 0.2984, 0.5569 },
				lorgus_jett = { 0.4441, 0.5314, 0.7305, 0.9895 },
				loop = { 0.2246, 0.7081, 0.5579, 1.0000 },
				gelihast = { 0.3004, 0.3817, 0.6387, 0.9775 },
				banner = { 0.2465, 0.0045, 0.8204, 0.1452 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "ghamoo_ra", boss = "Ghamoo-ra", pieces = { "ghamoo_ra" }, back = "entrance", way = { "pool", "sacellum" } },
				{ id = "lady_sarevess", boss = "Lady Sarevess", pieces = { "lady_sarevess" }, back = "entrance", way = { "pool", "sacellum" } },
				{ id = "gelihast", boss = "Gelihast", pieces = { "gelihast" }, back = "entrance", way = { "lorgus_jett", "loop", "pool", "sacellum" } },
				{ id = "lorgus_jett", boss = "Lorgus Jett", pieces = { "lorgus_jett" }, back = "entrance", way = { "loop", "pool", "sacellum" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance pool sacellum ghamoo_ra lady_sarevess lorgus_jett loop gelihast banner entrance+sacellum entrance+banner pool+sacellum pool+ghamoo_ra pool+lady_sarevess pool+loop pool+gelihast sacellum+gelihast lorgus_jett+loop lorgus_jett+gelihast loop+gelihast pool+sacellum+gelihast pool+loop+gelihast lorgus_jett+loop+gelihast",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "43.9I30.10I34.", "41.52I33.", "39.57I30.", "35.65I26.", "33.68I25.", "33.69I24.", "32.9I22K39I24.",
				"32.3I2.2I3K21A10.1I8.15I2.3I24.", "32.3I3.1K26A30.1I3.3I24.", "33.2I4.27A33.3I24.", "40.27A59.",
				"41.9A1.16A59.", "41.7A4.5A2.8A59.", "41.6A6.3A3.6A2J1C58.", "41.5A14.4A4J58.", "43.1A16.3A4J2C57.",
				"63.3J3C57.", "63.1C1J5C56.", "64.6C56.", "63.7C56.", "63.7C56.", "61.10C55.", "60.12C5.5C44.", "60.28C38.",
				"59.29C38.", "57.31C38.", "11.3E7.7E27.33C38.", "10.5E5.10E23.23C50.", "10.6E3.12E9.5B7.25C49.",
				"10.7E2.12E7.8B6.26C48.", "10.22E6.8B5.26C49.", "10.15E4N3E6.8B5.26C49.", "10.14E6N2E5.9B4.28C48.",
				"11.13E2N3B2N1E5.9B4.28C48.", "11.13E1N4B2N2E4.9B4.29C47.", "11.13E1N5B3N3.10B4.29C47.",
				"12.12E3N3B2N14B4.7C2Q20C47.", "13.12E3N20B1L6C7Q16C48.", "14.13E2N19B2L4C3Q3H3Q14C49.",
				"20.8E19B3L2C3Q7H5Q5C54.", "21.7E20B3L2Q10H4Q5C54.", "21.28B2L2U19H54.", "20.20B3M8B1U1P20H53.",
				"19.18B9M6B4P18H52.", "19.17B3M5D3M7B6P14H52.", "19.17B2M7D2M12B2P14H51.", "19.16B2M9D2M11B2P14H51.",
				"21.14B2M10D2M11B1P13H52.", "25.10B2M10D2M11B1P14H51.", "26.9B2M10D2M10B2P13H5F47.",
				"27.8B2M10D2M9B2P14H6F46.", "27.9B1M10D2M9B2P14H6F3.3F40.", "25.11B1M9D2M10B2P14H7F1.4F40.",
				"24.12B2M8D2M10B2P14H12F40.", "22.15B2M6D2M11B2P14H1S12F39.", "21.17B8M12B2P14H1S12F39.",
				"20.19B4M15B2P13H2S12F39.", "20.38B2P8H7S12F39.", "20.30B6P1B3P6H8S13F39.", "20.30B3P1H5P6H3S18F40.",
				"20.30B2P4H2P8H5S14F41.", "20.25B4P1B2P14H6S12F42.", "20.24B8P18H2S9F45.", "21.23B2P4H1P18H2S9F46.",
				"21.23B2V22H2S6F50.", "22.10B2.9B2V1T22H2S6F50.", "24.7B3.7B2O2V23H2S6F50.", "34.1B8O1G2T21H2S7F50.",
				"35.6O4G2T16H6S6F51.", "35.10G2T16H2S10F51.", "35.11G2T15H1S10F52.", "34.12G2T14H2S8F54.",
				"34.13G3T12H2S8F54.", "33.15G4T7H2T2W8F55.", "33.17G12T2R7F55.", "34.18G5T6G2R5F56.", "35.29G1R4F57.",
				"39.26G61.", "46.18G62.", "48.13G65.", "48.11G67.", "51.3G72.", "126.",
			},
		},
		["blackfathom-deeps-2"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.2595, 0.1168, 0.4870, 0.4326 },
				lorgus_jett_1 = { 0.3194, 0.0973, 0.4571, 0.3323 },
				lorgus_jett_2 = { 0.3673, 0.1317, 0.5100, 0.3787 },
				passage = { 0.2585, 0.2560, 0.4641, 0.6617 },
				lorgus_jett_3 = { 0.2854, 0.3653, 0.4242, 0.5898 },
				ruins = { 0.2325, 0.4925, 0.5449, 0.9895 },
				lorgus_jett_4 = { 0.2625, 0.6063, 0.4172, 0.8263 },
				twilight_lord_kelris = { 0.4162, 0.6033, 0.6577, 0.9895 },
				aku_mai = { 0.5230, 0.6512, 0.9651, 1.0000 },
				banner = { 0.2196, 0.0165, 0.7934, 0.1617 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "lorgus_jett_1", boss = "Lorgus Jett", pieces = { "lorgus_jett_1" }, back = "way_in", way = {} },
				{ id = "lorgus_jett_2", boss = "Lorgus Jett", pieces = { "lorgus_jett_2" }, back = "way_in", way = {} },
				{ id = "lorgus_jett_3", boss = "Lorgus Jett", pieces = { "lorgus_jett_3" }, back = "way_in", way = { "passage" } },
				{ id = "lorgus_jett_4", boss = "Lorgus Jett", pieces = { "lorgus_jett_4" }, back = "way_in", way = { "ruins", "passage" } },
				{ id = "twilight_lord_kelris", boss = "Twilight Lord Kelris", pieces = { "twilight_lord_kelris" }, back = "way_in", way = { "ruins", "passage" } },
				{ id = "aku_mai", boss = "Aku'mai", pieces = { "aku_mai" }, back = "twilight_lord_kelris", way = {} },
			},
			where = { cols = 126, rows = 84, keys = "way_in lorgus_jett_1 lorgus_jett_2 passage lorgus_jett_3 ruins lorgus_jett_4 twilight_lord_kelris aku_mai banner way_in+lorgus_jett_1 way_in+lorgus_jett_2 way_in+passage passage+lorgus_jett_3 passage+ruins ruins+lorgus_jett_4 ruins+twilight_lord_kelris twilight_lord_kelris+aku_mai",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "41.2J1.1J39.2J40.", "39.14J2.34J37.", "38.51J37.", "32.5J1.51J2.4J31.", "30.67J29.",
				"29.68J29.", "29.70J27.", "29.4J1.65J27.", "29.2J3.5J34.6J9.5J3.3J27.", "29.3J64.2J28.", "30.1J65.1J29.",
				"47.4B75.", "46.6B74.", "45.7B74.", "45.8B5C68.", "41.3A1.8B6C67.", "40.5A7B7C67.", "40.6A6B7C67.",
				"40.6A1B1K4B7C67.", "41.5A6K7C67.", "40.8A3K1A1L5C68.", "40.12A1L5C68.", "40.12A1L4C69.", "40.12A2L2C70.",
				"40.12A2L1C71.", "42.5A6M73.", "42.4A7M73.", "45.1D5M3D72.", "46.7D73.", "46.7D73.", "46.7D73.", "45.8D73.",
				"45.8D73.", "45.8D73.", "45.3N4D74.", "43.3E2N4D74.", "42.4E2N4D74.", "41.5E2N4D74.", "41.5E2N4D74.",
				"41.5E2N4D74.", "41.3E1N1E2N4D74.", "42.1E5N3D75.", "41.9D76.", "40.9D77.", "39.9D3F2.2F71.",
				"37.1F2O6D2O8F70.", "36.2F6O1D3O12F66.", "36.4F7O14F65.", "35.26F65.", "35.27F64.", "35.28F63.",
				"34.30F62.", "34.30F62.", "35.28F63.", "35.6F4P18F2.12H49.", "36.3F7P17F2.12H49.", "37.1F3P4G2P16F2.12H49.",
				"38.2P5G2P16F14H49.", "38.8G1P16F13H24.8I18.", "39.6G2P15F9H5.6I17.10I17.", "39.6G2P12F2Q11H1.11I15.10I17.",
				"40.5G1P12F2Q12H12I15.10I17.", "42.1G1.14F1Q12H2R11I16.8I18.", "44.14F1Q12H2R11I14.14I14.",
				"44.14F1Q12H2R11I13.16I13.", "45.13F1Q12H2R18I1.23I11.", "45.13F1Q12H2R42I11.", "46.12F1Q12H2R43I10.",
				"47.11F1Q12H2R43I10.", "47.11F1Q12H2R44I9.", "47.11F2Q11H2R44I9.", "49.9F2Q11H1R44I10.",
				"50.8F3Q11H4I1.39I10.", "51.8F2Q10H7.13I5.20I10.", "55.5F3.8H10.7I10.18I10.", "56.4F4.6H12.5I13.15I11.",
				"103.11I12.", "105.7I14.", "126.", "126.", "126.", "126.",
			},
		},
		["blackfathom-deeps-3"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3184, 0.4266, 0.5259, 0.8009 },
				old_serra_kis = { 0.3383, 0.0853, 0.8234, 0.7680 },
				banner = { 0.2196, 0.0165, 0.7934, 0.1617 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "old_serra_kis", boss = "Old Serra'kis", pieces = { "old_serra_kis" }, back = "way_in", way = {} },
			},
			where = { cols = 126, rows = 84, keys = "way_in old_serra_kis banner way_in+old_serra_kis",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "41.2C1.1C39.2C40.", "39.14C2.34C37.", "38.51C37.", "32.5C1.51C2.4C31.", "30.67C29.",
				"29.68C29.", "29.70C27.", "29.4C1.65C27.", "29.2C3.5C34.6C9.5C3.3C27.", "29.3C64.2C28.",
				"30.1C42.2B21.1C29.", "70.8B48.", "69.11B46.", "68.14B44.", "66.17B43.", "65.18B43.", "64.20B42.",
				"63.21B42.", "62.22B42.", "61.23B42.", "56.41B29.", "55.43B28.", "55.43B28.", "55.43B28.", "56.29B3.6B32.",
				"56.29B4.5B32.", "56.29B41.", "56.30B40.", "56.30B40.", "56.31B39.", "56.32B38.", "56.33B37.", "56.33B37.",
				"55.34B37.", "54.36B36.", "53.37B36.", "52.37B37.", "50.39B37.", "49.40B37.", "49.40B37.", "48.3D38B37.",
				"48.4D36B38.", "47.1A7D33B38.", "47.3A9D28B39.", "47.5A8D26B40.", "48.7A5D25B41.", "48.9A3D24B42.",
				"49.8A3D23B43.", "49.8A3D21B45.", "49.8A3D16B50.", "49.8A3D15B51.", "49.8A3D14B52.", "49.8A3D13B53.",
				"49.8A3D12B54.", "49.8A3D11B55.", "49.8A3D8B58.", "49.8A3D5B61.", "50.9A67.", "126.", "126.", "126.",
				"126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
				"126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
			},
		},
	},
})
