local _, ns = ...

--[[
	The journal's pins on Blizzard's world map: frames of its own on the map's canvas, never the map's
	own pins (its AcquirePin, RemoveAllPinsByTemplate, RemovePin).

	Those calls of the map's write the map's shared state as they go: MarkCanvasDirty sets the scroll
	frame's currentScale, currentScrollX and currentScrollY to nil, placing or removing a pin marks the
	map's pin nudging dirty, the first pin of a kind makes a pool in the map's pinPools. Called from the
	journal's code, each of those writes carries the journal's taint. The scroll frame's next update reads
	them and goes on writing the canvas's scale from that taint, a turn of the mouse wheel then sets the
	map's zoom target from it, which no closing of the map clears; the next time the map opens, even with
	the M key, the client's own pins are drawn from that taint, and in combat the client refuses their
	SetPassThroughButtons and blames the journal (ADDON_ACTION_BLOCKED), until the next /reload.

	So the journal keeps its pins in pools of its own, and places, scales and stacks them itself from
	what the map reads out (its canvas, scale, zoom and pin frame levels): only its own frames are ever
	written, with one exception: hovering a door, cave, flight, transport or quest pin names it at the
	top of the map through the map's own SetAreaLabel and ClearAreaLabel callbacks (UI/DungeonMap.lua),
	which write the map's label and its record of the events running. Nothing the client protects is
	called from there, and the map's quest pins never read them. A pin's right click is let through to
	the map with SetPassThroughButtons, which the client refuses an addon in combat: so each pin sets it
	once, as it is made, out of combat (PassThrough, below). The journal's data providers still hear the
	map's changes, each in a call of its own (OnMapChanged, OnCanvasScaleChanged, OnCanvasSizeChanged:
	UI/DungeonMap.lua's passes them on here). A pin's clicks are its own: OnMouseClickAction, as on the map's pins.
]]

local CanvasPins = {}
ns.CanvasPins = CanvasPins

-- The journal's pin templates that are buttons (the rest are frames): UI/MapPins.xml.
local BUTTON_TEMPLATES = { AegisJournalBossPinTemplate = true }

-- By template: every pin made (all) and those in use (active), in the order they were handed out.
local pools = {}
-- Pins made in combat: their right click passed to the map once it ends.
local waitingPassThrough = {}

local function Clamp01(value)
	if value < 0 then return 0 end
	if value > 1 then return 1 end
	return value
end

-- The methods every journal pin has over the map pin mixin's: where it sits, its size and its level,
-- all from reading the map, and nothing asked of the map's own pin code.
local Methods = {}
CanvasPins.Methods = Methods

--[[
	The map a pin is on, kept under a name of the journal's own: not the map pins' owningMap, which the
	map's own code reads from whatever frame the mouse is over (MapCanvasMixin:ProcessCursorHandlers), and
	would read as the journal's.
]]
function Methods:GetMap()
	return self.journalMap
end

function Methods:SetPosition(normalizedX, normalizedY)
	self.normalizedX, self.normalizedY = normalizedX, normalizedY
	self:ApplyCurrentPosition()
end

function Methods:GetPosition()
	return self.normalizedX, self.normalizedY
end

-- As MapCanvasMixin:ApplyPinPosition places a pin (with no nudging): its centre on the spot, in the
-- pin's own scale.
function Methods:ApplyCurrentPosition()
	local canvas = self:GetParent()
	local x, y = self.normalizedX, self.normalizedY
	self:ClearAllPoints()
	if not (canvas and x and y) then return end
	local scale = self:GetScale()
	if not scale or scale == 0 then scale = 1 end
	self:SetPoint("CENTER", canvas, "TOPLEFT", canvas:GetWidth() * x / scale, -canvas:GetHeight() * y / scale)
end

