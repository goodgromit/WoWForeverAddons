-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = ForeverFishing
local NAME = "ForeverFishing"
local events = CreateFrame("Frame")

local function Finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function DirectionAngle(x, y)
    x, y = tonumber(x), tonumber(y)
    if not Finite(x) or not Finite(y) then return end
    local magnitude = math.max(math.abs(x), math.abs(y))
    if magnitude == 0 then return end
    return math.deg(math.atan2(y / magnitude, x / magnitude)) % 360
end

function FF:GetMinimapIconSettings()
    local db = self.db
    if not db then return end
    if type(db.minimapIcon) ~= "table" then db.minimapIcon = {} end
    local settings = db.minimapIcon
    local legacy = type(db.launcher) == "table" and db.launcher or {}
    -- A valid standard-library position is already authoritative. Legacy data
    -- remains untouched and is consulted only when there is no valid angle.
    if not Finite(settings.minimapPos) then
        settings.minimapPos = DirectionAngle(legacy.iconX, legacy.iconY)
            or DirectionAngle(legacy.familyX, legacy.familyY) or 245
    end
    if type(db.showMinimapIcon) ~= "boolean" then
        db.showMinimapIcon = not (settings.hide == true or legacy.iconHidden == true)
    end
    settings.hide = db.showMinimapIcon == false
    return settings
end

function FF:StyleFishingMinimapArtwork(button)
    if not button or button:GetParent() ~= Minimap then return end
    if InCombatLockdown and InCombatLockdown() then
        self.minimapArtworkPending = {db=self.db,button=button}
        events:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local border, background
    for _, region in ipairs({button:GetRegions()}) do
        local texture = region.GetTexture and region:GetTexture()
        if texture == 136430 or texture == "Interface\\Minimap\\MiniMap-TrackingBorder" then border = region end
        if texture == 136467 or texture == "Interface\\Minimap\\UI-Minimap-Background" then background = region end
    end
    local icon = button.icon
    if border and icon then
        -- Preserve the accepted 22px full round art, aligned to the visible
        -- ring's centre inside its padded 64px native texture.
        icon:SetSize(22,22)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER",border,"TOPLEFT",border:GetWidth()*20/64,-border:GetHeight()*19/64)
        if background then
            background:ClearAllPoints()
            background:SetPoint("CENTER",icon,"CENTER")
        end
    end
end

local function ShowTooltip(button)
    if not GameTooltip then return end
    GameTooltip:SetOwner(button,"ANCHOR_LEFT")
    GameTooltip:SetText("Forever Fishing",1,0.82,0)
    GameTooltip:AddLine(FF:LocalizedText("minimap.open"),0.85,0.85,0.85)
    GameTooltip:AddLine(FF:LocalizedText("minimap.settings"),0.85,0.85,0.85)
    GameTooltip:AddLine(FF:LocalizedText("runtime.close-combat"),0.85,0.85,0.85)
    if not FF.fishingStartupFailed then
        for _, line in ipairs(FF:GetFishingMinimapSnapshot()) do GameTooltip:AddLine(line,0.94,0.9,0.77,true) end
    end
    GameTooltip:Show()
end

function FF:HandleMinimapClick(mouseButton)
    if mouseButton == "RightButton" then self:ShowSettings()
    elseif mouseButton == "LeftButton" then self:ToggleMainWindow(true) end
end

function FF:InitializeMinimapIcon()
    if not self.db or self.fishingMinimapStartupFailed then return false end
    if self.minimapLibrary and self.minimapIconDB == self.db then return true end
    local broker = LibStub and LibStub("LibDataBroker-1.1",true)
    local library = LibStub and LibStub("LibDBIcon-1.0",true)
    if not broker or not library or broker:GetDataObjectByName(NAME) or library:IsRegistered(NAME) then
        self:Print(self:LocalizedText("runtime.minimap-unavailable"))
        return false
    end
    local settings = self:GetMinimapIconSettings()
    self.minimapDataObject = broker:NewDataObject(NAME,{
        type="launcher",text="Forever Fishing",label="Forever Fishing",icon=self.roundIcon,
        -- LibDBIcon trims 5% while released. These supported coordinates keep
        -- the full round artwork visible at rest and retain its press effect.
        iconCoords={-1/18,19/18,-1/18,19/18},
        OnClick=function(_,mouseButton) FF:HandleMinimapClick(mouseButton) end,
        OnEnter=ShowTooltip,
        OnLeave=function() if GameTooltip then GameTooltip:Hide() end end,
    })
    self.minimapLibrary,self.minimapIconDB = library,self.db
    library:Register(NAME,self.minimapDataObject,settings)
    -- Keep Blizzard's addon list available independently of icon visibility.
    if settings.showInCompartment ~= false then library:AddButtonToCompartment(NAME) end
    self:StyleFishingMinimapArtwork(library:GetMinimapButton(NAME))
    return self:SyncMinimapIconVisibility()
end

function FF:SyncMinimapIconVisibility()
    if self.fishingMinimapStartupFailed then return false end
    local library = self.minimapLibrary
    if not self.db or self.minimapIconDB ~= self.db or not library or not library:IsRegistered(NAME) then return false end
    local shown = self.db.showMinimapIcon ~= false
    self.db.minimapIcon.hide = not shown
    -- Some library revisions reposition on Show. An adopted frame belongs to
    -- its manager; native Show retains manager hooks without resetting anchors.
    local button = library:GetMinimapButton(NAME)
    if shown and button and button:GetParent() ~= Minimap then button:Show()
    elseif shown then library:Show(NAME)
    else library:Hide(NAME) end
    return true
end

function FF:SetMinimapIconShown(shown)
    if not self.db then return false end
    self.db.showMinimapIcon = shown == true
    local applied = self.minimapLibrary and self:SyncMinimapIconVisibility() or self:InitializeMinimapIcon()
    local control = self.settingsPanel and self.settingsPanel.minimapIconButton
    if control then control:SetState(self.db.showMinimapIcon) end
    return applied
end

events:SetScript("OnEvent",function()
    events:UnregisterEvent("PLAYER_REGEN_ENABLED")
    local pending = FF.minimapArtworkPending
    FF.minimapArtworkPending = nil
    if pending and pending.db == FF.db and FF.minimapLibrary
        and FF.minimapLibrary:GetMinimapButton(NAME) == pending.button then FF:StyleFishingMinimapArtwork(pending.button) end
end)
