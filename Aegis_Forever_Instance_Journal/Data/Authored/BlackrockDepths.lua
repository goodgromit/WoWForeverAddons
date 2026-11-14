local _, ns = ...

--[[
	Blackrock Depths, written by hand over its data (Data/Instances/BlackrockDepths.lua), from the
	quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): the
	Shadowforge Key's two quests (3801, 3802), Ironfel from Fineous Darkvire and the monument it
	goes on; the Prison Cell Key as High Interrogator Gerstahn's drop; Attunement to the Core and
	its Core Fragment inside the Depths; The Challenge's banner (its sourceItemId, given when the
	quest is taken), Theldren and his drop; Three Kings of Flame's Incendicite from Lord Incendius;
	A Taste of Flame's two lead-ins (4022, 4023: either one opens 4024); Overmaster Pyron standing
	in Blackrock Mountain, outside the dungeon. The rewards given with the choice on Jail Break!,
	Hurley Blackbreath and Lost Thunderbrew Recipe are QuestieDB's and foreverchanges.pro's
	Blackrock Depths page ("You also receive", read by hand on 2026-10-29).

	What the Prison Cell Key opens is the original game's: no source read says so for Forever, and
	the note says as much. Left out on the owner's word: Lokhtos Darkbargainer's repeatable
	Thorium Brotherhood turn-ins (6642-6646).

	The quests' reputation is the audit's reputation pass's (step 15c, 2026-10-30): QuestieDB's
	Forever data, which the site's quest pages match, written where each quest's rewards are. A
	Binding Contract (7604) has none: QuestieDB gives one Thorium Brotherhood +200, the site's page
	lists it four times, so it is on the list of things to check in game.

	From the deep audit of 2026-10-30 (Dev/docs/audit_2026-10-30, step 7 of its plan): The Heart of
	the Mountain (4123) needs a Relic Coffer Key (11078, QuestieDB's requiredSourceItems), which 30
	of the Depths' foes drop; the Heart (11309) is in object 165554 inside, and the Relic Coffers
	(160836) and the Secret Safe (161495) are in the Depths too. The Lost Thunderbrew Recipe (11312)
	drops from Hurley Blackbreath (9537) and his Blackbreath Cronies (9541) alone. Jail Break! (4322)
	leads to Stormwind Rendezvous (6402, Marshal Maxwell's), the next step of the Alliance Onyxia
	chain. The counts given with the choice (10 Dark Dwarven Lager on 4126; 5 Superior Healing and 5
	Greater Mana Potions on 4134) are the site's quest pages'. Franclorn's own words (3802's text)
	call the Shadowforge Key the master key. The original game's, and said so in the notes: the
	twelve coffers calling Watchman Doomgrip, with the Heart in the safe behind him; the kegs of
	Thunderbrew Lager calling Hurley and his cronies; what the Shadowforge Key opens is not said at
	all (no source read names it). All three are on the list of things to check in game.

	Loads after FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

ns.AmendInstance("BlackrockDepths", {
	--[[
		Before you go (the overview): the Shadowforge Key and the Prison Cell Key, the Molten Core
		attunement, and Theldren, Watchman Doomgrip and Hurley Blackbreath, the bosses the players call
		themselves (Hurley's note for each side, naming its own quest).
	]]
	prepare = {
		{
			title = "The Shadowforge Key",
			-- 3801 and 3802 are both Franclorn's; 3802 ends at the monument (object 164689, inside). His
			-- ghost is inside Blackrock Mountain and is seen only by the dead (the original game's, and a
			-- second guide's; the quest data's spot for npc 8888 is the mountain drawn on the Burning Steppes'
			-- map; 2026-11-05).
			text = "Franclorn Forgewright's ghost, in Blackrock Mountain, gives Dark Iron Legacy; you can see him only "
				.. "when you are dead. Inside, kill Fineous Darkvire for the great hammer {item:10999:Ironfel}, and "
				.. "place it on the Monument of Franclorn Forgewright at the Shrine of Thaurissan. That gives the "
				.. "{item:11000:Shadowforge Key}. Franclorn calls it the master key. What it opens is not yet checked "
				.. "on Forever.",
			quests = { 3801, 3802 },
			-- The key is 3802's reward: the player has it once 3802 is handed in.
			haveWhen = "done",
		},
		{
			title = "The Prison Cell Key",
			kind = "key",
			-- Its use is the original game's; kept on the list of things to check in game.
			text = "High Interrogator Gerstahn drops the {item:11140:Prison Cell Key:1}. In the original game, it "
				.. "opened the cells of Marshal Windsor, Kharan Mighthammer and Commander Gor'shak. This is not yet "
				.. "checked on Forever.",
		},
		{
			title = "Molten Core attunement",
			text = "Lothos Riftwaker, in Blackrock Mountain, gives Attunement to the Core. Pick up a Core Fragment "
				.. "at the Molten Core portal inside the Depths, then take it back to him.",
			quests = { 7848 },
			-- Attuned when 7848 is handed in, not when it is taken.
			haveWhen = "done",
		},
		{
			title = "Theldren, a hidden boss",
			-- He has no page of his own: no model or loot is known beyond the amulet's piece.
			boss = "Theldren",
			text = "Falrin Treeshaper in Dire Maul gives you the {item:21986:Banner of Provocation} with The "
				.. "Challenge. Plant it in the middle of the Ring of Law as High Justice Grimstone sentences you, "
				.. "then kill Theldren and his gladiators. Theldren drops the {item:22047:Top Piece of Lord "
				.. "Valthalak's Amulet}.",
		},
		{
			title = "Watchman Doomgrip, a hidden boss",
			-- Shown on his own page's Overview too. The coffers and the safe are the original game's;
			-- kept on the list of things to check in game.
			boss = "Watchman Doomgrip",
			text = "Maxwort Uberglint in the Burning Steppes gives The Heart of the Mountain. It needs a "
				.. "{item:11078:Relic Coffer Key}, which many foes in the Depths drop. In the original game, the keys "
				.. "opened the twelve Relic Coffers in the vault. Once all twelve were open, Watchman Doomgrip came "
				.. "out, and the Heart of the Mountain was in the safe behind him. This is not yet checked on Forever.",
		},
		-- Hurley has no page of his own (his tankard is under the Guzzler's loot). The kegs are the
		-- original game's; kept on the list of things to check in game.
		{
			title = "Hurley Blackbreath, a hidden boss",
			faction = "Alliance",
			boss = "Hurley Blackbreath",
			text = "Ragnar Thunderbrew in Kharanos gives Hurley Blackbreath. Hurley and his Blackbreath Cronies drop "
				.. "the {item:11312:Lost Thunderbrew Recipe}. In the original game, they came out when the kegs of "
				.. "Thunderbrew Lager by the Grim Guzzler were broken. This is not yet checked on Forever.",
		},
		{
			title = "Hurley Blackbreath, a hidden boss",
			faction = "Horde",
			boss = "Hurley Blackbreath",
			text = "Shadowmage Vivian Lagrave in Kargath gives Lost Thunderbrew Recipe. Hurley Blackbreath and his "
				.. "Blackbreath Cronies drop the {item:11312:Lost Thunderbrew Recipe}. In the original game, they came "
				.. "out when the kegs of Thunderbrew Lager by the Grim Guzzler were broken. This is not yet checked on "
				.. "Forever.",
		},
	},
})

local quests = {}
for _, quest in ipairs(ns.GetInstance("BlackrockDepths").quests) do quests[quest.questID] = quest end

-- Three Kings of Flame (8961): its Incendicite of Incendius drops from Lord Incendius here, so it is
-- listed under the Depths too, as Upper Blackrock Spire lists it (QuestAudit.lua). A copy of its
-- own, so the translations are laid over each once.
local function Copy(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, field in pairs(value) do copy[key] = Copy(field) end
	return copy
end
for _, quest in ipairs(ns.GetInstance("UpperBlackrockSpire").quests) do
	if quest.questID == 8961 and not quests[8961] then
		ns.AmendInstance("BlackrockDepths", { addQuests = { Copy(quest) } })
	end
end
-- What follows it, which the Depths list nowhere: Components of Importance (8962-8965, one of four;
-- QuestieDB's nextQuestInChain), and the amulet's quests on the other pages (the owner's calls of
-- 2026-11-03). Upper Blackrock Spire's copy lists those after it, so its note stays as it was.
for _, quest in ipairs(ns.GetInstance("BlackrockDepths").quests) do
	if quest.questID == 8961 then
		quest.followUp = "Then Bodley gives Components of Importance. The amulet's quests go on in Blackrock Spire, "
			.. "Dire Maul, Scholomance and Stratholme."
	end
end

-- The rewards given with the choice ("You also receive").
local function Also(questID, items)
	local quest = quests[questID]
	quest.rewards = quest.rewards or {}
	quest.rewards.also = items
end
-- Jail Break!: choose the Blade of Reckoning or the Skilled Fighting Blade; the Ward of the
-- Elements comes with either.
do
	local rewards = quests[4322].rewards
	local chosen = {}
	for _, item in ipairs(rewards.items) do
		if item.itemID ~= 12065 then chosen[#chosen + 1] = item end
	end
	rewards.items, rewards.choice = chosen, true
	Also(4322, { { itemID = 12065, name = "Ward of the Elements" } })
end
-- How many of each, the site's quest pages' (the deep audit of 2026-10-30, B2).
Also(4126, { { itemID = 12003, name = "Dark Dwarven Lager", count = 10 } }) -- Hurley Blackbreath
Also(4134, { -- Lost Thunderbrew Recipe
	{ itemID = 3928, name = "Superior Healing Potion", count = 5 },
	{ itemID = 6149, name = "Greater Mana Potion", count = 5 },
})

-- What the quests need that their objectives don't say (QuestieDB's Forever data): The Heart of the
-- Mountain's Relic Coffer Key; who drops the Lost Thunderbrew Recipe, for both sides' quests.
quests[4123].note = "Needs a Relic Coffer Key. Many foes in Blackrock Depths drop it."
quests[4126].note = "Hurley Blackbreath and his Blackbreath Cronies drop the recipe."
quests[4134].note = "Hurley Blackbreath and his Blackbreath Cronies drop the recipe."
-- Jail Break! (4322) goes on outside: Stormwind Rendezvous (6402) and then the rest of the Alliance
-- Onyxia chain, which Upper Blackrock Spire and Onyxia's Lair show before you go.
quests[4322].followUp = "Then Marshal Maxwell gives Stormwind Rendezvous: meet Marshal Windsor at the gates of "
	.. "Stormwind City. The chain goes on to the Onyxia attunement, which Upper Blackrock Spire and Onyxia's Lair show."

-- A Taste of Flame (4024): either earlier A Taste of Flame opens it (QuestieDB's preQuestSingle: 4022,
-- after Kalaran Windblade's chain, or 4023; a player gets only one). The Quests tab says so itself
-- (ns.OneOf), so it needs no note.
quests[4024].prerequisites = { ns.OneOf("A Taste of Flame", { questID = 4022, level = 54 }, { questID = 4023, level = 54 }) }
quests[4024].note = nil

-- Overmaster Pyron, whom the quests before Disharmony of Fire (3906, Horde) and Incendius! (4262,
-- Alliance) send you to kill, stands in the quarry in Blackrock Mountain, outside the dungeon.
for _, questID in ipairs({ 3906, 4262 }) do
	local step = ns.GetQuestStep(questID)
	if step then step.note = "Overmaster Pyron is in the quarry in Blackrock Mountain, outside the dungeon." end
end
