local _, ns = ...
local L = ns.L

--[[
	The run block: the dungeon the player is in, as the game's own objective tracker would show a run, beside it.

	Top to bottom: the dungeon's name in a header like the tracker's own header it sits next to (the owner's call,
	2026-11-12): above the tracker or placed freely, like its "All Objectives" (the dark bar with the ornate ends and
	its red-square collapse-all button, 0.39.20's), so the block reads as a tracker of its own; under the quests or
	inside the tracker, like its sections' ("Quests": their bar with its thin line and their own collapse button,
	0.39.21's), so it reads as one more section (STYLES, RunTracker.StyleFor); the keystone timer's gold
	frame (ChallengeMode-Timer), with one circle per boss along its top (the same round faces as the dungeon map's
	boss pins, crossed out with the map's own defeated mark: UI/DungeonMap.lua's BuildFace), the run's time, the clock's
	two small buttons (start, pause or resume it; a new run: RunTracker.CONTROLS) and the bosses down out of those
	counted; under it a bar that fills one step per boss killed (it is not a timer);
	then a line per boss, "0/1 <Boss> defeated" with the tracker's gold dot, "1/1 <Boss> defeated" with its green
	check in its grey for done lines, as the client's scenario criteria read; then experience, money and items.
	The run itself, its kills and its numbers are Core/Run.lua's.

	All of it is the journal's own frame, parented to UIParent, built from the client's atlases and font objects.
	It never becomes part of the game's tracker: no module of the tracker's manager, no top padding provider, no
	hook on its methods or scripts, nothing written into ObjectiveTrackerFrame or its tables, no SetPoint on it,
	no template of its (the header is drawn by hand with the template's atlases and sizes); it only reads where the
	tracker is (GetTop, IsShown, isCollapsed, moduleSpacing, bottomModulePadding, its NineSlice, Header and
	gamepadFooter as anchors) and the tint of its section headers' art (RunTracker.TrackerTint). No game menu either.
	Placement: above the tracker where there is room between
	its top and the minimap (or the screen's top), so the dungeon's header is the topmost one and the game's "All
	Objectives" comes under the block (held there by its top, so a collapse leaves the header where it was, as the
	tracker's own does); else docked under what the tracker shows; or anywhere the player drags it ("Place it
	freely", on by default since 0.39.23: by the tracker as above until first dragged, or at its own spot while the
	tracker is hidden or off the screen, RunTracker:Anchor; a lock on its header keeps it in place then: LOCK).
	Either way it keeps the tracker's own space between its sections from it. It follows Edit Mode moves through its anchor. Clamped to the screen. The one exception, off by default (ticked in the options): placing it inside the
	tracker, under its "All Objectives" (UI/RunTrackerInside.lua, which says what it hands the tracker).

	Its header's art (bar and button) takes the tint of the tracker's own header it is drawn like ("All Objectives"
	or "Quests" first), so a dark-mode UI that darkens the game's tracker darkens the block with it; "Dark mode"
	darkens it without one (RunTracker:Paint).

	Its clock ticks once a second, only while the block shows and is not collapsed. It waits at 0:00 until the run's
	first pull (Core/Run.lua), grayed, as it is while the player has paused it.

	Test mode (UI/TestPanel.lua, "Pretend I'm inside") shows a pretend run here, outside a dungeon only, through one
	seam (RunTracker:View asks UI/TestRun.lua's Source; a real run inside always wins): the same view and layout as a
	real run's (RunTracker:ViewOf), "(test)" after its name; its clock button, New run and its circles (a click marks
	the fight killed or standing again) are the pretend run's, never the real one's.
]]

local RunTracker = {}
ns.RunTracker = RunTracker
local Run = ns.Run

-- The client's art (its atlas tables, read 2026-11-11 and 2026-11-12). The header's is in STYLES, below.
local ART = {
	frame = "ChallengeMode-Timer",
	barBack = "ChallengeMode-TimerBG-back",
	barBG = "ChallengeMode-TimerBG",
	barFill = "ChallengeMode-TimerFill",
	ring = "ChallengeMode-AffixRing-Sm",
	check = "ui-questtracker-tracker-check",
	nub = "ui-questtracker-objective-nub",
	skull = "dungeonskull",
}
RunTracker.ART = ART

--[[
	The header's two looks, as the client's XML draws them, each with its art, its sizes in UI units and its button's
	states (the header mixins' SetCollapsed swapping collapse and expand, the pressed ones as the buttons' PushedTexture):
	- objectives: the tracker's own header, "All Objectives" (Blizzard_ObjectiveTrackerContainer.xml:
	  ObjectiveTrackerContainerHeaderTemplate, 260 x 32, its Background atlas at its own size, 300 x 40 centered: 4 over
	  its top (over); its text at 7, 208 wide; its MinimizeButton (ObjectiveTrackerContainerMinimizeButtonTemplate)
	  18 x 19 at the right -1, collapse-all / expand-all and the red highlight). The first thing under it 38 down, where
	  the container puts its first section (Blizzard_ObjectiveTrackerContainer.lua's BASE_TOP_PADDING).
	- quests: a section's header, "Quests" (Blizzard_ObjectiveTrackerModule.xml: ObjectiveTrackerModuleHeaderTemplate,
	  260 x 26, its Background 300 x 30 centered: 2 over its top; its text at 7, 200 wide; its MinimizeButton
	  (ObjectiveTrackerModuleMinimizeButtonTemplate) 16 x 16 at the right +1, the secondary collapse / expand and the
	  yellow highlight). The first thing under it 36 down: 10 under the header, the module's fromHeaderOffsetY.
	Both texts in ObjectiveTrackerHeaderFont, one line, shrunk to fit down to a 12 line height (headerMinLine).
]]
local STYLES = {
	objectives = {
		name = "objectives", label = "All Objectives",
		header = "ui-questtracker-primary-objective-header",
		collapse = "ui-questtrackerbutton-collapse-all",
		collapsePressed = "ui-questtrackerbutton-collapse-all-pressed",
		expand = "ui-questtrackerbutton-expand-all",
		expandPressed = "ui-questtrackerbutton-expand-all-pressed",
		highlight = "ui-questtrackerbutton-red-highlight",
		height = 32, text = 208, button = 18, buttonHeight = 19, buttonX = -1, contentTop = 38, over = 4,
	},
	quests = {
		name = "quests", label = "Quests",
		header = "ui-questtracker-secondary-objective-header",
		collapse = "ui-questtrackerbutton-secondary-collapse",
		collapsePressed = "ui-questtrackerbutton-secondary-collapse-pressed",
		expand = "ui-questtrackerbutton-secondary-expand",
		expandPressed = "ui-questtrackerbutton-secondary-expand-pressed",
		highlight = "ui-questtrackerbutton-yellow-highlight",
		height = 26, text = 200, button = 16, buttonHeight = 16, buttonX = 1, contentTop = 36, over = 2,
	},
}
RunTracker.STYLES = STYLES

--[[
	Sizes, in UI units: the client's tracker and keystone block (Blizzard_ObjectiveTracker XML: 10 between sections
	(its moduleSpacing) and its background 10 under the last one (bottomModulePadding); the keystone frame 251 x 87,
	its bar 207 x 13 at the bottom +10 over the TimerBG at +13; the line icon 16 x 16 at -10, 2), and the mock-up the
	owner approved for the rest: the circles from 16 down, centred between the frame's inner edges (28 to 223), 22
	across at most, a second row above 8 bosses; boss lines 22 apart, number lines 17. The header's: STYLES.
]]
local SIZE = {
	width = 260, headerMinLine = 12, sectionGap = 10, slicePadding = 10,
	frameWidth = 251, frameHeight = 87, innerLeft = 28, innerWidth = 195,
	ringTop = 16, ringMax = 22, ringGap = 4, ringGapTight = 3, rowGap = 4, oneRow = 8,
	barWidth = 207, barHeight = 13, barBottom = 10, barBackBottom = 13,
	clockGap = 5, countDown = 5, skull = 15, check = 16,
	afterFrame = 12, lineX = 32, iconX = -10, iconY = 2, icon = 16,
	bossPitch = 22, completePitch = 20, numberPitch = 17, numbersGap = 4, lineFont = 12,
	fallbackX = -110, fallbackY = -275,
	-- Placed freely, never dragged, the game's tracker hidden or off the screen: the block's own spot (RunTracker:Anchor).
	freeX = -400, freeY = -275,
}
RunTracker.SIZE = SIZE

-- The tracker's colours (OBJECTIVE_TRACKER_COLOR: Normal 0.8, Complete 0.6) and the header's gold. The clock waiting
-- for the first pull or paused: the gray of its font's disabled twin (GameFontDisableHuge, FontStyles.xml: 0.5).
local NORMAL, COMPLETE, GOLD, WHITE = { 0.8, 0.8, 0.8 }, { 0.6, 0.6, 0.6 }, { 1, 0.82, 0 }, { 1, 1, 1 }
local IDLE = { 0.5, 0.5, 0.5 }
local RED = { 1, 0.125, 0.125 }
local DEFEATED_COLOR, OPEN_COLOR = { 0.1, 1, 0.1 }, { 0.8, 0.8, 0.8 }
local NORMAL_CODE, WHITE_CODE = "|cffcccccc", "|cffffffff"

--[[
	The clock's two buttons, between the time and the count (the owner's call of 2026-11-14: "a small button like we
	have for Spoken play", from a player's wish to start and stop the clock themselves while the group gathers at the
	door). Each has the Spoken button's look (UI/SpokenButton.lua, its numbers kept here, not shared, so that file
	stays its own): 14 square, the quest log's tracking checkbox for its box (QuestLog-icon-ticksquare), black at 0.6
	just inside it, its glyph 10 square at 0.85 and full under the mouse, the box's own atlas added over itself at 0.7
	for the highlight; grayed where it cannot be used (desaturated, the glyph at 0.4), its tooltip still shown.
	- The clock's: Play (the Spoken button's common-dropdown-icon-play) while the clock waits for the first pull, which
	  starts it now, or is paused, which resumes it; Pause while it runs. The client has no pause among its menus'
	  small icons (read 2026-11-14), so its pause is the credits screen's (creditsscreen-assets-buttons-pause: two gold
	  bars, in the gold of the menus' play; its square filled as the play's is, 22% to 83% across, so the same size at
	  10); without it, two gold bars drawn on a plain texture. Grayed once the clock has stopped (the final boss).
	- New run: two curved arrows making a circle, the client's one such icon (uitools-icon-refresh; the others, the
	  talents' undo and the reset buttons, are one arrow), white in the client, so given the gold of the play and pause
	  glyphs (the average of the play glyph's, read from its picture). It asks first (a popup of the journal's own, the
	  game's StaticPopup), then does what /ij run new does (Run:NewRun). Without the atlas, the classic refresh arrow
	  (Interface\Buttons\UI-RefreshButton), gold already.
	Where (SIZE.controls): centred 133 from the keystone frame's left, the clock's button left of the New run one, 4
	apart, their tops 4 under the clock's (their middles on the skull's). Measured with the client's own fonts
	(FRIZQT__ and the others, 2026-11-14): the widest time, 1:23:45 in the clock's font (20), reaches 101 from the
	frame's left (from 28; 102 with its shadow); the widest count, 16/16 in the count's (14), starts at 181, and the
	skull 2 left of it at 164. So 15 clear on each side then, and about as much each side with the usual 12:34 and 3/7.
	Shown with the open run inside its dungeon (not the last run shown outside); hidden with the keystone frame when the
	block is collapsed, and while the wing is waited for ("Which wing?": no frame).
	Taint: both are the journal's own buttons on its own frame, and a click runs only the journal's code (Core/Run.lua)
	and the game's StaticPopup. Beside the tracker, nothing of the game's is touched. Inside the tracker (the test
	option), a new run can change the room the block asks of the tracker (a new run's tallest height: UI/
	RunTrackerInside.lua's padding), and that has the tracker lay itself out from the journal's call, which in a fight
	is where its blocked actions came from: so with that option ticked, New run is grayed in combat (the game's own
	words for it on its tooltip, ERR_NOT_IN_COMBAT) and its popup's Yes refused then. The clock's button changes only the
	block's time and its color, never its height, so it works in combat either way, as the clock's own once-a-second
	update does.
]]
local CONTROLS = {
	box = "QuestLog-icon-ticksquare", play = "common-dropdown-icon-play", pause = "creditsscreen-assets-buttons-pause",
	restart = "uitools-icon-refresh",
	playFallback = "Interface\\ChatFrame\\ChatFrameExpandArrow", restartFallback = "Interface\\Buttons\\UI-RefreshButton",
	size = 14, glyph = 10, back = 0.6, glyphAlpha = 0.85, litAlpha = 0.7, grayedAlpha = 0.4,
	center = 133, gap = 4, down = 4,
	-- The play glyph's gold (its picture's average, 214/180/44 of 255), for the white refresh glyph.
	gold = { 0.84, 0.71, 0.17 },
}
RunTracker.CONTROLS = CONTROLS
local NEW_RUN_POPUP = "AEGIS_JOURNAL_NEW_RUN"

