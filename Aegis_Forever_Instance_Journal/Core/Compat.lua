local _, ns = ...

--[[
	What this client offers, asked rather than assumed.

	Forever runs the modern engine but ships its own subset of Blizzard's interface: the
	journal's own addon never loads here, and some templates other clients have are gated
	away. Everything the journal builds goes through these helpers, so a missing piece
	falls back to the next best one instead of stopping the window from opening.
]]

function ns.HasTemplate(name)
	if not name then return false end
	if C_XMLUtil and C_XMLUtil.GetTemplateInfo then
		local ok, info = pcall(C_XMLUtil.GetTemplateInfo, name)
		if ok then return info ~= nil end
	end
	-- No way to ask: let CreateFrame decide.
	return true
end

-- Creates the frame from the first template in the list that this client has.
function ns.CreateFrameWithTemplate(frameType, name, parent, ...)
	for index = 1, select("#", ...) do
		local template = select(index, ...)
		if ns.HasTemplate(template) then
			local ok, frame = pcall(CreateFrame, frameType, name, parent, template)
			if ok and frame then return frame, template end
		end
	end
	return CreateFrame(frameType, name, parent), nil
end

-- A texture made from a virtual texture template, or nil when the client lacks it.
function ns.CreateTextureFromTemplate(parent, layer, template, subLevel)
	if not ns.HasTemplate(template) then return nil end
	local ok, texture = pcall(parent.CreateTexture, parent, nil, layer, template, subLevel)
	if ok then return texture end
	return nil
end

-- Registers each event this client has; one it lacks is skipped instead of raising an error.
function ns.RegisterEvents(frame, ...)
	for index = 1, select("#", ...) do
		pcall(frame.RegisterEvent, frame, (select(index, ...)))
	end
end

function ns.UnregisterEvents(frame, ...)
	for index = 1, select("#", ...) do
		pcall(frame.UnregisterEvent, frame, (select(index, ...)))
	end
end

function ns.AtlasExists(name)
	if not (C_Texture and C_Texture.GetAtlasInfo) then return false end
	local ok, info = pcall(C_Texture.GetAtlasInfo, name)
	return ok and info ~= nil
end

local fileProbe = UIParent:CreateTexture()
fileProbe:Hide()

-- Whether the client has a file. Texture paths are given without their extension; the client's
-- file list may know them only with it, so both are asked.
function ns.FileExists(path)
	if type(GetFileIDFromPath) == "function" then
		local answered = false
		for _, candidate in ipairs({ path, path .. ".blp" }) do
			local ok, fileID = pcall(GetFileIDFromPath, candidate)
			if ok then
				answered = true
				if fileID ~= nil and fileID ~= 0 then return true end
			end
		end
		if answered then return false end
	end
	fileProbe:SetTexture(nil)
	fileProbe:SetTexture(path)
	local fileID = fileProbe:GetTextureFileID()
	return fileID ~= nil and fileID ~= 0
end

-- Uses the atlas when the client has it, the file when it has that, or reports false.
function ns.SetAtlasOrFile(texture, atlas, file)
	if atlas and ns.AtlasExists(atlas) then
		texture:SetAtlas(atlas)
		return true
	end
	if file and ns.FileExists(file) then
		texture:SetTexture(file)
		return true
	end
	return false
end

-- Fills a texture with a gradient from color at fromAlpha on its bottom (or left) edge to
-- toColor (or the same colour) at toAlpha on the top (or right), with whichever gradient
-- call this client has.
function ns.Gradient(texture, orientation, color, fromAlpha, toAlpha, toColor)
	toColor = toColor or color
	local r, g, b = color[1], color[2], color[3]
	local r2, g2, b2 = toColor[1], toColor[2], toColor[3]
	texture:SetColorTexture(1, 1, 1, 1)
	if texture.SetGradient and type(CreateColor) == "function" then
		if pcall(texture.SetGradient, texture, orientation, CreateColor(r, g, b, fromAlpha), CreateColor(r2, g2, b2, toAlpha)) then
			return
		end
	end
	if texture.SetGradientAlpha and pcall(texture.SetGradientAlpha, texture, orientation, r, g, b, fromAlpha, r2, g2, b2, toAlpha) then
		return
	end
	texture:SetColorTexture((r + r2) / 2, (g + g2) / 2, (b + b2) / 2, (fromAlpha + toAlpha) / 2)
