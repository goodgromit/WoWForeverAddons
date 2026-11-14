local _, ns = ...

--[[
	Onyxia's Lair, ready before the raid opens: its attunement before you go, and its quests, written
	by hand over its data (Data/Instances/Raids.lua) from the quest audit of 2026-10-29
	(Dev/docs/audit_2026-10-29, step 18 of its plan). Facts only, in our own words.

	Before you go: the Onyxia attunement for the player's side, the same entry Upper Blackrock Spire
	shows (ns.OnyxiaAttunement, Data/Authored/BlackrockSpire.lua: one source for the two). Its steps
	are the quests the journal keeps under Blackrock Depths and the Spire, and the steps of their
	chains (Data/Generated/QuestSteps.lua); Before you go finds them there.

	The quests, from QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game)
	and foreverchanges.pro's quest pages (2026-10-30):
	  Victory for the Alliance (7495) and Victory for the Horde (7490) start from each side's Head of
	  Onyxia (18423, 18422; Onyxia drops both) and are handed in to Highlord Bolvar Fordragon in
	  Stormwind and to Thrall in Orgrimmar. Each needs its side's amulet quest first (6502, 6602;
	  QuestieDB's preQuestSingle), so its chain is the attunement's, then that quest. Level 60, from
	  60 (the site: "Requires level 60 instead of 50" on 7495). Stormwind +200 and Orgrimmar +200
	  (QuestieDB's reputationReward, factions 72 and 76; the site's pages agree). Victory for the
	  Horde gives 9,950 XP: its page's change line, "Gives 9,950 experience instead of 13,250".
	  Victory for the Alliance gives 9,950 too, but only the original game's number: its page marks
	  only the level as changed, and the site's Stormwind City list gives the 9,950 as a plain
	  (Classic's) number, not in gold (Forever's own). Step 18 left it out; on the owner's choice of
	  2026-10-30 (the audit's step 19) it is shown, and the Quests tab marks it as the original game's
	  (Data/Generated/OriginalXP.lua).
	  What follows each, Celebrating Good Times (7496, Bolvar to Major Mattingly in the Valley of
	  Heroes) and For All To See (7491, Thrall to Overlord Runthak in the Valley of Strength), is done
	  in the city and leads nowhere near the raid, so it is not listed (the owner's rule, 2026-10-29);
	  each Victory quest's note names it and its choice of Onyxia Blood Talisman, Dragonslayer's
	  Signet or Onyxia Tooth Pendant (the site's pages for 7496 and 7491, Classic's rewards, unchanged
	  there as far as is known).
	  The Forging of Quel'Serrar (7509) is done here: Onyxia's breath heats the blade, which is driven
	  into her body (QuestieDB files it under Onyxia's Lair, area 2159). It is Dire Maul West's own
	  quest, copied from there so the two agree (its rewards: Quel'Serrar, Shen'dralar +200 in both
	  sources), with Lorekeeper Lydros, who gives and takes it, placed in Dire Maul. Its 9,950 XP is
	  the original game's: the site's page for it calls it unchanged from Classic, and its Onyxia's
	  Lair list gives the 9,950 as a plain (Classic's) number. Step 18c took it out here; step 19 put
	  it back, the same as Dire Maul's copies, and the Quests tab marks it in both places as the
	  original game's. Since 2026-11-03 it is left out for now, with the rest of its chain (see the
	  end of this file).

	Loads after BlackrockSpire.lua and DireMaul.lua, whose quests it reads, and before ItemNames.lua.
]]

local function QuestOf(key, questID)
	for _, quest in ipairs(ns.GetInstance(key).quests) do
		if quest.questID == questID then return quest end
	end
	error("OnyxiasLair.lua: " .. key .. " has no quest " .. questID)
end

local function Copy(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for field, inner in pairs(value) do copy[field] = Copy(inner) end
	return copy
end

-- The Victory quest's chain: the amulet quest's own, then the amulet quest. Copies, so the
-- translations are laid over each once.
local function After(questID)
	local amulet = QuestOf("UpperBlackrockSpire", questID)
	local chain = Copy(amulet.prerequisites or {})
	chain[#chain + 1] = { questID = amulet.questID, name = amulet.name }
	return chain
end

local CHOICE = "Onyxia Blood Talisman, Dragonslayer's Signet or Onyxia Tooth Pendant"

-- Quel'Serrar, as Dire Maul West lists it, given and taken by Lydros in Dire Maul.
local quelSerrar = Copy(QuestOf("DireMaulWest", 7509))
quelSerrar.pickup = "Lorekeeper Lydros, inside Dire Maul"
quelSerrar.turnin = "Lorekeeper Lydros, inside Dire Maul"
-- For warriors and paladins (QuestieDB's requiredClasses 3), as Dire Maul's copies say (DireMaul.lua, which
-- also gives West's its classes; its objective is Data/Instances/DireMaulWest.lua's).
quelSerrar.note = "For warriors and paladins."

ns.AmendInstance("OnyxiasLair", {
	prepare = {
		ns.OnyxiaAttunement("Alliance"),
		ns.OnyxiaAttunement("Horde"),
	},
	addQuests = {
		{
			questID = 7495, name = "Victory for the Alliance", level = 60, requiredLevel = 60, faction = "Alliance",
			objective = "Take the Head of Onyxia to Highlord Bolvar Fordragon in Stormwind.",
			pickup = "Head of Onyxia, dropped by Onyxia",
			startItem = { itemID = 18423, name = "Head of Onyxia", note = "Dropped by Onyxia." },
			turnin = "Highlord Bolvar Fordragon, Stormwind City",
			endMap = { mapID = 1453, x = 0.802, y = 0.384, label = "Highlord Bolvar Fordragon" },
			note = "Then Bolvar sends you to Major Mattingly in the Valley of Heroes with Celebrating Good Times, "
				.. "which gives a choice of " .. CHOICE .. ".",
			prerequisites = After(6502),
			-- The original game's XP (see above).
			rewards = { xp = 9950, reputation = { { faction = "Stormwind", amount = 200 } } },
		},
		{
			questID = 7490, name = "Victory for the Horde", level = 60, requiredLevel = 60, faction = "Horde",
			objective = "Take the Head of Onyxia to Thrall in Orgrimmar.",
			pickup = "Head of Onyxia, dropped by Onyxia",
			startItem = { itemID = 18422, name = "Head of Onyxia", note = "Dropped by Onyxia." },
			turnin = "Thrall, Orgrimmar",
			endMap = { mapID = 1454, x = 0.317, y = 0.378, label = "Thrall" },
			note = "Then Thrall sends you to Overlord Runthak in the Valley of Strength with For All To See, "
				.. "which gives a choice of " .. CHOICE .. ".",
			prerequisites = After(6602),
			rewards = { xp = 9950, reputation = { { faction = "Orgrimmar", amount = 200 } } },
		},
		quelSerrar,
	},
})

--[[
	Quel'Serrar left out for now: the owner's call of 2026-11-03, the whole chain out of every page
	until Onyxia's Lair opens, its data kept so it can come back. That is Nostro's Compendium (7507)
	and The Forging of Quel'Serrar (7508, 7509) on Dire Maul's three wings, and this raid's copy of
	7509. Everything about them stays as it was, in DireMaul.lua and above: their classes, notes,
	wing wording, XP and translations. To bring the chain back, delete this one removal.
]]
for key, questIDs in pairs({
	DireMaulEast = { 7507, 7508, 7509 },
	DireMaulNorth = { 7507, 7508, 7509 },
	DireMaulWest = { 7507, 7508, 7509 },
	OnyxiasLair = { 7509 },
}) do
	ns.AmendInstance(key, { removeQuests = questIDs })
end
