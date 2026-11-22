-- Forever Fishing
-- Copyright Â© 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
-- Removed development status/seconds fields are ignored; no preference reset.
local FIELDS={enabled=true,skill=true,progress=true,goldPerHour=true}
function FF:GetFishingInformationOptions()
    local saved=self.db and self.db.fishingInformation
    local out={}
    for key in pairs(FIELDS) do out[key]=not (type(saved)=="table" and saved[key]==false) end
    local mode=type(saved)=="table" and saved.progressMode
    -- Explicit mode wins; the old boolean retains its equivalent default.
    out.progressMode=(mode=="off" or mode=="always" or mode=="hidden") and mode or (out.progress and "always" or "off")
    out.progress=out.progressMode~="off"
    local bars=type(saved)=="table" and saved.hideCastBars
    out.hideCastBars=(bars=="off" or bars=="fishing" or bars=="cooking" or bars=="both") and bars or "both"
    return out
end
function FF:SetFishingCastBarHideMode(mode)
    if not self.db or (mode~="off" and mode~="fishing" and mode~="cooking" and mode~="both") then return false end
    if type(self.db.fishingInformation)~="table" then self.db.fishingInformation={} end
    self.db.fishingInformation.hideCastBars=mode
    self:ApplyFishingInformationLayout()
    if self.settingsPanel and self.settingsPanel.RefreshInformationControls then self.settingsPanel:RefreshInformationControls() end
    return true
end
function FF:SetFishingCastProgressMode(mode)
    if not self.db or (mode~="off" and mode~="always" and mode~="hidden") then return false end
    if type(self.db.fishingInformation)~="table" then self.db.fishingInformation={} end
    self.db.fishingInformation.progressMode=mode
    self.db.fishingInformation.progress=mode~="off"
    self:ApplyFishingInformationLayout()
    if self.settingsPanel and self.settingsPanel.RefreshInformationControls then self.settingsPanel:RefreshInformationControls() end
    return true
end
function FF:SetFishingInformationOption(key,value)
    if not FIELDS[key] or not self.db then return false end
    if key=="progress" then return self:SetFishingCastProgressMode(value==true and "always" or "off") end
    if type(self.db.fishingInformation)~="table" then self.db.fishingInformation={} end
    self.db.fishingInformation[key]=value==true
    self:ApplyFishingInformationLayout()
    if self.settingsPanel and self.settingsPanel.RefreshInformationControls then self.settingsPanel:RefreshInformationControls() end
    return true
end
local function AddGoldSource(gold)
    GameTooltip:AddLine(FF:LocalizedText("information.gold-source",gold.sources),.9,.85,.7,true)
end

local function ShowGoldTooltip(gold)
    GameTooltip:SetOwner(gold,"ANCHOR_RIGHT")
    GameTooltip:SetText(FF:LocalizedText("information.gold-per-hour"))
    AddGoldSource(gold)
    GameTooltip:Show()
end

local function PaintGoldPerHour(gold)
    local amount=FF:FormatFishingHourlyCoinAmount(gold.copper,FF:CurrentSessionSeconds(),true)
    local text=gold.text
    if text:GetText()==amount then return end
    text:SetText(amount)
    if gold.fontHeight and text.GetUnboundedStringWidth then
        text:SetFontHeight(gold.fontHeight)
        local width=text:GetUnboundedStringWidth()
        if width and width>gold:GetWidth() then
            -- Inline coin art retains its fixed size when the numbers shrink.
            text:SetFontHeight(math.max(8,gold.fontHeight*(gold:GetWidth()-36)/(width-36)))
        end
    end
end

local function StopGoldClock(self)
    if not self.fishingGoldClock then return end
    self.fishingGoldClock:Cancel()
    self.fishingGoldClock=nil
end

