# Changelog

All notable changes to **Aegis: Forever Instance Journal**.

Format loosely follows [Keep a Changelog](https://keepachangelog.com/).
The version here matches `## Version` in `Aegis_Forever_Instance_Journal.toc`
and the version shown in the AddOns list. Quote it in bug reports.

> ⚠️ Releases marked **restart** add a new file (a `.lua` file or a texture).
> The client reads those only at startup, so `/reload` won't pick them up: close
> the game fully and start it again. Everything else is `/reload`-safe.

---

## [0.40.1] (restart) - 2026-11-20

Every dungeon map has fog of war now: Alcaz Prison, Blackmaw Hold and the Shaper's Terrace get theirs, 34 dungeons in all. Each dungeon's loot is checked against what players have seen drop, and 31 dungeons get a Recipes page; Forever's newest dungeons list many more trash drops (only their own, not drops found all over the world), and Kroog and Sabella No-Eyes join as rares. On the Quests tab a dungeon quest shows the road that leads to it as one line instead of repeating every step from Before you go, and the Shaper's Terrace's six notes on summoning its bosses are one short note. The journal is in the minimap's addon menu too, and more bosses show their level.

This version adds new files: close the game fully and start it again. A /reload isn't enough.

The new words are drafted in the other languages, to be checked. Before you go's note on the Krol'dok Compound Key is still in English there.

### Added
- Fog of war on the last three dungeons without it: Alcaz Prison, Blackmaw Hold and the Shaper's Terrace. Every
  dungeon with a map has it now, 34 in all. In Alcaz Prison each boss clears his wing, and the stairs between the two
  levels are clear from the start and marked on the map both ways. In Blackmaw Hold each of the two ways through
  clears with its own beast, and Varrox Bleakhoof's kill clears every map whichever way you came. Each lower
  level's boss clears its passages; the Blackmaw Behemoth and the Unbound Spirit don't hold back the rest, as their
  kills count only when the journal sees their corpses. Both ends of Level 3's winding passage are clear from the
  start. On the Shaper's Terrace the five bosses that roam are optional, so they clear their own parts but don't
  hold back the rest: Nanaya's kill clears everything, and King Op's cave holds no fog, as he's a rare. The parts
  of each map are best guesses until checked in game.
- Recipes: a dungeon can list the recipes, plans and patterns that drop in it on a page of their own, one more
  entry in the boss list after the trash, with a recipe scroll for its picture. A boss's own recipe stays on its
  page too. Every dungeon has one but the Hall of Thanes, the Drowned City and Alcaz Prison. Search and item
  tooltips find them as they find other loot. The Gear Finder leaves recipes out.
- In Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold, the Shaper's Terrace and the Drowned City, the Trash page,
  and the Recipes page where there is one, list only the dungeon's own loot, dropped by its own creatures (in
  Blackmaw Hold a few of them also stand just outside the entrance), not the common drops found all over the world.
- Adventure Mode: a dungeon's Recipes entry stays hidden until you see one of its recipes drop there, so it doesn't
  give away that the dungeon has any. Then it shows, with the recipes you have seen.
- Recipes pages list, once each, Forever's recipes that drop off the bosses of several dungeons, marked "Any boss"
  where two or more of the dungeon's bosses drop them (the bosses drop them, not the trash), the bosses' own
  recipes, the recipes off the trash, and the enchanting formulas the journal already listed in the dungeon, plus
  four that drop in one dungeon alone (Mother Smolderweb's, Pyroguard Emberseer's, and one each off the trash in
  Scholomance and Stratholme). A recipe that only one boss or rare there drops is on his page too, and the
  dungeon's loot list names him.
- More loot that players have seen drop on Forever: its new blues off bosses and rares in Razorfen Downs,
  Maraudon, Uldaman, Zul'Farrak, Blackrock Depths, Scholomance and Stratholme; the bosses' own blueprints,
  schematics and formulas, with the reagents those bosses drop; the blue quest items for In Demand - Blackrock
  Legal Records and In Demand - Ancient Elven Curiosities, and a few more quest items; Quartermaster Zigris's set
  belts and bracers and Commander Springvale's Eerie Stable Lantern; and a Trash page for the Excavation Site with
  its creatures' six blues, and seven more trash blues in the City of Dalaran.
- Krol'dok Stronghold: Kroog, a rare, with his two blue drops. Where he spawns isn't known yet, so he has no spot on
  the map.
- Blackmaw Hold: Sabella No-Eyes, a fourth rare, with her two blue drops. Where she spawns isn't known yet either.
- Blackmaw Hold: every boss has its three blue drops now, the Blackmaw Behemoth and the Unbound Spirit for the
  first time, and the trash has its nine blues. Its Recipes page has the Pattern: Timbermaw Tunic and the Plans:
  Breastplate of Salvation, each dropped by one kind of creature in the hold.
- Krol'dok Stronghold: seven more blues off the trash, ten in all.
- Alcaz Prison: eight more blues off the trash, ten in all.
- Shaper's Terrace: six more blues off the trash, and Freya's Sigil, a blue quest item Nanaya rarely drops.
- The Drowned City: Linken's Boots of Iron, a blue that any of its bosses and rares can drop (about once in 100
  kills), is on the Trash page. The loot list and the item's tooltip say the bosses and rares drop it, not the trash.
- The journal is in the minimap's addon menu, the small numbered button that lists your addons, with its icon. A
  click there opens or closes the journal and a right-click opens its options, as on its minimap button. It stays
  in the menu when the minimap button is turned off. To take it out, untick "Show in the addon menu" in the
  journal's options; it leaves the menu after a /reload.

### Changed
- Loot is checked against what players have seen drop on Forever, dungeon by dungeon. Nothing comes off only
  because no one has seen it drop yet: such a row stays, with "Not seen dropping yet." in its tooltip outside
  Adventure Mode. The six crafted leather helms (Defender's, Totemic, Brawler's, Trapper's, Stormrider's and Wisdom's
  Leather Helm) are off the bosses, which drop their patterns; the patterns are on the Recipes pages. Recipes that
  several of a dungeon's bosses drop moved from their pages to the Recipes page; one that a boss alone drops there
  is on that boss's page too (Herod, Arcanist Doan, Houndmaster Loksey, Edwin VanCleef, Targorr the Dread,
  Archaedas and the Lordaeron Captain each have a group of them).
- Trash pages no longer repeat what only a boss drops (it stays on the boss) or list another wing's loot (it stays
  on that wing), and most quest items are off them. Recipes off the trash are on the Recipes page instead (books,
  such as the Librams and the class books, stay on the Trash page).
- Blackmaw Hold: Level 3's way back up to Level 2 is at the bottom end of its winding passage, most likely
  where the way in is (to be checked in game).
- Shaper's Terrace: Before you go has one short note instead of six, Summoning the bosses: each console boss's 15
  crystals and where its console is, a line each, then Nanaya's console. Cinder, Snowtalon, Bolt and Vitrix are no
  longer called hidden bosses. Their pages and Nanaya's show the same note.
- Item links in notes show a common item in white, as in the game, instead of the page's dark brown. A note with
  one gets the game's text shadow so the white reads on the parchment.
- Quests tab: a dungeon quest's + no longer repeats its road from Before you go. It shows one line for the road,
  with how far along you are, then only that quest's own steps (Krol'dok Stronghold, Onyxia's Lair, Alcaz Prison,
  the City of Dalaran, the Scarlet Monastery Library's mage quests). Clicking the line opens the road at the step
  the quest is waiting on. Krol'dok Stronghold, Horde: the road from Rog'mar now ends at Bring Me His Head, and It
  Is Time, Brother... is under Eye of Mugg's and Tome of Twilight's +. In Adventure Mode, when the only quest you've
  met is on a road, the tab opens that road in Before you go with that quest chosen.
- Krol'dok Stronghold: Before you go says where Tunk is, an elite ogre at his anvil a short way northeast of
  Handler Ashka, and that Tran'gul is in the building just north of Krom'rosh.

### Fixed
- Boss levels that were missing: Lyn the Ignored in the City of Dalaran; Var'Taka, the Primeval Elemental,
  Deathless Marrow and Min'loth the Serpent in the Drowned City; and Slavecrusher Grox, Twilight Commander Zarmok,
  Nar'gurk, Bossman Toof and Overseer Mugg in Krol'dok Stronghold. A boss whose level isn't known for sure yet
  still shows none.
- Blackmaw Hold: Varrox Bleakhoof's notes say the Mark of Xavius is for In Demand - Titan Relics.
- The Drowned City: the Ancient Gurubashi Idol drops from Deathless Marrow, not the Primeval Elemental. Marrow's
  notes and loot say so, and Marrow has the quest mark for both sides' quests for the idol. The Alliance's Ancient
  Gurubashi Secrets says so too.
- Shaper's Terrace: Nanaya's notes no longer mention the blueprint she drops, so Adventure Mode doesn't give it
  away before you have seen it.
- Alcaz Prison: the map's way down to the Maximum Security Unit is at the foot of the west stairs, where it really is.
- Excavation Site: the journal knows the Highland Horror by his creature id, so seeing him dead marks his kill in
  every language, and so does looting his corpse.
- The side tabs beside the journal (Overview, Loot, Abilities, Model, Quests) are drawn over its edge, as on retail,
  instead of under it, which hid their left side.
- On a boss's Overview, Spoken's play button no longer overlaps the scroll bar's up arrow.
- The loot filters: an armor type hides only the other armor types, no longer weapons, shields, jewelry, cloaks,
  trinkets, recipes or quest items, so a warrior with Mail chosen sees Edwin VanCleef's sword. A class shows what it
  can use as in Classic: no polearms for a druid, off-hand weapons only for a class that can wield two, and the
  cosmetic pieces a few factions sell at Revered for every class. An item the game hasn't loaded yet is judged by
  its slot until it has.
- On a loot list, a quest item, recipe, key or anything else that isn't gear names its type in your game's language,
  as gear does, instead of in English. A quest item says Quest Item, as its own tooltip does. In English too, such a
  row now names the type the way the game does, so a few read differently than before (food may say Consumable, for
  example).
- Loot rows' qualities, slots and names, from the game's own item data: 29 blues the journal had as green (on
  bosses in Maraudon, the Sunken Temple, Dire Maul and Stratholme), weapons that are Main Hand but were listed as
  One-Hand (and Jagged Bone Fist the other way round), the blueprints' professions and a few other slots, and the
  spelling of Hi-Tech Supergun and Blood-Etched Blade.
- Searching the game's options for some words, such as "name", no longer ends in a message that the journal was
  blocked from an action. The search still finds the journal's boxes, but no longer its buttons.

## [0.40.0] (restart) - 2026-11-18

Adventure Mode is a new journal style: the journal starts empty and fills in as you play, each character on its own. Dungeon maps get fog of war, 31 dungeons so far, always on in Adventure Mode and a box to tick in the other styles. The Shaper's Terrace is filled in, and Blackmaw Hold has its boss spots and models and the ways between its lower levels, with Varrox Bleakhoof as its last boss. Both are still marked Not yet tested, so some of what they show is a best guess. Krol'dok Stronghold's Before you go has each side's way in to its quests as a chain to do, and the quests of Krol'dok, Uldaman and Alcaz Prison are checked again. With the Gamepad UI on, the journal no longer leaves the pad stuck.

This version adds new files: close the game fully and start it again. A /reload isn't enough.

The new text is drafted in the other languages, to be checked.

### Added
- Shaper's Terrace is filled in: each boss's picture and model, notes, abilities and drops, its six
  quests, and each boss's spot on the terrace's map, where players have seen them in their runs (King Op
  most likely in the cave; where in it is a guess). The journal knows the dungeon and each fight by the
  game's own numbers, so kills count in the run block in any language. Cinder, Snowtalon, Bolt and Vitrix
  are called up with 15 Power Crystals of their color at a console: Before you go says where, and their
  pages say so too. Nanaya, the last boss, comes once those four are dead. The run counts 10 and ends at
  Nanaya; King Op is a rare and isn't counted, and Izha'Rel and Tor'Rel are most likely one fight,
  Ravasaur Hunters. Nothing here is checked in game yet: the door's place on the Un'Goro Crater map, the
  order of the list and the raptor pair are best guesses.
- Adventure Mode, a new journal style: the journal starts empty and fills in as you play. Each character
  has its own. New characters are offered it in the style question at their first login; a character that
  already answered that question isn't asked again. Any character can pick it at any time: Esc > Options >
  AddOns > Aegis Instance Journal, then Choose next to Journal style (or type /aegis style). Picking another
  style turns it off, and what you found is kept.
- In Adventure Mode a dungeon you haven't been inside is a rumor: its name, level range and where it is.
  Its bosses show as "???" until you meet them, their abilities once you fight them, and its loot item by
  item as you see it drop (the loot window, a roll, or a loot line in chat).
- In Adventure Mode a dungeon's or a boss's lore says "???" for a boss you haven't met or an item you haven't
  seen yet, as the rest of the journal does. While part of it is hidden, its words don't light up as Spoken
  reads it, though Spoken's Play still reads the whole story. A boss you haven't met shows his lore too, his
  full name in it as "???", under the line saying you haven't met him, with his Play button beside it.
  Spoken itself plays a boss's story only once you have met him, or at any time with its Unlock Unfound
  Bosses option on.
- In Adventure Mode the Quests tab and Before you go show a quest once you are offered it. Where the only
  quests you have found for a dungeon are a key's, under Before you go, the Quests tab opens on that quest. A
  faction shows once it is on your Reputation tab, and its rewards once you see them at its quartermaster.
- In Adventure Mode what a character did before counts: quests done and factions met right away, the
  flight paths you know as you open a flight master's map on each continent, and the bosses the dungeon map
  and the run block still keep as killed from your last run of each dungeon. Other old boss kills and old
  loot can't be known, so they wait for your next run.
- In Adventure Mode Search finds only what you have found. An item's tooltip says where it drops as far as
  you have seen it. The Gear Finder shows the upgrades you have seen drop; one you haven't seen is
  "Something better" in its dungeon, and one in a dungeon you haven't been to is a rumor, with Show on map
  for its door.
- In Adventure Mode the Gear Finder shows an upgrade you haven't seen by its slot's own picture from the
  character sheet (a helmet for the head, a ring for a ring) in its rarity's border.
