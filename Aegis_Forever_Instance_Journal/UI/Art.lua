local _, ns = ...

--[[
	Pieces of the journal's texture sheet, at the sizes and coordinates Blizzard's own
	Blizzard_EncounterJournal.xml declares them. That file does not load on Forever, so its
	virtual textures are not there to inherit; these are the same cuts of the same files.
]]

local SHEET = "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
local TILE = "Interface\\EncounterJournal\\UI-EncounterJournalTextures_Tile"

-- name = { width, height, left, right, top, bottom [, file] }; the file defaults to SHEET.
local PIECES = {
	-- The paper strips of the abilities tree (EncounterInfoTemplate), collapsed and expanded.
	["PaperHeader-UnSelectUp-Left"] = { 64, 29, 0.84960938, 0.97460938, 0.49023438, 0.51855469 },
	["PaperHeader-UnSelectUp-Right"] = { 64, 29, 0.72656250, 0.85156250, 0.52441406, 0.55273438 },
	["PaperHeader-UnSelectUp-Mid"] = { 64, 29, 0, 1, 0.34375000, 0.40039063, TILE },
	["PaperHeader-UnSelectDown-Left"] = { 64, 29, 0.47460938, 0.59960938, 0.49316406, 0.52148438 },
	["PaperHeader-UnSelectDown-Right"] = { 64, 29, 0.60351563, 0.72851563, 0.49316406, 0.52148438 },
	["PaperHeader-UnSelectDown-Mid"] = { 64, 29, 0, 1, 0.28320313, 0.33984375, TILE },
	["PaperHeader-SelectUp-Left"] = { 64, 29, 0.81445313, 0.93945313, 0.39453125, 0.42285156 },
	["PaperHeader-SelectUp-Right"] = { 64, 29, 0.34570313, 0.47070313, 0.49316406, 0.52148438 },
	["PaperHeader-SelectUp-Mid"] = { 64, 29, 0, 1, 0.22265625, 0.27929688, TILE },
	["PaperHeader-SelectDown-Left"] = { 64, 29, 0.64062500, 0.76562500, 0.21386719, 0.24218750 },
	["PaperHeader-SelectDown-Right"] = { 64, 29, 0.76953125, 0.89453125, 0.21386719, 0.24218750 },
	["PaperHeader-SelectDown-Mid"] = { 64, 29, 0, 1, 0.40429688, 0.46093750, TILE },
	["PaperHeader-Highlight-Left"] = { 64, 29, 0.74218750, 0.86718750, 0.15820313, 0.18652344 },
	["PaperHeader-Highlight-Right"] = { 64, 29, 0.87109375, 0.99609375, 0.15820313, 0.18652344 },
	["PaperHeader-Highlight-Mid"] = { 64, 29, 0, 1, 0.46484375, 0.52148438, TILE },
	["AbilityTextBG"] = { 256, 80, 0.00195313, 0.50195313, 0.02246094, 0.10058594 },
	["AbilityTextBottomBorder"] = { 243, 9, 0.04492188, 0.51953125, 0.00097656, 0.00976563 },

	["BossButton-Up"] = { 325, 55, 0.00195313, 0.63671875, 0.21386719, 0.26757813 },
	["BossButton-Down"] = { 325, 55, 0.00195313, 0.63671875, 0.10253906, 0.15625000 },
	["BossButton-Highlight"] = { 325, 55, 0.00195313, 0.63671875, 0.15820313, 0.21191406 },
	["BossModelButton"] = { 64, 61, 0.50585938, 0.63085938, 0.02246094, 0.08203125 },
	["DungeonButton-Up"] = { 174, 96, 0.00195313, 0.34179688, 0.42871094, 0.52246094 },
	["DungeonButton-Down"] = { 174, 96, 0.00195313, 0.34179688, 0.33300781, 0.42675781 },
	["DungeonButton-Highlight"] = { 174, 96, 0.34570313, 0.68554688, 0.33300781, 0.42675781 },
	["DungeonNameBg"] = { 256, 64, 0.34570313, 0.84570313, 0.42871094, 0.49121094 },
	["Tab-Highlight"] = { 63, 57, 0.00195313, 0.12500000, 0.90332031, 0.95898438 },
	["Tab-Selected"] = { 63, 57, 0.12890625, 0.25195313, 0.90332031, 0.95898438 },
	["Tab-UnSelected"] = { 63, 57, 0.25585938, 0.37890625, 0.90332031, 0.95898438 },
	["Tab-BossIcon-Selected"] = { 48, 43, 0.90234375, 0.99609375, 0.26953125, 0.31152344 },
	["Tab-BossIcon-UnSelected"] = { 48, 43, 0.85546875, 0.94921875, 0.52441406, 0.56640625 },
	["Tab-LootIcon-Selected"] = { 48, 43, 0.63281250, 0.72656250, 0.61816406, 0.66015625 },
	["Tab-LootIcon-UnSelected"] = { 48, 43, 0.73046875, 0.82421875, 0.61816406, 0.66015625 },
	["Tab-AbilitiesIcon-Selected"] = { 48, 43, 0.806640625, 0.8984375, 0.70703125, 0.748046875 },
	["Tab-AbilitiesIcon-UnSelected"] = { 48, 43, 0.904296875, 0.99609375, 0.70703125, 0.748046875 },
	["Tab-ModelIcon-Selected"] = { 48, 43, 0.8046875, 0.900390625, 0.662109375, 0.705078125 },
	["Tab-ModelIcon-UnSelected"] = { 48, 43, 0.90234375, 1, 0.662109375, 0.705078125 },
	-- The model page (the encounter frame's ModelFrame): its backdrop, paper frame and name shadow.
	["BossNameShadow"] = { 395, 63, 0.00195313, 0.77343750, 0.26953125, 0.33105469 },
	["LeftPageHeader"] = { 386, 39, 0, 0.755859375, 0.9599609375, 1 },
	["RightPageHeader"] = { 386, 39, 0.755859375, 0, 0.9599609375, 1 },
	["Header-Overview"] = { 327, 30, 0.359375, 0.99609375, 0.8525390625, 0.880859375 },
	["PaperOverlay-Bullet"] = { 13, 13, 0.974609375, 1.0, 0.7509765625, 0.763671875 },
	["ShowMapBG"] = { 171, 50, 0.00195313, 0.33593750, 0.85253906, 0.90136719 },
	["LootFrame"] = { 321, 45, 0.00195313, 0.62890625, 0.61816406, 0.66210938 },
	["FilterBar"] = { 320, 28, 0.00195313, 0.62695313, 0.58886719, 0.61621094 },
	["DungeonLootFrame"] = { 369, 64, 0.00195313, 0.72265625, 0.52441406, 0.58691406 },
}

-- Gives a texture one of the pieces. keepSize leaves its size alone, as for a button's own textures.
function ns.Art(texture, name, keepSize)
	local piece = PIECES[name]
	if not piece then error("unknown journal art: " .. tostring(name), 2) end
	texture:SetTexture(piece[7] or SHEET)
	texture:SetTexCoord(piece[3], piece[4], piece[5], piece[6])
	if not keepSize then texture:SetSize(piece[1], piece[2]) end
	return texture
end

function ns.ArtSize(name)
	local piece = PIECES[name]
	return piece[1], piece[2]
end

-- A piece's texture coordinates: left, right, top, bottom.
function ns.ArtCoords(name)
	local piece = PIECES[name]
	return piece[3], piece[4], piece[5], piece[6]
end

-- Normal, pushed, highlight (added) and disabled textures for a button, any of which may be nil.
function ns.SetButtonArt(button, normal, pushed, highlight, disabled)
	if normal then
		button:SetNormalTexture(SHEET)
		ns.Art(button:GetNormalTexture(), normal, true)
	end
	if pushed then
		button:SetPushedTexture(SHEET)
		ns.Art(button:GetPushedTexture(), pushed, true)
	end
	if highlight then
		button:SetHighlightTexture(SHEET, "ADD")
		ns.Art(button:GetHighlightTexture(), highlight, true)
	end
	if disabled then
		button:SetDisabledTexture(SHEET)
		ns.Art(button:GetDisabledTexture(), disabled, true)
	end
end

-- A dungeon's picture in the tint its data asks for (artTint: first in grey, then its colour), else as drawn:
-- the Scarlet Monastery's Graveyard grey beside the Library, Dire Maul's wings each a colour of their own, where
-- they share a picture (the owner's call, 2026-11-09). Every texture that shows a dungeon's picture goes through
-- it, so one used next for another dungeon, or anything else, shows that as drawn (instance nil).
function ns.TintInstanceArt(texture, instance)
	local tint = instance and instance.artTint
	if texture.SetDesaturated then texture:SetDesaturated(tint and tint.desaturate and true or false) end
	local color = tint and tint.color
	if texture.SetVertexColor then
		texture:SetVertexColor(color and color[1] or 1, color and color[2] or 1, color and color[3] or 1)
	end
end

-- The parchment text colour Blizzard's journal uses for body text on its pages.
ns.PARCHMENT_TEXT_COLOR = { 0.25, 0.1484375, 0.02 }
-- The page-header colour for instance and boss names.
ns.PAGE_TITLE_COLOR = { 0.902, 0.788, 0.671 }
-- The label on a section bar (Header-Overview), such as a boss page's "Overview".
ns.HEADER_LABEL_COLOR = { 0.929, 0.788, 0.620 }

--[[
	The journal's own menus (ns.Menus), drawn as the game's: Blizzard_Menu's Mainline style (the dropdown's
	"common-dropdown-textholder" box and arrow, the menu's "common-dropdown-bg" panel, its ticks, highlight,
	divider and submenu arrow, the same fonts and spacing), on frames of the journal's alone. The game's menu
	system keeps one pool of frames for every menu: one the journal built there ran the journal's code on
	those frames, and the unit menus that took them next were blocked (raid icons, the interact distance
	check: the owner's taint log of 2026-11-08, "Execution tainted by Aegis_Forever_Instance_Journal while
	reading field attachments"). So the journal never opens the game's menus, nor adds to them.

	A menu is still written with the game's calls on its description: CreateTitle, CreateDivider,
	CreateButton (what is added to a button is its submenu), CreateRadio and CreateCheckbox. The owner keeps
	the menu's record as `_menu`: its entries in order (items), and its title, radios, checkboxes and buttons.
]]
local Menus = {}
ns.Menus = Menus

local ROW_HEIGHT, DIVIDER_HEIGHT = 20, 13
local INSET_LEFT, INSET_TOP, INSET_RIGHT, INSET_BOTTOM = 8, 8, 8, 15 -- MenuStyle1Mixin:GetInset()
local EXTRA_WIDTH = 20 -- MenuStyle1Mixin:GetChildExtentPadding()
local ARROW_WIDTH = 16
local USE_ATLAS_SIZE = true

local Description = {}
Description.__index = Description

local function NewRecord(text)
	return setmetatable({ text = text, items = {}, radios = {}, checkboxes = {}, buttons = {} }, Description)
end

local function Add(record, entry, list)
	record.items[#record.items + 1] = entry
	if list then list[#list + 1] = entry end
	return entry
end

function Description:CreateTitle(text)
	self.title = self.title or text
	return Add(self, { kind = "title", text = text })
end

function Description:CreateDivider()
	return Add(self, { kind = "divider" })
end

function Description:CreateRadio(text, isSelected, setSelected, data)
	return Add(self, { kind = "radio", text = text, isSelected = isSelected, setSelected = setSelected, data = data },
		self.radios)
end

function Description:CreateCheckbox(text, isSelected, setSelected, data)
	return Add(self, { kind = "checkbox", text = text, isSelected = isSelected, setSelected = setSelected, data = data },
		self.checkboxes)
end

-- A button: clicked, its callback; what is added to it makes its submenu.
function Description:CreateButton(text, onClick, data)
	local entry = NewRecord(text)
	entry.kind, entry.onClick, entry.data = "button", onClick, data
	return Add(self, entry, self.buttons)
end

local function IsSelected(entry)
	if not entry.isSelected then return false end
	local ok, selected = pcall(entry.isSelected, entry.data)
	return ok and selected and true or false
end

-- The radios chosen, in the menu and its submenus, as the game's dropdowns name them.
local function Chosen(record, out)
	for _, entry in ipairs(record.items) do
		if entry.kind == "radio" and IsSelected(entry) then
			out[#out + 1] = entry
		elseif entry.kind == "button" then
			Chosen(entry, out)
		end
	end
	return out
end

-- A menu built afresh from its generator: the owner's own (kept as owner._menu), or one given for a context
-- menu (kept by the open menu alone, as its owner may be a map pin).
local function Generate(owner, generator)
	local own = generator == nil
	generator = generator or owner._menuGenerator
	if not generator then return nil end
	local record = NewRecord()
	generator(owner, record)
	if own then owner._menu = record end
	return record
end

local function Sound(on)
	if PlaySound and SOUNDKIT then
		PlaySound(on and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
end

------------------------------------------------------------------------------------------
-- The menu's panels: the menu, and a submenu beside it
------------------------------------------------------------------------------------------

local panels = {}
Menus.panels = panels -- (the menu, then its submenu: read by the tests)
local current -- { owner, record, generator (a context menu's) } while a menu is open
local Fill, OpenSubmenu
local watcher = CreateFrame("Frame")

local function ClosePanels(fromLevel)
	for level = fromLevel, #panels do
		local panel = panels[level]
		panel.record = nil
		panel:Hide()
	end
end

function Menus:Close()
	local was = current
	current = nil
	ClosePanels(1)
	pcall(watcher.UnregisterEvent, watcher, "GLOBAL_MOUSE_DOWN")
	if was and was.owner and was.owner.MenuClosed then was.owner:MenuClosed() end
end

function Menus:IsOpen(owner)
	return current ~= nil and (owner == nil or current.owner == owner)
end

local function Refresh()
	if not current then return end
	current.record = Generate(current.owner, current.generator) or current.record
	Fill(panels[1], current.record, 1)
	if current.owner.UpdateText then current.owner:UpdateText() end
end

local function RowEnter(row)
	local entry = row.entry
	if not entry then return end
	if entry.kind ~= "title" and entry.kind ~= "divider" then row.Highlight:Show() end
	local level = row.level
	if entry.kind == "button" and #entry.items > 0 then
		OpenSubmenu(row, entry, level + 1)
	elseif panels[level + 1] and panels[level + 1]:IsShown() then
		ClosePanels(level + 1)
	end
end

local function RowLeave(row)
	row.Highlight:Hide()
end

local function RowClick(row)
	local entry = row.entry
	if not (entry and current) then return end
	if entry.kind == "radio" then
		Sound(true)
		if entry.setSelected then entry.setSelected(entry.data) end
		local owner = current.owner
		Menus:Close()
		if owner.UpdateText then owner:UpdateText() end
	elseif entry.kind == "checkbox" then
		Sound(not IsSelected(entry))
		if entry.setSelected then entry.setSelected(entry.data) end
		Refresh()
	elseif entry.kind == "button" and #entry.items == 0 then
		Sound(true)
		local onClick, data = entry.onClick, entry.data
		Menus:Close()
		if onClick then onClick(data) end
	end
end

local function Row(panel, index)
	local row = panel.rows[index]
	if row then return row end
	row = CreateFrame("Button", nil, panel)
	row:SetHeight(ROW_HEIGHT)
	row.Highlight = row:CreateTexture(nil, "BACKGROUND")
	row.Highlight:SetAllPoints()
	row.Highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	row.Highlight:SetBlendMode("ADD")
	row.Highlight:Hide()
	row.Tick = row:CreateTexture(nil, "ARTWORK")
	row.Mark = row:CreateTexture(nil, "OVERLAY")
	row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.Text:SetJustifyH("LEFT")
	row.Text:SetWordWrap(false)
	row.Arrow = row:CreateTexture(nil, "ARTWORK")
	row.Arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
	row.Arrow:SetSize(ARROW_WIDTH, ARROW_WIDTH)
	row.Arrow:SetPoint("RIGHT")
	row.Divider = row:CreateTexture(nil, "ARTWORK")
	row.Divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
	row.Divider:SetPoint("LEFT")
	row.Divider:SetPoint("RIGHT")
	row.Divider:SetHeight(DIVIDER_HEIGHT)
	row:SetScript("OnEnter", RowEnter)
	row:SetScript("OnLeave", RowLeave)
	row:SetScript("OnClick", RowClick)
	panel.rows[index] = row
	return row
end

-- One entry on its row: its tick (radio, checkbox), name, submenu arrow or divider; its width.
local function Show(row, entry)
	row.entry = entry
	row.Highlight:Hide()
	row.Tick:Hide()
	row.Mark:Hide()
	row.Arrow:Hide()
	row.Divider:Hide()
	row.Text:Show()
	row.Text:ClearAllPoints()
	row.Text:SetFontObject(entry.kind == "title" and "GameFontNormal" or "GameFontHighlight")
	row.Text:SetText(entry.text or "")
	row:SetHeight(entry.kind == "divider" and DIVIDER_HEIGHT or ROW_HEIGHT)
	row:EnableMouse(entry.kind ~= "title" and entry.kind ~= "divider")
	if entry.kind == "divider" then
		row.Text:Hide()
		row.Divider:Show()
		return 0
	end
	local left = 0
	if entry.kind == "radio" or entry.kind == "checkbox" then
		local radio = entry.kind == "radio"
		row.Tick:SetAtlas(radio and "common-dropdown-tickradial" or "common-dropdown-ticksquare", USE_ATLAS_SIZE)
		row.Tick:ClearAllPoints()
		row.Tick:SetPoint("LEFT", radio and -3 or 0, 0)
		row.Tick:Show()
		if IsSelected(entry) then
			row.Mark:SetAtlas(radio and "common-dropdown-icon-radialtick-yellow" or "common-dropdown-icon-checkmark-yellow",
				USE_ATLAS_SIZE)
			row.Mark:ClearAllPoints()
			if radio then
				row.Mark:SetPoint("TOPLEFT", row.Tick, "TOPLEFT")
			else
				row.Mark:SetPoint("CENTER", row.Tick, "CENTER", 2, 1)
			end
			row.Mark:Show()
		end
		row.Text:SetPoint("LEFT", row.Tick, "RIGHT", radio and 1 or 7, radio and 0 or 1)
		left = (radio and -3 or 0) + (row.Tick:GetWidth() or 0) + (radio and 1 or 7)
	else
		row.Text:SetPoint("LEFT")
	end
	local width = left + (row.Text:GetStringWidth() or 0)
	if entry.kind == "button" and #entry.items > 0 then
		row.Arrow:Show()
		width = width + ARROW_WIDTH
	end
	return width
end

local function Panel(level)
	local panel = panels[level]
	if panel then return panel end
	panel = CreateFrame("Frame", nil, UIParent)
	panel:SetFrameStrata("FULLSCREEN_DIALOG")
	panel:SetFrameLevel(10 * level)
	panel:SetClampedToScreen(true)
	panel:EnableMouse(true)
	panel.Background = panel:CreateTexture(nil, "BACKGROUND")
	panel.Background:SetAtlas("common-dropdown-bg")
	panel.Background:SetPoint("TOPLEFT", -10, 3)
	panel.Background:SetPoint("BOTTOMRIGHT", 10, -3)
	panel.Background:SetAlpha(0.925)
	panel.level = level
	panel.rows = {}
	panel:Hide()
	panels[level] = panel
	return panel
end

-- A panel laid out for a record: its rows top down, as wide as its widest entry, and at least as wide as
-- the menu's owner when it is the menu itself.
function Fill(panel, record, level)
	panel.record = record
	local widest, height = 0, INSET_TOP
	for index, entry in ipairs(record.items) do
		local row = Row(panel, index)
		row.level = level
		widest = math.max(widest, Show(row, entry))
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", panel, "TOPLEFT", INSET_LEFT, -height)
		row:SetPoint("RIGHT", panel, "RIGHT", -INSET_RIGHT, 0)
		row:Show()
		height = height + row:GetHeight()
	end
	for index = #record.items + 1, #panel.rows do
		panel.rows[index].entry = nil
		panel.rows[index]:Hide()
	end
	local width = widest + EXTRA_WIDTH + INSET_LEFT + INSET_RIGHT
	if level == 1 and current and current.minWidth then width = math.max(width, current.minWidth) end
	panel:SetSize(width, height + INSET_BOTTOM)
end

function OpenSubmenu(row, record, level)
	ClosePanels(level)
	local panel = Panel(level)
	Fill(panel, record, level)
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", row, "TOPRIGHT", INSET_RIGHT + 2, INSET_TOP)
	panel:Show()
end

-- Closed by a click anywhere but on the menu or its owner (whose own click opens or closes it).
watcher:SetScript("OnEvent", function()
	if not current then return end
	if current.owner.IsMouseOver and current.owner:IsMouseOver() then return end
	for _, panel in ipairs(panels) do
		if panel:IsShown() and panel:IsMouseOver() then return end
	end
	Menus:Close()
end)

-- The menu of an owner opened: below it, or at the cursor (anchor "cursor"); its owner's click opens or
-- closes it, as the game's do.
function Menus:Open(owner, generator, anchor)
	if current and current.owner == owner then
		self:Close()
		return
	end
	self:Close()
	local record = Generate(owner, generator)
	if not record then return end
	current = { owner = owner, record = record, generator = generator }
	local panel = Panel(1)
	panel:ClearAllPoints()
	if anchor == "cursor" then
		local x, y = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale() or 1
		if scale <= 0 then scale = 1 end
		panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (x or 0) / scale, (y or 0) / scale)
	else
		current.minWidth = owner.GetWidth and owner:GetWidth() or nil
		panel:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
	end
	Fill(panel, record, 1)
	panel:Show()
	Sound(true)
	pcall(watcher.RegisterEvent, watcher, "GLOBAL_MOUSE_DOWN")
	if owner.MenuOpened then owner:MenuOpened() end
	return record
end

-- A context menu at the cursor (MenuUtil.CreateContextMenu's place): its record, also kept as Menus.context.
function Menus:OpenContext(owner, generator)
	self.context = self:Open(owner, generator, "cursor")
	if self.context then self.context.owner = owner end
	return self.context
end

-- An owner's menu built afresh (what it offers may have changed), kept as owner._menu.
function Menus:Generate(owner)
	return Generate(owner)
end

local function Detach(owner)
	if current and current.owner == owner then Menus:Close() end
end

-- A button that opens a menu on its press, as a dropdown's arrow does: its menu kept as button._menu,
-- built now and at each opening. A plain button: on the game's DropdownButton the game's own menu opens too
-- (Menus:StepArrow, below).
function Menus:Attach(button, generator)
	button._menuGenerator = generator or button._menuGenerator
	button:SetScript("OnMouseDown", function(self, mouseButton)
		if mouseButton == "LeftButton" and (not self.IsEnabled or self:IsEnabled()) then Menus:Open(self) end
	end)
	if not button._menusHooked then
		button._menusHooked = true
		button:HookScript("OnHide", Detach)
	end
	Generate(button)
	return button
end

--[[
	A location bar's menus (Blizzard_FrameXML/Mainline/NavigationBar.xml), as the journal's own buttons. A step
	(NavButtonTemplate) has its menu on a DropdownButton, MenuArrowButton, and the bar its overflow button on one:
	the game's widget, whose press is handled inside it, before and whatever its scripts (SetScript changes
	nothing there), and opens the game's menu, which the template sets up as the button shows
	(NavButtonTemplate_SetupDropdown) and fills from the step's listFunc or the bar's list of its steps. On the
	journal's steps and bar, that is the game's menus run with the journal's lists, as the note above says they
	must never be; on the floor step the journal puts on the world map's bar, a list asked for that it doesn't
	have (an error: the owner's, on Shadowfang Keep's floor step, 2026-11-08). So the game's buttons there are
	hidden and kept from the mouse, and the journal's own, drawn the same, open its menu.
]]

-- The square button's frame round the step's arrow, shown on the mouse (MenuArrowButton's OnEnter, OnLeave).
local function ShowArrowFrame(arrow, alpha)
	local normal, pushed = arrow:GetNormalTexture(), arrow:GetPushedTexture()
	if normal then normal:SetAlpha(alpha) end
	if pushed then pushed:SetAlpha(alpha) end
end

local function CenteredSquare(texture)
	if not texture then return end
	texture:ClearAllPoints()
	texture:SetPoint("CENTER")
	texture:SetSize(32, 32)
end

-- A step's menu arrow, MenuArrowButton drawn the same: the arrow, the square button's frame on the mouse, the
-- arrow nudged while pressed. Made once per step; a step the bar hands to another crumb gets that one's menu
-- (generator), or none (the arrow hidden by its caller).
function Menus:StepArrow(step, generator)
	local arrow = rawget(step, "JournalArrow")
	if arrow then
		arrow._menuGenerator = generator
		Generate(arrow)
		return arrow
	end
	local game = rawget(step, "MenuArrowButton")
	if game then
		game:Hide()
		if game.EnableMouse then game:EnableMouse(false) end
	end
	arrow = CreateFrame("Button", nil, step)
	arrow:SetSize(27, 31)
	arrow:SetPoint("RIGHT", step, "TOPRIGHT", -2, -15)
	arrow.smartNavigationIgnored = true
	arrow:SetNormalTexture("Interface\\Buttons\\UI-SquareButton-Up")
	arrow:SetPushedTexture("Interface\\Buttons\\UI-SquareButton-Down")
	arrow:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	CenteredSquare(arrow:GetNormalTexture())
	CenteredSquare(arrow:GetPushedTexture())
	CenteredSquare(arrow:GetHighlightTexture())
	ShowArrowFrame(arrow, 0)
	local art = arrow:CreateTexture(nil, "OVERLAY")
	art:SetTexture("Interface\\Buttons\\SquareButtonTextures")
	art:SetSize(12, 12)
	art:SetPoint("CENTER", arrow, "CENTER", 0, -1)
	art:SetTexCoord(0.453125, 0.640625, 0.203125, 0.015625)
	arrow.Art = art
	Menus:Attach(arrow, generator)
	arrow:HookScript("OnMouseDown", function(self) self.Art:SetPoint("CENTER", self, "CENTER", -1, -2) end)
	arrow:SetScript("OnMouseUp", function(self) self.Art:SetPoint("CENTER", self, "CENTER", 0, -1) end)
	arrow:SetScript("OnEnter", function(self) ShowArrowFrame(self, 1) end)
	arrow:SetScript("OnLeave", function(self) ShowArrowFrame(self, 0) end)
	step.JournalArrow = arrow
	return arrow
end

-- The bar's overflow button: the game's kept from the mouse and out of sight, the journal's own in its place,
-- drawn the same (NavBarTemplate's overflow), shown as the bar shows the game's. Its menu: the steps the bar
-- folded into it, from the first, each opened by its click as the game's menu does (NavBar_OverflowItemOnClick).
local OVERFLOW_ART = "Interface\\HelpFrame\\CS_HelpTextures"
local OVERFLOW_UP = { 0.54296875, 0.62890625, 0.7578125, 0.9921875 }
local OVERFLOW_DOWN = { 0.453125, 0.5390625, 0.7578125, 0.9921875 }

function Menus:CoverOverflow(bar)
	local game = rawget(bar, "overflowButton") or rawget(bar, "overflow")
	if not game then return nil end
	local cover = rawget(bar, "JournalOverflow")
	if cover then return cover end
	if game.EnableMouse then game:EnableMouse(false) end
	game:SetAlpha(0)
	cover = CreateFrame("Button", nil, bar)
	cover:SetAllPoints(game)
	cover:SetFrameLevel(game:GetFrameLevel() + 2)
	cover:SetNormalTexture(OVERFLOW_ART)
	cover:SetPushedTexture(OVERFLOW_ART)
	cover:SetHighlightTexture(OVERFLOW_ART, "ADD")
	local normal, pushed, highlight = cover:GetNormalTexture(), cover:GetPushedTexture(), cover:GetHighlightTexture()
	if normal then normal:SetTexCoord(unpack(OVERFLOW_UP)) end
	if pushed then pushed:SetTexCoord(unpack(OVERFLOW_DOWN)) end
	if highlight then
		highlight:SetTexCoord(unpack(OVERFLOW_UP))
		highlight:SetAlpha(0.4)
	end
	Menus:Attach(cover, function(_, menu)
		for _, step in ipairs(rawget(bar, "navList") or {}) do
			if step:IsShown() then break end
			menu:CreateButton(step:GetText(), function() step:Click() end)
		end
	end)
	cover:SetShown(game:IsShown())
	game:HookScript("OnShow", function() cover:Show() end)
	game:HookScript("OnHide", function() cover:Hide() end)
	bar.JournalOverflow = cover
	return cover
end

------------------------------------------------------------------------------------------
-- The dropdown: the game's WowStyle1DropdownTemplate (Mainline), drawn the same
------------------------------------------------------------------------------------------

local Dropdown = {}

local function ArrowState(button)
	if button.IsEnabled and not button:IsEnabled() then return "common-dropdown-a-button-disabled" end
	if button.down and button.over then return "common-dropdown-a-button-pressedhover" end
	if button.over then return "common-dropdown-a-button-hover" end
	if button.down then return "common-dropdown-a-button-pressed" end
	if Menus:IsOpen(button) then return "common-dropdown-a-button-open" end
	return "common-dropdown-a-button"
end

function Dropdown:UpdateArrow()
	self.Arrow:SetAtlas(ArrowState(self), USE_ATLAS_SIZE)
end

-- Its text: the chosen radios' names (SetSelectionText to say it otherwise), else the default text.
function Dropdown:UpdateText()
	local record = self._menu or Generate(self)
	local chosen = record and Chosen(record, {}) or {}
	local text = self.overrideText
	if text then
		-- said by its owner (SetText)
	elseif self.selectionText then
		local ok, said = pcall(self.selectionText, chosen)
		text = ok and said or nil
	elseif #chosen > 0 then
		local names = {}
		for _, entry in ipairs(chosen) do names[#names + 1] = entry.text end
		text = table.concat(names, ", ")
	end
	self.Text:SetText(text or self.defaultText or "")
end

function Dropdown:SetupMenu(generator)
	self._menuGenerator = generator
	self:GenerateMenu()
end

-- Built afresh (what it offers may have changed), its text with it; an open menu shows it at once.
function Dropdown:GenerateMenu()
	Generate(self)
	if current and current.owner == self then
		current.record = self._menu
		Fill(panels[1], self._menu, 1)
	end
	self:UpdateText()
end

function Dropdown:SetDefaultText(text)
	self.defaultText = text
	self:UpdateText()
end

-- Its text said outright, whatever is chosen (the floor menu's: the place shown).
function Dropdown:SetText(text)
	self.overrideText = text
	self:UpdateText()
end

function Dropdown:GetText()
	return self.Text:GetText()
end

function Dropdown:SetSelectionText(callback)
	self.selectionText = callback
	self:UpdateText()
end

function Dropdown:IsMenuOpen() return Menus:IsOpen(self) end
function Dropdown:CloseMenu() if Menus:IsOpen(self) then Menus:Close() end end
function Dropdown:MenuOpened() self:UpdateArrow() end
function Dropdown:MenuClosed() self:UpdateArrow() end

-- A dropdown of the game's look, its menu the journal's.
function Menus:NewDropdown(parent, width)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width or 120, 25)
	button.Background = button:CreateTexture(nil, "BACKGROUND")
	button.Background:SetAtlas("common-dropdown-textholder", USE_ATLAS_SIZE)
	button.Background:SetPoint("TOPLEFT", -8, 7)
	button.Background:SetPoint("BOTTOMRIGHT", 8, -9)
	button.Arrow = button:CreateTexture(nil, "OVERLAY")
	button.Arrow:SetPoint("RIGHT", 1, -3)
	button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	button.Text:SetJustifyH("LEFT")
	button.Text:SetWordWrap(false)
	button.Text:SetHeight(10)
	button.Text:SetPoint("TOPRIGHT", button.Arrow, "LEFT")
	button.Text:SetPoint("TOPLEFT", 8, -8)
	for key, method in pairs(Dropdown) do button[key] = method end
	button:SetScript("OnEnter", function(self) self.over = true; self:UpdateArrow() end)
	button:SetScript("OnLeave", function(self) self.over = false; self:UpdateArrow() end)
	button:SetScript("OnMouseUp", function(self) self.down = false; self:UpdateArrow() end)
	button:SetScript("OnEnable", Dropdown.UpdateArrow)
	button:SetScript("OnDisable", Dropdown.UpdateArrow)
	Menus:Attach(button)
	button:HookScript("OnMouseDown", function(self) self.down = true; self:UpdateArrow() end)
	button:UpdateArrow()
	return button
end
