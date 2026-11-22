-- Forever Fishing
-- Copyright Â© 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
FF.journalStyle = { padding = 12, gap = 8, corner = 14, paper = {0.97, 0.91, 0.77}, ink = {0.23,0.14,0.075} }

FF.journalChevronTexture = "Interface\\AddOns\\ForeverFishing\\Media\\JournalQueueChevron"

-- Match the Events arrow's deep bronze. Owners retain geometry, hover feedback,
-- disabled/hidden state and direction semantics (including action-facing queues).
function FF:SetJournalChevron(texture, pointsUp)
    texture:SetTexture(self.journalChevronTexture)
    texture:SetTexCoord(0, 1, pointsUp and 0 or 1, pointsUp and 1 or 0)
    texture:SetVertexColor(0.39, 0.23, 0.08, 1)
end

function FF:CopyJournalViewState(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, item in pairs(value) do copy[key] = type(item) == "table" and self:CopyJournalViewState(item) or item end
    return copy
end

function FF:SetJournalInputFocus(edit, focused)
    if focused and InCombatLockdown and InCombatLockdown() then edit:ClearFocus(); return end
    if focused then self.journalInputFocus = edit
    elseif self.journalInputFocus == edit then self.journalInputFocus = nil end
    if self.ApplyBindings and self.db then self:ApplyBindings() end
    if self.UpdateJournalBackBinding then self:UpdateJournalBackBinding() end
end

function FF:CreateJournalEditBox(parent, width, placeholder)
    local edit = CreateFrame("EditBox",nil,parent,"InputBoxTemplate")
    edit:SetSize(width,24); edit:SetAutoFocus(false); edit:SetMaxLetters(120)
    edit:SetFontObject("GameFontHighlightSmall")
    edit.placeholder = edit:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
    edit.placeholder:SetPoint("LEFT",edit,"LEFT",3,0); edit.placeholder:SetText(placeholder or "")
    edit:SetScript("OnEditFocusGained",function(box) FF:SetJournalInputFocus(box,true) end)
    edit:SetScript("OnEditFocusLost",function(box) FF:SetJournalInputFocus(box,false) end)
    edit:SetScript("OnEscapePressed",function(box) box:ClearFocus() end)
    edit:SetScript("OnEnterPressed",function(box) box:ClearFocus() end)
    edit:SetScript("OnHide",function(box) box:ClearFocus(); FF:SetJournalInputFocus(box,false) end)
    edit:SetScript("OnTextChanged",function(box) box.placeholder:SetShown((box:GetText() or "") == "") end)
    return edit
end

function FF:YieldJournalInputsForScan()
    if self.CloseJournalRoutePicker then self:CloseJournalRoutePicker() end
    if self.journalInputFocus then self.journalInputFocus:ClearFocus() end
    if self.DismissJournalSearch then self:DismissJournalSearch(false) end
    if self.sessionGoalsRequested then self:CloseSessionGoals() end
    if self.sessionTrackerRequested then self:CloseSessionTracker() end
end

local function Snap(texture)
    if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(true) end
    if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
end

local function JournalFrameOrnaments(border, parent, size, visible, owner)
    if not visible and not border.ornaments then return end
    border.ornaments = border.ornaments or {}
    local pivot = 0.391304347826087
    for name, point in pairs({TopLeft="TOPLEFT",TopRight="TOPRIGHT",BottomLeft="BOTTOMLEFT",BottomRight="BOTTOMRIGHT"}) do
        local texture = border.ornaments[name]
        if not texture then
            texture = (owner or border):CreateTexture(nil,"OVERLAY")
            texture:SetTexture(FF.journalAssets.E05); texture:SetTexCoord(unpack(FF.journalFrameSlices.E05[name]))
            Snap(texture); border.ornaments[name] = texture
        end
        texture:SetSize(size,size); texture:ClearAllPoints()
        local left, top = name:find("Left") ~= nil, name:find("Top") ~= nil
        texture:SetPoint(point,parent,point,(left and 1 or -1)*(2-size*pivot),(top and -1 or 1)*(2-size*pivot))
        texture:SetShown(visible == true)
    end
end

-- Event identity is presentation metadata, never a title/name test. Reuse the
-- existing frame so Rare Catches gains corners without a second visible box.
function FF:StyleJournalEventFrame(border, eventRelated)
    if eventRelated and not border.eventOrnamentLayer then
        local layer=CreateFrame("Frame",nil,border)
        layer:SetAllPoints(border); layer:EnableMouse(false)
        border.eventOrnamentLayer=layer
    end
    local layer=border.eventOrnamentLayer
    if layer then layer:SetFrameLevel(border:GetFrameLevel()+2) end
    JournalFrameOrnaments(border, border:GetParent(), 20, eventRelated, layer)
end

-- Ordinary texture regions, not a retail NineSlice dependency or edgeFile.
-- Keep the authored cross-axis size at every scale. Atlas slices use continuous
-- sampling: independently pixel-snapping a stretched rail and a square corner
-- can give their identical bevel profiles different coverage at the join.
function FF:CreateJournalFrame(parent, ornament, corner, ornamentSize)
    local border = CreateFrame("Frame", nil, parent)
    border:SetAllPoints(parent); border:EnableMouse(false)
    -- Border textures share the owner's level: child controls and text stay
    -- above the rails. The empty center never intercepts input or covers paper.
    border:SetFrameLevel(parent:GetFrameLevel())
    border.pieces = {}
    local c = corner or self.journalStyle.corner
    border.cornerSize = c
    local points = {TopLeft="TOPLEFT",TopRight="TOPRIGHT",BottomLeft="BOTTOMLEFT",BottomRight="BOTTOMRIGHT"}
    for name, uv in pairs(self.journalFrameSlices.E04) do
        local t = border:CreateTexture(nil, "BORDER")
        t:SetTexture(self.journalAssets.E04); t:SetTexCoord(unpack(uv))
        if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
        if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
        border.pieces[name] = t
        if points[name] then t:SetSize(c,c); t:SetPoint(points[name], parent, points[name], 0,0) end
    end
    -- Resolve corners first, then attach both edges of every rail directly to
    -- its caps. This is the same rectangle as the original parent offsets;
    -- it cannot acquire a separate cross-axis size or seam when resized.
    local p = border.pieces
    for _,side in ipairs({"Left","Right"}) do
        p[side]:SetPoint("TOPLEFT",p["Top"..side],"BOTTOMLEFT",0,0)
        p[side]:SetPoint("BOTTOMRIGHT",p["Bottom"..side],"TOPRIGHT",0,0)
    end
    for _,edge in ipairs({"Top","Bottom"}) do
        p[edge]:SetPoint("TOPLEFT",p[edge.."Left"],"TOPRIGHT",0,0)
        p[edge]:SetPoint("BOTTOMRIGHT",p[edge.."Right"],"BOTTOMLEFT",0,0)
    end
    if ornament then JournalFrameOrnaments(border, parent, ornamentSize or 28, true) end
    return border
end

-- A dedicated native edgeFile replaces E04 completely on affected panels.
-- Native Backdrop owns all eight joins; no repeated strip pool or old atlas
-- corner remains underneath it. Existing owners supply their measured bounds.
function FF:StyleJournalPanelBorder(border, enabled, width, height)
    if not enabled and not border.panelBackdrop then return end
    for _,piece in pairs(border.pieces) do piece:SetShown(not enabled) end
    if not enabled then border.panelBackdrop:Hide(); return end
    local skin = border.panelBackdrop
    if not skin then
        skin = CreateFrame("Frame",nil,border,BackdropTemplateMixin and "BackdropTemplate" or nil)
        border.panelBackdrop = skin
        skin:SetPoint("TOPLEFT",border:GetParent(),"TOPLEFT",0,0)
        skin:EnableMouse(false)
        -- Above the owner's paper/fills; transparent centre and no mouse input.
        skin:SetFrameLevel(border:GetFrameLevel()+1)
        local c = border.cornerSize
        if skin.SetBackdrop then
            skin:SetBackdrop({edgeFile=self.journalAssets.E06,edgeSize=c,tileEdge=true})
            skin:SetBackdropBorderColor(1,1,1,1)
            -- Match sampling on every native edge/corner. Default per-piece
            -- sharpening can darken some rails at fractional Journal scales.
            for _,name in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
                "TopEdge","BottomEdge","LeftEdge","RightEdge"}) do
                local t=skin[name]
                if t and t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
                if t and t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
            end
        else
            -- Older clients without BackdropTemplate use the same new artwork,
            -- never the defective E04 skin. Native 8-cell order and crop.
            local u, v = 2/256, 30/256
            local regions = {TopLeft={4,"TOPLEFT"},TopRight={5,"TOPRIGHT"},
                BottomLeft={6,"BOTTOMLEFT"},BottomRight={7,"BOTTOMRIGHT"},
                Top={2},Bottom={3},Left={0},Right={1}}
            skin.parts = {}
            for name,region in pairs(regions) do
                local t=skin:CreateTexture(nil,"BORDER"); skin.parts[name]=t
                t:SetTexture(self.journalAssets.E06)
                if region[2] then
                    t:SetSize(c,c); t:SetPoint(region[2],skin,region[2],0,0)
                elseif name == "Top" or name == "Bottom" then
                    local point=name == "Top" and "TOP" or "BOTTOM"
                    t:SetHeight(c); t:SetPoint(point.."LEFT",skin,point.."LEFT",c,0)
                    t:SetPoint(point.."RIGHT",skin,point.."RIGHT",-c,0)
                else
                    t:SetWidth(c); t:SetPoint("TOP"..name:upper(),skin,"TOP"..name:upper(),0,-c)
                    t:SetPoint("BOTTOM"..name:upper(),skin,"BOTTOM"..name:upper(),0,c)
                end
                local left,right=region[1]/8+u,region[1]/8+v
                if name == "Top" or name == "Bottom" then
                    t:SetTexCoord(left,1/16,right,1/16,left,15/16,right,15/16)
                else t:SetTexCoord(left,right,1/16,15/16) end
                if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
                if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
            end
        end
    end
    if border.panelWidth ~= width or border.panelHeight ~= height then
        skin:SetSize(width,height); border.panelWidth,border.panelHeight=width,height
    end
    skin:Show()
