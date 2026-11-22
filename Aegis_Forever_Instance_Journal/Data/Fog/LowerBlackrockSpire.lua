local _, ns = ...

--[[ Lower Blackrock Spire's fog: the journal's own six pictures (Media/Maps/Classic/
     LowerBlackrockSpire.blp, LowerBlackrockSpire1-5.blp), each the whole spire with its own level lit.
     A floor's fog is split over its lit floor only; the rest of the spire stays under the parchment
     until the full clear. Each floor keeps the parchment inside its own frame (extent, frame = false:
     these pictures are the client's map made about 0.2 % smaller, so the shared frame mask fits them a
     pixel off). Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/LowerBlackrockSpire/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/LowerBlackrockSpireFog/fog_spec.py. ]]
ns.AddFog("LowerBlackrockSpire", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Urok Doomhowl"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["LowerBlackrockSpire"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3780, 0.3178, 0.6150, 0.6492 },
				burning_felguard_hall = { 0.4950, 0.4393, 0.7240, 0.7301 },       -- the arena, the Felguard's spot in it (Voone's room opens onto it)
				band = { 0.4140, 0.3658, 0.7280, 0.8621 },       -- the band round the arena and the corridor south (Bannok's nook too): on every way
				war_master_voone = { 0.4470, 0.4303, 0.5960, 0.7106 },
				banner = { 0.2000, 0.0000, 0.8640, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "war_master_voone", boss = "War Master Voone", pieces = { "war_master_voone" }, back = "entrance", way = { "burning_felguard_hall", "band" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance burning_felguard_hall band war_master_voone banner entrance+band burning_felguard_hall+band burning_felguard_hall+war_master_voone band+war_master_voone entrance+band+war_master_voone burning_felguard_hall+band+war_master_voone",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.59E29.", "37.59E29.", "29.67E1.6E22.", "28.77E20.", "27.79E19.", "26.81E18.", "26.81E18.",
				"26.4E3.67E3.4E18.", "27.4E4.3E57.3E4.5E18.", "28.3E71.4E19.", "103.1E21.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "55.14A56.", "54.16A55.", "54.16A5.4C46.", "55.14A4C1.6C1.5C39.",
				"55.12A2F17C39.", "57.9A3F17C39.", "58.8A3F17C39.", "57.4A8F17C39.", "56.5A6J1I1K16G1C39.",
				"56.5A1J1I5D1K16G40.", "56.5A1J1I5D1H17B39.", "56.1A4F1J1I5D1H17B39.", "56.1A4F1J1I5D1H17B39.",
				"57.4F1J1I5D1H17B39.", "57.4C2I5D1H16B40.", "57.4C2I5D1H16B40.", "57.4C2I5D1H16B40.", "57.4C2I5D1H16B40.",
				"57.4C2I5D1H16B40.", "57.4C6I2K16B40.", "57.10C12G6B40.", "59.9C11G6B40.", "59.24C42.", "59.24C42.",
				"59.24C42.", "59.24C42.", "60.24C41.", "62.22C41.", "70.14C41.", "70.14C41.", "70.13C42.", "70.13C42.",
				"70.4C51.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.",
			},
		},
		["LowerBlackrockSpire1"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.4440, 0.6372, 0.5940, 0.8621 },
				tunnel = { 0.4790, 0.6447, 0.6350, 0.8681 },       -- the tunnel: on every way
				mother_smolderweb = { 0.5360, 0.6087, 0.7600, 0.8801 },       -- the teal room, Crystal Fang's spot in it too (a rare: his kill clears nothing)
				shadow_hunter_vosh_gajin = { 0.4170, 0.3898, 0.7030, 0.7976 },       -- his corridor and the halls up its stair
				banner = { 0.2000, 0.0000, 0.8640, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "mother_smolderweb", boss = "Mother Smolderweb", pieces = { "mother_smolderweb" }, back = "way_in", way = { "tunnel" } },
				{ id = "shadow_hunter_vosh_gajin", boss = "Shadow Hunter Vosh'gajin", pieces = { "shadow_hunter_vosh_gajin" }, back = "way_in", way = { "tunnel" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in tunnel mother_smolderweb shadow_hunter_vosh_gajin banner way_in+tunnel tunnel+mother_smolderweb tunnel+shadow_hunter_vosh_gajin",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.59E29.", "37.59E29.", "29.67E1.6E22.", "28.77E20.", "27.79E19.", "26.81E18.", "26.81E18.",
				"26.4E3.67E3.4E18.", "27.4E4.3E57.3E4.5E18.", "28.3E71.4E19.", "103.1E21.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "58.13D54.", "57.15D53.",
				"57.17D51.", "58.17D50.", "59.16D2.5D43.", "63.19D43.", "63.19D43.", "63.19D43.", "63.19D43.", "63.20D42.",
				"63.20D42.", "63.20D42.", "63.20D42.", "63.19D43.", "63.17D45.", "66.13D46.", "67.12D46.", "67.12D46.",
				"67.7D2C2D47.", "66.7D5C2.3C42.", "66.6D12C41.", "66.6D12C41.", "65.1A1D5H2G10C41.", "63.2A3F4H2G10C41.",
				"62.3A3F4B2G15C36.", "63.2A3F4B2G16C35.", "63.2A3F4B2G16C35.", "66.1F5B2G16C35.", "67.5B2G15C36.",
				"70.3B15C37.", "74.3C3.7C38.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["LowerBlackrockSpire2"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3840, 0.3403, 0.5600, 0.5622 },
				mokdoom_way = { 0.3960, 0.4828, 0.5550, 0.6687 },       -- the corridor from Mok'Doom's neck to the Butcher's spot
				hordemar = { 0.4430, 0.2909, 0.7330, 0.7196 },       -- the ramp, the upper room, the big hall, and the corridor round the Butcher's spot
				highlord_omokk = { 0.2910, 0.4303, 0.4950, 0.7391 },       -- Mok'Doom whole (the Battle Lord's and Lord Magus's spots too) and its name
				banner = { 0.2000, 0.0000, 0.8640, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "highlord_omokk", boss = "Highlord Omokk", pieces = { "highlord_omokk" }, back = "way_in", way = { "mokdoom_way", "hordemar" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in mokdoom_way hordemar highlord_omokk banner way_in+hordemar mokdoom_way+hordemar mokdoom_way+highlord_omokk",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.59E29.", "37.59E29.", "29.67E1.6E22.", "28.77E20.", "27.79E19.", "26.81E18.", "26.81E18.",
				"26.4E3.67E3.4E18.", "27.4E4.3E57.3E4.5E18.", "28.3E71.4E19.", "103.1E21.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"68.3C54.", "67.6C1.2C2.8C39.", "66.20C39.", "64.22C39.", "62.24C39.", "61.25C39.", "61.2F23C39.",
				"55.6A2F24C38.", "55.6A3F23C38.", "55.6A3F23C38.", "55.6A3F2.21C38.", "66.21C38.", "44.9D12.22C38.",
				"43.11D10.23C38.", "42.12D10.22C39.", "42.13D9.22C39.", "42.14D4.1B2.23C39.", "42.13D2H5B1G23C39.",
				"42.13D2H5B2G22C39.", "42.13D2H5B2G22C39.", "42.13D2H5B2G22C39.", "41.14D2H5B1G23C39.",
				"41.15D7.5C1.17C39.", "41.14D15.16C39.", "41.13D16.16C39.", "41.12D17.15C40.", "41.11D73.", "42.7D76.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.",
			},
		},
		["LowerBlackrockSpire3"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.2310, 0.1859, 0.6300, 0.8876 },
				banner = { 0.2000, 0.0000, 0.8640, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.59B29.", "37.59B29.", "29.67B1.6B22.", "28.77B20.", "27.79B19.", "26.81B18.", "26.81B18.",
				"26.4B3.67B3.4B18.", "27.4B4.3B57.3B4.5B18.", "28.3B71.4B19.", "103.1B21.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "61.9A55.", "59.12A54.", "58.14A53.", "58.14A53.",
				"57.15A53.", "39.2A2.2A12.13A55.", "38.9A9.13A56.", "36.12A8.13A56.", "36.12A9.12A56.", "36.13A7.13A56.",
				"36.13A7.13A56.", "37.12A8.12A56.", "42.7A7.13A56.", "43.7A1.17A57.", "43.24A58.", "44.22A59.", "44.21A60.",
				"45.19A61.", "44.16A1.3A61.", "45.14A66.", "46.13A66.", "46.4A1.8A66.", "51.9A65.", "51.9A65.", "51.9A65.",
				"51.9A65.", "51.12A1.3A58.", "51.18A56.", "51.18A56.", "51.18A56.", "51.18A56.", "51.17A57.", "51.16A58.",
				"51.9A65.", "51.8A66.", "51.5A69.", "51.5A69.", "51.5A69.", "51.5A69.", "51.5A69.", "51.5A69.", "51.5A69.",
				"51.5A69.", "51.5A69.", "51.5A69.", "52.3A70.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["LowerBlackrockSpire4"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3550, 0.6357, 0.5030, 0.8516 },
				corridor = { 0.3640, 0.6807, 0.5850, 0.8921 },       -- the corridor between the lair and the Storehouse: on every way
				sw_hall = { 0.2810, 0.5112, 0.4630, 0.8426 },       -- the south-west room, its stairs and Ghok's lobe over it: the lair's way on
				halycon = { 0.2940, 0.6927, 0.4710, 0.9910 },       -- the lair, Gizrul's too (either kill clears it)
				quartermaster_zigris = { 0.4460, 0.7436, 0.6330, 1.0000 },
				banner = { 0.2000, 0.0000, 0.8640, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "halycon", boss = "Halycon", pieces = { "halycon" }, back = "way_in", way = { "corridor", "sw_hall" } },
				{ id = "quartermaster_zigris", boss = "Quartermaster Zigris", pieces = { "quartermaster_zigris" }, back = "way_in", way = { "corridor" } },
				{ id = "gizrul", boss = "Gizrul the Slavener", pieces = { "halycon" }, back = "way_in", way = { "corridor", "sw_hall" } },
			},
			where = { cols = 125, rows = 84, keys = "way_in corridor sw_hall halycon quartermaster_zigris banner way_in+corridor corridor+halycon corridor+quartermaster_zigris sw_hall+halycon",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.59F29.", "37.59F29.", "29.67F1.6F22.", "28.77F20.", "27.79F19.", "26.81F18.", "26.81F18.",
				"26.4F3.67F3.4F18.", "27.4F4.3F57.3F4.5F18.", "28.3F71.4F19.", "103.1F21.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "43.8C74.", "42.10C73.", "42.10C73.", "42.10C73.",
				"43.8C74.", "42.10C73.", "41.11C73.", "40.13C72.", "40.13C72.", "40.13C72.", "40.12C73.", "40.13C72.",
				"40.13C2A70.", "40.12C4A69.", "41.11C4A69.", "41.11C4G69.", "41.3C8J4G69.", "42.1C8D1H16B57.",
				"43.8D1H16B57.", "43.8D1H16B57.", "43.8D2H12B3I3E54.", "43.9D11.9E53.", "43.9D11.9E53.", "43.10D10.9E53.",
				"42.12D9.9E53.", "42.12D9.9E53.", "42.12D7.13E51.", "42.12D7.13E51.", "44.9D8.13E51.", "44.8D9.13E51.",
				"62.11E52.", "125.", "125.", "125.", "125.", "125.",
			},
		},
		["LowerBlackrockSpire5"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3350, 0.4888, 0.5670, 0.7181 },
				overlord_wyrmthalak = { 0.4510, 0.4153, 0.6710, 0.7391 },
				banner = { 0.2000, 0.0000, 0.8640, 0.1484 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "overlord_wyrmthalak", boss = "Overlord Wyrmthalak", pieces = { "overlord_wyrmthalak" }, back = "way_in", way = {} },
			},
			where = { cols = 125, rows = 84, keys = "way_in overlord_wyrmthalak banner way_in+overlord_wyrmthalak",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "37.59C29.", "37.59C29.", "29.67C1.6C22.", "28.77C20.", "27.79C19.", "26.81C18.", "26.81C18.",
				"26.4C3.67C3.4C18.", "27.4C4.3C57.3C4.5C18.", "28.3C71.4C19.", "103.1C21.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "67.11B47.",
				"66.13B46.", "66.13B46.", "66.13B46.", "67.11B47.", "67.10B48.", "67.11B47.", "67.11B47.", "50.13A15B47.",
				"49.13A3D13B47.", "49.13A3D13B47.", "49.13A3D13B47.", "50.12A2D14B47.", "66.12B47.", "67.11B47.",
				"67.11B47.", "68.9B48.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.", "125.",
				"125.", "125.", "125.", "125.",
			},
		},
	},
})
