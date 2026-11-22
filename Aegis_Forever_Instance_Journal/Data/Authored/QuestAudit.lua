local _, ns = ...

--[[
	The quest audit (2026-10-20). Every dungeon quest's prerequisites, givers and takers, their
	places, levels and sides, and the items or objects that start them, checked against QuestieDB's
	Forever database (an October 10 snapshot of the live game, read with our own decoder), the
	Forever Dungeon Journal's hand-checked chains, foreverchanges.pro and Alex Atlas Loot; then each
	change checked again against the sources by a second reviewer. Facts only, in our own words.

	Laid over the generated and hand-written data (this file loads after them), per dungeon:
	  add      quests the dungeon's data lacked
	  patches  fields corrected on a quest; false clears one (a start spot that was wrong)
	  remove   quests that are not the dungeon's on Forever: duplicates the game never offers, and
	           another wing's quests
	Prerequisites list every quest a player must have done first, oldest first: optional
	breadcrumbs, and steps any one of several will do, are left out (later files put some of the
	latter back as one-of steps, ns.OneOf, 2026-10-30). Each change names its sources.
	What those left open was then read on Wowhead's Forever pages and checked again (Wowhead); the
	few Wowhead could not settle either are listed in Dev/docs/quest-audit-2026-10-20.md.
]]

local function Audit(key, spec)
	if not ns.GetInstance(key) then return end
	if spec.add then ns.AmendInstance(key, { addQuests = spec.add }) end
	if spec.patches then ns.AmendInstance(key, { questPatches = spec.patches }) end
	if spec.remove then ns.AmendInstance(key, { removeQuests = spec.remove }) end
end

Audit("RagefireChasm", {
	patches = {
		-- Searching for the Lost Satchel: startMap (Questie, FDJ, foreverchanges, AAL)
		[5722] = {
			startMap = { mapID = 1456, x = 0.701, y = 0.295, label = "Rahauro" },
		},
		-- Testing an Enemy's Strength: startMap (Questie, FDJ, foreverchanges, AAL)
		[5723] = {
			startMap = { mapID = 1456, x = 0.701, y = 0.295, label = "Rahauro" },
		},
		-- Returning the Lost Satchel: prerequisites (Questie, FDJ, foreverchanges)
		[5724] = {
			prerequisites = { { questID = 5722, name = "Searching for the Lost Satchel" } },
		},
		-- Hidden Enemies: prerequisites (Questie, FDJ, foreverchanges)
		[5730] = {
			prerequisites = {
				{ questID = 5726, name = "Hidden Enemies" },
				{ questID = 5727, name = "Hidden Enemies" },
				{ questID = 5728, name = "Hidden Enemies" },
				{ questID = 5729, name = "Hidden Enemies" },
			},
		},
	},
})

-- Deathguard Linnea's Rear Guard Patrol, before The Wrath of Rath'mael (below), as steps' pages: Forever's quest
-- data's (giver, spot, the first part's level and objective), the second part's level from a quest page read then.
-- The second part's need for the first and both parts' Undercity reputation: Forever's quest data 1.0.12, and
-- the site's quest pages (2026-11-10); not yet seen in game.
local LINNEA = { mapID = 1420, x = 0.6549, y = 0.6025, label = "Deathguard Linnea — southeast of Brill" }
ns.AddQuestSteps({
	[356] = {
		name = "Rear Guard Patrol", level = 11, requiredLevel = 6, faction = "Horde",
		pickup = "Deathguard Linnea, Tirisfal Glades", turnin = "Deathguard Linnea, Tirisfal Glades",
		startMap = LINNEA, endMap = LINNEA,
		objective = "Kill 8 Bleeding Horrors and 8 Wandering Spirits, then report back to Deathguard Linnea at her camp.",
		rewards = { reputation = { { faction = "Undercity", amount = 75 } } },
	},
	[99156] = {
		name = "Rear Guard Patrol", level = 13, requiredLevel = 10, faction = "Horde",
		pickup = "Deathguard Linnea, Tirisfal Glades", turnin = "Deathguard Linnea, Tirisfal Glades",
		startMap = LINNEA, endMap = LINNEA,
		objective = "Bring Riptear's Heart to Deathguard Linnea.",
		note = "Riptear, a rogue abomination, wanders near Venomweb Vale in eastern Tirisfal Glades and drops the heart. It is elite: bring a group.",
		prerequisites = { { questID = 356, name = "Rear Guard Patrol" } },
		rewards = { reputation = { { faction = "Undercity", amount = 100 } } },
	},
})

-- The apothecaries' A Recipe For Death, before The New Plague (below), as steps' pages: Forever's quest data's (levels,
-- givers, takers, spots, objectives).
local RENFERREL = { mapID = 1421, x = 0.428, y = 0.4086, label = "Apothecary Renferrel — the Sepulcher" }
local FARANELL = { mapID = 1458, x = 0.4882, y = 0.6928, label = "Master Apothecary Faranell — the Apothecarium" }
ns.AddQuestSteps({
	[447] = {
		name = "A Recipe For Death", level = 12, requiredLevel = 9, faction = "Horde",
		pickup = "Apothecary Renferrel, the Sepulcher, Silverpine Forest", turnin = "Master Apothecary Faranell, the Apothecarium, Undercity",
		startMap = RENFERREL, endMap = FARANELL,
		objective = "Collect 6 Grizzled Bear Hearts and 6 samples of Skittering Blood and deliver them to Master Apothecary Faranell in the Undercity.",
	},
	[450] = {
		name = "A Recipe For Death", level = 15, requiredLevel = 9, faction = "Horde",
		pickup = "Master Apothecary Faranell, the Apothecarium, Undercity", turnin = "Apothecary Renferrel, the Sepulcher, Silverpine Forest",
		startMap = FARANELL, endMap = RENFERREL,
		objective = "Retrieve Apothecary Berard's journal from Pyrewood Village and take it to Apothecary Renferrel at the Sepulcher.",
	},
	[451] = {
		name = "A Recipe For Death", level = 18, requiredLevel = 9, faction = "Horde",
		pickup = "Apothecary Renferrel, the Sepulcher, Silverpine Forest", turnin = "Master Apothecary Faranell, the Apothecarium, Undercity",
		startMap = RENFERREL, endMap = FARANELL,
		objective = "Bring 6 samples of Lake Creeper Moss, 6 samples of Lake Skulker Moss and a Hardened Tumor to Master Apothecary Faranell in the Undercity.",
	},
})

Audit("RuinsOfLordaeron", {
	add = {
		-- Unending Torment (Questie, foreverchanges)
		{
			questID = 97290, name = "Unending Torment", level = 21, requiredLevel = 16, faction = "Horde",
			pickup = "Unfinished Abomination, Undercity",
			turnin = "Master Apothecary Faranell, Undercity",
			startMap = { mapID = 1458, x = 0.460, y = 0.620 }, endMap = { mapID = 1458, x = 0.488, y = 0.693 },
			objective = "Report back to Master Apothecary Faranell in the Undercity.",
			note = "New in Forever: part 3, in the Undercity.",
			prerequisites = { { questID = 97288, name = "Unending Torment" }, { questID = 97289, name = "Unending Torment" } },
		},
	},
	patches = {
		-- The Wrath of Rath'mael: prerequisites, note. Deathguard Kristof offers it only after Rear Guard Patrol, new
		-- since the beta: a player's find (Obsolete's, passed on by the owner, 2026-11-08), and players' comments on its
		-- Wowhead page (2026-11-04 on: both parts of Rear Guard Patrol, then this), though the page's own facts name
		-- nothing before it, and Forever's quest data (October 10) neither. Rear Guard Patrol is two quests from
		-- Deathguard Linnea, who stands beside Kristof: the second (99156) follows the first (356) in its Wowhead series,
		-- and its text opens on the report that came in while you were on patrol.
		[92422] = {
			prerequisites = {
				{ questID = 356, name = "Rear Guard Patrol" },
				{ questID = 99156, name = "Rear Guard Patrol" },
			},
			note = "Deathguard Kristof offers it once you have done Rear Guard Patrol for Deathguard Linnea, who stands beside him: two quests, the second against Riptear, an elite abomination.",
		},
		-- The New Plague: prerequisites, note. Theodore Griffs offers it only after A Recipe For Death, new since the
		-- beta: players' comments on its Wowhead page (2026-11-05 and 11-06: missing on live, then unlocked by that
		-- chain, the last of it quest 451), though the page's own facts name nothing before it, and Forever's quest data
		-- (October 10) neither. The chain's three quests and their order are that data's.
		[95216] = {
			prerequisites = {
				{ questID = 447, name = "A Recipe For Death" },
				{ questID = 450, name = "A Recipe For Death" },
				{ questID = 451, name = "A Recipe For Death" },
			},
			note = "Theodore Griffs offers it once you have done A Recipe For Death, the apothecaries' three quests between the Sepulcher in Silverpine Forest and the Undercity.",
		},
		-- Remember That I Love You: pickup, startItem, endMap, note (Forever's quest data, two quest pages).
		-- Her spot is on Forever's redrawn Stormwind: 47.2, 38.4, which some guides still give, is her spot
		-- on the classic map. Part 2 (95161) takes the letter to Avette Fellwood in Darkshire: where the chain
		-- goes next is the quest's own followUp (Data/Instances/RuinsOfLordaeron.lua, 0.39.19's audit), which names
		-- her; the shorter line this file gave since 2026-11-05 is gone with the merge of 0.39.19.
		[92415] = {
			pickup = "Blood-Stained Parchment, found inside Ruins of Lordaeron",
			startItem = { itemID = 251270, name = "Blood-Stained Parchment" },
			endMap = { mapID = 1453, x = 0.563, y = 0.54, label = "Orphan Matron Nightingale — Cathedral Square" },
			note = "Starts from the Blood-Stained Parchment (or the Last Scrawlings of Edward Heartweaver); the quest then gives you the Blood-Stained Letter to bring to Nightingale.",
		},
		-- Bloodied Insignia: endMap (Questie, foreverchanges)
		[95195] = {
			endMap = { mapID = 1453, x = 0.692, y = 0.827, label = "General Marcus Jonathan — Valley of Heroes" },
		},
		-- Unending Torment: pickup, startMap, turnin, endMap (Questie, foreverchanges)
		[97289] = {
			pickup = "Master Apothecary Faranell, Undercity",
			startMap = { mapID = 1458, x = 0.488, y = 0.693, label = "Master Apothecary Faranell — Apothecarium" },
			turnin = "Unfinished Abomination, Undercity",
			endMap = { mapID = 1458, x = 0.46, y = 0.62, label = "Unfinished Abomination — Undercity" },
		},
		-- Unending Torment: pickup, startMap, turnin (Questie, foreverchanges)
		[97291] = {
			pickup = "Master Apothecary Faranell, Undercity",
			startMap = { mapID = 1458, x = 0.488, y = 0.693, label = "Master Apothecary Faranell — Apothecarium" },
			turnin = "Master Apothecary Faranell, Undercity",
		},
		-- Unending Torment: pickup, startMap, turnin (Questie, foreverchanges)
		[97292] = {
			pickup = "Master Apothecary Faranell, Undercity",
			startMap = { mapID = 1458, x = 0.488, y = 0.693, label = "Master Apothecary Faranell — Apothecarium" },
			turnin = "Master Apothecary Faranell, Undercity",
		},
	},
})

Audit("TheDeadmines", {
	add = {
		-- (Speak with Shoni, 2041, Underground Assault's optional lead-in, was a row here from 2026-11-03 until the
		-- owner's call of 2026-11-06: it is only who you talk to before Underground Assault, not a step of it.)
		-- A Moon-Kissed Blade (Questie, Wowhead)
		{
			questID = 95036, name = "A Moon-Kissed Blade", level = 25, requiredLevel = 20, faction = "Horde", classOnly = "PALADIN",
			pickup = "Lumina Windsinger, the Sepulcher, Silverpine Forest",
			turnin = "Trevan Rol, the Sepulcher, Silverpine Forest",
			startMap = { mapID = 1421, x = 0.433, y = 0.410, label = "Lumina Windsinger" },
			endMap = { mapID = 1421, x = 0.433, y = 0.410, label = "Trevan Rol" },
			-- The Purified Kor Gem is on foreverchanges.pro's quest page (2026-10-30), not in QuestieDB's
			-- quest record; QuestieDB's gem (272448) is Seeking the Kor Gem's reward and names this quest
			-- as its related one. The note's follow-ups, all done outside: QuestieDB's An Underrated Talent
			-- (95111, Trevan Rol to Ott, npc 3539, who stands in Tarren Mill), Ott's Masterwork (95125), The
			-- Moonsilver Blade (95126, its reward the Moonsilver Blade, 268484) and Old Fire-Eye (95140,
			-- Lumina Windsinger's; Old Fire-Eye's spawns are in southern Silverpine; its reward Wolfsbane,
			-- 267369). Their order is read from who gives and takes each (the deep audit of 2026-10-30,
			-- G01-06 and G01-07).
			objective = "Bring Trevan Rol in the Sepulcher the Whitestone Oak Lumber, the Enchanted Silver Ingot and the "
				.. "Purified Kor Gem he needs.",
			note = "A paladin quest for the Forsaken. Here: Whitestone Oak Lumber, which the Goblin Woodcarvers drop. The "
				.. "Purified Kor Gem comes from Seeking the Kor Gem, from Ulric Frostveil at Zoram'gar Outpost; its "
				.. "Corrupted Kor Gem drops in Blackfathom Deeps. Trevan then sends you to Ott, the weaponsmith in Tarren "
				.. "Mill (Hillsbrad Foothills), who forges the Moonsilver Blade. Lumina Windsinger then has you use it on "
				.. "Old Fire-Eye in southern Silverpine, for Wolfsbane.",
			-- QuestieDB's Forever data (the quest audit's reputation pass, 2026-10-30); the site's quest
			-- page has no Rewards section.
			rewards = { reputation = { { faction = "Undercity", amount = 100 }, { faction = "Earthen Ring", amount = 100 } } },
		},
	},
	patches = {
		-- Oh Brother...: startMap (Wowhead)
		[167] = {
			startMap = { mapID = 1453, x = 0.703, y = 0.408, label = "Wilder Thistlenettle" },
		},
		-- Collecting Memories: startMap (Wowhead)
		[168] = {
			startMap = { mapID = 1453, x = 0.703, y = 0.408, label = "Wilder Thistlenettle" },
		},
		-- The Unsent Letter: endMap (Questie, FDJ, foreverchanges)
		[373] = {
			endMap = { mapID = 1453, x = 0.577, y = 0.479, label = "Baros Alexston" },
		},
		-- The Test of Righteousness: prerequisites (Questie, FDJ, foreverchanges)
		[1806] = {
			prerequisites = {
				{ questID = 1649, name = "The Tome of Valor" },
				{ questID = 1650, name = "The Tome of Valor" },
				{ questID = 1651, name = "The Tome of Valor" },
				{ questID = 1652, name = "The Tome of Valor" },
				{ questID = 1653, name = "The Test of Righteousness" },
				{ questID = 1654, name = "The Test of Righteousness" },
			},
		},
		-- Destruction in Deadmines: prerequisites (Questie, FDJ, foreverchanges)
		[92819] = {
			prerequisites = {
				{ questID = 92742, name = "Testing the Wells" },
				{ questID = 92744, name = "Murloc Gills" },
				{ questID = 92745, name = "The State of the Mines" },
				{ questID = 92747, name = "Moonbrook Espionage" },
				{ questID = 92748, name = "Explosive Consultation" },
				{ questID = 92749, name = "A Dynamite Plan" },
				{ questID = 92750, name = "Detonation at a Distance" },
				{ questID = 92751, name = "Detonation at a Distance" },
				{ questID = 92752, name = "Explosive Consultation" },
				{ questID = 92753, name = "Destruction in Deadmines" },
			},
		},
		-- A Moon-Kissed Blade: prerequisites (Questie, Wowhead)
		[95036] = {
			prerequisites = {
				{ questID = 91858, name = "Diplomatic Incident" },
				{ questID = 91859, name = "A Curious Pair" },
				{ questID = 91860, name = "A Grim Fate" },
				{ questID = 91861, name = "Into Fenris Keep" },
				{ questID = 91862, name = "Lumina Windsinger" },
				{ questID = 96204, name = "The Windshaper's Wrath" },
				{ questID = 95034, name = "The Debt" },
			},
		},
	},
})

Audit("WailingCaverns", {
	patches = {
		-- Leaders of the Fang: note (Questie, FDJ)
		[914] = {
			note = "Needs the Barrens oasis chain first: The Forgotten Pools, The Stagnant Oasis and Altered Beings, then Hamuul Runetotem and Nara Wildmane, before Leaders of the Fang opens.",
			-- (the quests the note names that are named after someone: Adventure Mode hides them as quests)
			namesQuests = { 1489, 1490 },
		},
		-- Hamuul Runetotem: prerequisites (Questie, FDJ, foreverchanges)
		[1489] = {
			prerequisites = {
				{ questID = 870, name = "The Forgotten Pools" },
				{ questID = 877, name = "The Stagnant Oasis" },
				{ questID = 880, name = "Altered Beings" },
			},
		},
		-- Nara Wildmane: prerequisites (Questie, FDJ, foreverchanges)
		[1490] = {
			prerequisites = {
				{ questID = 870, name = "The Forgotten Pools" },
				{ questID = 877, name = "The Stagnant Oasis" },
				{ questID = 880, name = "Altered Beings" },
				{ questID = 1489, name = "Hamuul Runetotem" },
			},
		},
		-- The Glowing Shard: startMap, turnin, endMap (Questie, FDJ, foreverchanges)
		[6981] = {
			startMap = false,
			turnin = "Falla Sagewind, The Barrens",
			endMap = { mapID = 1413, x = 0.482, y = 0.328, label = "Falla Sagewind" },
		},
	},
	remove = {
		999, -- When Dreams Turn to Nightmares: an empty stub in the game's data, never offered: no giver, no text (Wowhead)
		1500, -- Waking Naralex: an empty stub in the game's data, never offered: no giver, no text (Wowhead)
		3366, -- The Glowing Shard: a dead copy of The Glowing Shard (6981), which the journal lists (Wowhead)
	},
})

Audit("ShadowfangKeep", {
	patches = {
		-- The Test of Righteousness: prerequisites (Questie, FDJ, foreverchanges)
		[1806] = {
			prerequisites = {
				{ questID = 1649, name = "The Tome of Valor" },
				{ questID = 1650, name = "The Tome of Valor" },
				{ questID = 1651, name = "The Tome of Valor" },
				{ questID = 1652, name = "The Tome of Valor" },
				{ questID = 1653, name = "The Test of Righteousness" },
				{ questID = 1654, name = "The Test of Righteousness" },
			},
		},
	},
})

