local _, ns = ...
local L = ns.L

--[[
	The Reputation tab's list: a card for every faction, laid out like the dungeon grid and
	framed the same way. A card shows the faction's crest in the journal's gold ring over a glow
	of its colour, the player's standing, and how many rewards it has (or that its quartermaster
	is not captured yet). Clicking one opens its rewards in the book, its standings where a
	dungeon lists bosses. After the factions, under Vendors, a card for each currency some vendor
	takes for wares that need no standing (Pix Xizzix's Tarnished Undermine Real): its icon, how
	many the player has, and its page, the vendors where a faction lists standings.

	Above the grid, Capture: with a quartermaster's shop open, it keeps everything they sell,
	and the wares that need a standing join that faction's rewards at once.

	In Adventure Mode (Core/Discovery.lua) a faction has a card once it has been on the character's
	Reputation tab (Discovery:FactionKnown), not because the client gives a standing with it (Forever
	gives one for a faction never met); its rewards show on its page once seen at its quartermaster
	(UI/LootPanel.lua).
]]

local FactionSelect = {}
ns.FactionSelect = FactionSelect

local Reputation = ns.Reputation

local CARD_WIDTH, CARD_HEIGHT = 174, 96
local COLUMNS = 4
local SPACING_X, SPACING_Y = 15, 15
local GRID_LEFT, GRID_TOP = 17, 62
local CREST_COORDS = { 0.07, 0.93, 0.07, 0.93 }
local CREST_SIZE = 36
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local GOLD_DARK, GOLD_LIGHT = { 0.50, 0.34, 0.10 }, { 1, 0.88, 0.52 }
local BLACK = { 0, 0, 0 }
local UNKNOWN_COLOR = { 0.6, 0.6, 0.6 }
local NAME_FONT = "QuestTitleFontBlackShadow"

local panels = {}

------------------------------------------------------------------------------------------
-- Cards
------------------------------------------------------------------------------------------

-- A round texture of the given size on the card's crest point.
local function Circle(card, subLevel, size)
	local texture = card:CreateTexture(nil, "OVERLAY", nil, subLevel)
	texture:SetSize(size, size)
	texture:SetPoint("CENTER", card, "BOTTOM", 0, 30)
	if card.CreateMaskTexture and texture.AddMaskTexture then
		local mask = card:CreateMaskTexture()
		mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetAllPoints(texture)
		texture:AddMaskTexture(mask)
	end
	return texture
end

-- Long names drop a size so they keep to two lines above the crest.
local function SetName(card, name)
	card.Name:SetFontObject(NAME_FONT)
	card.Name:SetText(name)
	local lines = card.Name:GetNumLines()
	if type(lines) == "number" and lines > 2 then
		local font, size, flags = card.Name:GetFont()
		if font and size then card.Name:SetFont(font, size - 3, flags) end
	end
end

-- What the player has of a currency, with its icon ("37 [coin]"); nil where the client cannot say.
local function CurrencyHeld(page)
	local count = ns.CurrencyCount(page.currency)
	if not count then return nil end
	local icon = ns.CurrencyIcon(page.currency)
	return icon and string.format("%d|T%s:0:0:2:0|t", count, icon) or tostring(count)
end
FactionSelect.CurrencyHeld = CurrencyHeld

-- A currency's card: its vendors, by name and where they stand.
local function ShowCurrencyTooltip(card)
	local page = card.faction
	GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
	GameTooltip:SetText(page.name, 1, 1, 1)
	local held = CurrencyHeld(page)
	if held then GameTooltip:AddLine(string.format(L.CURRENCY_YOU_HAVE, held), 1, 0.82, 0) end
	for _, vendor in ipairs(page.bosses) do
		local map = vendor.mapID and ns.DungeonMap:MapInfo(vendor.mapID)
		local line = string.format(L.CURRENCY_VENDOR, vendor.name)
		GameTooltip:AddLine(map and map.name and (line .. ", " .. map.name) or line, 1, 1, 1)
	end
	-- Where the currency comes from, where the journal knows (Carved Centaur Totem's centaurs)
	local note = ns.CurrencyNote(page.currency)
	if note then GameTooltip:AddLine(note, 1, 0.82, 0, true) end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.CURRENCY_CARD_CLICK, 0.5, 0.8, 1)
	GameTooltip:Show()
end