end

function FF:StyleLearnedJournalRow(row, learned, height)
    if learned and not row.learnedBorder then row.learnedBorder = self:CreateJournalFrame(row,false,10) end
    if row.learnedBorder then
        if learned then self:StyleJournalPanelBorder(row.learnedBorder,true,row:GetWidth(),height or row:GetHeight()) end
        row.learnedBorder:SetShown(learned == true)
    end
end

function FF:GetJournalItemIcon(id)
    local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id)
    if not icon and GetItemIcon then icon = GetItemIcon(id) end
    return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function FF:RoundJournalItemIcon(texture)
    local parent=texture:GetParent()
    if texture.journalRoundMask or not (texture.AddMaskTexture and parent and parent.CreateMaskTexture) then return end
    local mask=parent:CreateMaskTexture(nil,"ARTWORK"); mask:SetAllPoints(texture)
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask); texture.journalRoundMask=mask
end

function FF:GetJournalCatchIconLayout(id, size, neutral)
    local state = not neutral and self:GetJournalCatchClassifications(id) or {}
    local scale = (size or 40) / 40
    local surround = (state.rarity and 60 or 56) * scale
    -- V2 openings are centred: bronze radius <25/64, dragons <21/64.
    -- The mask overlaps the solid inner rim; the image extends under that mask.
    local artwork = surround*(state.rarity and 45 or 54)/64
    local mask = surround*(state.rarity and 43 or 52)/64
    local ringX,ringY = 0,0
    local bounds=state.rarity and {1/64,1/64,63/64,63/64} or {1/64,1/64,63/64,62/64}
    local top=(.5-bounds[2])*surround+ringY
    local bottom=(bounds[4]-.5)*surround-ringY
    local left=(.5-bounds[1])*surround-ringX
    local right=(bounds[3]-.5)*surround+ringX
    -- The circular rim's lower edge differs from the dragon decoration bounds.
    local rimBottom=(state.rarity and 29 or 28)/64
    local laurel=(state.rarity and 60 or 56)*scale
    local laurelHeight=laurel*(59-33)/(63-1)
    local laurelDrop=rimBottom*surround+2.5*scale
    if state.trophy then
        top=math.max(top,laurelHeight-laurelDrop+ringY)
        bottom=math.max(bottom,laurelDrop-ringY)
        left=math.max(left,laurel/2-ringX); right=math.max(right,laurel/2+ringX)
    end
    return {surround=surround, artwork=artwork, mask=mask, ringX=ringX, ringY=ringY, top=top, bottom=bottom,
        left=left, right=right, laurel=laurel, laurelHeight=laurelHeight, laurelDrop=laurelDrop,
        height=top+bottom, centerY=(bottom-top)/2, trophy=state.trophy,
        texture=self.journalAssets[state.rarity == "ultra" and "JS06" or state.rarity and "JS05" or "JS04"]}
