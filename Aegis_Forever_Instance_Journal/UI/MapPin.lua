local _, ns = ...
local L = ns.L

--[[
	"Show Start" and "Show End": the world map opened on the player's own zone, the spot marked on it
	with the journal's pin where that map shows the spot, and the client's own waypoint offered in the
	chat as its map pin link, which sets the waypoint and opens the map on it (MapPin:Mark;
	UI/DungeonMap.lua's SetWaypointAt says why the journal never sets the waypoint itself). Once set,
	the waypoint shows on the map, the minimap and in the world as one set by hand does.

	Where the client allows no waypoint on that map, the journal's pin alone (MapPin:Show), with the
	place named in its tooltip. That pin sits on the map's canvas, so it moves and zooms with the map,
	and it shows on whichever map shows the spot (its zone, the continent).

	The journal opens the map only on the player's own map and never turns it to another
	(UI/DungeonMap.lua, the rule above OpenWorld): the player browses to the spot's zone.

	Where the client allows a waypoint the buttons are that link themselves, over their whole face
	(UI/QuestsPanel.lua's link faces), so a click on a button is the click on the link: the client sets
	the waypoint and opens the map on it, and nothing is said in the chat. The above is for a button
	with no face.
]]

local MapPin = {}
ns.MapPin = MapPin

local PIN_ATLAS = "Waypoint-MapPin-Tracked"
local PIN_SIZE = 32

local pin, target, hooked

local function Canvas()
	if not WorldMapFrame then return nil end
	if WorldMapFrame.GetCanvas then
		local ok, canvas = pcall(WorldMapFrame.GetCanvas, WorldMapFrame)
		if ok and canvas then return canvas end
	end
	return WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child or nil
end

local function ShownMapID()
	if not (WorldMapFrame and WorldMapFrame.GetMapID) then return nil end
	local ok, mapID = pcall(WorldMapFrame.GetMapID, WorldMapFrame)
	return ok and mapID or nil
end

-- The target's place on the map shown: its own zone's, or one above it (UI/DungeonMap.lua's PositionOn).
local function PlaceOnShown()
	local shown = ShownMapID()
	if not shown then return nil end
	if shown == target.mapID then return target.x, target.y end
	return ns.DungeonMap:PositionOn(target, shown)
end

function MapPin:Update()
	if not pin or not target then return end
	local canvas = pin:GetParent()
	local x, y = PlaceOnShown()
	pin:SetShown(x ~= nil)
	if x then
		pin:ClearAllPoints()
		pin:SetPoint("CENTER", canvas, "TOPLEFT", x * canvas:GetWidth(), -y * canvas:GetHeight())
	end
end

local function EnsurePin()
	local canvas = Canvas()
	if not canvas then return nil end
	if not pin then
		pin = CreateFrame("Button", nil, canvas)
		pin:SetSize(PIN_SIZE, PIN_SIZE)
		pin.Icon = pin:CreateTexture(nil, "OVERLAY")
		pin.Icon:SetAllPoints()
		pin.Icon:SetAtlas(PIN_ATLAS)
		pin:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(target and target.title or "", 1, 0.82, 0)
			if target and target.label then GameTooltip:AddLine(target.label, 1, 1, 1, true) end
			GameTooltip:AddLine(L.MAP_PIN_CLEAR, 0.5, 0.8, 1)
			GameTooltip:Show()
		end)
		pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
		pin:SetScript("OnClick", function() MapPin:Clear() end)
	end
	pin:SetFrameLevel(canvas:GetFrameLevel() + 2000)

	if not hooked then
		hooked = true
		-- Follow the map as the player browses it.
		if WorldMapFrame.OnMapChanged then
			hooksecurefunc(WorldMapFrame, "OnMapChanged", function() MapPin:Update() end)
		end
		WorldMapFrame:HookScript("OnShow", function() MapPin:Update() end)
	end
	return pin
end

-- The name of a point's zone, for the chat.
local function ZoneName(mapID)
	local info = ns.DungeonMap:MapInfo(mapID)
	return info and info.name or nil
end

-- Says where a point is, when the map shows another zone.
local function SayWhere(mapID, title)
	local zone = ZoneName(mapID)
	if zone and ShownMapID() ~= mapID then ns.Print(string.format(L.MAP_PIN_IN_ZONE, title or "", zone)) end
end

-- Whether the client allows its own waypoint on a map.
local function CanWaypoint(mapID)
	if not (C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.GetUserWaypoint) then return false end
	local ok, allowed = pcall(C_Map.CanSetUserWaypointOnMap, mapID)
	return ok and allowed == true
end

-- Shows a point { mapID, x, y, label } on the world map with the journal's own pin, titled `title`.
function MapPin:Show(point, title)
	if not point or not point.mapID then return false end
	if InCombatLockdown() then
		ns.Print(L.MAP_PIN_COMBAT)
		return false
	end
	target = { mapID = point.mapID, x = point.x or 0.5, y = point.y or 0.5, label = point.label, title = title }
	if not ns.DungeonMap:OpenWorld() then return false end
	if EnsurePin() then self:Update() end
	SayWhere(point.mapID, title)
	return true
end

-- The journal's pin on a point of the map that is open, opening nothing (in combat too): the target set,
-- which UI/DungeonMap.lua keeps to know its pin later (a waypoint offered, standing in for it).
function MapPin:Put(point, title)
	target = { mapID = point.mapID, x = point.x or 0.5, y = point.y or 0.5, label = point.label, title = title }
	if EnsurePin() then self:Update() end
	return target
end

-- Opens the map on the player's own zone with the point marked where it shows, and offers the client's
-- waypoint on it in the chat, which once set is named with the point's zone; the journal's
-- own pin alone where the map allows no waypoint.
function MapPin:Mark(point, title)
	if not point or not point.mapID then return false end
	if InCombatLockdown() then
		ns.Print(L.MAP_PIN_COMBAT)
		return false
	end
	if not CanWaypoint(point.mapID) then return self:Show(point, title) end
	self:Clear()
	ns.DungeonMap:OpenWorld()
	local zone = ZoneName(point.mapID)
	ns.DungeonMap:SetWaypointAt(point.mapID, point.x or 0.5, point.y or 0.5, title,
		zone and string.format(L.QUESTMAP_WAYPOINT_SET_IN, title, zone) or string.format(L.QUESTMAP_WAYPOINT_SET, title))
	return true
end

function MapPin:Clear()
	target = nil
	if pin then pin:Hide() end
end

function MapPin:Target()
	return target
end

-- The pin itself, once made, for the smoke test.
function MapPin:Frame()
	return pin
end
