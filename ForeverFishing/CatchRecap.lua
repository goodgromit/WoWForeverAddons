-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

local DURATION = 5
local FADE_DURATION = 0.6
local WIDTH = 286
local ROW_HEIGHT = 31
local BAR_GAP = 65

local function PlainRecapFact(value)
    return not (issecretvalue and issecretvalue(value))
end

local function RecapCount(value)
    if PlainRecapFact(value) and type(value) == "number" and value > 0
        and value < math.huge and value % 1 == 0 then return value end
    return 0
end

local function ValidRecapIcon(value)
    return PlainRecapFact(value) and (type(value) == "string" and value ~= ""
        or type(value) == "number" and value > 0 and value < math.huge)
end

local function ItemIcon(id, lootIcon)
    if ValidRecapIcon(lootIcon) then return lootIcon end
    for _, getter in ipairs({C_Item and C_Item.GetItemIconByID or false, GetItemIcon or false}) do
        if getter then
            local ok, icon = pcall(getter, id)
            if ok and ValidRecapIcon(icon) then return icon end
        end
    end
end

local function RecapItemInfo(id)
    if not GetItemInfo then return end
    local ok, name, _, quality = pcall(GetItemInfo, id)
    if not ok then return end
    if not PlainRecapFact(name) or type(name) ~= "string" or name == "" then name = nil end
    if not PlainRecapFact(quality) or type(quality) ~= "number" or quality < 0
        or quality >= math.huge or quality % 1 ~= 0 then quality = nil end
    return name, quality
end

local function RecapQualityRGB(quality)
    if quality and GetItemQualityColor then
        local ok, r, g, b = pcall(GetItemQualityColor, quality)
        if ok and PlainRecapFact(r) and PlainRecapFact(g) and PlainRecapFact(b)
            and type(r) == "number" and type(g) == "number" and type(b) == "number"
            and r >= 0 and r <= 1 and g >= 0 and g <= 1 and b >= 0 and b <= 1 then return r, g, b end
    end
    return 0.94, 0.94, 0.88
end

local function SavePosition(self, panel)
    local x, y = panel:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not x or not y or not parentX or not parentY then return end
    local scale = panel:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local offsetX, offsetY = x * scale - parentX, y * scale - parentY
    self.db.catchRecapPosition = { x = offsetX, y = offsetY }
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "CENTER", offsetX / scale, offsetY / scale)
end

function FF:PositionCatchRecap()
    local panel = self.catchRecapPanel
    if not panel then return end
    local position = type(self.db.catchRecapPosition) == "table" and self.db.catchRecapPosition or nil
    panel:ClearAllPoints()
    if position and tonumber(position.x) and tonumber(position.y) then
        local scale = panel:GetEffectiveScale() / UIParent:GetEffectiveScale()
        panel:SetPoint("CENTER", UIParent, "CENTER", tonumber(position.x) / scale, tonumber(position.y) / scale)
    else
        panel:SetPoint("LEFT", self.bar, "RIGHT", BAR_GAP, 0)
    end
end

local function AddSolid(parent, point, width, height, r, g, b, a)
    local texture = parent:CreateTexture(nil, "BORDER")
    texture:SetPoint(unpack(point))
    texture:SetSize(width, height)
    texture:SetColorTexture(r, g, b, a)
    return texture
end

function FF:RefreshCatchRecapSetting()
    local panel = self.settingsPanel
    if not panel then return end
    if panel.catchRecapButton then panel.catchRecapButton:SetState(self.db.catchRecap) end
    if panel.generalCatchRecapButton then panel.generalCatchRecapButton:SetState(self.db.catchRecap) end
    local recommended = self:GetBlizzardUIHideMode() ~= "never" and self.db.catchRecap ~= true
    if panel.catchRecapRecommended then panel.catchRecapRecommended:SetShown(recommended) end
    if panel.generalCatchRecapRecommended then panel.generalCatchRecapRecommended:SetShown(recommended) end
end

function FF:SetCatchRecapEnabled(enabled)
    if not self.db then return end
    self.db.catchRecap = enabled == true
    if not self.db.catchRecap then self:HideCatchRecap() end
    self:RefreshCatchRecapSetting()
end

function FF:HideCatchRecap(keepAchievementNotices)
    self.catchRecapRevision = (self.catchRecapRevision or 0) + 1
    if not keepAchievementNotices and self.HideAchievementNotice then self:HideAchievementNotice(true) end
    self.catchRecapCast = nil
    self.catchRecapItems = nil
    self.catchRecapElapsed = nil
    local panel = self.catchRecapPanel
    if panel then
        if panel.moving == true then panel:StopMovingOrSizing(); panel.moving = nil end
        panel:SetScript("OnUpdate", nil)
        panel:Hide()
        panel:SetAlpha(1)
    end
