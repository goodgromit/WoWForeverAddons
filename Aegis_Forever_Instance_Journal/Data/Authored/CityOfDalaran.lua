local addonName, ns = ...

--[[
	City of Dalaran, one of Forever's new dungeons, written by hand over the generated data.

	Run order, strategy, Lyn the Ignored's abilities and summoning, the way in and the Horde's key
	quests were first written from a published guide to the dungeon (2026-10-09), read by hand and put
	in our own words: facts only, as were its loot's item ids (Dev/build_data.py).

	Checked against foreverchanges.pro's City of Dalaran page (2026-10-09), read by hand, facts only:
	its loot and ability names agree with ours. From it: which effects can be dispelled, how the Fel
	Ancient's barrier comes down, where Lyn is summoned, why the Shade resets, the immunities, the
	Alliance's key quest, what follows Heart of Disruption, and the boss spots on its two floors
	(the sewers and the city, on Santiago Reyes's map, the frame our spots were already in). Its
	"Getting in" section (read again 2026-11-03) backs the way in and both sides' key quests, in the
	order the chains below list them.

	Marked tested at the owner's request (2026-10-19), after trying it with the journal. Recorded
	runs: Skep's two (Recordings/Skep, 2026-10-19 22-34 and 22-41) and the owner's (Recordings/Torchlite,
	2026-11-11, five visits, every boss killed): their rooms set the map's floors below. The Fel Infused
	Blossom that Skep's second run and the owner's credited to the Fel Ancient is a plant on the ground
	near him, not his drop (the owner, 2026-11-11; Data/Authored/SiteLoot.lua).
]]

ns.AmendInstance("CityOfDalaran", {
	description = "Dalaran, the city of the Kirin Tor, stands rebuilt in the Alterac Mountains, its magic barrier "
		.. "gone and its streets overrun. Go in through the sewers, to a portal at the end of a long pipe, then "
		.. "fight up through the streets to the Shade of the Archmage.\n\n"
		.. "Immunities: much of the city takes no Arcane damage. Constructs and elementals ignore bleeds and "
		.. "poisons, and the treants take no Nature damage, though they bleed.\n\n"
		.. "Trash: interrupt the Mana Phantoms' Mana Burn, and stand in the pool a Saturated Remnant leaves behind "
		.. "to regain mana. Every kill gives Kirin Tor reputation.",

	--[[
		Before you go (the overview, for the player's own side): the Dalaran Sewer Key, from Heart of
		Disruption, which the Image of Archmage Modera gives by Lordamere Lake; and Lyn the Ignored,
		the hidden boss, who needs the Tome of Dalaran. The Horde's chain and the tome checked against
		news posts of October 2026 and foreverchanges.pro's quest pages and City of Dalaran page, read
		by hand: facts only. Keeper Bel'varil's Stone Tokens and Bracers of Binding, which a news post
		lists alongside, are not steps of the chain (Blood in the Streets needs only the patrols and the
		Grimy Key; the site's "Getting in" says the Stone Tokens are not needed) and are left out.

		From the quest audit of 2026-10-29 (Dev/docs/audit_2026-10-29, step 8 of its plan): the
		quests before Heart of Disruption need level 30 (QuestieDB's Forever data, and
		foreverchanges.pro's pages for An Alarming Request and Blood in the Streets, 2026-10-30); the
		Arcane Mote (251961) drops from the Shade of the Archmage (QuestieDB; its second dropper there,
		Rath'mael, stands in the Ruins of Lordaeron, a slip). The key is handed over when Heart of
		Disruption is taken (its sourceItemId).
	]]
	prepare = {
		{
			faction = "Alliance",
			title = "The Dalaran Sewer Key",
			text = "Emissary Jacques in Southshore starts An Alarming Request, which leads to the Image of Archmage "
				.. "Modera by Lordamere Lake, outside the city. Her Heart of Disruption gives the "
				.. "{item:277507:Dalaran Sewer Key:2}; one key in the group lets everyone in. You need level 30 to "
				.. "start. Heart of Disruption asks for the {item:251961:Arcane Mote}, which the Shade of the "
				.. "Archmage, the last boss, drops.",
			quests = { 92432, 92458 },
		},
		{
			faction = "Horde",
			title = "The Dalaran Sewer Key",
			text = "Magus Wordeen Voidglare in Tarren Mill gives Prison Break In and Key to the City (the "
				.. "{item:279469:Grimy Key:1}, from the Warden's Footlocker at the Lordamere Internment Camp), then "
				.. "Dalaran Patrols and Blood in the Streets, which leads to the Image of Archmage Modera by Lordamere "
				.. "Lake. Her Heart of Disruption gives the {item:277507:Dalaran Sewer Key:2}; one key in the group "
				.. "lets everyone in. You need level 30 to start. Heart of Disruption asks for the "
				.. "{item:251961:Arcane Mote}, which the Shade of the Archmage, the last boss, drops.",
			quests = { 544, 93680, 545, 92434, 96984 },
		},
		{
			title = "Lyn the Ignored, a hidden boss",
			-- Shown on his own page's Overview too.
			boss = "Lyn the Ignored",
			text = "Bring the {item:275989:Tome of Dalaran:2} to summon him. Take the {item:276561:Black Tome:1} "
				.. "from Archmage Arugal's table in "
				.. "Shadowfang Keep after his kill, and use it beside the Leyline Focus in Ambermill's keep, in "
				.. "Silverpine Forest. In the sewers, past Atrexis, go straight on into the tunnel to the purple rune "
				.. "and use the tome there. It is not used up: it can be used again after 3 minutes.",
		},
	},

	-- Lyn is summoned in the sewers past Atrexis; the Fel Ancient waits behind his barrier until
	-- the city around him is cleared.
	bossOrder = {
		"Atrexis the Grave Knight", "Lyn the Ignored", "Arcane Anomaly", "Arcanic Enigma", "Unstable Sentinel",
		"Mana Devourer", "Fel Ancient", "Shade of the Archmage",
	},

	bosses = {
		["Atrexis the Grave Knight"] = {
			notes = {
				"At the ritual circle in the sewers, with Kirin Tor Necromancers around him.",
				"Raises skeletons through the fight: kill them, and give the tank time to build threat before using area damage.",
				"A test of the tank: he hits hard, disarms, and his Unholy Frenzy speeds his attacks by 75% for 20 seconds. Purge or dispel the frenzy, and tanks should bring a shield.",
			},
			spellFlags = {
				[6713] = { "Tank" },     -- Disarm
				[1303264] = { "Magic" }, -- Unholy Frenzy
			},
			mapPin = { x = 0.609, y = 0.589, floor = 1 },
		},
		["Arcane Anomaly"] = {
			notes = {
				"Focal Blast: after a 3-second cast, a beam sweeps around the room, turning counterclockwise, for 6 seconds. Get out of its path as the cast starts: it kills.",
				"Stay on the platform: small adds wait at the room's edge.",
			},
			mapPin = { x = 0.520, y = 0.834, floor = 2 },
		},
		["Arcanic Enigma"] = {
			notes = {
				"Two Mana Phantoms fight beside him: kill them first, their Mana Burn drains whoever they target.",
				"Manamorph takes a player out of the fight for 8 seconds: dispel it. His Silence hits those close to him, so healers keep their distance.",
				"He keeps calling Arcane Manalings: cleave them down.",
			},
			spellFlags = {
				[1240869] = { "Magic" },  -- Manamorph
				[8988] = { "Healer" },    -- Silence
			},
			mapPin = { x = 0.660, y = 0.498, floor = 2 },
		},
		["Unstable Sentinel"] = {
			notes = {
				"Malfunction winds up for 2 seconds, then hits everyone within 25 yards every 2 seconds for 6 seconds: ranged stay beyond 25 yards, melee step out as the cast starts.",
				"Angry Tomes come out of the buildings as you approach: clear them before the fight.",
			},
			spellFlags = { [1241329] = { "Deadly" } }, -- Malfunction
			mapPin = { x = 0.590, y = 0.408, floor = 2 },
		},
		["Mana Devourer"] = {
			notes = {
				"By the entrance to the Violet Hold. Clear his room first: anything still alive in it joins the fight.",
				"Debilitate drains mana from everyone within 45 yards, and Drain Vitality wears down the tank: dispel it. A race before your mana runs out. He is immune to arcane.",
			},
			spellFlags = {
				[1240750] = { "Healer" }, -- Debilitate
				[1240738] = { "Magic" },  -- Drain Vitality
			},
			mapPin = { x = 0.435, y = 0.720, floor = 2 },
		},
		["Fel Ancient"] = {
			notes = {
				"He waits behind a barrier in the middle of the city. Kill the Suffused Treants in front of it, then speak to Magus Fansy Goodbringer, just south of the barrier, to bring it down.",
				"Entangle roots up to two players near him and hurts them: dispel it. Fel Timbers leaves poisonous pools: anyone rooted in one needs Blessing of Freedom or Escape Artist.",
			},
			spellFlags = {
				[1240688] = { "Important", "Magic" }, -- Entangle
			},
			mapPin = { x = 0.535, y = 0.550, floor = 2 },
		},
		["Lyn the Ignored"] = {
			notes = {
				"Past Atrexis, clear the north-east room with the market stalls and the small pink summoning circle. Whoever carries the tome clicks the circle, and Lyn comes out of the big round grate.",
				"Shadow Bolt Volley and Curse of Thorns together hurt: remove the curse, melee above all. He raises skeletons as Atrexis does.",
			},
			mapPin = { x = 0.690, y = 0.166, floor = 1 },
			-- His abilities: Data/Authored/Abilities.lua.
		},
		["Shade of the Archmage"] = {
			notes = {
				"The last boss: Archmage Modera opens the Portal to the Violet Chamber, which leads to him.",
				"Bounding Mana flies to a player and back, silencing anyone it passes through: don't stand between him and its target. Casters stay 20 yards away from his Arcane Explosion.",
				"When his mana runs dry he turns the whole group into animals for 8 seconds, then channels Evocation to refill it. Casters can hide behind the wall from the polymorph, but if anyone leaves the room he resets to full health.",
			},
			mapPin = { x = 0.567, y = 0.258, floor = 2 },
		},
	},

	-- The Dalaran Sewer Key: each side's way to the Image of Archmage Modera, and what follows.
	questPatches = {
		[92458] = {
			prerequisites = { { questID = 92432, name = "An Alarming Request" } },
			note = "Emissary Jacques in Southshore starts it with An Alarming Request. It gives the Dalaran Sewer Key, "
				.. "and Friend of the Kirin Tor follows, taking the mote to Archmage Celindra in the Violet Citadel. "
				.. "The mote drops from the Shade of the Archmage, the last boss.",
		},
		[96984] = {
			-- Key to the City first: Dev/build_quest_steps.py takes a new quest's steps from what comes
			-- before it in this list (QuestieDB has no links between Forever's new quests), and Key to the
			-- City and Prison Break In are open side by side from the start (step 18b of the 2026-10-29
			-- audit). Prison Break In, a Classic quest, takes its own (none) from QuestieDB.
			prerequisites = {
				{ questID = 93680, name = "Key to the City" },
				{ questID = 544, name = "Prison Break In" },
				{ questID = 545, name = "Dalaran Patrols" },
				{ questID = 92434, name = "Blood in the Streets" },
			},
			-- The Image of Archmage Modera gives it (QuestieDB, the site); Voidglare starts the chain (the
			-- deep audit of 2026-10-30, g09-8).
			note = "Magus Wordeen Voidglare in Tarren Mill starts the chain with Prison Break In and Key to the City. "
				.. "At the Lordamere Internment Camp, kill four traitors for their artifacts (they take 5 to 10 "
				.. "minutes to come back) and take the Grimy Key from the Warden's Footlocker, upstairs in the "
				.. "two-storey building. Blood in the Streets then leads through the north sewers to the Image of Archmage Modera. It gives the Dalaran Sewer Key, and "
				.. "Shrewd Negotiations follows, to Archmage Celindra. The mote drops from the Shade of the Archmage, "
				.. "the last boss.",
		},
		[96988] = {
			note = "Cracked Sentry Cores drop from the Fragmented Sentries, one per sentry and one player each. A run "
				.. "has 12 to 15 of them, so a full group needs two or three runs.",
		},
		[96987] = {
			note = "The Founding of Dalaran is on the back wall, past the portal room.",
		},
	},

	--[[
		What follows Heart of Disruption on each side, from the quest audit of 2026-10-29 (step 8):
		Friend of the Kirin Tor (92459) and Shrewd Negotiations (97287), from QuestieDB's Forever data
		(givers, Archmage Celindra, levels, the Arcane Mote each hands you, its sourceItemId; Kirin Tor
		+10 on 92459, its reputationReward) and foreverchanges.pro's quest pages (2026-10-30), whose
		chains put each after its side's Heart of Disruption. Both are Forever's own, new there, and
		are turned in inside the dungeon, so they are listed: QuestieDB puts the dungeon's own NPCs
		(Lyn, the Fel Ancient, the Mana Devourers) on the Alterac Mountains map (1416), and Celindra's
		spot there (14.27, 60.07) is beside the Archmage Modera who opens the portal to the last boss,
		as fc's "within the Violet Citadel" says. So the endMap pin on 1416 marks the dungeon's spot,
		not an NPC outdoors. Each quest hands over its own mote (sourceItemId); Heart of Disruption
		takes the one the last boss drops. Their XP is left out: the site's quest pages have no
		Rewards section and its list page does not give theirs (the audit's XP pass, 2026-10-30).

		Each lists its side's whole chain, so its row on the Quests tab shows every step, as the
		site's "Getting in" orders them (the deep audit of 2026-10-30, g09-7). The locks are the same as
		before: each step needs the ones before it.
	]]
	addQuests = {
		{
			questID = 92459, name = "Friend of the Kirin Tor", level = 33, requiredLevel = 24, faction = "Alliance",
			pickup = "Image of Archmage Modera, Lordamere Lake near Dalaran",
			turnin = "Archmage Celindra, City of Dalaran",
			startMap = { mapID = 1421, x = 0.686, y = 0.452, label = "Image of Archmage Modera — Lordamere Lake near Dalaran" },
			endMap = { mapID = 1416, x = 0.1427, y = 0.6007, label = "Archmage Celindra — City of Dalaran" },
			objective = "Speak to Archmage Celindra in the City of Dalaran.",
			note = "The quest hands you the Arcane Mote to take to her.",
			prerequisites = {
				{ questID = 92432, name = "An Alarming Request" },
				{ questID = 92458, name = "Heart of Disruption" },
			},
			rewards = { reputation = { { faction = "Kirin Tor", amount = 10 } } },
		},
		{
			questID = 97287, name = "Shrewd Negotiations", level = 33, requiredLevel = 24, faction = "Horde",
			pickup = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
			turnin = "Archmage Celindra, City of Dalaran",
			startMap = { mapID = 1424, x = 0.616, y = 0.2085, label = "Magus Wordeen Voidglare — Tarren Mill" },
			endMap = { mapID = 1416, x = 0.1427, y = 0.6007, label = "Archmage Celindra — City of Dalaran" },
			objective = "Speak with Archmage Celindra in the City of Dalaran.",
			note = "The quest hands you the Arcane Mote to take to her.",
			prerequisites = {
				{ questID = 93680, name = "Key to the City" },
				{ questID = 544, name = "Prison Break In" },
				{ questID = 545, name = "Dalaran Patrols" },
				{ questID = 92434, name = "Blood in the Streets" },
				{ questID = 96984, name = "Heart of Disruption" },
			},
		},
	},
})

--[[
	The map: Santiago Reyes's City of Dalaran (Atlas de Azeroth: Forever), used with his permission
	(2026-10-09), its two floors as foreverchanges.pro shows them, converted to Media/Maps like
	his other maps. The boss spots above and the way up from the sewers are on it.
]]
local city = ns.GetInstance("CityOfDalaran")
if city and city.map then
	local folder = "Interface\\AddOns\\" .. addonName .. "\\Media\\Maps\\"
	-- Each floor's rooms, by the names the client gives them inside (GetSubZoneText): the map opens on
	-- the floor the player is on and turns with them while it is open (UI/DungeonMap.lua, follow.Floor).
	-- Read on Skep's runs (2026-10-19) and the owner's (2026-11-11: "The Underbelly", then "Dalaran" on
	-- the way up out of the sewers); the bosses killed in each room are on that floor. "City of
	-- Dalaran", the dungeon's own name, is also one city room's (the city building's own names): every
	-- run read it just after climbing out into Dalaran, so it is the city's. The Eventide and Presage
	-- Plaza were read on the owner's run only. roomsOnly: where no room is named the minimap's name
	-- (the zone's, "City of Dalaran") is not read, as it could be at the sewers' way in; a spot like
	-- that keeps the floor last followed, else the map opens on the sewers, the way in.
	city.map.roomsOnly = true
	city.map.floors = {
		{
			art = folder .. "CityOfDalaranSewers", artBottom = 683 / 1024,
			areas = { ["Sewer"] = true, ["The Underbelly"] = true, ["Cantrips & Crows"] = true },
		},
		{
			art = folder .. "CityOfDalaranCity", artBottom = 683 / 1024,
			areas = {
				["Dalaran"] = true, ["The Violet Hold"] = true, ["Runeweaver Square"] = true,
				["Magus Commerce Exchange"] = true, ["Path of Renewal"] = true, ["The Violet Citadel"] = true,
				["The Purple Parlor"] = true, ["City of Dalaran"] = true, ["The Eventide"] = true,
				["Presage Plaza"] = true,
			},
		},
	}
	city.floorNames = { "The Sewers", "The City" }
	city.map.entrance = { x = 0.186, y = 0.840, floor = 1 }
end