function FF:RefreshFishingGoldPerHour()
    local button=self.castButton
    local gold=button and button.fishingGold
    if not gold then return end
    local options=self:GetFishingInformationOptions()
    local opacity=self.GetFishingHUDOpacity and self:GetFishingHUDOpacity() or 1
    local shown=options.enabled and options.goldPerHour and opacity>0 and self.bar and self.bar:IsShown()
        and not self.dataResetPendingReload and self.session and self.session.records and self.GetSessionGoldValue
    local hover=shown and opacity==1 or false
    if gold.hover~=hover and gold.motionTooltip then
        gold.hover=hover
        gold:SetMouseMotionEnabled(hover)
        if not hover and GameTooltip:GetOwner()==gold then GameTooltip:Hide() end
    end
    if not shown then
        if gold:IsShown() then gold:Hide(); button.label:SetWidth(244) end
        gold.copper=nil
        StopGoldClock(self)
        return
    end
    if gold.copper==nil or gold.session~=self.session or gold.revision~=self.statsRevision then
        gold.copper,gold.sources=self:GetSessionGoldValue()
        gold.session,gold.revision=self.session,self.statsRevision
        PaintGoldPerHour(gold)
        if GameTooltip:GetOwner()==gold then ShowGoldTooltip(gold) end
    end
    if not gold:IsShown() then gold:Show(); button.label:SetWidth(192) end
    if gold.copper==0 or not self.session.activeStarted then
        StopGoldClock(self)
    elseif not self.fishingGoldClock and C_Timer and C_Timer.NewTicker then
        local ticker
        ticker=C_Timer.NewTicker(1,function()
            if self.fishingGoldClock~=ticker then return end
            if not gold:IsVisible() or self.session~=gold.session or not self.session.activeStarted then StopGoldClock(self); return end
            PaintGoldPerHour(gold)
        end)
        self.fishingGoldClock=ticker
    end
end

function FF:InitializeFishingInformation()
    if type(self.db.fishingInformation)~="table" then self.db.fishingInformation={} end
    local saved,options=self.db.fishingInformation,self:GetFishingInformationOptions()
    saved.progressMode,saved.hideCastBars=options.progressMode,options.hideCastBars
    local button=self.castButton
    button.label:SetWidth(244); button.label:SetJustifyH("LEFT"); button.label:SetWordWrap(false)
    local gold=CreateFrame("Frame",nil,button)
    gold:SetPoint("TOPRIGHT",button,"TOPRIGHT",-34,-11); gold:SetSize(122,17)
    gold.text=gold:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    gold.text:SetAllPoints(gold); gold.text:SetJustifyH("RIGHT"); gold.text:SetWordWrap(false)
    gold.text:SetTextColor(1,.84,.52)
    if gold.text.GetFont and gold.text.SetFontHeight then gold.fontHeight=select(2,gold.text:GetFont()) end
    if gold.SetMouseMotionEnabled and gold.SetMouseClickEnabled then
        gold:SetMouseClickEnabled(false); gold:SetMouseMotionEnabled(false)
        gold.motionTooltip=true
        gold:SetScript("OnEnter",ShowGoldTooltip)
        gold:SetScript("OnLeave",function() if GameTooltip:GetOwner()==gold then GameTooltip:Hide() end end)
    end
    gold:Hide(); button.fishingGold=gold
    local track=button:CreateTexture(nil,"ARTWORK")
    track:SetPoint("BOTTOMLEFT",button,"BOTTOMLEFT",10,4); track:SetSize(418,3); track:SetColorTexture(.24,.19,.12,.8)
    local fill=button:CreateTexture(nil,"OVERLAY")
    fill:SetPoint("BOTTOMLEFT",track,"BOTTOMLEFT"); fill:SetSize(1,3); fill:SetColorTexture(.8,.61,.28,.95)
    button.fishingProgressTrack,button.fishingProgressFill=track,fill
    local seconds=button:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    seconds:SetPoint("BOTTOM",track,"TOP",0,1); seconds:SetSize(74,12); seconds:SetJustifyH("CENTER")
    seconds:SetTextColor(.9,.8,.55); button.fishingSeconds=seconds
    self:ApplyFishingInformationLayout()
end
function FF:ApplyFishingInformationLayout()
    if not self.castButton or not self.castButton.fishingSeconds then return end
    if InCombatLockdown and InCombatLockdown() then self.fishingInformationPending=true; return end
    self.fishingInformationPending=nil
    local options=self:GetFishingInformationOptions()
    if self.minimalCastGuard then self.minimalCastGuard:SetAttribute("restore-information",options.enabled) end
    local opacity=self.GetFishingHUDOpacity and self:GetFishingHUDOpacity() or 1
    local shown=options.enabled and opacity>0
    -- Keep the session and secure Close forwarding target alive. All panel
    -- controls become invisible and input-transparent together.
    local owner=GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner()
    for _,field in ipairs({"castButton","bindButton","closeButton"}) do
        local control=self[field]
        if control then
            control:SetAlpha(shown and opacity or 0)
            control:EnableMouse(shown and opacity==1 or false)
            if not shown and owner==control then GameTooltip:Hide() end
        end
    end
    self.castButton.hint:SetShown(shown)
    if not shown then self.castButton.statusIcon:Hide() end
    self.castButton.label:SetShown(shown)
    self:UpdateFishingInformation(true)
    self:RefreshFishingGoldPerHour()
