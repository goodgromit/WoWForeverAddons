local _, ns = ...
local L = ns.L

--[[
	The Quests tab. Retail's journal has none, so this follows the classic instance journals:
	the quest list takes the left page (instead of the boss list) and the chosen quest fills
	the right page, laid out like the classic quest frame: title, objective, Show Start and
	Show End, then Rewards.

	Status comes from the player's own quest log and history: done, in the log, ready to hand
	in, available, or not yet available. A "+" opens a quest's chain beneath it. Quests
	recorded on the Record tab add their full text, their exact rewards and where they end.

	The list is in dropdowns, under the Abilities tab's paper headers. Before you go comes first, under its
	bar, where the player's side has notes (UI/BeforeYouGo.lua; the owner's call of 2026-11-13: all of it
	moved here from the overview), in its own order: a key's dropdown (the Dalaran Sewer Key: the quests to
	it, for the player's side) holds the note's text and how far along the player is, then its quests; a
	note no quest of its own fills (a key a boss drops, a hidden boss, a plain note) is a header with its
	text alone, folded until clicked, and a click on it only opens or folds it. Then Dungeon Quests, the
	rest, then Class Quests, those for the player's class alone (classOnly), shown only to that class. Each
	dropdown's header shows the mark of its first quest still to do and how many of its quests are done.
	When a dungeon is shown, all of Before you go starts folded, keys and chains too (the owner's call of
	2026-11-14), and Dungeon Quests and Class Quests open (a raid's are Raid Quests), Dungeon Quests' first
	quest still to do chosen; what the player opens stays open while the dungeon stays shown.
	A quest that comes after a road of Before you go (a key's dropdown whose last quest it needs: The road from
	Rog'mar, Onyxia attunement, the Dalaran Sewer Key) doesn't list the road's quests again under its +: it opens on
	one line for the road, its title, how many of its quests are done and the mark of the step the quest waits on (a
	check once it has all it needs of the road), whose click opens the road on that step; then the quest's own steps,
	where its way branches off (the owner's direction of 2026-11-19).

	In Adventure Mode (Core/Discovery.lua) a quest shows once the character has been offered it, taken it
	or done it, with its chain: a row of the dropdowns once its quest, or a step of its chain that is
	this dungeon's, is known (a key's dropdown stays, as Before you go keeps it, its quests those known).
	A step not offered yet is "???", its level, mark and parts' count kept, so the reader sees the chain
	goes on without being told where; chosen, its page says only that. A row of several quests (a one-of
	step's versions, a row of same-named parts) is known once one of them is; a part listed as a row of its
	own, "<name> (Part n)", is "??? (Part n)" until offered, but under that name where the row of same-named
	parts it is numbered in is known (its name already on the tab). What the game
	told the player of a known quest shows as it is; a lock line, and the journal's own notes, name a quest not offered yet
	as "???" (Discovery:MaskQuests, Discovery:MaskAll). A road's quests are no "???" steps under a +: its line's count
	stands for them; where the only quest a dungeon's rows show for is a road's, the road is unfolded in Before you go
	on it (the owner's answer of 2026-11-19).
]]

local QuestsPanel = {}
ns.QuestsPanel = QuestsPanel

local ROW_HEIGHT, INDENT, LIST_WIDTH, DETAIL_WIDTH = 26, 18, 320, 315
-- The dropdowns: room above the first, as the boss list has; their quests set in a little.
local TOP_PADDING, HEADER_GAP, ROW_INDENT = 6, 6, 8
-- An open dropdown's quests sit in a box, as an ability's text sits under its header: the room
-- above and below them in it, and how far its top tucks under the header.
local BOX_PADDING, BOX_TUCK, BOX_SIDE = 6, 3, 1
-- Before you go's bar (the overview's had it: Header-Overview), its height; a note's text box (the header's
-- own, AbilityTextBG): how far below the box's text the header's height runs (SetHeader counts 20: the box's
-- 11, then 9 under it), how far below the text the box ends, and the room above and below a key's quests in it.
local BAR_HEIGHT, TEXT_BELOW, BOX_BELOW_TEXT, KEY_ROW_PADDING = 30, 20, 11, 4
local REWARD_BOX_WIDTH, REWARD_BOX_HEIGHT = 147, 41

local STATUS_DONE, STATUS_READY, STATUS_ACTIVE, STATUS_AVAILABLE, STATUS_LOCKED =
	"done", "ready", "active", "available", "locked"

-- The classic instance journals' colours: black headings, dark brown text on the parchment,
-- yellow quests in the list and green ones once done.
local TITLE_COLOR = { 0, 0, 0 }
local BODY_COLOR = { 0.13, 0.04, 0 }
local REPUTATION_COLOR = { 0.1, 0.5, 0.1 }
-- A muted note on the parchment: the original game's XP.
local NOTE_COLOR = { 0.42, 0.34, 0.24 }
local GREEN = "|cff1e7d00"
local ROW_COLOR = { 1, 1, 0 }
local ROW_DONE_COLOR = { 0.1, 1, 0.1 }
local ROW_CHOSEN_COLOR = { 1, 1, 1 }
local DONE_ICON = "Interface\\Buttons\\UI-CheckBox-Check"

-- The classic quest log's row highlight: brightest in the middle, tinted like the row.
local ROW_HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
local ROW_HIGHLIGHT_FALLBACK = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local HIGHLIGHT_ALPHA_CHOSEN, HIGHLIGHT_ALPHA_HOVER = 0.45, 0.25

------------------------------------------------------------------------------------------
-- Status
------------------------------------------------------------------------------------------

local function QuestCall(name, questID)
	local fn = C_QuestLog and C_QuestLog[name]
	if type(fn) ~= "function" or not questID then return nil end
	local ok, value = pcall(fn, questID)
	return ok and value or nil
end

local function IsDone(questID) return QuestCall("IsQuestFlaggedCompleted", questID) == true end

local function InLog(questID)
	local index = QuestCall("GetLogIndexForQuestID", questID)
	return index ~= nil and index ~= 0
end

------------------------------------------------------------------------------------------
-- Adventure Mode
------------------------------------------------------------------------------------------

-- What the character knows, kept for each find (Discovery:Version) and record: rows are asked many times a redraw.
local known, knownFor, knownStore = {}, nil, nil

-- Whether the character has been offered a quest, or any quest a row stands for. Always, outside Adventure Mode.
local function Known(quest)
	if not ns.Style:Adventure() then return true end
	local version, store = ns.Discovery:Version(), ns.charDB and ns.charDB.discovered
	if knownFor ~= version or knownStore ~= store then known, knownFor, knownStore = {}, version, store end
	local answer = known[quest]
	if answer == nil then
		answer = ns.Discovery:Knows("quest", quest.questID)
		for _, inner in ipairs(quest.oneOf or {}) do answer = answer or Known(inner) end
		for _, part in ipairs(quest.parts or {}) do answer = answer or Known(part) end
		known[quest] = answer
	end
	return answer
end

-- A step's name as a line gives it: "???" for one not offered yet (Adventure Mode).
local function Named(step, name)
	if Known(step) then return name end
	return ns.Discovery.UNKNOWN
end

local function PlayerLevel()
	local ok, level = pcall(UnitLevel, "player")
	return ok and level or 0
end

-- A step any one of several quests will do (ns.OneOf): the versions this character can take (all of
-- them, should none be), and whether one of them is done.
local function Versions(prerequisite)
	local versions = {}
	for _, version in ipairs(prerequisite.oneOf) do
		if QuestsPanel:IsForPlayer(version) then versions[#versions + 1] = version end
	end
	return #versions > 0 and versions or prerequisite.oneOf
end

local function PrerequisiteDone(prerequisite)
	if not prerequisite.oneOf then return IsDone(prerequisite.questID) end
	for _, version in ipairs(prerequisite.oneOf) do
		if IsDone(version.questID) then return true end
	end
	return false
end

-- "A, B or C".
local function OrList(names)
	if #names == 1 then return names[1] end
	return table.concat(names, L.QUEST_LIST_COMMA, 1, #names - 1) .. L.QUEST_OR .. names[#names]
end

-- A one-of step's versions' name, if they share one.
local function SharedName(versions)
	for _, version in ipairs(versions) do
		if version.name ~= versions[1].name then return nil end
	end
	return versions[1].name
end

-- A quest's or a step's name as the data writes it, in English (Core/Registry.lua keeps it where a translation
-- was laid over it): what tells the quests and steps of one chain that share a name, in every language alike.
local function EnglishName(quest) return quest.enName or quest.name end

-- The same for a one-of step's versions: their English name, if they share one.
local function SharedEnglishName(versions)
	for _, version in ipairs(versions) do
		if EnglishName(version) ~= EnglishName(versions[1]) then return nil end
	end
	return EnglishName(versions[1])
end

-- A quest's level, from the page the journal keeps for it: a step's, else a dungeon's own.
local function KnownLevel(questID)
	local step = ns.GetQuestStep(questID)
	if step then return step.level end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances(kind)) do
			for _, quest in ipairs(instance.quests or {}) do
				if quest.questID == questID and quest.level then return quest.level end
			end
		end
	end
	return nil
end

-- Which part of its name a step of quest's chain is (`entry`, one of quest's prerequisites): its place
-- among the steps there of its English name, in the chain's order, as the rows number them (a row of
-- same-named quests' parts and a chain's numbered steps: QuestsPanel:Fold, StepRows); nil when it is not
-- one of them.
local function PartNumber(entry, quest)
	local name, number = EnglishName(entry), 0
	for _, other in ipairs(quest.prerequisites or {}) do
		if EnglishName(other) == name then number = number + 1 end
		if other == entry then return number end
	end
	return nil
end

-- The part a step of another name is (`entry`, one of quest's prerequisites), where it is one of a numbered
-- run, several of quest's steps sharing its name (The Test of Righteousness's four The Tome of Valor): its
-- number, as the chain's rows have it; nil when it is alone of its name there.
local function RunPart(entry, quest)
	local name, count = EnglishName(entry), 0
	for _, other in ipairs(quest.prerequisites or {}) do
		if EnglishName(other) == name then count = count + 1 end
	end
	return count > 1 and PartNumber(entry, quest) or nil
end

-- The number the tab's rows give a step of another name where it is a part of a numbered run (below, once the
-- rows are built: TabParts).
local TabPart

