local _, ns = ...

-- Blizzard's own global strings are used where they exist, so the client's language
-- carries through on the words the retail journal shares with the rest of the UI.
local L = {}
ns.L = L

--[[
	The language the journal speaks: the client's, or the one /aegis lang previews (saved as
	AegisJournalDB.previewLocale, which the client reads before these files: the TOC's
	LoadSavedVariablesFirst). Each translation asks before it lays itself over this table.
]]
local preview = type(AegisJournalDB) == "table" and type(AegisJournalDB.previewLocale) == "string"
	and AegisJournalDB.previewLocale or nil
ns.previewLocale = preview

function ns.Speaks(locale)
	if preview then return preview == locale end
	return GetLocale() == locale
end

--[[
	What a translation holds to match the client's own text (an item's Equip: lines, the room the
	player stands in, a boss or a faction the client names) is the client's language's, previewed
	or not: it goes to ns.ClientL. ns.LocaleTargets gives a translation the table its words go to,
	ns.L where the journal speaks its language (where only the client does, a table thrown away
	once the language's two files have read it: Russian's faction names are in its interface
	file), and ns.ClientL where the client speaks it; nothing where neither does.
]]
ns.ClientL = {}
local unspoken
function ns.LocaleTargets(locale)
	local speaks, client = ns.Speaks(locale), GetLocale() == locale
	if not (speaks or client) then return nil end
	if not speaks then unspoken = unspoken or setmetatable({}, { __index = L }) end
	return speaks and L or unspoken, client and ns.ClientL or nil
end
-- Once every translation has loaded and been read (Core/Registry.lua's ns.KeepClientNames).
function ns.ForgetUnspokenWords()
	unspoken = nil
end

L.JOURNAL_TITLE = "Instance Journal"
L.HOME = HOME or "Home"
L.TAB_DUNGEONS = DUNGEONS or "Dungeons"
L.TAB_RAIDS = RAIDS or "Raids"
L.TAB_REPUTATION = REPUTATION or "Reputation"

L.BINDING_TOGGLE = "Toggle Instance Journal"
L.KEY_CLAIMED = "Shift+J now opens the Instance Journal."
L.KEY_TAKEN = "Shift+J is already bound to %s. Choose a key under Key Bindings > AddOns > Toggle Instance Journal."
L.POSITION_RESET = "Window position reset."
-- /aegis dock (Core/Init.lua; UI/Journal.lua's docking).
L.DOCK_ON = "The window now opens at the top left, beside the game's own windows. Drag it to move it until it closes."
L.DOCK_OFF = "The window is free again: it opens where you last dragged it."
L.DOCK_AFTER_COMBAT = "That takes effect when combat ends."
L.SLASH_HELP = "/aegis (or /ij) opens the journal. /aegis record starts or stops recording. /aegis reset moves the window back to its default place. /aegis dock docks the window at the top left, beside the game's windows, or frees it again. /aegis perf measures the journal's memory and speed. /aegis where and /aegis taxi report where you stand and the flight points on your map. /aegis travel saves a boat, zeppelin, tram or portal for the world map. /aegis items finds the listed items the server knows nothing of. /aegis gear opens the Gear Finder, /aegis weights its stat weights; /aegis gearscan saves what it reads from your gear, for checking its scoring. /aegis options opens the journal's options. /aegis style shows the journal's style question again. /aegis lang previews the journal in another of its languages. /aegis run shows or hides the dungeon run block (outside a dungeon, your last run); /aegis run new starts a new run. /aegis test opens test mode."
-- /aegis lang (Core/Init.lua)
L.LANG_USAGE = "/aegis lang de, fr, ru, cn, tw, es, mx, pt or ko shows the journal in German, French, Russian, Chinese (Simplified or Traditional), Spanish (Spain or Latin America), Brazilian Portuguese or Korean from your next /reload, to check a translation; /aegis lang off goes back to your client's language. Now: %s."
L.LANG_SET = "From your next /reload the journal speaks %s: only its own words, as the game's own names stay your client's. Type /reload now; /aegis lang off goes back."
L.LANG_OFF = "From your next /reload the journal speaks your client's language again. Type /reload now."
L.LANG_FONTS = "Chinese needs a Chinese client's fonts: on yours some of its letters may not show."
L.LANG_FONTS_KO = "Korean needs a Korean client's fonts: on yours some of its letters may not show."
L.LANG_ON = "Previewing the journal in %s. /aegis lang off ends it."
L.LANG_UNAVAILABLE = "This client read the journal before its saved settings, so the language preview could not start."
-- A map addon the owner asked us to warn about, while it is loaded: its name twice (Core/Init.lua NoteMapAddon), 2026-11-12.
L.MAP_ADDON_HIDES = "%s is turned on. It covers the world map, so some of the journal's maps and features may be hidden. We recommend turning %s off."
L.ITEMS_START = "Asking the server about the %d items the journal lists. The answer comes in about %d seconds; carry on as you like."
L.ITEMS_SCANNING = "Still asking the server; the answer comes in a moment."
L.ITEMS_DONE = "Of %d items, the server knows nothing of %d: most likely they are not in Forever yet. The journal hides them until the server or a recorded run confirms them. The full list goes in the saved file at your next /reload or logout."
L.ITEMS_LINE = "  Item %d: %s"
L.ITEMS_MORE = "  ...and %d more."
L.PERF_HEADER = "Performance (memory in KB, times in milliseconds; lower is better):"
L.PERF_MEMORY = "  %s: %.0f KB"
L.PERF_TIME = "  %s: %.2f ms"
L.PERF_BUILD = "First open (building the window)"
L.PERF_BOOK = "First dungeon opened (building the book)"
L.PERF_OPEN = "Open and close the journal"
L.PERF_DUNGEON = "Open a dungeon's page"
L.PERF_TAB = "Switch to the %s tab"
L.PERF_FACTION = "Open a faction's page"
L.PERF_LOOT = "Redraw a loot page"
L.PERF_COMBAT = "Measuring waits until you are out of combat."
L.WHERE = "Map %s (%s)  x %.4f  y %.4f  area \"%s\"  minimap \"%s\"  height %s"
L.WHERE_BELOW = "%s: remembered %s"
L.WHERE_BELOW_BELOW = "below"
L.WHERE_BELOW_TOP = "top"
L.WHERE_BELOW_NOTHING = "nothing"
L.WHERE_BELOW_CHANGE = "  %s  %s  map %s  area \"%s\"  x %s  y %s:  %s -> %s"
-- /aegis where's last line with the Gamepad UI on (Core/Compat.lua's ns.Gamepad:Readout): how often the journal
-- handed the pad back as a fight started and the game's event that did the last (its own name, untranslated), how
-- often the game refused already, the game's combat restriction events heard, the menu arrows' skip marks waiting.
L.WHERE_GAMEPAD = "Gamepad UI: pad handed back as a fight started: %d (the last on %s); too late: %d; combat restriction events heard: %d; skip marks waiting: %d"
L.WHERE_FLOOR = "%s: map on floor %d (%s), by the area \"%s\""
L.WHERE_FLOOR_KEPT = "%s: map on floor %d (%s), kept: the area \"%s\" is on no floor"
L.WHERE_FLOOR_HELD = "%s: map on floor %d (%s), not following the area \"%s\": a floor picked, or the whole map"
L.TAXI = "Map %s  shows flight points itself: %s  flight points on it: %d (%d discovered)  %s"
L.TAXI_ATLASES = "Travel icons: %s"
L.YES = YES or "yes"
L.NO = NO or "no"

L.EMPTY_DUNGEONS = "No dungeons have journal entries yet."
L.EMPTY_RAIDS = "No raids have journal entries yet."
L.EMPTY_REPUTATION = "No faction rewards are known yet."
L.EMPTY_BRACKET = "Nothing in this level range."

L.TAB_RECORD = "Record"
L.TAB_GEAR = "Gear Finder"

-- The Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua, UI/CharacterTab.lua).
L.GEAR_TITLE = "Gear Finder"
L.GEAR_PREVIEW = "Preview"
L.GEAR_NO_UPGRADE = "No upgrade found"
L.GEAR_LOOKING = "Looking in %d dungeons."
L.GEAR_LOOKING_ONE = "Looking in 1 dungeon."
L.GEAR_LOADING = "%d items still loading."
L.GEAR_LOADING_ONE = "1 item still loading."
L.GEAR_SCORING = "Scoring for"
L.GEAR_AUTO = "Automatic: %s"
L.GEAR_WHY_TALENTS = "%s (talents)"
L.GEAR_WHY_LEVELLING = "%s (levelling)"
L.GEAR_SUGGESTED = "Suggested dungeon"
L.GEAR_UPGRADES_HERE = "%d upgrades here"
L.GEAR_UPGRADE_HERE = "1 upgrade here"
L.GEAR_MORE_SLOTS = "and %d more"
L.GEAR_DUNGEON_OF = "%d of %d"
L.GEAR_NONE = "No upgrades in the dungeons near your level."
L.GEAR_TIP_CLICK = "Click for its loot; shift-click to link it."
L.GEAR_TIP_CELL_CLICK = "Click for the top upgrades; right-click for its loot."
L.GEAR_TIP_PICK_CLICK = "Click to show it here; right-click for its loot."
L.GEAR_TIP_PICKED = "Your pick for this slot."
L.GEAR_PICK_TOP = "The top %d of %d upgrades"
L.GEAR_PICK_ALL = "%d upgrades"
L.GEAR_PICK_ONE = "The only upgrade"
L.GEAR_PICK_BIGGEST = "Biggest"
L.GEAR_PICK_YOURS = "Your pick"
L.GEAR_PICK_KEPT = "Picks are kept for this character."
L.GEAR_PICK_CLEAR = "Clear my pick"
L.GEAR_TIP_NONE = "No upgrade for this slot in the dungeons near your level."
L.GEAR_CHAR_BUTTON = "Gear Finder"
L.GEAR_CHAR_BUTTON_TIP = "Your stat weights, and the best upgrades waiting for you in the journal's dungeons."
L.GEAR_SCAN_DONE = "Gear scan saved: %d worn items and %d dungeon drops. Log out or /reload to write it to the saved file."
L.GEAR_SCAN_ERRORS = "%d items could not be read; what went wrong is saved with the scan."
L.GEAR_SCAN_LOADING = "Some drops are still loading: wait a few seconds and type /aegis gearscan again for more."
L.GEAR_SLOT_FINGER1 = "Finger 1"
L.GEAR_SLOT_FINGER2 = "Finger 2"
L.GEAR_SLOT_TRINKET1 = "Trinket 1"
L.GEAR_SLOT_TRINKET2 = "Trinket 2"

