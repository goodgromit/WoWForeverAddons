local _, ns = ...

--[[
	The Deadmines, written by hand over the generated data.

	Facts from warcraft.wiki.gg, "Deadmines (Classic)" (CC BY-SA 4.0), put in our own words:
	run order, where each boss stands, and the mechanics worth knowing. Loot, quests and
	levels stay as generated from Forever's own data, since Forever changed some of them.
]]

ns.AmendInstance("TheDeadmines", {
	-- The client's two levels, by the names Blizzard's maps give them. Data/Authored/ClassicMaps.lua,
	-- which loads later, puts the whole dungeon's map before them and sets the names the map shows.
	floorNames = { "The Deadmines", "Ironclad Cove" },
	description = "Beneath Moonbrook lie the gold mines Stormwind abandoned during the First War. "
		.. "Edwin VanCleef's Defias Brotherhood has made them its stronghold, and deep inside, in a hidden "
		.. "sea cave, his crew is finishing a warship meant for Stormwind.",

	-- Inside the instance, in the order a run meets them, as the client names them there (the owner's
	-- recording of 2026-11-07). "Defias Hideout" is the mine outside, before the portal.
	areas = { "The Deadmines", "Mast Room", "Goblin Foundry", "Ironclad Cove" },

	--[[
		Before you go (the overview): the two Alliance chains done outside before their dungeon steps
		open (the deep audit of 2026-10-30, G01-17). From QuestieDB's Forever data: The Defias
		Brotherhood runs 65 > 132 > 135 > 141 > 142 > 155 (Gryan Stoutmantle at Sentinel Hill, Wiley the
		Black in Lakeshire, Mathias Shaw in Stormwind, the Defias Messenger, then the Defias Traitor's
		escort to the Brotherhood's hideout), and 155 opens both 166 and Red Silk Bandanas (214). Alba
		Fairmoon's chain ends with Destruction in Deadmines (92753); its A Dynamite Plan (92749) asks
		Sprite Jumpsprocket, in Stormwind's Dwarven District, for 10 Coarse Dynamite, "from crafting,
		trading, or the auction house" (QuestieDB's objective; it gives the item as 4358, which its item
		list calls Rough Dynamite, so the note names the dynamite without a link). Plain notes: neither
		gives a key.
	]]
	prepare = {
		{
			faction = "Alliance",
			title = "The Defias Brotherhood chain",
			text = "Gryan Stoutmantle at Sentinel Hill in Westfall starts The Defias Brotherhood. Its first steps take "
				.. "you to Lakeshire and Stormwind and back, then send you after a Defias Messenger in Westfall. Then you "
				.. "escort the Defias Traitor to the Brotherhood's hideout. After that, Gryan gives the step done here, "
				.. "and Scout Riell gives Red Silk Bandanas.",
		},
		{
			faction = "Alliance",
			title = "Alba Fairmoon's chain",
			text = "Alba Fairmoon at Sentinel Hill gives Destruction in Deadmines at the end of a chain of quests in "
				.. "Westfall and Stormwind. On the way, Sprite Jumpsprocket in the Dwarven District of Stormwind asks for "
				.. "10 Coarse Dynamite: make it, trade for it or buy it at the auction house.",
		},
	},

	bossOrder = {
		"Rhahk'Zor", "Miner Johnson", "Sneed's Shredder", "Sneed", "Gilnid",
		"Mr. Smite", "Cookie", "Captain Greenskin", "Edwin VanCleef",
	},

	-- Each boss's encounter id, from the owner's recording of 2026-11-07 (a won fight under his name for
	-- each): a win of that fight marks him killed, so the map no longer watches for his corpse.
	bosses = {
		["Rhahk'Zor"] = {
			area = "The Deadmines",
			encounterID = 2741,
			notes = { "An ogre foreman with heavy armour who hits hard; the first boss inside." },
		},
		["Miner Johnson"] = {
			area = "The Deadmines",
			encounterID = 3676,
		},
		-- Sneed's Shredder and Sneed are one fight, encounter 2742 (the owner's recording of 2026-11-07):
		-- the shredder breaks, Sneed climbs out, and the fight ends as he dies. A win counts for both
		-- (ns.BossesForEncounter).
		["Sneed's Shredder"] = {
			area = "Mast Room",
			encounterID = 2742,
			notes = {
				"Sneed fights from inside the shredder, and climbs out when it is destroyed.",
				"The shredder ignores burning, bleeding and stun-style concussion effects.",
			},
			spellFlags = { [7399] = { "Important" }, [5141] = { "Damage" } },
		},
		["Sneed"] = {
			area = "Mast Room",
			encounterID = 2742,
			notes = { "Steps out of his shredder once it breaks." },
		},
		["Gilnid"] = {
			area = "Goblin Foundry",
			encounterID = 2743,
			notes = {
				"Arrives with three goblin helpers.",
				"Defeating him opens the door onward.",
			},
		},
		["Mr. Smite"] = {
			area = "Ironclad Cove",
			encounterID = 2745,
			notes = {
				"Stomps at 75% and again at 50% health, stunning the whole party. It cannot be interrupted.",
				"Changes weapons partway through the fight.",
			},
			-- The stages follow foreverchanges.pro's account of the fight; the spells are in
			-- Data/Authored/Abilities.lua.
			stages = {
				{ title = "Stage One", description = "Mr. Smite opens the fight with a sword and shield." },
				{ title = "Stage Two: 66% Health", description = "He stomps, stunning everyone near him, and takes up two axes.",
					spells = { 6432, 3391 } },
				{ title = "Stage Three: 33% Health", description = "He stomps again and takes up his hammer.",
					spells = { 6435 } },
			},
		},
		["Cookie"] = {
			area = "Ironclad Cove",
			encounterID = 2746,
			notes = { "The ship's cook, found aboard the juggernaut." },
		},
		["Captain Greenskin"] = {
			area = "Ironclad Cove",
			encounterID = 2744,
			notes = { "Holds the top of the ship with two of his crew." },
		},
		["Edwin VanCleef"] = {
			area = "Ironclad Cove",
			encounterID = 2747,
			notes = {
				"Waits in the captain's cabin at the top of the ship.",
				"Stuns, and calls his guards in when his health runs low.",
			},
			spellFlags = { [5200] = { "Damage", "Important" }, [3391] = { "Tank" } },
		},
	},
})

-- Red Silk Bandanas (214) needs The Defias Brotherhood's part 6 (155) only, as Forever's quest data has it
-- (the generated data lists all six parts). That chain is not its own (the owner's call of 2026-11-07), so
-- its row has no + (noChain); while it is locked it says "Requires: The Defias Brotherhood (Part 6)".
for _, quest in ipairs(ns.GetInstance("TheDeadmines").quests) do
	if quest.questID == 214 then
		quest.prerequisites = { { questID = 155, name = "The Defias Brotherhood" } }
		quest.noChain = true
	end
end
