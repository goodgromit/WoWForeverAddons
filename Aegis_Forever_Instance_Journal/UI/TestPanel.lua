local _, ns = ...
local L = ns.L

--[[
	Test mode's panel (the owner, 2026-11-18, testing 0.40: "i cant pull up the maps when im outside of the dungeon or
	open that dungeons run block in adventure mode - can we build a more intuitive and solid test options so we can test
	these features without being in the instance?"): one small window to test a dungeon's map, fog, run block and
	Adventure Mode from anywhere. Opened by /aegis test (or /ij test), /ij fogtest, or the Test mode button at the
	bottom of the journal's options; /aegis test off ends the test, /aegis test debug prints what it is doing.

	Top to bottom: the dungeon menu (every dungeon under the journal's level brackets, each once, then the raids: found
	or not, Adventure Mode or not); Show Map (the dungeon's map from anywhere, under the fog as the test's kills leave
	it: UI/DungeonMap.lua's Show); Walk in (only at a Scarlet Monastery wing's door); "Pretend I'm inside" (the run block
	as on walking in: UI/TestRun.lua); "Show as found (Adventure Mode)" (UI/FogTest.lua's SetFound); the bosses with a
	box each (defeated: the test's kill, else the character's own), what the game treats differently about each (rare,
	summoned, not counted, maybe, quest, outside, final), and Next, All and Reset; one line saying what the test shows;
	End test. A kill made here, on the map's pins and hints or on the pretend run's circles is the same kill everywhere
	(UI/FogTest.lua's Mark). The panel alone has the count and Next, All, Reset and End test: the dungeon map shows
	nothing of the test's own (but a line in a pin's tooltip, on hover), so a map opened in test mode looks as in a
	real run (the owner, 2026-11-18, to take its pictures for a release). The panel and the map speak of one dungeon:
	a pick shows the new one's map if the map was open on the old one (Pick), and the journal's Show Map on another
	dungeon's page moves the panel to it (FollowMap).

	For this session only, like everything of the test: nothing is saved (not even where the panel was dragged: its
	position is the client's to forget, SetUserPlaced false). Closing the panel (its X, Escape) only hides it, the test
	going on (a pin's tooltip says so, on hover, and the pretend block's "(test)" while pretending to be inside); End
	test (here, or /ij test off) or a /reload ends it; /ij test or the options' button brings the panel back.

	The look is the journal's own (the owner's rule: Blizzard's own templates and art, nothing custom): the window is
	ButtonFrameTemplate with its portrait hidden (the journal's frame art), the game's panel buttons, check buttons and
	fonts, the journal's own dropdown and menu (UI/Art.lua's ns.Menus: never the game's menus, which tainted its unit
	menus), the inset's marble from the template. Built the first time it opens; no OnUpdate, no ticker: it is drawn
	again only when something it shows changes (the test's kills and finds, the pretend run, the style, a real
	dungeon entered or left; and the fight's start and end, heard only while it is shown).

	In a fight: Show Map is grayed (the game opens no map for an addon then). With "Inside the quest tracker" ticked,
	whatever shows, hides or reshapes the pretend block (Pretend I'm inside, Walk in, the menu and End test while
	pretending, the block's New run) waits for the fight to end, as the real block's New run does
	(RunTracker:RestartBlocked); everything else works, being the journal's own frames.
]]

local TestPanel = {}
ns.TestPanel = TestPanel

local FRAME_NAME = "AegisJournalTestPanel"

-- Its measures in UI units (the design of 2026-11-18 and its mock-up): the window as high as the journal's, beside
-- it past the boss page's side tabs (43 past the journal's edge: UI/Journal.lua's DOCK_LAYOUT), else in the game's
-- left window slot; the attic 60 high (the menu), the template's button bar 26 (End test). The readout has three lines
-- (the mock-up's two, and the list 12 shorter: its longest, a wing's door in a fight outside Adventure Mode, takes
-- three in most of the languages, measured at the client's fonts). A button as wide as its words want, at least its
-- own width (another language's End test, the client's Reset).
local SIZE = {
	width = 280, height = 496, beside = 47, slotX = 16, slotY = -116, drag = 24,
	menuX = 16, menuY = -31, menu = 248,
	button = 120, buttonHeight = 22, buttonPadding = 24, mapX = 16, walkX = 144, buttonsY = -68,
	box = 26, boxX = 12, insideY = -94, foundY = -118, labelGap = 2,
	bossesX = 18, bossesY = -151, countRight = 262,
	listLeft = 12, listTop = -168, listRight = -26, listBottom = 98, row = 22, nameX = 24, tagGap = 6,
	small = 78, smallGap = 6, smallX = 16, smallY = -402,
	readoutX = 18, readoutY = -430, readout = 244, readoutLines = 3, line = 12,
	finish = 100, finishRight = -6, finishBottom = 4,
	insetTop = -60, insetBottom = 26,
}
TestPanel.SIZE = SIZE

-- A refusal's line on a tooltip (the run block's red), and the gold of the game's tooltip lines.
local RED, GOLD = { 1, 0.125, 0.125 }, { 1, 0.82, 0 }

-- What the game treats differently about a boss, in this order, each a gray word on his row and a line on its tooltip
-- (Core/Run.lua's Counted and Others; the fog's rule, UI/DungeonFog.lua: rares and summoned bosses hold back none).
local TAGS = {
	{ field = "rare", text = "TEST_TAG_RARE", tip = "TEST_TIP_RARE" },
	{ field = "summoned", text = "TEST_TAG_SUMMONED", tip = "TEST_TIP_SUMMONED" },
	{ field = "uncounted", text = "TEST_TAG_NOT_COUNTED", tip = "TEST_TIP_NOT_COUNTED" },
	{ field = "maybe", text = "TEST_TAG_MAYBE", tip = "TEST_TIP_MAYBE" },
	{ field = "questTarget", text = "TEST_TAG_QUEST", tip = "TEST_TIP_QUEST" },
	{ field = "outsideRun", text = "TEST_TAG_OUTSIDE", tip = "TEST_TIP_OUTSIDE" },
	{ final = true, text = "TEST_TAG_FINAL", tip = "TEST_TIP_FINAL" },
}

-- The window, once made; the dungeon it is for (this session); dragged by the player this session.
local panel, selected, dragged
--[[
	A fight begun while the panel shows: PLAYER_REGEN_DISABLED comes before the game's lockdown starts (Core/Compat.lua's
	note), so InCombatLockdown still says no while the panel is drawn for it. The panel goes by the event until
	PLAYER_REGEN_ENABLED, which comes after the lockdown ends, or until it is hidden (shown again, InCombatLockdown is
	right by then).
]]
local fightBegun

local function InFight()
	return InCombatLockdown() == true or fightBegun == true
end

------------------------------------------------------------------------------------------
-- What it shows
------------------------------------------------------------------------------------------

-- The dungeons under the journal's level brackets (ns.LEVEL_BRACKETS, the Dungeons tab's), each once: under the last
-- bracket its lowest level falls in (Scarlet Monastery's Graveyard, 30, under "Level 30 to 45"), in the journal's
-- order; a bracket with none left out. Every dungeon the journal lists, found or not.
function TestPanel.Brackets()
	local groups = {}
	for _, bracket in ipairs(ns.LEVEL_BRACKETS) do
		if bracket.min then groups[#groups + 1] = { bracket = bracket, list = {} } end
	end
	for _, instance in ipairs(ns.GetInstances("dungeon")) do
		local low, home = instance.levelMin, groups[1]
		for _, group in ipairs(groups) do
			if type(low) == "number" and low >= group.bracket.min and low <= group.bracket.max then home = group end
		end
		if home then home.list[#home.list + 1] = instance end
	end
	local shown = {}
	for _, group in ipairs(groups) do
		if #group.list > 0 then shown[#shown + 1] = group end
	end
	return shown
end

-- The words for a boss: his tags joined ("summoned, not counted") and their tooltip lines.
local function Tags(instance, boss)
	local final = ns.Run.FinalEntry(instance)
	local words, tips = {}, {}
	for _, tag in ipairs(TAGS) do
		local has = false
		if tag.final then
			for _, part in ipairs(final and final.parts or {}) do has = has or part == boss end
		else
			has = boss[tag.field] == true
		end
		if has then
			words[#words + 1] = L[tag.text]
			tips[#tips + 1] = L[tag.tip]
		end
	end
	return table.concat(words, ", "), tips
end
TestPanel.Tags = Tags

-- The client's name for the dungeon the player is really in (the real run shows there).
local function RealName()
	local ok, name = pcall(GetInstanceInfo)
	name = ok and ns.Readable(name) or nil
	if type(name) == "string" and name ~= "" then return name end
	local here = ns.CurrentInstance(true)
	return here and here.name or ""
end

-- Why "Pretend I'm inside" is refused (UI/TestRun.lua's Refused), in words: its tooltip's, and the chat's on a click.
local function RefusalNote(why)
	return why == "raid" and L.TEST_INSIDE_RAID or why == "real" and string.format(L.TEST_INSIDE_REAL, RealName())
		or why == "off" and L.RUN_IS_OFF or why == "combat" and L.TEST_TRACKER_COMBAT or nil
end

--[[
	What the test shows now, on one line (the panel's last, and /aegis test debug's first): the dungeon; really inside
	one (the real run on the block, the test's kills not on it), pretending to be inside or at a wing's door, or outside;
	its bosses defeated; its fog; in Adventure Mode, shown as found by the box, found by a test kill (the box unticked,
	the character not having found it), or as the character found it; in a fight.
]]
function TestPanel:ReadoutText()
	local instance = selected
	if not instance then return "" end
	local TR, FT, D = ns.TestRun, ns.FogTest, ns.Discovery
	local parts = { instance.name }
	if TR:RealInside() then
		parts[#parts + 1] = L.TEST_STATE_REAL_INSIDE
	elseif TR:Pretending() then
		parts[#parts + 1] = TR:Waiting() and L.TEST_STATE_DOOR or L.TEST_STATE_INSIDE
	else
		parts[#parts + 1] = L.TEST_STATE_OUTSIDE
	end
	parts[#parts + 1] = string.format(L.TEST_STATE_DEFEATED, FT:Count(instance))
	if not ns.DungeonFog:Has(instance) then
		parts[#parts + 1] = L.TEST_STATE_NO_FOG
	else
		parts[#parts + 1] = ns.DungeonFog:On() and L.TEST_STATE_FOG_ON or L.TEST_STATE_FOG_OFF
	end
	if not ns.Style:Adventure() then
		parts[#parts + 1] = L.TEST_STATE_NOT_ADVENTURE
	elseif FT:Found(instance) then
		parts[#parts + 1] = L.TEST_STATE_FOUND
	elseif D:Knows("instance", instance) and not D:KnowsReally("instance", instance) then
		parts[#parts + 1] = L.TEST_STATE_KILL_FOUND
	else
		parts[#parts + 1] = L.TEST_STATE_REAL
	end
	if InFight() then parts[#parts + 1] = L.TEST_STATE_COMBAT end
	return table.concat(parts, " - ")
end

------------------------------------------------------------------------------------------
-- Building
------------------------------------------------------------------------------------------

local function HideTip(owner)
	if GameTooltip:GetOwner() == owner then GameTooltip:Hide() end
end

-- A control's tooltip: its name, what it does (gold), why it is grayed where it is (note, in its color: red for a
-- refusal), each line wrapped.
local function ShowTip(owner)
	if not owner.tipTitle then return end
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	GameTooltip:SetText(owner.tipTitle, 1, 1, 1)
	for _, line in ipairs(owner.tipLines or {}) do GameTooltip:AddLine(line, GOLD[1], GOLD[2], GOLD[3], true) end
	if owner.tipNote then
		local color = owner.tipNoteColor or RED
		GameTooltip:AddLine(owner.tipNote, color[1], color[2], color[3], true)
	end
	GameTooltip:Show()
end

local function Tip(owner)
	if owner.SetMotionScriptsWhileDisabled then owner:SetMotionScriptsWhileDisabled(true) end
	owner:SetScript("OnEnter", ShowTip)
	owner:SetScript("OnLeave", HideTip)
end

-- A control's state: usable or grayed, its tooltip's words; the tooltip drawn again if it is up.
local function SetUsable(control, usable, title, lines, note, noteColor)
	control:SetEnabled(usable and true or false)
	if control.Label then
		local color = usable and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR
		if color and color.GetRGB then control.Label:SetTextColor(color:GetRGB()) end
	end
	control.tipTitle, control.tipLines, control.tipNote, control.tipNoteColor = title, lines, note, noteColor
	if GameTooltip:GetOwner() == control and GameTooltip:IsShown() then ShowTip(control) end
end

local function Button(parent, width, text, onClick)
	local button = ns.CreateFrameWithTemplate("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, SIZE.buttonHeight)
	button:SetText(text)
	local words = button.GetTextWidth and button:GetTextWidth() or 0
	if type(words) == "number" and words + SIZE.buttonPadding > width then button:SetWidth(words + SIZE.buttonPadding) end
	button:SetScript("OnClick", function(self)
		if self.IsEnabled and not self:IsEnabled() then return end
		ns.PlaySoundKit("IG_MAINMENU_OPTION")
		onClick(self)
	end)
	Tip(button)
	return button
end

-- A check button with its label to its right (GameFontHighlight, grayed with it). Its click does what it says
-- (onClick); the box is drawn again from what the test then is (TestPanel:Redraw), not from its own toggle.
local function Box(parent, x, y, text, onClick)
	local box = ns.CreateFrameWithTemplate("CheckButton", nil, parent, "UICheckButtonTemplate")
	box:SetSize(SIZE.box, SIZE.box)
	box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	box.Label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	box.Label:SetPoint("LEFT", box, "RIGHT", SIZE.labelGap, 1)
	box.Label:SetText(text)
	box:SetScript("OnClick", function(self)
		if self.IsEnabled and not self:IsEnabled() then return end
		ns.PlaySoundKit(self:GetChecked() and "IG_MAINMENU_OPTION_CHECKBOX_ON" or "IG_MAINMENU_OPTION_CHECKBOX_OFF")
		onClick(self)
		TestPanel:Redraw()
	end)
	Tip(box)
	return box
end

-- A boss's row: its box (defeated), his name, his tags; a click on the box or the row marks him defeated, or
-- standing again (the test's kill: UI/FogTest.lua's SetKilled).
local function RowClick(row)
	local boss = row.boss
	if not (boss and selected) then return end
	local dead = not ns.Discovery:Killed(selected, boss)
	ns.PlaySoundKit(dead and "IG_MAINMENU_OPTION_CHECKBOX_ON" or "IG_MAINMENU_OPTION_CHECKBOX_OFF")
	ns.FogTest:SetKilled(selected, boss, dead)
end

local function RowTip(row)
	row = row.boss and row or row:GetParent()
	if not row.boss then return end
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:SetText(row.boss.name, 1, 1, 1)
	for _, line in ipairs(row.tips or {}) do GameTooltip:AddLine(line, GOLD[1], GOLD[2], GOLD[3], true) end
	GameTooltip:AddLine(L.FOGTEST_PIN_CLICK, 0.5, 0.8, 1, true)
	GameTooltip:Show()
end

local function Row(index)
	local rows = panel.Rows
	if rows[index] then return rows[index] end
	local list = panel.List
	local row = CreateFrame("Button", nil, list.Child)
	row:SetSize(list.width, SIZE.row)
	row:SetPoint("TOPLEFT", list.Child, "TOPLEFT", 0, -(index - 1) * SIZE.row)
	-- Lit under the mouse as the journal's menus' rows are (UI/Art.lua).
	row.Highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.Highlight:SetAllPoints()
	row.Highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	row.Highlight:SetBlendMode("ADD")
	row.Check = ns.CreateFrameWithTemplate("CheckButton", nil, row, "UICheckButtonTemplate")
	row.Check:SetSize(SIZE.row, SIZE.row)
	row.Check:SetPoint("LEFT", row, "LEFT", 0, 0)
	row.Tag = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.Tag:SetPoint("RIGHT", row, "RIGHT", -2, 0)
	row.Tag:SetJustifyH("RIGHT")
	row.Name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.Name:SetPoint("LEFT", row, "LEFT", SIZE.nameX, 0)
	row.Name:SetPoint("RIGHT", row.Tag, "LEFT", -SIZE.tagGap, 0)
	row.Name:SetJustifyH("LEFT")
	row.Name:SetWordWrap(false)
	row:SetScript("OnClick", RowClick)
	row.Check:SetScript("OnClick", function(self) RowClick(self:GetParent()) end)
	for _, frame in ipairs({ row, row.Check }) do
		frame:SetScript("OnEnter", RowTip)
		frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end
	rows[index] = row
	return row
end

-- The dungeon menu: a radio for each, the one shown with its dot.
local function IsPicked(instance) return instance == selected end
local function PickFromMenu(instance) TestPanel:Pick(instance) end

local function FillMenu(_, root)
	root:CreateTitle(L.TAB_DUNGEONS)
	for _, group in ipairs(TestPanel.Brackets()) do
		local bracket = root:CreateButton(group.bracket.text)
		for _, instance in ipairs(group.list) do bracket:CreateRadio(instance.name, IsPicked, PickFromMenu, instance) end
	end
	local raids = ns.GetInstances("raid")
	if #raids > 0 then
		root:CreateDivider()
		root:CreateTitle(L.TAB_RAIDS)
		for _, instance in ipairs(raids) do root:CreateRadio(instance.name, IsPicked, PickFromMenu, instance) end
	end
end

-- Hidden, the test goes on; its fight's events heard only while it shows.
local function OnShow(self)
	ns.RegisterEvents(self, "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")
	TestPanel:Redraw()
end

local function OnHide(self)
	ns.UnregisterEvents(self, "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")
	fightBegun = nil
	-- Hidden while dragged (Escape): stopped there, and its place still the client's to forget, as on a drop (the drag
	-- frame's OnDragStop may not come then: a best guess).
	self:StopMovingOrSizing()
	if self.SetUserPlaced then self:SetUserPlaced(false) end
	-- (a tooltip of one of its controls goes with it)
	local owner = GameTooltip:GetOwner()
	while owner do
		if owner == self then
			GameTooltip:Hide()
			break
		end
		owner = owner.GetParent and owner:GetParent() or nil
	end
end

local function Build()
	if panel then return panel end
	local f = ns.CreateFrameWithTemplate("Frame", FRAME_NAME, UIParent, "ButtonFrameTemplate", "PortraitFrameTemplate")
	panel = f
	-- The journal's frame art without its portrait: the template's own call (its NineSlice's NoPortrait layout).
	if type(ButtonFrameTemplate_HidePortrait) == "function" then pcall(ButtonFrameTemplate_HidePortrait, f) end
	f:SetSize(SIZE.width, SIZE.height)
	-- Above the journal (HIGH) and the world map, as the journal's search window and style question are.
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:Hide()
	if f.SetTitle then f:SetTitle(L.TEST_TITLE) elseif f.TitleText then f.TitleText:SetText(L.TEST_TITLE) end
	-- The template's X closes through HideUIPanel, which the game may refuse an addon in combat: the panel's own Hide,
	-- as the journal's X does.
	local close = rawget(f, "CloseButton")
	if close and close.SetScript then close:SetScript("OnClick", function() TestPanel:Hide() end) end
	-- The template's inset (its marble), else one made the same.
	local inset = rawget(f, "Inset")
	if not inset then
		inset = ns.CreateFrameWithTemplate("Frame", nil, f, "InsetFrameTemplate")
		inset:SetPoint("TOPLEFT", 4, SIZE.insetTop)
		inset:SetPoint("BOTTOMRIGHT", -6, SIZE.insetBottom)
		f.Inset = inset
	end
	-- Moved by its title bar, for this session: dropped, it stays there until /reload, its place never saved.
	local drag = CreateFrame("Frame", nil, f)
	drag:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	drag:SetPoint("TOPRIGHT", f, "TOPRIGHT", -SIZE.drag, 0)
	drag:SetHeight(SIZE.drag)
	drag:EnableMouse(true)
	drag:RegisterForDrag("LeftButton")
	drag:SetScript("OnDragStart", function() f:StartMoving() end)
	drag:SetScript("OnDragStop", function()
		f:StopMovingOrSizing()
		if f.SetUserPlaced then f:SetUserPlaced(false) end
		dragged = true
	end)
	f.Drag = drag

	f.Menu = ns.Menus:NewDropdown(f, SIZE.menu)
	f.Menu:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.menuX, SIZE.menuY)
	f.Menu:SetDefaultText(L.TEST_PICK)
	f.Menu:SetupMenu(FillMenu)

	-- (the client's Show Map is on two lines, for the retail journal's button beside its icon: on one here, as on every
	-- map button of the journal's, UI/QuestsPanel.lua's MapLabelText)
	f.Map = Button(f, SIZE.button, ns.QuestsPanel:MapLabelText(L.MAP_SHOW), function()
		if selected then ns.DungeonMap:Show(selected) end
		TestPanel:Redraw()
	end)
	f.Map:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.mapX, SIZE.buttonsY)
	f.Walk = Button(f, SIZE.button, L.TEST_WALK_IN, function() TestPanel:WalkIn() end)
	f.Walk:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.walkX, SIZE.buttonsY)
	f.Walk:Hide()

	f.Inside = Box(f, SIZE.boxX, SIZE.insideY, L.TEST_INSIDE, function() TestPanel:ToggleInside() end)
	f.Found = Box(f, SIZE.boxX, SIZE.foundY, L.TEST_FOUND, function()
		if selected then ns.FogTest:SetFound(selected, not ns.FogTest:Found(selected)) end
	end)

	f.Bosses = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.Bosses:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.bossesX, SIZE.bossesY)
	f.Bosses:SetText(L.TEST_BOSSES)
	f.Count = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.Count:SetPoint("TOPRIGHT", f, "TOPLEFT", SIZE.countRight, SIZE.bossesY)
	f.Count:SetJustifyH("RIGHT")
	-- The bosses: the journal's scroll frame (its bar hidden while nothing scrolls), 22 a row.
	local list = ns.CreateScrollFrame(f, 6, -12, 12)
	list:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.listLeft, SIZE.listTop)
	list:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", SIZE.listRight, SIZE.listBottom)
	list.width = SIZE.width - SIZE.listLeft + SIZE.listRight
	list.Child:SetWidth(list.width)
	f.List, f.Rows = list, {}

	f.Next = Button(f, SIZE.small, L.FOGTEST_NEXT, function() if selected then ns.FogTest:Next(selected) end end)
	f.All = Button(f, SIZE.small, L.FOGTEST_ALL, function() if selected then ns.FogTest:SetAll(selected, true) end end)
	f.Reset = Button(f, SIZE.small, L.FOGTEST_RESET, function() if selected then ns.FogTest:SetAll(selected, false) end end)
	f.Next:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.smallX, SIZE.smallY)
	f.All:SetPoint("TOPLEFT", f.Next, "TOPRIGHT", SIZE.smallGap, 0)
	f.Reset:SetPoint("TOPLEFT", f.All, "TOPRIGHT", SIZE.smallGap, 0)

	-- The line saying what the test shows; its tooltip the whole of it, and the fog's advice where the fog is off.
	local holder = CreateFrame("Frame", nil, f)
	holder:SetPoint("TOPLEFT", f, "TOPLEFT", SIZE.readoutX, SIZE.readoutY)
	holder:SetSize(SIZE.readout, SIZE.readoutLines * SIZE.line + 2)
	holder:EnableMouse(true)
	f.Readout = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.Readout:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	f.Readout:SetWidth(SIZE.readout)
	f.Readout:SetJustifyH("LEFT")
	if f.Readout.SetMaxLines then f.Readout:SetMaxLines(SIZE.readoutLines) end
	Tip(holder)
	f.ReadoutHolder = holder

	f.End = Button(f, SIZE.finish, L.TEST_END, function() TestPanel:End() end)
	f.End:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", SIZE.finishRight, SIZE.finishBottom)

	f:SetScript("OnShow", OnShow)
	f:SetScript("OnHide", OnHide)
	-- (a fight begun: drawn as in it, the game's lockdown starting only after this event: fightBegun)
	f:SetScript("OnEvent", function(_, event)
		fightBegun = event == "PLAYER_REGEN_DISABLED" or nil
		TestPanel:Redraw()
	end)
	-- Escape hides it (the test going on), as it closes the journal.
	table.insert(UISpecialFrames, FRAME_NAME)
	return f
end

-- Beside the journal while it shows (anchored to it, so it follows the journal), else in the game's left window slot;
-- where the player dropped it once dragged, this session.
local function Place()
	if dragged then return end
	panel:ClearAllPoints()
	local journal = ns.Journal:IsShown() and ns.Journal:Window()
	if journal then
		panel:SetPoint("TOPLEFT", journal, "TOPRIGHT", SIZE.beside, 0)
	else
		panel:SetPoint("TOPLEFT", UIParent, "TOPLEFT", SIZE.slotX, SIZE.slotY)
	end
end

------------------------------------------------------------------------------------------
-- Drawing
------------------------------------------------------------------------------------------

-- Everything drawn as the test is now (only while it shows).
function TestPanel:Redraw()
	if not (panel and panel:IsShown() and selected) then return end
	local instance, FT, TR = selected, ns.FogTest, ns.TestRun
	local fight = InFight()
	local pretending = TR:Pretending()
	local blocked = pretending and TR:Blocked(fight)

	panel.Menu:GenerateMenu()
	panel.Menu:SetEnabled(not blocked)

	local hasMap = ns.DungeonMap:HasMap(instance)
	SetUsable(panel.Map, hasMap and not fight, ns.QuestsPanel:MapLabelText(L.MAP_SHOW), nil,
		not hasMap and L.TEST_NO_MAP or fight and L.MAP_PIN_COMBAT or nil)

	local door = TR:Waiting()
	panel.Walk:SetShown(door ~= nil and door == instance.instanceID)
	SetUsable(panel.Walk, not blocked, L.TEST_WALK_IN, { string.format(L.TEST_WALK_IN_TIP, instance.name) },
		blocked and L.TEST_TRACKER_COMBAT or nil)

	panel.Inside:SetChecked(pretending)
	local why = (not pretending and TR:Refused(instance, fight)) or (blocked and "combat") or nil
	SetUsable(panel.Inside, why == nil, L.TEST_INSIDE, { L.TEST_INSIDE_TIP }, RefusalNote(why))

	local adventure = ns.Style:Adventure()
	local really = adventure and ns.Discovery:KnowsReally("instance", instance) == true
	panel.Found:SetChecked(really or FT:Found(instance))
	SetUsable(panel.Found, adventure and not really, L.TEST_FOUND, { L.TEST_FOUND_TIP },
		not adventure and L.TEST_FOUND_OFF or really and L.TEST_FOUND_REAL or nil, really and GOLD or nil)

	local bosses = FT.Bosses(instance)
	local down, total = FT:Count(instance)
	panel.Count:SetText(string.format(L.TEST_DEFEATED, down, total))
	for index, boss in ipairs(bosses) do
		local row = Row(index)
		row.boss = boss
		local words, tips = Tags(instance, boss)
		row.tips = tips
		row.Name:SetText(boss.name)
		row.Tag:SetText(words)
		row.Check:SetChecked(ns.Discovery:Killed(instance, boss) == true)
		row:Show()
		if GameTooltip:GetOwner() == row and GameTooltip:IsShown() then RowTip(row) end
	end
	for index = #bosses + 1, #panel.Rows do
		panel.Rows[index].boss = nil
		panel.Rows[index]:Hide()
	end
	panel.List.Child:SetHeight(math.max(1, #bosses * SIZE.row))
	for _, button in ipairs({ panel.Next, panel.All, panel.Reset }) do button:SetEnabled(total > 0) end

	local readout = self:ReadoutText()
	panel.Readout:SetText(readout)
	local fogOff = ns.DungeonFog:Has(instance) and not ns.DungeonFog:On()
	panel.ReadoutHolder.tipTitle = L.TEST_TITLE
	-- (really inside a dungeon: why the block does not follow the test's kills)
	panel.ReadoutHolder.tipLines = { readout, TR:RealInside() and string.format(L.TEST_INSIDE_REAL, RealName()) or nil }
	panel.ReadoutHolder.tipNote, panel.ReadoutHolder.tipNoteColor = fogOff and L.FOGTEST_FOG_OFF or nil, GOLD
	if GameTooltip:GetOwner() == panel.ReadoutHolder and GameTooltip:IsShown() then ShowTip(panel.ReadoutHolder) end

	SetUsable(panel.End, not blocked, L.TEST_END, nil, blocked and L.TEST_TRACKER_COMBAT or nil)
end

------------------------------------------------------------------------------------------
-- What it does
------------------------------------------------------------------------------------------

-- The first dungeon of the session: the journal's open page, else the dungeon the player is in, else the journal's
-- first.
local function FirstPick()
	local shown = ns.Journal:ShownInstance()
	if shown then return shown end
	local here = ns.CurrentInstance(true)
	if here and (here.kind == "dungeon" or here.kind == "raid") then return here end
	return ns.GetInstances("dungeon")[1]
end

--[[
	/aegis test, /ij fogtest, the options' button: the test turned on if it was off (one line in chat) and then the
	journal opened if it was shut (on the panel's dungeon), and the panel shown beside it. Brought back while the test
	is on (its X or Escape hid it), the journal is left as the player left it: the panel beside it if it shows, else in
	the game's left window slot.
]]
function TestPanel:Open()
	local started = ns.FogTest:Start()
	if started then ns.Print(L.TEST_ON) end
	selected = selected or FirstPick()
	if started and not ns.Journal:IsShown() then ns.Journal:OpenForTest(selected, true) end
	Build()
	Place()
	panel:Show()
	self:Redraw()
	return true
end

-- The journal shown (UI/Journal.lua's OnShow): the panel, shown in the left window slot while the journal was shut,
-- goes beside it (not one the player dragged).
function TestPanel:JournalShown()
	if panel and panel:IsShown() and not dragged then Place() end
end

-- The X and Escape: the panel hidden, the test going on.
function TestPanel:Hide()
	if panel then panel:Hide() end
end

function TestPanel:IsShown()
	return panel ~= nil and panel:IsShown()
end

-- The panel and its dungeon, for the tests.
function TestPanel:Frame()
	return panel
end

function TestPanel:Selected()
	return selected
end

-- Refused while pretending in a fight with the run block inside the quest tracker (TestRun:Blocked): true and a line
-- in chat then.
local function Refused()
	if not (ns.TestRun:Pretending() and ns.TestRun:Blocked()) then return false end
	ns.Print(L.TEST_TRACKER_COMBAT)
	return true
end

-- The world map open on this dungeon's map (UI/DungeonMap.lua's overlay).
local function MapOn(instance)
	local overlay = ns.DungeonMap:Overlay()
	return WorldMapFrame ~= nil and WorldMapFrame:IsShown() and overlay ~= nil and overlay:IsShown()
		and overlay.instance == instance
end

--[[
	A dungeon picked in the menu: the panel's now, its page opened in a shown journal (through the gate: a rumor stays
	one unless shown as found), and the pretend run moved with it (UI/TestRun.lua's Move). The map open on the dungeon
	picked before shows the new one's, so the panel and the map never speak of two dungeons (not in a fight,
	when the game opens no map for an addon, nor for one with no map: the map is left as it is then, as it is when it
	shows another dungeon or is shut). From the map (FollowMap): its page and its map already shown.
]]
local function Choose(instance, fromMap)
	if type(instance) ~= "table" or instance == selected then return false end
	if Refused() then
		TestPanel:Redraw()
		return false
	end
	local was = selected
	selected = instance
	if not fromMap and ns.Journal:IsShown() then ns.Journal:OpenForTest(instance) end
	if ns.TestRun:Pretending() then ns.TestRun:Move(instance) end
	if not fromMap and was and MapOn(was) and ns.DungeonMap:HasMap(instance) and not InCombatLockdown() then
		ns.DungeonMap:Show(instance)
	end
	TestPanel:Redraw()
	return true
end

function TestPanel:Pick(instance)
	return Choose(instance, false)
end

--[[
	The journal's Show Map (UI/EncounterPage.lua) while the test is on: the panel goes to the dungeon the map now shows,
	so its count, Next, All and Reset are that dungeon's, as the strip on the map's were before it was removed (the
	owner, 2026-11-18: the map as in a real run, for the release's pictures). Shown or hidden, the panel follows (it
	opens on it again). Nothing while the test is off.
]]
function TestPanel:FollowMap(instance)
	if not (ns.FogTest:On() and ns.DungeonMap:HasMap(instance)) then return false end
	return Choose(instance, true)
end

--[[
	At a Scarlet Monastery wing's door, a kill on another wing's map names that wing (UI/TestRun.lua's Marked): the panel
	goes to that wing as well (its page with it in a shown journal), so its boxes, count and readout are the block's.
	Only another part of the same copy (its instance id), only while the pretend run shows it.
]]
function TestPanel:FollowRun()
	local run, here = ns.TestRun:Current()
	if not (run and here and selected) or here == selected then return false end
	if here.instanceID == nil or here.instanceID ~= selected.instanceID then return false end
	selected = here
	if ns.Journal:IsShown() then ns.Journal:OpenForTest(here) end
	return true
end

-- "Pretend I'm inside" ticked or unticked; refused, why in chat (as its tooltip says it).
function TestPanel:ToggleInside()
	if not selected or Refused() then return false end
	if ns.TestRun:Pretending() then return ns.TestRun:Leave() end
	local note = RefusalNote(ns.TestRun:Refused(selected))
	if note then
		ns.Print(note)
		return false
	end
	return ns.TestRun:Enter(selected)
end

-- Walk in: the wing shown in the menu, named at the door.
function TestPanel:WalkIn()
	if not selected or Refused() then return false end
	return ns.TestRun:WalkIn(selected)
end

-- End test (the panel's, /aegis test off): the pretend run left, every test kill and find forgotten, the
-- panel hidden, one line in chat. Refused only in a fight with the pretend block inside the quest tracker.
function TestPanel:End()
	if Refused() then return false end
	local was = ns.FogTest:On()
	ns.TestRun:Leave()
	ns.FogTest:Stop()
	self:Hide()
	if was then ns.Print(L.TEST_OFF) end
	return was
end

------------------------------------------------------------------------------------------
-- /aegis test
------------------------------------------------------------------------------------------

-- /aegis test debug: the readout, then what it is made of, one line each.
function TestPanel:Debug()
	local FT, TR, D, Fog = ns.FogTest, ns.TestRun, ns.Discovery, ns.DungeonFog
	local instance = selected or FirstPick()
	local lines = {}
	local function Add(text) lines[#lines + 1] = text end
	local function Yes(value) return value and "yes" or "no" end
	if selected then Add(self:ReadoutText()) end
	local overlay = ns.DungeonMap:Overlay()
	local map = "map shut"
	if WorldMapFrame and WorldMapFrame:IsShown() and overlay and overlay:IsShown() and overlay.instance then
		map = string.format("map open on floor %s (%s)", tostring(overlay.floor), tostring(overlay.instance.key))
	elseif WorldMapFrame and WorldMapFrame:IsShown() then
		map = "map open, no dungeon on it"
	end
	Add(string.format("test: %s; panel %s; dungeon %s; %s", FT:On() and "on" or "off",
		self:IsShown() and "shown" or "hidden", instance and instance.key or "none", map))
	Add(TR:DebugText())
	if instance then
		local down, total = FT:Count(instance)
		local marks, defeated, standing, real = FT:Marks(instance) or {}, {}, {}, {}
		for _, boss in ipairs(FT.Bosses(instance)) do
			local key = D.BossKey(boss)
			if D:Killed(instance, boss) then
				defeated[#defeated + 1] = boss.name .. (marks[key] == true and " (test)" or " (real)")
			end
			if marks[key] == false then standing[#standing + 1] = boss.name end
			if D:KilledReally(instance, boss) then real[#real + 1] = boss.name end
		end
		local function List(list) return #list > 0 and table.concat(list, ", ") or "none" end
		Add(string.format("marks %s: defeated %d/%d: %s; stood up: %s; real kills: %s", instance.key, down, total,
			List(defeated), List(standing), List(real)))
		local found = {}
		for key in pairs(FT:FoundKeys() or {}) do found[#found + 1] = key end
		table.sort(found)
		Add(string.format("Adventure Mode %s; found (test): %s; found (real) %s; rumor %s",
			ns.Style:Adventure() and "on" or "off", List(found), Yes(D:KnowsReally("instance", instance)),
			Yes(D:Rumour(instance))))
		local floor = overlay and overlay:IsShown() and overlay.instance == instance and overlay.floor or nil
		Add(string.format("fog: %s%s; has fog %s; cleared %s%s", Fog:On() and "on" or "off",
			ns.Style:Adventure() and " (Adventure Mode)" or "", Yes(Fog:Has(instance)), Yes(Fog:Cleared(instance)),
			floor and string.format("; floor %d cleared %s", floor, Yes(Fog:FloorCleared(instance, floor))) or ""))
	end
	local real, last = ns.Run:Current(), ns.Run:Last()
	Add(string.format("real run: inside %s; run %s; last run %s; wing wait %s", tostring(ns.Run:Inside()),
		real and tostring(real.key) or "none", last and last ~= real and tostring(last.key) or "none",
		tostring(ns.Run:WaitingForWing())))
	local inside = ns.RunTracker.inside
	Add(string.format("combat %s; inside the quest tracker %s; run block %s, %s", Yes(InCombatLockdown()),
		inside and inside:On() and "on" or "off", ns.Run:Option("on") and "on" or "off",
		ns.RunTracker.block and ns.RunTracker.block:IsShown() and "shown" or "hidden"))
	for _, text in ipairs(lines) do ns.Print(text) end
	return lines
end

function TestPanel:Slash(rest)
	local word = strtrim(rest or ""):lower():match("^(%S*)")
	if word == "" then
		self:Open()
	elseif word == "off" then
		if not self:End() and not ns.FogTest:On() then ns.Print(L.TEST_USAGE) end
	elseif word == "debug" then
		self:Debug()
	else
		ns.Print(L.TEST_USAGE)
	end
end

-- Drawn again when what it shows changes: the test's kills and finds (and the pretend run, after them: a kill at a
-- wing's door may have named another wing, FollowRun), a run's change (real or pretend: a real dungeon entered grays
-- "Pretend I'm inside"), the style (Adventure Mode on or off).
ns.FogTest:OnChange(function()
	TestPanel:FollowRun()
	TestPanel:Redraw()
end)
ns.Run:OnChange(function() TestPanel:Redraw() end)
ns.Style:OnChange(function() TestPanel:Redraw() end)
