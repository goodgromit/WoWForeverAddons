local addonName, ns = ...
local L = ns.L

ns.name = addonName

BINDING_NAME_AEGISJOURNAL_TOGGLE = L.BINDING_TOGGLE

local BINDING = "AEGISJOURNAL_TOGGLE"
local DEFAULT_KEY = "SHIFT-J"

-- Actions Shift+J may already hold that are safe to take over: nothing at all, Blizzard's
-- own journal (which does not load on Forever), the two journals this one replaces, and
-- this journal's own binding from before it was renamed.
local REPLACEABLE_ACTIONS = {
	[""] = true,
	TOGGLEENCOUNTERJOURNAL = true,
	TOGGLE_ADVENTUREGUIDECLASSIC = true,
	FOREVERDUNGEONJOURNAL_TOGGLE = true,
	AEGISIJ_TOGGLE = true,
}

function ns.Print(message)
	DEFAULT_CHAT_FRAME:AddMessage("|cffffd100" .. L.JOURNAL_TITLE .. ":|r " .. message)
end

--[[
	Shift+J is offered once for each set of key bindings (the account's, and the character's
	when "Character Specific Key Bindings" is on), not forced. A key the player has already
	given to something else is left alone, and once a set has had the offer the player's own
	choices in the Key Bindings window always win. Anything on Shift+J that is not in
	REPLACEABLE_ACTIONS is the player's choice, the game's guild window included: on Forever
	the guild window is on J, and Shift+J has nothing.
	On the live servers on 2026-11-04 the current set was still 0, the game's own defaults, when
	the journal logged in: the player's own bindings had not loaded yet. The offer ran on the
	defaults, its Shift+J was lost when the player's bindings loaded (an unbound Shift+J then
	falls through to J, the guild window). That offer was recorded for set 0, so it did not stop
	the account's own offer; what stopped it was the record for the account's set left by an
	earlier offer during the stress test, though the live game's bindings no longer held it. Now:
	- While the set is neither the account's (1) nor the character's (2), the offer waits, takes
	  nothing, records nothing and says nothing; UPDATE_BINDINGS brings it back once the player's
	  own set is in use, and the offer is saved into that set.
	- Every set has one more offer, for the sets whose Shift+J was lost that way: keyOfferedSets2
	  holds the sets that had it. The account's set is recorded for the account, and the
	  character's for each character, since every character has its own. keyOfferedSets, the
	  first offer's record, stays in the saved variables but is no longer read.
	- A game that stays on its defaults (a new player who never changed a key) still gets Shift+J:
	  if the set is still not 1 or 2 a while after login and the player's own set has not been in
	  use this session, Shift+J is put on the journal for this session only. Nothing is saved and
	  nothing is recorded, so it cannot replace the player's bindings if they load late; it is done
	  again at each login while the game is on its defaults, and the player is told only the first
	  time.
]]
local events = CreateFrame("Frame")

local ACCOUNT_SET, CHARACTER_SET = 1, 2
-- Seconds after login before Shift+J is put on the journal for the session when the game is still
-- on its defaults.
local DEFAULTS_WAIT = 25
-- Whether the account's or the character's set has been in use since login: then the defaults are
-- only a passing state (as after a reset to the defaults), and Shift+J is not put on them.
local ownSetSeen = false
-- Whether the session's Shift+J on the defaults waits for the end of a fight.
local defaultsWaitingForCombat = false

local function ClaimDefaultKey()
	local set = GetCurrentBindingSet()
	if set ~= ACCOUNT_SET and set ~= CHARACTER_SET then return end
	ownSetSeen = true
	local saved = set == CHARACTER_SET and ns.charDB or ns.db
	saved.keyOfferedSets2 = saved.keyOfferedSets2 or {}
	local offered = saved.keyOfferedSets2
	if offered[set] then return end
	if InCombatLockdown() then
		-- Bindings cannot change in combat: listen for its end only now, not all the time.
		events:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	offered[set] = true

	if GetBindingKey(BINDING) then return end
	local current = GetBindingAction(DEFAULT_KEY) or ""
	if not REPLACEABLE_ACTIONS[current] then
		ns.Print(string.format(L.KEY_TAKEN, current))
		return
	end
	if SetBinding(DEFAULT_KEY, BINDING) then
		SaveBindings(set)
		ns.Print(L.KEY_CLAIMED)
	end
