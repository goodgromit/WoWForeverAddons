local _, ns = ...

--[[
	The words of Spoken's story lit as Spoken reads them (the owner's ask of 2026-11-17: "highlight the words as Spoken
	reads them"). On a dungeon's Overview and a boss's, while Spoken's voice reads the very story the page shows, the
	word being read and the next are drawn in Spoken's own mark colors, as Spoken's own windows draw them: deep red on
	the parchment, gold on a dark page. Nothing else changes (no outline, no box, the same font), so the lines break
	where they did.

	Only Spoken's documented caption API (Spoken/API.lua, 3.9.0, "Captions, for an addon that shows the line being
	read somewhere else"): Spoken:GetCaption() (the line speaking, its words and their times, the word being read),
	Spoken:SplitCaption(text) (the journal's own copy cut into words as Spoken cuts them), Spoken:WordMarks() (Spoken's
	own Key, Pick, Spans, Want and ColorFor), Spoken:IsPaused(), Spoken:GetSource(key), and its CLIP_STARTED,
	CLIP_STOPPED and AUDIO_CHANGED callbacks. None of Spoken's code, data, audio or art is in the journal: the
	player's own Spoken is asked at run time, each call in pcall (UI/SpokenButton.lua's Call), and a Spoken without
	any of these, or any error, means no highlight and nothing in chat.

	Lit only when all of these hold:
	  - the page shows Spoken's story itself (Core/SpokenLore.lua), not a description;
	  - Spoken reads a story of its places or bosses (the clip's source), not a line with no recording (textOnly);
	  - the recording's own word times are in use (caption.timed: Spoken applies them only when the text is in the
	    voice's language and they fit its words), TIMED_ONLY;
	  - the player's Highlight Words is on in Spoken, FOLLOW_SPOKEN;
	  - the page's text, cut by Spoken:SplitCaption, is the caption's words exactly: as many, and each the same by
	    Spoken's own WordMarks.Key (case and ASCII punctuation aside), in order. Spoken's own windows take a 60%
	    match; here any difference means no highlight, never a wrong one. Tested once for each line Spoken reads.
	  - the voice is speaking, and Spoken is not paused, CLEAR_ON_PAUSE.
	A dungeon's story shows in Spoken's text language (Core/SpokenLore.lua), the language Spoken's narrator shows a
	place's line in (Spoken_Places/Audio.lua's NewLoreSound), so its page lights wherever that text is the voice's own
	language, whatever the client's: there Spoken applies the recording's times, and the page's words are the line's.
	Where the text is in another language than the voice's, Spoken's line has no times: Spoken's own windows still light
	it by Spoken's estimate, and this page, by TIMED_ONLY, does not. A boss's story shows in the client's language, as
	Spoken's bosses show it. With /aegis lang on, the page may be in another language than Spoken's line: not lit.

	Light: Spoken's CLIP_STARTED and CLIP_STOPPED are held beside the Play button's AUDIO_CHANGED, only while its
	page is shown (UI/SpokenButton.lua's Listen and Unlisten). One C_Timer at a time, set to the end of the word
	being read, and only while the story speaks on a shown page; each wake reads GetCaption again, so it never
	drifts. The text is set again only when the lit words change. No OnUpdate.

	The one owner of these FontStrings' text (SpokenWords.SetText): a page filled mid-story sets its plain text through
	here, which puts the highlight back where the same story still speaks. The text kept is always the plain one, its
	ink from SetTextColor; the color codes are only ever in what is drawn.
]]

local SpokenWords = {}
ns.SpokenWords = SpokenWords

--[[
	The owner's choices (the defaults of 2026-11-17, to be checked in game; each a one-line change):
	  LIT_WORDS       2: the word being read and the next, as Spoken's own windows light them; 1: the word alone, as
	                  Spoken's subtitles do.
	  COLOR           nil: Spoken's own rule (WordMarks.ColorFor on the text's ink: deep red on parchment, gold on a
	                  dark page); or a color code of the journal's own, such as "|cffffd100".
	  CLEAR_ON_PAUSE  true: pausing puts the plain text back (in Spoken, pause is a stop, and Resume reads the story
	                  again from its first word, lit again from there); false: the lit words stay where the voice
	                  stopped, as Spoken's captions keep them.
	  FOLLOW_SPOKEN   true: only while the player's Highlight Words is on in Spoken (off there, off here); false:
	                  whatever that setting.
	  TIMED_ONLY      true: only with the recording's own word times, never Spoken's estimate, which may run ahead of
	                  the voice or behind it; false: Spoken's estimate too, where the recording has no times.
]]
SpokenWords.LIT_WORDS = 2
SpokenWords.COLOR = nil
SpokenWords.CLEAR_ON_PAUSE = true
SpokenWords.FOLLOW_SPOKEN = true
SpokenWords.TIMED_ONLY = true

