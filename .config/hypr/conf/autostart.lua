--
-- conf/autostart.lua
-- Programs and services launched on Hyprland start
-- Reference: https://wiki.hypr.land/Configuring/Basics/Autostart/
--

local notify = require("conf.notify")

--- True when `path` exists.
--- @param path string
--- @return boolean
local function exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
end

local HOME         = os.getenv("HOME") or ""
local SHELL_SWITCH = HOME .. "/.local/bin/shell-switch"
local KRAKEN_LCD   = HOME .. "/.local/bin/kraken-lcd"

-- Host-specific hardware, see conf/hosts/<hostname>.lua.
local profile       = require("conf.host").profile()
local has_kraken    = profile.kraken_lcd == true and exists(KRAKEN_LCD)
local has_leviathan = profile.razer_leviathan == true

-------------------------------------------------------
-- Command builders
-------------------------------------------------------

--- Wrap a command in a shell retry loop; exits 1 only if every attempt failed.
--- @param command string
--- @param tries integer
--- @param delay integer   seconds between attempts
--- @return string
local function retry(command, tries, delay)
    return string.format(
        'i=0; until %s; do i=$((i+1)); [ "$i" -ge %d ] && exit 1; sleep %d; done',
        command, tries, delay
    )
end

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local cmds = {
    { label = "Keyring",        cmd = "gnome-keyring-daemon --restart --components=secrets" },
    -- shell-switch restores whichever shell was picked last.
    { label = "Shell",          cmd = exists(SHELL_SWITCH) and SHELL_SWITCH .. " restore" or "noctalia" },
    { label = "DBus Env",       cmd = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" },
    -- The Leviathan sometimes fails to enumerate at login, hence the retry.
    -- Targeted by name: `-l` indices shift between scans.
    { label = "OpenRGB",        cmd = retry('openrgb -d "Razer Leviathan V2 X" -c 000000', 10, 1), when = has_leviathan },
    { label = "Kraken LCD",     cmd = KRAKEN_LCD .. " pixel", when = has_kraken },
    -- WORKAROUND: workspace 6 appears at login otherwise. TODO: fix it.
    { label = "Workspace",      cmd = 'hyprctl dispatch "hl.dsp.focus({ workspace = 5 })"' },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Execute a command, notify on failure.
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
        if entry.when ~= false then
            exec_or_notify(entry.cmd, entry.label)
        end
    end
end)

-------------------------------------------------------
-- Kraken LCD
-- Fires on every config load; kraken-lcd no-ops when the mode is unchanged.
-------------------------------------------------------

if has_kraken then
    require("conf.vanity").on_gamemode_change(function(is_on)
        hl.exec_cmd(string.format(
            "%s %s", KRAKEN_LCD, is_on and "doom" or "pixel"
        ))
    end)
end
