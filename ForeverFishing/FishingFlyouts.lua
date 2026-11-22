-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local LIMITS={size={32,96},spacing={2,20},columns={1,8}}
local DEFAULTS={size=48,spacing=8,columns=5}
local KINDS={gear=true,lure=true,chef=true,utility=true}
local ORDER={"gear","lure","chef","utility"}
local function Number(value,limits,fallback)
    value=tonumber(value)
    if not value or value~=value or value==math.huge or value==-math.huge then return fallback end
    return math.floor(math.max(limits[1],math.min(limits[2],value))+.5)
end
function FF:GetFishingBarLayoutScale()
    local scale=tonumber(self.toolBar and self.toolBar:GetScale() or self.db and self.db.toolsScale)
    if not scale or scale~=scale or scale==math.huge or scale==-math.huge then return 1.006 end
    return math.max(.65,math.min(1.5,scale))
end
function FF:GetFishingFullBarWidth()
    local count=(self.GetFishingBarCategoryCount and self:GetFishingBarCategoryCount() or 5)
    local gap=self.GetIconBarSpacing and self:GetIconBarSpacing() or 8
    return count*48+(count-1)*gap
end
function FF:GetFishingFlyoutLayout(kind)
    local saved=self.db and self.db.flyoutGrid
    local legacy=self.db and self.db.flyoutDefaults
    local values={size=48,spacing=8,columns=5}
    -- Preserve the active shared grid; retired flyoutLayouts/split preferences
    -- stay ignored. Only explicit edits create the small current category table.
    if type(saved)~="table" and type(legacy)=="table" then
        local barScale=self:GetFishingBarLayoutScale()
        local barGap=self.GetIconBarSpacing and self:GetIconBarSpacing() or 8
        local preset=legacy.preset
        local scale=legacy.matchBarScale~=false and barScale or tonumber(legacy.scale) or 1
        local size,spacing
        if preset=="bar" then size,spacing,scale=48,barGap,barScale
        elseif preset=="compact" then size,spacing,scale=40,6,barScale
        else
            local manualSize=legacy.matchBarSize==false or not preset and legacy.size~=nil
            local manualGap=legacy.matchBarSpacing==false or not preset and legacy.spacing~=nil
            size=manualSize and (tonumber(legacy.size) or 48) or 48
            spacing=manualGap and (tonumber(legacy.spacing) or 8) or barGap
        end
        values.size,values.spacing=size*scale,spacing*scale
        values.columns=legacy.columns or 5
    end
    for key,default in pairs(DEFAULTS) do
        values[key]=Number(type(saved)=="table" and saved[key] or values[key],LIMITS[key],default)
    end
    local categories=type(saved)=="table" and saved.categories
    local category=KINDS[kind] and type(categories)=="table" and categories[kind]
    if type(category)=="table" then
        for key in pairs(DEFAULTS) do values[key]=Number(category[key],LIMITS[key],values[key]) end
    end
    values.scale=1
    return values
end
function FF:ResolveFishingFlyoutGeometry(kind,count,maxVisible,screenWidth,maxColumns)
    local layout=self:GetFishingFlyoutLayout(kind)
    layout.columns=math.min(layout.columns,math.max(1,count),maxColumns or 8)
    if screenWidth then
        local gutter=maxVisible and math.ceil(count/layout.columns)>math.max(1,maxVisible) and 18 or 0
        layout.columns=math.max(1,math.min(layout.columns,math.floor((screenWidth-10-gutter+layout.spacing)/(layout.size+layout.spacing))))
    end
    return layout