end
-- Presentation only. Unknown caps/levels never imply training eligibility.
function FF:GetFishingInformationSkillText(skill,level)
    if not skill or not skill.base then return "Forever Fishing" end
    local base,cap=tonumber(skill.base),tonumber(skill.trainedCap)
    local rank=self.fishingRankInfo and self.fishingRankInfo[cap]
    if not base or not rank then
        return self:LocalizedText("information.skill-format",self:FishingName(),skill.base,tostring(cap or "?"))
    end
    if cap==300 and base==300 then return self:LocalizedText("information.expert-angler") end
    local nextRank=self.fishingRankInfo[rank.nextCap]
    local eligible=nextRank and base>=nextRank.minSkill and (tonumber(level) or 0)>=nextRank.minLevel
    local capped=eligible and base>=cap
    local label=self:LocalizedText("information.rank-format",
        self:LocalizedText("information.rank."..string.lower(rank.name)),base,
        eligible and not capped and "*" or "",cap,capped and "!" or "")
    local tip=eligible and self:LocalizedText(capped and "information.train-capped" or "information.train-available",
        self:LocalizedText("information.rank."..string.lower(nextRank.name))) or nil
    return label,tip
end
function FF:UpdateFishingInformation(refreshSkill,playerLevel)
    local button=self.castButton
    if not button or not button.fishingSeconds then return end
    local options=self:GetFishingInformationOptions()
    if self.SyncMinimalFishingView then self:SyncMinimalFishingView() end
    local enabled=options.enabled and (not self.GetFishingHUDOpacity or self:GetFishingHUDOpacity()>0)
    if refreshSkill or not self.fishingInformationSkill then
        self.fishingInformationSkill=self.GetJournalSkills and self:GetJournalSkills().Fishing
        self.fishingInformationLevel=tonumber(playerLevel) or (UnitLevel and UnitLevel("player"))
        -- Refresh an already-hovered status tooltip only while it still owns it.
        if GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner()==button and GameTooltip:IsShown() then
            local enter=button:GetScript("OnEnter")
            if enter then enter(button) end
        end
    end
    button.label:SetShown(enabled)
    local skill=self.fishingInformationSkill
    if enabled and options.skill and skill and skill.base then
        button.label:SetText((self:GetFishingInformationSkillText(skill,self.fishingInformationLevel)))
    elseif enabled then button.label:SetText("Forever Fishing") end
    local active,remaining,fraction,cast=self:GetFishingInformationProgress()
    local ownedHidden=self.fishingUIHiddenByAddon and UIParent and not UIParent:IsShown()
    local minimalShown=self.minimalFishingViewActive and self.minimalCastFrame and self.minimalCastFrame:IsShown()
    local nativeHidden=self.SyncFishingCastBarVisibility and self:SyncFishingCastBarVisibility(cast)
    local progress=enabled and active and not minimalShown
        and (options.progressMode=="always" or (options.progressMode=="hidden" and (ownedHidden or nativeHidden))) or false
    local layoutChanged=button.fishingSeconds:IsShown()~=progress
    button.fishingSeconds:SetShown(progress)
    if active then self:PaintFishingInformationProgress(remaining,fraction)
    else button.fishingSeconds:SetText("");button.fishingProgressFill:SetWidth(.001) end
    button.fishingProgressTrack:SetShown(progress and true or false)
    button.fishingProgressFill:SetShown(progress and true or false)
    if progress then
        button.fishingProgressFill:SetShown(fraction>0)
    end
    local minimal=self.minimalCastFrame
    local fishing,_,fishingFraction=self:GetFishingChannelProgress()
    if minimal and self.minimalFishingViewActive and fishing then
        minimal.fill:SetWidth(math.max(.001,minimal.trackWidth*fishingFraction))
        minimal.fill:SetShown(fishingFraction>0)
    end
    if not enabled then
        button.hint:Hide(); button.statusIcon:Hide()
        local message=self.masterChefQuickStatus
        if message and message~=self.hiddenFishingInformationNotice and self.ShowPreparationStatusNotice then
            self:ShowPreparationStatusNotice(message,"chef")
        end
        self.hiddenFishingInformationNotice=message
    else
        button.hint:Show()
        button.statusIcon:SetShown(button.castStatusStyle and button.castStatusStyle.icon
            and not button.paintedChefOverlay and true or false)
        self.hiddenFishingInformationNotice=nil
    end
    if enabled and cast and cast.kind=="cooking" then
        local text=self:LocalizedText("information.cooking",cast.name)
        if button.hint:GetText()~=text then
            button.hint:SetText(text)
            layoutChanged=true
        end
        button.statusIcon:Hide()
    end
    if layoutChanged and button.LayoutFishingStatusText then button:LayoutFishingStatusText() end
    self.cookingInformationProgressShown=progress and cast and cast.kind=="cooking" or false
