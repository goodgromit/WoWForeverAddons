local _, ns = ...

--[[
	Razorfen Kraul's and Razorfen Downs' notes before you go and quest notes, written by hand over
	their data (Data/Instances/RazorfenKraul.lua, RazorfenDowns.lua) and the overlays before this
	file, from the quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29, step 10 of its plan).
	Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): Blueleaf
	Tubers (1221) is Mebok Mizzyrix's in Ratchet; the Crate With Holes (5880), the Snufflenose Command
	Stick (6684) and the Snufflenose Owner's Manual (5897) are taken from objects 21277, 68865 and
	21530 beside him (The Barrens 62.3, 37.6); the quest gives A Small Container of Gems (6755, in
	Data/Instances/RazorfenKraul.lua). foreverchanges.pro's quest page (2026-10-30) agrees on the item.
	Ambassador Malcin (npc 12865), whose head An Unholy Alliance (6521) asks for, stands only in the
	Barrens, about 46-48.6, 90-95.6, beside Myriam Moonsinger at Razorfen Downs' way in. The Gong
	(object 148917) is inside Razorfen Downs. Scourge of the Downs (3523, Belnistrasz's, inside) leads
	to Extinguishing the Idol (3525), which ends at Belnistrasz's Brazier (object 152097); the escort
	and the ritual are in its objectives, and the idol "near the entrance" and the brazier he leaves
	behind are in its text (the site's quest page, "Unchanged in Forever as far as is known").

	The original game's, and said so in the notes: that each ring of the Gong brought a wave of foes
	and Tuten'kash came with the last, and that waves of quilboar came at Belnistrasz during the
	ritual. Both are on the list of things to check in game.

	An Unholy Alliance (6521), Varimathras's quest for Ambassador Malcin's head, is listed on the Kraul
	as the last step of the Small Scroll quest (6522), locked until that is done, and still on Razorfen
	Downs, where Malcin stands at the way in: the owner's call of 2026-11-03 (it had been taken out of
	the Kraul on 2026-10-29). The Kraul's copy notes where Malcin is; its Cultist's Chestguard is green
	(Data/Instances/RazorfenKraul.lua), as the site and the Downs' copy have it. Razorfen Kraul's XP
	and reputation are the audit's XP and reputation passes' (steps 14c and 15a); Razorfen Downs'
	reputation is the reputation pass's (step 15b).

	Loads after FromGuides.lua, FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

ns.AmendInstance("RazorfenKraul", {
	-- Before you go (the overview): Blueleaf Tubers' tools, which wait in Ratchet, not in the Kraul.
	prepare = {
		{
			title = "Blueleaf Tubers: the tools in Ratchet",
			text = "Mebok Mizzyrix in Ratchet gives Blueleaf Tubers. Before you go, take the {item:5880:Crate With Holes}, "
				.. "the {item:6684:Snufflenose Command Stick} and the {item:5897:Snufflenose Owner's Manual} from beside "
				.. "him, and read the manual. In the Kraul, the crate calls a Snufflenose Gopher and the stick makes it "
				.. "find the tubers.",
		},
	},

	questPatches = {
		[6521] = { note = "Ambassador Malcin stands outside Razorfen Downs, in the Barrens near its entrance." },
		-- What follows on another page: Hearts of Zeal (1113, QuestieDB's next), done and listed in the
		-- Scarlet Monastery (2026-11-03)
		[1109] = { followUp = "Then Master Apothecary Faranell gives Hearts of Zeal, done in the Scarlet Monastery." },
	},
})

-- An Unholy Alliance (6521) right after the Small Scroll quest, the end of its chain (see the header).
ns.ListQuestAfter("RazorfenKraul", 6521, 6522)

ns.AmendInstance("RazorfenDowns", {
	--[[
		Before you go (the overview): Belnistrasz's escort, best done first, and Tuten'kash, the boss
		the Gong calls (also on his own page).
	]]
	prepare = {
		{
			title = "Belnistrasz and the idol",
			-- The waves are the original game's; kept on the list of things to check in game.
			text = "Talk to Belnistrasz first; he is inside. Scourge of the Downs asks you to hand back his Oathstone. "
				.. "He then gives Extinguishing the Idol: take him to the quilboar's idol near the entrance and keep him "
				.. "alive while he does the ritual. When he is gone, his brazier stays behind: click it to hand the quest "
				.. "in. In the original game, waves of quilboar came at him during the ritual. This is not yet checked "
				.. "on Forever.",
		},
		{
			title = "Tuten'kash, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Tuten'kash",
			-- How the Gong works is the original game's; kept on the list of things to check in game.
			text = "Ring the Gong in the dungeon to call him. In the original game, each ring brought a wave of foes, "
				.. "and Tuten'kash came with the last. This is not yet checked on Forever.",
		},
	},

	questPatches = {
		[6521] = { note = "Ambassador Malcin stands outside the instance, in the Barrens near the entrance." },
	},
})
