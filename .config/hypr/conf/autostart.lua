--
-- conf/autostart.lua
-- Programs and services launched on Hyprland start
-- Reference: https://wiki.hypr.land/Configuring/Basics/Autostart/
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local cmds = {
    { cmd = "gnome-keyring-daemon --restart --components=secrets",                                                      label = "Keyring" },
    { cmd = "killall -9 qs; killall -9 quickshell; QS_NO_RELOAD_POPUP=1 QML_DISABLE_DISK_CACHE=1 qs -c noctalia-shell", label = "Noctalia Shell" },
    { cmd = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",                         label = "DBus Env" },
    { cmd = 'openrgb -d "$(openrgb -l | awk -F\': \' \'/Razer Leviathan V2 X/{print $1; exit}\')" -c 000000',           label = "OpenRGB" },
    { cmd = "hyprctl dispatch workspace 1",                                                                             label = "Workspace" },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Execute a command, notify on failure.
--- @param cmd string
--- @param label string
local function exec_or_notify(cmd, label)
    hl.exec_cmd(string.format('%s || %s "%s failed"', cmd, notify.ERROR, label))
end

-------------------------------------------------------
-- Autostart
-------------------------------------------------------

hl.on("hyprland.start", function()
    for _, entry in ipairs(cmds) do
        exec_or_notify(entry.cmd, entry.label)
    end
    hl.exec_cmd(string.format('%s "Autostart complete"', notify.SUCCESS))
end)
