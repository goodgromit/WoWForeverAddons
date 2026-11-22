local _, ns = ...

--[[
	For the run block (UI/RunTracker.lua, Core/Run.lua).

	Each dungeon's final boss: the run's clock stops at his kill, so a run that skips optional or summoned bosses
	still ends. ALL BEST GUESSES, for the owner to confirm one dungeon at a time; a dungeon left out here stops its
	clock once every boss on its list is dead. By the boss's English name, as the dungeon's data has it.
]]
local FINAL_BOSSES = {
	-- The classic dungeons: the boss at the end of the usual way through, whom the dungeon's main quest is for.
	{ "RagefireChasm", "Bazzalan" },                      -- last on the list; Taragaman can come before or after him
	{ "WailingCaverns", "Mutanus the Devourer" },         -- comes after Naralex's awakening, the run's end
	{ "TheDeadmines", "Edwin VanCleef" },                 -- the ship, the last room
	{ "ShadowfangKeep", "Archmage Arugal" },              -- the top of the keep; the steeds and Voidwalkers not counted (below)
	{ "BlackfathomDeeps", "Aku'mai" },                    -- the last room; Baron Aquanis is a quest summon (not counted: below)
	{ "TheStockade", "Bazil Thredd" },                    -- the last cell block, the main quest's target
	{ "Gnomeregan", "Mekgineer Thermaplugg" },            -- the last room; Techbot stands outside (below)
	{ "RazorfenKraul", "Charlga Razorflank" },            -- the end of the kraul
	{ "RazorfenDowns", "Amnennar the Coldbringer" },      -- the top of the barrows; Plaguemaw is a side boss
	{ "Uldaman", "Archaedas" },                           -- the Chamber of Khaz'mul, the last room
	{ "ZulFarrak", "Chief Ukorz Sandscalp" },             -- the top of the pyramid stairs
	{ "Maraudon", "Princess Theradras" },                 -- the bottom of the inner caves
	{ "TempleOfAtalHakkar", "Shade of Eranikus" },        -- the last room, down the temple
	{ "BlackrockDepths", "Emperor Dagran Thaurissan" },   -- the throne room; Princess Moira stands with him
	{ "Scholomance", "Darkmaster Gandling" },             -- the last room, once the others are dead
	-- Stratholme's end is the Baron's, past the Service Gate, alone (the owner's call of 2026-11-12): a run of the Main
	-- Gate's side only, Balnazzar its last, keeps its clock until it is left behind (Core/Run.lua's Freeze: its end is
	-- when the player was last inside).
	{ "Stratholme", "Baron Rivendare" },
	-- One dungeon in parts: the end of each part.
	{ "ScarletMonasteryGraveyard", "Bloodmage Thalnos" },
	{ "ScarletMonasteryLibrary", "Arcanist Doan" },
	{ "ScarletMonasteryArmory", "Herod" },
	{ "ScarletMonasteryCathedral", "High Inquisitor Whitemane" },
	{ "LowerBlackrockSpire", "Overlord Wyrmthalak" },
	{ "UpperBlackrockSpire", "General Drakkisath" },
	{ "DireMaulEast", "Alzzin the Wildshaper" },          -- Lethtendris and Zevrim are on the way back
	{ "DireMaulWest", "Prince Tortheldrin" },             -- Immol'thar, before him, is the other big fight
	{ "DireMaulNorth", "King Gordok" },                   -- Cho'Rush fights beside him
	-- Forever's own dungeons: the last boss on the journal's list, nothing more known yet.
	{ "HallOfThanes", "Durgen Dirgehammer" },
	{ "RuinsOfLordaeron", "Viktor the Vile" },
	{ "ExcavationSiteWetlands", "Relic Guardian" },
	{ "CityOfDalaran", "Shade of the Archmage" },
	{ "TheDrownedCity", "Min'loth the Serpent" },
	{ "KroldokStronghold", "Overseer Mugg" },
	{ "AlcazPrison", "Blazeroar" },
	-- Blackmaw Hold's: Varrox Bleakhoof, not the Unbound Spirit, the last fight on the game's list (the owner's call of
	-- 2026-11-18: "a hole you drop down to get to the last boss and the depths of forbidden magic"; the dungeon's exit
	-- portal is behind him, Data/Authored/Upcoming.lua)
	{ "BlackmawHold", "Varrox Bleakhoof" },
	{ "ShapersTerrace", "Nanaya" },
}
for _, row in ipairs(FINAL_BOSSES) do
	if ns.GetInstance(row[1]) then ns.AmendInstance(row[1], { finalBoss = row[2] }) end
end

