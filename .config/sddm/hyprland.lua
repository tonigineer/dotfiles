--
-- hyprland.lua
-- Hyprland as the Wayland compositor for the SDDM greeter.
-- Self-contained: this file is copied to /var/lib/sddm/.config/hypr/ by the
-- greeter installer and runs without the ~/Dotfiles conf.* modules, so it does
-- not require() anything.
-- Reference: https://wiki.hypr.land/Configuring/Start/
--

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

--- Cursor theme applied to the greeter (env + hyprctl + gsettings).
local cursor = {
    theme = "Bibata-Modern-Ice",
    size  = 24,
}

--- Monitor rules. `desc:` must match `hyprctl monitors` (without the port suffix).
--- Mirror of conf/monitors.lua; the secondary panel stays dark at the greeter.
local monitors = {
    {
        output   = "desc:ASUSTek COMPUTER INC ROG XG27UQR R4LMQS097007",
        disabled = true,
    },
    {
        output   = "desc:ASUSTek COMPUTER INC PG27UQR R7LMQS169187",
        mode     = "highres@highrr",
        position = "auto-right",
        scale    = "2.0",
    },
}

--- Cursor environment (matches conf/themes.lua's active theme).
local env = {
    { "XCURSOR_THEME",   cursor.theme },
    { "XCURSOR_SIZE",    cursor.size  },
    { "HYPRCURSOR_THEME", cursor.theme },
    { "HYPRCURSOR_SIZE",  cursor.size  },
}

-------------------------------------------------------
-- Apply
-------------------------------------------------------

for _, var in ipairs(env) do
    hl.env(var[1], tostring(var[2]))
end

for _, m in ipairs(monitors) do
    hl.monitor(m)
end

-- Force the cursor into the compositor and the GTK/gnome interface, since the
-- greeter has no theming shell to do it (parity with conf/themes.lua).
hl.exec_cmd(string.format("hyprctl setcursor %s %d", cursor.theme, cursor.size))
hl.exec_cmd(string.format(
    "gsettings set org.gnome.desktop.interface cursor-theme '%s'", cursor.theme
))

hl.config({
    -- No motion at the login screen — snappier and avoids first-frame flicker.
    animations = {
        enabled = false,
    },
    cursor = {
        hide_on_key_press = true,
        inactive_timeout = 1,
    },
    -- Flat, opaque, no effects: the greeter draws over a solid background.
    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    input = {
        kb_layout    = "us",
        kb_options   = "compose:ralt, ctrl:nocaps",
        repeat_delay = 250,
        repeat_rate  = 50,
    },
    misc = {
        -- The greeter config never changes at runtime; skip the file watcher.
        disable_autoreload   = true,
        disable_hyprland_logo = true,
    },
})
