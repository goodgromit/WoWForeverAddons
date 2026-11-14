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
	{ "ShadowfangKeep", "Archmage Arugal" },              -- the top of the keep
	{ "BlackfathomDeeps", "Aku'mai" },                    -- the last room; Baron Aquanis is a quest summon
	{ "TheStockade", "Bazil Thredd" },                    -- the last cell block, the main quest's target
	{ "Gnomeregan", "Mekgineer Thermaplugg" },            -- the last room; Techbot stands outside (below)
	{ "RazorfenKraul", "Charlga Razorflank" },            -- the end of the kraul; Razorfen Spearhide is on the way
	{ "RazorfenDowns", "Amnennar the Coldbringer" },      -- the top of the barrows; Plaguemaw is a side boss
	{ "Uldaman", "Archaedas" },                           -- the Chamber of Khaz'mul, the last room
	{ "ZulFarrak", "Chief Ukorz Sandscalp" },             -- the top of the pyramid stairs
	{ "Maraudon", "Princess Theradras" },                 -- the bottom of the inner caves
	{ "TempleOfAtalHakkar", "Shade of Eranikus" },        -- the last room, down the temple
	{ "BlackrockDepths", "Emperor Dagran Thaurissan" },   -- the throne room; Princess Moira stands with him
	{ "Scholomance", "Darkmaster Gandling" },             -- the last room, once the others are dead
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
	{ "StratholmeMainGate", "Balnazzar" },
	{ "StratholmeServiceGate", "Baron Rivendare" },
	-- Forever's own dungeons: the last boss on the journal's list, nothing more known yet.
	{ "HallOfThanes", "Durgen Dirgehammer" },
	{ "RuinsOfLordaeron", "Viktor the Vile" },
	{ "ExcavationSiteWetlands", "Relic Guardian" },
	{ "CityOfDalaran", "Shade of the Archmage" },
	{ "TheDrownedCity", "Min'loth the Serpent" },
	{ "KroldokStronghold", "Overseer Mugg" },
	{ "AlcazPrison", "Blazeroar" },
	{ "BlackmawHold", "Unbound Spirit" },
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
	The dungeons whose parts are one copy, walked between inside without a loading screen (best guesses): a new run
	clears the kills of every part, a wing change inside keeps the run, and coming back in by another part's door
	within the half hour is the same run (Core/Run.lua's SameCopy). Scarlet Monastery's four wings share one instance
	id too, but each is behind its own door and its own copy: left out, so a visit to one keeps another's kills.
]]
for _, key in ipairs({ "StratholmeMainGate", "StratholmeServiceGate", "LowerBlackrockSpire", "UpperBlackrockSpire",
	"DireMaulEast", "DireMaulWest", "DireMaulNorth" }) do
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
