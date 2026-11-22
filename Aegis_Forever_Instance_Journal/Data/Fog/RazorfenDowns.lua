local _, ns = ...

--[[ Razorfen Downs' fog: its one floor, the classic map the journal draws (Media/Maps/Classic/
     RazorfenDowns.blp, the map at 1000 x 667 of the 1024 square). Pieces are fractions of the visible
     picture, as the boss spots are; each is a mask, Media/Fog/RazorfenDowns/<floor>/<piece>.tga, traced
     from the picture and split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/RazorfenDownsFog/fog_spec.py. ]]
ns.AddFog("RazorfenDowns", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Tuten'kash"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["RazorfenDowns"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.1650, 0.0240, 0.4040, 0.3943 },       -- the swirl, the passage east to the tunnels and the bay south of it
				spiral_green = { 0.2240, 0.3028, 0.5380, 0.9385 },       -- the band down from the crossroads and the spiral's green terrace
				west_passage = { 0.1460, 0.1889, 0.4020, 0.7421 },       -- the passage from the bay down the spiral's west side to the green terrace
				glutton = { 0.2680, 0.5442, 0.4290, 0.7841 },       -- a pocket round his spot on the green terrace
				spiral_ring = { 0.2950, 0.3808, 0.6410, 0.9100 },       -- the spiral's yellow ring, Ragglesnout's spot on it (a rare: he holds no fog)
				amnennar = { 0.3280, 0.4303, 0.5640, 0.8081 },       -- the inner terrace and the blue top
				murder_pens = { 0.6190, 0.0555, 0.9110, 0.5997 },       -- the crossing under the Murder Pens and the pens
				long_passage = { 0.4470, 0.3478, 0.7640, 0.6207 },       -- the long passage from the crossing back west to the crossroads
				tunnels = { 0.2820, 0.0540, 0.5710, 0.5502 },       -- the tunnels east of the way in, down to the crossroads, and the sheet up to the name
				mordresh_fire_eye = { 0.7170, 0.2534, 0.9950, 0.6732 },       -- the Bone Pile
				plaguemaw = { 0.4520, 0.1634, 0.7410, 0.5127 },       -- the Caller's Chamber: its mouth, its north-west corner, its name, the chamber, its tail and the walls round it (Tuten'kash's place too: summoned, he holds no fog)
				banner = { 0.2320, 0.0180, 0.8060, 0.1679 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "glutton", boss = "Glutton", pieces = { "glutton" }, back = "entrance", way = { "spiral_green", "west_passage" } },
				{ id = "amnennar", boss = "Amnennar the Coldbringer", pieces = { "amnennar" }, back = "entrance", way = { "spiral_ring", "spiral_green", "west_passage" } },
				{ id = "mordresh_fire_eye", boss = "Mordresh Fire Eye", pieces = { "mordresh_fire_eye" }, back = "entrance", way = { "murder_pens", "long_passage", "tunnels" } },
				{ id = "plaguemaw", boss = "Plaguemaw the Rotting", pieces = { "plaguemaw" }, back = "entrance", way = { "tunnels" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance spiral_green west_passage glutton spiral_ring amnennar murder_pens long_passage tunnels mordresh_fire_eye plaguemaw banner entrance+west_passage entrance+tunnels entrance+banner spiral_green+west_passage spiral_green+glutton spiral_green+spiral_ring spiral_green+amnennar spiral_green+tunnels west_passage+tunnels glutton+spiral_ring glutton+amnennar spiral_ring+amnennar spiral_ring+long_passage spiral_ring+tunnels murder_pens+long_passage murder_pens+mordresh_fire_eye murder_pens+plaguemaw murder_pens+banner long_passage+tunnels long_passage+plaguemaw tunnels+plaguemaw tunnels+banner entrance+west_passage+tunnels entrance+tunnels+banner spiral_green+west_passage+tunnels spiral_green+glutton+spiral_ring spiral_green+glutton+amnennar spiral_green+spiral_ring+amnennar spiral_green+spiral_ring+tunnels glutton+spiral_ring+amnennar spiral_ring+long_passage+tunnels murder_pens+long_passage+plaguemaw long_passage+tunnels+plaguemaw",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "43.2L40.2L38.", "40.50L35.", "39.52L34.", "34.61L30.", "32.20L5h41L27.",
				"31.9L8h2L12h37L26.", "30.8L26h34L2d1G24.", "30.1O7L2h2j23h21L7d4L3d2G23.",
				"29.1A2O5L5j1N22I21.2G7d1L4d4G21.", "28.3A3O1L3O4A1N22I21.7G6d6G20.", "28.4A5O4A3N20I23.8G3d7G20.",
				"29.12A3N20I22.19G20.", "28.13A3N20I22.20G19.", "28.13A3N21I21.21G18.", "28.13A3N21I21.21G18.",
				"28.13A3N22I20.21G18.", "28.13A3N22I20.22G17.", "28.13A3N21I1K4.1K14.24G16.", "28.13A3N19I2g12K8.24G16.",
				"29.12A2i1N18I2g14K1.2K3.25G16.", "29.10A3M2i18I1g20K26G16.", "30.8A4M2i18I1g20K1c25G16.",
				"31.6A5M1C2U17I2g19K1c24G17.", "32.4A4M3C2U18I2g18K1c24G17.", "34.1A8C2U18I2g18K1c24G17.",
				"34.9C2U19I2g17K2c18G2b4J16.", "33.10C2U19I2g17K2c16G4b7J13.", "31.12C2U19I2g17K2c11G7b10J12.",
				"30.13C2U19I2g17K2c11G5b13J11.", "30.13C2U3I8T8I2g18K1c10G2b19J9.", "29.14C2U1I5T3B3T5I3g19K2c9G2b20J8.",
				"29.14C1k4T7B2T5I2g21K1c9G2b21J7.", "29.13C2P11B2T5I1g22K2c8G2b21J7.", "29.13C2P11B2T5I1s9f13K2c8G2b22J6.",
				"29.12C2P12B2T5I1e5H18f1r1a7G2b22J6.", "29.12C2P10B2R2o5I1e11H12f1r1a7G2b22J6.",
				"30.10C2P9B4R2o3Z1I2e24H2a7G2b21J6.", "30.9C2P8B4R5E3Z2q7Y17H2a8G1b21J6.",
				"30.9C2P6B4R9E1Z2q1Y3E5Y16H1a8G2b20J6.", "29.9C2P6B3R21E3Y15H2a8G1b20J6.",
				"29.9C2P5B3R7X17E1Y15H2a8G2b19J6.", "28.9C2P5B2R2E2X3F4X15E2Y14H2a8G2b18J7.",
				"27.10C2P4B2R2E2X6F6X11E1Y16H1a4G3.3b18J7.", "26.11C2P3B2R3E2X9F5X10E17H7.20J8.",
				"26.11C2P3B2R3E2X12F3X10E11H13.19J8.", "26.11C2P3B2R3E2X14F2X9E24.18J9.",
				"25.12C3P2B2R3E2X14F2X9E25.16J10.", "24.14C3P1B2R3E2X14F2X10E26.13J11.",
				"24.15C1P2B2R3E2X14F2X10E28.10J12.", "23.15C2P2B2l1V2E1X15F2X10E33.1J16.", "23.15C2P3Q1l3V1X15F2X10E50.",
				"23.14C2P2Q4D2V1X15F2X10E50.", "23.12C4P2Q5D2p14F2X11E50.", "24.9C5P1B1Q7D1W12F4X11E50.",
				"25.7C1.6B1Q6D1Q1m11F2X14E50.", "33.6B2Q5D1Q1m1S10F1X15E50.", "33.7B2Q3D2Q1B2S9F1X14E51.",
				"33.7B6Q3B2S8F1X14E51.", "34.8B2Q6B3S4F1S1n1X13E52.", "34.17B6S2n14E52.", "35.23B2R12E53.",
				"36.22B3R10E54.", "37.22B2R10E54.", "38.21B2R9E55.", "40.20B2R8E55.", "42.18B2R7E56.", "43.17B2R6E57.",
				"45.15B2R4E59.", "48.11B2.4E60.", "50.8B67.", "51.6B68.", "53.2B70.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
	},
})
