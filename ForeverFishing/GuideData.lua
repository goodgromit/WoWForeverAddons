-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Verified Forever Apprentice/Journeyman teachers only. Expert uses a book;
-- Artisan uses a quest. See development docs/fishing-route-sources.md.
local fishingTrainers = {
    {"Androl Oakhand", "Rut'theran Village, Teldrassil", "Alliance", 1438, 55.8, 93.6},
    {"Arnold Leland", "Canals, Stormwind", "Alliance", 1453, 55.0, 69.6},
    {"Astaia", "Darnassus", "Alliance", 1457, 47.6, 56.6},
    {"Brannock", "Feathermoon Stronghold, Feralas", "Alliance", 1444, 32.2, 41.6},
    {"Donald Rabonne", "Southshore, Hillsbrad Foothills", "Alliance", 1424, 50.6, 61.0},
    {"Grimnur Stonebrand", "Forlorn Cavern, Ironforge", "Alliance", 1455, 48.4, 6.4},
    {"Harold Riggs", "Menethil Harbor, Wetlands", "Alliance", 1437, 8.2, 58.6},
    {"Lee Brown", "Crystal Lake, Elwynn Forest", "Alliance", 1429, 47.6, 62.2},
    {"Matthew Hooper", "Lakeshire, Redridge Mountains", "Alliance", 1433, 26.8, 50.4},
    {"Paxton Ganter", "Iceflow Lake, Dun Morogh", "Alliance", 1426, 35.6, 40.4},
    {"Warg Deepwater", "Loch Modan", "Alliance", 1432, 40.6, 39.6},
    {"Armand Cromwell", "Magic Quarter, Undercity", "Horde", 1458, 80.8, 31.2},
    {"Clyde Kellen", "Brightwater Lake, Tirisfal Glades", "Horde", 1420, 67.2, 51.0},
    {"Kah Mistrunner", "Middle Tier, Thunder Bluff", "Horde", 1456, 56.0, 46.8},
    {"Katoom the Angler", "Revantusk Village, The Hinterlands", "Horde", 1425, 80.2, 81.4},
    {"Kil'Hiwana", "Ashenvale, south of Blackfathom Deeps", "Horde", 1440, 10.8, 33.6},
    {"Lui'Mala", "Shadowprey Village, Desolace", "Horde", 1443, 22.6, 72.6},
    {"Lumak", "Valley of Honor, Orgrimmar", "Horde", 1454, 69.8, 29.6},
    {"Uthan Stillwater", "Bloodhoof Village, Mulgore", "Horde", 1412, 44.6, 60.6},
    {"Baelann Swiftcurrent", "Valanaar, Zephras Isle", "Neutral", "Zephras Isle", 63.2, 75.8},
    {"Fenn Fairweather", "Shen'dar Village, Zephras Isle", "Neutral", "Zephras Isle", 45.0, 48.4},
    {"Krix", "Powderfuse Port, Riverglades", "Neutral", "Riverglades", 79.2, 54.8},
    {"Myizz Luckycatch", "Booty Bay, Stranglethorn Vale", "Neutral", 1434, 27.6, 77.0},
}

function FF:GetFishingTrainingSources(rank, faction)
    local points = {}
    if rank ~= "Apprentice" and rank ~= "Journeyman" then return points end
    if faction ~= "Alliance" and faction ~= "Horde" then return points end
    for _, trainer in ipairs(fishingTrainers) do
        if trainer[3] == faction or trainer[3] == "Neutral" then
            points[#points + 1] = {kind="map", name=trainer[1], location=trainer[2],
                label=trainer[1] .. ", " .. trainer[2], faction=trainer[3], rank=rank,
                sellsPole=trainer[1] == "Baelann Swiftcurrent" or trainer[1] == "Katoom the Angler",
                mapID=self:GetGuideMapID(trainer[4]), x=trainer[5]/100, y=trainer[6]/100}
        end
    end
    return self:GetOrderedGuideMapPoints(points, true)
end

-- Native trained caps and verified Journal training requirements. These are
-- base-skill/level requirements, independent of temporary fishing bonuses.
FF.fishingRankInfo = {
    [75] = {name="Apprentice", nextCap=150},
    [150] = {name="Journeyman", minSkill=50, minLevel=10, nextCap=225},
    [225] = {name="Expert", minSkill=125, minLevel=20, nextCap=300},
    [300] = {name="Artisan", minSkill=225, minLevel=35},
}

function FF:GetFishingTrainingCallout(block)
    local heading
    for _, rank in pairs(self.fishingRankInfo) do
        if rank.name == block.trainingRank and rank.minSkill then
            heading = string.format("Next training • %s • Skill %d, Level %d; {trainer}",
                rank.name, rank.minSkill, rank.minLevel)
            break
        end
    end
    if block.trainingRank == "Journeyman" then
        return heading,
            "Train before the 75 skill cap; raises your cap to 150."
    elseif block.trainingRank == "Expert" then
        return heading,
            "Buy Expert Fishing – The Bass and You, then read it to raise your cap to 225."
    elseif block.trainingRank == "Artisan" then
        local fish = block.body:match("\n(.*)")
        return heading,
            "For Nat Pagle, Angler Extreme, catch:\n" .. fish
    end
end