- The Gear Finder's empty ranged slot shows the relic picture for classes that use librams, idols or
  totems, as the character sheet does.
- In Adventure Mode, on the world map, a dungeon's door is a rumor until you have been inside. Flight
  points show once you know the path. A dungeon quest you haven't been offered yet is a faint "!" with no
  name; once you are offered it, its mark is the full one.
- In Adventure Mode a quest's "!" and its objective marks on a dungeon's own map show once you have been
  inside, and only where the fog has cleared. A quest you haven't been offered yet is faint there with no
  name, as is a boss's quest badge for it.
- Fog of war on dungeon maps: where you come in is clear, and each boss your group kills clears its rooms and
  the way back. A dungeon's other maps clear once every boss on them is down, and once every boss is down the
  whole dungeon clears. Rare spawns and bosses you call up yourself hold back no fog at all: their spots clear
  with the rooms around them. Quest targets never keep the fog. 31 dungeons have it now: Ragefire Chasm, the
  Deadmines, Wailing Caverns, Shadowfang Keep, Blackfathom Deeps, the Stockade, Razorfen Kraul, Gnomeregan,
  the four wings of the Scarlet Monastery, Razorfen Downs, Uldaman, Zul'Farrak, Maraudon, the Temple of
  Atal'Hakkar, Blackrock Depths, Lower and Upper Blackrock Spire, all three wings of Dire Maul, Scholomance,
  Stratholme, the Hall of Thanes, City of Dalaran, the Ruins of Lordaeron, the Excavation Site, the Drowned
  City and Krol'dok Stronghold. More to come. Always on in Adventure Mode; in the other styles, tick "Fog of
  war on dungeon maps" in the options.
- In Krol'dok Stronghold, Bossman Toof's kill clears his bridges when the journal sees it, and Overseer Mugg's
  kill, with the bosses before him down, clears the whole map whether or not Toof's kill was seen. Where you
  come in, and how the journal sees Toof's kill, are best guesses until checked in game.
- Krol'dok Stronghold: Bossman Toof has his picture and model now, a big ogre warlord, in the boss list,
  on the map, in the run block and on the Model tab. The model is the one Forever's own data gives him; how he
  really looks is still to be checked in game.
- The Drowned City's hidden chest stays under the fog until the fog there is gone (once all five of its bosses
  are down), whenever the fog is on.
- The Drowned City: "Pyromancer" Braxton, a rare, with his two drops and a spot on the map in the pirates'
  part of the city, near Captain Dreadrise. Like the dungeon's other rares he isn't counted in the run and
  holds back no fog. His spot is a best guess, to be checked in game. The other languages have drafts of his
  notes, to be checked; the dungeon's other notes are in English there for now.
- The Drowned City's trash drops are listed: ten blue items.
- New in your journal: in Adventure Mode a line in chat names what you just found, and a click on a dungeon,
  boss, item, quest or faction opens its page. The minimap button glows until you next open the journal.
  Each has its own box in the options.
- Fog of War in the world map's legend, under Movement. Click it to turn the fog on or off for the map you're
  looking at, like the legend's other entries. On a zone it shows or hides the parts you haven't explored
  ("Show unexplored areas" in the options). On a dungeon's map with fog it turns the fog on or off (always on
  in Adventure Mode).
- Test mode, for testing (/aegis test, or Test mode at the bottom of the options): open any dungeon's map, fog and
  run block from anywhere, mark bosses defeated, and pretend you're inside. Nothing is saved; End test or a /reload
  ends it.
- Blackmaw Hold: a spot on Santiago Reyes's maps for Impaan the Imprisoner, the Unbound Spirit, the Blackmaw Behemoth
  and the Moontouched Wanderer, the ways between the depths' first three levels, and the hole behind the Behemoth
  that drops you down to Varrox Bleakhoof. An updraft in his pool takes you back up. The spots are best guesses,
  to be checked in game.
- Blackmaw Hold: two more rares, Gortek the Apprentice and the Tunnelweb Matriarch, each with its two known blue drops
  (that they are found here is a best guess), and the Lunarlight Robe from the Moontouched Wanderer: three rares in
  all. Notes on how to fight the Blackmaw Behemoth, Bonesnout the Unbroken and the Unbound Spirit, and on how to reach
  Varrox.
- Blackmaw Hold: its bosses and rares have their pictures and models now, in the boss list, on the map, in the run
  block and on the Model tab.
- Krol'dok Stronghold: Before you go lists each side's way in to the dungeon's quests as a chain to do, The road
  from Rog'mar and The road from Farholde Keep, with how far along you are. Its quests are marked on the world
  map where they are given and handed in.

### Changed
- The style question shows Classic, Modern and Adventure Mode side by side, with Custom as a bar beneath
  them. Adventure Mode docks the journal's window as Classic does, until you choose docking yourself
  (/aegis dock, or its box in the options).
- While the Gamepad UI's HUD mode is up, Show Map, the journal's options and trying an item on (Ctrl-click)
  stay shut, with a line in the chat saying why.
- Blackmaw Hold: Withermaw's spot moved to the north end of the Festering Grotto's east chamber, and Bonesnout's into
  his thicket below the bridge.
- Blackmaw Hold: Varrox Bleakhoof is its last boss now, not the Unbound Spirit. His kill stops the run's clock and
  shows Dungeon Complete!

### Fixed
- With the Gamepad UI on, the D-pad no longer stops working once you open a dungeon's or a faction's page,
  and the journal's top bar and its Show Map no longer leave the pad stuck (no jump or attack, the yellow
  arrow left on screen) until /reload.
- With the Gamepad UI on, the journal lets go of the pad as a fight starts, so jump and attack work while it
  stays open.
- The run block's gold frame no longer turns into a plain dark box when the block shows a dungeon with eight
  bosses or fewer after one with more (two rows of circles, such as Blackrock Depths or Scholomance) without a
  /reload in between.
- Quests of Krol'dok Stronghold, Uldaman and Alcaz Prison, checked again: in Krol'dok, Eye of Mugg and the other
  quests given only after a chain in the Riverglades no longer show as ready to take before it is done. The whole
  chain is under each one's "+", from its first quest: for the Horde, from Krom'rosh's A Message in Blood in
  Rog'mar, through the ogres of Sunnyglade's caves and Bolder'ok, to It Is Time, Brother...; for the Alliance,
  from Scraps of Knowledge or Saving Sunnyglade in Farholde Keep to Sergeant Riftan's Bring Me His Head, and Tome
  of Twilight after Curious Trinkets and A Small Favor. The lock line names the next step to do, each step has its
  own page, and the "!" at the giver stays gray until the chain is done. In Uldaman, Uldaman Reagent Run gives
  Greater Mender's Potions, The Lost Tablets of Will and The Hidden Chamber have their new reward choices, The
  Lost Dwarves' giver is where he stands, and Restoring the Necklace says to take it before you fight Archaedas.
  In Alcaz Prison, the Horde's State Secrets comes from Nazgrel in Orgrimmar, The Dragon's Journal goes back to
  Dalaran, more quests show their XP and money, and the notes say where Commander Folkar is chained, where Somber
  News and Bad News for Folkar start, how More Valuable Than Gold ends, and to hand in The Man in the Iron Chains
  together.

## [0.39.24] - 2026-11-18

### Added
- Alcaz Prison: each boss's three blue drops, as players have seen them drop, and a second blue off
  the trash, the Defias Enforcer's Mask. Drops nobody has reported seeing yet stay off the lists.
- Alcaz Prison: a spot for each boss on Santiago Reyes's two maps, and the stairs between the two
  floors. The spots are best guesses from the guides and the game's own rooms, to be checked in game.
- Alcaz Prison: inside, the map turns to the Maximum Security floor as you walk into it, by the
  game's own names for the prison's rooms.
- Alcaz Prison: the journal now knows the dungeon and each fight by the game's own numbers, so each
  kill counts in the run block as the fight ends, in any language, and the Record tab files the drops
  under their boss. Every boss has its picture and model. Blazeroar's fight, where you face Zarla Ober
  first, counts as one boss, once the dragon is down.

### Fixed
- Alcaz Prison: Sully McCleary hands out and takes back his quests behind Theramore's graveyard, not
  at the inn (all but Our Man in Theramore, which still ends at the inn, and Watch Yer Back, which
  still starts there). Their marks on the world map moved with him.
- Alcaz Prison: Somber News now also waits for The Secret Prison (to be confirmed). Blood Red Bandanas
  comes from Sergeant Ulka; that it waits for her earlier quests is a best guess. Several quests now
  show their XP, money and reputation.
- Alcaz Prison's notes: Katerina the Cleaner fights with poison and two healing chaplains, not fire;
  Zarla Ober turns out to be a dragon, without naming a color; and what the Overseer's Keyring opens
  is not confirmed yet.

## [0.39.23] (restart) - 2026-11-17

### Added
- Lore for 27 dungeons, Onyxia's Lair and 190 bosses: Spoken's own story of each, word for word,
  wherever Spoken tells it, so it matches what Spoken reads aloud. It shows on the dungeon's or boss's
  Overview, in place of the description, in every language Spoken has the story in, else in English.
  Krol'dok Stronghold, Blackmaw Hold and the Shaper's Terrace show Spoken's story of the place of
  that name. Where Spoken has no story, the description shows, as before. A boss's description
  moves to the top of the list under the Overview bar. A dungeon's practical words stay under its
  facts: City of Dalaran's way in, immunities and trash tips, the Excavation Site's areas, Onyxia's
  Lair's note, Stratholme's two gates, and each Scarlet Monastery and Dire Maul wing's own line, which
  tells it from the others. Spoken's author gave permission to use the stories, and you don't need
  Spoken to see them. With Spoken installed, the journal reads them from your copy, so they still
  match after Spoken updates them. The lore shows in the language Spoken shows it in. The map's
  boss pins keep the short description.
- A small Play button beside a dungeon's lore, and beside a boss's, for players who have Spoken. It
  plays Spoken's own recorded story of that dungeon or boss, through Spoken; click it again to stop.
  Without Spoken, or where Spoken has no recording, it is grayed out and its tooltip says why. A
  boss's button stays grayed out until Spoken's boss voices are installed. Like Spoken itself, it
  waits until your character has found the dungeon or met the boss, unless Spoken's settings unlock
  them. A later Spoken lets other addons play its stories: with it, the button asks Spoken itself.
- While Spoken reads a dungeon's or boss's story, the journal lights the words as they're spoken
  (Spoken's colors, when Spoken has the recording's word times).
- Krol'dok Stronghold: the way in on the Riverglades map, and what each boss and the creatures
  beside it cast, with the damage and timings of one recorded fight. From a player's recording.
- Krol'dok Stronghold: a picture and a model for each boss but Bossman Toof, whose look isn't known
  yet, and each boss's whole loot table, quest items and Mugg's key included, with Toof's three blues
  and two more Krol'dok Battlegear pieces from the trash (a best guess from the set). One drop per boss
  but Toof was seen in a recorded run; the rest come from drop lists, so check them in game. The Eye
  of Mugg quest now shows on Overseer Mugg, who drops the eye.
- Krol'dok Stronghold: Bossman Toof, between Nar'gurk and Overseer Mugg. Waves of adds come at you
  on the way to him. He is a warrior with Mortal Strike, Thunderclap and Demoralizing Shout, and two
  shamans and two brutes fight beside him. He counts in the run block, now out of 6, once you see him
  dead or loot him, in any language (his creature id is a best guess until checked in game). The
  other languages have drafts of his notes, to be checked.
- Krol'dok Stronghold: a spot on the map for each of the six bosses, a best guess from a player's
  combat log, to be checked in game.
- Krol'dok Stronghold: Overseer Mugg's weapon changes and Mugg's Fury on his Abilities tab. The
  changes likely come at set points of his health (a best guess). The other languages have drafts,
  to be checked.
- Razorfen Downs: Glutton drops the Abomination Chain. Tuten'kash's, Mordresh Fire Eye's, Glutton's
  and Amnennar the Coldbringer's pages say where they are fought.
- Scarlet Monastery: Herod drops the Band of Crimson Light and three recipes (Plans: Sentinel's Boots,
  Pattern: Skulker's Leather Shoes, Pattern: Black Cord). Herod's, High Inquisitor Fairbanks's and High
  Inquisitor Whitemane's pages say where they are fought.
- Scarlet Monastery: Interrogator Vishas drops Plans: Guard's Chain Helm. The bosses' abilities show
  the damage and timings of a recorded run, and five more abilities are listed: Arcanist Doan's Arcane
  Bubble, High Inquisitor Fairbanks's Dispel Magic, Scarlet Commander Mograine's Crusader Strike and
  Lay on Hands, and High Inquisitor Whitemane's Deep Sleep. The other languages have drafts, to be
  checked.
- Recipes seen dropping from more bosses in players' recordings: Lady Anacondra (Pattern: Filigreed
  Shining Gown, Pattern: Filigreed Pearly Gown), Wolf Master Nandos (Pattern: Defender's Leather
  Pants), Agathelos the Raging (Plans: Protector's Chain Helm), Overlord Ramtusk (Pattern: Brawler's
  Leather Helm) and Aku'mai (Plans: Veteran's Chain Helm).
- The Drowned City: the map marks the hidden chest on the wrecked boat past Min'loth the Serpent, and
  his page mentions it. It isn't locked: anyone can open it for random items and materials. The
  other languages have drafts of its tooltip, to be checked.
- City of Dalaran: six more rooms in the city turn the map to the city's floor.
- The Drowned City: Umbra, the rare, has a spot on the map, at the foot of the stairs up to Var'Taka
  in the Deep Archives. Just where by the stairs it stands is a best guess, to be checked in game.
- The Drowned City: what each boss and the creatures beside it cast, with the damage and timings of
  one recorded run and a player's combat log, and who should watch for each. Min'loth the Serpent's
  two stages. Captain Dreadrise's Embrine, the bubble that traps a player, is new. In other
  languages these texts and the dungeon's notes are in English for now.
