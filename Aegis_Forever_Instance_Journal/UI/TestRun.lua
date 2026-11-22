local _, ns = ...
local L = ns.L

--[[
	Test mode's pretend run (the owner, 2026-11-18: "i cant ... open that dungeons run block in adventure mode"): the
	panel's "Pretend I'm inside" (UI/TestPanel.lua) shows the run block (UI/RunTracker.lua) for a dungeon, from
	anywhere, as it would show on walking in: its name with "(test)" after it, its circles, its clock waiting for the
	first pull (Play starts it), the count, the lock; at a Scarlet Monastery wing, the wait for the wing ("Which wing?")
	until Walk in, or a kill, names it. Test mode's kills (UI/FogTest.lua's Mark) count on it as a real kill counts on a
	real run: crossed out, the count, the lines, the clock started by the first one and stopped by the final boss's.

	It is a table of this file's alone, never the character's (charDB.run): the run block shows it through one seam
	(RunTracker:View asks Source, only outside a dungeon; a real run inside always wins, and walking into a dungeon ends
	the pretend one). It uses Core/Run.lua's own rules (Run.Bosses, Run.Others, Run.EntryDead, Run.Finished,
	Run.ClockState, Run.Elapsed, Run.InRun) and never its doings (Start, Entered, Killed, Freeze, NewRun,
	ScheduleSummary, PrintSummary, Counting, WatchPull): its clock's steps are a few lines each here, the same as Run's
	(Tools/testpanel_scenario.lua keeps the two in step). So no real run, kill, summary in chat or saved run hears of it,
	and it counts no experience, money or items (its numbers stay 0, as on coming in). Real fights and groupmates never
	start its clock: it listens to no event. For this session only: gone at a /reload, and at End test. The block's
	lock, its collapse and where it is dragged to are the test's own while it shows the pretend run (Look), so the real
	block keeps the character's.

	Each change tells the run block as a real run's change does (Run:Changed), which changes nothing of the real run.
]]

local TestRun = {}
ns.TestRun = TestRun
local Run = ns.Run

-- The pretend run (the fields of a run the block reads, test = true), else nil.
local run
-- At the door of a Scarlet Monastery wing, its wing not known yet: { instanceID, hidden }, else nil.
local waiting
-- The part of the run the block shows: the dungeon walked into, or the part of its copy walked into since (Upper
-- Blackrock Spire after Lower, a Dire Maul wing after another).
local here
-- The run changed by a kill (Marked): the block told once every kill of the change is in (FogTest's OnChange).
local dirty
-- The pretend block's lock, collapse and dropped spot (runLocked, runCollapsed, runSpot: Look), else nil.
local look

-- Pretending to be inside: a run, or the wait at the door.
function TestRun:Pretending()
	return run ~= nil or waiting ~= nil
end

-- The run, the part shown and the wing's wait, for the panel's readout and the tests. Only read.
function TestRun:Current() return run, here, waiting end

-- At the door of this client instance id's wings, the wing not known yet.
function TestRun:Waiting()
	return waiting and waiting.instanceID or nil
end

-- Really inside a dungeon, or at the door of a wing: the block shows the real run then, never the pretend one.
function TestRun:RealInside()
	return Run:Inside() ~= nil or Run:WaitingForWing() ~= nil
end

-- With "Inside the quest tracker" ticked, in a fight: showing, hiding or reshaping the block waits, as New run does
-- (RunTracker:RestartBlocked). fight = true: a fight just begun, the game's lockdown not started yet (the panel's).
function TestRun:Blocked(fight)
	return ns.RunTracker ~= nil and ns.RunTracker:RestartBlocked(fight) == true
end

-- Why pretending to be inside this one cannot start now, for the panel's box ("raid", "real", "off", "combat"); nil
-- when it can. fight: as Blocked's.
function TestRun:Refused(instance, fight)
	if type(instance) ~= "table" or instance.kind == "raid" then return "raid" end
	if self:RealInside() then return "real" end
	if not Run:Option("on") then return "off" end
	if self:Blocked(fight) then return "combat" end
	return nil
end

--[[
	The pretend block's lock, its header's collapse and its dropped spot (UI/RunTracker.lua's Kept, while the block
	shows the pretend run): from = the character's, copied the first time (the spot a copy of its own), so the pretend
	block starts where the real one is; then the test's alone, kept from one pretend run to the next until End test (or
	/ij run reset: ForgetLook) and gone at a /reload. Nil with no copy yet and no from, or with the test off.
]]
function TestRun:Look(from)
	if not ns.FogTest:On() then
		look = nil
		return nil
	end
	if not look and type(from) == "table" then
		local spot = from.runSpot
		look = { runLocked = from.runLocked, runCollapsed = from.runCollapsed,
			runSpot = type(spot) == "table" and { spot[1], spot[2], spot[3], spot[4] } or nil }
	end
	return look
end

function TestRun:ForgetLook()
	look = nil
end

local function Changed()
	Run:Changed()
end

