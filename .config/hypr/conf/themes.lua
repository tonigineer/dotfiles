--
-- conf/theme.lua
-- GTK theme, icons, cursors, and font configuration
-- Reference: https://wiki.archlinux.org/title/GTK
--

local notify = require("conf.notify")
local HOME = os.getenv("HOME")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local theme = {
    name = "Material-Black-Blueberry-LA",
    icon = { package = "win11-icon-theme-git", name = "Win11" },
    -- Cursor options: Modern; Original + Amber; Classic: Ice
    cursor = { package = "bibata-cursor-theme-bin", name = "Bibata-Modern-Ice", size = "24" },
    hyprcursor = { package = "bibata-cursor-theme-bin", name = "Bibata-Modern-Ice", size = "24" },
    font = { package = "otf-monaspace", name = "Monaspace Krypton Bold 10" },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Write content to a file, notify on failure.
--- @param path string
--- @param content string
local function write_file(path, content)
    local f = io.open(path, "w")
    if not f then
        notify.error("Failed open %s", path)
        return
    end
    f:write(content .. "\n")
    f:close()
    -- notify.info(string.format("Wrote to %s", path))
end

--- Check if a package is installed, notify on absence.
--- @param label string
--- @param package string
local function check_package(label, package)
    local handle = io.popen(string.format("yay -Qa | grep %s", package))
    if not handle then
        notify.error("Could not read output for check_package")
        return
    end

    local result = handle:read("*a")
    handle:close()
    if result == "" then
        notify.error(string.format("%s: %s not installed", label, package))
    end
end

--- Set a gsettings key under org.gnome.desktop.interface.
--- @param key string
--- @param value string
local function gsettings_set(key, value)
    hl.exec_cmd(string.format('gsettings set org.gnome.desktop.interface %s "%s"', key, value))
end


-------------------------------------------------------
-- Apply
-------------------------------------------------------

--- Apply the full theme: validate packages, set env vars, write GTK configs,
--- update gsettings, and set the Hyprland cursor.
--- @param t table Theme configuration table
local function apply_theme(t)
    -- Check packages
    check_package("ICON", theme.icon.package)
    check_package("CURSOR", theme.cursor.package)
    check_package("HYPR_CURSOR", theme.hyprcursor.package)
    check_package("FONT", theme.font.package)

    -- Environment variables
    hl.env("GDK_SCALE", "1")
    hl.env("GTK_THEME", theme.name)
    hl.env("XCURSOR_SIZE", theme.cursor.size)
    hl.env("XCURSOR_THEME", theme.cursor.name)
    hl.env("HYPRCURSOR_SIZE", theme.hyprcursor.size)
    hl.env("HYPRCURSOR_THEME", theme.hyprcursor.name)

    -- GTK 2 (~/.gtkrc-2.0)
    write_file(HOME .. "/.gtkrc-2.0", string.format(
        [[gtk-icon-theme-name = "%s"
gtk-theme-name = "%s"
gtk-font-name = "%s"
gtk-cursor-theme-name = "%s"
gtk-cursor-theme-size = "%s"]],
        theme.icon.name, theme.name, theme.font.name, theme.cursor.name, theme.cursor.size
    ))

    -- GTK 3 (~/.config/gtk-3.0/settings.ini)
    hl.exec_cmd(string.format("mkdir -p %s/.config/gtk-3.0", HOME))

    write_file(HOME .. "/.config/gtk-3.0/settings.ini", string.format(
        [[[Settings]
gtk-icon-theme-name = %s
gtk-theme-name = %s
gtk-font-name = %s
gtk-cursor-theme-name = %s
gtk-cursor-theme-size = %s
gtk-application-prefer-dark-theme = true]],
        theme.icon.name, theme.name, theme.font.name, theme.cursor.name, theme.cursor.size
    ))

    -- GTK 4 (gsettings / dconf)
    gsettings_set("gtk-theme", theme.name)
    gsettings_set("icon-theme", theme.icon.name)
    gsettings_set("cursor-theme", theme.cursor.name)
    gsettings_set("cursor-size", theme.cursor.size)
    gsettings_set("font-name", theme.font.name)
    gsettings_set("color-scheme", "prefer-dark")

    -- Hypr Cursor
    hl.exec_cmd(string.format("hyprctl setcursor %s %s", theme.hyprcursor.name, theme.hyprcursor.size))
end

apply_theme(theme)

return { apply_theme = apply_theme, theme = theme }
