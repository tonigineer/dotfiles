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
    cursor = { package = "bibata-cursor-git", name = "Bibata-Modern-Ice", size = "24" },
    hyprcursor = { package = "bibata-cursor-git", name = "Bibata-Modern-Ice", size = "24" },
    font = { package = "otf-monaspace", name = "Monaspace Krypton Bold 10" },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

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

--- @param label string
--- @param package string
local function check_package(label, package)
    if not package then return end -- unpackaged theme
    local handle = io.popen(string.format("paru -Qa | grep %s", package))
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

--- @param key string
--- @param value string
local function gsettings_set(key, value)
    hl.exec_cmd(string.format('gsettings set org.gnome.desktop.interface %s "%s"', key, value))
end


-------------------------------------------------------
-- Apply
-------------------------------------------------------

--- @param t table
local function apply_theme(t)
    check_package("ICON", t.icon.package)
    check_package("CURSOR", t.cursor.package)
    check_package("HYPR_CURSOR", t.hyprcursor.package)
    check_package("FONT", t.font.package)

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

    hl.exec_cmd(string.format("hyprctl setcursor %s %s", t.hyprcursor.name, t.hyprcursor.size))

    -- hl.env only reaches Hyprland's own env; XWayland apps launched via
    -- systemd/D-Bus need this to pick up a cursor change mid-session.
    hl.exec_cmd(string.format(
        "dbus-update-activation-environment --systemd "
        .. "XCURSOR_THEME=%s XCURSOR_SIZE=%s HYPRCURSOR_THEME=%s HYPRCURSOR_SIZE=%s",
        t.cursor.name, t.cursor.size, t.hyprcursor.name, t.hyprcursor.size
    ))
end

apply_theme(theme)

-------------------------------------------------------
-- Cursor cycle
-------------------------------------------------------

-- Index 1 mirrors `theme.cursor`. xpkg = nil means no XCursor backend, so
-- XWayland apps fall back to the default cursor.
-- -- stylua: ignore start
local cursor_cycle = {
    { label = "Bibata",    cursor = "Bibata-Modern-Ice",        hyprcursor = "Bibata-Modern-Ice",        size = "24", xpkg = "bibata-cursor-git", hpkg = "bibata-cursor-git" },
    { label = "Rosé Pine", cursor = "rose-pine-hyprcursor",     hyprcursor = "rose-pine-hyprcursor",     size = "32", xpkg = nil,                 hpkg = "rose-pine-hyprcursor" },
    { label = "Sweet",     cursor = "Sweet-cursors-hyprcursor", hyprcursor = "Sweet-cursors-hyprcursor", size = "32", xpkg = nil,                 hpkg = "sweet-cursors-hyprcursor-git" },
    -- { label = "Apple",     cursor = "macOS-hypr",               hyprcursor = "macOS-hypr",               size = "32", xpkg = nil,                 hpkg = "apple_hyprcursor" },
    -- { label = "Nordzy",    cursor = "Nordzy-cursors",           hyprcursor = "Nordzy-hyprcursors",       size = "32", xpkg = "nordzy-cursors",    hpkg = "nordzy-hyprcursors" },
}
-- stylua: ignore end

local cursor_index = 1

--- @param tbl table
--- @return table
local function copy(tbl)
    local out = {}
    for k, v in pairs(tbl) do out[k] = v end
    return out
end

local function toggle_cursor()
    cursor_index = cursor_index % #cursor_cycle + 1
    local preset = cursor_cycle[cursor_index]

    local t = copy(theme)
    t.cursor = { package = preset.xpkg, name = preset.cursor, size = preset.size }
    t.hyprcursor = { package = preset.hpkg, name = preset.hyprcursor, size = preset.size }

    apply_theme(t)
    notify.success(string.format("Cursor: %s @%s", preset.label, preset.size))
end

return { apply_theme = apply_theme, theme = theme, toggle_cursor = toggle_cursor }
