-- Stratholme: the journal's own data for this dungeon. Edit it by hand.
-- One dungeon with two doors, the Main Gate and the Service Gate (doors), one page since 0.39.22 (the owner's call
-- of 2026-11-12; before, a page for each gate). Its bosses are listed by side: the Main Gate's side, the Scarlet
-- Crusade's, then the Service Gate's, the Scourge's, each in the order the gates' pages had them, each boss with
-- the side he stands on (side: the index of its door), then the trash. Bosses, levels, models, loot and quests as the
-- source of the journal's first data listed them (2026-10-10), facts only. Its first map, what the map shows by
-- itself, is the whole of Stratholme (Media/Maps/Dungeons/stratholme-full, Dev/maps/StratholmeWhole, signed:
-- LICENSE-MAPS.md): both classic floors on one sheet, unturned, each at a scale of its own, its boss skulls painted
-- out. Each boss's spot on it is carried from his classic floor by that floor's fit (pins.py), and he keeps his spot
-- on the classic floor too. The two floors after it (Media/Maps/Classic), their names and boss spots are the classic
-- dungeon maps. The bosses' abilities are added by Data/Generated/Abilities.lua (Dev/build_data.py).

local _, ns = ...

ns.AddInstance({
	key = "Stratholme",
	instanceID = 329,
	kind = "dungeon",
	name = "Stratholme",
	levelMin = 58,
	levelMax = 60,
	location = "Eastern Plaguelands",
	description = "Plagued Stratholme is split in two: the Scarlet Crusade holds the Main Gate's side under Grand Crusader Dathrohan, the dreadlord Balnazzar in disguise, and Baron Rivendare's Scourge holds the ziggurats and slaughterhouse past the Service Gate.",
	-- Its whole description stays in the overview's facts where Spoken's story shows: which side each gate leads to
	-- (UI/EncounterPage.lua's FillInstanceOverview).
	overviewNote = true,
	-- Forever's client has no file name for this loading screen, only its id (131871), so the id comes first.
	buttonArt = { 131871, "Interface\\Glues\\LoadingScreens\\LoadScreenStratholme" },
	buttonImage = { "Interface\\EncounterJournal\\UI-EJ-DUNGEONBUTTON-Stratholme" },
	loreImage = { "Interface\\EncounterJournal\\UI-EJ-LOREBG-Stratholme" },
	buttonArtCoords = { 0, 1, 0.13, 0.87 },
	iconArtCoords = { 0.2, 0.8, 0.1, 0.9 },
	loreArtCoords = { 0, 1, 0.1, 0.9 },
	--[[
		Its two doors outside, on Eastern Plaguelands (1423), by their place in the world: the Main Gate first, the
		door the journal's own waypoint goes to (the owner's call of 2026-11-12: the Service Gate needs its key), then
		the Service Gate (2026-10-30): the quest data's second Stratholme door, Eastern Plaguelands 41.45, 17.74, taken
		into the world by Forever's own UiMapAssignment for the zone; Forever's client places the service tunnel (WMO
		3455, groups ext_shortcut and tunnelA01A08-11, a small portcullis and a lever) at 3190.1, -4039.2, 7 yards away.
		Each door keeps the areas of its side, by which the two pages were told apart (areas, the client's names).
		inside: where it lets you in on the whole map (map.entrance is the Main Gate's), each on the painted swirl
		there, from the owner's circles of 2026-11-12.
	]]
	doors = {
		{
			name = "Main Gate",
			mapID = 1423,
			world = { 0, 3316.7, -3383.3 },
			areas = {
				["King's Square"] = true,
				["Market Row"] = true,
				["Crusaders' Square"] = true,
				["The Scarlet Bastion"] = true,
				["The Hall of Lights"] = true,
				["The Hoard"] = true,
				["Festival Lane"] = true,
			},
			inside = { x = 0.621, y = 0.952, floor = 1 },
		},
		{
			name = "Service Gate",
			mapID = 1423,
			world = { 0, 3183.1, -4039.5 },
			areas = {
				["The Gauntlet"] = true,
				["Elders' Square"] = true,
				["Slaughter Square"] = true,
				["The Slaughter House"] = true,
			},
			inside = { x = 0.829, y = 0.766, floor = 1 },
		},
	},
	map = {
		entrance = {
			x = 0.621,
			y = 0.952,
			floor = 1,
		},
		floors = {
			{
				art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\Dungeons\\stratholme-full",
				artRight = 1002 / 1024,
				artBottom = 668 / 1024,
				whole = true,
			},
			{
				art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\Classic\\Stratholme",
				artRight = 1000 / 1024,
				artBottom = 667 / 1024,
				uiMapID = 317,
			},
			{
				art = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\Classic\\Stratholme1",
				artRight = 1000 / 1024,
				artBottom = 667 / 1024,
				uiMapID = 318,
			},
		},
	},
	floorNames = { "Stratholme", "Crusader's Square", "The Gauntlet" },
	bosses = {
		{
			name = "Skul",
			displayID = 2606,
			level = 58,
			rare = true,
			order = 1,
			side = 1,
			loot = {
				{
					itemID = 13395,
					name = "Skul's Fingerbone Claws",
					slot = "Hands, Leather",
					quality = 3,
				},
				{
					itemID = 13394,
					name = "Skul's Cold Embrace",
					slot = "Chest, Plate",
					quality = 3,
				},
				{
					itemID = 13396,
					name = "Skul's Ghastly Touch",
					slot = "Ranged, Wand",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.705,
					y = 0.721,
					floor = 1,
				},
				{
					x = 0.801,
					y = 0.456,
					floor = 2,
				},
			},
		},
		{
			name = "Hearthsinger Forresten",
			displayID = 10482,
			level = 57,
			rare = true,
			order = 2,
			side = 1,
			loot = {
				{
					itemID = 16682,
					name = "Magister's Boots",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 13378,
					name = "Songbird Blouse",
					slot = "Chest, Leather",
					quality = 3,
				},
				{
					itemID = 13384,
					name = "Rainbow Girdle",
					slot = "Waist, Plate",
					quality = 3,
				},
				{
					itemID = 13383,
					name = "Woollies of the Prancing Minstrel",
					slot = "Legs, Mail",
					quality = 3,
				},
				{
					itemID = 13379,
					name = "Piccolo of the Flaming Fire",
					slot = "Trinket",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.587,
					y = 0.642,
					floor = 1,
				},
				{
					x = 0.602,
					y = 0.322,
					floor = 2,
				},
			},
		},
		{
			name = "Postmaster Malown",
			displayID = 10669,
			level = 60,
			order = 3,
			side = 1,
			loot = {
				{
					itemID = 13390,
					name = "The Postmaster's Band",
					slot = "Head, Cloth",
					quality = 3,
				},
				{
					itemID = 13388,
					name = "The Postmaster's Tunic",
					slot = "Chest, Cloth",
					quality = 3,
				},
				{
					itemID = 13389,
					name = "The Postmaster's Trousers",
					slot = "Legs, Cloth",
					quality = 3,
				},
				{
					itemID = 13391,
					name = "The Postmaster's Treads",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 13392,
					name = "The Postmaster's Seal",
					slot = "Finger",
					quality = 3,
				},
				{
					itemID = 13393,
					name = "Malown's Slam",
					slot = "Two-Hand, Mace",
					quality = 3,
				},
			},
		},
		{
			name = "Malor the Zealous",
			displayID = 10458,
			level = 60,
			order = 4,
			side = 1,
			loot = {
				{
					itemID = 276397,
					name = "Hand of the Zealous",
					slot = "Two-Hand, Mace",
					quality = 3,
				},
				{
					itemID = 276398,
					name = "Scarlet Malice",
					slot = "One-Hand, Mace",
					quality = 3,
				},
				{
					itemID = 276399,
					name = "Plate of the Scarlet Bastion",
					slot = "Chest, Plate",
					quality = 3,
				},
				{
					itemID = 12845,
					name = "Medallion of Faith",
					slot = "Quest",
					quality = 1,
					notSeen = true,
				},
			},
			mapPins = {
				{
					x = 0.406,
					y = 0.694,
					floor = 1,
				},
				{
					x = 0.297,
					y = 0.411,
					floor = 2,
				},
			},
		},
		{
			name = "Cannon Master Willey",
			displayID = 10674,
			level = 60,
			order = 5,
			side = 1,
			loot = {
				{
					itemID = 16708,
					name = "Shadowcraft Spaulders",
					slot = "Shoulder, Leather",
					quality = 3,
				},
				{
					itemID = 22407,
					name = "Helm of the New Moon",
					slot = "Head, Leather",
					quality = 3,
				},
				{
					itemID = 22403,
					name = "Nacreous Shell Necklace",
					slot = "Neck",
					quality = 3,
				},
				{
					itemID = 22405,
					name = "Mantle of the Scarlet Crusade",
					slot = "Shoulder, Cloth",
					quality = 3,
				},
				{
					itemID = 18721,
					name = "Barrage Girdle",
					slot = "Waist, Mail",
					quality = 3,
				},
				{
					itemID = 13381,
					name = "Master Cannoneer Boots",
					slot = "Feet, Plate",
					quality = 3,
				},
				{
					itemID = 13382,
					name = "Cannonball Runner",
					slot = "Trinket",
					quality = 3,
				},
				{
					itemID = 13380,
					name = "Willey's Portable Howitzer",
					slot = "Ranged, Gun",
					quality = 3,
				},
				{
					itemID = 13377,
					name = "Miniature Cannon Balls",
					slot = "Ammo, Bullet",
					quality = 3,
				},
				{
					itemID = 22404,
					name = "Willey's Back Scratcher",
					slot = "Main Hand, Fist Weapon",
					quality = 3,
				},
				{
					itemID = 22406,
					name = "Redemption",
					slot = "Two-Hand, Staff",
					quality = 3,
				},
				{
					itemID = 12839,
					name = "Plans: Heartseeker",
					slot = "Blacksmithing",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.253,
					y = 0.751,
					floor = 1,
				},
				{
					x = 0.04,
					y = 0.506,
					floor = 2,
				},
			},
		},
		{
			name = "Stratholme Courier",
			displayID = 10547,
			level = 57,
			order = 6,
			side = 1,
			loot = {
				{
					itemID = 13303,
					name = "Crusaders' Square Postbox Key",
					slot = "Key",
					quality = 1,
				},
				{
					itemID = 13305,
					name = "Elders' Square Postbox Key",
					slot = "Key",
					quality = 1,
				},
				{
					itemID = 13304,
					name = "Festival Lane Postbox Key",
					slot = "Key",
					quality = 1,
				},
				{
					itemID = 13307,
					name = "Ezra Grimm's Postbox Key",
					slot = "Key",
					quality = 1,
				},
				{
					itemID = 13306,
					name = "King's Square Postbox Key",
					slot = "Key",
					quality = 1,
				},
				{
					itemID = 13302,
					name = "Market Row Postbox Key",
					slot = "Key",
					quality = 1,
				},
			},
			mapPins = {
				{
					x = 0.568,
					y = 0.839,
					floor = 1,
				},
				{
					x = 0.57,
					y = 0.656,
					floor = 2,
				},
			},
		},
		{
			name = "The Unforgiven",
			displayID = 10771,
			level = 57,
			order = 7,
			side = 1,
			loot = {
				{
					itemID = 16717,
					name = "Wildheart Gloves",
					slot = "Hands, Leather",
					quality = 3,
				},
				{
					itemID = 13404,
					name = "Mask of the Unforgiven",
					slot = "Head, Leather",
					quality = 3,
				},
				{
					itemID = 13405,
					name = "Wailing Nightbane Pauldrons",
					slot = "Shoulder, Plate",
					quality = 3,
				},
				{
					itemID = 13409,
					name = "Tearfall Bracers",
					slot = "Wrist, Cloth",
					quality = 3,
				},
				{
					itemID = 13408,
					name = "Soul Breaker",
					slot = "Main Hand, Axe",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.667,
					y = 0.571,
					floor = 1,
				},
				{
					x = 0.737,
					y = 0.203,
					floor = 2,
				},
			},
		},
		{
			name = "Timmy the Cruel",
			displayID = 571,
			level = 58,
			order = 8,
			side = 1,
			loot = {
				{
					itemID = 16724,
					name = "Lightforge Gauntlets",
					slot = "Hands, Plate",
					quality = 3,
				},
				{
					itemID = 13400,
					name = "Vambraces of the Sadist",
					slot = "Wrist, Plate",
					quality = 3,
				},
				{
					itemID = 13403,
					name = "Grimgore Noose",
					slot = "Waist, Cloth",
					quality = 3,
				},
				{
					itemID = 13402,
					name = "Timmy's Galoshes",
					slot = "Feet, Mail",
					quality = 3,
				},
				{
					itemID = 13401,
					name = "The Cruel Hand of Timmy",
					slot = "One-Hand, Mace",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.463,
					y = 0.629,
					floor = 1,
				},
				{
					x = 0.393,
					y = 0.3,
					floor = 2,
				},
			},
		},
		{
			name = "Crimson Hammersmith",
			displayID = 10637,
			level = 60,
			order = 9,
			side = 1,
			loot = {
				{
					itemID = 276403,
					name = "Scarlet Bonebreaker",
					slot = "Two-Hand, Mace",
					quality = 3,
				},
				{
					itemID = 276404,
					name = "Masterwork Crimson Hammer",
					slot = "Main Hand, Mace",
					quality = 3,
				},
				{
					itemID = 276419,
					name = "Lightcrest Hammer",
					slot = "One-Hand, Mace",
					quality = 3,
				},
				{
					itemID = 18781,
					name = "Bottom Half of Advanced Armorsmithing: Volume II",
					slot = "Quest",
					quality = 3,
				},
			},
		},
		{
			name = "Archivist Galford",
			displayID = 10544,
			level = 60,
			order = 10,
			side = 1,
			loot = {
				{
					itemID = 16692,
					name = "Devout Gloves",
					slot = "Hands, Cloth",
					quality = 3,
				},
				{
					itemID = 13386,
					name = "Archivist Cape",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 13387,
					name = "Foresight Girdle",
					slot = "Waist, Mail",
					quality = 3,
				},
				{
					itemID = 18716,
					name = "Ash Covered Boots",
					slot = "Feet, Leather",
					quality = 3,
				},
				{
					itemID = 13385,
					name = "Tome of Knowledge",
					slot = "Held In Off-hand",
					quality = 3,
				},
				{
					itemID = 12811,
					name = "Righteous Orb",
					slot = "Other",
					quality = 2,
				},
				{
					itemID = 22897,
					name = "Tome of Conjure Food VII",
					slot = "Book",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.392,
					y = 0.897,
					floor = 1,
				},
				{
					x = 0.273,
					y = 0.753,
					floor = 2,
				},
			},
		},
		{
			name = "Balnazzar",
			displayID = 10545,
			level = 62,
			order = 11,
			side = 1,
			loot = {
				{
					itemID = 13353,
					name = "Book of the Dead",
					slot = "Held In Off-hand",
					quality = 4,
				},
				{
					itemID = 14512,
					name = "Pattern: Truefaith Vestments",
					slot = "Tailoring",
					quality = 4,
				},
				{
					itemID = 16725,
					name = "Lightforge Boots",
					slot = "Feet, Plate",
					quality = 3,
				},
				{
					itemID = 13359,
					name = "Crown of Tyranny",
					slot = "Head, Mail",
					quality = 3,
				},
				{
					itemID = 18718,
					name = "Grand Crusader's Helm",
					slot = "Head, Plate",
					quality = 3,
				},
				{
					itemID = 12103,
					name = "Star of Mystaria",
					slot = "Neck",
					quality = 3,
				},
				{
					itemID = 18720,
					name = "Shroud of the Nathrezim",
					slot = "Shoulder, Cloth",
					quality = 3,
				},
				{
					itemID = 13358,
					name = "Wyrmtongue Shoulders",
					slot = "Shoulder, Leather",
					quality = 3,
				},
				{
					itemID = 13369,
					name = "Fire Striders",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 13360,
					name = "Gift of the Elven Magi",
					slot = "Main Hand, Dagger",
					quality = 3,
				},
				{
					itemID = 18717,
					name = "Hammer of the Grand Crusader",
					slot = "Two-Hand, Mace",
					quality = 3,
				},
				{
					itemID = 22334,
					name = "Band of Mending",
					slot = "Finger",
					quality = 3,
				},
				{
					itemID = 13348,
					name = "Demonshear",
					slot = "Two-Hand, Sword",
					quality = 3,
				},
				{
					itemID = 13520,
					name = "Recipe: Flask of Distilled Wisdom",
					slot = "Alchemy",
					quality = 2,
				},
				{
					itemID = 13250,
					name = "Head of Balnazzar",
					slot = "Quest",
					quality = 1,
				},
			},
			mapPins = {
				{
					x = 0.350,
					y = 0.936,
					floor = 1,
				},
				{
					x = 0.203,
					y = 0.819,
					floor = 2,
				},
			},
		},
		{
			name = "Magistrate Barthilas",
			displayID = 10433,
			level = 58,
			order = 12,
			side = 2,
			loot = {
				{
					itemID = 18727,
					name = "Crimson Felt Hat",
					slot = "Head, Cloth",
					quality = 3,
				},
				{
					itemID = 13376,
					name = "Royal Tribunal Cloak",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 18726,
					name = "Magistrate's Cuffs",
					slot = "Wrist, Leather",
					quality = 3,
				},
				{
					itemID = 18722,
					name = "Death Grips",
					slot = "Hands, Plate",
					quality = 3,
				},
				{
					itemID = 23198,
					name = "Idol of Brutality",
					slot = "Relic, Idol",
					quality = 3,
				},
				{
					itemID = 18725,
					name = "Peacemaker",
					slot = "Two-Hand, Polearm",
					quality = 3,
				},
				{
					itemID = 12382,
					name = "Key to the City",
					slot = "Key",
					quality = 2,
				},
			},
			mapPins = {
				{
					x = 0.754,
					y = 0.127,
					floor = 1,
				},
				{
					x = 0.569,
					y = 0.156,
					floor = 3,
				},
			},
		},
		{
			name = "Black Guard Swordsmith",
			displayID = 775,
			level = 62,
			order = 13,
			side = 2,
			loot = {
				{
					itemID = 276434,
					name = "Black Guard Skullcap",
					slot = "Head, Mail",
					quality = 3,
				},
				{
					itemID = 276455,
					name = "Swordsmith Mitts",
					slot = "Hands, Leather",
					quality = 3,
				},
				{
					itemID = 276456,
					name = "Plague Defiled Buckler",
					slot = "Off Hand, Shield",
					quality = 3,
				},
				{
					itemID = 18783,
					name = "Bottom Half of Advanced Armorsmithing: Volume III",
					slot = "Quest",
					quality = 3,
				},
			},
		},
		{
			name = "Nerub'enkan",
			displayID = 9793,
			level = 60,
			order = 14,
			side = 2,
			loot = {
				{
					itemID = 16675,
					name = "Beaststalker's Boots",
					slot = "Feet, Mail",
					quality = 3,
				},
				{
					itemID = 18740,
					name = "Thuzadin Sash",
					slot = "Waist, Cloth",
					quality = 3,
				},
				{
					itemID = 18739,
					name = "Chitinous Plate Legguards",
					slot = "Legs, Plate",
					quality = 3,
				},
				{
					itemID = 18738,
					name = "Carapace Spine Crossbow",
					slot = "Ranged, Crossbow",
					quality = 3,
				},
				{
					itemID = 13529,
					name = "Husk of Nerub'enkan",
					slot = "Off Hand, Shield",
					quality = 3,
				},
				{
					itemID = 13533,
					name = "Acid-etched Pauldrons",
					slot = "Shoulder, Plate",
					quality = 3,
				},
				{
					itemID = 13532,
					name = "Darkspinner Claws",
					slot = "Hands, Mail",
					quality = 3,
				},
				{
					itemID = 13531,
					name = "Crypt Stalker Leggings",
					slot = "Legs, Leather",
					quality = 3,
				},
				{
					itemID = 13530,
					name = "Fangdrip Runners",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 13508,
					name = "Eye of Arachnida",
					slot = "Consumable",
					quality = 2,
				},
			},
			mapPins = {
				{
					x = 0.756,
					y = 0.385,
					floor = 1,
				},
				{
					x = 0.572,
					y = 0.46,
					floor = 3,
				},
			},
		},
		{
			name = "Ramstein the Gorger",
			displayID = 12818,
			level = 61,
			order = 15,
			side = 2,
			loot = {
				{
					itemID = 16737,
					name = "Gauntlets of Valor",
					slot = "Hands, Plate",
					quality = 3,
				},
				{
					itemID = 18723,
					name = "Animated Chain Necklace",
					slot = "Neck",
					quality = 3,
				},
				{
					itemID = 13374,
					name = "Soulstealer Mantle",
					slot = "Shoulder, Cloth",
					quality = 3,
				},
				{
					itemID = 13373,
					name = "Band of Flesh",
					slot = "Finger",
					quality = 3,
				},
				{
					itemID = 13515,
					name = "Ramstein's Lightning Bolts",
					slot = "Trinket",
					quality = 3,
				},
				{
					itemID = 13375,
					name = "Crest of Retribution",
					slot = "Off Hand, Shield",
					quality = 3,
				},
				{
					itemID = 13372,
					name = "Slavedriver's Cane",
					slot = "Two-Hand, Staff",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.657,
					y = 0.162,
					floor = 1,
				},
				{
					x = 0.456,
					y = 0.198,
					floor = 3,
				},
			},
		},
		{
			name = "Stonespine",
			displayID = 7856,
			level = 60,
			rare = true,
			order = 16,
			side = 2,
			loot = {
				{
					itemID = 13397,
					name = "Stoneskin Gargoyle Cape",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 13954,
					name = "Verdant Footpads",
					slot = "Feet, Leather",
					quality = 3,
				},
				{
					itemID = 13399,
					name = "Gargoyle Shredder Talons",
					slot = "Off Hand, Fist Weapon",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.836,
					y = 0.429,
					floor = 1,
				},
				{
					x = 0.666,
					y = 0.512,
					floor = 3,
				},
			},
		},
		{
			name = "Baroness Anastari",
			displayID = 10698,
			level = 59,
			order = 17,
			side = 2,
			loot = {
				{
					itemID = 16704,
					name = "Dreadmist Sandals",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 18728,
					name = "Anastari Heirloom",
					slot = "Neck",
					quality = 3,
				},
				{
					itemID = 18730,
					name = "Shadowy Laced Handwraps",
					slot = "Hands, Cloth",
					quality = 3,
				},
				{
					itemID = 18729,
					name = "Screeching Bow",
					slot = "Ranged, Bow",
					quality = 3,
				},
				{
					itemID = 13534,
					name = "Banshee Finger",
					slot = "Ranged, Wand",
					quality = 3,
				},
				{
					itemID = 13538,
					name = "Windshrieker Pauldrons",
					slot = "Shoulder, Mail",
					quality = 3,
				},
				{
					itemID = 13535,
					name = "Coldtouch Phantom Wraps",
					slot = "Chest, Cloth",
					quality = 3,
				},
				{
					itemID = 13537,
					name = "Chillhide Bracers",
					slot = "Wrist, Leather",
					quality = 3,
				},
				{
					itemID = 13539,
					name = "Banshee's Touch",
					slot = "Hands, Plate",
					quality = 3,
				},
				{
					itemID = 13514,
					name = "Wail of the Banshee",
					slot = "Consumable",
					quality = 2,
				},
				{
					itemID = 273124,
					name = "Blueprint: Loom",
					slot = "Recipe, Tailoring",
					quality = 2,
				},
				{
					itemID = 273131,
					name = "Bottled Screams",
					slot = "Reagent",
					quality = 2,
				},
			},
			mapPins = {
				{
					x = 0.903,
					y = 0.387,
					floor = 1,
				},
				{
					x = 0.745,
					y = 0.463,
					floor = 3,
				},
			},
		},
		{
			name = "Maleki the Pallid",
			displayID = 10546,
			level = 61,
			order = 18,
			side = 2,
			loot = {
				{
					itemID = 16691,
					name = "Devout Sandals",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 18734,
					name = "Pale Moon Cloak",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 18735,
					name = "Maleki's Footwraps",
					slot = "Feet, Cloth",
					quality = 3,
				},
				{
					itemID = 13524,
					name = "Skull of Burning Shadows",
					slot = "Held In Off-hand",
					quality = 3,
				},
				{
					itemID = 18737,
					name = "Bone Slicing Hatchet",
					slot = "One-Hand, Axe",
					quality = 3,
				},
				{
					itemID = 13528,
					name = "Twilight Void Bracers",
					slot = "Wrist, Mail",
					quality = 3,
				},
				{
					itemID = 13525,
					name = "Darkbind Fingers",
					slot = "Hands, Cloth",
					quality = 3,
				},
				{
					itemID = 13526,
					name = "Flamescarred Girdle",
					slot = "Waist, Leather",
					quality = 3,
				},
				{
					itemID = 13527,
					name = "Lavawalker Greaves",
					slot = "Feet, Plate",
					quality = 3,
				},
				{
					itemID = 13509,
					name = "Clutch of Foresight",
					slot = "Other",
					quality = 2,
				},
				{
					itemID = 12833,
					name = "Plans: Hammer of the Titans",
					slot = "Blacksmithing",
					quality = 3,
				},
			},
			mapPins = {
				{
					x = 0.846,
					y = 0.172,
					floor = 1,
				},
				{
					x = 0.677,
					y = 0.21,
					floor = 3,
				},
			},
		},
		{
			name = "Baron Rivendare",
			displayID = 10729,
			level = 62,
			order = 19,
			side = 2,
			loot = {
				{
					itemID = 13335,
					name = "Deathcharger's Reins",
					slot = "Mount",
					quality = 3,
					notSeen = true,
				},
				{
					itemID = 13505,
					name = "Runeblade of Baron Rivendare",
					slot = "Two-Hand, Sword",
					quality = 4,
				},
				{
					itemID = 22411,
					name = "Helm of the Executioner",
					slot = "Head, Plate",
					quality = 3,
				},
				{
					itemID = 22412,
					name = "Thuzadin Mantle",
					slot = "Shoulder, Cloth",
					quality = 3,
				},
				{
					itemID = 13340,
					name = "Cape of the Black Baron",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 13346,
					name = "Robes of the Exalted",
					slot = "Chest, Cloth",
					quality = 3,
				},
				{
					itemID = 22409,
					name = "Tunic of the Crescent Moon",
					slot = "Chest, Leather",
					quality = 3,
				},
				{
					itemID = 13344,
					name = "Dracorian Gauntlets",
					slot = "Hands, Mail",
					quality = 3,
				},
				{
					itemID = 22410,
					name = "Gauntlets of Deftness",
					slot = "Hands, Mail",
					quality = 3,
				},
				{
					itemID = 13345,
					name = "Seal of Rivendare",
					slot = "Finger",
					quality = 3,
				},
				{
					itemID = 22408,
					name = "Ritssyn's Wand of Bad Mojo",
					slot = "Ranged, Wand",
					quality = 3,
				},
				{
					itemID = 13349,
					name = "Scepter of the Unholy",
					slot = "Main Hand, Mace",
					quality = 3,
				},
				{
					itemID = 13368,
					name = "Bonescraper",
					slot = "One-Hand, Dagger",
					quality = 3,
				},
				{
					itemID = 13361,
					name = "Skullforge Reaver",
					slot = "One-Hand, Sword",
					quality = 3,
				},
				{
					itemID = 16694,
					name = "Devout Skirt",
					slot = "Legs, Cloth",
					quality = 3,
				},
				{
					itemID = 16687,
					name = "Magister's Leggings",
					slot = "Legs, Cloth",
					quality = 3,
				},
				{
					itemID = 16699,
					name = "Dreadmist Leggings",
					slot = "Legs, Cloth",
					quality = 3,
				},
				{
					itemID = 16709,
					name = "Shadowcraft Pants",
					slot = "Legs, Leather",
					quality = 3,
				},
				{
					itemID = 16719,
					name = "Wildheart Kilt",
					slot = "Legs, Leather",
					quality = 3,
				},
				{
					itemID = 16678,
					name = "Beaststalker's Pants",
					slot = "Legs, Mail",
					quality = 3,
				},
				{
					itemID = 16668,
					name = "Kilt of Elements",
					slot = "Legs, Mail",
					quality = 3,
				},
				{
					itemID = 16728,
					name = "Lightforge Legplates",
					slot = "Legs, Plate",
					quality = 3,
				},
				{
					itemID = 16732,
					name = "Legplates of Valor",
					slot = "Legs, Plate",
					quality = 3,
				},
				{
					itemID = 13251,
					name = "Head of Baron Rivendare",
					slot = "Quest",
					quality = 1,
				},
			},
			mapPins = {
				{
					x = 0.602,
					y = 0.164,
					floor = 1,
				},
				{
					x = 0.391,
					y = 0.2,
					floor = 3,
				},
			},
		},
		{
			name = "Trash Drops",
			trash = true,
			loot = {
				{
					itemID = 16697,
					name = "Devout Bracers",
					slot = "Wrist, Cloth",
					quality = 3,
				},
				{
					itemID = 16685,
					name = "Magister's Belt",
					slot = "Waist, Cloth",
					quality = 3,
				},
				{
					itemID = 16702,
					name = "Dreadmist Belt",
					slot = "Waist, Cloth",
					quality = 3,
				},
				{
					itemID = 16710,
					name = "Shadowcraft Bracers",
					slot = "Wrist, Leather",
					quality = 3,
				},
				{
					itemID = 16714,
					name = "Wildheart Bracers",
					slot = "Wrist, Leather",
					quality = 3,
				},
				{
					itemID = 16681,
					name = "Beaststalker's Bindings",
					slot = "Wrist, Mail",
					quality = 3,
				},
				{
					itemID = 16671,
					name = "Bindings of Elements",
					slot = "Wrist, Mail",
					quality = 3,
				},
				{
					itemID = 16723,
					name = "Lightforge Belt",
					slot = "Waist, Plate",
					quality = 3,
				},
				{
					itemID = 16736,
					name = "Belt of Valor",
					slot = "Waist, Plate",
					quality = 3,
				},
				{
					itemID = 12811,
					name = "Righteous Orb",
					slot = "Other",
					quality = 2,
				},
				{
					itemID = 18742,
					name = "Stratholme Militia Shoulderguard",
					slot = "Shoulder, Mail",
					quality = 3,
				},
				{
					itemID = 18743,
					name = "Gracious Cape",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 17061,
					name = "Juno's Shadow",
					slot = "Back, Cloth",
					quality = 3,
				},
				{
					itemID = 18741,
					name = "Morlune's Bracer",
					slot = "Wrist, Plate",
					quality = 3,
				},
				{
					itemID = 18744,
					name = "Plaguebat Fur Gloves",
					slot = "Hands, Leather",
					quality = 3,
				},
				{
					itemID = 18745,
					name = "Sacred Cloth Leggings",
					slot = "Legs, Cloth",
					quality = 3,
				},
				{
					itemID = 18736,
					name = "Plaguehound Leggings",
					slot = "Legs, Leather",
					quality = 3,
				},
			},
		},
		{
			name = "Recipes",
			recipes = true,
			loot = {
				{
					itemID = 12839,
					name = "Plans: Heartseeker",
					slot = "Recipe, Blacksmithing",
					quality = 3,
					droppedBy = "Cannon Master Willey",
				},
				{
					itemID = 13520,
					name = "Recipe: Flask of Distilled Wisdom",
					slot = "Recipe, Alchemy",
					quality = 2,
					droppedBy = "Balnazzar",
				},
				{
					itemID = 14512,
					name = "Pattern: Truefaith Vestments",
					slot = "Recipe, Tailoring",
					quality = 4,
					droppedBy = "Balnazzar",
				},
				{
					itemID = 273124,
					name = "Blueprint: Loom",
					slot = "Recipe, Tailoring",
					quality = 2,
					droppedBy = "Baroness Anastari",
				},
				{
					itemID = 12833,
					name = "Plans: Hammer of the Titans",
					slot = "Recipe, Blacksmithing",
					quality = 3,
					droppedBy = "Maleki the Pallid",
				},
				{
					itemID = 252937,
					name = "Pattern: Red Dragonscale Leggings",
					slot = "Recipe, Leatherworking",
					quality = 4,
					droppedBy = "Crimson Battle Mage",
				},
				{
					itemID = 254140,
					name = "Pattern: Bottomless Reagent Bag",
					slot = "Recipe, Tailoring",
					quality = 2,
					droppedBy = "Venom Belcher",
				},
				{
					itemID = 16248,
					name = "Formula: Enchant Weapon - Unholy Weapon",
					slot = "Recipe, Enchanting",
					quality = 2,
					droppedBy = "Thuzadin Shadowcaster",
				},
				{
					itemID = 16249,
					name = "Formula: Enchant 2H Weapon - Major Intellect",
					slot = "Recipe, Enchanting",
					quality = 2,
					droppedBy = "Crimson Sorcerer",
				},
				{
					itemID = 249524,
					name = "Formula: Enchant Bracer - Superior Agility",
					slot = "Recipe, Enchanting",
					quality = 2,
					droppedBy = "Thuzadin Acolyte",
				},
				{
					itemID = 14495,
					name = "Pattern: Ghostweave Pants",
					slot = "Tailoring",
					quality = 2,
				},
				{
					itemID = 15768,
					name = "Pattern: Wicked Leather Belt",
					slot = "Leatherworking",
					quality = 2,
				},
				{
					itemID = 15777,
					name = "Pattern: Runic Leather Shoulders",
					slot = "Leatherworking",
					quality = 2,
				},
				{
					itemID = 16052,
					name = "Schematic: Voice Amplification Modulator",
					slot = "Engineering",
					quality = 2,
				},
				{
					itemID = 18658,
					name = "Schematic: Ultra-Flash Shadow Reflector",
					slot = "Engineering",
					quality = 2,
				},
			},
		},
	},
	quests = {
		{
			questID = 5848,
			name = "Of Love and Family",
			level = 60,
			requiredLevel = 52,
			faction = "Both",
			startMap = {
				mapID = 1422,
				x = 0.658,
				y = 0.754,
			},
			endMap = {
				mapID = 1423,
				x = 0.052,
				y = 0.356,
			},
			objective = "Travel to Stratholme, in the northern part of the Plaguelands. It is in the Scarlet Bastion that you will find the painting 'Of Love and Family,' hidden behind another painting depicting the twin moons of our world.",
			pickup = "Artist Renfray, Western Plaguelands",
			turnin = "Tirion Fordring, Eastern Plaguelands",
			rewards = {
				xp = 6600,
			},
			prerequisites = {
				{
					questID = 5846,
					name = "Of Love and Family",
				},
			},
		},
		{
			questID = 5125,
			name = "Aurius' Reckoning",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			rewards = {
				xp = 9950,
				items = {
					{
						itemID = 17044,
						name = "Will of the Martyr",
					},
					{
						itemID = 17045,
						name = "Blood of the Martyr",
					},
				},
				choice = true,
			},
			prerequisites = {
				{
					questID = 5122,
					name = "The Medallion of Faith",
				},
			},
		},
		{
			questID = 5243,
			name = "Houses of the Holy",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.719,
				y = 0.483,
			},
			endMap = {
				mapID = 1423,
				x = 0.719,
				y = 0.483,
			},
			objective = "Travel to Stratholme, in the north. Search the supply crates that litter the city and recover 5 Stratholme Holy Water. Return to Leonid Barthalomew the Revered when you have collected enough of the blessed fluid.",
			pickup = "Leonid Barthalomew the Revered, Eastern Plaguelands",
			turnin = "Leonid Barthalomew the Revered, Eastern Plaguelands",
			rewards = {
				xp = 6600,
				money = 18000,
				reputation = {
					{
						faction = "Argent Dawn",
						amount = 100,
					},
				},
				items = {
					{
						itemID = 13216,
						name = "Crown of the Penitent",
					},
					{
						itemID = 13217,
						name = "Band of the Penitent",
					},
				},
				choice = true,
				-- Given with the choice (foreverchanges.pro's quest page, "You will also receive").
				also = {
					{
						itemID = 3928,
						name = "Superior Healing Potion",
						count = 5,
					},
					{
						itemID = 6149,
						name = "Greater Mana Potion",
						count = 5,
					},
				},
			},
		},
		{
			questID = 5212,
			name = "The Flesh Does Not Lie",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.717,
				y = 0.499,
			},
			endMap = {
				mapID = 1423,
				x = 0.717,
				y = 0.499,
			},
			objective = "Recover 10 Plagued Flesh Samples from Stratholme and return them to Betina Bigglezink. You suspect that any creature in Stratholme would have said flesh sample.",
			pickup = "Betina Bigglezink, Eastern Plaguelands",
			turnin = "Betina Bigglezink, Eastern Plaguelands",
			rewards = {
				xp = 6600,
				money = 18000,
				reputation = {
					{
						faction = "Argent Dawn",
						amount = 100,
					},
				},
			},
		},
		{
			questID = 5213,
			name = "The Active Agent",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.717,
				y = 0.499,
			},
			endMap = {
				mapID = 1423,
				x = 0.717,
				y = 0.499,
			},
			objective = "Travel to Stratholme and search the ziggurats. Find and return new Scourge Data to Betina Bigglezink.",
			pickup = "Betina Bigglezink, Eastern Plaguelands",
			turnin = "Betina Bigglezink, Eastern Plaguelands",
			rewards = {
				xp = 6600,
				reputation = {
					{
						faction = "Argent Dawn",
						amount = 100,
					},
				},
				items = {
					{
						itemID = 13209,
						name = "Seal of the Dawn",
					},
					{
						itemID = 19812,
						name = "Rune of the Dawn",
					},
				},
				choice = true,
			},
			prerequisites = {
				{
					questID = 5212,
					name = "The Flesh Does Not Lie",
				},
			},
		},
		{
			questID = 5251,
			name = "The Archivist",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.716,
				y = 0.501,
			},
			endMap = {
				mapID = 1423,
				x = 0.716,
				y = 0.501,
			},
			objective = "Travel to Stratholme and find Archivist Galford of the Scarlet Crusade. Destroy him and burn down the Scarlet Archive.",
			pickup = "Duke Nicholas Zverenhoff, Eastern Plaguelands",
			turnin = "Duke Nicholas Zverenhoff, Eastern Plaguelands",
			rewards = {
				xp = 8300,
				money = 18000,
				reputation = {
					{
						faction = "Argent Dawn",
						amount = 150,
					},
				},
			},
		},
		{
			questID = 5214,
			name = "The Great Ezra Grimm",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.709,
				y = 0.484,
			},
			endMap = {
				mapID = 1423,
				x = 0.709,
				y = 0.484,
			},
			objective = "Find Ezra Grimm's smoke shop in Stratholme and recover a box of Grimm's Premium Tobacco. Return to Smokey LaRue when the job is done.",
			pickup = "Smokey LaRue, Eastern Plaguelands",
			turnin = "Smokey LaRue, Eastern Plaguelands",
			rewards = {
				xp = 8300,
				items = {
					{
						itemID = 13171,
						name = "Smokey's Lighter",
					},
				},
			},
		},
		{
			questID = 5282,
			name = "The Restless Souls",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.114,
				y = 0.266,
			},
			endMap = {
				mapID = 1423,
				x = 0.114,
				y = 0.266,
			},
			objective = "Use Egan's Blaster on the ghostly and spectral citizens of Stratholme. When the restless souls break free from their ghostly shells, use the blaster again - freedom will be theirs! Free 15 Restless Souls and return to Egan.",
			pickup = "Egan, Eastern Plaguelands",
			turnin = "Egan, Eastern Plaguelands",
			rewards = {
				xp = 8300,
				money = 18000,
				items = {
					{
						itemID = 13315,
						name = "Testament of Hope",
					},
				},
			},
			prerequisites = {
				{
					questID = 5281,
					name = "The Restless Souls",
				},
			},
		},
		{
			questID = 5262,
			name = "The Truth Comes Crashing Down",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			endMap = {
				mapID = 1423,
				x = 0.716,
				y = 0.501,
			},
			objective = "Take the Head of Balnazzar to Duke Nicholas Zverenhoff in the Eastern Plaguelands.",
			turnin = "Duke Nicholas Zverenhoff, Eastern Plaguelands",
			rewards = {
				xp = 8300,
				reputation = {
					{
						faction = "Argent Dawn",
						amount = 150,
					},
				},
			},
			prerequisites = {
				{
					questID = 5251,
					name = "The Archivist",
				},
			},
		},
		{
			questID = 5263,
			name = "Above and Beyond",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.716,
				y = 0.501,
			},
			endMap = {
				mapID = 1423,
				x = 0.716,
				y = 0.501,
			},
			objective = "Venture to Stratholme and destroy Baron Rivendare. Take his head and return to Duke Nicholas Zverenhoff.",
			pickup = "Duke Nicholas Zverenhoff, Eastern Plaguelands",
			turnin = "Duke Nicholas Zverenhoff, Eastern Plaguelands",
			rewards = {
				xp = 8300,
				reputation = {
					{
						faction = "Argent Dawn",
						amount = 150,
					},
				},
			},
			prerequisites = {
				{
					questID = 5262,
					name = "The Truth Comes Crashing Down",
				},
			},
		},
		{
			questID = 5265,
			name = "The Argent Hold",
			level = 60,
			requiredLevel = 55,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.719,
				y = 0.484,
			},
			endMap = {
				mapID = 1423,
				x = 0.72,
				y = 0.484,
			},
			objective = "Open the Argent Hold and claim your reward.",
			pickup = "Lord Maxwell Tyrosus, Eastern Plaguelands",
			turnin = "The Argent Hold, Eastern Plaguelands",
			rewards = {
				xp = 9950,
				money = 27000,
				items = {
					{
						itemID = 13246,
						name = "Argent Avenger",
					},
					{
						itemID = 13243,
						name = "Argent Defender",
					},
					{
						itemID = 13249,
						name = "Argent Crusader",
					},
				},
				choice = true,
			},
			prerequisites = {
				{
					questID = 5264,
					name = "Lord Maxwell Tyrosus",
				},
			},
		},
		{
			questID = 5463,
			name = "Menethil's Gift",
			level = 60,
			requiredLevel = 57,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.719,
				y = 0.483,
			},
			objective = "Travel to Stratholme and find Menethil's Gift. Place the Keepsake of Remembrance upon the unholy ground.",
			pickup = "Leonid Barthalomew the Revered, Eastern Plaguelands",
			rewards = {
				xp = 6600,
			},
			prerequisites = {
				{
					questID = 5464,
					name = "Menethil's Gift",
				},
			},
		},
		{
			questID = 8945,
			name = "Dead Man's Plea",
			level = 60,
			requiredLevel = 58,
			faction = "Both",
			startMap = {
				mapID = 1423,
				x = 0.261,
				y = 0.113,
			},
			objective = "Go into Stratholme and rescue Ysida Harmon from Baron Rivendare.",
			pickup = "Anthion Harmon, Eastern Plaguelands",
			turnin = "Ysida Harmon, inside the dungeon",
			rewards = {
				xp = 8300,
				items = {
					{
						itemID = 22137,
						name = "Ysida's Satchel",
					},
				},
			},
			prerequisites = {
				{
					questID = 9022,
					name = "Warrior",
				},
			},
		},
		{
			questID = 8968,
			name = "The Left Piece of Lord Valthalak's Amulet",
			level = 60,
			requiredLevel = 58,
			faction = "Both",
			startMap = {
				mapID = 1428,
				x = 0.323,
				y = 0.258,
			},
			endMap = {
				mapID = 1428,
				x = 0.323,
				y = 0.258,
			},
			objective = "Use the Brazier of Beckoning to summon forth Jarien and Sothos and slay them. Return to Bodley inside Blackrock Mountain with the Left Piece of Lord Valthalak's Amulet and the Brazier of Beckoning.",
			pickup = "Bodley, Blackrock Mountain",
			turnin = "Bodley, Blackrock Mountain",
			rewards = {
				xp = 8300,
			},
			prerequisites = {
				{
					questID = 8964,
					name = "Components of Importance",
				},
			},
		},
		{
			questID = 8991,
			name = "The Right Piece of Lord Valthalak's Amulet",
			level = 60,
			requiredLevel = 58,
			faction = "Both",
			startMap = {
				mapID = 1428,
				x = 0.323,
				y = 0.258,
			},
			endMap = {
				mapID = 1428,
				x = 0.323,
				y = 0.258,
			},
			objective = "Use the Brazier of Beckoning to summon forth Jarien and Sothos and slay them. Return to Bodley inside Blackrock Mountain with the recombined Lord Valthalak's Amulet and the Brazier of Beckoning.",
			pickup = "Bodley, Blackrock Mountain",
			turnin = "Bodley, Blackrock Mountain",
			rewards = {
				xp = 8300,
			},
			prerequisites = {
				{
					questID = 8970,
					name = "I See Alcaz Island In Your Future...",
				},
			},
		},
		{
			questID = 6163,
			name = "Ramstein",
			level = 60,
			requiredLevel = 56,
			faction = "Horde",
			startMap = {
				mapID = 1423,
				x = 0.222,
				y = 0.635,
			},
			endMap = {
				mapID = 1423,
				x = 0.222,
				y = 0.635,
			},
			objective = "Travel to Stratholme and slay Ramstein the Gorger. Take his head as a souvenir for Nathanos.",
			pickup = "Nathanos Blightcaller, Eastern Plaguelands",
			turnin = "Nathanos Blightcaller, Eastern Plaguelands",
			rewards = {
				xp = 6600,
				money = 18000,
				reputation = {
					{
						faction = "Undercity",
						amount = 100,
					},
				},
				items = {
					{
						itemID = 18022,
						name = "Royal Seal of Alexis",
					},
					{
						itemID = 17001,
						name = "Elemental Circle",
					},
				},
				choice = true,
			},
			prerequisites = {
				{
					questID = 6135,
					name = "Duskwing, Oh How I Hate Thee...",
				},
			},
		},
	},
})