end
-- Both fill and countdown use this one time sample; never integrate elapsed
-- frame time or smooth toward an estimated/queue-wide duration.
function FF:PaintFishingInformationProgress(remaining,fraction)
    self.castButton.fishingSeconds:SetText(self:LocalizedText("format.display-seconds",self:LocalizedNumber(remaining,1)))
    self.castButton.fishingProgressFill:SetWidth(math.max(.001,418*fraction))
end
function FF:FinishCookingInformationCast()
    local hold=self.fishingCookingBarHold
    if hold and hold.cast==self.cookingInformationCast then hold.finished=true end
    if self.cookingInformationCast then self.informationCastEnded=self.cookingInformationCast end
    self.cookingInformationCast=nil;self.cookingInformationProgressShown=nil
end
function FF:UpdateCookingInformationProgress()
    local cast=self.cookingInformationCast
    if not cast then return end
    local now=GetTime()
    if cast.db~=self.db or cast.bar~=self.bar or not self.bar:IsShown() or self.informationWorldSuspended then
        self.cookingInformationCast=nil;self.cookingInformationProgressShown=nil;self:UpdateUI();return
    end
    if now>=cast.finish then self:FinishCookingInformationCast();self:UpdateUI();return end
    if self.cookingInformationProgressShown then
        local remaining=math.max(0,cast.finish-now)
        self:PaintFishingInformationProgress(remaining,math.min(1,remaining/(cast.finish-cast.start)))
    end
end
local function Plain(value,kind)
    return not (issecretvalue and issecretvalue(value)) and type(value)==kind
end
-- Read the client clock, not recipe estimates. Restricted/invalid values cannot
-- authorize replacing a native bar. Channels and ordinary casts have different
-- spell/GUID return positions.
function FF:ReadFishingInformationCast()
    for _,source in ipairs({"cast","channel"}) do
        local query=UnitCastingInfo
        if source=="channel" then query=UnitChannelInfo end
        if type(query)=="function" then
            local ok,name,_,_,started,ends,trade,guid,eighth,ninth=pcall(query,"player")
            if not ok or (issecretvalue and issecretvalue(name)) then return nil,"unknown" end
            local spell=source=="cast" and ninth or eighth
            if ok and Plain(name,"string") and Plain(started,"number") and Plain(ends,"number")
                and Plain(spell,"number") and started==started and ends==ends
                and started>=0 and started/1000<=GetTime()+.25 and ends>started and ends<math.huge then
                local cast={name=name,start=started/1000,finish=ends/1000,spell=spell,source=source,
                    trade=Plain(trade,"boolean") and trade or false,
                    guid=source=="cast" and Plain(guid,"string") and guid or nil}
                if cast.finish<=GetTime() then return nil,"expired",cast end
                return cast
            end
            -- A present but unreadable cast must not fall through to an older
            -- channel and hide the bar of the unknown activity.
            if name~=nil then return nil,"unknown" end
        end
    end
    return nil,"idle"
end
local function CookingRecipe(spell)
    local query=C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoByRecipeID
    if type(query)~="function" then return false end
    local ok,info=pcall(query,spell)
    if not ok or not Plain(info,"table") then return false end
    -- Stable native skill-line / profession identities, never recipe-name tests.
    for key,id in pairs({professionID=185,parentProfessionID=185,profession=5}) do
        if Plain(info[key],"number") and info[key]==id then return true end
    end
    return false
