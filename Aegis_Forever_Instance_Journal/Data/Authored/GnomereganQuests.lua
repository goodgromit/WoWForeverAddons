local _, ns = ...

--[[
	Gnomeregan's keys and quests, written by hand over its data (Data/Instances/Gnomeregan.lua) and
	the overlays before this file, from the quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29,
	step 9 of its plan). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): the Workshop
	Key (6893) drops from Electrocutioner 6000; Chief Engineer Scooty (2842, Sovik's) leads to
	Gnomer-gooooone! (2843), which gives the Goblin Transponder (9173) when it is handed in; Techbot
	(npc 6231) stands in Dun Morogh, outside the instance; the Sparklematic-Wrapped Box (9363) is the
	reward of 2952, 2953 and 4603-4606, not of 2951. foreverchanges.pro's quest pages (2026-10-30):
	Gnomer-gooooone!'s own text says the transponder lets you step on Scooty's pad in Booty Bay to go
	to Gnomeregan, and the pad there brings you back (unchanged from the original game, as far as the
	site knows); More Sparklematic Action gives the box (out of the journal since 2026-11-12). The rule
	that Rig Wars must be taken first is the journal's own (QuestAudit.lua's note on 2842).

	What the Workshop Key opens is the original game's: no source read says so for Forever, and the
	note says as much. No quest gives it, so its entry is a key no quest gives (kind = "key").
	Gnome Improvement (2948, Alliance) and Nogg's Ring Redo (2950, Horde), done in Ironforge and
	Orgrimmar after the dungeon's Return of the Ring (QuestieDB files them under those cities), are
	listed as the ring chain's last steps, locked until Return of the Ring is done: the owner's rule of
	2026-11-03, that a dungeon's chain stays whole as quests (they had been taken out on the owner's
	rule of 2026-10-29). Their reputation is QuestieDB's (Ironforge and Gnomeregan Exiles +100;
	Orgrimmar +100). Nogg's Ring Redo's 2,750 XP is marked as the original game's
	(Data/Generated/OriginalXP.lua), from the change site's Orgrimmar list; Gnome Improvement's 2,750 is
	Forever's own, which the owner read in game (2026-11-12), so it is not marked. The other quests' XP
	and reputation are the audit's XP and reputation passes' (steps 14a and 15a).

	Loads after FromGuides.lua, FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

local SPARKLEMATIC_BOX = { itemID = 9363, name = "Sparklematic-Wrapped Box", quality = 1 }

-- The box, a row of its own on each quest, so nothing is shared between them; and the quest's XP,
-- where it has one.
local function Box(xp)
	local row = {}
	for field, value in pairs(SPARKLEMATIC_BOX) do row[field] = value end
	return { xp = xp, items = { row } }
end

