local _, ns = ...

--[[ The Drowned City's fog: the journal's own pictures (Media/Maps/TheDrownedCity.tga and
     TheDrownedCityAtalbyzal.tga, Santiago Reyes's maps, under his own frame: the parchment lies only inside it
     and off his credit, each floor's extent, with no shared Frame mask). Pieces are fractions of the visible
     picture, as the boss spots are; each is a mask, Media/Fog/TheDrownedCity/<floor>/<piece>.tga, split by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/DrownedCityFog/fog_spec.py. The city's map clears once its
     five bosses are dead; its central pool clears with the optional Primeval Elemental (his room is on
     Atal'byzal) or with that. Atal'byzal's two ways in (from the Deep Archives, the south-west end; from
     the central pool, the north-east end, with the rare Gill's stretch) are clear from the start, the
     Elemental's room and the halls clear with his kill, and the whole of it with the city's five. ]]
ns.AddFog("TheDrownedCity", {
	-- false: never holds the fog back (his room, if he has one, still clears with his kill; a rare,
	-- a summoned boss or one the owner named holds no fog and has none); true: holds it back
	counts = { ["Primeval Elemental"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["TheDrownedCity"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6562, 0.9107, 0.9941, 0.9634 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.6943, 0.3016, 0.9668, 0.6706 },
				zul_alai = { 0.5283, 0.3163, 0.8115, 0.7628 },
				var_taka = { 0.3398, 0.4919, 0.7090, 0.9912 },
				captain_dreadrise = { 0.2998, 0.1127, 0.7373, 0.6369 },
				deathless_marrow = { 0.2139, 0.3104, 0.5146, 0.7628 },
				min_loth = { 0.0371, 0.3602, 0.3145, 0.7189 },
				primeval_elemental = { 0.4229, 0.3982, 0.6309, 0.6676 },
				banner = { 0.2598, 0.0293, 0.7979, 0.1845 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "zul_alai", boss = "Zul'Alai", pieces = { "zul_alai" }, back = "entrance", way = {} },
				{ id = "var_taka", boss = "Var'Taka", pieces = { "var_taka" }, back = "zul_alai", way = {} },
				{ id = "captain_dreadrise", boss = "Captain Dreadrise", pieces = { "captain_dreadrise" }, back = "var_taka", way = {} },
				{ id = "deathless_marrow", boss = "Deathless Marrow", pieces = { "deathless_marrow" }, back = "captain_dreadrise", way = {} },
				{ id = "min_loth", boss = "Min'loth the Serpent", pieces = { "min_loth" }, back = "deathless_marrow", way = {} },
				{ id = "primeval_elemental", boss = "Primeval Elemental", pieces = { "primeval_elemental" }, back = "var_taka", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance zul_alai var_taka captain_dreadrise deathless_marrow min_loth primeval_elemental banner entrance+zul_alai zul_alai+var_taka zul_alai+captain_dreadrise zul_alai+primeval_elemental var_taka+deathless_marrow var_taka+primeval_elemental captain_dreadrise+deathless_marrow captain_dreadrise+primeval_elemental deathless_marrow+min_loth zul_alai+var_taka+primeval_elemental zul_alai+captain_dreadrise+primeval_elemental var_taka+captain_dreadrise+deathless_marrow+primeval_elemental",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "90.2H36.", "43.50H35.", "43.50H35.", "39.55H34.", "37.62H29.", "36.64H28.",
				"35.66H27.", "35.66H27.", "34.4H1.62H27.", "34.3H2.57H2.3H27.", "35.2H61.3H27.", "36.1H61.2H28.",
				"73.4D51.", "66.1D4.7D50.", "65.15D48.", "54.27D47.", "53.27D48.", "53.26D49.", "53.26D49.", "53.27D48.",
				"53.28D47.", "54.27D47.", "54.27D47.", "54.27D47.", "44.3D5.28D48.", "43.38D47.", "43.46D39.", "44.45D39.",
				"45.44D39.", "46.1D1O41D4.4B31.", "46.4O39D3.3B3I4A26.", "46.2E5O36D2.4B3I5A25.", "45.5E4O35D2.4B3I6A24.",
				"19.3F13.18E2O30D4K2.4B3I9A21.", "18.9F5.2F20E2O27D4K2B1.5B3I12A18.", "18.10F3.3F20E2O26D3K10B3I14A16.",
				"18.17F20E1O25D3K11B3I16A14.", "18.15F2Q20E2O2D15P6D3K12B3I17A13.", "18.15F2Q20E2O2D2P12G2P4D3K13B3I18A12.",
				"17.16F2Q21E2O1D2P13G1P3D2K15B3I18A12.", "16.17F2Q21E2O1D2P13G1P2D2K16B3I19A11.",
				"16.17F2Q22E1O1D2P12G2P1D2K17B3I19A11.", "17.16F2Q22E2O1D2P11G2P2K18B3I18A12.",
				"18.15F2Q23E2O2P11G1P1S1K20B3I16A13.", "18.15F2Q23E2O2P11G1P1S21B3I15A14.",
				"10.23F2Q23E1M2T13G1L21B3I14A15.", "10.23F2Q20E5M2N12G1L21B3I12A17.", "10.23F2Q18E4M4C12N1R1L21B2I11A19.",
				"10.23F2Q17E3M7C11N2R21B32.", "10.23F2Q7E3.7E22C2J19B33.", "11.22F2Q6E7.26C2J17B35.",
				"22.8F1.2F2Q5E9.26C2J14B37.", "23.6F3.3Q5E9.26C2J13B38.", "27.1F4.8E11.25C2J11B39.", "32.8E11.26C2J8B41.",
				"33.7E12.26C2J2B46.", "33.6E13.27C2J1B46.", "35.3E14.28C1J47.", "52.30C46.", "51.35C42.", "51.35C42.",
				"52.34C42.", "53.33C42.", "55.31C42.", "55.31C42.", "56.30C42.", "57.27C44.", "58.26C44.", "58.26C44.",
				"58.25C45.", "58.25C45.", "58.2C2.22C44.", "63.21C44.", "64.3C2.14C45.", "70.10C48.", "70.4C54.",
				"71.2C55.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
		["TheDrownedCityAtalbyzal"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5283, 0.8931, 0.9375, 0.9400 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.5361, 0.0073, 0.7637, 0.3836 },
				way_in_archives = { 0.2178, 0.6457, 0.4336, 0.8990 },
				passage_1 = { 0.2754, 0.1786, 0.7549, 0.9224 },
				primeval_elemental = { 0.5684, 0.4026, 0.7754, 0.7116 },
				banner = { 0.4531, 0.7789, 0.9766, 0.9092 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "way_in_archives", start = true, pieces = { "way_in_archives" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "primeval_elemental", boss = "Primeval Elemental", pieces = { "primeval_elemental" }, back = "way_in_archives", way = { "passage_1" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in way_in_archives passage_1 primeval_elemental banner way_in+passage_1 way_in_archives+passage_1 passage_1+primeval_elemental passage_1+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "85.4A39.", "84.6A38.", "83.8A37.",
				"83.8A37.", "82.9A37.", "81.9A38.", "81.8A39.", "80.9A39.", "79.9A40.", "78.9A41.", "77.9A42.", "77.8A43.",
				"76.1F8A43.", "75.3F6A44.", "74.1C4F5A44.", "74.2C3F4A1C44.", "73.4C3F2A5C41.", "72.6C3F8C39.",
				"67.2C2.8C2F9C38.", "66.25C37.", "66.26C36.", "65.27C36.", "64.27C37.", "63.27C38.", "62.28C38.",
				"62.27C39.", "61.27C40.", "60.27C41.", "61.26C41.", "62.22C44.", "55.4C3.22C44.", "54.30C44.",
				"53.30C6D39.", "52.29C1H9D37.", "52.28C2H10D36.", "51.29C2H11D35.", "50.30C1H12D35.", "50.29C15D34.",
				"49.29C16D34.", "49.29C16D34.", "49.28C1.16D34.", "48.28C2.16D34.", "46.29C3.16D34.", "45.30C4.15D34.",
				"44.31C4.15D34.", "44.31C5.13D35.", "43.32C6.11D36.", "42.32C10.5D39.", "41.33C54.", "41.32C55.",
				"40.32C56.", "40.31C57.", "40.31C57.", "40.31C57.", "40.1G29C58.", "36.5B2G3C2G22C58.", "35.6B8G20C59.",
				"35.11B3G18C61.", "35.13B18C62.", "35.13B17C63.", "35.12B3.14C4.48E12.", "36.10B5.13C4.48E12.",
				"53.10C1.57E7.", "53.9C60E6.", "55.6C1I61E5.", "56.5C62E5.", "59.65E4.", "59.3E2.57E1.2E4.", "59.2E3.56E8.",
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
	},
})
