local _, ns = ...

--[[
	Ruins of Lordaeron, written by hand over the generated data.

	From foreverchanges.pro's Ruins of Lordaeron page and quest pages (2026-10-09), read by hand,
	facts only, in our own words: the level range Blizzard gives, how each fight goes, the boss
	spots (on Santiago Reyes's map, the same picture as ours), where Captain Truman stands, the
	Horde's own Crest of Lordaeron, and where five quests are handed in. Its loot and quests
	already matched ours; the journal's earlier boss spots were off.

	The Crest of Lordaeron lies in one of five places (the owner, 2026-11-17: "The Crest of Lordaeron
	map shows 4 locations, but there are 5"), as the owner's picture marks them on this same map
	(Mausoleum, Tower 3, Tower 2, Crypt, Tower 1) and a player's account, pasted by the owner, tells
	them. Each spot names its place in our own words, in its mark's tooltip. The four the journal had
	(back since the owner's call of 2026-11-06) are four of them, each on the building or tower the
	owner's shield is drawn over; the fifth, Tower 1 (the East tower, at the south-west corner of
	Witherfang's courtyard, on the alley you come in by), is the center of its round tower, as the
	West tower's (Tower 2) is: the two are twins, and the owner's shield over it is centered within
	0.003 of there.
]]

-- Where Captain Truman stands: the owner's spot, in game (2026-11-11; the site's (0.624, 0.285) was well south of him).
local TRUMAN = { x = 0.628, y = 0.178, floor = 1 }
-- The crest's five places, each naming where it hangs or lies (Data/Authored/InsideQuestSpots.lua's name: its mark's
-- tooltip line), the owner's names for them first.
local CREST_SPOTS = {
	-- Mausoleum: the small building in the far north-west corner (the spot drawn on its north side)
	{ x = 0.347, y = 0.207, floor = 1, name = "Mausoleum in the far north-west corner, on the wall" },
	-- Tower 2: the West tower, the center of its round tower
	{ x = 0.376, y = 0.493, floor = 1, name = "West tower, top floor, on the wall left of the doors" },
	-- Tower 3: the north-west tower Bjork walks around, at its foot
	{ x = 0.433, y = 0.290, floor = 1, name = "North-west tower, at the bottom, in front of the split staircase" },
	-- Crypt: the small crypt south-east of the Throne Room, on the alley you come in by
	{ x = 0.566, y = 0.596, floor = 1, name = "Behind the closed crypt doors, on the pitch-black wall" },
	-- Tower 1: the East tower, the center of its round tower (the fifth, 2026-11-17)
	{ x = 0.671, y = 0.495, floor = 1, name = "East tower, top floor, on the wall left of the doors" },
}
local CREST_NOTE = "The crest is not always in the same place: on the floor of a tower near Bjork, or on the wall of the "
	.. "small temple at the far end, past him, among other spots."

ns.AmendInstance("RuinsOfLordaeron", {
	levelMax = 20,

	bosses = {
		["The Baron"] = {
			notes = {
				"He hurls the tank into the air, stunned for 5 seconds: damage dealers, watch your threat, the tank holds him only about half the fight.",
				"Clear his room before the pull: a patrol walks by. His head is looted for Abominable Creatures and Unending Torment.",
			},
			mapPin = { x = 0.588, y = 0.698, floor = 1 },
		},
		["Witherfang"] = {
			notes = {
				"Nothing special on the boss itself: clear the other spiders of the courtyard first, or they join the fight.",
			},
			mapPin = { x = 0.668, y = 0.392, floor = 1 },
		},
		["The Abandoned"] = {
			notes = {
				"Clear the courtyard, click the statue and survive the waves: she comes after them.",
				"Frost Nova hits the whole group: healers, pace your mana through the waves.",
			},
			mapPin = { x = 0.410, y = 0.533, floor = 1 },
		},
		["Bjork"] = {
			notes = {
				"He knocks players back: clear the packs around him first, or you land in one.",
				"Anti-Magic Shield guards him against spells for a while, and he hits hard: keep the tank topped up.",
			},
			mapPin = { x = 0.392, y = 0.425, floor = 1 },
		},
		["Rath'mael"] = {
			notes = {
				"Flamestrike is his main spell, and he can be interrupted and stunned: plan your kicks and stuns.",
				"The longest fight of the dungeon: a large health pool, so keep the interrupts going.",
			},
			mapPin = { x = 0.458, y = 0.627, floor = 1 },
		},
		["Viktor the Vile"] = {
			notes = {
				"Clear the house and the statue, click the fireplace and survive the waves: he comes after the last flesh golem.",
				"He poisons his target and hits hard. Bring mana potions for the waves before him.",
			},
			mapPin = { x = 0.377, y = 0.648, floor = 1 },
		},
		["Lordaeron Captain"] = {
			mapPin = { x = 0.385, y = 0.250, floor = 1 },
		},
	},

	questPatches = {
		[95250] = { startInside = TRUMAN, endInside = TRUMAN, note = "Captain Truman stands just inside the entrance." },
		[95189] = {
			startItem = { itemID = 268579, name = "Crest of Lordaeron", note = "Not always in the same place inside Ruins of Lordaeron." },
			startInside = CREST_SPOTS,
			-- Lady Dena Kennedy, in the Royal Gallery: the owner's reading in game (2026-11-05).
			endMap = { mapID = 1453, x = 0.686, y = 0.282 },
			note = CREST_NOTE,
		},
		[95204] = {
			startItem = { itemID = 275521, name = "Crest of Lordaeron", note = "Not always in the same place inside Ruins of Lordaeron." },
			startInside = CREST_SPOTS,
			endMap = { mapID = 1458, x = 0.734, y = 0.324 },
			note = CREST_NOTE,
		},
		[97288] = {
			endMap = { mapID = 1458, x = 0.484, y = 0.694 },
			note = "Master Apothecary Faranell takes the head, and a second Unending Torment follows: four more steps inside the Undercity, the last back to him.",
		},
	},
})
