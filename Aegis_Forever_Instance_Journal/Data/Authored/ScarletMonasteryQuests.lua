local _, ns = ...

--[[
	The Scarlet Monastery's four wings, written by hand over their data (Data/Instances/
	ScarletMonastery*.lua) and the overlays before this file, from the quest audit of 2026-10-29
	(Dev/docs/audit_2026-10-29, step 7 of its plan). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): Vorrel's
	Wedding Ring (5538) drops only from Nancy Vishas (npc 3984), who stands in Alterac Mountains, not
	from Interrogator Vishas; the Alliance road to In the Name of the Light (1053): Brother Crowley in
	Stormwind (6141, a lead-in that can be skipped) to Brother Anton at Nijel's Point, Down the Scarlet
	Path (261, 30 Undead Ravagers), then Anton's letter (1052, its start item 5539) to Raleigh the
	Devout in Southshore; Mage's Wand (1952) from Tabetha, which needs both Rituals of Power (1951) and
	Items of Power (1948). foreverchanges.pro's quest pages (2026-10-30): Vorrel's Revenge gives
	Vorrel's Boots (7751) on top of the choice; Mage's Wand asks you to speak with Tabetha after her
	ritual and gives a choice of three wands. Its Library page puts the Scarlet Key (7146) in Doan's
	Strongbox, as the Library's own data already says.

	What the Scarlet Key opens is the original game's: no source read says so for Forever, and the
	note says as much. No quest gives the key, so its entry is a key no quest gives (kind = "key").
	Left out on the owner's rule: The Eye of Bhossca (78676), a Season of Discovery rune quest. The
	quests' XP and reputation are the audit's XP and reputation passes' (steps 14c and 15b); every
	wing's copy of a shared quest gives the same reputation.

	Loads after FromGuides.lua, FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

local function QuestsOf(key)
	local quests = {}
	for _, quest in ipairs(ns.GetInstance(key).quests) do quests[quest.questID] = quest end
	return quests
end

-- The note both wings show. Each gets its own copy, so the translations are laid over each once.
local function ScarletKey()
	return {
		title = "The Scarlet Key",
		kind = "key",
		-- Its use is the original game's; kept on the list of things to check in game.
		text = "{item:7146:The Scarlet Key:2} is in Doan's Strongbox, behind Arcanist Doan in the Library. In the "
			.. "original game, it opened the doors to the Armory and the Cathedral. This is not yet checked on Forever.",
	}
end

--[[
	For the Alliance, the road to In the Name of the Light (1053). A plain note: its quests are already
	In the Name of the Light's steps on the Quests tab. On every wing that lists the quest, as its
	targets are in each: the Library, the Armory and the Cathedral (the owner, 2026-10-30).
]]
local function RoadToTheLight()
	return {
		faction = "Alliance",
		title = "The road to In the Name of the Light",
		text = "Brother Crowley in Stormwind sends you to Brother Anton at Nijel's Point, in Desolace. Anton's "
			.. "Down the Scarlet Path asks you to kill 30 Undead Ravagers. He then gives you a letter for Raleigh "
			.. "the Devout in Southshore, who gives In the Name of the Light.",
	}
end

