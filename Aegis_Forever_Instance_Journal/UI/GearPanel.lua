local _, ns = ...
local L = ns.L

--[[
	The journal's Gear Finder tab (Core/GearFinder.lua), dressed as Forever's character panel
	(Blizzard_UIPanels_Game/Camelot/CharacterFrame.xml and PaperDollFrame.xml): its two pane
	backgrounds and the divider between them, its slot frames, header bar and striped rows.

	Left, the slots in the character sheet's two columns, each with the best upgrade waiting for
	it, marked with the equipment flyout's green arrow, or what is worn when there is none.
	Right, the sheet's own pane: the dungeon holding the most upgrades, which they are, the
	arrows through the other dungeons, and the ranged slot.

	The character panel's own tab for this is UI/CharacterTab.lua.

	In Adventure Mode an upgrade is shown as much as the character knows of it (Core/GearFinder.lua's
	states, the owner's calls of 2026-11-07). Seen to drop: in full, as in every other style. Its dungeon
	entered but the item not seen there yet: its slot's empty picture from the character sheet (a helmet's
	outline for the head) in its rarity's border, "Something better", "Drops in" the dungeon, its boss "???"
	until met, and nothing of the item (no name, picture, level, gain, link or compare). Its dungeon not
	entered, a rumour: the same picture and words, pointed to by the zone its door
	is in and its level range, with the door's line of rumour in the tooltip, never the dungeon's name or
	the boss's; a click on the slot shows that door on the world map with the client's own map pin link
	(UI/QuestsPanel.lua's link faces, as the quest page's Show Start does), not the journal's page. A
	suggested dungeon that is a rumour shows as one: "A rumor", its line, its place, its upgrades' count
	and Show on map. Rumours are never picked (the slot's box lists the others).
]]

local GearPanel = {}
ns.GearPanel = GearPanel

-- The two panes inside the panel's edge. The right one is the character sheet's own width; the
-- left one takes the rest, wider than the sheet's for the slots' names. The panel fills the
-- journal's inset, 792x431 (UI/Journal.lua).
local EDGE = 3
local RIGHT_WIDTH, PANE_HEIGHT = 233, 425

-- Slots as the sheet sets them: 37 square and 6 apart, 24 in from the left and 20 from the
-- right; the first row under the title and status line. The right pane's content sits 16 in,
-- as its side panes' does.
local SLOT_SIZE, ROW_STEP, FIRST_ROW = 37, 43, 59
local LEFT_X, RIGHT_X, SIDE_X = 24, 20, 16
local TEXT_GAP, TEXT_WIDTH = 8, 200
local SIDE_TEXT_WIDTH = RIGHT_WIDTH - 2 * SIDE_X - SLOT_SIZE - TEXT_GAP

-- Where each slot goes: { column, row }. Columns 1 and 2 are the left pane's, 3 the right pane.
local PLACES = {
	head = { 1, 1 }, neck = { 1, 2 }, shoulder = { 1, 3 }, back = { 1, 4 }, chest = { 1, 5 }, wrist = { 1, 6 },
	mainhand = { 1, 7 }, offhand = { 1, 8 },
	hands = { 2, 1 }, waist = { 2, 2 }, legs = { 2, 3 }, feet = { 2, 4 },
	finger1 = { 2, 5 }, finger2 = { 2, 6 }, trinket1 = { 2, 7 }, trinket2 = { 2, 8 },
	ranged = { 3, 8 },
}

-- The suggested dungeon's upgrades, as the sheet lists its stats: this many rows at most.
local SIDE_ROWS, ROW_WIDTH, ROW_HEIGHT = 5, 187, 23

local GAIN_COLOR = { 0.25, 1, 0.25 }
--[[
	A rumour's card (the right pane's suggested dungeon not entered yet) shows one of the game's own loading screens
	that the journal uses nowhere else, by its file id (nothing shipped), never the dungeon's own picture. Each is cut
	to the card's shape (174 x 96) inside the screen's frame: { its width over its height as the game shows it, left,
	right, top, bottom }. RUMOUR_ART is the one shown: the owner's pick is a change of that line. A light shade only,
	so the picture shows as a dungeon button's does and the name still reads.
]]
local RUMOUR_ARTS = {
	[131838] = { 4 / 3, 0.17, 0.9245, 0.24, 0.795 }, -- LoadScreenDungeon: a torchlit way in
	[131840] = { 4 / 3, 0.1126, 0.8874, 0.225, 0.795 }, -- LoadScreenEnviroment: a misty forest path
	[131829] = { 4 / 3, 0.1208, 0.8793, 0.24, 0.798 }, -- no file name: a pencil drawing of a sealed round door in a cave
	[6225617] = { 2992 / 1684, 0.1516, 0.8484, 0.159, 0.842 }, -- a map by lantern light: the owner's pick (2026-11-10)
	[7963776] = { 2992 / 1684, 0.1736, 0.8264, 0.18, 0.82 }, -- Forever's Eastern Kingdoms
	[131856] = { 4 / 3, 0.1126, 0.8874, 0.28, 0.85 }, -- an icy cavern
	[4661969] = { 2992 / 1684, 0.1736, 0.8264, 0.18, 0.82 }, -- a dark blue hall
	[8423398] = { 2992 / 1684, 0.1736, 0.8264, 0.18, 0.82 }, -- Forever's Darkspear Islands
}
local RUMOUR_ART = 6225617
local RUMOUR_SHADE = 0.8
local DIM_COLOR = { 0.5, 0.5, 0.5 }
-- The level an item waits for, in the red the game gives what a player cannot use yet.
local LATER_COLOR = { 1, 0.1, 0.1 }

local SLOT_LABELS = {
	head = INVTYPE_HEAD or "Head", neck = INVTYPE_NECK or "Neck", shoulder = INVTYPE_SHOULDER or "Shoulder",
	back = INVTYPE_CLOAK or "Back", chest = INVTYPE_CHEST or "Chest", wrist = INVTYPE_WRIST or "Wrist",
	hands = INVTYPE_HAND or "Hands", waist = INVTYPE_WAIST or "Waist", legs = INVTYPE_LEGS or "Legs",
	feet = INVTYPE_FEET or "Feet", mainhand = INVTYPE_WEAPONMAINHAND or "Main Hand",
	offhand = INVTYPE_WEAPONOFFHAND or "Off Hand", ranged = INVTYPE_RANGED or "Ranged",
	finger1 = L.GEAR_SLOT_FINGER1, finger2 = L.GEAR_SLOT_FINGER2,
	trinket1 = L.GEAR_SLOT_TRINKET1, trinket2 = L.GEAR_SLOT_TRINKET2,
}

------------------------------------------------------------------------------------------
-- Art
------------------------------------------------------------------------------------------

-- Draws an atlas, at its own size when asked; false when this client lacks it.
local function Atlas(texture, atlas, ownSize)
	if not ns.AtlasExists(atlas) then return false end
	texture:SetAtlas(atlas, ownSize == true)
	return true
end

-- An atlas at its own size, cut off where it would run past width x height: art made for the
-- character sheet's taller panes, kept to ours.
local function AtlasCut(texture, atlas, width, height)
	if not Atlas(texture, atlas, true) then return false end
	local info = C_Texture.GetAtlasInfo(atlas)
	local fullWidth, fullHeight = info.width or width, info.height or height
	local shownWidth, shownHeight = math.min(fullWidth, width), math.min(fullHeight, height)
	texture:SetSize(shownWidth, shownHeight)
	if (shownWidth < fullWidth or shownHeight < fullHeight) and info.leftTexCoord then
		local left, right, top, bottom = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
		texture:SetTexCoord(left, left + (right - left) * shownWidth / fullWidth,
			top, top + (bottom - top) * shownHeight / fullHeight)
	end
	return true
end

