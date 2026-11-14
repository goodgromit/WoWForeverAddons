local _, ns = ...

--[[
	Which bosses each dungeon's quests have business with (to kill, for his drop, for a drop that starts a quest, or
	giving or taking it at his spot): the quest badge on his pins and in the boss list (UI/QuestMap.lua). Written by
	Tools/build_quest_links.py from the journal's own quest data, by the rules in Tools/quest_links.lua: not by hand.
	Write it again after a change to a dungeon's bosses, loot or quests; Tools/smoke_test.py fails while it differs.
]]
ns.AddQuestLinks({
	RagefireChasm = {
		["Taragaman the Hungerer"] = {
			{ questID = 5761, act = "drop", item = 14540, itemName = "Taragaman the Hungerer's Heart" },
		},
		["Jergosh the Invoker"] = {
			{ questID = 5728, act = "kill" },
		},
		["Bazzalan"] = {
			{ questID = 5728, act = "kill" },
		},
	},
	HallOfThanes = {
		["Faldrim Anvilmar"] = {
			{ questID = 96395, act = "kill" },
		},
		["Durgen Dirgehammer"] = {
			{ questID = 96393, act = "drop", item = 274286, itemName = "Durgen Dirgehammer's Head" },
		},
	},
	RuinsOfLordaeron = {
		["The Baron"] = {
			{ questID = 95250, act = "drop", item = 268518, itemName = "Head of the Baron" },
			{ questID = 97288, act = "start", item = 280438, itemName = "Abominable Head" },
			{ questID = 97289, act = "drop", item = 268518, itemName = "Head of the Baron" },
		},
		["Witherfang"] = {
			{ questID = 95216, act = "drop", item = 275443, itemName = "Highly Toxic Strain" },
		},
		["Rath'mael"] = {
			{ questID = 92422, act = "kill" },
		},
	},
	TheDeadmines = {
		["Sneed's Shredder"] = {
			{ questID = 2040, act = "drop", item = 7365, itemName = "Gnoam Sprecklesprocket" },
		},
		["Edwin VanCleef"] = {
			{ questID = 166, act = "drop", item = 3637, itemName = "Head of VanCleef" },
			{ questID = 373, act = "start", item = 2874, itemName = "An Unsent Letter" },
		},
	},
	WailingCaverns = {
		["Lady Anacondra"] = {
			{ questID = 914, act = "drop", item = 9739, itemName = "Gem of Anacondra" },
		},
		["Lord Cobrahn"] = {
			{ questID = 914, act = "drop", item = 9738, itemName = "Gem of Cobrahn" },
		},
		["Lord Pythas"] = {
			{ questID = 914, act = "drop", item = 9740, itemName = "Gem of Pythas" },
		},
		["Lord Serpentis"] = {
			{ questID = 914, act = "drop", item = 9741, itemName = "Gem of Serpentis" },
		},
		["Mutanus the Devourer"] = {
			{ questID = 6981, act = "start", item = 10441, itemName = "Glowing Shard" },
		},
	},
	ShadowfangKeep = {
		["Archmage Arugal"] = {
			{ questID = 1014, act = "drop", item = 5442, itemName = "Head of Arugal" },
		},
	},
	BlackfathomDeeps = {
		["Lorgus Jett"] = {
			{ questID = 6565, act = "kill" },
		},
		["Twilight Lord Kelris"] = {
			{ questID = 1200, act = "drop", item = 5881, itemName = "Head of Kelris" },
			{ questID = 6561, act = "drop", item = 5881, itemName = "Head of Kelris" },
		},
		["Baron Aquanis"] = {
			{ questID = 6922, act = "start", item = 16782, itemName = "Strange Water Globe" },
		},
	},
	TheStockade = {
		["Targorr the Dread"] = {
			{ questID = 386, act = "drop", item = 3630, itemName = "Head of Targorr" },
		},
		["Kam Deepfury"] = {
			{ questID = 378, act = "drop", item = 3640, itemName = "Head of Deepfury" },
		},
		["Dextren Ward"] = {
			{ questID = 377, act = "drop", item = 3628, itemName = "Hand of Dextren Ward" },
		},
		["Bazil Thredd"] = {
			{ questID = 391, act = "drop", item = 2926, itemName = "Head of Bazil Thredd" },
		},
	},
	ExcavationSiteWetlands = {
		["Highland Horror"] = {
			{ questID = 95646, act = "drop", item = 270180, itemName = "Horrible Rootcore" },
		},
		["Relic Guardian"] = {
			{ questID = 95664, act = "start", item = 270866, itemName = "Titan Relic" },
			{ questID = 95810, act = "start", item = 270865, itemName = "Titan Relic" },
		},
	},
	CityOfDalaran = {
		["Atrexis the Grave Knight"] = {
			{ questID = 96986, act = "kill" },
		},
		["Arcanic Enigma"] = {
			{ questID = 92489, act = "kill" },
		},
		["Shade of the Archmage"] = {
			{ questID = 92458, act = "drop", item = 251961, itemName = "Arcane Mote" },
			{ questID = 96984, act = "drop", item = 251961, itemName = "Arcane Mote" },
		},
	},
	Gnomeregan = {
		["Mekgineer Thermaplugg"] = {
			{ questID = 2929, act = "kill" },
			{ questID = 2841, act = "drop", item = 9299, itemName = "Thermaplugg's Safe Combination" },
		},
		["Techbot"] = {
			{ questID = 2922, act = "drop", item = 9277, itemName = "Techbot's Memory Core" },
		},
	},
	RazorfenKraul = {
		["Roogug"] = {
			{ questID = 1701, act = "drop", item = 6841, itemName = "Vial of Phlogiston" },
			{ questID = 1838, act = "drop", item = 6841, itemName = "Vial of Phlogiston" },
		},
		["Charlga Razorflank"] = {
			{ questID = 1101, act = "drop", item = 5792, itemName = "Razorflank's Medallion" },
			{ questID = 1102, act = "drop", item = 5793, itemName = "Razorflank's Heart" },
			{ questID = 6522, act = "start", item = 17008, itemName = "Small Scroll" },
			{ questID = 79360, act = "kill" },
			{ questID = 96264, act = "kill" },
		},
	},
	ScarletMonasteryLibrary = {
		["Houndmaster Loksey"] = {
			{ questID = 1048, act = "kill" },
			{ questID = 1053, act = "kill" },
		},
	},
	TheDrownedCity = {
		["Var'Taka"] = {
			{ questID = 95776, act = "kill" },
		},
		["Captain Dreadrise"] = {
			{ questID = 95791, act = "kill" },
		},
	},
	ScarletMonasteryArmory = {
		["Herod"] = {
			{ questID = 1053, act = "kill" },
			{ questID = 1048, act = "kill" },
		},
	},
	RazorfenDowns = {
		["Amnennar the Coldbringer"] = {
			{ questID = 3636, act = "kill" },
			{ questID = 3341, act = "drop", item = 10420, itemName = "Skull of the Coldbringer" },
		},
	},
	ScarletMonasteryCathedral = {
		["Scarlet Commander Mograine"] = {
			{ questID = 1053, act = "kill" },
			{ questID = 1048, act = "kill" },
		},
		["High Inquisitor Whitemane"] = {
			{ questID = 1053, act = "kill" },
			{ questID = 1048, act = "kill" },
		},
	},
	KroldokStronghold = {
		["Nar'gurk"] = {
			{ questID = 94984, act = "kill" },
		},
	},
	Uldaman = {
		["Grimlok"] = {
			{ questID = 2201, act = "drop", item = 7670, itemName = "Shattered Necklace Sapphire" },
			{ questID = 2339, act = "drop", item = 7670, itemName = "Shattered Necklace Sapphire" },
		},
		["Obsidian Sentinel"] = {
			{ questID = 1956, act = "drop", item = 8053, itemName = "Obsidian Power Source" },
		},
		["Archaedas"] = {
			{ questID = 2204, act = "drop", item = 7672, itemName = "Shattered Necklace Power Source" },
			{ questID = 2339, act = "drop", item = 7672, itemName = "Shattered Necklace Power Source" },
		},
	},
	ZulFarrak = {
		["Nekrum Gutchewer"] = {
			{ questID = 2991, act = "drop", item = 9471, itemName = "Nekrum's Medallion" },
		},
		["Sergeant Bly"] = {
			{ questID = 2768, act = "drop", item = 8548, itemName = "Divino-matic Rod" },
		},
		["Gahz'rilla"] = {
			{ questID = 2770, act = "drop", item = 8707, itemName = "Gahz'rilla's Electrified Scale" },
		},
		["Theka the Martyr"] = {
			{ questID = 3527, act = "drop", item = 10660, itemName = "First Mosh'aru Tablet" },
		},
		["Witch Doctor Zum'rah"] = {
			{ questID = 96770, act = "kill" },
			{ questID = 96775, act = "kill" },
		},
		["Hydromancer Velratha"] = {
			{ questID = 2846, act = "drop", item = 9234, itemName = "Tiara of the Deep" },
			{ questID = 3527, act = "drop", item = 10661, itemName = "Second Mosh'aru Tablet" },
		},
	},
	Maraudon = {
		["Noxxion"] = {
			{ questID = 7044, act = "drop", item = 17702, itemName = "Celebrian Rod" },
		},
		["Lord Vyletongue"] = {
			{ questID = 7044, act = "drop", item = 17703, itemName = "Celebrian Diamond" },
		},
		["Princess Theradras"] = {
			{ questID = 7065, act = "kill" },
			{ questID = 7066, act = "gives", who = "Zaetar's Spirit" },
			{ questID = 7064, act = "kill" },
		},
	},
	AlcazPrison = {
		["The Questioner"] = {
			{ questID = 96335, act = "kill" },
		},
		["Tidemistress Ca'zass"] = {
			{ questID = 96381, act = "drop", item = 273883, itemName = "Ca'zass's Head" },
			{ questID = 96332, act = "drop", item = 273883, itemName = "Ca'zass's Head" },
		},
		["Blazeroar"] = {
			{ questID = 96772, act = "drop", item = 276890, itemName = "Zarla's Journal" },
		},
	},
	TempleOfAtalHakkar = {
		["Jammal'an the Prophet"] = {
			{ questID = 1446, act = "drop", item = 6212, itemName = "Head of Jammal'an" },
		},
		["Morphaz"] = {
			{ questID = 8232, act = "drop", item = 20019, itemName = "Tooth of Morphaz" },
			{ questID = 8236, act = "drop", item = 20022, itemName = "Azure Key" },
			{ questID = 8253, act = "drop", item = 20085, itemName = "Arcane Shard" },
			{ questID = 8257, act = "drop", item = 20025, itemName = "Blood of Morphaz" },
		},
		["Atal'alarion"] = {
			{ questID = 9053, act = "drop", item = 22444, itemName = "Putrid Vine" },
		},
		["Shade of Eranikus"] = {
			{ questID = 3373, act = "start", item = 10454, itemName = "Essence of Eranikus" },
		},
	},
	BlackrockDepths = {
		["Fineous Darkvire"] = {
			{ questID = 3802, act = "drop", item = 10999, itemName = "Ironfel", article = false },
		},
		["Bael'Gar"] = {
			{ questID = 4024, act = "kill" },
		},
		["Golem Lord Argelmach"] = {
			{ questID = 4282, act = "drop", item = 11465, itemName = "Marshal Windsor's Lost Information" },
			{ questID = 4063, act = "drop", item = 11268, itemName = "Head of Argelmach" },
		},
		["Emperor Dagran Thaurissan"] = {
			{ questID = 4362, act = "kill" },
			{ questID = 4003, act = "kill" },
		},
		["Lord Incendius"] = {
			{ questID = 4263, act = "kill" },
			{ questID = 3907, act = "drop", item = 11126, itemName = "Tablet of Kurniya" },
			{ questID = 8961, act = "drop", item = 21987, itemName = "Incendicite of Incendius" },
		},
		["General Angerforge"] = {
			{ questID = 4282, act = "drop", item = 11464, itemName = "Marshal Windsor's Lost Information" },
			{ questID = 4132, act = "kill" },
		},
		["Princess Moira Bronzebeard"] = {
			{ questID = 4362, act = "takes" },
			{ questID = 4363, act = "gives" },
			{ questID = 4003, act = "takes" },
			{ questID = 4004, act = "gives" },
		},
	},
	DireMaulEast = {
		["Pusillin"] = {
			{ questID = 7441, act = "drop", item = 18261, itemName = "Book of Incantations" },
		},
		["Hydrospawn"] = {
			{ questID = 7463, act = "drop", item = 18299, itemName = "Hydrospawn Essence" },
		},
		["Alzzin the Wildshaper"] = {
			{ questID = 5526, act = "kill" },
		},
		["Lethtendris"] = {
			{ questID = 7488, act = "drop", item = 18426, itemName = "Lethtendris's Web" },
			{ questID = 7489, act = "drop", item = 18426, itemName = "Lethtendris's Web" },
		},
	},
	BlackmawHold = {
		["Withermaw"] = {
			{ questID = 92069, act = "drop", item = 249697, itemName = "Claws of the Great Bear" },
		},
		["Elder Shaman Bloodmane"] = {
			{ questID = 97173, act = "drop", item = 276893, itemName = "Blackmaw Ritual Totem" },
			{ questID = 97198, act = "drop", item = 276893, itemName = "Blackmaw Ritual Totem" },
		},
		["Bonesnout the Unbroken"] = {
			{ questID = 92069, act = "drop", item = 249696, itemName = "Tusks of the Unbroken" },
		},
		["Varrox Bleakhoof"] = {
			{ questID = 92065, act = "drop", item = 249692, itemName = "Head of Varrox Bleakhoof" },
		},
	},
	LowerBlackrockSpire = {
		["Highlord Omokk"] = {
			{ questID = 4742, act = "drop", item = 12336, itemName = "Gemstone of Spirestone" },
			{ questID = 5081, act = "kill" },
			{ questID = 4903, act = "kill" },
			{ questID = 8957, act = "drop", item = 16670, itemName = "Boots of Elements" },
		},
		["War Master Voone"] = {
			{ questID = 4742, act = "drop", item = 12335, itemName = "Gemstone of Smolderthorn" },
			{ questID = 5081, act = "kill" },
			{ questID = 4903, act = "kill" },
			{ questID = 8931, act = "drop", item = 16676, itemName = "Beaststalker's Gloves" },
			{ questID = 8938, act = "drop", item = 16676, itemName = "Beaststalker's Gloves" },
		},
		["Mother Smolderweb"] = {
			{ questID = 4866, act = "kill" },
			{ questID = 8951, act = "drop", item = 16715, itemName = "Wildheart Boots" },
			{ questID = 9016, act = "drop", item = 16715, itemName = "Wildheart Boots" },
		},
		["Urok Doomhowl"] = {
			{ questID = 4867, act = "drop", item = 12712, itemName = "Warosh's Mojo" },
		},
		["Halycon"] = {
			{ questID = 4701, act = "kill" },
			{ questID = 4724, act = "kill" },
		},
		["Shadow Hunter Vosh'gajin"] = {
			{ questID = 5306, act = "drop", item = 13352, itemName = "Vosh'gajin's Snakestone" },
			{ questID = 8935, act = "drop", item = 16712, itemName = "Shadowcraft Gloves" },
			{ questID = 8941, act = "drop", item = 16712, itemName = "Shadowcraft Gloves" },
		},
		["Gizrul the Slavener"] = {
			{ questID = 8951, act = "drop", item = 16718, itemName = "Wildheart Spaulders" },
			{ questID = 9016, act = "drop", item = 16718, itemName = "Wildheart Spaulders" },
		},
		["Overlord Wyrmthalak"] = {
			{ questID = 4742, act = "drop", item = 12337, itemName = "Gemstone of Bloodaxe" },
			{ questID = 5089, act = "start", item = 12780, itemName = "General Drakkisath's Command" },
			{ questID = 5081, act = "kill" },
			{ questID = 4903, act = "kill" },
			{ questID = 8952, act = "drop", item = 16679, itemName = "Beaststalker's Mantle" },
			{ questID = 9017, act = "drop", item = 16679, itemName = "Beaststalker's Mantle" },
		},
	},
	DireMaulWest = {
		["Tendris Warpwood"] = {
			{ questID = 7643, act = "kill" },
		},
		["Prince Tortheldrin"] = {
			{ questID = 7461, act = "kill" },
		},
		["Immol'thar"] = {
			{ questID = 7461, act = "kill" },
		},
	},
	DireMaulNorth = {
		["Captain Kromcrush"] = {
			{ questID = 7506, act = "start", item = 18364, itemName = "The Emerald Dream" },
			{ questID = 7703, act = "gives" },
			{ questID = 7703, act = "takes" },
		},
		["Stomper Kreeg"] = {
			{ questID = 5528, act = "gives" },
			{ questID = 5528, act = "takes" },
		},
	},
	Scholomance = {
		["Jandice Barov"] = {
			{ questID = 5515, act = "drop", item = 13725, itemName = "Krastinov's Bag of Horrors" },
			{ questID = 8958, act = "drop", item = 16701, itemName = "Dreadmist Mantle" },
			{ questID = 9021, act = "drop", item = 16701, itemName = "Dreadmist Mantle" },
		},
		["Death Knight Darkreaver"] = {
			{ questID = 7647, act = "kill" },
			{ questID = 8258, act = "drop", item = 18880, itemName = "Darkreaver's Head" },
		},
		["Ras Frostwhisper"] = {
			{ questID = 5466, act = "drop", item = 13626, itemName = "Human Head of Ras Frostwhisper" },
			{ questID = 8953, act = "drop", item = 16689, itemName = "Magister's Mantle" },
			{ questID = 9018, act = "drop", item = 16689, itemName = "Magister's Mantle" },
		},
		["Doctor Theolen Krastinov"] = {
			{ questID = 5382, act = "kill" },
			{ questID = 8932, act = "drop", item = 16684, itemName = "Magister's Gloves" },
			{ questID = 8939, act = "drop", item = 16684, itemName = "Magister's Gloves" },
		},
		["Kirtonos the Herald"] = {
			{ questID = 5384, act = "kill" },
			{ questID = 8959, act = "drop", item = 16734, itemName = "Boots of Valor" },
			{ questID = 9022, act = "drop", item = 16734, itemName = "Boots of Valor" },
		},
		["Rattlegore"] = {
			{ questID = 8956, act = "drop", item = 16711, itemName = "Shadowcraft Boots" },
			{ questID = 9020, act = "drop", item = 16711, itemName = "Shadowcraft Boots" },
		},
		["Vectus"] = {
			{ questID = 4771, act = "kill" },
		},
		["Lorekeeper Polkelt"] = {
			{ questID = 8936, act = "drop", item = 16705, itemName = "Dreadmist Wraps" },
			{ questID = 8943, act = "drop", item = 16705, itemName = "Dreadmist Wraps" },
		},
		["Darkmaster Gandling"] = {
			{ questID = 8999, act = "drop", item = 16720, itemName = "Wildheart Cowl" },
			{ questID = 9000, act = "drop", item = 16677, itemName = "Beaststalker's Cap" },
			{ questID = 9001, act = "drop", item = 16686, itemName = "Magister's Crown" },
			{ questID = 9002, act = "drop", item = 16727, itemName = "Lightforge Helm" },
			{ questID = 9003, act = "drop", item = 16693, itemName = "Devout Crown" },
			{ questID = 9004, act = "drop", item = 16707, itemName = "Shadowcraft Cap" },
			{ questID = 9005, act = "drop", item = 16698, itemName = "Dreadmist Mask" },
			{ questID = 9006, act = "drop", item = 16731, itemName = "Helm of Valor" },
			{ questID = 9007, act = "drop", item = 16720, itemName = "Wildheart Cowl" },
			{ questID = 9008, act = "drop", item = 16677, itemName = "Beaststalker's Cap" },
			{ questID = 9014, act = "drop", item = 16686, itemName = "Magister's Crown" },
			{ questID = 9009, act = "drop", item = 16693, itemName = "Devout Crown" },
			{ questID = 9010, act = "drop", item = 16707, itemName = "Shadowcraft Cap" },
			{ questID = 9011, act = "drop", item = 16667, itemName = "Coif of Elements" },
			{ questID = 9012, act = "drop", item = 16698, itemName = "Dreadmist Mask" },
			{ questID = 9013, act = "drop", item = 16731, itemName = "Helm of Valor" },
		},
	},
	StratholmeMainGate = {
		["Hearthsinger Forresten"] = {
			{ questID = 8953, act = "drop", item = 16682, itemName = "Magister's Boots" },
			{ questID = 9018, act = "drop", item = 16682, itemName = "Magister's Boots" },
		},
		["Cannon Master Willey"] = {
			{ questID = 8956, act = "drop", item = 16708, itemName = "Shadowcraft Spaulders" },
			{ questID = 9020, act = "drop", item = 16708, itemName = "Shadowcraft Spaulders" },
		},
		["The Unforgiven"] = {
			{ questID = 8926, act = "drop", item = 16717, itemName = "Wildheart Gloves" },
			{ questID = 8927, act = "drop", item = 16717, itemName = "Wildheart Gloves" },
		},
		["Timmy the Cruel"] = {
			{ questID = 8933, act = "drop", item = 16724, itemName = "Lightforge Gauntlets" },
		},
		["Crimson Hammersmith"] = {
			{ questID = 5305, act = "drop", item = 13351, itemName = "Crimson Hammersmith's Apron" },
		},
		["Archivist Galford"] = {
			{ questID = 5251, act = "kill" },
			{ questID = 8934, act = "drop", item = 16692, itemName = "Devout Gloves" },
			{ questID = 8940, act = "drop", item = 16692, itemName = "Devout Gloves" },
		},
		["Balnazzar"] = {
			{ questID = 5262, act = "start", item = 13250, itemName = "Head of Balnazzar" },
			{ questID = 8954, act = "drop", item = 16725, itemName = "Lightforge Boots" },
		},
	},
	StratholmeServiceGate = {
		["Black Guard Swordsmith"] = {
			{ questID = 5307, act = "drop", item = 13350, itemName = "Insignia of the Black Guard" },
		},
		["Nerub'enkan"] = {
			{ questID = 8952, act = "drop", item = 16675, itemName = "Beaststalker's Boots" },
			{ questID = 9017, act = "drop", item = 16675, itemName = "Beaststalker's Boots" },
		},
		["Ramstein the Gorger"] = {
			{ questID = 6163, act = "drop", item = 15880, itemName = "Head of Ramstein the Gorger" },
			{ questID = 8937, act = "drop", item = 16737, itemName = "Gauntlets of Valor" },
			{ questID = 8944, act = "drop", item = 16737, itemName = "Gauntlets of Valor" },
		},
		["Baroness Anastari"] = {
			{ questID = 8958, act = "drop", item = 16704, itemName = "Dreadmist Sandals" },
			{ questID = 9021, act = "drop", item = 16704, itemName = "Dreadmist Sandals" },
		},
		["Maleki the Pallid"] = {
			{ questID = 8955, act = "drop", item = 16691, itemName = "Devout Sandals" },
			{ questID = 9019, act = "drop", item = 16691, itemName = "Devout Sandals" },
		},
		["Baron Rivendare"] = {
			{ questID = 5263, act = "drop", item = 13251, itemName = "Head of Baron Rivendare" },
			{ questID = 8945, act = "takes", who = "Ysida Harmon" },
			{ questID = 8946, act = "gives", who = "Ysida Harmon" },
			{ questID = 8951, act = "drop", item = 16719, itemName = "Wildheart Kilt" },
			{ questID = 8952, act = "drop", item = 16678, itemName = "Beaststalker's Pants" },
			{ questID = 8953, act = "drop", item = 16687, itemName = "Magister's Leggings" },
			{ questID = 8954, act = "drop", item = 16728, itemName = "Lightforge Legplates" },
			{ questID = 8955, act = "drop", item = 16694, itemName = "Devout Skirt" },
			{ questID = 8956, act = "drop", item = 16709, itemName = "Shadowcraft Pants" },
			{ questID = 8958, act = "drop", item = 16699, itemName = "Dreadmist Leggings" },
			{ questID = 8959, act = "drop", item = 16732, itemName = "Legplates of Valor" },
			{ questID = 9016, act = "drop", item = 16719, itemName = "Wildheart Kilt" },
			{ questID = 9017, act = "drop", item = 16678, itemName = "Beaststalker's Pants" },
			{ questID = 9018, act = "drop", item = 16687, itemName = "Magister's Leggings" },
			{ questID = 9019, act = "drop", item = 16694, itemName = "Devout Skirt" },
			{ questID = 9020, act = "drop", item = 16709, itemName = "Shadowcraft Pants" },
			{ questID = 8957, act = "drop", item = 16668, itemName = "Kilt of Elements" },
			{ questID = 9021, act = "drop", item = 16699, itemName = "Dreadmist Leggings" },
			{ questID = 9022, act = "drop", item = 16732, itemName = "Legplates of Valor" },
		},
	},
	UpperBlackrockSpire = {
		["Pyroguard Emberseer"] = {
			{ questID = 6821, act = "drop", item = 17322, itemName = "Eye of the Emberseer" },
			{ questID = 8961, act = "drop", item = 21988, itemName = "Ember of Emberseer" },
			{ questID = 8942, act = "drop", item = 16672, itemName = "Gauntlets of Elements" },
		},
		["Gyth"] = {
			{ questID = 8957, act = "drop", item = 16669, itemName = "Pauldrons of Elements" },
		},
		["The Beast"] = {
			{ questID = 5047, act = "gives", who = "Pip Quickwit" },
			{ questID = 8954, act = "drop", item = 16729, itemName = "Lightforge Spaulders" },
		},
		["Solakar Flamewreath"] = {
			{ questID = 8955, act = "drop", item = 16695, itemName = "Devout Mantle" },
			{ questID = 9019, act = "drop", item = 16695, itemName = "Devout Mantle" },
		},
		["Goraluk Anvilcrack"] = {
			{ questID = 5127, act = "kill" },
		},
		["Warchief Rend Blackhand"] = {
			{ questID = 4974, act = "drop", item = 12630, itemName = "Head of Rend Blackhand" },
			{ questID = 8959, act = "drop", item = 16733, itemName = "Spaulders of Valor" },
			{ questID = 9022, act = "drop", item = 16733, itemName = "Spaulders of Valor" },
		},
		["General Drakkisath"] = {
			{ questID = 6502, act = "drop", item = 16663, itemName = "Blood of the Black Dragon Champion" },
			{ questID = 5102, act = "kill" },
			{ questID = 6602, act = "drop", item = 16663, itemName = "Blood of the Black Dragon Champion" },
			{ questID = 8999, act = "drop", item = 16706, itemName = "Wildheart Vest" },
			{ questID = 9000, act = "drop", item = 16674, itemName = "Beaststalker's Tunic" },
			{ questID = 9001, act = "drop", item = 16688, itemName = "Magister's Robes" },
			{ questID = 9002, act = "drop", item = 16726, itemName = "Lightforge Breastplate" },
			{ questID = 9003, act = "drop", item = 16690, itemName = "Devout Robe" },
			{ questID = 9004, act = "drop", item = 16721, itemName = "Shadowcraft Tunic" },
			{ questID = 9005, act = "drop", item = 16700, itemName = "Dreadmist Robe" },
			{ questID = 9006, act = "drop", item = 16730, itemName = "Breastplate of Valor" },
			{ questID = 9007, act = "drop", item = 16706, itemName = "Wildheart Vest" },
			{ questID = 9008, act = "drop", item = 16674, itemName = "Beaststalker's Tunic" },
			{ questID = 9014, act = "drop", item = 16688, itemName = "Magister's Robes" },
			{ questID = 9009, act = "drop", item = 16690, itemName = "Devout Robe" },
			{ questID = 9010, act = "drop", item = 16721, itemName = "Shadowcraft Tunic" },
			{ questID = 9011, act = "drop", item = 16666, itemName = "Vest of Elements" },
			{ questID = 9012, act = "drop", item = 16700, itemName = "Dreadmist Robe" },
			{ questID = 9013, act = "drop", item = 16730, itemName = "Breastplate of Valor" },
		},
	},
	OnyxiasLair = {
		["Onyxia"] = {
			{ questID = 7495, act = "start", item = 18423, itemName = "Head of Onyxia" },
			{ questID = 7490, act = "start", item = 18422, itemName = "Head of Onyxia" },
		},
	},
})