-- A run of this part as on coming in: the clock waiting for the first pull, no kills, its numbers at 0.
local function NewRun(instance)
	local now = time()
	return { test = true, key = instance.key, instanceID = instance.instanceID, wing = instance.key, enteredAt = now,
		pausedSeconds = 0, xp = 0, copper = 0, itemValue = 0, items = 0, itemList = {}, greed = 0, pending = {}, kills = {} }
end

-- Its kills of one part, by boss name (as a real run keeps them).
local function Dead(instance)
	return function(boss)
		local killed = run and run.kills[instance.key]
		return killed ~= nil and killed[boss.name] ~= nil
	end
end

-- The clock's steps, as Core/Run.lua's: a pause ended at `at` adds its time to the time not counted; stopped at
-- `at` (the final boss), a pause then ends there.
local function SettlePause(at)
	if not run.pausedAt then return end
	run.pausedSeconds = (run.pausedSeconds or 0) + math.max(0, at - run.pausedAt)
	run.pausedAt = nil
end

local function StopClock(at)
	SettlePause(at)
	run.startedAt = run.startedAt or at
	run.endedAt = at
end

-- Walked in: a new run of the part, and the dungeon found as walking in finds it (UI/FogTest.lua's SetFound; later:
-- the caller tells the change).
local function Begin(instance, later)
	run, here, waiting = NewRun(instance), instance, nil
	ns.FogTest:SetFound(instance, true, later)
end

--[[
	The panel's box ticked: the block as on walking into this dungeon. At a Scarlet Monastery wing, the door first (no
	run, no clock, the dungeon not found yet: Walk in or a kill names the wing). Refused (false) for a raid, while
	really inside, with the block off, and in a fight with the block inside the quest tracker (Refused).
]]
function TestRun:Enter(instance)
	if self:Refused(instance) then return false end
	if ns.WingsAreCopies(instance.instanceID) then
		run, here, waiting = nil, nil, { instanceID = instance.instanceID }
	else
		Begin(instance)
	end
	Changed()
	return true
end

-- The box unticked, End test: left, the run dropped (nothing frozen, kept or told). False when not pretending.
function TestRun:Leave()
	if not self:Pretending() then return false end
	run, here, waiting, dirty = nil, nil, nil, nil
	Changed()
	return true
end