end

--[[
	A scroll frame with retail's thin scroll bar, built the way Blizzard's own templates do:
	the bar's offsets are set on the frame, then ScrollFrame_OnLoad attaches it and wires the
	mouse wheel. Content goes on scroll.Child. Without that helper, the wheel still scrolls.
]]
function ns.CreateScrollFrame(parent, barX, barTopY, barBottomY)
	local scroll = CreateFrame("ScrollFrame", nil, parent)
	scroll.scrollBarX, scroll.scrollBarTopY, scroll.scrollBarBottomY = barX or -10, barTopY or -10, barBottomY or 10
	scroll.scrollBarHideIfUnscrollable = true
	scroll.scrollBarHideTrackIfThumbExceedsTrack = true

	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(1, 1)
	scroll:SetScrollChild(child)
	scroll.Child = child

	if type(ScrollFrame_OnLoad) == "function" and pcall(ScrollFrame_OnLoad, scroll) then
		return scroll
	end
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self, delta)
		local target = self:GetVerticalScroll() - delta * 30
		self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange(), target)))
	end)
	return scroll
end

-- A font object by name, or the fallback when this client lacks it.
function ns.Font(name, fallback)
	if _G[name] then return name end
	return fallback
end

function ns.PlaySoundKit(key)
	if SOUNDKIT and SOUNDKIT[key] then PlaySound(SOUNDKIT[key]) end
end

local COIN_ICON = "%d|TInterface\\MoneyFrame\\UI-%sIcon:0:0:2:0|t"