--[[
	The header's lock (the owner's ask of 2026-11-17: "a lock and unlock button - a literally icon", from the mock-up
	they approved; a click swaps the icon at once). Shown only while the block is placed freely (RunTracker:Free()),
	before its first drag too, and while it is collapsed (it is on the header); hidden beside the tracker or inside it.
	- Where: the second button's place on the client's "All Objectives" header (ObjectiveTrackerContainerHeaderTemplate
	  keeps it for its FilterButton): 18 x 19, its right 2 left of the collapse button's left. Its glyph centered 1
	  right and 1 up of the button's middle, level with the collapse button's rim; pressed, 1 down and right of that.
	  So its edges fall on whole UI units of the header (223 to 239 across, 7 to 23 down): whole pixels where one UI
	  unit is one pixel (UI scale = 768 / the screen's height).
	- Its glyphs: the AddOns list's padlocks (Interface\Glues\CharacterSelect\Glues-AddOn-Icons, a 64 x 16 sheet: the
	  closed one in its first quarter, the open one in its second), at their own 16 x 16 (pixel art: no other size).
	  The open one is dim in the client's colors (its brightest 156 of 255), so a copy of it is added over it (ADD, at
	  0.6) to read as bright as the closed one, not grayed. At 0.85 at rest, as the clock's buttons; under the mouse,
	  full, and a copy added at 0.5 (the client's HIGHLIGHT layer). Without that file (ns.FileExists): the classic lock
	  buttons' art (Interface\Buttons\LockButton-Locked-Up and -Unlocked-Up), 24 square, so their padlock is about as
	  big as the AddOns list's (a best guess), no copy added at rest. Its glyph takes the collapse button's tint
	  (RunTracker:Paint).
	- Locked (charDB.runLocked, per character, next to runSpot; on test mode's pretend block, the test's own: Kept;
	  unlocked by default; not the "Place it freely" option):
	  the closed lock, the header not dragged (RunTracker:StartDrag) and its tooltip without the drag line. Unlocked:
	  the open lock, dragged by the header as before. /ij run lock and /ij run unlock do the same; /ij run reset clears
	  it with the spot. The journal's own button on its own frame: it works in combat, nothing of the game's touched.
]]
local LOCK = {
	file = "Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons",
	closed = { 0, 0.25, 0, 1 }, open = { 0.25, 0.5, 0, 1 },
	lockedFallback = "Interface\\Buttons\\LockButton-Locked-Up",
	unlockedFallback = "Interface\\Buttons\\LockButton-Unlocked-Up",
	width = 18, height = 19, gap = 2, glyph = 16, fallbackGlyph = 24,
	x = 1, y = 1, pressedX = 2, pressedY = 0,
	alpha = 0.85, boost = 0.6, litAlpha = 0.5,
}
RunTracker.LOCK = LOCK

-- Above this many bosses, the lines show the next this many still standing, in the journal's order, and the last one
-- killed (the circles show all: the owner's call at the 0.39.20 release).
local LONG_LIST = 8

-- Font objects: the tracker's own where the client has them (its Text Size setting changes them, and the lines
-- with them), else the game's plain ones. Only used, never changed. A text given the plain one because the
-- tracker's had not loaded yet takes the tracker's once it is there (RunTracker:Refresh).
local fallbacks = {}
local function UseFont(region, name, fallback)
	local object = _G[name] and name or fallback
	if _G[object] and region.SetFontObject then region:SetFontObject(_G[object]) end
	region.fontObject = object
	fallbacks[region] = object ~= name and { name, fallback } or nil
end

local function TrackerFontsNow()
	for region, names in pairs(fallbacks) do
		if _G[names[1]] then UseFont(region, names[1], names[2]) end
	end
end

local function SetColor(region, color)
	region:SetTextColor(color[1], color[2], color[3])
	region.color = color
end

------------------------------------------------------------------------------------------
-- Building
------------------------------------------------------------------------------------------

local function ShowTooltip(owner, build)
	GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
	build(GameTooltip)
	GameTooltip:Show()
end

local function HideTooltip()
	GameTooltip:Hide()
end

-- The circle's tooltip: the boss, the fights it stands for (Sneed's Shredder, then Sneed), defeated or not yet.
local function CircleTooltip(circle)
	local shown = circle.shown
	if not shown then return end
	ShowTooltip(circle, function(tip)
		tip:SetText(shown.name, GOLD[1], GOLD[2], GOLD[3])
		local parts = shown.entry.parts
		if #parts > 1 then
			-- (each by the name the journal's pages give it: "???" until met, in Adventure Mode)
			local function Name(boss) return shown.instance and ns.Discovery:BossTitle(shown.instance, boss) or boss.name end
			local text = Name(parts[1])
			for index = 2, #parts do text = string.format(L.RUN_PARTS, text, Name(parts[index])) end
			tip:AddLine(text, 1, 1, 1, true)
		end
		if shown.dead then
			tip:AddLine(L.RUN_DEFEATED, DEFEATED_COLOR[1], DEFEATED_COLOR[2], DEFEATED_COLOR[3])
		else
			tip:AddLine(L.RUN_NOT_DEFEATED, OPEN_COLOR[1], OPEN_COLOR[2], OPEN_COLOR[3])
		end
		-- (test mode's pretend run: a click marks it, CircleClick)
		if shown.test then tip:AddLine(L.FOGTEST_PIN_CLICK, 0.5, 0.8, 1, true) end
	end)
end

-- A circle clicked: on test mode's pretend run, its fight killed in the run or standing again (UI/TestRun.lua's
-- ToggleEntry); on a real run, nothing, as before.
local function CircleClick(circle)
	local shown = circle.shown
	if not (shown and shown.test and ns.TestRun) then return end
	ns.PlaySoundKit(shown.dead and "IG_MAINMENU_OPTION_CHECKBOX_OFF" or "IG_MAINMENU_OPTION_CHECKBOX_ON")
	ns.TestRun:ToggleEntry(shown.entry, shown.instance)
	if GameTooltip:GetOwner() == circle and GameTooltip:IsShown() then CircleTooltip(circle) end
end

-- The header's tooltip: what the money is made of, each part with its rate.
local function HeaderTooltip(header)
	local view = RunTracker.view
	if not view then return end
	ShowTooltip(header, function(tip)
		tip:SetText(view.title, GOLD[1], GOLD[2], GOLD[3])
		if view.numbers then
			local function Money(label, copper)
				local rate = Run.PerHour(copper, view.seconds)
				tip:AddDoubleLine(label, ns.MoneyText(copper) .. (rate and "  (" .. string.format(L.RUN_PER_HOUR,
					Run.RateMoney(rate)) .. ")" or ""), NORMAL[1], NORMAL[2], NORMAL[3], 1, 1, 1)
			end
			Money(L.RUN_COIN, view.copper)
			Money(L.RUN_ITEM_VALUE, view.itemValue)
			if view.pending > 0 then tip:AddLine(string.format(L.RUN_PENDING, view.pending), NORMAL[1], NORMAL[2], NORMAL[3]) end
		end
		if RunTracker:Free() and not RunTracker:Locked() then tip:AddLine(L.RUN_DRAG, 0.5, 0.8, 1, true) end
		-- Beside a tracker too short for it with "Inside the quest tracker" on: how to make room (UI/RunTrackerInside.lua).
		local short = RunTracker.inside and RunTracker.inside:ShortText()
		if short then tip:AddLine(short, NORMAL[1], NORMAL[2], NORMAL[3], true) end
	end)
end

local function Circle(index)
	local circles = RunTracker.circles
	if circles[index] then return circles[index] end
	local circle = CreateFrame("Button", nil, RunTracker.block.Frame)
	ns.DungeonMap.BuildFace(circle, SIZE.ringMax - 2)
	circle.Ring = circle:CreateTexture(nil, "OVERLAY", nil, 1)
	circle.Ring:SetAtlas(ART.ring)
	circle.Ring:SetAllPoints(circle)
	circle:SetScript("OnEnter", CircleTooltip)
	circle:SetScript("OnLeave", HideTooltip)
	circle:SetScript("OnClick", CircleClick)
	circles[index] = circle
	return circle
end

-- A line as the tracker writes an objective: its icon (gold dot or green check) and its text.
local function Line(index)
	local lines = RunTracker.lines
	if lines[index] then return lines[index] end
	local block = RunTracker.block
	local line = { Icon = block:CreateTexture(nil, "ARTWORK"), Text = block:CreateFontString(nil, "OVERLAY") }
	line.Icon:SetSize(SIZE.icon, SIZE.icon)
	UseFont(line.Text, "ObjectiveTrackerLineFont", "GameFontHighlight")
	line.Text:SetJustifyH("LEFT")
	-- A line turning done fades its check in, as the tracker's own does (its animation is the tracker's: not used).
	if line.Icon.CreateAnimationGroup then
		line.Fade = line.Icon:CreateAnimationGroup()
		local alpha = line.Fade and line.Fade.CreateAnimation and line.Fade:CreateAnimation("Alpha")
		if alpha then
			alpha:SetFromAlpha(0)
			alpha:SetToAlpha(1)
			alpha:SetDuration(0.4)
		end
	end
	lines[index] = line
	return line
end

------------------------------------------------------------------------------------------
-- The clock's buttons (CONTROLS)
------------------------------------------------------------------------------------------

-- A glyph's atlas, else its file; true where the atlas was there.
local function SetGlyph(texture, atlas, fallback)
	if ns.AtlasExists(atlas) then
		texture:SetAtlas(atlas)
		return true
	end
	if fallback then texture:SetTexture(fallback) end
	return false
end

-- What a button shows now: its glyph (by kind: "play", "pause", "restart"), enabled or grayed, the glyph full under
-- the mouse. Drawn again only when that changes.
local function PaintControl(button)
	local glyph, enabled = button.glyphKind, button.usable == true
	if button.painted ~= glyph then
		button.painted = glyph
		local bars = button.Bars
		bars[1]:Hide()
		bars[2]:Hide()
		button.Glyph:Show()
		if glyph == "pause" then
			if not SetGlyph(button.Glyph, CONTROLS.pause) then
				-- No pause in this client's art: two gold bars, as the play glyph's gold.
				button.Glyph:Hide()
				bars[1]:Show()
				bars[2]:Show()
			end
		elseif glyph == "restart" then
			-- The client's refresh icon is white: gold, as the play glyph; its classic fallback is gold already.
			if SetGlyph(button.Glyph, CONTROLS.restart, CONTROLS.restartFallback) then
				button.goldTint = CONTROLS.gold
			else
				button.goldTint = nil
			end
		else
			SetGlyph(button.Glyph, CONTROLS.play, CONTROLS.playFallback)
		end
	end
	if button.SetEnabled then button:SetEnabled(enabled) end
	local alpha = not enabled and CONTROLS.grayedAlpha or (button.over and 1 or CONTROLS.glyphAlpha)
	for _, texture in ipairs({ button.Glyph, button.Bars[1], button.Bars[2] }) do
		texture:SetDesaturated(not enabled)
		texture:SetAlpha(alpha)
	end
	local tint = button.goldTint and button.glyphKind == "restart" and button.goldTint or nil
	if tint and enabled then
		button.Glyph:SetVertexColor(tint[1], tint[2], tint[3])
	else
		button.Glyph:SetVertexColor(1, 1, 1)
	end
	button.Box:SetDesaturated(not enabled)
	button.Lit:SetShown(enabled)
