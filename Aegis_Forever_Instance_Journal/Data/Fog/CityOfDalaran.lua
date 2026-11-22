local _, ns = ...

--[[ City of Dalaran's fog: the journal's own pictures (Media/Maps/CityOfDalaranSewers.tga, Media/Maps/CityOfDalaranCity.tga).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/CityOfDalaran/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/CityOfDalaranFog/fog_spec.py. ]]
ns.AddFog("CityOfDalaran", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["CityOfDalaranSewers"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6299, 0.8873, 0.9756, 0.9414 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.1016, 0.6237, 0.3320, 0.9678 },
				underbelly = { 0.1865, 0.0176, 0.8271, 0.9370 },       -- the sewers' hall, pipes and tavern, Lyn's tunnel and room: on every way
				atrexis = { 0.5254, 0.4656, 0.6914, 0.7145 },       -- the ritual circle (a pocket: the hall round it is on every way)
				banner = { 0.0615, 0.0498, 0.5254, 0.2050 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "atrexis", boss = "Atrexis the Grave Knight", pieces = { "atrexis" }, back = "entrance", way = { "underbelly" } },
			},
			where = { cols = 128, rows = 86, keys = "entrance underbelly atrexis banner entrance+underbelly underbelly+atrexis",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "20.12D1.5D7.7D76.", "20.35D32.2B39.", "20.35D30.7B36.",
				"13.51D19.10B35.", "11.53D17.13B34.", "10.56D15.14B33.", "9.57D15.15B32.", "9.57D14.16B32.",
				"9.14D30.13D15.15B32.", "9.13D31.13D14.15B33.", "10.12D31.12D15.15B33.", "13.9D31.8D19.15B33.", "80.15B33.",
				"65.1B14.15B33.", "63.5B12.15B33.", "61.8B10.14B35.", "54.16B9.12B37.", "53.20B5.11B39.", "52.23B2.8B43.",
				"49.35B44.", "48.35B45.", "47.36B45.", "46.38B44.", "46.40B42.", "46.41B41.", "46.42B40.", "46.42B40.",
				"46.42B40.", "46.42B40.", "46.42B40.", "46.42B40.", "37.7B1.45B38.", "32.59B37.", "29.63B36.", "29.63B36.",
				"29.63B36.", "29.63B36.", "29.11B4.48B36.", "29.11B5.50B33.", "30.8B6.52B32.", "31.3B9.33B4F18B30.",
				"42.33B6F18B29.", "41.33B2F4C2F18B28.", "41.32B2F6C2F18B27.", "40.33B1F7C2F18B27.", "40.33B1F8C1F18B27.",
				"39.34B1F8C1F9B1.7B28.", "38.35B2F6C2F8B3.5B29.", "38.35B2F5C2F9B4.3B30.", "37.37B3F1C4F8B38.",
				"36.40B4F11B37.", "35.55B38.", "35.55B38.", "34.55B39.", "33.55B40.", "32.2E53B41.",
				"30.1A4E5B1.9B1.35B42.", "29.2A4E4B3.7B3.33B43.", "28.5A3E2B14.34B42.", "27.6A3E1B14.36B41.",
				"26.8A2E15.37B40.", "25.10A16.23B1.13B40.", "25.8A19.21B3.12B40.", "23.9A21.19B5.10B41.",
				"21.10A23.17B7.9B41.", "20.10A24.17B8.7B42.", "20.10A26.13B11.5B43.", "20.9A29.10B14.2B44.",
				"20.8A32.7B61.", "21.6A35.4B62.", "22.4A38.1B63.", "128.", "128.", "128.", "128.", "128.", "128.", "128.",
				"128.", "128.", "128.",
			},
		},
		["CityOfDalaranCity"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.6504, 0.8887, 0.9980, 0.9488 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3672, 0.5329, 0.6279, 0.8536 },       -- the round court and the street by the sewers' hatch, where the sewers come up
				landing = { 0.3691, 0.6808, 0.6836, 1.0000 },       -- Krasus Landing's lawns, the gate and its stairs: the Arcane Anomaly's way
				arcane_anomaly = { 0.4385, 0.7130, 0.6064, 0.9649 },       -- the landing's terrace (a pocket)
				arcanic_enigma = { 0.5010, 0.3089, 0.8018, 0.9605 },
				square = { 0.3711, 0.3514, 0.6377, 0.7321 },       -- Runeweaver Square round the barrier, and the streets down to the round court
				unstable_sentinel = { 0.4922, 0.2416, 0.7656, 0.5564 },
				mana_devourer = { 0.1768, 0.4378, 0.5557, 1.0000 },
				fel_ancient = { 0.4355, 0.4129, 0.6768, 0.6794 },       -- the barrier and the square's name (a pocket)
				shade = { 0.2354, 0.0000, 0.7285, 0.5959 },
				banner = { 0.5322, 0.0498, 0.9902, 0.1977 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "arcane_anomaly", boss = "Arcane Anomaly", pieces = { "arcane_anomaly" }, back = "way_in", way = { "landing" } },
				{ id = "arcanic_enigma", boss = "Arcanic Enigma", pieces = { "arcanic_enigma" }, back = "way_in", way = {} },
				{ id = "unstable_sentinel", boss = "Unstable Sentinel", pieces = { "unstable_sentinel" }, back = "way_in", way = { "square" } },
				{ id = "mana_devourer", boss = "Mana Devourer", pieces = { "mana_devourer" }, back = "way_in", way = {} },
				{ id = "fel_ancient", boss = "Fel Ancient", pieces = { "fel_ancient" }, back = "way_in", way = { "square" } },
				{ id = "shade", boss = "Shade of the Archmage", pieces = { "shade" }, back = "way_in", way = { "square" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in landing arcane_anomaly arcanic_enigma square unstable_sentinel mana_devourer fel_ancient shade banner way_in+landing way_in+arcanic_enigma way_in+square way_in+mana_devourer landing+arcane_anomaly landing+arcanic_enigma landing+mana_devourer arcanic_enigma+square arcanic_enigma+unstable_sentinel arcanic_enigma+fel_ancient square+unstable_sentinel square+mana_devourer square+fel_ancient square+shade unstable_sentinel+fel_ancient unstable_sentinel+shade mana_devourer+shade way_in+landing+arcanic_enigma way_in+landing+mana_devourer way_in+arcanic_enigma+square way_in+square+mana_devourer way_in+square+fel_ancient arcanic_enigma+square+fel_ancient arcanic_enigma+unstable_sentinel+fel_ancient square+unstable_sentinel+fel_ancient square+unstable_sentinel+shade square+mana_devourer+shade",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "64.1I63.", "58.10I60.", "57.12I11.34J14.", "56.13I10.35J14.", "55.14I5.47J7.",
				"54.15I1.52J6.", "53.16I1.54J4.", "52.17I1.46J1.8J3.", "51.18I46J2.8J3.", "50.19I46J2.9J2.",
				"49.20I2J4.5J1.2J29.2J8.4J2.", "49.20I3J50.3J3.", "48.21I1.2J50.3J3.", "48.33I47.", "47.34I47.",
				"46.36I46.", "44.39I45.", "42.44I42.", "39.48I41.", "38.50I40.", "37.51I40.", "37.51I40.", "37.51I40.",
				"37.45I6Z40.", "36.42I9Z2F39.", "36.40I4Z9F39.", "36.38I3Z12F39.", "35.38I2Z15F38.", "35.37I2Z16F38.",
				"35.36I3Z7F2S7F38.", "35.36I2Z8F3S6F38.", "35.35I2Z8F2S1D2S6F37.", "35.34I2Z8F2S3D2S6F36.",
				"35.27I6X2j9F1S5D2S6F35.", "35.27I2X1E3X1j1U8F2S6D7S35.", "35.26I3X5E1U8F2S14D34.",
				"35.25I3X6E2U8F1S15D33.", "35.24I2X9E3U6F2S14D33.", "35.22I3X6E5W3i6Y1h14D33.", "35.20I4X4E5W12H1T15D32.",
				"35.1I1a13I3a1k3X5E3W15H1T15D32.", "35.18a1k1V7E2W16H1T16D31.", "35.4G10a4G2V6E2W17H1T16D31.",
				"36.17G2V6E2W17H1T16D31.", "36.17G2V6E2W17H1T16D31.", "36.17G2V6E2W17H1T16D31.",
				"36.17G2V6E2W9H3W1g5T17D30.", "37.16G2V7E2W6H3W1E2R22D30.", "37.16G2V8E4W1H4W1E2R23D30.",
				"37.17G1V2E4M4E4W1f2M2R24D30.", "37.17G1V1e9M3E3M2d25D30.", "37.17G1V1e15M1d1L25D30.",
				"37.17G2e4A10M1A3L24D30.", "37.18G2N7A5M1A4L23D31.", "37.19G2N8A2M2A3L24D31.", "37.20G2N11A3L24D31.",
				"37.21G2N10A4L23D31.", "37.22G2N10A3L22D32.", "37.23G2N9A3L22D32.", "37.24G2N8A3L22D32.",
				"37.25G2N7A3L22D32.", "36.27G1N2c5K2b1L21D33.", "36.28G1c6K2b1L21D33.", "36.27G1Q1c7K1b22D33.",
				"36.27G1Q6O2B1P21D34.", "36.26G1Q2O3C3O1B1P21D34.", "36.25G1Q2O6C2O1P20D35.", "33.27G1Q1B1O7C2O1B1P18D36.",
				"32.27G1Q1B2O8C1O1B1P18D36.", "29.29G1Q2B2O8C1O1B1P17D37.", "28.29G1Q3B2O7C2O1B8P9D38.",
				"27.29G1Q5B2O6C2O8B2P6D40.", "27.28G2Q5B3O4C2O10B1P4D42.", "27.27G2Q8B6O11B1P2D44.",
				"28.25G2Q11B2O13B1P46.", "28.25G1Q26B48.", "41.12G24B51.", "44.8G6.16B54.", "61.11B56.", "61.10B57.",
				"61.10B57.", "62.8B58.", "128.",
			},
		},
	},
})
