--
-- conf/dvdbounce.lua
-- DVD-logo screensaver: float every window on the active monitor and bounce
-- them off the edges (and each other) until toggled back.
-- Reference: https://wiki.hypr.land/Configuring/Dispatchers/
--

-------------------------------------------------------
-- State
-------------------------------------------------------

local states = {}
local timer = nil
-- Shared bounds for every bouncing window: the monitor the effect was started on.
-- Captured once on toggle so a second monitor never changes the playfield.
local bounds = nil

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Advance one window by its velocity and reflect it off the playfield edges.
--- @param s table window state (x/y position, w/h size, vx/vy velocity, m* bounds)
local function bounce(s)
    s.x = s.x + s.vx
    s.y = s.y + s.vy

    if s.x <= s.mx or s.x + s.w >= s.mx + s.mw then
        s.vx = -s.vx
        s.x = math.max(s.mx, math.min(s.x, s.mx + s.mw - s.w))
    end
    if s.y <= s.my or s.y + s.h >= s.my + s.mh then
        s.vy = -s.vy
        s.y = math.max(s.my, math.min(s.y, s.my + s.mh - s.h))
    end
    hl.dispatch(hl.dsp.window.move({
        window = "address:" .. s.address,
        x = math.floor(s.x),
        y = math.floor(s.y),
    }))
end

--- Axis-aligned bounding-box overlap test.
--- @param a table window state
--- @param b table window state
--- @return boolean
local function collides(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

--- Separate two overlapping windows along the shallowest axis and swap velocities.
--- @param a table window state
--- @param b table window state
local function resolve(a, b)
    local ox = math.min(a.x + a.w, b.x + b.w) - math.max(a.x, b.x)
    local oy = math.min(a.y + a.h, b.y + b.h) - math.max(a.y, b.y)
    if ox < oy then
        a.vx, b.vx = b.vx, a.vx
        if a.x < b.x then
            a.vx = -math.abs(a.vx)
            b.vx = math.abs(b.vx)
            a.x = a.x - ox
        else
            a.vx = math.abs(a.vx)
            b.vx = -math.abs(b.vx)
            a.x = a.x + ox
        end
    else
        a.vy, b.vy = b.vy, a.vy
        if a.y < b.y then
            a.vy = -math.abs(a.vy)
            b.vy = math.abs(b.vy)
            a.y = a.y - oy
        else
            a.vy = math.abs(a.vy)
            b.vy = -math.abs(b.vy)
            a.y = a.y + oy
        end
    end
end

--- Iteratively pull a list of windows apart until none overlap (or 50 passes).
--- @param list table[] window states
local function settle(list)
    for _ = 1, 50 do
        local any = false
        for i = 1, #list do
            for j = i + 1, #list do
                if collides(list[i], list[j]) then
                    resolve(list[i], list[j])
                    any = true
                end
            end
        end
        if not any then
            break
        end
    end
end

--- Float a window, lock it to its current size/position, and register it for bouncing.
--- @param w HL.Window the window to enlist
local function add_window(w)
    if not bounds then
        return
    end
    -- Keep the window at its real size instead of forcing a fixed DVD square.
    local ww = math.max(1, math.floor(w.size.x))
    local wh = math.max(1, math.floor(w.size.y))
    local was_tiled = not w.floating
    if was_tiled then
        hl.dispatch(hl.dsp.window.float({
            window = "address:" .. w.address,
            action = "toggle",
        }))
        -- Floating may restore a different last-float size; pin it to the
        -- size the window had while tiled so the physics box stays accurate.
        hl.dispatch(hl.dsp.window.resize({
            window = "address:" .. w.address,
            x = ww,
            y = wh,
        }))
    end

    -- Start from where the window already is, clamped inside the playfield,
    -- so it eases into the bounce instead of snapping to a random spot.
    local sx = math.max(bounds.x, math.min(w.at.x, bounds.x + bounds.w - ww))
    local sy = math.max(bounds.y, math.min(w.at.y, bounds.y + bounds.h - wh))

    local s = {
        address = w.address,
        was_tiled = was_tiled,
        x = sx,
        y = sy,
        w = ww,
        h = wh,
        vx = 5 * (math.random(2) == 1 and 1 or -1),
        vy = 5 * (math.random(2) == 1 and 1 or -1),
        mx = bounds.x,
        my = bounds.y,
        mw = bounds.w,
        mh = bounds.h,
    }
    states[#states + 1] = s

    settle(states)
    hl.dispatch(hl.dsp.window.move({
        window = "address:" .. w.address,
        x = math.floor(s.x),
        y = math.floor(s.y),
    }))
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

-- Adopt newly opened windows on the active workspace while the effect runs.
hl.on("window.open", function(e)
    if not timer then
        return
    end
    local addr = e.address or e
    hl.timer(function()
        local ws = hl.get_active_workspace()
        for _, w in ipairs(hl.get_windows() or {}) do
            if w.address == addr and ws and w.workspace and w.workspace.id == ws.id then
                for _, s in ipairs(states) do
                    if s.address == addr then
                        return
                    end
                end
                add_window(w)
                return
            end
        end
    end, { timeout = 100, type = "oneshot" })
end)

-- Toggle the screensaver: float + bounce every window on the current workspace,
-- and restore tiling on the second press. Bound to a key in conf/keybinds.lua.
local function toggle()
    if timer then
        timer:set_enabled(false)
        timer = nil
        for _, s in ipairs(states) do
            if s.was_tiled then
                hl.dispatch(hl.dsp.window.float({ window = "address:" .. s.address, action = "unset" }))
            end
        end
        states = {}
        bounds = nil
        return
    end

    local current_workspace = hl.get_active_workspace()
    if not current_workspace then
        return
    end

    -- Lock the playfield to the monitor the active workspace lives on.
    -- m.x/m.y are logical coords, but m.width/m.height are physical pixels,
    -- so divide by the scale to match the logical space windows live in.
    local m = hl.get_active_monitor()
    if not m then
        return
    end
    local scale = m.scale or 1
    bounds = {
        x = m.x,
        y = m.y,
        w = m.width / scale,
        h = m.height / scale,
    }

    math.randomseed(os.time())
    states = {}

    for _, w in ipairs(hl.get_windows() or {}) do
        if not (w and w.workspace and w.workspace.id == current_workspace.id) then
            goto continue
        end
        add_window(w)
        ::continue::
    end

    settle(states)

    timer = hl.timer(function()
        for i = 1, #states do
            for j = i + 1, #states do
                if collides(states[i], states[j]) then
                    resolve(states[i], states[j])
                end
            end
        end
        for _, s in ipairs(states) do
            bounce(s)
        end
    end, {
        timeout = 16,
        type = "repeat",
    })
end

-------------------------------------------------------
-- Exports
-------------------------------------------------------

return { toggle = toggle }
