--
-- hyprland.lua
-- Hyprland config for the SDDM greeter; self-contained, as conf.* is not available there
-- Reference: https://wiki.hypr.land/Configuring/Start/
--

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local cursor = {
    theme = "Bibata-Modern-Ice",
    size  = 24,
}

--- The secondary panel stays dark at the greeter.
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

-- No theming shell runs at the greeter, so set the cursor here.
hl.exec_cmd(string.format("hyprctl setcursor %s %d", cursor.theme, cursor.size))
hl.exec_cmd(string.format(
    "gsettings set org.gnome.desktop.interface cursor-theme '%s'", cursor.theme
))

hl.config({
    -- No animations: avoids first-frame flicker at the greeter
    animations = {
        enabled = false,
    },
    cursor = {
        hide_on_key_press = true,
        inactive_timeout = 1,
    },
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
        disable_autoreload   = true,      -- config never changes at runtime
        disable_hyprland_logo = true,
    },
})