end

-- Reset the shared search row before it displays another kind of result.
function FF:ClearJournalItemIconFrame(frame, icon)
    if frame.itemSurround then frame.itemSurround:Hide() end
    if frame.trophyLaurel then frame.trophyLaurel:Hide() end
    if icon.SetDrawLayer then icon:SetDrawLayer("ARTWORK",0) end
    local mask=icon.journalRoundMask
    if mask then
        mask:ClearAllPoints(); mask:SetAllPoints(icon)
        mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
    end
end

-- Art lies under the solid inner rim, independent of the mask and decoration.
-- The cropped laurel wraps the lower sides without adding transparent height.
function FF:FrameJournalItemIcon(frame, icon, id, size, neutral, unknown)
    local layout = self:GetJournalCatchIconLayout(id,size,neutral)
    if not frame.itemSurround then
        frame.itemSurround=frame:CreateTexture(nil,"OVERLAY",nil,2)
        frame.trophyLaurel=frame:CreateTexture(nil,"OVERLAY",nil,3)
    end
    icon:SetSize(layout.artwork,layout.artwork)
    if icon.SetDrawLayer then icon:SetDrawLayer("ARTWORK",1) end
    self:RoundJournalItemIcon(icon)
    local mask=icon.journalRoundMask
    if mask then
        mask:ClearAllPoints(); mask:SetPoint("CENTER",icon,"CENTER",0,0)
        mask:SetSize(layout.mask,layout.mask)
        mask:SetTexture(self.journalAssets.ItemCircleMask,"CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
    end
    local ring, laurel = frame.itemSurround,frame.trophyLaurel
    ring:ClearAllPoints(); ring:SetPoint("CENTER",icon,"CENTER",layout.ringX,layout.ringY)
    ring:SetSize(layout.surround,layout.surround); ring:SetTexture(layout.texture)
    ring:SetTexCoord(0,1,0,1); ring:SetAlpha(unknown and .58 or 1); ring:Show()
    laurel:ClearAllPoints(); laurel:SetPoint("BOTTOM",ring,"CENTER",0,-layout.laurelDrop)
    laurel:SetSize(layout.laurel,layout.laurelHeight); laurel:SetTexture(self.journalAssets.JS07)
    laurel:SetTexCoord(1/64,63/64,33/64,59/64); laurel:SetAlpha(unknown and .75 or 1); laurel:SetShown(layout.trophy==true)
    return layout
end

-- Neutral UI icons retain their original texture size, anchors and hit target.
-- Reuse V2 fitting with the artwork diameter as the fixed logical size; its
-- circular mask overlaps the inner rim and the thin ring fits existing gaps.
function FF:FrameJournalRoundIcon(icon, diameter, unavailable)
    local frame=icon.journalBronzeFrame
    if not frame then
        local parent=icon:GetParent()
        frame=CreateFrame("Frame",nil,parent); frame:EnableMouse(false)
        frame:SetAllPoints(icon); frame:SetFrameLevel(parent:GetFrameLevel())
        icon.journalBronzeFrame=frame
    end
    local standard=self:GetJournalCatchIconLayout(0,40,true)
    self:FrameJournalItemIcon(frame,icon,0,diameter*40/standard.artwork,true)
    icon:SetSize(diameter,diameter)
    frame.itemSurround:SetDesaturated(unavailable==true)
    frame.itemSurround:SetAlpha(unavailable and .48 or 1)
    return frame
end

-- One item-hover contract for full/Mini Journal, inline links and Goals.
-- Only the hovered owner listens for Shift; native comparison item selection
-- and contents stay with the client. No CVar changes or polling are needed.
local function AnchorJournalItemTooltip(owner)
    local anchor = owner.journalTooltipAnchor or owner
    local screenLeft, screenRight = UIParent:GetLeft(), UIParent:GetRight()
    local edge = anchor.GetRight and anchor:GetRight()
    if not screenLeft or not screenRight then return end
    local scale = GameTooltip:GetEffectiveScale() or 1
    local screenScale = UIParent:GetEffectiveScale() or 1
    local anchorScale = anchor:GetEffectiveScale() or 1
    local cursor = owner.journalTooltipCursor
    if not edge and not cursor then return end
    local x = cursor and cursor[1] or edge * anchorScale
    local y = cursor and cursor[2] or (anchor.GetTop and anchor:GetTop())
    if y and not cursor then y = y * anchorScale end
    local mainHeight = GameTooltip:GetHeight() * scale
    local width, height = GameTooltip:GetWidth() * scale, mainHeight
    local comparisonDrop
    for _, tooltip in ipairs(GameTooltip.shoppingTooltips or {}) do
        if tooltip:IsShown() then
            local tooltipScale = tooltip:GetEffectiveScale() or 1
            comparisonDrop = comparisonDrop or 10 * tooltipScale
            width = width + tooltip:GetWidth() * tooltipScale
            height = math.max(height, tooltip:GetHeight() * tooltipScale + comparisonDrop)
        end
    end
    local left = math.max(screenLeft * screenScale,
        math.min(x - 2 * scale, screenRight * screenScale - width))
    local offsetY = 4
    local bottom, top = UIParent:GetBottom(), UIParent:GetTop()
    if y and bottom and top then
        local groupTop = math.max(bottom * screenScale + height,
            math.min(y + 4 * scale + mainHeight, top * screenScale))
        offsetY = (groupTop - mainHeight - y) / scale
    end
    GameTooltip:ClearAllPoints()
    if cursor then
        GameTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
            (left - screenLeft * screenScale) / scale, (y + offsetY * scale - (bottom or 0) * screenScale) / scale)
    else
        GameTooltip:SetPoint("BOTTOMLEFT", anchor, "TOPRIGHT", (left - x) / scale, offsetY)
    end
