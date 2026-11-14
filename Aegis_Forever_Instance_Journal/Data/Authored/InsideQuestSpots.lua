local _, ns = ...

--[[
	Quest spots inside the dungeons, on the journal's own floor pictures (2026-11-11, the owner's go of that
	day): who gives or takes a quest there (startInside, endInside: its "!" or "?", UI/QuestMap.lua), and
	what is looted, used or explored for one (objectivesInside: the game's In Progress mark, UI/QuestMap.lua's
	ObjectiveMark). Loaded after the dungeons' own data and quest files, so each quest is the one its dungeon's
	page lists.

	Each spot: x and y, a share of the floor picture's width and height; floor, the journal's floor index as
	the floor menu lists it (Data/Authored/ClassicMaps.lua puts a whole-dungeon picture first); name, who or
	what stands there, as the mark's tooltip names it. An objective also has act ("loot", "use" or "explore")
	and, to loot, the item (item, its id; itemName, its English name for the tooltip until the client has its
	own), with article = false where that name takes no "the" ("The Book of Ur", "Jordan's Smithing Hammer"), and
	quoted = true for a title, in the language's quotation marks ("Take “Of Love and Family”", a painting).
	One table for each person or thing: the quests it gives or takes share it, and are one mark there, the
	game's way over a person with several quests (UI/QuestMap.lua's InsideMarks).

	A dungeon's whole map (a floor marked whole: Blackfathom Deeps', the Deadmines', Shadowfang Keep's, Maraudon's,
	Stratholme's, the temple's) shows every floor's marks too (the owner's call of 2026-11-12): a spot on a level floor
	has its place there as well (whole = { x, y }, a share of the whole map's width and height), carried from its floor's
	picture by that floor's fit (the 2026-11-11 sheet, checked against the fits the whole maps were drawn from: within
	about 8 pixels of a 1000-pixel map, each on the same room's floor). One on the whole map itself (the temple's) has
	none. The level floors' spots are as they were. Two were set a few pixels off their fit later (Menethil's Gift and
	the Book of Ur, the review of 2026-11-12): the whole maps' pins stand closer together than the floors', and kept
	clear of them (UI/QuestMap.lua's ClearOfPins) those two went the wrong way, one over a pin, one onto a wall.

	Where they come from: the quest-spot facts read with our own parser (2026-11-10, read again 2026-11-11),
	carried onto these pictures by a registered fit, good to about 0.001 of a picture; and the owner's own spot
	of the Pitted Iron Chest and Ardin Grassman, in game (2026-11-11; Captain Truman's is in
	Data/Authored/RuinsOfLordaeron.lua). A spot "to check" was set beside a boss's portrait in those facts, so
	where it stands was not given: ours is a best guess near that boss (halfway back from the drawn spot,
	nudged onto the floor, or the drawn spot itself), for a look in game to fix. No spot is from a spawn
	table: none keeps a place inside a dungeon.

	Gnomeregan (2026-11-12): its whole map came first in its floor menu, so its level floors are 2 to 5 (226-229), and
	its spots have their whole places by the same fits (the 2026-11-11 marking sheets' fit.json, matched rooms, about 6
	pixels' error), Thermaplugg's Safe set onto Tinkers' Court's floor from just past its rim. Its way in's picture has
	one spot of its own (wayIn, the picture's key, on no floor: UI/QuestMap.lua's InsideMarks), besides Techbot's pin
	(Data/Authored/SubMaps.lua): Matrix Punchograph 3005-A in the tunnels outside, by the owner's reading there carried
	through Forever's region of Dun Morogh and the picture's frame. The Sparklematic 5200 is inside only (the owner,
	2026-11-12), where the owner circled it on the whole map; once its quest is done it keeps a mark of its own for the
	repeatable step (repeatInside: the spot and what it takes, UI/QuestMap.lua's RepeatMark). A Punchograph's step says what card goes in and what comes out (input, output), each card's short a
	key of the strings, its color in a word, for the tooltip's "Yellow > Blue" (the owner's call of 2026-11-12, words for
	color-blind players too); its mark goes once the player holds the card it gives or one made from it later (doneWith:
	White, then Yellow, Blue, Red, Prismatic Punch Card, the quest data's items 9279, 9280, 9282, 9281, 9316). Its mark is
	the card it takes, round in a ring (icon, a file id: UI/QuestMap.lua's RINGED_SIZE), the owner's pick of 2026-11-12:
	the client's colored punch card icons, Interface/Icons/INV_Misc_PunchCards_White (134393), _Yellow (134394), _Blue
	(134390) and _Red (134392), each in Forever's client files (read 2026-11-12). In Forever the cards themselves show a
	silver bar in the bags (Item.db2's icon, 133215, for all five): these colored icons are the client's punch card art,
	chosen for the map, not the cards' own.

	Not here: a quest that starts from an item a boss drops, and the givers the sheet could only stand in on a
	boss's own pin (Zaetar's Spirit, Captain Kromcrush, Stomper Kreeg, Princess Moira, Ysida Harmon, Pip Quickwit): the
	boss's pin carries the quest badge instead (Data/Generated/QuestLinks.lua); quests a dungeon's own file
	marks already (the Hall of Thanes', Ruins of Lordaeron's); and quests our data does not have on that page (Nostro's Compendium, 7507,
	Lorekeeper Lydros's in Dire Maul; The Archivist, 5251, which only the Main Gate's page lists).
]]

do
	-- Pitted Iron Chest (loot): the owner's spot, in game (2026-11-11); on the whole map, carried by its floor's fit
	local PITTED_IRON_CHEST = { x = 0.335, y = 0.405, floor = 2, act = "loot", name = "Pitted Iron Chest", item = 5359, itemName = "Lorgalis Manuscript", whole = { x = 0.2283, y = 0.27 } }
	-- Argent Guard Thaelrid: from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local ARGENT_GUARD_THAELRID = { x = 0.208, y = 0.753, floor = 2, name = "Argent Guard Thaelrid", whole = { x = 0.1405, y = 0.5115 } }
	-- Fathom Stone (loot): to check in game: the facts set it beside Baron Aquanis's portrait; a best guess; on the whole map, carried by its floor's fit
	local FATHOM_STONE = { x = 0.413, y = 0.762, floor = 3, act = "loot", name = "Fathom Stone", item = 16762, itemName = "Fathom Core", whole = { x = 0.4505, y = 0.8346 } }
	ns.AmendInstance("BlackfathomDeeps", { questPatches = {
		[971] = { objectivesInside = { PITTED_IRON_CHEST } },
		[1198] = { endInside = ARGENT_GUARD_THAELRID },
		[1200] = { startInside = ARGENT_GUARD_THAELRID },
		[6561] = { startInside = ARGENT_GUARD_THAELRID },
		[6921] = { objectivesInside = { FATHOM_STONE } },
	} })
end

do
	-- Commander Gor'shak: to check in game: the facts set it beside High Interrogator Gerstahn's portrait; a best guess
	local COMMANDER_GORSHAK = { x = 0.4975, y = 0.866, floor = 1, name = "Commander Gor'shak" }
	-- Kharan Mighthammer: to check in game: the facts set it beside High Interrogator Gerstahn's portrait; a best guess
	local KHARAN_MIGHTHAMMER = { x = 0.4975, y = 0.866, floor = 1, name = "Kharan Mighthammer" }
	-- Marshal Windsor: to check in game: the facts set it beside High Interrogator Gerstahn's portrait; a best guess
	local MARSHAL_WINDSOR = { x = 0.514, y = 0.926, floor = 1, name = "Marshal Windsor" }
	-- Core Fragment (loot): from the facts, carried onto this picture; not seen in game yet
	local CORE_FRAGMENT = { x = 0.6916, y = 0.3695, floor = 2, act = "loot", name = "Core Fragment", item = 18412, itemName = "Core Fragment" }
	-- Dark Coffer (loot): to check in game: the facts set it beside Warder Stilgiss's portrait; a best guess
	local DARK_COFFER = { x = 0.6158, y = 0.6945, floor = 2, act = "loot", name = "Dark Coffer", item = 7910, itemName = "Star Ruby" }
	-- Heart of the Mountain (loot): to check in game: the facts set it beside Warder Stilgiss's portrait; a best guess
	local HEART_OF_THE_MOUNTAIN = { x = 0.6158, y = 0.6945, floor = 2, act = "loot", name = "Heart of the Mountain", item = 11309, itemName = "The Heart of the Mountain", article = false }
	-- Lokhtos Darkbargainer: to check in game: the facts set it beside Plugger Spazzring's portrait; a best guess
	local LOKHTOS_DARKBARGAINER = { x = 0.4945, y = 0.6231, floor = 2, name = "Lokhtos Darkbargainer" }
	-- Mistress Nagmara: to check in game: the facts set it beside Plugger Spazzring's portrait; a best guess
	local MISTRESS_NAGMARA = { x = 0.4945, y = 0.6231, floor = 2, name = "Mistress Nagmara" }
	-- Monument of Franclorn Forgewright: to check in game: the facts set it beside Pyromancer Loregrain's portrait; a best guess
	local MONUMENT_OF_FRANCLORN_FORGEWRIGHT = { x = 0.5808, y = 0.9476, floor = 2, name = "Monument of Franclorn Forgewright" }
	-- Private Rocknot: to check in game: the facts set it beside Plugger Spazzring's portrait; a best guess
	local PRIVATE_ROCKNOT = { x = 0.4945, y = 0.6231, floor = 2, name = "Private Rocknot" }
	-- Spectral Chalice: to check in game: the facts set it beside The Seven's portrait; a best guess
	local SPECTRAL_CHALICE = { x = 0.5434, y = 0.2886, floor = 2, name = "Spectral Chalice" }
	ns.AmendInstance("BlackrockDepths", { questPatches = {
		[3982] = { startInside = COMMANDER_GORSHAK, endInside = COMMANDER_GORSHAK },
		[3981] = { endInside = COMMANDER_GORSHAK },
		[4001] = { startInside = COMMANDER_GORSHAK },
		[4341] = { endInside = KHARAN_MIGHTHAMMER },
		[4342] = { startInside = KHARAN_MIGHTHAMMER, endInside = KHARAN_MIGHTHAMMER },
		[4361] = { startInside = KHARAN_MIGHTHAMMER },
		[4322] = { startInside = MARSHAL_WINDSOR },
		[4241] = { endInside = MARSHAL_WINDSOR },
		[4242] = { startInside = MARSHAL_WINDSOR },
		[4264] = { endInside = MARSHAL_WINDSOR },
		[4282] = { startInside = MARSHAL_WINDSOR, endInside = MARSHAL_WINDSOR },
		[7848] = { objectivesInside = { CORE_FRAGMENT } },
		[4083] = { startInside = SPECTRAL_CHALICE, endInside = SPECTRAL_CHALICE, objectivesInside = { DARK_COFFER } },
		[4123] = { objectivesInside = { HEART_OF_THE_MOUNTAIN } },
		[7604] = { endInside = LOKHTOS_DARKBARGAINER },
		[4201] = { startInside = MISTRESS_NAGMARA, endInside = MISTRESS_NAGMARA },
		[3802] = { endInside = MONUMENT_OF_FRANCLORN_FORGEWRIGHT },
		[4295] = { startInside = PRIVATE_ROCKNOT, endInside = PRIVATE_ROCKNOT },
	} })
end

do
	-- Knot Thimblejack: to check in game: the facts set it beside Guard Slip'kik's portrait; a best guess
	local KNOT_THIMBLEJACK = { x = 0.2929, y = 0.5842, floor = 1, name = "Knot Thimblejack" }
	-- Ogre Tannin Basket (loot): to check in game: the facts set it beside Guard Slip'kik's portrait; a best guess
	local OGRE_TANNIN_BASKET = { x = 0.241, y = 0.5477, floor = 1, act = "loot", name = "Ogre Tannin Basket", item = 18240, itemName = "Ogre Tannin" }
	ns.AmendInstance("DireMaulNorth", { questPatches = {
		[5525] = { startInside = KNOT_THIMBLEJACK, endInside = KNOT_THIMBLEJACK },
		[5518] = { startInside = KNOT_THIMBLEJACK, endInside = KNOT_THIMBLEJACK, objectivesInside = { OGRE_TANNIN_BASKET } },
	} })
end

do
	-- Shen'dralar Ancient: from the facts, carried onto this picture; not seen in game yet
	local SHENDRALAR_ANCIENT = { x = 0.483, y = 0.5372, floor = 1, name = "Shen'dralar Ancient" }
	-- Lorekeeper Javon: from the facts, carried onto this picture; not seen in game yet
	local LOREKEEPER_JAVON = { x = 0.7455, y = 0.1129, floor = 3, name = "Lorekeeper Javon" }
	-- Lorekeeper Kildrath: from the facts, carried onto this picture; not seen in game yet
	local LOREKEEPER_KILDRATH = { x = 0.8433, y = 0.2297, floor = 3, name = "Lorekeeper Kildrath" }
	-- Lorekeeper Lydros: from the facts, carried onto this picture; not seen in game yet
	local LOREKEEPER_LYDROS = { x = 0.7355, y = 0.1708, floor = 3, name = "Lorekeeper Lydros" }
	-- Lorekeeper Mykos: from the facts, carried onto this picture; not seen in game yet
	local LOREKEEPER_MYKOS = { x = 0.8004, y = 0.1139, floor = 3, name = "Lorekeeper Mykos" }
	-- The Prince's Chest (loot): to check in game: the facts set it beside Prince Tortheldrin's portrait; a best guess
	local THE_PRINCES_CHEST = { x = 0.5963, y = 0.2531, floor = 3, act = "loot", name = "The Prince's Chest", item = 18336, itemName = "Gauntlet of Gordok Might" }
	ns.AmendInstance("DireMaulWest", { questPatches = {
		[7461] = { startInside = SHENDRALAR_ANCIENT, endInside = SHENDRALAR_ANCIENT },
		[7506] = { endInside = LOREKEEPER_JAVON },
		[7504] = { endInside = LOREKEEPER_JAVON },
		[7505] = { endInside = LOREKEEPER_JAVON },
		[7500] = { endInside = LOREKEEPER_KILDRATH },
		[7498] = { endInside = LOREKEEPER_KILDRATH },
		[7499] = { endInside = LOREKEEPER_KILDRATH },
		[7463] = { startInside = LOREKEEPER_LYDROS, endInside = LOREKEEPER_LYDROS },
		[7483] = { startInside = LOREKEEPER_LYDROS, endInside = LOREKEEPER_LYDROS },
		[7484] = { startInside = LOREKEEPER_LYDROS, endInside = LOREKEEPER_LYDROS },
		[7485] = { startInside = LOREKEEPER_LYDROS, endInside = LOREKEEPER_LYDROS },
		[7503] = { endInside = LOREKEEPER_MYKOS },
		[7501] = { endInside = LOREKEEPER_MYKOS },
		[7502] = { endInside = LOREKEEPER_MYKOS },
		[7703] = { objectivesInside = { THE_PRINCES_CHEST } },
	} })
end

do
	-- Ardin Grassman: the owner's spot, in game (2026-11-11)
	local ARDIN_GRASSMAN = { x = 0.327, y = 0.739, floor = 1, name = "Ardin Grassman" }
	-- Daewyn Songblade: to check in game: the facts set it beside Highland Horror's portrait; a best guess
	local DAEWYN_SONGBLADE = { x = 0.074, y = 0.497, floor = 1, name = "Daewyn Songblade" }
	ns.AmendInstance("ExcavationSiteWetlands", { questPatches = {
		[95647] = { endInside = ARDIN_GRASSMAN },
		[95809] = { startInside = ARDIN_GRASSMAN },
		[95772] = { endInside = DAEWYN_SONGBLADE },
		[95795] = { startInside = DAEWYN_SONGBLADE },
	} })
end

do
	-- The Sparklematic 5200: where the owner circled it on the whole map in game (2026-11-12, their picture of the whole map:
	-- 1214.5, 506.5 of its 2000 x 1329, the picture laid on this map by its features, 1.98 to one), in the Clean Zone's
	-- passage south-west of the Hall of Gears; on the Hall of Gears' floor, where that passage is drawn, carried by the
	-- floor's fit (about 6 pixels' error)
	local THE_SPARKLEMATIC_5200 = { x = 0.3964, y = 0.6731, floor = 2, name = "The Sparklematic 5200", whole = { x = 0.6076, y = 0.3798 } }
	-- Once The Sparklematic 5200! is done, the machine keeps the game's repeatable turn-in mark (the owner's call of
	-- 2026-11-12): it cleans another Grime-Encrusted Object (9308, what 2951 and its repeatable step take, by the quest
	-- data) as often as the player brings one; More Sparklematic Action itself stays off the quest lists
	local SPARKLEMATIC_AGAIN = { spot = THE_SPARKLEMATIC_5200, item = 9308, itemName = "Grime-Encrusted Object" }
	-- Thermaplugg's Safe (loot): from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its
	-- floor's fit (0.2206, 0.277, just past Tinkers' Court's rim there) and set onto the court's floor, by its place on the floor's
	-- picture (a best guess)
	local THERMAPLUGGS_SAFE = { x = 0.354, y = 0.177, floor = 5, act = "loot", name = "Thermaplugg's Safe", item = 9153, itemName = "Rig Blueprints", whole = { x = 0.203, y = 0.293 } }
	-- Kernobee: a best guess, the owner's (2026-11-12): the Dormitory's small rooms on its east side, where they circled it on the
	-- second floor's map (they have not found him yet); on the whole map, carried by its floor's fit
	local KERNOBEE = { x = 0.845, y = 0.722, floor = 3, name = "Kernobee", whole = { x = 0.7324, y = 0.4304 } }
	-- Data Rescue's four Matrix Punchographs, one step each.
	-- 3005-A, in the tunnels outside: the Train Depot's big oval, just north of its middle ramp, where the owner used it (2026-11-11,
	-- Dun Morogh's map shown: 21.7, 32.4; the spawn data has four of them there, two by this spot and two at the oval's north end)
	local PUNCHOGRAPH_A = { x = 0.5117, y = 0.3448, wayIn = "GnomereganApproach", act = "use", name = "Matrix Punchograph 3005-A",
		input = { item = 9279, itemName = "White Punch Card", short = "QUESTMAP_CARD_WHITE" },
		output = { item = 9280, itemName = "Yellow Punch Card", short = "QUESTMAP_CARD_YELLOW" }, icon = 134393,
		doneWith = { 9280, 9282, 9281, 9316 }, note = "QUESTMAP_NOTE_INPUT_DROPS" }
	-- 3005-B, in the Dormitory by the way from the Clean Zone: a best guess (the spawn data has no place inside a dungeon); on the whole
	-- map, carried by its floor's fit
	local PUNCHOGRAPH_B = { x = 0.72, y = 0.70, floor = 3, act = "use", name = "Matrix Punchograph 3005-B",
		input = { item = 9280, itemName = "Yellow Punch Card", short = "QUESTMAP_CARD_YELLOW" },
		output = { item = 9282, itemName = "Blue Punch Card", short = "QUESTMAP_CARD_BLUE" }, icon = 134394,
		doneWith = { 9282, 9281, 9316 }, whole = { x = 0.649, y = 0.4176 } }
	-- 3005-C, in Launch Bay by Electrocutioner 6000's platform: a best guess; on the whole map, carried by its floor's fit
	local PUNCHOGRAPH_C = { x = 0.29, y = 0.66, floor = 3, act = "use", name = "Matrix Punchograph 3005-C",
		input = { item = 9282, itemName = "Blue Punch Card", short = "QUESTMAP_CARD_BLUE" },
		output = { item = 9281, itemName = "Red Punch Card", short = "QUESTMAP_CARD_RED" }, icon = 134390,
		doneWith = { 9281, 9316 }, whole = { x = 0.3628, y = 0.3958 } }
	-- 3005-D, in the Engineering Labs' lower level, on its west side: a best guess; on the whole map, carried by its floor's fit
	local PUNCHOGRAPH_D = { x = 0.63, y = 0.775, floor = 5, act = "use", name = "Matrix Punchograph 3005-D",
		input = { item = 9281, itemName = "Red Punch Card", short = "QUESTMAP_CARD_RED" },
		output = { item = 9316, itemName = "Prismatic Punch Card", short = "QUESTMAP_CARD_PRISMATIC" }, icon = 134392,
		doneWith = { 9316 }, whole = { x = 0.4305, y = 0.7684 } }
	ns.AmendInstance("Gnomeregan", { questPatches = {
		[2951] = { startInside = THE_SPARKLEMATIC_5200, endInside = THE_SPARKLEMATIC_5200, repeatInside = SPARKLEMATIC_AGAIN },
		[2945] = { endInside = THE_SPARKLEMATIC_5200 },
		[2947] = { startInside = THE_SPARKLEMATIC_5200 },
		[2949] = { startInside = THE_SPARKLEMATIC_5200 },
		[2841] = { objectivesInside = { THERMAPLUGGS_SAFE } },
		[2904] = { startInside = KERNOBEE },
		[2930] = { objectivesInside = { PUNCHOGRAPH_A, PUNCHOGRAPH_B, PUNCHOGRAPH_C, PUNCHOGRAPH_D } },
	} })
