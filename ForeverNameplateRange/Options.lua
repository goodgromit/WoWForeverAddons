local _, ns = ...
local panel, icon, enabled, controls, syncing = nil, nil, nil, {}, false

local function Text(frame, value, x, y, template)
    local label = frame:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(value)
    return label
end

local function PositionIcon()
    if not icon then return end
    local db = ns.GetSettings()
    local angle = db and db.minimapAngle or math.rad(190)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", Minimap, "CENTER", 
        math.cos(angle) * (Minimap:GetWidth() / 2 + 10),
        math.sin(angle) * (Minimap:GetHeight() / 2 + 10))
end

local function Sync()
    syncing = true
    local db = ns.GetSettings()
    if not db then syncing = false; return end

    if enabled then enabled:SetChecked(db.enabled) end
    if panel and panel.reference and ns.ReferenceName then
        panel.reference:SetText(ns.ReferenceName())
    end

    for key, control in pairs(controls) do
        if db[key] ~= nil then
            control.box:SetText(tostring(db[key]))
            control.slider:SetValue(db[key])
        end
    end
    syncing = false
end

local function SetOffset(key, value, minimum, maximum)
    if syncing then return end
    local number = tonumber(value)
    if not number or number ~= number or number < minimum or number > maximum then
        if panel and panel.status then
            panel.status:SetText(string.format("%s: %d~%d 사이의 숫자를 입력하세요.", key:upper(), minimum, maximum))
        end
        Sync()
        return
    end

    local db = ns.GetSettings()
    if db then
        db[key] = math.floor(number + 0.5)
        ns.ApplySettings()
        Sync()
        if panel and panel.status then
            panel.status:SetText("적용 완료 · 설정 저장됨")
        end
    end
end