end

function FF:UpdateJournalItemTooltip(owner)
    if self.journalItemTooltipOwner ~= owner then return end
    if not GameTooltip.GetOwner or GameTooltip:GetOwner() ~= owner then
        self:HideJournalItemTooltip(owner)
        return
    end
    local comparisons = GameTooltip.shoppingTooltips or {}
    if owner.journalTooltipItemReady and IsShiftKeyDown and IsShiftKeyDown() and GameTooltip_ShowCompareItem then
        GameTooltip.overrideComparisonAnchorSide = "right"
        GameTooltip_ShowCompareItem(GameTooltip)
        local previous = GameTooltip
        for _, tooltip in ipairs(comparisons) do
            if tooltip:IsShown() then
                tooltip:ClearAllPoints()
                tooltip:SetPoint("TOPLEFT", previous, "TOPRIGHT", 0, previous == GameTooltip and -10 or 0)
                previous = tooltip
            end
        end
    else
        for _, tooltip in ipairs(comparisons) do tooltip:Hide() end
    end
    AnchorJournalItemTooltip(owner)
end

-- Only opt-in renderers are replayed. Their current item binding is checked by
-- the renderer; native data notifications never replay an old OnEnter closure.
function FF:RefreshJournalItemTooltip(owner, failed)
    if self.journalItemTooltipOwner ~= owner then return end
    if GameTooltip:GetOwner() ~= owner then self:HideJournalItemTooltip(owner); return end
    local hover = owner.journalTooltipHover
    if not hover then return end
    if hover.failed then GameTooltip.shouldRefreshData = false; return end
    local render = hover.refresh
    if failed then render = hover.failure end
    if not render then return end
    if not owner:IsVisible() or not owner:IsMouseOver() then
        self:HideJournalItemTooltip(owner)
        return
    end
    GameTooltip.shouldRefreshData = false
    render(owner, hover.id)