end

-- A button's tooltip: what it does, and why it is grayed where it is.
local function ControlTooltip(button)
	ShowTooltip(button, function(tip)
		tip:SetText(button.label or "", WHITE[1], WHITE[2], WHITE[3])
		if button.note then
			local color = button.noteColor or NORMAL
			tip:AddLine(button.note, color[1], color[2], color[3], true)
		end
	end)
end

local function ControlButton(parent, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(CONTROLS.size, CONTROLS.size)
	button:SetHitRectInsets(-2, -2, -2, -2)
	-- Its tooltip says why it is grayed: shown while it is disabled too.
	if button.SetMotionScriptsWhileDisabled then button:SetMotionScriptsWhileDisabled(true) end
	button.Back = button:CreateTexture(nil, "BACKGROUND")
	button.Back:SetPoint("TOPLEFT", 1, -1)
	button.Back:SetPoint("BOTTOMRIGHT", -1, 1)
	button.Back:SetColorTexture(0, 0, 0, CONTROLS.back)
	button.Box = button:CreateTexture(nil, "BORDER")
	button.Box:SetAllPoints()
	if ns.AtlasExists(CONTROLS.box) then button.Box:SetAtlas(CONTROLS.box) else button.Box:Hide() end
	button.Glyph = button:CreateTexture(nil, "ARTWORK")
	button.Glyph:SetSize(CONTROLS.glyph, CONTROLS.glyph)
	button.Glyph:SetPoint("CENTER")
	-- (the pause's fallback: two bars 3 wide, 8 high, 2 apart)
	button.Bars = {}
	for index = 1, 2 do
		local bar = button:CreateTexture(nil, "ARTWORK")
		bar:SetSize(3, 8)
		bar:SetPoint("CENTER", index == 1 and -2.5 or 2.5, 0)
		bar:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 1)
		bar:Hide()
		button.Bars[index] = bar
	end
	button.Lit = button:CreateTexture(nil, "HIGHLIGHT")
	button.Lit:SetAllPoints()
	if ns.AtlasExists(CONTROLS.box) then button.Lit:SetAtlas(CONTROLS.box) else button.Lit:SetColorTexture(1, 1, 1, 0.2) end
	button.Lit:SetBlendMode("ADD")
	button.Lit:SetAlpha(CONTROLS.litAlpha)
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self)
		self.over = true
		PaintControl(self)
		ControlTooltip(self)
	end)
	button:SetScript("OnLeave", function(self)
		self.over = false
		PaintControl(self)
		if GameTooltip:GetOwner() == self then HideTooltip() end
	end)
	-- Pressed, the glyph a pixel down and right, as the game's buttons press (and the Spoken button's).
	button:SetScript("OnMouseDown", function(self)
		if not self:IsEnabled() then return end
		self.Glyph:ClearAllPoints()
		self.Glyph:SetPoint("CENTER", 1, -1)
	end)
	button:SetScript("OnMouseUp", function(self)
		self.Glyph:ClearAllPoints()
		self.Glyph:SetPoint("CENTER")
	end)
	return button
end

-- New run waits until the fight is over, with "Inside the quest tracker" ticked (see CONTROLS). fight = true: a fight
-- just begun (PLAYER_REGEN_DISABLED, heard before the game's lockdown starts: test mode's panel, UI/TestPanel.lua).
function RunTracker:RestartBlocked(fight)
	local inside = self.inside
	return (fight == true or InCombatLockdown() == true) and inside ~= nil and inside:On() == true
end

--[[
	The popup's Yes: a new run, as /ij run new (refused in a fight with the test option ticked, and outside a dungeon).
	Asked by the pretend run's block (test mode) and answered on a real run, or the other way round (a real dungeon
	walked into, or the pretend run ticked, with the popup still up): nothing, the run it asked for gone (newRunFor:
	whether the block that asked showed the pretend run).
]]
function RunTracker:Restart()
	local asked = self.newRunFor
	self.newRunFor = nil
	local test = self.view ~= nil and self.view.test == true
	if asked ~= nil and asked ~= test then return false end
	if self:RestartBlocked() then
		ns.Print(L.RUN_TALLER_COMBAT)
		return false
	end
	-- (test mode's pretend run, UI/TestRun.lua: its own new run, the real one untouched)
	if self.view and self.view.test and ns.TestRun then return ns.TestRun:NewRun() end
	if not Run:NewRun() then
		ns.Print(L.RUN_NOT_INSIDE)
		return false
	end
	-- (the wing not known yet: nothing on the block changes until it is)
	if Run:WaitingForWing() then ns.Print(L.RUN_NEW_WING) end
	return true
end

StaticPopupDialogs[NEW_RUN_POPUP] = {
	text = L.RUN_RESTART_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function() RunTracker:Restart() end,
	OnCancel = function() RunTracker.newRunFor = nil end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- The clock's button: start, pause or resume, as the clock stands (Core/Run.lua's ToggleClock).
local function ClockClick(button)
	if not button.usable then return end
	-- (test mode's pretend run, UI/TestRun.lua: its own clock)
	local test = RunTracker.view and RunTracker.view.test and ns.TestRun
	local did
	if test then did = test:ToggleClock() else did = Run:ToggleClock() end
	if did then ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON") end
end

-- New run's: asks first (for the run the block shows: the pretend one or a real one, RunTracker:Restart).
local function RestartClick(button)
	if not button.usable then return end
	ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON")
	RunTracker.newRunFor = RunTracker.view ~= nil and RunTracker.view.test == true
	StaticPopup_Show(NEW_RUN_POPUP)
end

-- The two buttons' states for the view (its clock: Core/Run.lua's ClockState), placed at the clock's height.
function RunTracker:LayoutControls(view, clockTop)
	local frame = self.block.Frame
	local clock, restart = frame.ClockButton, frame.RestartButton
	local shown = view.clock ~= nil and not view.frozen
	clock:SetShown(shown)
	restart:SetShown(shown)
	if not shown then return end
	local left = CONTROLS.center - CONTROLS.size - CONTROLS.gap / 2
	clock:ClearAllPoints()
	clock:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -(clockTop + CONTROLS.down))
	restart:ClearAllPoints()
	restart:SetPoint("TOPLEFT", frame, "TOPLEFT", left + CONTROLS.size + CONTROLS.gap, -(clockTop + CONTROLS.down))
	local state = view.clock
	clock.state = state
	clock.glyphKind = (state == "running" or state == "stopped") and "pause" or "play"
	clock.usable = state ~= "stopped"
	clock.label = state == "waiting" and L.RUN_CLOCK_START or state == "paused" and L.RUN_CLOCK_RESUME or L.RUN_CLOCK_PAUSE
	clock.note = state == "waiting" and L.RUN_CLOCK_WAITING or state == "stopped" and L.RUN_CLOCK_DONE or nil
	clock.noteColor = nil
	restart.glyphKind = "restart"
	local blocked = self:RestartBlocked()
	restart.usable = not blocked
	restart.label = L.RUN_RESTART
	restart.note, restart.noteColor = blocked and L.RUN_TALLER_COMBAT or nil, blocked and RED or nil
	for _, button in ipairs({ clock, restart }) do
		PaintControl(button)
		if GameTooltip:GetOwner() == button and GameTooltip:IsShown() then ControlTooltip(button) end
	end
end

------------------------------------------------------------------------------------------
-- The header's lock (LOCK)
------------------------------------------------------------------------------------------

--[[
	Where the block's lock, its header's collapse and its dropped spot are kept (runLocked, runCollapsed, runSpot): the
	character's (charDB); while the block shows test mode's pretend run (view.test), the test's own copy of them
	(UI/TestRun.lua's Look: the character's copied the first time, then kept for the test until End test or a /reload),
	so locking, collapsing or dragging the pretend block saves nothing and the real block keeps its own.
]]
function RunTracker:Kept(view)
	view = view or self.view
	if view and view.test and ns.TestRun then return ns.TestRun:Look(ns.charDB) end
	return ns.charDB
end

-- Locked in place by the player (kept for the character); unlocked by default.
function RunTracker:Locked()
	local kept = self:Kept()
	return kept ~= nil and kept.runLocked == true
end

-- The glyph in its place: at rest, or pressed (1 down and right). Its copies follow it (anchored to it).
local function PlaceLockGlyph(lock, pressed)
	lock.Glyph:ClearAllPoints()
	lock.Glyph:SetPoint("CENTER", lock, "CENTER", pressed and LOCK.pressedX or LOCK.x, pressed and LOCK.pressedY or LOCK.y)
end

-- What the lock shows now: the closed padlock while locked, the open one while not (the open one's copy added over
-- it), full under the mouse; its tooltip's words. The glyph set again only when the state changes.
local function PaintLock(lock)
	local locked = RunTracker:Locked()
	if lock.painted ~= locked then
		lock.painted = locked
		if lock.fallback then
			local file = locked and LOCK.lockedFallback or LOCK.unlockedFallback
			lock.Glyph:SetTexture(file)
			lock.Lit:SetTexture(file)
		else
			local coords = locked and LOCK.closed or LOCK.open
			for _, texture in ipairs({ lock.Glyph, lock.Boost, lock.Lit }) do texture:SetTexCoord(unpack(coords)) end
		end
	end
	lock.Boost:SetShown(not locked and not lock.fallback)
	lock.Glyph:SetAlpha(lock.over and 1 or LOCK.alpha)
	lock.label = locked and L.RUN_LOCKED or L.RUN_UNLOCKED
	lock.note = locked and L.RUN_LOCKED_TIP or L.RUN_UNLOCKED_TIP
	lock.noteColor = nil
end

-- Locked or unlocked (the lock's click, /ij run lock and unlock): kept for the character (the pretend block's for the
-- test: Kept), the icon swapped at once.
function RunTracker:SetLocked(locked)
	local kept = self:Kept()
	if not kept then return end
	kept.runLocked = locked and true or nil
	local lock = self.block and self.block.Header.Lock
	if not lock then return end
	PaintLock(lock)
	if GameTooltip:GetOwner() == lock and GameTooltip:IsShown() then ControlTooltip(lock) end
end

local function LockClick()
	local locked = not RunTracker:Locked()
	ns.PlaySoundKit(locked and "IG_MAINMENU_OPTION_CHECKBOX_ON" or "IG_MAINMENU_OPTION_CHECKBOX_OFF")
	RunTracker:SetLocked(locked)
end

local function LockButton(header)
	local lock = CreateFrame("Button", nil, header)
	lock:SetSize(LOCK.width, LOCK.height)
	lock:SetPoint("RIGHT", header.Button, "LEFT", -LOCK.gap, 0)
	-- The AddOns list's padlocks where the client has them, else the classic lock buttons' (LOCK).
	lock.fallback = not ns.FileExists(LOCK.file)
	local size = lock.fallback and LOCK.fallbackGlyph or LOCK.glyph
	lock.Glyph = lock:CreateTexture(nil, "ARTWORK")
	lock.Glyph:SetSize(size, size)
	lock.Boost = lock:CreateTexture(nil, "ARTWORK", nil, 1)
	lock.Lit = lock:CreateTexture(nil, "HIGHLIGHT")
	lock.Boost:SetBlendMode("ADD")
	lock.Boost:SetAlpha(LOCK.boost)
	lock.Lit:SetBlendMode("ADD")
	lock.Lit:SetAlpha(LOCK.litAlpha)
	for _, texture in ipairs({ lock.Glyph, lock.Boost, lock.Lit }) do
		if not lock.fallback then texture:SetTexture(LOCK.file) end
		if texture ~= lock.Glyph then texture:SetAllPoints(lock.Glyph) end
	end
	PlaceLockGlyph(lock, false)
	lock:SetScript("OnClick", LockClick)
	lock:SetScript("OnEnter", function(self)
		self.over = true
		PaintLock(self)
		ControlTooltip(self)
	end)
	lock:SetScript("OnLeave", function(self)
		self.over = false
		PaintLock(self)
		if GameTooltip:GetOwner() == self then HideTooltip() end
	end)
	lock:SetScript("OnMouseDown", function(self) PlaceLockGlyph(self, true) end)
	lock:SetScript("OnMouseUp", function(self) PlaceLockGlyph(self, false) end)
	lock:SetScript("OnHide", function(self)
		self.over = false
		PlaceLockGlyph(self, false)
	end)
	lock:Hide()
	return lock
