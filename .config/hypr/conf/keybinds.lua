--
-- conf/keybinds.lua
-- All keybinds, organized by function
-- Reference: https://wiki.hypr.land/Configuring/Basics/Binds/
--

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

hl.bind("SUPER + SHIFT + C", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pin())
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

-- stylua: ignore start
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
-- stylua: ignore end

-------------------------------------------------------
-- 4. Workspaces
-------------------------------------------------------

for i = 1, 6 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special())
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special", follow = false }))

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
-- 6. Media & PIP
-------------------------------------------------------

-- stylua: ignore start
local PIP_RULE  = "[noinitialfocus; float; size monitor_w*0.35 monitor_h*0.35; move monitor_w*0.60 monitor_h*0.05; monitor 1; pin]"
local FLOAT_RULE = "[float; size monitor_w*0.35 monitor_h*0.35; move monitor_w*0.60 monitor_h*0.05; monitor 1; pin]"
-- stylua: ignore end

-- Cast browser media to mpv
hl.bind("CTRL + ALT + Y", hl.dsp.exec_cmd(
    PIP_RULE .. " sh -c '"
    .. "url=$(playerctl -p firefox metadata xesam:url);"
    .. " start=$(playerctl -p firefox position);"
    .. " playerctl -p firefox stop;"
    .. " mpv --start=\"$start\" \"$url\"'"
))

-- Netflix
hl.bind("CTRL + ALT + N", hl.dsp.exec_cmd(
    FLOAT_RULE .. " brave --ozone-platform=wayland --app=https://www.netflix.com/browse"
))

-- Live TV stream picker
hl.bind("SUPER + F9", hl.dsp.exec_cmd(
    PIP_RULE .. " printf '%s\\n' "
    .. "'Das Erste | https://daserste-live.ard-mcdn.de/daserste/live/hls/de/master.m3u8' "
    .. "'ZDF       | https://zdf-hls-15.akamaized.net/hls/live/2016498/de/high/master.m3u8' "
    .. "'Phoenix   | https://zdf-hls-19.akamaized.net/hls/live/2016502/de/high/master.m3u8' "
    .. "| walker -d 'Select stream' --minheight 3 "
    .. "| cut -d'|' -f2- "
    .. "| xargs -r sh -lc 'mpv \"$1\"' sh"
))

-------------------------------------------------------
-- 7. Tools
-------------------------------------------------------

-- System update
hl.bind("CTRL + ALT + U", hl.dsp.exec_cmd(
    FLOAT_RULE .. " kitty -o font_size=8 -e bash -lc '"
    .. 'yay -Syu || { code=$?; echo; echo "yay failed (exit $code)"; '
    .. "read -n1 -r -p \"Press any key to close...\"; }'"
))

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
-- 8. Toggles (F-keys)
-------------------------------------------------------

hl.bind("SUPER + F1", function() vanity.toggle_gamemode() end)
hl.bind("SUPER + F6", function() workspaces.toggle_chinese_names() end)

-- TESTGIN
local function beep(sound)
  sound = sound or "system-shutdown"
  return function()
    hl.exec_cmd("canberra-gtk-play -i " .. sound)
  end
end
hl.bind("SUPER + F7", function() beep() end)

-------------------------------------------------------
-- 9. Hardware keys
-------------------------------------------------------

-- Audio transport
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })

-------------------------------------------------------
-- 10. Noctalia overrides
-------------------------------------------------------

hl.unbind("SUPER + R")
hl.unbind("SUPER + S")
hl.unbind("SUPER + SHIFT + Q")
hl.unbind("XF86MonBrightnessUp")
hl.unbind("XF86MonBrightnessDown")

hl.bind("SUPER + R",         noctalia("launcher toggle"))
hl.bind("SUPER + S",         noctalia("controlCenter toggle"))
hl.bind("SUPER + SHIFT + Q", noctalia("sessionMenu toggle"))
hl.bind("CTRL + ALT + W",    noctalia("plugin:wallcards toggle"))

hl.bind("XF86MonBrightnessUp",   noctalia("brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", noctalia("brightness decrease"), { locked = true, repeating = true })