end

do
	-- Celebras the Redeemed: from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local CELEBRAS_THE_REDEEMED = { x = 0.2445, y = 0.1428, floor = 3, name = "Celebras the Redeemed", whole = { x = 0.1902, y = 0.3349 } }
	ns.AmendInstance("Maraudon", { questPatches = {
		[7044] = { endInside = CELEBRAS_THE_REDEEMED },
		[7046] = { startInside = CELEBRAS_THE_REDEEMED, endInside = CELEBRAS_THE_REDEEMED },
	} })
end

do
	-- Maur Grimtotem: to check in game: the facts set it beside Oggleflint's portrait; a best guess
	local MAUR_GRIMTOTEM = { x = 0.581, y = 0.381, floor = 1, name = "Maur Grimtotem" }
	ns.AmendInstance("RagefireChasm", { questPatches = {
		[5724] = { startInside = MAUR_GRIMTOTEM },
		[5722] = { endInside = MAUR_GRIMTOTEM },
	} })
end

do
	-- Belnistrasz: from the facts, carried onto this picture; not seen in game yet
	local BELNISTRASZ = { x = 0.7735, y = 0.1518, floor = 1, name = "Belnistrasz" }
	-- Belnistrasz's Brazier: from the facts, carried onto this picture; not seen in game yet
	local BELNISTRASZS_BRAZIER = { x = 0.4681, y = 0.2227, floor = 1, name = "Belnistrasz's Brazier" }
	ns.AmendInstance("RazorfenDowns", { questPatches = {
		[3525] = { startInside = BELNISTRASZ, endInside = BELNISTRASZS_BRAZIER },
		[3523] = { startInside = BELNISTRASZ, endInside = BELNISTRASZ },
	} })
