local _, ns = ...

--[[ Scarlet Monastery: Cathedral's fog: its one floor, the client's map as the journal draws it
     (Media/Maps/Dungeons/scarlet-monastery-cathedral). Pieces are fractions of the visible picture, as the
     boss spots are; each is a mask, Media/Fog/ScarletMonasteryCathedral/<floor>/<piece>.tga, traced from the
     picture and split into rooms by Dev/maps/FogBuilder/fogbuild.py from Dev/maps/SMCathedralFog/
     fog_spec.py. Whitemane's round chapel opens only on the altar, Mograine's room: her way back goes on
     through his. The Scarlet Monastery's hall (the way-in map) has no fog. ]]
ns.AddFog("ScarletMonasteryCathedral", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["scarlet-monastery-cathedral"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.3623, 0.7485, 0.7006, 1.0000 },       -- the swirl, its passage and the corridor under the garden up to the garden's south door
				nave = { 0.2645, 0.1048, 0.5928, 0.5210 },       -- the nave, the crossing round the altar's front, the west arm and its cells, CRUSADER'S CHAPEL
				gardens = { 0.3493, 0.3743, 0.7435, 0.9207 },       -- the Chapel Gardens, their stairs to the cathedral's door, and the name CHAPEL GARDENS
				high_inquisitor_fairbanks = { 0.4850, 0.1557, 0.6427, 0.4072 },       -- his cell, the sheet by it where his pin is, and the transept's east arm
				scarlet_commander_mograine = { 0.3992, 0.1452, 0.5838, 0.3937 },       -- the chancel (altar and steps) and the crossing within 32 px of his spot
				high_inquisitor_whitemane = { 0.4142, 0.0838, 0.5699, 0.2934 },       -- the round chapel, its passage, and the sheet up to the map's name
				banner = { 0.2206, 0.0045, 0.7944, 0.1527 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "high_inquisitor_fairbanks", boss = "High Inquisitor Fairbanks", pieces = { "high_inquisitor_fairbanks" }, back = "entrance", way = { "nave", "gardens" } },
				{ id = "scarlet_commander_mograine", boss = "Scarlet Commander Mograine", pieces = { "scarlet_commander_mograine" }, back = "entrance", way = { "nave", "gardens" } },
				{ id = "high_inquisitor_whitemane", boss = "High Inquisitor Whitemane", pieces = { "high_inquisitor_whitemane" }, back = "scarlet_commander_mograine", way = {} },
			},
			where = { cols = 126, rows = 84, keys = "entrance nave gardens high_inquisitor_fairbanks scarlet_commander_mograine high_inquisitor_whitemane banner entrance+gardens nave+gardens nave+high_inquisitor_fairbanks nave+scarlet_commander_mograine high_inquisitor_fairbanks+scarlet_commander_mograine scarlet_commander_mograine+high_inquisitor_whitemane high_inquisitor_whitemane+banner nave+high_inquisitor_fairbanks+scarlet_commander_mograine",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "38.51G37.", "36.55G35.", "32.63G31.", "30.67G29.", "29.69G28.", "29.70G27.", "29.4G1.65G27.",
				"29.3G3.3G10.46G2.3G27.", "29.3G16.31G7.3G7.2G28.", "48.8G11N12G8.2G7.1G29.", "48.8G4N3F5N11G47.",
				"56.12F58.", "57.10F59.", "52.1B4.10F59.", "39.16B2.10F59.", "39.17B2.8F60.", "39.17B1.1E7F1.1E59.",
				"50.6B1K3E4M3E1L6D52.", "49.7B1K10E1L7D51.", "49.7B1K10E1L7D51.", "48.8B1K10E1L7D51.", "48.8B1K10E1L7D51.",
				"48.8B1K10E1L8D50.", "48.8B3K6E2K1O8D50.", "48.8B4K4E3K1O8D50.", "48.11B6K2B1J8D50.", "48.12B4K3B2J7D50.",
				"49.19B1J6D51.", "53.17B56.", "54.16B56.", "54.16B56.", "54.15B57.", "54.16B56.", "54.16B56.", "54.15B57.",
				"54.16B56.", "54.15I1C56.", "52.19C55.", "49.24C53.", "49.25C52.", "49.26C51.", "49.26C51.", "49.26C51.",
				"49.26C51.", "49.26C51.", "49.26C51.", "49.26C51.", "49.26C51.", "49.26C51.", "49.26C51.", "50.38C38.",
				"49.39C38.", "49.39C38.", "49.39C38.", "49.26C51.", "49.26C51.", "50.24C52.", "52.20C54.", "52.20C54.",
				"52.20C54.", "52.20C54.", "52.20C54.", "52.20C54.", "52.20C54.", "52.20C54.", "52.20C54.", "52.20C54.",
				"52.20C54.", "52.1C18H1C54.", "52.19H6A49.", "52.19H8A47.", "53.1A4H22A46.", "57.23A46.", "57.23A46.",
				"58.23A45.", "59.22A45.", "73.8A45.", "74.7A45.", "75.6A45.", "76.4A46.", "126.", "126.", "126.",
			},
		},
	},
})
