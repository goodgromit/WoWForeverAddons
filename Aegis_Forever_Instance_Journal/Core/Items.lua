local _, ns = ...

--[[
	What the journal needs to know about an item, and who can use it.

	The client answers type, slot and icon at once (GetItemInfoInstant); the name, link and
	quality may need a round trip to the server, so the loot page asks for them and redraws
	when GET_ITEM_INFO_RECEIVED says they have arrived. The data files' own name and quality
	stand in until then.

	Retail's class filter reads the encounter journal's loot data, which Forever does not
	ship, so usability here follows the Classic proficiency rules instead.
]]

local Items = {}
ns.Items = Items

-- Enum.ItemClass
local CONSUMABLE, CONTAINER, WEAPON, ARMOR, TRADE_GOODS, RECIPE, QUEST, MISCELLANEOUS, BATTLE_PET = 0, 1, 2, 4, 7, 9, 12, 15, 17
-- Enum.ItemMiscellaneousSubclass
local MISC_PET, MISC_MOUNT = 2, 5

-- Enum.ItemArmorSubclass
local ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE = 1, 2, 3, 4
local ARMOR_SHIELD, ARMOR_LIBRAM, ARMOR_IDOL, ARMOR_TOTEM = 6, 7, 8, 9

-- Enum.ItemWeaponSubclass
local AXE1H, AXE2H, BOW, GUN, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H = 0, 1, 2, 3, 4, 5, 6, 7, 8
local STAFF, FIST, DAGGER, THROWN, CROSSBOW, WAND, FISHING = 10, 13, 15, 16, 18, 19, 20

local function Set(...)
	local set = {}
	for index = 1, select("#", ...) do set[select(index, ...)] = true end
	return set
end

--[[
	The armor each class can wear by level 60, and its weapons, as in Classic: what its trainer, a weapon master or a
	talent (the shaman's two-handed axes and maces) can teach it. No druid polearms (a later expansion's), no wand
	but for the priest, mage and warlock, no shield but for the warrior, paladin and shaman. Only these armor and
	weapon types ask for a skill (ARMOR_SKILLS, WEAPON_SKILLS); the rest (jewelry, trinkets, held off-hands,
	cosmetic pieces, fishing poles and the like) any class can use. An off-hand weapon is for a class that can
	learn to wield two (DUAL_WIELD): in Classic the warrior, rogue and hunter.
]]
local CLASS_ARMOR = {
	WARRIOR = Set(ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE, ARMOR_SHIELD),
	PALADIN = Set(ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE, ARMOR_SHIELD, ARMOR_LIBRAM),
	HUNTER = Set(ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL),
	SHAMAN = Set(ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_SHIELD, ARMOR_TOTEM),
	ROGUE = Set(ARMOR_CLOTH, ARMOR_LEATHER),
	DRUID = Set(ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_IDOL),
	PRIEST = Set(ARMOR_CLOTH),
	MAGE = Set(ARMOR_CLOTH),
	WARLOCK = Set(ARMOR_CLOTH),
}

local CLASS_WEAPONS = {
	WARRIOR = Set(AXE1H, AXE2H, BOW, GUN, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H, STAFF, FIST, DAGGER, THROWN, CROSSBOW),
	PALADIN = Set(AXE1H, AXE2H, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H),
	HUNTER = Set(AXE1H, AXE2H, BOW, GUN, POLEARM, SWORD1H, SWORD2H, STAFF, FIST, DAGGER, THROWN, CROSSBOW),
	SHAMAN = Set(AXE1H, AXE2H, MACE1H, MACE2H, STAFF, FIST, DAGGER),
	ROGUE = Set(BOW, GUN, MACE1H, SWORD1H, FIST, DAGGER, THROWN, CROSSBOW),
	DRUID = Set(MACE1H, MACE2H, STAFF, FIST, DAGGER),
	PRIEST = Set(MACE1H, STAFF, DAGGER, WAND),
	MAGE = Set(SWORD1H, STAFF, DAGGER, WAND),
	WARLOCK = Set(SWORD1H, STAFF, DAGGER, WAND),
}
local ARMOR_SKILLS = Set(ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE, ARMOR_SHIELD, ARMOR_LIBRAM, ARMOR_IDOL, ARMOR_TOTEM)
local WEAPON_SKILLS = Set(AXE1H, AXE2H, BOW, GUN, MACE1H, MACE2H, POLEARM, SWORD1H, SWORD2H, STAFF, FIST, DAGGER, THROWN,
	CROSSBOW, WAND)