--[[
	The empty picture of an inventory slot, as the character sheet shows it (the client's own: a helmet's
	outline for the head; the back slot has none of its own, and the client gives it the chest's). Adventure
	Mode shows an upgrade not seen yet by it too, in its rarity's border (SetCell, the picker's rows). The sheet's
	own rule for the ranged slot, asked as it draws: a class with a relic slot (librams, idols, totems) gets the
	relic's picture there, not the bow.
]]
local RELIC_SLOT_TEXTURE = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic"
local function EmptySlotTexture(inv)
	local getInfo = (C_PaperDollInfo and C_PaperDollInfo.GetInventorySlotInfo) or GetInventorySlotInfo
	if getInfo then
		local ok, _, texture, checkRelic = pcall(getInfo, inv)
		if ok and checkRelic and UnitHasRelicSlot and UnitHasRelicSlot("player") then return RELIC_SLOT_TEXTURE end
		if ok and texture then return texture end
	end
	return "Interface\\PaperDoll\\UI-Backpack-EmptySlot"
end

------------------------------------------------------------------------------------------
-- Words
------------------------------------------------------------------------------------------

-- A gain in the spec's own unit: "31", or "0.8" when it is that small.
local function Points(value)
	if value >= 10 then return tostring(math.floor(value + 0.5)) end
	return string.format("%.1f", value)
end
GearPanel.Points = Points

--[[
	"+4.2%", "+12%": what an upgrade adds to everything worn. While nothing worn is worth
	anything to the spec (a fresh character), the plain gain: "+31", "+0.4".
]]
local function GainText(compare)
	local share = compare.share
	if not share then return "+" .. Points(compare.delta or 0) end
	if share < 9.95 then return string.format("+%.1f%%", share) end
	return string.format("+%d%%", math.floor(share + 0.5))
end
GearPanel.GainText = GainText

-- Who drops it: the boss, or the dungeon's trash (a Trash page's row the bosses and rares drop: them, offBosses). In
-- Adventure Mode a boss not met is "???" (Core/Discovery.lua).
local function SourceName(entry)
	if entry.boss.trash then return entry.row and ns.OffBossesText(entry.row) or L.LOOT_TRASH end
	if ns.Discovery:Unmet(entry.instance, entry.boss) then return ns.Discovery.UNKNOWN end
	return entry.boss.name
end
GearPanel.SourceName = SourceName

-- Whether an upgrade is shown by its slot and rarity alone (Adventure Mode): not seen to drop yet, or a rumour.
local function Hidden(entry)
	return entry ~= nil and entry.state ~= nil and entry.state ~= "seen"
end
GearPanel.Hidden = Hidden

--[[
	A rumour's zone (Adventure Mode): the zone its door is in, by the client's name for it (UI/DungeonMap.lua's
	DoorPoint, which is also where its map pin link leads), else its location. Never its name: a place that holds
	it is left out (nil). And that point.
]]
local function RumourZone(instance)
	local point = ns.DungeonMap:DoorPoint(instance)
	local place = point and point.place or instance.location
	if type(place) ~= "string" or place == "" or place:find(instance.name, 1, true) then place = nil end
	return place, point
end

-- Its zone and level range, "Westfall · Level 17-26", where the slots and tooltips say where a rumour is.
local function RumourPlace(instance)
	local place = RumourZone(instance)
	local range = instance.levelMin and string.format(L.LEVEL_RANGE, instance.levelMin, instance.levelMax or instance.levelMin)
	if place and range then return string.format(L.GEAR_ADVENTURE_PLACE, place, range) end
	return place or range or ""
end
GearPanel.RumourPlace = RumourPlace
-- The rumour card's picture, for the checks (Tools/smoke_scenario.lua).
GearPanel.RUMOUR_ART, GearPanel.RUMOUR_ARTS, GearPanel.RUMOUR_SHADE = RUMOUR_ART, RUMOUR_ARTS, RUMOUR_SHADE

local function QualityRGB(quality)
	local r, g, b = ns.Items:QualityColor(quality)
	return r, g, b
end

------------------------------------------------------------------------------------------
-- Tooltips and clicks
------------------------------------------------------------------------------------------

local function ShowCompare()
	if type(GameTooltip_ShowCompareItem) == "function" and IsModifiedClick and IsModifiedClick("COMPAREITEMS") then
		pcall(GameTooltip_ShowCompareItem)
	end
end

-- Whether every item's tooltip, the Gear Finder's too, says what it is worth to each spec
-- (UI/ItemTooltip.lua): the player's choice for every character, shown unless turned off. The
-- same box is in the weights editor and the journal's options: each shown one follows a change.
function GearPanel.ShowsGains()
	return not (ns.db and ns.db.hideGearTipGains)
end

-- `fromOptions`: the change came from the options' own box, which needs no telling.
function GearPanel.SetShowsGains(shown, fromOptions)
	ns.db.hideGearTipGains = not shown or nil
	if ns.WeightsEditor then ns.WeightsEditor:SyncShowGains() end
	-- With Pawn, the journal's scale there shows or hides with it.
	if ns.PawnLink then
		ns.PawnLink:Push()
		ns.PawnLink:AskReload()
	end
	if not fromOptions and Settings and Settings.NotifyUpdate then
		pcall(Settings.NotifyUpdate, "AEGIS_JOURNAL_ITEM_TIPS")
	end
end

-- An upgrade's tooltip, kept plain: the item with what it is worth to each spec (UI/
-- ItemTooltip.lua, which shows the gain the Gear Finder found for its own spec: on a second ring,
-- over the other one), where it drops, and what a click on `owner` does; `picked`, that the
-- player chose it for its slot.
--[[
	An upgrade shown by its slot and rarity alone (Adventure Mode, Hidden): no item in the tooltip, so nothing of
	it reaches the game's tooltips, compare or another addon's scores. "Something better" in its rarity's colour, its
	slot (`slotKey`), then where: its dungeon and boss ("???" until met) and that it has not been seen to drop, or for
	a rumour "A rumor", the door's line and its place; then the click (`clickText`, and `moreText` under it).
]]
local function ShowHiddenTooltip(owner, entry, anchor, clickText, picked, slotKey, moreText)
	ns.ItemTooltip:UseCompare(owner, nil)
	ns.ItemTooltip:UseSource(owner, nil)
	GameTooltip:SetOwner(owner, anchor or "ANCHOR_RIGHT")
	local r, g, b = QualityRGB(entry.info.quality)
	GameTooltip:SetText(L.GEAR_ADVENTURE_BETTER, r, g, b)
	if slotKey and SLOT_LABELS[slotKey] then GameTooltip:AddLine(SLOT_LABELS[slotKey], 1, 1, 1) end
	if entry.rumour then
		GameTooltip:AddLine(L.ADVENTURE_DOOR_TITLE, 1, 0.82, 0)
		GameTooltip:AddLine(ns.Discovery:DoorRumour(entry.instance), 1, 1, 1, true)
		GameTooltip:AddLine(RumourPlace(entry.instance), 1, 0.82, 0)
	else
		GameTooltip:AddLine(entry.instance.name .. " \194\183 " .. SourceName(entry), 1, 0.82, 0)
		GameTooltip:AddLine(L.GEAR_ADVENTURE_UNSEEN, DIM_COLOR[1], DIM_COLOR[2], DIM_COLOR[3], true)
	end
	if picked then GameTooltip:AddLine(L.GEAR_TIP_PICKED, 1, 0.82, 0) end
	if clickText then GameTooltip:AddLine(clickText, 0.5, 0.5, 0.5, true) end
	if moreText then GameTooltip:AddLine(moreText, 0.5, 0.5, 0.5, true) end
	GameTooltip:Show()
end

