local _, ns = ...

--[[
	Each boss's loot, as foreverchanges.pro's loot tables list it (2026-10-11): the "Map, bosses
	and loot" section of its page for each of the 16 dungeons, read in the browser.

	The player chose the site as the one source for loot. A boss here lists exactly what the
	site lists for it, in the journal's order, and the dungeon's trash what the site lists for
	its trash. What other sources gave and the site does not (recipes Alex Atlas Loot's players
	saw elsewhere, old world drops, Scorn and Sever) is left out, with two kinds of exceptions:

	  QUEST_ITEMS    items the journal's quests need, which the site lists among quest items,
	                 not loot: they stay on the boss that drops them
	  DROP_BOSSES    creatures the site's page does not list at all: removed from the dungeon

	Each dungeon's own data (Data/Instances) may list more; the names, slots and notes on the
	rows that remain are kept, and this file has the last word. The site
	also lists two quest objects in Shadowfang Keep among its bosses (Jordan's Smithing Hammer
	and The Book of Ur); the journal has no such bosses.

	Loads after every file that adds loot, and before ItemNames.lua, which names the rows.

	Since 0.40.1 (the owner's calls of 2026-11-20, on the loot audit of 2026-11-19) a dungeon's lists here also take:
	  Recipes = { ... }  its Recipes entry (recipes = true, after its Trash: ns.PlaceBoss), made here if its data has
	                     none, as Trash = { ... } makes its Trash entry
	  NotSeen(id)        in place of an id: a row kept though no drop of it is recorded there yet ("Just cause we don't
	                     see it in a recording doesn't mean it doesn't drop"); its tooltip says so (UI/LootPanel.lua)
	  AnyBoss(id)        in place of an id, on a Recipes list: a recipe two or more of the dungeon's bosses drop, and
	                     its trash does not (Forever's shared recipes); named "Any boss" where the trash would be
	                     (offBosses = "bosses": ns.OffBossesText). AnyBoss(NotSeen(id)) gives a row both marks. A
	                     shared recipe one boss or rare alone drops there is his instead: on his list, and on the
	                     Recipes list as { itemID = id, droppedBy = "<his name>" }, as a boss's own recipe is (the
	                     owner's call of 2026-11-20).
]]

-- A row's marks, given in a list in place of its id (above): { itemID = id, notSeen = true, offBosses = "bosses" }.
local function Mark(entry, field, value)
	local row = type(entry) == "table" and entry or { itemID = entry }
	row[field] = value
	return row
end

local function NotSeen(entry)
	return Mark(entry, "notSeen", true)
end

local function AnyBoss(entry)
	return Mark(entry, "offBosses", "bosses")
end

-- Not here: the quest items the audit of 2026-11-10 found dropping from trash (in Blackfathom Deeps, The
-- Deadmines, Wailing Caverns, Ruins of Lordaeron and the Excavation Site). They stay off the trash lists, the
-- owner's call.
local QUEST_ITEMS = {
	[14540] = true, -- Taragaman the Hungerer's Heart (Ragefire Chasm)
	[9738] = true, [9739] = true, [9740] = true, [9741] = true, -- the Gems of the Fanglords (Wailing Caverns)
	[5442] = true, -- Head of Arugal (Shadowfang Keep)
	[5881] = true, -- Head of Kelris (Blackfathom Deeps; seen dropping in a recorded run)
	-- The Stockade, seen dropping in a recorded run (2026-10-12): the ringleaders' heads and hand. (The Red Wool
	-- Bandana, 2909, which The Color of Blood asks for, was here until 0.40.1: the prisoners drop it, and quest items
	-- that drop off trash stay off the lists, the owner's call.)
	[3630] = true, [3640] = true, [3628] = true, [2926] = true,
	[7146] = true, -- The Scarlet Key (Arcanist Doan, Scarlet Monastery: Library)
	[270866] = true, -- Titan Relic, the Horde's (Relic Guardian, Excavation Site)
	[280438] = true, -- Abominable Head (The Baron, Ruins of Lordaeron)
	[275443] = true, -- Highly Toxic Strain (Witherfang, Ruins of Lordaeron)
	-- The Deadmines, seen dropping in the owner's recording of 2026-11-07: Head of VanCleef (Edwin
	-- VanCleef, for The Defias Brotherhood) and Gnoam Sprecklesprocket (Sneed's Shredder, for Underground
	-- Assault). (Whitestone Oak Lumber, a Goblin Woodcarver's, for the paladins' quests, was here until 0.40.1: it
	-- drops off trash, and such quest items stay off the lists, the owner's call.)
	[3637] = true, [7365] = true,
	-- Head of the Baron (The Baron, Ruins of Lordaeron, for the Alliance's Abominable Creatures; seen in the
	-- owner's run of 2026-11-07)
	[268518] = true,
	[251961] = true, -- Arcane Mote (the Shade of the Archmage, City of Dalaran, for Heart of Disruption)
	-- Not here, and on no boss: the Fel Infused Blossom (251983), for the Alliance's A Green Sample in City of
	-- Dalaran. It is a plant looted from the ground near the Fel Ancient, not his drop (the owner, 2026-11-11).
	-- Two recordings credit it to him (Skep's of 2026-10-19 22-41, line 36, and the owner's of 2026-11-11, line
	-- 29): the Record tab then filed an object's loot opened soon after a kill under that boss (fixed in
	-- Core/Recorder.lua, which now files it as "object:<id>"). The quest's note says where it grows.
}

local DROP_BOSSES = {
	ScarletMonasteryGraveyard = { "Scorn" },
	ShadowfangKeep = { "Sever" },
}

local LOOT = {
	CityOfDalaran = {
		["Atrexis the Grave Knight"] = { 273036, 273032, 273033 },
		["Lyn the Ignored"] = { 273054, 273053, 273055 },
		["Arcane Anomaly"] = { 273031, 273034, 273035 },
		["Arcanic Enigma"] = { 273045, 273044, 273043 },
		["Unstable Sentinel"] = { 273046, 273048, 273047, 273099 },
		["Mana Devourer"] = { 273040, 273042, 273041 },
		["Fel Ancient"] = { 273039, 273038, 273037 },
		["Shade of the Archmage"] = { 273052, 273051, 273049, 273103 },
		-- The site's two, and the Violet Sorcerer's Sandals: seen dropping from the trash before Lyn
		-- (creature 255066) in both of Skep's recorded runs (2026-10-19), and from a Fragmented Sentry (246664)
		-- in the owner's run of 2026-11-11. The Violet Sorcerer's Leggings and Wraps: on the site's trash list
		-- since November, and in the client's item data. The rest the owner's run saw from the trash is left out:
		-- old world drops, greens and whites, and Pattern: Guardian Armor (4299), an old world recipe, as the other
		-- dungeons' trash recipes are.
		-- Then seven more blues, the drop data of 2026-11-19: every dropper one of the city's own creatures (the
		-- Construct's Grips off the Fragmented Sentry alone).
		Trash = { 276160, 276158, 286987, 286988, 286989, 286990, 286991, { itemID = 286992, droppedBy = "Fragmented Sentry" }, 286993, 286994, 286995, 286996 },
		-- The Shade's Blueprint: Arcane Salvager is an enchanting recipe, and the Unstable Sentinel's blueprint his own
		-- (the owner's calls of 2026-11-20); both stay on their bosses too.
		Recipes = {
			{ itemID = 273099, droppedBy = "Unstable Sentinel" }, -- Blueprint: Spinning Wheel
			{ itemID = 273103, droppedBy = "Shade of the Archmage" }, -- Blueprint: Arcane Salvager
		},
	},
	HallOfThanes = {
		["Faldrim Anvilmar"] = { 270227, 271096, 271097 },
		["Magmatus"] = { 270230, 270231, 271095 },
		["Plunder"] = { 270228, 270229, 271098 },
		["Durgen Dirgehammer"] = { 270256, 270260, 270261, 274286 },
	},
	RuinsOfLordaeron = {
		["The Baron"] = { 271204, 271205, 271206 },
		["Witherfang"] = { 271201, 271202, 271203 },
		["The Abandoned"] = { 271207, 271208, 271216 },
		["Bjork"] = { 271209, 271210, 271217 },
		-- Blueprint: Arcane Salvager: the drop data shows no drop off him in 5,569 kills (only Charlga Razorflank and the
		-- Shade of the Archmage), so it is marked, not removed (the owner's call of 2026-11-20).
		["Rath'mael"] = { 271213, 271214, 271215, 273085, NotSeen(273103) },
		["Viktor the Vile"] = { 271211, 271212, 271218 },
		-- The Captain's recipes (Plans: Veteran's and Crusader's Chain Shirt, Pattern: Wisdom's Leather Armor, the three
		-- Filigreed Gowns) are from Forever's shared groups, but he alone drops them here: on his page and the Recipes
		-- page, which names him (the owner's call of 2026-11-20).
		["Lordaeron Captain"] = { 6641, 6642, 251340, 251344, 252776, 253904, 253908, 253910 },
		-- 286977 Sword of the Fallen: not on the site's dungeon page; a zone drop seen in game. 286981 Death
		-- Bindings: not on the site's page either; seen dropping in the owner's run of 2026-11-07.
		Trash = { 286980, 286979, 286978, 286977, 286981 },
		-- Forever's shared recipes the Captain alone drops here (one each in 108 kills in the drop data, 2026-11-19; on
		-- his page too), the Fermenter (Rath'mael's own, on his page too) and the Arcane Salvager (an enchanting recipe:
		-- it stays, marked).
		Recipes = {
			{ itemID = 251340, droppedBy = "Lordaeron Captain" }, -- Plans: Veteran's Chain Shirt
			{ itemID = 251344, droppedBy = "Lordaeron Captain" }, -- Plans: Crusader's Chain Shirt
			{ itemID = 252776, droppedBy = "Lordaeron Captain" }, -- Pattern: Wisdom's Leather Armor
			{ itemID = 253904, droppedBy = "Lordaeron Captain" }, -- Pattern: Filigreed Silky Gown
			{ itemID = 253908, droppedBy = "Lordaeron Captain" }, -- Pattern: Filigreed Shadow Gown
			{ itemID = 253910, droppedBy = "Lordaeron Captain" }, -- Pattern: Filigreed Pearly Gown
			{ itemID = 273085, droppedBy = "Rath'mael" }, -- Blueprint: Fermenter
			NotSeen(273103), -- Blueprint: Arcane Salvager
		},
	},
	ExcavationSiteWetlands = {
		["Saltspine"] = { 273022, 273023, 273024 },
		["Shadetooth"] = { 273025, 273026, 273027, 273106 },
		["Highland Horror"] = { 270180 },
		["Relic Guardian"] = { 273028, 273030, 270865, 273029, 273097 },
		-- The dungeon's own creatures' blues (the drop data, 2026-11-19: 24 to 45 drops each, off 9 to 13 of its creature
		-- types), and the Thicket Raptor quest items stay off (they drop off the trash).
		Trash = { 286982, 286983, 286984, 286985, 286986, 287068 },
		-- The two bosses' own blueprints, here too (the owner's call of 2026-11-20); no enchanting recipe drops here.
		Recipes = {
			273106, -- Blueprint: Greenhouse (Shadetooth)
			273097, -- Blueprint: Rock Garden (Relic Guardian)
		},
	},
	RagefireChasm = {
		["Oggleflint"] = { 272999, 272996, 272998 },
		["Taragaman the Hungerer"] = { 14149, 14148, 14145 },
		["Jergosh the Invoker"] = { 14150, 14147, 14151 },
		["Bazzalan"] = { 273003, 273005, 273007 },
		-- Forever's chest recipes (the drop data of 2026-11-19, about 0.3 to 0.9% each, none off the trash): all four bosses
		-- drop all 17, so they are on the Recipes page. No recipe is the dungeon's own, and the journal listed no
		-- enchanting formula here before 0.40.1, so the world's formulas that drop here too are not listed (the owner's
		-- call of 2026-11-20: only the formulas listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251340), -- Plans: Veteran's Chain Shirt
			AnyBoss(251341), -- Plans: Guard's Chain Shirt
			AnyBoss(251342), -- Plans: Protector's Chain Shirt
			AnyBoss(251343), -- Plans: Acolyte's Chain Shirt
			AnyBoss(251344), -- Plans: Crusader's Chain Shirt
			AnyBoss(252771), -- Pattern: Brawler's Leather Armor
			AnyBoss(252772), -- Pattern: Trapper's Leather Armor
			AnyBoss(252773), -- Pattern: Defender's Leather Armor
			AnyBoss(252774), -- Pattern: Totemic Leather Armor
			AnyBoss(252775), -- Pattern: Stormrider's Leather Armor
			AnyBoss(252776), -- Pattern: Wisdom's Leather Armor
			AnyBoss(253902), -- Pattern: Filigreed Pristine Gown
			AnyBoss(253904), -- Pattern: Filigreed Silky Gown
			AnyBoss(253906), -- Pattern: Filigreed Flame Gown
			AnyBoss(253908), -- Pattern: Filigreed Shadow Gown
			AnyBoss(253910), -- Pattern: Filigreed Pearly Gown
			AnyBoss(253912), -- Pattern: Filigreed Shining Gown
		},
	},
	WailingCaverns = {
		-- Pattern: Trapper's Leather Gloves and Hood: the Merchant's Favor vendors sell them, and no drop of either is
		-- recorded yet: kept, marked (the owner's call of 2026-11-20).
		["Lord Cobrahn"] = { 6460, 10410, 6465, NotSeen(252778) },
		-- Since 0.40.1 (the owner's calls of 2026-11-20) the Forever recipes seen dropping in recorded runs (Pattern:
		-- Filigreed Silky, Shining, Pearly and Shadow Gown, Pattern: Stormrider's Leather Armor and the two Filigreed
		-- Pristine and Shadow Leggings) are on the Recipes page: every boss drops a whole group, not one boss alone.
		["Lady Anacondra"] = { 10412, 5404, 6446, 273088, 273098 },
		["Kresh"] = { 13245, 6447, 273084, NotSeen(252778) },
		["Lord Pythas"] = { 6472, 6473, 273089 },
		["Skum"] = { 6449, 6448, 273137, NotSeen(252799) },
		["Lord Serpentis"] = { 6469, 5970, 10411, 6459, 273087 },
		["Verdan the Everliving"] = { 6630, 6631, 6629 },
		["Mutanus the Devourer"] = { 6461, 6627, 6463, 10441 },
		["Deviate Faerie Dragon"] = { 5243, 6632 },
		Trash = { 10413 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 1% each, none off the trash): Kresh,
		-- Lord Cobrahn, Lady Anacondra and the Deviate Faerie Dragon drop the chest group, Lord Pythas, Skum, Lord
		-- Serpentis, Verdan the Everliving and Mutanus the Devourer the leggings group. Then the two bosses' own
		-- blueprints (on their pages too) and the two vendor patterns kept on the bosses; the world's enchanting
		-- formulas that drop here too are not listed (the owner's call of 2026-11-20: only the formulas the journal
		-- listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251340), -- Plans: Veteran's Chain Shirt
			AnyBoss(251341), -- Plans: Guard's Chain Shirt
			AnyBoss(251342), -- Plans: Protector's Chain Shirt
			AnyBoss(251343), -- Plans: Acolyte's Chain Shirt
			AnyBoss(251344), -- Plans: Crusader's Chain Shirt
			AnyBoss(251345), -- Plans: Veteran's Chain Leggings
			AnyBoss(251346), -- Plans: Guard's Chain Leggings
			AnyBoss(251347), -- Plans: Protector's Chain Leggings
			AnyBoss(251348), -- Plans: Acolyte's Chain Leggings
			AnyBoss(251349), -- Plans: Crusader's Chain Leggings
			AnyBoss(252771), -- Pattern: Brawler's Leather Armor
			AnyBoss(252772), -- Pattern: Trapper's Leather Armor
			AnyBoss(252773), -- Pattern: Defender's Leather Armor
			AnyBoss(252774), -- Pattern: Totemic Leather Armor
			AnyBoss(252775), -- Pattern: Stormrider's Leather Armor
			AnyBoss(252776), -- Pattern: Wisdom's Leather Armor
			AnyBoss(252792), -- Pattern: Brawler's Leather Pants
			AnyBoss(252793), -- Pattern: Trapper's Leather Pants
			AnyBoss(252794), -- Pattern: Defender's Leather Pants
			AnyBoss(252795), -- Pattern: Totemic Leather Pants
			AnyBoss(252796), -- Pattern: Stormrider's Leather Pants
			AnyBoss(252797), -- Pattern: Wisdom's Leather Pants
			AnyBoss(253902), -- Pattern: Filigreed Pristine Gown
			AnyBoss(253904), -- Pattern: Filigreed Silky Gown
			AnyBoss(253906), -- Pattern: Filigreed Flame Gown
			AnyBoss(253908), -- Pattern: Filigreed Shadow Gown
			AnyBoss(253910), -- Pattern: Filigreed Pearly Gown
			AnyBoss(253912), -- Pattern: Filigreed Shining Gown
			AnyBoss(253938), -- Pattern: Filigreed Pristine Leggings
			AnyBoss(253940), -- Pattern: Filigreed Silky Leggings
			AnyBoss(253942), -- Pattern: Filigreed Flame Leggings
			AnyBoss(253944), -- Pattern: Filigreed Shadow Leggings
			AnyBoss(253946), -- Pattern: Filigreed Pearly Leggings
			AnyBoss(253948), -- Pattern: Filigreed Shining Leggings
			{ itemID = 273087, droppedBy = "Lord Serpentis" }, -- Blueprint: Journeyman Campfire
			{ itemID = 273098, droppedBy = "Lady Anacondra" }, -- Blueprint: Field Guide
			NotSeen(252778), -- Pattern: Trapper's Leather Gloves
			NotSeen(252799), -- Pattern: Trapper's Leather Hood
		},
	},
	TheDeadmines = {
		-- Plans: Acolyte's Gloves: the Merchant's Favor vendors sell it, and no drop of it is recorded yet: kept, marked
		-- (the owner's call of 2026-11-20). Since 0.40.1 the Forever recipes seen dropping in recorded runs on Rhahk'Zor,
		-- Captain Greenskin and Cookie are on the Recipes page: all of them but Edwin VanCleef drop the chest group.
		["Rhahk'Zor"] = { 872, 5187, 273289, NotSeen(251363) },
		["Miner Johnson"] = { 5443, 5444 },
		["Sneed"] = { 5194, 5195, 273293, 273092 },
		["Sneed's Shredder"] = { 1937, 2169, 285292 },
		["Gilnid"] = { 1156, 5199, 273297, 273086 },
		["Mr. Smite"] = { 7230, 5192, 5196, 284715 },
		["Captain Greenskin"] = { 5201, 10403, 5200 },
		-- Pattern: Filigreed Silky Leggings: seen dropping in the owner's recorded run (2026-11-08), a Forever recipe.
		-- He alone drops the leggings group here (the drop data of 2026-11-19), so the whole group is on his page and on
		-- the Recipes page, which names him (the owner's call of 2026-11-20).
		["Edwin VanCleef"] = {
			5193, 5202, 10399, 5191, 2874, 253940, 251345, 251346, 251347, 251348, 251349, 252792, 252793, 252794,
			252795, 252796, 252797, 253938, 253942, 253944, 253946, 253948,
		},
		["Cookie"] = { 5198, 5197, 8490, 273298, 273102 },
		-- Whitestone Oak Lumber (6994), a quest item the Goblin Woodcarvers drop, is not here since 0.40.1: quest items
		-- that drop off trash stay off the lists (the owner's call).
		Trash = { 8492, 1934, 10402, 1943, 1951, 10400, 10401, 1929, 1930, 1936, 1944, 1945, 1925 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 1% each, none off the trash): Edwin
		-- VanCleef alone drops the leggings group here (his, named), every other boss, Miner Johnson included, the chest
		-- group (any boss). Then the three bosses' own blueprints (on their pages too) and the Plans: Acolyte's Gloves
		-- kept on Rhahk'Zor; the world's enchanting formulas that drop here too are not listed (the owner's call of
		-- 2026-11-20: only the formulas the journal listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251340), -- Plans: Veteran's Chain Shirt
			AnyBoss(251341), -- Plans: Guard's Chain Shirt
			AnyBoss(251342), -- Plans: Protector's Chain Shirt
			AnyBoss(251343), -- Plans: Acolyte's Chain Shirt
			AnyBoss(251344), -- Plans: Crusader's Chain Shirt
			{ itemID = 251345, droppedBy = "Edwin VanCleef" }, -- Plans: Veteran's Chain Leggings
			{ itemID = 251346, droppedBy = "Edwin VanCleef" }, -- Plans: Guard's Chain Leggings
			{ itemID = 251347, droppedBy = "Edwin VanCleef" }, -- Plans: Protector's Chain Leggings
			{ itemID = 251348, droppedBy = "Edwin VanCleef" }, -- Plans: Acolyte's Chain Leggings
			{ itemID = 251349, droppedBy = "Edwin VanCleef" }, -- Plans: Crusader's Chain Leggings
			AnyBoss(252771), -- Pattern: Brawler's Leather Armor
			AnyBoss(252772), -- Pattern: Trapper's Leather Armor
			AnyBoss(252773), -- Pattern: Defender's Leather Armor
			AnyBoss(252774), -- Pattern: Totemic Leather Armor
			AnyBoss(252775), -- Pattern: Stormrider's Leather Armor
			AnyBoss(252776), -- Pattern: Wisdom's Leather Armor
			{ itemID = 252792, droppedBy = "Edwin VanCleef" }, -- Pattern: Brawler's Leather Pants
			{ itemID = 252793, droppedBy = "Edwin VanCleef" }, -- Pattern: Trapper's Leather Pants
			{ itemID = 252794, droppedBy = "Edwin VanCleef" }, -- Pattern: Defender's Leather Pants
			{ itemID = 252795, droppedBy = "Edwin VanCleef" }, -- Pattern: Totemic Leather Pants
			{ itemID = 252796, droppedBy = "Edwin VanCleef" }, -- Pattern: Stormrider's Leather Pants
			{ itemID = 252797, droppedBy = "Edwin VanCleef" }, -- Pattern: Wisdom's Leather Pants
			AnyBoss(253902), -- Pattern: Filigreed Pristine Gown
			AnyBoss(253904), -- Pattern: Filigreed Silky Gown
			AnyBoss(253906), -- Pattern: Filigreed Flame Gown
			AnyBoss(253908), -- Pattern: Filigreed Shadow Gown
			AnyBoss(253910), -- Pattern: Filigreed Pearly Gown
			AnyBoss(253912), -- Pattern: Filigreed Shining Gown
			{ itemID = 253938, droppedBy = "Edwin VanCleef" }, -- Pattern: Filigreed Pristine Leggings
			{ itemID = 253940, droppedBy = "Edwin VanCleef" }, -- Pattern: Filigreed Silky Leggings
			{ itemID = 253942, droppedBy = "Edwin VanCleef" }, -- Pattern: Filigreed Flame Leggings
			{ itemID = 253944, droppedBy = "Edwin VanCleef" }, -- Pattern: Filigreed Shadow Leggings
			{ itemID = 253946, droppedBy = "Edwin VanCleef" }, -- Pattern: Filigreed Pearly Leggings
			{ itemID = 253948, droppedBy = "Edwin VanCleef" }, -- Pattern: Filigreed Shining Leggings
			{ itemID = 273086, droppedBy = "Gilnid" }, -- Blueprint: Anvil
			{ itemID = 273092, droppedBy = "Sneed" }, -- Blueprint: Repair Bot
			{ itemID = 273102, droppedBy = "Cookie" }, -- Blueprint: Cookie's Feast
			NotSeen(251363), -- Plans: Acolyte's Gloves
		},
	},
	ShadowfangKeep = {
		["Rethilgore"] = { 5254, 273456, 273457 },
		["Fel Steed / Shadow Charger"] = { 6341, 932 },
		["Razorclaw the Butcher"] = { 1292, 6226, 6633, 273096 },
		["Baron Silverlaine"] = { 6321, 6323, 273637 },
		-- Eerie Stable Lantern: his too since 0.40.1 (441 in 4,693 kills in the drop data, as the Fel Steed's).
		["Commander Springvale"] = { 6320, 3191, 273643, 6341, 273105 },
		-- Since 0.40.1 the Forever recipes seen dropping in recorded runs (Pattern: Filigreed Flame Leggings, Pattern:
		-- Defender's Leather Pants) are on the Recipes page: every boss drops a whole group.
		["Odo the Blindwatcher"] = { 6318, 6319, 273645 },
		["Deathsworn Captain"] = { 6642, 6641 },
		["Arugal's Voidwalker"] = { 5943 },
		["Fenrus the Devourer"] = { 6340, 3230, 273646 },
		["Wolf Master Nandos"] = { 3748, 6314, 273647 },
		["Archmage Arugal"] = { 6324, 6392, 6220 },
		-- Not here since 0.40.1: the Rift Bracers (only Arugal's Voidwalker drops them, and he has his own entry) and the
		-- Eerie Stable Lantern (only the Fel Steed and Commander Springvale drop it, no trash).
		Trash = { 2292, 1489, 1974, 2807, 1482, 1935, 1483, 1318, 3194, 2205, 1484 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 1.3% each, none off the trash): the Fel
		-- Steed, the Shadow Charger and Rethilgore drop the chest group, from Razorclaw the Butcher on every boss the
		-- leggings group. Then Razorclaw's and Commander Springvale's own blueprints (on their pages too); the world's
		-- enchanting formulas that drop here too are not listed (the owner's call of 2026-11-20: only the formulas the
		-- journal listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251340), -- Plans: Veteran's Chain Shirt
			AnyBoss(251341), -- Plans: Guard's Chain Shirt
			AnyBoss(251342), -- Plans: Protector's Chain Shirt
			AnyBoss(251343), -- Plans: Acolyte's Chain Shirt
			AnyBoss(251344), -- Plans: Crusader's Chain Shirt
			AnyBoss(251345), -- Plans: Veteran's Chain Leggings
			AnyBoss(251346), -- Plans: Guard's Chain Leggings
			AnyBoss(251347), -- Plans: Protector's Chain Leggings
			AnyBoss(251348), -- Plans: Acolyte's Chain Leggings
			AnyBoss(251349), -- Plans: Crusader's Chain Leggings
			AnyBoss(252771), -- Pattern: Brawler's Leather Armor
			AnyBoss(252772), -- Pattern: Trapper's Leather Armor
			AnyBoss(252773), -- Pattern: Defender's Leather Armor
			AnyBoss(252774), -- Pattern: Totemic Leather Armor
			AnyBoss(252775), -- Pattern: Stormrider's Leather Armor
			AnyBoss(252776), -- Pattern: Wisdom's Leather Armor
			AnyBoss(252792), -- Pattern: Brawler's Leather Pants
			AnyBoss(252793), -- Pattern: Trapper's Leather Pants
			AnyBoss(252794), -- Pattern: Defender's Leather Pants
			AnyBoss(252795), -- Pattern: Totemic Leather Pants
			AnyBoss(252796), -- Pattern: Stormrider's Leather Pants
			AnyBoss(252797), -- Pattern: Wisdom's Leather Pants
			AnyBoss(253902), -- Pattern: Filigreed Pristine Gown
			AnyBoss(253904), -- Pattern: Filigreed Silky Gown
			AnyBoss(253906), -- Pattern: Filigreed Flame Gown
			AnyBoss(253908), -- Pattern: Filigreed Shadow Gown
			AnyBoss(253910), -- Pattern: Filigreed Pearly Gown
			AnyBoss(253912), -- Pattern: Filigreed Shining Gown
			AnyBoss(253938), -- Pattern: Filigreed Pristine Leggings
			AnyBoss(253940), -- Pattern: Filigreed Silky Leggings
			AnyBoss(253942), -- Pattern: Filigreed Flame Leggings
			AnyBoss(253944), -- Pattern: Filigreed Shadow Leggings
			AnyBoss(253946), -- Pattern: Filigreed Pearly Leggings
			AnyBoss(253948), -- Pattern: Filigreed Shining Leggings
			{ itemID = 273096, droppedBy = "Razorclaw the Butcher" }, -- Blueprint: Tanning Rack
			{ itemID = 273105, droppedBy = "Commander Springvale" }, -- Blueprint: Toxin Study
		},
	},
	BlackfathomDeeps = {
		["Ghamoo-ra"] = { 6907, 6908, 273839 },
		-- Pattern: Brawler's Leather Hood: on the site's list of recipes seen dropping since November. The Merchant's
		-- Favor vendors sell it, and no drop of it is recorded yet: kept, marked (the owner's call of 2026-11-20), as are
		-- the Brawler's Leather Legguards and Defender's Leather Kilt patterns below.
		["Lady Sarevess"] = { 888, 3078, 11121, NotSeen(252798) },
		-- Since 0.40.1 (the owner's calls of 2026-11-20) no boss here lists the six Forever leather helms the site's
		-- list gave them: they are crafted, never dropped. Their patterns, which every boss from Gelihast on drops, are
		-- on the Recipes page with the rest of Forever's shared recipes.
		["Gelihast"] = { 6906, 6905, 1470, 273840, 273141, NotSeen(252820) },
		["Lorgus Jett"] = { 273843, 273841, NotSeen(252820), NotSeen(252822), 273842 },
		["Baron Aquanis"] = { 16782, NotSeen(252822) },
		["Twilight Lord Kelris"] = { 1155, 6903, 273846, NotSeen(252822), NotSeen(252820) },
		-- Plans: Protector's Chain Helm (seen dropping in the owner's recorded run of 2026-11-08) and Plans: Veteran's
		-- Chain Helm (in a player's recorded run of 2026-11-13), once Old Serra'kis's and Aku'mai's: every boss from
		-- Gelihast on drops them, so they are on the Recipes page.
		["Old Serra'kis"] = { 6901, 6904, 6902, NotSeen(252820), NotSeen(252822) },
		["Aku'mai"] = { 6911, 6910, 6909, NotSeen(252820) },
		Trash = { 1486, 3416, 1491, 3414, 1454, 1481, 2567, 3413, 3417, 3415, 2271, 2034 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 1.3% each, none off the trash): Ghamoo-ra
		-- and Lady Sarevess drop the leggings group, every boss from Gelihast on the helm group. Then Gelihast's own
		-- blueprint (on his page too) and the three vendor patterns kept on the bosses; the world's enchanting formulas
		-- that drop here too are not listed (the owner's call of 2026-11-20: only the formulas the journal listed
		-- before, and a dungeon's own).
		Recipes = {
			AnyBoss(251345), -- Plans: Veteran's Chain Leggings
			AnyBoss(251346), -- Plans: Guard's Chain Leggings
			AnyBoss(251347), -- Plans: Protector's Chain Leggings
			AnyBoss(251348), -- Plans: Acolyte's Chain Leggings
			AnyBoss(251349), -- Plans: Crusader's Chain Leggings
			AnyBoss(251350), -- Plans: Veteran's Chain Helm
			AnyBoss(251351), -- Plans: Guard's Chain Helm
			AnyBoss(251352), -- Plans: Protector's Chain Helm
			AnyBoss(251353), -- Plans: Acolyte's Chain Helm
			AnyBoss(251354), -- Plans: Crusader's Chain Helm
			AnyBoss(252792), -- Pattern: Brawler's Leather Pants
			AnyBoss(252793), -- Pattern: Trapper's Leather Pants
			AnyBoss(252794), -- Pattern: Defender's Leather Pants
			AnyBoss(252795), -- Pattern: Totemic Leather Pants
			AnyBoss(252796), -- Pattern: Stormrider's Leather Pants
			AnyBoss(252797), -- Pattern: Wisdom's Leather Pants
			AnyBoss(252814), -- Pattern: Brawler's Leather Helm
			AnyBoss(252815), -- Pattern: Trapper's Leather Helm
			AnyBoss(252816), -- Pattern: Defender's Leather Helm
			AnyBoss(252817), -- Pattern: Totemic Leather Helm
			AnyBoss(252818), -- Pattern: Stormrider's Leather Helm
			AnyBoss(252819), -- Pattern: Wisdom's Leather Helm
			AnyBoss(253938), -- Pattern: Filigreed Pristine Leggings
			AnyBoss(253940), -- Pattern: Filigreed Silky Leggings
			AnyBoss(253942), -- Pattern: Filigreed Flame Leggings
			AnyBoss(253944), -- Pattern: Filigreed Shadow Leggings
			AnyBoss(253946), -- Pattern: Filigreed Pearly Leggings
			AnyBoss(253948), -- Pattern: Filigreed Shining Leggings
			AnyBoss(253976), -- Pattern: Filigreed Pristine Circlet
			AnyBoss(253978), -- Pattern: Filigreed Silky Circlet
			AnyBoss(253980), -- Pattern: Filigreed Flame Circlet
			AnyBoss(253982), -- Pattern: Filigreed Shadow Circlet
			AnyBoss(253984), -- Pattern: Filigreed Pearly Circlet
			AnyBoss(253986), -- Pattern: Filigreed Shining Circlet
			{ itemID = 273141, droppedBy = "Gelihast" }, -- Blueprint: Fishing Rack
			NotSeen(252798), -- Pattern: Brawler's Leather Hood
			NotSeen(252820), -- Pattern: Brawler's Leather Legguards
			NotSeen(252822), -- Pattern: Defender's Leather Kilt
		},
	},
	TheStockade = {
		["Targorr the Dread"] = {
			273804, 273805, 273806, 251345, 251346, 251347, 251348, 251349, 252792, 252793, 252794, 252795, 252796,
			252797, 253938, 253940, 253942, 253944, 253946, 253948,
		},
		-- Since 0.40.1 (the owner's calls of 2026-11-20) no boss here lists the six Forever leather helms the site's
		-- list gave them: they are crafted, never dropped. Their patterns, which all four bosses from Kam Deepfury on
		-- drop, are on the Recipes page with the rest of Forever's shared recipes. The Brawler's Leather Legguards and
		-- Defender's Leather Kilt patterns: the Merchant's Favor vendors sell them, and no drop of either is recorded
		-- yet: kept, marked (the owner's call of 2026-11-20).
		["Kam Deepfury"] = { 2280, 273807, 273808, NotSeen(252820), NotSeen(252822) },
		-- Pattern: Filigreed Pearly Circlet (seen dropping in the owner's recorded run of 2026-11-10), once Hamhock's:
		-- Kam Deepfury, Dextren Ward and Bazil Thredd drop it too, so it is on the Recipes page.
		["Hamhock"] = { 273809, 273810, 273811, NotSeen(252822) },
		["Dextren Ward"] = { 273817, 273819, 273820, NotSeen(252820) },
		["Bazil Thredd"] = { 273824, 273825, 273827, 273829, NotSeen(252822), NotSeen(252820) },
		["Bruegal Ironknuckle"] = { 3228, 2941, 2942 },
		Trash = { 1076, 274092 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 1.2% each, none off the trash): Targorr
		-- the Dread alone drops the leggings group here (his: on his page too, and named), Kam Deepfury, Hamhock,
		-- Dextren Ward, Bazil Thredd and Bruegal Ironknuckle the helm group (any boss). Then the two vendor patterns kept
		-- on the bosses; the world's enchanting formulas that drop here too are not listed (the owner's call of
		-- 2026-11-20: only the formulas the journal listed before, and a dungeon's own).
		Recipes = {
			{ itemID = 251345, droppedBy = "Targorr the Dread" }, -- Plans: Veteran's Chain Leggings
			{ itemID = 251346, droppedBy = "Targorr the Dread" }, -- Plans: Guard's Chain Leggings
			{ itemID = 251347, droppedBy = "Targorr the Dread" }, -- Plans: Protector's Chain Leggings
			{ itemID = 251348, droppedBy = "Targorr the Dread" }, -- Plans: Acolyte's Chain Leggings
			{ itemID = 251349, droppedBy = "Targorr the Dread" }, -- Plans: Crusader's Chain Leggings
			AnyBoss(251350), -- Plans: Veteran's Chain Helm
			AnyBoss(251351), -- Plans: Guard's Chain Helm
			AnyBoss(251352), -- Plans: Protector's Chain Helm
			AnyBoss(251353), -- Plans: Acolyte's Chain Helm
			AnyBoss(251354), -- Plans: Crusader's Chain Helm
			{ itemID = 252792, droppedBy = "Targorr the Dread" }, -- Pattern: Brawler's Leather Pants
			{ itemID = 252793, droppedBy = "Targorr the Dread" }, -- Pattern: Trapper's Leather Pants
			{ itemID = 252794, droppedBy = "Targorr the Dread" }, -- Pattern: Defender's Leather Pants
			{ itemID = 252795, droppedBy = "Targorr the Dread" }, -- Pattern: Totemic Leather Pants
			{ itemID = 252796, droppedBy = "Targorr the Dread" }, -- Pattern: Stormrider's Leather Pants
			{ itemID = 252797, droppedBy = "Targorr the Dread" }, -- Pattern: Wisdom's Leather Pants
			AnyBoss(252814), -- Pattern: Brawler's Leather Helm
			AnyBoss(252815), -- Pattern: Trapper's Leather Helm
			AnyBoss(252816), -- Pattern: Defender's Leather Helm
			AnyBoss(252817), -- Pattern: Totemic Leather Helm
			AnyBoss(252818), -- Pattern: Stormrider's Leather Helm
			AnyBoss(252819), -- Pattern: Wisdom's Leather Helm
			{ itemID = 253938, droppedBy = "Targorr the Dread" }, -- Pattern: Filigreed Pristine Leggings
			{ itemID = 253940, droppedBy = "Targorr the Dread" }, -- Pattern: Filigreed Silky Leggings
			{ itemID = 253942, droppedBy = "Targorr the Dread" }, -- Pattern: Filigreed Flame Leggings
			{ itemID = 253944, droppedBy = "Targorr the Dread" }, -- Pattern: Filigreed Shadow Leggings
			{ itemID = 253946, droppedBy = "Targorr the Dread" }, -- Pattern: Filigreed Pearly Leggings
			{ itemID = 253948, droppedBy = "Targorr the Dread" }, -- Pattern: Filigreed Shining Leggings
			AnyBoss(253976), -- Pattern: Filigreed Pristine Circlet
			AnyBoss(253978), -- Pattern: Filigreed Silky Circlet
			AnyBoss(253980), -- Pattern: Filigreed Flame Circlet
			AnyBoss(253982), -- Pattern: Filigreed Shadow Circlet
			AnyBoss(253984), -- Pattern: Filigreed Pearly Circlet
			AnyBoss(253986), -- Pattern: Filigreed Shining Circlet
			NotSeen(252820), -- Pattern: Brawler's Leather Legguards
			NotSeen(252822), -- Pattern: Defender's Leather Kilt
		},
	},
	Gnomeregan = {
		["Techbot"] = { 9444 },
		["Grubbis"] = { 9445, 274043, 274042 },
		["Viscous Fallout"] = { 9454, 9453, 9452 },
		-- The Defender's Leather Kilt and Brawler's Leather Legguards patterns: the Merchant's Favor vendors sell them, and
		-- no drop of either is recorded yet: kept, marked (the owner's call of 2026-11-20).
		["Electrocutioner 6000"] = { 9447, 9446, 9448, 6893, NotSeen(252822) },
		["Crowd Pummeler 9-60"] = { 9449, 9450, 274068, 274049 },
		["Dark Iron Ambassador"] = { 9455, 9456, 9457, NotSeen(252820) },
		-- Schematic: Flash Bomb and Schematic: Goblin Rocket Boots since 0.40.1: the drop data of 2026-11-19 has 12 and 14
		-- of them in 2,879 of his kills (his other schematics 14 to 23), and no other creature dropping them.
		-- Schematic: Gnomish Cloaking Device and Schematic: Pet Bombling: no drop of either is recorded yet: kept, marked
		-- (the owner's call of 2026-11-20).
		["Mekgineer Thermaplugg"] = { 9492, 9461, 9458, 9459, 4415, 4413, 4411, 6672, 7192, NotSeen(7742), NotSeen(11828) },
		-- Until 0.40.1 this list also had the dungeon's quest items: the Security DELTA Data Access Card, the
		-- Grime-Encrusted Object and Ring, and the five punch cards (the White one drops off the trash, the others come out
		-- of the punch-card machines). Quest items stay off the Trash pages (the owner's call). Schematic: Lil' Smoky, a
		-- trash recipe, is on the Recipes page (the owner's call of 2026-11-20: recipes off the trash are there only).
		Trash = { 9508, 9491, 9509, 9510, 9487, 9485, 9488, 9486, 9490, 9489, 7191 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.1 to 1.2% each, none off the trash): Grubbis,
		-- Viscous Fallout, Electrocutioner 6000, Crowd Pummeler 9-60 and Mekgineer Thermaplugg drop the helm group, the
		-- Dark Iron Ambassador most of it. Then the bosses' own schematics (on their pages too) and the four recipes kept
		-- on the bosses with no drop recorded; the world's enchanting formula seen once here, off Techbot, is not listed
		-- (the owner's call of 2026-11-20: only the formulas the journal listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251350), -- Plans: Veteran's Chain Helm
			AnyBoss(251351), -- Plans: Guard's Chain Helm
			AnyBoss(251352), -- Plans: Protector's Chain Helm
			AnyBoss(251353), -- Plans: Acolyte's Chain Helm
			AnyBoss(251354), -- Plans: Crusader's Chain Helm
			AnyBoss(252814), -- Pattern: Brawler's Leather Helm
			AnyBoss(252815), -- Pattern: Trapper's Leather Helm
			AnyBoss(252816), -- Pattern: Defender's Leather Helm
			AnyBoss(252817), -- Pattern: Totemic Leather Helm
			AnyBoss(252818), -- Pattern: Stormrider's Leather Helm
			AnyBoss(252819), -- Pattern: Wisdom's Leather Helm
			AnyBoss(253976), -- Pattern: Filigreed Pristine Circlet
			AnyBoss(253978), -- Pattern: Filigreed Silky Circlet
			AnyBoss(253980), -- Pattern: Filigreed Flame Circlet
			AnyBoss(253982), -- Pattern: Filigreed Shadow Circlet
			AnyBoss(253984), -- Pattern: Filigreed Pearly Circlet
			AnyBoss(253986), -- Pattern: Filigreed Shining Circlet
			{ itemID = 274049, droppedBy = "Crowd Pummeler 9-60" }, -- Schematic: 9-60 Battery Pack
			{ itemID = 4415, droppedBy = "Mekgineer Thermaplugg" }, -- Schematic: Craftsman's Monocle
			{ itemID = 4413, droppedBy = "Mekgineer Thermaplugg" }, -- Schematic: Discombobulator Ray
			{ itemID = 4411, droppedBy = "Mekgineer Thermaplugg" }, -- Schematic: Flame Deflector
			{ itemID = 6672, droppedBy = "Mekgineer Thermaplugg" }, -- Schematic: Flash Bomb
			{ itemID = 7192, droppedBy = "Mekgineer Thermaplugg" }, -- Schematic: Goblin Rocket Boots
			NotSeen(252822), -- Pattern: Defender's Leather Kilt
			NotSeen(252820), -- Pattern: Brawler's Leather Legguards
			NotSeen(7742), -- Schematic: Gnomish Cloaking Device
			NotSeen(11828), -- Schematic: Pet Bombling
			NotSeen(11827), -- Schematic: Lil' Smoky (the trash's; no drop of it is recorded yet: kept, marked)
		},
	},
	RazorfenKraul = {
		-- Since 0.40.1 (the owner's calls of 2026-11-20) no boss or rare here lists the six Forever leather helms the
		-- site's list gave them: they are crafted, never dropped. Their patterns, which every boss here drops, are on the
		-- Recipes page with the rest of Forever's shared recipes. The Brawler's Leather Legguards and Defender's Leather
		-- Kilt patterns: the Merchant's Favor vendors sell them, and no drop of either is recorded yet: kept, marked (the
		-- owner's call of 2026-11-20).
		["Aggem Thorncurse"] = { 6681, 274158, 274159, NotSeen(252822), NotSeen(252820) },
		["Death Speaker Jargba"] = { 2816, 6685, 6682, NotSeen(252822), NotSeen(252820) },
		["Roogug"] = { 274155, 274149, NotSeen(252820), 274152 },
		-- Pattern: Brawler's Leather Helm (seen dropping in a player's recorded run of 2026-11-13), once Ramtusk's: every
		-- boss here drops it, so it is on the Recipes page.
		["Overlord Ramtusk"] = { 6687, 6686, 274161, NotSeen(252822) },
		-- Razorfen Spearhide's Armor Piercer (6679) is on the trash list below, as the site has it too: the Spearhides
		-- are Ramtusk's guards, no boss of their own (the owner, 2026-11-13), and the site does not list it under him.
		-- Plans: Protector's Chain Helm (seen dropping in a player's recorded run of 2026-11-13), once Agathelos's: every
		-- boss here drops it, so it is on the Recipes page.
		["Agathelos the Raging"] = { 6691, 6690, 274160, NotSeen(252820) },
		["Blind Hunter"] = { 6695, 6697, 6696 },
		["Charlga Razorflank"] = { 6693, 6694, 6692, 17008, 273103 },
		["Earthcaller Halmgar"] = { 6689, 6688 },
		-- Thornspike (6681), on this list too until 0.40.1, is Aggem Thorncurse's alone (the drop data of 2026-11-19: no
		-- other creature drops it), and stays on his page.
		Trash = { 2264, 1488, 4438, 1978, 2039, 1727, 776, 1976, 1975, 2549, 6679, 3569 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 1.4% each, none off the trash): the six
		-- bosses drop the whole helm group, the Blind Hunter and Earthcaller Halmgar most of it. Then the two vendor
		-- patterns kept on the bosses, Charlga Razorflank's Blueprint: Arcane Salvager (an enchanting recipe, hers alone
		-- here: on her page too); the world's enchanting formulas that drop here too are not listed (the owner's call of
		-- 2026-11-20: only the formulas the journal listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251350), -- Plans: Veteran's Chain Helm
			AnyBoss(251351), -- Plans: Guard's Chain Helm
			AnyBoss(251352), -- Plans: Protector's Chain Helm
			AnyBoss(251353), -- Plans: Acolyte's Chain Helm
			AnyBoss(251354), -- Plans: Crusader's Chain Helm
			AnyBoss(252814), -- Pattern: Brawler's Leather Helm
			AnyBoss(252815), -- Pattern: Trapper's Leather Helm
			AnyBoss(252816), -- Pattern: Defender's Leather Helm
			AnyBoss(252817), -- Pattern: Totemic Leather Helm
			AnyBoss(252818), -- Pattern: Stormrider's Leather Helm
			AnyBoss(252819), -- Pattern: Wisdom's Leather Helm
			AnyBoss(253976), -- Pattern: Filigreed Pristine Circlet
			AnyBoss(253978), -- Pattern: Filigreed Silky Circlet
			AnyBoss(253980), -- Pattern: Filigreed Flame Circlet
			AnyBoss(253982), -- Pattern: Filigreed Shadow Circlet
			AnyBoss(253984), -- Pattern: Filigreed Pearly Circlet
			AnyBoss(253986), -- Pattern: Filigreed Shining Circlet
			NotSeen(252820), -- Pattern: Brawler's Leather Legguards
			NotSeen(252822), -- Pattern: Defender's Leather Kilt
			{ itemID = 273103, droppedBy = "Charlga Razorflank" }, -- Blueprint: Arcane Salvager
		},
	},
	ScarletMonasteryGraveyard = {
		-- Since 0.40.1 (the owner's calls of 2026-11-20) no boss or rare here lists the six Forever leather helms the
		-- site's list gave them: they are crafted, never dropped. Their patterns, which both bosses and the three rares
		-- drop, are on the Recipes page with the rest of Forever's shared recipes. The Brawler's Leather Legguards and
		-- Defender's Leather Kilt patterns: the Merchant's Favor vendors sell them, and no drop of either is recorded
		-- yet: kept, marked (the owner's call of 2026-11-20). Plans: Guard's Chain Helm (seen dropping in the owner's
		-- recorded run of 2026-11-16), once Interrogator Vishas's: Bloodmage Thalnos and the rares drop it too, so it
		-- is on the Recipes page.
		["Interrogator Vishas"] = { 7682, 7683, 274290, NotSeen(252822), NotSeen(252820) },
		["Azshir the Sleepless"] = { 7709, 7708, 7731 },
		["Fallen Champion"] = { 7691, 7690, 7689, NotSeen(252820) },
		["Ironspine"] = { 7688, 7687, 7686, NotSeen(252820) },
		["Bloodmage Thalnos"] = { 7685, 7684, 274291, NotSeen(252822) },
		-- The monastery's trash drops that the Graveyard's own creatures drop too (the drop data of 2026-11-19, summed
		-- by wing). Until 0.40.1 this list also had the Scarlet Chestpiece and Gauntlets (the Cathedral's creatures
		-- drop them), the Scarlet Belt and Wristguards (the Armory's), the Scarlet Leggings (Herod's and Scarlet
		-- Commander Mograine's alone, on their pages) and eight blues only the higher wings' creatures drop (the
		-- Swampchill Fetish, Sliverblade, Fight Club, Flintrock Shoulders, Windweaver Staff, Ruthless Shiv, Archon
		-- Chestpiece and Warchief Kilt): each stays on its own wings' pages.
		Trash = { 5819, 7727, 7728, 7754, 10332, 2262, 7787, 7729, 7761, 7752, 8226, 7786, 7753, 7730, 8225 },
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 2% each, none off the trash): both bosses
		-- and the three rares drop the helm group. Then the two vendor patterns kept on the bosses; the world's
		-- enchanting formulas that drop here too are not listed (the owner's call of 2026-11-20: only the formulas the
		-- journal listed before, and a dungeon's own).
		Recipes = {
			AnyBoss(251350), -- Plans: Veteran's Chain Helm
			AnyBoss(251351), -- Plans: Guard's Chain Helm
			AnyBoss(251352), -- Plans: Protector's Chain Helm
			AnyBoss(251353), -- Plans: Acolyte's Chain Helm
			AnyBoss(251354), -- Plans: Crusader's Chain Helm
			AnyBoss(252814), -- Pattern: Brawler's Leather Helm
			AnyBoss(252815), -- Pattern: Trapper's Leather Helm
			AnyBoss(252816), -- Pattern: Defender's Leather Helm
			AnyBoss(252817), -- Pattern: Totemic Leather Helm
			AnyBoss(252818), -- Pattern: Stormrider's Leather Helm
			AnyBoss(252819), -- Pattern: Wisdom's Leather Helm
			AnyBoss(253976), -- Pattern: Filigreed Pristine Circlet
			AnyBoss(253978), -- Pattern: Filigreed Silky Circlet
			AnyBoss(253980), -- Pattern: Filigreed Flame Circlet
			AnyBoss(253982), -- Pattern: Filigreed Shadow Circlet
			AnyBoss(253984), -- Pattern: Filigreed Pearly Circlet
			AnyBoss(253986), -- Pattern: Filigreed Shining Circlet
			NotSeen(252820), -- Pattern: Brawler's Leather Legguards
			NotSeen(252822), -- Pattern: Defender's Leather Kilt
		},
	},
	ScarletMonasteryLibrary = {
		-- Since 0.40.1 (the owner's calls of 2026-11-20) Houndmaster Loksey no longer lists the Brawler's Leather Helm
		-- the site's list gave him: it is crafted, never dropped. Its pattern, with the rest of Forever's helm group,
		-- which he drops, is on the Recipes page. His Blueprint: Trapper's Workbench (the drop data of 2026-11-19: 125
		-- drops in 3,049 kills; elsewhere only off The Beast in Blackrock Spire) is on his page and the Recipes page.
		["Houndmaster Loksey"] = {
			7710, 7756, 3456, 274292, 273109, 251350, 251351, 251352, 251353, 251354, 252814, 252815, 252816, 252817,
			252818, 252819, 253976, 253978, 253980, 253982, 253984, 253986,
		},
		-- The Scarlet Key: no creature drops it; it is in Doan's Strongbox behind him, as his description says. It stays
		-- on his page, marked (the owner's call of 2026-11-20: a row is kept, marked, where no drop is recorded).
		["Arcanist Doan"] = {
			7714, 7713, 7712, 7711, 274293, 274294, NotSeen(7146), 251398, 251399, 251400, 251401, 251402, 252843,
			252844, 252845, 252846, 252847, 252896, 252897, 252898, 252899, 254038, 254040, 254042, 254044, 254046,
			254048,
		},
		-- The monastery's trash drops that the Library's own creatures drop too (the drop data of 2026-11-19, summed by
		-- wing). Until 0.40.1 this list also had the Scarlet Chestpiece and Gauntlets (the Cathedral's creatures drop
		-- them), the Scarlet Belt and Wristguards (the Armory's) and the Scarlet Leggings (Herod's and Scarlet Commander
		-- Mograine's alone, on their pages): each stays on its own wing's pages.
		Trash = {
			5819, 7755, 7727, 7728, 7759, 7760, 7754, 10332, 1992, 2262, 7787, 7729, 7761, 7752, 8226, 7786,
			5756, 7736, 8225, 7753, 7730, 7758, 7757,
		},
		-- Forever's shared recipes (the drop data of 2026-11-19, about 0.2 to 0.7% each, none off the trash): Houndmaster
		-- Loksey alone drops the helm group here, Arcanist Doan alone the level-40 boots, shoes and cords, so each group
		-- is on its boss's page too and names him here (the owner's call of 2026-11-20). Then Loksey's blueprint (on his
		-- page too); the world's enchanting formulas that drop here too are not listed (the owner's call of 2026-11-20:
		-- only the formulas the journal listed before, and a dungeon's own).
		Recipes = {
			{ itemID = 251350, droppedBy = "Houndmaster Loksey" }, -- Plans: Veteran's Chain Helm
			{ itemID = 251351, droppedBy = "Houndmaster Loksey" }, -- Plans: Guard's Chain Helm
			{ itemID = 251352, droppedBy = "Houndmaster Loksey" }, -- Plans: Protector's Chain Helm
			{ itemID = 251353, droppedBy = "Houndmaster Loksey" }, -- Plans: Acolyte's Chain Helm
			{ itemID = 251354, droppedBy = "Houndmaster Loksey" }, -- Plans: Crusader's Chain Helm
			{ itemID = 251398, droppedBy = "Arcanist Doan" }, -- Plans: Officer's Boots
			{ itemID = 251399, droppedBy = "Arcanist Doan" }, -- Plans: Sentinel's Boots
			{ itemID = 251400, droppedBy = "Arcanist Doan" }, -- Plans: Warder's Boots
			{ itemID = 251401, droppedBy = "Arcanist Doan" }, -- Plans: Prefect's Boots
			{ itemID = 251402, droppedBy = "Arcanist Doan" }, -- Plans: Justicar's Boots
			{ itemID = 252814, droppedBy = "Houndmaster Loksey" }, -- Pattern: Brawler's Leather Helm
			{ itemID = 252815, droppedBy = "Houndmaster Loksey" }, -- Pattern: Trapper's Leather Helm
			{ itemID = 252816, droppedBy = "Houndmaster Loksey" }, -- Pattern: Defender's Leather Helm
			{ itemID = 252817, droppedBy = "Houndmaster Loksey" }, -- Pattern: Totemic Leather Helm
			{ itemID = 252818, droppedBy = "Houndmaster Loksey" }, -- Pattern: Stormrider's Leather Helm
			{ itemID = 252819, droppedBy = "Houndmaster Loksey" }, -- Pattern: Wisdom's Leather Helm
			{ itemID = 252843, droppedBy = "Arcanist Doan" }, -- Pattern: Prowler's Leather Shoes
			{ itemID = 252844, droppedBy = "Arcanist Doan" }, -- Pattern: Skulker's Leather Shoes
			{ itemID = 252845, droppedBy = "Arcanist Doan" }, -- Pattern: Warden's Leather Shoes
			{ itemID = 252846, droppedBy = "Arcanist Doan" }, -- Pattern: Skycaller's Leather Shoes
			{ itemID = 252847, droppedBy = "Arcanist Doan" }, -- Pattern: Mender's Leather Shoes
			{ itemID = 252896, droppedBy = "Arcanist Doan" }, -- Pattern: Stalker's Mail Boots
			{ itemID = 252897, droppedBy = "Arcanist Doan" }, -- Pattern: Skycaller's Mail Boots
			{ itemID = 252898, droppedBy = "Arcanist Doan" }, -- Pattern: Skirmisher's Mail Boots
			{ itemID = 252899, droppedBy = "Arcanist Doan" }, -- Pattern: Mender's Mail Boots
			{ itemID = 253976, droppedBy = "Houndmaster Loksey" }, -- Pattern: Filigreed Pristine Circlet
			{ itemID = 253978, droppedBy = "Houndmaster Loksey" }, -- Pattern: Filigreed Silky Circlet
			{ itemID = 253980, droppedBy = "Houndmaster Loksey" }, -- Pattern: Filigreed Flame Circlet
			{ itemID = 253982, droppedBy = "Houndmaster Loksey" }, -- Pattern: Filigreed Shadow Circlet
			{ itemID = 253984, droppedBy = "Houndmaster Loksey" }, -- Pattern: Filigreed Pearly Circlet
			{ itemID = 253986, droppedBy = "Houndmaster Loksey" }, -- Pattern: Filigreed Shining Circlet
			{ itemID = 254038, droppedBy = "Arcanist Doan" }, -- Pattern: Gilded Cord
			{ itemID = 254040, droppedBy = "Arcanist Doan" }, -- Pattern: Frothing Cord
			{ itemID = 254042, droppedBy = "Arcanist Doan" }, -- Pattern: Fiery Cord
			{ itemID = 254044, droppedBy = "Arcanist Doan" }, -- Pattern: Black Cord
			{ itemID = 254046, droppedBy = "Arcanist Doan" }, -- Pattern: Golden Cord
			{ itemID = 254048, droppedBy = "Arcanist Doan" }, -- Pattern: Radiant Cord
			{ itemID = 273109, droppedBy = "Houndmaster Loksey" }, -- Blueprint: Trapper's Workbench
		},
	},
	ScarletMonasteryArmory = {
		-- Band of Crimson Light, a Forever ring, and three Forever recipes: Plans: Sentinel's Boots, Pattern: Skulker's
		-- Leather Shoes and Pattern: Black Cord, seen dropping in a player's recorded run (2026-11-13). Then the rest of
		-- that level-40 group, which he alone drops here (the owner's call of 2026-11-20).
		["Herod"] = {
			7719, 7718, 10330, 7717, 274295, 251399, 252844, 254044, 251398, 251400, 251401, 251402, 252843, 252845,
			252846, 252847, 252896, 252897, 252898, 252899, 254038, 254040, 254042, 254046, 254048,
		},
		-- The monastery's trash drops that the Armory's own creatures drop too, and its set belt and wristguards. Until
		-- 0.40.1 this list also had the Scarlet Chestpiece and Gauntlets (the Cathedral's creatures drop them) and the
		-- Scarlet Leggings (Herod's and Scarlet Commander Mograine's alone; Herod's page has them): each stays on its
		-- own wing's pages.
		Trash = {
			5819, 7755, 7727, 7728, 7759, 7754, 10332, 1992, 2262, 7787, 7729, 7761, 7752, 8226, 7786, 5756,
			7736, 8225, 7753, 7730, 7757, 10333, 10329, 23192, 7758, 7760,
		},
		-- Forever's level-40 recipes (the drop data of 2026-11-19, about 0.2 to 1% each, none off the trash): Herod, the
		-- Armory's one boss, drops the boots, shoes and cords: on his page too, and named here.
		-- Then the Scarlet Trainee's first-aid manual (490 drops in 8,486 kills, no other source); the world's
		-- enchanting formulas Herod drops too are not listed (the owner's call of 2026-11-20: only the formulas the
		-- journal listed before, and a dungeon's own).
		Recipes = {
			{ itemID = 251398, droppedBy = "Herod" }, -- Plans: Officer's Boots
			{ itemID = 251399, droppedBy = "Herod" }, -- Plans: Sentinel's Boots
			{ itemID = 251400, droppedBy = "Herod" }, -- Plans: Warder's Boots
			{ itemID = 251401, droppedBy = "Herod" }, -- Plans: Prefect's Boots
			{ itemID = 251402, droppedBy = "Herod" }, -- Plans: Justicar's Boots
			{ itemID = 252843, droppedBy = "Herod" }, -- Pattern: Prowler's Leather Shoes
			{ itemID = 252844, droppedBy = "Herod" }, -- Pattern: Skulker's Leather Shoes
			{ itemID = 252845, droppedBy = "Herod" }, -- Pattern: Warden's Leather Shoes
			{ itemID = 252846, droppedBy = "Herod" }, -- Pattern: Skycaller's Leather Shoes
			{ itemID = 252847, droppedBy = "Herod" }, -- Pattern: Mender's Leather Shoes
			{ itemID = 252896, droppedBy = "Herod" }, -- Pattern: Stalker's Mail Boots
			{ itemID = 252897, droppedBy = "Herod" }, -- Pattern: Skycaller's Mail Boots
			{ itemID = 252898, droppedBy = "Herod" }, -- Pattern: Skirmisher's Mail Boots
			{ itemID = 252899, droppedBy = "Herod" }, -- Pattern: Mender's Mail Boots
			{ itemID = 254038, droppedBy = "Herod" }, -- Pattern: Gilded Cord
			{ itemID = 254040, droppedBy = "Herod" }, -- Pattern: Frothing Cord
			{ itemID = 254042, droppedBy = "Herod" }, -- Pattern: Fiery Cord
			{ itemID = 254044, droppedBy = "Herod" }, -- Pattern: Black Cord
			{ itemID = 254046, droppedBy = "Herod" }, -- Pattern: Golden Cord
			{ itemID = 254048, droppedBy = "Herod" }, -- Pattern: Radiant Cord
			{ itemID = 255730, droppedBy = "Scarlet Trainee" }, -- Manual: Surgical Tourniquet
		},
	},
	ScarletMonasteryCathedral = {
		["High Inquisitor Fairbanks"] = { 19507, 19508, 19509 },
		["Scarlet Commander Mograine"] = { 7724, 10330, 7726, 7723 },
		["High Inquisitor Whitemane"] = { 7720, 7722, 7721 },
		-- Until 0.40.1 the trash list also had the Scarlet Belt and Wristguards (the Armory's creatures drop them) and
		-- the Scarlet Leggings (Mograine's and Herod's alone; Mograine's page has them): each stays on its own wing's
		-- pages. The set's chestpiece and gauntlets are the Cathedral's creatures' (Champion, Centurion).
		Trash = {
			5819, 7755, 7727, 7728, 7759, 7760, 7754, 10332, 1992, 2262, 7787, 7729, 7761, 7752, 8226, 7786,
			5756, 7736, 8225, 7753, 7730, 7758, 7757, 10328, 10331,
		},
		-- Forever's level-40 recipes (the drop data of 2026-11-19, about 0.2 to 0.9% each, none off the trash): all
		-- three of the Cathedral's bosses drop the boots, shoes and cords. The world's enchanting formulas they drop too
		-- are not listed (the owner's call of 2026-11-20: only the formulas the journal listed before, and a dungeon's
		-- own).
		Recipes = {
			AnyBoss(251398), -- Plans: Officer's Boots
			AnyBoss(251399), -- Plans: Sentinel's Boots
			AnyBoss(251400), -- Plans: Warder's Boots
			AnyBoss(251401), -- Plans: Prefect's Boots
			AnyBoss(251402), -- Plans: Justicar's Boots
			AnyBoss(252843), -- Pattern: Prowler's Leather Shoes
			AnyBoss(252844), -- Pattern: Skulker's Leather Shoes
			AnyBoss(252845), -- Pattern: Warden's Leather Shoes
			AnyBoss(252846), -- Pattern: Skycaller's Leather Shoes
			AnyBoss(252847), -- Pattern: Mender's Leather Shoes
			AnyBoss(252896), -- Pattern: Stalker's Mail Boots
			AnyBoss(252897), -- Pattern: Skycaller's Mail Boots
			AnyBoss(252898), -- Pattern: Skirmisher's Mail Boots
			AnyBoss(252899), -- Pattern: Mender's Mail Boots
			AnyBoss(254038), -- Pattern: Gilded Cord
			AnyBoss(254040), -- Pattern: Frothing Cord
			AnyBoss(254042), -- Pattern: Fiery Cord
			AnyBoss(254044), -- Pattern: Black Cord
			AnyBoss(254046), -- Pattern: Golden Cord
			AnyBoss(254048), -- Pattern: Radiant Cord
		},
	},
}

-- A list's entry: an item's id, or its row's marks with its id (NotSeen, AnyBoss: above).
local function IDOf(entry)
	return type(entry) == "table" and entry.itemID or entry
end

-- A row with the marks its list's entry gives it (a row of the dungeon's own data keeps its name, slot and notes).
local function Marked(row, entry)
	if type(entry) == "table" then
		for field, value in pairs(entry) do
			if field ~= "itemID" then row[field] = value end
		end
	end
	return row
end

-- The boss's rows for what the site lists (and its quest items), then any listed item it lacked.
local function SiteRows(boss, listed)
	local onSite, have, rows = {}, {}, {}
	for _, entry in ipairs(listed) do onSite[IDOf(entry)] = entry end
	for _, row in ipairs(boss.loot or {}) do
		if row.itemID and (onSite[row.itemID] or QUEST_ITEMS[row.itemID]) and not have[row.itemID] then
			rows[#rows + 1] = Marked(row, onSite[row.itemID])
			have[row.itemID] = true
		end
	end
	for _, entry in ipairs(listed) do
		local itemID = IDOf(entry)
		if not have[itemID] then
			rows[#rows + 1] = Marked({ itemID = itemID }, entry)
			have[itemID] = true
		end
	end
	return rows
end

for key, lists in pairs(LOOT) do
	local instance = ns.GetInstance(key)
	if instance then
		local drop = {}
		for _, name in ipairs(DROP_BOSSES[key] or {}) do drop[name] = true end
		local bosses, trash, recipes = {}, nil, nil
		for _, boss in ipairs(instance.bosses) do
			if not drop[boss.name] then
				bosses[#bosses + 1] = boss
				if boss.trash then trash = trash or boss end
				if boss.recipes then recipes = recipes or boss end
			end
		end
		instance.bosses = bosses
		-- (each after the bosses, the Trash before the Recipes: ns.PlaceBoss)
		if lists.Trash and not trash then ns.PlaceBoss(instance, { name = "Trash Drops", trash = true, loot = {} }) end
		if lists.Recipes and not recipes then ns.PlaceBoss(instance, { name = "Recipes", recipes = true, loot = {} }) end
		for _, boss in ipairs(instance.bosses) do
			local listed = lists[boss.trash and "Trash" or boss.recipes and "Recipes" or boss.name]
			if listed then boss.loot = SiteRows(boss, listed) end
		end
	end
end
