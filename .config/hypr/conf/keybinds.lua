--
-- conf/keybinds.lua
-- All keybinds, organized by function
-- Reference: https://wiki.hypr.land/Configuring/Basics/Binds/
--

local notify = require("conf.notify")
local vanity = require("conf.vanity")
local workspaces = require("conf.workspaces")
local themes = require("conf.themes")
local dvdbounce = require("conf.dvdbounce")

-------------------------------------------------------
-- Constants
-------------------------------------------------------

local HOME = os.getenv("HOME") or ""
local SCREENSHOT_DIR = "~/Pictures/Screenshots"
local NOCTALIA = "noctalia msg"
local RESIZE_STEP = 50
local ZOOM_IN = 1.1
local ZOOM_OUT = 0.9

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Dispatch based on active workspace layout.
--- @param bind_table table<string, table> layout name → dispatcher
--- @return function
local function layout_bind(bind_table)
    return function()
        local ws = hl.get_active_workspace()
        local layout = ws and ws.tiled_layout or "master"
        if bind_table[layout] then
            hl.dispatch(bind_table[layout])
        end
    end
end

--- Noctalia IPC shorthand.
--- @param action string
--- @return table
local function noctalia(action)
    return hl.dsp.exec_cmd(NOCTALIA .. " " .. action)
end

-------------------------------------------------------
-- 1. Session
-------------------------------------------------------

hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { desc = "Reload Hyprland config" })
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("pkill noctalia; sleep 0.1; noctalia"), { desc = "Restart Noctalia shell" })
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(HOME .. "/.local/share/quickshell-lockscreen/lock.sh"),
    { desc = "Lock screen" })

-------------------------------------------------------
-- 2. Window management
-------------------------------------------------------

--- Get half-monitor dimensions for floating/pinning.
--- @param fraction number?
--- @return number width, number height
local function fractional_monitor_size(fraction)
    if not fraction then
        fraction = 0.5
    end

    local mon = hl.get_active_monitor()
    if not mon then return 1920, 1080 end

    local mw = mon.width / mon.scale
    local mh = mon.height / mon.scale
    return math.floor(mw * fraction), math.floor(mh * fraction)
end

--- Toggle smart float for the active window.
local function smart_float()
    local w = hl.get_active_window()
    if not w then return end

    if w.pinned then return end

    if w.floating then
        hl.dispatch(hl.dsp.window.float())
        return
    end

    local width, height = fractional_monitor_size(0.55)
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = width, y = height, exact = true }))
    hl.dispatch(hl.dsp.window.center())
end

--- Toggle smart pin for the active window.
local function smart_pin()
    local w = hl.get_active_window()
    if not w then
        return
    end

    if w.pinned then
        hl.dispatch(hl.dsp.window.pin())
        return
    end

    if not w.floating then
        hl.dispatch(hl.dsp.window.float())
    end

    local width, height = fractional_monitor_size(0.3)

    local mon = hl.get_active_monitor()
    if not mon then return end

    hl.dispatch(hl.dsp.window.resize({ x = width, y = height, exact = true }))
    hl.dispatch(hl.dsp.window.pin())

    local x_offset = (mon.width / mon.scale) - width + 80 -- Offset from top right
    local y_offset = 45                                   -- Offset from top
    -- The `x = mon.x + ..` is necessary to place it on the current monitor
    hl.dispatch(hl.dsp.window.move({ x = mon.x + x_offset, y = y_offset }))
end

-- Positioning
hl.bind("SUPER + SHIFT + C", hl.dsp.window.close(), { desc = "Close active window" })
hl.bind("SUPER + F", function() smart_float() end, { desc = "Toggle float (sized & centered)" })
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ action = "toggle" }), { desc = "Toggle fullscreen" })
hl.bind("SUPER + P", function() smart_pin() end, { desc = "Toggle pin (corner picture-in-picture)" })
hl.bind("SUPER + C", hl.dsp.window.center(), { desc = "Center active window" })

-- Mouse drag & resize
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, desc = "Drag window with mouse" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, desc = "Resize window with mouse" })

-- Directional resize
hl.bind("SUPER + SHIFT + H", hl.dsp.window.resize({ x = -RESIZE_STEP, y = 0, relative = true }),
    { desc = "Shrink window horizontally" })