end
local function SameCast(a,b)
    return a and b and a.spell==b.spell and a.source==b.source
        and ((a.guid and b.guid and a.guid==b.guid) or (not (a.guid and b.guid) and a.start==b.start))
end
function FF:GetFishingInformationProgress()
    if not self.db or self.informationWorldSuspended or not (self.bar and self.bar:IsShown()) then
        self.cookingInformationCast=nil;return false,0,0
    end
    local ended=self.informationCastEnded
    if ended and (ended.db~=self.db or ended.bar~=self.bar) then self.informationCastEnded=nil end
    local expected=self.informationCastExpected
    if expected and (expected.db~=self.db or expected.bar~=self.bar) then self.informationCastExpected=nil;expected=nil end
    local current=self.cookingInformationCast
    if current and (current.db~=self.db or current.bar~=self.bar) then
        self.cookingInformationCast=nil;current=nil
    end
    if current and GetTime()>=current.finish then self:FinishCookingInformationCast();current=nil end
    -- Fishing already has canonical channel bounds. Cooking now likewise
    -- retains the accepted native bounds until an authoritative cast event.
    local live=not current and self:ReadFishingInformationCast() or nil
    self.informationCastObservation=live
    local expectedCooking=not expected or (live and live.spell==expected.spell
        and not (live.guid and expected.guid and live.guid~=expected.guid))
    if not current and live and live.trade and expectedCooking and not SameCast(live,self.informationCastEnded) then
        if not current and CookingRecipe(live.spell) then
            current=live;current.kind="cooking";current.db=self.db;current.bar=self.bar
            self.cookingInformationCast=current
        end
    end
    if current then
        local remaining=math.max(0,current.finish-GetTime())
        return true,remaining,math.min(1,remaining/(current.finish-current.start)),current
    end
    local active,remaining,fraction=self:GetFishingChannelProgress()
    -- Retain canonical fishing display/recovery. Native hiding additionally
    -- requires readable live bounds for that exact channel.
    local reliable=active and live and live.source=="channel" and not live.trade
        and (live.spell==131474 or live.spell==131476 or live.spell==self.fishingChannelSpell)
        and math.abs(live.start-self.castStart)<.001 and math.abs(live.finish-self.castEnd)<.001
    if reliable then live.kind="fishing" end
    return active,remaining,fraction,reliable and live or nil
