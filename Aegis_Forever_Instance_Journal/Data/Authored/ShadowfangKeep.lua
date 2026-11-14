local _, ns = ...

--[[
	Shadowfang Keep, written by hand over the generated data.
	Facts from warcraft.wiki.gg, "Shadowfang Keep (Classic)" (CC BY-SA 4.0), in our own words.
	Abilities come from the generated combat-log data; this file adds stages and role alerts.
]]

ns.AmendInstance("ShadowfangKeep", {
	-- The client floors' names in Data/Instances' order (the client's maps 310, 316, 315, 311 and 313).
	-- Data/Authored/ClassicMaps.lua's UseMaps sets the menu over these: the whole keep first, then the floors.
	floorNames = { "The Courtyard", "The Wall Walk", "Arugal's Chamber", "Dining Hall", "Lower Observatory" },
	description = "Baron Silverlaine's keep above Pyrewood fell to Archmage Arugal, who summoned the worgen to "
		.. "fight the Scourge and lost control of them. Now the keep belongs to Arugal and his pack.",

	--[[
		Before you go (the overview), from the quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29,
		step 8 of its plan). The prisoner for each side: Deathstalker Adamant (3849, Horde-friendly) and
		Sorcerer Ashcrombe (3850, Alliance-friendly), both inside the keep in QuestieDB's Forever data;
		that freeing him opened the courtyard door is the original game's, and the note says so. The
		Black Tome: what the City of Dalaran's own note says of it (Data/Authored/CityOfDalaran.lua),
		pointing there for how it is used, as no source read settles where in Dalaran the tome is used.
	]]
	prepare = {
		{
			faction = "Horde",
			title = "The courtyard door",
			text = "Deathstalker Adamant is held prisoner inside the keep. In the original game, freeing him "
				.. "opened the courtyard door, the way on. This is not yet checked on Forever.",
		},
		{
			faction = "Alliance",
			title = "The courtyard door",
			text = "Sorcerer Ashcrombe is held prisoner inside the keep. In the original game, freeing him "
				.. "opened the courtyard door, the way on. This is not yet checked on Forever.",
		},
		{
			title = "The Black Tome",
			text = "After Archmage Arugal dies, take the {item:276561:Black Tome:1} from his table. It leads to the "
				.. "{item:275989:Tome of Dalaran:2}, which summons Lyn the Ignored, a hidden boss in the City of "
				.. "Dalaran. That dungeon's Before you go says how.",
		},
	},

	bosses = {
		["Archmage Arugal"] = {
			notes = {
				"Waits at the top of the keep. When Fenrus the Devourer dies, he appears for a moment to call four Voidwalkers.",
				"Arugal's Curse turns a player into a worgen who attacks their own group.",
			},
			spellFlags = {
				[7588] = { "Interruptible", "Tank" },
				[7803] = { "Healer" },
				[7621] = { "Curse", "Important" },
			},
		},
		["Arugal's Voidwalker"] = {
			notes = { "Four of them come after Fenrus the Devourer dies: Arugal appears for a moment and calls them." },
		},
		["Commander Springvale"] = {
			notes = { "A fallen paladin who heals himself and shields himself from harm." },
			spellFlags = {
				[1026] = { "Interruptible", "Important" },
				[642] = { "Important" },
				[5588] = { "Magic" },
			},
		},
		["Baron Silverlaine"] = {
			spellFlags = { [7068] = { "Magic" } },
		},
		["Fenrus the Devourer"] = {
			spellFlags = { [7125] = { "Poison" } },
		},
		["Deathsworn Captain"] = {
			notes = { "A rare spawn: not every run meets him." },
		},
	},
})