hl.bind("SUPER + SHIFT + L", hl.dsp.window.resize({ x = RESIZE_STEP, y = 0, relative = true }),
    { desc = "Grow window horizontally" })
hl.bind("SUPER + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -RESIZE_STEP, relative = true }),
    { desc = "Shrink window vertically" })
hl.bind("SUPER + SHIFT + J", hl.dsp.window.resize({ x = 0, y = RESIZE_STEP, relative = true }),
    { desc = "Grow window vertically" })

-------------------------------------------------------
-- 3. Navigation (layout-aware)
-------------------------------------------------------

hl.bind("SUPER + H", layout_bind({
    master    = hl.dsp.focus({ direction = "left" }),
    dwindle   = hl.dsp.focus({ direction = "left" }),
    scrolling = hl.dsp.layout("focus l"),
}), { desc = "Focus window left" })
hl.bind("SUPER + L", layout_bind({
    master    = hl.dsp.focus({ direction = "right" }),
    dwindle   = hl.dsp.focus({ direction = "right" }),
    scrolling = hl.dsp.layout("focus r"),
}), { desc = "Focus window right" })
hl.bind("SUPER + K", layout_bind({
    master    = hl.dsp.focus({ direction = "up" }),
    dwindle   = hl.dsp.focus({ direction = "up" }),
    scrolling = hl.dsp.layout("focus u"),
}), { desc = "Focus window up" })
hl.bind("SUPER + J", layout_bind({
    master    = hl.dsp.focus({ direction = "down" }),
    dwindle   = hl.dsp.focus({ direction = "down" }),
    scrolling = hl.dsp.layout("focus d"),
}), { desc = "Focus window down" })

-------------------------------------------------------
-- 4. Workspaces
-------------------------------------------------------

--- Toggle the active workspace between the master and scrolling layouts.
local function change_layout()
    local ws = hl.get_active_workspace()
    if not ws then
        return
    end
    local new_layout = ws.tiled_layout == "master" and "scrolling" or "master"
    hl.workspace_rule({
        workspace = tostring(ws.id),
        layout = new_layout,
    })
    notify.info("Layout changed to: " .. new_layout)
end

for i = 1, 5 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }), { desc = "Switch to workspace " .. i })
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }),
        { desc = "Move window to workspace " .. i })
end
hl.bind("SUPER + S", function() change_layout() end, { desc = "Toggle master/scrolling layout" })
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special("communication"),
    { desc = "Toggle communication scratchpad" })
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special:communication", follow = false }),
    { desc = "Move window to communication scratchpad" })
hl.bind("SUPER + space", hl.dsp.workspace.toggle_special("scratchpad"), { desc = "Toggle scratchpad" })
hl.bind("SUPER + SHIFT + space", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }),
    { desc = "Move window to scratchpad" })

-- Swap workspaces between monitors
hl.bind("ALT + TAB", function()
    local monitors = hl.get_monitors()
    if not monitors or #monitors < 2 then return end
    hl.dispatch(hl.dsp.workspace.swap_monitors({
        monitor1 = monitors[1].id,
        monitor2 = monitors[2].id,
    }))
end, { desc = "Swap workspaces between monitors" })

-- Move active workspace to the other monitor
hl.bind("ALT + SHIFT + TAB", function()
    local monitors = hl.get_monitors()
    if not monitors or #monitors < 2 then return end
    for _, m in ipairs(monitors) do
        if not m.focused then
            hl.dispatch(hl.dsp.workspace.move({ monitor = m.id }))
            hl.dispatch(hl.dsp.focus({ monitor = m.id }))
            break
        end
    end
end, { desc = "Move active workspace to other monitor" })

-------------------------------------------------------
-- 5. Launchers
-------------------------------------------------------

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"), { desc = "Launch terminal (kitty)" })
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar ~"), { desc = "Launch file manager (thunar)" })
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("kitty -e yazi ~"), { desc = "Launch file manager (yazi)" })

-------------------------------------------------------
-- 6. Media Streaming
-------------------------------------------------------

--- Spawn a command and apply smart_pin once its window appears.
--- @param cmd string
--- @param match table
local function spawn_and_pin(cmd, match)
    -- TODO: Does not work properly when having a fullscreen app the active monitor
    local handler
    handler = hl.on("window.open", function(win)
        if match.class and not win.class:find(match.class) then return end
        if match.title and not win.title:find(match.title) then return end
        smart_pin()
        handler:remove()
    end)
    hl.dispatch(hl.dsp.exec_cmd(cmd))
