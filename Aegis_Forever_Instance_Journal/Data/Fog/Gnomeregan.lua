local _, ns = ...

--[[ Gnomeregan's fog: its five floors as the journal draws them (Media/Maps/Dungeons/): gnomeregan-full, the
     whole dungeon's map, traced from the picture; gnomeregan-1 to gnomeregan-4, the client's maps 226-229,
     traced from the game's own tiles. Pieces are fractions of the visible picture, as the boss spots are; each
     is a mask, Media/Fog/Gnomeregan/<floor>/<piece>.tga, split into rooms by Dev/maps/FogBuilder/fogbuild.py
     from Dev/maps/GnomereganFog/fog_spec.py. A kill clears the same room on every map that draws it: Viscous
     Fallout's hall on the Hall of Gears' map, Electrocutioner 6000's bay on the Launch Bay's and the Crowd
     Pummeler's labs on Tinkers' Court's are rooms there though the boss's spot is on another floor. ]]
ns.AddFog("Gnomeregan", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Techbot"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["gnomeregan-full"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.6816, 0.0000, 0.8593, 0.2560 },
				upper = { 0.5569, 0.0419, 0.8283, 0.4536 },
				grubbis = { 0.6627, 0.2246, 0.9581, 0.5389 },
				viscous_fallout = { 0.5000, 0.0988, 0.8074, 0.6512 },
				launch_ring = { 0.1796, 0.1856, 0.4790, 0.6407 },
				west_corridor = { 0.3693, 0.1362, 0.6557, 0.5569 },
				electrocutioner_6000 = { 0.2036, 0.2410, 0.4421, 0.5958 },
				labs_pass = { 0.2944, 0.3757, 0.5240, 0.7605 },
				crowd_pummeler_9_60 = { 0.3263, 0.4775, 0.8503, 0.9880 },
				u_passage = { 0.0689, 0.3967, 0.4471, 0.8892 },
				mekgineer_thermaplugg = { 0.0429, 0.1886, 0.2984, 0.6153 },
				banner = { 0.0908, 0.0539, 0.5529, 0.2111 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "grubbis", boss = "Grubbis", pieces = { "grubbis" }, back = "entrance", way = { "upper" } },
				{ id = "viscous_fallout", boss = "Viscous Fallout", pieces = { "viscous_fallout" }, back = "entrance", way = { "upper" } },
				{ id = "electrocutioner_6000", boss = "Electrocutioner 6000", pieces = { "electrocutioner_6000" }, back = "entrance", way = { "launch_ring", "west_corridor", "upper" } },
				{ id = "crowd_pummeler_9_60", boss = "Crowd Pummeler 9-60", pieces = { "crowd_pummeler_9_60" }, back = "entrance", way = { "labs_pass", "launch_ring", "west_corridor", "upper" } },
				{ id = "mekgineer_thermaplugg", boss = "Mekgineer Thermaplugg", pieces = { "mekgineer_thermaplugg" }, back = "crowd_pummeler_9_60", way = { "u_passage" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance upper grubbis viscous_fallout launch_ring west_corridor electrocutioner_6000 labs_pass crowd_pummeler_9_60 u_passage mekgineer_thermaplugg banner entrance+upper upper+grubbis upper+viscous_fallout upper+west_corridor grubbis+viscous_fallout viscous_fallout+west_corridor launch_ring+west_corridor launch_ring+electrocutioner_6000 launch_ring+labs_pass launch_ring+u_passage launch_ring+mekgineer_thermaplugg west_corridor+labs_pass labs_pass+crowd_pummeler_9_60 labs_pass+u_passage crowd_pummeler_9_60+u_passage u_passage+mekgineer_thermaplugg upper+grubbis+viscous_fallout upper+viscous_fallout+west_corridor launch_ring+west_corridor+labs_pass launch_ring+electrocutioner_6000+mekgineer_thermaplugg launch_ring+labs_pass+u_passage launch_ring+u_passage+mekgineer_thermaplugg",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "126.", "97.4A25.", "94.7A25.", "65.1L27.8A25.", "23.9L18.6L7.4L26.8A25.", "21.46L26.8A25.",
				"19.48L26.8A25.", "15.51L27.2M6A25.", "14.45L1.7L25.1B4M4A25.", "13.46L2.7L14.11B5M3A25.",
				"13.46L2.7L12.14B5M1A26.", "12.4L2.15L2.24L2.2L2.4L9.18B3M1A26.", "13.3L40.2L3.2L3.3L8.2B4O4B3O7B2M27.",
				"13.3L49.3L8.3B1O3D5O1D2O7B28.", "14.2L50.1L9.3B1O10D2O6B28.", "72.3F2P2O12D2O3B30.", "67.9F1d1O14D1O3B30.",
				"66.10F1d2O13D2O2B30.", "40.2E23.11F1P1B1O13D2O2B30.", "18.7K12.9E18.12F1P1B1O14D1O2B30.",
				"16.12K6.14E16.12F1P1B1O14D1O2B30.", "15.14K3.17E15.5F7R1d1B1O13D1O3B30.",
				"13.17K2.19E12.5F8R1d1B1O13D2O2B12.4C14.", "13.19K20E11.5F2R6D3O14D1c2N10.6C14.",
				"12.19K1W4E9T8E10.5F2R6D1O1B2O12D2c2N10.7C13.", "11.20K1W3E4T4G4T6E10.5F2R6D1O2B1O11D1O1c1N2C9.9C12.",
				"11.20K1W2E2T9G3T6E9.5F2R6D2O2B2O8D1O1c1N4C9.9C11.",
				"10.21K1W1E2T11G2T5E1S4F5.5F2R7D2O2B8O2c1N6C2.3C2.11C10.", "10.21K1W2T13G2T3E2S6F2.7F5R4D2O2B7O2c25C10.",
				"10.21K1W2T14G2T2E2S20F1R4D6O2D3O1c1Q24C10.", "10.21K1f1T15G2T2E2S20F1R5D4O7D3Q21C11.",
				"10.21K1f1T15G2T2E2S18F3R17D3Q20C11.", "10.21K1f1T16G1T2E2S18F1R20D3Q19C11.",
				"11.20K1f1T16G1T2E2S17F2R21D2Q18C12.", "11.20K1f1T15G2T2E2S14F4R23D1Q18C12.",
				"12.18K1W2T15G2T2E2S1F3X9F1.28D1Q8C2.7C12.", "12.17K1W2E2T14G2T2E1S2e3X8F3.28D11.5C13.",
				"13.15K1b1h2E2T13G2T3E2U1e2H1X6F6.27D11.4C14.", "14.13K2b1V3E2T12G2T2E3U3H2X2F10.26D29.",
				"15.10K3b1J2V2E3T9G3T2E3U7H12.25D29.", "15.6K5b3J3V3E3T5G4T2E3U8H13.24D29.",
				"15.6K1b8J2V4E9T3E3U9H14.23D29.", "15.6K1b9J3V5E4T4E3U11H14.21D30.", "15.7b10J3V11E3U12H15.17D3.5I25.",
				"15.19J4V5E4U13H18.15D3.6I24.", "14.21J7V2g2U13H20.13D3.7I24.", "14.29J2Z12H28.7D4.6I24.",
				"14.29J2Z11H30.5D4.7I24.", "14.29J2Z11H39.6I25.", "14.30J2Z9H40.5I26.", "14.30J2Z8H41.5I26.",
				"14.31J2Z6H17.3I22.5I26.", "14.32J3Z2H17.6I21.5I26.", "14.33J3Z2H15.8I20.5I26.", "15.33J3Z1Y6I9.9I15.9I26.",
				"16.32J2a2Y10I4.11I10.13I26.", "17.30J2a29I8.14I26.", "20.27J2a29I7.15I26.", "24.23J2a30I6.14I27.",
				"28.19J2a30I5.6I5.1I30.", "34.13J2a41I36.", "35.12J1a42I36.", "36.11J1a41I37.", "36.11J1a20I5.16I37.",
				"37.10J1a20I7.13I38.", "38.9J1a20I58.", "39.5J2.2a20I58.", "46.22I58.", "46.21I59.", "46.21I59.",
				"46.21I59.", "47.20I59.", "47.19I60.", "48.18I60.", "51.14I61.", "54.10I62.", "126.", "126.", "126.",
				"126.", "126.", "126.",
			},
		},
		["gnomeregan-1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3952, 0.0075, 0.7295, 0.4177 },
				upper = { 0.4830, 0.2006, 0.7006, 0.7201 },
				grubbis = { 0.5050, 0.4790, 0.8892, 0.8623 },
				clean_zone = { 0.2345, 0.5015, 0.6028, 1.0000 },
				ring_west = { 0.3403, 0.2605, 0.6058, 0.7380 },
				viscous_fallout = { 0.3693, 0.3054, 0.6287, 0.6841 },
				banner = { 0.2994, 0.0165, 0.6976, 0.1377 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "grubbis", boss = "Grubbis", pieces = { "grubbis" }, back = "entrance", way = { "upper" } },
				{ id = "viscous_fallout", boss = "Viscous Fallout", pieces = { "viscous_fallout" }, back = "entrance", way = { "clean_zone", "ring_west", "upper" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance upper grubbis clean_zone ring_west viscous_fallout banner entrance+upper entrance+banner upper+grubbis upper+ring_west upper+viscous_fallout grubbis+ring_west clean_zone+ring_west ring_west+viscous_fallout upper+grubbis+ring_west upper+ring_west+viscous_fallout",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "51.2G19.3G51.", "49.29G48.", "47.34G45.", "43.42G41.", "43.42G41.", "41.25G1I19G40.",
				"39.19G8I6A2I13G39.", "39.18G9I6A12I2G40.", "39.2G16.20A6I1A42.", "58.26A42.", "59.25A42.", "60.24A42.",
				"63.21A42.", "67.17A42.", "74.11A41.", "74.11A41.", "74.11A41.", "74.11A41.", "74.11A41.", "74.11A41.",
				"75.1H1A1H7A41.", "74.1B4H6A41.", "73.3B4H5A41.", "72.5B4H3A42.", "72.6B5H1A42.", "57.12E1.9B4H43.",
				"55.13E2K11B2H43.", "54.13E2K13B44.", "53.14E2K13B44.", "52.6E8O2Q13B45.", "51.5E11O2L11B46.",
				"50.5E3O10F2L9B47.", "49.5E3O12F2L7B48.", "48.5E2O15F2L5B49.", "48.4E2O17F2L4B49.", "48.4E2O18F2L3B49.",
				"48.4E2O18F2L4B48.", "48.4E2O18F2L4B48.", "48.4E2O18F2L3B49.", "48.4E2O18F2L3B49.", "48.4E2O18F2L3B49.",
				"48.4E2O18F2L3B49.", "48.4E2O18F2L4B48.", "48.4E2O18F2L3B20.2C27.", "48.4E2O18F2L3B17.6C26.",
				"45.3D5E2O16F2L4B16.8C25.", "43.6D5E2O14F2L2B1J2B16.8C25.", "42.8D1E1N3E3O11F3L1B2J2C15.9C25.",
				"41.10D2N3E12O1Q2L1B3J3C14.11C23.", "41.11D2N3E11O2Q2B2J5C14.12C21.", "40.13D2N13E2K1B2J7C12.14C20.",
				"41.13D1N14E1K1P1J10C1.6C2.16C19.", "36.19D14E2P36C19.", "35.22D12E2M36C19.", "35.22D1.10E1.1M37C19.",
				"35.23D12.36C20.", "37.20D14.33C22.", "38.19D15.31C23.", "41.15D18.28C24.", "40.16D19.27C24.",
				"39.17D21.26C23.", "39.16D24.11C5.7C24.", "40.15D40.7C24.", "40.14D42.5C25.", "41.13D42.5C25.", "42.23D61.",
				"44.22D60.", "44.23D59.", "45.24D57.", "47.23D56.", "47.24D55.", "49.22D55.", "50.21D55.", "50.21D55.",
				"51.20D55.", "53.18D55.", "54.17D55.", "64.6D56.", "66.2D58.", "126.", "126.", "126.",
			},
		},
		["gnomeregan-2"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.7355, 0.1961, 0.9182, 0.4805 },
				red_hall = { 0.6078, 0.2216, 0.9162, 0.5778 },
				viscous_fallout = { 0.5190, 0.3368, 0.9192, 0.9117 },
				launch_ring = { 0.0439, 0.3772, 0.4910, 0.9895 },
				west_corridor = { 0.3353, 0.3293, 0.7066, 0.8608 },
				electrocutioner_6000 = { 0.0938, 0.4581, 0.3932, 0.9057 },
				banner = { 0.2994, 0.0165, 0.6976, 0.1467 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "viscous_fallout", boss = "Viscous Fallout", pieces = { "viscous_fallout" }, back = "way_in", way = { "red_hall" } },
				{ id = "electrocutioner_6000", boss = "Electrocutioner 6000", pieces = { "electrocutioner_6000" }, back = "way_in", way = { "launch_ring", "west_corridor", "red_hall" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in red_hall viscous_fallout launch_ring west_corridor electrocutioner_6000 banner way_in+red_hall red_hall+viscous_fallout red_hall+west_corridor viscous_fallout+west_corridor launch_ring+west_corridor launch_ring+electrocutioner_6000 red_hall+viscous_fallout+west_corridor",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "51.2G19.3G51.", "49.29G48.", "47.34G45.", "43.42G41.", "43.42G41.", "41.45G40.",
				"39.27G6.15G39.", "39.26G8.13G40.", "39.2G37.5G43.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
				"126.", "126.", "126.", "126.", "126.", "102.1A23.", "90.9B2H4A21.", "88.11B3H4A20.", "87.12B3H5A19.",
				"84.15B3H5A19.", "83.16B3H5A19.", "82.17B4H5A18.", "82.18B3H4A1H1A17.", "82.18B9H17.", "81.20B8H1B16.",
				"73.9E2J18B3H5B16.", "69.13E2J9B6I11B16.", "68.14E2J7B3I4C2I10B16.", "66.16E2J7B2I6C2I9B16.",
				"29.5D32.16E2J6B2I8C1I9B16.", "23.15D27.17E2J6B2I8C2I8B16.", "21.19D24.18E2J6B2I8C2I8B16.",
				"20.22D21.19E2J6B2I8C2I8B16.", "19.24D19.9E11K2N6B2I8C2I8B16.", "17.27D19.8E1K10C10I7C11I16.",
				"16.29D18.8E1K38C16.", "15.11D9M11D17.8E1K37C17.", "14.10D5M3F5M10D16.8E1K37C17.",
				"14.8D4M9F4M9D15.8E2K35C18.", "13.8D3M13F3M8D15.8E3K33C19.", "13.7D3M16F2M7D15.10E1K33C19.",
				"12.7D3M18F2M7D14.10E1K32C20.", "12.7D2M19F2M7D1L6E7.11E30C22.", "11.7D2M21F2M6D1L7E6.10E31C22.",
				"11.7D2M21F2M6D2L22E33C20.", "11.7D1M23F2M4D2L23E34C19.", "11.6D2M23F2M4D2L23E1.34C18.",
				"11.6D2M23F2M4D1L23E3.35C16.", "11.6D2M23F2M4D2L22E4.34C16.", "11.6D2M23F2M4D2L21E6.34C15.",
				"11.6D2M23F2M4D2L21E7.33C15.", "11.6D2M23F2M4D2L19E10.32C15.", "11.6D2M23F2M5D2L17E12.31C15.",
				"11.7D2M22F1M7D2L14E15.30C15.", "11.7D2M21F2M7D2L6E24.29C15.", "12.7D2M20F2M8D2L4E28.26C15.",
				"12.7D2M19F2M10D2L3E28.26C15.", "12.8D2M17F2M12D2L1E30.25C15.", "13.8D2M15F2M13D2L1E30.25C15.",
				"13.9D3M11F3M17D30.25C15.", "14.9D4M7F4M19D29.25C15.", "14.11D11M21D30.23C16.", "15.13D5M24D30.23C16.",
				"17.40D40.1C28.", "18.37D71.", "19.31D76.", "20.29D77.", "23.16D2.7D78.", "25.10D7.5D79.", "30.1D11.4D80.",
				"126.", "126.", "126.", "126.", "126.", "126.",
			},
		},
		["gnomeregan-3"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3363, 0.3174, 0.5240, 0.5853 },
				passages = { 0.2505, 0.2635, 0.4701, 0.7006 },
				crowd_pummeler_9_60 = { 0.2984, 0.3907, 0.9242, 0.9865 },
				electrocutioner_6000 = { 0.1267, 0.0614, 0.4172, 0.6108 },
				banner = { 0.2994, 0.0165, 0.6976, 0.1467 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "crowd_pummeler_9_60", boss = "Crowd Pummeler 9-60", pieces = { "crowd_pummeler_9_60" }, back = "way_in", way = { "passages" } },
				{ id = "electrocutioner_6000", boss = "Electrocutioner 6000", pieces = { "electrocutioner_6000" }, back = "way_in", way = { "passages" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in passages crowd_pummeler_9_60 electrocutioner_6000 banner way_in+passages passages+crowd_pummeler_9_60 passages+electrocutioner_6000",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "51.2E19.3E51.", "49.29E48.", "47.34E45.", "43.42E41.", "43.42E41.", "41.45E40.",
				"39.27E6.15E39.", "39.26E8.13E40.", "33.4D2.2E37.5E43.", "29.11D86.", "27.15D84.", "26.17D83.", "25.19D82.",
				"24.21D81.", "23.23D80.", "23.23D80.", "22.25D79.", "22.25D79.", "21.26D79.", "21.27D78.", "21.27D78.",
				"21.26D79.", "21.26D79.", "21.26D79.", "21.26D79.", "22.25D79.", "22.22D3H79.", "22.21D3H80.",
				"23.19D2H3B79.", "23.18D3H4B78.", "24.16D3H5B78.", "26.11D4H8B77.", "27.10D3H10B5.3A68.",
				"27.10D1H13B3.5A67.", "27.10D14B1F7A67.", "27.8D3.11B2F8A67.", "26.9D4.10B3F6A47.5C16.",
				"26.9D4.10B3F5A47.7C15.", "26.8D6.9B5F2A48.7C15.", "26.8D7.9B4F50.7C15.", "26.8D7.10B3F50.7C15.",
				"25.9D6.13B51.6C16.", "26.7D6.14B51.6C16.", "27.5D6.14B53.5C16.", "38.13B54.5C16.", "38.11B23.3C29.6C16.",
				"39.9B22.6C28.6C16.", "39.9B21.8C27.6C16.", "40.8B21.9C27.5C16.", "42.4B2G12C8.11C17.14C16.",
				"43.1B4G13C6.13C14.16C16.", "44.2G35C11.18C16.", "45.37C10.17C17.", "45.37C9.18C17.", "45.25C2.11C8.16C19.",
				"44.25C4.10C8.6C29.", "44.25C4.10C7.6C30.", "44.25C5.22C30.", "43.26C6.21C30.", "43.26C7.20C30.",
				"43.26C8.18C31.", "43.26C10.16C31.", "42.27C13.7C1.2C34.", "43.26C57.", "43.26C57.", "43.26C57.",
				"43.25C58.", "43.25C58.", "43.24C59.", "43.24C59.", "43.24C59.", "44.23C59.", "45.22C59.", "47.19C60.",
				"51.14C61.", "54.3C4.2C63.", "126.", "126.", "126.", "126.", "126.", "126.",
			},
		},
		["gnomeregan-4"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3463, 0.5838, 0.5509, 0.8952 },
				u_passage = { 0.1926, 0.3802, 0.5409, 0.8039 },
				mekgineer_thermaplugg = { 0.1607, 0.0644, 0.4671, 0.5329 },
				labs_link = { 0.4261, 0.6991, 0.6327, 0.9087 },
				crowd_pummeler_9_60 = { 0.5220, 0.6317, 0.7954, 1.0000 },
				banner = { 0.2994, 0.0165, 0.6976, 0.1422 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "mekgineer_thermaplugg", boss = "Mekgineer Thermaplugg", pieces = { "mekgineer_thermaplugg" }, back = "way_in", way = { "u_passage" } },
				{ id = "crowd_pummeler_9_60", boss = "Crowd Pummeler 9-60", pieces = { "crowd_pummeler_9_60" }, back = "way_in", way = { "labs_link" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in u_passage mekgineer_thermaplugg labs_link crowd_pummeler_9_60 banner way_in+u_passage way_in+labs_link u_passage+mekgineer_thermaplugg mekgineer_thermaplugg+banner labs_link+crowd_pummeler_9_60",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "51.2F19.3F51.", "49.29F48.", "46.35F45.", "43.42F41.", "43.42F41.", "41.45F40.",
				"39.27F6.15F39.", "39.26F8.13F40.", "38.1C2J1C36.5F43.", "34.10C82.", "32.14C80.", "31.17C78.", "30.19C77.",
				"29.21C76.", "28.23C75.", "27.25C74.", "27.25C74.", "26.27C73.", "26.27C73.", "26.27C73.", "25.29C72.",
				"26.28C72.", "25.29C72.", "25.29C72.", "25.29C72.", "25.29C72.", "26.27C73.", "26.27C73.", "27.26C73.",
				"27.25C74.", "28.24C74.", "28.23C75.", "29.21C76.", "30.19C77.", "31.17C78.", "31.15C80.", "31.8I5C82.",
				"31.10B85.", "31.10B85.", "31.10B85.", "31.9B86.", "31.10B14.4B67.", "30.11B13.8B64.", "30.11B13.9B63.",
				"30.11B13.9B63.", "29.12B13.9B63.", "29.11B13.10B63.", "29.10B14.10B63.", "29.11B13.10B63.",
				"30.14B9.9B64.", "30.18B4.10B64.", "30.32B64.", "31.30B65.", "31.24B2G4B65.", "32.20B7G2B65.",
				"33.18B9G66.", "34.17B4G1A4G22.6E38.", "37.13B3G6A22.9E36.", "43.7B3G7A20.11E35.", "45.5B3G7A19.12E35.",
				"50.1B2G8A17.14E34.", "55.7A14.17E33.", "56.5A2H4.5D3.18E33.", "57.3A3H1D1.8D2.19E32.",
				"58.1A4H10D1K21E31.", "59.3H10D3K20E31.", "59.2H11D2K21E31.", "60.8D2.1D2K22E31.", "62.5D4.1K23E31.",
				"71.24E31.", "72.23E31.", "73.21E32.", "74.19E33.", "74.17E35.", "75.15E36.", "76.13E37.", "80.8E38.",
				"126.", "126.", "126.", "126.", "126.",
			},
		},
	},
})
