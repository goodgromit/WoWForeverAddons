local _, ns = ...

--[[ Stratholme's fog: its three floors as the journal draws them, each traced from the journal's own
     picture: stratholme-full (Media/Maps/Dungeons), the whole city on the classic sheet; Stratholme and
     Stratholme1 (Media/Maps/Classic, .blp), Crusader's Square and The Gauntlet, the classic sheet at
     1000 x 667, each with its own frame (its extent, frame = false). Pieces are fractions of the
     visible picture, as the boss spots are; each is a mask,
     Media/Fog/Stratholme/<floor>/<piece>.tga, split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/StratholmeFog/fog_spec.py. A boss others walk past has a pocket round his spot (a rare's
     spot clears with the street round it: rares hold back no fog). On the whole
     map the Main Gate and the Service Gate are both ways in, clear from the start. ]]
ns.AddFog("Stratholme", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Black Guard Swordsmith"] = false, ["Crimson Hammersmith"] = false, ["Postmaster Malown"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["stratholme-full"] = {
			extent = true,              -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = { { 0.6796, 0.8937, 0.9481, 0.9296 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.5050, 0.7919, 0.7325, 1.0000 },
				service_gate = { 0.7545, 0.6392, 0.9102, 0.8728 },
				bastion = { 0.2944, 0.5329, 0.4860, 0.8428 },       -- the Scarlet Bastion's hall, Malor's courtyard, the corridors' junction
				crusaders_square = { 0.3244, 0.4416, 0.6008, 0.8069 },       -- Crusader's Square and Market Row west of the junction
				king_square = { 0.4711, 0.4386, 0.8204, 0.9985 },       -- King's Square: its streets, the south-west street, Festival Lane
				malor = { 0.3373, 0.5913, 0.4750, 0.7979 },
				cannon_master_willey = { 0.1766, 0.6183, 0.4042, 0.8847 },
				stratholme_courier = { 0.5000, 0.7365, 0.6377, 0.9431 },
				the_unforgiven = { 0.5988, 0.4686, 0.7365, 0.6751 },
				timmy = { 0.3942, 0.5269, 0.5319, 0.7320 },
				south_hall = { 0.2904, 0.6916, 0.4331, 0.9746 },       -- the Bastion's corridor south
				archivist_galford = { 0.3114, 0.7949, 0.4611, 1.0000 },
				balnazzar = { 0.2026, 0.7934, 0.4202, 1.0000 },
				gauntlet = { 0.6098, 0.0000, 1.0000, 0.5973 },       -- the Gauntlet's streets, the lanes to Elders' Square and Slaughter Square
				elders_square = { 0.6766, 0.3922, 0.9261, 0.8174 },       -- Elders' Square
				magistrate_barthilas = { 0.6856, 0.0240, 0.8234, 0.2305 },
				nerub_enkan = { 0.6447, 0.2829, 0.8253, 0.5269 },
				slaughter_square = { 0.5080, 0.0000, 0.7555, 0.4147 },       -- Slaughter Square: Ramstein's and the Baron's way
				ramstein = { 0.5868, 0.0599, 0.7265, 0.2650 },
				baroness_anastari = { 0.8343, 0.2725, 1.0000, 0.5644 },
				maleki = { 0.7774, 0.0060, 0.9691, 0.2754 },
				baron_rivendare = { 0.5000, 0.0314, 0.6846, 0.2934 },
				banner = { 0.0519, 0.0210, 0.4431, 0.1647 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "service_gate", start = true, pieces = { "service_gate" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "malor", boss = "Malor the Zealous", pieces = { "malor" }, back = "entrance", way = { "bastion", "crusaders_square", "king_square" } },
				{ id = "cannon_master_willey", boss = "Cannon Master Willey", pieces = { "cannon_master_willey" }, back = "entrance", way = { "bastion", "crusaders_square", "king_square" } },
				{ id = "stratholme_courier", boss = "Stratholme Courier", pieces = { "stratholme_courier" }, back = "entrance", way = { "king_square" } },
				{ id = "the_unforgiven", boss = "The Unforgiven", pieces = { "the_unforgiven" }, back = "entrance", way = { "king_square" } },
				{ id = "timmy", boss = "Timmy the Cruel", pieces = { "timmy" }, back = "entrance", way = { "crusaders_square", "king_square" } },
				{ id = "archivist_galford", boss = "Archivist Galford", pieces = { "archivist_galford" }, back = "entrance", way = { "south_hall", "bastion", "crusaders_square", "king_square" } },
				{ id = "balnazzar", boss = "Balnazzar", pieces = { "balnazzar" }, back = "entrance", way = { "south_hall", "bastion", "crusaders_square", "king_square" } },
				{ id = "magistrate_barthilas", boss = "Magistrate Barthilas", pieces = { "magistrate_barthilas" }, back = "service_gate", way = { "gauntlet", "elders_square" } },
				{ id = "nerub_enkan", boss = "Nerub'enkan", pieces = { "nerub_enkan" }, back = "service_gate", way = { "gauntlet", "elders_square" } },
				{ id = "ramstein", boss = "Ramstein the Gorger", pieces = { "ramstein" }, back = "service_gate", way = { "slaughter_square", "gauntlet", "elders_square" } },
				{ id = "baroness_anastari", boss = "Baroness Anastari", pieces = { "baroness_anastari" }, back = "service_gate", way = { "gauntlet", "elders_square" } },
				{ id = "maleki", boss = "Maleki the Pallid", pieces = { "maleki" }, back = "service_gate", way = { "gauntlet", "elders_square" } },
				{ id = "baron_rivendare", boss = "Baron Rivendare", pieces = { "baron_rivendare" }, back = "ramstein", way = { "slaughter_square" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance service_gate bastion crusaders_square king_square malor cannon_master_willey stratholme_courier the_unforgiven timmy south_hall archivist_galford balnazzar gauntlet elders_square magistrate_barthilas nerub_enkan slaughter_square ramstein baroness_anastari maleki baron_rivendare banner entrance+king_square service_gate+elders_square bastion+crusaders_square bastion+malor bastion+cannon_master_willey bastion+south_hall crusaders_square+king_square crusaders_square+malor crusaders_square+timmy king_square+stratholme_courier king_square+the_unforgiven king_square+gauntlet king_square+elders_square cannon_master_willey+south_hall south_hall+archivist_galford south_hall+balnazzar archivist_galford+balnazzar gauntlet+elders_square gauntlet+magistrate_barthilas gauntlet+nerub_enkan gauntlet+slaughter_square gauntlet+baroness_anastari gauntlet+maleki slaughter_square+ramstein slaughter_square+baron_rivendare bastion+crusaders_square+malor bastion+cannon_master_willey+south_hall king_square+gauntlet+elders_square south_hall+archivist_galford+balnazzar slaughter_square+ramstein+baron_rivendare",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "76.11R39.", "75.14R37.", "14.13W5.13W28.17R36.", "14.31W26.20R4N31.",
				"8.4W2.31W3.2W20.20R8N7.3N6.1U11.", "7.38W2.6W16.19R2r9N3.5N1t9U9.", "7.38W2.7W15.18R2r5N2p10N2t9U9.",
				"7.38W2.7W15.3R6v8R2r4N6p7N2t10U9.", "8.37W2.8W14.2R3v2V3v8R1r4N2p2P2p7N2t10U9.",
				"10.7W24.8W3.3W14.2R1v6V2v1R3u3R1r4N1p4P1p7N2t10U9.", "43.6W3.3W14.10V1v5u2R1r4N2p3P1p7N2t9U10.",
				"45.2W5.2W14.11V1v1!3S2u1R1r4N6p6N3t8U11.", "68.11V2!4S1u1R1r5N4p6N2t10U11.",
				"68.11V1v1!3S2u2r15N2t7U1t2U11.", "69.10V1v6u2r15N2t3U6t12.", "70.8V2v1R4u2r17N5t3N1t1N12.",
				"70.1R3v2V3v6R2r18N3t5N13.", "70.2R6v6R2r26N14.", "70.14R2r27N13.", "71.13R2r27N13.", "71.12R2r29N12.",
				"71.12R2r30N11.", "72.11R2r2N2.26N5.2N4.", "74.9R3N3.26N4.4N3.", "73.8R3.1N4.27N2.6N2.", "72.8R8.36N2.",
				"71.7R9.36N3.", "71.6R8.31N4s3N3.", "72.4R8.5N8q15N9s2N3.", "84.4N10q13N4s5T2s2N2.",
				"83.4N3q7Q2q12N1s9T2s1N2.", "82.5N2q8Q2q11N2s9T2s3.", "82.5N1q9Q1q13N1s11T3.", "82.5N1q8Q2q13N3s9T3.",
				"82.5N2q6Q2q15N3s8T3.", "84.3N2q5Q2q18N2s6T4.", "84.4N7q20N1s5T5.", "85.4N5q2N1o18N1s5T5.",
				"85.9N6o16N5T5.", "86.7N3o2O4o14N5T5.", "85.7N3o5O6o5N5.4T6.", "62.6D1d2E14.1i1N2i3N2o9O4o1N10.1T7.",
				"61.7D2d2E6.8E5i2o13O1o1O18.", "54.3D4.7D2d2E5.13E1i1y17O17.", "50.8D2.8D2d3E2.7E4h5E1j18O16.",
				"47.21D2d11E2h2I2h4E1j18O16.", "47.21D2d11E1h4I1h4E1j18O16.", "47.21D2d11E1h4I1h4E1j19O15.",
				"47.21D2d11E2h2I2h4E1j19O15.", "48.3Z5D5f7D2d12E4h5E2j18O15.", "48.1C3Z3D2f2J2f7D2d22E2j17O15.",
				"47.4C2Z2D2f3J2f6D2d23E5j13O15.", "47.5C1Z2D2f3J2f6D2d26E2j13O15.", "48.3C2Z2D3f1J2f8D1d26E2j13O15.",
				"44.4C2F1a2w3D4f8D2d26E2j14O14.", "44.4C3F1w2e13D3d26E2j13O15.", "44.4C5F1e11D2.29E2j13O15.",
				"28.11G5.4C1a4F1w2Z9D2.29E2j12O16.", "28.11G4.5C2a2F2a2Z8D3.30E1j12O16.",
				"28.11G4.6C5a1C7D5.30E3.3O5Y2O16.", "29.11G2.2b6C4a1C6D5.30E5.1O7Y17.", "28.14G3b8C5.2D5.30E7.6Y18.",
				"28.15G2x1b2C17.30E7.5B19.", "29.14G1k2x1c1C18.28E8.5B19.", "29.14G1k3K19.27E9.4B20.", "30.12G5K18.26E35.",
				"32.6G2.2G6K16.6E3g17E36.", "33.4G5.6K16.5E5g15E37.", "43.6K15.4E2g3H2g12E39.", "43.6K16.3E2g3H2g12E39.",
				"42.7K16.3E2g3H2g12E39.", "42.1K1m5K3L13.4E5g9E1X1E41.", "42.1K1m3K2l4L12.5E3g5E6X1E41.",
				"31.12M2m1K2l5L13.8E10X42.", "31.13M1m1z1l6L13.6E12X1A41.", "31.14M2n5L15.5E3X10A41.",
				"33.13M1n5L18.2E2X11A41.", "34.12M1n4L20.14A41.", "41.7M23.14A41.", "41.6M25.12A42.", "42.5M28.6A45.",
				"126.", "126.",
			},
		},
		["Stratholme"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.5170, 0.6687, 0.8150, 1.0000 },
				bastion = { 0.1400, 0.1604, 0.4120, 0.6627 },       -- the Scarlet Bastion's hall, Malor's courtyard, the corridors' junction
				crusaders_square = { 0.2230, 0.0495, 0.6100, 0.5532 },       -- Crusader's Square and Market Row west of the junction
				king_square = { 0.4410, 0.0000, 1.0000, 0.8876 },       -- King's Square: its streets, the south-west street, Festival Lane
				malor = { 0.2290, 0.3088, 0.3670, 0.5142 },
				cannon_master_willey = { 0.0000, 0.3418, 0.2440, 0.6897 },
				stratholme_courier = { 0.5020, 0.5532, 0.6400, 0.7601 },
				the_unforgiven = { 0.6690, 0.1004, 0.8070, 0.3073 },
				timmy = { 0.3250, 0.1979, 0.4630, 0.4033 },
				south_hall = { 0.1330, 0.4843, 0.3180, 0.8771 },       -- the Bastion's corridor south
				archivist_galford = { 0.1880, 0.6522, 0.3430, 0.8801 },
				balnazzar = { 0.1200, 0.6912, 0.3730, 0.9610 },
				banner = { 0.3200, 0.0195, 0.7310, 0.1664 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "malor", boss = "Malor the Zealous", pieces = { "malor" }, back = "way_in", way = { "bastion", "crusaders_square", "king_square" } },
				{ id = "cannon_master_willey", boss = "Cannon Master Willey", pieces = { "cannon_master_willey" }, back = "way_in", way = { "bastion", "crusaders_square", "king_square" } },
				{ id = "stratholme_courier", boss = "Stratholme Courier", pieces = { "stratholme_courier" }, back = "way_in", way = { "king_square" } },
				{ id = "the_unforgiven", boss = "The Unforgiven", pieces = { "the_unforgiven" }, back = "way_in", way = { "king_square" } },
				{ id = "timmy", boss = "Timmy the Cruel", pieces = { "timmy" }, back = "way_in", way = { "crusaders_square", "king_square" } },
				{ id = "archivist_galford", boss = "Archivist Galford", pieces = { "archivist_galford" }, back = "way_in", way = { "south_hall", "bastion", "crusaders_square", "king_square" } },
				{ id = "balnazzar", boss = "Balnazzar", pieces = { "balnazzar" }, back = "way_in", way = { "south_hall", "bastion", "crusaders_square", "king_square" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in bastion crusaders_square king_square malor cannon_master_willey stratholme_courier the_unforgiven timmy south_hall archivist_galford balnazzar banner way_in+king_square bastion+crusaders_square bastion+malor bastion+cannon_master_willey bastion+south_hall crusaders_square+king_square crusaders_square+timmy crusaders_square+banner king_square+stratholme_courier king_square+the_unforgiven king_square+banner south_hall+archivist_galford south_hall+balnazzar archivist_galford+balnazzar crusaders_square+king_square+banner south_hall+archivist_galford+balnazzar",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "125.", "51.30M44.", "51.30M44.", "45.42M9.4D25.", "43.16M11U18M7.6D24.",
				"42.15M14U17M1X5.7D3.1D20.", "41.1M7U7M16U8M10X2D2.14D17.", "41.28U4b2X2M13X19D16.",
				"40.1C19U8C6b16X19D16.", "39.2C18U9C1S5b16X19D16.", "38.4C2U4C2U18C5S7D2X5D2X20D16.", "35.33C5S36D16.",
				"34.35C3S18D4W15D16.", "33.36C2S18D2W2H2W16D14.", "33.36C2S18D1W4H1W17D13.", "33.36C2S18D1W4H1W18D12.",
				"33.36C2S18D2W2H2W18D12.", "32.1B2O34C2S19D4W26D5.", "32.2B2O33C2S50D4.", "32.3B2O32C2S50D4.",
				"32.4B2O9C4T18C2S50D4.", "32.5B2O7C3T1I2T17C2S50D4.", "31.7B1O1B6C2T3I1T17C1S50D5.",
				"31.11B4C1T4I2T15C2S44D11.", "32.11B3C2T2I2T16C2S43D12.", "33.10B4C5T16C2S43D12.",
				"27.2B4.11B4C2T17C2S45D11.", "27.3B4.10B23C2S46D10.", "26.5B2.11B19C1.2C2S48D9.",
				"25.10B4P5B1.15C4.2C2S50D7.", "25.10B5P5B15C5.2S51D7.", "26.8B2P3E1P5B15C4.54D7.",
				"5.11F10.8B1P4E2P3B2O13C4.55D7.", "5.12F9.8B2P3E1P4B2O13C5.53D8.", "5.12F9.8B6P4B2O12C6.53D8.",
				"5.12F8.11B3P6B1O11C8.51D9.", "5.13F6.20B2O8C12.46D13.", "4.14F5.21B2O8C9.49D13.",
				"2.17F3.18B4.1B1O1C2.4C9.49D14.", "2.18F2.16B24.48D15.", "1.22F2Q8B29.48D15.", "1.22F2Q7B29.48D16.",
				"1.23F1Q6B31.47D16.", "2.22F1Q6B31.46D17.", "3.20F2J7B31.39D2.3D18.", "4.18F3J4R3B31.39D23.",
				"4.18F4J3R3B30.41D22.", "5.10F1.5F1.6J1R3B29.42D22.", "6.7F9.7J2B29.43D22.", "6.6F11.8J29.36D2.5D22.",
				"8.3F13.10J26.9D4V23D3.3D23.", "24.11J25.8D3V1G2V22D29.", "25.10J26.7D2V3G2V21D29.",
				"24.11J26.7D2V3G2V21D29.", "23.11J27.7D2V2G2V22D29.", "23.11J27.8D5V21D30.", "23.11J27.31D33.",
				"22.12J28.30D33.", "23.9J2Y3K25.30D33.", "23.9J1Y5K25.29D33.", "24.7J1Y5K26.28D1N1D32.",
				"24.1L2J1Z2J2Y6K26.13D16N32.", "22.4L4Z2Y6K26.11D18N1A31.", "21.7L1Z1c1Y6K28.9D5N16A30.",
				"21.7L1Z1c1a5K29.8D5N17A30.", "20.8L2Z1a3K35.3D4N19A30.", "20.10L2a2K37.1D3N20A30.", "20.21L31.23A30.",
				"20.22L30.23A30.", "21.21L30.22A31.", "21.21L31.2A2.12A2.1A33.", "23.18L36.11A37.", "31.9L37.12A36.",
				"31.8L38.11A37.", "77.9A39.", "78.6A41.", "125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["Stratholme1"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.5320, 0.6867, 0.7800, 1.0000 },
				gauntlet = { 0.4030, 0.0000, 0.8840, 0.6702 },       -- the Gauntlet's streets, the lanes to Elders' Square and Slaughter Square
				elders_square = { 0.4780, 0.4948, 0.7620, 0.9100 },       -- Elders' Square
				magistrate_barthilas = { 0.5010, 0.0540, 0.6390, 0.2594 },
				nerub_enkan = { 0.4510, 0.3553, 0.6410, 0.6147 },
				slaughter_square = { 0.2790, 0.0000, 0.5620, 0.4858 },       -- Slaughter Square: Ramstein's and the Baron's way
				ramstein = { 0.3860, 0.0960, 0.5260, 0.3013 },
				baroness_anastari = { 0.6750, 0.3373, 0.8740, 0.6717 },
				maleki = { 0.6090, 0.0165, 0.8220, 0.3133 },
				baron_rivendare = { 0.2930, 0.0570, 0.4840, 0.3403 },
				banner = { 0.0350, 0.7736, 0.4460, 0.9280 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "magistrate_barthilas", boss = "Magistrate Barthilas", pieces = { "magistrate_barthilas" }, back = "way_in", way = { "gauntlet", "elders_square" } },
				{ id = "nerub_enkan", boss = "Nerub'enkan", pieces = { "nerub_enkan" }, back = "way_in", way = { "gauntlet", "elders_square" } },
				{ id = "ramstein", boss = "Ramstein the Gorger", pieces = { "ramstein" }, back = "way_in", way = { "slaughter_square", "gauntlet", "elders_square" } },
				{ id = "baroness_anastari", boss = "Baroness Anastari", pieces = { "baroness_anastari" }, back = "way_in", way = { "gauntlet", "elders_square" } },
				{ id = "maleki", boss = "Maleki the Pallid", pieces = { "maleki" }, back = "way_in", way = { "gauntlet", "elders_square" } },
				{ id = "baron_rivendare", boss = "Baron Rivendare", pieces = { "baron_rivendare" }, back = "ramstein", way = { "slaughter_square" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in gauntlet elders_square magistrate_barthilas nerub_enkan slaughter_square ramstein baroness_anastari maleki baron_rivendare banner way_in+elders_square gauntlet+elders_square gauntlet+magistrate_barthilas gauntlet+nerub_enkan gauntlet+slaughter_square gauntlet+baroness_anastari gauntlet+maleki slaughter_square+ramstein slaughter_square+baron_rivendare slaughter_square+ramstein+baron_rivendare",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "56.4F65.", "50.12F63.", "48.16F1P60.", "47.16F3P59.", "43.20F3P1.3B55.",
				"41.22F2P9B9.1B5.1I3.2I30.", "41.21F2P11B6.4B3R9I28.", "40.22F2P12B4.5B2R10I28.", "40.22F1P21B2R12I27.",
				"41.5F5T10F2P6B4N11B2R12I27.", "41.3F9T9F1P5B2N2D2N9B2R13I27.", "42.1F3T5J3T8F1P5B2N3D1N9B2R12I28.",
				"41.1F2T8J2T2F2S4F1P5B2N3D1N9B2R11I29.", "41.3T9J2T5S2F1P5B2N2D2N9B2R11I29.",
				"40.2F1T10J1T1U1S2G2S2F1P6B4N9B3R11I29.", "40.2F1T10J1T1U4G1S2F1P19B1R13I29.",
				"40.2F1T10J1T1U4G1S2F1P18B2R4I1R4I1R2I30.", "40.2F2T9J1T1U5S1F2P18B2R3I7R1I31.",
				"41.1F2T8J2T1F4S2F2P19B11R32.", "41.1F3T7J2T6F2P21B3R6B33.", "42.2F3T3J3T7F2P30B33.", "42.3F7T7F2P30B34.",
				"43.16F2P31B33.", "43.15F2P5B2.26B32.", "42.16F2P5B2.26B32.", "43.15F2P4B3.27B31.",
				"43.14F2P4B3.28B7.2B22.", "44.13F2P2B4.29B5.6B20.", "46.10F3P1B4.31B3.7B20.", "46.9F1.1F1P1B5.32B2.7B20.",
				"44.10F10.42B19.", "43.8F12.42B20.", "43.7F11.44B20.", "44.6F10.34B7Q3B21.", "45.3F11.6B8O19B5Q2H3Q2B21.",
				"59.4B11O16B4Q6H3Q2B20.", "57.5B3O8E2O15B2Q9H3Q1B20.", "56.6B2O9E2O15B1Q11H2Q1B20.",
				"55.7B2O9E2O15B1Q11H2Q1B20.", "55.7B1O9E2O16B2Q10H2Q21.", "55.7B1O9E2O17B2Q11H21.",
				"56.6B2O7E2O19B2Q10H21.", "57.5B3O5E2O21B3Q7H22.", "59.4B4O1E3O22B3Q7H22.", "59.5B6O22B3Q7H23.",
				"60.32B2Q8H23.", "61.14B3M14B1Q9H23.", "61.13B2C4M11B3.8H23.", "62.9B2.5C6M3B8.7H23.", "73.8C4M1B10.5H24.",
				"74.13C38.", "74.14C37.", "73.16C36.", "73.17C35.", "72.18C35.", "65.24C36.", "65.24C36.", "65.24C36.",
				"65.25C35.", "65.25C35.", "67.23C35.", "72.18C35.", "72.18C35.", "73.17C35.", "72.17C1L35.",
				"15.30K27.14C4L35.", "15.30K27.10C5L3A35.", "10.36K1.3K22.5C6L7A35.", "8.44K20.6L11A36.",
				"6.47K19.1C2L13A37.", "6.48K23.11A37.", "5.50K23.10A37.", "5.50K23.9A38.", "5.50K24.7A39.",
				"6.9K28.12K24.6A40.", "8.4K35.6K26.6A40.", "80.5A40.", "81.3A41.", "125.", "125.", "125.", "125.", "125.",
			},
		},
	},
})