local function Build()
    panel = CreateFrame("Frame", "ForeverNameplateRangeOptions", UIParent, "BackdropTemplate")
    panel:SetSize(420, 560) -- 크기 슬라이더 추가에 맞춰 세로 높이 확장
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetMovable(true)

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.025, 0.022, 0.018, 0.97)

    panel:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropBorderColor(0.65, 0.59, 0.45, 1)

    local title = CreateFrame("Frame", nil, panel)
    title:SetPoint("TOPLEFT", 5, -5)
    title:SetPoint("TOPRIGHT", -5, -5)
    title:SetHeight(35)
    title:EnableMouse(true)
    title:RegisterForDrag("LeftButton")

    local black = title:CreateTexture(nil, "BACKGROUND")
    black:SetAllPoints()
    black:SetColorTexture(0, 0, 0, 1)

    Text(title, "대상 이름표 거리 표시", 12, -10, "GameFontNormal")
    title:SetScript("OnDragStart", function() panel:StartMoving() end)
    title:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)

    enabled = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    enabled:SetPoint("TOPLEFT", 18, -45)
    Text(panel, "선택한 적에게만 거리 표시", 52, -54)
    enabled:SetScript("OnClick", function(self)
        local db = ns.GetSettings()
        if db then
            db.enabled = not not self:GetChecked()
            ns.ApplySettings()
        end
    end)

    Text(panel, "기준: 체력바 왼쪽 중앙 ↔ 거리 글자의 오른쪽 끝", 24, -84)

    -- 슬라이더 및 입력창 공용 생성 함수
    local function CreateControlRow(key, y, minimum, maximum, caption)
        Text(panel, caption, 24, y, "GameFontNormal")
        local box = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetSize(72, 24)
        box:SetPoint("TOPLEFT", 320, y + 6)
        box:SetAutoFocus(false)
        box:SetMaxLetters(7)

        local slider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", 30, y - 28)
        slider:SetSize(356, 18)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(minimum, maximum)
        slider:SetValueStep(1)
        if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
        if slider.Low then slider.Low:SetText(tostring(minimum)) end
        if slider.High then slider.High:SetText(tostring(maximum)) end
        if slider.Text then slider.Text:SetText("") end

        controls[key] = { box = box, slider = slider }
        slider:SetScript("OnValueChanged", function(_, value) SetOffset(key, value, minimum, maximum) end)

        local function Commit(self) SetOffset(key, self:GetText(), minimum, maximum) end
        box:SetScript("OnEnterPressed", function(self) Commit(self); self:ClearFocus() end)
        box:SetScript("OnEditFocusLost", Commit)
        box:SetScript("OnEscapePressed", function(self) Sync(); self:ClearFocus() end)
    end

    -- 1. 글씨 크기 (size: 8 ~ 24)
    CreateControlRow("size", -114, 8, 24, "글씨 크기 (기본값: 12)")

    -- 2. X 좌표 오프셋 (x: -200 ~ 100)
    CreateControlRow("x", -184, -200, 100, "X 위치  ·  음수는 왼쪽 / 양수는 오른쪽")

    -- 3. Y 좌표 오프셋 (y: -150 ~ 150)
    CreateControlRow("y", -254, -150, 150, "Y 위치  ·  음수는 아래 / 양수는 위")

    panel.status = Text(panel, "변경 즉시 적용 · 캐릭터 공통 자동 저장", 24, -330)
    panel.status:SetTextColor(0.85, 0.77, 0.58)

    panel.reference = Text(panel, "", 24, -360, "GameFontNormal")
    panel.reference:SetWidth(370)
    panel.reference:SetJustifyH("LEFT")

    Text(panel, "빨강: 멀리 있음 · 주황: 너무 가까움 · 회색: 판별 불가", 24, -446)

    local function Button(text, x, callback, y)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetPoint("TOPLEFT", x, y)
        button:SetSize(170, 26)
        button:SetText(text)
        button:SetScript("OnClick", callback)
    end

    Button("다음 기준 기술", 24, function() ns.CycleReference(false); Sync() end, -400)
    Button("직업 자동 선택", 226, function() ns.CycleReference(true); Sync() end, -400)

    Button("기본값 복원", 24, function()
        local db = ns.GetSettings()
        if db then
            db.size = 12
            db.x = -8
            db.y = 0
            Sync()
            ns.ApplySettings()
        end
    end, -490)

    Button("닫기", 226, function() panel:Hide() end, -490)

    panel:SetScript("OnHide", function()
        panel:StopMovingOrSizing()
        for _, control in pairs(controls) do control.box:ClearFocus() end
    end)

    table.insert(UISpecialFrames, "ForeverNameplateRangeOptions")
    panel:Hide()
end

function ns.ToggleOptions()
    if not ns.GetSettings() then return end
    if not panel then Build() end
    if panel:IsShown() then
        panel:Hide()
    else
        Sync()
        panel:Show()
    end
end

function ns.InitOptions()
    if icon or not Minimap or not ns.GetSettings() then return end
    icon = CreateFrame("Button", "ForeverNameplateRangeMinimapButton", Minimap)
    icon:SetSize(32, 32)
    icon:SetFrameStrata("MEDIUM")
    icon:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    icon:RegisterForClicks("LeftButtonUp")
    icon:RegisterForDrag("LeftButton")

    local texture = icon:CreateTexture(nil, "ARTWORK")
    texture:SetSize(20, 20)
    texture:SetPoint("CENTER")
    texture:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")

    local border = icon:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    icon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    icon:SetScript("OnMouseDown", function(self) self.dragged = false end)
    icon:SetScript("OnClick", function(self) if not self.dragged then ns.ToggleOptions() end end)

    local function Drag()
        local x, y = GetCursorPosition()
        local cx, cy = Minimap:GetCenter()
        if not cx or not cy then return end
        local scale = Minimap:GetEffectiveScale()
        local db = ns.GetSettings()
        if db then
            db.minimapAngle = math.atan2(y / scale - cy, x / scale - cx)
            PositionIcon()
        end
    end

    icon:SetScript("OnDragStart", function(self)
        self.dragged = true
        self:SetScript("OnUpdate", Drag)
        Drag()
    end)
    icon:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        Drag()
        ns.ApplySettings()
    end)
    icon:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)

    PositionIcon()
end