end

function FF:HideAchievementNotice(clearQueue)
    local panel = self.achievementNotice
    if panel then
        panel:SetScript("OnUpdate", nil); panel:Hide(); panel:SetAlpha(1); panel.achievementID = nil
        panel.glow:SetAlpha(0)
    end
    if clearQueue then self.achievementNoticeQueue = nil end
end

local function NoticeFont(parent, template, size, r, g, b)
    local text = parent:CreateFontString(nil, "OVERLAY", template)
    local font = text:GetFont()
    FF:SetDisplayFont(text, font, size, "")
    text:SetShadowOffset(0, 0); text:SetShadowColor(0, 0, 0, 0)
    text:SetTextColor(r, g, b); text:SetJustifyH("LEFT"); text:SetWordWrap(true)
    return text
end

local function PositionAchievementNotice(self, panel)
    -- Use the native raid-warning location without parenting to hidden native
    -- UI. Convert every coordinate through effective scale, then fit the whole
    -- decorated banner inside the current viewport (including live resizes).
    local width, height = UIParent:GetWidth(), UIParent:GetHeight()
    if not width or not height or width <= 0 or height <= 0 then return end
    local parentScale = UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
    local localScale = panel.GetScale and panel:GetScale() or 1
    local baseScale = (panel.GetEffectiveScale and panel:GetEffectiveScale() or parentScale) / localScale / parentScale
    local margin = math.min(12, width / 8, height / 8)
    local fit = math.min(1, (width - margin * 2) / (panel:GetWidth() * baseScale),
        (height - margin * 2) / (panel:GetHeight() * baseScale))
    if panel.SetScale and math.abs(localScale - fit) > 0.000001 then panel:SetScale(fit) end
    local scale = baseScale * fit
    local left, top = UIParent:GetLeft() or 0, UIParent:GetTop() or height
    local centerX, centerY = left + width / 2, top - height * 0.15
    local warning = RaidWarningFrame
    if warning and warning.GetCenter then
        local x, y = warning:GetCenter()
        if x and y then
            local warningScale = warning:GetEffectiveScale() / parentScale
            centerX, centerY = x * warningScale, y * warningScale
        end
    end
    centerY = centerY + 140 -- UIParent units; keep the whole banner on-screen below.
    local halfWidth, halfHeight = panel:GetWidth() * scale / 2, panel:GetHeight() * scale / 2
    centerX = math.max(left + margin + halfWidth, math.min(left + width - margin - halfWidth, centerX))
    centerY = math.max(top - height + margin + halfHeight, math.min(top - margin - halfHeight, centerY))
    local x, y = (centerX - left - width / 2) / scale, (centerY - top) / scale
    if not panel.noticeX or math.abs(panel.noticeX - x) > 0.000001 or math.abs(panel.noticeY - y) > 0.000001 then
        panel:ClearAllPoints(); panel:SetPoint("CENTER", UIParent, "TOP", x, y)
        panel.noticeX, panel.noticeY = x, y
    end
end

