--
-- conf/wallpaper.lua
-- Wallpaper-only view while the skwd-wall-v2 picker is open, and on SUPER+D
-- Reference: https://wiki.hypr.land/IPC/
--
-- M.toggle_desktop() (SUPER+D, see "Show desktop" below) reuses the same
-- empty temporary workspaces to show the bare wallpaper, but leaves animations
-- and the bar alone.
--
-- M.open() starts the picker (058-wallpaper.sh) in a fixed order: animations
-- off, every monitor switched to an empty temporary workspace, the Noctalia bar
-- hidden, and only then skwd-wall-v2. The bar is hidden by the same shell
-- command that starts the picker, so the picker never appears before
-- `bar-hide` has returned, and picker_start_delay_ms after it lets the cleared
-- screens settle first. Callers: the SUPER+SHIFT+W bind and, through
-- scripts/skwd-open.sh, both Noctalia bar actions (picker, mixer).
--
-- The picker is a layer surface, `skwd-wall`. When it closes the new wallpaper
-- is left alone on the empty screens for restore_delay_ms; then animations come
-- back first, so the switch off the temporary workspaces and the bar
-- reappearing are animated. The picker does not say whether a wallpaper
-- was picked or the dialog cancelled, so the wait happens either way. A picker
-- started some other way is still caught when its layer opens, just without
-- the ordering guarantee. Nothing is closed or moved: windows stay on their
-- workspaces.
--
-- Two API details that fail silently rather than raise:
--   * layer events pass the surface as userdata, not a table;
--   * Monitor:set_workspace takes a spec table, `{ workspace = <selector> }`,
--     and ignores a bare workspace (only logging "'workspace' is required").
-- set_workspace switches a monitor without moving focus or the cursor. Should
-- it not switch, the monitor is focused instead and focus and cursor are put
-- back.
--
-- The bar is driven through `noctalia msg`, asynchronously so the compositor
-- never waits on it. `bar-hide` keeps the bar's layer mapped, so its state is
-- read from `noctalia msg status` (`barVisible`) instead; a flag file records
-- that this module hid it, and a shared flock keeps hide and show in order
-- when the picker is opened and closed in quick succession. Noctalia animates
-- the bar itself, which only [shell.animation] in its own settings silences.
--

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

--- Layer namespace of the picker (not skwd-paper, the wallpaper itself).
local picker_namespace = "skwd-wall"

--- Accepted picker arguments -> command line.
local picker_cmds = {
    [""] = "skwd-wall-v2",
    ["--mixer"] = "skwd-wall-v2 --mixer",
}

--- Temporary workspaces are named <prefix><monitor>. Hyprland drops them once
--- they are empty and no longer shown, so restoring needs no cleanup.
local temp_prefix = "name:wallpaper-"

--- How long the wallpaper stays alone on screen after the picker closes.
local restore_delay_ms = 500

--- How long the cleared screens settle before the picker is started, on top of
--- whatever `bar-hide` itself takes.
local picker_start_delay_ms = 250

--- Give up and restore when open() started the picker but its layer never
--- appeared (skwd failed to start).
local open_timeout_ms = 5000

local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local bar_flag = runtime_dir .. "/hypr-wallpaper-bar-hidden"
local bar_lock = runtime_dir .. "/hypr-wallpaper-bar.lock"

local bar_hide_cmd = string.format(
    [[flock %s sh -c 'if noctalia msg status | grep -Eq "\"barVisible\": *true"; then noctalia msg bar-hide >/dev/null && touch %s; fi']],
    bar_lock, bar_flag)
local bar_show_cmd = string.format(
    [[flock %s sh -c '[ -e %s ] && rm -f %s && noctalia msg bar-show >/dev/null']],
    bar_lock, bar_flag, bar_flag)

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Picker surfaces currently open.
local open_count = 0

--- Monitor name -> workspace id shown before clear(); nil while windows show.
local saved = nil

--- True while animations are off because of this module. Never set when they
--- were already off, e.g. in gamemode, so this module only ever undoes its own
--- change.
local animations_owned = false

--- Bumped by every open() and every close, so a stale timer never acts on a
--- later session.
local open_token = 0
local close_token = 0

--- Whether the picker's layer has shown up since the last open().
local picker_seen = false

--- Namespace carried by a layer event, whichever form it arrives in.
--- @param layer HL.LayerSurface|string|nil
--- @return string|nil
local function namespace_of(layer)
    if layer == nil or type(layer) == "string" then return layer end
    return layer.namespace
