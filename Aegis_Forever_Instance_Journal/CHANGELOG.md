# Changelog

All notable changes to **Aegis: Forever Instance Journal**.

Format loosely follows [Keep a Changelog](https://keepachangelog.com/).
The version here matches `## Version` in `Aegis_Forever_Instance_Journal.toc`
and the version shown in the AddOns list. Quote it in bug reports.

> ⚠️ Releases marked **restart** add a new file (a `.lua` file or a texture).
> The client reads those only at startup, so `/reload` won't pick them up: close
> the game fully and start it again. Everything else is `/reload`-safe.

---

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