end

function FF:HideJournalItemTooltip(owner)
    if owner.journalTooltipHover and owner.journalTooltipHover.refresh then
        owner:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        owner:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
    end
    owner.journalTooltipHover = nil
    owner:UnregisterEvent("MODIFIER_STATE_CHANGED")
    owner.journalTooltipItemReady, owner.journalTooltipAnchor, owner.journalTooltipCursor = nil, nil, nil
    if self.journalItemTooltipOwner == owner then self.journalItemTooltipOwner = nil end
    if GameTooltip.GetOwner and GameTooltip:GetOwner() == owner then
        GameTooltip.overrideComparisonAnchorSide = nil
        GameTooltip:Hide()
    end
end

function FF:BeginJournalItemTooltip(owner, id, fallback, atLink, refresh, failure)
    if self.journalItemTooltipOwner then self:HideJournalItemTooltip(self.journalItemTooltipOwner) end
    if not owner.journalTooltipInstalled then
        owner.journalTooltipInstalled = true
        owner:HookScript("OnEvent", function(frame, event, key, success)
            if event == "MODIFIER_STATE_CHANGED" and (key == "LSHIFT" or key == "RSHIFT") then
                FF:UpdateJournalItemTooltip(frame)
            elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" then
                local hover = frame.journalTooltipHover
                if hover and hover.id == key then FF:RefreshJournalItemTooltip(frame, success == false) end
            end
        end)
        owner:HookScript("OnHide", function(frame) FF:HideJournalItemTooltip(frame) end)
        local update = owner.UpdateTooltip
        owner.UpdateTooltip = function(frame, ...)
            -- Native dispatch prioritises owner.UpdateTooltip over RefreshData.
            -- Do not let a callback retained from an old hover replace a newer tip.
            if FF.journalItemTooltipOwner ~= frame then return end
            if GameTooltip:GetOwner() ~= frame then FF:HideJournalItemTooltip(frame); return end
            if update then update(frame, ...) end
            if GameTooltip.shouldRefreshData then FF:RefreshJournalItemTooltip(frame) end
            FF:UpdateJournalItemTooltip(frame)
        end
    end
    if self.journalItemTooltipHideHook ~= GameTooltip then
        self.journalItemTooltipHideHook = GameTooltip
        GameTooltip:HookScript("OnHide", function()
            local owner = FF.journalItemTooltipOwner
            if owner then
                FF.journalItemTooltipOwner = nil
                if owner.journalTooltipHover and owner.journalTooltipHover.refresh then
                    owner:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
                    owner:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
                end
                owner.journalTooltipHover = nil
                owner:UnregisterEvent("MODIFIER_STATE_CHANGED")
                owner.journalTooltipItemReady, owner.journalTooltipAnchor, owner.journalTooltipCursor = nil, nil, nil
                GameTooltip.overrideComparisonAnchorSide = nil
            end
        end)
    end
    GameTooltip:SetOwner(owner, "ANCHOR_PRESERVE")
    owner.journalTooltipAnchor = owner.icon and owner.icon.GetRight and owner.icon or owner
    owner.journalTooltipCursor = nil
    if atLink and GetCursorPosition then
        local x, y = GetCursorPosition()
        if x and y then owner.journalTooltipCursor = {x, y} end
    end
    GameTooltip.overrideComparisonAnchorSide = "right"
    AnchorJournalItemTooltip(owner)
    local ok, result = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. id)
    if GameTooltip:GetOwner() ~= owner then return false end
    local ready = ok and result ~= false
    if not ready then GameTooltip:SetText(fallback or ("Item " .. id)) end
    -- SetHyperlink can hide itself on missing native data. Arm after native setup
    -- so that hide cannot discard this hover's item-completion subscription.
    self.journalItemTooltipOwner = owner
    owner.journalTooltipItemReady = ready
    owner.journalTooltipHover = { id = id, refresh = refresh, failure = failure }
    owner:RegisterEvent("MODIFIER_STATE_CHANGED")
    if refresh then
        owner:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        owner:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    end
    return ready
