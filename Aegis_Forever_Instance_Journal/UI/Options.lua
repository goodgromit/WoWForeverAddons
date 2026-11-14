local _, ns = ...
local L = ns.L

--[[
	The journal's page in the game's options (Options > AddOns), on the client's own settings
	panel (Blizzard_Settings_Shared): what the journal adds that a player may rather do without.
	Each box reads and writes the journal's own saved choice, so it agrees with the same box
	elsewhere (the stat weights editor's).
]]

local Options = {}
ns.Options = Options

-- Settings.VarType.Boolean and .String, on a client that names its types.
local BOOLEAN, STRING = "boolean", "string"

-- The journal's style (Core/Style.lua): a choice of Modern, Classic or Custom, and a box for each feature.
-- They are this character's; every other box on the page is for the whole account.
local STYLE_VARIABLE = "AEGIS_JOURNAL_STYLE"

local CHECKBOXES = {
	{ variable = "AEGIS_JOURNAL_BOSS_LEVELS", name = "OPTIONS_BOSS_LEVELS", tip = "OPTIONS_BOSS_LEVELS_TIP",
		get = function() return ns.EncounterPage.ShowsBossLevels() end,
		set = function(shown) ns.EncounterPage.SetShowsBossLevels(shown) end },
	-- The three that go by the Gear Finder's weights: under its box, and greyed while it is off.
	{ variable = "AEGIS_JOURNAL_ITEM_TIPS", name = "WEIGHTS_SHOW_GAINS", tip = "WEIGHTS_SHOW_GAINS_TIP", under = "gearFinder",
		get = function() return ns.GearPanel.ShowsGains() end,
		set = function(shown) ns.GearPanel.SetShowsGains(shown, true) end },
	{ variable = "AEGIS_JOURNAL_ITEM_SOURCES", name = "OPTIONS_SOURCES", tip = "OPTIONS_SOURCES_TIP",
		get = function() return ns.ItemTooltip.ShowsSources() end,
		set = function(shown) ns.ItemTooltip.SetShowsSources(shown) end },
	{ variable = "AEGIS_JOURNAL_UPGRADE_ARROWS", name = "OPTIONS_ARROWS", tip = "OPTIONS_ARROWS_TIP", under = "gearFinder",
		get = function() return ns.UpgradeArrows.Shows() end,
		set = function(shown) ns.UpgradeArrows.SetShows(shown) end },
	{ variable = "AEGIS_JOURNAL_PAWN_WEIGHTS", name = "OPTIONS_PAWN_WEIGHTS", tip = "OPTIONS_PAWN_WEIGHTS_TIP", under = "gearFinder",
		get = function() return ns.PawnLink:Source() == "pawn" end,
		set = function(on) ns.PawnLink:SetSource(on and "pawn" or "journal") end, default = false },
	-- The unexplored parts of a zone on the world map, shaded: under the map markers' box, as it goes by them. In the
	-- world map's own filter menu until 2026-11-08 (UI/ZoneMap.lua).
	{ variable = "AEGIS_JOURNAL_UNEXPLORED", name = "MAP_SHOW_UNEXPLORED", tip = "OPTIONS_UNEXPLORED_TIP", under = "mapMarkers",
		get = function() return ns.ZoneMap:ShowsUnexplored() end,
		set = function(shown) ns.ZoneMap:SetShowUnexplored(shown) end, default = false },
	-- The Record tab, on whatever the style: off, nothing is recorded (Core/Recorder.lua).
	{ variable = "AEGIS_JOURNAL_RECORD_TAB", name = "OPTIONS_RECORD_TAB", tip = "OPTIONS_RECORD_TAB_TIP",
		get = function() return ns.Recorder.TabShown() end,
		set = function(shown)
			ns.Recorder:SetTabShown(shown)
			ns.Journal:ApplyStyle()
		end },
	-- The dungeon run block (UI/RunTracker.lua), on in every style, with its five boxes under it, greyed while it is
	-- off: its numbers, placing it freely, its dark mode, its summary in chat and the experiment of placing it inside
	-- the tracker, with the button that makes the tracker taller for it.
	{ variable = "AEGIS_JOURNAL_RUN", name = "OPTIONS_RUN", tip = "OPTIONS_RUN_TIP", key = "runTracker",
		get = function() return ns.Run:Option("on") end,
		set = function(on) ns.Run:SetOption("on", on) end },
	{ variable = "AEGIS_JOURNAL_RUN_NUMBERS", name = "OPTIONS_RUN_NUMBERS", tip = "OPTIONS_RUN_NUMBERS_TIP", under = "runTracker",
		get = function() return ns.Run:Option("numbers") end,
		set = function(on) ns.Run:SetOption("numbers", on) end },
	{ variable = "AEGIS_JOURNAL_RUN_FREE", name = "OPTIONS_RUN_FREE", tip = "OPTIONS_RUN_FREE_TIP", under = "runTracker",
		get = function() return ns.Run:Option("free") end,
		set = function(on) ns.Run:SetOption("free", on) end, default = false },
	-- Its gold art darkened as a dark-mode UI darkens the tracker's; off, it takes the tracker's own tint, if any
	-- (UI/RunTracker.lua Paint).
	{ variable = "AEGIS_JOURNAL_RUN_DARK_MODE", name = "OPTIONS_RUN_DARK_MODE", tip = "OPTIONS_RUN_DARK_MODE_TIP",
		under = "runTracker",
		get = function() return ns.Run:Option("darkMode") end,
		set = function(on) ns.Run:SetOption("darkMode", on) end, default = false },
	{ variable = "AEGIS_JOURNAL_RUN_SUMMARY", name = "OPTIONS_RUN_SUMMARY", tip = "OPTIONS_RUN_SUMMARY_TIP", under = "runTracker",
		get = function() return ns.Run:Option("summary") end,
		set = function(on) ns.Run:SetOption("summary", on) end },
	-- The experiment of placing the block inside the game's quest tracker (UI/RunTrackerInside.lua): off by default
	-- (Run.INSIDE_DEFAULT), for the whole account like the boxes above it, so a blocked action seen on one character
	-- turns it off for all. Under it, a button: the tracker's Edit Mode Height made enough for the block, when the
	-- player asks (RunTrackerInside:MakeTaller).
	{ variable = "AEGIS_JOURNAL_RUN_INSIDE", name = "OPTIONS_RUN_INSIDE", tip = "OPTIONS_RUN_INSIDE_TIP", under = "runTracker",
		get = function() return ns.Run:Option("inside") end,
		set = function(on) ns.RunTrackerInside:SetByHand(on) end, default = ns.Run.INSIDE_DEFAULT },
	{ button = "OPTIONS_RUN_TALLER", buttonText = "OPTIONS_RUN_TALLER_BUTTON", tip = "OPTIONS_RUN_TALLER_TIP",
		under = "runTracker", click = function() ns.RunTrackerInside:MakeTaller() end },
	{ variable = "AEGIS_JOURNAL_MINIMAP", name = "OPTIONS_MINIMAP", tip = "OPTIONS_MINIMAP_TIP",
		get = function() return ns.MinimapButton.Shows() end,
		set = function(shown) ns.MinimapButton.SetShows(shown) end },
	-- Shows the window as it is: the player's choice, else the style's (UI/Journal.lua IsDocked). Its
	-- default is the default style's, Modern's; Reset forgets the choice, so the style's holds again.
	{ variable = "AEGIS_JOURNAL_DOCK", name = "OPTIONS_DOCK", tip = "OPTIONS_DOCK_TIP",
		get = function() return ns.Journal:IsDocked() end,
		set = function(on) ns.Journal:SetDocked(on, true) end,
		default = ns.Style.DOCKS[ns.Style.DEFAULT] ~= false, reset = function() ns.Journal:ForgetDocked() end },
}

-- Every setting on the page, top to bottom, with its default: what Reset puts back.
local pageSettings = {}

local function AddCheckbox(category, variable, name, tip, default, get, set)
	local boolean = Settings.VarType and Settings.VarType.Boolean or BOOLEAN
	local setting = Settings.RegisterProxySetting(category, variable, boolean, name, default, get, set)
	pageSettings[#pageSettings + 1] = { setting = setting, default = default }
	return Settings.CreateCheckbox(category, setting, tip)
end

-- Reset's question, before anything is put back.
local RESET_POPUP = "AEGIS_JOURNAL_RESET"
StaticPopupDialogs[RESET_POPUP] = {
	text = L.STYLE_RESET_CONFIRM,
	button1 = L.STYLE_RESET_BUTTON,
	button2 = CANCEL,
	OnAccept = function() Options:Reset() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

--[[
	The page, top to bottom: the style and the Reset button, then each of its features with what goes
	by it under it (the Gear Finder's weights in tooltips, its arrows and Pawn's weights under the
	Gear Finder), then the rest. A feature ticked or unticked makes the style Custom (Core/Style.lua).
]]
function Options:Register()
	if self.category or not (Settings and Settings.RegisterVerticalLayoutCategory and Settings.RegisterProxySetting
		and Settings.CreateCheckbox and Settings.RegisterAddOnCategory) then
		return
	end
	local category, layout = Settings.RegisterVerticalLayoutCategory(L.OPTIONS_TITLE)
	--[[
		The style: its setting (what Reset puts back, and what a change of style tells the page), and a button that
		asks the style question (UI/StylePopup.lua). Not the game's dropdown since 2026-11-08: its menu is the game's
		(Blizzard_Menu), and the journal's code in it tainted the game's unit menus after it (the owner's taint log).
	]]
	local text = Settings.VarType and Settings.VarType.String or STRING
	local setting = Settings.RegisterProxySetting(category, STYLE_VARIABLE, text, L.STYLE_OPTION, ns.Style.DEFAULT,
		function() return ns.Style:Choice() end,
		function(choice) ns.Style:Choose(choice, STYLE_VARIABLE) end)
	pageSettings[#pageSettings + 1] = { setting = setting, default = ns.Style.DEFAULT }
	if layout and layout.AddInitializer and CreateSettingsButtonInitializer then
		local choose = CreateSettingsButtonInitializer(L.STYLE_OPTION, L.STYLE_CHOOSE_BUTTON,
			function() ns.StylePopup:Ask() end, L.STYLE_OPTION_TIP, true)
		if choose then layout:AddInitializer(choose) end
	end
	-- Under it, Reset: asked first, then the page as on a fresh install (Options:Reset).
	if layout and layout.AddInitializer and CreateSettingsButtonInitializer then
		local button = CreateSettingsButtonInitializer(L.STYLE_RESET, L.STYLE_RESET_BUTTON,
			function() StaticPopup_Show(RESET_POPUP) end, L.STYLE_RESET_TIP, true)
		if button then layout:AddInitializer(button) end
	end
	-- on: whether what the box goes by is on (a style feature by default, else the box above it).
	local function AddBox(box, parent, feature, on)
		-- A button among the boxes (the run block's Make taller): under the box it goes by, greyed with it where the
		-- client can show that; no setting of its own, so Reset leaves it be.
		if box.button then
			if not (layout and layout.AddInitializer and CreateSettingsButtonInitializer) then return nil end
			local button = CreateSettingsButtonInitializer(L[box.button], L[box.buttonText], box.click, L[box.tip], true)
			if not button then return nil end
			if parent and button.SetParentInitializer then button:SetParentInitializer(parent, on) end
			layout:AddInitializer(button)
			return button
		end
		local default = box.default == nil and true or box.default
		local initializer = AddCheckbox(category, box.variable, L[box.name], L[box.tip], default, box.get, box.set)
		pageSettings[#pageSettings].reset = box.reset
		-- Greyed while the feature it goes by is off, where the client can show that.
		if parent and initializer and initializer.SetParentInitializer then
			initializer:SetParentInitializer(parent, on or function() return ns.Style:On(feature) end)
		end
		return initializer
	end
	for _, feature in ipairs(ns.Style.FEATURES) do
		local initializer = AddCheckbox(category, feature.variable, L[feature.name], L[feature.tip], true,
			function() return ns.Style:On(feature.key) end,
			function(on) ns.Style:SetFeature(feature.key, on, feature.variable) end)
		for _, box in ipairs(CHECKBOXES) do
			if box.under == feature.key then AddBox(box, initializer, feature.key) end
		end
	end
	for _, box in ipairs(CHECKBOXES) do
		if not box.under then
			local initializer = AddBox(box)
			-- A box with boxes of its own under it (the run block's).
			for _, child in ipairs(box.key and CHECKBOXES or {}) do
				if child.under == box.key then AddBox(child, initializer, nil, box.get) end
			end
		end
	end
	Settings.RegisterAddOnCategory(category)
	self.category = category
end

-- A change of style from anywhere: the page's style and feature boxes follow, all but the one that
-- made it, which needs no telling.
ns.Style:OnChange(function(from)
	if not (Settings and Settings.NotifyUpdate) then return end
	local variables = { STYLE_VARIABLE }
	for _, feature in ipairs(ns.Style.FEATURES) do variables[#variables + 1] = feature.variable end
	for _, variable in ipairs(variables) do
		if variable ~= from then pcall(Settings.NotifyUpdate, variable) end
	end
end)

--[[
	The journal as on a fresh install: each setting on the page back to its default, through its own
	setter as the panel's Defaults button does (the style first, so the feature boxes find Modern), then
	the style question asked again. A setting already at its default is left be. The dock box forgets
	the player's choice instead, so the window docks or not as the style has it (UI/Journal.lua). The style, its
	features' boxes and its question are this character's, and other characters keep theirs; every
	other box is the account's, so it goes back for every character. Nothing else is touched:
	recordings, stat weights, the window's place and the rest of the saved data stay.
]]
function Options:Reset()
	for _, entry in ipairs(pageSettings) do
		if entry.reset then
			entry.reset()
		elseif entry.setting:GetValue() ~= entry.default then
			entry.setting:SetValue(entry.default)
		end
	end
	ns.Style:ForgetAsked()
	ns.StylePopup:Ask()
end

--[[
	The game's settings window shut before the style question shows, after Reset or /aegis style: the
	question has nothing behind its boxes, so the window would show around and between them. Hidden
	with HideUIPanel, the last step of the window's own Close; the window has no place among the
	game's windows, so that only hides it, and its OnHide saves the key bindings as on any close. The
	Close first commits every page, then goes back to the game menu. Neither is done from here: the
	game menu's way back shuts every window open, the question with them, and the commit would run
	every page's settings code as the journal's (tainted), so that a setting changed that way, such as
	an action bar's, could then be blocked in combat. Left open in combat, where the game
	takes no addon's HideUIPanel, and with game settings changed but not applied, which only the
	window's own Close may keep or drop: the question waits for the window to close then.
]]
function Options:CloseSettings()
	local panel = SettingsPanel
	if not (panel and panel.IsShown and panel:IsShown()) or InCombatLockdown() or type(HideUIPanel) ~= "function" then
		return
	end
	if type(panel.HasUnappliedSettings) == "function" then
		local ok, unapplied = pcall(panel.HasUnappliedSettings, panel)
		if not ok or unapplied then return end
	end
	pcall(HideUIPanel, panel)
end

-- /aegis options
function Options:Open()
	if self.category and Settings.OpenToCategory then
		Settings.OpenToCategory(self.category:GetID())
	end
end

local events = CreateFrame("Frame")
ns.RegisterEvents(events, "PLAYER_LOGIN")
events:SetScript("OnEvent", function() Options:Register() end)