end

--- Read a shell command's stdout (with stderr), trimmed.
--- @param cmd string
--- @return string
local function shell(cmd)
    local handle = io.popen(cmd .. " 2>&1")
    if not handle then return "" end
    local out = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    return out
end

--- Cast the current Firefox media to mpv.
local function youtube_to_mpv()
    local url = shell("playerctl -p firefox metadata xesam:url")
    local start = shell("playerctl -p firefox position")
    local output = shell("playerctl -p firefox stop")

    if output:find("No players found") then
        notify.error("No YouTube video is currently playing.")
        return
    end

    notify.success("Casting YouTube to MPV")
    spawn_and_pin(
        'mpv --start="' .. start .. '" "' .. url .. '"',
        { class = "mpv" }
    )
end

local tv_channels = {
    { key = "SUPER + F9",  name = "Das Erste", url = "https://daserste-live.ard-mcdn.de/daserste/live/hls/de/master.m3u8" },
    { key = "SUPER + F10", name = "ZDF",       url = "https://zdf-hls-15.akamaized.net/hls/live/2016498/de/high/master.m3u8" },
    { key = "SUPER + F11", name = "Phoenix",   url = "https://zdf-hls-19.akamaized.net/hls/live/2016502/de/high/master.m3u8" },
}

for _, ch in ipairs(tv_channels) do
    hl.bind(ch.key, function()
        notify.success("Streaming " .. ch.name)
        spawn_and_pin("mpv " .. ch.url, { class = "mpv" })
    end, { desc = "Stream " .. ch.name .. " live TV" })
end

hl.bind("CTRL + ALT + Y", function()
    youtube_to_mpv()
end, { desc = "Cast Firefox video to mpv" })

hl.bind("CTRL + ALT + N", function()
    notify.info("Opening Netflix")
    spawn_and_pin(
        "brave --ozone-platform=wayland --app=https://www.netflix.com/browse",
        { class = "brave" }
    )
end, { desc = "Open Netflix in a pinned window" })

-- Allowj dragging pinned windows with middle mouse drag
hl.bind("mouse:274", function()
    local w = hl.get_active_window()
    if not w then return end
    if w.pinned then
        hl.dispatch(hl.dsp.window.drag())
    end
end, {
    mouse = true,
    non_consuming = true,
    desc = "Drag pinned window with middle mouse",
})

-------------------------------------------------------
-- 7. Tools
-------------------------------------------------------

-- System update
hl.bind("CTRL + ALT + U",
    function()
        local update_script = table.concat({
            "yay -Syu",
        })

        local cmd = "kitty -o font_size=6 -e bash -c " .. ("%q"):format(update_script)
        spawn_and_pin(cmd, { class = "kitty" })
    end,
    { desc = "Run system update (yay -Syu)" }
)

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -m active -z -o " .. SCREENSHOT_DIR),
    { desc = "Screenshot active monitor" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window -z -o " .. SCREENSHOT_DIR),
    { desc = "Screenshot active window" })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -z -o " .. SCREENSHOT_DIR),
    { desc = "Screenshot region" })
hl.bind("CTRL + ALT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/capture.sh"),
    { desc = "Screen capture / record" })

-- Color picker
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"), { desc = "Pick color to clipboard" })

-- Zoom toggle
hl.bind("SUPER + SHIFT + Z", function()
    hl.dispatch(hl.dsp.submap("reset"))
    hl.exec_cmd("hypr-zoom -duration=250 -steps=150 -easing=OutBack -easingOut=InBack -interp=Linear")
end, { desc = "Toggle animated screen zoom" })

-- Scroll zoom
hl.bind("SUPER + mouse_up", function()
    local current = hl.get_config("cursor:zoom_factor")
    hl.config({ cursor = { zoom_factor = current * ZOOM_IN } })
end, { desc = "Zoom screen in" })
hl.bind("SUPER + mouse_down", function()
    local current = hl.get_config("cursor:zoom_factor")
    hl.config({ cursor = { zoom_factor = math.max(current * ZOOM_OUT, 1.0) } })
end, { desc = "Zoom screen out" })
hl.bind("SUPER + mouse:274", function()
    hl.config({ cursor = { zoom_factor = 1.0 } })
end, { desc = "Reset screen zoom" })