local function ShowTooltip(card)
	local faction = card.faction
	if faction.kind == "currency" then return ShowCurrencyTooltip(card) end
	GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
	GameTooltip:SetText(faction.name, 1, 1, 1)
	local standing = Reputation:Player(faction.factionID)
	if standing then
		local r, g, b = Reputation:Color(standing.reaction)
		GameTooltip:AddLine(Reputation:Label(standing.reaction), r, g, b)
		if standing.description then GameTooltip:AddLine(standing.description, 1, 0.82, 0, true) end
	else
		GameTooltip:AddLine(L.REP_UNKNOWN, 0.6, 0.6, 0.6)
	end
	local names = {}
	for _, vendor in pairs(faction.quartermasters or {}) do names[#names + 1] = vendor.name end
	table.sort(names)
	for _, name in ipairs(names) do GameTooltip:AddLine(string.format(L.REP_QUARTERMASTER, name), 1, 1, 1) end
	if not ns.FactionCaptured(faction) then
		GameTooltip:AddLine(ns.FactionListed(faction) and L.REP_LISTED_TIP or L.REP_NOT_CAPTURED_TIP, 0.6, 0.6, 0.6, true)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.REP_CARD_CLICK, 0.5, 0.8, 1)
	GameTooltip:Show()
end

local function CreateCard(parent)
	local card = CreateFrame("Button", nil, parent)
	card:SetSize(CARD_WIDTH, CARD_HEIGHT)

	-- A glow of the faction's colour, brightest behind the crest and darkening to the edges,
	-- inside the dungeon buttons' frame.
	card.Base = card:CreateTexture(nil, "BACKGROUND", nil, 0)
	card.Base:SetPoint("TOPLEFT", 3, -3)
	card.Base:SetPoint("BOTTOMRIGHT", -3, 3)
	card.GlowTop = card:CreateTexture(nil, "BACKGROUND", nil, 1)
	card.GlowTop:SetPoint("TOPLEFT", card.Base)
	card.GlowTop:SetPoint("BOTTOMRIGHT", card.Base, "RIGHT", 0, -14)
	card.GlowBottom = card:CreateTexture(nil, "BACKGROUND", nil, 1)
	card.GlowBottom:SetPoint("TOPLEFT", card.GlowTop, "BOTTOMLEFT")
	card.GlowBottom:SetPoint("BOTTOMRIGHT", card.Base)
	card.ShadeLeft = card:CreateTexture(nil, "BACKGROUND", nil, 2)
	card.ShadeLeft:SetPoint("TOPLEFT", card.Base)
	card.ShadeLeft:SetPoint("BOTTOMLEFT", card.Base)
	card.ShadeLeft:SetWidth(56)
	ns.Gradient(card.ShadeLeft, "HORIZONTAL", BLACK, 0.7, 0)
	card.ShadeRight = card:CreateTexture(nil, "BACKGROUND", nil, 2)
	card.ShadeRight:SetPoint("TOPRIGHT", card.Base)
	card.ShadeRight:SetPoint("BOTTOMRIGHT", card.Base)
	card.ShadeRight:SetWidth(56)
	ns.Gradient(card.ShadeRight, "HORIZONTAL", BLACK, 0, 0.7)
	ns.SetButtonArt(card, "DungeonButton-Up", "DungeonButton-Down", "DungeonButton-Highlight")

	card.Name = card:CreateFontString(nil, "OVERLAY", NAME_FONT)
	card.Name:SetSize(150, 0)
	card.Name:SetPoint("TOP", 0, -12)
	card.Name:SetJustifyH("CENTER")

	-- The crest in a true circle: a gold rim, a thin dark edge, then the icon, each rounded
	-- by its own mask and centred on the same point.
	card.Rim = Circle(card, 1, CREST_SIZE + 6)
	ns.Gradient(card.Rim, "VERTICAL", GOLD_DARK, 1, 1, GOLD_LIGHT)
	card.Edge = Circle(card, 2, CREST_SIZE + 2)
	card.Edge:SetColorTexture(0.1, 0.07, 0.03, 1)
	card.Crest = Circle(card, 3, CREST_SIZE)

	card.Standing = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	card.Standing:SetPoint("BOTTOMLEFT", 9, 9)
	card.Standing:SetJustifyH("LEFT")
	-- WoW: Forever's emblem on the factions it added, where the dungeon buttons wear it.
	card.Forever = ns.CreateForeverMark(card)
	card.Forever:SetPoint("BOTTOMRIGHT", -6, 6)


	card:SetScript("OnEnter", ShowTooltip)
	card:SetScript("OnLeave", function() GameTooltip:Hide() end)
	card:SetScript("OnClick", function(self)
		ns.PlaySoundKit("IG_SPELLBOOK_OPEN")
		ns.Journal:OpenInstance(self.faction)
	end)
	return card
end

