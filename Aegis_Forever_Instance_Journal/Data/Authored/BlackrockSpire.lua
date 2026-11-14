local _, ns = ...

--[[
	Lower and Upper Blackrock Spire, written by hand over their data (Data/Instances/
	LowerBlackrockSpire.lua, UpperBlackrockSpire.lua), from the quest audit of 2026-10-29
	(Dev/docs/audit_2026-10-29). Facts only, in our own words.

	From QuestieDB's Forever data (Dev/questie, an October 10 snapshot of the live game): the Seal of
	Ascension's two quests (4742, 4743), Vaelan (the Scarshield Infiltrator, npc 10299) who gives
	and takes both, the three gemstones and the Unadorned Seal (12219, dropped by the Spire's foes
	and by the Scarshield Quartermaster outside), Vaelan's Gift (4743's sourceItemId) and the Seal as
	4743's reward; Urok Doomhowl's quest (4867: the Roughshod Pike, picked up at object 175886, and
	Omokk's Head, set up at Urok's Tribute Pile, object 175621; Warosh's Mojo his drop); the
	Braziers of Beckoning that Mea Culpa, Lord Valthalak (8995, item 22056) and the Mor Grayhoof
	versions of the amulet's pieces (8966, 8989, item 22049) give when taken, and the two spirits
	they call (npcs 16042, 16080; their brazier spots, objects 181050 and 181046, are in the Spire,
	which half not said); the Drakefire Amulet (16309) as 6502's and 6602's reward; Blackhand's
	Command (18987) from the Scarshield Quartermaster and Drakkisath's Brand (object 179880); Eye of
	the Emberseer (6821) leading on to The Molten Core (6822); the amulet chain's "one of four"
	steps (8962-8965 before 8966, 8985-8988 before 8989); Warlord's Command (4903) also starting from
	Warlord Goretooth's Command (12563); Plans: Dawn's Edge (12821) as Snakestone of the Shadow
	Huntress's reward; the Elixir of Demonslaying (9224) given with The Demon Forge (5127), as
	foreverchanges.pro's Lower and Upper pages also list it; Pip Quickwit, At Your Service! (5047)
	kept from level 55, QuestieDB's (the site's quest page and its Spire list now say 57: "Requires
	level 57 instead of 55"; unsure, see below). Forever renamed Finkle Einhorn: QuestieDB's Forever
	data names the quest and its giver (npc 10776) Pip Quickwit, while the site still writes Finkle.

	Left out, unsure (Dev/docs/audit_2026-10-29/README.md): Bodley's spot, kept as it was; Rexxar's
	spot; that only one player needs the Seal; how Pip Quickwit
	appears; the level Pip Quickwit, At Your Service! is taken from (QuestieDB 55, the site 57; the
	journal keeps 55 until it is seen in game); the level Eye of the Emberseer (6821) is taken from
	(QuestieDB 56, the site 55: "Requires level 55 instead of 56"; the journal keeps 56).
	Taken out on the owner's rule (2026-10-29: quests not done in the dungeon and not leading to it):
	Confront Yeh'kinya (8181), on both halves. It comes after The Final Tablets (4788), whose tablets
	are in the Spire, but it is only a talk with Yeh'kinya in Tanaris and leads on to Zul'Gurub
	(QuestieDB: Prospector Ironboot gives it, Yeh'kinya takes it, next 8182; the site files it under
	Stranglethorn Vale as a raid quest). Its choice of two cloaks is named in The Final Tablets' note.
	What the Drakefire Amulet and the Mark of Drakkisath opened is the original game's, and the notes
	say so. The Onyxia attunement is the same entry Onyxia's Lair shows (ns.OnyxiaAttunement, below;
	step 18 of the audit's plan, 2026-10-30, gave it each side's whole chain in plain words). Both
	halves' reputation is the audit's reputation pass's (step 15c, 2026-10-30): QuestieDB's Forever
	data, which the site's quest pages match; a quest in both halves gives the same in each.

	From the deep audit of 2026-10-30 (Dev/docs/audit_2026-10-30, step 8 of its plan): The Demon
	Forge (5127) gives 5 of item 9224 (the site's item box; the site calls it Potion of Demon Slaying,
	QuestieDB Elixir of Demonslaying: the client shows its own name). Lorax's Tale (5126) is for
	warriors, paladins and shamans (QuestieDB's requiredClasses 67) with Blacksmithing 270, and The
	Demon Forge needs it and the same skill (the site says 285: unsure). Oculus Illusions (6569) is
	Upper's: its own text sends you to the upper citadel, the site's drops are Upper's Rookery
	Hatchers and Rage Talon dragonspawn, and QuestieDB's raid flag is set on it. What follows outside
	(QuestieDB's preQuestSingle): Malyfous's Catalogue's three quests after Pip Quickwit (5063, 5067,
	5068, each needing a Pristine Hide of the Beast); Leonid Barthalomew (5522) after Egg Collection,
	on to Betina Bigglezink (5531) and Dawn's Gambit (4771) in Scholomance. Bodley's label is "Blackrock Mountain" on
	every amulet quest now, as the quests' own objectives and the chain's steps say; his pin is
	unchanged and still on the list of things to check in game. Left for the owner: whether Delivery
	to Ridgewell (4765) goes.

	Which half each spirit is called in (the owner's call of 2026-11-03 on the deep audit's "missed"
	row for the Spire): the quest texts say so. Mor Grayhoof was killed in front of War Master Voone,
	a Lower boss (the Mor Grayhoof versions of the pieces, 8966 and 8989), and Lord Valthalak lived in
	what is now The Beast's chamber, in Upper (Mea Culpa, Lord Valthalak, 8995); QuestieDB's raid flag
	is set on 8995, not on 8966 or 8989. So Valthalak's note and his two quests (8995, and Return to
	Bodley, 8996, after it) are Upper's alone, and Mor's note and his two pieces Lower's alone. Each
	half's amulet chains still show the other half's quests as their steps. Where each brazier is used
	is not yet checked on Forever (QuestieDB's spots, objects 181050 and 181046, name no half).

	Loads after FromForeverChanges.lua and QuestAudit.lua, whose quests it amends, and before
	BlackrockDepths.lua, which copies Upper Blackrock Spire's Three Kings of Flame.
]]

