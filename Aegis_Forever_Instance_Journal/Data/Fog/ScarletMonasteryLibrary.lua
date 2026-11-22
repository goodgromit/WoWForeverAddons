local _, ns = ...

--[[ Scarlet Monastery: Library's fog: its one floor, the client's map as the journal draws it (Media/Maps/Dungeons/
     scarlet-monastery-library). Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/ScarletMonasteryLibrary/<floor>/<piece>.tga, traced from the game's own tiles and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/SMLibraryFog/fog_spec.py. ]]
ns.AddFog("ScarletMonasteryLibrary", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["scarlet-monastery-library"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.0559, 0.0120, 0.3044, 0.3623 },       -- the passage from the swirl and the long hall's north end (cut at its first pilasters)
				cloister = { 0.1277, 0.1617, 0.4611, 0.8398 },       -- the long hall, the Huntsman's Cloister and its name, the passage to Loksey's door
				houndmaster_loksey = { 0.1906, 0.6527, 0.4002, 1.0000 },       -- the pink room south of the cloister, and its walls
				athenaeum = { 0.7265, 0.0539, 1.0000, 0.7171 },       -- the Athenaeum's hall, its name, and the pillared room south of it
				gallery = { 0.3313, 0.0329, 0.8493, 0.7710 },       -- the passage east, the second corridor, the Gallery of Treasures and its name, the pillared rooms
				arcanist_doan = { 0.7116, 0.5434, 0.9581, 0.9266 },       -- the round room at the Athenaeum's south end
				banner = { 0.0739, 0.0030, 0.6477, 0.1677 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "houndmaster_loksey", boss = "Houndmaster Loksey", pieces = { "houndmaster_loksey" }, back = "entrance", way = { "cloister" } },
				{ id = "arcanist_doan", boss = "Arcanist Doan", pieces = { "arcanist_doan" }, back = "entrance", way = { "athenaeum", "gallery", "cloister" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance cloister houndmaster_loksey athenaeum gallery arcanist_doan banner entrance+cloister entrance+banner cloister+houndmaster_loksey cloister+gallery athenaeum+gallery athenaeum+arcanist_doan gallery+banner",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "22.8G32.7G57.", "20.51G55.", "17.57G52.", "13.65G48.", "11.68G47.", "11.68G1N1E45.",
				"10.51G9N5G2N1G2N3E43.", "10.4G2.9G3I32G15N2E4N3E3.12E27.", "10.3G3.2G5.6A30G1N12E3N3E3N19E5.2D19.",
				"11.2G9.8A28G2N40E2.7D17.", "22.8A1I22G7N41E8D17.", "18.12A1I21G8N41E10D15.", "16.15A21.47E2L11D14.",
				"16.15A22.46E2L11D14.", "16.14A23.46E2L11D14.", "16.14A23.46E2L11D14.", "16.14A23.46E2L11D14.",
				"15.15A23.46E2L11D14.", "14.7A9H20.49E2L11D14.", "14.7A9H20.50E2L9D15.", "14.7A2B7H20.49E3L9D15.",
				"15.6A9B20.49E2L11D14.", "18.1A2.9B21.48E13D14.", "22.9B22.25E1.6E1.6E1.5E24D4.", "22.8B23.20E25.24D4.",
				"22.8B23.20E25.24D4.", "21.9B23.19E26.14D14.", "21.9B23.18E28.12D15.", "21.10B22.18E28.12D15.",
				"21.10B17.24E27.13D14.", "22.9B16.26E25.14D14.", "22.8B17.26E25.14D14.", "22.8B17.26E25.14D14.",
				"21.9B17.26E25.14D14.", "21.9B17.1K25E25.14D14.", "21.26B5K21E25.14D14.", "22.25B5K20E27.12D15.",
				"22.29B1K19E28.12D15.", "22.29B1K18E28.14D14.", "22.28B2K10E1.6E28.16D13.", "21.29B2K10E35.16D13.",
				"21.29B2K9E36.17D12.", "22.28B2K9E36.17D12.", "22.28B2K9E36.16D13.", "22.28B2K10E35.16D13.",
				"22.28B2K10E35.16D13.", "23.27B2K9E36.16D13.", "24.26B2K9E36.17D12.", "28.22B2K9E36.17D12.",
				"28.22B2K9E36.17D12.", "28.22B2K10E35.6D4M6D13.", "28.22B2K10E36.4D6M5D13.", "28.22B2K10E36.1D5M3F3M2D14.",
				"28.22B2K9E37.1F3M6F2M2F14.", "28.25B8E36.16F13.", "28.25B8E35.18F12.", "28.25B8E35.18F12.",
				"28.25B1.6E36.19F11.", "28.25B3.2E37.20F11.", "28.14B1J10B42.20F11.", "28.3B6J3B4J8B43.21F10.",
				"28.3B7J1B3J10B43.21F10.", "31.3C8J2C51.21F10.", "30.6C5J4C50.20F11.", "30.15C50.20F11.", "30.15C51.19F11.",
				"30.15C51.18F12.", "30.15C52.17F12.", "30.15C52.16F13.", "30.15C54.13F14.", "30.15C55.10F16.",
				"30.15C58.5F18.", "30.15C81.", "30.15C81.", "30.15C81.", "30.15C81.", "30.15C81.", "126.", "126.", "126.",
				"126.", "126.", "126.",
			},
		},
	},
})
