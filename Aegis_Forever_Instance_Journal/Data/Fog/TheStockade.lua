local _, ns = ...

--[[ The Stockade's fog: its one floor, the client's map as the journal draws it (Media/Maps/Dungeons/
     the-stockade). Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/TheStockade/<floor>/<piece>.tga, traced from the game's own tiles and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/StockadeFog/fog_spec.py, which holds the touch-ups.
     Targorr the Dread and Dextren Ward each have several spots: a node a spot, all cleared by the one
     kill (no kill's place is kept), each carrying the boss's whole way back. Bruegal Ironknuckle (a rare,
     four spots) holds back no fog at all: his cells clear with the wing corridors, his corner of
     Targorr's west cell with Targorr.
     The rects kept clear are parts of the map's name (its scroll's lower band and curls) that the
     banner piece's trace misses: never fogged, as the banner is not. ]]
ns.AddFog("TheStockade", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["the-stockade"] = {
			extent = true,              -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = { { 0.5130, 0.0659, 0.5808, 0.1123 }, { 0.6607, 0.0644, 0.7006, 0.1138 }, { 0.6647, 0.1108, 0.7006, 0.1452 }, { 0.3273, 0.1138, 0.4002, 0.1497 }, { 0.3194, 0.1228, 0.3293, 0.1452 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3423, 0.5359, 0.6587, 1.0000 },
				west = { 0.2515, 0.1272, 0.5349, 0.5734 },       -- the west wing's corridor along its cells, its two empty cells and Bruegal's cell
				hall = { 0.3583, 0.2231, 0.6407, 0.7216 },       -- the central corridor, its crossing, the passage to the blue room, the two empty cells
				targorr_1 = { 0.4251, 0.1033, 0.5768, 0.3743 },
				targorr_2 = { 0.3533, 0.3263, 0.5359, 0.5704 },
				targorr_3 = { 0.4651, 0.4207, 0.6447, 0.6527 },
				targorr_4 = { 0.2255, 0.2695, 0.4042, 0.5569 },       -- the west wing's south-west cell, with Bruegal's corner past a straight cut
				east = { 0.4651, 0.1482, 0.7525, 0.5958 },       -- the east wing's corridor along its cells, its empty cell and Bruegal's two cells
				kam_deepfury = { 0.6028, 0.1662, 0.7754, 0.4446 },
				red_room = { 0.6587, 0.2111, 0.9072, 0.7021 },       -- the red room round Hamhock's pocket, and its two empty cells
				east_end = { 0.6407, 0.2964, 0.8004, 0.5210 },       -- the east wing's corridor from its cells to the red room
				hamhock = { 0.7026, 0.3383, 0.8623, 0.5778 },       -- a 31 px pocket in the middle of the red room
				green_room = { 0.1198, 0.1198, 0.3154, 0.4177 },       -- the green room (Dextren Ward's three cells open on it)
				west_end = { 0.2026, 0.2036, 0.3653, 0.4281 },       -- the west wing's corridor from its cells to the green room
				dextren_ward_1 = { 0.0569, 0.0808, 0.2385, 0.3398 },
				dextren_ward_2 = { 0.1697, 0.0150, 0.3443, 0.2979 },
				dextren_ward_3 = { 0.0898, 0.2350, 0.2665, 0.5165 },
				bazil_thredd = { 0.7625, 0.3847, 0.9471, 0.6407 },
				banner = { 0.2994, 0.0165, 0.6976, 0.1467 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "targorr_1", boss = "Targorr the Dread", pieces = { "targorr_1" }, back = "entrance", way = { "west", "hall" } },
				{ id = "targorr_2", boss = "Targorr the Dread", pieces = { "targorr_2" }, back = "entrance", way = { "west", "hall" } },
				{ id = "targorr_3", boss = "Targorr the Dread", pieces = { "targorr_3" }, back = "entrance", way = { "west", "hall" } },
				{ id = "targorr_4", boss = "Targorr the Dread", pieces = { "targorr_4" }, back = "entrance", way = { "west", "hall" } },
				{ id = "kam_deepfury", boss = "Kam Deepfury", pieces = { "kam_deepfury" }, back = "entrance", way = { "east", "hall" } },
				{ id = "hamhock", boss = "Hamhock", pieces = { "hamhock" }, back = "entrance", way = { "red_room", "east_end", "east", "hall" } },
				{ id = "dextren_ward_1", boss = "Dextren Ward", pieces = { "dextren_ward_1" }, back = "entrance", way = { "green_room", "west_end", "west", "hall" } },
				{ id = "dextren_ward_2", boss = "Dextren Ward", pieces = { "dextren_ward_2" }, back = "entrance", way = { "green_room", "west_end", "west", "hall" } },
				{ id = "dextren_ward_3", boss = "Dextren Ward", pieces = { "dextren_ward_3" }, back = "entrance", way = { "green_room", "west_end", "west", "hall" } },
				{ id = "bazil_thredd", boss = "Bazil Thredd", pieces = { "bazil_thredd" }, back = "entrance", way = { "red_room", "east_end", "east", "hall" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance west hall targorr_1 targorr_2 targorr_3 targorr_4 east kam_deepfury red_room east_end hamhock green_room west_end dextren_ward_1 dextren_ward_2 dextren_ward_3 bazil_thredd banner entrance+hall west+hall west+targorr_2 west+targorr_4 west+west_end hall+targorr_1 hall+targorr_2 hall+targorr_3 hall+east targorr_3+east east+kam_deepfury east+east_end red_room+east_end red_room+hamhock red_room+bazil_thredd green_room+west_end green_room+dextren_ward_1 green_room+dextren_ward_2 green_room+dextren_ward_3 west+hall+targorr_2 west+targorr_4+west_end hall+targorr_3+east east+kam_deepfury+east_end",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "51.2S19.3S51.", "49.29S48.", "47.34S45.", "43.42S41.", "31.2P10.42S41.",
				"31.4P6.27S2.1S1.14S40.", "30.7P2.26S1.1S5.15S39.", "29.9P1.26S8.13S40.", "29.9P1.2S37.5S43.", "28.10P88.",
				"14.4O10.10P88.", "13.7O7.10P89.", "13.9O5.10P23.7D59.", "13.11O2.1M1k8P23.8D59.",
				"12.11O2j2M3k5P7.4B13.8D59.", "12.11O2j3M4k3P6.10B8.8D9.1H49.", "12.10O2j6M4k6.13B6.9D7.8H43.",
				"13.9O2j8M2k6.13B6.9D6.9H1d4I38.", "15.6O2j11M5.14B6.8D7.9H1d7I35.", "17.4O2j12M4.14B6.8D7.9H1d8I34.",
				"18.3O1j12M1i1N3.14B6.8D7.8H2d9I33.", "20.1j11M2i3N1.15B6.8D7.8H2d9I9.5J19.",
				"21.11M2i4N1X14B6.2D4Y2D7.8H2d9I8.7J18.", "21.2l8M2i5N2X13B7.6Y1D7.8H2d8I9.8J17.",
				"20.2Q3l6M2i5N3X12B7.7C7.8H1d9I8.9J17.", "20.3Q4l4M1i6N2X20B1U4C1b15H2d8I9.9J17.",
				"19.6Q3l4M5N2X1B4W16B2U2C2b15H2d8I8.10J17.", "19.8Q1l1M5.3N2n6W15B2U2C2b16H3d6I7.10J18.",
				"18.10Q8.3G1W4G1W15B2U2C2b17H5d1p1I1K7.10J18.", "18.9Q8.9G2W14B2U2C2b20H1d2p4K3.11J19.",
				"17.10Q8.9G2W14B2U2C2b21H2e5K1f12J19.", "17.9Q8.9G2W6B8V2m4C9b13H2e5K2f10J20.",
				"16.10Q8.9G1W7B2V7E2Z4C2b1C2b1C3b11H2e5K2f1J5g5J20.", "17.9Q8.9G1W6B2V8E2Z12C1b11H2e5K2f2g3L2g4J20.",
				"18.7Q9.8G2W6B2V9E1Z12C1b13H4K2f2g5L2g3J20.", "20.5Q8.9G2W6B2V9E1Z12C1b13H2.2K2f2g6L1g2J1h20.",
				"34.8G2W6B2V9E1Z12C1b12H4.3J1g7L1g1J2h2R18.", "34.8G1W7B2V9E1Z12C1b12H4.3J2g5L2g2h5R16.",
				"35.7G1W7B1V9E2Z11C2b12H5.2J2g5L2g2h7R14.", "39.2G2.8B11Z3C8a1o1c11H6.3J3g1L3g2h9R13.",
				"44.6B2C3Z9C2a8F1c11H6.4J5g1J2h10R12.", "50.14C2a10F10H5.10J2h11R12.", "50.14C2a10F5.3H7.11J12R12.",
				"50.14C2a10F14.11J2.11R12.", "50.14C2a10F13.10J5.9R13.", "50.14C2a10F13.10J7.7R13.",
				"51.13C2a10F12.10J11.3R14.", "52.14C8F14.10J28.", "58.9C21.9J29.", "59.1C2T5C22.8J29.", "59.4T1C3T22.7J30.",
				"59.1A6T2A23.5J30.", "57.4A5T3A57.", "57.12A57.", "56.14A56.", "56.14A56.", "54.19A53.", "52.22A52.",
				"51.24A51.", "51.24A51.", "50.25A51.", "50.26A50.", "50.26A50.", "50.26A50.", "50.26A50.", "51.25A50.",
				"51.24A51.", "52.23A51.", "53.21A52.", "54.18A54.", "56.14A56.", "56.14A56.", "57.12A57.", "58.10A58.",
				"59.8A59.", "61.4A61.", "126.", "126.", "126.", "126.", "126.", "126.",
			},
		},
	},
})
