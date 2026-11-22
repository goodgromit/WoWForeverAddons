local _, ns = ...

--[[ Maraudon's fog: its three floors as the journal draws them. maraudon-full, the whole dungeon's map (Media/Maps/
     Dungeons/maraudon-full.tga), and Maraudon and Maraudon1, the client's two maps as the journal keeps them
     (Media/Maps/Classic/Maraudon.blp, Maraudon1.blp: the client's drawing scaled to 1000 x 667), each traced from
     the picture. Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/Maraudon/<floor>/<piece>.tga, split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/MaraudonFog/fog_spec.py. Both doors start clear; every way runs back to its wing's door (the
     Wicked Grotto's or the orange one), on Zaetar's Grave to where Poison Falls comes down. ]]
ns.AddFog("Maraudon", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Maraudos"] = false, ["Veng"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["maraudon-full"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.4130, 0.1484, 0.5870, 0.4393 },
				orange_door = { 0.3690, 0.0210, 0.5180, 0.2429 },
				foulspore = { 0.1900, 0.0585, 0.3830, 0.3163 },
				noxious_hollow = { 0.2560, 0.0000, 0.5100, 0.3043 },
				razorlash = { 0.1560, 0.0075, 0.3280, 0.2714 },
				lower_caves = { 0.1840, 0.5097, 0.5140, 1.0000 },
				earth_song_falls = { 0.0250, 0.2999, 0.3550, 0.7946 },
				landslide = { 0.2400, 0.4873, 0.4020, 0.7256 },
				rotgrip = { 0.2410, 0.7376, 0.4030, 0.9805 },
				noxxion = { 0.2500, 0.0000, 0.4040, 0.1694 },
				bottom_passage = { 0.2390, 0.2984, 0.4270, 0.5532 },
				west_passage = { 0.3200, 0.2024, 0.5410, 0.5232 },
				wicked_grotto = { 0.3930, 0.1694, 0.5610, 0.4363 },
				lord_vyletongue = { 0.2450, 0.2054, 0.4110, 0.4513 },
				poison_falls = { 0.1180, 0.1139, 0.4310, 0.5112 },
				celebras = { 0.0960, 0.2084, 0.2850, 0.4678 },
				tinkerer_gizlock = { 0.3080, 0.1109, 0.4920, 0.3733 },
				princess_theradras = { 0.0910, 0.6342, 0.3850, 1.0000 },
				banner = { 0.4510, 0.0120, 0.8510, 0.1739 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "orange_door", start = true, pieces = { "orange_door" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "razorlash", boss = "Razorlash", pieces = { "razorlash" }, back = "orange_door", way = { "foulspore", "noxious_hollow" } },
				{ id = "landslide", boss = "Landslide", pieces = { "landslide" }, back = "celebras", way = { "lower_caves", "earth_song_falls" } },
				{ id = "rotgrip", boss = "Rotgrip", pieces = { "rotgrip" }, back = "celebras", way = { "lower_caves", "earth_song_falls" } },
				{ id = "noxxion", boss = "Noxxion", pieces = { "noxxion" }, back = "orange_door", way = { "noxious_hollow" } },
				{ id = "lord_vyletongue", boss = "Lord Vyletongue", pieces = { "lord_vyletongue" }, back = "entrance", way = { "bottom_passage", "west_passage", "wicked_grotto" } },
				{ id = "celebras", boss = "Celebras the Cursed", pieces = { "celebras" }, back = "orange_door", way = { "poison_falls", "foulspore", "noxious_hollow" } },
				{ id = "tinkerer_gizlock", boss = "Tinkerer Gizlock", pieces = { "tinkerer_gizlock" }, back = "entrance", way = { "west_passage", "wicked_grotto" } },
				{ id = "princess_theradras", boss = "Princess Theradras", pieces = { "princess_theradras" }, back = "celebras", way = { "lower_caves", "earth_song_falls" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance orange_door foulspore noxious_hollow razorlash lower_caves earth_song_falls landslide rotgrip noxxion bottom_passage west_passage wicked_grotto lord_vyletongue poison_falls celebras tinkerer_gizlock princess_theradras banner entrance+west_passage entrance+wicked_grotto orange_door+noxious_hollow orange_door+banner foulspore+noxious_hollow foulspore+razorlash foulspore+poison_falls noxious_hollow+noxxion noxious_hollow+poison_falls noxious_hollow+banner lower_caves+earth_song_falls lower_caves+landslide lower_caves+rotgrip lower_caves+princess_theradras earth_song_falls+landslide earth_song_falls+celebras earth_song_falls+princess_theradras rotgrip+princess_theradras bottom_passage+west_passage bottom_passage+lord_vyletongue bottom_passage+poison_falls west_passage+wicked_grotto west_passage+poison_falls west_passage+tinkerer_gizlock wicked_grotto+tinkerer_gizlock lord_vyletongue+poison_falls poison_falls+celebras poison_falls+tinkerer_gizlock entrance+west_passage+wicked_grotto foulspore+noxious_hollow+poison_falls noxious_hollow+poison_falls+tinkerer_gizlock lower_caves+earth_song_falls+landslide lower_caves+earth_song_falls+princess_theradras lower_caves+rotgrip+princess_theradras bottom_passage+west_passage+poison_falls bottom_passage+lord_vyletongue+poison_falls west_passage+wicked_grotto+tinkerer_gizlock west_passage+lord_vyletongue+poison_falls west_passage+poison_falls+tinkerer_gizlock",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.8J3.5D72.", "37.9J9D12.10S9.9S30.", "36.9J11D10.30S1.6S22.", "36.9J1a12D5.1S2.38S21.",
				"37.6J2a13D1.6S1.30S1.8S20.", "26.9E2.5J2a14D47S20.", "25.10E3.6a14D1c46S20.", "25.10E3.4a12D4V1D46S20.",
				"25.10E2.16D6V46S20.", "26.8E1.2C1X15D5V1c36S3.2S2.3S20.", "26.7E1Y3C3X1D1X11D1V3B1W32S11.4S20.",
				"26.6E3Y3C5X10D4B1.21S1.10S12.2S21.", "26.6E2Y7C1X11D6.10S4.6S2.8S36.", "25.7E1Y7C2X9D2Q72.",
				"26.5E2Y7C2X3D3b2D3Q72.", "28.1E3Y8C2X2D1b2x1u6Q71.", "29.11C2X1D2b2u8Q70.", "29.4C7Z2w2b2u9Q70.",
				"22.7O4C7O1Z1w1b1O1u11Q7.2U60.", "22.7O4C11O1u10Q2r4M4U60.", "21.8O3C12O1u10Q1r5M4U60.",
				"20.24O2u8Q1q1%4M3U3A59.", "20.6t12O6s1O2u5Q2q2%4M3U3A59.", "20.3t2P3t9O3s3N2s1O1'7q1L1o3M3U4A59.",
				"19.7P2t9O2s5N2s1'4q4L1o2M4U4A59.", "19.8P1t8O2s6N1s1&1p8L2o1M3U5A59.", "19.9P8O1s7N1s1&1p8L2o1M3U5A59.",
				"18.11P7O1s7N1s1&1p8L2o1M1U2v1T4A59.", "17.13P6O2s6N1s1&1p8L2o1M1o2v1A63.", "17.12P1i1G5O2s4N3s2p9L3o3L63.",
				"18.8P4i2G4O2$4m2$2O1p15L63.", "18.12i2G4O1n1$4K4n2#14L63.", "18.7i7G4O2n8K2l13L64.",
				"18.13G1.4O2n8K2l12L65.", "17.15G4O2n8K1l7L71.", "13.19G3O2n9K1.7L71.", "13.20G2O1.10K3.5L71.",
				"12.24G10K4.2L73.", "10.26G1.9K79.", "9.27G2.5K82.", "8.29G88.", "8.29G88.", "8.30G87.", "8.31G86.",
				"8.31G86.", "8.30G1h3H83.", "8.28G3h4H82.", "8.28G2h5H2e5F2.3F70.", "8.27G2h6H2e10F70.",
				"8.27G2h6H2e11F69.", "8.27G2h6H2e11F69.", "10.25G2h6H2e11F69.", "11.25G2y4H2e12F69.", "16.20G1d1y5e13F69.",
				"16.19G2d2F2e15F69.", "20.15G2d19F69.", "21.13G2d20F69.", "22.11G2d21F69.", "22.1G8j3d23F68.",
				"22.2R2j3R2z2d24F68.", "21.7R4g25F68.", "20.9R3g25F68.", "20.9R3g24F69.", "19.11R2g25F68.",
				"19.11R2g25F68.", "18.12R2g25F68.", "18.12R2g6F4f15F68.", "17.13R2g5F6f15F67.", "17.13R2g4F2f4I2f15F66.",
				"17.13R2g4F1f6I2f14F66.", "17.13R2g3F2f6I2f14F66.", "16.14R2g3F2f6I2f14F66.", "16.14R2g3F2f6I2f13F67.",
				"17.13R2g4F2f4I2f14F67.", "19.12R7g1!1k4f15F66.", "20.21R1g17F66.", "21.20R2g15F67.", "22.5R1.14R1g14F68.",
				"29.13R1g14F68.", "40.2R1g14F68.", "40.2R1g14F68.", "42.14F69.", "125.",
			},
		},
		["Maraudon"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.6820, 0.4993, 0.8620, 0.7961 },
				orange_door = { 0.5340, 0.1529, 0.7050, 0.4063 },
				foulspore = { 0.0890, 0.1694, 0.5310, 0.8486 },
				noxious_hollow = { 0.2610, 0.0000, 0.7080, 0.5757 },
				razorlash = { 0.0740, 0.2129, 0.2490, 0.4663 },
				noxxion = { 0.2760, 0.0000, 0.4400, 0.2234 },
				bottom_passage = { 0.1650, 0.6837, 0.5350, 1.0000 },
				meshlok_ground = { 0.4120, 0.6522, 0.6350, 1.0000 },
				west_passage = { 0.4220, 0.5127, 0.6720, 0.8096 },
				wicked_grotto = { 0.4470, 0.4513, 0.8410, 0.8786 },
				lord_vyletongue = { 0.2520, 0.5817, 0.5320, 0.9175 },
				tinkerer_gizlock = { 0.4220, 0.3733, 0.6790, 0.7001 },
				banner = { 0.4930, 0.0045, 0.9030, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "orange_door", start = true, pieces = { "orange_door" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "razorlash", boss = "Razorlash", pieces = { "razorlash" }, back = "orange_door", way = { "foulspore", "noxious_hollow" } },
				{ id = "noxxion", boss = "Noxxion", pieces = { "noxxion" }, back = "orange_door", way = { "noxious_hollow" } },
				{ id = "lord_vyletongue", boss = "Lord Vyletongue", pieces = { "lord_vyletongue" }, back = "way_in", way = { "bottom_passage", "meshlok_ground", "west_passage", "wicked_grotto" } },
				{ id = "tinkerer_gizlock", boss = "Tinkerer Gizlock", pieces = { "tinkerer_gizlock" }, back = "way_in", way = { "west_passage", "wicked_grotto" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in orange_door foulspore noxious_hollow razorlash noxxion bottom_passage meshlok_ground west_passage wicked_grotto lord_vyletongue tinkerer_gizlock banner way_in+wicked_grotto orange_door+noxious_hollow foulspore+noxious_hollow foulspore+razorlash foulspore+bottom_passage foulspore+west_passage foulspore+lord_vyletongue foulspore+tinkerer_gizlock noxious_hollow+noxxion noxious_hollow+tinkerer_gizlock bottom_passage+meshlok_ground bottom_passage+lord_vyletongue meshlok_ground+wicked_grotto meshlok_ground+lord_vyletongue west_passage+wicked_grotto west_passage+lord_vyletongue west_passage+tinkerer_gizlock wicked_grotto+tinkerer_gizlock foulspore+noxious_hollow+tinkerer_gizlock foulspore+bottom_passage+lord_vyletongue foulspore+west_passage+lord_vyletongue foulspore+west_passage+tinkerer_gizlock bottom_passage+meshlok_ground+lord_vyletongue meshlok_ground+west_passage+wicked_grotto meshlok_ground+west_passage+lord_vyletongue west_passage+wicked_grotto+tinkerer_gizlock",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "48.4D23.6M13.6M25.", "43.11D18.30M23.", "40.2D2V11D16.33M21.", "39.2D7V8D10.43M16.",
				"38.3D2V3F3V7D8.47M14.", "38.2D2V5F2V6D8.48M14.", "38.2D1V7F2V5D8.8M1.40M13.", "38.2D1V7F2V5D8.8M1.40M13.",
				"38.2D1V7F2V5D8.7M32.4M3.3M13.", "38.2D2V5F2V6D8.5M40.3M14.", "39.1D3V3F3V23D2.5D30.1M15.", "40.1D7V34D43.",
				"41.42D42.", "41.43D41.", "41.43D41.", "42.42D41.", "42.42D41.", "42.41D42.", "41.35D5O1D43.",
				"29.9C3.34D7O43.", "29.9C3.33D7O44.", "18.6C2.2C1.9C2.33D4O4B44.", "17.7Q15C1.33D3O5B44.",
				"16.2E6Q16C32D2.7B44.", "15.8E2Q15C4P28D3.5B45.", "15.9E1Q16C7P25D2.3B47.", "14.10E2Q18C4P24D53.",
				"14.10E2Q19C2P25D53.", "14.10E2Q19C2P25D53.", "14.10E1Q20C2P25D53.", "14.9E2Q20C1P26D53.",
				"15.5E4Q21C2P26D52.", "18.1E3Q23C2P26D52.", "20.1Q25C2P24D53.", "22.24C2P24D53.", "22.24C2P23D2W52.",
				"22.24C2P21D4W3L49.", "23.23C2P16D8W5L48.", "23.23C2P11D1P1f7W9L48.", "22.25C2P7D3P2f2W14L48.",
				"18.1C2.26C12P2U16L48.", "17.31C7P4C1U17L48.", "17.42C1U18L18.1J28.", "16.43C1U19L14.5J27.",
				"16.43C1U19L1e4.5J4.5J27.", "17.42C1U17L3e18J27.", "17.42C1U17L2e19J27.", "18.41C1U17L1m1e18J2N26.",
				"18.40C2U14L3d2m17J4N25.", "19.39C2U9L7d1I2b15J6N25.", "19.39C2i3d3L8d3I2b14J5N2A25.",
				"19.39C2i9d8I2b13J4N4A25.", "19.39C2S17I2b13J3N6A24.", "18.19C3T18C2S12I3b2I2b13J3N6A24.",
				"19.18C13T8C2S11I8b13J2N6A25.", "19.18C2T3K4T3K2T8C1S10I2b4J3b13J2N6A25.",
				"19.18C2T4K2T5K2T7C1h1S8I2b21J2N5A26.", "20.17C2T3K2T7K8T1h1c7I3b22J3A29.", "20.17C2T3K2T15K2c5I4b24J2A29.",
				"21.16C2T3K2T15K2c3I1b3k1Z24J32.", "21.16C1T5K2T14K1c1l5k4Z23J32.", "22.15C1T5K3T13K1a1l3k1Z4H2Z21J33.",
				"23.6C8R1g6K5T9K2a10H2Z18J35.", "24.2C6R4G1R1g9K1T9K2a11H2Z15J38.", "25.1C3R8G1g1Y18K2a11H2Z14J39.",
				"26.11G2Y18K1a12H2Z13J40.", "27.10G2Y3K9Y6K2a12H1.8J45.", "26.11G15Y5K2j11H55.",
				"26.11G3Y10G2Y4K2Y2X10H55.", "26.25G7Y1G2X8H56.", "26.26G5Y3G1X8H56.", "27.33G1X11H53.", "27.33G1X12H52.",
				"27.33G2X11H52.", "27.33G14H51.", "27.31G2.14H51.", "27.28G5.14H51.", "27.22G2.2G9.12H51.",
				"28.21G15.10H51.", "29.5G2.6G2.3G18.8H52.", "30.4G3.4G24.8H52.", "66.6H53.", "125.",
			},
		},
		["Maraudon1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.1650, 0.0000, 0.3780, 0.1874 },
				lower_caves = { 0.2510, 0.3553, 0.6480, 1.0000 },
				earth_song_falls = { 0.0460, 0.1349, 0.4450, 0.7226 },
				landslide = { 0.3310, 0.3598, 0.4950, 0.6252 },
				rotgrip = { 0.3350, 0.6912, 0.4970, 0.9325 },
				celebras = { 0.1390, 0.0000, 0.3670, 0.3013 },
				princess_theradras = { 0.1350, 0.5697, 0.4430, 0.9970 },
				banner = { 0.2990, 0.0165, 0.7090, 0.1619 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "landslide", boss = "Landslide", pieces = { "landslide" }, back = "celebras", way = { "lower_caves", "earth_song_falls" } },
				{ id = "rotgrip", boss = "Rotgrip", pieces = { "rotgrip" }, back = "celebras", way = { "lower_caves", "earth_song_falls" } },
				{ id = "celebras", boss = "Celebras the Cursed", pieces = { "celebras" }, back = "way_in", way = {} },
				{ id = "princess_theradras", boss = "Princess Theradras", pieces = { "princess_theradras" }, back = "celebras", way = { "lower_caves", "earth_song_falls" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in lower_caves earth_song_falls landslide rotgrip celebras princess_theradras banner way_in+celebras lower_caves+earth_song_falls lower_caves+landslide lower_caves+rotgrip lower_caves+princess_theradras earth_song_falls+landslide earth_song_falls+celebras lower_caves+earth_song_falls+landslide",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "29.11A85.", "28.12A11.2H1.1H17.3H50.", "28.1I11A8.30H47.", "27.3I10A6.34H45.", "26.1F4I9A3.41H41.",
				"26.2F4I8A2.42H41.", "26.3F9I1A1.47H38.", "26.7F5I1.48H38.", "25.12F1I27H2.21H37.",
				"25.12F2.2H8.1H27.5H3.3H37.", "24.13F47.3H38.", "23.14F48.1H39.", "22.16F87.", "22.16F87.", "23.17F85.",
				"24.17F84.", "24.7F10O84.", "24.9O4C4O84.", "23.1C7O10C84.", "23.18C84.", "23.18C84.", "22.19C84.",
				"17.25C83.", "16.30C79.", "15.32C78.", "14.33C78.", "12.34C79.", "11.35C79.", "11.36C78.", "11.37C77.",
				"11.37C77.", "11.38C76.", "11.39C75.", "11.39C75.", "11.39C1.3D10.4B57.", "11.39C4D8.6B57.",
				"11.37C2N5D7.7B56.", "11.36C3N5D1K4B1.9B55.", "11.36C2N6D1K15B54.", "11.36C1N7D1K15B54.",
				"11.36C1N7D2K15B53.", "12.35C1N7D1K16B53.", "13.34C2P5D2K16B53.", "15.32C1J2K4D2K15B54.",
				"20.26C2J1B2K1D3K16B54.", "21.25C2J2B4K18B53.", "26.20C2J24B53.", "27.18C2J25B53.", "28.16C2J26B53.",
				"28.15C3J26B53.", "29.13C3J27B53.", "30.10C4J29B52.", "30.5G3C4J31B52.", "29.7G4J33B52.", "28.9G2J34B52.",
				"26.13G1M33B52.", "26.13G2M31B53.", "25.14G1M32B53.", "25.14G1M33B52.", "24.15G1M33B52.", "23.16G1M33B52.",
				"23.16G1M32B53.", "23.16G1M10B4L19B52.", "22.17G1M9B6L19B51.", "22.17G1M8B2L4E2L19B50.",
				"22.17G1M7B2L6E2L19B49.", "22.17G1M7B2L6E2L19B49.", "22.17G1M7B2L6E2L18B50.", "22.17G1M7B2L6E2L18B50.",
				"22.17G1M8B2L4E2L19B50.", "22.17G1M8B7L20B50.", "25.14G2M9B4L21B50.", "26.13G3M2B5M26B50.",
				"26.14G10M25B50.", "28.14G2M5G26B50.", "28.6G1.14G1.23B52.", "35.14G2.22B52.", "52.21B52.", "52.21B52.",
				"52.20B53.", "54.18B53.", "57.6B2.3B1.2B54.", "125.",
			},
		},
	},
})