- The Drowned City's map has two ways between the city and Atal'byzal, the sunken shrine below it,
  each with the delve icon at both ends: from the flooded room at the south-east corner of the Deep
  Archives to the south-west end of the shrine's long hall, and from the central pool to the
  north-east end of the shrine's passage. Each icon's tooltip says where it comes out, and a click
  turns the map to the other floor. Inside, the map turns to Atal'byzal in the shrine and back to
  the city everywhere else, the central pool (the Flooded Shrine) and spots with no name included.
  /aegis where says which floor the map takes where you stand, or that it isn't following the area
  while a floor you picked (or the whole map) shows.
- In languages other than English, the names of these Razorfen Downs and City of Dalaran rooms, of
  the Drowned City's areas, and of the creatures beside Krol'dok's and the Drowned City's bosses, are
  best guesses until checked in game.
- Powderfuse's quartermaster, Friz Frazzlespark in the Riverglades: his six wares, so Powderfuse's
  rewards are confirmed, with their prices and standings. From a player's recording. His card is on
  Powderfuse's page, after the standings, with his zone and Show Map; click it to see what he sells.
  His arrows, drinks, weapons and other everyday goods are left off. Other factions' pages are as
  before.
- Two small buttons on the run block, between the time and the boss count. The first starts the
  clock now, pauses it or resumes it. A paused clock is grayed, its time is not counted, and it stays
  paused after a /reload or a logout until you resume it. The second starts a new run: it asks
  first, then clears the run's kills and sets the clock back to 0:00, as /ij run new does. With
  "Inside the quest tracker" on, New run waits until you are out of combat. The other languages have
  drafts of their tooltips, to be checked.
- A lock on the run block's header, left of its collapse button, while the block is placed freely.
  Click it to lock the block in place: the padlock closes and dragging the header no longer moves the
  block. Click it again to unlock it. Each character keeps its own. /ij run lock and /ij run unlock
  now do the same; to put the block back by the quest tracker, untick "Place it freely" or type
  /ij run reset. The other languages have drafts of its tooltips, to be checked.

### Changed
- The Drowned City is no longer marked "Not yet tested": it has been run and checked in game.
- The run block's clock starts at the first fight inside: yours, a groupmate's near you, the start
  of a boss fight, or the first kill. Until then it reads 0:00, grayed, so waiting at the door for
  the group no longer counts. A new run waits for its first fight the same way.
- The run block is placed freely by default: drag it by its header. Until you do, it waits by the
  quest tracker, or left of the tracker's usual place while the tracker is hidden. When another quest
  tracker addon hides the game's, the block no longer sits on it. Untick "Place it freely" to put it
  back beside the quest tracker. With "Inside the quest tracker" ticked, the block goes inside it
  instead. If you had moved it in an earlier version, it goes back to where you left it.
- Blackfathom Deeps counts 7 bosses on the run block. Baron Aquanis, whom only the Horde calls up
  with a quest, has no circle and no place in the count. He gets his line once he is killed, as Lyn
  the Ignored does in the City of Dalaran.
- Shadowfang Keep counts 8 bosses on the run block. The Fel Steed / Shadow Charger and Arugal's
  Voidwalkers have no circle and no place in the count. Each gets its line once killed: the
  Voidwalkers' line comes with the first of them seen dead. Archmage Arugal still ends the run.
- Scarlet Monastery: Scarlet Commander Mograine and High Inquisitor Whitemane are one fight. Its end
  crosses out both, on the run block and the map, and the Cathedral's clock stops there. Mograine
  keeps his own circle. His page says he is fought in Crusader's Chapel.
- Before you go moved from a dungeon's overview to the top of its Quests tab, under the same bar. A
  key's or a chain's dropdown now holds its note's text and how far along you are, then its quests.
  A key no quest gives, a hidden boss or a plain note is a header with its text, folded until you
  click it. Clicking one only opens or folds it: the quest you chose stays chosen.
- Before you go's entries start folded on the Quests tab, keys and chains too; the dungeon's quests
  start open, with the first one you haven't done chosen. What you open stays open while you stay on
  that dungeon.
- In its place, the overview has one line under the dungeon's facts, such as "Before you go: 2
  notes, on the Quests tab." Click it to open the tab. It shows only when your side has notes.
- The Quests tab is on for a dungeon with notes, even one with no quests.
- The Quests tab: where a chain branches, the quests after each branch are listed under the quest
  they follow. In the Drowned City, Findings for the Explorer's League is under Take Two With Water,
  and The Web of Magic under Magics of the Drowned City, instead of rows of their own.
- Krol'dok Stronghold: Lingering Essence and Curios of Curiosity are listed under Twilight Mementos,
  the dungeon quest they follow. Quests with no giver listed now name who gives them, and where.
- A boss's Abilities tab no longer repeats his description at the top. Only the note on how the
  fight starts stays there. The description is on his Overview, as before.
- Vorrel's Revenge's 3,300 experience is confirmed on Forever, so it is no longer marked as the
  original game's.
- The Drowned City: the Primeval Elemental's kill counts as its fight ends, as the other bosses' do.
  Seeing it dead still counts it.
- The Drowned City's notes follow a player's combat log: Zul'Alai's Undying Oath comes about halfway
  through the fight, not near the end; anyone can break Captain Dreadrise's bubble; Min'loth's poison
  volley does not lower healing, and in his second stage he has a bite that heals him.
- Past Due's note: the book is picked up in the monastery, most likely in the Library. Arcanist Doan
  does not drop it.

### Removed
- The "Click to see it on the Quests tab." line in the tooltips of Before you go's quests: they are
  on that tab now.

### Fixed
- Show Map on a vendor's card read "Show..." in English: the game's own words for it break onto two
  lines. It now reads "Show Map" in full, on one line, as wide as a quest's Show End and in the same
  font, in every language (wider only where its words need it, as in German). The vendor's name and
  zone moved left to make room. /aegis buttons now also shows each button's words, font and anchors.
- Razorfen Downs: a boss seen dead or looted counts by its creature id, in any language, Ragglesnout
  too.
- The Record tab files drops from the loot history, and loot taken just after a kill, under the boss's
  English name on every client, as it already did for loot from a boss's corpse. On a client in
  another language they went under that language's name for the fight.
- The Record tab files Krol'dok Stronghold's boss drops under their bosses, not as trash.
- The boss level badges' option and the map legend's quest marks say "colored" and "gray" in their
  tooltips.
- The Web of Magic's note says "favor".
- City of Dalaran: Lyn the Ignored is no longer called a rare. He is a hidden boss you summon
  yourself, so the boss list shows his name without "(Rare)". His page, the run block and the map
  treat him as before.
- Scarlet Monastery: the run block now knows which wing you are in. The game gives all four wings one
  instance, and names no room at a wing's door, so the block reads "Which wing?" until you reach a
  named room of the wing, or one of its boss fights starts or ends. Then it shows that wing's run.
  Another wing than your last one is a new run: the Armory after the Graveyard no longer goes on
  with the Graveyard's run at 0:00. Going back into the same wing within half an hour, or a corpse
  run, keeps the run, as before, and a pull before the wing is known still starts the clock, also
  after a /reload. /ij run new before the wing is known starts a new run once it is.
- Scarlet Monastery: a boss killed where the game names no room, such as Houndmaster Loksey, counts
  for the wing you are in.
- Ruins of Lordaeron: the map shows the Crest of Lordaeron's fifth place, the East tower, and each
  crest mark's tooltip says where the crest is there.

## [0.39.22] (restart) - 2026-11-13

### Added
- The Reputation tab has a Vendors group after the factions, for vendors whose wares cost an item
  instead of a standing, one page for each such item. One is the Tarnished Undermine Real: Pix
  Xizzix in Booty Bay and his 25 wares, gear first by slot, each with its price in Reals. The page
  shows where he stands, with Show Map, and how many Reals you have. The class, armor and type
  filters work as on a faction's page. The Gear Finder does not look at these wares yet.
- Capture vendor keeps such a vendor too, and says what they take. A shop that sells only for gold
  is left out.
- The search finds these wares.
- Gorhak, the Magram Clan Quartermaster in Desolace, under the Reputation tab's Vendors: his 12
  recipes, formulas, plans, patterns and schematics, each for 15 or 60 Carved Centaur Totems, and no
  standing needed, as recorded in game. His page and card say where the totems come from: centaurs of
  any clan in Desolace, and the quest Khan Hratha.
- Rettrick, Gadgetzan's quartermaster in Tanaris: his six wares, so Gadgetzan's rewards are
  confirmed, with their prices and standings. Recorded in game.
- The Drowned City's map shows where each boss stands, from a run's combat log: Zul'Alai, Var'Taka,
  Captain Dreadrise, Deathless Marrow and Min'loth the Serpent in the city, and the Primeval Elemental
  at the round altar in Atal'byzal below it. Gill is in Atal'byzal too, on the way to the Primeval
  Elemental, in the passage that comes down from the north-east (just where in it is a best guess).
- The Drowned City's bosses, Gill and Umbra have their pictures (boss list, map pins and search)
  and their models on the Model tab.
- Blackmaw Hold's maps: six by Santiago Reyes, the whole hold, its cave (the Festering Grotto) and the
  four levels of the depths below, each named in the floor menu. Bonesnout the Unbroken is in his
  thicket, Withermaw in the grotto, Elder Shaman Bloodmane on Level 2 and Varrox Bleakhoof on Level 4.
  These spots are best guesses from the maps' drawings and a players' guide, until runs show where
  they stand. Impaan the Imprisoner, the Blackmaw Behemoth, the Unbound Spirit and the Moontouched
  Wanderer have no spot yet. The ways into the grotto and down into the depths show the cave
  entrance icon: click one to go to that floor. Inside, the map turns to the floor whose area you
  are in. Best guesses until a run is recorded: that the game calls the dungeon and its areas by the
  names on these maps. Where it doesn't, pick your floor from the menu.
- The quests The Drowned City (Horde) and Take Two With Water (Alliance): a mark at each of the four
  tablets of I'lalai, named in its tooltip for its rubbing (The First Tablet of I'lalai to The
  Fourth), numbered in the order of a recorded run. Each mark goes once you have made its rubbing.
  Which tablet is which, and where the first one stands (down the stairs on the left as you see the
  central pool), are best guesses.
- Alcaz Prison's way in for each side, as quests of their own. Alliance: Master Mathias Shaw in
  Stormwind gives Our Man in Theramore, then Sully McCleary in Theramore gives Watch Yer Back and The
  Return of the King?. Horde: Eitrigg in Orgrimmar gives The Missing Kor'kron, Nazeer Bloodpike in
  Brackenwall Village gives The Elite of the Elite (elite), and Sergeant Ulka on Alcaz Island gives
  Right Place, Wrong Time. Sully's The Secret Prison and A Bit of Wet Work, and Ulka's No Orc Left
  Behind and A Little Payback, need them first. The Quests tab shows each as a chain,
  Before you go lists them in order ("Mathias Shaw's errand", "Orgrimmar's errand"), and the world map
  shows their marks, from Shaw and from Eitrigg. Best guesses: the order of Sully's two quests, The
  Return of the King? handed in at the inn, and Ulka's quests waiting for Right Place, Wrong Time.
  Watch Yer Back has no hand-in spot yet, and The Return of the King? no spot where Sully gives it.
- Alcaz Prison (Alliance): Shaw Needs To Know, the chain's end. After Somber News, Sully McCleary sends
  you back to Mathias Shaw in Stormwind for 80 silver, 1,300 experience, Stormwind reputation and a
  choice of Courier's Clasp, Fatebound Buckler or Dustwallow Dirk. That Sully gives it is a best guess,
  and the experience is not yet confirmed in game.
- Alcaz Prison: the Alcaz Operative Insignia, a toy, as a chain under Before you go for each side.
  Skip The Questioner on your way in: at the end, Mason Connery sends you back for his key (The Man
  in the Iron Chains), then More Valuable Than Gold sends you to a box upstairs in Moonbrook's inn in
  Westfall, which gives the Document Box. Don't sell it: State Secrets takes it, from Renzik "The
  Shiv" at SI:7 in Stormwind (Alliance) or Rix Xizzix near Booty Bay's auction house (Horde), for a
  Fractured Insignia. Six of those make the toy, and they can be traded. The Quests tab and the
  world map show each step: the box's "?" once the quest is ready to hand in (most likely only once
  you find the box), and your side's State Secrets giver. Best guesses: State Secrets needs Mason's
  two quests done, and is handed back to the same person. Its gold and experience are not known yet.
- Alcaz Prison: The Questioner drops the Ornate Shackle Key for The Man in the Iron Chains, and his
  page says to skip him on your way in if you want the toy, or the Alliance's Somber News and Shaw
  Needs To Know, as they all need that quest. That line replaces the players' warning not to kill him
  before Blazeroar.
- The Quests tab: an item a quest's note names is a link. Point at it to see the item.
- Scarlet Monastery Library (mages): Mage's Wand, the end of Rituals of Power's chain. Tabetha in
  Dustwallow Marsh gives it once Rituals of Power and Items of Power are handed in: 3,150 experience
  and a choice of Icefury Wand, Nether Force Wand or Ragefire Wand.
- Items of Power, Tabetha's other quest for the wand, as a step of Mage's Wand's chain: a Jade and the
  Bolt Charged Bramble, made by using 10 Witherbark Totem Sticks at the Stone of Outer Binding in
  Arathi Highlands. Mage's Wand needs it: confirmed as part of the chain.
- Before you go on the Library, for mages: the road to Rituals of Power. Journey to the Marsh from a
  mage trainer, Hidden Secrets from Tabetha and Get the Scoop from Magus Tirth, in order, so that you
  have Rituals of Power before you reach the book. The Quests tab lists the three first.
- The world map shows Journey to the Marsh's "!" at each mage trainer who gives it, for mages from
  level 30 who haven't started it, until it turns gray for them: Jennea Cannon in Stormwind and Bink
  in Ironforge for the Alliance, Deino in Orgrimmar, Ursyn Ghull in Thunder Bluff and Anastasia
  Hartwell in the Undercity for the Horde. Then each step's marks follow, at Tabetha and at Magus Tirth.
- Shaper's Terrace: Cinder and Snowtalon have their pictures and models. This is a best guess: they
  come from creatures of the same names the game already knows.
- The Record tab notes the model of each creature you target in a dungeon, shows how many in its list,
  and Copy brings them along. That is how the new dungeons' bosses will get their pictures.