end

do
	-- Heralath Fallowbrook: from the facts, carried onto this picture; not seen in game yet
	local HERALATH_FALLOWBROOK = { x = 0.364, y = 0.324, floor = 1, name = "Heralath Fallowbrook" }
	-- Willix the Importer: from the facts, carried onto this picture; not seen in game yet
	local WILLIX_THE_IMPORTER = { x = 0.364, y = 0.324, floor = 1, name = "Willix the Importer" }
	ns.AmendInstance("RazorfenKraul", { questPatches = {
		[1142] = { startInside = HERALATH_FALLOWBROOK },
		[1144] = { startInside = WILLIX_THE_IMPORTER, endInside = WILLIX_THE_IMPORTER },
	} })
end

do
	-- Vorrel Sengutz: to check in game: the facts set it beside Interrogator Vishas's portrait; a best guess
	local VORREL_SENGUTZ = { x = 0.722, y = 0.574, floor = 1, name = "Vorrel Sengutz" }
	ns.AmendInstance("ScarletMonasteryGraveyard", { questPatches = {
		[1051] = { startInside = VORREL_SENGUTZ },
	} })
end

do
	-- Beginnings of the Undead Threat (loot): from the facts, carried onto this picture; not seen in game yet
	local BEGINNINGS_OF_THE_UNDEAD_THREAT = { x = 0.454, y = 0.322, floor = 1, act = "loot", name = "Beginnings of the Undead Threat", item = 5861, itemName = "Beginnings of the Undead Threat" }
	-- Compendium of the Fallen (loot): from the facts, carried onto this picture; not seen in game yet
	local COMPENDIUM_OF_THE_FALLEN = { x = 0.822, y = 0.14, floor = 1, act = "loot", name = "Compendium of the Fallen", item = 5535, itemName = "Compendium of the Fallen" }
	-- Mythology of the Titans (loot): from the facts, carried onto this picture; not seen in game yet
	local MYTHOLOGY_OF_THE_TITANS = { x = 0.593, y = 0.122, floor = 1, act = "loot", name = "Mythology of the Titans", item = 5536, itemName = "Mythology of the Titans" }
	ns.AmendInstance("ScarletMonasteryLibrary", { questPatches = {
		[1160] = { objectivesInside = { BEGINNINGS_OF_THE_UNDEAD_THREAT } },
		[1049] = { objectivesInside = { COMPENDIUM_OF_THE_FALLEN } },
		[1050] = { objectivesInside = { MYTHOLOGY_OF_THE_TITANS } },
	} })