end
local informationCastEvents={
    UNIT_SPELLCAST_START=true,UNIT_SPELLCAST_DELAYED=true,UNIT_SPELLCAST_STOP=true,
    UNIT_SPELLCAST_FAILED=true,UNIT_SPELLCAST_FAILED_QUIET=true,UNIT_SPELLCAST_SUCCEEDED=true,
    UNIT_SPELLCAST_CHANNEL_START=true,UNIT_SPELLCAST_CHANNEL_UPDATE=true,
    UNIT_SPELLCAST_CHANNEL_STOP=true,UNIT_SPELLCAST_INTERRUPTED=true,
}
function FF:OnFishingInformationEvent(event,unit,guid,spell)
    if event=="PLAYER_LEAVING_WORLD" or event=="PLAYER_LOGOUT" then
        self.informationWorldSuspended=true;self.cookingInformationCast=nil;self.informationCastEnded=nil;self.informationCastExpected=nil
        if self.ReleaseFishingCastBars then self:ReleaseFishingCastBars() end
        return
    elseif event=="PLAYER_ENTERING_WORLD" then self.informationWorldSuspended=nil end
    if event=="PLAYER_ENTERING_WORLD" or event=="PLAYER_REGEN_DISABLED" or event=="PLAYER_REGEN_ENABLED" then
        if self.castButton then self:UpdateUI() end
        return
    end
    -- This observer is session-only. Unrelated events have different payloads,
    -- and cast events may carry private unit/GUID/spell values even while idle.
    if not informationCastEvents[event] or not self.db or self.informationWorldSuspended
        or not (self.bar and self.bar:IsShown()) then return end
    if not Plain(unit,"string") or unit~="player" then return end
    if issecretvalue and (issecretvalue(guid) or issecretvalue(spell)) then return end
    if (guid~=nil and not Plain(guid,"string")) or (spell~=nil and not Plain(spell,"number")) then return end
    local wasCooking=self.cookingInformationCast~=nil
    local terminal=event=="UNIT_SPELLCAST_STOP" or event=="UNIT_SPELLCAST_CHANNEL_STOP"
        or event=="UNIT_SPELLCAST_FAILED" or event=="UNIT_SPELLCAST_FAILED_QUIET" or event=="UNIT_SPELLCAST_INTERRUPTED"
    local current=self.cookingInformationCast
    terminal=terminal or (event=="UNIT_SPELLCAST_SUCCEEDED" and current and current.source=="cast")
    if current and terminal and Plain(spell,"number") and spell==current.spell
        and (not current.guid or (Plain(guid,"string") and guid==current.guid)) then
        self:FinishCookingInformationCast()
    elseif (event=="UNIT_SPELLCAST_START" or event=="UNIT_SPELLCAST_CHANNEL_START"
        or event=="UNIT_SPELLCAST_DELAYED" or event=="UNIT_SPELLCAST_CHANNEL_UPDATE") then
        local starting=event=="UNIT_SPELLCAST_START" or event=="UNIT_SPELLCAST_CHANNEL_START"
        if starting then
            self.informationCastExpected={db=self.db,bar=self.bar,
                guid=Plain(guid,"string") and guid or nil,spell=Plain(spell,"number") and spell or nil}
        end
        if starting or not current or not current.guid or current.guid==guid then
            local live,status,expired=self:ReadFishingInformationCast()
            if not starting and current and live and live.trade and SameCast(current,live) then
                current.start,current.finish=live.start,live.finish
            elseif not starting and current and status=="expired" and SameCast(current,expired) then
                self:FinishCookingInformationCast()
            else self.cookingInformationCast=nil end
        end
        self:GetFishingInformationProgress()
        current=self.cookingInformationCast
        if current and current.spell==spell and Plain(guid,"string") then current.guid=guid end
        if starting and not current and self.fishingCookingBarHold then
            self.fishingCookingBarHold.suspended=true
            self:ReleaseFishingCastBars(true)
        end
    end
    if self.castButton and (wasCooking or self.cookingInformationCast or self.fishingCookingBarHold) and (terminal or event=="UNIT_SPELLCAST_START"
        or event=="UNIT_SPELLCAST_CHANNEL_START" or event=="UNIT_SPELLCAST_DELAYED"
        or event=="UNIT_SPELLCAST_CHANNEL_UPDATE") then
        self:UpdateUI()
    end
end
-- Both cast displays use the same live native channel bounds, including UPDATE.
function FF:GetFishingChannelProgress()
    local start,finish=tonumber(self.castStart),tonumber(self.castEnd)
    local active=self.active and start and finish and finish>start
    local remaining=active and math.max(0,finish-GetTime()) or 0
    return active,remaining,active and math.min(1,remaining/(finish-start)) or 0
end
function FF:AddFishingInformationTooltip()
    local gold=self.castButton and self.castButton.fishingGold
    if gold and gold:IsVisible() and not gold.motionTooltip then
        GameTooltip:AddLine(FF:LocalizedText("information.gold-per-hour"),1,.84,.52)
        AddGoldSource(gold)
    end
    local skill=self.GetJournalSkills and self:GetJournalSkills().Fishing
    if skill and skill.base then
        GameTooltip:AddLine(FF:LocalizedText("information.skill-tooltip",skill.base,tostring(skill.trainedCap or "?"),skill.value or skill.base),.83,.72,.52,true)
        GameTooltip:AddLine(FF:LocalizedText("information.bonus-tooltip",(skill.value or skill.base)-skill.base),.76,.82,.8,true)
        local level=math.max(tonumber(UnitLevel and UnitLevel("player")) or 0,tonumber(self.fishingInformationLevel) or 0)
        local _,training=self:GetFishingInformationSkillText(skill,level)
        if training then GameTooltip:AddLine(training,.83,.72,.52,true) end
    end
end

-- On-demand diagnostics. Keep the native sources independent so a report
-- can show a missing modifier without assuming that the server applies it.
local function TraceReturns(ok,...)
    if ok then return ... end
end

local function TraceRead(reader,...)
    if Plain(reader,"function") then return TraceReturns(pcall(reader,...)) end
end

local function TraceValue(value)
    if issecretvalue and issecretvalue(value) then return "?" end
    local kind=type(value)
    return (kind=="number" or kind=="string" or kind=="boolean") and tostring(value) or "?"
