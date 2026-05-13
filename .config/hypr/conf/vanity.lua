--
-- conf/animations.lua
-- Bezier curves, animation rules, and general appearance
-- Reference: https://wiki.hypr.land/Configuring/Animations/
-- Curves:  https://www.cssportal.com/css-cubic-bezier-generator/
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Constants
-------------------------------------------------------

local BORDER_OPACITY = "55"

-------------------------------------------------------
-- Border Colors
-------------------------------------------------------

--- Build a gradient border: three sides in `hex`, bottom in `bottom_hex`.
--- @param hex string
--- @param bottom_hex? string
--- @return table
local function border_gradient(hex, bottom_hex)
    bottom_hex = bottom_hex or "131313"
    local c = "rgba(" .. hex .. BORDER_OPACITY .. ")"
    local b = "rgba(" .. bottom_hex .. BORDER_OPACITY .. ")"
    return { colors = { c, c, c, b }, angle = 0 }
end

-- TODO: read colors from nocatlia
local border_colors = {
    active   = border_gradient("343434"),
    inactive = border_gradient("131313"),
    floating = border_gradient("ffcc00"),
    pinned   = border_gradient("cc6666"),
}

-------------------------------------------------------
-- Curves
-------------------------------------------------------

-- stylua: ignore start
local curves = {
    { "easeOutExpo", { type = "bezier", points = { { 0.19, 1.00 }, { 0.22, 1.00 } } } },
    { "easeInQuart", { type = "bezier", points = { { 0.89, 0.03 }, { 0.68, 0.22 } } } },
    { "easeInOut",   { type = "bezier", points = { { 0.65, 0.00 }, { 0.35, 1.00 } } } },
    { "bounceOut",   { type = "bezier", points = { { 0.57, 1.40 }, { 0.24, 0.95 } } } },
    { "scurve",      { type = "bezier", points = { { 0.98, 0.01 }, { 0.02, 0.98 } } } },
    { "overshot",    { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.10 } } } },
}
-- stylua: ignore end

-------------------------------------------------------
-- Animations
-------------------------------------------------------

local animations = {
    -- Windows                                                                [styles: slide, slidevert, fade, popin]
    { leaf = "windows",     enabled = true, speed = 2.0,  bezier = "overshot"                         },
    { leaf = "windowsIn",   enabled = true, speed = 7.0,  bezier = "easeOutExpo", style = "slide"     },
    { leaf = "windowsOut",  enabled = true, speed = 7.0,  bezier = "easeOutExpo", style = "slide"     },
    -- Borders
    { leaf = "border",      enabled = true, speed = 2.0,  bezier = "easeInQuart"                      },
    { leaf = "borderangle", enabled = true, speed = 25.0, bezier = "easeInQuart", style = "loop"      },
    -- Fades
    { leaf = "fadeIn",      enabled = true, speed = 10.0, bezier = "default"                          },
    { leaf = "fadeOut",     enabled = true, speed = 10.0, bezier = "default"                          },
    { leaf = "fadeSwitch",  enabled = true, speed = 15.0, bezier = "default"                          },
    { leaf = "fadeDim",     enabled = true, speed = 25.0, bezier = "default"                          },
    -- Workspaces & layers
    { leaf = "workspaces",  enabled = true, speed = 4.0,  bezier = "easeInQuart", style = "slidevert" },
    { leaf = "layers",      enabled = true, speed = 5.0,  bezier = "scurve",      style = "slide"     },
}

-------------------------------------------------------
-- Appearance + Gamemode
-------------------------------------------------------

local gamemode = true

--- Toggle gamemode: disables animations, blur, shadow, and border for maximum performance.
local function toggle_gamemode()
    gamemode = not gamemode

    if gamemode then
        hl.config({
            animations = { enabled = false },
            decoration = {
                rounding = 0,
                shadow = { enabled = false },
                blur = { enabled = false },
            },
            general = {
                border_size = 0,
                gaps_in = 0,
                gaps_out = 0,
            },
            misc = {
                animate_mouse_windowdragging = false,
                animate_manual_resizes = false,
            },
        })
        notify.success("Gamemode enabled")
    else
        hl.config({
            general = {
                gaps_out = 10,
                gaps_in = 4,
                border_size = 1,
                col = {
                    active_border   = border_colors.active,
                    inactive_border = border_colors.inactive,
                },
            },
            decoration = {
                rounding = 10,
                active_opacity = 1.0,
                inactive_opacity = 1.0,
                shadow = {
                    enabled = true,
                    range = 4,
                    render_power = 3,
                    color = 0xee1a1a1a,
                },
                blur = {
                    enabled = false,
                    size = 3,
                    passes = 1,
                    vibrancy = 0.1696,
                },
            },
        })
        notify.info("Gamemode disabled")
    end
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

hl.on("config.reloaded", function ()
    toggle_gamemode()
end)

for _, curve in ipairs(curves) do
    hl.curve(curve[1], curve[2])
end

for _, anim in ipairs(animations) do
    hl.animation(anim)
end

-------------------------------------------------------
-- Exports
-------------------------------------------------------

return {
    border_colors = border_colors,
    toggle_gamemode = toggle_gamemode
}