local function SetCard(card, faction)
	card.faction = faction
	SetName(card, faction.name)

	local color = Reputation:CardColor(faction)
	card.Base:SetColorTexture(color[1] * 0.2, color[2] * 0.2, color[3] * 0.2, 1)
	ns.Gradient(card.GlowTop, "VERTICAL", color, 0.85, 0.15)
	ns.Gradient(card.GlowBottom, "VERTICAL", color, 0.3, 0.85)

	card.Crest:SetTexture(Reputation:Crest(faction))
	card.Crest:SetTexCoord(CREST_COORDS[1], CREST_COORDS[2], CREST_COORDS[3], CREST_COORDS[4])

	-- A currency's card says how many the player has, where a faction's says their standing.
	local standing = faction.kind ~= "currency" and Reputation:Player(faction.factionID)
	if faction.kind == "currency" then
		local held = CurrencyHeld(faction)
		-- (the count and the coin alone: "You have" would run into the crest; the tooltip says it)
		card.Standing:SetText(held or "")
		card.Standing:SetTextColor(1, 0.82, 0)
	elseif standing then
		card.Standing:SetText(Reputation:Label(standing.reaction))
		card.Standing:SetTextColor(Reputation:Color(standing.reaction))
	else
		card.Standing:SetText(L.REP_UNKNOWN)
		card.Standing:SetTextColor(UNKNOWN_COLOR[1], UNKNOWN_COLOR[2], UNKNOWN_COLOR[3])
	end

	card.Forever:SetShown(faction.forever == true)
end

------------------------------------------------------------------------------------------
-- Capturing a quartermaster
------------------------------------------------------------------------------------------