function FF:QueueAchievementNotice(id)
    if not self.db.catchRecap or not self.achievementsByID[id] then return end
    self.achievementNoticeQueue = self.achievementNoticeQueue or {}
    self.achievementNoticeQueue[#self.achievementNoticeQueue + 1] = id
    self:ShowNextAchievementNotice()
end

function FF:ShowNextAchievementNotice()
    if (InCombatLockdown and InCombatLockdown()) or not self.db.catchRecap then return end
    local queue = self.achievementNoticeQueue
    if not queue or #queue == 0 or (self.achievementNotice and self.achievementNotice:IsShown()) then return end
    if self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
    local id = table.remove(queue, 1)
    local definition = self.achievementsByID[id]
    if not definition then return self:ShowNextAchievementNotice() end
    local panel = self.achievementNotice
    if not panel then
        panel = CreateFrame("Button", nil, self:EnsureFishingVisibilityRoot())
        panel:SetSize(376, 80); panel:SetClampedToScreen(true)
        panel:RegisterForClicks("LeftButtonUp")
        -- The fixed E05 corners extend outside their E04 rails. Inset the
        -- chrome so all visible decoration stays inside the clamped hit area.
        panel.chrome = CreateFrame("Frame", nil, panel)
        panel.chrome:EnableMouse(false)
        panel.chrome:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -10)
        panel.chrome:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
        panel.background = panel.chrome:CreateTexture(nil, "BACKGROUND")
        panel.background:SetAllPoints(panel.chrome)
        panel.background:SetColorTexture(0.09, 0.19, 0.23, 0.97)
        panel.border = self:CreateJournalFrame(panel.chrome, true)
        panel.art = CreateFrame("Frame", nil, panel)
        panel.art:EnableMouse(false); panel.art:SetSize(48, 48)
        panel.art:SetPoint("LEFT", panel, "LEFT", 22, 0)
        panel.icon = panel.art:CreateTexture(nil, "ARTWORK")
        panel.icon:SetPoint("TOPLEFT", panel.art, "TOPLEFT", 2, -2)
        panel.icon:SetPoint("BOTTOMRIGHT", panel.art, "BOTTOMRIGHT", -2, 2)
        panel.art.border = self:CreateJournalFrame(panel.art, false, 10)
        panel.glow = panel.art:CreateTexture(nil, "OVERLAY")
        panel.glow:SetPoint("TOPLEFT", panel.art, "TOPLEFT", -9, 9)
        panel.glow:SetPoint("BOTTOMRIGHT", panel.art, "BOTTOMRIGHT", 9, -9)
        panel.glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
        panel.glow:SetTexCoord(0.0078125, 0.5078125, 0.53515625, 0.78515625)
        panel.glow:SetBlendMode("ADD"); panel.glow:SetVertexColor(1, 0.68, 0.16, 1)
        panel.textBlock = CreateFrame("Frame", nil, panel); panel.textBlock:EnableMouse(false)
        panel.textBlock:SetPoint("LEFT", panel, "LEFT", 84, 0)
        panel.heading = NoticeFont(panel.textBlock, "GameFontNormal", 11, 1, 0.84, 0.52)
        panel.heading:SetPoint("TOPLEFT", panel.textBlock, "TOPLEFT", 0, 0)
        panel.heading:SetText(self:LocalizedText("achievement.notice.earned"))
        panel.title = NoticeFont(panel.textBlock, "GameFontNormalLarge", 18, 1, 0.94, 0.80)
        panel.title:SetPoint("TOPLEFT", panel.heading, "BOTTOMLEFT", 0, -4)
        panel:SetScript("OnClick", function(button)
            if InCombatLockdown and InCombatLockdown() then return end
            local target = button.achievementID
            self:HideAchievementNotice()
            self:ShowAchievement(target)
            self:ShowNextAchievementNotice()
        end)
        panel:SetScript("OnHide", function(button) button:SetScript("OnUpdate", nil); button.glow:SetAlpha(0) end)
        self.achievementNotice = panel
    end
    panel.heading:SetText(self:LocalizedText("achievement.notice.earned"))
    panel.icon:SetTexture(self.achievementTextures[definition.id])
    panel.title:SetText(self:GetAchievementDisplayText(definition,"title"))
    local textWidth = panel:GetWidth() - 106
    panel.heading:SetWidth(textWidth); panel.title:SetWidth(textWidth)
    local headingHeight = math.ceil(panel.heading:GetStringHeight())
    local titleHeight = math.ceil(panel.title:GetStringHeight())
    panel.heading:SetHeight(headingHeight); panel.title:SetHeight(titleHeight)
    local textHeight = headingHeight + 4 + titleHeight
    panel.textBlock:SetSize(textWidth, textHeight)
    panel:SetHeight(math.max(80, textHeight + 32))
    panel.glow:SetAlpha(0.28)
    panel.achievementID, panel.elapsed, panel.fadeComplete = id, 0, nil
    PositionAchievementNotice(self, panel)
    panel:SetFrameStrata("FULLSCREEN")
    panel:SetAlpha(0)
    panel:SetScript("OnUpdate", function(button, elapsed)
        button.elapsed = button.elapsed + elapsed
        if InCombatLockdown and InCombatLockdown() then
            self:HideAchievementNotice()
        elseif button.fadeComplete then
            self:HideAchievementNotice()
            self:ShowNextAchievementNotice()
        elseif button.elapsed >= 5 then
            -- Render one fully transparent frame before reusing this button.
            -- The next award starts on a later update with its own clock.
            button:SetAlpha(0); button.glow:SetAlpha(0)
            button.fadeComplete = true
        else
            PositionAchievementNotice(self, button)
            button:SetAlpha(math.min(1, button.elapsed / 0.25, (5 - button.elapsed) / 0.6))
            button.glow:SetAlpha(0.28 * math.max(0, 1 - button.elapsed / 0.9))
        end
    end)
    panel:Show()
    if self.RefreshFishingLayer then self:RefreshFishingLayer() end