--[[
	Bosses who stand outside the instance, on the way in: never in a run's count (its total is what can be done
	inside), and no line either: the journal sees kills only inside an instance (UI/DungeonMap.lua's WatchDeaths and
	ENCOUNTER_END), and going in starts a new run (Core/Run.lua: outsideRun). Gnomeregan's Techbot is in Dun Morogh,
	outside the instance (the owner, 2026-11-12: Gnomeregan's run is 5/5, Techbot and the Dark Iron Ambassador, a rare,
	not counted).
]]
ns.AmendInstance("Gnomeregan", { bosses = { ["Techbot"] = { outsideRun = true } } })

--[[
	Bosses inside the dungeon that are not one of the run's own fights: a boss a usual run does not fight, or creatures
	that come with another's fight. Out of the run's count and its circles (uncounted: Core/Run.lua's Bosses), with a
	"1/1 ... defeated" line only once one is killed (Run.Others); a kill of one still starts a waiting clock
	(Core/Run.lua's Killed), and the final boss still ends the run. Kept on the journal's pages and the map, with their
	loot. By the dungeon's key and the boss's English name, one entry each; the owner's calls, one boss at a time
	(others like them are listed for the owner, not set).
	- Blackfathom Deeps' Baron Aquanis (the owner, 2026-11-14, from a player's screenshot of a run that read 0/8 with
	  "0/1 Baron Aquanis defeated"): a boss only the Horde calls up, by a quest (the Fathom Stone in the water gives the
	  Fathom Core for Amongst the Ruins, and he rises from it: Data/Authored/BlackfathomDeeps.lua's note). Blackfathom
	  Deeps counts 7.
	- Shadowfang Keep's Fel Steed / Shadow Charger and Arugal's Voidwalker (the owner, 2026-11-17: the steeds and the
	  summoned Voidwalkers are not counted bosses). The steeds stand in the courtyard (their pin's floor); the four
	  Voidwalkers come once Fenrus the Devourer dies, called by Arugal. Neither has a fight of the game's own: each is
	  counted by its corpse seen dead (the Shadow Charger by its English name only) or looted (the Fel Steed and the
	  Voidwalkers, by creature id: UI/DungeonMap.lua's WatchDeaths), so the Voidwalkers' line comes with the first of
	  the four seen dead, not the last. Shadowfang Keep counts 8 (10 before), Archmage Arugal still its final boss.
	- The City of Dalaran's Lyn the Ignored (the owner, 2026-11-17: "the summoned boss for dalaran isn't a rare"): a
	  hidden boss the players summon with the Tome of Dalaran (summoned = true in Data/Instances/CityOfDalaran.lua, his
	  page's bullet; Data/Authored/CityOfDalaran.lua's note says how), no chance spawn. Out of the count and with his
	  line once killed, as he was while he was flagged rare. The City of Dalaran counts 7.
]]
local OUT_OF_COUNT = {
	BlackfathomDeeps = { "Baron Aquanis" },
	ShadowfangKeep = { "Fel Steed / Shadow Charger", "Arugal's Voidwalker" },
	CityOfDalaran = { "Lyn the Ignored" },
}
for key, names in pairs(OUT_OF_COUNT) do
	local patch = {}
	for _, name in ipairs(names) do patch[name] = { uncounted = true } end
	ns.AmendInstance(key, { bosses = patch })
end

--[[
	The dungeons whose parts are one copy, walked between inside without a loading screen (best guesses): a new run
	clears the kills of every part, a wing change inside keeps the run, and coming back in by another part's door
	within the half hour is the same run (Core/Run.lua's SameCopy). Scarlet Monastery's four wings share one instance
	id too, but each is behind its own door and its own copy: left out, so a visit to one keeps another's kills.
]]
for _, key in ipairs({ "LowerBlackrockSpire", "UpperBlackrockSpire", "DireMaulEast", "DireMaulWest", "DireMaulNorth" }) do
	if ns.GetInstance(key) then ns.AmendInstance(key, { oneCopy = true }) end
end

--[[
	The Sunken Temple's six balcony trolls are one entry ("Balcony Minibosses", together = true), which no fight
	and no creature is named for: its circle is crossed out once all six have been seen dead (UI/DungeonMap.lua,
	DungeonMap:MemberDown), as target, mouseover or focus, or as their corpses are looted. By name, and by creature
	id (best guesses: the classic ids of these six, not read in Forever's own files).
]]
ns.AmendInstance("TempleOfAtalHakkar", { bosses = {
	["Balcony Minibosses"] = { members = {
		{ name = "Gasher", npcID = 5713 },
		{ name = "Hukku", npcID = 5715 },
		{ name = "Loro", npcID = 5714 },
		{ name = "Mijan", npcID = 5717 },
		{ name = "Zolo", npcID = 5712 },
		{ name = "Zul'Lor", npcID = 5716 },
	} },
} })

--[[
	Blackfathom Deeps' Lorgus Jett: the game starts his fight (2913) but never ends it. Two players' recordings
	(2026-10-11 and 2026-11-13) have it started with no kill and no wipe, though both looted him; the owner's of
	2026-11-08 has no fight for him at all. The map watches the corpses only of bosses it knows no fight of
	(UI/DungeonMap.lua), so his kill never counted. With watchCorpse his corpse counts him (seen as the target, focus
	or mouseover, or looted), and his fight's id stays (Data/Generated/Abilities.lua, which every rebuild of the data
	writes again): its start still tells a new copy (Core/Run.lua), and should the game ever end it, its end counts too.
]]
ns.AmendInstance("BlackfathomDeeps", { bosses = { ["Lorgus Jett"] = { watchCorpse = true } } })

--[[
	Fights the game names otherwise than the journal does, or one fight for several of its bosses: by these other
	names (aliases), a fight's end crosses out each boss it is for (ns.BossesForFight), and a corpse by its own name
	counts (UI/DungeonMap.lua). From the client's own list of fights (DungeonEncounter in Forever's client files,
	1.60.1.70938, read 2026-11-13). No run of these dungeons is recorded yet, so that the game starts these fights
	there is a best guess: in every dungeon a recording shows, it starts the client's fights of that dungeon.
	- Uldaman: one fight, "The Lost Dwarves" (548), for Eric "The Swift", Olaf and Baelog. Each keeps his circle; the
	  fight's end crosses out all three, and each one's corpse seen still counts him alone.
	- Scholomance: the client calls the Herald's fight "Kirtonos" (2805), and Ras Frostwhisper's "Ras Frostwhisperer"
	  (2810, so spelled). Without these, only their corpses seen counted them.
	- The Sunken Temple: the client holds three sets of fights for the temple, and which one the game starts is not
	  recorded yet. Forever's own (3582 to 3589) and the original game's (486 to 493, 2814) name each boss as the
	  journal does: Atal'alarion, the Avatar of Hakkar, the Shade of Eranikus, Hazzas, Morphaz, Weaver, Dreamscythe and
	  Jammal'an the Prophet. The Season of Discovery raid's (2952 to 2959) pairs them: "Dreamscythe and Weaver" (2955),
	  "Morphaz and Hazzas" (2958), "Jammal'an and Ogom" (2957), and "Atal'ai Defenders" (2954) for the six balcony
	  trolls. Those four names are kept here, so that whichever set it is, a fight's end crosses out each of its bosses
	  (the report of 2026-11-13, of two dragons left standing at a run's end, came from a window that is not the
	  journal's). Ogom, the Spawn of Hakkar and the balcony trolls have no fight in the other two sets: their corpses
	  count them.
	- Blackrock Depths' Ring of Law: one fight, "Ring of Law" (230), whichever challenger comes. The journal names
	  each "Ring of Law: ...", which no creature is called, so the line of the one killed never came: by his own name
	  his corpse counts him. By that name only: the challengers have no creature id in the data, so he counts when
	  seen dead as the target, focus or mouseover, on a client that names him in English, and not when looted (the
	  loot window goes by creature id). The same holds for Shadowfang Keep's Shadow Charger, whose own id is not known
	  (only the Fel Steed's, 3864). Best guess, to confirm from a Record export: the original game's ids, 9027 to 9032
	  for the challengers, 3865 for the Shadow Charger.
	- The Drowned City: the game calls Deathless Marrow's fight "Deathless Guardians" (3478, a player's recording of
	  2026-11-13). Its id counts it already (Data/Authored/Upcoming.lua); its name does too, should the id change.
]]
local OTHER_NAMES = {
	Uldaman = { ['Eric "The Swift"'] = { "The Lost Dwarves" }, Olaf = { "The Lost Dwarves" },
		Baelog = { "The Lost Dwarves" } },
	Scholomance = { ["Kirtonos the Herald"] = { "Kirtonos" }, ["Ras Frostwhisper"] = { "Ras Frostwhisperer" } },
	TempleOfAtalHakkar = { ["Balcony Minibosses"] = { "Atal'ai Defenders" },
		["Jammal'an the Prophet"] = { "Jammal'an and Ogom" }, ["Ogom the Wretched"] = { "Jammal'an and Ogom" },
		Weaver = { "Dreamscythe and Weaver" }, Dreamscythe = { "Dreamscythe and Weaver" },
		Morphaz = { "Morphaz and Hazzas" }, Hazzas = { "Morphaz and Hazzas" } },
	BlackrockDepths = { ["Ring of Law: Gorosh the Dervish"] = { "Gorosh the Dervish" },
		["Ring of Law: Eviscerator"] = { "Eviscerator" }, ["Ring of Law: Ok'thor the Breaker"] = { "Ok'thor the Breaker" },
		["Ring of Law: Hedrum the Creeper"] = { "Hedrum the Creeper" }, ["Ring of Law: Grizzle"] = { "Grizzle" },
		["Ring of Law: Anub'shiah"] = { "Anub'shiah" } },
	TheDrownedCity = { ["Deathless Marrow"] = { "Deathless Guardians" } },
}
for key, names in pairs(OTHER_NAMES) do
	local patch = {}
	-- Added to any other names the boss has already.
	for _, boss in ipairs(ns.GetInstance(key).bosses) do
		if names[boss.name] then
			local aliases = {}
			for _, alias in ipairs(boss.aliases or {}) do aliases[#aliases + 1] = alias end
			for _, alias in ipairs(names[boss.name]) do aliases[#aliases + 1] = alias end
			patch[boss.name] = { aliases = aliases }
		end
	end
	for name in pairs(names) do assert(patch[name], "OTHER_NAMES: " .. key .. " has no boss named " .. name) end
	ns.AmendInstance(key, { bosses = patch })
end

--[[
	Each fight's id for three dungeons whose bosses had none, from a player's recording (2026-11-13: the Record tab's
	ENCOUNTER lines, each fight won under the journal's name for its boss). By its name a fight counted only where the
	game names it as the journal does, so in English; by its id it counts in any language. A rebuild of the data
	(Dev/build_data.py) writes the same ids into Data/Generated/Abilities.lua; these stay either way. Their corpses
	are still watched (watchCorpse, as Lorgus Jett's above): the map watches only bosses with no fight id
	(UI/DungeonMap.lua), and these counted by their corpses before they had one, so a player who misses the fight's
	end (who joins after the kill, or is outside as a ghost) still gets the kill. Not here: the rare Ragglesnout, who
	had no fight of his own in that run; his corpse counts him, as before.

	Scarlet Commander Mograine fights in Whitemane's fight, 450: the owner's recording of 2026-11-16 has all his spells
	inside it, in each of its three kills, from its first seconds (he is pulled first; she comes when he falls and
	raises him), and no fight of his own (449 is Fairbanks's). So he has its id too, and its end crosses out both, in
	any language (ns.BossesForFight). Unlike Sneed's Shredder in Sneed's fight, he keeps his own circle and line
	(joinsFight: Core/Run.lua's Bosses), as the Lost Dwarves keep theirs; Whitemane stays the Cathedral's final boss
	(above), so the clock stops at 450's end, both down. The fight is hers: its loot by the fight's id goes under her
	(Core/Recorder.lua), and Spoken's story for 450 is hers, not his (UI/SpokenButton.lua). His corpse still counts him.
	Every Scarlet Monastery id above matches that recording (444, 2779, 446, 447, 448, 449, 450).
]]
local RECORDED_IDS = {
	RagefireChasm = { Oggleflint = 2732, ["Taragaman the Hungerer"] = 2733, ["Jergosh the Invoker"] = 2734,
		Bazzalan = 2735 },
	RazorfenDowns = { ["Tuten'kash"] = 2780, ["Plaguemaw the Rotting"] = 2781, ["Mordresh Fire Eye"] = 2782,
		Glutton = 2784, ["Amnennar the Coldbringer"] = 2785 },
	ScarletMonasteryGraveyard = { ["Interrogator Vishas"] = 444, ["Bloodmage Thalnos"] = 2779 },
	ScarletMonasteryLibrary = { ["Houndmaster Loksey"] = 446, ["Arcanist Doan"] = 447 },
	ScarletMonasteryArmory = { Herod = 448 },
	ScarletMonasteryCathedral = { ["High Inquisitor Fairbanks"] = 449, ["Scarlet Commander Mograine"] = 450,
		["High Inquisitor Whitemane"] = 450 },
}
for key, ids in pairs(RECORDED_IDS) do
	local patch = {}
	for name, id in pairs(ids) do patch[name] = { encounterID = id, watchCorpse = true } end
	ns.AmendInstance(key, { bosses = patch })
end
ns.AmendInstance("ScarletMonasteryCathedral", { bosses = { ["Scarlet Commander Mograine"] = { joinsFight = true } } })
