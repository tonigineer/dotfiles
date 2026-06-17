--
-- conf/themes.lua
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
    check_package("ICON", t.icon.package)
    check_package("CURSOR", t.cursor.package)
    check_package("HYPR_CURSOR", t.hyprcursor.package)
    check_package("FONT", t.font.package)

    -- Environment variables
    hl.env("GDK_SCALE", "1")
    hl.env("GTK_THEME", t.name)
    hl.env("XCURSOR_SIZE", t.cursor.size)
    hl.env("XCURSOR_THEME", t.cursor.name)
    hl.env("HYPRCURSOR_SIZE", t.hyprcursor.size)
    hl.env("HYPRCURSOR_THEME", t.hyprcursor.name)

    -- GTK 2 (~/.gtkrc-2.0)
    write_file(HOME .. "/.gtkrc-2.0", string.format(
        [[gtk-icon-theme-name = "%s"
gtk-theme-name = "%s"
gtk-font-name = "%s"
gtk-cursor-theme-name = "%s"
gtk-cursor-theme-size = "%s"]],
        t.icon.name, t.name, t.font.name, t.cursor.name, t.cursor.size
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
        t.icon.name, t.name, t.font.name, t.cursor.name, t.cursor.size
    ))

    -- GTK 4 (gsettings / dconf)
    gsettings_set("gtk-theme", t.name)
    gsettings_set("icon-theme", t.icon.name)
    gsettings_set("cursor-theme", t.cursor.name)
    gsettings_set("cursor-size", t.cursor.size)
    gsettings_set("font-name", t.font.name)
    gsettings_set("color-scheme", "prefer-dark")

    -- Hypr Cursor
    hl.exec_cmd(string.format("hyprctl setcursor %s %s", t.hyprcursor.name, t.hyprcursor.size))

    -- Propagate the cursor into the session activation environment so XWayland
    -- apps (Steam, etc.) launched via the systemd/DBus path inherit the current
    -- cursor on restart. hl.env only affects Hyprland's own startup env, which a
    -- GUI-launcher-spawned process won't pick up mid-session.
    hl.exec_cmd(string.format(
        "dbus-update-activation-environment --systemd "
        .. "XCURSOR_THEME=%s XCURSOR_SIZE=%s HYPRCURSOR_THEME=%s HYPRCURSOR_SIZE=%s",
        t.cursor.name, t.cursor.size, t.hyprcursor.name, t.hyprcursor.size
    ))
end

apply_theme(theme)

-------------------------------------------------------
-- Cursor toggle
-------------------------------------------------------

-- Alternate cursor preset (F4 toggle). Nordzy ships a matching XCursor and
-- hyprcursor under one name (`Nordzy-cursors`): the hyprcursor renders a sharp
-- vector cursor on Wayland, while the XCursor works in XWayland games (Steam).
-- A single setcursor name resolves both backends, so no alias is needed.
local alt_cursor = {
    cursor     = { package = "nordzy-cursors",     name = "Nordzy-cursors", size = "24" },
    hyprcursor = { package = "nordzy-hyprcursors", name = "Nordzy-cursors", size = "24" },
}

local cursor_alt = false

--- Shallow copy of a table (one level deep).
--- @param tbl table
--- @return table
local function copy(tbl)
    local out = {}
    for k, v in pairs(tbl) do out[k] = v end
    return out
end

--- Toggle the cursor between the default theme and `alt_cursor`,
--- re-applying the theme without mutating the default.
local function toggle_cursor()
    cursor_alt = not cursor_alt

    local t = copy(theme)
    if cursor_alt then
        t.cursor = alt_cursor.cursor
        t.hyprcursor = alt_cursor.hyprcursor
    end

    apply_theme(t)
    notify.info("Cursor: " .. t.hyprcursor.name)
end

return { apply_theme = apply_theme, theme = theme, toggle_cursor = toggle_cursor }
