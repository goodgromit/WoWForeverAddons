local _, ns = ...

--[[
	Test mode's pretend kills and finds (the owner's fog test of 2026-11-13, made test mode on 2026-11-18: "i cant pull
	up the maps when im outside of the dungeon or open that dungeons run block in adventure mode"). Test mode is opened
	from its panel (UI/TestPanel.lua: /aegis test, /ij test, /ij fogtest, or the options' Test mode button); this file
	keeps what it pretends. For this session only: off at every /reload and login, nothing of it saved.

	While it is on:
	- A pretend kill: a boss marked defeated, or standing again (a real kill too). From the panel's boss list and its
	  Next, All and Reset; a click on a boss's pin or on the fog's hint on the journal's dungeon map (UI/DungeonMap.lua's
	  OpenBoss and OpenPin, where every such click comes, instead of opening it); or a circle of the run block's
	  pretend run. All of them come to one place, Mark (SetKilled, SetSome), which also tells the pretend run
	  (UI/TestRun.lua: while the panel pretends the player is inside, it counts the kill as a real one would).
	- A pretend find: a dungeon shown as found in Adventure Mode (the panel's "Show as found", or the pretend run
	  walking in), SetFound.
	The fog, its hints and the pins are drawn again as if it were so (the pin crossed out, from anywhere:
	DungeonMap:ShowsDefeated), and in Adventure Mode the journal shows the boss as a kill would unlock it: its name and
	portrait in the boss list, its page, abilities, model and loot, its dungeon no longer a rumor (Core/Discovery.lua's
	pretend: Knows answers yes for the boss met, fought and killed, its dungeon entered and its loot seen off it). Every
	boss counts, a rare and one called up too. A dungeon that is still a rumor shows its Show Map while it is on
	(UI/EncounterPage.lua), and the panel's Show Map opens any dungeon's map from anywhere.

	Nothing real is touched: the pretend kills and finds are this file's and Discovery.pretend's alone. The run's kills
	(UI/DungeonMap.lua's IsDefeated and MarkDefeated, charDB.defeated), the real run (Core/Run.lua), the character's
	finds (charDB.discovered), the Record tab and the chat's lines for finds never hear of them. End test, or a /reload,
	and everything reads as before.

	Nothing of its own on the dungeon map: the fog, its hints and the pins are the map's, drawn as the marks say, so a
	map opened in test mode looks as it does in a real run (the owner, 2026-11-18, to take its pictures for a release:
	the bar that sat at the foot of the map is gone; the panel has the count and its Next, All, Reset and End test).
	No OnUpdate, no ticker, no hook.
]]

local FogTest = {}
ns.FogTest = FogTest

-- Discovery.pretend while the test is on (Core/Discovery.lua: bosses, entered, items), with this file's found, else nil.
local pretend
-- Told of every change (FogTest:OnChange): the pretend run, then the panel.
local listeners = {}

function FogTest:On()
	return pretend ~= nil
end

local function BossKey(boss)
	return ns.Discovery.BossKey(boss)
end

-- The bosses a pretend kill is for, in the boss list's order: the dungeon's bosses, not its trash nor the ones the
-- journal hides as not in the game yet, as the boss list (UI/EncounterPage.lua's BossesOf) and the pins
-- (UI/DungeonMap.lua's DrawPins) leave them out.
local function Bosses(instance)
	local list = {}
	for _, boss in ipairs(type(instance) == "table" and instance.bosses or {}) do
		if not ns.IsLootSection(boss) and not ns.Items:HidesBoss(boss) then list[#list + 1] = boss end
	end
	return list
end
FogTest.Bosses = Bosses

-- How a boss's pin shows it (DungeonMap:ShowsDefeated): while the test is on, as Discovery:Killed says, the same
-- answer the panel's boxes, the counts, Next, a click and the fog go by (a pretend mark, else the character's real
-- kill, from anywhere); nil with the test off (the run's own kills then).
function FogTest:Defeated(instance, boss)
	if not pretend or type(instance) ~= "table" or type(boss) ~= "table" then return nil end
	return ns.Discovery:Killed(instance, boss) == true
end

-- What Discovery reads besides the marks: the dungeons found (shown as found, or a boss of them pretend defeated), and
-- those bosses' loot.
local function Rebuild()
	local entered, items = {}, {}
	for key in pairs(pretend.found) do entered[key] = true end
	for key, bosses in pairs(pretend.bosses) do
		local instance = ns.GetInstance(key)
		for _, boss in ipairs(instance and instance.bosses or {}) do
			local bossKey = BossKey(boss)
			if bosses[bossKey] == true then
				entered[key] = true
				for _, row in ipairs(boss.loot or {}) do
					local itemID = row.itemID
					if type(itemID) == "number" then
						local seen = items[itemID] or {}
						items[itemID] = seen
						seen[key] = seen[key] or {}
						seen[key][bossKey] = true
					end
				end
			end
		end
	end
	pretend.entered, pretend.items = entered, items
end

-- The marks changed (or the test turned on or off): Discovery told (the fog at once, the journal's pages after the
-- burst), an open map drawn again, then whoever listens (the pretend run, the panel).
local function Changed()
	if pretend then Rebuild() end
	ns.Discovery:Pretend(pretend)
	ns.DungeonMap:Refresh()
	for _, listener in ipairs(listeners) do listener() end
end

-- fn(): called after every change of the marks and finds, and as the test turns on or off.
function FogTest:OnChange(fn)
	listeners[#listeners + 1] = fn
end

-- The one write of a kill: the mark, and the pretend run told (UI/TestRun.lua: it counts it, or takes it back, while
-- the panel pretends the player is inside a part of its run; else nothing).
local function Mark(instance, boss, dead)
	local bosses = pretend.bosses[instance.key] or {}
	pretend.bosses[instance.key] = bosses
	bosses[BossKey(boss)] = dead
	if ns.TestRun then ns.TestRun:Marked(instance, boss, dead) end
end

-- A boss defeated (dead = true) or standing again, a real kill too. False while the test is off.
function FogTest:SetKilled(instance, boss, dead)
	if not pretend or type(instance) ~= "table" or type(boss) ~= "table" then return false end
	Mark(instance, boss, dead == true)
	Changed()
	return true
end

-- Several bosses of one dungeon at once (a run block's circle of two, All, Reset): one change for them all.
function FogTest:SetSome(instance, bosses, dead)
	if not pretend or type(instance) ~= "table" then return false end
	for _, boss in ipairs(bosses or {}) do Mark(instance, boss, dead == true) end
	Changed()
	return true
end

-- A click on a boss's pin or hint (DungeonMap:OpenBoss): while the test is on, the boss defeated if it stands (a
-- real kill counts as defeated), else standing again; true, so the click opens nothing. False while it is off.
function FogTest:Clicked(instance, boss)
	if not pretend or type(instance) ~= "table" or type(boss) ~= "table" then return false end
	local dead = not ns.Discovery:Killed(instance, boss)
	ns.PlaySoundKit(dead and "IG_MAINMENU_OPTION_CHECKBOX_ON" or "IG_MAINMENU_OPTION_CHECKBOX_OFF")
	return self:SetKilled(instance, boss, dead)
end

-- The next boss still standing, in the boss list's order, defeated. False when none stands.
function FogTest:Next(instance)
	if not pretend then return false end
	for _, boss in ipairs(Bosses(instance)) do
		if not ns.Discovery:Killed(instance, boss) then return self:SetKilled(instance, boss, true) end
	end
	return false
end

-- Every boss defeated (all = true), or every one standing (false: Reset), a real kill too.
function FogTest:SetAll(instance, all)
	return self:SetSome(instance, Bosses(instance), all == true)
end

-- How many of the dungeon's bosses are down (real or pretend), and of how many.
function FogTest:Count(instance)
	local list, down = Bosses(instance), 0
	for _, boss in ipairs(list) do
		if ns.Discovery:Killed(instance, boss) then down = down + 1 end
	end
	return down, #list
end

-- A dungeon shown as found in Adventure Mode (the panel's "Show as found"; the pretend run walking in), or not;
-- later = true: one of several changes, the caller tells them all (UI/TestRun.lua's kill at the door).
function FogTest:SetFound(instance, found, later)
	if not pretend or type(instance) ~= "table" then return false end
	pretend.found[instance.key] = found and true or nil
	if not later then Changed() end
	return true
end

-- Whether the test shows this dungeon as found (the panel's box): not the character's own finds, nor a kill's.
function FogTest:Found(instance)
	return pretend ~= nil and type(instance) == "table" and pretend.found[instance.key] == true
end

-- The marks of one dungeon (bossKey = true, defeated; false, standing), for the panel's readout. Only read.
function FogTest:Marks(instance)
	return pretend and type(instance) == "table" and pretend.bosses[instance.key] or nil
end

-- The dungeons the test shows as found, by key, for the panel's readout. Only read.
function FogTest:FoundKeys()
	return pretend and pretend.found or nil
end

-- On, nothing marked or found yet (the panel's opening): true when it was off.
function FogTest:Start()
	if pretend then return false end
	pretend = { bosses = {}, entered = {}, items = {}, found = {} }
	Changed()
	return true
end

-- Off, every pretend kill and find forgotten (the panel's End test): true when it was on.
function FogTest:Stop()
	if not pretend then return false end
	pretend = nil
	Changed()
	return true
end