local DUAL_WIELD = Set("WARRIOR", "ROGUE", "HUNTER")

-- Retail's slot filter groups, by inventory type.
local SLOT_BY_EQUIP_LOC = {
	INVTYPE_HEAD = "HEAD", INVTYPE_NECK = "NECK", INVTYPE_SHOULDER = "SHOULDER", INVTYPE_CLOAK = "BACK",
	INVTYPE_CHEST = "CHEST", INVTYPE_ROBE = "CHEST", INVTYPE_WRIST = "WRIST", INVTYPE_HAND = "HANDS",
	INVTYPE_WAIST = "WAIST", INVTYPE_LEGS = "LEGS", INVTYPE_FEET = "FEET", INVTYPE_FINGER = "FINGER",
	INVTYPE_TRINKET = "TRINKET",
	INVTYPE_WEAPON = "MAINHAND", INVTYPE_WEAPONMAINHAND = "MAINHAND", INVTYPE_2HWEAPON = "MAINHAND",
	INVTYPE_RANGED = "MAINHAND", INVTYPE_RANGEDRIGHT = "MAINHAND", INVTYPE_THROWN = "MAINHAND",
	INVTYPE_WEAPONOFFHAND = "OFFHAND", INVTYPE_SHIELD = "OFFHAND", INVTYPE_HOLDABLE = "OFFHAND",
	INVTYPE_RELIC = "OFFHAND",
}

-- The sources' own slot words ("Wrist, Cloth"), for an item known only by its name.
local SLOT_BY_NAME = {
	Head = "HEAD", Neck = "NECK", Shoulder = "SHOULDER", Back = "BACK", Chest = "CHEST", Wrist = "WRIST",
	Hands = "HANDS", Waist = "WAIST", Legs = "LEGS", Feet = "FEET", Finger = "FINGER", Trinket = "TRINKET",
	["One-Hand"] = "MAINHAND", ["Two-Hand"] = "MAINHAND", ["Main Hand"] = "MAINHAND", Ranged = "MAINHAND",
	Thrown = "MAINHAND", ["Off Hand"] = "OFFHAND", ["Held In Off-hand"] = "OFFHAND", Shield = "OFFHAND",
	Relic = "OFFHAND",
}
local ARMOR_BY_NAME = { Cloth = ARMOR_CLOTH, Leather = ARMOR_LEATHER, Mail = ARMOR_MAIL, Plate = ARMOR_PLATE }
-- And what the words make it for the class filter ("Off Hand, Shield", "Two-Hand, Sword"): a two-hander's word is the
-- one-hander's, made two-handed.
local GEAR_BY_NAME = { Shield = ARMOR_SHIELD, Libram = ARMOR_LIBRAM, Idol = ARMOR_IDOL, Totem = ARMOR_TOTEM }
local WEAPON_BY_NAME = { Axe = AXE1H, Mace = MACE1H, Sword = SWORD1H, Polearm = POLEARM, Staff = STAFF,
	["Fist Weapon"] = FIST, Dagger = DAGGER, Bow = BOW, Gun = GUN, Crossbow = CROSSBOW, Wand = WAND,
	Thrown = THROWN, ["Fishing Pole"] = FISHING }
local TWO_HANDED = { [AXE1H] = AXE2H, [MACE1H] = MACE2H, [SWORD1H] = SWORD2H }

Items.SLOT_ORDER = { "HEAD", "NECK", "SHOULDER", "BACK", "CHEST", "WRIST", "HANDS", "WAIST", "LEGS", "FEET",
	"MAINHAND", "OFFHAND", "FINGER", "TRINKET", "OTHER" }