end

-- (for the tests: a lock built and drawn on a header of their own)
RunTracker.LockButton, RunTracker.PaintLock = LockButton, PaintLock

-- Shown while the block is placed freely, drawn as it stands (RunTracker:Place).
function RunTracker:ShowLock()
	local lock = self.block and self.block.Header.Lock
	if not lock then return end
	local free = self:Free()
	lock:SetShown(free)
	if free then PaintLock(lock) end
end

--[[
	The gold frame at any height: as it is for one row of circles; for two, its top and bottom kept and a middle
	strip stretched (the atlas's own texture coordinates, cut in three).

	Back to one row, the first piece's cut is undone (ResetTexCoord, and SetAtlas's resetTexCoords, as the client's
	TextureUtil.lua passes it): the client's SetAtlas keeps the coordinates a texture was given before and reads them
	inside the atlas. So in 0.39.20 to 0.40.0's test build 2, a block of eight bosses or fewer shown after one of
	more in the same session (two rows: Blackrock Depths, Scholomance) had for its frame a sliver of the frame's own
	dark middle stretched over it: a plain dark box, no gold (the owner's Drowned City, 2026-11-18; their picture
	matches that sliver, and Forever's own API documentation lists both).
]]
local function FrameArt(frame, height)
	local art = frame.Art
	local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(ART.frame)
	local file = info and (info.file or info.filename)
	if height == SIZE.frameHeight or not (file and info.leftTexCoord) then
		if art[1].ResetTexCoord then art[1]:ResetTexCoord() end
		art[1]:SetAtlas(ART.frame, false, nil, true)
		art[1]:ClearAllPoints()
		art[1]:SetAllPoints(frame)
		art[2]:Hide()
		art[3]:Hide()
		art.sliced = false
		return
	end
	local left, right, top, bottom = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
	local cutTop, cutBottom = top + (bottom - top) * 0.46, bottom - (bottom - top) * 0.46
	local edge = SIZE.frameHeight * 0.46
	for index, coords in ipairs({ { top, cutTop }, { cutTop, cutBottom }, { cutBottom, bottom } }) do
		art[index]:SetTexture(file)
		art[index]:SetTexCoord(left, right, coords[1], coords[2])
		art[index]:ClearAllPoints()
		art[index]:Show()
	end
	art[1]:SetPoint("TOPLEFT", frame, "TOPLEFT")
	art[1]:SetSize(SIZE.frameWidth, edge)
	art[3]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
	art[3]:SetSize(SIZE.frameWidth, edge)
	art[2]:SetPoint("TOPLEFT", art[1], "BOTTOMLEFT")
	art[2]:SetPoint("BOTTOMRIGHT", art[3], "TOPRIGHT")
	art.sliced = true
end

function RunTracker:Build()
	if self.block then return self.block end
	self.circles, self.lines = {}, {}
	local block = CreateFrame("Frame", "AegisJournalRunBlock", UIParent)
	block:SetSize(SIZE.width, STYLES.quests.height)
	block:SetFrameStrata("LOW")
	block:SetClampedToScreen(true)
	block:SetMovable(true)
	block:EnableMouse(false)
	block:Hide()
	self.block = block

	local header = CreateFrame("Frame", nil, block)
	header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton")
	header.Background = header:CreateTexture(nil, "BACKGROUND")
	header.Background:SetPoint("CENTER", header, "CENTER", 0, 0)
	header.Text = header:CreateFontString(nil, "ARTWORK")
	UseFont(header.Text, "ObjectiveTrackerHeaderFont", "GameFontNormal")
	header.Text:SetJustifyH("LEFT")
	if header.Text.SetMaxLines then header.Text:SetMaxLines(1) end
	header.Text:SetPoint("LEFT", header, "LEFT", 7, 0)
	header:SetScript("OnEnter", HeaderTooltip)
	header:SetScript("OnLeave", HideTooltip)
	header:SetScript("OnDragStart", function() RunTracker:StartDrag() end)
	header:SetScript("OnDragStop", function() RunTracker:EndDrag() end)
	-- Hidden mid-drag (the run over, the block turned off): dropped where it is, never left moving.
	block:SetScript("OnHide", function() RunTracker:EndDrag() end)
	block.Header = header

	local button = CreateFrame("Button", nil, header)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints(button)
	button.Highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.Highlight:SetAllPoints(button)
	button.Highlight:SetBlendMode("ADD")
	-- Held down, its pressed art, as the client's PushedTexture: kept through the block's own placings and layouts
	-- while held (RunTracker:ApplyStyle, RunTracker:Layout), its normal art again once let go.
	button:SetScript("OnMouseDown", function(self) self.held = true; self.Icon:SetAtlas(self.pressedAtlas) end)
	button:SetScript("OnMouseUp", function(self) self.held = nil; self.Icon:SetAtlas(self.atlas) end)
	button:SetScript("OnHide", function(self) self.held = nil end)
	button:SetScript("OnClick", function()
		-- The click both headers' buttons make (ObjectiveTrackerModuleHeaderMixin:OnToggle and the container's).
		if PlaySound and SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		RunTracker:HeaderButton()
	end)
	header.Button = button
	-- Its lock, left of that button, while the block is placed freely (LOCK).
	header.Lock = LockButton(header)

	local frame = CreateFrame("Frame", nil, block)
	frame:SetSize(SIZE.frameWidth, SIZE.frameHeight)
	frame.BarBack = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
	frame.BarBack:SetAtlas(ART.barBack, true)
	frame.BarBack:SetPoint("BOTTOM", frame, "BOTTOM", 0, SIZE.barBackBottom)
	frame.BarBG = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	frame.BarBG:SetAtlas(ART.barBG, true)
	frame.BarBG:SetPoint("BOTTOM", frame, "BOTTOM", 0, SIZE.barBackBottom)
	-- The gold frame over the bar, as the client layers its keystone block: the frame's art in OVERLAY, the bar at
	-- the frame's own level (useParentLevel) with its fill in ARTWORK, the TimerBG under both.
	frame.Art = {}
	for index = 1, 3 do frame.Art[index] = frame:CreateTexture(nil, "OVERLAY", nil, -1) end
	-- Instance progress: one step per boss down, out of those counted. Not a timer.
	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetSize(SIZE.barWidth, SIZE.barHeight)
	bar:SetPoint("BOTTOM", frame, "BOTTOM", 0, SIZE.barBottom)
	if bar.SetUsingParentFrameLevel then bar:SetUsingParentFrameLevel(true) end
	-- The fill by its atlas's name, as the client gives its own bars theirs (TextureUtil's SetupAtlasesOnRegions; the
	-- keystone XML's BarTexture atlas); a texture with the atlas on it only where that is not taken.
	local named = pcall(bar.SetStatusBarTexture, bar, ART.barFill)
	local fill = named and bar.GetStatusBarTexture and bar:GetStatusBarTexture()
	if not fill then
		fill = bar:CreateTexture(nil, "ARTWORK")
		fill:SetAtlas(ART.barFill)
		pcall(bar.SetStatusBarTexture, bar, fill)
	end
	bar.Fill = fill
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	frame.Bar = bar
	frame.Clock = frame:CreateFontString(nil, "OVERLAY")
	UseFont(frame.Clock, "GameFontHighlightHuge", "GameFontHighlightLarge")
	frame.Clock:SetJustifyH("LEFT")
	frame.Count = frame:CreateFontString(nil, "OVERLAY")
	UseFont(frame.Count, "GameFontNormalMed2", "GameFontNormal")
	frame.Count:SetJustifyH("RIGHT")
	frame.Skull = frame:CreateTexture(nil, "OVERLAY")
	frame.Skull:SetAtlas(ART.skull)
	frame.Skull:SetSize(SIZE.skull, SIZE.skull)
	frame.Skull:SetPoint("TOPRIGHT", frame.Count, "TOPLEFT", -2, 1)
	frame.Check = frame:CreateTexture(nil, "OVERLAY")
	frame.Check:SetAtlas(ART.check)
	frame.Check:SetSize(SIZE.check, SIZE.check)
	frame.Check:SetPoint("TOPRIGHT", frame.Count, "TOPLEFT", -2, 1)
	-- The clock's two buttons, between the time and the count (CONTROLS); placed and drawn by RunTracker:LayoutControls.
	frame.ClockButton = ControlButton(frame, ClockClick)
	frame.RestartButton = ControlButton(frame, RestartClick)
	frame.ClockButton:Hide()
	frame.RestartButton:Hide()
	block.Frame = frame

	block.Complete = block:CreateFontString(nil, "OVERLAY")
	UseFont(block.Complete, "ObjectiveTrackerLineFont", "GameFontHighlight")
	block.Complete:SetJustifyH("LEFT")
	-- "Which wing?", while the wing is not known (RunTracker:Layout).
	block.Wing = block:CreateFontString(nil, "OVERLAY")
	UseFont(block.Wing, "ObjectiveTrackerLineFont", "GameFontHighlight")
	block.Wing:SetJustifyH("LEFT")
	block.Wing:Hide()
	block.Numbers = {}
	for index = 1, 3 do
		local text = block:CreateFontString(nil, "OVERLAY")
		UseFont(text, "ObjectiveTrackerLineFont", "GameFontHighlight")
		text:SetJustifyH("LEFT")
		block.Numbers[index] = text
	end
	-- The hidden dash whose width the tracker's lines keep as their indent, and the line height (Text Size).
	block.Dash = block:CreateFontString(nil, "OVERLAY")
	UseFont(block.Dash, "ObjectiveTrackerLineFont", "GameFontHighlight")
	block.Dash:SetText("- ")
	block.Dash:SetAlpha(0)
	block.Dash:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
	-- Built in the section's look; its first placing (before it is first shown) gives it the one its place asks for.
	self.style = nil
	self:ApplyStyle(STYLES.quests)
	return block
end

--[[
	The header drawn in one of its two looks (STYLES): its size, its bar's atlas at the atlas's own size, its text's
	width, its button's size, place and highlight, and the keystone frame's distance under it. The button's own atlas
	(collapse or expand) is RunTracker:Layout's, which runs right after (RunTracker:SetStyle). Nothing done when the
	look is already the one asked for.
]]
function RunTracker:ApplyStyle(style)
	local block = self.block
	if not block or self.style == style then return false end
	self.style = style
	local header, button = block.Header, block.Header.Button
	header:SetSize(SIZE.width, style.height)
	header.Background:SetAtlas(style.header, true)
	header.Text:SetWidth(style.text)
	button:SetSize(style.button, style.buttonHeight)
	button:ClearAllPoints()
	button:SetPoint("RIGHT", header, "RIGHT", style.buttonX, 0)
	button.Highlight:SetAtlas(style.highlight)
	button.atlas, button.pressedAtlas = style.collapse, style.collapsePressed
	button.Icon:SetAtlas(button.held and button.pressedAtlas or button.atlas)
	block.Frame:ClearAllPoints()
	block.Frame:SetPoint("TOPLEFT", block, "TOPLEFT", 0, -style.contentTop)
	return true
end

------------------------------------------------------------------------------------------
-- What it shows
------------------------------------------------------------------------------------------

-- The client's name for the instance the player is in, for a dungeon of several wings before one is known.
local function ClientInstanceName()
	local ok, name = pcall(GetInstanceInfo)
	name = ok and ns.Readable(name) or nil
	return type(name) == "string" and name ~= "" and name or nil
end

--[[
	What the block shows now: the open run inside its dungeon, or (/ij run outside) the last one kept. The kills are
	the map's (DungeonMap:IsDefeated) inside, and the run's own record of them for a run left behind. Inside one of
	Scarlet Monastery's wings whose wing is not known yet (Core/Run.lua's WaitForWing), no run: the client's name for
	the dungeon and one line, "Which wing?" (waiting), until the wing's first named area or its first fight. Outside a
	dungeon, test mode's pretend run where the panel pretends the player is inside (UI/TestRun.lua's Source, test =
	true), before the last run: "(test)" after its name, its kills its own, never frozen; at a wing's door its "Which
	wing?" (wingID: the wings it waits for).
]]
local function Waiting(title, wingID)
	return { waiting = true, frozen = false, title = title, wingID = wingID, entries = {}, others = {}, lines = {},
		down = 0, total = 0, numbers = false, seconds = 0, xp = 0, copper = 0, itemValue = 0, items = 0, greed = 0,
		pending = 0 }