-- Stat weights (Core/ItemScore.lua, UI/WeightsEditor.lua).
L.WEIGHTS_TITLE = "Stat Weights"
L.WEIGHTS_EDIT = "Edit stat weights..."
L.WEIGHTS_SOURCE_DEFAULT = "The journal's weights"
L.WEIGHTS_SOURCE_LEVELLING = "The journal's weights, while levelling"
L.WEIGHTS_SOURCE_CUSTOM = "Your own weights"
L.WEIGHTS_SOURCE_PAWN = "Your weights, from Pawn: %s"
L.WEIGHTS_TIP = "How much one point of each stat is worth to this spec. Click a weight to change it; your own weights show in green and are kept for this character."
L.WEIGHTS_RESET = "Reset"
L.WEIGHTS_RESET_TIP = "Back to the journal's weights for this spec."
L.WEIGHTS_PAWN = "Pawn..."
-- The Pawn... button's tooltip names WoWSims' Pawn export (2026-11-03).
L.WEIGHTS_PAWN_TIP = "Bring in a scale from Pawn, or paste a Pawn export from WoWSims."
L.WEIGHTS_PAWN_HELP = "In Pawn, pick the scale, choose Export, copy the text, and paste it here."
L.WEIGHTS_IMPORT = "Import"
L.WEIGHTS_CANCEL = "Cancel"
L.WEIGHTS_BACK = "Back"
L.WEIGHTS_OPEN_FINDER = "Open the Gear Finder"
L.WEIGHTS_IMPORTED = "Imported %d weights from %s."
L.WEIGHTS_UNUSED = "Not used: %s."
L.WEIGHTS_NOT_PAWN = "That isn't a Pawn scale. In Pawn, choose Export and copy all of its text."
L.WEIGHTS_OTHER_CLASS = "That scale is for a %s, not for this character's class."
L.WEIGHTS_FOR = "For"
-- WoWSims' weights, the Gear Finder's defaults for the specs the sim has, and its Pawn export (2026-11-03).
L.WEIGHTS_SOURCE_SIMS = "WoWSims' weights: %s"
L.WEIGHTS_PAWN_SIMS = "A Pawn export from WoWSims (wowsims.com/forever) works too, with or without Pawn, and scores as the journal's WoWSims weights do. It has no weights for healing, school damage, spell penetration, feral attack power, defense, block or resistances."
L.WEIGHTS_NO_STATS = "That Pawn scale has no stat weights the journal can use."
-- /aegis areas: the client's id for each of the journal's area names (Core/Areas.lua).
L.AREAS_START = "Looking up the client's ids for the journal's %d area names..."
L.AREAS_DONE = "Found the ids of %d of the %d area names. /reload to save them."
L.AREAS_MISSING = "Not found: %s."
L.AREAS_SCANNING = "Still looking up the area names."
L.AREAS_ENGLISH = "Run /aegis areas on an English client: the names it looks for are English."
-- Test mode (UI/TestPanel.lua, UI/TestRun.lua, UI/FogTest.lua): the owner's fog test of 2026-11-13, made test
-- mode on 2026-11-18, for this session only. Next, All and Reset are the game's own words.
L.FOGTEST_FOG_OFF = "The fog is off on this character, so only the pins change. To see it, turn on Fog of War in the map's legend, or use Adventure Mode."
L.FOGTEST_NEXT = NEXT or "Next"
L.FOGTEST_ALL = ALL or "All"
L.FOGTEST_RESET = RESET or "Reset"
L.FOGTEST_PIN_CLICK = "Test mode: click to mark defeated, or standing again."
L.TEST_TITLE = "Test mode"
L.TEST_PICK = "Pick a dungeon"
L.TEST_NO_MAP = "This one has no map yet."
L.TEST_INSIDE = "Pretend I'm inside"
L.TEST_INSIDE_TIP = "The run block shows this dungeon as it would when you walk in: no kills, the clock waiting for the first pull (Play starts it). Kills you mark count on it as real kills would. Nothing of it is saved."
L.TEST_INSIDE_RAID = "The run block is for dungeons, not raids."
L.TEST_INSIDE_REAL = "You're inside %s: the run block shows your real run."
L.TEST_TRACKER_COMBAT = "Wait until the fight is over: the run block is inside the quest tracker."
L.TEST_WALK_IN = "Walk in"
L.TEST_WALK_IN_TIP = "Scarlet Monastery's run waits at the door until a wing's first room or fight names the wing. Walk in names it: %s."
L.TEST_FOUND = "Show as found (Adventure Mode)"
L.TEST_FOUND_TIP = "Ticked: the journal treats this dungeon as found, as if you had walked in. Its bosses, loot and quests still show only as you find them, or as a test kill unlocks them. Unticked: as your character found it. A test kill finds it too."
L.TEST_FOUND_OFF = "Your character isn't in Adventure Mode, so everything shows already."
L.TEST_FOUND_REAL = "Your character has found it."
L.TEST_BOSSES = "Bosses"
L.TEST_DEFEATED = "%d of %d defeated"
L.TEST_TAG_RARE = "rare"
L.TEST_TAG_SUMMONED = "summoned"
L.TEST_TAG_NOT_COUNTED = "not counted"
L.TEST_TAG_MAYBE = "maybe"
L.TEST_TAG_QUEST = "quest"
L.TEST_TAG_OUTSIDE = "outside"
L.TEST_TAG_FINAL = "final"
L.TEST_TIP_RARE = "Rare: no circle or line on the run block, and he holds back no fog."
L.TEST_TIP_SUMMONED = "Summoned: he holds back no fog."
L.TEST_TIP_NOT_COUNTED = "Not counted: a line on the run block once killed, no circle."
L.TEST_TIP_MAYBE = "Maybe: only some runs meet him. A line on the run block once killed, no circle."
L.TEST_TIP_QUEST = "Quest: a quest's target. A line on the run block once killed, no circle. Outside the test, his pin opens his quest."
L.TEST_TIP_OUTSIDE = "Outside: he stands outside the dungeon, so the run block never shows him."
L.TEST_TIP_FINAL = "Final: his kill stops the run's clock."
L.TEST_END = "End test"
L.TEST_ON = "Test mode on, for this session only: nothing is saved. End test or a /reload turns it off."
L.TEST_OFF = "Test mode off: everything is as it was."
L.TEST_RUN_TITLE = "%s (test)"
L.TEST_RUN_ENDED = "You went into a dungeon, so the test's pretend run ended."
L.TEST_STATE_INSIDE = "inside"
L.TEST_STATE_DOOR = "at the door (which wing?)"
L.TEST_STATE_OUTSIDE = "outside"
L.TEST_STATE_DEFEATED = "%d/%d defeated"
L.TEST_STATE_FOG_ON = "fog on"
L.TEST_STATE_FOG_OFF = "fog off"
L.TEST_STATE_NO_FOG = "no fog"
L.TEST_STATE_FOUND = "shown as found"
L.TEST_STATE_REAL = "as your character"
L.TEST_STATE_KILL_FOUND = "found by a test kill"
L.TEST_STATE_REAL_INSIDE = "really inside"
L.TEST_STATE_NOT_ADVENTURE = "not in Adventure Mode"
L.TEST_STATE_COMBAT = "in combat"
L.TEST_USAGE = "/ij test opens test mode. /ij test off ends it. /ij test debug prints what it is doing."
-- The journal's page in the game's options (Options > AddOns).
L.OPTIONS_TITLE = "Aegis Instance Journal"
L.OPTIONS_BOSS_LEVELS = "Show boss levels on the boss list"
L.OPTIONS_BOSS_LEVELS_TIP = "A badge on each boss's portrait with its level, colored by how hard the boss is for you: gray, green, yellow, orange or red."
L.OPTIONS_ARROWS = "Mark upgrades with a green arrow"
L.OPTIONS_MINIMAP = "Show the minimap button"
L.OPTIONS_PAWN_WEIGHTS = "Use Pawn's stat weights"
L.OPTIONS_PAWN_WEIGHTS_TIP = "With Pawn installed, its item tooltips and upgrade arrows are the ones shown. Ticked: the Gear Finder scores items with your Pawn scale for your spec. Unticked: Pawn shows the journal's weights for your spec instead, as a scale of the journal's, and its own scales are hidden on this character until you tick this."
-- Asked once, when Pawn is installed too (Core/PawnLink.lua).
L.PAWN_ASK = "Pawn is installed too. Its item tooltips and upgrade arrows will be shown.\n\nWhose stat weights should Pawn and the Gear Finder both use?\n\nThe journal's: Pawn shows them for your spec, and hides its own scales on this character.\nPawn's: the Gear Finder uses your Pawn scales."
L.PAWN_USE_PAWN = "Pawn's"
L.PAWN_USE_JOURNAL = "The journal's"
-- The journal's scale for a spec, as Pawn lists it.
L.PAWN_SCALE = "Journal: %s"
-- After the journal's scales in Pawn change, where Baganator draws Pawn's arrows.
L.PAWN_RELOAD = "Pawn's upgrade arrows in your Baganator bags change only after a reload: Baganator keeps Pawn's answers until your gear changes.\n\nReload now?"
L.PAWN_RELOAD_NOW = "Reload"
L.PAWN_RELOAD_LATER = "Later"
L.WEIGHTS_SOURCE_PAWN_LIVE = "Pawn's %s scale. Change it in Pawn, or choose the journal's in its options."
L.OPTIONS_MINIMAP_TIP = "The journal's button on the edge of the minimap: click it to open the journal, right-click it for these options, drag it to move it."
-- The journal's line in the minimap's addon menu, its box beside the minimap button's (UI/Options.lua; 2026-11-20).
L.OPTIONS_ADDON_MENU = "Show in the addon menu"
L.OPTIONS_ADDON_MENU_TIP = "The journal's line in the minimap's addon menu, the small button with a number: click it to open the journal, right-click it for these options. Unticked, it leaves the menu after a /reload."
L.OPTIONS_DOCK = "Dock the window at the top left"
L.OPTIONS_DOCK_TIP = "Ticked: the journal opens at the top left of the screen, where the game opens its own windows, and moves aside when one of them opens there, as they do for each other; where there isn't room for both, the game closes the older one. Drag it to move it anywhere: it docks again the next time it opens. Unticked: it opens where you last dragged it."
-- Test mode's button, last on the options' page (UI/Options.lua; 2026-11-18).
L.OPTIONS_TEST = "Test mode"
L.OPTIONS_TEST_BUTTON = "Open"
L.OPTIONS_TEST_TIP = "See any dungeon's map, fog and run block without going in: pick a dungeon, mark bosses defeated, pretend you're inside. For this session only: nothing is saved, and a /reload ends it."
L.OPTIONS_DUNGEON_FOG = "Fog of war on dungeon maps"
L.OPTIONS_DUNGEON_FOG_TIP = "Dungeon maps start under fog, with only the way in clear. Each boss your group defeats clears its rooms and the way back, and the last one clears the whole map; what is cleared stays clear. Always on in Adventure Mode. For this character only."
-- Adventure Mode's news (UI/News.lua): its line in the chat for what the character has just found (%s: the
-- names in brackets, each a link to its page where it has one, joined with QUEST_LIST_COMMA, with AND_MORE
-- past five); the minimap button's tooltip line while it glows for finds not seen yet; and the two boxes in the
-- options with their tips, each for the whole account and greyed outside Adventure Mode.
L.ADVENTURE_NEWS = "New in your journal: %s"
L.MINIMAP_NEWS = "Something new is in your journal."
L.OPTIONS_ADVENTURE_CHAT = "New finds in chat"
L.OPTIONS_ADVENTURE_CHAT_TIP = "In Adventure Mode, a line in the chat when you find something new for the journal: a dungeon, a boss, loot, a quest, a faction or a flight path. Click a name to open its page (a flight path has none). For all your characters."
L.OPTIONS_ADVENTURE_GLOW = "Minimap glow for new finds"
L.OPTIONS_ADVENTURE_GLOW_TIP = "In Adventure Mode, the minimap button glows when you have found something new since you last opened the journal, until you open it. For all your characters."
-- The minimap button's tooltip.
L.MINIMAP_LEFT_CLICK = "Click to open or close the journal."
L.MINIMAP_RIGHT_CLICK = "Right-click for its options."
L.MINIMAP_DRAG = "Drag to move it around the minimap."
L.OPTIONS_ARROWS_TIP = "A green arrow on items that are upgrades for your spec, as the Gear Finder counts them: in your bags, in the loot window and on loot rolls."
L.WEIGHTS_SHOW_GAINS = "Show stat weights in tooltips"
L.WEIGHTS_SHOW_GAINS_TIP = "Under every item, a line for each of your specs: what the item is worth by its weights, and a green arrow with what it adds to your gear when it is an upgrade. For all your characters with the Gear Finder on. With Pawn installed, this shows or hides the journal's scale in Pawn instead, and with it Pawn's upgrade arrows for the journal's weights: Pawn marks upgrades only for the scales it shows."
L.OPTIONS_SOURCES = "Show item sources in tooltips"
L.OPTIONS_SOURCES_TIP = "Under every item that drops in the journal's dungeons and raids, a line naming the boss and the dungeon: in your bags, on your character, in chat links, at merchants and wherever else the game shows the item. For all your characters."
-- The journal's style (Core/Style.lua): its question at each character's first login (UI/StylePopup.lua), each
-- choice's name and what it does, its lines under "Starting Settings:", and the choice and boxes in the options.
L.STYLE_TITLE = "Choose your journal"
L.STYLE_SUBTITLE = "How much should the journal add to your game? You can change this any time in the journal's options."
L.STYLE_CLASSIC = "Classic"
L.STYLE_CLASSIC_DESC = "A more original-style journal, with fewer extras. The bosses, loot, quests and dungeon maps are all still there."
L.STYLE_MODERN = "Modern"
L.STYLE_MODERN_DESC = "Everything the journal has, as it is now: the Gear Finder, maps of the way in, and its marks on the world map."
L.STYLE_CUSTOM = "Custom"
L.STYLE_CUSTOM_DESC = "You choose. Pick this to open the journal's settings, where each feature has its own box to tick."
-- Adventure Mode, in the options' list of styles, chat and tooltips (its box in the question's row has the short
-- name below), and what it does there and on that box: the journal fills in as you play.
L.STYLE_ADVENTURE = "Adventure Mode"
L.STYLE_ADVENTURE_DESC = "The journal starts empty and fills in as you play: dungeons, bosses, loot and quests appear once you find them."
-- Adventure Mode's name on its box in the question at login, one word like Classic and Modern.
L.STYLE_ADVENTURE_BOX = "Adventure"
-- Adventure Mode's pages: an unmet boss's line in place of its description, why the Abilities and Model tabs
-- are closed, the loot list with nothing seen yet, and a row's line for an item seen with its boss unknown
-- ("???", an unmet boss's name, is the same in every language).
L.ADVENTURE_BOSS_UNMET = "You haven't met this one yet."
L.ADVENTURE_ABILITIES_CLOSED = "Fight this boss to learn its abilities."
L.ADVENTURE_MODEL_CLOSED = "Meet this boss to see it here."
L.ADVENTURE_LOOT_NONE = "Nothing has been seen to drop here yet."
L.ADVENTURE_LOOT_IN_DUNGEON = "Drops in %s"
-- Adventure Mode's Quests tab: a chain's step not offered yet, chosen ("???" is its name), and a dungeon
-- whose quests none are found yet. The Reputation tab: no faction met yet; on a faction's page, the note on
-- rewards not seen yet (where they are seen, with the quartermaster's name where the journal has it: "A"
-- or "A or B"), and its rewards list with none seen yet.
L.ADVENTURE_QUEST_UNKNOWN = "You haven't been offered this quest yet."
L.ADVENTURE_QUESTS_NONE = "No quests for this dungeon have been found yet."
L.ADVENTURE_REP_NONE = "You haven't met any of these factions yet."
L.ADVENTURE_REP_TITLE = "Rewards to find"
L.ADVENTURE_REP_SEEN = "Its rewards show here once you see them at its quartermaster."
L.ADVENTURE_REP_SEEN_AT = "Its rewards show here once you see them at its quartermaster, %s."
L.ADVENTURE_REP_NONE_SEEN = "None of its rewards have been seen yet."
-- Adventure Mode's world-map doors (UI/DungeonMap.lua, Core/Discovery.lua): a dungeon or raid not entered yet
-- is a rumour, never named. Its tooltip's title; its line of rumour in the language's quotation marks (%s: the
-- line); the line where none is written; its name where one must stand (a shared door's lines and menu, a
-- waypoint); two of one kind behind one door numbered (%s: that name, %d: 1, 2...); its entry in a shared
-- door's menu (%s: that name, %s: its level range); where its way in is, unnamed (a cave, a building); the
-- waypoint set to it; a cave's line for the rumours it leads to; the click line of a way in that leads to
-- rumours alone, unnamed.
L.ADVENTURE_DOOR_TITLE = "A rumor"
L.ADVENTURE_DOOR_LINE = "“%s”"
L.ADVENTURE_DOOR_UNKNOWN = "Little is known of this place yet."
L.ADVENTURE_DOOR_DUNGEON = "Rumored dungeon"
L.ADVENTURE_DOOR_RAID = "Rumored raid"
L.ADVENTURE_DOOR_NTH = "%s %d"
L.ADVENTURE_DOOR_CHOICE = "%s (%s)"
L.ADVENTURE_DOOR_VIA = "Its portal is below: go down at the cave entrance."
L.ADVENTURE_DOOR_VIA_BUILDING = "Its portal is inside: go in at the entrance."
L.ADVENTURE_DOOR_WAYPOINT_SET = "Waypoint set to where the rumor leads."
L.ADVENTURE_CAVE_LEADS_TO = "The way to a rumored place"
L.ADVENTURE_CAVE_LEFT_CLICK = "Left-click to see the map of the way in"
-- Adventure Mode's quest marks on the world map (UI/QuestMap.lua): a quest not offered yet is a faint "!", a
-- rumor, under "A rumor" (ADVENTURE_DOOR_TITLE) and in ADVENTURE_DOOR_LINE's quotation marks: there may be work
-- there, from someone or something (inside a dungeon, a tablet or a crest). It names no quest, dungeon or
-- place.
L.ADVENTURE_QUEST_RUMOR = "There may be work for you here."
-- Adventure Mode's Gear Finder (Core/GearFinder.lua, UI/GearPanel.lua): an upgrade not seen to drop yet, in place
-- of its name, in its rarity's colour; a rumour's place, the zone its door is in and its level range (%s: the
-- zone, %s: LEVEL_RANGE's "Level 17-26"); the tooltip's line for an upgrade whose dungeon is entered but which
-- has not been seen to drop there; the click lines of a slot, a pick's row and the suggested dungeon's row
-- showing one (they open the dungeon, not the item); a rumour's click line, on a slot showing one and on the
-- button, and where its door is not known; the button under a rumour that shows its door on the world map.
L.GEAR_ADVENTURE_BETTER = "Something better"
L.GEAR_ADVENTURE_PLACE = "%s · %s"
L.GEAR_ADVENTURE_UNSEEN = "You haven't seen it drop yet."
L.GEAR_ADVENTURE_CELL_CLICK = "Click for the top upgrades; right-click for the dungeon."
L.GEAR_ADVENTURE_PICK_CLICK = "Click to show it here; right-click for the dungeon."
L.GEAR_ADVENTURE_ROW_CLICK = "Click for the dungeon."
L.GEAR_ADVENTURE_MAP_CLICK = "Click to see the way there on the world map."
L.GEAR_ADVENTURE_NO_DOOR = "Where its door is isn't known yet."
L.GEAR_ADVENTURE_SHOW_MAP = "Show on map"
-- The Gear Finder's rumour slot with upgrades to pick: its picture leads to the door, its words to the picks;
-- and the picks' right-click where the slot has no link.
L.GEAR_ADVENTURE_MAP_PICK_CLICK = "Click the icon to see the way there on the world map; click the words for the upgrades you can pick."
L.GEAR_ADVENTURE_RUMOUR_PICKS = "Right-click for the upgrades you can pick."
--[[
	Not shown: what Adventure Mode's masking (Core/Discovery.lua) needs to know of the journal's names in
	this language, where its rules can't tell. Each translation's content file has its own lists.
	  MASK_GROUP_WORDS  words of bosses' names that name their group or their rank, not the boss: put out
	                    only as part of a boss's whole name, so "the Twilight's Hammer" and "Courier
	                    Hammerfall" stay as they are
	  MASK_PLACES       places, and others' names, that hold a boss's name ("Grim Guzzler"), never put out
	  MASK_NAMES        others' names (a faction's, a group's, a word) that are a quest's name in this language:
	                    on a boss's page and in a dungeon's description, never put out as the quest (none in
	                    English)
	  MASK_BOSS_FORMS   a boss's other forms, by its English name, where a line says it in a way no rule
	                    finds
	  MASK_QUEST_FORMS  a quest's other names, by its id, where a line names it otherwise (none in English)
]]
-- (Apprentice: Gortek the Apprentice's rank, Blackmaw Hold's rare since 2026-11-18, so the Burning Blade's Apprentices in
-- Ragefire Chasm's notes stay as they are)
L.MASK_GROUP_WORDS = { "Twilight", "Sandfury", "Executioner", "Dark", "Iron", "Quartermaster", "Courier", "Magistrate",
	"Prince", "Cannon", "Herald", "Swordsmith", "Apprentice" }
L.MASK_PLACES = { "Grim Guzzler", "King Magni Bronzebeard" }
L.MASK_NAMES = {}
L.MASK_BOSS_FORMS = {
	-- (a quest's giver, Doan Karhan, has his name: his strongbox is named whole)
	["Arcanist Doan"] = { "Doan's Strongbox" },
}
L.MASK_QUEST_FORMS = {}
L.STYLE_STARTING = "Starting Settings:"
L.STYLE_LINE_ON = "%s on"
L.STYLE_LINE_OFF = "%s off"
-- Adventure Mode's lines under "Starting Settings:" in the question's box: what is different about it.
L.STYLE_LINE_ADVENTURE_HIDDEN = "Dungeons, bosses and loot start hidden"
L.STYLE_LINE_ADVENTURE_FOG = "Dungeon maps under fog until bosses fall"
L.STYLE_LINE_ADVENTURE_ON = "Gear Finder, way-in maps and markers on"
L.STYLE_GEAR = "Gear Finder and stat weights"
L.STYLE_GEAR_TIP = "The Gear Finder tab, its tab on the character panel, the stat-weight lines on item tooltips, the green upgrade arrows and the journal's weights in Pawn. They all go by the same weights, so they go together. For this character only."
L.STYLE_WAY_IN = "Way-in maps and caves"
L.STYLE_WAY_IN_TIP = "Maps of the way into a dungeon (caves, buildings, Blackrock Mountain's levels) over the world map, and the cave and building doors to them. The dungeons' own maps stay. For this character only."
L.STYLE_MARKERS = "World map markers"
L.STYLE_MARKERS_TIP = "The journal's marks on the world map: dungeon and raid doors, flight masters, boats, zeppelins, trams and portals, its quest marks, zone levels and unexplored areas. For this character only."
L.STYLE_CLICK = "Click to choose"
L.STYLE_NOW = "Your style now"
L.STYLE_CLOSE_NOTE = "Closing this keeps %s."
L.STYLE_CHOSEN = "Journal style: %s. You can change it any time in the journal's options (/aegis options)."
L.STYLE_OPTIONS_AFTER_COMBAT = "The journal's options open when combat ends."
L.STYLE_OPTION = "Journal style"
L.STYLE_OPTION_TIP = "Classic, Modern, Adventure Mode or Custom, for this character only. Ticking or unticking a feature below makes it Custom (Adventure Mode stays on)."
L.STYLE_RESET = "Reset Instance Journal"
L.STYLE_RESET_BUTTON = "Reset"
L.STYLE_CHOOSE_BUTTON = "Choose"
L.STYLE_RESET_TIP = "Puts the journal's options back to how they were at install, for all your characters, and asks this character the style question again. Recordings, stat weights and your other characters' styles are kept."
L.STYLE_RESET_CONFIRM = "Put the journal's options back to how they were when you installed it, for all your characters, and ask this character the style question again? Your recordings, stat weights and other characters' styles are kept."
L.STYLE_GEAR_IS_OFF = "The Gear Finder is turned off. Turn it on in the journal's options (/aegis options)."
L.OPTIONS_RECORD_TAB = "Show the Record tab"
L.OPTIONS_RECORD_TAB_TIP = "The tab that records your dungeon runs for us. Unticked: the tab is hidden and the journal records nothing (Capture vendor on the Reputation tab still works). What you recorded before is kept."
L.RECORD_TAB_IS_OFF = "The Record tab is turned off. Turn it on in the journal's options (/aegis options)."
L.LEGEND_STYLE_OFF = "Turned off in the journal's options."
L.GEAR_WHY_CUSTOM = "%s (your weights)"
-- The specs' names and the units their weights count in are the generated weights' own English
-- (Data/Generated/GearWeights.lua). A translation names them here: by spec key
-- (L.GEAR_SPEC_NAMES = { Arms = "...", ... }) and by the English unit
-- (L.GEAR_UNITS = { ["attack power"] = "...", ... }).
L.GEAR_SPEC_NAMES = {}
L.GEAR_UNITS = {}
L.WEIGHT_GROUPS = {
	PRIMARY = "Primary Attributes", WEAPONS = "Weapons", SPELLS = "Spells", DEFENSE = "Defense",
	RESISTANCE = "Resistances",
}
L.STAT_NAMES = {
	STRENGTH = "Strength", AGILITY = "Agility", STAMINA = "Stamina", INTELLECT = "Intellect", SPIRIT = "Spirit",
	DPS = "Weapon DPS", ["RANGED DPS"] = "Ranged Weapon DPS", ["ATTACK POWER"] = "Attack Power",
	["RANGED ATTACK POWER"] = "Ranged Attack Power", ["FERAL ATTACK POWER"] = "Feral Attack Power", HIT = "Hit",
	CRIT = "Critical Strike", ["RANGED CRIT"] = "Ranged Critical", HASTE = "Attack Speed", ["RANGED HASTE"] = "Ranged Speed",
	["SPELL POWER"] = "Damage and Healing", ["SPELL DAMAGE"] = "Spell Damage", HEALING = "Healing", ["SPELL HIT"] = "Spell Hit",
	["SPELL CRIT"] = "Spell Critical", ["HOLY CRIT"] = "Holy Critical", ["HOLY DAMAGE"] = "Holy Damage",
	["FIRE DAMAGE"] = "Fire Damage", ["FROST DAMAGE"] = "Frost Damage", ["NATURE DAMAGE"] = "Nature Damage",
	["SHADOW DAMAGE"] = "Shadow Damage", ["ARCANE DAMAGE"] = "Arcane Damage", ["SPELL PENETRATION"] = "Spell Penetration",
	MANA = "Mana", ["MANA PER 5"] = "Mana per 5 sec", ["CASTING REGEN"] = "Regen While Casting",
	ARMOR = "Armor", HEALTH = "Health", ["HEALTH PER 5"] = "Health per 5 sec", DEFENSE = "Defense", DODGE = "Dodge",
	PARRY = "Parry", BLOCK = "Block", ["BLOCK VALUE"] = "Block Value",
	["HOLY RESISTANCE"] = "Holy Resistance", ["FIRE RESISTANCE"] = "Fire Resistance",
	["NATURE RESISTANCE"] = "Nature Resistance", ["FROST RESISTANCE"] = "Frost Resistance",
	["SHADOW RESISTANCE"] = "Shadow Resistance", ["ARCANE RESISTANCE"] = "Arcane Resistance",
}
L.RECORD_START = "Start Recording"
L.RECORD_STOP = "Stop Recording"
L.RECORD_CLEAR = "Clear"
L.RECORD_CLEAR_CONFIRM = "Throw away everything recorded so far? This cannot be undone."
L.RECORD_STATUS_ON = "Recording since %s"
L.RECORD_STATUS_OFF = "Not recording"
L.RECORD_COMBATLOG = "Write the combat log in dungeons"
L.RECORD_COMBATLOG_TIP = "Boss abilities come from the game's combat log. The journal turns it on inside dungeons and off again on the way out; a log you started yourself is left alone. To send it, add the log file to your recording on the Log Reader page (Copy shows the link)."
L.RECORD_RECENT = "Recent"
L.RECORD_NOTHING_YET = "Nothing caught yet. Walk into a dungeon with recording on, then kill, loot and quest as you always do."
L.RECORD_STARTED = "Recording started. /aegis record stops it."
L.RECORD_STOPPED = "Recording stopped."
L.RECORD_LOG_STARTED = "Recording started."
L.RECORD_LOG_STOPPED = "Recording stopped."
L.RECORD_LOG_CLEARED = "Recordings cleared."
L.RECORD_LOG_ENTERED = "Entered %s."
L.RECORD_LOG_LEFT = "Left the dungeon."
L.RECORD_LOG_AREA = "New area: %s."
L.RECORD_LOG_PULL = "Pulled %s."
L.RECORD_LOG_KILL = "Killed %s."
L.RECORD_LOG_WIPE = "Wiped on %s."
L.RECORD_LOG_LOOT = "Loot: %d new item(s)."
L.RECORD_LOG_QUEST_OFFERED = "Quest offered: %s."
L.RECORD_LOG_QUEST_DONE = "Quest handed in: %s."
L.RECORD_LOG_ENTRANCE = "Entrance of %s recorded."
L.RECORD_LOG_NO_ENTRANCE = "Entrance of %s not recorded: %s."
L.RECORD_NO_MAP = "the game gave no map as the loading screen began"
L.RECORD_NO_POSITION = "the game gave no position as the loading screen began"
L.RECORD_IN_DUNGEON_MAP = "the loading screen began on a dungeon's map"
L.RECORD_LOG_COMBATLOG_ON = "Combat log on: Logs\\%s."
L.RECORD_LOG_COMBATLOG_OFF = "Combat log off."

L.LEVEL_RANGE = "Level %d-%d"
L.LEVEL_ALL = "All Levels"
L.LEVEL_BRACKET = "Level %d to %d"
L.TRASH_DROPS = "Trash Drops"
L.UNTESTED = "Not yet tested"
L.UNTESTED_NOTE = "Not yet tested: what is here comes from Blizzard's announcement and may be incomplete. Run it with the Record tab on to fill in its bosses, loot and entrance."
L.COMING_SOON = "Coming soon"
L.COMING_SOON_TEXT = "Not open in WoW: Forever yet. Its bosses, loot and map come in as players record their runs. Recorded one? Post it on our Discord, and your name goes in the journal's contributors."
L.COMING_SOON_PARTLY = "Not open in WoW: Forever yet: what is here comes from Blizzard's announcement. Recorded a run? Post it on our Discord, and your name goes in the journal's contributors."
L.DISCORD_COPY_HINT = "Click, then Ctrl+C"
L.FOREVER_MARK = "New in WoW: Forever"
L.RECORD_LOG_VENDOR = "%s: %d wares kept, %d new to the journal."
L.RECORD_CAUGHT = "%d caught, %d new since your last copy"
L.RECORD_COPY = "Copy"
L.RECORD_AUTO = "Record automatically in dungeons"
L.RECORD_AUTO_TIP = "Recording starts by itself when you enter a dungeon or a raid, and stops when you leave. A recording you started yourself is never stopped for you."
L.RECORD_RECORDER = "Recorder"
L.RECORD_SEND = "Send it to us"
L.RECORD_HELP_TEXT = "Press Copy, then paste the text in our Discord:"
L.RECORD_CREDIT = "Credit me as:"
L.RECORD_CREDIT_TIP = "The name your recordings are credited to among the journal's contributors. Left empty, it is your character's name."
L.RECORD_CONTRIBUTORS = "Contributors"
L.RECORD_CONTRIBUTORS_NONE = "No one yet: be the first."
L.RECORD_CONTRIBUTORS_FOOT = "Send yours: your name goes here."
L.RECORD_COPY_TITLE = "Your recording, as text"
L.RECORD_COPY_HINT = "It is all picked out: press Ctrl+C, then paste it in our Discord."
L.RECORD_COPY_HINT_LOG = "Press Ctrl+C, then paste it on the Log Reader with your combat log (%s, in the game's Logs folder). Post what it gives you in our Discord."
L.RECORD_MORE_LOGS = "%s and %d older"
L.RECORD_BACK = "Back"
L.RECORD_CAUGHT_TITLE = "What you caught"
L.RECORD_ITEM = "Item %s"
L.RECORD_ONE_VISIT = "1 visit"
L.RECORD_VISITS = "%d visits"
L.RECORD_ENTRANCE_YES = "entrance recorded"
L.RECORD_ENTRANCE_NO = "entrance not recorded yet"
L.RECORD_AREAS = "%d areas"
L.RECORD_KILLED = "Killed: %s"
L.RECORD_KILLED_TIMES = "%s (%d)"
L.RECORD_DROPS = "Drops: %s new, %s already in the journal"
L.RECORD_OFF = "Off %s"
L.RECORD_OFF_TRASH = "Off trash"
L.RECORD_OFF_GROUP = "Looted by your group"
L.RECORD_OFF_OBJECTS = "Off chests and plants"
L.RECORD_QUESTS = "Quests"
L.RECORD_QUEST_DONE = "handed in"
L.RECORD_NEW = "new"
L.RECORD_QUARTERMASTERS = "Quartermasters"
L.RECORD_WARES = "%s: %d wares, %s new"
L.RECORD_TRAVEL = "Travel marks: %d"
L.RECORD_MODELS = "Models: %d"
L.FOREVER_LINE = "New in WoW: Forever."
L.LOCATION_LINE = "Location: %s"

-- The dungeon's round icon at the top of its left page: its tooltip, under the dungeon's name.
L.INSTANCE_ICON_OVERVIEW = "Click to see its overview."

L.TAB_OVERVIEW = OVERVIEW or "Overview"
L.TAB_LOOT = LOOT_NOUN or "Loot"
L.TAB_ABILITIES = ABILITIES or "Abilities"
L.TAB_MODEL = MODEL or "Model"
L.TAB_QUESTS = QUESTS_LABEL or "Quests"
L.ALL_CLASSES = ALL_CLASSES or "All Classes"
L.ALL_ARMOR = "All Armor"
L.ALL_TYPES = "All Types"
-- The loot pages' Type menu: the kinds of item, "All ..." atop the two with a submenu, and one of each.
L.LOOT_KIND = {
	EQUIPMENT = "Equipment", RECIPE = "Recipes", CONSUMABLE = "Consumables", MOUNT = "Mounts", PET = "Pets",
	TOY = "Toys", BAG = "Bags", TRADE = "Trade Goods", QUEST = "Quest Items", OTHER = "Other",
}
L.LOOT_KIND_ALL = { EQUIPMENT = "All Equipment", RECIPE = "All Recipes" }
L.LOOT_KIND_ONE = { MOUNT = "Mount", PET = "Pet", TOY = "Toy" }
L.LOOT_RECIPE = "Recipe"
-- A loot row's type where the client cannot describe the item (Core/Items.lua's Items:Words): a quest item
-- (the game's tooltip line for one, ITEM_BIND_QUEST, where the client has it), and the data's other words.
-- Keyed by the data's English word; a slot, a profession and an armor type are the client's own words first.
L.LOOT_QUEST_ITEM = "Quest Item"
L.LOOT_WORDS = {
	Alchemy = "Alchemy", Blacksmithing = "Blacksmithing", Cooking = "Cooking", Enchanting = "Enchanting",
	Engineering = "Engineering", ["First Aid"] = "First Aid", Fishing = "Fishing", Leatherworking = "Leatherworking",
	Tailoring = "Tailoring", Book = "Book", Blueprint = "Blueprint", Bag = "Bag", ["Ammo Pouch"] = "Ammo Pouch",
	Quiver = "Quiver", Arrow = "Arrow", Bullet = "Bullet", Consumable = "Consumable",
	["Food & Drink"] = "Food & Drink", Potions = "Potions", Junk = "Junk", Key = "Key", Other = "Other",
	Parts = "Parts", Reagent = "Reagent", Weapon = "Weapon", Cloth = "Cloth", Leather = "Leather", Mail = "Mail",
	Plate = "Plate", Shield = "Shield", Idol = "Idol", Libram = "Libram", Totem = "Totem", Axe = "Axe", Bow = "Bow",
	Crossbow = "Crossbow", Dagger = "Dagger", ["Fist Weapon"] = "Fist Weapon", Gun = "Gun", Mace = "Mace",
	Polearm = "Polearm", Staff = "Staff", Sword = "Sword", Wand = "Wand",
}
L.LOOT_FAVORITES = "Favorites"
L.LOOT_FAVORITES_ONLY = "Favorites only"
L.LOOT_FAVORITE = "Add to favorites"
L.LOOT_UNFAVORITE = "Remove from favorites"
L.LOOT_PINNED = "Pinned"
L.LOOT_ALL = "Loot"
L.LOOT_TRASH = "Dungeon trash"
-- A Trash page's row the dungeon's bosses and rares drop instead (UI/LootPanel.lua): its line on the
-- dungeon's own Loot page ("Boss: Any boss or rare") and its note in the row's tooltip.
L.LOOT_BOSSES_AND_RARES = "Any boss or rare"
L.LOOT_BOSSES_AND_RARES_NOTE = "Drops from the dungeon's bosses and rares, not from its trash."
-- A Recipes page's row the dungeon's bosses drop, any of them, and its trash does not (Forever's shared recipes,
-- 2026-11-20: offBosses = "bosses", ns.OffBossesText): its line on the dungeon's own Loot page and its note.
L.LOOT_ANY_BOSS = "Any boss"
L.LOOT_ANY_BOSS_NOTE = "Drops from the dungeon's bosses, not from its trash."
-- A loot row kept though no drop of it is recorded there yet (notSeen, 2026-11-20): a gray line in its tooltip.
L.LOOT_NOT_SEEN_NOTE = "Not seen dropping yet."
-- Where an item drops, on its tooltip (UI/ItemTooltip.lua): its boss and dungeon, its number of
-- bosses there, its trash; the dungeons, for one of several; on a loot row, the other dungeons.
L.DROPS_FROM_BOSS = "Drops from %s in %s"
L.DROPS_FROM_TRASH = "Drops from trash in %s"
L.DROPS_FROM_BOSSES = "Drops from %d bosses in %s"
L.DROPS_FROM_BOSSES_AND_RARES = "Drops from any boss or rare in %s"
L.DROPS_FROM_ANY_BOSS = "Drops from any boss in %s"
L.DROPS_IN = "Drops in %s"
L.DROPS_ALSO_IN = "Also drops in %s"
-- The world map legend's entries, each a switch (UI/MapLegend.lua).
L.LEGEND_CLICK_HIDE = "Click to hide these on the map."
L.LEGEND_CLICK_SHOW = "Hidden. Click to show these on the map again."
L.LEGEND_QUEST_TIP = "The journal's ! marks on the maps: quests you can take, and gray ones not open yet."
L.LEGEND_GAME_FILTER = "The game's own map filter, as in the map's filter menu: quests in progress and ready to hand in share one."
L.LEGEND_GAME_FILTER_MENU = "Shown or hidden from the map's filter menu: %s."
-- Before you go, at the top of a dungeon's Quests tab: its key and the quests to it, a hidden boss to prepare for.
L.PREPARE_TITLE = "Before you go"
L.PREPARE_PROGRESS = "You have done %d of its %d quests."
-- The same for a key with one quest.
L.PREPARE_PROGRESS_ONE = "You have not done its quest yet."
L.PREPARE_HAVE = "You have it."
-- A chain of quests to do first (Before you go's chain = true), once done.
L.PREPARE_CHAIN_DONE = "You have done its quests."
-- Before you go's line on a dungeon's overview, under its facts, where the player's side has notes: how many,
-- and that they are on the Quests tab (a click opens it). The second for one note.
L.PREPARE_POINTER = "Before you go: %d notes, on the Quests tab."
L.PREPARE_POINTER_ONE = "Before you go: 1 note, on the Quests tab."
-- The small Play button beside a dungeon's lore and a boss's (UI/SpokenButton.lua), which plays Spoken's own
-- recorded story of it through the player's Spoken. "Spoken" is named here and nowhere else in the journal's
-- words: the owner's call of 2026-11-13. Its tooltip: what a click does (Play, Replay once stopped, Stop while it
-- speaks) over "Read aloud by Spoken."; grayed, why (red) over what it does.
L.SPOKEN_PLAY = "Play the story"
L.SPOKEN_REPLAY = "Play the story again"
L.SPOKEN_STOP = "Stop"
L.SPOKEN_BY = "Read aloud by Spoken."
L.SPOKEN_REQUIRES = "Requires Spoken"
L.SPOKEN_ABOUT_PLACE = "Reads this place's story aloud."
L.SPOKEN_ABOUT_BOSS = "Reads this boss's story aloud."
L.SPOKEN_NO_STORY_PLACE = "Spoken has no recorded story for this place."
L.SPOKEN_NO_STORY_BOSS = "Spoken has no recorded story for this boss."
-- Grayed where Spoken's own story API says it has no story it can play there, and the journal's checks can't tell why (2026-11-14).
L.SPOKEN_NO_STORY_YET = "Spoken has no story it can play here yet."
L.SPOKEN_NEEDS_BOSS_VOICES = "Needs Spoken's boss voices, which are not installed."
L.SPOKEN_NEEDS_PLACE_VOICES = "Needs Spoken's place voices, which are not installed."
L.SPOKEN_OFF = "Turned off in Spoken's settings."
-- Grayed where Spoken keeps the story back from this character (the place not found yet, the boss not met).
L.SPOKEN_LOCKED_PLACE = "Spoken tells this story once you have found this place."
L.SPOKEN_LOCKED_BOSS = "Spoken tells this story once you have met this boss."
-- The Quests tab's dropdown of the dungeon's own quests (after its key, if it has one).
L.QUESTS_DUNGEON = "Dungeon Quests"
-- The same on a raid's Quests tab.
L.QUESTS_RAID = "Raid Quests"
-- The Quests tab's dropdown of the quests for the player's class alone (after Dungeon Quests).
L.QUESTS_CLASS = "Class Quests"
-- The trash's entry in a dungeon's boss list, and its page.
L.TRASH = "Trash"
L.TRASH_DESCRIPTION = "What the dungeon's other creatures drop that is worth knowing about: rare and epic gear, recipes and quest items."
-- The recipes' entry in a dungeon's boss list, after the trash's (recipes = true: Core/Registry.lua's ns.IsLootSection),
-- and its page.
L.RECIPES = "Recipes"
L.RECIPES_DESCRIPTION = "The recipes, plans and patterns that drop in the dungeon, off its bosses and its other creatures. A boss's own recipe is on that boss's page too."
L.LOOT_BOSS_LINE = BOSS_INFO_STRING or "Boss: %s"
L.LOOT_FILTER_BAR = "Filter: %s"
L.LOOT_RETRIEVING = RETRIEVING_ITEM_INFO or "Retrieving item information"
L.LOOT_NO_DATA = "Item %d"
L.LOOT_NO_DATA_TOOLTIP = "The server has not sent this item's details. It may not be in the game yet."
L.LOOT_UNIDENTIFIED_TOOLTIP = "Not identified yet: its source names it, but not its item ID. Loot it while recording to add it."
L.LOOT_TOOLTIP_PIN = "Right-click to pin this item to the top of this list."
L.LOOT_TOOLTIP_UNPIN = "Right-click to unpin."
L.LOOT_NONE = "No loot is known for this yet."
L.LOOT_NO_MATCH = "Nothing here matches the filters. Clear them with the X above."
L.ABILITY_LOADING = RETRIEVING_DATA or "Retrieving data..."
L.ABILITIES_NONE = "No abilities are known for this encounter yet. Record a run from the Record tab to capture them."
L.STATS_HIT = "Hits %s"
L.STATS_TICK = "ticks %s"
L.STATS_FIRST = "first cast at %ds"
L.STATS_EVERY = "then every %ss"
L.QUEST_NONE = "No quests for your faction are known for this dungeon."
L.QUEST_STATUS_READY = "Complete: ready to hand in"
L.QUEST_STATUS_NEEDS = "Requires: %s"
L.QUEST_STATUS_LEVEL = "Requires level %d"
L.QUEST_DESCRIPTION = QUEST_DESCRIPTION or "Description"
L.QUEST_START_ITEM = "Begins with:"
L.QUEST_PARTS = "%s (%d parts)"
-- A row for the quests of one chain that share a name: which of them its page shows.
L.QUEST_PART_OF = "Part %d of %d"
-- One of them as a row of its own, in a chain: which part it is.
L.QUEST_PART_NAME = "%s (Part %d)"
-- A step any one of several quests will do: on a quest that needs one, and on the step's own row.
L.QUEST_STATUS_NEEDS_VERSION = "Requires one of the %d versions of %s"
L.QUEST_STATUS_NEEDS_ONE_OF = "Requires one of: %s"
-- A quest given only while another is in the log (QuestieDB's parentQuest).
L.QUEST_STATUS_NEEDS_IN_LOG = "Requires: %s in your quest log"
L.QUEST_OR = " or "
L.QUEST_LIST_COMMA = ", "
L.QUEST_ONE_OF_VERSIONS = "This quest comes in %d versions. Any one of them will do."
L.QUEST_ONE_OF_ANY = "Any one of these quests will do."
L.QUEST_SHOW_START = "Show Start"
L.QUEST_SHOW_END = "Show End"
L.QUEST_PLACE_UNKNOWN = "Location not known yet. Pick up or hand in this quest with the Record tab running to add it."
L.QUEST_OFFERED_BY = "Quest offered by %s"
L.QUEST_HAND_IN_TO = "Hand in to %s"
L.QUESTMAP_DUNGEON_QUEST = "Dungeon quest: %s"
L.QUESTMAP_RAID_QUEST = "Raid quest: %s"
L.QUESTMAP_LEFT_CLICK = "Left-click to open it in the journal"
L.QUESTMAP_WAYPOINT_SET = "Waypoint set for %s."
L.QUESTMAP_WAYPOINT_SET_IN = "Waypoint set for %s, in %s."
L.WAYPOINT_OFFER = "Click %s to set the waypoint."
L.QUESTMAP_ONE_OF = "Not always in the same place: one of %d spots."
-- What is looted, used or explored for a quest inside a dungeon, on its In Progress mark's tooltip (UI/QuestMap.lua's
-- ObjectiveLine), after the game's own dash: the item to take (%s: its name, as the client gives it), the same for a
-- name that takes no "the" ("The Book of Ur", "Jordan's Smithing Hammer"), the thing to use (%s: its name), and a
-- place to explore.
L.QUESTMAP_OBJECTIVE_DASH = QUEST_DASH or "- "
L.QUESTMAP_OBJECTIVE_TAKE = "Take the %s"
L.QUESTMAP_OBJECTIVE_TAKE_NAMED = "Take %s"
-- A title on that line, in the language's quotation marks (%s: the title: "Take “Of Love and Family”").
L.QUESTMAP_TITLE_QUOTED = "“%s”"
L.QUESTMAP_OBJECTIVE_USE = "Use the %s"
L.QUESTMAP_OBJECTIVE_EXPLORE = "Explore this place"
-- A spot's own words for what to do there, in place of those (its line, a key of these strings: UI/QuestMap.lua's
-- ObjectiveLine): at the Drowned City's tablets of I'lalai, a rubbing with the hide and charcoal (2026-11-12).
L.QUESTMAP_OBJECTIVE_RUBBING = "Make a rubbing with the hide and charcoal"
-- A machine that takes one item and gives the next (Gnomeregan's Matrix Punchographs, 2026-11-12), on its mark's tooltip,
-- with no dash: what goes in, then what comes out, each in its short word ("Yellow > Blue": the owner's words, "make the
-- tooltip say blue > red", words so that color-blind players can read it too); the punch cards' colors, as each card's name
-- has it (White Punch Card, Yellow, Blue, Red, Prismatic); and a note under it where what goes in drops (%s: its name, as
-- the client gives it): the White Punch Card, from mobs in the tunnels outside Gnomeregan.
L.QUESTMAP_OBJECTIVE_STEP = "%s > %s"
L.QUESTMAP_CARD_WHITE = "White"
L.QUESTMAP_CARD_YELLOW = "Yellow"
L.QUESTMAP_CARD_BLUE = "Blue"
L.QUESTMAP_CARD_RED = "Red"
L.QUESTMAP_CARD_PRISMATIC = "Prismatic"
L.QUESTMAP_NOTE_INPUT_DROPS = "The %s drops from mobs in these tunnels."
-- A machine used again once its quest is done (the Sparklematic 5200, 2026-11-12), on its repeatable mark's tooltip
-- (UI/QuestMap.lua's RepeatMark): that it takes another of what it cleans (%s: its name, as the client gives it,
-- "Grime-Encrusted Object").
L.QUESTMAP_REPEAT_AGAIN = "Repeatable: put in another %s."
-- What a boss is to a quest, on his tooltip under his quest badge (UI/QuestMap.lua's BadgeLine; the owner's lines of
-- 2026-11-11): one to kill; one that drops what the quest needs (%s: the item, as the client gives it), the same for a
-- name that takes no "the" ("Razorflank's Medallion"), and one whose drop starts the quest; who gives the quest there, or
-- takes it, himself or by name (%s: someone at his spot, "Zaetar's Spirit"). A quest's mob more than a boss (the
-- Excavation Site's Highland Horror): QUEST_TARGET on his map pin's tooltip.
L.QUEST_BADGE_KILL = "Kill for this quest"
L.QUEST_BADGE_DROPS = "Drops the %s"
L.QUEST_BADGE_DROPS_NAMED = "Drops %s"
L.QUEST_BADGE_STARTS = "Drops the %s: it starts a quest"
L.QUEST_BADGE_STARTS_NAMED = "Drops %s: it starts a quest"
L.QUEST_BADGE_GIVES = "Gives this quest"
L.QUEST_BADGE_GIVES_WHO = "%s gives this quest here"
L.QUEST_BADGE_TAKES = "Hand it in here"
L.QUEST_BADGE_TAKES_WHO = "Hand it in to %s here"
L.QUEST_TARGET = "Quest target"
L.MAP_ONE_OF = "Not always in the same place: one of %d spots."
L.QUEST_REWARDS = REWARDS or "Rewards"
L.QUEST_YOU_RECEIVE = YOU_RECEIVE or "You will receive:"
L.QUEST_XP = "%s Experience"
-- XP that is only the original game's number, not yet confirmed on Forever: a note after it, and
-- its tooltip (2026-10-30).
L.QUEST_XP_ORIGINAL = "(original game)"
L.QUEST_XP_ORIGINAL_TIP = "This is what the quest gave in the original game. Forever may give more. This is not yet checked on Forever. Hand it in with the Record tab running to add what Forever gives."
L.QUEST_REPUTATION = "%d %s Reputation"
L.QUEST_CHOOSE = REWARD_CHOICES or "You will be able to choose one of these rewards:"
L.QUEST_ALSO = REWARD_ITEMS or "You will also receive:"
L.REP_REWARDS = "%d rewards"
L.REP_REWARD_ONE = "1 reward"
L.REP_ALL_REWARDS = "Rewards"
-- The faction page's group for the wares that need no standing (ns.ANY_STANDING)
L.REP_ANY_STANDING = "Any standing"
L.REP_UNKNOWN = "Not met"
L.REP_CARD_CLICK = "Click to see its rewards."
L.REP_YOUR_STANDING = "Your standing: %s"
L.REP_NOT_MET = "You have not met this faction yet."
L.REP_PROGRESS = "%s / %s"
L.REP_QUARTERMASTER = "Quartermaster: %s"
L.REP_CAPTURE = "Capture vendor"
L.REP_CAPTURE_TIP = "Walk up to a reputation quartermaster and open their shop, then press this. Everything they sell is kept: each ware's price, any other cost, and the standing it needs. The wares join their faction's rewards at once, and come along when you press Copy on the Record tab."
L.REP_CAPTURE_READY = "Shop open: press Capture vendor."
L.REP_CAPTURE_HINT = "Open a quartermaster's shop to capture their wares."
L.REP_CAPTURED = "%s: %d wares for %s, %d new."
L.REP_CAPTURED_NONE = "%s: %d wares kept; none needs a standing."
L.REP_CAPTURED_UNKNOWN = "%s: %d wares need a standing with a faction the game doesn't name; kept until a ware names it."
L.REP_NOT_CAPTURED = "Not captured yet"
L.REP_NOT_CAPTURED_TIP = "No one has captured this faction's quartermaster yet."
L.REP_NOT_CAPTURED_TEXT = "No one has captured this faction's quartermaster yet. Find one, open their shop and press Capture vendor on the Reputation tab, then post your recording on our Discord. Your name goes in the journal's contributors."
L.REP_LISTED_TIP = "Its rewards come from the game's item data and haven't been confirmed at a quartermaster yet."
L.REP_LISTED_TEXT = "These rewards come from the game's item data, not yet from a quartermaster, so they have no prices and a few may not be sold at all. Find one of this faction's quartermasters, open their shop and press Capture vendor on the Reputation tab, then post your recording on our Discord. Your name goes in the journal's contributors."
L.REP_COMING_SOON_TEXT = "New in WoW: Forever, and not captured yet. Once it is in the game, find its quartermaster, open their shop and press Capture vendor on the Reputation tab, then post your recording on our Discord."
-- The Reputation tab's Vendors: a page for each currency a vendor takes for wares that need no standing (2026-11-12).
L.REP_VENDORS = "Vendors"
L.CURRENCY_YOU_HAVE = "You have %s"
L.CURRENCY_VENDOR = "Vendor: %s"
L.CURRENCY_CARD_CLICK = "Click to see their wares."
L.REP_CAPTURED_CURRENCY = "%s: %d wares kept, sold for %s."
-- Where Carved Centaur Totems come from, on its Vendors card and page (Gorhak's; %s is the item's name as the client writes
-- it). In Forever's quest data, quests 93224 and 93225 ask for five; Khan Hratha (96222, from Umarak) gives ten (the
-- owner confirmed it in game, 2026-11-13; that data lists no rewards and has the quest Horde only, so the line names no side).
L.CURRENCY_NOTE_CENTAUR_TOTEM = "%s: centaurs of any clan in Desolace drop them, and the quest Khan Hratha gives ten. The quest Carved Centaur Totems, for the Alliance and the Horde alike, asks for five."
L.MAP_SHOW = ENCOUNTER_JOURNAL_SHOW_MAP or "Show Map"
L.MAP_SHOW_UNEXPLORED = "Show unexplored areas"
L.OPTIONS_UNEXPLORED_TIP = "Shades the parts of a zone you haven't explored yet on the world map."
-- The map legend's Fog of War switch (UI/MapLegend.lua), the last of Movement's: its name, its
-- description, then what is so now on the map shown and what a click does there, on a zone's map (the unexplored
-- areas) or a dungeon's with fog; why it can't in Adventure Mode on a dungeon's map, where there is no fog, and on a
-- zone the character has explored whole.
L.LEGEND_FOG = "Fog of War"
L.LEGEND_FOG_TOOLTIP = "Hides the parts of a zone you haven't explored, and the parts of a dungeon's map your group hasn't cleared."
L.LEGEND_FOG_ZONE_HIDDEN = "The map shows only the parts of this zone you have explored."
L.LEGEND_FOG_ZONE_SHOWN = "The parts of this zone you haven't explored show too, a little darker."
L.LEGEND_FOG_ZONE_SHOW = "Click to show the parts you haven't explored."
L.LEGEND_FOG_ZONE_HIDE = "Click to show only the parts you have explored."
L.LEGEND_FOG_DUNGEON_ON = "Fog covers the parts of this map you haven't cleared. Each boss your group defeats clears its rooms."
L.LEGEND_FOG_DUNGEON_OFF = "The fog is off: the whole map shows."
L.LEGEND_FOG_DUNGEON_CLEARED = "The fog has cleared: the whole map shows."
L.LEGEND_FOG_DUNGEON_LIFT = "Click to turn the fog off."
L.LEGEND_FOG_DUNGEON_LAY = "Click to turn the fog on."
L.LEGEND_FOG_ADVENTURE = "Can't be turned off in Adventure Mode."
L.LEGEND_FOG_NONE = "No fog of war on this map."
L.LEGEND_FOG_ZONE_EXPLORED = "You have explored all of this zone."
-- The map legend's switches, in the map's filter menu too (UI/ZoneMap.lua).
L.MAP_FILTER_QUESTS = "Quests on offer"
L.MAP_FILTER_DUNGEONS = "Dungeon entrances"
L.MAP_FILTER_RAIDS = "Raid entrances"
L.MAP_FILTER_FLIGHT = "Flight points"
L.MAP_FILTER_CAVES = "Cave entrances"
L.MAP_FILTER_TRANSPORT = "Boats, zeppelins, trams and portals"
L.MAP_PIN_OPEN = "Click to open in the journal."
L.MAP_DEFEATED = DUNGEON_ENCOUNTER_DEFEATED or "Defeated"
-- The hint where a boss not yet defeated waits, under the fog: its tooltip's line.
L.MAP_FOG_HINT = "Defeat it to clear the fog here."
L.MAP_UNMET_HINT = "Not met yet."
L.MAP_LEVEL = "Level %d"
L.MAP_FLOOR = "Level %d"
-- A dungeon's floor (or an area's level) on the map's location bar over a zone not its own: the floor, then its place.
L.MAP_STEP_ELSEWHERE = "%s (%s)"
L.MAP_GO_TO = "To %s"
-- Under a way between floors, where two lead to one floor (the Drowned City's: Data/Authored/Upcoming.lua), where
-- it comes out on that floor.
L.MAP_WAY_OUT_SOUTHWEST = "Comes out at its south-west end"
L.MAP_WAY_OUT_NORTHEAST = "Comes out at its north-east end"
L.MAP_WAY_OUT_DEEP_ARCHIVES = "Comes out in the Deep Archives"
L.MAP_WAY_OUT_CENTRAL_POOL = "Comes out in the central pool"
L.MAP_YOU_ARE_HERE = "You are here"
L.ENTRANCE_DUNGEON = LFG_TYPE_DUNGEON or "Dungeon"
L.ENTRANCE_RAID = LFG_TYPE_RAID or "Raid"
L.ENTRANCE_DUNGEONS = DUNGEONS or "Dungeons"
L.ENTRANCE_RAIDS = RAIDS or "Raids"
L.ENTRANCE_LEFT_CLICK = "Left-click to open the Instance Journal"
L.ENTRANCE_CHOOSE_LEFT_CLICK = "Left-click to choose one to open in the Instance Journal"
L.ENTRANCE_RIGHT_CLICK = "Right-click to set a waypoint"
L.ENTRANCE_WAYPOINT_SET = "Waypoint set to the entrance of %s."
L.ENTRANCE_VIA = "Its portal is below, in %s: go down at the cave entrance."
L.ENTRANCE_WAYPOINT_VIA = "Waypoint set to the way down into %s, for %s."
L.CAVE_LABEL = "Cave Entrance"
L.BUILDING_LABEL = "Entrance"
L.ENTRANCE_VIA_BUILDING = "Its portal is inside, in %s: go in at the entrance."
L.CAVE_LEADS_TO = "The way to %s"
L.CAVE_LEFT_CLICK = "Left-click to see the map of %s"
L.CAVE_WAYPOINT_SET = "Waypoint set to the way down into %s."
L.FLIGHT_POINT = MAP_LEGEND_FLIGHTPOINT or "Flight Point"
L.CLICK_FOR_WAYPOINT = "Click to set a waypoint"
L.FLIGHT_WAYPOINT_SET = "Waypoint set to the flight master at %s."
L.TRAVEL_KINDS = { boat = "Boat", zeppelin = "Zeppelin", airship = "Airship", tram = "Tram", portal = "Portal" }
L.TRAVEL_FACTIONS = { Alliance = FACTION_ALLIANCE or "Alliance", Horde = FACTION_HORDE or "Horde" }
L.TRAVEL_ROUTE = "%s to %s"
L.TRAVEL_AND = "%s and %s"
L.TRAVEL_ROUTE_NOTE = "%s: %s"
L.TRAVEL_HELP = "Stand at a dock, zeppelin tower, tram or portal and type /aegis travel boat (or zeppelin, airship, tram, portal) followed by where it goes, e.g. /aegis travel boat Auberdine. Add alliance, horde or neutral at the end to say who it serves, and a note in brackets for who may take it, e.g. /aegis travel portal Dalaran (Skyborne only). /aegis travel list shows what is saved; /aegis travel undo takes back the last one."
L.TRAVEL_NO_POSITION = "The game gives no position here, so nothing was saved."
L.TRAVEL_SAVED = "Saved %s at %s. /aegis travel undo takes it back."
L.TRAVEL_UNDONE = "Took back %s at %s."
L.TRAVEL_NOTHING = "Nothing to take back."
L.TRAVEL_LIST_EMPTY = "No travel spots saved yet. Type /aegis travel to see how."
L.TRAVEL_LIST_LINE = "%d. %s at %s (map %d, %.4f, %.4f)"
L.TRAVEL_WAYPOINT_SET = "Waypoint set to %s."
L.LEGEND_TRANSPORT = "Transport"
L.LEGEND_TRANSPORT_TOOLTIP = "Boats, zeppelins, the tram and portals. Blue serves the Alliance, red the Horde, gold everyone."
L.LEGEND_CAVE_TOOLTIP = "The way into a cave, where a dungeon's door is. Click it on the map to see inside."
L.LEGEND_BUILDING_TOOLTIP = "The way into a building, a mountain's halls or a level below the zone, where a dungeon's door is. Click it on the map to see inside."
L.SEARCH_SHOW_ALL = SEARCH_RESULTS_SHOW_COUNT or "Show All %d Results"
L.SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Search Results for \"%s\" (%d)"
L.SEARCH_TYPE_BOSS = "Encounter"
L.SEARCH_TYPE_ABILITY = "Ability"
L.SEARCH_TYPE_ITEM = "Item"
L.SEARCH_TYPE_QUEST = "Quest"
L.SEARCH_TYPE_FACTION = FACTION or "Faction"
L.MAP_PIN_CLEAR = "Click to remove this pin."
L.MAP_PIN_COMBAT = "The map can't be opened in combat."
-- With the Gamepad UI's HUD mode up, the journal opens none of the game's windows (the world map, the game's
-- settings): Core/Compat.lua's ns.Gamepad:ShowPanel.
L.GAMEPAD_HUD_UP = "Leave the Gamepad UI's HUD mode first, then try again."
L.MAP_PIN_IN_ZONE = "%s is marked on the map of %s."
-- The way to another level of an area below a zone (Blackrock Mountain's), on its picture.
L.MAP_LEVEL_LINK_CLICK = "Left-click to see that level's map"
-- A place worth knowing on a dungeon's map (UI/DungeonMap.lua's MapSpot): its kind's name, the tooltip's title, and
-- each place's own line under it (the Drowned City's hidden chest, the owner's find of 2026-11-17).
L.MAP_SPOT_CHEST = "Hidden Chest"
L.MAP_SPOT_DROWNED_CHEST = "On the wrecked boat past Min'loth the Serpent. It isn't locked: anyone can open it for random items and materials."
-- The Spire's door, on Blackrock Mountain's picture and on both dungeons' pages (Data/Authored/SubMaps.lua).
L.DOOR_SPIRE_ONE_INSTANCE = "Lower and Upper Blackrock Spire are one instance, with one door."
L.DOOR_SPIRE_LOWER = "Lower Blackrock Spire: up to 10 players, but its quests can only be completed in a group of 5 or fewer."
L.DOOR_SPIRE_UPPER = "Upper Blackrock Spire: further in, behind a sealed door that needs the Seal of Ascension. Up to 10 players."

L.RARE_SUFFIX = " (Rare)"
L.AND_MORE = "and %d more"
L.BULLET_AREA = "Found in %s."
L.BULLET_RARE = "A rare spawn: not every run meets it."
L.BULLET_SUMMONED = "A hidden boss you summon yourself: the note above says how."
-- The same bullet where his note is a plain one naming several bosses, not a hidden boss's (the Shaper's
-- Terrace's console bosses: not hidden, the owner's call of 2026-11-19; "summon", as their note says it, since the
-- owner's short form of 2026-11-20).
L.BULLET_CALLED_UP = "A boss you summon yourself: the note above says how."
-- A quest's mob, on the map only (questTarget: Techbot, the Highland Horror), on his page.
L.BULLET_QUEST_TARGET = "A quest target, not one of the dungeon's bosses."
L.BULLET_LEVEL = "A level %d encounter."
L.BULLET_ABILITIES = "Seen casting: %s."
L.BULLET_LOOT = "Drops %d items, including %s."
L.BULLET_ADDS = "Joined by %s."
L.ADD_DESCRIPTION = "Fights beside %s."
L.BULLET_NOTHING_YET = "Nothing is known about this encounter yet."

-- The run block (UI/RunTracker.lua, Core/Run.lua): the client's own words where it has them.
L.RUN_BOSS_DEFEATED = "%s defeated"
L.RUN_COMPLETE = DUNGEON_COMPLETED or "Dungeon Complete!"
L.RUN_EXPERIENCE = EXPERIENCE_COLON or "Experience:"
L.RUN_MONEY = MONEY_COLON or "Money:"
L.RUN_ITEMS = "Items:"
L.RUN_PER_HOUR = "%s/hr"
L.RUN_GREED = "%d won on " .. (GREED or "Greed")
L.RUN_DEFEATED = BOSS_DEAD or "Defeated"
L.RUN_NOT_DEFEATED = "Not defeated yet"
L.RUN_PARTS = "%s, then %s"
L.RUN_COIN = "Coin looted"
L.RUN_ITEM_VALUE = "Items at vendor price"
L.RUN_PENDING = "Waiting for a price: %d"
L.RUN_DRAG = "Drag the header to move it."
L.RUN_SUMMARY = "%s: %d/%d bosses in %s"
L.RUN_SUMMARY_XP = "%s XP"
L.RUN_SUMMARY_ITEMS = "Items: %d"
L.RUN_NEW = "A new run starts now."
L.RUN_NOT_INSIDE = "Go into a dungeon to start a new run."
L.RUN_HIDDEN = "The run block is hidden for this run. Type /ij run to show it again."
L.RUN_NONE = "No dungeon run yet."
L.RUN_IS_OFF = "The run tracker is off. Turn it on in the journal's options (/aegis options)."
L.RUN_FREE_OFF = "The run block is back by the quest tracker."
-- The run block's header lock and its chat lines, /ij run lock and unlock now the lock's (UI/RunTracker.lua LOCK), 2026-11-17.
L.RUN_USAGE = "/ij run shows or hides the run block (outside a dungeon, your last run). /ij run new starts a new run. /ij run lock and /ij run unlock lock it in place or let you drag it again, as the lock on its header does; /ij run reset puts it back by the quest tracker. /ij run debug prints what it counted."
L.RUN_LOCKED = "Locked"
L.RUN_LOCKED_TIP = "Click to unlock it, then drag the block by its header."
L.RUN_UNLOCKED = "Unlocked"
L.RUN_UNLOCKED_TIP = "Drag the block by its header to move it. Click to lock it in place."
L.RUN_LOCK_ON = "The run block is locked in place."
L.RUN_LOCK_OFF = "The run block is unlocked: drag it by its header to move it."
L.RUN_LOCK_NOT_FREE = "It moves only while it is placed freely (\"%s\" in the options)."
-- The clock's buttons on the run block, between the time and the count (UI/RunTracker.lua CONTROLS), 2026-11-14.
L.RUN_CLOCK_START = "Start the clock now"
L.RUN_CLOCK_WAITING = "Otherwise it starts at the first fight."
L.RUN_CLOCK_PAUSE = "Pause the clock"
L.RUN_CLOCK_RESUME = "Resume the clock"
L.RUN_CLOCK_DONE = "The run is done, so its clock has stopped."
L.RUN_RESTART = "New run"
L.RUN_RESTART_CONFIRM = "Start a new run? This clears its kills and restarts the clock."
-- The run block's one line inside a Scarlet Monastery wing before the wing is known (UI/RunTracker.lua), 2026-11-17.
L.RUN_WHICH_WING = "Which wing?"
-- /ij run new or New run before the wing is known: the new run starts once it is (UI/RunTracker.lua), 2026-11-17.
L.RUN_NEW_WING = "A new run starts once the wing is known."
L.OPTIONS_RUN = "Dungeon run tracker"
L.OPTIONS_RUN_TIP = "Inside a dungeon, a block by the quest tracker shows how long the run has taken, its bosses and what you've gained. Off, nothing is counted."
L.OPTIONS_RUN_NUMBERS = "Show experience and money"
L.OPTIONS_RUN_NUMBERS_TIP = "Experience and money (coin looted plus the vendor price of the items you get), each with its rate per hour, and how many items you got."
L.OPTIONS_RUN_FREE = "Place it freely"
-- "Place it freely" on by default since 0.39.23: its tip says so, and what unticking it does (2026-11-17).
L.OPTIONS_RUN_FREE_TIP = "Drag the block by its header to anywhere on screen. On by default. Until you drag it, it waits by the quest tracker. Off, it sits by the quest tracker and moves with it. \"Inside the quest tracker\" wins over this."
-- The run block's dark mode: its gold art darkened, else the tracker's tint (UI/RunTracker.lua Paint), 2026-11-12.
L.OPTIONS_RUN_DARK_MODE = "Dark mode"
L.OPTIONS_RUN_DARK_MODE_TIP = "Darkens the gold of the run block's header and frame. Off, the block takes the look of your quest tracker's headers, so it is dark when your UI darkens them."
L.OPTIONS_RUN_SUMMARY = "Summary in chat"
L.OPTIONS_RUN_SUMMARY_TIP = "One line in chat a minute after a run's clock stops (sooner if you leave). A run you leave unfinished gets its line once it is over: when the dungeon is reset, or after half an hour away."
-- The run block inside the quest tracker: off by default (the owner's call of 2026-11-13; on in 0.39.22's tests), its tip warning of blocked actions in combat until a /reload once the block has been inside the tracker (the owner's words, 2026-11-13), its name marked as a test (UI/RunTrackerInside.lua), 2026-11-12.
L.OPTIONS_RUN_INSIDE = "Inside the quest tracker (test)"
-- Its tip: beside the tracker with this off only while "Place it freely" is unticked too, since that is on by default (2026-11-17).
L.OPTIONS_RUN_INSIDE_TIP = "The block goes into the quest tracker, right under \"" .. (TRACKER_ALL_OBJECTIVES or "All Objectives") .. "\", and the tracker's sections (" .. (TRACKER_HEADER_QUESTS or "Quests") .. " and the rest) move down below it. Off by default. A tracker you moved in Edit Mode is only as tall as its Height there: if that is too short to hold the block, the journal raises that Height in your Edit Mode layout once and says so in chat (you see it after a /reload; the button below does it again). Until then the block stays beside it, as it does with this off and \"Place it freely\" unticked. Once the block has been inside the tracker, it can cause blocked actions in combat until a /reload. This is a test. If the game reports a blocked action, it turns itself off. Once it has been used, it is fully off only after a /reload."
L.RUN_INSIDE_BLOCKED = "The game blocked an action of the journal (%s), so \"Inside the quest tracker\" is off now and the run block goes back beside the tracker. Please report this line. Type /reload to take it out of the tracker completely."
L.RUN_INSIDE_RELOAD = "\"Inside the quest tracker\" is off now, and the run block goes back beside the tracker. Type /reload to take it out of the tracker completely."
-- The tracker too short for the block inside: the Height it needs, and the options' Make taller button (UI/RunTrackerInside.lua), 2026-11-12.
L.OPTIONS_RUN_TALLER = "Make the quest tracker taller"
L.OPTIONS_RUN_TALLER_BUTTON = "Make taller"
L.OPTIONS_RUN_TALLER_TIP = "For \"Inside the quest tracker\": sets the quest tracker's Height in your Edit Mode layout to what the run block needs, and saves the layout. Only for a tracker you moved in Edit Mode. Use it while the run block shows, out of combat, with Edit Mode closed. You see it after a /reload."
L.RUN_INSIDE_SHORT = "The run block stays beside the quest tracker: the tracker is too short to hold it. To make it taller: %s, select the %s, %s %d or more. Or use \"%s\" in the journal's options (/aegis options)."
L.RUN_INSIDE_SHORT_TIP = "The quest tracker is too short to hold the block. To make it taller: %s, select the %s, %s %d or more."
L.RUN_TALLER_COMBAT = ERR_NOT_IN_COMBAT or "You can't do that while in combat"
L.RUN_TALLER_EDIT_MODE = "Close %s first."
L.RUN_TALLER_DEFAULT = "The quest tracker is in its default spot, where it reaches down the screen: it has no height to set."
L.RUN_TALLER_UNKNOWN = "Use this while the run block shows (in a dungeon, or your last run with /ij run): its height is measured then."
L.RUN_TALLER_ENOUGH = "The quest tracker is tall enough for the run block already."
L.RUN_TALLER_FAILED = "Your Edit Mode layout could not be changed from here. Set it yourself: %s, select the %s, %s %d or more."
L.RUN_TALLER_DONE = "The %s's %s is now %d in your Edit Mode layout \"%s\". Type /reload now to see it."
L.RUN_TALLER_MOST = "That is the most Edit Mode allows, so the block may still not fit."
-- The tracker's Height raised once by the journal itself when too short, 0.39.22 (UI/RunTrackerInside.lua AutoTaller), 2026-11-12.
L.RUN_INSIDE_AUTO = "The quest tracker was too short for the run block, so the journal changed its %s from %d to %d in your Edit Mode layout \"%s\". Type /reload to see it. You can set it back in %s."
L.RUN_INSIDE_SAVED_TIP = "Your Edit Mode layout now gives the quest tracker a %s of %d. Type /reload to see it."
-- Edit Mode opened before the /reload after the journal saved a Height: its old copy (UI/RunTrackerInside.lua EditModeEntered), 2026-11-12.
L.RUN_INSIDE_EDIT_MODE_OLD = "%s still shows the quest tracker's old %s until you type /reload. If you save anything there now, the old one comes back."
