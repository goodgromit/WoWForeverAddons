local _, ns = ...

--[[ Scarlet Monastery: Armory's fog: its one floor, the client's map as the journal draws it
     (Media/Maps/Dungeons/scarlet-monastery-armory). Pieces are fractions of the visible picture, as the
     boss spots are; each is a mask, Media/Fog/ScarletMonasteryArmory/<floor>/<piece>.tga, traced from the
     game's own tiles and split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/SMArmoryFog/fog_spec.py. Herod is the wing's one boss: his kill is the full clear, so his
     room and way never show by themselves. The pieces follow the wing's four named areas. ]]
ns.AddFog("ScarletMonasteryArmory", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["scarlet-monastery-armory"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.5160, 0.8099, 0.7255, 1.0000 },       -- the swirl's room and its passage up to the Training Grounds
				hallway = { 0.6018, 0.1033, 0.8613, 0.3054 },       -- the hallway before the Hall of Champions
				crusaders_armory = { 0.6098, 0.1467, 0.8473, 0.4955 },       -- the Crusader's Armory and the passage up to the hallway
				footmans_armory = { 0.6118, 0.3338, 0.8463, 0.7380 },       -- the Footman's Armory and the passage up to the Crusader's Armory
				training_grounds = { 0.5699, 0.5853, 0.8383, 0.9910 },       -- the Training Grounds, their name and the passage up to the Footman's Armory
				herod = { 0.6896, 0.0000, 0.8852, 0.2605 },       -- the Hall of Champions: the round room, its cog rim and its door
				banner = { 0.1487, 0.0195, 0.7226, 0.1946 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "herod", boss = "Herod", pieces = { "herod" }, back = "entrance", way = { "hallway", "crusaders_armory", "footmans_armory", "training_grounds" } },
			},
			where = { cols = 126, rows = 84, keys = "entrance hallway crusaders_armory footmans_armory training_grounds herod banner entrance+training_grounds hallway+crusaders_armory hallway+herod crusaders_armory+footmans_armory footmans_armory+training_grounds",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"126.", "99.1F26.", "95.8F23.", "30.27G2.6G2.13G14.10F22.", "28.54G11.12F21.", "24.63G6.13F20.",
				"22.67G3.14F20.", "20.69G3.14F20.", "20.70G2.15F19.", "20.70G2.15F19.", "20.2G2.8G6.33G6.9G1.3G2.14F20.",
				"20.12G7.32G6.8G2.3G2.14F20.", "21.2G1.8G6.34G6.6G3.2G4.12F21.", "25.2G2.1G7.35G8.2G11.12F21.",
				"37.5G4.9G12.5G10.13B1.3J1F1J3F22.", "81.15B5J2B23.", "81.23B22.", "81.23B22.", "81.2B13I7B23.",
				"83.1C1I1C11I5B24.", "82.16C28.", "82.16C28.", "82.16C28.", "82.16C28.", "82.15C29.", "84.13C29.",
				"85.13C28.", "86.12C28.", "86.13C27.", "86.15C25.", "86.15C25.", "86.16C24.", "86.16C24.", "86.12C2K1C25.",
				"86.11C4K25.", "87.9C1K4D25.", "89.1C3.3C5D25.", "96.5D25.", "93.2D1.5D25.", "87.14D25.", "86.15D25.",
				"86.16D24.", "86.16D24.", "86.16D24.", "86.15D25.", "86.15D25.", "86.12D28.", "86.12D28.", "85.13D28.",
				"83.15D28.", "83.15D28.", "82.16D28.", "82.16D28.", "82.16D28.", "82.16D28.", "82.5L10D29.", "82.5E9D30.",
				"82.6E1D37.", "78.12E36.", "77.14E35.", "77.15E34.", "77.15E34.", "77.15E34.", "77.15E34.", "77.15E34.",
				"77.22E27.", "77.23E26.", "77.23E26.", "77.23E26.", "77.23E26.", "77.21E28.", "77.15E34.", "77.15E34.",
				"77.15E34.", "77.1E4H10E34.", "76.1A7H8E34.", "74.4A6H8E34.", "72.9A3H7E35.", "72.13A41.", "72.12A42.",
				"72.12A42.", "73.10A43.", "75.5A46.", "126.",
			},
		},
	},
})