Items.SLOT_NAMES = {
	HEAD = INVTYPE_HEAD or "Head", NECK = INVTYPE_NECK or "Neck", SHOULDER = INVTYPE_SHOULDER or "Shoulder",
	BACK = INVTYPE_CLOAK or "Back", CHEST = INVTYPE_CHEST or "Chest", WRIST = INVTYPE_WRIST or "Wrist",
	HANDS = INVTYPE_HAND or "Hands", WAIST = INVTYPE_WAIST or "Waist", LEGS = INVTYPE_LEGS or "Legs",
	FEET = INVTYPE_FEET or "Feet", MAINHAND = INVTYPE_WEAPONMAINHAND or "Main Hand",
	OFFHAND = INVTYPE_WEAPONOFFHAND or "Off Hand", FINGER = INVTYPE_FINGER or "Finger",
	TRINKET = INVTYPE_TRINKET or "Trinket", OTHER = OTHER or "Other",
}

Items.ARMOR_ORDER = { ARMOR_CLOTH, ARMOR_LEATHER, ARMOR_MAIL, ARMOR_PLATE }

--[[
	What kind of thing an item is, for the loot pages' Type menu (info.kind), and a recipe's
	profession (info.profession, the client's own name: "Alchemy"). Mounts and pets are
	Miscellaneous items of their own subclass; a toy is one the toy box knows.
]]
Items.KIND_ORDER = { "EQUIPMENT", "RECIPE", "CONSUMABLE", "MOUNT", "PET", "TOY", "BAG", "TRADE", "QUEST", "OTHER" }
local KIND_BY_CLASS = {
	[WEAPON] = "EQUIPMENT", [ARMOR] = "EQUIPMENT", [RECIPE] = "RECIPE", [CONSUMABLE] = "CONSUMABLE",
	[CONTAINER] = "BAG", [TRADE_GOODS] = "TRADE", [QUEST] = "QUEST", [BATTLE_PET] = "PET",
}
-- The sources' own first word, for an item the client cannot describe ("Recipe, Alchemy", "Quest").
local KIND_BY_WORD = { Recipe = "RECIPE", Quest = "QUEST", Consumable = "CONSUMABLE", Mount = "MOUNT", Pet = "PET",
	Toy = "TOY", Bag = "BAG" }
-- Not an equipment slot, though GetItemInfoInstant names one.
local NOT_EQUIPPED = { INVTYPE_NON_EQUIP = true, INVTYPE_NON_EQUIP_IGNORE = true }

local function IsToy(itemID)
	if not (C_ToyBox and C_ToyBox.GetToyInfo) then return false end
	local ok, toyID = pcall(C_ToyBox.GetToyInfo, itemID)
	return ok and toyID ~= nil
end

local function Classify(info, words)
	local where, what = (words or ""):match("^%s*([^,]*),?%s*(.-)%s*$")
	local kind
	if info.classID == MISCELLANEOUS then
		kind = (info.subclassID == MISC_MOUNT and "MOUNT") or (info.subclassID == MISC_PET and "PET") or nil
	elseif info.classID then
		kind = KIND_BY_CLASS[info.classID]
	end
	if not kind and Items:IsIdentified(info.itemID) and IsToy(info.itemID) then kind = "TOY" end
	if not kind and info.slot ~= "OTHER" then kind = "EQUIPMENT" end
	if not kind and not info.classID then kind = KIND_BY_WORD[where] or (SLOT_BY_NAME[where] and "EQUIPMENT") end
	info.kind = kind or "OTHER"
	if info.kind == "RECIPE" then
		-- (the data's word in the player's language, as the client names its own recipes' professions)
		info.profession = (info.classID == RECIPE and info.subType ~= "" and info.subType)
			or (what ~= "" and Items:ProfessionName(what)) or nil
	end
end

local instantCache = {}

-- Whether the item has an id; one the sources name without an id yet is keyed "?Name"
-- (Core/Registry.lua), and the client knows nothing of it.
function Items:IsIdentified(itemID)
	return type(itemID) == "number"
end

local function Instant(itemID)
	if not Items:IsIdentified(itemID) then return nil end
	local cached = instantCache[itemID]
	if cached then return cached end
	local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
	local ok, _, itemType, itemSubType, equipLoc, icon, classID, subclassID = pcall(getInstant, itemID)
	if not ok or not classID then return nil end
	cached = {
		itemType = itemType, subType = itemSubType,
		equipLoc = equipLoc ~= "" and not NOT_EQUIPPED[equipLoc] and equipLoc or nil,
		icon = icon, classID = classID, subclassID = subclassID,
	}
	instantCache[itemID] = cached
	return cached
end

-- The item's icon, known at once without asking the server.
function Items:Icon(itemID)
	local instant = Instant(itemID)
	return instant and instant.icon or nil
end

--[[
	Each item's info is built once and kept; the pages read it, never change it. An item the
	server has not described yet is asked for once, checked again on later reads, and after
	GIVE_UP_SECONDS marked unavailable: on Forever the server never answers for some items,
	and a row should not say "Retrieving" for ever.
]]
local GIVE_UP_SECONDS = 15
Items.GIVE_UP_SECONDS = GIVE_UP_SECONDS
local infoCache = {}

--[[
	What the item is, for the filters: its slot (info.slot), its armor type (info.armor: cloth, leather, mail or plate,
	never a cloak's) and its kind (Classify). The client's answer where it has one; else the data's words
	(info.words: "One-Hand, Sword", "Chest, Mail"), which also say what it is for the class filter (info.wordClassID,
	info.wordSubclassID), until the client can say (Learn).
]]
local function Judge(info)
	if info.classID then
		info.slot = SLOT_BY_EQUIP_LOC[info.equipLoc or ""] or "OTHER"
		local subclassID = info.classID == ARMOR and info.subclassID
		info.armor = subclassID and subclassID >= ARMOR_CLOTH and subclassID <= ARMOR_PLATE and info.slot ~= "BACK"
			and subclassID or nil
		info.wordClassID, info.wordSubclassID = nil, nil
	else
		local where, what = (info.words or ""):match("^%s*([^,]*),?%s*(.-)%s*$")
		info.slot = SLOT_BY_NAME[where] or "OTHER"
		info.armor = info.slot ~= "BACK" and ARMOR_BY_NAME[what] or nil
		local weapon = info.slot ~= "OTHER" and (WEAPON_BY_NAME[what] or WEAPON_BY_NAME[where])
		local gear = info.slot ~= "OTHER" and (ARMOR_BY_NAME[what] or GEAR_BY_NAME[what])
		if weapon then
			info.wordClassID, info.wordSubclassID = WEAPON, where == "Two-Hand" and TWO_HANDED[weapon] or weapon
		elseif gear then
			info.wordClassID, info.wordSubclassID = ARMOR, gear
		else
			info.wordClassID, info.wordSubclassID = nil, nil
		end
	end
	Classify(info, info.words)
end

-- An item the client could not describe when its info was built: judged again once it can.
local function Learn(info)
	if info.classID or info.unidentified then return end
	local instant = Instant(info.itemID)
	if not instant then return end
	for key, value in pairs(instant) do info[key] = value end
	Judge(info)
end

local function Describe(info)
	Learn(info)
	local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
	local ok, name, link, quality = pcall(getInfo, info.itemID)
	if not (ok and name) then return false end
	info.name, info.link, info.quality = name, link, quality
	info.pending, info.unavailable, info.askedAt = nil, nil, nil
	return true
end

-- The item's info if it was built already, without asking the server for anything.
function Items:Peek(itemID)
	return infoCache[itemID]
end

-- Everything a loot row shows. `fallback` is the data file's row ({ name, quality, slot }).
function Items:Get(itemID, fallback)
	local info = infoCache[itemID]
	if info then
		-- (the data's words, where the first to ask had none: what the item is until the client can say)
		if not info.words and fallback and fallback.slot then
			info.words = fallback.slot
			if not info.classID then Judge(info) end
		end
		if info.pending and not Describe(info) then
			if not info.unavailable then info.unavailable = GetTime() - info.askedAt > GIVE_UP_SECONDS end
			if fallback then
				info.name = info.name or fallback.name
				info.quality = info.quality or fallback.quality
			end
		end
		return info
	end

	if not self:IsIdentified(itemID) then
		-- Only the data's own words: its name, quality and slot ("Wrist, Cloth").
		info = {
			itemID = itemID, name = fallback and fallback.name, quality = fallback and fallback.quality,
			words = fallback and fallback.slot, unidentified = true,
		}
		Judge(info)
		infoCache[itemID] = info
		return info
	end

	info = { itemID = itemID, words = fallback and fallback.slot }
	local instant = Instant(itemID)
	if instant then
		for key, value in pairs(instant) do info[key] = value end
	end
	Judge(info)

	if not Describe(info) then
		info.name = fallback and fallback.name
		info.quality = fallback and fallback.quality
		info.pending, info.askedAt = true, GetTime()
		if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, itemID) end
	end
	infoCache[itemID] = info
	return info
end

--[[
	Items the server knows nothing of are hidden from the journal's lists until confirmed: an
	/aegis items scan finds them (the player's own, kept in the saved file, and one built in from
	a scan, Data/Generated/Unconfirmed.lua). One shows again as soon as the server describes it, or
	a recorded run sees it drop. A creature listed only for such loot is hidden with it.
]]
local unconfirmed = {}
local RECHECK_PER_STEP, RECHECK_SECONDS = 25, 0.25

-- Adds items to hide until confirmed: { [itemID] = anything }.
function Items:AddUnconfirmed(items)
	for itemID in pairs(items or {}) do
		if type(itemID) == "number" then unconfirmed[itemID] = true end
	end
end

function Items:IsHidden(itemID)
	if not unconfirmed[itemID] then return false end
	local info = infoCache[itemID]
	if info and info.pending then Describe(info) end
	if info and info.link then return false end
	return not (ns.Recorder and ns.Recorder:SawItem(itemID))
end

-- A name-only item (keyed "?Name") whose real one has turned up on the same boss: an item there
-- with an id that the server has described under the same name. The name-only row gives way
-- to it (one source names an item, another gives its id).
function Items:Superseded(boss, row)
	if self:IsIdentified(row.itemID) or not row.name then return false end
	for _, other in ipairs(boss.loot or {}) do
		if self:IsIdentified(other.itemID) then
			local info = infoCache[other.itemID]
			if info and info.link and info.name == row.name then return true end
		end
	end
	return false
end

--[[
	A dungeon's trash drops worth listing: rare and epic ones, recipes and quest items, of any
	quality. The rest, the greens and whites any creature there may drop, are left out of its Trash
	page, the dungeon's loot, search and the Gear Finder. A boss's own drops are always listed, and so
	is every row of a dungeon's Recipes (recipes = true), a white recipe too.
]]
local NOTABLE_QUALITY = 3
local NOTABLE_KINDS = { RECIPE = true, QUEST = true }

function Items:Unremarkable(boss, row)
	if not boss.trash then return false end
	if type(row.quality) == "number" and row.quality >= NOTABLE_QUALITY then return false end
	local info = self:Get(row.itemID, row)
	if type(info.quality) == "number" and info.quality >= NOTABLE_QUALITY then return false end
	return not NOTABLE_KINDS[info.kind]
end

-- Whether a dungeon's trash (or its recipes: ns.IsLootSection) has a drop worth listing that is not hidden: its
-- Trash (or Recipes) entry then shows.
function Items:ListsTrash(boss)
	for _, row in ipairs(boss.loot or {}) do
		if not self:IsHidden(row.itemID) and not self:Unremarkable(boss, row) then return true end
	end
	return false
end

-- A creature the journal has nothing on but loot (no description, abilities, notes on the fight
-- or recorded fight), all of it hidden: most likely not in the game yet either. A boss written up
-- by hand is in the game even while Blizzard keeps all its drops hidden. The trash and the recipes are no
-- creatures (ns.IsLootSection): their entries show by ListsTrash.
function Items:HidesBoss(boss)
	if ns.IsLootSection(boss) or boss.description or (boss.abilities and #boss.abilities > 0)
		or (boss.notes and #boss.notes > 0)
		or boss.encounterID then
		return false
	end
	local loot = boss.loot or {}
	if #loot == 0 then return false end
	for _, row in ipairs(loot) do
		if not self:IsHidden(row.itemID) then return false end
	end
	return true
end

-- Asks the server about the hidden items again, a few at a time: once a session, since Forever
-- adds items as it goes. Those it describes show again.
function Items:RecheckUnconfirmed()
	local list = {}
	for itemID in pairs(unconfirmed) do list[#list + 1] = itemID end
	local position = 1
	local function Next()
		for _ = 1, RECHECK_PER_STEP do
			local itemID = list[position]
			if not itemID then return end
			self:Get(itemID)
			position = position + 1
		end
		C_Timer.After(RECHECK_SECONDS, Next)
	end
	Next()
end

--[[
	Whether a class (its file name, as UnitClass's second return) can equip the item, by the Classic rules above.
	Jewelry, trinkets, cloaks, held off-hands, cosmetic pieces and anything not equippable count as usable by all. An
	item the client cannot describe yet is judged by the data's words (Judge); one with no words either counts as
	usable, so it shows until the client can say.
]]
function Items:ClassCanUse(classFile, info)
	local classID, subclassID = info.classID, info.subclassID
	if classID and not info.equipLoc then return true end
	if not classID then classID, subclassID = info.wordClassID, info.wordSubclassID end
	if not classFile or not classID then return true end
	if classID == WEAPON then
		local weapons = CLASS_WEAPONS[classFile]
		if not weapons or not WEAPON_SKILLS[subclassID] then return true end
		-- (an off-hand weapon: info.slot says so of the client's INVTYPE_WEAPONOFFHAND and the data's "Off Hand")
		return weapons[subclassID] == true and (info.slot ~= "OFFHAND" or DUAL_WIELD[classFile] == true)
	end
	if classID == ARMOR then
		local armor = CLASS_ARMOR[classFile]
		if not armor or info.slot == "BACK" or not ARMOR_SKILLS[subclassID] then return true end
		return armor[subclassID] == true
	end
	return true
end

-- The client's name for an item subclass ("Cloth", "Leatherworking"), nil where it gives none.
local function SubClassName(classID, subclassID)
	local getSubClass = C_Item and C_Item.GetItemSubClassInfo or GetItemSubClassInfo
	local ok, name = pcall(getSubClass, classID, subclassID)
	return ok and type(name) == "string" and name ~= "" and name or nil
end

local ARMOR_WORDS = { [ARMOR_CLOTH] = "Cloth", [ARMOR_LEATHER] = "Leather", [ARMOR_MAIL] = "Mail", [ARMOR_PLATE] = "Plate" }

function Items:ArmorName(subclassID)
	local word = ARMOR_WORDS[subclassID]
	return SubClassName(ARMOR, subclassID) or (word and ns.L.LOOT_WORDS and ns.L.LOOT_WORDS[word]) or word
end

--[[
	The data's slot words ("Wrist, Cloth", "Recipe, Tailoring", "Quest") in the player's language, for a row the
	client cannot describe: an item known by its name alone, or one the client has no data for. Each word as the game
	says it where it has one: a slot the client's own (INVTYPE_*, as the rows of gear it knows), a quest item the line
	its tooltip gives one (ITEM_BIND_QUEST), a profession and an armour type the client's names for them; the rest
	the journal's own (L.LOOT_WORDS), the English word last. The data keeps its English words: the Type menu and the
	slot filter read them (KIND_BY_WORD, SLOT_BY_NAME).
]]
local SLOT_GLOBALS = {
	Head = "INVTYPE_HEAD", Neck = "INVTYPE_NECK", Shoulder = "INVTYPE_SHOULDER", Back = "INVTYPE_CLOAK",
	Chest = "INVTYPE_CHEST", Shirt = "INVTYPE_BODY", Tabard = "INVTYPE_TABARD", Wrist = "INVTYPE_WRIST",
	Hands = "INVTYPE_HAND", Waist = "INVTYPE_WAIST", Legs = "INVTYPE_LEGS", Feet = "INVTYPE_FEET",
	Finger = "INVTYPE_FINGER", Trinket = "INVTYPE_TRINKET", ["One-Hand"] = "INVTYPE_WEAPON",
	["Two-Hand"] = "INVTYPE_2HWEAPON", ["Main Hand"] = "INVTYPE_WEAPONMAINHAND", ["Off Hand"] = "INVTYPE_WEAPONOFFHAND",
	["Held In Off-hand"] = "INVTYPE_HOLDABLE", Ranged = "INVTYPE_RANGED", Thrown = "INVTYPE_THROWN",
	Relic = "INVTYPE_RELIC", Ammo = "INVTYPE_AMMO",
}
Items.SLOT_GLOBALS = SLOT_GLOBALS
-- Enum.ItemRecipeSubclass: each profession's recipes ("Recipe, Leatherworking"), and the books.
local RECIPE_SUBCLASS = { Book = 0, Leatherworking = 1, Tailoring = 2, Engineering = 3, Blacksmithing = 4, Cooking = 5,
	Alchemy = 6, ["First Aid"] = 7, Enchanting = 8, Fishing = 9 }
local QUEST_WORDS = { Quest = true, ["Quest Item"] = true }
local ONE_KIND = { Mount = "MOUNT", Pet = "PET", Toy = "TOY" }

-- What the game calls a quest item: the line its tooltip gives one ("Quest Item").
function Items:QuestItemText()
	if type(ITEM_BIND_QUEST) == "string" and ITEM_BIND_QUEST ~= "" then return ITEM_BIND_QUEST end
	return ns.L.LOOT_QUEST_ITEM
end

-- A profession as the data names it ("Leatherworking"), in the client's words for its recipes.
function Items:ProfessionName(word)
	local words = ns.L.LOOT_WORDS
	return RECIPE_SUBCLASS[word] and SubClassName(RECIPE, RECIPE_SUBCLASS[word]) or (words and words[word]) or word
end

local function Word(word)
	if word == "" then return nil end
	if QUEST_WORDS[word] then return Items:QuestItemText() end
	local global = SLOT_GLOBALS[word] and _G[SLOT_GLOBALS[word]]
	if type(global) == "string" and global ~= "" then return global end
	if RECIPE_SUBCLASS[word] then return Items:ProfessionName(word) end
	if ARMOR_BY_NAME[word] then return Items:ArmorName(ARMOR_BY_NAME[word]) end
	local L = ns.L
	if word == "Recipe" then return L.LOOT_RECIPE end
	if ONE_KIND[word] then return L.LOOT_KIND_ONE[ONE_KIND[word]] end
	return L.LOOT_WORDS and L.LOOT_WORDS[word] or word
end

function Items:Words(words)
	if type(words) ~= "string" then return nil end
	local where, what = words:match("^%s*([^,]*),?%s*(.-)%s*$")
	local first, second = Word(where), Word(what)
	if first and second then return first .. ", " .. second end
	return first or second
end

function Items:QualityColor(quality)
	if quality and C_Item and C_Item.GetItemQualityColor then
		local ok, r, g, b, hex = pcall(C_Item.GetItemQualityColor, quality)
		if ok and r then return r, g, b, hex end
	end
	if quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
		local color = ITEM_QUALITY_COLORS[quality]
		return color.r, color.g, color.b, color.hex
	end
	return 1, 1, 1
end

--[[
	A note's items as links in its text: "{item:275989:Tome of Dalaran:2}" (the id, the name to show
	until the client gives its own, in its language, and the quality) becomes the item's name in its
	quality's color, in brackets, as the game's own links are: a link the note's frame shows the item's
	tooltip for. A common item in the game's white, as in the game (the owner's call of 2026-11-20: "like
	the actual item text in game"; until then the page's dark ink, white being thought not to read on the
	parchment), and so is one whose quality is not known yet; its note then takes the game's text shadow
	(Items:ShadowLinks below).
]]
local COMMON, UNCOMMON = 1, 2

-- The color code a link in this quality takes: the client's for it ("|cffffffff" for a common item).
function Items:LinkColor(quality)
	local _, _, _, hex = self:QualityColor(quality or COMMON)
	if type(hex) ~= "string" then return "|cffffffff" end
	return hex:sub(1, 2) == "|c" and hex or ("|c" .. hex)
end

function Items:LinkText(text)
	return (tostring(text or ""):gsub("{item:(%d+):([^:}]*):?(%d*)}", function(id, written, quality)
		local itemID = tonumber(id)
		local info = self:Get(itemID, { name = written, quality = tonumber(quality) })
		local color = self:LinkColor(type(info.quality) == "number" and info.quality or COMMON)
		return color .. "|Hitem:" .. itemID .. "|h[" .. (info.name or written) .. "]|h|r"
	end))
end

-- Whether a text made by LinkText holds a link in a light color: a common item's white, or a poor one's gray.
function Items:HasLightLink(text)
	if type(text) ~= "string" or not text:find("|Hitem:", 1, true) then return false end
	text = text:lower()
	for quality = 0, UNCOMMON - 1 do
		if text:find(self:LinkColor(quality):lower() .. "|hitem:", 1, true) then return true end
	end
	return false
end

--[[
	A note's text shadow, set with its text (UI/AbilitiesPanel.lua's paper headers, the Quests tab's quest note):
	while the text holds a white or gray link (HasLightLink), the game's own, black, 1 right and 1 down, as its white
	text and its chat's links carry it (GameFontHighlight, ChatFontNormal), so the link reads on the parchment as it
	does in the game; else the font string's own (GameFontBlack's: none), as before (the owner judges it in game,
	2026-11-20).
]]
local LINK_SHADOW = { 0, 0, 0, 1, 1, -1 }

function Items:ShadowLinks(fontString, text)
	if not (fontString and fontString.SetShadowColor and fontString.SetShadowOffset) then return end
	local own = fontString.aegisOwnShadow
	if not own then
		local r, g, b, a, x, y
		if fontString.GetShadowColor then r, g, b, a = fontString:GetShadowColor() end
		if fontString.GetShadowOffset then x, y = fontString:GetShadowOffset() end
		own = { r or 0, g or 0, b or 0, a or 0, x or 0, y or 0 }
		fontString.aegisOwnShadow = own
	end
	local shadow = self:HasLightLink(text) and LINK_SHADOW or own
	fontString:SetShadowColor(shadow[1], shadow[2], shadow[3], shadow[4])
	fontString:SetShadowOffset(shadow[5], shadow[6])
end

-- The client's own link for an item (for the chat), or nil while it has none.
function Items:Link(itemID)
	local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
	if type(getInfo) ~= "function" then return nil end
	local ok, _, link = pcall(getInfo, itemID)
	return ok and link or nil
end

-- The classes this client has, in its own order: { classFile, name, classID }.
-- The classes the client has, in its own order. Their ids have gaps (no Death Knight or Monk here,
-- and the Druid is 11), and GetNumClasses counts the classes, not the ids: every id is tried, up
-- to retail's last (the Evoker, 13).
local LAST_CLASS_ID = 13
function Items:Classes()
	local classes = {}
	local count = type(GetNumClasses) == "function" and GetNumClasses() or 0
	for classID = 1, math.max(count, LAST_CLASS_ID) do
		local ok, name, classFile = pcall(GetClassInfo, classID)
		if ok and classFile and CLASS_ARMOR[classFile] then
			classes[#classes + 1] = { classFile = classFile, name = name, classID = classID }
		end
	end
	return classes
end
