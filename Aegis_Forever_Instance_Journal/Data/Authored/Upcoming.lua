local _, ns = ...

--[[
	Forever's announced dungeons that no source covers yet: placeholders with what Blizzard has
	said about them (level range, place, setting), marked untested. Their bosses, loot, map and
	entrance arrive as runs are recorded with the Record tab, or as the sources catch up.

	Facts from the dungeon announcements as summarised by classicwow.gg ("World of Warcraft:
	Forever Dungeons") and Warcraft Tavern ("Dungeons - WoW Forever"), in our own words.

	Each ends with a "coming soon" box and our Discord link, for anyone who records a run.
]]

--[[
	A picture of its own (`picture`, a file of Media/Dungeons): the game's loading screen for the dungeon, as the
	owner gave it (2026-11-08; Alcaz Prison's, Krol'dok Stronghold's and Blackmaw Hold's 2026-11-10), cut to 2:1
	(ns.UseDungeonPicture). Without one, the journal's placeholder picture.
]]
local function Placeholder(instance)
	instance.kind = "dungeon"
	instance.untested = true
	instance.forever = true
	if instance.picture then
		local picture = instance.picture
		instance.picture = nil
		ns.UseDungeonPicture(instance, picture, instance.iconArtCoords)
	end
	ns.AddInstance(instance)
end

--[[
	Maps: Santiago Reyes's own (Atlas de Azeroth: Forever, released 2026-11-08), used on his terms
	(CREDITS.md), converted to Media/Maps like his others. No boss spots yet: they come as runs
	are recorded. Boss lists (2026-11-08): the names in the game's files as foreverchanges.pro
	shows them; The Drowned City's in the order a players' guide gives, and Var'Taka as quest
	95776 names her. Nobody has run these yet, so names, order and count can still change.
]]
local MAPS = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\Maps\\"
local PICTURE = 683 / 1024

local function Bosses(names)
	local list = {}
	for order, entry in ipairs(names) do
		local boss = type(entry) == "table" and entry or { name = entry }
		boss.order = order
		list[order] = boss
	end
	return list
end

-- A rare drop seen in game, its item checked in the game's data (foreverchanges.pro's item pages).
local function Seen(itemID, name, slot, droppedBy)
	return { itemID = itemID, name = name, slot = slot, quality = 3, droppedBy = droppedBy }
end

-- A quest item (or key) a boss drops, its colour the game's (foreverchanges.pro's item pages).
local function QuestItem(itemID, name, quality, slot)
	return { itemID = itemID, name = name, slot = slot or "Quest", quality = quality or 1 }
end

