local _, ns = ...
local L = ns.L

--[[
	A dungeon run, for the run block (UI/RunTracker.lua): when it started, when its clock stopped, and what it
	brought in. Kept with the character (AegisJournalCharDB.run), so a /reload or a login inside keeps it, and the
	run before it as AegisJournalCharDB.lastRun, for /ij run outside.

	What a run is, is the dungeon map's (UI/DungeonMap.lua): it decides on entering whether this is a new run (from
	outside, not a ghost, not a login or /reload, away longer than SAME_RUN_SECONDS, or after a reset), clears its
	kills and tells this file (Run:Entered). Its kills are the map's too: every kill the map marks comes here
	(Run:Killed), so the block's circles, its lines and the map's crosses agree. A run is tied to one copy of the
	dungeon (Run.SameCopy): the parts walked between inside (Blackrock Spire's, Dire Maul's: oneCopy in Data/Authored/
	RunTracker.lua) are one, so a wing change there keeps the run and a new run clears the kills of every part
	(DungeonMap:ClearRun); Scarlet Monastery's wings, each behind its own door, are each their own, though the client
	gives them one instance id: so the run there is decided once the wing is known, at its first named area or its
	first fight (Run:WaitForWing; a new run in another wing than the run's, since 0.39.23). Stratholme, two pages until
	0.39.22, is one dungeon with two doors: one run, whichever door it is entered by.

	The clock: from the first pull (the owner's call of 2026-11-14, from a player's wish not to have it tick at the door
	while the group gathers), to the kill of the dungeon's final boss (Data/Authored/RunTracker.lua, best guesses), else
	to the kill of the last boss counted. Until the first pull it waits at 0:00 (startedAt nil). The first pull is the
	first of (Run:Pull, Run:WatchPull): the player entering combat inside (PLAYER_REGEN_DISABLED), a groupmate in sight
	entering combat (UNIT_FLAGS on a party or raid unit, UnitAffectingCombat and UnitIsVisible: in sight, so in the same
	dungeon), the start of a boss fight (ENCOUNTER_START, also for a groupmate's pull far ahead), or a kill the map marks;
	a player or groupmate already in a fight when the run is decided counts as a pull then. A run joined late with kills
	already (the map's) starts its clock at once. The two pull events are listened to only inside, while the clock
	waits (or, in a Scarlet Monastery wing not known yet, until a pull is noted: Run:WaitForWing). The player can also
	start it before the first pull, pause it and resume it (Run:ToggleClock, the block's button: UI/RunTracker.lua); a
	paused clock stays paused across a /reload or a logout (pausedAt is kept with the run) until the player resumes it,
	and the time it was paused is not counted (pausedSeconds). Its one line in chat comes
	SUMMARY_DELAY seconds after the clock stops, so that the final boss's loot is in it, or as the player leaves the
	dungeon, whichever is first (the owner's call at the 0.39.20 release): its time is kept with the run (summaryAt),
	so a /reload or a logout in between neither loses it nor gives it twice (run.told). Time logged out is not counted (the
	gap from PLAYER_LOGOUT to the next login is added to pausedSeconds, while the clock runs: waiting or paused, it is
	not running anyway; the part of it after the player was last inside is kept apart as pausedAway, and given back if
	the run is left behind, as its clock ends at lastInsideAt, before that gap); deaths, corpse runs and stepping out are.

	The numbers count only while inside the run's dungeon (or a Scarlet Monastery wing still waited for, counted
	apart: Counts), with the block on (its events are registered there and nowhere else):
	- Experience: each rise of UnitXP; a fall is a level gained (the old level's rest, then the new XP).
	- Coin looted: a rise of GetMoney paired one to one, within MONEY_WINDOW seconds either way, with the client's
	  line for coin the player loots (YOU_LOOT_MONEY, LOOT_MONEY_SPLIT: a party's split is the share received).
	  The amount is GetMoney's, so it is exact in any language. Nothing while a merchant, mailbox, trade or
	  auction window is open.
	- Items: every item the player receives as loot (LOOT_ITEM_SELF_MULTIPLE, then LOOT_ITEM_SELF), with its vendor
	  price (C_Item.GetItemInfo's sellPrice) times the count. Quest items count 0. One the client has not described
	  yet waits PENDING_SECONDS for it, then counts 0, as the journal's item rows give up.
	- Won on Greed: a roll the player won ("You won", or its short Greed form) after choosing Greed for that roll
	  (the client's lootHistory id, which both lines carry).
	No combat log (Forever keeps it from addons) and no chat text read for numbers but the item counts.
]]

local Run = {}
ns.Run = Run

local MONEY_WINDOW = 3
local PENDING_SECONDS = 15
-- An encounter started for a boss this run already killed, at least this long ago: a new copy.
local NEW_COPY_AFTER = 60
local QUEST_CLASS = 12
local LOG_SIZE = 5
-- The chat summary waits this long after the clock stops: the final boss's loot is counted in it.
local SUMMARY_DELAY = 60
Run.SUMMARY_DELAY = SUMMARY_DELAY

--[[
	Whether "Inside the quest tracker" (UI/RunTrackerInside.lua) is on for a player who never ticked or unticked it:
	off, as in 0.39.21 (the owner, 2026-11-13: "keep experimental in for now"; 0.39.22's tests had it on, after the
	owner's ask of 2026-11-12, until the owner saw map pins refused in combat after clicking a quest title in the
	tracker: once the block has gone inside, the tracker's own code carries the journal's taint until a /reload). The
	options' box takes its default from here. A choice the player made, or the safety net's off, is kept as it is
	either way (KEPT): saved as made since 0.39.21, so a player who ticked it keeps it on.
]]
Run.INSIDE_DEFAULT = false

--[[
	Whether "Place it freely" is on for a player who never ticked or unticked it: on since 0.39.23 (the owner,
	2026-11-17: beside the game's quest tracker, the block got in the way of other quest tracker addons; placed freely,
	nothing of the tracker's is ever asked or changed, UI/RunTracker.lua Anchor). Before 0.39.23 off was the default
	and not saved, so a player who had unticked it then cannot be told from one who never chose: both get it on. One
	who had dragged the block before unticking it still has that spot (charDB.runSpot, kept per character), so the block
	goes straight back to the spot dropped then, instead of waiting by the tracker (not moved over: a player new to
	0.39.23 who drags it saves the same, and the spot is the character's while this is the account's). A choice made
	from 0.39.23 on is saved as made (KEPT), so unticking it puts the block back beside the tracker for good.
]]
Run.FREE_DEFAULT = true

-- The block's options, for the whole account (UI/Options.lua): on, with its numbers and its chat summary; placed
-- freely (on by default: Run.FREE_DEFAULT); placing it inside the game's quest tracker (off by default:
-- Run.INSIDE_DEFAULT); dark mode for its gold art (UI/RunTracker.lua Paint), off by default.
local OPTION_DEFAULTS = { on = true, numbers = true, free = Run.FREE_DEFAULT, summary = true,
	inside = Run.INSIDE_DEFAULT, darkMode = false }
-- Saved as chosen even when that is the default, so that a later change of the default leaves the choice be.
local KEPT = { inside = true, free = true }

function Run:Option(name)
	local saved = ns.db and ns.db.runOptions
	local value = saved and saved[name]
	if value == nil then return OPTION_DEFAULTS[name] end
	return value
end

function Run:SetOption(name, value)
	if not ns.db then return end
	ns.db.runOptions = ns.db.runOptions or {}
	if value == OPTION_DEFAULTS[name] and not KEPT[name] then value = nil end
	ns.db.runOptions[name] = value
	self:Counting()
	self:Changed()
end

-- What the run block listens to: called with no arguments whenever the run changes.
local listeners = {}
function Run:OnChange(listener) listeners[#listeners + 1] = listener end
function Run:Changed()
	for _, listener in ipairs(listeners) do listener() end
end

local function SameRunSeconds()
	return ns.DungeonMap and ns.DungeonMap.SAME_RUN_SECONDS or 30 * 60
end

-- The parts that are one copy with this one, walked between inside (instance.oneCopy: best guesses, Data/Authored/
-- RunTracker.lua), else the instance alone. Used by the map too (DungeonMap:ClearRun and its entering), so the two
-- agree on what a run is.
function Run.SameCopy(instance)
	if not instance then return {} end
	if instance.oneCopy and instance.instanceID then return ns.GetInstancesByInstanceID(instance.instanceID) end
	return { instance }
end

-- Whether a part of a dungeon belongs to a run: the part it started in, or one copy with it.
function Run.InRun(run, instance)
	if not (run and instance) then return false end
	if instance.key == run.key then return true end
	return instance.oneCopy == true and instance.instanceID ~= nil and instance.instanceID == run.instanceID
end

-- This session's state: the client instance id the player is inside (nil outside, and while the wing is not known:
-- wingWait, below), the baselines the numbers count from (read again on every entering and login, never saved), which
-- windows are open, the coin pairing, the rolls chosen on Greed, and the last few readings for /ij run debug.
local session = { windows = {}, greed = {}, won = {}, log = { money = {}, loot = {}, xp = {}, clock = {} } }
Run.session = session

local function Log(kind, text)
	local list = session.log[kind]
	table.insert(list, 1, date and date("%H:%M:%S") .. " " .. text or text)
	while #list > LOG_SIZE do table.remove(list) end
end

------------------------------------------------------------------------------------------
-- The bosses a run counts
------------------------------------------------------------------------------------------

local function Counted(boss)
	return not (ns.IsLootSection(boss) or boss.rare or boss.maybe or boss.questTarget or boss.uncounted or boss.outsideRun
		or boss.comingSoon
		or (ns.Items and ns.Items:HidesBoss(boss)))
end

--[[
	The dungeon's (or wing's) bosses as the block shows them, in the journal's order: one entry per fight, so two
	bosses of one encounter (Sneed's Shredder, then Sneed: encounter 2742) are one circle and one line, with the
	last one's name and face. Not counted: trash, rares (no line either), the Ring of Law's maybes, quest targets (the
	Excavation Site's Highland Horror, a quest's mob more than a boss: Data/Authored/ExcavationSiteWetlands.lua), a
	creature on the list that is no fight of the run's own (uncounted, set in Data/Authored/RunTracker.lua's
	OUT_OF_COUNT: Blackfathom Deeps' Baron Aquanis, a boss only the Horde calls up, by a quest; Shadowfang Keep's steeds
	and Arugal's Voidwalkers; the City of Dalaran's Lyn the Ignored, whom the players summon; the Drowned City's shark,
	Zin'aka, which players swim around, had it while it was on the list: Data/Authored/Upcoming.lua says how to bring it
	back), bosses who stand outside the instance (outsideRun: Gnomeregan's Techbot, Data/Authored/RunTracker.lua),
	bosses coming soon and those the journal hides. Each entry: { boss = the face, parts = { boss, ... } }. A boss who
	only joins another's fight (joinsFight: Scarlet Commander Mograine in Whitemane's, Data/Authored/RunTracker.lua)
	keeps his own entry, and the fight's end crosses out both all the same (UI/DungeonMap.lua, by the fight's id).

	An entry's name and face come from Run.EntryName and the block's ShowCircle (UI/RunTracker.lua), one place each.
]]
function Run.Bosses(instance)
	local list, byEncounter = {}, {}
	for _, boss in ipairs(instance and instance.bosses or {}) do
		if Counted(boss) then
			local shared = boss.encounterID and not boss.joinsFight and boss.encounterID or nil
			local entry = shared and byEncounter[shared]
			if entry then
				entry.parts[#entry.parts + 1] = boss
				entry.boss = boss
			else
				entry = { boss = boss, parts = { boss } }
				list[#list + 1] = entry
				if shared then byEncounter[shared] = entry end
			end
		end
	end
	return list
end

-- The bosses that get no circle and no place in the count, but a done line once killed: maybes, quest targets (one
-- done by his quest is done here too: UI/DungeonMap.lua's IsDefeated) and the uncounted (Baron Aquanis, Shadowfang
-- Keep's steeds and Voidwalkers, Lyn the Ignored). Not rare spawns (the owner, 2026-11-13: they leave the block; a
-- rare's kill is still kept with the run, run.kills, for the map and /ij run debug), nor those outside the instance
-- (outsideRun): the journal sees no kill outside one, so their line could never come (0.39.21's review).
function Run.Others(instance)
	local list = {}
	for _, boss in ipairs(instance and instance.bosses or {}) do
		if (boss.maybe or boss.questTarget or boss.uncounted) and not boss.rare
			and not boss.outsideRun and not ns.IsLootSection(boss) and not (ns.Items and ns.Items:HidesBoss(boss)) then
			list[#list + 1] = boss
		end
	end
	return list
end

-- instance: the dungeon the entry is of, for Adventure Mode, where a boss not met yet is "???" (Core/Discovery.lua's
-- BossTitle, as on his pin and in the boss list: the owner's call of 2026-11-11, the same mystery faces).
function Run.EntryName(entry, instance)
	if instance and ns.Discovery and ns.Discovery:Unmet(instance, entry.boss) then return ns.Discovery.UNKNOWN end
	return entry.boss.name
end

-- Whether every part of an entry is dead, as `dead(boss)` tells.
function Run.EntryDead(entry, dead)
	for _, boss in ipairs(entry.parts) do
		if not dead(boss) then return false end
	end
	return true
end

-- The entry of the dungeon's final boss, where Data/Authored/RunTracker.lua names one the list has.
function Run.FinalEntry(instance, list)
	local final = instance and instance.finalBoss
	if not final then return nil end
	for _, entry in ipairs(list or Run.Bosses(instance)) do
		for _, boss in ipairs(entry.parts) do
			if (boss.enName or boss.name) == final then return entry end
		end
	end
	return nil
end

-- Whether a run of this dungeon is done: its final boss dead, else every boss counted.
function Run.Finished(instance, dead, list)
	list = list or Run.Bosses(instance)
	local final = Run.FinalEntry(instance, list)
	if final then return Run.EntryDead(final, dead) end
	if #list == 0 then return false end
	for _, entry in ipairs(list) do
		if not Run.EntryDead(entry, dead) then return false end
	end
	return true
end

------------------------------------------------------------------------------------------
-- Patterns from the client's own strings
------------------------------------------------------------------------------------------

--[[
	A Lua pattern from one of the client's format strings, and the order its captures come in: each
	%s becomes (.-) and each %d (%d+), each a capture, and a positional code (%2$s) says which value it is, so a
	language that puts the count before the item still gives them back in the format's order. Magic characters are
	escaped. The end is loose: the client's own lines end with a period or not (LOOT_ITEM_SELF has none).
]]
function Run.Pattern(format)
	if type(format) ~= "string" or format == "" then return nil end
	local body = format:gsub("[%.%s]+$", ""):gsub("\227\128\130$", "")
	local parts, order, nextArg, at = { "^" }, {}, 0, 1
	while at <= #body do
		local char = body:sub(at, at)
		if char == "%" then
			if body:sub(at + 1, at + 1) == "%" then
				parts[#parts + 1] = "%%"
				at = at + 2
			else
				local position, conversion, stop = body:match("^(%d*)%$?[%-+ #0]*%d*%.?%d*([sdi])()", at + 1)
				if conversion then
					local argument = tonumber(position)
					if not argument then
						nextArg = nextArg + 1
						argument = nextArg
					end
					order[#order + 1] = argument
					parts[#parts + 1] = conversion == "s" and "(.-)" or "(%d+)"
					at = stop
				else
					parts[#parts + 1] = "%%"
					at = at + 1
				end
			end
		else
			parts[#parts + 1] = char:find("[%^%$%(%)%.%[%]%*%+%-%?]") and "%" .. char or char
			at = at + 1
		end
	end
	parts[#parts + 1] = "$"
	return { pattern = table.concat(parts), order = order }
end

-- The values a line gives for a compiled pattern, in the format's order; nil if it is not that line. The line's
-- own end (a period, the full stop of Chinese, spaces) is dropped as the format's was.
function Run.Match(text, compiled)
	if not (compiled and type(text) == "string") then return nil end
	text = text:gsub("[%.%s]+$", ""):gsub("\227\128\130$", "")
	local captures = { text:match(compiled.pattern) }
	if #captures == 0 then return nil end
	local values = {}
	for index, argument in ipairs(compiled.order) do values[argument] = captures[index] end
	return values
end

local patterns
-- Built from the client's globals, in its language; again by a check that changes them.
function Run.BuildPatterns()
	local function All(...)
		local list = {}
		for index = 1, select("#", ...) do
			local compiled = Run.Pattern(_G[(select(index, ...))])
			if compiled then list[#list + 1] = compiled end
		end
		return list
	end
	patterns = {
		multiple = Run.Pattern(LOOT_ITEM_SELF_MULTIPLE),
		single = Run.Pattern(LOOT_ITEM_SELF),
		greedChosen = Run.Pattern(LOOT_ROLL_GREED_SELF),
		won = Run.Pattern(LOOT_ROLL_YOU_WON),
		wonOnGreed = Run.Pattern(LOOT_ROLL_YOU_WON_NO_SPAM_GREED),
		coin = All("YOU_LOOT_MONEY", "LOOT_MONEY_SPLIT", "YOU_LOOT_MONEY_GUILD", "LOOT_MONEY_SPLIT_GUILD",
			"YOU_LOOT_MONEY_MOD", "LOOT_MONEY_SPLIT_MOD"),
	}
	return patterns
end

------------------------------------------------------------------------------------------
-- The run itself
------------------------------------------------------------------------------------------

function Run:Current()
	return ns.charDB and ns.charDB.run or nil
end

-- The run to show outside: the one still open (just left), else the last one kept.
function Run:Last()
	local db = ns.charDB
	if not db then return nil end
	return db.run or db.lastRun
end

function Run:Inside()
	return session.inside
end

-- Inside one of Scarlet Monastery's wings, which one not known yet (UI/DungeonMap.lua's WaitForWing): the client
-- instance id, else nil. The run before stays as it was left until the wing says whether it goes on.
function Run:WaitingForWing()
	return session.wingWait and session.wingWait.instanceID or nil
end

-- A new run asked for while the wing was not known (Run:NewRun): the wing, once known, starts one (UI/DungeonMap.lua's
-- PlaceWing).
function Run:NewRunAsked()
	return session.wingWait ~= nil and session.wingWait.fresh == true
end

-- Where the numbers go: the run, else (the wing not known yet) what is counted meanwhile, for the run the wing
-- decides (Run:Entered).
local function Counts()
	local wait = session.wingWait
	return wait and wait.counts or Run:Current()
end

-- Seconds on the run's clock: from the first pull (0 while it waits for it) to its stop, else (left behind) to when
-- the player was last inside, else to now; paused, to the pause (pausedAt), its earlier pauses and the time logged
-- out while it ran left out (pausedSeconds).
function Run.Elapsed(run)
	if not (run and run.startedAt) then return 0 end
	local stop = run.endedAt or (run.frozen and run.lastInsideAt) or time()
	if run.pausedAt and run.pausedAt < stop then stop = run.pausedAt end
	return math.max(0, stop - run.startedAt - (run.pausedSeconds or 0))
end

-- How the run's clock stands: "waiting" for the first pull, "running", "paused" by the player, or "stopped" (the
-- final boss down, or the run left behind); "none" without a run.
function Run.ClockState(run)
	if not run then return "none" end
	if run.endedAt then return "stopped" end
	if not run.startedAt then return "waiting" end
	if run.pausedAt then return "paused" end
	return "running"
end

-- A pause ended at `at`: its time added to the time not counted.
local function SettlePause(run, at)
	if not run.pausedAt then return end
	run.pausedSeconds = (run.pausedSeconds or 0) + math.max(0, at - run.pausedAt)
	run.pausedAt = nil
end

-- The clock stopped at `at` (the final boss, a run joined late found finished): a pause then ends there.
local function StopClock(run, at)
	SettlePause(run, at)
	run.startedAt = run.startedAt or at
	run.endedAt = at
end

-- Any boss this run killed, as the run kept them.
local function AnyKill(run)
	for _, killed in pairs(run.kills or {}) do
		if next(killed) then return true end
	end
	return false
end

local Baselines

-- The kills the map already has for this run's dungeon, kept with the run: a run joined late (a login after a
-- lost session, the first login with this version) starts with what the map shows, time unknown (0).
local function SeedKills(run, instance)
	local map = ns.DungeonMap
	if not (map and map.Kills) then return end
	for _, wing in ipairs(Run.SameCopy(instance)) do
		for name, killed in pairs(map:Kills(wing) or {}) do
			if killed == true then
				run.kills[wing.key] = run.kills[wing.key] or {}
				run.kills[wing.key][name] = run.kills[wing.key][name] or 0
			end
		end
	end
end

--[[
	The open run left behind: kept as the last run, its clock ended where it stopped, else when the player was last
	inside, else now. Its summary goes to chat once if its clock never stopped and it killed anything,
	or if its clock stopped and its summary still waits (summaryAt); one joined late with its clock
	already stopped gets none.
]]
function Run:Freeze()
	local db = ns.charDB
	local run = db and db.run
	if not run then return end
	run.frozen = true
	-- Its clock ends where the player left it: a logout after that is not to be taken off it again.
	if not run.endedAt and run.lastInsideAt and run.pausedAway then
		run.pausedSeconds = math.max(0, (run.pausedSeconds or 0) - run.pausedAway)
	end
	run.pausedAway = nil
	-- Paused by the player when left: the pause ends where the clock ends.
	if run.pausedAt then SettlePause(run, run.endedAt or run.lastInsideAt or time()) end
	run.endedAt = run.endedAt or run.lastInsideAt or time()
	run.pending = nil
	db.lastRun, db.run = run, nil
	if run.summaryAt or (not run.finished and AnyKill(run)) then self:PrintSummary(run) end
end

-- A new run, its clock waiting for the first pull (enteredAt: when it was decided). One joined late with kills
-- already (the map's: it was going on) starts its clock at once.
function Run:Start(instance, late)
	local db = ns.charDB
	if not (db and instance) then return end
	if db.run then self:Freeze() end
	local now = time()
	db.run = {
		instanceID = instance.instanceID, key = instance.key, wing = instance.key, enteredAt = now, pausedSeconds = 0,
		lastSeen = now, late = late or nil, xp = 0, copper = 0, itemValue = 0, items = 0, itemList = {}, greed = 0,
		pending = {}, kills = {},
	}
	session.greed, session.won = {}, {}
	if late then SeedKills(db.run, instance) end
	if late and AnyKill(db.run) then db.run.startedAt, db.run.startedBy = now, "joined late" end
	Log("xp", "run started" .. (late and " (joined late)" or ""))
	Log("clock", db.run.startedAt and "started (joined late, with kills)" or "waiting for the first pull")
end

-- The run's clock started (Run:Pull, the block's button): at its first pull, or by the player. How, for /ij run debug.
function Run:StartClock(how)
	local run = self:Current()
	if Run.ClockState(run) ~= "waiting" then return false end
	run.startedAt, run.startedBy = time(), how
	Log("clock", "started: " .. tostring(how))
	self:WatchPull()
	self:Changed()
	return true
end

-- A sign of the first pull (see the top of this file): the clock started if it still waits, inside its dungeon. With
-- the wing not known yet, the first one is noted (its time and how), for the run the wing decides (Run:Entered).
function Run:Pull(how)
	local wait = session.wingWait
	if wait then
		if wait.pull then return false end
		wait.pull = { at = time(), how = how }
		Log("clock", "a pull before the wing was known: " .. tostring(how))
		self:WatchPull()
		return false
	end
	if not session.inside then return false end
	return self:StartClock(how)
end

-- The player's pause, and their resume: only of a clock running (or paused) inside.
function Run:Pause()
	local run = self:Current()
	if not session.inside or Run.ClockState(run) ~= "running" then return false end
	run.pausedAt = time()
	Log("clock", "paused")
	self:Changed()
	return true
end

function Run:Resume()
	local run = self:Current()
	if not session.inside or Run.ClockState(run) ~= "paused" then return false end
	SettlePause(run, time())
	Log("clock", "resumed")
	self:Changed()
	return true
end

-- The block's clock button (UI/RunTracker.lua): starts a clock still waiting for the first pull, pauses a running
-- one, resumes a paused one. What it did ("started", "paused", "resumed"), or nil.
function Run:ToggleClock()
	local state = Run.ClockState(self:Current())
	if state == "waiting" then return session.inside and self:StartClock("the player") and "started" or nil end
	if state == "running" then return self:Pause() and "paused" or nil end
	if state == "paused" then return self:Resume() and "resumed" or nil end
	return nil
end

--[[
	A /ij run new, or the block's New run button: the map's kills cleared for every wing of this dungeon, and a new
	run, its clock waiting for the first pull as on coming in (started at once if the player or a groupmate in sight
	is in a fight). A new copy seen at a fight's start (the watcher, below) starts it at once. With the wing not known
	yet (Run:WaitForWing), the request is kept for it (Run:NewRunAsked): the pull and numbers so far dropped, as a new
	run's start would, and a new run of the wing once it is known, whichever it is.
]]
local NoCounts

function Run:NewRun()
	local wait = session.wingWait
	if wait then
		wait.fresh, wait.pull, wait.away, wait.counts = true, nil, nil, NoCounts()
		Log("xp", "a new run asked for, the wing not known yet")
		if Baselines then Baselines() end
		self:WatchPull()
		self:PullNow()
		self:Changed()
		return true
	end
	local instance = session.instance
	if not instance then return false end
	if ns.DungeonMap and ns.DungeonMap.ClearRun then ns.DungeonMap:ClearRun(instance) end
	self:Start(instance)
	if Baselines then Baselines() end
	self:WatchPull()
	self:PullNow()
	if ns.DungeonMap then ns.DungeonMap:Refresh() end
	self:Changed()
	return true
end

local function Dead(boss)
	return ns.DungeonMap ~= nil and ns.DungeonMap:IsDefeated(session.instance, boss)
end

-- Time logged out is not the run's (from a logout anywhere, inside or out). Only a running clock's: waiting for the
-- first pull it has not started, and paused it is not counting (the pause, kept, goes on).
local function SettleLogout(run, now, login, reload)
	if not (run and (login or reload) and run.loggedOutAt) then return end
	if Run.ClockState(run) == "running" then
		local gap = math.max(0, now - run.loggedOutAt)
		run.pausedSeconds = (run.pausedSeconds or 0) + gap
		-- Logged out once out of the dungeon (or logged out inside: lastInsideAt is the logout): past the end of
		-- a run left behind, so kept apart until the player is back in and the run goes on (Freeze gives it back).
		if run.lastInsideAt then run.pausedAway = (run.pausedAway or 0) + gap end
	end
	run.loggedOutAt = nil
end

--[[
	Inside one of several wings that are each their own copy (Scarlet Monastery's), the wing not known yet (UI/
	DungeonMap.lua's WaitForWing: it is known at the wing's first named area or its first fight). No run is shown or
	counted meanwhile (the run block's "Which wing?"): the run before stays as it was left, for the wing to say whether it
	goes on (a corpse run back into its wing) or a new one starts (any other wing). The first pull meanwhile is noted
	(Run:Pull), and starts the clock of the run the wing decides, at its time; the numbers are counted apart (Counts),
	and go to that run (the trash before a wing's first named room, the Library's long hall). The wait is kept with the
	character (AegisJournalCharDB.wingWait), so a /reload or a login while waiting picks it up again, its pull and
	numbers with it, where it is for the same instance and was last seen within SAME_RUN_SECONDS (the time logged out
	after its pull kept apart as away, not the run's, as for a run's clock: SettleLogout). Run:Entered ends it.
]]
function NoCounts()
	return { xp = 0, copper = 0, itemValue = 0, items = 0, itemList = {}, greed = 0, pending = {} }
end

function Run:WaitForWing(instanceID, login, reload)
	local db = ns.charDB
	if not db then return end
	local now = time()
	login, reload = ns.Readable(login) == true, ns.Readable(reload) == true
	SettleLogout(db.run, now, login, reload)
	if db.run and session.inside then db.run.lastInsideAt, db.run.lastSeen = now, now end
	session.inside, session.instance = nil, nil
	local kept = db.wingWait
	if (login or reload) and type(kept) == "table" and kept.instanceID == instanceID and type(kept.counts) == "table"
		and now - (kept.seenAt or kept.since or 0) <= SameRunSeconds() then
		if kept.pull and kept.seenAt then kept.away = (kept.away or 0) + math.max(0, now - kept.seenAt) end
		kept.seenAt = nil
		session.wingWait = kept
		Log("clock", "waiting for the wing again, after a " .. (reload and "/reload" or "login"))
	else
		-- (the run before hidden with /ij run and still one the wing can go on with, a corpse run back in: the wait
		-- hidden too, so the block does not come back at the door)
		local run = db.run
		local hidden = run and run.hidden and run.instanceID == instanceID
			and now - (run.lastInsideAt or run.lastSeen or 0) <= SameRunSeconds() or nil
		session.wingWait = { instanceID = instanceID, since = now, counts = NoCounts(), hidden = hidden }
		Log("clock", "waiting for the wing")
	end
	db.wingWait = session.wingWait
	self:Counting()
	self:WatchPull()
	self:PullNow()
	self:Changed()
end

--[[
	The player came into the world (UI/DungeonMap.lua's PLAYER_ENTERING_WORLD, once it has decided the run), or a wing
	waited for is known (UI/DungeonMap.lua's PlaceWing): `instance` is the dungeon they are in (nil outside), `cleared`
	whether the map just started a new run there.
]]
function Run:Entered(instance, cleared, login, reload)
	local db = ns.charDB
	if not db then return end
	local now = time()
	login, reload = ns.Readable(login) == true, ns.Readable(reload) == true
	local wait = session.wingWait
	session.wingWait, db.wingWait = nil, nil
	local run = db.run
	SettleLogout(run, now, login, reload)
	local dungeon = instance and instance.kind ~= "raid" and instance or nil
	if not dungeon then
		if run and session.inside then run.lastInsideAt, run.lastSeen = now, now end
		session.inside, session.instance = nil, nil
		-- Out of the dungeon: a summary still waiting goes now.
		if run and run.summaryAt then self:PrintSummary(run) end
		-- Away longer than the map keeps a run: it is left behind.
		if run and run.lastInsideAt and now - run.lastInsideAt > SameRunSeconds() then self:Freeze() end
		self:Counting()
		self:WatchPull()
		self:Changed()
		return
	end
	session.instance = dungeon
	if cleared then
		self:Start(dungeon)
	elseif not Run.InRun(run, dungeon) then
		self:Start(dungeon, true)
	elseif (login or reload) and now - (run.lastSeen or 0) > SameRunSeconds() then
		-- A saved run older than the map keeps one, at a login inside: the session that ended it was lost
		-- (a crash writes nothing), so it is not resumed.
		self:Start(dungeon, true)
	end
	run = db.run
	-- Back in, the run goes on: the time logged out since leaving stays paused.
	run.lastSeen, run.lastInsideAt, run.pausedAway = now, nil, nil
	session.inside = dungeon.instanceID
	if not run.endedAt and run.late and Run.Finished(dungeon, Dead) then
		StopClock(run, now)
		run.finished, run.finishedWing = true, dungeon.key
	end
	-- What was counted while the wing was not known yet: this run's.
	local counts = wait and wait.counts
	if counts then
		run.xp, run.copper = (run.xp or 0) + counts.xp, (run.copper or 0) + counts.copper
		run.itemValue, run.items = (run.itemValue or 0) + counts.itemValue, (run.items or 0) + counts.items
		run.greed = (run.greed or 0) + counts.greed
		run.itemList, run.pending = run.itemList or {}, run.pending or {}
		for itemID, count in pairs(counts.itemList) do run.itemList[itemID] = (run.itemList[itemID] or 0) + count end
		for itemID, waiting in pairs(counts.pending) do
			local mine = run.pending[itemID]
			if mine then mine.count = mine.count + waiting.count else run.pending[itemID] = waiting end
		end
	end
	-- The block hidden or shown with /ij run while the wing was not known yet (wait.toggled): so is this run. Else a run
	-- that goes on keeps its own choice, and a new one is shown.
	if wait and wait.toggled then run.hidden = wait.hidden or nil end
	-- A pull while the wing was not known yet: the first pull of this run, at its time.
	if wait and wait.pull and Run.ClockState(run) == "waiting" then
		run.startedAt, run.startedBy = math.min(wait.pull.at, now), tostring(wait.pull.how) .. ", before the wing was known"
		-- (time logged out since, across a /reload or a login while waiting: not the run's)
		if (wait.away or 0) > 0 then run.pausedSeconds = (run.pausedSeconds or 0) + wait.away end
		Log("clock", "started: " .. run.startedBy)
	end
	-- A summary still waiting (a /reload or a login inside since the clock stopped): its timer again, for what is left.
	if run.summaryAt then self:ScheduleSummary(run) end
	if Baselines then Baselines() end
	self:Counting()
	-- The clock still waiting: the pull events heard from now, and a fight already going on counted as the pull.
	self:WatchPull()
	self:PullNow()
	self:Changed()
end

-- A kill the map marked (DungeonMap:MarkDefeated): kept with its time, and the clock stopped at the final boss.
function Run:Killed(instance, boss)
	local run = self:Current()
	if not (boss and Run.InRun(run, instance)) then return end
	run.kills[instance.key] = run.kills[instance.key] or {}
	if run.kills[instance.key][boss.name] then return end
	local now = time()
	run.kills[instance.key][boss.name] = now
	run.wing = instance.key
	-- A kill with the clock still waiting (no fight of the player's or a groupmate's in sight seen before it): the
	-- first pull, at the kill.
	if Run.ClockState(run) == "waiting" then
		run.startedAt, run.startedBy = now, "a kill"
		Log("clock", "started: a kill")
		self:WatchPull()
	end
	if not run.endedAt and Run.Finished(instance, function(other)
		return ns.DungeonMap:IsDefeated(instance, other)
	end) then
		-- The part it finished in: another part walked into afterwards (Blackrock Spire's, Dire Maul's) is not done.
		StopClock(run, now)
		run.finished, run.finishedWing = true, instance.key
		run.summaryAt = now + SUMMARY_DELAY
		self:ScheduleSummary(run)
	end
	self:Changed()
end

-- The summary of a run whose clock stopped, at its time (summaryAt), once: one timer a session (a /reload drops it,
-- and Entered sets it again).
function Run:ScheduleSummary(run)
	if not run or run.told or session.summaryFor == run then return end
	session.summaryFor = run
	C_Timer.After(math.max(0, (run.summaryAt or time()) - time()), function()
		if session.summaryFor == run then session.summaryFor = nil end
		self:PrintSummary(run)
	end)
end

-- The game's reset message (UI/DungeonMap.lua): a run left outside is over.
function Run:Reset()
	if self:Current() and not session.inside then
		self:Freeze()
		self:Changed()
	end
end

------------------------------------------------------------------------------------------
-- Experience, coin and items
------------------------------------------------------------------------------------------

local function Number(value)
	value = ns.Readable(value)
	return type(value) == "number" and value or nil
end

-- Whether the experience line shows: not at the level cap, nor with experience turned off.
function Run.XPShown()
	if type(IsXPUserDisabled) == "function" and IsXPUserDisabled() then return false end
	local max = Number(UnitXPMax and UnitXPMax("player"))
	if not max or max <= 0 then return false end
	local cap = type(GetMaxPlayerLevel) == "function" and Number(GetMaxPlayerLevel()) or nil
	local level = Number(UnitLevel and UnitLevel("player"))
	return not (cap and level and level >= cap)
end

function Baselines()
	session.xp = { value = Number(UnitXP and UnitXP("player")), max = Number(UnitXPMax and UnitXPMax("player")) }
	session.money = { last = Number(GetMoney and GetMoney()) }
end

local function CountXP()
	local run = Counts()
	local value, max = Number(UnitXP("player")), Number(UnitXPMax("player"))
	local was = session.xp or {}
	if not (run and value and was.value) then
		session.xp = { value = value, max = max }
		return
	end
	local gain = 0
	if value > was.value then
		gain = value - was.value
	elseif value < was.value and was.max then
		-- Experience never falls but at a new level: the rest of the old one, then the new one's.
		gain = math.max(0, was.max - was.value) + value
	end
	session.xp = { value = value, max = max }
	if gain > 0 then
		run.xp = (run.xp or 0) + gain
		Log("xp", "+" .. gain)
		Run:Changed()
	end
end

local function WindowOpen()
	return next(session.windows) ~= nil
end

local function CountCoin(amount, how)
	local run = Counts()
	if not run or amount <= 0 then return end
	run.copper = (run.copper or 0) + amount
	Log("money", how .. " +" .. amount .. " counted")
	Run:Changed()
end

local function OwnCoinLine(text)
	text = ns.Readable(text)
	if type(text) ~= "string" then return true, "secret" end
	for _, compiled in ipairs((patterns or Run.BuildPatterns()).coin) do
		if Run.Match(text, compiled) then return true, "readable" end
	end
	return false, "readable"
end

-- Unpaired coin lines and purse rises, oldest first, each kept MONEY_WINDOW seconds: paired one to one.
local function Fresh(list, now)
	while list[1] and now - list[1].at > MONEY_WINDOW do
		local old = table.remove(list, 1)
		if old.amount then Log("money", "rise +" .. old.amount .. " with no line: not counted") end
	end
end

local function OnMoneyLine(text)
	local own, how = OwnCoinLine(text)
	if not own then
		Log("money", "line not ours (" .. how .. ")")
		return
	end
	if WindowOpen() then
		Log("money", "line while a window is open: not counted")
		return
	end
	local money, now = session.money or {}, GetTime()
	session.money = money
	money.rises, money.lines = money.rises or {}, money.lines or {}
	Fresh(money.rises, now)
	local rise = table.remove(money.rises, 1)
	if rise then
		CountCoin(rise.amount, "line after rise (" .. how .. ")")
	else
		money.lines[#money.lines + 1] = { at = now }
		Log("money", "line (" .. how .. ") waits for a rise")
	end
end

local function OnMoneyChanged()
	local money = session.money or {}
	local now, current = GetTime(), Number(GetMoney())
	if not current then return end
	local delta = current - (money.last or current)
	money.last = current
	session.money = money
	if delta <= 0 then return end
	money.rises, money.lines = money.rises or {}, money.lines or {}
	if WindowOpen() then
		money.rises, money.lines = {}, {}
		Log("money", "rise +" .. delta .. " with a window open: not counted")
		return
	end
	Fresh(money.lines, now)
	if table.remove(money.lines, 1) then
		CountCoin(delta, "rise after line")
	else
		money.rises[#money.rises + 1] = { at = now, amount = delta }
	end
end

-- An item's vendor price in copper (0 for a quest item or one with none), or nil while the client has not
-- described it yet.
local function SellPrice(itemID)
	local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
	if type(getInfo) ~= "function" then return 0 end
	local info = { pcall(getInfo, itemID) }
	if not (info[1] and info[2]) then return nil end
	local price, classID = Number(info[12]), Number(info[13])
	if classID == QUEST_CLASS then return 0 end
	return price or 0
end

local function AddValue(run, itemID, count)
	local price = SellPrice(itemID)
	if price == nil then
		local waiting = run.pending[itemID] or { count = 0 }
		waiting.count, waiting.since = waiting.count + count, time()
		run.pending[itemID] = waiting
		if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, itemID) end
		return "pending"
	end
	run.itemValue = (run.itemValue or 0) + price * count
	return price
end

-- The items still waiting: priced once the client describes them, given up on after PENDING_SECONDS.
function Run:Settle(itemID)
	local run = Counts()
	if not (run and run.pending) then return end
	local changed = false
	for id, waiting in pairs(run.pending) do
		if not itemID or id == itemID then
			local price = SellPrice(id)
			if price ~= nil then
				run.itemValue = (run.itemValue or 0) + price * waiting.count
				run.pending[id], changed = nil, true
			elseif time() - (waiting.since or 0) > PENDING_SECONDS then
				Log("loot", "item " .. id .. " never described: counted at 0")
				run.pending[id], changed = nil, true
			end
		end
	end
	if changed then self:Changed() end
end

local function OnLootLine(text)
	local run = Counts()
	if not run then return end
	text = ns.Readable(text)
	if type(text) ~= "string" then
		Log("loot", "line kept secret: skipped")
		return
	end
	local found = patterns or Run.BuildPatterns()
	local values = Run.Match(text, found.multiple)
	local link, count
	if values then
		link, count = values[1], tonumber(values[2])
	else
		values = Run.Match(text, found.single)
		if values then link, count = values[1], 1 end
	end
	if link then
		local itemID = ns.ItemIDFromLink(link)
		if not (itemID and count and count > 0) then return end
		run.items = (run.items or 0) + count
		run.itemList = run.itemList or {}
		run.itemList[itemID] = (run.itemList[itemID] or 0) + count
		local price = AddValue(run, itemID, count)
		Log("loot", "item " .. itemID .. " x" .. count .. " (" .. tostring(price) .. ")")
		Run:Changed()
		return
	end
	-- The rolls: Greed chosen for a roll, then won; or the short line that says both.
	values = Run.Match(text, found.greedChosen)
	if values and values[1] then
		session.greed[values[1]] = true
		return
	end
	values = Run.Match(text, found.wonOnGreed)
	local rollID = values and values[1]
	if not rollID then
		values = Run.Match(text, found.won)
		rollID = values and values[1]
		if not (rollID and session.greed[rollID]) then return end
	end
	if session.won[rollID] then return end
	session.won[rollID] = true
	run.greed = (run.greed or 0) + 1
	Log("loot", "won on Greed (roll " .. rollID .. ")")
	Run:Changed()
end

------------------------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------------------------

local COUNT_EVENTS = { "PLAYER_XP_UPDATE", "CHAT_MSG_MONEY", "PLAYER_MONEY", "CHAT_MSG_LOOT", "GET_ITEM_INFO_RECEIVED",
	"ITEM_DATA_LOAD_RESULT", "MERCHANT_SHOW", "MERCHANT_CLOSED", "MAIL_SHOW", "MAIL_CLOSED", "TRADE_SHOW", "TRADE_CLOSED",
	"AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" }
local WINDOWS = { MERCHANT_SHOW = "merchant", MAIL_SHOW = "mail", TRADE_SHOW = "trade", AUCTION_HOUSE_SHOW = "auction" }
local CLOSED = { MERCHANT_CLOSED = "merchant", MAIL_CLOSED = "mail", TRADE_CLOSED = "trade", AUCTION_HOUSE_CLOSED = "auction" }

local counter = CreateFrame("Frame")
Run.counter = counter

-- The numbers' events: only inside the run's dungeon (or a wing not known yet) with the block on, else none.
-- Counting from the purse and experience as they are when it starts (not as a time it was off left them).
function Run:Counting()
	if (session.inside and self:Current() or session.wingWait) and self:Option("on") then
		if not session.counting and Baselines then Baselines() end
		session.counting = true
		ns.RegisterEvents(counter, unpack(COUNT_EVENTS))
	else
		session.counting = nil
		ns.UnregisterEvents(counter, unpack(COUNT_EVENTS))
		session.windows = {}
	end
end

counter:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_XP_UPDATE" then
		local unit = ...
		if unit == nil or unit == "player" then CountXP() end
	elseif event == "CHAT_MSG_MONEY" then
		OnMoneyLine((...))
	elseif event == "PLAYER_MONEY" then
		OnMoneyChanged()
	elseif event == "CHAT_MSG_LOOT" then
		OnLootLine((...))
	elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" then
		local itemID = Number((...))
		if itemID then Run:Settle(itemID) end
	elseif WINDOWS[event] then
		session.windows[WINDOWS[event]] = true
	elseif CLOSED[event] then
		session.windows[CLOSED[event]] = nil
	end
end)

-- Always heard, as they are about the run itself: a logout (the clock's pause), and a fight's start for a boss this
-- run already killed (a new copy: a groupmate kept it, or a reset nobody heard).
local watcher = CreateFrame("Frame")
ns.RegisterEvents(watcher, "PLAYER_LOGOUT", "ENCOUNTER_START")
watcher:SetScript("OnEvent", function(_, event, ...)
	local run = Run:Current()
	if event == "PLAYER_LOGOUT" then
		local now = time()
		if run then
			run.loggedOutAt, run.lastSeen = now, now
			-- Logged out inside: the server may log them in outside, and the run's time away counts from here.
			if session.inside then run.lastInsideAt = now end
		end
		-- Waiting for the wing: when it was last seen, for a /reload or a login to pick it up (Run:WaitForWing).
		if session.wingWait then session.wingWait.seenAt = now end
		return
	end
	-- The wing not known yet: the fight names it first (UI/DungeonMap.lua), so a fight against a boss this run already
	-- killed is a new copy as at a named room (whichever frame hears the fight first).
	if session.wingWait and ns.DungeonMap and ns.DungeonMap.PlaceWingOfFight then
		ns.DungeonMap:PlaceWingOfFight(Number(select(1, ...)), ns.Readable(select(2, ...)))
		run = Run:Current()
	end
	-- Still not known (a fight of no wing's): the fight's start noted as the first pull.
	if session.wingWait then
		Run:Pull("a boss fight")
		return
	end
	-- The part the player stands in, where it is this run's (a fight in Upper Blackrock Spire after Lower is kept
	-- as Upper's), else the one entered by.
	local here = session.inside and ns.CurrentInstance(true)
	local instance = here and Run.InRun(run, here) and here or session.instance
	if not (run and instance and session.inside) then return end
	local encounterID, name = ...
	local killed = run.kills[instance.key] or {}
	-- A fight for several bosses (Sneed's Shredder and Sneed; Uldaman's three Lost Dwarves) is a new copy only once
	-- every one of them was killed: with one still standing, it is the same fight again after a wipe.
	local bosses, latest = ns.BossesForFight(instance, Number(encounterID), ns.Readable(name)), nil
	for _, boss in ipairs(bosses) do
		local at = killed[boss.name]
		if not (at and ns.DungeonMap:IsDefeated(instance, boss)) then
			latest = nil
			break
		end
		latest = math.max(latest or at, at)
	end
	if latest and time() - latest >= NEW_COPY_AFTER then
		Log("xp", "a fight started for " .. bosses[#bosses].name .. ", killed this run: a new run")
		Run:NewRun()
	end
	-- A boss fight started: the first pull, if the clock still waits (the new copy's too).
	Run:Pull("a boss fight")
end)

------------------------------------------------------------------------------------------
-- The first pull (see the top of this file)
------------------------------------------------------------------------------------------

-- A party or raid member's unit (UNIT_FLAGS also comes for the target, nameplates and the like).
local function GroupUnit(unit)
	return type(unit) == "string" and (unit:find("^party%d$") ~= nil or unit:find("^raid%d+$") ~= nil)
end

-- In a fight: the player, or a groupmate in sight (so in the same dungeon: not one fighting out in the world). Each
-- answer only where the client gives it readable (Forever keeps some unit values secret in dungeons): nil reads as no.
local function InFight(unit)
	if type(UnitAffectingCombat) ~= "function" then return false end
	local ok, fighting = pcall(UnitAffectingCombat, unit)
	if not (ok and ns.Readable(fighting) == true) then return false end
	if unit == "player" then return true end
	if type(UnitIsVisible) ~= "function" then return false end
	local okSeen, seen = pcall(UnitIsVisible, unit)
	return okSeen and ns.Readable(seen) == true
end

local pull = CreateFrame("Frame")
Run.pull = pull
local PULL_EVENTS = { "PLAYER_REGEN_DISABLED", "UNIT_FLAGS" }

-- Whether the first pull is still to come: inside, the run's clock waiting for it; or, the wing not known yet, none
-- noted yet.
local function PullToCome()
	local wait = session.wingWait
	if wait then return wait.pull == nil end
	return session.inside ~= nil and Run.ClockState(Run:Current()) == "waiting"
end

-- The pull events, heard only inside while the run's clock waits for the first pull (or the wing does: PullToCome);
-- dropped once it starts.
function Run:WatchPull()
	local waiting = PullToCome()
	if waiting == (session.watchingPull == true) then return end
	session.watchingPull = waiting or nil
	if waiting then ns.RegisterEvents(pull, unpack(PULL_EVENTS)) else ns.UnregisterEvents(pull, unpack(PULL_EVENTS)) end
end

-- A fight already going on as the clock starts to wait (coming in, a /reload, a new run): the player's, or a
-- groupmate's in sight. Once, then the events.
function Run:PullNow()
	if not PullToCome() then return false end
	if InFight("player") then return self:Pull("already in a fight") end
	local raid = type(IsInRaid) == "function" and IsInRaid() == true
	for index = 1, raid and 40 or 4 do
		if InFight((raid and "raid" or "party") .. index) then return self:Pull("a groupmate already in a fight") end
	end
	return false
end

pull:SetScript("OnEvent", function(_, event, unit)
	if event == "PLAYER_REGEN_DISABLED" then
		Run:Pull("the player's fight")
	elseif GroupUnit(unit) and InFight(unit) then
		Run:Pull("a groupmate's fight")
	end
end)

------------------------------------------------------------------------------------------
-- Words
------------------------------------------------------------------------------------------

-- 41:07, or 1:02:03 from an hour (the owner's m:ss).
function Run.Clock(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	if seconds >= 3600 then
		return string.format("%d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
	end
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

function Run.Thousands(value)
	value = math.floor(value or 0)
	if type(BreakUpLargeNumbers) == "function" then
		local ok, text = pcall(BreakUpLargeNumbers, value)
		if ok and type(text) == "string" then return text end
	end
	local text = tostring(value)
	while true do
		local replaced, count = text:gsub("^(%d+)(%d%d%d)", "%1,%2")
		text = replaced
		if count == 0 then return text end
	end
end

-- Per hour of the run's clock: nil for its first minute, when a few seconds give silly numbers.
function Run.PerHour(total, seconds)
	if not seconds or seconds < 60 then return nil end
	return math.floor(total * 3600 / seconds + 0.5)
end

-- A rate in coins: from a gold up, to the silver.
function Run.RateMoney(copper)
	if copper >= 10000 then copper = math.floor(copper / 100 + 0.5) * 100 end
	return ns.MoneyText(copper)
end

function Run:Summary(run)
	local instance = ns.GetInstance(run.wing or run.key)
	if not instance then return nil end
	local dead = function(boss)
		local killed = run.kills and run.kills[instance.key]
		return killed ~= nil and killed[boss.name] ~= nil
	end
	local list = Run.Bosses(instance)
	local down = 0
	for _, entry in ipairs(list) do
		if Run.EntryDead(entry, dead) then down = down + 1 end
	end
	local seconds = Run.Elapsed(run)
	local parts = { string.format(L.RUN_SUMMARY, instance.name, down, #list, Run.Clock(seconds)) }
	if (run.xp or 0) > 0 then parts[#parts + 1] = string.format(L.RUN_SUMMARY_XP, Run.Thousands(run.xp)) end
	local money = (run.copper or 0) + (run.itemValue or 0)
	if money > 0 then
		local rate = Run.PerHour(money, seconds)
		parts[#parts + 1] = ns.MoneyText(money) .. (rate and " (" .. string.format(L.RUN_PER_HOUR, Run.RateMoney(rate)) .. ")" or "")
	end
	if (run.items or 0) > 0 then parts[#parts + 1] = string.format(L.RUN_SUMMARY_ITEMS, run.items) end
	return table.concat(parts, " - ")
end

-- Once per run, and only with its box ticked.
function Run:PrintSummary(run)
	if run.told or not self:Option("on") or not self:Option("summary") then return end
	run.told, run.summaryAt = true, nil
	local ok, text = pcall(self.Summary, self, run)
	if ok and text then ns.Print(text) end
end

-- /ij run debug: what settles the best guesses in one run. Then the block's own lines (where it sits, the experiment).
function Run:Debug(...)
	local run = self:Current() or self:Last()
	local lines = {}
	local function Add(text) lines[#lines + 1] = text end
	local wait = session.wingWait
	if wait then
		local function At(stamp) return date and date("%H:%M:%S", stamp) or tostring(stamp) end
		local counts = wait.counts
		Add(string.format("waiting for the wing (instance %s) since %s%s%s; counted meanwhile: xp %d, coin %d, items %d",
			tostring(wait.instanceID), At(wait.since),
			wait.pull and (", a pull at " .. At(wait.pull.at) .. " by " .. tostring(wait.pull.how)) or ", no pull yet",
			wait.fresh and ", a new run asked for" or "", counts.xp, counts.copper, counts.items))
	end
	if not run then
		Add("no run")
	else
		local function At(stamp) return date and date("%H:%M:%S", stamp) or tostring(stamp) end
		local state = Run.ClockState(run)
		Add(string.format("run %s (id %s, wing %s)%s%s: in at %s, %s, paused %ds, clock %s (%s)", tostring(run.key),
			tostring(run.instanceID), tostring(run.wing), run.late and " joined late" or "", run.frozen and " kept" or "",
			run.enteredAt and At(run.enteredAt) or "?",
			run.startedAt and ("started " .. At(run.startedAt) .. " by " .. tostring(run.startedBy or "?"))
				or "waiting for the first pull",
			run.pausedSeconds or 0, Run.Clock(Run.Elapsed(run)),
			state == "paused" and ("paused since " .. At(run.pausedAt)) or state))
		for wing, killed in pairs(run.kills or {}) do
			for name, at in pairs(killed) do
				Add(string.format("  %s: %s at %s", wing, name, at == 0 and "?" or (date and date("%H:%M:%S", at) or at)))
			end
		end
		-- What Adventure Mode's record (Core/Discovery.lua) holds for each boss of the run's dungeon, in every style:
		-- none, met, fought or killed. A boss killed above but not here is how the block's "???" beside a cross shows.
		-- One line a part, for every part walked between inside (Run.SameCopy: Blackrock Spire's, Dire Maul's), as the
		-- kills above are; not the bosses the journal hides (not in the game yet: no record to have).
		local record = ns.Discovery and ns.Discovery:Record()
		if record then
			local levels = {}
			for name, rank in pairs(ns.Discovery.BOSS_LEVELS) do levels[rank] = name end
			for _, part in ipairs(Run.SameCopy(ns.GetInstance(run.wing or run.key))) do
				local held, said = record.bosses[part.key], {}
				for _, boss in ipairs(part.bosses or {}) do
					if not ns.IsLootSection(boss) and not (ns.Items and ns.Items:HidesBoss(boss)) then
						local rank = type(held) == "table" and held[ns.Discovery.BossKey(boss)]
						said[#said + 1] = boss.name .. " " .. (levels[rank] or "none")
					end
				end
				if #said > 0 then Add(string.format("  record, %s: %s", part.key, table.concat(said, ", "))) end
			end
		end
		Add(string.format("xp %d, coin %d, items %d worth %d, greed %d", run.xp or 0, run.copper or 0, run.items or 0,
			run.itemValue or 0, run.greed or 0))
	end
	Add(string.format("inside %s; xp shown %s (level %s, cap %s)", tostring(session.inside), tostring(Run.XPShown()),
		tostring(UnitLevel and UnitLevel("player")), tostring(type(GetMaxPlayerLevel) == "function" and GetMaxPlayerLevel())))
	for _, kind in ipairs({ "clock", "money", "loot", "xp" }) do
		for _, text in ipairs(session.log[kind]) do Add(kind .. ": " .. text) end
	end
	for index = 1, select("#", ...) do
		local extra = select(index, ...)
		if extra then Add(extra) end
	end
	for _, text in ipairs(lines) do ns.Print(text) end
	return lines
end
