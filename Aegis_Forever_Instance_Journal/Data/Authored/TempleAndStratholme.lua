local _, ns = ...

--[[
	The Temple of Atal'Hakkar's and Stratholme's notes before you go, quest notes and rewards, written
	by hand over their data (Data/Instances/TempleOfAtalHakkar.lua, StratholmeMainGate.lua,
	StratholmeServiceGate.lua) and the overlays before this file, from the quest audit of 2026-10-29
	(Dev/docs/audit_2026-10-29, step 12 of its plan). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game):
	  The temple. The Stone Circle (3444) and Secret of the Circle (3447) are Marvon Rivetseeker's;
	  3447 ends at the Idol of Hakkar (object 148838), "in the circle of statues", whose guardian is
	  Atal'alarion (npc 8580, "Guardian of the Idol"). The God Hakkar (3528) is Yeh'kinya's, after The
	  Ancient Egg (4787); it hands you the Egg of Hakkar (10465, its sourceItemId), needs the Essence
	  of Hakkar (10663) and asks for the Filled Egg of Hakkar (10662). Bloodpetal Zapper (4148, Horde,
	  Larion) and Bloodpetal Sprouts (4144, Alliance, Muigin) follow Zapper Fuel (4146) and Haze of
	  Evil (4143), and both are done in Un'Goro Crater: their Bloodpetal Sprouts (11315) come from
	  the crater's creatures. The nine class quests' rewards are the items' questRewards; which are a
	  choice, which are given and the money are foreverchanges.pro's quest pages (2026-10-30), which
	  name the same items.
	  Stratholme. Bodley gives the Brazier of Beckoning (22051) with the Jarien and Sothos versions of
	  the Left and Right Piece (8968, 8991), which call Jarien and Sothos (npcs 16101, 16102; on
	  Stratholme's map, which side not said); the site's two Stratholme pages say the same. Dead Man's
	  Plea (8945) needs In Search of Anthion (8929 Alliance, Deliana; 8930 Horde, Mokvar), which needs
	  a class's Just Compensation, after Return to Deliana (8977) or Return to Mokvar (8978); those two
	  and In Search of Anthion give the Extra-Dimensional Ghost Revealer (22115), to be used "at the
	  entrance to Stratholme" to speak with Anthion's ghost. The Ectoplasmic Distiller (8921) needs A
	  Supernatural Device (8922 or 8923). 8968 needs one of Components of Importance (8962-8965), 8991
	  one of More Components of Importance (8985-8988), and Three Kings of Flame (8961) one of Bodley's
	  Unfortunate Fate (8960, 9032). The Argent Hold (5265) is opened at Light's Hope Chapel (object
	  176317) after Lord Maxwell Tyrosus (5264), both in Eastern Plaguelands, after Above and Beyond
	  (5263). Houses of the Holy's 5 Superior Healing Potions and 5 Greater Mana Potions, given with
	  the choice, are the site's quest page's (in Data/Instances/StratholmeMainGate.lua and
	  StratholmeServiceGate.lua). Magistrate Barthilas drops the Key to the City (12382) every time
	  (the site's Service Gate page). Stratholme's reputation is the audit's reputation pass's (step
	  15c, 2026-10-30): QuestieDB's Forever data, which the site's quest pages match, the same at both
	  gates. Dead Man's Plea (8945) has none: QuestieDB gives Argent Dawn +399, the site's quest page
	  none, so it is on the list of things to check in game.

	The Great Ezra Grimm (5214), at both gates: Forever renamed Fras Siabi. Forever's quest data
	names the quest, its objective, its tobacco (13172) and npc 11058 for Ezra Grimm, as the site's
	Ezra Grimm's Postbox Key (13307) already does; the quest's name and objective are written so in
	Data/Instances/StratholmeMainGate.lua and StratholmeServiceGate.lua (the quest check of 2026-11-05).

	The original game's, and said so in the notes: the statues touched in order calling
	Atal'alarion; the egg used at the Altar of Hakkar, the guards' blood and the Eternal Flames
	before the Avatar comes; what the Key to the City opened. All three are on the list of things to
	check in game.

	From the deep audit of 2026-10-30 (Dev/docs/audit_2026-10-30, step 7 of its plan), QuestieDB's: the
	Essence of Hakkar (10663) drops from the Shade of Hakkar (npc 8440, inside). The quests that come
	next, done outside, named on the temple's quests: The Essence of Eranikus (3373) goes on to its
	second part (3374, the Chained Essence to Itharius in the Swamp of Sorrows) and In Eranikus' Own
	Words (3512, Itharius's, to Winterspring); The God Hakkar (3528) to The Lost Tablets of Mosh'aru
	(5065, Prospector Ironboot in Tanaris) and then The Final Tablets (4788, Lower Blackrock Spire);
	Eranikus, Tyrant of the Dream (8733) to Tyrande and Remulos (8734, from the Forest Wisp to Keeper
	Remulos in Moonglade).

	Into The Temple of Atal'Hakkar (1475) stays from level 38: foreverchanges.pro's quest page says
	"Changed in Forever. Requires level 38 instead of 41." QuestieDB says 41 (on the audit's Unsure
	list).

	Taken out on the owner's rule (2026-10-29: quests not done in the dungeon and not leading to it):
	Bloodpetal Zapper (4148), done in Un'Goro after Zapper Fuel (Bloodpetal Sprouts, 4144, its
	Alliance twin, stays out too); The Argent Hold (5265), opened at Light's Hope Chapel after Above
	and Beyond. The quests before them name what follows and its reward. Left out: the Atiesh quests
	(9257, 9269-9271), whose chain starts in Naxxramas, not confirmed on Forever.

	Loads after FromGuides.lua, FromForeverChanges.lua, QuestAudit.lua and BlackrockSpire.lua, whose
	quests and chains it amends.
]]