Placeholder({
	key = "TheDrownedCity",
	name = "The Drowned City",
	picture = "TheDrownedCity",
	-- The sunken gate and its stairs, on the left of the picture: the square icon is cut around them.
	iconArtCoords = { 0.05, 0.55, 0, 1 },
	levelMin = 35, levelMax = 40,
	location = "Coast of Stranglethorn Vale",
	description = "A troll city that sank into the ocean long ago has risen again, and naga, pirates and stranger "
		.. "things from the deep have claimed its streets.",
	-- The way in, the fights and the drops seen so far: from a players' guide to the dungeon (2026-11-08), facts
	-- only, in our own words; its early reports, so they can change. Only the drops players saw are listed.
	location = "Sunken Hollow, under the sea west of the Vile Reef, Stranglethorn Vale",
	zoneEntrance = { mapID = 1434, x = 0.214, y = 0.278 },
	bosses = Bosses({
		{ name = "Zul'Alai", notes = {
			"An undead troll who enrages near the end of the fight and hits the whole group hard: save cooldowns for then, and keep everyone topped up before he gets low.",
		}, loot = { Seen(274600, "Berserker Shackles", "Wrist, Mail") } },
		{ name = "Var'Taka", notes = {
			"The Brinescale naga's leader. Two Brinescale Priestesses fight beside the boss and heal it: kill or crowd-control them first. Naga are humanoids, so Polymorph and Sap work.",
		}, loot = { Seen(274602, "Brinebelly Leggings", "Legs, Leather") } },
		{ name = "Captain Dreadrise", notes = {
			"Captain of the Saltseer pirates whose ship crashed into the city. His abilities are not recorded yet.",
		}, loot = { Seen(274604, "Frosty Blunderbuss", "Ranged, Gun"), Seen(274605, "Briny Sash", "Waist, Cloth") } },
		{ name = "Deathless Marrow", notes = {
			"One fight with the Primeval Elemental, in a flooded tomb guarded by Deathless Guardians and Deathless Sorcerers.",
			"The Primeval Elemental drops the Ancient Gurubashi Idol, for the Horde's Ancient Gurubashi Idol and the Alliance's Ancient Gurubashi Secrets.",
		}, loot = { Seen(274606, "Bloodspine Staff", "Two-Hand, Staff"),
			Seen(274612, "Waterlogged Burial Shroud", "Back", "Primeval Elemental") } },
		{ name = "Gill", notes = { "An elemental with a fight of its own. Nothing about it is recorded yet." } },
		{ name = "Min'loth the Serpent", notes = {
			"The last boss. A storm gathers over the city during the run, just before this fight.",
		}, loot = { Seen(274610, "Ritual-Binder's Gloves", "Hands, Leather") } },
	}),
	map = { floors = {
		{ art = MAPS .. "TheDrownedCity", artBottom = PICTURE },
		{ art = MAPS .. "TheDrownedCityAtalbyzal", artBottom = PICTURE },
	} },
	floorNames = { "The Drowned City", "Atal'byzal" },
})

Placeholder({
	key = "KroldokStronghold",
	name = "Krol'dok Stronghold",
	picture = "KroldokStronghold",
	-- The spiked gate, a little right of the middle: the square icon is cut around it.
	iconArtCoords = { 0.29, 0.79, 0, 1 },
	levelMin = 40, levelMax = 45,
	location = "Riverglades",
	description = "An ogre stronghold packed with warriors, where the Twilight's Hammer has found willing allies.",
	bosses = Bosses({ "Slavecrusher Grox", "Twilight Commander Zarmok", "Handler Ashka", "Nar'gurk", "Overseer Mugg" }),
	map = { floors = { { art = MAPS .. "KroldokStronghold", artBottom = PICTURE } } },
	--[[
		The Krol'dok Compound Key, one chain for each side (2026-11-08, read by hand from the quests' own pages,
		facts only): a Krol'dok Moulding starts the first quest; the smith its second quest's text is, who takes
		the moulding, makes the key. The moulding drops from Tunk, the blacksmith in Krol'dok, when he is killed: a
		player's report on the journal's Discord (Obsolete, 2026-11-08; the kill confirmed through the owner,
		2026-11-09), the item's own source still blank on its Wowhead page (2026-11-09), which has Tunk (npc 259256)
		as an elite blacksmith and each side's moulding as party loot: everyone in the group gets one. What the key
		opens is not known yet. Their quests are step pages (below), not rows: they are done outside.
	]]
	prepare = {
		{
			faction = "Alliance",
			title = "The Krol'dok Compound Key",
			kind = "key",
			text = "A {item:267138:Krol'dok Moulding} starts Krol'dok Moulding. Tunk, the blacksmith in Krol'dok, drops "
				.. "it when killed, one for everyone in the group. Take it to "
				.. "Alphonse Dumas in Farholde Keep, in the Riverglades, who makes the {item:267089:Krol'dok Compound Key} from "
				.. "4 Thick Leather and 12 Iron Bars. What it opens is not known yet.",
			quests = { 94980, 94981 },
			-- The key is 94981's reward: the player has it once 94981 is handed in.
			haveWhen = "done",
		},
		{
			faction = "Horde",
			title = "The Krol'dok Compound Key",
			kind = "key",
			text = "A {item:267137:Krol'dok Moulding} starts Krol'dok Moulding. Tunk, the blacksmith in Krol'dok, drops "
				.. "it when killed, one for everyone in the group. Take it to "
				.. "Kreza Darkthorn in Rog'mar, in the Riverglades, who makes the {item:267089:Krol'dok Compound Key} from "
				.. "4 Thick Leather and 12 Iron Bars. What it opens is not known yet.",
			quests = { 94973, 94974 },
			haveWhen = "done",
		},
	},
})