-- As MapCanvasPinMixin:ApplyCurrentScale: a steady size on screen, growing a little as the map zooms
-- in (the pin's scaling limits), times the map's pin scale.
function Methods:ApplyCurrentScale()
	local map = self:GetMap()
	if not map then return end
	local scale
	if self.startScale and self.endScale and map.GetCanvasScale and map.GetCanvasZoomPercent then
		local canvasScale = map:GetCanvasScale()
		if canvasScale and canvasScale > 0 then
			local zoom = Clamp01((self.scaleFactor or 1) * (map:GetCanvasZoomPercent() or 0))
			scale = (self.startScale + (self.endScale - self.startScale) * zoom) / canvasScale
		end
	elseif not self.ignoreGlobalPinScale then
		scale = 1
	end
	if scale then
		if not self.ignoreGlobalPinScale and map.GetGlobalPinScale then scale = scale * (map:GetGlobalPinScale() or 1) end
		self:SetScale(scale)
	end
	self:ApplyCurrentPosition()
end

-- The level the map gives pins of this kind (read from its pin frame levels manager).
function Methods:ApplyFrameLevel()
	local map = self:GetMap()
	local manager = map and map.GetPinFrameLevelsManager and map:GetPinFrameLevelsManager()
	if not (manager and manager.GetValidFrameLevel) then return end
	local ok, level = pcall(manager.GetValidFrameLevel, manager, self.pinFrameLevelType or "PIN_FRAME_LEVEL_DEFAULT",
		self.pinFrameLevelIndex)
	if ok and type(level) == "number" then self:SetFrameLevel(level) end
end

-- Never the map's own, which sets SetPassThroughButtons on every call: the client refuses that to an
-- addon in combat. Each pin sets it once, as it is made, out of combat (PassThrough, below).
function Methods:CheckMouseButtonPassthrough() end

-- A click is the pin's own (OnMouseClickAction), as the map's pins hear it.
local function OnMouseUp(pin, button, upInside)
	if upInside == false then return end
	if pin.OnMouseClickAction then pin:OnMouseClickAction(button) end
end

-- A right click on a pin that lets it through goes to the map below, which zooms out: set once, as
-- the pin is made (the client allows it to an addon only out of combat).
local function PassThrough(pin)
	if not pin.SetPassThroughButtons then return end
	if InCombatLockdown() then
		waitingPassThrough[pin] = true
		return
	end
	local through = pin.ShouldMouseButtonBePassthrough and pin:ShouldMouseButtonBePassthrough("RightButton")
	if through then pcall(pin.SetPassThroughButtons, pin, "RightButton") end
end

local combatWatch = CreateFrame("Frame")
combatWatch:SetScript("OnEvent", function()
	for pin in pairs(waitingPassThrough) do
		waitingPassThrough[pin] = nil
		PassThrough(pin)
	end
	ns.UnregisterEvents(combatWatch, "PLAYER_REGEN_ENABLED")
end)

local function Pool(template)
	local pool = pools[template]
	if not pool then
		pool = { all = {}, active = {} }
		pools[template] = pool
	end
	return pool
end

local function Make(map, template)
	local canvas = map:GetCanvas()
	local pin = CreateFrame(BUTTON_TEMPLATES[template] and "Button" or "Frame", nil, canvas, template)
	pin.journalMap = map
	if pin:GetObjectType() == "Button" then pin:SetScript("OnClick", nil) end
	pin:SetScript("OnMouseUp", OnMouseUp)
	pin:SetScript("OnEnter", pin.OnMouseEnter)
	pin:SetScript("OnLeave", pin.OnMouseLeave)
	pin:OnLoad()
	PassThrough(pin)
	if waitingPassThrough[pin] then ns.RegisterEvents(combatWatch, "PLAYER_REGEN_ENABLED") end
	return pin
end

-- A pin of the template on the map's canvas, as the map's AcquirePin hands one out: OnAcquired gets
-- the rest of the arguments.
function CanvasPins:Acquire(map, template, ...)
	local pool = Pool(template)
	local pin
	for _, candidate in ipairs(pool.all) do
		if not candidate.inUse then
			pin = candidate
			break
		end
	end
	if not pin then
		pin = Make(map, template)
		pool.all[#pool.all + 1] = pin
	end
	pin.inUse = true
	pool.active[#pool.active + 1] = pin
	pin:Show()
	pin:OnAcquired(...)
	pin:ApplyFrameLevel()
	pin:ApplyCurrentScale()
	return pin
end

-- Puts away every pin of the template.
function CanvasPins:ReleaseAll(template)
	local pool = pools[template]
	if not pool then return end
	for _, pin in ipairs(pool.active) do
		pin.inUse = false
		pin:Hide()
		pin:ClearAllPoints()
	end
	pool.active = {}
end

-- The pins of the template in use, in the order they were handed out.
function CanvasPins:Active(template)
	local pool = pools[template]
	local list = {}
	for index, pin in ipairs(pool and pool.active or {}) do list[index] = pin end
	return list
end

function CanvasPins:Enumerate(template)
	local list, index = self:Active(template), 0
	return function()
		index = index + 1
		return list[index]
	end
end

local function EachActive(callback)
	for _, pool in pairs(pools) do
		for _, pin in ipairs(pool.active) do callback(pin) end
	end
end

-- The map zoomed: every pin sized again (and so placed again).
function CanvasPins:OnCanvasScaleChanged()
	EachActive(function(pin) pin:ApplyCurrentScale() end)
end

-- The canvas took another size (another map, the map maximized): every pin told, and placed again.
function CanvasPins:OnCanvasSizeChanged()
	EachActive(function(pin)
		if pin.OnCanvasSizeChanged then pin:OnCanvasSizeChanged() end
		pin:ApplyCurrentScale()
	end)
end
