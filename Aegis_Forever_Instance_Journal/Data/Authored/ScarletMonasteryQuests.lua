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

-- Before you go (the overview): the Scarlet Key, from the Library, on the Armory and the Cathedral;
-- the road to In the Name of the Light on those two and the Library.
ns.AmendInstance("ScarletMonasteryLibrary", { prepare = { RoadToTheLight() } })
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