local function ShowEntryTooltip(owner, entry, anchor, clickText, picked, slotKey, moreText)
	if Hidden(entry) then return ShowHiddenTooltip(owner, entry, anchor, clickText, picked, slotKey, moreText) end
	ns.ItemTooltip:UseCompare(owner, entry.link, entry.compare)
	-- Its own line below says where it drops, and a click opens that place.
	ns.ItemTooltip:UseSource(owner, entry.itemID)
	GameTooltip:SetOwner(owner, anchor or "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(entry.link)
	GameTooltip:AddLine(entry.instance.name .. " \194\183 " .. SourceName(entry), 1, 0.82, 0)
	if picked then GameTooltip:AddLine(L.GEAR_TIP_PICKED, 1, 0.82, 0) end
	GameTooltip:AddLine(clickText or L.GEAR_TIP_CLICK, 0.5, 0.5, 0.5, true)
	GameTooltip:Show()
	ShowCompare()
end

-- Opens the item where the journal lists it, as a search result opens: trash drops on the
-- dungeon's own loot page, past any loot filter that would hide it.
-- One not seen to drop yet (Adventure Mode) opens its dungeon's loot, which lists what has been seen there; a
-- rumour never opens the journal (its door is shown on the map instead).
local function OpenEntry(entry)
	if entry.rumour then return end
	ns.PlaySoundKit("IG_ABILITY_PAGE_TURN")
	if Hidden(entry) then
		ns.Journal:OpenInstance(entry.instance)
		ns.EncounterPage:SetTab(ns.Journal:Page(), ns.EncounterPage.TAB_LOOT)
		return
	end
	if entry.boss.trash then
		ns.Journal:OpenInstance(entry.instance)
	else
		ns.Journal:OpenBoss(entry.instance, entry.boss)
	end
	ns.EncounterPage:SetTab(ns.Journal:Page(), ns.EncounterPage.TAB_LOOT)
	ns.LootPanel:Reveal(entry.itemID)
end

-- A click on an upgrade: shift and ctrl do what they do on any item (link it, try it on); a
-- plain one opens it.
local function ClickEntry(entry)
	if not entry or entry.rumour then return end
	if not Hidden(entry) and ns.Gamepad:ItemClick(entry.link) then return end
	OpenEntry(entry)
end

-- Whether a rumour's slot is its map pin link on its picture alone (SetCellDoor): the slot has upgrades to pick.
local function FaceOnIcon(cell)
	local face = rawget(cell, "LinkFace")
	return face and face:IsShown() and rawget(cell, "faceRegion") ~= nil or false
end

--[[
	A cell's click: shift and ctrl do what they do on any item (its upgrade, or what is worn there
	when it has none). A plain click opens the slot's top upgrades to pick from, beside it; a right
	click opens its upgrade's loot.
]]
local function ClickCell(cell, button)
	local entry, link = cell.entry, nil
	-- (one shown by its slot and rarity alone has no link to give: Adventure Mode)
	if entry then
		if not Hidden(entry) then link = entry.link end
	else
		link = GetInventoryItemLink("player", cell.def.slot)
	end
	if ns.Gamepad:ItemClick(link) then return end
	if not entry then return end
	-- A rumour's slot is the map pin link to its door (SetCellDoor): the whole slot, or its picture alone where the slot
	-- has upgrades to pick, whose words then open them. Where the client allows it no face, its own click marks the
	-- door, as Show Start's does (UI/MapPin.lua), and a right-click opens the picks; with no door placed, any click.
	if entry.rumour then
		if button == "RightButton" or FaceOnIcon(cell) or not cell.point then
			GearPanel:TogglePicker(cell)
			return
		end
		GearPanel:ClosePicker()
		if cell.point then
			ns.PlaySoundKit("IG_MAINMENU_OPTION")
			ns.MapPin:Mark(cell.point, ns.Discovery:DoorName(entry.instance))
		end
		return
	end
	if button == "RightButton" then
		GearPanel:ClosePicker()
		OpenEntry(cell.entry)
	else
		GearPanel:TogglePicker(cell)
	end
end

------------------------------------------------------------------------------------------
-- Slot cells
------------------------------------------------------------------------------------------

local function ShowCellTooltip(cell)
	local entry = cell.entry
	local anchor = cell.mirrored and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
	if entry then
		local click, more = L.GEAR_TIP_CELL_CLICK, nil
		if entry.rumour then
			-- Its picture the link to the door and its words the picks (SetCellDoor); else the slot's own clicks (ClickCell)
			if FaceOnIcon(cell) then
				click = L.GEAR_ADVENTURE_MAP_PICK_CLICK
			else
				click = cell.point and L.GEAR_ADVENTURE_MAP_CLICK or L.GEAR_ADVENTURE_NO_DOOR
				if ns.GearFinder:Pickable({ entries = cell.others or {} }) > 0 then
					more = L.GEAR_ADVENTURE_RUMOUR_PICKS
				end
			end
		elseif Hidden(entry) then
			click = L.GEAR_ADVENTURE_CELL_CLICK
		end
		ShowEntryTooltip(cell, entry, anchor, click, cell.picked, cell.def.key, more)
		return
	end
	-- No upgrade: what is worn, as the sheet's own slot shows it, with what it is worth.
	ns.ItemTooltip:UseCompare(cell, nil)
	ns.ItemTooltip:UseSource(cell, nil)
	GameTooltip:SetOwner(cell, anchor)
	local slotID = cell.def.slot
	if GetInventoryItemLink("player", slotID) then
		GameTooltip:SetInventoryItem("player", slotID)
	else
		GameTooltip:SetText(SLOT_LABELS[cell.def.key] or cell.def.key, 1, 1, 1)
	end
	GameTooltip:AddLine(L.GEAR_TIP_NONE, DIM_COLOR[1], DIM_COLOR[2], DIM_COLOR[3], true)
	GameTooltip:Show()
end