end

function FF:SuspendAchievementNoticeForScan()
    local panel = self.achievementNotice
    if not panel or not panel:IsShown() or not (self.IsCameraSearchPending and self:IsCameraSearchPending()) then return end
    local id = not panel.fadeComplete and panel.achievementID
    self:HideAchievementNotice()
    if id then
        self.achievementNoticeQueue = self.achievementNoticeQueue or {}
        table.insert(self.achievementNoticeQueue, 1, id)
    end
end

function FF:EnsureCatchRecapPanel()
    if self.catchRecapPanel then return self.catchRecapPanel end
    local panel = CreateFrame("Frame", nil, self:EnsureFishingVisibilityRoot())
    panel:SetSize(WIDTH, 48)
    self.catchRecapPanel = panel
    self:PositionCatchRecap()
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(frame)
        if InCombatLockdown and InCombatLockdown() then return end
        frame.moving = true
        frame:StartMoving()
    end)
    panel:SetScript("OnDragStop", function(frame)
        if frame.moving ~= true then return end
        frame:StopMovingOrSizing()
        frame.moving = nil
        SavePosition(self, frame)
        self.catchRecapElapsed = 0
    end)
    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(panel)
    background:SetColorTexture(0.09, 0.19, 0.23, 0.97)
    local border = CreateFrame("Frame", nil, panel, BackdropTemplateMixin and "BackdropTemplate" or nil)
    border:SetPoint("TOPLEFT", panel, "TOPLEFT", -4, 4)
    border:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 4, -4)
    border:EnableMouse(false)
    if border.SetBackdrop then
        border:SetBackdrop({ edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", edgeSize = 18 })
        border:SetBackdropBorderColor(0.95, 0.76, 0.43, 0.95)
    end
    panel.headerRule=AddSolid(panel, { "TOPLEFT", panel, "TOPLEFT", 8, -28 }, WIDTH - 16, 1, 0.28, 0.70, 0.78, 0.55)
    AddSolid(panel, { "TOPLEFT", panel, "TOPLEFT", 8, -8 }, 2, 14, 0.18, 0.78, 0.82, 0.95)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 17, -9)
    title:SetText(self:LocalizedText("journal.chrome.recap"))
    panel.title=title
    title:SetTextColor(1, 0.84, 0.52)
    panel.rows = {}
    panel:Hide()
    return panel
end

local function EnsureRow(panel, index)
    local row = panel.rows[index]
    if row then return row end
    row = CreateFrame("Frame", nil, panel)
    row:SetSize(WIDTH - 24, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -29 - (index - 1) * ROW_HEIGHT)
    row:EnableMouse(false)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(25, 25)
    icon:SetPoint("LEFT", row, "LEFT", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local iconBorder = row:CreateTexture(nil, "OVERLAY")
    iconBorder:SetSize(43, 43)
    iconBorder:SetPoint("CENTER", icon, "CENTER")
    iconBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    name:SetWidth(WIDTH - 91)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    local quantity = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quantity:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    quantity:SetTextColor(0.95, 0.80, 0.46)
    row.icon, row.name, row.quantity = icon, name, quantity
    panel.rows[index] = row
    return row
end

function FF:ShowCatchRecap(updates, cast)
    if not (self.db and self.db.catchRecap and self.bar and self.bar:IsShown())
        or not cast or not updates or #updates == 0 then return end
    self.catchRecapRevision = (self.catchRecapRevision or 0) + 1
    local revision, db, bar = self.catchRecapRevision, self.db, self.bar
    if self.catchRecapCast ~= cast or type(self.catchRecapItems) ~= "table" then
        self.catchRecapCast = cast
        self.catchRecapItems = {}
    end
    local items = self.catchRecapItems
    local function Current()
        return self.catchRecapRevision == revision and self.catchRecapCast == cast and self.catchRecapItems == items
            and self.db == db and self.bar == bar and db.catchRecap and bar:IsShown()
    end
    -- Rebuild from the existing qualified cast totals, including after display
    -- expiry. This is a view of Statistics facts, never another loot counter.
    local totals = type(cast.slots) == "table" and cast.slots or nil
    if totals then
        for id, amount in pairs(totals) do
            if RecapCount(id) > 0 and RecapCount(amount) > 0 then
                local item = items[id] or {id=id}
                item.count = amount
                local entry = db.journal and db.journal[id]
                item.name = item.name or entry and entry.name
                items[id] = item
            end
        end
    end
    for _, update in ipairs(updates) do
        local item = items[update.id]
        if not item then
            item = { id = update.id, count = 0 }
            items[update.id] = item
        end
        local total = totals and RecapCount(totals[update.id]) or 0
        item.count = total > 0 and total or item.count + RecapCount(update.amount)
        item.name = update.name or item.name
        item.icon = update.icon or item.icon
    end
    local ordered = {}
    for _, item in pairs(items) do ordered[#ordered + 1] = item end
    table.sort(ordered, function(a, b) return a.id < b.id end)
    local panel = self:EnsureCatchRecapPanel()
    if not Current() then return end
    local header=29
    if self:GetResolvedLocale()~="enUS" then
        panel.title:SetText(self:LocalizedText("journal.chrome.recap"));panel.title:SetWidth(WIDTH-34);panel.title:SetWordWrap(true)
        header=math.max(29,math.ceil(panel.title:GetStringHeight())+15)
        panel.headerRule:ClearAllPoints();panel.headerRule:SetPoint("TOPLEFT",panel,"TOPLEFT",8,1-header)
    end
    local height = header+8 + #ordered * ROW_HEIGHT
    panel:SetHeight(height)
    for index, item in ipairs(ordered) do
        local row = EnsureRow(panel, index)
        if self:GetResolvedLocale()~="enUS" then row:ClearAllPoints();row:SetPoint("TOPLEFT",panel,"TOPLEFT",12,-header-(index-1)*ROW_HEIGHT) end
        local name, quality = RecapItemInfo(item.id)
        if not Current() then return end
        local icon = ItemIcon(item.id, item.icon)
        if not Current() then return end
        row.itemID = item.id
        row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        if not icon and not item.iconRequested and C_Item and C_Item.RequestLoadItemDataByID then
            item.iconRequested = true
            pcall(C_Item.RequestLoadItemDataByID, item.id)
            if not Current() then return end
        end
        local displayName = PlainRecapFact(item.name) and type(item.name) == "string" and item.name ~= "" and item.name or name
        row.name:SetText(displayName or self:LocalizedText("common.item-id",item.id))
        local r, g, b = RecapQualityRGB(quality)
        if not Current() then return end
        -- Only numeric RGB, never the quality API's fourth colour-string return.
        row.name:SetTextColor(r, g, b)
        row.quantity:SetText(item.count > 1 and ("×" .. item.count) or "")
        row:Show()
    end
    for index = #ordered + 1, #panel.rows do panel.rows[index]:Hide() end
    self.catchRecapElapsed = 0
    panel:SetAlpha(1)
    panel:SetScript("OnUpdate", function(_, elapsed)
        if not Current() then return end
        if panel.moving == true or panel:IsMouseOver() then
            if FF.catchRecapElapsed > DURATION - FADE_DURATION then
                FF.catchRecapElapsed = DURATION - FADE_DURATION
                panel:SetAlpha(1)
            end
            return
        end
        FF.catchRecapElapsed = FF.catchRecapElapsed + elapsed
        if FF.catchRecapElapsed >= DURATION then
            FF:HideCatchRecap(true)
        elseif FF.catchRecapElapsed > DURATION - FADE_DURATION then
            panel:SetAlpha((DURATION - FF.catchRecapElapsed) / FADE_DURATION)
        end
    end)
    panel:Show()
    self:RefreshFishingLayer()
end

function FF:RefreshCatchRecapItem(itemID)
    local panel = self.catchRecapPanel
    if not panel or not panel:IsShown() or not (self.db and self.db.catchRecap and self.bar and self.bar:IsShown()) then return end
    local revision, cast, items, db, bar = self.catchRecapRevision, self.catchRecapCast, self.catchRecapItems, self.db, self.bar
    local function Current(row)
        return self.catchRecapRevision == revision and self.catchRecapCast == cast and self.catchRecapItems == items
            and self.db == db and self.bar == bar and db.catchRecap and bar:IsShown()
            and self.catchRecapPanel == panel and panel:IsShown() and row.itemID == itemID and row:IsShown()
    end
    for _, row in ipairs(panel.rows) do
        if row.itemID == itemID and row:IsShown() then
            local item = self.catchRecapItems and self.catchRecapItems[itemID]
            local icon = ItemIcon(itemID, item and item.icon)
            if not Current(row) then return end
            local name, quality = RecapItemInfo(itemID)
            if not Current(row) then return end
            local r, g, b = RecapQualityRGB(quality)
            if not Current(row) then return end
            if icon then row.icon:SetTexture(icon) end
            if name then row.name:SetText(name) end
            row.name:SetTextColor(r, g, b)
            break
        end
    end
end