end

local function TraceEffective(skill)
    if not Plain(skill,"table") or not Plain(skill.base,"number") or not Plain(skill.value,"number") then
        return "?"
    end
    return ("%g (%+g)"):format(skill.value,skill.value-skill.base)
end

local function TraceEquipped(slot)
    local itemID=TraceRead(GetInventoryItemID,"player",slot)
    local link=TraceRead(GetInventoryItemLink,"player",slot)
    local linkID,enchantID
    if Plain(link,"string") then
        linkID=tonumber(link:match("item:(%d+)"))
        enchantID=link:match("item:%d+:(%d*)")
    end
    if not Plain(itemID,"number") then itemID=linkID
    elseif itemID~=linkID then enchantID=nil end
    if enchantID=="" then enchantID="0" end
    return TraceValue(itemID).."/"..TraceValue(enchantID)
end

local function TraceMainHandEnchants()
    local mainHand=Enum and Enum.WeaponSlot and Enum.WeaponSlot.MainHand
    if Plain(mainHand,"number") then
        local enchants=TraceRead(C_Item and C_Item.GetWeaponEnchantInfo,mainHand)
        if Plain(enchants,"table") then
            local active={}
            for _,enchant in pairs(enchants) do
                local has
                if Plain(enchant,"table") then has=enchant.hasEnchant end
                if not Plain(has,"boolean") then
                    active[#active+1]="?"
                elseif has then
                    active[#active+1]=("%s/%s/%s"):format(TraceValue(enchant.enchantID),
                        TraceValue(enchant.enchantType),TraceValue(enchant.timeLeft))
                end
            end
            table.sort(active)
            return #active>0 and table.concat(active,", ") or "none"
        end
    end
    local has,remaining,_,id=TraceRead(GetWeaponEnchantInfo)
    if not Plain(has,"boolean") then return "?" end
    if not has then return "none" end
    return ("%s/?/%s"):format(TraceValue(id),TraceValue(remaining))
end

function FF:ShowFishingSkillTrace()
    local fishingID=356
    local version,build,_,interface=TraceRead(GetBuildInfo)
    local _,_,_,fishing=TraceRead(GetProfessions)
    local rank,cap,lineID,modifier
    if Plain(fishing,"number") then
        local _,_,r,c,_,_,id,m=TraceRead(GetProfessionInfo,fishing)
        rank,cap,lineID,modifier=r,c,id,m
    end
    local skill=TraceRead(C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID,fishingID)
    local trade=TraceRead(C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoBySkillLineID,fishingID)
    if not Plain(skill,"table") then skill={} end
    if not Plain(trade,"table") then trade={} end
    local native=TraceRead(self.GetJournalSkills,self)
    local journal=self.journalPanel and self.journalPanel.journalSkills
    self:Print(("Skill trace | client %s build %s interface %s"):format(
        TraceValue(version),TraceValue(build),TraceValue(interface)))
    self:Print(("GetProfessionInfo: line=%s rank=%s cap=%s modifier=%s"):format(
        TraceValue(lineID),TraceValue(rank),TraceValue(cap),TraceValue(modifier)))
    self:Print(("C_SkillInfo (356): rank=%s cap=%s tempPoints=%s modifier=%s"):format(
        TraceValue(skill.rank),TraceValue(skill.maxRank),TraceValue(skill.tempPoints),TraceValue(skill.modifier)))
    self:Print(("C_TradeSkillUI (356): rank=%s cap=%s modifier=%s"):format(
        TraceValue(trade.skillLevel),TraceValue(trade.maxSkillLevel),TraceValue(trade.skillModifier)))
    self:Print(("Effective (bonus): tooltip=%s | bar cache=%s | Journal cache=%s"):format(
        TraceEffective(Plain(native,"table") and native.Fishing),
        TraceEffective(self.fishingInformationSkill),TraceEffective(journal and journal.Fishing)))
    self:Print(("Equipped (item/link enchant): main=%s off=%s head=%s hands=%s feet=%s"):format(
        TraceEquipped(16),TraceEquipped(17),TraceEquipped(1),TraceEquipped(10),TraceEquipped(8)))
    self:Print(("Main-hand enchants (ID/type/ms): %s | addon lure seconds=%s"):format(
        TraceMainHandEnchants(),TraceValue(TraceRead(self.LureSeconds,self))))
end