local function QuestsOf(key)
	local quests = {}
	for _, quest in ipairs(ns.GetInstance(key).quests) do quests[quest.questID] = quest end
	return quests
end
local lower, upper = QuestsOf("LowerBlackrockSpire"), QuestsOf("UpperBlackrockSpire")

-- A quest's chain as a key's quests: its steps, oldest first, then the quest itself.
local function Chain(quest)
	local ids = {}
	for _, step in ipairs(quest.prerequisites or {}) do ids[#ids + 1] = step.questID end
	ids[#ids + 1] = quest.questID
	return ids
end

-- The notes both halves show. Each half gets its own copy, so the translations are laid over each
-- once.
local function SealOfAscension()
	return {
		title = "The Seal of Ascension",
		-- Vaelan gives and takes both quests (QuestieDB 4742, 4743); the gemstones are Omokk's,
		-- Voone's and Wyrmthalak's drops (the bosses' loot); the plain seal drops from the Spire's
		-- Scarshield, Spirestone, Smolderthorn, Firebrand and Bloodaxe foes and most of its bosses, and
		-- from the Scarshield Quartermaster outside (item 12219's drops).
		text = "Vaelan, the Scarshield Infiltrator inside Lower Blackrock Spire, gives Seal of Ascension from "
			.. "level 57. Bring him the Gemstones of Spirestone, Smolderthorn and Bloodaxe, from Highlord Omokk, "
			.. "War Master Voone and Overlord Wyrmthalak, and the {item:12219:Unadorned Seal of Ascension:1}. Many "
			.. "of the Spire's foes drop it, and so does the Scarshield Quartermaster outside. Vaelan's next quest "
			.. "gives you {item:12339:Vaelan's Gift}. Take it to Emberstrife in the Wyrmbog, in Dustwallow Marsh, "
			.. "beat him down and make him forge the seal. Back at Vaelan, you get the {item:12344:Seal of "
			.. "Ascension}. It opens the door to Upper Blackrock Spire.",
		quests = { 4742, 4743 },
		-- The seal is 4743's reward: the player has it once 4743 is handed in.
		haveWhen = "done",
	}
end
local function Valthalak()
	return {
		title = "Lord Valthalak, a hidden boss",
		-- He has no page of his own. Upper Blackrock Spire's (see the header); where his brazier is
		-- used is not yet checked on Forever.
		boss = "Lord Valthalak",
		text = "Bodley gives you the {item:22056:Brazier of Beckoning} with Mea Culpa, Lord Valthalak, near the "
			.. "end of the amulet's quests. Use it in Blackrock Spire to call him. Kill him, use Lord Valthalak's "
			.. "Amulet on his body, and give the amulet to his spirit.",
	}
end
local function MorGrayhoof()
	return {
		title = "Mor Grayhoof, a hidden boss",
		-- Lower Blackrock Spire's (see the header).
		boss = "Mor Grayhoof",
		text = "Bodley gives you the {item:22049:Brazier of Beckoning} with the Mor Grayhoof versions of The Left "
			.. "Piece and The Right Piece of Lord Valthalak's Amulet. Use it in Blackrock Spire to call his spirit, "
			.. "and kill him for the piece.",
	}
end

--[[
	The Onyxia attunement for one side, as Upper Blackrock Spire and Onyxia's Lair both show it
	(Data/Authored/OnyxiasLair.lua takes it from here: one source for the two). The chain is the
	journal's own, 6502's or 6602's prerequisites then the quest itself, each step checked against
	QuestieDB's Forever data (2026-10-30: every giver, taker, place, level and order; each step needs
	the one before it alone, and Axtroz's Test of Skulls the other three, so no step is a one-of).
	The places in the text are the steps' own (their givers' and takers' maps, and their objectives:
	Lakeshire, Ragged John, the city gates, the drake champions' haunts). Rexxar's spot is unsure
	(QuestieDB Desolace, the journal and the site Feralas), so the text doesn't name it; The
	Champion of the Horde's own words, on its page, say where Thrall tells you to look. What the
	amulet opened is the original game's: no Forever source says it is still needed.
	A new table each call: each dungeon gets its own, so the translations are laid over each once.
]]
local ONYXIA_TEXT = {
	Alliance = "The Alliance chain is long. Helendis Riverhorn in the Burning Steppes starts it with Dragonkin "
		.. "Menace. The True Masters takes you to Lakeshire in Redridge, to Highlord Bolvar in Stormwind and back to "
		.. "Lakeshire, then to Marshal Maxwell in the Burning Steppes, who has you find Ragged John. Maxwell sends you "
		.. "into Blackrock Depths to find Marshal Windsor, who sends you back with bad news. A note found on the "
		.. "Depths' foes sends you back to him: get his lost papers and free him (A Crumpled Up Note, A Shred of Hope, "
		.. "Jail Break!). In Stormwind, meet Windsor at the city gates and keep him alive on his walk to Bolvar "
		.. "(Stormwind Rendezvous, The Great Masquerade). Bolvar's The Dragon's Eye sends you to Haleh in Winterspring. "
		.. "Her quest, Drakefire Amulet, asks for General Drakkisath's blood, in Upper Blackrock Spire. That gives the "
		.. "{item:16309:Drakefire Amulet}. In the original game, the amulet let you into Onyxia's Lair. Whether "
		.. "Forever keeps this is not known yet.",
	Horde = "The Horde chain is long. Warlord Goretooth in Kargath, in the Badlands, starts it with Warlord's "
		.. "Command: kill Highlord Omokk, War Master Voone and Overlord Wyrmthalak in Lower Blackrock Spire and bring "
		.. "back the Important Blackrock Documents. Eitrigg's Wisdom takes you to Eitrigg and Thrall in Orgrimmar. "
		.. "Thrall's For The Horde! asks for Warchief Rend Blackhand's head, in Upper Blackrock Spire. After What the "
		.. "Wind Carries, The Champion of the Horde sends you to find Rexxar. He sends you to Myranda the Hag in the "
		.. "Western Plaguelands, who wants 20 Black Dragonspawn Eyes from Upper Blackrock Spire (Oculus Illusions). Wear "
		.. "her amulet and speak with Emberstrife in his den in the Wyrmbog, in Dustwallow Marsh. His Test of Skulls "
		.. "quests send you after four drake champions: Scryer in Winterspring, Somnus in the Swamp of Sorrows, "
		.. "Chronalis at the Caverns of Time in Tanaris, and last Axtroz at Grim Batol, in the Wetlands. Then show the "
		.. "Dull Drakefire Amulet to Rexxar (Ascension...). His quest, Blood of the Black Dragon Champion, asks for "
		.. "General Drakkisath's blood, in Upper Blackrock Spire. That gives the {item:16309:Drakefire Amulet}. In "
		.. "the original game, the amulet let you into Onyxia's Lair. Whether Forever keeps this is not known yet.",
}
local ONYXIA_QUEST = { Alliance = 6502, Horde = 6602 }
function ns.OnyxiaAttunement(faction)
	return {
		faction = faction,
		title = "Onyxia attunement",
		text = ONYXIA_TEXT[faction],
		-- Dragonkin Menace (4182) to Haleh's Drakefire Amulet (6502); Warlord's Command (4903) to
		-- Rexxar's Blood of the Black Dragon Champion (6602).
		quests = Chain(upper[ONYXIA_QUEST[faction]]),
		-- The amulet is 6502's and 6602's reward.
		haveWhen = "done",
	}
end

ns.AmendInstance("LowerBlackrockSpire", {
	--[[
		Before you go (the overview): the Seal of Ascension, begun here; Urok Doomhowl, and Mor
		Grayhoof, the spirit the amulet's pieces call: the bosses the players call themselves.
	]]
	prepare = {
		SealOfAscension(),
		{
			title = "Urok Doomhowl, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Urok Doomhowl",
			text = "Warosh, inside, gives the quest Urok Doomhowl. Pick up a {item:12533:Roughshod Pike}, take "
				.. "{item:12534:Omokk's Head:1} from Highlord Omokk, and set them up at Urok's Tribute Pile to "
				.. "challenge him. Kill him for Warosh's Mojo.",
		},
		MorGrayhoof(),
	},
})

ns.AmendInstance("UpperBlackrockSpire", {
	--[[
		Before you go (the overview): the Seal of Ascension that opens the door; the raid attunements
		that run through here (Onyxia's for the player's side, Blackwing Lair's), and where Molten
		Core's is; and Lord Valthalak, whom Mea Culpa, Lord Valthalak calls.
	]]
	prepare = {
		SealOfAscension(),
		-- The same as Onyxia's Lair's (ns.OnyxiaAttunement, above).
		ns.OnyxiaAttunement("Alliance"),
		ns.OnyxiaAttunement("Horde"),
		{
			title = "Blackwing Lair attunement",
			text = "The Scarshield Quartermaster, in Blackrock Mountain outside the Spire, drops "
				.. "{item:18987:Blackhand's Command}. The letter starts a quest of the same name: touch Drakkisath's "
				.. "Brand, guarded by General Drakkisath, for the Mark of Drakkisath. In the original game, the mark "
				.. "let you into Blackwing Lair. Whether Forever keeps this is not known yet.",
			quests = { 7761 },
			-- The mark comes as the quest is done, at the brand.
			haveWhen = "done",
		},
		{
			-- Not a key: the attunement itself is Blackrock Depths' note (Data/Authored/BlackrockDepths.lua).
			title = "Molten Core attunement",
			text = "Attunement to the Core, from Lothos Riftwaker in Blackrock Mountain, is done in Blackrock Depths. "
				.. "Here, Duke Hydraxis in Azshara asks for Pyroguard Emberseer's eye with Eye of the Emberseer. That "
				.. "quest leads on into Molten Core but is not the attunement.",
		},
		Valthalak(),
	},
})

--[[
	The amulet's quests, in both halves: each chain in full, its steps any one of several will do
	among them (ns.OneOf; QuestieDB's preQuestSingle, 2026-10-30): your side's Bodley's Unfortunate
	Fate (8960 Alliance, 9032 Horde) before Three Kings of Flame (8961), one of the four Components of
	Importance (8962-8965) before a Left Piece, one of the four Left Pieces (8966-8969) before I See
	Alcaz Island... (8970), one of the four More Components of Importance (8985-8988) before a Right
	Piece, and one of the four Right Pieces (8989-8992) before Final Preparations (8994). The Quests tab
	shows each as one row, done once one of them is, so the notes that named them are gone. Lower
	Blackrock Spire's Left Piece listed only Components of Importance (8962) and its Right Piece only
	I See Alcaz Island...: both take the full chain. Each quest gets its own copy, so the translations
	are laid over each once. Bodley's Unfortunate Fate itself comes after the class's Anthion's Parting
	Words, one for each class: Three Kings of Flame's note says so.
]]
--[[
	The chain's side steps, one quest for each side (QuestieDB's preQuestSingle; the deep audit of
	2026-10-30, X3): A Supernatural Device (8922 Alliance, 8923 Horde) before The Ectoplasmic Distiller
	(8921); after A Shifty Merchant (8928), Return to Deliana or Return to Mokvar (8977, 8978), then In
	Search of Anthion (8929, 8930) before Dead Man's Plea. Laid into every list that holds the chain's
	start (8921 to 8928): Three Kings of Flame's here, which the amulet's quests below copy, and the
	others' that QuestAudit.lua writes out (Dead Man's Plea and Proof of Life in Stratholme, Anthion's
	Old Friend, Falrin's Vendetta and The Instigator's Enchantment in Dire Maul, The Challenge in the
	Depths). The class's own steps between them (An Earnest Proposition, Just Compensation, Anthion's
	Parting Words) stay out of these lists and in notes, as before; since 2026-11-03 each is also a
	class quest of its own (below).
]]
do
	local function Supernatural()
		return ns.OneOf("A Supernatural Device", { questID = 8922, faction = "Alliance" }, { questID = 8923, faction = "Horde" })
	end
	local function ReturnTo()
		return ns.OneOf("Return to Deliana", { questID = 8977, faction = "Alliance" },
			{ questID = 8978, name = "Return to Mokvar", faction = "Horde" })
	end
	local function Anthion()
		return ns.OneOf("In Search of Anthion", { questID = 8929, faction = "Alliance" }, { questID = 8930, faction = "Horde" })
	end
	local keys = { "BlackrockDepths", "LowerBlackrockSpire", "UpperBlackrockSpire", "DireMaulEast", "DireMaulNorth",
		"DireMaulWest", "Scholomance", "StratholmeMainGate", "StratholmeServiceGate" }
	for _, key in ipairs(keys) do
		for _, quest in ipairs(ns.GetInstance(key).quests) do
			local list, distiller, merchant = quest.prerequisites or {}, nil, nil
			for index, step in ipairs(list) do
				if step.questID == 8921 and not step.oneOf then distiller = index end
				if step.questID == 8928 and not step.oneOf then merchant = index end
			end
			if distiller and merchant and merchant > distiller then
				table.insert(list, merchant + 1, Anthion())
				table.insert(list, merchant + 1, ReturnTo())
				table.insert(list, distiller, Supernatural())
			end
		end
	end
end

do
	-- The chain up to The Challenge (9015), as QuestAudit.lua gives Three Kings of Flame, with its side
	-- steps (above). Each copy its own, its one-of steps too.
	local function Copy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for key, field in pairs(value) do copy[key] = Copy(field) end
		return copy
	end
	local start = {}
	for index, step in ipairs(upper[8961].prerequisites) do start[index] = Copy(step) end
	local function Step(questID, name) return function() return { questID = questID, name = name } end end
	local order = {
		function()
			return ns.OneOf("Bodley's Unfortunate Fate", { questID = 8960, level = 60, faction = "Alliance" },
				{ questID = 9032, level = 60, faction = "Horde" })
		end,
		Step(8961, "Three Kings of Flame"),
		function() return ns.OneOf("Components of Importance", 8962, 8963, 8964, 8965) end,
		function() return ns.OneOf("The Left Piece of Lord Valthalak's Amulet", 8966, 8967, 8968, 8969) end,
		Step(8970, "I See Alcaz Island In Your Future..."),
		function() return ns.OneOf("More Components of Importance", 8985, 8986, 8987, 8988) end,
		function() return ns.OneOf("The Right Piece of Lord Valthalak's Amulet", 8989, 8990, 8991, 8992) end,
		Step(8994, "Final Preparations"),
		Step(8995, "Mea Culpa, Lord Valthalak"),
	}
	-- How many of those steps come before each quest.
	local before = { [8961] = 1, [8966] = 3, [8989] = 6, [8994] = 7, [8995] = 8, [8996] = 9 }
	local function AmuletChain(questID)
		local chain = {}
		for index, step in ipairs(start) do chain[index] = Copy(step) end
		for index = 1, before[questID] do chain[#chain + 1] = order[index]() end
		return chain
	end
	for questID in pairs(before) do
		for _, quests in ipairs({ lower, upper }) do
			if quests[questID] then quests[questID].prerequisites = AmuletChain(questID) end
		end
	end
	local fate = "Bodley's Unfortunate Fate comes after your class's Anthion's Parting Words."
	upper[8961].note = fate
	for _, quests in ipairs({ lower, upper }) do
		quests[8966].note = nil
		quests[8989].note = nil
		quests[8994].note = nil
	end
end

--[[
	The chain's class steps, one quest for each class and side (QuestieDB's Forever data; the owner's
	call of 2026-11-03 on the deep audit's X3: "if its a class quest involving a dungeon lets keep it
	like the others"): An Earnest Proposition (8905-8920), before A Supernatural Device; Just
	Compensation (8926, 8927, 8931-8944), after Return to Deliana or Return to Mokvar and before In
	Search of Anthion; Anthion's Parting Words (8951-8959, 9016-9022), after The Challenge and before
	Bodley's Unfortunate Fate. Each is a class quest on every page that holds the chain, so the Quests
	tab lists it under Class Quests for its class and side alone, locked until the steps before it for
	its side are done (QuestieDB's requiredAncestry, with the class's own step before it). The chain's
	own lists still leave them out (their steps are one per class), so its rows lock as before;
	Dead Man's Plea's note still names them. QuestieDB has none for Horde paladins or Alliance shamans
	(an in-game check). Its objectives, word for word, but for three slips mended: "Gloves Deliana"
	(8926), "1 set of" (8909) and "Orgimmar" (the Horde's Anthion's Parting Words). None has rewards:
	QuestieDB gives none, and the site's pages for them are unread.
]]
do
	local EARNEST = {
		{ 8905, "Alliance", "DRUID", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Wildheart Bracers to Deliana in Ironforge." },
		{ 8906, "Alliance", "HUNTER", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Beaststalker's Bindings to Deliana in Ironforge." },
		{ 8907, "Alliance", "MAGE", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Magister's Bindings to Deliana in Ironforge." },
		{ 8908, "Alliance", "PALADIN", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Lightforge Bracers to Deliana in Ironforge." },
		{ 8909, "Alliance", "PRIEST", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Devout Bracers to Deliana in Ironforge." },
		{ 8910, "Alliance", "ROGUE", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Shadowcraft Bracers to Deliana in Ironforge." },
		{ 8911, "Alliance", "WARLOCK", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Dreadmist Bracers to Deliana in Ironforge." },
		{ 8912, "Alliance", "WARRIOR", "Acquire 15 Winterspring Blood Samples and 20 gold and bring them along with a set of Bracers of Valor to Deliana in Ironforge." },
		{ 8913, "Horde", "DRUID", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Wildheart Bracers to Mokvar in Orgrimmar." },
		{ 8914, "Horde", "HUNTER", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Beaststalker's Bindings to Mokvar in Orgrimmar." },
		{ 8915, "Horde", "MAGE", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Magister's Bindings to Mokvar in Orgrimmar." },
		{ 8916, "Horde", "PRIEST", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Devout Bracers to Mokvar in Orgrimmar." },
		{ 8917, "Horde", "ROGUE", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Shadowcraft Bracers to Mokvar in Orgrimmar." },
		{ 8918, "Horde", "SHAMAN", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Bindings of Elements to Mokvar in Orgrimmar." },
		{ 8919, "Horde", "WARLOCK", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Dreadmist Bracers to Mokvar in Orgrimmar." },
		{ 8920, "Horde", "WARRIOR", "Acquire 15 Silithus Venom Samples and 20 gold and bring them along with a set of Bracers of Valor to Mokvar in Orgrimmar." },
	}
	local COMPENSATION = {
		{ 8926, "Alliance", "DRUID", "Bring a Wildheart Belt and a set of Wildheart Gloves to Deliana in Ironforge." },
		{ 8931, "Alliance", "HUNTER", "Bring a Beaststalker's Belt and a set of Beaststalker's Gloves to Deliana in Ironforge." },
		{ 8932, "Alliance", "MAGE", "Bring a Magister's Belt and a set of Magister's Gloves to Deliana in Ironforge." },
		{ 8933, "Alliance", "PALADIN", "Bring a Lightforge Belt and a set of Lightforge Gauntlets to Deliana in Ironforge." },
		{ 8934, "Alliance", "PRIEST", "Bring a Devout Belt and a set of Devout Gloves to Deliana in Ironforge." },
		{ 8935, "Alliance", "ROGUE", "Bring a Shadowcraft Belt and a set of Shadowcraft Gloves to Deliana in Ironforge." },
		{ 8936, "Alliance", "WARLOCK", "Bring a Dreadmist Belt and a set of Dreadmist Wraps to Deliana in Ironforge." },
		{ 8937, "Alliance", "WARRIOR", "Bring a Belt of Valor and a set of Gauntlets of Valor to Deliana in Ironforge." },
		{ 8927, "Horde", "DRUID", "Bring a Wildheart Belt and a set of Wildheart Gloves to Mokvar in Orgrimmar." },
		{ 8938, "Horde", "HUNTER", "Bring a Beaststalker's Belt and a set of Beaststalker's Gloves to Mokvar in Orgrimmar." },
		{ 8939, "Horde", "MAGE", "Bring a Magister's Belt and a set of Magister's Gloves to Mokvar in Orgrimmar." },
		{ 8940, "Horde", "PRIEST", "Bring a Devout Belt and a set of Devout Gloves to Mokvar in Orgrimmar." },
		{ 8941, "Horde", "ROGUE", "Bring a Shadowcraft Belt and a set of Shadowcraft Gloves to Mokvar in Orgrimmar." },
		{ 8942, "Horde", "SHAMAN", "Bring a Cord of Elements and a set of Gauntlets of Elements to Mokvar in Orgrimmar." },
		{ 8943, "Horde", "WARLOCK", "Bring a Dreadmist Belt and a set of Dreadmist Wraps to Mokvar in Orgrimmar." },
		{ 8944, "Horde", "WARRIOR", "Bring a Belt of Valor and a set of Gauntlets of Valor to Mokvar in Orgrimmar." },
	}
	local PARTING = {
		{ 8951, "Alliance", "DRUID", "Return to Deliana in Ironforge with a set of Wildheart Boots, a Wildheart Kilt and Wildheart Spaulders." },
		{ 8952, "Alliance", "HUNTER", "Return to Deliana in Ironforge with a set of Beaststalker's Boots, Beaststalker's Pants and Beaststalker's Mantle." },
		{ 8953, "Alliance", "MAGE", "Return to Deliana in Ironforge with a set of Magister's Boots, Magister's Leggings and Magister's Mantle." },
		{ 8954, "Alliance", "PALADIN", "Return to Deliana in Ironforge with a set of Lightforge Boots, Lightforge Legplates and Lightforge Spaulders." },
		{ 8955, "Alliance", "PRIEST", "Return to Deliana in Ironforge with a set of Devout Sandals, Devout Skirt and Devout Mantle." },
		{ 8956, "Alliance", "ROGUE", "Return to Deliana in Ironforge with a set of Shadowcraft Boots, Shadowcraft Pants and Shadowcraft Spaulders." },
		{ 8958, "Alliance", "WARLOCK", "Return to Deliana in Ironforge with a set of Dreadmist Sandals, Dreadmist Leggings and Dreadmist Mantle." },
		{ 8959, "Alliance", "WARRIOR", "Return to Deliana in Ironforge with a set of Boots of Valor, Legplates of Valor and Spaulders of Valor." },
		{ 9016, "Horde", "DRUID", "Return to Mokvar in Orgrimmar with a set of Wildheart Boots, a Wildheart Kilt and Wildheart Spaulders." },
		{ 9017, "Horde", "HUNTER", "Return to Mokvar in Orgrimmar with a set of Beaststalker's Boots, Beaststalker's Pants and Beaststalker's Mantle." },
		{ 9018, "Horde", "MAGE", "Return to Mokvar in Orgrimmar with a set of Magister's Boots, Magister's Leggings and Magister's Mantle." },
		{ 9019, "Horde", "PRIEST", "Return to Mokvar in Orgrimmar with a set of Devout Sandals, Devout Skirt and Devout Mantle." },
		{ 9020, "Horde", "ROGUE", "Return to Mokvar in Orgrimmar with a set of Shadowcraft Boots, Shadowcraft Pants and Shadowcraft Spaulders." },
		{ 8957, "Horde", "SHAMAN", "Return to Mokvar in Orgrimmar with a set of Boots of Elements, Kilt of Elements and Pauldrons of Elements." },
		{ 9021, "Horde", "WARLOCK", "Return to Mokvar in Orgrimmar with a set of Dreadmist Sandals, Dreadmist Leggings and Dreadmist Mantle." },
		{ 9022, "Horde", "WARRIOR", "Return to Mokvar in Orgrimmar with a set of Boots of Valor, Legplates of Valor and Spaulders of Valor." },
	}
	local DELIANA = { mapID = 1455, x = 0.435, y = 0.526, label = "Deliana" }
	local MOKVAR = { mapID = 1454, x = 0.35, y = 0.383, label = "Mokvar" }
	local ANTHION = { mapID = 1423, x = 0.261, y = 0.113, label = "Anthion Harmon" }
	local SIDES = {
		Alliance = { giver = "Deliana, Ironforge", map = DELIANA, device = 8922, back = { 8977, "Return to Deliana" },
			search = 8929 },
		Horde = { giver = "Mokvar, Orgrimmar", map = MOKVAR, device = 8923, back = { 8978, "Return to Mokvar" },
			search = 8930 },
	}
	local function Copy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for key, field in pairs(value) do copy[key] = Copy(field) end
		return copy
	end
	-- Each class's three, with the steps before each for its side.
	local quests = {}
	local function Add(row, name, pickup, startMap, prerequisites)
		local side = SIDES[row[2]]
		quests[#quests + 1] = {
			questID = row[1], name = name, level = 60, requiredLevel = 58, faction = row[2], classOnly = row[3],
			objective = row[4], pickup = pickup, startMap = startMap, turnin = side.giver, endMap = side.map,
			prerequisites = prerequisites,
		}
	end
	local earnest = {}
	for _, row in ipairs(EARNEST) do
		earnest[row[2] .. row[3]] = row[1]
		local side = SIDES[row[2]]
		Add(row, "An Earnest Proposition", side.giver, side.map, nil)
	end
	local compensation = {}
	for _, row in ipairs(COMPENSATION) do
		compensation[row[2] .. row[3]] = row[1]
		local side = SIDES[row[2]]
		Add(row, "Just Compensation", side.giver, side.map, {
			{ questID = earnest[row[2] .. row[3]], name = "An Earnest Proposition" },
			{ questID = side.device, name = "A Supernatural Device" },
			{ questID = 8921, name = "The Ectoplasmic Distiller" },
			{ questID = 8924, name = "Hunting for Ectoplasm" },
			{ questID = 8925, name = "A Portable Power Source" },
			{ questID = 8928, name = "A Shifty Merchant" },
			{ questID = side.back[1], name = side.back[2] },
		})
	end
	for _, row in ipairs(PARTING) do
		local side = SIDES[row[2]]
		Add(row, "Anthion's Parting Words", "Anthion Harmon, Eastern Plaguelands", ANTHION, {
			{ questID = earnest[row[2] .. row[3]], name = "An Earnest Proposition" },
			{ questID = side.device, name = "A Supernatural Device" },
			{ questID = 8921, name = "The Ectoplasmic Distiller" },
			{ questID = 8924, name = "Hunting for Ectoplasm" },
			{ questID = 8925, name = "A Portable Power Source" },
			{ questID = 8928, name = "A Shifty Merchant" },
			{ questID = side.back[1], name = side.back[2] },
			{ questID = compensation[row[2] .. row[3]], name = "Just Compensation" },
			{ questID = side.search, name = "In Search of Anthion" },
			{ questID = 8945, name = "Dead Man's Plea" },
			{ questID = 8946, name = "Proof of Life" },
			{ questID = 8947, name = "Anthion's Strange Request" },
			{ questID = 8948, name = "Anthion's Old Friend" },
			{ questID = 8949, name = "Falrin's Vendetta" },
			{ questID = 8950, name = "The Instigator's Enchantment" },
			{ questID = 9015, name = "The Challenge" },
		})
	end
	-- The pages that hold the chain: each its own copies, so the translations are laid over each once.
	for _, key in ipairs({ "BlackrockDepths", "LowerBlackrockSpire", "UpperBlackrockSpire", "DireMaulEast",
		"DireMaulNorth", "DireMaulWest", "Scholomance", "StratholmeMainGate", "StratholmeServiceGate" }) do
		ns.AmendInstance(key, { addQuests = Copy(quests) })
	end
end

--[[
	Saving the Best for Last (8999-9006 Alliance, 9007-9014 Horde), the Tier 0.5 chain's last step, one for
	each class and side: the owner's call of 2026-11-03 (a chain's last steps at the same giver stay as
	quests, and the chain's class steps are class quests). QuestieDB's Forever data: each needs Back to the
	Beginning for its side (8997 Alliance, 8998 Horde), which Bodley gives after Return to Bodley (8996) and
	which sends you to Deliana or Mokvar; Deliana or Mokvar gives and takes it; it asks for the class's
	Tier 0 helm, which Darkmaster Gandling drops in Scholomance, and chest, which General Drakkisath drops in
	Upper Blackrock Spire. So it is on those two pages, not on Lower Blackrock Spire, under Class Quests for
	its class and side alone, locked until Back to the Beginning and the steps before it (Return to Bodley's)
	are done. Its objectives are QuestieDB's, word for word. Its rewards are foreverchanges.pro's quest
	pages' (2026-11-03): the class's Tier 0.5 helm and chest, and 1,650 XP, the original game's (the pages
	call the quests unchanged). None for Alliance shamans or Horde paladins, as for the chain's other class
	steps. Back to the Beginning is a step of its own (Data/Generated/QuestSteps.lua).
]]
do
	local BEST = {
		{ 8999, "Alliance", "DRUID", "Give Deliana your Wildheart Cowl and Wildheart Vest.", { 22109, "Feralheart Cowl" }, { 22113, "Feralheart Vest" } },
		{ 9000, "Alliance", "HUNTER", "Give Deliana your Beaststalker's Cap and Beaststalker's Tunic.", { 22013, "Beastmaster's Cap" }, { 22060, "Beastmaster's Tunic" } },
		{ 9001, "Alliance", "MAGE", "Give Deliana your Magister's Crown and Magister's Robes.", { 22065, "Sorcerer's Crown" }, { 22069, "Sorcerer's Robes" } },
		{ 9002, "Alliance", "PALADIN", "Give Deliana your Lightforge Helm and Lightforge Breastplate.", { 22091, "Soulforge Helm" }, { 22089, "Soulforge Breastplate" } },
		{ 9003, "Alliance", "PRIEST", "Give Deliana your Devout Crown and Devout Robe.", { 22080, "Virtuous Crown" }, { 22083, "Virtuous Robe" } },
		{ 9004, "Alliance", "ROGUE", "Give Deliana your Shadowcraft Cap and Shadowcraft Tunic.", { 22005, "Darkmantle Cap" }, { 22009, "Darkmantle Tunic" } },
		{ 9005, "Alliance", "WARLOCK", "Give Deliana your Dreadmist Mask and Dreadmist Robe.", { 22074, "Deathmist Mask" }, { 22075, "Deathmist Robe" } },
		{ 9006, "Alliance", "WARRIOR", "Give Deliana your Helm of Valor and Breastplate of Valor.", { 21999, "Helm of Heroism" }, { 21997, "Breastplate of Heroism" } },
		{ 9007, "Horde", "DRUID", "Give Mokvar your Wildheart Cowl and Wildheart Vest.", { 22109, "Feralheart Cowl" }, { 22113, "Feralheart Vest" } },
		{ 9008, "Horde", "HUNTER", "Give Mokvar your Beaststalker's Cap and Beaststalker's Tunic.", { 22013, "Beastmaster's Cap" }, { 22060, "Beastmaster's Tunic" } },
		{ 9014, "Horde", "MAGE", "Give Mokvar your Magister's Crown and Magister's Robes.", { 22065, "Sorcerer's Crown" }, { 22069, "Sorcerer's Robes" } },
		{ 9009, "Horde", "PRIEST", "Give Mokvar your Devout Crown and Devout Robe.", { 22080, "Virtuous Crown" }, { 22083, "Virtuous Robe" } },
		{ 9010, "Horde", "ROGUE", "Give Mokvar your Shadowcraft Cap and Shadowcraft Tunic.", { 22005, "Darkmantle Cap" }, { 22009, "Darkmantle Tunic" } },
		{ 9011, "Horde", "SHAMAN", "Give Mokvar your Coif of Elements and Vest of Elements.", { 22097, "Coif of The Five Thunders" }, { 22102, "Vest of The Five Thunders" } },
		{ 9012, "Horde", "WARLOCK", "Give Mokvar your Dreadmist Mask and Dreadmist Robe.", { 22074, "Deathmist Mask" }, { 22075, "Deathmist Robe" } },
		{ 9013, "Horde", "WARRIOR", "Give Mokvar your Helm of Valor and Breastplate of Valor.", { 21999, "Helm of Heroism" }, { 21997, "Breastplate of Heroism" } },
	}
	local SIDES = {
		Alliance = { giver = "Deliana, Ironforge", map = { mapID = 1455, x = 0.435, y = 0.526, label = "Deliana" },
			back = 8997 },
		Horde = { giver = "Mokvar, Orgrimmar", map = { mapID = 1454, x = 0.35, y = 0.383, label = "Mokvar" }, back = 8998 },
	}
	local NOTES = {
		UpperBlackrockSpire = "General Drakkisath drops the chest here. Darkmaster Gandling in Scholomance drops the helm.",
		Scholomance = "Darkmaster Gandling drops the helm here. General Drakkisath in Upper Blackrock Spire drops the chest.",
	}
	local function Copy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for key, field in pairs(value) do copy[key] = Copy(field) end
		return copy
	end
	local bodley = upper[8996]
	for _, key in ipairs({ "UpperBlackrockSpire", "Scholomance" }) do
		local quests = {}
		for _, row in ipairs(BEST) do
			local side = SIDES[row[2]]
			local prerequisites = Copy(bodley.prerequisites)
			prerequisites[#prerequisites + 1] = { questID = 8996, name = "Return to Bodley" }
			prerequisites[#prerequisites + 1] = { questID = side.back, name = "Back to the Beginning" }
			quests[#quests + 1] = {
				questID = row[1], name = "Saving the Best for Last", level = 60, requiredLevel = 58, faction = row[2],
				classOnly = row[3], objective = row[4], pickup = side.giver, startMap = Copy(side.map),
				turnin = side.giver, endMap = Copy(side.map), note = NOTES[key], prerequisites = prerequisites,
				rewards = {
					xp = 1650,
					items = {
						{ itemID = row[5][1], name = row[5][2], quality = 4 },
						{ itemID = row[6][1], name = row[6][2], quality = 4 },
					},
				},
			}
		end
		ns.AmendInstance(key, { addQuests = quests })
	end
end

-- Warlord's Command also starts from Warlord Goretooth's Command (where it drops is not known).
lower[4903].startItem = { itemID = 12563, name = "Warlord Goretooth's Command" }

-- Snakestone of the Shadow Huntress gives the plans for Dawn's Edge.
lower[5306].rewards = lower[5306].rewards or {}
lower[5306].rewards.items = { { itemID = 12821, name = "Plans: Dawn's Edge" } }

-- The Demon Forge gives 5 Elixirs of Demonslaying with the plans and the sack (the count is the site's).
do
	local items = upper[5127].rewards.items
	items[#items + 1] = { itemID = 9224, name = "Elixir of Demonslaying", count = 5 }
end

-- Who can do The Demon Forge: Lorax's Tale (5126) comes first, for warrior, paladin and shaman
-- blacksmiths (QuestieDB's requiredClasses 67, Blacksmithing 270); the step's page says so too.
do
	local who = "For warrior, paladin and shaman blacksmiths with a skill of 270."
	upper[5127].note = who .. " Lorax's Tale comes first."
	local step = ns.GetQuestStep(5126)
	if step then step.note = who end
end

-- Oculus Illusions is Upper Blackrock Spire's (the deep audit of 2026-10-30, g06-5): moved there,
-- before Blood of the Black Dragon Champion, so the Horde's Onyxia chain names Upper.
do
	local oculus = lower[6569]
	ns.AmendInstance("LowerBlackrockSpire", { removeQuests = { 6569 } })
	local list = ns.GetInstance("UpperBlackrockSpire").quests
	local at = #list + 1
	for index, quest in ipairs(list) do
		if quest.questID == 6602 then at = index end
	end
	table.insert(list, at, oculus)
	lower[6569], upper[6569] = nil, oculus
end

-- What follows outside the dungeon (QuestieDB's preQuestSingle; the deep audit of 2026-10-30, g06-9).
upper[5047].note = "Then Malyfous's Catalogue, in Everlook, offers Cap of the Scarlet Savant, Leggings of Arcana "
	.. "and Breastplate of Bloodthirst. Each needs a Pristine Hide of the Beast."
upper[4735].followUp = "Tinkee then sends you to Leonid Barthalomew in the Eastern Plaguelands. The chain goes on to "
	.. "Dawn's Gambit in Scholomance."

-- What follows on the other half, or outside (QuestieDB's nextQuestInChain; the owner's calls of
-- 2026-11-03): Warlord's Command (4903) to Eitrigg's Wisdom (4941) and For The Horde! (4974, Upper's),
-- as the Alliance's Jail Break! names Stormwind Rendezvous; General Drakkisath's Command (5089) to
-- General Drakkisath's Demise (5102, Upper's); Final Preparations (8994) to Mea Culpa, Lord Valthalak
-- (8995, Upper's alone since 11-03), on Lower only; The Matron Protectorate (5160, Upper's alone since
-- 2026-11-05, below) to Wrath of the Blue Flight (5161, 5162, Haleh's) and Jeziba's Catalogue of the
-- Wayward (5164), then Breastplate of the Chromatic Flight (5166) and Legplates of the Chromatic Defier
-- (5167), both offered by the Catalogue (object 176192) and handed to Jeziba, both after 5164 and each
-- asking for Gyth's Chromatic Carapace (12871) and 10 Brilliant Chromatic Scales from Upper's dragonspawn
-- (Forever's quest data, and a second guide's chain; 2026-11-05); Eye of the Emberseer (6821) to The Molten Core
-- (6822). Lower's Message to Maxwell (5002) lists Maxwell's Mission (5081) after it.
lower[4903].followUp = "Then Warlord Goretooth gives Eitrigg's Wisdom, which takes you to Orgrimmar. The chain goes on to "
	.. "For The Horde! in Upper Blackrock Spire, then to the Onyxia attunement."
lower[5089].followUp = "Then Marshal Maxwell gives General Drakkisath's Demise, done in Upper Blackrock Spire."
lower[8994].followUp = "Then Bodley gives Mea Culpa, Lord Valthalak, done in Upper Blackrock Spire."
upper[5160].followUp = "Then Haleh, in Winterspring, gives Wrath of the Blue Flight. The chain goes on to Jeziba in "
	.. "Andorhal, whose Catalogue of the Wayward offers Breastplate of the Chromatic Flight and Legplates of the "
	.. "Chromatic Defier. Each needs Gyth's Chromatic Carapace and 10 Brilliant Chromatic Scales from Upper Blackrock "
	.. "Spire."
upper[6821].followUp = "Then Duke Hydraxis gives The Molten Core, done in Molten Core."

-- Lord Valthalak's quests are Upper Blackrock Spire's alone, and Mor Grayhoof's pieces Lower's (the
-- owner's call of 2026-11-03; see the header): each out of the other half, whose amulet chains (built
-- above) still show them as their steps. Lower's Final Preparations and Upper's other amulet quests stay.
ns.AmendInstance("LowerBlackrockSpire", { removeQuests = { 8995, 8996 } })
ns.AmendInstance("UpperBlackrockSpire", { removeQuests = { 8966, 8989 } })
lower[8995], lower[8996], upper[8966], upper[8989] = nil, nil, nil, nil

-- The quest check of 2026-11-05 (the owner's calls of that day). The Matron Protectorate is Upper's
-- alone: Awbee stands on Upper's ledge just past Gyth and Rend (the original game's, and a second
-- guide's on both sides; the quest data gives npc 10740 no spot). Lower's own quests are Lower's alone:
-- Kibler's Exotic Pets (4729), The Final Tablets (4788), En-Ay-Es-Tee-Why (4862), Mother's Milk (4866),
-- Bijou's four (4981, 4982, 4983, 5001) and Message to Maxwell (5002) are done on Lower's floors (their
-- objectives: the worg pups, Mother Smolderweb, Bijou's stash), none has the quest data's raid flag, a second
-- guide files them under Lower alone, and Lower's quests need a group of 5 or
-- fewer (the door's note), so an Upper group can't finish them. Lower keeps them all, with their notes
-- and follow-ups, and the chains that name them as steps find them there.
ns.AmendInstance("LowerBlackrockSpire", { removeQuests = { 5160 } })
ns.AmendInstance("UpperBlackrockSpire", { removeQuests = { 4729, 4788, 4862, 4866, 4981, 4982, 4983, 5001, 5002 } })
lower[5160] = nil
for _, questID in ipairs({ 4729, 4788, 4862, 4866, 4981, 4982, 4983, 5001, 5002 }) do upper[questID] = nil end

-- Pip Quickwit, At Your Service! from level 55, as QuestieDB's Forever data says. The site's quest
-- page and its Spire list now say 57 (as the 2026-10-16 pass in FromForeverChanges.lua set it), so
-- the two disagree: the level stays as the journal had it, on the audit's unsure list for the Upper
-- Spire, until it is seen in game.
upper[5047].requiredLevel = 55

-- Confront Yeh'kinya is done in Tanaris, after the Spire's The Final Tablets: out of both halves,
-- and its rewards named on the quest before it (QuestieDB 8181; the site's quest page for the choice).
-- It stays out: the owner's call of 2026-11-03. The Final Tablets is Lower's alone since 2026-11-05
-- (above), so the note is on Lower's.
do
	local note = "After this, Prospector Ironboot sends you to Yeh'kinya in Tanaris with Confront Yeh'kinya, "
		.. "which gives a choice of Faded Hakkari Cloak or Tattered Hakkari Cape."
	ns.AmendInstance("LowerBlackrockSpire", { removeQuests = { 8181 }, questPatches = { [4788] = { note = note } } })
	ns.AmendInstance("UpperBlackrockSpire", { removeQuests = { 8181 } })
end