--[[
	The currencies a reward can cost besides coins, by the English name its captured cost gives
	("180 Merchant's Favor"): the currency's id, and the icon for a client that cannot say. From the
	client's own currency table (CurrencyTypes, Forever build 1.60.1.70450): Merchant's Favor is the
	trade camps' currency, which the Azeroth Commerce Authority's and Durotar Supply and Logistics'
	quartermasters take.
	A few are items, not currencies (itemID in place of id): Tarnished Undermine Real, item 226404, icon 133799 (the
	client's item tables, ItemSparse and Item, Forever build 1.60.1.70399, read 2026-11-12), which Pix Xizzix in Booty
	Bay takes for his wares (Core/Registry.lua's currency vendors). Carved Centaur Totem, item 254432, icon 442743 (the
	same tables, read 2026-11-13), which Gorhak, the Magram Clan Quartermaster in Desolace, takes for his recipes.
	note: the locale key of a line saying where the currency comes from, on its card's tooltip and its page; its %s is
	the currency's name as the client writes it.
]]
local CURRENCIES = {
	["Merchant's Favor"] = { id = 3402, icon = 135725 },
	["Tarnished Undermine Real"] = { itemID = 226404, icon = 133799 },
	["Carved Centaur Totem"] = { itemID = 254432, icon = 442743, note = "CURRENCY_NOTE_CENTAUR_TOTEM" },
}
local CURRENCY_TEXT = "%s|T%s:0:0:2:0|t"

-- An item currency's name and icon as the client has them: the icon at once, the name once the server has
-- described the item (nil until then: asked again next time).
local function ItemCurrency(currency)
	local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
	local okIcon, _, _, _, _, icon = false, nil, nil, nil, nil, nil
	if type(getInstant) == "function" then okIcon, _, _, _, _, icon = pcall(getInstant, currency.itemID) end
	local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
	local okName, name = false, nil
	if type(getInfo) == "function" then okName, name = pcall(getInfo, currency.itemID) end
	return okName and type(name) == "string" and name ~= "" and name or nil, okIcon and icon or nil
end

-- The client's word for a currency: its name, in the client's language, and its icon.
local function CurrencyIcon(currency)
	if currency.clientName == nil then
		if currency.itemID then
			local name, icon = ItemCurrency(currency)
			currency.clientIcon = icon
			if not name then return icon or currency.icon end
			currency.clientName = name
			return currency.clientIcon or currency.icon
		end
		local getInfo = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo
		local ok, info = false, nil
		if type(getInfo) == "function" then ok, info = pcall(getInfo, currency.id) end
		info = ok and type(info) == "table" and info or {}
		currency.clientName = info.name or false
		currency.clientIcon = info.iconFileID
	end
	return currency.clientIcon or currency.icon
end

local function FindCurrency(name)
	if CURRENCIES[name] then return CURRENCIES[name] end
	for _, currency in pairs(CURRENCIES) do
		CurrencyIcon(currency)
		if currency.clientName == name then return currency end
	end
end

-- A cost ("180 Merchant's Favor") as the merchant shows it: each amount with its currency's icon.
-- Nil unless the journal knows every currency in it.
function ns.CostIcons(cost)
	local parts = {}
	for part in tostring(cost or ""):gmatch("[^+]+") do
		local amount, name = part:match("^%s*(%d+)%s+(.-)%s*$")
		local currency = name and FindCurrency(name)
		if not currency then return nil end
		parts[#parts + 1] = CURRENCY_TEXT:format(amount, CurrencyIcon(currency))
	end
	return #parts > 0 and table.concat(parts, " ") or nil
end

-- A currency a cost names in the client's words ("Angelaufener Real der Untermine" on a German client), by the
-- English name the journal keys it by; a name the journal does not know comes back as it is.
function ns.CurrencyKey(name)
	if name == nil or CURRENCIES[name] then return name end
	local currency = FindCurrency(name)
	for key, known in pairs(CURRENCIES) do
		if known == currency then return key end
	end
	return name
end

--[[
	A currency a cost names, for its vendors' page (Core/Registry.lua's currency vendors), by its English name:
	ns.CurrencyIcon its icon (nil for one the journal does not know), ns.CurrencyName its name as the client writes
	it (else the English), ns.CurrencyCount how many the player has, bank too (nil where the client cannot say).
]]
function ns.CurrencyIcon(name)
	local currency = CURRENCIES[name]
	return currency and CurrencyIcon(currency) or nil
end

function ns.CurrencyName(name)
	local currency = CURRENCIES[name]
	if currency then CurrencyIcon(currency) end
	return currency and currency.clientName or name
end

-- Where a currency comes from, in the player's language, naming it as the client does (ns.CurrencyName, the
-- English until the server has described the item); nil for one the journal says nothing of.
function ns.CurrencyNote(name)
	local currency = CURRENCIES[name]
	return currency and currency.note and string.format(ns.L[currency.note], ns.CurrencyName(name)) or nil
end

function ns.CurrencyCount(name)
	local currency = CURRENCIES[name]
	if not currency then return nil end
	if currency.itemID then
		local count = (C_Item and C_Item.GetItemCount) or GetItemCount
		local ok, have = false, nil
		if type(count) == "function" then ok, have = pcall(count, currency.itemID, true) end
		return ok and type(have) == "number" and have or nil
	end
	local getInfo = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo
	local ok, info = false, nil
	if type(getInfo) == "function" then ok, info = pcall(getInfo, currency.id) end
	return ok and type(info) == "table" and type(info.quantity) == "number" and info.quantity or nil
end

