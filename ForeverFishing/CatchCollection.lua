-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Direct, identifiable fishing catches. Contents of opened trunks, random gear,
-- weight variants, and one-time quest fish stay in the catch journal when caught,
-- but are not goals. Quest fish can become unobtainable; random container loot
-- and weight variants do not form a reliable, fixed Forever collection.
-- Best waters are useful leads, not exhaustive loot tables. The skill target is
-- the Forever zone's reported 100% catch skill, not a minimum to cast. Equipment
-- and lures count toward effective skill. Forever beta tables can still change.
-- Sources: Wowhead Forever Fishing overview, item fishing locations, and
-- Classic item records where Forever observations remain sparse.
-- https://www.wowhead.com/forever/guide/professions/fishing/overview-leveling
-- https://www.wowhead.com/classic/guide/fishing-fun-items
-- https://www.wowhead.com/forever/item=251524/whimsyfin
local function Catch(id, name, waters, skill, method, condition, rarity)
    return { id, name, { waters = waters, skill = skill, method = method, condition = condition },
        rareTier = rarity == "ultra" and "ultra" or (rarity == true and "rare" or nil) }
end
local function Faction(alliance, horde)
    return { Alliance = alliance, Horde = horde }
end

local entries = {
    Catch(6291, "Raw Brilliant Smallfish", Faction("Elwynn Forest rivers", "Durotar rivers"), 25, "Inland open water"),
    Catch(6303, "Raw Slitherskin Mackerel", Faction("Teldrassil coast", "Durotar coast"), 25, "Coastal open water"),
    Catch(6289, "Raw Longjaw Mud Snapper", Faction("Stormwind canals or Loch Modan lakes", "Orgrimmar or Thunder Bluff waters"), 75, "Inland open water"),
    Catch(6317, "Raw Loch Frenzy", "Loch Modan, especially Loch Modan's main lake", 75, "Inland open water"),
    Catch(6522, "Deviate Fish", "The Barrens oasis pools or Wailing Caverns", 75, "Deviate Fish schools or inland water"),
    Catch(6358, "Oily Blackmouth", Faction("Darkshore coast", "The Barrens coast"), 75, "Blackmouth schools or coastal water"),
    Catch(6361, "Raw Rainbow Fin Albacore", "Westfall or Darkshore coast", 75, "Coastal open water"),
    Catch(6308, "Raw Bristle Whisker Catfish", Faction("Redridge or Wetlands rivers and lakes", "The Barrens or Hillsbrad inland water"), 150, "Inland open water"),
    Catch(6359, "Firefin Snapper", Faction("Wetlands coast", "Hillsbrad coast"), 150, "Firefin schools or coastal water"),
    Catch(6362, "Raw Rockscale Cod", "Stranglethorn or Dustwallow Marsh coast", 225, "Coastal open water"),
    Catch(21071, "Raw Sagefish", "Ashenvale or Wetlands rivers", 150, "Sagefish schools"),
    Catch(21153, "Raw Greater Sagefish", "Alterac Mountains' Lake Lordamere shore or Stranglethorn rivers", 225, "Greater Sagefish schools"),
    Catch(8365, "Raw Mithril Head Trout", "Dustwallow Marsh or Stranglethorn rivers", 225, "Inland open water"),
    Catch(4603, "Raw Spotted Yellowtail", "Tanaris or Feralas coast", 300, "Coastal open water"),
    Catch(13422, "Stonescale Eel", "Tanaris or Feralas coast", 300, "Stonescale Eel schools or coastal water", "More common at night."),
    Catch(13754, "Raw Glossy Mightfish", "Tanaris or Feralas coast", 300, "Coastal open water"),
    Catch(13755, "Raw Winter Squid", "Tanaris or Feralas coast", 300, "Coastal open water", "Winter season; limited overlap in spring and autumn."),
    Catch(13756, "Raw Summer Bass", "Tanaris or Feralas coast", 300, "Coastal open water", "Summer season; limited overlap in spring and autumn."),
    Catch(13758, "Raw Redgill", "Felwood or Feralas lakes", 300, "Inland open water"),
    Catch(13759, "Raw Nightfin Snapper", "Moonglade or Felwood lakes", 300, "Inland open water", "Most common at night."),
    Catch(13760, "Raw Sunscale Salmon", "Moonglade or Felwood lakes", 300, "Inland open water", "Daytime catch."),
    Catch(13889, "Raw Whitescale Salmon", "Winterspring lakes", 425, "Inland open water"),
    Catch(13888, "Darkclaw Lobster", "Azshara, Bay of Storms", 425, "Coastal open water"),
    Catch(13893, "Large Raw Mightfish", "Azshara, Bay of Storms", 425, "Coastal open water"),
    Catch(12238, "Darkshore Grouper", "Darkshore coast near Auberdine", 75, "Coastal open water",
        { Alliance = "Needed for The Family and the Fishing Pole." }),
    Catch(19975, "Zulian Mudskunk", "Zul'Gurub rivers", 425, "Muddy Churning Waters only", "Inside the Zul'Gurub raid."),
    Catch(19807, "Speckled Tastyfish", "Stranglethorn coast, outside Booty Bay", 225, "Schools of Tastyfish only", "Stranglethorn Fishing Extravaganza, Sunday 2–4 p.m. server time."),
    Catch(19803, "Brownell's Blue Striped Racer", "Stranglethorn coast, outside Booty Bay", 225, "Schools of Tastyfish only", "Rare tournament catch. Turn in to Fishbot 5000.", true),
    Catch(19805, "Keefer's Angelfish", "Stranglethorn coast, outside Booty Bay", 225, "Schools of Tastyfish only", "Rare tournament catch. Turn in to Fishbot 5000.", true),
    Catch(19806, "Dezian Queenfish", "Stranglethorn coast, outside Booty Bay", 225, "Schools of Tastyfish only", "Rare tournament catch. Turn in to Fishbot 5000.", true),
    Catch(19808, "Rockhide Strongfish", "Stranglethorn coast, outside Booty Bay", 225, "Schools of Tastyfish only", "Rare tournament catch.", true),
    Catch(6643, "Bloated Brilliant Smallfish", Faction("Elwynn Forest rivers", "Durotar rivers"), 25, "Inland open water", "Rare catch alongside Raw Brilliant Smallfish.", true),
    Catch(6645, "Bloated Mud Snapper", "Stormwind canals or Loch Modan lakes", 75, "Inland open water", "Rare catch alongside Raw Longjaw Mud Snapper.", true),
    Catch(6647, "Bloated Catfish", Faction("Redridge rivers", "Ashenvale rivers"), 150, "Inland open water", "Rare catch alongside Raw Bristle Whisker Catfish.", true),
    Catch(8366, "Bloated Trout", "Dustwallow Marsh or Stranglethorn rivers", 225, "Inland open water", "Rare catch alongside Raw Mithril Head Trout.", true),
    Catch(13881, "Bloated Redgill", "Felwood or Feralas lakes", 300, "Inland open water", "Rare catch alongside Raw Redgill.", true),
    Catch(13891, "Bloated Whitescale Salmon", "Winterspring lakes", 425, "Inland open water", "Rare catch alongside Raw Whitescale Salmon.", true),
    Catch(21163, "Bloated Firefin Snapper", Faction("Wetlands coast", "Hillsbrad coast"), 150, "Firefin schools", "Rare catch alongside Firefin Snapper.", true),
    Catch(21164, "Bloated Rockscale Cod", "Desolace or Stranglethorn coast", 225, "Coastal open water", "Rare catch alongside Raw Rockscale Cod.", true),
    Catch(13757, "Lightning Eel", "Feralas inland water", 300, "Inland open water"),
    Catch(13890, "Raw Plated Armorfish", "Eastern Plaguelands inland water", 425, "Inland open water"),
    Catch(6360, "Steelscale Crushfish", Faction("Wetlands water", "Hillsbrad water"), 150, "Open water", "Rare catch.", "ultra"),
    Catch(6458, "Oil Covered Fish", "Windshear Crag, Stonetalon Mountains", 150, "Oil Spill pools only"),
    Catch(6299, "Sickly Looking Fish", Faction("Blackfathom Deeps", "Undercity canals or Blackfathom Deeps"), 75, "Inland open water"),
    Catch(251524, "Whimsyfin", "Redridge, east of Lake Everstill", 150, "Whimsyfin schools only"),
    Catch(8350, "The 1 Ring", Faction("Stormwind canals", "Orgrimmar waters"), 75, "Inland open water", "Very rare catch.", "ultra"),
    Catch(6301, "Old Teamster's Skull", "Tirisfal Glades rivers", 25, "Inland open water", "Rare catch."),
    Catch(6307, "Message in a Bottle", "Darkshore or Westfall coast", 75, "Coastal open water", "Rare catch."),
    Catch(3820, "Stranglekelp", "Wetlands coast", 150, "Coastal pools or wreckage"),
    Catch(5523, "Small Barnacled Clam", Faction("Westfall coast", "Durotar coast"), 75, "Coastal open water"),
    Catch(5524, "Thick-shelled Clam", Faction("Ashenvale coast", "Hillsbrad coast"), 150, "Coastal open water"),
    Catch(7973, "Big-mouth Clam", "Tanaris or Azshara coast", 300, "Coastal open water"),
    Catch(20709, "Rumsey Rum Light", Faction("Darkshore coast", "The Barrens coast"), 75, "Fish schools or floating debris"),
    Catch(21114, "Rumsey Rum Dark", Faction("Wetlands coast", "Hillsbrad coast"), 150, "Fish schools or wreckage"),
    Catch(21151, "Rumsey Rum Black Label", "Stranglethorn coast", 225, "Fish schools or wreckage"),
    Catch(6351, "Dented Crate", "Darkshore or Westfall coast", 75, "Coastal open water or debris"),
    Catch(6352, "Waterlogged Crate", Faction("Wetlands coast", "Hillsbrad coast"), 150, "Coastal open water or wreckage"),
    Catch(6353, "Small Chest", "Westfall or Darkshore coast", 75, "Coastal open water or debris"),
    Catch(6357, "Sealed Crate", "Desolace or Dustwallow Marsh coast", 225, "Coastal open water or wreckage"),
    Catch(13874, "Heavy Crate", "Tanaris or Azshara coast", 300, "Coastal open water or wreckage"),
    Catch(20708, "Tightly Sealed Trunk", Faction("Darkshore or Westfall coast", "The Barrens coast"), 75, "Floating Debris pools"),
    Catch(21113, "Watertight Trunk", Faction("Wetlands coast", "Hillsbrad coast"), 150, "Wreckage pools"),
    Catch(21150, "Iron Bound Trunk", "Desolace, Dustwallow Marsh, or Stranglethorn coast", 225, "Wreckage pools"),
    Catch(21228, "Mithril Bound Trunk", "Feralas, Tanaris, or Azshara coast", 300, "Wreckage pools"),
}

table.sort(entries, function(a, b) return a[2] < b[2] end)
FF.catchCollection = entries
FF.catchCollectionByID = {}
for _, entry in ipairs(entries) do FF.catchCollectionByID[entry[1]] = entry end
