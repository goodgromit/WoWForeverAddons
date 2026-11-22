-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

local floor = math.floor
local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
local START_HOUR, END_HOUR = 14, 16
local STRANGLETHORN_GUIDE = {
    { heading = "Requirements", body = "Bring a fishing pole and learn Fishing; no registration is needed. Aim for Fishing 150 or higher. Fishing 225 plus a lure reduces escapes." },
    { heading = "Where to fish", body = "When the event starts, fish Schools of Tastyfish along the Stranglethorn coast, outside Booty Bay. Land your bobber inside a pool." },
    { heading = "What to do", body = "Turn in 40 Speckled Tastyfish to Riggle Bassbait on Booty Bay's central dock. The first 250 turn-ins per ruleset win. Exchange the prize coin with Jang." },
    { heading = "Tips", body = "Clear bag space and set your Hearthstone to Booty Bay. Keep fishing for rare catches after the main prize announcement while the event remains active." },
}
local STRANGLETHORN_FULL_GUIDE = {kind="guideuse",id="event:stranglethorn:full-guide",
    tab="rares",heading="Stranglethorn Fishing Extravaganza",label="See Rare Catches for the full guide."}

-- Calendar dates are realm dates. Compare civil days directly so the player's
-- local daylight saving change cannot shift a Sunday on the realm.
local function CivilDay(year, month, day)
    if month < 3 then year, month = year - 1, month + 12 end
    return 365 * year + floor(year / 4) - floor(year / 100) + floor(year / 400)
        + floor((153 * (month - 3) + 2) / 5) + day
end

local function RealmStamp(today, target, hour, minute, now)
    local seconds = now % 60
    return now + (CivilDay(target.year, target.month, target.monthDay)
        - CivilDay(today.year, today.month, today.monthDay)) * 86400
        + (hour * 60 + minute - today.hour * 60 - today.minute) * 60 - seconds
end

function FF:GetUpcomingFishingEvents()
    if not (C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime
        and C_DateAndTime.AdjustTimeByDays and GetServerTime and date) then return {} end
    local today = C_DateAndTime.GetCurrentCalendarTime()
    if not (today and today.year and today.month and today.monthDay and today.weekday
        and today.hour and today.minute) then return {} end
    local now = GetServerTime()
    local untilSunday = (8 - today.weekday) % 7
    if untilSunday == 0 and today.hour >= END_HOUR then untilSunday = 7 end
    local events = {}
    for index = 1, 4 do
        local day = C_DateAndTime.AdjustTimeByDays(today, untilSunday + (index - 1) * 7)
        if day then
            local starts = RealmStamp(today, day, START_HOUR, 0, now)
            local ends = RealmStamp(today, day, END_HOUR, 0, now)
            if ends > now then
                -- Format both views from this occurrence, letting the native
                -- local formatter apply its offset/DST at each endpoint.
                local localDate = date("%a %d %b %Y", starts):gsub(" 0(%d )", " %1")
                local localEndDate = date("%a %d %b %Y", ends):gsub(" 0(%d )", " %1")
                local localStart, localEnd = date("%H:%M", starts), date("%H:%M", ends)
                local realmDate = string.format("%02d %s %d", day.monthDay, MONTHS[day.month], day.year)
                local localDateTime = localDate .. ", " .. localStart .. "–"
                    .. (localEndDate ~= localDate and localEndDate .. ", " or "") .. localEnd
                events[#events + 1] = {
                    id = "stranglethorn-" .. CivilDay(day.year, day.month, day.monthDay),
                    title = "Stranglethorn Fishing Extravaganza",
                    realmDate = realmDate,
                    realmTime = string.format("%02d:00–%02d:00", START_HOUR, END_HOUR),
                    starts = starts, ends = ends,
                    localDate = localDate, localEndDate = localEndDate,
                    localTime = localStart .. "–" .. localEnd,
                    localDateTime = localDateTime,
                    calendarDisplay = { year = day.year, month = day.month, day = day.monthDay,
                        realmDate = realmDate, localDateTime = localDateTime, starts = starts, ends = ends },
                    active = starts <= now,
                    blocks = STRANGLETHORN_GUIDE,
                    guideTarget = STRANGLETHORN_FULL_GUIDE,
                }
            end
        end
    end
    return events
end