-- Pole-selling roles are verified separately from teaching roles. Reuse the
-- accepted recipe-vendor map records; never infer a shop from a trainer name.
function FF:GetFishingPoleSources(faction)
    local verified = { ["Tharynn Bouden"]=true, ["Gretta Ganter"]=true,
        ["Nessa Shadowsong"]=true, ["Catherine Leland"]=true, ["Tansy Puddlefizz"]=true,
        ["Khara Deepwater"]=true, ["Stuart Fleming"]=true, ["Lindea Rabonne"]=true,
        ["Zansoa"]=true, ["Sewa Mistrunner"]=true, ["Lizbeth Cromwell"]=true, ["Wik'Tar"]=true }
    local points, seen = {}, {}
    for _, meal in ipairs(self.masterChefMeals or {}) do
        for _, point in ipairs(self:GetMealRecipeMapPoints(meal.id, faction) or {}) do
            if verified[point.name] and not seen[point.name] then
                seen[point.name] = true; point.sellsPole = true
                points[#points+1] = point
            end
        end
    end
    for _, point in ipairs(self:GetFishingTrainingSources("Apprentice", faction)) do
        if point.sellsPole then points[#points+1] = point end
    end
    return self:GetOrderedGuideMapPoints(points, true)
end

-- The canonical bodies below remain the searchable reference. These rows
-- divide that exact advice and add explicit training context, not new routes.
function FF:GetFishingRouteRows(block, faction, combinePole)
    local body = type(block.body) == "table" and block.body[faction] or block.body
    local first, rest = body:match("^(.-%.)%s+(.*)$")
    if block.heading:find("1–75", 1, true) == 1 then
        local waters, bait = rest:match("^(.-%.)%s+(.*)$")
        return {{"Start", "Train Apprentice Fishing; {trainer}."},
            {"Supplies", "Buy a pole from a fishing supplier; {supplier}."},
            {"Waters", waters}, {"Bait", bait}}, "Apprentice"
    elseif block.heading:find("75–150", 1, true) == 1 then
        return {{"Start", "Learn Journeyman Fishing (Skill 50, Level 10; cap 150); {trainer}."},
            {"Waters", body}}, "Journeyman"
    elseif block.heading:find("150–225", 1, true) == 1 then
        return {{"Start", "Read Expert Fishing – The Bass and You (Skill 125, Level 20; cap 225); {trainer}."},
            {"Waters", body}}, "Expert"
    elseif block.heading:find("225–300", 1, true) == 1 then
        local bait, advice = rest:match("^(.-%.)%s+(.*)$")
        return {{"Start", "Complete Nat Pagle, Angler Extreme (Skill 225, Level 35; cap 300); {trainer}."},
            {"Waters", first .. " " .. advice}, {"Bait", bait}}, "Artisan"
    end
end

-- Quest hover facts reuse the canonical guide/source notes below and the
-- existing Camping 101 reference ID. Missing IDs/requirements stay unknown;
-- guide-use item IDs are not quest IDs. No quest-log membership is required.
FF.journalQuestReferences = {
    {title="Nat Pagle, Angler Extreme", mapLabel="Nat Pagle",
        summary="Catch Feralas Ahi in the Verdantis River, Misty Reed Mahi Mahi off southeast Swamp of Sorrows, Sar'theris Striker off Desolace and Savage Coast Blue Sailfin off Stranglethorn. Return to Nat Pagle in Dustwallow Marsh.",
        requirements="Fishing 225 • Level 35", rewards="Artisan Fishing • skill cap 300"},
    {title="The Family and the Fishing Pole",
        summary="Fish six Darkshore Grouper near Auberdine and return to Gubber Blump.",
        requirements="Alliance • Level 10", rewards="Blump Family Fishing Pole • +3 Fishing"},
    {title="Gaffer Jacks", questID=1579, mapLabel="Wizbang Cranktoggle",
        summary="Fish 8 Gaffer Jacks near Auberdine and return to Wizbang Cranktoggle.", requirements="Alliance"},
    {title="Electropellers", questID=1580, mapLabel="Wizbang Cranktoggle",
        summary="Finish Gaffer Jacks. Fish 12 Electropellers in Darkshore and return to Wizbang Cranktoggle.",
        requirements="Alliance", rewards="20 × Aquadynamic Fish Lens"},
    {title="Snapjaws, Mon!",
        summary="Kill 15 Saltwater Snapjaws on the coast north of Revantusk Village, then return to Katoom the Angler.",
        requirements="Horde • Level 44", rewards="Nat Pagle's Extreme Angler FC-5000 • +25 Fishing; requires Fishing 100"},
    {title="Bottles and Baubles", questID=99143, mapLabel="Lee Brown",
        summary="Collect 6 Shiny Junk from the murloc camps on Crystal Lake's south shore and return to Lee Brown.",
        requirements="Alliance", rewards="Shiny Silver Coin • +30 Fishing for 30 minutes"},
    {title="Camping 101: Fishing", questID=97920,
        summary="Your starting-zone camping guide sends you to a Fishing trainer for Fish Bowl training.",
        requirements="Level 4 • Fishing 20 • introductory camping chain: The Adventurer, then The Great Outdoors",
        rewards="Fish Bowl training", note="A campfire is required before placing the bowl."},
    {title="The Adventurer", summary="Starts the introductory camping chain, before The Great Outdoors and Camping 101: Fishing.",
        note="Further objectives, requirements and rewards are not yet verified."},
    {title="The Great Outdoors", summary="Continues the introductory camping chain after The Adventurer and before Camping 101: Fishing.",
        note="Further objectives, requirements and rewards are not yet verified."},
}

function FF:GetJournalQuestReference(title)
    for _, quest in ipairs(self.journalQuestReferences) do
        if quest.title == title then return quest end
    end
end

-- Curated for the Forever beta. Classic routes remain useful, while entries
-- explicitly marked Forever come from the 1.60.1 beta profession data.
FF.guideTabs = {
    {
        id = "leveling",
        label = "Leveling route",
        title = "Fishing 1–300",
        subtitle = "Where to fish and when to train",
        blocks = {
            {
                heading = "1–75  •  Starting waters",
                body = "Train Apprentice Fishing and buy a pole from a fishing supplier. Fish inland near your starting area for Raw Brilliant Smallfish, or try the coast for Raw Slitherskin Mackerel. Use a Shiny Bauble if fish keep escaping.",
            },
            {
                heading = "Journeyman Fishing  •  Skill 50, Level 10 required",
                body = "Return to a Fishing trainer to learn Journeyman before you reach the 75 skill cap. This raises your cap to 150.",
            },
            {
                heading = "75–150  •  City waters",
                body = {
                    Alliance = "Fish in Stormwind or Darnassus for early Cooking fish. Some Ironforge water may not be fishable on modern Classic clients.",
                    Horde = "Fish in Orgrimmar or Thunder Bluff for early Cooking fish.",
                },
            },
            {
                heading = "Expert Fishing  •  Skill 125, Level 20 required",
                body = "Buy Expert Fishing – The Bass and You from Old Man Heming at the Happy Bobber in lower Booty Bay (27.4, 77). Read it to raise your skill cap to 225.",
            },
            {
                heading = "150–225  •  Intermediate waters",
                body = "Try Dustwallow Marsh or the Stranglethorn Vale coast. If fish escape too often, fish in Ashenvale, Wetlands, or Stonetalon until your skill catches up.",
            },
            {
                heading = "Artisan Fishing  •  Skill 225, Level 35 required",
                body = "Visit Nat Pagle on the island southwest of Theramore (59, 60). For the \"Nat Pagle, Angler Extreme\" quest, catch:\n• Feralas Ahi — Verdantis River (62, 51).\n• Misty Reed Mahi Mahi — southeast Swamp of Sorrows coast (90, 72).\n• Sar'theris Striker — Desolace (25, 77).\n• Savage Coast Blue Sailfin — Stranglethorn (33, 32).",
            },
            {
                heading = "225–300  •  Final stretch",
                body = "Fish in Feralas, The Hinterlands, Tanaris, Un'Goro, Felwood, or Western Plaguelands. Use a lure if your skill is low for the water. Level Cooking with your catches, or look for valuable pools.",
            },
        },
    },
    {
        id = "gear",
        label = "Gear & skill",
        title = "Fishing skill kit",
        subtitle = "Choose gear and lures that raise your Fishing skill",
        blocks = {
            {
                heading = "Fishing poles", body = "Equipment bonuses apply while the pole is equipped.",
                items = {
                    {id=12225, name="Blump Family Fishing Pole", benefit="+3 Fishing · equipped pole", faction="Alliance",
                        requirements="Fishing 1; quest requires Level 10.", quest="The Family and the Fishing Pole", start="Gubber Blump in Auberdine, Darkshore"},
                    {id=6365, name="Strong Fishing Pole", benefit="+5 Fishing · equipped pole", suppliers=true,
                        requirements="Level 5 · Fishing 10.", acquisition="Buy from a fishing supplier. Stock can be limited."},
                    {id=6367, name="Big Iron Fishing Pole", benefit="+20 Fishing · equipped pole",
                        requirements="Level 25 · Fishing 100.", acquisition="Open underwater Shellfish Traps off Shadowprey Village in Desolace, or check the Auction House. A pole is not guaranteed."},
                    {id=19022, name="Nat Pagle's Extreme Angler FC-5000", benefit="+25 Fishing · equipped pole", faction="Horde",
                        requirements="Fishing 100; quest requires Level 44.", quest="Snapjaws, Mon!", start="Katoom the Angler in Revantusk Village, The Hinterlands (80.2, 81.4)"},
                    {id=19970, name="Arcanite Fishing Pole", benefit="+35 Fishing · equipped pole",
                        requirements="Fishing 300.", tournament=true},
                },
            },
            {
                heading = "Lures", body = "Temporary pole enchants: applying another lure replaces the current lure. Check each native tooltip for its duration.",
                items = {
                    {id=6529, name="Shiny Bauble", benefit="+25 Fishing · temporary lure", requirements="Fishing 1.", suppliers=true, acquisition="Buy from a fishing supplier."},
                    {id=6530, name="Nightcrawlers", benefit="+50 Fishing · temporary lure", requirements="Fishing 50.", suppliers=true, acquisition="Buy from a fishing supplier."},
                    {id=6811, name="Aquadynamic Fish Lens", benefit="+50 Fishing · temporary lure", requirements="Fishing 50.", faction="Alliance",
                        acquisition="Complete Gaffer Jacks, then Electropellers. Return to Wizbang Cranktoggle in Auberdine for 20 × Aquadynamic Fish Lens."},
                    {id=6532, name="Bright Baubles", benefit="+75 Fishing · temporary lure", requirements="Fishing 100.", suppliers=true, acquisition="Buy from a fishing supplier."},
                    {id=7307, name="Flesh Eating Worm", benefit="+75 Fishing · temporary lure", requirements="Fishing 100.", acquisition="Loot Rotted Ones in Duskwood. A worm is not guaranteed."},
                    {id=6533, name="Aquadynamic Fish Attractor", benefit="+100 Fishing · temporary lure", requirements="Fishing 100.", suppliers=true,
                        acquisition="Engineers craft this lure; some fishing suppliers also stock it in limited quantities. Engineering recipe requirements and materials are not verified in this guide."},
                },
            },
            {
                heading = "Fishing food", body = "Tooltip Fishing bonuses last 15 minutes after eating for 10 seconds. Confirm the effective skill change on your client; some beta reports disagree with the tooltip.",
                items = {
                    {id=6316, meal=true, bonus=3, level=5},
                    {id=5476, meal=true, bonus=5, level=5},
                    {id=4593, meal=true, bonus=8, level=15},
                    {id=4594, meal=true, bonus=12, level=25},
                    {id=13930, meal=true, bonus=18, level=35},
                    {id=8957, name="Spinefin Halibut", meal=true, benefit="+18 Fishing · 15 min", requirements="Level 45.",
                        acquisition="Buy the prepared food from fish vendors or cook it with Raw Spinefin Halibut."},
                },
            },
            {
                heading = "Fishing gear and upgrades", body = "Tournament rare catches come from Stranglethorn's Tastyfish pools during the event. Equipment and permanent enchants are distinct from temporary lures.",
                items = {
                    {id=19972, name="Lucky Fishing Hat", benefit="+5 Fishing · equipped hat", catch="Keefer's Angelfish"},
                    {id=19969, name="Nat Pagle's Extreme Anglin' Boots", benefit="+5 Fishing · equipped boots", catch="Brownell's Blue Striped Racer"},
                    {id=19971, name="High Test Eternium Fishing Line", benefit="+5 Fishing · permanent pole enchant", catch="Dezian Queenfish",
                        acquisition="Apply the line to a pole you plan to keep; this is a permanent upgrade, separate from a temporary lure."},
                    {key="glove-enchant", name="Enchant Gloves – Fishing", spellName="Enchant Gloves - Fishing", icon="Interface\\Icons\\INV_Enchant_FormulaGood_01",
                        benefit="+2 Fishing · permanent glove enchant", acquisition="Ask an Enchanter to apply Enchant Gloves – Fishing to your gloves. Enchanting recipe acquisition and materials are not verified in this guide."},
                },
            },
            {
                heading = "Legacy perks",
                body = "Luremaster gives a 25% chance to catch an extra fish while a lure is active, rising to 50% at rank 2. Working Overtime increases the chance to gain a tradeskill point by 4% at its first rank, including Fishing. Dedicated Study can raise Fishing by one point if it is your lowest tradeskill; 25-second cast, 23-hour cooldown. Field Guide reduces the cooldown for placing fishing camp features. Learn these through the Legacy system; consult its current rank tooltips for higher-rank values.",
            },
            {
                heading = "Forever buffs and useful tools", body = "Buffs, camp contributions and utility effects are separate from permanent equipment bonuses.",
                items = {
                    {id=286732, name="Shiny Silver Coin", benefit="+30 Fishing · 30 min", quest="Bottles and Baubles",
                        acquisition="For Bottles and Baubles, collect 6 Shiny Junk from the murloc camps on Crystal Lake's south shore. Return to Lee Brown."},
                    {id=259846, name="Wide-Brimmed Fishing Hat", benefit="+25 Fishing · 10 min temporary lure",
                        acquisition="Use the hat to attach its lure to your equipped pole (10-minute use cooldown). This is not a permanent clothing Fishing bonus. Acquisition and equip requirements are not yet verified."},
                    {id=279981, camp=true}, {id=279967, camp=true}, {id=279965, camp=true}, {id=279966, camp=true},
                    {id=273636, name="Chef's Knife", benefit="Prepares Seasonal Fish Steaks · camp ingredient", suppliers=true,
                        requirements="Level 35 · Fishing 275.", acquisition="Buy the knife from a fishing supplier. Use it to prepare Seasonal Fish Steaks from Raw Summer Bass or Raw Winter Squid for the Fishing Hut."},
                    {id=19979, name="Hook of the Master Angler", benefit="Fish form · utility", coin=true,
                        acquisition="Check the native item tooltip for form restrictions and cooldown; this is not a permanent Fishing-skill upgrade."},
                    {id=276274, name="Surfer Shoes", benefit="Water movement · utility", coin=true,
                        acquisition="Check the native item tooltip for movement restrictions and cooldown; this is not a permanent Fishing-skill upgrade."},
                },
            },
            {
                heading = "Additional pole and bait references", body = "These entries are not confirmed shopping or catch routes. Current acquisition or availability remains unverified.",
                items = {
                    {id=285094, name="Ravaged Fishing Pole", benefit="+31 Fishing · equipped pole", requirements="Level 20 · Fishing 50.", acquisition="Listed in the current Forever item database; its acquisition source is not yet verified."},
                    {id=6366, name="Darkwood Fishing Pole", benefit="+15 Fishing · equipped pole", requirements="Level 15 · Fishing 50.", acquisition="A current Forever drop or vendor source is not verified."},
                    {id=7996, name="Worn Fishing Hat", benefit="+13 Fishing · equipped hat", requirements="Level 15 · Fishing 1.", acquisition="Current availability and acquisition are not verified."},
                    {id=268880, name='"Secret" Bait', benefit="+25 Fishing · 10 min temporary lure", acquisition="The Forever client records this pole lure. Its acquisition and additional requirements are not verified."},
                },
            },
            {
                heading = "Set up your Gear button",
                body = "Forever Fishing picks the strongest fishing pole and clothing that raises Fishing skill from your bags or equipped slots. Use the Gear arrow to change items, or drag a missed item onto the icon. Click Gear to equip your picks; click again to restore your previous items. The gold glow means some selected gear is not equipped.",
            },

        },
    },
    {
        id = "rares",
        label = "Rare catches",
        title = "Rare & valuable waters",
        subtitle = "Where to fish for rare and seasonal catches",
        blocks = {
            {
                heading = "Stranglethorn Fishing Extravaganza",
                body = "Every Sunday, 2–4 p.m. server time. You do not need to register.\n• Fish Schools of Tastyfish along the Stranglethorn coast, outside Booty Bay. Your bobber must land inside a pool.\n• Catch 40 Speckled Tastyfish and turn them in to Riggle Bassbait on Booty Bay's central dock. The first 250 turn-ins per ruleset win.\n• Winners receive an Arcanite Fishing Pole and an Extravagant Extravaganza Coin. Exchange the coin with Jang in Booty Bay for Hook of the Master Angler, Surfer Shoes, Master Angler's Fishing Hat, Empty Fish Bucket or Bitter Baitling.",
            },
            {
                heading = "Before the tournament",
                body = "Reach at least 150 Fishing; 225 and a lure mean fewer fish get away. Clear bag space and set your Hearthstone to Booty Bay. Keep it ready for the trip back to Riggle. A mount helps you reach the next pool.",
            },
            {
                heading = "Rare fish prizes",
                body = "Tastyfish pools can also yield rare fish. Turn each one in to Fishbot 5000 beside Riggle Bassbait in Booty Bay:\n• Keefer's Angelfish — Lucky Fishing Hat.\n• Brownell's Blue Striped Racer — Nat Pagle's Extreme Anglin' Boots.\n• Dezian Queenfish — High Test Eternium Fishing Line.",
            },
            {
                heading = "After a winner is announced",
                body = "The pools stay up until the event ends, so keep fishing for rare fish. Riggle's apprentice pays for Speckled Tastyfish in groups of five. Turn them in while the tournament NPCs are still in Booty Bay.",
            },
            {
                heading = "Whimsyfin in Redridge",
                body = "Look for Whimsyfin schools east of Lake Everstill. Learn Savory Whimsyfin Delight at Cooking 85; each craft uses one Whimsyfin and one Mild Spices to make two portions. Its recipe can drop from Redridge enemies, including Great Goretusks. The food transforms you into an orc pirate or ninja.",
            },
            {
                heading = "Useful schools",
                body = "• School of Deviate Fish — Barrens oases and Wailing Caverns.\n• Oily Blackmouth — coastal zones at many levels.\n• Firefin Snapper — coasts in mid and high level zones.\n• Stonescale Eel Swarm — Azshara, Feralas, and Tanaris.\n• Floating Wreckage and Debris may hold trunks, trade goods, bags, or uncommon items.",
            },
            {
                heading = "Fish by time and season",
                body = "Raw Nightfin Snapper bites most at night; Raw Sunscale Salmon is a daytime catch. Stonescale Eel is more common around dawn, dusk, and night. Winter Squid and Raw Summer Bass are seasonal, with some overlap in spring and autumn.",
            },
            {
                heading = "Forever camp catches",
                body = "Fishing Rack improves your chance of catching bloated fish and offers Fishing lures. Fishing Hut enables rare camp catches and offers Fishing lures. Use your Catch journal to compare what you find in each zone.",
            },
        },
    },
    { id = "nearby", label = "Nearby", title = "Nearby", subtitle = "Fishing discoveries and recipe sellers in your current zone" },
}

function FF:GetNearbyContext()
    local zone = GetRealZoneText and GetRealZoneText() or (GetZoneText and GetZoneText())
    local mapID
    if C_Map and C_Map.GetBestMapForUnit then
        local ok, value = pcall(C_Map.GetBestMapForUnit, "player")
        if ok then mapID = value end
    end
    return mapID, zone and zone ~= "" and zone or nil, self:GetJournalFaction()
end

function FF:BuildNearbyGuide()
    local mapID, zone, faction = self:GetNearbyContext()
    local guide = { id = "nearby", title = "Nearby", subtitle = self:GetZoneDisplayName(zone) or "Current zone unavailable", blocks = {} }
    local vendors = self:GetNearbyRecipeVendors(mapID, faction)
    guide.blocks[1] = { heading = "Recipe sellers", body = not mapID
        and "Your current map is unavailable. Recipe sellers will appear when the zone map is ready."
        or "No verified recipe sellers are listed for this zone.", linked = true }
    for _, vendor in ipairs(vendors) do
        local heading = self:GuideTargetLink({ kind = "map", label = vendor.label,
            mapID = vendor.mapID, x = vendor.x, y = vendor.y }, vendor.name)
            .. string.format("  •  %.1f, %.1f", vendor.x * 100, vendor.y * 100)
        local lines = {}
        for _, meal in ipairs(vendor.meals) do
            lines[#lines + 1] = "• " .. self:GuideTargetLink({ kind = "meal", id = meal.id, label = meal.name }, meal.name)
                .. " recipe  •  Cooking " .. meal.skill
        end
        guide.blocks[#guide.blocks + 1] = { heading = heading, body = table.concat(lines, "\n"), linked = true }
    end
    if #vendors > 0 then guide.blocks[1].body = "Select a seller to show their map location, or a meal to open its recipe in Master Chef." end
    local catches = {}
    for id, entry in pairs(self.db.journal or {}) do
        local count = 0
        if zone then
            for location, record in pairs(entry.locations or {}) do
                if self:FishingLocationMatchesZone(location, zone) then
                    count = count + (record.count or 0)
                end
            end
        end
        local itemID = tonumber(id)
        if itemID and count > 0 then
            local name = entry.name or (GetItemInfo and GetItemInfo(itemID)) or ("Item " .. itemID)
            catches[#catches + 1] = { id = itemID, name = name, count = count }
        end
    end
    table.sort(catches, function(a, b) return a.name < b.name or (a.name == b.name and a.id < b.id) end)
    local lines = {}
    for _, item in ipairs(catches) do
        lines[#lines + 1] = "• " .. self:GuideTargetLink({ kind = "fish", id = item.id, label = item.name }, item.name)
            .. "  ×" .. item.count
    end
    guide.blocks[#guide.blocks + 1] = { heading = "Your recorded catches", linked = true,
        body = #lines > 0 and table.concat(lines, "\n") .. "\n\nRecorded across your characters in this zone; select a catch to open its Journal entry."
            or (zone and "No catches have been recorded here yet. Fish in this zone to build your own record."
                or "Your current zone is unavailable. Recorded catches will appear when the zone is ready.") }
    return guide, mapID, zone, faction
end

-- Structured Gear & Skill references reuse Chef/quest/source records at demand
-- time, after all modules load. No inventory, recipe discovery or saved writes.
function FF:GetJournalGearReferences(block, faction)
    local entries = {}
    for _, spec in ipairs(block.items or {}) do
        if not spec.faction or spec.faction == faction then
            local entry = {}; for key,value in pairs(spec) do entry[key]=value end
            local details = {}
            local function Add(text) if text and text ~= "" then details[#details+1]=text end end
            if entry.meal then
                for _,meal in ipairs(self.masterChefMeals or {}) do if meal.id==entry.id then
                    entry.name=meal.name
                    entry.benefit=entry.benefit or "+"..entry.bonus.." Fishing · 15 min"
                    entry.requirements=entry.requirements or "Level "..entry.level.." to eat · Cooking "..meal.skill.." to prepare."
                    if not entry.acquisition then
                        Add("Ingredients: "..meal.ingredients..".")
                        Add("Recipe: "..(type(meal.recipe)=="table" and meal.recipe[faction] or meal.recipe)..".")
                        Add(meal.extra)
                    end
                    break
                end end
            elseif entry.camp then
                for _,camp in ipairs(self.masterChefCamps or {}) do if camp.id==entry.id then
                    entry.name=camp.name
                    entry.benefit=camp.basic and "Campfire · cooking and camp contributions"
                        or entry.id==279967 and "Camp buff · seated stats"
                        or entry.id==279965 and "Uncommon camp catches and Fishing lures · 1 hour"
                        or "Rare camp catches and Fishing lures · 1 hour"
                    entry.requirements=(camp.profession or "Fishing").." "..camp.skill.."."
                    if entry.id==279967 then
                        self:PrepareGuideLinks()
                        for _,target in ipairs(self.guideLinkTargets) do
                            if target.kind=="info" and target.label=="Camping 101: Fishing" then Add(target.tooltip); break end
                        end
                    else Add(camp.source) end
                    local ingredients={}
                    for _,reagent in ipairs(camp.ingredients or {}) do
                        ingredients[#ingredients+1]=reagent.quantity.." "..reagent.name
                    end
                    Add("Materials: "..table.concat(ingredients,", ")..".")
                    if camp.toolName then Add("Tool: "..camp.toolName.." (not consumed).") end
                    Add(camp.benefit)
                    if not camp.basic then Add("Build a Campfire before placing this contribution.") end
                    break
                end end
            end
            if entry.quest and not entry.acquisition then
                local quest=self:GetJournalQuestReference(entry.quest)
                Add("Take "..entry.quest.." from "..entry.start..".")
                Add(quest and quest.summary)
            end
            if entry.tournament or entry.coin then
                Add("During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.")
                if entry.coin then Add("Exchange the coin with Jang in Booty Bay for "..entry.name..".") end
            end
            if entry.catch then
                Add("During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for "..entry.catch..". Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.")
            end
            Add(entry.acquisition)
            entry.details=table.concat(details,"\n")
            entry.key=tostring(entry.id or entry.key)
            entries[#entries+1]=entry
        end
    end
    return entries
end

function FF:GetJournalGearSources(entry, faction)
    if not entry then return {} end
    local points=entry.suppliers and self:GetFishingItemSuppliers(entry.id,faction)
        or entry.meal and self:GetMealRecipeMapPoints(entry.id,faction) or {}
    return self:GetOrderedGuideMapPoints(points or {},true)
end

function FF:GetJournalGearReferenceText(block, faction)
    local text={block.body or ""}
    for _,entry in ipairs(self:GetJournalGearReferences(block,faction)) do
        text[#text+1]=table.concat({entry.name or "",entry.benefit or "",entry.requirements or "",entry.details},"\n")
    end
    return table.concat(text,"\n")
end

-- Display projections only: canonical route bodies still own English sentence
-- splitting, training ranks, source selection and navigation identities.
local fishingReferenceText = {
    ["route"] = {
        ["1–75  •  Starting waters"] = {
            ["heading"] = { "skill.fishing.route.1.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 1, 75 },
                    ["profession"] = "Fishing",
                    ["required"] = 1,
                    ["goodAt"] = 75,
                    ["fixedUpperBound"] = true,
                    ["fieldGuide"] = true
                } },
            ["summary"] = { "fishing.route.1.summary", {
                    ["textKey"] = "information.rank.apprentice"
                } },
            ["rows"] = {
                ["Alliance"] = { { { "fishing.row.start" }, { "fishing.route.1.row.1", {
                                ["textKey"] = "information.rank.apprentice"
                            } } }, { { "fishing.row.supplies" }, { "fishing.route.1.row.2" } }, { { "fishing.row.waters" }, { "fishing.route.1.row.3", "Raw Brilliant Smallfish", "Raw Slitherskin Mackerel" } }, { { "fishing.row.bait" }, { "fishing.route.1.row.4", "Shiny Bauble" } } },
                ["Horde"] = { { { "fishing.row.start" }, { "fishing.route.1.row.1", {
                                ["textKey"] = "information.rank.apprentice"
                            } } }, { { "fishing.row.supplies" }, { "fishing.route.1.row.2" } }, { { "fishing.row.waters" }, { "fishing.route.1.row.3", "Raw Brilliant Smallfish", "Raw Slitherskin Mackerel" } }, { { "fishing.row.bait" }, { "fishing.route.1.row.4", "Shiny Bauble" } } }
            }
        },
        ["Journeyman Fishing  •  Skill 50, Level 10 required"] = {
            ["heading"] = { "skill.fishing.route.2.heading", {
                    ["textKey"] = "information.rank.journeyman"
                }, {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 50 },
                    ["profession"] = "Fishing",
                    ["required"] = 50,
                    ["fieldGuide"] = true
                } },
            ["support"] = { "fishing.route.2.support" }
        },
        ["75–150  •  City waters"] = {
            ["heading"] = { "skill.fishing.route.3.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 75, 150 },
                    ["profession"] = "Fishing",
                    ["required"] = 75,
                    ["goodAt"] = 150,
                    ["fixedUpperBound"] = true,
                    ["fieldGuide"] = true
                } },
            ["summary"] = { "fishing.route.3.summary", {
                    ["textKey"] = "information.rank.expert"
                } },
            ["rows"] = {
                ["Alliance"] = { { { "fishing.row.start" }, { "skill.fishing.route.3.row.1", {
                                ["textKey"] = "information.rank.journeyman"
                            }, {
                                ["textKey"] = "skill.display.value",
                                ["values"] = { 50 },
                                ["profession"] = "Fishing",
                                ["required"] = 50,
                                ["fieldGuide"] = true
                            } } }, { { "fishing.row.waters" }, { "fishing.route.3.row.2.Alliance", "Stormwind", "Darnassus", "Ironforge" } } },
                ["Horde"] = { { { "fishing.row.start" }, { "skill.fishing.route.3.row.1", {
                                ["textKey"] = "information.rank.journeyman"
                            }, {
                                ["textKey"] = "skill.display.value",
                                ["values"] = { 50 },
                                ["profession"] = "Fishing",
                                ["required"] = 50,
                                ["fieldGuide"] = true
                            } } }, { { "fishing.row.waters" }, { "fishing.route.3.row.2.Horde", "Orgrimmar", "Thunder Bluff" } } }
            }
        },
        ["Expert Fishing  •  Skill 125, Level 20 required"] = {
            ["heading"] = { "skill.fishing.route.4.heading", {
                    ["textKey"] = "information.rank.expert"
                }, {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 125 },
                    ["profession"] = "Fishing",
                    ["required"] = 125,
                    ["fieldGuide"] = true
                } },
            ["support"] = { "fishing.route.4.support", "Expert Fishing – The Bass and You" }
        },
        ["150–225  •  Intermediate waters"] = {
            ["heading"] = { "skill.fishing.route.5.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 150, 225 },
                    ["profession"] = "Fishing",
                    ["required"] = 150,
                    ["goodAt"] = 225,
                    ["fixedUpperBound"] = true,
                    ["fieldGuide"] = true
                } },
            ["summary"] = { "fishing.route.5.summary", {
                    ["textKey"] = "information.rank.artisan"
                } },
            ["rows"] = {
                ["Alliance"] = { { { "fishing.row.start" }, { "skill.fishing.route.5.row.1", "Expert Fishing – The Bass and You", {
                                ["textKey"] = "skill.display.value",
                                ["values"] = { 125 },
                                ["profession"] = "Fishing",
                                ["required"] = 125,
                                ["fieldGuide"] = true
                            } } }, { { "fishing.row.waters" }, { "fishing.route.5.row.2", "Dustwallow Marsh", "Stranglethorn Vale", "Ashenvale", "Wetlands", "Stonetalon" } } },
                ["Horde"] = { { { "fishing.row.start" }, { "skill.fishing.route.5.row.1", "Expert Fishing – The Bass and You", {
                                ["textKey"] = "skill.display.value",
                                ["values"] = { 125 },
                                ["profession"] = "Fishing",
                                ["required"] = 125,
                                ["fieldGuide"] = true
                            } } }, { { "fishing.row.waters" }, { "fishing.route.5.row.2", "Dustwallow Marsh", "Stranglethorn Vale", "Ashenvale", "Wetlands", "Stonetalon" } } }
            }
        },
        ["Artisan Fishing  •  Skill 225, Level 35 required"] = {
            ["heading"] = { "skill.fishing.route.6.heading", {
                    ["textKey"] = "information.rank.artisan"
                }, {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 225 },
                    ["profession"] = "Fishing",
                    ["required"] = 225,
                    ["fieldGuide"] = true
                } },
            ["support"] = { "fishing.route.6.support", "Nat Pagle, Angler Extreme", "Feralas Ahi", "Verdantis River", "(62, 51)", "Misty Reed Mahi Mahi", "Swamp of Sorrows", "(90, 72)", "Sar'theris Striker", "Desolace", "(25, 77)", "Savage Coast Blue Sailfin", "Stranglethorn", "(33, 32)" }
        },
        ["225–300  •  Final stretch"] = {
            ["heading"] = { "skill.fishing.route.7.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 225, 300 },
                    ["profession"] = "Fishing",
                    ["required"] = 225,
                    ["goodAt"] = 300,
                    ["fixedUpperBound"] = true,
                    ["fieldGuide"] = true
                } },
            ["summary"] = { "fishing.route.7.summary", "Fishing Hut" },
            ["rows"] = {
                ["Alliance"] = { { { "fishing.row.start" }, { "skill.fishing.route.7.row.1", "Nat Pagle, Angler Extreme", {
                                ["textKey"] = "skill.display.value",
                                ["values"] = { 225 },
                                ["profession"] = "Fishing",
                                ["required"] = 225,
                                ["fieldGuide"] = true
                            } } }, { { "fishing.row.waters" }, { "fishing.route.7.row.2", "Feralas", "The Hinterlands", "Tanaris", "Un'Goro", "Felwood", "Western Plaguelands" } }, { { "fishing.row.bait" }, { "fishing.route.7.row.3" } } },
                ["Horde"] = { { { "fishing.row.start" }, { "skill.fishing.route.7.row.1", "Nat Pagle, Angler Extreme", {
                                ["textKey"] = "skill.display.value",
                                ["values"] = { 225 },
                                ["profession"] = "Fishing",
                                ["required"] = 225,
                                ["fieldGuide"] = true
                            } } }, { { "fishing.row.waters" }, { "fishing.route.7.row.2", "Feralas", "The Hinterlands", "Tanaris", "Un'Goro", "Felwood", "Western Plaguelands" } }, { { "fishing.row.bait" }, { "fishing.route.7.row.3" } } }
            }
        }
    },
    ["milestone"] = {
        ["1"] = {
            ["heading"] = { "skill.fishing.milestone.1.heading", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 20 },
                    ["profession"] = "Fishing",
                    ["required"] = 20,
                    ["fieldGuide"] = true
                }, "Fish Bowl" },
            ["body"] = { "fishing.milestone.1.body", "Camping 101: Fishing", "Fish Bowl", "Raw Brilliant Smallfish", "Empty Vial", "Build a Campfire", "Blessing of Kings" }
        },
        ["4"] = {
            ["heading"] = { "skill.fishing.milestone.4.heading", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 140 },
                    ["profession"] = "Fishing",
                    ["required"] = 140,
                    ["fieldGuide"] = true
                }, "Fishing Rack" },
            ["body"] = { "fishing.milestone.4.body", "Blueprint: Fishing Rack", "Gelihast", "Blackfathom Deeps", "Simple Wood", "Crystal Vial", "Raw Mithril Head Trout", "Fish Bowl" }
        },
        ["7"] = {
            ["heading"] = { "skill.fishing.milestone.7.heading", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 300 },
                    ["profession"] = "Fishing",
                    ["required"] = 300,
                    ["fieldGuide"] = true
                }, "Fishing Hut" },
            ["body"] = { "skill.fishing.milestone.7.guide", "Blueprint: Fishing Hut", "Jammal'an the Prophet", "Sunken Temple",
                "Simple Wood", "Bolt of Runecloth", "Seasonal Fish Steaks", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 275 },
                    ["profession"] = "Fishing",
                    ["required"] = 275,
                    ["fieldGuide"] = true
                }, "Chef's Knife", "Raw Summer Bass", "Raw Winter Squid", "Fish Bowl" }
        }
    }
}

