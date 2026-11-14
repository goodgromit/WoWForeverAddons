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
	dungeon (Run.SameCopy): the parts walked between inside (Stratholme's halves, Blackrock Spire's, Dire Maul's:
	oneCopy in Data/Authored/RunTracker.lua) are one, so a wing change there keeps the run and a new run clears the
	kills of every part (DungeonMap:ClearRun); Scarlet Monastery's wings, each behind its own door, are each their
	own, though the client gives them one instance id.

	The clock: from the moment the run is decided new, to the kill of the dungeon's final boss (Data/Authored/
	RunTracker.lua, best guesses), else to the kill of the last boss counted. Its one line in chat comes
	SUMMARY_DELAY seconds after the clock stops, so that the final boss's loot is in it, or as the player leaves the
	dungeon, whichever is first (the owner's call at the 0.39.20 release): its time is kept with the run (summaryAt),
	so a /reload or a logout in between neither loses it nor gives it twice (run.told). Time logged out is not counted (the
	gap from PLAYER_LOGOUT to the next login is added to pausedSeconds; the part of it after the player was last
	inside is kept apart as pausedAway, and given back if the run is left behind, as its clock ends at
	lastInsideAt, before that gap); deaths, corpse runs and stepping out are.

	The numbers count only while inside the run's dungeon, with the block on (its events are registered there and
	nowhere else):
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
	off while it is an experiment. Turning it on by default is this one line (the options' box takes its default from
	here). A choice the player made, or the safety net's off, is kept as it is either way (KEPT).
]]
Run.INSIDE_DEFAULT = false

-- The block's options, for the whole account (UI/Options.lua): on, with its numbers and its chat summary; placed
-- freely; the experiment of placing it inside the game's quest tracker; dark mode for its gold art (UI/RunTracker.lua
-- Paint), off by default.
local OPTION_DEFAULTS = { on = true, numbers = true, free = false, summary = true, inside = Run.INSIDE_DEFAULT,
	darkMode = false }
-- Saved as chosen even when that is the default, so that a later change of the default leaves the choice be.
local KEPT = { inside = true }

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

-- This session's state: the client instance id the player is inside (nil outside), the baselines the numbers
-- count from (read again on every entering and login, never saved), which windows are open, the
-- coin pairing, the rolls chosen on Greed, and the last few readings for /ij run debug.
local session = { windows = {}, greed = {}, won = {}, log = { money = {}, loot = {}, xp = {} } }
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
	return not (boss.trash or boss.rare or boss.maybe or boss.questTarget or boss.outsideRun or boss.comingSoon
		or (ns.Items and ns.Items:HidesBoss(boss)))
end

