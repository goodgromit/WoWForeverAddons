-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Explicit direct-fishing goals from CatchCollection, independent of displayed
-- rows, sorting, bags, or item quality. Sets may overlap (a rare fish can equip).
FF.achievementCatchSets = {
    standard = {6291,6303,6289,6317,6522,6358,6361,6308,6359,6362,21071,21153,
        8365,4603,13422,13754,13755,13756,13758,13759,13760,13889,13888,13893,
        12238,19975,19807,13757,13890,6458,6299,251524},
    rare = {19803,19805,19806,19808,6643,6645,6647,8366,13881,13891,21163,
        21164,6360,8350,6301,6307},
    gear = {19808,6360,8350},
    nonfish = {8350,6301,6307,3820,5523,5524,7973,20709,21114,21151,6351,
        6352,6353,6357,13874,20708,21113,21150,21228},
}
local full, seen = {}, {}
for _, name in ipairs({"standard", "rare", "gear", "nonfish"}) do
    for _, id in ipairs(FF.achievementCatchSets[name]) do
        if not seen[id] then seen[id] = true; full[#full + 1] = id end
    end
end
FF.achievementCatchSets.full = full

local achievementFlavour = {
    ["first-bite"] = "A quiet ripple can be the start of a grand adventure.",
    ["eyes-on-the-water"] = "Patience and a watchful eye are an angler's finest tackle.",
    ["hook-to-hearth"] = "Every great fishing tale deserves a freshly cooked meal.",
    ["something-fishy"] = "There is always another surprise beneath the surface.",
    ["one-of-a-kind"] = "Some ripples are worth remembering.",
    ["treasure-from-the-deep"] = "The waters have a curious idea of buried treasure.",
    ["hooked"] = "Just one more cast is a perfectly reasonable plan.",
    ["new-waters"] = "Pack a pole and let the next shoreline choose the view.",
    ["plenty-of-fish"] = "A well-worn journal makes room for colourful company.",
    ["camp-cook"] = "The campfire always draws a hungry crowd.",
    ["tackle-box"] = "A little preparation can make a quiet afternoon interesting.",
    ["rare-company"] = "Unusual company makes for excellent dockside stories.",
    ["seasoned-angler"] = "Patience wears as comfortably as a favourite fishing hat.",
    ["master-of-the-line"] = "Even the longest cast begins with a steady hand.",
    ["well-travelled"] = "The road is easier to follow when it runs beside the water.",
    ["fully-equipped"] = "The finest tackle sometimes comes from the other end of the line.",
    ["master-angler"] = "Every page is an invitation to try another stretch of water.",
    ["master-chef"] = "A good recipe is a treasure worth keeping beside the tackle box.",
    ["forever-fishing"] = "There is no hurry when the water still has stories to tell.",
    ["the-deep-end"] = "Beyond the familiar shallows, stranger tales are waiting.",
    ["master-of-the-waters"] = "The best fishing spots reward those who linger.",
    ["hook-em-all"] = "A journal full of possibilities begins with an empty page.",
}

local function Achievement(id, title, description, metric, target, difficulty, detail)
    return {id=id, title=title, description=description, metric=metric, target=target,
        difficulty=difficulty,
        detail=detail, flavour=achievementFlavour[id]}
end
FF.achievementDefinitions = {
    Achievement("first-bite", "First Bite", "Catch your first fish.", "catches", 1, 1),
    Achievement("eyes-on-the-water", "Eyes on the Water", "Land 10 successful catches within five minutes.", "quickCatches", 10, 1,
        "Progress shows your best five-minute window. Each successful fishing cast counts once, regardless of item quantity. Failed or cancelled casts do not reset the window."),
    Achievement("hook-to-hearth", "From Hook to Hearth", "Cook your first fishing meal with Master Chef.", "cooks", 1, 1),
    Achievement("something-fishy", "Something Fishy", "Discover 10 different fish.", "standard", 10, 1),
    Achievement("one-of-a-kind", "One of a Kind", "Reel in your first rare catch.", "rare", 1, 1),
    Achievement("treasure-from-the-deep", "Treasure from the Deep", "Fish up something that isn’t a fish.", "nonfish", 1, 1),
    Achievement("hooked", "Hooked", "Record 100 catches.", "catches", 100, 2),
    Achievement("new-waters", "New Waters", "Catch fish in 5 different zones.", "zones", 5, 2),
    Achievement("plenty-of-fish", "Plenty of Fish", "Discover 25 different fish.", "standard", 25, 2),
    Achievement("camp-cook", "Camp Cook", "Cook 50 fishing meals with Master Chef.", "cooks", 50, 2),
    Achievement("tackle-box", "Tackle Box", "Put 5 different fishing lures to use.", "lures", 5, 2),
    Achievement("rare-company", "Rare Company", "Discover 5 different rare catches.", "rare", 5, 2),
    Achievement("seasoned-angler", "Seasoned Angler", "Record 500 catches.", "catches", 500, 3),
    Achievement("master-of-the-line", "Master of the Line", "Reach 300 Fishing skill.", "skill", 300, 3, "Base Fishing skill; equipment and lure bonuses do not count."),
    Achievement("well-travelled", "Well Travelled", "Catch fish in 15 different zones.", "zones", 15, 3),
    Achievement("fully-equipped", "Fully Equipped", "Fish up every piece of equippable fishing gear in the collection.", "gear", "gear", 3, "Catch Rockhide Strongfish, Steelscale Crushfish and The 1 Ring yourself; buying or trading for them does not count."),
    Achievement("master-angler", "Master Angler", "Catch every standard fish in the Catch Collection.", "standard", "standard", 4),
    Achievement("master-chef", "Master Chef", "Learn every fishing recipe in the Master Chef collection.", "recipes", "recipes", 4),
    Achievement("forever-fishing", "Forever Fishing", "Record 1,000 catches.", "catches", 1000, 4),
    Achievement("the-deep-end", "The Deep End", "Discover every rare and special catch.", "rare", "rare", 4),
    Achievement("master-of-the-waters", "Master of the Waters", "Catch every standard fish at least 10 times.", "mastery", "standard", 4, "Reach Catch Mastery Tier I for each standard fish (10 catches). Later tiers begin at 50, 100, 250, 500 and 1,000 catches."),
    Achievement("hook-em-all", "Hook ’Em All", "Complete the entire Catch Collection.", "full", "full", 4, "Includes standard fish, rare and special catches, equippable catches and other finds. Items inside opened containers do not count."),
}
FF.achievementsByID = {}
for index, definition in ipairs(FF.achievementDefinitions) do
    definition.order = index
    FF.achievementsByID[definition.id] = definition
end

-- Reusable title/row styling only: no individual achievement icon assets.
FF.achievementStyles = {
    {color={0.57,0.35,0.18}, title={0.34,0.19,0.09}, weight=1},
    {color={0.56,0.59,0.62}, title={0.25,0.28,0.31}, weight=1},
    {color={0.78,0.57,0.19}, title={0.43,0.27,0.07}, weight=2},
    {color={0.87,0.64,0.24}, title={0.42,0.24,0.07}, weight=2, prestige=true},
}