--[[
	A slot as the character sheet draws one (PaperDollItemSlotButtonTemplate's look: the slot
	frame, the quick-slot edge, the quality border), with the item's name and where it drops
	beside it. Built rather than inherited: the sheet's template equips and picks up items.
	Cells in the right-hand column face the other way, their text towards the middle.
]]
local function CreateCell(panel, def)
	local column, row = PLACES[def.key][1], PLACES[def.key][2]
	local mirrored = column == 2
	local textWidth = column == 3 and SIDE_TEXT_WIDTH or TEXT_WIDTH
	local cell = CreateFrame("Button", nil, panel)
	cell:SetSize(SLOT_SIZE + TEXT_GAP + textWidth, SLOT_SIZE)
	local y = -(EDGE + FIRST_ROW + (row - 1) * ROW_STEP)
	if column == 1 then
		cell:SetPoint("TOPLEFT", EDGE + LEFT_X, y)
	elseif column == 2 then
		cell:SetPoint("TOPRIGHT", -(EDGE + RIGHT_WIDTH + RIGHT_X), y)
	else
		cell:SetPoint("TOPLEFT", panel, "TOPRIGHT", -(EDGE + RIGHT_WIDTH) + SIDE_X, y)
	end
	cell.def, cell.mirrored = def, mirrored
	cell.emptyTexture = EmptySlotTexture(def.inv)

	cell.Icon = cell:CreateTexture(nil, "BORDER")
	cell.Icon:SetSize(SLOT_SIZE, SLOT_SIZE)
	cell.Icon:SetPoint(mirrored and "RIGHT" or "LEFT")

	cell.SlotFrame = cell:CreateTexture(nil, "BACKGROUND")
	cell.SlotFrame:SetPoint("CENTER", cell.Icon)
	cell.SlotFrame:SetShown(Atlas(cell.SlotFrame, "UI-Character-Info-GearSlot", true))

	cell.Edge = cell:CreateTexture(nil, "ARTWORK")
	cell.Edge:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	cell.Edge:SetSize(64, 64)
	cell.Edge:SetPoint("CENTER", cell.Icon, 0, -1)

	cell.IconBorder = cell:CreateTexture(nil, "OVERLAY")
	cell.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
	cell.IconBorder:SetAllPoints(cell.Icon)

	-- The level an item waits for, where the sheet puts a count.
	cell.Level = cell:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	cell.Level:SetPoint("BOTTOMRIGHT", cell.Icon, -3, 2)

	-- The player's own pick, starred as the auction house stars a favourite.
	cell.Picked = cell:CreateTexture(nil, "OVERLAY", nil, 2)
	cell.Picked:SetSize(14, 14)
	cell.Picked:SetPoint("TOPRIGHT", cell.Icon, 2, 2)
	cell.hasPickedArt = Atlas(cell.Picked, "auctionhouse-icon-favorite")
	cell.Picked:Hide()

	cell.IconHighlight = cell:CreateTexture(nil, "HIGHLIGHT")
	cell.IconHighlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	cell.IconHighlight:SetBlendMode("ADD")
	cell.IconHighlight:SetAllPoints(cell.Icon)

	-- The character panel's row light, behind the text.
	cell.Hover = cell:CreateTexture(nil, "HIGHLIGHT")
	if Atlas(cell.Hover, "charactercreate-customize-dropdown-linemouseover-middle") then
		cell.Hover:SetAlpha(0.1)
	else
		cell.Hover:SetColorTexture(1, 1, 1, 0.06)
	end
	cell.Hover:SetPoint("TOP", 0, 2)
	cell.Hover:SetPoint("BOTTOM", 0, -2)
	if mirrored then
		cell.Hover:SetPoint("LEFT", -4, 0)
		cell.Hover:SetPoint("RIGHT", cell.Icon, "LEFT", -2, 0)
	else
		cell.Hover:SetPoint("LEFT", cell.Icon, "RIGHT", 2, 0)
		cell.Hover:SetPoint("RIGHT", 4, 0)
	end

	local side = mirrored and "RIGHT" or "LEFT"
	local out = mirrored and -TEXT_GAP or TEXT_GAP
	cell.Name = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	cell.Name:SetPoint("TOP" .. side, cell.Icon, "TOP" .. (mirrored and "LEFT" or "RIGHT"), out, -3)
	cell.Name:SetWidth(textWidth)
	cell.Name:SetJustifyH(side)
	cell.Name:SetWordWrap(false)

	-- Second line: where it drops, and the gain just after it, so each cell's gain stays by its
	-- own words (the two columns' would otherwise meet in the middle).
	cell.Gain = cell:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	cell.Gain:SetTextColor(GAIN_COLOR[1], GAIN_COLOR[2], GAIN_COLOR[3])
	cell.Source = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	cell.Source:SetWordWrap(false)
	cell.Source:SetJustifyH(side)
	cell.Source:SetPoint("BOTTOM" .. side, cell.Icon, "BOTTOM" .. (mirrored and "LEFT" or "RIGHT"), out, 4)
	cell.Gain:SetPoint("BOTTOM" .. side, cell.Source, "BOTTOM" .. (mirrored and "LEFT" or "RIGHT"), mirrored and -6 or 6, 0)
	cell.textWidth = textWidth

	cell:SetScript("OnEnter", ShowCellTooltip)
	cell:SetScript("OnLeave", function() GameTooltip:Hide() end)
	cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	cell:SetScript("OnClick", ClickCell)
	-- The tooltip rebuilds itself when the client sends more of the item, or shift is pressed.
	cell.UpdateTooltip = ShowCellTooltip
	-- Over its map pin link's face (a rumour's, Adventure Mode: SetCellDoor), its own tooltip still.
	cell.ShowFaceTip = ShowCellTooltip
	return cell
end

