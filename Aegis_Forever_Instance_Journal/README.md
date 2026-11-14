<p align="center"><img src="docs/images/logo.png" alt="Aegis Instance Journal" width="220"></p>

# Aegis: Forever Instance Journal (v0.39.21)

**Retail's instance journal and dungeon maps, brought to WoW: Forever.**

[![Discord](https://img.shields.io/badge/Discord-join%20us-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/Hr66t25vE7)
[![WoW: Forever](https://img.shields.io/badge/WoW%3A%20Forever-Interface%2016001-c79c2e?style=flat-square&labelColor=555)](#install)
[![GitHub: changelog](https://img.shields.io/badge/GitHub-changelog-24292f?style=flat-square&logo=github&logoColor=white)](CHANGELOG.md)
[![CurseForge: download](https://img.shields.io/badge/CurseForge-download-F16436?style=flat-square&logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/aegis-forever-instance-journal)

Press **Shift+J** and the journal you know from retail opens: every dungeon and
raid, its bosses, loot, abilities, 3D models and quests, with maps that show
where each boss stands and an icon on the world map at every door.

> Built for **WoW: Forever** (the `_forever_` client, Interface 16001).
> Not Classic Era. Not retail.

> ### 🚧 Work in progress
> The journal is still being built and filled in. Forever's own dungeons, raids
> and reputations join as they open and as players record them, and some data is
> still missing: a few boss spots and entrances, the damage abilities do, and the
> reputation rewards nobody has captured yet.
> Expect changes between versions: see the [changelog](CHANGELOG.md).

**[💬 Join the Discord](https://discord.gg/Hr66t25vE7)** for help, bug reports,
and to send in your recorded runs.

---

## Contents

- [What it does](#what-it-does): the journal and its styles, boss pages, maps, reputation, the Gear Finder, search and the Record tab
- [Santiago Reyes's maps](#santiago-reyess-maps)
- [Install](#install)
- [A few honest notes](#a-few-honest-notes)
- [Something broken?](#something-broken)

---

## What it does

### 📖 The journal

| Dungeons | City of Dalaran |
|:---:|:---:|
| <img src="docs/images/dungeons.png" alt="The Dungeons tab, Forever's own marked with its emblem" width="430"> | <img src="docs/images/journal-city-of-dalaran.jpg" alt="The journal open on City of Dalaran: its bosses, New in WoW: Forever, Alterac Mountains, level 28-33, and Before you go: The Dalaran Sewer Key and Lyn the Ignored, a hidden boss" width="430"> |

- **Retail's Encounter Journal**, rebuilt to its measurements (Blizzard's own
  doesn't load on Forever): breadcrumb bar, search box, and five tabs:
  **Dungeons · Raids · Reputation · Gear Finder · Record**.
- **35 dungeons**: the classics from Ragefire Chasm to Stratholme, Forever's own
  (The Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands, City of
  Dalaran), and the five Blizzard has announced.
- **3 raids, coming soon**: Barrow Deeps, Hyjal Summit and Onyxia's Lair.
- A **level-range filter**; **WoW: Forever's emblem** marks what Forever added;
  **Not yet tested** marks what still needs a recorded run.
- **Docked like the game's own windows** in the Classic and Custom styles: it opens
  at the top left and moves aside when one of them opens there, and you can drag it
  anywhere until it closes. In Modern it opens where you last left it. Tick or untick
  docking in its options, or type `/aegis dock`, to choose for all your characters.
- **Before you go**, in most dungeons: keys, attunements, hidden bosses and the
  quests that lead to them. Onyxia's attunement is in for both sides.
- **Where it drops**: an item's tooltip names the boss and dungeon that drop it,
  wherever you see the item.
- **Its icon** is Forever's journal book with its emblem. On the minimap button and
  the journal's window, its swirl takes your class's colour.

**Choose your journal**: each character is asked once, at its first login with the
journal, how much it should add to the game.

- **Classic**: a more original-style journal. The Gear Finder and stat weights, the
  way-in maps and caves, and the journal's marks on the world map start off.
- **Modern**: everything the journal has, all on. Closing the question keeps the
  style you have, Modern at first.
- **Custom**: opens the journal's options, where each of those has its own box to tick.
- The bosses, loot, quests and dungeon maps are there in every style, and the Record
  tab has its own box, on in every style. Change the style any time in the options;
  `/aegis style` asks again, and **Reset Instance Journal** puts the options back as
  at install and asks again.

| Choose your journal |
|:---:|
| <img src="docs/images/choose-your-journal.jpg" alt="The Choose your journal question: Classic, Modern and Custom with their starting settings, Modern marked Your style now, and Closing this keeps Modern" width="430"> |

### 🗡️ Boss pages

Five side tabs, as in retail, plus one:

- **Overview**: fight notes and quick facts.
- **Loot**: filter by class, armour and type (equipment by slot, recipes by
  profession, consumables, mounts, pets, toys), ★ favourites, pin an item to the
  map. Items the server doesn't know yet stay hidden until someone sees one drop.
- **Abilities**: retail's collapsible tree: what each ability does in the fight, its
  role alerts, stages, and the damage and timings your recorded runs measured.
- **Model**: the creature in 3D. Drag to turn it, scroll to zoom.
- **Quests**: the dungeon's quests with status icons and chains, their rewards,
  and **Show Start / Show End** to open the map on the spot and set a waypoint there. **Class Quests** lists
  your class's quests on their own. Forever's XP is shown on about 90 quests and
  reputation on over 200; numbers from the original game are marked.

| Overview | Loot | Abilities |
|:---:|:---:|:---:|
| <img src="docs/images/boss-overview.png" alt="A boss's overview" width="280"> | <img src="docs/images/boss-loot.png" alt="A boss's loot" width="280"> | <img src="docs/images/boss-abilities.jpg" alt="Faldrim Anvilmar's abilities, with their icons and the damage and timings recorded runs measured" width="280"> |
| **Model** | **Quests** | **Quests on the map** |
| <img src="docs/images/boss-model.png" alt="A boss in 3D" width="280"> | <img src="docs/images/boss-quests.jpg" alt="City of Dalaran's quests: the Sewer Key chain, who offers a quest and who takes it back, its rewards" width="280"> | <img src="docs/images/map-ruins-of-lordaeron.jpg" alt="Ruins of Lordaeron map with a quest mark's tooltip" width="280"> |

### 🗺️ Dungeon maps

- **Show Map**, or the world map inside a dungeon, draws its floors with retail's
  boss pins. Bosses you've killed are crossed out; the area you stand in glows.
  Hover a boss's pin for its name and level, and a note where the journal has one
  (City of Dalaran's say where each boss stands); click it to open the boss in the
  journal.
- **Whole-dungeon maps**: the Deadmines, Blackfathom Deeps, Maraudon, the Sunken
  Temple and Stratholme open on one map with every boss pinned. Maraudon's and the
  Temple's are Blizzard's drawn maps; the other three are redrawn by Torchlite. The
  Temple's lower level has Atal'alarion and the Spawn of Hakkar.
- **A boss with several possible spots** gets small faded pins; hover one and
  all of its spots light up.
- **Forever's own dungeons** use Santiago Reyes's hand-drawn maps.
- **The places the game has no map of**: Old Ironforge, the Defias Hideout on the
  way to the Deadmines, and the Deeprun Tram, with your arrow where the game
  gives a position.

| Maraudon, the whole dungeon on one map | City of Dalaran, a boss's tooltip |
|:---:|:---:|
| <img src="docs/images/map-maraudon-whole.jpg" alt="Maraudon's whole map with boss portraits from the Noxious Hollow and Foulspore Cavern down to Zaetar's Grave, beside the map legend" width="430"> | <img src="docs/images/map-city-of-dalaran.jpg" alt="City of Dalaran's map with its boss portraits, The Sewers and The City in the location bar's menu, and the Shade of the Archmage's tooltip: the last boss, in the Purple Parlor of the Violet Citadel" width="430"> |
| **The Hall of Thanes** | **Old Ironforge** |
| <img src="docs/images/map-hall-of-thanes.jpg" alt="The Hall of Thanes map" width="430"> | <img src="docs/images/map-old-ironforge.jpg" alt="Old Ironforge map" width="430"> |

### 🏰 Maps of the ways in

Several caves, mines and halls, many of them on the way to a dungeon's door, have
maps of their own. Walk in and the world map changes to them, with your arrow and
the dungeon doors on it; walk out and it changes back. Click a cave or entrance icon on the zone map to
look inside before you go.

<p align="center"><img src="docs/images/map-scarlet-monastery-hall.jpg" alt="The Scarlet Monastery's hall, redrawn for the classic four wings, with a door at each wing's portal and sketches of a Scarlet crusader and the Ashbringer" width="860"></p>
<p align="center"><em>The Scarlet Monastery's hall, redrawn by Torchlite for the classic four wings.</em></p>

- **Drawn for the journal** and signed by Torchlite: the ways into Blackfathom Deeps
  (its sunken court and flooded caves), Gnomeregan (its gate and lift), Razorfen
  Downs (its maze and Agamaggan's skull) and the Sunken Temple (the Pool of Tears
  and its halls).
- **Redrawn for the journal** from Blizzard's maps and signed: the Scarlet Monastery's hall,
  its passages to the Cathedral and the Armory drawn back in, a door at each wing's portal, and
  sketches of a Scarlet crusader and the Ashbringer; Blackrock Mountain's ring and middle
  level; Orgrimmar's Cleft of Shadow and Tirisfal Glades' Night Web's Hollow.
- **Caves, mines and a keep** have maps of their own in Elwynn Forest, Dun Morogh,
  Durotar, Orgrimmar, Teldrassil and Tirisfal Glades. Fargodeep Mine has two levels.
- **Blizzard's own drawn maps**: the Wailing Caverns' cave, Uldaman's dig,
  Maraudon's two caves, Blackrock Mountain's way down to the Depths, the ruins of
  Dire Maul, and the starting zones' caves, mines and keep (but for Night Web's
  Hollow).
- **Blackrock Mountain's three levels** are one more step of the map's location bar:
  Blackrock Spire (the ring over the lava), Blackrock Mountain (the middle level) and
  Blackrock Depths (the way down). Razorfen Downs' and the Sunken Temple's ways in,
  Fargodeep Mine, Tiragarde Keep and Ban'ethil Barrow Den have levels too. Where two levels meet, a door with an arrow shows the other one when you
  click it.

| Blackfathom Deeps' way in | The Sunken Temple's halls | Blackrock Mountain, its levels in the location bar |
|:---:|:---:|:---:|
| <img src="docs/images/map-blackfathom-way-in.jpg" alt="Ashenvale's map turned to the journal's drawn map of the way into Blackfathom Deeps, its sunken court and flooded caves, with the dungeon door's tooltip: Left-click to open the Instance Journal" width="280"> | <img src="docs/images/map-sunken-temple-halls.jpg" alt="The journal's drawn map of the Temple of Atal'Hakkar's halls down to the dungeon door, with a troll sketch, the door up to the Pool of Tears, and Pool of Tears and The Temple of Atal'Hakkar in the location bar's menu" width="280"> | <img src="docs/images/map-blackrock-mountain.jpg" alt="Blackrock Mountain's ring over the lava with Blackrock Spire's dungeon door, Blackwing Lair marked and the doors between levels, and the levels menu open: Blackrock Spire, Blackrock Mountain, Blackrock Depths" width="280"> |
| **Fargodeep Mine** | **Echo Ridge Mine, with your arrow** | **Dire Maul's ruins, with your arrow** |
| <img src="docs/images/map-fargodeep-mine.jpg" alt="Elwynn Forest's Fargodeep Mine on its own map, with the door down to its lower level and a kobold miner sketch, beside the map legend" width="280"> | <img src="docs/images/map-echo-ridge-mine.jpg" alt="Elwynn Forest's map turned to Echo Ridge Mine, with the player's arrow inside the mine" width="280"> | <img src="docs/images/map-dire-maul-ruins.jpg" alt="The ruins of Dire Maul on the world map, a dungeon icon at each of the wings' five doors, the player's arrow and the map legend" width="280"> |

### 🧭 World map

- **Every dungeon and raid door**, with retail's portal icons: **left-click**
  opens the journal, **right-click** offers a waypoint link in the chat. Wings that share a door
  (Scarlet Monastery, Blackrock Mountain) share one icon with a menu.
- **Cave and building entrances** mark the ways in, each with its own switch in
  the legend. A dungeon's floors, and Blackrock Mountain's levels, are one more
  step of the map's location bar.
- **Flight masters** on zone maps, and the **boats, zeppelins, airships, trams
  and portals** where Forever actually put them: blue for the Alliance, red for the
  Horde, gold for everyone.
- **Quest marks that follow your log**: **!** where an available quest starts,
  a grey **!** where one you can't take yet starts (its tooltip says what it
  needs), **?** where a finished one is handed in.
- The map's **Quests** and **Map Legend** tabs are back, and the legend lights
  up the journal's icons. Click one of the journal's icons in the legend to hide
  those on the map; the game's own quest icons follow the game's map filters.
- **Zone level ranges**: hover a zone on a continent map and its range shows
  after its name, coloured for your level, Forever's new zones included.
- **The map's filter menu** has an Instance Journal part: tick **Show unexplored
  areas** to see the parts of a zone you haven't explored yet, a little darker, and
  untick dungeon or raid entrances, flight points, cave entrances,
  or boats, zeppelins, trams and portals to hide them.

| Kalimdor: the legend's Transport | Eastern Kingdoms: the filter menu |
|:---:|:---:|
| <img src="docs/images/world-map-kalimdor-transport.jpg" alt="Kalimdor with dungeon and raid doors and transports, and the legend's Transport tooltip: blue serves the Alliance, red the Horde, gold everyone" width="430"> | <img src="docs/images/world-map-eastern-kingdoms-filter.jpg" alt="Eastern Kingdoms with dungeon doors, cave entrances and transports, and the map's filter menu open on its Instance Journal part" width="430"> |
| **Feralas: the wings' doors and the way into the ruins** | **Riverglades: Show unexplored areas** |
| <img src="docs/images/world-map-feralas.jpg" alt="Feralas with Dire Maul's three wing doors and the entrance icon of its ruins" width="430"> | <img src="docs/images/world-map-unexplored.png" alt="Riverglades with Show unexplored areas ticked in the map's filter menu, the parts not yet explored a little darker" width="430"> |

### 🛡️ Reputation

- **A card per faction** with its crest and your standing, and WoW: Forever's
  emblem on the factions it added.
- **Each standing's rewards**, filtered like loot, with what the quartermaster asks
  for each: gold, and any other cost.
- **Captured in game, first hand.** Open a quartermaster's shop, then press
  **Capture vendor** on the Reputation tab: every ware, its price and the standing
  it needs join the faction at once.
- **Until then, the game's own list.** A faction nobody has captured yet shows the
  rewards the game's item data lists for it, marked *unconfirmed* and without
  prices. A capture confirms each one it finds.

| Factions | A faction's rewards |
|:---:|:---:|
| <img src="docs/images/reputation.png" alt="The Reputation tab's faction cards" width="430"> | <img src="docs/images/reputation-faction.png" alt="The Azeroth Commerce Authority's rewards by standing, with the Type menu open" width="430"> |

### 🎯 Gear Finder

- **The best upgrade for every slot** waiting in the dungeons near your level, laid
  out like your character sheet: each marked with what it adds to all the gear you
  wear, and where it drops.
- **Pick from the top 3**: click a slot to see its three biggest upgrades and choose
  the one you want there; your picks are kept for each character. Right-click opens
  an item's loot in the journal.
- **The dungeon that holds the most of them**, and the others with upgrades, one
  click apart.
- **Scored for your spec**: the one your talents say, or one you pick. At level 60,
  15 specs start from stat weights taken from a simulator's presets. Change any
  **stat weight** in game, or bring in a Pawn scale with **Pawn...**, with or without
  the Pawn addon; your weights are kept for each character.
- **Works with Pawn**: with Pawn installed, choose once whose stat weights both use.
  The journal's: Pawn shows them for your spec, so its tooltips and upgrade arrows
  agree with the Gear Finder. Pawn's: the Gear Finder scores with your Pawn scale.
- **On the character panel too**: its own tab turns the panel to your character,
  with your stat weights where the stats are, and a button to the Gear Finder.

| Gear Finder | Stat weights on the character panel |
|:---:|:---:|
| <img src="docs/images/gear-finder.png" alt="The Gear Finder tab: an upgrade for each slot and the suggested dungeon" width="430"> | <img src="docs/images/gear-finder-weights.png" alt="The Stat Weights window over the character panel's stats" width="430"> |

### 🔍 Search

Three letters find dungeons, bosses, abilities, loot, quests and factions. A
click opens the right page.

### 🔴 Record: help fill in Forever's journal

- **Starts by itself** when you enter a dungeon and stops when you leave, and
  writes the game's combat log there for boss abilities.
- **Notes what the journal needs**: entrances, area names, boss kills, every drop
  (your loot window, your group's loot and group rolls), quests from offer to
  hand-in, quartermasters' wares (or press **Capture vendor** at any shop), and
  travel spots you mark.
- **What you caught** lists what the journal doesn't have yet. **Copy** turns it
  into text to paste in our Discord, and your name goes on the contributors list.
- **The [Log Reader](https://torchlite-bit.github.io/Aegis_Forever_Instance_Journal/log-reader/)**
  adds the bosses' spells from your combat log to that text, in your browser.
  Addons can't see enemy casts in Forever's dungeons, but the log can.

### ⚡ Light on your game

No polling while it sits idle, and pages are built the first time you open
them. `/aegis perf` measures it in your own game.

---

## Santiago Reyes's maps

The maps of **The Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands,
City of Dalaran, The Drowned City, Krol'dok Stronghold, Shaper's Terrace and Alcaz Prison** are
Santiago Reyes's, from his project *Atlas de Azeroth: Forever*. They are his own reinterpretations, not official World of Warcraft art,
and he isn't affiliated with Blizzard. Showing them in a video or a stream?
Please credit him in its description. Never alter them or remove his watermark.

**Support his maps:**
[Patreon](https://www.patreon.com/c/SantiagoReyesMaps) ·
[Ko-fi](https://ko-fi.com/sr433_20)

---

## Install

1. Get it from
   [**CurseForge**](https://www.curseforge.com/wow/addons/aegis-forever-instance-journal)
   (the CurseForge app keeps it updated). The folder inside is already named
   `Aegis_Forever_Instance_Journal`.
2. Put the folder in `World of Warcraft/_forever_/Interface/AddOns/`.
3. **Restart the client fully** (a `/reload` isn't enough the first time), then
   tick **Aegis Instance Journal** in the AddOns list.
4. Press **Shift+J**, or type `/aegis`.

---

## A few honest notes

- **Forever hides a lot inside its dungeons.** There's no player position there,
  so "you are here" comes from the area's name rather than an arrow.
- **The returning classic dungeons are new to Forever.** A few of their doors are
  only roughly placed, and some bosses have no spot on the map yet, until
  someone records a run.
- **Damage and timings come only from recorded runs.** Many bosses have none yet.
- **The announced dungeons and the raids** hold only what Blizzard has said so
  far. Their pages say *Coming soon*.

---

## Something broken?

1. Check the **version** in the AddOns list (`0.39.0`) and quote it.
2. A red line under **Recent** on the Record tab says what went wrong.
   Screenshot it.
3. Tell us on **[Discord](https://discord.gg/Hr66t25vE7)**.

Recent changes are in [CHANGELOG.md](CHANGELOG.md).

---

## License

All rights reserved: see [LICENSE](LICENSE). You can download the addon from its official pages
and play with it. Copying, changing, re-uploading or reusing it, or any part of it, needs
Torchlite's written permission: ask on [Discord](https://discord.gg/Hr66t25vE7). The code of
versions up to 0.38.0 was released under the MIT License, and copies of those keep it.

- **Torchlite's maps**, each signed "Redrawn by Torchlite", were all rights reserved from the
  start. See [LICENSE-MAPS.md](LICENSE-MAPS.md).
- **Santiago Reyes's maps** are his, used with his permission. See [CREDITS.md](CREDITS.md).

World of Warcraft, its art and its game data are Blizzard Entertainment's; this addon is not
made or endorsed by Blizzard.

---

<div align="center">

**[💬 Discord](https://discord.gg/Hr66t25vE7)** · **[🔥 CurseForge](https://www.curseforge.com/wow/addons/aegis-forever-instance-journal)** · **[📜 Changelog](CHANGELOG.md)** · **[📄 Credits](CREDITS.md)**

*Aegis: Forever Instance Journal is part of the Aegis addon series. Good hunting.* ⚔️

</div>
