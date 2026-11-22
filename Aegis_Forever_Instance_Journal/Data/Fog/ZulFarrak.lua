local _, ns = ...

--[[ Zul'Farrak's fog: its one floor, the journal's own picture (Media/Maps/Classic/ZulFarrak.blp), drawn at
     its own 1000 x 667 (artRight = 1000 / 1024, artBottom = 667 / 1024). Pieces are fractions of the visible
     picture, as the boss spots are; each is a mask, Media/Fog/ZulFarrak/<floor>/<piece>.tga, traced from the
     picture and split into rooms by Dev/maps/FogBuilder/fogbuild.py from Dev/maps/ZulFarrakFog/fog_spec.py. ]]
ns.AddFog("ZulFarrak", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Gahz'rilla"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["ZulFarrak"] = {
			-- no extent: the fog lies over the whole picture; the map's name is the banner piece (a start node)
			-- extent = true,           -- <dir>\extent: where fog lies at all (soft; never-fogged rects baked in)
			keepClear = {},             -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.4730, 0.6627, 0.6760, 1.0000 },       -- the yard round the swirl and the gate
				theka_yard = { 0.5020, 0.1664, 0.6480, 0.4498 },       -- the sand between Theka's building and Antu'sul's basin
				theka_path = { 0.5040, 0.2309, 0.6450, 0.4483 },       -- the winding path up to Theka's building
				court = { 0.4200, 0.2774, 0.7280, 0.6222 },       -- the courtyard and its arm east (Zerillis's spot in it: a rare, he holds no fog)
				street = { 0.4980, 0.4573, 0.6730, 0.8516 },       -- the walled passage north and the long street up to the courtyard
				antu_sul = { 0.5380, 0.1214, 0.7240, 0.4573 },       -- his pink basin, and the dunes under it that the ways ring
				sand = { 0.3090, 0.0390, 0.4720, 0.3253 },       -- the sand round Dustwraith's spot, to the graveyard (a rare, he holds no fog)
				shadowpriest_sezz_ziz = { 0.1530, 0.0120, 0.4080, 0.3178 },       -- the pyramid and its yard: Sezz'ziz's and the Executioner's room
				theka = { 0.4260, 0.1439, 0.6340, 0.4468 },       -- his building, and the arm of the dunes south of it that the ways ring
				witch_doctor_zum_rah = { 0.3550, 0.0540, 0.5350, 0.3193 },       -- the graveyard, and its part of the walled way to Theka's building
				pool = { 0.1730, 0.1679, 0.4390, 0.5682 },       -- the sacred pool and the walled way north from it (Gahz'rilla's spot in it: summoned, he holds no fog; Velratha's a pocket)
				valley = { 0.3040, 0.3718, 0.5490, 0.6582 },       -- the valley west of the courtyard (Sandarr's spot in it: a rare, he holds no fog)
				hydromancer_velratha = { 0.2840, 0.2924, 0.4270, 0.5067 },
				diagonal = { 0.2940, 0.1679, 0.4660, 0.3973 },       -- the walled way to the yellow building
				chief_ukorz_sandscalp = { 0.3070, 0.1574, 0.5790, 0.5457 },       -- the yellow building, and the dunes round it that the ways ring
				banner = { 0.5130, 0.0405, 0.9200, 0.1889 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "antu_sul", boss = "Antu'sul", pieces = { "antu_sul" }, back = "entrance", way = { "theka_yard", "theka_path", "court", "street" } },
				{ id = "shadowpriest_sezz_ziz", boss = "Shadowpriest Sezz'ziz", pieces = { "shadowpriest_sezz_ziz" }, back = "witch_doctor_zum_rah", way = { "sand" } },
				{ id = "theka", boss = "Theka the Martyr", pieces = { "theka" }, back = "entrance", way = { "theka_path", "court", "street" } },
				{ id = "witch_doctor_zum_rah", boss = "Witch Doctor Zum'rah", pieces = { "witch_doctor_zum_rah" }, back = "theka", way = {} },
				{ id = "sandfury_executioner", boss = "Sandfury Executioner", pieces = { "shadowpriest_sezz_ziz" }, back = "witch_doctor_zum_rah", way = { "sand" } },
				{ id = "hydromancer_velratha", boss = "Hydromancer Velratha", pieces = { "hydromancer_velratha" }, back = "entrance", way = { "pool", "valley", "court", "street" } },
				{ id = "chief_ukorz_sandscalp", boss = "Chief Ukorz Sandscalp", pieces = { "chief_ukorz_sandscalp" }, back = "sandfury_executioner", way = { "diagonal" } },
			},
			where = { cols = 125, rows = 84, keys = "entrance theka_yard theka_path court street antu_sul sand shadowpriest_sezz_ziz theka witch_doctor_zum_rah pool valley hydromancer_velratha diagonal chief_ukorz_sandscalp banner entrance+street theka_yard+theka_path theka_yard+antu_sul theka_yard+theka theka_path+court court+street court+antu_sul court+theka court+valley court+chief_ukorz_sandscalp sand+shadowpriest_sezz_ziz sand+witch_doctor_zum_rah sand+diagonal shadowpriest_sezz_ziz+pool theka+witch_doctor_zum_rah theka+chief_ukorz_sandscalp witch_doctor_zum_rah+chief_ukorz_sandscalp pool+valley pool+hydromancer_velratha pool+diagonal pool+chief_ukorz_sandscalp valley+chief_ukorz_sandscalp hydromancer_velratha+chief_ukorz_sandscalp diagonal+chief_ukorz_sandscalp theka_yard+theka_path+court theka_yard+theka_path+antu_sul theka_yard+theka_path+theka theka_yard+court+antu_sul theka_path+court+theka court+theka+chief_ukorz_sandscalp court+valley+chief_ukorz_sandscalp sand+shadowpriest_sezz_ziz+diagonal sand+diagonal+chief_ukorz_sandscalp shadowpriest_sezz_ziz+pool+diagonal theka+witch_doctor_zum_rah+chief_ukorz_sandscalp pool+valley+chief_ukorz_sandscalp pool+hydromancer_velratha+chief_ukorz_sandscalp pool+diagonal+chief_ukorz_sandscalp theka_yard+theka_path+court+antu_sul sand+witch_doctor_zum_rah+diagonal+chief_ukorz_sandscalp",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"125.", "125.", "125.", "125.", "77.3P19.2P24.", "75.29P21.", "35.4H35.32P19.", "34.6H28.42P15.",
				"34.8H3.2G21.44P13.", "25.19H1a3G20.45P12.", "24.20H2a3G4.5J8.48P11.", "24.20H2a3G3.7J6.49P11.",
				"24.20H2a4G1.9J5.12P10.13P5.3P3.3P11.", "24.20H2a4G1b10J4.8P38.3P11.", "24.20H2a4G1b10J5.5P40.1P13.",
				"24.20H2a4G1b11J18.2F43.", "24.20H2a4G1b11J17.4F42.", "24.20H2a4G2b9J1e1I15.6F41.",
				"24.20H2a4G3b7J1e3I1.6I4.9F41.", "25.19H2a3c2G2b1J5g1y1e12I1B1S10F40.",
				"31.2H9d2x2v5c1w1%5g1O1y12I2T2S9F40.", "33.1d8K2j5N2c1w1n6O2f11I2T2S10F39.", "34.9K2j5N2n8O3f9I2T2S9F40.",
				"34.9K2j4N2n10O2f8I2T1B2S9F40.", "34.9K2j3N2n12O3f5I2T2B2S9F40.", "34.9K2j2N2n15O2f2I1T2q2R1p2S9F40.",
				"29.14K1j1#3n17O2f1I2q3R1p10F41.", "28.16K2#1n18O2f1I1T2q1C1R1p10F41.", "27.17K3k18O2f2I1T2q1R1p10F41.",
				"27.17K2k17O2Z2t1X2I2q1C2p10F40.", "27.16K1i2!17O1Z2D4X2s1U1$1p1F2W7F40.",
				"27.15K3i2!15O2Z4D2X1s2U1o1$1r4W5F40.", "27.14K2i3M2m14O2Z11D2W1D2W4F41.", "27.14K2i3M2!12O4Z17D1.3D40.",
				"29.12K2i3M2!11O4Z23D39.", "29.13K4i1!2k10O2Z25D39.", "29.13K4i1K2k10O2Z25D39.",
				"30.17K1h2z2l5O1l2u1Z24D40.", "31.15K3h1L8l1u3Y22D41.", "32.13K3h4L5l3L3Y20D42.", "33.11K3h7L2l6L1Y19D43.",
				"34.9K3h16L2.12D49.", "37.3K3.2h17L2.11D50.", "44.18L3.7D2V51.", "44.17L4.5D4V51.", "46.16L4.2D5V4E48.",
				"49.13L5.1D2V8E47.", "51.11L5.11E47.", "51.10L7.11E46.", "52.7L9.11E46.", "67.12E46.", "67.12E46.",
				"67.11E47.", "68.10E47.", "68.10E47.", "70.8E47.", "70.8E47.", "70.7E48.", "70.7E48.", "70.7E48.",
				"69.8E48.", "69.8E48.", "69.4Q4E48.", "68.1A6Q2E48.", "67.2A7Q49.", "67.5A3Q1A49.", "67.10A48.",
				"67.10A48.", "66.11A48.", "66.11A48.", "66.12A47.", "66.12A47.", "66.12A47.", "66.12A47.", "66.11A48.",
				"66.11A48.", "66.11A48.", "66.11A48.", "66.11A48.", "66.11A48.", "66.11A48.", "67.9A49.", "67.8A50.",
				"125.",
			},
		},
	},
})
