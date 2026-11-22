local _, ns = ...

--[[ The Temple of Atal'Hakkar's fog: its two floors as the journal draws them (Media/Maps/Dungeons/):
     the-temple-of-atal-hakkar-full, the whole temple, and the-temple-of-atal-hakkar-lower, its lowest level,
     both traced from the picture. Pieces are fractions of the visible picture, as the boss spots are; each is
     a mask, Media/Fog/TempleOfAtalHakkar/<floor>/<piece>.tga, split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/TempleOfAtalHakkarFog/fog_spec.py. Every boss's way runs
     back to its floor's way in. Weaver and Dreamscythe share one room, Jammal'an and Ogom another: either
     kill clears it. ]]
ns.AddFog("TempleOfAtalHakkar", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["the-temple-of-atal-hakkar-full"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3160, 0.0000, 0.6780, 0.3193 },
				pit = { 0.3360, 0.1949, 0.6630, 0.7211 },       -- the pit inside the upper ring (on every boss's way: the main level's halls open off it)
				ring = { 0.2940, 0.0750, 0.7610, 0.8591 },       -- the ring and the rooms off it
				balcony_minibosses_1 = { 0.4750, 0.2174, 0.6360, 0.4348 },
				balcony_minibosses_2 = { 0.5330, 0.3373, 0.6750, 0.6042 },
				balcony_minibosses_3 = { 0.4780, 0.4813, 0.6310, 0.7061 },
				balcony_minibosses_4 = { 0.3670, 0.4843, 0.5250, 0.7001 },
				balcony_minibosses_5 = { 0.3250, 0.3478, 0.4660, 0.5757 },
				balcony_minibosses_6 = { 0.3720, 0.2099, 0.5260, 0.4333 },
				east = { 0.5690, 0.2804, 0.8540, 0.7736 },       -- the east wing's hall and arm, and the yard beside it
				jammal_an = { 0.6430, 0.2669, 0.8850, 0.6747 },       -- the pink room (Jammal'an and Ogom, one room)
				weaver = { 0.3770, 0.4078, 0.5440, 0.6432 },       -- the dragons' room round their spots in the pit (Weaver and Dreamscythe, one room)
				morphaz_hall = { 0.3640, 0.7271, 0.6480, 1.0000 },       -- the yellow room (Morphaz's spot a pocket)
				hazzas_hall = { 0.4180, 0.6117, 0.6600, 0.8951 },       -- the south corridor (Hazzas's spot a pocket) and the yard beside it
				morphaz = { 0.4270, 0.7616, 0.5700, 0.9760 },
				atal_alarion = { 0.4260, 0.3433, 0.5760, 0.5682 },       -- the circle at the pit's centre, over the pool where he is called (whole map); the pool (lower)
				west = { 0.1490, 0.1394, 0.4310, 0.6252 },       -- the west wing's north hall and arm, and the yard between the arms
				west_s = { 0.1470, 0.4528, 0.4220, 0.7736 },       -- the west wing's south hall and arm
				avatar_of_hakkar = { 0.1160, 0.2354, 0.3600, 0.6702 },
				hazzas = { 0.4360, 0.6387, 0.5790, 0.8531 },
				shade_of_eranikus = { 0.5400, 0.6897, 0.7960, 1.0000 },
				banner = { 0.2050, 0.0000, 0.8100, 0.1439 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "balcony_minibosses_1", boss = "Balcony Minibosses", pieces = { "balcony_minibosses_1" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "balcony_minibosses_2", boss = "Balcony Minibosses", pieces = { "balcony_minibosses_2" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "balcony_minibosses_3", boss = "Balcony Minibosses", pieces = { "balcony_minibosses_3" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "balcony_minibosses_4", boss = "Balcony Minibosses", pieces = { "balcony_minibosses_4" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "balcony_minibosses_5", boss = "Balcony Minibosses", pieces = { "balcony_minibosses_5" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "balcony_minibosses_6", boss = "Balcony Minibosses", pieces = { "balcony_minibosses_6" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "jammal_an", boss = "Jammal'an the Prophet", pieces = { "jammal_an" }, back = "entrance", way = { "east", "pit", "ring" } },
				{ id = "ogom", boss = "Ogom the Wretched", pieces = { "jammal_an" }, back = "entrance", way = { "east", "pit", "ring" } },
				{ id = "weaver", boss = "Weaver", pieces = { "weaver" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "morphaz", boss = "Morphaz", pieces = { "morphaz" }, back = "entrance", way = { "morphaz_hall", "hazzas_hall", "pit", "ring" } },
				{ id = "atal_alarion", boss = "Atal'alarion", pieces = { "atal_alarion" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "avatar_of_hakkar", boss = "Avatar of Hakkar", pieces = { "avatar_of_hakkar" }, back = "entrance", way = { "west", "west_s", "pit", "ring" } },
				{ id = "dreamscythe", boss = "Dreamscythe", pieces = { "weaver" }, back = "entrance", way = { "pit", "ring" } },
				{ id = "hazzas", boss = "Hazzas", pieces = { "hazzas" }, back = "entrance", way = { "hazzas_hall", "pit", "ring" } },
				{ id = "shade_of_eranikus", boss = "Shade of Eranikus", pieces = { "shade_of_eranikus" }, back = "entrance", way = { "morphaz_hall", "hazzas_hall", "pit", "ring" } },
			},
			where = { cols = 84, rows = 56, keys = "entrance pit ring balcony_minibosses_1 balcony_minibosses_2 balcony_minibosses_3 balcony_minibosses_4 balcony_minibosses_5 balcony_minibosses_6 east jammal_an weaver morphaz_hall hazzas_hall morphaz atal_alarion west west_s avatar_of_hakkar hazzas shade_of_eranikus banner entrance+ring entrance+banner pit+ring pit+balcony_minibosses_1 pit+balcony_minibosses_2 pit+balcony_minibosses_3 pit+balcony_minibosses_4 pit+balcony_minibosses_5 pit+balcony_minibosses_6 pit+weaver pit+atal_alarion ring+balcony_minibosses_1 ring+balcony_minibosses_2 ring+balcony_minibosses_3 ring+balcony_minibosses_4 ring+balcony_minibosses_5 ring+balcony_minibosses_6 ring+east ring+jammal_an ring+hazzas_hall ring+west ring+west_s ring+shade_of_eranikus balcony_minibosses_4+weaver east+jammal_an morphaz_hall+hazzas_hall morphaz_hall+morphaz morphaz_hall+shade_of_eranikus hazzas_hall+hazzas west+west_s west+avatar_of_hakkar west_s+avatar_of_hakkar pit+ring+balcony_minibosses_1 pit+ring+balcony_minibosses_2 pit+ring+balcony_minibosses_3 pit+ring+balcony_minibosses_4 pit+ring+balcony_minibosses_5 pit+ring+balcony_minibosses_6 pit+balcony_minibosses_4+weaver ring+east+jammal_an ring+hazzas_hall+hazzas ring+hazzas_hall+shade_of_eranikus ring+west+west_s morphaz_hall+hazzas_hall+shade_of_eranikus west+west_s+avatar_of_hakkar",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"26.6V22.5V25.", "24.37V23.", "20.45V19.", "19.48V17.", "18.14V20X15V17.", "18.2V2.9V21A11V2.2V17.",
				"18.2V12.20A1V12.2V17.", "32.20A32.", "32.1A6W11A1W1A32.", "32.7W10A2W2C31.", "31.6C5W3A5W4C30.",
				"18.8Q6.6C4W2A5W6C29.", "17.10Q4.10C5W10C28.", "16.12Q3.10C4W13C26.", "16.14Q29C25.", "16.15Q7C2m4Y15C25.",
				"16.14Q2q4C3m2)2B1Y1$3h12C24.", "16.1Q6!8Q2q2C2m2I1e4B1Z3D1h11C24.",
				"15.1S2!4S2!6Q2q3C1)3I2e2B2Z4D1$10C1.8K15.", "13.10S2!5Q1q3C1Y2e1I2e4B2Z1D2Z2Y4C2n2C1o11K13.",
				"13.11S2!4Q1q3C1Y1B2e7B3Z3B1Y3C3n1,1o11K13.", "13.12S1!3Q1q4C1Y16B1Y2C2n2J1u12K13.",
				"13.13S1!2Q1q3C1Y17B1Y2C2n2J1u12K13.", "13.13S1!1Q2q2C1l1(1d5B4g5B2a1i3C1n2J1u12K13.",
				"13.13S1!1Q1q2C1l2H1d4B2g2P2g4B1a2E1i2C1n2J1u12K13.", "13.13S1!1Q1q2C1l3H1d3B1g4P1g3B1a3E1i2C1n2J1u12K13.",
				"13.13S1!1Q1q2C1l2H2d1B2f2g2P2g3B2a2E1i2C1n2J1u12K13.", "13.13S1!1Q2q1C2l2d2f1L2f4g5B2a1E1i2C1n2J1u12K13.",
				"13.13S1!1Q2q2C1(2B1f4L2f8B1a2i1C2n2J1u12K13.", "13.12S2!2Q1:2C1Y2B1f5L1f7B2%1i2C1n3J1u12K13.",
				"13.11S1#1<3z2r1C1Y3B1f4L1f7B1Y3C2n3J2u11K13.", "13.10S2#5R1r2C1Y2B1*2t2f4B4b1Y3C1n5J2u10K13.",
				"14.3S1#5S1#6R2r2C1'1c3G1c4B1b3F1&3C2n6J2u4K2u16.", "16.1R6#7R2r3C1k3G2c3B1b3F1j2C2n8J6u1J16.",
				"16.14R1r5C2k1G1c4B1b2F1j3C2n15J16.", "16.14R1r6C2k1'2Y1B1Y1&2j6C15J16.", "16.13R12C2Y11C14J16.",
				"16.12R1r24C3.12J16.", "17.10R1.11C5p9C4.10J17.", "17.9R3.10C1p2N1y1p9C5.8J18.", "30.9C2N3y1-8C31.",
				"31.7C2N1y3T1-1p7C31.", "32.2C4.2N2y2T1y1p6C1s10U21.", "38.3N3y1N6p1/1s10U21.", "35.4M12N1/11U21.",
				"34.5M11v1;12U21.", "34.7M2w6M1v1x12U21.", "34.6M1w1O2w6M1x12U21.", "34.5M2w2O1w6M1x12U21.",
				"34.6M1w2O1w6M1x12U21.", "34.6M3w7M1x12U21.", "34.15M2x12U21.", "34.15M1x13U21.", "35.8M3.3M14U21.",
				"49.14U21.", "50.13U21.",
			},
		},
		["the-temple-of-atal-hakkar-lower"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.2964, 0.0000, 0.5908, 0.3234 },
				ring = { 0.2485, 0.1527, 0.7535, 1.0000 },       -- the ring and the rooms off it
				atal_alarion = { 0.3054, 0.3219, 0.6906, 0.8533 },       -- the circle at the pit's centre, over the pool where he is called (whole map); the pool (lower)
				spawn_of_hakkar_1 = { 0.5599, 0.6542, 0.6986, 0.8623 },
				spawn_of_hakkar_2 = { 0.4491, 0.2216, 0.5878, 0.4281 },
				banner = { 0.2056, 0.0135, 0.8094, 0.1527 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "atal_alarion", boss = "Atal'alarion", pieces = { "atal_alarion" }, back = "way_in", way = { "ring" } },
				{ id = "spawn_of_hakkar_1", boss = "Spawn of Hakkar", pieces = { "spawn_of_hakkar_1" }, back = "way_in", way = { "ring" } },
				{ id = "spawn_of_hakkar_2", boss = "Spawn of Hakkar", pieces = { "spawn_of_hakkar_2" }, back = "way_in", way = { "ring" } },
			},
			where = { cols = 126, rows = 84, keys = "way_in ring atal_alarion spawn_of_hakkar_1 spawn_of_hakkar_2 banner way_in+ring way_in+banner ring+atal_alarion ring+spawn_of_hakkar_1 ring+spawn_of_hakkar_2",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "38.10F32.9F37.", "37.54F35.", "37.16F2H36F35.", "30.5F2.14F5H35F2.4F29.",
				"28.19F6H2A3H42F26.", "28.17F8H2A12H34F25.", "27.17F2H20A2H33F25.", "27.4F1.12F2H20A1H28F1.5F25.",
				"27.3F3.4F8.22A6.6F2.1F8.5F3.3F25.", "28.2F15.21A32.3F25.", "45.21A60.", "45.7A3.11A60.", "45.6A5.10A60.",
				"45.6A9.6A60.", "45.6A9.6A60.", "46.4A10.6A60.", "46.4A6.1B3.6G60.", "47.3A2.7B7G60.", "49.11B6G60.",
				"49.17B60.", "49.17B60.", "48.18B10.6B44.", "47.17B2K1E1K1B5.9B43.", "47.16B2K1E2K5B1.10B42.",
				"47.15B2K3E2K16B41.", "48.14B2K3E2K17B40.", "48.14B2K2E2K19B39.", "47.16B5K19B39.", "46.19B1K20B40.",
				"45.41B40.", "44.12B2I26B42.", "43.11B5I11B3I11B42.", "42.11B2I2C2I10B5I10B42.",
				"41.12B2I3C1I8B3I2C3I10B41.", "38.15B2I3C2I6B3I4C2I11B40.", "38.15B2I3C2I6B2I5C2I11B40.",
				"39.14B2I4C2I5B2I4C2I12B40.", "39.14B2I4C8I4C2I14B39.", "39.15B2I5C1I3C1I4C3I14B39.", "39.16B2I13C2I16B38.",
				"38.17B2I13C2I16B38.", "38.16B2I14C2I16B38.", "38.16B2I15C2I15B38.", "37.8B4I4B2I16C2I15B38.",
				"37.8B9I18C6I11B37.", "37.7B2I4C4I19C7I9B37.", "36.8B2I32C3I8B37.", "36.8B2I34C2I7B37.",
				"37.7B3I33C2I7B37.", "37.8B9I18C5I3C1I8B37.", "36.12B7I17C9I8B37.", "36.17B2I16C2I5B2I9B37.",
				"37.17B2I15C2I15B38.", "38.16B2I14C2I16B38.", "38.17B2I13C2I16B38.", "39.16B2I13C2I16B38.",
				"39.15B2I4C7I4C2I14B39.", "39.14B2I4C8I4C3I13B39.", "39.13B2I5C2I5B2I4C1I6B1J7B39.",
				"40.11B2I5C2I6B2I4C1I4B5J5B39.", "40.11B2I4C3I7B1I4C1I3B2J2D2J4B40.", "40.12B2I1C4I8B2I2C2I3B2J3D2J3B40.",
				"42.11B5I9B2I1C3I3B2J3D1J3B41.", "42.12B1I12B5I5B5J2B42.", "40.38B3J4B41.", "40.45B41.", "39.46B41.",
				"39.46B41.", "40.45B41.", "41.43B42.", "42.41B43.", "42.41B43.", "42.41B43.", "43.16B2.3B2.16B44.",
				"43.16B8.15B44.", "44.13B10.14B45.", "45.7B15.14B45.", "68.5B1.6B46.", "76.1B49.", "126.", "126.", "126.",
			},
		},
	},
})
