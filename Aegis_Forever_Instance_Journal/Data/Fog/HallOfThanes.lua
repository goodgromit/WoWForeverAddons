local _, ns = ...

--[[ The Hall of Thanes's fog: the journal's own picture (Media/Maps/HallOfThanes.tga).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/HallOfThanes/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/HallOfThanesFog/fog_spec.py. ]]
ns.AddFog("HallOfThanes", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["HallOfThanes"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6465, 0.9107, 0.9902, 0.9605 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.4121, 0.7936, 0.6074, 1.0000 },
				south_hall = { 0.4238, 0.7072, 0.5957, 0.9605 },
				faldrim_anvilmar = { 0.2373, 0.5037, 0.7842, 0.8551 },
				magmatus = { 0.5195, 0.3060, 0.8281, 0.6515 },
				plunder = { 0.4150, 0.3616, 0.6152, 0.6618 },
				durgen_dirgehammer = { 0.4219, 0.0571, 0.6758, 0.5081 },
				banner = { 0.2607, 0.0102, 0.7793, 0.1669 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "faldrim_anvilmar", boss = "Faldrim Anvilmar", pieces = { "faldrim_anvilmar" }, back = "entrance", way = { "south_hall" } },
				{ id = "magmatus", boss = "Magmatus", pieces = { "magmatus" }, back = "faldrim_anvilmar", way = {} },
				{ id = "plunder", boss = "Plunder", pieces = { "plunder" }, back = "faldrim_anvilmar", way = {} },
				{ id = "durgen_dirgehammer", boss = "Durgen Dirgehammer", pieces = { "durgen_dirgehammer" }, back = "plunder", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance south_hall faldrim_anvilmar magmatus plunder durgen_dirgehammer banner entrance+south_hall south_hall+faldrim_anvilmar faldrim_anvilmar+magmatus faldrim_anvilmar+plunder magmatus+plunder plunder+durgen_dirgehammer faldrim_anvilmar+magmatus+plunder",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "48.18G3.16G43.", "47.39G42.", "47.39G42.", "38.6G3.52G29.", "36.63G29.", "35.64G29.",
				"35.64G29.", "34.64G30.", "34.3G4.10G9.11F11.9G4.3G30.", "35.3G21.12F24.3G30.", "35.3G21.13F23.2G31.",
				"59.13F56.", "59.22F47.", "59.23F46.", "59.23F46.", "60.22F46.", "60.22F46.", "61.20F47.", "62.19F47.",
				"62.19F47.", "62.18F48.", "62.7F59.", "62.7F59.", "62.7F59.", "62.7F59.", "62.7F59.", "62.7F59.",
				"62.7F59.", "63.5F60.", "63.5F22.5D33.", "63.5F16.14D30.", "63.5F13.18D29.", "63.5F12.20D28.",
				"63.5F12.21D27.", "58.5E5F4E7.22D27.", "58.5E5M5E4.24D27.", "58.15E28D27.", "58.14E1L28D27.",
				"58.14E1L28D27.", "58.14E1L28D27.", "58.14E1L28D27.", "58.14E1L27D28.", "58.14E1L27D28.", "58.14E1L26D29.",
				"58.14E1L25D30.", "58.14E1L22D33.", "58.14E1L21D34.", "36.15C7.14E1N19J3C33.", "35.24C4E5K4E1N14C4J4C33.",
				"35.28C4K29C32.", "35.61C32.", "35.61C32.", "35.61C32.", "35.61C32.", "35.61C32.", "35.61C32.", "35.61C32.",
				"35.61C32.", "35.61C32.", "35.61C32.", "35.61C32.", "35.61C32.", "35.60C33.", "36.59C33.", "51.9C11I8C49.",
				"51.9C11I8C49.", "52.8C11B7C50.", "60.11B57.", "60.11B57.", "60.11B57.", "60.11B57.", "60.11B57.",
				"60.11B57.", "60.11H57.", "60.11H57.", "60.11A57.", "60.11A57.", "60.11A57.", "60.11A57.", "60.11A57.",
				"60.11A57.", "60.11A57.", "60.10A58.", "128.",
			},
		},
	},
})