Audit("BlackfathomDeeps", {
	add = {
		-- (The Corruption Abroad, 3765, the Alliance's lead-in to Researching the Corruption, was a row here from
		-- 2026-11-03 until the owner's call of 2026-11-07.)
		-- The Orb of Soran'ruk (FDJ, Questie, foreverchanges)
		{ questID = 1740, name = "The Orb of Soran'ruk", level = 25, requiredLevel = 20, faction = "Both", classOnly = "WARLOCK", pickup = "Doan Karhan, The Barrens", turnin = "Doan Karhan, The Barrens", startMap = { mapID = 1413, x = 0.493, y = 0.572, label = "Doan Karhan" }, objective = "Find 3 Soran'ruk Fragments and 1 Large Soran'ruk Fragment and return them to Doan Karhan.", note = "A warlock quest. The 3 Soran'ruk Fragments drop from Twilight Acolytes here; the Large Soran'ruk Fragment comes from Shadowfang Darksouls in Shadowfang Keep.", rewards = { xp = 5100, choice = true, items = { { itemID = 6898, name = "Orb of Soran'ruk", quality = 3 }, { itemID = 15109, name = "Staff of Soran'ruk", quality = 3 } } } },
	},
	patches = {
		-- Researching the Corruption: prerequisites (Questie, FDJ); its lead-in is a row since 2026-11-03, so
		-- no note (false clears the data's own)
		[1275] = {
			note = false,
			prerequisites = {},
		},
		-- The Test of Righteousness: prerequisites (Wowhead)
		[1806] = {
			prerequisites = {
				{ questID = 1649, name = "The Tome of Valor" },
				{ questID = 1650, name = "The Tome of Valor" },
				{ questID = 1651, name = "The Tome of Valor" },
				{ questID = 1652, name = "The Tome of Valor" },
				{ questID = 1653, name = "The Test of Righteousness" },
				{ questID = 1654, name = "The Test of Righteousness" },
			},
		},
		-- Blackfathom Villainy: endMap (Questie, foreverchanges, AAL)
		[6561] = {
			endMap = { mapID = 1456, x = 0.711, y = 0.342, label = "Bashana Runetotem" },
		},
		-- Trouble in the Deeps: endMap (Questie, foreverchanges)
		[6562] = {
			endMap = { mapID = 1440, x = 0.1156, y = 0.3429, label = "Je'neu Sancrea" },
		},
		-- Allegiance to the Old Gods, the Damp Note's: prerequisites, from Forever's quest data (its one
		-- earlier quest: Trouble in the Deeps), not yet seen in game (2026-11-07). Its second part lists the
		-- whole chain, oldest first.
		[6564] = {
			prerequisites = { { questID = 6562, name = "Trouble in the Deeps" } },
		},
		[6565] = {
			prerequisites = {
				{ questID = 6562, name = "Trouble in the Deeps" },
				{ questID = 6564, name = "Allegiance to the Old Gods" },
			},
		},
		-- Baron Aquanis: endMap (Questie, foreverchanges, AAL)
		[6922] = {
			endMap = { mapID = 1440, x = 0.1156, y = 0.3429, label = "Je'neu Sancrea" },
		},
	},
})

Audit("ExcavationSiteWetlands", {
	patches = {
		-- Horrors in the Highland: prerequisites (Questie, FDJ, AAL)
		[95646] = {
			prerequisites = {
				{ questID = 276, name = "Tramping Paws" },
				{ questID = 277, name = "Fire Taboo" },
				{ questID = 275, name = "Blisters on The Land" },
			},
		},
		-- Lost in the Thicket Things: turnin (Questie, FDJ, foreverchanges)
		[95647] = {
			turnin = "Ardin Grassman, inside Excavation Site: Wetlands",
		},
		-- Songblade Search: startMap (Questie, FDJ, foreverchanges, AAL)
		[95772] = {
			startMap = { mapID = 1433, x = 0.258, y = 0.464, label = "Dorin Songblade — Redridge Mountains" },
		},
		-- Fallen in the Fen: endMap, prerequisites (Questie, FDJ, foreverchanges, AAL)
		[95795] = {
			endMap = { mapID = 1433, x = 0.258, y = 0.464, label = "Dorin Songblade, Lakeshire" },
			prerequisites = {},
		},
		-- Highland Hides: prerequisites (Questie, FDJ)
		[98815] = {
			prerequisites = { { questID = 484, name = "Young Crocolisk Skins" } },
		},
	},
})

Audit("CityOfDalaran", {
	patches = {
		-- Starving Arcane: startMap, prerequisites (Questie, FDJ, foreverchanges, Wowhead)
		[92457] = {
			startMap = { mapID = 1421, x = 0.686, y = 0.452, label = "Image of Archmage Modera — Lordamere Lake near Dalaran" },
			prerequisites = { { questID = 92432, name = "An Alarming Request" } },
		},
		-- Heart of Disruption: startMap (Questie, foreverchanges)
		[92458] = {
			startMap = { mapID = 1421, x = 0.686, y = 0.452, label = "Image of Archmage Modera — Lordamere Lake" },
		},
		-- Heart of Disruption: startMap, endMap (Questie, FDJ, foreverchanges)
		[96984] = {
			startMap = { mapID = 1421, x = 0.686, y = 0.452, label = "Image of Archmage Modera — Lordamere Lake near Dalaran" },
			endMap = { mapID = 1424, x = 0.616, y = 0.208, label = "Magus Wordeen Voidglare — Tarren Mill" },
		},
	},
})

Audit("Gnomeregan", {
	patches = {
		-- Chief Engineer Scooty: endMap, note (Questie, FDJ, foreverchanges)
		[2842] = {
			endMap = { mapID = 1434, x = 0.276, y = 0.7748, label = "Scooty" },
			note = "Accept Rig Wars from Nogg first; you need not finish it. If Nogg no longer offers Rig Wars, abandon this quest and Rig Wars comes back. Leads to Gnomer-gooooone!, the goblins' transporter to Gnomeregan.",
		},
		-- Gnomer-gooooone!: note, prerequisites (Questie, FDJ)
		[2843] = {
			note = "Needs Rig Wars accepted, not finished: take it from Nogg in Orgrimmar before Chief Engineer Scooty.",
			prerequisites = { { questID = 2842, name = "Chief Engineer Scooty" } },
		},
		-- Data Rescue: note, prerequisites (Questie, FDJ)
		[2930] = {
			note = "A White Punch Card drops from mobs outside the instance; run it through Matrix Punchograph 3005-A (Train Depot, outside), 3005-B (the Dormitory), 3005-C (Electrocutioner 6000's platform) and 3005-D (lower Engineering Labs) to get the Prismatic Punch Card.",
			prerequisites = {},
		},
		-- Grime-Encrusted Ring: requiredLevel, pickup, turnin (Questie, FDJ, foreverchanges)
		[2945] = {
			requiredLevel = 28,
			pickup = "Grime-Encrusted Ring, dropped by Dark Iron Agents inside Gnomeregan",
			turnin = "The Sparklematic 5200, inside Gnomeregan",
		},
		-- Return of the Ring: pickup (Questie, FDJ, foreverchanges)
		[2947] = {
			pickup = "The Sparklematic 5200, inside Gnomeregan",
		},
		-- Return of the Ring: pickup (Questie, FDJ, foreverchanges)
		[2949] = {
			pickup = "The Sparklematic 5200, inside Gnomeregan",
		},
		-- The second The Sparklematic 5200! (4605, 4606): its one-of prerequisites, which this file once
		-- cleared for notes (with More Sparklematic Action's, 2953, 4603 and 4604, out of the journal since the
		-- owner's call of 2026-11-12), are set in
		-- Data/Authored/GnomereganQuests.lua, which shows each step as one row (the deep audit of
		-- 2026-10-30, G02-01 and G02-02).
	},
})

Audit("RazorfenKraul", {
	add = {
		-- Speak with Thun'grim, the Horde warriors' lead-in to Brutal Armor, a row marked optional as every other
		-- lead-in is (Questie's breadcrumb, after Trial at the Field of Giants; foreverchanges.pro's quest page
		-- for its XP, 2026-11-04; a call of that day the owner left to Claude). Listed just before Brutal Armor
		-- (the end of this file).
		{
			questID = 1825, name = "Speak with Thun'grim", level = 20, requiredLevel = 20, faction = "Horde", classOnly = "WARRIOR",
			pickup = "Ruga Ragetotem, Camp Taurajo, The Barrens", turnin = "Thun'grim Firegaze, The Barrens",
			startMap = { mapID = 1413, x = 0.447, y = 0.594, label = "Ruga Ragetotem" },
			endMap = { mapID = 1413, x = 0.572, y = 0.303, label = "Thun'grim Firegaze" },
			objective = "Speak with Thun'grim Firegaze in the Barrens.",
			note = "Optional: it leads to Brutal Armor.",
			prerequisites = {
				{ questID = 1824, name = "Trial at the Field of Giants" },
			},
			rewards = { xp = 775 },
		},
		-- Fire Hardened Mail (Questie)
		{
			questID = 1701, name = "Fire Hardened Mail", level = 28, requiredLevel = 20, faction = "Alliance", classOnly = "WARRIOR",
			pickup = "Furen Longbeard, Stormwind City", turnin = "Furen Longbeard, Stormwind City",
			startMap = { mapID = 1453, x = 0.646, y = 0.372, label = "Furen Longbeard" },
			objective = "Gather the materials Furen Longbeard requires, and bring them to him in Stormwind.",
			note = "Roogug drops the Vial of Phlogiston.",
			prerequisites = {
				{ questID = 1699, name = "The Rethban Gauntlet" },
				{ questID = 1702, name = "The Shieldsmith" },
			},
			rewards = { xp = 2300 },
		},
		-- Furen's Armor, the chain's last step (Questie; foreverchanges.pro's quest page for its rewards,
		-- 2026-11-03; the owner's call of that day: a chain's last steps at the same giver stay)
		{
			questID = 1782, name = "Furen's Armor", level = 28, requiredLevel = 20, faction = "Alliance", classOnly = "WARRIOR",
			pickup = "Furen Longbeard, Stormwind City", turnin = "Furen Longbeard, Stormwind City",
			startMap = { mapID = 1453, x = 0.646, y = 0.372, label = "Furen Longbeard" },
			objective = "Talk to Furen Longbeard in Stormwind to get your armor.",
			prerequisites = {
				{ questID = 1699, name = "The Rethban Gauntlet" },
				{ questID = 1702, name = "The Shieldsmith" },
				{ questID = 1701, name = "Fire Hardened Mail" },
			},
			rewards = { xp = 3400, items = { { itemID = 6972, name = "Fire Hardened Hauberk", quality = 3 } } },
		},
		-- Brutal Armor (Questie)
		{
			questID = 1838, name = "Brutal Armor", level = 30, requiredLevel = 20, faction = "Horde", classOnly = "WARRIOR",
			pickup = "Thun'grim Firegaze, The Barrens", turnin = "Thun'grim Firegaze, The Barrens",
			startMap = { mapID = 1413, x = 0.572, y = 0.303, label = "Thun'grim Firegaze" },
			objective = "Bring to Thun'grim Firegaze 15 Smoky Iron Ingots, 10 Powdered Azurite, 10 Iron Bars and a Vial of Phlogiston.",
			-- Its optional lead-in, Speak with Thun'grim (1825), is the row before it since 2026-11-04 (Questie's
			-- breadcrumbs), so the note no longer names it
			note = "Roogug drops the Vial of Phlogiston.",
			prerequisites = {
				{ questID = 1824, name = "Trial at the Field of Giants" },
			},
			rewards = { xp = 3650 },
		},
		-- Brutal Hauberk, the chain's last step (Questie; foreverchanges.pro's quest page for its rewards,
		-- 2026-11-03; the owner's call of that day: a chain's last steps at the same giver stay)
		{
			questID = 1848, name = "Brutal Hauberk", level = 30, requiredLevel = 20, faction = "Horde", classOnly = "WARRIOR",
			pickup = "Thun'grim Firegaze, The Barrens", turnin = "Thun'grim Firegaze, The Barrens",
			startMap = { mapID = 1413, x = 0.572, y = 0.303, label = "Thun'grim Firegaze" },
			objective = "Talk to Thun'grim Firegaze in the Barrens to get your armor.",
			prerequisites = {
				{ questID = 1824, name = "Trial at the Field of Giants" },
				{ questID = 1838, name = "Brutal Armor" },
			},
			rewards = { xp = 3050, items = { { itemID = 7133, name = "Brutal Hauberk", quality = 3 } } },
		},
		-- An Unholy Alliance: its 40 silver as Razorfen Downs' copy has it. Its
		-- 5,900 XP: the owner read it in the quest window (2026-11-13), as a player's recorded hand-in gave it;
		-- the 2,800 read earlier (2026-10-30) was out of date. Forever's number, not marked.
		{
			questID = 6522, name = "An Unholy Alliance", level = 36, requiredLevel = 28, faction = "Horde",
			pickup = "Small Scroll, dropped by Charlga Razorflank in Razorfen Kraul", turnin = "Varimathras, Royal Quarter, Undercity",
			startItem = { itemID = 17008, name = "Small Scroll", note = "Dropped by Charlga Razorflank." },
			endMap = { mapID = 1458, x = 0.563, y = 0.922, label = "Varimathras — Royal Quarter, Undercity" },
			objective = "Take the Small Scroll to Varimathras in the Undercity.",
			prerequisites = {},
			rewards = { xp = 5900, money = 4000 },
		},
		-- Elemental Aid (its quest page); its two givers, Rau Cliffrunner and Prate Cloudseer, both in Thousand
		-- Needles, are Forever's quest data's (2026-11-05; the pin stays at Rau's). The turn-in is Bath'rah the
		-- Windwatcher's in the Alterac Mountains: the quest data's first taker, which also lists Rau (the owner's
		-- report, 2026-11-05).
		{
			questID = 79360, name = "Elemental Aid", level = 33, requiredLevel = 30, faction = "Horde", classOnly = "SHAMAN",
			pickup = "Rau Cliffrunner (or Prate Cloudseer), Thousand Needles", turnin = "Bath'rah the Windwatcher, Alterac Mountains",
			startMap = { mapID = 1441, x = 0.461, y = 0.517, label = "Rau Cliffrunner" },
			endMap = { mapID = 1416, x = 0.805, y = 0.669, label = "Bath'rah the Windwatcher" },
			objective = "Defeat Charlga Razorflank in Razorfen Kraul and collect information on the quilboar's plans.",
			note = "Charlga Razorflank drops the Tattered Note.",
			prerequisites = {},
		},
		-- Elemental Aid (Questie)
		{
			questID = 96264, name = "Elemental Aid", level = 33, requiredLevel = 30, faction = "Alliance", classOnly = "SHAMAN",
			pickup = "Veyric Thunderhame, Arathi Highlands", turnin = "Veyric Thunderhame, Arathi Highlands",
			startMap = { mapID = 1417, x = 0.598, y = 0.276, label = "Veyric Thunderhame" },
			objective = "Defeat Charlga Razorflank in Razorfen Kraul and collect information on the quilboar's plans.",
			note = "Charlga Razorflank drops the Tattered Note.",
			prerequisites = {},
		},
	},
	patches = {
		-- An Unholy Alliance: startMap, prerequisites (Questie, FDJ, foreverchanges, AAL)
		[6521] = {
			startMap = { mapID = 1458, x = 0.563, y = 0.922, label = "Varimathras — Royal Quarter, Undercity" },
			prerequisites = { { questID = 6522, name = "An Unholy Alliance" } },
		},
	},
})

Audit("ScarletMonasteryLibrary", {
	add = {
		-- Into The Scarlet Monastery (Questie, foreverchanges)
		{
			questID = 1048, name = "Into The Scarlet Monastery", level = 42, requiredLevel = 33, faction = "Horde",
			pickup = "Varimathras, Royal Quarter, Undercity", turnin = "Varimathras, Royal Quarter, Undercity",
			startMap = { mapID = 1458, x = 0.563, y = 0.922 },
			objective = "Kill High Inquisitor Whitemane, Scarlet Commander Mograine, Herod and Houndmaster Loksey, then report to Varimathras in the Undercity.",
			rewards = { xp = 5150, items = { { itemID = 6802 }, { itemID = 6803 }, { itemID = 10711 } }, choice = true, reputation = { { faction = "Undercity", amount = 200 } } },
		},
		-- In the Name of the Light (Questie, foreverchanges)
		{
			questID = 1053, name = "In the Name of the Light", level = 40, requiredLevel = 34, faction = "Alliance",
			pickup = "Raleigh the Devout, Southshore, Hillsbrad Foothills", turnin = "Raleigh the Devout, Southshore, Hillsbrad Foothills",
			startMap = { mapID = 1424, x = 0.515, y = 0.584 },
			objective = "Kill High Inquisitor Whitemane, Scarlet Commander Mograine, Herod and Houndmaster Loksey, then report to Raleigh the Devout in Southshore.",
			prerequisites = { { questID = 261, name = "Down the Scarlet Path" }, { questID = 1052, name = "Down the Scarlet Path" } },
			rewards = { xp = 4700, items = { { itemID = 6829 }, { itemID = 6830 }, { itemID = 6831 }, { itemID = 11262 } }, choice = true, reputation = { { faction = "Stormwind", amount = 200 } } },
		},
	},
	patches = {
		-- Compendium of the Fallen: note (Questie, FDJ, foreverchanges)
		[1049] = {
			note = "Undead characters cannot take this quest.",
		},
		-- Test of Lore: prerequisites (Questie, FDJ, foreverchanges)
		[1160] = {
			prerequisites = {
				{ questID = 1149, name = "Test of Faith" },
				{ questID = 1150, name = "Test of Endurance" },
				{ questID = 1151, name = "Test of Strength" },
				{ questID = 1152, name = "Test of Lore" },
				{ questID = 1154, name = "Test of Lore" },
				{ questID = 6627, name = "Test of Lore" },
				{ questID = 1159, name = "Test of Lore" },
			},
		},
		-- Final Passage: prerequisites (Questie, FDJ, foreverchanges)
		[1394] = {
			prerequisites = {
				{ questID = 1149, name = "Test of Faith" },
				{ questID = 1150, name = "Test of Endurance" },
				{ questID = 1151, name = "Test of Strength" },
				{ questID = 1152, name = "Test of Lore" },
				{ questID = 1154, name = "Test of Lore" },
				{ questID = 6627, name = "Test of Lore" },
				{ questID = 1159, name = "Test of Lore" },
				{ questID = 1160, name = "Test of Lore" },
				{ questID = 6628, name = "Test of Lore" },
			},
		},
		-- Rituals of Power: turnin, endMap, objective, note, prerequisites (Questie, foreverchanges)
		[1951] = {
			turnin = "Tabetha, Dustwallow Marsh",
			endMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			objective = "Bring the book Rituals of Power, from the Library, to Tabetha in Dustwallow Marsh.",
			note = "The book lies at the north end of the hallway to Arcanist Doan.",
			prerequisites = {
				{ questID = 1947, name = "Journey to the Marsh" },
				{ questID = 1949, name = "Hidden Secrets" },
				{ questID = 1950, name = "Get the Scoop" },
			},
		},
		-- Past Due: startMap (Forever's quest data 1.0.12, where Magus Olvek has one spawn; 2026-11-10)
		[96800] = {
			startMap = { mapID = 1416, x = 0.0975, y = 0.6336, label = "Magus Olvek — Dalaran" },
		},
	},
})

-- The Rebel Camp's chain before An Acquaintance in Southshore (below), as steps' pages: Forever's quest data's (levels,
-- givers, objectives, spots).
local function RebelCamp(x, y, label) return { mapID = 1434, x = x, y = y, label = label } end
ns.AddQuestSteps({
	[203] = {
		name = "The Second Rebellion", level = 33, requiredLevel = 30, faction = "Alliance",
		pickup = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale", turnin = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale",
		startMap = RebelCamp(0.3802, 0.0333, "Sergeant Yohwa"), endMap = RebelCamp(0.3802, 0.0333, "Sergeant Yohwa"),
		objective = "Kill 15 Kurzen Jungle Fighters, then return to Sergeant Yohwa at the Rebel Camp.",
	},
	[204] = {
		name = "Bad Medicine", level = 34, requiredLevel = 30, faction = "Alliance",
		pickup = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale", turnin = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale",
		startMap = RebelCamp(0.3802, 0.0333, "Sergeant Yohwa"), endMap = RebelCamp(0.3802, 0.0333, "Sergeant Yohwa"),
		objective = "Bring 7 Jungle Remedies and 1 Venom Fern Extract to Sergeant Yohwa at the Rebel Camp.",
	},
	[207] = {
		name = "Kurzen's Mystery", level = 38, requiredLevel = 30, faction = "Alliance",
		pickup = "Brother Nimetz, Rebel Camp, Stranglethorn Vale", turnin = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
		startMap = RebelCamp(0.3783, 0.0356, "Brother Nimetz"), endMap = RebelCamp(0.3783, 0.0356, "Brother Nimetz"),
		objective = "Find the 4 tablets and bring their legends back to Brother Nimetz.",
	},
	[205] = {
		name = "Troll Witchery", level = 40, requiredLevel = 30, faction = "Alliance",
		pickup = "Brother Nimetz, Rebel Camp, Stranglethorn Vale", turnin = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
		startMap = RebelCamp(0.3783, 0.0356, "Brother Nimetz"), endMap = RebelCamp(0.3783, 0.0356, "Brother Nimetz"),
		objective = "Bring 4 Skullsplitter Fetishes to Brother Nimetz at the Rebel Camp.",
	},
})

-- The Steamwheedle towns' reputation the Saltseer quests give (Wowhead's list of the dungeon's quests,
-- 2026-11-09): Booty Bay, whose Krazek gives them, and a little with the other three.
local function GOBLIN_TOWNS()
	return {
		{ faction = "Booty Bay", amount = 100 }, { faction = "Ratchet", amount = 50 },
		{ faction = "Gadgetzan", amount = 50 }, { faction = "Everlook", amount = 50 },
	}
end
Audit("TheDrownedCity", {
	-- The two Horde quests Forever's quest data has for the dungeon (95775, 95776): their level,
	-- side, objective and reputation (Orgrimmar and Darkspear Trolls, +100 each) are its own. It names
	-- no giver or taker, so none is given: the page says the place is not known yet. Added on the
	-- owner's call of 2026-11-03 (the deep audit of 2026-10-30, g09-1); the site's pages for them are
	-- unread. 95776's objective names Var'Taka, the journal's second boss since 2026-11-08 (it had been
	-- Zin'aka). Zin'aka is still in the dungeon, as an elite shark in the central pool, not a boss (2026-11-12), and
	-- off the boss list since the owner's call of 2026-11-12 (it drops no loot yet: Data/Authored/Upcoming.lua).
	-- The Horde's tablet quest, The Drowned City (95775), needs no earlier quest: the owner's word of 2026-11-12 ("make
	-- sure these quests don't have pre-reqs"). It had Locating the Lost City, from the guide's chain and the quest's text
	-- (2026-11-08), not from a player's report, and Forever's quest data lists no earlier quest for it either. Locating
	-- the Lost City stays on the page as a quest of its own. The Alliance's Take Two With Water (95787) keeps An
	-- Acquaintance in Southshore, as Magics of the Drowned City (95788) does: asked about it, the owner said to keep a
	-- requirement as it is where a player's report gave it (2026-11-12). Whether 95775 stays without one is still to be
	-- confirmed with the owner.
	-- 2026-11-08: the chains before them, as a players' guide to the dungeon gives them (facts only): The Vile Reef
	-- (629, Kin'weelay at Grom'gol) leads to The Gurubashi Legends of Old, then Locating the Lost City (the cavern
	-- of Sunken Hollow), then The Drowned City; Enemies in the Water (the Brinescale Skirmishers outside the portal)
	-- leads to The Only Good Brinescale.... Their ids, levels, sides and objectives are Forever's quest data's.
	-- 2026-11-08, on the owner's call: the Alliance chain from Southshore and the two Booty Bay quests open to both
	-- sides, read by hand from the quests' own pages (level, side, objective, giver where named, rewards) and
	-- checked against the guide; the givers' and takers' spots are Forever's quest data's. An Acquaintance in
	-- Southshore names no giver: Brother Nimetz, as Magics of the Drowned City's text says he sent the player.
	-- Which follow-up comes after which dungeon quest is from their text (the tablets' translations, the fetish).
	-- The reward items' colours are the guide's (the follow-ups' blues, the Saltseer quests' greens).
	add = {
		{
			questID = 629, name = "The Vile Reef", level = 37, requiredLevel = 30, faction = "Horde",
			pickup = "Kin'weelay, Grom'gol Base Camp", turnin = "Kin'weelay, Grom'gol Base Camp",
			startMap = { mapID = 1434, x = 0.3227, y = 0.2771, label = "Kin'weelay" },
			endMap = { mapID = 1434, x = 0.3227, y = 0.2771, label = "Kin'weelay" },
			objective = "Bring a Tablet Shard to Kin'weelay at the Grom'gol Base Camp.",
		},
		{
			questID = 95748, name = "The Gurubashi Legends of Old", level = 40, requiredLevel = 30, faction = "Horde",
			pickup = "Kin'weelay, Grom'gol Base Camp",
			objective = "Use the hide and charcoal to create a rubbing of the Third Troll Legend tablet.",
			prerequisites = { { questID = 629, name = "The Vile Reef" } },
		},
		{
			questID = 95770, name = "Locating the Lost City", level = 40, requiredLevel = 30, faction = "Horde",
			objective = "Explore the Vile Reef and find the cavern entrance.",
			prerequisites = { { questID = 95748, name = "The Gurubashi Legends of Old" } },
		},
		{
			questID = 95775, name = "The Drowned City", level = 40, requiredLevel = 30, faction = "Horde",
			objective = "Use the hide and charcoal to create rubbings of the tablets found in the Drowned City.",
			rewards = { reputation = { { faction = "Orgrimmar", amount = 100 }, { faction = "Darkspear Trolls", amount = 100 } } },
			-- (no earlier quest: the owner's word of 2026-11-12, above)
		},
		{
			questID = 95773, name = "Enemies in the Water", level = 37, requiredLevel = 30, faction = "Horde",
			objective = "Gather 10 Brinescale Tridents from Brinescale Skirmishers.",
		},
		{
			questID = 95776, name = "The Only Good Brinescale...", level = 38, requiredLevel = 30, faction = "Horde",
			objective = "Slay Var'Taka in the Drowned City.",
			-- Money and the choice: its Wowhead page (2026-11-09). Locating the Lost City too, by two players'
			-- comments there (2026-11-08): available after Enemies in the Water, and after Locating the Lost City.
			rewards = {
				money = 13000,
				choice = true,
				items = { { itemID = 279888, name = "Tidesoaked Leggings" }, { itemID = 279889, name = "Naga Priestess's Mantle" } },
				reputation = { { faction = "Orgrimmar", amount = 100 }, { faction = "Darkspear Trolls", amount = 100 } },
			},
			prerequisites = {
				{ questID = 95770, name = "Locating the Lost City" },
				{ questID = 95773, name = "Enemies in the Water" },
			},
		},
		{
			questID = 95786, name = "An Acquaintance in Southshore", level = 40, requiredLevel = 30, faction = "Alliance",
			pickup = "Brother Nimetz, Rebel Camp, Stranglethorn Vale", turnin = "Loremaster Dibbs, Southshore",
			startMap = { mapID = 1434, x = 0.3783, y = 0.0356, label = "Brother Nimetz" },
			endMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			objective = "Take the Savage Coast Report Bundle to Loremaster Dibbs in Southshore.",
			note = "It can't be shared: everyone in the group picks it up. Brother Nimetz gives it after Troll Witchery, sending its fetishes and his legends along.",
			-- After Brother Nimetz's own chain at the Rebel Camp (the steps' pages: below): a player's report on the
			-- journal's Discord (2026-11-08: Troll Witchery came first, in their quest log), and the quest's own text, which
			-- sends "the fetishes and legends" along: Troll Witchery's Skullsplitter Fetishes, Kurzen's Mystery's legends.
			-- No site lists it yet. Kurzen's Mystery needs The Second Rebellion and Bad Medicine (Forever's quest data).
			prerequisites = {
				{ questID = 203, name = "The Second Rebellion" },
				{ questID = 204, name = "Bad Medicine" },
				{ questID = 207, name = "Kurzen's Mystery" },
				{ questID = 205, name = "Troll Witchery" },
			},
		},
		{
			questID = 95787, name = "Take Two With Water", level = 40, requiredLevel = 30, faction = "Alliance",
			pickup = "Loremaster Dibbs, Southshore", turnin = "Loremaster Dibbs, Southshore",
			startMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			endMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			objective = "Use the hide and charcoal to create rubbings of the tablets found in the Drowned City.",
			note = "The same four tablets of I'lalai as the Horde's quest The Drowned City.",
			rewards = { money = 15000, reputation = { { faction = "Stormwind", amount = 100 } } },
			-- Kept on the owner's answer of 2026-11-12 (above)
			prerequisites = { { questID = 95786, name = "An Acquaintance in Southshore" } },
		},
		{
			questID = 95788, name = "Magics of the Drowned City", level = 40, requiredLevel = 30, faction = "Alliance",
			pickup = "Loremaster Dibbs, Southshore", turnin = "Loremaster Dibbs, Southshore",
			startMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			endMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			objective = "Collect 5 I'lalai Fetishes from trolls in the Drowned City.",
			rewards = { reputation = { { faction = "Stormwind", amount = 100 } } },
			prerequisites = { { questID = 95786, name = "An Acquaintance in Southshore" } },
		},
		{
			questID = 95799, name = "Findings for the Explorer's League", level = 40, requiredLevel = 30, faction = "Alliance",
			pickup = "Loremaster Dibbs, Southshore", turnin = "Historian Karnik, Ironforge",
			startMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			endMap = { mapID = 1455, x = 0.7754, y = 0.1182, label = "Historian Karnik" },
			objective = "Bring Loremaster Dibbs' I'lalai Translations to Historian Karnik in Ironforge.",
			rewards = {
				choice = true,
				items = {
					{ itemID = 279880, name = "Ancient Voodoo Pouch", quality = 3 },
					{ itemID = 279881, name = "Intrepid Explorer's Chainmail", quality = 3 },
				},
				also = { { itemID = 272124, name = "Translated Tale of I'lalai" } },
			},
			prerequisites = { { questID = 95787, name = "Take Two With Water" } },
		},
		{
			questID = 95798, name = "The Web of Magic", level = 40, requiredLevel = 30, faction = "Alliance",
			pickup = "Loremaster Dibbs, Southshore", turnin = "Abra Cadabra, Dalaran",
			startMap = { mapID = 1424, x = 0.5057, y = 0.5709, label = "Loremaster Dibbs" },
			endMap = { mapID = 1416, x = 0.1325, y = 0.6955, label = "Abra Cadabra — Dalaran" },
			objective = "Bring the I'lalai Fetish to Abra Cadabra in Dalaran.",
			note = "It can't be shared. The Kirin Tor only let noted visitors into Dalaran, so you may need their favor first.",
			rewards = {
				choice = true,
				items = {
					{ itemID = 279879, name = "Rune-Etched Epaulets", quality = 3 },
					{ itemID = 279878, name = "Apprentice Sorcerer's Slacks", quality = 3 },
				},
			},
			prerequisites = { { questID = 95788, name = "Magics of the Drowned City" } },
		},
		{
			questID = 95789, name = "Shady Saltseers", level = 40, requiredLevel = 34, faction = "Both",
			pickup = "Krazek, Booty Bay",
			startMap = { mapID = 1434, x = 0.2695, y = 0.7721, label = "Krazek" },
			objective = "Collect 10 Voodoo-Infused Artifacts from Saltseer pirates in the Drowned City.",
			rewards = {
				money = 10000,
				choice = true,
				items = {
					{ itemID = 279882, name = "Rusted Troll War Belt", quality = 2 },
					{ itemID = 279930, name = "Saltseer's Helm", quality = 2 },
				},
				reputation = GOBLIN_TOWNS(),
			},
		},
		{
			questID = 95791, name = "The Saltseer Captain", level = 40, requiredLevel = 34, faction = "Both",
			pickup = "Krazek, Booty Bay", turnin = "Krazek, Booty Bay",
			startMap = { mapID = 1434, x = 0.2695, y = 0.7721, label = "Krazek" },
			endMap = { mapID = 1434, x = 0.2695, y = 0.7721, label = "Krazek" },
			objective = "Slay Captain Dreadrise and 3 Saltseer Coroners in the Drowned City.",
			rewards = {
				choice = true,
				items = {
					{ itemID = 279883, name = "Mutinous Cuffs", quality = 2 },
					{ itemID = 279884, name = "South Seas Shroud", quality = 2 },
				},
				reputation = GOBLIN_TOWNS(),
			},
		},
		{
			questID = 97130, name = "Ancient Gurubashi Secrets", level = 40, requiredLevel = 34, faction = "Alliance",
			pickup = "Archmage Timear, Dalaran",
			startMap = { mapID = 1416, x = 0.1617, y = 0.7166, label = "Archmage Timear — Dalaran" },
			objective = "Recover an Ancient Gurubashi Idol from the Drowned City.",
			-- (the idol: Deathless Marrow's, 2026-11-19: the drop data has it off Marrow on 1124 of 2185 kills and never off
			-- the Primeval Elemental in 1450, and the owner remembers it off Marrow; Data/Authored/Upcoming.lua, at his loot)
			note = "The idol drops from Deathless Marrow. The Horde's quest for it is Ancient Gurubashi Idol, from Mazu'kon in Mulgore.",
			-- Its rewards: Wowhead's list of the dungeon's quests (2026-11-09).
			rewards = { money = 5000, reputation = { { faction = "Kirin Tor", amount = 300 }, { faction = "Stormwind", amount = 150 } } },
		},
	},
	patches = {
		-- Ancient Gurubashi Idol: turnin, endMap (Questie, foreverchanges); its money, Wowhead's list (2026-11-09). Its
		-- XP stays foreverchanges' 8800 (that list says 3900: not settled).
		[96774] = {
			turnin = "Mazu'kon, Mulgore",
			endMap = { mapID = 1412, x = 0.324, y = 0.206, label = "Mazu'kon" },
			rewards = {
				xp = 8800,
				money = 10000,
				reputation = { { faction = "Darkspear Trolls", amount = 150 }, { faction = "Earthen Ring", amount = 300 } },
			},
		},
	},
})

--[[
	The dungeons not open yet: their quests as Forever's data has them already, on the owner's call of
	2026-11-08, read by hand from the quests' own pages (level, side, objective, giver where named, rewards;
	facts only, in our own words). Nobody has run these dungeons, so all of it can still change. A giver the
	page does not name is named only where the quest's own text is plainly theirs, and the comment says so;
	else the page says the giver is not listed yet. Spots are Forever's quest data's (the Riverglades map,
	2548: the Horde's camp at Rog'mar and the Alliance's Farholde Keep). Item colours are left to the game.
	Reputation with the Brotherhood of the Horse is Forever's own faction (Data/Authored/Factions.lua).
]]
-- Krol'dok Stronghold. The Krol'dok Compound Key's quests are done outside, so they are its Before you go's key
-- (Data/Authored/Upcoming.lua), with step pages, not rows.
-- Checked again on 2026-11-17 (the owner's ask, "lets make sure the quests info is correct"): each quest's start and
-- end NPC and map pin, level, side and series in Forever's quest database, a players' guide to the dungeon and the
-- owner's table of its quests, and the client's item data (which items start which quest, the items' names). Every
-- level, side, reward and prerequisite here matched. New: the givers and takers the first reading had no name or
-- spot for (Sergeant Riftan, Demar Brant, Ashe Amberhall, Ranath Nightstride, Tran'gul, Da'grosh), each the
-- database's start and end NPC at its pin, which the guide names too.
-- The way in (2026-11-18, the owner's report: Eye of Mugg showed as open from level 40, "we cant get that yet"). The Eye
-- of Mugg starts no quest (the client's item data: no start quest, and a quest item, so it drops only for a player who
-- has the quest). Each side's dungeon quests are offered only after a chain outside, which the game data shows only in
-- part (no series reaches the dungeon quests: that lock is the server's). So each one's lock is the whole chain, in
-- order, as players' notes on the quests' pages, the owner's notes and pictures, the guides, the quests' own text and
-- their series have it, each step a page of its own (Data/Authored/Upcoming.lua), so the lock line names the next step
-- to do. Only steps surely needed: one a player may skip would keep the quest locked for good, as a step counts only
-- once done (QuestsPanel:Status). Since the owner's evening notes of 2026-11-18, the chains from their first quests:
-- The Horde's (fairly sure): Krom'rosh's A Message in Blood, then his Show Them How It's Done (players' notes).
-- His Food for the Taking, given beside it, is no step of the lock (it keeps its page): one player (the note the owner
-- sent) did both before Show Them How It's Done, another did both but is unsure both are needed, one only lists them
-- side by side and one was offered both at once; one more says A Message in Blood and A Gift From Our Enemies
-- (Krom'rosh's, the stolen feed to Gorg) must be done to move on to Show Them How It's Done, and names no Food for the
-- Taking. So it may be optional (a question for the owner's run). Tran'gul's Twilight Missives, then Digging for Answers (its series); Clubtoe's The
-- Purple Ones, in two parts (the first ends at a dead ogre in the caves, which gives the second: their series), and
-- Sickening Lights, then Twilight No More! (two players' lists, one the note the owner sent; the series); Spread the
-- Word back to Tran'gul, then Land of Giants on to Clugfist (their series; Clubtoe gives the head that Tran'gul sends
-- on); Clugfist's Might Makes Right and Unworthy Champion, then Clugfist's Decree (two players' lists, one in so many
-- words: do both "and you finally unlock Clugfist's Decree"; its text thanks you for smashing the Twilight); The
-- Wayward Warrior (Clugfist's Decree's series); Da'grosh's Carving a Path, Break Their Chains and Rumblings of
-- Discontent, then his Bring Me His Head (two players, each step by step, apart; A Token of Vengeance after it), and
-- It Is Time, Brother... (Eye of Mugg and Tome of Twilight after it). Left out: Encroaching Twilight (one player's list
-- has it beside Twilight Missives; no series or text ties it to Digging for Answers), A Gift From Our Enemies (the one
-- player above names it in Food for the Taking's place; no one else does) and Rise Up! (one player: not needed).
-- Encroaching Twilight stays out of the locks and off the road in Before you go, with no page: the owner's call of
-- 2026-11-19 is to add it only if the game requires it. Players' notes on the quests' pages, read again that day, don't
-- settle it: none says in so many words that it is needed or that it isn't; one had it offered together with Twilight
-- Missives once Show Them How It's Done was handed in (so it is offered after that, fairly sure); other lists go from
-- Twilight Missives to Digging for Answers without it; one bare reply naming it may mean it was needed too, or may
-- only guess another quest's name; and one player's way to Clugfist ran through a kill-the-cultists quest from an orc
-- mage in Rog'mar, which may be it. A question for the game: with Twilight Missives handed in and it not done, does
-- Tran'gul offer Digging for Answers?
-- The Alliance's (likely): Ashe Amberhall's Scraps of Knowledge or Demar Brant's Saving Sunnyglade, either one (ns.OneOf:
-- a player had The Western Front once Scraps of Knowledge was done, and its completion sends you to Brant; another
-- player's guess and another addon's chain view the owner saw put Saving Sunnyglade before it; the owner and a guide
-- name Curious Trinkets too, which no chain puts there. Whether both are needed is not known: the smaller sure set);
-- The Western Front (three players: Sergeant Riftan offers nothing before it); Riftan's No Soldier Left Behind and
-- Carving a Path (the chain view the owner saw puts them before Bring Me His Head, the owner had both from Riftan with
-- no Bring Me His Head yet, and its text speaks of "the soldiers we rescued"; Da'grosh's Horde quests are the same);
-- Riftan's Bring Me His Head (Eye of Mugg after it: a player and a guide; Twilight Mementos: another player, and the
-- chain view). Left out: News to Farholde, which that chain view alone puts before Eye of Mugg (a player has it
-- "available once Kilgar has been killed"; a question for the owner's run). The Alliance's Tome of Twilight: Curious
-- Trinkets, then A Small Favor (a player, the chain view, and A Small Favor's own text: "the reagents you collected";
-- Scraps of Knowledge, which that view lists first too, left out).
-- The Field Marshal's Log's quests (Saving Marshal Ryan, Dying Wish, Delivering Closure: their series) are no step of
-- either: the log drops off the Twilight's Hammer at random and rarely (a player killed some 230 before one fell), so
-- nothing waits on it, and no player's chain or the chain view has them (fairly sure). Krol'dok No More!, new in the
-- database, stays out: its reward items aren't in the client (not live, by the best guess). XP is left out: the
-- database's quest pages and its list of them disagree.
-- (A new table each call, so the translations are laid over each quest's once.)
local function Riverglades(x, y, label) return { mapID = 2548, x = x, y = y, label = label } end
local function MuggChoice()
	return {
		{ itemID = 279852, name = "Rock on Stick" },
		{ itemID = 279480, name = "Bigger Rock on Bigger Stick" },
		{ itemID = 279853, name = "Stick No Rock" },
	}
end
-- Each side's way in to the dungeon's quests (above), in order; the steps' pages are in Data/Authored/Upcoming.lua.
-- A new table each call. The Horde's, from Krom'rosh's first quest to Da'grosh's Bring Me His Head (Food for the
-- Taking left out: it may be optional, above).
local HORDE_WAY_IN = {
	{ 93786, "A Message in Blood" }, { 94483, "Show Them How It's Done" },
	{ 94680, "Twilight Missives" }, { 94727, "Digging for Answers" }, { 95417, "The Purple Ones" },
	{ 95601, "The Purple Ones" }, { 95602, "Sickening Lights" }, { 95427, "Twilight No More!" },
	{ 95418, "Spread the Word" }, { 95420, "Land of Giants" }, { 95424, "Might Makes Right" },
	{ 95425, "Unworthy Champion" }, { 95428, "Clugfist's Decree" }, { 94744, "The Wayward Warrior" },
	{ 94745, "Carving a Path" }, { 94748, "Break Their Chains" }, { 95431, "Rumblings of Discontent" },
	{ 94768, "Bring Me His Head" },
}
local function DagroshsHead()
	local list = {}
	for _, step in ipairs(HORDE_WAY_IN) do list[#list + 1] = { questID = step[1], name = step[2] } end
	return list
end
local function KromroshsMissive()
	local list = DagroshsHead()
	list[#list + 1] = { questID = 95278, name = "It Is Time, Brother..." }
	return list
end
-- The Alliance's: either of the two Farholde Keep quests (above), then Sergeant Riftan's.
local function RiftansHead()
	return {
		ns.OneOf("Scraps of Knowledge", { questID = 94879, name = "Scraps of Knowledge" },
			{ questID = 94877, name = "Saving Sunnyglade" }),
		{ questID = 94886, name = "The Western Front" },
		{ questID = 94888, name = "No Soldier Left Behind" },
		{ questID = 94889, name = "Carving a Path" },
		{ questID = 94890, name = "Bring Me His Head" },
	}
end
Audit("KroldokStronghold", {
	add = {
		-- Eye of Mugg, for each side: the proof is the Eye of Mugg (its page's item, 267086 in the client's data),
		-- which Overseer Mugg drops. The Horde's text is Krom'rosh's, who takes it; the Alliance's quest text calls its giver
		-- Commander Brant, who is Demar Brant <Knight Commander> in Farholde Keep (the database's start and end NPC
		-- and pin, 66.6 81.0; the guide names him too). Each side's after its way in (above, since 2026-11-18; the whole
		-- chain since the owner's evening notes): the Horde's once It Is Time, Brother... is handed in to Krom'rosh, the
		-- Alliance's once Kilgar's head is with Sergeant Riftan (whether News to Farholde comes first too: a question for
		-- the owner).
		{
			questID = 94968, name = "Eye of Mugg", level = 45, requiredLevel = 40, faction = "Horde",
			pickup = "Krom'rosh, Rog'mar, Riverglades", turnin = "Krom'rosh, Rog'mar, Riverglades",
			startMap = Riverglades(0.594, 0.456, "Krom'rosh"), endMap = Riverglades(0.594, 0.456, "Krom'rosh"),
			objective = "Infiltrate Krol'dok Stronghold and return to Krom'rosh with proof of their leader's demise.",
			note = "The proof is the Eye of Mugg, which Overseer Mugg drops.",
			rewards = { money = 13000, choice = true, items = MuggChoice() },
			prerequisites = KromroshsMissive(),
		},
		{
			questID = 94982, name = "Eye of Mugg", level = 45, requiredLevel = 40, faction = "Alliance",
			pickup = "Demar Brant, Farholde Keep, Riverglades", turnin = "Demar Brant, Farholde Keep, Riverglades",
			startMap = Riverglades(0.666, 0.81, "Demar Brant"), endMap = Riverglades(0.666, 0.81, "Demar Brant"),
			objective = "Infiltrate Krol'dok Stronghold and return to Commander Brant with proof of their leader's demise.",
			note = "The proof is the Eye of Mugg, which Overseer Mugg drops.",
			rewards = { money = 13000, choice = true, items = MuggChoice(),
				reputation = { { faction = "Brotherhood of the Horse", amount = 150 } } },
			prerequisites = RiftansHead(),
		},
		-- Ranath Nightstride gives and takes it in Dalaran (the database's start and end NPC and pin, 17.8 66.0 on the
		-- Alterac Mountains map, as Dalaran's other givers are mapped; the guide names him too).
		{
			questID = 96771, name = "Vengeance of the Highborne", level = 45, requiredLevel = 37, faction = "Alliance",
			pickup = "Ranath Nightstride, Dalaran", turnin = "Ranath Nightstride, Dalaran",
			startMap = { mapID = 1416, x = 0.178, y = 0.66, label = "Ranath Nightstride — Dalaran" },
			endMap = { mapID = 1416, x = 0.178, y = 0.66, label = "Ranath Nightstride — Dalaran" },
			objective = "Travel to Krol'dok Stronghold and slay Zalfan Moonshadow.",
			note = "Zalfan Moonshadow is a highborne seen in the stronghold with the Twilight's Hammer.",
			rewards = { money = 6500, reputation = { { faction = "Kirin Tor", amount = 250 },
				{ faction = "Brotherhood of the Horse", amount = 150 } } },
		},
		-- Ashe Amberhall gives and takes the Alliance's (the database's start and end NPC and pin; the guide names her);
		-- the tome (267104) drops from Nar'gurk, for each side's quest.
		{
			questID = 94984, name = "Tome of Twilight", level = 44, requiredLevel = 39, faction = "Alliance",
			pickup = "Ashe Amberhall, Farholde Keep, Riverglades", turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
			startMap = Riverglades(0.667, 0.811, "Ashe Amberhall"), endMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
			objective = "Kill Nar'gurk within Krol'dok Stronghold and recover any valuable information.",
			note = "The information is the Tome of Twilight, which Nar'gurk drops.",
			rewards = {
				choice = true,
				items = { { itemID = 279854, name = "Twilight Initiate's Belt" }, { itemID = 279855, name = "Torn Cultist Cloak" } },
				reputation = { { faction = "Brotherhood of the Horse", amount = 150 } },
			},
			-- A Small Favor before it, by its page's series, and Curious Trinkets before that (the block's comment above;
			-- the steps' pages: Data/Authored/Upcoming.lua)
			prerequisites = { { questID = 94881, name = "Curious Trinkets" }, { questID = 94907, name = "A Small Favor" } },
		},
		-- Tran'gul gives and takes the Horde's, in Rog'mar (the database's start and end NPC and pin, 59.4 44.0; the guide
		-- names him too). After the Horde's way in, as Eye of Mugg (above): both players have Tran'gul offer it once It Is
		-- Time, Brother... is handed in.
		{
			questID = 94972, name = "Tome of Twilight", level = 44, requiredLevel = 39, faction = "Horde",
			pickup = "Tran'gul, Rog'mar, Riverglades", turnin = "Tran'gul, Rog'mar, Riverglades",
			startMap = Riverglades(0.594, 0.44, "Tran'gul"), endMap = Riverglades(0.594, 0.44, "Tran'gul"),
			objective = "Recover the Tome of Twilight from Krol'dok Stronghold.",
			note = "Nar'gurk drops the tome.",
			rewards = {
				choice = true,
				items = { { itemID = 279859, name = "Indoctrinated Choker" }, { itemID = 279860, name = "Convert's Bindings" } },
			},
			prerequisites = KromroshsMissive(),
		},
		-- Da'grosh gives and takes it, outside the stronghold (the database's start and end NPC and pin, 33.4 38.0, in
		-- the Krol'dok Stronghold Outskirts; the guide names him too). Its reward starts no quest (the client's data).
		-- Da'grosh offers it once his Bring Me His Head is handed in (both players, above).
		{
			questID = 94975, name = "A Token of Vengeance", level = 42, requiredLevel = 38, faction = "Horde",
			pickup = "Da'grosh, outside Krol'dok Stronghold, Riverglades",
			turnin = "Da'grosh, outside Krol'dok Stronghold, Riverglades",
			startMap = Riverglades(0.334, 0.38, "Da'grosh"), endMap = Riverglades(0.334, 0.38, "Da'grosh"),
			objective = "Collect 15 Cultist Ears from the Twilight's Hammer in Krol'dok Stronghold.",
			rewards = { items = { { itemID = 267090, name = "Semblance of Twilight" } } },
			prerequisites = DagroshsHead(),
		},
		-- Sergeant Riftan gives and takes it in the Twilight's Shroud (the database's start and end NPC and pin, 30.6
		-- 49.0; the guide and the owner's table name him too). The bangles are the client's Twilight Bangle (267234).
		-- Its row shows its chain (chainHead: UI/QuestsPanel.lua's BranchesOn; the owner's call of 2026-11-17, "make the
		-- main dungeon quest the visible one"): Lingering Essence and Curios of Curiosity, its follow-ups outside, are
		-- steps under its +, not rows. After the Alliance's way in (above, since 2026-11-18): a player has it offered once
		-- Kilgar's head is with Riftan, and a guide says so of his Bring Me His Head.
		{
			questID = 94983, name = "Twilight Mementos", level = 42, requiredLevel = 38, faction = "Alliance",
			pickup = "Sergeant Riftan, the Twilight's Shroud, Riverglades",
			turnin = "Sergeant Riftan, the Twilight's Shroud, Riverglades",
			startMap = Riverglades(0.306, 0.49, "Sergeant Riftan"), endMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
			objective = "Collect 8 Cultist Bangles from the Twilight's Hammer in Krol'dok Stronghold.",
			note = "The bangles drop as Twilight Bangles from the Twilight's Hammer cultists inside.",
			rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 150 } } },
			prerequisites = RiftansHead(),
			chainHead = true,
		},
		-- Its two follow-ups in Farholde Keep (the owner's rule: a chain's few follow-ups stay in it). Lingering
		-- Essence is after Twilight Mementos by its page's series, and Sergeant Riftan gives it with the Satchel of
		-- Cursed Mementos (its start NPC and pin); Curios of Curiosity's text is Ashe's, after hers.
		{
			questID = 94997, name = "Lingering Essence", level = 42, requiredLevel = 38, faction = "Alliance",
			pickup = "Sergeant Riftan, the Twilight's Shroud, Riverglades", turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
			startMap = Riverglades(0.306, 0.49, "Sergeant Riftan"), endMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
			objective = "Bring the Satchel of Cursed Mementos to Ashe Amberhall in Farholde Keep.",
			note = "It can't be shared.",
			rewards = { money = 5500, reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
			prerequisites = { { questID = 94983, name = "Twilight Mementos" } },
		},
		{
			questID = 94998, name = "Curios of Curiosity", level = 42, requiredLevel = 38, faction = "Alliance",
			pickup = "Ashe Amberhall, Farholde Keep, Riverglades", turnin = "Melanie Sable, Farholde Keep, Riverglades",
			startMap = Riverglades(0.667, 0.811, "Ashe Amberhall"), endMap = Riverglades(0.662, 0.832, "Melanie Sable"),
			objective = "Bring the Satchel of Mementos to Melanie Sable.",
			note = "It can't be shared.",
			rewards = { money = 5500, items = { { itemID = 279850, name = "Curio-Adorned Necklace" } },
				reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
			prerequisites = { { questID = 94997, name = "Lingering Essence" } },
		},
	},
})

-- Alcaz Prison. The Dragon's Journal's text names Timear as its writer's partner: Archmage Lan'dalock, as in Dalaran's
-- other dungeon quests. The prisoner's two quests are given inside: More Valuable Than Gold names him, Mason Connery.
-- They and each side's State Secrets are the Alcaz Operative Insignia's chain (below, before the dungeon's rows).
-- Alcaz Prison's givers and takers outside: Sully McCleary in Theramore's inn (Forever's quest data, Dustwallow
-- Marsh), Thrall and Eitrigg in Orgrimmar (the same). A new table each call.
-- The game has two Sully McClearys (Forever's NPC data, 2026-11-17, read from each one's page): the one in the inn
-- (260146, 66.2 45.2) only takes Our Man in Theramore and gives Watch Yer Back; the one behind the graveyard outside
-- town (260271, 63.4 42.4) gives and takes the rest: The Return of the King?, The Secret Prison, A Bit of Wet Work,
-- Somber News and Shaw Needs To Know. Before 0.39.24 the journal had them all at the inn.
local function Theramore() return { mapID = 1445, x = 0.662, y = 0.452, label = "Sully McCleary — Theramore" } end
local function Graveyard() return { mapID = 1445, x = 0.634, y = 0.424, label = "Sully McCleary — Theramore's graveyard" } end
local function Orgrimmar(x, y, label) return { mapID = 1454, x = x, y = y, label = label } end

--[[
	The Alliance's way in, as steps' pages (2026-11-12, the owner's report: Sully's quests need Mathias Shaw's
	breadcrumb from Stormwind first). Forever's quest data (the game's copy, version 1.0.12) has none of these
	quests yet; the site's quest pages (2026-11-12) give their ids, levels, sides and objectives, Our Man in
	Theramore's spot at the end (Sully, 66.2 45.2, Sully McCleary's spot in Forever's quest data) and its
	chain on to Watch Yer Back. The owner's screenshot of Shaw's quest window: Our Man in Theramore from
	Master Mathias Shaw, to the dwarf Sully at Theramore's inn, 1,300 XP (the window's own number). Shaw's spot
	is the one the Deadmines' chain has for him (Data/Generated/QuestSteps.lua).
	The Return of the King? (the tower, in disguise) follows Watch Yer Back, and Sully gives The Secret Prison and A
	Bit of Wet Work after it. Where (2026-11-17, the two Sullys' own pages, above): Watch Yer Back ends behind
	Theramore's graveyard, and The Return of the King? is given and handed in there, not at the inn (before, a best
	guess from a player's comment; Watch Yer Back had no end spot). Watch Yer Back's and The Return of the King?'s
	1,300 XP are the site's numbers (Forever's, from players' quest windows); their reputation (25, 75 and 100
	Stormwind, with Our Man in Theramore's) the quests' pages' (2026-11-17).
]]
-- Master Mathias Shaw at SI:7 in Stormwind: he gives Our Man in Theramore and takes Shaw Needs To Know. A new table each call.
local function Shaw() return { mapID = 1453, x = 0.783, y = 0.707, label = "Master Mathias Shaw" } end
local SULLY_GRAVEYARD = "Sully McCleary, behind Theramore's graveyard, Dustwallow Marsh"
ns.AddQuestSteps({
	[95194] = {
		name = "Our Man in Theramore", level = 53, requiredLevel = 48, faction = "Alliance",
		pickup = "Master Mathias Shaw, Stormwind City", startMap = Shaw(),
		turnin = "Sully McCleary, the inn at Theramore, Dustwallow Marsh", endMap = Theramore(),
		objective = "Seek out the SI:7 agent stationed on Theramore Isle.",
		rewards = { xp = 1300, reputation = { { faction = "Stormwind", amount = 25 } } },
	},
	[95196] = {
		name = "Watch Yer Back", level = 53, requiredLevel = 48, faction = "Alliance",
		pickup = "Sully McCleary, the inn at Theramore, Dustwallow Marsh", startMap = Theramore(),
		-- (the graveyard Sully's spot, above: before 2026-11-17 no source gave it, and it had none)
		turnin = SULLY_GRAVEYARD, endMap = Graveyard(),
		objective = "Meet Sully McCleary in Dustwallow Marsh and learn more about your mission.",
		note = "Sully leaves the inn first. Wait until he is gone, then meet him behind the graveyard outside town.",
		rewards = { xp = 1300, reputation = { { faction = "Stormwind", amount = 75 } } },
		prerequisites = { { questID = 95194, name = "Our Man in Theramore" } },
	},
	[95198] = {
		name = "The Return of the King?", level = 53, requiredLevel = 48, faction = "Alliance",
		-- (given and taken back behind the graveyard: the graveyard Sully's page, above)
		pickup = SULLY_GRAVEYARD, startMap = Graveyard(),
		turnin = SULLY_GRAVEYARD, endMap = Graveyard(),
		objective = "Use the SI:7 Disguise Kit to eavesdrop on Jaina and her inner circle at the Theramore Mage Tower.",
		note = "Sully's SI:7 Disguise Kit makes you look like a Kul Tiras marine. Don't go near Jaina: she sees through it. If you lose the disguise, Sully gives you another kit.",
		rewards = { xp = 1300, reputation = { { faction = "Stormwind", amount = 100 } } },
		prerequisites = { { questID = 95194, name = "Our Man in Theramore" }, { questID = 95196, name = "Watch Yer Back" } },
	},
})
-- Sully's quests after the tower (above): the way in, oldest first. A new table each call.
local function SullysErrand()
	return {
		{ questID = 95194, name = "Our Man in Theramore" },
		{ questID = 95196, name = "Watch Yer Back" },
		{ questID = 95198, name = "The Return of the King?" },
	}
end

--[[
	The Horde's way in, as steps' pages (2026-11-12, the owner's answer: it starts in Orgrimmar). Forever's quest data
	has none of these quests; the site's quest pages (2026-11-12) give their ids, levels, side, objectives
	and texts, their order (one chain: The Missing Kor'kron, The Elite of the Elite, Right Place, Wrong Time), 1,300 XP
	each, Right Place, Wrong Time's 20 silver and 75 Orgrimmar reputation. Their givers and takers, as players saw them
	in game (the pages of 2026-11-13): Eitrigg in Orgrimmar gives The Missing Kor'kron (34.4 39.1; Nazeer's hand-in
	line: "Eitrigg sent you?"), Nazeer Bloodpike takes it and gives The Elite of the Elite, Sergeant Ulka takes that one
	and gives and takes Right Place, Wrong Time. The spots: Eitrigg's the one Blood Red Bandanas has for him (Forever's
	quest data, NPC 3144, in Grommash Hold), Nazeer's his in Forever's quest data (NPC 4791, 35.2 30.7; the page has 35.3),
	Sergeant Ulka's the owner's, 70.4 19.0 (the page has 70.3). The game names him Nazeer Bloodpike, the quest's
	objective "Bloodspike". Best guess: Ulka's two quests at the prison (No Orc Left Behind, A Little Payback) wait for
	Right Place, Wrong Time, as Sully's wait for the tower (her hand-in line asks if you are ready to do your duty).
]]
local EITRIGG = "Eitrigg, Grommash Hold, Orgrimmar"
local NAZEER = "Nazeer Bloodpike, Brackenwall Village, Dustwallow Marsh"
local ULKA = "Sergeant Ulka, outside Alcaz Prison"
-- A new table each call.
local function Nazeer() return { mapID = 1445, x = 0.352, y = 0.307, label = "Nazeer Bloodpike" } end
local function Ulka() return { mapID = 1445, x = 0.704, y = 0.190, label = "Sergeant Ulka" } end
ns.AddQuestSteps({
	[95283] = {
		name = "The Missing Kor'kron", level = 53, requiredLevel = 48, faction = "Horde",
		pickup = EITRIGG, startMap = Orgrimmar(0.3428, 0.3935, "Eitrigg"),
		turnin = NAZEER, endMap = Nazeer(),
		objective = "Speak with Nazeer Bloodspike in Brackenwall Village.",
		-- (its reputation: the quest's page, 2026-11-17)
		rewards = { xp = 1300, reputation = { { faction = "Orgrimmar", amount = 50 } } },
	},
	[95284] = {
		name = "The Elite of the Elite", level = 53, requiredLevel = 48, faction = "Horde",
		pickup = NAZEER, startMap = Nazeer(),
		turnin = ULKA, endMap = Ulka(),
		objective = "Find the missing Kor'kron Elites.",
		note = "An elite quest: bring friends. Nazeer thinks the Kor'kron went to Alcaz Island.",
		-- (its reputation: the quest's page, 2026-11-17)
		rewards = { xp = 1300, reputation = { { faction = "Orgrimmar", amount = 75 } } },
		prerequisites = { { questID = 95283, name = "The Missing Kor'kron" } },
	},
	[95285] = {
		name = "Right Place, Wrong Time", level = 53, requiredLevel = 48, faction = "Horde",
		pickup = ULKA, startMap = Ulka(),
		turnin = ULKA, endMap = Ulka(),
		objective = "Speak with Sergeant Ulka to learn more about the situation on Alcaz Isle.",
		rewards = { xp = 1300, money = 2000, reputation = { { faction = "Orgrimmar", amount = 75 } } },
		prerequisites = { { questID = 95283, name = "The Missing Kor'kron" }, { questID = 95284, name = "The Elite of the Elite" } },
	},
})
-- Sergeant Ulka's quests after Right Place, Wrong Time (above): the way in, oldest first. A new table each call.
local function UlkasErrand()
	return {
		{ questID = 95283, name = "The Missing Kor'kron" },
		{ questID = 95284, name = "The Elite of the Elite" },
		{ questID = 95285, name = "Right Place, Wrong Time" },
	}
end

--[[
	The Alcaz Operative Insignia, a toy (the owner's steps, 2026-11-13): Mason Connery, chained at the prison's end,
	gives The Man in the Iron Chains (The Questioner's key, so The Questioner must still be alive), then More Valuable
	Than Gold, whose note ("WF, 43.4, 67.8") leads to a box under the floorboards upstairs in Moonbrook's inn in
	Westfall: the quest is handed in there, for the Document Box. Each side's State Secrets takes the box for a
	Fractured Insignia; six of those make the toy. Checked in the client's own item data: the Ornate Shackle Key
	(274029, a quest item: the quest's objective calls it the Alcaz Shackle Key), the Document Box (274041, junk,
	sells for 25 gold, not bound), the Fractured Insignia (279450, Uncommon, not bound, level 40; its use, "Combine 6
	Operative Insignias.", as its item page gives it: the spell it casts is in the client's encrypted part), the toy
	(279471, Rare, in the game's Toy table). Who gives and takes each State Secrets (each quest's page's start and end,
	2026-11-18; their spots Forever's quest data's): the Alliance's, Renzik "The Shiv" (NPC 6946, at SI:7 in Stormwind,
	78.29 71.14); the Horde's, Nazgrel (NPC 3230, in Grommash Hold, Orgrimmar 32.3 35.75), the Warchief's advisor its text
	names. Before 2026-11-18 the journal had Rix Xizzix in Booty Bay for the Horde's, a best guess: he is a vendor who
	gives no quest. Each needs More Valuable Than Gold done first (the steps' order, a best guess). The box: Connery's
	Trunk, where the note says (More Valuable Than Gold's page's end, 2026-11-18). Their XP and gold: the pages' (below).
	A new table each call.
]]
local MOONBROOK_BOX = "Mason Connery's treasure, upstairs in the inn at Moonbrook, Westfall"
local RENZIK = "Renzik \"The Shiv\", SI:7, Old Town, Stormwind City"
local NAZGREL = "Nazgrel, Grommash Hold, Orgrimmar"
local function MoonbrookBox() return { mapID = 1436, x = 0.434, y = 0.678, label = "Mason Connery's treasure" } end
local function Renzik() return { mapID = 1453, x = 0.7829, y = 0.7114, label = "Renzik \"The Shiv\"" } end
local function Nazgrel() return Orgrimmar(0.323, 0.3575, "Nazgrel") end
local function MasonsQuests()
	return {
		{ questID = 96335, name = "The Man in the Iron Chains" },
		{ questID = 96337, name = "More Valuable Than Gold" },
	}
end
-- (a State Secrets' reward: the Fractured Insignia)
local function Insignia() return { { itemID = 279450, name = "Fractured Insignia" } } end

Audit("AlcazPrison", {
	add = {
		{
			questID = 96772, name = "The Dragon's Journal", level = 53, requiredLevel = 46, faction = "Alliance",
			pickup = "Archmage Lan'dalock, Dalaran", turnin = "Archmage Lan'dalock, Dalaran",
			-- (he takes it back too: its page's end, 2026-11-18, at the same pins)
			startMap = { mapID = 1416, x = 0.1588, y = 0.7311, label = "Archmage Lan'dalock — Dalaran" },
			endMap = { mapID = 1416, x = 0.1588, y = 0.7311, label = "Archmage Lan'dalock — Dalaran" },
			objective = "Recover Zarla's Journal from the depths of Alcaz Prison.",
			-- (her dragon: the quest's own text calls her a black dragon in disguise, 2026-11-17)
			note = "Zarla's Journal drops from Blazeroar, the last boss: Zarla Ober, the prisoner who turns out to be a dragon.",
			-- (its XP and money: its page's, 2026-11-18, at level 53; the 80 silver before was a guide's)
			rewards = { xp = 14400, money = 16752, reputation = { { faction = "Kirin Tor", amount = 300 }, { faction = "Stormwind", amount = 150 } } },
		},
		{
			questID = 96335, name = "The Man in the Iron Chains", level = 53, requiredLevel = 48, faction = "Both",
			pickup = "Mason Connery, inside Alcaz Prison", turnin = "Mason Connery, inside Alcaz Prison",
			objective = "Recover the Alcaz Shackle Key from The Questioner in Alcaz Prison.",
			-- (the owner's steps, 2026-11-13: he offers it at the end, after Blazeroar, as its text says, and The
			-- Questioner must still be alive; the key is the Ornate Shackle Key in the client's item data)
			-- (handed in together: two players' reports on its page, 2026-11-14 and 11-16, that once one player had freed him,
			-- he walked off and the others could not hand it in; its XP: its page's, 2026-11-18)
			note = "Mason Connery is a prisoner chained at the end of the prison. The Questioner must still be alive: skip him on your way in, then go back for him once you have this quest. He drops the Ornate Shackle Key. Everyone in the group should hand it in at the same time: once one player frees him, he walks off, and the others can't hand it in. This quest can't be shared.",
			rewards = { xp = 2850 },
		},
		{
			questID = 96337, name = "More Valuable Than Gold", level = 53, requiredLevel = 48, faction = "Both",
			pickup = "Mason Connery, inside Alcaz Prison",
			-- (handed in at a box in Westfall: the owner's steps, 2026-11-13, above; its objective as the game gives it. Its
			-- page, 2026-11-18: its goal is the Loose Floorboard (an object), and it ends at Connery's Trunk (an object,
			-- Westfall 43.4 67.9), whose "?" shows once the floorboard is clicked (a player, 2026-11-13). The taker's words
			-- stay "Mason Connery's treasure": the spot is the trunk's. Its XP: its page's.)
			turnin = MOONBROOK_BOX, endMap = MoonbrookBox(),
			objective = "Use the note provided by Mason Connery to find his hidden treasure.",
			note = "Mason's note reads \"WF, 43.4, 67.8\": the inn at Moonbrook in Westfall. Upstairs, click the loose floorboard, then hand the quest in at Connery's Trunk beside it. Don't sell the Document Box it gives you (a vendor pays 25 gold): State Secrets needs it. This quest can't be shared.",
			rewards = { xp = 11550, items = { { itemID = 274041, name = "Document Box" } } },
			prerequisites = { { questID = 96335, name = "The Man in the Iron Chains" } },
		},
		--[[
			The rest of the dungeon's quests (2026-11-09), each read by hand from its Wowhead page (level, side,
			objective, rewards, series), facts only, in our own words. The Alliance's way in is a player's comment
			there (2026-11-09: Mathias Shaw's errand to the dwarf in Theramore's inn, then Jaina's tower; Before you
			go): the dwarf is Sully McCleary, whose text A Bit of Wet Work is and to whom Somber News returns, so he
			gives The Secret Prison too (its text is a dwarf's). The Horde's Sergeant Ulka is the players' guide's
			(Data/Authored/Upcoming.lua), and A Little Payback's text is hers (Right Place, Wrong Time's text calls her
			"she"); Commander Folkar's text is The Honor of the Kor'kron's and Thrall Needs to Know's. Its series: The Honor of the Kor'kron, Bad News for Folkar,
			Thrall Needs to Know; and The Man in the Iron Chains, Somber News. Each State Secrets: its giver and reward
			since the owner's steps of 2026-11-13 (above). Its reputation: the Alliance's page of 2026-11-09 listed
			Orgrimmar's, as the Horde's did; left out of the Alliance's on purpose (an Alliance player gains no Orgrimmar
			reputation), kept on the Horde's. The Alliance quest's own data on the site still carries the 150 Orgrimmar
			(read again 2026-11-18); neither the client's files nor the owner's steps say either way.
			Since 2026-11-12 the Alliance's way in is three quests of its own, the steps above (SullysErrand), and the
			Horde's from Orgrimmar too (UlkasErrand).
			XP and money (2026-11-18): the figures each quest's page shows at level 53, as No Orc Left Behind's and The
			Honor of the Kor'kron's were read (fairly sure; State Secrets' money only from the page's scaling reward).
		]]
		{
			questID = 95262, name = "The Secret Prison", level = 53, requiredLevel = 48, faction = "Alliance",
			pickup = SULLY_GRAVEYARD, startMap = Graveyard(),
			objective = "Enter Alcaz Prison and learn what became of the King of Stormwind.",
			-- (its two goals on its page, 2026-11-17: the last boss, Blazeroar, and the note on the ground after him, which
			-- a player's comment on the Horde's twin places)
			note = "It can't be shared. It is done once Blazeroar, the last boss, is dead and you have read the note about the King on the ground after the fight.",
			rewards = { xp = 14400, money = 13919, reputation = { { faction = "Stormwind", amount = 150 } } },
			prerequisites = SullysErrand(),
		},
		{
			questID = 96381, name = "A Bit of Wet Work", level = 53, requiredLevel = 48, faction = "Alliance",
			pickup = SULLY_GRAVEYARD, turnin = SULLY_GRAVEYARD,
			startMap = Graveyard(), endMap = Graveyard(),
			objective = "Kill 15 Strashaz Soldiers and 8 Strashaz Enchantresses in Alcaz Prison, and bring Tidemistress Ca'zass's head to Sully McCleary.",
			rewards = {
				xp = 11550,
				money = 8000,
				choice = true,
				items = { { itemID = 279825, name = "Theramore Defender's Gauntlets" }, { itemID = 279826, name = "Marshdweller's Pants" }, { itemID = 279829, name = "Naga Scale Spaulders" } },
				reputation = { { faction = "Stormwind", amount = 100 }, { faction = "Ironforge", amount = 100 } },
			},
			prerequisites = SullysErrand(),
		},
		{
			questID = 95263, name = "Somber News", level = 53, requiredLevel = 48, faction = "Alliance",
			pickup = "Inside Alcaz Prison", turnin = SULLY_GRAVEYARD,
			endMap = Graveyard(),
			objective = "Take what you learned of the King of Stormwind back to Sully McCleary in Dustwallow Marsh.",
			-- (where it starts: its text is an object's or an item's, and two guides name the Perfumed Note by Blazeroar,
			-- 2026-11-18; its XP: its page's)
			note = "It can't be shared. It starts from the Perfumed Note on the ground by Blazeroar after the fight, once you have done The Secret Prison and The Man in the Iron Chains.",
			rewards = { xp = 2850, reputation = { { faction = "Stormwind", amount = 75 } } },
			-- (The Secret Prison too since 2026-11-17, both kept at the owner's word of 2026-11-18: the quests' series lists
			-- The Secret Prison and The Man in the Iron Chains side by side just before this one, and a walk-through posted
			-- on its own page, 2026-11-09, warns that killing The Questioner before the last boss loses the last quest. Its
			-- news, the King's death, is what The Secret Prison finds out.)
			prerequisites = {
				{ questID = 95262, name = "The Secret Prison" },
				{ questID = 96335, name = "The Man in the Iron Chains" },
			},
		},
		--[[
			The chain's end, back at Shaw (the owner's yes, 2026-11-12), as the Horde's Thrall Needs to Know. Its page on the
			site (2026-11-12): its objective (it spells him "Matthias", kept as the game shows it), text, and rewards:
			1,300 XP (the site's number, not yet seen in game), 80 silver, 100 Stormwind reputation, a choice of the three
			items. The page names no giver and no series: Sully gives it (its text is his, "I beg ye", and sends you back to
			Stormwind with the news), after Somber News brings him that news: a best guess, as Thrall Needs to Know follows
			Bad News for Folkar. Not shareable, by its page (no "Shareable"), as Somber News.
		]]
		{
			questID = 95264, name = "Shaw Needs To Know", level = 53, requiredLevel = 48, faction = "Alliance",
			pickup = SULLY_GRAVEYARD, turnin = "Master Mathias Shaw, Stormwind City",
			-- (the graveyard Sully gives it: his page lists it, 2026-11-17)
			startMap = Graveyard(), endMap = Shaw(),
			objective = "Bring the news to Matthias Shaw in Stormwind.",
			note = "It can't be shared.",
			rewards = {
				xp = 1300,
				money = 8000,
				choice = true,
				items = { { itemID = 279833, name = "Courier's Clasp" }, { itemID = 279831, name = "Fatebound Buckler" }, { itemID = 279474, name = "Dustwallow Dirk" } },
				reputation = { { faction = "Stormwind", amount = 100 } },
			},
			prerequisites = {
				{ questID = 96335, name = "The Man in the Iron Chains" },
				{ questID = 95263, name = "Somber News" },
			},
		},
		{
			questID = 96377, name = "State Secrets", level = 53, requiredLevel = 48, faction = "Alliance",
			pickup = RENZIK, turnin = RENZIK, startMap = Renzik(), endMap = Renzik(),
			objective = "Bring back the Document Box.",
			note = "It needs the Document Box from More Valuable Than Gold. Its reward, the {item:279450:Fractured Insignia:2}, can be traded: six of them combine into the {item:279471:Alcaz Operative Insignia:3}, a toy. One run is enough: trade or buy the other five. This quest can't be shared. The Horde has its own State Secrets.",
			rewards = { xp = 6550, money = 16000, items = Insignia() },
			prerequisites = MasonsQuests(),
		},
		{
			questID = 95309, name = "No Orc Left Behind", level = 53, requiredLevel = 48, faction = "Horde",
			pickup = "Sergeant Ulka, outside Alcaz Prison", turnin = "Commander Folkar, inside Alcaz Prison",
			-- (Ulka's spot and her quests after Right Place, Wrong Time since 2026-11-12: the steps above, UlkasErrand)
			startMap = Ulka(),
			objective = "Go down into Alcaz Prison and find Commander Folkar.",
			-- (its page, 2026-11-17: its goal, Find Commander Folkar, is credited by Katerina the Cleaner; a guide, 2026-11-18:
			-- Folkar is chained behind her and gives The Honor of the Kor'kron once she is dead. Fairly sure, to check in
			-- game. Its XP and its money at level 53, about 1 gold 39 silver)
			note = "Commander Folkar is chained just past Katerina the Cleaner: he counts as found once she is dead.",
			rewards = { xp = 12100, money = 13919, reputation = { { faction = "Orgrimmar", amount = 150 } } },
			prerequisites = UlkasErrand(),
		},
		{
			questID = 96332, name = "A Little Payback", level = 53, requiredLevel = 48, faction = "Horde",
			pickup = "Sergeant Ulka, outside Alcaz Prison", turnin = "Sergeant Ulka, outside Alcaz Prison",
			startMap = Ulka(), endMap = Ulka(),
			prerequisites = UlkasErrand(),
			objective = "Kill 15 Strashaz Soldiers and 8 Strashaz Enchantresses in Alcaz Prison, and bring Tidemistress Ca'zass's head to Sergeant Ulka.",
			rewards = {
				xp = 9700,
				money = 8000,
				choice = true,
				items = { { itemID = 279824, name = "Kor'kron Battle Gauntlets" }, { itemID = 279826, name = "Marshdweller's Pants" }, { itemID = 279829, name = "Naga Scale Spaulders" } },
				reputation = { { faction = "Orgrimmar", amount = 75 } },
			},
		},
		{
			questID = 95454, name = "The Honor of the Kor'kron", level = 53, requiredLevel = 48, faction = "Horde",
			pickup = "Commander Folkar, inside Alcaz Prison",
			objective = "Search Alcaz Prison for King Varian Wrynn, and read the note on the ground.",
			-- (its page, 2026-11-17: its goals are Blazeroar, the last boss, and the note on the ground after him; its XP and
			-- its money at level 53. Folkar gives it once Katerina is dead: a guide, 2026-11-18, as No Orc Left Behind's.
			-- Whether it needs No Orc Left Behind done: nothing says, so no lock)
			note = "Commander Folkar, chained past Katerina the Cleaner, gives it once she is dead. It is done once Blazeroar, the last boss, is dead and you have read the note about the King on the ground after the fight.",
			rewards = { xp = 12100, money = 13919, reputation = { { faction = "Orgrimmar", amount = 100 } } },
		},
		{
			questID = 96369, name = "Bad News for Folkar", level = 53, requiredLevel = 48, faction = "Horde",
			pickup = "Inside Alcaz Prison", turnin = "Commander Folkar, inside Alcaz Prison",
			objective = "Take what you learned of King Varian Wrynn back to Commander Folkar.",
			-- (where it starts: its text is an object's or an item's, and two guides name the Perfumed Note by Blazeroar,
			-- 2026-11-18)
			note = "It starts from the Perfumed Note on the ground by Blazeroar after the fight.",
			-- (its XP: its page, 2026-11-17)
			rewards = { xp = 2400, reputation = { { faction = "Orgrimmar", amount = 50 } } },
			prerequisites = { { questID = 95454, name = "The Honor of the Kor'kron" } },
		},
		{
			questID = 95483, name = "Thrall Needs to Know", level = 53, requiredLevel = 48, faction = "Horde",
			pickup = "Commander Folkar, inside Alcaz Prison", turnin = "Thrall, Orgrimmar",
			endMap = Orgrimmar(0.3173, 0.3782, "Thrall"),
			objective = "Bring word of King Varian Wrynn's fate to Thrall in Orgrimmar.",
			rewards = {
				xp = 2400,
				choice = true,
				items = { { itemID = 279831, name = "Fatebound Buckler" }, { itemID = 279833, name = "Courier's Clasp" }, { itemID = 279474, name = "Dustwallow Dirk" } },
				reputation = { { faction = "Orgrimmar", amount = 100 } },
			},
			prerequisites = {
				{ questID = 95454, name = "The Honor of the Kor'kron" },
				{ questID = 96369, name = "Bad News for Folkar" },
			},
		},
		{
			questID = 96334, name = "Blood Red Bandanas", level = 53, requiredLevel = 48, faction = "Horde",
			-- (its giver: Sergeant Ulka, its page's Quick Facts, read again 2026-11-17 for the review of e36e2fe, with its
			-- XP, 9,700. The quests before it are the BEST GUESS: its page shows no series and no quest it needs; a
			-- player's comment has The Elite of the Elite lead to it, and Ulka's other quests come after her errand (the
			-- owner's steps), so her errand as theirs. A question for the owner: does it need her earlier quests?)
			pickup = ULKA, startMap = Ulka(),
			turnin = "Eitrigg, Orgrimmar", endMap = Orgrimmar(0.3428, 0.3935, "Eitrigg"),
			objective = "Collect 8 Blood Red Bandanas from the human guards in Alcaz Prison and take them to Eitrigg in Orgrimmar.",
			note = "Sergeant Ulka gives it, outside the prison. The bandanas drop rarely: a group may need several runs.",
			prerequisites = UlkasErrand(),
			rewards = {
				xp = 9700,
				choice = true,
				items = { { itemID = 279448, name = "Bloodsplattered Bandana" }, { itemID = 279473, name = "Makeshift Belt" } },
				reputation = { { faction = "Orgrimmar", amount = 75 } },
			},
		},
		{
			questID = 96376, name = "State Secrets", level = 53, requiredLevel = 48, faction = "Horde",
			-- (Nazgrel in Orgrimmar since 2026-11-18, its page's start and end, above)
			pickup = NAZGREL, turnin = NAZGREL, startMap = Nazgrel(), endMap = Nazgrel(),
			objective = "Bring back the Document Box.",
			note = "It needs the Document Box from More Valuable Than Gold. Its reward, the {item:279450:Fractured Insignia:2}, can be traded: six of them combine into the {item:279471:Alcaz Operative Insignia:3}, a toy. One run is enough: trade or buy the other five. This quest can't be shared. The Alliance has its own State Secrets.",
			-- (the Orgrimmar reputation as the page of 2026-11-09 listed it: not confirmed, above)
			rewards = { xp = 6550, money = 16000, items = Insignia(), reputation = { { faction = "Orgrimmar", amount = 150 } } },
			prerequisites = MasonsQuests(),
		},
	},
})

-- Blackmaw Hold. Get to the Roots of It, for each side, after Beneath Nordrassil (its page's series; a step's page:
-- Data/Authored/Upcoming.lua): its text is the druid's the step sends you to, who takes the root caps. The Alliance's
-- Blackmaw Magic names Lan'dalock as its writer's partner: Archmage Timear; the Horde's names no giver.
Audit("BlackmawHold", {
	add = {
		{
			questID = 92344, name = "Get to the Roots of It", level = 55, requiredLevel = 45, faction = "Alliance",
			pickup = "Mathrengyl Bearwalker, Darnassus", turnin = "Mathrengyl Bearwalker, Darnassus",
			startMap = { mapID = 1457, x = 0.354, y = 0.084, label = "Mathrengyl Bearwalker" },
			endMap = { mapID = 1457, x = 0.354, y = 0.084, label = "Mathrengyl Bearwalker" },
			objective = "Gather 10 Nordrassil Root Caps inside Blackmaw Hold for Mathrengyl Bearwalker in Darnassus.",
			rewards = { reputation = { { faction = "Darnassus", amount = 150 } } },
			prerequisites = { { questID = 92345, name = "Beneath Nordrassil" } },
		},
		{
			questID = 92343, name = "Get to the Roots of It", level = 55, requiredLevel = 45, faction = "Horde",
			pickup = "Nara Wildmane, Thunder Bluff", turnin = "Nara Wildmane, Thunder Bluff",
			startMap = { mapID = 1456, x = 0.757, y = 0.316, label = "Nara Wildmane" },
			endMap = { mapID = 1456, x = 0.757, y = 0.316, label = "Nara Wildmane" },
			objective = "Gather 10 Nordrassil Root Caps inside Blackmaw Hold for Nara Wildmane in Thunder Bluff.",
			rewards = { reputation = { { faction = "Thunder Bluff", amount = 150 } } },
			prerequisites = { { questID = 92346, name = "Beneath Nordrassil" } },
		},
		{
			questID = 97173, name = "Blackmaw Magic", level = 59, requiredLevel = 52, faction = "Alliance",
			pickup = "Archmage Timear, Dalaran",
			startMap = { mapID = 1416, x = 0.1617, y = 0.7166, label = "Archmage Timear — Dalaran" },
			objective = "Recover a Blackmaw Ritual Totem from Blackmaw Hold.",
			rewards = { money = 9000, reputation = { { faction = "Kirin Tor", amount = 300 }, { faction = "Darnassus", amount = 150 } } },
		},
		{
			questID = 97198, name = "Blackmaw Magic", level = 59, requiredLevel = 52, faction = "Horde",
			objective = "Recover a Blackmaw Ritual Totem from Blackmaw Hold.",
			note = "Who gives the quest is not listed yet.",
			rewards = { money = 9000, reputation = { { faction = "Earthen Ring", amount = 300 }, { faction = "Thunder Bluff", amount = 150 } } },
		},
		-- Claws That Rend, Tusks that Gore, for both sides: its text is Ogtinc's, who takes them (Ogtinc's spot as his
		-- other quests give it).
		{
			questID = 92069, name = "Claws That Rend, Tusks that Gore", level = 58, requiredLevel = 45, faction = "Both",
			pickup = "Ogtinc, Azshara", turnin = "Ogtinc, Azshara",
			startMap = { mapID = 1447, x = 0.424, y = 0.426, label = "Ogtinc" },
			endMap = { mapID = 1447, x = 0.424, y = 0.426, label = "Ogtinc" },
			objective = "Bring the Claws of the Great Bear and the Tusks of the Unbroken to Ogtinc in Azshara.",
			note = "They come from Withermaw, the great bear, and Bonesnout, the Unbroken, two beasts that roam the hold.",
			rewards = {
				choice = true,
				items = {
					{ itemID = 260213, name = "Great Bear Claw" },
					{ itemID = 260214, name = "Staff of Wild Beasts" },
					{ itemID = 260215, name = "Wild Malleus" },
				},
				reputation = { { faction = "Timbermaw Hold", amount = 150 } },
			},
		},
		--[[
			Four more of the dungeon's quests (2026-11-09), each read by hand from its Wowhead page: the Blackmaw
			furbolgs' own, given at Ursolan and the Ruins of Eldarath in Azshara. Each names who takes it, and its
			text is theirs. Their places have no spot in Forever's quest data yet.
		]]
		{
			questID = 92065, name = "Blackmaw Reclamation", level = 60, requiredLevel = 47, faction = "Both",
			pickup = "Gatekeeper Rageroar, Ursolan, Azshara", turnin = "Gatekeeper Rageroar, Ursolan, Azshara",
			objective = "Kill Varrox Bleakhoof in Blackmaw Hold and bring his head to Gatekeeper Rageroar at Ursolan.",
			rewards = {
				choice = true,
				items = { { itemID = 260216, name = "Ouroboros Ring" }, { itemID = 260217, name = "Eagle's Head Signet" }, { itemID = 260218, name = "Malefactor's End" }, { itemID = 260219, name = "Engraved Band" } },
				reputation = { { faction = "Timbermaw Hold", amount = 150 } },
			},
		},
		{
			questID = 92066, name = "The Twin Bears", level = 55, requiredLevel = 47, faction = "Both",
			pickup = "Lorekeeper Nok, Ursolan, Azshara", turnin = "Lorekeeper Nok, Ursolan, Azshara",
			objective = "Find the Totem of Ursoc and the Totem of Ursol inside Blackmaw Hold and bring them to Lorekeeper Nok at Ursolan.",
			rewards = {
				choice = true,
				items = { { itemID = 279891, name = "Guidance of Ursoc" }, { itemID = 279892, name = "Wisdom of Ursol" } },
				reputation = { { faction = "Timbermaw Hold", amount = 150 } },
			},
		},
		{
			questID = 92070, name = "A Lost Memento", level = 55, requiredLevel = 47, faction = "Both",
			startItem = { itemID = 249698, name = "Feathered Charm Necklace" },
			objective = "Find the owner of the Feathered Charm Necklace.",
			note = "It can't be shared. The necklace is a furbolg child's charm.",
			rewards = {
				items = { { itemID = 279893, name = "Nama's Cherished Necklace" } },
				reputation = { { faction = "Timbermaw Hold", amount = 100 } },
			},
		},
		{
			questID = 97327, name = "Blackmaw Pouches", level = 60, requiredLevel = 55, faction = "Both",
			pickup = "Ekkal, Ruins of Eldarath, Azshara", turnin = "Ekkal, Ruins of Eldarath, Azshara",
			objective = "Recover 5 Blackmaw Pouches inside Blackmaw Hold for Ekkal at the Ruins of Eldarath.",
			rewards = { money = 9000, reputation = { { faction = "Timbermaw Hold", amount = 150 } } },
		},
	},
})

--[[
	The Shaper's Terrace's six quests (2026-11-18), each read by hand from its quest page (level, side, giver and taker,
	objective, rewards, whether it can be shared), facts only, in our own words; where each quest's items come from,
	the items' own pages and a players' guide to the dungeon. Forever's quest data has none of them yet. The givers'
	spots: Forever's quest data (Curator Thorius, Chemist Fuely; Master Apothecary Faranell as above); Mayena
	Earthseeker's, the quest page's mark (the quest data has eight spots for her, around it). Digestible Research's
	page names no giver, only Curator Thorius, who takes it. Their names and objectives stay English, as the game shows
	these new quests in every language; their notes and givers are drafted in the other languages, to be checked.
]]
local THORIUS_LINE = "Curator Thorius, Hall of Explorers, Ironforge"
local function Thorius() return { mapID = 1455, x = 0.715, y = 0.1574, label = "Curator Thorius — Hall of Explorers" } end
local FUELY_LINE = "Chemist Fuely, the Apothecarium, Undercity"
local function Fuely() return { mapID = 1458, x = 0.4745, y = 0.7335, label = "Chemist Fuely — the Apothecarium" } end
local MAYENA_LINE = "Mayena Earthseeker, Mulgore"
local function Mayena() return { mapID = 1412, x = 0.348, y = 0.220, label = "Mayena Earthseeker" } end
-- (each quest's XP: the figure its page shows, 2026-11-18; the page's hidden list says 6,600, as Alcaz Prison's did,
-- and the shown figure is the one kept there too. No turn-in seen in game yet)
Audit("ShapersTerrace", {
	add = {
		{
			questID = 95924, name = "Panic at the Digsite", level = 60, requiredLevel = 55, faction = "Alliance",
			pickup = THORIUS_LINE, turnin = THORIUS_LINE, startMap = Thorius(), endMap = Thorius(),
			objective = "Kill Venomridge, 6 Ravasaur Matriarchs and 9 Ironhide Ravasaurs in the Shaper's Terrace.",
			note = "Venomridge, a great diemetradon, is one of the optional bosses, on the plain south of the tar pits.",
			rewards = {
				xp = 17650, money = 9000, choice = true,
				items = { { itemID = 279903, name = "Diemetradon Scale Spaulders" }, { itemID = 279905, name = "Ravasaur Hide Footpads" } },
				reputation = { { faction = "Ironforge", amount = 100 }, { faction = "Stormwind", amount = 50 } },
			},
		},
		{
			questID = 95925, name = "Mapping the Way Forward", level = 60, requiredLevel = 55, faction = "Alliance",
			pickup = THORIUS_LINE, turnin = THORIUS_LINE, startMap = Thorius(), endMap = Thorius(),
			objective = "Find five landmarks in the Shaper's Terrace and fill in the explorer's map at each.",
			-- (the kit, 271770, is given with the quest; the five places as its page names them. Its three choices are The
			-- Dark Crystal's too, on both pages: possibly a placeholder, to check at a turn-in)
			note = "Use the Explorers' League Cartographer's Kit you are given at the Pillar of Assimilation, the Achromatic Crystal, the Western Gates, the Regrowth Vestibule and the Unearthed Stone Watcher. It can't be shared.",
			rewards = {
				xp = 17650, choice = true,
				items = { { itemID = 279908, name = "Crystal-Infused Cleaver" }, { itemID = 279910, name = "Beastslayer's Trident" },
					{ itemID = 279912, name = "Faintly Glowing Orb" } },
				reputation = { { faction = "Ironforge", amount = 100 }, { faction = "Stormwind", amount = 50 } },
			},
		},
		{
			questID = 95790, name = "Digestible Research", level = 60, requiredLevel = 55, faction = "Alliance",
			turnin = THORIUS_LINE, endMap = Thorius(),
			objective = "Collect 15 Partially Digested Journal Pages in the Shaper's Terrace.",
			-- (the pages' own page: they drop off the dungeon's ravasaurs, its hunters, matriarchs, juveniles and trappers)
			note = "Who gives it is not listed yet. The pages drop from the ravasaurs inside. It can't be shared.",
			rewards = {
				xp = 17650, choice = true,
				items = { { itemID = 279931, name = "Lost Researcher's Hood" }, { itemID = 279901, name = "Expeditionary Legplates" } },
				reputation = { { faction = "Ironforge", amount = 100 }, { faction = "Stormwind", amount = 100 } },
			},
		},
		{
			questID = 95928, name = "Crystalline Elements", level = 60, requiredLevel = 55, faction = "Horde",
			pickup = MAYENA_LINE, turnin = MAYENA_LINE, startMap = Mayena(), endMap = Mayena(),
			objective = "Bring Mayena Earthseeker a Moist Crystal, a Charged Crystal, a Noxious Crystal and a Fiery Crystal from the Shaper's Terrace.",
			-- (the items' own pages: the Fiery, Charged and Moist Crystals from crystal fragments of their kinds; the
			-- Noxious Crystal's page not read, the same by its name, a best guess)
			note = "Each most likely comes from a crystal fragment of its kind in the terrace. They are not the Power Crystals the consoles take.",
			rewards = {
				xp = 17650, choice = true,
				items = { { itemID = 279904, name = "Crystalline Pauldrons" }, { itemID = 279906, name = "Potent Treads" } },
				reputation = { { faction = "Orgrimmar", amount = 50 }, { faction = "Earthen Ring", amount = 100 } },
			},
		},
		{
			questID = 97049, name = "Essence of Seeping Slimes", level = 60, requiredLevel = 55, faction = "Horde",
			pickup = FUELY_LINE, turnin = FUELY_LINE, startMap = Fuely(), endMap = Fuely(),
			objective = "Gather 8 Seeping Slime Essence in the Shaper's Terrace.",
			-- (the quest's own text and a players' guide)
			note = "The essence drops from the small slimes in the pools by the Achromatic Crystal.",
			rewards = {
				xp = 17650, money = 9000, choice = true,
				items = { { itemID = 279932, name = "Slime-Resistant Shroud" }, { itemID = 279902, name = "Reinforced Muck Protectors" } },
				reputation = { { faction = "Undercity", amount = 100 }, { faction = "Orgrimmar", amount = 50 } },
			},
		},
		{
			questID = 95926, name = "The Dark Crystal", level = 60, requiredLevel = 55, faction = "Horde",
			pickup = "Master Apothecary Faranell, the Apothecarium, Undercity",
			turnin = "Master Apothecary Faranell, the Apothecarium, Undercity", startMap = FARANELL, endMap = FARANELL,
			objective = "Gather a Drained Crystal Fragment near the Achromatic Crystal in the Shaper's Terrace.",
			-- (the quest's own text and a players' guide)
			note = "The fragment lies on the ground near the Achromatic Crystal, a colorless crystal in the terrace.",
			-- (the same three choices as Mapping the Way Forward, on both quest pages: possibly a placeholder; to check at
			-- a turn-in)
			-- Its XP as the owner's table gives it (2026-11-18): 6,600, where the other five give 17,650 (the Horde's three,
			-- 41,900 in all, add up only so). Its quest page shows 17,650: to be checked at a turn-in.
			rewards = {
				xp = 6600, choice = true,
				items = { { itemID = 279908, name = "Crystal-Infused Cleaver" }, { itemID = 279910, name = "Beastslayer's Trident" },
					{ itemID = 279912, name = "Faintly Glowing Orb" } },
				reputation = { { faction = "Undercity", amount = 100 }, { faction = "Orgrimmar", amount = 50 } },
			},
		},
	},
})

Audit("ScarletMonasteryArmory", {
	patches = {
		-- In the Name of the Light: prerequisites (Questie, foreverchanges)
		[1053] = {
			prerequisites = { { questID = 261, name = "Down the Scarlet Path" }, { questID = 1052, name = "Down the Scarlet Path" } },
		},
		-- Hearts of Zeal: prerequisites (Questie, FDJ, foreverchanges)
		[1113] = {
			prerequisites = { { questID = 1109, name = "Going, Going, Guano!" } },
		},
	},
})

Audit("RazorfenDowns", {
	-- 2026-11-08, the owner's report: The Coldbringer's Eye, new in Forever, one for each side, read by hand from the
	-- quests' own pages (level, side, giver, objective, rewards; facts only). The givers' spots are Forever's quest
	-- data's (Sutara Plainstalker walks a little around Mazu'kon's camp: the middle of her spots). The Alliance's
	-- names no one to hand it to. Who has the Eye is not listed: the Horde's text sends you to Amnennar's lair.
	add = {
		{
			questID = 96773, name = "The Coldbringer's Eye", level = 41, requiredLevel = 34, faction = "Alliance",
			pickup = "Archmage Lan'dalock, Dalaran",
			startMap = { mapID = 1416, x = 0.1588, y = 0.7311, label = "Archmage Lan'dalock — Dalaran" },
			objective = "Recover The Coldbringer's Eye from Razorfen Downs.",
			note = "The Eye is a scrying orb the Scourge use to direct their minions. Look for it in Amnennar the Coldbringer's lair, at the end of the dungeon.",
			rewards = { money = 5500, reputation = { { faction = "Kirin Tor", amount = 300 }, { faction = "Stormwind", amount = 150 } } },
		},
		{
			questID = 97196, name = "The Coldbringer's Eye", level = 41, requiredLevel = 34, faction = "Horde",
			pickup = "Sutara Plainstalker, Mulgore", turnin = "Sutara Plainstalker, Mulgore",
			startMap = { mapID = 1412, x = 0.343, y = 0.228, label = "Sutara Plainstalker" },
			endMap = { mapID = 1412, x = 0.343, y = 0.228, label = "Sutara Plainstalker" },
			objective = "Recover The Coldbringer's Eye from Razorfen Downs.",
			note = "The Eye is a scrying orb the Scourge use to direct their minions. Look for it in Amnennar the Coldbringer's lair, at the end of the dungeon.",
			rewards = { money = 5500, reputation = { { faction = "Earthen Ring", amount = 300 }, { faction = "Thunder Bluff", amount = 150 } } },
		},
		-- Agamaggan's Blood: new in Forever, for both sides; its page names no giver, but its text is Kog'thug's, who
		-- takes the blood. His spot is not in Forever's quest data.
		{
			questID = 93604, name = "Agamaggan's Blood", level = 45, requiredLevel = 35, faction = "Both",
			pickup = "Kog'thug the Brave, Bristleback Retreat, Desolace", turnin = "Kog'thug the Brave, Bristleback Retreat, Desolace",
			objective = "Bring the Virulent Blood of Agamaggan from Razorfen Downs to Kog'thug the Brave at Bristleback Retreat in Desolace.",
			note = "It has to be the blood from the Downs: the Blood of Agamaggan in Razorfen Kraul won't do.",
			rewards = { money = 6500 },
		},
	},
	patches = {
		-- Scourge of the Downs: pickup, turnin (Questie, foreverchanges)
		[3523] = {
			pickup = "Belnistrasz, inside Razorfen Downs",
			turnin = "Belnistrasz, inside Razorfen Downs",
		},
		-- Extinguishing the Idol: pickup, turnin (Questie, foreverchanges, AAL)
		[3525] = {
			pickup = "Belnistrasz, inside Razorfen Downs",
			turnin = "Belnistrasz's Brazier, inside Razorfen Downs",
		},
		-- An Unholy Alliance: pickup, startItem (Questie, FDJ, foreverchanges)
		[6522] = {
			pickup = "Small Scroll, dropped by Charlga Razorflank in Razorfen Kraul",
			startItem = { itemID = 17008, name = "Small Scroll", note = "Drops from Charlga Razorflank in Razorfen Kraul." },
		},
	},
})

Audit("ScarletMonasteryCathedral", {
	add = {
		-- Hearts of Zeal (FDJ, Questie, foreverchanges)
		{
			questID = 1113, name = "Hearts of Zeal", level = 33, requiredLevel = 30, faction = "Horde",
			pickup = "Master Apothecary Faranell, the Apothecarium, Undercity",
			turnin = "Master Apothecary Faranell, the Apothecarium, Undercity",
			startMap = { mapID = 1458, x = 0.488, y = 0.693, label = "Master Apothecary Faranell" },
			endMap = { mapID = 1458, x = 0.488, y = 0.693, label = "Master Apothecary Faranell" },
			objective = "Bring 20 Hearts of Zeal to Master Apothecary Faranell in the Undercity.",
			note = "The Scarlet Crusaders of every wing carry the hearts, and so do their leaders.",
			prerequisites = { { questID = 1109, name = "Going, Going, Guano!" } },
			rewards = { xp = 3300, reputation = { { faction = "Undercity", amount = 150 } } },
		},
	},
	patches = {
		-- In the Name of the Light: prerequisites (Questie, foreverchanges)
		[1053] = {
			prerequisites = { { questID = 261, name = "Down the Scarlet Path" }, { questID = 1052, name = "Down the Scarlet Path" } },
		},
	},
})

Audit("Uldaman", {
	add = {
		-- Power in Uldaman (Questie)
		{
			questID = 1956, name = "Power in Uldaman", level = 40, requiredLevel = 35, faction = "Both", classOnly = "MAGE",
			pickup = "Tabetha, Dustwallow Marsh", turnin = "Tabetha, Dustwallow Marsh",
			startMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			endMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			objective = "Bring Tabetha in Dustwallow Marsh an Obsidian Power Source.",
			note = "A mage quest. The Obsidian Sentinel inside Uldaman carries the power source.",
			prerequisites = { { questID = 1954, name = "The Infernal Orb" }, { questID = 1955, name = "The Exorcism" } },
			rewards = { xp = 3900 },
		},
		-- Mana Surges and Celestial Power, the chain's last two steps, from and to Tabetha (Questie; the Mana
		-- Surges, npc 6550, come out by her house; foreverchanges.pro's quest pages for the 10 minutes and the
		-- rewards, 2026-11-03; the owner's call of that day: a chain's last steps at the same giver stay)
		{
			questID = 1957, name = "Mana Surges", level = 40, requiredLevel = 35, faction = "Both", classOnly = "MAGE",
			pickup = "Tabetha, Dustwallow Marsh", turnin = "Tabetha, Dustwallow Marsh",
			startMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			endMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			objective = "Kill 12 Mana Surges in the allowed time limit.",
			note = "The Mana Surges come out of a rift Tabetha opens by her house. You have 10 minutes.",
			prerequisites = {
				{ questID = 1954, name = "The Infernal Orb" },
				{ questID = 1955, name = "The Exorcism" },
				{ questID = 1956, name = "Power in Uldaman" },
			},
			rewards = { xp = 2350 },
		},
		{
			questID = 1958, name = "Celestial Power", level = 40, requiredLevel = 35, faction = "Both", classOnly = "MAGE",
			pickup = "Tabetha, Dustwallow Marsh", turnin = "Tabetha, Dustwallow Marsh",
			startMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			endMap = { mapID = 1445, x = 0.461, y = 0.571, label = "Tabetha" },
			objective = "Talk to Tabetha in Dustwallow Marsh for your reward.",
			prerequisites = {
				{ questID = 1954, name = "The Infernal Orb" },
				{ questID = 1955, name = "The Exorcism" },
				{ questID = 1956, name = "Power in Uldaman" },
				{ questID = 1957, name = "Mana Surges" },
			},
			rewards = {
				xp = 3150, choice = true,
				items = { { itemID = 7515, name = "Celestial Orb", quality = 3 }, { itemID = 9517, name = "Celestial Stave", quality = 3 } },
			},
		},
	},
	patches = {
		-- Agmond's Fate: prerequisites (Questie, foreverchanges)
		[704] = {
			prerequisites = { { questID = 738, name = "Find Agmond" }, { questID = 739, name = "Murdaloc" } },
		},
		-- A Sign of Hope: turnin, endMap (Questie, foreverchanges)
		[721] = {
			turnin = "Hammertoe Grez, Badlands",
			endMap = { mapID = 1418, x = 0.379, y = 0.106, label = "Hammertoe Grez" },
		},
		-- Amulet of Secrets: pickup, startMap, turnin, endMap, prerequisites (Questie, foreverchanges)
		[722] = {
			pickup = "Hammertoe Grez, Badlands",
			startMap = { mapID = 1418, x = 0.379, y = 0.106, label = "Hammertoe Grez" },
			turnin = "Hammertoe Grez, Badlands",
			endMap = { mapID = 1418, x = 0.379, y = 0.106, label = "Hammertoe Grez" },
			prerequisites = { { questID = 720, name = "A Sign of Hope" }, { questID = 721, name = "A Sign of Hope" } },
		},
		-- The Lost Tablets of Will: pickup, startMap, turnin, endMap, prerequisites (Questie, foreverchanges, AAL)
		[1139] = {
			pickup = "Advisor Belgrum, Hall of Explorers, Ironforge",
			startMap = { mapID = 1455, x = 0.773, y = 0.097, label = "Advisor Belgrum" },
			turnin = "Advisor Belgrum, Hall of Explorers, Ironforge",
			endMap = { mapID = 1455, x = 0.773, y = 0.097, label = "Advisor Belgrum" },
			prerequisites = {
				{ questID = 720, name = "A Sign of Hope" },
				{ questID = 721, name = "A Sign of Hope" },
				{ questID = 722, name = "Amulet of Secrets" },
				{ questID = 723, name = "Prospect of Faith" },
				{ questID = 724, name = "Prospect of Faith" },
				{ questID = 725, name = "Passing Word of a Threat" },
				{ questID = 726, name = "Passing Word of a Threat" },
				{ questID = 762, name = "An Ambassador of Evil" },
			},
		},
		-- Reclaimed Treasures: pickup, startMap, turnin, endMap (Questie, foreverchanges)
		[1360] = {
			pickup = "Krom Stoutarm, Hall of Explorers, Ironforge",
			startMap = { mapID = 1455, x = 0.742, y = 0.094, label = "Krom Stoutarm" },
			turnin = "Krom Stoutarm, Hall of Explorers, Ironforge",
			endMap = { mapID = 1455, x = 0.742, y = 0.094, label = "Krom Stoutarm" },
		},
		-- The Shattered Necklace: pickup, turnin, endMap (Questie, FDJ, foreverchanges, AAL)
		[2198] = {
			pickup = "Shattered Necklace, dropped by the Shadowforge dwarves and Stonevault troggs around Uldaman",
			turnin = "Talvash del Kissel, Ironforge",
			endMap = { mapID = 1455, x = 0.357, y = 0.04, label = "Talvash del Kissel" },
		},
		-- Lore for a Price: pickup, startMap, turnin, endMap (Questie, FDJ, foreverchanges, AAL)
		[2199] = {
			pickup = "Talvash del Kissel, Ironforge",
			startMap = { mapID = 1455, x = 0.357, y = 0.04, label = "Talvash del Kissel" },
			turnin = "Talvash del Kissel, Ironforge",
			endMap = { mapID = 1455, x = 0.357, y = 0.04, label = "Talvash del Kissel" },
		},
		-- Back to Uldaman: prerequisites (Questie, foreverchanges)
		[2200] = {
			prerequisites = { { questID = 2198, name = "The Shattered Necklace" }, { questID = 2199, name = "Lore for a Price" } },
		},
		-- Find the Gems: pickup, prerequisites (Questie, foreverchanges, AAL)
		[2201] = {
			pickup = "Remains of a Paladin, inside Uldaman",
			prerequisites = {
				{ questID = 2198, name = "The Shattered Necklace" },
				{ questID = 2199, name = "Lore for a Price" },
				{ questID = 2200, name = "Back to Uldaman" },
			},
		},
		-- Uldaman Reagent Run: prerequisites (Questie, foreverchanges)
		[2202] = {
			prerequisites = { { questID = 2258, name = "Badlands Reagent Run" } },
		},
		-- Restoring the Necklace: pickup, turnin, endMap, prerequisites (Questie, FDJ, foreverchanges, AAL)
		[2204] = {
			pickup = "Talvash's Scrying Bowl, inside the dungeon",
			turnin = "Talvash del Kissel, Ironforge",
			endMap = { mapID = 1455, x = 0.357, y = 0.04, label = "Talvash del Kissel" },
			prerequisites = {
				{ questID = 2198, name = "The Shattered Necklace" },
				{ questID = 2199, name = "Lore for a Price" },
				{ questID = 2200, name = "Back to Uldaman" },
				{ questID = 2201, name = "Find the Gems" },
			},
		},
		-- The Hidden Chamber: pickup, turnin, endMap, prerequisites (Questie, foreverchanges, AAL)
		[2240] = {
			pickup = "Baelog, inside Uldaman",
			turnin = "Prospector Stormpike, Ironforge",
			endMap = { mapID = 1455, x = 0.746, y = 0.117, label = "Prospector Stormpike" },
			prerequisites = {},
		},
		-- The Platinum Discs: pickup, turnin, endMap, prerequisites (Questie, foreverchanges)
		[2279] = {
			pickup = "The Discs of Norgannon, inside Uldaman",
			turnin = "High Explorer Magellas, Hall of Explorers, Ironforge",
			endMap = { mapID = 1455, x = 0.696, y = 0.186, label = "High Explorer Magellas" },
			prerequisites = { { questID = 2278, name = "The Platinum Discs" } },
		},
		-- The Platinum Discs: pickup, prerequisites (Questie, foreverchanges)
		[2280] = {
			pickup = "The Discs of Norgannon, inside Uldaman",
			prerequisites = { { questID = 2278, name = "The Platinum Discs" } },
		},
		-- Translating the Journal: prerequisites (Questie, foreverchanges)
		[2318] = {
			prerequisites = { { questID = 2283, name = "Necklace Recovery" }, { questID = 2284, name = "Necklace Recovery, Take 2" } },
		},
		-- Translating the Journal: prerequisites (Questie, foreverchanges)
		[2338] = {
			prerequisites = {
				{ questID = 2283, name = "Necklace Recovery" },
				{ questID = 2284, name = "Necklace Recovery, Take 2" },
				{ questID = 2318, name = "Translating the Journal" },
			},
		},
		-- Find the Gems and Power Source: prerequisites (Questie, foreverchanges)
		[2339] = {
			prerequisites = {
				{ questID = 2283, name = "Necklace Recovery" },
				{ questID = 2284, name = "Necklace Recovery, Take 2" },
				{ questID = 2318, name = "Translating the Journal" },
				{ questID = 2338, name = "Translating the Journal" },
			},
		},
		-- Deliver the Gems: prerequisites (Questie, foreverchanges)
		[2340] = {
			prerequisites = {
				{ questID = 2283, name = "Necklace Recovery" },
				{ questID = 2284, name = "Necklace Recovery, Take 2" },
				{ questID = 2318, name = "Translating the Journal" },
				{ questID = 2338, name = "Translating the Journal" },
				{ questID = 2339, name = "Find the Gems and Power Source" },
			},
		},
		-- Necklace Recovery, Take 3: prerequisites (Questie, foreverchanges)
		[2341] = {
			prerequisites = {
				{ questID = 2283, name = "Necklace Recovery" },
				{ questID = 2284, name = "Necklace Recovery, Take 2" },
				{ questID = 2318, name = "Translating the Journal" },
				{ questID = 2338, name = "Translating the Journal" },
				{ questID = 2339, name = "Find the Gems and Power Source" },
				{ questID = 2340, name = "Deliver the Gems" },
			},
		},
		-- Restoring the Necklace: pickup, startMap, turnin, endMap, prerequisites (Questie, FDJ, foreverchanges, AAL)
		[2361] = {
			pickup = "Talvash del Kissel, Ironforge",
			startMap = { mapID = 1455, x = 0.357, y = 0.04, label = "Talvash del Kissel" },
			turnin = "Talvash del Kissel, Ironforge",
			endMap = { mapID = 1455, x = 0.357, y = 0.04, label = "Talvash del Kissel" },
			prerequisites = {
				{ questID = 2198, name = "The Shattered Necklace" },
				{ questID = 2199, name = "Lore for a Price" },
				{ questID = 2200, name = "Back to Uldaman" },
				{ questID = 2201, name = "Find the Gems" },
				{ questID = 2204, name = "Restoring the Necklace" },
			},
		},
		-- The Platinum Discs: pickup, startMap, turnin, endMap, prerequisites (Questie, foreverchanges)
		[2439] = {
			pickup = "High Explorer Magellas, Hall of Explorers, Ironforge",
			startMap = { mapID = 1455, x = 0.696, y = 0.186, label = "High Explorer Magellas" },
			turnin = "Dinita Stonemantle, the Vault, Ironforge",
			endMap = { mapID = 1455, x = 0.339, y = 0.592, label = "Dinita Stonemantle" },
			prerequisites = { { questID = 2278, name = "The Platinum Discs" }, { questID = 2279, name = "The Platinum Discs" } },
		},
		-- The Platinum Discs: prerequisites (Questie, foreverchanges)
		[2440] = {
			prerequisites = { { questID = 2278, name = "The Platinum Discs" }, { questID = 2280, name = "The Platinum Discs" } },
		},
		-- Replacement Phial: prerequisites (Questie, foreverchanges)
		[3375] = {
			prerequisites = {
				{ questID = 2198, name = "The Shattered Necklace" },
				{ questID = 2199, name = "Lore for a Price" },
				{ questID = 2200, name = "Back to Uldaman" },
				{ questID = 2201, name = "Find the Gems" },
			},
		},
	},
})

Audit("ZulFarrak", {
	add = {
		-- (The Brassbolts Brothers, 2769, the Alliance's lead-in to Gahz'rilla, was a row here from 2026-11-03 until
		-- the owner's call of 2026-11-07.)
		-- 2026-11-08: Witch Doctor Zum'rah's head, new in Forever, one quest for each side, read by hand from the
		-- quests' own pages (facts only). Their pages name only who takes the head; the givers are the same, as
		-- their text asks for it to be brought to them. Their spots are Forever's quest data's.
		{
			questID = 96770, name = "The Witch Doctor's Head", level = 46, requiredLevel = 39, faction = "Alliance",
			pickup = "Archmage Lan'dalock, Dalaran", turnin = "Archmage Lan'dalock, Dalaran",
			startMap = { mapID = 1416, x = 0.1588, y = 0.7311, label = "Archmage Lan'dalock — Dalaran" },
			endMap = { mapID = 1416, x = 0.1588, y = 0.7311, label = "Archmage Lan'dalock — Dalaran" },
			objective = "Slay Witch Doctor Zum'rah and bring his head to Archmage Lan'dalock in Dalaran.",
			rewards = { money = 13000, reputation = { { faction = "Kirin Tor", amount = 300 } } },
		},
		{
			questID = 96775, name = "Zum'rah's Head", level = 46, requiredLevel = 42, faction = "Horde",
			pickup = "Mazu'kon, Mulgore", turnin = "Mazu'kon, Mulgore",
			startMap = { mapID = 1412, x = 0.324, y = 0.206, label = "Mazu'kon" },
			endMap = { mapID = 1412, x = 0.324, y = 0.206, label = "Mazu'kon" },
			objective = "Slay Witch Doctor Zum'rah and bring his head to Mazu'kon in Mulgore.",
			rewards = { money = 6500, reputation = { { faction = "Earthen Ring", amount = 300 }, { faction = "Darkspear Trolls", amount = 150 } } },
		},
	},
	patches = {
		-- Gahz'rilla: prerequisites (Questie, foreverchanges); its lead-in is a row since 2026-11-03
		[2770] = {
			prerequisites = {},
		},
		-- Tiara of the Deep: prerequisites (Questie, foreverchanges)
		[2846] = {
			prerequisites = {},
		},
		-- Scarab Shells: prerequisites (Questie, foreverchanges)
		[2865] = {
			prerequisites = {},
		},
		-- The Spider God: prerequisites (Questie, foreverchanges)
		[2936] = {
			prerequisites = {
				{ questID = 2933, name = "Venom Bottles" },
				{ questID = 2934, name = "Undamaged Venom Sac" },
				{ questID = 2935, name = "Consult Master Gadrin" },
			},
		},
		-- Nekrum's Medallion: prerequisites (Questie, foreverchanges)
		[2991] = {
			prerequisites = {
				{ questID = 2988, name = "Witherbark Cages" },
				{ questID = 2989, name = "The Altar of Zul" },
				{ questID = 2990, name = "Thadius Grimshade" },
			},
		},
	},
})

-- Word of the Woods, the step before Rot and Regret (below), as a step's page rather than a row: it only sends you
-- to Woodwyrd (the owner's call of 2026-11-07 keeps lead-ins out of the dungeons' lists). Its page names no giver.
ns.AddQuestSteps({
	[93594] = {
		name = "Word of the Woods", level = 43, requiredLevel = 35, faction = "Both",
		objective = "Find Woodwyrd in the Forlorn Gardens at Shen'dralas in Desolace.",
		turnin = "Woodwyrd, the Forlorn Gardens, Desolace",
		note = "Who gives it is not listed yet.",
	},
})

Audit("Maraudon", {
	-- 2026-11-08: Forever's new quests for the dungeon, read by hand from the quests' own pages (facts only): Rot
	-- and Regret, after Word of the Woods (its series), for both sides, its two blues checked in the game's data
	-- (foreverchanges.pro's item pages); An'she's Radiance for the Horde, whose page names no giver or taker. Woodwyrd's
	-- spot is not in Forever's quest data; Woodwyrd gives Rot and Regret, as its text is his.
	add = {
		{
			questID = 93404, name = "Rot and Regret", level = 49, requiredLevel = 35, faction = "Both",
			pickup = "Woodwyrd, the Forlorn Gardens, Desolace", turnin = "Woodwyrd, the Forlorn Gardens, Desolace",
			objective = "Bring a Vial of Earth Song Water from Maraudon to Woodwyrd at the Forlorn Gardens in Desolace, and put out his flame.",
			rewards = {
				choice = true,
				items = {
					{ itemID = 272186, name = "Overgrown Cuffs", quality = 3 },
					{ itemID = 272187, name = "Thornplated Cord", quality = 3 },
				},
			},
			prerequisites = { { questID = 93594, name = "Word of the Woods" } },
		},
		{
			questID = 96776, name = "An'she's Radiance", level = 51, requiredLevel = 43, faction = "Horde",
			objective = "Recover the crystal known as An'she's Radiance from Maraudon.",
			note = "It is the brightest crystal, at the top of the chamber of white crystals past the Earth Song Falls, where giants guard it. It goes back to Mulgore; who gives the quest is not listed yet.",
			rewards = { money = 7500, reputation = { { faction = "Earthen Ring", amount = 300 }, { faction = "Thunder Bluff", amount = 200 } } },
		},
	},
	patches = {
		-- The Scepter of Celebras: pickup (Questie, foreverchanges, AAL)
		[7046] = {
			pickup = "Celebras the Redeemed, inside the dungeon",
		},
		-- Seed of Life: pickup (Questie, foreverchanges)
		[7066] = {
			pickup = "Zaetar's Spirit, inside the dungeon",
		},
	},
})

Audit("TempleOfAtalHakkar", {
	add = {
		-- The Sunken Temple (Questie, foreverchanges)
		{ questID = 3445, name = "The Sunken Temple", level = 51, requiredLevel = 46, faction = "Alliance", pickup = "Angelas Moonbreeze, Feathermoon Stronghold, Feralas", turnin = "Marvon Rivetseeker, Tanaris", startMap = { mapID = 1444, x = 0.318, y = 0.456, label = "Angelas Moonbreeze" }, endMap = { mapID = 1446, x = 0.527, y = 0.459, label = "Marvon Rivetseeker" }, objective = "Find Marvon Rivetseeker in Tanaris.", rewards = { xp = 3650 } },
		-- Haze of Evil (Questie)
		{ questID = 4143, name = "Haze of Evil", level = 52, requiredLevel = 47, faction = "Alliance", pickup = "Gregan Brewspewer, Feralas", turnin = "Muigin, Marshal's Refuge, Un'Goro Crater", startMap = { mapID = 1444, x = 0.451, y = 0.256, label = "Gregan Brewspewer" }, endMap = { mapID = 1449, x = 0.429, y = 0.096, label = "Muigin" }, objective = "Collect 5 samples of Atal'ai Haze from the Deep Lurkers, Murk Worms and Saturated Oozes of the Sunken Temple, then return to Muigin in Un'Goro Crater.", prerequisites = { { questID = 4141, name = "Muigin and Larion" }, { questID = 4142, name = "A Visit to Gregan" } }, rewards = { xp = 5100 } },
		-- A Better Ingredient (Questie)
		{ questID = 9053, name = "A Better Ingredient", level = 52, requiredLevel = 50, faction = "Both", classOnly = "DRUID", pickup = "Torwa Pathfinder, Un'Goro Crater", turnin = "Torwa Pathfinder, Un'Goro Crater", startMap = { mapID = 1449, x = 0.716, y = 0.760, label = "Torwa Pathfinder" }, endMap = { mapID = 1449, x = 0.716, y = 0.760, label = "Torwa Pathfinder" }, objective = "Bring Torwa Pathfinder a Putrid Vine from Atal'alarion, the guardian at the bottom of the Sunken Temple.", prerequisites = { { questID = 9052, name = "Bloodpetal Poison" }, { questID = 9051, name = "Toxic Test" } } },
	},
	patches = {
		-- The Temple of Atal'Hakkar: prerequisites (Questie, foreverchanges)
		[1445] = {
			prerequisites = {
				{ questID = 1424, name = "Pool of Tears" },
				{ questID = 1429, name = "The Atal'ai Exile" },
				{ questID = 1444, name = "Return to Fel'Zerul" },
			},
		},
		-- Into The Temple of Atal'Hakkar: prerequisites (Questie, foreverchanges)
		[1475] = {
			prerequisites = {
				{ questID = 1448, name = "In Search of The Temple" },
				{ questID = 1449, name = "To The Hinterlands" },
				{ questID = 1450, name = "Gryphon Master Talonaxe" },
				{ questID = 1451, name = "Rhapsody Shindigger" },
				{ questID = 1452, name = "Rhapsody's Kalimdor Kocktail" },
				{ questID = 1469, name = "Rhapsody's Tale" },
			},
		},
		-- The Essence of Eranikus: pickup, startItem, prerequisites (Questie, foreverchanges, AAL)
		[3373] = {
			pickup = "Essence of Eranikus, dropped by the Shade of Eranikus inside the dungeon",
			startItem = { itemID = 10454, name = "Essence of Eranikus", note = "Dropped by the Shade of Eranikus" },
			prerequisites = {},
		},
		-- The God Hakkar: prerequisites (Questie, foreverchanges)
		[3528] = {
			prerequisites = {
				{ questID = 3520, name = "Screecher Spirits" },
				{ questID = 3527, name = "The Prophecy of Mosh'aru" },
				{ questID = 4787, name = "The Ancient Egg" },
			},
		},
		-- Zapper Fuel: prerequisites (Questie, foreverchanges)
		[4146] = {
			prerequisites = { { questID = 4145, name = "Larion and Muigin" }, { questID = 4147, name = "Marvon's Workshop" } },
		},
		-- Bloodpetal Zapper: prerequisites (Questie, foreverchanges)
		[4148] = {
			prerequisites = {
				{ questID = 4145, name = "Larion and Muigin" },
				{ questID = 4147, name = "Marvon's Workshop" },
				{ questID = 4146, name = "Zapper Fuel" },
			},
		},
		-- The Green Drake: prerequisites (Questie, foreverchanges)
		[8232] = {
			prerequisites = {
				{ questID = 8151, name = "The Hunter's Charm" },
				{ questID = 8153, name = "Courser Antlers" },
				{ questID = 8231, name = "Wavethrashing" },
			},
		},
		-- The Azure Key: prerequisites (Questie, foreverchanges)
		[8236] = {
			prerequisites = { { questID = 8234, name = "Sealed Azure Bag" }, { questID = 8235, name = "Encoded Fragments" } },
		},
		-- Destroy Morphaz: prerequisites (Questie, foreverchanges)
		[8253] = {
			prerequisites = { { questID = 8251, name = "Magic Dust" }, { questID = 8252, name = "The Siren's Coral" } },
		},
		-- Blood of Morphaz: prerequisites (Questie, foreverchanges)
		[8257] = {
			prerequisites = {
				{ questID = 8254, name = "Cenarion Aid" },
				{ questID = 8255, name = "Of Coursers We Know" },
				{ questID = 8256, name = "The Ichor of Undeath" },
			},
		},
		-- Da Voodoo: prerequisites (Questie, foreverchanges). Spirit Totem opens after either one of
		-- its two lead-ins (QuestieDB's preQuestSingle), a step of its own now, not a note (the deep
		-- audit of 2026-10-30, T2).
		[8413] = {
			prerequisites = {
				ns.OneOf("Elemental Mastery", { questID = 8410, faction = "Horde", classOnly = "SHAMAN" },
					{ questID = 8411, name = "Mastering the Elements", faction = "Horde", classOnly = "SHAMAN" }),
				{ questID = 8412, name = "Spirit Totem" },
			},
		},
		-- Forging the Mightstone: prerequisites (Questie, foreverchanges)
		[8418] = {
			prerequisites = { { questID = 8414, name = "Dispelling Evil" }, { questID = 8416, name = "Inert Scourgestones" } },
		},
		-- Trolls of a Feather: prerequisites (Questie, foreverchanges). The Wrong Stuff opens after either
		-- one of its two lead-ins, as Da Voodoo's Spirit Totem does (T2).
		[8422] = {
			prerequisites = {
				ns.OneOf("An Imp's Request", { questID = 8419, classOnly = "WARLOCK" },
					{ questID = 8420, name = "Hot and Itchy", classOnly = "WARLOCK" }),
				{ questID = 8421, name = "The Wrong Stuff" },
			},
		},
		-- Voodoo Feathers: prerequisites (Questie, foreverchanges)
		[8425] = {
			prerequisites = { { questID = 8423, name = "Warrior Kinship" }, { questID = 8424, name = "War on the Shadowsworn" } },
		},
		-- Eranikus, Tyrant of the Dream: prerequisites (Questie, foreverchanges)
		[8733] = {
			prerequisites = {
				{ questID = 8286, name = "What Tomorrow Brings" },
				{ questID = 8288, name = "Only One May Rise" },
				{ questID = 8301, name = "The Path of the Righteous" },
				{ questID = 8303, name = "Anachronos" },
				{ questID = 8305, name = "Long Forgotten Memories" },
				{ questID = 8519, name = "A Pawn on the Eternal Board" },
				{ questID = 8555, name = "The Charge of the Dragonflights" },
			},
		},
	},
})

Audit("BlackrockDepths", {
	add = {
		-- Fragment of the Firelands: new in Forever, for the Horde, read by hand from its page (facts only); Alaana
		-- Stormwalker gives it, as its text is hers, and her spot is Forever's quest data's (2026-11-08).
		{
			questID = 97197, name = "Fragment of the Firelands", level = 55, requiredLevel = 46, faction = "Horde",
			pickup = "Alaana Stormwalker, Mulgore", turnin = "Alaana Stormwalker, Mulgore",
			startMap = { mapID = 1412, x = 0.334, y = 0.225, label = "Alaana Stormwalker" },
			endMap = { mapID = 1412, x = 0.334, y = 0.225, label = "Alaana Stormwalker" },
			objective = "Recover a Fragment of the Firelands from Blackrock Depths for Alaana Stormwalker in Mulgore.",
			note = "It comes from one of the elementals of the Firelands that slip through deep in the Depths.",
			rewards = { money = 8500, reputation = { { faction = "Earthen Ring", amount = 300 } } },
		},
		-- Attunement to the Core (Questie)
		{
			questID = 7848, name = "Attunement to the Core", level = 60, requiredLevel = 55, faction = "Both",
			pickup = "Lothos Riftwaker, Blackrock Mountain",
			turnin = "Lothos Riftwaker, Blackrock Mountain",
			startMap = { mapID = 1427, x = 0.321, y = 0.947, label = "Lothos Riftwaker" },
			endMap = { mapID = 1427, x = 0.321, y = 0.947, label = "Lothos Riftwaker" },
			objective = "Recover a Core Fragment at the Molten Core entry portal inside Blackrock Depths, then go back to Lothos Riftwaker.",
			rewards = { xp = 6600 },
		},
	},
	patches = {
		-- What Is Going On?: prerequisites (Questie, foreverchanges)
		[3982] = {
			prerequisites = { { questID = 3906, name = "Disharmony of Flame" }, { questID = 3981, name = "Commander Gor'shak" } },
		},
		-- What Is Going On?: prerequisites (Questie, foreverchanges)
		[4001] = {
			prerequisites = {
				{ questID = 3906, name = "Disharmony of Flame" },
				{ questID = 3981, name = "Commander Gor'shak" },
				{ questID = 3982, name = "What Is Going On?" },
			},
		},
		-- The Eastern Kingdoms: name, prerequisites (Questie, foreverchanges)
		[4002] = {
			name = "The Eastern Kingdom",
			prerequisites = {
				{ questID = 3906, name = "Disharmony of Flame" },
				{ questID = 3981, name = "Commander Gor'shak" },
				{ questID = 3982, name = "What Is Going On?" },
				{ questID = 4001, name = "What Is Going On?" },
			},
		},
		-- The Royal Rescue: faction, prerequisites (Questie, foreverchanges, AAL)
		[4003] = {
			faction = "Horde",
			prerequisites = {
				{ questID = 3906, name = "Disharmony of Flame" },
				{ questID = 3981, name = "Commander Gor'shak" },
				{ questID = 3982, name = "What Is Going On?" },
				{ questID = 4001, name = "What Is Going On?" },
				{ questID = 4002, name = "The Eastern Kingdom" },
			},
		},
		-- The Princess Saved?: faction, pickup, prerequisites (Questie, foreverchanges, AAL)
		[4004] = {
			faction = "Horde",
			pickup = "Princess Moira Bronzebeard, inside the dungeon",
			prerequisites = {
				{ questID = 3906, name = "Disharmony of Flame" },
				{ questID = 3981, name = "Commander Gor'shak" },
				{ questID = 3982, name = "What Is Going On?" },
				{ questID = 4001, name = "What Is Going On?" },
				{ questID = 4002, name = "The Eastern Kingdom" },
				{ questID = 4003, name = "The Royal Rescue" },
			},
		},
		-- The Rise of the Machines: prerequisites (Questie, foreverchanges)
		[4063] = {
			prerequisites = { { questID = 4061, name = "The Rise of the Machines" }, { questID = 4062, name = "The Rise of the Machines" } },
		},
		-- The Spectral Chalice: pickup, startObject (Questie, foreverchanges)
		[4083] = {
			pickup = "Spectral Chalice, inside the dungeon",
			startObject = { name = "Spectral Chalice", note = "Inside the dungeon; needs Mining 230." },
		},
		-- Precarious Predicament: prerequisites (Questie, foreverchanges)
		[4121] = {
			prerequisites = {
				{ questID = 4081, name = "KILL ON SIGHT: Dark Iron Dwarves" },
				{ questID = 4082, name = "KILL ON SIGHT: High Ranking Dark Iron Officials" },
				{ questID = 4122, name = "Grark Lorkrub" },
			},
		},
		-- Grark Lorkrub: prerequisites (Questie, foreverchanges)
		[4122] = {
			prerequisites = { { questID = 4081, name = "KILL ON SIGHT: Dark Iron Dwarves" }, { questID = 4082, name = "KILL ON SIGHT: High Ranking Dark Iron Officials" } },
		},
		-- Hurley Blackbreath: prerequisites (Questie, foreverchanges)
		[4126] = {
			prerequisites = {},
		},
		-- Operation: Death to Angerforge: prerequisites (Questie, foreverchanges)
		[4132] = {
			prerequisites = {
				{ questID = 4081, name = "KILL ON SIGHT: Dark Iron Dwarves" },
				{ questID = 4082, name = "KILL ON SIGHT: High Ranking Dark Iron Officials" },
				{ questID = 4122, name = "Grark Lorkrub" },
				{ questID = 4121, name = "Precarious Predicament" },
			},
		},
		-- Lost Thunderbrew Recipe: prerequisites (Questie, foreverchanges)
		[4134] = {
			prerequisites = {},
		},
		-- Ribbly Screwspigot: prerequisites (Questie, foreverchanges)
		[4136] = {
			prerequisites = {},
		},
		-- The Love Potion: pickup (Questie, foreverchanges, AAL)
		[4201] = {
			pickup = "Mistress Nagmara, inside the dungeon",
		},
		-- Marshal Windsor: prerequisites (Questie, foreverchanges)
		[4241] = {
			prerequisites = {
				{ questID = 4182, name = "Dragonkin Menace" },
				{ questID = 4183, name = "The True Masters" },
				{ questID = 4184, name = "The True Masters" },
				{ questID = 4185, name = "The True Masters" },
				{ questID = 4186, name = "The True Masters" },
				{ questID = 4223, name = "The True Masters" },
				{ questID = 4224, name = "The True Masters" },
			},
		},
		-- Abandoned Hope: pickup, prerequisites (Questie, foreverchanges, AAL)
		[4242] = {
			pickup = "Marshal Windsor, inside the dungeon",
			prerequisites = {
				{ questID = 4182, name = "Dragonkin Menace" },
				{ questID = 4183, name = "The True Masters" },
				{ questID = 4184, name = "The True Masters" },
				{ questID = 4185, name = "The True Masters" },
				{ questID = 4186, name = "The True Masters" },
				{ questID = 4223, name = "The True Masters" },
				{ questID = 4224, name = "The True Masters" },
				{ questID = 4241, name = "Marshal Windsor" },
			},
		},
		-- A Crumpled Up Note: pickup, startItem, prerequisites (Questie, foreverchanges)
		[4264] = {
			pickup = "A Crumpled Up Note, dropped by foes inside the dungeon",
			startItem = { itemID = 11446, name = "A Crumpled Up Note", note = "Drops from foes all over Blackrock Depths." },
			prerequisites = {
				{ questID = 4182, name = "Dragonkin Menace" },
				{ questID = 4183, name = "The True Masters" },
				{ questID = 4184, name = "The True Masters" },
				{ questID = 4185, name = "The True Masters" },
				{ questID = 4186, name = "The True Masters" },
				{ questID = 4223, name = "The True Masters" },
				{ questID = 4224, name = "The True Masters" },
				{ questID = 4241, name = "Marshal Windsor" },
				{ questID = 4242, name = "Abandoned Hope" },
			},
		},
		-- A Shred of Hope: pickup, prerequisites (Questie, foreverchanges, AAL)
		[4282] = {
			pickup = "Marshal Windsor, inside the dungeon",
			prerequisites = {
				{ questID = 4182, name = "Dragonkin Menace" },
				{ questID = 4183, name = "The True Masters" },
				{ questID = 4184, name = "The True Masters" },
				{ questID = 4185, name = "The True Masters" },
				{ questID = 4186, name = "The True Masters" },
				{ questID = 4223, name = "The True Masters" },
				{ questID = 4224, name = "The True Masters" },
				{ questID = 4241, name = "Marshal Windsor" },
				{ questID = 4242, name = "Abandoned Hope" },
				{ questID = 4264, name = "A Crumpled Up Note" },
			},
		},
		-- Jail Break!: pickup, prerequisites (Questie, foreverchanges, AAL)
		[4322] = {
			pickup = "Marshal Windsor, inside the dungeon",
			prerequisites = {
				{ questID = 4182, name = "Dragonkin Menace" },
				{ questID = 4183, name = "The True Masters" },
				{ questID = 4184, name = "The True Masters" },
				{ questID = 4185, name = "The True Masters" },
				{ questID = 4186, name = "The True Masters" },
				{ questID = 4223, name = "The True Masters" },
				{ questID = 4224, name = "The True Masters" },
				{ questID = 4241, name = "Marshal Windsor" },
				{ questID = 4242, name = "Abandoned Hope" },
				{ questID = 4264, name = "A Crumpled Up Note" },
				{ questID = 4282, name = "A Shred of Hope" },
			},
		},
		-- Kharan Mighthammer: prerequisites (Questie, foreverchanges)
		[4341] = {
			prerequisites = { { questID = 3702, name = "The Smoldering Ruins of Thaurissan" }, { questID = 3701, name = "The Smoldering Ruins of Thaurissan" } },
		},
		-- Kharan's Tale: prerequisites (Questie, foreverchanges)
		[4342] = {
			prerequisites = {
				{ questID = 3702, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 3701, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 4341, name = "Kharan Mighthammer" },
			},
		},
		-- The Bearer of Bad News: prerequisites (Questie, foreverchanges)
		[4361] = {
			prerequisites = {
				{ questID = 3702, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 3701, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 4341, name = "Kharan Mighthammer" },
				{ questID = 4342, name = "Kharan's Tale" },
			},
		},
		-- The Fate of the Kingdom: pickup, startMap, prerequisites (Questie, foreverchanges, AAL)
		[4362] = {
			pickup = "King Magni Bronzebeard, Ironforge",
			startMap = { mapID = 1455, x = 0.391, y = 0.562, label = "King Magni Bronzebeard" },
			prerequisites = {
				{ questID = 3702, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 3701, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 4341, name = "Kharan Mighthammer" },
				{ questID = 4342, name = "Kharan's Tale" },
				{ questID = 4361, name = "The Bearer of Bad News" },
			},
		},
		-- The Princess's Surprise: pickup, turnin, endMap, prerequisites (Questie, foreverchanges, AAL)
		[4363] = {
			pickup = "Princess Moira Bronzebeard, inside the dungeon",
			turnin = "King Magni Bronzebeard, Ironforge",
			endMap = { mapID = 1455, x = 0.391, y = 0.562, label = "King Magni Bronzebeard" },
			prerequisites = {
				{ questID = 3702, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 3701, name = "The Smoldering Ruins of Thaurissan" },
				{ questID = 4341, name = "Kharan Mighthammer" },
				{ questID = 4342, name = "Kharan's Tale" },
				{ questID = 4361, name = "The Bearer of Bad News" },
				{ questID = 4362, name = "The Fate of the Kingdom" },
			},
		},
		-- The Last Element: prerequisites (Questie, foreverchanges)
		[7201] = {
			prerequisites = { { questID = 3906, name = "Disharmony of Flame" } },
		},
		-- A Binding Contract: pickup, startItem (Questie, foreverchanges, AAL)
		[7604] = {
			pickup = "Thorium Brotherhood Contract, from Lokhtos Darkbargainer inside the dungeon",
			startItem = { itemID = 18628, name = "Thorium Brotherhood Contract", note = "Given by Lokhtos Darkbargainer, inside the dungeon." },
		},
		-- The Challenge: pickup, prerequisites (Questie, foreverchanges). The chain from its start, as
		-- every other copy has it (the deep audit of 2026-10-30, g10-17); its side steps are laid in by
		-- Data/Authored/BlackrockSpire.lua.
		[9015] = {
			pickup = "Falrin Treeshaper, the library, inside Dire Maul",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
			},
		},
	},
	remove = {
		3911, -- The Last Element: not on Forever: an old duplicate the game never offers
	},
})

Audit("DireMaulEast", {
	add = {
		-- The Prison's Bindings (Questie)
		{
			questID = 7581, name = "The Prison's Bindings", level = 60, requiredLevel = 60, faction = "Both", classOnly = "WARLOCK",
			pickup = "Daio the Decrepit, The Tainted Scar, Blasted Lands", turnin = "Daio the Decrepit, The Tainted Scar, Blasted Lands",
			startMap = { mapID = 1419, x = 0.341, y = 0.501, label = "Daio the Decrepit" },
			endMap = { mapID = 1419, x = 0.341, y = 0.501, label = "Daio the Decrepit" },
			objective = "Bring Daio 15 Satyr Blood from the Wildspawn satyrs of the Warpwood Quarter.",
			note = "Taken with The Prison's Casing; both lead to Suppression.",
			rewards = { xp = 6600 },
		},
		-- Unfinished Gordok Business (Questie, foreverchanges)
		{
			questID = 7703, name = "Unfinished Gordok Business", level = 60, requiredLevel = 56, faction = "Both",
			pickup = "Captain Kromcrush, inside Dire Maul", turnin = "Captain Kromcrush, inside Dire Maul",
			objective = "Find the Gauntlet of Gordok Might and return it to Captain Kromcrush in Dire Maul.",
			note = "The gauntlet is in The Prince's Chest, in Prince Tortheldrin's wing.",
			rewards = {
				choice = true,
				items = {
					{ itemID = 18366, name = "Gordok's Handguards" },
					{ itemID = 18367, name = "Gordok's Gauntlets" },
					{ itemID = 18368, name = "Gordok's Gloves" },
					{ itemID = 18369, name = "Gordok's Handwraps" },
				},
			},
		},
	},
	patches = {
		-- Arcane Refreshment: classOnly, pickup (Questie, foreverchanges, AAL); its spell (foreverchanges'
		-- quest page: "You will learn: Conjure Water"; the deep audit of 2026-10-30, g07-19)
		[7463] = {
			classOnly = "MAGE",
			pickup = "Lorekeeper Lydros, inside Dire Maul",
			note = "Teaches Conjure Water.",
		},
		-- Elven Legends: objective (Questie)
		[7481] = {
			objective = "Look in Dire Maul for Telmius Dreamseeker and report back to Sage Korolusk.",
		},
		-- Elven Legends: objective (Questie)
		[7482] = {
			objective = "Look in Dire Maul for Telmius Dreamseeker and report back to Scholar Runethorn.",
		},
		-- The Libram quests (7483-7485): their Elven Legends step, in every wing, is laid on in
		-- Data/Authored/DireMaul.lua; their note is FromForeverChanges.lua's (the deep audit of
		-- 2026-10-30, g07-02).
		-- Lethtendris's Web: prerequisites (Questie, foreverchanges)
		[7488] = {
			prerequisites = {},
		},
		-- Garona: A Study on Stealth and Treachery: classOnly, startItem (Questie, foreverchanges, AAL)
		[7498] = {
			classOnly = "ROGUE",
			startItem = { itemID = 18356, name = "Garona: A Study on Stealth and Treachery", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- Codex of Defense: classOnly, startItem (Questie, foreverchanges, AAL)
		[7499] = {
			classOnly = "WARRIOR",
			startItem = { itemID = 18357, name = "Codex of Defense", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- The Arcanist's Cookbook: classOnly, startItem (Questie, foreverchanges, AAL)
		[7500] = {
			classOnly = "MAGE",
			startItem = { itemID = 18358, name = "The Arcanist's Cookbook", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- The Light and How To Swing It: classOnly, startItem (Questie, foreverchanges, AAL)
		[7501] = {
			classOnly = "PALADIN",
			startItem = { itemID = 18359, name = "The Light and How to Swing It", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- Harnessing Shadows: classOnly, startItem (Questie, foreverchanges, AAL)
		[7502] = {
			classOnly = "WARLOCK",
			startItem = { itemID = 18360, name = "Harnessing Shadows", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- The Greatest Race of Hunters: classOnly, startItem (Questie, foreverchanges, AAL)
		[7503] = {
			classOnly = "HUNTER",
			startItem = { itemID = 18361, name = "The Greatest Race of Hunters", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- Holy Bologna: What the Light Won't Tell You: classOnly, startItem (Questie, foreverchanges, AAL)
		[7504] = {
			classOnly = "PRIEST",
			startItem = { itemID = 18362, name = "Holy Bologna: What the Light Won't Tell You", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- Frost Shock and You: classOnly, startItem (Questie, foreverchanges, AAL)
		[7505] = {
			classOnly = "SHAMAN",
			startItem = { itemID = 18363, name = "Frost Shock and You", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- The Emerald Dream...: classOnly, startItem (Questie, foreverchanges, AAL)
		[7506] = {
			classOnly = "DRUID",
			startItem = { itemID = 18364, name = "The Emerald Dream", note = "From A Dusty Tome inside Dire Maul." },
		},
		-- Foror's Compendium: name, startItem, objective, note (Questie, foreverchanges)
		[7507] = {
			name = "Nostro's Compendium",
			startItem = { itemID = 18401, name = "Nostro's Compendium of Dragon Slaying", note = "From A Dusty Tome inside Dire Maul." },
			objective = "Return Nostro's Compendium of Dragon Slaying to the Athenaeum.",
			note = "For warriors and paladins.",
		},
		-- The Forging of Quel'Serrar: startItem, note, prerequisites (Questie, foreverchanges)
		[7508] = {
			startItem = { itemID = 18513, name = "A Dull and Flat Elven Blade" },
			note = "For warriors and paladins.",
			prerequisites = { { questID = 7507, name = "Nostro's Compendium" } },
		},
		-- The Forging of Quel'Serrar: pickup, note, prerequisites (Questie, foreverchanges)
		[7509] = {
			pickup = "Lorekeeper Lydros, inside Dire Maul",
			note = "For warriors and paladins.",
			prerequisites = { { questID = 7507, name = "Nostro's Compendium" }, { questID = 7508, name = "The Forging of Quel'Serrar" } },
		},
		-- The Treasure of the Shen'dralar: faction, prerequisites (Questie, foreverchanges)
		[7877] = {
			faction = "Both",
			prerequisites = { { questID = 7461, name = "The Madness Within" } },
		},
		-- Anthion's Old Friend: prerequisites (Questie, foreverchanges)
		[8948] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
			},
		},
		-- Falrin's Vendetta: pickup, prerequisites (Questie, foreverchanges, AAL)
		[8949] = {
			pickup = "Falrin Treeshaper, inside Dire Maul",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
			},
		},
		-- The Instigator's Enchantment: pickup, prerequisites (Questie, foreverchanges, AAL)
		[8950] = {
			pickup = "Falrin Treeshaper, inside Dire Maul",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
			},
		},
		-- The Left Piece of Lord Valthalak's Amulet: prerequisites (Questie, foreverchanges)
		[8967] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
			},
		},
		-- The Right Piece of Lord Valthalak's Amulet: prerequisites (Questie, foreverchanges)
		[8990] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
			},
		},
	},
	remove = {
		1318, -- Unfinished Gordok Business: a duplicate of Unfinished Gordok Business (7703), not in the game
		7462, -- The Treasure of the Shen'dralar: a duplicate of The Treasure of the Shen'dralar (7877), which both sides take
	},
})

Audit("LowerBlackrockSpire", {
	add = {
		-- Hot Fiery Death (Wowhead)
		{
			questID = 5103, name = "Hot Fiery Death", level = 60, requiredLevel = 55, faction = "Both",
			pickup = "Human Remains, inside the dungeon", turnin = "Malyfous Darkhammer, Winterspring",
			endMap = { mapID = 1452, x = 0.610, y = 0.388, label = "Malyfous Darkhammer" },
			startObject = { name = "Human Remains", note = "Inside the dungeon." },
			objective = "Take the Unfired Plate Gauntlets lying by the Human Remains to Malyfous Darkhammer in Everlook.",
			-- No class limit: QuestieDB's requiredClasses is 0 and the site's page names no class (the deep audit of
			-- 2026-10-30, g06-3). Its follow-up, Fiery Plate Gauntlets (5124), is done in Everlook.
			note = "For blacksmiths with a skill of 270. The remains and the gauntlets are by a lava flow, down a tunnel behind the orc tents at the start of the long orc hall before the spiders. "
				.. "Malyfous then offers Fiery Plate Gauntlets, which gives the gauntlets and their plans.",
			prerequisites = {},
			rewards = { xp = 6600 },
		},
		-- Final Preparations (Questie, foreverchanges)
		{
			questID = 8994, name = "Final Preparations", level = 60, requiredLevel = 58, faction = "Both",
			pickup = "Bodley, Blackrock Mountain",
			turnin = "Bodley, Blackrock Mountain",
			startMap = { mapID = 1428, x = 0.323, y = 0.258 }, endMap = { mapID = 1428, x = 0.323, y = 0.258 },
			objective = "Bring Bodley 40 Blackrock Bracers, taken from the orcs of Blackrock Spire, and a Flask of Supreme Power.",
			note = "Offered once one of the four Right Piece of Lord Valthalak's Amulet quests is done.",
			prerequisites = { { questID = 8921, name = "The Ectoplasmic Distiller" }, { questID = 8924, name = "Hunting for Ectoplasm" }, { questID = 8925, name = "A Portable Power Source" }, { questID = 8928, name = "A Shifty Merchant" }, { questID = 8945, name = "Dead Man's Plea" }, { questID = 8946, name = "Proof of Life" }, { questID = 8947, name = "Anthion's Strange Request" }, { questID = 8948, name = "Anthion's Old Friend" }, { questID = 8949, name = "Falrin's Vendetta" }, { questID = 8950, name = "The Instigator's Enchantment" }, { questID = 9015, name = "The Challenge" }, { questID = 8961, name = "Three Kings of Flame" }, { questID = 8970, name = "I See Alcaz Island In Your Future..." } },
			rewards = { xp = 6600 },
		},
	},
	patches = {
		-- Seal of Ascension: pickup, turnin, prerequisites (Questie, foreverchanges, Wowhead)
		[4742] = {
			pickup = "Scarshield Infiltrator, inside the dungeon",
			turnin = "Scarshield Infiltrator, inside the dungeon",
			prerequisites = {},
		},
		-- Seal of Ascension: pickup, turnin (Questie, foreverchanges, Wowhead)
		[4743] = {
			pickup = "Scarshield Infiltrator, inside the dungeon",
			turnin = "Scarshield Infiltrator, inside the dungeon",
		},
		-- Doomrigger's Clasp: prerequisites (Questie, foreverchanges)
		[4764] = {
			prerequisites = {},
		},
		-- The Final Tablets: prerequisites (Questie, foreverchanges)
		[4788] = {
			prerequisites = {
				{ questID = 3520, name = "Screecher Spirits" },
				{ questID = 3527, name = "The Prophecy of Mosh'aru" },
				{ questID = 4787, name = "The Ancient Egg" },
				{ questID = 3528, name = "The God Hakkar" },
				{ questID = 5065, name = "The Lost Tablets of Mosh'aru" },
			},
		},
		-- Urok Doomhowl: pickup (Questie, foreverchanges)
		[4867] = {
			pickup = "Warosh, inside the dungeon",
		},
		-- Warlord's Command: pickup, startMap (Questie, foreverchanges, AAL)
		[4903] = {
			pickup = "Warlord Goretooth, Badlands",
			startMap = { mapID = 1418, x = 0.058, y = 0.475, label = "Warlord Goretooth" },
		},
		-- Bijou's Belongings: prerequisites (Questie, foreverchanges)
		[4982] = {
			prerequisites = { { questID = 4981, name = "Operative Bijou" } },
		},
		-- Bijou's Reconnaissance Report: pickup, prerequisites (Questie, foreverchanges)
		[4983] = {
			pickup = "Bijou, inside the dungeon",
			prerequisites = { { questID = 4981, name = "Operative Bijou" }, { questID = 4982, name = "Bijou's Belongings" } },
		},
		-- Bijou's Belongings: pickup (Questie, foreverchanges)
		[5001] = {
			pickup = "Bijou, inside the dungeon",
		},
		-- Message to Maxwell: pickup (Questie, foreverchanges)
		[5002] = {
			pickup = "Bijou, inside the dungeon",
		},
		-- Maxwell's Mission: prerequisites (Questie, foreverchanges)
		[5081] = {
			prerequisites = { { questID = 5001, name = "Bijou's Belongings" }, { questID = 5002, name = "Message to Maxwell" } },
		},
		-- General Drakkisath's Command: pickup, startItem (Questie, foreverchanges)
		[5089] = {
			pickup = "General Drakkisath's Command, dropped by Overlord Wyrmthalak inside Lower Blackrock Spire",
			startItem = { itemID = 12780, name = "General Drakkisath's Command", note = "Dropped by Overlord Wyrmthalak." },
		},
		-- The Matron Protectorate: pickup (Questie, foreverchanges)
		[5160] = {
			pickup = "Awbee, inside the dungeon",
		},
		-- Oculus Illusions: prerequisites (Questie, foreverchanges)
		[6569] = {
			prerequisites = {
				{ questID = 4903, name = "Warlord's Command" },
				{ questID = 4941, name = "Eitrigg's Wisdom" },
				{ questID = 4974, name = "For The Horde!" },
				{ questID = 6566, name = "What the Wind Carries" },
				{ questID = 6567, name = "The Champion of the Horde" },
				{ questID = 6568, name = "The Testament of Rexxar" },
			},
		},
		-- Confront Yeh'kinya: prerequisites (Questie, foreverchanges)
		[8181] = {
			prerequisites = {
				{ questID = 3520, name = "Screecher Spirits" },
				{ questID = 3527, name = "The Prophecy of Mosh'aru" },
				{ questID = 4787, name = "The Ancient Egg" },
				{ questID = 3528, name = "The God Hakkar" },
				{ questID = 5065, name = "The Lost Tablets of Mosh'aru" },
				{ questID = 4788, name = "The Final Tablets" },
			},
		},
		-- Mea Culpa, Lord Valthalak: prerequisites (Questie, foreverchanges)
		[8995] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
				{ questID = 8994, name = "Final Preparations" },
			},
		},
		-- Return to Bodley: pickup, prerequisites (Questie, foreverchanges)
		[8996] = {
			pickup = "Spirit of Lord Valthalak, inside the dungeon",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
				{ questID = 8994, name = "Final Preparations" },
				{ questID = 8995, name = "Mea Culpa, Lord Valthalak" },
			},
		},
	},
	remove = {
		4734, -- Egg Freezing: Upper Blackrock Spire's: the eggs are in its Rookery
		4735, -- Egg Collection: Upper Blackrock Spire's: the eggs are in its Rookery
		5047, -- Pip Quickwit, At Your Service! (Finkle Einhorn's in the original game): Upper Blackrock Spire's: it starts after The Beast
		5127, -- The Demon Forge: Upper Blackrock Spire's: Goraluk Anvilcrack is there
		7761, -- Blackhand's Command: Upper Blackrock Spire's: it ends at Drakkisath's Brand
		-- Doomrigger's Clasp and Delivery to Ridgewell: Upper Blackrock Spire's, as their Horde twin The
		-- Darkstone Tablet (4768) and both lead-ins are (the deep audit of 2026-10-30, g06-4: the quest text puts
		-- the clasp high in the Spire, and QuestieDB's raid flag is set on them as on every Upper quest)
		4764,
		4765,
	},
})

Audit("DireMaulWest", {
	add = {
		-- Dreadsteed of Xoroth (Questie)
		{
			questID = 7631, name = "Dreadsteed of Xoroth", level = 60, requiredLevel = 60, faction = "Both", classOnly = "WARLOCK",
			pickup = "Mor'zul Bloodbringer, Burning Steppes", turnin = "Dreadsteed Spirit, inside the dungeon",
			startMap = { mapID = 1428, x = 0.127, y = 0.316, label = "Mor'zul Bloodbringer" },
			objective = "Read Mor'zul's Instructions. Summon a Xorothian Dreadsteed, defeat it, then bind its spirit to you.",
			-- Its spell: foreverchanges' quest page, "You will learn: Summon Dreadsteed" (the deep audit of
			-- 2026-10-30, g07-19)
			note = "The summoning is done in the Prison of Immol'thar. Teaches Summon Dreadsteed.",
			prerequisites = {
				{ questID = 7563, name = "Rage of Blood" },
				{ questID = 7564, name = "Wildeyes" },
				{ questID = 7623, name = "Lord Banehollow" },
				{ questID = 7624, name = "Ulathek the Traitor" },
				{ questID = 7625, name = "Xorothian Stardust" },
				{ questID = 7626, name = "Bell of Dethmoora" },
				{ questID = 7627, name = "Wheel of the Black March" },
				{ questID = 7628, name = "Doomsday Candle" },
				{ questID = 7629, name = "Imp Delivery" },
				{ questID = 7630, name = "Arcanite" },
			},
			rewards = { xp = 6600 },
		},
		-- Ancient Equine Spirit (Questie)
		{
			questID = 7643, name = "Ancient Equine Spirit", level = 60, requiredLevel = 60, faction = "Alliance", classOnly = "PALADIN",
			pickup = "Lord Grayson Shadowbreaker, Stormwind City", turnin = "Ancient Equine Spirit, inside the dungeon",
			startMap = { mapID = 1453, x = 0.484, y = 0.502, label = "Lord Grayson Shadowbreaker" },
			objective = "Get the special horse feed from Merideth Carlson in Southshore, kill Tendris Warpwood in Dire Maul to free the Ancient Equine Spirit, feed it, and give it the Arcanite Barding to bless.",
			prerequisites = {
				{ questID = 7638, name = "Lord Grayson Shadowbreaker" },
				{ questID = 7637, name = "Emphasis on Sacrifice" },
				{ questID = 7639, name = "To Show Due Judgment" },
				{ questID = 7640, name = "Exorcising Terrordale" },
				{ questID = 7641, name = "The Work of Grimand Elmore" },
				{ questID = 7642, name = "Collection of Goods" },
			},
			rewards = { xp = 4950 },
		},
		-- Blessed Arcanite Barding (Questie)
		{
			questID = 7644, name = "Blessed Arcanite Barding", level = 60, requiredLevel = 60, faction = "Alliance", classOnly = "PALADIN",
			pickup = "Ancient Equine Spirit, inside the dungeon", turnin = "Lord Grayson Shadowbreaker, Stormwind City",
			endMap = { mapID = 1453, x = 0.484, y = 0.502, label = "Lord Grayson Shadowbreaker" },
			objective = "Return with the Blessed Arcanite Barding to Lord Grayson Shadowbreaker in the Cathedral District of Stormwind.",
			prerequisites = {
				{ questID = 7638, name = "Lord Grayson Shadowbreaker" },
				{ questID = 7637, name = "Emphasis on Sacrifice" },
				{ questID = 7639, name = "To Show Due Judgment" },
				{ questID = 7640, name = "Exorcising Terrordale" },
				{ questID = 7641, name = "The Work of Grimand Elmore" },
				{ questID = 7642, name = "Collection of Goods" },
				{ questID = 7643, name = "Ancient Equine Spirit" },
			},
			-- QuestieDB's Forever data (the quest audit's reputation pass, 2026-10-30); the site's quest
			-- page has no Rewards section.
			rewards = { reputation = { { faction = "Stormwind", amount = 150 } } },
		},
		-- Unfinished Gordok Business (AAL, Questie, foreverchanges)
		{
			questID = 7703, name = "Unfinished Gordok Business", level = 60, requiredLevel = 56, faction = "Both",
			pickup = "Captain Kromcrush, inside Dire Maul", turnin = "Captain Kromcrush, inside Dire Maul",
			objective = "Find the Gauntlet of Gordok Might and return it to Captain Kromcrush in Dire Maul.",
			note = "The gauntlet is in The Prince's Chest, in Prince Tortheldrin's wing.",
			rewards = {
				xp = 8300,
				choice = true,
				items = {
					{ itemID = 18366, name = "Gordok's Handguards" },
					{ itemID = 18367, name = "Gordok's Gauntlets" },
					{ itemID = 18368, name = "Gordok's Gloves" },
					{ itemID = 18369, name = "Gordok's Handwraps" },
				},
			},
		},
		-- Enchanted Thorium Platemail: Volume I: here, where Lorekeeper Lydros takes it, as he does Volume II (DireMaul.lua), not in North (2026-10-30).
		-- From level 50 and its plans: foreverchanges' quest page ("Changed in Forever. Requires level 50 instead of 60.";
		-- "You will receive: Plans: Enchanted Thorium Breastplate"; the deep audit of 2026-10-30, g07-09)
		{
			questID = 7649, name = "Enchanted Thorium Platemail: Volume I", level = 60, requiredLevel = 50, faction = "Both",
			pickup = "Enchanted Thorium Platemail: Volume I, bound from its two halves",
			turnin = "Lorekeeper Lydros, inside the dungeon",
			startItem = { itemID = 18769, name = "Enchanted Thorium Platemail", note = "Combine the Top Half (King Gordok, Dire Maul North) and the Bottom Half (Goraluk Anvilcrack, Upper Blackrock Spire) of Advanced Armorsmithing: Volume I." },
			objective = "Bring the book to Lorekeeper Lydros in Dire Maul.",
			note = "For blacksmiths (skill 300).",
			prerequisites = {},
			rewards = { xp = 6600, items = { { itemID = 12727, name = "Plans: Enchanted Thorium Breastplate" } }, reputation = { { faction = "Shen'dralar", amount = 200 } } },
		},
	},
	patches = {
		-- The Madness Within: pickup (Questie, foreverchanges, AAL)
		[7461] = {
			pickup = "Shen'dralar Ancient, inside the dungeon",
		},
		-- Garona: A Study on Stealth and Treachery: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7498] = {
			classOnly = "ROGUE",
			pickup = "Garona: A Study on Stealth and Treachery, inside Dire Maul",
			startItem = { itemID = 18356, name = "Garona: A Study on Stealth and Treachery", note = "From A Dusty Tome in Dire Maul." },
		},
		-- Codex of Defense: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7499] = {
			classOnly = "WARRIOR",
			pickup = "Codex of Defense, inside Dire Maul",
			startItem = { itemID = 18357, name = "Codex of Defense", note = "From A Dusty Tome in Dire Maul." },
		},
		-- The Arcanist's Cookbook: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7500] = {
			classOnly = "MAGE",
			pickup = "The Arcanist's Cookbook, inside Dire Maul",
			startItem = { itemID = 18358, name = "The Arcanist's Cookbook", note = "From A Dusty Tome in Dire Maul." },
		},
		-- The Light and How To Swing It: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7501] = {
			classOnly = "PALADIN",
			pickup = "The Light and How to Swing It, inside Dire Maul",
			startItem = { itemID = 18359, name = "The Light and How to Swing It", note = "From A Dusty Tome in Dire Maul." },
		},
		-- Harnessing Shadows: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7502] = {
			classOnly = "WARLOCK",
			pickup = "Harnessing Shadows, inside Dire Maul",
			startItem = { itemID = 18360, name = "Harnessing Shadows", note = "From A Dusty Tome in Dire Maul." },
		},
		-- The Greatest Race of Hunters: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7503] = {
			classOnly = "HUNTER",
			pickup = "The Greatest Race of Hunters, inside Dire Maul",
			startItem = { itemID = 18361, name = "The Greatest Race of Hunters", note = "From A Dusty Tome in Dire Maul." },
		},
		-- Holy Bologna: What the Light Won't Tell You: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7504] = {
			classOnly = "PRIEST",
			pickup = "Holy Bologna: What the Light Won't Tell You, inside Dire Maul",
			startItem = { itemID = 18362, name = "Holy Bologna: What the Light Won't Tell You", note = "From A Dusty Tome in Dire Maul." },
		},
		-- Frost Shock and You: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7505] = {
			classOnly = "SHAMAN",
			pickup = "Frost Shock and You, inside Dire Maul",
			startItem = { itemID = 18363, name = "Frost Shock and You", note = "From A Dusty Tome in Dire Maul." },
		},
		-- The Emerald Dream...: classOnly, pickup, startItem (Questie, foreverchanges, AAL)
		[7506] = {
			classOnly = "DRUID",
			pickup = "The Emerald Dream, inside Dire Maul",
			startItem = { itemID = 18364, name = "The Emerald Dream", note = "From A Dusty Tome in Dire Maul, or from Captain Kromcrush." },
		},
		-- Foror's Compendium: name, pickup, startItem (Questie, foreverchanges); objective, as East's and
		-- North's (the deep audit of 2026-10-30, g07-03)
		[7507] = {
			name = "Nostro's Compendium",
			pickup = "Nostro's Compendium of Dragon Slaying, inside Dire Maul",
			startItem = { itemID = 18401, name = "Nostro's Compendium of Dragon Slaying", note = "From A Dusty Tome in Dire Maul." },
			objective = "Return Nostro's Compendium of Dragon Slaying to the Athenaeum.",
		},
		-- The Forging of Quel'Serrar: startItem, prerequisites (Questie, foreverchanges)
		[7508] = {
			startItem = { itemID = 18513, name = "A Dull and Flat Elven Blade" },
			prerequisites = { { questID = 7507, name = "Nostro's Compendium" } },
		},
		-- The Forging of Quel'Serrar: pickup, prerequisites (Questie, foreverchanges)
		[7509] = {
			pickup = "Lorekeeper Lydros, inside the dungeon",
			prerequisites = { { questID = 7507, name = "Nostro's Compendium" }, { questID = 7508, name = "The Forging of Quel'Serrar" } },
		},
		-- The Treasure of the Shen'dralar: faction, prerequisites (Questie, foreverchanges, AAL)
		[7877] = {
			faction = "Both",
			prerequisites = { { questID = 7461, name = "The Madness Within" } },
		},
		-- Anthion's Old Friend: prerequisites (Questie, foreverchanges, AAL)
		[8948] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
			},
		},
		-- Falrin's Vendetta: pickup, prerequisites (Questie, foreverchanges, AAL)
		[8949] = {
			pickup = "Falrin Treeshaper, inside the dungeon",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
			},
		},
		-- The Instigator's Enchantment: pickup, prerequisites (Questie, foreverchanges, AAL)
		[8950] = {
			pickup = "Falrin Treeshaper, inside the dungeon",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
			},
		},
	},
	remove = {
		1318, -- Unfinished Gordok Business: a duplicate of Unfinished Gordok Business (7703), not in the game
		5528, -- The Gordok Taste Test: Dire Maul North's: Stomper Kreeg gives and takes it there
		7462, -- The Treasure of the Shen'dralar: a duplicate of The Treasure of the Shen'dralar (7877), which both sides take
		8967, -- The Left Piece of Lord Valthalak's Amulet: Dire Maul East's: its target, Isalien, is there
		8990, -- The Right Piece of Lord Valthalak's Amulet: Dire Maul East's: its target, Isalien, is there
	},
})

Audit("DireMaulNorth", {
	add = {
		-- Unfinished Gordok Business (AAL, Questie, foreverchanges)
		{
			questID = 7703, name = "Unfinished Gordok Business", level = 60, requiredLevel = 56, faction = "Both",
			pickup = "Captain Kromcrush, inside Dire Maul", turnin = "Captain Kromcrush, inside Dire Maul",
			objective = "Find the Gauntlet of Gordok Might and return it to Captain Kromcrush in Dire Maul.",
			note = "The gauntlet is in The Prince's Chest, in Prince Tortheldrin's wing.",
			rewards = {
				xp = 8300,
				choice = true,
				items = {
					{ itemID = 18366, name = "Gordok's Handguards" },
					{ itemID = 18367, name = "Gordok's Gauntlets" },
					{ itemID = 18368, name = "Gordok's Gloves" },
					{ itemID = 18369, name = "Gordok's Handwraps" },
				},
			},
		},
	},
	patches = {
		-- The Gordok Ogre Suit: pickup (Questie, foreverchanges, AAL)
		[5518] = {
			pickup = "Knot Thimblejack, inside the dungeon",
		},
		-- Free Knot!: pickup (Questie, foreverchanges); objective, its repeat's (7429): QuestieDB asks
		-- both for a Gordok Shackle Key (item 18250; the deep audit of 2026-10-30, g07-20)
		[5525] = {
			pickup = "Knot Thimblejack, inside the dungeon",
			objective = "Bring Knot Thimblejack a Gordok Shackle Key to free him.",
		},
		-- The Gordok Taste Test: pickup, turnin (Questie, foreverchanges, AAL)
		[5528] = {
			pickup = "Stomper Kreeg, inside the dungeon",
			turnin = "Stomper Kreeg, inside the dungeon",
		},
		-- The Libram quests (7483-7485): their Elven Legends step, in every wing, is laid on in
		-- Data/Authored/DireMaul.lua; their note is FromForeverChanges.lua's (the deep audit of
		-- 2026-10-30, g07-02).
		-- Garona: A Study on Stealth and Treachery: classOnly, startItem (Questie, foreverchanges, AAL)
		[7498] = {
			classOnly = "ROGUE",
			startItem = { itemID = 18356, name = "Garona: A Study on Stealth and Treachery", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- Codex of Defense: classOnly, startItem (Questie, foreverchanges, AAL)
		[7499] = {
			classOnly = "WARRIOR",
			startItem = { itemID = 18357, name = "Codex of Defense", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- The Arcanist's Cookbook: classOnly, startItem (Questie, foreverchanges, AAL)
		[7500] = {
			classOnly = "MAGE",
			startItem = { itemID = 18358, name = "The Arcanist's Cookbook", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- The Light and How To Swing It: classOnly, startItem (Questie, foreverchanges, AAL)
		[7501] = {
			classOnly = "PALADIN",
			startItem = { itemID = 18359, name = "The Light and How to Swing It", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- Harnessing Shadows: classOnly, startItem (Questie, foreverchanges, AAL)
		[7502] = {
			classOnly = "WARLOCK",
			startItem = { itemID = 18360, name = "Harnessing Shadows", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- The Greatest Race of Hunters: classOnly, startItem (Questie, foreverchanges, AAL)
		[7503] = {
			classOnly = "HUNTER",
			startItem = { itemID = 18361, name = "The Greatest Race of Hunters", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- Holy Bologna: What the Light Won't Tell You: classOnly, startItem (Questie, foreverchanges, AAL)
		[7504] = {
			classOnly = "PRIEST",
			startItem = { itemID = 18362, name = "Holy Bologna: What the Light Won't Tell You", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- Frost Shock and You: classOnly, startItem (Questie, foreverchanges, AAL)
		[7505] = {
			classOnly = "SHAMAN",
			startItem = { itemID = 18363, name = "Frost Shock and You", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- The Emerald Dream...: classOnly, startItem (Questie, foreverchanges, AAL)
		[7506] = {
			classOnly = "DRUID",
			startItem = { itemID = 18364, name = "The Emerald Dream", note = "Found in A Dusty Tome inside Dire Maul." },
		},
		-- Foror's Compendium: name, startItem, objective (Questie, foreverchanges)
		[7507] = {
			name = "Nostro's Compendium",
			startItem = { itemID = 18401, name = "Nostro's Compendium of Dragon Slaying", note = "Found in A Dusty Tome inside Dire Maul." },
			objective = "Return Nostro's Compendium of Dragon Slaying to the Athenaeum.",
		},
		-- The Forging of Quel'Serrar: startItem, prerequisites (Questie, foreverchanges)
		[7508] = {
			startItem = { itemID = 18513, name = "A Dull and Flat Elven Blade" },
			prerequisites = { { questID = 7507, name = "Nostro's Compendium" } },
		},
		-- The Forging of Quel'Serrar: pickup, prerequisites (Questie, foreverchanges)
		[7509] = {
			pickup = "Lorekeeper Lydros, inside Dire Maul",
			prerequisites = { { questID = 7507, name = "Nostro's Compendium" }, { questID = 7508, name = "The Forging of Quel'Serrar" } },
		},
		-- The Treasure of the Shen'dralar: faction, prerequisites (Questie, foreverchanges, AAL)
		[7877] = {
			faction = "Both",
			prerequisites = { { questID = 7461, name = "The Madness Within" } },
		},
		-- Anthion's Old Friend: startMap, prerequisites (Questie, foreverchanges)
		[8948] = {
			startMap = { mapID = 1423, x = 0.261, y = 0.113, label = "Anthion Harmon" },
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
			},
		},
		-- Falrin's Vendetta: pickup, prerequisites (Questie, foreverchanges)
		[8949] = {
			pickup = "Falrin Treeshaper, inside Dire Maul",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
			},
		},
		-- The Instigator's Enchantment: pickup, prerequisites (Questie, foreverchanges)
		[8950] = {
			pickup = "Falrin Treeshaper, inside Dire Maul",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
			},
		},
		-- The Left Piece of Lord Valthalak's Amulet: prerequisites (Questie, foreverchanges)
		[8967] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
			},
		},
		-- The Right Piece of Lord Valthalak's Amulet: prerequisites (Questie, foreverchanges)
		[8990] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
			},
		},
	},
	remove = {
		1318, -- Unfinished Gordok Business: a duplicate of Unfinished Gordok Business (7703), not in the game
		7462, -- The Treasure of the Shen'dralar: a duplicate of The Treasure of the Shen'dralar (7877), which both sides take
	},
})

Audit("Scholomance", {
	add = {
		-- Imp Delivery (Questie)
		{
			questID = 7629, name = "Imp Delivery", level = 60, requiredLevel = 60, faction = "Both", classOnly = "WARLOCK",
			pickup = "Gorzeeki Wildeyes, Burning Steppes", turnin = "Gorzeeki Wildeyes, Burning Steppes",
			startMap = { mapID = 1428, x = 0.124, y = 0.316, label = "Gorzeeki Wildeyes" },
			endMap = { mapID = 1428, x = 0.124, y = 0.316, label = "Gorzeeki Wildeyes" },
			objective = "Take the Imp in a Jar to the alchemy lab in Scholomance, then bring the jar back to Gorzeeki Wildeyes.",
			-- Dreadsteed of Xoroth (7631, Dire Maul West's) needs it and Arcanite (7630) (Questie; 2026-11-03)
			note = "A step of the warlock's Dreadsteed quests.",
			followUp = "With Arcanite, it leads to Dreadsteed of Xoroth, done in Dire Maul's Capital Gardens.",
			prerequisites = {
				{ questID = 7623, name = "Lord Banehollow" },
				{ questID = 7624, name = "Ulathek the Traitor" },
				{ questID = 7625, name = "Xorothian Stardust" },
			},
			rewards = { xp = 6600 },
		},
		-- Judgment and Redemption (Questie)
		{
			questID = 7647, name = "Judgment and Redemption", level = 60, requiredLevel = 60, faction = "Alliance", classOnly = "PALADIN",
			pickup = "Lord Grayson Shadowbreaker, Stormwind City", turnin = "Darkreaver's Fallen Charger, inside the dungeon",
			startMap = { mapID = 1453, x = 0.484, y = 0.502, label = "Lord Grayson Shadowbreaker" },
			objective = "Use the Divination Scryer in the Great Ossuary's basement, defeat the spirits it calls and Death Knight Darkreaver, then give the Charger's Redeemed Soul and the Blessed Enchanted Barding to Darkreaver's Fallen Charger.",
			note = "The last step of the paladin's charger quests.",
			prerequisites = {
				{ questID = 7638, name = "Lord Grayson Shadowbreaker" },
				{ questID = 7637, name = "Emphasis on Sacrifice" },
				{ questID = 7639, name = "To Show Due Judgment" },
				{ questID = 7640, name = "Exorcising Terrordale" },
				{ questID = 7641, name = "The Work of Grimand Elmore" },
				{ questID = 7642, name = "Collection of Goods" },
				{ questID = 7643, name = "Ancient Equine Spirit" },
				{ questID = 7644, name = "Blessed Arcanite Barding" },
				{ questID = 7646, name = "The Divination Scryer" },
			},
			rewards = { xp = 9950 },
		},
		-- The Darkreaver Menace (Questie)
		{
			questID = 8258, name = "The Darkreaver Menace", level = 60, requiredLevel = 58, faction = "Horde", classOnly = "SHAMAN",
			pickup = "Sagorne Creststrider, Valley of Wisdom, Orgrimmar", turnin = "Sagorne Creststrider, Valley of Wisdom, Orgrimmar",
			startMap = { mapID = 1454, x = 0.387, y = 0.359, label = "Sagorne Creststrider" },
			endMap = { mapID = 1454, x = 0.387, y = 0.359, label = "Sagorne Creststrider" },
			objective = "Use the Divination Scryer in the Great Ossuary's basement, defeat the spirits it calls and Death Knight Darkreaver, and bring Darkreaver's Head to Sagorne Creststrider.",
			prerequisites = { { questID = 7667, name = "Material Assistance" } },
			-- From level 58 and the Skyfury Helm: foreverchanges' quest page ("Changed in Forever. Requires
			-- level 58 instead of 60."; QuestieDB says 60, so kept for an in-game check; "You will receive:
			-- Skyfury Helm", item 20134 in QuestieDB's Forever data too; the deep audit of 2026-10-30, g07-06, g07-07)
			rewards = { xp = 9950, items = { { itemID = 20134, name = "Skyfury Helm", quality = 4 } } },
		},
	},
	patches = {
		-- Dawn's Gambit: prerequisites (Questie, foreverchanges)
		[4771] = {
			prerequisites = {
				{ questID = 4726, name = "Broodling Essence" },
				{ questID = 4808, name = "Felnok Steelspring" },
				{ questID = 4809, name = "Chillwind Horns" },
				{ questID = 4810, name = "Return to Tinkee" },
				{ questID = 4734, name = "Egg Freezing" },
				{ questID = 4735, name = "Egg Collection" },
				{ questID = 5522, name = "Leonid Barthalomew" },
				{ questID = 5531, name = "Betina Bigglezink" },
			},
		},
		-- Kirtonos the Herald: prerequisites (Questie, foreverchanges)
		[5384] = {
			prerequisites = { { questID = 5382, name = "Doctor Theolen Krastinov, the Butcher" }, { questID = 5515, name = "Krastinov's Bag of Horrors" } },
		},
		-- The Lich, Ras Frostwhisper: prerequisites (Questie, foreverchanges)
		[5466] = {
			prerequisites = {
				{ questID = 5382, name = "Doctor Theolen Krastinov, the Butcher" },
				{ questID = 5515, name = "Krastinov's Bag of Horrors" },
				{ questID = 5384, name = "Kirtonos the Herald" },
				{ questID = 5461, name = "The Human, Ras Frostwhisper" },
				{ questID = 5462, name = "The Dying, Ras Frostwhisper" },
				{ questID = 5463, name = "Menethil's Gift" },
				{ questID = 5464, name = "Menethil's Gift" },
				{ questID = 5465, name = "Soulbound Keepsake" },
			},
		},
		-- Betina Bigglezink: prerequisites (Questie, foreverchanges)
		[5531] = {
			prerequisites = {
				{ questID = 4726, name = "Broodling Essence" },
				{ questID = 4808, name = "Felnok Steelspring" },
				{ questID = 4809, name = "Chillwind Horns" },
				{ questID = 4810, name = "Return to Tinkee" },
				{ questID = 4734, name = "Egg Freezing" },
				{ questID = 4735, name = "Egg Collection" },
				{ questID = 5522, name = "Leonid Barthalomew" },
			},
		},
		-- Healthy Dragon Scale: startItem (Questie)
		[5582] = {
			startItem = { itemID = 13920, name = "Healthy Dragon Scale", note = "Drops from Plagued Hatchlings inside Scholomance." },
		},
		-- Kormok's Left and Right Piece (8969, 8992) take Upper Blackrock Spire's chains, laid on in
		-- Data/Authored/TempleAndStratholme.lua (the deep audit of 2026-10-30, g07-01/g10-01).
	},
})

Audit("Stratholme", {
	add = {
		-- Sweet Serenity (Questie)
		{
			questID = 5305, name = "Sweet Serenity", level = 60, requiredLevel = 50, faction = "Both",
			pickup = "Lilith the Lithe, Everlook, Winterspring", turnin = "Lilith the Lithe, Everlook, Winterspring",
			startMap = { mapID = 1452, x = 0.613, y = 0.371 }, endMap = { mapID = 1452, x = 0.613, y = 0.371 },
			objective = "Travel to Stratholme and kill the Crimson Hammersmith. Recover the Crimson Hammersmith's Apron and return to Lilith.",
			note = "For weaponsmiths with a blacksmithing skill of 250.",
			prerequisites = {},
			rewards = { xp = 8300, items = { { itemID = 12824, name = "Plans: Enchanted Battlehammer" } } },
		},
		-- Corruption (Questie)
		{
			questID = 5307, name = "Corruption", level = 60, requiredLevel = 50, faction = "Both",
			pickup = "Seril Scourgebane, Everlook, Winterspring",
			turnin = "Seril Scourgebane, Everlook, Winterspring",
			startMap = { mapID = 1452, x = 0.613, y = 0.372, label = "Seril Scourgebane" },
			endMap = { mapID = 1452, x = 0.613, y = 0.372, label = "Seril Scourgebane" },
			objective = "Destroy the Black Guard Swordsmith in Stratholme and bring the Insignia of the Black Guard to Seril Scourgebane.",
			note = "For weaponsmiths with a blacksmithing skill of 250. The Swordsmith appears near Baroness Anastari when you pick up the blacksmithing plans there.",
			prerequisites = {},
			rewards = { xp = 8300, items = { { itemID = 12825, name = "Plans: Blazing Rapier" } } },
		},
		-- Menethil's Gift (Questie, foreverchanges)
		{
			questID = 5464, name = "Menethil's Gift", level = 60, requiredLevel = 57, faction = "Both",
			pickup = "Menethil's Gift, inside Stratholme", turnin = "Leonid Barthalomew the Revered, Eastern Plaguelands",
			endMap = { mapID = 1423, x = 0.719, y = 0.483 },
			startObject = { name = "Menethil's Gift", note = "Inside Stratholme, where the Keepsake of Remembrance is placed." },
			objective = "Take the Soulbound Keepsake to Leonid Barthalomew in Eastern Plaguelands.",
			note = "Then Leonid gives Soulbound Keepsake, which sends you back to Magistrate Marduke in Caer Darrow. The chain ends with The Lich, Ras Frostwhisper, in Scholomance.",
			prerequisites = { { questID = 5382, name = "Doctor Theolen Krastinov, the Butcher" }, { questID = 5515, name = "Krastinov's Bag of Horrors" }, { questID = 5384, name = "Kirtonos the Herald" }, { questID = 5461, name = "The Human, Ras Frostwhisper" }, { questID = 5462, name = "The Dying, Ras Frostwhisper" }, { questID = 5463, name = "Menethil's Gift" } },
			rewards = { xp = 8300, reputation = { { faction = "Argent Dawn", amount = 150 } } },
		},
		-- Proof of Life (Questie, foreverchanges)
		{
			questID = 8946, name = "Proof of Life", level = 60, requiredLevel = 58, faction = "Both",
			pickup = "Ysida Harmon, inside the dungeon",
			turnin = "Anthion Harmon, Eastern Plaguelands",
			endMap = { mapID = 1423, x = 0.261, y = 0.113 },
			objective = "Bring Ysida's Locket to Anthion Harmon in the Eastern Plaguelands.",
			prerequisites = { { questID = 8921, name = "The Ectoplasmic Distiller" }, { questID = 8924, name = "Hunting for Ectoplasm" }, { questID = 8925, name = "A Portable Power Source" }, { questID = 8928, name = "A Shifty Merchant" }, { questID = 8945, name = "Dead Man's Plea" } },
			rewards = { xp = 6600 },
		},
	},
	patches = {
		-- Aurius' Reckoning: pickup, turnin (Questie, foreverchanges, AAL)
		[5125] = {
			pickup = "Aurius, inside Stratholme",
			turnin = "Aurius, inside Stratholme",
		},
		-- The Truth Comes Crashing Down: pickup, startItem (Questie, foreverchanges)
		[5262] = {
			pickup = "Head of Balnazzar, dropped by Balnazzar inside Stratholme",
			startItem = { itemID = 13250, name = "Head of Balnazzar", note = "Drops from Balnazzar inside Stratholme." },
		},
		-- Above and Beyond: prerequisites (Questie, foreverchanges)
		[5263] = {
			prerequisites = { { questID = 5251, name = "The Archivist" }, { questID = 5262, name = "The Truth Comes Crashing Down" } },
		},
		-- The Argent Hold: prerequisites (Questie, foreverchanges)
		[5265] = {
			prerequisites = {
				{ questID = 5251, name = "The Archivist" },
				{ questID = 5262, name = "The Truth Comes Crashing Down" },
				{ questID = 5263, name = "Above and Beyond" },
				{ questID = 5264, name = "Lord Maxwell Tyrosus" },
			},
		},
		-- Menethil's Gift: turnin, prerequisites (Questie, foreverchanges); the turnin as the Service Gate's page had it, the
		-- dungeon unnamed, since 0.39.22's one page
		[5463] = {
			turnin = "Menethil's Gift, inside the dungeon",
			prerequisites = {
				{ questID = 5382, name = "Doctor Theolen Krastinov, the Butcher" },
				{ questID = 5515, name = "Krastinov's Bag of Horrors" },
				{ questID = 5384, name = "Kirtonos the Herald" },
				{ questID = 5461, name = "The Human, Ras Frostwhisper" },
				{ questID = 5462, name = "The Dying, Ras Frostwhisper" },
			},
		},
		-- Of Love and Family: prerequisites (Questie, foreverchanges)
		[5848] = {
			note = "Then Tirion Fordring gives Find Myranda, which sends you to Myranda the Hag in the Western Plaguelands.",
			prerequisites = {
				{ questID = 5542, name = "Demon Dogs" },
				{ questID = 5543, name = "Blood Tinged Skies" },
				{ questID = 5544, name = "Carrion Grubbage" },
				{ questID = 5742, name = "Redemption" },
				{ questID = 5781, name = "Of Forgotten Memories" },
				{ questID = 5845, name = "Of Lost Honor" },
				{ questID = 5846, name = "Of Love and Family" },
			},
		},
		-- Ramstein: prerequisites (Questie, foreverchanges)
		[6163] = {
			prerequisites = {
				{ questID = 6022, name = "To Kill With Purpose" },
				{ questID = 6042, name = "Un-Life's Little Annoyances" },
				{ questID = 6133, name = "The Ranger Lord's Behest" },
				{ questID = 6135, name = "Duskwing, Oh How I Hate Thee..." },
				{ questID = 6136, name = "The Corpulent One" },
			},
		},
		-- Dead Man's Plea: prerequisites (Questie, foreverchanges)
		[8945] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
			},
		},
		-- The Left and Right Piece of Lord Valthalak's Amulet (8968, 8991) take Upper Blackrock Spire's
		-- chains, laid on in Data/Authored/TempleAndStratholme.lua (the deep audit of 2026-10-30, S12).
	},
})

Audit("UpperBlackrockSpire", {
	add = {
		-- Eye of the Emberseer (Questie)
		{
			questID = 6821, name = "Eye of the Emberseer", level = 60, requiredLevel = 56, faction = "Both",
			pickup = "Duke Hydraxis, Azshara",
			turnin = "Duke Hydraxis, Azshara",
			startMap = { mapID = 1447, x = 0.793, y = 0.737 }, endMap = { mapID = 1447, x = 0.793, y = 0.737 },
			objective = "Slay Pyroguard Emberseer in Upper Blackrock Spire and bring his eye to Duke Hydraxis in Azshara.",
			prerequisites = { { questID = 6804, name = "Poisoned Water" }, { questID = 6805, name = "Stormers and Rumblers" } },
			rewards = { xp = 8300 },
		},
		-- Three Kings of Flame (Questie, foreverchanges)
		{
			questID = 8961, name = "Three Kings of Flame", level = 60, requiredLevel = 58, faction = "Both",
			pickup = "Bodley, Blackrock Mountain",
			turnin = "Bodley, Blackrock Mountain",
			startMap = { mapID = 1428, x = 0.323, y = 0.258 }, endMap = { mapID = 1428, x = 0.323, y = 0.258 },
			objective = "Bring Bodley the Incendicite of Incendius (Lord Incendius, Blackrock Depths), the Ember of Emberseer (Pyroguard Emberseer, Upper Blackrock Spire) and the Cinder of Cynders (the Duke of Cynders, Silithus), with a Hallowed Brazier.",
			note = "Also needs your side's Bodley's Unfortunate Fate, after your class's Anthion's Parting Words.",
			prerequisites = { { questID = 8921, name = "The Ectoplasmic Distiller" }, { questID = 8924, name = "Hunting for Ectoplasm" }, { questID = 8925, name = "A Portable Power Source" }, { questID = 8928, name = "A Shifty Merchant" }, { questID = 8945, name = "Dead Man's Plea" }, { questID = 8946, name = "Proof of Life" }, { questID = 8947, name = "Anthion's Strange Request" }, { questID = 8948, name = "Anthion's Old Friend" }, { questID = 8949, name = "Falrin's Vendetta" }, { questID = 8950, name = "The Instigator's Enchantment" }, { questID = 9015, name = "The Challenge" } },
			rewards = { xp = 6600 },
		},
		-- Final Preparations (Questie, foreverchanges)
		{
			questID = 8994, name = "Final Preparations", level = 60, requiredLevel = 58, faction = "Both",
			pickup = "Bodley, Blackrock Mountain",
			turnin = "Bodley, Blackrock Mountain",
			startMap = { mapID = 1428, x = 0.323, y = 0.258 }, endMap = { mapID = 1428, x = 0.323, y = 0.258 },
			objective = "Bring Bodley 40 Blackrock Bracers, taken from the orcs of Blackrock Spire, and a Flask of Supreme Power.",
			note = "Offered once one of the four Right Piece of Lord Valthalak's Amulet quests is done.",
			prerequisites = { { questID = 8921, name = "The Ectoplasmic Distiller" }, { questID = 8924, name = "Hunting for Ectoplasm" }, { questID = 8925, name = "A Portable Power Source" }, { questID = 8928, name = "A Shifty Merchant" }, { questID = 8945, name = "Dead Man's Plea" }, { questID = 8946, name = "Proof of Life" }, { questID = 8947, name = "Anthion's Strange Request" }, { questID = 8948, name = "Anthion's Old Friend" }, { questID = 8949, name = "Falrin's Vendetta" }, { questID = 8950, name = "The Instigator's Enchantment" }, { questID = 9015, name = "The Challenge" }, { questID = 8961, name = "Three Kings of Flame" }, { questID = 8970, name = "I See Alcaz Island In Your Future..." } },
			rewards = { xp = 6600 },
		},
	},
	patches = {
		-- Egg Freezing: prerequisites (Questie, foreverchanges)
		[4734] = {
			prerequisites = {
				{ questID = 4726, name = "Broodling Essence" },
				{ questID = 4808, name = "Felnok Steelspring" },
				{ questID = 4809, name = "Chillwind Horns" },
				{ questID = 4810, name = "Return to Tinkee" },
			},
		},
		-- Egg Collection: prerequisites (Questie, foreverchanges)
		[4735] = {
			prerequisites = {
				{ questID = 4726, name = "Broodling Essence" },
				{ questID = 4808, name = "Felnok Steelspring" },
				{ questID = 4809, name = "Chillwind Horns" },
				{ questID = 4810, name = "Return to Tinkee" },
				{ questID = 4734, name = "Egg Freezing" },
			},
		},
		-- Seal of Ascension: pickup, turnin (Questie, foreverchanges, AAL, Wowhead)
		[4743] = {
			pickup = "Scarshield Infiltrator, inside Lower Blackrock Spire",
			turnin = "Scarshield Infiltrator, inside Lower Blackrock Spire",
		},
		-- Doomrigger's Clasp: prerequisites (Questie, foreverchanges)
		[4764] = {
			prerequisites = {},
		},
		-- The Darkstone Tablet: prerequisites (Questie, foreverchanges)
		[4768] = {
			prerequisites = {},
		},
		-- The Final Tablets: prerequisites (Questie, foreverchanges)
		[4788] = {
			prerequisites = {
				{ questID = 3520, name = "Screecher Spirits" },
				{ questID = 3527, name = "The Prophecy of Mosh'aru" },
				{ questID = 4787, name = "The Ancient Egg" },
				{ questID = 3528, name = "The God Hakkar" },
				{ questID = 5065, name = "The Lost Tablets of Mosh'aru" },
			},
		},
		-- Tinkee Steamboil: prerequisites (Questie, foreverchanges)
		[4907] = {
			prerequisites = {
				{ questID = 4726, name = "Broodling Essence" },
				{ questID = 4808, name = "Felnok Steelspring" },
				{ questID = 4809, name = "Chillwind Horns" },
				{ questID = 4810, name = "Return to Tinkee" },
			},
		},
		-- For The Horde!: prerequisites (Questie, foreverchanges)
		[4974] = {
			prerequisites = { { questID = 4903, name = "Warlord's Command" }, { questID = 4941, name = "Eitrigg's Wisdom" } },
		},
		-- Bijou's Belongings: prerequisites (Questie, foreverchanges)
		[4982] = {
			prerequisites = { { questID = 4981, name = "Operative Bijou" } },
		},
		-- Bijou's Reconnaissance Report: pickup, prerequisites (Questie, foreverchanges, AAL)
		[4983] = {
			pickup = "Bijou, inside Lower Blackrock Spire",
			prerequisites = { { questID = 4981, name = "Operative Bijou" }, { questID = 4982, name = "Bijou's Belongings" } },
		},
		-- Bijou's Belongings: pickup, turnin (Questie, foreverchanges)
		[5001] = {
			pickup = "Bijou, inside Lower Blackrock Spire",
			turnin = "Bijou, inside Lower Blackrock Spire",
		},
		-- Message to Maxwell: pickup (Questie, foreverchanges)
		[5002] = {
			pickup = "Bijou, inside Lower Blackrock Spire",
		},
		-- Pip Quickwit, At Your Service!: pickup (Questie, foreverchanges; Pip is Forever's name for Finkle Einhorn, Questie)
		[5047] = {
			pickup = "Pip Quickwit, inside the dungeon",
		},
		-- The Matron Protectorate: pickup (Questie, foreverchanges)
		[5160] = {
			pickup = "Awbee, inside the dungeon",
		},
		-- Drakefire Amulet: prerequisites (Questie, foreverchanges)
		[6502] = {
			prerequisites = {
				{ questID = 4182, name = "Dragonkin Menace" },
				{ questID = 4183, name = "The True Masters" },
				{ questID = 4184, name = "The True Masters" },
				{ questID = 4185, name = "The True Masters" },
				{ questID = 4186, name = "The True Masters" },
				{ questID = 4223, name = "The True Masters" },
				{ questID = 4224, name = "The True Masters" },
				{ questID = 4241, name = "Marshal Windsor" },
				{ questID = 4242, name = "Abandoned Hope" },
				{ questID = 4264, name = "A Crumpled Up Note" },
				{ questID = 4282, name = "A Shred of Hope" },
				{ questID = 4322, name = "Jail Break!" },
				{ questID = 6402, name = "Stormwind Rendezvous" },
				{ questID = 6403, name = "The Great Masquerade" },
				{ questID = 6501, name = "The Dragon's Eye" },
			},
		},
		-- Blood of the Black Dragon Champion: prerequisites (Questie, foreverchanges)
		[6602] = {
			prerequisites = {
				{ questID = 4903, name = "Warlord's Command" },
				{ questID = 4941, name = "Eitrigg's Wisdom" },
				{ questID = 4974, name = "For The Horde!" },
				{ questID = 6566, name = "What the Wind Carries" },
				{ questID = 6567, name = "The Champion of the Horde" },
				{ questID = 6568, name = "The Testament of Rexxar" },
				{ questID = 6569, name = "Oculus Illusions" },
				{ questID = 6570, name = "Emberstrife" },
				{ questID = 6582, name = "The Test of Skulls, Scryer" },
				{ questID = 6583, name = "The Test of Skulls, Somnus" },
				{ questID = 6584, name = "The Test of Skulls, Chronalis" },
				{ questID = 6585, name = "The Test of Skulls, Axtroz" },
				{ questID = 6601, name = "Ascension..." },
			},
		},
		-- Blackhand's Command: pickup, startItem; its note cleared, as the start item's own says where it drops (2026-10-30)
		[7761] = {
			pickup = "Blackhand's Command, dropped by the Scarshield Quartermaster in Blackrock Mountain",
			startItem = { itemID = 18987, name = "Blackhand's Command", note = "Dropped by the Scarshield Quartermaster in Blackrock Mountain, outside the Spire." },
			note = false,
		},
		-- Confront Yeh'kinya: prerequisites (Questie, foreverchanges)
		[8181] = {
			prerequisites = {
				{ questID = 3520, name = "Screecher Spirits" },
				{ questID = 3527, name = "The Prophecy of Mosh'aru" },
				{ questID = 4787, name = "The Ancient Egg" },
				{ questID = 3528, name = "The God Hakkar" },
				{ questID = 5065, name = "The Lost Tablets of Mosh'aru" },
				{ questID = 4788, name = "The Final Tablets" },
			},
		},
		-- The Left Piece of Lord Valthalak's Amulet: prerequisites (Wowhead)
		[8966] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
			},
		},
		-- The Right Piece of Lord Valthalak's Amulet: prerequisites (Questie, foreverchanges)
		[8989] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
			},
		},
		-- Mea Culpa, Lord Valthalak: prerequisites (Questie, foreverchanges)
		[8995] = {
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
				{ questID = 8994, name = "Final Preparations" },
			},
		},
		-- Return to Bodley: pickup, prerequisites (Questie, foreverchanges)
		[8996] = {
			pickup = "Spirit of Lord Valthalak, inside the dungeon",
			prerequisites = {
				{ questID = 8921, name = "The Ectoplasmic Distiller" },
				{ questID = 8924, name = "Hunting for Ectoplasm" },
				{ questID = 8925, name = "A Portable Power Source" },
				{ questID = 8928, name = "A Shifty Merchant" },
				{ questID = 8945, name = "Dead Man's Plea" },
				{ questID = 8946, name = "Proof of Life" },
				{ questID = 8947, name = "Anthion's Strange Request" },
				{ questID = 8948, name = "Anthion's Old Friend" },
				{ questID = 8949, name = "Falrin's Vendetta" },
				{ questID = 8950, name = "The Instigator's Enchantment" },
				{ questID = 9015, name = "The Challenge" },
				{ questID = 8961, name = "Three Kings of Flame" },
				{ questID = 8970, name = "I See Alcaz Island In Your Future..." },
				{ questID = 8994, name = "Final Preparations" },
				{ questID = 8995, name = "Mea Culpa, Lord Valthalak" },
			},
		},
	},
})

-- The lead-in rows still listed, each just before the quest it leads to (Forever's quest data; the
-- quest review of 2026-11-03: every lead-in row says "Optional: it leads to ...", and sits just before that
-- quest). Since the owner's call of 2026-11-07 a talk that only leads to a dungeon quest is not a quest of its
-- own here: the 18 that did are out, with their placements here (Speak with Shoni since 2026-11-06). Those that
-- follow a quest of their own chain stay rows: Speak with Thun'grim (after Trial at the Field of Giants) and
-- Tinkee Steamboil (after Return to Tinkee). In Search of Thaelrid is back since the owner's report of 2026-11-08:
-- its talk is inside Blackfathom Deeps, and the game lists it as a dungeon quest.
ns.ListQuestBefore("RazorfenKraul", 1825, 1838)
ns.ListQuestBefore("BlackfathomDeeps", 1198, 1200)
-- And The Lost Dwarves, the same way, since the owner's call of 2026-11-08 (its talk is with Baelog inside Uldaman)
ns.ListQuestBefore("Uldaman", 2398, 2240)
ns.ListQuestBefore("UpperBlackrockSpire", 4907, 4734)
