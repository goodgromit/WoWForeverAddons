local _, ns = ...

--[[
	퀘스트 제목을 게임 데이터(퀘스트 ID)로 표시한다. (로컬 수정, 원래 Aegis에는 없는 파일)

	Aegis는 퀘스트 제목을 영어로 갖고 있다가 언어별 번역표(Locales/*_content.lua)로 바꾸는데, 번역표에 없는
	퀘스트는 영어로 남는다. 이 파일은 접속 후 각 퀘스트의 제목을 게임에 퀘스트 ID로 물어(C_QuestLog.GetTitleForQuestID)
	클라이언트 언어의 공식 제목으로 바꾼다. 퀘스트 내용(목표, 메모)은 Aegis 것을 그대로 둔다.

	- 게임이 이미 아는 퀘스트는 접속하자마자 바뀐다.
	- 게임이 아직 모르는 퀘스트는 서버에 조금씩 나눠 요청하고(RequestLoadQuestByID), 도착하면(QUEST_DATA_LOAD_RESULT)
	  바꾼 뒤 도감을 다시 그린다. 게임 클라이언트가 받은 퀘스트 정보를 기억하므로 애드온 쪽 캐시는 두지 않는다.
	- 게임에서도 제목을 못 받은 퀘스트는 지금처럼 Aegis의 이름(번역 또는 영어)을 쓴다.
	- 대상: { questID = 숫자, name = 글자 } 인 퀘스트 표. 던전의 퀘스트와 그 선행 퀘스트(prerequisites), 상위 퀘스트
	  (parentQuest), 여러 버전(oneOf), 하위 페이지(pages), 퀘스트 단계 데이터(Data/Generated/QuestSteps.lua). 호드 쪽(horde)은 이름을 단계에서 읽어 간다.
	- 한계: 검색 색인(UI/Search.lua)은 처음 검색할 때 한 번 만들어지므로, 그 뒤에 도착한 제목은 검색 결과에 /reload 후 반영된다.

	필요한 다른 수정: Core/Registry.lua의 ns.DataChanged 공개 한 줄, TOC의 이 파일 한 줄.
]]

local GetTitle = C_QuestLog and C_QuestLog.GetTitleForQuestID
local RequestLoad = C_QuestLog and C_QuestLog.RequestLoadQuestByID
if not (GetTitle and RequestLoad) then return end

local REQUESTS_PER_TICK = 5		-- 한 번에 보낼 요청 수
local TICK_INTERVAL = 0.2		-- 요청을 보내는 간격(초)
local REFRESH_DELAY = 1			-- 제목이 바뀐 뒤 도감을 다시 그리기까지 기다리는 시간(초). 연달아 도착하면 한 번만 그린다.

-- 퀘스트 단계 데이터는 Registry.lua 안에만 있어서, 등록 함수를 감싸 목록을 기록해 둔다.
-- (이 파일은 TOC에서 Core 마지막, Data 앞에 있어야 한다: Data 파일들이 등록 함수를 부르기 전)
local stepLists = {}
local AddQuestSteps = ns.AddQuestSteps
ns.AddQuestSteps = function(list, ...)
	stepLists[#stepLists + 1] = list
	return AddQuestSteps(list, ...)
end

-- 퀘스트 ID → 그 퀘스트를 가리키는 표들
local byID = {}

local function Add(t)
	if type(t) ~= "table" or type(t.questID) ~= "number" or type(t.name) ~= "string" then return end
	local list = byID[t.questID]
	if not list then
		list = {}
		byID[t.questID] = list
	end
	list[#list + 1] = t
end

-- 퀘스트 하나와, 그 안에서 다른 퀘스트를 가리키는 표들
local function AddQuest(quest, seen)
	if type(quest) ~= "table" or seen[quest] then return end
	seen[quest] = true
	Add(quest)
	for _, other in ipairs(quest.prerequisites or {}) do Add(other) end
	Add(quest.parentQuest)
	for _, version in ipairs(quest.oneOf or {}) do Add(version) end
	for _, page in ipairs(quest.pages or {}) do AddQuest(page, seen) end
end

local function CollectQuests()
	local seen = {}
	for _, kind in ipairs({ "dungeon", "raid" }) do
		for _, instance in ipairs(ns.GetInstances(kind)) do
			for _, quest in ipairs(instance.quests or {}) do AddQuest(quest, seen) end
		end
	end
	for _, list in ipairs(stepLists) do
		for _, quest in pairs(list) do AddQuest(quest, seen) end
	end
end

-- 게임이 아는 제목으로 바꾼다. 바꿀 제목이 없으면 false
local function ApplyTitle(questID)
	local title = GetTitle(questID)
	if type(title) ~= "string" or title == "" or (issecretvalue and issecretvalue(title)) then return false end
	local changed = false
	for _, t in ipairs(byID[questID]) do
		if t.name ~= title then
			t.name = title
			changed = true
		end
	end
	return true, changed
end

-- 제목이 바뀌면 도감이 다시 계산하도록 데이터 버전을 올리고, 열려 있으면 다시 그린다. 연달아 바뀌면 한 번만.
local refreshPending = false
local function ScheduleRefresh()
	if refreshPending then return end
	refreshPending = true
	C_Timer.After(REFRESH_DELAY, function()
		refreshPending = false
		if ns.DataChanged then ns.DataChanged() end
		if ns.Journal and ns.Journal.Redraw then pcall(ns.Journal.Redraw, ns.Journal) end
	end)
end

-- 게임이 아직 모르는 퀘스트: 조금씩 나눠 요청한다
local queue = {}
local ticker
local function SendRequests()
	for _ = 1, REQUESTS_PER_TICK do
		local questID = table.remove(queue)
		if not questID then
			ticker:Cancel()
			ticker = nil
			return
		end
		RequestLoad(questID)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
frame:SetScript("OnEvent", function(_, event, questID, success)
	if event == "PLAYER_LOGIN" then
		-- Aegis가 ADDON_LOADED에서 번역을 적용한 뒤이므로, 그 위에 게임 제목을 덮어쓴다
		CollectQuests()
		local anyChanged = false
		for id in pairs(byID) do
			local ok, changed = ApplyTitle(id)
			if ok then
				anyChanged = anyChanged or changed
			else
				queue[#queue + 1] = id
			end
		end
		if anyChanged and ns.DataChanged then ns.DataChanged() end
		if #queue > 0 then ticker = C_Timer.NewTicker(TICK_INTERVAL, SendRequests) end
	elseif event == "QUEST_DATA_LOAD_RESULT" then
		-- 다른 화면이 요청한 퀘스트라도 도감에 있는 퀘스트면 반영한다
		if not success or not byID[questID] then return end
		local ok, changed = ApplyTitle(questID)
		if ok and changed then ScheduleRefresh() end
	end
end)
