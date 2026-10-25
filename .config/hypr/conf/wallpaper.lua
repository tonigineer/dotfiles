--
-- conf/wallpaper.lua
-- Wallpaper-only view while the skwd-wall-v2 picker is open, and on SUPER+D
-- Reference: https://wiki.hypr.land/IPC/
--

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

-- Picker layer namespace (skwd-paper is the wallpaper itself).
local picker_namespace = "skwd-wall"

local picker_cmds = {
    [""] = "skwd-wall-v2",
    ["--mixer"] = "skwd-wall-v2 --mixer",
}

-- Hyprland drops empty, unshown workspaces, so these need no cleanup.
local temp_prefix = "name:wallpaper-"

-- skwd does not report pick vs cancel, so this wait always runs.
local restore_delay_ms = 500

local picker_start_delay_ms = 250

-- Restore if the picker's layer never appears.
local open_timeout_ms = 5000

local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local bar_flag = runtime_dir .. "/hypr-wallpaper-bar-hidden"
local bar_lock = runtime_dir .. "/hypr-wallpaper-bar.lock"

-- bar-hide keeps the layer mapped, so visibility is read from `noctalia msg
-- status`; the flock keeps hide/show ordered on quick open/close.
-- The bar animates itself; only [shell.animation] in Noctalia silences that.
local bar_hide_cmd = string.format(
    [[flock %s sh -c 'if noctalia msg status | grep -Eq "\"barVisible\": *true"; then noctalia msg bar-hide >/dev/null && touch %s; fi']],
    bar_lock, bar_flag)
local bar_show_cmd = string.format(
    [[flock %s sh -c '[ -e %s ] && rm -f %s && noctalia msg bar-show >/dev/null']],
    bar_lock, bar_flag, bar_flag)

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

local open_count = 0

-- Monitor name -> workspace id shown before clear().
local saved = nil

-- Only set when this module turned animations off (not e.g. gamemode).
local animations_owned = false

-- Invalidate stale timers.
local open_token = 0
local close_token = 0

local picker_seen = false

-- Layer events pass the surface as userdata, not a table.
--- @param layer HL.LayerSurface|string|nil
--- @return string|nil
local function namespace_of(layer)
    if layer == nil or type(layer) == "string" then return layer end
    return layer.namespace
end

--- @param name string  monitor name
--- @return integer|nil
local function shown_id(name)
    local m = hl.get_monitor(name)
    local ws = m and m.active_workspace
    return ws and ws.id
end

--- set_workspace needs a `{ workspace = ... }` table and ignores anything else
--- silently; if it still did not switch, focus over and restore focus/cursor.
--- @param m HL.Monitor
--- @param selector string|integer
local function switch(m, selector)
    local before = shown_id(m.name)
    m:set_workspace({ workspace = selector })
    if shown_id(m.name) ~= before then return end

    local active = hl.get_active_monitor()
    local cursor = hl.get_cursor_pos()
    hl.dispatch(hl.dsp.focus({ monitor = m.id }))
    hl.dispatch(hl.dsp.focus({ workspace = selector }))
    if active then hl.dispatch(hl.dsp.focus({ monitor = active.id })) end
    if cursor then hl.dispatch(hl.dsp.cursor.move({ x = cursor.x, y = cursor.y })) end
end

--- @return boolean
local function wallpaper_only()
    return open_count > 0 or saved ~= nil
end

local function animations_sync()
    if wallpaper_only() then
        if animations_owned or not hl.get_config("animations.enabled") then return end
        animations_owned = true
        hl.config({ animations = { enabled = false } })
        return
    end

    if not animations_owned then return end
    animations_owned = false
    hl.config({ animations = { enabled = true } })
end

local function clear()
    saved = {}
    animations_sync()
    for _, m in ipairs(hl.get_monitors()) do
        local id = shown_id(m.name)
        if id then
            saved[m.name] = id
            switch(m, temp_prefix .. m.name)
        end
    end
end

