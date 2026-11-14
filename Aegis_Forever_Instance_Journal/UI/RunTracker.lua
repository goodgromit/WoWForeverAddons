local _, ns = ...
local L = ns.L

--[[
	The run block: the dungeon the player is in, as the game's own objective tracker would show a run, beside it.

	Top to bottom: the dungeon's name in a header like the tracker's own sections' ("Quests", "Achievements": their
	bar with its thin line and their own collapse button; the owner's call, 2026-11-12, after 0.39.20's "All
	Objectives" one), so the block reads as one more section of the tracker; the keystone timer's gold
	frame (ChallengeMode-Timer), with one circle per boss along its top (the same round faces as the dungeon map's
	boss pins, crossed out with the map's own defeated mark: UI/DungeonMap.lua's BuildFace), the run's time and
	the bosses down out of those counted; under it a bar that fills one step per boss killed (it is not a timer);
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
	freely"). Either way it keeps the tracker's own space between its sections from it. It follows Edit Mode moves
	through its anchor. Clamped to the screen. The one exception, off by default: the experiment of placing it inside
	the tracker, under its "All Objectives" (UI/RunTrackerInside.lua, which says what it hands the tracker).

	Its gold art (the header's bar and button, the keystone frame and its rings) takes the tint of the tracker's own
	section headers, so a dark-mode UI that darkens the game's tracker darkens the block with it; "Dark mode" darkens
	it without one (RunTracker:Paint).

	Its clock ticks once a second, only while the block shows and is not collapsed.
]]

local RunTracker = {}
ns.RunTracker = RunTracker
local Run = ns.Run

-- The client's art (its atlas tables, read 2026-11-11 and 2026-11-12). The header's: a section's of the tracker, as
-- Blizzard_ObjectiveTrackerModule.xml draws "Quests" (ObjectiveTrackerModuleHeaderTemplate, its MinimizeButton's
-- template ObjectiveTrackerModuleMinimizeButtonTemplate, and ObjectiveTrackerModuleHeaderMixin:SetCollapsed swapping
-- the secondary collapse and expand).
local ART = {
	header = "ui-questtracker-secondary-objective-header",
	collapse = "ui-questtrackerbutton-secondary-collapse",
	collapsePressed = "ui-questtrackerbutton-secondary-collapse-pressed",
	expand = "ui-questtrackerbutton-secondary-expand",
	expandPressed = "ui-questtrackerbutton-secondary-expand-pressed",
	highlight = "ui-questtrackerbutton-yellow-highlight",
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
	Sizes, in UI units: the client's tracker and keystone block (Blizzard_ObjectiveTracker XML: a section's header
	260 x 26 with its text at 7, 200 wide, one line, shrunk to fit down to a 12 line height (headerMinLine), and its
	16 x 16 button at the right +1; the first thing under it 10 under the header (the module's fromHeaderOffsetY:
	36 down); 10 between sections (its moduleSpacing) and its background 10 under the last one (bottomModulePadding);
	the keystone frame 251 x 87, its bar
	207 x 13 at the bottom +10 over the TimerBG at +13; the line icon 16 x 16 at -10, 2), and the mock-up the owner
	approved for the rest: the circles from 16 down, centred between the frame's inner edges (28 to 223), 22 across
	at most, a second row above 8 bosses; boss lines 22 apart, number lines 17. The header's art is 30 high on its
	26: 2 over its top (headerOver).
]]
local SIZE = {
	width = 260, header = 26, headerText = 200, headerMinLine = 12, button = 16, buttonHeight = 16, buttonX = 1,
	contentTop = 36, sectionGap = 10, slicePadding = 10, headerOver = 2,
	frameWidth = 251, frameHeight = 87, innerLeft = 28, innerWidth = 195,
	ringTop = 16, ringMax = 22, ringGap = 4, ringGapTight = 3, rowGap = 4, oneRow = 8,
	barWidth = 207, barHeight = 13, barBottom = 10, barBackBottom = 13,
	clockGap = 5, countDown = 5, skull = 15, check = 16,
	afterFrame = 12, lineX = 32, iconX = -10, iconY = 2, icon = 16,
	bossPitch = 22, completePitch = 20, numberPitch = 17, numbersGap = 4, lineFont = 12,
	fallbackX = -110, fallbackY = -275,
}
RunTracker.SIZE = SIZE

