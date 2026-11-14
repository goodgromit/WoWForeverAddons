local _, ns = ...

--[[
	Scholomance, written by hand over its data (Data/Instances/Scholomance.lua), from the quest
	audit of 2026-10-29 (Dev/docs/audit_2026-10-29). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): the
	Skeleton Key's quests on each side, their givers and takers and where they stand, their levels,
	their order, the reputation they give, and the Skeleton Key as the last one's reward; the
	reputation of the dungeon's other quests; and what calls each hidden boss (the quests' own
	words, and the items the quests give or the bosses drop). foreverchanges.pro's Scholomance page
	(2026-10-30), read by hand, agrees on Kirtonos and Kormok and says nothing of the door.

	Loads after FromForeverChanges.lua and QuestAudit.lua, whose Scholomance quests it gives their
	reputation.
]]

local SKELETON_KEY = { itemID = 13704, name = "Skeleton Key" }

-- The places the key's quests are given and handed in, as the generated quests write them.
local VALORFIST = "Commander Ashlam Valorfist, Western Plaguelands"
local ARBINGTON = "Alchemist Arbington, Western Plaguelands"
local KRINKLE = "Krinkle Goodsteel, Tanaris"
local DERRINGTON = "High Executor Derrington, Tirisfal Glades"
local DITHERS = "Apothecary Dithers, Tirisfal Glades"
local function At(mapID, x, y) return { mapID = mapID, x = x, y = y } end
local AT_VALORFIST, AT_ARBINGTON, AT_KRINKLE = At(1422, 0.427, 0.840), At(1422, 0.427, 0.838), At(1446, 0.515, 0.288)
local AT_DERRINGTON, AT_DITHERS = At(1420, 0.831, 0.689), At(1420, 0.833, 0.692)

-- Each side's chain, oldest first: { questID, name, level, requiredLevel, pickup, startMap, turnin,
-- endMap, objective, reputation }. Its breadcrumbs (5066, 5090, 5091; 5093, 5094, 5095) can be
-- skipped, and are left out.
local CHAINS = {
	Alliance = {
		faction = "Stormwind",
		{ 5092, "Clear the Way", 52, 50, VALORFIST, AT_VALORFIST, VALORFIST, AT_VALORFIST,
			"Kill 10 Skeletal Flayers and 10 Slavering Ghouls in Sorrow Hill.", 100 },
		{ 5097, "All Along the Watchtowers", 56, 50, VALORFIST, AT_VALORFIST, VALORFIST, AT_VALORFIST,
			"Mark each of the four towers in Andorhal with the Beacon Torch: stand in each tower's doorway to mark it.", 100 },
		{ 5533, "Scholomance", 55, 55, VALORFIST, AT_VALORFIST, ARBINGTON, AT_ARBINGTON,
			"Speak with Alchemist Arbington at Chillwind Camp." },
		{ 5537, "Skeletal Fragments", 57, 55, ARBINGTON, AT_ARBINGTON, ARBINGTON, AT_ARBINGTON,
			"Bring 15 Skeletal Fragments." },
		{ 5538, "Mold Rhymes With...", 57, 55, ARBINGTON, AT_ARBINGTON, KRINKLE, AT_KRINKLE,
			"Bring the Imbued Skeletal Fragments and 15 gold coins to Krinkle Goodsteel in Gadgetzan." },
		{ 5801, "Fire Plume Forged", 57, 55, KRINKLE, AT_KRINKLE, ARBINGTON, AT_ARBINGTON,
			"Take the Skeleton Key Mold and 2 Thorium Bars to the top of Fire Plume Ridge in Un'Goro Crater. Use the mold by the lava lake to forge the Unfinished Skeleton Key." },
		{ 5803, "Araj's Scarab", 60, 55, ARBINGTON, AT_ARBINGTON, ARBINGTON, AT_ARBINGTON,
			"Destroy Araj the Summoner and bring back Araj's Scarab." },
		{ 5505, "The Key to Scholomance", 60, 55, ARBINGTON, AT_ARBINGTON, ARBINGTON, AT_ARBINGTON, nil, 200, SKELETON_KEY },
	},
	Horde = {
		faction = "Undercity",
		{ 5096, "Scarlet Diversions", 53, 50, DERRINGTON, AT_DERRINGTON, DERRINGTON, AT_DERRINGTON,
			"Destroy the command tent at the Scarlet Crusade's camp between Felstone Field and Dalson's Tears, and place the Scourge banner there.", 100 },
		{ 5098, "All Along the Watchtowers", 56, 50, DERRINGTON, AT_DERRINGTON, DERRINGTON, AT_DERRINGTON,
			"Mark each of the four towers in Andorhal with the Beacon Torch: stand in each tower's doorway to mark it.", 100 },
		{ 838, "Scholomance", 55, 55, DERRINGTON, AT_DERRINGTON, DITHERS, AT_DITHERS,
			"Speak with Apothecary Dithers at the Bulwark." },
		{ 964, "Skeletal Fragments", 57, 55, DITHERS, AT_DITHERS, DITHERS, AT_DITHERS,
			"Bring 15 Skeletal Fragments." },
		{ 5514, "Mold Rhymes With...", 57, 55, DITHERS, AT_DITHERS, KRINKLE, AT_KRINKLE,
			"Bring the Imbued Skeletal Fragments and 15 gold coins to Krinkle Goodsteel in Gadgetzan." },
		{ 5802, "Fire Plume Forged", 57, 55, KRINKLE, AT_KRINKLE, DITHERS, AT_DITHERS,
			"Take the Skeleton Key Mold and 2 Thorium Bars to the top of Fire Plume Ridge in Un'Goro Crater. Use the mold by the lava lake to forge the Unfinished Skeleton Key." },
		{ 5804, "Araj's Scarab", 60, 55, DITHERS, AT_DITHERS, DITHERS, AT_DITHERS,
			"Destroy Araj the Summoner and bring back Araj's Scarab." },
		{ 5511, "The Key to Scholomance", 60, 55, DERRINGTON, AT_DERRINGTON, DERRINGTON, AT_DERRINGTON, nil, 200, SKELETON_KEY },
	},
}

