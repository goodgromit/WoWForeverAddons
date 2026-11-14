local _, ns = ...

--[[
	The journal's style, for each character on its own: Modern (everything on, as the journal has
	been), Classic (a more original-style journal, with fewer extras) or Custom (each feature ticked
	or not in the journal's options). Each character is asked once, at its first login with the
	journal (UI/StylePopup.lua), and can change it any time in the journal's options (UI/Options.lua).
	A choice on one character changes no other's.

	What each style turns on is here, in one place: FEATURES lists the features, in the order the
	popup and the options show them, and PRESETS says what Modern and Classic set each one to.
	A feature not named in a preset is on in it. The journal itself (bosses, loot, quests, Before
	you go, the dungeons' own maps, the search, where an item drops in its tooltip) is no feature:
	it is always there.

	  gearFinder   The Gear Finder tab, its tab on the character panel, the stat-weight lines on
	               item tooltips, the green upgrade arrows and the journal's scales in Pawn: one
	               switch, as they all weigh items by the same stat weights.
	  wayInMaps    The maps of the way into a dungeon (caves, buildings, Blackrock Mountain's
	               levels) over the world map, and their cave and building doors on it.
	  mapMarkers   The journal's marks on the world map: dungeon and raid doors, flight masters,
	               boats, zeppelins, trams and portals, its quest marks, zone levels and unexplored
	               areas.

	The style also says whether the journal's window docks among the game's own (UI/Journal.lua) while
	the player has never chosen that themselves: Modern free, Classic docked, Custom docked as before.
	A choice of the player's (the options' box, /aegis dock) is the account's and stands for every
	style; it is no feature and never makes the style Custom.

	Saved in the character's AegisJournalCharDB (ns.charDB): style ("modern", "classic", "custom";
	none is Modern), styleFeatures (Custom's own ticks) and styleAsked (the VERSION the character was
	last asked at). Nothing reads them before ADDON_LOADED sets ns.charDB; until then, and on a
	character that has not chosen, the style is Modern.
]]

local Style = {}
ns.Style = Style

-- Raised when every character should be asked again (a new feature worth choosing about).
Style.VERSION = 1

Style.FEATURES = {
	{ key = "gearFinder", name = "STYLE_GEAR", tip = "STYLE_GEAR_TIP", variable = "AEGIS_JOURNAL_GEAR_FINDER" },
	{ key = "wayInMaps", name = "STYLE_WAY_IN", tip = "STYLE_WAY_IN_TIP", variable = "AEGIS_JOURNAL_WAY_IN_MAPS" },
	{ key = "mapMarkers", name = "STYLE_MARKERS", tip = "STYLE_MARKERS_TIP", variable = "AEGIS_JOURNAL_MAP_MARKERS" },
}

Style.PRESETS = {
	modern = { gearFinder = true, wayInMaps = true, mapMarkers = true },
	classic = { gearFinder = false, wayInMaps = false, mapMarkers = false },
}

-- Whether each style docks the window while the player has not chosen; a style not named docks.
Style.DOCKS = { modern = false, classic = true }

-- The popup's boxes, left to right, and the options' list.
Style.CHOICES = { "classic", "modern", "custom" }
Style.DEFAULT = "modern"

-- A choice's name and what it does, in the journal's language: STYLE_CLASSIC, STYLE_CLASSIC_DESC and so on.
function Style.Name(choice)
	return ns.L["STYLE_" .. choice:upper()]
end

function Style.Description(choice)
	return ns.L["STYLE_" .. choice:upper() .. "_DESC"]
end

local listeners = {}

-- fn(from): called after every change; `from` is the options' variable that made it, if one did.
function Style:OnChange(fn)
	listeners[#listeners + 1] = fn
end

local function Changed(from)
	for _, fn in ipairs(listeners) do
		local ok, problem = pcall(fn, from)
		if not ok then geterrorhandler()(problem) end
	end
end

function Style:Choice()
	local choice = ns.charDB and ns.charDB.style
	if choice == "custom" or Style.PRESETS[choice] then return choice end
	return Style.DEFAULT
end

-- Whether the window docks for this character's style, while the player has not chosen (ns.db.docked nil).
function Style:DocksByDefault()
	return Style.DOCKS[self:Choice()] ~= false
end

-- Whether a feature is on now.
function Style:On(feature)
	local preset = Style.PRESETS[self:Choice()]
	if preset then return preset[feature] ~= false end
	local picks = ns.charDB and ns.charDB.styleFeatures
	return not (type(picks) == "table" and picks[feature] == false)
end

-- What is on now, feature by feature: where Custom starts from.
local function Current()
	local picks = {}
	for _, feature in ipairs(Style.FEATURES) do picks[feature.key] = Style:On(feature.key) end
	return picks
end

function Style:Choose(choice, from)
	if not (ns.charDB and (choice == "custom" or Style.PRESETS[choice])) then return false end
	if choice == "custom" and self:Choice() ~= "custom" then ns.charDB.styleFeatures = Current() end
	ns.charDB.style = choice
	Changed(from)
	return true
end

-- A feature ticked or unticked by itself: the style becomes Custom, starting from what was on. Set to
-- what the preset already gives (as the Settings panel's Defaults button does), it stays the preset.
function Style:SetFeature(feature, on, from)
	if not ns.charDB then return end
	on = on and true or false
	if self:Choice() ~= "custom" then
		if self:On(feature) == on then return end
		ns.charDB.styleFeatures = Current()
		ns.charDB.style = "custom"
	end
	-- Custom with no ticks saved (saved data edited by hand): from what is on now.
	if type(ns.charDB.styleFeatures) ~= "table" then ns.charDB.styleFeatures = Current() end
	ns.charDB.styleFeatures[feature] = on
	Changed(from)
end

-- Whether this character has been asked (and so is not asked again).
function Style:Asked()
	local asked = ns.charDB and ns.charDB.styleAsked
	return type(asked) == "number" and asked >= Style.VERSION
end

function Style:MarkAsked()
	if ns.charDB then ns.charDB.styleAsked = Style.VERSION end
end

-- This character asked again, as on its first login (the options' Reset). Other characters keep theirs.
function Style:ForgetAsked()
	if ns.charDB then ns.charDB.styleAsked = nil end
end

--[[
	Unreleased test builds saved the style in AegisJournalDB, for the whole account. Each character
	now has its own and is asked for it, so those keys are dropped at load, not carried over.
]]
function Style.DropAccountKeys(db)
	db.style, db.styleFeatures, db.styleAsked = nil, nil, nil
end