local function QuestsOf(key)
	local quests = {}
	for _, quest in ipairs(ns.GetInstance(key).quests) do quests[quest.questID] = quest end
	return quests
end

-- The class quests' rewards: a choice of three; money where the quest page gives it; reputation
-- where QuestieDB's Forever data gives it (step 15 of the audit's plan; the site's quest pages agree).
local function Choice(items, money, also, reputation)
	local rewards = { items = {}, choice = true, money = money, also = also, reputation = reputation }
	for index, item in ipairs(items) do rewards.items[index] = { itemID = item[1], name = item[2] } end
	return rewards
end

ns.AmendInstance("TempleOfAtalHakkar", {
	--[[
		Before you go (the overview): the two bosses the players call themselves (also on their own
		pages).
	]]
	prepare = {
		{
			title = "Atal'alarion, a hidden boss",
			boss = "Atal'alarion",
			-- How the statues call him is the original game's; kept on the list of things to check in game.
			text = "Marvon Rivetseeker in Tanaris gives The Stone Circle, then Secret of the Circle, which ends at the "
				.. "Idol of Hakkar in the temple's circle of statues. In the original game, touching the statues in the "
				.. "order the Stone Circle shows called Atal'alarion, the idol's guardian. This is not yet checked on "
				.. "Forever.",
		},
		{
			title = "Avatar of Hakkar, a hidden boss",
			boss = "Avatar of Hakkar",
			-- The altar, the guards and the flames are the original game's; kept on the list of things to
			-- check in game.
			text = "Yeh'kinya in Tanaris gives The God Hakkar after The Ancient Egg, and hands you the "
				.. "{item:10465:Egg of Hakkar}. Fill it with the {item:10663:Essence of Hakkar}, which the Shade of "
				.. "Hakkar drops in the temple, and take the {item:10662:Filled Egg of Hakkar} back to Yeh'kinya. "
				.. "In the original game, you used the egg at "
				.. "the Altar of Hakkar: Hakkar's guards came, their blood put out the Eternal Flames, and then the "
				.. "Avatar of Hakkar came. This is not yet checked on Forever.",
		},
	},

	-- Bloodpetal Zapper, done in Un'Goro, stays out: the owner's call of 2026-11-03.
	removeQuests = { 4148 },

	questPatches = {
		-- Into the Depths and Secret of the Circle: The Stone Circle comes after your side's The Sunken
		-- Temple (QuestieDB's preQuestSingle for 3444; the deep audit of 2026-10-30, T1), both listed here.
		[3446] = {
			prerequisites = {
				ns.OneOf("The Sunken Temple", { questID = 3445, faction = "Alliance" }, { questID = 3380, faction = "Horde" }),
				{ questID = 3444, name = "The Stone Circle" },
			},
		},
		[3447] = {
			prerequisites = {
				ns.OneOf("The Sunken Temple", { questID = 3445, faction = "Alliance" }, { questID = 3380, faction = "Horde" }),
				{ questID = 3444, name = "The Stone Circle" },
			},
		},
		[4146] = {
			note = "Larion then gives Bloodpetal Zapper in Un'Goro Crater: bring him a Bloodpetal Sprout, and he gives "
				.. "the Bloodpetal Zapper.",
		},
		[4143] = { note = "Muigin then gives Bloodpetal Sprouts in Un'Goro Crater: bring him 3 Bloodpetal Sprouts." },
		-- What comes after, done outside (the deep audit of 2026-10-30, T3): QuestieDB's
		-- nextQuestInChain, givers, takers and objectives.
		[3373] = {
			note = "After this, The Essence of Eranikus goes on outside: take the Chained Essence of Eranikus to "
				.. "Itharius in the Swamp of Sorrows. He then gives In Eranikus' Own Words, which sends you to Winterspring.",
		},
		[3528] = {
			followUp = "After this, Prospector Ironboot in Tanaris gives The Lost Tablets of Mosh'aru, which leads to The "
				.. "Final Tablets in Lower Blackrock Spire.",
		},
		[8733] = {
			note = "Then the Forest Wisp gives Tyrande and Remulos, which sends you to Keeper Remulos in Moonglade. The "
				.. "chain goes on from there.",
		},
		[8232] = { rewards = Choice({ { 20083, "Hunting Spear" }, { 19991, "Devilsaur Eye" }, { 19992, "Devilsaur Tooth" } }) },
		[8236] = { rewards = Choice({ { 19984, "Ebon Mask" }, { 20255, "Whisperwalk Boots" }, { 19982, "Duskbat Drape" } }, 7500, nil,
			{ { faction = "Ravenholdt", amount = 150 } }) },
		[8253] = { rewards = Choice({ { 20035, "Glacial Spike" }, { 20037, "Arcane Crystal Pendant" }, { 20036, "Fire Ruby" } }, 15500) },
		[8257] = { rewards = Choice({ { 19990, "Blessed Prayer Beads" }, { 20082, "Woestave" }, { 20006, "Circle of Hope" } }, 15500) },
		[8413] = { rewards = Choice({ { 20369, "Azurite Fists" }, { 20503, "Enamored Water Spirit" }, { 20556, "Wildstaff" } }, 15500) },
		-- The Holy Mightstone comes with the choice ("You will also receive").
		[8418] = {
			rewards = Choice({ { 20504, "Lightforged Blade" }, { 20512, "Sanctified Orb" }, { 20505, "Chivalrous Signet" } }, 15500,
				{ { itemID = 20620, name = "Holy Mightstone" } }, { { faction = "Argent Dawn", amount = 150 } }),
		},
		[8422] = { rewards = Choice({ { 20536, "Soul Harvester" }, { 20534, "Abyss Shard" }, { 20530, "Robes of Servitude" } }, 15500) },
		[8425] = { rewards = Choice({ { 20521, "Fury Visor" }, { 20130, "Diamond Flask" }, { 20517, "Razorsteel Shoulders" } }) },
		[9053] = { rewards = Choice({ { 22274, "Grizzled Pelt" }, { 22272, "Forest's Embrace" }, { 22458, "Moonshadow Stave" } }) },
	},
})

-- The class quests' XP, 6,350 each: the original game's number (the site's quest pages call each
-- unchanged; the audit's step 19). The Quests tab marks it as such (Data/Generated/OriginalXP.lua).
do
	local temple = QuestsOf("TempleOfAtalHakkar")
	for _, questID in ipairs({ 8232, 8236, 8253, 8257, 8413, 8418, 8422, 8425, 9053 }) do
		temple[questID].rewards.xp = 6350
	end
end

-- Jarien and Sothos: on both gates, as their quests are (which side they are called on is not known).
local function JarienAndSothos()
	return {
		title = "Jarien and Sothos, hidden bosses",
		-- They have no page of their own: no model or loot is known beyond the amulet's pieces.
		boss = "Jarien and Sothos",
		text = "Bodley gives you the {item:22051:Brazier of Beckoning} with the Jarien and Sothos versions of The Left "
			.. "Piece and The Right Piece of Lord Valthalak's Amulet. Use it in Stratholme to call their spirits, and "
			.. "kill them for the piece.",
	}
end

-- Dead Man's Plea: the class's own steps, one for each class, which its list leaves out (its side's
-- steps are in it now, as one-of steps: Data/Authored/BlackrockSpire.lua; the deep audit of
-- 2026-10-30, X3), and the ghost.
local PLEA_NOTE = "Also needs your class's An Earnest Proposition, before A Supernatural Device, and your class's "
	.. "Just Compensation, before In Search of Anthion. Anthion Harmon is a ghost: to see him, use the "
	.. "Extra-Dimensional Ghost Revealer, which Return to Deliana or Return to Mokvar gives you, at the entrance to "
	.. "Stratholme."

ns.AmendInstance("StratholmeMainGate", {
	--[[
		Before you go (the overview): the Scarlet Key, Postmaster Malown and Jarien and Sothos, the
		bosses the amulet's brazier calls. The key and Malown since the quest check of 2026-11-05 (the
		owner's calls of that day): both are the original game's, kept on the list of things to check
		in game.
	]]
	prepare = {
		{
			title = "The Scarlet Key",
			kind = "key",
			-- The Scarlet Monastery's key (item 7146, Doan's Strongbox: Data/Authored/
			-- ScarletMonasteryQuests.lua). The two doors it opened here, and the rogue's lockpicking, are
			-- the original game's (a second guide says the same).
			text = "{item:7146:The Scarlet Key:2} is in Doan's Strongbox, in the Scarlet Monastery's Library. In the "
				.. "original game, it also opened the Bastion Door and the door of the Hall of High Command here, and a "
				.. "rogue could pick both locks. This is not yet checked on Forever.",
		},
		{
			title = "Postmaster Malown, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Postmaster Malown",
			-- The Courier drops the postbox keys (Forever's quest data for items 13302-13307, npc 11082; his
			-- loot here). The postboxes calling guards and Malown are the original game's (a second guide
			-- says the same).
			text = "The Stratholme Courier drops the city's postbox keys. In the original game, each locked postbox "
				.. "you opened brought out guards, and Postmaster Malown came with the third. This is not yet "
				.. "checked on Forever.",
		},
		JarienAndSothos(),
	},
	questPatches = {
		[8945] = { note = PLEA_NOTE },
		-- What follows, listed on the Service Gate alone: Above and Beyond (5263, QuestieDB's
		-- nextQuestInChain; the owner's calls of 2026-11-03)
		[5262] = { followUp = "Then Duke Nicholas Zverenhoff gives Above and Beyond, done at the Service Gate." },
	},
})

ns.AmendInstance("StratholmeServiceGate", {
	--[[
		Before you go (the overview): Stratholme's Key to the City, which Magistrate Barthilas drops
		(not the City of Dalaran's quest of that name), and Jarien and Sothos.
	]]
	prepare = {
		{
			title = "Stratholme's Key to the City",
			kind = "key",
			-- Its use is the original game's; kept on the list of things to check in game.
			text = "Magistrate Barthilas always drops the {item:12382:Key to the City:2}. It is not the key from the "
				.. "City of Dalaran's quest of the same name. In the original game, it opened the Service Entrance's "
				.. "gate from outside, so a group could go straight to the Baron's side. This is not yet checked on "
				.. "Forever.",
		},
		JarienAndSothos(),
	},

	-- The Argent Hold, opened at Light's Hope Chapel, stays out: the owner's call of 2026-11-03.
	removeQuests = { 5265 },

	questPatches = {
		[8945] = { note = PLEA_NOTE },
		[5263] = {
			note = "Duke Nicholas Zverenhoff then sends you to Lord Maxwell Tyrosus at Light's Hope Chapel, who gives The "
				.. "Argent Hold: open it for a choice of Argent Avenger, Argent Defender or Argent Crusader.",
		},
		-- What follows: Anthion's Strange Request (8947, outside) and Anthion's Old Friend (8948, Falrin's,
		-- Dire Maul West's) (QuestieDB's nextQuestInChain; the owner's calls of 2026-11-03). The note names
		-- no wing: Dire Maul North's page shows this quest as a step, and names none for the Athenaeum.
		[8946] = {
			followUp = "Then Anthion Harmon gives Anthion's Strange Request. The chain goes on to Anthion's Old Friend in "
				.. "Dire Maul.",
		},
	},
})

--[[
	The amulet's quests on both gates take Blackrock Spire's chains (Data/Authored/
	BlackrockSpire.lua; Lower's Mor Grayhoof pieces, listed there alone since 2026-11-03), with their steps any one of several will do (ns.OneOf): your side's Bodley's
	Unfortunate Fate before Three Kings of Flame, one of the four Components of Importance before
	8968, and for 8991 one of the four Left Pieces and one of the four More Components of Importance
	too (QuestieDB's preQuestSingle). The Quests tab shows those itself. The Main Gate's copies had
	listed only Components of Importance (8964) or I See Alcaz Island... (8970), and the Service
	Gate's 8964 and More Components of Importance (8987), which would lock them for a player who did
	another version. The notes keep what the chain can't show: Bodley's Unfortunate Fate comes after
	the class's own Anthion's Parting Words, and, on the Right Pieces (8991, 8992), that Final
	Preparations (8994, QuestieDB's nextQuestInChain) follows on Blackrock Spire's pages (the owner's
	calls of 2026-11-03). Each gets its own copy, so the translations are laid over each once.
]]
do
	local lower = QuestsOf("LowerBlackrockSpire")
	local function Copy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for key, field in pairs(value) do copy[key] = Copy(field) end
		return copy
	end
	local fate = "Bodley's Unfortunate Fate comes after your class's Anthion's Parting Words."
	local preparations = "Then Bodley gives Final Preparations, which goes on in Blackrock Spire."
	for _, key in ipairs({ "StratholmeMainGate", "StratholmeServiceGate" }) do
		local quests = QuestsOf(key)
		quests[8968].prerequisites = Copy(lower[8966].prerequisites)
		quests[8968].note = fate
		quests[8991].prerequisites = Copy(lower[8989].prerequisites)
		quests[8991].note, quests[8991].followUp = fate, preparations
	end
	-- Kormok's in Scholomance (8969, 8992) the same (the deep audit of 2026-10-30, g07-01/g10-01): they
	-- had the old fixed chain (Components of Importance 8965 only; I See Alcaz Island... and 8988 only,
	-- without Bodley's Unfortunate Fate), which locked out a player who did another version and kept
	-- Three Kings of Flame shut. Here, not in Scholomance.lua, which loads before BlackrockSpire.lua.
	local scholomance = QuestsOf("Scholomance")
	scholomance[8969].prerequisites = Copy(lower[8966].prerequisites)
	scholomance[8969].note = fate
	scholomance[8992].prerequisites = Copy(lower[8989].prerequisites)
	scholomance[8992].note, scholomance[8992].followUp = fate, preparations
end

-- The Medallion of Faith (5122, added by Data/Authored/FromForeverChanges.lua after the gates' own
-- quests) is listed just before Aurius' Reckoning (5125), which needs it (QuestieDB's preQuestSingle;
-- the deep audit of 2026-10-30, S7). The Flesh Does Not Lie comes before The Active Agent in the
-- Service Gate's own file.
for _, key in ipairs({ "StratholmeMainGate", "StratholmeServiceGate" }) do
	local list = ns.GetInstance(key).quests
	local medallion
	for index, quest in ipairs(list) do
		if quest.questID == 5122 then
			medallion = table.remove(list, index)
			break
		end
	end
	for index, quest in ipairs(list) do
		if medallion and quest.questID == 5125 then
			table.insert(list, index, medallion)
			medallion = nil
			break
		end
	end
	-- Without Aurius' Reckoning it stays listed, at the end, where it was
	if medallion then list[#list + 1] = medallion end
end

--[[
	Collection of Goods (7642), the Alliance paladin's charger step whose Stratholme Holy Water is
	gathered here, on both gates (the owner's call of 2026-11-03 on the deep audit's S10): QuestieDB's
	Forever data for all of it (Grimand Elmore gives and takes it; the steps before it, its objective,
	Ironforge +100), and its XP as its step page had it (the original game's, so marked). The holy water
	(13180) comes only from Stratholme's two kinds of supply crate (objects 176224 and 181085, in no
	set spot). A class quest, so the Quests tab lists it under Class Quests, for Alliance paladins alone.
	Dire Maul's and Scholomance's chains show this page as a step. Its followUp (shown on its own page
	alone, not on theirs) names what follows, Ancient Equine Spirit (7643, Lord Grayson Shadowbreaker's,
	done on Tendris Warpwood and listed in Dire Maul West; QuestieDB's preQuestSingle; the owner's calls of
	2026-11-03).
]]
for _, key in ipairs({ "StratholmeMainGate", "StratholmeServiceGate" }) do
	ns.AmendInstance(key, {
		addQuests = {
			{
				questID = 7642, name = "Collection of Goods", level = 60, requiredLevel = 60, faction = "Alliance",
				classOnly = "PALADIN",
				objective = "Bring 40 Runecloth, 6 Arcanite Bars, 10 Arthas' Tears, 5 Stratholme Holy Water vials, and "
					.. "150 gold to Grimand Elmore in the Dwarven District of Stormwind.",
				pickup = "Grimand Elmore, Stormwind City",
				startMap = { mapID = 1453, x = 0.597, y = 0.338, label = "Grimand Elmore" },
				turnin = "Grimand Elmore, Stormwind City",
				endMap = { mapID = 1453, x = 0.597, y = 0.338, label = "Grimand Elmore" },
				note = "A step of the paladin's charger quests. The Stratholme Holy Water comes from supply crates "
					.. "inside Stratholme.",
				followUp = "Then Lord Grayson Shadowbreaker gives Ancient Equine Spirit, done in Dire Maul's Capital "
					.. "Gardens.",
				prerequisites = {
					{ questID = 7638, name = "Lord Grayson Shadowbreaker" },
					{ questID = 7637, name = "Emphasis on Sacrifice" },
					{ questID = 7639, name = "To Show Due Judgment" },
					{ questID = 7640, name = "Exorcising Terrordale" },
					{ questID = 7641, name = "The Work of Grimand Elmore" },
				},
				rewards = { xp = 1650, reputation = { { faction = "Ironforge", amount = 100 } } },
			},
		},
	})
end