-- Animations first, so leaving the temporary workspaces is animated.
local function restore()
    -- Cleared before the sync, which reads it via wallpaper_only().
    local previous = saved
    saved = nil
    animations_sync()

    if previous then
        for _, m in ipairs(hl.get_monitors()) do
            local id = previous[m.name]
            local ws = id and hl.get_workspace(id)
            -- Skip workspaces that moved to another monitor meanwhile.
            if ws and ws.monitor and ws.monitor.name == m.name and shown_id(m.name) ~= id then
                switch(m, id)
            end
        end
    end

    hl.dispatch(hl.dsp.exec_cmd(bar_show_cmd))
end

-------------------------------------------------------
-- Show desktop
-------------------------------------------------------

local desktop_saved = nil

-- Keeps the workspace.active listener from reacting to our own switches.
local desktop_busy = false

local temp_name = temp_prefix:gsub("^name:", "")

--- @param ws HL.Workspace|nil
--- @return boolean
local function is_temp(ws)
    return ws ~= nil and ws.name:sub(1, #temp_name) == temp_name
end

local function show_desktop()
    desktop_saved = {}
    desktop_busy = true
    for _, m in ipairs(hl.get_monitors()) do
        local id = shown_id(m.name)
        if id then
            desktop_saved[m.name] = id
            switch(m, temp_prefix .. m.name)
        end
    end
    desktop_busy = false
end

local function restore_desktop()
    local previous = desktop_saved
    desktop_saved = nil
    if not previous then return end

    desktop_busy = true
    for _, m in ipairs(hl.get_monitors()) do
        local id = previous[m.name]
        local mon = hl.get_monitor(m.name)
        local ws = id and hl.get_workspace(id)
        -- ws == nil: empty workspace was dropped; switching recreates it.
        if id and mon and is_temp(mon.active_workspace)
            and (not ws or (ws.monitor and ws.monitor.name == m.name)) then
            switch(m, id)
        end
    end
    desktop_busy = false
end

-------------------------------------------------------
-- Exports
-------------------------------------------------------

local M = {}

function M.toggle_desktop()
    if saved then return end
    if desktop_saved then
        restore_desktop()
    else
        show_desktop()
    end
end

--- @param args? string  nil/"" for the picker, "--mixer" for the mixer
function M.open(args)
    local cmd = picker_cmds[args or ""]
    if not cmd then return end

    -- Already open: skwd's single-instance guard turns this into a close.
    if saved then
        hl.dispatch(hl.dsp.exec_cmd(cmd))
        return
    end

    clear()
    hl.dispatch(hl.dsp.exec_cmd(string.format(
        "%s; sleep %.3f; %s", bar_hide_cmd, picker_start_delay_ms / 1000, cmd)))

    open_token = open_token + 1
    picker_seen = false
    local token = open_token
    hl.timer(function()
        if token == open_token and not picker_seen and saved then restore() end
    end, { timeout = open_timeout_ms, type = "oneshot" })
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

hl.on("layer.opened", function(layer)
    if namespace_of(layer) ~= picker_namespace then return end
    open_count = open_count + 1
    picker_seen = true
    -- Started without M.open().
    if open_count == 1 and not saved then
        clear()
        hl.dispatch(hl.dsp.exec_cmd(bar_hide_cmd))
    end
    animations_sync()
end)

hl.on("workspace.active", function()
    if not desktop_saved or desktop_busy then return end
    local ws = hl.get_active_workspace()
    if ws and not ws.special and not is_temp(ws) then restore_desktop() end
end)

hl.on("window.open", function(win)
    if not desktop_saved or not is_temp(win.workspace) then return end
    local id = win.monitor and desktop_saved[win.monitor.name]
    restore_desktop()
    if id then
        hl.dispatch(hl.dsp.window.move({ window = "address:" .. win.address, workspace = id, follow = true }))
    end
end)

hl.on("layer.closed", function(layer)
    if namespace_of(layer) ~= picker_namespace then return end
    open_count = math.max(open_count - 1, 0)
    if open_count > 0 then return end

    close_token = close_token + 1
    local token = close_token
    hl.timer(function()
        if token ~= close_token or open_count > 0 then return end
        restore()
    end, { timeout = restore_delay_ms, type = "oneshot" })
end)

return M