end

do
	-- Deathstalker Vincent: from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local DEATHSTALKER_VINCENT = { x = 0.558, y = 0.622, floor = 2, name = "Deathstalker Vincent", whole = { x = 0.7233, y = 0.6704 } }
	-- Jordan's Hammer (loot): to check in game: the facts set it beside Fel Steed / Shadow Charger's portrait; a best guess; on the whole map, carried by its floor's fit
	local JORDANS_HAMMER = { x = 0.3405, y = 0.5925, floor = 2, act = "loot", name = "Jordan's Hammer", item = 6895, itemName = "Jordan's Smithing Hammer", article = false, whole = { x = 0.525, y = 0.6433 } }
	-- The Book of Ur (loot): to check in game: the facts set it beside Arugal's Voidwalker's portrait; a best guess; on the whole map, carried by its floor's
	-- fit, then set 7 px west (the review of 2026-11-12), so that kept clear of the pins it goes west, onto the light arc beside the Voidwalker's pin,
	-- not east over Fenrus's and on past it onto a wall
	local THE_BOOK_OF_UR = { x = 0.482, y = 0.7515, floor = 6, act = "loot", name = "The Book of Ur", item = 6283, itemName = "The Book of Ur", article = false, whole = { x = 0.658, y = 0.3512 } }
	ns.AmendInstance("ShadowfangKeep", { questPatches = {
		[1098] = { endInside = DEATHSTALKER_VINCENT },
		[1654] = { objectivesInside = { JORDANS_HAMMER } },
		[1013] = { objectivesInside = { THE_BOOK_OF_UR } },
	} })
