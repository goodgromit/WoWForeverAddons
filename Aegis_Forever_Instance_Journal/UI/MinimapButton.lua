local _, ns = ...
local L = ns.L

--[[
	The journal's button on the minimap's edge: the journal's icon, the book, which its window
	wears too (UI/Journal.lua), round. Left-click opens or closes the journal, right-click opens its options; dragged, it goes round
	the minimap's edge and stays where it is left. It is a button on the edge as classic ones are; a
	minimap button collector gathers it like the rest. Shown unless turned off in the journal's options.

	The journal is in the minimap's addon menu too (Blizzard's Addon Compartment, the small numbered button
	that lists addons; a player's ask of 2026-11-19), whether or not this button shows, with its title and
	icon: a click there does what a click here does, its tooltip says the same but for dragging. Each has its
	own box in the journal's options (the owner, 2026-11-20), so a player has the button, the menu's line, both
	or neither; both by default. The line is registered at run time, at the end of this file: a TOC's lines for
	that menu, as in 0.40.1's test builds, can't be turned off. Forever's client has that menu (its own files,
	read 2026-11-19: Blizzard_Minimap loads AddonCompartment for Forever, under its GameTimeFrame; until then
	this note said it had none).

	In Adventure Mode it glows while something found is unseen (UI/News.lua), with the game's own pulse
	round a minimap button (CreateGlow, below).
]]

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local DEFAULT_ANGLE = 210       -- degrees round the minimap, from its right, anticlockwise
local OUTSIDE = 10              -- how far past the minimap's edge the button's centre sits

--[[
	Adventure Mode's glow (UI/News.lua): the game's own pulse round a minimap button, its expansion landing
	page button's looping one (Blizzard_Minimap's ExpansionLandingPageMinimapButton: its LoopingGlow, the
	GarrLanding-CircleGlow ring drawn added, and MinimapLoopPulseAnim, which fades it in for half a second and
	out over the next second as it swells, over and over). The ring is sized to this smaller button (that
	button is 53 across, its ring 46). Where the client lacks the ring, the button's own highlight stands in;
	where it can't animate, a steady ring.
]]
local GLOW_ATLAS = "GarrLanding-CircleGlow"
local GLOW_FALLBACK = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
local GLOW_SIZE = 40

function MinimapButton.Shows()
	return not (ns.db and ns.db.hideMinimapButton)
end

-- Shown or hidden by Show and Hide, not SetShown: a minimap button collector hears only those.
local function SetShown(button, shown)
	if shown then button:Show() else button:Hide() end
end

function MinimapButton.SetShows(shown)
	ns.db.hideMinimapButton = not shown or nil
	if MinimapButton.button then SetShown(MinimapButton.button, shown) end
	MinimapButton:UpdateGlow()
end

-- Where the button goes for an angle: on a round minimap's edge, or a square one's.
local function Place(button, angle)
	local radians = math.rad(angle)
	local x, y = math.cos(radians), math.sin(radians)
	local square = type(GetMinimapShape) == "function" and GetMinimapShape() == "SQUARE"
	if square then
		local most = math.max(math.abs(x), math.abs(y))
		x, y = x / most, y / most
	end
	local radius = (Minimap:GetWidth() or 140) / 2 + OUTSIDE
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x * radius, y * radius)
end

-- The angle from the minimap's centre to the cursor, while the button is dragged.
local function CursorAngle()
	local mx, my = Minimap:GetCenter()
	local cx, cy = GetCursorPosition()
	local scale = (Minimap.GetEffectiveScale and Minimap:GetEffectiveScale()) or 1
	if not (mx and cx) then return nil end
	return math.deg(math.atan2(cy / scale - my, cx / scale - mx)) % 360
end