end
-- Resolve the same logical grid in either orientation: columns is capacity
-- along the bar; rows is depth away from it. Vertical swaps physical axes.
function FF:ResolveFishingFlyoutPlacement(count,owner,screen,fixed,kind,maxColumns,preferRight)
    local grid=self:GetFishingFlyoutLayout(kind)
    local step=grid.size+grid.spacing
    local vertical=self:GetFishingBarOrientation()=="vertical"
    local right=preferRight
    if right==nil then right=(owner.left+owner.right)<(screen.left+screen.right) end
    local order=vertical and (right and {"right","left"} or {"left","right"})
        or {"below","above","right","left"}
    local best
    for index,side in ipairs(order) do
        if not vertical and index==3 and best then return best end
        local width,height=screen.right-screen.left,screen.top-screen.bottom
        if side=="right" then width=screen.right-owner.right-4
        elseif side=="left" then width=owner.left-screen.left-4
        elseif side=="below" then height=owner.bottom-screen.bottom-4
        else height=screen.top-owner.top-4 end
        local span=vertical and height or width
        local depth=vertical and width or height
        local rows=math.floor((depth-10+grid.spacing)/step)
        local layout=self:ResolveFishingFlyoutGeometry(kind,count,rows,span,maxColumns)
        local natural=math.ceil(count/layout.columns)
        local minimum=fixed and natural>rows and 2 or 1
        local needed=layout.columns*step-grid.spacing+10+(natural>rows and 18 or 0)
        if span>=needed and rows>=minimum then
            local capacity=layout.columns*(rows-(fixed and natural>rows and 1 or 0))
            local candidate={side=side,width=span,maxVisible=rows,capacity=capacity}
            if not best or capacity>best.capacity then best=candidate end
            if natural<=rows then return candidate end
        end
    end
    return best or {side=order[1],width=(vertical and screen.top-screen.bottom or screen.right-screen.left),maxVisible=1}
end
function FF:InitializeFishingPresentationSettings()
    if not self.db then return end
    if type(self.db.flyoutGrid)~="table" then
        local grid=self:GetFishingFlyoutLayout("all")
        self.db.flyoutGrid={size=grid.size,columns=grid.columns,spacing=grid.spacing}
    end
    if type(self.db.fishingBarAutoCollapse)~="boolean" then self.db.fishingBarAutoCollapse=self:GetFishingBarAutoCollapse() end
end
-- The editor reads without normalizing or saving a preference. All is honest
-- per field: identical category values are shown even if the shared base differs.
function FF:GetFishingFlyoutEditValues(kind)
    local values=self:GetFishingFlyoutLayout(kind)
    local mixed={}
    if kind=="all" then
        values=self:GetFishingFlyoutLayout(ORDER[1])
        for index=2,#ORDER do
            local other=self:GetFishingFlyoutLayout(ORDER[index])
            for key in pairs(DEFAULTS) do if other[key]~=values[key] then mixed[key]=true end end
        end
    end
    return values,mixed
end
function FF:RefreshAllFishingFlyoutLayouts()
    for _,kind in ipairs(ORDER) do self:RefreshFishingFlyoutLayout(kind) end
    -- Both shortcuts use the shared grid, including while their frames are hidden.
    if self.settingsPicker then self:RefreshFishingFlyoutLayout("settings") end
    if self.journalPicker then self:RefreshFishingFlyoutLayout("journal") end
end
function FF:SetFishingFlyoutLayout(kind,key,value)
    if not self.db or not LIMITS[key] or (kind~="all" and not KINDS[kind]) then return false end
    if type(self.db.flyoutGrid)~="table" then
        local grid=self:GetFishingFlyoutLayout("all")
        self.db.flyoutGrid={size=grid.size,columns=grid.columns,spacing=grid.spacing}
    end
    local grid=self.db.flyoutGrid
    value=Number(value,LIMITS[key],DEFAULTS[key])
    if kind=="all" then
        grid[key]=value
        if type(grid.categories)=="table" then
            for _,id in ipairs(ORDER) do
                if type(grid.categories[id])=="table" then grid.categories[id][key]=nil end
            end
        end
        self:RefreshAllFishingFlyoutLayouts()
    else
        grid.categories=type(grid.categories)=="table" and grid.categories or {}
        grid.categories[kind]=type(grid.categories[kind])=="table" and grid.categories[kind] or {}
        grid.categories[kind][key]=value
        self:RefreshFishingFlyoutLayout(kind)
    end
    if self.settingsPanel and self.settingsPanel.RefreshFlyoutControls then self.settingsPanel:RefreshFlyoutControls() end
    return true
end
function FF:SetFishingFlyoutGrid(key,value) return self:SetFishingFlyoutLayout("all",key,value) end