end

do
	-- Malor's Strongbox (loot): from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local MALORS_STRONGBOX = { x = 0.3094, y = 0.4074, floor = 2, act = "loot", name = "Malor's Strongbox", item = 12845, itemName = "Medallion of Faith", whole = { x = 0.4132, y = 0.6921 } }
	-- Scarlet Archive (use): to check in game: the facts set it beside Archivist Galford's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCARLET_ARCHIVE = { x = 0.2889, y = 0.7829, floor = 2, act = "use", name = "Scarlet Archive", whole = { x = 0.4011, y = 0.9142 } }
	-- Unfinished Painting (loot): to check in game: the facts set it beside Archivist Galford's portrait; a best guess; on the whole map, carried by its floor's fit
	local UNFINISHED_PAINTING = { x = 0.2889, y = 0.7829, floor = 2, act = "loot", name = "Unfinished Painting", item = 14679, itemName = "Of Love and Family", quoted = true, whole = { x = 0.4011, y = 0.9142 } }
	-- Aurius: from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local AURIUS = { x = 0.6766, y = 0.7279, floor = 3, name = "Aurius", whole = { x = 0.8453, y = 0.6127 } }
	-- Menethil's Gift: to check in game: the facts set it beside Baron Rivendare's portrait; a best guess; on the whole map, carried by its floor's fit,
	-- then set 3 px west, just west of his pin's center (the review of 2026-11-12), so that kept clear of the pins it goes west, onto the walkway round his
	-- platform, not east between his pin and Ramstein's, too close together for it
	local MENETHILS_GIFT = { x = 0.3922, y = 0.2282, floor = 3, name = "Menethil's Gift", whole = { x = 0.6, y = 0.1878 } }
	-- Scourge Data (loot): to check in game: the facts set it beside Maleki the Pallid's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCOURGE_DATA = { x = 0.6831, y = 0.1862, floor = 3, act = "loot", name = "Scourge Data", item = 13176, itemName = "Scourge Data", whole = { x = 0.8508, y = 0.152 } }
	-- Scourge Data (loot): to check in game: the facts set it beside Baroness Anastari's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCOURGE_DATA_2 = { x = 0.7725, y = 0.4653, floor = 3, act = "loot", name = "Scourge Data", item = 13176, itemName = "Scourge Data", whole = { x = 0.9269, y = 0.3894 } }
	-- Scourge Data (loot): to check in game: the facts set it beside Nerub'enkan's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCOURGE_DATA_3 = { x = 0.5499, y = 0.4898, floor = 3, act = "loot", name = "Scourge Data", item = 13176, itemName = "Scourge Data", whole = { x = 0.7374, y = 0.4102 } }
	ns.AmendInstance("StratholmeMainGate", { questPatches = {
		[5122] = { startInside = AURIUS, endInside = AURIUS, objectivesInside = { MALORS_STRONGBOX } },
		[5251] = { objectivesInside = { SCARLET_ARCHIVE } },
		[5848] = { objectivesInside = { UNFINISHED_PAINTING } },
		[5125] = { startInside = AURIUS, endInside = AURIUS },
		[5463] = { endInside = MENETHILS_GIFT },
		[5213] = { objectivesInside = { SCOURGE_DATA, SCOURGE_DATA_2, SCOURGE_DATA_3 } },
	} })
