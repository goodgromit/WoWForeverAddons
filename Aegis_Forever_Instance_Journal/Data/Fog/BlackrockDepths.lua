local _, ns = ...

--[[ Blackrock Depths's fog: the journal's own pictures (Media/Maps/Classic/BlackrockDepths.blp, Media/Maps/Classic/BlackrockDepths1.blp).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/BlackrockDepths/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/BlackrockDepthsFog/fog_spec.py. ]]
ns.AddFog("BlackrockDepths", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Guzzler"] = false, ["Princess Moira Bronzebeard"] = false, ["Verek"] = false, ["Watchman Doomgrip"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["BlackrockDepths"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.2150, 0.6372, 0.4690, 1.0000 },
				cavern = { 0.2890, 0.4318, 0.5290, 0.9655 },       -- the cavern round the junction's rocks, from the way in to every door
				lord_roccor = { 0.4040, 0.4783, 0.6440, 0.8111 },
				fineous_darkvire = { 0.5450, 0.1004, 0.7960, 0.3973 },       -- the Hall of Crafting, and its name
				highway = { 0.2190, 0.4273, 0.4360, 0.7166 },       -- the Dark Iron Highway to Bael'Gar's room
				bael_gar = { 0.1300, 0.3703, 0.3440, 0.6582 },
				high_interrogator_gerstahn = { 0.3530, 0.6507, 0.6030, 1.0000 },       -- the Detention Block, and its name
				ramp = { 0.2870, 0.0315, 0.7970, 0.7286 },       -- the ramp up to the Black Anvil, and the city's roofs drawn round it
				lord_incendius = { 0.4630, 0.1589, 0.6680, 0.4498 },       -- the Black Anvil's plateau and its bridge
				banner = { 0.2190, 0.0165, 0.7930, 0.1619 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "lord_roccor", boss = "Lord Roccor", pieces = { "lord_roccor" }, back = "entrance", way = { "cavern" } },
				{ id = "fineous_darkvire", boss = "Fineous Darkvire", pieces = { "fineous_darkvire" }, back = "lord_incendius", way = {} },
				{ id = "bael_gar", boss = "Bael'Gar", pieces = { "bael_gar" }, back = "entrance", way = { "highway", "cavern" } },
				{ id = "high_interrogator_gerstahn", boss = "High Interrogator Gerstahn", pieces = { "high_interrogator_gerstahn" }, back = "entrance", way = { "cavern" } },
				{ id = "lord_incendius", boss = "Lord Incendius", pieces = { "lord_incendius" }, back = "entrance", way = { "ramp", "cavern" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance cavern lord_roccor fineous_darkvire highway bael_gar high_interrogator_gerstahn ramp lord_incendius banner entrance+cavern entrance+high_interrogator_gerstahn cavern+lord_roccor cavern+highway cavern+high_interrogator_gerstahn cavern+ramp lord_roccor+high_interrogator_gerstahn lord_roccor+ramp fineous_darkvire+ramp fineous_darkvire+lord_incendius highway+bael_gar ramp+lord_incendius entrance+cavern+high_interrogator_gerstahn cavern+lord_roccor+high_interrogator_gerstahn cavern+lord_roccor+ramp cavern+highway+ramp fineous_darkvire+ramp+lord_incendius",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "41.2J1.1J38.2J40.", "38.15J1.34J37.", "36.55J34.", "32.63J30.", "30.67J28.", "29.68J28.",
				"29.26J9H33J28.", "28.27J10H33J27.", "28.3J3.4J16.12H10.3J10.4J2.3J27.", "29.3J19.15H29.3J27.",
				"30.1J19.17H28.2J28.", "50.17H13.1D44.", "49.17H10.6D43.", "48.18H9.8D42.", "47.19H8.10D2.8D31.",
				"46.19H8.21D31.", "46.19H4.2I2.21D31.", "45.19H4.6I20D31.", "45.18H4.7I1T13D37.", "45.18H3.9I1T12D37.",
				"44.19H12I2T11D37.", "44.19H13I1T9D2S37.", "44.19H13I2T8D1S6H32.", "44.19H13I2T7D1S7H32.",
				"43.20H13I2a2S3D2S8H32.", "42.21H13I2V1H5S10H31.", "41.22H13I2V16H31.", "41.24H2V9I2V17H30.",
				"41.24H3V7I2V18H30.", "41.25H11V18H30.", "42.52H31.", "43.51H31.", "46.48H31.", "46.48H31.",
				"26.5F15.47H32.", "24.10F12.46H33.", "24.11F12.44H34.", "23.13F11.44H34.", "22.14F12.42H35.",
				"22.14F2.8E1.42H36.", "21.16F1.9E2Z6P33H37.", "21.16F1U9E2Z8P29H39.", "21.15F2U9E2Z6B3P28H39.",
				"22.13F2U9E2N9B2P27H39.", "23.11F2U9E3N10B1P1Y8R17H40.", "24.10F2U7E4N11B2Y1R5C3R16H40.",
				"26.7F2U8E2N12B2M9C3R13H41.", "27.5F2U9E2N11B2M11C3R11H42.", "33.10E2N11B2M12C2R11H42.",
				"35.8E1N12B2M13C2R10H42.", "36.6E2N12B1M15C2R9H42.", "38.4E2N12B1M16C2R7H43.", "41.2N13B1M16C2R7H43.",
				"41.15B1M16C2R6H44.", "42.14B1M17C51.", "42.14B1M16C52.", "42.14B2M15C52.", "42.14B3M12C54.",
				"42.1B2K12B2M6C2Q3C55.", "42.4K12B2X7Q2C56.", "42.5K12B1O1X4Q4G56.", "38.6A4K11B1O10G55.",
				"37.8A3K11B1O10G55.", "37.8A3K7B5O10G55.", "36.10A3K5B6O8G57.", "36.10A3K4B2O12G58.", "36.11A3K2B2O13G58.",
				"35.12A3K2B1O14G58.", "35.13A3K1B1O14G58.", "34.14A3K2O14G58.", "34.14A3K2O15G57.", "34.15A1K1W1O16G57.",
				"34.15A1K1W1O16G57.", "34.15A1L1W17G57.", "34.15A2L17G57.", "34.15A2L18G56.", "35.15A1L18G56.",
				"45.6A17G57.", "49.2A15G59.", "51.14G60.", "51.13G61.", "125.",
			},
		},
		["BlackrockDepths1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3330, 0.6312, 0.5480, 1.0000 },
				arena_ring = { 0.3880, 0.5772, 0.6340, 1.0000 },       -- the Ring of Law's gold ring and its east gate, the ground north of it with its name, and Pyromancer Loregrain's spot by its south-east gate (a rare: he holds no fog)
				ring_of_law_gorosh = { 0.4300, 0.7841, 0.5840, 1.0000 },       -- the Ring of Law's sand (its six challengers)
				manufactory = { 0.2830, 0.5292, 0.5210, 0.8426 },       -- the Manufactory and the road east to the Grim Guzzler
				golem_lord_argelmach = { 0.2990, 0.5217, 0.4400, 0.7526 },
				guzzler = { 0.3190, 0.3613, 0.6070, 0.7691 },       -- the Grim Guzzler and its district (Guzzler and Phalanx)
				road = { 0.3460, 0.2054, 0.6100, 0.5592 },       -- the road from the Chamber up to the Mold Foundry, and its name (Panzor's spot: a rare, he holds no fog)
				the_seven = { 0.4250, 0.0750, 0.7950, 0.4438 },       -- the Summoners' Tomb and the passage to the Molten Core, and their names
				emperor_dagran_thaurissan = { 0.7980, 0.0000, 0.9970, 0.2984 },       -- the Imperial Seat (the Emperor and Princess Moira), and its name
				houndmaster_grebmar = { 0.2940, 0.7781, 0.5030, 1.0000 },
				ne_passage = { 0.5060, 0.6792, 0.7170, 1.0000 },       -- the Shrine of Thaurissan and the passage up to the Domicile
				warder_stilgiss = { 0.4760, 0.5277, 0.6980, 0.8291 },       -- the Domicile (Warder Stilgiss; Watchman Doomgrip, summoned, holds no fog)
				general_angerforge = { 0.2240, 0.6912, 0.4500, 0.9250 },
				plaza = { 0.4090, 0.3928, 0.7810, 0.8726 },       -- Shadowforge City: its plaza and outer rings
				ambassador_flamelash = { 0.4200, 0.2114, 0.7100, 0.6357 },       -- the Chamber of Enchantment and its lava
				tomb_ne = { 0.5200, 0.0930, 0.6600, 0.3193 },
				lyceum = { 0.5280, 0.0000, 0.8040, 0.3043 },
				magmus = { 0.7040, 0.0000, 0.9010, 0.2339 },
				banner = { 0.0110, 0.0180, 0.5790, 0.1619 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "ring_of_law_gorosh", boss = "Ring of Law: Gorosh the Dervish", pieces = { "ring_of_law_gorosh" }, back = "way_in", way = { "arena_ring" } },
				{ id = "ring_of_law_eviscerator", boss = "Ring of Law: Eviscerator", pieces = { "ring_of_law_gorosh" }, back = "way_in", way = { "arena_ring" } },
				{ id = "ring_of_law_ok_thor", boss = "Ring of Law: Ok'thor the Breaker", pieces = { "ring_of_law_gorosh" }, back = "way_in", way = { "arena_ring" } },
				{ id = "ring_of_law_hedrum", boss = "Ring of Law: Hedrum the Creeper", pieces = { "ring_of_law_gorosh" }, back = "way_in", way = { "arena_ring" } },
				{ id = "ring_of_law_grizzle", boss = "Ring of Law: Grizzle", pieces = { "ring_of_law_gorosh" }, back = "way_in", way = { "arena_ring" } },
				{ id = "ring_of_law_anub_shiah", boss = "Ring of Law: Anub'shiah", pieces = { "ring_of_law_gorosh" }, back = "way_in", way = { "arena_ring" } },
				{ id = "golem_lord_argelmach", boss = "Golem Lord Argelmach", pieces = { "golem_lord_argelmach" }, back = "way_in", way = { "manufactory" } },
				{ id = "guzzler", boss = "Guzzler", pieces = { "guzzler" }, back = "way_in", way = { "manufactory" } },
				{ id = "the_seven", boss = "The Seven", pieces = { "the_seven" }, back = "ambassador_flamelash", way = { "road" } },
				{ id = "emperor_dagran_thaurissan", boss = "Emperor Dagran Thaurissan", pieces = { "emperor_dagran_thaurissan" }, back = "magmus", way = {} },
				{ id = "houndmaster_grebmar", boss = "Houndmaster Grebmar", pieces = { "houndmaster_grebmar" }, back = "way_in", way = {} },
				{ id = "warder_stilgiss", boss = "Warder Stilgiss", pieces = { "warder_stilgiss" }, back = "way_in", way = { "ne_passage", "arena_ring" } },
				{ id = "general_angerforge", boss = "General Angerforge", pieces = { "general_angerforge" }, back = "way_in", way = { "manufactory" } },
				{ id = "phalanx", boss = "Phalanx", pieces = { "guzzler" }, back = "way_in", way = { "manufactory" } },
				{ id = "ambassador_flamelash", boss = "Ambassador Flamelash", pieces = { "ambassador_flamelash" }, back = "guzzler", way = { "plaza" } },
				{ id = "magmus", boss = "Magmus", pieces = { "magmus" }, back = "the_seven", way = { "tomb_ne", "lyceum" } },
				{ id = "princess_moira_bronzebeard", boss = "Princess Moira Bronzebeard", pieces = { "emperor_dagran_thaurissan" }, back = "magmus", way = {} },
			},
			where = { cols = 125, rows = 84, keys = "way_in arena_ring ring_of_law_gorosh manufactory golem_lord_argelmach guzzler road the_seven emperor_dagran_thaurissan houndmaster_grebmar ne_passage warder_stilgiss general_angerforge plaza ambassador_flamelash tomb_ne lyceum magmus banner way_in+arena_ring way_in+manufactory way_in+houndmaster_grebmar way_in+general_angerforge arena_ring+ring_of_law_gorosh arena_ring+manufactory arena_ring+guzzler arena_ring+ne_passage arena_ring+warder_stilgiss manufactory+golem_lord_argelmach manufactory+guzzler manufactory+general_angerforge golem_lord_argelmach+guzzler guzzler+road guzzler+warder_stilgiss guzzler+plaza road+the_seven road+plaza road+ambassador_flamelash the_seven+ambassador_flamelash the_seven+tomb_ne the_seven+banner emperor_dagran_thaurissan+magmus ne_passage+warder_stilgiss ne_passage+plaza warder_stilgiss+plaza plaza+ambassador_flamelash tomb_ne+lyceum lyceum+magmus way_in+arena_ring+manufactory way_in+manufactory+general_angerforge arena_ring+manufactory+guzzler arena_ring+guzzler+warder_stilgiss arena_ring+ne_passage+warder_stilgiss manufactory+golem_lord_argelmach+guzzler guzzler+road+plaza guzzler+warder_stilgiss+plaza guzzler+plaza+ambassador_flamelash road+the_seven+ambassador_flamelash ne_passage+warder_stilgiss+plaza guzzler+road+plaza+ambassador_flamelash",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "78.11Q1.2Q33.", "15.2S40.2S15.19Q32.", "12.50S12.20Q31.", "10.55S9.20Q14.8I9.",
				"6.62S4.23Q11R1.9I9.", "4.67S1.23Q11R11I8.", "3.68S23Q1v11R1p11I7.", "3.68S23Q1v11R1p12I6.",
				"2.35S1.33S22Q2v11R1p13I5.", "2.3S3.6S36.5S6.6S2.2S22Q2v10R2p13I5.", "3.3S63.2S22Q2v10R2p12I6.",
				"4.1S54.10H1o1S22Q2v10R1p12I7.", "59.12H3Q2u18Q1v11R11I8.", "59.12H2P1Q3u18Q4.2R6.9I9.",
				"59.12H3n1P2u17Q14.7I10.", "60.10H2n3P2u16Q13.12I7.", "60.11H2n3P1u16Q13.12I7.", "60.11H2n4P2.9Q18.12I7.",
				"59.13H3n2P2.6Q3H37.", "59.14H4n4.2Q6H36.", "59.18H3.10H35.", "59.31H35.", "58.3G2j12H2m14H34.",
				"58.3G3j10H3m15H33.", "57.6G2j8H4m17H31.", "50.5G1.8G2j7H2m1O2m16H31.", "49.15G3j5H2m3O4m13H31.",
				"49.16G5j1H2m6O3m5H38.", "49.19G1j2'1m9O2m3H39.", "49.19G1l2'11O1m3H39.", "55.12G3l13O2H40.",
				"56.11G2l14O42.", "56.10G2l15O42.", "56.10G2l14O43.", "55.10G2l14O44.", "52.2F2g8G2l14O45.",
				"51.4F2g6G2l12O48.", "50.6F1g1$4G2l13O48.", "49.8F1$1k4l13O2t3N44.", "48.9F1$1)2l14O2t5N43.",
				"48.10F2&12O4t7N42.", "47.11F1i1&11O3t10N41.", "47.12F1&1t8O3t13N40.", "46.13F2&6O4t15N39.",
				"46.14F1&1t2O4t18N39.", "45.15F2&4t20N39.", "45.16F2&1t22N39.", "45.17F6i19N1.2N35.",
				"45.1F1f16F1i3F2i22N34.", "45.2f2#19F2i3N6s13N33.", "44.4E1#1d19F1i1N4s3L2s12N33.",
				"43.5E1#1d19F1i1%3s5L2s11N33.", "42.6E1#1d19F1%1s9L1s12N32.", "42.6E1#1d5F2d1y9F3h10L1s12N32.",
				"42.6E1#1d2F5d2y7F3h11L1s12N32.", "41.2D5c1#5d3D1Y2y3F2Z1z1h13L1s12N32.",
				"41.3D3c1D4d5D2Y1y5Z1z14L2s10N33.", "40.17D2Y2B2Z2B1b14L2s10N33.", "40.11D5U1w1Y7B1b14L2s10N33.",
				"41.9D5U2w1Y7B1b14L2s9N34.", "41.9D4U3w8B1b14L1s9N35.", "41.8D4U1A3T8B3b12L1s8N36.",
				"41.4D1e2D4U2A4T7B4b1!10q1(8N36.", "35.9M4e3x4A3T11B1a10K2r6N37.", "34.15M2W5A3T10B1a11K2r4N38.",
				"34.15M2W5A3T10B1a11K3r2N39.", "34.16M1W5A4T9B1a12K3r40.", "41.9M7A5T7B1a15K40.", "41.9M7A5T7B1a14K41.",
				"42.8M1.8A3T7B1a13K42.", "42.7M2.3J3V2A2T4X4B1a13K42.", "44.1M1.2M1.7J1V1A2T6X3B2a11K43.",
				"49.7J1V1A1T2X4C2X2B3a10K43.", "49.7J1V1A1T2X5C2X2B3a10K42.", "49.7J1V1A1T2X5C2X3B2a10K42.",
				"44.12J1V1A1T2X5C2X3B2a10K42.", "43.13J1V1A1T2X4C2X5B2a7K44.", "42.15J3T6X8B6K45.", "42.15J3T1B4X9B51.",
				"43.14J2T15B51.", "52.2J4.14B53.", "60.11B54.", "125.",
			},
		},
	},
})