-- The key's quests, as steps' pages (spots from Forever's quest data, the Riverglades map).
local function Riverglades(x, y, label) return { mapID = 2548, x = x, y = y, label = label } end
-- Where the moulding comes from (a player's report: the note above Krol'dok Stronghold's key).
local TUNK = "Drops from Tunk, the blacksmith in Krol'dok, when he is killed: one for everyone in the group."
ns.AddQuestSteps({
	[94980] = {
		name = "Krol'dok Moulding", level = 41, requiredLevel = 38, faction = "Alliance",
		startItem = { itemID = 267138, name = "Krol'dok Moulding", note = TUNK },
		objective = "Find someone in Farholde Keep who may know about the mould.",
		turnin = "Alphonse Dumas, Farholde Keep, Riverglades", endMap = Riverglades(0.644, 0.8202, "Alphonse Dumas"),
		note = "It can't be shared.",
		rewards = { money = 5500 },
	},
	[94981] = {
		name = "Key Ingredients", level = 41, requiredLevel = 38, faction = "Alliance",
		pickup = "Alphonse Dumas, Farholde Keep, Riverglades", turnin = "Alphonse Dumas, Farholde Keep, Riverglades",
		startMap = Riverglades(0.644, 0.8202, "Alphonse Dumas"), endMap = Riverglades(0.644, 0.8202, "Alphonse Dumas"),
		objective = "Bring 4 Thick Leather and 12 Iron Bars to Alphonse Dumas.",
		rewards = { money = 5500, items = { { itemID = 267089, name = "Krol'dok Compound Key" } } },
	},
	[94973] = {
		name = "Krol'dok Moulding", level = 41, requiredLevel = 38, faction = "Horde",
		startItem = { itemID = 267137, name = "Krol'dok Moulding", note = TUNK },
		objective = "Find someone in Rog'mar who may know about the mould.",
		turnin = "Kreza Darkthorn, Rog'mar, Riverglades", endMap = Riverglades(0.598, 0.46, "Kreza Darkthorn"),
		note = "It can't be shared.",
		rewards = { money = 5500 },
	},
	[94974] = {
		name = "Key Ingredients", level = 41, requiredLevel = 38, faction = "Horde",
		pickup = "Kreza Darkthorn, Rog'mar, Riverglades", turnin = "Kreza Darkthorn, Rog'mar, Riverglades",
		startMap = Riverglades(0.598, 0.46, "Kreza Darkthorn"), endMap = Riverglades(0.598, 0.46, "Kreza Darkthorn"),
		objective = "Bring 4 Thick Leather and 12 Iron Bars to Kreza Darkthorn.",
		rewards = { money = 5500, items = { { itemID = 267089, name = "Krol'dok Compound Key" } } },
	},
	-- And A Small Favor, the step before the Alliance's Tome of Twilight (its page's series). Its text is Ashe
	-- Amberhall's, by Amberhall's Soulstone, which it gives you.
	[94907] = {
		name = "A Small Favor", level = 44, requiredLevel = 36, faction = "Alliance",
		pickup = "Ashe Amberhall, Farholde Keep, Riverglades", startMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		objective = "Summon a Twilight Thrall from a conduit within the Twilight Shroud and capture it with Amberhall's Soulstone.",
		note = "It can't be shared.",
		rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
	},
})

Placeholder({
	key = "AlcazPrison",
	name = "Alcaz Prison",
	picture = "AlcazPrison",
	-- The prison under the vines, right of the middle: the square icon is cut around it.
	iconArtCoords = { 0.38, 0.88, 0, 1 },
	levelMin = 48, levelMax = 53,
	description = "The prison on Alcaz Island still holds Defias Brotherhood inmates, but naga have taken the island "
		.. "and made the prison their own.",
	--[[
		The way in, the fights and the drops seen so far: from a players' guide to the dungeon (2026-11-08, the owner's
		pick), facts only, in our own words; its first runs, so all of it can change. Only the drops players saw are
		listed, each checked in the game's data (foreverchanges.pro's item pages); the guide's "probable" ones are left
		out. The order is the one players report: the game's own list puts The Questioner fourth, and the first groups
		went in other orders. Overseer Wrex's keyring opens the lower floor; Blazeroar is the last. Creature ids as the
		guide's pages link them.
	]]
	location = "The basement of the tower on Alcaz Island, Dustwallow Marsh",
	zoneEntrance = { mapID = 1445, x = 0.753, y = 0.141 },
	bosses = Bosses({
		{ name = "Overseer Wrex", level = 50, notes = {
			"The jail's overseer, in a side room of the upper floor. Pulling him brings the whole room, six to eight jailers and bounty hunters: draw him out into the corridor and crowd-control the extras.",
			"His Overseer's Keyring opens the locked door to the lower floor, so kill him early.",
		}, loot = { Seen(276733, "Grips of Control", "Hands, Plate"), Seen(276734, "Wrex's Pinky Ring", "Finger"),
			QuestItem(263992, "Overseer's Keyring", 1, "Key") } },
		{ name = "The Questioner", npcID = 256236, level = 51, notes = {
			"The prison's torturer. He has far more health than the other bosses: expect a long fight and save cooldowns for it.",
			-- (a player's comment on the dungeon's quests' Wowhead pages, 2026-11-09)
			"Players warn not to kill him before the last boss, Blazeroar: killed earlier, the dungeon's last quest can't be had.",
		}, loot = { Seen(276742, "Girdle of Extracted Answers", "Waist, Plate"), Seen(276743, "Fingerbreaker Stamp", "Trinket"),
			Seen(276741, "Defias Enforcer's Shoulderpads", "Shoulder, Leather") } },
		{ name = "Tidemistress Ca'zass", npcID = 255997, level = 50, notes = {
			"Leader of the Strashaz naga, near the cells not far from the entrance. Her Enchantresses cast Polymorph again and again: kill or interrupt them first; a Grounding Totem soaks it.",
			"She drops Blizzard on the group: move out of it.",
		}, loot = { Seen(276735, "Tidesong Wand", "Ranged, Wand"), Seen(276736, "Seascale Bracers", "Wrist, Mail"),
			QuestItem(273883, "Ca'zass's Head") } },
		{ name = "Katerina the Cleaner", npcID = 257016, level = 52, notes = {
			"On the lower floor, behind the door Wrex's keyring opens. Her fire hits the whole group hard and fills the room: let the healer drink to full first, and kill her fast.",
			"Leave the prisoners chained around her room alone during the fight.",
		}, loot = { Seen(276739, "Cutthroat Chestguard", "Chest, Mail") } },
		{ name = "Blazeroar", npcID = 255702, level = 53, notes = {
			"The last boss: Zarla Ober, one of the prisoners, who turns into a red dragon. Fire did nothing to her in the first fights, so fire casters should switch to frost.",
			"A hidden room behind her holds the Perfumed Note for the Horde's chain.",
		}, loot = { QuestItem(276890, "Zarla's Journal") } },
		{ name = "Trash Drops", trash = true, loot = { Seen(287021, "Defias Enforcer's Prowlers", "Feet, Leather") } },
	}),
	prepare = {
		{
			title = "The Overseer's Keyring",
			kind = "key",
			text = "Overseer Wrex drops the {item:263992:Overseer's Keyring}. It opens the locked door to the lower floor, "
				.. "where Katerina the Cleaner waits.",
		},
		{
			faction = "Horde",
			title = "Sergeant Ulka",
			-- (since 2026-11-09 the Kor'kron's quests are rows of the Quests tab: Data/Authored/QuestAudit.lua)
			text = "Sergeant Ulka waits outside the prison on Alcaz Island. He sends you in after Commander Folkar and "
				.. "asks for A Little Payback; inside, Folkar sends you looking for King Varian Wrynn.",
		},
		{
			faction = "Alliance",
			title = "Sully McCleary's errand",
			-- A player's comment on the dungeon's quests' Wowhead pages (2026-11-09).
			text = "Master Mathias Shaw, at SI:7 in Stormwind's Old Town, sends you to the inn at Theramore in Dustwallow "
				.. "Marsh. The dwarf inside, Sully McCleary, has you climb Jaina Proudmoore's tower and stand in for the guard "
				.. "at her side. Back at the inn, he gives The Secret Prison and A Bit of Wet Work.",
		},
	},
	-- Santiago Reyes's maps (Atlas de Azeroth: Forever), given by the owner on 2026-11-08 and 11-09, converted as his
	-- others: the prison's two levels, each named as his map labels it.
	map = { floors = {
		{ art = MAPS .. "AlcazPrison", artBottom = PICTURE },
		{ art = MAPS .. "AlcazPrisonMaximumSecurity", artBottom = PICTURE },
	} },
	floorNames = { "Main Unit", "Maximum Security Unit" },
})

