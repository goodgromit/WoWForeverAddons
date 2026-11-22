local _, ns = ...

--[[ Dire Maul: Warpwood Quarter's fog: 2 floors, the client's maps as the journal draws them
     (Media/Maps/Classic/DireMaulEast.blp, DireMaulEast1.blp: the map at 1000 x 667 of the 1024 square).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/DireMaulEast/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/DireMaulEastFog/fog_spec.py. ]]
ns.AddFog("DireMaulEast", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["DireMaulEast"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.0000, 0.2114, 0.1790, 0.5802 },       -- the way in: the swirl's niche in the courtyard's west wall
				middle_hall = { 0.2860, 0.2054, 0.5650, 0.8051 },       -- the middle hall round the dais, its stairs, the dais's south and east edges by them, and the passage east (down to the Shrine)
				north_corridor = { 0.3000, 0.1484, 1.0000, 0.6162 },       -- the north corridor, and the Hidden Reach past it to the east swirl
				courtyard = { 0.0130, 0.0855, 0.4210, 0.9805 },       -- the courtyard: its walks, the sunken garden, the south passage and its swirl
				pusillin = { 0.3540, 0.4123, 0.4960, 0.6312 },       -- the dais's front west part, above its stairs
				lethtendris = { 0.3570, 0.3568, 0.5190, 0.5952 },       -- the dais's back, round its skull
				banner = { 0.3980, 0.0360, 0.9760, 0.1874 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "pusillin", boss = "Pusillin", pieces = { "pusillin" }, back = "entrance", way = { "middle_hall", "north_corridor", "courtyard" } },
				{ id = "lethtendris", boss = "Lethtendris", pieces = { "lethtendris" }, back = "entrance", way = { "middle_hall", "north_corridor", "courtyard" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance middle_hall north_corridor courtyard pusillin lethtendris banner entrance+courtyard middle_hall+north_corridor middle_hall+courtyard middle_hall+pusillin middle_hall+lethtendris north_corridor+courtyard pusillin+lethtendris middle_hall+north_corridor+courtyard middle_hall+pusillin+lethtendris",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "125.", "125.", "61.10G29.10G15.", "60.51G14.", "58.56G1.1G9.", "53.65G7.", "52.67G6.",
				"51.69G5.", "51.70G4.", "51.3G2.15G20.3G4.17G2.4G4.", "40.6D5.3G3.1G55.2G2.4G4.", "7.9D23.8D5.2G63.3G5.",
				"7.41D69.2G6.", "7.41D77.", "7.41D77.", "7.41D1C76.", "7.39D1M19C59.", "7.36D4M23C55.", "8.35D4M24C54.",
				"9.34D2M27C53.", "10.33D1M29C52.", "10.32D1J1O17I12C52.", "10.4H27D3J16B2I11C52.",
				"10.4H27D2J17B2I11C2.35C15.", "9.1A4H27D2J18B1I49C14.", "6.6A2H27D2J18B5.45C14.", "5.7A2H27D2J18B6.48C10.",
				"5.7A2H27D2J18B6.49C9.", "5.7A2H27D2J18B6.50C8.", "5.7A3H26D2J18B7.50C7.", "5.7A4H25D2J18B7.50C7.",
				"5.8A3H25D2J18B8.50C6.", "5.8A3H25D2J18B10.48C6.", "5.8A3H25D2J7B9L2B12.46C6.",
				"5.8A3H25D2J7B10L1B12.50C2.", "5.8A3H25D2J7B2L6F2L1B13.50C1.", "6.6A4H25D2J7B2L6F2L1B14.26C1.3C2.1C4.12C1.",
				"7.5A3H26D2J7B2L6F2L1B25.14C12.12C1.", "8.6H27D2J7B2P1N5F2L1B25.14C12.12C1.",
				"8.6H27D2J7B2P3N3F2L1B25.13C14.11C1.", "8.33D2J7B1K2E2N1P1L1F2L1B27.10C16.10C1.",
				"7.34D2J7B1K4E1K1P3L1B53.10C1.", "7.34D2J7B1K4E2K1B1L2B54.8C2.", "8.33D2J7B1K4E2K4B54.7C3.",
				"9.32D2J7B7K4B56.3C5.", "10.31D2J8B5K5B64.", "9.32D2J18B64.", "9.32D2J22B60.", "9.32D2J22B60.",
				"9.32D2J23B59.", "9.32D2J23B59.", "9.32D2J23B59.", "9.32D2J23B59.", "9.32D2J22B60.", "9.32D2J22B60.",
				"10.31D2J21B61.", "10.31D3J19B62.", "10.33D2J18B62.", "10.34D2J17B62.", "10.36D11.6B62.", "10.36D12.4B63.",
				"10.36D79.", "9.37D79.", "8.39D78.", "8.39D78.", "8.39D78.", "8.39D78.", "8.39D78.", "8.39D78.", "8.38D79.",
				"9.31D85.", "12.27D86.", "12.26D87.", "12.9D5.2D3.2D92.", "13.6D106.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.",
			},
		},
		["DireMaulEast1"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.4350, 0.6807, 0.7270, 1.0000 },       -- the way in: the spiral ramp and the east hall's south end
				hydrospawn = { 0.4510, 0.4273, 0.6480, 0.8636 },       -- the east hall's red-lit west side and its north end
				pipes = { 0.1920, 0.1469, 0.5490, 0.6762 },       -- the two passages from the Shrine's gate, to the Conservatory and to the west swirl
				conservatory = { 0.1400, 0.4018, 0.5890, 1.0000 },       -- the Conservatory, its name, and the passage to the spiral
				alzzin = { 0.3910, 0.0360, 0.8910, 0.5892 },       -- the Shrine of Eldretharr, its name, its gate and the rock under it
				zevrim_thornhoof = { 0.5080, 0.4168, 0.6870, 0.8636 },       -- the green dais and the ramp down to it
				banner = { 0.2200, 0.0000, 0.7930, 0.1394 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "hydrospawn", boss = "Hydrospawn", pieces = { "hydrospawn" }, back = "way_in", way = {} },
				{ id = "alzzin", boss = "Alzzin the Wildshaper", pieces = { "alzzin" }, back = "way_in", way = { "pipes", "conservatory" } },
				{ id = "zevrim_thornhoof", boss = "Zevrim Thornhoof", pieces = { "zevrim_thornhoof" }, back = "way_in", way = {} },
			},
			where = { cols = 125, rows = 84, keys = "way_in hydrospawn pipes conservatory alzzin zevrim_thornhoof banner way_in+hydrospawn way_in+conservatory way_in+zevrim_thornhoof hydrospawn+conservatory hydrospawn+alzzin hydrospawn+zevrim_thornhoof pipes+conservatory pipes+alzzin conservatory+alzzin alzzin+zevrim_thornhoof alzzin+banner way_in+hydrospawn+conservatory way_in+hydrospawn+zevrim_thornhoof hydrospawn+conservatory+alzzin hydrospawn+alzzin+zevrim_thornhoof pipes+conservatory+alzzin",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "39.13G2.8G1.1G4.4G3.13G37.", "36.54G35.", "33.61G31.", "30.66G29.", "29.32G4R1G19R12G28.",
				"29.31G29R9G27.", "28.31G31R8G27.", "28.3G3.7G8.7G5R25E5R2G2.3G27.", "29.3G17.6G6R30E4.3G27.",
				"30.1G19.5G1.2E2R30E5.2G28.", "56.34E35.", "56.35E34.", "56.36E33.", "55.37E33.", "55.38E32.", "54.39E32.",
				"54.51E20.", "50.4C2O50E19.", "48.7C2O49E19.", "47.9C1O49E19.", "47.9C1O48E20.", "46.10C1O36E32.",
				"45.11C1O36E32.", "45.11C1O36E32.", "44.12C1O36E32.", "44.12C1O36E32.", "44.12C2O35E32.", "44.12C2O35E32.",
				"43.14C2O34E32.", "42.15C2O33E33.", "42.16C2O31E34.", "41.17C2O30E35.", "37.22C2O29E35.", "36.24C2O28E35.",
				"32.28C2O27E36.", "31.30C2O26E36.", "31.30C2O26E36.", "30.32C1O25E37.", "29.8C25N1W24E38.",
				"29.8C25N1W11E2Q9E40.", "29.8C1N24D1P9E5Q1F5E42.", "29.8C1N24D1U5L3E3Q6F45.", "30.7C1N24D1U8L1V8F45.",
				"30.7C1N24D1K8B1M8F45.", "30.7C1N24D1K8B1M9F44.", "29.8C1N24D1K8B5M5F44.", "29.8C1N24D1K8B5M5F44.",
				"29.8C1N24D1K11B2M5F44.", "29.7C2N24D1K11B2M5F44.", "29.7C2N24D1K11B2M5F44.", "35.1N26D1K11B2M5F44.",
				"35.27D1K11B2M5F44.", "35.27D1K11B2M5F44.", "35.27D1K11B2M5F44.", "35.27D1K6B6M6F44.", "35.27D1K6B1M11F44.",
				"35.27D1K6B1M11F44.", "35.27D1K6B1M11F44.", "35.27D1K6B1M11F44.", "35.27D1K6B1M11F44.", "35.27D1K6B1M9F46.",
				"35.27D1K6B1M8F47.", "35.27D1K6B1M8F47.", "35.27D1K6B1M8F47.", "27.5D3.27D1K6B1T6F2J47.",
				"24.38D1S6H1T7J1A47.", "23.39D1I17A45.", "23.39D1I18A44.", "23.39D1I18A44.", "35.27D1I19A43.",
				"35.27D1I19A43.", "35.27D1I20A42.", "35.27D1I21A41.", "35.27D5I17A41.", "35.26D7I16A41.", "35.26D7I15A42.",
				"35.31D2I15A42.", "35.31D2I14A43.", "35.31D3I13A43.", "35.31D2I3.9A45.", "36.28D9.4A48.", "125.", "125.",
			},
		},
	},
})