--[[
	A slot showing a rumour (Adventure Mode) is the client's map pin link to the rumour's door (UI/QuestsPanel.lua's
	link faces, as the quest page's Show Start is): the player's click on it runs the client's own link handler,
	which sets the waypoint there and opens the map on it; the journal sets no waypoint and opens no map itself.
	The link lies over the whole slot, or over its picture alone where the slot has upgrades to pick (`entries`), so a
	click on its words still opens them (ClickCell): every button of a click on the link goes to the link. The
	face is made the first time a slot shows a rumour, and hidden while it shows anything else, so the slot's own
	clicks are its own again. No door placed, no face.
]]
local function SetCellDoor(cell, entry, entries)
	cell.point = entry and entry.rumour and ns.DungeonMap:DoorPoint(entry.instance) or nil
	if cell.point and rawget(cell, "LinkFace") == nil then cell.LinkFace = ns.QuestsPanel.CreateLinkFace(cell) or false end
	local face = rawget(cell, "LinkFace")
	if not face then return end
	local region = cell.point and ns.GearFinder:Pickable({ entries = entries or {} }) > 0 and cell.Icon or nil
	if region ~= rawget(cell, "faceRegion") then
		cell.faceRegion = region
		face:ClearAllPoints()
		face:SetAllPoints(region or cell)
	end
	ns.QuestsPanel.SetLinkFace(cell)
end

-- The second line's words, as wide as they need and no wider than the gain leaves them. They are
-- measured unbounded: GetStringWidth stops at the width the last words were given, so a longer
-- dungeon name would be cut to it.
local function SetSource(cell, text, gain)
	cell.Gain:SetText(gain or "")
	cell.Source:SetText(text)
	local room = cell.textWidth - ((gain and gain ~= "") and ((cell.Gain:GetStringWidth() or 0) + 6) or 0)
	local measure = cell.Source.GetUnboundedStringWidth or cell.Source.GetStringWidth
	cell.Source:SetWidth(math.max(1, math.min(measure(cell.Source) or room, room)))
end
GearPanel.SetSource = SetSource

-- (nil: the slot's empty picture, as the sheet draws it, undimmed: the same for an upgrade not seen yet)
local function SetIcon(cell, texture, quality)
	cell.Icon:SetTexture(texture or cell.emptyTexture)
	if quality and quality >= 2 then
		cell.IconBorder:SetVertexColor(QualityRGB(quality))
		cell.IconBorder:Show()
	else
		cell.IconBorder:Hide()
	end
end

-- The upgrade a cell shows, starred when the player picked it; or what is worn in its slot when
-- there is none.
local function SetCell(cell, shown, entries, picked)
	cell.entry, cell.others, cell.picked = shown, entries, picked and shown ~= nil or false
	cell.Picked:SetShown(cell.picked and cell.hasPickedArt)
	cell.emptyTexture = EmptySlotTexture(cell.def.inv)
	SetCellDoor(cell, shown, entries)
	-- Adventure Mode: "Something better" behind its slot's empty picture in its rarity's border (a ring's or a
	-- trinket's own slot; a two-hand weapon the main hand's); where it drops, or a rumour's place.
	if shown and Hidden(shown) then
		local quality = shown.info.quality
		SetIcon(cell, cell.emptyTexture, quality)
		cell.Level:SetText("")
		cell.Name:SetText(L.GEAR_ADVENTURE_BETTER)
		cell.Name:SetTextColor(QualityRGB(quality))
		if shown.rumour then
			SetSource(cell, RumourPlace(shown.instance))
		else
			SetSource(cell, string.format(L.ADVENTURE_LOOT_IN_DUNGEON, shown.instance.name))
		end
		cell.Source:SetTextColor(1, 1, 1)
		return
	end
	if shown then
		local compare = shown.compare
		SetIcon(cell, ns.Items:Icon(shown.itemID), shown.info.quality)
		cell.Level:SetText(compare.later and compare.minLevel or "")
		cell.Level:SetTextColor(LATER_COLOR[1], LATER_COLOR[2], LATER_COLOR[3])
		cell.Name:SetText(shown.info.name or "")
		cell.Name:SetTextColor(QualityRGB(shown.info.quality))
		SetSource(cell, shown.instance.name, GainText(compare))
		cell.Source:SetTextColor(1, 1, 1)
		return
	end
	local slotID = cell.def.slot
	local link = GetInventoryItemLink("player", slotID)
	cell.Level:SetText("")
	if link then
		local quality = GetInventoryItemQuality("player", slotID)
		SetIcon(cell, GetInventoryItemTexture("player", slotID), quality)
		cell.Name:SetText(link:match("%[(.-)%]") or "")
		cell.Name:SetTextColor(QualityRGB(quality))
	else
		SetIcon(cell, nil, nil)
		cell.Name:SetText(SLOT_LABELS[cell.def.key] or cell.def.key)
		cell.Name:SetTextColor(DIM_COLOR[1], DIM_COLOR[2], DIM_COLOR[3])
	end
	SetSource(cell, L.GEAR_NO_UPGRADE)
	cell.Source:SetTextColor(DIM_COLOR[1], DIM_COLOR[2], DIM_COLOR[3])
end

------------------------------------------------------------------------------------------
-- Picking a slot's upgrade
------------------------------------------------------------------------------------------

--[[
	A cell's top upgrades (Core/GearFinder.lua, Choices) in a box beside it, over the other column,
	as Pathfinder's Gear Finder opens a slot's list: each with its gain and where it drops, the
	one the slot shows marked. A click on one shows it in the slot; the box closes.
]]
local PICKER_WIDTH, PICK_ROW_WIDTH, PICK_ROW_HEIGHT = 268, 252, 42
-- Room above the rows (the slot, how many) and below them (the note, Clear).
local PICKER_TOP, PICKER_BOTTOM = 46, 38

local function ShowPickRowTooltip(row)
	ShowEntryTooltip(row, row.entry, "ANCHOR_RIGHT", Hidden(row.entry) and L.GEAR_ADVENTURE_PICK_CLICK or L.GEAR_TIP_PICK_CLICK,
		row.picked, row.key)
end

-- A row's click: shift and ctrl as on any item; a right click opens its loot, a plain one picks it.
local function ClickPickRow(row, button)
	local entry = row.entry
	if not entry then return end
	if not Hidden(entry) and ns.Gamepad:ItemClick(entry.link) then return end
	if button == "RightButton" then
		GearPanel:ClosePicker()
		OpenEntry(entry)
		return
	end
	GearPanel:Pick(row.key, entry.itemID)
end

local function CreatePickRow(picker, index)
	local row = CreateFrame("Button", nil, picker)
	row:SetSize(PICK_ROW_WIDTH, PICK_ROW_HEIGHT)
	row:SetPoint("TOP", 0, -(PICKER_TOP + (index - 1) * PICK_ROW_HEIGHT))
	row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	-- The one the slot shows, lit in gold.
	row.Selected = row:CreateTexture(nil, "BACKGROUND")
	row.Selected:SetAllPoints()
	row.Selected:SetColorTexture(1, 0.82, 0, 0.12)
	row.Hover = row:CreateTexture(nil, "HIGHLIGHT")
	row.Hover:SetAllPoints()
	if Atlas(row.Hover, "charactercreate-customize-dropdown-linemouseover-middle") then
		row.Hover:SetAlpha(0.15)
	else
		row.Hover:SetColorTexture(1, 1, 1, 0.06)
	end
	row.Icon = row:CreateTexture(nil, "ARTWORK")
	row.Icon:SetSize(32, 32)
	row.Icon:SetPoint("LEFT", 5, 0)
	row.IconBorder = row:CreateTexture(nil, "OVERLAY")
	row.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
	row.IconBorder:SetAllPoints(row.Icon)
	-- The level it waits for, in red on its icon, as on a cell.
	row.Level = row:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	row.Level:SetPoint("BOTTOMRIGHT", row.Icon, -2, 2)
	row.Level:SetTextColor(LATER_COLOR[1], LATER_COLOR[2], LATER_COLOR[3])
	row.Gain = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.Gain:SetPoint("TOPRIGHT", -6, -5)
	row.Gain:SetTextColor(GAIN_COLOR[1], GAIN_COLOR[2], GAIN_COLOR[3])
	row.Mark = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	row.Mark:SetPoint("BOTTOMRIGHT", -6, 6)
	row.Name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.Name:SetPoint("TOPLEFT", row.Icon, "TOPRIGHT", 8, -1)
	row.Name:SetPoint("RIGHT", row.Gain, "LEFT", -6, 0)
	row.Name:SetJustifyH("LEFT")
	row.Name:SetWordWrap(false)
	row.Source = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.Source:SetPoint("BOTTOMLEFT", row.Icon, "BOTTOMRIGHT", 8, 1)
	row.Source:SetPoint("RIGHT", row.Mark, "LEFT", -6, 0)
	row.Source:SetJustifyH("LEFT")
	row.Source:SetWordWrap(false)
	row:SetScript("OnClick", ClickPickRow)
	row:SetScript("OnEnter", ShowPickRowTooltip)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)
	row.UpdateTooltip = ShowPickRowTooltip
	return row
end

-- The box, in the look of the game's tooltips, over the slots.
local function CreatePicker(panel)
	local picker = ns.CreateFrameWithTemplate("Frame", nil, panel, "TooltipBackdropTemplate")
	picker:SetWidth(PICKER_WIDTH)
	picker:SetFrameLevel(panel:GetFrameLevel() + 30)
	picker:EnableMouse(true)
	picker:Hide()
	picker.Title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	picker.Title:SetPoint("TOPLEFT", 12, -10)
	picker.Count = picker:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	picker.Count:SetPoint("TOPLEFT", picker.Title, "BOTTOMLEFT", 0, -3)
	picker.Close = ns.CreateFrameWithTemplate("Button", nil, picker, "UIPanelCloseButtonNoScripts", "UIPanelCloseButton")
	picker.Close:SetPoint("TOPRIGHT", 0, 0)
	picker.Close:SetScript("OnClick", function() GearPanel:ClosePicker() end)
	picker.Rows = {}
	-- The top ones, and the slot's own pick if it is further down.
	for index = 1, ns.GearFinder.TOP_PICKS + 1 do picker.Rows[index] = CreatePickRow(picker, index) end
	picker.Clear = ns.CreateFrameWithTemplate("Button", nil, picker, "UIPanelButtonTemplate")
	picker.Clear:SetSize(100, 22)
	picker.Clear:SetPoint("BOTTOMRIGHT", -8, 8)
	picker.Clear:SetText(L.GEAR_PICK_CLEAR)
	picker.Clear:SetScript("OnClick", function() GearPanel:Pick(picker.key, nil) end)
	picker.Kept = picker:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	picker.Kept:SetPoint("BOTTOMLEFT", 12, 10)
	picker.Kept:SetPoint("RIGHT", picker.Clear, "LEFT", -8, 0)
	picker.Kept:SetJustifyH("LEFT")
	picker.Kept:SetText(L.GEAR_PICK_KEPT)
	return picker
end

-- Beside its cell, over the other column (the ranged slot's, over the left pane), inside the panel.
local function PlacePicker(panel, picker, def)
	local column, row = PLACES[def.key][1], PLACES[def.key][2]
	local panelHeight = panel:GetHeight()
	if not panelHeight or panelHeight <= 0 then panelHeight = PANE_HEIGHT + 2 * EDGE end
	local top = EDGE + FIRST_ROW + (row - 1) * ROW_STEP - 4
	top = math.max(EDGE, math.min(top, panelHeight - picker:GetHeight() - EDGE))
	local cellWidth = SLOT_SIZE + TEXT_GAP + TEXT_WIDTH
	picker:ClearAllPoints()
	if column == 1 then
		picker:SetPoint("TOPLEFT", EDGE + LEFT_X + cellWidth + 6, -top)
	elseif column == 2 then
		picker:SetPoint("TOPRIGHT", -(EDGE + RIGHT_WIDTH + RIGHT_X + cellWidth + 6), -top)
	else
		picker:SetPoint("TOPRIGHT", -(EDGE + RIGHT_WIDTH - SIDE_X + 6), -top)
	end
end

-- The box for its cell, from the finder's cells; closed when the slot has nothing left to pick.
function GearPanel:PaintPicker(cells)
	local panel = self.panel
	local picker = panel and rawget(panel, "Picker")
	if not (picker and picker:IsShown()) then return end
	local finder = ns.GearFinder
	local cell
	for _, each in ipairs(cells or finder:Cells()) do
		if each.def.key == picker.key then cell = each end
	end
	-- (nothing left to pick: no upgrade, or rumours alone, which are never picked)
	local choices = cell and cell.shown and finder:Choices(cell) or {}
	if #choices == 0 then
		picker:Hide()
		return
	end
	local total = finder:Pickable(cell)
	picker.Title:SetText(SLOT_LABELS[cell.def.key] or cell.def.key)
	if total <= 1 then
		picker.Count:SetText(L.GEAR_PICK_ONE)
	elseif total <= finder.TOP_PICKS then
		picker.Count:SetText(string.format(L.GEAR_PICK_ALL, total))
	else
		picker.Count:SetText(string.format(L.GEAR_PICK_TOP, finder.TOP_PICKS, total))
	end
	for index, row in ipairs(picker.Rows) do
		local entry = choices[index]
		row.entry, row.key = entry, cell.def.key
		if entry then
			local shown = entry.itemID == cell.shown.itemID
			row.picked = shown and cell.picked
			-- (one not seen to drop yet, Adventure Mode: its slot and rarity alone, by the slot's empty picture)
			local hidden = Hidden(entry)
			row.Icon:SetTexture(hidden and EmptySlotTexture(cell.def.inv) or ns.Items:Icon(entry.itemID))
			local quality = entry.info.quality
			row.IconBorder:SetShown(quality ~= nil and quality >= 2)
			if quality then row.IconBorder:SetVertexColor(QualityRGB(quality)) end
			row.Name:SetText(hidden and L.GEAR_ADVENTURE_BETTER or entry.info.name or "")
			row.Name:SetTextColor(QualityRGB(quality))
			row.Source:SetText(entry.instance.name .. " \194\183 " .. SourceName(entry))
			row.Level:SetText(not hidden and entry.compare.later and entry.compare.minLevel or "")
			row.Gain:SetText(hidden and "" or GainText(entry.compare))
			row.Mark:SetText(shown and (cell.picked and L.GEAR_PICK_YOURS or L.GEAR_PICK_BIGGEST) or "")
			row.Selected:SetShown(shown)
			row:Show()
		else
			row.picked = nil
			row:Hide()
		end
	end
	picker.Clear:SetShown(cell.picked)
	picker:SetHeight(PICKER_TOP + #choices * PICK_ROW_HEIGHT + PICKER_BOTTOM)
	PlacePicker(panel, picker, cell.def)
end

-- Opens a cell's box, or closes it when it is that cell's already.
function GearPanel:TogglePicker(cellFrame)
	local panel = self.panel
	local picker = rawget(panel, "Picker")
	if not picker then
		picker = CreatePicker(panel)
		panel.Picker = picker
	end
	if picker:IsShown() and picker.key == cellFrame.def.key then
		picker:Hide()
		return
	end
	picker.key = cellFrame.def.key
	picker:Show()
	self:PaintPicker()
end

function GearPanel:ClosePicker()
	local picker = self.panel and rawget(self.panel, "Picker")
	if picker then picker:Hide() end
end

-- Shows upgrade `itemID` in cell `key` (nil: its biggest again); the suggested dungeon follows.
function GearPanel:Pick(key, itemID)
	if not key then return end
	ns.GearFinder:SetPick(key, itemID)
	self:ClosePicker()
	self.panel.suggestIndex = 1
	self:Redraw(self.panel)
end

------------------------------------------------------------------------------------------
-- The right pane: the suggested dungeon
------------------------------------------------------------------------------------------

-- A row's tooltip: its upgrade's, or for the last row of a long list, the slots it stands for.
-- An upgrade's gain as the rows give it: "?" for one shown by its slot alone (Adventure Mode).
local function RowGain(entry)
	if Hidden(entry) then return "?" end
	return GainText(entry.compare)
end

local function ShowRowTooltip(row)
	if row.entry then
		ShowEntryTooltip(row, row.entry, "ANCHOR_LEFT", Hidden(row.entry) and L.GEAR_ADVENTURE_ROW_CLICK or nil, nil, row.slotKey)
	elseif row.more then
		GameTooltip:SetOwner(row, "ANCHOR_LEFT")
		for index, entry in ipairs(row.more.entries) do
			GameTooltip:AddDoubleLine(SLOT_LABELS[row.more.slots[index]] or row.more.slots[index], RowGain(entry),
				1, 0.82, 0, GAIN_COLOR[1], GAIN_COLOR[2], GAIN_COLOR[3])
		end
		GameTooltip:Show()
	end
end

-- A row as the sheet lists a stat: gold label, white value, a stripe behind every other one.
local function CreateRow(parent, index)
	local row = CreateFrame("Button", nil, parent)
	row:SetSize(ROW_WIDTH, ROW_HEIGHT)
	row.Stripe = row:CreateTexture(nil, "BACKGROUND")
	row.Stripe:SetPoint("CENTER")
	row.Stripe:SetShown(index % 2 == 1 and Atlas(row.Stripe, "UI-Character-Info-Line-Bounce2", true))
	row.Label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.Label:SetPoint("LEFT", 11, 0)
	row.Label:SetJustifyH("LEFT")
	row.Value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.Value:SetPoint("RIGHT", -8, 0)
	row.Value:SetTextColor(GAIN_COLOR[1], GAIN_COLOR[2], GAIN_COLOR[3])
	row.Hover = row:CreateTexture(nil, "HIGHLIGHT")
	row.Hover:SetAllPoints()
	if Atlas(row.Hover, "charactercreate-customize-dropdown-linemouseover-middle") then
		row.Hover:SetAlpha(0.1)
	else
		row.Hover:SetColorTexture(1, 1, 1, 0.06)
	end
	row:SetScript("OnEnter", ShowRowTooltip)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)
	row:SetScript("OnClick", function(self) ClickEntry(self.entry) end)
	row.UpdateTooltip = ShowRowTooltip
	return row
end

-- The spellbook's page arrows, which the character panel uses for its own.
local function CreatePageButton(parent, direction)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(28, 28)
	local name = direction < 0 and "Prev" or "Next"
	button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. name .. "Page-Up")
	button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. name .. "Page-Down")
	button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. name .. "Page-Disabled")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	return button