end

do
	-- Malor's Strongbox (loot): from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local MALORS_STRONGBOX = { x = 0.3094, y = 0.4074, floor = 2, act = "loot", name = "Malor's Strongbox", item = 12845, itemName = "Medallion of Faith", whole = { x = 0.4132, y = 0.6921 } }
	-- Unfinished Painting (loot): to check in game: the facts set it beside Archivist Galford's portrait; a best guess; on the whole map, carried by its floor's fit
	local UNFINISHED_PAINTING = { x = 0.2889, y = 0.7829, floor = 2, act = "loot", name = "Unfinished Painting", item = 14679, itemName = "Of Love and Family", quoted = true, whole = { x = 0.4011, y = 0.9142 } }
	-- Aurius: from the facts, carried onto this picture; not seen in game yet; on the whole map, carried by its floor's fit
	local AURIUS = { x = 0.6766, y = 0.7279, floor = 3, name = "Aurius", whole = { x = 0.8453, y = 0.6127 } }
	-- Menethil's Gift: to check in game: the facts set it beside Baron Rivendare's portrait; a best guess; on the whole map, carried by its floor's fit,
	-- then set 3 px west, just west of his pin's center (the review of 2026-11-12), so that kept clear of the pins it goes west, onto the walkway round his
	-- platform, not east between his pin and Ramstein's, too close together for it
	local MENETHILS_GIFT = { x = 0.3922, y = 0.2282, floor = 3, name = "Menethil's Gift", whole = { x = 0.6, y = 0.1878 } }
	-- Scourge Data (loot): to check in game: the facts set it beside Maleki the Pallid's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCOURGE_DATA = { x = 0.6831, y = 0.1862, floor = 3, act = "loot", name = "Scourge Data", item = 13176, itemName = "Scourge Data", whole = { x = 0.8508, y = 0.152 } }
	-- Scourge Data (loot): to check in game: the facts set it beside Baroness Anastari's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCOURGE_DATA_2 = { x = 0.7725, y = 0.4653, floor = 3, act = "loot", name = "Scourge Data", item = 13176, itemName = "Scourge Data", whole = { x = 0.9269, y = 0.3894 } }
	-- Scourge Data (loot): to check in game: the facts set it beside Nerub'enkan's portrait; a best guess; on the whole map, carried by its floor's fit
	local SCOURGE_DATA_3 = { x = 0.5499, y = 0.4898, floor = 3, act = "loot", name = "Scourge Data", item = 13176, itemName = "Scourge Data", whole = { x = 0.7374, y = 0.4102 } }
	ns.AmendInstance("StratholmeServiceGate", { questPatches = {
		[5122] = { startInside = AURIUS, endInside = AURIUS, objectivesInside = { MALORS_STRONGBOX } },
		[5848] = { objectivesInside = { UNFINISHED_PAINTING } },
		[5125] = { startInside = AURIUS, endInside = AURIUS },
		[5463] = { endInside = MENETHILS_GIFT },
		[5213] = { objectivesInside = { SCOURGE_DATA, SCOURGE_DATA_2, SCOURGE_DATA_3 } },
	} })
