local _, ns = ...

--[[ Wailing Caverns's fog: the journal's own picture (Media/Maps/Dungeons/wailing-caverns.tga).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/WailingCaverns/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/WailingCavernsFog/fog_spec.py. ]]
ns.AddFog("WailingCaverns", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Mutanus the Devourer"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["wailing-caverns"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3832, 0.4626, 0.5429, 0.7006 },
				deviate_faerie_dragon_hall = { 0.0000, 0.1078, 0.2685, 0.6123 },       -- the Pit of Fangs, with the Dragon's spot (a rare holds no fog)
				west_passage = { 0.1477, 0.2395, 0.3273, 0.5763 },       -- the stream west from the river to the Pit of Fangs
				kresh_hall = { 0.1966, 0.0000, 0.5609, 0.4910 },       -- the river and its north bank (Kresh's spot a pocket), and Dreamer's Rock (Mutanus's: a summoned boss holds no fog)
				terraces = { 0.2655, 0.3009, 0.5669, 0.6722 },       -- the terraces south of the river and their lowest step, down to the swirl
				lord_cobrahn = { 0.0210, 0.4177, 0.2365, 0.7051 },
				lady_anacondra = { 0.2255, 0.3024, 0.3932, 0.5524 },
				kresh = { 0.3014, 0.2260, 0.4681, 0.4581 },
				chasm = { 0.5339, 0.1602, 1.0000, 0.8144 },       -- the Winding Chasm's floor, from Pythas's basin to Skum's pool
				lower = { 0.4361, 0.5075, 0.9451, 1.0000 },       -- the channel, the Crag of the Everliving and the passages south of it
				lord_pythas = { 0.7395, 0.1078, 0.9900, 0.5030 },       -- his grey basin, and the WINDING CHASM name over it (the owner's call, 2026-11-10)
				skum = { 0.8363, 0.6213, 1.0000, 0.9237 },
				lord_serpentis = { 0.4890, 0.3698, 0.6956, 0.6796 },
				verdan = { 0.4341, 0.2754, 0.6637, 0.6662 },       -- Verdan's green, the stream beside it and the Screaming Gully's wall over the stream
				banner = { 0.4431, 0.0404, 1.0000, 0.1841 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "lord_cobrahn", boss = "Lord Cobrahn", pieces = { "lord_cobrahn" }, back = "entrance", way = { "deviate_faerie_dragon_hall", "west_passage", "kresh_hall", "terraces" } },
				{ id = "lady_anacondra", boss = "Lady Anacondra", pieces = { "lady_anacondra" }, back = "entrance", way = { "terraces" } },
				{ id = "kresh", boss = "Kresh", pieces = { "kresh" }, back = "entrance", way = { "kresh_hall", "terraces" } },
				{ id = "lord_pythas", boss = "Lord Pythas", pieces = { "lord_pythas" }, back = "entrance", way = { "chasm", "lower", "terraces" } },
				{ id = "skum", boss = "Skum", pieces = { "skum" }, back = "entrance", way = { "lower", "terraces" } },
				{ id = "lord_serpentis", boss = "Lord Serpentis", pieces = { "lord_serpentis" }, back = "entrance", way = { "lower", "terraces" } },
				{ id = "verdan", boss = "Verdan the Everliving", pieces = { "verdan" }, back = "entrance", way = { "terraces" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance deviate_faerie_dragon_hall west_passage kresh_hall terraces lord_cobrahn lady_anacondra kresh chasm lower lord_pythas skum lord_serpentis verdan banner entrance+terraces deviate_faerie_dragon_hall+west_passage deviate_faerie_dragon_hall+lord_cobrahn west_passage+kresh_hall west_passage+lady_anacondra kresh_hall+terraces kresh_hall+lady_anacondra kresh_hall+kresh kresh_hall+verdan terraces+lady_anacondra terraces+kresh terraces+lower terraces+verdan chasm+lower chasm+lord_pythas chasm+skum chasm+lord_serpentis chasm+verdan lower+skum lower+lord_serpentis lower+verdan lord_serpentis+verdan west_passage+kresh_hall+lady_anacondra kresh_hall+terraces+lady_anacondra kresh_hall+terraces+kresh kresh_hall+terraces+verdan terraces+lower+verdan chasm+lower+skum chasm+lower+lord_serpentis chasm+lord_serpentis+verdan lower+lord_serpentis+verdan",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "37.11D78.", "35.16D75.", "34.19D73.", "33.22D12.6O35.5O13.", "33.23D9.50O11.", "33.24D7.54O8.",
				"32.25D1.63O5.", "31.27D66O2.", "31.26D67O2.", "31.26D6O1.61O1.", "31.26D2O1.3O1.25O2.29O1.4O1.",
				"31.26D4.1O53.4O3.3O1.", "31.27D64.2O2.", "17.3B10.28D64.1O3.", "17.4B9.27D42.9K18.", "13.12B5.25D44.9K18.",
				"11.14B6.23D45.9K18.", "5.21B5.23D45.1I8K18.", "4.22B5.24D41.3I2d9K16.", "3.23B5.24D40.4I2d11K14.",
				"2.24B5.25D39.5I1d12K13.", "1.25B6.25D34.9I1d15K10.", "1.25B6.27D31.9I2d16K9.",
				"1.26B4.17D1W13D28.9I2d17K8.", "1.26B3.2S13D7W11D15.6I3.12I2d17K8.", "1.27B1.1C2S12D3W3H2W11D14.22I2d18K7.",
				"1.27B3C1S12D2W5H2W10D14.22I1d20K6.", "1.27B3C1S12D1W7H1W12D1.3N8.22I1d20K6.",
				"2.27B1C2S11D2W7H2W10D1X6N7.21I1d19K7.", "3.25B3C1S12D1W7H1W10D2X7N6.21I1d4K2d12K8.",
				"4.24B3C1S5D6V1m2n4Z1H2W10D2X10N3.21I1d1K5d11K9.", "4.24B3C2S2D7V1m1Y2E5Z1n5U3D5X11N1.22I4d2I2d11K8.",
				"5.22B1Q3C3S3V5G2Y10E5U1D2X15N22I2d4I2d11K8.", "5.21B2Q3C3S1l1V7G1Y13E3U1o1X11N2g2N1g28I1d10K9.",
				"5.21B2Q6C1T8G1Y15E1U1o1b12N4g28I10d1K9.", "5.20B2Q7C1T7G2Y17E2b12N1g1s29I5d3I2d10.",
				"5.20B2Q7C1T7G2Y17E3b11N2s1f37I11.", "6.19B2Q7C2T4G3Y20E2b10N1k1M2f41I6.",
				"7.17B2Q9C1T3G3Y22E1b9N2k2M2f41I5.", "7.7B2R8B2Q9C1.3G1Y24E1b9N1k4M2f41I4.",
				"8.6B10R2Q9C3.1G25E1b8N2k4M2f42I3.", "8.6B1R4F6R5.4C4.26E1b7N2k6M2f41I3.", "8.6B1R9F14.26E2b5N2k8M1f41I3.",
				"8.7R9F15.25E2b4N2k9M1f41I3.", "8.3F4R9F16.17E5P2E2b2N3k10M1f41I3.", "8.16F17.14E7P2E2b2N1k11M2f41I3.",
				"8.17F29.1E6P3E2b1N2k11M2f42I2.", "9.15F31.3P3A3E2b1N2k8M4f12I4c28I1.",
				"9.15F32.5A3a2p1j2t6i1M3f13I7c26I1.", "9.5F1.8F34.3A1J4a1p1j2J6i2r13I3c4J3c1I4c20I1.",
				"11.1F4.7F34.3A15J1r1c12I2c7J7c20I1.", "17.5F38.16J2c1I5c5I2c8J3c2J2c19I1.", "18.3F39.17J3c2J8c14J2c19I1.",
				"60.17J2c4J6c15J2c19I1.", "61.44J3c17I1.", "62.43J4c16I1.", "63.43J2c17I1.", "64.42J2c10I7e1.",
				"64.42J2c8I5e4L1.", "63.43J2c6I4e6L2.", "62.44J6c2q2e8L2.", "62.45J4c1J2h9L3.", "63.48J2h11L2.",
				"64.47J2h11L2.", "63.48J1h11L3.", "64.47J2h10L3.", "66.45J1h10L4.", "66.46J10L4.", "65.47J9L5.",
				"64.49J7L6.", "63.49J2.4L8.", "63.38J2.8J4.2L9.", "64.36J5.4J17.", "64.35J27.", "64.35J27.", "65.34J27.",
				"66.11J2.19J28.", "66.10J4.17J29.", "67.8J5.17J29.", "68.1J2.2J10.13J30.", "85.10J31.", "87.5J34.", "126.",
			},
		},
	},
})
