--
-- conf/keybinds.lua
-- All keybinds, organized by function
-- Reference: https://wiki.hypr.land/Configuring/Basics/Binds/
--

local notify = require("conf.notify")
local vanity = require("conf.vanity")
local workspaces = require("conf.workspaces")

-------------------------------------------------------
-- Constants
-------------------------------------------------------

local HOME = os.getenv("HOME") or ""
local SCREENSHOT_DIR = "~/Pictures/Screenshots"
local NOCTALIA = "qs -c noctalia-shell ipc call"
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

hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("pkill qs; qs -c noctalia-shell"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(HOME .. "/.local/share/quickshell-lockscreen/lock.sh"))


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

    local width, height = fractional_monitor_size(0.4)
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
    local y_offset = 45 -- Offset from top
    -- The `x = mon.x + ..` is necessary to place it on the current monitor
    hl.dispatch(hl.dsp.window.move({ x = mon.x + x_offset, y = y_offset }))
end

--- Change workspace layout.
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



-- Positioning
hl.bind("SUPER + SHIFT + C", hl.dsp.window.close())
hl.bind("SUPER + F", function() smart_float() end)
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + P", function() smart_pin() end)
hl.bind("SUPER + C", hl.dsp.window.center())

-- Mouse drag & resize
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Directional resize
hl.bind("SUPER + SHIFT + H", hl.dsp.window.resize({ x = -RESIZE_STEP, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.resize({ x = RESIZE_STEP, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -RESIZE_STEP, relative = true }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.resize({ x = 0, y = RESIZE_STEP, relative = true }))

-------------------------------------------------------
-- 3. Navigation (layout-aware)
-------------------------------------------------------

hl.bind("SUPER + H", layout_bind({
    master    = hl.dsp.focus({ direction = "left" }),
    dwindle   = hl.dsp.focus({ direction = "left" }),
    scrolling = hl.dsp.layout("focus l"),
}))
hl.bind("SUPER + L", layout_bind({
    master    = hl.dsp.focus({ direction = "right" }),
    dwindle   = hl.dsp.focus({ direction = "right" }),
    scrolling = hl.dsp.layout("focus r"),
}))
hl.bind("SUPER + K", layout_bind({
    master    = hl.dsp.focus({ direction = "up" }),
    dwindle   = hl.dsp.focus({ direction = "up" }),
    scrolling = hl.dsp.layout("focus u"),
}))
hl.bind("SUPER + J", layout_bind({
    master    = hl.dsp.focus({ direction = "down" }),
    dwindle   = hl.dsp.focus({ direction = "down" }),
    scrolling = hl.dsp.layout("focus d"),
}))

-------------------------------------------------------
-- 4. Workspaces
-------------------------------------------------------

for i = 1, 5 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind("SUPER + SHIFT + L", function() change_layout() end)
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special("communication"))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special:communication", follow = false }))
hl.bind("SUPER + space", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + SHIFT + space", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Swap workspaces between monitors
hl.bind("ALT + TAB", function()
    local monitors = hl.get_monitors()
    if not monitors or #monitors < 2 then return end
    hl.dispatch(hl.dsp.workspace.swap_monitors({
        monitor1 = monitors[1].id,
        monitor2 = monitors[2].id,
    }))
end)

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
end)

-------------------------------------------------------
-- 5. Launchers
-------------------------------------------------------

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar ~"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("kitty -e yazi ~"))

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
    end)
end

hl.bind("CTRL + ALT + Y", function()
    youtube_to_mpv()
end)

hl.bind("CTRL + ALT + N", function()
    notify.info("Opening Netflix")
    spawn_and_pin(
        "brave --ozone-platform=wayland --app=https://www.netflix.com/browse",
        { class = "brave" }
    )
end)

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
})

-------------------------------------------------------
-- 7. Tools
-------------------------------------------------------

-- Hyprland logging
hl.bind("SUPER + F2",
    function()
        local update_script = table.concat({
            "hyprctl rollinglog -f | grep lua",
        })

        local cmd = "kitty -o font_size=6 -e bash -c " .. ("%q"):format(update_script)
        spawn_and_pin(cmd, { class = "kitty" })
    end
)


-- System update
hl.bind("CTRL + ALT + U",
    function()
        local update_script = table.concat({
            "yay -Syu",
        })

        local cmd = "kitty -o font_size=6 -e bash -c " .. ("%q"):format(update_script)
        spawn_and_pin(cmd, { class = "kitty" })
    end
)

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -m active -z -o " .. SCREENSHOT_DIR))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window -z -o " .. SCREENSHOT_DIR))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -z -o " .. SCREENSHOT_DIR))
hl.bind("CTRL + ALT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/capture.sh"))

-- Color picker
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

-- Zoom toggle
hl.bind("SUPER + SHIFT + Z", function()
    hl.dispatch(hl.dsp.submap("reset"))
    hl.exec_cmd("hypr-zoom -duration=250 -steps=150 -easing=OutBack -easingOut=InBack -interp=Linear")
end)

-- Scroll zoom
hl.bind("SUPER + mouse_down", function()
    local current = hl.get_config("cursor:zoom_factor")
    hl.config({ cursor = { zoom_factor = current * ZOOM_IN } })
end)
hl.bind("SUPER + mouse_up", function()
    local current = hl.get_config("cursor:zoom_factor")
    hl.config({ cursor = { zoom_factor = math.max(current * ZOOM_OUT, 1.0) } })
end)
hl.bind("SUPER + mouse:274", function()
    hl.config({ cursor = { zoom_factor = 1.0 } })
end)

-- Matrix background toggle
hl.bind("CTRL + ALT + M", hl.dsp.exec_cmd(
    "pkill cmatrix || kitty +kitten panel --edge=background -o font_size=12 cmatrix -a -b -u 2 -r"
))

-------------------------------------------------------
-- 8. Utility toggles (F-keys)
-------------------------------------------------------

hl.bind("SUPER + F1", function() vanity.toggle_gamemode() end)
hl.bind("SUPER + F5", function() workspaces.toggle_chinese_names() end)

-------------------------------------------------------
-- 9. Hardware keys
-------------------------------------------------------

-- Audio transport
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-------------------------------------------------------
-- 10. Noctalia overrides
-------------------------------------------------------

hl.unbind("SUPER + R")
hl.unbind("SUPER + S")
hl.unbind("SUPER + SHIFT + Q")
hl.unbind("XF86MonBrightnessUp")
hl.unbind("XF86MonBrightnessDown")

hl.bind("SUPER + R", noctalia("launcher toggle"))
hl.bind("SUPER + S", noctalia("controlCenter toggle"))
hl.bind("SUPER + SHIFT + Q", noctalia("sessionMenu toggle"))
hl.bind("CTRL + ALT + W", noctalia("plugin:wallcards toggle"))

hl.bind("XF86MonBrightnessUp", noctalia("brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", noctalia("brightness decrease"), { locked = true, repeating = true })
