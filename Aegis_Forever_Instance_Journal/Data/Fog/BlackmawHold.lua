local _, ns = ...

--[[ Blackmaw Hold's fog: the journal's own pictures (Media/Maps/BlackmawHold*.tga, Santiago Reyes's six
     maps, each under his own frame: the parchment lies only inside it and off his credit, the floor's extent,
     with no shared Frame mask). Pieces are fractions of the visible picture, as the boss spots are; each is a
     mask, Media/Fog/BlackmawHold/<floor>/<piece>.tga, made by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/BlackmawHoldFog/fog_spec.py. Every way in is clear at the start. On the hold, Impaan clears his
     grove, Bonesnout his thicket and Withermaw the lake route north to the grotto's mouths; on each map below
     one boss clears its cave. Each map clears once its bosses that hold the fog back are dead. Withermaw and
     Bonesnout (optional: one for each way through) and the Behemoth and the Unbound Spirit (no fight id or
     loot, so their kills may go unseen) do not (counts), so the hold (the whole map), the grotto and Levels
     1 and 3 clear with the whole fog: Impaan, Bloodmane and Varrox Bleakhoof dead, whichever way a group
     came. ]]
ns.AddFog("BlackmawHold", {
	-- false: never holds the fog back (his room, if he has one, still clears with his kill; a rare,
	-- a summoned boss or one the owner named holds no fog and has none); true: holds it back
	counts = { ["Blackmaw Behemoth"] = false, ["Bonesnout the Unbroken"] = false, ["Unbound Spirit"] = false, ["Withermaw"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["BlackmawHold"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5918, 0.9180, 0.9668, 0.9619 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.0342, 0.3748, 0.2715, 0.8507 },       -- the gate with the portal's swirl
				impaan = { 0.1436, 0.4187, 0.6250, 0.8258 },       -- Blackmaw Grove, the valley east of the gate
				bonesnout = { 0.4521, 0.3485, 0.9590, 0.9722 },       -- his thicket and its name, the bridge and the furbolg gate down to the depths
				withermaw = { 0.0928, 0.0249, 0.8672, 0.6164 },       -- the hold: the lake, its name and the slopes up to the grotto's mouths; the grotto: its cave
				banner = { 0.4131, 0.0498, 0.9844, 0.2255 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "impaan", boss = "Impaan the Imprisoner", pieces = { "impaan" }, back = "entrance", way = {} },
				{ id = "bonesnout", boss = "Bonesnout the Unbroken", pieces = { "bonesnout" }, back = "impaan", way = {} },
				{ id = "withermaw", boss = "Withermaw", pieces = { "withermaw" }, back = "impaan", way = {} },
			},
			where = { cols = 128, rows = 86, keys = "entrance impaan bonesnout withermaw banner entrance+impaan entrance+withermaw impaan+bonesnout impaan+withermaw bonesnout+withermaw entrance+impaan+withermaw impaan+bonesnout+withermaw",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "77.18E33.", "67.42E19.", "30.2D35.43E18.",
				"29.5D25.3E5.43E2.5E11.", "28.7D22.8E1.54E8.", "27.10D19.65E7.", "26.12D17.67E6.", "26.13D16.68E5.",
				"26.13D15.70E4.", "26.14D14.5E2.63E4.", "26.15D13.5E4.6E27.20E3.6E3.", "26.18D10.5E7.1E43.4E7.4E3.",
				"26.21D8.3E64.3E3.", "25.23D80.", "25.24D31.4D44.", "25.25D27.12D39.", "25.26D22.18D37.", "25.31D14.23D35.",
				"25.70D33.", "25.73D30.", "18.81D29.", "17.83D28.", "17.83D28.", "17.84D27.", "17.85D26.", "17.86D25.",
				"17.86D25.", "17.87D24.", "17.87D24.", "18.87D23.", "25.79D2J22.", "24.79D3J2C20.", "24.77D4J4C19.",
				"23.77D3J7C18.", "23.3G73D2J10C17.", "22.1A3G72D2J11C17.", "22.1A3G32D5I33D3J13C16.",
				"21.2A3G1D5I17D20I26D3J14C16.", "20.4A2K27I14B5I8D17J15C16.", "20.4A3F6B15I21B4I4D18J17C16.",
				"19.5A3F44B3I1D5J32C16.", "18.6A3F46B2L2J35C16.", "18.6A3F46B2L37C16.", "17.7A3F45B2H37C17.",
				"16.8A3F45B2H43C11.", "16.9A2F45B1H45C10.", "15.10A1F45B2H45C10.", "14.11A1F45B2H45C10.",
				"13.12A1F44B2H46C10.", "12.13A1F44B2H46C10.", "11.14A1F43B2H46C11.", "11.14A1F42B2H40C18.",
				"11.14A1F42B2H40C18.", "12.13A3F39B2H41C18.", "12.13A3F38B2H42C18.", "12.13A3F38B2H41C19.",
				"12.13A3F37B2H42C19.", "12.13A3F36B2H43C19.", "13.13A2F17B17.2B2H43C19.", "14.12A3F13B20.1B2H43C20.",
				"17.9A2F35.2H43C20.", "63.45C20.", "64.44C20.", "64.43C21.", "65.42C21.", "65.41C22.", "65.41C22.",
				"65.41C22.", "66.39C23.", "66.38C24.", "66.38C24.", "67.36C25.", "69.32C27.", "71.25C32.", "128.", "128.",
				"128.", "128.", "128.", "128.", "128.",
			},
		},
		["BlackmawHoldFesteringGrotto"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5625, 0.9136, 0.9727, 0.9546 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				south_mouth = { 0.5010, 0.6354, 0.7266, 0.9253 },
				east_mouth = { 0.7119, 0.5066, 0.8936, 0.7643 },
				passage_1 = { 0.6836, 0.2679, 0.8496, 0.6061 },
				east_mouth_hall = { 0.6963, 0.4583, 0.8848, 0.6940 },
				withermaw = { 0.1582, 0.0805, 0.8516, 0.8624 },       -- the hold: the lake, its name and the slopes up to the grotto's mouths; the grotto: its cave
				banner = { 0.0234, 0.7745, 0.5947, 0.9502 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "south_mouth", start = true, pieces = { "south_mouth" } },
				{ id = "east_mouth", start = true, pieces = { "east_mouth" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "withermaw", boss = "Withermaw", pieces = { "withermaw" }, back = "east_mouth", way = { "passage_1", "east_mouth_hall" } },
			},
			where = { cols = 128, rows = 86, keys = "south_mouth east_mouth passage_1 east_mouth_hall withermaw banner south_mouth+withermaw east_mouth+east_mouth_hall passage_1+east_mouth_hall passage_1+withermaw",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "93.4E31.",
				"92.6E30.", "74.1E4.4E7.10E28.", "71.31E26.", "69.34E25.", "68.36E24.", "68.36E24.", "67.37E24.",
				"67.37E24.", "66.38E24.", "66.38E24.", "64.40E24.", "62.42E24.", "61.43E24.", "56.48E24.", "55.48E25.",
				"54.46E1J2E25.", "53.46E3J26.", "53.45E3J1C26.", "36.5E11.45E3J2C26.", "35.12E5.45E2J3C26.",
				"26.4E2.64E2J5C25.", "25.71E2J5C25.", "25.70E2J7C24.", "25.69E2J8C24.", "26.68E2J8C24.", "27.66E2J9C24.",
				"27.66E2J8C25.", "28.65E10C25.", "30.62E10C26.", "31.57E4.10C26.", "31.55E7.8C27.", "32.54E7.9C26.",
				"33.15E3.35E8.1C7I1D25.", "34.14E4.12E6.17E7.7I3D24.", "35.12E8.6E10.17E6.12D22.", "37.9E27.16E6.12D21.",
				"38.7E33.12E5.13D20.", "80.11E5.4D5H3D20.", "81.10E5.2D9H1D20.", "82.10E5.1D10H20.", "83.9E6.3H3B4H20.",
				"84.8E6.9B21.", "83.10E6.8B21.", "83.10E6.8B21.", "82.11E6.8B21.", "82.11E7.2B26.", "81.12E35.",
				"80.13E35.", "79.2G11E36.", "77.2A3G10E36.", "73.6A4G8E37.", "71.9A4G6E38.", "71.10A4G5E38.",
				"71.11A4G3E39.", "72.11A4G1E40.", "17.42F13.12A3G41.", "17.43F12.13A43.", "10.1F6.43F12.13A43.",
				"8.6F3.52F4.10A45.", "7.64F9.1A47.", "6.66F56.", "5.68F55.", "4.70F54.", "4.6F1.63F54.", "4.5F3.63F53.",
				"4.5F5.4F41.6F6.4F53.", "5.4F63.3F53.", "7.1F120.", "128.", "128.", "128.", "128.", "128.",
			},
		},
		["BlackmawHoldFallenGrove"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5742, 0.9092, 0.9570, 0.9561 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.1680, 0.7204, 0.4160, 1.0000 },
				passage_3 = { 0.0000, 0.4700, 0.1963, 0.7701 },
				passage_4 = { 0.0176, 0.5739, 0.2715, 0.9780 },
				way_in_hall = { 0.1387, 0.7408, 0.3379, 0.9722 },
				unbound_spirit = { 0.0977, 0.0483, 0.7373, 0.7745 },       -- the passages, the heap of logs and the hollow stump
				banner = { 0.4023, 0.7833, 0.9736, 0.9590 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "unbound_spirit", boss = "Unbound Spirit", pieces = { "unbound_spirit" }, back = "way_in", way = { "passage_3", "passage_4", "way_in_hall" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in passage_3 passage_4 way_in_hall unbound_spirit banner way_in+way_in_hall passage_3+passage_4 passage_3+unbound_spirit passage_4+way_in_hall",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "62.2E64.", "61.6E61.", "60.10E58.",
				"59.13E56.", "46.5E6.17E54.", "45.6E6.19E52.", "45.7E4.22E50.", "45.7E4.26E46.", "46.6E4.27E45.",
				"46.38E44.", "46.39E43.", "36.3E7.40E42.", "35.5E3.44E41.", "34.54E40.", "34.54E40.", "34.54E40.",
				"34.55E39.", "35.54E39.", "35.54E39.", "36.54E38.", "36.53E39.", "37.52E39.", "37.52E39.", "38.51E39.",
				"39.50E39.", "39.50E39.", "40.49E39.", "40.48E40.", "41.46E41.", "41.46E41.", "35.29E1.21E42.",
				"29.33E4.17E45.", "26.35E6.13E48.", "26.33E9.9E51.", "25.32E71.", "25.30E73.", "16.2B7.28E75.",
				"11.7B2I31E77.", "9.9B2I31E77.", "6.12B2I31E77.", "5.13B2I31E77.", "5.13B2I31E77.", "4.14B2I31E77.",
				"5.13B2I31E77.", "5.13B1I32E77.", "5.11B2H6.27E77.", "6.9B3H8.24E78.", "7.7B3H2C9.22E78.",
				"8.6B2H4C9.20E79.", "10.3B2H6C10.17E80.", "11.2B2H7C11.15E80.", "12.2H8C12.12E82.", "13.10C16.3E86.",
				"14.9C105.", "15.9C104.", "15.9C104.", "16.8C104.", "16.9C103.", "17.8C103.", "17.9C50.17F35.",
				"17.11C1J3D6G4A23.43F20.", "17.11C1J2D7G5A22.43F20.", "10.2C5.10C2J1D6G7A15.2F5.43F3.4F13.",
				"8.19C2J5G10A12.7F2.53F10.", "7.19C2J1D3G12A11.65F8.", "7.18C2J2D3G12A10.67F7.", "7.17C2J2D3G13A9.68F7.",
				"7.16C2J3D3G14A8.69F6.", "8.16C4D3G15A7.5F2.63F5.", "10.10C7.1D2G16A6.5F4.7F22.25F3.5F5.",
				"33.13A7.4F6.3F42.5F6.5F4.", "33.13A8.3F63.3F5.", "34.12A82.", "34.12A82.", "34.11A83.", "36.8A84.", "128.",
			},
		},
		["BlackmawHoldElders"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5723, 0.9107, 0.9570, 0.9590 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.6846, 0.1303, 0.9277, 0.4466 },
				spur = { 0.6543, 0.2460, 0.8242, 0.5051 },
				log = { 0.4854, 0.5476, 0.7510, 0.8902 },
				passage_1 = { 0.5020, 0.0571, 0.7520, 0.4524 },
				spur_hall = { 0.6270, 0.1435, 0.8125, 0.4290 },
				elder_shaman_bloodmane = { 0.2910, 0.2094, 0.6328, 0.9971 },       -- his green room and the passages to the pond's room
				banner = { 0.0234, 0.0483, 0.5938, 0.2240 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "spur", start = true, pieces = { "spur" } },
				{ id = "log", start = true, pieces = { "log" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "elder_shaman_bloodmane", boss = "Elder Shaman Bloodmane", pieces = { "elder_shaman_bloodmane" }, back = "spur", way = { "passage_1", "spur_hall" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in spur log passage_1 spur_hall elder_shaman_bloodmane banner way_in+spur_hall spur+spur_hall log+elder_shaman_bloodmane passage_1+spur_hall passage_1+elder_shaman_bloodmane",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "18.34G76.", "17.43G68.", "17.43G68.", "8.5G4.43G1.6G61.",
				"7.63G58.", "6.65G9.6D42.", "5.67G7.9D40.", "5.68G4.12D39.", "4.70G3.13D38.", "4.5G3.62G2.15D37.",
				"4.5G4.6G31.16G4.5G16D37.", "5.4G7.1G43.4G7.4G16D37.", "5.4G63.3G7D2.7D37.", "74.7D4.4D2K1E10.3A23.",
				"74.7D4.2D3K2E7.8A21.", "74.7D4.4K4E4.11A20.", "74.7D4.2K7E1.1H13A19.", "73.8D5.8E3H12A19.",
				"53.1F4.5F10.8D5.8E4H11A19.", "51.19F1L10D6.8E4H2A2.7A18.", "50.20F1L10D7.8E3H1A4.6A18.",
				"49.21F2L9D8.7E2H6.7A17.", "49.21F2L8D10.7E7.8A16.", "49.22F1L8D10.1E5I9.7A16.", "49.22F1L8D10.6I10.6A16.",
				"49.18F4.8D11.4I3B10.4A17.", "49.18F5.7D12.1I6B30.", "49.17F6.5D14.7B30.", "49.17F7.3D15.8B29.",
				"49.17F26.6B30.", "49.17F27.5B30.", "49.17F62.", "50.15F63.", "50.14F64.", "49.14F65.", "49.10F69.",
				"49.7F72.", "49.6F73.", "48.7F73.", "48.6F74.", "47.6F75.", "45.8F75.", "44.9F75.", "43.9F76.", "43.9F76.",
				"43.9F76.", "42.9F77.", "42.9F77.", "42.10F76.", "42.11F32.3C40.", "42.11F30.6C39.", "43.11F27.8C39.",
				"43.12F23.11C39.", "44.12F3.1F16.13C39.", "45.18F12.13C40.", "46.17F11.12C42.", "47.17F9.11C44.",
				"49.16F7.10C46.", "52.13F6.10C47.", "53.13F4.10C48.", "53.14F2.10C49.", "53.16F2J7C50.", "53.15F5J3C52.",
				"53.16F5J1C53.", "52.19F3J54.", "52.22F54.", "52.21F55.", "52.21F55.", "52.20F56.", "52.20F56.",
				"53.22F53.", "54.22F52.", "55.21F52.", "57.19F52.", "59.17F52.", "70.5F53.", "128.", "128.", "128.", "128.",
				"128.",
			},
		},
		["BlackmawHoldBurrow"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5723, 0.9107, 0.9570, 0.9590 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.2461, 0.6237, 0.4639, 0.8960 },
				top_end = { 0.2949, 0.0717, 0.4854, 0.3807 },
				passage_1 = { 0.2930, 0.1786, 0.4688, 0.5725 },
				blackmaw_behemoth = { 0.1191, 0.1889, 0.7422, 0.9707 },       -- the red den, the S passage and the floor's name
				banner = { 0.2617, 0.0307, 0.8330, 0.2064 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "top_end", start = true, pieces = { "top_end" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "blackmaw_behemoth", boss = "Blackmaw Behemoth", pieces = { "blackmaw_behemoth" }, back = "top_end", way = { "passage_1" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in top_end passage_1 blackmaw_behemoth banner way_in+blackmaw_behemoth top_end+passage_1 top_end+banner passage_1+blackmaw_behemoth",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "48.42E38.", "47.43E38.", "47.43E38.", "38.7E2.53E28.", "37.64E27.",
				"36.66E26.", "36.67E25.", "35.69E24.", "35.70E23.", "34.5E4.7E3H52E23.", "35.4E6.3E6B36.5E6.4E23.",
				"35.4E9.7B47.4E22.", "37.2E8.8B73.", "47.8B73.", "46.9B73.", "45.9B74.", "45.9B74.", "44.3G6B28.3D44.",
				"44.4G5B10.24D41.", "43.2C5G2B8.28D40.", "43.3C5G7.31D39.", "43.4C4G6.33D38.", "43.8C5.34D38.",
				"43.8C5.34D38.", "43.8C5.34D38.", "42.8C5.35D38.", "42.9C4.35D38.", "43.8C4.34D39.", "43.9C3.34D39.",
				"44.8C2.34D40.", "44.10C32D42.", "44.10C29D45.", "45.8C2I25D48.", "45.8C2I22D51.", "46.7C1I16D58.",
				"47.6C1I11D63.", "48.5C1I9D65.", "49.4C1I9D65.", "50.3C1I11D63.", "51.1C2I12D62.", "21.47D60.", "20.49D59.",
				"20.50D58.", "20.52D56.", "20.53D55.", "20.53D55.", "21.53D54.", "51.24D53.", "51.25D52.", "51.25D52.",
				"52.24D52.", "52.24D52.", "52.23D53.", "52.23D53.", "52.23D53.", "52.22D54.", "50.1F23D54.",
				"46.3A3F21D55.", "41.8A3F20D56.", "39.10A3F20D56.", "39.11A3F19D56.", "38.12A3F19D56.", "38.12A3F19D56.",
				"39.12A1F20D56.", "39.9A5.19D56.", "40.5A9.18D56.", "54.18D56.", "55.17D56.", "55.17D56.", "56.16D56.",
				"57.14D57.", "58.13D57.", "60.10D58.", "62.7D59.", "64.1D63.", "128.", "128.", "128.", "128.", "128.",
				"128.", "128.",
			},
		},
		["BlackmawHoldForbiddenMagic"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.5723, 0.9107, 0.9570, 0.9590 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				way_in = { 0.3877, 0.2987, 0.5840, 0.5930 },
				way_in_hall = { 0.2939, 0.2035, 0.6230, 0.6310 },
				varrox_bleakhoof = { 0.4814, 0.3807, 0.8320, 0.8272 },       -- the rune circle and the pool's cave
				banner = { 0.4102, 0.0410, 0.9814, 0.2167 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "way_in", start = true, pieces = { "way_in" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "varrox_bleakhoof", boss = "Varrox Bleakhoof", pieces = { "varrox_bleakhoof" }, back = "way_in", way = { "way_in_hall" } },
			},
			where = { cols = 128, rows = 86, keys = "way_in way_in_hall varrox_bleakhoof banner way_in+way_in_hall way_in_hall+varrox_bleakhoof",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "128.", "128.", "66.43D19.", "66.43D19.", "60.1D5.43D19.", "57.7D2.53D9.",
				"56.64D8.", "55.66D7.", "54.68D6.", "54.69D5.", "54.5D1.64D4.", "53.5D4.7D18.30D1.6D4.",
				"54.4D6.3D42.5D6.5D3.", "54.4D63.4D3.", "128.", "128.", "128.", "128.", "128.", "128.", "44.8B76.",
				"43.12B73.", "43.24B61.", "43.25B60.", "43.26B59.", "43.27B58.", "43.28B57.", "43.28B57.", "44.27B57.",
				"44.16B4E7B57.", "43.15B8E5B57.", "43.14B10E4B57.", "43.14B4E3A4E3B57.", "43.13B4E5A3E3B57.",
				"43.13B3E6A3E6B54.", "43.13B3E6A3E5B2F14C39.", "44.12B3E6A3E4B2F16C38.", "44.13B3E5A3E3B2F18C37.",
				"45.12B5E1A4E4B2F18C37.", "46.11B10E3B2F20C36.", "47.12B7E4B2F20C36.", "48.13B2E6B2F22C35.",
				"49.20B2F23C34.", "51.17B2F25C33.", "53.14B2F26C33.", "55.4B6.2B2F27C32.", "67.30C31.", "69.29C30.",
				"69.29C30.", "69.29C30.", "70.28C30.", "70.27C31.", "70.27C31.", "70.28C30.", "70.30C28.", "71.30C27.",
				"71.30C27.", "72.29C27.", "73.29C26.", "74.27C27.", "75.25C28.", "76.22C30.", "79.9C6.3C31.", "128.",
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.",
				"128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
	},
})
