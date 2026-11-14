local _, ns = ...

--[[
	Forever's own dungeons (the Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands): notes
	before you go and quest fixes, written by hand over their data (Data/Instances/HallOfThanes.lua,
	RuinsOfLordaeron.lua, ExcavationSiteWetlands.lua) and the overlays before this file, from the quest
	audit of 2026-10-29 (Dev/docs/audit_2026-10-29, step 13 of its plan). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game), with
	foreverchanges.pro's quest pages (2026-10-30) for the levels, sides and rewards, which agree but
	where said (An Ancient Grudge's side, both factions there and the Alliance in QuestieDB, stays
	Both in Data/Instances/HallOfThanes.lua: the owner saw a Horde character get it, 2026-11-05):
	  The Hall of Thanes. The Dark Iron Map (274268) drops from the Dark Iron Spies and Captain Beld,
	  whose spots are the spies' (Dun Morogh, about 77, 61; Ironband's Compound in Nip 'Em in the Bud's
	  own words), and starts Underground Map (96391), which Earthseer Farsen takes; he then gives Old
	  Ironforge Incursion (96393). A Visitor to Dun Morogh (96408, Beldin Steelgrill's) leads to him;
	  Farsen's Watch (96392) comes before Nip 'Em in the Bud (96390). None of the three is needed for
	  the map, so they are optional lead-ins here, not prerequisites. All Alliance, from level 9.
	  Ruins of Lordaeron. Master Apothecary Faranell hands you the Head of the Baron (268518) with
	  part 2 of Unending Torment (97289), to take to Othmar's body, the Unfinished Abomination.
	  foreverchanges.pro's quest pages give the Horde chain's choice of Monstrous Cleaver, Grave Shroud
	  or Slain Baron's Signet on part 3 (97290), not on part 1 (97288), which gives none.
	  Excavation Site. The Relic Guardian, the last boss, drops each side's Titan Relic (270865 for the
	  Alliance, starting Lost Relic Carry, 95810; 270866 for the Horde, starting Elder Knowledge,
	  95664). The quests that lead to the dungeon's own: Seeking Caitlin (95737) to Lost in the Thicket
	  Things; Rethiel the Greenwarden's Tramping Paws, Fire Taboo and Blisters on The Land (276, 277,
	  275) before Horrors in the Highland; Young Crocolisk Skins (484) before Highland Hides; Dragonmaw
	  Rumors (95663) to Open the Maw.

	Unending Torment's later parts are done in the Undercity; both sources file them under the Ruins
	(but part 3, which QuestieDB files under the Undercity), so they stay, as the chain they were.

	Loads after FromGuides.lua, FromForeverChanges.lua and QuestAudit.lua, whose quests it amends.
]]

ns.AmendInstance("HallOfThanes", {
	-- Before you go (the overview): where the Dark Iron Map comes from, and the quests that lead to it.
	prepare = {
		{
			faction = "Alliance",
			title = "The Dark Iron Map",
			text = "Dark Iron Spies and Captain Beld, at Ironband's Compound in Dun Morogh, drop the "
				.. "{item:274268:Dark Iron Map:1}. It starts Underground Map: bring it to Earthseer Farsen, at his camp "
				.. "above the Gol'Bolar Quarry, and he gives Old Ironforge Incursion. Optional lead-ins: Beldin "
				.. "Steelgrill's A Visitor to Dun Morogh sends you to Farsen, who then gives Farsen's Watch and Nip 'Em "
				.. "in the Bud, which sends you after the spies.",
		},
	},
})

ns.AmendInstance("RuinsOfLordaeron", {
	questPatches = {
		[97289] = {
			note = "New in Forever: part 2, given in the Undercity once the Abominable Head is with Master Apothecary "
				.. "Faranell. He hands you the Head of the Baron: take it to Othmar's body, the Unfinished Abomination.",
		},
		-- The chain's reward, on its own step (the item rows as Abominable Creatures, 95250, has them). Its XP
		-- and money: foreverchanges.pro's quest page (the quest audit's XP pass, 2026-10-30).
		[97290] = {
			rewards = {
				xp = 1650,
				money = 1300,
				items = {
					{ itemID = 279864, name = "Monstrous Cleaver", quality = 3 },
					{ itemID = 279865, name = "Grave Shroud", quality = 3 },
					{ itemID = 279867, name = "Slain Baron's Signet", quality = 3 },
				},
				choice = true,
			},
		},
	},
})

ns.AmendInstance("ExcavationSiteWetlands", {
	-- Before you go (the overview): each side's Titan Relic, which drops inside, and the quests that
	-- lead to the dungeon's own. A plain note, not a key: the relic is not needed to get in, the last
	-- boss drops it and it starts a quest (the deep audit of 2026-10-30, g09-13; the owner's call,
	-- 2026-11-03).
	prepare = {
		{
			faction = "Alliance",
			title = "The Titan Relic",
			text = "The Relic Guardian, the last boss, drops the {item:270865:Titan Relic:1}. It starts Lost Relic "
				.. "Carry: bring it to Prospector Whelgar at Whelgar's Excavation Site, who then gives Prehistoric Prism. "
				.. "Quests that lead here: Seeking Caitlin, from Llana in Astranaar, to Lost in the Thicket Things; "
				.. "Rethiel the Greenwarden's Tramping Paws, Fire Taboo and Blisters on The Land before Horrors in the "
				.. "Highland; James Halloran's Young Crocolisk Skins before Highland Hides.",
		},
		{
			faction = "Horde",
			title = "The Titan Relic",
			text = "The Relic Guardian, the last boss, drops the {item:270866:Titan Relic:1}. It starts Elder Knowledge: "
				.. "take it to Bashana Runetotem on the Elder Rise in Thunder Bluff, who then gives Earthen Echo. Quests "
				.. "that lead here: Zaruk's Dragonmaw Rumors, in the Arathi Highlands, to Open the Maw.",
		},
	},
})

-- Each chain's rows in its order, the quest that opens a follow-up just before it, as the site's
-- Excavation Site page lists them (the owner's calls of 2026-11-03, change 35; as the deep audit's
-- G03-11 and S7 did elsewhere): Lost Relic Carry, Prehistoric Prism; Lost in the Thicket Things,
-- Heartwoven; Dragonmaw Rumors, Open the Maw; Elder Knowledge, Earthen Echo. In this order the rows say
-- what the notes on Lost in the Thicket Things, Heartwoven, Lost Relic Carry and Elder Knowledge said
-- ("Follows", "Leads to"), so those notes are gone. Seeking Caitlin (95737), the lead-in Lost in the
-- Thicket Things was listed after, is out of the journal since the owner's call of 2026-11-07; Lost in
-- the Thicket Things keeps its place, after Prehistoric Prism.
ns.ListQuestAfter("ExcavationSiteWetlands", 98824, 95810)
ns.ListQuestAfter("ExcavationSiteWetlands", 95647, 98824)
ns.ListQuestAfter("ExcavationSiteWetlands", 95809, 95647)
ns.ListQuestAfter("ExcavationSiteWetlands", 95682, 95663)
ns.ListQuestAfter("ExcavationSiteWetlands", 98823, 95664)
