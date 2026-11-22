local _, ns = ...
local L = ns.L

--[[
	The small Play button beside a dungeon's lore and a boss's (UI/EncounterPage.lua). Where the player has Spoken
	installed, it plays Spoken's own recording of that dungeon's or boss's story, through Spoken: its narrator, its
	queue, its voice. Spoken plays recordings only. The lore beside the button is Spoken's own text of that same story
	wherever Spoken tells one (Core/SpokenLore.lua, which finds it with this file's lookup), so the words shown are the
	words read. The owner's idea of 2026-11-13, from Spoken's Play button on the quest tracker. The journal ships none
	of Spoken's code, audio or art (its story text, with its author's permission: LICENSE-LORE.md): it asks the
	player's own copy, at run time, to play what that copy has.

	The look is that button's (Spoken 3.8.7 and 3.9.0: Spoken_Quests/Compatibility.lua's tracker adapter and
	Spoken/UI/Actions.lua's BoxPlay): 14 square, the quest log's tracking checkbox for its box (the game's
	QuestLog-icon-ticksquare atlas), black at 0.6 just inside it, the glyph at seven tenths of the box (10) at
	0.85 and full under the mouse, the box's own atlas added over itself at 0.7 for the highlight. Its play glyph is
	Spoken's own art, so here the game's own small Play and Stop take its place: common-dropdown-icon-play and
	common-dropdown-icon-stop, the gold icons of the game's dropdown menus. Grayed where it cannot play (the
	game's disabled look: desaturated, the glyph dim), its tooltip still shown.

	Its states are those of Spoken's own Play (Spoken/UI/Compendium.lua, PlayState and PlayClick): Stop while the
	story speaks, Replay once it is stopped at the head of Spoken's queue, Play otherwise. Stop pauses Spoken's
	queue, as Spoken's own button does (Spoken: pause is stop, and resume plays the line again from its start).

	Spoken promises other addons only what Spoken/API.lua defines (IsCompatible, IsPartOn, GetQueue, GetCurrent,
	GetNowPlaying, IsPaused, TogglePause, RegisterCallback, UnregisterCallback). Its places and bosses methods
	(SpokenPlaces, SpokenBossesAddon) and data tables (SpokenDungeons, SpokenBosses, SpokenBossCreatures,
	SpokenBossStories) are its own and may change in any update: every call is type-checked and made in pcall,
	and anything that fails reads as "no story", with nothing in chat and no error.

	A Spoken newer than 3.9.0 adds a story API of its own to Spoken/API.lua (HasStory, PlayStory, IsPlayingStory,
	StopStory: StoryPlayer below). Where the player's Spoken has it, the button asks it whether the story can play, and
	plays and stops it through it, for a dungeon by its instance map and for a boss by his encounter; Spoken's tables
	then only say why it can't, where they can (Resolve). The lookup in Spoken's own tables stays for an older Spoken,
	and for a boss or dungeon the journal has no such number for.

	Spoken keeps a place's story back until the character has found the place, and a boss's until the character has
	met him, unless the player unlocks them in Spoken's settings (Unlock Undiscovered Places, Unlock Unfound
	Bosses). SpokenPlaces:PlayLore and SpokenBossesAddon:PlayStory do not check that themselves (Spoken_Places/Core.lua
	asks other addons to check IsLocked first), so the button does, and is grayed for a story Spoken still keeps back.
	(Spoken's story API checks it itself.)

	Light: the lookup runs when a page is filled; Spoken's AUDIO_CHANGED callback is held only while a button that
	can play is shown (its page part's OnShow and OnHide), so no ticker and no OnUpdate. In the same window, where
	the words beside it are Spoken's story and the player's Spoken has its caption API, the word highlight's
	CLIP_STARTED and CLIP_STOPPED (UI/SpokenWords.lua).
]]

local SpokenButton = {}
ns.SpokenButton = SpokenButton

local SIZE, GLYPH_SIZE = 14, 10
local BOX_ATLAS, PLAY_ATLAS, STOP_ATLAS = "QuestLog-icon-ticksquare", "common-dropdown-icon-play", "common-dropdown-icon-stop"
-- On a client without those atlases: the classic chat frame's small gold arrow for Play, a gold square for Stop.
local PLAY_FALLBACK = "Interface\\ChatFrame\\ChatFrameExpandArrow"
local GLYPH_ALPHA, LIT_ALPHA, GRAYED_ALPHA = 0.85, 0.7, 0.4
local WHITE, GOLD, RED = { 1, 1, 1 }, { 1, 0.82, 0 }, { 1, 0.125, 0.125 }

SpokenButton.SIZE = SIZE

------------------------------------------------------------------------------------------
-- Spoken, as the player has it
------------------------------------------------------------------------------------------

local function Invoke(object, method, ...)
	local fn = object[method]
	if type(fn) ~= "function" then error("no " .. tostring(method)) end
	return fn(object, ...)
end

-- A method of one of Spoken's tables, looked up and called in pcall: true and what it returns; false where the
-- table or the method is missing, or the call failed.
local function Call(object, method, ...)
	if type(object) ~= "table" then return false end
	return pcall(Invoke, object, method, ...)
end
-- (also the word highlight's way to Spoken: UI/SpokenWords.lua)
SpokenButton.Call = Call

-- Spoken's player, where it is loaded and speaks the API this was written against: Spoken's own hard requirement
-- for its parts, `_G.Spoken and Spoken:IsCompatible(1)` (Spoken/API.lua).
local function Player()
	local spoken = rawget(_G, "Spoken")
	local ok, compatible = Call(spoken, "IsCompatible", 1)
	if ok and compatible == true then return spoken end
	return nil
end

-- Whether the player switched that part of Spoken off ("places", "bosses"), in Spoken's settings.
local function PartOff(spoken, part)
	local ok, on = Call(spoken, "IsPartOn", part)
	return ok and on == false
end

--[[
	Spoken's story API, in Spoken/API.lua after 3.9.0 (written by Spoken's author; not released yet on 2026-11-14):
	HasStory, PlayStory, IsPlayingStory and StopStory, each called with (kind, id) and each answering true or false.
	kind "instance" with a dungeon's instance map (GetInstanceInfo's 8th value: the journal's instanceID), or "boss"
	with a dungeon encounter (ENCOUNTER_START's first value: the journal's encounterID; world bosses have none).
	Recorded stories only: HasStory is false without Spoken's part for it, with that part switched off, with no voice
	that has the story, or with the story kept back from this character. PlayStory plays at once when nothing speaks,
	else after the line speaking. It came with no new API_VERSION (still 1), so the button looks for the functions
	themselves: all four, or it keeps to Spoken's tables (Resolve).
]]
local STORY_API = { "HasStory", "PlayStory", "IsPlayingStory", "StopStory" }

-- Spoken's player where it has the story API, else nil.
local function StoryPlayer(spoken)
	if type(spoken) ~= "table" then return nil end
	for _, method in ipairs(STORY_API) do
		local ok, fn = pcall(function() return spoken[method] end)
		if not ok or type(fn) ~= "function" then return nil end
	end
	return spoken
end

-- What the story API calls this story: "instance" and the dungeon's instance map, or "boss" and his encounter;
-- nil where the journal has no such number for it.
local function StoryID(kind, instance, boss)
	if kind == "boss" then
		-- (not the fight of a boss who only joins another's: Mograine in Whitemane's, Data/Authored/RunTracker.lua)
		local encounter = type(boss) == "table" and not boss.joinsFight and boss.encounterID
		if type(encounter) == "number" then return "boss", encounter end
		return nil
	end
	local map = type(instance) == "table" and instance.instanceID
	if type(map) == "number" then return "instance", map end
	return nil
end

-- One of the story API's calls, in pcall: Spoken's true or false; nil where the call failed or answered anything else.
local function AskStory(spoken, method, story)
	local ok, answer = Call(spoken, method, story[1], story[2])
	if ok and type(answer) == "boolean" then return answer end
	return nil
end

--[[
	Spoken's place stories for dungeons its dungeon table does not link (the owner's decision of 2026-11-17: Spoken's
	words wherever Spoken has a story for a dungeon): by the journal's key, the place in Spoken's places part
	({ uiMapID, key }, as Spoken_Places/Data/<language>/Subzones.lua files it), whose recording Spoken's place voices
	read as they read any place's. Taken only where Spoken's dungeon table links no story for the dungeon, so Spoken's
	own link wins once it has one, and only where the player's Spoken has that place (DungeonStory).
]]
local NAMED_PLACES = {
	-- Spoken_Places, Azshara (1447): "blackmaw hold", named Blackmaw Hold
	BlackmawHold = { 1447, "blackmaw hold" },
	-- Spoken_Places, Un'Goro Crater (1449): "shapers terrace", named The Shaper's Terrace
	ShapersTerrace = { 1449, "shapers terrace" },
	-- Spoken_Places, Riverglades (2548): "kroldok stronghold", named Krol'dok Stronghold
	KroldokStronghold = { 2548, "kroldok stronghold" },
}

