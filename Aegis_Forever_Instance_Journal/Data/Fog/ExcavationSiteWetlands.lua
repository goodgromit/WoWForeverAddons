local _, ns = ...

--[[ Excavation Site: Wetlands's fog: the journal's own picture (Media/Maps/ExcavationSiteWetlands.tga,
     Santiago Reyes's map, untouched: the fog lies over it in game). Pieces are fractions of the visible
     picture, as the boss spots are; each is a mask, Media/Fog/ExcavationSiteWetlands/<floor>/<piece>.tga,
     traced from the picture and split into rooms by Dev/maps/FogBuilder/fogbuild.py from
     Dev/maps/ExcavationSiteWetlandsFog/fog_spec.py. Every boss's way runs back to the swirl; Saltspine
     and Shadetooth are pockets the other ways pass, and so is the Highland Horror (a quest target,
     holding nothing back). ]]
ns.AddFog("ExcavationSiteWetlands", {
	-- false: never holds the fog back (his room still clears with his kill); true: holds it back
	counts = { ["Highland Horror"] = false },
	floors = {
		-- A string key is the floor's picture (the last part of floor.art, or of floor.tiles), so the floors'
		-- order in ClassicMaps.lua can change without moving the fog to another floor. A number key is a client
		-- map ID, for a floor drawn from the client's own tiles (no art, no tiles).
		["ExcavationSiteWetlands"] = {
			extent = true,              -- <dir>\extent: where fog lies at all: inside the picture's own frame,
			                            -- off the rects kept clear (soft)
			frame = false,              -- not the classic map sheet: no shared Frame mask (its frame is in the extent)
			keepClear = { { 0.0469, 0.0322, 0.3994, 0.0791 }, { 0.5957, 0.9063, 0.9805, 0.9561 } }, -- { x0, y0, x1, y1 } fractions, never fogged: credits, signature (baked into extent)
			pieces = {                  -- name = { x0, y0, x1, y1 }, the box its mask covers, or true: the whole picture
				entrance = { 0.7783, 0.0849, 1.0000, 0.4422 },
				marsh = { 0.3779, 0.1040, 0.8721, 0.7643 },       -- the Lost Marsh, its falls and pond: on every way
				approach = { 0.6084, 0.0937, 1.0000, 0.8492 },       -- the north road from the swirl, the rocky hills, the east slopes: on every way
				saltspine = { 0.4160, 0.2723, 0.5820, 0.5198 },       -- his pocket in the marsh (the marsh round it is on every way)
				thicket = { 0.1396, 0.1698, 0.4961, 0.6779 },       -- Stalker's Thicket: Shadetooth's way, and the Guardian's
				shadetooth = { 0.3203, 0.3631, 0.4824, 0.6047 },       -- his pocket at the Thicket's east end, on the road (the Guardian's way passes it)
				dig_site = { 0.0000, 0.1830, 0.2686, 0.7189 },       -- the Lost Dig Site: the Highland Horror's way, and the Guardian's
				relic_guardian = { 0.0322, 0.4671, 0.5742, 0.9327 },       -- the Site of the Guardian and the road into it
				highland_horror = { 0.0000, 0.2167, 0.1865, 0.5139 },       -- his pocket: the whole nook he stands in (a quest target: he holds nothing back)
				banner = { 0.1973, 0.0278, 0.9395, 0.1933 },       -- the map's name (its title banner): never fogged
			},
			nodes = {
				{ id = "entrance", start = true, pieces = { "entrance" } },
				{ id = "banner", start = true, pieces = { "banner" } },
				{ id = "saltspine", boss = "Saltspine", pieces = { "saltspine" }, back = "entrance", way = { "marsh", "approach" } },
				{ id = "shadetooth", boss = "Shadetooth", pieces = { "shadetooth" }, back = "entrance", way = { "thicket", "marsh", "approach" } },
				{ id = "relic_guardian", boss = "Relic Guardian", pieces = { "relic_guardian" }, back = "entrance", way = { "dig_site", "thicket", "marsh", "approach" } },
				{ id = "highland_horror", boss = "Highland Horror", pieces = { "highland_horror" }, back = "entrance", way = { "dig_site", "thicket", "marsh", "approach" } },
			},
			where = { cols = 128, rows = 86, keys = "entrance marsh approach saltspine thicket shadetooth dig_site relic_guardian highland_horror banner entrance+approach marsh+approach marsh+saltspine marsh+thicket marsh+relic_guardian marsh+banner approach+banner thicket+shadetooth thicket+dig_site thicket+relic_guardian dig_site+relic_guardian dig_site+highland_horror marsh+approach+banner marsh+thicket+shadetooth marsh+thicket+relic_guardian thicket+shadetooth+relic_guardian thicket+dig_site+relic_guardian",   -- Covers: each cell's pieces (UI/DungeonFog.lua; Dev/maps/FogBuilder/where.py)
				"128.", "128.", "128.", "41.65J22.", "40.66J22.", "35.76J17.", "29.87J12.", "28.89J11.", "27.91J10.",
				"27.92J9.", "26.93J9.", "26.48J11P1W16Q1J6Q10J9.", "26.43J15P3W24Q8J9.", "27.12J30.15B3L21C4Q7J9.",
				"27.6J37.15B1L22C3K1Q7J9.", "70.13B3L21C4K2A2.2J11.", "70.13B2L22C3K5A13.", "66.17B2L22C3K7A11.",
				"64.19B2L22C2K11A8.", "59.25B1L22C2K12A7.", "31.3E24.26B2L20C3K12A7.", "8.7G15.7E19.28B3L19C3K13A6.",
				"6.11G8.13E17.30B2L19C3K13A6.", "5.13G6.15E15.32B1L19C3K13A6.", "4.5G5V5G4.17E13.33B2L18C3K11A3K5.",
				"4.4G8V4G3.17E13.3N30B2L18C4K8A5K5.", "4.2G3V6I2V4G2.16E13.2E2N30B2L18C4K7A5K2C4.",
				"5.1I2V8I2V5G16E12.4E2N29B1L20C4K4A5K4C4.", "5.11I2V6G1S15E8.7E2N28B2L21C4K1A6K5C4.",
				"5.12I1V6G2S16E3.11E1N4B6M17B2L23C8K8C3.", "5.12I1V6G3S29E2N2B2M3D3M16B2L24C5K10C3.",
				"5.12I2V6G3S28E2N1B2M6D2M15B1L27C2K11C3.", "5.11I2V9G2S27E2N1B1M7D2M14B2L40C3.",
				"5.9I3V10G2S27E1N2B1M8D1M15B2L39C3.", "5.2V7I2V11G1S27E2N2B1M7D2M15B3L37C4.",
				"4.2G2V5I2V11G2S27E2N2B1M7D2M16B2L38C3.", "3.3G2V5I2V11G2S27E2N2B2M6D2M17B2L37C3.",
				"3.4G7V12G2S20E6R1E2N3B2M3D3M19B2L9C5L22C3.", "2.7G4V13G1S20E3R3F2R2N4B6M21B4L1C12L20C3.",
				"2.23G2S20E1R6F1R1X1N32B8L6B3L19C3.", "2.23G2S19E2R7F1X1N47B2L19C3.", "2.23G2S19E2R7F1X1N47B2L20C2.",
				"2.23G2S19E2R7F1X1N48B1L19C3.", "2.23G2S20E1R6F2R1N48B1L19C3.", "3.22G2S20E2R4F3R2N46B2L15C7.",
				"3.22G2S21E7R1E2N46B2L11C11.", "3.22G2S20E3T3Z3E2N7B3O8B9.19B2L11C11.",
				"3.15G6U1G2S19E9T1E2N5B5O7B11.18B1L12C11.", "4.13G3U2H3U2S18E3T5H2T1E2N3B4O1H2O6B12.17B2L12C11.",
				"5.11G2U6H1U2a4E4T8E3T8H1T2Y1O2B3O4H1O3B15.16B2L12C12.", "6.10G2U7H1a12T3E4T11H6O5H1O1B18.15B2L11C13.",
				"6.10G2U18H7T24H20.15B2L11C13.", "7.8G2U21H3T25H22.14B2L11C13.", "7.7G3U49H23.14B1L11C13.",
				"8.3G5U49H27.11B2L10C13.", "9.5U51H29.9B2L9C14.", "9.2U53H35.4B2L9C14.", "10.54H37.2B2L11C12.",
				"12.52H38.1B2L12C11.", "14.49H40.2L12C11.", "15.48H41.14C10.", "17.45H42.15C9.", "18.43H44.14C9.",
				"19.40H46.14C9.", "19.40H47.13C9.", "18.40H49.9C12.", "16.42H51.6C13.", "15.43H53.3C14.", "15.43H70.",
				"15.42H71.", "15.41H72.", "15.32H81.", "17.17H94.", "19.3H1.9H96.", "24.6H98.", "128.", "128.", "128.",
				"128.", "128.", "128.", "128.", "128.", "128.", "128.", "128.",
			},
		},
	},
})