end

-- The game still on its defaults a while after login: Shift+J on the journal for this session, if
-- it is free and the journal has no key. No SaveBindings and no record, so the player's own
-- bindings, when they load, replace it and have their own offer. A Shift+J the defaults give to
-- something else is left alone without a word, as it would be said at every login.
local function KeyOnDefaults()
	defaultsWaitingForCombat = false
	local set = GetCurrentBindingSet()
	if ownSetSeen or set == ACCOUNT_SET or set == CHARACTER_SET then return end
	if InCombatLockdown() then
		defaultsWaitingForCombat = true
		events:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	if GetBindingKey(BINDING) then return end
	if not REPLACEABLE_ACTIONS[GetBindingAction(DEFAULT_KEY) or ""] then return end
	if SetBinding(DEFAULT_KEY, BINDING) and not ns.db.keyOnDefaultsTold then
		ns.db.keyOnDefaultsTold = true
		ns.Print(L.KEY_CLAIMED)
	end
end

local function InitSavedVariables()
	AegisJournalDB = AegisJournalDB or {}
	AegisJournalCharDB = AegisJournalCharDB or {}
	ns.db = AegisJournalDB
	ns.charDB = AegisJournalCharDB
	-- The style is the character's own now: the account-wide keys of the test builds go.
	ns.Style.DropAccountKeys(ns.db)
	ns.Recorder:Init()
	-- The player's own /aegis items scan hides what it found, as the built-in one does.
	if type(ns.db.missingItems) == "table" then ns.Items:AddUnconfirmed(ns.db.missingItems.items) end
end

-- Hidden items are asked about again a while after logging in, once a session.
local RECHECK_DELAY = 10

function AegisJournal_Toggle()
	ns.Journal:Toggle()
end