-- Coins as icons. The Forever client keeps GetCoinTextureString under C_CurrencyInfo;
-- GetMoneyString (SharedXML), the old global and our own icons are fallbacks.
function ns.MoneyText(copper)
	local formatters = {
		C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString,
		GetMoneyString,
		GetCoinTextureString,
	}
	for index = 1, 3 do
		local format = formatters[index]
		if type(format) == "function" then
			local ok, text = pcall(format, copper)
			if ok and type(text) == "string" and text:find("|T", 1, true) then return text end
		end
	end
	local gold, silver, rest = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
	local parts = {}
	if gold > 0 then parts[#parts + 1] = COIN_ICON:format(gold, "Gold") end
	if silver > 0 then parts[#parts + 1] = COIN_ICON:format(silver, "Silver") end
	if rest > 0 then parts[#parts + 1] = COIN_ICON:format(rest, "Copper") end
	return table.concat(parts, " ")
end

--[[
	Values the client may withhold. Inside dungeons Forever hands addons "secret" values
	for enemy guids and casts; those are treated as unknown rather than compared or stored.
]]
function ns.IsSecret(value)
	if type(issecretvalue) ~= "function" then return false end
	local ok, secret = pcall(issecretvalue, value)
	return ok and secret == true
end

function ns.Readable(value)
	if ns.IsSecret(value) then return nil end
	return value
end

-- A call the client may lack or refuse: its first value, or nil when it lacks the call, it fails or
-- it keeps the value back.
function ns.Call(fn, ...)
	if type(fn) ~= "function" then return nil end
	local ok, value = pcall(fn, ...)
	if ok then return ns.Readable(value) end
	return nil
end

function ns.InInstance()
	local ok, inside = pcall(IsInInstance)
	return ok and ns.Readable(inside) == true
end

function ns.NpcIDFromGUID(guid)
	guid = ns.Readable(guid)
	if type(guid) ~= "string" then return nil end
	local unitType, _, _, _, _, npcID = strsplit("-", guid)
	if unitType == "Creature" or unitType == "Vehicle" then return tonumber(npcID) end
	return nil
end

-- An object's id from its GUID (a chest, a plant, a node: "GameObject-0-server-instance-zone-id-spawn"),
-- read as a creature's is.
function ns.ObjectIDFromGUID(guid)
	guid = ns.Readable(guid)
	if type(guid) ~= "string" then return nil end
	local unitType, _, _, _, _, objectID = strsplit("-", guid)
	if unitType == "GameObject" then return tonumber(objectID) end
	return nil
end

function ns.ItemIDFromLink(link)
	link = ns.Readable(link)
	if type(link) ~= "string" then return nil end
	return tonumber(link:match("item:(%d+)"))
end

-- The player's map and position, where the client reports one (not inside Forever's own dungeons).
function ns.PlayerMapPosition()
	if not (C_Map and C_Map.GetBestMapForUnit) then return nil end
	local mapID = ns.Readable(C_Map.GetBestMapForUnit("player"))
	if type(mapID) ~= "number" then return nil end
	local position = C_Map.GetPlayerMapPosition(mapID, "player")
	if not position then return mapID end
	local x, y = position:GetXY()
	x, y = ns.Readable(x), ns.Readable(y)
	if type(x) ~= "number" or type(y) ~= "number" then return mapID end
	return mapID, math.floor(x * 10000 + 0.5) / 10000, math.floor(y * 10000 + 0.5) / 10000
end

-- Points in the client's list of flight masters (by node id) that Forever has no flight master for. Found
-- by setting Forever's own flight-node table (101 rows, client 1.60.1) against the flight masters in
-- Forever's quest data, 2026-11-10: every other point the maps list stands within 12 yards of one. The
-- world map leaves them out (UI/TravelMap.lua), and Adventure Mode never counts them found (Core/Discovery.lua).
ns.NOT_ON_FOREVER_TAXI = {
	-- Eastern Plaguelands' four towers: no flight master within 570 yards, and no one can learn them (the
	-- client gives them no character bit). Light's Hope Chapel is the zone's only flight point.
	[84] = true, [85] = true, [86] = true, [87] = true,
	-- Old Riverglades placeholders ("zzOLD..."), drawn on top of Southshore's, Thorium Point's and
	-- Ratchet's own points; Riverglades' real ones are Rog'mar's and Farholde Keep's.
	[3206] = true, [3207] = true, [3208] = true,
}

-- Whether a flight point of the client's list (by node id) is one Forever has a flight master for.
function ns.ForeverTaxiNode(nodeID)
	return not ns.NOT_ON_FOREVER_TAXI[nodeID]
end

------------------------------------------------------------------------------------------
-- The game's Gamepad UI
------------------------------------------------------------------------------------------

--[[
	Forever's Gamepad UI (Settings > Gamepad > Enable Gamepad UI). While it is on, the game's own pad code takes
	each window its window manager opens, moves the pad's buttons to it and back (Blizzard_GamepadSharedUtility/
	FrameControlsManager.lua:384-561, its binding sets), and walks its buttons with the D-pad, the yellow arrow
	(Blizzard_GamepadSmartNavigation). The docked journal is one of those windows. That code runs only while the
	Gamepad UI is on (FrameControlsManager.lua:385-387, 474-476: the test UIOn makes).

	The owner's taint logs of 2026-11-10: the pad code's change of the pad's buttons refused for the journal's
	taint (ADDON_ACTION_FORBIDDEN, SetPreferredGamepadInteractTarget: MainActionBarFrame.lua:355-375), the yellow
	arrow left on screen, no jump and no attack until /reload. One tainted moment lasts: the pad code's binding
	stack reads a slot before it writes it (InputBindingManager.lua:235-241), so a slot once written from an
	addon's taint stays so. So, only while the Gamepad UI is on, the journal:
	- writes none of the pad code's keys on its frames itself: a mark goes through the setter the game gives
	  addons (Gamepad:Skip);
	- opens no window through the window manager while the Gamepad UI's HUD mode is up (Gamepad:ShowPanel,
	  Gamepad:ItemClick);
	- leaves the world map's zone step as it is while the pad's arrow is on it (Gamepad:IsCurrent);
	- lets go of the pad when a fight starts (Gamepad:Watch).
	With it off, or on a client without it, none of the game's pad code is called and none of its state read: the
	journal only keeps the frames to mark, and listens for the Gamepad UI being switched on (Gamepad:Skip).
]]
local Gamepad = {}
ns.Gamepad = Gamepad