Placeholder({
	key = "BlackmawHold",
	name = "Blackmaw Hold",
	picture = "BlackmawHold",
	-- The bear-head gate, a little right of the middle: the square icon is cut around it.
	iconArtCoords = { 0.30, 0.80, 0, 1 },
	levelMin = 55, levelMax = 60,
	description = "Behind the furbolg gates in the far north of Azshara lies one of the largest furbolg dens, and "
		.. "something is corrupting it from the depths.",
	--[[
		The way in, the fights and the drops seen so far: from a players' guide to the dungeon (2026-11-08, the owner's
		pick), facts only, in our own words; its first runs, so all of it can change. The bosses in the order of the
		game's encounter list, then the rare; only the drops players saw, each checked in the game's data
		(foreverchanges.pro's item pages). The door is the tunnel's mouth; the portal is at its far end. Creature ids as
		the guide's pages link them.
	]]
	location = "A furbolg tunnel in northern Azshara, its portal at the far end by the Winterspring border",
	zoneEntrance = { mapID = 1447, x = 0.384, y = 0.326 },
	bosses = Bosses({
		{ name = "Withermaw", npcID = 247195, level = 58, notes = {
			"The clan's great bear. If it is the rotting bear of the cavern route, it leaves pools of lava: fight out of them.",
			"Drops the Claws of the Great Bear for Claws That Rend, Tusks that Gore.",
		}, loot = { Seen(280064, "Withering Grips", "Hands, Leather"), QuestItem(249697, "Claws of the Great Bear") } },
		{ name = "Impaan the Imprisoner", npcID = 247206, level = 57, notes = {
			"A demon the corrupted clan let into its home. Its abilities are not recorded yet.",
		}, loot = { Seen(280058, "Impish Chain Hood", "Head, Mail") } },
		{ name = "Elder Shaman Bloodmane", npcID = 247209, notes = {
			"The clan's elder shaman, a caster: bring interrupts.",
			"Carries the Blackmaw Ritual Totem for Blackmaw Magic, and the Reliquary of Tyr for paladins.",
		}, loot = { QuestItem(276893, "Blackmaw Ritual Totem"), QuestItem(286415, "Reliquary of Tyr", 4) } },
		{ name = "Bonesnout the Unbroken", npcID = 247198, level = 58, notes = {
			"An undead boar made stronger by the Legashi Ritualists around it: kill or crowd-control them first.",
			"Drops the Tusks of the Unbroken for Claws That Rend, Tusks that Gore.",
		}, loot = { Seen(280060, "Lucky Shovelnose Tuft", "Trinket"), QuestItem(249696, "Tusks of the Unbroken") } },
		{ name = "Varrox Bleakhoof", npcID = 247234, level = 60, notes = {
			"A demon, the highest-level boss seen so far; his kill is the one the game counts for the dungeon.",
			"Drops the Head of Varrox Bleakhoof, for Blackmaw Reclamation, and the Mark of Xavius, whose quest is not known yet.",
		}, loot = { QuestItem(249692, "Head of Varrox Bleakhoof"), QuestItem(272027, "Mark of Xavius", 3) } },
		{ name = "Blackmaw Behemoth", npcID = 247207, notes = { "A beast. Nothing about the fight is recorded yet." } },
		{ name = "Unbound Spirit", npcID = 247231, notes = {
			"The last fight in the game's list, an elemental. Nothing about it is recorded yet.",
		} },
		{ name = "Moontouched Wanderer", npcID = 269104, level = 55, rare = true,
			notes = { "A rare that does not always spawn." },
			loot = { Seen(280080, "Claymore of Two Moons", "Two-Hand, Sword") } },
		{ name = "Trash Drops", trash = true,
			loot = { Seen(287036, "Satyr's Touch", "Ranged, Wand", "Legashi Ritualist") } },
	}),
	prepare = {
		{
			title = "Two ways through",
			text = "The hold has no single path. One way cuts through the satyr ritualists who strengthen a patrolling "
				.. "boar, Bonesnout the Unbroken; the other swims across a lake to a cavern where a rotting bear stalks, most "
				.. "likely Withermaw. Both lead to the ritual at the heart of the hold. Claws That Rend, Tusks that Gore "
				.. "needs both beasts.",
		},
	},
})

