local _, ns = ...

--[[ Dire Maul: Gordok Commons's fog: the journal's own picture (Media/Maps/Classic/DireMaulNorth.blp).
     Pieces are fractions of the visible picture, as the boss spots are; each is a mask,
     Media/Fog/DireMaulNorth/<floor>/<piece>.tga, traced from the picture and split into rooms by
     Dev/maps/FogBuilder/fogbuild.py from Dev/maps/DireMaulNorthFog/fog_spec.py. ]]
ns.AddFog("DireMaulNorth", {
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["DireMaulNorth"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.6200, 0.7586, 0.8810, 1.0000 },       -- the gate in the south wall (the swirl), the south walk in front of it and the east walk's foot
				guard_mol_dar = { 0.5720, 0.6327, 0.8150, 0.9310 },       -- the first courtyard's green, inside its frame
				halls_passage = { 0.1520, 0.5247, 0.4570, 0.8996 },       -- the lower Halls of Destruction, the red hall's stair, the passage to the courtyards' west door
				west_court_walks = { 0.3460, 0.5502, 0.5940, 1.0000 },       -- the walks round Guard Fengus's garden (his green square a pocket)
				east_court_walks = { 0.4960, 0.5487, 0.8650, 1.0000 },       -- the walks round the first courtyard and between the courts
				guard_slip_kik = { 0.0530, 0.4288, 0.3480, 0.6987 },       -- the upper Halls of Destruction and the HALLS OF DESTRUCTION name
				captain_kromcrush = { 0.1990, 0.3478, 0.4350, 0.6777 },       -- the red hall, from the step across the throne room's neck to its stair
				king_gordok = { 0.1740, 0.0435, 0.5640, 0.4963 },       -- Gordok's Seat, the throne room (Cho'Rush's spot too), and the GORDOK'S SEAT name
				stomper_kreeg = { 0.5320, 0.5832, 0.7030, 0.8321 },       -- the first courtyard's north-west corner (his red patch), a pocket
				guard_fengus = { 0.4120, 0.6447, 0.5800, 0.9205 },       -- his green square in the garden court, a pocket
				banner = { 0.3910, 0.0225, 0.9660, 0.1664 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "guard_mol_dar", boss = "Guard Mol'dar", pieces = { "guard_mol_dar" }, back = "entrance", way = {} },
				{ id = "guard_slip_kik", boss = "Guard Slip'kik", pieces = { "guard_slip_kik" }, back = "entrance", way = { "halls_passage", "west_court_walks", "east_court_walks" } },
				{ id = "captain_kromcrush", boss = "Captain Kromcrush", pieces = { "captain_kromcrush" }, back = "entrance", way = { "halls_passage", "west_court_walks", "east_court_walks" } },
				{ id = "king_gordok", boss = "King Gordok", pieces = { "king_gordok" }, back = "captain_kromcrush", way = {} },
				{ id = "stomper_kreeg", boss = "Stomper Kreeg", pieces = { "stomper_kreeg" }, back = "entrance", way = { "east_court_walks" } },
				{ id = "guard_fengus", boss = "Guard Fengus", pieces = { "guard_fengus" }, back = "entrance", way = { "west_court_walks", "east_court_walks" } },
				{ id = "cho_rush", boss = "Cho'Rush the Observer", pieces = { "king_gordok" }, back = "captain_kromcrush", way = {} },
			},
			where = { cols = 250, rows = 167, keys = "entrance guard_mol_dar halls_passage west_court_walks east_court_walks guard_slip_kik captain_kromcrush king_gordok stomper_kreeg guard_fengus banner entrance+guard_mol_dar entrance+east_court_walks guard_mol_dar+east_court_walks guard_mol_dar+stomper_kreeg halls_passage+west_court_walks halls_passage+guard_slip_kik halls_passage+captain_kromcrush west_court_walks+east_court_walks west_court_walks+guard_fengus east_court_walks+stomper_kreeg guard_slip_kik+captain_kromcrush captain_kromcrush+king_gordok entrance+guard_mol_dar+east_court_walks guard_mol_dar+east_court_walks+stomper_kreeg halls_passage+guard_slip_kik+captain_kromcrush",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"250.", "250.", "250.", "250.", "250.", "250.", "122.17K61.17K33.", "120.27K4.20K8.11K3.27K30.",
				"118.103K29.", "116.107K27.", "113.112K25.", "108.123K19.", "105.128K17.", "104.132K14.", "102.135K13.",
				"101.137K12.", "101.137K12.", "76.5H19.139K11.", "72.13H15.139K11.", "69.20H11.139K11.",
				"68.23H9.7K3.31K19.2K17.8K7.2K1.32K3.8K10.", "66.27H7.5K6.14K76.6K8.14K4.7K10.",
				"65.30H5.6K6.3K108.4K6.6K11.", "64.32H5.5K127.6K11.", "63.34H4.5K127.5K12.", "62.36H4.3K128.4K13.",
				"61.38H151.", "60.40H150.", "59.41H150.", "58.43H149.", "58.44H3.23H122.", "57.45H2.25H121.", "56.74H120.",
				"55.75H120.", "55.75H120.", "54.76H120.", "54.75H121.", "54.74H122.", "53.53H144.", "53.53H144.",
				"53.53H144.", "53.53H144.", "53.53H144.", "53.53H144.", "53.53H144.", "53.53H144.", "53.53H144.",
				"53.53H144.", "53.53H144.", "54.51H145.", "54.51H145.", "54.51H145.", "55.49H146.", "55.49H146.",
				"55.48H147.", "56.47H147.", "56.46H148.", "57.45H148.", "57.44H149.", "58.43H149.", "59.41H150.",
				"59.40H151.", "59.40H151.", "60.39H151.", "60.38H152.", "61.37H152.", "61.37H152.", "60.38H152.",
				"60.39H151.", "60.39W151.", "60.39W151.", "60.39W151.", "60.39G151.", "60.38G152.", "61.37G152.",
				"61.37G152.", "64.32G154.", "65.29G156.", "66.28G156.", "66.28G156.", "65.29G156.", "56.1F8.29G156.",
				"53.12F1.28G156.", "51.16F3G1V23G156.", "50.19F4V21G156.", "49.20F4V20G157.", "48.22F4V17G159.",
				"48.23F4V14G161.", "48.24F3V13G162.", "48.25F3V12G162.", "48.25F3V12G162.", "48.25F3V12G162.",
				"48.25F3V12G162.", "48.25F3V12G162.", "48.25F3V12G162.", "29.15F4.25F3V12G162.", "28.17F3.25F3V12G162.",
				"27.19F2.25F3V12G162.", "26.21F1.25F3V12G162.", "25.36F12Q3Z9R3G162.", "25.35F13Q3Z11R1G162.",
				"24.25F15Q9C14R103.3E57.", "24.24F15Q12C11R1C17.12D3.14D3.2S7E3.12E5.16E5.16E48.",
				"25.23F14Q25C15.33D3S64E48.", "25.23F2C2Q34C15.34D3S65E47.", "48.2C1Q35C14.35D3S67E45.",
				"48.37C14.36D3S68E44.", "48.37C13.37D3S68E44.", "48.37C13.37D3S6E20U42E44.", "48.37C12.38D3S6E21U41E44.",
				"48.37C12.38D3S6E21U41E44.", "48.37C12.38D3S6E3U15I3U41E44.", "48.37C12.38D3S6E3U15I3U41E44.",
				"48.37C12.38D3S6E3U15I3U41E44.", "48.37C12.38D3S6E3U15I3U41E44.", "48.36C13.38D3S6E3U15I3U41E44.",
				"48.35C15.37D3S6E3U15I2U1Y26N15E44.", "49.30C19.37D3S6E3U15I1U2Y28N13E44.",
				"50.28C20.16D19T2D3S6E3U8I8O2Y28N13E44.", "51.27C20.16D20T1D3S6E3U8I1O35B2N13E44.",
				"52.27C18.17D2T16J2T1D3S6E3U8I1O35B2N13E44.", "57.23C15.2C1D1P15D2T16J2T1D3S6E3U8I1O35B2N13E44.",
				"58.31C2.7C4P12D2T16J2T1D3S6E4U7I1O35B2N13E44.", "59.39C5P11D2T16J2T1D3S7E3U7I1O35B2N12E45.",
				"59.40C4P11D2T16J2T1D3S7E4U6I1O35B2N12E45.", "59.41C4P10D2T16J2T1D3S7E10U1O35B2N12E45.",
				"59.41C4P10D2T16J2T1D3S8E9U1Y35B2N12E45.", "60.40C4P10D2T16J2T1D3S9E7U2Y35B2N13E44.",
				"61.39C4P10D2T16J2T1D3S16E2N35B2N13E44.", "61.39C4P10D2T16J2T1D3S16E2N35B2N13E44.",
				"62.38C4P10D2T16J2T1D3S16E2N35B2N13E44.", "63.37C4P10D2T16J2T1D3S16E2N35B2N13E44.",
				"64.36C4P10D2T16J2T1D3S16E2N35B2N13E44.", "64.36C4P10D2T16J2T1D3S16E2N35B2N13E44.",
				"65.34C4P11D2T16J2T1D3S16E2N35B2N13E44.", "65.33C5P11D2T16J2T1D3S16E2N35B2N13E44.",
				"67.30C5P12D2T16J2T1D3S16E2N35B2N12E45.", "69.28C4P13D2T16J2T1D3S16E2N35B2N12E45.",
				"71.26C3P14D2T16J2T1D3S16E2N35B2N13E44.", "78.11C2.6C1P16D2T16J2T1D3S16E2N35B2N1M9E1M2E44.",
				"97.17D2T16J2T1D3S16E2N35B2N13M44.", "98.16D20T1D3S16E2N35B1N1X13M44.",
				"98.16D20T1D3S16E2N14B1L20B2X13M44.", "98.37D3S16E14N5X17L3X13M44.", "98.37D3S17E13N5X18L1X14M44.",
				"98.37D3S30E5M33A44.", "98.37D3S30E5M33A44.", "98.37D3S30E5M32A45.", "97.38D3S30E5M32A45.",
				"98.37D3S30E5M31A46.", "98.37D3S30E5M31A46.", "98.37D3S30E5M31A46.", "98.37D3S30E5M31A46.",
				"98.37D3S30E5M31A46.", "98.37D3S30E5M31A46.", "98.37D3S30E5M31A46.", "100.35D3S30E5M31A46.",
				"101.34D3S30E5M31A46.", "102.33D2S31E5M30A47.", "104.11D4.10D4.2D2S2E1.4E1.23E5M20A2.6A49.",
				"146.22E5M15A62.", "147.21E5M15A62.", "148.20E5M14A63.", "149.19E4M14A64.", "152.2E4.13E14A65.", "250.",
				"250.",
			},
		},
	},
})
