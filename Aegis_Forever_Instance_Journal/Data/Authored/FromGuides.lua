local _, ns = ...

--[[
	Facts checked against the guides, in our own words: corrections where they disagree with
	the generated data, and the dungeon quests it lacks.

	Sources: Wowhead's WoW: Forever guides ("Every Dungeon Quest in WoW Forever", "The Hall of
	Thanes Dungeon Overview") and quest pages, and warcraft.wiki.gg's quest pages (CC BY-SA 4.0).
	Quest givers' places come from those guides (/way); a recorded pick-up (Record tab) is
	exact and wins over them.
]]

local function AddQuests(key, quests)
	if ns.GetInstance(key) then ns.AmendInstance(key, { addQuests = quests }) end
end

-- Blizzard's recommended range, per Wowhead's guide and the dungeon announcement.
if ns.GetInstance("HallOfThanes") then ns.AmendInstance("HallOfThanes", { levelMin = 13, levelMax = 18 }) end

-- The Ruins' rare: its creature and model, per Wowhead's Forever NPC page (npc=255699, its
-- "View in 3D"). The other sources name it without either, so it had no portrait or model.
if ns.GetInstance("RuinsOfLordaeron") then
	ns.AmendInstance("RuinsOfLordaeron", { bosses = { ["Lordaeron Captain"] = { npcID = 255699, displayID = 139050 } } })
end

AddQuests("ExcavationSiteWetlands", {
	{
		questID = 95647, name = "Lost in the Thicket Things", level = 31, requiredLevel = 24, faction = "Alliance",
		pickup = "Caitlin Grassman, Wetlands",
		objective = "Find Ardin Grassman in the Excavation Site and learn what became of him.",
		rewards = { xp = 4900 },
	},
	{
		questID = 95664, name = "Elder Knowledge", level = 31, requiredLevel = 24, faction = "Horde",
		startItem = { itemID = 270866, name = "Titan Relic", note = "Looted inside the Excavation Site." },
		turnin = "Bashana Runetotem, Elder Rise, Thunder Bluff",
		objective = "Take the Titan Relic to the Elder Rise in Thunder Bluff, to someone who can say more about it.",
		rewards = { xp = 1400 },
	},
	{
		questID = 95810, name = "Lost Relic Carry", level = 31, requiredLevel = 24, faction = "Alliance",
		startItem = { itemID = 270865, name = "Titan Relic", note = "Looted inside the Excavation Site." },
		turnin = "Prospector Whelgar, Whelgar's Excavation Site, Wetlands",
		objective = "Bring the Titan Relic to Prospector Whelgar at his excavation in the Wetlands.",
		rewards = { xp = 1250 },
	},
})

AddQuests("Gnomeregan", {
	{
		questID = 2842, name = "Chief Engineer Scooty", level = 35, requiredLevel = 20, faction = "Horde",
		pickup = "Sovik, Valley of Honor, Orgrimmar", startMap = { mapID = 1454, x = 0.7549, y = 0.2536 },
		turnin = "Scooty, Booty Bay",
		objective = "Speak with Scooty in Booty Bay.",
		note = "Leads to Gnomer-gooooone!, the goblins' transporter to Gnomeregan.",
		rewards = { xp = 280 },
	},
	{
		questID = 2945, name = "Grime-Encrusted Ring", level = 30, faction = "Both",
		startObject = { name = "Grime-Encrusted Ring", note = "Dropped by Dark Iron Agents in Gnomeregan." },
		objective = "Find a way to clean the grime off the ring: the Sparklematic 5200 in Gnomeregan will.",
		note = "Leads to Return of the Ring.",
		-- 6,592 on Forever: the owner's recording, 2026-11-11 (the original game's 2,700 until then; the owner: "go with
		-- recording"). One quest for both sides: no twin to set. To check (0.39.21's review): the recordings' turn-in
		-- experience reads 3% over the quest window since 2026-11-10 (Return of the Ring 4,996 against 4,850), so the
		-- window most likely says 6,400; the owner reads it in game.
		rewards = { xp = 6592 },
	},
	{
		questID = 2947, name = "Return of the Ring", level = 30, requiredLevel = 10, faction = "Alliance",
		startObject = { name = "The Sparklematic 5200", note = "In Gnomeregan, once the ring is clean." },
		turnin = "Talvash del Kissel, Mystic Ward, Ironforge",
		objective = "Keep the ring, or find whoever made the mark engraved inside its band.",
		prerequisites = { { questID = 2945, name = "Grime-Encrusted Ring" } },
		-- 4,850 on Forever: the owner's quest window, 2026-11-11
		rewards = { xp = 4850 },
	},
	{
		questID = 2949, name = "Return of the Ring", level = 30, requiredLevel = 10, faction = "Horde",
		startObject = { name = "The Sparklematic 5200", note = "In Gnomeregan, once the ring is clean." },
		turnin = "Nogg, Valley of Honor, Orgrimmar",
		objective = "Keep the ring, or find whoever made the mark engraved inside its band.",
		prerequisites = { { questID = 2945, name = "Grime-Encrusted Ring" } },
		-- The Alliance's 4,850 (a best guess: the same quest at the same level; not seen on a Horde character)
		rewards = { xp = 4850 },
	},
})

AddQuests("RagefireChasm", {
	{
		questID = 5722, name = "Searching for the Lost Satchel", level = 16, requiredLevel = 9, faction = "Horde",
		pickup = "Rahauro, Elder Rise, Thunder Bluff", startMap = { mapID = 1456, x = 0.70, y = 0.32 },
		turnin = "Maur Grimtotem's corpse, Ragefire Chasm",
		objective = "Find Maur Grimtotem's corpse in Ragefire Chasm and search it.",
		note = "Leads to Returning the Lost Satchel.",
		rewards = { xp = 1800 },
	},
})

AddQuests("ScarletMonasteryLibrary", {
	{
		questID = 1160, name = "Test of Lore", level = 36, requiredLevel = 26, faction = "Horde",
		pickup = "Parqual Fintallas, The Apothecarium, Undercity", startMap = { mapID = 1458, x = 0.578, y = 0.654 },
		turnin = "Parqual Fintallas, The Apothecarium, Undercity",
		objective = "Find The Beginnings of the Undead Threat in the Library and bring it to Parqual Fintallas.",
		note = "Part of the Test of Faith chain, which starts with Dorn Plainstalker in Thousand Needles. The book is "
			.. "on a table in the first room on the left past the courtyard.",
		rewards = { xp = 5000, reputation = { { faction = "Undercity", amount = 75 } } },
	},
	{
		questID = 1951, name = "Rituals of Power", level = 40, requiredLevel = 30, faction = "Both", classOnly = "MAGE",
		pickup = "Magus Tirth, Shimmering Flats, Thousand Needles", startMap = { mapID = 1441, x = 0.783, y = 0.757 },
		turnin = "Magus Tirth, Shimmering Flats, Thousand Needles",
		objective = "Bring the book Rituals of Power, from the Library, to Magus Tirth.",
		note = "Follows Journey to the Marsh. The book lies at the north end of the hallway to Arcanist Doan.",
		rewards = { xp = 3150 },
	},
})
