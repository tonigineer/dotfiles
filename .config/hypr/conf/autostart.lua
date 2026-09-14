--
-- conf/autostart.lua
-- Programs and services launched on Hyprland start
-- Reference: https://wiki.hypr.land/Configuring/Basics/Autostart/
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Command builders
-- Non-trivial autostart commands are assembled here so the list below stays
-- declarative. Add a builder whenever an entry needs more than a plain command.
-------------------------------------------------------

--- Wrap a command in a shell retry loop.
--- Useful for autostart tasks that race hardware/services still coming up at
--- login: retries until the command succeeds, then `exit 1` only if every
--- attempt failed (so the `|| notify` chain still fires on a real failure).
--- @param command string  shell command to run
--- @param tries integer   maximum attempts before giving up
--- @param delay integer   seconds to wait between attempts
--- @return string         an `sh`-compatible one-liner
local function retry(command, tries, delay)
    return string.format(
        'i=0; until %s; do i=$((i+1)); [ "$i" -ge %d ] && exit 1; sleep %d; done',
        command, tries, delay
    )
end

-------------------------------------------------------
-- Configuration
-- Each entry: label = name shown in the failure notice, cmd = shell to run.
-- The comment above each entry documents *why* it is in autostart.
-------------------------------------------------------

local cmds = {
    { label = "Keyring",        cmd = "gnome-keyring-daemon --restart --components=secrets" },
    { label = "Noctalia Shell", cmd = "noctalia" },
    -- Export the Wayland session vars into the systemd/D-Bus activation env so
    -- portals and user services spawn with the correct environment.
    { label = "DBus Env",       cmd = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" },
    -- Turn the Razer Leviathan LEDs off. This USB HID device intermittently
    -- fails to enumerate on a cold scan at login, so retry until OpenRGB sees
    -- it. Targeted by name (not a `-l` index, which shifts between scans).
    { label = "OpenRGB",        cmd = retry('openrgb -d "Razer Leviathan V2 X" -c 000000', 10, 1) },
    -- Push the cooler's login animation. The gamemode listener below also
    -- fires on config load, but only `hyprland.start` is a documented event, so
    -- the login push is anchored here. `kraken-lcd` is locked and boot-scoped,
    -- so whichever call arrives first pushes and the other is a no-op.
    { label = "Kraken LCD",     cmd = "/home/toni/.local/bin/kraken-lcd pixel" },
    -- Land on workspace 5 once everything else is up (WORKAROUND for workspace 6 appearing; TODO: fix it).
    { label = "Workspace",      cmd = 'hyprctl dispatch "hl.dsp.focus({ workspace = 5 })"' },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Execute a command, notify on failure.
--- The failure notice runs in the shell `||` chain, so it uses the hyprctl
--- notification builder rather than the in-process Lua API.
--- @param cmd string
--- @param label string
local function exec_or_notify(cmd, label)
    hl.exec_cmd(string.format('%s || %s', cmd, notify.shell("error", "Autostart: " .. label .. " failed")))
end

-------------------------------------------------------
-- Autostart
-------------------------------------------------------

hl.on("hyprland.start", function()
    for _, entry in ipairs(cmds) do
        exec_or_notify(entry.cmd, entry.label)
    end
end)

-------------------------------------------------------
-- Kraken LCD
-- Swap the cooler's LCD animation with the vanity gamemode toggle (SUPER+F1).
-- Login is handled by the "Kraken LCD" autostart entry above; this listener only
-- has to follow the toggle. It runs from apply_gamemode(), which fires on every
-- config load, but `kraken-lcd` no-ops when the mode is unchanged for the
-- current boot, so the repeated reload calls cost nothing (a real push is a
-- multi-MB USB transfer taking seconds).
-------------------------------------------------------

require("conf.vanity").on_gamemode_change(function(is_on)
    hl.exec_cmd(string.format(
        "/home/toni/.local/bin/kraken-lcd %s", is_on and "doom" or "pixel"
    ))
end)