-- Walk in (the panel's button: the wing shown in its dungeon menu), or a kill of one of a wing's bosses at the door
-- (later: inside a change UI/FogTest.lua tells), as a real wing's first room or fight names it. The hidden choice of
-- /ij run goes with it, as the real wait's does.
function TestRun:WalkIn(wing, later)
	if not (waiting and type(wing) == "table" and wing.instanceID == waiting.instanceID) then return false end
	local hidden = waiting.hidden
	Begin(wing, later)
	run.hidden = hidden
	if later then dirty = true else Changed() end
	return true
end

--[[
	The panel's dungeon changed while pretending: another wing at the door, the wait goes on; another part of the same
	copy (Run.InRun: Blackrock Spire's, Dire Maul's), walked into, the run going on there; anything else, the pretend
	run left and the new dungeon walked into (a raid: only left). True while still pretending.
]]
function TestRun:Move(instance)
	if not self:Pretending() or type(instance) ~= "table" then return false end
	if waiting and instance.instanceID == waiting.instanceID then return true end
	if run and instance == here then return true end
	if run and Run.InRun(run, instance) then
		here = instance
		run.wing = instance.key
		ns.FogTest:SetFound(instance, true)
		Changed()
		return true
	end
	run, here, waiting, dirty = nil, nil, nil, nil
	if self:Enter(instance) then return true end
	Changed()
	return false
end

--[[
	A test kill (UI/FogTest.lua's Mark), as a real kill reaches the real run (Run:Killed): only while pretending to be
	inside a part of this run. Kept with its time; the clock started by it if it still waits for the first pull ("a
	kill"); stopped at the final boss, else the last counted (Run.Finished), the run done: no summary, no chat line. A
	kill taken back (standing again): gone from the run, and a run it had finished goes on, its stopped time not
	counted, so its clock does not jump. At the door, a kill of one of the wing's bosses names the wing first.
]]
function TestRun:Marked(instance, boss, dead)
	if not self:Pretending() or type(instance) ~= "table" or type(boss) ~= "table" then return end
	if waiting then
		if not (dead and instance.instanceID == waiting.instanceID) then return end
		self:WalkIn(instance, true)
	end
	if not Run.InRun(run, instance) then return end
	local killed = run.kills[instance.key] or {}
	run.kills[instance.key] = killed
	local now = time()
	if dead then
		if killed[boss.name] then return end
		killed[boss.name] = now
		if Run.ClockState(run) == "waiting" then run.startedAt, run.startedBy = now, "a kill" end
		if not run.endedAt and Run.Finished(instance, Dead(instance)) then
			StopClock(now)
			run.finished, run.finishedWing = true, instance.key
		end
	else
		if not killed[boss.name] then return end
		killed[boss.name] = nil
		if run.finished and run.finishedWing == instance.key and not Run.Finished(instance, Dead(instance)) then
			run.pausedSeconds = (run.pausedSeconds or 0) + math.max(0, now - (run.endedAt or now))
			run.endedAt, run.finished, run.finishedWing = nil, nil, nil
		end
	end
	dirty = true
end

-- The block's clock button on the pretend run: start a clock still waiting, pause a running one, resume a paused one
-- (its pause not counted); nothing once it stopped. What it did, or nil.
function TestRun:ToggleClock()
	if not run then return nil end
	local state, now, did = Run.ClockState(run), time(), nil
	if state == "waiting" then
		run.startedAt, run.startedBy, did = now, "the player", "started"
	elseif state == "running" then
		run.pausedAt, did = now, "paused"
	elseif state == "paused" then
		SettlePause(now)
		did = "resumed"
	end
	if did then Changed() end
	return did
end

-- The block's New run (its popup's Yes) on the pretend run: no kills, the clock waiting again. The test's kills stay,
-- as a real new run does not bring the fog back.
function TestRun:NewRun()
	if not run then return false end
	local hidden = run.hidden
	run = NewRun(here)
	run.hidden = hidden
	Changed()
	return true
end

-- A circle of the pretend run clicked (UI/RunTracker.lua): its fight killed in this run if it is not yet (each of its
-- bosses: Sneed's Shredder and Sneed), else every one of them standing again.
function TestRun:ToggleEntry(entry, instance)
	if not (run and type(entry) == "table" and type(instance) == "table") then return false end
	return ns.FogTest:SetSome(instance, entry.parts, not Run.EntryDead(entry, Dead(instance)))
end

-- /ij run while pretending: the pretend block hidden or shown again, as /ij run does for a real run. True, and
-- whether it is hidden now; false when not pretending.
function TestRun:ToggleHidden()
	local target = run or waiting
	if not target then return false end
	target.hidden = not target.hidden or nil
	return true, target.hidden == true
end

--[[
	What the run block shows for the pretend run (RunTracker:View), outside a dungeon only: { waiting, instanceID,
	hidden, title } at the door; else { run, instance, title, dead }. Nil when not pretending or really inside.
]]
function TestRun:Source()
	if not self:Pretending() or self:RealInside() then return nil end
	if waiting then
		local wing = ns.GetInstancesByInstanceID(waiting.instanceID)[1]
		local name = wing and (ns.DungeonMap.Building(wing.name) or wing.name) or ""
		return { waiting = true, instanceID = waiting.instanceID, hidden = waiting.hidden,
			title = string.format(L.TEST_RUN_TITLE, name) }
	end
	return { run = run, instance = here, title = string.format(L.TEST_RUN_TITLE, here.name), dead = Dead(here) }
end

-- The run's state for /ij test debug: one line.
function TestRun:DebugText()
	if waiting then
		return string.format("pretend run: at the door of instance %s (which wing?)%s", tostring(waiting.instanceID),
			waiting.hidden and ", hidden" or "")
	end
	if not run then return "pretend run: none" end
	local function At(stamp) return date and date("%H:%M:%S", stamp) or tostring(stamp) end
	local list, dead = Run.Bosses(here), Dead(here)
	local down = 0
	for _, entry in ipairs(list) do
		if Run.EntryDead(entry, dead) then down = down + 1 end
	end
	local kills = {}
	for part, killed in pairs(run.kills) do
		for name, at in pairs(killed) do
			kills[#kills + 1] = (part ~= here.key and part .. ": " or "") .. name .. " " .. At(at)
		end
	end
	table.sort(kills)
	return string.format("pretend run: %s (part %s), clock %s %s%s, paused %ds, %d/%d: %s; finished %s%s",
		tostring(run.key), tostring(here.key), Run.ClockState(run), Run.Clock(Run.Elapsed(run)),
		run.startedBy and " (started by " .. run.startedBy .. ")" or "", run.pausedSeconds or 0, down, #list,
		#kills > 0 and table.concat(kills, ", ") or "no kills", run.finished and "yes" or "no",
		run.hidden and ", hidden" or "")
end

-- Every kill of a change in: the block told once (UI/FogTest.lua's OnChange, which this file hears before the panel).
-- The test ended: the pretend block's lock, collapse and spot forgotten with it.
ns.FogTest:OnChange(function()
	if not ns.FogTest:On() then look = nil end
	if not dirty then return end
	dirty = nil
	Changed()
end)

-- Walked into a real dungeon (or a wing's door): the real run shows (RunTracker:View asks Source, which says nothing
-- then) and the pretend one ends, once, with a line in chat. Heard after the block's own refresh (UI/RunTracker.lua's
-- listener comes first).
Run:OnChange(function()
	if TestRun:Pretending() and TestRun:RealInside() then
		run, here, waiting, dirty = nil, nil, nil, nil
		ns.Print(L.TEST_RUN_ENDED)
	end
end)
