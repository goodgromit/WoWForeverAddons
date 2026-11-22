-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Shared lightweight title plaque for rows and recap-style earned notices.
-- Difficulty lives in these reusable rules/corners, never in printed labels.
function FF:CreateAchievementPlaque(parent, dark)
    local plaque = CreateFrame("Frame", nil, parent)
    plaque:EnableMouse(false)
    plaque.dark = dark
    plaque.bg = plaque:CreateTexture(nil, "BACKGROUND")
    plaque.bg:SetAllPoints(plaque)
    plaque.rules, plaque.corners = {}, {}
    for _, edge in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
        local line = plaque:CreateTexture(nil, "BORDER")
        if edge == "TOP" or edge == "BOTTOM" then
            line:SetPoint(edge .. "LEFT"); line:SetPoint(edge .. "RIGHT"); line:SetHeight(1)
        else
            line:SetPoint("TOP" .. edge); line:SetPoint("BOTTOM" .. edge); line:SetWidth(1)
        end
        plaque.rules[#plaque.rules + 1] = line
    end
    for _, point in ipairs({"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}) do
        for _, horizontal in ipairs({true, false}) do
            local corner = plaque:CreateTexture(nil, "OVERLAY")
            corner:SetPoint(point, plaque, point, 0, 0)
            corner:SetSize(horizontal and 10 or 2, horizontal and 2 or 7)
            plaque.corners[#plaque.corners + 1] = corner
        end
    end
    plaque.title = plaque:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    plaque.title:SetPoint("LEFT", plaque, "LEFT", 13, 0)
    plaque.title:SetJustifyH("LEFT"); plaque.title:SetWordWrap(false)
    plaque.check = plaque:CreateTexture(nil, "OVERLAY")
    plaque.check:SetSize(18, 18); plaque.check:SetPoint("RIGHT", plaque, "RIGHT", -10, 0)
    plaque.check:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\JournalCheck.tga")
    return plaque
end

function FF:StyleAchievementPlaque(plaque, definition, completed)
    local style = self.achievementStyles[definition.difficulty]
    local color = style.color
    plaque.bg:SetColorTexture(plaque.dark and 0.09 or color[1], plaque.dark and 0.19 or color[2],
        plaque.dark and 0.23 or color[3], plaque.dark and 0.97 or (completed and 0.15 or 0.07))
    for index, line in ipairs(plaque.rules) do
        line:SetColorTexture(color[1], color[2], color[3], completed and 0.9 or 0.58)
        if index <= 2 then line:SetHeight(style.weight) else line:SetWidth(style.weight) end
    end
    for _, corner in ipairs(plaque.corners) do
        corner:SetColorTexture(color[1], color[2], color[3], completed and 1 or 0.75)
        corner:SetShown(style.prestige == true)
    end
    plaque.title:SetText(self:GetAchievementDisplayText(definition,"title"))
    plaque.title:SetTextColor(unpack(plaque.dark and {1,0.84,0.52} or style.title))
    plaque.title:SetWidth(math.max(80, plaque:GetWidth() - (completed and 50 or 26)))
    plaque.check:SetVertexColor(plaque.dark and 0.95 or 0.22, plaque.dark and 0.78 or 0.40, plaque.dark and 0.40 or 0.25)
    plaque.check:SetShown(completed)
end
local function Count(value)
    value = tonumber(value)
    return value and value == value and value < math.huge and math.max(0, math.floor(value)) or 0
end
local function Saved(self)
    local saved = self.db.achievements
    if type(saved) ~= "table" then saved = {}; self.db.achievements = saved end
    if type(saved.earned) ~= "table" then saved.earned = {} end
    if type(saved.facts) ~= "table" then saved.facts = {} end
    if type(saved.facts.lures) ~= "table" then saved.facts.lures = {} end
    return saved
end
local function Collection(self, ids, minimum)
    local count, missing = 0, {}
    for _, id in ipairs(ids) do
        local record = self.db.journal and self.db.journal[id]
        if Count(record and record.count) >= (minimum or 1) then count = count + 1
        else missing[#missing + 1] = id end
    end
    return count, missing
end

function FF:RefreshFishingAchievements(notify, refreshPersonal)
    if not self.db then return end
    local saved = Saved(self)
    local metrics, missing = {}, {}
    for _, set in ipairs({"standard", "rare", "gear", "nonfish", "full"}) do
        metrics[set], missing[set] = Collection(self, self.achievementCatchSets[set])
    end
    metrics.mastery, missing.mastery = Collection(self, self.achievementCatchSets.standard, 10)
    metrics.catches = Count(self.db.lifetime and self.db.lifetime.catchCount)
    metrics.quickCatches = Count(saved.facts.bestFiveMinuteCatches)
    metrics.cooks = Count(saved.facts.chefCooks)
    metrics.lures = 0
    for _, applied in pairs(saved.facts.lures) do if applied == true then metrics.lures = metrics.lures + 1 end end
    local zones = {}
    for location, amount in pairs(self.db.fishingLocations or {}) do
        if type(location) == "string" and Count(amount) > 0 then
            -- Statistics formats exact parent zone then ': subzone'. No map or
            -- suggested-water guess can manufacture recorded catch locations.
            local parent = location:match("^(.-): ") or location
            if parent ~= "" and parent ~= "Unknown" then zones[parent] = true end
        end
    end
    metrics.zones = 0
    for _ in pairs(zones) do metrics.zones = metrics.zones + 1 end
    local previous = self.achievementMetrics or {}
    if refreshPersonal then
        local skills = self.GetJournalSkills and self:GetJournalSkills() or {}
        metrics.skill = Count(skills.Fishing and skills.Fishing.base)
        metrics.recipes, self.achievementRecipeTarget, self.achievementRecipeDetail, self.achievementRecipeDisplay = self:GetAchievementRecipeProgress()
    else metrics.skill, metrics.recipes = previous.skill or 0, previous.recipes or 0 end
    local states, completed, changed = {}, 0, false
    for _, definition in ipairs(self.achievementDefinitions) do
        local target = type(definition.target) == "number" and definition.target
            or definition.target == "recipes" and (self.achievementRecipeTarget or 0)
            or #self.achievementCatchSets[definition.target]
        local current = metrics[definition.metric] or 0
        local earned = saved.earned[definition.id]
        if not earned and target > 0 and current >= target then
            earned = {at=GetServerTime and GetServerTime() or (time and time()) or 0,
                count=current, target=target, owner=UnitGUID and UnitGUID("player")}
            saved.earned[definition.id] = earned
            if notify and self.QueueAchievementNotice then self:QueueAchievementNotice(definition.id) end
        end
        if earned then completed = completed + 1 end
        local state = {definition=definition, current=current, target=target, earned=earned,
            missing=missing[definition.metric]}
        local old = self.achievementStates and self.achievementStates[definition.order]
        if not old or old.current ~= current or old.target ~= target or old.earned ~= earned then changed = true end
        states[#states + 1] = state
    end
    self.achievementStates, self.achievementMetrics, self.achievementsCompleted = states, metrics, completed
    if changed then self.achievementRevision = (self.achievementRevision or 0) + 1 end
end

function FF:GetAchievementDetails(state)
    local definition = state.definition
    local lines = {}
    if state.earned then
        lines[#lines + 1] = (state.earned.at and state.earned.at > 0 and date and self:LocalizedText("achievement.detail.completed-date",self:FormatTimestampDisplay(state.earned.at,"long")) or self:LocalizedText("achievement.detail.completed"))
    end
    if definition.flavour then lines[#lines + 1] = self:GetAchievementDisplayText(definition,"flavour") end
    if definition.detail then lines[#lines + 1] = self:GetAchievementDisplayText(definition,"detail") end
    if definition.metric == "lures" then
        lines[#lines + 1] = self:LocalizedText("achievement.detail.lures")
    elseif definition.metric == "recipes" then
        lines[#lines + 1] = self:GetAchievementRecipeDetail()
    elseif definition.metric == "zones" then
        lines[#lines + 1] = self:LocalizedText("achievement.detail.zones")
    end
    if state.missing and #state.missing > 0 and not state.earned then
        local names = {}
        for index = 1, math.min(5, #state.missing) do
            local entry = self.catchCollectionByID[state.missing[index]]
            names[#names + 1] = self:GetJournalItemDisplayName(state.missing[index],entry and entry[2] or self:LocalizedText("common.item-id",state.missing[index]))
        end
        lines[#lines + 1] = (#state.missing>5 and self:LocalizedText("achievement.detail.missing-more",table.concat(names,", "),#state.missing-5) or self:LocalizedText("achievement.detail.missing",table.concat(names,", ")))
    end
    return table.concat(lines, "\n\n")
end

-- Statistics calls this only on the first qualified loot of a successful cast.
-- Keep at most ten server timestamps per character so a rolling attempt can
-- survive reload without mixing characters or retaining a catch-event log.
function FF:RecordAchievementFishingCatch()
    if not self.db then return end
    local saved = Saved(self)
    if saved.earned["eyes-on-the-water"] then return end
    local owner = UnitGUID and UnitGUID("player")
    local now = GetServerTime and GetServerTime() or (time and time())
    if not owner or type(now) ~= "number" then return end
    local windows = saved.facts.catchWindows
    if type(windows) ~= "table" then windows = {}; saved.facts.catchWindows = windows end
    local previous = windows[owner]
    local recent = {}
    for _, stamp in ipairs(type(previous) == "table" and previous or {}) do
        if type(stamp) == "number" and stamp >= now - 300 and stamp <= now then
            recent[#recent + 1] = stamp
        end
    end
    recent[#recent + 1] = now
    while #recent > 10 do table.remove(recent, 1) end
    windows[owner] = recent
    saved.facts.bestFiveMinuteCatches = math.max(Count(saved.facts.bestFiveMinuteCatches), #recent)
    if #recent == 10 then saved.facts.catchWindows = nil end
end

-- These facts supplement existing catch quantities, locations and recipe/skill
-- owners. Earned records stay sticky across settings resets and content changes.
function FF:RecordAchievementChefCook()
    local saved = Saved(self)
    saved.facts.chefCooks = Count(saved.facts.chefCooks) + 1
    self:RefreshFishingAchievements(true)
end

function FF:OnAchievementLureEvent(event, spellID, castGUID)
    if not self.db then return end
    if (issecretvalue and (issecretvalue(spellID) or issecretvalue(castGUID))) then return end
    if event == "UNIT_SPELLCAST_SENT" or event == "UNIT_SPELLCAST_START" then
        if self.achievementLureAttempt and self.achievementLureAttempt.guid == castGUID then return end
        local id = self.GetRecognizedLureForSpell and self:GetRecognizedLureForSpell(spellID)
        local pole = GetInventoryItemID and GetInventoryItemID("player", 16)
        if not id or not pole or not self.FishingRodEquippedNow or self:FishingRodEquippedNow() ~= true then return end
        self.achievementLureAttempt = {id=id, spell=spellID, guid=castGUID, pole=pole,
            before=self:LureSeconds(), started=GetTime()}
        return
    end
    local attempt = self.achievementLureAttempt
    if not attempt or attempt.spell ~= spellID or attempt.guid ~= castGUID then return end
    if event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        self.achievementLureAttempt = nil
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if attempt.succeeded then return end
        attempt.succeeded = true
        local function Confirm()
            if self.achievementLureAttempt ~= attempt then return end
            local remaining = self:LureSeconds()
            if GetInventoryItemID("player", 16) == attempt.pole and self:FishingRodEquippedNow() == true
                and remaining and attempt.before and remaining > attempt.before + 1 then
                Saved(self).facts.lures[attempt.id] = true
                self.achievementLureAttempt = nil
                self:RefreshFishingAchievements(true)
                if self.RefreshJournal then self:RefreshJournal() end
            end
        end
        Confirm()
        if self.achievementLureAttempt == attempt and C_Timer and C_Timer.After then
            C_Timer.After(0.1, Confirm)
            C_Timer.After(0.5, function() Confirm(); if self.achievementLureAttempt == attempt then self.achievementLureAttempt = nil end end)
        end
    end
end
