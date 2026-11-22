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

	`tested`: the owner has run it and checked the journal's page in game, so it no longer says "Not yet tested"
	(its button's mark and its overview's note).
]]
local function Placeholder(instance)
	instance.kind = "dungeon"
	instance.untested = not instance.tested
	instance.tested = nil
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
	(CREDITS.md), converted to Media/Maps like his others. Boss spots so far: The Drowned City's,
	Krol'dok Stronghold's, Alcaz Prison's, Blackmaw Hold's and the Shaper's Terrace's (each map's note below says where they
	come from); the others' come as runs are recorded. Boss lists (2026-11-08): the names in the
	game's files; The Drowned City's in the order a players' guide gives, and Var'Taka as quest 95776
	names her. Nobody has run the others yet, so names, order and count can still change.
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

--[[
	A rare (blue) drop seen dropping there, its item checked in the game's data: in a player's recorded run, or in
	Forever's NPC and item data's drop lists, counted on the kills it was seen on. Krol'dok Stronghold's, Alcaz Prison's,
	Blackmaw Hold's, the Shaper's Terrace's and the Drowned City's drops were all read again so on 2026-11-19, the rule
	for each: Seen where that data shows it dropping there, Listed (below) where something names it for the boss or the
	dungeon but no drop is seen yet. droppedBy: the one creature it drops off, where only one does (a trash drop's), else
	nil. Nothing in the journal shows it: it is a note for the data (and the tests).
]]
local function Seen(itemID, name, slot, droppedBy)
	return { itemID = itemID, name = name, slot = slot, quality = 3, droppedBy = droppedBy }
end

--[[
	A rare (blue) drop named for the boss or the dungeon (a players' guide's loot table, a drop list that counts no drop
	of it) but not seen dropping there yet, its item checked in the game's data. The row is the same as Seen's: the
	journal marks neither kind here (the owner's calls on these dungeons' loot, 2026-11-19), so the name only says,
	here, where it came from. (A classic dungeon's row kept though no drop of it is recorded carries a mark since
	0.40.1, which its tooltip shows: notSeen, Data/Authored/SiteLoot.lua's NotSeen.)
]]
local function Listed(itemID, name, slot, droppedBy)
	return Seen(itemID, name, slot, droppedBy)
end

--[[
	A drop of the whole dungeon that no one boss's list keeps: one row on its Trash page (the owner's call for the Drowned
	City's Linken's Boots of Iron, 2026-11-19), though the dungeon's bosses and rares drop it and its trash never does
	(offBosses). The journal says so wherever it would say the trash: the row's line on the dungeon's own Loot page and the
	row's tooltip on either page (UI/LootPanel.lua), the item's own tooltip (UI/ItemTooltip.lua), the search and the
	Gear Finder.
]]
local function OffBosses(row)
	row.offBosses = true
	return row
end

-- A quest item (or key) a boss drops, its colour the game's (its item data).
local function QuestItem(itemID, name, quality, slot)
	return { itemID = itemID, name = name, slot = slot or "Quest", quality = quality or 1 }
end

--[[
	A recipe, plans or pattern, on a boss's own list or in a dungeon's Recipes entry (recipes = true: Core/Registry.lua's
	ns.IsLootSection, after its trash's), its profession as the client's item data classes it ("Recipe, Cooking"), its
	quality the game's, and who drops it (droppedBy). A boss's own recipe is on his list and in the Recipes entry both;
	one only the Recipes entry lists drops off the dungeon's trash (UI/LootPanel.lua and UI/ItemTooltip.lua say so). Each
	one here is seen dropping there, as Seen's are; one only named would say Listed beside it.
]]
local function Recipe(itemID, name, profession, quality, droppedBy)
	return { itemID = itemID, name = name, slot = "Recipe, " .. profession, quality = quality, droppedBy = droppedBy }
end

Placeholder({
	key = "TheDrownedCity",
	name = "The Drowned City",
	-- Run and checked in game (the owner, 2026-11-17): no "Not yet tested" mark.
	tested = true,
	picture = "TheDrownedCity",
	-- The sunken gate and its stairs, on the left of the picture: the square icon is cut around them.
	iconArtCoords = { 0.05, 0.55, 0, 1 },
	levelMin = 35, levelMax = 40,
	location = "Coast of Stranglethorn Vale",
	description = "A troll city that sank into the ocean long ago has risen again, and naga, pirates and stranger "
		.. "things from the deep have claimed its streets.",
	-- The way in and the fights: from a players' guide to the dungeon (2026-11-08), facts only, in our own words; its
	-- early reports, so they can change. The drops: each fight's full list from Forever's NPC and item data (below).
	location = "Sunken Hollow, under the sea west of the Vile Reef, Stranglethorn Vale",
	zoneEntrance = { mapID = 1434, x = 0.214, y = 0.278 },
	--[[
		The game's numbers for the dungeon and its fights (encounterID below), from a player's recording (2026-11-13:
		the Record tab's VISIT and ENCOUNTER lines of a run that killed all five). Without the dungeon's number the
		journal never knew the player was inside: no kill counted on the map or in the run block, and the Record tab
		filed the bosses' drops as trash. By its id a fight counts in any language, and whatever the game calls it: it
		calls the fifth "Deathless Guardians" (3478), counted for Deathless Marrow, whose creature (260202) dropped the
		Bloodspine Staff just after it. The Primeval Elemental had no fight in that run; the owner's own recording of
		2026-11-16 has one, "Primeval Elemental" (3511, a kill in 2970), so its kill counts as the fight ends. Its corpse
		still counts it too (watchCorpse, UI/DungeonMap.lua), for a player who misses the fight's end.
	]]
	instanceID = 2970,
	--[[
		The fights, in the order of the owner's run (their combat log of 2026-11-11: Zul'Alai, Var'Taka, the Primeval
		Elemental, Captain Dreadrise, "Deathless Guardians", Min'loth the Serpent), then the rares (Gill, Umbra and,
		since 2026-11-18, "Pyromancer" Braxton), then the trash's drops. Zin'aka, the shark, is off the list (below).

		The fifth fight: the log names it "Deathless Guardians", the journal "Deathless Marrow" (a players' guide, the
		community wiki). The client's own encounter table (DungeonEncounter) could not settle it: its Drowned City rows
		are in encrypted sections of Forever's client files, and its hotfix cache holds only Min'loth the Serpent's row
		(3479, map 2970, the sixth). The journal keeps "Deathless Marrow" until the owner says which (2026-11-12).

		Boss spots (mapPin): from the owner's run, the 2026-11-11 combat log they viewed with its units' places, marked
		on our sheet of Santiago Reyes's two maps (2026-11-12). Their marks measured by color on their crops, which were
		laid on the sheet by its grid and its own pins (about 1 art pixel); x and y are shares of the 1024 x 683 art.
		Zul'Alai's and Captain Dreadrise's are our sheet's spots, which the owner left as they were. Gill's is the owner's
		area (2026-11-13): their crop of the journal's second map, Atal'byzal ("i think Gill should be in this area"), and
		a players' guide's words, along the way to the Primeval Elemental in the Deep Archives. The crop is Santiago
		Reyes's map as the journal draws it, with no mark of the owner's on it (its orange alcove and blue-green room are
		his); matched on the picture (correlation 0.995; one crop pixel is 1.23 art pixels; it shows art 438-951 across,
		27-289 down). The pin stands in the middle of that area on the way to the Elemental: halfway along the passage
		whose stairs go up north-east from the blue-green room, north of the orange alcove (art 664, 135). Where in the
		passage he stands is a best guess. Umbra's spot: the owner's words (2026-11-17), in the comment at its entry;
		"Pyromancer" Braxton's: the owner's picture (2026-11-18), in the comment at his.

		Gill's and Umbra's abilities (2026-11-12): the owner's players' guide, in our own words. No spell ids are known
		for them, so they are extraAbilities (UI/AbilitiesPanel.lua) with icons from the client's own files.

		The six fights' abilities and the creatures beside them (adds), 2026-11-17: each spell's id, school, damage and
		first cast from the owner's recording of a run on 0.39.23 (2026-11-16: the Log Reader's FIGHT and SPELL lines,
		one fight each), each id's name checked in the client's spell table (SpellName, build 1.60.1); what each does in
		the fight, its cast time, how long it lasts and how often it comes from a player's combat log of a run on
		2026-11-11 (read through a log site's pages, which show no spell ids), and from the client's own spell text.
		Where the two runs' numbers differ, the recording's are kept (Zul'Alai's Monstrous Slam: 427 to 597 there,
		715 to 790 in the log). Not in the recording, from the log alone (comments mark each): Harpoon, Deluge, the
		Saltseer Murderers' spells, the Sorcerer's Fireball damage and the timings the recording's short fights did
		not repeat. Left out, as the journal leaves out elsewhere: a creature that only cast on itself (the Brinescale
		Sorceress's Frost Armor, in the Elemental's fight: she rebuffs it out of combat nearby, as the log saw during
		Zul'Alai's), and the Saltscale Muckdweller's Rend, which only bled on in Var'Taka's fight (no cast in it: a
		pack pulled just before). The Saltseer Manhunter only meleed. The texts are drafted in English only, as the
		dungeon's notes are.

		Creature ids (npcID): the creatures fought, as Forever's NPC and item data lists the dungeon's creatures
		(2026-11-13): Zul'Alai 258905, Var'Taka 258924, Captain Dreadrise 260042, Deathless Marrow 260202, Min'loth the
		Serpent 260243, the Primeval Elemental 263886, Umbra 264172 and Gill 264177 ("Pyromancer" Braxton 260468, read
		2026-11-18). Forever's quest data has the bosses and Gill as 270882 to 270888 (it names 270885 "Deathless
		Marrow"), but every one of those rows has a "Staging Area" subtitle (1 to 6): they are stand-ins, not the
		creatures fought, and the journal no longer uses them. Gill's id, 264177, is also the owner's (2026-11-13), and
		the game itself names creature 264177 "Gill" (a name the client looked up on the owner's PC, saved 2026-11-12;
		that confirms the name, not where he spawns).

		Levels (level): a players' guide's boss table, from the first clears its players recorded (read 2026-11-19; it
		says to take them as a starting point), where a second players' list gives the same: Var'Taka 38, Deathless
		Marrow 39 and Min'loth the Serpent 40; and the Primeval Elemental's, 38, the guide's alone. Zul'Alai's and
		Captain Dreadrise's are left off, as the two disagree (37 or 38, 38 or 39): a look in game will settle them. So
		are Gill's and Umbra's: the guide does not know Gill's (the second list's 38 stands alone), and no source gives
		Umbra's ("Pyromancer" Braxton's, 38, is the owner's picture's: at his entry). Neither Forever's NPC data nor the
		client gives a level for any of them.

		Models (displayID), for the boss list's pictures and the Model tab: each creature's model as Forever's NPC data
		gives it (2026-11-13; "Pyromancer" Braxton's 2026-11-18, at his entry). Each checked in the client's own files
		(build 1.60.1.70938; Braxton's 1.60.1.70959): its CreatureDisplayInfo row is in an open part of the table, and
		every file its model needs reads (Braxton's baked skin was not checked). The Primeval Elemental's model and skin
		are locked with a key the server hands the client, and the client's hotfix cache holds that key: with it, both
		files open whole. The owner's creature cache no longer has these creatures, so it could not be checked there.

		Drops (loot): each boss's and rare's full list, as Forever's NPC and item data has it (2026-11-13), the slot and
		type as its item pages give them. Every id, name, slot and type checked in the client's hotfix cache (its
		ItemSparse and Item rows, read 2026-11-13). Every list read again on 2026-11-19 with the same items (the bosses
		then at 1450 to 3264 kills each, the rares at 106 to 177), and two more added: the Ancient Gurubashi Idol,
		Deathless Marrow's (at its entry), and Linken's Boots of Iron, the whole dungeon's (on the trash's row). Two
		other creatures there carry the bosses' names, 269586 "Deathless Marrow" and 260274 "Min'loth the Serpent":
		copies with no kills (269586's table holds only the idol, 260274 has none), not the ones fought. The trash's
		drops (2026-11-18, read again 2026-11-19): the row after the rares, at its entry.
	]]
	bosses = Bosses({
		{ name = "Zul'Alai", npcID = 258905, displayID = 144475, encounterID = 3474, notes = {
			-- (his oath came about halfway through in both runs, at 11 of 20 seconds and 21 of 35, not near the end;
			-- the client's text for it: faster attacks, and a share of his health back every few seconds)
			"An undead troll. About halfway through the fight he swears his Undying Oath: faster attacks, and he heals until he dies. Save cooldowns for it, and keep everyone topped up for Monstrous Slam.",
			"Monstrous Slam can be interrupted.",
		}, abilities = {
			-- (the log: a 2-second cast at 0:10 and 0:31, a 3-second stun; every one landed, so the guide's interrupt
			-- is not confirmed by it)
			{ spellID = 1282504, name = "Monstrous Slam", school = 1, flags = { "Healer", "Interruptible" },
				text = "A 2-second cast, then Physical damage to everyone near him and a 3-second stun.",
				hit = { 427, 597, 523 }, firstCast = 9, every = { 21, 21 } },
			-- (the log: on 2 to 4 players at 0:11 and 0:22, and a 10-second effect that does no damage)
			{ spellID = 1282519, name = "Rotted Strike", school = 1, flags = { "Damage" },
				text = "Physical damage to a few players near him, and slower attacks and movement for 10 seconds.",
				hit = { 52, 77, 68 }, firstCast = 12, every = { 11, 11 } },
			-- (the log: a 1-second cast, on him until he died)
			{ spellID = 1282511, name = "Undying Oath", school = 1, onSelf = true, flags = { "Enrage", "Important" },
				text = "A 1-second cast on himself: faster attacks, and he heals a share of his health every few seconds until he dies.",
				firstCast = 11 },
		}, loot = { Seen(274598, "Bloodslash Axe", "One-Hand, Axe"), Seen(274599, "Oathbound Bracers", "Wrist, Leather"),
				Seen(274600, "Berserker Shackles", "Wrist, Mail") },
			-- the east ruins, just inside the gate from Sunken Hollow (our sheet's spot, unchanged by the owner)
			mapPin = { x = 0.659, y = 0.537, floor = 1 } },
		{ name = "Var'Taka", npcID = 258924, displayID = 144487, encounterID = 3475, level = 38, notes = {
			"The Brinescale naga's leader. Two Brinescale Priestesses fight beside the boss and heal it: kill or crowd-control them first. Naga are humanoids, so Polymorph and Sap work.",
			"Harpoon pulls a player to the boss.",
			"A glowing pearl near the boss, once it is dead, opens the barrier ahead.",
		}, abilities = {
			-- (the log: every 7 to 9 seconds, 176 to 239 on the players beside the tank)
			{ spellID = 15284, name = "Cleave", school = 1, flags = { "Tank", "Damage" },
				text = "Hits the tank and the players beside it. Keep everyone else away from the front.",
				hit = { 103, 142, 120 }, firstCast = 3, every = { 8, 8 } },
			-- (not in the recording. The id is the client's own Harpoon, whose text names Var'taka; that the log's three
			-- unnamed casts, at 0:16, 0:35 and 0:52 with no damage shown, were this is a best guess, so no timings)
			{ spellID = 1282615, name = "Harpoon", school = 1, flags = { "Important" },
				text = "Throws a harpoon at a random player and pulls them to the boss." },
		}, adds = {
			-- (two of them; the log: each casts Frostbolt back to back, a slow of 4 to 8 seconds, and one Healing Wave
			-- healed the boss for 2,068 to 2,394 and each priestess for about 1,300)
			{ name = "Brinescale Priestess", npcID = 260096, abilities = {
				{ spellID = 9672, name = "Frostbolt", school = 16, flags = { "Interruptible", "Magic" },
					text = "A 3-second cast, most often on the tank: Frost damage and slower movement.",
					hit = { 116, 126, 122 }, firstCast = 1 },
				{ spellID = 1282611, name = "Healing Wave", school = 8, flags = { "Interruptible", "Important" },
					text = "A 3-second cast that heals the boss and every naga near them, the boss for over 2,000. Interrupt it.",
					firstCast = 12 },
			} },
		}, loot = { Seen(274601, "Harpoon of Command", "Two-Hand, Polearm"), Seen(274602, "Brinebelly Leggings", "Legs, Leather"),
				Seen(274613, "Priestess Cloak", "Back") },
			-- the Deep Archives' west building (the owner's red circle: 1047.6, 1149.3 on the sheet)
			mapPin = { x = 0.512, y = 0.710, floor = 1 } },
		{ name = "Primeval Elemental", npcID = 263886, displayID = 143898, encounterID = 3511, watchCorpse = true,
			level = 38, notes = {
			"An optional fight under water, in a hidden room reached through the central pool or down the stairs near Var'Taka's room: watch your breath. It shows itself once the offerings in its room are dead.",
		}, abilities = {
			-- (the log: always on the tank, 360 to 440 a bolt)
			{ spellID = 1290978, name = "Waterbolt", school = 16, flags = { "Tank", "Interruptible" },
				text = "A 3-second cast on the tank, one after another.",
				hit = { 414, 446, 435 }, firstCast = 0, every = { 3, 4 } },
			-- (the pulses' own id, with their damage; the cast that starts them, 1290980, came at 14 seconds in both runs.
			-- The log: 6 pulses, one a second, 133 to 156 each, the slow gone about 10 seconds after the last)
			{ spellID = 1290983, name = "Freeze Water", school = 16, flags = { "Healer" },
				text = "Frost pulses from it once a second for 6 seconds: Frost damage to everyone nearby, and a slow that stacks up to 6 times.",
				hit = { 148, 148, 148 }, firstCast = 14 },
		}, loot = { Seen(274611, "Robe of the Drowned", "Chest, Cloth"), Seen(274612, "Waterlogged Burial Shroud", "Back"),
				Seen(274615, "Heart of the Primeval", "Trinket") },
			-- Atal'byzal's round altar (the owner's red circle: 1377.6, 2356.3 on the sheet)
			mapPin = { x = 0.673, y = 0.550, floor = 2 } },
		{ name = "Captain Dreadrise", npcID = 260042, displayID = 142144, encounterID = 3476, notes = {
			-- (the log: he joined 8 seconds in, while three Saltseer Murderers and a Manhunter still fought; its tank broke
			-- the bubble, so "someone other than the tank" is gone)
			"Captain of the Saltseer pirates whose ship crashed into the city. His crew, three Saltseer Murderers and a Manhunter, fights beside him, and he joins a few seconds in: kill them first.",
			"He traps a player in a drowning bubble: break it fast. Interrupt Waterbolt Volley.",
			"A glowing pearl after the fight opens the way on.",
		}, abilities = {
			-- (the recording names it and when, but shows nothing it did: its words are the client's spell text. The
			-- log's unnamed 3-second cast just before an Abyssal Bubble appeared on his spot is most likely it: a best guess)
			{ spellID = 1282842, name = "Embrine", school = 8, flags = { "Important" },
				text = "Traps a random player near him in a bubble of water: they can't move or act, and slowly drown.",
				firstCast = 12 },
			-- (the log: a 3-second cast, 561 on the healer; two more were started and never finished, likely interrupted)
			{ spellID = 1282860, name = "Waterbolt Volley", school = 16, flags = { "Interruptible", "Healer" },
				text = "A 3-second cast: Frost damage to everyone near him.",
				hit = { 486, 580, 544 }, firstCast = 15 },
		}, adds = {
			-- (from the log alone: no creature id. The ids are best guesses: the only spells of these names among
			-- Forever's own, next to the dungeon's other creatures' spells)
			{ name = "Saltseer Murderer", abilities = {
				{ spellID = 1283416, name = "Poisonous Stab", school = 8, flags = { "Poison" },
					text = "Poisons a player: Nature damage every 3 seconds for about 9 seconds, and slower attacks and movement.",
					tick = { 11, 11 } },
				{ spellID = 1283366, name = "Shadow Shell", onSelf = true, flags = { "Damage" },
					text = "Raises its armor for a few seconds." },
			} },
		}, loot = { Seen(274603, "Dreadfrost Saber", "Main Hand, Sword"), Seen(274604, "Frosty Blunderbuss", "Ranged, Gun"),
				Seen(274605, "Briny Sash", "Waist, Cloth") },
			-- the channel below the Altar of the Serpent (our sheet's spot, unchanged by the owner)
			mapPin = { x = 0.559, y = 0.363, floor = 1 } },
		{ name = "Deathless Marrow", npcID = 260202, displayID = 142245, encounterID = 3478, level = 39, notes = {
			"Deathless Guardians, Sorcerers and Watchers keep coming while it lives. Each one killed makes the boss take 20% more damage, so kill them as they come, the Guardians first (they stun). It has a lot of health.",
			-- (the idol: at the loot below)
			"Drops the Ancient Gurubashi Idol, for the Horde's Ancient Gurubashi Idol and the Alliance's Ancient Gurubashi Secrets.",
		}, abilities = {
			-- (the log: every 12 to 16 seconds, on all five players)
			{ spellID = 1283034, name = "Bloodbolt", school = 1, flags = { "Healer", "Interruptible" },
				text = "A 3-second cast that hits every player.",
				hit = { 105, 192, 141 }, firstCast = 1, every = { 13, 16 } },
			-- (the client's text: more damage taken from all sources; the log saw 6 stacks as the adds went down)
			{ spellID = 1283027, name = "Poisoned Blood", school = 1, onSelf = true, flags = { "Damage" },
				text = "Stacks on the Marrow: each stack makes it take more damage from everything. Up to 6 were seen.",
				firstCast = 33 },
		}, adds = {
			{ name = "Deathless Guardian", npcID = 260213, abilities = {
				{ spellID = 1283081, name = "Shield Slam", school = 1, flags = { "Tank" },
					text = "Physical damage and a 2-second stun.", hit = { 75, 94, 88 }, firstCast = 28 },
				{ spellID = 1283083, name = "Shield Spike", school = 1, flags = { "Tank" },
					text = "Physical damage to the player it fights.", hit = { 73, 73, 73 } },
			} },
			{ name = "Deathless Watcher", npcID = 260205, abilities = {
				{ spellID = 1283076, name = "Strike", school = 1, flags = { "Tank" },
					text = "A hard extra hit on the player it fights.", hit = { 98, 98, 98 }, firstCast = 46 },
			} },
			-- (its damage from the log, 215 on the healer: the recording saw its casts land on no one)
			{ name = "Deathless Sorcerer", npcID = 260214, abilities = {
				{ spellID = 1283086, name = "Fireball", school = 4, flags = { "Interruptible" },
					text = "A 3-second cast: Fire damage to one player.", hit = { 215, 215, 215 }, firstCast = 46 },
			} },
		}, loot = { Seen(274606, "Bloodspine Staff", "Two-Hand, Staff"), Seen(274607, "Viscera Spaulders", "Shoulder, Mail"),
				Seen(274614, "Knucklebone Ring", "Finger"),
				-- The Ancient Gurubashi Idol (276894, a white quest item), for 96774 Ancient Gurubashi Idol (Horde) and
				-- 97130 Ancient Gurubashi Secrets (Alliance). It once stood on the Primeval Elemental. Forever's NPC and
				-- item data (2026-11-19) has it off Deathless Marrow (260202) on 1124 of 2185 kills, and never off the
				-- Primeval Elemental the players fight (263886) in 1450; the idol's own "dropped by" list names Marrow
				-- and two copies with no kills (269586 "Deathless Marrow", 273738 "Primeval Elemental"), not the
				-- Elemental fought. And the owner remembers it off Marrow (2026-11-19: "that dropped from marrow i think").
				QuestItem(276894, "Ancient Gurubashi Idol") },
			-- the Eternal Amphitheater's east hall, one building east of our sheet's guess (the owner's red circle:
			-- 717.0, 909.9 on the sheet)
			mapPin = { x = 0.350, y = 0.535, floor = 1 } },
		{ name = "Min'loth the Serpent", npcID = 260243, displayID = 142286, encounterID = 3479, level = 40, notes = {
			"The last boss. A storm gathers over the city during the run, just before this fight.",
			-- (neither the log nor the client's text has the volley lowering healing: gone; the bite that heals him is new)
			"When nearly beaten he turns into a giant serpent, heals to full and is fought again. The second phase adds fear, a poison volley on everyone and a bite that heals him: save the healer's cooldowns for it.",
			-- (the owner, 2026-11-17: the chest the city's map marks, mapSpots below; English only, as the dungeon's other notes)
			"After the fight, a hidden chest waits on the wrecked boat on the small island north of his dais, marked on the map. It isn't locked: anyone can open it for random items and materials.",
		}, abilities = {
			-- (the log: a 3-second cast, 516 on the tank)
			{ spellID = 1283250, name = "Drench", school = 16, flags = { "Tank", "Interruptible" },
				text = "A 3-second cast: heavy Frost damage to one player, most often the tank.",
				hit = { 649, 649, 649 }, firstCast = 4 },
			-- (from the log alone: 81 a hit on everyone for about 7 seconds. Which of the client's six Deluge rows is the
			-- rain's is a best guess: the one whose words the others borrow)
			{ spellID = 1283239, name = "Deluge", school = 16, flags = { "Healer" },
				text = "Rain falls on the group for about 7 seconds: small Frost hits on everyone, several a second.",
				hit = { 81, 81, 81 } },
			-- (the log: a 4-second cast that healed him for 12,877)
			{ spellID = 1283295, name = "Transform", school = 1, onSelf = true, flags = { "Important" },
				text = "A 4-second cast: he becomes a giant serpent and heals to full.",
				firstCast = 15 },
			-- (the log: its poison ticked 31 to 45 every 2 seconds; the volley, the fear and the bite each came about every
			-- 16 to 17 seconds)
			{ spellID = 1283313, name = "Poison Bolt Volley", school = 8, flags = { "Healer", "Poison" },
				text = "Nature damage to every player, then more every 2 seconds for a few seconds.",
				hit = { 293, 364, 319 }, tick = { 31, 45 }, firstCast = 25, every = { 16, 16 } },
			{ spellID = 1313471, name = "Fear", school = 32, flags = { "Interruptible" },
				text = "A 1.5-second cast: one player flees in fear for a few seconds.",
				firstCast = 28, every = { 17, 17 } },
			{ spellID = 1283327, name = "Fatal Bite", school = 1, flags = { "Tank" },
				text = "Bites the tank, and he heals for up to twice the damage done.",
				hit = { 296, 296, 296 }, firstCast = 35, every = { 16, 16 } },
		}, stages = {
			{ title = "Stage One", description = "His first form, until he is nearly beaten.",
				spells = { 1283250, 1283239 } },
			{ title = "Stage Two: The Serpent", description = "He becomes a giant serpent, heals to full and is fought again.",
				spells = { 1283295, 1283313, 1313471, 1283327 } },
		}, loot = { Seen(274608, "Maw of Min'loth", "Off Hand, Shield"), Seen(274609, "Serpentbane Crown", "Head, Mail"),
				Seen(274610, "Ritual-Binder's Gloves", "Hands, Leather") },
			-- one spot, the Abyssal Dais (the owner's red circle: 417.5, 920.0 on the sheet; our other guess, the Altar of
			-- the Serpent, crossed out by the owner)
			mapPin = { x = 0.204, y = 0.542, floor = 1 } },
		-- Gill's spot: the owner's area (2026-11-13), in Atal'byzal's passage up north-east from the blue-green room, on
		-- the way to the Primeval Elemental (see above)
		{ name = "Gill", npcID = 264177, displayID = 144023, rare = true, notes = {
			"A rare along the way to the Primeval Elemental in the Deep Archives. He throws dynamite at whoever he is fighting.",
			"Pull him away from the enemies around him before you fight him.",
		}, extraAbilities = {
			{ title = "Throw Dynamite", icon = "Interface\\Icons\\inv_misc_bomb_06", flags = { "Tank" },
				description = "Throws dynamite at whoever he is fighting, most often the tank." },
		}, loot = { Seen(286649, "Tidebound Dagger", "Main Hand, Dagger"), Seen(286646, "Gill's Gills", "Trinket") },
			mapPin = { x = 0.648, y = 0.198, floor = 2 } },
		-- Umbra's spot: the owner's words (2026-11-17), "Umbra spawns inside The Drowned City near the stairs leading up
		-- toward Var'Taka in the Deep Archives area". The city map draws one stair there, in the Deep Archives' west
		-- building: it climbs north from the building's south room into Var'Taka's room (art 523 to 530 across, 511 to
		-- 532 down). The pin is at its foot, on the south room's floor (art 526.3, 537.5). No recording or log names
		-- Umbra; the 2026-11-11 log has the group at the south room's east door (art 543, 530) and two murloc pulls just
		-- before Var'Taka, whose places were not read. Where at the foot Umbra stands is a best guess, to check in game.
		{ name = "Umbra", npcID = 264172, displayID = 144022, rare = true, notes = {
			"A rare that comes with five Saltscale Murlocs. Their attacks make you bleed, and together they hurt fast.",
			"Umbra itself does nothing special: kill it quickly, then the murlocs.",
		}, extraAbilities = {
			{ title = "Bleed", icon = "Interface\\Icons\\ability_gouge", flags = { "Bleed" },
				description = "The Saltscale Murlocs' attacks make their target bleed. Several at once can kill quickly." },
		}, loot = { Seen(286658, "Umbral Scaled Belt", "Waist, Mail"), Seen(286662, "Deep-Dweller's Grips", "Hands, Cloth") },
			mapPin = { x = 0.514, y = 0.787, floor = 1 } },
		--[[
			"Pyromancer" Braxton, a rare: the owner's pictures (2026-11-18) of a page with him, his level and two
			drops, and of a piece of a map of the city with his pin. His facts from Forever's NPC and item data
			(2026-11-18): creature 260468, a rare elite humanoid found in the Drowned City, named by the game with the
			quotes; a player's note there puts him in the pirates' part of the city. His one spell there, Head Smash
			(1291712, its name checked in the client's spell table, SpellName, 1.60.1.70959); the other, Dazed, is the
			game's own daze, left out. His level, 38, is the owner's picture's alone: neither the NPC data nor the
			client has it.
			His model (displayID): the NPC data's, 142457, checked in the client's own files (1.60.1.70959): its
			CreatureDisplayInfo row is in the table's open part, a display dressed as player characters are (model
			7661, whose file reads whole; its extra row, 164143, a human man), as the owner's picture shows him. The
			client holds no row for the creature (no creature cache, Creature or hotfix row), so only the NPC data
			ties the two.
			His drops: the two blues the NPC data has off him, 48 and 58 in its 106 kills, about one a kill; each id,
			name, slot and type checked in the client's hotfix cache. A third on his page, Linken's Boots of Iron
			(271718, 2 of 106), is a drop of the whole dungeon, not his own: one row on the Trash page that says the
			bosses and rares drop it (the owner, 2026-11-19; at the trash's row).
			His spot: the owner's map piece laid on the journal's own picture of the city (the same map of Santiago
			Reyes's; correlation 0.987, his pin and its label left out; one picture pixel is 0.39 art pixel): the open
			ground just east of the ends of the three walkways north-west of the central pool, west of the channel
			below the Altar of the Serpent (art 507, 251), about 65 art pixels west of Captain Dreadrise's. The NPC
			data has no spawn marks for him. A rare-tracking list built from players' data (read 2026-11-18, the owner's
			OK) has him, with his two drops at about half the kills each, but no spot either: it places the city's
			other two rares, Gill and Umbra, and leaves him without a zone. So the spot rests on that pin alone: a best
			guess from players' data until checked in game.
		]]
		{ name = "\"Pyromancer\" Braxton", npcID = 260468, displayID = 142457, rare = true, level = 38, notes = {
			"A rare in the pirates' part of the city, not far from Captain Dreadrise. As a rare, he may not be there every run.",
			"Despite his name, no fire spell is known for him yet: he hits with Head Smash, which stuns for 2 seconds.",
			"The kills recorded so far dropped one of his two items about every time.",
		}, abilities = {
			{ spellID = 1291712, name = "Head Smash", school = 1, flags = { "Tank" },
				text = "Hits his target a little harder than a normal blow and stuns it for 2 seconds." },
		}, loot = { Seen(286650, "Pyromancer's Baton", "One-Hand, Mace"), Seen(286651, "Flamestarter's Signet", "Finger") },
			mapPin = { x = 0.495, y = 0.367, floor = 1 } },
		--[[
			The trash's drops: the ten blues of the owner's picture of a trash list (2026-11-18), the client's band
			286997-287006, each one Forever's NPC and item data has dropping in the Drowned City: off many of its 17
			kinds of trash in small counts (Brinescale Explorers, Risen Sentries, Brinescale Sorceresses, the Saltseer
			pirates, Champions of the Deep, Profane Necromancers, Chasm Crawlers and the rest), but Risen Sentry's
			Links, off the Risen Sentries (258792) alone. Each id, name, slot and type checked in the client's hotfix
			cache (all blue, item level 39 to 42). Seen: each one's drop list on the NPC data names only the Drowned
			City's creatures (2026-11-19: 25 to 160 drops each).
			Last, Linken's Boots of Iron (271718: blue, Bind on Pickup, Feet, Mail, item level 38), the owner's call of
			2026-11-19 ("one row on the Trash page, with a note that bosses and rares drop it"): the NPC data has it off
			the dungeon's six bosses and three rares alone, about 1 kill in 100 (141 drops), never off its trash. So its
			row says the bosses and rares drop it, not the trash (OffBosses, above).
			Left off, as the owner's rule has it (2026-11-19: a Trash page lists only the dungeon's own loot): the
			world's drops off these creatures (old recipes and blues found all over the world at these levels, the
			profession drops), and the trash's two quest items, the I'lalai Fetish and the Voodoo-Infused Artifact (the
			owner, 2026-11-19: "keep them off"). No recipe drops only here, so the city has no Recipes row.
		]]
		{ name = "Trash Drops", trash = true, loot = {
			Seen(287002, "Risen Sentry's Links", "Legs, Mail", "Risen Sentry"),
			Seen(287005, "Sword of Dismemberment", "Two-Hand, Sword"), Seen(286997, "Depth-Risen Leggings", "Legs, Cloth"),
			Seen(286998, "Deep Flora Bindings", "Wrist, Cloth"), Seen(286999, "Deathcrawler's Chest", "Chest, Leather"),
			Seen(287000, "Skin-Flayed Footguards", "Feet, Leather"),
			Seen(287001, "Waterlogged Shoulderpads", "Shoulder, Leather"), Seen(287003, "Corroded Handguards", "Hands, Mail"),
			Seen(287004, "Touch of the Depths", "Ranged, Wand"), Seen(287006, "Resurged Axe", "One-Hand, Axe"),
			OffBosses(Seen(271718, "Linken's Boots of Iron", "Feet, Mail")) } },
		--[[
			Zin'aka, an elite shark that circles the central pool, is off the list (the owner, 2026-11-12: it drops no loot
			yet, so it stays out until we know whether it has a purpose). To bring it back, add before the trash's drops:
			{ name = "Zin'aka", uncounted = true, notes = {
				"An elite shark that circles the central pool. It is not a boss and no quest needs it. It hits very hard: swim around it.",
			}, mapPin = { x = 0.527, y = 0.520, floor = 1 } },
			(uncounted: no circle in the run block's count, Core/Run.lua; not rare = true, as it is always there; the spot,
			the central pool, our sheet's.) Its test in Tools/smoke_scenario.lua lists the bosses and pins without it.
		]]
	}),
	--[[
		Santiago Reyes's two maps: the city, and Atal'byzal, the sunken shrine below it. Inside, the map opens on the
		floor of the area the player is in (UI/DungeonMap.lua, follow.Floor), by the game's own names for the dungeon's
		areas. Where each name is, from Forever's own files (read 2026-11-17, client 1.60.1.70938; their rows for the
		dungeon are in a part of AreaTable the client's own keys open):
		- the city's ground names six areas, all under the dungeon's own (AreaTable 16550): Sunken Hollow (17037),
		  Deep Archives (17039), Altar of the Serpent (17040), Eternal Amphitheater (17041), Abyssal Dais (17042), on
		  their labels, and the Flooded Shrine (17038): the walled square of the central pool, where the shark circles
		  (30 pieces of ground, 6 by 5, drawn on the city's map by the 2026-11-11 log's fit). Its other ground (streets,
		  sea, the strip inside the pool's south wall, by the way down) is the dungeon's own: no area's name. Otton's
		  recording (2026-11-13) reads the six, and each boss's fight area as the ground has it (the owner's of
		  2026-11-16 has the fights alone, no area's name).
		- Atal'byzal is one building under the city (WMOAreaTable rows 142354-142365): all 11 of its rooms, from the
		  pool's south edge to the Deep Archives' flooded room, name AreaTable 17046, "Ataal'Byzal"; the building's own
		  row says "Atal'Byzal". None of its rooms is unnamed.
		So the city's areas are its five and the Flooded Shrine (the owner took it for the shrine, 2026-11-14; a best
		guess why: its name shows in the pool, on the way down), Atal'byzal's its two names, and where the client names
		no area at all (unnamedFloor) the player is in the city: the owner, 2026-11-17, up through the pool: "It might
		not have a name".
		Which of the shrine's two spellings the game shows there is a best guess (the room's area, most likely), so
		both count. Forever has no map of its own for the dungeon (UiMap, UiMapAssignment) and no height inside, so
		the names are all there is to go by.

		Two ways between the floors (the owner, 2026-11-17, green circles on the journal's two maps: "the left mark is
		from the deep archives and the top right is letting out into the center pool where the shark boss is"), each
		with a way at both ends:
		- the Deep Archives: from the flooded room at the south-east corner of the Deep Archives, on the city's map, to
		  the south-west end of Atal'byzal's long hall, where his picture leaves it open;
		- the central pool: from the pool's south edge, by its south wall, on the city's map, to the north-east end of
		  Atal'byzal's long passage, past Gill's spot.
		Each spot is the owner's circle, its screenshot laid on the journal's own map picture (the city's and
		Atal'byzal's: 69 and 41 patches of the picture matched; one screenshot pixel is 0.836 art pixel; the fit's error
		0.35 art pixel on average, 0.62 and 0.69 at most); the circles were drawn "generally", so each sits where its
		passage ends. The Deep Archives' way down at its circle, in the room's open floor (art 587.6, 568.6), a little
		below the earlier spot (art 582.4, 559.9, the 2026-11-11 log's first Bladetooth Frenzy pull), which sat on the
		room's broken wall; the pool's at its circle (art 574.2, 398.9); Atal'byzal's south-west end 6 pixels inside the
		hall's open end, on which the circle sat (art 293, 529.7); its north-east end at the circle (art 708.8, 84.9), a
		little past the earlier spot (art 690, 88). Each has the delve's icon, as a building's way in has (Atal'byzal is
		a shrine; his maps draw no stair), and under "To <floor>" a line of where it comes out (note, the key of its
		words: UI/DungeonMap.lua). A link turns the map to the other floor; it cannot point at a spot there.
	]]
	map = {
		floors = {
			{
				art = MAPS .. "TheDrownedCity", artBottom = PICTURE,
				areas = { ["Sunken Hollow"] = true, ["Deep Archives"] = true, ["Altar of the Serpent"] = true,
					["Eternal Amphitheater"] = true, ["Abyssal Dais"] = true,
					["Flooded Shrine"] = true },
			},
			{ art = MAPS .. "TheDrownedCityAtalbyzal", artBottom = PICTURE,
				areas = { ["Ataal'Byzal"] = true, ["Atal'Byzal"] = true } },
		},
		-- where the client names no area: the city (above)
		unnamedFloor = 1,
		transitions = {
			-- the Deep Archives' way, at both ends
			{ floor = 1, to = 2, x = 0.574, y = 0.833, icon = "building", note = "MAP_WAY_OUT_SOUTHWEST" },
			{ floor = 2, to = 1, x = 0.286, y = 0.776, icon = "building", note = "MAP_WAY_OUT_DEEP_ARCHIVES" },
			-- the central pool's way, at both ends
			{ floor = 1, to = 2, x = 0.561, y = 0.584, icon = "building", note = "MAP_WAY_OUT_NORTHEAST" },
			{ floor = 2, to = 1, x = 0.692, y = 0.124, icon = "building", note = "MAP_WAY_OUT_CENTRAL_POOL" },
		},
	},
	floorNames = { "The Drowned City", "Atal'byzal" },
	--[[
		Places worth knowing on the city's map (mapSpots: UI/DungeonMap.lua's MapSpot), each { kind, floor, x, y, text }.
		The hidden chest (the owner, 2026-11-17: "a secret chest at the end of the dungeon", then their dot "on the boat in
		the upper left after final boss"): their green dot on a screenshot of the journal's city map, laid on the journal's
		own picture of it by its features (405 patches of the picture matched; one screenshot pixel is 0.836 art pixel; the
		fit's error 0.06 art pixel on average, 0.31 at most). It sits on the deck of the boat on the small island north of
		the Abyssal Dais, past Min'loth the Serpent (art 165.5, 229.2); the owner said "the boat", and "wrecked" in its
		text is our reading of the art, a boat beached on the rocks. What it holds and how it
		opens (the owner, 2026-11-17): "It held random items and materials and was not locked and able to be opened by
		anyone".
	]]
	mapSpots = {
		{ kind = "chest", floor = 1, x = 0.162, y = 0.336, text = "MAP_SPOT_DROWNED_CHEST" },
	},
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
	-- The game's numbers for the dungeon and its fights, from a player's recording (2026-11-13: the Record tab's VISIT
	-- and ENCOUNTER lines of a run that killed all five, the fights named as the list names them): without them no kill
	-- counted on the map or in the run block. By its id a fight counts in any language.
	instanceID = 3039,
	-- Where the player stood as the loading screen began, in the Riverglades (the same recording: one reading).
	zoneEntrance = { mapID = 2548, x = 0.3745, y = 0.372 },
	--[[
		From the same recording (2026-11-13), with the one combat log of that run the journal's Log Reader page read.
		Creature ids (npcID): the creature that cast the boss's spells in its own fight; Grox's and Mugg's also dropped
		their boss's item off their corpses. The game calls two of them otherwise than their fights, so those names count
		too (aliases): "War Handler Ashka" and "Overlord Mugg". The bosses stay in the journal's order for now (that run
		went Nar'gurk before Ashka; the owner's call, 2026-11-14). A player's combat log of another run (2026-11-12) went
		in the journal's order: Grox, Zarmok, Ashka, Nar'gurk, then Bossman Toof, then Mugg. Toof goes in there (the
		owner's call, 2026-11-14); the others stay as they are until their places are known.

		Models (displayID), for the boss list's pictures, the faces on the map and in the run block, and the Model tab:
		each boss's model as Forever's NPC data gives it (2026-11-17; Bossman Toof's, 14424, read there 2026-11-18, his
		creature 264773 a humanoid elite). The client holds none of Krol'dok's creatures (its creature cache and Creature
		table have no row for them), so nothing in it ties a creature to its model; each id was checked in the client's
		own files instead (build 1.60.1.70959): its CreatureDisplayInfo row is in the table's open part, and every model
		and skin file it names reads whole. What the files draw: Nar'gurk an ogre mage, Mugg an ogre king, Zarmok an orc
		man and Ashka an orc woman, the last two dressed as player characters are; Grox's model file has no name inside
		it, but its skin (texture 125310) is an ogre's: grey-blue skin, a tusked face and purple armor. Toof's, an old
		display of the game's own rather than one of the new 141215-141443, is the ogre warlord model (model row 1431,
		file 125293, which calls itself OgreWarlord) at 2.35 times its size, its two skins (125297, 125294) a tan ogre
		with red war paint (a spiral on the belly, a diamond around the eye) in dark grey armor with fur trim and red
		straps; its two .skin files and 19 animation files read whole too (checked 2026-11-18, the same build). A big
		ogre fits him (Big-Belly Belt, Toofbreaker); that the NPC data has his model right is still to be seen in game.
		(The client's unused id among the others', 141216, a human man, is not his.)

		Drops (loot): each boss's list as Forever's NPC and item data has it, the same lists a players' guide's loot tables
		give (2026-11-17). Read again there on 2026-11-19, every blue on them is seen dropping off its boss, about one
		blue a kill (on 967 to 1382 kills each; Bossman Toof's, below, on 1063), so all are Seen now (until then, Seen
		meant the one blue each fight dropped in that recording, through the loot history under its fight, and the rest
		were Listed). Nothing new on any boss's list. The quest items and Mugg's key as the same lists have them; Grox's
		green blueprint, a cooking recipe (43 of his 967 kills), too, and in the Recipes entry (below), the dungeon's one
		recipe of its own. The quest items that drop all over the dungeon (Cultist Ear, Twilight Bangle) stay off the
		trash, as quest items off trash do elsewhere (Data/Authored/SiteLoot.lua); so does the Sealed Expert's Writ
		(262889), which drops in many dungeons. Every item's id, name, slot, type and quality checked in the client's item
		data (its hotfix cache, read 2026-11-17; the trash's ten again 2026-11-19, in the copy of 2026-11-18).

		The trash (Forever's NPC and item data, 2026-11-19): the client's band 287007-287016, ten Bind on Equip blues of
		item level 44 to 47, each seen dropping off Krol'dok's own creatures, the Krol'dok Brutes and Twilight Grunts most,
		then the Twilight Lieutenants, Outriders, Centurions, Shamans and Warlocks; the Outrider's Gloves off the Twilight
		Outrider alone (143 of 2743 kills). The Gauntlets were seen once in the recording too, off creature 258042 (a Grunt).
		The three plate pieces are the rest of Krol'dok Battlegear (set 2135), with Nar'gurk's helmet and chest. The
		trash's recipes are the classic world-drop recipes of the level (63 of them seen, each dropping all over the world,
		none the dungeon's own): left out of its Recipes entry (the owner, 2026-11-19: only loot of the dungeon's own).
		Only the dungeon's own (the owner's call of 2026-11-19: the trash's and the recipes' rows are the dungeon's own loot),
		checked that day in each item's "dropped by" list: every trash row, the blueprint and Kroog's two drop off the
		dungeon's own creatures alone (its fights' adds and trash, Zalfan Moonshadow, Kroog), nothing else. Most of those
		creatures have no zone there, only marks on the continent's map in one cluster with the zone's own three; and the
		data counts every kill of every one of them in a dungeon (its count of kills in a dungeon equals that of all
		kills), so none of these items has dropped outside. Which dungeon, for those with no zone: Krol'dok, by the
		cluster, their ids and their place in the fights (a best guess, if a close one). Nothing taken out.

		Kroog (262716), a rare elite with two blues of his own (Kroog's Backscratcher 279857, a dagger, 31 of 73 kills, and
		the Black Horn Necklace 279863, 42 of 73; both Bind on Pickup, item level 43, checked in the client's item data),
		who drops the trash's Legplates too, is most likely a rare of this dungeon: a player's note on him says so, and his
		items' ids sit by the dungeon's quest rewards. Listed on the owner's word (2026-11-19: "Sure"), as Blackmaw Hold's
		rares were: after the bosses, a rare (no fog, not in the run's count), with no pin, as no spot of his is known. (Read
		again 2026-11-19: the NPC data now has one spawn mark for him, on the continent's map only, among the dungeon's own
		creatures there, Zalfan Moonshadow's and the Shadowhide Bullies' marks; not laid on our map: a lead for a pin.) Each
		of his two blues drops off him alone in that data. His model, 17273, the NPC data's, checked in the client's own
		files (1.60.1.70959): its CreatureDisplayInfo row is in the table's open part, and its model file (the ogre model,
		row 32), its 4 .skin and 25 animation files and its skin (texture 125289, a tan ogre with red war paint) all read
		whole. His level: neither the NPC data nor the client gives it.
		(Zalfan Moonshadow, 268423, the elite the Alliance's Vengeance of the Highborne sends players to kill, drops only
		the trash's set pieces: not listed.)

		Levels (level): a players' guide's boss table, from the first clears its players recorded (read 2026-11-19),
		where a second players' list gives the same: Slavecrusher Grox 42 (a picture in the guide shows him as a level
		42 elite too), Twilight Commander Zarmok 43, Nar'gurk 44, Bossman Toof 42 and Overseer Mugg 45. Handler Ashka's
		is left off: the guide says it is not known yet, and no other source gives it. Kroog's too (the level 38 the
		guide gives at his drops is the level they need, not his). Neither Forever's NPC data nor the client gives a
		level for any of them.

		Spots (mapPin, on Santiago Reyes's map): where that combat log drew each fight, matched to his map by 22
		landmarks (buildings, towers and the way in). A best guess until checked in game: the log draws one mark per
		fight, which may be where the pull began or the middle of the fight.
	]]
	bosses = Bosses({
		{ name = "Slavecrusher Grox", npcID = 258966, displayID = 141217, encounterID = 3450, level = 42,
			loot = { Seen(274995, "Slavecrusher Scepter", "One-Hand, Mace"), Seen(274996, "Resistance Breaker Spaulder", "Shoulder, Mail"),
				Seen(274997, "Chain of Binding", "Waist, Mail"), Recipe(273101, "Blueprint: Expert Campfire", "Cooking", 2) },
			-- open ground just inside the way in, north-east of the portal
			mapPin = { x = 0.240, y = 0.754, floor = 1 } },
		{ name = "Twilight Commander Zarmok", npcID = 258972, displayID = 141219, encounterID = 3452, level = 43,
			loot = { Seen(274998, "Shadowlight Athame", "Main Hand, Dagger"), Seen(274999, "Shadecaster's Leggings", "Legs, Cloth"),
				Seen(275000, "Zarmok's Plated Signet", "Finger") },
			-- Rending Whirl's cast: its hits (1280011), with their damage, are the row to read
			notAbilities = { [1296130] = true },
			-- the yard south-west of the big dome, at the east end of the long wall
			mapPin = { x = 0.389, y = 0.691, floor = 1 } },
		{ name = "Handler Ashka", npcID = 259281, displayID = 141443, aliases = { "War Handler Ashka" }, encounterID = 3453,
			loot = { Seen(275001, "Bloodied Gutslicer", "Two-Hand, Sword"), Seen(275002, "War Handler's Gaze", "Head, Leather"),
				Seen(275003, "Worgbinder's Treads", "Feet, Plate") },
			-- the east yard, just east of the round tower
			mapPin = { x = 0.623, y = 0.554, floor = 1 } },
		{ name = "Nar'gurk", npcID = 258964, displayID = 141215, encounterID = 3449, level = 44,
			loot = { Seen(275004, "Chain of the Corruptor", "Neck"), Seen(275005, "Krol'dok Warplate Chest", "Chest, Plate"),
				Seen(275006, "Krol'dok Warplate Helmet", "Head, Plate"), QuestItem(267104, "Tome of Twilight") },
			-- on the long stone walkway in the west, about halfway along
			mapPin = { x = 0.377, y = 0.576, floor = 1 } },
		--[[
			Bossman Toof, in the owner's words (2026-11-14), with what the 2026-11-12 combat log saw. His creature id,
			264773, is the one creature of that name in Forever's NPC data (2026-11-17); no recording or log of ours has
			it yet, and the client holds no row for him. His fight's id is still UNKNOWN. He counts by his creature id,
			seen lying dead (as target, focus or mouseover) or looted, on a client in any language: UI/DungeonMap.lua's
			WatchDeaths watches every boss with no encounter id, by id and by name. And by his name: when a fight the game
			names "Bossman Toof" ends (ns.BossesForFight finds him through ns.BossesNamed), or seen lying dead under it.
			His loot: the three blues a players' guide's loot table gives him (2026-11-17), which Forever's NPC data lists
			under his own creature since (2026-11-19: 336, 334 and 393 drops in 1063 kills, so Seen): Band of Bossman
			(286428, also seen once in Krol'dok as group loot in the earlier recording), Big-Belly Belt (286429) and
			Toofbreaker (286430). The same page gives his spells as Thunderclap 15548, Demoralizing Shout 16244 and Mortal
			Strike 16856, as his note names them (no fight of his is recorded, so they are not written as abilities). His
			model: above. His shamans' Lightning Bolt and his brutes' Cleave are written here: no spell id fits them for sure
			(their other spells: below).
		]]
		{ name = "Bossman Toof", npcID = 264773, displayID = 14424, level = 42, notes = {
			"A series of add waves comes at you as you make your way to him. Bossman Toof himself is a warrior, with Mortal Strike, Thunderclap and Demoralizing Shout.",
			"Two Krol'dok Shamans and two Krol'dok Brutes fight beside him. The shamans cast Lightning Bolt and put Bloodlust on him: purge it if you can.",
		}, extraAbilities = {
			{ title = "Lightning Bolt", icon = "Interface\\Icons\\spell_nature_lightning",
				description = "The Krol'dok Shamans cast it at players, one every 4 to 12 seconds between the two of them." },
			{ title = "Cleave", icon = "Interface\\Icons\\ability_warrior_cleave",
				description = "The Krol'dok Brutes' Cleave hits their target and the players next to it." },
		}, loot = { Seen(286428, "Band of Bossman", "Finger"), Seen(286429, "Big-Belly Belt", "Waist, Cloth"),
				Seen(286430, "Toofbreaker", "One-Hand, Mace") },
			-- the north-east end of the wooden bridge from the central building
			mapPin = { x = 0.600, y = 0.458, floor = 1 } },
		{ name = "Overseer Mugg", npcID = 258968, displayID = 141218, aliases = { "Overlord Mugg" }, encounterID = 3451,
			level = 45,
			loot = { Seen(275007, "Mugg's Jabber", "One-Hand, Fist Weapon"), Seen(275008, "Mugg's Crosser", "One-Hand, Fist Weapon"),
				Seen(275009, "Emblem of Slamming", "Trinket"), Seen(275010, "Strongly Scented Hood", "Head, Cloth"),
				QuestItem(267086, "Eye of Mugg"), QuestItem(271721, "Krol'dok Ogre Key", 1, "Key") },
			-- the great hall at the north end (the east building)
			mapPin = { x = 0.680, y = 0.171, floor = 1 } },
		-- Kroog, a rare (the owner, 2026-11-19; above): no pin, as where he spawns is not known; no level known
		{ name = "Kroog", npcID = 262716, displayID = 17273, rare = true,
			notes = { "A rare, listed here as a best guess. Where it spawns is not known yet." },
			loot = { Seen(279857, "Kroog's Backscratcher", "One-Hand, Dagger"), Seen(279863, "Black Horn Necklace", "Neck") } },
		-- (the trash's ten and the dungeon's one recipe: above)
		{ name = "Trash Drops", trash = true, loot = {
			Seen(287007, "Stretched Footpads", "Feet, Cloth"), Seen(287008, "Ogre Magi's Mantle", "Shoulder, Cloth"),
			Seen(287009, "Twilight Enforcer's Legs", "Legs, Leather"),
			Seen(287010, "Outrider's Gloves", "Hands, Leather", "Twilight Outrider"),
			Seen(287011, "Guise of Battle", "Head, Mail"), Seen(287012, "Krol'dok Warplate Gauntlets", "Hands, Plate"),
			Seen(287013, "Krol'dok Warplate Legplates", "Legs, Plate"), Seen(287014, "Krol'dok Warplate Pauldrons", "Shoulder, Plate"),
			Seen(287015, "Supreme Smasher", "Two-Hand, Mace"), Seen(287016, "Shadow-Seer Orb", "Held In Off-hand") } },
		{ name = "Recipes", recipes = true, loot = {
			Recipe(273101, "Blueprint: Expert Campfire", "Cooking", 2, "Slavecrusher Grox") } },
	}),
	map = { floors = { { art = MAPS .. "KroldokStronghold", artBottom = PICTURE } } },
	--[[
		The Krol'dok Compound Key, one chain for each side (2026-11-08, read by hand from the quests' own pages,
		facts only): a Krol'dok Moulding starts the first quest; the smith its second quest's text is, who takes
		the moulding, makes the key. The moulding drops from Tunk, the blacksmith in Krol'dok, when he is killed: a
		player's report on the journal's Discord (Obsolete, 2026-11-08; the kill confirmed through the owner,
		2026-11-09), the item's own source still blank on its Wowhead page (2026-11-09), which has Tunk (npc 259256)
		as an elite blacksmith and each side's moulding as party loot: everyone in the group gets one. What the key
		opens is not known yet. Their quests are step pages (below), not rows: they are done outside.
		Where Tunk stands (the owner's answer of 2026-11-19, checked that day against players' notes, our own words): inside
		the stronghold (sure: several players, none saying otherwise), an ogre always at his anvil a short way northeast of
		Handler Ashka (fairly sure: three players say northeast of her, two more next to her, and the creatures' spawn marks
		on the continent's map put him just east to northeast of her). Her name as the journal's boss list gives it, so the
		text hides it in Adventure Mode until she is met.
	]]
	prepare = {
		{
			faction = "Alliance",
			title = "The Krol'dok Compound Key",
			kind = "key",
			text = "A {item:267138:Krol'dok Moulding} starts Krol'dok Moulding. Tunk, the blacksmith in Krol'dok, drops "
				.. "it when killed, one for everyone in the group. He is an elite ogre at his anvil, a short way "
				.. "northeast of Handler Ashka. Take it to "
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
				.. "it when killed, one for everyone in the group. He is an elite ogre at his anvil, a short way "
				.. "northeast of Handler Ashka. Take it to "
				.. "Kreza Darkthorn in Rog'mar, in the Riverglades, who makes the {item:267089:Krol'dok Compound Key} from "
				.. "4 Thick Leather and 12 Iron Bars. What it opens is not known yet.",
			quests = { 94973, 94974 },
			haveWhen = "done",
		},
		--[[
			Each side's way in to the dungeon's quests (the owner's notes of 2026-11-18; the steps, and how sure each is: the
			Krol'dok block's comment in Data/Authored/QuestAudit.lua): a chain to do first, done once its last step is handed
			in, its steps marked on the world map (UI/QuestMap.lua), as Alcaz Prison's way in from Stormwind. The steps' pages
			are below (ns.AddQuestSteps). Each ends where the dungeon quests after it part ways (the owner's direction of
			2026-11-19: the road kept once, in Before you go, each quest's + a line for it and then the quest's own steps,
			UI/QuestsPanel.lua): the Horde's at Da'grosh's Bring Me His Head, after which he gives A Token of Vengeance, and
			his It Is Time, Brother..., which only Eye of Mugg and Tome of Twilight need, is their own step (its page keeps
			its marks on the map: mapMarks); the Alliance's at Sergeant Riftan's Bring Me His Head, both Farholde Keep quests
			first, as either may be the one that opens The Western Front. The smoke test keeps every road so: no quest may
			need a road's middle but not its end.
			Krom'rosh's Food for the Taking is in the Horde's list as a step to do, though no lock waits on it (it may be
			optional): a player who skips it ends at 18 of 19, done, as one who does one Farholde Keep quest ends at 5 of 6.
			Tran'gul's place: just north of Krom'rosh, indoors (both their spots in Forever's quest data, and players' notes;
			what kind of building it is, a best guess, is left unsaid).
			Ashe Amberhall's own two, before her Tome of Twilight, are named in its text only. Where a first step's giver gives
			the dungeon quest too (Krom'rosh, Demar Brant), the step's open "!" stands there in place of the dungeon quest's
			grey one (UI/QuestMap.lua's MarksOn), at a level the step is not grey for (none for a grey quest, as the client).
		]]
		{
			faction = "Horde",
			title = "The road from Rog'mar",
			text = "Krom'rosh, in Rog'mar in the Riverglades, gives A Message in Blood and Food for the "
				.. "Taking, then Show Them How It's Done. Tran'gul, in the building just north of him, gives "
				.. "Twilight Missives, then Digging for Answers, which sends you to the ogre Clubtoe, under a "
				.. "ruined house in Sunnyglade. "
				.. "After Clubtoe's quests, take Chogg's head to Tran'gul and on to Clugfist in Bolder'ok, to "
				.. "the north. After his two quests, Clugfist's Decree takes you back to Krom'rosh for The "
				.. "Wayward Warrior. Da'grosh, west of Rog'mar, wants three quests and then his elite Bring Me His "
				.. "Head: bring friends. That opens his A Token of Vengeance, and his It Is Time, Brother... takes "
				.. "you back to Krom'rosh for Eye of Mugg; Tran'gul then gives Tome of Twilight.",
			quests = { 93786, 93787, 94483, 94680, 94727, 95417, 95601, 95602, 95427, 95418, 95420, 95424, 95425, 95428,
				94744, 94745, 94748, 95431, 94768 },
			haveWhen = "done",
			chain = true,
			mapMarks = true,
		},
		{
			faction = "Alliance",
			title = "The road from Farholde Keep",
			text = "In Farholde Keep, in the Riverglades, do Ashe Amberhall's Scraps of Knowledge and Demar "
				.. "Brant's Saving Sunnyglade (one of them may be enough) for Brant's The Western Front, which "
				.. "sends you to Sergeant Riftan in the Twilight's Shroud. Do his No Soldier Left Behind and "
				.. "Carving a Path, then his elite Bring Me His Head: bring friends. Then Riftan gives Twilight "
				.. "Mementos, and Brant Eye of Mugg. Ashe's own Tome of Twilight comes after her Curious Trinkets "
				.. "and A Small Favor.",
			quests = { 94879, 94877, 94886, 94888, 94889, 94890 },
			haveWhen = "done",
			chain = true,
			mapMarks = true,
		},
	},
})

--[[
	Krol'dok's fights, as the one combat log of a player's recorded run saw them (2026-11-13, read by the journal's
	Log Reader page: the recording's FIGHT and SPELL lines): each boss's spells with their damage and timings, and the
	creatures that cast beside it (its adds), in the shape Dev/build_data.py writes into Data/Generated/Abilities.lua.
	That tool reads only Data/Instances, never these placeholders, so they are written here by hand, through the
	tool's own reading of those lines. As everywhere, the journal leaves out what a creature cast only on itself
	(Grox's Bloodlust, Zarmok's Enrage; the Krol'dok Shamans' Lightning Shield, so they were no add) and a creature
	that cast nothing (the Riding Wolf with Ashka). Mugg's weapon changes were left out so too, until 2026-11-14
	(below). One log: the numbers are one fight's each.

	Added from a player's combat log of another run (2026-11-12, read through its log site's pages, which show no
	spell ids), the owner's call of 2026-11-14:
	- Bossman Toof's fight, all new: his spells, and his two adds. Spell ids from the client's spell table where the
	  name and the creature fit; ALL BEST GUESSES (marked below), for a raw combat log to settle. Nothing in the
	  client's spell table or hotfix cache ties a spell to Toof. The hotfix cache's own Mortal Strike (1328019), Cleaves
	  (1327248, 1327716, 1328013) and Bloodlust (1325968) belong to unknown creatures and could be his or his adds': a
	  raw combat log would settle it.
	- Mugg's weapon changes and Mugg's Fury, shown now (below).
	Nothing else that log showed was missing here: Grox's five Redridge Prisoners only hit in melee, so they are no
	add, as above.
]]
ns.SetAbilities({ KroldokStronghold = {
	["Slavecrusher Grox"] = {
		abilities = {
			{ spellID = 1280085, name = "Force Compliance", school = 1, every = { 17, 17 }, firstCast = 7 },
			{ spellID = 11428, name = "Knockdown", school = 1,
				hit = { 124, 124, 124 }, every = { 13, 13 }, firstCast = 9 },
			{ spellID = 21049, name = "Bloodlust", school = 8, firstCast = 28, onSelf = true },
		},
		encounterID = 3450,
	},
	["Twilight Commander Zarmok"] = {
		abilities = {
			{ spellID = 12057, name = "Strike", school = 1, hit = { 197, 197, 197 }, every = { 8, 10 }, firstCast = 7 },
			{ spellID = 1296130, name = "Rending Whirl", school = 1, every = { 13, 13 }, firstCast = 9 },
			{ spellID = 1280011, name = "Rending Whirl", school = 1,
				hit = { 703, 818, 760 }, tick = { 2, 203 }, every = { 13, 13 }, firstCast = 9 },
			{ spellID = 8599, name = "Enrage", school = 1, firstCast = 17, onSelf = true },
		},
		encounterID = 3452,
	},
	["Handler Ashka"] = {
		abilities = {
			{ spellID = 9128, name = "Battle Shout", school = 1, firstCast = 1 },
			{ spellID = 12057, name = "Strike", school = 1, hit = { 301, 305, 303 }, every = { 7, 8 }, firstCast = 6 },
			{ spellID = 1282076, name = "Command: Kill!", school = 1, firstCast = 9 },
		},
		adds = {
			{ name = "Snarlfang", npcID = 259283, abilities = {
				{ spellID = 13445, name = "Rend", school = 1, tick = { 27, 27 }, every = { 21, 21 }, firstCast = 4 },
			} },
			{ name = "Terrorhowl", npcID = 259285, abilities = {
				{ spellID = 1282071, name = "Frightening Howl", school = 32, firstCast = 16 },
			} },
		},
		encounterID = 3453,
	},
	["Nar'gurk"] = {
		abilities = {
			{ spellID = 1280356, name = "Shadow Bolt Volley", school = 32,
				hit = { 105, 485, 377 }, every = { 22, 29 }, firstCast = 6 },
			{ spellID = 1280259, name = "Convert", school = 32, every = { 32, 32 }, firstCast = 14 },
		},
		adds = {
			{ name = "Twilight Warlock", npcID = 258100, abilities = {
				{ spellID = 20787, name = "Immolate", school = 4,
					hit = { 104, 183, 170 }, tick = { 19, 58 }, every = { 0, 11 }, firstCast = 2 },
				{ spellID = 20754, name = "Rain of Fire", school = 4,
					tick = { 224, 250 }, every = { 1, 18 }, firstCast = 11 },
			} },
			{ name = "Shadowhide Curseweaver", npcID = 258040, abilities = {
				{ spellID = 9613, name = "Shadow Bolt", school = 32,
					hit = { 139, 176, 152 }, every = { 5, 9 }, firstCast = 3 },
				{ spellID = 13338, name = "Curse of Tongues", school = 32, every = { 16, 16 }, firstCast = 6 },
			} },
		},
		encounterID = 3449,
	},
	["Bossman Toof"] = {
		-- Best guesses: the Krol'dok Centurion's three spells (Mugg's add, below), the same three names on another ogre
		-- warrior of this dungeon, with numbers that fit his (Mortal Strike 611 over 2 hits; Thunderclap 236 on 4 players)
		abilities = {
			{ spellID = 16856, name = "Mortal Strike", school = 1, hit = { 305, 305, 305 }, every = { 12, 12 }, firstCast = 7 },
			{ spellID = 16244, name = "Demoralizing Shout", school = 1, firstCast = 8 },
			{ spellID = 15548, name = "Thunderclap", school = 8, hit = { 59, 59, 59 }, firstCast = 16 },
		},
		adds = {
			-- Its creature id from the earlier recording (its Lightning Shield, 12550, there). Bloodlust: a best guess,
			-- Grox's (21049, recorded in this dungeon: "an ally's attack speed"); cast on Toof at 18 and 31 s.
			-- Its Lightning Bolt: with Toof's written abilities, in his entry above.
			{ name = "Krol'dok Shaman", npcID = 257888, abilities = {
				{ spellID = 21049, name = "Bloodlust", school = 8, every = { 13, 13 }, firstCast = 18, flags = { "Magic" } },
			} },
			-- No creature id yet. Strike: a best guess, Zarmok's and Ashka's (12057, recorded in this dungeon). Its
			-- Cleave: Toof's written abilities.
			{ name = "Krol'dok Brute", abilities = {
				{ spellID = 12057, name = "Strike", school = 1 },
			} },
		},
	},
	--[[
		Mugg's weapon changes and Mugg's Fury, cast on himself, are shown all the same: they change the fight. The
		recording saw Set of Maces 52 s and Set of Mauls 72 s into the fight; the 2026-11-12 log, a faster kill, 30 s and
		47 s. So no first cast for them: they likely come at set points of his health, not on a timer (a best guess).
		Mugg's Fury, by its name in the client's hotfix cache (2026-11-14): 1282387 is the buff the log saw drop at each
		change and come back 2-4 s later (1282386, the passive that gives it).
	]]
	["Overseer Mugg"] = {
		abilities = {
			{ spellID = 1282397, name = "Crushing Slam", school = 1,
				hit = { 310, 635, 575 }, every = { 2, 24 }, firstCast = 6 },
			{ spellID = 1282393, name = "Set of Maces", school = 1, flags = { "Tank", "Important" },
				text = "He takes up two one-handed maces, and his melee hits harder. It came 52 seconds into one fight and 30 seconds into a faster kill, so it likely comes at a set point of his health (a best guess). With the maces his Crushing Slam can hit three players at once." },
			{ spellID = 1282394, name = "Set of Mauls", school = 1, flags = { "Tank", "Important" },
				text = "He takes up two two-handed mauls, and his melee hits harder again. It came 72 seconds into one fight and 47 seconds into a faster kill, so it likely comes at a set point of his health too (a best guess)." },
			{ spellID = 1282387, name = "Mugg's Fury", flags = { "Tank" },
				text = "Each of his melee hits makes him attack faster. It starts over each time he changes weapons." },
		},
		adds = {
			{ name = "Krol'dok Centurion", npcID = 257885, abilities = {
				{ spellID = 16856, name = "Mortal Strike", school = 1,
					hit = { 297, 533, 359 }, every = { 2, 15 }, firstCast = 3 },
				{ spellID = 16244, name = "Demoralizing Shout", school = 1, every = { 16, 16 }, firstCast = 9 },
				{ spellID = 15548, name = "Thunderclap", school = 8,
					hit = { 40, 81, 71 }, every = { 16, 16 }, firstCast = 14 },
			} },
		},
		encounterID = 3451,
	},
} })


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
	-- Amberhall's, by Amberhall's Soulstone, which it gives you; she takes it back too (its page's end NPC, 2026-11-17).
	-- After her Curious Trinkets (since the owner's evening notes of 2026-11-18: a player, another addon's chain view the
	-- owner saw, and its own text, "the reagents you collected").
	[94907] = {
		name = "A Small Favor", level = 44, requiredLevel = 36, faction = "Alliance",
		pickup = "Ashe Amberhall, Farholde Keep, Riverglades", startMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		turnin = "Ashe Amberhall, Farholde Keep, Riverglades", endMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		objective = "Summon a Twilight Thrall from a conduit within the Twilight Shroud and capture it with Amberhall's Soulstone.",
		note = "It can't be shared.",
		rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
		prerequisites = { { questID = 94881, name = "Curious Trinkets" } },
	},
	--[[
		Each side's way in to Krol'dok's dungeon quests (2026-11-18; what was read, and how sure: the Krol'dok block's
		comment in Data/Authored/QuestAudit.lua, which locks the quests behind these). Levels, sides, givers, takers,
		spots, rewards and sharing: the quests' pages in Forever's quest database; The Western Front's level and objective
		in the client's own quest cache too; the reward items' names the client's item data's. XP left out, as for every
		Krol'dok quest. What each step needs first: the Alliance's Bring Me His Head after The Western Front (three
		players: Sergeant Riftan offers nothing before it); the Horde's Bring Me His Head after Da'grosh's three (both
		players did them first; Rise Up!, after Rumblings of Discontent, one of them calls not needed), It Is Time,
		Brother... after it (both players), and The Wayward Warrior after Clugfist's Decree (its page's series).
		Since the owner's evening notes of 2026-11-18 (more players' notes, the owner's pictures; the steps and how sure
		each is: that same comment): each chain from its first quest, below. The Western Front after Scraps of Knowledge
		or Saving Sunnyglade, either one; Riftan's Bring Me His Head after his No Soldier Left Behind and Carving a Path
		too. The Horde's from Krom'rosh's A Message in Blood in Rog'mar (his Food for the Taking, which players did beside
		it, has a page but comes before nothing: it may be optional), through Tran'gul's, the ogre Clubtoe's under a
		ruined house in Sunnyglade and Clugfist's in Bolder'ok, to Clugfist's Decree. Each page says only the steps just
		before it. The objectives are the quests' own words (Unworthy Champion's calls Klunk's club Skullthumper; the
		item is Skullbasher, the client's item data's name); the notes are players' (a few each, on the quests' pages).
		The reward items' names: the client's item data's. The Bolder'ok Clan's reputation, which the Horde's ogre
		quests give, is left out: the journal has no id for that faction yet.
	]]
	[94886] = {
		name = "The Western Front", level = 44, requiredLevel = 38, faction = "Alliance",
		pickup = "Demar Brant, Farholde Keep, Riverglades", startMap = Riverglades(0.666, 0.81, "Demar Brant"),
		turnin = "Sergeant Riftan, the Twilight's Shroud, Riverglades", endMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		objective = "Find Sergeant Riftan near the Twilight's Shroud to the west.",
		prerequisites = {
			ns.OneOf("Scraps of Knowledge", { questID = 94879, name = "Scraps of Knowledge" },
				{ questID = 94877, name = "Saving Sunnyglade" }),
		},
	},
	[94890] = {
		name = "Bring Me His Head", level = 46, requiredLevel = 38, faction = "Alliance",
		pickup = "Sergeant Riftan, the Twilight's Shroud, Riverglades", startMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		turnin = "Sergeant Riftan, the Twilight's Shroud, Riverglades", endMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		objective = "Defeat Overlord Kilgar within the Twilight's Shroud and bring his head to Sergeant Riftan.",
		note = "An elite quest: bring friends. Overlord Kilgar is in the big hut in the Twilight's Shroud, at 26.6, 44.8.",
		rewards = {
			choice = true,
			items = { { itemID = 275046, name = "Twilight Overlord Drape" }, { itemID = 275049, name = "Farholde Bastion" } },
			reputation = { { faction = "Brotherhood of the Horse", amount = 150 } },
		},
		prerequisites = {
			{ questID = 94886, name = "The Western Front" },
			{ questID = 94888, name = "No Soldier Left Behind" },
			{ questID = 94889, name = "Carving a Path" },
		},
	},
	[94744] = {
		name = "The Wayward Warrior", level = 43, requiredLevel = 38, faction = "Horde",
		pickup = "Krom'rosh, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		turnin = "Da'grosh, outside Krol'dok Stronghold, Riverglades", endMap = Riverglades(0.334, 0.38, "Da'grosh"),
		objective = "Find Da'grosh in the hills west of Rog'mar.",
		prerequisites = { { questID = 95428, name = "Clugfist's Decree" } },
	},
	[94768] = {
		name = "Bring Me His Head", level = 46, requiredLevel = 38, faction = "Horde",
		pickup = "Da'grosh, outside Krol'dok Stronghold, Riverglades", startMap = Riverglades(0.334, 0.38, "Da'grosh"),
		turnin = "Da'grosh, outside Krol'dok Stronghold, Riverglades", endMap = Riverglades(0.334, 0.38, "Da'grosh"),
		objective = "Defeat Overlord Kilgar within the Twilight's Shroud and bring his head to Da'grosh.",
		note = "An elite quest: bring friends. Overlord Kilgar is in the big hut in the Twilight's Shroud, at 26.6, 44.8.",
		rewards = {
			choice = true,
			items = { { itemID = 275050, name = "Cloak of the Cult" }, { itemID = 275051, name = "Twilight Barrier" } },
		},
		prerequisites = {
			{ questID = 94744, name = "The Wayward Warrior" },
			{ questID = 94745, name = "Carving a Path" },
			{ questID = 94748, name = "Break Their Chains" },
			{ questID = 95431, name = "Rumblings of Discontent" },
		},
	},
	[95278] = {
		name = "It Is Time, Brother...", level = 45, requiredLevel = 38, faction = "Horde",
		pickup = "Da'grosh, outside Krol'dok Stronghold, Riverglades", startMap = Riverglades(0.334, 0.38, "Da'grosh"),
		turnin = "Krom'rosh, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		objective = "Deliver the missive to Krom'rosh at Rog'mar.",
		note = "Da'grosh gives you the missive, Blood and Battle. It can't be shared.",
		prerequisites = { { questID = 94744, name = "The Wayward Warrior" }, { questID = 94768, name = "Bring Me His Head" } },
		-- Its marks on the world map of its own (UI/QuestMap.lua's Walk): no longer on the road (since 2026-11-19), whose
		-- marks it had, as only Eye of Mugg and Tome of Twilight need it.
		mapMarks = true,
	},
	-- The Alliance's first steps, in Farholde Keep: Demar Brant's Saving Sunnyglade and Ashe Amberhall's two (none needs
	-- another first), then Sergeant Riftan's two after The Western Front.
	[94877] = {
		name = "Saving Sunnyglade", level = 40, requiredLevel = 36, faction = "Alliance",
		pickup = "Demar Brant, Farholde Keep, Riverglades", startMap = Riverglades(0.666, 0.81, "Demar Brant"),
		turnin = "Demar Brant, Farholde Keep, Riverglades", endMap = Riverglades(0.666, 0.81, "Demar Brant"),
		objective = "Defeat 8 Twilight Raiders, 8 Twilight Shadowmancers, and 8 Twilight Neophytes within Sunnyglade for Demar Brant.",
		rewards = {
			choice = true,
			items = { { itemID = 274919, name = "Neophyte's Wand" }, { itemID = 274920, name = "Twilight Carver" } },
			reputation = { { faction = "Brotherhood of the Horse", amount = 100 } },
		},
	},
	[94879] = {
		name = "Scraps of Knowledge", level = 40, requiredLevel = 36, faction = "Alliance",
		pickup = "Ashe Amberhall, Farholde Keep, Riverglades", startMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		turnin = "Ashe Amberhall, Farholde Keep, Riverglades", endMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		objective = "Collect 5 Twilight Pages from within Sunnyglade for Ashe Amberall in Farholde Keep.",
		note = "The pages are small white maps on crates in Sunnyglade's ruined houses.",
		rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
	},
	[94881] = {
		name = "Curious Trinkets", level = 38, requiredLevel = 36, faction = "Alliance",
		pickup = "Ashe Amberhall, Farholde Keep, Riverglades", startMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		turnin = "Ashe Amberhall, Farholde Keep, Riverglades", endMap = Riverglades(0.667, 0.811, "Ashe Amberhall"),
		objective = "Retrieve 25 Twilight Charms from Twilight Shadowmancers and Twilight Neophytes in Sunnyglade for Ashe Amberhall in Farholde Keep.",
		rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
	},
	[94888] = {
		name = "No Soldier Left Behind", level = 44, requiredLevel = 38, faction = "Alliance",
		pickup = "Sergeant Riftan, the Twilight's Shroud, Riverglades", startMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		turnin = "Sergeant Riftan, the Twilight's Shroud, Riverglades", endMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		objective = "Rescue 5 Farholde Scouts within the Twilight's Shroud for Sergeant Riftan.",
		note = "The Twilight Champions drop the Twilight Keys. The other side's scouts have cages of their own: if a cage won't open, try another.",
		rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
		prerequisites = { { questID = 94886, name = "The Western Front" } },
	},
	[94889] = {
		name = "Carving a Path", level = 44, requiredLevel = 38, faction = "Alliance",
		pickup = "Sergeant Riftan, the Twilight's Shroud, Riverglades", startMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		turnin = "Sergeant Riftan, the Twilight's Shroud, Riverglades", endMap = Riverglades(0.306, 0.49, "Sergeant Riftan"),
		objective = "Defeat 8 Twilight Fanatics, 8 Twilight Corrupters, and 8 Twilight Champions within the Twilight's Shroud for Sergeant Riftan.",
		rewards = { reputation = { { faction = "Brotherhood of the Horse", amount = 100 } } },
		prerequisites = { { questID = 94886, name = "The Western Front" } },
	},
	-- The Horde's first steps: Krom'rosh's in Rog'mar, then Tran'gul's, just north of him.
	[93786] = {
		name = "A Message in Blood", level = 36, requiredLevel = 35, faction = "Horde",
		pickup = "Krom'rosh, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		turnin = "Krom'rosh, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		objective = "Slay 12 Meadowsbrook Farmhands, then return to Krom'rosh with news of your success.",
	},
	[93787] = {
		name = "Food for the Taking", level = 36, requiredLevel = 36, faction = "Horde",
		pickup = "Krom'rosh, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		turnin = "Krom'rosh, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		objective = "Steal 6 Feed Satchels from the Alliance farm in Meadowsbrook then return to Krom'rosh.",
	},
	[94483] = {
		name = "Show Them How It's Done", level = 39, requiredLevel = 36, faction = "Horde",
		pickup = "Krom'rosh, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		turnin = "Krom'rosh, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		objective = "Slay 8 Farholde Priests and 12 Farholde Scouts south of the river.",
		note = "Few priests show at first: they take the scouts' places as those come back, so kill scouts until enough priests appear.",
		prerequisites = { { questID = 93786, name = "A Message in Blood" } },
	},
	[94680] = {
		name = "Twilight Missives", level = 41, requiredLevel = 36, faction = "Horde",
		pickup = "Tran'gul, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.44, "Tran'gul"),
		turnin = "Tran'gul, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.44, "Tran'gul"),
		objective = "Retrieve 3 Twilight Missives from Twilight Shadowmancers in Sunnyglade for Tran'gul in Rog'mar.",
		prerequisites = { { questID = 94483, name = "Show Them How It's Done" } },
	},
	[94727] = {
		name = "Digging for Answers", level = 40, requiredLevel = 36, faction = "Horde",
		pickup = "Tran'gul, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.44, "Tran'gul"),
		turnin = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", endMap = Riverglades(0.499, 0.47, "Clubtoe"),
		objective = "Convince a Twilight's Hammer miner in Sunnyglade to divulge their secrets.",
		note = "Clubtoe is down the stairs into a cellar under a ruined house in Sunnyglade, at 50, 46. Beat him until he gives in (it flags you for PvP).",
		prerequisites = { { questID = 94680, name = "Twilight Missives" } },
	},
	-- The ogre Clubtoe's, under a ruined house in Sunnyglade: The Purple Ones in two parts (the first ends at a dead ogre
	-- in the caves below, whose own quest is the second), Sickening Lights beside them, then Twilight No More!. The dead
	-- ogre's spot is the database's end point for the first part (one of the 15 spots of its Twilight Brutes, 45, 50.2 to
	-- 49.2, 46.8): not yet seen in the game.
	[95417] = {
		name = "The Purple Ones", level = 40, requiredLevel = 36, faction = "Horde",
		pickup = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", startMap = Riverglades(0.499, 0.47, "Clubtoe"),
		turnin = "A dead Twilight Brute, in the caves under Sunnyglade, Riverglades",
		endMap = Riverglades(0.492, 0.468, "Twilight Brute"),
		objective = "Find missing ogres in the caves beneath Sunnyglade for Clubtoe.",
		prerequisites = { { questID = 94727, name = "Digging for Answers" } },
	},
	[95601] = {
		name = "The Purple Ones", level = 40, requiredLevel = 36, faction = "Horde",
		pickup = "A dead Twilight Brute, in the caves under Sunnyglade, Riverglades",
		startMap = Riverglades(0.492, 0.468, "Twilight Brute"),
		turnin = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", endMap = Riverglades(0.499, 0.47, "Clubtoe"),
		objective = "Kill 5 Empowered Brutes and 10 Twilight Ritualists then return to Clubtoe in Sunnyglade.",
		prerequisites = { { questID = 95417, name = "The Purple Ones" } },
	},
	[95602] = {
		name = "Sickening Lights", level = 40, requiredLevel = 36, faction = "Horde",
		pickup = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", startMap = Riverglades(0.499, 0.47, "Clubtoe"),
		turnin = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", endMap = Riverglades(0.499, 0.47, "Clubtoe"),
		objective = "Destroy 5 Twilight Ritual Circles found throughout the caves underneath Sunnyglade.",
		note = "The circles can't be used while shapeshifted.",
		prerequisites = { { questID = 94727, name = "Digging for Answers" } },
	},
	[95427] = {
		name = "Twilight No More!", level = 41, requiredLevel = 36, faction = "Horde",
		pickup = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", startMap = Riverglades(0.499, 0.47, "Clubtoe"),
		turnin = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", endMap = Riverglades(0.499, 0.47, "Clubtoe"),
		objective = "Kill Chogg'Zac in the Sunnyglade cave and collect their heads for Clubtoe.",
		note = "An elite quest: bring friends. Chogg'Zac is at the far end of the caves under Sunnyglade.",
		prerequisites = { { questID = 95601, name = "The Purple Ones" }, { questID = 95602, name = "Sickening Lights" } },
	},
	-- Chogg's head back to Tran'gul, then on to Clugfist in Bolder'ok, the ogres' city to the north, and his.
	[95418] = {
		name = "Spread the Word", level = 40, requiredLevel = 36, faction = "Horde",
		pickup = "Clubtoe, under a ruined house in Sunnyglade, Riverglades", startMap = Riverglades(0.499, 0.47, "Clubtoe"),
		turnin = "Tran'gul, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.44, "Tran'gul"),
		objective = "Deliver the head of Chogg to Tran'gul in Rog'mar.",
		note = "It can't be shared.",
		prerequisites = { { questID = 95427, name = "Twilight No More!" } },
	},
	[95420] = {
		name = "Land of Giants", level = 40, requiredLevel = 36, faction = "Horde",
		pickup = "Tran'gul, Rog'mar, Riverglades", startMap = Riverglades(0.594, 0.44, "Tran'gul"),
		turnin = "Clugfist, Bolder'ok, Riverglades", endMap = Riverglades(0.644, 0.148, "Clugfist"),
		objective = "Deliver Chogg's head to the ogre city to the north.",
		note = "It can't be shared.",
		prerequisites = { { questID = 95418, name = "Spread the Word" } },
	},
	[95424] = {
		name = "Might Makes Right", level = 41, requiredLevel = 36, faction = "Horde",
		pickup = "Clugfist, Bolder'ok, Riverglades", startMap = Riverglades(0.644, 0.148, "Clugfist"),
		turnin = "Clugfist, Bolder'ok, Riverglades", endMap = Riverglades(0.644, 0.148, "Clugfist"),
		objective = "Kill 7 Twilight Maulers and 7 Twilight Firecallers for Clugfist in Bolder'ok.",
		prerequisites = { { questID = 95420, name = "Land of Giants" } },
	},
	[95425] = {
		name = "Unworthy Champion", level = 42, requiredLevel = 36, faction = "Horde",
		pickup = "Clugfist, Bolder'ok, Riverglades", startMap = Riverglades(0.644, 0.148, "Clugfist"),
		turnin = "Clugfist, Bolder'ok, Riverglades", endMap = Riverglades(0.644, 0.148, "Clugfist"),
		objective = "Collect Skullthumper from Klunk for Clugfist in Bolder'ok.",
		note = "Klunk has Skullbasher, the club this asks for. He is in the cave whose way in is at 76, 26, in a small pocket on its left.",
		prerequisites = { { questID = 95420, name = "Land of Giants" } },
	},
	[95428] = {
		name = "Clugfist's Decree", level = 41, requiredLevel = 36, faction = "Horde",
		pickup = "Clugfist, Bolder'ok, Riverglades", startMap = Riverglades(0.644, 0.148, "Clugfist"),
		turnin = "Krom'rosh, Rog'mar, Riverglades", endMap = Riverglades(0.594, 0.456, "Krom'rosh"),
		objective = "Report to Krom'rosh in Rog'mar.",
		prerequisites = { { questID = 95424, name = "Might Makes Right" }, { questID = 95425, name = "Unworthy Champion" } },
	},
	-- Da'grosh's three before his Bring Me His Head (above), after The Wayward Warrior.
	[94745] = {
		name = "Carving a Path", level = 44, requiredLevel = 38, faction = "Horde",
		pickup = "Da'grosh, outside Krol'dok Stronghold, Riverglades", startMap = Riverglades(0.334, 0.38, "Da'grosh"),
		turnin = "Da'grosh, outside Krol'dok Stronghold, Riverglades", endMap = Riverglades(0.334, 0.38, "Da'grosh"),
		objective = "Defeat 8 Twilight Fanatics, 8 Twilight Corrupters, and 8 Twilight Champions within the Twilight's Shroud for Da'grosh.",
		prerequisites = { { questID = 94744, name = "The Wayward Warrior" } },
	},
	[94748] = {
		name = "Break Their Chains", level = 44, requiredLevel = 38, faction = "Horde",
		pickup = "Da'grosh, outside Krol'dok Stronghold, Riverglades", startMap = Riverglades(0.334, 0.38, "Da'grosh"),
		turnin = "Da'grosh, outside Krol'dok Stronghold, Riverglades", endMap = Riverglades(0.334, 0.38, "Da'grosh"),
		objective = "Rescue 5 Rog'mar Scouts within the Twilight's Shroud for Da'grosh.",
		note = "The Twilight Champions drop the Twilight Keys. The other side's scouts have cages of their own: if a cage won't open, try another.",
		prerequisites = { { questID = 94744, name = "The Wayward Warrior" } },
	},
	[95431] = {
		name = "Rumblings of Discontent", level = 41, requiredLevel = 38, faction = "Horde",
		pickup = "Da'grosh, outside Krol'dok Stronghold, Riverglades", startMap = Riverglades(0.334, 0.38, "Da'grosh"),
		turnin = "Crag'rog, in a cave near Da'grosh, Riverglades", endMap = Riverglades(0.274, 0.37, "Crag'rog"),
		objective = "Look for the Bolder'ok ogre in the nearby cave.",
		prerequisites = { { questID = 94744, name = "The Wayward Warrior" } },
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
		The way in and the fights: from players' guides to the dungeon (one of 2026-11-08, the owner's pick, and the two
		the owner gave on 2026-11-17), facts only, in our own words; its first runs, so all of it can change. The order is the
		one players first reported; the game's own list (below) puts Tidemistress Ca'zass second and The Questioner fourth,
		and one of the 2026-11-17 guides calls Ca'zass the first boss. The order stays until the owner says (2026-11-17).
		Blazeroar is the last.

		The game's numbers, from Forever's own client files (1.60.1.70959, read 2026-11-17 with the keys the client itself
		holds; no run of the dungeon is recorded anywhere yet, so none of them is seen in a run):
		- the dungeon (instanceID): its Map row, 2994, "Alcaz Prison", a five-player dungeon. Without it the journal knew
		  the player was inside only by the client's name for it (Core/Registry.lua, LearnInstanceID).
		- each fight (encounterID): its DungeonEncounter row on map 2994, named as the journal names the boss: Overseer
		  Wrex 3403, Tidemistress Ca'zass 3410, Katerina the Cleaner 3418, The Questioner 3415, Blazeroar 3409. By its id
		  a fight's end counts the kill in any language, and the Record tab files its drops under the boss. Their
		  corpses are watched too (watchCorpse, UI/DungeonMap.lua), as for the Drowned City's Primeval Elemental: should
		  the game start no fight of these ids, seeing the boss dead still counts him.

		Creature ids (npcID) and models (displayID): Forever's NPC data (2026-11-17), each model checked in the client's
		files (its CreatureDisplayInfo row in an open part of the table, its model file read whole). Overseer Wrex's
		creature, 255391, is the NPC data's alone: the client has no row or cache entry for it yet. Blazeroar's model is
		the client's own link (a hotfix ties creature 255702 to model 149885, a drake at 0.8 scale); the NPC data's 6374 is
		the same drake model and skins.

		Blazeroar's fight (2026-11-17): both guides and the NPC data have it begin with Zarla Ober, a human prisoner
		(her own creature, 255707, model 139053), who at about 30% health reveals her true form and is fought again at full
		health as the dragon Blazeroar (255702), whose corpse holds the drops (her own creature drops nothing). The game
		calls the whole fight "Blazeroar" (3409): one boss, one circle in the run block, counted once at the fight's end.
		Her name is not one of his other names (aliases), on purpose (the review of e36e2fe): the corpse watcher counts a
		dead unit by an alias's name, so if the game kills her unit at the change, Blazeroar would be crossed out, and the
		run ended, before the dragon is fought. The fight counts by its id, 3409, in any language, and no fight in the
		client's files is named for her.
		The quests' own texts call her a black dragon; one guide and the owner's search summary say red, and her model's skins
		are a drake's dark scales with an orange underside: the notes say "dragon".

		Drops (loot): each boss's three blues, as Forever's NPC data lists them with the kills they were seen on
		(2026-11-17: all fifteen seen, each on hundreds of kills), the slot and type as its item pages give them; each id,
		name, slot and item level checked in the client's hotfix cache (ItemSparse and Item rows; in the client the
		boss items come in blocks of three in boss order). The quest items and the keyring as before; the Ornate Shackle
		Key (274029) also seen off The Questioner there. Left out: the Blood Red Bandana (274028), the Horde's quest item,
		seen now and then off three bosses and most of the human trash too, as other dungeons' quest items stay off their
		lists. Read again 2026-11-19: the same fifteen blues and quest items, on 916 to 1188 kills each, nothing new; Zarla
		Ober's own creature drops nothing, and the dungeon has no rare (every creature in it is elite).

		The trash (Forever's NPC and item data, 2026-11-19): all ten of the client's band 287017-287026, Bind on Equip
		blues of item level 52 to 54, each now seen dropping in the dungeon (until then two were, and a guide listed four
		more). Nine come from a pool every kind of its trash shares, each about one kill in a hundred or fewer (6 to 84
		drops in about 10,300 kills); the Enchantresses' Spire drops off the Strashaz Enchantresses alone (47 of 827
		kills; not off Tidemistress Ca'zass, whose list of 996 kills has none of it). The three leather pieces are the
		rest of the Defias Enforcer's Garb (set 2136), with The Questioner's shoulders and Blazeroar's legs. Its recipes:
		none of its own. The bosses drop none, and the trash only the classic world-drop recipes of the level, each seen
		once in hundreds of kills and all over the world: no Recipes entry (the owner, 2026-11-19: only loot of the
		dungeon's own). Only the dungeon's own (the owner's call of 2026-11-19), checked that day in each item's "dropped by"
		list: every trash row drops off the prison's own creatures alone, each placed in the dungeon. Nothing taken out.

		Boss spots (mapPin): the owner OK'd them on 2026-11-18, from the sheet (spots_preview, 2026-11-17), as they are
		here; still to be checked in game when someone runs it: no run of the dungeon is recorded or logged anywhere
		yet. Each is the middle of a room of the game's own building (the dungeon's one WMO, 7490002), laid on Santiago
		Reyes's pictures by one fit to the game's geometry (art x = 359.05 + 3.3118 x local, art y = -5.69 - 3.3118 y
		local; his drawn rooms agree within about 3 art pixels); which room is whose, from the guides' words and what
		the game puts in each room (each boss's comment).
	]]
	-- (a keep, as the game's own quest texts call the building, 2026-11-18; before, "tower")
	location = "The basement of the keep on Alcaz Island, Dustwallow Marsh",
	zoneEntrance = { mapID = 1445, x = 0.753, y = 0.141 },
	instanceID = 2994,
	bosses = Bosses({
		-- (the round hub at the end of the cell corridor Santiago labels "Main Unit", with three rooms off it and five
		-- weapon racks: it fits both guides, one with him walking the cells and rooms around him, the other in a side
		-- room he is pulled out of. A guess; Ca'zass's hub could be his instead. The owner OK'd it from the sheet,
		-- 2026-11-18; to be checked in game)
		{ name = "Overseer Wrex", npcID = 255391, displayID = 7914, encounterID = 3403, watchCorpse = true, level = 50, notes = {
			"The jail's overseer. He walks the cells and rooms around him, and pulling him brings their jailers and bounty hunters, six to eight of them: clear the rooms first, or draw him out into the corridor and crowd-control the extras.",
			"Mortal Strike cuts the tank's healing for a few seconds, and he shouts to strengthen his allies as the fight begins.",
			-- (no guide or quest says what it opens: the earlier line, from the first guide, said the locked door to the
			-- lower floor; the NPC data has it on only about one kill in ten, which fits no door everyone must pass)
			"What his Overseer's Keyring opens is not confirmed yet.",
		}, loot = { Seen(276732, "Alcaz Willcrusher", "Two-Hand, Mace"), Seen(276733, "Grips of Control", "Hands, Plate"),
			Seen(276734, "Wrex's Pinky Ring", "Finger"), QuestItem(263992, "Overseer's Keyring", 1, "Key") },
			mapPin = { x = 0.644, y = 0.339, floor = 1 } },
		-- (the green octagon left of the stairs down: a round room on the player's right soon after the way in, as the
		-- owner's search summary puts him, and the game puts four of the building's six torture racks in it. Likely; the
		-- owner OK'd it from the sheet, 2026-11-18; to be checked in game)
		{ name = "The Questioner", npcID = 256236, displayID = 140092, encounterID = 3415, watchCorpse = true, level = 51, notes = {
			"The prison's torturer. He has far more health than the other bosses: expect a long fight and save cooldowns for it.",
			-- (the owner's steps, 2026-11-13: Mason Connery, at the prison's end, asks for this boss's key, so he must still
			-- be alive then; this line takes the place of a player's warning of 2026-11-09 not to kill him before Blazeroar.
			-- The key, 274029, as the client's item data names it: a quest item. The Alliance's Somber News, and so Shaw Needs
			-- To Know, also need The Man in the Iron Chains, so the line names them too.)
			"If you want the Alcaz Operative Insignia toy, or the Alliance's Somber News and Shaw Needs To Know, skip him on your way in: his key is for Mason Connery's quest at the end, The Man in the Iron Chains, which they all need.",
		}, loot = { Seen(276742, "Girdle of Extracted Answers", "Waist, Plate"), Seen(276743, "Fingerbreaker Stamp", "Trinket"),
			Seen(276741, "Defias Enforcer's Shoulderpads", "Shoulder, Leather"), QuestItem(274029, "Ornate Shackle Key") },
			mapPin = { x = 0.247, y = 0.176, floor = 1 } },
		-- (the round hub at the end of the main corridor, straight on from the way in, with six hanging cages: the owner's
		-- search summary has her straight ahead past the entrance, the earlier note near the cells. A guess; the owner
		-- OK'd it from the sheet, 2026-11-18; to be checked in game)
		{ name = "Tidemistress Ca'zass", npcID = 255997, displayID = 4973, encounterID = 3410, watchCorpse = true, level = 50, notes = {
			"Leader of the Strashaz naga, near the cells not far from the entrance. Her Enchantresses cast Polymorph again and again: kill or interrupt them first; a Grounding Totem soaks it.",
			"She drops Blizzard on the group: move out of it. Frost Nova roots everyone near her: dispel it so no one is stuck in the Blizzard.",
		}, loot = { Seen(276735, "Tidesong Wand", "Ranged, Wand"), Seen(276736, "Seascale Bracers", "Wrist, Mail"),
			Seen(276737, "Cloak of the Tidemistress", "Back"), QuestItem(273883, "Ca'zass's Head") },
			mapPin = { x = 0.355, y = 0.719, floor = 1 } },
		-- (the lower floor's round hub under Ca'zass's, ringed with nine iron maidens, on the only way to the end: the
		-- prisoners around her room; the Horde's No Orc Left Behind counts her as its goal. A guess; the owner OK'd it
		-- from the sheet, 2026-11-18; to be checked in game)
		{ name = "Katerina the Cleaner", npcID = 257016, displayID = 2317, encounterID = 3418, watchCorpse = true, level = 52, notes = {
			-- (the NPC data has her spells as poison and a garrote, no fire, and one guide has the chaplains with her; the
			-- other guide's fire filling the room is left out: a question for the owner)
			"On the lower floor. Two Alcaz Chaplains fight beside her and heal: crowd-control or kill them first.",
			"Grievous Garrote hits a random player hard, then bleeds until they are healed above 90%. Dispel Deadly Poison from the tank quickly.",
			"Leave the prisoners chained around her room alone during the fight.",
		}, loot = { Seen(276738, "Katerina's Shanker", "One-Hand, Dagger"), Seen(276739, "Cutthroat Chestguard", "Chest, Mail"),
			Seen(276740, "Sentimental Locket", "Neck") },
			mapPin = { x = 0.391, y = 0.718, floor = 2 } },
		-- (the big four-lobed room at the far end, the building's biggest, furnished as a lived-in cell: beds, water
		-- buckets, bananas. Fairly sure; the owner OK'd it from the sheet, 2026-11-18; to be checked in game)
		{ name = "Blazeroar", npcID = 255702, displayID = 149885, encounterID = 3409,
			watchCorpse = true, level = 53, notes = {
			"The last boss: Zarla Ober, one of the prisoners, fights first with Fireball and Flamestrike. At about 30% health she shows her true form and is fought again at full health as the dragon Blazeroar. Fire did nothing to her in the first fights, so fire casters should switch to frost.",
			"As the dragon: Flame Breath hits the tank very hard, Searing Scales burns the whole group, and a fear sends everyone but the tank running (a Tremor Totem helps).",
			-- (a quest objective's note, read on the ground after the last boss for The Secret Prison and The Honor of the
			-- Kor'kron; one guide puts it in a hidden room after her, as the earlier line did)
			"After the fight, look for the note about King Varian Wrynn, past her: both sides' quests about the King need you to read it.",
		}, loot = { Seen(276744, "Zarla's Snack Pouch", "Trinket"), Seen(276745, "Beastbond Robe", "Chest, Cloth"),
			Seen(276746, "Defias Enforcer's Legguards", "Legs, Leather"), QuestItem(276890, "Zarla's Journal") },
			mapPin = { x = 0.665, y = 0.719, floor = 2 } },
		-- (the trash's ten: above)
		{ name = "Trash Drops", trash = true, loot = {
			Seen(287017, "Chaplain's Mitre", "Head, Cloth"), Seen(287018, "Compound Gloves", "Hands, Cloth"),
			Seen(287019, "Defias Enforcer's Mask", "Head, Leather"), Seen(287020, "Defias Enforcer's Chest", "Chest, Leather"),
			Seen(287021, "Defias Enforcer's Prowlers", "Feet, Leather"), Seen(287022, "Spaulders of Containment", "Shoulder, Mail"),
			Seen(287023, "Iron-Wrought Cuffs", "Wrist, Plate"), Seen(287024, "Mark of Captivity", "Neck"),
			Seen(287025, "Enchantresses' Spire", "Two-Hand, Staff", "Strashaz Enchantress"),
			Seen(287026, "Escape Plan", "Ranged, Gun") } },
	}),
	prepare = {
		{
			title = "The Overseer's Keyring",
			kind = "key",
			-- (2026-11-17: no guide or quest says what it opens, and it drops on only some of his kills: the first guide's
			-- "the locked door to the lower floor" stays a report, a question for the owner)
			text = "Overseer Wrex can drop the {item:263992:Overseer's Keyring}. An early report said it opens the locked "
				.. "door to the lower floor, where Katerina the Cleaner waits; that is not confirmed yet.",
		},
		{
			faction = "Horde",
			title = "Orgrimmar's errand",
			-- The Horde's way in, its three quests the steps in Data/Authored/QuestAudit.lua (the owner's answer of 2026-11-12:
			-- it starts in Orgrimmar; its giver, Eitrigg, from the quest page of 2026-11-13, as players saw in game). A chain
			-- to do, as the Alliance's below; its quests have their marks on the world map, the first at Eitrigg in Orgrimmar
			-- (UI/QuestMap.lua).
			text = "Eitrigg, in Grommash Hold in Orgrimmar, gives The Missing Kor'kron, which sends you to Nazeer "
				.. "Bloodpike in Brackenwall Village. He gives The Elite of the Elite, an elite quest: bring friends to find "
				.. "the missing Kor'kron on Alcaz Island. There, the wounded Sergeant Ulka gives Right Place, Wrong Time.",
			quests = { 95283, 95284, 95285 },
			haveWhen = "done",
			chain = true,
			mapMarks = true,
		},
		{
			faction = "Horde",
			title = "Sergeant Ulka",
			-- (since 2026-11-09 the Kor'kron's quests are rows of the Quests tab: Data/Authored/QuestAudit.lua; "she" since
			-- 2026-11-12, as Right Place, Wrong Time's text has her)
			text = "Sergeant Ulka waits outside the prison on Alcaz Island. She sends you in after Commander Folkar and "
				.. "asks for A Little Payback; inside, Folkar sends you looking for King Varian Wrynn.",
		},
		{
			faction = "Alliance",
			title = "Mathias Shaw's errand",
			-- A player's comment on the dungeon's quests' pages (2026-11-09); since 2026-11-12 its three quests,
			-- the steps in Data/Authored/QuestAudit.lua (the owner's report: Shaw's breadcrumb comes first). A chain to
			-- do, not a key: done once the last is handed in. Its quests have their marks on the world map, the first
			-- at Shaw in Stormwind (UI/QuestMap.lua).
			text = "Master Mathias Shaw, at SI:7 in Stormwind's Old Town, gives Our Man in Theramore. At the inn in "
				.. "Theramore, the dwarf Sully McCleary sends you to meet him behind the graveyard, then up Jaina "
				.. "Proudmoore's tower in disguise to listen in. After that, he gives The Secret Prison and A Bit of Wet Work.",
			quests = { 95194, 95196, 95198 },
			haveWhen = "done",
			chain = true,
			mapMarks = true,
		},
		--[[
			The Alcaz Operative Insignia, a toy, for each side (the owner's steps, 2026-11-13; its quests and what was
			checked: Data/Authored/QuestAudit.lua): Mason Connery's two quests, then the side's State Secrets, whose
			Fractured Insignia six of make the toy. A chain to do, done once State Secrets is handed in; its quests'
			marks on the world map are the rows' own (the box at Moonbrook's inn, Renzik, Nazgrel). The toy's
			name is the game's, item 279471 in its Toy table (the owner's steps call it the Alcaz Operative Disguise).
		]]
		{
			faction = "Alliance",
			title = "Toy: Alcaz Operative Insignia",
			text = "If you want this toy, skip The Questioner on your way in. At the end, the prisoner Mason Connery sends "
				.. "you back for The Questioner's key, then to the inn at Moonbrook in Westfall for a Document Box: don't "
				.. "sell it. Bring it to Renzik \"The Shiv\" at SI:7 in Stormwind for State Secrets. Six "
				.. "{item:279450:Fractured Insignia:2} make the {item:279471:Alcaz Operative Insignia:3}, and they can be traded.",
			quests = { 96335, 96337, 96377 },
			haveWhen = "done",
			chain = true,
			mapMarks = true,
		},
		{
			faction = "Horde",
			title = "Toy: Alcaz Operative Insignia",
			text = "If you want this toy, skip The Questioner on your way in. At the end, the prisoner Mason Connery sends "
				.. "you back for The Questioner's key, then to the inn at Moonbrook in Westfall for a Document Box: don't "
				.. "sell it. Bring it to Nazgrel, in Grommash Hold in Orgrimmar, for State Secrets. Six "
				.. "{item:279450:Fractured Insignia:2} make the {item:279471:Alcaz Operative Insignia:3}, and they can be traded.",
			quests = { 96335, 96337, 96376 },
			haveWhen = "done",
			chain = true,
			mapMarks = true,
		},
	},
	--[[
		Santiago Reyes's maps (Atlas de Azeroth: Forever), given by the owner on 2026-11-08 and 11-09, converted as his
		others: the prison's two levels, each named as his map labels it.

		Inside, the map opens on the floor of the area the player is in (UI/DungeonMap.lua, follow.Floor), as the Drowned
		City's does, by the game's own names for the prison's rooms. From Forever's own files (read 2026-11-17, client
		1.60.1.70959): the dungeon is one building (WMO 7490002), and each of its 30 rooms has a name in WMOAreaTable
		(rows 137675-137705, none pointing at an area of its own): the nine rooms of the lower level, under the main
		corridor and out to the big room at the far end, are "Maximum Security"; the other 21 are "Alcaz Prison", the
		dungeon's own name (AreaTable 16620, its only area). So the first floor goes by "Alcaz Prison" and the second by
		"Maximum Security"; where the client names no room (GetSubZoneText gives "", maybe in the rooms named as the
		dungeon) the minimap's name, the dungeon's, keeps the first, and unnamedFloor says so should that be blank too.
		Two rooms do not fit (a best guess what the game shows there, to read in game with /aegis where): the corridor
		at the foot of the stairs and the room west of it are drawn on his lower picture, but the game names them "Alcaz
		Prison", so the map shows the upper picture there until the player walks on into "Maximum Security". The
		way between the floors (transitions) is there to turn it by hand. The names are drafted in the other languages
		(Locales: AREA_NAMES), to be checked.

		The way in and the way between the floors (2026-11-17), from the same building's doorways (its portals), each on
		his pictures by the same fit as the boss spots (the note above): the way in, the swirl he draws at the top
		of the main corridor, where the cellar's stairs from the keep come down; the only way between the floors, the
		long stairs he draws in the cross west of the main corridor, below The Questioner's octagon: on the first floor
		at its foot (the owner's mark in game, 2026-11-19), on the second at its foot, where his lower picture starts
		the corridor. Each with the delve's icon, as a building's ways between floors have (the Drowned City's; the
		prison is one building): his pictures draw the stairs, but a plain spot shows only when pointed at, and the
		owner wants the way down marked (2026-11-19: "i thought we were marking the stairs").
	]]
	map = {
		floors = {
			{ art = MAPS .. "AlcazPrison", artBottom = PICTURE, areas = { ["Alcaz Prison"] = true } },
			{ art = MAPS .. "AlcazPrisonMaximumSecurity", artBottom = PICTURE, areas = { ["Maximum Security"] = true } },
		},
		-- where the client names no area: the first floor (above)
		unnamedFloor = 1,
		-- the swirl at the top of the main corridor
		entrance = { x = 0.355, y = 0.161, floor = 1 },
		transitions = {
			-- the stairs in the west cross, down and back up, each with the delve's icon (a building's way: the map's note
			-- above); the way down at the stairs' foot, where the owner marked it in game (2026-11-19: "this is where you
			-- go down to the second floor")
			{ floor = 1, to = 2, x = 0.250, y = 0.538, icon = "building" },
			{ floor = 2, to = 1, x = 0.247, y = 0.516, icon = "building" },
		},
	},
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
		game's encounter list, then the rares; only the drops players saw, each checked in the game's item
		data. The door is the tunnel's mouth; the portal is at its far end. Creature ids as
		the guide's pages link them.

		More since, from players' guides the owner OK'd for facts on 2026-11-18, in our own words (each note says what it
		adds): Clawbert (247996), a furbolg shaman, fights beside the Blackmaw Behemoth and heals it, and as he dies the
		Behemoth heals and enrages; each of the four Legashi Ritualists (258668) still alive makes Bonesnout take a
		quarter less damage; Elder Bramblesnap (248765), a friendly furbolg, starts the Unbound Spirit's fight, in which
		the Spirit and its three Profane Totems start out immune and he makes the totems breakable one at a time; Varrox
		Bleakhoof is reached by dropping through a hole behind the Behemoth into the pool in front of him, and an updraft
		there carries players back up. Two more rares, Gortek the Apprentice (269111) and the Tunnelweb Matriarch (250034):
		each a rare elite Forever's NPC data finds in this dungeon, listed on the owner's word as best guesses (2026-11-18:
		"The 3 rares are best guesses"), with no spot and no level, each with the two blues that data lists for it; and
		the Moontouched Wanderer's second blue there, the Lunarlight Robe (280079). Those drops are Seen since 2026-11-19
		(the same data shows each dropping: the Robe on 28 of 79 kills, Gortek's on 12 and 6 of 18, the Matriarch's on 22
		and 20 of 43), each checked in the game's item data (blue, its slot). A third, Mopes (247412), is out with his
		two blues (the owner, 2026-11-18: "i dont see mention of Mopes or Gortek so we can remove them and add these 3",
		the three being the Moontouched Wanderer, Gortek, whom they called "Gore the Apprentice", with the same drops, and
		the Tunnelweb Matriarch, each in their screenshots of a video).

		Drops, read again in Forever's NPC and item data (2026-11-19): each boss drops three blues of its own (Bind on
		Pickup, item level 59 to 62), about one a kill, all seen there on 165 to 292 kills: Withermaw's, Impaan's,
		Bonesnout's and Varrox Bleakhoof's other two or three, and the first ones of Elder Shaman Bloodmane, the Blackmaw
		Behemoth and the Unbound Spirit. Varrox's Mark of Xavius (once in 279 kills) is for In Demand - Titan Relics
		(96088). Each id, name, slot and item level checked in the client's item data (its hotfix cache of 2026-11-18).
		The trash: the client's band 287028-287036, nine Bind on Equip blues of item level 57 to 60, each seen dropping
		off the hold's creatures, all nine listed; Satyr's Touch most of all, off the Legashi Slayers, Swarming Imps,
		Legashi Subjugators and Summoners, and now and then a Ritualist. Its recipes: two of its own, each new to Forever
		and seen dropping off one creature alone, in the Recipes entry: the Pattern: Timbermaw Tunic off the Blackmaw
		Druids (8 of 71 kills; it makes the Timbermaw Tunic, 252484, an epic leather chest) and the Plans: Breastplate of
		Salvation off the Legashi Summoners (8 of 152). Left out: the classic world-drop recipes and class books the
		trash drops too, as creatures do all over the world; and the Schematic: EZ and SAF Field Transporter: Mt. Hyjal
		(264231, a Forever recipe, off the Blackmaw Headhunters 3 of 502 kills), whose other sources could not be read
		(a question for the owner; left out since: the owner, 2026-11-19, only loot of the dungeon's own). The quest
		items the hold's creatures drop (the Feathered Charm Necklace, which starts A Lost Memento, the Fel-Tainted
		Flesh, the Blackmaw Pouch) stay off the trash, as quest items off trash do elsewhere.
		Only the dungeon's own (the owner's call of 2026-11-19), checked that day in each item's "dropped by" list, whose
		kill counts come twice for each creature: the kills in a dungeon, and all kills. Several of the hold's creatures
		(the Thralls, Swarming Imps, Berserkers, Slayers, Headhunters and Champions) stand in Azshara too, in a strip from
		the portal north-west, and the gap between the two counts is their kills out there. Two trash blues drop there
		too: the Grove Subjugator's Blade (287034), 7 of its 43 drops outside (6 off Swarming Imps, 18 in all kills
		against 12 in the dungeon's, and the one off a Legashi Satyr, 272307, which stands in Azshara alone, among the
		Thralls' marks in that strip: taken as one of the hold's satyrs, a best guess), and Satyr's Touch (287036), 14 of
		its 93 (12 off Swarming Imps, 2 off Legashi Slayers). Taken off the trash in a review that day, both are back on
		the owner's call (2026-11-19: "yes put those items back specifically since they are still related to that
		dungeon"): a dungeon's Trash and Recipes pages list its own loot, dropped only off its own creatures, counting its
		own kinds of creature where they also stand just outside its way in; never world drops or another zone's loot.
		Both drop off the hold's own creatures alone, some of them standing by the portal outside. The other seven trash
		blues, both recipes and Sabella No-Eyes's two have no drop outside: every one of their drops is in the dungeon's
		count (seen in the dungeon alone so far, which is all the data can say).

		Sabella No-Eyes (269151), a rare elite beast with two blues of the hold's rare band (the Truesight Rifle 280083,
		11 of 21 kills, and the Furbolg Rib Protector 280084, 10 of 21; both checked in the client's item data), is most
		likely a fourth rare of the hold, but the NPC data gives her no place (all 21 of her kills there are counted in a
		dungeon, so she is a dungeon's rare; which dungeon, by her drops' ids: a best guess). Listed on the owner's word (2026-11-19:
		"Sure"), as the other three were: after them, a rare (no fog, not in the run's count), with no pin, as no spot of
		hers is known (a player's note of 2026-11-19 has her at "the entrance of the cave inside the dungeon", which cave
		not said). Each of her two blues drops off her alone in that data. Her model, 6829, the NPC data's, checked in the
		client's own files (1.60.1.70959): its CreatureDisplayInfo row is in the table's open part, and its model file
		(Furbolg, at 1.5 times its size), its 2 .skin and 11 animation files and its two skins (124125, 124130: white fur
		and a claw necklace) all read whole: a white furbolg, though the NPC data calls her a beast. Her level: neither the
		NPC data nor the client gives it.

		Models (displayID), for the boss list's pictures, the faces on the map and in the run block, and the Model tab:
		each creature's model as Forever's NPC data gives it (read 2026-11-18). The client holds none of the hold's
		creatures (no row in its creature cache or its Creature table), so nothing in it ties a creature to its model;
		each id was checked in the client's own files instead (build 1.60.1.70959): its CreatureDisplayInfo row is in the
		table's open part (no key needed, no hotfix row), and its model file, the .skin and animation files the model
		names and its skins all read whole. What the files draw (a picture of each model at rest, made from them):
		Withermaw (140708) the bear model, gray-blue, with festering sores along its back and bloody claw wounds: a
		rotting bear. Impaan the Imprisoner (130432) a satyr (the Satyr2 model) with sea-green skin, golden fur and long
		ridged horns. Elder Shaman Bloodmane (130440) a black-furred furbolg with feathers on its head, a claw necklace
		and a green loincloth (Clawbert's model, 131321, is the same furbolg in the same skins). Bonesnout the Unbroken
		(130427) a giant boar, its bristles dark red-brown, gray-green spikes along its back, big tusks and a glowing
		green eye. Varrox Bleakhoof (130447) a satyr in armor (Satyr3): pale lilac fur, gray-blue skin, glowing pink
		eyes and dark horns, green-and-gold shoulders and bracers set with pink gems, a skull at the belt. Those are the
		model's own skins: the row also names a purple-and-green set, which the model has no slot for, so most likely
		it goes unused (a best guess). The Blackmaw Behemoth (130436) a huge dire furbolg (DireFurbolg), black fur, red
		eyes and a skull on a cord at its neck: a furbolg's model, though the NPC data calls the creature a beast. The
		Unbound Spirit (131644, drawn at 1.5 times its size; its model file names no model) an elemental of dark stone
		and glowing red crystal: a horned head with red eyes, a stone ribcage and two great crystal fists, no legs. The
		Moontouched Wanderer (12235, the ForceofNature model) a white-and-gray moonkin with antlers and black claws, as
		the owner's screenshot shows it. Gortek the Apprentice (145808) a wolvar (the Wolvar model): brown fur, a dark
		masked face, big stitched leather shoulder guards, green shorts and a bushy tail. The owner's screenshot showed
		what the owner called a brown furbolg in leather shoulder guards. The files draw a wolvar, not a furbolg: only
		the brown fur and the shoulder guards match (the furbolg model has none), so it is most likely the same
		creature, still to be checked in game (the owner may want to look at the screenshot again). The Tunnelweb
		Matriarch (2424) an orange tarantula, its legs striped black and orange, as the owner's screenshot shows it.
		That the NPC data has each right is still to be seen in game.
	]]
	location = "A furbolg tunnel in northern Azshara, its portal at the far end by the Winterspring border",
	zoneEntrance = { mapID = 1447, x = 0.384, y = 0.326 },
	bosses = Bosses({
		{ name = "Withermaw", npcID = 247195, displayID = 140708, level = 58, notes = {
			"The clan's great bear. If it is the rotting bear of the cavern route, it leaves pools of lava: fight out of them.",
			"Drops the Claws of the Great Bear for Claws That Rend, Tusks that Gore.",
		}, loot = { Seen(280062, "Cloak of the Fleshborer", "Back"), Seen(280063, "Bloodfur Bulwark", "Off Hand, Shield"),
				Seen(280064, "Withering Grips", "Hands, Leather"), QuestItem(249697, "Claws of the Great Bear") },
			-- the Festering Grotto: the owner's spot (2026-11-18), the east chamber's north end, just north of the dark
			-- rock island with the crescent, where the north wall dips in (their mark read at 0.665, 0.273: on that spot
			-- here; the map's note below)
			mapPin = { x = 0.665, y = 0.273, floor = 2 } },
		{ name = "Impaan the Imprisoner", npcID = 247206, displayID = 130432, level = 57, notes = {
			"A demon the corrupted clan let into its home. Its abilities are not recorded yet.",
		}, loot = { Seen(280056, "Flameslash Crescent", "Two-Hand, Axe"), Seen(280057, "Robes of Dark Summons", "Chest, Cloth"),
				Seen(280058, "Impish Chain Hood", "Head, Mail") },
			-- Blackmaw Grove, on the whole hold: the owner's spot (2026-11-18), inside the curved thorny ridge west of the
			-- grove's middle peak, just below the right half of the grove's label. Their mark was read at 0.311, 0.685,
			-- which on this picture is under the label's left half (it runs about 0.21 to 0.44): the pin stands on the spot
			-- they named, 0.022 east of it, past the label's middle and short of the root's arc, as Bonesnout's does.
			-- Players' guides put him up a winding path in the grove, outside the hold's gates but inside the dungeon.
			mapPin = { x = 0.333, y = 0.685, floor = 1 } },
		{ name = "Elder Shaman Bloodmane", npcID = 247209, displayID = 130440, notes = {
			"The clan's elder shaman, a caster: bring interrupts.",
			"Carries the Blackmaw Ritual Totem for Blackmaw Magic, and the Reliquary of Tyr for paladins.",
		}, loot = { Seen(280068, "Bloody Claws of Attack", "One-Hand, Fist Weapon"), Seen(280069, "Shamanic Wristguards", "Wrist, Mail"),
				Seen(280070, "Veilpiercer Girdle", "Waist, Leather"), QuestItem(276893, "Blackmaw Ritual Totem"),
				QuestItem(286415, "Reliquary of Tyr", 4) },
			-- the Depths of the Elders (Level 2), in the room of the green glow: the guess of 2026-11-13, kept by the owner
			-- (2026-11-18: their mark on it; the map's note below)
			mapPin = { x = 0.450, y = 0.370, floor = 4 } },
		{ name = "Bonesnout the Unbroken", npcID = 247198, displayID = 130427, level = 58, notes = {
			-- (the Legashi Ritualists: players' guides, 2026-11-18; above)
			"An undead boar guarded by four Legashi Ritualists. Each one still alive makes Bonesnout take a quarter less damage, so while all four stand it can't be hurt: kill them first.",
			"Drops the Tusks of the Unbroken for Claws That Rend, Tusks that Gore.",
		}, loot = { Seen(280059, "Tuskblade Halberd", "Two-Hand, Polearm"), Seen(280060, "Lucky Shovelnose Tuft", "Trinket"),
				Seen(280061, "Spike Crested Bracers", "Wrist, Plate"), QuestItem(249696, "Tusks of the Unbroken") },
			-- Bonesnout's Thicket: the owner's spot (2026-11-18), in the thicket below the bridge's west half, just west of
			-- the line of dark dots that runs north to south through it, a little lower than the thicket's label. Their mark
			-- was read at 0.657, 0.682, which on this picture is just east of the dots, under the bridge's middle: the pin
			-- stands on the spot they named, 0.022 west of it (it patrols: where it stands is a best guess)
			mapPin = { x = 0.635, y = 0.682, floor = 1 } },
		{ name = "Varrox Bleakhoof", npcID = 247234, displayID = 130447, level = 60, notes = {
			"A demon, the highest-level boss seen so far; his kill is the one the game counts for the dungeon.",
			-- (the way down and back up: players' guides, 2026-11-18; the owner's hole, the map's note below)
			"To reach him, drop through the hole behind the Blackmaw Behemoth: you land in the pool in front of him. An updraft there takes you back up.",
			-- (the Mark's quest: Forever's item data, 2026-11-19; above)
			"Drops the Head of Varrox Bleakhoof, for Blackmaw Reclamation, and, rarely, the Mark of Xavius, for In Demand - Titan Relics.",
		}, loot = { Seen(280074, "Scalding Flamehoof", "Trinket"), Seen(280075, "Bleak Eye Shoulderplates", "Shoulder, Plate"),
				Seen(280076, "Horns of Varrox", "Head, Leather"), QuestItem(249692, "Head of Varrox Bleakhoof"),
				QuestItem(272027, "Mark of Xavius", 3) },
			-- the Depths of Forbidden Magic (Level 4), on the purple rune circle: the guess of 2026-11-13, kept by the owner
			-- (2026-11-18). The furbolg door behind him is the dungeon's way out (the map's note below). He is the run's last
			-- boss (Data/Authored/RunTracker.lua: the owner, 2026-11-18).
			mapPin = { x = 0.636, y = 0.580, floor = 6 } },
		-- (Clawbert: players' guides, 2026-11-18; above)
		{ name = "Blackmaw Behemoth", npcID = 247207, displayID = 130436, notes = {
			"A huge dire furbolg. Clawbert, a furbolg shaman, fights beside it and keeps healing it: kill him first.",
			"When Clawbert dies, the Behemoth heals and enrages.",
		}, loot = { Seen(280065, "Behemoth Bones", "Trinket"), Seen(280066, "Trousers of the Ebon Giant", "Legs, Cloth"),
				Seen(280067, "Blackmaw Chain Belt", "Waist, Mail") },
			-- the Depths of the Burrow (Level 3): the owner's spot (2026-11-18), in the west part of the red den, just under
			-- the spikes on its north edge (their mark read at 0.559, 0.349: on that spot here)
			mapPin = { x = 0.559, y = 0.349, floor = 5 } },
		-- (Elder Bramblesnap and the Profane Totems: players' guides, 2026-11-18; above.) Last on the game's list, but not
		-- the run's last boss: Varrox Bleakhoof is (Data/Authored/RunTracker.lua).
		{ name = "Unbound Spirit", npcID = 247231, displayID = 131644, notes = {
			"An elemental, fought before Varrox Bleakhoof. Elder Bramblesnap, a friendly furbolg, starts it.",
			"The Spirit and its three Profane Totems start out immune. Bramblesnap makes the totems breakable one at a time: break each as he does.",
		}, loot = { Seen(280071, "Flamebreak Talisman", "Trinket"), Seen(280072, "Cowl of Dark Ambition", "Head, Cloth"),
				Seen(280073, "Burnished Pridescales", "Chest, Plate") },
			-- the Depths of the Fallen Grove (Level 1): the owner's spot (2026-11-18), on the great hollow stump at the right
			-- of the heap of logs, on its round cut top (their mark read at 0.594, 0.352: on that spot here). They also wrote
			-- "1. Impaan, Unbound Spirit" by their first mark on the whole hold: taken as Impaan's spot alone, the Spirit's
			-- the one they circled on this level (asked, not yet answered)
			mapPin = { x = 0.594, y = 0.352, floor = 3 } },
		{ name = "Moontouched Wanderer", npcID = 269104, displayID = 12235, level = 55, rare = true,
			notes = { "A rare that does not always spawn." },
			loot = { Seen(280080, "Claymore of Two Moons", "Two-Hand, Sword"), Seen(280079, "Lunarlight Robe", "Chest, Leather") },
			-- the far south-east corner of Bonesnout's Thicket, by its small huts: players' guides name the corner; the spot
			-- in it is a best guess, which the owner let stand (2026-11-18)
			mapPin = { x = 0.775, y = 0.860, floor = 1 } },
		-- Two more rares (the owner, 2026-11-18: best guesses; above): no spot, no level
		{ name = "Gortek the Apprentice", npcID = 269111, displayID = 145808, rare = true,
			notes = { "A rare, listed here as a best guess. It may spawn near the ramp down to the Blackmaw Behemoth." },
			loot = { Seen(280077, "Fist of Revelation", "One-Hand, Fist Weapon"),
				Seen(280078, "Apprentice's Protective Treads", "Feet, Leather") } },
		{ name = "Tunnelweb Matriarch", npcID = 250034, displayID = 2424, rare = true,
			notes = { "A rare spider, listed here as a best guess. Where it spawns is not known yet." },
			loot = { Seen(280086, "Octofinger Gauntlets", "Hands, Plate"), Seen(280085, "Tunnelweb Pincer", "One-Hand, Dagger") } },
		-- Sabella No-Eyes, a rare (the owner, 2026-11-19; above): no pin, as where she spawns is not known; no level known
		{ name = "Sabella No-Eyes", npcID = 269151, displayID = 6829, rare = true,
			notes = { "A rare, listed here as a best guess. Where it spawns is not known yet." },
			loot = { Seen(280083, "Truesight Rifle", "Ranged, Gun"), Seen(280084, "Furbolg Rib Protector", "Chest, Mail") } },
		-- (the trash's nine and the hold's two recipes: above. The Grove Subjugator's Blade, 7 of its 43 drops outside,
		-- and Satyr's Touch, 14 of its 93, drop off the hold's own creatures alone, some of them standing by the portal
		-- outside, in Azshara: the dungeon's own, the owner's call of 2026-11-19. Satyr's Touch drops off several of the
		-- satyrs, not one: until 2026-11-19 it named the Legashi Ritualist alone)
		{ name = "Trash Drops", trash = true, loot = {
			Seen(287028, "Tormented Cuffs", "Wrist, Cloth"), Seen(287029, "Nature Guardian's Legguards", "Legs, Leather"),
			Seen(287030, "Blackmaw Bindings", "Wrist, Mail"), Seen(287031, "Spearfisher's Waders", "Legs, Mail"),
			Seen(287032, "Den Champion's Binding", "Waist, Plate"), Seen(287033, "Furbolg Berserker's Boots", "Feet, Plate"),
			Seen(287034, "Grove Subjugator's Blade", "One-Hand, Dagger"), Seen(287035, "Demon Worshipper's Necklace", "Neck"),
			Seen(287036, "Satyr's Touch", "Ranged, Wand") } },
		{ name = "Recipes", recipes = true, loot = {
			Recipe(252893, "Pattern: Timbermaw Tunic", "Leatherworking", 4, "Blackmaw Druid"),
			Recipe(251453, "Plans: Breastplate of Salvation", "Blacksmithing", 4, "Legashi Summoner") } },
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
	--[[
		Santiago Reyes's six maps of the hold (Atlas de Azeroth: Forever), given by the owner on 2026-11-13 and converted
		from his full-size originals as his others: the whole hold outdoors (his "Blackmaw Hold (General)"), its cave, the
		Festering Grotto, and the four levels of the depths below it, Level 1 to 4. Each floor is named as his map labels
		it, the first by the dungeon's name. His map of the whole hold spells the grove "Blackmaw Groove": the journal
		says Blackmaw Grove, as his Spanish name for that map (Arboleda Faucenegra) does.

		Inside, the map opens on the floor of the area the player is in (areas: UI/DungeonMap.lua, follow.Floor), by the
		names on his maps. A best guess: the client's tables keep the hold's own area names in encrypted rows. It also
		needs the dungeon's instance id, which our data does not have yet: the journal takes the one the client gives
		inside a five-player instance it calls Blackmaw Hold (Core/Registry.lua, LearnInstanceID). That the client calls
		it so is a best guess too, until a run is recorded; if it does not, the map is not the hold's inside it.

		The ways between floors, read off his pictures (best guesses, not yet walked): into the grotto at the two bone
		piles he draws at its mouths, both on the hold's map and on the grotto's; down into the depths at the furbolg
		gate by Bonesnout's Thicket, with the same gate at the bottom of Level 1. Where Levels 1, 2 and 3 meet is not
		drawn: the owner's ways, below. The way in (entrance): the portal's swirl he draws by the hold's south-west gate.

		Between Levels 1, 2 and 3: the owner's ways (2026-11-18, "i believe"; not yet checked in game), circled on a
		picture of our maps and each laid on the corridor's end it circles (each within 0.021 of the circle's middle,
		inside its ring). Level 1 down to Level 2 at three ends: the north branch's top end and the end below it, both
		west of the log hut, and the west branch's end, on its log; Level 2 back up at three: the far east end of the
		north corridor, the end of the short spur by the north pool, and the log at the east corridor's end. Level 2
		down to Level 3 at the end of the corridor along the south room's bottom. Each of these with the cave's icon:
		his art draws no way at a corridor's end, so a plain spot, which shows only when pointed at, would hide them.
		Level 3 back up to Level 2 at the bottom end of its S-shaped corridor, in the map's lower middle: the owner's
		belief (2026-11-19, "at the bottom of the map is the entrance I believe"; not yet checked in game), which fits
		Level 2's way down at the bottom of its map. Nothing marks it there, so a plain spot, as the updraft's. The
		corridor's top end, under the map's title, where the first guess put it, stays clear at the start too (the fog's
		second way in), in case the way is there.

		From Level 3 down to Level 4: the owner's spot (2026-11-18, "a hole you drop down to get to the last boss"), the
		round dark hole at the east end of Level 3's red den (their mark read at 0.652, 0.326: on the hole here), with the
		cave's icon as the other ways down. Players' guides say the drop lands in a pool in front of Varrox Bleakhoof and
		that an updraft in it carries players back up: the way back is in Level 4's pool, at its south-east end, the side
		nearest Varrox (where in the pool is a best guess). His art draws no mark there, so the spot shows nothing until
		it is pointed at, as the Prismatic Talus's way back does: no icon on a spot nobody has placed. The furbolg door
		of roots and stakes on blue ground behind Varrox (about 0.745, 0.670) is the dungeon's way out, an exit portal
		(the owner, 2026-11-18): not a way in. The map has no mark for a way out, so it is noted here only.

		Boss spots: the owner's (2026-11-18), marked on screenshots of his maps, read off them by eye and each laid on the
		landmark they marked on our copy of his pictures (each boss's comment says where; for Impaan and Bonesnout, where
		the mark as read and the landmark disagree, the landmark won). Their copy of his whole hold looks newer than ours:
		its grove's label is spelled right, and a label, Zedrik's Rest, by the east furbolg gate, is new (an area of the
		whole hold's floor since, below). Withermaw at the Festering Grotto's north notch; Impaan the Imprisoner in
		Blackmaw Grove; Bonesnout in his thicket below the bridge; the Unbound Spirit on Level 1's hollow stump; the
		Blackmaw Behemoth in Level 3's red den. Elder Shaman Bloodmane (Level 2's green room) and Varrox Bleakhoof (Level
		4's rune circle) are kept where the guesses of 2026-11-13 put them. The Moontouched Wanderer's, in the thicket's
		south-east corner, is a best guess the owner let stand. Gortek the Apprentice and the Tunnelweb Matriarch have no
		spot: nothing places them. All of them are to be checked in game.

		The hold's map is the dungeon's whole map (whole = true; the owner's call of 2026-11-19): the hold has two ways
		through, past Bonesnout or across the lake to Withermaw, and a group may take only one, so neither beast holds
		back the fog (UI/DungeonFog.lua, the fog data's counts), and the hold's map clears with the whole fog, at Varrox
		Bleakhoof's kill, whichever way the group came, as Krol'dok Stronghold's last kill clears its map. It is named
		Blackmaw Hold either way. On a whole map the quest marks of the levels below show too, each at its place there
		(spot.whole: UI/QuestMap.lua). The hold has no quest marks inside yet; one added on a lower level shows on its
		own level as on any map, and needs its place on the hold's map too (spot.whole), as the smoke test asks of
		every dungeon with a whole map.
	]]
	map = {
		floors = {
			{
				-- the dungeon's whole map (the note above)
				art = MAPS .. "BlackmawHold", artBottom = PICTURE, whole = true,
				-- Zedrik's Rest: a best guess, from the label by the east furbolg gate on a newer version of his map (the
				-- owner's screenshot, 2026-11-18); our copy has no such label, and its art is left as it is
				areas = { ["Blackmaw Grove"] = true, ["Blackmaw Stillwater"] = true, ["Bonesnout's Thicket"] = true,
					["Zedrik's Rest"] = true },
			},
			{ art = MAPS .. "BlackmawHoldFesteringGrotto", artBottom = PICTURE, areas = { ["Festering Grotto"] = true } },
			{ art = MAPS .. "BlackmawHoldFallenGrove", artBottom = PICTURE, areas = { ["Depths of the Fallen Grove"] = true } },
			{ art = MAPS .. "BlackmawHoldElders", artBottom = PICTURE, areas = { ["Depths of the Elders"] = true } },
			{ art = MAPS .. "BlackmawHoldBurrow", artBottom = PICTURE, areas = { ["Depths of the Burrow"] = true } },
			{ art = MAPS .. "BlackmawHoldForbiddenMagic", artBottom = PICTURE, areas = { ["Depths of Forbidden Magic"] = true } },
		},
		-- the portal's swirl, by the gate in the south-west of the hold
		entrance = { x = 0.178, y = 0.735, floor = 1 },
		transitions = {
			-- into the Festering Grotto at each of its two bone piles, and down into the depths at the furbolg gate
			{ floor = 1, to = 2, x = 0.507, y = 0.315, icon = "cave" },
			{ floor = 1, to = 2, x = 0.711, y = 0.317, icon = "cave" },
			{ floor = 1, to = 3, x = 0.795, y = 0.505, icon = "cave" },
			-- back out: the grotto's two bone piles, and Level 1's furbolg gate
			{ floor = 2, to = 1, x = 0.577, y = 0.785 },
			{ floor = 2, to = 1, x = 0.806, y = 0.670 },
			{ floor = 3, to = 1, x = 0.309, y = 0.935 },
			-- between Levels 1 and 2 at the corridors' ends the owner circled (2026-11-18, "i believe"; the map's note
			-- above), each with the cave's icon: down from Level 1 at the north branch's top end and the end below it,
			-- and at the west branch's log; back up from Level 2 at the north corridor's far east end, the spur's end by
			-- the north pool, and the log at the east corridor's end
			{ floor = 3, to = 4, x = 0.382, y = 0.200, icon = "cave" },
			{ floor = 3, to = 4, x = 0.320, y = 0.297, icon = "cave" },
			{ floor = 3, to = 4, x = 0.228, y = 0.525, icon = "cave" },
			{ floor = 4, to = 3, x = 0.848, y = 0.327, icon = "cave" },
			{ floor = 4, to = 3, x = 0.745, y = 0.393, icon = "cave" },
			{ floor = 4, to = 3, x = 0.670, y = 0.660, icon = "cave" },
			-- down from Level 3 to Level 4 through the hole at the red den's east end (the owner, 2026-11-18), and back up
			-- by the updraft in Level 4's pool (where in the pool: a best guess; the map's note above)
			{ floor = 5, to = 6, x = 0.652, y = 0.326, icon = "cave" },
			{ floor = 6, to = 5, x = 0.485, y = 0.445 },
			-- down from Level 2 to Level 3 at the end of the corridor along the south room's bottom (the owner's circle,
			-- 2026-11-18, "i believe"), with the cave's icon; back up at the bottom end of Level 3's S-shaped corridor,
			-- where the owner believes the way in is (2026-11-19, "I believe"), a plain spot (the map's note above)
			{ floor = 4, to = 5, x = 0.574, y = 0.899, icon = "cave" },
			{ floor = 5, to = 4, x = 0.352, y = 0.764 },
		},
	},
	floorNames = { "Blackmaw Hold", "Festering Grotto", "Depths of the Fallen Grove", "Depths of the Elders",
		"Depths of the Burrow", "Depths of Forbidden Magic" },
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
	description = "A titan site hidden in Un'Goro Crater, guarding secrets of the makers among the crater's dinosaurs.",
	--[[
		The way in (a players' guide to the dungeon, 2026-11-18, facts only): up the stairs from Marshal's Refuge to a
		titan temple on the crater's northern rim, where the portal is; a Meeting Stone stands at the stairs; no key or
		quest is needed. The door's spot is the guide's, Un'Goro 48.1, 6.1 (a player's note on the zone says the climb
		starts in the hills by the northern pylon, 56, 12): a best guess until someone stands there with /aegis where.
	]]
	location = "The northern rim of Un'Goro Crater, up the stairs from Marshal's Refuge",
	zoneEntrance = { mapID = 1449, x = 0.481, y = 0.061 },
	-- Spoken's story is this dungeon's lore, so the description gives way to it; these practical words stay in the
	-- overview's facts (UI/EncounterPage.lua's FillInstanceOverview; the owner's lore rule of 2026-11-13). Drafted in
	-- the other languages (Locales/*_content.lua), to be checked.
	overviewNote = "Four of the bosses are summoned with Power Crystals, 15 of one color at each one's console: see "
		.. "Before you go. Nanaya, the last boss, comes once those four are dead; the other five bosses are optional. "
		.. "To leave, jump off the edge of the terrace.",
	--[[
		The game's numbers, from Forever's own client files (1.60.1.70959, read 2026-11-18 with the keys the client
		itself holds; no run of the dungeon is recorded anywhere yet, so none is seen in a run):
		- the dungeon (instanceID): its Map row, 3001, "The Shaper's Terrace", a five-player dungeon. Until now the
		  journal knew the player was inside only by the client's name for it (Core/Registry.lua, LearnInstanceID).
		- each fight (encounterID): its DungeonEncounter row on map 3001, all eleven readable, named as the journal
		  names its bosses, in this order in the game's own list: Titanosaur 3498, Ravasaur Hunters 3499, Thunderhoof
		  3500, Venomridge 3501, Direhorn Matriarch 3507, Cinder 3503, King Op 3504, Snowtalon 3597, Bolt 3505, Vitrix
		  3600, Nanaya 3502. By its id a fight's end counts the kill in any language, and the Record tab files its drops
		  under the boss. Their corpses are watched too (watchCorpse, UI/DungeonMap.lua), as Alcaz Prison's are: should
		  the game start no fight of these ids, seeing the boss dead still counts him.

		"Ravasaur Hunters" is the game's own name for one fight; that it is the raptor pair Izha'Rel and Tor'Rel is a
		strong guess, not proven (no client row ties a creature to a fight): it is second in the game's list, and the
		dungeon's second block of boss items (280012-280014, between Titanosaur's and Venomridge's) is the pair's, the
		Talon of Tor'Rel among them. Its corpse watch needs both seen dead (members, as the Sunken Temple's balcony
		trolls: Data/Authored/RunTracker.lua).

		The order: the five that roam the terrace in the order a players' guide says groups usually take them; the four
		called up at the consoles, which that guide says can be done in any order, in the game's own order; Nanaya last
		(the run's final boss, Data/Authored/RunTracker.lua); King Op, a rare, after her, as the other Forever dungeons'
		rares are. The game's own list puts the pair second and Venomridge after Thunderhoof, and King Op among the four.
		The run block counts ten: King Op, a rare, leaves the count as rares do; the four summoned bosses stay in it, as
		Nanaya needs them (not out of the count, unlike Lyn the Ignored), and so do the five optional ones. The clock
		stops at Nanaya.

		Creature ids (npcID) and models (displayID): Forever's NPC data (2026-11-18). Each model checked in the client's
		files (build 1.60.1.70959): its CreatureDisplayInfo row is in the table's open part, and every model and skin
		file it names reads whole. What they draw: Titanosaur the devilsaur model; Thunderhoof a thunder lizard;
		Venomridge a diemetradon; the Direhorn Matriarch a direhorn's skin (by eye); Tor'Rel and Izha'Rel raptors with
		fire and frost skins; Cinder, Snowtalon and Bolt the raptor models the client names Fire, Frost and Lightning,
		and Vitrix a green-skinned raptor of their size (so a players' guide's "gorilla" for Bolt is not his: read again
		at the owner's ask, 2026-11-18, his display 143063 draws the model file 1385709, which names itself
		Raptor2_Lightning, with one skin, 1043773, a yellow raptor's; no hotfix row changes either, and of the
		dungeon's new display rows only King Op's draws the gorilla model); King Op a gorilla; Nanaya the old stone
		keeper statue, white with gold. Cinder's and Snowtalon's ids and models are also the client's creature cache's
		(2026-11-12, raptors with 12 and 13 times a normal creature's health).

		Levels (level): a players' guide's, from its players' runs (2026-11-18): 61 for the five that roam, 62 for Bolt,
		Vitrix and Nanaya; Cinder's, Snowtalon's and King Op's not recorded. Neither the NPC data nor the client has them.
		Checked again against the guide's pages the owner sent (2026-11-18): its levels are the same, and every item of
		its "best loot" lists is in the drops here under the boss it names. Those lists give only each boss's best:
		Cinder's shows only the Crescent, and Vitrix's the Sparklance Wand and the Heartflame Gauntlets, two of the six
		it drops from Cinder's, Snowtalon's and Bolt's pool.

		Abilities: each boss's spells as Forever's NPC data lists them (2026-11-18), what each does in its own spell text
		there; each id's name checked in the client's spell table (SpellName, 1.60.1.70959: all the same). No recorded
		fight, so no damage or timings. Tactics in the notes: a players' guide (2026-11-18) and players' notes on the
		bosses (2026-11-16), facts only, in our own words. Left out: spells with no text that nothing explains (Cinder's
		Roar 1310251, Nanaya's Poison 1291301, Thunderhoof's second Lightning Cloud 1301404). The notes and the
		abilities' words are drafted in English only, as the Drowned City's are.

		Drops (loot): each boss's list as Forever's NPC and item data has it, with the kills they were seen on
		(2026-11-18): Seen, as Alcaz Prison's (each seen dropping, on 69 to 166 kills; King Op's on only 5). The slot and
		type as the item data gives them; each id, name, slot, type and item level (63, all of them) checked in the
		client's hotfix cache. Vitrix has no items of its own: the six it was seen dropping, one a kill, are Cinder's,
		Snowtalon's and Bolt's (a best guess: it drops from their pool). Left out: the Mote of Unstable Magic (274964), a
		white reagent most bosses drop a few kills in a hundred, as white reagents stay off the journal's lists; and the
		Direhorn Matriarch's Heart (285951), a quest item in the client that the Direhorn Matriarch was seen to drop once
		in 155 kills (its item data, 2026-11-19), for no quest we can read.
		Read again 2026-11-19: the same lists, and Nanaya's Freya's Sigil (272028), a blue quest item her item data has
		her dropping once in 163 kills (her own list leaves out what drops that seldom), for In Demand - Titan Relics
		(96088), as Blackmaw Hold's Mark of Xavius is; listed, as that is.
		The trash (Forever's NPC and item data, 2026-11-19): the client's band 287037-287046, Bind on Equip blues of item
		level 59 to 61. Six are seen dropping off the terrace's creatures (ravasaurs, gorillas, a slime, a stegodon), each
		about once in a hundred kills: Seen. The Shaper's Robe, a players' guide's alone, Listed as before. The other three
		of the band (287039 Tattered Explorer's Cuffs, 287043 Predaceous Band, 287046 Pylon Poker) have no drop seen and
		nothing names them for the dungeon but their ids: they wait (a question for the owner). The trash's quest items
		(the Partially Digested Journal Pages, the Seeping Slime Essence) stay off it, as quest items off trash do
		elsewhere; so do the gorillas' classic world-drop blues and Gorilla Fangs. Its recipes: Nanaya's Blueprint: Arcane
		Forge, the one of its own, in the Recipes entry too. Left out: the classic world-drop patterns, plans and class
		books off the trash, and the Recipe: Prehistoric Pulled Raptor (250183), a Forever cooking recipe the ravasaurs
		drop (5 drops in about 300 kills) that most likely drops off raptors outside too (not checked): left out (the owner,
		2026-11-19: only loot of the dungeon's own).
		Only the dungeon's own (the owner's call of 2026-11-19), checked that day in each item's "dropped by" list: the six
		trash blues seen and the blueprint drop off the terrace's own creatures alone, each with no zone there but marks
		on the continent's map in one cluster with Nanaya's, and every kill of each counted in a dungeon (so none dropped
		outside; the terrace, by the cluster: a close best guess). The Shaper's Robe has no "dropped by" list at all, so it can't
		be checked: it stays, on the guide's word, a best guess. Nothing taken out.

		Boss spots (mapPin, on the terrace's and the cave's maps, below): the owner's (2026-11-18), from players' videos
		of the dungeon, each a ring the owner drew on a screenshot of Santiago's terrace map in another site's map
		viewer (the same picture, his 11/26 version). The screenshot was laid on his original by 24 places spread over
		the whole map (his labels, both portal swirls, both cave marks, the lake's island, the tar pool, his buildings),
		each found by matching the picture around it: one scale and an offset each way fit all 24 within 0.8
		screenshot pixels (0.36 on average, under one art pixel), the scale the same across and down to 0.06%. Each pin
		is its ring's middle, read to about half a screenshot pixel. Not yet checked in game. They replace the first
		best guesses (Forever's NPC data's spawn marks laid on the map by a fit to four bosses, 2026-11-18), which were
		8 to 68 art pixels from them. King Op stays inside the Prismatic Talus: the owner's ring on the terrace is on
		the cave mark, "likely" his cave; where in the cave he stands is still a guess. The owner's other ring, green,
		is the way in: the swirl at the Terrace Overlook (the map's entrance, below).
	]]
	instanceID = 3001,
	bosses = Bosses({
		-- (the owner's spot, 2026-11-18: in the ruins at the west end of the Verdant Plains, on the broken stone
		-- pillar above the Highlands Causeway's label)
		{ name = "Titanosaur", npcID = 253201, displayID = 142989, encounterID = 3498, watchCorpse = true, level = 61, notes = {
			"A huge devilsaur at the great gate on the west side; it comes out through the gate. It is usually the first big pull: clear the creatures around it first.",
			"Terrifying Roar sends everyone near it running in fear: a Tremor Totem, Fear Ward or Berserker Rage helps. Stay out from behind it, where its tail knocks players back.",
			-- (a players' guide; the NPC data's tallies fit it: 112 of its items in 69 kills)
			"Optional. It drops two of its items each kill.",
		}, abilities = {
			{ spellID = 1294312, name = "Mighty Blow", flags = { "Tank" },
				text = "A heavy blow on the tank that knocks them back." },
			{ spellID = 1294313, name = "Terrifying Roar", flags = { "Important" },
				text = "Everyone near it runs in fear for 5 seconds." },
		}, loot = { Seen(280009, "Titanosaur Scale Pendant", "Neck"), Seen(280010, "Gargantuan Wristguards", "Wrist, Plate"),
				Seen(280011, "Deeproar Cord", "Waist, Cloth") },
			mapPin = { x = 0.148, y = 0.408, floor = 1 } },
		-- (the owner's spot, 2026-11-18: the plain just south of the tar pits' rim, north-west of the Botanical
		-- Grounds)
		{ name = "Venomridge", npcID = 261813, displayID = 144511, encounterID = 3501, watchCorpse = true, level = 61, notes = {
			"A great diemetradon on the plain south of the tar pits, near the yellow crystals.",
			"Its Poison Bolt Volley poisons the whole group: cure it or drop a Poison Cleansing Totem, and keep apart. Players in melee range get trampled as well.",
			"Optional, but the Alliance's Panic at the Digsite needs it dead.",
		}, abilities = {
			{ spellID = 3604, name = "Tendon Rip", flags = { "Tank" },
				text = "Tears at the tank's legs: slower movement for 8 seconds." },
			{ spellID = 1310365, name = "Poison Bolt Volley", flags = { "Healer", "Poison" },
				text = "Nature damage to everyone near it, then more every 3 seconds for 15 seconds. Cure it, or use a Poison Cleansing Totem." },
		}, loot = { Seen(280015, "Venomvessel Ring", "Finger"), Seen(280016, "Spiderchitin Wrap", "Chest, Leather"),
				Seen(280017, "Octoclaw Chain Boots", "Feet, Mail") },
			mapPin = { x = 0.443, y = 0.662, floor = 1 } },
		-- (the owner's spot, 2026-11-18: on the grass by the lake's west shore, west of the island and its green
		-- crystals, above the Pillar of Assimilation's label)
		{ name = "Thunderhoof", npcID = 261812, displayID = 144514, encounterID = 3500, watchCorpse = true, level = 61, notes = {
			"A thunder lizard by the water west of the Pillar of Assimilation, across from the island's green crystals.",
			"Lightning Cloud takes 3 seconds to cast: agree who interrupts it, and move out of any cloud that lands. Chain Lightning is instant, so spread out.",
			"Optional.",
		}, abilities = {
			-- (its spell page, 2026-11-18: a 3-second cast, 40 seconds between; Thunderhoof's only lightning spell with a
			-- cast, so most likely the one a players' guide says can be interrupted)
			{ spellID = 6535, name = "Lightning Cloud", flags = { "Interruptible", "Important" },
				text = "A 3-second cast: a storm cloud hangs over an area for 15 seconds, striking everyone under it with Nature damage. Interrupt it, or move out." },
			{ spellID = 8078, name = "Thunderclap", flags = { "Healer" },
				text = "Nature damage to everyone near it, then slower attacks and movement for 10 seconds." },
			{ spellID = 12553, name = "Shock", flags = { "Healer" },
				text = "An instant bolt of lightning at one player." },
			-- (its spell page, 2026-11-18: instant, 6 seconds between, so it can't be interrupted)
			{ spellID = 1310513, name = "Chain Lightning", flags = { "Healer" },
				text = "Lightning that jumps between up to 4 players. Don't stand close together." },
		}, loot = { Seen(280018, "Hammer of Thundering Hooves", "Two-Hand, Mace"), Seen(280019, "Dinofrill Casque", "Head, Mail"),
				Seen(280020, "Deep Jungle Rifle", "Ranged, Gun") },
			mapPin = { x = 0.619, y = 0.637, floor = 1 } },
		-- (the owner's spot, 2026-11-18: the open ground east of the lake, toward Isiz's Pillar)
		{ name = "Direhorn Matriarch", npcID = 262127, displayID = 144515, encounterID = 3507, watchCorpse = true, level = 61, notes = {
			"A great direhorn at the east end of the terrace, past the lake.",
			"Keep everyone at her sides: Tail Lash hits the players behind her, and she charges at players who stand far off. Puncture stacks on the tank and bleeds, so the tank needs more healing as the fight goes on.",
			"Optional.",
		}, abilities = {
			{ spellID = 1287872, name = "Tail Lash", flags = { "Damage" },
				text = "Sweeps her tail at the players behind her." },
			-- (1287879, also Trihorn Charge, is its other half: the hit, a best guess)
			{ spellID = 1287876, name = "Trihorn Charge", flags = { "Important" },
				text = "Charges a player standing away from her: damage and a knockback." },
			{ spellID = 1287886, name = "Puncture", flags = { "Tank", "Bleed" },
				text = "Gores the tank: each Puncture after it hurts 10% more, stacking, for 30 seconds." },
		}, loot = { Seen(280021, "Tooth of the Matriarch", "One-Hand, Dagger"), Seen(280022, "Scaleguard Scimitar", "One-Hand, Sword"),
				Seen(280045, "Regal Direhorn Drape", "Back") },
			mapPin = { x = 0.838, y = 0.609, floor = 1 } },
		--[[
			Izha'Rel (253218, model 143040, frost skin) and Tor'Rel (261811, model 143039, fire skin): both normal, not
			elite (the NPC data and a players' guide). The entry's creature and model are Tor'Rel's, whose list holds the
			pair's drops (the NPC data lists none for Izha'Rel: that they drop off him is a best guess); Izha'Rel is its
			add. Their pin: the owner's spot (2026-11-18), on the north side just above the Walk of Communion's label.
		]]
		{ name = "Ravasaur Hunters", npcID = 261811, displayID = 143039, encounterID = 3499, watchCorpse = true, level = 61,
			members = { { name = "Izha'Rel", npcID = 253218 }, { name = "Tor'Rel", npcID = 261811 } }, notes = {
			"Izha'Rel and Tor'Rel, two raptors that walk the north side together: most likely the fight the game calls Ravasaur Hunters. Izha'Rel's attacks are frost, Tor'Rel's fire.",
			"Neither is elite: crowd-control one (Sleep, Freezing Trap, Entangling Roots) while the group kills the other.",
			"Optional. Their drops are listed on Tor'Rel.",
		}, abilities = {
			{ spellID = 1287756, name = "Fiery Talons", flags = { "Healer" },
				text = "Tor'Rel rakes a player with burning talons: Fire damage, then more every 3 seconds for 12 seconds." },
			-- (the game's data has no text for it: by its name, a best guess)
			{ spellID = 1287747, name = "Berserk", flags = { "Enrage" },
				text = "Tor'Rel goes berserk. The game gives no text for it: most likely harder or faster attacks." },
		}, adds = {
			{ name = "Izha'Rel", npcID = 253218, abilities = {
				{ spellID = 6136, name = "Chilled", flags = { "Magic" },
					text = "Slows a player's movement by 30% and attacks by 25%." },
				{ spellID = 15089, name = "Frost Shock", flags = { "Magic" },
					text = "Frost damage to one player, and slower movement for 8 seconds." },
			} },
		}, loot = { Seen(280012, "Talon of Tor'Rel", "One-Hand, Sword"), Seen(280013, "Frostfang Mail Vest", "Chest, Mail"),
				Seen(280014, "Raptorscale Bulwark", "Off Hand, Shield") },
			mapPin = { x = 0.650, y = 0.359, floor = 1 } },
		--[[
			The four called up at the consoles (summoned; summonedBullet, the owner's rule of 2026-11-17: Before you
			go's one note, below, says how, and their pages show it). Each needs 15 Power Crystals of one color, the
			old Un'Goro crystals (11184-11188); where each console is: players' notes on the bosses (2026-11-16) and a
			players' guide (2026-11-18). The colors are every source's but the owner's search summary, which mixed in
			the four quest crystals of the Horde's Crystalline Elements (Fiery, Charged, Noxious, Moist: 271894,
			271898, 271902, 271912). A hotfix (2026-11-09) names Cinder's console the Archival Panel; the others'
			names are not known, so the note says "console". They stay in the run's count: Nanaya needs them (not
			OUT_OF_COUNT, unlike Lyn the Ignored).
		]]
		-- (the owner's spot, 2026-11-18: Ruby Spring, the hill with the red crystals in the south-west, on the ledge
		-- below them)
		{ name = "Cinder", npcID = 261974, displayID = 143035, encounterID = 3503, watchCorpse = true,
			summoned = true, summonedBullet = true, notes = {
			"A fire raptor. Fire Resistance helps against the heat around it.",
			"Stay clear of a player Conflagration sets on fire: the flames burn the allies near them. When it lands on the tank, Cinder turns on someone else for a few seconds.",
		}, abilities = {
			{ spellID = 1310267, name = "Radiating Heat", flags = { "Healer" },
				text = "Fire damage every 2 seconds to everyone within 7 yards of it." },
			{ spellID = 1310512, name = "Conflagration", flags = { "Important" },
				text = "Sets a player on fire for 4 seconds: Fire damage, and they run in panic. While they burn, the flames hurt their allies near them." },
		}, loot = { Seen(280028, "Heartflame Gauntlets", "Hands, Plate"), Seen(280029, "Cinderedge Crescent", "One-Hand, Axe") },
			mapPin = { x = 0.163, y = 0.673, floor = 1 } },
		-- (the owner's spot, 2026-11-18: the Hidden Wash's north rim in the north-west, under the Tribunal of Ages'
		-- western building, just west of the cave mark)
		{ name = "Snowtalon", npcID = 262297, displayID = 143122, encounterID = 3597, watchCorpse = true,
			summoned = true, summonedBullet = true, notes = {
			"A frost raptor, best fought away from its cave's crystals: pull it out into the open.",
			"Frost Resistance helps. Frost Nova roots everyone near it, and Howling Blast slows.",
		}, abilities = {
			{ spellID = 1310354, name = "Frost Nova", flags = { "Magic" },
				text = "Frost damage to everyone near it, rooting them for up to 8 seconds." },
			{ spellID = 1310514, name = "Howling Blast", flags = { "Healer" },
				text = "Frost damage to everyone within 8 yards of it, and 80% slower movement for 6 seconds." },
		}, loot = { Seen(280026, "Albinofur Grips", "Hands, Mail"), Seen(280027, "Crownroar Chestplate", "Chest, Plate") },
			mapPin = { x = 0.082, y = 0.118, floor = 1 } },
		-- (the owner's spot, 2026-11-18: on the Botanical Grounds' building, where its two domes meet at the top)
		{ name = "Bolt", npcID = 262081, displayID = 143063, encounterID = 3505, watchCorpse = true, level = 62,
			summoned = true, summonedBullet = true, notes = {
			"A lightning raptor. It takes no Nature damage.",
			-- (the same spell as Thunderhoof's: instant, its spell page says, so it can't be interrupted)
			"Don't stand close together: Chain Lightning jumps from player to player.",
			-- (a players' guide, 2026-11-18. The client has the item but not its effect: no effect row in its hotfix
			-- cache, and Forever shows an item's stats only once seen)
			"Players say Bolt's Charged Eyeball, the trinket it drops, does three times the damage to dinosaurs.",
		}, abilities = {
			{ spellID = 15588, name = "Thunderclap", flags = { "Healer" },
				text = "Nature damage to everyone near it, then attacks 33% slower and movement 40% slower for 10 seconds." },
			{ spellID = 1310513, name = "Chain Lightning", flags = { "Healer" },
				text = "Lightning that jumps between up to 4 players." },
		}, loot = { Seen(280031, "Sparklance Wand", "Ranged, Wand"), Seen(280032, "Bolt's Charged Eyeball", "Trinket") },
			mapPin = { x = 0.433, y = 0.722, floor = 1 } },
		-- (the owner's spot, 2026-11-18: the root-wrapped doorway of the Regrowth Vestibule, in the north, under its
		-- lintel)
		{ name = "Vitrix", npcID = 272561, displayID = 147098, encounterID = 3600, watchCorpse = true, level = 62,
			summoned = true, summonedBullet = true, notes = {
			"A poison raptor. Its poison can be cured, and it can be stunned.",
			-- (a player's note: about 2,000 on the tank from a hit no one could name)
			"Poison Shock hits everyone near its target: melee, spread out around it. It also lands a hard hit on the tank now and then.",
			"It has no items of its own: what it was seen dropping, one a kill, is Cinder's, Snowtalon's and Bolt's.",
		}, abilities = {
			{ spellID = 1312869, name = "Leech Poison", flags = { "Poison" },
				text = "Poisons a player and drains their health every 2 seconds for 16 seconds." },
			{ spellID = 1312870, name = "Poison Shock", flags = { "Damage" },
				text = "Nature damage to its target and everyone within 10 yards of them." },
		}, loot = { Seen(280028, "Heartflame Gauntlets", "Hands, Plate"), Seen(280029, "Cinderedge Crescent", "One-Hand, Axe"),
				Seen(280026, "Albinofur Grips", "Hands, Mail"), Seen(280027, "Crownroar Chestplate", "Chest, Plate"),
				Seen(280031, "Sparklance Wand", "Ranged, Wand"), Seen(280032, "Bolt's Charged Eyeball", "Trinket") },
			mapPin = { x = 0.508, y = 0.313, floor = 1 } },
		--[[
			Nanaya, the last boss (Data/Authored/RunTracker.lua): no summoned flag, as she is no hidden boss but the
			dungeon's end; Before you go's one note (below) says how she comes too, and her page shows it. Her fight,
			from a players' guide and a player's note (facts only): she charges up at the crystal clusters during it,
			and changes element every 25% of her health. Her four Energize spells (1290506-1290509) and four Energized
			(1290510-1290513) have no text; that each is one of the four clusters around the pillar, red, blue, yellow
			and green, each giving her one element (fire, frost, lightning, poison: her Blast Wave, Blizzard, Chain
			Lightning and Poison Cloud), is a best guess, so no stages.
		]]
		-- (the owner's spot, 2026-11-18: the Pillar of Assimilation he draws on the lake's island, just east of it)
		{ name = "Nanaya", npcID = 261809, displayID = 143832, encounterID = 3502, watchCorpse = true, level = 62, notes = {
			"The last boss, a titan keeper of stone. She comes once Cinder, Snowtalon, Bolt and Vitrix are dead: see Before you go.",
			"During the fight she goes to the crystal clusters around the pillar and charges up: her damage rises, and players report she takes on a new element every 25% of her health. Keep on whatever resistance gear you wore for the four raptors. The tank can step away while she charges.",
			-- (the Blueprint: Arcane Forge she drops now and then is not told here, nor the Arcane Forge the Spark is for,
			-- the blueprint's own name: Adventure Mode hides a dungeon's recipes until one is seen there, the owner,
			-- 2026-11-19; until then this note named "the forge's Blueprint". The Spark's own text names the forge.)
			"She drops a Maker's Spark nearly every kill.",
		}, abilities = {
			{ spellID = 1290463, name = "Powerful Slam", flags = { "Important" },
				text = "Slams the ground: everyone within 15 yards of her is stunned for 2 seconds." },
			{ spellID = 1290464, name = "Sonic Screech", flags = { "Important" },
				text = "A shockwave that deals Physical damage to everyone in its path." },
			{ spellID = 1290506, name = "Energize", flags = { "Important" },
				text = "She draws on one of the crystal clusters around the pillar: her damage rises and she gains attacks that hit an area." },
			-- (1291168, also Blizzard, its other half: a best guess)
			{ spellID = 1291167, name = "Blizzard", flags = { "Healer" },
				text = "Ice falls on an area: Frost damage every 3 seconds and 50% slower movement. Move out." },
			{ spellID = 1291176, name = "Blast Wave", flags = { "Healer" },
				text = "Fire damage to everyone near her, and slower movement for 2 seconds." },
			-- (no text in the game's data: by its name, a best guess)
			{ spellID = 1291274, name = "Poison Cloud", flags = { "Poison" },
				text = "A cloud of poison. The game gives no text for it: most likely, move out of it." },
			{ spellID = 1291380, name = "Chain Lightning", flags = { "Healer" },
				text = "Nature damage that jumps between up to 5 players, 10% less with each jump. Spread out." },
		}, loot = { Seen(280023, "Nanaya's Control Spire", "Two-Hand, Staff"), Seen(280024, "Legplates of Reinforced Crystal", "Legs, Plate"),
				Seen(280025, "Leggings of Curation", "Legs, Cloth"),
				-- (155 of 163 kills; the camp's Arcane Forge runs on it, its own text says)
				{ itemID = 273128, name = "Maker's Spark", slot = "Reagent", quality = 2 },
				-- (7 of 163 kills)
				Recipe(273116, "Blueprint: Arcane Forge", "Enchanting", 2),
				-- (once in 163 kills, 2026-11-19: above)
				QuestItem(272028, "Freya's Sigil", 3) },
			mapPin = { x = 0.741, y = 0.607, floor = 1 } },
		--[[
			King Op, a rare (Forever's NPC data: rare elite), a gorilla (his model). The game holds a fight for him (3504)
			all the same; as a rare he leaves the run's count. His one spawn mark is off the terrace, about 100 yards
			east and 50 south of the cave mark: inside the Prismatic Talus, whose map has a gorilla drawn beside it, as a
			player's note on the zone tells of a gorilla cave at the east end. The cave is likely; where in it, the
			weakest of the guesses: the far chamber with the pool, south of it. The owner's ring on the terrace's cave
			mark, "cave likely to King Op" (2026-11-18), keeps him in the cave. His drops: seen on only 5 kills, both
			Snowtalon's items.
		]]
		{ name = "King Op", npcID = 261993, displayID = 143129, encounterID = 3504, watchCorpse = true, rare = true, notes = {
			"A rare gorilla, most likely in the Prismatic Talus, the cave at the terrace's south-east corner. As a rare, he may not be there every run.",
			"The few kills recorded so far dropped Snowtalon's items.",
		}, abilities = {
			{ spellID = 12553, name = "Shock", flags = { "Healer" },
				text = "An instant bolt of lightning at one player." },
		}, loot = { Seen(280026, "Albinofur Grips", "Hands, Mail"), Seen(280027, "Crownroar Chestplate", "Chest, Plate") },
			-- (a best guess, low: the cave's far chamber, south of its pool)
			mapPin = { x = 0.700, y = 0.820, floor = 2 } },
		-- (the trash's seven and the terrace's one recipe: above)
		{ name = "Trash Drops", trash = true, loot = {
			Listed(287037, "Shaper's Robe", "Chest, Cloth"), Seen(287038, "Naturopathy Footpads", "Feet, Cloth"),
			Seen(287040, "Dinosaur Hide Belt", "Waist, Leather"), Seen(287041, "Time-Forgotten Bindings", "Wrist, Mail"),
			Seen(287042, "Pauldrons of the Stone Guardian", "Shoulder, Plate"), Seen(287044, "Predator's Shroud", "Back"),
			Seen(287045, "Ancient Mattock", "One-Hand, Axe") } },
		{ name = "Recipes", recipes = true, loot = { Recipe(273116, "Blueprint: Arcane Forge", "Enchanting", 2, "Nanaya") } },
	}),
	--[[
		Before you go (UI/BeforeYouGo.lua): one plain note, no hidden boss's skull (the owner's call of 2026-11-19:
		"this could be cleaned up and put into 1 easy to read comment", and the four "arent really hidden"; until then
		six notes). Its words are the owner's own short form, approved as written on 2026-11-20 (until then a longer
		note, with where each boss comes out and tips on the crystals): the four console bosses to summon and kill
		first, then a line each, his 15 crystals of his color, linked, and where his console is, then Nanaya at hers.
		The bullet and the times sign: every language's font draws both (each font's character map, read from the
		client's files on 2026-11-20) but Simplified Chinese's, whose bullet is an empty glyph (ARKai_T.ttf): a "-"
		there. It names all five (bosses), so each one's page opens on it: the four with their summoned bullet
		(UI/EncounterPage.lua's BossBullets), which then does not call them hidden; Nanaya with none, as she is the
		dungeon's end, not summoned. Where each console is: the players' notes and the guide; the map's pins are where
		the bosses appear, near their consoles. The Power Crystals' quality: the client's item data (common), so their
		links are white, as the game's are (Core/Items.lua's LinkText). Drafted in the other languages
		(Locales/*_content.lua), to be checked: the bosses' names stay as the game names them, as the journal matches
		them.
	]]
	prepare = {
		{
			title = "Summoning the bosses",
			bosses = { "Cinder", "Snowtalon", "Bolt", "Vitrix", "Nanaya" },
			-- (which waterfall is Snowtalon's: a players' guide, 2026-11-18. Vitrix's green: players' notes; a players'
			-- guide marks the green crystals for Vitrix as its best reading, every other source agrees. Left out of the
			-- short form, the owner's choice: the crystals grow in the dungeon and on the crater's floor; a console used
			-- during a pull brings its boss into that fight; the big blue crystals in Snowtalon's cave silence; where
			-- each boss comes out; no green crystals grow in Vitrix's cavern; Nanaya's scene.)
			text = "Four bosses must be summoned and killed before you can summon Nanaya, the last boss. Summon each at "
				.. "its console:\n"
				.. "• Cinder: 15 × {item:11186:Red Power Crystal:1}, on the hill with the red crystals (southwest)\n"
				.. "• Snowtalon: 15 × {item:11184:Blue Power Crystal:1}, in the cave behind the left waterfall (northwest)\n"
				.. "• Bolt: 15 × {item:11188:Yellow Power Crystal:1}, by the yellow crystals south of the tar pits\n"
				.. "• Vitrix: 15 × {item:11185:Green Power Crystal:1}, in a cavern on the north side\n"
				.. "Then summon Nanaya at the console on the Pillar of Assimilation's island.",
		},
	},
	--[[
		Santiago Reyes's maps (Atlas de Azeroth: Forever), his updated terrace and its cave, the Prismatic Talus, given
		by the owner on 2026-11-10 and converted from his full-size originals as his others: each floor named as his
		maps label it. The way in (entrance): the middle of the portal's swirl he draws at the Terrace Overlook, where
		the owner's green ring puts the way in (2026-11-18; the ring's middle and the swirl's are less than an art pixel
		apart); his other swirl, at the west edge where the Highlands Causeway starts, is not it. The ways between
		them, read off his pictures: on the terrace, the cave mark he drew above the
		Prismatic Talus's label, at the end of a dotted trail down from the plains (the cave's own icon on it); in the
		cave, the narrow end of its north-western chamber, where its wall thins and a way in from the north-west would
		come (a best guess: his cave map draws no opening). Its fog: Data/Fog/ShapersTerrace.lua.

		Not done yet: the map could open on the floor the player is in by the game's own area names. The client's
		readable rows under the dungeon (AreaTable 16667) are the terrace's: Shaper's Plateau, Pillar of Assimilation,
		The Verdant Plains, Lost Tar Pits, Ruby Spring, Walk of Communion, The Highlands Causeway, Watcher's Overlook,
		Botanical Grounds, Crystalline Highlands. No readable row is named "Prismatic Talus" (16 rows are locked): so
		floor 2's name would be a guess. Kept out until a run reads it with /aegis where.
	]]
	map = {
		floors = {
			{ art = MAPS .. "ShapersTerrace", artBottom = PICTURE },
			{ art = MAPS .. "ShapersTerracePrismaticTalus", artBottom = PICTURE },
		},
		-- the portal's swirl at the Terrace Overlook (the owner's, 2026-11-18)
		entrance = { x = 0.239, y = 0.694, floor = 1 },
		transitions = {
			{ floor = 1, to = 2, x = 0.921, y = 0.817, icon = "cave" },
			{ floor = 2, to = 1, x = 0.330, y = 0.218 },
		},
	},
	floorNames = { "Shaper's Terrace", "Prismatic Talus" },
})
