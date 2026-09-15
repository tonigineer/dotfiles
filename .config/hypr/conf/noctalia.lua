--
-- conf/noctalia.lua
-- Noctalia colour scheme for borders and groupbars, applied without a reload
-- Reference: https://wiki.hypr.land/Configuring/Variables/#general
--
-- Noctalia renders .config/noctalia/templates/hyprland.lua (registered as
-- [theme.templates.user.hyprland] in the settings.<host>.toml files) into
-- `colors_file` whenever the colour scheme changes, then runs
--
--   hyprctl eval 'require("conf.noctalia").apply()'
--
-- as its post_hook. The file is read with io.open + load() rather than
-- require(), and lives outside ~/.config/hypr, so Hyprland never adds it to its
-- config watch. A new wallpaper therefore recolours the borders in place
-- instead of reloading the whole config (monitors, keybinds, rules, load-time
-- notifications), which is what the built-in Noctalia template caused.
--
-- Not to be confused with conf/colors.lua, the static palette table other
-- modules (vanity.lua) read hex values from.
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local colors_file = state_home .. "/noctalia/hyprland-colors.lua"

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Load the rendered theme table from disk.
--- @return table|nil theme  `{ colors = {...}, apply_theme = fn }`, or nil when
---                          the file is missing (not rendered yet) or broken
local function load_theme()
    local handle = io.open(colors_file, "r")
    if not handle then
        return nil
    end
    local source = handle:read("*a")
    handle:close()

    local chunk, err = load(source, "=" .. colors_file, "t")
    if not chunk then
        notify.error("Noctalia colours: " .. tostring(err))
        return nil
    end

    local ok, theme = pcall(chunk)
    if not ok or type(theme) ~= "table" or type(theme.apply_theme) ~= "function" then
        notify.error("Noctalia colours: " .. tostring(ok and "no apply_theme()" or theme))
        return nil
    end
    return theme
end

-------------------------------------------------------
-- Exports
-------------------------------------------------------

local M = {}

--- Apply the current Noctalia colours. Safe to call at any time, including
--- from `hyprctl eval` while Hyprland is running.
function M.apply()
    local theme = load_theme()
    if theme then
        theme.apply_theme()
    end
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

M.apply()

-- vanity.lua sets its own border colours from its config.reloaded handler;
-- this one is registered later, so Noctalia's colours win after a reload.
hl.on("config.reloaded", M.apply)

return M
