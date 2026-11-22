-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Canonical operation messages remain English for the existing state readers.
-- Display records are bounded per field, transient, and valid only while their
-- canonical value still owns that field (including old/direct clear paths).
function FF:SetMasterChefMessage(field, key, ...)
    self.masterChefMessageRecords = self.masterChefMessageRecords or {}
    if not key then self[field] = nil; self.masterChefMessageRecords[field] = nil; return end
    local args = { ... }
    local canonical = string.format(self.englishStrings[key],unpack(args))
    self[field] = canonical
    self.masterChefMessageRecords[field] = { canonical = canonical, key = key, args = args }
    return canonical
end

function FF:GetMasterChefMessage(field)
    local record = self.masterChefMessageRecords and self.masterChefMessageRecords[field]
    if record and record.canonical == self[field] then return self:LocalizedText(record.key,unpack(record.args)) end
    return self[field]
end

function FF:CopyMasterChefMessage(target, source, fallbackKey)
    local record = self.masterChefMessageRecords and self.masterChefMessageRecords[source]
    if record and record.canonical == self[source] then
        return self:SetMasterChefMessage(target,record.key,unpack(record.args))
    end
    if not self[source] and fallbackKey then return self:SetMasterChefMessage(target,fallbackKey) end
    self:SetMasterChefMessage(target,nil)
    self[target] = self[source]
    return self[target]
end

function FF:SetLocalizedMasterChefQuickStatus(key, ...)
    if not (self.masterChefTray and self.masterChefTray:IsShown()) then return end
    local message = self:SetMasterChefMessage("masterChefQuickStatus",key,...)
    self:SetMasterChefQuickStatus(message)
end

local CRAFT_REQUEST_FIELDS = { "masterChefCookingRequest", "masterChefCampCraftRequest" }

local function ClearCraftRequest(chef, field, failed)
    local request = chef[field]
    if request then request.failed = failed; chef[field] = nil end
end

local function RequestRecipe(chef, field, recipeID, quantity)
    -- Callers arm active state first: native failure/success events can arrive
    -- inside CraftRecipe. A void API return is not confirmation of a cast.
    local request = { recipeID = recipeID, inCall = true, started = false }
    chef[field] = request
    local ok, result = pcall(C_TradeSkillUI.CraftRecipe, recipeID, quantity)
    request.inCall = false
    if not ok or result == false then
        if chef[field] == request then
            if field == "masterChefCookingRequest" then
                chef:OnMasterChefCraftFailed(recipeID)
            else
                chef:OnMasterChefCampCraftEvent("UNIT_SPELLCAST_FAILED", recipeID)
            end
        end
        return false
    end
    return not request.failed
end

function FF:OnMasterChefCraftSent(recipeID, castGUID)
    if type(recipeID) ~= "number" or (issecretvalue and issecretvalue(recipeID)) then return end
    if type(castGUID) ~= "string" or (issecretvalue and issecretvalue(castGUID)) then return end
    for _, field in ipairs(CRAFT_REQUEST_FIELDS) do
        local request = self[field]
        if request and request.recipeID == recipeID then request.castGUID = castGUID end
    end
end

function FF:OnMasterChefCraftStarted(recipeID, castGUID)
    if type(recipeID) ~= "number" or (issecretvalue and issecretvalue(recipeID)) then return end
    self:OnMasterChefCraftSent(recipeID, castGUID)
    for _, field in ipairs(CRAFT_REQUEST_FIELDS) do
        local request = self[field]
        if request and request.recipeID == recipeID then request.started = true end
    end
end

local function OtherCraftFailure(request, castGUID)
    return request and request.castGUID and type(castGUID) == "string"
        and not (issecretvalue and issecretvalue(castGUID)) and request.castGUID ~= castGUID
end

local CRAFT_ERROR_IDENTITIES={
    moving={"SPELL_FAILED_MOVING","ERR_NOT_WHILE_MOVING"},
    ready={"SPELL_FAILED_NOT_READY","SPELL_FAILED_ITEM_NOT_READY","ERR_ITEM_COOLDOWN","ERR_SPELL_COOLDOWN"},
    focus={"SPELL_FAILED_REQUIRES_SPELL_FOCUS"},
}
function FF:GetMasterChefCraftErrorKind(message, errorID)
    if issecretvalue and issecretvalue(message) then return end
    if type(message)~="string" then return end
    local identity=self:GetNativeErrorName(errorID)
    if identity then
        for _,kind in ipairs({"moving","ready","focus"}) do
            for _,name in ipairs(CRAFT_ERROR_IDENTITIES[kind]) do
                if identity==name then
                    if kind=="focus" then
                        local lower=(message:gsub("[A-Z]",string.lower))
                        return lower:find("cooking fire",1,true) and "fire" or "ready"
                    end
                    return kind
                end
            end
        end
    end
    if self:MatchesNativeError(message,CRAFT_ERROR_IDENTITIES.moving) then return "moving" end
    if self:MatchesNativeError(message,CRAFT_ERROR_IDENTITIES.ready)
        or self:MatchesNativeError(message,CRAFT_ERROR_IDENTITIES.focus) then return "ready" end
    -- Retain the existing English compatibility path, never draft translations.
    local lower=(message:gsub("[A-Z]",string.lower))
    if lower:find("while moving",1,true) then return "moving" end
    if lower:find("cooking fire",1,true) then return "fire" end
    if lower:find("not ready yet",1,true) then return "ready" end
end

function FF:OnMasterChefCraftUIError(message, errorID)
    -- Place has its own targeting/retry lifecycle and retains first ownership.
    if self.masterChefCampPlacement or self.masterChefCampPlaceAttempt then return false end
    local kind=self:GetMasterChefCraftErrorKind(message,errorID)
    local moving=kind=="moving"
    local statusKey=moving and "chef.ui.stop-moving" or kind=="fire" and "chef.ui.need-fire" or "journal.chrome.not-ready"
    local label=moving and "Stop moving" or kind=="fire" and "Need cooking fire" or kind=="ready" and "Not ready"
    if not label then return false end
    for _, field in ipairs(CRAFT_REQUEST_FIELDS) do
        local request = self[field]
        local cooking = field == "masterChefCookingRequest"
        local active = self[cooking and "masterChefCookingActive" or "masterChefCampCrafting"]
        if request and active and not request.started then
            -- A global UI error has no recipe ID. Do not unlock a running cast
            -- merely because another action reports an error.
            local casting = not request.inCall and ((UnitCastingInfo and UnitCastingInfo("player"))
                or (UnitChannelInfo and UnitChannelInfo("player")))
            if not casting then
                local quick = cooking and self.masterChefCookingQuickActive ~= nil
                if cooking then
                    self:OnMasterChefCraftFailed(request.recipeID)
                    if kind~="ready" then
                        if quick then self:SetMasterChefMessage("masterChefQuickMessage",moving and "chef.message.moving-click" or "chef.message.fire-click")
                        else self:SetMasterChefMessage("masterChefQueueMessage",moving and "chef.message.moving-start" or "chef.message.fire-start") end
                    end
                else
                    local queued = self.masterChefCampCraftQueued
                    self:OnMasterChefCampCraftEvent("UNIT_SPELLCAST_FAILED", request.recipeID)
                    if kind~="ready" then
                        self:SetMasterChefMessage("masterChefCampMessage",moving and "chef.message.moving-camp" or "chef.message.fire-camp")
                        if queued then self:CopyMasterChefMessage("masterChefCampQueueMessage","masterChefCampMessage") end
                    end
                end
                if self.ShowMasterChefStatus then
                    self:ShowMasterChefStatus(cooking and "meals" or "campfire", label, true, 3, statusKey)
                end
                if self.SetMasterChefQuickStatus then self:SetLocalizedMasterChefQuickStatus(statusKey) end
                if self.RefreshJournal then self:RefreshJournal() end
                return true
            end
        end
    end
    return false
end

-- A small, static reference. Item IDs are cooked food, so the journal can use
-- the same in-game item icons and tooltips as the catch list. Recipe sources
-- marked unconfirmed have no verified acquisition route in Forever.
-- Sources: Wowhead Forever cooking spells/items, Classic vendor records, and
-- the Forever beta profession tables (September 2026).
-- https://www.wowhead.com/forever/items/recipes/cooking
-- https://classicwowforever.com/professions/cooking/
-- https://classicwowforever.com/professions/fishing/
local function Meal(id, name, skill, ingredients, recipe, waters, extra)
    return { id = id, name = name, skill = skill, ingredients = ingredients,
        recipe = recipe, waters = waters, extra = extra }
end

FF.masterChefMeals = {
    Meal(6290, "Brilliant Smallfish", 1, "Raw Brilliant Smallfish", "Fishing or cooking suppliers in starting areas", "Starting zone rivers and lakes"),
    Meal(787, "Slitherskin Mackerel", 1, "Raw Slitherskin Mackerel", {
        Alliance = "Coastal fishing suppliers; Nessa Shadowsong in Rut'theran Village",
        Horde = "Coastal fishing suppliers; Zansoa near Sen'jin Village",
    }, "Starting zone coasts"),
    Meal(4592, "Longjaw Mud Snapper", 50, "Raw Longjaw Mud Snapper", {
        Alliance = "Fishing suppliers; Khara Deepwater in Loch Modan",
        Horde = "Fishing suppliers in Thunder Bluff",
    }, {
        Alliance = "Stormwind canals or Loch Modan lakes",
        Horde = "Orgrimmar or Thunder Bluff waters",
    }),
    Meal(5476, "Fillet of Frenzy", 50, "Soft Frenzy Flesh, Mild Spices", {
        Alliance = "Laird in Auberdine, Darkshore",
        Horde = "Check the neutral Auction House",
    }, "Soft Frenzy Flesh drops from Frenzy in coastal water", "Its fish ingredient comes from Frenzy creatures, rather than a fishing cast."),
    Meal(6316, "Loch Frenzy Delight", 50, "Raw Loch Frenzy, Mild Spices", {
        Alliance = "Khara Deepwater in Loch Modan",
        Horde = "Check the neutral Auction House",
    }, "Loch Modan lakes"),
    Meal(5095, "Rainbow Fin Albacore", 50, "Raw Rainbow Fin Albacore", "Coastal fishing suppliers", "Westfall or Darkshore coast"),
    Meal(21072, "Smoked Sagefish", 80, "Raw Sagefish, Mild Spices", "Fishing suppliers; Kelsey Yance in Booty Bay also stocks it", "Sagefish schools in Ashenvale or Wetlands"),
    Meal(5526, "Clam Chowder", 90, "Clam Meat, Ice Cold Milk, Mild Spices", {
        Alliance = "Heldan Galesong in Darkshore or Kriggon Talsone in Westfall",
        Horde = "No Horde recipe source is confirmed in this guide",
    }, "Open clams caught in low level coastal water"),
    Meal(4593, "Bristle Whisker Catfish", 100, "Raw Bristle Whisker Catfish", {
        Alliance = "Fishing suppliers in Stormwind and other cities",
        Horde = "Fishing suppliers in Thunder Bluff and other cities",
    }, {
        Alliance = "Redridge or Wetlands rivers and lakes",
        Horde = "The Barrens or Hillsbrad inland water",
    }),
    Meal(5527, "Goblin Deviled Clams", 125, "Tangy Clam Meat, Hot Spices", "Cooking trainer", "Open clams from coastal fishing or sea creatures"),
    Meal(4594, "Rockscale Cod", 175, "Raw Rockscale Cod", "Kelsey Yance in Booty Bay; also sold by regional fishing suppliers", "Stranglethorn or Dustwallow coast"),
    Meal(8364, "Mithril Headed Trout", 175, "Raw Mithril Head Trout", "Kelsey Yance in Booty Bay; also sold by regional fishing suppliers", "Dustwallow Marsh or Stranglethorn inland water"),
    Meal(21217, "Sagefish Delight", 175, "Raw Greater Sagefish, Hot Spices", {
        Alliance = "Kelsey Yance in Booty Bay or Erika Tate in Stormwind",
        Horde = "Kelsey Yance in Booty Bay or Derek Nightfall in Tarren Mill",
    }, "Greater Sagefish schools in Alterac or Stranglethorn"),
    Meal(6038, "Giant Clam Scorcho", 175, "Giant Clam Meat, Hot Spices", "Fishing supplier in Booty Bay, Stranglethorn Vale", "Open Giant Clams from higher level coastal catches"),
    Meal(274971, "Briny Seafood Stew", 200, "2 Murloc Eye, Tender Crab Meat, Hot Spices", "Recipe: Briny Seafood Stew from A Taste of the Sea. Speak to Fimbo Greasemitz in Riverglades.", "Loot Murloc Eyes and Tender Crab Meat. Buy Hot Spices from cooking suppliers.", "Uses a cooking fire."),
    Meal(8957, "Spinefin Halibut", nil, "Raw Spinefin Halibut", "Recipe source not yet confirmed in Forever", "Buy Raw Spinefin Halibut from fish vendors."),
    Meal(286152, "Plated Armorfish", 225, "Raw Plated Armorfish, Soothing Spices", "Recipe: Plated Armorfish (source unconfirmed)", "Eastern Plaguelands or Deadwind Pass inland water", "Check the current native buff for server restrictions."),
    Meal(6887, "Spotted Yellowtail", 225, "Raw Spotted Yellowtail", "Gikkix at Steamwheedle Port, Tanaris", "Tanaris or Feralas coast"),
    Meal(13927, "Cooked Glossy Mightfish", 225, "Raw Glossy Mightfish, Soothing Spices", "Kelsey Yance in Booty Bay", "Tanaris or Feralas coast"),
    Meal(13930, "Filet of Redgill", 225, "Raw Redgill", "Kelsey Yance in Booty Bay", "Felwood or Feralas lakes"),
    Meal(16766, "Undermine Clam Chowder", 225, "2 Zesty Clam Meat, Hot Spices, Ice Cold Milk", "Jabbey at Steamwheedle Port, Tanaris", "Open Big-mouth Clams from higher level coastal catches"),
    Meal(13928, "Grilled Squid", 240, "Raw Winter Squid, Soothing Spices", "Gikkix at Steamwheedle Port, Tanaris", "Tanaris coast in winter", "Needs an Iron Oven."),
    Meal(13929, "Hot Smoked Bass", 240, "Raw Summer Bass, 2 Hot Spices", "Kelsey Yance in Booty Bay", "Tanaris coast in summer", "Needs an Iron Oven."),
    Meal(13931, "Nightfin Soup", 250, "Raw Nightfin Snapper, Refreshing Spring Water", "Gikkix at Steamwheedle Port, Tanaris", "Moonglade or Felwood lakes at night", "Uses a cooking fire."),
    Meal(13932, "Poached Sunscale Salmon", 250, "Raw Sunscale Salmon", "Gikkix at Steamwheedle Port, Tanaris", "Moonglade or Felwood lakes by day", "Needs an Iron Oven."),
    Meal(13933, "Lobster Stew", 275, "Darkclaw Lobster, Refreshing Spring Water", {
        Alliance = "Vivianna at Feathermoon Stronghold",
        Horde = "Sheendra Tallgrass at Camp Mojache",
    }, "High level coastal water", "Needs an Iron Oven."),
    Meal(13935, "Baked Salmon", 275, "Raw Whitescale Salmon, Soothing Spices", {
        Alliance = "Vivianna at Feathermoon Stronghold",
        Horde = "Sheendra Tallgrass at Camp Mojache",
    }, "Feralas or Winterspring inland water", "Needs an Iron Oven."),
    Meal(13934, "Mightfish Steak", 275, "Large Raw Mightfish, Hot Spices, Soothing Spices", {
        Alliance = "Vivianna at Feathermoon Stronghold",
        Horde = "Sheendra Tallgrass at Camp Mojache",
    }, "High level coastal water", "Needs an Iron Oven."),
    Meal(250081, "Clam Linguine", 275, "3 Zesty Clam Meat, 4 Soothing Spices", "Recipe: Clam Linguine (source unconfirmed)", "Open Big-mouth Clams from higher level coastal catches", "Needs an Iron Oven."),
    Meal(238641, "Specklefin Feast", 280, "12 Raw Spotted Yellowtail, 4 Raptor Flesh, 3 Raw Rockscale Cod, Exquisite Spices", "Recipe source not yet confirmed in Forever", "Fish the Tanaris or Stranglethorn coast for yellowtail and cod"),
    Meal(238642, "Grand Lobster Banquet", 280, "12 Darkclaw Lobster, 4 Turtle Meat, 3 Buzzard Wing, Exquisite Spices", "Recipe source not yet confirmed in Forever", "Fish high level coasts for Darkclaw Lobster"),
    Meal(6657, "Savory Deviate Delight", 85, "Deviate Fish, Mild Spices", "Recipe drops from creatures in The Barrens", "The Barrens oasis pools or Wailing Caverns"),
    Meal(251525, "Savory Whimsyfin Delight", 85, "Whimsyfin, Mild Spices", "Recipe drops from Great Goretusk in Redridge Mountains", "Whimsyfin schools in Redridge Mountains"),
}

function FF.CompareMasterChefMealSkills(a, b)
    local aSkill, bSkill = a.skill or math.huge, b.skill or math.huge
    return aSkill < bSkill or (aSkill == bSkill and a.name < b.name)
end
table.sort(FF.masterChefMeals, FF.CompareMasterChefMealSkills)