-- The tracker's colours (OBJECTIVE_TRACKER_COLOR: Normal 0.8, Complete 0.6) and the header's gold.
local NORMAL, COMPLETE, GOLD, WHITE = { 0.8, 0.8, 0.8 }, { 0.6, 0.6, 0.6 }, { 1, 0.82, 0 }, { 1, 1, 1 }
local DEFEATED_COLOR, OPEN_COLOR = { 0.1, 1, 0.1 }, { 0.8, 0.8, 0.8 }
local NORMAL_CODE, WHITE_CODE = "|cffcccccc", "|cffffffff"

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
			local text = parts[1].name
			for index = 2, #parts do text = string.format(L.RUN_PARTS, text, parts[index].name) end
			tip:AddLine(text, 1, 1, 1, true)
		end
		if shown.dead then
			tip:AddLine(L.RUN_DEFEATED, DEFEATED_COLOR[1], DEFEATED_COLOR[2], DEFEATED_COLOR[3])
		else
			tip:AddLine(L.RUN_NOT_DEFEATED, OPEN_COLOR[1], OPEN_COLOR[2], OPEN_COLOR[3])
		end
	end)
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
		if Run:Option("free") then tip:AddLine(L.RUN_DRAG, 0.5, 0.8, 1, true) end
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

-- The gold frame at any height: as it is for one row of circles; for two, its top and bottom kept and a middle
-- strip stretched (the atlas's own texture coordinates, cut in three).
local function FrameArt(frame, height)
	local art = frame.Art
	local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(ART.frame)
	local file = info and (info.file or info.filename)
	if height == SIZE.frameHeight or not (file and info.leftTexCoord) then
		art[1]:SetAtlas(ART.frame)
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
	block:SetSize(SIZE.width, SIZE.header)
	block:SetFrameStrata("LOW")
	block:SetClampedToScreen(true)
	block:SetMovable(true)
	block:EnableMouse(false)
	block:Hide()
	self.block = block

	local header = CreateFrame("Frame", nil, block)
	header:SetSize(SIZE.width, SIZE.header)
	header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton")
	header.Background = header:CreateTexture(nil, "BACKGROUND")
	header.Background:SetAtlas(ART.header, true)
	header.Background:SetPoint("CENTER", header, "CENTER", 0, 0)
	header.Text = header:CreateFontString(nil, "ARTWORK")
	UseFont(header.Text, "ObjectiveTrackerHeaderFont", "GameFontNormal")
	header.Text:SetJustifyH("LEFT")
	header.Text:SetWidth(SIZE.headerText)
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
	button:SetSize(SIZE.button, SIZE.buttonHeight)
	button:SetPoint("RIGHT", header, "RIGHT", SIZE.buttonX, 0)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints(button)
	button.Icon:SetAtlas(ART.collapse)
	button.Highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.Highlight:SetAllPoints(button)
	button.Highlight:SetAtlas(ART.highlight)
	button.Highlight:SetBlendMode("ADD")
	button:SetScript("OnMouseDown", function(self) self.Icon:SetAtlas(self.pressedAtlas) end)
	button:SetScript("OnMouseUp", function(self) self.Icon:SetAtlas(self.atlas) end)
	button:SetScript("OnClick", function()
		-- The click a section header's makes (ObjectiveTrackerModuleHeaderMixin:OnToggle).
		if PlaySound and SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		RunTracker:HeaderButton()
	end)
	button.atlas, button.pressedAtlas = ART.collapse, ART.collapsePressed
	header.Button = button

	local frame = CreateFrame("Frame", nil, block)
	frame:SetSize(SIZE.frameWidth, SIZE.frameHeight)
	frame:SetPoint("TOPLEFT", block, "TOPLEFT", 0, -SIZE.contentTop)
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
	block.Frame = frame

	block.Complete = block:CreateFontString(nil, "OVERLAY")
	UseFont(block.Complete, "ObjectiveTrackerLineFont", "GameFontHighlight")
	block.Complete:SetJustifyH("LEFT")
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
	return block
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
	the map's (DungeonMap:IsDefeated) inside, and the run's own record of them for a run left behind.
]]
function RunTracker:View()
	local inside = Run:Inside() and Run:Current() or nil
	local run = inside or (self.showingLast and Run:Last()) or nil
	if not run then return nil end
	local view = { run = run, frozen = inside == nil }
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
	view.instance, view.placed = instance, placed and true or false
	view.title = placed and instance.name or ClientInstanceName() or (instance and instance.name) or ""
	local entries, others = {}, {}
	if placed then
		for _, entry in ipairs(Run.Bosses(instance)) do
			entries[#entries + 1] = { entry = entry, name = Run.EntryName(entry), boss = entry.boss, dead = Run.EntryDead(entry, dead) }
		end
		for _, boss in ipairs(Run.Others(instance)) do
			if dead(boss) then others[#others + 1] = { name = boss.name, boss = boss, dead = true } end
		end
	end
	view.entries, view.others = entries, others
	view.down = 0
	for _, shown in ipairs(entries) do
		if shown.dead then view.down = view.down + 1 end
	end
	view.total = #entries
	-- Done in the part its final boss died in: another part walked into afterwards (Stratholme's other half, Upper
	-- Blackrock Spire after Lower) is not, its bosses still 0/1. Whether its clock should run on there: the owner's.
	view.finished = run.finished == true and not (placed and run.finishedWing and run.finishedWing ~= instance.key)
	view.seconds = Run.Elapsed(run)
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
	The header's name shrunk to fit its 208 on one line rather than cut off with "...", as the client's container
	header does (its text's AutoScalingFontStringMixin: ScaleTextToFit, minLineHeight 12): the text scale from the
	name's width, then a line-height step smaller while it is still cut off, never under 12. Unlike the mixin, the
	line height is read again whenever the name or the font's size (the Edit Mode Text Size) changes, not kept from
	the first time. A name still too long at 12 ends in "..." as the client's would. Returns the scale.
]]
function RunTracker.FitHeaderText(text, title)
	if not (text.SetTextScale and text.GetUnboundedStringWidth and text.GetLineHeight) then return 1 end
	local _, fontHeight = text:GetFont()
	if text.fitTitle == title and text.fitFont == fontHeight and text.fitScale then return text.fitScale end
	text:SetTextScale(1)
	local base = math.floor((text:GetLineHeight() or 0) + 0.5)
	local width = text:GetUnboundedStringWidth() or 0
	local scale = 1
	if base > SIZE.headerMinLine and width > SIZE.headerText then
		local try = math.max(SIZE.headerMinLine, math.floor(SIZE.headerText / width * base + 0.5))
		while try >= SIZE.headerMinLine do
			scale = try / base
			text:SetTextScale(scale)
			if not (text.IsTruncated and text:IsTruncated()) then break end
			try = try - 1
		end
	end
	text.fitTitle, text.fitFont, text.fitScale = title, fontHeight, scale
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

-- open: laid out expanded whatever the collapse (to know its full height, RunTracker:Refresh).
function RunTracker:Layout(view, open)
	local block = self.block
	local frame = block.Frame
	block.Header.Text:SetText(view.title)
	RunTracker.FitHeaderText(block.Header.Text, view.title)
	local collapsed = not open and self:Collapsed(view)
	local button = block.Header.Button
	button.atlas = collapsed and ART.expand or ART.collapse
	button.pressedAtlas = collapsed and ART.expandPressed or ART.collapsePressed
	button.Icon:SetAtlas(button.atlas)
	frame:SetShown(not collapsed)
	if collapsed then
		for _, circle in ipairs(self.circles) do circle:Hide() end
		for _, line in ipairs(self.lines) do line.Icon:Hide(); line.Text:Hide() end
		block.Complete:Hide()
		for _, text in ipairs(block.Numbers) do text:Hide() end
		block:SetHeight(SIZE.header)
		self.height = SIZE.header
		return SIZE.header
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
		-- The portrait drawn again only when the boss or his state changes.
		if not (circle.shown and circle.shown.boss == shown.boss and circle.shown.dead == shown.dead) then
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
	SetColor(frame.Clock, view.finished and GOLD or WHITE)
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
	local y = SIZE.contentTop + frameHeight + SIZE.afterFrame
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
	self.height, self.openHeight = y, y
	-- The tallest it has been laid out open for this run: where it sits goes by that (RunTracker:Place), so a
	-- collapse, or a kill that shortens a long dungeon's lines, does not move it from under the tracker to above it.
	if self.fullFor ~= view.run then self.fullFor, self.fullHeight = view.run, y end
	self.fullHeight = math.max(self.fullHeight or 0, y)
	return y
end

-- A circle's face: the boss's portrait, crossed out once he is dead.
function RunTracker.ShowCircle(circle, shown)
	ns.DungeonMap.ShowFace(circle, shown.boss, shown.dead)
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
	self:Paint()
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
	local spot = ns.charDB and ns.charDB.runSpot
	if Run:Option("free") and spot then
		block:SetPoint(spot[1], UIParent, spot[2], spot[3], spot[4])
		self.placement = "free"
		return
	end
	local tracker = ObjectiveTrackerFrame
	local top = tracker and tracker.GetTop and tracker:GetTop()
	if not top then
		-- The tracker has no place yet (nothing tracked since login): its default spot.
		block:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", SIZE.fallbackX, SIZE.fallbackY)
		self.placement = "fallback"
		return
	end
	-- The tracker's own space between its sections (its moduleSpacing), between it and the block.
	local spacing = TrackerNumber(tracker, "moduleSpacing", SIZE.sectionGap)
	-- The side goes by the block open at its tallest this run, never by a collapsed header's 26; its header's art
	-- reaches 2 over its top, kept on the screen.
	local need = (self.view and self.fullFor == self.view.run and self.fullHeight) or self.height or SIZE.header
	if not tracker:IsShown() then
		-- Nothing tracked, so no tracker on screen. With the experiment on (the tracker too short for the block inside
		-- it: UI/RunTrackerInside.lua), never on the spot its header comes back to: above it where there is room, else
		-- under its frame, which its sections never pass. Otherwise its place, as 0.39.20.
		if self.inside and self.inside.active then
			if RoomAbove(tracker) >= need + spacing + SIZE.headerOver then
				block:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, spacing + (self.openHeight or need))
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
	if RoomAbove(tracker) >= need + spacing + SIZE.headerOver then
		-- Held by its top, its open bottom the spacing over the tracker: collapsed, the header and its button stay
		-- where they were (under the mouse), as the tracker's own header does, the room under it left empty.
		block:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, spacing + (self.openHeight or need))
		self.placement = "above"
		return
	end
	-- Under what the tracker shows: its contents' edge (the NineSlice it moves to its last module, bottomModulePadding
	-- under it, so the block a section's space under that module, but never so close that the header's art would
	-- reach over the background's edge), its header alone while it is collapsed, the controller prompts' footer
	-- while that shows.
	local under, placement = tracker.NineSlice, "below"
	local gap = math.max(SIZE.headerOver, spacing - TrackerNumber(tracker, "bottomModulePadding", SIZE.slicePadding))
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
	SetDesaturated), never the journal's. So the block's gold art takes the tint of the tracker's own section headers,
	only read (GetVertexColor, IsDesaturated): the "Quests" header first (QuestObjectiveTracker.Header, the client's
	ObjectiveTrackerModuleHeaderTemplate, Blizzard_ObjectiveTrackerModule.xml: its Background, the bar with its line,
	and its MinimizeButton's NormalTexture), then the other sections' headers (the tracker's modules), then "All
	Objectives" (ObjectiveTrackerFrame.Header, ObjectiveTrackerContainerHeaderTemplate): the first tinted bar, and the
	first tinted button, of those. The bar's tint goes on the block's bar and line (its header's Background), its
	alpha too, so the block's header looks as the Quests header does; the button's on the block's button. The keystone
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

-- The tint of the tracker's section headers' bar and button (nil, nil where none is tinted). Only read.
function RunTracker.TrackerTint()
	local quests, tracker = QuestObjectiveTracker, ObjectiveTrackerFrame
	local bar, button
	if type(quests) == "table" then bar, button = ReadHeader(quests.Header, bar, button) end
	if type(tracker) ~= "table" then return bar, button end
	local modules = tracker.modules
	if type(modules) == "table" then
		for _, module in ipairs(modules) do
			if bar and button then break end
			if type(module) == "table" and module ~= quests then bar, button = ReadHeader(module.Header, bar, button) end
		end
	end
	return ReadHeader(tracker.Header, bar, button)
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
	local bar, button = RunTracker.TrackerTint()
	self.tintSource = bar and "the tracker's" or "none"
	-- "Dark mode" only where the tracker's bar has no tint: a tinted tracker keeps its own look on bar and button.
	if Run:Option("darkMode") and not bar then
		self.tintSource = "dark mode"
		bar, button = DARK, button or DARK
	end
	self.tint = bar
	Paint(block.Header.Background, bar)
	Paint(block.Header.Button.Icon, button)
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
	if self.dragging or not (block and Run:Option("free")) then return end
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

-- Dropped: the spot kept for the character, where it was let go. Its edges and SetPoint's offsets are both in the
-- block's own units (it has no scale of its own: UIParent's), from UIParent's bottom left, so at any UI scale.
function RunTracker:KeepSpot()
	if not (Run:Option("free") and ns.charDB) then return end
	local left, top = self.block:GetLeft(), self.block:GetTop()
	if not (left and top) then return end
	ns.charDB.runSpot = { "TOPLEFT", "BOTTOMLEFT", left, top }
end

------------------------------------------------------------------------------------------
-- Showing, ticking, collapsing
------------------------------------------------------------------------------------------

-- Collapsed by its header's button (kept for the character). Not for the last run shown outside (/ij run): that one
-- shows whole, and its button puts it away.
function RunTracker:Collapsed(view)
	if view and view.frozen then return false end
	return ns.charDB ~= nil and ns.charDB.runCollapsed == true
end

function RunTracker:HeaderButton()
	if self.view and self.view.frozen then
		self.showingLast = false
	elseif ns.charDB then
		ns.charDB.runCollapsed = not self:Collapsed() or nil
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
	-- Inside, the run going on: the last run shown outside (/ij run) is put away, so leaving hides the block again.
	if Run:Inside() then self.showingLast = false end
	local view = Run:Option("on") and self:View() or nil
	if view and not view.frozen and view.run.hidden then view = nil end
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
	if self:Collapsed(view) and self.fullFor ~= view.run then self:Layout(view, true) end
	self:Layout(view)
	self:Place()
	self.block:Show()
	if not self.listening then ns.RegisterEvents(events, unpack(SHOWN_EVENTS)) end
	self.listening = true
	if self:Collapsed(view) then
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

-- Where the block is, and its gold art's tint and where it comes from (for the owner's in-game check of dark mode).
function RunTracker:PlacementText()
	local tint = self.tint
	return string.format("placement: %s; tint: %s%s", tostring(self.placement), tostring(self.tintSource or "none"),
		tint and string.format(" (%.2f, %.2f, %.2f%s)", tint[1], tint[2], tint[3], tint.desaturated and ", gray" or "") or "")
end

function RunTracker:Slash(rest)
	local word = strtrim(rest or ""):lower():match("^(%S*)")
	if word == "" then
		local run = Run:Inside() and Run:Current()
		if run then
			run.hidden = not run.hidden or nil
			if run.hidden then ns.Print(L.RUN_HIDDEN) end
		elseif Run:Last() then
			self.showingLast = not self.showingLast
		else
			ns.Print(L.RUN_NONE)
		end
		if not Run:Option("on") then ns.Print(L.RUN_IS_OFF) end
		self:Refresh()
	elseif word == "new" then
		ns.Print(Run:NewRun() and L.RUN_NEW or L.RUN_NOT_INSIDE)
	elseif word == "unlock" or word == "lock" then
		Run:SetOption("free", word == "unlock")
		NotifyOption("AEGIS_JOURNAL_RUN_FREE")
		ns.Print(word == "unlock" and L.RUN_FREE_ON or L.RUN_FREE_OFF)
	elseif word == "reset" then
		if ns.charDB then ns.charDB.runSpot = nil end
		Run:SetOption("free", false)
		NotifyOption("AEGIS_JOURNAL_RUN_FREE")
		ns.Print(L.RUN_FREE_OFF)
	elseif word == "debug" then
		Run:Debug(self:PlacementText(), self.inside and self.inside:DebugText())
	else
		ns.Print(L.RUN_USAGE)
	end
end