-- Whether the Gamepad UI is on, by the game's own test (Blizzard_SharedXML/Mainline/InputUtil.lua:11-13).
-- Only read.
function Gamepad:UIOn()
	if InputUtil and type(InputUtil.IsGamepadUIEnabled) == "function" then
		local ok, on = pcall(InputUtil.IsGamepadUIEnabled)
		return ok and on == true
	end
	if C_InputInterfaceStyle and type(C_InputInterfaceStyle.GetCurrentStyle) == "function" then
		local ok, style = pcall(C_InputInterfaceStyle.GetCurrentStyle)
		local types = Enum and Enum.InputDeviceInterfaceType
		return ok and style ~= nil and style == (types and types.Gamepad or 1)
	end
	return false
end

--[[
	The client's addon restriction for combat, on: the pad code's own test of every setter and wrapped call an addon
	makes, and its only one (Blizzard_GamepadSmartNavigation/SecureHelper.lua:14-15, 26-28, 136, 168). Off
	throughout the client's event that tells of it changing (RESTRICTION_CHANGED, below).
]]
local function CombatRestricted()
	local restrictions, kinds = C_RestrictedActions, Enum and Enum.AddOnRestrictionType
	if not (restrictions and type(restrictions.IsAddOnRestrictionActive) == "function" and kinds and kinds.Combat ~= nil) then
		return false
	end
	local ok, on = pcall(restrictions.IsAddOnRestrictionActive, kinds.Combat)
	return ok and on == true
end

--[[
	Whether the game refuses the journal's calls into its pad code now: in combat, or while the client's addon
	restriction for combat is on (above). A refused call puts the game's "blocked" line in the chat, blaming the
	journal, so the journal asks first and does nothing then. Combat's lockdown is asked too, to be safe, though the
	pad code's helper does not ask it; only at the client's own word that its restriction is about to start is the
	restriction asked alone (LetGo, below).
]]
function Gamepad:Restricted()
	if InCombatLockdown() then return true end
	return CombatRestricted()
end