--[[
	The dungeon's (or wing's) bosses as the block shows them, in the journal's order: one entry per fight, so two
	bosses of one encounter (Sneed's Shredder, then Sneed: encounter 2742) are one circle and one line, with the
	last one's name and face. Not counted: trash, rares, the Ring of Law's maybes, quest targets (the Excavation Site's
	Highland Horror, a quest's mob more than a boss: Data/Authored/ExcavationSiteWetlands.lua), bosses who stand
	outside the instance (outsideRun: Gnomeregan's Techbot, Data/Authored/RunTracker.lua), bosses coming soon and
	those the journal hides. Each entry: { boss = the face, parts = { boss, ... } }.

	An entry's name and face come from Run.EntryName and the block's ShowCircle (UI/RunTracker.lua), one place each.
]]
function Run.Bosses(instance)
	local list, byEncounter = {}, {}
	for _, boss in ipairs(instance and instance.bosses or {}) do
		if Counted(boss) then
			local entry = boss.encounterID and byEncounter[boss.encounterID]
			if entry then
				entry.parts[#entry.parts + 1] = boss
				entry.boss = boss
			else
				entry = { boss = boss, parts = { boss } }
				list[#list + 1] = entry
				if boss.encounterID then byEncounter[boss.encounterID] = entry end
			end
		end
	end
	return list
end

-- The bosses that get no circle and no place in the count, but a done line once killed: rares, maybes, quest
-- targets (one done by his quest is done here too: UI/DungeonMap.lua's IsDefeated). Not those outside the instance
-- (outsideRun): the journal sees no kill outside one, so their line could never come (0.39.21's review).
function Run.Others(instance)
	local list = {}
	for _, boss in ipairs(instance and instance.bosses or {}) do
		if (boss.rare or boss.maybe or boss.questTarget) and not boss.outsideRun and not boss.trash
			and not (ns.Items and ns.Items:HidesBoss(boss)) then
			list[#list + 1] = boss
		end
	end
	return list
end

function Run.EntryName(entry)
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

-- Seconds on the run's clock: to its stop, else (left behind) to when the player was last inside, else to now.
function Run.Elapsed(run)
	if not run then return 0 end
	local stop = run.endedAt or (run.frozen and run.lastInsideAt) or time()
	return math.max(0, stop - (run.startedAt or stop) - (run.pausedSeconds or 0))
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
	run.endedAt = run.endedAt or run.lastInsideAt or time()
	run.pending = nil
	db.lastRun, db.run = run, nil
	if run.summaryAt or (not run.finished and AnyKill(run)) then self:PrintSummary(run) end
end

function Run:Start(instance, late)
	local db = ns.charDB
	if not (db and instance) then return end
	if db.run then self:Freeze() end
	local now = time()
	db.run = {
		instanceID = instance.instanceID, key = instance.key, wing = instance.key, startedAt = now, pausedSeconds = 0,
		lastSeen = now, late = late or nil, xp = 0, copper = 0, itemValue = 0, items = 0, itemList = {}, greed = 0,
		pending = {}, kills = {},
	}
	session.greed, session.won = {}, {}
	if late then SeedKills(db.run, instance) end
	Log("xp", "run started" .. (late and " (joined late)" or ""))
end

-- A /ij run new: the map's kills cleared for every wing of this dungeon, and a new run from now.
function Run:NewRun()
	local instance = session.instance
	if not instance then return false end
	if ns.DungeonMap and ns.DungeonMap.ClearRun then ns.DungeonMap:ClearRun(instance) end
	self:Start(instance)
	if Baselines then Baselines() end
	if ns.DungeonMap then ns.DungeonMap:Refresh() end
	self:Changed()
	return true
end

local function Dead(boss)
	return ns.DungeonMap ~= nil and ns.DungeonMap:IsDefeated(session.instance, boss)
end

--[[
	The player came into the world (UI/DungeonMap.lua's PLAYER_ENTERING_WORLD, once it has decided the run):
	`instance` is the dungeon they are in (nil outside), `cleared` whether the map just started a new run there.
]]
function Run:Entered(instance, cleared, login, reload)
	local db = ns.charDB
	if not db then return end
	local now = time()
	login, reload = ns.Readable(login) == true, ns.Readable(reload) == true
	local run = db.run
	-- Time logged out is not the run's (from a logout anywhere, inside or out).
	if run and (login or reload) and run.loggedOutAt then
		if not run.endedAt then
			local gap = math.max(0, now - run.loggedOutAt)
			run.pausedSeconds = (run.pausedSeconds or 0) + gap
			-- Logged out once out of the dungeon (or logged out inside: lastInsideAt is the logout): past the end of
			-- a run left behind, so kept apart until the player is back in and the run goes on (Freeze gives it back).
			if run.lastInsideAt then run.pausedAway = (run.pausedAway or 0) + gap end
		end
		run.loggedOutAt = nil
	end
	local dungeon = instance and instance.kind ~= "raid" and instance or nil
	if not dungeon then
		if run and session.inside then run.lastInsideAt, run.lastSeen = now, now end
		session.inside, session.instance = nil, nil
		-- Out of the dungeon: a summary still waiting goes now.
		if run and run.summaryAt then self:PrintSummary(run) end
		-- Away longer than the map keeps a run: it is left behind.
		if run and run.lastInsideAt and now - run.lastInsideAt > SameRunSeconds() then self:Freeze() end
		self:Counting()
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
		run.endedAt, run.finished, run.finishedWing = now, true, dungeon.key
	end
	-- A summary still waiting (a /reload or a login inside since the clock stopped): its timer again, for what is left.
	if run.summaryAt then self:ScheduleSummary(run) end
	if Baselines then Baselines() end
	self:Counting()
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
	if not run.endedAt and Run.Finished(instance, function(other)
		return ns.DungeonMap:IsDefeated(instance, other)
	end) then
		-- The part it finished in: another part walked into afterwards (Stratholme, Blackrock Spire) is not done.
		run.endedAt, run.finished, run.finishedWing = now, true, instance.key
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
	local run = Run:Current()
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
	local run = Run:Current()
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
	local run = self:Current()
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
	local run = Run:Current()
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

-- The numbers' events: only inside the run's dungeon with the block on, else none.
-- Counting from the purse and experience as they are when it starts (not as a time it was off left them).
function Run:Counting()
	if session.inside and self:Current() and self:Option("on") then
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
		if run then
			local now = time()
			run.loggedOutAt, run.lastSeen = now, now
			-- Logged out inside: the server may log them in outside, and the run's time away counts from here.
			if session.inside then run.lastInsideAt = now end
		end
		return
	end
	-- The part the player stands in, where it is this run's (a fight in Stratholme's other half is kept as that
	-- half's), else the one entered by.
	local here = session.inside and ns.CurrentInstance(true)
	local instance = here and Run.InRun(run, here) and here or session.instance
	if not (run and instance and session.inside) then return end
	local encounterID, name = ...
	local killed = run.kills[instance.key] or {}
	for _, boss in ipairs(ns.BossesForFight(instance, Number(encounterID), ns.Readable(name))) do
		local at = killed[boss.name]
		if at and ns.DungeonMap:IsDefeated(instance, boss) and time() - at >= NEW_COPY_AFTER then
			Log("xp", "a fight started for " .. boss.name .. ", killed this run: a new run")
			Run:NewRun()
			return
		end
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
	if not run then
		Add("no run")
	else
		Add(string.format("run %s (id %s, wing %s)%s%s: started %s, paused %ds, clock %s%s", tostring(run.key),
			tostring(run.instanceID), tostring(run.wing), run.late and " joined late" or "", run.frozen and " kept" or "",
			date and date("%H:%M:%S", run.startedAt or 0) or tostring(run.startedAt), run.pausedSeconds or 0,
			Run.Clock(Run.Elapsed(run)), run.endedAt and " (stopped)" or ""))
		for wing, killed in pairs(run.kills or {}) do
			for name, at in pairs(killed) do
				Add(string.format("  %s: %s at %s", wing, name, at == 0 and "?" or (date and date("%H:%M:%S", at) or at)))
			end
		end
		Add(string.format("xp %d, coin %d, items %d worth %d, greed %d", run.xp or 0, run.copper or 0, run.items or 0,
			run.itemValue or 0, run.greed or 0))
	end
	Add(string.format("inside %s; xp shown %s (level %s, cap %s)", tostring(session.inside), tostring(Run.XPShown()),
		tostring(UnitLevel and UnitLevel("player")), tostring(type(GetMaxPlayerLevel) == "function" and GetMaxPlayerLevel())))
	for _, kind in ipairs({ "money", "loot", "xp" }) do
		for _, text in ipairs(session.log[kind]) do Add(kind .. ": " .. text) end
	end
	for index = 1, select("#", ...) do
		local extra = select(index, ...)
		if extra then Add(extra) end
	end
	for _, text in ipairs(lines) do ns.Print(text) end
	return lines
end
