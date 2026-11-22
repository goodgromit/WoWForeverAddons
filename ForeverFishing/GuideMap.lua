-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

local pin = {}
if MapCanvasPinMixin and CreateFromMixins then pin = CreateFromMixins(MapCanvasPinMixin) end
ForeverFishingGuideMapPinMixin = pin

function pin:OnAcquired(target)
    self.target = target
    -- A single selected Journal location must remain readable on detailed maps
    -- as well as continents, including when this pin is reused from the pool.
    if self.UseFrameLevelType then self:UseFrameLevelType("PIN_FRAME_LEVEL_TOPMOST") end
    if self.SetScalingLimits then self:SetScalingLimits(1, 1, 1) end
    if self.SetAlphaLimits then self:SetAlphaLimits(nil, nil, nil) end
    if self.SetAlpha then self:SetAlpha(1) end
    if self.SetPosition then
        self:SetPosition(target.x, target.y)
    else
        MapCanvasPinMixin.SetPosition(self, target.x, target.y)
    end
end

function pin:OnReleased()
    self.target = nil
    if MapCanvasPinMixin and MapCanvasPinMixin.OnReleased then MapCanvasPinMixin.OnReleased(self) end
end

function pin:OnMouseEnter()
    if not self.target then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(FF:GetGuideMapLabel(self.target), 1, 0.82, 0.45)
    GameTooltip:AddLine(FF:FormatCoordinateDisplay((self.target.zoneX or self.target.x) * 100,
        (self.target.zoneY or self.target.y) * 100), 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

function pin:OnMouseLeave()
    GameTooltip:Hide()
end

local function ParentMapID(mapID)
    if not (C_Map and C_Map.GetMapInfo) then return nil end
    local info = C_Map.GetMapInfo(mapID)
    return info and info.parentMapID and info.parentMapID > 0 and info.parentMapID or nil
end

local function Finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function OnMap(x, y)
    return Finite(x) and Finite(y) and x >= 0 and x <= 1 and y >= 0 and y <= 1
end

local function MapRect(mapID, topMapID)
    if not (C_Map and C_Map.GetMapRectOnMap) then return nil end
    local ok, minX, maxX, minY, maxY = pcall(C_Map.GetMapRectOnMap, mapID, topMapID)
    if not ok or not Finite(minX) or not Finite(maxX) or not Finite(minY) or not Finite(maxY)
        or maxX <= minX or maxY <= minY then return nil end
    return minX, maxX, minY, maxY
end

local function RectPosition(mapID, topMapID, x, y)
    local minX, maxX, minY, maxY = MapRect(mapID, topMapID)
    if not minX then return nil end
    return minX + (maxX - minX) * x, minY + (maxY - minY) * y
end

local function ProjectPoint(target, mapID)
    if target.mapID == mapID then return target end
    local x, y = RectPosition(target.mapID, mapID, target.x, target.y)
    if not OnMap(x, y) then x, y = nil, nil end
    if not x and C_Map and C_Map.GetWorldPosFromMapPos and C_Map.GetMapPosFromWorldPos then
        local position = CreateVector2D and CreateVector2D(target.x, target.y) or {x=target.x,y=target.y}
        local worldOK, continentID, worldPosition = pcall(C_Map.GetWorldPosFromMapPos,
            target.mapID, position)
        if worldOK and continentID and worldPosition then
            local mapOK, projectedMapID, position = pcall(C_Map.GetMapPosFromWorldPos,
                continentID, worldPosition, mapID)
            if mapOK and projectedMapID == mapID and position then
                if position.GetXY then x, y = position:GetXY() else x, y = position.x, position.y end
                if not OnMap(x, y) then x, y = nil, nil end
            end
        end
    end
    -- Some city/overlapping maps lack a world-position override. Invert their
    -- verified rectangle on the source map, rather than treating zone coords
    -- as city coords or showing a fabricated point when projection is absent.
    if not x then
        local minX, maxX, minY, maxY = MapRect(mapID, target.mapID)
        if minX then
            x, y = (target.x-minX)/(maxX-minX), (target.y-minY)/(maxY-minY)
            if not OnMap(x, y) then x, y = nil, nil end
        end
    end
    if not x then
        local child, seen = target.mapID, {}
        x, y = target.x, target.y
        while child and child ~= mapID and not seen[child] do
            seen[child] = true
            local parent = ParentMapID(child)
            if not parent then return nil end
            x, y = RectPosition(child, parent, x, y)
            if not x then return nil end
            child = parent
        end
        if child ~= mapID then return nil end
    end
    if not OnMap(x, y) then return nil end
    return { label = target.label, mapID = target.mapID, x = x, y = y,
        zoneX = target.x, zoneY = target.y }
end

local map = { registered = false }
function map:Register()
    if self.registered then return true end
    if not (WorldMapFrame and WorldMapFrame.AddDataProvider
        and MapCanvasDataProviderMixin and MapCanvasPinMixin and CreateFromMixins) then return false end
    if not pin.SetPosition then
        for key, value in pairs(MapCanvasPinMixin) do
            if pin[key] == nil then pin[key] = value end
        end
    end
    local provider = CreateFromMixins(MapCanvasDataProviderMixin)
    function provider:RefreshAllData()
        local canvas = self:GetMap()
        if not canvas then return end
        canvas:RemoveAllPinsByTemplate("ForeverFishingGuideMapPinTemplate")
        if map.target then
            local mapID = canvas:GetMapID()
            local projected = ProjectPoint(map.target, mapID)
            if projected then canvas:AcquirePin("ForeverFishingGuideMapPinTemplate", projected) end
        end
    end
    function provider:OnMapChanged()
        self:RefreshAllData()
    end
    self.provider = provider
    WorldMapFrame:AddDataProvider(provider)
    if WorldMapFrame.HookScript then
        WorldMapFrame:HookScript("OnHide", function()
            map.target = nil
            provider:RefreshAllData()
            if FF.ScheduleFishingTemporaryPanelSync then FF:ScheduleFishingTemporaryPanelSync() end
        end)
    end
    self.registered = true
    return true
end

function FF:OpenGuideMapPoint(target)
    if not (target and target.mapID and target.x and target.y) then return end
    if self.RevealFishingUIForTemporaryPanel then self:RevealFishingUIForTemporaryPanel() end
    local mapID = target.mapID
    local visible = WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()
    if not visible then
        if OpenWorldMap then
            pcall(OpenWorldMap, mapID)
        elseif ToggleWorldMap then
            pcall(ToggleWorldMap)
        end
    end
    if WorldMapFrame then
        if WorldMapFrame.IsShown and not WorldMapFrame:IsShown() and ShowUIPanel then
            pcall(ShowUIPanel, WorldMapFrame)
        end
        -- Opening can hide/rebuild map panels. Commit after those transitions
        -- so their OnHide cleanup cannot discard the newly selected location.
        map.target = target
        if WorldMapFrame.SetMapID then pcall(WorldMapFrame.SetMapID, WorldMapFrame, mapID) end
        if WorldMapFrame.ResetZoom then WorldMapFrame:ResetZoom() end
    end
    -- Keep the journal underneath the map so it is ready when the map closes.
    if self.InstallBlizzardPanelHooks then self:InstallBlizzardPanelHooks()
    elseif self.RefreshFishingLayer then self:RefreshFishingLayer() end
    if map:Register() then map.provider:RefreshAllData() end
    if self.ScheduleFishingTemporaryPanelSync then self:ScheduleFishingTemporaryPanelSync() end
end