- Razorfen Kraul's bosses show the damage and timings of their abilities, and the adds that fight
  beside them, from a recorded run. Razorfen Spearhide is no longer a boss of its own: the two
  Spearhides are Overlord Ramtusk's guards, listed with his adds and their abilities, and his Model
  tab shows them beside him. Their Armor Piercer is with the trash drops.
- A line in chat when a world map addon known to hide the journal's maps is turned on, recommending
  turning it off. It shows once for each version of the journal.

### Changed
- Stratholme is one dungeon: one page with both sides' bosses, loot and quests. The boss list shows
  the Main Gate's side first, then the Service Gate's, each under a small heading. Its whole map shows
  every boss and every quest mark of both sides.
- The Eastern Plaguelands map shows both of Stratholme's entrances, the Main Gate and the Service
  Gate. Each one's tooltip says which it is, and a right click sets a waypoint to that entrance and
  names it in chat. When the journal sets a waypoint to Stratholme itself, it uses the Main Gate.
- The run block no longer lists rare spawns. A rare you kill was never counted, and now it gets no
  "defeated" line either. The Ring of Law's challengers, the Highland Horror and Lyn the Ignored,
  a hidden boss you summon in the City of Dalaran, still get theirs.
- A Stratholme run ends at Baron Rivendare. A run of the Main Gate's side only ends its clock when
  you leave.
- Stratholme's Before you go lists both keys first, The Scarlet Key and the Key to the City, then
  Postmaster Malown, then Jarien and Sothos.