-- Transient presentation state only: no saved pin, profession or input owner.
function FF:CanRevealFishingFlyout()
    return not (InCombatLockdown and InCombatLockdown()) and self.toolBar and self.toolBar:IsShown()
        and not (self.IsCameraSearchPending and self:IsCameraSearchPending())
        and not self.minimalFishingViewActive
        and not self.toolBar.moving and not self.toolBar.scaling
        and not (self.bar and (self.bar.moving or self.bar.scaling))
        and not self.journalInputFocus and not self.settingsKeyboardFocus
        and not (self.capture and self.capture:IsShown())
end

function FF:UpdateFishingFlyoutWatch()
    if self.SyncCompactFishingBarForFlyout then self:SyncCompactFishingBarForFlyout() end
    local watch = self.quickTrayDismiss
    if not watch then return end
    local panel = self:HasOpenFishingFlyout()
    if panel then
        watch:RegisterEvent("PLAYER_LEAVING_WORLD")
    else
        watch:UnregisterAllEvents()
    end
    local needsUpdate = panel
    watch:SetScript("OnUpdate", needsUpdate and function(_,elapsed) self:TickFishingFlyout(elapsed) end or nil)
end

-- Visible trays and an operation-hidden Chef tray both hold the bar open.
function FF:HasOpenFishingFlyout()
    return self.activeFishingFlyout or self.masterChefTrayResume
end

function FF:IsMasterChefQuickTrayBusy()
    -- A PreClick attempt only captures synchronous results. PostClick owns the
    -- operation hide after it has installed placement cleanup.
    return self.masterChefCampPlacement
        or self.masterChefCookingActive or self.masterChefCampCrafting
end

function FF:SuspendMasterChefQuickTray()
    if InCombatLockdown and InCombatLockdown() then return end
    local tray = self.masterChefTray
    if not tray or not tray:IsShown() then return end
    self.masterChefTrayResume = self.masterChefTrayResume or {activated=tray.flyoutChefActivated}
    self:CloseFishingQuickTray(true, true)
end

function FF:SyncMasterChefQuickTrayOperation()
    if self:IsMasterChefQuickTrayBusy() then self:SuspendMasterChefQuickTray()
    elseif self.masterChefTrayResume then self:ShowMasterChefQuickTray(true) end
end

function FF:TickFishingFlyout(elapsed)
    if not self:CanRevealFishingFlyout() then
        self:CloseFishingFlyouts()
        self:UpdateFishingFlyoutWatch()
        return
    end
    -- Mouse position never dismisses a flyout. Existing operation state only
    -- hides/restores presentation; this watcher never prepares or starts work.
    self:SyncMasterChefQuickTrayOperation()
    self:UpdateFishingFlyoutWatch()
end

function FF:ActivateFishingFlyout(panel)
    self.activeFishingFlyout = panel
    panel.flyoutOpenMode = "open"
    self:UpdateFishingFlyoutWatch()
end
function FF:ReleaseFishingFlyout(panel)
    panel.flyoutOpenMode = nil
    panel.flyoutChefActivated = nil
    panel.flyoutEntries, panel.flyoutGeometryLocked = nil,nil
    if self.activeFishingFlyout == panel then self.activeFishingFlyout = nil end
    self:UpdateFishingFlyoutWatch()
end
function FF:FinishFishingFlyoutSelection(panel) panel:Hide() end

local function EntryKey(entry)
    if entry.add or entry.kind == "plus" then return "add" end
    if entry.autoEquipToggle then return "auto-equip-lures" end
    if entry.auto then return "auto" end
    if entry.kind == "camp" then return "camp:"..entry.camp.id end
    if entry.kind == "meal" then return "meal:"..entry.meal.id end
    if entry.item then return entry.slot..":"..entry.item.id..":"..(entry.item.link or "") end
    return tostring(entry.id)
end
function FF:ResolveFishingFlyoutEntries(panel,entries)
    if panel.flyoutEntries and panel:IsShown() and self.activeFishingFlyout == panel then
        local incoming, stable = {},{}
        for _,entry in ipairs(entries) do incoming[EntryKey(entry)] = entry end
        for _,old in ipairs(panel.flyoutEntries) do
            local entry = incoming[EntryKey(old)]
            if not entry then
                entry = {}
                for k,v in pairs(old) do entry[k]=v end
                entry.flyoutUnavailable = true
            end
            stable[#stable+1]=entry
        end
        entries = stable
    end
    panel.flyoutEntries = entries
    return entries
end