end

function RunTracker:View()
	if Run:WaitingForWing() then
		-- (hidden with /ij run while waiting, or the run it may go on with hidden: Run:WaitForWing)
		if Run.session.wingWait.hidden then return nil end
		return Waiting(ClientInstanceName() or "")
	end
	local inside = Run:Inside() and Run:Current() or nil
	-- Test mode's pretend run (UI/TestRun.lua): only outside a dungeon; a real run inside always wins.
	if not inside and ns.TestRun then
		local test = ns.TestRun:Source()
		if test and test.waiting then
			if test.hidden then return nil end
			local view = Waiting(test.title, test.instanceID)
			view.test = true
			return view
		elseif test then
			local view = self:ViewOf(test.run, test.instance, true, test.dead, false, test.title)
			view.test = true
			for _, shown in ipairs(view.entries) do shown.test = true end
			return view
		end
	end
	local run = inside or (self.showingLast and Run:Last()) or nil
	if not run then return nil end
	local instance, placed, dead
	if inside then
		instance, placed = ns.CurrentInstance(true)
		if instance and not Run.InRun(run, instance) then instance, placed = nil, false end
		-- A dungeon of one part is always placed; a wing only once the area or the map names it.
		if instance and placed then run.wing = instance.key end
		dead = function(boss) return ns.DungeonMap:IsDefeated(instance, boss) end
	else
		instance = ns.GetInstance(run.wing or run.key)
		placed = instance ~= nil
		dead = function(boss)
			local killed = run.kills and run.kills[instance.key]
			return killed ~= nil and killed[boss.name] ~= nil
		end
	end
	return self:ViewOf(run, instance, placed, dead, inside == nil)
end

