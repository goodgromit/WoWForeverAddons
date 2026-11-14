# Credits

This addon is published with the agreement of the people below, who were asked again before
its public release (2026-10-11).

The addon is all rights reserved: see [LICENSE](LICENSE). The maps below that are other
people's keep their own terms.

The journal's code is its own, written for it. Its data (dungeons, bosses, loot, quests, maps'
boss spots, flight paths and travel routes, models and images) is the journal's own files,
checked against what is public on many sites, foreverchanges.pro first, and against what
the testers record in game. The world map's unexplored areas come from the client's own map
tables, as wago.tools exports them.

## Alex Atlas Loot

By Alex Brandson and its contributors. Its recorder and faction pages inspired the journal's
**Record** and **Reputation** tabs: recording on the way into a dungeon, a copy to paste in
Discord, a list of contributors, and each faction's rewards by standing. None of its code is
used.

## Santiago Reyes's maps

The maps of the Forever dungeons (The Hall of Thanes, Ruins of Lordaeron, Excavation Site:
Wetlands, City of Dalaran, The Drowned City, Krol'dok Stronghold, Shaper's Terrace and Alcaz Prison) are
Santiago Reyes's own reinterpretations, made for his project Atlas de Azeroth: Forever
(`Media/Maps/HallOfThanes.tga`, `RuinsOfLordaeron.tga`, `ExcavationSiteWetlands.tga`,
`CityOfDalaranCity.tga`, `CityOfDalaranSewers.tga`, `TheDrownedCity.tga`,
`TheDrownedCityAtalbyzal.tga`, `KroldokStronghold.tga`, `ShapersTerrace.tga`,
`ShapersTerracePrismaticTalus.tga`, `AlcazPrison.tga` and `AlcazPrisonMaximumSecurity.tga`). They
are not official World of Warcraft artwork, and he is not commercially or professionally
affiliated with Blizzard. He lets them be used free of charge, on these terms, which the
journal keeps:

- His watermark (the project's name, the map's title and the year) stays on every map. The
  journal only resizes his pictures and converts them to the game's texture format: nothing is
  cropped from them or drawn into them. The boss and quest marks are drawn over them in game,
  not into the files. A copy without the watermark would need his review.
- He is credited wherever the maps are used: here, in the README, in the addon's notes in the
  AddOns list, and in the testers' field guide.
- Anyone who shows the maps in a video or a stream (YouTube, Twitch, Kick and so on) should
  credit him in its description.
- The maps are not to be altered, nor their watermark removed, without his consent.
- What he shares about maps still in development stays private until he announces it himself.

Permission to share with testers, 2026-10-07; permission for all his maps, per the player,
2026-10-09; agreement to the public release, 2026-10-11. Donations to support his maps are
welcome, never required:
[Patreon](https://www.patreon.com/c/SantiagoReyesMaps),
[Ko-fi](https://ko-fi.com/sr433_20) or
[PayPal](https://www.paypal.com/donate/?cmd=_donations&business=reyes.guevara.santiago@gmail.com&item_name=WoWMaps&currency_code=USD).

## Torchlite's maps

The maps Torchlite makes or edits for the journal, each signed "Redrawn by Torchlite" low on the
map or wherever the map has room for it (`Media/Maps/ScarletMonasteryHall.tga`,
`BlackrockMountainRing.tga`, `BlackrockMountainMiddle.tga`, `Dungeons/blackfathom-deeps-full.tga`,
`Dungeons/stratholme-full.tga`, `Dungeons/the-deadmines-full.tga`,
`Dungeons/shadowfang-keep-full.tga`, `Dungeons/shadowfang-keep-4.tga`,
`OrgrimmarCleftOfShadow.tga`, `BlackfathomApproach.tga`, `GnomereganApproach.tga`,
`TirisfalNightWebsHollow.tga`, `RazorfenDownsApproach.tga`, `RazorfenDownsSkull.tga`,
`TempleOfAtalHakkarPool.tga` and `TempleOfAtalHakkarHalls.tga` so far), are drawn over Blizzard's
own map art. Torchlite's work in them is all rights reserved: see [LICENSE-MAPS.md](LICENSE-MAPS.md).

## Staree4ok's Russian translation

The journal in Russian is Staree4ok's work: its interface (`Locales/ruRU.lua`) and its
content, the dungeons', raids' and factions' names, bosses, abilities, quests and places
(`Locales/ruRU_content.lua`). It was contributed in pull request #25 and shows on a client
set to Russian.

## Drafted translations

The German, French, Spanish (Spain and Latin America), Brazilian Portuguese, Korean, Simplified
Chinese and Traditional Chinese translations (`Locales/deDE`, `frFR`, `esES`, `esMX`, `ptBR`,
`koKR`, `zhCN`, `zhTW` and their `_content` files) were drafted with Claude AI and have not yet
been checked by native speakers. Corrections are welcome, and so is anyone who
would like to take one of them on. The Russian translation is a native speaker's, but a few later
lines in `Locales/ruRU.lua` were drafted the same way and are marked "drafted, to be checked".

## Claude AI

This addon was created with the help of Claude AI, Anthropic's assistant.

---

World of Warcraft, its art and its game data are Blizzard Entertainment's. This addon is not
made or endorsed by Blizzard. The addon's icon is made from Blizzard's own art in the Forever
client (the Adventure Guide's book and the WoW: Forever emblem), recoloured. Its swirl comes in
each class's colour, from the game's own class colours.

## WoWSims

At level 60, the Gear Finder's default stat weights come from WoWSims, the Forever simulator
([wowsims.com/forever](https://wowsims.com/forever/),
[github.com/wowsims/forever](https://github.com/wowsims/forever)). Each spec the sim has weights
for uses one of its presets. `Data/Generated/SimsWeights.lua` names each one. A rating's weight is
given for 1%, as the journal weighs it. Below level 60, and for the other specs, the journal keeps
its own weights. None of the sim's code is used.

WoWSims is shared under the MIT License. Its notice follows:

```
MIT License

Copyright (c) 2022 wowsims team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