- Kills, runs and loot pins saved on the two old Stratholme pages carry over.
- The Drowned City: the Primeval Elemental is a fight of its own. Gill is a rare and Umbra a new rare,
  each with new notes and an ability (Throw Dynamite; Bleed, from Umbra's murlocs). Zin'aka, the shark
  in the central pool, is off the boss list and the map until it has a purpose: it drops no loot yet.
  New notes for each fight.
- The Drowned City's bosses, Gill and Umbra have their full drops, two or three each, and the right
  creature ids.
- The Horde's quest The Drowned City no longer needs an earlier quest. The Alliance's Take Two With
  Water still needs An Acquaintance in Southshore.
- Alcaz Prison (Horde): Before you go calls Sergeant Ulka "she", as the game's quest text does.
- The world map: where two gray "!" stand on one spot, the one that waits only on your level shows
  (Our Man in Theramore at Mathias Shaw, not State Secrets at Renzik beside him).
- "Inside the quest tracker" is still off by default, and its name says "(test)" instead of
  "(experimental)". Its tip now says that once the block has been inside the tracker, it can cause
  blocked actions in combat until a /reload. If you ticked it, it stays on.
- With "Inside the quest tracker" ticked, if a quest tracker you moved in Edit Mode is too short for
  the run block, the journal now raises its Height in your Edit Mode layout by itself, once, out of
  combat and with Edit Mode closed. A line in chat gives the old and new Height. You see it after a
  /reload, and you can set it back in Edit Mode: the journal then leaves it as you set it. It never
  changes one of the game's own layouts. "Make the quest tracker taller" in the options still does it
  on demand. If you open Edit Mode before the /reload, a line in chat says it still shows the old
  Height and that saving there puts it back; if that happens, the journal raises it again once in
  your next session.
- If the game blocks an action of the journal before the run block has gone inside the tracker
  since you logged in or typed /reload, "Inside the quest tracker" stays on: only a blocked action
  after it went in turns it off. A blocked action before then, after the journal changed your Edit
  Mode layout, is only noted in /ij run debug.
- The run block's header matches the tracker header it sits next to: like "All Objectives" above
  the tracker or placed freely, like "Quests" under the quests or inside the tracker.

### Fixed
- Show Map on a vendor's page (new in this version) showed its name on two lines, spilling out of the
  button. It now keeps its name on one line, though on a vendor's card it can still be cut short
  ("Show..."): the next version fixes that. Show Start and Show End on a quest's page keep their names
  on one line, whole, in every language, and widen where the name is longer (German, Spanish,
  Portuguese and Russian). /aegis buttons lists each map button's label and width, and whether the
  label is cut short, for checking in game.
- A faction's page shows wares captured after it was first opened, without a reload.
- Grime-Encrusted Ring gives 6,400 experience. The 6,592 before was read through a +3% experience
  buff.
- The Sparklematic 5200! gives 2,450 experience on Forever, so it is no longer marked as the original
  game's.
- Mortality Wanes gives 7,250 experience on Forever, not the original game's 3,050. Read from a
  recorded hand-in, less a +3% experience buff, and confirmed.
- The Glowing Shard's 5,150 experience is confirmed in its quest window.
- An Unholy Alliance gives 5,900 experience, as its quest window shows, not 2,800.
- The Record tab also saves the experience the quest window shows. The window's number most likely
  leaves out experience buffs; the experience you get at the turn-in counts them.
- A quest you recorded shows the experience from its quest window first.
- The journal's options (Options > AddOns) no longer cut off their names with "...", in any language.
  A few names are shorter, and their tooltips say the rest.
- Lonebrow's Journal's mark is where the journal lies, on Darkcloud Pinnacle in Thousand Needles.
  The world map now shows its "!" there, as the game's own map shows nothing for it. It goes once the
  journal is in your bags, waiting to be read.
- Russian: Moonbrook's name in "Moonbrook Espionage" and in The Deadmines' description (it read as
  Moonglade's).
- The Drowned City and Krol'dok Stronghold: a boss you kill there is crossed out on the map and
  counted by the run block, in any language. The journal did not know when you were inside them, so
  no kill counted. The game's numbers for them come from a player's recording. The fight the game
  calls Deathless Guardians counts for Deathless Marrow. The Record tab files The Drowned City's boss
  drops under their boss, no longer as trash.
- Alcaz Prison, Blackmaw Hold and Shaper's Terrace: until the journal has the game's number for them,
  it knows you are inside one when the game calls it by the journal's name for it. Then, from the
  day they open, their kills count, the run block starts and the world map shows the dungeon's own
  map. That the game calls them by these names is a best guess until a run is recorded. In another
  language this works where the journal's name for the dungeon is the game's.
- Blackfathom Deeps: Lorgus Jett is crossed out and counted once you see him dead (target or loot
  him). The game starts his fight but never ends it, so his kill never counted.
- The Ring of Law in Blackrock Depths: the challenger you kill gets his line in the run block once
  you target or mouse over him dead, on an English client. It never came before.
- Shadowfang Keep: the Fel Steed / Shadow Charger counts when you target or mouse over a dead Shadow
  Charger, on an English client, not only a Fel Steed.
- On an English client, the run block crosses out the Sunken Temple's dragons even if the game names
  their fights in pairs there (Dreamscythe and Weaver, Morphaz and Hazzas), and Jammal'an, Ogom and
  the balcony trolls the same way. Not yet checked in game.
- On an English client, Uldaman's Lost Dwarves are one fight: winning it crosses out Eric "The
  Swift", Olaf and Baelog. Scholomance's Kirtonos the Herald and Ras Frostwhisper count by the game's
  names for their fights too. Not yet checked in game.
- Pulling the Lost Dwarves, or one of the temple's paired fights, again after a wipe, with one of its
  bosses still standing, no longer starts a new run.
- Ragefire Chasm, Razorfen Downs and Scarlet Monastery: kills count by the game's own number for each
  fight, from a player's recording, so in any language, not only by the fight's English name. Seeing
  the boss dead still counts it too.
- Wailing Caverns: Lord Pythas's and Skum's pages say the Winding Chasm, where all three recorded
  runs met them (they said Pit of Fangs and Crag of the Everliving).
- Russian: Wailing Caverns' bosses, two of its creatures, Dreamer's Rock and the notes that quote them
  use the game's own names (Леди Анакондра, Криг, Лорд Питонас, Шкам, Вердан Вечноживущий), as a
  player's recording read them. Some spell names in the notes too.
- Razorfen Kraul's map: Charlga Razorflank stands in her room, and Roogug and Earthcaller Halmgar
  where they are found.
- Razorfen Kraul's entrance pin is at the portal.

## [0.39.21] (restart) - 2026-11-12

### Added
- Gnomeregan's map opens on a map of the whole dungeon, each boss's pin on his skull. Its four floors
  are still in the floor menu. Once you pick a floor, the map turns to The Hall of Gears or Tinkers'
  Court as you walk into their rooms. The other rooms lie on two floors, so the floor you picked stays.
  Where the Dark Iron Ambassador, a rare, stands is a best guess.
- Gnomeregan's way-in map shows Techbot and Matrix Punchograph 3005-A.
- Data Rescue: a mark at each of the four Matrix Punchographs, showing the punch card it takes. Its
  tooltip names the card in and out, such as "Blue > Red". Each mark is gone once you have the card
  it gives. The three inside Gnomeregan are best guesses.
- The Sparklematic 5200 keeps a mark once The Sparklematic 5200! is done: the game's blue mark for a
  repeatable quest, to put in another Grime-Encrusted Object.
- Kernobee (A Fine Mess) is marked in the Dormitory's east rooms. This is a best guess.
- The whole-dungeon maps (Blackfathom Deeps, Shadowfang Keep, Maraudon, Stratholme) show the same
  quest marks as each floor's map.
- Dark mode for the run block: its header takes the tint of the quest tracker's header bars, and its
  button the tint of the tracker's buttons, so a UI that darkens the tracker's headers darkens the
  block's header the same way. The box keeps its gold frame. "Dark mode", under the run tracker's box
  in the options, darkens the header without one.
- An experimental option, off by default: "Inside the quest tracker (experimental)" puts the run
  block inside the quest tracker, under "All Objectives". If the tracker is too short or hides itself,
  the block stays beside it, and /ij run debug says why. If the game reports a blocked action, the
  option turns itself off and says so in chat. Once used, it is fully off only after a /reload.
- A tracker you moved in Edit Mode is only as tall as its Height there. When it is too short for the
  block, a line in chat (once a session) and the block's tooltip say which Height fits it. "Make the
  quest tracker taller", a button under the option, saves that Height in your Edit Mode layout (with
  the option ticked, out of combat, Edit Mode closed). It takes effect after a /reload.
- Stondry Darkhammer's new plans for the Cracked, Mithril and Arcanite Blacksmith Hammers (30, 60 and
  90 Merchant's Favor; the Mithril one needs Friendly, the Arcanite one Honored). Alynsia's Formula:
  Enchant Boots - Speed (180 Merchant's Favor, Honored).

### Changed
- The run block's header looks like the quest tracker's section headers, such as "Quests", with
  their thin line and their own button to fold it away. It still shows the dungeon's name.
- Gnomeregan's run counts 5 bosses. Techbot stands outside the instance, so he is not in the run.
- Techbot and the Excavation Site's Highland Horror are off the boss lists. They stay on the map with
  a quest badge, grayed out when there is nothing to do for the quest. Click the pin to open the
  quest; its tooltip shows the notes on the fight.
- Gnomeregan's quest chains are joined: Gnogaine is under The Only Cure is More Green Glow, and
  Grime-Encrusted Ring and Return of the Ring under Gnome Improvement or Nogg's Ring Redo. Click the +
  to see them.
- Boss abilities: Gnomeregan has damage and timings from a recorded run for the first time.
- Gnomeregan: More Sparklematic Action, the repeatable quest, is off the list.
- Reputation pages: "Any standing" lists recipes and plans first, by profession from A to Z, then the
  rest. Within each, gold comes before Merchant's Favor, then the lowest cost first.

### Fixed
- Reputation pages list the wares a quartermaster sells that need no standing too, under "Any
  standing" with their price, such as Stondry Darkhammer's 30-Favor plans and the Blacksmithing
  Certification. The Silverwing Sentinels', League of Arathor's and Theramore Expeditionary Force's
  pages may miss such wares until their quartermasters are captured again.
- Kalsey Sanden's and Aza'bek's everyday goods (water, spices, flour, wood and the like) are off the
  reputation pages. Their recipes stay.
- The Sparklematic 5200's mark is where it stands, in the passage between the Clean Zone and The Hall
  of Gears.
- Grime-Encrusted Ring gives 6,592 experience, as recorded in game. The journal said 2,700.
- Gnome Improvement's 2,750 experience is no longer marked as the original game's: it is Forever's.
- Gnomeregan's way-in map now shows by itself in the tunnels outside the dungeon.
- Dragging the run block with "Place it freely" no longer jumps back to its old spot.

## [0.39.20] (restart)

### Added
- A dungeon run tracker. Inside a dungeon, a block beside the quest tracker shows the dungeon's
  bosses as round portraits, crossed out as they die (as on the dungeon map), and as tracker lines
  that turn from "0/1 Gilnid defeated" to "1/1". Its bar fills one step per boss killed, and its
  clock shows how long the run has taken. Under them: experience and money (coin looted plus what
  your items sell for), each with its rate per hour once the run is a minute old, and how many items
  you got.
- In a dungeon with more than 8 bosses, the lines show the next 8 still standing and your last
  kill. The portraits still show them all.
- The clock stops at the dungeon's final boss. A minute later, or as you leave if that comes first,
  one line in chat sums up the run, his loot included. Which boss is the final one is our best
  guess for now in each dungeon: tell us if one is wrong.
- The block has its own header, like the quest tracker's "All Objectives" one, with the dungeon's
  name and the same button to fold it away. It sits above the quest tracker where there is room
  (move the tracker down once in Edit Mode to make room), else under it, and moves with it.
  "Place it freely" lets you drag it anywhere. It is on in every style; one box in the journal's
  options turns it off. /ij run hides or shows the block (outside a dungeon, your last run), /ij run
  new starts a new one.
- Quest marks inside dungeons, on each floor's map: a "!" or "?" where someone inside gives or takes a
  quest, and the game's In Progress mark on what you loot, use or explore for one, such as the Pitted
  Iron Chest in Blackfathom Deeps. That mark is full while the quest is in your log, faded before you
  take it, and gone once you have what you came for or the quest is ready to hand in. Its tooltip says
  what to do there, like "- Take the Lorgalis Manuscript". A mark that would cover a boss's portrait
  stands beside it. Many spots are best guesses still to be checked in game.
- A quest badge on a boss's pin on the dungeon maps and on his portrait in the boss list, when one of
  your quests needs him: to kill, for something he drops, for a drop that starts a quest, or someone
  there gives or takes a quest. It is faded before you take the quest and full while it is in your
  log. It goes once the quest is ready to hand in or done, or once you have what he drops for it. His
  tooltip names the quest and says what he is to it, like "Drops the Horrible Rootcore".
- The tooltip of a quest mark you can't take yet says why: "Requires level X", and "Requires:" with
  the quest you can do next to open it (a few, where they can be done side by side). On a dungeon's
  own map, these marks and badges show even when the quest is more than 2 levels above you; the world
  map still shows a gray "!" only once you are within 2 levels of the quest.
- Warsong Gulch's two factions on the Reputation tab. The Silverwing Sentinels come with their
  quartermaster, Illiyana Moonblaze, and her rewards, with their prices and the standing each needs.
  The Warsong Outriders wait for theirs to be captured.
- Before you go has four new notes: Scholomance's Viewing Room Key, Stratholme's Scarlet Key and
  Postmaster Malown, and Uldaman's Keystone (the Staff of Prehistoria that opens Ironaya's door).
- A Green Sample says where to find the Fel Infused Blossom: on the ground near the Fel Ancient.

### Changed
- Show Map on The Temple of Atal'Hakkar, Razorfen Downs, Blackrock Depths and Blackrock Spire opens
  the dungeon's own map, as it does for every other dungeon. Their way-in maps are still on the zone maps.
- Inside City of Dalaran, the map opens on the floor you are on, the sewers or the city, and turns
  with you as you climb out of the sewers or go back down.
- Stratholme, Blackrock Spire and Dire Maul count as one run across their parts: a new run clears
  the kills of every part, and coming back in by another gate within half an hour keeps them.
  Scarlet Monastery's wings stay separate.
- Excavation Site: the Highland Horror is a quest target now, not one of the dungeon's bosses. He keeps
  his notes and loot, wears the quest badge and is tagged "(Quest)" in the boss list. The run tracker
  leaves him out of its count and gives him a done line once he is down.
- The world map's gray "!" says both the quest to do next and the level its quest needs, not just the
  first of them.
- Boss abilities: City of Dalaran has more damage and timings from a recorded run.

### Fixed
- Gnomeregan: Viscous Fallout's pin is on the second floor's map, in the Hall of Gears, where he is.
- Return of the Ring gives Forever's 4,850 experience.
- Blackrock Spire: The Matron Protectorate is on Upper's list only, and Lower's own quests (Bijou's,
  Mother's Milk, The Final Tablets and the rest) on Lower's only. The Matron Protectorate's next steps
  name the chain's last two quests.
- Stratholme: The Great Fras Siabi is The Great Ezra Grimm, as Forever names it.
- Franclorn Forgewright's ghost is in Blackrock Mountain, not the Burning Steppes, and only the dead
  can see him.
- Elemental Aid (Horde shamans) is turned in to Bath'rah the Windwatcher in the Alterac Mountains, and
  Prate Cloudseer gives it too.
- Crest of Lordaeron: Lady Dena Kennedy's pin is where she stands in the Royal Gallery.
- Falrin's Vendetta: Lower Blackrock Spire's Spirestone ogres drop the warbeads too.
- French, Russian and Simplified Chinese name Orphan Matron Nightingale and Bath'rah the Windwatcher
  as the game does.
- The Record tab no longer credits loot from a plant or chest opened right after a kill to the boss.
- The Sunken Temple's balcony trolls are marked killed on the map once all six have been seen dead.
- Ruins of Lordaeron: Captain Truman's mark is where he stands.
- Excavation Site: the Highland Horror shows as done once his Horrible Rootcore is in your bags or his
  quest's objective is complete, even when the journal didn't see him die.

## [0.39.19] (restart)

### Added
- Two more quartermasters: the Theramore Expeditionary Force's (Bryanna Embreeze) and the League of
  Arathor's (Samuel Hawke). Where they stand and their rewards, with their prices and the standing
  each needs, in place of those factions' unconfirmed lists.
- More Forever recipes on the bosses that drop them: Old Serra'kis, Lady Sarevess, Cookie, Hamhock,
  Lady Anacondra, Odo the Blindwatcher and Fenrus the Devourer.
- The Baron drops the Head of the Baron, and the Shade of the Archmage the Arcane Mote.
- Death Bindings on the Ruins of Lordaeron's trash, and the Violet Sorcerer's Leggings and Wraps on
  City of Dalaran's.
- Unending Torment's parts 2, 4 and 5 say what to do, and Remember That I Love You says where its
  chain goes next.

### Changed
- The dungeon map shows a run's kills only while you are in that dungeon; seen from anywhere else, its
  map is clean.
- Stepping out of a dungeon and back in within half an hour (to repair, or to wait for your group)
  keeps its kills marked. Coming back later, or after you reset the dungeon, starts a new run.
- Boss abilities: damage, timings and adds from recorded runs. Shadowfang Keep, Wailing Caverns,
  The Deadmines and Ruins of Lordaeron have them for the first time; The Stockade, Hall of Thanes,
  Blackfathom Deeps and the Excavation Site have more.
- Shaper's Terrace has Santiago Reyes's updated map, and a second floor for its cave, the Prismatic
  Talus. A cave icon on the terrace's map leads down to it.

### Fixed
- Remember That I Love You gives 6,200 XP, not 2,600.
- Rear Guard Patrol: the second part needs the first, and both give Undercity reputation.
- Past Due: Magus Olvek's spot on the map.
- Item colors: 19 items show as rare, not uncommon, in Blackfathom Deeps, Shadowfang Keep, Wailing
  Caverns, the Cathedral, Razorfen Downs, Uldaman, Zul'Farrak, Maraudon and Stratholme; Rift Bracers
  shows as uncommon.
- Stratholme's two wings show their own loading screen on the dungeon list, not the stand-in picture.

## [0.39.18] (restart)

### Changed
- Alcaz Prison, Krol'dok Stronghold and Blackmaw Hold have their loading screens as their
  pictures: on the dungeon list, the round icon and the overview.

### Fixed
- The world map no longer shows flight points Forever doesn't have: Eastern Plaguelands' four
  towers (Light's Hope Chapel is its only one), and three old Riverglades points that sat on top of
  Southshore's, Thorium Point's and Ratchet's.

## [0.39.17] (restart)

### Added
- Alcaz Prison lists all its quests. For the Alliance: Sully McCleary's in Theramore (his errand at
  Jaina's tower is under Before you go) and the news of the King. For the Horde: the Kor'kron's,
  from Sergeant Ulka and Commander Folkar, A Little Payback and Blood Red Bandanas. And State
  Secrets for each side.
- Blackmaw Hold: Blackmaw Reclamation, The Twin Bears, A Lost Memento and Blackmaw Pouches, the
  Blackmaw furbolgs' quests at Ursolan and the Ruins of Eldarath.

### Changed
- The Drowned City's quests show the money, item choices and reputation they give, and The Only
  Good Brinescale... also needs Locating the Lost City.
- Alcaz Prison: players warn not to kill The Questioner before Blazeroar, the last boss, or the
  last quest can't be had. His page says so.

### Fixed
- Wailing Caverns shows its map as Forever has it, with the Winding Chasm in the east, and its boss
  pins match: Lord Pythas and Skum are back in the Winding Chasm, Kresh is in the river, and Lady
  Anacondra has one pin instead of four.

## [0.39.16] (restart)

### Changed
- The Scarlet Monastery Graveyard and Library now show the original Scarlet Monastery picture. The
  game had been showing its newer painting of the courtyard, which is now the Cathedral's. The
  Graveyard's picture is a darker moonlit blue instead of grey.

## [0.39.15] (restart)

### Added
- Scarlet Monastery: the Armory and the Cathedral have pictures of their own, from their loading
  screens, on their buttons, icons and overviews.

### Changed
- Every dungeon's overview shows its picture in the same framed size. The dungeons that had the
  game's tall journal picture show it cut to that frame.
- The Scarlet Monastery Graveyard and Library keep the monastery's picture, the Graveyard's now in
  grey, so the two wings look different.
- Dire Maul's three wings each show their picture in a colour of their own: East green, West blue
  and North amber.

## [0.39.14]

### Changed
- Krol'dok Stronghold: the Krol'dok Moulding drops from Tunk, the blacksmith in Krol'dok, when he
  is killed, one for everyone in the group. Obsolete found where it comes from. Thank you again!

## [0.39.13] (restart)

### Added
- Alcaz Prison's second level, the Maximum Security Unit, from Santiago Reyes. The map's floor menu
  switches between it and the Main Unit.

### Changed
- Krol'dok Stronghold: the Krol'dok Compound Key now says where the Krol'dok Moulding comes from:
  Tunk, the blacksmith in Krol'dok. Everyone in the group gets one.

## [0.39.12]

### Fixed
- Opening a dungeon's floor menu on the world map's top bar (Shadowfang Keep's, for one) no longer
  shows a Lua error. Its arrow is now the journal's own.
- The arrows on the journal window's own top bar (the lists of dungeons and bosses, and the button
  that appears when the steps don't fit) now open the journal's own menus too. They still used the
  game's menus, which could block raid icons the same way 0.39.9 fixed.

## [0.39.11] (restart)

### Added
- Alcaz Prison has Santiago Reyes's map. It also lists its bosses (Overseer Wrex, The Questioner,
  Tidemistress Ca'zass, Katerina the Cleaner and Blazeroar), the drops players have seen so far
  and notes on each fight. Overseer Wrex's keyring, which opens the lower floor, is under
  Preparation.
- Blackmaw Hold lists its bosses, the Moontouched Wanderer rare and the drops seen so far, with
  notes on the fights and the two ways through the hold.
- The Drowned City and Shaper's Terrace show their loading screens as their pictures.

### Changed
- The maps of The Drowned City (both floors), Krol'dok Stronghold and Shaper's Terrace are rebuilt
  from Santiago Reyes's full-size originals, so they are sharper. The Drowned City's map now names
  the Abyssal Dais and the Eternal Amphitheater.
- The Dragon's Journal says where Zarla's Journal drops: from Blazeroar, the last boss of Alcaz
  Prison.
- Neither dungeon is open to everyone yet, so bosses, drops and order can still change.
- Ruins of Lordaeron: two Horde quests now need others first, new since the beta. The Wrath of
  Rath'mael comes after Deathguard Linnea's two Rear Guard Patrol quests beside Brill; Obsolete
  found it and joins the contributors list. Thank you! The New Plague comes after the three
  A Recipe For Death quests from the Sepulcher and the Undercity. Both now show those quests.

## [0.39.10]

### Changed
- The Drowned City: An Acquaintance in Southshore now shows the quests before it, from Brother
  Nimetz's chain at the Rebel Camp: The Second Rebellion, Bad Medicine, Kurzen's Mystery and
  Troll Witchery.

## [0.39.9]

### Fixed
- Raid icons and the right-click menus of players and targets no longer get blocked after you use
  one of the journal's menus. Its menus (the dungeon list, the loot filters, the Gear Finder, the
  floor menu on the world map and the menu of a door shared by several dungeons) are now its own,
  drawn like the game's.

### Changed
- "Show unexplored areas" moved from the world map's filter menu to the journal's options, under
  the map markers. The map legend still shows and hides each kind of marker.
- The journal style in the options is now a button that opens the style question.

## [0.39.8]

### Added
- Quests for three dungeons that aren't open yet, as the game has them so far:
  - Krol'dok Stronghold: Eye of Mugg for each side, Vengeance of the Highborne, Tome of Twilight for
    each side, A Token of Vengeance, and Twilight Mementos with its two follow-ups in Farholde Keep.
    Before you go shows the Krol'dok Compound Key and the two quests that make it, for each side.
  - Alcaz Prison: The Dragon's Journal, The Man in the Iron Chains and More Valuable Than Gold.
  - Blackmaw Hold: Get to the Roots of It and Blackmaw Magic for each side, and Claws That Rend,
    Tusks that Gore.
  Nobody has run these dungeons yet, so the quests can still change. Where a quest's giver isn't
  known yet, its page says so.

### Fixed
- Bosses killed on the dungeon map stay marked after a /reload or a relog inside the dungeon. Until
  now a /reload forgot them. Going in from outside still starts a new run.

### Changed
- Uldaman: The Lost Dwarves is listed again. You find Baelog inside the dungeon, so it counts as one
  of its quests.

## [0.39.7]

### Added
- The Drowned City's Alliance quests from Southshore: An Acquaintance in Southshore, Take Two With
  Water and Magics of the Drowned City, then Findings for the Explorer's League and The Web of Magic
  with their rewards, and Ancient Gurubashi Secrets from Archmage Timear in Dalaran. Also Krazek's
  two quests in Booty Bay for both factions: Shady Saltseers and The Saltseer Captain.
- Forever's new quests in dungeons that were missing from the journal:
  - Razorfen Downs: The Coldbringer's Eye, from Archmage Lan'dalock in Dalaran for the Alliance and
    Sutara Plainstalker in Mulgore for the Horde, and Agamaggan's Blood for Kog'thug the Brave in
    Desolace.
  - Zul'Farrak: The Witch Doctor's Head (Alliance) and Zum'rah's Head (Horde).
  - Maraudon: Rot and Regret, after Word of the Woods, and An'she's Radiance (Horde).
  - Blackrock Depths: Fragment of the Firelands (Horde).

### Changed
- Blackfathom Deeps: In Search of Thaelrid is listed again. You find Argent Guard Thaelrid inside
  the dungeon, so it counts as one of its quests.

## [0.39.6]

### Added
- The Drowned City: its entrance on the Stranglethorn Vale map (the cavern of Sunken Hollow, under
  the sea west of the Vile Reef), a short note on each fight, the rare drops players have seen so
  far, and the Horde quests that lead to it: The Vile Reef, The Gurubashi Legends of Old, Locating
  the Lost City and Enemies in the Water.

## [0.39.5] (restart)

### Added
- Santiago Reyes's new maps: The Drowned City, with Atal'byzal as its second floor, Krol'dok
  Stronghold and Shaper's Terrace. Show Map opens them from each dungeon's page.
- Krol'dok Stronghold and Shaper's Terrace list their bosses, as named in the game's files. Their
  pages fill in as runs are recorded.

### Changed
- The Drowned City lists six bosses: Zul'Alai, Var'Taka, Captain Dreadrise, Deathless Marrow,
  Gill and Min'loth the Serpent. Var'Taka replaces Zin'aka. None of these dungeons is open yet,
  so names and order can still change.

## [0.39.4]

### Changed
- Inside The Deadmines, the map opens on the part you are in, the mine or Ironclad Cove, and turns
  with you while it is open. Picking a part from the map's menu keeps it until you close the map.
- The Deadmines' loot now lists three quest items: the Head of VanCleef from Edwin VanCleef, the
  Gnoam Sprecklesprocket from Sneed's Shredder, and the Whitestone Oak Lumber that Goblin Woodcarvers
  drop.
- Rhahk'Zor and Miner Johnson are now in "The Deadmines", the name the game gives that part.
- Grey "!" marks for quests you can't take yet now show only once you are no more than 2 levels below the level they need.

### Fixed
- The Defias Hideout map under Moonbrook places your arrow on the drawn cave. It used to drift
  off to the side, most in the top rooms.
- Coming out of The Deadmines by the back exit, onto Westfall's coast, no longer shows the Defias
  Hideout map.
- In The Deadmines, killing Sneed now marks Sneed's Shredder killed on the map too. They are one
  fight.

## [0.39.3] (restart)

### Added
- Shadowfang Keep opens on a map of the whole keep, with its floors after it.
- Shadowfang Keep's Lower Observatory, with Fenrus the Devourer, is on the map between The Wall Walk
  and Arugal's Chamber.

### Fixed
- Old Ironforge's map shows from the top of the way down and while you are below, also after a
  /reload, logging out there or coming out of the Hall of Thanes. Stepping out into the throne room
  or any street brings back Ironforge's map.
- Ruins of Lordaeron's map shows the four places the Crest of Lordaeron can lie again.
- The journal's "!" marks show again for players who had hidden them with the map legend in 0.39.1
  or earlier. They no longer depend on a hidden game setting.
- Dragging the journal while it is docked no longer leaves it stuck to the cursor.
- On Shadowfang Keep's map, Wolf Master Nandos, Baron Silverlaine, Odo the Blindwatcher and
  Commander Springvale are now in their own rooms.
- The stairs on Shadowfang Keep's map lead to the right floors, and each floor has its way back down.

### Changed
- The journal's window now opens free on Modern characters and docked on Classic and Custom ones,
  unless you have chosen with the options' dock box or /aegis dock, which counts for every character.
- Show Start and Show End open the map on the spot in one click again, with the waypoint set there.
- A waypoint set from the journal is no longer tracked for you. Click its pin on the map to track it,
  as with a pin you place yourself.
- When the journal shows a dungeon's map, or a place's levels, over another zone, the floor menu is
  now on the map's location bar instead of in a box, and names the place too ("The Sewers (City of
  Dalaran)").
- Shadowfang Keep: Archmage Arugal's and his Voidwalkers' notes now say the four Voidwalkers come when
  Fenrus the Devourer dies, and their pin is in Fenrus's room.
- Quests you can't take yet show a grey "!" on the maps again. Its tooltip says what it needs. Quests
  that are grey for your level still have no mark.
- The map legend's Quest entry turns the journal's "!" marks on and off, on every map and inside
  dungeons.
- Quests whose parts share a name, like The Defias Brotherhood, open with + to list every part, each
  with its own page. In a chain, each part is its own row, numbered "(Part 1)", "(Part 2)" and so on.
- A quest that needs an earlier part of the same name says which part, as in "Requires: The Defias
  Brotherhood (Part 3)", instead of its level. So does a quest that needs a numbered part of
  another name, like A Dynamite Plan.
- Red Silk Bandanas no longer lists The Defias Brotherhood's parts under it. It needs part 6 only.
- A quest's + no longer repeats a quest the list already shows; its lock line names it instead.
- Talks that only lead to a dungeon quest (Speak with Shoni and 18 others) are no longer listed as
  quests of their own.
- Allegiance to the Old Gods, from the Damp Note in Blackfathom Deeps, now needs Trouble in the
  Deeps first, as the game's quest data has it. Not yet checked in game.

## [0.39.2] (restart)

### Fixed
- Opening the world map in a fight no longer brings up an error naming the journal ("tried to call
  the protected function Button:SetPassThroughButtons"). The journal turned the map itself, and the
  game then refused its own quest marks for the rest of the session.

### Changed
- The open map no longer turns by itself when you cross onto another map. The way-in pictures still
  show where they belong.
- Show Map, and a door's click on a way-in picture, draw the dungeon over the map you have open,
  instead of turning it to the door's zone.
- Right-clicking a door, cave, flight path, boat or quest mark, and Show Start or Show End, mark the
  spot and put a link in chat. Click the link to set the waypoint.
- The legend's Quest, In Progress and Turn In entries no longer switch the game's quest marks. Their
  tooltips say where to change them. The filter menu's "Quests on offer" is gone for the same reason.

## [0.39.1]

### Added
- Click a dungeon's round icon, beside its name at the top of the left page, to go back to its
  overview from any of its pages. It lights up under the mouse and says so in its tooltip.

### Fixed
- Shift+J opens the journal again on the live servers. The journal set it while the game was still
  loading your key bindings, so it was lost. It now waits for them, and sets Shift+J once more
  where it was lost, if the key is free.
- A quest chain whose steps share a name, such as The Test of Righteousness or Restoring the
  Necklace, shows as one row with its parts instead of a row for each. Its page is the part
  you're on.
- The chain's other steps of that name are parts of the row too, so nothing under it repeats its
  name: Hidden Enemies is one row of five parts. Under another quest's chain, steps of one name are
  one row as well.
- Search lists such a chain once for each dungeon and opens its row. In the list under the search
  box, quests of one name are one line, which opens the one in the dungeon you're in.
- Quests of one name that start at the same spot on the world map, such as the four Left Piece of
  Lord Valthalak's Amulet quests, are one mark. Its tooltip names each dungeon.
- The Record tab tells two recorded quests of one name apart by their quest IDs.
- In Spanish (Spain), Disharmony of Fire no longer has the same name as Disharmony of Flame.

## [0.39.0] (restart)

### Added
- **Choose your journal** for each character: Classic, Modern or Custom. Classic turns
  off the Gear Finder and stat weights, the way-in maps and caves, and the world map marks. Custom
  opens the options. /aegis style asks again. **Reset Instance Journal** in the options puts the
  options back as at install and asks again. The Record tab has its own box, on in every style.
- **Class Quests** on the Quests tab: your class's quests on their own, now with Collection of
  Goods, the amulet chain's class steps and the warrior, mage and Tier 0.5 chain ends.
- **Maps of more ways in**, drawn for the journal and signed: Blackfathom Deeps' sunken court and
  flooded caves, Gnomeregan's gate and lift, Razorfen Downs' maze and Agamaggan's skull, and the
  Sunken Temple's Pool of Tears and halls. The world map follows you in, where Forever allows it.
- **Caves, mines and a keep with maps of their own** in Elwynn Forest, Dun Morogh, Durotar,
  Orgrimmar, Teldrassil and Tirisfal Glades.
- **Whole-dungeon maps**: the Deadmines, Blackfathom Deeps, Maraudon, the Sunken Temple and
  Stratholme open on one map with every boss pinned. The Temple's lower level has
  Atal'alarion and the Spawn of Hakkar.
- **Blackrock Mountain's middle level**. Click where levels meet to see the other one.
- **Before you go in most dungeons**: keys, attunements, hidden bosses (Grubbis in Gnomeregan)
  and the quests that lead to them. Onyxia's attunement is in for both sides.
- **Quest XP and reputation**: Forever's XP on about 90 quests, and reputation on over 200.
  Numbers from the original game are marked.
- **Gear Finder**: new level 60 stat weights for 15 specs, from a simulator's presets (see
  CREDITS.md), and **Pawn...** takes a Pawn string without the Pawn addon.
- **A new icon**: Forever's journal book with its emblem. On the minimap button and the journal's
  window, its swirl takes your class's colour.

### Changed
- The addon is now all rights reserved: see LICENSE. Downloading it and playing with it stay free.
  The code of versions up to 0.38.0 stays under the MIT License.
- The GitHub repository is private: get the addon from CurseForge and report problems on Discord.
- Dungeon doors stand on their portals at Blackfathom Deeps, Gnomeregan, Razorfen Downs and the
  Sunken Temple, and a right click sets the waypoint to the way in.
- Several quests done outside the dungeon are taken out, and the quest before names what comes
  next. Hidden Enemies and In Nightmares, their chains' last steps, now have reward choices.
- Quel'Serrar's quests are left out until Onyxia's Lair opens.
- Some quests moved to another dungeon, wing or half of the Spire: Dire Maul's by wing,
  Valthalak's to the Upper Spire and Mor Grayhoof's to the Lower.
- The Test of Righteousness is in the Deadmines, Shadowfang Keep and Blackfathom Deeps, and the
  Drowned City has its two Horde quests.
- A quest chain's steps from other dungeons show their own page and where they're done,
  locked until their turn. "Any one of" and "(N parts)" steps lock too.
- Quests that start from an item say where the item is, and reputation names the faction in your
  language.
- The new text is in every language, mostly drafted: corrections welcome on Discord.

### Fixed
- Quest rewards, counts, givers' spots, objectives and levels in many dungeons.
- The Valthalak amulet chains and Kormok's pieces wait for your side's steps, and City of Dalaran's
  Horde key quests open side by side.
- Old Ironforge's map shows again where the game gives a spot no name.
- Recording: a visit after you stop recording inside counts, and after a logout inside, the journal
  no longer turns off your own combat log.

## [0.38.0] (restart)

### Added
- **Where it drops**: an item's tooltip names the boss and dungeon that drop it, wherever the game
  shows the item: your bags, the character sheet, chat links, loot and merchants. "Drops from Edwin
  VanCleef in The Deadmines", or how many bosses there drop it, or the dungeons for an item found in
  several. On by default, with a box in the journal's options to turn it off.
- **The journal docks like the game's own windows** *(player request)*: it opens at the top left,
  moves aside when one of the game's windows opens there, and comes back when that one closes. Drag
  it to put it anywhere until it closes. To have it open where you last left it, as before, untick
  the option in the journal's options or type `/aegis dock`. It works in combat too.
- **Maps of the ways in**: inside the Wailing Caverns' cave, Uldaman's dig, Maraudon's two caves
  (orange and purple), Blackrock Mountain and the ruins of Dire Maul, the world map shows Blizzard's
  own drawn map of the place, with your arrow and the dungeon doors. It changes as you walk in and out.
- **The Scarlet Monastery's hall**, redrawn for the classic four wings: the passages to the
  Cathedral and the Armory drawn back in, each wing's door at its own portal, and sketches of a
  Scarlet crusader and the Ashbringer. It shows once you step inside.
- **Blackrock Mountain's two levels**: the upper ring with the Spire's door, and the level below with
  the Depths' door. Pick one as a new step of the world map's location bar: "World > Eastern
  Kingdoms > Burning Steppes > Blackrock Spire". A dungeon's floors are picked there too.
- Entrance icons: a cave's way in gets the cave entrance icon, and a building's or hall's (the
  Scarlet Monastery, Blackrock Mountain's two gates, Dire Maul's ruins, Old Ironforge, the Defias
  Hideout) the delve entrance icon. The map legend has an Entrance entry beside Cave Entrance, each
  turning its own icons on and off.

### Changed
- Dungeon doors stand on their portals: the Wailing Caverns', Uldaman's, Maraudon's, and each of
  Dire Maul's three wings, which all shared one spot south of the ruins. On the ruins' map every
  doorway has its own icon.
- The journal's Map button opens a dungeon on its own zone's map.
- `/aegis reset` puts a docked window you dragged loose straight back into its place.
- The new maps' rooms are named in every language the journal speaks.
- Maps drawn for the journal, like the Scarlet Monastery's hall, are signed "Redrawn by Torchlite"
  and are all rights reserved; the code stays MIT. See LICENSE-MAPS.md.
- On games in other languages, abilities nobody has written alerts for get them from the ability's
  English name, as on an English game.
- Recordings and `/aegis gearscan` note your game's language, and the gear scan and `/aegis items`
  save dungeon and boss names in English.

### Fixed
- Previewing a language with `/aegis lang` now changes only the journal's own words. Before, the
  preview also changed what the journal reads from the game: the Gear Finder and the upgrades on item
  tooltips misread item stats, the dungeon map lost track of the room you were in, and some bosses
  weren't marked when killed. All of that now follows your game's language.
- On a game in another language, the quartermasters you captured stay with their factions after a
  reload. Before, they dropped out at your next reload.
- Search finds an ability by the spell name its page shows, as well as by the journal's name for it.

## [0.37.0] (restart)

### Added
- **Spanish (Spain), Spanish (Latin America), Brazilian Portuguese and Korean**: the whole journal,
  its interface and every name and text, on a client set to one of them, and `/aegis lang es`, `mx`,
  `pt` or `ko` to preview it on any client. Names come from Blizzard's own for each client where they
  exist; the rest is drafted and awaits native speakers' corrections, which are welcome on the Discord.

### Changed
- **Russian, German, French and Chinese** cover the texts added since they were first drafted: the
  checked quests' givers, places and notes, the chain steps' pages, and the newer interface lines.

## [0.36.0]

### Added
- **Who gives a quest, on its page**: beneath Show Start and Show End, "Quest offered by Afadra
  Dunwall, Ironforge", and who to hand it in to when that is someone else, as the buttons' tooltips
  say it. *(player request)*

### Fixed
- **The quests the audit left open**, verified manually: 64 items, each checked twice. 35
  confirmed what the journal had. The rest: The Test of Righteousness needs its
  whole Tome of Valor chain in every dungeon that lists it, Starving Arcane needs An Alarming
  Request, the Seal of Ascension is the Scarshield Infiltrator's, Wilder Thistlenettle stands where
  Forever's Stormwind has him, and four quests are added (Hot Fiery Death, Corruption, Enchanted
  Thorium Platemail: Volume I, the shamans' Elemental Aid). Three empty Wailing Caverns quests the
  game never offered are gone.

## [0.35.0] (restart)

### Added
- **Item links in Before you go**: the items its notes name (the Tome of Dalaran, the Black Tome,
  the Grimy Key, the Dalaran Sewer Key) are item links, in their quality's colour. Point at one
  for its tooltip, shift-click to put it in chat.
- **Lyn the Ignored's page** opens on the Before you go note on how to summon him, above the
  Overview, and no longer calls him a chance rare.
- **Chain steps get a quest's page**: the quests a dungeon quest needs first (Tramping Paws, Fire
  Taboo...) show their level, and a click opens the page a dungeon quest has: the objective, who
  gives and takes it and where (Show Start and Show End), what starts it, and what it needs first,
  greyed until then and checked off once done, and its rewards. 197 steps, verified manually.