local function Index(object, key) return object[key] end

-- object[key] in pcall where object is a table (one of Spoken's may throw on a lookup); nil otherwise.
local function Field(object, key)
	if type(object) ~= "table" then return nil end
	local ok, value = pcall(Index, object, key)
	if ok then return value end
	return nil
end

-- A name as Spoken keys a place (Spoken_Places/Core.lua's NormaliseAreaKey): lower case, apostrophes dropped, a
-- leading "the " dropped, anything else not a letter or a digit read as a space.
local function PlaceKey(name)
	if type(name) ~= "string" then return nil end
	local key = name:lower():gsub("'", ""):gsub("^the%s+", ""):gsub("[^a-z0-9]+", " ")
	key = key:match("^%s*(.-)%s*$")
	return key ~= "" and key or nil
end

-- Spoken's dungeon table's entry for a dungeon: by its instance map; where the journal has none for it, by Spoken's
-- English name for it there.
local function DungeonEntry(dungeons, instance)
	local map = instance.instanceID
	if type(map) == "number" then return Field(dungeons, map) end
	local name = PlaceKey(instance.enName or instance.name)
	if not name then return nil end
	for _, entry in pairs(dungeons) do
		if type(entry) == "table" and PlaceKey(Field(entry, 1)) == name then return entry end
	end
	return nil
end

-- Whether the player's Spoken has that place's words: its English text, which its places part always loads
-- (SpokenPlaces.CaptionLore.enUS.subzones[uiMapID][key].full; Spoken_Places/Language.lua).
local function HasPlace(mapID, key)
	local lore = Field(Field(rawget(_G, "SpokenPlaces"), "CaptionLore"), "enUS")
	local full = Field(Field(Field(Field(lore, "subzones"), mapID), key), "full")
	return type(full) == "string" and full ~= ""
end

--[[
	A dungeon's story: as Spoken links it (Spoken/Data/Dungeons.lua: SpokenDungeons.dungeons[instance map].story,
	{ uiMapID, key }, absent where Spoken has none), else the place NAMED_PLACES names for it, where the player's Spoken
	has that place (then true, third). Each wing of the Scarlet Monastery and of Dire Maul has its dungeon's instance
	map, so the wings share their dungeon's one story; Blackrock Depths and the Spire have none. Nil without Spoken's
	dungeon table (Spoken not loaded).
]]
local function DungeonStory(instance)
	if type(instance) ~= "table" then return nil end
	local dungeons = Field(rawget(_G, "SpokenDungeons"), "dungeons")
	if type(dungeons) ~= "table" then return nil end
	local story = Field(DungeonEntry(dungeons, instance), "story")
	local mapID, key = Field(story, 1), Field(story, 2)
	if type(mapID) == "number" and type(key) == "string" then return mapID, key end
	local named = NAMED_PLACES[instance.key]
	if named and HasPlace(named[1], named[2]) then return named[1], named[2], true end
	return nil
end

-- How Spoken files a boss: his English name in lower case, without punctuation, a dash read as a space
-- (Spoken_Bosses/Data/Bosses.lua's keys).
local function KeyOf(name)
	if type(name) ~= "string" then return nil end
	local key = name:lower():gsub("%-", " "):gsub("[^a-z0-9 ]", ""):gsub("%s+", " ")
	return (key:match("^ ?(.-) ?$"))
end

-- Bosses Spoken tells as one story, under the name of their fight: Uldaman's three dwarves.
local FIGHTS = { ["Eric \"The Swift\""] = "The Lost Dwarves", Olaf = "The Lost Dwarves", Baelog = "The Lost Dwarves" }

--[[
	The boss's story in Spoken's tables: his instance map and Spoken's key for him, or nil. Found by his creature
	(SpokenBossCreatures[map][key].creature), else his encounter (SpokenBosses.maps[map][n].ids), else his English
	name or one of his other names against Spoken's key or Spoken's English name for him (Spoken's key for Ras
	Frostwhisper is "ras frostwhisperer"), the name of his fight (FIGHTS), or the part of his name before a colon
	(the Ring of Law's six challengers, one Spoken story).
]]
local function BossStory(instance, boss)
	local map = instance and instance.instanceID
	if type(map) ~= "number" or type(boss) ~= "table" then return nil end
	local creatures = rawget(_G, "SpokenBossCreatures")
	creatures = type(creatures) == "table" and creatures[map]
	if type(creatures) == "table" and type(boss.npcID) == "number" then
		for key, entry in pairs(creatures) do
			if type(key) == "string" and type(entry) == "table" and entry.creature == boss.npcID then return map, key end
		end
	end
	local data = rawget(_G, "SpokenBosses")
	local list = type(data) == "table" and type(data.maps) == "table" and data.maps[map]
	if type(list) ~= "table" then return nil end
	-- Not by the fight of a boss who only joins another's (joinsFight: Mograine in Whitemane's): the story is hers.
	if type(boss.encounterID) == "number" and not boss.joinsFight then
		for _, entry in ipairs(list) do
			if type(entry) == "table" and type(entry.key) == "string" and type(entry.ids) == "table" then
				for _, id in ipairs(entry.ids) do
					if id == boss.encounterID then return map, entry.key end
				end
			end
		end
	end
	local english = boss.enName or boss.name
	local names = { KeyOf(FIGHTS[english] or english) }
	for _, alias in ipairs(type(boss.aliases) == "table" and boss.aliases or {}) do names[#names + 1] = KeyOf(alias) end
	local fight = type(english) == "string" and english:match("^(.-):") or nil
	if fight then names[#names + 1] = KeyOf(fight) end
	for _, entry in ipairs(list) do
		if type(entry) == "table" and type(entry.key) == "string" then
			local spokenName = KeyOf(entry[1])
			for _, name in ipairs(names) do
				if name == entry.key or name == spokenName then return map, entry.key end
			end
		end
	end
	return nil
end

--[[
	Whether Spoken keeps that story back from this character: true (locked), false (open), or nil where the
	check itself failed. A place: SpokenPlaces:IsLocked (Spoken_Places/UI/LoreWindow.lua: not found yet, with Unlock
	Undiscovered Places off). A boss: not met (SpokenBossesAddon:IsBossFound, Spoken_Bosses/Core.lua) with Unlock
	Unfound Bosses off (SpokenBossesAddon.Unlocked, Spoken_Bosses/UI/Bosses.lua; its setting
	SpokenBossesSettings.unlockUnfound where that is gone). Where Spoken has no such check at all, the story is open,
	as Spoken's own screens take it (`SpokenPlaces.IsLocked and SpokenPlaces:IsLocked(...)`, Spoken_Bosses/MapLore.lua).
]]
local function PlaceLocked(places, mapID, key)
	if type(places.IsLocked) ~= "function" then return false end
	local ok, locked = Call(places, "IsLocked", mapID, key)
	if not ok then return nil end
	return locked == true
end

local function BossLocked(bosses, map, key)
	if type(bosses.IsBossFound) ~= "function" then return false end
	local ok, found = Call(bosses, "IsBossFound", map, key)
	if not ok then return nil end
	if found == true then return false end
	if type(bosses.Unlocked) == "function" then
		local okUnlocked, unlocked = pcall(bosses.Unlocked)
		if not okUnlocked then return nil end
		return unlocked ~= true
	end
	local settings = rawget(_G, "SpokenBossesSettings")
	return not (type(settings) == "table" and settings.unlockUnfound == true)
end

-- Whether Spoken has the words of that boss's story (Spoken_Bosses/Data/Stories.lua), in any language.
local function HasStoryText(map, key)
	local stories = rawget(_G, "SpokenBossStories")
	local text = type(stories) == "table" and type(stories[map]) == "table" and stories[map][key]
	if type(text) == "table" then
		for _, words in pairs(text) do
			if type(words) == "string" and words ~= "" then return true end
		end
		return false
	end
	return type(text) == "string" and text ~= ""
end

--[[
	What a button stands for: { state, and where it can play: spoken, and either story ({ kind, id }: Spoken's story
	API) or clipKey (the story's key in Spoken's queue: "s:<uiMapID>:<key>" for a place, "boss:<map>:<key>" for a
	boss) and start }. The states:
	  missing      Spoken, or its places or bosses part, not loaded
	  none         no story for it, or no recording of it in the voices installed (or anything failed)
	  voices       a story, but none of Spoken's voices for it installed (its boss voices are a folder of their own,
	               SpokenBossesAudio, beside its place voices in its audio download, and may be left out)
	  off          that part of Spoken switched off in Spoken's settings
	  locked       a recording, but Spoken keeps the story back from this character: the place not found yet, the
	               boss not met (Spoken's own lock, which its settings can lift)
	  unavailable  Spoken's story API says it has none it can play, and the journal's own checks can't tell why
	  ready        a recording to play
	TableResolve looks in Spoken's own tables; Resolve asks the story API first, where Spoken has it.
]]
local function TableResolve(kind, instance, boss)
	local spoken = Player()
	if kind == "boss" then
		local bosses = rawget(_G, "SpokenBossesAddon")
		if not spoken or type(bosses) ~= "table" then return { state = "missing" } end
		local map, key = BossStory(instance, boss)
		if not key or not HasStoryText(map, key) then return { state = "none" } end
		if PartOff(spoken, "bosses") then return { state = "off" } end
		local ok, clip = Call(bosses, "GetAudioClip", map, key)
		if ok and type(clip) == "table" then
			local locked = BossLocked(bosses, map, key)
			if locked == nil then return { state = "none" } end
			if locked then return { state = "locked" } end
			return { state = "ready", spoken = spoken, clipKey = "boss:" .. map .. ":" .. key,
				start = function() return Call(bosses, "PlayStory", map, key) end }
		end
		-- "voices" only where Spoken says so (its list of boss voices empty), as for a place below: a failed call is
		-- "no story", never a request to install voices the player may already have.
		local okPacks, packs = Call(bosses, "GetAudioPacks")
		if okPacks and type(packs) == "table" and #packs == 0 then return { state = "voices" } end
		return { state = "none" }
	end
	local places = rawget(_G, "SpokenPlaces")
	if not spoken or type(places) ~= "table" then return { state = "missing" } end
	local mapID, key = DungeonStory(instance)
	if not mapID then return { state = "none" } end
	if PartOff(spoken, "places") then return { state = "off" } end
	local okVoice, voice = Call(places, "IsVoiceEnabled")
	if okVoice and voice == false then return { state = "off" } end
	-- Asked first: PlayLore itself says in chat when there is nothing to play.
	local ok, has = Call(places, "HasAudio", mapID, key)
	if ok and has == true then
		local locked = PlaceLocked(places, mapID, key)
		if locked == nil then return { state = "none" } end
		if locked then return { state = "locked" } end
		return { state = "ready", spoken = spoken, clipKey = "s:" .. mapID .. ":" .. key,
			start = function() return Call(places, "PlayLore", mapID, key) end }
	end
	local okPacks, packs = Call(places, "GetAudioPacks")
	if okPacks and type(packs) == "table" and #packs == 0 then return { state = "voices" } end
	return { state = "none" }
end

-- The reasons the journal's own checks can give where the story API's HasStory says no.
local REASONS = { off = true, locked = true, voices = true }

--[[
	The story API first, where the player's Spoken has it and the journal has the number it asks for: HasStory true,
	ready; false, grayed with the reason Spoken's tables give where it is one of REASONS, else "unavailable" (Spoken's
	plain no: its tables may no longer be the ones the journal reads, and the API answers for them). Where HasStory
	fails, Spoken's tables, as with an older Spoken. A dungeon whose story is a place the journal names for it
	(NAMED_PLACES), not one Spoken links: Spoken's tables alone, as the story API answers for Spoken's own links.
]]
local function Resolve(kind, instance, boss)
	local spoken = StoryPlayer(Player())
	local storyKind, id = StoryID(kind, instance, boss)
	if kind ~= "boss" and select(3, DungeonStory(instance)) == true then storyKind = nil end
	if spoken and storyKind then
		local story = { storyKind, id }
		local has = AskStory(spoken, "HasStory", story)
		if has == true then return { state = "ready", spoken = spoken, story = story } end
		if has == false then
			local ok, own = pcall(TableResolve, kind, instance, boss)
			if ok and type(own) == "table" and REASONS[own.state] then return { state = own.state } end
			return { state = "unavailable" }
		end
	end
	return TableResolve(kind, instance, boss)
end

-- The story Spoken has for a boss or a dungeon, as found (map, key; nil where none or anything failed; for a dungeon,
-- true third where it is a place NAMED_PLACES names), for the lore beside the button (Core/SpokenLore.lua: the words
-- and the button name the same story), Tools/build_spoken_lore.py and the tests; and what a button would stand for.
SpokenButton.BossStory = function(instance, boss)
	local ok, map, key = pcall(BossStory, instance, boss)
	if ok then return map, key end
	return nil
end
SpokenButton.DungeonStory = function(instance)
	local ok, map, key, named = pcall(DungeonStory, instance)
	if ok then return map, key, named end
	return nil
end
function SpokenButton.Resolve(kind, instance, boss)
	local ok, target = pcall(Resolve, kind, instance, boss)
	if ok and type(target) == "table" then return target end
	return { state = "none" }
end

--[[
	Spoken/UI/Compendium.lua's PlayState: "stop" while the story is the head of Spoken's queue and speaking,
	"replay" while it is the head and the queue is stopped, "play" otherwise (not queued, waiting, or held by a
	gate); and the story's line, where it is queued. With the story API: "stop" while Spoken says it plays the
	story (IsPlayingStory), else "play" (it has no stopped line to play again).
]]
local function PlayState(target)
	local spoken = target.spoken
	if target.story then return AskStory(spoken, "IsPlayingStory", target.story) == true and "stop" or "play", nil end
	local ok, queue = Call(spoken, "GetQueue")
	local clip
	if ok and type(queue) == "table" then
		for _, queued in ipairs(queue) do
			if type(queued) == "table" and queued.key == target.clipKey then
				clip = queued
				break
			end
		end
	end
	if not clip then return "play", nil end
	local okHead, head = Call(spoken, "GetCurrent")
	if not okHead or head ~= clip then return "play", clip end
	local okPaused, paused = Call(spoken, "IsPaused")
	if okPaused and paused == true then return "replay", clip end
	local okNow, now = Call(spoken, "GetNowPlaying")
	if okNow and now == clip then return "stop", clip end
	return "play", clip
end

local function SafePlayState(target)
	local ok, state, clip = pcall(PlayState, target)
	if ok then return state, clip end
	return "play", nil
end

------------------------------------------------------------------------------------------
-- The button
------------------------------------------------------------------------------------------

local function SetAtlas(texture, atlas, fallback)
	if ns.AtlasExists(atlas) then
		texture:SetAtlas(atlas)
		return true
	end
	if fallback then texture:SetTexture(fallback) else texture:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 1) end
	return false
end

local function Ready(button)
	return button.target ~= nil and button.target.state == "ready"
end

-- Its glyph for the state it is in, enabled or grayed.
local function Paint(button)
	local ready = Ready(button)
	button.playState = ready and SafePlayState(button.target) or "play"
	local glyph = button.playState == "stop" and STOP_ATLAS or PLAY_ATLAS
	if button.glyph ~= glyph then
		button.glyph = glyph
		SetAtlas(button.Glyph, glyph, glyph == PLAY_ATLAS and PLAY_FALLBACK or nil)
	end
	button:SetEnabled(ready)
	button.Glyph:SetDesaturated(not ready)
	button.Box:SetDesaturated(not ready)
	button.Glyph:SetAlpha(not ready and GRAYED_ALPHA or (button.over and 1 or GLYPH_ALPHA))
	button.Lit:SetShown(ready)
end

function SpokenButton.ShowTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	local state = button.target and button.target.state or "missing"
	local boss = button.kind == "boss"
	if state == "ready" then
		local play = button.playState
		GameTooltip:SetText(play == "stop" and L.SPOKEN_STOP or play == "replay" and L.SPOKEN_REPLAY or L.SPOKEN_PLAY,
			WHITE[1], WHITE[2], WHITE[3])
		GameTooltip:AddLine(L.SPOKEN_BY, GOLD[1], GOLD[2], GOLD[3], true)
	else
		local reason
		if state == "missing" then
			reason = L.SPOKEN_REQUIRES
		elseif state == "off" then
			reason = L.SPOKEN_OFF
		elseif state == "locked" then
			reason = boss and L.SPOKEN_LOCKED_BOSS or L.SPOKEN_LOCKED_PLACE
		elseif state == "voices" then
			reason = boss and L.SPOKEN_NEEDS_BOSS_VOICES or L.SPOKEN_NEEDS_PLACE_VOICES
		elseif state == "unavailable" then
			reason = L.SPOKEN_NO_STORY_YET
		else
			reason = boss and L.SPOKEN_NO_STORY_BOSS or L.SPOKEN_NO_STORY_PLACE
		end
		GameTooltip:SetText(reason, RED[1], RED[2], RED[3], 1, true)
		GameTooltip:AddLine(boss and L.SPOKEN_ABOUT_BOSS or L.SPOKEN_ABOUT_PLACE, GOLD[1], GOLD[2], GOLD[3], true)
	end
	GameTooltip:Show()
end

local function Refresh(button)
	Paint(button)
	if GameTooltip:GetOwner() == button and GameTooltip:IsShown() then SpokenButton.ShowTooltip(button) end
end

--[[
	The word highlight's two callbacks (UI/SpokenWords.lua), held beside AUDIO_CHANGED where the story's words beside
	the button are Spoken's story itself and the player's Spoken has its caption API: CLIP_STARTED (a line starts) and
	CLIP_STOPPED (one is stopped, skipped or done). AUDIO_CHANGED then also has the highlight look again.
]]
local WORD_EVENTS = { CLIP_STARTED = "Started", CLIP_STOPPED = "Stopped" }
local NONE = {}

local function UnlistenWords(button)
	for _, handle in ipairs(button.wordHandles or NONE) do Call(button.listening, "UnregisterCallback", handle) end
	button.wordHandles = nil
	if button.words then ns.SpokenWords.Release(button.words) end
end

local function ListenWords(button, spoken)
	local words = ns.SpokenWords
	if not (button.words and words.Wanted(button.words, spoken)) then
		UnlistenWords(button)
		return
	end
	if not button.wordHandles then
		local handles = {}
		for event, handler in pairs(WORD_EVENTS) do
			local ok, handle = Call(spoken, "RegisterCallback", event, function(clip)
				if button:IsVisible() then words[handler](button.words, clip) end
			end)
			if ok and handle ~= nil then handles[#handles + 1] = handle end
		end
		button.wordHandles = handles
	end
	words.Follow(button.words, spoken)
end

local function Unlisten(button)
	UnlistenWords(button)
	if button.handle then Call(button.listening, "UnregisterCallback", button.handle) end
	button.handle, button.listening = nil, nil
end

-- Spoken's AUDIO_CHANGED (after every change to its queue) while the button can play and is seen, with the word
-- highlight's callbacks where it is wanted; let go otherwise.
local function Listen(button)
	if not (Ready(button) and button:IsVisible()) then
		Unlisten(button)
		return
	end
	local spoken = button.target.spoken
	if not (button.handle and button.listening == spoken) then
		Unlisten(button)
		local ok, handle = Call(spoken, "RegisterCallback", "AUDIO_CHANGED", function()
			if button:IsVisible() then
				Refresh(button)
				if button.wordHandles then ns.SpokenWords.Update(button.words) end
			end
		end)
		if not (ok and handle ~= nil) then return end
		button.handle, button.listening = handle, spoken
	end
	ListenWords(button, spoken)
end

-- A click, as Spoken's own Play takes it (Compendium.lua's PlayClick): Stop and Replay stop Spoken's queue or play
-- the line again; a line waiting behind a stopped one plays now; one not queued is started; one waiting behind a
-- line speaking is left where it is. With the story API: StopStory while it plays, else PlayStory, which Spoken plays
-- at once or after the line speaking.
local function Click(button)
	if not Ready(button) then return end
	local target = button.target
	pcall(function()
		if target.story then
			if AskStory(target.spoken, "IsPlayingStory", target.story) == true then
				ns.PlaySoundKit("U_CHAT_SCROLL_BUTTON")
				AskStory(target.spoken, "StopStory", target.story)
			else
				AskStory(target.spoken, "PlayStory", target.story)
			end
			return
		end
		local state, clip = PlayState(target)
		if state == "stop" or state == "replay" then
			ns.PlaySoundKit("U_CHAT_SCROLL_BUTTON")
			Call(target.spoken, "TogglePause")
		elseif clip then
			local ok, paused = Call(target.spoken, "IsPaused")
			if ok and paused == true then
				ns.PlaySoundKit("U_CHAT_SCROLL_BUTTON")
				Call(clip.source, "PlayNow", clip)
			end
		else
			target.start()
		end
	end)
	Refresh(button)
end

--[[
	A button for kind "dungeon" (a dungeon's or a raid's story) or "boss", on parent; holder is the page part it
	shows with, whose showing and hiding start and end its listening; words the FontString beside it that holds the
	story, whose text UI/SpokenWords.lua sets and may light. Placed by its page.
]]
function SpokenButton.Create(parent, kind, holder, words)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(SIZE, SIZE)
	button:SetHitRectInsets(-2, -2, -2, -2)
	-- Its tooltip says why it is grayed: shown while it is disabled too.
	if button.SetMotionScriptsWhileDisabled then button:SetMotionScriptsWhileDisabled(true) end
	button.kind, button.words = kind, words
	button.Back = button:CreateTexture(nil, "BACKGROUND")
	button.Back:SetPoint("TOPLEFT", 1, -1)
	button.Back:SetPoint("BOTTOMRIGHT", -1, 1)
	button.Back:SetColorTexture(0, 0, 0, 0.6)
	button.Box = button:CreateTexture(nil, "BORDER")
	button.Box:SetAllPoints()
	if not ns.AtlasExists(BOX_ATLAS) then button.Box:Hide() else button.Box:SetAtlas(BOX_ATLAS) end
	button.Glyph = button:CreateTexture(nil, "ARTWORK")
	button.Glyph:SetSize(GLYPH_SIZE, GLYPH_SIZE)
	button.Glyph:SetPoint("CENTER")
	button.Lit = button:CreateTexture(nil, "HIGHLIGHT")
	button.Lit:SetAllPoints()
	if ns.AtlasExists(BOX_ATLAS) then button.Lit:SetAtlas(BOX_ATLAS) else button.Lit:SetColorTexture(1, 1, 1, 0.2) end
	button.Lit:SetBlendMode("ADD")
	button.Lit:SetAlpha(LIT_ALPHA)
	Paint(button)

	button:SetScript("OnClick", Click)
	button:SetScript("OnEnter", function(self)
		self.over = true
		Paint(self)
		SpokenButton.ShowTooltip(self)
	end)
	button:SetScript("OnLeave", function(self)
		self.over = false
		Paint(self)
		if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
	end)
	-- Pressed, the glyph a pixel down and right, as the game's buttons press.
	button:SetScript("OnMouseDown", function(self)
		if not self:IsEnabled() then return end
		self.Glyph:ClearAllPoints()
		self.Glyph:SetPoint("CENTER", 1, -1)
	end)
	button:SetScript("OnMouseUp", function(self)
		self.Glyph:ClearAllPoints()
		self.Glyph:SetPoint("CENTER")
	end)
	holder:HookScript("OnShow", function()
		if button.target then
			Paint(button)
			Listen(button)
		end
	end)
	holder:HookScript("OnHide", function() Unlisten(button) end)
	button:Hide()
	return button
end

-- Shows the button for this dungeon (boss nil) or this boss: its state looked up now.
function SpokenButton.Set(button, instance, boss)
	button.target = SpokenButton.Resolve(button.kind, instance, boss)
	button:Show()
	Refresh(button)
	Listen(button)
end

-- Hides it: nothing for it to sit beside.
function SpokenButton.Clear(button)
	button.target = nil
	button:Hide()
	Unlisten(button)
end

-- Whether it holds Spoken's callback now (for the tests).
function SpokenButton.Listening(button)
	return button.handle ~= nil
end