local function CreateCapture(panel)
	local button = ns.CreateFrameWithTemplate("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetSize(150, 24)
	button:SetPoint("TOPRIGHT", -26, -22)
	button:SetText(L.REP_CAPTURE)
	button:SetScript("OnClick", function() FactionSelect:Capture(panel) end)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:SetText(L.REP_CAPTURE, 1, 1, 1)
		GameTooltip:AddLine(L.REP_CAPTURE_TIP, 1, 0.82, 0, true)
		-- The wares go out with Copy on the Record tab: say so when that tab is hidden.
		if not ns.Recorder.TabShown() then GameTooltip:AddLine(L.RECORD_TAB_IS_OFF, 1, 0.3, 0.3, true) end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- Wrapped so the button reacts to the mouse even while disabled, for its tooltip.
	if button.SetMotionScriptsWhileDisabled then button:SetMotionScriptsWhileDisabled(true) end
	panel.Capture = button

	panel.CaptureStatus = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.CaptureStatus:SetPoint("RIGHT", button, "LEFT", -12, 0)
	panel.CaptureStatus:SetJustifyH("RIGHT")
end

function FactionSelect:RefreshCapture(panel)
	local open = ns.Recorder:MerchantOpen()
	panel.Capture:SetEnabled(open)
	local found, status = panel.lastCapture, panel.CaptureStatus
	if found and open then
		if found.forStanding > 0 and #found.factions > 0 then
			-- Every ware joins: those that need no standing too, under "Any standing" (ns.AddCapturedVendors).
			status:SetText(string.format(L.REP_CAPTURED, found.name, found.wares, table.concat(found.factions, ", "),
				found.new))
		elseif found.forStanding > 0 then
			status:SetText(string.format(L.REP_CAPTURED_UNKNOWN, found.name, found.forStanding))
		elseif found.currency then
			-- A currency vendor: their page under Vendors (Core/Registry.lua's currency vendors).
			status:SetText(string.format(L.REP_CAPTURED_CURRENCY, found.name, found.wares, found.currency))
		else
			status:SetText(string.format(L.REP_CAPTURED_NONE, found.name, found.wares))
		end
		status:SetTextColor(0.3, 1, 0.3)
	elseif open then
		status:SetText(L.REP_CAPTURE_READY)
		status:SetTextColor(1, 0.82, 0)
	else
		panel.lastCapture = nil
		status:SetText(L.REP_CAPTURE_HINT)
		status:SetTextColor(0.7, 0.7, 0.7)
	end
end

function FactionSelect:Capture(panel)
	ns.PlaySoundKit("IG_MAINMENU_OPTION")
	panel.lastCapture = ns.Recorder:CaptureVendor(true)
	-- (the wares that join a faction's rewards now are seen there, in Adventure Mode)
	ns.Discovery:ReadShop()
	self:RefreshCapture(panel)
	if panel:IsVisible() then self:Refresh(panel) end
end

------------------------------------------------------------------------------------------
-- Grid
------------------------------------------------------------------------------------------

function FactionSelect:Build(panel)
	panel.Buttons = {}
	local scroll = ns.CreateScrollFrame(panel, ns.GRID_SCROLLBAR_X, -6, 4)
	scroll:SetPoint("TOPLEFT", GRID_LEFT, -GRID_TOP)
	scroll:SetPoint("BOTTOMRIGHT", -24, 6)
	scroll.Child:SetSize(COLUMNS * CARD_WIDTH + (COLUMNS - 1) * SPACING_X, 1)
	panel.Scroll = scroll

	-- Standings change as the player earns reputation.
	panel:RegisterEvent("UPDATE_FACTION")
	panel:SetScript("OnEvent", function(self)
		if self:IsVisible() and not self.refreshQueued then
			self.refreshQueued = true
			C_Timer.After(0.2, function()
				self.refreshQueued = nil
				if self:IsVisible() then FactionSelect:Refresh(self) end
			end)
		end
	end)
	panel:SetScript("OnShow", function(self) FactionSelect:Refresh(self) end)

	CreateCapture(panel)
	-- A shop opening or closing (and a capture) shows on the button and the line beside it.
	ns.Recorder:OnChange(function() FactionSelect:RefreshCapture(panel) end)
	self:RefreshCapture(panel)

	-- The cards are made the first time the tab shows (OnShow above), not with the window.
	panels[#panels + 1] = panel
end

-- The factions with a card: every one, or in Adventure Mode those the character knows.
local function Listed()
	local list = ns.GetFactions()
	if not ns.Style:Adventure() then return list end
	local known = {}
	for _, faction in ipairs(list) do
		if ns.Discovery:FactionKnown(faction) then known[#known + 1] = faction end
	end
	return known
end

--[[
	The factions' cards, then, after them, the Vendors: a heading over the cards of the currency vendors' pages (Core/
	Registry.lua's currency vendors), one for each currency, laid out the same, from a row of their own.
]]
local GROUP_HEADING_HEIGHT = 34

local function PlaceCards(panel, list, first, top)
	local child = panel.Scroll.Child
	for offset, faction in ipairs(list) do
		local index = first + offset - 1
		local card = panel.Buttons[index]
		if not card then
			card = CreateCard(child)
			panel.Buttons[index] = card
		end
		local column = (offset - 1) % COLUMNS
		local row = math.floor((offset - 1) / COLUMNS)
		card:ClearAllPoints()
		card:SetPoint("TOPLEFT", column * (CARD_WIDTH + SPACING_X), -(top + row * (CARD_HEIGHT + SPACING_Y)))
		SetCard(card, faction)
		card:Show()
	end
	local rows = math.ceil(#list / COLUMNS)
	return top + math.max(0, rows * (CARD_HEIGHT + SPACING_Y) - SPACING_Y)
end

function FactionSelect:Refresh(panel)
	local list = Listed()
	-- (Adventure Mode keeps the currency vendors' pages back: nothing yet tells which the character has found, and the
	-- journal there starts empty. A best guess until the owner says when one should show.)
	local vendors = ns.Style:Adventure() and {} or ns.GetCurrencyPages()
	local child = panel.Scroll.Child
	local bottom = PlaceCards(panel, list, 1, 0)

	-- (rawget: the field is the journal's own)
	if #vendors > 0 and not rawget(panel, "VendorsHeading") then
		panel.VendorsHeading = child:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		panel.VendorsHeading:SetJustifyH("LEFT")
		panel.VendorsHeading:SetText(L.REP_VENDORS)
	end
	if rawget(panel, "VendorsHeading") then panel.VendorsHeading:SetShown(#vendors > 0) end
	if #vendors > 0 then
		-- Each page by the client's name for its currency, once the server has described it.
		for _, page in ipairs(vendors) do page.name = ns.CurrencyName(page.currency) end
		local top = (#list > 0 and bottom + SPACING_Y or 0)
		panel.VendorsHeading:ClearAllPoints()
		panel.VendorsHeading:SetPoint("TOPLEFT", 4, -(top + 8))
		bottom = PlaceCards(panel, vendors, #list + 1, top + GROUP_HEADING_HEIGHT)
	end
	for index = #list + #vendors + 1, #panel.Buttons do panel.Buttons[index]:Hide() end

	child:SetHeight(math.max(1, bottom))
	panel.Empty:SetShown(#list + #vendors == 0)
	-- (in Adventure Mode, the factions the character knows: none met yet says so)
	panel.Empty:SetText(ns.Style:Adventure() and L.ADVENTURE_REP_NONE or panel.emptyText)
	self:RefreshCapture(panel)
end

-- The tab drawn again where it shows, for a find in Adventure Mode (UI/Journal.lua's Redraw).
function FactionSelect:RefreshShown()
	for _, panel in ipairs(panels) do
		if panel:IsVisible() then self:Refresh(panel) end
	end
end
