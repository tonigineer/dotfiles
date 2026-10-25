--
-- conf/noctalia.lua
-- Noctalia colour scheme for borders and groupbars, applied without a reload
-- Reference: https://wiki.hypr.land/Configuring/Variables/#general
--
-- colors_file is loaded with load(), not require(), and lives outside
-- ~/.config/hypr so Hyprland does not watch it: a scheme change recolours
-- in place instead of reloading the whole config.
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local colors_file = state_home .. "/noctalia/hyprland-colors.lua"

--- Elegant profile: its primary is a reddish rose, and a `surface` inactive
--- border vanishes against light glass, so both borders use secondary.
local elegant_border_role = "secondary"
local elegant_inactive_alpha = "55"

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- @return table|nil theme  `{ colors = {...}, apply_theme = fn }`
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

--- Noctalia's post_hook calls this via `hyprctl eval`.
function M.apply()
    local theme = load_theme()
    if not theme then
        return
    end
    theme.apply_theme()

    local color = theme.colors and theme.colors[elegant_border_role]
    local hex = color and color:match("%x%x%x%x%x%x")
    if hex and require("conf.vanity").get_profile() == "elegant" then
        hl.config({
            general = {
                col = {
                    active_border = "rgb(" .. hex .. ")",
                    inactive_border = "rgba(" .. hex .. elegant_inactive_alpha .. ")",
                },
            },
        })
    end
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

M.apply()

-- Registered after vanity.lua's handler, so these colours win after a reload.
hl.on("config.reloaded", M.apply)

return M
