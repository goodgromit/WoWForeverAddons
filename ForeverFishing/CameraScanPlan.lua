-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing
local P = {}
FF.ScanPlanner = P

function P.Median(values)
    table.sort(values)
    local n = #values
    if n == 0 then return nil end
    if n % 2 == 1 then return values[(n + 1) / 2] end
    return (values[n / 2] + values[n / 2 + 1]) / 2
end

-- Logical coordinates are yaw right and pitch down, in estimated degrees.
function P.Build(config)
    local steps, x, y = {}, 0, 0
    local function To(nx, ny, kind, row, rowEnd, turn, curve)
        if nx == x and ny == y then return end
        local length = turn and turn.radius * math.abs(turn.sweep)
            or curve and curve.length or math.sqrt((nx - x)^2 + (ny - y)^2)
        steps[#steps + 1] = { x = nx, y = ny, fromX = x, fromY = y, length = length,
            kind = kind, stage = "NORMAL", row = row, rowEnd = rowEnd, turn = turn, curve = curve }
        x, y = nx, ny
    end
    if config.rounded and not config.pyramid then
        local lead = (config.tilt or 0) + config.start
        local direction = lead < 0 and -1 or 1
        local radius = math.min(config.spacing / 2, config.reach / 2)
        To(0, lead, "travel", -1)
        -- Down (or up for a negative tilt), then tangent left: one quarter circle.
        local firstY = lead + direction * radius
        To(-radius, firstY, "scan", 0, nil,
            { cx = -radius, cy = lead, radius = radius, angle = 0, sweep = direction * math.pi / 2 })
        To(-config.reach, firstY, "scan", 0, true)
        for row = 1, config.down do
            local ny, side = firstY + row * config.spacing, x < 0 and -1 or 1
            To(x, ny, "scan", row, nil,
                { cx = x, cy = y + config.spacing / 2, radius = config.spacing / 2,
                    angle = -math.pi / 2, sweep = side * math.pi })
            To(-x, ny, "scan", row, true)
        end
    elseif config.racetrack then
        To(0, config.start, "travel", -1)
        To(-config.reach, config.start, "scan", 0)
        To(config.reach, config.start, "scan", 0, true)
        for row = 1, config.down do
            local side = row % 2 == 1 and 1 or -1
            local reach = config.reach + (config.pyramid and row * (config.pyramidStep or 1) or 0)
            local ny = config.start + row * config.spacing
            local bulge = math.max(config.spacing / 2, math.abs(reach - math.abs(x)) / 2)
            local curve = P.MakeCurve(x, y, side * reach, ny, side * bulge)
            To(side * reach, ny, "scan", row, nil, nil, curve)
            To(-side * reach, ny, "scan", row, true)
        end
    else
        To(0, config.start, "travel", -1)
        for row = 0, config.down do
            local ny = config.start + row * config.spacing
            -- Pyramid rows widen by the selected amount on each side at each step down.
            local reach = config.reach + (config.pyramid and row * (config.pyramidStep or 1) or 0)
            local start = row % 2 == 0 and -reach or reach
            To(start, ny, "scan", row)
            To(-start, ny, "scan", row, true)
        end
    end
    return steps
end

local function Cubic(curve, t)
    local u = 1 - t
    local a, b, c, d = u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t
    return a * curve.x0 + b * curve.x1 + c * curve.x2 + d * curve.x3,
        a * curve.y0 + b * curve.y1 + c * curve.y2 + d * curve.y3
end

-- Short outward U-turns keep both row endpoints and their horizontal tangents.
-- An arc-length table keeps camera speed nearly uniform through the bend.
function P.MakeCurve(x0, y0, x3, y3, outward)
    local curve = { x0 = x0, y0 = y0, x1 = x0 + outward, y1 = y0,
        x2 = x3 + outward, y2 = y3, x3 = x3, y3 = y3, lengths = { 0 } }
    local px, py, length = x0, y0, 0
    for sample = 1, 24 do
        local nx, ny = Cubic(curve, sample / 24)
        length = length + math.sqrt((nx - px)^2 + (ny - py)^2)
        curve.lengths[sample + 1] = length
        px, py = nx, ny
    end
    curve.length = length
    return curve
end

function P.CurvePosition(step, progress)
    local curve = step.curve
    if progress <= 0 then return curve.x0, curve.y0 end
    if progress >= 1 then return curve.x3, curve.y3 end
    local distance = progress * curve.length
    for sample = 1, 24 do
        local previous, nextLength = curve.lengths[sample], curve.lengths[sample + 1]
        if distance <= nextLength then
            local fraction = (distance - previous) / (nextLength - previous)
            return Cubic(curve, (sample - 1 + fraction) / 24)
        end
    end
    return curve.x3, curve.y3
end

function P.TurnPosition(step, progress)
    local turn = step.turn
    local angle = turn.angle + turn.sweep * progress
    return turn.cx + turn.radius * math.cos(angle), turn.cy + turn.radius * math.sin(angle)
end

-- Build a single time line. Circular arcs and straight lines use the same
-- angular path speed, so their tangent velocities match at every row join.
function P.Time(steps, rate)
    local elapsed = 0
    for _, step in ipairs(steps) do
        step.rate = rate
        step.begins = elapsed
        elapsed = elapsed + step.length / step.rate
        step.ends = elapsed
    end
    return elapsed
end

function P.Sample(steps, elapsed)
    for index, step in ipairs(steps) do
        if elapsed < step.ends or index == #steps then
            local progress = math.max(0, math.min(1, (elapsed - step.begins) / (step.ends - step.begins)))
            if step.turn then
                local x, y = P.TurnPosition(step, progress)
                return x, y, index, progress
            end
            if step.curve then
                local x, y = P.CurvePosition(step, progress)
                return x, y, index, progress
            end
            return step.fromX + (step.x - step.fromX) * progress,
                step.fromY + (step.y - step.fromY) * progress, index, progress
        end
    end
end