-- A wake comes at the end of the word being read, no sooner than MIN_WAIT seconds and no later than MAX_WAIT (a long
-- silence in the voice still looks again now and then).
local MIN_WAIT, MAX_WAIT = 0.05, 2
-- Spoken's captions keep the line before for a moment after a new one starts where one of Spoken's windows fades out
-- to turn to it (Spoken/UI/Transcript.lua's Hold), and no callback says when they catch up: after CLIP_STARTED, the
-- new line is looked for every CATCH_UP seconds, CATCH_UP_TRIES times at most.
local CATCH_UP, CATCH_UP_TRIES = 0.2, 10

local Call = ns.SpokenButton.Call

-- Each story FontString's state: { fs, text (the plain text, always), story (it is Spoken's story itself), active
-- (its Play button listens), spoken, timer, tested (the last line tested against it), lit (the pair drawn), ... }.
local entries = {}

local function Entry(fs)
	local entry = entries[fs]
	if not entry then
		entry = { fs = fs, text = "", story = false, redraws = 0, moved = 0 }
		entry.wake = function()
			entry.timer = nil
			SpokenWords.Update(fs)
		end
		entries[fs] = entry
	end
	return entry
end

local function Index(object, key) return object[key] end

-- object[key], in pcall (one of Spoken's tables may throw on a lookup); nil where it is not a table or that failed.
local function Field(object, key)
	if type(object) ~= "table" then return nil end
	local ok, value = pcall(Index, object, key)
	if ok then return value end
	return nil
end

-- Whether the player's Spoken has the caption API this is written against: GetCaption, SplitCaption and WordMarks.
local API = { "GetCaption", "SplitCaption", "WordMarks" }
function SpokenWords.Usable(spoken)
	if type(spoken) ~= "table" then return false end
	for _, method in ipairs(API) do
		if type(Field(spoken, method)) ~= "function" then return false end
	end
	return true
end

-- Spoken's WordMarks, where it has every function used here (MarkLinks is used where it is there).
local MARKS = { "Key", "Pick", "Spans", "Want", "ColorFor" }
local function Marks(spoken)
	local ok, marks = Call(spoken, "WordMarks")
	if not ok or type(marks) ~= "table" then return nil end
	for _, name in ipairs(MARKS) do
		if type(Field(marks, name)) ~= "function" then return nil end
	end
	return marks
end

-- text cut into words as Spoken's captions cut it, each { text, first, last } (its bytes in text); nil where that failed.
local function Split(spoken, text)
	local ok, words = Call(spoken, "SplitCaption", text)
	if ok and type(words) == "table" then return words end
	return nil
end

local function IsWord(word)
	return type(word) == "table" and type(word.text) == "string" and type(word.first) == "number"
		and type(word.last) == "number"
end

-- The same word, by Spoken's own key (case and ASCII punctuation aside); a word with no key (punctuation alone, or an
-- escape sequence) the same only as itself.
local function Same(marks, ours, theirs)
	local keyOurs, keyTheirs = marks.Key(ours), marks.Key(theirs)
	if keyOurs == nil or keyTheirs == nil then return keyOurs == keyTheirs and ours == theirs end
	return keyOurs == keyTheirs
end

-- Where the page's words and the caption's first differ (or their counts), nil where they are the same throughout;
-- with the page's words.
local function Difference(spoken, marks, text, words)
	local ours = Split(spoken, text)
	if not ours or type(words) ~= "table" then return 0, ours end
	if #ours == 0 or #ours ~= #words then return 0, ours end
	for index = 1, #words do
		local mine, theirs = ours[index], words[index]
		if not (IsWord(mine) and type(theirs) == "table" and type(theirs.text) == "string")
			or not Same(marks, mine.text, theirs.text) then
			return index, ours
		end
	end
	return nil, ours
end