-- A step's name as a lock line gives it (entry: the prerequisite of quest it is, or stands for). Where it
-- is the quest's own ("Requires: The Defias Brotherhood" on The Defias Brotherhood), the part it is
-- follows it, "The Defias Brotherhood (Part 3)"; where it is not one of the chain's parts, its level:
-- "Hidden Enemies (12)". A step of another name that is one of a numbered run says its part too (the
-- owner's call of 2026-11-06): "Requires: The Tome of Valor (Part 2)" on The Test of Righteousness. Its
-- number is the one the tab's rows give it wherever the dungeon shows it (since 2026-11-07: A Dynamite Plan's
-- "Requires: Explosive Consultation (Part 1)", as Destruction in Deadmines' chain numbers that step; Red Silk
-- Bandanas' "The Defias Brotherhood (Part 6)", as the row of seven numbers it), else its place in the quest's own
-- steps.
local function StepName(step, name, quest, entry)
	if name and quest and name == quest.name then
		local part = entry and PartNumber(entry, quest)
		if part then return string.format(L.QUEST_PART_NAME, name, part) end
		local level = KnownLevel(step.questID) or step.level
		if level then return name .. " (" .. level .. ")" end
	end
	local part = name and quest and entry and (TabPart(entry, quest) or RunPart(entry, quest))
	if part then return string.format(L.QUEST_PART_NAME, name, part) end
	return name or "?"
end

-- What a quest still needs: a quest, one of several versions of one, or one of several quests.
local function NeedsText(prerequisite, quest)
	if not prerequisite.oneOf then
		return string.format(L.QUEST_STATUS_NEEDS, StepName(prerequisite, Named(prerequisite, prerequisite.name), quest, prerequisite))
	end
	local versions = Versions(prerequisite)
	if #versions == 1 then
		return string.format(L.QUEST_STATUS_NEEDS,
			StepName(versions[1], Named(versions[1], versions[1].name or prerequisite.name), quest, prerequisite))
	end
	local shared = SharedName(versions)
	-- Versions of a numbered part of the quest's own name (A Taste of Flame's Part 1), or of a numbered run of
	-- another: that part. (Not the tab's number for a one-of step alone of its name: More Sparklematic Action
	-- keeps "Requires one of the 3 versions of The Sparklematic 5200!".) In Adventure Mode a step not offered
	-- yet is "???" with its part's number, as its row is.
	local part = shared and quest and (shared == quest.name and PartNumber(prerequisite, quest) or RunPart(prerequisite, quest))
	if part then return string.format(L.QUEST_STATUS_NEEDS, string.format(L.QUEST_PART_NAME, Named(prerequisite, shared), part)) end
	if shared then return string.format(L.QUEST_STATUS_NEEDS_VERSION, #versions, Named(prerequisite, shared)) end
	local names = {}
	for _, version in ipairs(versions) do names[#names + 1] = Named(version, version.name or "?") end
	return string.format(L.QUEST_STATUS_NEEDS_ONE_OF, OrList(names))
end

--[[
	A row's name as the lists give it: in Adventure Mode "???" for one not offered yet, with its parts'
	count where it has parts ("??? (3 parts)"); a one-of row's versions named "A or B" have those not
	offered yet as "???".
]]
local function ShownName(quest)
	if not Known(quest) then
		local count = quest.parts and #quest.parts
		if count then return string.format(L.QUEST_PARTS, ns.Discovery.UNKNOWN, count) end
		return ns.Discovery.UNKNOWN
	end
	if quest.oneOf and ns.Style:Adventure() and not SharedName(quest.oneOf) then
		local names = {}
		for _, version in ipairs(quest.oneOf) do names[#names + 1] = Named(version, version.name or "?") end
		return OrList(names)
	end
	return quest.name
end

-- A row for the quests of one chain that share a name (QuestsPanel:Fold): the part the player is on, the first
-- not yet done, and its place among them; nil once every part is done.
local function PartOn(fold)
	for index, part in ipairs(fold.parts) do
		if QuestsPanel:Status(part) ~= STATUS_DONE then return part, index end
	end
	return nil
end

-- The part such a row shows: the one the player is on, else the last.
local function ShownPart(fold)
	local part, index = PartOn(fold)
	if part then return part, index end
	return fold.parts[#fold.parts], #fold.parts
end

function QuestsPanel:Status(quest)
	-- Quests of one chain sharing a name, shown as one row: as the part the player is on, done once all are.
	if quest.parts then
		local part = PartOn(quest)
		return part and self:Status(part) or STATUS_DONE
	end
	-- A step any one of several quests will do, shown as one row: done once one of them is.
	if quest.oneOf then
		local active
		for _, version in ipairs(quest.oneOf) do
			if IsDone(version.questID) then return STATUS_DONE end
			if InLog(version.questID) then
				active = QuestCall("IsComplete", version.questID) and STATUS_READY or active or STATUS_ACTIVE
			end
		end
		if active then return active end
		-- None taken: locked while every version is (their pages, kept on a chain's row: OneOfRow).
		if not quest.pages then return STATUS_AVAILABLE end
		for _, page in ipairs(quest.pages) do
			if self:Status(page) ~= STATUS_LOCKED then return STATUS_AVAILABLE end
		end
		return STATUS_LOCKED
	end

	if IsDone(quest.questID) then return STATUS_DONE end
	if InLog(quest.questID) then
		return QuestCall("IsComplete", quest.questID) and STATUS_READY or STATUS_ACTIVE
	end
	for _, prerequisite in ipairs(quest.prerequisites or {}) do
		if not PrerequisiteDone(prerequisite) then return STATUS_LOCKED end
	end
	-- A quest given only while another is in the log (QuestieDB's parentQuest: Seeking the Kor Gem
	-- while The Test of Righteousness is), not once that one is done.
	if quest.parentQuest and not InLog(quest.parentQuest.questID) then return STATUS_LOCKED end
	if quest.requiredLevel and PlayerLevel() < quest.requiredLevel then return STATUS_LOCKED end
	return STATUS_AVAILABLE
end

-- The page a quest's lock is read from: a one-of row's first version's (every version is locked when the
-- row is), a row of same-named quests' part the player is on, else the quest's own.
local function LockPage(quest)
	if quest.parts then return LockPage((ShownPart(quest))) end
	if quest.oneOf and quest.pages then
		-- The version nearest to open: the fewest steps still to do (one that needs only a level has none),
		-- so the line names the easier way in.
		local best, fewest
		for _, page in ipairs(quest.pages) do
			local left = 0
			for _, prerequisite in ipairs(page.prerequisites or {}) do
				if not PrerequisiteDone(prerequisite) then left = left + 1 end
			end
			if not fewest or left < fewest then best, fewest = page, left end
		end
		return best
	end
	return quest
end

-- Why a quest cannot be taken yet: the first step of its chain still to do, else the level it needs.
function QuestsPanel:LockedReason(quest)
	quest = LockPage(quest)
	for _, prerequisite in ipairs(quest.prerequisites or {}) do
		if not PrerequisiteDone(prerequisite) then return NeedsText(prerequisite, quest) end
	end
	if quest.parentQuest and not InLog(quest.parentQuest.questID) then
		return string.format(L.QUEST_STATUS_NEEDS_IN_LOG, Named(quest.parentQuest, quest.parentQuest.name or "?"))
	end
	return string.format(L.QUEST_STATUS_LEVEL, quest.requiredLevel or 0)
end

-- A step's own page, by its quest id: the journal's page for a chain's step, else the first dungeon's quest of that id
-- (pages, kept for the data as it is: ns.DataVersion).
local pages, pagesFor
local function StepPage(questID)
	local step = ns.GetQuestStep(questID)
	if step then return step end
	local version = ns.DataVersion()
	if pagesFor ~= version then
		pages, pagesFor = {}, version
		for _, kind in ipairs({ "dungeon", "raid" }) do
			for _, instance in ipairs(ns.GetInstances(kind)) do
				for _, quest in ipairs(instance.quests or {}) do
					if quest.questID and not pages[quest.questID] then pages[quest.questID] = quest end
				end
			end
		end
	end
	return pages[questID]
end

-- Whether a step not done yet is one the player can do next: every step before it, on its own page, done (for a step
-- any one of several quests will do, on one of its versions' pages). A step with no page of its own can't say.
local function DoableNext(prerequisite)
	for _, version in ipairs(prerequisite.oneOf and Versions(prerequisite) or { prerequisite }) do
		local page = version.questID and StepPage(version.questID)
		if page then
			local open = true
			for _, step in ipairs(page.prerequisites or {}) do
				if not PrerequisiteDone(step) then
					open = false
					break
				end
			end
			if open then return true end
		end
	end
	return false
end

--[[
	What a quest still needs before the player can take it, a line each, for the quest marks' tooltips
	(UI/QuestMap.lua; the owner's call of 2026-11-11: "requires level X and/or Requires: X quest"): the steps of
	its chain the player can do next (DoableNext: one in a chain, a few where its branches run side by side; the
	first step still to do where none says), as the lock line names them ("???" for one not offered yet, in
	Adventure Mode), the quest it is given only while in the log, and the level it needs. Not every step still to
	do: a long chain's would run to dozens of lines (the review of 3cc3416: 25 on Saving the Best for Last). Of the
	parts of one name still to do, the first only: a later part waits for it, though a part's page may not say so
	(A Recipe For Death's three, before The New Plague). Each line once (several steps not offered yet are one
	"Requires: ???"); none for a quest open to the player.
]]
function QuestsPanel:Requirements(quest)
	quest = LockPage(quest)
	local lines, said = {}, {}
	local function Add(line)
		if not said[line] then
			said[line] = true
			lines[#lines + 1] = line
		end
	end
	local first, any
	local waiting = {}
	for _, prerequisite in ipairs(quest.prerequisites or {}) do
		if not PrerequisiteDone(prerequisite) then
			first = first or prerequisite
			local name = prerequisite.enName or prerequisite.name
			if not (name and waiting[name]) and DoableNext(prerequisite) then
				any = true
				Add(NeedsText(prerequisite, quest))
			end
			if name then waiting[name] = true end
		end
	end
	if first and not any then Add(NeedsText(first, quest)) end
	if quest.parentQuest and not InLog(quest.parentQuest.questID) then
		Add(string.format(L.QUEST_STATUS_NEEDS_IN_LOG, Named(quest.parentQuest, quest.parentQuest.name or "?")))
	end
	if quest.requiredLevel and PlayerLevel() < quest.requiredLevel then
		Add(string.format(L.QUEST_STATUS_LEVEL, quest.requiredLevel))
	end
	return lines
end

local function SetStatusIcon(texture, status)
	texture:SetVertexColor(1, 1, 1)
	texture:SetDesaturated(false)
	texture:SetTexCoord(0, 1, 0, 1)
	if status == STATUS_DONE then
		texture:SetTexture(DONE_ICON)
	elseif status == STATUS_READY or status == STATUS_ACTIVE then
		texture:SetAtlas("QuestTurnin")
		if status == STATUS_ACTIVE then
			texture:SetDesaturated(true)
			texture:SetVertexColor(0.85, 0.85, 0.85)
		end
	else
		texture:SetAtlas("QuestNormal")
		if status == STATUS_LOCKED then
			texture:SetDesaturated(true)
			texture:SetVertexColor(0.85, 0.85, 0.85)
		end
	end
end

-- The quests this character can take: their faction's and class's (or classes'), and those open to all.
function QuestsPanel:IsForPlayer(quest)
	local _, faction = pcall(UnitFactionGroup, "player")
	local _, _, classFile = pcall(UnitClass, "player")
	local factionOK = not quest.faction or quest.faction == "Both" or not faction or quest.faction == faction
	local classOK = ns.ForClass(quest.classOnly, classFile)
	return factionOK and classOK
end

local function QuestsFor(instance)
	local list = {}
	for _, quest in ipairs(instance.quests or {}) do
		if QuestsPanel:IsForPlayer(quest) then list[#list + 1] = quest end
	end
	return list
end

local function Recorded(questID)
	local state = ns.Recorder and ns.Recorder:GetState()
	return state and state.quests and questID and state.quests[questID] or nil
end

------------------------------------------------------------------------------------------
-- Left page: the list
------------------------------------------------------------------------------------------

local highlightFile

local function HighlightFile()
	if not highlightFile then
		highlightFile = ns.FileExists(ROW_HIGHLIGHT) and ROW_HIGHLIGHT or ROW_HIGHLIGHT_FALLBACK
	end
	return highlightFile
end

-- The chosen row and the one under the mouse light up, their text turning white (a road's line's note too).
local function UpdateRowHighlight(row)
	local lit = row.selected or row.hovered
	row.Highlight:SetShown(lit)
	if lit then row.Highlight:SetAlpha(row.selected and HIGHLIGHT_ALPHA_CHOSEN or HIGHLIGHT_ALPHA_HOVER) end
	local color = lit and ROW_CHOSEN_COLOR or row.color or ROW_COLOR
	row.Text:SetTextColor(color[1], color[2], color[3])
	row.Note:SetTextColor(color[1], color[2], color[3])
end

-- A row's text runs to its right edge, or up to its note (noted: a road's line, SetRoadRow).
local function AnchorText(row, noted)
	row.Text:ClearAllPoints()
	row.Text:SetPoint("LEFT", row.Status, "RIGHT", 4, 0)
	if noted then
		row.Text:SetPoint("RIGHT", row.Note, "LEFT", -6, 0)
	else
		row.Text:SetPoint("RIGHT", -4, 0)
	end
	row.noted = noted or nil
end

-- onClick: what a click on the row does with it (else it is chosen on the Quests tab).
local function CreateRow(parent, onClick)
	local row = CreateFrame("Button", nil, parent)
	row:SetHeight(ROW_HEIGHT)

	row.Highlight = row:CreateTexture(nil, "BACKGROUND")
	row.Highlight:SetTexture(HighlightFile())
	row.Highlight:SetBlendMode("ADD")
	row.Highlight:SetPoint("TOPLEFT", 0, -1)
	row.Highlight:SetPoint("BOTTOMRIGHT", 0, 1)
	row.Highlight:Hide()

	row.Expand = CreateFrame("Button", nil, row)
	row.Expand:SetSize(16, 16)
	row.Expand:SetPoint("LEFT", 0, 0)
	row.Expand:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
	row.Expand:SetScript("OnClick", function()
		ns.PlaySoundKit("IG_MAINMENU_OPTION_CHECKBOX_ON")
		QuestsPanel:ToggleChain(row.quest)
	end)

	row.Status = row:CreateTexture(nil, "OVERLAY")
	row.Status:SetSize(16, 16)
	row.Status:SetPoint("LEFT", row.Expand, "RIGHT", 4, 0)

	-- (a road's line: how many of its quests are done, on the right, as the road's header has it)
	row.Note = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.Note:SetPoint("RIGHT", -4, 0)
	row.Note:Hide()
	row.Text = row:CreateFontString(nil, "OVERLAY", ns.Font("GameFontNormalMed3", "GameFontNormal"))
	AnchorText(row, false)
	row.Text:SetJustifyH("LEFT")
	row.Text:SetWordWrap(false)

	row:SetScript("OnEnter", function(self)
		self.hovered = true
		UpdateRowHighlight(self)
	end)
	row:SetScript("OnLeave", function(self)
		self.hovered = false
		UpdateRowHighlight(self)
	end)
	row:SetScript("OnClick", function(self)
		ns.PlaySoundKit("IG_QUEST_LIST_SELECT")
		-- (a road's line opens the road in Before you go: QuestsPanel:OpenRoad)
		if self.road then
			QuestsPanel:OpenRoad(self.road)
			return
		end
		-- (a step of a chain, one in, is chosen as a step, under its row: QuestsPanel:Select)
		if onClick then onClick(self) else QuestsPanel:Select(self.quest, (self.depth or 0) > 0, self.under) end
	end)
	return row
end

-- part: { n, count } for a step shown as one of the parts of a name (ChainRows), named "<name> (Part n)".
-- (Rows are reused: a road's line, SetRoadRow, made a quest's row again.)
local function SetRow(row, quest, depth, hasChain, expanded, selected, part)
	row.quest, row.depth, row.part, row.road = quest, depth, part, nil
	if row.noted then
		row.Note:Hide()
		AnchorText(row, false)
	end
	row:ClearAllPoints()
	row:SetWidth(LIST_WIDTH - depth * INDENT)

	row.Expand:SetShown(hasChain)
	if hasChain then
		row.Expand:SetNormalTexture(expanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
	end

	local status = QuestsPanel:Status(quest)
	SetStatusIcon(row.Status, status)
	-- (a row of same-named quests at the level of the part the player is on)
	local shown = quest.parts and ShownPart(quest) or quest
	local level = shown.level and ("[" .. shown.level .. "] ") or ""
	-- (Adventure Mode: "???" for a quest not offered yet, ShownName. A part of a name is "<name> (Part n)":
	-- named where the character knows the row of same-named quests it is numbered in, which the tab names.)
	local name = ShownName(quest) or ""
	if part then
		if part[3] and Known(part[3]) then name = quest.name or "" end
		name = string.format(L.QUEST_PART_NAME, name, part[1])
	end
	row.Text:SetText(level .. name)
	row.color = status == STATUS_DONE and ROW_DONE_COLOR or ROW_COLOR
	row.Highlight:SetVertexColor(row.color[1], row.color[2], row.color[3])

	row.selected = selected
	UpdateRowHighlight(row)
end

--[[
	A road's line under a quest's + (QuestsPanel:Refresh, RoadLine): road = { key (the road's dropdown's), title (as its
	header shows it), status or icon (its mark), note (how many of its quests are done, or the check), done (green), quest
	(what a click chooses there, or nil) }. Never chosen itself; a click opens the road (QuestsPanel:OpenRoad). (Rows are
	reused: nothing of a quest's row stays on it.)
]]
local function SetRoadRow(row, road, depth)
	row.quest, row.depth, row.part, row.under, row.road = nil, depth, nil, nil, road
	row:ClearAllPoints()
	row:SetWidth(LIST_WIDTH - depth * INDENT)
	row.Expand:Hide()
	if road.status then
		SetStatusIcon(row.Status, road.status)
	else
		row.Status:SetTexture(road.icon)
		row.Status:SetTexCoord(0, 1, 0, 1)
		row.Status:SetDesaturated(false)
		row.Status:SetVertexColor(1, 1, 1)
	end
	row.Text:SetText(road.title or "")
	row.Note:SetText(road.note or "")
	row.Note:Show()
	AnchorText(row, true)
	row.color = road.done and ROW_DONE_COLOR or ROW_COLOR
	row.Highlight:SetVertexColor(row.color[1], row.color[2], row.color[3])
	row.selected = false
	UpdateRowHighlight(row)
end

-- The list's rows and marks, for other pages that list quests the same way (Before you go).
QuestsPanel.CreateRow, QuestsPanel.SetRow, QuestsPanel.SetStatusIcon = CreateRow, SetRow, SetStatusIcon
QuestsPanel.STATUS_DONE, QuestsPanel.STATUS_LOCKED = STATUS_DONE, STATUS_LOCKED
-- Adventure Mode: whether a row is known, and its name as the lists give it (Before you go too).
function QuestsPanel:Known(quest) return Known(quest) end
function QuestsPanel:ShownName(quest) return ShownName(quest) end

------------------------------------------------------------------------------------------
-- Right page: the quest
------------------------------------------------------------------------------------------

local function Text(parent, font, color)
	local text = parent:CreateFontString(nil, "ARTWORK", font or "GameFontBlack")
	text:SetWidth(DETAIL_WIDTH)
	text:SetJustifyH("LEFT")
	color = color or BODY_COLOR
	text:SetTextColor(color[1], color[2], color[3])
	return text
end

-- Classic QuestItemTemplate: the icon, then the item's name, in its quality's colour, on a
-- dark strip.
local function CreateRewardBox(parent)
	local box = CreateFrame("Button", nil, parent)
	box:SetSize(REWARD_BOX_WIDTH, REWARD_BOX_HEIGHT)
	box.Icon = box:CreateTexture(nil, "BORDER")
	box.Icon:SetSize(39, 39)
	box.Icon:SetPoint("TOPLEFT")
	box.NameFrame = box:CreateTexture(nil, "BACKGROUND")
	box.NameFrame:SetTexture("Interface\\QuestFrame\\UI-QuestItemNameFrame")
	box.NameFrame:SetSize(128, 64)
	box.NameFrame:SetPoint("LEFT", box.Icon, "RIGHT", -10, 0)
	box.Name = box:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	box.Name:SetSize(90, 36)
	box.Name:SetPoint("LEFT", box.NameFrame, "LEFT", 15, 0)
	box.Name:SetJustifyH("LEFT")
	-- How many, as the quest frame shows it on the icon.
	box.Count = box:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	box.Count:SetPoint("BOTTOMRIGHT", box.Icon, -3, 3)
	box:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if ns.Items:IsIdentified(self.itemID) then
			GameTooltip:SetItemByID(self.itemID)
		else
			GameTooltip:SetText(self.Name:GetText() or "", 1, 1, 1)
			GameTooltip:AddLine(L.LOOT_UNIDENTIFIED_TOOLTIP, 0.6, 0.6, 0.6, true)
		end
		GameTooltip:Show()
	end)
	box:SetScript("OnLeave", function() GameTooltip:Hide() end)
	box:SetScript("OnClick", function(self)
		local info = ns.Items:Get(self.itemID)
		ns.Gamepad:ItemClick(info.link)
	end)
	return box
end

local MoneyText = ns.MoneyText

local function Number(value)
	if type(BreakUpLargeNumbers) == "function" then
		local ok, text = pcall(BreakUpLargeNumbers, value)
		if ok and text then return text end
	end
	return tostring(value)
end

-- Said only when it adds something the list's icon does not: what is still needed, or that
-- the quest can be handed in.
local function StatusNote(quest, status)
	if status == STATUS_READY then return GREEN .. L.QUEST_STATUS_READY .. "|r" end
	if status ~= STATUS_LOCKED then return nil end
	return "|cff8a2a1a" .. QuestsPanel:LockedReason(quest) .. "|r"
end

local function FirstName(text)
	return text and (text:match("^([^,]+)") or text) or nil
end

-- Who gives or takes a quest, as this dungeon's page shows it. A quest another dungeon keeps (an
-- attunement's steps, on the raid's page or the Spire's) is done inside that one, not this: its
-- "inside the dungeon" names it, "inside Blackrock Depths" (ns.InsideNamed), in the language's
-- words where it has them (Core/Registry.lua's ns.ApplyLocale). A quest more than one wing of a
-- dungeon keeps (Falrin's quests in all of Dire Maul's) names the dungeon, "inside Dire Maul", not
-- the wing that happens to come first. So does a wing's
-- quest on the pages its wingUnsaidOn lists, where which wing it is done in is not known (West's
-- Athenaeum quests on Dire Maul North's page, the data filing the Athenaeum under both).
local function WingUnsaid(quest, instance)
	return quest.wingUnsaidOn ~= nil and instance ~= nil and quest.wingUnsaidOn[instance.key] == true
end

-- Whether the page lists the quest as its own, not as another dungeon's, shown as a chain's step.
local function OwnQuest(quest, instance)
	for _, own in ipairs(instance and instance.quests or {}) do
		if own == quest then return true end
	end
	return false
end

local function Where(quest, field, instance)
	local text = quest[field]
	if not text or not instance then return text end
	if OwnQuest(quest, instance) then return text end
	local home, keepers, dungeon = nil, 0, nil
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, other in ipairs(ns.GetInstances(kind)) do
			for _, candidate in ipairs(other.quests or {}) do
				if candidate.questID == quest.questID then
					if candidate == quest then home = other end
					local wingOf = ns.WingDungeon(other.enName or other.name) or false
					keepers = keepers + 1
					if keepers == 1 then dungeon = wingOf elseif dungeon ~= wingOf then dungeon = false end
					break
				end
			end
		end
	end
	if not home then return text end
	if (keepers > 1 or WingUnsaid(quest, instance)) and dungeon then
		local inside = quest.insideDungeon and quest.insideDungeon[field]
		return inside or ns.InsideNamed(text, dungeon) or text
	end
	local inside = quest.inside and quest.inside[field]
	return inside or ns.InsideNamed(text, home.name) or text
end

--[[
	Whether the quest's pickup is its start item, not someone who gives it: the pickup begins with the
	item's name, as the data writes both in English ("Damp Note, dropped by Blackfathom Tide
	Priestesses"; Warlord's Command's "Warlord Goretooth, Badlands" is a giver). The English is kept
	where a translation was laid over them (Core/Registry.lua's TrQuest).
]]
local function PickupIsItem(quest)
	local item = quest.startItem
	local name = item and (item.enName or item.name)
	local pickup = quest.enPickup or quest.pickup
	return type(name) == "string" and name ~= "" and type(pickup) == "string" and pickup:sub(1, #name) == name
end

-- Where the quest starts and ends, best source first.
local function StartPoint(quest)
	local recorded = Recorded(quest.questID)
	local place = recorded and recorded.pickup and recorded.pickup.place
	if place and place.mapID and place.x then
		return { mapID = place.mapID, x = place.x, y = place.y, label = quest.pickup }
	end
	if quest.startMap then
		return { mapID = quest.startMap.mapID, x = quest.startMap.x, y = quest.startMap.y, label = quest.pickup or quest.startMap.label }
	end
	return nil
end

local function EndPoint(quest)
	local recorded = Recorded(quest.questID)
	local place = recorded and recorded.turnin and recorded.turnin.place
	if place and place.mapID and place.x then
		return { mapID = place.mapID, x = place.x, y = place.y, label = quest.turnin }
	end
	if quest.endMap then
		return { mapID = quest.endMap.mapID, x = quest.endMap.x, y = quest.endMap.y, label = quest.turnin or quest.endMap.label }
	end
	-- endMap = false: its end spot is not known, though the same person takes it somewhere else (Watch Yer Back's
	-- Sully, behind Theramore's graveyard, not at the inn where he gave it).
	if quest.endMap == false then return nil end
	-- Handed back to whoever gave it: the same spot.
	if quest.startMap and quest.turnin and FirstName(quest.turnin) == FirstName(quest.pickup) then
		return { mapID = quest.startMap.mapID, x = quest.startMap.x, y = quest.startMap.y, label = quest.turnin }
	end
	return nil
end

-- For the quest marks on the maps (UI/QuestMap.lua).
function QuestsPanel:StartPoint(quest) return StartPoint(quest) end
-- Whether the player has handed a quest in, or has it in their log.
function QuestsPanel:IsDone(questID) return IsDone(questID) end
function QuestsPanel:InLog(questID) return InLog(questID) end
function QuestsPanel:EndPoint(quest) return EndPoint(quest) end

--[[
	Show Start's and Show End's link faces. Each button is covered by a frame of the client's
	InlineHyperlinkFrameTemplate, the button's own size and place, whose text is the client's map pin link
	for its place (UI/DungeonMap.lua's WaypointLinkText) drawn as a picture of the button's size from the
	client's clear spacer (Interface\Common\spacer, the blank room its own tooltips leave with it): the
	whole button is the link, and the button's name, highlight and pushed look show through it. A click
	anywhere on the button runs that template's own OnHyperlinkClick alone, which hands the link to the
	client's link handler, as a click on a chat link does: the client sets its waypoint and opens the map
	on it, from its own code, in one click. The journal never sets that handler and never calls what it
	calls; it writes the face before any click, and says nothing after it, as the client's own map pin
	links say nothing. The handler takes any mouse button and reads no modifier (SetItemRef hands the
	link to it and is done): a right-click, Shift- or Ctrl-click sets the waypoint and opens the map too,
	and puts nothing in the chat.

	Over the face the journal lights the button (LockHighlight) and shows the button's tooltip in place of
	the template's (which would ask the tooltip for the link). The client may send the face's OnLeave as the
	mouse moves onto its link, inside the button, so the face's OnEnter and OnHyperlinkEnter both start the
	hover, its OnLeave and OnHyperlinkLeave do not end it, and while it lasts the face looks each frame
	(OnUpdate, a run of its own) at whether the mouse is still anywhere over the face or the button, and
	ends it once it is over neither, or another frame (the map the click opens over the journal, a menu) is
	the client's mouse focus there (or at once where the face is hidden). The client may not tell the face
	of a press on its link (OnMouseDown), so in that same look the face reads the mouse buttons and pushes
	the button while one is down, as the button's own press would:
	the face takes the mouse from the button, so the journal runs the button's own press and release
	scripts on it (its template swaps its art to the pressed look and back: UIPanelButton_OnMouseDown and
	_OnMouseUp), its own button and nothing of the client's. A press the face sees takes away the journal's
	own pin, wherever it stands, before the click, for the client's waypoint to take over; a press dragged
	off the face and let go elsewhere takes it away too, with no waypoint set, and a click down and up
	within one frame is not seen, and leaves the pin. And while the mouse is over a face a chat offer
	waiting for its waypoint is not heard (DungeonMap:HoldOffer, held by the face the mouse is on): the
	client hands out that event inside its click.

	Of the journal's own scripts and event handlers none runs inside the click itself but these: as the
	map opens, after the waypoint is set, the client's window manager may put the journal away to make room
	for it (docked, with no room for both, or the map opening full screen), as pressing M does, which runs
	the journal's own OnHide, the face's OnHide and OnLeave (and its empty OnHyperlinkLeave). They touch only the
	journal's own frames, the client's tooltip (hidden) and the offer's event (heard again). The map's own calls into the journal's map
	providers and its hooks run as on any opening of the map, under the client's secure execution.

	No face without a place, where the client allows no waypoint on its map (the journal's pin then, as
	before), or on a client without the template or the spacer: there the button's own click marks the
	spot and offers the link in the chat (MapPin:Mark).
]]
local LINK_TEMPLATE = "InlineHyperlinkFrameTemplate"
local CLEAR = "Interface\\Common\\spacer"

local function ShowButtonTip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:SetText(button.place or button.label or "", 1, 1, 1, 1, true)
	if not button.point then GameTooltip:AddLine(L.QUEST_PLACE_UNKNOWN, 0.6, 0.6, 0.6, true) end
	GameTooltip:Show()
end

-- Whether a mouse button is down: the template's handler takes a click of any of them.
local MOUSE_BUTTONS = { "LeftButton", "RightButton", "MiddleButton", "Button4", "Button5" }
local function MouseDown()
	if type(IsMouseButtonDown) ~= "function" then return false end
	for _, which in ipairs(MOUSE_BUTTONS) do
		if IsMouseButtonDown(which) then return true end
	end
	return false
end

-- The button pushed or let up, as its own press and release would: its state, and its template's own
-- scripts for them, which draw its pressed art or put the plain art back. A press takes the journal's
-- pin away (above).
local function PushButton(button, down)
	if down and ns.MapPin:Target() then ns.MapPin:Clear() end
	if not button:IsEnabled() then return end
	button:SetButtonState(down and "PUSHED" or "NORMAL")
	local script = button:GetScript(down and "OnMouseDown" or "OnMouseUp")
	if script then script(button, "LeftButton") end
end

-- The frame the mouse is on (the client's top mouse focus), if the client says.
local function MouseFocus()
	if type(GetMouseFoci) == "function" then
		local foci = GetMouseFoci()
		return type(foci) == "table" and foci[1] or nil
	end
	if type(GetMouseFocus) == "function" then return GetMouseFocus() end
	return nil
end

-- Whether `inner` is `outer` or lies inside it (the client's DoesAncestryInclude).
local function Holds(outer, inner)
	while inner do
		if inner == outer then return true end
		if type(inner) ~= "table" or not inner.GetParent or (inner.IsForbidden and inner:IsForbidden()) then return false end
		inner = inner:GetParent()
	end
	return false
end

-- Whether the mouse is anywhere over the face or its button, wherever the client sends its events: inside
-- the button, and on nothing drawn over it (the map a click opens over the journal, a menu). IsMouseOver
-- reads only the spot; the client's mouse focus tells another frame on it. No focus, the 3D world's, the
-- face's, the button's or a frame holding them (the journal) counts as over.
local function MouseOverButton(face)
	local button = face:GetParent()
	if not (face:IsMouseOver() or button:IsMouseOver()) then return false end
	local focus = MouseFocus()
	return focus == nil or focus == WorldFrame or Holds(focus, face) or Holds(button, focus)
end

-- The button at rest: the mouse gone from its face, or the face shown again; the face's hold on a chat
-- offer let go.
local function FaceRest(face)
	face:SetScript("OnUpdate", nil)
	face.down = nil
	local button = face:GetParent()
	button:UnlockHighlight()
	PushButton(button, false)
	ns.DungeonMap:HoldOffer(face, false)
end

-- The hover over: the button at rest, its tooltip gone.
local function FaceEnd(face)
	FaceRest(face)
	if GameTooltip:GetOwner() == face:GetParent() then GameTooltip:Hide() end
end

-- Each frame while the hover lasts: over neither the face nor the button, it ends; else the button lit,
-- pushed while a mouse button is down and up again as it comes up.
local function FaceUpdate(face)
	if not MouseOverButton(face) then
		FaceEnd(face)
		return
	end
	local button = face:GetParent()
	button:LockHighlight()
	local down = MouseDown()
	if down == face.down then return end
	face.down = down
	PushButton(button, down)
end

-- The hover begun, by the face's OnEnter or its OnHyperlinkEnter, whichever the client sends first; the
-- second only shows the tooltip again.
local function FaceStart(face)
	local button = face:GetParent()
	if not face:GetScript("OnUpdate") then
		-- A button already down as the mouse came over was pressed elsewhere.
		face.down = MouseDown()
		face:SetScript("OnUpdate", FaceUpdate)
		ns.DungeonMap:HoldOffer(face, true)
	end
	button:LockHighlight()
	-- (a button of the journal's other faces may show its own tooltip: ShowFaceTip)
	local showTip = rawget(button, "ShowFaceTip") or ShowButtonTip
	showTip(button)
end

-- The face's OnLeave (and OnHyperlinkLeave): the hover goes on, for its own look to end it; only a face
-- hidden under the mouse, which has no look again, ends it here.
local function FaceLeave(face)
	if not face:IsVisible() then FaceEnd(face) end
end

local function CreateLinkFace(button)
	if not ns.HasTemplate(LINK_TEMPLATE) then return nil end
	local ok, face = pcall(CreateFrame, "Frame", nil, button, LINK_TEMPLATE)
	if not (ok and face) then return nil end
	-- The template's own click handler, as the client set it; else no face.
	local enabled = not face.GetHyperlinksEnabled or face:GetHyperlinksEnabled()
	if not (enabled and face:GetScript("OnHyperlinkClick")) then
		face:Hide()
		return nil
	end
	face:SetFrameLevel(button:GetFrameLevel() + 2)
	face:SetAllPoints(button)
	face:EnableMouse(true)
	face.Text = face:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	face.Text:SetPoint("CENTER", face, "CENTER", 0, 0)
	face.Text:SetWordWrap(false)
	face:SetScript("OnEnter", FaceStart)
	face:SetScript("OnHyperlinkEnter", FaceStart)
	face:SetScript("OnLeave", FaceLeave)
	face:SetScript("OnHyperlinkLeave", FaceLeave)
	face:SetScript("OnShow", FaceRest)
	face:SetScript("OnHide", FaceEnd)
	-- Where the client does tell the face of a press, the same as its own look.
	face:SetScript("OnMouseDown", function()
		face.down = true
		PushButton(button, true)
	end)
	face:SetScript("OnMouseUp", function()
		face.down = false
		PushButton(button, false)
	end)
	face:Hide()
	return face
end

-- The face for the button's place, or none. It is as big as the button, or as the part of it the face is laid
-- over (button.faceRegion: the Gear Finder's rumour slots, UI/GearPanel.lua).
local function SetLinkFace(button)
	local face, point = button.LinkFace, button.point
	local link
	if face and point and ns.FileExists(CLEAR) then
		local width, height = (rawget(button, "faceRegion") or button):GetSize()
		link = ns.DungeonMap:WaypointLinkText(point.mapID, point.x or 0.5, point.y or 0.5,
			string.format("|T%s:%d:%d|t", CLEAR, math.ceil(height or 0), math.ceil(width or 0)))
	end
	if not link then
		if face then face:Hide() end
		return
	end
	face:SetFrameLevel(button:GetFrameLevel() + 2)
	face.Text:SetText(link)
	face:Show()
end

local function SetMapButton(button, point, title, place)
	button.point, button.title, button.place = point, title, place
	button:SetEnabled(point ~= nil)
	SetLinkFace(button)
end

--[[
	A map button's width: the quest page's 112, or wider where its label needs it: the label's own width on one line
	(GetUnboundedStringWidth, the words' width whatever the room) and 40, the template's own allowance for its label
	(fitTextWidthPadding, Blizzard_SharedXML/SecureUIPanelTemplates.xml:41-42; the client's own FitToText widens this
	template to GetTextWidth() + 40 just after SetText, so Button:GetTextWidth is most likely the same one-line width,
	a best guess).

	Its words on one line. The vendor's Show Map has the client's own words, ENCOUNTER_JOURNAL_SHOW_MAP (L.MAP_SHOW),
	which Forever's English client has as "Show\nMap" (its GlobalStrings.db2, read 2026-11-14): two lines, for the
	retail journal's Show Map beside its map icon, as the journal's own overview shows it (UI/EncounterPage.lua). On one
	line the client draws a label with a line break as its first line and "...": build 5's "Show..." (the owner's
	screenshot of 2026-11-14), whatever the room; build 3's "Sho..." where the label was only as wide as "Show"; build
	2's two lines spilling out of the button where it could wrap. Show Start and Show End, the journal's own words, have
	no line break, and so came out whole. So a map button's line breaks are joined (MapLabelText): a space, or nothing
	on a Chinese client, whose words have no spaces between them (a line break comes from the client's own strings, in
	its own language).

	The label's room. UIPanelButtonTemplate's label (its ButtonText) has no width or anchors of its own
	(SecureUIPanelTemplates.xml:81), and the client does not widen it with the button. So the journal sets the room
	itself, whatever the client did: the label is anchored to both sides of its button, MAP_LABEL_INSET in (the
	template's end pieces, 12 wide), and given that width too each time the button's width is set, changes or it is
	shown (as Blizzard's own TruncatedButtonTemplate sets its text's width on OnSizeChanged, SharedUIPanelTemplates.lua).
	On one line: a label longer than its room would end in "..." rather than run out of the button, and MapButtonNeed
	keeps the button wide enough that it never is.
]]
local MAP_BUTTON_WIDTH, MAP_BUTTON_HEIGHT, MAP_BUTTON_PADDING, MAP_LABEL_INSET = 112, 22, 40, 12
-- Every map button made, for /aegis buttons.
local madeMapButtons = {}

-- The button's label (the template's Text, else the client's own font string for it).
local function MapButtonLabel(button)
	return rawget(button, "Text") or (button.GetFontString and button:GetFontString()) or nil
end

-- A label's words on one line (above): each line break ("\n", or the client's "|n") a space, or nothing in Chinese.
local function MapLabelText(text)
	if type(text) ~= "string" then return text end
	local locale = GetLocale and GetLocale()
	local join = (locale == "zhCN" or locale == "zhTW") and "" or " "
	return (text:gsub("%s*|n%s*", join):gsub("%s*\n%s*", join))
end

-- The label's room: the button's width less its ends, on one line, centered (above), anchored at both sides every
-- time. Only while the button is held down are its anchors left as they are: the client moves a pressed label by
-- its pushed text offset and back as it is let up, and how is not known (a best guess: by its anchors, the mock's
-- SetButtonState), so anchoring it then could leave it off by that much. Its width is set all the same.
local function FitMapLabel(button)
	local label = MapButtonLabel(button)
	if not label then return end
	if label.SetWordWrap then label:SetWordWrap(false) end
	if not (button.GetButtonState and button:GetButtonState() == "PUSHED") then
		label:ClearAllPoints()
		label:SetPoint("LEFT", button, "LEFT", MAP_LABEL_INSET, 0)
		label:SetPoint("RIGHT", button, "RIGHT", -MAP_LABEL_INSET, 0)
	end
	label:SetWidth(math.max(1, (tonumber(button:GetWidth()) or 0) - 2 * MAP_LABEL_INSET))
end

-- The button's width, and its label's room with it.
local function SetMapButtonWidth(button, width)
	button:SetWidth(width)
	FitMapLabel(button)
end

-- One font string to measure other words in a map button's font (MapButtonNeed's text), made on the first button that
-- asks; it holds no words between measures, so it draws nothing.
local measurer

-- How wide the button must be for its label on one line, the template's allowance with it; or, given a text, for
-- that text in its label's font (the quest page's Show End, for the vendors' Show Map: MapButtonWidth).
local function MapButtonNeed(button, text)
	local label = MapButtonLabel(button)
	local width
	if text and label and label.GetFont then
		measurer = measurer or button:CreateFontString(nil, "ARTWORK")
		local font, size, flags = label:GetFont()
		if font then measurer:SetFont(font, size, flags) else measurer:SetFontObject(label:GetFontObject()) end
		measurer:SetText(MapLabelText(text))
		width = measurer.GetUnboundedStringWidth and measurer:GetUnboundedStringWidth() or measurer:GetStringWidth()
		measurer:SetText("")
	elseif label and label.GetUnboundedStringWidth then
		width = label:GetUnboundedStringWidth()
	elseif button.GetTextWidth then
		width = button:GetTextWidth()
	end
	return math.ceil(tonumber(width) or 0) + MAP_BUTTON_PADDING
end

-- Its width: the quest page's 112, or what its label needs.
local function FitMapButton(button)
	SetMapButtonWidth(button, math.max(MAP_BUTTON_WIDTH, MapButtonNeed(button)))
end

-- A vendor's Show Map beside the quest page's buttons (the owner, 2026-11-14: "they should be the same size and
-- font"): Show End's width in the client's language, the quest page's 112 or what its words need in the same font,
-- and wider only where its own label needs more (never cut). German's "Karte anzeigen" needs 126, Show End 112.
local function MapButtonWidth(button)
	return math.max(MAP_BUTTON_WIDTH, MapButtonNeed(button), MapButtonNeed(button, L.QUEST_SHOW_END))
end

local function CreateMapButton(parent, text)
	local button = ns.CreateFrameWithTemplate("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(MAP_BUTTON_WIDTH, MAP_BUTTON_HEIGHT)
	text = MapLabelText(text)
	button:SetText(text)
	local label = MapButtonLabel(button)
	-- How the client made the label, before the journal sets its room (/aegis buttons): whether the button was made
	-- where it shows, the label's width and its anchors.
	button.labelAsMade = {
		shown = parent and parent.IsVisible and parent:IsVisible() or false,
		width = label and label.GetWidth and tonumber(label:GetWidth()) or nil,
		points = label and label.GetNumPoints and label:GetNumPoints() or nil,
	}
	if label and label.SetJustifyH then label:SetJustifyH("CENTER") end
	FitMapButton(button)
	-- (its label's room again whenever its size changes, or it is shown: FitMapLabel)
	button:HookScript("OnSizeChanged", FitMapLabel)
	button:HookScript("OnShow", FitMapLabel)
	madeMapButtons[#madeMapButtons + 1] = button
	button.label = text
	button:SetMotionScriptsWhileDisabled(true)
	-- Where it has no face (above).
	button:SetScript("OnClick", function(self)
		ns.PlaySoundKit("IG_MAINMENU_OPTION")
		ns.MapPin:Mark(self.point, self.title)
	end)
	button:SetScript("OnEnter", ShowButtonTip)
	-- (while its face's hover lasts, the face ends it and its tooltip: FaceEnd)
	button:SetScript("OnLeave", function(self)
		if not (self.LinkFace and self.LinkFace:GetScript("OnUpdate")) then GameTooltip:Hide() end
	end)
	button.LinkFace = CreateLinkFace(button)
	return button
end

--[[
	The same faces for the journal's other map pin links (the Gear Finder's rumours, UI/GearPanel.lua): a face
	over any button of the journal's (CreateLinkFace, nil where the client has no template), its link written
	for button.point or hidden where it has none (SetLinkFace); a button that has a face shows its own
	tooltip over it where it has a ShowFaceTip(button). A Show Start of their own is QuestsPanel:CreateMapButton and
	QuestsPanel:SetMapButton below (point, its title for a button with no face, its place for the tooltip).
]]
QuestsPanel.CreateLinkFace, QuestsPanel.SetLinkFace = CreateLinkFace, SetLinkFace

-- What the detail page may show, hidden for a page with no quest chosen and for a quest not offered yet.
local DETAIL_PARTS = { "Title", "Part", "Status", "Objective", "Note", "DescriptionHeader", "Description", "ShowStart",
	"ShowEnd", "Giver", "RewardsHeader", "Receive", "Money", "Experience", "ExperienceNote", "ExperienceHover", "Reputation",
	"Choose", "Also" }
local function HideDetail(child)
	for _, key in ipairs(DETAIL_PARTS) do child[key]:Hide() end
	for _, box in ipairs(child.RewardBoxes) do box:Hide() end
end

-- The same map button, link face and all, for a currency vendor's place on their page (UI/EncounterPage.lua): made
-- with its text, then set to a point { mapID, x, y } (nil: disabled), a title for the journal's pin and the chat, and
-- the place its tooltip names. MapButtonWidth: its width beside the quest page's Show End; SetMapButtonWidth: its
-- width, its label's room with it. MapLabelText: a label's words on one line.
QuestsPanel.MAP_BUTTON_WIDTH = MAP_BUTTON_WIDTH
function QuestsPanel:CreateMapButton(parent, text) return CreateMapButton(parent, text) end
function QuestsPanel:SetMapButton(button, point, title, place) SetMapButton(button, point, title, place) end
function QuestsPanel:MapButtonNeed(button, text) return MapButtonNeed(button, text) end
function QuestsPanel:MapButtonWidth(button) return MapButtonWidth(button) end
function QuestsPanel:SetMapButtonWidth(button, width) SetMapButtonWidth(button, width) end
function QuestsPanel:MapLabelText(text) return MapLabelText(text) end

--[[
	/aegis buttons: the client's own words for Show Map, then each map button made so far (Show Start, Show End, each
	vendor's Show Map), for checking in the game that its label is whole, and if not, why: its words (a line break
	shown as \n), how many lines and whether the client cut it short (IsTruncated) or may wrap it (CanWordWrap); its font
	(file, size, font object) and the button's effective scale; the button's width, what its label needs, and Show End's
	width in that font; the label's own width (its room: the button's less 24), its width on one line and as drawn; each
	of its anchors (point, offsets; another frame's or point's named); and how the client made it, before the journal set
	its room. What each cause of a cut label would print:
	  a line break in its words (build 5's "Show...", the cause found): \n in its words, 2 lines or cut short, though its
	    one-line width is less than its room;
	  too little room (build 3's best guess): a label narrower than its one-line width, or anchors other than LEFT 12,0
	    and RIGHT -12,0;
	  another font or size: a font unlike Show End's line; a scale on the card: a scale unlike Show End's line (the same
	    font drawn smaller or larger);
	  a measure made while hidden, or before its font was in: "needs" less than its one-line width and 40.
	In English, like /aegis run debug.
]]
function QuestsPanel:DebugMapButtons()
	local function Read(object, method)
		local fn = object and object[method]
		if type(fn) ~= "function" then return nil end
		local ok, value = pcall(fn, object)
		if ok then return value end
		return nil
	end
	local function Width(value) return tonumber(value) and string.format("%.1f", value) or "?" end
	local function YesNo(value)
		if value == nil then return "?" end
		return value and "yes" or "no"
	end
	-- (its words as written: a line break as \n, and a |n shown, not drawn as one)
	local function Words(text)
		if type(text) ~= "string" then return tostring(text) end
		return "\"" .. text:gsub("|", "||"):gsub("\n", "\\n") .. "\""
	end
	local function Font(label)
		local ok, font, size, flags = pcall(label.GetFont, label)
		local object = Read(label, "GetFontObject")
		local name = type(object) == "table" and Read(object, "GetName") or (type(object) == "string" and object) or "?"
		if not (ok and font) then return "? (" .. tostring(name) .. ")" end
		return string.format("%s %s%s (%s)", tostring(font), Width(size), (flags and flags ~= "") and (" " .. flags) or "",
			tostring(name))
	end
	local function Anchors(button, label)
		local points = {}
		for index = 1, tonumber(Read(label, "GetNumPoints")) or 0 do
			local ok, point, relative, relativePoint, x, y = pcall(label.GetPoint, label, index)
			if ok then
				local to = ""
				if relative ~= button or relativePoint ~= point then
					local name = relative == button and "button" or (type(relative) == "table" and Read(relative, "GetName"))
					to = ">" .. tostring(name or "another frame") .. ":" .. tostring(relativePoint)
				end
				points[#points + 1] = string.format("%s%s %s,%s", tostring(point), to, tostring(x), tostring(y))
			end
		end
		return #points > 0 and table.concat(points, " ") or "none"
	end
	ns.Print("the client's Show Map words (ENCOUNTER_JOURNAL_SHOW_MAP): " .. Words(ENCOUNTER_JOURNAL_SHOW_MAP))
	if #madeMapButtons == 0 then
		ns.Print("no map buttons yet: open a quest's or a vendor's page first")
		return
	end
	for _, button in ipairs(madeMapButtons) do
		local label = MapButtonLabel(button)
		local made = rawget(button, "labelAsMade") or {}
		local scale = tonumber(Read(button, "GetEffectiveScale"))
		ns.Print(string.format("%s: lines %s, cut short: %s, may wrap: %s; font %s, scale %s; button %s, needs %d, Show End"
			.. " %d; label %s wide, one line %s, drawn %s; anchors %s%s; made %s, label %s wide, %s anchors%s",
			Words(Read(button, "GetText")), tostring(Read(label, "GetNumLines") or "?"), YesNo(Read(label, "IsTruncated")),
			YesNo(Read(label, "CanWordWrap")), Font(label), scale and string.format("%.2f", scale) or "?",
			Width(Read(button, "GetWidth")), MapButtonNeed(button),
			math.max(MAP_BUTTON_WIDTH, MapButtonNeed(button, L.QUEST_SHOW_END)), Width(Read(label, "GetWidth")),
			Width(Read(label, "GetUnboundedStringWidth")), Width(Read(label, "GetStringWidth")), Anchors(button, label),
			Read(button, "GetButtonState") == "PUSHED" and " (pushed)" or "",
			made.shown and "shown" or "hidden", Width(made.width), tostring(made.points or "?"),
			button:IsVisible() and "" or " (hidden)"))
	end
end

-- The detail page, laid out top to bottom for the chosen quest (asStep: chosen as a step of a chain; part:
-- { n, count }, chosen as one of the parts of a name, ChainRows).
local function FillDetail(detail, quest, instance, asStep, part)
	local child = detail.Child
	-- A row of same-named quests shows the page of the part the player is on (the last, once all are
	-- done), under its own name, with which part it is; a part chosen as its own row says which it is too.
	local partIndex, partCount, rowKnown
	if quest.parts then
		partCount, rowKnown = #quest.parts, Known(quest)
		quest, partIndex = ShownPart(quest)
	elseif part then
		partIndex, partCount = part[1], part[2]
		rowKnown = part[3] ~= nil and Known(part[3])
	end
	-- Adventure Mode: a quest not offered yet has its name (a part of a row known by its name, that name;
	-- else "???"), which part it is, and a line saying it is not offered yet; nothing of its own.
	if not Known(quest) then
		HideDetail(child)
		local y = 6
		child.Title:SetText(rowKnown and quest.name or ShownName(quest))
		child.Title:ClearAllPoints()
		child.Title:SetPoint("TOPLEFT", 2, -y)
		child.Title:Show()
		y = y + child.Title:GetStringHeight()
		if partIndex then
			child.Part:SetText(string.format(L.QUEST_PART_OF, partIndex, partCount))
			child.Part:ClearAllPoints()
			child.Part:SetPoint("TOPLEFT", 2, -(y + 2))
			child.Part:Show()
			y = y + 2 + child.Part:GetStringHeight()
		end
		child.Objective:SetText(L.ADVENTURE_QUEST_UNKNOWN)
		child.Objective:ClearAllPoints()
		child.Objective:SetPoint("TOPLEFT", 2, -(y + 8))
		child.Objective:Show()
		y = y + 8 + child.Objective:GetStringHeight()
		child:SetHeight(y + 12)
		return
	end
	local status = QuestsPanel:Status(quest)
	-- A one-of row is no one quest: nothing recorded is its.
	local recorded = not quest.oneOf and Recorded(quest.questID) or nil
	local y = 6

	local function place(region, gap, height)
		region:ClearAllPoints()
		region:SetPoint("TOPLEFT", 2, -(y + (gap or 0)))
		region:Show()
		y = y + (gap or 0) + (height or (region.GetStringHeight and region:GetStringHeight()) or region:GetHeight())
	end

	child.Title:SetText(ShownName(quest) or "")
	place(child.Title)

	child.Part:SetShown(partIndex ~= nil)
	if partIndex then
		child.Part:SetText(string.format(L.QUEST_PART_OF, partIndex, partCount))
		place(child.Part, 2)
	end

	local note = StatusNote(quest, status)
	child.Status:SetShown(note ~= nil)
	if note then
		child.Status:SetText(note)
		place(child.Status, 2)
	end

	local objective = quest.objective or (recorded and recorded.objective)
	if quest.oneOf and not quest.objective then
		objective = SharedName(quest.oneOf) and string.format(L.QUEST_ONE_OF_VERSIONS, #quest.oneOf) or L.QUEST_ONE_OF_ANY
	end
	child.Objective:SetShown(objective ~= nil)
	if objective then
		child.Objective:SetText(objective)
		place(child.Objective, 8)
	end
	local notes = {}
	-- Adventure Mode: the journal's own notes, and who gives and takes the quest, name nothing not found
	-- yet (Discovery:MaskAll), as Before you go's do: they are our words, not the game's (the quest's
	-- objective and text, which the game told, stay as they are; so does the item it begins with, which
	-- the character holds to be offered it). A quest not offered yet that a note names is "???", as its
	-- row is.
	local untold = ns.Discovery:Untold(instance)
	-- (named: the quests named after someone its note names as quests, namesQuests)
	local function Ours(text, named)
		return ns.Discovery:MaskAll(instance, text, untold, named)
	end
	-- What it begins with, and beneath it the start's own note: where the item drops or the object
	-- stands ("From A Dusty Tome inside Dire Maul.").
	local start = (quest.startItem and quest.startItem.name and quest.startItem)
		or (quest.startObject and quest.startObject.name and quest.startObject)
	if start then
		notes[#notes + 1] = ns.Discovery:MaskQuests(L.QUEST_START_ITEM .. " " .. start.name)
		if start.note then notes[#notes + 1] = Ours(start.note) end
	end
	-- (on a page where the quest's wing is not said, its note that names none, if it has one)
	local questNote = WingUnsaid(quest, instance) and quest.wingUnsaidNote or quest.note
	-- Where its chain goes next (followUp), on the page that lists the quest as its own alone, and chosen
	-- as its row there: another page that shows it as a step of a chain (another dungeon's copy,
	-- KnownQuest) lists what follows below it, or is the page the note would send you to, and its own
	-- page's chains that hold it as a step list what follows below it too.
	if quest.followUp and OwnQuest(quest, instance) and not asStep then
		-- (after the note, in its paragraph; a note in Chinese ends with its own full stop, no space)
		questNote = questNote and (questNote .. (questNote:find("。$") and "" or " ") .. quest.followUp) or quest.followUp
	end
	if questNote then notes[#notes + 1] = Ours(questNote, quest.namesQuests) end
	child.Note:SetShown(#notes > 0)
	if #notes > 0 then
		-- (an item a note names is a link, as in Before you go: State Secrets' Fractured Insignia and the toy they make)
		local noteText = ns.Items:LinkText(table.concat(notes, "\n"))
		child.Note:SetText(noteText)
		-- (a common item's link is white, as in the game, and the note then takes the game's text shadow)
		ns.Items:ShadowLinks(child.Note, noteText)
		place(child.Note, 6)
	end

	local description = recorded and recorded.description
	child.DescriptionHeader:SetShown(description ~= nil)
	child.Description:SetShown(description ~= nil)
	if description then
		place(child.DescriptionHeader, 12)
		child.Description:SetText(description)
		place(child.Description, 4)
	end

	-- Show Start and Show End, side by side as on the classic journals; a chain's one-of row's where
	-- its versions share them (false where they don't: OneOfRow). A dungeon's own one-of row has its
	-- own page.
	local source = quest
	if quest.oneOf and quest.shared ~= nil then source = quest.shared end
	if not source then
		child.ShowStart:Hide()
		child.ShowEnd:Hide()
		child.Giver:Hide()
	else
		local pickup, turnin = Where(source, "pickup", instance), Where(source, "turnin", instance)
		-- (fitted again before their faces are made: a label measured as the page was made, its font not yet in, may
		-- have come out short)
		FitMapButton(child.ShowStart)
		FitMapButton(child.ShowEnd)
		SetMapButton(child.ShowStart, StartPoint(source), quest.name, pickup)
		SetMapButton(child.ShowEnd, EndPoint(source), quest.name, turnin)
		place(child.ShowStart, 12, 22)
		child.ShowEnd:ClearAllPoints()
		child.ShowEnd:SetPoint("LEFT", child.ShowStart, "RIGHT", 12, 0)
		child.ShowEnd:Show()
		-- Who gives it and who takes it, written out beneath the buttons as their tooltips say it
		-- (a player's request): the taker only where it is someone else.
		-- A quest that starts from an item says where the item is ("Damp Note, dropped by ..."), on its
		-- own line: no one offers it.
		-- (Adventure Mode: the item it begins with named, as above; the rest as the notes are)
		local givers = {}
		if pickup and PickupIsItem(source) then
			local item = start and start.name
			if item and pickup:sub(1, #item) == item then
				givers[#givers + 1] = item .. Ours(pickup:sub(#item + 1))
			else
				givers[#givers + 1] = Ours(pickup)
			end
		elseif pickup then
			givers[#givers + 1] = Ours(string.format(L.QUEST_OFFERED_BY, pickup))
		end
		if turnin and turnin ~= pickup then
			givers[#givers + 1] = Ours(string.format(L.QUEST_HAND_IN_TO, turnin))
		end
		if #givers > 0 then
			child.Giver:SetText(table.concat(givers, "\n"))
			place(child.Giver, 6)
		else
			child.Giver:Hide()
		end
	end

	-- Rewards (a one-of row's where its versions' agree)
	local rewards = (source and source.rewards) or {}
	local turnedIn = recorded and recorded.turnedIn
	-- What the player was given, as recorded; else the data's, which may be only the original game's
	-- number (ns.QuestXP), shown with a note. A hand-in recorded at the level cap gives no XP, which
	-- says nothing about the quest's, so the data's number stays. Of a recorded hand-in, the number its
	-- quest window showed comes first (the reward window's, else the offer's, as the Record tab's text
	-- has it): what the turn-in gave counts any XP buff (a sleeping bag's +3%).
	local xp, originalXP = nil, false
	local seen = recorded and (recorded.rewards or recorded.offered)
	local window = seen and seen.xp
	if turnedIn and turnedIn.xp and turnedIn.xp > 0 then
		xp = (type(window) == "number" and window > 0) and window or turnedIn.xp
	else
		xp, originalXP = ns.QuestXP(source and source.questID, rewards)
	end
	if not xp and rewards.text then
		local digits = rewards.text:match("([%d,]+) XP")
		xp = digits and tonumber((digits:gsub(",", ""))) or nil
	end
	local money = (turnedIn and turnedIn.money) or rewards.money
	local reputation = {}
	if recorded and recorded.reputation then
		for faction, amount in pairs(recorded.reputation) do reputation[#reputation + 1] = { faction = faction, amount = amount } end
	else
		for _, entry in ipairs(rewards.reputation or {}) do reputation[#reputation + 1] = entry end
	end
	-- rewards.items, one of which is chosen when rewards.choice is set; rewards.also, given with it.
	local items, choice, also = rewards.items or {}, rewards.choice, rewards.also or {}
	-- Rewards seen on the quest frame (seen, above) fill in for a quest the data lists none for.
	if #items == 0 and seen then
		local ids = seen.choices or seen.items or {}
		choice = seen.choices ~= nil
		items = {}
		for _, itemID in ipairs(ids) do items[#items + 1] = { itemID = itemID } end
	end

	child.RewardsHeader:Hide()
	child.Receive:Hide()
	child.Money:Hide()
	child.Experience:Hide()
	child.ExperienceNote:Hide()
	child.ExperienceHover:Hide()
	child.Reputation:Hide()
	child.Choose:Hide()
	child.Also:Hide()
	for _, box in ipairs(child.RewardBoxes) do box:Hide() end

	-- The items in two columns, from the pool's box `first` on; returns the next free box.
	local function PlaceBoxes(list, first)
		y = y + 6
		for index, item in ipairs(list) do
			local slot = first + index - 1
			local box = child.RewardBoxes[slot]
			if not box then
				box = CreateRewardBox(child)
				child.RewardBoxes[slot] = box
			end
			box.itemID = item.itemID
			local info = ns.Items:Get(item.itemID, item)
			box.Icon:SetTexture(info.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
			local r, g, b = ns.Items:QualityColor(info.quality)
			box.Name:SetText(info.name or "")
			box.Name:SetTextColor(r, g, b)
			box.Count:SetText(item.count and item.count > 1 and item.count or "")
			local column = (index - 1) % 2
			box:ClearAllPoints()
			box:SetPoint("TOPLEFT", 2 + column * (REWARD_BOX_WIDTH + 8), -y)
			box:Show()
			if column == 1 or index == #list then y = y + REWARD_BOX_HEIGHT + 4 end
		end
		return first + #list
	end

	local hasRewards = (xp and xp > 0) or (money and money > 0) or #reputation > 0 or #items > 0 or #also > 0
	if hasRewards then
		place(child.RewardsHeader, 16)
		if money and money > 0 then
			-- As on the quest frame: the coins' numbers in white, after the dark label.
			child.Receive:SetText(L.QUEST_YOU_RECEIVE)
			place(child.Receive, 6)
			child.Money:SetText(MoneyText(money))
			child.Money:ClearAllPoints()
			child.Money:SetPoint("LEFT", child.Receive, "LEFT", child.Receive:GetStringWidth() + 6, 0)
			child.Money:Show()
		end
		if xp and xp > 0 then
			child.Experience:SetText(string.format(L.QUEST_XP, Number(xp)))
			place(child.Experience, 2)
			if originalXP then
				-- Only the original game's number: a muted note after it, and a tooltip saying so.
				local note, used = child.ExperienceNote, child.Experience:GetStringWidth() + 5
				note:SetWidth(DETAIL_WIDTH - used)
				note:SetText(L.QUEST_XP_ORIGINAL)
				note:ClearAllPoints()
				note:SetPoint("TOPLEFT", child.Experience, "TOPLEFT", used, 0)
				note:Show()
				local lineHeight = child.Experience:GetStringHeight()
				y = y + math.max(0, note:GetStringHeight() - lineHeight)
				local hover = child.ExperienceHover
				hover:ClearAllPoints()
				hover:SetPoint("TOPLEFT", child.Experience, "TOPLEFT")
				hover:SetSize(used + note:GetStringWidth(), math.max(lineHeight, note:GetStringHeight()))
				hover:Show()
			end
		end
		if #reputation > 0 then
			local lines = {}
			for _, entry in ipairs(reputation) do
				-- The faction as the client names it, where it does (Core/Reputation.lua)
				lines[#lines + 1] = string.format(L.QUEST_REPUTATION, entry.amount, ns.Reputation:QuestFactionName(entry.faction))
			end
			child.Reputation:SetText(table.concat(lines, "\n"))
			place(child.Reputation, 2)
		end
		local nextBox = 1
		if #items > 0 then
			if choice then
				child.Choose:SetText(L.QUEST_CHOOSE)
				place(child.Choose, 8)
			end
			nextBox = PlaceBoxes(items, nextBox)
		end
		if #also > 0 then
			child.Also:SetText(L.QUEST_ALSO)
			place(child.Also, 8)
			PlaceBoxes(also, nextBox)
		end
	end

	child:SetHeight(y + 12)
end

------------------------------------------------------------------------------------------
-- The panel
------------------------------------------------------------------------------------------

function QuestsPanel:Create(page, info)
	-- Left page: the same place as the boss list.
	local list = ns.CreateScrollFrame(info, 5, -5, 5)
	-- The boss list's height: the dungeon's name above stays clear.
	list:SetSize(338, 364)
	list:SetPoint("BOTTOMLEFT", 25, 1)
	list:SetFrameLevel(info:GetFrameLevel() + 5)
	list.Child:SetWidth(LIST_WIDTH)
	-- Notes: Before you go's headers with no quests of their own (the dropdowns stay list.Headers).
	list.Rows, list.Headers, list.Boxes, list.Notes = {}, {}, {}, {}
	-- Before you go's bar, with its label as a boss page's "Overview" has it.
	local bar = list.Child:CreateTexture(nil, "ARTWORK")
	ns.Art(bar, "Header-Overview")
	bar:SetWidth(LIST_WIDTH + 6)
	bar:Hide()
	local label = list.Child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 8, 6)
	label:SetText(L.PREPARE_TITLE)
	local color = ns.HEADER_LABEL_COLOR
	label:SetTextColor(color[1], color[2], color[3])
	label:Hide()
	-- What Before you go shows, as last drawn (QuestsPanel:Refresh): its bar and label, its headers in order
	-- (keys' dropdowns and notes alike) and the quests in its keys' boxes.
	list.beforeYouGo = { bar = bar, label = label, headers = {}, rows = {} }
	list:Hide()

	-- Right page: the chosen quest.
	local detail = ns.CreateScrollFrame(info, -15, -6, 6)
	detail:SetSize(350, 383)
	detail:SetPoint("BOTTOMRIGHT", -5, 1)
	detail:SetFrameLevel(info:GetFrameLevel() + 5)
	detail.Child:SetWidth(DETAIL_WIDTH + 5)
	detail:Hide()

	local headerFont = ns.Font("QuestTitleFont", "GameFontNormalLarge")
	local child = detail.Child
	child.Title = Text(child, headerFont, TITLE_COLOR)
	child.Status = Text(child, "GameFontNormalSmall")
	child.Part = Text(child, "GameFontNormalSmall")
	child.Objective = Text(child)
	child.Note = Text(child)
	-- Items a note names are links (ns.Items:LinkText), as on Before you go's notes (UI/AbilitiesPanel.lua): pointing at
	-- one shows the item. No click handler: this page holds Show Start's and Show End's map pin links, whose clicks are
	-- the client's alone (the smoke test's link-setter check), so a click on an item here does nothing.
	pcall(child.SetHyperlinksEnabled, child, true)
	pcall(child.SetScript, child, "OnHyperlinkEnter", function(self, link)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		pcall(GameTooltip.SetHyperlink, GameTooltip, link)
		GameTooltip:Show()
	end)
	pcall(child.SetScript, child, "OnHyperlinkLeave", function() GameTooltip:Hide() end)
	child.DescriptionHeader = Text(child, headerFont, TITLE_COLOR)
	child.DescriptionHeader:SetText(L.QUEST_DESCRIPTION)
	child.Description = Text(child)
	child.ShowStart = CreateMapButton(child, L.QUEST_SHOW_START)
	child.ShowEnd = CreateMapButton(child, L.QUEST_SHOW_END)
	child.Giver = Text(child)
	child.RewardsHeader = Text(child, headerFont, TITLE_COLOR)
	child.RewardsHeader:SetText(L.QUEST_REWARDS)
	child.Receive = Text(child, nil, TITLE_COLOR)
	child.Money = child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	child.Money:Hide()
	child.Experience = Text(child)
	child.ExperienceNote = Text(child, nil, NOTE_COLOR)
	-- Over the XP and its note, for the note's tooltip; clicks and the wheel pass to the page. A client
	-- that can't take motion without clicks gets no tooltip there, as the Forever mark does.
	child.ExperienceHover = CreateFrame("Frame", nil, child)
	if child.ExperienceHover.SetMouseMotionEnabled and child.ExperienceHover.SetMouseClickEnabled then
		child.ExperienceHover:SetMouseMotionEnabled(true)
		child.ExperienceHover:SetMouseClickEnabled(false)
	end
	child.ExperienceHover:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(child.Experience:GetText() or "", 1, 1, 1)
		GameTooltip:AddLine(L.QUEST_XP_ORIGINAL_TIP, 0.6, 0.6, 0.6, true)
		GameTooltip:Show()
	end)
	child.ExperienceHover:SetScript("OnLeave", function() GameTooltip:Hide() end)
	child.ExperienceHover:Hide()
	child.Reputation = Text(child, ns.Font("GameFontNormalSmall", "GameFontBlack"), REPUTATION_COLOR)
	child.Choose = Text(child)
	child.Also = Text(child)
	child.RewardBoxes = {}

	child.Empty = Text(child)
	child.Empty:SetPoint("TOPLEFT", 2, -8)
	child.Empty:SetText(L.QUEST_NONE)

	-- The player's quest log changes what every row says.
	list:RegisterEvent("QUEST_LOG_UPDATE")
	list:RegisterEvent("QUEST_TURNED_IN")
	list:RegisterEvent("QUEST_ACCEPTED")
	list:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	list:SetScript("OnEvent", function(self)
		if self:IsVisible() and not self.refreshQueued then
			self.refreshQueued = true
			C_Timer.After(0.2, function()
				self.refreshQueued = nil
				if self:IsVisible() then QuestsPanel:Refresh(page) end
			end)
		end
	end)

	self.page = page
	page.QuestList, page.QuestDetail = list, detail
	page.expandedChains = {}
end

function QuestsPanel:Show(page, shown)
	page.QuestList:SetShown(shown)
	page.QuestDetail:SetShown(shown)
	page.Bosses:SetShown(not shown)
	if shown then self:Refresh(page) end
end

-- asStep: chosen as a step of a chain (its row one in), not as its own row; under: the row it is listed
-- under (a quest two chains list may have a part's number in one alone). A quest opened from elsewhere
-- (search, the map) is chosen as its row, or as its part's row (Refresh).
function QuestsPanel:Select(quest, asStep, under)
	local page = self.page
	page.selectedQuest, page.selectedAsStep, page.selectedUnder = quest, asStep == true or nil, asStep and under or nil
	self:Refresh(page)
end

-- Opens the journal on a dungeon's Quests tab with the quest chosen (search, the map's quest
-- marks), the dropdown and the chain that hold it open.
function QuestsPanel:Open(instance, quest)
	local journal = ns.Journal
	journal:Show()
	-- (the tab's Refresh as it shows chooses its first quest still to do, but opens no chain for it: ChooseFirst)
	self.page.opening = true
	journal:OpenInstance(instance)
	ns.EncounterPage:SetTab(journal:Page(), ns.EncounterPage.TAB_QUESTS)
	self.page.opening = nil
	self.page.reveal = quest
	self:Select(quest)
end

-- A click on a road's line (RoadLine): the road's dropdown in Before you go opened, the quest the line names chosen
-- there and scrolled to, as a quest opened from elsewhere is (a part of a row of same-named quests as its part's row
-- under it); with none to choose, the road's header scrolled to (in Adventure Mode, a road none of whose quests is known).
function QuestsPanel:OpenRoad(road)
	local page = self.page
	page.expandedChains[road.key] = true
	if road.quest then
		page.selectedQuest, page.selectedAsStep, page.selectedUnder = road.quest, nil, nil
		page.reveal = road.quest
	else
		page.revealKey = road.key
	end
	self:Refresh(page)
end

local function Holds(quests, quest)
	for _, held in ipairs(quests or {}) do
		if held == quest then return true end
	end
	return false
end

-- The parchment box an open dropdown's quests sit in, as an ability's text does on the Abilities tab.
local function CreateBox(child)
	local box = child:CreateTexture(nil, "BACKGROUND")
	ns.Art(box, "AbilityTextBG")
	box.Bottom = child:CreateTexture(nil, "BACKGROUND")
	ns.Art(box.Bottom, "AbilityTextBottomBorder")
	box.Bottom:ClearAllPoints()
	box.Bottom:SetPoint("LEFT", box, "BOTTOMLEFT")
	box.Bottom:SetPoint("RIGHT", box, "BOTTOMRIGHT")
	return box
end

-- Where a dropdown's chain branches, the quests that follow each branch's first quest, by that quest: its chain's next
-- steps (QuestsPanel:Rows's BranchesOn, for ChainRows). Built again with the rows.
local nextSteps = setmetatable({}, { __mode = "k" })

-- A dropdown's quests in order, each quest its chain branches into followed by the quests after it on its branch
-- (nextSteps: steps under its +, no rows of their own, yet the dropdown's quests all the same); under: by position,
-- the row such a step is listed under.
local function DropdownQuests(quests)
	local all, under = {}, {}
	for _, quest in ipairs(quests) do
		all[#all + 1] = quest
		for _, step in ipairs(nextSteps[quest] or {}) do
			all[#all + 1] = step
			under[#all] = quest
		end
	end
	return all, under
end

--[[
	The first of these quests still to do (the first, once all are done), the quests after a branch included; and,
	for one of those, the row it is listed under (it is chosen there, as a step). In Adventure Mode one the
	character knows first, still to do, else done (a "???" row tells nothing).
]]
local function FirstToDo(quests)
	local all, under = DropdownQuests(quests)
	if ns.Style:Adventure() then
		local known
		for index, quest in ipairs(all) do
			if Known(quest) then
				if QuestsPanel:Status(quest) ~= STATUS_DONE then return quest, under[index] end
				known = known or index
			end
		end
		if known then return all[known], under[known] end
	end
	for index, quest in ipairs(all) do
		if QuestsPanel:Status(quest) ~= STATUS_DONE then return quest, under[index] end
	end
	return all[1]
end

--[[
	The quest a dropdown starts on (FirstToDo) and, where it is chosen as a step of a chain, the row it is chosen
	under (QuestsPanel:Select's under). In Adventure Mode, where the character knows none of its rows, a step of a
	row's chain it knows (chainOf), the first still to do, else the first: a prerequisite or a later step is often
	the first quest a character is offered, and a "???" row tells nothing. Where none of those is known either, a
	quest it knows of a road a row comes after (roads: QuestsPanel:Rows's, whose quests its + doesn't repeat; the road's
	dropdown, roadGroups), chosen there, not as a step, and returned with that dropdown (the owner's answer of
	2026-11-19: "open the road in Before you go on it", where today's Warlord's Command was chosen under Victory for the
	Horde's +).
]]
local function FirstShown(quests, chainOf, roads, roadGroups)
	local first, head = FirstToDo(quests)
	if not (first and ns.Style:Adventure() and chainOf) or Known(first) then return first, head end
	local known, knownRow
	for _, quest in ipairs(quests) do
		for _, step in ipairs(chainOf[quest] or {}) do
			if Known(step) then
				if QuestsPanel:Status(step) ~= STATUS_DONE then return step, quest end
				known, knownRow = known or step, knownRow or quest
			end
		end
	end
	local roadDone, roadDoneGroup
	for _, quest in ipairs(roads and quests or {}) do
		for _, key in ipairs(roads[quest] or {}) do
			local group = roadGroups and roadGroups[key]
			local road = group and FirstToDo(group.quests)
			if road and Known(road) then
				if QuestsPanel:Status(road) ~= STATUS_DONE then return road, nil, group end
				roadDone, roadDoneGroup = roadDone or road, roadDoneGroup or group
			end
		end
	end
	if known then return known, knownRow end
	if roadDone then return roadDone, nil, roadDoneGroup end
	return first, head
end

-- Chooses a dropdown's first quest still to do (FirstShown): one chosen as a step under its row, that row's +
-- opened; one of a road, the road's dropdown in Before you go unfolded so it is seen (as the owner's call of
-- 2026-11-18 unfolds a key's). Neither while QuestsPanel:Open shows the tab, as the quest opened from elsewhere is
-- chosen next, its chain alone open.
local function ChooseFirst(page, quests, chainOf, roads, roadGroups)
	local quest, head, roadGroup = FirstShown(quests, chainOf, roads, roadGroups)
	page.selectedQuest, page.selectedAsStep, page.selectedUnder = quest, head and true or nil, head
	if head and not page.opening then page.expandedChains[head.questID] = true end
	if roadGroup and not page.opening then
		page.expandedChains[roadGroup.section.key] = true
		roadGroup.section.expanded = true
	end
	return quest
end

-- A dropdown's header: the mark of its first quest still to do, and how many of its quests are done (the quests
-- after a branch counted too, as they were when they had rows of their own).
local function GroupSection(key, title, quests)
	local all = DropdownQuests(quests)
	local done = 0
	for _, quest in ipairs(all) do
		if QuestsPanel:Status(quest) == STATUS_DONE then done = done + 1 end
	end
	-- (in Adventure Mode the mark of one the character knows: FirstToDo)
	local first = FirstToDo(quests)
	return { key = key, title = title, status = first and QuestsPanel:Status(first) or STATUS_DONE,
		note = string.format("%d/%d", done, #all), flags = {} }
end

-- A click on a dropdown's header opens or folds it; as it opens, its first quest still to do is
-- chosen, unless one of its quests is chosen already.
function QuestsPanel:Clicked(section)
	local page = self.page
	local opening = not section.expanded
	page.expandedChains[section.key] = opening
	if opening and not section.members[page.selectedQuest] then
		ChooseFirst(page, section.quests, section.chainOf, section.roads, section.roadGroups)
	end
	self:Refresh(page)
end

-- A click on a note of Before you go no quest of its own fills only opens or folds it: the quest chosen stays.
function QuestsPanel:ToggleNote(section)
	local page = self.page
	page.expandedChains[section.key] = not section.expanded
	self:Refresh(page)
end

function QuestsPanel:ToggleChain(quest)
	local page = self.page
	page.expandedChains[quest.questID] = not page.expandedChains[quest.questID]
	self:Refresh(page)
end

-- A dungeon's own quest by its id (the first of the id it lists), looked up in a map made once for each
-- version of the data: the chains ask for every step in every dungeon.
local questsByID, questsByIDFor = setmetatable({}, { __mode = "k" }), nil
local function QuestByID(instance, questID)
	local quests = instance.quests
	if not quests then return nil end
	local dataVersion = ns.DataVersion and ns.DataVersion() or 0
	if questsByIDFor ~= dataVersion then questsByID, questsByIDFor = setmetatable({}, { __mode = "k" }), dataVersion end
	local byID = questsByID[quests]
	if not byID then
		byID = {}
		for _, quest in ipairs(quests) do
			if quest.questID ~= nil and byID[quest.questID] == nil then byID[quest.questID] = quest end
		end
		questsByID[quests] = byID
	end
	return byID[questID]
end

-- The page the journal keeps for a quest: this dungeon's, a step's, else another dungeon's. Where
-- several keep it, the one first by key, so every language shows the same copy (the list's order
-- goes by the translated names).
local function KnownQuest(instance, questID)
	local quest = QuestByID(instance, questID) or ns.GetQuestStep(questID)
	if quest then return quest end
	local key
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, other in ipairs(ns.GetInstances(kind)) do
			local copy = QuestByID(other, questID)
			if copy and (not key or other.key < key) then quest, key = copy, other.key end
		end
	end
	return quest
end

-- A chain's steps as rows. A step this dungeon does not list itself is the quest the journal
-- keeps for it (Data/Generated/QuestSteps.lua: its level, giver, objective, rewards, the page a
-- dungeon quest has), or another dungeon's own, as that dungeon keeps it (the Depths' Marshal
-- Windsor in Victory for the Alliance's chain on Onyxia's Lair: its page, its dungeon named, and
-- locked until what comes before it is done, as Before you go shows it), else its name alone; one
-- object each, so they can stay chosen. A step any one of several quests will do is one row, done
-- once one of them is: the version this character can take, if only one is theirs, else a row for
-- them all, its name theirs if they share one ("A or B" if not), locked while every one of them is.
local stepQuests = {}
local function StepRow(instance, questID, name, level, enName)
	local row = KnownQuest(instance, questID)
	if not row then
		stepQuests[questID] = stepQuests[questID] or { questID = questID, name = name, level = level, enName = enName }
		row = stepQuests[questID]
	end
	return row
end

local function Same(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then return a == b end
	for key, value in pairs(a) do
		if not Same(value, b[key]) then return false end
	end
	for key in pairs(b) do
		if a[key] == nil then return false end
	end
	return true
end

-- What a one-of row's versions share, for its page: who gives and takes them and where (as both A
-- Taste of Flame versions are Cyrus Therepentous's), and their rewards if those agree too (their XP
-- marked the same way: ns.QuestXP). Nil when the journal has no page for one of them, or they differ.
local function SharedPage(instance, versions)
	local first
	for _, version in ipairs(versions) do
		local page = KnownQuest(instance, version.questID)
		if not page then return nil end
		if not first then
			first = { questID = page.questID, pickup = page.pickup, turnin = page.turnin, startMap = page.startMap,
				endMap = page.endMap, rewards = page.rewards }
		elseif page.pickup ~= first.pickup or page.turnin ~= first.turnin or not Same(page.startMap, first.startMap)
			or not Same(page.endMap, first.endMap) then
			return nil
		elseif not Same(page.rewards, first.rewards)
			or select(2, ns.QuestXP(page.questID, page.rewards)) ~= select(2, ns.QuestXP(first.questID, first.rewards)) then
			first.rewards = nil
		end
	end
	return first
end

local function OneOfRow(instance, step)
	local versions = Versions(step)
	if #versions == 1 then
		return StepRow(instance, versions[1].questID, versions[1].name or step.name, versions[1].level,
			versions[1].enName or step.enName)
	end
	local ids, names = {}, {}
	for _, version in ipairs(versions) do
		ids[#ids + 1] = version.questID
		names[#names + 1] = version.name or step.name or "?"
	end
	local key = "oneOf:" .. table.concat(ids, ":")
	if not stepQuests[key] then
		-- The versions' pages, for its lock (locked while every version is; nil if one has none), and
		-- what they share (false if nothing: no single start, end or rewards).
		local level, pages = nil, {}
		for _, version in ipairs(versions) do
			local known = KnownQuest(instance, version.questID)
			level = level or (known and known.level) or version.level
			if pages and known then pages[#pages + 1] = known else pages = nil end
		end
		stepQuests[key] = { questID = ids[1], name = SharedName(versions) or OrList(names), oneOf = versions, level = level,
			pages = pages, shared = SharedPage(instance, versions) or false,
			enName = SharedEnglishName(versions) or step.enName or step.name }
	end
	return stepQuests[key]
end

-- The quest ids a row stands for: its own, and a one-of row's versions'.
local function RowIDs(quest)
	local ids = { [quest.questID] = true }
	for _, version in ipairs(quest.oneOf or {}) do ids[version.questID] = true end
	return ids
end

-- Every quest id a row of the list holds, in order: its own, a one-of row's versions', and a row of
-- same-named quests' parts' (QuestsPanel:Fold).
local function HeldIDs(quest, out)
	out = out or {}
	out[#out + 1] = quest.questID
	for _, inner in ipairs(quest.oneOf or {}) do out[#out + 1] = inner.questID end
	for _, part in ipairs(quest.parts or {}) do HeldIDs(part, out) end
	return out
end

-- The quest ids a chain's step stands for: its own, and a one-of step's versions'.
local function StepIDs(step)
	local ids = { step.questID }
	for _, version in ipairs(step.oneOf or {}) do ids[#ids + 1] = version.questID end
	return ids
end

-- A chain's step as a row of its own: a one-of step's row, else the quest the journal keeps for it.
local function StepQuest(instance, step)
	if step.oneOf then return OneOfRow(instance, step) end
	return StepRow(instance, step.questID, step.name, nil, step.enName)
end

-- A chain's step as the tab lists it: the piece that is it (the row the tab lists it as, rowOf; the part of a row of
-- same-named quests that is it; a one-of step's row; else its step's row), and the tab's row holding that piece, if one
-- does. (A one-of step is the tab's row only where that row is its one-of row itself or has it as a part.)
local function StepPiece(instance, step, rowOf)
	if step.oneOf then
		local piece, holder = OneOfRow(instance, step), nil
		local row = rowOf and rowOf[piece.questID]
		if row == piece then holder = row end
		for _, part in ipairs(row and row.parts or {}) do
			if part == piece then holder = row end
		end
		return piece, holder
	end
	local holder = rowOf and rowOf[step.questID]
	local piece = holder
	for _, part in ipairs(holder and holder.parts or {}) do
		for _, questID in ipairs(HeldIDs(part)) do
			if questID == step.questID then piece = part end
		end
	end
	return piece or StepRow(instance, step.questID, step.name, nil, step.enName), holder
end

-- A row of same-named quests (QuestsPanel:Fold), one object for the same parts, so it stays chosen.
local foldRows = {}
local function FoldRow(parts, named)
	local keys = {}
	for index, part in ipairs(parts) do keys[index] = tostring(part) end
	local key = table.concat(keys, "|")
	if not foldRows[key] then
		foldRows[key] = { questID = parts[1].questID, name = string.format(L.QUEST_PARTS, named.name or "", #parts),
			parts = parts }
	end
	return foldRows[key]
end

--[[
	A chain's rows from its steps, in order, one row each (its piece): the row the tab lists it as (rowOf: a
	quest of one of its dropdowns), the part of a row of same-named quests that is it (QuestsPanel:Fold), else
	its step's. A one-of step is the tab's row only where that row is its one-of row itself or has it as a
	part (A Taste of Flame's, for a side that can take one version); a one-of the player may have done in
	another dungeon stays a one-of row, done once any version is (the Valthalak amulet's pieces, four
	dungeons' versions). Each piece is listed once, where it first comes; the row whose chain it is (skip)
	is not listed under itself.

	Steps of one name are never two rows without their numbers (the owner's reports of 2026-11-04 and
	2026-11-06): each is a row of its own, "<name> (Part n)", its page saying "Part n of m". Where they are
	all parts of one row of the tab, n and m are that row's; otherwise they go by the chain's own order, m
	how many it has (Final Passage's Test of Lore steps, the Library's five and Parqual's question after
	them). A step alone of its name that is a part of such a row has that row's number too.

	given[index]: a step that is a piece already (a row of same-named quests' part: ChainRows), the row
	holding it. shown: the rows of the chain's own dropdown, by row; road: the rows of the roads in Before you go
	the chain's row comes after, by row (see below). Returns the rows, and each one's { n, m } or nil.
]]
local function StepRows(instance, prerequisites, rowOf, skip, given, shown, road)
	local rows, holders, listed = {}, {}, {}
	for index, step in ipairs(prerequisites) do
		local piece, holder
		if given and given[index] then
			piece, holder = step, given[index]
		else
			piece, holder = StepPiece(instance, step, rowOf)
		end
		if piece ~= skip and not listed[piece] then
			listed[piece] = true
			rows[#rows + 1], holders[#rows + 1] = piece, holder
		end
	end
	-- The numbers, name by name.
	local named, numbers = {}, {}
	for position, piece in ipairs(rows) do
		local name = EnglishName(piece) or ""
		named[name] = named[name] or {}
		named[name][#named[name] + 1] = position
	end
	for _, same in pairs(named) do
		local holder = holders[same[1]]
		local at = {}
		for index, part in ipairs(holder and holder.parts or {}) do at[part] = index end
		for _, position in ipairs(same) do
			if holders[position] ~= holder or not at[rows[position]] then holder = nil end
		end
		for count, position in ipairs(same) do
			if holder then
				numbers[position] = { at[rows[position]], #holder.parts, holder }
			elseif #same > 1 then
				numbers[position] = { count, #same }
			end
		end
	end
	-- The owner's rule (2026-11-07): a quest's + never repeats a quest that already has its own row in the
	-- same dropdown (Grime-Encrusted Ring under Return of the Ring and Gnome Improvement, Gnomeregan). Such a
	-- step, or a part of such a row of same-named quests, is left out; the lock line still names it. A row's
	-- own parts stay, and so do steps that are only inside a chain. A one-of step one of whose versions is
	-- such a row is left out too (The Left Piece of Lord Valthalak's Amulet under The Right Piece, where the
	-- dungeon lists its own version); its lock line says any version will do. (Left out after the numbering,
	-- so a step left keeps the number it had.)
	-- The owner's direction of 2026-11-19 takes it to Before you go ("if the road is the same for many, we keep that
	-- road in the breadcrumbs / attunement line, then we branch off where the quests start to differ"): a + never
	-- repeats the road it comes after either (road: a dropdown of Before you go whose last quest the row needs,
	-- QuestsPanel:Rows), whose own line stands for it there (RoadLine); only the row's own steps follow. A step of a
	-- dropdown the row doesn't come after stays (Somber News's The Man in the Iron Chains, the first of the toy's
	-- quests: a road's line would say it needs them all), and so do steps another row of the tab lists (Class Quests'
	-- Anthion's Parting Words keeps the Dungeon Quests rows of its chain).
	local function Repeats(position)
		local function Here(row) return row ~= skip and (shown[row] or (road ~= nil and road[row] == true)) end
		local holder = holders[position]
		if holder then return Here(holder) end
		for _, questID in ipairs(HeldIDs(rows[position])) do
			local row = rowOf and rowOf[questID]
			if row and Here(row) then return true end
		end
		return false
	end
	if shown then
		local kept, keptNumbers = {}, {}
		for position, piece in ipairs(rows) do
			if not Repeats(position) then
				kept[#kept + 1], keptNumbers[#kept + 1] = piece, numbers[position]
			end
		end
		rows, numbers = kept, keptNumbers
	end
	return rows, numbers
end

--[[
	A row's chain: the steps before it, as rows, and their numbers (StepRows; rowOf, as it takes it: the tab's
	own rows by the quest ids they hold; without it, every step as a step; shown: the rows of its dropdown,
	and road: the rows of the roads in Before you go it comes after, which its chain doesn't repeat either); then,
	where its chain branches at it, the quests after it on its branch (nextSteps). A row of same-named quests
	(QuestsPanel:Fold) opens on the whole chain as it runs (the owner's call of 2026-11-06): part by part, the
	steps the part needs that are not listed yet, then the part (partsOnly: its parts alone, for a key's
	dropdown, which lists the key's other quests itself).
]]
local function ChainRows(instance, quest, rowOf, partsOnly, shown, road)
	-- A quest whose steps are another quest's chain lists none (noChain: Red Silk Bandanas, after The Defias
	-- Brotherhood's part 6); its lock line still names the step.
	if quest.noChain then return {}, {} end
	local prerequisites, given = {}, {}
	if not quest.parts then
		-- Some chains list the quest itself among its steps; it already has its own row.
		local skip = RowIDs(quest)
		for _, step in ipairs(quest.prerequisites or {}) do
			if not skip[step.questID] then prerequisites[#prerequisites + 1] = step end
		end
		-- (the quests after it on its branch, where its chain branches: BranchesOn)
		for _, after in ipairs(nextSteps[quest] or {}) do prerequisites[#prerequisites + 1] = after end
	else
		local seen = {}
		for _, part in ipairs(quest.parts) do
			for questID in pairs(RowIDs(part)) do seen[questID] = true end
		end
		for _, part in ipairs(quest.parts) do
			for _, step in ipairs(not partsOnly and part.prerequisites or {}) do
				local new = true
				for _, questID in ipairs(StepIDs(step)) do
					if seen[questID] then new = false end
				end
				if new then
					prerequisites[#prerequisites + 1] = step
					for _, questID in ipairs(StepIDs(step)) do seen[questID] = true end
				end
			end
			prerequisites[#prerequisites + 1] = part
			given[#prerequisites] = quest
		end
	end
	return StepRows(instance, prerequisites, rowOf, quest, given, shown, road)
end

--[[
	Quests of one chain that share a name, as one row (the owner's reports of 2026-11-04: The Test of
	Righteousness twice, 1654 and Jordan's forging after it, 1806; then the same name still twice under
	the row, 1653 in its chain, and Hidden Enemies three times). In a dropdown's list, a quest whose
	prerequisites name another of the list by the same name (that quest itself, or as one version of a
	step any one of several will do, as the second Sparklematic row's pages name the first's versions)
	folds into one row with it, and so on down the chain. With the dungeon given (the Dungeon and Class
	Quests dropdowns, whose rows open their chains), the steps of a quest's chain with its name fold in
	too, as parts: Hidden Enemies' five quests are one row, two of them the dungeon's own. A step of that
	name in another quest's chain only (Parqual's question, 6628, after the Library's Test of Lore, in
	Final Passage's) stays out of the row, which is done once the dungeon's quest is; that chain lists
	the row's parts and the step one by one, numbered (StepRows).
	A step a quest of another dropdown is (outside: the tab's other rows' quest ids) stays that quest's.
	The parts are in the chain's order: each after the parts it needs, else as the chains run (each
	quest after the steps before it, the list's quests in their order). The names are compared in
	English, so every language folds the same quests. Quests of different names never fold: a chain's
	other steps stay rows of their own. Without the dungeon (a key's quests, BeforeYouGo:Keys: one chain,
	in its order), quests of one name next to each other fold too, steps the journal knows by their name
	alone naming none before them.

	The row is { questID (its first part's), name = "<name> (<n> parts)" (the first of the list's quests
	in it named), parts }: its status, level, lock and page are the part the player is on (the first not
	done; the last once all are), a part that is only a step showing its step's page; its "+" opens its
	parts, one row each, among the steps they need (ChainRows). One object for the same parts, so it stays
	chosen.
]]

-- Whether quest needs the one whose ids are given: its prerequisites name it, or a one-of row's versions'
-- pages' do, directly or as one version of a step.
local NONE_LIST = {}
local function NeedsIn(list, ids)
	for _, step in ipairs(list or NONE_LIST) do
		if ids[step.questID] then return true end
		for _, version in ipairs(step.oneOf or NONE_LIST) do
			if ids[version.questID] then return true end
		end
	end
	return false
end
local function Needs(quest, ids)
	if NeedsIn(quest.prerequisites, ids) then return true end
	for _, page in ipairs(quest.pages or NONE_LIST) do
		if NeedsIn(page.prerequisites, ids) then return true end
	end
	return false
end

-- A dropdown's quests, those of one chain sharing a name as one row, where the first of them was; with the
-- dungeon given, the steps of each one's chain with its name folded in (outside: quest ids another dropdown holds).
function QuestsPanel:Fold(quests, instance, outside)
	-- Each quest, and each step that may fold in, once: { quest, ids, own }.
	local members, byID, own = {}, {}, {}
	local function Member(quest, isOwn)
		local member = { quest = quest, ids = RowIDs(quest), own = isOwn }
		members[#members + 1] = member
		for questID in pairs(member.ids) do byID[questID] = byID[questID] or member end
		return member
	end
	for index, quest in ipairs(quests) do
		own[index] = Member(quest, true)
	end
	-- The order the chains run, for parts that need none of the others.
	local at, count = {}, 0
	local function Reach(member)
		if member and not at[member] then
			count = count + 1
			at[member] = count
		end
	end
	for index, quest in ipairs(quests) do
		if instance and not quest.parts then
			for _, step in ipairs(quest.prerequisites or {}) do
				local member, elsewhere = nil, false
				for _, questID in ipairs(StepIDs(step)) do
					member = member or byID[questID]
					elsewhere = elsewhere or (outside ~= nil and outside[questID] == true)
				end
				if not member and not elsewhere and EnglishName(step) == EnglishName(quest) then
					member = Member(StepQuest(instance, step), false)
				end
				Reach(member)
			end
		end
		Reach(own[index])
	end
	-- Linked: the same name, and one needs the other.
	local root, needs, byName = {}, {}, {}
	for _, member in ipairs(members) do
		root[member] = member
		if not member.quest.parts then
			local name = EnglishName(member.quest) or ""
			byName[name] = byName[name] or {}
			byName[name][#byName[name] + 1] = member
		end
	end
	local function Root(member)
		while root[member] ~= member do member = root[member] end
		return member
	end
	local linked = false
	local function Link(later, earlier)
		needs[later] = needs[later] or {}
		needs[later][earlier] = true
		root[Root(later)] = Root(earlier)
		linked = true
	end
	for _, same in pairs(byName) do
		for _, later in ipairs(same) do
			for _, earlier in ipairs(same) do
				if earlier ~= later and Needs(later.quest, earlier.ids) then Link(later, earlier) end
			end
		end
	end
	if not instance then
		for index = 2, #quests do
			local earlier, later = own[index - 1], own[index]
			if not (earlier.quest.parts or later.quest.parts) and EnglishName(earlier.quest) == EnglishName(later.quest) then
				Link(later, earlier)
			end
		end
	end
	if not linked then return quests end
	local groups = {}
	for _, member in ipairs(members) do
		local top = Root(member)
		groups[top] = groups[top] or {}
		groups[top][#groups[top] + 1] = member
	end
	local list, placed = {}, {}
	for index, quest in ipairs(quests) do
		local group = groups[Root(own[index])]
		if #group == 1 then
			list[#list + 1] = quest
		elseif not placed[group] then
			placed[group] = true
			table.sort(group, function(a, b) return at[a] < at[b] end)
			-- In the chain's order: each time, the first (as the chains run) whose parts before it are in.
			local parts, taken = {}, {}
			while #parts < #group do
				local pick
				for _, member in ipairs(group) do
					if not pick and not taken[member] then
						local ready = true
						for before in pairs(needs[member] or {}) do
							if not taken[before] then ready = false end
						end
						if ready then pick = member end
					end
				end
				-- (a loop in the data, should one ever be: the first left)
				if not pick then
					for _, member in ipairs(group) do
						if not taken[member] then pick = member break end
					end
				end
				taken[pick] = true
				parts[#parts + 1] = pick.quest
			end
			list[#list + 1] = FoldRow(parts, quest)
		end
	end
	return list
end

--[[
	A chain shown whole (quest.wholeChain, on its last quest: the owner's call of 2026-11-12, "These are a quest chain -
	please connect them", Gnogaine and The Only Cure is More Green Glow): the quests before it that its dropdown would
	list as rows of their own are rows no more, but steps under its +, as a chain's steps with no row of their own are
	(StepRows, whose rule of 2026-11-07 leaves out a step that has a row of its own in the same dropdown, so that no quest
	is listed twice). Each is still listed once, in its chain. A dropdown's list, those quests left out.
]]
local function UnderWholeChains(list)
	local under = {}
	for _, quest in ipairs(list) do
		if quest.wholeChain and not quest.parts then
			for _, step in ipairs(quest.prerequisites or {}) do
				for _, questID in ipairs(StepIDs(step)) do under[questID] = true end
			end
		end
	end
	if next(under) == nil then return list end
	local kept = {}
	for _, quest in ipairs(list) do
		if quest.wholeChain or quest.parts or not under[quest.questID] then kept[#kept + 1] = quest end
	end
	return kept
end

--[[
	A chain that branches (the owner's report of 2026-11-17: in the Drowned City, An Acquaintance in Southshore gives
	both Take Two With Water and Magics of the Drowned City, and each leads on to its own last quest, Findings for the
	Explorer's League and The Web of Magic, which were rows of their own beside them). Where two or more quests of a
	dropdown need one quest of it and need none of the others that do, the chain branches there, and the list's order
	alone can no longer show which quest goes on from which. Only whether a quest needs one of the others counts: a
	quest after a branch often lists its whole chain, so it needs the quest before the branch too. So each quest the
	chain branches into keeps its row, and the quests that follow it on its branch (needing it, or a quest already
	after it) are its chain's next steps: under its +, after the steps before it, each a step row with its page and
	status, rows of their own no more (nextSteps, for ChainRows). A quest that comes after two branches (where they
	meet again) stays a row, and so does a quest the chain branches into again. A chain that runs straight is as
	before: its quests rows in its order, a + never repeating one (the owner's rule of 2026-11-07, StepRows), unless
	the data marks the quest it is shown on (quest.chainHead, the owner's call of 2026-11-17 on Krol'dok's Twilight
	Mementos, "make the main dungeon quest the visible one"): that quest keeps its row as a branch's quest does, and
	the quests after it (its follow-ups outside) are its chain's next steps the same way. wholeChain is the other way
	round: the last quest the row, the ones before it its steps. A dropdown's list, those quests left out.
]]
local function BranchesOn(list)
	local rows = {}
	for _, quest in ipairs(list) do
		nextSteps[quest] = nil
		if not quest.parts then rows[#rows + 1] = quest end
	end
	local idsOf = {}
	local function NeedsRow(quest, row)
		if quest == row then return false end
		local ids = idsOf[row]
		if not ids then ids = RowIDs(row) idsOf[row] = ids end
		return Needs(quest, ids)
	end
	-- The quests the chain branches into, each with the others of its branching.
	local heads, branching = {}, {}
	for _, root in ipairs(rows) do
		local needing = {}
		for _, quest in ipairs(rows) do
			if NeedsRow(quest, root) then needing[#needing + 1] = quest end
		end
		local apart = {}
		for _, quest in ipairs(needing) do
			local alone = true
			for _, other in ipairs(needing) do
				if NeedsRow(quest, other) then alone = false end
			end
			if alone then apart[#apart + 1] = quest end
		end
		if #apart > 1 then
			for _, head in ipairs(apart) do
				if not branching[head] then
					heads[#heads + 1] = head
					branching[head] = true
				end
			end
		end
	end
	-- (and a quest the data shows its straight chain on: chainHead)
	for _, quest in ipairs(rows) do
		if quest.chainHead and not branching[quest] then
			heads[#heads + 1] = quest
			branching[quest] = true
		end
	end
	if #heads == 0 then return list end
	-- What follows each, in the list's order but each after the ones it needs.
	local after, times = {}, {}
	for _, head in ipairs(heads) do
		local reached, chain, grew = { [head] = true }, {}, true
		while grew do
			grew = false
			for _, quest in ipairs(rows) do
				if not reached[quest] and not branching[quest] then
					local follows = false
					for member in pairs(reached) do
						if NeedsRow(quest, member) then follows = true end
					end
					if follows then
						reached[quest], grew = true, true
						chain[#chain + 1] = quest
						times[quest] = (times[quest] or 0) + 1
					end
				end
			end
		end
		after[head] = chain
	end
	local under = {}
	for _, head in ipairs(heads) do
		local left, chain = {}, {}
		for _, quest in ipairs(after[head]) do
			-- (after two branches: where they meet again, a row)
			if times[quest] == 1 then left[#left + 1], under[quest] = quest, true end
		end
		while #left > 0 do
			local pick = 1
			for index, quest in ipairs(left) do
				local ready = true
				for _, other in ipairs(left) do
					if other ~= quest and NeedsRow(quest, other) then ready = false end
				end
				if ready then pick = index break end
			end
			-- (a loop in the data, should one ever be: the first left)
			chain[#chain + 1] = table.remove(left, pick)
		end
		if #chain > 0 then nextSteps[head] = chain end
	end
	local kept = {}
	for _, quest in ipairs(list) do
		if not under[quest] then kept[#kept + 1] = quest end
	end
	return kept
end

--[[
	A dungeon's dropdowns on the Quests tab, for this character: { key, title, quests, chains, keyEntry, shown
	(its rows, by row: what its chains don't repeat, StepRows), and for Dungeon, Raid and Class Quests roads and
	roadRows (below) }, in
	order (its keys, as Before you go has them: BeforeYouGo:Keys; then Dungeon Quests, then Class Quests, whose
	rows open their chains), and rowOf: each quest id the dropdowns hold, the row that holds it (a key's first,
	then Dungeon Quests', then Class Quests'). Search lists a dungeon's quests as these rows do.
	The roads (the owner's direction of 2026-11-19, StepRows): by row of Dungeon, Raid and Class Quests, the keys of
	Before you go (BeforeYouGo:Keys's) whose dropdown's last quest the row needs (Needs: its prerequisites, a one-of row's
	pages', a row of same-named quests' parts'), in Before you go's order, each a line under its + (RoadLine); and
	roadRows, by row, those dropdowns' rows, which its chain leaves out. Where a road ends is its dropdown's list, the data's
	(a road ends where the quests after it part ways: Krol'dok's Horde road at Bring Me His Head, as the smoke test keeps
	every road).
]]
function QuestsPanel:Rows(instance)
	local groups, inKey, rowOf = {}, {}, {}
	local function Hold(row)
		for _, questID in ipairs(HeldIDs(row)) do rowOf[questID] = rowOf[questID] or row end
	end
	-- (a key's quests of one chain sharing a name are one row there already: BeforeYouGo:Keys)
	local keys = ns.BeforeYouGo:Keys(instance)
	for _, key in ipairs(keys) do
		for _, quest in ipairs(key.quests) do
			inKey[quest] = true
			for _, part in ipairs(quest.parts or {}) do inKey[part] = true end
			Hold(quest)
		end
		groups[#groups + 1] = { key = key.key, title = key.title, quests = key.quests, keyEntry = key }
	end
	-- The dropdowns: the dungeon's keys (their quests, steps of no other), then Dungeon Quests, then Class
	-- Quests (the owner's call of 2026-11-03): a quest for one class or a few (classOnly) is under that, and
	-- a character of another class sees neither it nor the header.
	local others, classQuests = {}, {}
	for _, quest in ipairs(QuestsFor(instance)) do
		if inKey[quest] then
			-- in its key's dropdown
		elseif quest.classOnly then
			classQuests[#classQuests + 1] = quest
		else
			others[#others + 1] = quest
		end
	end
	-- Quests of one chain sharing a name, as one row in each, their chains' steps of that name with them
	-- (QuestsPanel:Fold); a step another dropdown lists stays its.
	local function Outside(list)
		local ids = {}
		for questID in pairs(rowOf) do ids[questID] = true end
		for _, quest in ipairs(list) do
			for questID in pairs(RowIDs(quest)) do ids[questID] = true end
		end
		return ids
	end
	local dungeonOutside, classOutside = Outside(classQuests), Outside(others)
	others, classQuests = self:Fold(others, instance, dungeonOutside), self:Fold(classQuests, instance, classOutside)
	-- (a chain shown whole: the quests before its last under its +, not rows of their own)
	others, classQuests = UnderWholeChains(others), UnderWholeChains(classQuests)
	-- (a chain that branches: the quests after each branch under its first quest's +)
	others, classQuests = BranchesOn(others), BranchesOn(classQuests)
	for _, quest in ipairs(others) do Hold(quest) end
	for _, quest in ipairs(classQuests) do Hold(quest) end
	if #others > 0 then
		-- A raid's own are Raid Quests.
		local title = instance.kind == "raid" and L.QUESTS_RAID or L.QUESTS_DUNGEON
		groups[#groups + 1] = { key = "dungeon", title = title, quests = others, chains = true }
	end
	if #classQuests > 0 then
		groups[#groups + 1] = { key = "class", title = L.QUESTS_CLASS, quests = classQuests, chains = true }
	end
	for _, group in ipairs(groups) do
		group.shown = {}
		for _, quest in ipairs(group.quests) do group.shown[quest] = true end
		-- (the roads each row comes after)
		if group.chains then
			group.roads, group.roadRows = {}, {}
			for _, row in ipairs(group.quests) do
				for _, key in ipairs(keys) do
					local quests = key.entry.quests
					local last = { [quests[#quests]] = true }
					local after = Needs(row, last)
					for _, part in ipairs(row.parts or NONE_LIST) do after = after or Needs(part, last) end
					if after then
						local roads, roadRows = group.roads[row] or {}, group.roadRows[row] or {}
						roads[#roads + 1] = key
						for _, held in ipairs(key.quests) do roadRows[held] = true end
						group.roads[row], group.roadRows[row] = roads, roadRows
					end
				end
			end
		end
	end
	return groups, rowOf
end

-- A row's chain as the tab lists it (for the tests): its steps, a step the tab lists as a row being that row
-- (rowOf, QuestsPanel:Rows's, if the caller has it), and their numbers (partsOnly: a key's row's; shown: its
-- dropdown's rows, and road: the rows of the roads it comes after, which it doesn't repeat; without rowOf, all
-- three as the tab has them).
function QuestsPanel:Chain(instance, quest, rowOf, partsOnly, shown, road)
	if not rowOf then
		local groups
		groups, rowOf = self:Rows(instance)
		for _, group in ipairs(groups) do
			if group.shown[quest] then
				shown = shown or group.shown
				road = road or (group.roadRows and group.roadRows[quest])
			end
		end
	end
	return ChainRows(instance, quest, rowOf, partsOnly, shown, road)
end

--[[
	The numbers the tab's rows give the quests they show (the owner's call of 2026-11-07: a lock line names a
	step by the number its row has), dungeon by dungeon: each row, each row of same-named quests' parts
	(QuestsPanel:Fold) and each chain's steps (StepRows), with the number a part or a numbered step has there.
	For each quest id the tab shows somewhere, the numbers of each dungeon that shows it. Built once for the
	character's side and class (what the rows hold) and the data as it is (ns.DataVersion).
]]
local tabParts, tabPartsFor
local function TabParts()
	local _, faction = pcall(UnitFactionGroup, "player")
	local _, _, classFile = pcall(UnitClass, "player")
	local key = tostring(faction) .. " " .. tostring(classFile) .. " " .. tostring(ns.DataVersion())
	if tabPartsFor == key then return tabParts end
	-- (set first: a lock line asked while the rows are built finds no number, not a loop)
	tabParts, tabPartsFor = {}, key
	local shownIn = {}
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances(kind)) do
			local numbers, shown = {}, {}
			-- (a row shows every quest it holds; a number is the piece's own, a one-of step's for each version)
			local function Show(piece, number)
				for _, questID in ipairs(HeldIDs(piece)) do shown[questID] = true end
				for _, questID in ipairs(number and StepIDs(piece) or {}) do
					numbers[questID] = numbers[questID] or number
				end
			end
			local groups, rowOf = QuestsPanel:Rows(instance)
			for _, group in ipairs(groups) do
				for _, row in ipairs(group.quests) do
					Show(row)
					for index, part in ipairs(row.parts or {}) do Show(part, index) end
					if group.chains or row.parts then
						local rows, given = ChainRows(instance, row, rowOf, not group.chains, group.shown,
							group.roadRows and group.roadRows[row])
						for at, piece in ipairs(rows) do Show(piece, given[at] and given[at][1]) end
					end
				end
			end
			for questID in pairs(shown) do
				shownIn[questID] = shownIn[questID] or {}
				table.insert(shownIn[questID], numbers)
			end
		end
	end
	tabParts = shownIn
	return tabParts
end

-- The part a step of another name is (`entry`, one of quest's prerequisites) where the tab numbers it, in a
-- dungeon that shows quest: Explosive Consultation (92748) is Part 1 of Destruction in Deadmines' chain, so A
-- Dynamite Plan, whose own steps hold it alone of its name, needs "Explosive Consultation (Part 1)". Nil where
-- the tab gives it no number.
TabPart = function(entry, quest)
	local dungeons = quest.questID and TabParts()[quest.questID]
	for _, numbers in ipairs(dungeons or {}) do
		for _, questID in ipairs(StepIDs(entry)) do
			if numbers[questID] then return numbers[questID] end
		end
	end
	return nil
end

-- A quest's name with its part where the tab numbers it ("Unending Torment (Part 2)", as its row of same-named quests
-- does), else its name: for a list that may name two parts of one name at once, a boss's quests (UI/QuestMap.lua's
-- AddBadgeLines; the review of 3cc3416, the Baron's two Unending Torment).
function QuestsPanel:PartName(quest)
	for _, numbers in ipairs(quest.questID and TabParts()[quest.questID] or {}) do
		local part = numbers[quest.questID]
		if part then return string.format(L.QUEST_PART_NAME, quest.name, part) end
	end
	return quest.name
end

-- A quest as the Quests tab lists it: the dungeon's own, else the step of a chain that holds it, every step
-- as a step (ChainRows without the tab's rows). Nil when the dungeon lists it nowhere. (A quest the tab
-- folds into a row of same-named quests, or lists inside another row, is found as itself or its step; the
-- tab chooses it as its part's row under the row of same-named quests that holds it, else the row that
-- holds it: QuestsPanel:Refresh.)
function QuestsPanel:Find(instance, questID)
	local quest = QuestByID(instance, questID)
	if quest then return quest end
	for _, parent in ipairs(instance.quests or {}) do
		for _, step in ipairs(ChainRows(instance, parent)) do
			for _, held in ipairs(HeldIDs(step)) do
				if held == questID then return step end
			end
		end
	end
	return nil
end

--[[
	Adventure Mode: whether a step of a quest's chain is one the character knows that belongs to this
	dungeon: a row of its tab (rowOf), or a step of this dungeon's chains alone. A step many dungeons'
	chains share (A Shifty Merchant, of the dungeon sets' chain) does not show their quests, so a known
	step tells nothing of where its chain goes.
]]
local chainsHolding
local function ChainStepHere(step, rowOf)
	if not chainsHolding then
		chainsHolding = {}
		for _, kind in ipairs({ "dungeon", "raid" }) do
			for _, instance in ipairs(ns.GetInstances(kind)) do
				local seen = {}
				for _, quest in ipairs(instance.quests or {}) do
					seen[quest.questID or 0] = true
					for _, prerequisite in ipairs(quest.prerequisites or {}) do
						for _, questID in pairs(StepIDs(prerequisite)) do seen[questID] = true end
					end
				end
				for questID in pairs(seen) do chainsHolding[questID] = (chainsHolding[questID] or 0) + 1 end
			end
		end
	end
	for _, questID in ipairs(HeldIDs(step)) do
		if ns.Discovery:Knows("quest", questID) and (rowOf[questID] or (chainsHolding[questID] or 0) <= 1) then
			return true
		end
	end
	return false
end
-- (the chat line's rule for a step: UI/News.lua tells one only where the tab shows it)
function QuestsPanel:ChainStepHere(step, rowOf) return ChainStepHere(step, rowOf) end

--[[
	The line a road gets under the + of a quest that comes after it (QuestsPanel:Rows's roads; SetRoadRow): the road's
	title as its header shows it, and what the quest itself needs of it (the review of 2026-11-19): its steps on the
	road, as its lock line reads them (LockPage). Done (the check, in green) once all of those are, which may be after
	the road's header has its check (the Dalaran Sewer Key's, once Heart of Disruption is only taken, while Shrewd
	Negotiations waits for it to be handed in); else the mark of the first of them still to do, the step its lock line
	names, and how many of the road's quests are done, as the header counts them. A click chooses that step in the
	road's dropdown, never a quest the lock skips (Food for the Taking); once the quest waits on none of it, the road's
	last quest, where its way branches off (not the dropdown's first still to do, which may be one the lock skips);
	else, the step not shown there (in Adventure Mode, one not offered yet, which keeps the header's mark, a key's while
	it would be a check), the dropdown's first quest still to do; none where the dropdown shows none. group: the road's
	dropdown (its section, quests and members).
]]
local function RoadLine(instance, key, quest, rowOf, group)
	local onRoad, lastID = {}, key.entry.quests[#key.entry.quests]
	for _, questID in ipairs(key.entry.quests) do onRoad[questID] = true end
	local needed, waiting, ending = false, nil, nil
	for _, prerequisite in ipairs(LockPage(quest).prerequisites or NONE_LIST) do
		for _, questID in ipairs(StepIDs(prerequisite)) do
			if questID == lastID then ending = prerequisite end
		end
		for _, questID in ipairs(StepIDs(prerequisite)) do
			if onRoad[questID] then
				needed = true
				if not waiting and not PrerequisiteDone(prerequisite) then waiting = prerequisite end
				break
			end
		end
	end
	local done = waiting == nil and (needed or key.have == true)
	local section = group.section
	local line = { key = key.key, title = section.title, done = done,
		note = done and ns.BeforeYouGo.HAVE_MARK or string.format("%d/%d", key.done, key.total) }
	local step = waiting and StepPiece(instance, waiting, rowOf)
	if done then
		line.status = STATUS_DONE
	elseif step and Known(step) then
		line.status = QuestsPanel:Status(step)
	else
		line.status = section.status ~= STATUS_DONE and section.status or nil
		if not line.status then line.icon = ns.BeforeYouGo.KEY_ICON end
	end
	local chosen = step or (done and ending and StepPiece(instance, ending, rowOf))
	if chosen and section.members[chosen] and Known(chosen) then
		line.quest = chosen
	else
		line.quest = (FirstToDo(group.quests))
	end
	return line
end

function QuestsPanel:Refresh(page)
	local instance = page.instance
	local list, child = page.QuestList, page.QuestList.Child
	local reveal, revealKey = page.reveal, page.revealKey
	page.reveal, page.revealKey = nil, nil
	-- What is open and chosen holds while the dungeon stays shown, as on the Abilities tab. A
	-- dungeon shown anew starts afresh, at the list's top, nothing open or chosen yet (a step two
	-- dungeons share would stay chosen, folded out of sight). A quest opened there from elsewhere is
	-- chosen after this (QuestsPanel:Open shows the tab first).
	if page.questsShown ~= instance then
		page.questsShown, page.expandedChains, page.selectedQuest, page.selectedAsStep = instance, {}, nil, nil
		page.selectedUnder, page.shownPart = nil, nil
		list:SetVerticalScroll(0)
	end
	local open = page.expandedChains

	-- The dropdowns (QuestsPanel:Rows), each quest's chain with it (a step the tab lists as a row of its own
	-- being that row).
	local groups, rowOf = self:Rows(instance)
	local adventure, anyQuests = ns.Style:Adventure(), #groups > 0
	-- Their numbers too: a key's rows have none, but for a row of same-named quests, its parts. A chain
	-- doesn't repeat a quest its dropdown shows as a row (shown, StepRows), nor the road it comes after (roadRows).
	local function Chains(group, shown)
		group.chainOf, group.numbersOf = {}, {}
		for _, quest in ipairs(group.quests) do
			if group.chains or quest.parts then
				group.chainOf[quest], group.numbersOf[quest] = ChainRows(instance, quest, rowOf, not group.chains, shown,
					group.roadRows and group.roadRows[quest])
			else
				group.chainOf[quest], group.numbersOf[quest] = {}, {}
			end
		end
	end
	for _, group in ipairs(groups) do Chains(group, not adventure and group.shown or nil) end
	-- Adventure Mode: each lists its quests known, and those with a step of their chain known that is this
	-- dungeon's (ChainStepHere: its whole chain, as the data has it, a step that is a row too); Dungeon and
	-- Class Quests with none are left out, a key's stays. Then the chains as shown: none repeats a row its
	-- dropdown shows, and a step that is a row the mode leaves out stays in them ("???" until offered).
	if adventure then
		local kept = {}
		for _, group in ipairs(groups) do
			local quests, shownRows = {}, {}
			for _, quest in ipairs(group.quests) do
				local shown = Known(quest)
				for _, step in ipairs(group.chainOf[quest]) do shown = shown or ChainStepHere(step, rowOf) end
				if shown then quests[#quests + 1], shownRows[quest] = quest, true end
			end
			group.quests, group.shown = quests, shownRows
			Chains(group, shownRows)
			if #quests > 0 or group.keyEntry then kept[#kept + 1] = group end
		end
		groups = kept
	end
	-- Each starts as it should once the dungeon is shown, so a quest taken while the tab is open doesn't open or
	-- fold one under the player: Before you go's all folded, its keys and chains too (had or not, done or not), so
	-- the dungeon's own quests come first (the owner's call of 2026-11-14); Dungeon Quests and Class Quests open.
	-- (Where the dungeon lists no other quest, the key whose quest is chosen is unfolded below, as the tab starts or as
	-- that quest is first found.)
	local keys, groupOf = {}, {}
	for _, group in ipairs(groups) do
		local key = group.keyEntry
		if key then
			if open[key.key] == nil then open[key.key] = false end
			-- (its title naming nothing not found yet, in Adventure Mode, as on Before you go; nor its mark a
			-- quest the character doesn't know: a key's, while it knows none of them)
			local title = ns.Discovery:MaskAll(instance, key.title, ns.Discovery:Untold(instance))
			group.section = GroupSection(key.key, title, key.quests)
			group.section.status, group.section.note = key.status, key.note
			if not key.status then group.section.icon = ns.BeforeYouGo.KEY_ICON end
			keys[#keys + 1], groupOf[key] = key, group
		else
			if open[group.key] == nil then open[group.key] = true end
			group.section = GroupSection(group.key, group.title, group.quests)
		end
	end
	-- Before you go's notes, in its order: a key's dropdown takes the note's text (and how far along the player
	-- is); a note no quest of its own fills starts folded too.
	local notes = ns.BeforeYouGo:Notes(instance, keys)
	for _, note in ipairs(notes) do
		if note.key then
			groupOf[note.key].section.description = note.section.description
		else
			if open[note.section.key] == nil then open[note.section.key] = false end
			note.section.expanded = open[note.section.key] == true
		end
	end

	-- What each holds, chains included.
	local listed, own = {}, {}
	for _, group in ipairs(groups) do
		for _, quest in ipairs(group.quests) do
			own[quest], listed[quest] = true, true
			for _, step in ipairs(group.chainOf[quest]) do listed[step] = true end
		end
	end
	-- A quest the tab doesn't list as itself, opened or chosen (a part of a row of same-named quests, a step
	-- found as a step: QuestsPanel:Find), is the row that holds it: a dropdown's own, else a chain's.
	local holder = {}
	for questID, row in pairs(rowOf) do holder[questID] = row end
	for _, group in ipairs(groups) do
		for _, quest in ipairs(group.quests) do
			for _, step in ipairs(group.chainOf[quest]) do
				for _, questID in ipairs(HeldIDs(step)) do holder[questID] = holder[questID] or step end
			end
		end
	end
	local function ListedAs(quest)
		if not quest or listed[quest] then return quest end
		for _, questID in ipairs(HeldIDs(quest)) do
			if holder[questID] then return holder[questID] end
		end
		return quest
	end
	-- A part of a row of same-named quests opened from elsewhere is its part's row under that row, chosen as a
	-- step, that row's chain alone opened (not other chains it is a step of).
	local revealUnder
	local partRow = reveal and not own[reveal] and rowOf[reveal.questID]
	for _, part in ipairs(partRow and partRow.parts or {}) do
		if not revealUnder and (part == reveal or RowIDs(part)[reveal.questID]) then
			reveal, revealUnder = part, partRow
			page.selectedQuest, page.selectedAsStep, page.selectedUnder = part, true, partRow
		end
	end
	reveal = ListedAs(reveal)
	if page.selectedQuest and not listed[page.selectedQuest] and ListedAs(page.selectedQuest) ~= page.selectedQuest then
		page.selectedQuest, page.selectedAsStep, page.selectedUnder = ListedAs(page.selectedQuest), nil, nil
	end
	-- A quest opened from elsewhere opens its dropdown; a step with no row of its own, its chain too (a
	-- quest that has one is chosen there, and the chains that name it as a step stay as they are).
	for _, group in ipairs(groups) do
		local section = group.section
		section.quests, section.members, section.chainOf = group.quests, {}, group.chainOf
		-- (the roads its rows come after, and their dropdowns: ChooseFirst, as QuestsPanel:Clicked opens it too)
		section.roads, section.roadGroups = group.roads, groupOf
		for _, quest in ipairs(group.quests) do
			local chain = group.chainOf[quest]
			section.members[quest] = true
			for _, step in ipairs(chain) do section.members[step] = true end
			if revealUnder then
				if quest == revealUnder then
					open[section.key], open[quest.questID] = true, true
				end
			elseif reveal and (reveal == quest or (not own[reveal] and Holds(chain, reveal))) then
				open[section.key] = true
				if reveal ~= quest then open[quest.questID] = true end
			end
		end
		section.expanded = open[section.key] == true
	end

	-- Keep the choice while the dungeon lists it, shown or folded away; otherwise start on Dungeon
	-- Quests' first quest still to do (one after a branch as a step under its row; in Adventure Mode one the
	-- character knows, or a step of a row's chain it knows: ChooseFirst), else Class Quests' (Before you go's
	-- dropdowns start folded: one of their quests is chosen as the player opens it, QuestsPanel:Clicked). Where
	-- neither has a quest and a key of Before you go does (in Adventure Mode, where the only quests found are a key's:
	-- Dungeon Quests and Class Quests with none known are left out), that key's first quest still to do, the first
	-- key in Before you go's order that has one, its dropdown unfolded so the quest chosen is seen (the owner's call
	-- of 2026-11-18, "open the key's quest instead", for Krol'dok's moulding and every dungeon alike). Else none.
	local selected = page.selectedQuest
	if not (selected and listed[selected]) then
		-- (the first dropdown not a key's: Dungeon Quests comes before Class Quests, QuestsPanel:Rows)
		selected = nil
		page.selectedQuest, page.selectedAsStep, page.selectedUnder = nil, nil, nil
		for _, group in ipairs(groups) do
			if not group.keyEntry and #group.quests > 0 then
				selected = ChooseFirst(page, group.quests, group.chainOf, group.roads, groupOf)
				break
			end
		end
		if not selected then
			for _, note in ipairs(notes) do
				local group = note.key and groupOf[note.key]
				if group and #group.quests > 0 then
					selected = ChooseFirst(page, group.quests, group.chainOf)
					-- (not while QuestsPanel:Open shows the tab: the quest opened from elsewhere is chosen next, and opens
					-- the dropdown that holds it)
					if not page.opening then
						open[group.section.key] = true
						group.section.expanded = true
					end
					break
				end
			end
		end
	end

	local y, headers, rows, boxes, chosenY, chosenAsStep, chosenUnder, chosenPart = TOP_PADDING, 0, 0, 0, nil, false, nil, nil
	-- (a road opened from its line with no quest to choose there: its header's place, QuestsPanel:OpenRoad)
	local revealY
	-- under: the row a step is listed under; part: its number there (ChainRows).
	local function Place(quest, depth, hasChain, expanded, part, under)
		if quest == selected then
			-- (where it is listed twice, the row it was chosen from)
			local mine = under == page.selectedUnder
			if not chosenY or mine then chosenY, chosenPart = y, part end
			-- (chosen as a step, and that step still shown: a chain folded since shows it as its row)
			if depth > 0 and page.selectedAsStep and (not chosenAsStep or mine) then chosenAsStep, chosenUnder = true, under end
		end
		rows = rows + 1
		local row = list.Rows[rows]
		if not row then
			row = CreateRow(child)
			list.Rows[rows] = row
		end
		SetRow(row, quest, depth, hasChain, expanded, quest == selected, part)
		row.under = under
		row:SetWidth(LIST_WIDTH - ROW_INDENT - depth * INDENT - ROW_INDENT)
		row:SetPoint("TOPLEFT", ROW_INDENT + depth * INDENT, -y)
		row:Show()
		y = y + ROW_HEIGHT
		return row
	end
	-- A road's line under a quest's + (RoadLine), one in, as its steps are.
	local function PlaceRoad(key, quest)
		rows = rows + 1
		local row = list.Rows[rows]
		if not row then
			row = CreateRow(child)
			list.Rows[rows] = row
		end
		SetRoadRow(row, RoadLine(instance, key, quest, rowOf, groupOf[key]), 1)
		row:SetWidth(LIST_WIDTH - ROW_INDENT - INDENT - ROW_INDENT)
		row:SetPoint("TOPLEFT", ROW_INDENT + INDENT, -y)
		row:Show()
		y = y + ROW_HEIGHT
	end
	local prepare = list.beforeYouGo
	prepare.headers, prepare.rows = {}, {}
	-- A dropdown's quests, their chains' steps beneath those opened: first a line for each road the quest comes after
	-- (a + with nothing else under it still opens on that, so it says what the quest waits on: the owner's answer of
	-- 2026-11-19), then its own steps.
	local function PlaceQuests(group, inKey)
		for _, quest in ipairs(group.quests) do
			local chain = group.chainOf[quest]
			local roads = group.roads and group.roads[quest] or NONE_LIST
			local hasChain = #chain > 0 or #roads > 0
			local chainOpen = hasChain and open[quest.questID] == true
			local row = Place(quest, 0, hasChain, chainOpen)
			if inKey then prepare.rows[#prepare.rows + 1] = row end
			if chainOpen then
				for _, key in ipairs(roads) do PlaceRoad(key, quest) end
				for index, step in ipairs(chain) do Place(step, 1, false, false, group.numbersOf[quest][index], quest) end
			end
		end
	end
	-- A header's text box, as SetHeader leaves it, else reaching `below` under the text (a key's quests in it).
	local function SetTextBox(header, below)
		header.DescriptionBG:ClearAllPoints()
		header.DescriptionBG:SetPoint("TOPLEFT", header.Description, "TOPLEFT", -9, 12)
		header.DescriptionBG:SetPoint("BOTTOMRIGHT", header.Description, "BOTTOMRIGHT", 9, -(below or BOX_BELOW_TEXT))
	end
	local function PlaceGroup(group)
		headers = headers + 1
		local header = list.Headers[headers]
		if not header then
			header = ns.PaperHeader.Create(child, function(section) QuestsPanel:Clicked(section) end)
			list.Headers[headers] = header
		end
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", 0, -y)
		header:SetWidth(LIST_WIDTH)
		local top = y
		if revealKey and group.section.key == revealKey then revealY = top end
		local height = ns.PaperHeader.Set(header, group.section, 0, group.section.expanded)
		header:Show()
		SetTextBox(header)
		if group.keyEntry then prepare.headers[#prepare.headers + 1] = header end
		local hasText = header.Description:IsShown()
		if hasText then
			-- A key of Before you go: its quests in its text's box, under the text, as the overview had them.
			local textBottom = top + height - TEXT_BELOW
			y = textBottom + BOX_BELOW_TEXT
			if #group.quests > 0 then
				y = textBottom + KEY_ROW_PADDING
				PlaceQuests(group, true)
				SetTextBox(header, y - textBottom + KEY_ROW_PADDING)
				y = y + KEY_ROW_PADDING
			end
		else
			y = top + height
			if group.section.expanded and #group.quests > 0 then
				local boxTop = y - BOX_TUCK
				y = y + BOX_PADDING
				PlaceQuests(group, group.keyEntry ~= nil)
				y = y + BOX_PADDING
				boxes = boxes + 1
				local box = list.Boxes[boxes]
				if not box then
					box = CreateBox(child)
					list.Boxes[boxes] = box
				end
				box:ClearAllPoints()
				box:SetPoint("TOPLEFT", child, "TOPLEFT", BOX_SIDE, -boxTop)
				box:SetPoint("BOTTOMRIGHT", child, "TOPLEFT", LIST_WIDTH - BOX_SIDE, -y)
				box:Show()
				box.Bottom:Show()
			end
		end
		y = y + HEADER_GAP * 2
	end

	-- Before you go first, under its bar: the notes in its order, a key as its dropdown.
	prepare.bar:SetShown(#notes > 0)
	prepare.label:SetShown(#notes > 0)
	local placed, noteHeaders = {}, 0
	if #notes > 0 then
		prepare.bar:ClearAllPoints()
		prepare.bar:SetPoint("TOPLEFT", -4, -y)
		y = y + BAR_HEIGHT + 4
	end
	for _, note in ipairs(notes) do
		local group = note.key and groupOf[note.key]
		if group then
			PlaceGroup(group)
			placed[group] = true
		else
			noteHeaders = noteHeaders + 1
			local header = list.Notes[noteHeaders]
			if not header then
				header = ns.PaperHeader.Create(child, function(section) QuestsPanel:ToggleNote(section) end)
				list.Notes[noteHeaders] = header
			end
			header:ClearAllPoints()
			header:SetPoint("TOPLEFT", 0, -y)
			header:SetWidth(LIST_WIDTH)
			local height = ns.PaperHeader.Set(header, note.section, 0, note.section.expanded)
			header:Show()
			prepare.headers[#prepare.headers + 1] = header
			-- (to the foot of its text's box, as a dropdown's box ends)
			y = y + (header.Description:IsShown() and height - (TEXT_BELOW - BOX_BELOW_TEXT) or height) + HEADER_GAP * 2
		end
	end
	-- Then the dropdowns: Dungeon Quests, then Class Quests.
	for _, group in ipairs(groups) do
		if not placed[group] then PlaceGroup(group) end
	end
	for index = noteHeaders + 1, #list.Notes do list.Notes[index]:Hide() end
	for index = headers + 1, #list.Headers do list.Headers[index]:Hide() end
	for index = boxes + 1, #list.Boxes do
		list.Boxes[index]:Hide()
		list.Boxes[index].Bottom:Hide()
	end
	for index = rows + 1, #list.Rows do list.Rows[index]:Hide() end
	child:SetHeight(math.max(1, y + 4))

	-- A quest opened from elsewhere is scrolled into view, once the client knows the list's
	-- scroll range (as the loot list does); a road opened with none to choose, its header.
	local revealAt = reveal and chosenY or revealKey and revealY
	if revealAt then
		C_Timer.After(0, function()
			local top, height = list:GetVerticalScroll() or 0, list:GetHeight() or 0
			if revealAt < top or revealAt + ROW_HEIGHT > top + height then
				list:SetVerticalScroll(math.max(0, math.min(list:GetVerticalScrollRange() or 0, revealAt - TOP_PADDING)))
			end
		end)
	end

	if not chosenAsStep then page.selectedAsStep, page.selectedUnder = nil, nil end
	-- The part's number it was shown with, kept while its chain is folded away.
	if chosenY then page.shownPart = { quest = selected, part = chosenPart } end
	local part = page.shownPart and page.shownPart.quest == selected and page.shownPart.part or nil
	-- (a part chosen under its own row of same-named quests is not a step of another quest's chain: its page
	-- says where its chain goes next)
	local asStep = chosenAsStep and not (chosenUnder and Holds(chosenUnder.parts, selected))
	local detailChild = page.QuestDetail.Child
	detailChild.Empty:SetShown(selected == nil)
	-- (Adventure Mode: a dungeon with quests for the player, none of them found yet)
	detailChild.Empty:SetText(adventure and anyQuests and L.ADVENTURE_QUESTS_NONE or L.QUEST_NONE)
	if selected then
		FillDetail(page.QuestDetail, selected, instance, asStep, part)
	else
		HideDetail(detailChild)
	end
end
