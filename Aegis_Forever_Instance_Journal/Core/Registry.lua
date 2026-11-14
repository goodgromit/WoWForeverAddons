local addonName, ns = ...

--[[
	The journal's data, registered by the files under Data/ as they load.

	Data/Instances holds each dungeon's own data, Data/Authored what is laid over it by hand,
	and Data/Generated what Dev/build_data.py writes (abilities, recorded fights). Adding a
	dungeon is one more ns.AddInstance file and its maps; nothing in the UI names a dungeon.
]]

local instances, byKey, byInstanceID = {}, {}, {}
-- Wings of one dungeon (Scarlet Monastery's) share the client's instance id: id -> { wing, ... }.
local wingsByInstanceID, lastWing = {}, {}
local factions = {}

-- Sorted lists handed out by GetInstances and GetFactions, kept until the data changes.
-- Callers read them and never change them.
local listCache, factionList = {}, nil
-- Where each item drops (ns.ItemDrops), built on first use; and how many times the data has changed.
local drops, moreDrops, dropInstance
local dataVersion = 0
local function DataChanged()
	listCache, factionList = {}, nil
	drops, moreDrops, dropInstance = nil, nil, nil
	dataVersion = dataVersion + 1
end

-- Art given as a list of files the client may have: the first it has, else nil.
local function FirstFile(candidates)
	if type(candidates) ~= "table" then return candidates end
	for _, file in ipairs(candidates) do
		if type(file) == "number" or ns.FileExists(file) then return file end
	end
	return nil
end

-- The picture of a dungeon that has none of its own (Media/DungeonPlaceholder, made by
-- Dev/make_raid_art.py): 2:1, cut like the raids' pictures.
local PLACEHOLDER_ART = "Interface\\AddOns\\" .. addonName .. "\\Media\\DungeonPlaceholder"

local function UsePlaceholderArt(instance)
	instance.buttonArt = PLACEHOLDER_ART
	instance.buttonArtCoords = { 0.047, 0.953, 0, 1 }
	instance.iconArtCoords = { 0.25, 0.75, 0, 1 }
	instance.loreArtCoords = { 0.083, 0.917, 0, 1 }
	instance.placeholderArt = true
end

--[[
	A picture of the dungeon's own (picture: a file of Media/Dungeons): a loading screen the owner gave,
	cut to 2:1 the way the raids' pictures are (the sources in the reference folder's Art/Dungeons). It
	takes the place of the game's journal art: the button's picture, the round icon (iconArtCoords: a
	square of it, its middle unless given) and the overview's. For a dungeon made or already made.
]]
local PICTURES = "Interface\\AddOns\\" .. addonName .. "\\Media\\Dungeons\\"

function ns.UseDungeonPicture(instance, picture, iconArtCoords)
	DataChanged()
	instance.buttonArt = PICTURES .. picture
	instance.buttonImage, instance.loreImage, instance.placeholderArt = nil, nil, nil
	instance.buttonArtCoords = { 0.047, 0.953, 0, 1 }
	instance.iconArtCoords = iconArtCoords or { 0.25, 0.75, 0, 1 }
	instance.loreArtCoords = { 0.083, 0.917, 0, 1 }
end

