local _, ns = ...

--[[ Ragefire Chasm's fog: its one floor, the client's map as the journal draws it (Media/Maps/Dungeons/
     ragefire-chasm). Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/RagefireChasm/ragefire-chasm/<piece>.tga, traced from the game's own tiles by
     Dev/maps/RagefireChasmFog/build.py and touched up by hand there. ]]
ns.AddFog("RagefireChasm", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["ragefire-chasm"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.5319, 0.0000, 0.7904, 0.2904 },
				east = { 0.5060, 0.1198, 0.8154, 0.8099 },
				green = { 0.4102, 0.1257, 0.6727, 0.5030 },
				disc = { 0.4890, 0.2470, 0.6427, 0.4835 },
				lake = { 0.2026, 0.3174, 0.6078, 0.8084 },
				lake_to_chamber = { 0.2854, 0.3383, 0.5808, 0.7964 },
				lake_to_walkway = { 0.2096, 0.3383, 0.5808, 0.7320 },
				chamber = { 0.2435, 0.5868, 0.5349, 0.9506 },
				walkway = { 0.1856, 0.5838, 0.5000, 1.0000 },
				banner = { 0.0309, 0.0389, 0.6098, 0.1856 },       -- the "RAGEFIRE CHASM" title banner, scroll ends included: never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "oggleflint", boss = "Oggleflint", pieces = { "disc" }, back = "entrance", way = { "east", "green" } },
				{ id = "taragaman", boss = "Taragaman the Hungerer", pieces = { "lake" }, back = "oggleflint", way = {} },
				{ id = "jergosh", boss = "Jergosh the Invoker", pieces = { "chamber" }, back = "taragaman", way = { "lake_to_chamber" } },
				{ id = "bazzalan", boss = "Bazzalan", pieces = { "walkway" }, back = "taragaman", way = { "lake_to_walkway" } },
			},
			where = { cols = 167, rows = 112, keys = "entrance east green disc lake chamber walkway banner entrance+east entrance+banner east+green east+disc east+lake green+disc green+lake lake+lake_to_chamber lake+lake_to_walkway lake+chamber lake+walkway chamber+walkway east+green+disc lake+lake_to_chamber+lake_to_walkway lake+lake_to_chamber+chamber lake+lake_to_walkway+walkway lake+chamber+walkway green+lake+lake_to_chamber+lake_to_walkway",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"167.", "167.", "167.", "103.7A57.", "100.13A54.", "99.16A52.", "20.17H5.3H25.16H12.19A50.",
				"20.67H11.20A49.", "19.69H10.21A48.", "9.88H1.23A46.", "8.91H23A45.", "7.92H23A45.", "7.93H23A44.",
				"7.93H1.22A44.", "6.94H1J22A44.", "6.28H13.1H12.5H5.1H2.27H1J21A45.", "7.5H2.8H63.8H2.5H22A45.",
				"7.5H4.5H65.4H5.4H1J22A45.", "8.3H85.3H22A46.", "9.1H89.22A46.", "99.21A47.", "80.5C15.18I1A48.",
				"78.12C10.18I49.", "77.14C9.17I50.", "76.20C5.2I14B50.", "76.21C5.16B49.", "75.24C3.16B49.",
				"75.25C1.18B48.", "75.26C18B48.", "75.26C18B48.", "75.27C17B48.", "75.27C17B48.", "75.28C15B49.",
				"75.28C15B49.", "75.29C14B49.", "75.15C8N6C13B50.", "76.13C10N4C2K12B50.", "76.13C2N6D3N2C3K13B49.",
				"76.13C2N7D1N1U5K14B48.", "77.12C2N7D2U3K17B47.", "77.12C2N7D1L1U2K18B47.", "77.12C2N7D2L21B46.",
				"61.9E7.12C2N7D2L21B46.", "57.21E11C2N6D3L21B46.", "55.24E4O6C4N2D4L22B46.", "53.27E3O3Z3C3N2U4L23B46.",
				"52.11E2Q16E2O6Z3C2U2L25B46.", "51.6E11Q15E1V6Z2O1K1L27B46.", "51.5E14Q13E5V2Z3O28B46.",
				"50.5E18Q9E1Q7V3E28B46.", "49.5E23Q4E2Q7V3E29B45.", "49.4E29Q8V4E28B45.", "48.4E30Q7V1P4E28B45.",
				"48.4E29Q7V2P4E27B46.", "48.4E7Q7E15Q6V2P6E27B45.", "47.4E8Q10E11Q6V2P7E27B45.", "47.4E7Q13E8Q6V3P7E27B45.",
				"46.5E7Q17E4Q3V5P8E27B45.", "46.5E7Q20E9P8E27B45.", "46.4E8Q20E8P8E28B45.", "46.2E10Q20E7P9E27B46.",
				"46.1E10Q21E7P9E27B46.", "46.10Q22E7P9E27B46.", "45.10Q23E7P9E28B45.", "44.10Q24E7P9E30B43.",
				"44.9Q25E7P8E1M33B40.", "44.8Q26E7P8E35B39.", "42.10Q26E7P8E36B38.", "42.9Q27E7P8E36B38.",
				"42.8Q28E7P7E1.37B37.", "41.1E8Q28E7P6E3.35B38.", "41.1E8Q27E8P5E4.35B38.", "41.8Q11E7P10E7P6E5.34B38.",
				"40.1G1S7X2Y5R1E14P5E8P5E6.34B38.", "40.2G1S5X1S2Y4R1W16P3E9P4E8.32B39.", "40.9G2T4F2W26P4E9.30B41.",
				"40.9G2T4F2W26P3E10.28B43.", "40.9G1T5F3W24P3E11.26B45.", "40.8G2T6F2W24P3E12.23B47.",
				"40.8G2T6F4W2P1E16P1W2R1E14.22B48.", "40.8G2T7F2W5R4E8P3W4R15.20B49.", "41.7G2T9F11R7W5R18.16B51.",
				"41.7G2T13F18R20.15B51.", "41.7G2T22F5R1F27.6B56.", "41.7G2T24F93.", "40.8G2T20F97.", "41.7G2T20F97.",
				"40.8G2T21F96.", "40.8G2T20F1T96.", "40.8G2T19F3T95.", "40.8G2T18F3T3G93.", "39.9G2T17F2T6G92.",
				"39.9G2T17F2T7G91.", "38.10G3T15F2T8G91.", "38.11G2T14F3T9G90.", "38.11G3T13F2T10G90.",
				"39.11G4T9F3T11G90.", "39.12G14T12G90.", "39.15G9T14G90.", "40.36G91.", "41.34G92.", "42.33G92.",
				"49.25G93.", "51.22G94.", "52.20G95.", "54.17G96.", "59.2G106.", "167.", "167.", "167.", "167.", "167.",
			},
		},
	},
})