-- The view of a run (real or test mode's pretend one): its entries, lines, count, clock and numbers, by the block's own
-- rules. dead(boss): the kills it goes by; title: the header's name where it is not the dungeon's own.
function RunTracker:ViewOf(run, instance, placed, dead, frozen, title)
	local view = { run = run, frozen = frozen }
	view.instance, view.placed = instance, placed and true or false
	view.title = title or placed and instance.name or ClientInstanceName() or (instance and instance.name) or ""
	local entries, others = {}, {}
	if placed then
		for _, entry in ipairs(Run.Bosses(instance)) do
			-- (in Adventure Mode a boss not met yet: "???" and the unknown-boss picture, as on the map: ShowCircle)
			entries[#entries + 1] = { entry = entry, name = Run.EntryName(entry, instance), boss = entry.boss,
				dead = Run.EntryDead(entry, dead), unmet = ns.Discovery:Unmet(instance, entry.boss), instance = instance }
		end
		for _, boss in ipairs(Run.Others(instance)) do
			if dead(boss) then others[#others + 1] = { name = ns.Discovery:BossTitle(instance, boss), boss = boss, dead = true } end
		end
	end
	view.entries, view.others = entries, others
	view.down = 0
	for _, shown in ipairs(entries) do
		if shown.dead then view.down = view.down + 1 end
	end
	view.total = #entries
	-- Done in the part its final boss died in: another part walked into afterwards (Upper Blackrock Spire after
	-- Lower) is not, its bosses still 0/1. Whether its clock should run on there: the owner's.
	view.finished = run.finished == true and not (placed and run.finishedWing and run.finishedWing ~= instance.key)
	view.seconds = Run.Elapsed(run)
	-- How its clock stands (waiting for the first pull, running, paused, stopped): its color and its buttons.
	view.clock = Run.ClockState(run)
	-- Long lists: the next LONG_LIST bosses still standing, in the journal's order, and the last one killed (by the
	-- run's kill times, else list order), in its place among them.
	view.lines = entries
	if #entries > LONG_LIST then
		local last, lastAt = nil, -1
		local killed = run.kills and instance and run.kills[instance.key] or {}
		for _, shown in ipairs(entries) do
			if shown.dead then
				local at = 0
				for _, part in ipairs(shown.entry.parts) do at = math.max(at, killed[part.name] or 0) end
				if at >= lastAt then last, lastAt = shown, at end
			end
		end
		view.lines = {}
		local standing = 0
		for _, shown in ipairs(entries) do
			if shown == last then
				view.lines[#view.lines + 1] = shown
			elseif not shown.dead and standing < LONG_LIST then
				standing = standing + 1
				view.lines[#view.lines + 1] = shown
			end
		end
		view.long = true
	end
	view.numbers = Run:Option("numbers")
	view.xpShown = Run.XPShown() or (view.frozen and (run.xp or 0) > 0)
	view.xp, view.copper, view.itemValue = run.xp or 0, run.copper or 0, run.itemValue or 0
	view.items, view.greed = run.items or 0, run.greed or 0
	view.pending = 0
	for _, waiting in pairs(run.pending or {}) do view.pending = view.pending + (waiting.count or 0) end
	return view
end

-- Circles per row, their size and gap: one row up to 8, then two; 22 across at most, as many as fit in 195.
function RunTracker.RingLayout(count)
	local rows = count > SIZE.oneRow and 2 or 1
	local per = math.max(1, math.ceil(count / rows))
	local size = math.min(SIZE.ringMax, math.floor((SIZE.innerWidth - SIZE.ringGapTight * (per - 1)) / per))
	local gap = (size == SIZE.ringMax and per * size + (per - 1) * SIZE.ringGap <= SIZE.innerWidth) and SIZE.ringGap
		or SIZE.ringGapTight
	return rows, per, size, gap
end

--[[
	The header's name shrunk to fit its width (its look's: 208 or 200) on one line rather than cut off with "...", as
	the client's headers do (their text's AutoScalingFontStringMixin: ScaleTextToFit, minLineHeight 12): the text
	scale from the name's width, then a line-height step smaller while it is still cut off, never under 12. Unlike the
	mixin, the line height is read again whenever the name, the width or the font's size (the Edit Mode Text Size)
	changes, not kept from the first time. A name still too long at 12 ends in "..." as the client's would. Returns
	the scale.
]]
function RunTracker.FitHeaderText(text, title, room)
	if not (text.SetTextScale and text.GetUnboundedStringWidth and text.GetLineHeight) then return 1 end
	room = room or STYLES.quests.text
	local _, fontHeight = text:GetFont()
	if text.fitTitle == title and text.fitFont == fontHeight and text.fitRoom == room and text.fitScale then
		return text.fitScale
	end
	text:SetTextScale(1)
	local base = math.floor((text:GetLineHeight() or 0) + 0.5)
	local width = text:GetUnboundedStringWidth() or 0
	local scale = 1
	if base > SIZE.headerMinLine and width > room then
		local try = math.max(SIZE.headerMinLine, math.floor(room / width * base + 0.5))
		while try >= SIZE.headerMinLine do
			scale = try / base
			text:SetTextScale(scale)
			if not (text.IsTruncated and text:IsTruncated()) then break end
			try = try - 1
		end
	end
	text.fitTitle, text.fitFont, text.fitRoom, text.fitScale = title, fontHeight, room, scale
	return scale
end

-- "  (x/hr)" after a total, from the run's first minute on (Run.PerHour); before it, nothing: the total alone.
local function Rate(total, seconds, money)
	local rate = Run.PerHour(total, seconds)
	if not rate then return "" end
	return string.format("  %s(%s)|r", NORMAL_CODE, string.format(L.RUN_PER_HOUR,
		money and Run.RateMoney(rate) or Run.Thousands(rate)))
end

-- The line height the font gives now (the Edit Mode Text Size changes it), and the pitches from it.
local function Pitches(block)
	local height = block.Dash:GetStringHeight() or SIZE.lineFont
	if height <= 0 then height = SIZE.lineFont end
	return math.max(SIZE.bossPitch, height + 10), math.max(SIZE.numberPitch, height + 5),
		math.max(SIZE.completePitch, height + 8), height
end

-- A line's text as wide as the block's right edge, two lines at most; how far down the next line goes.
local function Wrapped(text, pitch, width, lineHeight)
	text:SetWidth(width)
	if text.SetMaxLines then text:SetMaxLines(2) end
	return math.max(pitch, (text:GetStringHeight() or 0) + pitch - lineHeight)
end

--[[
	The open body (RunTracker:Layout's openBody) of the block the wing waited for will bring, the tallest of the client
	instance id's wings (the Cathedral's, in Scarlet Monastery): its circles, each boss's line (one line high: a name
	that wraps makes it taller still) and the numbers as they will show. Where "Which wing?" waits by the tracker goes by
	it (RunTracker:TallestIn, Anchor's side), not by its one line, and the run the wing decides keeps it as its tallest
	(Layout: fullFor WAITING), so the block stays on the side it waited on, never above the tracker for "Which wing?"
	and then below it (the release review of 2026-11-17). So a wing with fewer bosses, which alone would fit above, sits
	below it that run where the Cathedral would not fit.
]]
local WAITING = {}
-- What the tallest open height kept (fullBody) is for: the run shown, or the wing waited for.
local function FullKey(view)
	return view.waiting and WAITING or view.run
end
local function WingBody(instanceID, bossPitch, numberPitch)
	local numbers = Run:Option("numbers") and (Run.XPShown() and 3 or 2) or 0
	local tallest = 0
	for _, wing in ipairs(instanceID and ns.GetInstancesByInstanceID(instanceID) or {}) do
		local count = #Run.Bosses(wing)
		local rows, _, size = RunTracker.RingLayout(count)
		local body = SIZE.frameHeight + (count > 0 and (rows - 1) * (size + SIZE.rowGap) or 0) + SIZE.afterFrame
			+ math.min(count, LONG_LIST + 1) * bossPitch + (numbers > 0 and SIZE.numbersGap + numbers * numberPitch or 0)
		tallest = math.max(tallest, body)
	end
	return tallest
end

--[[
	open: laid out expanded whatever the collapse (to know its full height, RunTracker:Refresh). In the header's look
	of the moment (self.style). Its open height is kept apart from the header's (openBody: from the keystone frame's
	top down, the same in both looks), so where it goes (RunTracker:Anchor) can be worked out for either look before
	the look is changed.
]]
function RunTracker:Layout(view, open)
	local block = self.block
	local frame = block.Frame
	local style = self.style
	block.Header.Text:SetText(view.title)
	RunTracker.FitHeaderText(block.Header.Text, view.title, style.text)
	local collapsed = not open and self:Collapsed(view)
	local button = block.Header.Button
	button.atlas = collapsed and style.expand or style.collapse
	button.pressedAtlas = collapsed and style.expandPressed or style.collapsePressed
	button.Icon:SetAtlas(button.held and button.pressedAtlas or button.atlas)
	frame:SetShown(not collapsed and not view.waiting)
	block.Wing:SetShown(not collapsed and view.waiting == true)
	if collapsed or view.waiting then
		for _, circle in ipairs(self.circles) do circle:Hide() end
		for _, line in ipairs(self.lines) do line.Icon:Hide(); line.Text:Hide() end
		block.Complete:Hide()
		for _, text in ipairs(block.Numbers) do text:Hide() end
	end
	if collapsed then
		block:SetHeight(style.height)
		self.height = style.height
		return style.height
	end
	-- The wing not known yet (RunTracker:View): one line where the keystone frame goes, as the tracker writes a line
	-- under its header, in its gray; no clock, circles or numbers, for there is no run yet.
	if view.waiting then
		local bossPitch, numberPitch, _, lineHeight = Pitches(block)
		local textX = SIZE.lineX + (block.Dash:GetStringWidth() or 0)
		local y = style.contentTop
		block.Wing:ClearAllPoints()
		block.Wing:SetPoint("TOPLEFT", block, "TOPLEFT", textX, -y)
		block.Wing:SetText(L.RUN_WHICH_WING)
		SetColor(block.Wing, NORMAL)
		y = y + Wrapped(block.Wing, bossPitch, SIZE.width - textX, lineHeight)
		block:SetHeight(y)
		self.height, self.openHeight, self.openBody = y, y, y - style.contentTop
		if self.fullFor ~= WAITING then self.fullFor, self.fullBody = WAITING, self.openBody end
		-- (where it waits: by the block its wing will bring, WingBody)
		self.fullBody = math.max(self.fullBody or 0, self.openBody,
			WingBody(view.wingID or Run:WaitingForWing(), bossPitch, numberPitch))
		return y
	end

	-- The frame: circles, clock, count and the bar.
	local rows, per, size, gap = RunTracker.RingLayout(#view.entries)
	local frameHeight = SIZE.frameHeight + (#view.entries > 0 and (rows - 1) * (size + SIZE.rowGap) or 0)
	frame:SetHeight(frameHeight)
	FrameArt(frame, frameHeight)
	for index, shown in ipairs(view.entries) do
		local circle = Circle(index)
		local row = math.floor((index - 1) / per)
		local inRow = math.min(per, #view.entries - row * per)
		local rowWidth = inRow * size + (inRow - 1) * gap
		local column = (index - 1) % per
		circle:SetSize(size, size)
		circle:ClearAllPoints()
		circle:SetPoint("TOPLEFT", frame, "TOPLEFT", SIZE.innerLeft + (SIZE.innerWidth - rowWidth) / 2 + column * (size + gap),
			-(SIZE.ringTop + row * (size + SIZE.rowGap)))
		if circle.faceSize ~= size - 2 then
			ns.DungeonMap.SizeFace(circle, size - 2)
			circle.faceSize = size - 2
		end
		-- The portrait drawn again only when the boss or his state changes (met, in Adventure Mode, too).
		if not (circle.shown and circle.shown.boss == shown.boss and circle.shown.dead == shown.dead
			and circle.shown.unmet == shown.unmet and circle.faceDrawn == circle.faceSize) then
			self.ShowCircle(circle, shown)
		end
		circle.shown = shown
		circle:Show()
	end
	for index = #view.entries + 1, #self.circles do
		self.circles[index]:Hide()
		self.circles[index].shown = nil
	end
	local clockTop = SIZE.ringTop + (#view.entries > 0 and rows * (size + SIZE.rowGap) + 1 or 0)
	frame.Clock:ClearAllPoints()
	frame.Clock:SetPoint("TOPLEFT", frame, "TOPLEFT", SIZE.innerLeft, -clockTop)
	frame.Clock:SetText(Run.Clock(view.seconds))
	-- Gold once done; gray while it waits for the first pull or is paused (not running); white while it runs, or
	-- stopped in a part the run did not finish in.
	local idle = view.clock == "waiting" or view.clock == "paused"
	SetColor(frame.Clock, view.finished and GOLD or idle and IDLE or WHITE)
	self:LayoutControls(view, clockTop)
	frame.Count:ClearAllPoints()
	frame.Count:SetPoint("TOPRIGHT", frame, "TOPLEFT", SIZE.innerLeft + SIZE.innerWidth, -(clockTop + SIZE.countDown))
	frame.Count:SetText(string.format("%d/%d", view.down, view.total))
	SetColor(frame.Count, GOLD)
	frame.Count:SetShown(view.total > 0)
	frame.Skull:SetShown(view.total > 0 and not view.finished)
	frame.Check:SetShown(view.total > 0 and view.finished)
	local fraction = view.total > 0 and view.down / view.total or 0
	frame.Bar:SetValue(fraction)
	frame.Bar.fraction = fraction

	-- The lines under it, as wide as the tracker's to the block's right edge: a long name wraps to a second line
	-- (two at most, as the client's objective lines: SetMaxLines(2)), and the next line steps down by its height.
	local bossPitch, numberPitch, completePitch, lineHeight = Pitches(block)
	local dash = block.Dash:GetStringWidth() or 0
	local textX = SIZE.lineX + dash
	local textWidth = SIZE.width - textX
	local y = style.contentTop + frameHeight + SIZE.afterFrame
	if view.finished then
		block.Complete:ClearAllPoints()
		block.Complete:SetPoint("TOPLEFT", block, "TOPLEFT", textX, -y)
		block.Complete:SetText(L.RUN_COMPLETE)
		SetColor(block.Complete, GOLD)
		block.Complete:Show()
		y = y + completePitch
	else
		block.Complete:Hide()
	end
	local shownLines = {}
	for _, shown in ipairs(view.lines) do shownLines[#shownLines + 1] = shown end
	for _, shown in ipairs(view.others) do shownLines[#shownLines + 1] = shown end
	for index, shown in ipairs(shownLines) do
		local line = Line(index)
		local text = string.format("%d/%d %s", shown.dead and 1 or 0, 1, string.format(L.RUN_BOSS_DEFEATED, shown.name))
		line.Text:SetText(text)
		SetColor(line.Text, shown.dead and COMPLETE or NORMAL)
		line.Text:ClearAllPoints()
		line.Text:SetPoint("TOPLEFT", block, "TOPLEFT", textX, -y)
		line.Text:Show()
		local atlas = shown.dead and ART.check or ART.nub
		if line.atlas ~= atlas then
			line.Icon:SetAtlas(atlas)
			if shown.dead and line.atlas and line.Fade and line.Fade.Play then line.Fade:Play() end
			line.atlas = atlas
		end
		line.Icon:ClearAllPoints()
		line.Icon:SetPoint("TOPLEFT", block, "TOPLEFT", SIZE.lineX + SIZE.iconX, -(y - SIZE.iconY))
		line.Icon:Show()
		y = y + Wrapped(line.Text, bossPitch, textWidth, lineHeight)
	end
	for index = #shownLines + 1, #self.lines do
		self.lines[index].Icon:Hide()
		self.lines[index].Text:Hide()
	end

	-- The numbers.
	local numbers = {}
	if view.numbers then
		if view.xpShown then
			numbers[#numbers + 1] = string.format("%s %s%s|r%s", L.RUN_EXPERIENCE, WHITE_CODE, Run.Thousands(view.xp),
				Rate(view.xp, view.seconds))
		end
		local money = view.copper + view.itemValue
		numbers[#numbers + 1] = string.format("%s %s%s|r%s", L.RUN_MONEY, WHITE_CODE,
			money > 0 and ns.MoneyText(money) or "0", Rate(money, view.seconds, true))
		local items = string.format("%s %s%d|r", L.RUN_ITEMS, WHITE_CODE, view.items)
		if view.greed > 0 then items = items .. "  " .. NORMAL_CODE .. "(" .. string.format(L.RUN_GREED, view.greed) .. ")|r" end
		numbers[#numbers + 1] = items
	end
	if #numbers > 0 then y = y + SIZE.numbersGap end
	for index, text in ipairs(block.Numbers) do
		local value = numbers[index]
		text:SetShown(value ~= nil)
		if value then
			text:SetText(value)
			SetColor(text, NORMAL)
			text:ClearAllPoints()
			text:SetPoint("TOPLEFT", block, "TOPLEFT", textX, -y)
			y = y + Wrapped(text, numberPitch, textWidth, lineHeight)
		end
	end
	block:SetHeight(y)
	self.height, self.openHeight, self.openBody = y, y, y - style.contentTop
	-- The tallest it has been laid out open for this run: where it sits goes by that (RunTracker:Place), so a
	-- collapse, or a kill that shortens a long dungeon's lines, does not move it from under the tracker to above it.
	-- Kept without the header (fullBody), so the same whichever look the header has. The run the wing waited for
	-- decides keeps the room it waited by (WingBody), so it stays on that side.
	if self.fullFor ~= view.run then
		self.fullBody = self.fullFor == WAITING and not view.frozen and self.fullBody or self.openBody
		self.fullFor = view.run
	end
	self.fullBody = math.max(self.fullBody or 0, self.openBody)
	return y
end

-- The block's open height with the header in the look given: its header's distance to the keystone frame and the
-- rest as last laid out open (its header's own height before it ever was).
function RunTracker:OpenHeightIn(style)
	return self.openBody and style.contentTop + self.openBody or style.height
end

-- Its tallest open height this run with the header in the look given (RunTracker:Anchor's room above).
function RunTracker:TallestIn(style)
	local body = self.view and self.fullFor == FullKey(self.view) and self.fullBody or self.openBody
	return body and style.contentTop + body or style.height
end

-- A circle's face: the boss's portrait, crossed out once he is dead; in Adventure Mode a boss not met yet wears the
-- journal's unknown-boss picture on a black disc, as his hint on the map does (UI/DungeonFog.lua), the same size.
function RunTracker.ShowCircle(circle, shown)
	ns.DungeonMap.ShowFace(circle, shown.boss, shown.dead)
	local unknown = rawget(circle, "Unknown")
	if shown.unmet and not shown.dead then
		if not unknown then
			unknown = circle:CreateTexture(nil, "ARTWORK", nil, -1)
			if circle.Portrait.CircleMask then unknown:AddMaskTexture(circle.Portrait.CircleMask) end
			circle.Unknown = unknown
		end
		if ns.DungeonFog and ns.DungeonFog.CutUnknown then
			unknown:ClearAllPoints()
			ns.DungeonFog.CutUnknown(unknown, circle.Portrait, (circle.faceSize or (SIZE.ringMax - 2)) / 2)
		end
		circle.Portrait:SetColorTexture(0, 0, 0, 1)
		circle.Skull:Hide()
		unknown:Show()
	elseif unknown then
		unknown:Hide()
	end
	circle.faceDrawn = circle.faceSize
end

------------------------------------------------------------------------------------------
-- Where it sits
------------------------------------------------------------------------------------------

-- A frame's edge in UIParent's units.
local function UIUnits(frame, value)
	if value == nil then return nil end
	local scale = frame.GetEffectiveScale and frame:GetEffectiveScale() or 1
	local base = UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
	return value * scale / base
end

-- The room above the tracker's top, up to the minimap cluster's bottom where it is over the tracker, else the
-- screen's top.
local function RoomAbove(tracker)
	local top = UIUnits(tracker, tracker:GetTop())
	local ceiling = UIParent:GetTop() or top
	local cluster = MinimapCluster
	if cluster and cluster.IsShown and cluster:IsShown() then
		local bottom = UIUnits(cluster, cluster:GetBottom())
		local left, right = UIUnits(cluster, cluster:GetLeft()), UIUnits(cluster, cluster:GetRight())
		local trackerLeft, trackerRight = UIUnits(tracker, tracker:GetLeft()), UIUnits(tracker, tracker:GetRight())
		if bottom and left and right and trackerLeft and trackerRight and left < trackerRight and right > trackerLeft then
			ceiling = math.min(ceiling, bottom)
		end
	end
	return ceiling - top
end

-- One of the tracker's layout numbers (its XML KeyValues), only read; the client's default where it has none.
local function TrackerNumber(tracker, key, default)
	local value = tracker[key]
	return type(value) == "number" and value >= 0 and value or default
end

-- The placing in use, for /ij run debug and the checks.
RunTracker.placement = "none"

--[[
	The header's look for a placing: like the tracker's own header it sits next to (the owner's call, 2026-11-12).
	- "All Objectives" (objectives): above the tracker, its header the topmost one there with the tracker's own "All
	  Objectives" under it; placed freely, a tracker of its own wherever it is dropped; and with "Place it freely"
	  ticked at all, where it waits by the tracker until it is first dragged too (the owner's "if it's free mode";
	  a best guess for that wait), or at its own spot while the tracker is not seen ("free (its own spot)"). Also
	  where it stands alone where the tracker's own header would be: "fallback"
	  (the tracker with no place yet: the block at the tracker's default spot) and "tracker's place" (nothing tracked,
	  the tracker hidden: the block at its top left), where nothing of the tracker shows beside it and the block is
	  in the "All Objectives" header's own place (a best guess).
	- "Quests" (quests): under the tracker's quests, under its collapsed header, under its controller footer, under
	  the tracker itself, and inside it (the experiment, a section under its "All Objectives"; inside wins over
	  "Place it freely": it is never on then). "below the tracker (tracker hidden)" (inside on, nothing tracked, no
	  room above) stays "Quests" although nothing of the tracker shows beside it either: it is a placing under the
	  tracker, the block under the tracker's own frame rather than in its header's place as at "tracker's place", and
	  the one a section of the tracker would take there (a best guess; the owner may want it "All Objectives" too).
]]
local OBJECTIVES_PLACINGS = { ["above"] = true, ["above (tracker hidden)"] = true, ["free"] = true,
	["free (its own spot)"] = true, ["fallback"] = true, ["tracker's place"] = true }

function RunTracker.StyleFor(placement)
	if type(placement) == "string" and placement:find("^inside") then return STYLES.quests end
	if RunTracker:Free() or OBJECTIVES_PLACINGS[placement] then return STYLES.objectives end
	return STYLES.quests
end

--[[
	Placed freely: "Place it freely" on (the default since 0.39.23: Core/Run.lua Run.FREE_DEFAULT), and "Inside the
	quest tracker" off. That test option, ticked, wins: its own placing then (inside, or beside the tracker where it
	has no room), never dragged.
]]
function RunTracker:Free()
	if not Run:Option("free") then return false end
	local inside = self.inside
	return not (inside and inside:On())
end

--[[
	Placed freely and never dragged, the block waits by the tracker only while the tracker is seen on the screen: shown,
	under a shown parent (another addon may hide it, or hide what it is under), and some of it on the screen. Only
	read (IsShown, IsVisible, its edges); nothing of the tracker's is called that could change it. With the game's
	interface hidden (Alt+Z), the last answer from while it was shown (RunTracker.lastSeen), so the block does not move
	then, not even onto a tracker another addon hid under a hidden frame (IsShown still true): the tracker's own
	IsShown alone only where no answer was kept yet.
]]
local function SeenNow(tracker)
	if type(tracker) ~= "table" then return false end
	for _, method in ipairs({ "IsShown", "IsVisible", "GetLeft", "GetRight", "GetTop", "GetBottom" }) do
		if type(tracker[method]) ~= "function" then return false end
	end
	if not tracker:IsShown() then return false end
	if UIParent:IsVisible() and not tracker:IsVisible() then return false end
	local left, right = UIUnits(tracker, tracker:GetLeft()), UIUnits(tracker, tracker:GetRight())
	local top, bottom = UIUnits(tracker, tracker:GetTop()), UIUnits(tracker, tracker:GetBottom())
	local width, height = UIParent:GetRight(), UIParent:GetTop()
	if not (left and right and top and bottom and width and height) then return false end
	return right > 0 and left < width and top > 0 and bottom < height
end
local function TrackerSeen(tracker)
	local seen = SeenNow(tracker)
	if UIParent:IsVisible() then
		RunTracker.lastSeen = seen
	elseif RunTracker.lastSeen ~= nil then
		return RunTracker.lastSeen
	end
	return seen
end
RunTracker.TrackerSeen = TrackerSeen

--[[
	Placed: anchored, then given the header's look its place asks for, then its tint. A new look is drawn and the block
	laid out again in the same call, before the frame is drawn, so it never shows a frame in the old look at the new
	place (no flicker), and nothing runs every frame: the look is only looked at where the block is placed anyway (its
	clock once a second while open, quest events, zone changes, Edit Mode closed, an option changed, a drop). Where it
	goes does not depend on the look (RunTracker:Anchor works the room out for the look it will have), so the new look
	never moves it again.
]]
function RunTracker:Place()
	local block = self.block
	if not block then return end
	-- Being dragged, the block is the client's to place, under the mouse, until it is dropped (RunTracker:StartDrag).
	-- Its button let go unheard (outside the game's window): dropped now, where it is.
	if self.dragging then
		if not (IsMouseButtonDown and IsMouseButtonDown("LeftButton")) then return self:EndDrag() end
		self:Paint()
		return
	end
	block:ClearAllPoints()
	self:Anchor(block)
	self:SetStyle(RunTracker.StyleFor(self.placement))
	self:ShowLock()
	self:Paint()
end

-- The header in the look given, the block laid out again in it when it changes (its height with it).
function RunTracker:SetStyle(style)
	if not self:ApplyStyle(style) then return false end
	self.styleChanges = (self.styleChanges or 0) + 1
	if self.view then self:Layout(self.view) end
	return true
end

function RunTracker:Anchor(block)
	-- The experiment, when it is on: under the tracker's "All Objectives", its sections moved down below the block.
	if self.inside then
		local inside, placement = self.inside:Place(self, block)
		if inside then
			self.placement = placement
			return
		end
	end
	local kept = self:Kept()
	local spot = kept and kept.runSpot
	local free = self:Free()
	if free and spot then
		block:SetPoint(spot[1], UIParent, spot[2], spot[3], spot[4])
		self.placement = "free"
		return
	end
	local tracker = ObjectiveTrackerFrame
	--[[
		Placed freely, not dragged yet: by the tracker (below, as beside it) while the tracker is seen; else the block's
		own spot, one tracker's width and a gap left of where the game's tracker stands by default, so it never sits on
		another quest tracker there nor goes with a hidden one (a best guess at a spot that is out of their way).
	]]
	if free and not TrackerSeen(tracker) then
		block:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", SIZE.freeX, SIZE.freeY)
		self.placement = "free (its own spot)"
		return
	end
	local top = tracker and tracker.GetTop and tracker:GetTop()
	if not top then
		-- The tracker has no place yet (nothing tracked since login): its default spot.
		block:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", SIZE.fallbackX, SIZE.fallbackY)
		self.placement = "fallback"
		return
	end
	-- The tracker's own space between its sections (its moduleSpacing), between it and the block.
	local spacing = TrackerNumber(tracker, "moduleSpacing", SIZE.sectionGap)
	-- Above, the block has the "All Objectives" look (RunTracker.StyleFor), so the room is worked out for that look
	-- whatever it has now: the block open at its tallest this run with that header (38 to the keystone frame, never a
	-- collapsed header's 32), and the header's art reaching 4 over its top, kept on the screen. Held by its top, at
	-- its open height in that look.
	local above = STYLES.objectives
	local need = self:TallestIn(above) + spacing + above.over
	local openAbove = spacing + self:OpenHeightIn(above)
	if not tracker:IsShown() then
		-- Nothing tracked, so no tracker on screen. With the experiment on (the tracker too short for the block inside
		-- it: UI/RunTrackerInside.lua), never on the spot its header comes back to: above it where there is room, else
		-- under its frame, which its sections never pass. Otherwise its place, as 0.39.20.
		if self.inside and self.inside.active then
			if RoomAbove(tracker) >= need then
				block:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, openAbove)
				self.placement = "above (tracker hidden)"
			else
				block:SetPoint("TOPLEFT", tracker, "BOTTOMLEFT", 0, -spacing)
				self.placement = "below the tracker (tracker hidden)"
			end
			return
		end
		block:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, 0)
		self.placement = "tracker's place"
		return
	end
	if RoomAbove(tracker) >= need then
		-- Held by its top, its open bottom the spacing over the tracker: collapsed, the header and its button stay
		-- where they were (under the mouse), as the tracker's own header does, the room under it left empty.
		block:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, openAbove)
		self.placement = "above"
		return
	end
	-- Under what the tracker shows: its contents' edge (the NineSlice it moves to its last module, bottomModulePadding
	-- under it, so the block a section's space under that module, but never so close that the header's art would
	-- reach over the background's edge: the art of the look it has there, RunTracker.StyleFor), its header alone while
	-- it is collapsed, the controller prompts' footer while that shows.
	local under, placement = tracker.NineSlice, "below"
	local over = RunTracker.StyleFor(placement).over
	local gap = math.max(over, spacing - TrackerNumber(tracker, "bottomModulePadding", SIZE.slicePadding))
	if tracker.isCollapsed and tracker.Header then under, placement, gap = tracker.Header, "below the header", spacing end
	local footer = tracker.gamepadFooter
	if footer and footer.IsShown and footer:IsShown() then under, placement, gap = footer, "below the footer", spacing end
	if not (under and under.GetLeft) then under, placement, gap = tracker, "below the tracker", spacing end
	local dx = 0
	local trackerLeft, underLeft = UIUnits(tracker, tracker:GetLeft()), UIUnits(under, under:GetLeft())
	if trackerLeft and underLeft then dx = trackerLeft - underLeft end
	block:SetPoint("TOPLEFT", under, "BOTTOMLEFT", dx, -gap)
	self.placement = placement
end

------------------------------------------------------------------------------------------
-- Dark mode: the tracker's tint on the block's gold art
------------------------------------------------------------------------------------------

--[[
	A UI that darkens the game (a dark-mode addon) tints the game's own textures (SetVertexColor, often with
	SetDesaturated), never the journal's. So the block's gold art takes the tint of the tracker's own headers, only
	read (GetVertexColor, IsDesaturated), the header the block's is drawn like first: in the "Quests" look, the
	"Quests" header first (QuestObjectiveTracker.Header, the client's ObjectiveTrackerModuleHeaderTemplate,
	Blizzard_ObjectiveTrackerModule.xml: its Background, the bar with its line, and its MinimizeButton's
	NormalTexture), then the other sections' headers (the tracker's modules), then "All Objectives"
	(ObjectiveTrackerFrame.Header, ObjectiveTrackerContainerHeaderTemplate: its Background and its MinimizeButton's
	NormalTexture); in the "All Objectives" look, "All Objectives" first, then "Quests", then the other sections'. The
	first tinted bar, and the first tinted button, of those. The bar's tint goes on the block's bar (its header's
	Background), its alpha too, so the block's header looks as its counterpart does; the button's on the block's
	button. The keystone
	frame's gold and the circles' gold rings stay gold (tintFrame off: the owner's pick of 2026-11-12, "3", the frame
	left gold; on, they would take the bar's tint too). The highlight and everything else stay as they are. Read again at each placing (once a
	second while the block is open; quest and zone events, Edit Mode closed), never by an OnUpdate. With no tint on
	the tracker, the block's art is exactly as before. "Dark mode" (the run option darkMode) darkens the same art
	where the tracker's is not tinted, by DARK: a best guess at how dark such addons make the game's art. A tinted
	tracker's own tint still wins, on the bar and the button alike (a dark UI that leaves the tracker's button gold
	leaves the block's gold too), so the two always match.
]]
local DARK = { 0.3, 0.3, 0.3, desaturated = true }
RunTracker.DARK = DARK
RunTracker.tintFrame = false

-- A texture's tint, { r, g, b, a, desaturated = true or false }; nil where it has none (white, opaque, in colour) or is
-- no texture.
local function TintOf(texture)
	if type(texture) ~= "table" or type(texture.GetVertexColor) ~= "function" then return nil end
	local r, g, b, a = texture:GetVertexColor()
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return nil end
	if type(a) ~= "number" then a = 1 end
	local desaturated = type(texture.IsDesaturated) == "function" and texture:IsDesaturated() == true
	if not desaturated and r >= 0.995 and g >= 0.995 and b >= 0.995 and a >= 0.995 then return nil end
	return { r, g, b, a, desaturated = desaturated }
end

-- The bar's and the button's tints, each kept from the first section header that has one.
local function ReadHeader(header, bar, button)
	if type(header) ~= "table" then return bar, button end
	bar = bar or TintOf(header.Background)
	if not button then
		local minimize = header.MinimizeButton
		if type(minimize) == "table" and type(minimize.GetNormalTexture) == "function" then
			button = TintOf(minimize:GetNormalTexture())
		end
	end
	return bar, button
end

-- The tint of the tracker's headers' bar and button (nil, nil where none is tinted), the counterpart of the look
-- given first ("All Objectives" for STYLES.objectives, "Quests" for STYLES.quests and by default). Only read.
function RunTracker.TrackerTint(style)
	local quests, tracker = QuestObjectiveTracker, ObjectiveTrackerFrame
	local container = type(tracker) == "table" and tracker.Header or nil
	local bar, button
	if style == STYLES.objectives then bar, button = ReadHeader(container, bar, button) end
	if type(quests) == "table" then bar, button = ReadHeader(quests.Header, bar, button) end
	if type(tracker) ~= "table" then return bar, button end
	local modules = tracker.modules
	if type(modules) == "table" then
		for _, module in ipairs(modules) do
			if bar and button then break end
			if type(module) == "table" and module ~= quests then bar, button = ReadHeader(module.Header, bar, button) end
		end
	end
	if style == STYLES.objectives then return bar, button end
	return ReadHeader(container, bar, button)
end

local function SameTint(a, b)
	if a == nil or b == nil then return a == b end
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and (a[4] or 1) == (b[4] or 1) and a.desaturated == b.desaturated
end

-- One of the block's own textures given a tint (nil: none, as the client draws it); changed only when it changes.
local function Paint(texture, tint)
	if not texture or SameTint(texture.tint, tint) then return end
	texture.tint = tint
	texture:SetDesaturated(tint ~= nil and tint.desaturated == true)
	if tint then
		texture:SetVertexColor(tint[1], tint[2], tint[3], tint[4] or 1)
	else
		texture:SetVertexColor(1, 1, 1)
	end
end

function RunTracker:Paint()
	local block = self.block
	if not block then return end
	local bar, button = RunTracker.TrackerTint(self.style)
	self.tintSource = bar and "the tracker's" or "none"
	-- "Dark mode" only where the tracker's bar has no tint: a tinted tracker keeps its own look on bar and button.
	if Run:Option("darkMode") and not bar then
		self.tintSource = "dark mode"
		bar, button = DARK, button or DARK
	end
	self.tint = bar
	Paint(block.Header.Background, bar)
	Paint(block.Header.Button.Icon, button)
	-- The lock's glyph as the collapse button's (its highlight, as that button's, as it is).
	Paint(block.Header.Lock.Glyph, button)
	Paint(block.Header.Lock.Boost, button)
	local frameTint = self.tintFrame and bar or nil
	for _, piece in ipairs(block.Frame.Art) do Paint(piece, frameTint) end
	for _, circle in ipairs(self.circles) do Paint(circle.Ring, frameTint) end
end

--[[
	Dragged by its header ("Place it freely"): the client moves it under the mouse (StartMoving), and nothing of the
	journal's places it again until it is dropped (RunTracker:Place: its clock once a second, a quest event's placing,
	a zone change, Edit Mode closed), else it went back to its old spot (0.39.20 and 0.39.21's test build). Dropped
	at its OnDragStop; or, with none (let go off the header), at the button let go anywhere (GLOBAL_MOUSE_UP, listened
	to only while it is dragged), a frame later so its own OnDragStop goes first; or when it is hidden; or at the next
	placing, the button found up. Nothing runs every frame.
]]
local drag = CreateFrame("Frame")
RunTracker.drag = drag

function RunTracker:StartDrag()
	local block = self.block
	-- Not while locked (the header's lock, LOCK).
	if self.dragging or not (block and self:Free()) or self:Locked() then return end
	self.dragging = true
	block:StartMoving()
	pcall(drag.RegisterEvent, drag, "GLOBAL_MOUSE_UP")
end

function RunTracker:EndDrag()
	local block = self.block
	if not (block and self.dragging) then return end
	self.dragging = nil
	pcall(drag.UnregisterEvent, drag, "GLOBAL_MOUSE_UP")
	block:StopMovingOrSizing()
	-- Its spot is the journal's to keep (KeepSpot), not the client's layout file's.
	if block.SetUserPlaced then block:SetUserPlaced(false) end
	self:KeepSpot()
	self:Place()
end

drag:SetScript("OnEvent", function(_, _, button)
	if button ~= "LeftButton" or not RunTracker.dragging then return end
	C_Timer.After(0, function() RunTracker:EndDrag() end)
end)

-- Dropped: the spot kept for the character (the pretend block's for the test: Kept), where it was let go. Its edges
-- and SetPoint's offsets are both in the block's own units (it has no scale of its own: UIParent's), from UIParent's
-- bottom left, so at any UI scale.
function RunTracker:KeepSpot()
	local kept = self:Kept()
	if not (self:Free() and kept) then return end
	local left, top = self.block:GetLeft(), self.block:GetTop()
	if not (left and top) then return end
	kept.runSpot = { "TOPLEFT", "BOTTOMLEFT", left, top }
end

------------------------------------------------------------------------------------------
-- Showing, ticking, collapsing
------------------------------------------------------------------------------------------

-- Collapsed by its header's button (kept for the character; the pretend block's for the test: Kept). Not for the last
-- run shown outside (/ij run): that one shows whole, and its button puts it away.
function RunTracker:Collapsed(view)
	if view and view.frozen then return false end
	local kept = self:Kept(view)
	return kept ~= nil and kept.runCollapsed == true
end

function RunTracker:HeaderButton()
	local kept = self:Kept()
	if self.view and self.view.frozen then
		self.showingLast = false
	elseif kept then
		kept.runCollapsed = not self:Collapsed() or nil
	end
	self:Refresh()
end

-- EDIT_MODE_LAYOUTS_UPDATED: Edit Mode's layout given to the tracker (at login, a layout chosen), its place and
-- Height with it, by Edit Mode's own handler of the same event: placed again a moment later, after it.
local SHOWN_EVENTS = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "QUEST_WATCH_LIST_CHANGED",
	"QUEST_LOG_UPDATE", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED", "EDIT_MODE_LAYOUTS_UPDATED" }
local events = CreateFrame("Frame")
RunTracker.events = events

function RunTracker:StopTicker()
	if self.ticker then
		self.ticker:Cancel()
		self.ticker = nil
	end
end

function RunTracker:Refresh()
	-- Inside, the run going on (or its wing waited for): the last run shown outside (/ij run) is put away, so leaving
	-- hides the block again. So too while test mode pretends to be inside (UI/TestRun.lua: Pretend I'm inside ticked,
	-- a dungeon picked or Walk in; the owner, 2026-11-18): unticked or End test, no last run comes back until /ij run.
	if Run:Inside() or Run:WaitingForWing() or (ns.TestRun and ns.TestRun:Pretending()) then self.showingLast = false end
	local view = Run:Option("on") and self:View() or nil
	if view and not view.frozen and view.run and view.run.hidden then view = nil end
	self.view = view
	if not view then
		if self.block then self.block:Hide() end
		if self.inside then self.inside:Release(self.block) end
		self:StopTicker()
		if self.listening then ns.UnregisterEvents(events, unpack(SHOWN_EVENTS)) end
		self.listening = nil
		return
	end
	self:Build()
	if next(fallbacks) then TrackerFontsNow() end
	-- Collapsed before it was ever open this run: laid out open once, to know its full height for Place.
	if self:Collapsed(view) and self.fullFor ~= FullKey(view) then self:Layout(view, true) end
	self:Layout(view)
	self:Place()
	self.block:Show()
	if not self.listening then ns.RegisterEvents(events, unpack(SHOWN_EVENTS)) end
	self.listening = true
	-- (no clock to tick while the wing is waited for)
	if self:Collapsed(view) or view.waiting then
		self:StopTicker()
	elseif not self.ticker and C_Timer and C_Timer.NewTicker then
		self.ticker = C_Timer.NewTicker(1, function() RunTracker:Tick() end)
	end
end

-- Once a second while shown: the clock, the items still waiting for a price, and where the tracker is now.
function RunTracker:Tick()
	local run = Run:Inside() and Run:Current()
	if run then
		run.lastSeen = time()
		Run:Settle()
	end
	self:Refresh()
end

events:SetScript("OnEvent", function(_, event)
	if event == "QUEST_LOG_UPDATE" or event == "QUEST_WATCH_LIST_CHANGED" or event == "EDIT_MODE_LAYOUTS_UPDATED" then
		-- Often, and in bursts: placed again once, a moment later.
		if RunTracker.placeDue then return end
		RunTracker.placeDue = true
		C_Timer.After(0.2, function()
			RunTracker.placeDue = nil
			if RunTracker.block and RunTracker.block:IsShown() then RunTracker:Place() end
		end)
		return
	end
	RunTracker:Refresh()
end)

Run:OnChange(function() RunTracker:Refresh() end)

--[[
	Edit Mode closed: the tracker may have a new place or a new height, and its headers' art a new tint (a dark-mode UI
	that tints it again then). The block placed again, once, through Refresh, its tint read again with it. While Edit
	Mode is open, the block's clock (once a second, while it is open) follows. EventRegistry calls this out of Edit
	Mode's own code (CallbackRegistry.lua's TriggerEvent: securecallfunction).
]]
if EventRegistry and EventRegistry.RegisterCallback then
	EventRegistry:RegisterCallback("EditMode.Exit", function()
		if RunTracker.block and RunTracker.block:IsShown() then RunTracker:Refresh() end
	end, RunTracker)
end

------------------------------------------------------------------------------------------
-- /ij run
------------------------------------------------------------------------------------------

local function NotifyOption(variable)
	if Settings and Settings.NotifyUpdate then pcall(Settings.NotifyUpdate, variable) end
end

-- Where the block is, the look of its header, and its gold art's tint and where it comes from (for the owner's
-- in-game check of dark mode); its lock: shown or not, locked or not, and its art (LOCK).
function RunTracker:PlacementText()
	local tint = self.tint
	local lock = self.block and self.block.Header.Lock
	local lockText = (lock and lock:IsShown() and "shown" or "hidden") .. ", " .. (self:Locked() and "locked" or "unlocked")
		.. (lock and lock.fallback and ", classic art" or "")
	return string.format("placement: %s; header: %s; tint: %s%s; lock: %s", tostring(self.placement),
		self.style and self.style.label or "none", tostring(self.tintSource or "none"),
		tint and string.format(" (%.2f, %.2f, %.2f%s)", tint[1], tint[2], tint[3], tint.desaturated and ", gray" or "") or "",
		lockText)
end

function RunTracker:Slash(rest)
	local word = strtrim(rest or ""):lower():match("^(%S*)")
	if word == "" then
		local wait = Run:WaitingForWing() and Run.session.wingWait
		local run = Run:Inside() and Run:Current()
		if wait then
			-- (the wing not known yet: "Which wing?" hidden or shown, and the run the wing decides with it, Run:Entered)
			wait.hidden, wait.toggled = not wait.hidden or nil, true
			if wait.hidden then ns.Print(L.RUN_HIDDEN) end
		elseif run then
			run.hidden = not run.hidden or nil
			if run.hidden then ns.Print(L.RUN_HIDDEN) end
		elseif ns.TestRun and ns.TestRun:Pretending() then
			-- (test mode's pretend run, UI/TestRun.lua: hidden or shown again, for this session)
			local _, hidden = ns.TestRun:ToggleHidden()
			if hidden then ns.Print(L.RUN_HIDDEN) end
		elseif Run:Last() then
			self.showingLast = not self.showingLast
		else
			ns.Print(L.RUN_NONE)
		end
		if not Run:Option("on") then ns.Print(L.RUN_IS_OFF) end
		self:Refresh()
	elseif word == "new" then
		-- (the wing not known yet: the new run starts once it is, Run:NewRunAsked)
		ns.Print(not Run:NewRun() and L.RUN_NOT_INSIDE or Run:WaitingForWing() and L.RUN_NEW_WING or L.RUN_NEW)
	elseif word == "unlock" or word == "lock" then
		-- The header's lock (LOCK), since 0.39.23; placing it freely is the "Place it freely" option's. The second line
		-- only while that option is unticked (it names it): with it ticked and "Inside the quest tracker" winning, none.
		self:SetLocked(word == "lock")
		ns.Print(word == "lock" and L.RUN_LOCK_ON or L.RUN_LOCK_OFF)
		if not Run:Option("free") then ns.Print(string.format(L.RUN_LOCK_NOT_FREE, L.OPTIONS_RUN_FREE)) end
	elseif word == "reset" then
		-- Its spot and its lock forgotten (the lock with it: a best guess), back by the tracker; test mode's copy of them
		-- for the pretend block too (UI/TestRun.lua's Look).
		if ns.charDB then ns.charDB.runSpot, ns.charDB.runLocked = nil, nil end
		if ns.TestRun then ns.TestRun:ForgetLook() end
		Run:SetOption("free", false)
		NotifyOption("AEGIS_JOURNAL_RUN_FREE")
		ns.Print(L.RUN_FREE_OFF)
	elseif word == "debug" then
		Run:Debug(self:PlacementText(), self.inside and self.inside:DebugText())
	else
		ns.Print(L.RUN_USAGE)
	end
end
