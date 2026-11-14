local addonName, ns = ...
local L = ns.L

--[[
	The question of the journal's style (Core/Style.lua): Classic, Modern or Custom, three boxes side
	by side in the look of Forever's own Classic or Enhanced choice. Each box has its name in gold,
	a short description, and "Starting Settings:" with what it turns on and off. A click on a box
	chooses it; Custom then opens the journal's options, where each feature has its own box.

	Asked once of each character, at its first login with the journal: at the first
	PLAYER_ENTERING_WORLD after logging in, and only when the player can see it and answer: once combat
	ends, once a cinematic (a new character's intro) is over, and once the game's settings window and
	game menu are closed. Not when the journal is opened.

	Only the player's own answer counts: a box clicked, its X, or Escape. Closed with the X or Escape,
	that character stays Modern and is not asked again. Closed by the game instead (it shuts every
	window for a cinematic, a loading screen, death, a loss of control or its game menu), it is asked
	again once the world is back: a frame after the cinematic ends or the interface shows again, when
	the player is alive or in control again, once the game menu closes, or at the next loading screen
	or login; never to a dead player, over the game's death dialog. Hidden with the game's interface
	(Alt+Z), it comes back with it: in Classic Era as it was; in Forever, whose interface shuts every
	window as it shows again (even when Escape brings it back), a frame later and still unanswered.
	/aegis style shows it again, and the options' Reset asks this character again.

	Built from the game's own art, by path, the same files in Classic Era and Forever: the collections'
	dark leather tile for the fill, the quest log's bullet and highlight, the game's fonts and close
	button. The border is the journal's own picture (Media/PopupBorder.tga), drawn to the measure of
	Forever's panels, so both clients show the same one.
]]

local StylePopup = {}
ns.StylePopup = StylePopup

local FRAME_NAME = "AegisJournalStylePopup"
local BOX_WIDTH, BOX_HEIGHT, BOX_GAP = 290, 340, 44
local HEADER, FOOTER = 78, 44
-- Where "Starting Settings:" sits in every box, so the three lists line up whatever the descriptions.
local LIST_TOP = -164
local TEXT_INSET = 24
-- The lines under it: indented for their bullets, and running a little nearer the right edge than the
-- description, so the longest (Custom's first, in Chinese) stays on one line.
local LINE_INDENT, LINE_RIGHT = 16, 20
-- The name's size: its font object's own (12 in most languages, 15 in Chinese) and 2 more, a little
-- under the game's large font, as on Forever's own choice. The rest of the text keeps its font
-- object's own small sizes.
local TITLE_GROW = 2

-- The fill: the leather tile, opaque, tinted to the warm dark brown of Forever's panels, and shaded
-- darker toward the top as theirs are.
local FILL = "Interface\\Collections\\CollectionsBackgroundTile"
local FILL_COLOR = { 0.67, 0.6, 0.5 }
local FILL_SHADE = 0.5
-- The border, as on Forever's panels: a band of bronze and brown lines about 7 units deep, lit from the
-- top left, its corners cut at 45 degrees BORDER_CUT units along each side with a band of their own
-- CUT_WIDTH deep, and a dark rim up to BORDER_RIM units deep just inside it. Its picture (made by
-- Dev/make_popup_border.py) is laid out as a backdrop's edge, each cell drawn EDGE_SIZE units square,
-- big enough to hold a cut with its band and rim, so the corners meet the edges without a seam.
local EDGE = "Interface\\AddOns\\" .. addonName .. "\\Media\\PopupBorder"
local EDGE_SIZE = 28
-- Each side's depth: Forever's left side is a little thinner than the others.
local BORDER_LEFT, BORDER_RIGHT, BORDER_TOP, BORDER_BOTTOM = 6.65, 7, 7, 7
local BORDER_CUT, CUT_WIDTH, BORDER_RIM = 9.5, 7.5, 4.5
-- The fill starts under the border: more than half the cut in, so its corners stay inside the cut
-- corners, and less than the border's depth, so no gap opens between them.
local EDGE_INSET = 6
local BULLET = "Interface\\QuestFrame\\UI-Quest-BulletPoint"
local HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
-- The picture's colours are stored divided by BORDER_COLOR, so that tint shows them as drawn and
-- BORDER_LIT brightens every line. The tint is nearly grey so the picture can hold the top-left cut's
-- pale highlight.
local BORDER_COLOR, BORDER_LIT = { 0.75, 0.73, 0.76 }, { 0.99, 1, 0.99 }
-- A softer gold than the game's for the names, cream for the words, as on the reference.
local GOLD, CREAM, CREAM_DIM = { 0.85, 0.76, 0.48 }, { 0.9, 0.87, 0.78 }, { 0.8, 0.77, 0.7 }
local DOT = { 0.9, 0.78, 0.45 }
local HINT, HINT_LIT = { 0.62, 0.58, 0.5 }, { 0.5, 0.9, 0.4 }
local BLACK = { 0, 0, 0 }
-- The title, the line under it and the note at the foot sit on the game's world, with nothing behind
-- them: outlined, as the game's own zone names are, so they read on snow as on grass. The words in the
-- boxes keep their font objects' own shadow.
local WORLD_OUTLINE = "OUTLINE"

local frame
-- The question waits to be shown (at login, after Reset or /aegis style, or after the game closed it).
local due
-- Hidden by the game's closing of its windows, not yet known to be Escape's (see EscapePressed).
local closing
-- Hidden by the player's own X or choice (StylePopup:Hide), which answers it.
local byPlayer
-- The game's settings window just closed this frame; the game's interface just shown again this frame.
local settingsClosed, interfaceBack
-- Up when the game's interface was hidden (Alt+Z): a frame the game hides while it cannot be seen hears
-- no OnHide, so the interface's return looks for it (Watch).
local hiddenWithInterface
-- Custom chosen in combat: the journal's options open once combat ends.
local optionsAfterCombat
-- After the game shut the question, what else says the world is back: the player alive again (released
-- or raised), a ghost raised, control back after a fear or a stun.
local worldBack = { "PLAYER_ALIVE", "PLAYER_UNGHOST", "PLAYER_CONTROL_GAINED" }

-- The border's measures and colours, for the smoke test.
StylePopup.BORDER = { file = EDGE, edgeSize = EDGE_SIZE, inset = EDGE_INSET, cut = BORDER_CUT, cutWidth = CUT_WIDTH,
	rim = BORDER_RIM, width = { left = BORDER_LEFT, right = BORDER_RIGHT, top = BORDER_TOP, bottom = BORDER_BOTTOM },
	color = BORDER_COLOR, lit = BORDER_LIT }

-- What a box lists under "Starting Settings:": each feature on or off in the style, or Custom's
-- "your choice". From the presets themselves (Core/Style.lua), so the lists cannot drift from them.
function StylePopup.Lines(choice)
	local lines = {}
	local preset = ns.Style.PRESETS[choice]
	for _, feature in ipairs(ns.Style.FEATURES) do
		local name = L[feature.name]
		local text
		if not preset then
			text = string.format(L.STYLE_LINE_CHOOSE, name)
		elseif preset[feature.key] ~= false then
			text = string.format(L.STYLE_LINE_ON, name)
		else
			text = string.format(L.STYLE_LINE_OFF, name)
		end
		lines[#lines + 1] = text
	end
	return lines
end

-- Lit (hovered, or the style now): the border brightens and the hint turns green.
local function Paint(box, lit)
	if box.SetBackdropBorderColor then
		local color = lit and BORDER_LIT or BORDER_COLOR
		box:SetBackdropBorderColor(color[1], color[2], color[3])
	end
	local hint = lit and HINT_LIT or HINT
	box.Hint:SetTextColor(hint[1], hint[2], hint[3])
end

-- A font string from one of the game's font objects (the right font for each language), in its
-- colour and, if given, that many points larger than the font object's own size for the language, and
-- with those font flags (an outline) in place of the font object's.
local function Text(parent, template, color, grow, outline)
	local text = parent:CreateFontString(nil, "OVERLAY", template)
	if grow or outline then
		local font, size, flags = text:GetFont()
		if font and size then text:SetFont(font, size + (grow or 0), outline or flags) end
	end
	text:SetTextColor(color[1], color[2], color[3])
	return text
end

local function CreateBox(parent, choice, index)
	local box = ns.CreateFrameWithTemplate("Button", nil, parent, "BackdropTemplate")
	box.choice = choice
	box:SetSize(BOX_WIDTH, BOX_HEIGHT)
	box:SetPoint("TOPLEFT", parent, "TOPLEFT", (index - 1) * (BOX_WIDTH + BOX_GAP), -HEADER)
	-- A level above the popup's own frame.
	box:SetFrameLevel(parent:GetFrameLevel() + 1)
	if box.SetBackdrop then
		box:SetBackdrop({ bgFile = FILL, edgeFile = EDGE, tile = true, tileSize = 256, edgeSize = EDGE_SIZE,
			insets = { left = EDGE_INSET, right = EDGE_INSET, top = EDGE_INSET, bottom = EDGE_INSET } })
		box:SetBackdropColor(FILL_COLOR[1], FILL_COLOR[2], FILL_COLOR[3], 1)
	end
	-- Over the fill, under the border: darker at the top, nothing at the bottom.
	box.Shade = box:CreateTexture(nil, "BACKGROUND", nil, 1)
	box.Shade:SetPoint("TOPLEFT", EDGE_INSET, -EDGE_INSET)
	box.Shade:SetPoint("BOTTOMRIGHT", -EDGE_INSET, EDGE_INSET)
	ns.Gradient(box.Shade, "VERTICAL", BLACK, 0, FILL_SHADE)

	box.Highlight = box:CreateTexture(nil, "HIGHLIGHT")
	box.Highlight:SetTexture(HIGHLIGHT)
	box.Highlight:SetBlendMode("ADD")
	box.Highlight:SetVertexColor(GOLD[1], GOLD[2], GOLD[3])
	box.Highlight:SetAlpha(0.06)
	-- Within the border's inner edge, as this layer draws above the border.
	box.Highlight:SetPoint("TOPLEFT", BORDER_LEFT, -BORDER_TOP)
	box.Highlight:SetPoint("BOTTOMRIGHT", -BORDER_RIGHT, BORDER_BOTTOM)

	box.Title = Text(box, "GameFontNormal", GOLD, TITLE_GROW)
	box.Title:SetPoint("TOP", 0, -24)
	box.Title:SetText(ns.Style.Name(choice))

	box.Description = Text(box, "GameFontHighlight", CREAM)
	box.Description:SetPoint("TOP", box.Title, "BOTTOM", 0, -28)
	box.Description:SetWidth(BOX_WIDTH - 2 * TEXT_INSET)
	box.Description:SetJustifyH("CENTER")
	box.Description:SetText(ns.Style.Description(choice))

	box.Heading = Text(box, "GameFontHighlight", CREAM)
	box.Heading:SetPoint("TOPLEFT", TEXT_INSET, LIST_TOP)
	box.Heading:SetText(L.STYLE_STARTING)

	box.Lines, box.Bullets = {}, {}
	local above = box.Heading
	for lineIndex, text in ipairs(StylePopup.Lines(choice)) do
		local line = Text(box, "GameFontHighlightSmall", CREAM_DIM)
		line:SetPoint("TOPLEFT", above, "BOTTOMLEFT", lineIndex == 1 and LINE_INDENT or 0, lineIndex == 1 and -10 or -6)
		line:SetWidth(BOX_WIDTH - TEXT_INSET - LINE_INDENT - LINE_RIGHT)
		line:SetJustifyH("LEFT")
		line:SetText(text)
		local bullet = box:CreateTexture(nil, "OVERLAY")
		bullet:SetTexture(BULLET)
		bullet:SetVertexColor(DOT[1], DOT[2], DOT[3])
		bullet:SetSize(12, 12)
		bullet:SetPoint("TOPRIGHT", line, "TOPLEFT", -4, 1)
		box.Lines[lineIndex], box.Bullets[lineIndex] = line, bullet
		above = line
	end

	box.Hint = Text(box, "GameFontNormalSmall", HINT)
	box.Hint:SetPoint("BOTTOM", 0, 20)

	box:SetScript("OnEnter", function(self) Paint(self, true) end)
	box:SetScript("OnLeave", function(self) Paint(self, self.choice == ns.Style:Choice()) end)
	box:SetScript("OnClick", function(self) StylePopup:Choose(self.choice) end)
	return box
end

local events = CreateFrame("Frame")

-- The player's own answer (a box, the X or Escape): not asked again, and the events for its return let go.
-- Pawn's question, held while this one was up or waiting, comes after.
local function Answered()
	due = nil
	ns.Style:MarkAsked()
	ns.UnregisterEvents(events, unpack(worldBack))
	if C_Timer and C_Timer.After then C_Timer.After(1, function() ns.PawnLink:Check() end) end
end

-- The game's interface away: a cinematic playing, or the interface hidden (Alt+Z, a movie).
local function InterfaceAway()
	return (InCinematic and InCinematic()) or not UIParent:IsShown()
end

-- Closed by the game's ToggleGameMenu (the Escape key's own function), which shuts it with every other
-- window, after this frame's OnHide: Escape, the player's. Not the call the settings window makes as
-- it closes, to go back to the game menu; nor Escape bringing back an interface hidden with Alt+Z in
-- Forever, where it is the interface's return that shuts every window (see Watch).
local function EscapePressed()
	if closing and not settingsClosed and not interfaceBack then
		closing = nil
		Answered()
	end
end

-- A frame on from a close no Escape claimed: the game's own (a cinematic's start, a loading screen,
-- death, a loss of control, the game menu, the interface back in Forever). Asked again once the
-- world is back (Try): a frame after the cinematic ends, the interface shows again or the game menu
-- closes (Watch), when the player is alive or in control again, or at the next loading screen or
-- login (PLAYER_ENTERING_WORLD).
local function Settle()
	if not closing then return end
	closing = nil
	if frame:IsShown() or ns.Style:Asked() then return end
	due = true
	ns.RegisterEvents(events, unpack(worldBack))
	if InterfaceAway() then ns.RegisterEvents(events, "CINEMATIC_STOP") end
end

-- One of the game's windows open (its settings window, its game menu): the question would show over
-- it, around and between its boxes.
local function Showing(window)
	return window ~= nil and type(window.IsShown) == "function" and window:IsShown()
end

local Try

--[[
	What the question waits for, watched from the first time it is due out of combat (Try, before it is
	ever shown). Each only tries again a frame later, which does nothing unless the question is due.
	- The settings window's own OnHide tells EventRegistry, in both clients. Its Close then goes back to
	  the game menu (ToggleGameMenu), which shuts every window it finds open, or else shows the game
	  menu: that call is not taken for the player's Escape (EscapePressed), and a question held for the
	  window then waits for the game menu.
	- The game menu hidden.
	- The game's interface shown again (UIParent's OnShow, after Alt+Z or a movie). Forever's UIParent
	  shuts every window as it shows (Blizzard_Game's UI.TopLevelParentShown), before this hook runs,
	  even inside ToggleGameMenu when Escape brings the interface back: that close is the game's, not
	  the player's Escape. Classic Era's shuts none (its UIParent_OnShow's close never runs). A question
	  that was up when the interface went and is gone now was shut by the game, whether or not it
	  heard its OnHide; settled here first (Settle), whether or not its own frame-later settling has run.
	Hooked out of combat only, UIParent being a protected frame in Classic Era, and each hook in a
	pcall: a hook the client refused would cost only that way back, never the question.
]]
local watching = {}
local function Watch()
	if not watching.settings and EventRegistry and EventRegistry.RegisterCallback then
		watching.settings = true
		EventRegistry:RegisterCallback("SettingsPanel.OnHide", function()
			settingsClosed = true
			C_Timer.After(0, function()
				settingsClosed = nil
				-- The way back to the game menu may have shut the question: the game's close, settled first.
				Settle()
				Try()
			end)
		end, StylePopup)
	end
	if not watching.menu and GameMenuFrame and GameMenuFrame.HookScript then
		watching.menu = true
		pcall(GameMenuFrame.HookScript, GameMenuFrame, "OnHide", function() C_Timer.After(0, Try) end)
	end
	if not watching.interface then
		watching.interface = true
		pcall(UIParent.HookScript, UIParent, "OnShow", function()
			interfaceBack = true
			if hiddenWithInterface then
				hiddenWithInterface = nil
				if frame and not frame:IsShown() and not ns.Style:Asked() then closing = true end
			end
			C_Timer.After(0, function()
				interfaceBack = nil
				Settle()
				Try()
			end)
		end)
	end
end

local function Create()
	local width = #ns.Style.CHOICES * BOX_WIDTH + (#ns.Style.CHOICES - 1) * BOX_GAP
	local f = CreateFrame("Frame", FRAME_NAME, UIParent)
	f:SetSize(width, HEADER + BOX_HEIGHT + FOOTER)
	f:SetPoint("CENTER", 0, 20)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	-- Nothing behind the boxes, so the game shows around and between them, and a click there reaches it.
	-- The boxes and the close X take their own clicks.
	f:EnableMouse(false)
	f:Hide()

	f.Title = Text(f, ns.Font("GameFontNormalHuge", "GameFontNormalLarge"), GOLD, nil, WORLD_OUTLINE)
	f.Title:SetPoint("TOP", 0, -8)
	f.Title:SetText(L.STYLE_TITLE)
	f.Subtitle = Text(f, "GameFontHighlight", CREAM, nil, WORLD_OUTLINE)
	f.Subtitle:SetPoint("TOP", f.Title, "BOTTOM", 0, -10)
	f.Subtitle:SetText(L.STYLE_SUBTITLE)

	f.Boxes = {}
	for index, choice in ipairs(ns.Style.CHOICES) do f.Boxes[index] = CreateBox(f, choice, index) end

	-- In the dim cream of the boxes' lines, not the hint's darker shade, which was chosen for a black veil.
	f.Note = Text(f, "GameFontDisable", CREAM_DIM, nil, WORLD_OUTLINE)
	f.Note:SetPoint("BOTTOM", 0, 10)

	f.CloseButton = ns.CreateFrameWithTemplate("Button", nil, f, "UIPanelCloseButton")
	f.CloseButton:SetPoint("TOPRIGHT", 4, 4)
	f.CloseButton:SetScript("OnClick", function() StylePopup:Hide() end)

	f:SetScript("OnHide", function()
		-- Hidden with the game's interface (Alt+Z): still up, and back with it (in Forever, then shut as the
		-- interface returns: a close of the game's, below or in Watch). Or closed by the player's X or
		-- choice, which answered it already.
		if f:IsShown() then
			hiddenWithInterface = true
			return
		end
		if byPlayer then return end
		-- Shut with the game's windows: Escape's if ToggleGameMenu comes back next, else the game's own.
		closing = true
		if C_Timer and C_Timer.After then C_Timer.After(0, Settle) end
	end)
	table.insert(UISpecialFrames, FRAME_NAME)
	-- Escape is the client's ToggleGameMenu, in both clients; hooked once the game's interface has loaded.
	if type(ToggleGameMenu) == "function" then hooksecurefunc("ToggleGameMenu", EscapePressed) end
	return f
end

function StylePopup:Show()
	frame = frame or Create()
	due = nil
	local current = ns.Style:Choice()
	frame.Note:SetText(string.format(L.STYLE_CLOSE_NOTE, ns.Style.Name(current)))
	for _, box in ipairs(frame.Boxes) do
		box.Hint:SetText(box.choice == current and L.STYLE_NOW or L.STYLE_CLICK)
		Paint(box, box.choice == current)
	end
	frame:Show()
	ns.PlaySoundKit("IG_MAINMENU_OPEN")
end

-- Closed by the player (its X, or a box chosen): answered.
function StylePopup:Hide()
	if frame and frame:IsShown() then
		byPlayer = true
		frame:Hide()
		byPlayer = nil
		ns.PlaySoundKit("IG_MAINMENU_CLOSE")
		Answered()
	end
end

function StylePopup:IsShown()
	return frame ~= nil and frame:IsShown()
end

-- Up, or waiting to be shown: Pawn's question waits for it (Core/PawnLink.lua).
function StylePopup:IsPending()
	return self:IsShown() or due == true
end

-- The popup's frame, for the smoke test and the preview.
function StylePopup:Frame()
	return frame
end

-- A box clicked: that style, and for Custom the journal's options, to tick each feature there. In
-- combat the game opens no settings window for an addon, so they open once combat ends.
function StylePopup:Choose(choice)
	if not ns.Style:Choose(choice) then return end
	ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON")
	self:Hide()
	ns.Print(string.format(L.STYLE_CHOSEN, ns.Style.Name(choice)))
	if choice ~= "custom" then return end
	if InCombatLockdown() then
		optionsAfterCombat = true
		ns.RegisterEvents(events, "PLAYER_REGEN_ENABLED")
		ns.Print(L.STYLE_OPTIONS_AFTER_COMBAT)
	else
		ns.Options:Open()
	end
end

-- The question, if it is due, shown now if the player can see and answer it, or held till then: out of
-- combat (the same rule as the rest of the journal's windows), the player not dead (the game's death
-- dialog up: asked once released or raised), with the game's interface there (no cinematic playing),
-- and the game's settings window and game menu closed.
function Try()
	if not due then return end
	if StylePopup:IsShown() then
		due = nil
		return
	end
	if InCombatLockdown() then
		ns.RegisterEvents(events, "PLAYER_REGEN_ENABLED")
		return
	end
	Watch()
	-- Dead, not a ghost: the death dialog, where the boxes would lie over its Release Spirit. A hunter's
	-- Feign Death is no death.
	if UnitIsDead and UnitIsDead("player") and not (UnitIsFeignDeath and UnitIsFeignDeath("player")) then
		ns.RegisterEvents(events, unpack(worldBack))
		return
	end
	if InterfaceAway() then
		ns.RegisterEvents(events, "CINEMATIC_STOP")
		return
	end
	if Showing(SettingsPanel) or Showing(GameMenuFrame) then return end
	ns.UnregisterEvents(events, "CINEMATIC_STOP")
	if not optionsAfterCombat then ns.UnregisterEvents(events, "PLAYER_REGEN_ENABLED") end
	StylePopup:Show()
end

--[[
	Every entering-world (each login, /reload and loading screen) while this character has not
	answered: the question. Combat's end: the options Custom asked for, then the question if it waits.
	A cinematic's end: the question a frame later, once the game has shown its interface again and
	closed its windows as it does then. Alive again, a ghost raised or control back, after the game shut
	the question or while it waited for the player to be alive: the question, if nothing else holds it.
]]
ns.RegisterEvents(events, "PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if not ns.Style:Asked() then due = true end
		Try()
	elseif event == "PLAYER_REGEN_ENABLED" then
		ns.UnregisterEvents(events, "PLAYER_REGEN_ENABLED")
		if optionsAfterCombat then
			optionsAfterCombat = nil
			ns.Options:Open()
		end
		Try()
	elseif event == "CINEMATIC_STOP" then
		C_Timer.After(0, Try)
	else
		Try()
	end
end)

-- Asked again of this character (the options' Reset), or shown again (/aegis style): out of combat,
-- the game's settings window shut first (Options:CloseSettings), as the player is in it or about to be
-- asked over it; then shown when it can be (Try).
function StylePopup:Ask()
	due = true
	if not InCombatLockdown() then ns.Options:CloseSettings() end
	Try()
end