local function IndexInstanceID(instance)
	local id = instance.instanceID
	local first = byInstanceID[id]
	if not first then
		byInstanceID[id] = instance
		return
	end
	local wings = wingsByInstanceID[id] or { first }
	wings[#wings + 1] = instance
	wingsByInstanceID[id] = wings
	for _, wing in ipairs(wings) do wing.sharesInstanceID = true end
end

--[[
	An item the sources name but give no id for yet (City of Dalaran's newest drops) is kept
	under its name: its itemID becomes "?" and the name, so lists, favourites and pins still tell
	it from the others. Items:IsIdentified tells the two kinds apart; such an item has no icon,
	link or tooltip of its own until a recording gives its id.
]]
local function KeyUnidentified(rows)
	for _, row in ipairs(rows or {}) do
		if not row.itemID then row.itemID = "?" .. (row.name or "") end
	end
end

--[[
	A floor drawn from the client's tiles may name candidates for them (dungeons whose map folders
	are not confirmed yet): the first the client has is kept. A dungeon with a floor the client
	has none for gets no map, rather than one with a blank level.
]]
local function ResolveTiles(instance)
	local floors = instance.map and instance.map.floors
	if not floors then return end
	for _, floor in ipairs(floors) do
		if type(floor.tiles) == "table" then
			local found
			for _, prefix in ipairs(floor.tiles) do
				if ns.FileExists(prefix .. "1") then
					found = prefix
					break
				end
			end
			if not found then
				instance.map.floors = nil
				return
			end
			floor.tiles = found
		end
	end
end

function ns.AddInstance(instance)
	DataChanged()
	assert(type(instance.key) == "string", "AddInstance: key is required")
	assert(not byKey[instance.key], "AddInstance: duplicate key " .. instance.key)
	instance.kind = instance.kind or "dungeon"
	instance.bosses = instance.bosses or {}
	instance.quests = instance.quests or {}
	ResolveTiles(instance)
	for _, boss in ipairs(instance.bosses) do KeyUnidentified(boss.loot) end
	for _, quest in ipairs(instance.quests) do KeyUnidentified(quest.rewards and quest.rewards.items) end
	instance.buttonImage = FirstFile(instance.buttonImage)
	instance.loreImage = FirstFile(instance.loreImage)
	instance.buttonArt = FirstFile(instance.buttonArt)
	if not instance.buttonArt then UsePlaceholderArt(instance) end
	instances[#instances + 1] = instance
	byKey[instance.key] = instance
	if instance.instanceID then IndexInstanceID(instance) end
end

local function FindBoss(instance, name)
	for _, boss in ipairs(instance.bosses) do
		if boss.name == name or boss.enName == name then return boss end
	end
	return nil
end

--[[
	Hand-written additions from Data/Authored, laid over the dungeon's own data:
	  bosses = { ["Boss Name"] = { field = value, ... } }  merged into that boss
	  bossOrder = { "Boss Name", ... }                       run order; unlisted bosses keep theirs, after
	  addQuests = { quest, ... }                             quests the dungeon's data lacks, added after
	                                                         its own (one it already has is left alone)
	  addBosses = { boss, ... }                              bosses the dungeon's data lacks, added before
	                                                         its trash (one it already has is left alone);
	                                                         added first, so the other fields can name them
	  questPatches = { [questID] = { field = value } }       merged into that quest (false clears a field)
	  removeQuests = { questID, ... }                        quests that are not the dungeon's on Forever
	  anything else                                          replaces the instance's field
]]
local function AddBosses(instance, bosses)
	for _, boss in ipairs(bosses) do
		if not FindBoss(instance, boss.name) then
			KeyUnidentified(boss.loot)
			boss.loot = boss.loot or {}
			local at = #instance.bosses + 1
			while at > 1 and instance.bosses[at - 1].trash do at = at - 1 end
			table.insert(instance.bosses, at, boss)
		end
	end
end

function ns.AmendInstance(key, patch)
	DataChanged()
	local instance = byKey[key]
	assert(instance, "AmendInstance: unknown instance " .. tostring(key))
	if patch.addBosses then AddBosses(instance, patch.addBosses) end
	for field, value in pairs(patch) do
		if field == "addBosses" then
			-- added above, before the fields that may name them
		elseif field == "bosses" then
			for name, bossPatch in pairs(value) do
				local boss = FindBoss(instance, name)
				assert(boss, "AmendInstance: " .. key .. " has no boss named " .. name)
				for bossField, bossValue in pairs(bossPatch) do boss[bossField] = bossValue end
				KeyUnidentified(boss.loot)
			end
		elseif field == "bossOrder" then
			local ordered, placed = {}, {}
			for _, name in ipairs(value) do
				local boss = FindBoss(instance, name)
				assert(boss, "AmendInstance: " .. key .. " has no boss named " .. name)
				ordered[#ordered + 1] = boss
				placed[boss] = true
			end
			for _, boss in ipairs(instance.bosses) do
				if not placed[boss] then ordered[#ordered + 1] = boss end
			end
			instance.bosses = ordered
		elseif field == "questPatches" then
			for questID, questPatch in pairs(value) do
				local quest
				for _, candidate in ipairs(instance.quests) do
					if candidate.questID == questID then quest = candidate end
				end
				assert(quest, "AmendInstance: " .. key .. " has no quest " .. tostring(questID))
				for questField, questValue in pairs(questPatch) do
					if questValue == false then quest[questField] = nil else quest[questField] = questValue end
				end
			end
		elseif field == "addQuests" then
			local known = {}
			for _, quest in ipairs(instance.quests) do known[quest.questID] = true end
			for _, quest in ipairs(value) do
				if not known[quest.questID] then
					instance.quests[#instance.quests + 1] = quest
					known[quest.questID] = true
				end
			end
		elseif field == "removeQuests" then
			local gone = {}
			for _, questID in ipairs(value) do gone[questID] = true end
			local kept = {}
			for _, quest in ipairs(instance.quests) do
				if gone[quest.questID] then gone[quest.questID] = nil else kept[#kept + 1] = quest end
			end
			assert(next(gone) == nil, "AmendInstance: " .. key .. " has no quest " .. tostring(next(gone)))
			instance.quests = kept
		else
			instance[field] = value
		end
	end
end

-- A dungeon's quest moved to just after another of its quests: a chain's last step after the step before
-- it, so the Quests tab lists the chain in its order.
function ns.ListQuestAfter(key, questID, afterID)
	DataChanged()
	local quests = byKey[key].quests
	local moved
	for index, quest in ipairs(quests) do
		if quest.questID == questID then moved = table.remove(quests, index) break end
	end
	assert(moved, "ListQuestAfter: " .. key .. " has no quest " .. tostring(questID))
	for index, quest in ipairs(quests) do
		if quest.questID == afterID then table.insert(quests, index + 1, moved) return end
	end
	error("ListQuestAfter: " .. key .. " has no quest " .. tostring(afterID))
end

-- And just before another: a lead-in before the quest it leads to.
function ns.ListQuestBefore(key, questID, beforeID)
	DataChanged()
	local quests = byKey[key].quests
	local moved
	for index, quest in ipairs(quests) do
		if quest.questID == questID then moved = table.remove(quests, index) break end
	end
	assert(moved, "ListQuestBefore: " .. key .. " has no quest " .. tostring(questID))
	for index, quest in ipairs(quests) do
		if quest.questID == beforeID then table.insert(quests, index, moved) return end
	end
	error("ListQuestBefore: " .. key .. " has no quest " .. tostring(beforeID))
end

--[[
	What recorded fights measured (Data/Generated/Abilities.lua, from Dev/build_data.py):
	{ [instance key] = { [boss name] = { abilities, adds, encounterID } } }. Loaded after every
	other data file. A recorded spell the boss's written abilities name gives them its numbers
	(damage, timings); one they lack is added, unless it is nothing to watch for: a hand-written
	file says so (boss.notAbilities, { [spellID] = true }), or it is only a buff the boss cast on
	itself and hit no one with (Kam Deepfury's Defensive Stance). Recorded adds are the creatures
	that cast during the fight, less those a hand-written file says took no part (boss.notAdds,
	{ [npcID] = true }: trash nearby still fighting something else). What a hand-written file
	gave a boss is kept.
]]
local RECORDED_FIELDS = { "hit", "tick", "firstCast", "every", "school", "onSelf" }

local function NothingToWatch(boss, spell)
	if boss.notAbilities and boss.notAbilities[spell.spellID] then return true end
	return spell.onSelf == true and not spell.hit and not spell.tick
end

local function MergeRecorded(boss, recorded)
	local bySpell = {}
	for _, row in ipairs(boss.abilities or {}) do
		if row.spellID then bySpell[row.spellID] = row end
	end
	for _, spell in ipairs(recorded or {}) do
		local row = bySpell[spell.spellID]
		if not row and NothingToWatch(boss, spell) then
			-- a spell the log saw that is not worth listing
		elseif row then
			for _, field in ipairs(RECORDED_FIELDS) do
				if row[field] == nil then row[field] = spell[field] end
			end
		else
			boss.abilities = boss.abilities or {}
			boss.abilities[#boss.abilities + 1] = spell
		end
	end
end

local function RecordedAdds(boss, adds)
	if not (adds and boss.notAdds) then return adds end
	local out = {}
	for _, add in ipairs(adds) do
		if not boss.notAdds[add.npcID] then out[#out + 1] = add end
	end
	return out
end

function ns.SetAbilities(byInstance)
	for key, bosses in pairs(byInstance) do
		local instance = byKey[key]
		for name, found in pairs(instance and bosses or {}) do
			local boss = FindBoss(instance, name)
			if boss then
				MergeRecorded(boss, found.abilities)
				if boss.adds == nil then boss.adds = RecordedAdds(boss, found.adds) end
				if boss.encounterID == nil then boss.encounterID = found.encounterID end
			end
		end
	end
end

-- Every boss of the instance a fight is for, by the encounter's id: more than one where bosses share
-- a fight, as The Deadmines' Sneed's Shredder and Sneed share encounter 2742 (the shredder breaks,
-- Sneed climbs out, and the fight ends as he dies), so a win counts for each. Empty where no boss of
-- the instance has the id.
function ns.BossesForEncounter(instance, encounterID)
	local bosses = {}
	if not (instance and encounterID) then return bosses end
	for _, boss in ipairs(instance.bosses) do
		if boss.encounterID == encounterID then bosses[#bosses + 1] = boss end
	end
	return bosses
end

--[[
	Factions are registered in the shape of an instance, a standing in place of a boss:
	{ key = "Faction529", kind = "faction", factionID, name, bosses = { standing, ... } },
	each standing { name, reaction, standing = true, loot = { { itemID, price, cost }, ... } }.
	The journal then draws a faction's rewards the way it draws a dungeon's loot, filters and
	all. The list itself (Data/Reputation/Factions.lua) has no rewards: they come from captured
	quartermasters (ns.AddCapturedVendors).
]]
-- The original game's factions all have ids below 1000; those added since (WoW: Forever's
-- own, and the Season of Discovery ones it brought along) are numbered from 2500 up.
local FIRST_NEW_FACTION_ID = 1000

function ns.AddFactions(list)
	for _, entry in ipairs(list) do
		local faction = { key = "Faction" .. entry.factionID, kind = "faction", factionID = entry.factionID, name = entry.name,
			forever = entry.factionID >= FIRST_NEW_FACTION_ID or nil }
		faction.bosses = {}
		for _, standing in ipairs(entry.standings or {}) do
			local loot = {}
			for _, itemID in ipairs(standing.items or {}) do loot[#loot + 1] = { itemID = itemID } end
			faction.bosses[#faction.bosses + 1] = {
				name = _G["FACTION_STANDING_LABEL" .. tostring(standing.reaction)] or standing.name,
				reaction = standing.reaction, standing = true, loot = loot,
			}
		end
		ns.AddInstance(faction)
		factions[#factions + 1] = faction
	end
end

--[[
	Reputation rewards come only from quartermasters captured in game (the Reputation tab's
	Capture button, or a recording): the build's captures (Data/Reputation/Captured.lua) and the
	player's own (seen = true). Each vendor:
	  { npcID, name, mapID, x, y, wares = { { itemID, price, cost, faction, reaction }, ... } }
	A ware that needs a standing joins that faction's rewards at it, with its price (copper) and
	any other cost ("2 Arcane Crystal"), unless the faction lists it already. The faction is known
	by the name the ware's tooltip gives (faction nil: "this faction", worked out below); one the
	journal does not have is left alone. A ware that needs no standing (reaction nil: Stondry
	Darkhammer's 30-Favor plans) joins the faction of its vendor's wares that do, in a group of its
	own, "Any standing", first on the page; a vendor with no ware that needs a standing is no
	faction's, and adds nothing. The vendor is kept on the faction as one of its quartermasters.
	Returns how many wares joined.
]]
-- The "Any standing" group's reaction: below Hated (1), so it comes first and any standing reaches it.
ns.ANY_STANDING = 0

local function StandingFor(faction, reaction)
	for _, candidate in ipairs(faction.bosses) do
		if candidate.reaction == reaction then return candidate end
	end
	local name = reaction == ns.ANY_STANDING and ns.L.REP_ANY_STANDING
		or _G["FACTION_STANDING_LABEL" .. tostring(reaction)] or tostring(reaction)
	local standing = { name = name, reaction = reaction, standing = true, loot = {} }
	local at = #faction.bosses + 1
	while at > 1 and (faction.bosses[at - 1].reaction or 0) > reaction do at = at - 1 end
	table.insert(faction.bosses, at, standing)
	return standing
end

-- Whether a boss or a faction goes by a name: the journal's own, its English or the client's.
function ns.NamedAs(entry, name)
	return name ~= nil and (entry.name == name or entry.enName == name or entry.clientName == name)
end

local function FactionNamed(name)
	for _, faction in ipairs(factions) do
		if ns.NamedAs(faction, name) then return faction end
	end
	return nil
end

local function HasReward(faction, itemID)
	for _, standing in ipairs(faction.bosses) do
		for _, row in ipairs(standing.loot) do
			if row.itemID == itemID then return true end
		end
	end
	return false
end

--[[
	Many wares say only "Requires Friendly with this faction.": the vendor's own faction, which
	the game does not name (the Azeroth Commerce Authority's craftsmen). It is worked out from the
	wares that do name theirs, in this order:
	  1. another ware of the same vendor that names its faction;
	  2. the currency it costs, when wares that name a faction cost it and no other faction's do
	     (whatever Merchant's Favor buys is the Azeroth Commerce Authority's);
	  3. a vendor standing close by (same map, within NEAR_VENDOR) whose faction is known.
	A ware none of these place waits (pendingWares) and is tried again with every capture.
]]
local NEAR_VENDOR = 0.03
local vendorFaction, currencyFaction, placedVendors, pendingWares = {}, {}, {}, {}

-- The currencies and items a cost names: "200 Merchant's Favor + 2 Arcane Crystal".
local function CostNames(cost)
	local names = {}
	for part in tostring(cost or ""):gmatch("[^+]+") do
		local name = part:match("^%s*%d+%s+(.-)%s*$")
		if name and name ~= "" then names[#names + 1] = name end
	end
	return names
end

local function LearnFaction(vendor, ware)
	local key = vendor.npcID or vendor.name
	if key then
		vendorFaction[key] = vendorFaction[key] or ware.faction
		if vendor.mapID and vendor.x and vendor.y then
			placedVendors[key] = { mapID = vendor.mapID, x = vendor.x, y = vendor.y, faction = vendorFaction[key] }
		end
	end
	for _, name in ipairs(CostNames(ware.cost)) do
		local known = currencyFaction[name]
		if known == nil then
			currencyFaction[name] = ware.faction
		elseif known ~= ware.faction then
			currencyFaction[name] = false -- paid to two factions: says nothing
		end
	end
end

-- The faction a ware needs a standing with: the one its tooltip names, else worked out as above.
function ns.WareFaction(vendor, ware)
	if ware.faction then return ware.faction end
	local key = vendor.npcID or vendor.name
	if key and vendorFaction[key] then return vendorFaction[key] end
	for _, name in ipairs(CostNames(ware.cost)) do
		if currencyFaction[name] then return currencyFaction[name] end
	end
	if vendor.mapID and vendor.x and vendor.y then
		for _, other in pairs(placedVendors) do
			if other.mapID == vendor.mapID and math.abs(other.x - vendor.x) <= NEAR_VENDOR
				and math.abs(other.y - vendor.y) <= NEAR_VENDOR then
				return other.faction
			end
		end
	end
	return nil
end

-- A faction's row for an item, and the standing it is under.
local function RewardRow(faction, itemID)
	for _, standing in ipairs(faction.bosses) do
		for index, row in ipairs(standing.loot) do
			if row.itemID == itemID then return row, standing, index end
		end
	end
end

--[[
	Rewards as the client's item tables list them (Data/Reputation/Listed.lua), before anyone has
	captured the faction's quartermaster: { [factionID] = { [reaction] = { itemID, ... } } }. Each
	row is marked listed: unconfirmed, with no price or cost, until a capture finds it (AddWare).
]]
function ns.AddListedRewards(byFaction)
	for _, faction in ipairs(factions) do
		local standings = byFaction[faction.factionID]
		if standings then
			local reactions = {}
			for reaction in pairs(standings) do reactions[#reactions + 1] = reaction end
			table.sort(reactions)
			for _, reaction in ipairs(reactions) do
				for _, itemID in ipairs(standings[reaction]) do
					if not HasReward(faction, itemID) then
						local loot = StandingFor(faction, reaction).loot
						loot[#loot + 1] = { itemID = itemID, listed = true }
					end
				end
			end
			faction.rewardCount, faction.crest = nil, nil
		end
	end
end

-- The ware whose faction a vendor's wares that need no standing join: the first that needs a standing
-- with a faction the journal has and its tooltip names, else the first that needs one; nil for a vendor
-- with none.
function ns.StandingWare(vendor)
	local first
	for _, ware in ipairs(vendor.wares or {}) do
		if ware.reaction then
			if ware.faction and FactionNamed(ware.faction) then return ware end
			first = first or ware
		end
	end
	return first
end

-- One ware joining its faction's rewards; false when its faction is not known yet. A listed
-- (unconfirmed) row it matches is confirmed: it takes the ware's price, cost and standing. via is
-- the ware whose faction it takes: itself, or for one that needs no standing, a ware of the same
-- vendor that needs one.
local function AddWare(vendor, ware, seen, via)
	local name = ns.WareFaction(vendor, via or ware)
	local faction = name and FactionNamed(name)
	if not faction then return false, 0 end
	faction.quartermasters = faction.quartermasters or {}
	faction.quartermasters[vendor.npcID or vendor.name] = { name = vendor.name, mapID = vendor.mapID,
		x = vendor.x, y = vendor.y }
	local reaction = ware.reaction or ns.ANY_STANDING
	local row, standing, index = RewardRow(faction, ware.itemID)
	if row and row.listed then
		row.listed, row.price, row.cost, row.seen = nil, ware.price, ware.cost, seen or nil
		if standing.reaction ~= reaction then
			table.remove(standing.loot, index)
			local loot = StandingFor(faction, reaction).loot
			loot[#loot + 1] = row
		end
		faction.rewardCount = nil
		return true, 1
	end
	if row then return true, 0 end
	local loot = StandingFor(faction, reaction).loot
	loot[#loot + 1] = { itemID = ware.itemID, price = ware.price, cost = ware.cost, seen = seen or nil }
	-- Its count and crest are worked out again.
	faction.rewardCount, faction.crest = nil, nil
	return true, 1
end

--[[
	Everyday goods (the owner's call of 2026-11-12, "yes hide those"): Kalsey Sanden's and Aza'bek's water, spices,
	flour, wood and the like are no faction's rewards, and stay off the Authority's "Any standing". Those two vendors
	only (by creature id): their wares that need no standing, priced in gold with no other cost, that are not a recipe,
	plan, pattern, formula or schematic (the client's Recipe item class, known at once: GetItemInfoInstant). An item the
	client cannot describe counts as such goods. A capture of the player's own is held to it too.
]]
local EVERYDAY_GOODS_VENDORS = { [256731] = "Kalsey Sanden", [248198] = "Aza'bek" }
local RECIPE_CLASS = 9   -- Enum.ItemClass.Recipe

function ns.IsEverydayGoods(vendor, ware)
	if not (EVERYDAY_GOODS_VENDORS[vendor.npcID] and not ware.reaction and (ware.price or 0) > 0
		and (ware.cost == nil or ware.cost == "")) then
		return false
	end
	local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
	local ok, _, _, _, _, _, classID = pcall(getInstant, ware.itemID)
	return not (ok and classID == RECIPE_CLASS)
end

function ns.AddCapturedVendors(vendors, seen)
	-- What these vendors say about whose wares are whose comes first, so their order does not matter.
	for _, vendor in ipairs(vendors) do
		for _, ware in ipairs(vendor.wares or {}) do
			if ware.faction and ware.reaction and FactionNamed(ware.faction) then LearnFaction(vendor, ware) end
		end
	end
	-- Wares that waited for their faction join it as soon as these name it (not counted: they are
	-- another vendor's).
	local waiting = pendingWares
	pendingWares = {}
	for _, entry in ipairs(waiting) do
		if not AddWare(entry.vendor, entry.ware, entry.seen, entry.via) then pendingWares[#pendingWares + 1] = entry end
	end
	local added = 0
	for _, vendor in ipairs(vendors) do
		local via = ns.StandingWare(vendor)
		for _, ware in ipairs(via and vendor.wares or {}) do
			-- (two vendors' everyday goods left off: ns.IsEverydayGoods)
			if not ns.IsEverydayGoods(vendor, ware) then
				local whose = not ware.reaction and via or nil
				local placed, count = AddWare(vendor, ware, seen, whose)
				added = added + count
				-- A faction the tooltip named that the journal lacks is left alone; an unnamed one waits.
				if not placed and not (whose or ware).faction then
					pendingWares[#pendingWares + 1] = { vendor = vendor, ware = ware, seen = seen, via = whose }
				end
			end
		end
	end
	return added
end

-- Whether a faction has any rewards confirmed by a capture; one without waits for its
-- quartermaster, though the client's item tables may already list some (ns.FactionListed).
function ns.FactionCaptured(faction)
	for _, standing in ipairs(faction.bosses) do
		for _, row in ipairs(standing.loot) do
			if not row.listed then return true end
		end
	end
	return false
end
function ns.FactionListed(faction)
	for _, standing in ipairs(faction.bosses) do
		if #standing.loot > 0 then return true end
	end
	return false
end
-- Whether a faction's own rewards list an item (not counting wares a vendor was seen selling).
function ns.FactionListsItem(factionName, itemID)
	for _, faction in ipairs(factions) do
		if ns.NamedAs(faction, factionName) then
			for _, standing in ipairs(faction.bosses) do
				for _, row in ipairs(standing.loot) do
					if row.itemID == itemID and not row.seen and not row.listed then return true end
				end
			end
			return false
		end
	end
	return false
end

-- Whether any instance in the journal has a quest: as a row of its own, or as a version of a row any
-- one of several quests will do (Gnomeregan's Sparklematic steps).
function ns.JournalHasQuest(questID)
	for _, instance in ipairs(instances) do
		for _, quest in ipairs(instance.quests) do
			if quest.questID == questID then return true end
			for _, version in ipairs(quest.oneOf or {}) do
				if version.questID == questID then return true end
			end
		end
	end
	return false
end

-- A boss's name as the journal titles it: the dungeon's trash is "Trash".
function ns.BossTitle(boss)
	return boss.trash and ns.L.TRASH or boss.name
end

function ns.GetInstance(key)
	return byKey[key]
end

-- The wing the player stands in: by the area's name (wingAreas), else by the map the client
-- puts them on; else the wing they were last seen in, else the first. The second value says
-- whether the place itself told (the area or the map), not a guess.
local function WingHere(instanceID, wings)
	local ok, area = pcall(GetSubZoneText)
	area = ok and ns.Readable(area) or nil
	for _, wing in ipairs(wings) do
		if area and ns.AreaIn(wing.wingAreas, area) then return wing, true end
	end
	local mapID = ns.PlayerMapPosition()
	for _, wing in ipairs(wings) do
		for _, floor in ipairs(mapID and wing.map and wing.map.floors or {}) do
			if floor.uiMapID == mapID then return wing, true end
		end
	end
	return lastWing[instanceID] or wings[1], false
end

-- Every instance a client instance id stands for: the wings of one that has several.
function ns.GetInstancesByInstanceID(instanceID)
	return wingsByInstanceID[instanceID] or { byInstanceID[instanceID] }
end

-- The instance the player is standing in, from GetInstanceInfo's instance id; and whether that is
-- sure: always for a dungeon with one wing, and for a wing only when the area or the map named it.
-- The wing found is the one guessed next time where nothing names one; look = true only looks, and
-- leaves that guess as the map, the Recorder and the search left it (the run block asks so:
-- Core/Run.lua, UI/RunTracker.lua).
function ns.GetInstanceByInstanceID(instanceID, look)
	local wings = wingsByInstanceID[instanceID]
	if not wings then return byInstanceID[instanceID], byInstanceID[instanceID] ~= nil end
	local wing, placed = WingHere(instanceID, wings)
	if not look then lastWing[instanceID] = wing end
	return wing, placed
end

-- The instance the player is inside, if the journal has it, with whether the wing is sure (above)
-- and the client's instance id. Nil outside, and where the client keeps the id back. look: as above.
function ns.CurrentInstance(look)
	local ok, _, _, _, _, _, _, _, instanceID = pcall(GetInstanceInfo)
	instanceID = ok and ns.Readable(instanceID) or nil
	if not instanceID then return nil end
	local instance, placed = ns.GetInstanceByInstanceID(instanceID, look)
	if not instance then return nil end
	return instance, placed, instanceID
end

-- A boss of the instance by a name the client gives: the journal's, the English, the client's own
-- or one of its other names (aliases).
function ns.BossNamed(instance, name)
	if not (instance and name) then return nil end
	for _, boss in ipairs(instance.bosses) do
		if ns.NamedAs(boss, name) then return boss end
		for _, alias in ipairs(boss.aliases or {}) do
			if alias == name then return boss end
		end
	end
	return nil
end

-- The bosses a fight is for: each boss with the encounter's id where the journal knows it (two where
-- they share one fight: Sneed's Shredder and Sneed, ns.BossesForEncounter), else the one the fight is
-- named for. The client's name for a fight is not always the boss's (Magmatus's is "Infurnus"), nor
-- each boss's where two share it. Empty where it is none of the instance's.
function ns.BossesForFight(instance, encounterID, name)
	local bosses = ns.BossesForEncounter(instance, encounterID)
	if #bosses == 0 then bosses[1] = ns.BossNamed(instance, name) end
	return bosses
end

-- Whether ENCOUNTER_END's success says the group won: 1 on most clients, true on some. What the
-- client keeps back is no win.
function ns.EncounterWon(success)
	success = ns.Readable(success)
	return success == 1 or success == true
end

local function ByLevelThenName(a, b)
	local levelA, levelB = a.levelMin or 0, b.levelMin or 0
	if levelA ~= levelB then return levelA < levelB end
	return a.name < b.name
end

-- Instances of one kind ("dungeon" or "raid"), lowest level first. A bracket of nil means all.
function ns.GetInstances(kind, bracket)
	local cacheKey = bracket and bracket.min and (kind .. ":" .. bracket.min .. "-" .. bracket.max) or kind
	local list = listCache[cacheKey]
	if list then return list end
	list = {}
	for _, instance in ipairs(instances) do
		-- A hidden one (hidden = true) keeps its data but stays out of every list, for now.
		if instance.kind == kind and not instance.hidden and ns.InstanceInBracket(instance, bracket) then
			list[#list + 1] = instance
		end
	end
	table.sort(list, ByLevelThenName)
	listCache[cacheKey] = list
	return list
end

-- An instance belongs to a bracket when their level ranges overlap.
function ns.InstanceInBracket(instance, bracket)
	if not bracket or not bracket.min then return true end
	local low, high = instance.levelMin, instance.levelMax or instance.levelMin
	if not low then return true end
	return low <= bracket.max and high >= bracket.min
end

--[[
	Areas below a zone that the client has no map of, such as Old Ironforge beneath Ironforge.
	The client reports the player's position there on the zone's own map, so each one has a
	picture and, from two readings taken in game (calibration: the same spot's position on
	the zone's map and on the picture), the rectangle of the zone's map the picture covers.
]]
local subMaps, subMapsByKey = {}, {}

function ns.AddSubMap(subMap)
	subMap.instances = subMap.instances or {}
	-- A place the client gives no position in (the Deeprun Tram) has no calibration, and so no
	-- bounds: it is known by its zone's name instead.
	if subMap.calibration then
		local a, b = subMap.calibration[1], subMap.calibration[2]
		local width = (a.map[1] - b.map[1]) / (a.picture[1] - b.picture[1])
		local height = (a.map[2] - b.map[2]) / (a.picture[2] - b.picture[2])
		local left, top = a.map[1] - a.picture[1] * width, a.map[2] - a.picture[2] * height
		subMap.bounds = { left = left, top = top, width = width, height = height }
	end
	subMaps[#subMaps + 1] = subMap
	subMapsByKey[subMap.key] = subMap
end

function ns.GetSubMaps()
	return subMaps
end

function ns.GetSubMap(key)
	return subMapsByKey[key]
end

--[[
	Transports written into the journal (Data/Authored/Transports.lua): boats, zeppelins,
	airships, trams and portals, in the shape /aegis travel saves them:
	{ kind, mapID, x, y, area, faction, to = { destination, ... }, notes = { [destination] = note } }.
]]
local transports = {}

function ns.AddTransports(list)
	for _, spot in ipairs(list) do
		spot.to = spot.to or {}
		transports[#transports + 1] = spot
	end
end

function ns.GetTransports()
	return transports
end

-- The quests the dungeons' chains need first that no dungeon lists itself ("steps"), each a quest
-- of its own by its id, so the Quests tab gives them a dungeon quest's page
-- (Data/Generated/QuestSteps.lua).
local questSteps = {}

function ns.AddQuestSteps(list)
	for questID, quest in pairs(list) do
		quest.questID = questID
		questSteps[questID] = quest
	end
end

--[[
	Which bosses each dungeon's quests have business with (Data/Generated/QuestLinks.lua, written by
	Tools/build_quest_links.py: by dungeon, then by the boss's English name, his links), kept on each boss of that
	name as questLinks, for his quest badge (UI/QuestMap.lua). Loaded after every file that adds or amends a dungeon's
	bosses and quests, before the client's language is laid over them (ns.ApplyLocale names who in it).
]]
function ns.AddQuestLinks(byInstance)
	for key, byBoss in pairs(byInstance) do
		local instance = ns.GetInstance(key)
		for _, boss in ipairs(instance and instance.bosses or {}) do
			if not boss.trash and byBoss[boss.name] then boss.questLinks = byBoss[boss.name] end
		end
	end
end

--[[
	A step whose givers differ by side (Journey to the Marsh: Bink in Ironforge for the Alliance, Ursyn
	Ghull in Thunder Bluff for the Horde) keeps the Alliance's and carries the Horde's as `horde`: its
	pickup, startMap and note, false where it has none. A Horde character gets the step with those in
	their place, read through to the step (so the translations laid over both show), the same table
	each time, so it can stay chosen.
]]
local hordeSteps = {}

function ns.GetQuestStep(questID)
	local step = questSteps[questID]
	if not (step and step.horde) then return step end
	local ok, faction = pcall(UnitFactionGroup, "player")
	if not ok or faction ~= "Horde" then return step end
	local view = hordeSteps[questID]
	if not view then
		local own = step.horde
		view = setmetatable({}, { __index = function(_, key)
			local value = own[key]
			if value == nil then value = step[key] end
			return value
		end })
		hordeSteps[questID] = view
	end
	return view
end

--[[
	Quest XP the journal has only from the original game (Data/Generated/OriginalXP.lua, by quest id,
	with that number): Forever may give more, and it is not yet confirmed there. ns.QuestXP gives a
	quest's XP and whether it is that number, for the Quests tab to mark it; a quest whose XP is
	another number (Forever's) is not marked.
]]
local originalXP = {}

function ns.AddOriginalXP(list)
	for questID, xp in pairs(list) do originalXP[questID] = xp end
end

function ns.QuestXP(questID, rewards)
	local xp = rewards and rewards.xp
	return xp, xp ~= nil and xp > 0 and originalXP[questID] == xp
end

--[[
	A step in a quest's prerequisites that any one of several quests will do (QuestieDB's
	preQuestSingle), for the Quests tab (UI/QuestsPanel.lua): ns.OneOf(name, version, ...), each
	version a quest id or { questID, name, level, faction, classOnly } (its name, if not given,
	the step's; its level, for the row, if the journal has no page for it). The step keeps the
	first version's id as its own, as every step has one. A new table each call: each quest gets
	its own, so the translations are laid over each once.
]]
function ns.OneOf(name, ...)
	local versions = {}
	for _, version in ipairs({ ... }) do
		local entry = type(version) == "table" and version or { questID = version }
		local copy = {}
		for field, value in pairs(entry) do copy[field] = value end
		copy.name = copy.name or name
		versions[#versions + 1] = copy
	end
	return { questID = versions[1].questID, name = name, oneOf = versions }
end

--[[
	Whether a quest or a note for one class, or for a few ({ "WARRIOR", "PALADIN" }: QuestieDB's
	requiredClasses with more than one class), is for this class (its file name, as UnitClass gives
	it). With no class known, it is.
]]
function ns.ForClass(classOnly, classFile)
	if not classOnly or not classFile then return true end
	if type(classOnly) ~= "table" then return classOnly == classFile end
	for _, class in ipairs(classOnly) do
		if class == classFile then return true end
	end
	return false
end

--[[
	A quest's giver or taker "inside the dungeon" ("Marshal Windsor, inside the dungeon"), with the
	dungeon named ("Marshal Windsor, inside Blackrock Depths"), as the journal writes it elsewhere:
	how another dungeon's page shows it, where "the dungeon" would read as that one (an
	attunement's steps on the raid's page; UI/QuestsPanel.lua). Nil when the words are not in it.
]]
local INSIDE_DUNGEON = "inside the dungeon"
function ns.InsideNamed(text, name)
	if type(text) ~= "string" or not name or not text:find(INSIDE_DUNGEON, 1, true) then return nil end
	return (text:gsub(INSIDE_DUNGEON, (("inside " .. name):gsub("%%", "%%%%"))))
end

-- The dungeon a wing is part of, by its English name: "Dire Maul" for "Dire Maul: Warpwood Quarter",
-- "Stratholme" for "Stratholme: Service Gate"; nil for an instance that is no wing. A quest several
-- wings keep is named by it on another dungeon's page, not by whichever wing comes first.
function ns.WingDungeon(enName)
	return type(enName) == "string" and enName:match("^(.-): ") or nil
end

-- Routes Forever took out: { kind, mapID, x, y, to = { destination, ... } }, hidden from the
-- spots players saved themselves too (UI/TravelMap.lua).
local goneTransports = {}

function ns.RemoveTransports(list)
	for _, route in ipairs(list) do goneTransports[#goneTransports + 1] = route end
end

function ns.GetGoneTransports()
	return goneTransports
end

-- Factions with rewards, by name.
function ns.GetFactions()
	if not factionList then
		factionList = {}
		for _, faction in ipairs(factions) do factionList[#factionList + 1] = faction end
		table.sort(factionList, function(a, b) return a.name < b.name end)
	end
	return factionList
end

--[[
	Where each item drops, for its tooltip (UI/ItemTooltip.lua): the bosses whose loot lists it, and
	the trash, in the journal's order (dungeons, then raids, as GetInstances sorts them; each one's
	bosses in their order, its trash last). Most items drop in one place: drops[itemID] is that boss,
	and moreDrops[itemID] lists them all only for an item with more than one. A faction's rewards are
	not drops, and are left out. Built on first use, and again after the data changes.
]]
local function IndexDrops()
	drops, moreDrops, dropInstance = {}, {}, {}
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances(kind)) do
			for _, boss in ipairs(instance.bosses) do
				dropInstance[boss] = instance
				for _, row in ipairs(boss.loot or {}) do
					local itemID = row.itemID
					-- One known by its name only ("?Name") has no tooltip of its own.
					if type(itemID) == "number" then
						local first = drops[itemID]
						if not first then
							drops[itemID] = boss
						elseif first ~= boss then
							-- A boss's rows are walked together: one listing an item twice is the last one here.
							local more = moreDrops[itemID]
							if not more then
								moreDrops[itemID] = { first, boss }
							elseif more[#more] ~= boss then
								more[#more + 1] = boss
							end
						end
					end
				end
			end
		end
	end
end

local function NextDrop(itemID, index)
	index = index + 1
	local more, boss = moreDrops[itemID], nil
	if more then
		boss = more[index]
	elseif index == 1 then
		boss = drops[itemID]
	end
	if boss then return index, boss, dropInstance[boss] end
end

-- for _, boss, instance in ns.ItemDrops(itemID) do ... end
function ns.ItemDrops(itemID)
	if not drops then IndexDrops() end
	return NextDrop, itemID, 0
end

function ns.HasDrops(itemID)
	if not drops then IndexDrops() end
	return drops[itemID] ~= nil
end

-- Goes up each time the data changes: whatever is worked out from it is worked out again.
function ns.DataVersion()
	return dataVersion
end

--[[
	The client's own names, where its language is one the journal is translated into (ns.ClientL),
	whichever language the journal previews: a boss's and a faction's, as what the client says of
	them is matched by them too (a fight ending, a creature at hand, a ware's tooltip: ns.NamedAs),
	and a route's, as the player may have saved it under that (UI/TravelMap.lua). Taken before the
	journal's own words are laid over the data (Core/Init.lua), and let go once used.
]]
function ns.KeepClientNames()
	ns.ForgetUnspokenWords()
	local client = ns.ClientL
	local bossNames, factionNames, strings = client.BOSS_NAMES, client.FACTION_NAMES, client.STRINGS
	client.BOSS_NAMES, client.FACTION_NAMES, client.STRINGS = nil, nil, nil
	if bossNames or factionNames then
		for _, instance in ipairs(instances) do
			instance.enName = instance.enName or instance.name
			if instance.kind == "faction" and factionNames then instance.clientName = factionNames[instance.factionID] end
			for _, boss in ipairs(instance.bosses or {}) do
				boss.enName = boss.enName or boss.name
				if bossNames then boss.clientName = bossNames[boss.enName] end
			end
		end
	end
	if strings then
		for _, spot in ipairs(transports) do
			if spot.to and not spot.clientTo then
				spot.clientTo = {}
				for index, destination in ipairs(spot.to) do spot.clientTo[index] = strings[destination] or destination end
			end
		end
	end
end

--[[
	Lays a translation of the content over the data, once every data file has loaded and the
	client's own names are kept (ns.KeepClientNames, before it in Core/Init.lua): names and text
	are swapped in place, looked up by their English words (Locales/ruRU_content.lua). An English
	client has no such tables, and nothing is changed.

	A boss, an add or an instance keeps its English name as enName: what the journal matches and
	records by (a fight the client names, a faction a ware's tooltip names, a recording sent in)
	still finds it. The lookup tables are let go once used.
]]
function ns.ApplyLocale()
	local L = ns.L
	if not (L.INSTANCE_NAMES or L.BOSS_NAMES or L.STRINGS or L.FACTION_NAMES or L.SUBMAP_NAMES) then return end
	local instanceNames = L.INSTANCE_NAMES
	local locations = L.INSTANCE_LOCATIONS
	local descriptions = L.INSTANCE_DESCRIPTIONS
	local factionNames = L.FACTION_NAMES
	local subMapNames = L.SUBMAP_NAMES
	local trash = L.TRASH_DROPS
	local bossNames = L.BOSS_NAMES
	local abilityNames = L.ABILITY_NAMES
	local strings = L.STRINGS

	-- Free text (a description, a note, an ability's own words, quest text), looked up as written.
	local function Tr(text)
		if type(text) == "string" and strings then return strings[text] or text end
		return text
	end
	local function TrBossName(name)
		if type(name) ~= "string" or not bossNames then return name end
		return bossNames[name] or name
	end
	local function TrAbility(ability)
		if type(ability) ~= "table" then return end
		-- The English is kept, for the role alerts read from it (UI/AbilitiesPanel.lua).
		ability.enName = ability.enName or ability.name
		if ability.name and abilityNames then ability.name = abilityNames[ability.name] or ability.name end
		if ability.text then ability.text = Tr(ability.text) end
	end
	local function TrBoss(boss)
		boss.enName = boss.enName or boss.name
		if trash and (boss.trash or boss.name == "Trash Drops") then
			boss.name = trash
		else
			boss.name = TrBossName(boss.name)
		end
		if boss.description then boss.description = Tr(boss.description) end
		if boss.fightNote then boss.fightNote = Tr(boss.fightNote) end
		if boss.area then
			boss.enArea = boss.enArea or boss.area
			local named = ns.AreaName(boss.enArea)
			boss.area = named ~= boss.enArea and named or Tr(boss.enArea)
		end
		if boss.notes then
			for index, note in ipairs(boss.notes) do boss.notes[index] = Tr(note) end
		end
		for _, ability in ipairs(boss.abilities or {}) do TrAbility(ability) end
		for _, extra in ipairs(boss.extraAbilities or {}) do
			if extra.title then extra.title = Tr(extra.title) end
			if extra.description then extra.description = Tr(extra.description) end
		end
		for _, stage in ipairs(boss.stages or {}) do
			if stage.title then stage.title = Tr(stage.title) end
			if stage.description then stage.description = Tr(stage.description) end
			for _, ability in ipairs(stage.abilities or {}) do TrAbility(ability) end
		end
		for _, add in ipairs(boss.adds or {}) do
			if type(add) == "table" then
				add.enName = add.enName or add.name
				add.name = TrBossName(add.name)
				for _, ability in ipairs(add.abilities or {}) do TrAbility(ability) end
			end
		end
		-- Reputation wares carry a cost ("200 Merchant's Favor"); the item's own name is the client's.
		-- The English is kept, for the currency's icon (ns.CostIcons).
		for _, row in ipairs(boss.loot or {}) do
			if row.cost then
				row.enCost = row.enCost or row.cost
				row.cost = Tr(row.cost)
			end
		end
	end
	--[[
		Someone who gives or takes a quest, by their English name: their name in the language, else as one of the
		quest's own giver and taker lines has it in the language, the words before its comma ("Zaetar's Spirit, inside
		the dungeon"; the full-width comma in Chinese), read from its English line, kept (enPickup, enTurnin) as the
		quests share their tables. nil where neither says. For a spot inside a dungeon (Data/Authored/InsideQuestSpots.lua)
		and one at a boss's spot (Data/Generated/QuestLinks.lua's who).
	]]
	local function PersonName(enName, quest)
		local name = strings and strings[enName]
		if name or not strings then return name end
		for _, line in ipairs({ quest.enPickup or quest.pickup or false, quest.enTurnin or quest.turnin or false }) do
			local told = line and line:sub(1, #enName + 1) == enName .. "," and strings[line]
			if told then return told:match("^(.-),") or told:match("^(.-)\239\188\140") end
		end
		return nil
	end
	local function TrQuest(quest, instance)
		-- The English name is kept, for the Quests tab to tell the steps of one chain that share a name in
		-- every language alike (UI/QuestsPanel.lua's Fold).
		quest.enName = quest.enName or quest.name
		if quest.name then quest.name = Tr(quest.name) end
		if quest.objective then quest.objective = Tr(quest.objective) end
		if quest.note then quest.note = Tr(quest.note) end
		if quest.wingUnsaidNote then quest.wingUnsaidNote = Tr(quest.wingUnsaidNote) end
		-- Where its chain goes next, shown on its own page alone (UI/QuestsPanel.lua's FillDetail), and the
		-- quest it is given only while in the log, which its lock line names
		if quest.followUp then quest.followUp = Tr(quest.followUp) end
		if quest.parentQuest and quest.parentQuest.name then quest.parentQuest.name = Tr(quest.parentQuest.name) end
		-- A giver or taker inside the dungeon keeps the language's words for it with the dungeon named
		-- (ns.InsideNamed), for another dungeon's page; false where the language has none. A quest two
		-- wings share keeps the first's. A wing's quest keeps them with the whole dungeon named too
		-- (ns.WingDungeon), for a quest more than one wing keeps.
		for _, field in ipairs({ "pickup", "turnin" }) do
			local named = instance and ns.InsideNamed(quest[field], instance.enName)
			if named and not (quest.inside and quest.inside[field] ~= nil) then
				quest.inside = quest.inside or {}
				quest.inside[field] = strings and strings[named] or false
			end
			local dungeon = instance and ns.InsideNamed(quest[field], ns.WingDungeon(instance.enName))
			if dungeon and not (quest.insideDungeon and quest.insideDungeon[field] ~= nil) then
				quest.insideDungeon = quest.insideDungeon or {}
				quest.insideDungeon[field] = strings and strings[dungeon] or false
			end
		end
		-- The English pickup and start item's name are kept, for the Quests tab to tell a pickup that is
		-- the start item ("Damp Note, dropped by ...") from a giver (UI/QuestsPanel.lua's PickupIsItem); the English
		-- turnin too, for the names of who takes it inside (PersonName).
		quest.enPickup = quest.enPickup or quest.pickup
		quest.enTurnin = quest.enTurnin or quest.turnin
		if quest.pickup then quest.pickup = Tr(quest.pickup) end
		if quest.turnin then quest.turnin = Tr(quest.turnin) end
		if quest.startMap and quest.startMap.label then quest.startMap.label = Tr(quest.startMap.label) end
		-- Who or what stands at a spot inside the dungeon (Data/Authored/InsideQuestSpots.lua), as its mark's tooltip
		-- names it: from its English, kept, as quests share a spot's table; a giver or taker by their giver or taker line
		-- too (PersonName), where the language names the line and not them (the review of 3cc3416).
		for _, field in ipairs({ "startInside", "endInside", "objectivesInside" }) do
			local spots = quest[field]
			for _, spot in ipairs(spots and (spots.x and { spots } or spots) or {}) do
				if spot.name then
					spot.enName = spot.enName or spot.name
					local name = field ~= "objectivesInside" and PersonName(spot.enName, quest)
					-- (one quest of a spot's may say so where another's line does not: a name found is kept)
					if name or spot.name == spot.enName then spot.name = name or Tr(spot.enName) end
				end
			end
		end
		for _, key in ipairs({ "startItem", "startObject" }) do
			local entry = quest[key]
			if entry then
				entry.enName = entry.enName or entry.name
				if entry.name then entry.name = Tr(entry.name) end
				if entry.note then entry.note = Tr(entry.note) end
			end
		end
		for _, prerequisite in ipairs(quest.prerequisites or {}) do
			-- (a step's English name kept too: the Quests tab folds a chain's steps of the quest's own name into
			-- its row, and joins a chain's steps of one name, alike in every language)
			prerequisite.enName = prerequisite.enName or prerequisite.name
			if prerequisite.name then prerequisite.name = Tr(prerequisite.name) end
			for _, version in ipairs(prerequisite.oneOf or {}) do
				version.enName = version.enName or version.name
				if version.name then version.name = Tr(version.name) end
			end
			-- A step the journal has no quest of its own for carries its own card's words.
			if prerequisite.objective then prerequisite.objective = Tr(prerequisite.objective) end
			if prerequisite.pickup then prerequisite.pickup = Tr(prerequisite.pickup) end
			if prerequisite.turnin then prerequisite.turnin = Tr(prerequisite.turnin) end
			if prerequisite.note then prerequisite.note = Tr(prerequisite.note) end
			local point = prerequisite.startMap
			if point and point.label then point.label = Tr(point.label) end
			local item = prerequisite.startItem
			if item then
				if item.name then item.name = Tr(item.name) end
				if item.note then item.note = Tr(item.note) end
			end
		end
		-- A row any one of several quests will do, as a dungeon lists it (Gnomeregan's Sparklematic steps):
		-- its versions' names, and their pages, which its lock line reads (UI/QuestsPanel.lua).
		for _, version in ipairs(quest.oneOf or {}) do
			if version.name then version.name = Tr(version.name) end
		end
		for _, page in ipairs(quest.pages or {}) do TrQuest(page, instance) end
	end

	for _, instance in ipairs(instances) do
		instance.enName = instance.enName or instance.name
		if instance.kind == "faction" then
			local name = factionNames and factionNames[instance.factionID]
			if name then instance.name = name end
		else
			local name = instanceNames and instanceNames[instance.key]
			if name then instance.name = name end
			local location = locations and locations[instance.key]
			instance.location = location or Tr(instance.location)
			local description = descriptions and descriptions[instance.key]
			instance.description = description or Tr(instance.description)
		end
		for _, boss in ipairs(instance.bosses or {}) do TrBoss(boss) end
		-- Whoever gives or takes a quest at a boss's spot (Data/Generated/QuestLinks.lua's who, his quest badge's
		-- tooltip): as PersonName has them, the English kept.
		for _, boss in ipairs(instance.bosses or {}) do
			for _, link in ipairs(boss.questLinks or {}) do
				if link.who then
					link.enWho = link.enWho or link.who
					local name
					for _, quest in ipairs(instance.quests or {}) do
						if not name and quest.questID == link.questID then name = PersonName(link.enWho, quest) end
					end
					link.who = name or link.enWho
				end
			end
		end
		for _, quest in ipairs(instance.quests or {}) do TrQuest(quest, instance) end
		-- Before you go's notes (UI/BeforeYouGo.lua); the boss a note names stays English, as matched.
		for _, entry in ipairs(instance.prepare or {}) do
			entry.title, entry.text = Tr(entry.title), Tr(entry.text)
		end
	end
	for _, quest in pairs(questSteps) do
		TrQuest(quest)
		-- The Horde's giver, where the sides' differ (ns.GetQuestStep).
		if quest.horde then TrQuest(quest.horde) end
	end
	if subMapNames then
		for _, subMap in ipairs(subMaps) do
			local name = subMapNames[subMap.key]
			if name then subMap.name = name end
		end
	end
	for _, spot in ipairs(transports) do
		if spot.area then spot.area = Tr(spot.area) end
		-- The English is kept, so a route the player saved under it is known as this one (UI/TravelMap.lua).
		if spot.to and not spot.enTo then
			spot.enTo = {}
			for index, destination in ipairs(spot.to) do spot.enTo[index] = destination end
		end
		for index, destination in ipairs(spot.to or {}) do spot.to[index] = Tr(destination) end
		-- A route's note ("Skyborne only") is kept under its destination: under the new name now.
		if spot.notes then
			local notes = {}
			for destination, note in pairs(spot.notes) do notes[Tr(destination)] = Tr(note) end
			spot.notes = notes
		end
	end
	L.STRINGS, L.BOSS_NAMES, L.ABILITY_NAMES = nil, nil, nil
	DataChanged()
end