--[[
	/aegis lang <de|fr|ru|cn|tw|es|mx|pt|ko|en|off>: the journal in another of its languages from the next
	/reload, whatever the client's, to check a translation. Only its own words change: the game's
	names (spells, items, the client's own interface words) stay the client's. Saved for the
	account until /aegis lang off.
]]
local LANGUAGE_CODES = { de = "deDE", dede = "deDE", fr = "frFR", frfr = "frFR", ru = "ruRU", ruru = "ruRU",
	cn = "zhCN", zhcn = "zhCN", tw = "zhTW", zhtw = "zhTW", es = "esES", eses = "esES", mx = "esMX", esmx = "esMX",
	pt = "ptBR", ptbr = "ptBR", ko = "koKR", kr = "koKR", kokr = "koKR", en = "enUS", enus = "enUS" }
local LANGUAGE_NAMES = { deDE = "German", frFR = "French", ruRU = "Russian", zhCN = "Simplified Chinese",
	zhTW = "Traditional Chinese", esES = "Spanish (Spain)", esMX = "Spanish (Latin America)", ptBR = "Brazilian Portuguese",
	koKR = "Korean", enUS = "English" }

local function PreviewLanguage(typed)
	typed = ((typed or ""):lower():gsub("[^%a]", ""))
	if typed == "off" then
		ns.db.previewLocale = nil
		ns.Print(L.LANG_OFF)
		return
	end
	local code = LANGUAGE_CODES[typed]
	if not code then
		local now = ns.previewLocale or GetLocale()
		ns.Print(string.format(L.LANG_USAGE, LANGUAGE_NAMES[now] or now))
		return
	end
	ns.db.previewLocale = code
	ns.Print(string.format(L.LANG_SET, LANGUAGE_NAMES[code]))
	if code == "zhCN" or code == "zhTW" then ns.Print(L.LANG_FONTS) end
	if code == "koKR" then ns.Print(L.LANG_FONTS_KO) end
end

SLASH_AEGISJOURNAL1 = "/aegis"
SLASH_AEGISJOURNAL2 = "/instancejournal"
SLASH_AEGISJOURNAL3 = "/ij"
SlashCmdList.AEGISJOURNAL = function(message)
	-- The first word is the command; the rest keeps its capitals (place names).
	local command, rest = strtrim(message or ""):match("^(%S*)%s*(.-)$")
	command = command:lower()
	if command == "" then
		ns.Journal:Toggle()
	elseif command == "record" then
		-- With the Record tab off in the options, nothing is recorded: it says where to turn it on.
		if ns.Recorder.TabShown() then ns.Recorder:Toggle() else ns.Print(L.RECORD_TAB_IS_OFF) end
	elseif command == "reset" then
		ns.Journal:ResetPosition()
		ns.Print(L.POSITION_RESET)
	elseif command == "dock" then
		local on = not ns.Journal:IsDocked()
		local waits = ns.Journal:SetDocked(on)
		ns.Print(on and L.DOCK_ON or L.DOCK_OFF)
		if waits then ns.Print(L.DOCK_AFTER_COMBAT) end
	elseif command == "perf" then
		ns.Perf:Run()
	elseif command == "where" then
		ns.Perf:Where()
	elseif command == "taxi" then
		ns.Perf:Taxi()
	elseif command == "items" then
		ns.Perf:Items()
	elseif command == "travel" then
		ns.TravelMap:Capture(rest)
	elseif command == "gear" then
		ns.Journal:ShowGear()
	elseif command == "weights" then
		if ns.Journal:ShowGear() then ns.GearPanel:ShowWeights(ns.GearPanel.panel, true) end
	elseif command == "gearscan" then
		ns.GearFinder:Scan()
	elseif command == "options" then
		ns.Options:Open()
	elseif command == "style" then
		ns.StylePopup:Ask()
	elseif command == "areas" then
		ns.Areas:Scan()
	elseif command == "lang" then
		PreviewLanguage(rest)
	elseif command == "run" then
		ns.RunTracker:Slash(rest)
	else
		ns.Print(L.SLASH_HELP)
	end
end

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == addonName then
			InitSavedVariables()
			-- The content in the journal's language, where it has it. A mistake in a translation is
			-- reported, and the journal still opens. The quartermasters the player captured join
			-- their factions first, known by the client's names for them, so the translation covers
			-- what they add.
			local ok, problem = pcall(ns.KeepClientNames)
			if not ok then geterrorhandler()(problem) end
			ns.Recorder:ShareVendors()
			ok, problem = pcall(ns.ApplyLocale)
			if not ok then geterrorhandler()(problem) end
			self:UnregisterEvent("ADDON_LOADED")
		end
	elseif event == "PLAYER_LOGIN" then
		self:UnregisterEvent("PLAYER_LOGIN")
		-- Switching between the account's and the character's bindings brings another set. Listened
		-- to first, so a set-0 login still gets the offer once the player's own set is in use.
		self:RegisterEvent("UPDATE_BINDINGS")
		ownSetSeen, defaultsWaitingForCombat = false, false
		ClaimDefaultKey()
		-- Still on the game's defaults a while after login: Shift+J for this session only (above).
		if C_Timer and C_Timer.After then C_Timer.After(DEFAULTS_WAIT, KeyOnDefaults) end
		if ns.previewLocale then
			ns.Print(string.format(L.LANG_ON, LANGUAGE_NAMES[ns.previewLocale] or ns.previewLocale))
		elseif ns.db.previewLocale then
			ns.Print(L.LANG_UNAVAILABLE)
		end
		if C_Timer and C_Timer.After then
			C_Timer.After(RECHECK_DELAY, function() ns.Items:RecheckUnconfirmed() end)
		end
	elseif event == "UPDATE_BINDINGS" then
		ClaimDefaultKey()
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		ClaimDefaultKey()
		if defaultsWaitingForCombat then KeyOnDefaults() end
	end
end)