--[[
	ADDON_RESTRICTION_STATE_CHANGED (type, state): the client's word that one of its addon restrictions is changing,
	fired before it becomes active and after it is no longer. While it is told, IsAddOnRestrictionActive says false,
	and a restriction about to start (Activating) is not enforced till it has been told
	(Blizzard_APIDocumentationGenerated/RestrictedActionsDocumentation.lua:58, 97-106;
	RestrictedActionsConstantsDocumentation.lua:13-14, 26). None of the game's own interface code listens for it.
]]
local RESTRICTION_CHANGED = "ADDON_RESTRICTION_STATE_CHANGED"

-- A state of the client's addon restrictions, by its Enum, else by the number its documentation gives.
local function RestrictionState(name)
	local states = Enum and Enum.AddOnRestrictionState
	local value = states and states[name]
	if value == nil then value = (name == "Activating") and 1 or 0 end
	return value
end

local watch    -- the frame for the events below, made when first needed
local OnEvent  -- its handler (at the end)
local function Watcher()
	if not watch then
		watch = CreateFrame("Frame")
		watch:SetScript("OnEvent", function(self, event, ...) OnEvent(self, event, ...) end)
	end
	return watch
end

local watched  -- the journal's window while it is shown, the Gamepad UI on (Gamepad:Watch)
local waiting  -- marks waiting for the game to allow them (MarkSkipped)

-- The client's word on its restriction for combat, listened for while either of those needs it.
local function HearRestriction()
	if watched or waiting then
		ns.RegisterEvents(Watcher(), RESTRICTION_CHANGED)
	elseif watch then
		ns.UnregisterEvents(watch, RESTRICTION_CHANGED)
	end
end

--[[
	A frame the pad's window navigation should pass over (the location bars' menu arrows: UI/Art.lua's
	Menus:StepArrow; the game's own overflow button, kept out of sight: Menus:CoverOverflow), marked by the game's
	setter (Blizzard_GamepadSmartNavigation/Utility.lua:14-16, 26, 46-52), which writes the mark from the game's
	own code (SecureHelper.lua:47-78, 144-158). The navigation reads that key on every frame of a window it moves
	through, on every press, hidden frames too (SmartNavigation.lua:1207-1210, Utility.lua:59-79): the key the
	journal wrote itself on its arrows made each press run from its taint, and the next change of focus wrote the
	pad's binding stack so (above). The setter refuses an addon in combat with the blocked line, and the mark
	matters only to the Gamepad UI: a frame waits (weakly held) until the Gamepad UI is on and the game allows it,
	asked again as combat ends (PLAYER_REGEN_ENABLED) and as the client says its restriction for combat is over
	(RESTRICTION_CHANGED, Inactive), whichever finds both over first.
]]
local skipping = setmetatable({}, { __mode = "k" })

local function Wait(on)
	if (waiting == true) == on then return end
	waiting = on or nil
	if on then
		ns.RegisterEvents(Watcher(), "PLAYER_REGEN_ENABLED")
	else
		ns.UnregisterEvents(Watcher(), "PLAYER_REGEN_ENABLED")
	end
	HearRestriction()
end

local function MarkSkipped()
	if next(skipping) == nil or not Gamepad:UIOn() then
		Wait(false)
		return
	end
	if Gamepad:Restricted() then
		Wait(true)
		return
	end
	Wait(false)
	local mark = SmartNavigation_MarkFrameIgnored
	for frame in pairs(skipping) do
		skipping[frame] = nil
		if type(mark) == "function" then pcall(mark, frame) end
	end
end

function Gamepad:Skip(frame)
	if not frame or type(SmartNavigation_MarkFrameIgnored) ~= "function" then return end
	if next(skipping) == nil then ns.RegisterEvents(Watcher(), "INPUT_DEVICE_INTERFACE_TRANSITION") end
	skipping[frame] = true
	MarkSkipped()
end

