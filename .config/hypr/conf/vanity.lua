--
-- conf/animations.lua
-- Bezier curves, animation rules, and general appearance
-- Reference: https://wiki.hypr.land/Configuring/Animations/
-- Curves:  https://www.cssportal.com/css-cubic-bezier-generator/
--

local notify = require("conf.notify")
local colors = require("conf.colors")

-------------------------------------------------------
-- Constants
-------------------------------------------------------

local BORDER_OPACITY = "88"

-------------------------------------------------------
-- Listeners
-------------------------------------------------------

local listeners = {}

local function on_gamemode_change(fn)
    table.insert(listeners, fn)
end

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
    -- local b = "rgba(" .. bottom_hex .. BORDER_OPACITY .. ")"
    return { colors = { c, c, c, c }, angle = 0 }
end

local border_colors = {
    active   = border_gradient(colors.primary),
    inactive = border_gradient(colors.surface),
    floating = border_gradient(colors.secondary),
    pinned   = border_gradient(colors.error),
    -- Subtle XWayland marker: a dark scheme color, shown in both focus
    -- states (string "active inactive" — window rules take one color each).
    xwayland = "rgba(" .. colors.surface .. "ff) rgba(" .. colors.surface .. "ff)",
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

local gamemode = false

--- Apply the appearance for the current gamemode state (no toggle, no notify).
local function apply_gamemode()
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
    else
        hl.config({
            general = {
                gaps_out = 10,
                gaps_in = 4,
                border_size = 2,
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
                    range = 2,
                    render_power = 1,
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
    end

    -- Inform subscribers (e.g. windowrules Zen rounding) of the current state.
    -- Runs after hl.config so listeners reading decoration.rounding see the new
    -- value, and on every reload so their rules survive a config reload.
    for _, fn in ipairs(listeners) do
        fn(gamemode)
    end
end

--- Toggle gamemode: flip the state, apply it, and notify.
local function toggle_gamemode()
    gamemode = not gamemode
    apply_gamemode()
    if gamemode then
        notify.success("Gamemode enabled")
    else
        notify.info("Gamemode disabled")
    end
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

-- Apply the current gamemode appearance whenever the config (re)loads. The base
-- config never sets gaps/rounding/borders — this handler is the only place they
-- are applied — so it must run on every load. Silent and non-toggling: the
-- previous version called toggle_gamemode() here, which flipped the state and
-- fired a "Gamemode enabled/disabled" notification on every reload (and twice per
-- save, since editors emit two inotify events that each trigger an autoreload).
hl.on("config.reloaded", function()
    apply_gamemode()
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
    toggle_gamemode = toggle_gamemode,
    is_gamemode = function() return gamemode end,
    on_gamemode_change = on_gamemode_change,
}