end

--- Id of the workspace a monitor shows right now.
--- @param name string  monitor name
--- @return integer|nil
local function shown_id(name)
    local m = hl.get_monitor(name)
    local ws = m and m.active_workspace
    return ws and ws.id
end

--- Show `selector` on monitor `m`, preferring set_workspace; fall back to
--- focusing when the monitor did not change, then put focus and cursor back.
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

--- True while the wallpaper-only view should be up.
--- @return boolean
local function wallpaper_only()
    return open_count > 0 or saved ~= nil
end

--- Reconcile animations with the wanted state: off while the picker is up, on
--- again once it is gone. Called on every transition, so animations cannot stay
--- off past the last picker.
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

--- Animations off, then every monitor on an empty workspace. The bar is left
--- to the caller, so it can be ordered before the picker starts.
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

--- Animations back first, then workspaces and bar, so leaving the temporary
--- workspaces is animated like any other switch.
local function restore()
    -- Dropped before the sync, because wallpaper_only() reads it and would
    -- otherwise keep animations off.
    local previous = saved
    saved = nil
    animations_sync()

    if previous then
        for _, m in ipairs(hl.get_monitors()) do
            local id = previous[m.name]
            local ws = id and hl.get_workspace(id)
            -- Skip a workspace that has since moved to another monitor, so a
            -- restore never drags it back across screens.
            if ws and ws.monitor and ws.monitor.name == m.name and shown_id(m.name) ~= id then
                switch(m, id)
            end
        end
    end

    hl.dispatch(hl.dsp.exec_cmd(bar_show_cmd))
end

-------------------------------------------------------
-- Show desktop
-- SUPER+D: every monitor switches to its empty temporary workspace, the same
-- one the picker uses, so only the wallpaper shows; again, and each monitor
-- returns to what it showed. Windows are never moved or minimised. Leaving the
-- temporary workspace any other way ends it too: switching workspace by hand
-- brings the other monitors back, and a window opened on the bare desktop goes
-- to that monitor's previous workspace, which comes back with it.
-------------------------------------------------------

--- Monitor name -> workspace id shown before show_desktop(); nil while the
--- windows are shown.
local desktop_saved = nil

--- Set while show/restore switch workspaces, so the workspace.active listener
--- does not take those switches for the user leaving.
local desktop_busy = false

--- Workspace name of the temporary workspaces (the selector minus "name:").
local temp_name = temp_prefix:gsub("^name:", "")

--- Whether `ws` is one of the temporary workspaces.
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

--- Return every monitor still on its temporary workspace to the one it showed
--- before; a monitor switched elsewhere since keeps that choice.
local function restore_desktop()
    local previous = desktop_saved
    desktop_saved = nil
    if not previous then return end

    desktop_busy = true
    for _, m in ipairs(hl.get_monitors()) do
        local id = previous[m.name]
        local mon = hl.get_monitor(m.name)
        local ws = id and hl.get_workspace(id)
        -- An empty workspace was dropped when it went out of view (ws == nil);
        -- switching to its id recreates it. One that has moved to another
        -- monitor since is skipped, so it is never dragged back across screens.
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

--- Toggle the bare desktop (SUPER+D). Ignored while the picker's own
--- wallpaper-only view is up, which already shows nothing but the wallpaper.
function M.toggle_desktop()
    if saved then return end
    if desktop_saved then
        restore_desktop()
    else
        show_desktop()
    end
end

--- Open the picker: animations off, monitors cleared, bar hidden, then skwd.
--- While the picker is already open this only forwards the launch, which
--- skwd's single-instance guard turns into a toggle; the close restores.
--- @param args? string  nil/"" for the picker, "--mixer" for the mixer
function M.open(args)
    local cmd = picker_cmds[args or ""]
    if not cmd then return end

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
        -- Only for a picker that never appeared: a closed one is already on
        -- its way back through the delayed restore below.
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
    -- Started without M.open(): clear now, after the fact.
    if open_count == 1 and not saved then
        clear()
        hl.dispatch(hl.dsp.exec_cmd(bar_hide_cmd))
    end
    animations_sync()
end)

-- Switching workspace by hand (SUPER+<n>, the bar) ends the bare desktop.
hl.on("workspace.active", function()
    if not desktop_saved or desktop_busy then return end
    local ws = hl.get_active_workspace()
    if ws and not ws.special and not is_temp(ws) then restore_desktop() end
end)

-- A window opened on the bare desktop joins the workspace its monitor showed
-- before, and the windows come back.
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
