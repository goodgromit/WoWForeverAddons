local _, ns = ...
local L = ns.L

--[[
	Before you go, at the top of a dungeon's Quests tab (UI/QuestsPanel.lua): what the dungeon asks of the
	player before its door (a key and the quests to it) and what is worth preparing (a hidden boss and how to
	summon it), from its data's `prepare` list ({ title, text, faction, classOnly, quests, kind, boss, bosses,
	haveWhen, chain, mapMarks }), for the player's own side and class.

	An entry is a key when it lists quests, or says kind = "key" (a key no quest gives, such as one
	a boss drops). The player has a key once its last quest is taken (a key given with the quest),
	or, with haveWhen = "done", once it is handed in (a key or attunement the quest rewards). It is a
	hidden boss when it names one (boss = "<his English name>"); any other entry is a plain note, one
	naming several bosses too (bosses = { "<English name>", ... }: the Shaper's Terrace's console bosses
	and Nanaya, not hidden, the owner's call of 2026-11-19), whose pages each open it. A key's
	quests may be ones the journal keeps under another dungeon (an attunement's), or steps of a chain
	it keeps for none (Data/Generated/QuestSteps.lua). An entry with chain = true is a chain to do
	first, not a key (Alcaz Prison's way in from Stormwind): once done, it says so, not "You have it". With
	mapMarks = true its quests have marks on the world map too (UI/QuestMap.lua's Index).

	The Quests tab lists the notes under a "Before you go" bar, in this order (BeforeYouGo:Notes), each under
	one of the Abilities tab's paper headers:
	  a key with quests is the tab's dropdown for it (BeforeYouGo:Keys): its header carries the mark of the
	  quest the player is on and how many of its quests are done (a check once they have the key), its box
	  the note's text and how far along the player is, then its quests.
	  a key no quest gives carries a key; a hidden boss's header, a skull; a plain note, no icon. These hold
	  their text alone (the owner's call of 2026-11-13). A hidden boss's note also opens his own page, as a
	  note naming several bosses opens each one's (BeforeYouGo:BossNote).
	All of them start folded on the tab, keys and chains too, had or not (the owner's call of 2026-11-14), so
	the dungeon's own quests come first: QuestsPanel:Refresh.
	The dungeon's overview says how many notes there are, in one line that opens the tab.

	In Adventure Mode (Core/Discovery.lua) the notes show once the dungeon is entered (a rumour's page has no
	Quests tab, and its overview no line for them: UI/EncounterPage.lua). Every entry stays; a key's quests are
	those the character knows, as the Quests tab lists them, and its mark is theirs (a key's, while it knows
	none); and no title or text names what is not found yet (Discovery:Mask): an unmet boss or rare of the
	dungeon, a hidden boss not told yet, an item not seen to drop there, or another dungeon's unmet boss
	(Discovery:Untold); nor a quest the character has not been offered (Discovery:MaskAll).
]]

local BeforeYouGo = {}
ns.BeforeYouGo = BeforeYouGo

local HIDDEN_BOSS_ICON = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local KEY_ICON = "Interface\\Icons\\INV_Misc_Key_03"
-- (the Quests tab's key header carries it too, in Adventure Mode)
BeforeYouGo.KEY_ICON = KEY_ICON
local HAVE_MARK = "|TInterface\\Buttons\\UI-CheckBox-Check:16:16|t"
-- (a road's line on the Quests tab carries it too, once the quest under it has all it needs of the road)
BeforeYouGo.HAVE_MARK = HAVE_MARK
-- The Quests tab's green, dark enough for the parchment.
local HAVE_COLOR = "|cff1e7d00"

function BeforeYouGo:Entries(instance)
	local list = {}
	local faction = UnitFactionGroup and UnitFactionGroup("player")
	local _, _, classFile = pcall(UnitClass, "player")
	for _, entry in ipairs(instance.prepare or {}) do
		if (not entry.faction or entry.faction == faction)
			and ns.ForClass(entry.classOnly, classFile) then
			list[#list + 1] = entry
		end
	end
	return list
end

-- How far along a key's quests the player is: how many are done, of how many, and whether they
-- have the key (its last quest taken or done; done only, with haveWhen = "done").
function BeforeYouGo:Progress(entry)
	local quests = entry.quests or {}
	local done = 0
	for _, questID in ipairs(quests) do
		if ns.QuestsPanel:IsDone(questID) then done = done + 1 end
	end
	local last = quests[#quests]
	local have = last ~= nil and (ns.QuestsPanel:IsDone(last)
		or (entry.haveWhen ~= "done" and ns.QuestsPanel:InLog(last)) or false)
	return done, #quests, have
end

-- A key's quest as the journal keeps it: the dungeon's own, or a step of one of its chains, as its
-- Quests tab lists it; else another dungeon's own (an attunement's quests, kept where they are
-- done); else a step of a chain the journal keeps for none of them. A step the dungeon's chains
-- know by its name alone (no level) is the other dungeon's quest, when one keeps it.
local function KeyQuest(instance, questID)
	local quest = ns.QuestsPanel:Find(instance, questID)
	if quest and quest.level then return quest end
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, other in ipairs(ns.GetInstances(kind)) do
			for _, candidate in ipairs(other.quests or {}) do
				if candidate.questID == questID then return candidate end
			end
		end
	end
	return ns.GetQuestStep(questID) or quest
end

-- A key's quests as the Quests tab lists them; steps it shows as one are listed once.
local function KeyQuests(instance, entry)
	local quests = {}
	for _, questID in ipairs(entry.quests or {}) do
		local quest = KeyQuest(instance, questID)
		if quest and quests[#quests] ~= quest then quests[#quests + 1] = quest end
	end
	return quests
end

-- The mark of the first quest still to do; a check once the player has the key.
local function KeyStatus(quests, have)
	local done = ns.QuestsPanel.STATUS_DONE
	if have then return done end
	for _, quest in ipairs(quests) do
		local status = ns.QuestsPanel:Status(quest)
		if status ~= done then return status end
	end
	return done
end

--[[
	The keys of a dungeon for the player's side, as headers show them: { key, entry, title, status,
	note, have, done, total, quests }: the Quests tab's dropdowns for them. Quests of one
	chain sharing a name are one row in the list (the two Dark Iron Legacy quests: QuestsPanel:Fold);
	the key's mark and count go by its quests one by one, as before.
]]
function BeforeYouGo:Keys(instance)
	local keys = {}
	for index, entry in ipairs(self:Entries(instance)) do
		if entry.quests and #entry.quests > 0 then
			local quests = KeyQuests(instance, entry)
			local done, total, have = self:Progress(entry)
			-- Adventure Mode: the mark of the quests the character knows; none while it knows none, nor a
			-- check while those it knows are done and more are still to come (the header then carries a key,
			-- as one no quest gives).
			local marked, adventure = quests, ns.Style:Adventure()
			if adventure then
				marked = {}
				for _, quest in ipairs(quests) do
					if ns.QuestsPanel:Known(quest) then marked[#marked + 1] = quest end
				end
			end
			local status = (not adventure or have or #marked > 0) and KeyStatus(marked, have) or nil
			if adventure and not have and #marked < #quests and status == ns.QuestsPanel.STATUS_DONE then status = nil end
			keys[#keys + 1] = {
				-- (its title masked where it is drawn, in Adventure Mode: Section below, and the Quests tab)
				key = "prepare:" .. index, entry = entry, title = entry.title,
				status = status,
				note = have and HAVE_MARK or string.format("%d/%d", done, total),
				have = have, done = done, total = total, quests = ns.QuestsPanel:Fold(quests),
			}
		end
	end
	return keys
end

-- An entry as a paper header's section, with the quests beneath it (a key's, from keys: BeforeYouGo:Keys).
-- (On the Quests tab each starts folded: QuestsPanel:Refresh. Its own boss page opens a hidden boss's note:
-- EncounterPage's PlaceBossNote.) In Adventure Mode its title and text name nothing not found yet.
local function Section(entry, index, keys, instance)
	local Discovery = ns.Discovery
	local untold = Discovery:Untold(instance)
	-- (nor a quest the character has not been offered: Discovery:MaskAll)
	local section = { key = "prepare:" .. index, flags = {}, title = Discovery:MaskAll(instance, entry.title, untold) }
	local text = Discovery:MaskAll(instance, ns.Items:LinkText(entry.text), untold)
	for _, key in ipairs(keys) do
		if key.entry == entry then
			section.status, section.note = key.status, key.note
			if not key.status then section.icon = KEY_ICON end
			-- A key with one quest says so in words, not "0 of its 1 quests" (once that quest is done,
			-- the player has the key).
			-- (a chain to do first, chain = true, is done, not had)
			local progress = key.have and (HAVE_COLOR .. (entry.chain and L.PREPARE_CHAIN_DONE or L.PREPARE_HAVE) .. "|r")
				or key.total == 1 and L.PREPARE_PROGRESS_ONE
				or string.format(L.PREPARE_PROGRESS, key.done, key.total)
			section.description = text .. "\n\n" .. progress
			return section, key.quests
		end
	end
	-- A key no quest gives; a hidden boss; else a plain note.
	if entry.kind == "key" then
		section.icon = KEY_ICON
	elseif entry.boss then
		section.icon = HIDDEN_BOSS_ICON
	end
	section.description = text
	return section, {}
end

-- Whether an entry names a boss by this English name: a hidden boss's (boss), or one of several (bosses).
local function Names(entry, name)
	if name == nil then return false end
	if entry.boss then return entry.boss == name end
	for _, named in ipairs(entry.bosses or {}) do
		if named == name then return true end
	end
	return false
end

-- The entry on a boss for the player's side (one naming it: boss = "<its English name>", a hidden boss's, or
-- bosses = { ... }, a plain note on several) and its place in the list; nil when none names it.
local function BossEntry(self, instance, boss)
	for index, entry in ipairs(self:Entries(instance)) do
		if Names(entry, boss.enName) or Names(entry, boss.name) then return entry, index end
	end
	return nil
end

-- The note on a boss, as a section for its own page's Overview; nil when no note names it. hiddenBoss is
-- true where it is a hidden boss's note (its page's bullet then calls him hidden: UI/EncounterPage.lua's
-- BossBullets), not a plain note naming several bosses.
function BeforeYouGo:BossNote(instance, boss)
	local entry, index = BossEntry(self, instance, boss)
	if not entry then return nil end
	local section = Section(entry, index, {}, instance)
	section.key = "boss:" .. (entry.boss or boss.enName or boss.name)
	section.hiddenBoss = entry.boss ~= nil
	return section
end

--[[
	The notes for the player's side, in their order, as the Quests tab lists them: { section, key } each, the
	section a paper header's (its text, and for a key its mark, count and how far along the player is), key
	the key's entry of keys (BeforeYouGo:Keys, the tab's dropdown for it) or nil for a note no quest of its
	own fills (plain = true on its section).
]]
function BeforeYouGo:Notes(instance, keys)
	keys = keys or self:Keys(instance)
	local notes = {}
	for index, entry in ipairs(self:Entries(instance)) do
		local section = Section(entry, index, keys, instance)
		local key
		for _, candidate in ipairs(keys) do
			if candidate.entry == entry then key = candidate end
		end
		section.plain = key == nil or nil
		notes[#notes + 1] = { section = section, key = key }
	end
	return notes
end
