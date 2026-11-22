-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

local GOLD = { 0.96, 0.69, 0.27 }
local DARK_BROWN = { 0.075, 0.045, 0.025 }
local TEAL = { 0.18, 0.78, 0.82 }
local INK = { 0.23, 0.14, 0.075 }
local SOFT_INK = { 0.31, 0.21, 0.12 }
local CATCH_HEADING_INK = { 117/255, 72/255, 24/255 }
local JOURNAL_NAV_WIDTH = 150
local EnableGuideLinks
local ROUND_ICON_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local MINI_CHEF_CIRCLE = "Interface\\AddOns\\ForeverFishing\\Media\\MiniMasterChefCircle"
local CHEF_HEADING_ICON_SIZE = 48
local CHEF_HEADING_ICON_LEFT = 27
local CHEF_HEADING_ICON_TOP = -17
local RARE_GOLD_TEXTURE = "Interface\\AddOns\\ForeverFishing\\Media\\JournalRareGold"
local RARE_SILVER_TEXTURE = "Interface\\AddOns\\ForeverFishing\\Media\\JournalRareSilver"
local STATS_MEDIA = "Interface\\AddOns\\ForeverFishing\\Media\\Stats\\"
local VENDOR_ICON = STATS_MEDIA .. "Vendor"
local AUCTION_ICON = STATS_MEDIA .. "Auction"
local METRIC_CARD_HEIGHT = 64
local FIRST_CATCH_ROWS = 9
local CATCH_ROWS_PER_FRAME = 8
local CATCH_BUILD_INTERVAL = 0.01
local SKILL_COLORS = { low = "c52f29", ready = "8f6b00", good = "287a35" }
local NEED_RED = { 0xc5 / 255, 0x2f / 255, 0x29 / 255 }
local GUIDE_SKILL_COLORS = { low = "995044", ready = "8f6b00", good = "4f6241" }
local JOURNAL_BACK_KEY = "BUTTON4"
local JOURNAL_BACK_BUTTON = "ForeverFishingJournalBackButton"
local JOURNAL_BACK_OWNER = CreateFrame("Frame", nil, WorldFrame, "SecureHandlerStateTemplate")
FF.journalBackBindingOwner = JOURNAL_BACK_OWNER
JOURNAL_BACK_OWNER:SetAttribute("_onstate-combat", [[if newstate == "combat" then self:ClearBindings() end]])
RegisterStateDriver(JOURNAL_BACK_OWNER, "combat", "[combat]combat;peace")
local journalBackEvents = CreateFrame("Frame", nil, WorldFrame)
FF.journalBackMouseWatcher = journalBackEvents
journalBackEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
journalBackEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
journalBackEvents:SetScript("OnEvent", function(_, event, button)
    if event == "GLOBAL_MOUSE_UP" then
        FF:JournalBackMouseUp(button)
    elseif event == "PLAYER_REGEN_DISABLED" then
        FF.journalBackBindingApplied = nil
        if FF.UpdateJournalBackBinding then FF:UpdateJournalBackBinding() end
    elseif FF.UpdateJournalBackBinding then
        FF:UpdateJournalBackBinding()
    end
end)

local function NeedsSkillFallback(skills, profession)
    return not skills[profession] or skills[profession].value == 0
end

local function PublicSkillNumber(value)
    return type(value) == "number" and not (issecretvalue and issecretvalue(value))
end

local function SkillValues(rank, cap, modifier)
    if not PublicSkillNumber(rank) then return { value = 0 } end
    local trainedCap = PublicSkillNumber(cap) and cap or nil
    local bonus = not (issecretvalue and issecretvalue(modifier)) and tonumber(modifier) or 0
    return { base = rank, trainedCap = trainedCap, value = rank + bonus,
        cap = trainedCap and trainedCap + bonus }
end

local function ReadStructuredFishingSkill(reader, rankKey, capKey, modifierKey)
    if type(reader) ~= "function" or (issecretvalue and issecretvalue(reader)) then return end
    local ok, info = pcall(reader, 356)
    if not ok or (issecretvalue and issecretvalue(info)) or type(info) ~= "table" then return end
    local rank, cap, modifier = info[rankKey], info[capKey], info[modifierKey]
    if PublicSkillNumber(rank) and rank > 0 and PublicSkillNumber(cap) and cap > 0
        and PublicSkillNumber(modifier) then
        return SkillValues(rank, cap, modifier)
    end
end

function FF:GetJournalSkills()
    -- On Forever, the legacy profession tuple can omit equipped bonuses.
    -- Use one complete native snapshot. Zero is valid after a bonus expires.
    local skills = { Fishing =
        ReadStructuredFishingSkill(C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoBySkillLineID,
            "skillLevel", "maxSkillLevel", "skillModifier")
        or ReadStructuredFishingSkill(C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID,
            "rank", "maxRank", "modifier") }
    local hasProfessions = GetProfessions and GetProfessionInfo
    if hasProfessions then
        local _, _, _, fishing, cooking = GetProfessions()
        local indexes = { Fishing = PublicSkillNumber(fishing) and fishing or false,
            Cooking = PublicSkillNumber(cooking) and cooking or false }
        for name, index in pairs(indexes) do
            if not skills[name] then
                local rank, cap, modifier
                if index then _, _, rank, cap, _, _, _, modifier = GetProfessionInfo(index) end
                if name ~= "Fishing" then modifier = nil end
                skills[name] = SkillValues(rank, cap, modifier)
            end
        end
    end
    if (NeedsSkillFallback(skills, "Fishing") or NeedsSkillFallback(skills, "Cooking")) and GetNumSkillLines and GetSkillLineInfo then
        local names = { Fishing = self:FishingName(), Cooking = self:GetNativeProfessionName(185,"Cooking") }
        for index = 1, GetNumSkillLines() do
            local name, isHeader, _, rank, _, modifier, cap = GetSkillLineInfo(index)
            if not isHeader and PublicSkillNumber(rank) then
                for profession, displayName in pairs(names) do
                    if name == displayName and NeedsSkillFallback(skills, profession) then
                        if profession ~= "Fishing" then modifier = nil end
                        skills[profession] = SkillValues(rank, cap, modifier)
                    end
                end
            end
            if not NeedsSkillFallback(skills, "Fishing") and not NeedsSkillFallback(skills, "Cooking") then break end
        end
    end
    return skills
end

local function SkillSnapshot(skills)
    local fishing, cooking = skills.Fishing or {}, skills.Cooking or {}
    return table.concat({ tostring(fishing.value), tostring(fishing.cap),
        tostring(cooking.value), tostring(cooking.cap) }, ":")
end

local function ColorRequirement(skills, label, profession, required, goodAt, palette, fixedUpperBound)
    local stat = skills and skills[profession]
    required = tonumber(required)
    if not required or not stat or type(stat.value) ~= "number" then return label end
    goodAt = tonumber(goodAt) or required + 25
    if not fixedUpperBound and stat.cap and stat.cap >= required then goodAt = math.min(goodAt, stat.cap) end
    local status = stat.value < required and "low" or stat.value < goodAt and "ready" or "good"
    return "|cff" .. (palette or SKILL_COLORS)[status] .. label .. "|r"
end

-- Numeric metadata supplies colour semantics for translated route display slots.
function FF:ColorJournalRequirement(skills, label, profession, required, goodAt, fixedUpperBound, fieldGuide)
    return ColorRequirement(skills, label, profession, required, goodAt, fieldGuide == false and SKILL_COLORS or GUIDE_SKILL_COLORS, fixedUpperBound)
end

local function ColorGuideSkills(skills, source, profession, heading, fieldGuide, structured)
    if type(source) ~= "string" then return source end
    if structured and FF:GetResolvedLocale() ~= "enUS" then return source end
    local palette = fieldGuide and GUIDE_SKILL_COLORS or nil
    if heading then
        source = source:gsub("^(%d+)–(%d+)", function(low, high)
            return ColorRequirement(skills, low .. "–" .. high, profession, low, high,
                palette, fieldGuide)
        end)
    end
    source = source:gsub("([Ss]kill) (%d+)", function(word, value)
        return ColorRequirement(skills, word .. " " .. value, profession, value, nil, palette)
    end)
    source = source:gsub("(Fishing) (%d+)", function(word, value)
        return ColorRequirement(skills, word .. " " .. value, "Fishing", value, nil, palette)
    end)
    source = source:gsub("(Cooking) (%d+)", function(word, value)
        return ColorRequirement(skills, word .. " " .. value, "Cooking", value, nil, palette)
    end)
    source = source:gsub("(%d+) Fishing([;%.])", function(value, punctuation)
        return ColorRequirement(skills, value .. " Fishing", "Fishing", value, nil, palette) .. punctuation
    end)
    source = source:gsub("(%d+) Fishing( or higher)", function(value, suffix)
        return ColorRequirement(skills, value .. " Fishing", "Fishing", value, nil, palette) .. suffix
    end)
    if profession == "Fishing" then
        source = source:gsub("(%d+)( plus a lure)", function(value, suffix)
            return ColorRequirement(skills, value, "Fishing", value, nil, palette) .. suffix
        end)
        source = source:gsub("(%d+)( and a lure)", function(value, suffix)
            return ColorRequirement(skills, value, "Fishing", value, nil, palette) .. suffix
        end)
    elseif profession == "Cooking" then
        source = source:gsub("(%d+)( recipes)", function(value, suffix)
            return ColorRequirement(skills, value, "Cooking", value, nil, palette) .. suffix
        end)
    end
    return source
end

-- Route formatting shares Cooking's skill rules without recolouring authored
-- spans or links. Other Journal pages continue through their existing helper.
local function ColorRouteSkills(skills,source,profession,heading,structured)
    if type(source)~="string" then return source end
    local protected={}
    local function Hold(value)
        protected[#protected+1]=value
        return "\001"..#protected.."\002"
    end
    source=source:gsub("|c%x%x%x%x%x%x%x%x.-|r",Hold)
    source=source:gsub("|H.-|h.-|h",Hold):gsub("|T.-|t",Hold)
    source=ColorGuideSkills(skills,source,profession,heading,true,structured)
    return (source:gsub("\001(%d+)\002",function(index) return protected[tonumber(index)] end))
end

local function JournalFactionText(value, faction)
    if type(value) == "table" then return value[faction] end
    return value
end

local function RoundIcon(texture)
    local parent = texture:GetParent()
    if not (texture.AddMaskTexture and parent and parent.CreateMaskTexture) then return end
    local mask = parent:CreateMaskTexture(nil, "ARTWORK")
    mask:SetAllPoints(texture)
    mask:SetTexture(ROUND_ICON_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask)
    texture.journalRoundMask = mask
end

local function Surface(frame, r, g, b, a)
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetColorTexture(r, g, b, a or 1)
    return texture
end

local function InsetSurface(frame, color, left, right, top, bottom)
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -top)
    texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -right, bottom)
    texture:SetColorTexture(unpack(color))
    return texture
end

local function Edge(frame, color)
    local top = frame:CreateTexture(nil, "BORDER")
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(2)
    top:SetColorTexture(color[1], color[2], color[3], 0.9)
    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)
    bottom:SetColorTexture(color[1] * 0.55, color[2] * 0.55, color[3] * 0.55, 0.8)
    for _, side in ipairs({ "LEFT", "RIGHT" }) do
        local line = frame:CreateTexture(nil, "BORDER")
        line:SetPoint("TOP" .. side)
        line:SetPoint("BOTTOM" .. side)
        line:SetWidth(1)
        line:SetColorTexture(color[1], color[2], color[3], 0.6)
    end
end

local JOURNAL_LOWER_INSET = 10
local PARCHMENT_EDGE_INSET = 8
local JOURNAL_PAGE_TOP_LIFT = PARCHMENT_EDGE_INSET + 2

local function MirrorGoldEdge(top, bottom)
    if not (top and bottom and top.GetTexCoord and bottom.SetTexCoord) then return end
    local ulx, uly, llx, lly, urx, ury, lrx, lry = top:GetTexCoord()
    if lry then
        bottom:SetTexCoord(llx, lly, ulx, uly, lrx, lry, urx, ury)
    elseif lly then
        bottom:SetTexCoord(ulx, uly, lly, llx)
    end
end

local function OrnateBorder(parent, padding, edgeSize, r, g, b)
    local border = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    border:SetPoint("TOPLEFT", parent, "TOPLEFT", -padding, padding)
    border:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", padding, -padding)
    border:SetFrameLevel(parent:GetFrameLevel() + 2)
    border:EnableMouse(false)
    if border.SetBackdrop then
        -- BackdropTemplate lays out fixed corners and separate tiled edges.
        -- Snap its pieces together on the pixel grid at custom Journal scales.
        border:SetBackdrop({
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = edgeSize,
            tileEdge = true,
        })
        border:SetBackdropBorderColor(r or 0.94, g or 0.72, b or 0.38, 0.95)
        for _, piece in ipairs({ "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
            "TopEdge", "BottomEdge", "LeftEdge", "RightEdge" }) do
            local texture = border[piece]
            if texture and texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(true) end
            if texture and texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
        end
        local function MatchLowerEdge()
            MirrorGoldEdge(border.TopEdge, border.BottomEdge)
            MirrorGoldEdge(border.TopLeftCorner, border.BottomLeftCorner)
            MirrorGoldEdge(border.TopRightCorner, border.BottomRightCorner)
        end
        MatchLowerEdge()
        if border.HookScript then border:HookScript("OnSizeChanged", MatchLowerEdge) end
    end
    return border
end

local function GoldDivider(parent, edge)
    local divider = OrnateBorder(parent, 0, 32)
    divider:ClearAllPoints()
    divider.edgePiece = edge
    for _, piece in ipairs({ "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
        "TopEdge", "BottomEdge", "LeftEdge", "RightEdge" }) do
        if piece ~= edge and divider[piece] then divider[piece]:Hide() end
    end
    return divider
end

local function SnapJournalTexture(texture)
    if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(true) end
    if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
end

local function ParchmentSlices(page)
    local info = C_Texture and C_Texture.GetAtlasInfo
        and C_Texture.GetAtlasInfo("QuestBG-Parchment")
    if not (info and type(info.width) == "number"
        and type(info.height) == "number" and info.width > 80 and info.height > 80
        and info.leftTexCoord and info.rightTexCoord
        and info.topTexCoord and info.bottomTexCoord) then
        return nil
    end

    local file = info.file or info.filename
    -- Exclude the atlas's straight outer gutter; keep the torn edge inside it.
    local crop = 4
    local corner = 32
    local inset = PARCHMENT_EDGE_INSET
    local du = (info.rightTexCoord - info.leftTexCoord) / info.width
    local dv = (info.bottomTexCoord - info.topTexCoord) / info.height
    local u0, u3 = info.leftTexCoord + crop * du, info.rightTexCoord - crop * du
    local v0, v3 = info.topTexCoord + crop * dv, info.bottomTexCoord - crop * dv
    local u1, u2 = u0 + corner * du, u3 - corner * du
    local v1, v2 = v0 + corner * dv, v3 - corner * dv
    local slices = {}
    local function Slice(name, sublevel, left, right, top, bottom)
        -- All parchment art belongs behind page text and child controls.
        local texture = page:CreateTexture(nil, "BACKGROUND", nil, sublevel)
        if file then texture:SetTexture(file)
        else texture:SetAtlas("QuestBG-Parchment") end
        texture:SetTexCoord(left, right, top, bottom)
        texture:SetVertexColor(1, 0.94, 0.83, 0.96)
        SnapJournalTexture(texture)
        slices[name] = texture
        return texture
    end
    -- The center is separate from the decorative edge. It reaches one pixel
    -- under each edge so scaled layouts cannot reveal a dark seam.
    local center = Slice("Center", 1, u1, u2, v1, v2)
    center:SetPoint("TOPLEFT", page, "TOPLEFT", inset + corner - 1, -inset - corner + 1)
    center:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -inset - corner + 1, inset + corner - 1)

    local topLeft = Slice("TopLeft", 3, u0, u1, v0, v1)
    topLeft:SetPoint("TOPLEFT", page, "TOPLEFT", inset, -inset)
    topLeft:SetSize(corner, corner)
    local topRight = Slice("TopRight", 3, u2, u3, v0, v1)
    topRight:SetPoint("TOPRIGHT", page, "TOPRIGHT", -inset, -inset)
    topRight:SetSize(corner, corner)
    local bottomLeft = Slice("BottomLeft", 3, u0, u1, v2, v3)
    bottomLeft:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", inset, inset)
    bottomLeft:SetSize(corner, corner)
    local bottomRight = Slice("BottomRight", 3, u2, u3, v2, v3)
    bottomRight:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -inset, inset)
    bottomRight:SetSize(corner, corner)

    local top = Slice("Top", 2, u1, u2, v0, v1)
    top:SetPoint("TOPLEFT", page, "TOPLEFT", inset + corner - 1, -inset)
    top:SetPoint("TOPRIGHT", page, "TOPRIGHT", -inset - corner + 1, -inset)
    top:SetHeight(corner)
    local bottom = Slice("Bottom", 2, u1, u2, v2, v3)
    bottom:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", inset + corner - 1, inset)
    bottom:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -inset - corner + 1, inset)
    bottom:SetHeight(corner)
    local left = Slice("Left", 2, u0, u1, v1, v2)
    left:SetPoint("TOPLEFT", page, "TOPLEFT", inset, -inset - corner + 1)
    left:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", inset, inset + corner - 1)
    left:SetWidth(corner)
    local right = Slice("Right", 2, u2, u3, v1, v2)
    right:SetPoint("TOPRIGHT", page, "TOPRIGHT", -inset, -inset - corner + 1)
    right:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -inset, inset + corner - 1)
    right:SetWidth(corner)
    return slices
end

local function JournalFrameSkin(frame, parchment)
    if parchment then
        frame.paperFill = InsetSurface(frame, { 0.83, 0.71, 0.51, 0.985 }, 14, 14, 14, 14)
        SnapJournalTexture(frame.paperFill)
        -- Restore the original worn atlas, including its mottled center. The
        -- flat fill is only the backing/fallback, never an opaque inset sheet.
        frame.parchmentSlices = ParchmentSlices(frame)
        frame.innerBorder = OrnateBorder(frame, 0, 32, 0.59, 0.38, 0.17)
    else
        frame.windowFill = InsetSurface(frame,
            { DARK_BROWN[1], DARK_BROWN[2], DARK_BROWN[3], 0.99 }, 12, 12, 12, JOURNAL_LOWER_INSET)
        SnapJournalTexture(frame.windowFill)
        frame.outerBorder = OrnateBorder(frame, 0, 32)
    end
end

local function JournalScrollSide(panel)
    if panel.compactChef then return 20 end
    return FF.journalTab == "chef" and 22 or 31
end

local function JournalScrollTop(panel)
    return FF.journalTab == "chef" and (panel.compactChef and -115 or -105)
        or (panel.journalLayout and panel.journalLayout.scrollTop or -88)
end

local JOURNAL_CHEVRON = FF.journalChevronTexture

local function SetJournalChevron(texture, pointsUp)
    FF:SetJournalChevron(texture, pointsUp)
end

local function SetChefQueueChevron(queue, expanded, count)
    local canExpand = count > 1
    queue.toggle:EnableMouse(canExpand)
    queue.toggle.icon:SetShown(canExpand)
    if canExpand then
        -- Queue chevrons indicate the next action: up to open, down to close.
        SetJournalChevron(queue.toggle.icon, not expanded)
    end
end

local function CloseButton(panel, inset)
    local button = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    button:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(inset or 3), -(inset or 3))
    button:SetFrameLevel(panel:GetFrameLevel() + 5)
    button:SetScript("OnClick", function() panel:Hide() end)
    return button
end

local journalFonts = setmetatable({}, { __mode = "k" })

function FF:GetJournalTextScale()
    local value = tonumber(self.db and self.db.journalTextScale) or 1
    return math.max(0.85, math.min(1.15, value))
end

function FF:ApplyJournalTextSize()
    local scale = self:GetJournalTextScale()
    for font, spec in pairs(journalFonts) do
        FF:SetDisplayFont(font, spec.path, spec.size * scale, spec.flags)
    end
    if self.ReflowJournal then self:ReflowJournal() end
end

function FF:SetJournalTextScale(value)
    value = tonumber(value) or 1
    self.db.journalTextScale = math.max(0.85, math.min(1.15,
        math.floor(value * 20 + 0.5) / 20))
    self:ApplyJournalTextSize()
end

local function Text(parent, template, anchor, relative, relativeAnchor, x, y, value)
    local font = parent:CreateFontString(nil, "OVERLAY", template)
    font:SetPoint(anchor, relative, relativeAnchor, x, y)
    font:SetText(value or "")
    local path, size, flags = font:GetFont()
    if path and size then
        journalFonts[font] = { path = path, size = size, flags = flags or "" }
        FF:SetDisplayFont(font, path, size * FF:GetJournalTextScale(), flags or "")
    end
    return font
end

local function Readable(font, size)
    local path, _, flags = font:GetFont()
    if path then
        local base = size or 14
        journalFonts[font] = { path = path, size = base, flags = flags or "" }
        FF:SetDisplayFont(font, path, base * FF:GetJournalTextScale(), flags or "")
    end
    return font
end

local function PaperText(parent, template, anchor, relative, relativeAnchor, x, y, value)
    local font = Text(parent, template, anchor, relative, relativeAnchor, x, y, value)
    local path, size = font:GetFont()
    if path then
        FF:SetDisplayFont(font, path, size, "")
        if journalFonts[font] then journalFonts[font].flags = "" end
    end
    font:SetShadowColor(0, 0, 0, 0)
    font:SetShadowOffset(0, 0)
    return font
end

local function ModernButton(parent, label, width, height, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetText(label)
    local caption = button.GetFontString and button:GetFontString()
    if caption then
        local _, size = caption:GetFont()
        if size then Readable(caption, size) end
    end
    if onClick then button:SetScript("OnClick", onClick) end
    return button
end


-- Translated session actions share their existing buttons and callbacks. Refit
-- after font/scale assignment; English keeps its established geometry.
local function FitTranslatedJournalAction(button, minimum, fitEnglish)
    if not fitEnglish and FF:GetResolvedLocale()=="enUS" then return button:GetHeight() end
    local caption=button.GetFontString and button:GetFontString()
    if not caption then return button:GetHeight() end
    caption:SetWidth(math.max(1,button:GetWidth()-12)); caption:SetWordWrap(true)
    caption:SetHeight(0)
    local height=math.max(minimum,math.ceil(caption:GetStringHeight())+8)
    button:SetHeight(height); caption:SetHeight(height-6)
    return height
end

-- Shared fixed-corner slices for small bronze buttons; all states tint the
-- same rounded fill/edge instead of overlaying a rectangular highlight.
local function RoundedButtonLayers(button)
    button.bronzeLayers={}
    local anchors={"TOPLEFT","TOP","TOPRIGHT","LEFT","CENTER","RIGHT","BOTTOMLEFT","BOTTOM","BOTTOMRIGHT"}
    for layer,path in ipairs({"FlyoutRoundedFill","FlyoutRoundedEdge"}) do
        local pieces={}; button.bronzeLayers[layer]=pieces
        for index,anchor in ipairs(anchors) do
            local col=(index-1)%3; local row=math.floor((index-1)/3)
            local uv={0,8/64,56/64,1}; local texture=button:CreateTexture(nil,layer==1 and "BACKGROUND" or "BORDER")
            texture:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\"..path)
            texture:SetTexCoord(uv[col+1],uv[col+2],uv[row+1],uv[row+2])
            if col~=1 and row~=1 then texture:SetSize(5,5); texture:SetPoint(anchor,button,anchor,0,0)
            elseif row~=1 then
                texture:SetHeight(5); local side=row==0 and "TOP" or "BOTTOM"
                texture:SetPoint(side.."LEFT",button,side.."LEFT",5,0); texture:SetPoint(side.."RIGHT",button,side.."RIGHT",-5,0)
            elseif col~=1 then
                texture:SetWidth(5); local side=col==0 and "LEFT" or "RIGHT"
                texture:SetPoint("TOP"..side,button,"TOP"..side,0,-5); texture:SetPoint("BOTTOM"..side,button,"BOTTOM"..side,0,5)
            else texture:SetPoint("TOPLEFT",button,"TOPLEFT",5,-5); texture:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-5,5) end
            pieces[index]=texture
        end
    end
end

local function WarmTab(parent, label, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(155, 37)
    button.bg = Surface(button, 0.11, 0.07, 0.035, 0.38)
    local hi = button:CreateTexture(nil, "HIGHLIGHT")
    hi:SetAllPoints(button)
    hi:SetColorTexture(1, 0.68, 0.23, 0.12)
    button:SetHighlightTexture(hi)
    button.marker = button:CreateTexture(nil, "ARTWORK")
    button.marker:SetPoint("TOPLEFT")
    button.marker:SetPoint("BOTTOMLEFT")
    button.marker:SetWidth(3)
    button.marker:SetColorTexture(unpack(GOLD))
    button.marker:Hide()
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Readable(button.label, 14)
    button.label:SetPoint("LEFT", button, "LEFT", 13, 0)
    button.label:SetText(label)
    button.label:SetTextColor(0.84, 0.74, 0.57)
    button:SetScript("OnClick", onClick)
    return button
end

local function PaintWarmTab(button, selected)
    button.marker:SetShown(selected)
    button.bg:SetColorTexture(selected and 0.25 or 0.11, selected and 0.15 or 0.07, selected and 0.065 or 0.035, selected and 0.98 or 0.38)
    button.label:SetTextColor(selected and 1 or 0.84, selected and 0.82 or 0.74, selected and 0.44 or 0.57)
end

local function PanelVisible(panel)
    if panel.IsVisible then return panel:IsVisible() end
    return panel:IsShown()
end

function FF:JournalBackMouseUp(button)
    if button ~= "Button4" and button ~= "BUTTON4" then return end
    if not self.journalBackBindingApplied or (InCombatLockdown and InCombatLockdown()) then return end
    if (IsShiftKeyDown and IsShiftKeyDown()) or (IsControlKeyDown and IsControlKeyDown())
        or (IsAltKeyDown and IsAltKeyDown()) then return end
    local panel = self.journalPanel
    if panel and panel.backButton and PanelVisible(panel) and panel.backButton:IsShown() then
        self:JournalBack()
    end
end

function FF:UpdateJournalBackBinding()
    local panel = self.journalPanel
    local wanted = not self.journalInputFocus and panel and panel.backButton and PanelVisible(panel) and panel.backButton:IsShown()
    if InCombatLockdown and InCombatLockdown() then
        journalBackEvents:UnregisterEvent("GLOBAL_MOUSE_UP")
        self.journalBackBindingApplied = nil
        return
    end
    if wanted then journalBackEvents:RegisterEvent("GLOBAL_MOUSE_UP")
    else journalBackEvents:UnregisterEvent("GLOBAL_MOUSE_UP") end
    if wanted and not self.journalBackBindingApplied then
        -- Consume the normal Button 4 action; the global release event handles
        -- navigation even while the pointer is over another journal control.
        SetOverrideBindingClick(JOURNAL_BACK_OWNER, true, JOURNAL_BACK_KEY, "ForeverFishingGuardButton", "LeftButton")
        self.journalBackBindingApplied = true
        if self.db and self.db.key == JOURNAL_BACK_KEY then self:ApplyBindings() end
    elseif not wanted and self.journalBackBindingApplied then
        ClearOverrideBindings(JOURNAL_BACK_OWNER)
        self.journalBackBindingApplied = nil
        if self.db and self.db.key == JOURNAL_BACK_KEY then self:ApplyBindings() end
    end
end

local function UpdateJournalBackButton(panel)
    if panel.backButton and not (InCombatLockdown and InCombatLockdown()) then
        panel.backButton:SetShown(not panel.compactChef
            and panel.backHistory and #panel.backHistory > 0 or false)
    end
    FF:UpdateJournalBackBinding()
end

function FF:GetJournalGuideDisplayText(tab,field)
    local key=tab and "journal.guide."..tostring(tab.id).."."..field
    return key and self.englishStrings[key] and self:LocalizedText(key) or tab and tab[field] or ""
end

local function JournalGuideNavigation()
    local ordered={}
    for _,tab in ipairs(FF.guideTabs or {}) do if tab.id=="nearby" then ordered[#ordered+1]=tab end end
    for _,tab in ipairs(FF.guideTabs or {}) do if tab.id~="nearby" then ordered[#ordered+1]=tab end end
    return ordered
end

local function CreateJournal()
    local panel = CreateFrame("Frame", "ForeverFishingJournal", FF:EnsureFishingVisibilityRoot(),
        "SecureHandlerStateTemplate")
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "ForeverFishingJournal" end
    panel:SetSize(750, 560)
    panel:SetPoint("CENTER")
    panel:EnableMouse(true)
    JournalFrameSkin(panel, false)
    local closeButton = CloseButton(panel)
    panel.fullCloseButton = closeButton

    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(67)
    panel.fullHeaderFill = InsetSurface(header, { 0.095, 0.057, 0.028, 0.98 },
        12, 12, 12, 0)
    local book = header:CreateTexture(nil, "ARTWORK")
    book:SetSize(42, 42)
    book:SetPoint("LEFT", header, "LEFT", 17, -1)
    book:SetTexture(FF.journalIcon)
    book:SetTexCoord(0, 1, 0, 1)
    RoundIcon(book)
    FF:FrameJournalRoundIcon(book,42)
    local title = Readable(Text(header, "GameFontNormalHuge", "LEFT", book, "RIGHT", 12, 0, FF:LocalizedText("journal.header")), 26)
    title:SetJustifyH("LEFT")
    title:SetTextColor(1, 0.83, 0.48)
    title:SetShadowColor(0, 0, 0, 0.8)
    title:SetShadowOffset(1, -1)
    panel.fullHeader = header
    panel.headerTitle, panel.headerBook = title, book
    local headerDivider = GoldDivider(panel, "TopEdge")
    -- Backdrop edges omit one corner width at either end. Extend the invisible
    -- divider frame so only the tiled edge spans the intended visible line.
    headerDivider:SetPoint("TOPLEFT", panel, "TOPLEFT", -20, -67)
    headerDivider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 20, -67)
    headerDivider:SetHeight(32)
    headerDivider:SetFrameLevel(panel:GetFrameLevel() + 3)
    local navDivider = GoldDivider(panel, "LeftEdge")
    navDivider:SetPoint("TOPLEFT", panel, "TOPLEFT", 10 + JOURNAL_NAV_WIDTH, -40)
    navDivider:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10 + JOURNAL_NAV_WIDTH, JOURNAL_LOWER_INSET - 32)
    navDivider:SetWidth(32)
    navDivider:SetFrameLevel(panel:GetFrameLevel() + 1)
    panel.headerDivider, panel.navDivider = headerDivider, navDivider
    local compactHeader = CreateFrame("Frame", nil, panel)
    compactHeader:SetPoint("TOPLEFT")
    compactHeader:SetPoint("TOPRIGHT")
    compactHeader:SetHeight(55)
    -- This is only a drag handle; the compact heading lives on the page.
    local compactClose = CloseButton(panel, 7)
    compactHeader:Hide()
    compactClose:Hide()
    panel.compactHeader, panel.compactCloseButton = compactHeader, compactClose
    local backButton = CreateFrame("Button", JOURNAL_BACK_BUTTON, panel)
    backButton:SetSize(112, 33)
    backButton:SetPoint("RIGHT", closeButton, "LEFT", -10, -27)
    backButton:SetFrameLevel(panel:GetFrameLevel() + 5)
    backButton:RegisterForClicks("LeftButtonUp")
    RoundedButtonLayers(backButton)
    for index, texture in ipairs(backButton.bronzeLayers[2]) do
        local bottom = index >= 7
        local shade = bottom and 0.55 or 1
        texture:SetVertexColor(0.69 * shade, 0.49 * shade, 0.22 * shade,
            index <= 3 and 0.9 or bottom and 0.8 or 0.6)
    end
    local backLabel = Readable(Text(backButton, "GameFontNormalLarge", "CENTER", backButton, "CENTER", 0, 0, FF:LocalizedText("journal.back")), 16)
    local function PaintBack()
        local hover = backButton.backHovered and not backButton.backPressed
        for _, texture in ipairs(backButton.bronzeLayers[1]) do
            texture:SetVertexColor(hover and 0.24 or 0.16, hover and 0.14 or 0.09,
                hover and 0.055 or 0.035, 0.98)
        end
        backLabel:SetTextColor(1, hover and 0.92 or 0.83, hover and 0.68 or 0.50)
    end
    backButton:SetScript("OnEnter", function()
        backButton.backHovered = true; PaintBack()
    end)
    backButton:SetScript("OnLeave", function()
        backButton.backHovered, backButton.backPressed = nil, nil; PaintBack()
    end)
    backButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then backButton.backPressed = true; PaintBack() end
    end)
    backButton:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then backButton.backPressed = nil; PaintBack() end
    end)
    backButton:SetScript("OnHide", function()
        backButton.backHovered, backButton.backPressed = nil, nil; PaintBack()
    end)
    PaintBack()
    backButton:SetScript("OnClick", function() FF:JournalBack() end)
    panel.backButton = backButton
    UpdateJournalBackButton(panel)

    local nav = CreateFrame("Frame", nil, panel)
    nav:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -76)
    nav:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, JOURNAL_LOWER_INSET)
    nav:SetWidth(JOURNAL_NAV_WIDTH)
    panel.navFill = Surface(nav, 0.055, 0.034, 0.02, 0.98)
    SnapJournalTexture(panel.navFill)
    panel.nav = nav

    panel.navTabs = {}
    local records = Readable(Text(nav, "GameFontNormal", "TOPLEFT", nav, "TOPLEFT", 10, -13, FF:LocalizedText("journal.records")), 14)
    records:SetTextColor(unpack(GOLD))
    panel.navRecords = records
    local catchTab = WarmTab(nav, FF:LocalizedText("journal.catch-tab"), function() FF:SelectJournalTab("catch", true) end)
    catchTab:SetPoint("TOPLEFT", nav, "TOPLEFT", 7, -32)
    panel.navTabs.catch = catchTab
    panel.navTabs.achievements = WarmTab(nav, FF:LocalizedText("journal.achievements"), function() FF:SelectJournalTab("achievements", true) end)
    local sessionTab = WarmTab(nav, FF:LocalizedText("journal.nav-session"), function() FF:SelectJournalTab("session", true) end)
    sessionTab:SetPoint("TOPLEFT", nav, "TOPLEFT", 7, -73)
    panel.navTabs.session = sessionTab
    local lifetimeTab = WarmTab(nav, FF:LocalizedText("journal.nav-lifetime"), function() FF:SelectJournalTab("lifetime", true) end)
    lifetimeTab:SetPoint("TOPLEFT", nav, "TOPLEFT", 7, -114)
    panel.navTabs.lifetime = lifetimeTab
    local field = Readable(Text(nav, "GameFontNormal", "TOPLEFT", nav, "TOPLEFT", 10, -169, FF:LocalizedText("journal.field-guide")), 14)
    field:SetTextColor(unpack(GOLD))
    panel.navFieldHeading = field
    for index, tab in ipairs(JournalGuideNavigation()) do
        local tabID = tab.id
        local button = WarmTab(nav, FF:GetJournalGuideDisplayText(tab,"label"), function() FF:SelectJournalTab(tabID, true) end)
        button:SetPoint("TOPLEFT", nav, "TOPLEFT", 7, -188 - (index - 1) * 40)
        panel.navTabs[tab.id] = button
    end
    local eventsTab = WarmTab(nav, FF:LocalizedText("journal.events-tab"), function() FF:SelectJournalTab("events", true) end)
    eventsTab:SetPoint("TOPLEFT", nav, "TOPLEFT", 7, -188 - #(FF.guideTabs or {}) * 40)
    panel.navTabs.events = eventsTab
    local chefTab = WarmTab(nav, FF:LocalizedText("settings.copy.master-chef-78f9"), function() FF:SelectJournalTab("chef", true) end)
    chefTab:SetPoint("TOPLEFT", eventsTab, "BOTTOMLEFT", 0, -3)
    panel.navTabs.chef = chefTab
    local beta = Readable(Text(nav, "GameFontHighlight", "BOTTOMLEFT", nav, "BOTTOMLEFT", 11, 13, "Forever beta  •  1.60.1"), 13)
    beta:SetTextColor(0.52, 0.43, 0.3)
    beta:SetWidth(JOURNAL_NAV_WIDTH - 22)
    beta:SetWordWrap(true)
    panel.navBeta = beta

    local page = CreateFrame("Frame", nil, panel)
    -- The torn artwork extends beneath the horizontal divider while the
    -- content keeps its own padding inside the page.
    page:SetPoint("TOPLEFT", nav, "TOPRIGHT", -6, JOURNAL_PAGE_TOP_LIFT)
    page:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -4,
        JOURNAL_LOWER_INSET - PARCHMENT_EDGE_INSET)
    JournalFrameSkin(page, true)
    panel.page = page
    compactHeader:SetFrameLevel(page:GetFrameLevel() + 3)
    panel.pageTitle = Readable(PaperText(page, "GameFontNormalHuge", "TOPLEFT", page, "TOPLEFT", 24, -18, ""), 25)
    panel.pageTitle:SetTextColor(unpack(INK))
    local chefTitleIcon = page:CreateTexture(nil, "ARTWORK")
    chefTitleIcon:SetSize(CHEF_HEADING_ICON_SIZE, CHEF_HEADING_ICON_SIZE)
    chefTitleIcon:SetPoint("TOPLEFT", page, "TOPLEFT",
        CHEF_HEADING_ICON_LEFT, CHEF_HEADING_ICON_TOP)
    chefTitleIcon:SetTexture(MINI_CHEF_CIRCLE)
    chefTitleIcon:Hide()
    panel.chefTitleIcon = chefTitleIcon
    local openMiniChef = CreateFrame("Button", nil, page)
    openMiniChef:SetSize(CHEF_HEADING_ICON_SIZE, CHEF_HEADING_ICON_SIZE)
    openMiniChef:SetPoint("TOPLEFT", page, "TOPLEFT",
        CHEF_HEADING_ICON_LEFT, CHEF_HEADING_ICON_TOP)
    openMiniChef:SetFrameLevel(page:GetFrameLevel() + 3)
    openMiniChef:RegisterForClicks("LeftButtonUp")
    local openMiniIcon = openMiniChef:CreateTexture(nil, "ARTWORK")
    openMiniIcon:SetAllPoints(openMiniChef)
    openMiniIcon:SetTexture(MINI_CHEF_CIRCLE)
    openMiniChef.icon = openMiniIcon
    openMiniChef:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("chef.open-mini"), 1, 0.82, 0.45)
        GameTooltip:Show()
    end)
    openMiniChef:SetScript("OnLeave", function() GameTooltip:Hide() end)
    openMiniChef:SetScript("OnClick", function()
        -- This shortcut starts from a chosen full-Journal Chef view, so keep
        -- that view instead of applying the compact window's first-open tab.
        panel.compactChefOpened = true
        FF:ShowCompactMasterChef(true)
    end)
    openMiniChef:Hide()
    panel.openMiniChefButton = openMiniChef
    panel.pageSubtitle = Readable(PaperText(page, "GameFontHighlight", "TOPLEFT", page, "TOPLEFT", 24, -55, ""), 14)
    panel.pageSubtitle:SetJustifyH("LEFT")
    panel.pageSubtitle:SetTextColor(unpack(SOFT_INK))
    local showAll = CreateFrame("Button", nil, page)
    showAll:SetSize(111, 28)
    showAll:SetPoint("TOPRIGHT", page, "TOPRIGHT", -20, -42)
    local check = CreateFrame("Frame", nil, showAll)
    check:SetSize(14, 14); check:SetPoint("LEFT", showAll, "LEFT", 2, 0)
    Surface(check, 0.97, 0.88, 0.67, 0.3)
    local boxColor = { 0.36, 0.22, 0.10 }
    local top = check:CreateTexture(nil, "BORDER")
    top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT"); top:SetHeight(1)
    top:SetColorTexture(unpack(boxColor))
    local bottom = check:CreateTexture(nil, "BORDER")
    bottom:SetPoint("BOTTOMLEFT"); bottom:SetPoint("BOTTOMRIGHT"); bottom:SetHeight(1)
    bottom:SetColorTexture(unpack(boxColor))
    local left = check:CreateTexture(nil, "BORDER")
    left:SetPoint("TOPLEFT"); left:SetPoint("BOTTOMLEFT"); left:SetWidth(1)
    left:SetColorTexture(unpack(boxColor))
    local right = check:CreateTexture(nil, "BORDER")
    right:SetPoint("TOPRIGHT"); right:SetPoint("BOTTOMRIGHT"); right:SetWidth(1)
    right:SetColorTexture(unpack(boxColor))
    showAll.tick = check:CreateTexture(nil, "OVERLAY")
    showAll.tick:SetSize(14, 14); showAll.tick:SetPoint("CENTER", check, "CENTER")
    showAll.tick:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\JournalCheck.tga")
    showAll.tick:SetVertexColor(0.15, 0.33, 0.27)
    showAll.label = Readable(PaperText(showAll, "GameFontNormal", "LEFT", check, "RIGHT", 9, 0, FF:LocalizedText("journal.show-all")), 15)
    showAll.label:SetTextColor(unpack(INK))
    showAll:SetScript("OnEnter", function(button)
        button.label:SetTextColor(0.48, 0.26, 0.08)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:AddLine(FF:LocalizedText("journal.known-finds"))
        GameTooltip:AddLine(FF:LocalizedText("journal.show-all-help"), 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(FF:LocalizedText("journal.show-all-references"),0.8,0.8,0.8,true)
        GameTooltip:Show()
    end)
    showAll:SetScript("OnLeave", function(button)
        button.label:SetTextColor(unpack(INK))
        GameTooltip:Hide()
    end)
    showAll:SetScript("OnClick", function()
        panel.showAllCatches = not panel.showAllCatches
        panel.scroll:SetVerticalScroll(0)
        FF:RenderCatchJournal()
    end)
    panel.showAllButton = showAll
    panel.showAllCatches = true
    local milestones = CreateFrame("Button", nil, page)
    milestones:SetSize(171, 25)
    milestones:SetPoint("TOPRIGHT", page, "TOPRIGHT", -20, -43)
    milestones.bg = Surface(milestones, 0.27, 0.18, 0.08, 0.12)
    Edge(milestones, { 0.52, 0.34, 0.15 })
    milestones.label = Readable(PaperText(milestones, "GameFontNormal", "CENTER",
        milestones, "CENTER", 0, 0, ""), 13)
    milestones.label:SetTextColor(unpack(INK))
    milestones:SetScript("OnClick", function()
        FF.db.campMilestones = FF.db.campMilestones == false
        local scroll = panel.scroll:GetVerticalScroll()
        for _, tab in ipairs(FF.guideTabs or {}) do
            if tab.id == "leveling" then FF:RenderGuide(tab); break end
        end
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    panel.campMilestonesButton = milestones
    panel.chefViewButtons = {}
    for _, view in ipairs({ { "campfire", FF:LocalizedText("journal.chef-campfire"), 87, -175 },
        { "meals", FF:LocalizedText("journal.chef-grilling"), 84, -87 }, { "guide", FF:LocalizedText("journal.chef-guide"), 63, -20 } }) do
        local button = CreateFrame("Button", nil, page)
        button:SetSize(view[3], 23)
        button:SetPoint("TOPRIGHT", page, "TOPRIGHT", view[4], -60)
        button.bg = Surface(button, 0.27, 0.18, 0.08, 0.12)
        Edge(button, { 0.52, 0.34, 0.15 })
        button.label = Readable(PaperText(button, "GameFontNormal", "CENTER", button, "CENTER", 0, 0, view[2]), 13)
        button:SetScript("OnClick", function() FF:SelectMasterChefView(view[1], true) end)
        panel.chefViewButtons[view[1]] = button
        button:Hide()
    end
    local rule = page:CreateTexture(nil, "BORDER")
    rule:SetPoint("TOPLEFT", page, "TOPLEFT", 19, -75)
    rule:SetPoint("TOPRIGHT", page, "TOPRIGHT", -19, -75)
    rule:SetHeight(1)
    rule:SetColorTexture(0.39, 0.23, 0.09, 0.48)
    panel.headerRule = rule
    local eventOrnament = CreateFrame("Frame", nil, page)
    eventOrnament:SetSize(20, 10)
    eventOrnament:SetPoint("CENTER", page, "TOP", 0, -75)
    eventOrnament:EnableMouse(false)
    -- Leave the page rule quiet; ornamentation belongs to the event frames.
    eventOrnament:Hide()
    panel.eventOrnament = eventOrnament
    local scroll = CreateFrame("ScrollFrame", nil, page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 31, -88)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -31, 13)
    scroll:EnableMouse(true)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(530, 1)
    scroll:SetScrollChild(content)
    local function ScrollPage(_, delta)
        local nextOffset = scroll:GetVerticalScroll() - delta * 48
        scroll:SetVerticalScroll(math.max(0, math.min(scroll:GetVerticalScrollRange(), nextOffset)))
    end
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", ScrollPage)
    page:EnableMouse(true)
    page:EnableMouseWheel(true)
    page:SetScript("OnMouseWheel", ScrollPage)
    panel.scroll = scroll
    panel.content = content
    panel.dynamic = {}
    panel.deferInitialCatches = true
    FF:PrepareFloatingWindow(panel, "journal", header)
    compactHeader:EnableMouse(true)
    if compactHeader.RegisterForDrag and panel.floatingDragStart then
        compactHeader:RegisterForDrag("LeftButton")
        compactHeader:SetScript("OnDragStart", panel.floatingDragStart)
        compactHeader:SetScript("OnDragStop", panel.floatingDragStop)
    end
    panel.scaleGrip:ClearAllPoints()
    panel.scaleGrip:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -12, 12)
    panel.scaleGrip:SetFrameLevel(panel:GetFrameLevel() + 6)
    panel:HookScript("OnHide", function()
        local placing = FF.masterChefCampPlacement ~= nil
        if not placing and FF.masterChefOwnsCampSession then
            local crafting = FF.masterChefCampCrafting ~= nil
            FF.masterChefCampCrafting = nil
            FF.masterChefCampCraftToken = (FF.masterChefCampCraftToken or 0) + 1
            FF:ReleaseMasterChefCampSession()
            if crafting then FF:SetMasterChefMessage("masterChefCampMessage","chef.message.craft-stopped") end
        end
        if not placing and FF.masterChefOwnsCookingSession then
            local quick = FF.masterChefCookingQuickActive or FF.masterChefCookingQuickPending
            FF.masterChefCookingActive = nil
            FF.masterChefCookingRemaining = nil
            FF.masterChefCraftToken = (FF.masterChefCraftToken or 0) + 1
            FF:ReleaseMasterChefCookingSession()
            if quick then
                FF:SetMasterChefMessage("masterChefQuickMessage","chef.message.cooking-stopped-click")
            else
                FF:SetMasterChefMessage("masterChefQueueMessage","chef.message.cooking-stopped-prepare")
            end
        end
        FF:StopJournalClock()
        panel.catchBuildSerial = (panel.catchBuildSerial or 0) + 1
        panel.catchBuildPending = nil
        FF.pendingJournalPresentation = nil
        if not placing then panel.backHistory = nil end
        UpdateJournalBackButton(panel)
    end)
    panel:HookScript("OnShow", function() FF:RefreshJournal(); FF:UpdateJournalClock() end)
    panel:HookScript("OnSizeChanged", function(_, width, height)
        if panel.suspendResponsiveLayout or not width then return end
        local shortNav = not panel.compactChef and (height or panel:GetHeight()) < 520
        if panel.lastResponsiveWidth and math.abs(width - panel.lastResponsiveWidth) < 0.5
            and panel.lastResponsiveShortNav == shortNav then return end
        panel.lastResponsiveWidth = width
        panel.lastResponsiveShortNav = shortNav
        if not panel:IsShown() then return end
        panel.responsiveSerial = (panel.responsiveSerial or 0) + 1
        local serial = panel.responsiveSerial
        if C_Timer and C_Timer.After then
            C_Timer.After(0.06, function()
                if panel.responsiveSerial == serial and panel:IsShown() then FF:ReflowJournal() end
            end)
        else
            FF:ReflowJournal()
        end
    end)
    panel.OnFloatingResizeFinished = function() FF:ReflowJournal() end
    if FF.CreateJournalSearch then FF:CreateJournalSearch(panel) end
    panel:Hide()
    FF:RegisterCombatCloseWindow("journal", panel)
    return panel
end

local function UpdateChefHeading(panel)
    local chefPage = FF.journalTab == "chef"
    panel.chefTitleIcon:SetShown(panel.compactChef and chefPage)
    panel.openMiniChefButton:SetShown(not panel.compactChef and chefPage)
    panel.pageTitle:ClearAllPoints()
    if chefPage then
        local icon = panel.compactChef and panel.chefTitleIcon or panel.openMiniChefButton
        panel.pageTitle:SetPoint("LEFT", icon, "RIGHT", 7, 0)
    else
        panel.pageTitle:SetPoint("TOPLEFT", panel.page, "TOPLEFT", 24,
            panel.compactChef and -14 or -18)
    end
    -- Keep the session title clear of the unchanged 130-unit History button.
    -- Other destinations retain their normal unconstrained heading width.
    panel.pageTitle:SetWidth(FF.journalTab == "session" and not panel.sessionHistoryShown
        and math.max(1, (panel.journalLayout and panel.journalLayout.contentWidth or 530) - 159) or 0)
    panel.pageSubtitle:ClearAllPoints()
    panel.pageSubtitle:SetPoint("TOPLEFT", panel.page, "TOPLEFT",
        panel.compactChef and 20 or 24,
        chefPage and panel.compactChef and -80 or chefPage and -72
            or panel.compactChef and -51 or -55)
    panel.pageSubtitle:SetWidth(chefPage and panel.compactChef
        and math.max(125, (panel.journalLayout.contentWidth or 548) - 40)
        or chefPage and math.min(320, math.max(125,
            (panel.journalLayout.contentWidth or 548) - 248))
        -- The parchment is 62 units wider than its inset list viewport.
        -- Use its real inner margins, reserving only a visible header control.
        or math.max(1, (panel.journalLayout and panel.journalLayout.contentWidth or 530) + 62
            - (FF.journalTab == "catch" and (24 + 20 + panel.showAllButton:GetWidth() + 10)
                or FF.journalTab == "leveling" and (24 + 20 + panel.campMilestonesButton:GetWidth() + 10)
                or 48)))
    panel.headerRule:ClearAllPoints()
    local ruleY = chefPage and panel.compactChef and -102 or chefPage and -92
        or -75
    panel.headerRule:SetPoint("TOPLEFT", panel.page, "TOPLEFT", 19, ruleY)
    panel.headerRule:SetPoint("TOPRIGHT", panel.page, "TOPRIGHT", -19, ruleY)
    local tabY = chefPage and panel.compactChef and -55 or chefPage and -60
        or -60
    for id, right in pairs({ campfire = -175, meals = -87, guide = -20 }) do
        local button = panel.chefViewButtons[id]
        button:ClearAllPoints()
        button:SetPoint("TOPRIGHT", panel.page, "TOPRIGHT", right, tabY)
    end
end

-- A page owns only the height its subtitle actually needs. A narrow window
-- alone must never reserve a second line on unrelated pages. Chef retains its
-- independent tab/status header and its existing full/Mini layout.
local function SetJournalPageSubtitle(panel, text, shorter, shortest, headerTop)
    local subtitle = panel.pageSubtitle
    if FF.journalTab == "chef" then subtitle:SetText(text); return end
    Readable(subtitle, 14)
    local width = subtitle:GetWidth()
    subtitle:SetWidth(0); subtitle:SetWordWrap(false)
    if subtitle.SetMaxLines then subtitle:SetMaxLines(0) end
    subtitle:SetText(text)
    for _, candidate in ipairs({ shorter, shortest }) do
        if subtitle:GetStringWidth() <= width then break end
        subtitle:SetText(candidate)
    end
    subtitle:SetWidth(width); subtitle:SetWordWrap(true)
    local ruleY = -math.max(75, math.ceil((headerTop or 55) + subtitle:GetStringHeight() + 4))
    local layout = panel.journalLayout
    layout.headerRuleY, layout.scrollTop, layout.narrowHeader = ruleY, ruleY - 13, ruleY < -75
    panel.headerRule:ClearAllPoints()
    panel.headerRule:SetPoint("TOPLEFT", panel.page, "TOPLEFT", 19, ruleY)
    panel.headerRule:SetPoint("TOPRIGHT", panel.page, "TOPRIGHT", -19, ruleY)
    local side = JournalScrollSide(panel)
    panel.scroll:ClearAllPoints()
    panel.scroll:SetPoint("TOPLEFT", panel.page, "TOPLEFT", side, layout.scrollTop)
    -- Full-width Rare cards sit five units right; use page padding for their ornate corners.
    panel.scroll:SetPoint("BOTTOMRIGHT", panel.page, "BOTTOMRIGHT", -(FF.journalTab == "rares" and 20 or side), 13)
end

local function JournalWidthStage(width)
    return width >= 530 and "full" or width >= 485 and "compact"
        or width >= 445 and "narrow" or "minimum"
end

local function JournalLayout(panel)
    local width = panel:GetWidth()
    local chef = FF.journalTab == "chef"
    local contentWidth = math.max(1, width - (panel.compactChef and 42
        or JOURNAL_NAV_WIDTH + (chef and 52 or 70)))
    local stage = JournalWidthStage(contentWidth)
    local layout = { contentWidth = contentWidth, stage = stage,
        narrowHeader = false, headerRuleY = -75, scrollTop = -88, chef = chef }
    panel.journalLayout = layout
    if not panel.compactChef then
        local short = panel:GetHeight() < 520
        local function NavPoint(frame, y, height)
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", panel.nav, "TOPLEFT", 7, y)
            frame:SetWidth(JOURNAL_NAV_WIDTH - 15)
            if height then frame:SetHeight(height) end
        end
        panel.navRecords:ClearAllPoints()
        panel.navRecords:SetPoint("TOPLEFT", panel.nav, "TOPLEFT", 10,
            short and -10 or -13)
        local recordStep, recordHeight = short and 28 or 34, short and 26 or 31
        for index, id in ipairs({"catch", "achievements", "session", "lifetime"}) do
            NavPoint(panel.navTabs[id], (short and -28 or -32) - (index - 1) * recordStep, recordHeight)
        end
        panel.navFieldHeading:ClearAllPoints()
        panel.navFieldHeading:SetPoint("TOPLEFT", panel.nav, "TOPLEFT", 10, short and -151 or -182)
        local guideTop, guideStep, guideHeight = short and -170 or -200, short and 25 or 36, short and 24 or 33
        for index, tab in ipairs(JournalGuideNavigation()) do
            NavPoint(panel.navTabs[tab.id], guideTop - (index - 1) * guideStep, guideHeight)
        end
        local guideCount = #(FF.guideTabs or {})
        NavPoint(panel.navTabs.events, guideTop - guideCount * guideStep, guideHeight)
        NavPoint(panel.navTabs.chef, guideTop - (guideCount + 1) * guideStep, guideHeight)
    end
    panel.content:SetWidth(contentWidth)
    if FF.LayoutJournalSearch then FF:LayoutJournalSearch(panel) end
    UpdateChefHeading(panel)
    return layout
end

local function JournalWidth(panel)
    return panel.journalLayout and panel.journalLayout.contentWidth or 530
end

local function JournalStage(panel)
    return panel.journalLayout and panel.journalLayout.stage or "full"
end

local function JournalTextSize(panel, full, minimum, width)
    local stage = width and JournalWidthStage(width) or JournalStage(panel)
    return stage == "full" and full or stage == "compact" and math.max(minimum, full - 1)
        or stage == "narrow" and math.max(minimum, full - 2)
        or minimum
end

local function FitJournalText(font, value, width)
    font:SetWidth(width)
    if font.SetWordWrap then font:SetWordWrap(false) end
    if font.SetMaxLines then font:SetMaxLines(1) end
    font:SetText(value or "")
    if not (font.GetStringWidth and type(value) == "string")
        or font:GetStringWidth() <= width then return end
    local chars = {}
    for char in value:gmatch("[%z\1-\127\194-\244][\128-\191]*") do chars[#chars + 1] = char end
    local low, high, best = 0, #chars, 0
    while low <= high do
        local mid = math.floor((low + high) / 2)
        font:SetText(table.concat(chars, "", 1, mid) .. "…")
        if font:GetStringWidth() <= width then best, low = mid, mid + 1
        else high = mid - 1 end
    end
    font:SetText(table.concat(chars, "", 1, best) .. "…")
end

local function SetJournalPresentation(panel, compact)
    if panel.compactChef == compact then return end
    panel.compactChef = compact
    panel.windowFill:SetShown(not compact)
    panel.outerBorder:SetShown(not compact)
    panel.headerDivider:SetShown(not compact)
    panel.navDivider:SetShown(not compact)
    panel.fullHeader:SetShown(not compact)
    panel.fullCloseButton:SetShown(not compact)
    panel.nav:SetShown(not compact)
    panel.compactHeader:SetShown(compact)
    panel.compactCloseButton:SetShown(compact)
    panel.page.innerBorder:SetShown(compact)
    UpdateChefHeading(panel)
    panel.page:ClearAllPoints()
    if compact then
        panel.page:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
        panel.page:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    else
        panel.page:SetPoint("TOPLEFT", panel.nav, "TOPRIGHT", -6, JOURNAL_PAGE_TOP_LIFT)
        panel.page:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -4,
            JOURNAL_LOWER_INSET - PARCHMENT_EDGE_INSET)
    end
    panel.suspendResponsiveLayout = true
    FF:UseFloatingWindowLayout(panel, compact and "masterChef" or "journal",
        compact and 590 or 750, compact and 510 or 560)
    panel.suspendResponsiveLayout = nil
    JournalLayout(panel)
    UpdateJournalBackButton(panel)
end

-- Text links share large pooled frames: a frame remaining under the pointer
-- does not prove that its previous link is still there after a scroll/reflow.
local function DismissGuideItemHover(panel)
    local owner = FF.journalQuestTooltipOwner or FF.journalItemTooltipOwner
    if owner and owner.journalGuideHover and owner.journalGuideHover.panel == panel then
        owner.journalGuideHover = nil
        FF:HideJournalQuestTooltip(owner)
        FF:HideJournalItemTooltip(owner)
    end
end

local function ClearDynamic(panel)
    DismissGuideItemHover(panel)
    panel.guideTooltipGeneration = (panel.guideTooltipGeneration or 0) + 1
    if FF.CloseJournalRoutePicker then FF:CloseJournalRoutePicker() end
    if panel.catchBuildPending then
        panel.catchBuildSerial = (panel.catchBuildSerial or 0) + 1
        panel.catchBuildPending = nil
    end
    for _, frame in ipairs(panel.dynamic) do
        frame:Hide()
        if not frame.pooled then frame:SetParent(nil) end
    end
    panel.dynamic = {}
    if panel.chefQueue then panel.chefQueue:Hide() end
    if panel.campQueue then panel.campQueue:Hide() end
    local layout = JournalLayout(panel)
    panel.scroll:ClearAllPoints()
    local side = JournalScrollSide(panel)
    panel.scroll:SetPoint("TOPLEFT", panel.page, "TOPLEFT", side, JournalScrollTop(panel))
    panel.scroll:SetPoint("BOTTOMRIGHT", panel.page, "BOTTOMRIGHT", -side, 13)
    panel.content:SetWidth(layout.contentWidth)
end

local function AddDynamic(panel, frame)
    panel.dynamic[#panel.dynamic + 1] = frame
    frame:Show()
    return frame
end

local function Hint(frame, title, body)
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title)
        GameTooltip:AddLine(body, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Pooled(panel, key, create)
    if not panel[key] then panel[key] = create(); panel[key].pooled = true end
    return AddDynamic(panel, panel[key])
end

local function Plural(count, key)
    return FF:LocalizedPlural("count."..key, count)
end
local function ShortDate(stamp)
    if not stamp or not date then return "—" end
    return FF:FormatTimestampDisplay(stamp, "short")
end
local function Percent(count, total)
    return total > 0 and FF:LocalizedText("format.display-percent", FF:LocalizedNumber(count * 100 / total, 1)) or "—"
end

local function SetCatchHeight(panel, height)
    panel.content:SetHeight(height)
    if panel.scroll.UpdateScrollChildRect then panel.scroll:UpdateScrollChildRect() end
    panel.scroll:SetVerticalScroll(math.min(panel.scroll:GetVerticalScroll(), panel.scroll:GetVerticalScrollRange()))
end

local function TopZones(entry)
    local first, second
    local function Before(a, b) return not b or a.count > b.count or (a.count == b.count and a.name < b.name) end
    for name, record in pairs(entry.locations) do
        local candidate = { name = name, count = record.count }
        if candidate.count > 0 then
            if Before(candidate, first) then second, first = first, candidate
            elseif Before(candidate, second) then second = candidate end
        end
    end
    if not first then return FF:GetFishingLocationDisplay(entry.zone) or FF:LocalizedText("catch.unknown-water") end
    local display = FF:GetFishingLocationDisplay(first.name)
    return second and (display .. "  •  " .. FF:GetFishingLocationDisplay(second.name)) or display
end

local COLUMNS = {
    { 8, 146, "LEFT", "catch.column.scope" }, { 166, 60, "RIGHT", "catch.column.caught" },
    { 238, 72, "RIGHT", "catch.column.share" }, { 322, 96, "RIGHT", "catch.column.best" },
    { 430, 92, "LEFT", "catch.column.last" },
}
local function TableCells(parent, header)
    local cells = {}
    for index, column in ipairs(COLUMNS) do
        local font = Readable(PaperText(parent, header and "GameFontNormal" or "GameFontHighlight",
            "LEFT", parent, "LEFT", column[1], 0, header and FF:LocalizedText(column[4],"%") or ""), 14)
        font:SetWidth(column[2]); font:SetJustifyH(column[3])
        font:SetTextColor(unpack(header and INK or SOFT_INK))
        if not header then font:SetWordWrap(false); if font.SetMaxLines then font:SetMaxLines(1) end end
        cells[index] = font
    end
    return cells
end
local function LayoutTableCells(cells, width, header, stage)
    local factor = (width - 28) / 530
    local short = { "catch.column.scope", "catch.column.short-caught", false, "catch.column.short-best", "catch.column.last" }
    for index, font in ipairs(cells) do
        local column = COLUMNS[index]
        font:ClearAllPoints()
        font:SetPoint("LEFT", font:GetParent(), "LEFT", 14 + math.floor(column[1] * factor + 0.5), 0)
        font:SetWidth(math.max(32, math.floor(column[2] * factor + 0.5)))
        Readable(font, JournalTextSize(FF.journalPanel, 14, 12))
        if header then font:SetText(stage == "minimum" and (short[index] and FF:LocalizedText(short[index]) or "%") or FF:LocalizedText(column[4],"%")) end
    end
end
local function Divider(parent)
    local line = parent:CreateTexture(nil, "BORDER")
    line:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 0)
    line:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 0)
    line:SetHeight(1); line:SetColorTexture(0.48, 0.30, 0.13, 0.25)
    return line
end
-- A receiving child handles one wheel event directly; no hooked ancestor
-- handler or nested table scroll may also consume/move that same gesture.
local function CatchListWheel(panel, frame)
    if not panel.catchWheelHandler then
        panel.catchWheelHandler = function(_, delta)
            local scroll = panel.scroll
            scroll:SetVerticalScroll(math.max(0, math.min(scroll:GetVerticalScrollRange(),
                scroll:GetVerticalScroll() - delta * 48)))
        end
    end
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", panel.catchWheelHandler)
end
local function CatchDetails(panel)
    local detail = CreateFrame("Frame", nil, panel.content)
    detail.pooled = true; detail:SetWidth(530); detail.rows = {}
    local header = CreateFrame("Frame", nil, detail)
    header:SetSize(530, 36); header:SetPoint("TOPLEFT")
    header:EnableMouse(false)
    header.cells = TableCells(header, true); detail.header = header; Divider(header)
    detail.scroll = CreateFrame("ScrollFrame", nil, detail)
    detail.scroll:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    detail.scroll:SetPoint("BOTTOMRIGHT", detail, "BOTTOMRIGHT", 0, 0)
    detail.body = CreateFrame("Frame", nil, detail.scroll)
    detail.body:SetSize(530, 1); detail.scroll:SetScrollChild(detail.body)
    detail.scroll:EnableMouse(true)
    for _, frame in ipairs({ detail, header, detail.scroll, detail.body }) do CatchListWheel(panel, frame) end
    return detail
end
local function FillCatchDetails(panel, detail, item)
    local width = JournalWidth(panel)
    detail:SetWidth(width); detail.header:SetWidth(width); detail.body:SetWidth(width)
    LayoutTableCells(detail.header.cells, width, true, JournalStage(panel))
    local headerHeight = 36
    for _, cell in ipairs(detail.header.cells) do headerHeight = math.max(headerHeight, cell:GetStringHeight() + 12) end
    detail.header:SetHeight(headerHeight)
    if detail.itemID ~= item.id or detail.revision ~= FF.catchRevision then
        detail.scopes = FF:GetCatchScopes(item.entry)
        if detail.itemID ~= item.id then detail.scroll:SetVerticalScroll(0) end
        detail.itemID, detail.revision = item.id, FF.catchRevision
    end
    local current = FF:GetFishingLocation()
    local rowHeight = math.max(30, math.ceil(22 * FF:GetJournalTextScale() + 8))
    for index, scope in ipairs(detail.scopes) do
        local row = detail.rows[index]
        if not row then
            row = CreateFrame("Frame", nil, detail.body); detail.rows[index] = row
            row:SetSize(530, 30); row:SetPoint("TOPLEFT", detail.body, "TOPLEFT", 0, -(index - 1) * 30)
            row.tint = Surface(row, 0.47, 0.32, 0.12, 0)
            row.cells = TableCells(row); Divider(row)
            Hint(row, "", "")
            CatchListWheel(panel, row)
            row:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:AddLine(button.displayName)
                GameTooltip:AddLine(FF:LocalizedText(button.scope.name == FF:GetFishingLocation() and "catch.scope.current" or "catch.scope.recorded"), 0.8, 0.8, 0.8)
                local record = button.scope.record
                GameTooltip:AddLine(FF:LocalizedText("catch.scope.count-share",record.count,Percent(record.count, button.scope.total)), 0.8, 0.8, 0.8)
                GameTooltip:AddLine(FF:LocalizedText("catch.scope.best-last",record.best or "—",ShortDate(record.last)), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
        end
        row.scope = scope
        row.displayName = index == 1 and FF:LocalizedText("catch.scope.lifetime") or FF:GetFishingLocationDisplay(scope.name)
        row:SetSize(width, rowHeight); row:ClearAllPoints()
        row:SetPoint("TOPLEFT", detail.body, "TOPLEFT", 0, -(index - 1) * rowHeight)
        LayoutTableCells(row.cells, width, false, JournalStage(panel))
        row.tint:SetColorTexture(0.47, 0.32, 0.12, index > 1 and scope.name == current and 0.17 or (index == 1 and 0.08 or 0))
        local record = scope.record
        local values = { row.displayName, FF:FormatDisplayCount(record.count, true), Percent(record.count, scope.total),
            record.best and FF:FormatDisplayCount(record.best, true) or "—", ShortDate(record.last) }
        for column, value in ipairs(values) do
            FitJournalText(row.cells[column], value, row.cells[column]:GetWidth())
        end
        row:Show()
    end
    for index = #detail.scopes + 1, #detail.rows do detail.rows[index]:Hide() end
    detail.body:SetHeight(#detail.scopes * rowHeight)
    -- Keep every scope reachable through the main list, with no inner scroll.
    detail.scroll:SetHeight(detail.body:GetHeight()); detail.scroll:SetVerticalScroll(0)
    detail:SetHeight(headerHeight + 2 + detail.body:GetHeight())
end

local QUALITY_INK = {
    [0] = { 0.36, 0.36, 0.36 },
    [2] = { 0.08, 0.58, 0.08 },
    [3] = { 0.05, 0.32, 0.65 },
    [4] = { 0.43, 0.18, 0.66 },
    [5] = { 0.65, 0.31, 0.04 },
}
local function CatchItemQuality(itemID)
    local quality
    local itemInfo = C_Item and C_Item.GetItemInfo
    if itemInfo then quality = select(3, itemInfo(itemID)) end
    if quality == nil and GetItemInfo and GetItemInfo ~= itemInfo then quality = select(3, GetItemInfo(itemID)) end
    if quality == nil and C_Item and C_Item.GetItemQualityByID then quality = C_Item.GetItemQualityByID(itemID) end
    return tonumber(quality)
end
local function CatchNameColor(quality, undiscovered)
    if quality == nil then return unpack(undiscovered and SOFT_INK or INK) end
    if quality == 1 then return unpack(INK) end -- White item text would disappear against parchment.
    if GetItemQualityColor then
        local r, g, b = GetItemQualityColor(quality)
        if type(r) == "number" and type(g) == "number" and type(b) == "number" then
            return r * 0.62, g * 0.62, b * 0.62
        end
    end
    return unpack(QUALITY_INK[quality] or INK)
end
local function RequestCatchQuality(self, itemID)
    if not (C_Item and C_Item.RequestLoadItemDataByID) then return end
    self.requestedCatchQualityItems = self.requestedCatchQualityItems or {}
    if self.requestedCatchQualityItems[itemID] then return end
    self.requestedCatchQualityItems[itemID] = true
    if not pcall(C_Item.RequestLoadItemDataByID, itemID) then self.requestedCatchQualityItems[itemID] = nil end
end
local function UpdateCatchRowItemVisuals(self, row, collection, requestMissing)
    local itemID = row.itemID
    local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID) or (GetItemIcon and GetItemIcon(itemID))
    local quality = CatchItemQuality(itemID)
    row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    row.icon:SetDesaturated(row.unknown); row.icon:SetAlpha(row.unknown and 0.58 or 1)
    self:FrameJournalItemIcon(row,row.icon,itemID,40,false,row.unknown)
    row.rareSurround = row.itemSurround
    row.name:SetTextColor(CatchNameColor(quality, row.unknown))
    row.name:SetAlpha(row.unknown and 0.76 or 1)
    if requestMissing and quality == nil then RequestCatchQuality(self, itemID) end
end
function FF:RefreshCatchItemQuality(itemID)
    local panel = self.journalPanel
    if not panel or self.journalTab ~= "catch" then return end
    local row = panel.catchRowsByID and panel.catchRowsByID[itemID]
    if row and row:IsShown() then UpdateCatchRowItemVisuals(self, row, self:GetJournalCatchDefinition(itemID), false) end
end
local MASTERY_NUMERALS = { "I", "II", "III", "IV", "V", "VI" }
local function ReleaseCatchMasteryTooltip(owner)
    if GameTooltip.GetOwner and GameTooltip:GetOwner() == owner then GameTooltip:Hide() end
end
local function OwnCatchMasteryTooltip(frame)
    frame:SetScript("OnLeave", ReleaseCatchMasteryTooltip)
    frame:SetScript("OnHide", ReleaseCatchMasteryTooltip)
end
local function UpdateCatchMastery(self, badge, count)
    self:UpdateCatchMasteryBadge(badge, count)
    local state = self:GetCatchProgression(count)
    badge.description = self:LocalizedText("catch.mastery.earned",MASTERY_NUMERALS[state.tier] or self:LocalizedText("catch.mastery.unearned"))
        .. "\n" .. self:LocalizedPlural("catch.mastery.lifetime",state.count)
        .. "\n" .. (state.nextMilestone and self:LocalizedText("catch.mastery.next",MASTERY_NUMERALS[state.tier+1],state.nextMilestone) or self:LocalizedText("catch.mastery.complete"))
        .. "\n" .. self:LocalizedText("catch.mastery.milestones")
    return state
end
local function CatchHeaderHeight(panel,itemID)
    -- Compact headers measure visible decoration, never transparent canvases.
    local layout=FF:GetJournalCatchIconLayout(itemID,40)
    return math.max(74,math.ceil(layout.height+16),math.ceil((JournalTextSize(panel, 16, 14)
        + JournalTextSize(panel, 12, 11)) * FF:GetJournalTextScale() * 1.5 + 20)) - 8
end
local function CatchRow(panel)
    local row = CreateFrame("Button", nil, panel.content)
    row.pooled = true; row:SetSize(530, 48); row:RegisterForClicks("LeftButtonUp")
    CatchListWheel(panel, row)
    row.bg = Surface(row, 0.67, 0.51, 0.30, 0.07)
    row.border = FF:CreateJournalFrame(row)
    local hi = row:CreateTexture(nil, "HIGHLIGHT"); hi:SetAllPoints(row); hi:SetColorTexture(0.48, 0.30, 0.13, 0.09)
    row.icon = row:CreateTexture(nil, "ARTWORK"); row.icon:SetSize(40, 40); row.icon:SetPoint("LEFT", row, "LEFT", 23, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93); RoundIcon(row.icon)
    FF:FrameJournalItemIcon(row,row.icon,0,40,true)
    row.rareSurround = row.itemSurround
    row.name = Readable(PaperText(row, "GameFontNormal", "TOPLEFT", row.icon, "TOPRIGHT", 10, -3, ""), 15)
    row.name:SetWidth(345); row.name:SetJustifyH("LEFT"); row.name:SetTextColor(unpack(INK))
    row.place = Readable(PaperText(row, "GameFontHighlight", "BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 10, 4, ""), 14)
    row.place:SetWidth(385); row.place:SetJustifyH("LEFT"); row.place:SetWordWrap(false)
    row.place:SetTextColor(unpack(SOFT_INK))
    row.count = PaperText(row, "GameFontNormalLarge", "RIGHT", row, "RIGHT", -25, 0, "")
    row.count:SetTextColor(0.5, 0.29, 0.08)
    row.count:SetWordWrap(false)
    if row.count.SetMaxLines then row.count:SetMaxLines(1) end
    row.masteryBadge = FF:CreateCatchMasteryBadge(row)
    CatchListWheel(panel, row.masteryBadge)
    OwnCatchMasteryTooltip(row.masteryBadge)
    row.masteryBadge:SetSize(36, 36); row.masteryBadge:SetPoint("RIGHT", row, "RIGHT", -32, 0)
    row.masteryBadge.marker:ClearAllPoints()
    row.masteryBadge.marker:SetPoint("CENTER", row.masteryBadge, "TOPLEFT", 18, -26.64)
    local badgeFont, _, badgeFlags = row.masteryBadge.marker:GetFont()
    FF:SetDisplayFont(row.masteryBadge.marker, badgeFont, 10, badgeFlags)
    -- The child owns mastery hover only; the rest of the header retains item
    -- hover and comparison handling. A badge click still toggles the catch.
    row.masteryBadge:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            panel.expandedCatches[row.itemID] = not panel.expandedCatches[row.itemID]
            FF:RenderCatchJournal()
        end
    end)
    row.indicator = row:CreateTexture(nil, "ARTWORK"); row.indicator:SetSize(12, 7)
    row.indicator:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    row:SetScript("OnEnter", function(button)
        FF:BeginJournalItemTooltip(button, button.itemID, button.itemName)
        FF:AddJournalCatchClassifications(GameTooltip,button.itemID)
        GameTooltip:AddLine(FF:LocalizedText(button.unknown and (panel.expandedCatches[button.itemID] and "catch.help.hide-locations" or "catch.help.show-locations")
            or (panel.expandedCatches[button.itemID] and "catch.help.hide-details" or "catch.help.show-details")), 0.7, 0.7, 0.7)
        FF:FinishJournalItemTooltip(button)
    end)
    row:SetScript("OnLeave", function(button) FF:HideJournalItemTooltip(button) end)
    row:SetScript("OnClick", function(button)
        panel.expandedCatches[button.itemID] = not panel.expandedCatches[button.itemID]
        FF:RenderCatchJournal()
    end)
    return row
end
local function CatchGuidanceRow(detail, panel, label, asset)
    local row = CreateFrame("Frame", nil, detail)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetTexture(FF.journalAssets[asset])
    -- Each 64px export has a 56px visible medallion. Keep its baked frame;
    -- the transparent canvas is not the icon column's visible width.
    row.icon:SetSize(26 * 64 / 56, 26 * 64 / 56)
    row.icon:SetPoint("CENTER", row, "TOPLEFT", 27, -17)
    row.heading = Readable(PaperText(row, "GameFontNormal", "TOPLEFT", row, "TOPLEFT", 50, -8, label), 15)
    row.heading:SetTextColor(unpack(CATCH_HEADING_INK))
    row.value = Readable(PaperText(row, "GameFontHighlight", "TOPLEFT", row, "TOPLEFT", 195, -8, ""), 14)
    row.value:SetTextColor(unpack(SOFT_INK))
    for _, font in ipairs({ row.heading, row.value }) do
        font:SetJustifyH("LEFT"); font:SetJustifyV("TOP"); font:SetWordWrap(true)
    end
    row.divider = row:CreateTexture(nil, "BORDER")
    row.divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 14, 0)
    row.divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -14, 0)
    row.divider:SetHeight(1); row.divider:SetColorTexture(0.48, 0.30, 0.13, 0.18)
    EnableGuideLinks(row, panel); CatchListWheel(panel, row)
    row:SetScript("OnHide", function()
        row.linkHovered = nil
        if GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() == row then GameTooltip:Hide() end
    end)
    return row
end

local function CatchLocationDetail(panel)
    local detail = CreateFrame("Frame", nil, panel.content)
    detail.pooled = true; detail:SetWidth(530)
    CatchListWheel(panel, detail)
    detail.fields, detail.guidanceRows = {}, {}
    for index, definition in ipairs({ { "catch.guidance.waters", "CJ01" }, { "catch.guidance.skill", "CJ04" },
        { "catch.guidance.method", "CJ02" }, { "catch.guidance.condition", "CJ05" }, { "catch.guidance.uses", "CJ03" } }) do
        local row = CatchGuidanceRow(detail, panel, FF:LocalizedText(definition[1]), definition[2])
        row.headingKey = definition[1]
        detail.guidanceRows[index] = row
        if index <= 4 then detail.fields[index] = row else detail.uses = row; row.lines = {} end
    end
    detail:SetScript("OnHide", function()
        for _, row in ipairs(detail.guidanceRows) do row:Hide() end
    end)
    return detail
end

local function LayoutCatchGuidanceRow(row, detail, y, labelWidth, valueX, valueWidth)
    row:SetWidth(detail:GetWidth()); row.contentY = y
    row:ClearAllPoints(); row:SetPoint("TOPLEFT", detail, "TOPLEFT", 0, -y)
    row.heading:SetWidth(labelWidth)
    local valueHeight = 0
    if row.lines then
        for index, line in ipairs(row.lines) do if line:IsShown() then
            line:SetWidth(valueWidth); line:ClearAllPoints()
            line:SetPoint("TOPLEFT", row, "TOPLEFT", valueX, -8 - valueHeight)
            valueHeight = valueHeight + line:GetStringHeight()
            valueHeight=valueHeight+3
        end end
        valueHeight = math.max(0, valueHeight - 3)
    else
        row.value:SetWidth(valueWidth); row.value:ClearAllPoints()
        row.value:SetPoint("TOPLEFT", row, "TOPLEFT", valueX, -8)
        valueHeight = row.value:GetStringHeight()
    end
    -- Visible medallion ends 30 units below the row top; transparent canvas
    -- padding is not content. Preserve inter-row spacing independently.
    row.contentBottom = math.max(30, math.ceil(8 + math.max(row.heading:GetStringHeight(), valueHeight)))
    row:SetHeight(math.max(34, math.ceil(8 + math.max(row.heading:GetStringHeight(), valueHeight) + 7)))
    row:Show(); return y + row:GetHeight()
end

local function FillCatchLocationDetail(detail, guide, ownWaters, itemID)
    local panel = FF.journalPanel
    local width = JournalWidth(panel)
    detail:SetWidth(width)
    local widest = 0
    for index, row in ipairs(detail.guidanceRows) do
        row.heading:SetText(FF:LocalizedText(index == 1 and not guide and "catch.guidance.your-waters" or row.headingKey))
        Readable(row.heading, JournalTextSize(panel, 15, 13))
        Readable(row.value, JournalTextSize(panel, 14, 12))
        row.heading:SetWidth(0)
        widest = math.max(widest, row.heading:GetStringWidth())
    end
    local labelWidth = math.min(math.ceil(widest + 1), math.floor((width - 76) * 0.36))
    local valueX = 50 + labelWidth + 12
    local valueWidth = width - valueX - 14
    detail.labelWidth, detail.valueX = labelWidth, valueX
    local fields
    if guide then
        local skills = panel.journalSkills or FF:GetJournalSkills()
        local faction = FF:GetJournalFaction()
        local entry=FF:GetJournalCatchDefinition(itemID)
        fields = { FF:GetJournalCatchReferenceText(entry,"waters",faction),
            guide.skill and FF:LocalizedText("catch.guidance.skill-bonuses",ColorRequirement(skills, tostring(guide.skill), "Fishing", guide.skill)) or FF:LocalizedText("catch.guidance.not-verified"),
            FF:GetJournalCatchReferenceText(entry,"method",faction), FF:GetJournalCatchReferenceText(entry,"condition",faction) }
    else
        fields = { ownWaters or FF:LocalizedText("catch.guidance.no-waters"), FF:LocalizedText("catch.guidance.not-verified"), FF:LocalizedText("catch.guidance.not-verified") }
    end
    local y, visible = 0, {}
    for index, row in ipairs(detail.fields) do
        local value = fields[index]
        local present = value ~= nil and value ~= ""
        row:SetShown(present); row.heading:SetShown(present); row.value:SetShown(present)
        if present then
            row.value:SetText(FF:GuideLinkText(value, true, true))
            y = LayoutCatchGuidanceRow(row, detail, y, labelWidth, valueX, valueWidth)
            visible[#visible + 1] = row
        end
    end
    local uses, useRow = FF:GetJournalCatchUses(itemID), detail.uses
    panel.catchUsesDetails = panel.catchUsesDetails or {}; panel.catchUsesDetails[detail.index] = useRow
    useRow.itemID = itemID; useRow.value:Hide()
    for _, line in ipairs(useRow.lines) do line:Hide() end
    useRow:SetShown(#uses > 0); useRow.heading:SetShown(#uses > 0)
    if #uses > 0 then
        for index, use in ipairs(uses) do
            local line = useRow.lines[index]
            if not line then
                line = Readable(PaperText(useRow, "GameFontHighlight", "TOPLEFT", useRow, "TOPLEFT", valueX, -8, ""), 14)
                line:SetWordWrap(true); line:SetJustifyH("LEFT"); line:SetJustifyV("TOP")
                line:SetTextColor(unpack(SOFT_INK)); useRow.lines[index] = line
            end
            local target = {}; for key, value in pairs(use.target) do target[key] = value end
            target.tooltip = FF:GetJournalCatchUseDisplayText(use,"detail")
            target.displayLabel = FF:GetJournalCatchUseDisplayText(use,"label")
            Readable(line, JournalTextSize(panel, 14, 12))
            local text = FF:GuideTargetLink(target, target.displayLabel)
            -- Stable link IDs must not freeze a previous faction's sources.
            local linked = FF:GuideLinkTarget(text:match("|H(ffguide:%d+)|h"))
            if linked then linked.tooltip, linked.displayLabel = target.tooltip, target.displayLabel end
            local effect=(use.target.kind=="meal" or use.target.kind=="campinfo") and FF:GetJournalFoodDisplayEffects(use.target.id)
            if effect then text=text.."\n"..effect.summary end
            -- The name remains the existing link on its own line. Its dark
            -- summary starts at the same inset; measure both with natural wrap.
            line:SetText(text); line:Show()
        end
        y = LayoutCatchGuidanceRow(useRow, detail, y, labelWidth, valueX, valueWidth)
        visible[#visible + 1] = useRow
    end
    for index, row in ipairs(visible) do row.divider:SetShown(index < #visible) end
    local last = visible[#visible]
    detail:SetHeight((last and last.contentY + last.contentBottom or 0) + 9)
end
local function RenderCatchItem(self, panel, index, item, y)
    local row = panel.catchRows[index]
    if not row then row = CatchRow(panel); panel.catchRows[index] = row end
    AddDynamic(panel, row); row:ClearAllPoints(); row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
    row.itemID = item.id
    row.contentY = y
    row.unknown = item.collection ~= nil
    row.itemName = self:GetJournalItemDisplayName(item.id,row.unknown and item.collection[2] or (item.entry.name or ("Item " .. item.id)))
    panel.catchRowsByID[item.id] = row
    local collection = item.collection or self:GetJournalCatchDefinition(item.id)
    row.bg:SetColorTexture(0.67, 0.51, 0.30, row.unknown and (index % 2 == 1 and 0.07 or 0.035) or (index % 2 == 1 and 0.08 or 0.04))
    local width = JournalWidth(panel)
    row:SetWidth(width)
    local recordedCount = item.entry and item.entry.count or 0
    row:SetHeight(CatchHeaderHeight(panel,item.id))
    local decoration=self:GetJournalCatchIconLayout(item.id,40)
    row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT",row,"LEFT",23,decoration.centerY)
    Readable(row.count, JournalTextSize(panel, 16, 14))
    row.count:SetText(row.unknown and "" or FF:FormatDisplayCount(recordedCount))
    row.count:SetWidth(0)
    local countWidth = math.max(40, (row.count.GetStringWidth and row.count:GetStringWidth()
        or #tostring(recordedCount) * 10 * self:GetJournalTextScale()) + 2)
    row.count:SetWidth(countWidth); row.count:SetJustifyH("RIGHT")
    row.count:ClearAllPoints(); row.count:SetPoint("RIGHT", row, "RIGHT", -78, 0)
    local nameWidth = math.max(1, width - 78 - countWidth - 10 - 84)
    Readable(row.name, JournalTextSize(panel, 16, 14))
    FitJournalText(row.name,not row.unknown and not item.entry.name and self:LocalizedText("common.item-id",item.id) or row.itemName,nameWidth)
    UpdateCatchRowItemVisuals(self, row, collection, true)
    Readable(row.place, JournalTextSize(panel, 12, 11))
    FitJournalText(row.place, row.unknown and self:LocalizedText("catch.not-caught") or TopZones(item.entry),
        nameWidth)
    local textY = (row:GetHeight() - row.name:GetStringHeight() - 3 - row.place:GetStringHeight()) / 2
    row.name:ClearAllPoints(); row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 84, -textY)
    row.place:ClearAllPoints(); row.place:SetPoint("TOPLEFT", row, "TOPLEFT", 84, -textY-row.name:GetStringHeight()-3)
    row.place:SetAlpha(row.unknown and 0.7 or 1)
    UpdateCatchMastery(self, row.masteryBadge, recordedCount)
    local expanded = panel.expandedCatches[item.id]
    row.border:SetShown(not expanded)
    if row.group then row.group:SetShown(expanded == true) end
    SetJournalChevron(row.indicator, expanded)
    y = y + row:GetHeight()
    if expanded then
        do
            panel.catchMasteryDetails = panel.catchMasteryDetails or {}
            local mastery = panel.catchMasteryDetails[index]
            if not mastery then
                mastery = CreateFrame("Frame", nil, panel.content); mastery.pooled = true
                mastery.label = Readable(PaperText(mastery, "GameFontNormal", "TOPLEFT", mastery, "TOPLEFT", 74, -8, self:LocalizedText("catch.mastery.title")), 15)
                mastery.label:SetTextColor(unpack(INK)); mastery.label:SetJustifyH("LEFT")
                mastery.label:SetWordWrap(false)
                mastery.badge = self:CreateCatchMasteryBadge(mastery)
                mastery.badge:SetPoint("LEFT", mastery, "LEFT", 14, 0)
                OwnCatchMasteryTooltip(mastery.badge)
                mastery.bar=CreateFrame("Frame",nil,mastery); mastery.bar:SetHeight(14)
                mastery.track=Surface(mastery.bar,0.12,0.085,0.045,0.8)
                mastery.fill=mastery.bar:CreateTexture(nil,"ARTWORK")
                mastery.fill:SetPoint("TOPLEFT",mastery.bar,"TOPLEFT",1,-1); mastery.fill:SetHeight(12)
                mastery.fill:SetColorTexture(0.72,0.48,0.08,0.95)
                mastery.bar.border=self:CreateJournalFrame(mastery.bar,false,7)
                mastery.fraction=Readable(PaperText(mastery,"GameFontNormal","TOPRIGHT",mastery,"TOPRIGHT",-13,0,""),12)
                mastery.fraction:SetJustifyH("RIGHT"); mastery.fraction:SetTextColor(unpack(INK))
                mastery.remaining = Readable(PaperText(mastery,"GameFontHighlight","TOPLEFT",mastery,"TOPLEFT",74,0,""),12)
                mastery.remaining:SetTextColor(unpack(SOFT_INK)); mastery.remaining:SetJustifyH("LEFT")
                Hint(mastery.bar,self:LocalizedText("catch.mastery.title"),"")
                CatchListWheel(panel,mastery); CatchListWheel(panel,mastery.badge); CatchListWheel(panel,mastery.bar)
                OwnCatchMasteryTooltip(mastery.bar)
                mastery.bar:SetScript("OnEnter",function(bar)
                    GameTooltip:SetOwner(bar,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("catch.mastery.title"))
                    GameTooltip:AddLine(mastery.badge.description,0.9,0.9,0.9,true); GameTooltip:Show()
                end)
                Divider(mastery)
                panel.catchMasteryDetails[index] = mastery
            end
            local state = UpdateCatchMastery(self, mastery.badge, recordedCount)
            mastery:SetWidth(width)
            Readable(mastery.label, JournalTextSize(panel, 15, 13))
            mastery.label:SetWordWrap(self:GetResolvedLocale()~="enUS")
            mastery.label:SetText(self:LocalizedText("catch.mastery.heading",MASTERY_NUMERALS[state.tier] and self:LocalizedText("catch.mastery.tier",MASTERY_NUMERALS[state.tier]) or self:LocalizedText("catch.mastery.unearned")))
            mastery.fraction:SetText(state.nextMilestone and self:LocalizedText("catch.mastery.toward",state.count-state.reached,state.nextMilestone-state.reached,MASTERY_NUMERALS[state.tier+1]) or self:LocalizedText("catch.mastery.mastered"))
            Readable(mastery.fraction,JournalTextSize(panel,12,11))
            local fractionWidth=mastery.fraction:GetStringWidth()+2
            if self:GetResolvedLocale()~="enUS" then fractionWidth=math.min(fractionWidth,math.floor((width-88)*.45)) end
            mastery.fraction:SetWidth(fractionWidth); mastery.fraction:ClearAllPoints()
            mastery.fraction:SetPoint("TOPRIGHT",mastery,"TOPRIGHT",-14,-8)
            mastery.label:SetWidth(width-88-fractionWidth-8)
            local barY=8+math.max(mastery.fraction:GetStringHeight(),mastery.label:GetStringHeight())+5
            local barWidth=width-88
            mastery.bar:SetWidth(barWidth); mastery.bar:ClearAllPoints()
            mastery.bar:SetPoint("TOPLEFT",mastery,"TOPLEFT",74,-barY)
            mastery.fill:SetWidth(math.max(.01,(barWidth-2)*state.fraction)); mastery.fill:SetShown(state.fraction>0)
            Readable(mastery.remaining,JournalTextSize(panel,12,11)); mastery.remaining:SetWidth(width-88)
            mastery.remaining:ClearAllPoints(); mastery.remaining:SetPoint("TOPLEFT",mastery,"TOPLEFT",74,-barY-19)
            mastery.remaining:SetText(self:LocalizedPlural(state.nextMilestone and "catch.mastery.remaining" or "catch.mastery.total",state.nextMilestone and state.remaining or state.count))
            mastery:SetHeight(math.max(64,barY+19+mastery.remaining:GetStringHeight()+8))
            mastery:ClearAllPoints(); mastery:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
            AddDynamic(panel, mastery); y = y + mastery:GetHeight() + 4
        end
        if not row.unknown then
            local stats = panel.catchDetails[index]
            if not stats then stats = CatchDetails(panel); panel.catchDetails[index] = stats end
            FillCatchDetails(panel, stats, item)
            AddDynamic(panel, stats)
            stats:ClearAllPoints(); stats:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
            y = y + stats:GetHeight() + 8
        end
        local detail = panel.locationDetails[index]
        if not detail then detail = CatchLocationDetail(panel); panel.locationDetails[index] = detail end
        detail.index = index
        FillCatchLocationDetail(detail, collection and collection[3],
            not collection and item.entry and TopZones(item.entry), item.id)
        AddDynamic(panel, detail)
        detail:ClearAllPoints(); detail:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        y = y + detail:GetHeight() + 8
        if not row.group then
            row.group=CreateFrame("Frame",nil,row); row.group:EnableMouse(false)
            row.group:SetPoint("TOPLEFT",row,"TOPLEFT",0,0)
            row.group.border=self:CreateJournalFrame(row.group)
        end
        row.group:SetWidth(width); row.group:SetHeight(y-row.contentY-8); row.group:Show()
    end
    return y + (expanded and -6 or 2)
end
local function CatchJournalRarity(item)
    local tier = FF:GetJournalCatchClassifications(item.id).rarity
    return tier == "ultra" and 2 or (tier == "rare" and 1 or 0)
end
local function CatchJournalName(item)
    return item.entry and (item.entry.name or ("Item " .. item.id))
        or item.collection and item.collection[2] or ("Item " .. item.id)
end
function FF:RenderCatchJournal()
    local panel = self.journalPanel
    ClearDynamic(panel)
    panel.catchRows, panel.catchDetails, panel.expandedCatches = panel.catchRows or {}, panel.catchDetails or {}, panel.expandedCatches or {}
    panel.catchRowsByID = {}
    panel.locationDetails = panel.locationDetails or {}
    local items = {}
    for _, item in ipairs(self:GetCatchJournalItems()) do items[#items + 1] = item end
    local catalogue = self:GetJournalCatchCatalogue()
    local discovered = 0
    for _, entry in ipairs(catalogue) do
        local record = self.db.journal[entry[1]]
        if record and record.count > 0 then discovered = discovered + 1 end
    end
    panel.showAllButton.tick:SetShown(panel.showAllCatches or false)
    if panel.showAllCatches then
        for _, entry in ipairs(catalogue) do
            local record = self.db.journal[entry[1]]
            if not record or record.count == 0 then
                items[#items + 1] = { id = entry[1], collection = entry }
            end
        end
    end
    table.sort(items, function(a, b)
        local aCaught, bCaught = a.entry ~= nil, b.entry ~= nil
        if aCaught ~= bCaught then return aCaught end
        local aRarity = CatchJournalRarity(a)
        local bRarity = CatchJournalRarity(b)
        if aRarity ~= bRarity then return aRarity > bRarity end
        local aName, bName = FF:FoldSearchText(CatchJournalName(a)), FF:FoldSearchText(CatchJournalName(b))
        if aName ~= bName then return aName < bName end
        return tostring(a.id) < tostring(b.id)
    end)
    panel.pageTitle:SetText(FF:LocalizedText("journal.catch-title"))
    local catches = Plural(self.journalCount, "catch")
    local locations = Plural(self.journalLocations, "location")
    SetJournalPageSubtitle(panel, self:LocalizedText("journal.catch-summary",catches,discovered,#catalogue,Plural(self.journalLocations,"fishing-location")),
        self:LocalizedText("journal.catch-summary",catches,discovered,#catalogue,locations),
        self:LocalizedText("journal.catch-summary-short",catches,discovered,locations))
    panel.catchRevision, panel.locationRevision = self.catchRevision, self.journalLocationRevision
    panel.foodEffectRevision=self.journalFoodEffectRevision
    panel.renderedTab = "catch"
    if #items == 0 then
        local empty = Pooled(panel, "emptyCatch", function()
            local empty = CreateFrame("Frame", nil, panel.content)
            empty:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -48); empty:SetSize(JournalWidth(panel), 250)
            local icon = empty:CreateTexture(nil, "ARTWORK"); icon:SetSize(60, 60); icon:SetPoint("TOP", empty, "TOP", 0, -8)
            icon:SetTexture(self.roundIcon)
            local title = PaperText(empty, "GameFontNormalLarge", "TOP", icon, "BOTTOM", 0, -16, FF:LocalizedText("journal.first-catch"))
            title:SetTextColor(unpack(INK))
            local first,second=FF:LocalizedText("journal.empty-quote"):match("^(.-)\n(.*)$")
            local quote = Readable(PaperText(empty, "GameFontHighlight", "TOP", title, "BOTTOM", 0, -13, first), 15)
            quote:SetWidth(math.min(440, JournalWidth(panel) - 25)); quote:SetJustifyH("CENTER"); quote:SetTextColor(unpack(SOFT_INK))
            local ending = Readable(PaperText(empty, "GameFontHighlight", "TOP", quote, "BOTTOM", 0, -5, second), 15)
            ending:SetWidth(math.min(440, JournalWidth(panel) - 25)); ending:SetJustifyH("CENTER"); ending:SetTextColor(unpack(SOFT_INK))
            empty.quote, empty.ending = quote, ending
            return empty
        end)
        empty:SetWidth(JournalWidth(panel))
        empty.quote:SetWidth(math.min(440, JournalWidth(panel) - 25))
        empty.ending:SetWidth(math.min(440, JournalWidth(panel) - 25))
        SetCatchHeight(panel, 320); return
    end
    local expanded = false
    for _, isOpen in pairs(panel.expandedCatches) do
        if isOpen then expanded = true; break end
    end
    if panel.deferInitialCatches and not expanded and #items > FIRST_CATCH_ROWS and C_Timer and C_Timer.After then
        local serial = (panel.catchBuildSerial or 0) + 1
        panel.catchBuildSerial = serial
        panel.catchBuildPending = true
        local offsets,total={},0
        for index,item in ipairs(items) do offsets[index]=total; total=total+CatchHeaderHeight(panel,item.id)+2 end
        SetCatchHeight(panel, total)
        local nextIndex = 1
        local function BuildBatch()
            if panel.catchBuildSerial ~= serial or self.journalPanel ~= panel or panel.renderedTab ~= "catch" then return end
            if nextIndex > 1 and self.IsCameraSearchBusy and self:IsCameraSearchBusy() then
                C_Timer.After(0.1, BuildBatch)
                return
            end
            local batchSize = nextIndex == 1 and FIRST_CATCH_ROWS or CATCH_ROWS_PER_FRAME
            local last = math.min(#items, nextIndex + batchSize - 1)
            for index = nextIndex, last do RenderCatchItem(self, panel, index, items[index], offsets[index]) end
            nextIndex = last + 1
            if nextIndex <= #items then
                C_Timer.After(CATCH_BUILD_INTERVAL, BuildBatch)
            else
                panel.catchBuildPending = nil
                panel.deferInitialCatches = false
            end
        end
        BuildBatch()
        return
    end
    local y = 0
    for index, item in ipairs(items) do y = RenderCatchItem(self, panel, index, item, y) end
    if #items > FIRST_CATCH_ROWS then panel.deferInitialCatches = false end
    SetCatchHeight(panel, math.max(1, y))
end

local function LifetimeDuration(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    if seconds == 0 then return "—" end
    return FF:FormatElapsedDisplay(seconds, false)
end
local function RecordTimes(self, lifetime)
    local record = lifetime and self.db.lifetime or self.session
    local seconds = lifetime and self:CurrentFishingSeconds() or self:CurrentSessionSeconds()
    return seconds, lifetime and self:CurrentFishingSeconds(true) or seconds, lifetime and record.rateCatches or record.catches
end
local function CatchesPerHour(seconds, count)
    return seconds > 0 and FF:LocalizedNumber(count * 3600 / seconds, 1) or "—"
end
local function UpdateRecordClockValues(panel, seconds, rateSeconds, rateCount)
    panel.metricCards[1].value:SetText(LifetimeDuration(seconds))
    panel.metricCards[5].value:SetText(CatchesPerHour(rateSeconds, rateCount))
end
local function CoinPerHour(copper, seconds)
    local amount = FF:FormatFishingHourlyCoinAmount(copper, seconds)
    return amount and FF:LocalizedText("journal.hourly", amount) or FF:LocalizedText("journal.hourly-missing")
end
local function RecordMetrics(self, lifetime, compact)
    local record = lifetime and self.db.lifetime or self.session
    local seconds, rateSeconds, rateCount = RecordTimes(self, lifetime)
    local denominator = lifetime and record.verifiedCasts or record.casts
    local catchCount = lifetime and record.catchCount or record.catches
    local metrics = {
        { lifetime and FF:LocalizedText("journal.metric.time-fishing") or FF:LocalizedText("journal.metric.session-time"), LifetimeDuration(seconds), STATS_MEDIA .. "TimeFishing",
            lifetime and FF:LocalizedText("journal.metric-help.time-fishing") or FF:LocalizedText("journal.metric-help.session-time") },
        { FF:LocalizedText("journal.metric.casts"), FF:FormatDisplayCount(record.casts), STATS_MEDIA .. "Casts", FF:LocalizedText("journal.metric-help.casts") },
        { lifetime and FF:LocalizedText("journal.metric.catch-count") or FF:LocalizedText("journal.metric.catches"), FF:FormatDisplayCount(catchCount), STATS_MEDIA .. "CatchCount", FF:LocalizedText("journal.metric-help.catches") },
        { FF:LocalizedText("journal.metric.success"), Percent(record.successfulCasts, denominator), STATS_MEDIA .. "SuccessRate",
            FF:LocalizedText("journal.metric-help.success") },
        { FF:LocalizedText("journal.metric.catches-hour"), CatchesPerHour(rateSeconds, rateCount), STATS_MEDIA .. "CatchesPerHour",
            lifetime and FF:LocalizedText("journal.metric-help.lifetime-hour") or FF:LocalizedText("journal.metric-help.session-hour") },
        { FF:LocalizedText("journal.metric.cast-loot"), record.timedCatches > 0 and FF:LocalizedText("format.display-seconds", FF:LocalizedNumber(record.elapsedTotal / record.timedCatches, 1)) or "—", STATS_MEDIA .. "AverageCastToLoot",
            FF:LocalizedText("journal.metric-help.cast-loot") },
    }
    metrics[5].shortLabelKey="journal.metric-short.catches-hour"
    metrics[6].shortLabelKey="journal.metric-short.cast-loot"
    if compact then return metrics end
    if lifetime then
        metrics[7] = { FF:LocalizedText("journal.metric.sessions"), FF:FormatDisplayCount(record.sessions), STATS_MEDIA .. "Sessions", FF:LocalizedText("journal.metric-help.sessions") }
        metrics[8] = { FF:LocalizedText("journal.metric.unique"), FF:FormatDisplayCount(self.journalUnique), STATS_MEDIA .. "UniqueCatches", FF:LocalizedText("journal.metric-help.unique") }
    end
    local values = self:GetCatchValues(lifetime)
    local vendorNote = FF:LocalizedText("journal.metric-help.vendor")
    if values.vendorMissing > 0 then vendorNote = vendorNote .. FF:LocalizedText("journal.metric-help.vendor-loading") end
    local auctionNote = values.hasAuctionSource and FF:LocalizedText("journal.metric-help.auction")
        or FF:LocalizedText("journal.metric-help.auction-install")
    if values.hasAuctionSource and values.auctionMissing > 0 then
        auctionNote = auctionNote .. FF:LocalizedText("journal.auction-fallback",self:FormatFishingCoinAmount(values.auctionFallback))
        if values.vendorMissing > 0 then auctionNote = auctionNote .. FF:LocalizedText("journal.metric-help.vendor-loading-line") end
    end
    metrics[#metrics + 1] = { FF:LocalizedText("journal.metric.vendor"), self:FormatFishingCoinAmount(values.vendor) .. (values.vendorMissing > 0 and "*" or ""), VENDOR_ICON, vendorNote, true,
        CoinPerHour(values.vendor, seconds), values.vendor }
    metrics[#metrics + 1] = { FF:LocalizedText("journal.metric.auction"), values.hasAuctionSource and (self:FormatFishingCoinAmount(values.auction)
        .. (values.auctionMissing > 0 and "*" or "")) or FF:LocalizedText("journal.auction-install"), AUCTION_ICON, auctionNote, true,
        CoinPerHour(values.hasAuctionSource and values.auction or nil, seconds), values.hasAuctionSource and values.auction or nil }
    if lifetime then metrics[8].shortLabelKey="journal.metric-short.unique" end
    return metrics
end
local function UpdateRecordValues(panel, metrics)
    for index, metric in ipairs(metrics) do
        local card = panel.metricCards[index]
        card.value:SetText(metric[2])
        if card.hourly then
            card.hourly:SetText(metric[6] or "")
            card.hourlyCopper = metric[7]
        end
        if metric[5] then Hint(card, metric[1], metric[4]) end
    end
end
local function RenderRecordMetrics(panel, metrics, sessionLayout)
    panel.metricCards = panel.metricCards or {}
    local width = JournalWidth(panel)
    local gap = JournalStage(panel) == "full" and 11 or JournalStage(panel) == "compact" and 9 or 7
    local cardWidth = (width - gap - (sessionLayout and 0 or 9)) / 2
    local rowHeight = math.max(60, math.ceil(60 * FF:GetJournalTextScale()))
    for index, metric in ipairs(metrics) do
        local card = panel.metricCards[index]
        if not card then
            card = CreateFrame("Frame", nil, panel.content); card.pooled = true; panel.metricCards[index] = card
            card:SetSize(255, METRIC_CARD_HEIGHT)
            Divider(card)
            card.icon = card:CreateTexture(nil, "ARTWORK"); card.icon:SetSize(33, 33); card.icon:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -3)
            card.icon:SetTexCoord(0, 1, 0, 1); RoundIcon(card.icon)
            card.label = Readable(PaperText(card, "GameFontHighlight", "TOPLEFT", card, "TOPLEFT", 51, -7, ""), 14)
            card.label:SetTextColor(unpack(SOFT_INK))
            card.value = PaperText(card, "GameFontNormalLarge", "BOTTOMLEFT", card, "BOTTOMLEFT", 11, 9, "")
            card.value:SetTextColor(unpack(INK))
            card.value:SetWidth(238)
            card.valueSize = (journalFonts[card.value] or {}).size or 16
        end
        card:SetSize(cardWidth, rowHeight)
        card.icon:ClearAllPoints()
        card.icon:SetSize(42,42)
        card.icon:SetPoint("LEFT", card, "LEFT", 8, 0)
        FF:FrameJournalRoundIcon(card.icon,42)
        card.label:ClearAllPoints(); card.label:SetPoint("TOPLEFT", card, "TOPLEFT", 60, -7)
        card.label:SetJustifyH("LEFT")
        AddDynamic(panel, card); card.icon:SetTexture(metric[3])
        Readable(card.label, JournalTextSize(panel, 14, 12))
        FitJournalText(card.label, JournalStage(panel) == "minimum"
            and (metric.shortLabelKey and FF:LocalizedText(metric.shortLabelKey) or metric[1]) or metric[1], cardWidth - 68)
        Readable(card.value, metric[5] and 14 or card.valueSize)
        card.value:SetWidth(cardWidth - 68)
        card.value:SetJustifyH("LEFT")
        if card.value.SetWordWrap then card.value:SetWordWrap(metric[5] == true) end
        card.value:ClearAllPoints()
        card.value:SetPoint("TOPLEFT", card, "TOPLEFT", 60, -math.ceil(25 * FF:GetJournalTextScale()))
        if metric[5] and not card.hourly then
            card.hourly = Readable(PaperText(card, "GameFontHighlight", "BOTTOMLEFT", card, "BOTTOMLEFT", 11, 4, ""), 12)
            card.hourly:SetTextColor(unpack(SOFT_INK))
            card.hourly:SetWidth(238)
        end
        if card.hourly then
            Readable(card.hourly, 12)
            card.hourly:ClearAllPoints()
            card.hourly:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 60, 4)
            card.hourly:SetWidth(cardWidth - 68)
            card.hourly:SetJustifyH("LEFT")
            card.hourly:SetShown(metric[5] == true)
            card.hourly:SetText(metric[6] or "")
            card.hourlyCopper = metric[7]
        end
        card.value:SetText(metric[2]); Hint(card, metric[1], metric[4])
        if metric[5] then
            card:SetHeight(math.max(rowHeight,math.ceil(25 * FF:GetJournalTextScale())
                + card.value:GetStringHeight() + card.hourly:GetStringHeight() + 8))
        end
    end
    -- Paired rows share measured height; unusually long money values can wrap
    -- without covering the hourly note or shortening the displayed amount.
    local y=0
    for index=1,#metrics,2 do
        local left,right=panel.metricCards[index],panel.metricCards[index+1]
        local height=math.max(left:GetHeight(),right and right:GetHeight() or 0)
        for column,card in ipairs({left,right}) do
            card:SetHeight(height); card:ClearAllPoints()
            card:SetPoint("TOPLEFT",panel.content,"TOPLEFT",(column-1)*(cardWidth+gap),-y)
        end
        y=y+height+4
    end
    return y-4
end

do
    local TRACKER_WIDTH, TRACKER_HEIGHT = 224, 210
    local PALETTE = FF.sessionWindowPalette
    local TRACKER_INSET, TRACKER_BODY_BOTTOM = 13, 26
    local SCROLLBAR_INSET, SCROLLBAR_GAP = 7, 6
    local TRACKER_GAP = 8
    local TRACKER_METRICS = {
        {"time", "journal.metric.session-time"}, {"casts", "journal.metric.casts"},
        {"catches", "journal.metric.catches"}, {"success", "journal.metric.success"},
        {"rate", "journal.metric-short.catches-hour"}, {"gold", "journal.tracker-gold-hour"},
    }
    local ART = "Interface\\AddOns\\ForeverFishing\\Media\\"
    local L = function(key, ...) return FF:LocalizedText(key, ...) end

    local function TrackerText(parent, template, value)
        local text = parent:CreateFontString(nil, "OVERLAY", template)
        text:SetJustifyH("LEFT"); text:SetText(value or "")
        return text
    end

    local function WrapTrackerText(text)
        text:SetWordWrap(true)
        if text.SetNonSpaceWrap then text:SetNonSpaceWrap(true) end
    end

    local function TrackerTextWidth(text)
        if text.GetUnboundedStringWidth then return math.ceil(text:GetUnboundedStringWidth()) end
        local width = text:GetWidth()
        text:SetWidth(0)
        local measured = math.ceil(text:GetStringWidth())
        text:SetWidth(width)
        return measured
    end

    local function TrackerOptionsButton(panel)
        local button = CreateFrame("Button", nil, panel, "UIPanelCloseButtonNoScripts")
        button:SetSize(panel.close:GetWidth(), panel.close:GetHeight())
        button:SetPoint("RIGHT", panel.close, "LEFT", -4, 0)
        local normal, pushed = button:GetNormalTexture(), button:GetPushedTexture()
        -- Keep the native plate, bevel, inset and highlight. Cover only the X
        -- with a strip of the same atlas's red face before laying in the lines.
        normal:SetDrawLayer("BACKGROUND"); pushed:SetDrawLayer("BACKGROUND")
        local face = button:CreateTexture(nil, "ARTWORK")
        local inset = button:GetWidth() * 5 / 24
        face:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
        face:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
        local function PaintFace(texture)
            local atlas = texture.GetAtlas and texture:GetAtlas()
            local info = atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
            local file = info and (info.file or info.filename)
            if file and info.leftTexCoord and info.rightTexCoord and info.topTexCoord and info.bottomTexCoord then
                local left, top = info.leftTexCoord, info.topTexCoord
                local width, height = info.rightTexCoord - left, info.bottomTexCoord - top
                face:SetTexture(file)
                face:SetTexCoord(left + width * 0.21, left + width * 0.23,
                    top + height * 5 / 24, top + height * 19 / 24)
                return
            end
            face:SetColorTexture(0.27, 0.045, 0.025, 1)
        end
        PaintFace(normal)
        button:HookScript("OnMouseDown", function(_, key) if key == "LeftButton" then PaintFace(pushed) end end)
        button:HookScript("OnMouseUp", function() PaintFace(normal) end)
        button:HookScript("OnLeave", function() PaintFace(normal) end)
        button:HookScript("OnHide", function() PaintFace(normal) end)
        local icon = button:CreateTexture(nil, "OVERLAY")
        icon:SetSize(14, 14)
        -- Align the glyph with the visual center of the native inset.
        icon:SetPoint("CENTER", face, "CENTER", -1, 1)
        icon:SetTexture(ART .. "TrackerOptionsLines.tga")
        icon:SetVertexColor(0.90, 0.70, 0.39)
        button.icon = icon
        return button
    end

    local function PaintTrackerHeading(button, selected, hovered)
        button.accent:SetShown(selected)
        if selected then
            local gold = PALETTE.gold
            button.label:SetTextColor(gold[1], hovered and 0.90 or gold[2], hovered and 0.64 or gold[3])
        else
            button.label:SetTextColor(hovered and 0.78 or 0.62, hovered and 0.69 or 0.56, hovered and 0.52 or 0.44)
        end
    end

    local function TrackerHeading(panel, label, click)
        local button = CreateFrame("Button", nil, panel)
        button.label = TrackerText(button, "GameFontNormal", label)
        WrapTrackerText(button.label)
        button.accent = FF:CreateSessionHeaderAccent(button)
        button.accent:Hide()
        button:SetScript("OnClick", click)
        button:SetScript("OnEnter", function(control) PaintTrackerHeading(control, control.accent:IsShown(), true) end)
        button:SetScript("OnLeave", function(control) PaintTrackerHeading(control, control.accent:IsShown(), false) end)
        return button
    end

    local function SizeTrackerHeadings(panel)
        local stats, catches = panel.statsHeading, panel.catchesHeading
        local padding = TRACKER_INSET + 4
        -- Leave room for both fixed-size controls, the heading gaps and the drag strip.
        local budget = math.max(44, panel:GetWidth() - 76)
        local statsWidth = math.min(TrackerTextWidth(stats.label) + padding,
            math.max(budget / 2, budget - TrackerTextWidth(catches.label) - padding))
        local catchesWidth = math.min(TrackerTextWidth(catches.label) + padding, budget - statsWidth)
        stats:SetWidth(statsWidth); catches:SetWidth(catchesWidth)

        local height = 36
        for _, button in ipairs({stats, catches}) do
            local label = button.label
            label:SetWidth(math.max(1, button:GetWidth() - padding))
            label:ClearAllPoints()
            label:SetPoint("LEFT", button, "LEFT", TRACKER_INSET, 0)
            button.accent:SetSize(2, 16)
            button.accent:ClearAllPoints()
            button.accent:SetPoint("LEFT", button, "LEFT", 5, 0)
            height = math.max(height, math.ceil(label:GetStringHeight()) + 8)
        end
        stats:SetHeight(height); catches:SetHeight(height)
        panel.trackerHeader:SetHeight(height)
        return height
    end

    local function StopTrackerClock(self)
        if self.sessionTrackerClock then
            self.sessionTrackerClock:Cancel()
            self.sessionTrackerClock = nil
        end
    end

    local function SetTrackerValue(card, value)
        if card.value:GetText() == value then return false end
        local height = card.value:GetStringHeight()
        card.value:SetText(value)
        return card:IsShown() and height ~= card.value:GetStringHeight()
    end

    local function TrackerGoldTooltip(card)
        GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L("journal.tracker-gold-hour"))
        GameTooltip:AddLine(card.fullGold)
        GameTooltip:AddLine(card.goldNote, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end

    local function FitTrackerGold(card)
        local width = card:GetWidth()
        if not card.fullGold or width <= 0 or (card.goldFitWidth == width and card.goldFitRate == card.goldRate) then return false end
        card.goldFitWidth, card.goldFitRate = width, card.goldRate
        local frame, value = card.goldValueFrame, card.value
        local previousHeight = value:GetStringHeight() * (card.goldValueScale or 1)
        frame:SetScale(1)
        value:SetText(card.fullGold)
        local scale = 1
        if card.goldRate > 0 and TrackerTextWidth(value) > width then
            value:SetText(FF:FormatFishingCoinAmount(card.goldRate, 11, true))
            -- An exceptionally large rate may still need a smaller footprint after copper is omitted.
            scale = math.min(1, width / TrackerTextWidth(value))
        end
        card.goldValueScale = scale
        frame:SetScale(scale)
        local logicalWidth, height = width / scale, value:GetStringHeight()
        frame:SetSize(logicalWidth, math.max(1, height))
        value:SetWidth(logicalWidth)
        return previousHeight ~= height * scale
    end

    local function SetTrackerGold(self, panel, card, seconds, note)
        local rate = self:GetFishingHourlyCopper(panel.goldCopper, seconds) or 0
        local changedNote, changedRate = note and card.goldNote ~= note, card.goldRate ~= rate
        if note then card.goldNote = note end
        local resized = false
        if changedRate then
            card.goldRate = rate
            card.fullGold = self:FormatFishingHourlyCoinAmount(panel.goldCopper, seconds, true)
            resized = FitTrackerGold(card)
        end
        if (changedRate or changedNote) and GameTooltip:GetOwner() == card then TrackerGoldTooltip(card) end
        return resized
    end

    local function PaintTrackerTime(self, panel)
        local seconds, rateSeconds, rateCount = RecordTimes(self, false)
        local cards = panel.metricCards
        local resized = cards[1]:IsShown() and SetTrackerValue(cards[1], LifetimeDuration(seconds))
        if cards[5]:IsShown() then resized = SetTrackerValue(cards[5], CatchesPerHour(rateSeconds, rateCount)) or resized end
        if cards[6]:IsShown() then resized = SetTrackerGold(self, panel, cards[6], seconds) or resized end
        return resized
    end

    local function PaintTrackerGold(self, panel, card, seconds)
        local copper, sources, unpriced = self:GetSessionGoldValue()
        local note = L("journal.tracker-valuation", sources)
        if unpriced then note = note .. "\n" .. L("journal.tracker-unpriced") end
        panel.goldCopper = copper
        return SetTrackerGold(self, panel, card, seconds, note)
    end

    local function ClearTrackerItemTooltip(scroll)
        local owner = FF.journalItemTooltipOwner
        if owner and owner.trackerScroll == scroll then FF:HideJournalItemTooltip(owner) end
    end

    local function TrackerScrollWheel(scroll, delta)
        scroll:SetVerticalScroll(math.max(0, math.min(scroll:GetVerticalScrollRange(), scroll:GetVerticalScroll() - delta * 40)))
    end

    local function TrackerBodyHeight(panel)
        return panel.historyShown and panel.catchBodyHeight or panel.statsBodyHeight
    end

    local function SetTrackerScrollOffset(panel, offset)
        local scroll = panel.trackerScroll
        local clamped = math.min(offset, scroll:GetVerticalScrollRange())
        if clamped ~= scroll:GetVerticalScroll() then scroll:SetVerticalScroll(clamped) end
    end

    local function LayoutTrackerScroll(panel, offset)
        local bottom = TrackerBodyHeight(panel)
        if panel.settingsShown then
            local menu = panel.menu
            menu:ClearAllPoints()
            menu:SetPoint("TOPLEFT", panel.trackerContent, "TOPLEFT", 0, -bottom - TRACKER_GAP)
            bottom = bottom + TRACKER_GAP + menu:GetHeight()
        end
        panel.trackerContent:SetHeight(bottom)
        local scroll = panel.trackerScroll
        if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
        SetTrackerScrollOffset(panel, offset)
    end

    local function LayoutTrackerCatchRows(panel, width)
        local y = 0
        for index = 1, panel.catchCount do
            local row = panel.catchRows[index]
            row:SetWidth(width)
            if not row.itemSurround then FF:FrameJournalItemIcon(row, row.icon, row.itemID, 24, true) end
            local quantityWidth = math.min(math.max(24, TrackerTextWidth(row.quantity) + 2), width * 0.4)
            row.quantity:SetWidth(quantityWidth)
            row.name:SetWidth(math.max(1, width - quantityWidth - 50))
            local textHeight = math.max(row.name:GetStringHeight(), row.quantity:GetStringHeight())
            local height = math.max(36, math.ceil(textHeight + 8))
            row:SetHeight(height)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", panel.catchList, "TOPLEFT", 0, -y)
            y = y + height
        end
        panel.catchBodyHeight = y > 0 and y
            or math.max(40, math.ceil(panel.catchEmpty:GetStringHeight() + 20))
    end

    local function TrackerCatchRow(panel, index)
        local scroll, content = panel.trackerScroll, panel.catchList
        local row = CreateFrame("Frame", nil, content)
        row.trackerScroll = scroll
        row.bg = Surface(row, 0.30, 0.19, 0.08, index % 2 == 0 and 0.22 or 0.12)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.name = TrackerText(row, "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", row, "LEFT", 40, 0)
        WrapTrackerText(row.name)
        row.quantity = TrackerText(row, "GameFontNormalSmall")
        row.quantity:SetPoint("RIGHT", row, "RIGHT", -5, 0)
        WrapTrackerText(row.quantity)
        row.quantity:SetJustifyH("RIGHT")
        row.quantity:SetTextColor(unpack(PALETTE.gold))
        row:EnableMouse(true); row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta) TrackerScrollWheel(scroll, delta) end)
        row:SetScript("OnEnter", function(frame)
            FF:BeginJournalItemTooltip(frame, frame.itemID, frame.itemName)
            FF:FinishJournalItemTooltip(frame)
        end)
        row:SetScript("OnLeave", function(frame) FF:HideJournalItemTooltip(frame) end)
        panel.catchRows[index] = row
        return row
    end

    local function PaintTrackerCatches(self, panel)
        local scroll, rows = panel.trackerScroll, panel.catchRows
        local sameSession = panel.catchSession == self.session
        local offset = sameSession and scroll:GetVerticalScroll() or 0
        panel.catchSession = self.session
        local items = {}
        for key, record in pairs(self.session.records) do
            local id, count = tonumber(key), tonumber(record.count)
            if id and count and count > 0 then
                local saved = self.db.journal[id] or self.db.journal[tostring(id)]
                local name = self:GetJournalItemDisplayName(id, saved and saved.name or L("common.item-id", id))
                items[#items + 1] = {id = id, count = count, name = name}
            end
        end
        table.sort(items, function(a, b) return a.name < b.name or (a.name == b.name and a.id < b.id) end)
        for index, item in ipairs(items) do
            local row = rows[index] or TrackerCatchRow(panel, index)
            if row.itemID ~= item.id and self.journalItemTooltipOwner == row then self:HideJournalItemTooltip(row) end
            row.itemID, row.itemName = item.id, item.name
            row.icon:SetTexture(self:GetJournalItemIcon(item.id))
            local quality = CatchItemQuality(item.id)
            if quality == nil then RequestCatchQuality(self, item.id) end
            local r, g, b
            if quality and GetItemQualityColor then r, g, b = GetItemQualityColor(quality) end
            if type(r) == "number" and type(g) == "number" and type(b) == "number" then
                row.name:SetTextColor(r, g, b)
            else row.name:SetTextColor(0.94, 0.94, 0.88) end
            row.quantity:SetText("×" .. self:FormatDisplayCount(item.count))
            row.name:SetText(item.name)
            row:Show()
        end
        for index = #items + 1, #rows do
            local row = rows[index]
            if self.journalItemTooltipOwner == row then self:HideJournalItemTooltip(row) end
            row:Hide()
        end
        panel.catchCount = #items
        panel.catchEmpty:SetShown(#items == 0)
        LayoutTrackerCatchRows(panel, panel.trackerContent:GetWidth())
        LayoutTrackerScroll(panel, offset)
    end

    local function CreateTrackerBody(panel)
        local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
        scroll:EnableMouseWheel(true)
        scroll:SetScript("OnMouseWheel", TrackerScrollWheel)
        scroll:HookScript("OnVerticalScroll", ClearTrackerItemTooltip)
        scroll:HookScript("OnHide", ClearTrackerItemTooltip)
        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(1, 1)
        scroll:SetScrollChild(content)
        panel.trackerScroll, panel.trackerContent = scroll, content
        local catches = CreateFrame("Frame", nil, content)
        catches:SetPoint("TOPLEFT", content, "TOPLEFT")
        catches:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT")
        panel.catchList, panel.catchRows, panel.catchCount = catches, {}, 0
        panel.catchEmpty = TrackerText(catches, "GameFontHighlight", L("journal.tracker-no-catches"))
        panel.catchEmpty:SetJustifyH("CENTER"); WrapTrackerText(panel.catchEmpty)
    end

    local function SizeTrackerStatColumns(panel, hidden, available)
        local cards = {}
        for index, card in ipairs(panel.metricCards) do
            local visible = not panel.historyShown and not hidden[TRACKER_METRICS[index][1]]
            card:SetShown(visible)
            if visible then cards[#cards + 1] = card end
        end
        panel.statsEmpty:SetShown(not panel.historyShown and #cards == 0)
        if #cards == 0 then return end

        local room = #cards > 1 and math.max(2, available - TRACKER_GAP) or available
        local leftWidth = #cards > 1 and math.floor(room / 2) or room
        if #cards > 1 and cards[#cards].goldValueFrame then
            -- Allow a compact two-denomination amount a little more room at the small end.
            local reserve = math.min(12, math.max(0, math.floor((94 - leftWidth) / 2)), math.max(0, leftWidth - 56))
            leftWidth = leftWidth + (#cards % 2 == 1 and reserve or -reserve)
        end
        for index, card in ipairs(cards) do
            local width = index % 2 == 1 and leftWidth or room - leftWidth
            card:SetWidth(width)
            card.label:SetWidth(width)
            if card.goldValueFrame then FitTrackerGold(card)
            else card.value:SetWidth(width) end
        end
    end

    local function LayoutTrackerStatRows(panel)
        local cards, heights = {}, {}
        for _, card in ipairs(panel.metricCards) do
            if card:IsShown() then
                local row = math.floor(#cards / 2) + 1
                cards[#cards + 1] = card
                local textHeight = card.label:GetStringHeight() + card.value:GetStringHeight() * (card.goldValueScale or 1) + 5
                heights[row] = math.max(heights[row] or 0, 36, math.ceil(textHeight))
            end
        end
        if #cards == 0 then return math.ceil(math.max(26, panel.statsEmpty:GetStringHeight() + 6)) end

        local height = TRACKER_GAP * (#heights - 1)
        for _, rowHeight in ipairs(heights) do height = height + rowHeight end
        local extra = not panel.settingsShown and #heights > 1
            and math.min(12, math.max(0, panel.trackerScroll:GetHeight() - height) / (#heights - 1)) or 0
        local content = panel.trackerContent
        local left = cards[1]:GetWidth()
        local y = 0
        for index, rowHeight in ipairs(heights) do
            for column = 1, 2 do
                local card = cards[(index - 1) * 2 + column]
                if card then
                    card:SetHeight(rowHeight)
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", content, "TOPLEFT", (column - 1) * (left + TRACKER_GAP), -y)
                end
            end
            y = y + rowHeight + TRACKER_GAP + extra
        end
        return height + extra * (#heights - 1)
    end

    local function ReflowTrackerStatRows(panel)
        panel.statsBodyHeight = LayoutTrackerStatRows(panel)
        LayoutTrackerScroll(panel, panel.trackerScroll:GetVerticalScroll())
    end

    function FF:RefreshSessionTracker()
        local panel = self.sessionTrackerPanel
        if not (panel and PanelVisible(panel) and self.session) then return end
        if panel.confirmSession and panel.confirmSession ~= self.session then
            panel.confirmSession, panel.confirmAction = nil, nil
            self:LayoutSessionTracker()
            return
        end
        if panel.historyShown then
            PaintTrackerCatches(self, panel)
            StopTrackerClock(self)
            return
        end
        local metrics = RecordMetrics(self, false, true)
        local resized = false
        for index = 1, 5 do
            resized = SetTrackerValue(panel.metricCards[index], metrics[index][2]) or resized
        end
        local gold = panel.metricCards[6]
        if gold:IsShown() then resized = PaintTrackerGold(self, panel, gold, self:CurrentSessionSeconds()) or resized end
        if resized then ReflowTrackerStatRows(panel) end
        local ticking = self.session.activeStarted and
            (panel.metricCards[1]:IsShown() or panel.metricCards[5]:IsShown() or gold:IsShown())
        if not ticking then
            StopTrackerClock(self)
        elseif not self.sessionTrackerClock and C_Timer and C_Timer.NewTicker then
            self.sessionTrackerClock = C_Timer.NewTicker(1, function()
                if not PanelVisible(panel) or not (self.session and self.session.activeStarted) then
                    StopTrackerClock(self)
                    return
                end
                if PaintTrackerTime(self, panel) then ReflowTrackerStatRows(panel) end
            end)
        end
    end

    local function CreateTrackerCards(panel)
        local content = panel.trackerContent
        panel.metricCards = {}
        for index, metric in ipairs(TRACKER_METRICS) do
            local card = CreateFrame("Frame", nil, content)
            card.label = TrackerText(card, "GameFontHighlightSmall", L(metric[2]))
            WrapTrackerText(card.label); card.label:SetTextColor(unpack(PALETTE.text))
            card.label:SetPoint("TOPLEFT", card, "TOPLEFT")
            if metric[1] == "gold" then
                local frame = CreateFrame("Frame", nil, card)
                frame:SetPoint("TOPLEFT", card.label, "BOTTOMLEFT", 0, -2)
                card.goldValueFrame = frame
                card.value = TrackerText(frame, "GameFontNormalLarge")
                card.value:SetPoint("TOPLEFT", frame, "TOPLEFT")
                card.value:SetWordWrap(false)
                if card.value.SetNonSpaceWrap then card.value:SetNonSpaceWrap(false) end
                card:EnableMouse(true)
                card:SetScript("OnEnter", TrackerGoldTooltip)
                local function HideGoldTooltip()
                    if GameTooltip:GetOwner() == card then GameTooltip:Hide() end
                end
                card:SetScript("OnLeave", HideGoldTooltip)
                card:SetScript("OnHide", HideGoldTooltip)
            else
                card.value = TrackerText(card, "GameFontNormalLarge")
                card.value:SetPoint("TOPLEFT", card.label, "BOTTOMLEFT", 0, -2)
                WrapTrackerText(card.value)
            end
            card.value:SetTextColor(unpack(PALETTE.gold))
            panel.metricCards[index] = card
        end
        panel.statsEmpty = TrackerText(content, "GameFontHighlight", L("journal.tracker-no-stats"))
        panel.statsEmpty:SetPoint("TOP", content, "TOP", 0, -3)
        panel.statsEmpty:SetJustifyH("CENTER"); WrapTrackerText(panel.statsEmpty)
    end

    local function ShowTrackerConfirmation(self, panel, action)
        panel.confirmAction, panel.confirmSession = action, self.session
        self:LayoutSessionTracker(true)
    end

    local function TrackerMenuAction(parent, label, click)
        local button = ModernButton(parent, label, 131, 25, click)
        local caption = button.GetFontString and button:GetFontString()
        local spec = caption and journalFonts[caption]
        if spec then
            FF:SetDisplayFont(caption, spec.path, spec.size, spec.flags)
            journalFonts[caption] = nil
        end
        return button
    end

    local function SizeTrackerMenuAction(button, width)
        button:SetWidth(width)
        button:SetHeight(25)
        local caption = button.GetFontString and button:GetFontString()
        if caption then WrapTrackerText(caption) end
        return FitTranslatedJournalAction(button, 25, true)
    end

    local function CreateTrackerMenu(self, panel)
        local menu = CreateFrame("Frame", nil, panel.trackerContent)
        menu.bg = Surface(menu, 0.18, 0.095, 0.035, 0.78)
        menu.border = self:CreateJournalFrame(menu, false, 8)
        menu.choices = CreateFrame("Frame", nil, menu)
        menu.choices:SetAllPoints()
        menu.checks = {}
        for index, metric in ipairs(TRACKER_METRICS) do
            local key = metric[1]
            local check = CreateFrame("CheckButton", nil, menu.choices, "UICheckButtonTemplate")
            check:SetSize(22, 22)
            check.label = TrackerText(check, "GameFontHighlightSmall", L(metric[2]))
            check.label:SetPoint("TOPLEFT", check, "TOPRIGHT", 1, -3)
            WrapTrackerText(check.label)
            check:SetScript("OnClick", function(button)
                local hidden = self.db.sessionTrackerHidden
                if type(hidden) ~= "table" then hidden = {}; self.db.sessionTrackerHidden = hidden end
                hidden[key] = not button:GetChecked() and true or nil
                self:LayoutSessionTracker()
            end)
            menu.checks[index] = check
        end
        menu.rule = menu.choices:CreateTexture(nil, "BORDER")
        local separator = PALETTE.separator
        menu.rule:SetColorTexture(separator[1], separator[2], separator[3], 0.55)
        menu.finish = TrackerMenuAction(menu.choices, L("journal.end-session"), function() ShowTrackerConfirmation(self, panel, "end") end)
        menu.reset = TrackerMenuAction(menu.choices, L("journal.reset-session"), function() ShowTrackerConfirmation(self, panel, "reset") end)
        menu.note = TrackerText(menu.choices, "GameFontHighlightSmall", L("journal.session-footer"))
        WrapTrackerText(menu.note); menu.note:SetJustifyH("CENTER")
        menu.confirm = CreateFrame("Frame", nil, menu)
        menu.confirm:SetAllPoints()
        menu.prompt = TrackerText(menu.confirm, "GameFontHighlight")
        WrapTrackerText(menu.prompt)
        menu.accept = TrackerMenuAction(menu.confirm, L("journal.end-session"), function()
            local action, sameSession = panel.confirmAction, panel.confirmSession == self.session
            panel.confirmAction, panel.confirmSession = nil, nil
            if sameSession and action == "end" then self:EndSession()
            elseif sameSession and action == "reset" then self:ResetSession() end
            self:LayoutSessionTracker(true)
        end)
        menu.cancel = TrackerMenuAction(menu.confirm, L("binding.cancel"), function()
            panel.confirmAction, panel.confirmSession = nil, nil
            self:LayoutSessionTracker(true)
        end)
        panel.menu = menu
        menu:Hide()
    end

    local function LayoutTrackerMenu(panel, hidden, width)
        local menu = panel.menu
        menu:SetShown(panel.settingsShown == true)
        if not panel.settingsShown then return end
        local inset, gap = 9, TRACKER_GAP
        menu:SetWidth(width)
        menu.choices:SetShown(not panel.confirmAction)
        menu.confirm:SetShown(panel.confirmAction ~= nil)
        local buttonWidth = math.max(1, (width - inset * 2 - gap) / 2)
        if panel.confirmAction then
            local ending = panel.confirmAction == "end"
            menu.prompt:SetText(L(ending and "journal.tracker-end-confirm" or "journal.tracker-reset-confirm"))
            menu.prompt:SetWidth(math.max(1, width - inset * 2))
            menu.prompt:ClearAllPoints()
            menu.prompt:SetPoint("TOPLEFT", menu.confirm, "TOPLEFT", inset, -inset)
            menu.accept:SetText(L(ending and "journal.end-session" or "journal.reset-session"))
            local height = math.max(SizeTrackerMenuAction(menu.accept, buttonWidth),
                SizeTrackerMenuAction(menu.cancel, buttonWidth))
            menu.accept:ClearAllPoints(); menu.cancel:ClearAllPoints()
            menu.accept:SetPoint("TOPLEFT", menu.prompt, "BOTTOMLEFT", 0, -gap)
            menu.cancel:SetPoint("LEFT", menu.accept, "RIGHT", gap, 0)
            menu:SetHeight(math.ceil(menu.prompt:GetStringHeight()) + inset * 2 + gap + height)
            return
        end

        local y, rowHeight = inset, 0
        local checkSize = 22
        local columnWidth = (width - inset * 2) / 2
        for index, check in ipairs(menu.checks) do
            check:SetChecked(not hidden[TRACKER_METRICS[index][1]])
            check:SetSize(checkSize, checkSize)
            check:ClearAllPoints()
            check:SetPoint("TOPLEFT", menu.choices, "TOPLEFT", inset + (index - 1) % 2 * columnWidth, -y)
            check.label:SetWidth(math.max(1, columnWidth - checkSize - 3))
            rowHeight = math.max(rowHeight, checkSize + 1, math.ceil(check.label:GetStringHeight()) + 5)
            if index % 2 == 0 then y = y + rowHeight; rowHeight = 0 end
        end
        menu.rule:ClearAllPoints()
        menu.rule:SetPoint("TOPLEFT", menu.choices, "TOPLEFT", inset, -y - gap / 2)
        menu.rule:SetSize(math.max(1, width - inset * 2), 1)
        local actionTop = y + inset
        menu.finish:ClearAllPoints(); menu.reset:ClearAllPoints()
        menu.finish:SetPoint("TOPLEFT", menu.choices, "TOPLEFT", inset, -actionTop)
        menu.reset:SetPoint("TOPRIGHT", menu.choices, "TOPRIGHT", -inset, -actionTop)
        local height = math.max(SizeTrackerMenuAction(menu.finish, buttonWidth),
            SizeTrackerMenuAction(menu.reset, buttonWidth))
        menu.note:SetWidth(math.max(1, width - inset * 2))
        menu.note:ClearAllPoints(); menu.note:SetPoint("TOP", menu.choices, "TOP", 0, -actionTop - height - gap)
        menu:SetHeight(actionTop + height + math.ceil(menu.note:GetStringHeight()) + gap + inset)
    end

    local function LayoutTrackerGeometry(self, panel)
        if not PanelVisible(panel) or (InCombatLockdown and InCombatLockdown()) then return end
        local panelWidth, panelHeight = panel:GetWidth(), panel:GetHeight()
        local scroll = panel.trackerScroll
        local offset = scroll:GetVerticalScroll()
        local bodyTop = SizeTrackerHeadings(panel) + 2
        local bar = scroll.ScrollBar
        local scrollbarWidth = bar and bar:GetWidth()
        if not scrollbarWidth or scrollbarWidth <= 0 then scrollbarWidth = 16 end
        local width = math.max(1, panelWidth - TRACKER_INSET - SCROLLBAR_INSET - scrollbarWidth - SCROLLBAR_GAP)
        scroll:ClearAllPoints()
        scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", TRACKER_INSET, -bodyTop)
        scroll:SetSize(width, math.max(1, panelHeight - bodyTop - TRACKER_BODY_BOTTOM))
        if bar then
            bar:ClearAllPoints()
            bar:SetWidth(scrollbarWidth)
            bar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -SCROLLBAR_INSET, -bodyTop - 16)
            bar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -SCROLLBAR_INSET, TRACKER_BODY_BOTTOM + 16)
        end
        panel.trackerContent:SetWidth(width)
        local hidden = type(self.db.sessionTrackerHidden) == "table" and self.db.sessionTrackerHidden or {}
        SizeTrackerStatColumns(panel, hidden, width)
        panel.statsEmpty:SetWidth(width)
        panel.catchEmpty:SetWidth(math.max(1, width - 14))
        panel.catchEmpty:ClearAllPoints()
        panel.catchEmpty:SetPoint("TOP", panel.catchList, "TOP", 0, -12)
        panel.catchList:SetShown(panel.historyShown == true)
        if panel.historyShown then
            LayoutTrackerCatchRows(panel, width)
        else
            panel.statsBodyHeight = LayoutTrackerStatRows(panel)
        end
        LayoutTrackerMenu(panel, hidden, width)
        LayoutTrackerScroll(panel, offset)
    end

    function FF:LayoutSessionTracker(revealOptions)
        local panel = self.sessionTrackerPanel
        if not (panel and PanelVisible(panel)) or (InCombatLockdown and InCombatLockdown()) then return end
        PaintTrackerHeading(panel.statsHeading, not panel.historyShown, panel.statsHeading:IsMouseOver())
        PaintTrackerHeading(panel.catchesHeading, panel.historyShown == true, panel.catchesHeading:IsMouseOver())
        LayoutTrackerGeometry(self, panel)
        self:RefreshSessionTracker()
        if revealOptions and panel.settingsShown then
            SetTrackerScrollOffset(panel, TrackerBodyHeight(panel) + TRACKER_GAP)
        end
    end

    function FF:CloseSessionTracker(remember)
        self.sessionTrackerRequested = nil
        if not remember and self.db and not self.dataResetPendingReload then
            self.db.sessionTrackerOpen = nil
        end
        local panel = self.sessionTrackerPanel
        if panel then
            panel.settingsShown, panel.confirmAction, panel.confirmSession, panel.beforeOptionsScroll = nil, nil, nil, nil
            panel.sessionWindowDismissal = nil
            if panel:IsShown() then panel:Hide() end
        end
    end

    function FF:RestoreSessionTracker()
        if not self.db or self.db.sessionTrackerOpen ~= true or self.dataResetPendingReload then return end
        self.sessionTrackerRequested = true
        self:SyncSessionTrackerVisibility()
    end

    function FF:ToggleSessionTracker()
        if not self.session or self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown()) then return end
        if self.sessionTrackerRequested then self:CloseSessionTracker()
        else self:ShowSessionTracker() end
    end

    function FF:ShowSessionTracker()
        if not self.session or self.dataResetPendingReload or (InCombatLockdown and InCombatLockdown()) then return end
        if self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
        self.sessionTrackerRequested = true
        self.db.sessionTrackerOpen = true
        self:SyncSessionTrackerVisibility(true)
    end

    function FF:SyncSessionTrackerVisibility(explicitOpen)
        if not self.sessionTrackerRequested or not self.session or self.dataResetPendingReload
            or (InCombatLockdown and InCombatLockdown()) then return end
        local panel = self.sessionTrackerPanel
        if panel and panel:IsShown() then
            if explicitOpen then self:BringFishingWindowForward(panel) end
            return
        end
        if self.IsCameraSearchPending and self:IsCameraSearchPending() then return end
        if not panel then
            local header
            panel, header = self:CreateSessionWindow("ForeverFishingSessionTracker", TRACKER_WIDTH, TRACKER_HEIGHT,
                nil, L("journal.tracker-move"), L("journal.tracker-close"))
            panel:Hide()
            panel.trackerHeader = header
            self:PlaceFishingBarCloseButton(panel.close, panel)
            panel.close:SetScript("OnClick", function() self:CloseSessionTracker() end)
            panel.settings = TrackerOptionsButton(panel)
            panel.settings:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_TOP"); GameTooltip:SetText(L("journal.tracker-settings")); GameTooltip:Show()
            end)
            panel.settings:HookScript("OnLeave", function() GameTooltip:Hide() end)
            panel.settings:SetScript("OnClick", function()
                if not panel.settingsShown then panel.beforeOptionsScroll = panel.trackerScroll:GetVerticalScroll() end
                panel.settingsShown = not panel.settingsShown
                panel.confirmAction, panel.confirmSession = nil, nil
                self:LayoutSessionTracker(panel.settingsShown)
                if not panel.settingsShown then
                    SetTrackerScrollOffset(panel, panel.beforeOptionsScroll or 0)
                    panel.beforeOptionsScroll = nil
                end
            end)
            local function SelectView(historyShown)
                if (panel.historyShown == true) == historyShown then return end
                panel.historyShown = historyShown
                panel.confirmAction, panel.confirmSession = nil, nil
                SetTrackerScrollOffset(panel, 0)
                panel.beforeOptionsScroll = 0
                self:LayoutSessionTracker(panel.settingsShown)
            end
            panel.statsHeading = TrackerHeading(panel, L("journal.tracker-stats-tab"), function() SelectView(false) end)
            panel.statsHeading:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
            panel.catchesHeading = TrackerHeading(panel, L("journal.tracker-catches-tab"), function() SelectView(true) end)
            panel.catchesHeading:SetPoint("LEFT", panel.statsHeading, "RIGHT", 3, 0)
            -- The buttons occupy the ends of the strip. Only the blank middle drags the window.
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", panel.catchesHeading, "TOPRIGHT", 4, 0)
            header:SetPoint("TOPRIGHT", panel.settings, "TOPLEFT", -6, 2)
            for _, button in ipairs({panel.statsHeading, panel.catchesHeading, panel.settings, panel.close}) do
                button:SetFrameLevel(header:GetFrameLevel() + 1)
                button:EnableMouse(true)
                button:RegisterForClicks("LeftButtonUp")
            end
            CreateTrackerBody(panel)
            CreateTrackerCards(panel)
            CreateTrackerMenu(self, panel)
            self.sessionTrackerPanel = panel
            panel.floatingResizeOnly, panel.floatingResizeFromTopLeft = true, true
            self:PrepareFloatingWindow(panel, "sessionTracker", header)
            panel:SetScript("OnSizeChanged", function() LayoutTrackerGeometry(self, panel) end)
            local grip = panel.scaleGrip
            grip:SetSize(20, 20)
            panel:HookScript("OnHide", function()
                grip.scaling = nil
                grip:SetScript("OnUpdate", nil)
                StopTrackerClock(self)
                ClearTrackerItemTooltip(panel.trackerScroll)
                if self.sessionTrackerRequested then
                    self:ResolveSessionWindowNativeHide(panel, self.SyncSessionTrackerVisibility, self.CloseSessionTracker)
                end
            end)
            panel:HookScript("OnShow", function()
                panel.sessionWindowDismissal = nil
                self:LayoutSessionTracker()
            end)
            self:RegisterCombatCloseWindow("sessionTracker", panel)
            if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "ForeverFishingSessionTracker" end
        end
        self:ShowFloatingSessionWindow(panel, explicitOpen)
    end
end

function FF:RenderSessionStats()
    if self.journalPanel.sessionHistoryShown then self:RenderSessionHistory(); return end
    local panel = self.journalPanel
    ClearDynamic(panel); local gridHeight = RenderRecordMetrics(panel, RecordMetrics(self, false), true)
    panel.pageTitle:SetText(FF:LocalizedText("journal.session-title")); SetJournalPageSubtitle(panel, FF:LocalizedText("journal.session-subtitle"))
    panel.pageTitle:SetJustifyH("LEFT")
    local history = panel.sessionHistoryButton
    if not history then
        history = ModernButton(panel.page,FF:LocalizedText("journal.history-button"),130,24,function() self:ToggleSessionHistory(true) end)
        panel.sessionHistoryButton = history
    end
    FitTranslatedJournalAction(history,24)
    history:ClearAllPoints()
    history:SetPoint("RIGHT",panel.page,"TOPRIGHT",-JournalScrollSide(panel)-10,-18-panel.pageTitle:GetStringHeight()/2)
    history:Show()
    local footer = Pooled(panel, "sessionFooter", function()
        local footer = CreateFrame("Frame", nil, panel.content)
        Divider(footer)
        local note = Readable(PaperText(footer, "GameFontHighlight", "TOP", footer, "TOP", 0, 0, FF:LocalizedText("journal.session-footer")), 14)
        note:SetTextColor(unpack(SOFT_INK)); note:SetJustifyH("CENTER"); note:SetWordWrap(true)
        footer.note = note
        footer.goals = ModernButton(footer, FF:LocalizedText("journal.goals-button"), 176, 28, function() self:ShowSessionGoals() end)
        footer.tracker = ModernButton(footer, FF:LocalizedText("journal.tracker-button"), 176, 28, function() self:ToggleSessionTracker() end)
        footer.goals.border = self:CreateJournalFrame(footer.goals, true)
        footer.tracker.border = self:CreateJournalFrame(footer.tracker, true)
        footer.finish = ModernButton(footer, FF:LocalizedText("journal.end-session"), 176, 28, function() self:EndSession() end)
        footer.reset = ModernButton(footer, FF:LocalizedText("journal.reset-session"), 176, 28, function() self:ResetSession() end)
        return footer
    end)
    local width, gap, top = JournalWidth(panel), 22, 10
    local buttonWidth = math.min(176, (width - 24 - gap) / 2)
    footer:SetWidth(width)
    for _, row in ipairs({{footer.goals, footer.tracker}, {footer.finish, footer.reset}}) do
        local height = 28
        for column, button in ipairs(row) do
            button:SetWidth(buttonWidth); button:SetHeight(28)
            height = math.max(height, FitTranslatedJournalAction(button, 28))
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", footer, "TOP", (column - 1) * (buttonWidth + gap) - buttonWidth - gap / 2, -top)
        end
        for _, button in ipairs(row) do button:SetHeight(height) end
        top = top + height + 12
    end
    footer.note:SetWidth(width - 24)
    footer.note:ClearAllPoints(); footer.note:SetPoint("TOP", footer, "TOP", 0, -top)
    footer:SetHeight(top + math.ceil(footer.note:GetStringHeight()) + 8)
    footer:ClearAllPoints()
    footer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -gridHeight - 12)
    SetCatchHeight(panel, gridHeight + 12 + footer:GetHeight() + 8)
    panel.renderedTab, panel.statsRevision = "session", self.statsRevision
end
function FF:RenderLifetimeStats()
    local panel = self.journalPanel
    ClearDynamic(panel); local gridHeight = RenderRecordMetrics(panel, RecordMetrics(self, true))
    panel.pageTitle:SetText(FF:LocalizedText("journal.lifetime-title")); SetJournalPageSubtitle(panel, FF:LocalizedText("journal.lifetime-subtitle"))
    local note=Pooled(panel,"lifetimeNote",function()
        local text=Readable(PaperText(panel.content,"GameFontHighlight","TOPLEFT",panel.content,"TOPLEFT",12,0,""),13)
        text:SetJustifyH("LEFT"); text:SetWordWrap(true); text:SetTextColor(unpack(SOFT_INK)); return text
    end)
    note:SetWidth(JournalWidth(panel)-24); note:ClearAllPoints()
    note:SetPoint("TOPLEFT",panel.content,"TOPLEFT",12,-gridHeight-12)
    note:SetText(FF:LocalizedText("journal.lifetime-note"))
    SetCatchHeight(panel, gridHeight + note:GetStringHeight() + 28)
    panel.renderedTab, panel.statsRevision = "lifetime", self.statsRevision
end

function FF:StopJournalClock()
    if self.journalClock then self.journalClock:Cancel(); self.journalClock = nil end
end
function FF:UpdateJournalClock()
    local panel = self.journalPanel
    local wanted = panel and PanelVisible(panel) and ((self.journalTab == "session" and not panel.sessionHistoryShown and self.session.activeStarted) or
        (self.journalTab == "lifetime" and self.lifetimeCastStartedAt))
    if not wanted then self:StopJournalClock(); return end
    if self.journalClock or not (C_Timer and C_Timer.NewTicker) then return end
    self.journalClock = C_Timer.NewTicker(1, function()
        if not PanelVisible(panel) then self:StopJournalClock(); return end
        local lifetime = self.journalTab == "lifetime"
        if (self.journalTab ~= "session" or panel.sessionHistoryShown) and not lifetime then self:StopJournalClock(); return end
        local seconds, rateSeconds, rateCount = RecordTimes(self, lifetime)
        UpdateRecordClockValues(panel, seconds, rateSeconds, rateCount)
        local first = lifetime and 9 or 7
        for index = first, first + 1 do
            local card = panel.metricCards[index]
            if card and card.hourly then card.hourly:SetText(CoinPerHour(card.hourlyCopper, seconds)) end
        end
        if (lifetime and not self.lifetimeCastStartedAt) or (not lifetime and not self.session.activeStarted) then self:StopJournalClock() end
    end)
end

local function LinkText(frame, value)
    return frame.SetHyperlinksEnabled and FF.GuideLinkText and FF:GuideLinkText(value, true) or FF:LocalizeReferenceZones(value)
end

-- Direct source links retain stable identities; hover resolves the current
-- render's point so distance is never frozen in GuideLinks' static registry.
function FF:GetJournalRouteSource(target)
    local panel = self.journalPanel
    for _, point in ipairs(panel and panel.routeTrainingSources and panel.routeTrainingSources[target.rank] or {}) do
        if point.name == target.name then return point end
    end
end

function FF:ToggleJournalRouteSources(key)
    local panel = self.journalPanel
    if not panel then return end
    self:OpenJournalRoutePicker(panel.routeSelectors and panel.routeSelectors[key])
end

local function ShowGuideItemTooltip(frame, hover, failed)
    local panel, target = hover.panel, hover.target
    if frame.journalGuideHover ~= hover then return end
    if hover.shown and (FF.journalItemTooltipOwner ~= frame or GameTooltip:GetOwner() ~= frame) then return end
    if not frame.linkHovered
        or hover.tab ~= FF.journalTab or hover.generation ~= panel.guideTooltipGeneration
        or hover.scroll ~= panel.scroll:GetVerticalScroll() then
        FF:HideJournalItemTooltip(frame)
        return
    end
    if failed then
        -- A failed load is terminal for this hover. Keep the verified name and
        -- addon notes, without displaying native retrieving text or retrying.
        GameTooltip:SetText(FF:GetNativeGuideTargetName(target,target.label))
        if frame.gearReferenceIcon then GameTooltip:AddLine(FF:LocalizedText("journal.link.item-unavailable"),.8,.8,.8,true) end
        frame.journalTooltipItemReady = false
        frame.journalTooltipHover.failed = true
        frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        frame:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
    else
        FF:BeginJournalItemTooltip(frame, hover.id, target.label, hover.atLink ~= false,
            function(owner) ShowGuideItemTooltip(owner, hover) end,
            function(owner) ShowGuideItemTooltip(owner, hover, true) end)
        if FF.journalItemTooltipOwner ~= frame or GameTooltip:GetOwner() ~= frame then return end
        hover.shown = true
        -- Retain the original text-link anchor through asynchronous rebuilds.
        if hover.cursor then frame.journalTooltipCursor = hover.cursor
        else hover.cursor = frame.journalTooltipCursor end
    end
    if frame.gearReferenceIcon then frame.icon:SetTexture(FF:GetJournalItemIcon(hover.id)) end
    if target.kind == "fish" then FF:AddJournalCatchClassifications(GameTooltip, hover.id) end
    if target.tooltip then GameTooltip:AddLine(FF:GetGuideTargetTooltipText(target),.8,.8,.8,true) end
    if target.kind ~= "item" then
        GameTooltip:AddLine(FF:LocalizedText(target.kind == "fish" and "journal.link.open-catch" or "journal.link.open-chef"), .7,.7,.7)
    end
    FF:FinishJournalItemTooltip(frame)
end

local function ShowGuideQuestTooltip(frame, hover, failed)
    local panel = hover.panel
    if frame.journalGuideHover ~= hover then return end
    if hover.shown and (FF.journalQuestTooltipOwner ~= frame or GameTooltip:GetOwner() ~= frame) then return end
    if (hover.atLink and not frame.linkHovered) or (not hover.atLink and frame.service ~= hover.target)
        or hover.tab ~= FF.journalTab or hover.generation ~= panel.guideTooltipGeneration
        or hover.scroll ~= panel.scroll:GetVerticalScroll() then
        FF:HideJournalQuestTooltip(frame); return
    end
    if not hover.shown then
        hover.questID = FF:GetJournalQuestID(hover.quest)
        FF:BeginJournalQuestTooltip(frame, hover, function(owner, unavailable)
            ShowGuideQuestTooltip(owner, hover, unavailable)
        end)
        hover.shown = true
    end
    local complete = FF:AddJournalQuestTooltipLines(GameTooltip, hover.quest, hover.questID, failed)
    if hover.target.kind == "guideuse" then
        GameTooltip:AddLine(FF:LocalizedText("journal.link.instructions"),.7,.7,.7,true)
    end
    if hover.target.questMapTarget then GameTooltip:AddLine(FF:LocalizedText("journal.link.click-map"),.7,.7,.7) end
    if hover.person then
        GameTooltip:AddLine(FF:GetJournalNPCDisplayName(hover.person.point.name).." • "..FF:GetJournalSourceLocationText(hover.person.point),.78,.71,.57,true)
    end
    FF:FinishJournalQuestTooltip(frame)
    FF:SetJournalQuestHover(frame, hover.link, hover.quest, hover.bounds)
    if not complete and not failed and not hover.requested and hover.questID
        and C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        hover.requested = true
        frame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
        if not pcall(C_QuestLog.RequestLoadQuestByID, hover.questID) then
            frame:UnregisterEvent("QUEST_DATA_LOAD_RESULT")
            ShowGuideQuestTooltip(frame, hover, true)
        end
    end
end

EnableGuideLinks = function(frame, panel)
    if not frame.SetHyperlinksEnabled then return end
    frame:SetHyperlinksEnabled(true)
    frame:HookScript("OnHide", function(owner)
        FF:ClearJournalQuestHover(owner)
        owner.journalGuideHover, owner.linkHovered = nil, nil
    end)
    if not panel.guideTooltipHooks then
        panel.guideTooltipHooks = true
        panel.scroll:HookScript("OnVerticalScroll", function() DismissGuideItemHover(panel) end)
        panel:HookScript("OnHide", function() DismissGuideItemHover(panel) end)
    end
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(_, delta)
        local scroll = panel.scroll
        scroll:SetVerticalScroll(math.max(0, math.min(scroll:GetVerticalScrollRange(),
            scroll:GetVerticalScroll() - delta * 48)))
    end)
    frame:SetScript("OnHyperlinkEnter", function(_, link, text, region, left, bottom, width)
        FF:ClearJournalQuestHover(frame)
        frame.journalGuideHover = nil
        frame.linkHovered = true
        local target = FF:GuideLinkTarget(link)
        if not target then return end
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        local quest = FF:GetJournalQuestReference(target.label)
        if quest then
            local hover = {panel=panel, target=target, quest=quest, link=link, atLink=true,
                bounds={region=region, left=left, bottom=bottom, width=width},
                tab=FF.journalTab, generation=panel.guideTooltipGeneration,
                scroll=panel.scroll:GetVerticalScroll()}
            frame.journalGuideHover = hover
            ShowGuideQuestTooltip(frame, hover)
            return
        elseif target.kind == "routesource" then
            local point = FF:GetJournalRouteSource(target)
            if not point then return end
            GameTooltip:SetText(FF:GetGuideMapLabel(point), 1, 0.82, 0.45)
            local nearby=target.rank:sub(1,7)=="Nearby:"
            if nearby then
                GameTooltip:AddLine(point.distance and FF:LocalizedText("nearby.person.distance-tip",math.floor(math.sqrt(point.distance)+.5))
                    or FF:LocalizedText("nearby.person.map-distance-unavailable"),.8,.8,.8)
                GameTooltip:AddLine(FF:GetNearbyPointRoleDisplayText(point),.8,.8,.8,true)
                if point.sellsPole then GameTooltip:AddLine(FF:LocalizedText("nearby.person.sells-pole"),.8,.8,.8) end
                GameTooltip:AddLine(FF:FormatCoordinateDisplay(point.x*100,point.y*100,true),.7,.7,.7)
            else
                GameTooltip:AddLine(point.distance and FF:LocalizedText("journal.link.distance-straight" ,math.floor(math.sqrt(point.distance)+.5))
                    or FF:LocalizedText("journal.link.distance-unavailable"), .8,.8,.8)
                GameTooltip:AddLine(FF:GetJournalSourceRoleText(point,target.rank) or FF:GetFishingRouteRequirementText(target.rank)
                    or FF:LocalizedText("journal.link.verified-map"), .8,.8,.8,true)
                if point.sellsPole and target.rank ~= "Supplier" then GameTooltip:AddLine(FF:LocalizedText("nearby.person.sells-pole"),.8,.8,.8) end
                GameTooltip:AddLine(FF:FormatCoordinateDisplay(point.x*100,point.y*100,true),.7,.7,.7)
            end
        elseif target.kind == "fishingevent" then
            GameTooltip:SetText(FF:LocalizedText("journal.events-title"),1,.82,.45)
            GameTooltip:AddLine(FF:LocalizedText("events.open-next-tip"),.8,.8,.8,true)
        elseif target.kind == "nearbypool" then
            GameTooltip:SetText(FF:GetJournalPoolDisplayName(target.label),1,.82,.45)
            GameTooltip:AddLine(FF:LocalizeReferenceZones(FF:GetNearbyPoolTooltipDisplayText(target.tooltip)),.8,.8,.8,true)
            GameTooltip:AddLine(FF:LocalizedText("nearby.pool.toggle"),.7,.7,.7)
        elseif target.kind == "nearbyservice" then
            GameTooltip:SetText(FF:LocalizedText("nearby.service.other"),1,.82,.45)
            GameTooltip:AddLine(FF:LocalizedText("nearby.service.toggle"),.8,.8,.8,true)
        elseif target.kind == "guideuse" then
            GameTooltip:SetText(target.displayLabel or target.label,1,.82,.45)
            GameTooltip:AddLine(FF:GetGuideTargetTooltipText(target) or FF:LocalizedText("catch.use.related-instructions"),.8,.8,.8,true)
        elseif target.kind == "routepicker" then
            GameTooltip:SetText(FF:GetJournalSourcePickerTitle(target.rank),1,.82,.45)
            GameTooltip:AddLine(FF:LocalizedText("journal.link.alternatives"),.8,.8,.8,true)
        elseif target.kind == "info" then
            GameTooltip:SetText(FF:GetNativeGuideTargetName(target,target.label), 1, 0.82, 0.45)
            GameTooltip:AddLine(FF:LocalizeJournalReferenceText(FF:GetGuideTargetTooltipText(target)), 0.8, 0.8, 0.8, true)
        elseif target.kind == "spell" then
            local ok=pcall(GameTooltip.SetHyperlink,GameTooltip,"spell:"..target.id)
            if not ok then GameTooltip:SetText(FF:GetJournalSpellDisplayName(target.id,target.label),1,.82,.45) end
            GameTooltip:AddLine(FF:LocalizedText("journal.link.effect-unverified"),.8,.8,.8,true)
        elseif target.kind == "map" then
            GameTooltip:SetText(FF:GetGuideMapLabel(target), 1, 0.82, 0.45)
            GameTooltip:AddLine(FF:FormatCoordinateDisplay(target.x * 100, target.y * 100), 0.8, 0.8, 0.8)
            GameTooltip:AddLine(FF:LocalizedText("journal.link.click-map"), 0.7, 0.7, 0.7)
        else
            local hover = {panel=panel, target=target, id=target.id, link=link, atLink=not frame.gearReferenceIcon,
                tab=FF.journalTab, generation=panel.guideTooltipGeneration,
                scroll=panel.scroll:GetVerticalScroll()}
            frame.journalGuideHover = hover
            ShowGuideItemTooltip(frame, hover)
            -- Native SetHyperlink normally requests data itself. Explicitly
            -- request only an uncached item, once on entry (never on replay).
            if C_Item and C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID
                and not C_Item.IsItemDataCachedByID(target.id) then
                pcall(C_Item.RequestLoadItemDataByID, target.id)
            end
        end
        if FF.journalItemTooltipOwner == frame then FF:FinishJournalItemTooltip(frame)
        else GameTooltip:Show() end
    end)
    frame:SetScript("OnHyperlinkLeave", function(_, link)
        local hover = frame.journalGuideHover
        if link and hover and hover.link ~= link then return end
        frame.journalGuideHover = nil
        frame.linkHovered = nil
        FF:HideJournalQuestTooltip(frame)
        FF:HideJournalItemTooltip(frame)
    end)
    frame:SetScript("OnHyperlinkClick", function(_, link)
        local target = FF:GuideLinkTarget(link)
        if not target then return end
        GameTooltip:Hide()
        if FF.BringFishingWindowForward then FF:BringFishingWindowForward(panel) end
        if target.kind == "quest" and target.questMapTarget then FF:OpenGuideMapPoint(target.questMapTarget)
        elseif target.kind == "routesource" then
            local point = FF:GetJournalRouteSource(target)
            if point then FF:OpenGuideMapPoint(point) end
        elseif target.kind == "fishingevent" then FF:OpenNextFishingEvent()
        elseif target.kind == "nearbypool" then
            local scroll=panel.scroll:GetVerticalScroll(); local key="nearby:pool:"..target.id
            panel.expandedGuides[key]=not panel.expandedGuides[key]
            FF:RenderNearby(); panel.scroll:SetVerticalScroll(math.min(scroll,panel.scroll:GetVerticalScrollRange()))
        elseif target.kind == "nearbyservice" then
            local scroll=panel.scroll:GetVerticalScroll()
            panel.expandedGuides=panel.expandedGuides or {}
            local key="nearby:person:"..target.id
            panel.expandedGuides[key]=not panel.expandedGuides[key]
            FF:RenderNearby(); panel.scroll:SetVerticalScroll(math.min(scroll,panel.scroll:GetVerticalScrollRange()))
        elseif target.kind == "guideuse" then FF:OpenJournalGuideUse(target)
        elseif target.kind == "routepicker" then FF:ToggleJournalRouteSources(target.id)
        elseif target.kind == "map" then FF:OpenGuideMapPoint(target)
        elseif target.kind == "fish" then FF:OpenGuideCatch(target.id)
        elseif target.kind == "meal" then FF:OpenGuideMeal(target.id)
        elseif target.kind == "camp" then FF:OpenGuideCamp(target.id)
        elseif target.kind == "campinfo" then FF:OpenGuideCamp(target.id, true) end
    end)
end

local function GuideCard(panel, x, headingY, bodyY, bodyWidth)
    local card = CreateFrame("Button", nil, panel.content)
    card.pooled = true
    card:SetWidth(530)
    card.border = FF:CreateJournalFrame(card)
    card:RegisterForClicks("LeftButtonUp")
    EnableGuideLinks(card, panel)
    card.milestoneBg = Surface(card, 0.57, 0.39, 0.18, 0.10)
    card.milestoneRule = card:CreateTexture(nil, "BORDER")
    card.milestoneRule:SetPoint("TOPLEFT", card, "TOPLEFT", 5, -5)
    card.milestoneRule:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 5, 5)
    card.milestoneRule:SetWidth(2)
    card.milestoneRule:SetColorTexture(0.53, 0.32, 0.12, 0.7)
    local separator = card:CreateTexture(nil, "BORDER")
    separator:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 12, 0)
    separator:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 0)
    separator:SetHeight(1)
    separator:SetColorTexture(0.48, 0.30, 0.13, 0.38)
    card.separator=separator
    card.heading = Readable(PaperText(card, "GameFontNormal", "TOPLEFT", card, "TOPLEFT", x, headingY, ""), 15)
    card.heading:SetWidth(bodyWidth)
    card.heading:SetJustifyH("LEFT")
    card.heading:SetTextColor(unpack(INK))
    card.body = Readable(PaperText(card, "GameFontHighlight", "TOPLEFT", card, "TOPLEFT", x, bodyY, ""), 14)
    card.body:SetWidth(bodyWidth)
    card.body:SetJustifyH("LEFT")
    card.body:SetJustifyV("TOP")
    card.body:SetSpacing(3)
    card.body:SetTextColor(unpack(SOFT_INK))
    card.heading:SetWordWrap(true); card.body:SetWordWrap(true)
    card.summary = Readable(PaperText(card,"GameFontHighlight","TOPLEFT",card,"TOPLEFT",13,-33,""),13)
    card.summary:SetWordWrap(true); card.summary:SetJustifyH("LEFT"); card.summary:SetTextColor(unpack(SOFT_INK))
    card.sections = {}
    card.categoryIcon = card:CreateTexture(nil,"ARTWORK"); card.categoryIcon:SetSize(24,24)
    card.categoryIcon:SetPoint("TOPLEFT",card,"TOPLEFT",12,-8)
    card.categoryIcon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    card.map = CreateFrame("Button",nil,card); card.map:SetSize(20,20)
    card.map:SetPoint("TOPRIGHT",card,"TOPRIGHT",-34,-10)
    card.map.icon = card.map:CreateTexture(nil,"ARTWORK"); card.map.icon:SetAllPoints(card.map)
    card.map.icon:SetTexture(FF.journalAssets.U01)
    card.map:SetScript("OnClick",function() if card.mapTarget then FF:OpenGuideMapPoint(card.mapTarget) end end)
    card.map:SetScript("OnEnter",function(button)
        if not card.mapTarget then return end
        GameTooltip:SetOwner(button,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:GetGuideMapLabel(card.mapTarget))
        GameTooltip:AddLine(FF:LocalizedText("journal.link.click-map"),0.8,0.8,0.8); GameTooltip:Show()
    end)
    card.map:SetScript("OnLeave",function() GameTooltip:Hide() end)
    card.chevron = card:CreateTexture(nil,"ARTWORK"); card.chevron:SetSize(12,7)
    card.chevron:SetPoint("TOPRIGHT",card,"TOPRIGHT",-12,-18)
    card:SetScript("OnClick",function(button)
        if button.linkHovered then return end
        if button.routeCallout then return end
        panel.expandedGuides = panel.expandedGuides or {}
        if button.parentGuide then panel.expandedGuides[button.parentGuide] = true end
        panel.expandedGuides[button.blockKey] = not button.expanded
        local scroll = panel.scroll:GetVerticalScroll()
        FF:ReflowJournal(); panel.scroll:SetVerticalScroll(math.min(scroll,panel.scroll:GetVerticalScrollRange()))
    end)
    return card
end

-- Canonical text stays intact for search/links. Layout divides existing lines
-- into readable aligned sections, rather than dropping or clipping paragraphs.
local function RouteSourceKey(key, rank)
    return rank == "Supplier" and key..":Supplier" or key
end

local function RouteSourceLink(panel, key, rank, index, withChoices)
    local points = panel.routeTrainingSources[rank] or {}
    local sourceKey = RouteSourceKey(key,rank)
    local point = withChoices and FF:GetSelectedJournalRouteSource(sourceKey,rank) or points[index or 1]
    if not point then return FF:LocalizedText("journal.chrome.source-unavailable") end
    local target = {kind="routesource", id=rank, rank=rank, name=point.name,
        label=point.label, mapID=point.mapID, x=point.x, y=point.y}
    local text = FF:GuideTargetLink(target,FF:GetJournalNPCDisplayName(point.name).." • "..FF:GetJournalSourceLocationText(point))
    -- Inline flow reserves padded controls beside the final NPC/location word.
    local join = " "
    text = text..join..FF:GuideTargetLink(target,"|T"..FF.journalAssets.U01..":14:14:0:0|t")
    if withChoices and #points > 1 then
        text = text..join..FF:GuideTargetLink({kind="routepicker",id=sourceKey,rank=rank,
            label=rank == "Supplier" and "Other suppliers" or "Other trainers"},"|T"..JOURNAL_CHEVRON..":7:12:0:0|t")
    end
    return text
end

local RARE_EVENT_TITLE = "Stranglethorn Fishing Extravaganza"
local RARE_EVENT_HEADINGS = { [RARE_EVENT_TITLE]=true, ["Before the tournament"]=true,
    ["Rare fish prizes"]=true, ["After a winner is announced"]=true }

local function EventScheduleLink(text,structured)
    if structured then return text end
    return (text:gsub("Every Sunday",function()
        return FF:GuideTargetLink({kind="fishingevent",id="stranglethorn",label=RARE_EVENT_TITLE},"Every Sunday")
    end))
end

-- Presentation only: retain every canonical line and its existing link tokens.
local function RareEventBlocks(tab)
    local event, others, originals = nil, {}, {}
    for _,block in ipairs(tab.blocks or {}) do
        if RARE_EVENT_HEADINGS[block.heading] then
            originals[block.heading]=block
            if block.heading==RARE_EVENT_TITLE then event=block end
        else others[#others+1]=block end
    end
    if not event then return tab.blocks end
    local copy={}; for key,value in pairs(event) do copy[key]=value end
    copy.eventGuide=true; copy.guideHeadings=RARE_EVENT_HEADINGS
    copy.summary="Every Sunday: these catches are available only during the event."
    copy.eventSections={}; local bodies={}
    local function Add(label,text,itemID,separate)
        if text and text~="" then copy.eventSections[#copy.eventSections+1]={label=label,text=text,itemID=itemID,separate=separate} end
    end
    local lines={}; for line in event.body:gmatch("[^\n]+") do lines[#lines+1]=line end
    Add("Event",lines[1])
    local preparation=originals["Before the tournament"]
    Add("Requirements & preparation",preparation and preparation.body,nil,true)
    Add("Where to fish",lines[2],nil,true)
    Add("Catches & turn-in",lines[3],19807,true)
    Add("Winner rewards",lines[4],nil,true)
    local prizes=originals["Rare fish prizes"]
    if prizes then
        local first=true
        local catches={19805,19803,19806}; local index=0
        for line in prizes.body:gmatch("[^\n]+") do
            if first then Add("Rare catches & rewards",line,nil,true); first=false
            else index=index+1; Add("",line,catches[index]) end
        end
    end
    local after=originals["After a winner is announced"]
    Add("After a winner is announced",after and after.body,nil,true)
    for _,block in ipairs(tab.blocks) do if RARE_EVENT_HEADINGS[block.heading] then bodies[#bodies+1]=block.body end end
    copy.body=table.concat(bodies,"\n")
    table.insert(others,1,copy)
    return others
end

-- Project copies after canonical event grouping; translated prose never chooses
-- a section, catch icon, expansion key, schedule identity or Back destination.
local function RareGuideDisplayBlocks(tab,skills)
    local grouped=RareEventBlocks(tab)
    local originals,lines={},{}
    for _,block in ipairs(tab.blocks or {}) do
        originals[block.heading]=block
        local index=0
        for raw in (type(block.body)=="string" and block.body or ""):gmatch("[^\n]+") do
            index=index+1
            local text,structured=FF:GetRareGuideDisplayText(block,"line",index,skills,true)
            lines[raw]={text=text,structured=structured}
        end
    end
    local result={}
    for _,block in ipairs(grouped) do
        local copy={};for k,v in pairs(block) do copy[k]=v end
        local original=originals[block.heading]
        copy.displayHeading=FF:GetRareGuideDisplayText(original,"heading",nil,skills)
        local displayBody,structured=FF:GetRareGuideDisplayText(original,"body",nil,skills)
        copy.structuredSkills=structured
        if structured then copy.displayBody=displayBody end
        if block.eventGuide then
            copy.summary=FF:GetRareGuideSummaryText(original,true) or block.summary
            local bodies={}
            for _,source in ipairs(tab.blocks) do if RARE_EVENT_HEADINGS[source.heading] then
                bodies[#bodies+1]=FF:GetRareGuideDisplayText(source,"body",nil,skills)
            end end
            if structured then copy.displayBody=table.concat(bodies,"\n") end
            copy.eventSections={}
            for i,entry in ipairs(block.eventSections) do
                local section={};for k,v in pairs(entry) do section[k]=v end
                local display=lines[entry.text]
                section.text=display and display.text or entry.text
                section.structuredSkills=display and display.structured or false
                section.label=FF:GetRareGuideSectionLabel(entry.label)
                copy.eventSections[i]=section
            end
        end
        result[#result+1]=copy
    end
    return result
end

local function LayoutRareEventSections(card,panel,block,bodyTop,width)
    local y=0
    for index,entry in ipairs(block.eventSections) do
        local section=card.sections[index]
        if not section then
            section=CreateFrame("Frame",nil,card); EnableGuideLinks(section,panel)
            section.label=Readable(PaperText(section,"GameFontNormal","TOPLEFT",section,"TOPLEFT",0,0,""),14)
            section.body=Readable(PaperText(section,"GameFontHighlight","TOPLEFT",section,"TOPLEFT",0,0,""),14)
            section.icon=section:CreateTexture(nil,"ARTWORK"); section.icon:Hide()
            card.sections[index]=section
        end
        if section.routeInline then section.routeInline:Hide() end
        if not section.eventRule then
            section.eventRule=section:CreateTexture(nil,"BORDER")
            section.eventRule:SetHeight(1); section.eventRule:SetColorTexture(.48,.30,.13,.24)
            section.eventRule:SetPoint("TOPLEFT",section,"TOPLEFT",0,0)
            section.eventRule:SetPoint("TOPRIGHT",section,"TOPRIGHT",0,0)
            local button=CreateFrame("Button",nil,section); button:RegisterForClicks("LeftButtonUp")
            button.icon=button:CreateTexture(nil,"ARTWORK"); button:SetSize(54,54)
            button:SetScript("OnEnter",function(b) FF:ShowJournalCatchTooltip(b,b.itemID) end)
            button:SetScript("OnLeave",function(b) FF:HideJournalItemTooltip(b) end)
            button:SetScript("OnClick",function(b) FF:OpenGuideCatch(b.itemID) end)
            button:EnableMouseWheel(true); button:SetScript("OnMouseWheel",function(_,delta)
                local s=panel.scroll; s:SetVerticalScroll(math.max(0,math.min(s:GetVerticalScrollRange(),s:GetVerticalScroll()-delta*48)))
            end)
            section.eventItem=button
        end
        section:SetWidth(width); section:ClearAllPoints(); section:SetPoint("TOPLEFT",card,"TOPLEFT",13,-bodyTop-y)
        section.icon:Hide(); section.eventRule:SetShown(entry.separate==true)
        local top=entry.separate and 7 or 0
        Readable(section.label,JournalTextSize(panel,14,12)); section.label:SetWidth(width)
        section.label:SetTextColor(unpack(INK)); section.label:SetJustifyH("LEFT"); section.label:SetWordWrap(true)
        section.label:ClearAllPoints(); section.label:SetPoint("TOPLEFT",section,"TOPLEFT",0,-top)
        section.label:SetText(entry.label); section.label:SetShown(entry.label~="")
        local textTop=top+(entry.label~="" and section.label:GetStringHeight()+3 or 0)
        local left=entry.itemID and 60 or 0
        Readable(section.body,JournalTextSize(panel,14,12)); section.body:SetWidth(width-left)
        section.body:SetJustifyH("LEFT"); section.body:SetWordWrap(true); section.body:SetSpacing(2)
        section.body:SetTextColor(unpack(SOFT_INK))
        section.body:SetText(ColorGuideSkills(panel.journalSkills or FF:GetJournalSkills(),EventScheduleLink(LinkText(section,entry.text),entry.structuredSkills),"Fishing",false,true,entry.structuredSkills))
        local height=section.body:GetStringHeight()
        section.eventItem:SetShown(entry.itemID~=nil)
        if entry.itemID then
            local button=section.eventItem; button.itemID=entry.itemID
            button.icon:SetTexture(FF:GetJournalItemIcon(entry.itemID))
            local layout=FF:FrameJournalItemIcon(button,button.icon,entry.itemID,32)
            height=math.max(height,layout.height+12)
            button:ClearAllPoints(); button:SetPoint("TOPLEFT",section,"TOPLEFT",0,-textTop-(height-54)/2)
            button.icon:ClearAllPoints(); button.icon:SetPoint("CENTER",button,"CENTER",0,layout.centerY)
        end
        section.body:ClearAllPoints(); section.body:SetPoint("TOPLEFT",section,"TOPLEFT",left,-textTop-(height-section.body:GetStringHeight())/2)
        section.body:Show(); section:SetHeight(textTop+height); section:Show()
        y=y+section:GetHeight()+6
    end
    return math.max(0,y-6)
end

-- Item references share GuideCard disclosure/history and the normal guide-link
-- tooltip owner. Only actual destinations retain blue text in this page.
local function GearLinkText(frame,text)
    return (LinkText(frame,text):gsub("|c%x%x%x%x%x%x%x%x|H(ffguide:%d+)|h(.-)|h|r",function(link,label)
        local target=FF:GuideLinkTarget(link)
        if not target or target.kind=="item" or target.kind=="spell" then return label end
        return "|cff"..FF:GetJournalGuideLinkColor(target).."|H"..link.."|h"..label.."|h|r"
    end))
end

local function GearReferenceRow(card,panel,index)
    card.gearItems=card.gearItems or {}
    local row=card.gearItems[index]
    if row then return row end
    row=GuideCard(panel,54,-7,-28,400); row:SetParent(card)
    row.border:Hide(); row.map:Hide(); row.categoryIcon:Hide()
    row.milestoneBg:Hide(); row.milestoneRule:Hide(); row.summary:Show()
    row.highlight=row:CreateTexture(nil,"HIGHLIGHT"); row.highlight:SetAllPoints(row)
    row.highlight:SetColorTexture(.48,.30,.13,.07)
    local icon=CreateFrame("Frame",nil,row); icon:SetSize(40,40)
    icon.icon=icon:CreateTexture(nil,"ARTWORK"); icon.icon:SetSize(32,32); icon.icon:SetPoint("CENTER",icon,"CENTER",0,0)
    icon.gearReferenceIcon=true; EnableGuideLinks(icon,panel)
    icon:SetScript("OnEnter",function(frame)
        local entry=frame.reference
        if entry.id then
            local link=FF:GuideTargetLink({kind="item",id=entry.id,label=entry.name},entry.name):match("|H(.-)|h")
            frame:GetScript("OnHyperlinkEnter")(frame,link)
        else
            GameTooltip:SetOwner(frame,"ANCHOR_RIGHT")
            local spell=entry.spellName and GetSpellLink and GetSpellLink(entry.spellName)
            if not spell or not pcall(GameTooltip.SetHyperlink,GameTooltip,spell) then
                GameTooltip:SetText(FF:GetJournalSpellDisplayName(entry.spellID,entry.name)); GameTooltip:AddLine(FF:LocalizedText("journal.link.enchant-unavailable"),.8,.8,.8,true)
            end
            GameTooltip:Show()
        end
    end)
    icon:SetScript("OnLeave",function(frame)
        frame.journalGuideHover,frame.linkHovered=nil,nil
        FF:HideJournalItemTooltip(frame)
        if GameTooltip:GetOwner()==frame then GameTooltip:Hide() end
    end)
    icon:HookScript("OnHide",icon:GetScript("OnLeave"))
    row.itemIcon=icon; card.gearItems[index]=row
    return row
end

local function LayoutGearReferenceItems(card,panel,block,bodyTop,width)
    card.gearItems=card.gearItems or {}
    for _,row in ipairs(card.gearItems) do row:Hide() end
    local y=0
    if block.body and block.body~="" then
        card.body:Show(); y=card.body:GetStringHeight()+6
    end
    local entries=FF:GetJournalGearReferences(block,FF:GetJournalFaction())
    for index,entry in ipairs(entries) do
        local row=GearReferenceRow(card,panel,index)
        row.reference=entry; row.itemIcon.reference=entry
        row.blockKey="gear:item:"..entry.key; row.parentGuide=card.blockKey
        row.expanded=panel.expandedGuides[row.blockKey]==true; row.linkHovered=nil
        row:SetWidth(width); row:ClearAllPoints(); row:SetPoint("TOPLEFT",card,"TOPLEFT",13,-bodyTop-y)
        row.heading:ClearAllPoints(); row.heading:SetPoint("TOPLEFT",row,"TOPLEFT",52,-5)
        row.heading:SetWidth(math.max(1,width-80)); row.heading:SetTextColor(unpack(INK))
        Readable(row.heading,JournalTextSize(panel,14,12))
        local displayName=entry.id and FF:GetJournalItemDisplayName(entry.id,entry.name) or FF:GetJournalSpellDisplayName(entry.spellID,entry.name)
        row.heading:SetText(entry.meal and FF:GuideTargetLink({kind="meal",id=entry.id,label=entry.name},displayName) or displayName)
        row.heading:Show()
        row.summary:ClearAllPoints(); row.summary:SetPoint("TOPLEFT",row,"TOPLEFT",52,-8-row.heading:GetStringHeight())
        row.summary:SetWidth(math.max(1,width-80)); Readable(row.summary,JournalTextSize(panel,13,12))
        row.summary:SetText(FF:GetGearReferenceDisplayText(entry,"benefit")); row.summary:SetTextColor(unpack(SOFT_INK)); row.summary:Show()
        local header=math.max(46,13+row.heading:GetStringHeight()+row.summary:GetStringHeight())
        row.itemIcon:ClearAllPoints(); row.itemIcon:SetPoint("TOPLEFT",row,"TOPLEFT",4,-(header-40)/2)
        local texture=entry.id and FF:GetJournalItemIcon(entry.id) or entry.icon
        if entry.spellName and GetSpellInfo then
            local _,_,spellTexture=GetSpellInfo(entry.spellName)
            texture=spellTexture or texture
        end
        row.itemIcon.icon:SetTexture(texture)
        FF:FrameJournalRoundIcon(row.itemIcon.icon,32)
        row.itemIcon:Show()
        row.chevron:ClearAllPoints(); row.chevron:SetPoint("RIGHT",row,"TOPRIGHT",-8,-header/2)
        SetJournalChevron(row.chevron,row.expanded); row.chevron:Show()
        local height=header
        row.body:Hide(); if row.routeInline then row.routeInline:Hide() end
        if row.expanded then
            local requirement=FF:GetGearReferenceDisplayText(entry,"requirements",panel.journalSkills or FF:GetJournalSkills())
            local text=(requirement and requirement.."\n" or "")..FF:GetGearDetailDisplayText(entry,FF:GetJournalFaction(),panel.journalSkills or FF:GetJournalSkills(),true)
            if entry.camp then
                text=text.."\n"..FF:GuideTargetLink({kind="campinfo",id=entry.id,label="Master Chef: "..entry.name},FF:LocalizedText("gear.details.open-chef",displayName))
            elseif entry.meal then
                text=text.."\n"..FF:GuideTargetLink({kind="meal",id=entry.id,label=entry.name},FF:LocalizedText("gear.details.open-chef",displayName))
            end
            local rank="Gear:"..entry.key
            local points=FF:GetJournalGearSources(entry,FF:GetJournalFaction())
            panel.routeTrainingSources[rank]=points; panel.gearSourceEntries[rank]=entry
            if #points>0 then text=text.."\n"..RouteSourceLink(panel,rank,rank,1,true) end
            Readable(row.body,JournalTextSize(panel,14,12)); row.body:SetWidth(math.max(1,width-60))
            row.body:ClearAllPoints(); row.body:SetPoint("TOPLEFT",row,"TOPLEFT",52,-header-3)
            text=ColorRouteSkills(panel.journalSkills or FF:GetJournalSkills(),GearLinkText(row,text),"Fishing",false)
            row.body:SetText(text); row.body:SetSpacing(2)
            local detail=FF:LayoutJournalRouteInline(row,row.body,text,row.body:GetWidth(),false,EnableGuideLinks,ParchmentSlices)
            height=header+detail+10
        end
        row:SetHeight(height); row.contentY=card.contentY+bodyTop+y
        row:Show(); y=y+height+3
    end
    return math.max(0,y-3)
end

local function LayoutGuideSections(card, panel, block, bodyTop, width)
    for _, section in ipairs(card.sections) do
        section:Hide()
        if section.eventRule then section.eventRule:Hide(); section.eventItem:Hide() end
        for _,sources in pairs(section.trainingLists or {}) do sources:Hide() end
    end
    card.body:Hide()
    for _,row in ipairs(card.gearItems or {}) do row:Hide() end
    if not card.expanded then return card.summary:GetStringHeight() end
    if block.items then return LayoutGearReferenceItems(card,panel,block,bodyTop,width) end
    if block.eventGuide then return LayoutRareEventSections(card,panel,block,bodyTop,width) end
    local lines, labels, trainingRank = {}, block.sectionLabels or {}
    if block.routeStage then
        local rows
        rows, trainingRank = FF:GetFishingRouteRows(block, FF:GetJournalFaction(), nil, panel.journalSkills)
        for index, row in ipairs(rows) do
            labels[index] = row[1]
            local linked = LinkText(card,row[2])
            linked = linked:gsub("{trainer}",function() return RouteSourceLink(panel,card.blockKey,trainingRank,1,true) end)
            linked = linked:gsub("{supplier}",function() return RouteSourceLink(panel,card.blockKey,"Supplier",1,true) end)
            linked = ColorRouteSkills(panel.journalSkills or FF:GetJournalSkills(),linked,"Fishing",false,true)
            lines[index] = row[1]..": "..linked
        end
    elseif block.cookingInstructions then
        for index, instruction in ipairs(block.cookingInstructions) do
            local text = FF:LocalizedText("chef.route.instruction." .. instruction.kind, instruction.text)
            text = LinkText(card, text)
            if instruction.source then
                text = text .. " " .. RouteSourceLink(panel, instruction.source, instruction.source, 1, true)
            end
            lines[index] = text
        end
    else
        local _,support = FF:GetFishingTrainingCallout(block, panel.journalSkills)
        local body = support and ColorRouteSkills(panel.journalSkills or FF:GetJournalSkills(),LinkText(card,support),"Fishing",false,true) or card.body:GetText() or ""
        for line in (body.."\n"):gmatch("(.-)\n") do lines[#lines+1]=line end
        trainingRank = block.trainingRank
    end
    local y = 0
    for index, text in ipairs(lines) do
        local section = card.sections[index]
        if not section then
            section = CreateFrame("Frame",nil,card)
            EnableGuideLinks(section,panel)
            section.label = Readable(PaperText(section,"GameFontNormal","TOPLEFT",section,"TOPLEFT",0,0,""),13)
            section.label:SetJustifyH("LEFT"); section.label:SetWordWrap(true); section.label:SetTextColor(unpack(INK))
            section.body = Readable(PaperText(section,"GameFontHighlight","TOPLEFT",section,"TOPLEFT",0,0,""),14)
            section.body:SetJustifyH("LEFT"); section.body:SetWordWrap(true); section.body:SetSpacing(3)
            section.body:SetTextColor(unpack(SOFT_INK))
            section.icon = section:CreateTexture(nil,"ARTWORK"); section.icon:SetSize(24,24)
            section.icon:SetPoint("TOPLEFT",section,"TOPLEFT",0,0)
            card.sections[index]=section
        end
        local label = labels[index] or ""
        local labelWidth = not block.routePage and label ~= "" and math.min(102,math.floor(width*.23)) or 0
        local link = text:match("|H(ffguide:%d+)|h")
        local target = link and FF:GuideLinkTarget(link)
        local itemID = block.routePage and block.campItemID
            or not block.routePage and target and target.kind ~= "map" and target.kind ~= "info" and target.id
        itemID = itemID or nil
        section.icon:SetShown(itemID ~= nil and label == "")
        if itemID then section.icon:SetTexture(FF:GetJournalItemIcon(itemID)) end
        local left = labelWidth > 0 and labelWidth+10 or itemID and 32 or 0
        section:SetWidth(width); section:ClearAllPoints()
        section:SetPoint("TOPLEFT",card,"TOPLEFT",13,-bodyTop-y)
        local textWidth = block.cookingInstructions and card:GetWidth() or nil
        Readable(section.label,JournalTextSize(panel,14,12,textWidth)); section.label:SetWidth(math.max(1,labelWidth))
        section.label:SetText(label); section.label:SetShown(label ~= "" and not block.routePage)
        Readable(section.body,JournalTextSize(panel,14,12,textWidth)); section.body:SetWidth(width-left)
        section.body:ClearAllPoints(); section.body:SetPoint("TOPLEFT",section,"TOPLEFT",left,0); section.body:SetText(text)
        section.body:SetSpacing(block.routePage and 2 or 3)
        local textHeight=section.body:GetStringHeight()
        if block.routePage then
            textHeight=FF:LayoutJournalRouteInline(section,section.body,text,width-left,false,EnableGuideLinks,ParchmentSlices)
        elseif section.routeInline then section.routeInline:Hide(); section.body:Show() end
        local height=math.max(textHeight,labelWidth > 0 and section.label:GetStringHeight() or itemID and 24 or 0)
        section:SetHeight(height); section:Show(); y=y+height+(block.routePage and 5 or 8)
    end
    return math.max(0,y-(block.routePage and 5 or 8))
end

local function NearbySection(panel,key,title,parent)
    local section=Pooled(panel,"nearby:"..key,function()
        local frame=CreateFrame("Frame",nil,panel.content); frame.pooled=true; frame.items={}
        frame.heading=Readable(PaperText(frame,"GameFontNormal","TOPLEFT",frame,"TOPLEFT",8,-7,""),16)
        frame.heading:SetTextColor(unpack(INK)); frame.heading:SetJustifyH("LEFT"); frame.heading:SetWordWrap(true)
        frame.body=Readable(PaperText(frame,"GameFontHighlight","TOPLEFT",frame,"TOPLEFT",8,0,""),14)
        frame.body:SetTextColor(unpack(SOFT_INK)); frame.body:SetJustifyH("LEFT"); frame.body:SetWordWrap(true)
        EnableGuideLinks(frame,panel); frame.divider=Divider(frame)
        if key=="waters" or key=="gallery" or key=="supplies" then frame.border=FF:CreateJournalFrame(frame,false,6) end
        return frame
    end)
    section:SetParent(parent or panel.content)
    if parent then section:SetFrameLevel(parent:GetFrameLevel()+1) end
    section:SetWidth(JournalWidth(panel)); section.body:Hide()
    section.divider:SetShown(not section.border and not parent)
    Readable(section.heading,JournalTextSize(panel,16,14)); section.heading:SetWidth(section:GetWidth()-16)
    section.heading:SetText(title or ""); section.heading:SetShown(title~=nil)
    for _,item in ipairs(section.items) do item:Hide() end
    if section.variantGroups then for _,group in pairs(section.variantGroups) do group:Hide() end end
    return section,title and 7+section.heading:GetStringHeight()+7 or 7
end

local function NearbyName(font,value,width)
    font:SetWidth(math.max(1,width)); font:SetWordWrap(true)
    if font.SetMaxLines then font:SetMaxLines(0) end
    font:SetText("Ag"); local line=font:GetStringHeight(); font:SetText(value)
    if font:GetStringHeight()>line*2+.5 then
        local chars={}; for char in value:gmatch("[%z\1-\127\194-\244][\128-\191]*") do chars[#chars+1]=char end
        local low,high,best=0,#chars,0
        while low<=high do
            local mid=math.floor((low+high)/2); font:SetText(table.concat(chars,"",1,mid).."…")
            if font:GetStringHeight()<=line*2+.5 then best=mid; low=mid+1 else high=mid-1 end
        end
        font:SetText(table.concat(chars,"",1,best).."…")
    end
    if font.SetMaxLines then font:SetMaxLines(2) end
    return line*2
end

local function NearbyToggle(panel,key)
    GameTooltip:Hide()
    local offset=panel.scroll:GetVerticalScroll()
    panel.expandedGuides[key]=not panel.expandedGuides[key]
    FF:RenderNearby()
    panel.scroll:SetVerticalScroll(math.min(offset,panel.scroll:GetVerticalScrollRange()))
end

-- Reuse the existing rounded flyout assets as nine-slices: fixed corners,
-- stretched rails/centre, restrained bronze states on parchment.
local function NearbyBronzeButton(parent,label,onClick,textColor)
    local button=WarmTab(parent,label,onClick)
    local path,size=button.label:GetFont(); FF:SetDisplayFont(button.label, path,size,"")
    if journalFonts[button.label] then journalFonts[button.label].flags="" end
    button.label:SetShadowColor(0,0,0,0); button.label:SetShadowOffset(0,0)
    button.labelColor=textColor
    button.bg:Hide(); button.marker:Hide()
    if button.GetHighlightTexture then
        -- The Forever client rejects nil in SetHighlightTexture. Keep the
        -- installed native highlight and suppress it with texture alpha;
        -- Show/LockHighlight cannot make the old rectangular layer visible.
        local old=button:GetHighlightTexture(); if old then old:SetAlpha(0) end
    end
    RoundedButtonLayers(button)
    button.Paint=function(b)
        local active,hover=b.selected,b.nearbyHovered
        local alpha=active and (hover and .19 or .14) or (hover and .09 or .035)
        for _,t in ipairs(b.bronzeLayers[1]) do t:SetVertexColor(.39,.25,.10,alpha) end
        for _,t in ipairs(b.bronzeLayers[2]) do t:SetVertexColor(.48,.30,.13,active and .75 or hover and .65 or .45) end
        b.label:SetTextColor(unpack(b.labelColor or (active and CATCH_HEADING_INK or hover and INK or SOFT_INK)))
    end
    button:HookScript("OnEnter",function(b) b.nearbyHovered=true; b:Paint() end)
    button:HookScript("OnLeave",function(b) b.nearbyHovered=nil; b:Paint() end)
    button:HookScript("OnHide",function(b) b.nearbyHovered=nil; b:Paint() end)
    button:Paint(); return button
end

local function NearbyGrid(section,panel,entries,top)
    if #entries==0 then return top end
    section.variantGroups=section.variantGroups or {}
    for _,group in pairs(section.variantGroups) do group:Hide() end
    local width=section:GetWidth()-16
    local columns=math.max(1,math.floor((width+6)/98)); local cell=(width-(columns-1)*6)/columns
    local y,rowHeight,openFamilies=top,0,{}
    local function FinishRow()
        y=y+rowHeight+6; rowHeight=0
        -- A family opens beneath its complete gallery row, so its individual
        -- icons can use the full panel width rather than a narrow nested column.
        for _,entry in ipairs(openFamilies) do
            local group=section.variantGroups[entry.family]
            if not group then
                group=CreateFrame("Frame",nil,section); group:EnableMouse(false); group.items={}
                group.heading=Readable(PaperText(group,"GameFontNormal","TOPLEFT",group,"TOPLEFT",8,-3,""),12)
                group.heading:SetTextColor(unpack(SOFT_INK)); group.heading:SetJustifyH("LEFT"); group.heading:SetWordWrap(true)
                group.rule=group:CreateTexture(nil,"BORDER"); group.rule:SetHeight(1)
                group.rule:SetPoint("TOPLEFT",group,"TOPLEFT",8,0); group.rule:SetPoint("TOPRIGHT",group,"TOPRIGHT",-8,0)
                group.rule:SetColorTexture(.48,.30,.13,.18); section.variantGroups[entry.family]=group
            end
            group:SetWidth(section:GetWidth()); Readable(group.heading,JournalTextSize(panel,12,11))
            group.heading:SetWidth(width); group.heading:SetText(FF:LocalizedText("nearby.family.individual",FF:GetJournalFamilyDisplayName(entry.family)))
            for _,tile in ipairs(group.items) do tile:Hide() end
            local height=NearbyGrid(group,panel,entry.variants,group.heading:GetStringHeight()+7)
            group:ClearAllPoints(); group:SetPoint("TOPLEFT",section,"TOPLEFT",0,-y)
            group:SetHeight(height); group:Show(); y=y+height+4
        end
        openFamilies={}
    end
    for index,entry in ipairs(entries) do
        local tile=section.items[index]
        if not tile then
            tile=CreateFrame("Button",nil,section); tile:RegisterForClicks("LeftButtonUp")
            tile.icon=tile:CreateTexture(nil,"ARTWORK"); tile.icon:SetTexCoord(.07,.93,.07,.93); RoundIcon(tile.icon)
            tile.label=Readable(PaperText(tile,"GameFontHighlight","TOPLEFT",tile,"TOPLEFT",0,0,""),12)
            tile.label:SetJustifyH("CENTER"); tile.label:SetTextColor(unpack(INK))
            local function OpenCatch(b) FF:OpenGuideCatch(b.itemID) end
            local function HoverCatch(b)
                local record=FF.db.journal[b.itemID]
                local note=FF:LocalizedText(record and record.count>0 and "nearby.catch.recorded" or "nearby.catch.uncaught")
                if b.variants then note=note.."\n"..FF:LocalizedText("nearby.family.tip",FF:GetJournalFamilyDisplayName(b.family),#b.variants) end
                FF:ShowJournalCatchTooltip(b,b.itemID,note)
            end
            local function LeaveCatch(b) FF:HideJournalItemTooltip(b) end
            tile:SetScript("OnClick",OpenCatch); tile:SetScript("OnEnter",HoverCatch); tile:SetScript("OnLeave",LeaveCatch)
            -- The name retains its complete navigation/hover area below the
            -- icon's narrower hit region, clear of the summary chevron.
            tile.nameAction=CreateFrame("Button",nil,tile); tile.nameAction:RegisterForClicks("LeftButtonUp")
            tile.nameAction:SetScript("OnClick",OpenCatch); tile.nameAction:SetScript("OnEnter",HoverCatch)
            tile.nameAction:SetScript("OnLeave",LeaveCatch); CatchListWheel(panel,tile.nameAction)
            local choices=CreateFrame("Button",nil,tile); choices:SetSize(22,24); choices:RegisterForClicks("LeftButtonUp")
            choices.icon=choices:CreateTexture(nil,"ARTWORK"); choices.icon:SetSize(12,7)
            SetJournalChevron(choices.icon,false); choices.icon:SetPoint("CENTER",choices,"CENTER",0,0)
            choices:SetScript("OnClick",function(b) NearbyToggle(panel,b.expansionKey) end)
            choices:SetScript("OnEnter",function(b)
                GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("nearby.family.heading"))
                GameTooltip:AddLine(FF:LocalizedText("nearby.family.toggle"),.8,.8,.8,true); GameTooltip:Show()
            end)
            choices:SetScript("OnLeave",function() GameTooltip:Hide() end)
            tile.choices=choices; CatchListWheel(panel,tile); CatchListWheel(panel,choices); section.items[index]=tile
        end
        if (index-1)%columns==0 and index>1 then FinishRow() end
        local id=entry[1] or entry.id; tile.itemID=id; tile.variants=entry.variants; tile.family=entry.family; tile:SetWidth(cell)
        local layout=FF:FrameJournalItemIcon(tile,tile.icon,id,36,false,false)
        tile.icon:SetTexture(FF:GetJournalItemIcon(id)); tile.icon:SetDesaturated(false); tile.icon:SetAlpha(1)
        local choices=entry.variants and #entry.variants>1
        tile.icon:ClearAllPoints(); tile.icon:SetPoint("TOP",tile,"TOP",0,-34+layout.centerY+layout.artwork/2)
        local expansionKey="nearby:family:"..(panel.nearbyZone or "")..":"..(entry.family or id)
        tile.choices.expansionKey=expansionKey; tile.choices:SetShown(choices)
        SetJournalChevron(tile.choices.icon,panel.expandedGuides[expansionKey])
        if choices and panel.expandedGuides[expansionKey] then openFamilies[#openFamilies+1]=entry end
        tile.choices:ClearAllPoints(); tile.choices:SetPoint("LEFT",tile.icon,"CENTER",layout.right+7,0)
        -- Keep navigation inside the decorated icon column. The independent
        -- chevron starts four units beyond that hit region, including when it
        -- extends into the space between neighbouring gallery cells.
        tile:SetHitRectInsets(math.max(0,cell/2-layout.left-3),math.max(0,cell/2-layout.right-3),0,0)
        Readable(tile.label,JournalTextSize(panel,12,11))
        local labelHeight=NearbyName(tile.label,entry.family and FF:GetJournalFamilyDisplayName(entry.name) or FF:GetJournalItemDisplayName(entry[1] or entry.id,entry[2] or entry.name),cell-4)
        tile.label:ClearAllPoints(); tile.label:SetPoint("TOPLEFT",tile,"TOPLEFT",2,-67)
        local nameAction=tile.nameAction
        nameAction.itemID,nameAction.variants,nameAction.family,nameAction.icon=id,entry.variants,entry.family,tile.icon
        nameAction:SetSize(cell-4,labelHeight); nameAction:ClearAllPoints(); nameAction:SetPoint("TOPLEFT",tile,"TOPLEFT",2,-67)
        tile:SetHeight(67+labelHeight+6); tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT",section,"TOPLEFT",8+((index-1)%columns)*(cell+6),-y)
        rowHeight=math.max(rowHeight,tile:GetHeight()); tile:Show()
    end
    section.galleryColumns=columns; section.galleryCount=#entries
    FinishRow(); return y
end

local function NearbyServiceTooltip(button)
    local service=button.service
    local quest=FF:GetJournalQuestReference(service.label)
    if quest then
        local panel=FF.journalPanel
        local hover={panel=panel,target=service,quest=quest,person=button.person,
            tab=FF.journalTab,generation=panel.guideTooltipGeneration,
            scroll=panel.scroll:GetVerticalScroll()}
        button.journalGuideHover=hover
        ShowGuideQuestTooltip(button,hover)
        return
    end
    GameTooltip:SetOwner(button,"ANCHOR_RIGHT")
    local native=false
    if service.kind=="meal" or service.kind=="item" then
        native=FF:BeginJournalItemTooltip(button,service.id,service.label)
    elseif service.kind=="spell" then
        local ok,result=pcall(GameTooltip.SetHyperlink,GameTooltip,"spell:"..service.id)
        native=ok and result~=false
    end
    if not native then GameTooltip:SetText(FF:GetNearbyServiceDisplayText(service,"label"),1,.82,.45) end
    if service.kind=="meal" then
        -- Canonical Nearby recipe records identify the cooked output. Do not
        -- invent a recipe-scroll item ID when displaying that recipe's icon.
        GameTooltip:AddLine(FF:LocalizedText("nearby.service.recipe",service.label),1,.82,.45,true)
        for _,meal in ipairs(FF.masterChefMeals) do if meal.id==service.id then
            GameTooltip:AddLine(FF:LocalizedText("nearby.service.ingredients",meal.skill,meal.ingredients),.8,.8,.8,true); break
        end end
        GameTooltip:AddLine(FF:LocalizedText("nearby.service.open-recipe"),.7,.7,.7,true)
    elseif service.kind=="guideuse" then GameTooltip:AddLine(FF:LocalizedText("nearby.service.open-guide"),.7,.7,.7,true) end
    if service.limited then
        GameTooltip:AddLine(FF:LocalizedText("nearby.service.limited-tip"),.78,.62,.36,true)
    end
    if service.tooltip then GameTooltip:AddLine(FF:GetNearbyServiceDisplayText(service,"tooltip"),.8,.8,.8,true) end
    GameTooltip:AddLine(FF:GetJournalNPCDisplayName(button.person.point.name).." • "..FF:GetJournalSourceLocationText(button.person.point),.78,.71,.57,true)
    if FF.journalItemTooltipOwner == button then FF:FinishJournalItemTooltip(button)
    else GameTooltip:Show() end
end

local function NearbyServices(row,panel,person,top,width)
    row.serviceGroups=row.serviceGroups or {}
    for _,group in pairs(row.serviceGroups) do group:Hide() end
    local groups={Sells={},Recipes={},Training={},Other={}}
    for _,service in ipairs(person.services) do
        local key=service.kind=="meal" and "Recipes" or service.kind=="item" and "Sells"
            or service.kind=="info" and person.roles["Fishing trainer"] and "Training" or "Other"
        groups[key][#groups[key]+1]=service
    end
    local y=top
    for _,key in ipairs({"Training","Sells","Recipes","Other"}) do if #groups[key]>0 then
        local group=row.serviceGroups[key]
        if not group then
            group=CreateFrame("Frame",nil,row); group:EnableMouse(false); group.items={}
            group.label=Readable(PaperText(group,"GameFontNormal","TOPLEFT",group,"TOPLEFT",0,0,""),12)
            group.label:SetTextColor(unpack(SOFT_INK)); group.label:SetJustifyH("LEFT"); group.label:SetWordWrap(true)
            row.serviceGroups[key]=group
        end
        group:ClearAllPoints(); group:SetPoint("TOPLEFT",row,"TOPLEFT",8,-y); group:SetWidth(width)
        Readable(group.label,JournalTextSize(panel,12,11)); group.label:SetWidth(width)
        group.label:SetText(FF:LocalizedText("nearby.service."..({Training="training",Sells="sells",Recipes="recipes",Other="other"})[key]))
        local x,sy,lineHeight=0,group.label:GetStringHeight()+4,0
        for index,service in ipairs(groups[key]) do
            local button=group.items[index]
            if not button then
                button=CreateFrame("Button",nil,group); button:RegisterForClicks("LeftButtonUp")
                button.icon=button:CreateTexture(nil,"ARTWORK"); button.icon:SetPoint("CENTER",button,"CENTER",0,0)
                RoundIcon(button.icon)
                button.label=Readable(PaperText(button,"GameFontHighlight","TOPLEFT",button,"TOPLEFT",4,-3,""),12)
                button.label:SetTextColor(unpack(INK)); button.label:SetJustifyH("LEFT"); button.label:SetWordWrap(true)
                button.limited=Readable(PaperText(button,"GameFontHighlight","TOPLEFT",button,"TOPLEFT",0,0,""),11)
                button.limited:SetJustifyH("CENTER"); button.limited:SetWordWrap(false); button.limited:SetTextColor(unpack(CATCH_HEADING_INK))
                button:SetScript("OnEnter",NearbyServiceTooltip)
                button:SetScript("OnLeave",function(b) FF:HideJournalQuestTooltip(b); FF:HideJournalItemTooltip(b) end)
                button:SetScript("OnClick",function(b)
                    local target=b.service
                    if target.kind=="meal" then FF:OpenGuideMeal(target.id)
                    elseif target.kind=="guideuse" then FF:OpenJournalGuideUse(target) end
                end)
                CatchListWheel(panel,button); group.items[index]=button
            end
            button.service,button.person=service,person
            local texture
            if service.kind=="meal" or service.kind=="item" then
                texture=FF:GetJournalItemIcon(service.id)
                if texture=="Interface\\Icons\\INV_Misc_QuestionMark" then texture=nil end
            elseif service.kind=="spell" then
                if C_Spell and C_Spell.GetSpellTexture then texture=C_Spell.GetSpellTexture(service.id)
                elseif GetSpellTexture then texture=GetSpellTexture(service.id) end
            end
            local w,h=38,38
            if texture then
                button.icon:Show(); button.icon:SetTexture(texture); FF:FrameJournalRoundIcon(button.icon,28):Show()
                button.label:Hide()
            else
                button.icon:Hide()
                if button.icon.journalBronzeFrame then button.icon.journalBronzeFrame:Hide() end
                Readable(button.label,JournalTextSize(panel,12,11)); button.label:SetWidth(0)
                local quest=FF:GetJournalQuestReference(service.label)
                button.label:SetText(quest and ("|cff"..FF.journalQuestColor..FF:JournalQuestTitleText(service.label).."|r") or FF:GetNearbyServiceDisplayText(service,"label"))
                button.label:Show()
                w=math.min(width,math.max(38,button.label:GetStringWidth()+8)); button.label:SetWidth(math.max(1,w-8))
                h=math.max(30,button.label:GetStringHeight()+6)
            end
            button.limited:Hide()
            button.limited:SetText(FF:LocalizedText("nearby.service.limited"))
            button.limited:SetWordWrap(FF:GetResolvedLocale()~="enUS")
            if service.limited then
                Readable(button.limited,JournalTextSize(panel,11,11)); button.limited:SetWidth(0)
                w=math.min(width,math.max(w,math.ceil(button.limited:GetStringWidth())+6))
                button.limited:SetWidth(w); button.limited:ClearAllPoints()
                button.limited:SetPoint("TOPLEFT",button,"TOPLEFT",0,-h)
                if texture then
                    button.icon:ClearAllPoints(); button.icon:SetPoint("TOP",button,"TOP",0,-5)
                end
                h=h+button.limited:GetStringHeight()+3; button.limited:Show()
            elseif texture then button.icon:ClearAllPoints(); button.icon:SetPoint("CENTER",button,"CENTER",0,0) end
            if x>0 and x+w>width then x=0; sy=sy+lineHeight+4; lineHeight=0 end
            button:SetSize(w,h); button:ClearAllPoints(); button:SetPoint("TOPLEFT",group,"TOPLEFT",x,-sy); button:Show()
            x=x+w+5; lineHeight=math.max(lineHeight,h)
        end
        for index=#groups[key]+1,#group.items do group.items[index]:Hide() end
        local height=sy+lineHeight; group:SetHeight(height); group:Show(); y=y+height+5
    end end
    return y
end

local function NearbyZoneControls(panel)
    if panel.nearbyZoneControls then return panel.nearbyZoneControls end
    local controls=CreateFrame("Frame",nil,panel.page); controls:SetSize(243,26)
    controls:SetPoint("TOPRIGHT",panel.page,"TOPRIGHT",-20,-18)
    controls.current=NearbyBronzeButton(controls,FF:LocalizedText("nearby.current"),function() FF:SetNearbyZone(nil) end,INK)
    controls.current:SetPoint("RIGHT",controls,"RIGHT",0,0)
    local selector=NearbyBronzeButton(controls,"",function(button) FF:OpenJournalNearbyZonePicker(button) end,INK)
    selector:SetSize(175,24); selector:SetPoint("LEFT",controls,"LEFT",0,0)
    selector.icon=selector:CreateTexture(nil,"ARTWORK"); selector.icon:SetSize(12,7)
    selector.icon:SetPoint("RIGHT",selector,"RIGHT",-5,0); SetJournalChevron(selector.icon,false)
    selector.chevron=selector.icon; selector.anchor=controls; selector.paper=ParchmentSlices
    selector.label:ClearAllPoints(); selector.label:SetPoint("LEFT",selector,"LEFT",9,0)
    selector:HookScript("OnEnter",function(button)
        GameTooltip:SetOwner(button,"ANCHOR_RIGHT"); GameTooltip:SetText(button.zoneName or FF:LocalizedText("journal.zone-unavailable"))
        GameTooltip:AddLine(FF:LocalizedText(panel.nearbySelectedZone and "nearby.browse-tip" or "nearby.follow-tip"),.8,.8,.8,true); GameTooltip:Show()
    end)
    selector:HookScript("OnLeave",function() GameTooltip:Hide() end)
    controls.selector=selector; controls.menu=FF:GetJournalFloatingPicker(panel,ParchmentSlices)
    controls:HookScript("OnHide",function() controls.menu:Hide() end)
    panel.nearbyZoneControls=controls; return controls
end

local function NearbyConditions(panel,data,skills,width)
    local section=NearbySection(panel,"waters",FF:LocalizedText("nearby.heading.conditions"))
    local key="nearby:conditions:"..(data.zone or "")
    if panel.expandedGuides[key]==nil then panel.expandedGuides[key]=true end
    local expanded=panel.expandedGuides[key]
    section.rows=section.rows or {}; section.poolSections=section.poolSections or {}
    for _,row in pairs(section.rows) do row:Hide() end
    for _,pool in pairs(section.poolSections) do pool:Hide() end
    if not section.toggle then
        local button=CreateFrame("Button",nil,section); button:RegisterForClicks("LeftButtonUp")
        button.icon=button:CreateTexture(nil,"ARTWORK"); button.icon:SetSize(12,7); button.icon:SetPoint("RIGHT",button,"RIGHT",-17,0)
        local hover=button:CreateTexture(nil,"HIGHLIGHT"); hover:SetAllPoints(button); hover:SetColorTexture(.48,.30,.13,.06)
        button:SetHighlightTexture(hover)
        button:SetScript("OnClick",function(b) NearbyToggle(panel,b.expansionKey) end)
        CatchListWheel(panel,button); section.toggle=button
    end
    section.heading:SetWidth(width-48)
    local headerHeight=math.max(28,14+section.heading:GetStringHeight())
    section.headerHeight=headerHeight
    section.toggle:SetSize(width,headerHeight); section.toggle:ClearAllPoints(); section.toggle:SetPoint("TOPLEFT",section,"TOPLEFT",0,0)
    section.toggle.expansionKey=key; SetJournalChevron(section.toggle.icon,expanded)
    local top=headerHeight
    if not expanded then return section,top end
    local function Row(id,asset,title,value,explanation)
        if not value or value=="" then return end
        local row=section.rows[id]
        if not row then
            row=CatchGuidanceRow(section,panel,"",asset); section.rows[id]=row
            local button=CreateFrame("Button",nil,row); button:SetSize(34,34)
            button:SetPoint("TOPLEFT",row,"TOPLEFT",10,0)
            button:SetScript("OnEnter",function(b)
                GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:SetText(b.title)
                GameTooltip:AddLine(b.explanation,.8,.8,.8,true); GameTooltip:Show()
            end)
            local function Hide(b) if GameTooltip:GetOwner()==b then GameTooltip:Hide() end end
            button:SetScript("OnLeave",Hide); button:SetScript("OnHide",Hide)
            CatchListWheel(panel,button); row.medallion=button
        end
        row.heading:Hide(); row.divider:Hide(); row:SetWidth(width)
        Readable(row.value,JournalTextSize(panel,13,12)); row.value:SetTextColor(unpack(INK))
        row.value:ClearAllPoints(); row.value:SetPoint("TOPLEFT",row,"TOPLEFT",50,-8)
        row.value:SetWidth(width-64); row.value:SetText(FF:GuideLinkText(value,true,true))
        row:SetHeight(math.max(34,8+row.value:GetStringHeight()+6))
        row:ClearAllPoints(); row:SetPoint("TOPLEFT",section,"TOPLEFT",0,-top)
        row.medallion.title=title; row.medallion.explanation=explanation
        row:Show(); top=top+row:GetHeight()+2
    end
    -- Translate display categories after canonical discovery; never feed display
    -- wording back into availability, pool matching or saved identities.
    local waterKeys={["Inland water"]="inland",["Coastal water"]="coastal",["Open water"]="open"}
    local waterTypes={}
    for _,water in ipairs(data.waterTypes) do waterTypes[#waterTypes+1]=waterKeys[water]
        and FF:LocalizedText("nearby.water."..waterKeys[water]) or water end
    local method=#waterTypes>0 and table.concat(waterTypes," • ") or (#data.pools>0 and FF:LocalizedText("nearby.pools") or "")
    for _,essential in ipairs(data.essentialMethods) do method=method..(method~="" and "\n" or "")..FF:GetNearbyProseDisplayText(essential) end
    if data.notes~="" then
        local notes
        if FF:GetResolvedLocale()=="enUS" then notes=ColorGuideSkills(skills,data.notes:gsub("\n"," • "),"Fishing",false,true)
        else notes=FF:GetNearbyProseDisplayText(data.notes,"\n",function(raw) return ColorGuideSkills(skills,raw,"Fishing",false,true) end):gsub("\n"," • ") end
        method=method..(method~="" and "\n" or "")..notes
    end
    Row("method","CJ02",FF:LocalizedText("nearby.heading.method"),method,FF:LocalizeReferenceZones(FF:GetNearbyProseDisplayText(data.methodDetails," • ")).."\n"..FF:LocalizedText("nearby.leads-tip"))
    local function Threshold(value) return ColorRequirement(skills,tostring(value),"Fishing",value,nil,GUIDE_SKILL_COLORS) end
    local skill=data.skill and FF:LocalizedText("nearby.skill-thresholds",Threshold(data.skill.minimum),Threshold(data.skill.reliable)) or ""
    if data.caveat then
        local caveat=data.caveat:gsub("(%d+)( minimum)",function(n,s) return Threshold(tonumber(n))..s end)
        caveat=caveat:gsub("(%d+)( reliable)",function(n,s) return Threshold(tonumber(n))..s end)
        skill=skill..(skill~="" and "\n" or "")..(FF:GetNearbyCaveatDisplayText(data.caveat,Threshold) or caveat)
    end
    Row("skill","CJ04",FF:LocalizedText("nearby.heading.skill"),skill,FF:LocalizedText("nearby.skill-tip"))
    local pools={}
    for _,pool in ipairs(data.pools) do
        local names={}; for _,entry in ipairs(pool.catches) do names[#names+1]=FF:GetJournalItemDisplayName(entry[1],entry[2]) end
        pools[#pools+1]=FF:GuideTargetLink({kind="nearbypool",id=pool.name,label=pool.name,
            tooltip=pool.note.."\nKnown catches: "..table.concat(names,", ")},FF:GetJournalPoolDisplayName(pool.name))
    end
    Row("waters","CJ01",FF:LocalizedText("nearby.heading.waters"),table.concat(pools," • "),FF:LocalizedText("nearby.waters-tip"))
    if top==headerHeight then
        Readable(section.body,JournalTextSize(panel,13,12)); section.body:SetWidth(width-16)
        section.body:ClearAllPoints(); section.body:SetPoint("TOPLEFT",section,"TOPLEFT",8,-top)
        section.body:SetText(FF:LocalizedText("nearby.conditions-empty")); section.body:Show()
        top=top+section.body:GetStringHeight()+6
    end
    for _,pool in ipairs(data.pools) do if panel.expandedGuides["nearby:pool:"..pool.name] then
        local child=NearbySection(panel,"pool:"..pool.name,FF:GetJournalPoolDisplayName(pool.name),section)
        section.poolSections[pool.name]=child; child:SetWidth(width-16); child.heading:SetWidth(width-32)
        Readable(child.heading,JournalTextSize(panel,13,12))
        child:SetHeight(NearbyGrid(child,panel,pool.catches,7+child.heading:GetStringHeight()+3))
        child:ClearAllPoints(); child:SetPoint("TOPLEFT",section,"TOPLEFT",8,-top); child:Show()
        top=top+child:GetHeight()+3
    end end
    return section,top+6
end

function FF:RenderNearby()
    local panel=self.journalPanel; ClearDynamic(panel)
    panel.expandedGuides=panel.expandedGuides or {}; panel.nearbyFilters=panel.nearbyFilters or {}
    panel.routeTrainingSources=panel.routeTrainingSources or {}; panel.routeSelectors={}
    for rank in pairs(panel.routeTrainingSources) do if rank:sub(1,7)=="Nearby:" then panel.routeTrainingSources[rank]=nil end end
    local data=self:BuildNearbyData(); local width=JournalWidth(panel); local zoneKey=data.zone or ""
    local zoneDisplay=self:GetZoneDisplayName(data.zone)
    local skills=panel.journalSkills or self:GetJournalSkills()
    panel.nearbyMapID,panel.nearbyZone,panel.nearbyFaction=data.mapID,data.zone,data.faction
    panel.nearbyCatchRevision,panel.nearbyLocationRevision=self.catchRevision,self.journalLocationRevision
    panel.nearbyData=data; panel.pageTitle:SetText(self:LocalizedText("journal.guide.nearby.label")); panel.pageTitle:SetWidth(math.max(1,width-260))
    SetJournalPageSubtitle(panel,zoneDisplay or FF:LocalizedText("journal.zone-unavailable"))
    local controls=NearbyZoneControls(panel); controls:Show()
    Readable(controls.selector.label,JournalTextSize(panel,13,12)); controls.selector.zoneName=zoneDisplay
    FitJournalText(controls.selector.label,zoneDisplay or self:LocalizedText("nearby.zone-unavailable"),145)
    controls.current.label:SetText(self:LocalizedText("nearby.current"))
    Readable(controls.current.label,JournalTextSize(panel,12,11)); controls.current.label:SetWidth(0)
    local translated=self:GetResolvedLocale()~="enUS"
    if translated then controls.current.label:SetWidth(math.min(110,math.ceil(controls.current.label:GetStringWidth()))) end
    controls.current.label:ClearAllPoints(); controls.current.label:SetPoint("CENTER",controls.current,"CENTER",0,0)
    local controlHeight=math.max(26,math.ceil(controls.current.label:GetStringHeight())+10)
    local currentWidth=math.max(62,math.ceil(math.min(translated and 110 or math.huge,controls.current.label:GetStringWidth()))+18)
    controls.current:SetSize(currentWidth,controlHeight); controls.selector:SetSize(175,controlHeight)
    controls:SetSize(175+6+currentWidth,controlHeight)
    controls.current.selected=panel.nearbySelectedZone==nil; controls.current:Paint(); controls.selector:Paint()
    panel.pageTitle:SetWidth(math.max(1,width-controls:GetWidth()-18))
    -- Preserve English geometry; translated controls/title may wrap vertically.
    local headerTop=translated and math.max(55,18+math.max(controlHeight,panel.pageTitle:GetStringHeight())+8) or 55
    panel.pageSubtitle:ClearAllPoints(); panel.pageSubtitle:SetPoint("TOPLEFT",panel.page,"TOPLEFT",24,-headerTop)
    SetJournalPageSubtitle(panel,zoneDisplay or self:LocalizedText("journal.zone-unavailable"),nil,nil,headerTop)
    local y=0
    local function Place(section,height)
        section:SetHeight(height); section:ClearAllPoints(); section:SetPoint("TOPLEFT",panel.content,"TOPLEFT",0,-y)
        section.contentY=y; AddDynamic(panel,section); y=y+height+5
    end
    local function Body(section,top,value,size)
        Readable(section.body,JournalTextSize(panel,size or 13,12)); section.body:SetWidth(width-16)
        section.body:ClearAllPoints(); section.body:SetPoint("TOPLEFT",section,"TOPLEFT",8,-top)
        section.body:SetText(value); section.body:Show(); return top+section.body:GetStringHeight()+6
    end
    local section,top=NearbyConditions(panel,data,skills,width)
    Place(section,top)
    section,top=NearbySection(panel,"gallery",FF:LocalizedText("nearby.heading.gallery"))
    local entries,filters,filter=self:GetNearbyCatchGallery(data,panel.nearbyFilters[zoneKey])
    panel.nearbyFilters[zoneKey]=filter; panel.nearbyGallery=entries; panel.nearbyAvailableFilters=filters
    section.filters=section.filters or {}; local buttons,total={},0
    for _,choice in ipairs({{"all","nearby.filter.all"},{"rare","nearby.filter.rare"},{"trophy","nearby.filter.trophy"},{"common","nearby.filter.common"}}) do
        local key,label=choice[1],self:LocalizedText(choice[2]); local button=section.filters[key]
        if not button then
            button=NearbyBronzeButton(section,label,function()
                local offset=panel.scroll:GetVerticalScroll(); panel.nearbyFilters[panel.nearbyZone or ""]=key
                FF:RenderNearby(); panel.scroll:SetVerticalScroll(math.min(offset,panel.scroll:GetVerticalScrollRange()))
            end)
            CatchListWheel(panel,button); section.filters[key]=button
        end
        button:SetShown(filters[key]==true)
        if filters[key] then
            local path,size=button.label:GetFont(); FF:SetDisplayFont(button.label, path,size,"")
            button.label:SetShadowColor(0,0,0,0); button.label:SetShadowOffset(0,0)
            button.label:SetText(label)
            Readable(button.label,JournalTextSize(panel,12,11)); button.label:SetWidth(0)
            if translated then button.label:SetWidth(math.min(width-32,math.ceil(button.label:GetStringWidth()))) end
            button.label:ClearAllPoints(); button.label:SetPoint("LEFT",button,"LEFT",8,0)
            button.label:SetTextColor(unpack(INK))
            button:SetSize(math.ceil(math.min(translated and width-32 or math.huge,button.label:GetStringWidth()))+16,24)
            button.selected=key==filter; button.marker:Hide(); button.bg:SetColorTexture(.39,.25,.10,key==filter and .14 or .035)
            button:SetHeight(math.max(24,math.ceil(button.label:GetStringHeight())+8)); button:Paint()
            buttons[#buttons+1]=button; total=total+button:GetWidth()+3
        end
    end
    total=math.max(0,total-3)
    local filterTop=section.heading:GetStringWidth()+12+total<=width-16 and 3 or top
    section.heading:SetWidth(filterTop==3 and math.max(1,width-total-28) or width-16)
    local x=filterTop==3 and width-8-total or 8
    local filterRow,filterRowHeight=filterTop,0
    for _,button in ipairs(buttons) do
        if translated and x>8 and x+button:GetWidth()>width-8 then
            x=8;filterRow=filterRow+filterRowHeight+3;filterRowHeight=0
        end
        button:ClearAllPoints(); button:SetPoint("TOPLEFT",section,"TOPLEFT",x,-filterRow)
        x=x+button:GetWidth()+3;filterRowHeight=math.max(filterRowHeight,button:GetHeight())
    end
    local filterHeight=24; for _,button in ipairs(buttons) do filterHeight=math.max(filterHeight,button:GetHeight()) end
    top=math.max(top,filterTop+filterHeight+4,filterRow+filterRowHeight+4)
    if #entries>0 then Place(section,NearbyGrid(section,panel,entries,top))
    else section.galleryCount=0; section.galleryColumns=0
        Place(section,Body(section,top,self:LocalizedText("nearby.empty."..filter))) end
    local supplies,sourceY=NearbySection(panel,"supplies",FF:LocalizedText("nearby.heading.supplies"))
    local function LocalRow(row,height)
        row:SetHeight(height); row:ClearAllPoints(); row:SetPoint("TOPLEFT",supplies,"TOPLEFT",0,-sourceY)
        row.contentY=y+sourceY; AddDynamic(panel,row); sourceY=sourceY+height+5
    end
    local points,byPoint={},{}
    for _,person in ipairs(data.people) do points[#points+1]=person.point; byPoint[person.point]=person end
    table.sort(points,function(a,b) return byPoint[a].key<byPoint[b].key end)
    self:GetOrderedGuideMapPoints(points,true); panel.nearbyPeople={}
    for _,point in ipairs(points) do
        local person=byPoint[point]; panel.nearbyPeople[#panel.nearbyPeople+1]=person
        local key=person.key; local rank="Nearby:"..zoneKey..":"..key
        panel.routeTrainingSources[rank]={point}
        section,top=NearbySection(panel,"person:"..key,nil,supplies); top=0
        local expanded=panel.expandedGuides["nearby:person:"..key]==true
        local source=RouteSourceLink(panel,"nearby:npc:"..key,rank,1,false)
        Body(section,top,source,14)
        -- The full summary is the disclosure target. Native source links and
        -- map controls stay above it; expanded services start below it.
        local sourceHeight=self:LayoutJournalRouteInline(section,section.body,source,width-52,false,EnableGuideLinks,ParchmentSlices)
        if not section.tail then
            section.tail=Readable(PaperText(section,"GameFontHighlight","TOPLEFT",section,"TOPLEFT",8,0,""),12)
            section.tail:SetWordWrap(true); section.tail:SetJustifyH("LEFT"); section.tail:SetTextColor(unpack(SOFT_INK))
        end
        local distance=point.distance and self:LocalizedText("nearby.person.distance",math.floor(math.sqrt(point.distance)+.5)) or "?"
        Readable(section.tail,JournalTextSize(panel,12,11)); section.tail:SetWidth(width-52)
        section.tail:SetText(self:GetNearbyRoleDisplayText(person.roles).." • "..distance)
        section.tail:ClearAllPoints(); section.tail:SetPoint("TOPLEFT",section,"TOPLEFT",8,-sourceHeight-3); section.tail:Show()
        local summaryHeight=sourceHeight+3+section.tail:GetStringHeight()+6
        if not section.toggle then
            local button=CreateFrame("Button",nil,section); button:RegisterForClicks("LeftButtonUp")
            button.icon=button:CreateTexture(nil,"ARTWORK"); button.icon:SetSize(12,7); button.icon:SetPoint("RIGHT",button,"RIGHT",-17,0)
            local hover=button:CreateTexture(nil,"HIGHLIGHT"); hover:SetAllPoints(button); hover:SetColorTexture(.48,.30,.13,.06)
            button:SetHighlightTexture(hover)
            button:SetScript("OnClick",function(b) if b.expandable then NearbyToggle(panel,b.expansionKey) end end)
            button:SetScript("OnEnter",function(b)
                GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("nearby.person.services",FF:GetJournalNPCDisplayName(b.person.point.name)),1,.82,.45)
                GameTooltip:AddLine(FF:GetNearbyRoleDisplayText(b.person.roles),.8,.8,.8,true)
                GameTooltip:AddLine(b.person.point.distance and FF:LocalizedText("nearby.person.distance-tip",math.floor(math.sqrt(b.person.point.distance)+.5))
                    or FF:LocalizedText("nearby.person.distance-unavailable"),.8,.8,.8,true)
                GameTooltip:AddLine(FF:LocalizedText("nearby.person.toggle"),.7,.7,.7,true); GameTooltip:Show()
            end)
            button:SetScript("OnLeave",function() GameTooltip:Hide() end); CatchListWheel(panel,button); section.toggle=button
        end
        section.person,section.headerHeight=person,summaryHeight
        local toggle=section.toggle; toggle.person=person; toggle.expansionKey="nearby:person:"..key
        toggle:SetFrameLevel(section:GetFrameLevel()+1); toggle:SetSize(width,math.max(28,summaryHeight))
        toggle:ClearAllPoints(); toggle:SetPoint("TOPLEFT",section,"TOPLEFT",0,0)
        section.header=toggle
        local flow=section.routeInline
        flow:SetParent(toggle); flow:SetFrameLevel(toggle:GetFrameLevel()+1); flow.nearbyHeader=toggle
        for _,group in ipairs(flow.groups) do group:SetFrameLevel(flow:GetFrameLevel()+1) end
        for _,control in ipairs(flow.controls) do control:SetFrameLevel(flow:GetFrameLevel()+2) end
        if not flow.nearbyHeaderInput then
            -- Source links consume their own click; only a blank-text press
            -- and release forwards to the header. Child map buttons stay native.
            flow:SetScript("OnMouseDown",function(frame,button)
                frame.nearbyHeaderPressed=button=="LeftButton" and frame.nearbyHeader.expandable and not frame.linkHovered
            end)
            flow:SetScript("OnMouseUp",function(frame,button)
                local pressed=frame.nearbyHeaderPressed; frame.nearbyHeaderPressed=nil
                if pressed and button=="LeftButton" and not frame.linkHovered then
                    NearbyToggle(panel,frame.nearbyHeader.expansionKey)
                end
            end)
            flow:HookScript("OnHide",function(frame) frame.nearbyHeaderPressed=nil end)
            flow.nearbyHeaderInput=true
        end
        toggle.expandable=#person.services>0; toggle:EnableMouse(toggle.expandable); toggle:Show()
        SetJournalChevron(toggle.icon,expanded); toggle.icon:SetShown(toggle.expandable)
        if section.serviceGroups then for _,group in pairs(section.serviceGroups) do group:Hide() end end
        local bottom=expanded and NearbyServices(section,panel,person,summaryHeight+2,width-16) or summaryHeight
        section.divider:Show(); LocalRow(section,bottom+3)
    end
    section,top=NearbySection(panel,"local-tools",nil,supplies); top=0; local lines={}
    if #data.people==0 then lines[#lines+1]=self:LocalizedText(data.mapID and "nearby.sources-empty" or "nearby.map-unavailable") end
    lines[#lines+1]=self:GuideTargetLink({kind="guideuse",id="nearby:utilities",tab="gear",heading="Forever buffs and useful tools",label="Fishing kit & camp tools"},self:LocalizedText("nearby.tools"))
    LocalRow(section,Body(section,top,table.concat(lines,"\n")))
    Place(supplies,sourceY-2)
    section,top=NearbySection(panel,"records",nil)
    if not section.toggle then
        local button=CreateFrame("Button",nil,section); button:RegisterForClicks("LeftButtonUp")
        button.label=Readable(PaperText(button,"GameFontNormal","TOPLEFT",button,"TOPLEFT",0,0,""),14)
        button.label:SetJustifyH("LEFT"); button.label:SetWordWrap(true); button.label:SetTextColor(unpack(INK))
        button.icon=button:CreateTexture(nil,"ARTWORK"); button.icon:SetSize(12,7); button.icon:SetPoint("RIGHT",button,"RIGHT",0,0)
        button:SetScript("OnClick",function()
            local key="nearby:records:"..(panel.nearbyZone or ""); local offset=panel.scroll:GetVerticalScroll()
            panel.expandedGuides[key]=not panel.expandedGuides[key]; FF:RenderNearby(); panel.scroll:SetVerticalScroll(math.min(offset,panel.scroll:GetVerticalScrollRange()))
        end)
        button:SetScript("OnEnter",function(b)
            GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:SetText(FF:LocalizedText("nearby.records.title"))
            GameTooltip:AddLine(FF:LocalizedText("nearby.records.tip"),.8,.8,.8,true); GameTooltip:Show()
        end)
        button:SetScript("OnLeave",function() GameTooltip:Hide() end); CatchListWheel(panel,button); section.toggle=button
    end
    local expanded=panel.expandedGuides["nearby:records:"..zoneKey]; local toggle=section.toggle
    toggle:ClearAllPoints(); toggle:SetPoint("TOPLEFT",section,"TOPLEFT",8,-top); toggle:SetWidth(width-16)
    Readable(toggle.label,JournalTextSize(panel,14,12)); toggle.label:SetWidth(width-42)
    toggle.label:SetText(self:LocalizedText("nearby.records.summary",self:LocalizedPlural("nearby.records.types",data.recordTypes),self:LocalizedPlural("nearby.records.items",data.recordQuantity)))
    SetJournalChevron(toggle.icon,expanded); toggle:SetHeight(math.max(24,toggle.label:GetStringHeight()+4)); toggle:Show()
    local bottom=top+toggle:GetHeight()+5
    if expanded then
        local records={}
        for _,record in ipairs(data.records) do records[#records+1]=self:GuideTargetLink({kind="fish",id=record.id,label=record.name},record.name).." ×"..record.count end
        bottom=Body(section,bottom,#records>0 and table.concat(records,"\n") or self:LocalizedText("nearby.records.empty"))
    end
    Place(section,bottom+4); panel.content:SetHeight(math.max(1,y)); panel.renderedTab="nearby"
end

function FF:ToggleSessionHistory(show)
    local panel = self.journalPanel
    if not panel then return end
    if panel.sessionHistoryShown then panel.sessionHistoryScroll = panel.scroll:GetVerticalScroll()
    else panel.sessionCurrentScroll = panel.scroll:GetVerticalScroll() end
    panel.sessionHistoryShown = show == true
    self:SelectJournalTab("session")
    panel.scroll:SetVerticalScroll(math.min((show and panel.sessionHistoryScroll or panel.sessionCurrentScroll) or 0,
        panel.scroll:GetVerticalScrollRange()))
end

local function SessionHistoryCard(panel)
    local card = CreateFrame("Frame", nil, panel.content)
    card.pooled = true
    card.bg = Surface(card, 0.55, 0.40, 0.20, 0.045)
    card.border = FF:CreateJournalFrame(card)
    Divider(card)
    card.header = CreateFrame("Button", nil, card)
    card.header:SetPoint("TOPLEFT"); card.header:RegisterForClicks("LeftButtonUp")
    local hover = card.header:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(card.header); hover:SetColorTexture(0.55, 0.36, 0.16, 0.08)
    card.heading = Readable(PaperText(card.header, "GameFontNormal", "TOPLEFT", card.header, "TOPLEFT", 12, -10, ""), 16)
    card.heading:SetTextColor(unpack(INK)); card.heading:SetJustifyH("LEFT")
    card.summary = Readable(PaperText(card.header, "GameFontHighlight", "TOPLEFT", card.heading, "BOTTOMLEFT", 0, -6, ""), 13)
    card.summary:SetTextColor(unpack(SOFT_INK)); card.summary:SetJustifyH("LEFT"); card.summary:SetWordWrap(true)
    card.chevron = card.header:CreateTexture(nil, "ARTWORK")
    card.chevron:SetSize(12, 7); card.chevron:SetPoint("TOPRIGHT", card.header, "TOPRIGHT", -13, -18)
    card.header:SetScript("OnClick", function()
        if not card.entry then return end
        local scroll, oldY = panel.scroll:GetVerticalScroll(), card.contentY
        panel.expandedHistoryEntry = panel.expandedHistoryEntry ~= card.entry and card.entry or nil
        FF:RenderSessionHistory()
        -- Keep the clicked header at its screen position when opening it also
        -- collapses a card above it. Clamp only at the list's natural ends.
        panel.scroll:SetVerticalScroll(math.max(0, math.min(scroll + card.contentY - oldY,
            panel.scroll:GetVerticalScrollRange())))
    end)
    return card
end

local function SessionBreakdownColumn(detail, panel, label, catches)
    local column = CreateFrame("Frame", nil, detail)
    column.rows, column.catches = {}, catches
    column.heading = Readable(PaperText(column, "GameFontNormal", "TOPLEFT", column, "TOPLEFT", 0, 0, label), 14)
    column.heading:SetJustifyH("LEFT"); column.heading:SetTextColor(unpack(INK))
    column.rule = column:CreateTexture(nil, "BORDER")
    column.rule:SetPoint("TOPLEFT", column.heading, "BOTTOMLEFT", 0, -4)
    column.rule:SetHeight(1); column.rule:SetColorTexture(0.48,0.30,0.13,0.18)
    return column
end

local function RenderSessionBreakdown(column, panel, entries, width)
    column:SetWidth(width)
    Readable(column.heading, JournalTextSize(panel, 14, 12))
    column.heading:SetWidth(width); column.rule:SetWidth(width)
    local top = column.heading:GetStringHeight() + 10
    local step = math.max(22, math.ceil(select(2, column.heading:GetFont()) or 14) + 8)
    for index, item in ipairs(entries) do
        local row = column.rows[index]
        if not row then
            row = CreateFrame("Frame", nil, column); column.rows[index] = row
            row.name = Readable(PaperText(row, "GameFontHighlight", "LEFT", row, "LEFT", 0, 0, ""), 13)
            row.name:SetJustifyH("LEFT"); row.name:SetTextColor(unpack(SOFT_INK))
            row.quantity = Readable(PaperText(row, "GameFontHighlight", "RIGHT", row, "RIGHT", 0, 0, ""), 13)
            row.quantity:SetJustifyH("RIGHT"); row.quantity:SetTextColor(unpack(SOFT_INK))
            if column.catches then
                EnableGuideLinks(row, panel)
                row:SetScript("OnHide", function(button)
                    if GameTooltip.GetOwner and GameTooltip:GetOwner() == button then GameTooltip:Hide() end
                end)
            else
                -- Full location text remains available when its display name
                -- must shorten; this tooltip is specific to that location row.
                row:EnableMouse(true)
                row:SetScript("OnEnter", function(button)
                    GameTooltip:SetOwner(button, "ANCHOR_RIGHT"); GameTooltip:SetText(button.fullName); GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)
                row:SetScript("OnHide", function(button)
                    if GameTooltip.GetOwner and GameTooltip:GetOwner() == button then GameTooltip:Hide() end
                end)
                row:EnableMouseWheel(true)
                row:SetScript("OnMouseWheel", function(_, delta)
                    panel.scroll:SetVerticalScroll(math.max(0, math.min(panel.scroll:GetVerticalScrollRange(),
                        panel.scroll:GetVerticalScroll() - delta * 48)))
                end)
            end
        end
        local name = column.catches and FF:GetJournalItemDisplayName(item.id,item.name) or FF:GetFishingLocationDisplay(item.name)
        row.fullName, row.itemID = name, item.id
        row:SetSize(width, step); row:ClearAllPoints(); row:SetPoint("TOPLEFT", column, "TOPLEFT", 0, -top - (index - 1) * step)
        Readable(row.name, JournalTextSize(panel, 13, 12)); Readable(row.quantity, JournalTextSize(panel, 13, 12))
        row.quantity:SetText("×" .. item.count)
        local quantityWidth = math.max(30, math.ceil((select(2,row.quantity:GetFont()) or 13) * (#tostring(item.count) + 1) * 0.7))
        row.quantity:SetWidth(quantityWidth)
        FitJournalText(row.name,item.missingName and FF:LocalizedText("common.item-id",item.id) or name,math.max(24,width-quantityWidth-8))
        if column.catches then
            local display = row.name:GetText()
            row.name:SetText(FF:GuideTargetLink({kind="fish", id=item.id, label=item.name}, display))
        end
        row:Show()
    end
    for index = #entries + 1, #column.rows do column.rows[index]:Hide() end
    local height = top + #entries * step
    column:SetHeight(height); column:Show()
    return height
end

local function SessionDetailLists(self, entry)
    local items, locations = {}, {}
    for id, record in pairs(entry.records or {}) do
        local itemID = tonumber(id)
        if type(record) == "table" then
            if itemID and (tonumber(record.count) or 0) > 0 then
                local saved = self.db.journal[itemID] or self.db.journal[tostring(itemID)]
                local name = saved and saved.name or (GetItemInfo and GetItemInfo(itemID))
                local missingName=not name
                name=name or ("Item " .. itemID)
                items[#items + 1] = {id=itemID, name=name, count=record.count,missingName=missingName}
            end
            for place, count in pairs(record.locations or {}) do
                if type(place) == "string" and (tonumber(count) or 0) > 0 then
                    locations[place] = (locations[place] or 0) + tonumber(count)
                end
            end
        end
    end
    if not next(locations) then
        for place, count in pairs(entry.locations or {}) do
            if type(place) == "string" and (tonumber(count) or 0) > 0 then locations[place] = tonumber(count) end
        end
    end
    table.sort(items, function(a,b) return a.name < b.name or (a.name == b.name and a.id < b.id) end)
    local places = {}
    for name, count in pairs(locations) do places[#places + 1] = {name=name, count=count} end
    table.sort(places, function(a,b) return a.name < b.name end)
    return items, places
end

local function RenderSessionCardDetails(self, panel, card, width, headerHeight)
    local detail = card.detail
    if not detail then
        detail = CreateFrame("Frame", nil, card); card.detail = detail
        detail.rule = detail:CreateTexture(nil, "BORDER")
        detail.rule:SetPoint("TOPLEFT", detail, "TOPLEFT", 12, -3); detail.rule:SetHeight(1)
        detail.rule:SetColorTexture(0.48,0.30,0.13,0.18)
        detail.secondary = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail, "TOPLEFT", 12, -12, ""), 13)
        detail.secondary:SetTextColor(unpack(SOFT_INK)); detail.secondary:SetJustifyH("LEFT"); detail.secondary:SetWordWrap(true)
        detail.catches = SessionBreakdownColumn(detail, panel, "Catches", true)
        detail.locations = SessionBreakdownColumn(detail, panel, FF:LocalizedText("journal.locations-heading"), false)
        detail.empty = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail, "TOPLEFT", 12, 0, ""), 13)
        detail.empty:SetTextColor(unpack(SOFT_INK)); detail.empty:SetJustifyH("LEFT"); detail.empty:SetWordWrap(true)
    end
    detail:SetWidth(width); detail:ClearAllPoints(); detail:SetPoint("TOPLEFT", card, "TOPLEFT", 0, -headerHeight)
    detail.rule:SetWidth(width - 24)
    local entry, secondary = card.entry, {}
    if (tonumber(entry.timedCatches) or 0) > 0 and (tonumber(entry.elapsedTotal) or 0) > 0 then
        secondary[#secondary + 1] = FF:LocalizedText("journal.history-average-number",FF:LocalizedNumber(entry.elapsedTotal / entry.timedCatches,1))
    end
    if type(entry.startedAt) == "number" then secondary[#secondary + 1] = FF:LocalizedText("journal.history-started",date("%H:%M",entry.startedAt)) end
    secondary[#secondary + 1] = entry.endedBy == "manual" and FF:LocalizedText("journal.ended-manually") or FF:LocalizedText("journal.saved-logout")
    Readable(detail.secondary, JournalTextSize(panel, 13, 12))
    detail.secondary:SetWidth(width - 24); detail.secondary:SetText(table.concat(secondary, "  •  "))
    local y = 12 + detail.secondary:GetStringHeight() + 14
    local items, places = SessionDetailLists(self, entry)
    local both = #items > 0 and #places > 0
    local available = width - 24
    local catchWidth = both and (available - 18) * 0.6 or available
    local placeWidth = both and (available - 18) * 0.4 or available
    local height = 0
    detail.catches:SetShown(#items > 0); detail.locations:SetShown(#places > 0)
    detail.empty:SetShown(#items == 0 and #places == 0)
    if #items > 0 then
        detail.catches:ClearAllPoints(); detail.catches:SetPoint("TOPLEFT", detail, "TOPLEFT", 12, -y)
        height = RenderSessionBreakdown(detail.catches, panel, items, catchWidth)
    end
    if #places > 0 then
        detail.locations:ClearAllPoints(); detail.locations:SetPoint("TOPLEFT", detail, "TOPLEFT", both and 12 + catchWidth + 18 or 12, -y)
        height = math.max(height, RenderSessionBreakdown(detail.locations, panel, places, placeWidth))
    end
    if #items == 0 and #places == 0 then
        detail.empty:ClearAllPoints(); detail.empty:SetPoint("TOPLEFT", detail, "TOPLEFT", 12, -y)
        detail.empty:SetWidth(available)
        detail.empty:SetText(FF:LocalizedText("journal.breakdown-empty"))
        height = detail.empty:GetStringHeight()
    end
    detail:SetHeight(y + height + 12); detail:Show()
    return detail:GetHeight()
end

function FF:RenderSessionHistory()
    local panel = self.journalPanel
    ClearDynamic(panel); self:StopJournalClock()
    if panel.sessionHistoryButton then panel.sessionHistoryButton:Hide() end
    panel.pageTitle:SetText(FF:LocalizedText("journal.history-title"))
    local owner = UnitGUID and UnitGUID("player")
    local history = owner and self.db.sessionHistory and self.db.sessionHistory[owner] or {}
    panel.historyOwner, panel.historyRecords = owner, history
    panel.historyRevision = self.sessionHistoryRevision
    local visibleHistory = {}
    for _, entry in ipairs(history) do
        if self:SessionHasConfirmedCatches(entry) then visibleHistory[#visibleHistory + 1] = entry end
    end
    SetJournalPageSubtitle(panel, FF:LocalizedText("journal.history-subtitle"))
    local controls = Pooled(panel, "sessionHistoryControls", function()
        local frame = CreateFrame("Frame", nil, panel.content); frame:SetHeight(36)
        frame.current = ModernButton(frame, FF:LocalizedText("journal.current-session"), 126, 26, function() self:ToggleSessionHistory(false) end)
        frame.current:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        frame.label = Readable(PaperText(frame, "GameFontHighlight", "TOPLEFT", frame, "TOPLEFT", 12, -7, ""), 14)
        frame.label:SetTextColor(unpack(SOFT_INK))
        return frame
    end)
    local width = JournalWidth(panel)
    controls:SetHeight(math.max(36,FitTranslatedJournalAction(controls.current,26)+8))
    controls:SetWidth(width); controls:ClearAllPoints(); controls:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, 0)
    controls.label:SetWidth(width - 150)
    controls.label:SetText(FF:LocalizedPlural("journal.saved-count",#visibleHistory,#visibleHistory))
    panel.historyCards = panel.historyCards or {}
    local y = controls:GetHeight()+4
    for index = 1, math.max(1, #visibleHistory) do
        local entry = visibleHistory[#visibleHistory - index + 1]
        local card = panel.historyCards[index]
        if not card then card = SessionHistoryCard(panel); panel.historyCards[index] = card end
        card.entry, card.contentY = entry, y
        card:SetWidth(width); card:ClearAllPoints(); card:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        card.header:SetWidth(width)
        Readable(card.heading, JournalTextSize(panel, 16, 14)); Readable(card.summary, JournalTextSize(panel, 13, 12))
        card.summary:SetWidth(width - 24)
        card.chevron:SetShown(entry ~= nil)
        local expanded = entry and panel.expandedHistoryEntry == entry
        if entry then
            FitJournalText(card.heading, type(entry.endedAt) == "number" and FF:FormatTimestampDisplay(entry.endedAt,"history") or FF:LocalizedText("journal.saved-session"), width - 52)
            local parts = {Plural(entry.casts or 0,"cast"), Plural(entry.catches or 0,"catch")}
            if (tonumber(entry.activeSeconds) or 0) > 0 then parts[#parts + 1] = FF:LocalizedText("journal.history-rod-time",LifetimeDuration(entry.activeSeconds)) end
            if (tonumber(entry.casts) or 0) > 0 and type(entry.successfulCasts) == "number" then
                parts[#parts + 1] = FF:LocalizedText("journal.history-success",Percent(entry.successfulCasts,entry.casts))
            end
            card.summary:SetText(table.concat(parts,"  •  "))
        else
            card.heading:SetWidth(width - 24); card.heading:SetText(FF:LocalizedText("journal.history-empty-title"))
            card.summary:SetText(FF:LocalizedText("journal.history-empty-help"))
        end
        local headerHeight = math.max(64, 10 + card.heading:GetStringHeight() + 6 + card.summary:GetStringHeight() + 12)
        card.header:SetHeight(headerHeight)
        local height = headerHeight
        if expanded then height = height + RenderSessionCardDetails(self,panel,card,width,headerHeight)
        elseif card.detail then card.detail:Hide() end
        SetJournalChevron(card.chevron,expanded)
        card.bg:SetColorTexture(0.55,0.40,0.20,expanded and 0.085 or (index % 2 == 1 and 0.045 or 0.025))
        card:SetHeight(height); AddDynamic(panel,card)
        y = y + height + 6
    end
    SetCatchHeight(panel,y)
    panel.renderedTab, panel.statsRevision = "session", self.statsRevision
end

-- Keep canonical headings/items for disclosure, sources and Back.
local function GearGuideDisplayBlocks(tab)
    local blocks={}
    for _,block in ipairs(tab.blocks or {}) do
        local copy={};for k,v in pairs(block) do copy[k]=v end
        copy.displayHeading=FF:GetGearOverviewText(block,"heading")
        local body,translated=FF:GetGearOverviewText(block,"body")
        if translated then copy.displayBody=body;copy.structuredSkills=true end
        blocks[#blocks+1]=copy
    end
    return blocks
end

function FF:RenderGuide(tab, topInset)
    local panel = self.journalPanel
    if tab.id == "nearby" then return self:RenderNearby() end
    local skills = panel.journalSkills or self:GetJournalSkills()
    local profession = tab.profession or "Fishing"
    local faction = self:GetJournalFaction()
    ClearDynamic(panel)
    local fieldGuide = tab.id ~= nil or tab.skillPalette == "guide"
    panel.pageTitle:SetText(self:GetJournalGuideDisplayText(tab,"title"))
    SetJournalPageSubtitle(panel, self:GetJournalGuideDisplayText(tab,"subtitle"))
    panel.guideCards = panel.guideCards or {}
    local y = topInset or 0
    local blocks = tab.blocks or {}
    if tab.id == "rares" then blocks=RareGuideDisplayBlocks(tab,skills); panel.rareEventGrouped=true end
    if tab.id == "gear" then
        panel.routeFloatingControls=true; panel.routeSelectors={}; panel.routeTrainingSources={}; panel.gearSourceEntries={}
        blocks=GearGuideDisplayBlocks(tab)
    end
    if tab.id == "leveling" then
        panel.routeFloatingControls=true; panel.routeSelectors={}
        -- One source snapshot per visible reflow, shared by Start/Next training.
        panel.routeTrainingSources = {
            Supplier = self:GetFishingPoleSources(faction),
            Apprentice = self:GetFishingTrainingSources("Apprentice", faction),
            Journeyman = self:GetFishingTrainingSources("Journeyman", faction),
            Expert = self:GetOrderedGuideMapPoints({{kind="map", name="Old Man Heming",
                sourceKind="Book seller",
                location="Happy Bobber, lower Booty Bay", label="Old Man Heming, Booty Bay",
                mapID=1434, x=.274, y=.77}}, true),
            Artisan = self:GetOrderedGuideMapPoints({{kind="map", name="Nat Pagle",
                sourceKind="Quest giver",
                location="Island southwest of Theramore, Dustwallow Marsh", label="Nat Pagle, Dustwallow Marsh",
                mapID=1445, x=.59, y=.60}}, true),
        }
        blocks = {}
        local stages, stage = {}, nil
        for routeIndex, block in ipairs(tab.blocks or {}) do
            local copy = {}
            for key, value in pairs(block) do copy[key] = value end
            copy.routePage = true
            copy.displayHeading = self:GetFishingReferenceText("route", block, "heading", faction, skills)
            if block.heading:match("^%d+–%d+") then
                copy.routeStage = true
                stage = {card=copy, camps={}, training={}}
                stages[#stages+1] = stage
                copy.summary = self:GetFishingReferenceText("route", block, "summary", faction, skills)
            else
                copy.routeCallout = true
                if routeIndex == 2 then copy.trainingRank = "Journeyman" end
                if routeIndex == 4 then copy.trainingRank = "Expert" end
                if routeIndex == 6 then copy.trainingRank = "Artisan" end
                stage.training[#stage.training+1] = copy
            end
            for _, milestone in ipairs(self.masterChefCampMilestones or {}) do
                if milestone.after == routeIndex and self.db and self.db.campMilestones ~= false then
                    stage.camps[#stage.camps+1] = {heading=milestone.heading, body=milestone.body,
                        displayHeading=self:GetFishingReferenceText("milestone",milestone,"heading",faction, skills),
                        displayBody=self:GetFishingReferenceText("milestone",milestone,"body",faction, skills),
                        campMilestone=true, routePage=true, routeCallout=true,
                        campItemID=milestone.after == 1 and 279967 or nil}
                end
            end
        end
        for _, group in ipairs(stages) do
            blocks[#blocks+1] = group.card
            for _, callout in ipairs(group.camps) do blocks[#blocks+1] = callout end
            for _, callout in ipairs(group.training) do blocks[#blocks+1] = callout end
        end
    end
    if panel.campMilestonesButton then
        panel.campMilestonesButton:SetShown(tab.id == "leveling")
        panel.campMilestonesButton.label:SetText(self:LocalizedText(
            (self.db and self.db.campMilestones == false) and "fishing.milestones-off" or "fishing.milestones-on"))
    end
    panel.expandedGuides = panel.expandedGuides or {}
    local stageCard, stageKey, stageY
    local function FinishStage()
        if stageCard and stageCard.group then stageCard.group:SetHeight(math.max(stageCard:GetHeight(),y-stageY-(tab.id == "leveling" and 6 or 9))) end
    end
    for index, block in ipairs(blocks) do
        local card = panel.guideCards[index]
        if not card then card = GuideCard(panel, 13, -10, -33, 500); panel.guideCards[index] = card end
        local isStage = tab.id == "leveling" and block.heading:match("^%d+–%d+") ~= nil
        if isStage then FinishStage(); stageCard,stageKey,stageY=card,"leveling:"..block.heading,y end
        local nested = tab.id == "leveling" and stageCard ~= nil and not isStage
        card.parentGuide = nested and stageKey or nil
        card.routeCallout = block.routeCallout
        card.eventGuide=block.eventGuide; card.guideHeadings=block.guideHeadings
        self:StyleJournalEventFrame(card.border, block.eventGuide == true)
        if block.eventGuide and index == 1 then y = y + 6 end
        local cardWidth = JournalWidth(panel) - (self.journalTab == "chef" and 18 or nested and block.campMilestone and 24 or 0)
        card:SetWidth(cardWidth)
        card.heading:SetWidth(math.max(180, cardWidth - 48))
        card.body:SetWidth(math.max(180, cardWidth - 30))
        card.summary:SetWidth(math.max(180, cardWidth - 30))
        local textWidth = block.cookingInstructions and cardWidth or nil
        Readable(card.heading, JournalTextSize(panel, nested and 15 or 18, nested and 13 or 16, textWidth))
        Readable(card.body, JournalTextSize(panel, 14, 12, textWidth))
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", panel.content, "TOPLEFT", self.journalTab == "chef" and 9 or self.journalTab == "rares" and 5 or nested and block.campMilestone and 12 or 0, -y)
        card.milestoneBg:SetShown(block.eventGuide == true or not block.routePage and (block.campMilestone == true or block.routeCallout == true))
        card.milestoneRule:SetShown(not block.routePage and block.campMilestone == true)
        if block.campMilestone and block.routePage and not card.campBorder then card.campBorder=self:CreateJournalFrame(card,false,6) end
        if card.campBorder then card.campBorder:SetShown(block.campMilestone == true and block.routePage == true) end
        card.separator:SetShown(not (block.campMilestone and block.routePage))
        if block.routeCallout and not block.campMilestone and not card.routeSeparator then
            card.routeSeparator=card:CreateTexture(nil,"BORDER"); card.routeSeparator:SetHeight(1)
            card.routeSeparator:SetPoint("TOPLEFT",card,"TOPLEFT",13,-2); card.routeSeparator:SetPoint("TOPRIGHT",card,"TOPRIGHT",-13,-2)
            card.routeSeparator:SetColorTexture(.48,.30,.13,.22)
        end
        if card.routeSeparator then card.routeSeparator:SetShown(block.routePage == true and block.routeCallout == true and not block.campMilestone) end
        local displayHeading = block.displayHeading or block.heading
        local useRouteColors = block.routePage and not block.cookingInstructions
        local heading = block.linked and displayHeading or LinkText(card,displayHeading)
        local compactHeading = self:GetFishingTrainingCallout(block, skills)
        card.blockKey = (tab.id or "cooking") .. ":" .. block.heading
        if compactHeading then
            heading = LinkText(card,compactHeading):gsub("{trainer}",function()
                return RouteSourceLink(panel,card.blockKey,block.trainingRank,1,true)
            end)
        end
        card.heading:SetText(useRouteColors and ColorRouteSkills(skills,heading,profession,true,true) or ColorGuideSkills(skills,heading,profession,true,fieldGuide,block.structuredSkills))
        local linkedBody = block.linked and block.body or LinkText(card,block.displayBody or JournalFactionText(block.body,faction))
        card.body:SetText(useRouteColors and ColorRouteSkills(skills,linkedBody,profession,false,true) or ColorGuideSkills(skills,linkedBody,profession,false,fieldGuide,block.structuredSkills))
        card.blockKey = (tab.id or "cooking") .. ":" .. block.heading
        if block.items and panel.expandedGuides[card.blockKey] == nil then panel.expandedGuides[card.blockKey]=true end
        if isStage and index == 1 and panel.expandedGuides[card.blockKey] == nil then panel.expandedGuides[card.blockKey]=true end
        card.linkHovered = nil
        card.contentY = y - (block.eventGuide and 6 or 0)
        card.expanded = panel.expandedGuides[card.blockKey] == true
            or nested and panel.expandedGuides[card.blockKey] == nil
        if block.routeCallout then card.expanded = true end
        local source = block.displayBody or JournalFactionText(block.body, faction) or ""
        local summary = block.summary or source:match("^[^\n]+") or source
        if #summary > 155 then summary = summary:match("^.-%.") or summary end
        local linkedSummary = block.linked and summary or LinkText(card,summary)
        if block.eventGuide then linkedSummary=EventScheduleLink(linkedSummary,block.structuredSkills) end
        card.summary:SetText(useRouteColors and ColorRouteSkills(skills,linkedSummary,profession,false,true) or ColorGuideSkills(skills,linkedSummary,profession,false,fieldGuide,block.structuredSkills))
        Readable(card.summary, JournalTextSize(panel,13,12,textWidth))
        local headingHeight=card.heading:GetStringHeight()
        if block.routePage then headingHeight=self:LayoutJournalRouteInline(card,card.heading,card.heading:GetText(),card.heading:GetWidth(),true,EnableGuideLinks,ParchmentSlices)
        elseif card.routeInline then card.routeInline:Hide(); card.heading:Show() end
        local bodyTop = (block.routePage and 13 or 16) + headingHeight
        card.summary:ClearAllPoints(); card.summary:SetPoint("TOPLEFT",card,"TOPLEFT",13,-bodyTop)
        card.body:ClearAllPoints(); card.body:SetPoint("TOPLEFT",card,"TOPLEFT",13,-bodyTop)
        card.summary:SetShown(not card.expanded)
        card.mapTarget=nil
        local mapLink=card.heading:GetText():match("|H(ffguide:%d+)|h")
        local target=mapLink and self:GuideLinkTarget(mapLink)
        if target and target.kind == "map" and type(target.mapID)=="number"
            and type(target.x)=="number" and type(target.y)=="number"
            and target.x>=0 and target.x<=1 and target.y>=0 and target.y<=1 then card.mapTarget=target end
        card.map:SetShown(card.mapTarget ~= nil)
        card.categoryIcon:SetShown(card.mapTarget ~= nil)
        card.heading:ClearAllPoints(); card.heading:SetPoint("TOPLEFT",card,"TOPLEFT",card.mapTarget and 44 or 13,-10)
        if card.mapTarget then card.heading:SetWidth(math.max(120,cardWidth-110)) end
        SetJournalChevron(card.chevron,card.expanded)
        card.chevron:SetShown(not block.routeCallout)
        if block.routePage or block.eventGuide then
            card.chevron:ClearAllPoints()
            card.chevron:SetPoint("RIGHT",card,"TOPRIGHT",-12,-10-headingHeight/2)
        else
            card.chevron:ClearAllPoints(); card.chevron:SetPoint("TOPRIGHT",card,"TOPRIGHT",-12,-18)
        end
        local detailHeight=LayoutGuideSections(card,panel,block,bodyTop,cardWidth-30)
        local height = math.max(block.routePage and 44 or 64, bodyTop + detailHeight + (block.routePage and 10 or 15))
        card:SetHeight(height)
        self:StyleJournalPanelBorder(card.border,tab.id == "rares" or self.journalTab == "chef",cardWidth,height)
        if isStage then
            if not card.group then
                card.group=CreateFrame("Frame",nil,card); card.group:EnableMouse(false)
                card.group:SetPoint("TOPLEFT",card,"TOPLEFT",0,0)
                card.group.border=self:CreateJournalFrame(card.group)
            end
            card.group:SetWidth(cardWidth); card.group:Show()
        elseif card.group then card.group:Hide() end
        local sectionHeading=tab.id=="nearby" and (index==1 or index==#blocks)
        card.border:SetShown(not isStage and not nested and not sectionHeading)
        local visible = not nested or stageCard.expanded
        if visible then AddDynamic(panel, card); y = y + height + (block.eventGuide and 16 or block.routePage and 6 or 9) else card:Hide() end
    end
    FinishStage()
    panel.content:SetHeight(math.max(1, y))
end

function FF:OpenNextFishingEvent()
    local panel=self.journalPanel
    if not panel then return end
    self:RememberJournalPage()
    if self.DismissJournalSearch then self:DismissJournalSearch(false) end
    panel.expandedEvent=nil
    for _,event in ipairs(self:GetUpcomingFishingEvents()) do
        if event.id:match("^stranglethorn%-") then panel.expandedEvent=event.id; break end
    end
    self:SelectJournalTab("events")
    panel.scroll:SetVerticalScroll(0)
end

function FF:ExpandJournalGuideHeading(tabID, heading)
    local panel=self.journalPanel
    if not panel then return end
    panel.expandedGuides=panel.expandedGuides or {}
    if tabID=="rares" and RARE_EVENT_HEADINGS[heading] then heading=RARE_EVENT_TITLE end
    panel.expandedGuides[(tabID=="chef" and "cooking" or tabID)..":"..heading]=true
    if tabID ~= "leveling" then return end
    local stage, route
    for _,tab in ipairs(self.guideTabs or {}) do if tab.id==tabID then route=tab.blocks end end
    for index,block in ipairs(route or {}) do
        if block.heading:match("^%d+–%d+") then stage=block.heading end
        if block.heading==heading then break end
        for _,milestone in ipairs(self.masterChefCampMilestones or {}) do
            if milestone.after==index and milestone.heading==heading then
                panel.expandedGuides["leveling:"..stage]=true; return
            end
        end
    end
    if stage then panel.expandedGuides["leveling:"..stage]=true end
end

local function RememberJournalPage(panel)
    panel.backHistory = panel.backHistory or {}
    panel.backHistory[#panel.backHistory + 1] = {
        tab = panel.selectedTab or FF.journalTab or "catch",
        scroll = panel.scroll:GetVerticalScroll(),
        chefView = panel.chefView,
        expandedMeal = panel.expandedMeal,
        expandedRecipeVendorMeal = panel.expandedRecipeVendorMeal,
        showAllCatches = panel.showAllCatches,
        sessionHistoryShown = panel.sessionHistoryShown,
        expandedHistoryEntry = panel.expandedHistoryEntry,
        expandedCamp = panel.expandedCamp,
        expandedCatches = FF:CopyJournalViewState(panel.expandedCatches),
        routeSourceSelections = FF:CopyJournalViewState(panel.routeSourceSelections),
        nearbySelectedZone = panel.nearbySelectedZone,
        nearbyFilters = FF:CopyJournalViewState(panel.nearbyFilters),
        expandedAchievements = FF:CopyJournalViewState(panel.expandedAchievements),
        expandedGuides = FF:CopyJournalViewState(panel.expandedGuides),
        expandedEvents = FF:CopyJournalViewState(panel.expandedEvents),
        focusedAchievement = panel.focusedAchievement,
        expandedEvent = panel.expandedEvent,
        searchState = FF.GetJournalSearchState and FF:GetJournalSearchState(),
    }
    UpdateJournalBackButton(panel)
end

function FF:RememberJournalPage() if self.journalPanel then RememberJournalPage(self.journalPanel) end end

function FF:JournalBack()
    local panel = self.journalPanel
    local history = panel and panel.backHistory
    if not history or #history == 0 then return end
    local previous = table.remove(history)
    panel.chefView = previous.chefView
    panel.expandedMeal = previous.expandedMeal
    panel.expandedRecipeVendorMeal = previous.expandedRecipeVendorMeal
    panel.showAllCatches = previous.showAllCatches
    panel.sessionHistoryShown = previous.sessionHistoryShown
    panel.expandedHistoryEntry = previous.expandedHistoryEntry
    panel.expandedCamp = previous.expandedCamp
    panel.expandedCatches = previous.expandedCatches
    panel.routeSourceSelections = previous.routeSourceSelections
    panel.nearbySelectedZone = previous.nearbySelectedZone
    panel.nearbyFilters = previous.nearbyFilters
    panel.expandedAchievements = previous.expandedAchievements
    panel.expandedGuides = previous.expandedGuides
    panel.expandedEvents = previous.expandedEvents
    panel.focusedAchievement = previous.focusedAchievement
    panel.expandedEvent = previous.expandedEvent
    self:SelectJournalTab(previous.tab)
    local scroll = math.min(previous.scroll or 0, panel.scroll:GetVerticalScrollRange())
    panel.scroll:SetVerticalScroll(scroll)
    panel.tabScrollOffsets[previous.tab] = scroll
    if self.RestoreJournalSearchState then self:RestoreJournalSearchState(previous.searchState) end
    UpdateJournalBackButton(panel)
end

function FF:ExpandJournalGearReference(heading,name,key)
    local panel=self.journalPanel
    for _,tab in ipairs(self.guideTabs) do if tab.id=="gear" then
        for _,block in ipairs(tab.blocks) do if block.heading==heading then
            for _,entry in ipairs(self:GetJournalGearReferences(block,self:GetJournalFaction())) do
                if entry.key==key or name and (entry.name==name or entry.quest==name) then
                    panel.expandedGuides["gear:"..heading]=true
                    panel.expandedGuides["gear:item:"..entry.key]=true
                    return entry.key
                end
            end
        end end
    end end
end

function FF:OpenJournalGuideUse(target)
    local panel=self.journalPanel
    if not panel then return end
    RememberJournalPage(panel)
    self:ExpandJournalGuideHeading(target.tab,target.heading)
    local itemKey=target.tab=="gear" and self:ExpandJournalGearReference(target.heading,target.label)
    self:SelectJournalTab(target.tab)
    if itemKey then
        for _,card in ipairs(panel.guideCards or {}) do for _,row in ipairs(card.gearItems or {}) do
            if row:IsShown() and row.reference.key==itemKey then
                panel.scroll:SetVerticalScroll(math.min(row.contentY,panel.scroll:GetVerticalScrollRange())); return
            end
        end end
    end
    for _,card in ipairs(panel.guideCards or {}) do if card.blockKey==target.tab..":"..target.heading and card:IsShown() then
        panel.scroll:SetVerticalScroll(math.min(card.contentY or 0,panel.scroll:GetVerticalScrollRange())); break
    end end
end

function FF:OpenGuideCatch(itemID)
    local panel = self.journalPanel
    if not panel then return end
    RememberJournalPage(panel)
    local recorded = self.db.journal[itemID] or self.db.journal[tostring(itemID)]
    if not (recorded and recorded.count > 0) then panel.showAllCatches = true end
    panel.expandedCatches = panel.expandedCatches or {}
    panel.expandedCatches[itemID] = true
    self:SelectJournalTab("catch")
    for _, row in ipairs(panel.catchRows or {}) do
        if row.itemID == itemID and row:IsShown() then
            panel.scroll:SetVerticalScroll(math.min(row.contentY or 0, panel.scroll:GetVerticalScrollRange()))
            break
        end
    end
end

function FF:OpenGuideMeal(itemID)
    local panel = self.journalPanel
    if not panel then return end
    RememberJournalPage(panel)
    panel.chefView, panel.expandedMeal, panel.expandedRecipeVendorMeal = "meals", itemID, nil
    self:PrepareMasterChefJournalView("meals")
    self:SelectJournalTab("chef")
    for _, row in ipairs(panel.chefRows or {}) do
        if row.meal and row.meal.id == itemID and row:IsShown() then
            panel.scroll:SetVerticalScroll(math.min(row.contentY or 0, panel.scroll:GetVerticalScrollRange()))
            break
        end
    end
end

function FF:OpenGuideCamp(itemID, informationOnly)
    local panel = self.journalPanel
    if not panel then return end
    RememberJournalPage(panel)
    panel.chefView = "campfire"
    if informationOnly then panel.expandedCamp = itemID
    else self:PrepareMasterChefJournalView("campfire") end
    self:SelectJournalTab("chef")
    for _, row in pairs(panel.campRows or {}) do
        if row.camp and row.camp.id == itemID and row:IsShown() then
            panel.scroll:SetVerticalScroll(math.min(row.contentY or 0,
                panel.scroll:GetVerticalScrollRange()))
            break
        end
    end
end

local function QueuePreparationCanUseClick(kind)
    if InCombatLockdown and InCombatLockdown() then return false end
    if kind == "cooking" and FF.masterChefOwnsCampSession
        and (FF.masterChefCampCrafting or FF.masterChefCampPreparing
            or (FF.masterChefCampCraftQueue or {})[1]) then return false end
    if kind == "camp" and FF.masterChefOwnsCookingSession
        and (FF.masterChefCookingActive or FF.masterChefCookingPending
            or FF.masterChefCookingQuickPending
            or (FF.masterChefCookingQueue or {})[1]) then return false end
    if not FF.masterChefOwnsCookingSession and not FF.masterChefOwnsCampSession then
        local frame = _G.ProfessionsFrame
        if not (frame and frame.IsShown and frame:IsShown()) then frame = _G.TradeSkillFrame end
        if frame and frame.IsShown and frame:IsShown() then return false end
    end
    return true
end

local CHEF_DEFAULT_STATUS_KEYS = { campfire = "chef.ui.camp-tools", meals = "chef.ui.cooking-recipes",
    guide = "chef.ui.cooking-guide" }

local function ChefDefaultStatus(view, font, width, size, profession)
    if view == "guide" or not profession then return FF:LocalizedText(CHEF_DEFAULT_STATUS_KEYS[view]) end
    local prepared = FF:LocalizedText("chef.ui.prepared",profession)
    local short = FF:LocalizedText("chef.ui.ready",profession)
    local choices = { FF:LocalizedText(view == "campfire" and "chef.ui.camp-prepared" or "chef.ui.recipes-prepared",profession),
        FF:LocalizedText(view == "campfire" and "chef.ui.camp-short-prepared" or "chef.ui.recipes-short-prepared",profession), prepared, short }
    for _, label in ipairs(choices) do
        font:SetWidth(1000)
        font:SetText(label)
        local measured = font.GetStringWidth and font:GetStringWidth()
            or (#label - 2) * size * 0.53
        font:SetWidth(width)
        if measured <= width then return label end
    end
    return short
end

local function CompactChefStatus(view, raw)
    local message = raw:lower()
    if message:find("not ready", 1, true) then return "Not ready", true, "journal.chrome.not-ready" end
    if message:find("moving", 1, true) then return "Stop moving", true, "chef.ui.stop-moving" end
    if view == "campfire" then
        if message:find("not learned", 1, true) then return "Recipe unknown", true, "chef.ui.recipe-unknown" end
        if message:find("need ", 1, true) or message:find("materials committed", 1, true)
            then return "Need materials", true, "chef.ui.materials-status" end
        if message:find("combat", 1, true) then return "In combat", true, "chef.ui.in-combat" end
        if message:find("stopped", 1, true) or message:find("changed", 1, true)
            then return "Craft paused", true, "chef.ui.craft-paused" end
        if message:find("could not", 1, true) or message:find("unavailable", 1, true)
            or message:find("did not", 1, true) then return "Can't craft", true, "chef.ui.cant-craft" end
        if message:find("crafted", 1, true) then return "Craft complete", false, "chef.ui.craft-complete" end
        if message:find("crafting", 1, true) then return "Crafting", false, "chef.ui.crafting" end
        if message:find("ready", 1, true) then return "Ready to craft", false, "chef.ui.ready-craft" end
        if message:find("prepar", 1, true) then return "Preparing", false, "chef.ui.preparing" end
        if message:find("progress", 1, true) or message:find("finish", 1, true)
            then return "Craft busy", false, "chef.ui.craft-busy" end
        return "Can't craft", true, "chef.ui.cant-craft"
    end
    if message:find("fire", 1, true) then return "Need cooking fire", true, "chef.ui.need-fire" end
    if message:find("ingredient", 1, true) or message:find("committed", 1, true)
        then return "Need ingredients", true, "chef.ui.ingredients-status" end
    if message:find("combat", 1, true) then return "In combat", true, "chef.ui.in-combat" end
    if message:find("stopped", 1, true) or message:find("changed", 1, true)
        or message:find("confirmed", 1, true) then return "Cook paused", true, "chef.ui.cook-paused" end
    if message:find("could not", 1, true) or message:find("unavailable", 1, true)
        or message:find("did not", 1, true) then return "Can't cook", true, "chef.ui.cant-cook" end
    if message:find("ready", 1, true) then return "Ready to cook", false, "chef.ui.ready-cook" end
    if message:find("cooked", 1, true) then return "Cook complete", false, "chef.ui.cook-complete" end
    if message:find("cooking ", 1, true) then return "Cooking", false, "chef.ui.cooking" end
    if message:find("prepar", 1, true) then return "Preparing", false, "chef.ui.preparing" end
    return "Cook paused", true, "chef.ui.cook-paused"
end

local function ApplyChefStatus(chef, view)
    local panel = chef.journalPanel
    if not panel then return end
    local state = chef.masterChefStatus and chef.masterChefStatus[view]
    if state and GetTime and GetTime() >= state.untilTime then state = nil end
    local width = panel.pageSubtitle:GetWidth()
    local size = JournalTextSize(panel, 14, 12)
    Readable(panel.pageSubtitle, size)
    if panel.pageSubtitle.SetWordWrap then panel.pageSubtitle:SetWordWrap(false) end
    local profession = chef.GetMasterChefPreparedProfession
        and chef:GetMasterChefPreparedProfession()
    local preparedMessage = state and not state.error and state.prepared
    if preparedMessage and not profession then state = nil end
    local label = state and not preparedMessage and (state.messageKey and chef:LocalizedText(state.messageKey) or state.text)
        or ChefDefaultStatus(view, panel.pageSubtitle, width, size, profession)
    FitJournalText(panel.pageSubtitle, label, width)
    panel.pageSubtitle:SetTextColor(unpack(state and state.error and NEED_RED or SOFT_INK))
end

function FF:ShowMasterChefStatus(view, label, error, priority, messageKey, prepared)
    self.masterChefStatus = self.masterChefStatus or {}
    local current = self.masterChefStatus[view]
    if current and GetTime and GetTime() < current.untilTime
        and (current.priority or 0) > (priority or 1) then return end
    self.masterChefStatusToken = (self.masterChefStatusToken or 0) + 1
    local token = self.masterChefStatusToken
    self.masterChefStatus[view] = { text = label, messageKey = messageKey, prepared = prepared == true, error = error, priority = priority or 1,
        untilTime = (GetTime and GetTime() or 0) + 3, token = token }
    if C_Timer and C_Timer.After then
        C_Timer.After(3, function()
            local state = self.masterChefStatus and self.masterChefStatus[view]
            if not state or state.token ~= token then return end
            self.masterChefStatus[view] = nil
            local panel = self.journalPanel
            if panel and panel:IsShown() and self.journalTab == "chef"
                and panel.chefView == view then ApplyChefStatus(self, view) end
        end)
    end
end

function FF:ClearMasterChefStatus(view)
    if self.masterChefStatus then self.masterChefStatus[view] = nil end
    if self.masterChefStatusRaw then self.masterChefStatusRaw[view] = nil end
end

function FF:RenderMasterChefStatus(view, raw)
    self.masterChefStatusRaw = self.masterChefStatusRaw or {}
    if self.masterChefStatusRaw[view] ~= raw then
        self.masterChefStatusRaw[view] = raw
        if raw then
            local label, error, messageKey = CompactChefStatus(view, raw)
            self:ShowMasterChefStatus(view, label, error, 1, messageKey)
        end
    end
    ApplyChefStatus(self, view)
end

local function ShowChefMaterialsTooltip(owner, heading, ingredients, counts, toolName, toolCount,
    reserved)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(heading, unpack(NEED_RED))
    for index, ingredient in ipairs(ingredients or {}) do
        local name = FF:GetJournalItemDisplayName(ingredient.id,ingredient.name)
            or (C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(ingredient.id))
            or (GetItemInfo and GetItemInfo(ingredient.id))
            or FF:LocalizedText("journal.chrome.item-hash",ingredient.id)
        GameTooltip:AddLine(name .. "  " .. tostring(counts and counts[index] or 0)
            .. "/" .. ingredient.quantity, 0.83, 0.72, 0.52)
    end
    if toolName then
        GameTooltip:AddLine(toolName .. "  " .. tostring(toolCount or 0) .. "/1",
            0.83, 0.72, 0.52)
    end
    if reserved then GameTooltip:AddLine(FF:LocalizedText("chef.ui.reserved"), 0.83, 0.72, 0.52) end
    GameTooltip:Show()
end
FF.ShowMasterChefMaterialsTooltip = ShowChefMaterialsTooltip

local function ShowChefCampTooltip(button, camp)
    FF:BeginJournalItemTooltip(button, camp.id, camp.name)
    if camp.benefit then GameTooltip:AddLine(FF:GetMasterChefReferenceText("camp",camp,"benefit"), 0.83, 0.72, 0.52, true) end
    if camp.source then GameTooltip:AddLine(FF:LocalizeReferenceZones(FF:GetMasterChefReferenceText("camp",camp,"source")), 0.72, 0.66, 0.55, true) end
    FF:FinishJournalItemTooltip(button)
end

local function ChefCampPlaceButton(row, camp, label, width, right)
    -- The secure item action runs on the player's mouse-up click; the Journal
    -- hides only after that action, regardless of ActionButtonUseKeyDown.
    local place = CreateFrame("Button", nil, row, "SecureActionButtonTemplate")
    place:SetSize(width, 25)
    place:SetPoint("RIGHT", row, "RIGHT", right, 0)
    place:RegisterForClicks("AnyUp")
    if not (InCombatLockdown and InCombatLockdown()) then
        place:SetAttribute("useOnKeyDown", false)
        place:SetAttribute("type", "item")
        place:SetAttribute("type1", "item")
        place:SetAttribute("item", "item:" .. camp.id)
        place:SetAttribute("item1", "item:" .. camp.id)
        row.placeReady = true
    end
    Surface(place, 0.54, 0.33, 0.13, 0.32)
    Edge(place, { 0.56, 0.35, 0.15 })
    place.label = Readable(PaperText(place, "GameFontNormal", "CENTER",
        place, "CENTER", 0, 0, label), 13)
    place.label:SetTextColor(unpack(INK))
    place:HookScript("PreClick", function(_, button)
        local panel = FF.journalPanel
        if button == "LeftButton" and panel and panel:IsShown() then
            FF:ArmMasterChefCampPlacement(camp.id, panel.chefView or "campfire")
        end
    end)
    place:HookScript("PostClick", function(_, button, down)
        if button ~= "LeftButton" or down then return end
        FF:BeginMasterChefCampPlacement(camp.id)
    end)
    place:SetScript("OnEnter", function(button) ShowChefCampTooltip(button, camp) end)
    place:SetScript("OnLeave", function(button) FF:HideJournalItemTooltip(button) end)
    return place
end

local function ChefGrillingCampfireRow(panel, camp)
    local row = CreateFrame("Frame", nil, panel.content)
    row.pooled = true
    row.camp = camp
    row:SetSize(548, 48)
    row.bg = Surface(row, 0.67, 0.51, 0.30, 0.18)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(36, 36)
    row.icon:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RoundIcon(row.icon)
    FF:FrameJournalRoundIcon(row.icon,36)
    row.name = Readable(PaperText(row, "GameFontNormal", "TOPLEFT", row,
        "TOPLEFT", 48, -5, "Basic Campfire"), 15)
    row.name:SetTextColor(unpack(INK))
    row.skill = Readable(PaperText(row, "GameFontHighlight", "TOPLEFT", row,
        "TOPLEFT", 48, -27, FF:LocalizedText("journal.chrome.cooking-fire")), 13)
    row.skill:SetTextColor(unpack(SOFT_INK))
    row.place = ChefCampPlaceButton(row, camp, FF:LocalizedText("chef.ui.place-campfire"), 119, -9)
    row.craft = CreateFrame("Button", nil, row)
    row.craft:SetSize(119, 25)
    row.craft:SetPoint("RIGHT", row, "RIGHT", -9, 0)
    row.craft:RegisterForClicks("LeftButtonUp")
    Surface(row.craft, 0.54, 0.33, 0.13, 0.32)
    Edge(row.craft, { 0.56, 0.35, 0.15 })
    row.craft.label = Readable(PaperText(row.craft, "GameFontNormal", "CENTER",
        row.craft, "CENTER", 0, 0, FF:LocalizedText("chef.ui.craft")), 13)
    row.craft.label:SetTextColor(unpack(INK))
    row.craft:SetScript("OnClick", function()
        FF:ClearMasterChefStatus("meals")
        local scroll = panel.scroll:GetVerticalScroll()
        local started = FF:CraftMasterChefCamp(camp.id, 1)
        if started then
            local label = FF.masterChefCampCrafting == camp.id and "Crafting"
                or FF.masterChefCampPreparing == camp.id and "Preparing Cooking"
                or "Cooking prepared"
            local messageKey = FF.masterChefCampCrafting == camp.id and "chef.ui.crafting"
                or FF.masterChefCampPreparing == camp.id and "chef.ui.preparing-cooking" or nil
            FF:ShowMasterChefStatus("meals", label, false, 2, messageKey, FF.masterChefCampCrafting ~= camp.id and FF.masterChefCampPreparing ~= camp.id)
        else
            local label, error, messageKey = CompactChefStatus("campfire",
                FF.masterChefCampMessage or "Could not craft")
            FF:ShowMasterChefStatus("meals", label, error, 2, messageKey)
        end
        FF:RenderMasterChefMeals()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    row.craft:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("chef.ui.craft-one"), 1, 0.82, 0.45)
        GameTooltip:Show()
    end)
    row.craft:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.craftHint = CreateFrame("Frame", nil, row)
    row.craftHint:SetSize(119, 25)
    row.craftHint:SetPoint("RIGHT", row, "RIGHT", -9, 0)
    row.craftHint:EnableMouse(true)
    row.craftHint.label = Readable(PaperText(row.craftHint, "GameFontNormal",
        "CENTER", row.craftHint, "CENTER", 0, 0, FF:LocalizedText("chef.ui.need-materials")), 13)
    row.craftHint.label:SetTextColor(unpack(NEED_RED))
    row.craftHint:SetScript("OnEnter", function()
        local status = FF:GetMasterChefCampStatus(camp.id)
        ShowChefMaterialsTooltip(row.craftHint, FF:LocalizedText("chef.ui.need-materials"),
            status and status.ingredients, status and status.counts,
            camp.toolID and FF:GetJournalItemDisplayName(camp.toolID,camp.toolName or FF:LocalizedText("journal.chrome.tool")), status and status.toolCount,
            status and status.crafts and status.crafts > 0)
    end)
    row.craftHint:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.rule = row:CreateTexture(nil, "ARTWORK")
    row.rule:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 6, -7)
    row.rule:SetPoint("TOPRIGHT", row, "BOTTOMRIGHT", -6, -7)
    row.rule:SetHeight(1)
    row.rule:SetColorTexture(0.39, 0.23, 0.09, 0.38)
    return row
end

local function ChefQuantityControls(row, panel, kind, x, y, width, amountX, amountY)
    row.amountSlider = CreateFrame("Slider", nil, row)
    row.amountSlider:SetPoint("TOPLEFT", row, "TOPLEFT", x, y)
    row.amountSlider:SetSize(width, 18)
    row.amountSlider:SetOrientation("HORIZONTAL")
    row.amountSlider:SetMinMaxValues(1, 1)
    row.amountSlider:SetValueStep(1)
    if row.amountSlider.SetObeyStepOnDrag then row.amountSlider:SetObeyStepOnDrag(true) end
    local track = row.amountSlider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", row.amountSlider, "LEFT", 0, 0)
    track:SetPoint("RIGHT", row.amountSlider, "RIGHT", 0, 0)
    track:SetHeight(4); track:SetColorTexture(0.44, 0.29, 0.14, 0.78)
    row.amountSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    row.amountSlider:GetThumbTexture():SetVertexColor(0.72, 0.43, 0.16)
    row.amountSlider:GetThumbTexture():SetSize(16, 20)
    row.amount = Readable(PaperText(row, "GameFontNormal", "TOPLEFT", row,
        "TOPLEFT", amountX, amountY, "1"), 14)
    row.amount:SetWidth(28); row.amount:SetJustifyH("CENTER")
    row.amount:SetTextColor(unpack(INK))
    row.amountSlider:SetScript("OnValueChanged", function(_, value)
        local quantity = math.floor(value + 0.5)
        row.amount:SetText(tostring(quantity))
        local item = kind == "camp" and row.camp or row.meal
        if item then
            local key = kind == "camp" and "chefCampQuantities" or "chefQuantities"
            panel[key] = panel[key] or {}
            panel[key][item.id] = quantity
        end
    end)
end

local function RefreshChefQuantityControls(row, panel, kind, itemID, available)
    local key = kind == "camp" and "chefCampQuantities" or "chefQuantities"
    panel[key] = panel[key] or {}
    local selected = panel[key][itemID]
    local quantity = math.max(1, math.min(selected or available,
        math.max(1, available)))
    row.amountSlider:SetMinMaxValues(available == 1 and 0 or 1,
        math.max(1, available))
    row.amountSlider:SetValue(quantity)
    row.amountSlider:EnableMouse(available > 1)
    row.amount:SetText(tostring(quantity))
    -- Publish even if SetValue did not emit a change for a reused row. A
    -- hidden, unavailable recipe must not acquire an initial selection of 1.
    panel[key][itemID] = (selected ~= nil or available > 0) and quantity or nil
    return quantity
end

-- Shared full/Mini controls keep their hit targets and action handlers. Only
-- translated presentation grows; never change protected placement in combat.
local function FitChefAction(button)
    if not button or not button.label then return 0 end
    button.chefMinimumHeight = button.chefMinimumHeight or button:GetHeight()
    local label = button.label
    label:SetWidth(math.max(1,button:GetWidth()-10)); label:SetWordWrap(true); label:SetHeight(0)
    local height = math.max(button.chefMinimumHeight,math.ceil(label:GetStringHeight())+6)
    label:SetHeight(height-4); button:SetHeight(height)
    return height
end

local function FitTranslatedChefRow(row, kind)
    if FF:GetResolvedLocale()=="enUS" or (InCombatLockdown and InCombatLockdown()) then return end
    local actionHeight = math.max(FitChefAction(row.cook),FitChefAction(row.craft),
        FitChefAction(row.place),FitChefAction(row.craftHint),FitChefAction(row.missingIngredientsHint))
    row:SetHeight(math.max(51,actionHeight+(kind=="camp" and 30 or 12)))
end

local function FitTranslatedChefSkill(panel,row,kind)
    if FF:GetResolvedLocale()=="enUS" or InCombatLockdown and InCombatLockdown() then return end
    row.skill:SetWordWrap(true)
    local top=JournalStage(panel)=="minimum" and 8 or 27
    row.skill:ClearAllPoints();row.skill:SetPoint("TOPLEFT",row,"TOPLEFT",kind=="meal" and 54 or 48,-top)
    row:SetHeight(math.max(row:GetHeight(),top+math.ceil(row.skill:GetStringHeight())+7))
end

local function LayoutChefRow(panel, row, kind, name)
    local width, stage = JournalWidth(panel), JournalStage(panel)
    row:SetWidth(width)
    if kind == "basic" then
        Readable(row.name, JournalTextSize(panel, 15, 13))
        FitJournalText(row.name, name, math.max(95, width - 185))
        FitTranslatedChefRow(row,kind)
        return
    end
    local sliderX, sliderWidth, amountX
    if kind == "meal" then
        sliderX = width - (stage == "minimum" and 250
            or stage == "narrow" and 265 or stage == "compact" and 270 or 266)
        sliderWidth = stage == "minimum" and 88 or stage == "narrow" and 96
            or stage == "compact" and 108 or 125
        amountX = sliderX + sliderWidth + 7
        row.cook:ClearAllPoints()
        row.cook:SetPoint("TOPLEFT", row, "TOPLEFT", width - 98, -5)
        row.missingIngredientsHint:ClearAllPoints()
        row.missingIngredientsHint:SetPoint("TOPLEFT", row, "TOPLEFT", sliderX, -4)
        row.missingIngredientsHint:SetWidth(width - sliderX - 30)
        Readable(row.name, JournalTextSize(panel, 15, 12))
        row.name:SetShown(stage ~= "minimum")
        FitJournalText(row.name, name, math.max(30, math.min(211, sliderX - 62)))
        row.skill:SetWidth(math.max(55, sliderX - 61))
        if stage == "minimum" then
            row.skill:ClearAllPoints()
            row.skill:SetPoint("LEFT", row, "LEFT", 54, 0)
        else
            row.skill:ClearAllPoints()
            row.skill:SetPoint("BOTTOMLEFT", row.icon:GetParent(), "BOTTOMRIGHT", 10, 4)
        end
    else
        sliderX = stage == "minimum" and width - 302
            or stage == "narrow" and width - 300
            or stage == "compact" and width - 320 or width - 328
        sliderWidth = stage == "minimum" and 58 or stage == "narrow" and 62
            or stage == "compact" and 68 or 74
        amountX = sliderX + sliderWidth + 5
        row.expand:SetWidth(math.min(325, math.max(100, sliderX + 3)))
        Readable(row.name, JournalTextSize(panel, 15, 12))
        row.name:SetShown(stage ~= "minimum")
        FitJournalText(row.name, name, stage == "full"
            and math.max(240, sliderX - 54) or math.max(30, sliderX - 54))
        row.skill:SetWidth(math.max(60, sliderX - 50))
        row.skill:ClearAllPoints()
        row.skill:SetPoint("TOPLEFT", row, "TOPLEFT", 48,
            stage == "minimum" and -17 or -27)
    end
    row.amountSlider:ClearAllPoints()
    row.amountSlider:SetPoint("TOPLEFT", row, "TOPLEFT", sliderX,
        kind == "meal" and -9 or -27)
    row.amountSlider:SetWidth(sliderWidth)
    row.amount:ClearAllPoints()
    row.amount:SetPoint("TOPLEFT", row, "TOPLEFT", amountX,
        kind == "meal" and -11 or -29)
    FitTranslatedChefRow(row,kind)
end

local function ChefMealRow(panel)
    local row = CreateFrame("Button", nil, panel.content)
    row.pooled = true; row:SetSize(548, 48); row:RegisterForClicks("LeftButtonUp")
    row.bg = Surface(row, 0.67, 0.51, 0.30, 0.12)
    local hi = row:CreateTexture(nil, "HIGHLIGHT")
    hi:SetAllPoints(row); hi:SetColorTexture(0.48, 0.30, 0.13, 0.09)
    row:SetHighlightTexture(hi)
    local iconButton = CreateFrame("Button", nil, row)
    iconButton:SetSize(38, 38); iconButton:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.icon = iconButton:CreateTexture(nil, "ARTWORK")
    row.icon:SetAllPoints(iconButton); row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RoundIcon(row.icon)
    local ShowMealTooltip
    local function RefreshMealTooltip(button, itemID)
        if not row.meal or row.meal.id ~= itemID then
            FF:HideJournalItemTooltip(button)
            return
        end
        ShowMealTooltip(button)
    end
    ShowMealTooltip = function(button)
        if not row.meal then return end
        FF:BeginJournalItemTooltip(button, row.meal.id, row.meal.name, false, RefreshMealTooltip)
        FF:FinishJournalItemTooltip(button)
    end
    iconButton:SetScript("OnEnter", ShowMealTooltip)
    iconButton:SetScript("OnLeave", function(button) FF:HideJournalItemTooltip(button) end)
    local function Toggle()
        local previousScroll = panel.scroll:GetVerticalScroll()
        if panel.expandedMeal == row.meal.id then
            panel.expandedMeal = nil
        else
            panel.expandedMeal = row.meal.id
        end
        panel.expandedRecipeVendorMeal = nil
        FF:RenderMasterChefMeals()
        panel.scroll:SetVerticalScroll(math.min(previousScroll, panel.scroll:GetVerticalScrollRange()))
    end
    iconButton:SetScript("OnClick", Toggle)
    row:SetScript("OnClick", Toggle)
    row.name = Readable(PaperText(row, "GameFontNormal", "TOPLEFT", iconButton, "TOPRIGHT", 10, -4, ""), 15)
    row.name:SetWidth(211); row.name:SetJustifyH("LEFT")
    row.name:SetTextColor(unpack(INK))
    row.skill = Readable(PaperText(row, "GameFontHighlight", "BOTTOMLEFT", iconButton, "BOTTOMRIGHT", 10, 4, ""), 14)
    row.skill:SetJustifyH("LEFT")
    row.skill:SetTextColor(unpack(SOFT_INK))
    ChefQuantityControls(row, panel, "meal", 282, -9, 125, 414, -11)
    row.cook = CreateFrame("Button", nil, row)
    row.cook:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row.cook:SetSize(68, 25)
    row.cook:SetPoint("TOPLEFT", row, "TOPLEFT", 450, -5)
    row.cook.bg = Surface(row.cook, 0.54, 0.33, 0.13, 0.32)
    Edge(row.cook, { 0.56, 0.35, 0.15 })
    row.cook.label = Readable(PaperText(row.cook, "GameFontNormal", "CENTER", row.cook,
        "CENTER", 0, 0, FF:LocalizedText("chef.ui.cook")), 13)
    row.cook.label:SetTextColor(unpack(INK))
    row.cook:SetScript("OnClick", function(_, button)
        if not row.meal then return end
        FF:ClearMasterChefStatus("meals")
        local mealID = row.meal.id
        local scroll = panel.scroll:GetVerticalScroll()
        local quantity = panel.chefQuantities and panel.chefQuantities[mealID] or 1
        if button == "LeftButton" then
            FF:QuickCookMasterChefMeal(mealID, quantity)
        elseif FF:AddMasterChefCooking(mealID, quantity) then
            FF:SetMasterChefMessage("masterChefQuickMessage",nil)
            if not FF.masterChefCookingActive and not FF.masterChefCookingPending
                and QueuePreparationCanUseClick("cooking") then
                FF:StartMasterChefCooking(true)
            end
        end
        FF:RenderMasterChefMeals()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    row.cook:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("chef.ui.cook"), 1, 0.82, 0.45)
        GameTooltip:AddLine(FF:LocalizedText("chef.ui.left-cook"), 0.83, 0.72, 0.52)
        GameTooltip:AddLine(FF:LocalizedText("chef.ui.right-queue"), 1, 211 / 255, 106 / 255)
        GameTooltip:Show()
    end)
    row.cook:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.missingIngredientsHint = CreateFrame("Frame", nil, row)
    row.missingIngredientsHint:SetPoint("TOPLEFT", row, "TOPLEFT", 308, -4)
    row.missingIngredientsHint:SetSize(210, 32)
    row.missingIngredientsHint:SetFrameLevel(row.cook:GetFrameLevel() + 1)
    row.missingIngredientsHint:EnableMouse(true)
    row.missingIngredientsHint.label = Readable(PaperText(row.missingIngredientsHint,
        "GameFontNormal", "CENTER", row.missingIngredientsHint, "CENTER", 0, 0,
        FF:LocalizedText("chef.ui.need-ingredients")), 13)
    row.missingIngredientsHint.label:SetTextColor(unpack(NEED_RED))
    row.missingIngredientsHint:SetScript("OnEnter", function(hint)
        local status = row.meal and FF:GetMasterChefMealStatus(row.meal.id)
        ShowChefMaterialsTooltip(hint, FF:LocalizedText("chef.ui.need-ingredients"),
            status and status.recipe.ingredients, status and status.counts,
            nil, nil, status and status.crafts and status.crafts > 0)
    end)
    row.missingIngredientsHint:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.missingIngredientsHint:Hide()
    row.indicator = row:CreateTexture(nil, "ARTWORK")
    row.indicator:SetSize(12, 7); row.indicator:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    return row
end

local function ChefQueueRow(content, queue)
    local row = CreateFrame("Frame", nil, content)
    row:SetSize(548, 25)
    local iconButton = CreateFrame("Button", nil, row)
    iconButton:SetSize(20, 20); iconButton:SetPoint("LEFT", row, "LEFT", 22, 0)
    row.icon = iconButton:CreateTexture(nil, "ARTWORK")
    row.icon:SetAllPoints(iconButton)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RoundIcon(row.icon)
    FF:FrameJournalRoundIcon(row.icon,20)
    iconButton:SetScript("OnEnter", function(button)
        local itemID = row.itemID or (row.meal and row.meal.id)
        if not itemID then return end
        FF:BeginJournalItemTooltip(button, itemID, row.meal and row.meal.name)
        FF:FinishJournalItemTooltip(button)
    end)
    iconButton:SetScript("OnLeave", function(button) FF:HideJournalItemTooltip(button) end)
    row.name = Readable(PaperText(row, "GameFontNormal", "LEFT", row, "LEFT", 46, 0, ""), 13)
    row.name:SetWidth(390); row.name:SetTextColor(unpack(INK))
    row.count = Readable(PaperText(row, "GameFontHighlight", "RIGHT", row, "RIGHT", -49, 0, ""), 13)
    row.count:SetWidth(45); row.count:SetJustifyH("RIGHT")
    row.count:SetTextColor(unpack(SOFT_INK))
    row.minus = CreateFrame("Button", nil, row)
    row.minus:SetSize(20, 20); row.minus:SetPoint("RIGHT", row, "RIGHT", -11, 0)
    row.minus.icon = row.minus:CreateTexture(nil, "ARTWORK")
    row.minus.icon:SetAllPoints(row.minus)
    row.minus.icon:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
    row.minus:SetScript("OnClick", function()
        local removed = queue.kind == "camp" and row.itemID
            and FF:RemoveMasterChefCampCraft(row.itemID)
            or queue.kind ~= "camp" and row.meal and FF:RemoveMasterChefCooking(row.meal.id)
        if not removed then return end
        local panel = FF.journalPanel
        local scroll = panel.scroll:GetVerticalScroll()
        if queue.kind == "camp" then FF:RenderMasterChefCampfire()
        else FF:RenderMasterChefMeals() end
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    return row
end

local function ChefQueue(panel, kind)
    kind = kind or "cooking"
    local key = kind == "camp" and "campQueue" or "chefQueue"
    if panel[key] then return panel[key] end
    local queue = CreateFrame("Frame", nil, panel.page)
    queue.kind = kind
    queue:SetFrameLevel(panel.scroll:GetFrameLevel() + 2)
    Surface(queue, 0.67, 0.51, 0.30, 0.18)
    local topRule = queue:CreateTexture(nil, "BORDER")
    topRule:SetPoint("TOPLEFT", queue, "TOPLEFT", 4, 0)
    topRule:SetPoint("TOPRIGHT", queue, "TOPRIGHT", -4, 0)
    topRule:SetHeight(1); topRule:SetColorTexture(0.43, 0.26, 0.10, 0.65)
    queue.toggle = CreateFrame("Button", nil, queue)
    queue.toggle:SetPoint("TOPLEFT", queue, "TOPLEFT", 10, -3)
    queue.toggle:SetPoint("TOPRIGHT", queue, "TOPRIGHT", -252, -3)
    queue.toggle:SetHeight(48)
    queue.toggle.icon = queue.toggle:CreateTexture(nil, "ARTWORK")
    queue.toggle.icon:SetSize(12, 7)
    queue.toggle.icon:SetPoint("TOPLEFT", queue.toggle, "TOPLEFT", 4, -10)
    queue.heading = Readable(PaperText(queue.toggle, "GameFontNormal", "TOPLEFT", queue.toggle,
        "TOPLEFT", 24, -5, kind == "camp" and FF:LocalizedText("chef.ui.crafting-queue") or FF:LocalizedText("chef.ui.cooking-queue")), 15)
    queue.heading:SetTextColor(unpack(INK))
    queue.total = Readable(PaperText(queue.toggle, "GameFontHighlight", "TOPLEFT", queue.toggle,
        "TOPLEFT", 170, -7, ""), 13)
    queue.total:SetTextColor(unpack(SOFT_INK))
    queue.nextIcon = queue.toggle:CreateTexture(nil, "ARTWORK")
    queue.nextIcon:SetSize(19, 19)
    queue.nextIcon:SetPoint("TOPLEFT", queue.toggle, "TOPLEFT", 24, -26)
    queue.nextIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RoundIcon(queue.nextIcon)
    FF:FrameJournalRoundIcon(queue.nextIcon,19)
    queue.next = Readable(PaperText(queue.toggle, "GameFontHighlight", "TOPLEFT", queue.toggle,
        "TOPLEFT", 48, -28, ""), 13)
    queue.next:SetWidth(285); queue.next:SetTextColor(unpack(SOFT_INK))
    queue.next:SetWordWrap(false)
    queue.nextMinus = CreateFrame("Button", nil, queue)
    queue.nextMinus:SetSize(17, 17)
    queue.nextMinus:SetPoint("TOPLEFT", queue.toggle, "TOPLEFT", 3, -27)
    queue.nextMinus:SetFrameLevel(queue.toggle:GetFrameLevel() + 1)
    queue.nextMinus.icon = queue.nextMinus:CreateTexture(nil, "ARTWORK")
    queue.nextMinus.icon:SetAllPoints(queue.nextMinus)
    queue.nextMinus.icon:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
    queue.nextMinus:SetScript("OnClick", function()
        local entries = kind == "camp" and FF.masterChefCampCraftQueue or FF.masterChefCookingQueue
        local first = entries and entries[1]
        if not first then return end
        local removed = kind == "camp" and FF:RemoveMasterChefCampCraft(first.itemID)
            or FF:RemoveMasterChefCooking(first.mealID)
        if not removed then return end
        local scroll = panel.scroll:GetVerticalScroll()
        if kind == "camp" then
            local nextEntry = (FF.masterChefCampCraftQueue or {})[1]
            if nextEntry and not FF.masterChefCampCrafting and not FF.masterChefCampPreparing
                and QueuePreparationCanUseClick("camp") then
                FF:CraftMasterChefCamp(nextEntry.itemID, nextEntry.quantity, true, true)
            end
            FF:RenderMasterChefCampfire()
        else
            if (FF.masterChefCookingQueue or {})[1]
                and not FF.masterChefCookingActive and not FF.masterChefCookingPending
                and QueuePreparationCanUseClick("cooking") then
                FF:StartMasterChefCooking(true)
            end
            FF:RenderMasterChefMeals()
        end
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    queue.nextMinus:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("chef.ui.remove-next"), 1, 0.82, 0.45)
        GameTooltip:Show()
    end)
    queue.nextMinus:SetScript("OnLeave", function() GameTooltip:Hide() end)
    queue.note = Readable(PaperText(queue, "GameFontHighlight", "BOTTOMLEFT", queue,
        "BOTTOMLEFT", 14, 7, ""), 12)
    queue.note:SetTextColor(unpack(SOFT_INK))
    queue.toggle:SetScript("OnClick", function()
        local entries = kind == "camp" and FF.masterChefCampCraftQueue
            or FF.masterChefCookingQueue
        if not entries or #entries <= 1 then return end
        if kind == "camp" then panel.campQueueExpanded = not panel.campQueueExpanded
        else panel.chefQueueExpanded = not panel.chefQueueExpanded end
        local scroll = panel.scroll:GetVerticalScroll()
        if kind == "camp" then FF:RenderMasterChefCampfire()
        else FF:RenderMasterChefMeals() end
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    queue.start = CreateFrame("Button", nil, queue)
    queue.start:SetSize(76, 25)
    queue.start:SetPoint("TOPRIGHT", queue, "TOPRIGHT", -13, -14)
    queue.start.bg = Surface(queue.start, 0.54, 0.33, 0.13, 0.32)
    Edge(queue.start, { 0.56, 0.35, 0.15 })
    queue.start.label = Readable(PaperText(queue.start, "GameFontNormal", "CENTER", queue.start,
        "CENTER", 0, 0, FF:LocalizedText("chef.ui.start")), 13)
    queue.start.label:SetTextColor(unpack(INK))
    local function StartQueue()
        if kind == "camp" then
            FF:ClearMasterChefStatus("campfire")
            FF:StartMasterChefCampCraftQueue()
            FF:RenderMasterChefCampfire()
        else
            FF:ClearMasterChefStatus("meals")
            FF:StartMasterChefCooking()
            FF:RenderMasterChefMeals()
        end
    end
    queue.start:SetScript("OnClick", StartQueue)
    queue.start:SetScript("OnEnter", function(button)
        local message = kind == "camp" and FF:GetMasterChefMessage("masterChefCampQueueMessage") or FF:GetMasterChefMessage("masterChefQueueMessage")
        if not message then return end
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(message, 1, 0.82, 0.45)
        GameTooltip:Show()
    end)
    queue.start:SetScript("OnLeave", function() GameTooltip:Hide() end)
    queue.sound = CreateFrame("Button", nil, queue)
    queue.sound:SetSize(25, 25)
    queue.sound:SetPoint("RIGHT", queue.start, "LEFT", -8, 0)
    Surface(queue.sound, 0.54, 0.33, 0.13, 0.25)
    Edge(queue.sound, { 0.56, 0.35, 0.15 })
    queue.sound.icon = queue.sound:CreateTexture(nil, "ARTWORK")
    queue.sound.icon:SetSize(17, 17)
    queue.sound.icon:SetPoint("CENTER", queue.sound, "CENTER")
    queue.sound.icon:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\JournalSpeaker")
    queue.sound.icon:SetVertexColor(0.47, 0.29, 0.11, 0.95)
    local function RefreshSoundLabel()
        local choice = FF:RangeSoundChoice(FF.db.cookingCompleteSound)
        queue.sound.choiceLabel = choice and choice.label or "Chime"
    end
    queue.sound.RefreshLabel = RefreshSoundLabel
    queue.sound:SetScript("OnEnter", function(button)
        RefreshSoundLabel()
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("chef.ui.queue-sound",queue.sound.choiceLabel), 1, 0.82, 0.45)
        GameTooltip:Show()
    end)
    queue.sound:SetScript("OnLeave", function() GameTooltip:Hide() end)
    queue.sound.menu = CreateFrame("Frame", nil, queue)
    queue.sound.menu:SetFrameLevel(queue:GetFrameLevel() + 8)
    queue.sound.menu:SetSize(190, #FF.rangeSoundChoices * 24 + 6)
    queue.sound.menu:SetPoint("BOTTOMRIGHT", queue.sound, "TOPRIGHT", 0, 3)
    Surface(queue.sound.menu, 0.83, 0.71, 0.51, 0.99)
    Edge(queue.sound.menu, { 0.52, 0.34, 0.15 })
    queue.sound.options = {}
    for index, choice in ipairs(FF.rangeSoundChoices) do
        local id = choice.id
        local option = CreateFrame("Button", nil, queue.sound.menu)
        option:SetPoint("TOPLEFT", queue.sound.menu, "TOPLEFT", 3, -3 - (index - 1) * 24)
        option:SetPoint("TOPRIGHT", queue.sound.menu, "TOPRIGHT", -3, -3 - (index - 1) * 24)
        option:SetHeight(24)
        local highlight = option:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(option)
        highlight:SetColorTexture(0.54, 0.33, 0.13, 0.2)
        option:SetHighlightTexture(highlight)
        option.label = Readable(PaperText(option, "GameFontNormal", "LEFT", option,
            "LEFT", 8, 0, choice.label), 13)
        option.label:SetTextColor(unpack(INK))
        option:SetScript("OnClick", function()
            FF:SetFishingSound("cooking", id)
            queue.sound.menu:Hide()
            RefreshSoundLabel()
            FF:PreviewFishingSound("cooking", id)
        end)
        queue.sound.options[index] = option
    end
    queue.sound.menu:Hide()
    queue.sound:SetScript("OnClick", function()
        queue.sound.menu:SetShown(not queue.sound.menu:IsShown())
    end)
    queue:HookScript("OnHide", function() queue.sound.menu:Hide() end)
    queue.list = CreateFrame("ScrollFrame", nil, queue)
    queue.list:SetPoint("TOPLEFT", queue, "TOPLEFT", 12, -56)
    queue.list:EnableMouseWheel(true)
    queue.list:SetScript("OnMouseWheel", function(_, delta)
        queue.list:SetVerticalScroll(math.max(0, math.min(queue.list:GetVerticalScrollRange(),
            queue.list:GetVerticalScroll() - delta * 27)))
    end)
    queue.content = CreateFrame("Frame", nil, queue.list)
    queue.content:SetSize(548, 1)
    queue.list:SetScrollChild(queue.content)
    queue.rows = {}
    panel[key] = queue
    queue:Hide()
    return queue
end

local function LayoutChefQueue(panel, queue)
    local width = JournalWidth(panel)
    queue.toggle:ClearAllPoints()
    queue.toggle:SetPoint("TOPLEFT", queue, "TOPLEFT", 10, -3)
    queue.toggle:SetPoint("TOPRIGHT", queue, "TOPRIGHT",
        JournalStage(panel) == "full" and -252 or -142, -3)
    queue.next:SetWidth(math.max(110,
        JournalStage(panel) == "full" and 283 or width - 192))
    queue.list:SetWidth(width)
    queue.content:SetWidth(width)
    for _, line in ipairs(queue.rows) do
        line:SetWidth(width)
        line.name:SetWidth(math.max(100, width - 157))
    end
end

local function ChefQueueHeaderHeight(panel, queue)
    if FF:GetResolvedLocale()=="enUS" then return 54 end
    local width = JournalWidth(panel)
    FitChefAction(queue.start)
    local textWidth = math.max(1,width-166)
    queue.heading:SetWidth(textWidth); queue.heading:SetWordWrap(true)
    queue.total:ClearAllPoints(); queue.total:SetPoint("TOPLEFT",queue.heading,"BOTTOMLEFT",0,-3)
    queue.total:SetWidth(textWidth); queue.total:SetWordWrap(true)
    local nextY = 5+math.ceil(queue.heading:GetStringHeight())+3+math.ceil(queue.total:GetStringHeight())+5
    queue.nextIcon:ClearAllPoints(); queue.nextIcon:SetPoint("TOPLEFT",queue.toggle,"TOPLEFT",24,-nextY)
    queue.nextMinus:ClearAllPoints(); queue.nextMinus:SetPoint("TOPLEFT",queue.toggle,"TOPLEFT",3,-nextY-1)
    queue.next:ClearAllPoints(); queue.next:SetPoint("TOPLEFT",queue.toggle,"TOPLEFT",48,-nextY-2)
    queue.next:SetWidth(math.max(1,width-192)); queue.next:SetWordWrap(true)
    local height = math.max(nextY+math.max(19,math.ceil(queue.next:GetStringHeight())+2)+8,
        queue.start:GetHeight()+28)
    queue.toggle:SetHeight(height-3)
    queue.list:ClearAllPoints(); queue.list:SetPoint("TOPLEFT",queue,"TOPLEFT",12,-height-2)
    return height
end

local function ChefQueueNoticeHeight(panel, queue, notice)
    queue.note:SetText(notice or "")
    if FF:GetResolvedLocale()=="enUS" then return notice and 18 or 0 end
    queue.note:SetWidth(math.max(1,JournalWidth(panel)-28)); queue.note:SetWordWrap(true)
    return notice and math.max(18,math.ceil(queue.note:GetStringHeight())+4) or 0
end

local function ChefMealDetail(panel)
    local detail = CreateFrame("Frame", nil, panel.content)
    detail.pooled = true; detail:SetWidth(548)
    EnableGuideLinks(detail, panel)
    Surface(detail, 0.46, 0.34, 0.19, 0.08)
    detail.fields = {}
    for index = 1, 6 do
        local heading = Readable(PaperText(detail, "GameFontNormal", "TOPLEFT", detail, "TOPLEFT", 15, 0, ""), 14)
        heading:SetWidth(100); heading:SetTextColor(unpack(INK))
        local value = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail, "TOPLEFT", 117, 0, ""), 14)
        value:SetWidth(410); value:SetJustifyH("LEFT"); value:SetJustifyV("TOP")
        value:SetSpacing(2); value:SetTextColor(unpack(SOFT_INK))
        detail.fields[index] = { heading = heading, value = value }
    end
    detail.vendorRows = {}
    detail.vendorToggle = CreateFrame("Button", nil, detail)
    detail.vendorToggle:SetSize(22, 22)
    detail.vendorToggle:RegisterForClicks("LeftButtonUp")
    detail.vendorToggle.icon = detail.vendorToggle:CreateTexture(nil, "ARTWORK")
    detail.vendorToggle.icon:SetSize(12, 12)
    detail.vendorToggle.icon:SetPoint("CENTER", detail.vendorToggle, "CENTER")
    detail.vendorToggle.icon:SetAlpha(0.65)
    detail.vendorToggle:Hide()
    detail.note = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail, "TOPLEFT", 15, 0, ""), 13)
    detail.note:SetWidth(510); detail.note:SetTextColor(unpack(SOFT_INK))
    Divider(detail)
    return detail
end

local function ChefVendorRow(detail)
    local row = CreateFrame("Button", nil, detail)
    row:SetSize(365, 21)
    row:RegisterForClicks("LeftButtonUp")
    row.label = Readable(PaperText(row, "GameFontHighlight", "LEFT", row, "LEFT", 0, 0, ""), 14)
    row.label:SetWidth(365)
    row.label:SetJustifyH("LEFT")
    row:SetScript("OnClick", function(button)
        if button.point and button.point.mapID then FF:OpenGuideMapPoint(button.point) end
    end)
    row:SetScript("OnEnter", function(button)
        if not button.point then return end
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:GetGuideMapLabel(button.point), 1, 0.82, 0.45)
        GameTooltip:AddLine(button.point.mapID and FF:LocalizedText("chef.detail.vendor-map")
            or FF:LocalizedText("chef.detail.map-unavailable"), 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return row
end

local function FillChefMealDetail(detail, meal, status)
    local width = JournalWidth(FF.journalPanel)
    detail:SetWidth(width)
    detail.note:SetWidth(width - 30)
    for _, field in ipairs(detail.fields) do field.value:SetWidth(width - 137) end
    for _, row in ipairs(detail.vendorRows) do
        row:SetWidth(width - 155); row.label:SetWidth(width - 155)
    end
    local skills = FF.journalPanel and FF.journalPanel.journalSkills or FF:GetJournalSkills()
    local faction = FF:GetJournalFaction()
    local ingredientNames = {}
    for name in meal.ingredients:gmatch("[^,]+") do
        ingredientNames[#ingredientNames + 1] = name:match("^%s*(.-)%s*$")
    end
    local ingredientLines = {}
    if status and status.recipe.ingredients then
        local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
        local getCount = (C_Item and C_Item.GetItemCount) or GetItemCount
        for index, ingredient in ipairs(status.recipe.ingredients) do
            local name = FF:GetJournalItemDisplayName(ingredient.id,(getInfo and getInfo(ingredient.id)))
                or (ingredientNames[index] and ingredientNames[index]:gsub("^%d+%s+", ""))
                or FF:LocalizedText("journal.chrome.item-hash",ingredient.id)
            local count = status.counts and status.counts[index]
            if count == nil and getCount then
                local ok, current = pcall(getCount, ingredient.id, false, false)
                if ok and type(current) == "number" then count = current end
            end
            ingredientLines[#ingredientLines + 1] = name .. (count and
                ("  " .. count .. "/" .. ingredient.quantity) or "")
        end
    else
        ingredientLines = ingredientNames
    end
    local effect=FF:GetJournalFoodDisplayEffects(meal.id)
    local cookingSkill=meal.skill and FF:LocalizedText("journal.chrome.skill",ColorRequirement(skills, tostring(meal.skill), "Cooking", meal.skill))
        or FF:LocalizedText("chef.detail.skill-unconfirmed")
    local fields = {
        { FF:LocalizedText("chef.detail.cooking"), cookingSkill },
    }
    if effect and effect.nativeEffects then fields[#fields+1]={FF:LocalizedText("chef.detail.effect"),effect.nativeEffects} end
    if effect and effect.restores then fields[#fields+1]={FF:LocalizedText("food.restores"),effect.restores} end
    if effect and effect.bonuses then fields[#fields+1]={FF:LocalizedText("food.bonuses"),effect.bonuses} end
    fields[#fields+1]={FF:LocalizedText("chef.detail.ingredients"),table.concat(ingredientLines,"\n")}
    fields[#fields+1]={FF:LocalizedText("chef.detail.recipe"),FF:GetMasterChefReferenceText("meal",meal,"recipe",faction),key="recipe"}
    fields[#fields+1]={FF:LocalizedText("chef.detail.find-ingredients"),FF:GetMasterChefReferenceText("meal",meal,"waters",faction)}
    for _,widgets in ipairs(detail.fields) do widgets.heading:Hide(); widgets.value:Hide() end
    local y = 12
    local vendors = FF:GetOrderedMealRecipeVendors(meal.id, faction)
    local expanded = vendors and #vendors > 1
        and FF.journalPanel.expandedRecipeVendorMeal == meal.id
    local visibleVendors = vendors and (expanded and #vendors or 1) or 0
    for index, row in ipairs(detail.vendorRows) do row:SetShown(index <= visibleVendors) end
    detail.vendorToggle:SetShown(vendors and #vendors > 1 or false)
    for index, field in ipairs(fields) do
        local widgets = detail.fields[index]
        widgets.heading:ClearAllPoints(); widgets.value:ClearAllPoints()
        widgets.heading:SetPoint("TOPLEFT", detail, "TOPLEFT", 15, -y)
        widgets.value:SetPoint("TOPLEFT", detail, "TOPLEFT", 117, -y)
        widgets.heading:SetText(field[1]); widgets.heading:Show(); widgets.value:Show()
        widgets.heading:SetWordWrap(true); widgets.value:SetWordWrap(true)
        if field.key == "recipe" and vendors then
            widgets.value:SetText("")
            for vendorIndex = 1, visibleVendors do
                local row = detail.vendorRows[vendorIndex]
                if not row then row = ChefVendorRow(detail); detail.vendorRows[vendorIndex] = row end
                local point = vendors[vendorIndex]
                row.point = point
                row:SetWidth(width - 155); row.label:SetWidth(width - 155)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", detail, "TOPLEFT", 117, -y - (vendorIndex - 1) * 23)
                row.label:SetText(FF:GetJournalNPCDisplayName(point.name) .. "  •  " .. FF:GetJournalSourceLocationText(point))
                row.label:SetTextColor(point.mapID and 0.20 or SOFT_INK[1],
                    point.mapID and 0.37 or SOFT_INK[2], point.mapID and 0.42 or SOFT_INK[3])
                row:Show()
            end
            if #vendors > 1 then
                detail.vendorToggle:ClearAllPoints()
                detail.vendorToggle:SetPoint("TOPRIGHT", detail, "TOPRIGHT", -17, -y + 1)
                detail.vendorToggle.icon:SetTexture(expanded and
                    "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
                detail.vendorToggle:SetScript("OnClick", function()
                    local panel = FF.journalPanel
                    local scroll = panel.scroll:GetVerticalScroll()
                    if expanded then
                        panel.expandedRecipeVendorMeal = nil
                    else
                        panel.expandedRecipeVendorMeal = meal.id
                    end
                    FF:RenderMasterChefMeals()
                    panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
                end)
            end
            y = y + math.max(visibleVendors * 23,FF:GetResolvedLocale()~="enUS" and widgets.heading:GetStringHeight() or 0) + 5
        else
            widgets.value:SetText(LinkText(detail, JournalFactionText(field[2], faction)))
            y = y + math.max(20, widgets.heading:GetStringHeight(), widgets.value:GetStringHeight()) + 5
        end
    end
    detail.note:ClearAllPoints()
    local notes={}
    if effect and not effect.available then notes[#notes+1]=effect.summary end
    if meal.extra then notes[#notes+1]=FF:GetMasterChefReferenceText("meal",meal,"extra") end
    if #notes>0 then
        detail.note:SetPoint("TOPLEFT", detail, "TOPLEFT", 15, -y - 2)
        detail.note:SetText(LinkText(detail,table.concat(notes,"\n"))); detail.note:Show()
        y = y + detail.note:GetStringHeight() + 8
    else detail.note:Hide() end
    detail:SetHeight(y + 6)
end

function FF:RenderMasterChefMeals()
    local panel = self.journalPanel
    local skills = panel.journalSkills or self:GetJournalSkills()
    self:EnsureMasterChefCooking(not self.masterChefRecipesChecked)
    self:EnsureMasterChefCamps()
    local display = self:CreateMasterChefDisplaySnapshot()
    local meals = {}
    local statuses = {}
    for _, meal in ipairs(self.masterChefMeals or {}) do
        meals[#meals + 1] = meal
        statuses[meal.id] = self:GetMasterChefMealStatus(meal.id, display)
    end
    table.sort(meals, function(a, b)
        local aOrder = statuses[a.id] and statuses[a.id].order or 4
        local bOrder = statuses[b.id] and statuses[b.id].order or 4
        if aOrder ~= bOrder then return aOrder < bOrder end
        return self.CompareMasterChefMealSkills(a, b)
    end)
    ClearDynamic(panel)
    panel.pageTitle:SetText(FF:LocalizedText("settings.copy.master-chef-78f9"))
    self:RenderMasterChefStatus("meals", self.masterChefQuickMessage
        or self.masterChefQueueMessage)
    panel.chefRows, panel.chefDetails = panel.chefRows or {}, panel.chefDetails or {}
    local camp
    for _, entry in ipairs(self.masterChefCamps or {}) do
        if entry.basic then camp = entry; break end
    end
    local y = 0
    if camp and camp.basic then
        local row = panel.grillingCampfireRow
        if not row then
            row = ChefGrillingCampfireRow(panel, camp)
            panel.grillingCampfireRow = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, 0)
        LayoutChefRow(panel, row, "basic", self:GetJournalItemDisplayName(camp.id,"Basic Campfire"))
        local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(camp.id)
        if not icon and GetItemIcon then icon = GetItemIcon(camp.id) end
        row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        local status = self:GetMasterChefCampStatus(camp.id, display)
        self:StyleLearnedJournalRow(row, status and status.learned == true)
        local owned = status and status.owned > 0 or false
        local craftable = not owned and status and status.learned
            and self:GetMasterChefCampAvailableCrafts(camp.id, display) > 0
        if not (InCombatLockdown and InCombatLockdown()) then
            if not row.placeReady then
                row.place:SetAttribute("useOnKeyDown", false)
                row.place:SetAttribute("type", "item")
                row.place:SetAttribute("type1", "item")
                row.place:SetAttribute("item", "item:" .. camp.id)
                row.place:SetAttribute("item1", "item:" .. camp.id)
                row.placeReady = true
            end
            row.place:SetShown(owned)
        end
        row.craft:SetShown(craftable and true or false)
        row.craftHint:SetShown(not owned and not craftable)
        AddDynamic(panel, row)
        y = math.max(62,row:GetHeight()+11)
    end
    for index, meal in ipairs(meals) do
        local row = panel.chefRows[index]
        if not row then row = ChefMealRow(panel); panel.chefRows[index] = row end
        row.meal = meal
        row.contentY = y
        row:ClearAllPoints(); row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        LayoutChefRow(panel, row, "meal", self:GetJournalItemDisplayName(meal.id,meal.name))
        row.bg:SetColorTexture(0.67, 0.51, 0.30, index % 2 == 1 and 0.18 or 0.08)
        local status = statuses[meal.id]
        local unlearned = status and not status.recipe.learned
        local known = status and status.recipe.learned
        local borderHeight = row:GetHeight()
        local available = known and self:GetMasterChefAvailableCrafts(meal.id, display) or 0
        local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(meal.id)
        if not icon and GetItemIcon then icon = GetItemIcon(meal.id) end
        row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.icon:SetDesaturated(unlearned and true or false)
        row.icon:SetAlpha(unlearned and 0.48 or 1)
        self:FrameJournalRoundIcon(row.icon,38,unlearned)
        row.name:SetTextColor(unlearned and 0.48 or INK[1],
            unlearned and 0.43 or INK[2], unlearned and 0.37 or INK[3])
        local skillLabel=meal.skill and self:GetJournalChefSkillText("Cooking",meal.skill)
            or self:LocalizedText("chef.detail.skill-unconfirmed")
        row.skill:SetText(unlearned and skillLabel or ColorRequirement(skills,skillLabel,"Cooking",meal.skill))
        FitTranslatedChefSkill(panel,row,"meal");borderHeight=row:GetHeight()
        row.skill:SetTextColor(unlearned and 0.48 or SOFT_INK[1],
            unlearned and 0.43 or SOFT_INK[2], unlearned and 0.37 or SOFT_INK[3])
        row.amountSlider:SetShown(known and available > 0 or false)
        row.amount:SetShown(known and available > 0 or false)
        row.cook:SetShown(known and available > 0 or false)
        row.missingIngredientsHint:SetShown(known and available == 0 or false)
        if known then
            RefreshChefQuantityControls(row, panel, "meal", meal.id, available)
        end
        SetJournalChevron(row.indicator, panel.expandedMeal == meal.id)
        AddDynamic(panel, row)
        y = y + row:GetHeight()
        if panel.expandedMeal == meal.id then
            local detail = panel.chefDetails[index]
            if not detail then detail = ChefMealDetail(panel); panel.chefDetails[index] = detail end
            FillChefMealDetail(detail, meal, statuses[meal.id])
            detail:ClearAllPoints(); detail:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
            AddDynamic(panel, detail)
            borderHeight = row:GetHeight() + detail:GetHeight()
            y = y + detail:GetHeight() + 8
        end
        self:StyleLearnedJournalRow(row, known == true, borderHeight)
    end
    local queue = ChefQueue(panel)
    LayoutChefQueue(panel, queue)
    local entries = self.masterChefCookingQueue or {}
    for index, line in ipairs(queue.rows) do line:SetShown(index < #entries) end
    for index = 2, #entries do
        local entry = entries[index]
        local lineIndex = index - 1
        local line = queue.rows[lineIndex]
        if not line then line = ChefQueueRow(queue.content, queue); queue.rows[lineIndex] = line end
        line:SetWidth(JournalWidth(panel))
        line.name:SetWidth(math.max(100, JournalWidth(panel) - 157))
        line.meal = nil
        line.itemID = nil
        for _, candidate in ipairs(self.masterChefMeals or {}) do
            if candidate.id == entry.mealID then line.meal = candidate; break end
        end
        line:ClearAllPoints(); line:SetPoint("TOPLEFT", queue.content, "TOPLEFT", 0, -(index - 2) * 27)
        line.name:SetText(self:GetJournalItemDisplayName(entry.mealID,line.meal and line.meal.name or FF:LocalizedText("journal.chrome.meal-hash",entry.mealID)))
        line.count:SetText("×" .. entry.quantity)
        local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(entry.mealID)
        if not icon and GetItemIcon then icon = GetItemIcon(entry.mealID) end
        line.iconTexture = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        line.icon:SetTexture(line.iconTexture)
        line:Show()
    end
    if #entries > 0 then
        local total = 0
        for _, entry in ipairs(entries) do total = total + entry.quantity end
        queue.total:SetText(FF:LocalizedText("chef.ui.to-cook",total))
        local nextMeal
        for _, candidate in ipairs(self.masterChefMeals or {}) do
            if candidate.id == entries[1].mealID then nextMeal = candidate; break end
        end
        local ready = self.masterChefCookingPrepared
            or (self.IsMasterChefCookingSessionReady and self:IsMasterChefCookingSessionReady())
        local nextIcon = C_Item and C_Item.GetItemIconByID
            and C_Item.GetItemIconByID(entries[1].mealID)
        if not nextIcon and GetItemIcon then nextIcon = GetItemIcon(entries[1].mealID) end
        queue.nextIcon:SetTexture(nextIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        queue.next:SetText(FF:LocalizedText(self.masterChefCookingActive and "chef.ui.next-cooking"
            or self.masterChefCookingPending and "chef.ui.next-preparing" or ready and "chef.ui.next-ready" or "chef.ui.next",
            nextMeal and nextMeal.name or FF:LocalizedText("journal.chrome.meal-hash",entries[1].mealID), entries[1].quantity))
        queue.start.label:SetText(self.masterChefCookingActive and FF:LocalizedText("chef.ui.cooking")
            or (self.masterChefCookingPending or self.masterChefCookingQuickPending) and FF:LocalizedText("chef.ui.preparing")
            or ready and FF:LocalizedText("chef.ui.start") or FF:LocalizedText("chef.ui.prepare"))
        queue.sound:RefreshLabel()
        local busy = self.masterChefCookingActive or self.masterChefCookingPending
            or self.masterChefCookingQuickPending
        queue.start:EnableMouse(not busy)
        queue.start:SetAlpha(busy and 0.45 or 1)
        if #entries <= 1 then panel.chefQueueExpanded = false end
        local expanded = panel.chefQueueExpanded == true
        local notice = not busy and self:GetMasterChefMessage("masterChefQueueMessage")
        local remaining = #entries - 1
        local visibleRows = math.min(remaining, 3)
        local noticeHeight = ChefQueueNoticeHeight(panel,queue,notice)
        local height = ChefQueueHeaderHeight(panel,queue) + (expanded and (remaining > 0 or notice)
            and 8 + visibleRows * 27 + noticeHeight or 0)
        queue:ClearAllPoints()
        queue:SetPoint("BOTTOMLEFT", panel.page, "BOTTOMLEFT", 16, 16)
        queue:SetPoint("BOTTOMRIGHT", panel.page, "BOTTOMRIGHT", -16, 16)
        queue:SetHeight(height)
        SetChefQueueChevron(queue, expanded, #entries)
        queue.note:SetText(notice or "")
        queue.note:SetShown(expanded and notice and true or false)
        queue.list:SetShown(expanded and remaining > 0)
        queue.list:SetSize(JournalWidth(panel), visibleRows * 27)
        queue.content:SetHeight(math.max(1, remaining * 27))
        if queue.list.UpdateScrollChildRect then queue.list:UpdateScrollChildRect() end
        queue.list:SetVerticalScroll(math.min(queue.list:GetVerticalScroll(),
            queue.list:GetVerticalScrollRange()))
        queue:Show()
        panel.scroll:ClearAllPoints()
        local side = JournalScrollSide(panel)
        panel.scroll:SetPoint("TOPLEFT", panel.page, "TOPLEFT", side, JournalScrollTop(panel))
        panel.scroll:SetPoint("BOTTOMRIGHT", panel.page, "BOTTOMRIGHT", -side, 24 + height)
    else
        panel.chefQueueExpanded = false
        queue.list:SetVerticalScroll(0)
    end
    SetCatchHeight(panel, math.max(1, y))
    panel.renderedTab = "chef"
end

function FF:RenderMasterChefGuide()
    local panel = self.journalPanel
    local faction = self:GetJournalFaction()
    panel.routeFloatingControls = true
    panel.routeSelectors = {}
    panel.routeTrainingSources = {}
    local blocks = {}
    for _, stage in ipairs(self.masterChefRoute or {}) do
        local fish = self:GetMasterChefReferenceText("route",stage,"fish",faction,panel.journalSkills)
        local sources = self:GetMasterChefRouteSourceRows(stage, faction, panel.journalSkills)
        local instructions = {{kind="catches", text=fish}}
        for _, source in ipairs(sources) do
            panel.routeTrainingSources[source.key] = source.points
            instructions[#instructions+1] = {
                kind=source.key:sub(1,12) == "Chef:Recipe:" and "recipe" or "training",
                text=source.instruction, source=source.key,
            }
        end
        instructions[#instructions+1] = {kind="waters",
            text=self:GetMasterChefReferenceText("route",stage,string.lower(faction),faction,panel.journalSkills)}
        blocks[#blocks + 1] = { heading = stage.heading, structuredSkills = true,
            routePage = true, cookingInstructions = instructions,
            displayHeading = self:GetMasterChefReferenceText("route",stage,"heading",faction,panel.journalSkills), summary = fish,
            body = fish .. "\n" .. self:GetMasterChefReferenceText("route",stage,"recipe",faction,panel.journalSkills)
                .. "\n" .. self:GetMasterChefReferenceText("route",stage,string.lower(faction),faction,panel.journalSkills) }
    end
    self:RenderGuide({ title = FF:LocalizedText("settings.copy.master-chef-78f9"), subtitle = FF:LocalizedText("chef.ui.cooking-guide"),
        profession = "Cooking", blocks = blocks }, 0)
    self:RenderMasterChefStatus("guide")
    panel.renderedTab = "chef"
end

local function ChefCampRow(panel, camp)
    local row = CreateFrame("Frame", nil, panel.content)
    row.pooled = true
    row:SetSize(548, 48)
    row.bg = Surface(row, 0.67, 0.51, 0.30, 0.12)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(36, 36)
    row.icon:SetPoint("LEFT", row, "LEFT", 5, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RoundIcon(row.icon)
    row.name = Readable(PaperText(row, "GameFontNormal", "TOPLEFT", row,
        "TOPLEFT", 48, -5, ""), 15)
    row.name:SetWidth(240)
    row.name:SetJustifyH("LEFT")
    row.name:SetTextColor(unpack(INK))
    row.skill = Readable(PaperText(row, "GameFontHighlight", "TOPLEFT", row,
        "TOPLEFT", 48, -27, ""), 13)
    row.skill:SetJustifyH("LEFT")
    row.skill:SetTextColor(unpack(SOFT_INK))
    local function ShowTooltip(button)
        ShowChefCampTooltip(button, camp)
    end
    local function ToggleDetail()
        local scroll = panel.scroll:GetVerticalScroll()
        if panel.expandedCamp == camp.id then
            panel.expandedCamp = nil
        else
            panel.expandedCamp = camp.id
        end
        FF:RenderMasterChefCampfire()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end
    row.expand = CreateFrame("Button", nil, row)
    row.expand:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.expand:SetSize(325, 48)
    row.expand:RegisterForClicks("LeftButtonUp")
    row.expand:SetScript("OnClick", ToggleDetail)
    row.expand:SetScript("OnEnter", ShowTooltip)
    row.expand:SetScript("OnLeave", function(button) FF:HideJournalItemTooltip(button) end)
    row.expandChevron = CreateFrame("Button", nil, row)
    row.expandChevron:SetSize(20, 28)
    row.expandChevron:SetPoint("RIGHT", row, "RIGHT", -3, 0)
    row.expandChevron:RegisterForClicks("LeftButtonUp")
    row.expandChevron:SetScript("OnClick", ToggleDetail)
    row.expandChevron:SetScript("OnEnter", ShowTooltip)
    row.expandChevron:SetScript("OnLeave", function(button) FF:HideJournalItemTooltip(button) end)
    row.indicator = row:CreateTexture(nil, "ARTWORK")
    row.indicator:SetSize(12, 7)
    row.indicator:SetPoint("RIGHT", row, "RIGHT", -7, 0)
    ChefQuantityControls(row, panel, "camp", 220, -27, 74, 299, -29)
    row.amountSlider:SetFrameLevel(row.expand:GetFrameLevel() + 1)
    row.craft = CreateFrame("Button", nil, row)
    row.craft:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row.craft:SetSize(70, 25)
    row.craft:SetPoint("RIGHT", row, "RIGHT", -127, 0)
    Surface(row.craft, 0.54, 0.33, 0.13, 0.32)
    Edge(row.craft, { 0.56, 0.35, 0.15 })
    row.craft.label = Readable(PaperText(row.craft, "GameFontNormal", "CENTER",
        row.craft, "CENTER", 0, 0, FF:LocalizedText("chef.ui.craft")), 12)
    row.craft.label:SetTextColor(unpack(INK))
    row.craft:SetScript("OnClick", function(_, button)
        FF:ClearMasterChefStatus("campfire")
        local scroll = panel.scroll:GetVerticalScroll()
        local amount = panel.chefCampQuantities and panel.chefCampQuantities[camp.id] or 1
        if button == "LeftButton" then
            FF:CraftMasterChefCamp(camp.id, amount)
        else
            FF:SetMasterChefMessage("masterChefCampMessage",nil)
            if FF:AddMasterChefCampCraft(camp.id, amount)
                and not FF.masterChefCampCrafting and not FF.masterChefCampPreparing
                and QueuePreparationCanUseClick("camp") then
                local first = (FF.masterChefCampCraftQueue or {})[1]
                if first then FF:CraftMasterChefCamp(first.itemID, first.quantity, true, true) end
            end
        end
        FF:RenderMasterChefCampfire()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    row.craft:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(FF:LocalizedText("chef.ui.craft"), 1, 0.82, 0.45)
        GameTooltip:AddLine(FF:LocalizedText("chef.ui.left-craft"), 0.83, 0.72, 0.52)
        GameTooltip:AddLine(FF:LocalizedText("chef.ui.right-queue"), 1, 211 / 255, 106 / 255)
        GameTooltip:Show()
    end)
    row.craft:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.craftHint = CreateFrame("Frame", nil, row)
    row.craftHint:SetPoint("RIGHT", row, "RIGHT", -125, 0)
    row.craftHint:SetSize(116, 32)
    row.craftHint:SetFrameLevel(row.craft:GetFrameLevel() + 1)
    row.craftHint:EnableMouse(true)
    row.craftHint.label = Readable(PaperText(row.craftHint, "GameFontNormal",
        "CENTER", row.craftHint, "CENTER", 0, 0, FF:LocalizedText("chef.ui.need-materials")), 13)
    row.craftHint.label:SetTextColor(unpack(NEED_RED))
    row.craftHint:SetScript("OnEnter", function()
        local status = FF:GetMasterChefCampStatus(camp.id)
        ShowChefMaterialsTooltip(row.craftHint, FF:LocalizedText("chef.ui.need-materials"),
            status and status.ingredients, status and status.counts,
            camp.toolID and FF:GetJournalItemDisplayName(camp.toolID,camp.toolName or FF:LocalizedText("journal.chrome.tool")), status and status.toolCount,
            status and status.crafts and status.crafts > 0)
    end)
    row.craftHint:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.place = ChefCampPlaceButton(row, camp, FF:LocalizedText("chef.ui.place"), 92, -26)
    return row
end

local function ChefCampDetail(panel)
    local detail = CreateFrame("Frame", nil, panel.content)
    EnableGuideLinks(detail, panel)
    detail.pooled = true; detail:SetWidth(548)
    Surface(detail, 0.46, 0.34, 0.19, 0.08)
    detail.materials = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail,
        "TOPLEFT", 117, -12, ""), 14)
    detail.materials:SetWidth(410); detail.materials:SetJustifyV("TOP")
    detail.materials:SetSpacing(2); detail.materials:SetTextColor(unpack(SOFT_INK))
    detail.materialsLabel = Readable(PaperText(detail, "GameFontNormal", "TOPLEFT", detail,
        "TOPLEFT", 15, -12, FF:LocalizedText("chef.detail.materials")), 14)
    detail.materialsLabel:SetTextColor(unpack(INK))
    detail.effectLabel = Readable(PaperText(detail, "GameFontNormal", "TOPLEFT", detail,
        "TOPLEFT", 15, -12, FF:LocalizedText("chef.detail.effect")), 14)
    detail.effectLabel:SetTextColor(unpack(INK))
    detail.effect = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail,
        "TOPLEFT", 117, -12, ""), 14)
    detail.effect:SetWidth(410); detail.effect:SetJustifyV("TOP")
    detail.effect:SetTextColor(unpack(SOFT_INK))
    detail.recipeLabel = Readable(PaperText(detail, "GameFontNormal", "TOPLEFT", detail,
        "TOPLEFT", 15, -12, FF:LocalizedText("chef.detail.recipe")), 14)
    detail.recipeLabel:SetTextColor(unpack(INK))
    detail.recipe = Readable(PaperText(detail, "GameFontHighlight", "TOPLEFT", detail,
        "TOPLEFT", 117, -12, ""), 14)
    detail.recipe:SetWidth(410); detail.recipe:SetJustifyV("TOP")
    detail.recipe:SetTextColor(unpack(SOFT_INK))
    return detail
end

local function FillChefCampDetail(detail, camp, status)
    local width = JournalWidth(FF.journalPanel)
    detail:SetWidth(width)
    detail.materials:SetWidth(width - 137)
    detail.effect:SetWidth(width - 137)
    detail.recipe:SetWidth(width - 137)
    if FF:GetResolvedLocale()~="enUS" then
        for _,label in ipairs({detail.materialsLabel,detail.effectLabel,detail.recipeLabel}) do
            label:SetWidth(96);label:SetWordWrap(true)
        end
    end
    local lines = {}
    for index, ingredient in ipairs(status.ingredients) do
        local name = FF:GetJournalItemDisplayName(ingredient.id,ingredient.name)
        if not name and C_Item and C_Item.GetItemInfo then name = C_Item.GetItemInfo(ingredient.id) end
        if not name and GetItemInfo then name = GetItemInfo(ingredient.id) end
        lines[#lines + 1] = (name or FF:LocalizedText("journal.chrome.item-hash",ingredient.id)) .. "  "
            .. (status.counts[index] and tostring(status.counts[index]) or "?")
            .. "/" .. ingredient.quantity
    end
    if camp.toolID then
        lines[#lines + 1] = FF:GetJournalItemDisplayName(camp.toolID,camp.toolName or FF:LocalizedText("journal.chrome.tool")) .. "  "
            .. (status.toolCount and tostring(status.toolCount) or "?") .. "/1"
    end
    detail.materials:SetText(table.concat(lines, "\n"))
    local y = 12 + math.max(20, detail.materials:GetStringHeight(),FF:GetResolvedLocale()~="enUS" and detail.materialsLabel:GetStringHeight() or 0) + 7
    detail.effectLabel:ClearAllPoints(); detail.effect:ClearAllPoints()
    if camp.benefit then
        detail.effectLabel:SetPoint("TOPLEFT", detail, "TOPLEFT", 15, -y)
        detail.effect:SetPoint("TOPLEFT", detail, "TOPLEFT", 117, -y)
        detail.effect:SetText(FF:GetMasterChefReferenceText("camp",camp,"benefit"))
        detail.effectLabel:Show(); detail.effect:Show()
        y = y + math.max(20, detail.effect:GetStringHeight(),FF:GetResolvedLocale()~="enUS" and detail.effectLabel:GetStringHeight() or 0) + 7
    else detail.effectLabel:Hide(); detail.effect:Hide() end
    detail.recipeLabel:ClearAllPoints(); detail.recipe:ClearAllPoints()
    if camp.source then
        detail.recipeLabel:SetPoint("TOPLEFT", detail, "TOPLEFT", 15, -y)
        detail.recipe:SetPoint("TOPLEFT", detail, "TOPLEFT", 117, -y)
        detail.recipe:SetText(FF:GuideLinkText(FF:GetMasterChefReferenceText("camp",camp,"source"),true,true))
        detail.recipeLabel:Show(); detail.recipe:Show()
        y = y + math.max(20, detail.recipe:GetStringHeight(),FF:GetResolvedLocale()~="enUS" and detail.recipeLabel:GetStringHeight() or 0) + 7
    else detail.recipeLabel:Hide(); detail.recipe:Hide() end
    detail:SetHeight(y + 5)
end

function FF:RenderMasterChefCampfire()
    local panel = self.journalPanel
    self:EnsureMasterChefCamps()
    local display = self:CreateMasterChefDisplaySnapshot()
    local camps, statuses = {}, {}
    local available, campSkills = self:GetMasterChefCampEntries()
    for _, camp in ipairs(available) do
        camps[#camps + 1] = camp
        statuses[camp.id] = self:GetMasterChefCampStatus(camp.id, display)
    end
    local function CampGroup(camp)
        if camp.basic then return 0 end
        local status = statuses[camp.id]
        local available = status.owned > 0 or status.learned
        local fishing = not camp.profession or camp.profession == "Fishing"
        return (available and 1 or 3) + (fishing and 0 or 1)
    end
    table.sort(camps, function(a, b)
        local aGroup, bGroup = CampGroup(a), CampGroup(b)
        if aGroup ~= bGroup then return aGroup < bGroup end
        local left, right = statuses[a.id].order, statuses[b.id].order
        if left ~= right then return left < right end
        if a.skill ~= b.skill then return a.skill < b.skill end
        if (a.profession or "Fishing") ~= (b.profession or "Fishing") then
            return (a.profession or "Fishing") < (b.profession or "Fishing")
        end
        return a.name < b.name
    end)
    ClearDynamic(panel)
    panel.pageTitle:SetText(FF:LocalizedText("settings.copy.master-chef-78f9"))
    self:RenderMasterChefStatus("campfire", self.masterChefCampMessage
        or self.masterChefCampQueueMessage)
    panel.campRows = panel.campRows or {}
    panel.campDetails = panel.campDetails or {}
    local skills = panel.journalSkills or self:GetJournalSkills()
    for name, stat in pairs(campSkills) do
        if type(name) == "string" and not skills[name] then skills[name] = stat end
    end
    local y = 0
    for index, camp in ipairs(camps) do
        local row = panel.campRows[camp.id]
        if not row then row = ChefCampRow(panel, camp); panel.campRows[camp.id] = row end
        row.camp = camp
        row.contentY = y
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        LayoutChefRow(panel, row, "camp", self:GetJournalItemDisplayName(camp.id,camp.name))
        row.bg:SetColorTexture(0.67, 0.51, 0.30, index % 2 == 1 and 0.18 or 0.08)
        local status = statuses[camp.id]
        local unlearned = status.order == 4
        local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(camp.id)
        if not icon and GetItemIcon then icon = GetItemIcon(camp.id) end
        row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.icon:SetDesaturated(unlearned)
        row.icon:SetAlpha(unlearned and 0.48 or 1)
        self:FrameJournalRoundIcon(row.icon,36,unlearned)
        row.name:SetTextColor(unlearned and 0.48 or INK[1],
            unlearned and 0.43 or INK[2], unlearned and 0.37 or INK[3])
        local profession = camp.profession or "Fishing"
        local skillLabel = self:GetJournalChefSkillText(profession,camp.skill,JournalStage(panel)=="minimum")
        row.skill:SetText(unlearned and skillLabel
            or ColorRequirement(skills, skillLabel, profession, camp.skill))
        FitTranslatedChefSkill(panel,row,"camp")
        row.skill:SetTextColor(unlearned and 0.48 or SOFT_INK[1],
            unlearned and 0.43 or SOFT_INK[2], unlearned and 0.37 or SOFT_INK[3])
        row.campLearned = status.learned
        local borderHeight = row:GetHeight()
        row.campMissingTool = camp.toolID and (status.toolCount or 0) < 1
        local availableCrafts = status.learned and self:GetMasterChefCampAvailableCrafts(camp.id, display) or 0
        row.craft:SetShown(status.learned and availableCrafts > 0)
        row.craftHint:SetShown(status.learned and availableCrafts == 0)
        row.amountSlider:SetShown(status.learned and availableCrafts > 0)
        row.amount:SetShown(status.learned and availableCrafts > 0)
        if status.learned then
            RefreshChefQuantityControls(row, panel, "camp", camp.id, availableCrafts)
        end
        local combat = InCombatLockdown and InCombatLockdown()
        if not combat then
            if not row.placeReady then
                row.place:SetAttribute("useOnKeyDown", false)
                row.place:SetAttribute("type", "item")
                row.place:SetAttribute("type1", "item")
                row.place:SetAttribute("item", "item:" .. camp.id)
                row.place:SetAttribute("item1", "item:" .. camp.id)
                row.placeReady = true
            end
            row.place:SetShown(status.owned > 0)
            row.place:EnableMouse(status.owned > 0)
        end
        row.place.label:SetText(FF:LocalizedText("chef.ui.place"))
        row.craftAvailable = status.learned and availableCrafts > 0
        row.craft:EnableMouse(row.craftAvailable)
        row.craft:SetAlpha(row.craftAvailable and 1 or 0.38)
        row.place:SetAlpha(combat and 0.38 or 1)
        SetJournalChevron(row.indicator, panel.expandedCamp == camp.id)
        AddDynamic(panel, row)
        y = y + row:GetHeight()
        if panel.expandedCamp == camp.id then
            local detail = panel.campDetails[camp.id]
            if not detail then detail = ChefCampDetail(panel); panel.campDetails[camp.id] = detail end
            FillChefCampDetail(detail, camp, status)
            detail:ClearAllPoints(); detail:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
            AddDynamic(panel, detail)
            borderHeight = row:GetHeight() + detail:GetHeight()
            y = y + detail:GetHeight() + 8
        end
        self:StyleLearnedJournalRow(row, status.learned == true, borderHeight)
    end
    local queue = ChefQueue(panel, "camp")
    LayoutChefQueue(panel, queue)
    local entries = self.masterChefCampCraftQueue or {}
    for index, line in ipairs(queue.rows) do line:SetShown(index < #entries) end
    for index = 2, #entries do
        local entry = entries[index]
        local lineIndex = index - 1
        local line = queue.rows[lineIndex]
        if not line then line = ChefQueueRow(queue.content, queue); queue.rows[lineIndex] = line end
        line:SetWidth(JournalWidth(panel))
        line.name:SetWidth(math.max(100, JournalWidth(panel) - 157))
        line.meal = nil; line.itemID = entry.itemID
        local camp
        for _, candidate in ipairs(self.masterChefCamps or {}) do
            if candidate.id == entry.itemID then camp = candidate; break end
        end
        line:ClearAllPoints(); line:SetPoint("TOPLEFT", queue.content, "TOPLEFT", 0, -(index - 2) * 27)
        line.name:SetText(self:GetJournalItemDisplayName(entry.itemID,camp and camp.name or FF:LocalizedText("journal.chrome.camp-hash",entry.itemID)))
        line.count:SetText("×" .. entry.quantity)
        local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(entry.itemID)
        if not icon and GetItemIcon then icon = GetItemIcon(entry.itemID) end
        line.iconTexture = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        line.icon:SetTexture(line.iconTexture)
        line:Show()
    end
    if #entries > 0 then
        local total = 0
        for _, entry in ipairs(entries) do total = total + entry.quantity end
        queue.total:SetText(FF:LocalizedText("chef.ui.to-craft",total))
        local nextCamp
        for _, candidate in ipairs(self.masterChefCamps or {}) do
            if candidate.id == entries[1].itemID then nextCamp = candidate; break end
        end
        local nextIcon = C_Item and C_Item.GetItemIconByID
            and C_Item.GetItemIconByID(entries[1].itemID)
        if not nextIcon and GetItemIcon then nextIcon = GetItemIcon(entries[1].itemID) end
        queue.nextIcon:SetTexture(nextIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        queue.next:SetText(FF:LocalizedText(self.masterChefCampCrafting and "chef.ui.next-crafting"
            or self.masterChefCampPreparing and "chef.ui.next-preparing" or "chef.ui.next",
            nextCamp and nextCamp.name or FF:LocalizedText("journal.chrome.camp-hash",entries[1].itemID), entries[1].quantity))
        queue.start.label:SetText(self.masterChefCampCrafting and FF:LocalizedText("chef.ui.crafting")
            or self.masterChefCampPreparing and FF:LocalizedText("chef.ui.preparing") or FF:LocalizedText("chef.ui.start"))
        queue.sound:RefreshLabel()
        local busy = self.masterChefCampCrafting or self.masterChefCampPreparing
        queue.start:EnableMouse(not busy)
        queue.start:SetAlpha(busy and 0.45 or 1)
        if #entries <= 1 then panel.campQueueExpanded = false end
        local expanded = panel.campQueueExpanded == true
        local notice = not busy and self:GetMasterChefMessage("masterChefCampQueueMessage")
        local remaining = #entries - 1
        local visibleRows = math.min(remaining, 3)
        local noticeHeight = ChefQueueNoticeHeight(panel,queue,notice)
        local height = ChefQueueHeaderHeight(panel,queue) + (expanded and (remaining > 0 or notice)
            and 8 + visibleRows * 27 + noticeHeight or 0)
        queue:ClearAllPoints()
        queue:SetPoint("BOTTOMLEFT", panel.page, "BOTTOMLEFT", 16, 16)
        queue:SetPoint("BOTTOMRIGHT", panel.page, "BOTTOMRIGHT", -16, 16)
        queue:SetHeight(height)
        SetChefQueueChevron(queue, expanded, #entries)
        queue.note:SetText(notice or "")
        queue.note:SetShown(expanded and notice and true or false)
        queue.list:SetShown(expanded and remaining > 0)
        queue.list:SetSize(JournalWidth(panel), visibleRows * 27)
        queue.content:SetHeight(math.max(1, remaining * 27))
        if queue.list.UpdateScrollChildRect then queue.list:UpdateScrollChildRect() end
        queue.list:SetVerticalScroll(math.min(queue.list:GetVerticalScroll(),
            queue.list:GetVerticalScrollRange()))
        queue:Show()
        panel.scroll:ClearAllPoints()
        local side = JournalScrollSide(panel)
        panel.scroll:SetPoint("TOPLEFT", panel.page, "TOPLEFT", side, JournalScrollTop(panel))
        panel.scroll:SetPoint("BOTTOMRIGHT", panel.page, "BOTTOMRIGHT", -side, 24 + height)
    else
        panel.campQueueExpanded = false
        queue.list:SetVerticalScroll(0)
    end
    SetCatchHeight(panel, math.max(1, y))
    panel.renderedTab = "chef"
end

local function CampPlaceError(message,errorID)
    local identity=FF:GetNativeErrorName(errorID)
    if identity=="SPELL_FAILED_ONLY_OUTDOORS" then return "Outdoor only", "chef.ui.outdoor" end
    if identity=="SPELL_FAILED_TOO_CLOSE" then return "Not enough room", "chef.ui.no-room" end
    if FF:MatchesNativeError(message,{"SPELL_FAILED_ONLY_OUTDOORS"}) then return "Outdoor only", "chef.ui.outdoor" end
    if FF:MatchesNativeError(message,{"SPELL_FAILED_TOO_CLOSE"}) then return "Not enough room", "chef.ui.no-room" end
    local lower = (message:gsub("[A-Z]",string.lower))
    if lower:find("indoors", 1, true) or lower:find("outdoors", 1, true)
        then return "Outdoor only", "chef.ui.outdoor" end
    if lower:find("not enough room", 1, true) or lower:find("not enough space", 1, true)
        or lower:find("too close", 1, true) then return "Not enough room", "chef.ui.no-room" end
    return "Can't place", "chef.ui.cant-place"
end

local GROUND_CAMPFIRE_ITEMS = { [279981] = true, [279961] = true, [279974] = true }

function FF:OnMasterChefUIError(message,errorID)
    local pending = self.masterChefCampPlacement or self.masterChefCampPlaceAttempt
    if pending then
        local label, messageKey = CampPlaceError(message,errorID)
        if not pending.error or pending.error == "Can't place" or label ~= "Can't place" then
            pending.error = label
            pending.errorKey = messageKey
            self:ShowMasterChefStatus(pending.view or "campfire", label, true, 3, messageKey)
        end
        if pending.groundPlacement and pending.targeting then
            -- An invalid ground click can report an error while the campfire
            -- reticle stays available for another attempt.
            pending.result = nil
            pending.awaitEndEvent = true
        else
            pending.result = "failed"
        end
        if self.masterChefCampPlacement then self:CheckMasterChefCampPlacement() end
        return
    end
    local panel = self.journalPanel
    if panel and panel:IsShown() and self.journalTab == "chef"
        and panel.chefView == "meals"
        and (self.masterChefCookingActive or self.masterChefOwnsCookingSession
            or (self.masterChefCookingAttemptAt and GetTime
                and GetTime() - self.masterChefCookingAttemptAt <= 1.5))
        and self:GetMasterChefCraftErrorKind(message,errorID)=="fire" then
        self:ShowMasterChefStatus("meals", "Need cooking fire", true, 3, "chef.ui.need-fire")
        ApplyChefStatus(self, "meals")
    end
end

function FF:CheckMasterChefCampPlacement(event, cancelledCast)
    local pending = self.masterChefCampPlacement
    if not pending then return end
    if event == "CURRENT_SPELL_CAST_CHANGED" and cancelledCast == true
        and pending.groundPlacement then
        pending.result = "cancelled"
        pending.endConfirmed = true
    end
    local targeting = SpellIsTargeting and SpellIsTargeting() or false
    if targeting then
        pending.targeting = true
        if pending.targetEndedAt then
            pending.error = nil
            pending.errorKey = nil
            pending.awaitEndEvent = nil
            pending.endConfirmed = nil
            if pending.groundPlacement then pending.result = nil end
        end
        pending.targetEndedAt = nil
        return
    end
    if pending.targeting then pending.targetEndedAt = pending.targetEndedAt or pending.ticks end
    local casting = UnitCastingInfo and UnitCastingInfo("player")
    if casting then return end
    if pending.groundPlacement and pending.targeting then
        if pending.result == "cancelled" then
            self:FinishMasterChefCampPlacement()
        elseif pending.endConfirmed and pending.targetEndedAt
            and pending.ticks - pending.targetEndedAt >= 5 then
            self:FinishMasterChefCampPlacement()
        elseif not pending.awaitEndEvent and pending.targetEndedAt
            and pending.ticks - pending.targetEndedAt >= 5 then
            -- Campfire reticles can briefly drop targeting after an invalid
            -- ground click. After an error, wait for an actual end event instead.
            self:FinishMasterChefCampPlacement()
        end
        return
    end
    -- Once a ground cursor has appeared, only its departure (or a matching
    -- spell/error result after departure) can restore the Journal. The short
    -- fallback applies solely to item uses that never entered targeting.
    if (pending.targetEndedAt and pending.result)
        or (pending.targetEndedAt and pending.ticks - pending.targetEndedAt >= 2)
        or (not pending.targeting and pending.ticks >= 4) then
        self:FinishMasterChefCampPlacement()
    end
end

-- Capture errors arriving inside the secure action, without hiding its owner
-- before PostClick can promote this attempt to a watched placement.
function FF:ArmMasterChefCampPlacement(itemID, view, trayButton)
    self.masterChefCampPlacement = nil
    self:ClearMasterChefStatus(view)
    local attempt = {itemID=itemID, view=view, tray=trayButton and true or nil,
        button=trayButton}
    self.masterChefCampPlaceAttempt = attempt
    if C_Timer and C_Timer.After then
        C_Timer.After(0.5, function()
            if self.masterChefCampPlaceAttempt == attempt then
                self.masterChefCampPlaceAttempt = nil
            end
        end)
    end
    return attempt
end

function FF:BeginMasterChefCampPlacement(itemID)
    local panel = self.journalPanel
    local fromJournal = panel and panel:IsShown() and self.journalTab == "chef"
        and (panel.chefView == "campfire" or panel.chefView == "meals"
            and itemID == 279981)
    local pending = self.masterChefCampPlaceAttempt
    local fromTray = self.masterChefTray and self.masterChefTray:IsShown()
        and ((self.masterChefTray.placeItems and self.masterChefTray.placeItems[itemID])
            or (pending and pending.tray and pending.itemID == itemID))
    if not fromJournal and not fromTray then
        if pending and pending.itemID == itemID then self.masterChefCampPlaceAttempt = nil end
        return false
    end
    if not pending or pending.itemID ~= itemID then pending = { itemID = itemID } end
    pending.view = fromTray and "campfire" or panel.chefView
    pending.tray = fromTray and true or nil
    if fromJournal then
        pending.compact = panel.compactChef == true
        pending.scroll = panel.scroll:GetVerticalScroll()
    end
    self.masterChefCampPlacement = pending
    self.masterChefCampPlaceAttempt = nil
    -- PostClick runs after the secure item action. Hide before checking game
    -- state or formatting feedback so neither can delay this visual response.
    if fromTray then self:SuspendMasterChefQuickTray()
    else panel:Hide() end
    pending.groundPlacement = GROUND_CAMPFIRE_ITEMS[itemID] == true
    pending.ticks = 0
    pending.targeting = SpellIsTargeting and SpellIsTargeting() or false
    self:ShowMasterChefStatus(pending.view, "Ready to place", false, 1, "chef.ui.ready-place")
    local function Watch()
        if self.masterChefCampPlacement ~= pending then return end
        pending.ticks = pending.ticks + 1
        self:CheckMasterChefCampPlacement()
        if self.masterChefCampPlacement == pending and C_Timer and C_Timer.After then
            C_Timer.After(0.1, Watch)
        end
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.1, Watch)
    else self:FinishMasterChefCampPlacement() end
    return true
end

function FF:FinishMasterChefCampPlacement()
    local pending = self.masterChefCampPlacement
    if not pending then return end
    self.masterChefCampPlacement = nil
    self.masterChefCampPlaceAttempt = nil
    local view = pending.view or "campfire"
    if pending.result == "success" then
        self:ShowMasterChefStatus(view, "Place complete", false, 4, "chef.ui.place-complete")
    elseif pending.result == "cancelled" then
        self:ShowMasterChefStatus(view, "Place cancelled", false, 4, "chef.ui.place-cancelled")
    elseif pending.error then
        self:ShowMasterChefStatus(view, pending.error, true, 3, pending.errorKey)
    elseif pending.targeting then
        self:ShowMasterChefStatus(view, "Place cancelled", false, 2, "chef.ui.place-cancelled")
    else
        self:ShowMasterChefStatus(view, "Can't place", true, 2, "chef.ui.cant-place")
    end
    if pending.tray then
        if self.bar and self.bar:IsShown() and self.ShowMasterChefQuickTray then
            self:ShowMasterChefQuickTray(true)
        end
        return
    end
    local panel = self.journalPanel
    if not panel or panel:IsShown() then return end
    self.journalTab = "chef"
    panel.chefView = view
    panel.tabScrollOffsets = panel.tabScrollOffsets or {}
    panel.tabScrollOffsets.chef = pending.scroll
    if pending.compact then self:ShowCompactMasterChef()
    else self:ShowJournal() end
end

function FF:RenderMasterChef()
    local panel = self.journalPanel
    panel.chefView = panel.chefView or "campfire"
    for view, button in pairs(panel.chefViewButtons) do
        local selected = view == panel.chefView
        button.bg:SetColorTexture(0.27, 0.18, 0.08, selected and 0.32 or 0.12)
        button.label:SetTextColor(selected and 0.47 or SOFT_INK[1], selected and 0.28 or SOFT_INK[2],
            selected and 0.08 or SOFT_INK[3])
    end
    if panel.chefView == "guide" then self:RenderMasterChefGuide()
    elseif panel.chefView == "meals" then self:RenderMasterChefMeals()
    else self:RenderMasterChefCampfire() end
end

local function ReleaseUnusedChefPreparation(targetTab, targetView)
    local cookingView = targetTab == "chef"
        and (targetView == "meals" or targetView == "campfire" or not targetView)
    if not cookingView and FF.masterChefOwnsCookingSession
        and not FF.masterChefCookingActive
        and not (FF.masterChefCookingQueue or {})[1] then
        FF:ReleaseMasterChefCookingSession()
    end
    if not (targetTab == "chef" and targetView == "campfire")
        and FF.masterChefOwnsCampSession and not FF.masterChefCampCrafting
        and not (FF.masterChefCampCraftQueue or {})[1] then
        if not (targetTab == "chef" and targetView == "meals"
            and FF:UseMasterChefCampCookingPreparation()) then
            FF:ReleaseMasterChefCampSession()
        end
    end
end

function FF:SelectMasterChefView(view, manual)
    local panel = self.journalPanel
    if not panel then return end
    if manual then
        if self.DismissJournalSearch then self:DismissJournalSearch(true) end
        panel.backHistory = nil
        UpdateJournalBackButton(panel)
    end
    local targetView = (view == "guide" or view == "meals") and view or "campfire"
    ReleaseUnusedChefPreparation("chef", targetView)
    panel.chefView = targetView
    if manual then self:PrepareMasterChefJournalView(targetView) end
    panel.scroll:SetVerticalScroll(0)
    self:RenderMasterChef()
end

local EVENT_GAP = 16
local EVENT_FRAME_CLEARANCE = 6

local function EventGuideSection(row, panel)
    local section = CreateFrame("Frame", nil, row)
    section:SetWidth(530)
    EnableGuideLinks(section, panel)
    section.heading = Readable(PaperText(section, "GameFontNormal", "TOPLEFT",
        section, "TOPLEFT", 14, 0, ""), 15)
    section.heading:SetWordWrap(true); section.heading:SetJustifyH("CENTER")
    section.heading:SetTextColor(unpack(CATCH_HEADING_INK))
    section.body = Readable(PaperText(section, "GameFontHighlight", "TOPLEFT",
        section, "TOPLEFT", 14, -24, ""), 14)
    section.body:SetWordWrap(true); section.body:SetJustifyH("LEFT")
    section.body:SetJustifyV("TOP"); section.body:SetSpacing(2)
    section.body:SetTextColor(unpack(SOFT_INK))
    local divider = section:CreateTexture(nil, "BORDER")
    divider:SetPoint("BOTTOMLEFT", section, "BOTTOMLEFT", 14, 4)
    divider:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", -14, 4)
    divider:SetHeight(1); divider:SetColorTexture(0.43, 0.26, 0.10, 0.20)
    section.divider = divider
    return section
end

local function UpcomingEventRow(panel)
    local row = CreateFrame("Frame", nil, panel.content)
    row.pooled = true; row:SetSize(530, 80)
    -- Contain the 20-unit flourishes' horizontal outsets in the viewport.
    -- Vertical outsets use the list's leading clearance and inter-card gap.
    row.chrome = CreateFrame("Frame", nil, row); row.chrome:EnableMouse(false)
    row.chrome:SetPoint("TOPLEFT", row, "TOPLEFT", EVENT_FRAME_CLEARANCE, 0)
    row.chrome:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -EVENT_FRAME_CLEARANCE, 0)
    row.chrome:SetFrameLevel(row:GetFrameLevel())
    row.bg = Surface(row.chrome, 0.85, 0.64, 0.38, 0.13)
    row.border = FF:CreateJournalFrame(row.chrome)
    FF:StyleJournalEventFrame(row.border, true)
    local header = CreateFrame("Button", nil, row)
    header:SetSize(528, 80)
    header:SetPoint("TOPLEFT", row, "TOPLEFT", 1, 0)
    header:RegisterForClicks("LeftButtonUp")
    local hover = header:CreateTexture(nil, "HIGHLIGHT")
    hover:SetPoint("TOPLEFT", header, "TOPLEFT", EVENT_FRAME_CLEARANCE - 1, 0)
    hover:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 1 - EVENT_FRAME_CLEARANCE, 0)
    hover:SetColorTexture(0.48, 0.30, 0.13, 0.07)
    header:SetHighlightTexture(hover)
    row.header = header
    row.title = Readable(PaperText(header, "GameFontNormalLarge", "TOPLEFT", header, "TOPLEFT", 42, -9, ""), 17)
    row.title:SetWordWrap(true); row.title:SetJustifyH("CENTER"); row.title:SetJustifyV("TOP")
    row.title:SetTextColor(0.29, 0.15, 0.055)
    row.now = Readable(PaperText(header, "GameFontNormal", "TOPLEFT", header, "TOPLEFT", 10, -10, FF:LocalizedText("events.now")), 11)
    row.now:SetTextColor(0.40, 0.28, 0.10)
    row.times = CreateFrame("Frame", nil, header); row.times:EnableMouse(false)
    row.realmLabel = Readable(PaperText(row.times, "GameFontHighlight", "TOPLEFT", row.times, "TOPLEFT", 0, 0, FF:LocalizedText("events.realm")), 14)
    row.localLabel = Readable(PaperText(row.times, "GameFontHighlight", "TOPLEFT", row.times, "TOPLEFT", 0, -20, FF:LocalizedText("events.local")), 14)
    row.realm = Readable(PaperText(row.times, "GameFontHighlight", "TOPLEFT", row.times, "TOPLEFT", 58, 0, ""), 14)
    row.localTime = Readable(PaperText(row.times, "GameFontHighlight", "TOPLEFT", row.times, "TOPLEFT", 58, -20, ""), 14)
    for _, label in ipairs({ row.realmLabel, row.localLabel }) do
        label:SetWordWrap(false); label:SetJustifyH("LEFT"); label:SetJustifyV("TOP")
        label:SetTextColor(unpack(SOFT_INK))
    end
    for _, value in ipairs({ row.realm, row.localTime }) do
        value:SetWordWrap(true); value:SetJustifyH("LEFT"); value:SetJustifyV("TOP")
        value:SetTextColor(unpack(INK))
    end
    row.toggle = CreateFrame("Button", nil, header); row.toggle:SetSize(30, 28)
    row.toggle:RegisterForClicks("LeftButtonUp")
    row.indicator = row.toggle:CreateTexture(nil, "ARTWORK")
    row.indicator:SetSize(16, 9); row.indicator:SetPoint("CENTER", row.toggle, "CENTER", 0, 0)
    local rule = row:CreateTexture(nil, "BORDER")
    rule:SetPoint("TOPLEFT", row, "TOPLEFT", 14, -80)
    rule:SetPoint("TOPRIGHT", row, "TOPRIGHT", -14, -80)
    rule:SetHeight(1); rule:SetColorTexture(0.43, 0.26, 0.10, 0.25); row.rule = rule
    row.sections = {}
    local function Toggle()
        local previousScroll = panel.scroll:GetVerticalScroll()
        if row.expanded then panel.expandedEvent = nil else panel.expandedEvent = row.event.id end
        FF:RenderUpcomingEvents()
        panel.scroll:SetVerticalScroll(math.min(previousScroll, panel.scroll:GetVerticalScrollRange()))
    end
    header:SetScript("OnClick", Toggle); row.toggle:SetScript("OnClick", Toggle)
    for _, receiver in ipairs({ row, header, row.toggle }) do CatchListWheel(panel, receiver) end
    return row
end

-- Measure both columns together. Their compact shared origin stays centred;
-- only the values wrap when a date/time range needs another line.
local function LayoutEventSummary(row, panel, event, width)
    local headerWidth = width - 2
    row.header:SetWidth(headerWidth)
    Readable(row.title, JournalTextSize(panel, 17, 14)); row.title:SetText(FF:GetFishingEventDisplayText(event,"title"))
    local translated=FF:GetResolvedLocale()~="enUS"
    row.now:SetText(FF:LocalizedText("events.now"));row.realmLabel:SetText(FF:LocalizedText("events.realm"));row.localLabel:SetText(FF:LocalizedText("events.local"))
    row.now:SetWidth(0)
    if translated then row.now:SetWordWrap(true);row.now:SetWidth(math.min(70,math.ceil(row.now:GetStringWidth()))) end
    local side=translated and event.active and math.max(42,row.now:GetWidth()+18) or 42
    local titleWidth = headerWidth - 2*side
    row.title:SetWidth(titleWidth)
    row.title:ClearAllPoints()
    row.title:SetPoint("TOP", row.header, "TOP", 0, -9)
    local titleHeight = math.max(row.title:GetStringHeight(),translated and event.active and row.now:GetStringHeight()+1 or 0)
    row.now:SetShown(event.active)
    row.toggle:ClearAllPoints()
    row.toggle:SetPoint("RIGHT", row.header, "RIGHT", -6, 0)
    local realmTime, localTime = FF:GetFishingEventTimeDisplay(event)
    row.realm:SetText(realmTime)
    row.localTime:SetText(localTime)
    local labelWidth, valueWidth = 0, 0
    for _, font in ipairs({ row.realmLabel, row.localLabel, row.realm, row.localTime }) do
        Readable(font, JournalTextSize(panel, 14, 12))
        font:SetWidth(0)
    end
    labelWidth = math.ceil(math.max(row.realmLabel:GetStringWidth(), row.localLabel:GetStringWidth()))
    if translated then labelWidth=math.min(labelWidth,math.max(30,math.floor(headerWidth*.3))) end
    row.realmLabel:SetWordWrap(translated);row.localLabel:SetWordWrap(translated)
    valueWidth = math.ceil(math.min(headerWidth - 28 - labelWidth - 8,
        math.max(row.realm:GetStringWidth(), row.localTime:GetStringWidth()) + 1))
    row.times:SetWidth(labelWidth + 8 + valueWidth)
    row.times:ClearAllPoints(); row.times:SetPoint("TOP", row.header, "TOP", 0, -9 - titleHeight - 6)
    local timeHeight = 0
    for index, fields in ipairs({ { row.realmLabel, row.realm }, { row.localLabel, row.localTime } }) do
        local label, value = fields[1], fields[2]
        label:SetWidth(labelWidth); value:SetWidth(valueWidth)
        label:ClearAllPoints(); label:SetPoint("TOPLEFT", row.times, "TOPLEFT", 0, -timeHeight)
        value:ClearAllPoints(); value:SetPoint("TOPLEFT", row.times, "TOPLEFT", labelWidth + 8, -timeHeight)
        timeHeight = timeHeight + math.max(label:GetStringHeight(), value:GetStringHeight()) + (index == 1 and 3 or 0)
    end
    row.times:SetHeight(timeHeight)
    row.headerHeight = math.ceil(9 + titleHeight + 6 + timeHeight + 10)
    row.header:SetHeight(row.headerHeight)
    row.rule:ClearAllPoints()
    row.rule:SetPoint("TOPLEFT", row, "TOPLEFT", 14, -row.headerHeight)
    row.rule:SetPoint("TOPRIGHT", row, "TOPRIGHT", -14, -row.headerHeight)
    row.rule:SetShown(row.expanded)
    return row.headerHeight
end

function FF:RenderUpcomingEvents()
    local panel = self.journalPanel
    ClearDynamic(panel)
    panel.eventRows, panel.eventGuideCards = panel.eventRows or {}, {}
    panel.pageTitle:SetText(FF:LocalizedText("journal.events-title"))
    SetJournalPageSubtitle(panel, FF:LocalizedText("journal.events-subtitle"))
    local events = self:GetUpcomingFishingEvents()
    local y = EVENT_FRAME_CLEARANCE
    if #events == 0 then
        local note = AddDynamic(panel, Readable(PaperText(panel.content, "GameFontHighlight", "TOPLEFT",
            panel.content, "TOPLEFT", 13, -15, FF:LocalizedText("events.unavailable")), 14))
        note:SetWidth(math.max(180, JournalWidth(panel) - 30))
        note:SetTextColor(unpack(SOFT_INK))
        panel.content:SetHeight(self:GetResolvedLocale()~="enUS" and math.max(65,15+note:GetStringHeight()+10) or 65)
        return
    end
    local skills = panel.journalSkills or self:GetJournalSkills()
    for index, event in ipairs(events) do
        local expanded = panel.expandedEvent == event.id
        local row = panel.eventRows[index]
        if not row then row = UpcomingEventRow(panel); panel.eventRows[index] = row end
        local width = JournalWidth(panel)
        row:SetWidth(width)
        -- Link/search scroll targets include the upper corner outsets.
        row.event, row.expanded, row.contentY = event, expanded, y - EVENT_FRAME_CLEARANCE
        row:ClearAllPoints(); row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        row.bg:SetColorTexture(0.85, 0.64, 0.38, expanded and 0.17 or 0.13)
        SetJournalChevron(row.indicator, expanded)
        for _, section in ipairs(row.sections) do section:Hide() end
        if row.guideFooter then row.guideFooter:Hide() end
        local rowHeight = LayoutEventSummary(row, panel, event, width)
        if expanded then
            rowHeight = rowHeight + 10
            -- Keep readable columns as Text Size grows; paired headings and
            -- body starts share measured row anchors, even with long headings.
            local paired=width >= 485 * self:GetJournalTextScale()
            row.eventPaired=paired
            local columns=paired and 2 or 1
            local sectionWidth=width/columns
            for first=1,#event.blocks,columns do
                local last=math.min(first+columns-1,#event.blocks)
                local headingHeight,pairHeight=0,0
                for blockIndex=first,last do
                    local block=event.blocks[blockIndex]
                    local section=row.sections[blockIndex]
                    if not section then section=EventGuideSection(row,panel); row.sections[blockIndex]=section end
                    section:SetWidth(sectionWidth)
                    section.heading:SetWidth(sectionWidth-28); section.body:SetWidth(sectionWidth-28)
                    Readable(section.heading,JournalTextSize(panel,15,13))
                    Readable(section.body,JournalTextSize(panel,14,12))
                    section.heading:SetText(self:LocalizeReferenceZones(self:GetFishingEventDisplayText(event,"heading",block)))
                    local body,projected=self:GetFishingEventDisplayText(event,"body",block,skills)
                    local linked=LinkText(section,body)
                    section.body:SetText(projected and linked or ColorGuideSkills(skills,linked,"Fishing"))
                    headingHeight=math.max(headingHeight,section.heading:GetStringHeight())
                end
                for blockIndex=first,last do
                    local section=row.sections[blockIndex]
                    section:ClearAllPoints()
                    section:SetPoint("TOPLEFT",row,"TOPLEFT",(blockIndex-first)*sectionWidth,-rowHeight)
                    section.body:ClearAllPoints(); section.body:SetPoint("TOPLEFT",section,"TOPLEFT",14,-headingHeight-6)
                    pairHeight=math.max(pairHeight,headingHeight+6+section.body:GetStringHeight()+14)
                end
                for blockIndex=first,last do
                    local section=row.sections[blockIndex]
                    section:SetHeight(pairHeight); section.divider:SetShown(last<#event.blocks)
                    section:Show(); panel.eventGuideCards[#panel.eventGuideCards+1]=section
                end
                rowHeight=rowHeight+pairHeight
            end
            if event.guideTarget then
                if not row.guideFooter then
                    local footer=CreateFrame("Frame",nil,row); EnableGuideLinks(footer,panel)
                    footer.body=Readable(PaperText(footer,"GameFontHighlight","TOPLEFT",footer,"TOPLEFT",14,0,""),13)
                    footer.body:SetWordWrap(true); footer.body:SetJustifyH("LEFT"); footer.body:SetTextColor(unpack(SOFT_INK))
                    row.guideFooter=footer
                end
                local footer=row.guideFooter
                footer:SetWidth(width); Readable(footer.body,JournalTextSize(panel,13,12))
                footer.body:SetWidth(width-28)
                footer.body:SetText(self:GuideTargetLink(event.guideTarget,self:GetFishingEventDisplayText(event,"footer")))
                footer:ClearAllPoints(); footer:SetPoint("TOPLEFT",row,"TOPLEFT",0,-rowHeight-2)
                local footerHeight=footer.body:GetStringHeight()+10
                footer:SetHeight(footerHeight); footer:Show(); rowHeight=rowHeight+2+footerHeight
            end
            rowHeight = rowHeight + 2
        end
        row:SetHeight(rowHeight)
        self:StyleJournalPanelBorder(row.border,true,width-2*EVENT_FRAME_CLEARANCE,rowHeight)
        AddDynamic(panel, row)
        y = y + rowHeight + EVENT_GAP
    end
    local note = AddDynamic(panel, Readable(PaperText(panel.content, "GameFontHighlight", "TOPLEFT",
        panel.content, "TOPLEFT", 13, -y - 8, FF:LocalizedText("events.schedule-note")), 13))
    note:SetWidth(math.max(180, JournalWidth(panel) - 30))
    note:SetTextColor(unpack(SOFT_INK))
    note:SetWordWrap(true)
    panel.content:SetHeight(y + 8 + note:GetStringHeight() + 10)
end

local function AchievementRow(panel)
    local row = CreateFrame("Button", nil, panel.content)
    row.pooled = true; row:RegisterForClicks("LeftButtonUp")
    row.bg = Surface(row, 0.55, 0.40, 0.20, 0.07)
    row.border = FF:CreateJournalFrame(row)
    row.art = CreateFrame("Frame",nil,row); row.art:SetSize(52,52)
    row.art:SetPoint("TOPLEFT",row,"TOPLEFT",12,-12)
    row.icon = row.art:CreateTexture(nil, "ARTWORK")
    row.icon:SetPoint("TOPLEFT",row.art,"TOPLEFT",3,-3)
    row.icon:SetPoint("BOTTOMRIGHT",row.art,"BOTTOMRIGHT",-3,3)
    row.art.border = FF:CreateJournalFrame(row.art,false,10)
    -- The notice retains its title plaque. A page card needs just one frame.
    row.plaque = CreateFrame("Frame",nil,row); row.plaque:EnableMouse(false)
    row.plaque:SetPoint("TOPLEFT", row, "TOPLEFT", 74, -12)
    row.plaque.title = Readable(PaperText(row.plaque,"GameFontNormalLarge","TOPLEFT",row.plaque,"TOPLEFT",0,0,""),17)
    row.plaque.title:SetJustifyH("LEFT"); row.plaque.title:SetWordWrap(true)
    row.plaque.check = row:CreateTexture(nil,"ARTWORK")
    row.plaque.check:SetSize(18,18); row.plaque.check:SetPoint("TOPRIGHT",row,"TOPRIGHT",-30,-12)
    row.plaque.check:SetTexture("Interface\\AddOns\\ForeverFishing\\Media\\JournalCheck.tga")
    row.plaque.check:SetVertexColor(0.22,0.40,0.25)
    row.requirement = Readable(PaperText(row, "GameFontHighlight", "TOPLEFT", row.plaque, "BOTTOMLEFT", 0, -32, ""), 14)
    row.requirement:SetJustifyH("LEFT"); row.requirement:SetTextColor(unpack(INK))
    row.requirement:SetWordWrap(true)
    row.progress = Readable(PaperText(row, "GameFontNormal", "TOPRIGHT", row.plaque, "BOTTOMRIGHT", 0, -7, ""), 13)
    row.progress:SetJustifyH("RIGHT")
    row.progress:SetWordWrap(false)
    if row.progress.SetMaxLines then row.progress:SetMaxLines(1) end
    row.progress:SetTextColor(unpack(SOFT_INK))
    row.indicator = row:CreateTexture(nil, "ARTWORK"); row.indicator:SetSize(12, 7)
    row.indicator:SetPoint("TOPRIGHT", row, "TOPRIGHT", -9, -17)
    row.detail = Readable(PaperText(row, "GameFontHighlight", "TOPLEFT", row.requirement, "BOTTOMLEFT", 0, -12, ""), 13)
    row.detail:SetJustifyH("LEFT"); row.detail:SetWordWrap(true); row.detail:SetTextColor(unpack(SOFT_INK))
    row.bar = CreateFrame("Frame",nil,row)
    row.bar:EnableMouse(false); row.bar:SetHeight(12)
    row.track = row.bar:CreateTexture(nil, "BACKGROUND")
    row.track:SetAllPoints(row.bar); row.track:SetHeight(12)
    row.track:SetColorTexture(0.12,0.085,0.045,0.8)
    row.bar.border = FF:CreateJournalFrame(row.bar,false,6)
    row.fill = row.bar:CreateTexture(nil, "ARTWORK")
    row.fill:SetPoint("TOPLEFT", row.bar, "TOPLEFT", 1, -1); row.fill:SetHeight(10)
    row.focus = row:CreateTexture(nil, "OVERLAY")
    row.focus:SetPoint("TOPLEFT"); row.focus:SetPoint("BOTTOMLEFT"); row.focus:SetWidth(3)
    row.focus:SetColorTexture(0.95,0.68,0.22,0.9)
    -- No item ID, item hover, tooltip owner or comparison event is attached.
    row:SetScript("OnClick", function(button)
        panel.expandedAchievements = panel.expandedAchievements or {}
        panel.expandedAchievements[button.achievementID] = not panel.expandedAchievements[button.achievementID]
        local scroll = panel.scroll:GetVerticalScroll()
        FF:RenderAchievements()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end)
    return row
end

function FF:RenderAchievements()
    local panel = self.journalPanel
    if not self.achievementStates then self:RefreshFishingAchievements(false, true) end
    ClearDynamic(panel)
    panel.achievementRows = panel.achievementRows or {}
    panel.expandedAchievements = panel.expandedAchievements or {}
    panel.pageTitle:SetText(FF:LocalizedText("journal.achievements"))
    SetJournalPageSubtitle(panel,self:LocalizedText("achievement.completed-count",self.achievementsCompleted or 0,#self.achievementDefinitions))
    panel.renderedTab, panel.achievementRevision = "achievements", self.achievementRevision
    local width, y = JournalWidth(panel), 0
    -- One measured count column for the entire page. The check slot is also
    -- reserved for unearned cards, keeping every progress track aligned.
    local countWidth = 72
    for index, state in ipairs(self.achievementStates or {}) do
        local row = panel.achievementRows[index]
        if not row then row = AchievementRow(panel); panel.achievementRows[index] = row end
        Readable(row.progress, JournalTextSize(panel, 13, 12))
        row.progress:SetWidth(0)
        row.progress:SetText(state.target > 0 and (math.min(state.current,state.target) .. " / " .. state.target) or "—")
        countWidth = math.max(countWidth, (row.progress.GetStringWidth and row.progress:GetStringWidth()
            or #row.progress:GetText() * 8 * self:GetJournalTextScale()) + 2)
    end
    for index, state in ipairs(self.achievementStates or {}) do
        local definition = state.definition
        local row = panel.achievementRows[index]
        if not row then row = AchievementRow(panel); panel.achievementRows[index] = row end
        row.achievementID, row.contentY, row.state = definition.id, y, state
        row:SetWidth(width); row:ClearAllPoints(); row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        row.icon:SetTexture(self.achievementTextures[definition.id])
        row.icon:SetDesaturated(false); row.icon:SetAlpha(1)
        -- The 18-unit progress/count lane leaves 3 units around the 12-unit
        -- bar. Tighten both text gaps by 6, retaining measured wrapping.
        local padding, textX, textWidth = 10, 74, width - 108
        row.plaque:ClearAllPoints(); row.plaque:SetPoint("TOPLEFT",row,"TOPLEFT",textX,-padding)
        row.plaque:SetWidth(textWidth)
        Readable(row.plaque.title, JournalTextSize(panel, 16, 14))
        row.plaque.title:SetWidth(textWidth); row.plaque.title:SetText(self:GetAchievementDisplayText(definition,"title"))
        row.plaque.title:SetTextColor(unpack(INK))
        row.plaque:SetHeight(row.plaque.title:GetStringHeight())
        row.plaque.check:SetShown(state.earned ~= nil)
        Readable(row.requirement, JournalTextSize(panel, 14, 12))
        Readable(row.progress, JournalTextSize(panel, 13, 12))
        Readable(row.detail, JournalTextSize(panel, 13, 12))
        row.requirement:SetWidth(textWidth); row.requirement:SetText(self:GetAchievementDisplayText(definition,"description"))
        row.progress:SetWidth(countWidth)
        local progressHeight = math.max(18, row.progress:GetStringHeight())
        local progressCenter = padding + row.plaque:GetHeight() + progressHeight / 2
        local barWidth = textWidth - countWidth - 18 - 6 - 10
        row.bar:ClearAllPoints(); row.bar:SetWidth(barWidth)
        row.bar:SetPoint("TOPLEFT",row,"TOPLEFT",textX,-progressCenter+6)
        row.track:SetWidth(barWidth)
        row.progress:ClearAllPoints()
        row.progress:SetPoint("RIGHT",row,"TOPRIGHT",-58,-progressCenter)
        row.plaque.check:ClearAllPoints()
        row.plaque.check:SetPoint("RIGHT",row,"TOPRIGHT",-34,-progressCenter)
        local descriptionY = progressCenter + progressHeight / 2
        row.requirement:ClearAllPoints()
        row.requirement:SetPoint("TOPLEFT",row,"TOPLEFT",textX,-descriptionY)
        local expanded = panel.expandedAchievements[definition.id] == true
        row.detail:SetShown(expanded); row.detail:SetWidth(textWidth)
        local descriptionBottom = descriptionY + row.requirement:GetStringHeight()
        -- Short cards retain 8-unit clearance around the unchanged icon frame.
        local summaryHeight = math.max(52 + 16, descriptionBottom + padding)
        row.summaryHeight = summaryHeight
        row.art:ClearAllPoints(); row.art:SetPoint("TOPLEFT",row,"TOPLEFT",12,-(summaryHeight-52)/2)
        row.indicator:ClearAllPoints(); row.indicator:SetPoint("RIGHT",row,"TOPRIGHT",-12,-progressCenter)
        local height = summaryHeight
        if expanded then
            row.detail:SetText(self:GetAchievementDetails(state))
            row.detail:ClearAllPoints(); row.detail:SetPoint("TOPLEFT",row,"TOPLEFT",textX,-descriptionBottom-8)
            height = math.max(summaryHeight, descriptionBottom + 8 + row.detail:GetStringHeight() + padding)
        end
        row:SetHeight(height)
        row.fill:SetWidth(math.max(0.01, (row.track:GetWidth() - 2) * (state.earned and 1 or state.target > 0 and math.min(1, state.current / state.target) or 0)))
        row.fill:SetShown(state.earned ~= nil or state.current > 0)
        row.fill:SetColorTexture(state.earned and 0.20 or 0.72,state.earned and 0.52 or 0.48,state.earned and 0.18 or 0.08,0.95)
        row.focus:SetShown(panel.focusedAchievement == definition.id)
        row.bg:SetColorTexture(0.55,0.40,0.20,state.earned and 0.12 or 0.055)
        SetJournalChevron(row.indicator, expanded)
        AddDynamic(panel, row)
        y = y + height + 8
    end
    SetCatchHeight(panel, math.max(1,y))
end

function FF:ShowAchievement(id)
    if not self.achievementsByID[id] or (InCombatLockdown and InCombatLockdown()) then return end
    self.journalTab = "achievements"
    self:ShowJournal()
    local panel = self.journalPanel
    if not panel then return end
    panel.backHistory = nil
    UpdateJournalBackButton(panel)
    panel.focusedAchievement = id
    panel.expandedAchievements = panel.expandedAchievements or {}
    panel.expandedAchievements[id] = true
    self:RenderAchievements()
    if panel.scroll.UpdateScrollChildRect then panel.scroll:UpdateScrollChildRect() end
    local row = panel.achievementRows[self.achievementsByID[id].order]
    panel.scroll:SetVerticalScroll(math.min(row.contentY, panel.scroll:GetVerticalScrollRange()))
end

local function RenderSelectedJournalPage(self, panel)
    if self.journalTab == "catch" then
        self:RenderCatchJournal()
    elseif self.journalTab == "achievements" then
        self:RenderAchievements()
    elseif self.journalTab == "session" then
        self:RenderSessionStats()
    elseif self.journalTab == "lifetime" then
        self:RenderLifetimeStats()
    elseif self.journalTab == "events" then
        self:RenderUpcomingEvents()
    elseif self.journalTab == "chef" then
        self:RenderMasterChef()
    else
        local found
        for _, tab in ipairs(self.guideTabs or {}) do
            if tab.id == self.journalTab then
                self:RenderGuide(tab)
                panel.renderedTab = self.journalTab
                found = true
                break
            end
        end
        if not found then self:RenderCatchJournal() end
    end
    if panel.scroll.UpdateScrollChildRect then panel.scroll:UpdateScrollChildRect() end
end

function FF:ReflowJournal()
    local panel = self.journalPanel
    if not panel or not panel:IsShown() or (InCombatLockdown and InCombatLockdown()) then return end
    local scroll = panel.scroll:GetVerticalScroll()
    RenderSelectedJournalPage(self, panel)
    panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
end

function FF:SelectJournalTab(id, manual)
    local panel = self.journalPanel
    ReleaseUnusedChefPreparation(id or "catch", panel and panel.chefView)
    self.journalTab = id or "catch"
    if not panel then return end
    if panel.nearbyZoneControls then panel.nearbyZoneControls:SetShown(self.journalTab=="nearby"); panel.nearbyZoneControls.menu:Hide() end
    if panel.sessionHistoryButton then panel.sessionHistoryButton:Hide() end
    UpdateChefHeading(panel)
    if manual and self.journalTab == "chef" then
        self:PrepareMasterChefJournalView(panel.chefView or "campfire")
    end
    if manual then
        if self.DismissJournalSearch then self:DismissJournalSearch(true) end
        panel.focusedAchievement = nil
        if self.journalTab == "session" then panel.sessionHistoryShown = nil end
        panel.backHistory = nil
        UpdateJournalBackButton(panel)
    end
    panel.tabScrollOffsets = panel.tabScrollOffsets or {}
    if panel.selectedTab then
        panel.tabScrollOffsets[panel.selectedTab] = panel.scroll:GetVerticalScroll()
    end
    panel.journalSkills = self:GetJournalSkills()
    if self.journalTab == "achievements" then self:RefreshFishingAchievements(false, true) end
    panel.skillSnapshot = SkillSnapshot(panel.journalSkills)
    panel.showAllButton:SetShown(self.journalTab == "catch")
    panel.campMilestonesButton:SetShown(self.journalTab == "leveling")
    panel.eventOrnament:SetShown(self.journalTab == "events")
    JournalLayout(panel)
    if panel.pageSubtitle.SetWordWrap then panel.pageSubtitle:SetWordWrap(true) end
    panel.pageSubtitle:SetTextColor(unpack(SOFT_INK))
    for _, button in pairs(panel.chefViewButtons) do button:SetShown(self.journalTab == "chef") end
    for tabID, button in pairs(panel.navTabs) do
        PaintWarmTab(button, tabID == self.journalTab)
    end
    self:StopJournalClock()
    panel.scroll:SetVerticalScroll(0)
    RenderSelectedJournalPage(self, panel)
    panel.scroll:SetVerticalScroll(math.min(panel.tabScrollOffsets[self.journalTab] or 0,
        panel.scroll:GetVerticalScrollRange()))
    panel.selectedTab = self.journalTab
    self:UpdateJournalClock()
end

function FF:ShowJournal(userClick)
    if InCombatLockdown and InCombatLockdown() and not self.journalPanel then return end
    if not self.journalPanel then self.journalPanel = CreateJournal() end
    if self.journalPanel.compactChef == true and InCombatLockdown
        and InCombatLockdown() then
        self.pendingJournalPresentation = "full"
        return
    end
    if InCombatLockdown and InCombatLockdown() then return end
    self.pendingJournalPresentation = nil
    SetJournalPresentation(self.journalPanel, false)
    local pending = self.masterChefCampPlacement
    if pending then
        -- The normal Journal button is a recovery path if this client misses
        -- the end of a ground-placement cursor.
        self.masterChefCampPlacement = nil
        self.masterChefCampPlaceAttempt = nil
        self.journalTab = "chef"
        self.journalPanel.chefView = pending.view or "campfire"
        self.journalPanel.tabScrollOffsets = self.journalPanel.tabScrollOffsets or {}
        self.journalPanel.tabScrollOffsets.chef = pending.scroll
        self:ClearMasterChefStatus(self.journalPanel.chefView)
    end
    if userClick and self.journalTab == "chef" then
        self:PrepareMasterChefJournalView(self.journalPanel.chefView or "campfire")
    end
    self:SelectJournalTab(self.journalTab or "catch")
    self:ShowFloatingWindow(self.journalPanel)
    self:UpdateJournalClock()
end

function FF:ShowCompactMasterChef(userClick, fromQuickTray)
    if InCombatLockdown and InCombatLockdown() and not self.journalPanel then return end
    if not self.journalPanel then self.journalPanel = CreateJournal() end
    local panel = self.journalPanel
    if panel.compactChef ~= true and InCombatLockdown and InCombatLockdown() then
        self.pendingJournalPresentation = "compact"
        return
    end
    if InCombatLockdown and InCombatLockdown() then return end
    self.pendingJournalPresentation = nil
    local pending = self.masterChefCampPlacement
    if pending then
        -- The bar shortcut can recover a missed placement-end event too.
        self.masterChefCampPlacement = nil
        self.masterChefCampPlaceAttempt = nil
        panel.chefView = pending.view or "campfire"
        panel.tabScrollOffsets = panel.tabScrollOffsets or {}
        panel.tabScrollOffsets.chef = pending.scroll
        self:ClearMasterChefStatus(panel.chefView)
    elseif not panel.compactChefOpened then
        panel.chefView = "meals"
    end
    panel.compactChefOpened = true
    SetJournalPresentation(panel, true)
    if (userClick or fromQuickTray) and self.masterChefCookingContextPending then
        self.masterChefCookingPendingView = panel.chefView or "campfire"
    end
    self:SelectJournalTab("chef")
    if userClick and not fromQuickTray then
        self:PrepareMasterChefJournalView(panel.chefView or "campfire")
    elseif fromQuickTray and self.masterChefOwnsCookingSession
        and self.masterChefCookingPrepared and self:IsMasterChefCookingSessionReady() then
        self:ShowMasterChefStatus(panel.chefView or "campfire", "Cooking prepared", false, 2, nil, true)
    end
    self:ShowFloatingWindow(panel)
end

function FF:ShowPendingJournalPresentation()
    local pending = self.pendingJournalPresentation
    if pending == "compact" then self:ShowCompactMasterChef()
    elseif pending == "full" then self:ShowJournal() end
end

function FF:ShowStats()
    if self.journalPanel then
        self.journalPanel.sessionHistoryShown = nil
        self.journalPanel.backHistory = nil
        UpdateJournalBackButton(self.journalPanel)
    end
    self.journalTab = "session"
    self:ShowJournal()
end

function FF:RefreshJournal()
    local panel = self.journalPanel
    if not panel or not PanelVisible(panel) then return end
    if self.DeferScanRefresh and self:DeferScanRefresh("RefreshJournal") then return end
    local tab = self.journalTab or "catch"
    if tab ~= "session" and tab ~= "lifetime" then
        local skills = self:GetJournalSkills()
        local snapshot = SkillSnapshot(skills)
        if panel.skillSnapshot ~= snapshot then
            self:SelectJournalTab(tab)
            return
        end
    end
    if tab == "catch" then
        if panel.catchRevision ~= self.catchRevision or panel.locationRevision ~= self.journalLocationRevision
            or panel.foodEffectRevision~=self.journalFoodEffectRevision then
            local scroll=panel.scroll:GetVerticalScroll()
            self:RenderCatchJournal()
            panel.scroll:SetVerticalScroll(math.min(scroll,panel.scroll:GetVerticalScrollRange()))
        end
    elseif tab == "achievements" then
        if panel.achievementRevision ~= self.achievementRevision then
            local scroll = panel.scroll:GetVerticalScroll()
            self:RenderAchievements()
            panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
        end
    elseif tab == "nearby" then
        local mapID, zone, faction = self:GetNearbyContext()
        if panel.nearbyCatchRevision ~= self.catchRevision or panel.nearbyLocationRevision ~= self.journalLocationRevision
            or panel.nearbyMapID ~= mapID or panel.nearbyZone ~= zone or panel.nearbyFaction ~= faction then
            local scroll = panel.scroll:GetVerticalScroll()
            RenderSelectedJournalPage(self, panel)
            panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
        end
    elseif tab == "session" or tab == "lifetime" then
        if panel.statsRevision ~= self.statsRevision then
            if tab == "session" and panel.sessionHistoryShown then
                local owner = UnitGUID and UnitGUID("player")
                local history = owner and self.db.sessionHistory and self.db.sessionHistory[owner]
                if panel.historyRevision ~= self.sessionHistoryRevision or panel.historyOwner ~= owner
                    or (history and panel.historyRecords ~= history) then
                    local scroll = panel.scroll:GetVerticalScroll()
                    self:RenderSessionHistory()
                    panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
                end
            else UpdateRecordValues(panel, RecordMetrics(self, tab == "lifetime")) end
            panel.statsRevision = self.statsRevision
        end
    elseif tab == "chef" and panel.chefView == "campfire" then
        local scroll = panel.scroll:GetVerticalScroll()
        self:RenderMasterChefCampfire()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    elseif tab == "chef" and panel.chefView == "meals" then
        local scroll = panel.scroll:GetVerticalScroll()
        self:RenderMasterChefMeals()
        panel.scroll:SetVerticalScroll(math.min(scroll, panel.scroll:GetVerticalScrollRange()))
    end
    self:UpdateJournalClock()
end
