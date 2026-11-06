local _, ns = ...
local function Valid(n)
    if issecretvalue and issecretvalue(n) then return false end
    return type(n) == "number" and n == n and n >= 0 and n < math.huge
end
function ns.FormatRange(low, high)
    if not Valid(low) then return "?", false end
    if high == nil then
        if low <= 0 then return "?", false end
        return string.format(">%g", low), true
    end
    if not Valid(high) or high < low or high <= 0 then return "?", false end
    if low == 0 then return string.format("≤%g", high), true end
    if low == high then return string.format("~%g", high), true end
    return string.format("%g–%g", low, high), true
end
