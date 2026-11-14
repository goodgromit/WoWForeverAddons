local _, ns = ...

--[[
	Blackfathom Deeps, written by hand over the generated data.
	Facts from warcraft.wiki.gg, "Blackfathom Deeps (Classic)" (CC BY-SA 4.0), in our own words.
]]

ns.AmendInstance("BlackfathomDeeps", {
	description = "Once a temple to Elune on the Ashenvale shore, Blackfathom Deeps sank beneath the sea in the "
		.. "Sundering. The Twilight's Hammer now holds its flooded halls, guarding Aku'mai, a beast prized by the "
		.. "Old Gods, while naga and murlocs prowl its pools.",

	-- The client's own area names, as a recorded run (2026-10-11) saw them.
	areas = { "The Drowned Sacellum", "The Pool of Ask'ar", "Moonshrine Ruins", "The Forgotten Pool", "Moonshrine Sanctum",
		"Aku'mai's Lair" },

	--[[
		Before you go (the overview), from the quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29,
		step 9 of its plan): Baron Aquanis, the boss the Horde calls up. From QuestieDB's Forever data:
		the Fathom Stone (object 177964, inside) gives the Fathom Core (16762) that Amongst the Ruins
		(6921, Je'neu Sancrea's) asks for, and he drops the Strange Water Globe (16782), which starts
		Baron Aquanis (6922). Horde only, as both quests are; whether the Alliance can click the stone
		is left for a check in game.
	]]
	prepare = {
		{
			faction = "Horde",
			title = "Baron Aquanis, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Baron Aquanis",
			text = "Je'neu Sancrea at Zoram'gar Outpost gives Amongst the Ruins. In the dungeon, click the Fathom Stone "
				.. "in the water: it gives the {item:16762:Fathom Core} and Baron Aquanis rises from it. He drops the "
				.. "{item:16782:Strange Water Globe:2}, which starts the quest Baron Aquanis.",
		},
	},

	--[[
		Seeking the Kor Gem (95042), Forever's own Horde paladin quest (step 9): QuestieDB's Forever data
		(level, giver and taker Ulric Frostveil, npc 259649, his spot, the Corrupted Kor Gem 6995 it asks
		for, the Purified Kor Gem 272448 and Undercity +75 it gives) and foreverchanges.pro's quest page
		(2026-10-30, "New in Forever"; the same level, place and rewards). The gem drops from the Sea
		Witches inside and the Tide Priestesses and Oracles at the entrance, as the Alliance's Test of
		Righteousness note already says. Its XP, 2,000, is from the site's quest page, which marks the
		quest as new in Forever (the audit's XP pass, 2026-10-30).
		Its Purified Kor Gem is for A Moon-Kissed Blade (95036, the Deadmines' Horde paladin quest):
		foreverchanges.pro's quest page for 95036 lists the gem among what Trevan Rol needs, and
		QuestieDB's gem names 95036 as its related quest, though QuestieDB's record of 95036 does not
		list it (the deep audit of 2026-10-30, G02-04). Every Horde paladin on Forever is Forsaken, so
		the link holds for every player who sees this quest.

		Seeking the Kor Gem (1442), the Alliance's, listed beside it the same way (the owner's call of
		2026-11-03): QuestieDB's Forever data (level 22, from 20; Alliance paladins, humans and dwarves;
		Thundris Windweaver in Auberdine gives and takes it, npc 3649; the Corrupted Kor Gem 6995; a
		sub-quest of The Test of Righteousness, 1654, and repeatable) and foreverchanges.pro's quest page
		(2026-11-03: the Purified Kor Gem 7083 and 875 XP, Forever's: "Gives 875 experience instead of
		440"). So 1654's note here no longer names Thundris: this row does. As a sub-quest (QuestieDB's
		parentQuest, 1654), Thundris offers it only while The Test of Righteousness is in the quest log:
		parentQuest locks the row until then, and its lock line and note say so (the quest
		review of 2026-11-03). The Horde's 95042 has no parent quest, so it stays open.
	]]
	addQuests = {
		{
			questID = 1442, name = "Seeking the Kor Gem", level = 22, requiredLevel = 20, faction = "Alliance",
			classOnly = "PALADIN",
			pickup = "Thundris Windweaver, Auberdine, Darkshore",
			turnin = "Thundris Windweaver, Auberdine, Darkshore",
			startMap = { mapID = 1439, x = 0.374, y = 0.401, label = "Thundris Windweaver" },
			endMap = { mapID = 1439, x = 0.374, y = 0.401, label = "Thundris Windweaver" },
			objective = "Bring a Kor Gem to Thundris Windweaver in Darkshore.",
			parentQuest = { questID = 1654, name = "The Test of Righteousness" },
			note = "Repeatable. Thundris gives it only while The Test of Righteousness is in your quest log. The "
				.. "Corrupted Kor Gem drops from the Blackfathom Sea Witches inside, or the Tide Priestesses and Oracles "
				.. "at the entrance.",
			rewards = {
				xp = 875,
				items = { { itemID = 7083, name = "Purified Kor Gem", quality = 1 } },
			},
		},
		{
			questID = 95042, name = "Seeking the Kor Gem", level = 25, requiredLevel = 20, faction = "Horde",
			classOnly = "PALADIN",
			pickup = "Ulric Frostveil, Zoram'gar Outpost, Ashenvale",
			turnin = "Ulric Frostveil, Zoram'gar Outpost, Ashenvale",
			startMap = { mapID = 1440, x = 0.1186, y = 0.3446, label = "Ulric Frostveil — Zoram'gar Outpost" },
			endMap = { mapID = 1440, x = 0.1186, y = 0.3446, label = "Ulric Frostveil — Zoram'gar Outpost" },
			objective = "Bring a Kor Gem to Ulric Frostveil in Ashenvale.",
			note = "A paladin quest for the Horde. The Corrupted Kor Gem drops from the Blackfathom Sea Witches inside, "
				.. "or the Tide Priestesses and Oracles at the entrance. The Purified Kor Gem it gives is for A Moon-Kissed "
				.. "Blade, which Trevan Rol in the Sepulcher takes with lumber from the Deadmines.",
			rewards = {
				xp = 2000,
				items = { { itemID = 272448, name = "Purified Kor Gem" } },
				reputation = { { faction = "Undercity", amount = 75 } },
			},
		},
	},

	-- In Search of Thaelrid (1198) leads to Blackfathom Villainy (1200), by Forever's quest data. A row marked
	-- optional from 2026-11-03, out from the owner's call of 2026-11-07 (a talk that only leads to a dungeon quest),
	-- back on the owner's report of 2026-11-08: its talk is with Argent Guard Thaelrid inside the dungeon, and the
	-- game lists it as a dungeon quest.
	questPatches = {
		[1198] = { note = "Optional: it leads to Blackfathom Villainy." },
	},

	bosses = {
		["Ghamoo-ra"] = {
			area = "The Pool of Ask'ar",
			notes = { "A giant turtle in the first great pool." },
		},
		["Lady Sarevess"] = {
			area = "The Pool of Ask'ar",
			notes = { "A naga sorceress in a side cavern off the pool; optional." },
		},
		["Gelihast"] = {
			notes = { "A murloc chieftain in his shrine. His followers run for help when they are low on health, so finish them off." },
		},
		["Lorgus Jett"] = {
			notes = { "A Twilight's Hammer shaman patrolling the tunnels." },
		},
		["Old Serra'kis"] = {
			area = "The Forgotten Pool",
			notes = { "A threshadon in the underwater cave; optional. He only melees." },
			-- Seen in a recorded run's log, but nothing to watch for in the fight (the player who ran it).
			notAbilities = { [8433] = true }, -- Leech Pulse
		},
		["Twilight Lord Kelris"] = {
			area = "Moonshrine Sanctum",
			notes = {
				"Clear the cultists around him one group at a time before pulling him.",
				"The braziers of the sanctum open the way to Aku'mai; each one lit calls a wave of enemies, so rest between them.",
			},
		},
		["Aku'mai"] = {
			area = "Aku'mai's Lair",
			notes = { "The hydra at the end of the Deeps, and the hardest fight here: keep a steady tank and healer on it." },
		},
	},
})
