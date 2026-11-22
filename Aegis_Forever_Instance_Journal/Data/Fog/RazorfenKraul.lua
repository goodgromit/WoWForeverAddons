local _, ns = ...

--[[ Razorfen Kraul's fog: its one floor, the client's map as the journal draws it (Media/Maps/Dungeons/
     razorfen-kraul). Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/RazorfenKraul/<floor>/<piece>.tga, traced from the game's own tiles and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/RazorfenKraulFog/fog_spec.py. ]]
ns.AddFog("RazorfenKraul", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["razorfen-kraul"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.5369, 0.6362, 0.8154, 0.9940 },       -- the swirl and its passage up to the loop
				lower_hall = { 0.7255, 0.3967, 0.9291, 0.7455 },       -- the strip past Aggem's room and the arm down to the loop
				hub = { 0.4721, 0.3832, 0.8543, 0.8263 },       -- the loop round the first rock island, its bands and the islands east and west of it
				aggem_thorncurse = { 0.7275, 0.3877, 0.8962, 0.6527 },       -- his yellow room, as tinted
				east_hall = { 0.5948, 0.1901, 0.8992, 0.5569 },       -- the great hall: the channel from Ramtusk's room, the ridge, the lower part down to Aggem's tint
				death_speaker_jargba = { 0.7914, 0.2680, 0.9701, 0.5808 },       -- his pink room, as tinted
				roogug_hall = { 0.5339, 0.3713, 0.7715, 0.6482 },       -- the C-shaped floor under Roogug's spiral
				roogug = { 0.5040, 0.2814, 0.7515, 0.5584 },       -- Ramtusk's tunnel, where he stands at its foot, with the knoll and the spiral wall beside it
				overlord_ramtusk = { 0.4411, 0.1512, 0.7056, 0.4925 },       -- his blue room and the notch beside it, walls and all (where his Spearhide guards stand)
				bat_cave = { 0.0000, 0.2006, 0.3014, 0.7186 },       -- the bat cave, with its north-west recess (the Blind Hunter's: a rare holds no fog)
				bridge = { 0.1607, 0.1527, 0.4521, 0.7784 },       -- the first bridge and the R-shaped tunnel under it, with the R's top arm
				spiral = { 0.2934, 0.2350, 0.6178, 0.7964 },       -- the spiral round Halmgar's knoll, its landing, the two bridges across it and the lobe at the plank bridge's south-west end (Earthcaller Halmgar's: a rare holds no fog)
				agathelos = { 0.0000, 0.4895, 0.1796, 0.8263 },       -- his red cave behind the ward
				charlga_razorflank = { 0.1208, 0.1497, 0.3174, 0.4790 },       -- the green room (her pin and the client's skull)
				banner = { 0.2325, 0.0165, 0.8064, 0.1602 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "aggem_thorncurse", boss = "Aggem Thorncurse", pieces = { "aggem_thorncurse" }, back = "entrance", way = { "lower_hall", "hub" } },
				{ id = "death_speaker_jargba", boss = "Death Speaker Jargba", pieces = { "death_speaker_jargba" }, back = "entrance", way = { "east_hall", "lower_hall", "hub" } },
				{ id = "roogug", boss = "Roogug", pieces = { "roogug" }, back = "entrance", way = { "roogug_hall", "hub" } },
				{ id = "overlord_ramtusk", boss = "Overlord Ramtusk", pieces = { "overlord_ramtusk" }, back = "entrance", way = { "east_hall", "lower_hall", "hub" } },
				{ id = "agathelos", boss = "Agathelos the Raging", pieces = { "agathelos" }, back = "entrance", way = { "bat_cave", "bridge", "spiral", "hub" } },
				{ id = "charlga_razorflank", boss = "Charlga Razorflank", pieces = { "charlga_razorflank" }, back = "entrance", way = { "bat_cave", "bridge", "spiral", "hub" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance lower_hall hub aggem_thorncurse east_hall death_speaker_jargba roogug_hall roogug overlord_ramtusk bat_cave bridge spiral agathelos charlga_razorflank banner entrance+hub lower_hall+hub lower_hall+aggem_thorncurse lower_hall+death_speaker_jargba hub+aggem_thorncurse hub+east_hall hub+roogug_hall hub+roogug hub+spiral aggem_thorncurse+east_hall east_hall+death_speaker_jargba east_hall+roogug_hall east_hall+roogug east_hall+overlord_ramtusk roogug_hall+roogug roogug+overlord_ramtusk roogug+spiral overlord_ramtusk+spiral bat_cave+bridge bat_cave+agathelos bat_cave+charlga_razorflank bridge+spiral bridge+charlga_razorflank lower_hall+hub+aggem_thorncurse lower_hall+aggem_thorncurse+east_hall lower_hall+aggem_thorncurse+death_speaker_jargba hub+aggem_thorncurse+east_hall hub+east_hall+roogug_hall hub+roogug_hall+roogug hub+roogug+spiral aggem_thorncurse+east_hall+death_speaker_jargba east_hall+roogug_hall+roogug east_hall+roogug+overlord_ramtusk roogug+overlord_ramtusk+spiral bat_cave+bridge+charlga_razorflank",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "42.7O34.5O38.", "40.51O35.", "37.56O33.", "34.63O29.", "32.67O27.", "31.69O26.",
				"30.70O26.", "30.4O2.21O2.5O3.28O1.5O25.", "30.3O3.3O53.3O3.3O25.", "31.3O63.3O26.", "126.", "126.", "126.",
				"126.", "126.", "27.1N98.", "25.7N4.3K36.5I46.", "24.10N6K2.2K28.10I44.", "24.9N2l10K24.14I43.",
				"23.10N2l14K19.15I5.6E32.", "12.4J6.10N2l16K17.17I3.10E1.1E27.", "11.7J3.11N2l16K16.18I1.16E25.",
				"10.9J2.11N1l18K15.18I18E24.", "10.10J11N2l19K6.3L2g1I2.16I2c19E23.", "10.10J1j10N2l19K3.6L2g19I1c21E22.",
				"10.10J3j7N2l20K2.7L2g18I2c23E1.1F18.", "11.10J2j8N1l20K1.8L3g17I1c24E1Z5F14.",
				"9.12J4j6N1l20K10L2g7I6e3I2c23E2Z7F12.", "8.15J3j5N1l19K12L2g4I10e1I2v1b22E2Z8F11.",
				"7.18J2j3N2l18K14L1g5I1e6H4e1v3b20E2Z8F11.", "6.20J2j2N2l18K14L2g3I2e13H2b19E2Z9F10.",
				"6.21J2j1x1l19K15L3g1I2e13H3b18E2Z10F9.", "5.23J1j1x1h18K1k16L3g2w14H2b18E2Z10F9.",
				"5.24J3h17K1k18L1g1w1f15H2b17E2Z10F9.", "5.25J2h17K2k19L2f15H2b17E2Z9F9.",
				"5.26J2h16K2k19L2f8H7d2u2a15E2Z9F9.", "5.26J2h16K2k19L1X1s1W4H11d1u1a2q2U11E2t9F10.",
				"6.24J2h17K2k18L2X1C2W1H6d9G2V5U8Y1n1o2S6F11.", "5.25J2h17K2k18L1X2C1W1r3d1G3d9G1V3C3U2p1Y4D1R1n1R3S4F12.",
				"5.25J2h16K2k19L1X3C1r16G2V6C1T5D2R3B2S3F12.", "5.25J2h16K2k18L2X3C2V15G2V6C1T6D1R4B2S1F13.",
				"6.23J2h17K2k18L2X3C3V14G2V6C1T6D2R4B1S14.", "6.23J2h17K2k18L2X4C8V7G2V7C2T5D2R4B15.",
				"6.23J2h17K2k19L2X4C7V7G2V7C2T4D2R5B15.", "5.2i22J2h17K3k19L2X9C2V5G2V8C2T4D2R5B15.",
				"4.1M3i21J2h16K3k20L2X9C8V10C2m2D2R5B16.", "4.2M3i19J2h15K4k21L2X11C4V12C2m3R6B16.",
				"4.4M2i17J2h13K5k21L3X27C2Q10B16.", "3.6M1i17J2h13K3k21L4X27C3Q9B17.", "3.8M7.8J2h14K24L2X29C2Q10B17.",
				"2.9M9.6J2h14K24L31C2Q9B18.", "2.9M11.3J3h14K23L33C2Q7B19.", "2.11M12.2h15K23L33C3Q5B20.",
				"3.10M12.17K23L34C3Q3B21.", "4.11M11.16K1.21L36C3Q1B22.", "4.12M11.14K3.20L1.36C1Q24.",
				"5.12M11.12K5.18L2.35C26.", "7.10M13.8K8.16L4.33C27.", "8.10M34.9L6.9C6P16C28.", "10.8M37.4L9.7C7P15C29.",
				"11.6M52.5C4P1A3P8C36.", "12.4M56.2C3P6A1P1C41.", "75.10A41.", "75.11A40.", "75.14A37.", "76.18A32.",
				"76.19A31.", "76.20A30.", "77.19A30.", "78.18A30.", "80.4A3.9A30.", "88.7A31.", "88.7A31.", "89.5A32.",
				"126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
			},
		},
	},
})