- **Boxes on the Quests tab**: an open dropdown's quests sit in a parchment box under it, as an
  ability's text does, and the box grows as you open a chain. On a dungeon's overview, a key's
  quests sit in its note's box too.
- **The Horde Skyborne's ship** on the world map, in Horde red: its dock on Zephras Isle, west of
  the Alliance's in Valanaar, and its landing on Skywatcher Plateau in Mulgore, by Camp Gev'rek
  (Skyborne only).
- **Skep's runs**: City of Dalaran's first recorded abilities, for all eight bosses and their
  adds, more Excavation Site timings, and the Violet Sorcerer's Sandals from City of Dalaran's
  trash. Skep joins the contributors list. Thank you!

### Changed
- **Item tooltips show only the upgrade**: a line for each spec the item is an upgrade for, with
  the green arrow and what it adds ("+7.4%"). The item's worth to each spec and the level an
  upgrade waits for are gone, and so are the lines for specs it doesn't improve.
- **City of Dalaran's abilities** use the spells its bosses really cast, from Skep's combat logs,
  and no longer show some of them twice.

### Removed
- **The Skyborne's portals** between Stormwind's mage tower and Dalaran: Forever took both out.
  They are hidden where you saved them yourself with /aegis travel too. The Skyborne airship
  between Dalaran and Zephras Isle stays.

