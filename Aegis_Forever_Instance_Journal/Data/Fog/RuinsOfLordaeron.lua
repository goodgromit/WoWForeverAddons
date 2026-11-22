local _, ns = ...

--[[ Ruins of Lordaeron's fog: the journal's own picture (Media/Maps/RuinsOfLordaeron.tga, Santiago Reyes's
     map, under his own frame: the parchment lies only inside it and off his credit, the floor's extent, with no
     shared Frame mask). Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/RuinsOfLordaeron/<floor>/<piece>.tga, split into districts by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/RuinsOfLordaeronFog/fog_spec.py. Every boss's way runs back to the way in through one of two
     bossless streets (alley_w east of the throne room, palace north and west of it), except Viktor's: no
     street reaches the graveyard, so his runs back through the Baron's overlook, the run's order. ]]
ns.AddFog("RuinsOfLordaeron", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["RuinsOfLordaeron"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6289, 0.8931, 0.9766, 0.9473 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.5020, 0.0249, 0.7129, 0.4158 },       -- the north-east palace building, the swirl
				alley_w = { 0.5186, 0.2474, 0.6816, 0.6398 },       -- the rubble strip east of the throne room: Witherfang's and the Baron's way
				the_baron = { 0.4277, 0.4817, 0.8008, 0.9517 },       -- Lordamere Overlook, its name, the south-east
				witherfang = { 0.5752, 0.0630, 0.8525, 0.6471 },       -- King's Alley and its name
				palace = { 0.3467, 0.0586, 0.6143, 0.6047 },       -- the palace, its court and lawn, the ground west of the throne room: the west's way
				the_abandoned = { 0.3125, 0.4158, 0.4883, 0.6896 },       -- the walled courtyard, its pool and tower
				nw_quarter = { 0.2441, 0.0659, 0.4678, 0.3734 },       -- the north-west quarter: Bjork's way, the Captain's spot
				bjork = { 0.1631, 0.1874, 0.5010, 0.5593 },       -- Market Street and its name
				rathmael = { 0.3809, 0.2533, 0.6377, 0.7862 },       -- the throne room and his ground
				viktor = { 0.2471, 0.4158, 0.6455, 0.9927 },       -- Lordaeron Graveyard, its name, the west lane, the south
				banner = { 0.1719, 0.0059, 0.9014, 0.1742 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "the_baron", boss = "The Baron", pieces = { "the_baron" }, back = "entrance", way = { "alley_w" } },
				{ id = "witherfang", boss = "Witherfang", pieces = { "witherfang" }, back = "entrance", way = { "alley_w" } },
				{ id = "the_abandoned", boss = "The Abandoned", pieces = { "the_abandoned" }, back = "entrance", way = { "palace" } },
				{ id = "bjork", boss = "Bjork", pieces = { "bjork" }, back = "entrance", way = { "nw_quarter", "palace" } },
				{ id = "rathmael", boss = "Rath'mael", pieces = { "rathmael" }, back = "entrance", way = { "palace" } },
				{ id = "viktor", boss = "Viktor the Vile", pieces = { "viktor" }, back = "the_baron", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance alley_w the_baron witherfang palace the_abandoned nw_quarter bjork rathmael viktor banner entrance+alley_w entrance+witherfang entrance+palace entrance+banner alley_w+the_baron alley_w+witherfang alley_w+rathmael the_baron+witherfang the_baron+rathmael the_baron+viktor witherfang+banner palace+the_abandoned palace+nw_quarter palace+bjork palace+rathmael palace+banner the_abandoned+bjork the_abandoned+rathmael the_abandoned+viktor nw_quarter+bjork nw_quarter+banner bjork+viktor rathmael+viktor entrance+alley_w+witherfang entrance+alley_w+rathmael entrance+witherfang+banner entrance+palace+rathmael alley_w+the_baron+witherfang alley_w+the_baron+rathmael the_baron+rathmael+viktor palace+the_abandoned+bjork palace+the_abandoned+rathmael palace+nw_quarter+bjork palace+nw_quarter+banner the_abandoned+bjork+viktor the_abandoned+rathmael+viktor entrance+alley_w+palace+rathmael",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "39.7K1.42K4.5K30.", "36.66K26.", "36.66K26.", "29.4K3.66K26.", "27.84K17.", "25.87K16.",
				"24.22K4f34K5V25K14.", "24.14K4f2K6f3s21a6K11V23K14.", "23.13K12f6s21a4O1k19V15K14.",
				"23.4K3.5K13f1s5X17E4N4O1k1M7D13V6K3.4K14.", "23.3K5.3K4f11G4X18E2N8A3M16D1V6K5.2K14.",
				"24.3K4.3K3f13G1X20E2N8A3M16D2V5K4.3K14.", "24.3K7.16G1X20E2N8A3M17D10.2K15.", "35.15G1X20E2N8A3M16D28.",
				"36.14G1X20E2N8A3M15D29.", "36.14G1X20E2N8A3M15D29.", "37.13G3X18E2N8A3M15D29.", "37.14G3X17E2N8A3M15D29.",
				"37.15G2X17E2N8A4M13D30.", "37.16G1X17E2N8A4M13D30.", "37.16G2X1Y15E2N9A2M15D29.",
				"36.9e8G1r4Y13E2N9A2M15D29.", "36.10e6G1e1r3H2Y12E2N9A2M16D28.", "36.9H2e4G3e3H2Y12E2N6A5M16D28.",
				"36.10H7e4H2Y12E2N6A2M19D28.", "36.11H4e5H2Y13E2N6A2M19D28.", "36.19H2Y5E9Z1l1v6L2i18D29.",
				"36.18H2Y6E1Z3I5Z1l1v1j6L1i1Q17D29.", "36.18H2Y6E1Z9I2R6B2Q17D29.", "37.17H2Y6E1Z9I2R6B2Q17D29.",
				"36.18H2Y6E1Z9I2R6B2Q17D29.", "36.19H1Y6E1Z9I2R6B2Q18D28.", "36.19H1Y6E1Z9I2R6B2Q22D24.",
				"36.19H2Y5E1Z9I2R6B2Q22D24.", "26.29H2Y5E1Z10I1R6B2Q22D24.", "26.29H2Y4E2Z10I1R6B2Q22D24.",
				"26.29H2Y3E3Z10I2R5B2Q22D24.", "26.29H2Y3E2Z11I2R5B2Q21D25.", "26.29H2Y2E2Z13I2R4B2Q16D30.",
				"27.28H2Y2E2Z13I2R4B2Q16D30.", "36.10g1t8b2p2E2Z14I1R4B2Q17D29.", "36.1J8g2t8b2p2E2Z14I1R4B2Q17D29.",
				"37.8J2d8F2W2E2Z14I1R4B2Q17D29.", "37.8J2d8F1W1q4Z14I1R4B2Q16D30.", "38.7J2d9F1q4Z14I1R4B2Q16D30.",
				"38.7J2d9F1c2I1Z15I1R3B2Q16D31.", "38.7J2d9F1c6I9T3I1R3B2Q16D31.", "38.7J2d9F1c4I4T4C6T1n3P2m1D8S1D6S31.",
				"38.7J2d9F1c3I2T11C2T1n4P1m15S1C31.", "37.8J2d9F1c4I2T34C31.", "37.8J2d9F1c4I2T34C31.",
				"38.7J10d2c5I2T33C31.", "38.14J2d2u1c5I1T34C31.", "39.15J2h7I1T33C31.", "39.15J2h7I1T32C32.",
				"40.15J1h7I1T31C33.", "39.16J1h7I1T31C33.", "39.16J2h6I1T31C33.", "39.16J4h4I2T30C33.",
				"39.18J7h1o1U29C33.", "40.21J3h1o1U29C33.", "40.25J2U27C34.", "40.25J2U27C34.", "40.26J1U26C35.",
				"40.26J2U23C37.", "40.26J2U22C38.", "41.25J2U22C38.", "45.22J2U20C39.", "46.22J2U18C40.", "47.21J8U11C41.",
				"50.20J7U7C44.", "51.24J2U6C45.", "52.23J2U6C45.", "52.23J2U5C46.", "53.23J1U4C47.", "55.1J2.18J1U3C48.",
				"59.16J53.", "60.14J54.", "62.4J2.5J55.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
	},
})