end

function FF:FinishJournalItemTooltip(owner)
    if self.journalItemTooltipOwner ~= owner or GameTooltip:GetOwner() ~= owner then return end
    GameTooltip:Show()
    self:UpdateJournalItemTooltip(owner)
end

-- Quest text uses the same native tooltip and screen-fitting anchor, while
-- item construction/modifier/comparison state remains with the item owner.
local function ReleaseJournalQuestTooltip(owner)
    owner:UnregisterEvent("QUEST_DATA_LOAD_RESULT")
    owner.journalQuestTooltipHover = nil
    if FF.journalItemTooltipOwner ~= owner then owner.journalTooltipAnchor, owner.journalTooltipCursor = nil, nil end
    FF:ClearJournalQuestHover(owner)
    if FF.journalQuestTooltipOwner == owner then FF.journalQuestTooltipOwner = nil end
end

function FF:HideJournalQuestTooltip(owner)
    local active = self.journalQuestTooltipOwner == owner
    ReleaseJournalQuestTooltip(owner)
    if active and GameTooltip:GetOwner() == owner then GameTooltip:Hide() end
end

function FF:BeginJournalQuestTooltip(owner, hover, refresh)
    if self.journalQuestTooltipOwner then self:HideJournalQuestTooltip(self.journalQuestTooltipOwner) end
    if self.journalItemTooltipOwner then self:HideJournalItemTooltip(self.journalItemTooltipOwner) end
    if not owner.journalQuestTooltipInstalled then
        owner.journalQuestTooltipInstalled = true
        owner:HookScript("OnHide", function(frame) FF:HideJournalQuestTooltip(frame) end)
        owner:HookScript("OnEvent", function(frame, event, id, success)
            local current = frame.journalQuestTooltipHover
            if event ~= "QUEST_DATA_LOAD_RESULT" or not current or current.id ~= id then return end
            frame:UnregisterEvent("QUEST_DATA_LOAD_RESULT")
            if FF.journalQuestTooltipOwner ~= frame or GameTooltip:GetOwner() ~= frame then
                FF:HideJournalQuestTooltip(frame); return
            end
            if not frame:IsVisible() or not frame:IsMouseOver() then FF:HideJournalQuestTooltip(frame); return end
            current.refresh(frame, success == false)
        end)
    end
    if self.journalQuestTooltipHideHook ~= GameTooltip then
        self.journalQuestTooltipHideHook = GameTooltip
        GameTooltip:HookScript("OnHide", function()
            if FF.journalQuestTooltipOwner then ReleaseJournalQuestTooltip(FF.journalQuestTooltipOwner) end
        end)
    end
    GameTooltip:SetOwner(owner, "ANCHOR_PRESERVE")
    GameTooltip.shouldRefreshData = false
    self.journalQuestTooltipOwner = owner
    owner.journalQuestTooltipHover = {id=hover.questID, refresh=refresh}
    owner.journalTooltipAnchor = owner.icon and owner.icon.GetRight and owner.icon or owner
    if hover.atLink and not hover.cursor and GetCursorPosition then
        local x, y = GetCursorPosition(); if x and y then hover.cursor = {x,y} end
    end
    owner.journalTooltipCursor = hover.cursor
    for _, tip in ipairs(GameTooltip.shoppingTooltips or {}) do tip:Hide() end
    AnchorJournalItemTooltip(owner)