-- Beneath Nordrassil, for each side, the step before Get to the Roots of It (its page's series, 2026-11-08, read
-- by hand, facts only): only a talk, so a step's page, not a row. Its giver is not named on its page.
ns.AddQuestSteps({
	[92345] = {
		name = "Beneath Nordrassil", level = 55, requiredLevel = 45, faction = "Alliance",
		objective = "Speak to Mathrengyl Bearwalker at the Cenarion Enclave in Darnassus.",
		turnin = "Mathrengyl Bearwalker, Darnassus",
		endMap = { mapID = 1457, x = 0.354, y = 0.084, label = "Mathrengyl Bearwalker" },
		note = "Who gives it is not listed yet.",
	},
	[92346] = {
		name = "Beneath Nordrassil", level = 55, requiredLevel = 45, faction = "Horde",
		objective = "Speak to Nara Wildmane at Elder Rise in Thunder Bluff.",
		turnin = "Nara Wildmane, Thunder Bluff",
		endMap = { mapID = 1456, x = 0.757, y = 0.316, label = "Nara Wildmane" },
		note = "Who gives it is not listed yet.",
	},
})

Placeholder({
	key = "ShapersTerrace",
	name = "Shaper's Terrace",
	picture = "ShapersTerrace",
	-- The glowing crystals, right of the middle: the square icon is cut around them.
	iconArtCoords = { 0.4, 0.9, 0, 1 },
	levelMin = 58, levelMax = 60,
	location = "Un'Goro Crater",
	description = "A titan site hidden in Un'Goro Crater, guarding secrets of the makers among the crater's dinosaurs.",
	bosses = Bosses({ "Titanosaur", "Ravasaur Hunters", "Thunderhoof", "Venomridge", "Direhorn Matriarch", "Cinder",
		"King Op", "Snowtalon", "Bolt", "Vitrix", "Nanaya" }),
	--[[
		Santiago Reyes's maps (Atlas de Azeroth: Forever), his updated terrace and its cave, the Prismatic Talus, given
		by the owner on 2026-11-10 and converted from his full-size originals as his others: each floor named as his
		maps label it. The ways between them, read off his pictures: on the terrace, the cave mark he drew above the
		Prismatic Talus's label, at the end of a dotted trail down from the plains (the cave's own icon on it); in the
		cave, the narrow end of its north-western chamber, where its wall thins and a way in from the north-west would
		come (a best guess: his cave map draws no opening).
	]]
	map = {
		floors = {
			{ art = MAPS .. "ShapersTerrace", artBottom = PICTURE },
			{ art = MAPS .. "ShapersTerracePrismaticTalus", artBottom = PICTURE },
		},
		transitions = {
			{ floor = 1, to = 2, x = 0.921, y = 0.817, icon = "cave" },
			{ floor = 2, to = 1, x = 0.330, y = 0.218 },
		},
	},
	floorNames = { "Shaper's Terrace", "Prismatic Talus" },
})