end

local function CreateSide(panel)
	local side = CreateFrame("Frame", nil, panel)
	side:SetPoint("TOPRIGHT", -EDGE, -EDGE)
	side:SetPoint("BOTTOMRIGHT", -EDGE, EDGE)
	side:SetWidth(RIGHT_WIDTH)

	side.Background = side:CreateTexture(nil, "BACKGROUND", nil, -8)
	side.Background:SetAllPoints()
	if not Atlas(side.Background, "UI-Character-Info-Stat-BG") then side.Background:SetColorTexture(0.05, 0.05, 0.05, 1) end
	-- The class's own tint, as behind the sheet's stats.
	side.ClassBackground = side:CreateTexture(nil, "BACKGROUND", nil, -7)
	side.ClassBackground:SetPoint("TOPLEFT")
	side.ClassBackground:SetShown(AtlasCut(side.ClassBackground,
		string.format("UI-Character-Info-%s-BG", ns.ItemScore:Class() or ""), RIGHT_WIDTH, PANE_HEIGHT))
	-- The line between the panes.
	side.Divider = side:CreateTexture(nil, "OVERLAY")
	if Atlas(side.Divider, "common-framedivider", true) then
		side.Divider:SetPoint("TOPLEFT", -6, -1)
		side.Divider:SetPoint("BOTTOMLEFT", -6, 0)
	else
		side.Divider:Hide()
	end

	-- What the pane shows: the suggested dungeon, or the stat weights (GearPanel:ShowWeights).
	local content = CreateFrame("Frame", nil, side)
	content:SetAllPoints()
	side.Suggestion = content

	-- "Suggested dungeon", on the sheet's category bar.
	side.Header = CreateFrame("Frame", nil, content)
	side.Header:SetSize(197, 40)
	side.Header:SetPoint("TOP", 0, -8)
	side.Header.Background = side.Header:CreateTexture(nil, "BACKGROUND")
	side.Header.Background:SetAllPoints()
	side.Header.Background:SetShown(Atlas(side.Header.Background, "UI-Character-Info-Title"))
	side.Header.Title = side.Header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	side.Header.Title:SetPoint("CENTER", 0, 1)
	side.Header.Title:SetText(L.GEAR_SUGGESTED)

	-- The dungeon, as its button on the Dungeons tab: a click opens it.
	side.Dungeon = ns.CreateInstanceButton(content)
	side.Dungeon:SetPoint("TOP", side.Header, "BOTTOM", 0, -4)

	-- "5 upgrades here", in the sheet's item-level box.
	side.Count = CreateFrame("Frame", nil, content)
	side.Count:SetSize(ROW_WIDTH, 29)
	side.Count:SetPoint("TOP", side.Dungeon, "BOTTOM", 0, -4)
	side.Count.Background = side.Count:CreateTexture(nil, "BORDER")
	side.Count.Background:SetAllPoints()
	side.Count.Background:SetShown(Atlas(side.Count.Background, "UI-Character-Info-ItemLevel-Bounce"))
	side.Count.Text = side.Count:CreateFontString(nil, "OVERLAY", ns.Font("Game15Font_o1", "GameFontNormalLarge"))
	side.Count.Text:SetPoint("CENTER", 0, -1)
	side.Count.Text:SetTextColor(GAIN_COLOR[1], GAIN_COLOR[2], GAIN_COLOR[3])

	side.Rows = {}
	for index = 1, SIDE_ROWS do
		local row = CreateRow(content, index)
		row:SetPoint("TOP", index == 1 and side.Count or side.Rows[index - 1], "BOTTOM", 0, index == 1 and -2 or 0)
		side.Rows[index] = row
	end

	-- The other dungeons with upgrades.
	side.Previous = CreatePageButton(content, -1)
	side.Next = CreatePageButton(content, 1)
	side.Of = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	side.Of:SetPoint("TOP", side.Rows[SIDE_ROWS], "BOTTOM", 0, -12)
	side.Previous:SetPoint("RIGHT", side.Of, "LEFT", -6, 0)
	side.Next:SetPoint("LEFT", side.Of, "RIGHT", 6, 0)
	for _, button in ipairs({ side.Previous, side.Next }) do
		local direction = button == side.Previous and -1 or 1
		button:SetScript("OnClick", function()
			ns.PlaySoundKit("IG_ABILITY_PAGE_TURN")
			panel.suggestIndex = (panel.suggestIndex or 1) + direction
			GearPanel:Redraw(panel)
		end)
	end

	side.None = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	side.None:SetPoint("TOP", side.Header, "BOTTOM", 0, -40)
	side.None:SetWidth(RIGHT_WIDTH - 2 * SIDE_X)
	side.None:SetText(L.GEAR_NONE)
	return side
