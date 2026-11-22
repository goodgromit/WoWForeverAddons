local _, ns = ...

--[[ Krol'dok Stronghold's fog: the journal's own picture (Media/Maps/KroldokStronghold.tga, Santiago Reyes's
     map, under his own frame: the parchment lies only inside it and off his credit, the floor's extent, with no
     shared Frame mask). Pieces are fractions of the visible picture, as the boss spots are. The way in (his
     portal swirl) and the name are clear at the start; each of the six bosses clears his own part of the valley,
     split along the way the run goes (Handler Ashka and Nar'gurk in either order), and the whole fog goes once
     the five that hold it back are dead: Bossman Toof does not (counts), as his kill may go unseen (it counts
     by his English name only), so Overseer Mugg's kill clears the whole map even when Toof's was never seen;
     his own part still clears with his kill when it is. Built by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/KroldokStrongholdFog/fog_spec.py. ]]
ns.AddFog("KroldokStronghold", {
	-- false: never holds the fog back (his room, if he has one, still clears with his kill; a rare,
	-- a summoned boss or one the owner named holds no fog and has none); true: holds it back
	counts = { ["Bossman Toof"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["KroldokStronghold"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6211, 0.9019, 0.9766, 0.9517 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.1162, 0.6750, 0.3232, 1.0000 },       -- the portal swirl at the valley's south-west corner (read from the art)
				slavecrusher_grox = { 0.1377, 0.5915, 0.3535, 1.0000 },       -- the open ground just inside the way in
				twilight_commander_zarmok = { 0.1748, 0.4905, 0.5244, 1.0000 },       -- the yards along the long wall's south-west side, down to the south gate
				handler_ashka = { 0.4199, 0.3953, 0.7715, 0.9444 },       -- the way east past the gate's buildings, and the east yard to the river
				nar_gurk = { 0.2500, 0.2826, 0.5830, 0.7994 },       -- the long stone walkway and the inner yard behind it
				bossman_toof = { 0.4678, 0.2474, 0.6855, 0.6369 },       -- the two wooden bridges, the dome between them and the green north of them
				overseer_mugg = { 0.5166, 0.0161, 0.8301, 0.5769 },       -- the great hall, the north complex, the river path and the east bank
				banner = { 0.0029, 0.0337, 0.6289, 0.1742 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "slavecrusher_grox", boss = "Slavecrusher Grox", pieces = { "slavecrusher_grox" }, back = "entrance", way = {} },
				{ id = "twilight_commander_zarmok", boss = "Twilight Commander Zarmok", pieces = { "twilight_commander_zarmok" }, back = "slavecrusher_grox", way = {} },
				{ id = "handler_ashka", boss = "Handler Ashka", pieces = { "handler_ashka" }, back = "twilight_commander_zarmok", way = {} },
				{ id = "nar_gurk", boss = "Nar'gurk", pieces = { "nar_gurk" }, back = "twilight_commander_zarmok", way = {} },
				{ id = "bossman_toof", boss = "Bossman Toof", pieces = { "bossman_toof" }, back = "nar_gurk", way = {} },
				{ id = "overseer_mugg", boss = "Overseer Mugg", pieces = { "overseer_mugg" }, back = "bossman_toof", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance slavecrusher_grox twilight_commander_zarmok handler_ashka nar_gurk bossman_toof overseer_mugg banner entrance+slavecrusher_grox slavecrusher_grox+twilight_commander_zarmok twilight_commander_zarmok+handler_ashka twilight_commander_zarmok+nar_gurk handler_ashka+nar_gurk handler_ashka+bossman_toof handler_ashka+overseer_mugg nar_gurk+bossman_toof bossman_toof+overseer_mugg twilight_commander_zarmok+handler_ashka+nar_gurk handler_ashka+nar_gurk+bossman_toof handler_ashka+bossman_toof+overseer_mugg",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "12.57H59.", "11.59H58.", "7.1H3.59H17.1G40.", "5.74H3.11G35.",
				"3.77H15G33.", "2.77H19G30.", "1.78H21G28.", "1.77H22G28.", "2.1H4.66H3.2H22G28.", "7.5H57.1H7.24G27.",
				"77.24G27.", "76.25G27.", "76.25G27.", "76.25G27.", "75.26G27.", "75.26G27.", "75.26G27.", "74.27G27.",
				"74.27G27.", "73.28G27.", "73.28G27.", "72.29G27.", "71.2Q28G27.", "70.1F2Q28G27.", "69.3F1Q28G27.",
				"67.1E1P3F2Q27G27.", "65.2E2P4F1Q27G27.", "63.5E1P4F2Q26G27.", "61.6E2P5F2Q25G27.", "60.7E2P5F2Q25G27.",
				"57.10E2P6F2Q24G27.", "52.15E1P8F3Q22G27.", "48.19E1P9F3Q21G27.", "45.22E1P11F2Q19G28.",
				"43.24E1P12F2Q18G28.", "41.25E2P12F2Q6G2O9G29.", "40.26E2P13F1T9O8G29.", "39.27E2P11F3N8D2O6G30.",
				"39.27E1P11F2N11D2O4G31.", "38.28E1P9F3N13D2O1G33.", "38.28E1P8F3N14D1O1G34.", "38.28E1P7F2N16D36.",
				"37.29E1P4F4N15D38.", "37.1L27E2P2F4N16D39.", "37.3L25E2S3N17D41.", "36.3C3L24E2M18D42.",
				"35.5C3L24E2M16D43.", "34.8C3L22E2M15D44.", "33.11C3L20E1M15D45.", "31.15C2L18E2M13D47.",
				"29.18C3L16E2M12D48.", "28.21C2L14E2M13D48.", "27.4J18C3L13E2M12D49.", "26.2B6J17C2L12E1M12D50.",
				"25.7B4J16C2L11E1M12D50.", "25.10B3J15C1L10E2M11D51.", "24.12B2J15C4L7E2M11D51.", "24.13B2J16C5L1E4M11D52.",
				"23.15B1J18C2L2R3M12D52.", "23.15B2J20C1K14D53.", "23.15B2J20C1K14D53.", "23.1I14B2J20C2K12D54.",
				"22.1A4I11B2J20C2K12D54.", "22.3A4I9B1J21C2K11D55.", "22.5A2I9B1J21C2K10D56.", "22.6A2I8B1J21C1K10D57.",
				"22.7A2I6B2J20C2K9D58.", "22.8A2I5B2J20C2K8D59.", "22.8A3I4B2J20C2K6D61.", "22.9A2I4B1J22C1K5D62.",
				"22.10A1I3B2J22C2K2D64.", "22.10A2I2B2J22C2K66.", "22.10A2I2B2J23C67.", "22.10A2I2B1J23C68.",
				"22.10A2I2B1J22C69.", "22.10A2I2B1J22C69.", "22.10A2I2B1J21C70.", "23.9A2I2B1J21C70.", "24.8A96.", "128.",
				"128.", "128.",
			},
		},
	},
})
