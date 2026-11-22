local _, ns = ...

--[[ Scarlet Monastery: Graveyard's fog: its one floor, the client's map as the journal draws it (Media/
     Maps/Dungeons/scarlet-monastery-graveyard). Pieces are fractions of the visible picture, as the boss
     spots are; each is a mask, Media/Fog/ScarletMonasteryGraveyard/<floor>/<piece>.tga, traced from the
     game's own tiles and split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/SMGraveyardFog/fog_spec.py, which holds the touch-ups.
     The three rares (Azshir the Sleepless, the Fallen Champion, Ironspine) share six places and hold
     back no fog at all: five places clear with the cloister, the sixth with Honor's Tomb. ]]
ns.AddFog("ScarletMonasteryGraveyard", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["scarlet-monastery-graveyard"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.7056, 0.6781, 0.9202, 0.9461 },
				chamber = { 0.6108, 0.4835, 0.7964, 0.7695 },       -- the Chamber of Atonement round Vishas's pocket (the pillar's west and south sides)
				long_hall = { 0.6936, 0.5434, 0.8234, 0.9057 },       -- the long hall north of the way in
				interrogator_vishas = { 0.6038, 0.4371, 0.7974, 0.7081 },       -- a 30 px pocket in the chamber's north-east lobe, and CHAMBER OF ATONEMENT
				tomb = { 0.0938, 0.4521, 0.3423, 0.7096 },       -- Honor's Tomb but for its north band (its west column, the rares' place 6), and HONOR'S TOMB
				cloister = { 0.1786, 0.3234, 0.6277, 0.8024 },       -- the Forlorn Cloister: the nave, the gardens (the rares' places 1-5), the east rooms
				west_hall = { 0.5220, 0.4506, 0.7106, 0.7081 },       -- the hall west of the chamber and its corridor to the cloister's east door
				bloodmage_thalnos = { 0.1547, 0.4042, 0.3423, 0.6287 },       -- Honor's Tomb's north band, and the garden by his spot (21 px)
				banner = { 0.2196, 0.0165, 0.7934, 0.1841 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "interrogator_vishas", boss = "Interrogator Vishas", pieces = { "interrogator_vishas" }, back = "entrance", way = { "chamber", "long_hall" } },
				{ id = "bloodmage_thalnos", boss = "Bloodmage Thalnos", pieces = { "bloodmage_thalnos" }, back = "entrance", way = { "tomb", "cloister", "west_hall", "chamber", "long_hall" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance chamber long_hall interrogator_vishas tomb cloister west_hall bloodmage_thalnos banner entrance+long_hall chamber+long_hall chamber+interrogator_vishas chamber+west_hall interrogator_vishas+west_hall tomb+cloister tomb+bloodmage_thalnos cloister+west_hall cloister+bloodmage_thalnos chamber+interrogator_vishas+west_hall tomb+cloister+bloodmage_thalnos",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "126.", "41.2I1.1I39.2I40.", "38.51I37.", "36.55I35.", "32.63I31.", "30.68I28.", "29.69I28.",
				"29.70I27.", "29.4I1.65I27.", "29.2I3.4I10.32I7.1I1.4I3.3I27.", "29.3I16.32I15.3I28.",
				"30.1I17.32I15.3I28.", "48.31I16.2I29.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
				"126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "30.25F71.", "28.30F68.",
				"28.31F1.8F58.", "28.41F57.", "28.42F56.", "28.42F56.", "28.42F56.", "28.1F3R40F54.", "28.6R39F53.",
				"26.6H6R35F53.", "25.8H5R35F11.10D32.", "24.12H2R35F7.1G2.12D31.", "23.1E1H5P1H2P3H2R36F5.3G1N12D31.",
				"17.8E9P2H2R34F2Q8G1N12D31.", "17.16E3P2T33F3Q8G1N11D32.", "17.19E2O33F2Q10G1N3L7D32.",
				"18.18E2O34F2Q8G2S1L1B1L8D31.", "19.17E2O36F1.1G1.5G2M2B1L8D31.", "24.12E2O36F4.4G2M2B1L8D31.",
				"24.12E2O36F5.3G2M2B2L6D4C28.", "24.5E9O36F5.4G1M3B7L4C28.", "24.4E9O36F6.4G5B5L2K4C27.",
				"27.1E45F8.1G11B2K4C27.", "28.43F11.11B2K4C27.", "28.42F12.11B2K4C27.", "27.43F13.10B2K4C27.",
				"28.41F15.9B6C27.", "28.40F17.2B5.7C27.", "28.30F34.7C27.", "28.29F36.6C27.", "93.6C27.", "92.5C1J1C27.",
				"92.5C1J4A24.", "93.4C1J8A20.", "92.5C1J9A19.", "92.5C1J10A18.", "93.4C1J11A17.", "93.4C1J4.7A17.",
				"94.3C6.6A17.", "104.4A18.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.", "126.",
				"126.", "126.",
			},
		},
	},
})