end

--[[
	The right pane's rumour (Adventure Mode: the suggested dungeon not entered yet), made the first time one shows.
	In the dungeon's button's place, a card in that button's look, on one of the game's loading screens (RUMOUR_ART),
	lightly shaded, and with no name: "A rumor" where a dungeon button has its name, its level range and its place
	where the button has its own. Under its upgrades' count, the door's line of rumour and Show on map: the client's
	map pin link to its door, over the button (UI/QuestsPanel.lua's Show Start). The rows of slots stand aside: the
	slots show them.
]]
local function ShowMapTip(button)
	GameTooltip:SetOwner(button, "ANCHOR_LEFT")
	GameTooltip:SetText(L.ADVENTURE_DOOR_TITLE, 1, 1, 1)
	if button.place then GameTooltip:AddLine(button.place, 1, 0.82, 0) end
	GameTooltip:AddLine(button.point and L.GEAR_ADVENTURE_MAP_CLICK or L.GEAR_ADVENTURE_NO_DOOR, 0.5, 0.5, 0.5, true)
	GameTooltip:Show()
end

local function CreateRumour(side)
	local content = side.Suggestion
	local card = ns.CreateInstanceButton(content)
	card:SetPoint("TOP", side.Header, "BOTTOM", 0, -4)
	-- Nothing to open: the journal's page of a rumour is shut (UI/Journal.lua), and its door is Show on map's.
	card:SetScript("OnClick", nil)
	card:EnableMouse(false)
	card.Untested:Hide()
	card.Forever:Hide()
	local art = RUMOUR_ARTS[RUMOUR_ART]
	card.Art:SetTexture(RUMOUR_ART)
	card.Art:SetTexCoord(art[2], art[3], art[4], art[5])
	ns.TintInstanceArt(card.Art, nil, RUMOUR_SHADE)
	-- Where the button has its name (ns.CreateInstanceButton), in its font.
	card.Name:SetText(L.ADVENTURE_DOOR_TITLE)
	card.Location:ClearAllPoints()
	card.Location:SetPoint("BOTTOMRIGHT", -7, 7)
	card.Location:SetWidth(112)
	card.Location:Show()
	side.Rumour = card

	side.RumourLine = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	side.RumourLine:SetPoint("TOP", side.Count, "BOTTOM", 0, -8)
	side.RumourLine:SetWidth(ROW_WIDTH - 12)
	side.RumourLine:SetJustifyH("CENTER")
	if side.RumourLine.SetMaxLines then side.RumourLine:SetMaxLines(5) end

	local button = ns.QuestsPanel:CreateMapButton(content, L.GEAR_ADVENTURE_SHOW_MAP)
	button:SetSize(150, 22)
	button:SetPoint("TOP", side.RumourLine, "BOTTOM", 0, -10)
	button:SetScript("OnEnter", ShowMapTip)
	button.ShowFaceTip = ShowMapTip
	side.ShowMap = button
end

-- The rumour's card, line and Show on map for `instance`.
local function SetRumour(side, instance)
	local card = side.Rumour
	if instance.levelMin and instance.levelMax and instance.levelMin ~= instance.levelMax then
		card.Range:SetText(instance.levelMin .. "-" .. instance.levelMax)
	else
		card.Range:SetText(instance.levelMin or "")
	end
	local place, point = RumourZone(instance)
	card.Location:SetText(place or "")
	side.RumourLine:SetText(ns.Discovery:DoorRumour(instance))
	ns.QuestsPanel:SetMapButton(side.ShowMap, point, ns.Discovery:DoorName(instance), RumourPlace(instance))
end

local function SetSide(side, suggestions, index)
	local dungeon = suggestions[index]
	local rumour = dungeon ~= nil and dungeon.rumour == true
	if rumour and not rawget(side, "Rumour") then CreateRumour(side) end
	side.Dungeon:SetShown(dungeon ~= nil and not rumour)
	side.Count:SetShown(dungeon ~= nil)
	if rawget(side, "Rumour") then
		for _, region in ipairs({ side.Rumour, side.RumourLine, side.ShowMap }) do region:SetShown(rumour) end
	end
	local paged = dungeon ~= nil and #suggestions > 1
	side.Previous:SetShown(paged)
	side.Next:SetShown(paged)
	side.Of:SetShown(paged)
	side.None:SetShown(dungeon == nil)
	for _, row in ipairs(side.Rows) do
		row.entry, row.more = nil, nil
		row:Hide()
	end
	if not dungeon then return end

	side.Count.Text:SetText(dungeon.count == 1 and L.GEAR_UPGRADE_HERE or string.format(L.GEAR_UPGRADES_HERE, dungeon.count))
	side.Of:SetText(string.format(L.GEAR_DUNGEON_OF, index, #suggestions))
	if rumour then
		SetRumour(side, dungeon.instance)
		return
	end
	ns.SetInstanceButton(side.Dungeon, dungeon.instance)
	-- One row a slot; past the last row, how many more.
	local count = #dungeon.slots
	local rows = count > SIDE_ROWS and SIDE_ROWS - 1 or count
	for rowIndex = 1, rows do
		local row = side.Rows[rowIndex]
		local entry = dungeon.entries[rowIndex]
		row.entry, row.slotKey = entry, dungeon.slots[rowIndex]
		row.Label:SetText(SLOT_LABELS[dungeon.slots[rowIndex]] or dungeon.slots[rowIndex])
		row.Value:SetText(RowGain(entry))
		row:Show()
	end
	if count > rows then
		local row = side.Rows[SIDE_ROWS]
		row.more = { slots = {}, entries = {} }
		for index = rows + 1, count do
			row.more.slots[#row.more.slots + 1] = dungeon.slots[index]
			row.more.entries[#row.more.entries + 1] = dungeon.entries[index]
		end
		row.Label:SetText(string.format(L.GEAR_MORE_SLOTS, count - rows))
		row.Value:SetText("")
		row:Show()
	end
end

------------------------------------------------------------------------------------------
-- The spec menu
------------------------------------------------------------------------------------------

local function SpecText()
	local IS = ns.ItemScore
	local spec, why = IS:Spec()
	if not spec then return "" end
	local label = IS:SpecLabel(spec)
	if IS:CustomWeights(spec) then return string.format(L.GEAR_WHY_CUSTOM, label) end
	if why == "talents" then return string.format(L.GEAR_WHY_TALENTS, label) end
	if why == "levelling" then return string.format(L.GEAR_WHY_LEVELLING, label) end
	return label
end

local function AutomaticText()
	local IS = ns.ItemScore
	return string.format(L.GEAR_AUTO, IS:SpecLabel(IS:AutoSpec()))
end

--[[
	The spec menu: automatic, then the class's specs; with `onEdit`, a last entry that opens the
	stat weights. Built for the Gear Finder tab and the weights editors alike.
]]
function GearPanel.CreateSpecMenu(parent, width, onEdit)
	local IS = ns.ItemScore
	-- The journal's own dropdown (UI/Art.lua's ns.Menus), never the game's: one the journal built there tainted the
	-- game's unit menus after it (the owner's taint log of 2026-11-08).
	local dropdown = ns.Menus:NewDropdown(parent, width)
	dropdown:SetupMenu(function(_, rootDescription)
		rootDescription:CreateRadio(AutomaticText(),
			function() return IS:PickedSpec() == nil end, function() IS:SetSpec(nil) end)
		for _, spec in ipairs(IS:Specs()) do
			rootDescription:CreateRadio(spec.label,
				function() return IS:PickedSpec() == spec.key end, function() IS:SetSpec(spec.key) end)
		end
		if onEdit then
			rootDescription:CreateDivider()
			rootDescription:CreateButton(L.WEIGHTS_EDIT, onEdit)
		end
	end)
	-- The closed menu says why: "Retribution, while levelling".
	dropdown:SetSelectionText(function() return SpecText() end)
	return dropdown
end

-- After a change: the closed menu's words, and its ticks.
function GearPanel.UpdateSpecMenu(dropdown)
	dropdown:GenerateMenu()
end

-- In the left pane's top right corner, where the character panel's reputation page has its filter.
local function CreateSpecMenu(panel)
	local right = -(EDGE + RIGHT_WIDTH + 14)
	panel.ScoringLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local dropdown = GearPanel.CreateSpecMenu(panel, 190, function() GearPanel:ShowWeights(panel, true) end)
	dropdown:SetPoint("TOPRIGHT", right, -16)
	panel.ScoringLabel:SetPoint("RIGHT", dropdown, "LEFT", -8, 0)
	panel.ScoringLabel:SetText(L.GEAR_SCORING)
	return dropdown
end

------------------------------------------------------------------------------------------
-- The panel
------------------------------------------------------------------------------------------

function GearPanel:Build(panel)
	-- The character sheet's backgrounds in place of the journal's backdrop.
	panel.Background:Hide()
	panel.LeftBackground = panel:CreateTexture(nil, "BACKGROUND", nil, -8)
	panel.LeftBackground:SetPoint("TOPLEFT", EDGE, -EDGE)
	panel.LeftBackground:SetPoint("BOTTOMRIGHT", -(EDGE + RIGHT_WIDTH), EDGE)
	if not Atlas(panel.LeftBackground, "UI-Character-Info-General-BG") then
		panel.LeftBackground:SetColorTexture(0.06, 0.05, 0.04, 1)
	end

	panel.Title:SetText(L.GEAR_TITLE)
	panel.Preview = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	panel.Preview:SetPoint("LEFT", panel.Title, "RIGHT", 8, -1)
	panel.Preview:SetText(L.GEAR_PREVIEW)

	panel.Status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.Status:SetPoint("TOPLEFT", 22, -44)
	panel.Status:SetJustifyH("LEFT")

	panel.Spec = CreateSpecMenu(panel)
	panel.Side = CreateSide(panel)
	panel.Cells = {}
	for _, def in ipairs(ns.GearFinder.CELLS) do
		panel.Cells[#panel.Cells + 1] = CreateCell(panel, def)
	end
	panel.suggestIndex = 1

	ns.GearFinder.IsShowing = function() return panel:IsVisible() end
	ns.GearFinder:OnUpdate(function()
		if panel:IsVisible() then GearPanel:Redraw(panel) end
	end)
	-- Searched on the next frame: a journal opened straight onto another page hides this at once.
	-- Shown again and again in one frame (a journal toggled quickly), it still searches once.
	panel:HookScript("OnShow", function()
		panel.suggestIndex = 1
		-- Opened anew, the tab shows its upgrades; /aegis weights turns it to the weights after.
		if rawget(panel.Side, "EditorHolder") then GearPanel:ShowWeights(panel, false) end
		if panel.searchPending then return end
		panel.searchPending = true
		C_Timer.After(0, function()
			panel.searchPending = nil
			if panel:IsVisible() then ns.GearFinder:Refresh() end
		end)
	end)
	panel:HookScript("OnHide", function() GearPanel:ClosePicker() end)
	self.panel = panel
end

--[[
	The right pane's other face: the stat weights (UI/WeightsEditor.lua), built when first shown,
	above the ranged slot; Back returns to the suggested dungeon.
]]
function GearPanel:ShowWeights(panel, shown)
	local side = panel.Side
	if shown and not rawget(side, "Editor") then
		local holder = CreateFrame("Frame", nil, side)
		holder:SetPoint("TOPLEFT")
		holder:SetPoint("BOTTOMRIGHT", 0, PANE_HEIGHT - (FIRST_ROW + 7 * ROW_STEP) + 8)
		side.Editor = ns.WeightsEditor:Create(holder, {
			extra = { text = L.WEIGHTS_BACK, onClick = function() GearPanel:ShowWeights(panel, false) end },
		})
		side.EditorHolder = holder
	end
	if rawget(side, "EditorHolder") then side.EditorHolder:SetShown(shown) end
	side.Suggestion:SetShown(not shown)
	if shown then side.Editor:Refresh() end
end

function GearPanel:Redraw(panel)
	local finder = ns.GearFinder
	local cells = finder:Cells()
	for index, cell in ipairs(cells) do SetCell(panel.Cells[index], cell.shown, cell.entries, cell.picked) end
	self:PaintPicker(cells)
	local suggestions = finder:Suggest(cells)
	local count = #suggestions
	if count > 0 then
		panel.suggestIndex = ((panel.suggestIndex or 1) - 1) % count + 1
	else
		panel.suggestIndex = 1
	end
	SetSide(panel.Side, suggestions, panel.suggestIndex)

	local _, missing, looked = finder:Results()
	local status = looked == 1 and L.GEAR_LOOKING_ONE or string.format(L.GEAR_LOOKING, looked)
	if missing > 0 then
		status = status .. " " .. (missing == 1 and L.GEAR_LOADING_ONE or string.format(L.GEAR_LOADING, missing))
	end
	panel.Status:SetText(status)
	if panel.Spec then GearPanel.UpdateSpecMenu(panel.Spec) end
end