local function FishingDisplay(self, spec, skills)
    if spec then return self:FormatLocalizedReference(spec, skills) end
end

function FF:GetFishingReferenceText(kind, entry, field, faction, skills)
    local catalogue = fishingReferenceText[kind]
    local record = catalogue and catalogue[kind == "route" and entry.heading or tostring(entry.after)]
    if record and record[field] then return FishingDisplay(self, record[field], skills) end
    local value = entry[field]
    if type(value) == "table" then return value[faction] end
    return value
end

local CanonicalFishingRouteRows = FF.GetFishingRouteRows
function FF:GetFishingRouteRows(block, faction, combinePole, skills)
    local rows, rank = CanonicalFishingRouteRows(self, block, faction, combinePole)
    local record = fishingReferenceText.route[block.heading]
    local specs = record and record.rows and record.rows[faction]
    if rows and specs then
        for index, row in ipairs(rows) do
            row[1] = FishingDisplay(self, specs[index][1], skills)
            row[2] = FishingDisplay(self, specs[index][2], skills)
        end
    end
    return rows, rank
end

local CanonicalFishingTrainingCallout = FF.GetFishingTrainingCallout
function FF:GetFishingTrainingCallout(block, skills)
    local heading, support = CanonicalFishingTrainingCallout(self, block)
    if not heading then return heading, support end
    for _, rank in pairs(self.fishingRankInfo) do
        if rank.name == block.trainingRank and rank.minSkill then
            heading = self:FormatLocalizedReference({"skill.fishing.training-heading",
                {textKey="information.rank."..string.lower(rank.name)},
                {textKey="skill.display.value",values={rank.minSkill},profession="Fishing",required=rank.minSkill},
                rank.minLevel}, skills)
            break
        end
    end
    local record = fishingReferenceText.route[block.heading]
    return heading, record and FishingDisplay(self, record.support, skills) or support
end

function FF:GetFishingRouteSearchText(block, faction)
    local record = fishingReferenceText.route[block.heading]
    local text = {}
    if record then
        for _, field in ipairs({"heading", "summary", "support"}) do
            local display = FishingDisplay(self, record[field])
            if display then text[#text+1] = display end
        end
        for _, row in ipairs(record.rows and record.rows[faction] or {}) do
            text[#text+1] = FishingDisplay(self, row[1])
            text[#text+1] = FishingDisplay(self, row[2])
        end
    end
    return text
end

function FF:GetFishingRouteRequirementText(rank)
    if rank == "Apprentice" or rank == "Journeyman" then
        local id = string.lower(rank)
        return self:LocalizedText("fishing.source."..id, self:LocalizedText("information.rank."..id))
    elseif rank == "Expert" then
        return self:LocalizedText("fishing.source.expert", "Expert Fishing – The Bass and You")
    elseif rank == "Artisan" then
        return self:LocalizedText("fishing.source.artisan", "Nat Pagle, Angler Extreme")
    elseif rank == "Supplier" then
        return self:LocalizedText("fishing.source.supplier", "Fishing Pole")
    end
end
