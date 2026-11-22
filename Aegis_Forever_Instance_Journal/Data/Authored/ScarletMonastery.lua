local _, ns = ...

--[[
	The Scarlet Monastery's wings, written by hand over their own data (Data/Instances).
	Facts from warcraft.wiki.gg, "Scarlet Monastery Graveyard" and "Scarlet Monastery Library"
	(CC BY-SA 4.0), in our own words.

	To the client every wing is the same instance (189), so each wing lists the areas inside it
	(wingAreas): the journal tells which wing the player is in by the area's name.

	Each wing's areas, as two players' recordings name them (2026-11-13, and the owner's of 2026-11-16: one run of each
	wing in turn, the same order in both): the Graveyard's Chamber of Atonement, Forlorn Cloister and Honor's Tomb; the
	Library's Huntsman's Cloister, Gallery of Treasures and Athenaeum (below); the Armory's Training Grounds, Footman's
	Armory, Crusader's Armory and Hall of Champions, and the Cathedral's Chapel Gardens and Crusader's Chapel (in their
	own files, Data/Instances). No name is in two wings, in either recording. The client's own tables agree: each
	name is a room of that wing's building; the Armory's building also names two halls "The Grand Vestibule", which
	neither recording saw (so it is not one of the Armory's areas here).
	Not a wing's, though both recordings list them first, before the Graveyard's and the Library's rooms: "Terrace of
	Repose" and "Whispering Gardens". They are Tirisfal's (the client's area table: 161 and 160, on the Eastern
	Kingdoms, under Tirisfal Glades; the monastery's own ground inside is all 796, "Scarlet Monastery"), the ground
	outside the doors, still named for a moment as the player comes in (the Record tab notes the area then). Every wing
	is entered from that ground, so either name would put a player coming into the Armory or the Cathedral in the
	Graveyard or the Library. Until a room of the wing's own is named, or one of its fights starts or ends, its wing is
	not known (UI/DungeonMap.lua's WaitForWing; the run block's "Which wing?").
]]

--[[
	The wings' pictures (the owner's call, 2026-11-09): the Armory and the Cathedral their own, from the loading
	screens the owner gave (the hall of statues; the cathedral's courtyard), cut as the journal's other pictures
	(ns.UseDungeonPicture). The Graveyard and the Library share the original Scarlet Monastery loading screen,
	which the owner gave too: the game's journal art for the monastery is a later expansion's painting of its
	courtyard, the Cathedral's own picture now. The Graveyard's is shaded a darker moonlit blue so the two look
	different (artTint, ns.TintInstanceArt; first grey, which the owner found didn't suit it, 2026-11-09).
]]
ns.UseDungeonPicture(ns.GetInstance("ScarletMonasteryArmory"), "ScarletMonasteryArmory")
ns.UseDungeonPicture(ns.GetInstance("ScarletMonasteryCathedral"), "ScarletMonasteryCathedral")
ns.UseDungeonPicture(ns.GetInstance("ScarletMonasteryGraveyard"), "ScarletMonastery")
ns.UseDungeonPicture(ns.GetInstance("ScarletMonasteryLibrary"), "ScarletMonastery")

ns.AmendInstance("ScarletMonasteryGraveyard", {
	artTint = { color = { 0.55, 0.62, 0.85 } },
	description = "The Scarlet Monastery was a seat of Lordaeron's priesthood until the Scarlet Crusade made it "
		.. "their stronghold after the Third War. In its graveyard wing the Crusade's interrogators work, and "
		.. "the dead buried there no longer rest.",
	-- Its words for this wing stay in the overview's facts where Spoken's story, the monastery's one story, shows
	-- (UI/EncounterPage.lua's FillInstanceOverview).
	overviewNote = "In its graveyard wing the Crusade's interrogators work, and the dead buried there no longer rest.",

	wingAreas = { ["Chamber of Atonement"] = true, ["Forlorn Cloister"] = true, ["Honor's Tomb"] = true },
	areas = { "Chamber of Atonement", "Forlorn Cloister", "Honor's Tomb" },

	bosses = {
		["Interrogator Vishas"] = { area = "Chamber of Atonement" },
		["Azshir the Sleepless"] = { area = "Forlorn Cloister" },
		["Fallen Champion"] = { area = "Forlorn Cloister" },
		["Ironspine"] = { area = "Forlorn Cloister" },
		["Bloodmage Thalnos"] = { area = "Honor's Tomb" },
	},
})

ns.AmendInstance("ScarletMonasteryLibrary", {
	description = "The monastery's library wing, where the Crusade's huntsmen keep their hounds and Arcanist Doan "
		.. "guards the Athenaeum and the key to the rest of the monastery.",
	-- Its whole description stays in the overview's facts where Spoken's story, its dungeon's one story, shows: it
	-- tells this wing from the others (UI/EncounterPage.lua's FillInstanceOverview).
	overviewNote = true,

	wingAreas = { ["Huntsman's Cloister"] = true, ["Gallery of Treasures"] = true, ["Athenaeum"] = true },
	areas = { "Huntsman's Cloister", "Gallery of Treasures", "Athenaeum" },

	bosses = {
		["Houndmaster Loksey"] = {
			area = "Huntsman's Cloister",
			notes = { "His Scarlet Tracking Hounds fight beside him: kill them first. He uses Bloodlust." },
		},
		["Arcanist Doan"] = {
			area = "Athenaeum",
			notes = { "His Arcane Explosion hits everyone close to him, and Detonation hits harder still: keep your distance when he readies it." },
		},
	},
})

-- Where the Armory's and the Cathedral's fights were fought, as the client named the area as each started (two
-- players' recordings, 2026-11-13 and 2026-11-16: their ENCOUNTER lines). Mograine's is Whitemane's fight, 450, which
-- starts as he is pulled (the owner's recording of 2026-11-16: his spells from its first seconds): the chapel too.
ns.AmendInstance("ScarletMonasteryArmory", { bosses = { ["Herod"] = { area = "Hall of Champions" } } })
ns.AmendInstance("ScarletMonasteryCathedral", { bosses = {
	["High Inquisitor Fairbanks"] = { area = "Crusader's Chapel" },
	["Scarlet Commander Mograine"] = { area = "Crusader's Chapel" },
	["High Inquisitor Whitemane"] = { area = "Crusader's Chapel" },
} })

-- The Cathedral's two quests send you through the Armory too, for Herod: the Armory lists them as well
-- (foreverchanges.pro's page for it does). The world map still marks each once.
do
	local herodQuests = {}
	for _, quest in ipairs(ns.GetInstance("ScarletMonasteryCathedral").quests) do
		if quest.questID == 1053 or quest.questID == 1048 then herodQuests[#herodQuests + 1] = quest end
	end
	ns.AmendInstance("ScarletMonasteryArmory", { addQuests = herodQuests })
end