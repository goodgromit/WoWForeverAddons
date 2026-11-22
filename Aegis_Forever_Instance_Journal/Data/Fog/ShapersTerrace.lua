local _, ns = ...

--[[ Shaper's Terrace's fog: the journal's own pictures (Media/Maps/ShapersTerrace.tga and
     ShapersTerracePrismaticTalus.tga, Santiago Reyes's maps, under his own frame: the parchment lies only inside
     it and off his credit, each floor's extent, with no shared Frame mask). Pieces are fractions of the visible
     picture, as the boss spots are; each is a mask, Media/Fog/ShapersTerrace/<floor>/<piece>.tga, made by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/ShapersTerraceFog/fog_spec.py. The way in (Terrace Overlook)
     is clear at the start; each of the five that roam clears his part of the terrace (they are optional, so
     none holds the fog back: counts), the four called up at the consoles and King Op (a rare) clear nothing of
     their own, and Nanaya's kill clears both maps. The Prismatic Talus, where only King Op stands, is clear
     from the start. ]]
ns.AddFog("ShapersTerrace", {
	-- false: never holds the fog back (his room, if he has one, still clears with his kill; a rare,
	-- a summoned boss or one the owner named holds no fog and has none); true: holds it back
	counts = { ["Direhorn Matriarch"] = false, ["Ravasaur Hunters"] = false, ["Thunderhoof"] = false, ["Titanosaur"] = false, ["Venomridge"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["ShapersTerrace"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6211, 0.9224, 0.9629, 0.9693 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.1367, 0.4993, 0.4141, 0.8609 },       -- Terrace Overlook and its name: the swirl, its pool and the ground north of it
				titanosaur = { 0.0000, 0.0000, 0.5166, 0.7804 },       -- the west: the Verdant Plains, the Highlands Causeway, Ruby Spring and the Hidden Wash
				venomridge = { 0.2422, 0.2958, 0.6348, 0.8492 },       -- the middle: the Path of the Shaper, the tar pits and the Botanical Grounds
				thunderhoof = { 0.5273, 0.3631, 0.8389, 0.9048 },       -- the lake's west shore, from the Walk of Communion's ledge to the south edge, and the Pillar of Assimilation's name
				direhorn_matriarch = { 0.6426, 0.3704, 0.9941, 0.9531 },       -- the east: Isiz's Pillar, the south building, the trail down to the cave mark and the cave's name
				ravasaur_hunters = { 0.3936, 0.1479, 0.9307, 0.6135 },       -- the north: the Regrowth Vestibule and the Walk of Communion
				nanaya = { 0.5947, 0.3982, 0.8799, 0.8258 },       -- the lake round the Pillar of Assimilation and its island
				banner = { 0.4258, 0.0498, 0.9902, 0.2167 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "titanosaur", boss = "Titanosaur", pieces = { "titanosaur" }, back = "entrance", way = {} },
				{ id = "venomridge", boss = "Venomridge", pieces = { "venomridge" }, back = "entrance", way = {} },
				{ id = "thunderhoof", boss = "Thunderhoof", pieces = { "thunderhoof" }, back = "venomridge", way = {} },
				{ id = "direhorn_matriarch", boss = "Direhorn Matriarch", pieces = { "direhorn_matriarch" }, back = "thunderhoof", way = {} },
				{ id = "ravasaur_hunters", boss = "Ravasaur Hunters", pieces = { "ravasaur_hunters" }, back = "venomridge", way = {} },
				{ id = "nanaya", boss = "Nanaya", pieces = { "nanaya" }, back = "thunderhoof", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance titanosaur venomridge thunderhoof direhorn_matriarch ravasaur_hunters nanaya banner entrance+titanosaur entrance+venomridge titanosaur+venomridge titanosaur+ravasaur_hunters venomridge+thunderhoof venomridge+ravasaur_hunters thunderhoof+direhorn_matriarch thunderhoof+ravasaur_hunters thunderhoof+nanaya direhorn_matriarch+ravasaur_hunters direhorn_matriarch+nanaya ravasaur_hunters+nanaya entrance+titanosaur+venomridge titanosaur+venomridge+ravasaur_hunters venomridge+thunderhoof+ravasaur_hunters thunderhoof+direhorn_matriarch+nanaya thunderhoof+ravasaur_hunters+nanaya direhorn_matriarch+ravasaur_hunters+nanaya",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "8.15B105.", "4.23B101.", "4.24B42.41H17.", "3.25B41.43H16.",
				"3.25B33.3H2.2H1.50H9.", "3.26B32.63H4.", "3.26B29.67H3.", "2.27B28.68H3.", "2.32B22.69H3.",
				"2.34B20.69H3.", "2.35B19.5H1.64H2.", "2.38B15.4H4.63H2.", "1.43B12.3H54.2H2.9H2.", "1.47B9.3H60.5H3.",
				"1.53B4.1H62.2H5.", "1.56B30.14F27.", "1.55B2L4.17F5.18F26.", "1.55B2L44F26.", "1.55B1L45F26.",
				"1.55B2L45F25.", "1.55B2L45F25.", "1.55B2L46F24.", "1.55B2L46F24.", "1.56B1L47F23.", "1.56B2L47F22.",
				"1.56B2L48F21.", "1.56B2L48F21.", "1.57B2L49F19.", "1.46B8K3B2L50F18.", "1.43B5K1C8K1B1L52F16.",
				"1.43B2K9C4K2V1N50F16.", "1.42B2K13C1K1V5N48F15.", "1.42B2K17C7N44F15.", "1.42B1K21C10N39F14.",
				"1.42B1K27C3N2W5P31F2R14.", "1.42B1K30C2M2D4P29F3R1E13.", "1.42B1K30C2M4D2P28F2R3E13.",
				"1.42B1K30C2M5D2P8F7T11F2R5E12.", "1.42B1K30C2M6D2P6F3T3G2T9F3R7E11.", "1.42B1K30C2M6D2P2F6T5G4T5F3R9E10.",
				"1.42B1K30C2M7D2P1F4T7G2T1G2T3F2R11E10.", "1.42B1K30C1M9D1P1Y1T14G1T2F2R12E10.",
				"1.42B1K30C1M9D1Q1Y15G2T2R13E10.", "1.42B1K30C1M8D2Q16G1T1Z1R14E10.", "1.42B1K30C1M7D2Q18G2S14E10.",
				"1.35B8K29C2M7D1Q20G1S14E10.", "1.30B5I1U36C2M7D1Q20G1S14E10.", "1.27B8I1U36C2M7D2Q18G2S13E11.",
				"1.27B8I1U1J35C2M8D1Q18G2S11E13.", "1.27B4I4A2J35C2M7D2Q18G2S11E13.", "1.27B1I7A9J28C2M7D2Q18G2S11E13.",
				"1.26B2I13A3J28C2M7D2Q18G2S11E13.", "1.25B2I15A1J29C1M8D10Q11G1S11E13.",
				"1.25B2I15A1J29C1M17D1Q11G2S10E13.", "1.10B3.12B2I15A1J29C1M17D1Q12G1S10E13.",
				"1.8B5.12B2I15A1J29C1M17D1Q12G2S9E13.", "1.6B8.11B2I15A1J29C1M17D1Q12G2S10E12.",
				"2.3B10.12B16A1J29C1M17D1Q12G2S10E12.", "17.8B18A2J28C1M17D1Q13G1S11E11.",
				"24.19A2J28C1M17D1Q3X1Q9G2S11E10.", "24.20A2J27C1M16D1O11X3G2S11E10.", "24.22A1.26C2M14D4O2E1O3X2O6S12E9.",
				"24.22A2.25C2M14D1O13E3S13E9.", "25.20A4.24C2M13D2O29E9.", "50.11C9.3C1M14D2O30E8.", "76.12D2O30E8.",
				"78.10D1O31E8.", "80.8D1O31E8.", "83.5D1O33E6.", "86.2D1O10E3.20E6.", "103.19E6.", "103.19E6.", "103.19E6.",
				"103.19E6.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
		["ShapersTerracePrismaticTalus"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5410, 0.8960, 0.9746, 0.9458 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.2012, 0.0322, 0.9375, 0.9751 },       -- the cave, from the way back up to King Op's chamber (he is a rare: it holds no fog)
				banner = { 0.0186, 0.7526, 0.5820, 0.9224 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "44.6A78.", "43.9A76.",
				"42.16A70.", "41.18A69.", "40.21A67.", "38.24A66.", "37.25A66.", "37.26A65.", "36.27A65.", "36.28A64.",
				"37.27A64.", "38.26A64.", "37.27A64.", "35.28A65.", "34.29A14.7A44.", "33.30A10.13A42.", "33.30A8.17A40.",
				"33.30A6.19A40.", "33.29A6.21A39.", "33.28A6.24A37.", "33.26A7.25A37.", "33.22A10.27A1.4A31.",
				"33.21A9.35A30.", "34.18A9.37A30.", "35.17A8.47A1.4A16.", "36.17A5.55A15.", "37.76A15.", "37.76A15.",
				"37.39A6.31A15.", "37.39A8.28A16.", "38.38A9.14A29.", "38.38A9.14A29.", "38.38A10.14A28.",
				"38.38A12.12A28.", "38.38A13.11A28.", "39.37A13.11A28.", "38.38A13.11A28.", "38.38A13.10A29.",
				"37.39A12.12A28.", "36.40A12.13A27.", "36.40A12.13A27.", "35.40A13.14A26.", "35.39A15.13A26.",
				"35.13A2.23A16.14A25.", "36.12A3.20A19.13A25.", "36.11A5.17A21.16A22.", "36.10A44.17A21.", "39.6A44.19A20.",
				"41.3A43.21A20.", "87.22A19.", "87.23A18.", "75.10A1.24A18.", "72.38A18.", "71.40A17.", "71.41A16.",
				"71.41A16.", "17.43B11.41A16.", "17.43B12.40A16.", "14.48B10.40A16.", "8.62B3.39A16.", "6.65B3.37A17.",
				"4.68B4.35A17.", "4.69B4.33A18.", "4.69B6.31A18.", "3.5B3.63B7.28A19.", "3.3B5.54B2.7B22.12A20.",
				"4.3B61.5B24.2A1.1A27.", "5.2B62.3B56.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
	},
})
