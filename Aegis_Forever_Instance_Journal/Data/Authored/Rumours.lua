local _, ns = ...

--[[
	Each dungeon's line of rumour: in Adventure Mode, what a world-map door of a dungeon not entered yet
	says in place of its name (Core/Discovery.lua's DoorRumour). A line goes in here only once the owner
	has approved it; a dungeon with none says that little is known of it yet. In English, its
	translations in each Locales/<code>_content.lua's L.STRINGS, keyed by the line itself.

	All 38 picked by the owner on 2026-11-07, in the order of the list he picked from. Each comment says
	what its line hints at; no line names its dungeon or a boss.

	Loaded after every file that adds or amends a dungeon (the TOC), so each is here to take its line.
]]

-- The restless dead in the tomb of the dwarven kings.
ns.AmendInstance("HallOfThanes", {
	rumour = "Someone in Ironforge pays good coin for heirlooms brought up from the kings' resting place.",
})

-- The necromancer gathering undead in the ruined capital.
ns.AmendInstance("RuinsOfLordaeron", {
	rumour = "Brill folk swear the plague's dead still walk the courtyards where the human kings once ruled.",
})

-- The Titan construct at the end, which stands still until woken.
ns.AmendInstance("ExcavationSiteWetlands", {
	rumour = "At the end of a hidden dig in the Wetlands hills, a Titan figure of stone waits to be woken.",
})

-- Mana phantoms and the Angry Tomes; the way in by Lordamere Lake.
ns.AmendInstance("CityOfDalaran", {
	rumour = "Fishers on Lordamere Lake say wild magic has taken the mages' city, and even its books attack.",
})

-- The Searing Blade cultists under Orgrimmar.
ns.AmendInstance("RagefireChasm", {
	rumour = "Guards in Orgrimmar say chanting rises from the caves deep below the city.",
})

-- The deviate creatures and the Druids of the Fang.
ns.AmendInstance("WailingCaverns", {
	rumour = "Barrens herders say the caves have twisted every creature inside, druids included.",
})

-- The Defias in the Moonbrook mine, and the ship being built below.
ns.AmendInstance("TheDeadmines", {
	rumour = "Westfall farmers see the Defias vanish into the Moonbrook mine and hear hammering below.",
})

-- Arugal and his worgen in the keep above Pyrewood.
ns.AmendInstance("ShadowfangKeep", {
	rumour = "Travelers warn Pyrewood is not safe at night, and strange sounds can be heard from the keep!",
})

-- The Twilight's Hammer in Elune's sunken temple.
ns.AmendInstance("BlackfathomDeeps", {
	rumour = "Zoram fishers see lights far under the waves, where cultists guard a shrine the sea took.",
})

-- The Defias-led riot in Stormwind's prison.
ns.AmendInstance("TheStockade", {
	rumour = "From Lakeshire to Darkshire, bounties are posted on outlaws who run free in Stormwind's prison.",
})

-- The radiation the gnomes let loose on the troggs.
ns.AmendInstance("Gnomeregan", {
	rumour = "Gnome refugees mourn their lost home, still glowing from what they unleashed on the troggs.",
})

-- The quilboar thorns, and the undead envoys among them.
ns.AmendInstance("RazorfenKraul", {
	rumour = "Word on the Barrens road is that a goblin trader is held captive deep in quilboar country.",
})

-- Interrogator Vishas, and the dead that rise in the tombs.
ns.AmendInstance("ScarletMonasteryGraveyard", {
	rumour = "Anyone the Crusade suspects of carrying the plague is dragged to its crypts, and few come back.",
})

-- The Library books both factions' quests ask for, and the hounds.
ns.AmendInstance("ScarletMonasteryLibrary", {
	rumour = "Scholars in Ironforge and the Undercity alike want books the zealots guard with hounds.",
})

-- Herod's trainees and the weapon racks.
ns.AmendInstance("ScarletMonasteryArmory", {
	rumour = "Steel clashes from dawn to dusk where red-clad recruits train beside racks of fine weapons.",
})

-- Whitemane raising Mograine.
ns.AmendInstance("ScarletMonasteryCathedral", {
	rumour = "Old knights whisper that the truth of the Ashbringer's death waits beside the Crusade's high altar.",
})

-- Amnennar and the Scourge among the quilboar barrows, by the Great Lift road.
ns.AmendInstance("RazorfenDowns", {
	rumour = "By the road to Thousand Needles, quilboar bow to the walking dead among their burial mounds.",
})

-- The troggs from the Titan vault, and the Dark Iron dig.
ns.AmendInstance("Uldaman", {
	rumour = "Badlands prospectors say troggs pour from a vault older than the dwarves, where Dark Irons now dig.",
})

-- Zum'rah's risen dead in the troll graveyard.
ns.AmendInstance("ZulFarrak", {
	rumour = "Gadgetzan traders buy scarab shells and troll potions from anyone who dares enter the desert city.",
})

-- Zaetar's grave, the centaurs at the gate, the earth elementals inside.
ns.AmendInstance("Maraudon", {
	rumour = "The centaurs of Desolace guard the grave of a god's son, where even the rocks attack intruders.",
})

-- The Atal'ai trolls and their blood god.
ns.AmendInstance("TempleOfAtalHakkar", {
	rumour = "Swamp of Sorrows hunters hear troll drums from a flooded pit, beating for a god of blood.",
})

-- The Dark Iron city inside Blackrock Mountain.
ns.AmendInstance("BlackrockDepths", {
	rumour = "Searing Gorge miners swear the Dark Irons built a whole city of fire inside the mountain.",
})

-- Rend Blackhand's army in the lower spire.
ns.AmendInstance("LowerBlackrockSpire", {
	rumour = "An orc who calls himself warchief is gathering an army halfway up the mountain, scouts report.",
})

-- The black dragonflight's brood, and the Seal you need to get in.
ns.AmendInstance("UpperBlackrockSpire", {
	rumour = "Black dragons are bred for war at the mountain's peak, they say, and the way up is sealed.",
})

-- The satyrs and the corrupted treants.
ns.AmendInstance("DireMaulEast", {
	rumour = "Feralas tales say the satyrs of the old city were elves once, until demons twisted them.",
})

-- The Gordok rule behind the tribute run: kill the king, take his crown.
ns.AmendInstance("DireMaulNorth", {
	rumour = "A gnome chained up among the ogres begs passers-by for cloth and leather to sew a disguise.",
})

-- The Highborne pylons and the demon behind them.
ns.AmendInstance("DireMaulWest", {
	rumour = "Anyone who brings lost books home to the elves of the western halls earns a fine reward.",
})

-- The school of necromancy on Caer Darrow.
ns.AmendInstance("Scholomance", {
	rumour = "Boatmen won't row to the island in Darrowmere Lake, where the living learn to raise the dead.",
})

-- The Grand Crusader, who is really a dreadlord: Stratholme's, and its Main Gate's. Stratholme is one dungeon with
-- two doors since 0.39.22; each door keeps the line its gate had as a page of its own (the owner's call of
-- 2026-11-12: one rumour per door).
ns.AmendInstance("Stratholme", {
	rumour = "The Argent Dawn warns that the Crusade's leader in the burned city is not what he seems.",
})

-- The undead baron raising the Scourge's army: Stratholme's second door, the Service Gate.
ns.AmendDoor("Stratholme", 2, {
	rumour = "A ghost outside the walls begs the living to save the woman he loves before time runs out.",
})

-- Onyxia in the Wyrmbog, and her whelps.
ns.AmendInstance("OnyxiasLair", {
	rumour = "Dustwallow trappers know of a black dragon in the Wyrmbog caves, guarded by swarms of whelps.",
})

-- Old lore: the night elves' underground prison (a best guess: the data has only its name).
ns.AmendInstance("BarrowDeeps", {
	rumour = "Night elves will not speak of the vaults beneath their forests, or of who was locked inside.",
})

-- An unknown raid by the world tree. The zone is open on Forever; the raid isn't.
ns.AmendInstance("HyjalSummit", {
	rumour = "Druids on the mountain call for fighters to guard the great tree against an old enemy.",
})

-- The risen troll city and the pirates in it.
ns.AmendInstance("TheDrownedCity", {
	rumour = "Booty Bay sailors say the sea gave back an old troll city, and pirates got there first.",
})

-- Ogres allied with the Twilight's Hammer.
ns.AmendInstance("KroldokStronghold", {
	rumour = "The ogres of the Riverglades have new friends in Twilight robes.",
})

-- The naga on the island and the Defias prisoners.
ns.AmendInstance("AlcazPrison", {
	rumour = "Naga swarm the island jail off the Dustwallow coast, and its Defias inmates never got out.",
})

-- The corrupted furbolg and what's below their den.
ns.AmendInstance("BlackmawHold", {
	rumour = "Travelers say the furbolg of northern Azshara have gone mad, sickened by something below.",
})

-- The Titan site in Un'Goro.
ns.AmendInstance("ShapersTerrace", {
	rumour = "Past the dinosaurs lie stone halls that no one has mapped yet, or so the explorers whisper.",
})