-- Their XP: the original game's numbers (the site's quest pages call each quest unchanged; the
-- audit's step 19). The Quests tab marks them as such (Data/Generated/OriginalXP.lua).
local XP = {
	[5092] = 5100, [5097] = 5800, [5533] = 550, [5537] = 4500, [5538] = 600, [5801] = 4500, [5803] = 4950,
	[5505] = 9950,
	[5096] = 5250, [5098] = 5800, [838] = 550, [964] = 4500, [5514] = 600, [5802] = 4500, [5804] = 4950,
	[5511] = 9950,
}

-- The chains as the dungeon's quests, each needing every one before it; and their ids, for the keys.
local keyQuests, keyIDs = {}, {}
for side, chain in pairs(CHAINS) do
	keyIDs[side] = {}
	local before = {}
	for _, step in ipairs(chain) do
		local questID, name, level, requiredLevel, pickup, startMap, turnin, endMap, objective, reputation, item = unpack(step, 1, 11)
		local rewards = {
			xp = XP[questID],
			reputation = reputation and { { faction = chain.faction, amount = reputation } } or nil,
			items = item and { { itemID = item.itemID, name = item.name } } or nil,
		}
		local prerequisites = {}
		for index, earlier in ipairs(before) do prerequisites[index] = earlier end
		keyQuests[#keyQuests + 1] = {
			questID = questID, name = name, level = level, requiredLevel = requiredLevel, faction = side,
			pickup = pickup, startMap = startMap, turnin = turnin, endMap = endMap, objective = objective,
			prerequisites = prerequisites, rewards = rewards,
		}
		before[#before + 1] = { questID = questID, name = name }
		keyIDs[side][#keyIDs[side] + 1] = questID
	end
end
table.sort(keyQuests, function(a, b)
	if a.faction ~= b.faction then return a.faction == "Alliance" end
	return #a.prerequisites < #b.prerequisites
end)

ns.AmendInstance("Scholomance", {
	--[[
		Before you go (the overview, for the player's own side and class): the Skeleton Key, from each
		side's chain; the Viewing Room Key, Rattlegore's drop (2026-11-05); and the bosses the players call
		themselves, with what calls them.
	]]
	prepare = {
		{
			faction = "Alliance",
			title = "The Skeleton Key",
			-- Who gives each step (QuestieDB): Valorfist 5092, 5097, 5533; Arbington 5537, 5538; Krinkle 5801,
			-- back to Arbington; Arbington 5803, 5505.
			text = "Commander Ashlam Valorfist at Chillwind Camp, in the Western Plaguelands, gives the first three "
				.. "quests. Alchemist Arbington, beside him, sends you for Skeletal Fragments, then to Krinkle Goodsteel "
				.. "in Gadgetzan for a mold. Krinkle has you forge the key at Fire Plume Ridge in Un'Goro Crater and take "
				.. "it back to Arbington. Arbington then sends you for Araj's Scarab from Andorhal. His last quest, The "
				.. "Key to Scholomance, gives the {item:13704:Skeleton Key}. It opened the door in the original game. "
				.. "Whether Forever still locks the door is not known yet.",
			quests = keyIDs.Alliance,
			-- The key is the last quest's reward: the player has it once that is handed in.
			haveWhen = "done",
		},
		{
			faction = "Horde",
			title = "The Skeleton Key",
			-- Derrington 5096, 5098, 838; Dithers 964, 5514; Krinkle 5802, back to Dithers; Dithers 5804;
			-- Derrington 5511.
			text = "High Executor Derrington at the Bulwark gives the first three quests. Apothecary Dithers, beside "
				.. "him, sends you for Skeletal Fragments, then to Krinkle Goodsteel in Gadgetzan for a mold. Krinkle "
				.. "has you forge the key at Fire Plume Ridge in Un'Goro Crater and take it back to Dithers. Dithers "
				.. "then sends you for Araj's Scarab from Andorhal. The last quest, The Key to Scholomance, is "
				.. "Derrington's again and gives the {item:13704:Skeleton Key}. It opened the door in the original "
				.. "game. Whether Forever still locks the door is not known yet.",
			quests = keyIDs.Horde,
			-- The key is the last quest's reward: the player has it once that is handed in.
			haveWhen = "done",
		},
		{
			title = "The Viewing Room Key",
			kind = "key",
			-- Rattlegore's drop (Forever's quest data for item 13873, and his loot here). The door it opened
			-- and that one key does for the group are the original game's (a second guide says the same), kept
			-- on the list of things to check in game (2026-11-05).
			text = "Rattlegore drops the {item:13873:Viewing Room Key:1}. In the original game, it opened the Viewing "
				.. "Room door, the way on to Vectus and Marduk Blackpool, and one key did for the whole group. This is "
				.. "not yet checked on Forever.",
		},
		{
			title = "Kirtonos the Herald, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Kirtonos the Herald",
			-- The quest (5384) gives the blood when it is taken: its sourceItemId in QuestieDB.
			text = "Place the {item:13523:Blood of Innocents:1} in the brazier on the porch, and he comes. Eva "
				.. "Sarkhoff gives you the blood when you take her quest Kirtonos the Herald. The Blood Steward of "
				.. "Kirtonos, Jandice Barov and Doctor Theolen Krastinov also drop it.",
		},
		{
			title = "Death Knight Darkreaver, a hidden boss",
			boss = "Death Knight Darkreaver",
			text = "Use the Divination Scryer in the heart of the Great Ossuary's basement. Spirits come first; once "
				.. "they are dead, he comes. Alliance paladins need him for Judgment and Redemption, Horde shamans "
				.. "for The Darkreaver Menace.",
		},
		{
			title = "Kormok, a hidden boss",
			boss = "Kormok",
			-- Only Kormok's versions of the pieces (8969, 8992) give his brazier: their sourceItemId in
			-- QuestieDB (the deep audit of 2026-10-30, g07-21).
			text = "Use the {item:22052:Brazier of Beckoning} to call his spirit. Bodley, inside Blackrock Mountain, "
				.. "gives it with the Kormok versions of The Left Piece and The Right Piece of Lord Valthalak's Amulet.",
		},
		{
			title = "J'eevee, for warlocks",
			classOnly = "WARLOCK",
			text = "On Imp Delivery, take the {item:18688:Imp in a Jar} to the alchemy lab. Once the parchment is made, "
				.. "take the jar back to Gorzeeki Wildeyes in the Burning Steppes.",
		},
		{
			title = "Darkmaster Gandling",
			boss = "Darkmaster Gandling",
			-- Kept on the list of things to check in game.
			text = "In the original game, he came out only once the six room bosses were dead. This is not yet "
				.. "checked on Forever.",
		},
	},

	addQuests = keyQuests,

	-- The Last Barov (5344, 5342): its targets, Alexi and Weldon Barov, die at the Bulwark and at
	-- Chillwind Camp, outside the dungeon (the owner's rule, 2026-10-29).
	removeQuests = { 5344, 5342 },
})

-- The reputation the dungeon's other quests give (QuestieDB).
local REPUTATION = {
	[5529] = { faction = "Argent Dawn", amount = 100 }, -- Plagued Hatchlings
	[5531] = { faction = "Argent Dawn", amount = 25 },  -- Betina Bigglezink
	[4771] = { faction = "Argent Dawn", amount = 200 }, -- Dawn's Gambit
	[5582] = { faction = "Argent Dawn", amount = 50 },  -- Healthy Dragon Scale
	[7647] = { faction = "Stormwind", amount = 200 },   -- Judgment and Redemption
	[8258] = { faction = "Horde", amount = 200 },       -- The Darkreaver Menace
}
for _, quest in ipairs(ns.GetInstance("Scholomance").quests) do
	local reputation = REPUTATION[quest.questID]
	if reputation then
		quest.rewards = quest.rewards or {}
		quest.rewards.reputation = { reputation }
	end
	-- Barov Family Fortune names what follows it, The Last Barov, taken out above (QuestieDB's
	-- nextQuestInChain 5342 and 5344; the deep audit of 2026-10-30, g07-13).
	if quest.questID == 5341 or quest.questID == 5343 then
		quest.note = "Leads to The Last Barov, done outside the dungeon."
	end
end
