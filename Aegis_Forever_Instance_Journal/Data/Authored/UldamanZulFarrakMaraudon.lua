local _, ns = ...

--[[
	Uldaman's, Zul'Farrak's and Maraudon's notes before you go and quest notes, written by hand over
	their data (Data/Instances/Uldaman.lua, ZulFarrak.lua, Maraudon.lua) and the overlays before this
	file, from the quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29, step 11 of its plan). Facts
	only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game):
	  Uldaman. Indurium Ore (1192) is Pozzik's, on the Shimmering Flats (Thousand Needles 80.2, 75.9),
	  level 42, from level 29, both sides, repeatable, after the racing chain 1104, 1105 (both needed
	  for 1106), 1106, 1108, 1137, 1190 and 1194; the ore (5833) drops only from creatures in Uldaman and
	  from the Indurium Mineral Vein inside (object 19903). foreverchanges.pro's quest page (2026-10-30)
	  asks for 4 and pays 6 silver ("Unchanged in Forever as far as is known"); it gives no XP, so the
	  audit's XP pass (2026-10-30) left it without one. The Shattered Necklace (2198) starts from the
	  Shattered Necklace (7666). Back to Uldaman (2200) hands you Talvash's Phial of Scrying (7667),
	  which Find the Gems (2201) is handed in with. The Lost Dwarves (2398) is an optional lead-in to
	  The Hidden Chamber (2240): out from the owner's call of 2026-11-07, back since the owner's call
	  of 2026-11-08 (its talk is with Baelog inside Uldaman). Solution to
	  Doom's tablet (the Ancient Chest), Agmond's Fate's urns, both Reclaimed Treasures chests and
	  Hammertoe's amulet are on the Badlands map, in the dig-site caves outside the instance, which the
	  way-in map covers. Badlands Reagent Run (2500 Alliance, 2258 Horde) comes before Uldaman Reagent
	  Run (17, 2202).
	  Zul'Farrak. The Gong of Zul'Farrak (object 141832) is inside; Qiaga the Keeper, in the
	  Hinterlands, drops the Sacred Mallet (9241); the Sandfury Executioner drops the Executioner's
	  Key (8444). Tabetha's Task (2861) and Tran'rek (2864), only lead-ins to Tiara of the Deep (2846)
	  and Scarab Shells (2865), and the Alliance's The Brassbolts Brothers (2769), the lead-in to
	  Gahz'rilla (2770), are out of the journal (the owner's call of 2026-11-07).
	  Where the chains go next, named in the quest before (the owner's calls of 2026-11-03: a follow-up
	  that is a new task elsewhere stays out): Solution to Doom (709) to To Ironforge for Yagyin's
	  Digest (727) or To the Undercity for Yagyin's Digest (728), then 735 or 736, then Forbidden
	  Knowledge (737) back at Theldurin; The Platinum Discs (2439, 2440) to Portents of Uldum (2963,
	  2965), then Seeing What Happens (2946, 2966) and The Stone Watcher (2954) in Tanaris; Uldaman
	  Reagent Run (17, 2202) to Badlands Reagent Run II (2501, 2203), Alchemy 210, done on the Badlands'
	  scorched guardian dragons (2202's note is in FromForeverChanges.lua). The Alliance's Badlands
	  Reagent Run II (2501) needs Badlands Reagent Run (2500) too, which Uldaman Reagent Run itself needs
	  (QuestieDB's preQuestSingle), so 17 has it as its step and lock line, as 2202 has 2258 (the quest
	  review and its recheck of 2026-11-03). Each says where its chain goes next in its followUp, shown
	  on its own row alone (UI/QuestsPanel.lua). The Prophecy of Mosh'aru (3527) to The Ancient Egg (4787), then The God
	  Hakkar (3528), which the Sunken Temple lists;
	  Nekrum's Medallion (2991) to The Divination (2992), Return to the Hinterlands (2993) and Saving
	  Sharpbeak (2994, Jintha'Alor); The Spider God (2936) to Summoning Shadra (2937, Shadra'Alor), then
	  Venom to the Undercity (2938).
	  Maraudon. Legends of Maraudon (7044, Cavindra's, Desolace) leads to The Scepter of Celebras
	  (7046, Celebras the Redeemed's, inside), which gives the Scepter of Celebras (17191) when it is
	  handed in (also foreverchanges.pro's quest page). The Celebrian Rod (17702) drops from Noxxion,
	  the Celebrian Diamond (17703) from Lord Vyletongue.

	The original game's, and said so in the notes: calling Gahz'rilla by striking the gong with the
	Mallet of Zul'Farrak, and making the mallet at the altar atop Jintha'Alor; the Executioner's Key
	opening the prisoners' cages on the pyramid and the fight on the stairs; the Scepter of Celebras
	letting you use the portal near Maraudon's entrance. All three are on the list of things to check
	in game.

	Rewards (Uldaman Reagent Run, The Platinum Discs) are in Data/Instances/Uldaman.lua. The audit's XP
	pass (2026-10-30) left their XP as it is: the site's Uldaman list gives it as the original game's,
	unchanged. Solution to Doom (709) and Agmond's Fate (704) keep their choice of three: the site's
	quest pages list all three items as one choice, its Uldaman page lists the old item as given with
	a choice of the two new ones, so it stays on the list of things to check. The three dungeons'
	reputation is the audit's reputation pass's (step 15b, 2026-10-30): QuestieDB's Forever data, which
	the site's quest pages match, written where each quest's rewards are.

	Loads after FromGuides.lua, FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

ns.AmendInstance("Uldaman", {
	--[[
		Before you go (the overview): the quests to take before the door, and the ones finished in the
		dig-site caves outside the instance, for each side; and the Keystone, for both (2026-11-05).
	]]
	prepare = {
		{
			faction = "Alliance",
			title = "Quests to take first, and the dig site",
			text = "Take these before you go in: Back to Uldaman, from Talvash del Kissel in Ironforge, and The Lost "
				.. "Dwarves, from Prospector Stormpike. Uldaman Reagent Run comes after Badlands Reagent Run. Keep the "
				.. "{item:7667:Talvash's Phial of Scrying} that Back to Uldaman gives you: you hand in Find the Gems with "
				.. "it. Some quests are finished in the dig-site caves, outside the instance: Solution to Doom (the "
				.. "Ancient Chest), Agmond's Fate (the urns), Reclaimed Treasures (Krom Stoutarm's Chest), and A Sign "
				.. "of Hope and Amulet of Secrets.",
		},
		{
			faction = "Horde",
			title = "Quests to take first, and the dig site",
			text = "Take Necklace Recovery, Take 2 from Dran Droffers in Orgrimmar before you go in. Uldaman Reagent "
				.. "Run comes after Badlands Reagent Run. Some quests are finished in the dig-site caves, outside the "
				.. "instance: Solution to Doom (the Ancient Chest) and Reclaimed Treasures (the Garrett Family Chest).",
		},
		{
			title = "The Keystone",
			-- The quest check of 2026-11-05 (the owner's call of that day). Revelosh drops The Shaft of Tsol
			-- (7741, the journal's own Revelosh loot), Baelog's Chest (object 123329) gives the Gni'kiv Medallion
			-- (7740), and the two make the Staff of Prehistoria (7733): the original game's item data and a second
			-- guide agree on the ids. The staff working the Keystone and opening Ironaya's door is the original
			-- game's, kept on the list of things to check in game. For both sides: the staff is not tied to The
			-- Hidden Chamber (2240, the Alliance's), and a Horde group opens the door too (the owner's report,
			-- 2026-11-05).
			text = "Revelosh drops {item:7741:The Shaft of Tsol:1}. Put together with the {item:7740:Gni'kiv Medallion} "
				.. "from Baelog's Chest, behind the Lost Dwarves, it makes the {item:7733:Staff of Prehistoria}, which works "
				.. "the Keystone in the Map Chamber, past Revelosh, and opens Ironaya's door. This is not yet checked on Forever.",
		},
	},

	addQuests = {
		{
			questID = 1192, name = "Indurium Ore", level = 42, requiredLevel = 29, faction = "Both",
			pickup = "Pozzik, Thousand Needles",
			turnin = "Pozzik, Thousand Needles",
			startMap = { mapID = 1441, x = 0.802, y = 0.759 },
			endMap = { mapID = 1441, x = 0.802, y = 0.759 },
			objective = "Bring 4 Indurium Ore to Pozzik on the Shimmering Flats.",
			note = "Repeatable. The ore is found only in Uldaman: many of its foes drop it, and so does the Indurium "
				.. "Mineral Vein.",
			rewards = { money = 600 },
			prerequisites = {
				{ questID = 1104, name = "Salt Flat Venom" },
				{ questID = 1105, name = "Hardened Shells" },
				{ questID = 1106, name = "Martek the Exiled" },
				{ questID = 1108, name = "Indurium" },
				{ questID = 1137, name = "News for Fizzle" },
				{ questID = 1190, name = "Keeping Pace" },
				{ questID = 1194, name = "Rizzle's Schematics" },
			},
		},
	},

	questPatches = {
		[2198] = { startItem = { itemID = 7666, name = "Shattered Necklace" } },
		[2398] = { note = "Optional: it leads to The Hidden Chamber." },
		-- What follows outside (QuestieDB's nextQuestInChain; the owner's calls of 2026-11-03, see the header)
		[709] = {
			followUp = "Then Theldurin the Lost gives To Ironforge for Yagyin's Digest (Alliance) or To the Undercity for "
				.. "Yagyin's Digest (Horde), a short chain outside.",
		},
		[2439] = {
			followUp = "Then High Explorer Magellas gives Portents of Uldum, which goes on to the gates of Uldum in Tanaris.",
		},
		[2440] = {
			followUp = "Then Sage Truthseeker gives Portents of Uldum, which goes on to the gates of Uldum in Tanaris.",
		},
		[17] = {
			followUp = "For alchemists (skill 210), Ghak Healtouch then gives Badlands Reagent Run II, done in the Badlands.",
		},
	},
})

ns.AmendInstance("ZulFarrak", {
	--[[
		Before you go (the overview): the Executioner's Key, which drops inside, and Gahz'rilla, the
		boss the gong called in the original game (also on his own page).
	]]
	prepare = {
		{
			title = "The Executioner's Key",
			kind = "key",
			-- Its use is the original game's; kept on the list of things to check in game.
			text = "The Sandfury Executioner drops the {item:8444:Executioner's Key:1}. In the original game, it opened "
				.. "the prisoners' cages on the pyramid, and freeing them started the fight on the stairs. This is not "
				.. "yet checked on Forever. Sergeant Bly drops the rod Chief Engineer Bilgewhizzle asks for.",
		},
		{
			title = "Gahz'rilla, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Gahz'rilla",
			-- The gong (inside) and Qiaga's drop are QuestieDB's; calling him with the mallet and how the
			-- mallet is made are the original game's, kept on the list of things to check in game.
			text = "In the original game, you struck the Gong of Zul'Farrak, inside, with the "
				.. "{item:9240:Mallet of Zul'Farrak} to call him. Qiaga the Keeper, in the Hinterlands, drops the "
				.. "{item:9241:Sacred Mallet}, which you used at the altar atop Jintha'Alor to make the Mallet of "
				.. "Zul'Farrak. This is not yet checked on Forever.",
		},
	},

	questPatches = {
		-- What follows outside (QuestieDB's nextQuestInChain; the owner's calls of 2026-11-03, see the header)
		[3527] = { followUp = "Then Yeh'kinya gives The Ancient Egg, which leads to The God Hakkar in the Sunken Temple." },
		[2991] = {
			followUp = "Then Thadius Grimshade gives The Divination, a chain that ends with Saving Sharpbeak in the Hinterlands.",
		},
		[2936] = { followUp = "Then Master Gadrin gives Summoning Shadra, done at Shadra'Alor in the Hinterlands." },
	},
})

ns.AmendInstance("Maraudon", {
	-- Before you go (the overview): the Scepter of Celebras, and the shortcut it opened.
	prepare = {
		{
			title = "The Scepter of Celebras",
			-- What the scepter opens is the original game's; kept on the list of things to check in game.
			-- Legends of Maraudon is handed in inside, to Celebras the Redeemed (QuestieDB 7044, npc 13716).
			text = "Cavindra in Desolace gives Legends of Maraudon: get the Celebrian Rod, which Noxxion drops, and "
				.. "the Celebrian Diamond, which Lord Vyletongue drops, and find a way to speak with Celebras. You hand "
				.. "it in inside, to Celebras the Redeemed, who then gives The Scepter of Celebras: help him with the "
				.. "ritual, and he gives you the {item:17191:Scepter of Celebras}. In the original game, it let you use "
				.. "the portal near the entrance to go straight to inner Maraudon. This is not yet checked on Forever.",
			quests = { 7044, 7046 },
			-- The scepter is 7046's reward: the player has it once 7046 is handed in.
			haveWhen = "done",
		},
	},
})