--[[
	For mages, the road to Rituals of Power (the owner's chain of 2026-11-13, below): the three quests to do before going
	in, so that Rituals of Power is taken before the book is reached. A chain to do (chain), done once the three are, not
	a key; their marks on the world map (mapMarks, UI/QuestMap.lua). For both sides: each side's trainers give the first.
]]
local function RoadToRituals()
	return {
		classOnly = "MAGE",
		title = "The road to Rituals of Power",
		text = "A mage trainer in Stormwind, Ironforge, Orgrimmar, Thunder Bluff or the Undercity gives Journey to the "
			.. "Marsh, to Tabetha in Dustwallow Marsh. Her Hidden Secrets sends you to Magus Tirth in the Shimmering "
			.. "Flats, in Thousand Needles. After his Get the Scoop, take Rituals of Power from him before you go in: "
			.. "the book is in the Library.",
		quests = { 1947, 1949, 1950 },
		haveWhen = "done",
		chain = true,
		mapMarks = true,
	}
end

-- Before you go (the Quests tab): the Scarlet Key, from the Library, on the Armory and the Cathedral;
-- the road to In the Name of the Light on those two and the Library; the road to Rituals of Power on the Library.
ns.AmendInstance("ScarletMonasteryLibrary", { prepare = { RoadToTheLight(), RoadToRituals() } })
ns.AmendInstance("ScarletMonasteryArmory", { prepare = { ScarletKey(), RoadToTheLight() } })
ns.AmendInstance("ScarletMonasteryCathedral", { prepare = { ScarletKey(), RoadToTheLight() } })

-- Vorrel's Revenge: the ring is outside the dungeon, and the boots come with the choice ("You also
-- receive"), named in Data/Authored/ItemNames.lua (their slot and quality too).
ns.AmendInstance("ScarletMonasteryGraveyard", {
	questPatches = {
		[1051] = {
			note = "Nancy Vishas has the ring, in Alterac Mountains, outside the dungeon. Interrogator Vishas does "
				.. "not drop it.",
		},
	},
})
do
	local rewards = QuestsOf("ScarletMonasteryGraveyard")[1051].rewards
	rewards.also = { { itemID = 7751 } }
end

--[[
	Rituals of Power: what the book leads to. Final Passage (1394), done in Thousand Needles after the
	Library's Test of Lore (QuestieDB: 1160, then 6628 with Parqual's question, then 1394 at Dorn
	Plainstalker), is listed as the chain's last step, locked behind the two before it, with its choice
	of Windstorm Hammer or Dancing Flame: the owner's rule of 2026-11-03, that a dungeon's chain stays
	whole as quests (it had been taken out on the owner's rule of 2026-10-29). Its Horde +200 is QuestieDB's
	(faction 67); its 4,200 XP is marked as the original game's (Data/Generated/OriginalXP.lua), as
	foreverchanges.pro's quest page calls it unchanged.
]]
ns.AmendInstance("ScarletMonasteryLibrary", {
	questPatches = {
		[1951] = {
			note = "The book lies at the north end of the hallway to Arcanist Doan. Once this and Items of Power are "
				.. "done, Tabetha gives Mage's Wand: speak with her after her ritual and choose one of three wands.",
		},
	},
})

-- Final Passage right after Test of Lore, so the list reads in the chain's order.
ns.ListQuestAfter("ScarletMonasteryLibrary", 1394, 1160)

--[[
	Rituals of Power's whole chain, for mages of both sides (the owner, 2026-11-13: "we are missing this quest for SM
	Library", then the chain's list from the site's quest pages, "this is the whole chain we need": Journey to the
	Marsh, Hidden Secrets, Get the Scoop, Rituals of Power and Mage's Wand, 9,890 XP in all). Mage's Wand (1952), its
	last, is a row of its own after Rituals of Power, as Final Passage is after Test of Lore (the owner's rule of
	2026-11-03: a dungeon's chain stays whole as quests). Its page (the site's, 2026-11-13): Tabetha gives and takes it
	("Speak with Tabetha after her ritual."), 3,150 XP, a choice of Icefury Wand (7514), Nether Force Wand (11263) or
	Ragefire Wand (7513), all rare; "unchanged in Forever as far as is known", so its XP is marked as the original
	game's (Data/Generated/OriginalXP.lua), as Rituals of Power's is.
	Journey to the Marsh, Hidden Secrets and Get the Scoop are steps of their own already (Data/Generated/QuestSteps.lua:
	Forever's quest data and the site's XP: 290, 1,450 and 1,850).
	Items of Power (1948): Forever's quest data (the snapshot of 2026-10-20 and the game's copy of 2026-11-07
	alike) has Mage's Wand need it as well as Rituals of Power (preQuestGroup 1948 and 1951), and Items of Power come
	after Journey to the Marsh, from and to Tabetha: "Bring 1 Jade and the Bolt Charged Bramble" (items 1529 and 7272;
	Tabetha's Instructions, 7516, given with it; the Witherbark Totem Stick, 7273, which the Witherbark trolls of
	Arathi Highlands drop, its Use line "Gather 10 totem sticks, and use them at the Stone of Outer Binding", the same
	in the original and Forever clients on the site's item page; the Stone of Outer Binding, object 2690, its spell
	focus, 103660, and the Bolt Charged Bramble, 103662, all at Arathi Highlands 52.0 50.8 in Forever's quest data). The site's page
	for it agrees (3,150 XP, from and to Tabetha, unchanged) and says nothing against it, though the site's list of
	the chain leaves it out. So it is a step of Mage's Wand's chain, after Journey to the Marsh, with marks of its own
	on the world map (mapMarks); the owner confirmed it's part of the chain (2026-11-13: "it appears its part of the
	chain"). Jade: Forever's quest data has it from tin, iron and gold veins, chests, lockboxes and gem sacks (the
	site's item page lists the lockboxes and gem sacks, not the veins).
	Journey to the Marsh's givers, all four confirmed by the owner (2026-11-13: "it looks like it can be all 4"): the
	Alliance's Bink in Ironforge and Jennea Cannon in Stormwind, the Horde's Ursyn Ghull in Thunder Bluff and Deino in
	Orgrimmar. Anastasia Hartwell in the Undercity, a Horde giver too, is from Forever's quest data alone (both copies;
	the owner didn't name her). The step keeps its first giver for the Quests tab and names the others in its note, as
	the journal does for a quest several trainers give; the others' spots (alsoStarts, from Forever's quest data) give
	each its own "!" on the world map.
	Before you go, for mages: the three steps to do before going in (RoadToRituals, above).
]]
local TABETHA = "Tabetha, Dustwallow Marsh"
-- Tabetha's spot, west of Theramore (from Forever's quest data, as her other quests have it). A new table each call.
local function Tabetha() return { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" } end
local function MarshChain(...)
	local named = {
		[1947] = "Journey to the Marsh", [1948] = "Items of Power", [1949] = "Hidden Secrets", [1950] = "Get the Scoop",
		[1951] = "Rituals of Power",
	}
	local list = {}
	for _, questID in ipairs({ ... }) do list[#list + 1] = { questID = questID, name = named[questID] } end
	return list
end
ns.AddQuestSteps({
	[1948] = {
		name = "Items of Power", level = 40, requiredLevel = 30, faction = "Both", classOnly = "MAGE",
		pickup = TABETHA, startMap = Tabetha(), turnin = TABETHA, endMap = Tabetha(),
		objective = "Bring 1 Jade and the Bolt Charged Bramble to Tabetha in Dustwallow Marsh.",
		note = "Jade comes from tin, iron and gold veins, chests, lockboxes and gem sacks. Witherbark trolls in "
			.. "Arathi Highlands drop Witherbark Totem Sticks: use 10 of them at the Stone of Outer Binding there "
			.. "(52, 51) to make the Bolt Charged Bramble.",
		prerequisites = MarshChain(1947),
		rewards = { xp = 3150 },
		mapMarks = true,
	},
})
ns.AmendQuestStep(1947, {
	alsoStarts = { { mapID = 1453, x = 0.4956, y = 0.858, label = "Jennea Cannon, Stormwind City" } },
	horde = {
		alsoStarts = {
			-- (Anastasia Hartwell: from Forever's quest data alone; the owner confirmed the other four, 2026-11-13)
			{ mapID = 1458, x = 0.8514, y = 0.1003, label = "Anastasia Hartwell, Undercity" },
			{ mapID = 1454, x = 0.3845, y = 0.8613, label = "Deino, Orgrimmar" },
		},
	},
})
ns.AmendInstance("ScarletMonasteryLibrary", {
	addQuests = {
		{
			questID = 1952, name = "Mage's Wand", level = 40, requiredLevel = 30, faction = "Both", classOnly = "MAGE",
			pickup = TABETHA, startMap = Tabetha(), turnin = TABETHA, endMap = Tabetha(),
			objective = "Speak with Tabetha after her ritual.",
			prerequisites = MarshChain(1947, 1948, 1949, 1950, 1951),
			rewards = {
				xp = 3150, choice = true,
				items = {
					{ itemID = 7514, name = "Icefury Wand", quality = 3 },
					{ itemID = 11263, name = "Nether Force Wand", quality = 3 },
					{ itemID = 7513, name = "Ragefire Wand", quality = 3 },
				},
			},
		},
	},
})
-- Mage's Wand right after Rituals of Power, the chain's order.
ns.ListQuestAfter("ScarletMonasteryLibrary", 1952, 1951)