end

do
	-- Altar of Hakkar: from the facts, carried onto this picture; not seen in game yet
	local ALTAR_OF_HAKKAR = { x = 0.501, y = 0.3606, floor = 1, name = "Altar of Hakkar" }
	-- Idol of Hakkar: from the facts, carried onto this picture; not seen in game yet
	local IDOL_OF_HAKKAR = { x = 0.501, y = 0.4789, floor = 1, name = "Idol of Hakkar" }
	-- Essence Font: to check in game: the facts set it beside Shade of Eranikus's portrait; a best guess
	local ESSENCE_FONT = { x = 0.7026, y = 0.8382, floor = 1, name = "Essence Font" }
	ns.AmendInstance("TempleOfAtalHakkar", { questPatches = {
		[3446] = { endInside = ALTAR_OF_HAKKAR },
		[3447] = { endInside = IDOL_OF_HAKKAR },
		[3373] = { endInside = ESSENCE_FONT },
	} })
end

do
	-- a place to explore (explore): to check in game: the facts set it beside Ironaya's portrait; a best guess
	local HIDDEN_CHAMBER_PLACE = { x = 0.3433, y = 0.728, floor = 1, act = "explore" }
	-- Baelog: to check in game: the facts set it beside The Lost Dwarves's portrait; a best guess
	local BAELOG = { x = 0.6098, y = 0.9327, floor = 1, name = "Baelog" }
	-- Conspicuous Urn (loot): to check in game: the facts set it beside The Lost Dwarves's portrait; a best guess
	local CONSPICUOUS_URN = { x = 0.6098, y = 0.9327, floor = 1, act = "loot", name = "Conspicuous Urn", item = 7671, itemName = "Shattered Necklace Topaz" }
	-- Remains of a Paladin: to check in game: the facts set it beside Revelosh's portrait; a best guess
	local REMAINS_OF_A_PALADIN = { x = 0.5324, y = 0.6805, floor = 1, name = "Remains of a Paladin" }
	-- Shadowforge Cache (loot): to check in game: the facts set it beside Grimlok's portrait; a best guess
	local SHADOWFORGE_CACHE = { x = 0.2126, y = 0.2981, floor = 1, act = "loot", name = "Shadowforge Cache", item = 7669, itemName = "Shattered Necklace Ruby" }
	-- Tablet of Will (loot): to check in game: the facts set it beside Grimlok's portrait; a best guess
	local TABLET_OF_WILL = { x = 0.2126, y = 0.2981, floor = 1, act = "loot", name = "Tablet of Will", item = 5824, itemName = "Tablet of Will" }
	-- The Discs of Norgannon: from the facts, carried onto this picture; not seen in game yet
	local THE_DISCS_OF_NORGANNON = { x = 0.5, y = 0.3305, floor = 2, name = "The Discs of Norgannon" }
	ns.AmendInstance("Uldaman", { questPatches = {
		[2240] = { startInside = BAELOG, objectivesInside = { HIDDEN_CHAMBER_PLACE } },
		[2398] = { endInside = BAELOG },
		[2201] = { startInside = REMAINS_OF_A_PALADIN, objectivesInside = { CONSPICUOUS_URN, SHADOWFORGE_CACHE } },
		[2339] = { objectivesInside = { CONSPICUOUS_URN, SHADOWFORGE_CACHE } },
		[2200] = { endInside = REMAINS_OF_A_PALADIN },
		[2284] = { endInside = REMAINS_OF_A_PALADIN },
		[2318] = { startInside = REMAINS_OF_A_PALADIN },
		[1139] = { objectivesInside = { TABLET_OF_WILL } },
		[2278] = { startInside = THE_DISCS_OF_NORGANNON, endInside = THE_DISCS_OF_NORGANNON },
		[2279] = { startInside = THE_DISCS_OF_NORGANNON },
		[2280] = { startInside = THE_DISCS_OF_NORGANNON },
	} })
end