-- Keep recipe data per login. A different profession or incomplete list must
-- never replace a valid Cooking scan.
local mealByOutput, achievementMeals = {}, {}
-- Additional meals share cooking discovery without extending the existing achievement.
local additionalMealOutputs = { [8957] = true, [274971] = true }
for _, meal in ipairs(FF.masterChefMeals) do
    mealByOutput[meal.id] = meal
    if not additionalMealOutputs[meal.id] then achievementMeals[#achievementMeals + 1] = meal end
end

-- The profession recipe list is empty in the Forever client while Cooking is
-- closed. These curated spell IDs let Grilling inspect its meals directly.
-- Each result is still checked against its cooked output item before use.
local recipeSpellByOutput = {
    [6290] = 7751, [787] = 7752, [4592] = 7753, [5476] = 6415,
    [6316] = 7754, [5095] = 7827, [21072] = 25704, [5526] = 6501,
    [4593] = 7755, [5527] = 6500, [4594] = 7828, [8364] = 20916,
    [21217] = 25904, [6038] = 7213, [286152] = 1319313,
    [6887] = 18238, [13927] = 18239, [13930] = 18241,
    [16766] = 20626, [13928] = 18240, [13929] = 18242,
    [13931] = 18243, [13932] = 18244, [13933] = 18245,
    [13935] = 18247, [13934] = 18246, [250081] = 1250158,
    [238641] = 1225762, [238642] = 1225763,
    [6657] = 8238, [251525] = 1252566, [8957] = 1247741, [274971] = 1295805,
}

-- Verified obtainable collection for each actual character faction. Opposing
-- faction vendor-only and source-unconfirmed meals become eligible if that
-- character actually knows them; Journal's display faction is not evidence.
local achievementRecipeEligibility = {
    [5476] = "Alliance", [6316] = "Alliance", [5526] = "Alliance",
    [286152] = false, [250081] = false,
}
function FF:GetAchievementRecipeProgress()
    local count, target, missing, excluded = 0, 0, {}, 0
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    for _, meal in ipairs(achievementMeals) do
        local spellID = recipeSpellByOutput[meal.id]
        local learned, checked = false, false
        if spellID and IsPlayerSpell then
            local ok, known = pcall(IsPlayerSpell, spellID)
            learned = ok and known == true
            checked = ok and type(known) == "boolean"
        end
        local recipe = self.masterChefRecipes and self.masterChefRecipes[meal.id]
        if not checked and self.masterChefCookingCatalogContext and self.masterChefRecipesChecked and recipe
            and recipe.recipeID == spellID and recipe.learned == true then learned = true end
        local eligibility = achievementRecipeEligibility[meal.id]
        if learned or eligibility == nil or eligibility == faction then
            target = target + 1
            if learned then count = count + 1 else missing[#missing + 1] = meal.name end
        else excluded = excluded + 1 end
    end
    local detail = "Recipes for your faction count. Recipes from the other faction or with an unknown source also count if you have learned them."
    if #missing > 0 then
        local names = {}
        for index = 1, math.min(5, #missing) do names[#names + 1] = missing[index] end
        detail = detail .. "\n\nStill to learn: " .. table.concat(names, ", ")
            .. (#missing > 5 and ("  •  +" .. (#missing - 5) .. " more") or "")
    end
    return count, target, detail, {canonical=detail, missing=missing}
end

local function RecipeIngredients(schematic)
    if type(schematic) ~= "table" or type(schematic.reagentSlotSchematics) ~= "table" then return nil end
    local ingredients = {}
    local byID = {}
    for _, slot in ipairs(schematic.reagentSlotSchematics) do
        if slot.required ~= false then
            local reagent = type(slot.reagents) == "table" and slot.reagents[1]
            local itemID = reagent and reagent.itemID
            local quantity = slot.quantityRequired
            if slot.reagentType ~= 1 or type(slot.reagents) ~= "table" or #slot.reagents ~= 1
                or type(itemID) ~= "number"
                or type(quantity) ~= "number" or quantity < 1 or quantity % 1 ~= 0 then return nil end
            if byID[itemID] then
                byID[itemID].quantity = byID[itemID].quantity + quantity
            else
                local ingredient = { id = itemID, quantity = quantity }
                ingredients[#ingredients + 1] = ingredient
                byID[itemID] = ingredient
            end
        end
    end
    return #ingredients > 0 and ingredients or nil
end

local function RecipeDiscoveryUrgent(self)
    return self.masterChefCookingPending or self.masterChefCookingQuickPending
        or self.masterChefCookingContextPending or self.masterChefCookingActive
        or self.masterChefCampPreparing or self.masterChefCampCrafting
end

-- Only stable personal data can be reused; ownership/readiness is checked live
-- by action methods, not inferred from this presentation catalog.
local function RecipeCatalogContext()
    local api = C_TradeSkillUI
    if not api then return nil end
    local profession
    if api.GetBaseProfessionInfo then
        local ok, info = pcall(api.GetBaseProfessionInfo)
        if not ok then return nil end
        profession = info
    elseif GetTradeSkillLine then
        local ok, name = pcall(GetTradeSkillLine)
        if not ok then return nil end
        profession = { professionName = name }
    else return nil end
    for _, method in ipairs({ "IsTradeSkillLinked", "IsNPCCrafting", "IsDataSourceChanging" }) do
        if type(api[method]) ~= "function" then return nil end
        local ok, blocked = pcall(api[method])
        if not ok or blocked ~= false then return nil end
    end
    if profession ~= nil and type(profession) ~= "table" then return nil end
    if not profession then return "closed|" .. tostring(UnitFactionGroup and UnitFactionGroup("player")) end
    return table.concat({ tostring(profession.professionID), tostring(profession.parentProfessionID),
        tostring(profession.profession), tostring(profession.professionName),
        tostring(profession.parentProfessionName), tostring(UnitFactionGroup and UnitFactionGroup("player")) }, "|")
end

function FF:InvalidateMasterChefRecipeCatalogs()
    self.masterChefCookingCatalogContext = nil
    self.masterChefCampCatalogContext = nil
end

function FF:EnsureMasterChefCooking(immediate)
    local context = RecipeCatalogContext()
    if not immediate and not RecipeDiscoveryUrgent(self) and self.masterChefRecipesChecked
        and context and context == self.masterChefCookingCatalogContext then return false end
    return self:ScanMasterChefCooking(immediate)
end

function FF:ScanMasterChefCooking(immediate)
    if self.DeferScanRefresh and self:DeferScanRefresh("RefreshMasterChefCookingFromEvent",
        immediate or RecipeDiscoveryUrgent(self)) then return false end
    self.masterChefCookingCatalogContext = nil
    local api = C_TradeSkillUI
    if not api then self.masterChefScanState = "api"; return false end
    local cookingName = FF:GetNativeProfessionName(185,"Cooking")
    local ok, profession
    if api.GetBaseProfessionInfo then ok, profession = pcall(api.GetBaseProfessionInfo) end
    if (not ok or type(profession) ~= "table") and GetTradeSkillLine then
        local hasLine, name = pcall(GetTradeSkillLine)
        if hasLine and name == cookingName then profession = { professionID = 185 } end
    end
    local cookingOpen = type(profession) == "table" and (profession.professionID == 185
        or profession.parentProfessionID == 185 or profession.profession == 5
        or profession.professionName == cookingName
        or profession.parentProfessionName == cookingName)
    local otherOpen = type(profession) == "table" and not cookingOpen
    if cookingOpen then self.masterChefCookingSeen = true end
    if not (api.GetRecipeInfo and (api.GetProfessionSpells
        or api.GetAllRecipeIDs or api.GetFilteredRecipeIDs)
        and (api.GetRecipeOutputItemData or api.GetRecipeSchematic)) then
        self.masterChefScanState = "api"
        return false
    end
    local allowList = not otherOpen
    for _, method in ipairs({ "IsTradeSkillLinked", "IsNPCCrafting" }) do
        if api[method] then
            local checked, blocked = pcall(api[method])
            if not checked or blocked then allowList = false end
        end
    end
    if cookingOpen and self.masterChefRecipesChecked and api.IsDataSourceChanging then
        local checked, changing = pcall(api.IsDataSourceChanging)
        if not checked or changing then return false end
    end
    local recipeIDs, knownIDs, added = {}, {}, {}
    if api.GetProfessionSpells then
        for _, professionID in ipairs({ 185, 5 }) do
            local valid, spells = pcall(api.GetProfessionSpells, professionID)
            if valid and type(spells) == "table" then
                for _, id in ipairs(spells) do
                    if type(id) == "number" and not added[id] then
                        recipeIDs[#recipeIDs + 1] = id; knownIDs[id] = true; added[id] = true
                    end
                end
            end
            if #recipeIDs > 0 then break end
        end
    end
    if allowList then
        local valid, ids
        if api.GetAllRecipeIDs then valid, ids = pcall(api.GetAllRecipeIDs) end
        if (not valid or type(ids) ~= "table" or #ids == 0) and api.GetFilteredRecipeIDs then
            valid, ids = pcall(api.GetFilteredRecipeIDs)
        end
        if valid and type(ids) == "table" then
            for _, id in ipairs(ids) do
                if type(id) == "number" and not added[id] then
                    recipeIDs[#recipeIDs + 1] = id; added[id] = true
                end
            end
        end
    end
    for _, meal in ipairs(self.masterChefMeals) do
        local id = recipeSpellByOutput[meal.id]
        if id and not added[id] then recipeIDs[#recipeIDs + 1] = id; added[id] = true end
    end
    if #recipeIDs == 0 then
        self.masterChefScanState = cookingOpen and "loading" or "unavailable"
        return false
    end
    local recipes, verifiedLearned = {}, {}
    for _, recipeID in ipairs(recipeIDs) do
        if type(recipeID) == "number" then
                local hasInfo, info = pcall(api.GetRecipeInfo, recipeID)
                local hasOutput, output
                if api.GetRecipeOutputItemData then
                    hasOutput, output = pcall(api.GetRecipeOutputItemData, recipeID)
                end
                local itemID = hasOutput and type(output) == "table" and output.itemID
                local schematic
                if api.GetRecipeSchematic and (not itemID or mealByOutput[itemID]) then
                    local hasSchematic, result = pcall(api.GetRecipeSchematic, recipeID, false)
                    if hasSchematic and type(result) == "table" then
                        schematic = result
                        if not itemID then itemID = result.outputItemID end
                        if result.outputItemID and itemID ~= result.outputItemID then itemID = nil end
                    end
                end
                if type(itemID) == "number" and mealByOutput[itemID] then
                    local ingredients = RecipeIngredients(schematic)
                    local hasSpell, playerSpell
                    if IsPlayerSpell then hasSpell, playerSpell = pcall(IsPlayerSpell, recipeID) end
                    local learned = (hasInfo and type(info) == "table" and info.learned == true)
                        or knownIDs[recipeID] == true or (hasSpell and playerSpell == true)
                    if not recipes[itemID] or (learned and not recipes[itemID].learned) then
                        recipes[itemID] = { recipeID = recipeID, learned = learned,
                            ingredients = ingredients }
                        verifiedLearned[itemID] = knownIDs[recipeID] == true
                            or (hasSpell and type(playerSpell) == "boolean")
                            or (hasInfo and type(info) == "table" and type(info.learned) == "boolean")
                    end
                end
        end
    end
    if not next(recipes) then self.masterChefScanState = "unmatched"; return false end
    -- Check this scan, not retained records merged from an earlier complete scan.
    local complete = true
    for itemID, spellID in pairs(recipeSpellByOutput) do
        local recipe = recipes[itemID]
        -- A hidden or unavailable new recipe should not block reuse of a
        -- complete established catalogue. The profession events retry it.
        local required = not additionalMealOutputs[itemID] or knownIDs[spellID] or (recipe and recipe.learned)
        if required and (not recipe or recipe.recipeID ~= spellID or not recipe.ingredients
            or not verifiedLearned[itemID]) then complete = false; break end
    end
    for itemID, recipe in pairs(recipes) do
        if (not additionalMealOutputs[itemID] or recipe.learned)
            and (not recipe.ingredients or not verifiedLearned[itemID]) then complete = false; break end
    end
    for itemID, previous in pairs(self.masterChefRecipes or {}) do
        if not recipes[itemID] then recipes[itemID] = previous end
    end
    self.masterChefRecipes = recipes
    self.masterChefRecipesChecked = true
    self.masterChefScanState = nil
    -- Missing required outputs or reagent data remain retryable on every refresh.
    if complete then self.masterChefCookingCatalogContext = RecipeCatalogContext() end
    return true
end

function FF:RefreshMasterChefCookingFromEvent()
    self:InvalidateMasterChefRecipeCatalogs()
    self.masterChefTradeSkillSeen = true
    if self.DeferScanRefresh and self:DeferScanRefresh("RefreshMasterChefCookingFromEvent",
        RecipeDiscoveryUrgent(self)) then
        -- Invalidate settling callbacks from an earlier profession event too.
        self.masterChefScanToken = (self.masterChefScanToken or 0) + 1
        return
    end
    local function Scan(settling)
        self.masterChefCampCatalogContext = nil
        local seen = self.masterChefCookingSeen
        local state = self.masterChefScanState
        local updated = self:ScanMasterChefCooking()
        if settling and updated and self.RefreshFishingAchievements then
            self:RefreshFishingAchievements(true, true)
        end
        if (updated or self.masterChefCookingSeen ~= seen or self.masterChefScanState ~= state)
            and self.RefreshJournal then
            self:RefreshJournal()
        end
        if self.ContinueMasterChefCooking then self:ContinueMasterChefCooking() end
        if settling and self.RefreshMasterChefQuickTray then self:RefreshMasterChefQuickTray() end
    end
    Scan()
    if not (C_Timer and C_Timer.After) then return end
    self.masterChefScanToken = (self.masterChefScanToken or 0) + 1
    local token = self.masterChefScanToken
    C_Timer.After(0.2, function()
        if token ~= self.masterChefScanToken then return end
        Scan(true)
        C_Timer.After(0.6, function()
            if token == self.masterChefScanToken then Scan(true) end
        end)
    end)
end

-- Display data belongs to one synchronous render; callbacks/actions never keep it.
function FF:CreateMasterChefDisplaySnapshot()
    return { counts = {}, meals = {}, camps = {}, mealCrafts = {}, campCrafts = {} }
end

local function DisplayItemCount(itemID, display)
    if display and display.counts[itemID] ~= nil then
        local cached = display.counts[itemID]
        return cached ~= false and cached or nil
    end
    local getter = (C_Item and C_Item.GetItemCount) or GetItemCount
    local count
    if getter then
        local ok, value = pcall(getter, itemID, false, false)
        if ok and type(value) == "number" then count = value end
    end
    if display then
        if count == nil then display.counts[itemID] = false
        else display.counts[itemID] = count end
    end
    return count
end

-- Both queues share bag materials even while their profession is paused.
-- Keep one synchronous render cache; live click validation never reuses it.
local function CraftReservations(self, display)
    if display and display.reserved then return display.reserved end
    local totals = {}
    local function Add(recipes, id, quantity)
        local recipe = recipes and recipes[id]
        for _, ingredient in ipairs(recipe and recipe.ingredients or {}) do
            totals[ingredient.id] = (totals[ingredient.id] or 0) + ingredient.quantity * quantity
        end
    end
    for _, entry in ipairs(self.masterChefCookingQueue or {}) do
        Add(self.masterChefRecipes, entry.mealID, entry.quantity)
    end
    for _, entry in ipairs(self.masterChefCampCraftQueue or {}) do
        Add(self.masterChefCampRecipes, entry.itemID, entry.quantity)
    end
    if self.masterChefCookingQuickActive then Add(self.masterChefRecipes, self.masterChefCookingQuickActive, 1) end
    if self.masterChefCampCrafting and not self.masterChefCampCraftQueued then
        Add(self.masterChefCampRecipes, self.masterChefCampCrafting, 1)
    end
    if display then display.reserved = totals end
    return totals
end

local function BuildMealStatus(self, mealID, display)
    local recipe = self.masterChefRecipes and self.masterChefRecipes[mealID]
    if not recipe then return nil end
    if not recipe.learned then return { text = "Recipe not learned", order = 5, recipe = recipe } end
    local getCount = (C_Item and C_Item.GetItemCount) or GetItemCount
    if not recipe.ingredients or not getCount then
        return { text = "Known recipe", order = 3, recipe = recipe }
    end
    local counts, crafts = {}, nil
    for index, ingredient in ipairs(recipe.ingredients) do
        local count = DisplayItemCount(ingredient.id, display)
        if count == nil then
            return { text = "Known recipe", order = 3, recipe = recipe }
        end
        counts[index] = count
        local possible = math.floor(count / ingredient.quantity)
        crafts = crafts and math.min(crafts, possible) or possible
    end
    local ready = crafts and crafts > 0
    local mainReady = counts[1] >= recipe.ingredients[1].quantity
    return { text = ready and "Ingredients in bags"
            or (mainReady and "Need other ingredients" or "Need ingredients"),
        order = ready and 1 or (mainReady and 2 or 3), recipe = recipe,
        counts = counts, crafts = crafts or 0 }
end

function FF:GetMasterChefMealStatus(mealID, display)
    if display and display.meals[mealID] ~= nil then
        return display.meals[mealID] or nil
    end
    local status = BuildMealStatus(self, mealID, display)
    if display then display.meals[mealID] = status or false end
    return status
end

function FF:GetMasterChefAvailableCrafts(mealID, display)
    if display and display.mealCrafts[mealID] ~= nil then return display.mealCrafts[mealID] end
    local status = self:GetMasterChefMealStatus(mealID, display)
    if not (status and status.recipe.learned and status.counts) then return 0 end
    local available
    local reservations = CraftReservations(self, display)
    for index, ingredient in ipairs(status.recipe.ingredients) do
        local reserved = reservations[ingredient.id] or 0
        local possible = math.floor(math.max(0, status.counts[index] - reserved) / ingredient.quantity)
        available = available and math.min(available, possible) or possible
    end
    available = available or 0
    if display then display.mealCrafts[mealID] = available end
    return available
end

function FF:GetMasterChefQuickMeals(immediate, display)
    self:EnsureMasterChefCooking(immediate)
    display = display or self:CreateMasterChefDisplaySnapshot()
    local meals = {}
    for _, meal in ipairs(self.masterChefMeals) do
        local status = self:GetMasterChefMealStatus(meal.id, display)
        if status and status.recipe.learned
            and self:GetMasterChefAvailableCrafts(meal.id, display) > 0 then
            meals[#meals + 1] = meal
        end
    end
    return meals
end

function FF:AddMasterChefCooking(mealID, quantity)
    if not mealByOutput[mealID] or type(quantity) ~= "number" or quantity < 1
        or quantity % 1 ~= 0 or quantity > self:GetMasterChefAvailableCrafts(mealID) then return false end
    self.masterChefCookingQueue = self.masterChefCookingQueue or {}
    if #self.masterChefCookingQueue == 0 then self:SetMasterChefMessage("masterChefQueueMessage",nil) end
    for _, entry in ipairs(self.masterChefCookingQueue) do
        if entry.mealID == mealID then
            entry.quantity = entry.quantity + quantity
            return true
        end
    end
    self.masterChefCookingQueue[#self.masterChefCookingQueue + 1] = { mealID = mealID, quantity = quantity }
    return true
end

function FF:ChangeMasterChefCooking(mealID, change)
    if type(change) ~= "number" or change % 1 ~= 0 then return false end
    local queue = self.masterChefCookingQueue or {}
    for index, entry in ipairs(queue) do
        if entry.mealID == mealID then
            if change > 0 and change > self:GetMasterChefAvailableCrafts(mealID) then return false end
            if entry.quantity + change > 0 then entry.quantity = entry.quantity + change
            else return self:RemoveMasterChefCooking(mealID) end
            return true
        end
    end
    return false
end

function FF:RemoveMasterChefCooking(mealID)
    for index, entry in ipairs(self.masterChefCookingQueue or {}) do
        if entry.mealID == mealID then
            table.remove(self.masterChefCookingQueue, index)
            if (self.masterChefCookingActive == mealID
                and self.masterChefCookingQuickActive ~= mealID)
                or self.masterChefCookingPending == mealID then
                self.masterChefCookingActive = nil
                self.masterChefCookingPending = nil
                self.masterChefCookingRemaining = nil
                self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
                if not self.masterChefCookingQuickActive
                    and not self.masterChefCookingQuickPending then
                    self:ReleaseMasterChefCookingSession()
                end
            end
            if #self.masterChefCookingQueue == 0 then
                self:SetMasterChefMessage("masterChefQueueMessage",nil)
                if not self.masterChefCookingQuickActive
                    and not self.masterChefCookingQuickPending then
                    self:ReleaseMasterChefCookingSession()
                end
            end
            return true
        end
    end
    return false
end

local function CookingSessionReady()
    local api = C_TradeSkillUI
    if not api then return false end
    local ok, profession
    if api.GetBaseProfessionInfo then ok, profession = pcall(api.GetBaseProfessionInfo) end
    local cookingName = FF:GetNativeProfessionName(185,"Cooking")
    if (not ok or type(profession) ~= "table") and GetTradeSkillLine then
        local hasLine, name = pcall(GetTradeSkillLine)
        if hasLine and name == cookingName then profession = { professionID = 185 } end
    end
    if type(profession) ~= "table" then return false end
    if profession.professionID ~= 185 and profession.parentProfessionID ~= 185
        and profession.profession ~= 5 and profession.professionName ~= cookingName
        and profession.parentProfessionName ~= cookingName then return false end
    if api.IsTradeSkillReady then
        local checked, ready = pcall(api.IsTradeSkillReady)
        if not checked or not ready then return false end
    end
    return true
end

function FF:IsMasterChefCookingSessionReady()
    return CookingSessionReady()
end

local function NotifyDirectPreparation(chef, profession, action, preparing)
    if chef.ShowMasterChefPreparationNotice then
        chef:ShowMasterChefPreparationNotice(profession, action, preparing)
    end
end

function FF:ReviewMasterChefCookingSession(event)
    if event ~= "TRADE_SKILL_SHOW" or not self.masterChefOwnsCookingSession
        or not self.masterChefCookingPrepared or CookingSessionReady() then return end
    local quick = self.masterChefQuickMessage ~= nil
    self:ReleaseMasterChefCookingSession(true)
    if quick then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-changed-click")
    else
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-changed-prepare")
    end
    if self.RefreshJournal then self:RefreshJournal() end
end

function FF:ConcealMasterChefCookingPanel()
    if not self.masterChefOwnsCookingSession then return false end
    local frame = _G.ProfessionsFrame
    if not (frame and frame.IsShown and frame:IsShown()) then frame = _G.TradeSkillFrame end
    if not (frame and frame.IsShown and frame:IsShown() and frame.GetNumPoints and UIParent) then return nil end
    if not self.masterChefCookingPanel then
        local points = {}
        for index = 1, frame:GetNumPoints() do
            local anchor, relative, relativeAnchor, x, y = frame:GetPoint(index)
            points[index] = { anchor, relative, relativeAnchor, x, y }
        end
        self.masterChefCookingPanel = { frame = frame, points = points }
    end
    local ok = pcall(function()
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", WorldFrame or UIParent, "BOTTOMLEFT", 0, -100)
    end)
    if ok and self.RefreshFishingLayer then self:RefreshFishingLayer() end
    return ok
end

function FF:ReleaseMasterChefCookingSession(closed)
    ClearCraftRequest(self, "masterChefCookingRequest", true)
    local owned = self.masterChefOwnsCookingSession
    self.masterChefOwnsCookingSession = nil
    self.masterChefCookingPending = nil
    self.masterChefCookingQuickPending = nil
    self.masterChefCookingContextPending = nil
    self.masterChefCookingPendingView = nil
    self.masterChefCookingQuickActive = nil
    self.masterChefCookingPrepared = nil
    self.masterChefTrayCampPreparedRecipeID = nil
    local panel = self.masterChefCookingPanel
    self.masterChefCookingPanel = nil
    if InCombatLockdown and InCombatLockdown() then
        local pending = self.masterChefCookingClosePending or {}
        pending.close = pending.close or (owned and not closed)
        pending.panel = pending.panel or panel
        self.masterChefCookingClosePending = pending
        if owned and self.RefreshFishingLayer then self:RefreshFishingLayer() end
        return
    end
    if owned and not closed and C_TradeSkillUI and C_TradeSkillUI.CloseTradeSkill then
        pcall(C_TradeSkillUI.CloseTradeSkill)
    end
    if panel then
        pcall(function()
            panel.frame:ClearAllPoints()
            for _, point in ipairs(panel.points) do
                panel.frame:SetPoint(point[1], point[2], point[3], point[4], point[5])
            end
        end)
    end
    if owned and self.RefreshFishingLayer then self:RefreshFishingLayer() end
end

function FF:OnMasterChefCookingSessionClosed()
    if not self.masterChefOwnsCookingSession then return end
    local quick = self.masterChefCookingQuickPending or self.masterChefCookingQuickActive
    self.masterChefCookingActive = nil
    self.masterChefCookingQuickActive = nil
    self.masterChefCookingRemaining = nil
    self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
    if quick then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-stopped-click")
    else
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-stopped-start")
    end
    self:ReleaseMasterChefCookingSession(true)
    if self.RefreshJournal then self:RefreshJournal() end
end

local function WatchCraft(chef, mealID)
    chef.masterChefCraftToken = (chef.masterChefCraftToken or 0) + 1
    local token = chef.masterChefCraftToken
    if C_Timer and C_Timer.After then
        C_Timer.After(12, function()
            if chef.masterChefCookingActive == mealID and token == chef.masterChefCraftToken then
                ClearCraftRequest(chef, "masterChefCookingRequest", true)
                chef.masterChefCookingActive = nil
                if chef.masterChefCookingQuickActive == mealID then
                    chef.masterChefCookingQuickActive = nil
                    chef:SetMasterChefMessage("masterChefQuickMessage","chef.message.unconfirmed-click")
                else
                    chef:SetMasterChefMessage("masterChefQueueMessage","chef.message.unconfirmed-start")
                end
                chef.masterChefCookingRemaining = nil
                chef:KeepMasterChefCookingSessionAfterStop()
                if chef.RefreshJournal then chef:RefreshJournal() end
            end
        end)
    end
end

local function WatchPrepared(chef)
    chef.masterChefPreparedToken = (chef.masterChefPreparedToken or 0) + 1
    local token = chef.masterChefPreparedToken
    if C_Timer and C_Timer.After then
        C_Timer.After(30, function()
            if chef.masterChefCookingPrepared and chef.masterChefOwnsCookingSession
                and token == chef.masterChefPreparedToken then
                local panel = chef.journalPanel
                if not CookingSessionReady() then
                    local quick = chef.masterChefQuickMessage ~= nil
                    chef:ReleaseMasterChefCookingSession(true)
                    if quick then
                        chef:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-changed-click")
                    else
                        chef:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-changed-prepare")
                    end
                    if chef.RefreshJournal then chef:RefreshJournal() end
                elseif (panel and panel:IsShown() and chef.journalTab == "chef"
                    and (panel.chefView == "meals" or panel.chefView == "campfire"))
                    or (panel and panel:IsShown()
                        and (chef.masterChefCookingQueue or {})[1])
                    or (chef.masterChefTray and chef.masterChefTray:IsShown())
                    or (chef.masterChefCampPlacement and chef.masterChefCampPlacement.tray) then
                    WatchPrepared(chef)
                else
                    chef:ReleaseMasterChefCookingSession()
                end
            end
        end)
    end
end

function FF:KeepMasterChefCookingSessionAfterStop()
    if self.masterChefOwnsCookingSession and CookingSessionReady() then
        self.masterChefCookingPrepared = true
        WatchPrepared(self)
    else
        self:ReleaseMasterChefCookingSession(true)
    end
end

function FF:ContinueMasterChefCooking()
    if not self.masterChefCookingPending and not self.masterChefCookingQuickPending
        and not self.masterChefCookingContextPending then return end
    local quick = self.masterChefCookingQuickPending ~= nil
    local view = self.masterChefCookingPendingView
    local tray = self.masterChefCookingContextPending ~= nil and not view
    if InCombatLockdown and InCombatLockdown() then
        self:ReleaseMasterChefCookingSession()
        if quick then self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cook-after-combat")
        else self:SetMasterChefMessage("masterChefQueueMessage","chef.message.retry-after-combat") end
        if self.RefreshJournal then self:RefreshJournal() end
        return
    end
    local concealed = self:ConcealMasterChefCookingPanel()
    if concealed == false then
        self:ReleaseMasterChefCookingSession()
        if quick then self:SetMasterChefMessage("masterChefQuickMessage","chef.message.prepare-cooking-retry")
        else self:SetMasterChefMessage("masterChefQueueMessage","chef.message.conceal-cooking-retry") end
        if self.RefreshJournal then self:RefreshJournal() end
        return
    end
    if not concealed then return end
    if not CookingSessionReady() then return end
    self.masterChefCookingPending = nil
    self.masterChefCookingQuickPending = nil
    self.masterChefCookingContextPending = nil
    self.masterChefCookingPendingView = nil
    if not quick and not tray and not view and not (self.masterChefCookingQueue or {})[1] then
        self:ReleaseMasterChefCookingSession()
        return
    end
    self.masterChefCookingPrepared = true
    if tray then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.ui.ready-cook")
        if self.SetMasterChefQuickStatus then
            self:SetLocalizedMasterChefQuickStatus("chef.message.cooking-prepared")
        end
        local camp, status, rank = self:GetMasterChefQuickCampfire()
        local api = C_TradeSkillUI
        if camp and rank == 2 and api and api.OpenRecipe then
            local ok, result = pcall(api.OpenRecipe, camp.recipeID)
            if ok and result ~= false then
                self.masterChefTrayCampPreparedRecipeID = camp.recipeID
            end
        end
    elseif quick then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-ready-click")
        if self.SetMasterChefQuickStatus then
            self:SetLocalizedMasterChefQuickStatus("chef.message.prepared-click-cook")
        end
        if self.ShowMasterChefStatus then
            self:ShowMasterChefStatus("meals", "Cooking prepared", false, 2, nil, true)
        end
    elseif view then
        self:PrepareMasterChefBasicCampfire()
        if self.ShowMasterChefStatus then
            self:ShowMasterChefStatus(view, "Cooking prepared", false, 2, nil, true)
        end
    else
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-ready-start")
    end
    WatchPrepared(self)
    if self.RefreshJournal then self:RefreshJournal() end
end

function FF:PrepareMasterChefCookingContext(view)
    if self.MasterChefExternalPanelOpen and self:MasterChefExternalPanelOpen() then return false end
    if (InCombatLockdown and InCombatLockdown()) or self.masterChefOwnsCampSession
        or self.masterChefCookingActive or self.masterChefCookingPending
        or self.masterChefCookingQuickPending or self.masterChefCookingContextPending then return false end
    if CookingSessionReady() then return true end
    if not self.masterChefOwnsCookingSession then
        local frame = _G.ProfessionsFrame
        if not (frame and frame.IsShown and frame:IsShown()) then frame = _G.TradeSkillFrame end
        if frame and frame.IsShown and frame:IsShown() then return false end
    end
    if (self.masterChefCookingQueue or {})[1] then
        return self:StartMasterChefCooking(true)
    end
    local api = C_TradeSkillUI
    if not (api and api.OpenTradeSkill) then return false end
    self.masterChefCookingContextPending = true
    self.masterChefCookingPendingView = view
    self.masterChefOwnsCookingSession = true
    local ok, result = pcall(api.OpenTradeSkill, 185)
    if not ok or result == false then
        self:ReleaseMasterChefCookingSession(true)
        return false
    end
    self:ContinueMasterChefCooking()
    if C_Timer and C_Timer.After then
        C_Timer.After(4, function()
            if self.masterChefCookingContextPending then self:ReleaseMasterChefCookingSession() end
        end)
    end
    return true
end

function FF:PrepareMasterChefQuickTray()
    return self:PrepareMasterChefCookingContext()
end

function FF:PrepareMasterChefJournalView(view)
    if view ~= "campfire" and view ~= "meals" then return false end
    local prepared = self:PrepareMasterChefCookingContext(view)
    if prepared then self:PrepareMasterChefBasicCampfire() end
    if prepared and CookingSessionReady() and self.ShowMasterChefStatus then
        self:ShowMasterChefStatus(view, "Cooking prepared", false, 2, nil, true)
    end
    return prepared
end

function FF:StartMasterChefCooking(prepareOnly)
    if self.MasterChefExternalPanelOpen and self:MasterChefExternalPanelOpen() then
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.close-window-cook")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.retry-after-combat")
        return false
    end
    if self.masterChefCampCrafting or self.masterChefCampPreparing then
        self.masterChefQueueMessage = "Finish the current preparation or craft first"
        return false
    end
    if self.masterChefOwnsCampSession and not self.masterChefCampCrafting
        and not self.masterChefCampPreparing then
        if not self:UseMasterChefCampCookingPreparation() then
            self:ReleaseMasterChefCampSession()
        end
    end
    if self.masterChefOwnsCampSession then
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.finish-camp")
        return false
    end
    local entry = (self.masterChefCookingQueue or {})[1]
    if not entry then
        self.masterChefCookingActive = nil
        self:ReleaseMasterChefCookingSession()
        return false
    end
    self:ScanMasterChefCooking(true)
    local recipe = self.masterChefRecipes and self.masterChefRecipes[entry.mealID]
    if not (recipe and recipe.learned and recipe.recipeID and C_TradeSkillUI
        and C_TradeSkillUI.CraftRecipe) then
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.recipe-unavailable")
        self:ReleaseMasterChefCookingSession()
        return false
    end
    if self.masterChefCookingPending or self.masterChefCookingQuickPending
        or self.masterChefCookingActive then return false end
    local status = self:GetMasterChefMealStatus(entry.mealID)
    if not (status and status.crafts and status.crafts > 0) then
        self:SetMasterChefMessage("masterChefQueueMessage","chef.message.ingredients-missing",mealByOutput[entry.mealID].name)
        self:ReleaseMasterChefCookingSession()
        return false
    end
    if not CookingSessionReady() then
        if self.masterChefOwnsCookingSession and self.masterChefCookingPrepared then
            self:ReleaseMasterChefCookingSession(true)
        end
        if not C_TradeSkillUI.OpenTradeSkill then
            self:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-unavailable")
            self:ReleaseMasterChefCookingSession()
            return false
        end
        self.masterChefCookingPending = entry.mealID
        self.masterChefOwnsCookingSession = true
        self:SetMasterChefMessage("masterChefQueueMessage","chef.ui.preparing-cooking")
        local opened, result = pcall(C_TradeSkillUI.OpenTradeSkill, 185)
        if not opened or result == false then
            self:ReleaseMasterChefCookingSession(true)
            self:SetMasterChefMessage("masterChefQueueMessage","chef.message.start-cooking-failed")
            return false
        end
        self:ContinueMasterChefCooking()
        if C_Timer and C_Timer.After then
            local mealID = entry.mealID
            C_Timer.After(4, function()
                if self.masterChefCookingPending == mealID then
                    self:ReleaseMasterChefCookingSession()
                    self:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-unloaded-start")
                    if self.RefreshJournal then self:RefreshJournal() end
                end
            end)
        end
        return true
    end
    if prepareOnly then return true end
    local count = math.min(entry.quantity, status.crafts)
    self.masterChefCookingAttemptAt = GetTime and GetTime()
    self.masterChefCookingActive = entry.mealID
    self.masterChefCookingPrepared = nil
    self.masterChefTrayCampPreparedRecipeID = nil
    self.masterChefCookingRemaining = count
    self:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-meal",mealByOutput[entry.mealID].name)
    if not RequestRecipe(self, "masterChefCookingRequest", recipe.recipeID, count) then return false end
    if self.masterChefCookingActive == entry.mealID then WatchCraft(self, entry.mealID) end
    return true
end

function FF:QuickCookMasterChefMeal(mealID, quantity)
    if self.MasterChefExternalPanelOpen and self:MasterChefExternalPanelOpen() then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.close-window-cook")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cook-after-combat")
        return false
    end
    self:ScanMasterChefCooking(true)
    local recipe = self.masterChefRecipes and self.masterChefRecipes[mealID]
    if not (recipe and recipe.learned and recipe.recipeID and C_TradeSkillUI
        and C_TradeSkillUI.CraftRecipe) then return false end
    if self.masterChefCampCrafting or self.masterChefCampPreparing then
        self.masterChefQuickMessage = "Finish the current preparation or craft first"
        return false
    end
    if self.masterChefOwnsCampSession and not self.masterChefCampCrafting
        and not self.masterChefCampPreparing then
        if not self:UseMasterChefCampCookingPreparation() then
            self:ReleaseMasterChefCampSession()
        end
    end
    -- The profession can become ready before its update event reaches us. Use
    -- this second player click to finish preparation, then craft if ready.
    if self.masterChefCookingQuickPending == mealID then
        self:ContinueMasterChefCooking()
    end
    if self.masterChefOwnsCampSession or self.masterChefCookingActive
        or self.masterChefCookingPending or self.masterChefCookingQuickPending then
        if self.masterChefCookingQuickPending == mealID then
            NotifyDirectPreparation(self, "Cooking", "cook", true)
        end
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.finish-current")
        return false
    end
    local available = self:GetMasterChefAvailableCrafts(mealID)
    quantity = quantity or 1
    if available < quantity or quantity < 1 then
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.need-unreserved")
        return false
    end
    if not CookingSessionReady() then
        if self.masterChefCookingContextPending and self.masterChefOwnsCookingSession then
            self.masterChefCookingContextPending = nil
            self.masterChefCookingPendingView = nil
            self.masterChefCookingQuickPending = mealID
            self:SetMasterChefMessage("masterChefQuickMessage","chef.ui.preparing-cooking")
            self:ContinueMasterChefCooking()
            if C_Timer and C_Timer.After then
                C_Timer.After(4, function()
                    if self.masterChefCookingQuickPending == mealID then
                        self:ReleaseMasterChefCookingSession()
                        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-unloaded-click")
                        if self.RefreshJournal then self:RefreshJournal() end
                    end
                end)
            end
            if self.masterChefCookingQuickPending == mealID or self.masterChefCookingPrepared then
                NotifyDirectPreparation(self, "Cooking", "cook", not CookingSessionReady())
            end
            return true
        end
        if not self.masterChefOwnsCookingSession then
            local frame = _G.ProfessionsFrame
            if not (frame and frame.IsShown and frame:IsShown()) then frame = _G.TradeSkillFrame end
            if frame and frame.IsShown and frame:IsShown() then
                self:SetMasterChefMessage("masterChefQuickMessage","chef.message.close-profession")
                return false
            end
        end
        if self.masterChefOwnsCookingSession and self.masterChefCookingPrepared then
            self:ReleaseMasterChefCookingSession(true)
        end
        if not C_TradeSkillUI.OpenTradeSkill then
            self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-unavailable")
            return false
        end
        self.masterChefCookingQuickPending = mealID
        self.masterChefOwnsCookingSession = true
        self:SetMasterChefMessage("masterChefQuickMessage","chef.ui.preparing-cooking")
        local opened, result = pcall(C_TradeSkillUI.OpenTradeSkill, 185)
        if not opened or result == false then
            self:ReleaseMasterChefCookingSession(true)
            self:SetMasterChefMessage("masterChefQuickMessage","chef.message.prepare-cooking-failed")
            return false
        end
        self:ContinueMasterChefCooking()
        if C_Timer and C_Timer.After then
            C_Timer.After(4, function()
                if self.masterChefCookingQuickPending == mealID then
                    self:ReleaseMasterChefCookingSession()
                    self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-unloaded-click")
                    if self.RefreshJournal then self:RefreshJournal() end
                end
            end)
        end
        if self.masterChefCookingQuickPending == mealID or self.masterChefCookingPrepared then
            NotifyDirectPreparation(self, "Cooking", "cook", not CookingSessionReady())
        end
        return true
    end
    self.masterChefCookingAttemptAt = GetTime and GetTime()
    self.masterChefCookingActive = mealID
    self.masterChefCookingQuickActive = mealID
    self.masterChefCookingPrepared = nil
    self.masterChefCookingRemaining = quantity
    self:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-meal",mealByOutput[mealID].name)
    if not RequestRecipe(self, "masterChefCookingRequest", recipe.recipeID, quantity) then return false end
    if self.masterChefCookingActive == mealID then WatchCraft(self, mealID) end
    return true
end

function FF:OnMasterChefCraftSucceeded(recipeID, castGUID)
    if type(recipeID) ~= "number" or (issecretvalue and issecretvalue(recipeID)) then return end
    if type(castGUID) == "string" and not (issecretvalue and issecretvalue(castGUID))
        and self.masterChefAchievementLastSuccessGUID == castGUID then return end
    local request = self.masterChefCookingRequest
    if request and type(castGUID) == "string" and not (issecretvalue and issecretvalue(castGUID))
        and ((request.achievementSuccesses and request.achievementSuccesses[castGUID])
            or OtherCraftFailure(request, castGUID)) then return end
    local mealID = self.masterChefCookingActive
    local recipe = mealID and self.masterChefRecipes and self.masterChefRecipes[mealID]
    -- Use the existing request/active meal boundary. Queue entries alone and
    -- successes from player-owned Cooking cannot establish Chef cook facts.
    if self.RecordAchievementChefCook and request and recipe and mealByOutput[mealID]
        and recipe.recipeID == recipeID and request.recipeID == recipeID
        and not OtherCraftFailure(request, castGUID)
        and (type(castGUID) ~= "string" or not (issecretvalue and issecretvalue(castGUID))) then
        request.achievementSuccesses = request.achievementSuccesses or {}
        if type(castGUID) == "string" and not request.achievementSuccesses[castGUID] then
            request.achievementSuccesses[castGUID] = true
            self.masterChefAchievementLastSuccessGUID = castGUID
            self:RecordAchievementChefCook()
        end
    end
    local quick = self.masterChefCookingQuickActive
    local quickRecipe = quick and self.masterChefRecipes and self.masterChefRecipes[quick]
    if quickRecipe and quickRecipe.recipeID == recipeID then
        self.masterChefCookingRemaining = math.max(0,
            (self.masterChefCookingRemaining or 1) - 1)
        if self.masterChefCookingRemaining > 0 then
            if self.masterChefCookingRequest then
                self.masterChefCookingRequest.started, self.masterChefCookingRequest.castGUID = false, nil
            end
            WatchCraft(self, quick)
            if self.RefreshJournal then self:RefreshJournal() end
            return
        end
        self.masterChefCookingActive = nil
        self.masterChefCookingQuickActive = nil
        self.masterChefCookingRemaining = nil
        self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
        ClearCraftRequest(self, "masterChefCookingRequest", false)
        self:SetMasterChefMessage("masterChefQuickMessage","chef.message.meal-cooked",mealByOutput[quick].name)
        local panel = self.journalPanel
        if self.masterChefOwnsCookingSession and panel and panel:IsShown()
            and self.journalTab == "chef"
            and (panel.chefView == "meals" or panel.chefView == "campfire") then
            self.masterChefCookingPrepared = true
            WatchPrepared(self)
        else
            self:ReleaseMasterChefCookingSession()
        end
        if self.RefreshJournal then self:RefreshJournal() end
        return
    end
    if quick then return end
    local queue = self.masterChefCookingQueue or {}
    for index, entry in ipairs(queue) do
        local recipe = self.masterChefRecipes and self.masterChefRecipes[entry.mealID]
        if recipe and recipe.learned and recipe.recipeID == recipeID then
            local active = self.masterChefCookingActive == entry.mealID
            if active then
                if self.masterChefCookingRequest then
                    self.masterChefCookingRequest.started, self.masterChefCookingRequest.castGUID = false, nil
                end
                self.masterChefCookingRemaining = math.max(0, (self.masterChefCookingRemaining or 1) - 1)
            end
            entry.quantity = entry.quantity - 1
            if entry.quantity == 0 then table.remove(queue, index) end
            if active and entry.quantity == 0 then
                ClearCraftRequest(self, "masterChefCookingRequest", false)
                self.masterChefCookingActive = nil
                self.masterChefCookingRemaining = nil
                self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
                if #queue > 0 then
                    self:SetMasterChefMessage("masterChefQueueMessage","chef.message.next-meal")
                    local panel = self.journalPanel
                    if self.masterChefOwnsCookingSession and panel and panel:IsShown()
                        and self.journalTab == "chef" and panel.chefView == "meals" then
                        self.masterChefCookingPrepared = true
                        WatchPrepared(self)
                    elseif self.masterChefOwnsCookingSession then
                        self:ReleaseMasterChefCookingSession()
                    end
                    if self.PlayCookingCompleteAlert then self:PlayCookingCompleteAlert() end
                else
                    self:ReleaseMasterChefCookingSession()
                end
            elseif active and self.masterChefCookingRemaining == 0 then
                ClearCraftRequest(self, "masterChefCookingRequest", false)
                self.masterChefCookingActive = nil
                self.masterChefCookingRemaining = nil
                self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
                self:SetMasterChefMessage("masterChefQueueMessage","chef.message.continue-stack")
                local panel = self.journalPanel
                if self.masterChefOwnsCookingSession and panel and panel:IsShown()
                    and self.journalTab == "chef" and panel.chefView == "meals" then
                    self.masterChefCookingPrepared = true
                    WatchPrepared(self)
                elseif self.masterChefOwnsCookingSession then
                    self:ReleaseMasterChefCookingSession()
                end
            elseif active then
                WatchCraft(self, entry.mealID)
            elseif #queue == 0 then
                self.masterChefCookingActive = nil
                self.masterChefCookingRemaining = nil
                self:SetMasterChefMessage("masterChefQueueMessage",nil)
                self:ReleaseMasterChefCookingSession()
            end
            if self.RefreshJournal then self:RefreshJournal() end
            return
        end
    end
end

function FF:OnMasterChefCraftFailed(recipeID, castGUID)
    if type(recipeID) ~= "number" or (issecretvalue and issecretvalue(recipeID)) then return end
    if OtherCraftFailure(self.masterChefCookingRequest, castGUID) then return end
    local active = self.masterChefCookingActive
    local recipe = active and self.masterChefRecipes and self.masterChefRecipes[active]
    if recipe and recipe.recipeID == recipeID then
        ClearCraftRequest(self, "masterChefCookingRequest", true)
        local quick = self.masterChefCookingQuickActive == active
        self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
        self.masterChefCookingActive = nil
        self.masterChefCookingQuickActive = nil
        self.masterChefCookingRemaining = nil
        if quick then
            self:SetMasterChefMessage("masterChefQuickMessage","chef.message.craft-stopped-click")
        else
            self:SetMasterChefMessage("masterChefQueueMessage","chef.message.craft-stopped-retry")
        end
        self:KeepMasterChefCookingSessionAfterStop()
        if self.RefreshJournal then self:RefreshJournal() end
    end
end

function FF:OnMasterChefCraftStopped()
    local active = self.masterChefCookingActive
    local recipe = active and self.masterChefRecipes and self.masterChefRecipes[active]
    if recipe then self:OnMasterChefCraftFailed(recipe.recipeID) end
end

-- Seller inventory was checked against the Forever recipe item seller tables
-- and individual NPC map markers. Coordinates are zone-map positions, not an
-- NPC-name lookup at runtime. Recipes from trainers, drops, quests, and
-- unconfirmed sources intentionally have no vendor entry. Summoned camp bots
-- can sell sagefish recipes but have no fixed map position to link.
-- https://www.wowhead.com/forever/items/recipes/cooking
-- https://www.wowhead.com/forever/item=21099/recipe-smoked-sagefish
-- https://www.wowhead.com/forever/item=21219/recipe-sagefish-delight
-- https://www.wow-professions.com/forever/cooking-leveling-guide
local recipeVendors = {
    catherine = { "Catherine Leland", "Stormwind City", 1453, 55.1, 69.8, "Alliance" },
    khara = { "Khara Deepwater", "Loch Modan", 1432, 40.3, 39.3, "Alliance" },
    harn = { "Harn Longcast", "Mulgore", 1412, 47, 55, "Horde" },
    martine = { "Martine Tramblay", "Tirisfal Glades", 1420, 66, 60, "Horde" },
    sewa = { "Sewa Mistrunner", "Thunder Bluff", 1456, 55.8, 47, "Horde" },
    fyldan = { "Fyldan", "Darnassus", 1457, 48.6, 21.4, "Alliance" },
    xento = { "Xen'to", "Orgrimmar", 1454, 57.4, 53.2, "Horde" },
    tharynn = { "Tharynn Bouden", "Elwynn Forest", 1429, 41.8, 67.2, "Alliance" },
    nyoma = { "Nyoma", "Teldrassil", 1438, 57.2, 61.3, "Alliance" },
    gretta = { "Gretta Ganter", "Dun Morogh", 1426, 31.5, 44.7, "Alliance" },
    lizbeth = { "Lizbeth Cromwell", "Undercity", 1458, 81.0, 30.8, "Horde" },
    tansy = { "Tansy Puddlefizz", "Ironforge", 1455, 48.2, 6.5, "Alliance" },
    nyalah = { "Nyalah Brightfire", "Zephras Isle", "Zephras Isle", 60.6, 72.6, "Neutral" },
    zerril = { "Zerril Softbreeze", "Zephras Isle", "Zephras Isle", 43.8, 43.8, "Neutral" },
    nessa = { "Nessa Shadowsong", "Teldrassil", 1438, 56.3, 92.4, "Alliance" },
    zansoa = { "Zansoa", "Durotar", 1411, 57, 76, "Horde" },
    naal = { "Naal Mistrunner", "Thunder Bluff", 1456, 51, 52.5, "Horde" },
    killian = { "Killian Sanatha", "Silverpine Forest", 1421, 33, 17.8, "Horde" },
    laird = { "Laird", "Darkshore", 1439, 36, 44, "Alliance" },
    heldan = { "Heldan Galesong", "Darkshore", 1439, 37, 56.2, "Alliance" },
    kriggon = { "Kriggon Talsone", "Westfall", 1436, 36.2, 90, "Alliance" },
    kilxx = { "Kilxx", "The Barrens", 1413, 62.8, 38.2, "Neutral" },
    shankys = { "Shankys", "Orgrimmar", 1454, 70, 29.8, "Horde" },
    ronald = { "Ronald Burch", "Undercity", 1458, 62, 43, "Horde" },
    stuart = { "Stuart Fleming", "Wetlands", 1437, 8, 58.3, "Alliance" },
    lindea = { "Lindea Rabonne", "Hillsbrad Foothills", 1424, 50.6, 60.9, "Alliance" },
    wiktar = { "Wik'Tar", "Ashenvale", 1440, 11.7, 34.1, "Horde" },
    wulan = { "Wulan", "Desolace", 1443, 26, 69, "Horde" },
    tarban = { "Tarban Hearthgrain", "The Barrens", 1413, 55, 32, "Neutral" },
    otho = { "Otho Moji'ko", "The Hinterlands", 1425, 79.2, 79, "Horde" },
    emrul = { "Emrul Riknussun", "Ironforge", 1455, 59.9, 37.8, "Alliance" },
    aza = { "Aza'bek", "The Barrens", 1413, 49.6, 29.2, "Horde" },
    kalsey = { "Kalsey Sanden", "Redridge Mountains", 1433, 10.8, 72.5, "Alliance" },
    kelsey = { "Kelsey Yance", "Stranglethorn Vale", 1434, 28.2, 74.3, "Neutral" },
    erika = { "Erika Tate", "Stormwind City", 1453, 78, 53, "Alliance" },
    derak = { "Derak Nightfall", "Hillsbrad Foothills", 1424, 63, 19, "Horde" },
    micha = { "Micha Yance", "Hillsbrad Foothills", 1424, 49, 55, "Alliance" },
    gloria = { "Gloria Femmel", "Redridge Mountains", 1433, 26.6, 43.4, "Alliance" },
    gritta = { "Gritta Chumwater", "Riverglades", "Riverglades", 78.4, 55, "Neutral" },
    fimbo = { "Fimbo Greasemitz", "Riverglades", "Riverglades", 79, 54.2, "Neutral" },
    miranda = { "Miranda Turner", "Riverglades", "Riverglades", 63.4, 82.4, "Alliance" },
    qujo = { "Qujo", "The Hinterlands", 1425, 77.8, 78, "Neutral" },
    derek = { "Derek Odds", "Alterac Mountains", 1416, 12.4, 66, "Alliance" },
    paige = { "Paige", "Alterac Mountains", 1416, 20.8, 74.6, "Alliance" },
    carrie = { "Carrie Hearthfire", "Eastern Plaguelands", 1423, 95.2, 78.4, "Neutral" },
    gikkix = { "Gikkix", "Tanaris", 1446, 66.6, 22, "Neutral" },
    jabbey = { "Jabbey", "Tanaris", 1446, 67, 22, "Neutral" },
    grizzek = { "Grizzek", "Riverglades", "Riverglades", 76, 53, "Neutral" },
    vivianna = { "Vivianna", "Feralas", 1444, 31.2, 43.4, "Alliance" },
    sheendra = { "Sheendra Tallgrass", "Feralas", 1444, 74.6, 42.8, "Horde" },
}

local recipeSources = {
    [6290] = { "tharynn", "nyoma", "catherine", "gretta", "khara", "harn", "martine", "sewa", "lizbeth", "nyalah" },
    [787] = { "nessa", "zansoa", "tansy", "martine", "kriggon", "nyalah" },
    [4592] = { "tharynn", "nyoma", "khara", "tansy", "harn", "naal", "lizbeth", "killian", "nyalah" },
    [5476] = { "laird" },
    [6316] = { "khara" },
    [5095] = { "catherine", "nessa", "heldan", "kriggon", "stuart", "kilxx", "zansoa", "shankys", "ronald", "killian", "gritta" },
    [21072] = { "wulan", "naal", "zerril", "nyoma", "kelsey", "aza", "erika", "ronald", "xento", "kalsey", "emrul", "micha", "derak", "tarban", "fyldan", "otho", "gloria", "fimbo", "miranda", "qujo", "derek", "paige", "carrie" },
    [5526] = { "heldan", "kriggon" },
    [4593] = { "catherine", "lindea", "kilxx", "naal", "sewa", "ronald", "derak", "gritta" },
    [4594] = { "kelsey", "heldan", "stuart", "lindea", "tansy", "lizbeth", "shankys", "wiktar", "wulan" },
    [8364] = { "kelsey", "heldan", "stuart", "lindea", "tansy", "lizbeth", "shankys", "wiktar", "wulan" },
    [21217] = { "wulan", "naal", "zerril", "nyoma", "kelsey", "aza", "erika", "ronald", "xento", "kalsey", "emrul", "micha", "derak", "tarban", "fyldan", "otho", "gloria", "fimbo", "miranda", "qujo", "derek", "paige", "carrie" },
    [6038] = { "kelsey" },
    [6887] = { "gikkix" },
    [13927] = { "kelsey" },
    [13930] = { "kelsey" },
    [16766] = { "jabbey", "grizzek" },
    [13928] = { "gikkix" },
    [13929] = { "kelsey" },
    [13931] = { "gikkix" },
    [13932] = { "gikkix" },
    [13933] = { "vivianna", "sheendra" },
    [13935] = { "vivianna", "sheendra" },
    [13934] = { "vivianna", "sheendra" },
}

local namedMaps
function FF:GetGuideMapID(value)
    if type(value) == "number" then return value end
    if namedMaps and namedMaps[value] then return namedMaps[value] end
    if not (C_Map and C_Map.GetMapChildrenInfo) then return nil end
    -- Forever's new zone IDs differ from the UI map IDs used by WorldMapFrame.
    -- Reuse resolved UI IDs. A missing early map-tree result remains retryable
    -- on the next explicit guide render, rather than being cached as absent.
    namedMaps = namedMaps or {}
    if not namedMaps[value] then
        for _, root in ipairs({ 947, 1414, 1415 }) do
            local ok, children = pcall(C_Map.GetMapChildrenInfo, root, nil, true)
            if ok and children then
                for _, info in ipairs(children) do
                    namedMaps[info.name] = info.mapID
                    local canonical = self:GetCanonicalZoneName(info.name)
                    if canonical ~= info.name and not namedMaps[canonical] then namedMaps[canonical] = info.mapID end
                end
            end
        end
    end
    return namedMaps[value]
end

function FF:GetMealRecipeMapPoints(mealID, faction)
    local keys = recipeSources[mealID]
    if not keys then return nil end
    faction = faction or self:GetJournalFaction()
    local points = {}
    for _, key in ipairs(keys) do
        local vendor = recipeVendors[key]
        if vendor and (vendor[6] == faction or vendor[6] == "Neutral") then
            local mapID = self:GetGuideMapID(vendor[3])
            points[#points + 1] = { name = vendor[1], location = vendor[2],
                label = vendor[1] .. ", " .. vendor[2], mapID = mapID,
                x = vendor[4] / 100, y = vendor[5] / 100 }
        end
    end
    return #points > 0 and points or nil
end

-- Nearby reads the same verified seller/output records as recipe map links.
-- Match the player's map or its parents, never all children of a continent.
function FF:GetNearbyRecipeVendors(mapID, faction)
    local maps, seen = {}, {}
    while mapID and not seen[mapID] do
        maps[mapID], seen[mapID] = true, true
        local ok, info
        if C_Map and C_Map.GetMapInfo then ok, info = pcall(C_Map.GetMapInfo, mapID) end
        mapID = ok and info and info.parentMapID
        if mapID == 0 then mapID = nil end
    end
    local vendors, byKey = {}, {}
    for _, meal in ipairs(self.masterChefMeals or {}) do
        for _, point in ipairs(self:GetMealRecipeMapPoints(meal.id, faction) or {}) do
            if point.mapID and maps[point.mapID] then
                local key = point.mapID .. "/" .. point.name
                local vendor = byKey[key]
                if not vendor then
                    vendor = point
                    vendor.meals = {}
                    byKey[key], vendors[#vendors + 1] = vendor, vendor
                end
                vendor.meals[#vendor.meals + 1] = meal
            end
        end
    end
    table.sort(vendors, function(a, b) return a.name < b.name end)
    for _, vendor in ipairs(vendors) do
        table.sort(vendor.meals, self.CompareMasterChefMealSkills)
    end
    return vendors
end

-- Only the open meal is sorted. World coordinates from different continents
-- are unrelated, so same-continent sellers precede the remaining sellers.
function FF:GetOrderedMealRecipeVendors(mealID, faction)
    local points = self:GetMealRecipeMapPoints(mealID, faction)
    return self:GetOrderedGuideMapPoints(points)
end

-- Shared on-demand source selection for Chef and the visible Fishing route.
-- distance is squared world distance; never compare separate continents.
function FF:GetOrderedGuideMapPoints(points, measureSingle)
    if not points or #points < (measureSingle and 1 or 2) then return points end
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition
        and C_Map.GetWorldPosFromMapPos) then return points end
    local validMap, playerMapID = pcall(C_Map.GetBestMapForUnit, "player")
    if not validMap or not playerMapID then return points end
    local validPosition, playerPosition = pcall(C_Map.GetPlayerMapPosition, playerMapID, "player")
    if not validPosition or not playerPosition then return points end
    local ok, playerContinent, playerWorld = pcall(C_Map.GetWorldPosFromMapPos,
        playerMapID, playerPosition)
    local function ValidWorld(world)
        return world and type(world.x) == "number" and type(world.y) == "number"
            and world.x == world.x and world.y == world.y
            and math.abs(world.x) < math.huge and math.abs(world.y) < math.huge
    end
    if not ok or not playerContinent or not ValidWorld(playerWorld) then return points end
    for index, point in ipairs(points) do
        point.order = index
        point.distance = nil
        if point.mapID then
            local valid, continent, world = pcall(C_Map.GetWorldPosFromMapPos,
                point.mapID, { x = point.x, y = point.y })
            if valid and continent == playerContinent and ValidWorld(world) then
                local dx, dy = world.x - playerWorld.x, world.y - playerWorld.y
                point.distance = dx * dx + dy * dy
            end
        end
    end
    table.sort(points, function(a, b)
        if a.distance and not b.distance then return true end
        if b.distance and not a.distance then return false end
        if a.distance and b.distance and a.distance ~= b.distance then
            return a.distance < b.distance
        end
        return a.order < b.order
    end)
    return points
end

-- Curated Forever camp recipes. The client can expose temporary reagent IDs
-- for a camp schematic, so use live quantities only for matching item IDs.
local campReagentNames = {
    [159] = "Refreshing Spring Water", [765] = "Silverleaf", [1251] = "Linen Bandage",
    [2318] = "Light Leather", [2319] = "Medium Leather", [2320] = "Coarse Thread",
    [2321] = "Fine Thread", [2447] = "Peacebloom", [2452] = "Swiftthistle",
    [2772] = "Iron Ore", [2835] = "Rough Stone", [2838] = "Heavy Stone",
    [2840] = "Copper Bar", [2841] = "Bronze Bar", [2842] = "Silver Bar",
    [2996] = "Bolt of Linen Cloth", [3356] = "Kingsblood", [3371] = "Empty Vial",
    [3372] = "Leaded Vial", [3478] = "Coarse Grinding Stone", [3575] = "Iron Bar",
    [3713] = "Soothing Spices", [4234] = "Heavy Leather", [4305] = "Bolt of Silk Cloth",
    [4359] = "Handful of Copper Bolts", [4361] = "Copper Tube", [4371] = "Bronze Tube",
    [4375] = "Whirring Bronze Gizmo", [4470] = "Simple Wood", [5784] = "Slimy Murloc Scale",
    [6037] = "Truesilver Bar", [6452] = "Anti-Venom", [6453] = "Strong Anti-Venom",
    [8170] = "Rugged Leather", [8544] = "Mageweave Bandage", [8831] = "Purple Lotus",
    [8836] = "Arthas' Tears", [8925] = "Crystal Vial", [10284] = "Simple Flour",
    [10940] = "Strange Dust", [11137] = "Vision Dust", [11174] = "Lesser Nether Essence",
    [11291] = "Star Wood", [12037] = "Mystery Meat", [12204] = "Heavy Kodo Meat",
    [12359] = "Thorium Bar", [12365] = "Dense Stone", [13463] = "Dreamfoil",
    [13465] = "Mountain Silversage", [14047] = "Runecloth", [14048] = "Bolt of Runecloth",
    [14341] = "Rune Thread", [14344] = "Large Brilliant Shard", [14530] = "Heavy Runecloth Bandage",
    [15994] = "Thorium Widget", [16203] = "Greater Eternal Essence",
    [272941] = "Thick Logs", [273125] = "Lich's Index Finger", [273127] = "Golem Heart",
    [273128] = "Maker's Spark", [273129] = "Essence of Anarchy",
    [273130] = "Undeath Engine", [273131] = "Bottled Screams",
}

local function CampReagents(specs)
    local ingredients = {}
    for _, spec in ipairs(specs) do
        ingredients[#ingredients + 1] = { id = spec[1], quantity = spec[2],
            name = campReagentNames[spec[1]] }
    end
    return ingredients
end

local function CampItem(id, name, professionID, profession, skill, recipeID, specs, faction)
    return { id = id, name = name, professionID = professionID, profession = profession,
        skill = skill, recipeID = recipeID, ingredients = CampReagents(specs), faction = faction,
        source = skill <= 20 and "Learn through the profession's introductory camp training."
            or "Learn the corresponding camp blueprint." }
end

FF.masterChefCamps = {
    { id = 279981, name = "Basic Campfire", professionID = 185, profession = "Cooking",
      skill = 1, recipeID = 1229737, placeSpellID = 1307227, basic = true,
      toolID = 4471, toolName = "Flint and Tinder",
      ingredients = CampReagents({ { 4470, 1 } }),
      source = "Learn Cooking and craft with Simple Wood and Flint and Tinder.",
      benefit = "Cook at the fire and add up to 3 camp features, one per player. Sit or craft nearby for 1 min to gain camp benefits." },
    { id = 279967, name = "Fish Bowl", skill = 20, recipeID = 1229745, placeSpellID = 1307245,
      ingredients = { { id = 6291, name = "Raw Brilliant Smallfish", quantity = 1 },
          { id = 3371, name = "Empty Vial", quantity = 1 } },
      source = "Camping 101: Fishing leads to a Fishing trainer at skill 20.",
      benefit = "Place beside a Campfire. Nearby seated players gain 8% more stats; this does not stack with Blessing of Kings." },
    { id = 279965, name = "Fishing Rack", skill = 140, recipeID = 1262990, placeSpellID = 1307247,
      ingredients = { { id = 4470, name = "Simple Wood", quantity = 2 },
          { id = 8925, name = "Crystal Vial", quantity = 1 },
          { id = 8365, name = "Raw Mithril Head Trout", quantity = 2 } },
      source = "Blueprint: Fishing Rack drops from Gelihast in Blackfathom Deeps.",
      benefit = "At a campfire, grants 1 hr of access to uncommon catches and offers lures to everyone. Improves your chance of catching bloated fish. Can replace a Fish Bowl, keeping its benefits." },
    { id = 279966, name = "Fishing Hut", skill = 300, recipeID = 1262998, placeSpellID = 1307246,
      ingredients = { { id = 4470, name = "Simple Wood", quantity = 5 },
          { id = 14048, name = "Bolt of Runecloth", quantity = 2 },
          { id = 273295, name = "Seasonal Fish Steaks", quantity = 1 } },
      source = "Blueprint: Fishing Hut drops from Jammal'an the Prophet in Sunken Temple.",
      benefit = "At a campfire, grants 1 hr of access to rare catches and offers Fishing lures. Can replace a Fish Bowl, keeping its benefits." },
    CampItem(279956, "Mana Well", 171, "Alchemy", 20, 1230564, { { 2447, 1 }, { 3371, 1 } }),
    CampItem(279970, "Fermenter", 171, "Alchemy", 140, 1263005, { { 3372, 1 }, { 3356, 1 }, { 2452, 1 } }),
    CampItem(279990, "Alchemy Laboratory", 171, "Alchemy", 300, 1263078, { { 273125, 1 }, { 8925, 1 }, { 13463, 2 } }),
    CampItem(279944, "Sharpening Wheel", 164, "Blacksmithing", 20, 1230171, { { 2835, 1 }, { 2840, 1 } }),
    CampItem(279988, "Anvil", 164, "Blacksmithing", 140, 1263041, { { 2841, 5 }, { 3478, 2 }, { 2319, 2 } }),
    CampItem(279955, "Master Forge", 164, "Blacksmithing", 300, 1263073, { { 273127, 1 }, { 12359, 5 }, { 8170, 2 } }),
    CampItem(279976, "Enchanted Lute", 333, "Enchanting", 20, 1230643, { { 4470, 1 }, { 10940, 1 } }),
    CampItem(279985, "Arcane Salvager", 333, "Enchanting", 140, 1263056, { { 11137, 2 }, { 11174, 1 } }),
    CampItem(279987, "Arcane Forge", 333, "Enchanting", 300, 1263082, { { 273128, 1 }, { 14344, 2 }, { 16203, 4 } }),
    CampItem(279950, "Reagent Bot", 202, "Engineering", 20, 1230656, { { 4359, 1 }, { 4361, 1 } }),
    CampItem(279949, "Repair Bot", 202, "Engineering", 140, 1263034, { { 4375, 2 }, { 4371, 1 }, { 4234, 1 } }),
    CampItem(279989, "Anarchist's Workbench", 202, "Engineering", 300, 1263083, { { 273129, 1 }, { 15994, 2 } }),
    CampItem(279962, "Incense Candle", 182, "Herbalism", 20, 1229705, { { 2447, 1 }, { 765, 1 } }),
    CampItem(279964, "Greenhouse", 182, "Herbalism", 140, 1262980, { { 4470, 2 }, { 8836, 1 }, { 8831, 1 } }),
    CampItem(279947, "Seed Hybridizer", 182, "Herbalism", 300, 1263070, { { 13465, 4 }, { 8925, 1 }, { 14047, 2 } }),
    CampItem(279978, "Camp Tent", 165, "Leatherworking", 20, 1229432, { { 2318, 5 } }),
    CampItem(279941, "Tanning Rack", 165, "Leatherworking", 140, 1263031, { { 2319, 5 }, { 2321, 3 }, { 4470, 2 } }),
    CampItem(279945, "Sewing Machine", 165, "Leatherworking", 300, 1263079, { { 273130, 1 }, { 8170, 5 }, { 14341, 1 } }),
    CampItem(279960, "Lodestone", 186, "Mining", 20, 1230161, { { 2835, 1 }, { 2840, 1 } }),
    CampItem(279948, "Rock Garden", 186, "Mining", 140, 1262975, { { 2838, 2 }, { 2772, 1 }, { 2842, 1 } }),
    CampItem(279952, "Molten Foundry", 186, "Mining", 300, 1263071, { { 12359, 5 }, { 12365, 2 }, { 6037, 1 } }),
    CampItem(279979, "Camp Chair", 393, "Skinning", 20, 1229517, { { 2318, 3 }, { 4470, 2 } }),
    CampItem(279969, "Field Guide", 393, "Skinning", 140, 1262985, { { 2319, 3 }, { 5784, 2 }, { 2321, 1 } }),
    CampItem(279938, "Trapper's Workbench", 393, "Skinning", 300, 1262982, { { 4470, 2 }, { 4234, 4 }, { 3575, 1 } }),
    CampItem(279972, "Faction Banner", 197, "Tailoring", 20, 1229504, { { 2996, 1 }, { 2320, 1 } }, "Horde"),
    CampItem(279973, "Faction Banner", 197, "Tailoring", 20, 1263425, { { 2996, 1 }, { 2320, 1 } }, "Alliance"),
    CampItem(279943, "Spinning Wheel", 197, "Tailoring", 140, 1263032, { { 4470, 2 }, { 4305, 5 }, { 2321, 3 } }),
    CampItem(279959, "Loom", 197, "Tailoring", 300, 1263080, { { 273131, 1 }, { 14048, 4 }, { 4470, 4 } }),
    CampItem(279961, "Journeyman Campfire", 185, "Cooking", 90, 1283400, { { 11291, 1 } }),
    CampItem(279957, "Cookie's Feast", 185, "Cooking", 140, 1262978, { { 12037, 2 }, { 12204, 1 }, { 3713, 1 } }),
    CampItem(279974, "Expert Campfire", 185, "Cooking", 200, 1291341, { { 272941, 1 } }),
    CampItem(279982, "Iron Oven", 185, "Cooking", 300, 1263067, { { 10284, 10 }, { 159, 5 }, { 3713, 4 } }),
    CampItem(279968, "First Aid Kit", 129, "First Aid", 20, 1230117, { { 1251, 3 }, { 159, 1 } }),
    CampItem(279940, "Toxin Study", 129, "First Aid", 140, 1262996, { { 6452, 1 }, { 8544, 2 }, { 4470, 2 } }),
    CampItem(279951, "Plague Doctor's Laboratory", 129, "First Aid", 300, 1263001, { { 4470, 2 }, { 6453, 2 }, { 14530, 5 } }),
}

local campEffects = {
    [279956] = "Restores mana to nearby campers.",
    [279970] = "Makes alchemy reagents at camp and improves mana recovery.",
    [279990] = "Provides an alchemy workspace at camp.",
    [279944] = "Provides a Strength benefit at camp.",
    [279988] = "Provides an anvil and the Sharpening Wheel benefit.",
    [279955] = "Provides a forge and the Sharpening Wheel benefit.",
    [279976] = "Provides a camp music benefit to nearby players.",
    [279985] = "Improves disenchanting at camp and keeps the lute benefit.",
    [279987] = "Provides an enchanting workspace at camp.",
    [279950] = "Provides a reagent vendor at camp.",
    [279949] = "Provides repair and reagent services at camp.",
    [279989] = "Provides an engineering workspace at camp.",
    [279962] = "Provides an Intellect benefit at camp.",
    [279964] = "Grows herbs from seeds and keeps the incense benefit.",
    [279947] = "Creates hybrid seeds and keeps the incense benefit.",
    [279978] = "Restores rested experience at camp.",
    [279941] = "Makes leatherworking reagents and keeps the tent benefit.",
    [279945] = "Provides a leatherworking workspace at camp.",
    [279960] = "Provides a melee attack power benefit at camp.",
    [279948] = "Produces a mining node over time and keeps the lodestone benefit.",
    [279952] = "Provides a mining workspace at camp.",
    [279979] = "Provides a critical strike benefit at camp.",
    [279969] = "Allows Track Beasts at camp and keeps the chair benefit.",
    [279938] = "Provides a trap at camp and keeps the chair benefit.",
    [279972] = "Provides a Spirit benefit to nearby Horde players.",
    [279973] = "Provides a Spirit benefit to nearby Alliance players.",
    [279943] = "Makes tailoring reagents and keeps the banner benefit.",
    [279959] = "Provides a tailoring workspace at camp.",
    [279961] = "Cooking 90 to craft and place. Supports up to 5 additional camp features.",
    [279957] = "Place by a cooking fire to serve Stamina food.",
    [279974] = "Cooking 200 to learn. Cooking 220 to place. Supports up to 10 additional camp features.",
    [279982] = "Place by a cooking fire for advanced Cooking recipes.",
    [279968] = "Provides a Stamina benefit at camp.",
    [279940] = "Provides healing and anti-venom supplies at camp.",
    [279951] = "Provides potions and poultices at camp.",
}
local campSources = {
    [279961] = "Blueprint: Journeyman Campfire drops from Lord Serpentis in Wailing Caverns.",
    [279957] = "Blueprint: Cookie's Feast drops from Cookie in The Deadmines.",
    [279974] = "Blueprint: Expert Campfire drops from Slavecrusher Grox in Krol'dok Stronghold.",
    [279982] = "Blueprint: Iron Oven drops from Quartermaster Zigris in Lower Blackrock Spire.",
}
for _, camp in ipairs(FF.masterChefCamps) do
    camp.source = campSources[camp.id] or camp.source
    camp.benefit = camp.benefit or campEffects[camp.id]
end

FF.masterChefCampMilestones = {
    { after = 1, heading = "Camp milestone  •  Fishing 20: Fish Bowl",
      body = "Camping 101: Fishing sends you to a trainer for the Fish Bowl. Use 1 Raw Brilliant Smallfish and 1 Empty Vial. Build a Campfire before placing it; the seated buff is 8% stats and does not stack with Blessing of Kings." },
    { after = 4, heading = "Camp milestone  •  Fishing 140: Fishing Rack",
      body = "Blueprint: Fishing Rack drops from Gelihast in Blackfathom Deeps. Use 2 Simple Wood, 1 Crystal Vial and 2 Raw Mithril Head Trout. Place by a campfire for 1 hr of uncommon-catch access. Lures are available to everyone. Improves your chance of catching bloated fish. Can replace a Fish Bowl." },
    { after = 7, heading = "Camp milestone  •  Fishing 300: Fishing Hut",
      body = "Blueprint: Fishing Hut drops from Jammal'an the Prophet in Sunken Temple. Use 5 Simple Wood, 2 Bolt of Runecloth and 1 Seasonal Fish Steaks. At level 35 and Fishing 275, use a Chef's Knife on Raw Summer Bass or Raw Winter Squid to prepare the steaks. Place by a campfire for 1 hr of rare-catch access. Provides Fishing lures. Can replace a Fish Bowl. Camp features share a 1 hr placement cooldown." },
}

local campByItem, campByRecipe, campByPlacement = {}, {}, {}
for _, camp in ipairs(FF.masterChefCamps) do
    campByItem[camp.id] = camp
    campByRecipe[camp.recipeID] = camp
    if camp.placeSpellID then campByPlacement[camp.placeSpellID] = camp end
end

function FF:GetMasterChefCampEntries()
    local professions = {}
    if GetProfessions and GetProfessionInfo then
        local indices = { GetProfessions() }
        for slot = 1, 6 do
            local index = indices[slot]
            if index then
                local name, _, rank, cap, _, _, skillLine = GetProfessionInfo(index)
                local stat = { value = rank, cap = cap }
                if type(skillLine) == "number" then professions[skillLine] = stat end
                if name then professions[name] = stat end
            end
        end
    end
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    local entries = {}
    for _, camp in ipairs(self.masterChefCamps) do
        if camp.basic or not camp.profession or camp.profession == "Fishing"
            or (not camp.faction or camp.faction == faction)
                and (professions[camp.professionID] or professions[camp.profession]) then
            entries[#entries + 1] = camp
        end
    end
    return entries, professions
end

local function CampItemCount(itemID, display)
    return DisplayItemCount(itemID, display)
end

local function MatchingCampIngredients(live, catalog)
    if not live or #live ~= #catalog then return nil end
    local expected = {}
    for _, ingredient in ipairs(catalog) do expected[ingredient.id] = ingredient end
    for _, ingredient in ipairs(live) do
        local entry = expected[ingredient.id]
        if not entry then return nil end
        ingredient.name = entry.name
        expected[ingredient.id] = nil
    end
    return live
end

local function CampCatalogContext(self, entries, professions)
    local context = RecipeCatalogContext()
    if not context then return nil end
    if not entries then entries, professions = self:GetMasterChefCampEntries() end
    local parts = { context }
    for _, camp in ipairs(entries) do
        local stat = professions[camp.professionID or 356] or professions[camp.profession]
        parts[#parts + 1] = tostring(camp.id) .. ":" .. tostring(stat and stat.value)
            .. ":" .. tostring(stat and stat.cap)
    end
    return table.concat(parts, "|")
end

function FF:EnsureMasterChefCamps()
    local context = CampCatalogContext(self)
    if not RecipeDiscoveryUrgent(self) and self.masterChefCampRecipes and context
        and context == self.masterChefCampCatalogContext then return false end
    self:ScanMasterChefCamps()
    return true
end

function FF:ScanMasterChefCamps()
    self.masterChefCampCatalogContext = nil
    local api = C_TradeSkillUI
    local recipes = {}
    local knownByProfession = {}
    local entries, professions = self:GetMasterChefCampEntries()
    local complete = api and api.GetRecipeSchematic and true or false
    for _, camp in ipairs(entries) do
        local professionID = camp.professionID or 356
        local known = knownByProfession[professionID]
        if not known then
            known = {}
            knownByProfession[professionID] = known
            if api and api.GetProfessionSpells then
                local ok, spells = pcall(api.GetProfessionSpells, professionID)
                if ok and type(spells) == "table" then
                    for _, id in ipairs(spells) do known[id] = true end
                end
            end
        end
        local learned = known[camp.recipeID] == true
        local checkedSpell = false
        if IsPlayerSpell then
            local ok, result = pcall(IsPlayerSpell, camp.recipeID)
            checkedSpell = ok and type(result) == "boolean"
            learned = learned or (ok and result == true)
        end
        if not checkedSpell then complete = false end
        if api and api.GetRecipeInfo then
            local ok, info = pcall(api.GetRecipeInfo, camp.recipeID)
            learned = learned or (ok and type(info) == "table" and info.learned == true)
        end
        -- Basic Campfire is supplied with Cooking rather than a separate blueprint.
        local cooking = professions[185] or professions.Cooking
        learned = learned or (camp.basic and cooking
            and type(cooking.value) == "number" and cooking.value >= 1)
        local ingredients = camp.ingredients
        local verifiedIngredients = false
        if api and api.GetRecipeSchematic then
            local ok, schematic = pcall(api.GetRecipeSchematic, camp.recipeID, false)
            if ok and type(schematic) == "table" then
                local matches = schematic.outputItemID == camp.id
                if not matches and api.GetRecipeOutputItemData then
                    local valid, output = pcall(api.GetRecipeOutputItemData, camp.recipeID)
                    matches = valid and type(output) == "table" and output.itemID == camp.id
                end
                if matches then
                    local live = MatchingCampIngredients(RecipeIngredients(schematic), camp.ingredients)
                    verifiedIngredients = live ~= nil
                    ingredients = live or ingredients
                end
            end
        end
        if not verifiedIngredients then complete = false end
        recipes[camp.id] = { learned = learned, recipeID = camp.recipeID, ingredients = ingredients }
    end
    self.masterChefCampRecipes = recipes
    if complete then self.masterChefCampCatalogContext = CampCatalogContext(self, entries, professions) end
end

local function BuildCampStatus(self, itemID, display)
    local camp = campByItem[itemID]
    if not camp then return nil end
    local recipe = self.masterChefCampRecipes and self.masterChefCampRecipes[itemID]
    local owned = CampItemCount(itemID, display) or 0
    local ingredients = recipe and recipe.ingredients or camp.ingredients
    local counts, crafts = {}, nil
    for index, ingredient in ipairs(ingredients) do
        local count = CampItemCount(ingredient.id, display)
        counts[index] = count
        local possible = count and math.floor(count / ingredient.quantity) or 0
        crafts = crafts and math.min(crafts, possible) or possible
    end
    crafts = crafts or 0
    local toolCount = camp.toolID and CampItemCount(camp.toolID, display) or nil
    if camp.toolID and (toolCount or 0) < 1 then crafts = 0 end
    local ready = crafts > 0
    local learned = recipe and recipe.learned == true
    return { order = owned > 0 and 1 or learned and (ready and 2 or 3) or 4,
        owned = owned, learned = learned, ready = ready, crafts = crafts,
        ingredients = ingredients, counts = counts, toolCount = toolCount }
end

function FF:GetMasterChefCampStatus(itemID, display)
    if display and display.camps[itemID] ~= nil then return display.camps[itemID] or nil end
    local status = BuildCampStatus(self, itemID, display)
    if display then display.camps[itemID] = status or false end
    return status
end

function FF:GetMasterChefQuickCampfire(scanned, display)
    if not scanned then self:EnsureMasterChefCamps() end
    local selected, selectedStatus, selectedRank
    for _, camp in ipairs(self.masterChefCamps) do
        if camp.basic or camp.id == 279961 or camp.id == 279974 then
            local status = self:GetMasterChefCampStatus(camp.id, display)
            local rank = status and (status.owned > 0 and 3
                or status.learned and self:GetMasterChefCampAvailableCrafts(camp.id, display) > 0 and 2
                or status.learned and 1 or 0) or 0
            if not selected or rank > selectedRank
                or rank == selectedRank and ((rank >= 2 and camp.skill > selected.skill)
                    or (rank < 2 and camp.skill < selected.skill)) then
                selected, selectedStatus, selectedRank = camp, status, rank
            end
        end
    end
    return selected, selectedStatus, selectedRank
end

function FF:GetMasterChefQuickCamps(display)
    self:EnsureMasterChefCamps()
    display = display or self:CreateMasterChefDisplaySnapshot()
    local smart, status, rank = self:GetMasterChefQuickCampfire(true, display)
    local eligible = {}
    for _, camp in ipairs(self:GetMasterChefCampEntries()) do eligible[camp.id] = true end
    local camps = {}
    for _, camp in ipairs(self.masterChefCamps) do
        if camp.id ~= (smart and smart.id) then
            local state = self:GetMasterChefCampStatus(camp.id, display)
            local craftable = eligible[camp.id] and state.learned
                and self:GetMasterChefCampAvailableCrafts(camp.id, display) > 0
            if state.owned > 0 or craftable then
                camps[#camps + 1] = { camp = camp, status = state,
                    craftable = craftable and true or false }
            end
        end
    end
    table.sort(camps, function(a, b)
        local aFishing = not a.camp.profession or a.camp.profession == "Fishing"
        local bFishing = not b.camp.profession or b.camp.profession == "Fishing"
        if aFishing ~= bFishing then return aFishing end
        if a.camp.profession ~= b.camp.profession then
            return (a.camp.profession or "") < (b.camp.profession or "")
        end
        if a.camp.skill ~= b.camp.skill then return a.camp.skill < b.camp.skill end
        return a.camp.id < b.camp.id
    end)
    return smart, status, rank, camps
end

function FF:GetMasterChefCampAvailableCrafts(itemID, display)
    if display and display.campCrafts[itemID] ~= nil then return display.campCrafts[itemID] end
    local status = self:GetMasterChefCampStatus(itemID, display)
    if not (status and status.learned and (not campByItem[itemID].toolID
        or (status.toolCount or 0) > 0)) then return 0 end
    local available
    local reservations = CraftReservations(self, display)
    for index, ingredient in ipairs(status.ingredients) do
        local reserved = reservations[ingredient.id] or 0
        local possible = math.floor(math.max(0, (status.counts[index] or 0) - reserved)
            / ingredient.quantity)
        available = available and math.min(available, possible) or possible
    end
    available = available or 0
    if display then display.campCrafts[itemID] = available end
    return available
end

function FF:AddMasterChefCampCraft(itemID, quantity)
    if not campByItem[itemID] or type(quantity) ~= "number" or quantity < 1
        or quantity % 1 ~= 0 or quantity > self:GetMasterChefCampAvailableCrafts(itemID) then return false end
    self.masterChefCampCraftQueue = self.masterChefCampCraftQueue or {}
    if #self.masterChefCampCraftQueue == 0 then self:SetMasterChefMessage("masterChefCampQueueMessage",nil) end
    for _, entry in ipairs(self.masterChefCampCraftQueue) do
        if entry.itemID == itemID then
            entry.quantity = entry.quantity + quantity
            return true
        end
    end
    self.masterChefCampCraftQueue[#self.masterChefCampCraftQueue + 1] =
        { itemID = itemID, quantity = quantity }
    return true
end

function FF:RemoveMasterChefCampCraft(itemID)
    for index, entry in ipairs(self.masterChefCampCraftQueue or {}) do
        if entry.itemID == itemID then
            table.remove(self.masterChefCampCraftQueue, index)
            if self.masterChefCampCrafting == itemID or self.masterChefCampPreparing == itemID then
                self:ReleaseMasterChefCampSession()
            end
            if #self.masterChefCampCraftQueue == 0 then self:SetMasterChefMessage("masterChefCampQueueMessage",nil) end
            return true
        end
    end
    return false
end

local function CampSessionReady(professionID, professionName)
    local api = C_TradeSkillUI
    if not api then return false end
    if professionID == 185 and CookingSessionReady() then return true end
    local wanted = FF:GetNativeProfessionName(professionID,professionName)
    local function Named(name)
        if issecretvalue and issecretvalue(name) then return false end
        return type(name)=="string" and (name==wanted or name==professionName)
    end
    local ok, profession
    if api.GetBaseProfessionInfo then ok, profession = pcall(api.GetBaseProfessionInfo) end
    local matches = ok and type(profession) == "table" and
        (profession.professionID == professionID or profession.parentProfessionID == professionID
            or Named(profession.professionName) or Named(profession.parentProfessionName))
    if not matches and GetTradeSkillLine then
        local checked, name = pcall(GetTradeSkillLine)
        matches = checked and Named(name)
    end
    if not matches then return false end
    if api.IsTradeSkillReady then
        local checked, ready = pcall(api.IsTradeSkillReady)
        if not checked or not ready then return false end
    end
    if api.GetTradeSkillLine then
        local checked, lineID, lineName = pcall(api.GetTradeSkillLine)
        if checked then
            local named = type(lineName) == "string" and lineName ~= ""
            local lineMatches = named and Named(lineName)
            if type(lineID) == "number" and lineID > 0 then
                if lineID==professionID then return true end
                return lineMatches or false
            end
            if named and not lineMatches then return false end
        end
    end
    return true
end

function FF:GetMasterChefPreparedProfession()
    local camp = campByRecipe[self.masterChefCampPreparedRecipeID]
    if camp and CampSessionReady(camp.professionID or 356,
        camp.profession or "Fishing") then
        return camp.profession or "Fishing"
    end
    if self.masterChefOwnsCampSession then return nil end
    if (self.masterChefCookingPrepared or not self.masterChefOwnsCookingSession)
        and CookingSessionReady() then return "Cooking" end
end

function FF:PrepareMasterChefBasicCampfire()
    if not self.masterChefOwnsCookingSession or not self.masterChefCookingPrepared
        or self.masterChefCookingActive or self.masterChefCookingPending
        or self.masterChefCookingQuickPending
        or (self.masterChefCookingQueue or {})[1]
        or (self.masterChefCampCraftQueue or {})[1]
        or not CampSessionReady(185, "Cooking") then return false end
    local camp = campByItem[279981]
    if self.masterChefTrayCampPreparedRecipeID == camp.recipeID then return true end
    local api = C_TradeSkillUI
    if not (api and api.OpenRecipe) then return false end
    self:ScanMasterChefCamps()
    if self:GetMasterChefCampAvailableCrafts(camp.id) < 1 then return false end
    local ok, result = pcall(api.OpenRecipe, camp.recipeID)
    if not ok or result == false then return false end
    self.masterChefTrayCampPreparedRecipeID = camp.recipeID
    return true
end

function FF:UseMasterChefTrayCampPreparation(itemID)
    local camp = campByItem[itemID]
    if not camp or not self.masterChefOwnsCookingSession
        or not self.masterChefCookingPrepared
        or self.masterChefCookingActive or self.masterChefCookingPending
        or self.masterChefCookingQuickPending or self.masterChefCookingContextPending then return false end
    if not CampSessionReady(camp.professionID or 356,
        camp.profession or "Fishing") then return false end
    self.masterChefOwnsCookingSession = nil
    self.masterChefCookingPrepared = nil
    local focused = self.masterChefTrayCampPreparedRecipeID == camp.recipeID
    self.masterChefTrayCampPreparedRecipeID = nil
    self.masterChefCampPanel = self.masterChefCookingPanel
    self.masterChefCookingPanel = nil
    self.masterChefOwnsCampSession = true
    self.masterChefCampPreparedRecipeID = focused and camp.recipeID or nil
    return true
end

function FF:UseMasterChefCampCookingPreparation()
    local camp = campByRecipe[self.masterChefCampPreparedRecipeID]
    if not self.masterChefOwnsCampSession or not camp or camp.professionID ~= 185
        or self.masterChefCampCrafting or self.masterChefCampPreparing
        or not CookingSessionReady() then return false end
    self.masterChefOwnsCampSession = nil
    self.masterChefCampPreparedRecipeID = nil
    self.masterChefCampPreparedToken = (self.masterChefCampPreparedToken or 0) + 1
    self.masterChefCampCraftQueued = nil
    self.masterChefCampCraftRemaining = nil
    self.masterChefCookingPanel = self.masterChefCampPanel
    self.masterChefCampPanel = nil
    self.masterChefOwnsCookingSession = true
    self.masterChefCookingPrepared = true
    self.masterChefTrayCampPreparedRecipeID = camp.recipeID
    WatchPrepared(self)
    return true
end

function FF:ConcealMasterChefCampPanel()
    if not self.masterChefOwnsCampSession then return false end
    local frame = _G.ProfessionsFrame
    if not (frame and frame.IsShown and frame:IsShown()) then frame = _G.TradeSkillFrame end
    if not (frame and frame.IsShown and frame:IsShown() and frame.GetNumPoints and UIParent) then return nil end
    if not self.masterChefCampPanel then
        local points = {}
        for index = 1, frame:GetNumPoints() do
            local anchor, relative, relativeAnchor, x, y = frame:GetPoint(index)
            points[index] = { anchor, relative, relativeAnchor, x, y }
        end
        self.masterChefCampPanel = { frame = frame, points = points }
    end
    local ok = pcall(function()
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", WorldFrame or UIParent, "BOTTOMLEFT", 0, -100)
    end)
    if ok and self.RefreshFishingLayer then self:RefreshFishingLayer() end
    return ok
end

function FF:ReleaseMasterChefCampSession(closed)
    ClearCraftRequest(self, "masterChefCampCraftRequest", true)
    local owned = self.masterChefOwnsCampSession
    self.masterChefOwnsCampSession = nil
    self.masterChefCampPreparing = nil
    self.masterChefCampPreparedRecipeID = nil
    self.masterChefCampPreparedToken = (self.masterChefCampPreparedToken or 0) + 1
    self.masterChefCampCraftQueued = nil
    self.masterChefCampCraftRemaining = nil
    if self.masterChefCampCrafting then
        self.masterChefCampCrafting = nil
        self.masterChefCampCraftToken = (self.masterChefCampCraftToken or 0) + 1
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-stopped")
    end
    local panel = self.masterChefCampPanel
    self.masterChefCampPanel = nil
    if InCombatLockdown and InCombatLockdown() then
        local pending = self.masterChefCampClosePending or {}
        pending.close = pending.close or (owned and not closed)
        pending.panel = pending.panel or panel
        self.masterChefCampClosePending = pending
        return
    end
    if owned and not closed and C_TradeSkillUI and C_TradeSkillUI.CloseTradeSkill then
        pcall(C_TradeSkillUI.CloseTradeSkill)
    end
    if panel then
        pcall(function()
            panel.frame:ClearAllPoints()
            for _, point in ipairs(panel.points) do
                panel.frame:SetPoint(point[1], point[2], point[3], point[4], point[5])
            end
        end)
    end
    if owned and self.RefreshFishingLayer then self:RefreshFishingLayer() end
end

function FF:ResumeMasterChefWindowClose()
    if InCombatLockdown and InCombatLockdown() then return end
    for _, field in ipairs({ "masterChefCookingClosePending", "masterChefCampClosePending" }) do
        local pending = self[field]
        self[field] = nil
        if pending then
            if pending.close and C_TradeSkillUI and C_TradeSkillUI.CloseTradeSkill then
                pcall(C_TradeSkillUI.CloseTradeSkill)
            end
            local panel = pending.panel
            if panel then
                pcall(function()
                    panel.frame:ClearAllPoints()
                    for _, point in ipairs(panel.points) do
                        panel.frame:SetPoint(point[1], point[2], point[3], point[4], point[5])
                    end
                end)
            end
        end
    end
end

-- Blizzard's panel manager can restore the anchors of a profession frame that
-- Master Chef has parked off-screen. Relinquish only sessions we opened when
-- another panel takes focus; never close a profession opened by the player.
function FF:SuspendMasterChefForExternalPanel(frame)
    if not frame or frame == _G.ProfessionsFrame or frame == _G.TradeSkillFrame
        or not (frame.IsShown and frame:IsShown()) then return end
    if not (self.masterChefOwnsCookingSession or self.masterChefOwnsCampSession) then return end
    self:SuspendMasterChefPreparation("panel")
end

function FF:SuspendMasterChefPreparation(reason)
    if not (self.masterChefOwnsCookingSession or self.masterChefOwnsCampSession) then return end
    if self.masterChefOwnsCookingSession then
        self.masterChefCookingActive = nil
        self.masterChefCookingRemaining = nil
        self.masterChefCraftToken = (self.masterChefCraftToken or 0) + 1
        self:ReleaseMasterChefCookingSession()
        self:SetMasterChefMessage("masterChefQueueMessage",reason == "combat" and "chef.message.cook-after-combat"
            or "chef.message.cooking-paused")
        if self.masterChefQuickMessage then self:CopyMasterChefMessage("masterChefQuickMessage","masterChefQueueMessage")
        else self:SetMasterChefMessage("masterChefQuickMessage",nil) end
    end
    if self.masterChefOwnsCampSession then
        self:ReleaseMasterChefCampSession()
        self:SetMasterChefMessage("masterChefCampMessage",reason == "combat" and "chef.message.craft-after-combat"
            or "chef.message.profession-paused")
    end
    self.masterChefTrayOwnsPreparation = nil
    self.masterChefTrayOwnsCampPreparation = nil
    if not (InCombatLockdown and InCombatLockdown()) then
        if self.RefreshJournal then self:RefreshJournal() end
        if self.RefreshMasterChefQuickTray then self:RefreshMasterChefQuickTray() end
    end
end

local function WatchCampCraft(chef, itemID)
    chef.masterChefCampCraftToken = (chef.masterChefCampCraftToken or 0) + 1
    local token = chef.masterChefCampCraftToken
    if C_Timer and C_Timer.After then
        C_Timer.After(16, function()
            if chef.masterChefCampCrafting == itemID and token == chef.masterChefCampCraftToken then
                ClearCraftRequest(chef, "masterChefCampCraftRequest", true)
                chef.masterChefCampCrafting = nil
                chef:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-stopped-continue")
                if chef.masterChefCampCraftQueued then
                    chef:SetMasterChefMessage("masterChefCampQueueMessage","chef.message.craft-stopped-start")
                end
                chef:KeepMasterChefCampSessionAfterStop(itemID)
                if chef.RefreshJournal then chef:RefreshJournal() end
            end
        end)
    end
end

local function WatchCampPrepared(chef, recipeID)
    chef.masterChefCampPreparedToken = (chef.masterChefCampPreparedToken or 0) + 1
    local token = chef.masterChefCampPreparedToken
    if C_Timer and C_Timer.After then
        C_Timer.After(30, function()
            if chef.masterChefOwnsCampSession and chef.masterChefCampPreparedRecipeID == recipeID
                and not chef.masterChefCampCrafting and token == chef.masterChefCampPreparedToken then
                local panel = chef.journalPanel
                local camp = campByRecipe[recipeID]
                if not camp or not CampSessionReady(camp.professionID or 356,
                    camp.profession or "Fishing") then
                    chef:ReleaseMasterChefCampSession(true)
                    chef:SetMasterChefMessage("masterChefCampMessage","chef.message.profession-changed")
                    if chef.RefreshJournal then chef:RefreshJournal() end
                elseif panel and panel:IsShown() and chef.journalTab == "chef"
                    and (panel.chefView == "campfire"
                        or camp.id == 279981 and panel.chefView == "meals")
                    or panel and panel:IsShown()
                        and (chef.masterChefCampCraftQueue or {})[1]
                    or chef.masterChefTray and chef.masterChefTray:IsShown()
                    or chef.masterChefCampPlacement and chef.masterChefCampPlacement.tray then
                    WatchCampPrepared(chef, recipeID)
                else
                    chef:ReleaseMasterChefCampSession()
                end
            end
        end)
    end
end

function FF:KeepMasterChefCampSessionAfterStop(itemID)
    local camp = campByItem[itemID]
    self.masterChefCampCraftQueued = nil
    self.masterChefCampCraftRemaining = nil
    if camp and self.masterChefOwnsCampSession
        and self.masterChefCampPreparedRecipeID == camp.recipeID
        and CampSessionReady(camp.professionID or 356, camp.profession or "Fishing") then
        WatchCampPrepared(self, camp.recipeID)
    else
        self:ReleaseMasterChefCampSession(true)
    end
end

function FF:ContinueMasterChefCampPreparation()
    local itemID = self.masterChefCampPreparing
    local camp = itemID and campByItem[itemID]
    if not camp then return end
    if InCombatLockdown and InCombatLockdown() then
        self:ReleaseMasterChefCampSession()
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.prepare-after-combat")
        return
    end
    local concealed = self:ConcealMasterChefCampPanel()
    if concealed == false then
        self:ReleaseMasterChefCampSession()
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.prepare-profession-failed",camp.profession or "Fishing")
        return
    end
    if not concealed or not CampSessionReady(camp.professionID or 356,
        camp.profession or "Fishing") then return end
    local api = C_TradeSkillUI
    self.masterChefCampPreparing = nil
    if api and api.OpenRecipe then
        local focused, result = pcall(api.OpenRecipe, camp.recipeID)
        if not focused or result == false then
            self:ReleaseMasterChefCampSession()
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.select-recipe-failed",camp.name)
            return
        end
    end
    self.masterChefCampPreparedRecipeID = camp.recipeID
    self:SetMasterChefMessage("masterChefCampMessage","chef.message.camp-ready",camp.name)
    if self.ShowMasterChefStatus then
        self:ShowMasterChefStatus("campfire", (camp.profession or "Fishing")
            .. " prepared", false, 2, nil, true)
    end
    if self.masterChefTrayPreparingCampID == itemID and self.SetMasterChefQuickStatus then
        self:SetLocalizedMasterChefQuickStatus("chef.message.prepared-click-craft",camp.profession or "Fishing")
        self.masterChefTrayPreparingCampID = nil
    end
    if self.masterChefOwnsCampSession then WatchCampPrepared(self, camp.recipeID) end
    if self.RefreshJournal then self:RefreshJournal() end
end

function FF:CraftMasterChefCamp(itemID, quantity, queued, prepareOnly)
    if self.MasterChefExternalPanelOpen and self:MasterChefExternalPanelOpen() then
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.close-window-craft")
        return false
    end
    local camp = campByItem[itemID]
    if not camp then return false end
    quantity = quantity or 1
    if type(quantity) ~= "number" or quantity < 1 or quantity % 1 ~= 0 then return false end
    self:ScanMasterChefCamps()
    local status = self:GetMasterChefCampStatus(itemID)
    if not (status and status.learned) then
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.recipe-unlearned")
        return false
    end
    if status.crafts < 1 then
        if camp.toolID and (status.toolCount or 0) < 1 then
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.need-tool",camp.toolName or "recipe tool")
        else self:SetMasterChefMessage("masterChefCampMessage","chef.message.need-materials") end
        return false
    end
    if queued then
        local first = (self.masterChefCampCraftQueue or {})[1]
        if not first or first.itemID ~= itemID then return false end
        quantity = math.min(quantity, first.quantity, status.crafts)
    elseif quantity > self:GetMasterChefCampAvailableCrafts(itemID) then
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.materials-reserved")
        return false
    end
    if not queued and not prepareOnly and self.masterChefCampPreparing == itemID then
        self:ContinueMasterChefCampPreparation()
    end
    if self.masterChefCampCrafting or self.masterChefCampPreparing then
        if not queued and not prepareOnly and self.masterChefCampPreparing == itemID then
            NotifyDirectPreparation(self, camp.profession or "Fishing", "craft", true)
        end
        self:SetMasterChefMessage("masterChefCampMessage",self.masterChefCampCrafting and "chef.message.craft-progress"
            or "chef.message.preparing-profession")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-after-combat")
        return false
    end
    if self.masterChefCookingActive or self.masterChefCookingPending
        or self.masterChefCookingQuickPending or self.masterChefCookingContextPending then
        self.masterChefCampMessage = "Finish the current preparation or craft first"
        return false
    end
    if self.masterChefOwnsCookingSession and not self.masterChefCookingActive
        and not self.masterChefCookingPending and not self.masterChefCookingQuickPending
        and not self.masterChefCookingContextPending then
        if not self:UseMasterChefTrayCampPreparation(itemID) then
            self:ReleaseMasterChefCookingSession()
        end
    end
    if self.masterChefOwnsCookingSession then
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.finish-cooking-queue")
        return false
    end
    local api = C_TradeSkillUI
    if not (api and api.CraftRecipe) then
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.profession-unavailable")
        return false
    end
    local professionID = camp.professionID or 356
    local professionName = camp.profession or "Fishing"
    if not CampSessionReady(professionID, professionName) then
        if self.masterChefOwnsCampSession and self.masterChefCampPreparedRecipeID then
            self:ReleaseMasterChefCampSession(true)
        end
        if not api.OpenTradeSkill then
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.open-profession",professionName)
            return false
        end
        self.masterChefOwnsCampSession = true
        self.masterChefCampPreparing = itemID
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.preparing-profession-name",professionName)
        if queued then self:SetMasterChefMessage("masterChefCampQueueMessage",nil) end
        local ok, result = pcall(api.OpenTradeSkill, professionID)
        if not ok or result == false then
            self:ReleaseMasterChefCampSession(true)
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.open-profession-failed",professionName)
            return false
        end
        self:ContinueMasterChefCampPreparation()
        if C_Timer and C_Timer.After then
            C_Timer.After(4, function()
                if self.masterChefCampPreparing == itemID then
                    self:ReleaseMasterChefCampSession()
                    self:SetMasterChefMessage("masterChefCampMessage","chef.message.profession-unloaded",professionName)
                    if self.RefreshJournal then self:RefreshJournal() end
                end
            end)
        end
        if not queued and not prepareOnly
            and (self.masterChefCampPreparing == itemID
                or self.masterChefCampPreparedRecipeID == camp.recipeID) then
            NotifyDirectPreparation(self, professionName, "craft",
                self.masterChefCampPreparedRecipeID ~= camp.recipeID)
        end
        return true
    end
    if api.OpenRecipe and self.masterChefCampPreparedRecipeID ~= camp.recipeID then
        local focused, result = pcall(api.OpenRecipe, camp.recipeID)
        if not focused or result == false then
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.select-recipe-failed",camp.name)
            return false
        end
        self.masterChefCampPreparedRecipeID = camp.recipeID
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.camp-ready",camp.name)
        if self.ShowMasterChefStatus then
            self:ShowMasterChefStatus("campfire", professionName .. " prepared", false, 2, nil, true)
        end
        if self.masterChefOwnsCampSession then WatchCampPrepared(self, camp.recipeID) end
        if not queued and not prepareOnly then
            NotifyDirectPreparation(self, professionName, "craft", false)
        end
        return true
    end
    if prepareOnly then return true end
    self.masterChefCampCrafting = itemID
    self.masterChefCampPreparedToken = (self.masterChefCampPreparedToken or 0) + 1
    self.masterChefCampCraftQueued = queued and true or nil
    self.masterChefCampCraftRemaining = quantity
    self:SetMasterChefMessage("masterChefCampMessage","chef.message.crafting-camp",camp.name)
    if queued then self:SetMasterChefMessage("masterChefCampQueueMessage",nil) end
    if not RequestRecipe(self, "masterChefCampCraftRequest", camp.recipeID, quantity) then return false end
    if self.masterChefCampCrafting == itemID then WatchCampCraft(self, itemID) end
    return true
end

function FF:StartMasterChefCampCraftQueue()
    local entry = (self.masterChefCampCraftQueue or {})[1]
    if not entry then return false end
    local started = self:CraftMasterChefCamp(entry.itemID, entry.quantity, true)
    if not started and not self.masterChefCampCrafting and not self.masterChefCampPreparing then
        self:CopyMasterChefMessage("masterChefCampQueueMessage","masterChefCampMessage","chef.message.check-materials")
    end
    return started
end

function FF:OnMasterChefCampCraftEvent(event, spellID, castGUID)
    if event ~= "UNIT_SPELLCAST_SUCCEEDED" and event ~= "UNIT_SPELLCAST_FAILED"
        and event ~= "UNIT_SPELLCAST_INTERRUPTED" then return end
    if type(spellID) ~= "number" or (issecretvalue and issecretvalue(spellID)) then return end
    if event ~= "UNIT_SPELLCAST_SUCCEEDED"
        and OtherCraftFailure(self.masterChefCampCraftRequest, castGUID) then return end
    local camp = campByRecipe[spellID]
    if not camp or self.masterChefCampCrafting ~= camp.id then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local finishedStack
        if self.masterChefCampCraftQueued then
            local entry = (self.masterChefCampCraftQueue or {})[1]
            if entry and entry.itemID == camp.id then
                entry.quantity = entry.quantity - 1
                if entry.quantity <= 0 then
                    table.remove(self.masterChefCampCraftQueue, 1)
                    finishedStack = true
                end
            end
        end
        self.masterChefCampCraftRemaining = math.max(0, (self.masterChefCampCraftRemaining or 1) - 1)
        if self.masterChefCampCraftRemaining > 0 then
            if self.masterChefCampCraftRequest then
                self.masterChefCampCraftRequest.started, self.masterChefCampCraftRequest.castGUID = false, nil
            end
            WatchCampCraft(self, camp.id)
            if self.RefreshJournal then self:RefreshJournal() end
            return
        end
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.camp-crafted",camp.name)
        if self.masterChefCampCraftQueued and #(self.masterChefCampCraftQueue or {}) > 0 then
            self:SetMasterChefMessage("masterChefCampQueueMessage","chef.message.next-camp")
            if finishedStack and self.PlayCookingCompleteAlert then
                self:PlayCookingCompleteAlert()
            end
        elseif self.masterChefCampCraftQueued then
            self:SetMasterChefMessage("masterChefCampQueueMessage",nil)
        end
    else
        self:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-stopped-continue")
        if self.masterChefCampCraftQueued then
            self:SetMasterChefMessage("masterChefCampQueueMessage","chef.message.craft-stopped-start")
        end
    end
    ClearCraftRequest(self, "masterChefCampCraftRequest", event ~= "UNIT_SPELLCAST_SUCCEEDED")
    self.masterChefCampCrafting = nil
    self.masterChefCampCraftToken = (self.masterChefCampCraftToken or 0) + 1
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if self.masterChefCampCraftQueued
            or not self:UseMasterChefCampCookingPreparation() then
            self:ReleaseMasterChefCampSession()
        end
    else
        self:KeepMasterChefCampSessionAfterStop(camp.id)
    end
    if self.RefreshJournal then self:RefreshJournal() end
end

function FF:OnMasterChefCampCraftStopped()
    local itemID = self.masterChefCampCrafting
    if not itemID then return end
    ClearCraftRequest(self, "masterChefCampCraftRequest", true)
    self.masterChefCampCrafting = nil
    self.masterChefCampCraftToken = (self.masterChefCampCraftToken or 0) + 1
    if self.masterChefCampCraftQueued then
        self:SetMasterChefMessage("masterChefCampQueueMessage","chef.message.craft-stopped-start")
    end
    self:KeepMasterChefCampSessionAfterStop(itemID)
    self:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-stopped-continue")
    if self.RefreshJournal then self:RefreshJournal() end
end

function FF:OnMasterChefCampSessionEvent(event)
    if not self.masterChefOwnsCampSession then return end
    if event == "TRADE_SKILL_CLOSE" then
        if self.masterChefCampCrafting then
            self.masterChefCampCrafting = nil
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-stopped")
        end
        self:ReleaseMasterChefCampSession(true)
    elseif self.masterChefCampPreparing then
        self:ContinueMasterChefCampPreparation()
    elseif event == "TRADE_SKILL_SHOW" and self.masterChefCampPreparedRecipeID
        and not self.masterChefCampCrafting then
        local camp = campByRecipe[self.masterChefCampPreparedRecipeID]
        if not camp or not CampSessionReady(camp.professionID or 356,
            camp.profession or "Fishing") then
            self:ReleaseMasterChefCampSession(true)
            self:SetMasterChefMessage("masterChefCampMessage","chef.message.profession-changed")
        end
    end
    if self.RefreshJournal then self:RefreshJournal() end
end

function FF:OnMasterChefCampPlacementEvent(event, spellID)
    if type(spellID) ~= "number" or (issecretvalue and issecretvalue(spellID)) then return end
    local pending = self.masterChefCampPlacement or self.masterChefCampPlaceAttempt
    if not pending then return end
    local camp = campByItem[pending.itemID]
    local itemSpellID
    if GetItemSpell then
        local ok, _, id = pcall(GetItemSpell, pending.itemID)
        if ok then itemSpellID = id end
    end
    if campByPlacement[spellID] ~= camp and spellID ~= itemSpellID then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then
        if event == "UNIT_SPELLCAST_FAILED" and pending.groundPlacement
            and pending.targeting then
            pending.result = nil
            pending.awaitEndEvent = true
        elseif not (event == "UNIT_SPELLCAST_SUCCEEDED" and pending.error) then
            pending.result = event == "UNIT_SPELLCAST_SUCCEEDED" and "success"
                or event == "UNIT_SPELLCAST_INTERRUPTED" and "cancelled" or "failed"
            if pending.result == "success" then pending.error = nil end
        end
        if pending.groundPlacement and pending.targeting
            and event == "UNIT_SPELLCAST_SUCCEEDED"
            and not (SpellIsTargeting and SpellIsTargeting()) then
            pending.result = "success"
            pending.error = nil
            pending.endConfirmed = true
            pending.awaitEndEvent = nil
        end
    end
    if self.masterChefCampPlacement and self.CheckMasterChefCampPlacement then
        self:CheckMasterChefCampPlacement()
    end
end

-- Route blocks use the journal's existing guide typography. The saved Journal
-- Faction setting selects the route and recipe source at render time.
FF.masterChefRoute = {
    { heading = "1–50  •  First catches", fish = "Brilliant Smallfish from Raw Brilliant Smallfish. Coastal option: Slitherskin Mackerel.",
      recipe = "Buy the recipe from a nearby fishing or cooking supplier.",
      alliance = "Fish in Elwynn Forest or Teldrassil. For mackerel, use the Teldrassil coast.",
      horde = "Fish in Durotar or Mulgore. For mackerel, use the Durotar coast." },
    { heading = "50–100  •  Mud Snapper", fish = "Longjaw Mud Snapper from Raw Longjaw Mud Snapper. Coastal option: Rainbow Fin Albacore.",
      recipe = "Buy the Mud Snapper recipe from a fishing supplier. Train Journeyman Cooking at skill 50, before the 75 cap.",
      alliance = "Fish Stormwind canals or Loch Modan.",
      horde = "Fish Orgrimmar or Thunder Bluff waters." },
    { heading = "100–175  •  Catfish", fish = "Bristle Whisker Catfish from Raw Bristle Whisker Catfish.",
      recipe = "Buy the recipe from a fishing supplier. At skill 125, buy the Expert Cookbook before you reach the 150 cap.",
      alliance = "Fish Redridge, Wetlands or Stormwind.",
      horde = "Fish The Barrens or Hillsbrad." },
    { heading = "175–225  •  Trout", fish = "Mithril Headed Trout from Raw Mithril Head Trout. Cook Rockscale Cod from coastal catches too.",
      recipe = "Kelsey Yance in Booty Bay sells both recipes.",
      alliance = "Fish inland in Dustwallow Marsh near Theramore; fish its coast for cod.",
      horde = "Fish Stranglethorn Vale inland waters; its coast also yields cod." },
    { heading = "225–250  •  Yellowtail", fish = "Spotted Yellowtail from Raw Spotted Yellowtail. Filet of Redgill also works if you have the fish.",
      recipe = "Gikkix at Steamwheedle Port sells Yellowtail; Kelsey Yance in Booty Bay sells Redgill. For Artisan Cooking, complete Dirge Quikcleave's Clamlette Surprise in Gadgetzan at level 35 and skill 225.",
      alliance = "Fish the Tanaris coast for yellowtail, or Feralas lakes for redgill.",
      horde = "Fish the Tanaris coast for yellowtail, or Feralas lakes for redgill." },
    { heading = "250–275  •  Nightfin", fish = "Nightfin Soup from Raw Nightfin Snapper and Refreshing Spring Water. By day, cook Poached Sunscale Salmon if you have an Iron Oven.",
      recipe = "Gikkix at Steamwheedle Port sells both recipes.",
      alliance = "Fish Moonglade or Felwood lakes. Nightfin is best at night; Sunscale is a daytime catch.",
      horde = "Fish Moonglade or Felwood lakes. Nightfin is best at night; Sunscale is a daytime catch." },
    { heading = "275–300  •  Finish", fish = "Keep cooking Nightfin Soup. With an Iron Oven, make Mightfish Steak with spices, Lobster Stew with Refreshing Spring Water, or Baked Salmon with Soothing Spices.",
      recipe = {
          Alliance = "Vivianna at Feathermoon Stronghold sells the three 275 recipes.",
          Horde = "Sheendra Tallgrass at Camp Mojache sells the three 275 recipes.",
      },
      alliance = "Fish Feralas inland water for salmon, or high level coasts for mightfish and lobster.",
      horde = "Fish Feralas inland water for salmon, or high level coasts for mightfish and lobster." },
}

-- Forever Cooking trainer/rank tables and photographed NPC references.
-- https://www.icy-veins.com/wow-forever/cooking-leveling-guide
-- https://www.wow-professions.com/forever/cooking-trainers
-- Named zones use the client UI-map resolver shared by recipe vendors.
local cookingTrainers = {
    { "Alegorn", "Craftsmen's Terrace, Darnassus", 1457, 49.8, 21.0, "Alliance" },
    { "Cook Ghilm", "Gol'Bolar Quarry, Dun Morogh", 1426, 68.4, 54.6, "Alliance" },
    { "Crystal Boughman", "Lakeshire, Redridge Mountains", 1433, 22.8, 43.6, "Alliance" },
    { "Daryl Riknussun", "The Great Forge, Ironforge", 1455, 60.4, 38.0, "Alliance" },
    { "Gremlock Pilsnor", "Kharanos, Dun Morogh", 1426, 47.6, 52.4, "Alliance" },
    { "Hnaz Blunderflame", "Elderwild, Mount Hyjal", "Mount Hyjal", 15.6, 50.2, "Alliance" },
    { "Katherine Lee", "Dalaran, Alterac Mountains", 1416, 12.6, 65.8, "Alliance" },
    { "Stephen Ryback", "Old Town, Stormwind City", 1453, 78.2, 53.0, "Alliance" },
    { "Tomas", "Goldshire, Elwynn Forest", 1429, 44.2, 66.0, "Alliance" },
    { "Zarrin", "Dolanaar, Teldrassil", 1438, 57.0, 61.2, "Alliance" },
    { "Aska Mistrunner", "Central Rise, Thunder Bluff", 1456, 51.0, 52.8, "Horde" },
    { "Cook Torka", "Razor Hill, Durotar", 1411, 51.2, 42.6, "Horde" },
    { "Duhng", "The Barrens", 1413, 55.2, 31.8, "Horde" },
    { "Eunice Burch", "Trade Quarter, Undercity", 1458, 62.6, 44.6, "Horde" },
    { "Gorg", "Rog'mar, Riverglades", "Riverglades", 58.6, 44.6, "Horde" },
    { "Mudduk", "Grom'gol Base Camp, Stranglethorn Vale", 1434, 31.4, 28.0, "Horde" },
    { "Ortak Lomgok", "Elderwild, Mount Hyjal", "Mount Hyjal", 13.2, 52.8, "Horde" },
    { "Pyall Silentstride", "Bloodhoof Village, Mulgore", 1412, 45.0, 61.6, "Horde" },
    { "William Pickman", "Brill, Tirisfal Glades", 1420, 61.8, 51.6, "Horde" },
    { "Zamja", "The Drag, Orgrimmar", 1454, 57.6, 53.6, "Horde" },
    { "Nyalah Brightfire", "Valanaar, Zephras Isle", "Zephras Isle", 60.6, 72.6, "Neutral" },
    { "Zerril Softbreeze", "Shen'dar Village, Zephras Isle", "Zephras Isle", 43.8, 43.8, "Neutral" },
}

local cookingRouteSources = {
    ["1–50  •  First catches"] = { "Chef:Recipe:6290", "Chef:Recipe:787", "Chef:Training:Apprentice" },
    ["50–100  •  Mud Snapper"] = { "Chef:Recipe:4592", "Chef:Recipe:5095", "Chef:Training:Journeyman" },
    ["100–175  •  Catfish"] = { "Chef:Recipe:4593", "Chef:Training:Expert" },
    ["175–225  •  Trout"] = { "Chef:Recipe:8364", "Chef:Recipe:4594" },
    ["225–250  •  Yellowtail"] = { "Chef:Recipe:6887", "Chef:Recipe:13930", "Chef:Training:Artisan" },
    ["250–275  •  Nightfin"] = { "Chef:Recipe:13931,13932" },
    ["275–300  •  Finish"] = { "Chef:Recipe:13934,13933,13935" },
}

function FF:GetCookingRouteSourceLabel(key, skills, compact)
    local rank = key:match("^Chef:Training:(%a+)$")
    if rank then
        local specs = {
            Apprentice = { "chef.route.apprentice" },
            Journeyman = { "chef.route.journeyman", {
                textKey="skill.display.value", values={50}, profession="Cooking", required=50,
            } },
            Expert = { "chef.route.expert", {
                textKey="skill.display.value", values={125}, profession="Cooking", required=125,
            }, "Expert Cookbook" },
            Artisan = { "chef.route.artisan", {
                textKey="skill.display.value", values={225}, profession="Cooking", required=225,
            }, "Clamlette Surprise" },
        }
        local spec = specs[rank]
        if spec and compact then spec[1] = "chef.route.compact." .. string.lower(rank) end
        return spec and self:FormatLocalizedReference(spec, skills)
    end
    local names = {}
    for id in key:gmatch("%d+") do
        local meal = mealByOutput[tonumber(id)]
        if meal then
            local name=self:GetJournalItemDisplayName(meal.id,meal.name)
            names[#names+1]=compact=="instruction" and self:GuideTargetLink({kind="meal",id=meal.id,label=meal.name},name) or name
        end
    end
    if compact == "instruction" then return table.concat(names, ", ") end
    local labelKey = #names == 1 and "chef.route.recipe" or "chef.route.recipes"
    if compact then labelKey = labelKey .. "-compact" end
    return self:LocalizedText(labelKey, table.concat(names, ", "))
end

function FF:GetCookingRouteSources(key, faction)
    faction = faction or self:GetJournalFaction()
    local rank = key:match("^Chef:Training:(%a+)$")
    local records
    if rank == "Apprentice" or rank == "Journeyman" then
        records = cookingTrainers
    elseif rank == "Expert" then
        records = {
            { "Shandrina", "Silverwind Refuge, Ashenvale", 1440, 49.6, 67.0, "Alliance" },
            { "Wulan", "Shadowprey Village, Desolace", 1443, 26.2, 69.8, "Horde" },
        }
    elseif rank == "Artisan" then
        records = {{ "Dirge Quikcleave", "Gadgetzan, Tanaris", 1446, 52.6, 28.0, "Neutral" }}
    end
    local points = {}
    if records then
        for _, record in ipairs(records) do
            if record[6] == faction or record[6] == "Neutral" then
                points[#points+1] = {
                    name=record[1], location=record[2], label=record[1] .. ", " .. record[2],
                    mapID=self:GetGuideMapID(record[3]), x=record[4]/100, y=record[5]/100,
                    sourceKind=rank == "Expert" and "Book seller" or rank == "Artisan" and "Quest giver" or "Cooking trainer",
                }
            end
        end
    elseif key:sub(1,12) == "Chef:Recipe:" then
        -- A combined recipe row lists only vendors verified to sell every recipe.
        for id in key:gmatch("%d+") do
            local sellers = self:GetMealRecipeMapPoints(tonumber(id), faction) or {}
            if #points == 0 then
                points = sellers
            else
                local shared = {}
                for _, point in ipairs(points) do
                    for _, seller in ipairs(sellers) do
                        if point.name == seller.name and point.mapID == seller.mapID then
                            shared[#shared+1] = point
                            break
                        end
                    end
                end
                points = shared
            end
            if #points == 0 then break end
        end
    end
    for _, point in ipairs(points) do
        point.sourceKind = point.sourceKind or "Recipe seller"
        point.cookingSource = key
    end
    return self:GetOrderedGuideMapPoints(points, true)
end

function FF:GetMasterChefRouteSourceRows(stage, faction, skills)
    local rows = {}
    local function Add(key)
        rows[#rows+1] = { key=key, label=self:GetCookingRouteSourceLabel(key, skills),
            requirement=self:GetCookingRouteSourceLabel(key, skills, true),
            instruction=self:GetCookingRouteSourceLabel(key, skills, "instruction"),
            points=self:GetCookingRouteSources(key, faction) }
    end
    for _, key in ipairs(cookingRouteSources[stage.heading] or {}) do
        if key:sub(1,12) == "Chef:Recipe:" then
            for id in key:gmatch("%d+") do Add("Chef:Recipe:" .. id) end
        else
            Add(key)
        end
    end
    return rows
end

-- Display projections only: original IDs, recipes, names, guide headings,
-- faction fields and source facts remain canonical for actions/search/Back.
local chefReferenceText = {
    ["camp"] = {
        ["279981"] = {
            ["benefit"] = { "chef.reference.camp.279981.benefit" },
            ["source"] = { "chef.reference.camp.279981.source", "Simple Wood", "Flint and Tinder" }
        },
        ["279967"] = {
            ["benefit"] = { "chef.reference.camp.279967.benefit", "Blessing of Kings" },
            ["source"] = { "chef.reference.camp.279967.source", "Camping 101: Fishing" }
        },
        ["279965"] = {
            ["benefit"] = { "chef.reference.camp.279965.benefit", "Fish Bowl" },
            ["source"] = { "chef.reference.camp.blueprint-drop", "Blueprint: Fishing Rack", "Gelihast", "Blackfathom Deeps" }
        },
        ["279966"] = {
            ["benefit"] = { "chef.reference.camp.279966.benefit", "Fish Bowl" },
            ["source"] = { "chef.reference.camp.blueprint-drop", "Blueprint: Fishing Hut", "Jammal'an the Prophet", "Sunken Temple" }
        },
        ["279956"] = {
            ["benefit"] = { "chef.reference.camp.279956.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279970"] = {
            ["benefit"] = { "chef.reference.camp.279970.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279990"] = {
            ["benefit"] = { "chef.reference.camp.279990.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279944"] = {
            ["benefit"] = { "chef.reference.camp.279944.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279988"] = {
            ["benefit"] = { "chef.reference.camp.279988.benefit", "Sharpening Wheel" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279955"] = {
            ["benefit"] = { "chef.reference.camp.279955.benefit", "Sharpening Wheel" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279976"] = {
            ["benefit"] = { "chef.reference.camp.279976.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279985"] = {
            ["benefit"] = { "chef.reference.camp.279985.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279987"] = {
            ["benefit"] = { "chef.reference.camp.279987.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279950"] = {
            ["benefit"] = { "chef.reference.camp.279950.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279949"] = {
            ["benefit"] = { "chef.reference.camp.279949.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279989"] = {
            ["benefit"] = { "chef.reference.camp.279989.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279962"] = {
            ["benefit"] = { "chef.reference.camp.279962.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279964"] = {
            ["benefit"] = { "chef.reference.camp.279964.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279947"] = {
            ["benefit"] = { "chef.reference.camp.279947.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279978"] = {
            ["benefit"] = { "chef.reference.camp.279978.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279941"] = {
            ["benefit"] = { "chef.reference.camp.279941.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279945"] = {
            ["benefit"] = { "chef.reference.camp.279945.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279960"] = {
            ["benefit"] = { "chef.reference.camp.279960.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279948"] = {
            ["benefit"] = { "chef.reference.camp.279948.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279952"] = {
            ["benefit"] = { "chef.reference.camp.279952.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279979"] = {
            ["benefit"] = { "chef.reference.camp.279979.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279969"] = {
            ["benefit"] = { "chef.reference.camp.279969.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279938"] = {
            ["benefit"] = { "chef.reference.camp.279938.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279972"] = {
            ["benefit"] = { "chef.reference.camp.279972.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279973"] = {
            ["benefit"] = { "chef.reference.camp.279973.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279943"] = {
            ["benefit"] = { "chef.reference.camp.279943.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279959"] = {
            ["benefit"] = { "chef.reference.camp.279959.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279961"] = {
            ["benefit"] = { "chef.reference.camp.279961.benefit" },
            ["source"] = { "chef.reference.camp.blueprint-drop", "Blueprint: Journeyman Campfire", "Lord Serpentis", "Wailing Caverns" }
        },
        ["279957"] = {
            ["benefit"] = { "chef.reference.camp.279957.benefit" },
            ["source"] = { "chef.reference.camp.blueprint-drop", "Blueprint: Cookie's Feast", "Cookie", "The Deadmines" }
        },
        ["279974"] = {
            ["benefit"] = { "chef.reference.camp.279974.benefit" },
            ["source"] = { "chef.reference.camp.blueprint-drop", "Blueprint: Expert Campfire", "Slavecrusher Grox", "Krol'dok Stronghold" }
        },
        ["279982"] = {
            ["benefit"] = { "chef.reference.camp.279982.benefit" },
            ["source"] = { "chef.reference.camp.blueprint-drop", "Blueprint: Iron Oven", "Quartermaster Zigris", "Lower Blackrock Spire" }
        },
        ["279968"] = {
            ["benefit"] = { "chef.reference.camp.279968.benefit" },
            ["source"] = { "chef.reference.camp.279956.source" }
        },
        ["279940"] = {
            ["benefit"] = { "chef.reference.camp.279940.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        },
        ["279951"] = {
            ["benefit"] = { "chef.reference.camp.279951.benefit" },
            ["source"] = { "chef.reference.camp.279970.source" }
        }
    },
    ["meal"] = {
        ["274971"] = {
            ["extra"] = { "chef.reference.meal.13931.extra" },
            ["recipe"] = { "chef.reference.meal.274971.recipe", "Recipe: Briny Seafood Stew", "A Taste of the Sea", "Fimbo Greasemitz", "Riverglades" },
            ["waters"] = { "chef.reference.meal.274971.waters", "Murloc Eyes", "Tender Crab Meat", "Hot Spices" }
        },
        ["8957"] = {
            ["recipe"] = { "chef.reference.meal.recipe-unconfirmed" },
            ["waters"] = { "chef.reference.meal.8957.waters", "Raw Spinefin Halibut" }
        },
        ["5476"] = {
            ["extra"] = { "chef.reference.meal.5476.extra" },
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.5476.Alliance.recipe", "Laird", "Auberdine", "Darkshore" },
                ["Horde"] = { "chef.reference.meal.5476.Horde.recipe" }
            },
            ["waters"] = { "chef.reference.meal.5476.waters", "Soft Frenzy Flesh", "Frenzy" }
        },
        ["286152"] = {
            ["extra"] = { "chef.reference.meal.286152.extra" },
            ["recipe"] = { "chef.reference.meal.recipe-item-unconfirmed", "Recipe: Plated Armorfish" },
            ["waters"] = { "chef.reference.meal.286152.waters", "Eastern Plaguelands", "Deadwind Pass" }
        },
        ["13928"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = { "chef.reference.meal.6887.recipe", "Gikkix", "Steamwheedle Port", "Tanaris" },
            ["waters"] = { "chef.reference.meal.13928.waters", "Tanaris" }
        },
        ["13929"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = { "chef.reference.meal.13927.recipe", "Kelsey Yance", "Booty Bay" },
            ["waters"] = { "chef.reference.meal.13929.waters", "Tanaris" }
        },
        ["13932"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = { "chef.reference.meal.6887.recipe", "Gikkix", "Steamwheedle Port", "Tanaris" },
            ["waters"] = { "chef.reference.meal.13932.waters", "Moonglade", "Felwood" }
        },
        ["13935"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.13935.Alliance.recipe", "Vivianna", "Feathermoon Stronghold" },
                ["Horde"] = { "chef.reference.meal.13935.Horde.recipe", "Sheendra Tallgrass", "Camp Mojache" }
            },
            ["waters"] = { "chef.reference.meal.13935.waters", "Feralas", "Winterspring" }
        },
        ["250081"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = { "chef.reference.meal.recipe-item-unconfirmed", "Recipe: Clam Linguine" },
            ["waters"] = { "chef.reference.meal.16766.waters", "Big-mouth Clams" }
        },
        ["13933"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.13935.Alliance.recipe", "Vivianna", "Feathermoon Stronghold" },
                ["Horde"] = { "chef.reference.meal.13935.Horde.recipe", "Sheendra Tallgrass", "Camp Mojache" }
            },
            ["waters"] = { "chef.reference.meal.13933.waters" }
        },
        ["13934"] = {
            ["extra"] = { "chef.reference.meal.13928.extra", "Iron Oven" },
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.13935.Alliance.recipe", "Vivianna", "Feathermoon Stronghold" },
                ["Horde"] = { "chef.reference.meal.13935.Horde.recipe", "Sheendra Tallgrass", "Camp Mojache" }
            },
            ["waters"] = { "chef.reference.meal.13933.waters" }
        },
        ["6290"] = {
            ["recipe"] = { "chef.reference.meal.6290.recipe" },
            ["waters"] = { "chef.reference.meal.6290.waters" }
        },
        ["787"] = {
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.787.Alliance.recipe", "Nessa Shadowsong", "Rut'theran Village" },
                ["Horde"] = { "chef.reference.meal.787.Horde.recipe", "Zansoa", "Sen'jin Village" }
            },
            ["waters"] = { "chef.reference.meal.787.waters" }
        },
        ["6316"] = {
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.6316.Alliance.recipe", "Khara Deepwater", "Loch Modan" },
                ["Horde"] = { "chef.reference.meal.5476.Horde.recipe" }
            },
            ["waters"] = { "chef.reference.meal.6316.waters", "Loch Modan" }
        },
        ["4592"] = {
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.4592.Alliance.recipe", "Khara Deepwater", "Loch Modan" },
                ["Horde"] = { "chef.reference.meal.4592.Horde.recipe", "Thunder Bluff" }
            },
            ["waters"] = {
                ["Alliance"] = { "chef.reference.meal.4592.Alliance.waters", "Stormwind", "Loch Modan" },
                ["Horde"] = { "chef.reference.meal.4592.Horde.waters", "Orgrimmar", "Thunder Bluff" }
            }
        },
        ["5095"] = {
            ["recipe"] = { "chef.reference.meal.5095.recipe" },
            ["waters"] = { "chef.reference.meal.5095.waters", "Westfall", "Darkshore" }
        },
        ["21072"] = {
            ["recipe"] = { "chef.reference.meal.21072.recipe", "Kelsey Yance", "Booty Bay" },
            ["waters"] = { "chef.reference.meal.21072.waters", "Sagefish", "Ashenvale", "Wetlands" }
        },
        ["6657"] = {
            ["recipe"] = { "chef.reference.meal.6657.recipe", "The Barrens" },
            ["waters"] = { "chef.reference.meal.6657.waters", "The Barrens", "Wailing Caverns" }
        },
        ["251525"] = {
            ["recipe"] = { "chef.reference.meal.251525.recipe", "Great Goretusk", "Redridge Mountains" },
            ["waters"] = { "chef.reference.meal.251525.waters", "Whimsyfin", "Redridge Mountains" }
        },
        ["5526"] = {
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.5526.Alliance.recipe", "Heldan Galesong", "Darkshore", "Kriggon Talsone", "Westfall" },
                ["Horde"] = { "chef.reference.meal.5526.Horde.recipe" }
            },
            ["waters"] = { "chef.reference.meal.5526.waters" }
        },
        ["4593"] = {
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.4593.Alliance.recipe", "Stormwind" },
                ["Horde"] = { "chef.reference.meal.4593.Horde.recipe", "Thunder Bluff" }
            },
            ["waters"] = {
                ["Alliance"] = { "chef.reference.meal.4593.Alliance.waters", "Redridge", "Wetlands" },
                ["Horde"] = { "chef.reference.meal.4593.Horde.waters", "The Barrens", "Hillsbrad" }
            }
        },
        ["5527"] = {
            ["recipe"] = { "chef.reference.meal.5527.recipe" },
            ["waters"] = { "chef.reference.meal.5527.waters" }
        },
        ["6038"] = {
            ["recipe"] = { "chef.reference.meal.6038.recipe", "Booty Bay", "Stranglethorn Vale" },
            ["waters"] = { "chef.reference.meal.6038.waters", "Giant Clams" }
        },
        ["8364"] = {
            ["recipe"] = { "chef.reference.meal.8364.recipe", "Kelsey Yance", "Booty Bay" },
            ["waters"] = { "chef.reference.meal.8364.waters", "Dustwallow Marsh", "Stranglethorn" }
        },
        ["4594"] = {
            ["recipe"] = { "chef.reference.meal.8364.recipe", "Kelsey Yance", "Booty Bay" },
            ["waters"] = { "chef.reference.meal.4594.waters", "Stranglethorn", "Dustwallow" }
        },
        ["21217"] = {
            ["recipe"] = {
                ["Alliance"] = { "chef.reference.meal.21217.Alliance.recipe", "Kelsey Yance", "Booty Bay", "Erika Tate", "Stormwind" },
                ["Horde"] = { "chef.reference.meal.21217.Horde.recipe", "Kelsey Yance", "Booty Bay", "Derek Nightfall", "Tarren Mill" }
            },
            ["waters"] = { "chef.reference.meal.21217.waters", "Greater Sagefish", "Alterac", "Stranglethorn" }
        },
        ["13927"] = {
            ["recipe"] = { "chef.reference.meal.13927.recipe", "Kelsey Yance", "Booty Bay" },
            ["waters"] = { "chef.reference.meal.13927.waters", "Tanaris", "Feralas" }
        },
        ["13930"] = {
            ["recipe"] = { "chef.reference.meal.13927.recipe", "Kelsey Yance", "Booty Bay" },
            ["waters"] = { "chef.reference.meal.13930.waters", "Felwood", "Feralas" }
        },
        ["6887"] = {
            ["recipe"] = { "chef.reference.meal.6887.recipe", "Gikkix", "Steamwheedle Port", "Tanaris" },
            ["waters"] = { "chef.reference.meal.13927.waters", "Tanaris", "Feralas" }
        },
        ["16766"] = {
            ["recipe"] = { "chef.reference.meal.16766.recipe", "Jabbey", "Steamwheedle Port", "Tanaris" },
            ["waters"] = { "chef.reference.meal.16766.waters", "Big-mouth Clams" }
        },
        ["13931"] = {
            ["extra"] = { "chef.reference.meal.13931.extra" },
            ["recipe"] = { "chef.reference.meal.6887.recipe", "Gikkix", "Steamwheedle Port", "Tanaris" },
            ["waters"] = { "chef.reference.meal.13931.waters", "Moonglade", "Felwood" }
        },
        ["238642"] = {
            ["recipe"] = { "chef.reference.meal.recipe-unconfirmed" },
            ["waters"] = { "chef.reference.meal.238642.waters", "Darkclaw Lobster" }
        },
        ["238641"] = {
            ["recipe"] = { "chef.reference.meal.recipe-unconfirmed" },
            ["waters"] = { "chef.reference.meal.238641.waters", "Tanaris", "Stranglethorn" }
        }
    },
    ["route"] = {
        ["1–50  •  First catches"] = {
            ["heading"] = { "skill.chef.reference.route.1.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 1, 50 },
                    ["profession"] = "Cooking",
                    ["required"] = 1,
                    ["goodAt"] = 50,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.1.fish", "Brilliant Smallfish", "Raw Brilliant Smallfish", "Slitherskin Mackerel" },
            ["recipe"] = { "chef.reference.route.1.recipe" },
            ["alliance"] = { "chef.reference.route.1.alliance", "Elwynn Forest", "Teldrassil", "Teldrassil" },
            ["horde"] = { "chef.reference.route.1.horde", "Durotar", "Mulgore", "Durotar" }
        },
        ["50–100  •  Mud Snapper"] = {
            ["heading"] = { "skill.chef.reference.route.2.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 50, 100 },
                    ["profession"] = "Cooking",
                    ["required"] = 50,
                    ["goodAt"] = 100,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.2.fish", "Longjaw Mud Snapper", "Raw Longjaw Mud Snapper", "Rainbow Fin Albacore" },
            ["recipe"] = { "skill.chef.reference.route.2.recipe", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 50 },
                    ["profession"] = "Cooking",
                    ["required"] = 50,
                    ["fieldGuide"] = false,
                    ["fixedUpperBound"] = false
                } },
            ["alliance"] = { "chef.reference.route.2.alliance", "Stormwind", "Loch Modan" },
            ["horde"] = { "chef.reference.route.2.horde", "Orgrimmar", "Thunder Bluff" }
        },
        ["100–175  •  Catfish"] = {
            ["heading"] = { "skill.chef.reference.route.3.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 100, 175 },
                    ["profession"] = "Cooking",
                    ["required"] = 100,
                    ["goodAt"] = 175,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.3.fish", "Bristle Whisker Catfish", "Raw Bristle Whisker Catfish" },
            ["recipe"] = { "skill.chef.reference.route.3.recipe", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 125 },
                    ["profession"] = "Cooking",
                    ["required"] = 125,
                    ["fieldGuide"] = false,
                    ["fixedUpperBound"] = false
                }, "Expert Cookbook" },
            ["alliance"] = { "chef.reference.route.3.alliance", "Redridge", "Wetlands", "Stormwind" },
            ["horde"] = { "chef.reference.route.3.horde", "The Barrens", "Hillsbrad" }
        },
        ["175–225  •  Trout"] = {
            ["heading"] = { "skill.chef.reference.route.4.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 175, 225 },
                    ["profession"] = "Cooking",
                    ["required"] = 175,
                    ["goodAt"] = 225,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.4.fish", "Mithril Headed Trout", "Raw Mithril Head Trout", "Rockscale Cod" },
            ["recipe"] = { "chef.reference.route.4.recipe", "Kelsey Yance", "Booty Bay" },
            ["alliance"] = { "chef.reference.route.4.alliance", "Dustwallow Marsh", "Theramore" },
            ["horde"] = { "chef.reference.route.4.horde", "Stranglethorn Vale" }
        },
        ["225–250  •  Yellowtail"] = {
            ["heading"] = { "skill.chef.reference.route.5.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 225, 250 },
                    ["profession"] = "Cooking",
                    ["required"] = 225,
                    ["goodAt"] = 250,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.5.fish", "Spotted Yellowtail", "Raw Spotted Yellowtail", "Filet of Redgill" },
            ["recipe"] = { "skill.chef.reference.route.5.recipe", "Gikkix", "Steamwheedle Port", "Kelsey Yance", "Booty Bay", "Dirge Quikcleave", "Clamlette Surprise", "Gadgetzan", {
                    ["textKey"] = "skill.display.value",
                    ["values"] = { 225 },
                    ["profession"] = "Cooking",
                    ["required"] = 225,
                    ["fieldGuide"] = false,
                    ["fixedUpperBound"] = false
                } },
            ["alliance"] = { "chef.reference.route.5.alliance", "Tanaris", "Feralas" },
            ["horde"] = { "chef.reference.route.5.horde", "Tanaris", "Feralas" }
        },
        ["250–275  •  Nightfin"] = {
            ["heading"] = { "skill.chef.reference.route.6.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 250, 275 },
                    ["profession"] = "Cooking",
                    ["required"] = 250,
                    ["goodAt"] = 275,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.6.fish", "Nightfin Soup", "Raw Nightfin Snapper", "Refreshing Spring Water", "Poached Sunscale Salmon", "Iron Oven" },
            ["recipe"] = { "chef.reference.route.6.recipe", "Gikkix", "Steamwheedle Port" },
            ["alliance"] = { "chef.reference.route.6.alliance", "Moonglade", "Felwood" },
            ["horde"] = { "chef.reference.route.6.horde", "Moonglade", "Felwood" }
        },
        ["275–300  •  Finish"] = {
            ["heading"] = { "skill.chef.reference.route.7.heading", {
                    ["textKey"] = "skill.display.range",
                    ["values"] = { 275, 300 },
                    ["profession"] = "Cooking",
                    ["required"] = 275,
                    ["goodAt"] = 300,
                    ["fixedUpperBound"] = false,
                    ["fieldGuide"] = false
                } },
            ["fish"] = { "chef.reference.route.7.fish", "Nightfin Soup", "Iron Oven", "Mightfish Steak", "Lobster Stew", "Refreshing Spring Water", "Baked Salmon", "Soothing Spices" },
            ["recipe"] = {
                ["Alliance"] = { "skill.chef.reference.route.7.Alliance.recipe", "Vivianna", "Feathermoon Stronghold", {
                        ["textKey"] = "skill.display.value",
                        ["values"] = { 275 },
                        ["profession"] = "Cooking",
                        ["required"] = 275,
                        ["fieldGuide"] = false,
                        ["fixedUpperBound"] = false
                    } },
                ["Horde"] = { "skill.chef.reference.route.7.Horde.recipe", "Sheendra Tallgrass", "Camp Mojache", {
                        ["textKey"] = "skill.display.value",
                        ["values"] = { 275 },
                        ["profession"] = "Cooking",
                        ["required"] = 275,
                        ["fieldGuide"] = false,
                        ["fixedUpperBound"] = false
                    } }
            },
            ["alliance"] = { "chef.reference.route.7.alliance", "Feralas" },
            ["horde"] = { "chef.reference.route.7.horde", "Feralas" }
        }
    }
}

function FF:GetMasterChefReferenceText(kind, entry, field, faction, skills)
    if not entry then return nil end
    local id = kind == "route" and entry.heading or tostring(entry.id)
    local owner = chefReferenceText[kind] and chefReferenceText[kind][id]
    local spec = owner and owner[field]
    if spec and (spec.Alliance or spec.Horde) then spec = spec[faction] end
    if spec then
        -- Format even a zero-argument sentence (literal percent escapes).
        return self:FormatLocalizedReference(spec, skills)
    end
    local value = entry[field]
    if type(value)=="table" then return value[faction] end
    return value
end