### Fixed
- **Every dungeon quest verified manually** and corrected: 251 quests in all. Each quest now lists every quest you must do first, in order, and leaves out the
  optional ones that only point the way: Horrors in the Highland needs Rethiel's Tramping Paws,
  Fire Taboo and Blisters on the Land again. Givers and takers named, quests that start from an
  item or an object say which, class quests marked for their class, and quest givers placed
  where Forever's redrawn Stormwind and Redridge have them. 33 quests the journal lacked are in,
  and 15 are gone: duplicates the game never offers (Unfinished Gordok Business is listed once,
  as the quest the game gives) and another wing's quests.
- **Dungeon and cave entrances on the world map** answer the mouse over their icon only: the
  tooltip and a click could catch the cursor well off the swirl.
- **The Highland Horror** (Excavation Site) is crossed out on the dungeon map when killed. Bosses
  the game holds no encounter for, like him and the rares, are now marked once you see them dead:
  as your target, focus or mouseover, or as you loot them. (Forever keeps the combat log from
  addons, so it can't be used for this.)
- **The world map's legend**: pointing at a quest in your log lights its In Progress or Turn In
  entry only, no longer Quest as well; the journal's own "?" marks light Turn In only.

## [0.34.0]

### Added
- **Trash** in every dungeon's boss list, after its bosses: what the dungeon's other creatures drop
  that is worth knowing about, rare and epic gear, recipes and quest items. The greens and whites
  any creature there may drop are left out of the dungeon's loot, search and the Gear Finder too.
- **Before you go**, at the top of a dungeon's overview: its key and the quests to it, and any
  hidden boss to prepare for, each a note under a header like the Abilities tab's, opened and
  closed with a click. A key's header shows the "!" of the quest you're on and how many of its
  quests are done; beneath its text, its quests are listed as on the Quests tab, and a click
  opens one there. City of Dalaran first: the Dalaran Sewer Key for each side, and how to make
  and use the Tome of Dalaran that summons Lyn the Ignored. More dungeons will follow, one at a
  time.
- **Dropdowns on the Quests tab**: a dungeon's key first, holding the quests to it (for City of
  Dalaran, the Horde's five and the Alliance's two), open until you have it; then **Dungeon
  Quests**, the rest, listed as before. Each header shows the mark of its first quest still to
  do and how many of its quests are done, and a click folds or opens it.
- **Switches in the world map's legend**: click an entry to hide that kind of marker, click again
  to show it. The journal's own (dungeon and raid doors, flight points, caves, boats, zeppelins,
  trams and portals) are kept for your account; the game's quest markers use the game's own map
  filters, the same ones as the map's filter menu. The same switches are in the map's filter
  menu too, under Instance Journal, beside Show unexplored areas.
- **Ratchet and Booty Bay rewards confirmed**: their quartermasters, Winklespark and Gezzy
  Gunkgear, captured by Genesys Firstborn, with prices and the standing each needs (six rewards
  each). Thank you!

### Changed
- **City of Dalaran** is no longer marked "Not yet tested".
- **Merchant's Favor costs** on the Azeroth Commerce Authority's and Durotar Supply and
  Logistics' rewards now show as the merchant shows them: the amount and the currency's icon.
- **Dungeon quest marks** on the maps now show only quests you can take now (the quests before
  them done, your level reached) and that aren't grey for your level. The Quests tab still lists
  them all.
- **Pointing at a dungeon quest mark** lights the legend's Quest entry (and Turn In, for a "?"),
  and pointing at those entries lights the marks up, as the game's own marks do.
- **Show Start and Show End** on a quest now set the game's own waypoint there, on the map, the
  minimap and in the world.

### Fixed
- **Lyn the Ignored** is a he: his notes and abilities said "she", in every language.
- **On a dungeon's map**, the quest log's button in the map's corner could not be clicked once the
  log was closed: the map's own buttons now stay above the dungeon map.

## [0.33.0]

> ⚠️ **About the new languages.** The German, French and Chinese (Simplified and Traditional)
> translations were drafted with AI (Claude) and have **not yet been checked by native
> speakers**. Expect some awkward or wrong words, names that differ from Blizzard's own, and a
> few lines still in English. If you play in one of these languages, corrections are very
> welcome: open an issue or a pull request on GitHub, or tell us on Discord. The Russian
> translation is Staree4ok's own work and is not affected.

### Added
- **German, French, Simplified Chinese and Traditional Chinese**: the journal follows a game
  client set to any of them, its interface and its content (dungeons, bosses, abilities, quests
  and places), drafted as the note above says. A few of the newest lines (the minimap button,
  working with Pawn, the options) are still in English.
- **`/aegis lang`** to see a translation on any client: `/aegis lang de`, `fr`, `ru`, `cn` or `tw`
  shows the journal's own words in that language from your next `/reload` (the game's names stay
  your client's), and `/aegis lang off` goes back.
- **Dungeon rooms and areas in your language**: "you are here", recorded areas and zone levels
  match the client's own area names in every language, not English ones only.

### Changed
- **Russian**: the rooms inside dungeons and the `/aegis areas` messages are translated too.

## [0.32.0]

### Added
- **The journal's stat weights in Pawn**: with Pawn installed, the journal adds a scale of its
  own to Pawn for each of your specs ("Journal: Holy" and so on), holding the weights the Gear
  Finder uses. Choose the journal's weights and Pawn shows the one for the spec the Gear Finder
  scores for, and hides its own scales on that character, so Pawn's tooltips and upgrade arrows
  weigh items just as the Gear Finder does. A weight you change in the journal reaches Pawn at
  once, and a new spec's scale takes over when you change spec. Untick **Show stat weights in
  tooltips** and the journal's scale leaves Pawn's tooltips too (and with it Pawn's arrows for it,
  as Pawn marks upgrades only for the scales it shows). Choose Pawn's weights (in the journal's
  options) and Pawn's own scales come back. Baganator keeps Pawn's answer for each item until
  your gear changes, so where it draws Pawn's arrows the journal offers a reload after such a
  change, for the arrows to follow.

### Changed
- **The question asked when Pawn is installed** now offers the journal's weights first, for Pawn
  and the Gear Finder both. A scale you show again in Pawn yourself stays shown. If you ever
  remove the journal, show Pawn's own scales again in Pawn.

## [0.31.1]

### Added
- **73 dungeon quests** the journal lacked, found by verifying every dungeon's quests manually:
  chain steps given far from the dungeon (Gnomeregan, Uldaman,
  Blackrock Depths and Spire), Forever's new ones in Wailing Caverns, Blackrock Depths and the
  Ruins of Lordaeron, Dire Maul's librams, the Sunken Temple's class quests and more.
- **Excavation Site: Wetlands, from a recorded run**: each boss's spells (the Relic Guardian's
  Knock Away is his threat drop; Shadetooth's roar fears up to three players), their areas and
  the entrance. Thank you, Genesys Firstborn.
- **What can be dispelled on the way**, on the boss each pack leads to: the Marsh Skulkers'
  Muculent Rot, the Thicket Hunters' Infected Wound, the Dragonmaw Thaumaturgists' Curse of
  Weakness and the spider trail's poison and Highland Venom, with the classes that can take each
  off; and the Highland Horror's roots, which Blessing of Freedom breaks.
- **"You will also receive"** on a quest's page, for the items that come with the choice, and
  how many of each item you get.
- **The Gear Finder's stat weights on every item's tooltip**: in your bags, on the character
  sheet, in loot, at merchants, in chat links and in the Gear Finder, a short line for each of
  your specs with what the item is worth to it, and a green arrow with what it adds to your gear
  when it beats what you wear (with the level, for gear a few levels ahead).
- **Show stat weights in tooltips**, a box under the stat weights: untick it and items'
  tooltips, the Gear Finder's too, leave out what each item is worth and adds to your gear.
- **Green arrows on upgrades**: in your bags (Baganator's too, in its top right corner), in the
  loot window and on loot rolls, an item that is an upgrade for your spec has the bags' green arrow
  at its corner, so you can tell at a glance what to keep, take or roll on.
- **Working alongside Pawn**: with Pawn installed and enabled, its item tooltips and upgrade arrows
  are the ones shown, and the journal asks once whether the Gear Finder should score with Pawn's
  stat weights or the journal's own. With Pawn's, it takes your own Pawn scale for the class (a
  copied one for its spec) before Pawn's starter scales. Change it any time in the options;
  without Pawn, the journal shows its own.
- **Boss levels on the boss list**: each boss's level on its portrait, in the target frame's
  badge, coloured from grey to red by how hard the boss is for you.
- **The journal's options**, in the game's Options under AddOns (or `/aegis options`): boss
  levels, stat weights in tooltips and the green arrows can each be turned off.
- **`/ij`** opens the journal too, as `/aegis` does.
- **A minimap button**, with the journal's new icon, the Ashbringer. Click it to open the
  journal, right-click it for the options, drag it round the minimap's edge; the options can hide
  it.
- **The Gear Finder and its stat weights in Russian**, with every spec's name and unit, by
  Staree4ok. The new top 3 picker is still in English for now.

### Changed
- **18 quests' levels or side**, to Forever's: mostly the level they open at.
- **Excavation Site's quests**, verified manually one by one: where each is
  given and handed in, the right experience, Heartwoven's four of each potion, and no quests
  needed first that only lead the way there (Seeking Caitlin, Young Crocolisk Skins, Rethiel's
  Wetlands quests).
- The Log Reader page keeps a boss's spells when the game calls him neutral (the Relic Guardian).
- The Gear Finder no longer suggests a unique ring or trinket you already wear in the other slot.
- **The Gear Finder's tooltips are plainer**: the item, what it is worth to each spec, where it
  drops and a short hint, without the slot's other upgrades or the long lines.
- **The Gear Finder's slots no longer carry the green arrow**: everything it shows is an upgrade;
  the arrow now marks upgrades in your bags, the loot window and rolls instead.
- **The journal's own icon**: its window's round portrait, top left, is now the Ashbringer, as on
  its minimap button, in place of the game's journal book.

### Fixed
- The loot's class filter was missing the Druid.

## [0.31.0]

### Added
- **Pick from a slot's top 3**, as in Aegis: Pathfinder: click a slot in the Gear Finder and its
  three biggest upgrades open beside it, each with what it adds and where it drops. Click one to
  show it in the slot; the suggested dungeon follows your picks. A pick is starred, kept for each
  character, and forgotten once you wear it; **Clear my pick** brings the biggest back.

### Changed
- **Right-click** a Gear Finder slot to open its item's loot in the journal (a plain click now
  opens the top 3).

## [0.30.1]

### Changed
- **The character panel's Gear Finder tab** works like the panel's own tabs: from any page it
  turns the panel to your character, with your stat weights where its stats are. Clicked again,
  the weights stay; the Character tab or any other gives the stats back. Only the tab you're on is
  marked. With the right pane folded away, they show over the panel's edge; its arrow unfolds
  it.

## [0.30.0] (restart)

### Added
- **Gear Finder**, a new tab: the best upgrade waiting for each slot in the dungeons that
  start no more than three levels above you, laid out like your character sheet. Each shows
  what it adds to all the gear you wear and where it drops; one you can wear in a few levels
  shows that level in red. A click opens its loot. The dungeon holding the most upgrades is
  suggested, and the others are a click apart.
- **Scored for your spec**: the one your talents say, or one you pick, with Aegis: Pathfinder's
  stat weights (one set while levelling, another at 60).
- **Stat weights you can change**, kept for each character and spec: click a weight and type a
  new one; yours show in green, and **Reset** brings the journal's back. Or bring in a scale
  from **Pawn**: paste what its Export gives.
- **A tab on the character panel** opens your stat weights over the panel's stats, with a button
  to the Gear Finder. It takes the first place under the panel's own tabs; another addon's tab
  found there moves down under it.
- `/aegis gear` and `/aegis weights`. `/aegis gearscan` saves what the Gear Finder reads from
  your gear, so its scoring can be checked against Forever's own words.

### Changed
- **Record is now the last tab**, after Gear Finder. The journal still reopens on the tab you
  last had open.

## [0.29.1]

### Changed
- **Staree4ok heads the contributors** on the Record tab, for the journal's Russian translation.

## [0.29.0] (restart)

