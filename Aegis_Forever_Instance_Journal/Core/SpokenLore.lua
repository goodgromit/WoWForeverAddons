local _, ns = ...

--[[
	A dungeon's and a boss's lore, wherever Spoken tells its story: Spoken's own words, word for word, so the journal
	shows what Spoken reads aloud and shows in its narrator (the owner's decision of 2026-11-14, with the permission of
	Spoken's author; the text's license: LICENSE-LORE.md). Where Spoken has no story, no lore: the description, as before
	(UI/EncounterPage.lua's LoreText; the owner's decision of 2026-11-17, "match what spoken has or leave it blank").

	Which story: the Play button's own lookup in Spoken's tables (UI/SpokenButton.lua's DungeonStory and BossStory), so
	the words and the button name the same story. The field Spoken reads:
	  a dungeon  the full text of the place Spoken's dungeon table links (SpokenDungeons.dungeons[instance map].story,
	             { uiMapID, key }; Spoken_Places/Data/<language>/Subzones.lua's full), or where it links none, of the
	             place UI/SpokenButton.lua's NAMED_PLACES names for it (Blackmaw Hold, the Shaper's Terrace, Krol'dok
	             Stronghold: Spoken's place stories of those names). Spoken's voice reads all of it and nothing else
	             (its word timings count full's words), and its narrator and its own windows show it.
	  a boss     his story (Spoken_Bosses/Data/Stories.lua: one text in each language, its English the first).
	Where one of Spoken's voice packs carries its own words for a story in that language, those first, as Spoken shows
	them first (Spoken_Places/UI/LorePage.lua's LoreText, Spoken_Bosses/UI/Bosses.lua's Story): they are what that
	voice says. Shown as Spoken has it, its paragraphs (an empty line between them) and all.

	Read from the player's own Spoken where it is loaded and has the story, so the words match the recording installed
	even after Spoken changes its stories; else from the copy the journal ships (Data/Generated/SpokenLore.lua, written
	by Tools/build_spoken_lore.py from Spoken's files). In the language Spoken itself shows the story in, so the page and
	Spoken's own windows and narrator always match (the owner's decision of 2026-11-17, "go with your recommendation"):
	  a dungeon  Spoken's text language for its places, where the player's Spoken_Places is loaded and answers
	             (SpokenPlaces:GetLanguage(), Spoken_Places/Language.lua: its Text Language setting, or with Auto the
	             client's language once Spoken's text in it is ready, else English; settled when Spoken loads, so a
	             change there takes a /reload, as Spoken says); the client's language where it is missing or doesn't
	             answer (SpokenLanguage)
	  a boss     the client's language, as Spoken's bosses show his story (Spoken_Bosses/UI/Bosses.lua's CoreStory and
	             Story: GetLocale(); they have no setting of their own)
	/aegis lang still overrides both, so a translation's pages can be checked in it (the owner was told so on
	2026-11-17). Where Spoken has the story in that language, in it, else in Spoken's English, the language its voice
	speaks:
	  1. the player's Spoken, in that language
	  2. the shipped copy, in that language
	  3. the player's Spoken, in English
	  4. the shipped copy, in English
	The shipped copy keeps only English, the journal's language and Spoken's text language once it has loaded
	(AddSpokenLore). Spoken loads its places' text in its own text language, in English and in its voices' languages
	only: in another language (/aegis lang's), the shipped copy's words.

	Spoken's tables and its places and bosses parts are its own and may change in any update: every lookup and call is
	type-checked and made in pcall, and anything that fails reads as "not in the player's Spoken" (the shipped copy
	then), with no error and nothing in chat. Light: looked up when a page is drawn, once for each dungeon or boss
	(kept while Spoken's tables are the same ones), no ticker.
]]

local SpokenLore = {}
ns.SpokenLore = SpokenLore

local ENGLISH = "enUS"

-- The shipped copy: which story each dungeon (by its key) and boss (by his English name, under his dungeon's key) has,
-- as Spoken keys them ("s:<uiMapID>:<key>" for a place, "boss:<instance map>:<key>" for a boss), and their words by
-- language.
local shipped = { instances = {}, bosses = {}, text = {} }

local function Words(text)
	if type(text) == "string" and text ~= "" then return text end
	return nil
end

local function Index(object, key) return object[key] end

-- object[key] in pcall where object is a table (one of Spoken's may throw on a lookup); nil otherwise.
local function Field(object, key)
	if type(object) ~= "table" then return nil end
	local ok, value = pcall(Index, object, key)
	if ok then return value end
	return nil
end

-- object:method(...), looked up and called in pcall: its first answer, or nil where it is missing or failed.
local function Ask(object, method, ...)
	local fn = Field(object, method)
	if type(fn) ~= "function" then return nil end
	local ok, answer = pcall(fn, object, ...)
	if ok then return answer end
	return nil
end

--[[
	Spoken's text language for its places: what SpokenPlaces:GetLanguage() answers (Spoken_Places/Language.lua, the
	language its lore window, its map and its narrator show a place's story in), a locale code such as "enUS" or "deDE"
	(four letters: Spoken's codes, a voice pack's own language's too). Nil where the player's Spoken_Places is not
	loaded, has no such method, fails, or answers anything else. Not part of the API Spoken promises (Spoken/API.lua),
	so asked like any of its methods. Asked when a page is drawn (it is a field read in Spoken), never kept: Spoken
	settles it once when it loads.
]]
local function SpokenLanguage()
	local code = Ask(rawget(_G, "SpokenPlaces"), "GetLanguage")
	if type(code) == "string" and code:find("^%a%a%a%a$") then return code end
	return nil
end

--[[
	The language a story is shown in (place true for a dungeon's, false for a boss's), and why: "preview" (/aegis
	lang's, which overrides Spoken's so a translation can be checked), "spoken" (Spoken's text language, a dungeon's
	only), or "client" (the client's, as Spoken's bosses use it, and a dungeon's where the player's Spoken doesn't say).
]]
local function Language(place)
	local code = ns.previewLocale
	if type(code) == "string" and code ~= "" then return code, "preview" end
	code = place and SpokenLanguage()
	if code then return code, "spoken" end
	code = GetLocale and GetLocale()
	if type(code) == "string" and code ~= "" then return code, "client" end
	return ENGLISH, "client"
end

--[[
	Data/Generated/SpokenLore.lua's way in: ns.AddSpokenLore({ spoken, instances, bosses }) for which story each has,
	then ns.AddSpokenLore(language, { [story] = words }) for each language, kept only for English, the journal's
	language and the language a dungeon's story shows in (Spoken's text language, where it differs; the others let go
	with the file's chunk, as Spoken's own data files skip the languages it does not read). Spoken_Places loads before
	the journal (an optional dependency in its TOC), so its text language is settled by then.
]]
function ns.AddSpokenLore(code, texts)
	if type(code) == "table" then
		shipped.spoken = code.spoken
		shipped.instances = type(code.instances) == "table" and code.instances or {}
		shipped.bosses = type(code.bosses) == "table" and code.bosses or {}
	elseif type(code) == "string" and type(texts) == "table"
		and (code == ENGLISH or ns.Speaks(code) or code == Language(true)) then
		shipped.text[code] = texts
	end
end

--[[
	The player's Spoken's words for a story (kind "s" a place, "boss" a boss; Spoken's map and key) in a language, or nil.
	A place's: a voice pack's own words for it in that language (SpokenPlaces:PackLoreText, Spoken_Places/Audio.lua),
	else its full text in that language as Spoken loaded it (SpokenPlaces.CaptionLore[language].subzones[uiMapID][key],
	Spoken_Places/Language.lua's RegisterLoreData). A boss's: a voice pack's own words (SpokenBossesAddon:PackStoryText,
	Spoken_Bosses/Audio.lua), else SpokenBossStories[map][key]: English its first, each other language by its code.
]]
local function Installed(kind, map, key, code)
	if kind == "s" then
		local places = rawget(_G, "SpokenPlaces")
		local packed = Words(Ask(places, "PackLoreText", map, key, code))
		if packed then return packed end
		local place = Field(Field(Field(Field(Field(places, "CaptionLore"), code), "subzones"), map), key)
		return Words(Field(place, "full"))
	end
	local packed = Words(Ask(rawget(_G, "SpokenBossesAddon"), "PackStoryText", map, key, code))
	if packed then return packed end
	local story = Field(Field(rawget(_G, "SpokenBossStories"), map), key)
	if type(story) == "string" then return code == ENGLISH and Words(story) or nil end
	return Words(Field(story, code == ENGLISH and 1 or code))
end

-- The story the Play button stands for, in the player's Spoken (UI/SpokenButton.lua's lookup): its kind, map and key;
-- nil without Spoken's tables, or where they have none for it.
local function Found(instance, boss)
	local button = ns.SpokenButton
	if type(button) ~= "table" then return nil end
	local map, key
	if boss then
		if type(button.BossStory) == "function" then map, key = button.BossStory(instance, boss) end
	elseif type(button.DungeonStory) == "function" then
		map, key = button.DungeonStory(instance)
	end
	if type(map) == "number" and type(key) == "string" then return boss and "boss" or "s", map, key end
	return nil
end

-- The story the shipped copy gives this dungeon or boss, or nil.
local function ShippedStory(instance, boss)
	if boss then
		local bosses = shipped.bosses[instance.key]
		return type(bosses) == "table" and bosses[boss.enName or boss.name] or nil
	end
	return shipped.instances[instance.key]
end

local function ShippedWords(story, code)
	local texts = shipped.text[code]
	return story and type(texts) == "table" and Words(texts[story]) or nil
end

--[[
	The words and where they came from ({ story, from = "spoken" or "shipped", language }), in the order above; with
	installed false, the shipped copy's alone. Where the player's Spoken names a story it has no words for, the shipped
	copy's story for this dungeon or boss, where it has one.
]]
local function Resolve(instance, boss, installed)
	local code = Language(boss == nil)
	local kind, map, key
	if installed then kind, map, key = Found(instance, boss) end
	local found = kind and (kind .. ":" .. map .. ":" .. key) or nil
	local story = found or ShippedStory(instance, boss)
	local function From(text, source, language, which)
		return text, { story = which or story, from = source, language = language }
	end
	local text
	if code ~= ENGLISH then
		text = found and Installed(kind, map, key, code)
		if text then return From(text, "spoken", code) end
		text = ShippedWords(story, code)
		if text then return From(text, "shipped", code) end
	end
	text = found and Installed(kind, map, key, ENGLISH)
	if text then return From(text, "spoken", ENGLISH) end
	text = ShippedWords(story, ENGLISH)
	if text then return From(text, "shipped", ENGLISH) end
	local own = found and ShippedStory(instance, boss)
	if own and own ~= found then
		text = code ~= ENGLISH and ShippedWords(own, code)
		if text then return From(text, "shipped", code, own) end
		text = ShippedWords(own, ENGLISH)
		if text then return From(text, "shipped", ENGLISH, own) end
	end
	return nil
end

-- What each dungeon's or boss's lookup gave, by its table (weak), with Spoken's tables as they were then: looked up
-- again only where one of those is another table now (Spoken loaded, or gone), or the language changed.
local SPOKEN_TABLES = { "SpokenPlaces", "SpokenDungeons", "SpokenBossesAddon", "SpokenBosses", "SpokenBossCreatures",
	"SpokenBossStories" }
local seen = setmetatable({}, { __mode = "k" })

local function Current(kept, code)
	if not kept or kept.language ~= code then return false end
	for index, name in ipairs(SPOKEN_TABLES) do
		if rawget(_G, name) ~= kept[index] then return false end
	end
	return true
end

--[[
	Spoken's words for this dungeon (boss nil) or boss, and where they came from ({ story, from, language }); nil where
	Spoken has no story for it (the description then), and for the trash and the recipes (ns.IsLootSection).
]]
function SpokenLore.Text(instance, boss)
	if type(instance) ~= "table" or (boss ~= nil and type(boss) ~= "table") or (boss and ns.IsLootSection(boss)) then
		return nil
	end
	local entry, code = boss or instance, Language(boss == nil)
	local kept = seen[entry]
	if Current(kept, code) then return kept.text, kept.info end
	local ok, text, info = pcall(Resolve, instance, boss, true)
	if not ok then ok, text, info = pcall(Resolve, instance, boss, false) end
	if not ok then text, info = nil, nil end
	kept = { language = code, text = text, info = info }
	for index, name in ipairs(SPOKEN_TABLES) do kept[index] = rawget(_G, name) end
	seen[entry] = kept
	return text, info
end

--[[
	For Tools/build_spoken_lore.py and the tests: the story the player's Spoken has for this dungeon or boss
	("s:<uiMapID>:<key>" or "boss:<map>:<key>") and its words in a language there, nil where it has none; and the
	shipped copy's story for it, and that version of Spoken's.
]]
function SpokenLore.Read(instance, boss, code)
	local ok, story, text = pcall(function()
		local kind, map, key = Found(instance, boss)
		if not kind then return nil end
		return kind .. ":" .. map .. ":" .. key, Installed(kind, map, key, code or ENGLISH)
	end)
	if ok then return story, text end
	return nil
end

function SpokenLore.Shipped(instance, boss)
	if type(instance) ~= "table" then return nil end
	return ShippedStory(instance, boss), shipped.spoken
end

-- The language a dungeon's story (place true) or a boss's shows in now, and why ("preview", "spoken" or "client"):
-- for /aegis spoken's readout (UI/SpokenWords.lua) and the tests.
function SpokenLore.Language(place)
	return Language(place == true)
end

-- The languages the shipped copy keeps, in order (the tests: English, the journal's language and Spoken's text
-- language alone).
function SpokenLore.Languages()
	local codes = {}
	for code in pairs(shipped.text) do codes[#codes + 1] = code end
	table.sort(codes)
	return codes
end

-- Every lookup kept let go (the tests, after changing Spoken's tables in place).
function SpokenLore.Forget()
	for entry in pairs(seen) do seen[entry] = nil end
end