-- The tooltip, by the button or by the addon menu's line for the journal, which can't be dragged.
local function Tooltip(owner, draggable)
	GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
	GameTooltip:SetText(L.OPTIONS_TITLE, 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_LEFT_CLICK, 0.1, 1, 0.1)
	GameTooltip:AddLine(L.MINIMAP_RIGHT_CLICK, 0.1, 1, 0.1)
	if draggable then GameTooltip:AddLine(L.MINIMAP_DRAG, 0.6, 0.6, 0.6) end
	-- (Adventure Mode: why it glows. ns.News nil: a /reload after the update that added its file, which only a
	-- restart loads.)
	if ns.News ~= nil and ns.News:Glows() then GameTooltip:AddLine(L.MINIMAP_NEWS, 1, 1, 1) end
	GameTooltip:Show()
end

local function ShowTooltip(self) Tooltip(self, true) end

-- A click, by the button or in the addon menu: the right button opens the options, any other opens or closes the
-- journal, as Shift+J does (AegisJournal_Toggle, Core/Init.lua).
local function Click(mouseButton)
	if mouseButton == "RightButton" then
		ns.Options:Open()
	else
		AegisJournal_Toggle()
	end
end

--[[
	The glow, on a frame of its own over the button, so that its pulse plays only while that frame shows:
	from its OnShow, stopped by its OnHide, which the client sends too as the button or the minimap is hidden.
	Hidden until UpdateGlow shows it.
]]
local function CreateGlow(button)
	local glow = CreateFrame("Frame", nil, button)
	glow:SetSize(GLOW_SIZE, GLOW_SIZE)
	glow:SetPoint("CENTER", button.Icon, "CENTER")
	glow.Ring = glow:CreateTexture(nil, "ARTWORK")
	glow.Ring:SetAllPoints()
	if ns.AtlasExists(GLOW_ATLAS) then glow.Ring:SetAtlas(GLOW_ATLAS) else glow.Ring:SetTexture(GLOW_FALLBACK) end
	glow.Ring:SetBlendMode("ADD")
	local pulse = glow.Ring.CreateAnimationGroup and glow.Ring:CreateAnimationGroup()
	if pulse then
		-- (as the game's: drawn only by the pulse)
		glow.Ring:SetAlpha(0)
		pulse:SetLooping("REPEAT")
		local fadeIn, fadeOut, swell = pulse:CreateAnimation("Alpha"), pulse:CreateAnimation("Alpha"), pulse:CreateAnimation("Scale")
		fadeIn:SetFromAlpha(0)
		fadeIn:SetToAlpha(1)
		fadeIn:SetDuration(0.5)
		fadeIn:SetOrder(1)
		fadeOut:SetFromAlpha(1)
		fadeOut:SetToAlpha(0)
		fadeOut:SetStartDelay(0.5)
		fadeOut:SetDuration(1)
		fadeOut:SetOrder(1)
		if swell.SetScaleFrom and swell.SetScaleTo then
			swell:SetScaleFrom(0.75, 0.75)
			swell:SetScaleTo(1.1, 1.1)
		end
		swell:SetDuration(0.75)
		swell:SetOrder(1)
		glow.pulse = pulse
	end
	glow:SetScript("OnShow", function(self) if self.pulse then self.pulse:Play() end end)
	glow:SetScript("OnHide", function(self) if self.pulse then self.pulse:Stop() end end)
	glow:Hide()
	return glow
end

-- The glow shown while the news says so (UI/News.lua's Glows), and only while the button is: never when the
-- player has turned the button off.
function MinimapButton:UpdateGlow()
	local glow = self.button and self.button.Glow
	if not glow then return end
	if MinimapButton.Shows() and ns.News ~= nil and ns.News:Glows() then glow:Show() else glow:Hide() end
end

function MinimapButton:Create()
	if self.button or not Minimap then return self.button end
	local button = CreateFrame("Button", "AegisJournalMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	-- The minimap buttons' own look: a dark disc, the picture, the tracking button's gold ring.
	button.Background = button:CreateTexture(nil, "BACKGROUND")
	button.Background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	button.Background:SetSize(20, 20)
	button.Background:SetPoint("TOPLEFT", 7, -5)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	-- Made at PLAYER_LOGIN, when the player's class is known: the icon in its colour.
	button.Icon:SetTexture(ns.Journal.ClassIcon())
	button.Icon:SetTexCoord(unpack(ns.Journal.ICON_CROP))
	button.Icon:SetSize(19, 19)
	button.Icon:SetPoint("TOPLEFT", 6, -5)
	if button.CreateMaskTexture and button.Icon.AddMaskTexture then
		local mask = button:CreateMaskTexture()
		mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetAllPoints(button.Icon)
		button.Icon:AddMaskTexture(mask)
	end
	button.Border = button:CreateTexture(nil, "OVERLAY")
	button.Border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	button.Border:SetSize(53, 53)
	button.Border:SetPoint("TOPLEFT")
	button.Glow = CreateGlow(button)

	button:SetScript("OnClick", function(_, mouseButton) Click(mouseButton) end)
	button:SetScript("OnEnter", ShowTooltip)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- Round the edge with the cursor, only while it is held.
	button:SetScript("OnDragStart", function(self)
		GameTooltip:Hide()
		self:SetScript("OnUpdate", function()
			local angle = CursorAngle()
			if angle then
				ns.db.minimapAngle = angle
				Place(self, angle)
			end
		end)
	end)
	button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

	Place(button, ns.db.minimapAngle or DEFAULT_ANGLE)
	SetShown(button, MinimapButton.Shows())
	self.button = button
	self:UpdateGlow()
	return button
end

--[[
	The minimap's addon menu (above): AddonCompartmentFrame, as Forever's own code has it (Blizzard_Minimap's
	AddonCompartment.lua, its Mainline file with Camelot's overrides, client 1.60.1.70959, read 2026-11-20). It
	lists an addon by its TOC's ## AddonCompartmentFunc lines, read once at the first PLAYER_ENTERING_WORLD, or by
	RegisterAddon(info) at any time, which adds info to its list and shows the count. Of info it reads text, icon,
	func, funcOnEnter and funcOnLeave: func gets the menu's input (its buttonName, the mouse button: each line takes
	any button), funcOnEnter and funcOnLeave the line. It has no way to take a line out again, and the journal never
	writes its list (the game's code would then run on the journal's taint). So the line is registered at login
	while its box is ticked, or when the box is ticked later, and never twice; unticked, it stays until the next
	/reload, which leaves it out (the box's tooltip says so). The menu reads the line, which the journal wrote, each
	time it opens; a menu the journal once built in the game's menu system left the game's unit menus blocked
	(UI/Art.lua), so a taint log in game tells whether this line does anything like it. Unticked (and a /reload),
	the menu is the client's alone.
]]
local MENU_ICON = "Interface\\AddOns\\Aegis_Forever_Instance_Journal\\Media\\IconSmall"

function MinimapButton.InMenu()
	return not (ns.db and ns.db.hideAddonMenu)
end

-- The journal's line, added once while it is wanted, where the client has the menu.
function MinimapButton:AddToMenu()
	local menu = AddonCompartmentFrame
	if self.menuEntry or not MinimapButton.InMenu() or type(menu) ~= "table" or type(menu.RegisterAddon) ~= "function" then
		return
	end
	self.menuEntry = {
		text = L.OPTIONS_TITLE,
		icon = MENU_ICON,
		func = function(_, input) Click(type(input) == "table" and input.buttonName or nil) end,
		funcOnEnter = function(line) if type(line) == "table" then Tooltip(line, false) end end,
		funcOnLeave = function() GameTooltip:Hide() end,
	}
	menu:RegisterAddon(self.menuEntry)
end

-- The box: ticked, the line is added now if it isn't there yet; unticked, the next load leaves it out.
function MinimapButton.SetInMenu(shown)
	ns.db.hideAddonMenu = not shown or nil
	if shown then MinimapButton:AddToMenu() end
end

-- At login: the button, and the menu's line.
function MinimapButton:Login()
	self:Create()
	self:AddToMenu()
end

local events = CreateFrame("Frame")
ns.RegisterEvents(events, "PLAYER_LOGIN")
events:SetScript("OnEvent", function() MinimapButton:Login() end)
