local addonName, ns = ...
local L = ns.L

--[[
	The run block inside the game's quest tracker: right under its "All Objectives" header, with Quests and every
	other section of the tracker moved down below it, as retail shows its keystone block. Off by default, as in
	0.39.21 (the owner, 2026-11-13: "keep experimental in for now"; Core/Run.lua's Run.INSIDE_DEFAULT says why): its
	tip warns that it can cause blocked actions in combat until a /reload (the risk, below). Still named "(test)" in
	the options (shortened from "(experimental)" in 0.39.22 to fit, Tools/option_labels.lua). A player's own choice
	is kept (saved as made since 0.39.21): a ticked box stays on, an unticked one off. On, it goes inside wherever the block shows: inside a
	dungeon, and outside too (a run left behind, the last run shown with /ij run), as the owner asked after trying it
	in Booty Bay. From 0.39.21 to 0.39.22 "Place it freely" ticked won over it (the drag fix); since 0.39.23, with free
	the default (Core/Run.lua's Run.FREE_DEFAULT), this box ticked wins, and the block is not dragged while it is on
	(UI/RunTracker.lua's Free). Off, or while the block is hidden, this file asks nothing of the tracker and the block
	sits beside the tracker as in 0.39.20, or freely (UI/RunTracker.lua's Place); a provider handed over earlier in the session gives 0 until a
	/reload.

	The client's way in (Blizzard_ObjectiveTracker, read out of Forever's own files, 2026-11-12):
	- The tracker's OnLoad listens for EventRegistry's "ObjectiveTrackerContainerMixin.AddTopPaddingProvider"
	  (Blizzard_ObjectiveTrackerContainer.lua:22) and keeps what it is handed in its topPaddingProviders
	  (AddTopPaddingProvider, :26-28). The client has nothing to take one out again: once handed over, the provider
	  stays there until the interface is loaded again (/reload or a logout). "Off" is a provider that gives 0.
	- On every layout the tracker asks each provider's GetTopPadding() twice, in this order: for its sections
	  (UpdateTopPadding, Container.lua:57-63, called at the start of its Update, :77: the first section starts that
	  much lower than its usual 38), then for its header (UpdateHeaderPosition, Blizzard_ObjectiveTracker.lua:54-60,
	  at the end of its Update, :84: "All Objectives" moves down by it). The block wants the first and not the
	  second, so the provider answers the sections' ask with the block's height and the tracker's own space
	  between sections (its moduleSpacing), and the header's ask, which follows it in the same update, with 0. It
	  tells them apart by their order, counted afresh each frame (GetTime changes once per frame).
	- The block is anchored under the tracker's Header, 38 down from its top, where its first section would start
	  (the header's picture reaching 4 under its 32, the block's section-like header's 2 over its top: the two just
	  touch, as the tracker's own first section's do): the journal's frame anchored to theirs, never theirs to the
	  journal's.
	- The tracker never starved (the owner's test in The Stockade, 2026-11-12: a tracker moved in Edit Mode is as
	  high as its Height setting, 400 at the least, Container.lua UpdateHeight :207-221; the block's 352 left its Quests no
	  room for their header and first quest, so no section showed and the tracker hid itself, "All Objectives" with
	  it, Container.lua :117-127). Before it goes in, the room the tracker's height leaves under the block open at its
	  tallest this run is measured against what its first section needs (a section's header and its first quest as
	  the tracker last laid it out, only read; at the least a title and one objective line, from the client's numbers:
	  Room). Too short, and the block stays beside the tracker, /ij run debug saying why; a margin on the way in, none
	  on the way out, so it does not go back and forth.
	- A quest block cannot be shown in part: when the first quest grows taller while the block is inside (a quest of
	  three objective lines tracked on top, 0.39.21's review), the tracker can still hide itself. Seen at the next
	  placing (the tracker hidden, a section of its marked as having objectives but no room for them: its modules'
	  state, only read), the block steps beside the tracker and stays there until the room grows or the first quest
	  the tracker shows needs less than it did then (Starved).
	- A layout of the tracker's that hides it or shows it again (nothing tracked, a quest tracked, a padding change
	  that frees the room) has the block placed again the next frame, once: seen from the provider's own second ask,
	  at the end of that layout (the tracker's IsShown read there). No hook and no OnUpdate. While the tracker is
	  hidden, the block stays under where its header comes back (the padding kept), or, too short, above it or under
	  its frame: never on the header's spot.
	- The tracker learns of a new padding only when it lays itself out again; the client offers no event for that.
	  So when the padding changes (entering, leaving, collapsing the block, a taller block, a Text Size change), the
	  journal calls the tracker's MarkDirty() (the client's DirtiableMixin, Blizzard_SharedXML/MixinUtil.lua:346-352:
	  it schedules the tracker's own update for the next frame, as each of its sections does on each quest event),
	  and once more a moment later: the tracker works out the height its sections may fill from the padding of its
	  last layout, before it asks for the new one (Container.lua:74, then :77), so only its second layout fits them
	  to the new padding. Those and handing over the provider are the journal's only calls into the tracker; it never
	  calls its Update. The padding is kept still otherwise: the block open at its tallest this run (at this Text
	  Size), or its header alone when collapsed, so the tracker is told rarely.
	- The two asks are told apart by their order. If a layout of the tracker stops between them (an error in one of
	  its sections) and it lays itself out again in the same frame, the order is off by one for that frame and the
	  answers swapped: the header moved down, the sections not. The journal sees that at its next placing (its
	  1-second clock, a collapse) from the count left odd, and tells the tracker once, which sets it right.

	The risk, and why it is still marked a test: the provider is the journal's table, kept in the tracker's table,
	and its GetTopPadding runs inside every layout of the tracker. The rest of that layout then runs tainted by the
	journal (the 0.39.9 lesson: the journal's code inside the game's menus blocked SetRaidTarget). The tracker sets each
	quest item button's questLogIndex during that layout, and the button's click uses it (UseQuestLogSpecialItem); Edit
	Mode lays the tracker out too. MarkDirty is a write as well: called from the journal, it sets the tracker's own
	dirty flag and schedules its next update (RunNextFrame), both from the journal's code, so that next layout may run
	tainted from its start, and the tracker's own later MarkDirty calls read a flag the journal wrote (a best guess from
	the client's code, only while the provider is handed over). Whether the client then blocks anything is what the
	in-game test finds out (its Edit Mode and quest item steps).

	The tracker's height (the owner's test of 0.39.21: inside only once they raised its Height in Edit Mode). Moved in
	Edit Mode, the tracker is as high as its Edit Mode Height, math.max(editModeHeight or 800, the modules that must
	fit), Container.lua UpdateHeight :207-221; the setting is a slider from 400 to 1000 in steps of 10
	(EditModeSettingDisplayInfo.lua :609-618), kept in the layout as (Height - 400) / 10 (ConvertValueDefault, :8-14),
	and only a moved tracker has it (EditModeObjectiveTrackerSystemMixin:ShouldShowSetting). At its default spot it
	reaches down the screen. What the journal does about it, and why:
	- No Edit Mode code run as the journal's. Setting the Height in the running game means the Edit Mode system's own
	  code (UpdateSystemSettingValue writes the layout's table and the tracker's editModeHeight,
	  EditModeSystemTemplates.lua :268-287 and :2410-2413) run as the journal's: the tracker's next layouts and Edit
	  Mode's own Save would read values the journal wrote (tainted), the same risk as the provider's and more.
	  Counting the block in the tracker's height (a module that must fit) would mean adding the journal's frame to the
	  tracker's modules. Neither is done. Opening Edit Mode for the player is not done either
	  (ShowUIPanel(EditModeManagerFrame) from the journal runs EnterEditMode and every system frame's OnEditModeEnter,
	  the action bars' among them, as the journal's: EditModeManager.lua :94-106, :128-138).
	- The Height saved, never applied at once (0.39.22's research, Blizzard_EditMode/Shared/EditModeManager.lua): the
	  running game gives a layout to the tracker only through Edit Mode's UpdateLayoutInfo (:1010-1037: its
	  UpdateSystems, the tracker's UpdateSystemSettingHeight setting its editModeHeight, EditModeSystemTemplates.lua
	  :2410-2413). That runs from EDIT_MODE_LAYOUTS_UPDATED (OnEvent :192-201), PLAYER_SPECIALIZATION_CHANGED
	  (:202-208), an override layout (:1508-1525) and RevertAllChanges (:1670-1674) as Edit Mode closes (ExitEditMode
	  :116-126). The client sends EDIT_MODE_LAYOUTS_UPDATED at login and on C_EditMode.SetActiveLayout (Edit Mode's
	  SelectLayout, :1551-1557, applies a layout with that call alone), and the API's documentation marks it a
	  SynchronousEvent (EditModeManagerDocumentation.lua): sent from inside the call that caused it, so called from the
	  journal its handlers (the action bars' layout among them) would run as the journal's. Not done. SaveLayouts
	  applies nothing: Edit Mode's own SaveLayouts (:1655-1660) and ReconcileLayouts (:895-911, inside that event's
	  own handler) follow it with nothing that applies it, and nothing of the client's waits for an event after it (a
	  best guess: the call's C side cannot be read). So the new Height shows after a /reload, or when the player next
	  closes Edit Mode without saving there (opened before that, Edit Mode shows its own copy of the layout, and a
	  Save there writes that copy back over the journal's: one line in chat says so as it opens, and a copy saved
	  back is not taken for the player's set-back: "Edit Mode's own copy", below MakeTaller).
	- Saving it (HeightEntry, SaveHeight): C_EditMode.GetLayouts() (a new table, the journal's own: the player's saved
	  layouts) with the game's presets put first, from a copy of their own (EditModePresetLayoutManager's
	  GetCopyOfPresetLayouts, a CopyTable that writes nothing), as Edit Mode's UpdateLayoutInfo builds the list its
	  own SaveLayouts hands over (its activeLayout counts the presets: GetActiveLayoutInfo :1527-1533); the active
	  layout's Objective Tracker Height set in that copy; the copy handed to C_EditMode.SaveLayouts. Only the layout
	  Edit Mode has in use (the one at activeLayout, of the name and kind GetActiveLayoutInfo gives, only read), a
	  layout of the player's (not a preset or an override), the only one of its name and kind; never with Edit Mode
	  open (its own unsaved copy) or in combat. No table or frame of the game's UI is written, and nothing of Edit
	  Mode's code runs as the journal's but that CopyTable. What SaveLayouts is handed is the journal's table; what the
	  game reads back at the next login comes out of the client anew (GetLayouts makes new tables), not the journal's.
	- By itself, once (AutoTaller, since 0.39.22; the owner: "auto adjust the quest frames length size so you don't
	  have to in edit mode"): the first time a session the block stays beside a moved tracker too short for it, with
	  "Inside the quest tracker" ticked (off by default; off, the journal never touches the layout), out of combat,
	  with Edit Mode closed and its layouts loaded (else at a later placing), the Height it
	  needs saved, and one line in chat: the old Height and the new, the /reload, and that Edit Mode can set it back.
	  Not when the Height saved already fits (only the /reload missing: saved taller than the tracker runs now; Edit
	  Mode's most in use and still too short is past the most), not past Edit Mode's most (the button can still save
	  it; the advice line says it may still not fit), not for a layout it cannot save (the chat line and tooltip of
	  0.39.21 then), and once per need: the Height the journal last saved (by itself or by the button) is kept per
	  layout (an Account layout's for the account, a Character one's for the character), and a layout set lower than
	  that since is left as the player set it. A taller need later (a taller block, a larger Text Size) is a new need.
	- Telling the player otherwise: once a session, the first time the block stays beside a moved tracker too short
	  for it and nothing was saved, one line in chat with the Height it needs (WantedHeight); the same on the block's
	  header tooltip while it is so (once saved, that a /reload shows it); and the option's tip.
	- The button in the options, the player's own choice (MakeTaller): the same save whenever the player asks, out of
	  combat and with Edit Mode closed, a layout set back lower or not.

	The safety net: once the provider is handed over (the block inside once this session), ADDON_ACTION_BLOCKED and
	ADDON_ACTION_FORBIDDEN naming the journal turn the option off at once and for good (saved), with one line in chat
	naming the blocked function; the provider gives 0 and the block goes back beside the tracker at once, or when the
	fight ends if one is on. A /reload then takes the provider out of the tracker's list altogether. Off, by the
	safety net or by hand, the provider stays in that list until then (the client cannot take it out, and the journal
	does not write into the tracker's table) and is still asked on each layout, so the safety net keeps listening (and
	keeps what it hears for /ij run debug) as long as it is there, and unticking the box by hand says in chat that a
	/reload takes it out completely. Before the provider is handed over (since 0.39.22: the box ticked, the block not
	inside yet this session), nothing of the journal's is in the tracker, so a blocked action then is not the
	tracker's doing, and does not turn the option off: nothing is heard, but after the journal saved an Edit Mode
	layout this session, when what is heard is only kept, for /ij run debug.
]]

local Inside = {}
ns.RunTrackerInside = Inside
local Run, RunTracker = ns.Run, ns.RunTracker
RunTracker.inside = Inside

local EVENT = "ObjectiveTrackerContainerMixin.AddTopPaddingProvider"
-- The tracker's numbers (Blizzard_ObjectiveTrackerContainer.lua: BASE_TOP_PADDING, :15; its moduleSpacing, XML 10),
-- and its header's height (its template's 32), where the tracker has none to read.
local BASE_TOP, SPACING, HEADER = 38, 10, 32
-- The block's header inside: a section's ("Quests" look: UI/RunTracker.lua's STYLES and RunTracker.StyleFor).
local LOOK = RunTracker.STYLES.quests
-- The block's top under the tracker's header: its header's picture reaches 4 under it (40 high on its 32) and the
-- block's 2 over the block's top (the Quests look's over), so 6 apart they just touch: 38 down, where the
-- tracker's first section would start.
local DROP = 4 + LOOK.over
--[[
	What the tracker's first section needs to show at all (Blizzard_ObjectiveTrackerModule.lua's settings): its header
	(headerHeight 25), the 10 to its first entry (fromHeaderOffsetY), and that entry: a quest's title line and one
	objective line (both in ObjectiveTrackerLineFont: Blizzard_ObjectiveTrackerBlock.xml, at the line height the Text
	Size gives, read from the block's own line in that font) and the 4 between them (lineSpacing). A module that
	cannot fit that much shows nothing, and every one after it nothing either (Container.lua :112-114). MARGIN: more
	asked on the way in, so a tracker just tall enough does not have the block go in and out.
]]
local SECTION_HEADER, FIRST_ENTRY_GAP, LINE_SPACING, LINE = 25, 10, 4, 12
local MARGIN = 20
-- Edit Mode's Height slider for the tracker: its least, its most and its step (see the top of this file).
local HEIGHT_LEAST, HEIGHT_MOST, HEIGHT_STEP = 400, 1000, 10
-- The tracker told a second time, this long after the first (see the top of this file).
local TELL_AGAIN = 0.1
local OPTION_VARIABLE = "AEGIS_JOURNAL_RUN_INSIDE"

-- What the provider gives the tracker's sections now (0: nothing), and what it last gave each ask (for /ij run debug).
Inside.padding = 0
Inside.registered = false

------------------------------------------------------------------------------------------
-- The provider
------------------------------------------------------------------------------------------

local provider = {}
Inside.provider = provider
local askFrame, asks = nil, 0

-- The block placed again, the frame after a layout of the tracker's that hid it or showed it again.
local function PlaceAgain()
	Inside.placeDue = nil
	Inside.placedAgain = (Inside.placedAgain or 0) + 1
	if RunTracker.block and RunTracker.block:IsShown() then RunTracker:Place() end
end

-- Runs inside the tracker's own layout: a clock read and a count; at its second ask, at the end of the layout, the
-- tracker's IsShown read, and a timer made when that changed since the block was placed (once). Nothing else.
function provider:GetTopPadding()
	local now = GetTime()
	if now ~= askFrame then askFrame, asks = now, 0 end
	asks = asks + 1
	if asks % 2 == 0 then
		Inside.gaveHeader = 0
		if Inside.active and not Inside.placeDue then
			local tracker = ObjectiveTrackerFrame
			if tracker and (tracker:IsShown() == true) ~= Inside.placedShown then
				Inside.placeDue = true
				C_Timer.After(0, PlaceAgain)
			end
		end
		return 0
	end
	local padding = Inside.padding
	Inside.gaveSections = padding
	return padding
end

-- The tracker this client has, with its providers' list; nil where it has none (the 0.39.20 placing then).
local function Tracker()
	local tracker = ObjectiveTrackerFrame
	if not (tracker and type(tracker.topPaddingProviders) == "table" and tracker.Header) then return nil end
	if not (EventRegistry and EventRegistry.TriggerEvent) then return nil end
	return tracker
end

-- Handed to the tracker once, the first time the block goes in; true once the tracker has it.
function Inside:Register()
	if self.registered then return true end
	local tracker = Tracker()
	if not tracker then return false end
	EventRegistry:TriggerEvent(EVENT, provider)
	self.registered = tracker.topPaddingProviders[provider] == true
	self:Listen()
	return self.registered
end

-- The tracker told to lay itself out again, next frame, by its own update (MarkDirty: see the top of this file); and
-- once more a moment later, so its sections are fitted to the new padding too.
local function MarkTracker()
	local tracker = ObjectiveTrackerFrame
	if not (tracker and type(tracker.MarkDirty) == "function") then return false end
	tracker:MarkDirty()
	return true
end

function Inside:Tell()
	if not MarkTracker() then return end
	self.told = (self.told or 0) + 1
	if C_Timer and C_Timer.After then
		C_Timer.After(TELL_AGAIN, function()
			if Inside.registered then MarkTracker() end
		end)
	end
end

-- A layout of the tracker's that stopped between its two asks, in a frame now over: the count started afresh,
-- and the tracker told once if the swapped answers could have put anything out of place (see the top of this file).
function Inside:Mend()
	if asks % 2 == 0 or askFrame == GetTime() then return end
	asks = 0
	self.mended = (self.mended or 0) + 1
	if self.registered and self.padding > 0 then self:Tell() end
end

-- The padding for the tracker's sections. Handed over only when there is some to give; changed only when it
-- changes, and the tracker told then.
function Inside:SetPadding(value)
	value = math.ceil(value or 0)
	if value == self.padding then return end
	if value > 0 and not self:Register() then return end
	self.padding = value
	if self.registered then self:Tell() end
end

------------------------------------------------------------------------------------------
-- Where the block goes
------------------------------------------------------------------------------------------

-- On: the box ticked, or ticked until the safety net turned it off in a fight that is not over yet.
function Inside:On()
	if Run:Option("inside") then return true end
	return self.offAfterFight == true and InCombatLockdown() == true
end

-- The block's open height to leave room for: its tallest this run, at this Text Size (its line height); so a kill
-- that shortens a long dungeon's lines leaves the room as it was, and only a taller block or a new Text Size
-- changes it.
function Inside:Tallest(owner, view)
	local line = owner.block.Dash:GetStringHeight() or 0
	if self.tallestRun ~= view.run or self.tallestLine ~= line then
		self.tallestRun, self.tallestLine, self.tallest = view.run, line, 0
		self.fits = nil
	end
	-- (in the Quests look it has inside, whatever look it has before it goes in)
	self.tallest = math.max(self.tallest, owner:OpenHeightIn(LOOK))
	return self.tallest
end

-- The block's frame level over the tracker's (its background is drawn at the tracker's own level); put back as
-- it was when the block leaves.
local function Raise(block, tracker)
	if Inside.baseLevel == nil then Inside.baseLevel = block:GetFrameLevel() end
	local level = (tracker:GetFrameLevel() or 0) + 2
	if block:GetFrameLevel() ~= level then block:SetFrameLevel(level) end
end

local function Lower(block)
	if Inside.baseLevel ~= nil and block then block:SetFrameLevel(Inside.baseLevel) end
	Inside.baseLevel = nil
end

-- One of the tracker's layout numbers, only read; the client's where it has none.
local function TrackerNumber(tracker, key, default)
	local value = tracker[key]
	return type(value) == "number" and value >= 0 and value or default
end

--[[
	The room the tracker's height leaves its sections under the block open at its tallest (see the top of this file):
	its height (only read: Edit Mode's Height where it was moved, else down to the screen's bottom), less the padding
	its sections would start under (38, any other addon's padding as the tracker last added it up, the block's),
	against what its first section needs. Returns left, need (without the margin), height; nil where the tracker's
	height is not known yet.
]]
-- What the first section the tracker shows needs, as its last layout laid it out (its header, the gap to its first
-- entry and that entry's height: the client's CanFitBlock); nil where it shows none or keeps none of it. Only read.
local function FirstShown(tracker)
	local modules = tracker.modules
	if type(modules) ~= "table" then return nil end
	for _, module in ipairs(modules) do
		local first = type(module) == "table" and module.firstBlock
		if type(first) == "table" and type(first.height) == "number" then
			local header = TrackerNumber(module, "headerHeight", SECTION_HEADER)
			local gap = type(module.fromHeaderOffsetY) == "number" and math.abs(module.fromHeaderOffsetY) or FIRST_ENTRY_GAP
			return header + gap + first.height
		end
	end
	return nil
end

--[[
	The tracker hidden by its own layout although something is tracked: a section with objectives and no room for its
	first one (the client's ObjectiveTrackerModuleState.NotShown), so it and every one after it showed nothing. Only
	read.
]]
local function Starved(tracker)
	local states, modules = ObjectiveTrackerModuleState, tracker.modules
	if tracker:IsShown() or type(states) ~= "table" or states.NotShown == nil or type(modules) ~= "table" then
		return false
	end
	for _, module in ipairs(modules) do
		if type(module) == "table" and module.state == states.NotShown then return true end
	end
	return false
end

function Inside:Room(owner, tracker, padding)
	local height = tracker:GetHeight()
	if type(height) ~= "number" or height <= 0 then return nil end
	local line = owner.block.Dash:GetStringHeight() or 0
	if line <= 0 then line = LINE end
	local need = math.max(SECTION_HEADER + FIRST_ENTRY_GAP + line + LINE_SPACING + line, FirstShown(tracker) or 0)
	-- Other addons' padding, as the tracker last added it up (its topModulePadding less what this provider gave).
	local others = math.max(BASE_TOP, TrackerNumber(tracker, "topModulePadding", BASE_TOP) - (self.gaveSections or 0))
	return height - others - padding, need, height
end

--[[
	The room for the block open at its tallest this run, collapsed or not, so a collapse never takes it in or out: the
	tracker's sections start where the block ends (DROP under the header) and the tracker's space between sections.
	Returns Room's left, need and height, and the header's height, the spacing and the tallest, for the padding.
]]
function Inside:Measure(owner, tracker)
	local headerHeight = tracker.Header:GetHeight()
	if type(headerHeight) ~= "number" or headerHeight <= 0 then headerHeight = HEADER end
	local spacing = TrackerNumber(tracker, "moduleSpacing", SPACING)
	local tallest = self:Tallest(owner, owner.view)
	local left, need, height = self:Room(owner, tracker, headerHeight + DROP - BASE_TOP + tallest + spacing)
	return left, need, height, headerHeight, spacing, tallest
end

-- The tracker at its default spot (Edit Mode's own test), where it has no Height to set. Only read.
local function AtDefaultSpot(tracker)
	if type(tracker.IsInDefaultPosition) ~= "function" then return false end
	local ok, default = pcall(tracker.IsInDefaultPosition, tracker)
	return ok and default == true
end

-- The Edit Mode Height that holds the block inside a tracker of this height with this room: what is missing and the
-- margin, rounded up to the slider's steps; nil where nothing is missing. The second value: past the slider's most
-- (the Height then its most, which may still be too short).
local function WantedHeight(left, need, height)
	if not (left and need and height) then return nil end
	local short = need + MARGIN - left
	if short <= 0 then return nil end
	local wanted = math.ceil((height + short) / HEIGHT_STEP) * HEIGHT_STEP
	return math.max(HEIGHT_LEAST, math.min(HEIGHT_MOST, wanted)), wanted > HEIGHT_MOST
end
Inside.WantedHeight = WantedHeight

-- While the block stays beside a moved tracker too short for it (the experiment on): the Height it needs; else nil.
function Inside:Wanted()
	local room, tracker = self.room, Tracker()
	if not (self.active and self.fits == false and room and tracker) or AtDefaultSpot(tracker) then return nil end
	return WantedHeight(room.left, room.need, room.height)
end

-- The game's own names for Edit Mode, its Objective Tracker and its Height, where it has them.
local function EditModeNames()
	return HUD_EDIT_MODE_MENU or "Edit Mode", HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL or "Objective Tracker",
		HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_HEIGHT or "Height"
end

-- A Height saved this session (by the button or by itself) that holds the block: only the /reload missing.
function Inside:SavedFits(wanted)
	return self.savedHeight ~= nil and wanted ~= nil and self.savedHeight >= wanted
end

-- The block's header tooltip's line while it stays beside a tracker too short for it: how to make room, or, a Height
-- that fits saved already, that a /reload shows it.
function Inside:ShortText()
	local wanted, past = self:Wanted()
	if not wanted then return nil end
	local editMode, tracker, height = EditModeNames()
	if self:SavedFits(wanted) then return string.format(L.RUN_INSIDE_SAVED_TIP, height, self.savedHeight) end
	return string.format(L.RUN_INSIDE_SHORT_TIP, editMode, tracker, height, wanted) .. (past and " " .. L.RUN_TALLER_MOST or "")
end

-- Once a session, the first time the block stays beside a moved tracker too short for it and nothing that fits is
-- saved: one line in chat saying the Height it needs and where to set it (past Edit Mode's most: that it may still
-- not fit).
function Inside:TellShort()
	if self.toldShort or not Run:Option("inside") then return end
	local wanted, past = self:Wanted()
	if not wanted or self:SavedFits(wanted) then return end
	self.toldShort = true
	local editMode, tracker, height = EditModeNames()
	ns.Print(string.format(L.RUN_INSIDE_SHORT, editMode, tracker, height, wanted, L.OPTIONS_RUN_TALLER)
		.. (past and " " .. L.RUN_TALLER_MOST or ""))
end

--[[
	Called by RunTracker:Place with the block's points cleared. The experiment on, the block shown (a run inside, a run
	left behind or the last run shown outside; "Place it freely" ticked or not: this test option wins over it since
	0.39.23, when free became the default, RunTracker:Free), the tracker tall enough: the padding set, and the
	block anchored under the tracker's header (true, and the placing's name: "inside", or "inside (tracker hidden)"
	while nothing is tracked). Otherwise the padding back to 0 (false: the 0.39.20 placing; with self.active, the
	tracker too short, never on its header's spot while it is hidden: RunTracker:Anchor). self.reason says why, for
	/ij run debug.
]]
function Inside:Place(owner, block)
	self:Listen()
	if self.registered then self:Mend() end
	local view = owner.view
	-- (off: nothing of the tracker's read, as 0.39.20)
	local tracker = self:On() and view and Tracker()
	if not tracker then
		self:Release(block)
		self.reason = not self:On() and "the experiment off"
			or not view and "nothing shown" or "no tracker to go into"
		return false
	end
	self.active = true
	self.placedShown = tracker:IsShown() == true
	local header = tracker.Header
	local left, need, height, headerHeight, spacing, tallest = self:Measure(owner, tracker)
	self.room = { height = height, left = left, need = need }
	-- Hidden by its own layout with the block inside although a quest is tracked: starved after all (see the top of
	-- this file). Kept until the room grows, or the first quest the tracker shows, once it shows again beside the
	-- block, needs less than it did then.
	local starved = self.starved
	if left and self.padding > 0 and Starved(tracker) then
		starved = { left = left }
		self.starvedCount = (self.starvedCount or 0) + 1
	elseif starved and left and (left > starved.left or (self.placedShown and starved.need and need < starved.need)) then
		starved = nil
	elseif starved and self.placedShown and not starved.need then
		starved.need = need
	end
	self.starved = starved
	if left and (starved or left < need + (self.fits and 0 or MARGIN)) then
		self.fits = false
		self:Release(block)
		self.active = true
		self.reason = starved and "the tracker hid itself with the block inside (its first quest needs more room than "
			.. "is left under the block): give it more Height in Edit Mode"
			or "the tracker too short for the block inside: give it more Height in Edit Mode"
		-- The Height saved by itself, once (AutoTaller); its own line in chat then. Waiting (a fight, Edit Mode
		-- open): no line yet, the next placing tries again. Never for test mode's pretend run (UI/TestRun.lua): the
		-- test saves nothing, the player's Edit Mode layout least of all.
		local auto = not view.test and self:AutoTaller() or nil
		if auto == "saved" then
			self.toldShort = true
		elseif auto ~= "waiting" then
			self:TellShort()
		end
		return false
	end
	self.fits = true
	local open = owner:Collapsed(view) and LOOK.height or tallest
	self:SetPadding(headerHeight + DROP - BASE_TOP + open + spacing)
	if not self.registered then
		self.reason = "the tracker did not take the provider"
		Lower(block)
		return false
	end
	-- Nothing tracked, so no tracker on screen: under where its header comes back all the same, the room kept for its
	-- sections, so nothing of it can come back under the block.
	block:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -DROP)
	Raise(block, tracker)
	if self.placedShown and header:IsShown() then
		self.reason = "inside"
		return true, "inside"
	end
	self.reason = "inside, the tracker hidden (nothing tracked): under where its header comes back"
	return true, "inside (tracker hidden)"
end

-- The block hidden or placed beside the tracker: no room asked of it.
function Inside:Release(block)
	self.active = nil
	self:SetPadding(0)
	Lower(block)
end

------------------------------------------------------------------------------------------
-- The tracker's Height saved: by itself once, and the player's own button (see the top of this file)
------------------------------------------------------------------------------------------

-- Edit Mode open (its own test), only read.
local function EditModeOpen()
	local manager = EditModeManagerFrame
	if type(manager) ~= "table" or type(manager.IsEditModeActive) ~= "function" then return false end
	local ok, open = pcall(manager.IsEditModeActive, manager)
	return ok and open == true
end

--[[
	The player's Edit Mode layouts as Edit Mode's own save hands them over, in a copy of the journal's own (see the top
	of this file): C_EditMode.GetLayouts() with the game's presets put first (EditModePresetLayoutManager's
	GetCopyOfPresetLayouts, as UpdateLayoutInfo builds them); in it the layout in use (at activeLayout, of the name and
	kind EditModeManagerFrame:GetActiveLayoutInfo gives, only read) and its Objective Tracker's Height setting. Returns
	that copy, the layout and the setting's entry; or nil and why: no such API, Edit Mode's layouts not loaded yet
	("not ready", tried again later), a layout of the game's own (a preset or an override, which cannot be saved), two
	of that name and kind, the one in use not where Edit Mode keeps it, no Height setting in it.
]]
local NOT_READY = "Edit Mode's layouts not loaded yet"
-- A layout's Objective Tracker Height setting (its entry in the layout's table), where it has one.
local function HeightSetting(layout)
	local system, setting = Enum.EditModeSystem.ObjectiveTracker, Enum.EditModeObjectiveTrackerSetting.Height
	local entry
	for _, info in ipairs(type(layout.systems) == "table" and layout.systems or {}) do
		if type(info) == "table" and info.system == system and type(info.settings) == "table" then
			for _, value in ipairs(info.settings) do
				if type(value) == "table" and value.setting == setting and type(value.value) == "number" then entry = value end
			end
		end
	end
	return entry
end

local function HeightEntry()
	local api, enum, manager, presets = C_EditMode, Enum, EditModeManagerFrame, EditModePresetLayoutManager
	if not (type(api) == "table" and type(api.GetLayouts) == "function" and type(api.SaveLayouts) == "function"
		and type(enum) == "table" and type(enum.EditModeSystem) == "table"
		and type(enum.EditModeObjectiveTrackerSetting) == "table" and type(enum.EditModeLayoutType) == "table"
		and type(manager) == "table" and type(manager.GetActiveLayoutInfo) == "function"
		and type(presets) == "table" and type(presets.GetCopyOfPresetLayouts) == "function") then
		return nil, "no Edit Mode API"
	end
	local kinds = enum.EditModeLayoutType
	local system, setting = enum.EditModeSystem.ObjectiveTracker, enum.EditModeObjectiveTrackerSetting.Height
	if system == nil or setting == nil or kinds.Preset == nil then return nil, "no Edit Mode API" end
	local ok, active = pcall(manager.GetActiveLayoutInfo, manager)
	if not ok then return nil, "no Edit Mode API" end
	if not (type(active) == "table" and type(active.layoutName) == "string") then return nil, NOT_READY end
	if active.layoutType == kinds.Preset or (kinds.Override ~= nil and active.layoutType == kinds.Override) then
		return nil, "a layout of the game's own"
	end
	local got, layouts = pcall(api.GetLayouts)
	if not (got and type(layouts) == "table" and type(layouts.layouts) == "table") then return nil, "no layouts" end
	local copied, preset = pcall(presets.GetCopyOfPresetLayouts, presets)
	if not (copied and type(preset) == "table") then return nil, "no presets" end
	local all, named = {}, 0
	for _, layout in ipairs(preset) do all[#all + 1] = layout end
	for _, layout in ipairs(layouts.layouts) do
		if type(layout) ~= "table" or layout.layoutType == kinds.Preset then return nil, "an odd layout" end
		if layout.layoutName == active.layoutName and layout.layoutType == active.layoutType then named = named + 1 end
		all[#all + 1] = layout
	end
	if named > 1 then return nil, "two layouts of that name" end
	local found = type(layouts.activeLayout) == "number" and all[layouts.activeLayout] or nil
	if not (named == 1 and type(found) == "table" and found.layoutType ~= kinds.Preset
		and found.layoutName == active.layoutName and found.layoutType == active.layoutType) then
		return nil, "the layout in use not found"
	end
	local entry = HeightSetting(found)
	if not entry then return nil, "no Height in it" end
	layouts.layouts = all
	return layouts, found, entry
end

-- The Height a layout's entry keeps.
local function EntryHeight(entry) return HEIGHT_LEAST + entry.value * HEIGHT_STEP end

-- The Heights the journal saved itself, kept per layout: an Account layout's for the account, a Character one's for
-- the character (its own layouts). The table only made when one is saved.
local function Saved(layout, make)
	local character = Enum.EditModeLayoutType.Character ~= nil and layout.layoutType == Enum.EditModeLayoutType.Character
	local db = character and ns.charDB or ns.db
	if not db then return nil end
	if make and not db.runInsideHeights then db.runInsideHeights = {} end
	return db.runInsideHeights, tostring(layout.layoutType) .. ":" .. tostring(layout.layoutName)
end

--[[
	The Height wanted written into the copy (HeightEntry's) and handed to the client (the journal's table), and kept as
	the Height the journal last saved for that layout (the button's too, lower or not: the last change is the
	journal's own). Until a /reload or Edit Mode closing gives it to the tracker, it waits (self.pending: see Edit
	Mode's own copy below), and the safety net listens, only keeping what it hears. Returns the Height the layout had,
	or nil where the client refused it.
]]
local function Write(layouts, layout, entry, wanted)
	local old = EntryHeight(entry)
	entry.value = (wanted - HEIGHT_LEAST) / HEIGHT_STEP
	if not pcall(C_EditMode.SaveLayouts, layouts) then return nil end
	local saved, key = Saved(layout, true)
	if saved then saved[key] = wanted end
	Inside.savedHeight = wanted
	Inside.pending = { layoutName = layout.layoutName, layoutType = layout.layoutType, height = wanted, old = old }
	Inside.layoutSaved = true
	Inside:Listen()
	return old
end

-- The button's save: returns the layout's name and the Height it had, or nil where it cannot be done.
local function SaveHeight(wanted)
	local layouts, layout, entry = HeightEntry()
	if not layouts then return nil end
	local old = Write(layouts, layout, entry, wanted)
	if not old then return nil end
	return layout.layoutName, old
end

--[[
	By itself, once (see the top of this file): called by Place while the block stays beside a moved tracker too short
	for it. Returns "saved" (one line in chat said so), "waiting" (in a fight, Edit Mode open or its layouts not loaded:
	tried again at a later placing) or nil (nothing, this session: why in self.autoWhy, for /ij run debug).
]]
function Inside:AutoTaller()
	if self.autoDone or not Run:Option("inside") then return nil end
	local wanted, past = self:Wanted()
	if not wanted then return nil end
	if InCombatLockdown() then
		self.autoWhy = "waiting for the fight to end"
		return "waiting"
	end
	if EditModeOpen() then
		self.autoWhy = "waiting for Edit Mode to close"
		return "waiting"
	end
	local layouts, layout, entry = HeightEntry()
	if not layouts and layout == NOT_READY then
		self.autoWhy = "waiting: " .. NOT_READY
		return "waiting"
	end
	self.autoDone = true
	if not layouts then
		self.autoWhy = "not saved: " .. tostring(layout)
		return nil
	end
	local had = EntryHeight(entry)
	-- Saved already and taller than the tracker runs now: only the /reload missing. At or under what it runs (Edit
	-- Mode's most in use and the block still too tall), a /reload gives nothing: past the most, below.
	if had >= wanted and had > (self.room and self.room.height or 0) then
		self.savedHeight = math.max(self.savedHeight or 0, had)
		self.autoWhy = string.format("not needed: Height %d saved already (seen after a /reload)", had)
		return nil
	end
	if past then
		self.autoWhy = string.format("not saved: more than Edit Mode's most (%d) is needed", wanted)
		return nil
	end
	local saved, key = Saved(layout)
	local mine = saved and saved[key]
	if mine and had < mine then
		self.autoWhy = string.format("not saved: Height set back to %d after the journal saved %d, left as set", had, mine)
		return nil
	end
	if not Write(layouts, layout, entry, wanted) then
		self.autoWhy = "not saved: the client refused it"
		return nil
	end
	self.autoSaved = (self.autoSaved or 0) + 1
	self.autoWhy = string.format("Height %d saved (it was %d)", wanted, had)
	local editMode, _, heightName = EditModeNames()
	ns.Print(string.format(L.RUN_INSIDE_AUTO, heightName, had, wanted, layout.layoutName, editMode))
	return "saved"
end

--[[
	The options' "Make taller" button: "Inside the quest tracker" ticked, out of combat, Edit Mode closed, a moved
	tracker, the block shown (its height is what is measured): the Height the block needs inside, saved into the
	player's layout (SaveHeight), and one line in chat saying what was written, or why nothing was. The running game
	sees it after a /reload.
]]
function Inside:MakeTaller()
	if not Run:Option("inside") then
		ns.Print(L.OPTIONS_RUN_TALLER_TIP)
		return
	end
	local editMode, trackerName, heightName = EditModeNames()
	if InCombatLockdown() then
		ns.Print(L.RUN_TALLER_COMBAT)
		return
	end
	if EditModeOpen() then
		ns.Print(string.format(L.RUN_TALLER_EDIT_MODE, editMode))
		return
	end
	local tracker = Tracker()
	if tracker and AtDefaultSpot(tracker) then
		ns.Print(L.RUN_TALLER_DEFAULT)
		return
	end
	local left, need, height
	if tracker and RunTracker.block and RunTracker.view then left, need, height = self:Measure(RunTracker, tracker) end
	if not left then
		ns.Print(L.RUN_TALLER_UNKNOWN)
		return
	end
	local wanted, past = WantedHeight(left, need, height)
	if not wanted then
		ns.Print(L.RUN_TALLER_ENOUGH)
		return
	end
	local name = SaveHeight(wanted)
	if not name then
		ns.Print(string.format(L.RUN_TALLER_FAILED, editMode, trackerName, heightName, wanted))
		return
	end
	ns.Print(string.format(L.RUN_TALLER_DONE, trackerName, heightName, wanted, name) .. (past and " " .. L.RUN_TALLER_MOST or ""))
end

--[[
	Edit Mode's own copy of the layouts (0.39.22's review; Blizzard_EditMode/Shared/EditModeManager.lua): opening Edit
	Mode reloads none (EnterEditMode :98-106), and its Save (SaveLayoutChanges :1662-1667, SaveLayouts :1655-1660), as
	a rename (:1607-1615) or a deletion (:1591-1598), hands over the copy it loaded at its last UpdateLayoutInfo: before
	a /reload, the tracker's old Height, written back over the journal's. Closing it (ExitEditMode :116-126) loads the
	layouts again (RevertAllChanges :1670-1674), the journal's Height then given to the tracker at once. So, while a
	Height the journal saved waits (self.pending), heard from EventRegistry (its TriggerEvent calls each callback
	through securecallfunction, CallbackRegistry.lua :198-214), only read:
	- "EditMode.Enter" (:105): one line in chat, once a session: Edit Mode still shows the old Height, and saving
	  there puts it back; the Height Edit Mode opened with (the tracker's editModeHeight, only read) kept.
	- "EditMode.SavedLayouts" (:1659, after its C_EditMode.SaveLayouts): the layout's Height read back from the client
	  (GetLayouts: a new table). The journal's or taller: nothing. The very Height Edit Mode opened with: its old copy
	  saved over the journal's, not a choice of the player's, so the journal's record of it dropped (the next session
	  saves it once more, by itself: a best guess at what the player meant, untouched). Another Height, lower: the
	  player's own, kept as set (a set-back).
	- "EditMode.Exit" (:124): the tracker's Height read; the journal's there, it no longer waits.
]]
local function LayoutHeight(name, kind)
	local api = C_EditMode
	if not (type(api) == "table" and type(api.GetLayouts) == "function") then return nil end
	local ok, layouts = pcall(api.GetLayouts)
	if not (ok and type(layouts) == "table" and type(layouts.layouts) == "table") then return nil end
	for _, layout in ipairs(layouts.layouts) do
		if type(layout) == "table" and layout.layoutName == name and layout.layoutType == kind then
			local entry = HeightSetting(layout)
			return entry and EntryHeight(entry)
		end
	end
	return nil
end

-- The tracker's Edit Mode Height as Edit Mode last gave it, only read.
local function TrackerEditModeHeight()
	local tracker = ObjectiveTrackerFrame
	local height = tracker and tracker.editModeHeight
	return type(height) == "number" and height or nil
end

function Inside:EditModeEntered()
	local pending = self.pending
	if not pending then return end
	local running = TrackerEditModeHeight()
	if running and running >= pending.height then
		self.pending = nil
		return
	end
	pending.stale = running or pending.old
	if self.warnedStale then return end
	self.warnedStale = true
	local editMode, _, heightName = EditModeNames()
	ns.Print(string.format(L.RUN_INSIDE_EDIT_MODE_OLD, editMode, heightName))
end

function Inside:EditModeSaved()
	local pending = self.pending
	if not pending then return end
	local now = LayoutHeight(pending.layoutName, pending.layoutType)
	if now and now >= pending.height then return end
	self.pending, self.savedHeight = nil, nil
	if not now then
		self.autoWhy = "the layout saved is gone from Edit Mode (renamed or deleted)"
		return
	end
	if now == (pending.stale or pending.old) then
		local saved, key = Saved(pending)
		if saved and saved[key] == pending.height then saved[key] = nil end
		self.autoWhy = string.format("undone: Edit Mode saved its old copy (Height %d) over it before a /reload; "
			.. "saved once more next session", now)
	else
		self.autoWhy = string.format("set to %d in Edit Mode before a /reload, left as set", now)
	end
end

function Inside:EditModeExited()
	local pending, running = self.pending, TrackerEditModeHeight()
	if pending and running and running >= pending.height then self.pending = nil end
end

if EventRegistry and EventRegistry.RegisterCallback then
	EventRegistry:RegisterCallback("EditMode.Enter", function() Inside:EditModeEntered() end, Inside)
	EventRegistry:RegisterCallback("EditMode.SavedLayouts", function() Inside:EditModeSaved() end, Inside)
	EventRegistry:RegisterCallback("EditMode.Exit", function() Inside:EditModeExited() end, Inside)
end

------------------------------------------------------------------------------------------
-- The safety net
------------------------------------------------------------------------------------------

local events = CreateFrame("Frame")
Inside.events = events
local SAFETY_EVENTS = { "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN" }

-- The client's blocked and forbidden actions heard from the moment the provider is handed over to the tracker, for as
-- long as it is in the tracker's list (until a /reload), the option on or off. Before that (the block never inside
-- this session, the option off or on), nothing of the journal's is in the tracker: nothing heard, but after the
-- journal saved an Edit Mode layout this session (by itself or by the button), when what is heard is only kept, for
-- /ij run debug (the save's own risk: a best guess that it has none, see the top of this file).
function Inside:Listen()
	local on = self.registered == true or self.layoutSaved == true
	if on and not self.listening then
		ns.RegisterEvents(events, unpack(SAFETY_EVENTS))
	elseif not on and self.listening then
		ns.UnregisterEvents(events, unpack(SAFETY_EVENTS))
	end
	self.listening = on or nil
end

local function NotifyOption()
	if Settings and Settings.NotifyUpdate then pcall(Settings.NotifyUpdate, OPTION_VARIABLE) end
end

-- The box ticked or unticked by hand (UI/Options.lua). Unticked after the provider was handed over: one line in chat
-- saying a /reload takes it out of the tracker completely.
function Inside:SetByHand(on)
	local was = Run:Option("inside")
	Run:SetOption("inside", on)
	if was and not on and self.registered then ns.Print(L.RUN_INSIDE_RELOAD) end
end

--[[
	The journal named by the client as the one whose action it blocked (the events' payload: the addon's name, then
	the function's; Blizzard_APIDocumentationGenerated/RestrictedActionsDocumentation.lua). Kept for /ij run debug
	at once. The client sends these events from inside the blocked call (SynchronousEvent), so the rest waits for the
	next frame, out of it: the experiment turned off and saved off, one line in chat, and the block back beside the
	tracker then, or when the fight ends if one is on. Heard with the box already off (the provider still in the
	tracker's list), it is only kept.
]]
function Inside:Blocked(event, func)
	local seen = { event = event, func = tostring(func or "?"), at = time() }
	if not self.registered then seen.afterSave = true end
	self.blocked = seen
	if ns.db then ns.db.runInsideBlocked = seen end
	-- Heard only for an Edit Mode save (the provider never handed over): kept, the option left as it is.
	if not self.registered or self.turningOff then return end
	self.turningOff = true
	C_Timer.After(0, function()
		self.turningOff = nil
		if not Run:Option("inside") then return end
		if InCombatLockdown() then
			self.offAfterFight = true
			events:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
		Run:SetOption("inside", false)
		NotifyOption()
		ns.Print(string.format(L.RUN_INSIDE_BLOCKED, self.blocked.func))
	end)
end

events:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		events:UnregisterEvent("PLAYER_REGEN_ENABLED")
		Inside.offAfterFight = nil
		RunTracker:Refresh()
		Inside:Listen()
	elseif event == "PLAYER_LOGIN" then
		events:UnregisterEvent("PLAYER_LOGIN")
		Inside.blocked = ns.db and ns.db.runInsideBlocked or nil
		Inside:Listen()
	else
		local name, func = ...
		if name == addonName then Inside:Blocked(event, func) end
	end
end)
events:RegisterEvent("PLAYER_LOGIN")
Run:OnChange(function() Inside:Listen() end)

------------------------------------------------------------------------------------------
-- /ij run debug
------------------------------------------------------------------------------------------

-- The tracker as the block finds it, only read: shown or not, its height, Edit Mode's Height for it where it was
-- moved (EditModeObjectiveTrackerSystemMixin keeps it on the tracker: editModeHeight), and the room under the block.
function Inside:TrackerText()
	local tracker = Tracker()
	if not tracker then return "tracker: none" end
	local height = tracker:GetHeight()
	local ok, default = false, nil
	if tracker.IsInDefaultPosition then ok, default = pcall(tracker.IsInDefaultPosition, tracker) end
	local spot = ok and default == true and "its default spot" or type(tracker.editModeHeight) == "number"
		and string.format("moved, Edit Mode Height %d", tracker.editModeHeight) or "Edit Mode Height not known"
	local room = self.room
	local roomText = "room under the block not measured"
	if room and room.left then
		roomText = string.format("room under the block %d (its first section needs %d, and %d more to go in)",
			math.floor(room.left), room.need, MARGIN)
	end
	local wanted = self:Wanted()
	if wanted then roomText = roomText .. string.format("; Edit Mode Height wanted %d", wanted) end
	if self.savedHeight then roomText = roomText .. string.format("; Height %d saved (seen after a /reload)", self.savedHeight) end
	if self.pending then
		roomText = roomText .. string.format("; waiting for a /reload (Edit Mode opened with %s)", tostring(self.pending.stale or "-"))
	end
	if self.autoWhy then roomText = roomText .. "; saved by itself: " .. self.autoWhy end
	return string.format("tracker: %s, height %s (%s); %s", tracker:IsShown() and "shown" or "hidden (nothing tracked)",
		type(height) == "number" and tostring(math.floor(height + 0.5)) or "?", spot, roomText)
end

function Inside:DebugText()
	local blocked = self.blocked
	local seen = "none"
	if blocked then
		seen = string.format("%s (%s, %s%s)", blocked.func, blocked.event,
			date and date("%Y-%m-%d %H:%M:%S", blocked.at or 0) or tostring(blocked.at),
			blocked.afterSave and ", after the journal's Edit Mode save, the block never inside" or "")
	end
	local net = not self.listening and "not listening" or self.registered and "listening"
		or "listening, only keeping (an Edit Mode layout saved this session)"
	return string.format("inside the tracker: %s%s; %s; padding %d (last given: sections %s, header %s; tracker told %d times, %d set right, block placed again %d times); safety net %s; blocked action seen: %s; why: %s; %s",
		Run:Option("inside") and "on" or "off", self.offAfterFight and " (off after this fight)" or "",
		self.registered and "provider handed over (until /reload)" or "no provider", self.padding,
		tostring(self.gaveSections or "-"), tostring(self.gaveHeader or "-"), self.told or 0, self.mended or 0,
		self.placedAgain or 0, net, seen, tostring(self.reason or "-"),
		self:TrackerText())
end