-- Matrix background toggle
hl.bind("CTRL + ALT + M", hl.dsp.exec_cmd(
    "pkill cmatrix || kitty +kitten panel --edge=background -o font_size=12 cmatrix -a -b -u 2 -r"
), { desc = "Toggle cmatrix background" })

-------------------------------------------------------
-- 8. Utility toggles (F-keys)
-------------------------------------------------------

--- Toggle all non-active monitors off/on. Disabled monitors drop out of
--- `hl.get_monitors()`, so their config is captured here to restore them.
local saved_monitors = {}

local function toggle_secondary_monitors()
    local active = hl.get_active_monitor()
    if not active then return end

    if #saved_monitors > 0 then
        -- Restore: re-enable previously disabled monitors with their config.
        for _, m in ipairs(saved_monitors) do
            hl.monitor({
                output    = m.name,
                mode      = m.mode,
                position  = m.position,
                scale     = m.scale,
                transform = m.transform,
                disabled  = false,
            })
        end
        saved_monitors = {}
        notify.info("Secondary monitors enabled")
        return
    end

    -- Disable: capture each non-active monitor's config, then turn it off.
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.id ~= active.id then
            table.insert(saved_monitors, {
                name      = mon.name,
                mode      = string.format("%dx%d@%.5f", mon.width, mon.height, mon.refresh_rate),
                position  = string.format("%dx%d", mon.x, mon.y),
                scale     = mon.scale,
                transform = mon.transform,
            })
            hl.monitor({ output = mon.name, disabled = true })
        end
    end

    if #saved_monitors > 0 then
        notify.info("Secondary monitors disabled")
    end
end

--- Tail the Hyprland Lua log in a pinned kitty panel.
local function hyprland_logging()
    local cmd = "kitty -o font_size=6 -e bash -c " .. ("%q"):format("hyprctl rollinglog -f | grep lua")
    spawn_and_pin(cmd, { class = "kitty" })
end

hl.bind("SUPER + F1", function() vanity.toggle_gamemode() end, { desc = "Toggle gamemode (no animations)" })
hl.bind("SUPER + F2", function() hyprland_logging() end, { desc = "Tail Hyprland Lua log" })
hl.bind("SUPER + F3", function() dvdbounce.toggle() end, { desc = "Toggle DVD bounce" })
hl.bind("SUPER + F4", function() themes.toggle_cursor() end, { desc = "Toggle cursor theme" })
hl.bind("SUPER + F5", function() workspaces.toggle_chinese_names() end, { desc = "Toggle Chinese workspace names" })
hl.bind("SUPER + F8", function() toggle_secondary_monitors() end, { desc = "Toggle secondary monitors" })

-------------------------------------------------------
-- 9. Hardware keys
-------------------------------------------------------

-- Audio transport
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Play / pause media" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Play / pause media" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, desc = "Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, desc = "Previous track" })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"),
    { locked = true, repeating = true, desc = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%-"),
    { locked = true, repeating = true, desc = "Lower volume" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, desc = "Mute output" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, desc = "Mute microphone" })

-------------------------------------------------------
-- 10. Noctalia overrides
-------------------------------------------------------

hl.unbind("SUPER + R")
hl.unbind("SUPER + SHIFT + Q")
hl.unbind("XF86MonBrightnessUp")
hl.unbind("XF86MonBrightnessDown")

hl.bind("SUPER + R", noctalia("panel-toggle launcher"), { desc = "Toggle app launcher" })
hl.bind("SUPER + SHIFT + Q", noctalia("panel-toggle session"), { desc = "Toggle session menu" })
hl.bind("CTRL + ALT + W", noctalia("plugin:wallcards toggle"), { desc = "Toggle wallpaper picker" })
hl.bind("SUPER + BackSpace", noctalia("panel-toggle kenn/keybind-cheatsheet:cheatsheet"),
    { desc = "Toggle keybind cheatsheet" })

hl.bind("XF86MonBrightnessUp", noctalia("brightness increase"),
    { locked = true, repeating = true, desc = "Raise screen brightness" })
hl.bind("XF86MonBrightnessDown", noctalia("brightness decrease"),
    { locked = true, repeating = true, desc = "Lower screen brightness" })