--[[
	The page's text against the line Spoken reads, once for each line (and again where the page's text changes): nil
	where they differ at all. Else the page's text the way Spoken's WordMarks takes a window's: its paragraphs { text,
	words }, a new one wherever a line break comes between two words (as Spoken's captions start one), each cut by
	SplitCaption on its own; map[i] = { p, w } for caption word i, where it has a key (a word of punctuation alone is
	never lit, as in Spoken); and the text before, between and after the paragraphs, so that it goes back together byte
	for byte.
]]
local function Compare(spoken, text, words)
	local marks = Marks(spoken)
	if not marks then return nil end
	local differs, whole = Difference(spoken, marks, text, words)
	if differs then return nil end
	local test = { marks = marks, paragraphs = {}, gaps = {}, map = {}, count = #whole }
	local markLinks = Field(marks, "MarkLinks")
	local from, firstWord = whole[1].first, 1
	test.prefix = text:sub(1, from - 1)
	for index = 1, #whole do
		local word, after = whole[index], whole[index + 1]
		local gap = after and text:sub(word.last + 1, after.first - 1) or text:sub(word.last + 1)
		if not after or gap:find("\n", 1, true) then
			local paragraph = { text = text:sub(from, word.last) }
			local cut = Split(spoken, paragraph.text)
			if not cut or #cut ~= index - firstWord + 1 then return nil end
			if type(markLinks) == "function" then markLinks(paragraph.text, cut) end
			paragraph.words = cut
			local p = #test.paragraphs + 1
			test.paragraphs[p], test.gaps[p] = paragraph, gap
			for w, piece in ipairs(cut) do
				if not IsWord(piece) or piece.text ~= whole[firstWord + w - 1].text then return nil end
				if not piece.inLink and marks.Key(piece.text) then test.map[firstWord + w - 1] = { p = p, w = w } end
			end
			if after then from, firstWord = after.first, index + 1 end
		end
	end
	local rebuilt = { test.prefix }
	for p, paragraph in ipairs(test.paragraphs) do
		rebuilt[#rebuilt + 1] = paragraph.text
		rebuilt[#rebuilt + 1] = test.gaps[p]
	end
	if table.concat(rebuilt) ~= text then return nil end
	test.span = { first = 1, last = #test.paragraphs }
	return test
end

-- The test for the line speaking, kept for the line (Spoken's caption keeps one words table for each line) and the
-- page's text.
local function Tested(entry, spoken, caption)
	local kept = entry.tested
	if kept and kept.words == caption.words and kept.text == entry.text then return kept.result end
	entry.tested = { words = caption.words, text = entry.text, result = Compare(spoken, entry.text, caption.words) or false }
	entry.clip, entry.redraws, entry.moved = caption.clip, 0, 0
	return entry.tested.result
end

-- Whether a clip is one of Spoken's place or boss stories.
local SOURCES = { "places", "bosses" }
local function StorySource(spoken, source)
	if source == nil then return false end
	for _, key in ipairs(SOURCES) do
		local ok, found = Call(spoken, "GetSource", key)
		if ok and found ~= nil and found == source then return true end
	end
	return false
end

-- Seconds to the end of the word being read (start and finish are its share of the line, in units of totalWeight).
local function Remaining(caption, index)
	local word, total, length, progress = caption.words[index], caption.totalWeight, tonumber(caption.clip.length),
		caption.progress
	if type(word) ~= "table" or type(word.finish) ~= "number" or type(total) ~= "number" or total <= 0 or not length
		or type(progress) ~= "number" then
		return MAX_WAIT
	end
	return math.min(MAX_WAIT, math.max(MIN_WAIT, (word.finish / total - progress) * length))
end

--[[
	What the page should show now: "lit" with the test, the pair to light and the seconds to the next wake; or
	"plain", with the seconds to the next look where one is wanted (a new line not caught up yet, or the voice on a
	word that is never lit), else none.
]]
local function Look(entry)
	local spoken, settings = entry.spoken, SpokenWords
	if not (entry.active and entry.story and spoken and entry.fs:IsVisible()) then return "plain" end
	local ok, caption = Call(spoken, "GetCaption")
	local clip = ok and type(caption) == "table" and caption.clip or nil
	if entry.waiting then
		if clip ~= nil and clip == entry.waiting then
			entry.waiting = nil
		elseif entry.tries > 0 then
			entry.tries = entry.tries - 1
			return "plain", CATCH_UP
		else
			-- Never caught up: nothing lit and no wake (what Spoken's captions still hold is the line before, or a story
			-- ended); the next CLIP_STARTED, the page shown again, or an AUDIO_CHANGED once they catch up looks again.
			return "plain"
		end
	end
	if type(clip) ~= "table" or clip.textOnly or type(caption.words) ~= "table" then return "plain" end
	-- The line Spoken stopped but keeps at the head of its queue (held by one of its gates: a cinematic, combat): its
	-- caption still says speaking, on the word it stopped at. Not lit again until Spoken starts it again (CLIP_STARTED,
	-- which cuts its words afresh).
	local stopped = entry.stopped
	if stopped and stopped.clip == clip and stopped.words == caption.words then return "plain" end
	if settings.TIMED_ONLY and caption.timed ~= true then return "plain" end
	if settings.FOLLOW_SPOKEN and caption.highlight ~= true then return "plain" end
	if not StorySource(spoken, clip.source) then return "plain" end
	local test = Tested(entry, spoken, caption)
	if not test then return "plain" end
	local okPaused, paused = Call(spoken, "IsPaused")
	if not okPaused or type(paused) ~= "boolean" or (paused and settings.CLEAR_ON_PAUSE) then return "plain" end
	local index = caption.speaking == true and caption.activeWord or nil
	if type(index) ~= "number" then return "plain" end
	-- Paused (with CLEAR_ON_PAUSE off), the words stay as they are: no wake.
	local wait = not paused and Remaining(caption, index) or nil
	local lit, neighbor = test.marks.Pick(test.map, index)
	if type(lit) ~= "number" then return "plain", wait end
	if settings.LIT_WORDS < 2 or type(neighbor) ~= "number" then neighbor = nil end
	return "lit", wait, test, lit, neighbor
end

-- The text's ink, for Spoken's color rule: the FontString's own, else the parchment's.
local function Ink(fs)
	local r, g, b = fs:GetTextColor()
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then return r, g, b end
	local ink = ns.PARCHMENT_TEXT_COLOR
	return ink[1], ink[2], ink[3]
end

-- Its lines and height as the client lays the text out (the readout's check that lighting moves no line).
local function Measure(fs)
	local lines = type(fs.GetNumLines) == "function" and fs:GetNumLines() or nil
	local height = fs:GetStringHeight()
	return tonumber(lines), tonumber(height)
end

-- The page's text with the pair lit, set only where the pair is not the one drawn already (at a paragraph's end the
-- same two words as the word before).
local function Draw(entry, test, lit, neighbor)
	local key = neighbor and math.min(lit, neighbor) * 65536 + math.max(lit, neighbor) or lit
	if entry.lit == key and entry.drawn == test then return end
	local marks, fs = test.marks, entry.fs
	local color = SpokenWords.COLOR or marks.ColorFor(Ink(fs))
	local spans = marks.Spans(test.map, test.paragraphs, lit, neighbor)
	local parts = { test.prefix }
	for p, paragraph in ipairs(test.paragraphs) do
		parts[#parts + 1] = marks.Want(paragraph, p, test.span, nil, nil, spans, color)
		parts[#parts + 1] = test.gaps[p]
	end
	local text = table.concat(parts)
	local beforeLines, beforeHeight = Measure(fs)
	if entry.lit == nil then entry.plainLines, entry.plainHeight = beforeLines, beforeHeight end
	fs:SetText(text)
	entry.lit, entry.drawn, entry.litWord, entry.litNeighbor = key, test, lit, neighbor
	entry.redraws = entry.redraws + 1
	entry.beforeLines, entry.beforeHeight = beforeLines, beforeHeight
	entry.afterLines, entry.afterHeight = Measure(fs)
	if entry.afterLines ~= entry.plainLines or entry.afterHeight ~= entry.plainHeight then entry.moved = entry.moved + 1 end
end

-- The plain text back, where anything was lit (or always, after a failure).
local function Plain(entry, always)
	if entry.lit == nil and not always then return end
	entry.lit, entry.drawn = nil, nil
	entry.fs:SetText(entry.text)
end

local function Cancel(entry)
	if entry.timer then
		entry.timer:Cancel()
		entry.timer = nil
	end
end

-- The next wake: C_Timer.NewTimer, which can be cancelled; on a client without it, C_Timer.After, its call then
-- doing nothing once cancelled.
local function Wake(entry, seconds)
	Cancel(entry)
	if C_Timer.NewTimer then
		entry.timer = C_Timer.NewTimer(seconds, entry.wake)
		return
	end
	local timer = { Cancel = function(self) self.cancelled = true end }
	C_Timer.After(seconds, function()
		if not timer.cancelled then entry.wake() end
	end)
	entry.timer = timer
end

-- Looks at Spoken now: lights the right words, or puts the plain text back; sets the next wake where one is wanted.
function SpokenWords.Update(fs)
	local entry = entries[fs]
	if not entry then return end
	Cancel(entry)
	local ok, state, wait, test, lit, neighbor = pcall(Look, entry)
	if ok and state == "lit" then
		if not pcall(Draw, entry, test, lit, neighbor) then
			pcall(Plain, entry, true)
			return
		end
	else
		pcall(Plain, entry, not ok)
		if not ok then return end
	end
	if wait then Wake(entry, wait) end
end

--[[
	The story FontString's text (the Overview's lore, a boss's), set here alone: text, and whether it is Spoken's story
	itself (a description is never lit). Mid-story, the highlight comes back at once.
]]
function SpokenWords.SetText(fs, text, story)
	local entry = Entry(fs)
	Cancel(entry)
	entry.text, entry.story = type(text) == "string" and text or "", story == true
	entry.lit, entry.drawn = nil, nil
	fs:SetText(entry.text)
	if entry.active then SpokenWords.Update(fs) end
end

-- From the Play button's listening (UI/SpokenButton.lua): whether its words are worth following (Spoken's story itself,
-- and a Spoken with the caption API); its page shown with Spoken's callbacks held; let go.
function SpokenWords.Wanted(fs, spoken)
	local entry = fs and entries[fs]
	return entry ~= nil and entry.story and SpokenWords.Usable(spoken)
end

function SpokenWords.Follow(fs, spoken)
	local entry = Entry(fs)
	entry.active, entry.spoken = true, spoken
	SpokenWords.Update(fs)
end

function SpokenWords.Release(fs)
	local entry = entries[fs]
	if not entry then return end
	entry.active, entry.spoken, entry.waiting = false, nil, nil
	Cancel(entry)
	pcall(Plain, entry)
end

-- Spoken's CLIP_STARTED: the new line looked for (Spoken's captions may still show the line before): looked for again
-- every CATCH_UP seconds only where it is one of Spoken's stories, else only by the callbacks that follow.
function SpokenWords.Started(fs, clip)
	local entry = entries[fs]
	if not entry then return end
	local story = type(clip) == "table" and not Field(clip, "textOnly") and StorySource(entry.spoken, Field(clip, "source"))
	entry.waiting, entry.tries, entry.stopped = clip, story and CATCH_UP_TRIES or 0, nil
	SpokenWords.Update(fs)
end

-- Spoken's CLIP_STOPPED: the plain text back where it is the line lit (AUDIO_CHANGED follows, with what comes next),
-- and that line not lit again while Spoken keeps it stopped.
function SpokenWords.Stopped(fs, clip)
	local entry = entries[fs]
	if not entry or (clip ~= nil and clip ~= entry.clip) then return end
	entry.waiting = nil
	entry.stopped = { clip = clip or entry.clip, words = entry.tested and entry.tested.words }
	Cancel(entry)
	pcall(Plain, entry)
end

-- For the tests and the readout: a FontString's state (read only).
function SpokenWords.State(fs)
	return entries[fs]
end

------------------------------------------------------------------------------------------
-- /aegis spoken: the owner's readout, for the check in game
------------------------------------------------------------------------------------------

local function YesNo(value) return value and "yes" or "no" end

-- Words as written: a | shown, not read as a code; line breaks as \n.
local function Quoted(text)
	if type(text) ~= "string" then return tostring(text) end
	return "\"" .. text:gsub("|", "||"):gsub("\n", "\\n") .. "\""
end

local function Number(value)
	if type(value) ~= "number" then return "?" end
	if value == math.floor(value) then return tostring(value) end
	return string.format("%.2f", value)
end

local function Report(entry, print)
	local spoken = entry.spoken or rawget(_G, "Spoken")
	local start = entry.text:gsub("%s+", " "):sub(1, 48)
	print(string.format("Page: %s...; Spoken's story itself: %s; listening to Spoken: %s; a wake set: %s",
		Quoted(start), YesNo(entry.story), YesNo(entry.active), YesNo(entry.timer)))
	local ok, caption = Call(spoken, "GetCaption")
	if not ok or type(caption) ~= "table" or type(caption.clip) ~= "table" then
		print("Spoken reads nothing now" .. (ok and "" or " (or its GetCaption failed)") .. ".")
		return
	end
	local clip = caption.clip
	local source = "another of Spoken's"
	for _, key in ipairs(SOURCES) do
		local found, object = Call(spoken, "GetSource", key)
		if found and object ~= nil and object == clip.source then source = key end
	end
	local okPaused, paused = Call(spoken, "IsPaused")
	print(string.format("Line: %s (%s), %s s; recording's word times: %s; Highlight Words: %s; text only: %s; "
		.. "speaking: %s; paused: %s; at %s%%, word %s", Quoted(clip.key), source, Number(tonumber(clip.length)),
		YesNo(caption.timed == true), YesNo(caption.highlight == true), YesNo(clip.textOnly), YesNo(caption.speaking == true),
		okPaused and YesNo(paused) or "?", type(caption.progress) == "number" and Number(caption.progress * 100) or "?",
		Number(caption.activeWord)))
	local marks = Marks(spoken)
	local words = type(caption.words) == "table" and caption.words or {}
	if marks then
		local differs, ours = Difference(spoken, marks, entry.text, words)
		local match
		if not ours then
			match = "the page's words could not be cut"
		elseif differs == 0 then
			match = "not the same count: no highlight"
		elseif differs then
			match = string.format("they differ at word %d (%s, Spoken's %s): no highlight", differs,
				Quoted(IsWord(ours[differs]) and ours[differs].text), Quoted(words[differs] and words[differs].text))
		else
			match = "the same, word for word"
		end
		print(string.format("Words: the page's %s, the line's %d; %s", ours and tostring(#ours) or "?", #words, match))
	else
		print("Words: Spoken's WordMarks are missing: no highlight")
	end
	if entry.lit then
		local function Word(index) return index and Quoted(words[index] and words[index].text) .. " (" .. index .. ")" or "" end
		print(string.format("Lit: %s%s; redraws for this line: %d", Word(entry.litWord),
			entry.litNeighbor and (" and " .. Word(entry.litNeighbor)) or "", entry.redraws))
	else
		print(string.format("Lit: nothing; redraws for this line: %d", entry.redraws))
	end
	if entry.redraws > 0 then
		print(string.format("Lines: plain %s lines, %s high; last redraw %s lines, %s high, then %s lines, %s high; the "
			.. "lines moved in %d of %d redraws", Number(entry.plainLines), Number(entry.plainHeight),
			Number(entry.beforeLines), Number(entry.beforeHeight), Number(entry.afterLines), Number(entry.afterHeight),
			entry.moved, entry.redraws))
	end
end

function SpokenWords.Readout()
	local print = ns.Print
	local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
	local okVersion, version = false, nil
	if type(get) == "function" then okVersion, version = pcall(get, "Spoken", "Version") end
	local spoken = rawget(_G, "Spoken")
	print(string.format("Spoken's word highlight: Spoken %s; its caption API %s", okVersion and version and tostring(version)
		or "not loaded", SpokenWords.Usable(spoken) and "found" or "missing"))
	local settings = SpokenWords
	print(string.format("Settings: %d word%s lit; %s; pause %s; Spoken's Highlight Words %s; %s", settings.LIT_WORDS,
		settings.LIT_WORDS == 1 and "" or "s", settings.COLOR and ("the color " .. Quoted(settings.COLOR)) or "Spoken's colors",
		settings.CLEAR_ON_PAUSE and "clears them" or "keeps them", settings.FOLLOW_SPOKEN and "followed" or "not followed",
		settings.TIMED_ONLY and "the recording's word times only" or "Spoken's estimate too"))
	local lore = ns.SpokenLore
	local WHY = { preview = "/aegis lang's", spoken = "Spoken's text language", client = "the client's" }
	local placeCode, placeWhy = lore.Language(true)
	local bossCode, bossWhy = lore.Language(false)
	print(string.format("Story language: a dungeon's %s (%s), a boss's %s (%s)", tostring(placeCode),
		WHY[placeWhy] or tostring(placeWhy), tostring(bossCode), WHY[bossWhy] or tostring(bossWhy)))
	local shown = 0
	for fs, entry in pairs(entries) do
		if fs:IsVisible() then
			shown = shown + 1
			local ok, problem = pcall(Report, entry, print)
			if not ok then print("The readout failed: " .. Quoted(tostring(problem))) end
		end
	end
	if shown == 0 then
		print("No dungeon's or boss's Overview with lore is shown: open one, press Play, then type /aegis spoken again.")
	end
end
