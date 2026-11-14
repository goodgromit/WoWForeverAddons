local _, ns = ...

--[[
	Dire Maul's east and north wings, written by hand over their data (Data/Instances/
	DireMaulEast.lua, DireMaulNorth.lua), from the quest audit of 2026-10-29 (Dev/docs/
	audit_2026-10-29). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): Isalien
	(npc 16097), who stands only in the Shrine of Eldretharr, East's second floor; the Brazier of
	Beckoning (22050) that the Isalien versions of the amulet's Left and Right Piece (8967, 8990)
	give when taken; the "one of four" steps before them (8962-8965 before 8967, 8985-8988 before
	8990), two of which ask for the Starbreeze Village Relic (8963, 8985); Stomper Kreeg (14322),
	who gives and takes The Gordok Taste Test (5528), and Captain Kromcrush (14325), Unfinished
	Gordok Business's (7703), both in North only; Guard Mol'dar, who drops the Gordok Inner Door Key
	(18268), and Fengus's Chest (object 179516), which holds the Gordok Courtyard Key (18266; some
	of the wing's other foes drop it too, Guard Fengus not among them). foreverchanges.pro: Pusillin
	drops the Crescent Key every time (its Dire Maul pages), and the Taste Test gives 5 Gordok Green
	Grog and 5 Kreeg's Stout Beatdown, both (its quest page). The Taste Test's and Free Knot!'s
	(5525) level is unsure (56 or 57) and stays as FromForeverChanges.lua has it.

	What the Crescent Key and the Gordok door keys open, and that Isalien's pieces go with the relic
	versions, are the original game's: no source read says so for Forever, and the notes say as
	much. Left out, unsure (Dev/docs/audit_2026-10-29/README.md): the Gordok tribute run, and the
	Taste Test's and Free Knot!'s level.

	Dire Maul West (step 6 of the audit's plan), from QuestieDB's Forever data: Lord Hel'nurath
	(14506) and the Xorothian Dreadsteed (14502) on the Prison of Immol'thar's floor; Dreadsteed of
	Xoroth (7631) needs J'eevee's Jar, a Black Lodestone and Xorothian Glyphs (its requiredSourceItems),
	which Gorzeeki Wildeyes (14437) sells; The Madness Within's (7461) own words for Immol'thar's
	pylons; Elven Legends (7481, 7482) look for Telmius Dreamseeker (object 179544, in North's and
	West's data); Lorekeeper Lydros takes Enchanted Thorium Platemail: Volume II (7650), from its book
	(18770). foreverchanges.pro's quest pages (2026-10-30): Volume II from level 50 ("Changed in
	Forever. Requires level 50 instead of 60."; QuestieDB says 60) and its reward, the Plans: Enchanted
	Thorium Leggings; the Libram quests' Arcanums (7483-7485) and the repeatable Gordok Ogre Suit's suit
	(5519). That Hel'nurath comes when a warlock who has the Dreadsteed does the ritual again is the
	original game's, and the note says so. Tsu'zee, a rare, has no note. Volume II's 6,600 XP is the
	audit's XP pass's (step 14e: its quest page, "Changed in Forever"). The three wings' reputation is
	the audit's reputation pass's (step 15c, 2026-10-30): QuestieDB's Forever data, which the site's
	quest pages match, written where each quest's rewards are; every wing's copy of a shared quest
	(the Librams, the class books, Nostro's Compendium, The Forging of Quel'Serrar) gives the same.

	The deep audit of 2026-10-30 (Dev/docs/audit_2026-10-30, step 3 of its plan): the Libram quests
	need your side's Elven Legends (QuestieDB's preQuestSingle 7481 or 7482, by ancestryBySide) in
	every wing, with one note; Nostro's Compendium and both Forging of Quel'Serrar quests are for
	warriors and paladins (QuestieDB's requiredClasses 3) in every wing; Enchanted Thorium Platemail:
	Volume III (7651), which QuestieDB has Lorekeeper Lydros take from its book (18771), is West's like
	Volumes I and II, from level 50, giving the Plans: Enchanted Thorium Helm and Shen'dralar +200
	(foreverchanges.pro's quest page, read 2026-10-31: "Changed in Forever. Requires level 50 instead of
	55."; QuestieDB says 55 and the same reputation), its halves from Urok Doomhowl and the Black Guard
	Swordsmith (QuestieDB's item drops, as the loot has them). Its XP is left for the XP pass. On East's
	and North's pages, the lorekeepers and Falrin Treeshaper, who stand in the Athenaeum (QuestieDB's
	maps 235 and 238, not East's), give and take their quests "inside Dire Maul" (Data/Instances; on
	East's since 2026-11-03 "inside Dire Maul: Capital Gardens", at the end of this file).

	Loads after FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

local function QuestsOf(key)
	local quests = {}
	for _, quest in ipairs(ns.GetInstance(key).quests) do quests[quest.questID] = quest end
	return quests
end

-- The note both wings show. Each gets its own copy, so the translations are laid over each once.
local function CrescentKey()
	return {
		title = "The Crescent Key",
		kind = "key",
		-- Its use is the original game's; kept on the list of things to check in game.
		text = "Pusillin drops the {item:18249:Crescent Key:1} every time. Chase him through Warpwood Quarter "
			.. "and kill him. In the original game, the key opened the doors into Gordok Commons and Capital "
			.. "Gardens. This is not yet checked on Forever.",
	}
end

--[[
	The three wings share the game's picture of Dire Maul: each is drawn in a colour of its own so they look
	different (the owner's call, 2026-11-09; artTint, ns.TintInstanceArt): the picture in grey, then tinted.
	East green for the Warpwood Quarter's overgrown halls, West blue for the Highborne's arcane Capital
	Gardens, North amber for the Gordok ogres' Commons.
]]
ns.AmendInstance("DireMaulEast", { artTint = { desaturate = true, color = { 0.62, 0.95, 0.5 } } })
ns.AmendInstance("DireMaulWest", { artTint = { desaturate = true, color = { 0.6, 0.76, 1 } } })
ns.AmendInstance("DireMaulNorth", { artTint = { desaturate = true, color = { 1, 0.74, 0.46 } } })

ns.AmendInstance("DireMaulEast", {
	--[[
		Before you go (the overview): the Crescent Key, which drops here, and Isalien, the boss the
		players call themselves.
	]]
	prepare = {
		CrescentKey(),
		{
			title = "Isalien, a hidden boss",
			-- She has no page of her own.
			boss = "Isalien",
			text = "Bodley, inside Blackrock Mountain, gives you the {item:22050:Brazier of Beckoning} with the "
				.. "Isalien versions of The Left Piece and The Right Piece of Lord Valthalak's Amulet. Use it in the "
				.. "Shrine of Eldretharr to call her spirit, and kill her.",
		},
	},

	-- The Gordok Taste Test (5528): Stomper Kreeg gives and takes it, and he is only in Gordok
	-- Commons. Unfinished Gordok Business (7703): Captain Kromcrush is in Gordok Commons and the
	-- gauntlet in the Prince's Chest, in Capital Gardens; nothing of it is here (the owner's rule on
	-- quests not done in the dungeon). Both stay in North; 7703 stays in West too.
	removeQuests = { 5528, 7703 },
})

ns.AmendInstance("DireMaulNorth", {
	--[[
		Before you go (the overview): the Crescent Key, from the east wing, and the two keys the
		Gordok guards drop.
	]]
	prepare = {
		CrescentKey(),
		{
			title = "The Gordok door keys",
			kind = "key",
			-- The Courtyard Key: in Fengus's Chest, by QuestieDB's Forever data, not on Guard Fengus.
			text = "Guard Mol'dar drops the {item:18268:Gordok Inner Door Key:1}. The "
				.. "{item:18266:Gordok Courtyard Key:1} is in Fengus's Chest. In the original game, they opened the "
				.. "inner door and the courtyard door of Gordok Commons. This is not yet checked on Forever.",
		},
	},

	-- The Left and Right Piece of Lord Valthalak's Amulet, Isalien's versions (8967, 8990): she is
	-- called in the east wing, which lists both.
	removeQuests = { 8967, 8990 },
})

-- Isalien's Left and Right Piece: the same chains as Blackrock Spire's Mor Grayhoof versions
-- (Data/Authored/BlackrockSpire.lua), with their steps any one of several will do: one of the four
-- Components of Importance (8962-8965) before 8967, one of the four More Components of Importance
-- (8985-8988) before 8990 (QuestieDB's preQuestSingle). The Quests tab shows those itself. Isalien's
-- own, in the original game, is the one with the Starbreeze Village Relic: Components of Importance
-- (8963) and More Components of Importance (8985). Each gets its own copy of the chain, so the
-- translations are laid over each once.
do
	local function Copy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for key, field in pairs(value) do copy[key] = Copy(field) end
		return copy
	end
	-- Lower Blackrock Spire's: since 2026-11-03 the Mor Grayhoof pieces are listed there alone.
	local east, lower = QuestsOf("DireMaulEast"), QuestsOf("LowerBlackrockSpire")
	east[8967].prerequisites = Copy(lower[8966].prerequisites)
	east[8990].prerequisites = Copy(lower[8989].prerequisites)
	local relic = "In the original game, Isalien's was the one that asks for a Starbreeze Village Relic."
	east[8967].note = relic
	-- And what follows the Right Piece, listed only on Blackrock Spire's pages: Final Preparations (8994,
	-- QuestieDB's nextQuestInChain; the owner's calls of 2026-11-03)
	east[8990].note = relic
	east[8990].followUp = "Then Bodley gives Final Preparations, which goes on in Blackrock Spire."
end

-- The Gordok Taste Test gives 5 of each drink, both (foreverchanges.pro's quest page: "You will
-- receive", no choice).
do
	local tasteTest = QuestsOf("DireMaulNorth")[5528]
	tasteTest.rewards = tasteTest.rewards or {}
	tasteTest.rewards.items = {
		{ itemID = 18269, name = "Gordok Green Grog", count = 5 },
		{ itemID = 18284, name = "Kreeg's Stout Beatdown", count = 5 },
	}
end

--[[
	Dire Maul West. Before you go (the overview): the Crescent Key, as on the other wings; Immol'thar,
	behind the force field the five pylons keep up; and, for warlocks, Lord Hel'nurath, whom the
	Dreadsteed ritual calls.
]]
ns.AmendInstance("DireMaulWest", {
	prepare = {
		CrescentKey(),
		{
			title = "Immol'thar's prison",
			-- Shown on his own page's Overview too. The Madness Within's objective (QuestieDB).
			boss = "Immol'thar",
			text = "A force field holds Immol'thar in his prison. Kill the guardians at the five pylons that power "
				.. "it, and the field goes down. The Shen'dralar Ancient in the courtyard asks this of you in The "
				.. "Madness Within.",
		},
		{
			title = "Lord Hel'nurath, a hidden boss",
			-- Only a warlock can do the ritual. He has no page of his own.
			classOnly = "WARLOCK",
			boss = "Lord Hel'nurath",
			-- The quest's needs: QuestieDB. Calling Hel'nurath: the original game's, kept on the list of
			-- things to check in game.
			text = "Mor'zul Bloodbringer's quest Dreadsteed of Xoroth is done in the Prison of Immol'thar. It needs "
				.. "{item:18663:J'eevee's Jar}, a {item:18629:Black Lodestone} and {item:18670:Xorothian Glyphs}. "
				.. "Gorzeeki Wildeyes in the Burning Steppes sells all three. In the original game, a warlock who "
				.. "already had the Dreadsteed could do the ritual again, and Lord Hel'nurath came instead of the "
				.. "steed. This is not yet checked on Forever.",
		},
	},

	-- Enchanted Thorium Platemail: Volume II: its halves drop in Scholomance and Stratholme, and
	-- Lorekeeper Lydros takes the book. QuestieDB puts him on this wing's Prison of Immol'thar floor
	-- (and on North's map too, as it does Prince Tortheldrin, who is this wing's, and the other
	-- lorekeepers: each is filed under both of Dire Maul's areas, with no spot). From level 50, as
	-- Volume I and foreverchanges.pro's quest page have it (QuestieDB: 60). Volume I (7649), which
	-- Lydros takes too, is listed in this wing before it (QuestAudit.lua), not in North (the owner,
	-- 2026-10-30).
	addQuests = {
		{
			questID = 7650, name = "Enchanted Thorium Platemail: Volume II", level = 60, requiredLevel = 50,
			faction = "Both",
			pickup = "Enchanted Thorium Platemail: Volume II, bound from its two halves",
			turnin = "Lorekeeper Lydros, inside the dungeon",
			startItem = {
				itemID = 18770, name = "Enchanted Thorium Platemail",
				note = "Combine the Top Half (Rattlegore, Scholomance) and the Bottom Half (Crimson Hammersmith, "
					.. "Stratholme) of Advanced Armorsmithing: Volume II.",
			},
			objective = "Bring the book to Lorekeeper Lydros in Dire Maul.",
			note = "For blacksmiths (skill 300).",
			prerequisites = {},
			rewards = { xp = 6600, items = { { itemID = 12726, name = "Plans: Enchanted Thorium Leggings" } }, reputation = { { faction = "Shen'dralar", amount = 200 } } },
		},
		-- Volume III, the same way (see above).
		{
			questID = 7651, name = "Enchanted Thorium Platemail: Volume III", level = 60, requiredLevel = 50,
			faction = "Both",
			pickup = "Enchanted Thorium Platemail: Volume III, bound from its two halves",
			turnin = "Lorekeeper Lydros, inside the dungeon",
			startItem = {
				itemID = 18771, name = "Enchanted Thorium Platemail",
				note = "Combine the Top Half (Urok Doomhowl, Lower Blackrock Spire) and the Bottom Half (Black Guard "
					.. "Swordsmith, Stratholme) of Advanced Armorsmithing: Volume III.",
			},
			objective = "Bring the book to Lorekeeper Lydros in Dire Maul.",
			note = "For blacksmiths (skill 300).",
			prerequisites = {},
			rewards = { items = { { itemID = 12725, name = "Plans: Enchanted Thorium Helm" } }, reputation = { { faction = "Shen'dralar", amount = 200 } } },
		},
	},
})

-- Elven Legends in West: Forever's name for the elf they look for is Telmius Dreamseeker (QuestieDB's
-- object 179544), as East's said (QuestAudit.lua). Since 2026-11-03 West alone lists it (below).
ns.AmendInstance("DireMaulWest", {
	questPatches = {
		[7481] = { objective = "Look in Dire Maul for Telmius Dreamseeker and report back to Sage Korolusk." },
		[7482] = { objective = "Look in Dire Maul for Telmius Dreamseeker and report back to Scholar Runethorn." },
	},
})

-- The Libram quests' Arcanums, in each wing that lists them, and the repeatable Gordok Ogre Suit's
-- suit, the same as the first one gives (foreverchanges.pro's quest pages: "You will receive", one
-- item each, no choice).
local ARCANUMS = {
	[7483] = { itemID = 18329, name = "Arcanum of Rapidity" },
	[7484] = { itemID = 18330, name = "Arcanum of Focus" },
	[7485] = { itemID = 18331, name = "Arcanum of Protection" },
}
for _, key in ipairs({ "DireMaulEast", "DireMaulNorth", "DireMaulWest" }) do
	for questID, quest in pairs(QuestsOf(key)) do
		local arcanum = ARCANUMS[questID]
		if arcanum then
			quest.rewards = quest.rewards or {}
			quest.rewards.items = { { itemID = arcanum.itemID, name = arcanum.name } }
		end
	end
end
do
	local suit = QuestsOf("DireMaulNorth")[5519]
	suit.rewards = suit.rewards or {}
	suit.rewards.items = { { itemID = 18258, name = "Gordok Ogre Suit" } }
end

-- In every wing (the deep audit of 2026-10-30): the Libram quests open after your side's Elven Legends,
-- Horde 7481, Alliance 7482 (QuestieDB's preQuestSingle and ancestryBySide; g07-02), each wing keeping
-- FromForeverChanges.lua's one note, "Repeatable."; and Nostro's Compendium and The Forging of
-- Quel'Serrar are for warriors and paladins only (QuestieDB's requiredClasses 3; g07-15), with East's note
-- in every wing. Onyxia's Lair copies West's 7509 after this (and then leaves the chain out for now:
-- see the end of Data/Authored/OnyxiasLair.lua).
local LIBRAMS = { [7483] = true, [7484] = true, [7485] = true }
local QUEL_SERRAR = { [7507] = true, [7508] = true, [7509] = true }
for _, key in ipairs({ "DireMaulEast", "DireMaulNorth", "DireMaulWest" }) do
	for questID, quest in pairs(QuestsOf(key)) do
		if LIBRAMS[questID] then
			quest.prerequisites = {
				ns.OneOf("Elven Legends", { questID = 7481, faction = "Horde" }, { questID = 7482, faction = "Alliance" }),
			}
		elseif QUEL_SERRAR[questID] then
			quest.classOnly = { "WARRIOR", "PALADIN" }
			quest.note = "For warriors and paladins."
		end
	end
end

--[[
	Each quest in the wing where something of it is done (the owner's call of 2026-11-03 on the deep
	audit's g07-14, "i want this to not be confusing for players"; how other journals do it:
	Dev/docs/audit_2026-10-30/dire_maul_wings.md). A quest is a wing's when it is given or handed in
	there, or its foes, items or objects are there (QuestieDB's Forever data: East's maps are 239 and
	240, North's 235, West's 236 to 238; the Athenaeum, where the lorekeepers, Falrin Treeshaper,
	Telmius Dreamseeker's remains, the Treasure of the Shen'dralar and Prince Tortheldrin are, is filed
	under 235 and 238, and The Madness Within puts Prince Tortheldrin, West's last boss, in it). That the
	Athenaeum is West's alone is the audit's reading of 238; the data files it under North's 235 (area
	10022) as much, so it is on the list of things to check in game, and North's page does not say it.

	Out of East: The Treasure of the Shen'dralar (7877; the Shen'dralar Ancient is in West's courtyard,
	map 236, the treasure in the Athenaeum), Elven Legends (7481, 7482; Telmius's remains), Falrin's three
	(8948-8950: Falrin, the Jeering Spectres on map 238, the ogres' warbeads in North). Out of North the
	same, but Falrin's Vendetta (8949), whose Ogre Warbeads drop from North's ogres. Kept where they were:
	the class books and Nostro's Compendium (their Dusty Tomes are filed with the Athenaeum, with no spot,
	so where else they lie is not known: on the list of things to check in game), the Librams (their books
	drop in every wing), Unfinished Gordok Business (North and West). Both Forging of Quel'Serrar quests
	(7508, 7509) are kept wherever Nostro's Compendium is, as its chain's follow-ups, as West has them.
	Arcane Refreshment (7463), which Lydros gives and takes and whose Hydrospawn is in East, is listed in
	West too, as Falrin's Vendetta is in both.

	Quel'Serrar's chain (7507, 7508, 7509) is left out of every wing for now, with Onyxia's Lair's copy:
	the owner's call of 2026-11-03, until Onyxia's Lair opens. Its data and everything here about it
	(classes, notes, wing wording) stay, so it comes back whole; the one removal is at the end of
	Data/Authored/OnyxiasLair.lua, which copies West's 7509 first.

	So a player can tell where to go: on East's page, a giver or taker in the Athenaeum is "inside Dire
	Maul: Capital Gardens", the words the journal uses for another dungeon's steps (Core/Registry.lua's
	ns.InsideNamed), since none of East's maps has it and West's 238 is at least one way in; North's
	keeps "inside Dire Maul" (the data files the Athenaeum under 235 too), and its Unfinished Gordok
	Business keeps "in Prince Tortheldrin's wing". So do West's quests given or handed in in the
	Athenaeum, and Elven Legends, where North's page shows them as a chain's steps (Anthion's Old Friend
	and The Instigator's Enchantment under Falrin's Vendetta and Anthion's Parting Words, Elven Legends
	under the Librams): wingUnsaidOn names North's page, where UI/QuestsPanel.lua's Where() names the
	dungeon alone, and wingUnsaidNote is the note shown there. West's Captain Kromcrush is "inside Dire
	Maul: Gordok Commons". A note says what the page does not: Falrin's Vendetta (West) that the ogres
	are in Gordok Commons; Elven Legends (West, shown as the Librams' step on every wing) where Telmius's
	remains lie (on North's page, inside Dire Maul).
]]
do
	local function Copy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for key, field in pairs(value) do copy[key] = Copy(field) end
		return copy
	end
	local refreshment = Copy(QuestsOf("DireMaulEast")[7463])
	refreshment.pickup, refreshment.turnin = "Lorekeeper Lydros, inside the dungeon", "Lorekeeper Lydros, inside the dungeon"
	ns.AmendInstance("DireMaulWest", { addQuests = { refreshment } })
	ns.AmendInstance("DireMaulEast", { removeQuests = { 7877, 7481, 7482, 8948, 8949, 8950 } })
	ns.AmendInstance("DireMaulNorth", { removeQuests = { 7877, 7481, 7482, 8948, 8950 } })

	local ATHENAEUM = {
		["Lorekeeper Lydros, inside Dire Maul"] = "Lorekeeper Lydros, inside Dire Maul: Capital Gardens",
		["Lorekeeper Kildrath, inside Dire Maul"] = "Lorekeeper Kildrath, inside Dire Maul: Capital Gardens",
		["Lorekeeper Javon, inside Dire Maul"] = "Lorekeeper Javon, inside Dire Maul: Capital Gardens",
		["Lorekeeper Mykos, inside Dire Maul"] = "Lorekeeper Mykos, inside Dire Maul: Capital Gardens",
		["Falrin Treeshaper, inside Dire Maul"] = "Falrin Treeshaper, inside Dire Maul: Capital Gardens",
	}
	local east, west = QuestsOf("DireMaulEast"), QuestsOf("DireMaulWest")
	for _, quest in pairs(east) do
		quest.pickup = ATHENAEUM[quest.pickup] or quest.pickup
		quest.turnin = ATHENAEUM[quest.turnin] or quest.turnin
	end
	west[7703].pickup = "Captain Kromcrush, inside Dire Maul: Gordok Commons"
	west[7703].turnin = "Captain Kromcrush, inside Dire Maul: Gordok Commons"
	-- The warbeads drop from Lower Blackrock Spire's Spirestone ogres too (Forever's quest data: 8949's own text, and
	-- item 21982's drops, Highlord Omokk and the Spirestone ogres among them; 2026-11-05).
	west[8949].note = "Dire Maul's ogres are in Gordok Commons. Lower Blackrock Spire's Spirestone ogres drop the "
		.. "warbeads too."
	-- What follows on another page (QuestieDB's nextQuestInChain; the owner's calls of 2026-11-03): The
	-- Challenge (9015), done at the Ring of Law and listed in Blackrock Depths, not here; and for paladins,
	-- The Divination Scryer (7646, outside) and Judgment and Redemption (7647, Scholomance's)
	west[8950].followUp = "Then Falrin Treeshaper gives The Challenge, done at the Ring of Law in Blackrock Depths."
	west[7644].followUp = "Then Lord Grayson Shadowbreaker gives The Divination Scryer. The chain ends with Judgment and "
		.. "Redemption in Scholomance."
	local telmius = "Telmius Dreamseeker's remains are in the Athenaeum, in Capital Gardens."
	west[7481].note, west[7482].note = telmius, telmius
	for _, quest in pairs(west) do
		for _, field in ipairs({ "pickup", "turnin" }) do
			local text = quest[field] or ""
			if text:find("^Lorekeeper ") or text:find("^Falrin Treeshaper, ") then quest.wingUnsaidOn = { DireMaulNorth = true } end
		end
	end
	local remains = "Telmius Dreamseeker's remains are in the Athenaeum, inside Dire Maul."
	for _, questID in ipairs({ 7481, 7482 }) do
		west[questID].wingUnsaidOn = { DireMaulNorth = true }
		west[questID].wingUnsaidNote = remains
	end
end