--[[
	The Gamepad UI's HUD mode (Blizzard_GamePad/UI/HUDMode/GamepadHudMode.lua), up: it listens for each window the
	window manager opens with a plain callback, which shuts HUD mode, and that takes two sets of the pad's buttons
	off the binding stack (:88-104, 112-115). The manager tells its listeners from inside the code that called
	ShowUIPanel (UIParentPanelManager.lua:871-876, 902), so from the journal's code that would write the stack
	from its taint for good (above). While HUD mode is up the journal opens no window through the manager: its own
	shows as a plain frame (UI/Journal.lua), and the world map, the game's settings and its try-on window stay shut,
	with a chat line (UI/DungeonMap.lua's OpenWorld, UI/Options.lua, Gamepad:ItemClick). The game's quest window
	reads HUD mode the same way (Blizzard_UIPanels_Game/Mainline/QuestFrame.lua:434). Nothing in HUD mode listens
	for a window shut.
]]
function Gamepad:HudUp()
	if not self:UIOn() then return false end
	local hud = GamepadHudMode
	return type(hud) == "table" and type(hud.IsShown) == "function" and hud:IsShown() == true
end

-- ShowUIPanel(frame) from the journal's code, unless HUD mode is up (above): then nothing is asked, and false.
function Gamepad:ShowPanel(frame)
	if type(ShowUIPanel) ~= "function" or self:HudUp() then return false end
	pcall(ShowUIPanel, frame)
	return true
end

-- The chat line for a window left shut while HUD mode is up.
function Gamepad:SayHudUp()
	ns.Print(ns.L.GAMEPAD_HUD_UP)
end

--[[
	A click on an item in the journal (a loot row, the Gear Finder's cells and rows, a quest reward, an ability's
	item link), handed to the game's own HandleModifiedItemClick, which links the item or tries it on as the keys
	held say. While HUD mode is up, not the try-on: the game opens its try-on window with ShowUIPanel inside this
	call (Blizzard_ItemButton/Mainline/ItemButtonTemplate.lua:388-389; Blizzard_UIPanels_Game/Mainline/
	DressUpFrames.lua:6-13, 92-95, 346-365), so the chat line instead (above). True when the click was taken, as
	the game's says.
]]
function Gamepad:ItemClick(link)
	if not link or type(HandleModifiedItemClick) ~= "function" then return false end
	if self:HudUp() and type(IsModifiedClick) == "function" and IsModifiedClick("DRESSUP") then
		self:SayHudUp()
		return true
	end
	return HandleModifiedItemClick(link)
end

--[[
	Whether the pad's arrow is on this button (SmartNavigation:GetCurrentButton, SmartNavigation.lua:1825-1827),
	only read. The navigation hooks each button it selects, and a change of the selected one's enabled state
	(Enable, Disable) is told from inside the code that made it to the game's pad hints, which set the pad's
	buttons up again there (SmartNavigation.lua:721-740; Blizzard_GamepadSharedUtility/PromptedBindings/
	PromptedBindingFooter.lua:318-371; the world map's, Blizzard_WorldMap.lua:836-849): the journal leaves such a
	button as it is (UI/DungeonMap.lua's zone step).
]]
function Gamepad:IsCurrent(button)
	if not button or not self:UIOn() then return false end
	local navigation = SmartNavigation
	if type(navigation) ~= "table" or type(navigation.GetCurrentButton) ~= "function" then return false end
	local ok, current = pcall(navigation.GetCurrentButton, navigation)
	return ok and current == button
end

--[[
	The journal shown with the Gamepad UI on, as a fight starts: the pad code lets go of it, so the pad's buttons
	are the game's again at once (jump, attack) and the yellow arrow goes; the journal stays on screen. In a fight
	the game refuses the pad code's own forgetting of a window an addon's code hides (its OnHide hook asks a
	wrapped call: SmartNavigation.lua:812-818, 869-902), so a journal shut in a fight left the pad on it till the
	fight ended (the owner's report of 2026-11-10, 21:55). Let go of first, nothing is left on it.
	- FrameHidden (FrameControlsManager.lua:473-561): out of the pad code's windows; with none left the pad's
	  buttons go back to the game (:542-547), else to the window left (:527-535). It returns at once for a window
	  it does not hold (:484-487), such as a free journal.
	- RemovePanelInfo (SmartNavigation.lua:873-902): its navigation forgotten, so frames made under it in the
	  fight ask for no refresh the game would refuse (:255-265, 1799-1804).
	Both are the pad code's own calls for addons, run by its helper as its own code (SecureHelper.lua:162-191;
	FrameControlsManager.lua:463-464, 560-561; SmartNavigation.lua:900-902), allowed while the restriction for
	combat is off only. Told by whichever comes first:
	- the client's word that that restriction is about to start (RESTRICTION_CHANGED, Combat, Activating; above):
	  fired before it starts, and the restriction alone asked then, as the helper asks it, since combat's lockdown
	  may have begun by then;
	- PLAYER_REGEN_DISABLED, which comes before combat's lockdown; whether before the restriction too is not known.
	Already refused, nothing is asked and the pad stays with the window, as before (counted in lateFights; the
	count, and the event that let go, in /aegis where: Gamepad:Readout). The journal takes the pad again only at
	its next opening, not after the fight, where it would take the first press of the next pull.
]]
local function LetGo(event)
	local frame = watched
	if not (frame and frame:IsShown() and Gamepad:UIOn()) then return end
	local refused
	if event == RESTRICTION_CHANGED then refused = CombatRestricted() else refused = Gamepad:Restricted() end
	if refused then
		Gamepad.lateFights = (Gamepad.lateFights or 0) + 1
		return
	end
	Gamepad:Unwatch(frame)
	Gamepad.letGo, Gamepad.letGoBy = (Gamepad.letGo or 0) + 1, event
	local manager = GamepadMode and GamepadMode.FrameControlsManager
	if type(manager) == "table" and type(manager.FrameHidden) == "function" then
		pcall(manager.FrameHidden, manager, frame)
	end
	local navigation = SmartNavigation
	if type(navigation) == "table" and type(navigation.RemovePanelInfo) == "function" then
		pcall(navigation.RemovePanelInfo, navigation, frame)
	end
end

-- The journal's window shown (UI/Journal.lua): listened for, with the Gamepad UI on, till it shuts.
function Gamepad:Watch(frame)
	if not frame or not self:UIOn() then return end
	watched = frame
	ns.RegisterEvents(Watcher(), "PLAYER_REGEN_DISABLED")
	HearRestriction()
end

function Gamepad:Unwatch(frame)
	if watched == nil or watched ~= frame then return end
	watched = nil
	ns.UnregisterEvents(Watcher(), "PLAYER_REGEN_DISABLED")
	HearRestriction()
end

--[[
	/aegis where's line with the Gamepad UI on (Core/Perf.lua), for the owner's test of a fight's order of events
	(a best guess, above): the fights whose start let go of the pad and the event that did the last, those that
	found the game refusing already, how often the client told of its restriction for combat while the journal
	listened, and the marks still waiting. Nil with the Gamepad UI off.
]]
function Gamepad:Readout()
	if not self:UIOn() then return nil end
	local marks = 0
	for _ in pairs(skipping) do marks = marks + 1 end
	return string.format(ns.L.WHERE_GAMEPAD, self.letGo or 0, self.letGoBy or "-", self.lateFights or 0,
		self.restrictionHeard or 0, marks)
end

OnEvent = function(self, event, kind, state)
	if event == "PLAYER_REGEN_DISABLED" then
		LetGo(event)
		return
	end
	if event == RESTRICTION_CHANGED then
		local kinds = Enum and Enum.AddOnRestrictionType
		if not (kinds and kinds.Combat ~= nil and kind == kinds.Combat) then return end
		Gamepad.restrictionHeard = (Gamepad.restrictionHeard or 0) + 1
		if state == RestrictionState("Activating") then
			LetGo(event)
			return
		end
		if state ~= RestrictionState("Inactive") then return end
	end
	-- Combat or its restriction over, or the Gamepad UI switched on: the marks that waited.
	MarkSkipped()
end