end

function FF:FinishJournalQuestTooltip(owner)
    if self.journalQuestTooltipOwner ~= owner or GameTooltip:GetOwner() ~= owner then return end
    GameTooltip:Show()
    AnchorJournalItemTooltip(owner)
end

function FF:ShowJournalCatchTooltip(frame,id,note)
    local entry=self:GetJournalCatchDefinition(id)
    self:BeginJournalItemTooltip(frame,id,entry and entry[2])
    self:AddJournalCatchClassifications(GameTooltip,id)
    if entry then
        local guide,faction=entry[3],self:GetJournalFaction()
        local waters=self:GetJournalCatchReferenceText(entry,"waters",faction)
        local condition=self:GetJournalCatchReferenceText(entry,"condition",faction)
        if waters then GameTooltip:AddLine(waters,.78,.71,.57,true) end
        if guide.skill then GameTooltip:AddLine(self:LocalizedText("catch.tooltip.effective-skill",guide.skill),.78,.71,.57) end
        if condition then GameTooltip:AddLine(condition,.78,.71,.57,true) end
    end
    if note then GameTooltip:AddLine(note,.7,.7,.7,true) end
    self:FinishJournalItemTooltip(frame)
end

function FF:CreateCatchMasteryBadge(parent)
    local badge = CreateFrame("Frame",nil,parent)
    badge:SetSize(48,48); badge:EnableMouse(true)
    badge.icon = badge:CreateTexture(nil,"ARTWORK"); badge.icon:SetAllPoints(badge)
    badge.marker = badge:CreateFontString(nil,"OVERLAY","GameFontNormal")
    badge.marker:SetPoint("CENTER",badge,"TOPLEFT",24,-35.52)
    badge.marker:SetTextColor(1,0.90,0.62); badge.marker:SetFont(badge.marker:GetFont(),11,"OUTLINE")
    badge:SetScript("OnEnter",function(frame)
        GameTooltip:SetOwner(frame,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("catch.mastery.title"))
        GameTooltip:AddLine(frame.description or "",0.9,0.9,0.9,true); GameTooltip:Show()
    end)
    badge:SetScript("OnLeave",function() GameTooltip:Hide() end)
    return badge
end

function FF:UpdateCatchMasteryBadge(badge, count)
    local state = self:GetCatchProgression(count)
    -- Unearned artwork needs no text placeholder; earned tiers keep their numerals.
    local markers = {"","I","II","III","IV","V","VI"}
    badge.icon:SetTexture(self.journalAssets[string.format("M%02d",state.tier)])
    badge.marker:SetText(markers[state.tier+1])
    badge.description = (state.tier == 0 and self:LocalizedText("catch.badge.unearned") or self:LocalizedText("catch.badge.reached",markers[state.tier+1],state.reached))
        .. "\n"..self:LocalizedText("catch.badge.recorded",state.count).."\n"..(state.nextMilestone and self:LocalizedText("catch.badge.next",state.nextMilestone,state.remaining) or self:LocalizedText("catch.badge.complete"))
    return state
end