ns.AmendInstance("Gnomeregan", {
	--[[
		Before you go (the overview): the Workshop Key, which drops inside, and for the Horde the
		Goblin Transponder, their way in from Booty Bay; and Grubbis, the boss Blastmaster Emi
		Shortfuse's event calls.
	]]
	prepare = {
		{
			title = "The Workshop Key",
			kind = "key",
			-- Its use is the original game's; kept on the list of things to check in game.
			text = "Electrocutioner 6000 drops the {item:6893:Workshop Key:1}. In the original game, it opened the "
				.. "Workshop doors to the back entrance. This is not yet checked on Forever.",
		},
		{
			faction = "Horde",
			title = "The Goblin Transponder",
			-- What the transponder does is in the quest's own text; kept on the list of things to check in game.
			-- Rig Wars (2841) needs level 25 (QuestieDB; the deep audit of 2026-10-30, g10-16). foreverchanges.pro's
			-- 2842 and 2843 pages both say "The quest before it, Rig Wars, requires level 25.", and give Chief
			-- Engineer Scooty and Gnomer-gooooone! themselves level 20, as QuestieDB does; the 2842 page calls
			-- Scooty's a change in Forever ("Requires level 20 instead of 25"). Whether Forever still asks for
			-- Rig Wars first is on the list of things to check in game: QuestieDB has no link from Rig Wars to
			-- Scooty's quest (only that 2842 closes Rig Wars).
			text = "Sovik in Orgrimmar sends you to Scooty in Booty Bay. Take Rig Wars from Nogg first (from level 25); "
				.. "you need not finish it. Scooty's Gnomer-gooooone! gives the {item:9173:Goblin Transponder:1}. In "
				.. "the quest's own words, it lets you step on Scooty's pad in Booty Bay to go to Gnomeregan, and the "
				.. "pad there brings you back. This is not yet checked on Forever.",
			quests = { 2842, 2843 },
			-- The transponder is 2843's reward: the player has it once 2843 is handed in.
			haveWhen = "done",
		},
		{
			-- The boss an event calls, as Tuten'kash's Gong does (the deep audit of 2026-10-30, G02-15;
			-- the owner's call, 2026-11-03), in the words of the note his page had (FromForeverChanges.lua).
			title = "Grubbis, a hidden boss",
			-- Shown on his own page's Overview too, so it is his page's only copy: FromForeverChanges.lua
			-- no longer gives him that note, or his page would say it twice.
			boss = "Grubbis",
			text = "Speak to Blastmaster Emi Shortfuse and protect her while she seals the two cave mouths: troggs "
				.. "come in waves, then Grubbis with Chomper.",
		},
	},

	bosses = {
		-- A quest's mob, on the map only (the owner's call of 2026-11-12, as the Excavation Site's Highland Horror):
		-- off the boss list, his pin on the way in's picture wearing the quest badge for Save Techbot's Brain!, which
		-- a click on it opens; his page, notes, abilities and loot kept (UI/EncounterPage.lua's BossesOf).
		["Techbot"] = { description = "Outside the instance, in Dun Morogh.", questTarget = true },
	},

	questPatches = {
		-- The lead-ins (QuestieDB's breadcrumbs: 2923 leads to 2922, 2925 to 2924, 2927 to 2926, 2931 to
		-- 2930; the deep audit of 2026-10-30, G02-11) were rows of their own from then until the owner's call
		-- of 2026-11-07 (only talks that lead to a quest, out of the journal: FromForeverChanges.lua); the
		-- quests they lead to don't name them.
		[2922] = { note = "Techbot stands outside the instance, in Dun Morogh." },
		-- Chains shown whole (UI/QuestsPanel.lua's UnderWholeChains; the owner's call of 2026-11-12, "These are a quest
		-- chain - please connect them"): Gnogaine under The Only Cure is More Green Glow's +; and the same gap closed on
		-- the ring's chain, Grime-Encrusted Ring and Return of the Ring under Gnome Improvement's (Alliance) and Nogg's
		-- Ring Redo's (Horde) +, each listed once still, as the owner's report of 2026-11-07 asked. Data Rescue's punch
		-- cards and the Horde's goblin chain have no such gap: the cards are marks, not quests, and Gnomer-gooooone!
		-- needs Chief Engineer Scooty alone, which The Goblin Transponder's dropdown lists in its order.
		[2962] = { wholeChain = true },
		[2948] = { wholeChain = true },
		[2950] = { wholeChain = true },
		-- 2,450 XP, the original game's number (the site's list, in plain; its quest page calls the quest
		-- unchanged; the audit's step 19). 4606's is left out: the site's list gives it in gold, as Forever's,
		-- while its quest page calls it unchanged.
		[4605] = { rewards = Box(2450) },
		[4606] = { rewards = Box() },
	},
})

-- Each ring quest right after its side's Return of the Ring, so the list reads in the chain's order.
ns.ListQuestAfter("Gnomeregan", 2948, 2947)
ns.ListQuestAfter("Gnomeregan", 2950, 2949)
-- And the Horde's goblin chain in its order: Rig Wars, Chief Engineer Scooty, then Gnomer-gooooone!, which
-- needs Scooty's quest done and Rig Wars taken (the quest review of 2026-11-03). On the tab Scooty's two stay
-- in The Goblin Transponder's dropdown above, Rig Wars under Dungeon Quests: Rig Wars need not be finished.
ns.ListQuestAfter("Gnomeregan", 2842, 2841)
ns.ListQuestAfter("Gnomeregan", 2843, 2842)

--[[
	The Sparklematic 5200's steps, one row each (the deep audit of 2026-10-30, G02-01 and G02-02).
	Each step comes in three versions, one for each of the three machines inside (QuestieDB's objects
	142487, 175084 and 175085 start and end them), and doing one closes the other two (QuestieDB's
	exclusiveTo): 2951, 4601 and 4602; then 2952, 4605 and 4606, which need any one of the first three
	(preQuestSingle). The third step, More Sparklematic Action (2953, 4603 and 4604, repeatable), was a
	row here until the owner's call of 2026-11-12: "the repeatable one isnt necessary". Each row is done
	once one of its versions is, and keeps the versions' pages (`pages`), with those one-of
	prerequisites, so it is locked while every version is (UI/QuestsPanel.lua). The row shows the
	first version's page: its objective, giver and rewards.
	All three machines give the quest on Forever: the owner saw it in game (2026-11-05), though
	Forever's quest data marks 4601-4606 hidden.
]]
local MACHINES = "There are three Sparklematic 5200 machines, and each gives its own version of this quest. Once "
	.. "you do it at one, the other two close."
local SPARKLEMATIC_STEPS = {
	{ name = "The Sparklematic 5200!", versions = { 2951, 4601, 4602 }, note = MACHINES },
	{ name = "The Sparklematic 5200!", versions = { 2952, 4605, 4606 }, after = { 2951, 4601, 4602 }, note = MACHINES },
}

do
	local list = ns.GetInstance("Gnomeregan").quests
	local byID = {}
	for _, quest in ipairs(list) do byID[quest.questID] = quest end
	local rows, gone = {}, {}
	for _, step in ipairs(SPARKLEMATIC_STEPS) do
		local pages = {}
		for _, questID in ipairs(step.versions) do
			local page = byID[questID]
			if step.after then page.prerequisites = { ns.OneOf("The Sparklematic 5200!", unpack(step.after)) } end
			pages[#pages + 1] = page
			gone[questID] = true
		end
		local row = {}
		for field, value in pairs(pages[1]) do row[field] = value end
		row.name, row.note, row.prerequisites = step.name, step.note, nil
		row.oneOf = ns.OneOf(step.name, unpack(step.versions)).oneOf
		row.pages = pages
		rows[#rows + 1] = row
	end
	-- The rows together, after the ring's quests, which the first machine also starts and ends (Nogg's
	-- Ring Redo, listed after Return of the Ring above, is the last of them).
	local kept, placed = {}, false
	for _, quest in ipairs(list) do
		if not gone[quest.questID] then
			kept[#kept + 1] = quest
			if quest.questID == 2950 then
				for _, row in ipairs(rows) do kept[#kept + 1] = row end
				placed = true
			end
		end
	end
	if not placed then
		for _, row in ipairs(rows) do kept[#kept + 1] = row end
	end
	for index = #list, 1, -1 do list[index] = nil end
	for index, quest in ipairs(kept) do list[index] = quest end
end

-- (Each lead-in was listed here just before the quest it leads to, G02-11, until they left the journal on the
-- owner's call of 2026-11-07.)