### Added
- **The journal in Russian**, translated by Staree4ok. On a game client set to Russian, the
  window, its tabs, menus and messages are in Russian, and so are the dungeons', raids' and
  factions' names, their bosses and abilities, quests and places. Item and spell names are the
  game's own, as before. A client in any other language is unchanged.

## [0.28.0] (restart)

### Added
- **Faction rewards are back, unconfirmed.** Every faction nobody has captured yet lists the
  rewards the game's item data gives it, by standing: 458 rewards across 21 factions, leaving
  out the game's test items. They show without prices, the faction's tooltip says they're
  unconfirmed, and its page asks for a capture. Capturing a quartermaster confirms each
  reward it finds, with its price and cost, and moves it if it needs a different standing.
- **Durotar Supply and Logistics captured**: the Horde's Merchant's Favor quartermasters at the
  Crossroads, 9 vendors and 183 rewards with their costs, from Genesys Firstborn's recording.
- Both captured factions, the Azeroth Commerce Authority and Durotar Supply and Logistics, keep
  only their captured rewards, not the game's shorter lists.

### Changed
- **Faction cards**: no reward count in the corner any more. The factions WoW: Forever added
  wear its emblem there instead, as its dungeons and raids do.

New file: close the game fully and start it again; `/reload` won't load it.

---

## [0.27.1]

### Fixed
- Forever's own zones show their level ranges on the world map too: Riverglades 36-44,
  Mount Hyjal 60 and Shen'dralas 35-45.

---

## [0.27.0] (restart)

### Added
- **Zone level ranges on the world map.** Hover a zone on a continent map and its level
  range shows after its name, coloured for your level as quests are: red when it's above
  you, yellow while you're within it, green and grey below. Where the client knows a zone's
  range itself, its own shows instead.
- **Show unexplored areas.** A new tick box at the end of the world map's filter menu (the
  magnifying glass) draws the parts of a zone you haven't explored yet, a little darker
  than the parts you have. It is remembered across sessions and characters.

New files: close the game fully and start it again; `/reload` won't load them.

---

## [0.26.8]

### Changed
- **A new logo**: the Aegis shield and wings round an open journal, in a ring of runes. It is
  the journal's icon in the AddOns list and heads the README. The client may keep showing the
  old icon until the game is restarted.

---

## [0.26.7]

### Changed
- **Boss portraits are full circles** at the start of each plate, ringed in shaded gold like
  the faction cards' crests. The plate now starts behind the circle, so nothing of it shows
  to the portrait's left. Bosses without a known model and faction standings use the same circle.
- The boss list scrolls below the dungeon's icon, so a portrait never shows round it.

---

## [0.26.6]

### Changed
- The gold band round each boss portrait is twice as thick, closer to retail's rim.

---

## [0.26.5]

### Changed
- **Boss portraits sit in the plate's own cap**, as retail's boss pictures do, instead
  of a separate gold ring beside it. They fill the cap, cut flat by the plate's bottom
  edge, with a gold band that thickens the cap's thin rim to retail's, and the hover glow
  traces the cap without the old workaround.
- Recorded timings read as one number when they never varied ("then every 12s", not
  "12-12s").
- A boss's buff on itself that the written abilities don't list is left out (Kam
  Deepfury's Defensive Stance).

### Added
- **The Stockade from a recorded run**: encounter IDs, the bosses' recorded numbers,
  the Defias Insurgents that fight beside three of them, the ringleaders' heads and
  Dextren Ward's hand, the Red Wool Bandanas for The Color of Blood, and the entrance
  where the run walked in.

### Fixed
- **The Color of Blood** is marked where Nikova Raskol stands (73.3, 55.4).
- A quest the game already marks on the map (a "?" in your log) no longer gets a
  second mark from the journal on top of it.

---

## [0.26.4]

### Added
- **A Type filter on loot and reward pages**, in place of the slot filter: Equipment
  (by slot), Recipes (by profession: Alchemy, Blacksmithing, Enchanting…),
  Consumables, Mounts, Pets, Toys, Bags, Trade Goods and Quest Items. Only the kinds a
  page has are offered. A slot you had chosen carries over as Equipment.

### Fixed
- Recipes and other items that aren't worn showed ", Alchemy" where the slot goes; they
  now read "Recipe, Alchemy", "Mount", "Toy" and so on.

---

## [0.26.3]

### Fixed
- **Capture vendor** now keeps wares whose tooltip says only "Requires Friendly with
  this faction." Many quartermasters' wares, like the Azeroth Commerce Authority's
  craftsmen, never name their faction. The journal works it out from the wares that do:
  another ware of the same vendor, then the currency they cost (whatever Merchant's
  Favor buys belongs to the Authority), then a vendor standing beside them. Until one
  names it, the Capture line says the faction isn't named yet, and the wares wait.

### Added
- The **Azeroth Commerce Authority**'s rewards, captured from its nine vendors in
  Redridge: 183 wares bought with Merchant's Favor, from the craftsmen's recipes,
  plans, patterns, schematics and formulas (83 at Friendly, 97 at Honored) to the
  Packmule Treat (Revered), the Tabard and the Reins of the Pack Kodo (Exalted).

---

## [0.26.2]

### Added
- **Subtilizer** is the journal's first contributor, on the Record tab, for the
  Blackfathom Deeps run.
- **Sword of the Fallen** is back on the Ruins of Lordaeron's trash loot, dropped by
  Tattered Ghouls. It had been left out by mistake.

### Changed
- **Old Serra'kis only melees**: Leech Pulse, which his combat log showed, is no longer
  listed as an ability.

---

## [0.26.1]

From the first combat log sent through the Log Reader (Blackfathom Deeps).

### Added
- **Blackfathom Deeps' boss abilities now have numbers**: how hard each one hit, when it
  first came and how often, for all seven bosses with a fight. Old Serra'kis gains
  **Leech Pulse**.

### Fixed
- **A fight the game never ends** (Lorgus Jett's) no longer runs on through the trash
  after it. The Log Reader now ends it when he dies, and the journal takes only the
  boss's own spells from a fight with no end.
- A creature that only buffed itself near a boss is no longer listed as one of its adds.

### Changed
- The field guide no longer asks for travel marks: every route is in the journal.
- No more testers' zip: everyone gets the release from GitHub or CurseForge, and
  `Tools/package.py` builds only that.

---

## [0.26.0]

### Added
- **The Log Reader**, a web page that adds the bosses' spells from your combat log
  to your recording: https://torchlite-bit.github.io/Aegis_Forever_Instance_Journal/log-reader/
  Addons can't see what enemies cast inside Forever's dungeons, but the game's log
  file can. Paste your recording, drop in the log, and send the one text it gives
  back. The log is read in your browser and never uploaded. Only the enemies' spells
  from boss fights are kept, with no player names.
- The Record tab notes the log file it starts (Recent says `Combat log on:
  Logs\WoWCombatLog-….txt`). When a recording wrote one, **Copy** names the file
  and links the Log Reader.

### Changed
- The build tool reads the Log Reader's lines like a combat log file.

---

## [0.25.2]

From the first recorded Blackfathom Deeps run.

### Added
- **Blackfathom Deeps' encounter IDs** for all seven bosses that have a fight, so each
  fight is tied to its boss by ID, not by name (the game calls Gelihast's "Geilhast").
- Recordings pasted in Discord now give the journal their encounter IDs when the data
  is rebuilt.
- **Head of Kelris** on Twilight Lord Kelris's loot, for Blackfathom Villainy.

### Fixed
- The first pool is **The Pool of Ask'ar**, as the game names it. The Drowned Sacellum
  joins the list of the dungeon's areas.

---

## [0.25.1] (restart)

### Added
- **The Aegis Instance Journal logo**: the journal's icon in the AddOns list, and at
  the top of the README.

### Changed
- The README's screenshots are JPGs, so they show on CurseForge too.

---

## [0.25.0] (restart)

### Added
- **Capture vendor**, on the Reputation tab. Walk up to a quartermaster, open their
  shop, press the button: everything they sell is kept with its price, any other
  cost and the standing it needs. Their faction's rewards fill in at once, and the
  capture comes along with Copy on the Record tab. No need to be recording.
- **A placeholder for every faction nobody has captured yet**, saying how to
  capture it, with the Discord link. Forever's own factions say *Coming soon*.
- **Abilities for every boss of 16 dungeons**, verified manually: what
  each ability does in the fight, its role alerts, the mechanics with no spell, and
  how the fight begins where it is unusual (Sneed's Shredder, the Fires of Aku'mai,
  Lyn the Ignored's summoning...). Lyn's raised skeletons no longer read
  "Retrieving data".
- **14 quests the journal lacked**, most of them the Horde's: in Maraudon, Uldaman,
  Dire Maul, Blackrock Spire, Gnomeregan, the Scarlet Monastery, the Excavation Site
  and the Drowned City.
- **WoW: Forever's emblem** marks Forever's dungeons and raids, with a tooltip.

### Changed
- **The Reputation tab's rewards come only from captured quartermasters.** The
  earlier, unconfirmed rewards lists are gone; every faction starts as a placeholder.
- **Loot verified manually**: Forever's new leather helms and patterns where
  players have seen them, and the recipes seen on Kresh, Skum, Lady Anacondra,
  Rhahk'Zor and Captain Greenskin.
- **Mr. Smite's stages** are at 66% and 33% health, with the weapons he takes up.
- **The levels quests open at**, verified manually, and the right giver for
  Destruction in Deadmines.
- **The README** has screenshots, and says the journal is a work in progress.

### Removed
- **The "New in Forever" label** on dungeon buttons (now the emblem) and on faction
  cards.

---

## [0.24.2]

### Added
- **Group loot is recorded.** The Record tab used to see only your own loot
  window. It now also notes what your group members loot (from the loot chat,
  under *Looted by your group*) and the drops the group rolls on, filed under
  the boss they came from. Players' names are never kept.
- **Auto loot is caught.** Items are read as soon as the loot is ready, before
  the window shows.

### Changed
- **Start Recording is the standard button again**, like Copy and Clear. It
  still can't be clicked for 5 seconds after starting, so a double click doesn't
  stop the recording it just began.

---

## [0.24.1]

### Fixed
- **The Record page was hard to read.** Its lighter and smaller lines (the
  dungeon facts, *Off …*, *Recent*, the contributors note) are now in the page's
  full ink at body size, and item colours are darkened for the parchment. The
  contributors note moved out of the page's shaded corner.

---

## [0.24.0] (restart)

### Added
- **New pictures.** Onyxia's Lair has a painting of the broodmother, and the
  dungeons with no picture of their own have a moonlit keep instead of a
  question mark.

### Changed
- **The Record tab is a page of the journal.** On the left, the **Recorder**:
  status, Start / Copy / Clear, the two switches, our Discord, *Credit me as*
  and the contributors. On the right, **What you caught**: each dungeon's
  entrance, kills and the drops the journal doesn't have yet, then quests,
  quartermasters, travel marks and the latest entries.
- **Copy turns the right page into text**, picked out for Ctrl+C. **Back** or
  Esc turns it back. Left empty, *Credit me as* is your character's name.
- **Clear asks first**, and is greyed out when there's nothing to clear.
- Each copied loot line says whether the journal lists the drop already.

### Fixed
- **The Record tab's status overlapped its title.**
- **"New in WoW: Forever" sank into the parchment.** It's now a deep blue.

---

## [0.23.0] (restart)

### Added
- **14 dungeons are back**: Razorfen Downs, Uldaman, Zul'Farrak, Maraudon, the
  Temple of Atal'Hakkar, Blackrock Depths, Lower and Upper Blackrock Spire, Dire
  Maul East, North and West, Scholomance, and Stratholme's Main Gate and Service
  Gate. Each comes with its maps, bosses, loot and quests.
- **The raids**: Barrow Deeps, Hyjal Summit and Onyxia's Lair, as *Coming soon*
  pages.
- **Forever's announced dungeons are listed**, each with a *Coming soon* box and
  the Discord link.
- **New in Forever**: a small label on what Forever added, on dungeon buttons
  and faction cards, and a line on the dungeon's overview.
- **The Record tab**: records by itself in dungeons, counts what you've caught,
  **Copy** turns it into text for our Discord, and a contributors list.
- **Reputation quartermasters**: open one while recording and the wares each
  standing unlocks join the Reputation tab.

### Changed
- **The boss button's hover glow** now traces the portrait's ring.
- **All of the journal's data now lives in its own files**, one per dungeon.

---

## [0.22.0] to [0.22.2]

- **Loot tables** match what is confirmed in game, quest items kept.
- **Bosses with several possible spots** get small, faded pins; hovering one
  lights up all of its spots.

## [0.20.0] to [0.21.1]

- **Every classic dungeon checked** again: levels, fight notes, boss spots, loot
  and quests. New maps for the classic dungeons, without the old painted skulls.
- **Scarlet Monastery's Armory and Cathedral** added.
- **Item names** filled in for every drop, even ones the server doesn't describe
  yet.

## [0.17.0] to [0.19.0]

- **Quest marks on the maps**: **!** and **?** that follow your quest log, on the
  world map and inside dungeons.
- **Excavation Site** gets its newer map and its fourth boss, the Highland Horror;
  **Ruins of Lordaeron** gets its boss spots fixed.

## [0.15.0] to [0.16.3]

- **The Model tab**: each boss in 3D.
- **City of Dalaran** gets its map, every drop and its quests' order.

## [0.12.0] to [0.14.5]

- **First tester build**, with the tester guide.
- **Unknown items are hidden** until confirmed; `/aegis items` finds them.
- **Wings that share a door** share one map icon with a menu.
- **Boats and zeppelins** labelled by where they go.

## [0.9.0] to [0.11.3]

- **Dungeon doors on the world map**, retail style: left-click opens the
  journal, right-click sets a waypoint.
- **Search.**
- **Old Ironforge, the Defias Hideout and the Deeprun Tram** get maps of their own.
- **The map legend** and the map's Quests tab come back; flight masters on zone
  maps; `/aegis travel` to mark boats, zeppelins and portals.
- **The Record tab**, first version.

## [0.5.0] to [0.8.0]

- **The journal itself**: the dungeon grid, the book, boss pages with Overview,
  Loot and Abilities, then the Quests tab, the Reputation tab and the dungeon
  maps.
