--
-- conf/vanity.lua
-- Animations, appearance profiles and gamemode
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
-- Appearance
-------------------------------------------------------

-- Profiles must set the same keys, so switching leaves nothing behind.
local profiles = {
    normal = {
        animations = { enabled = true },
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
                popups = false,
            },
        },
        misc = {
            animate_mouse_windowdragging = true,
            animate_manual_resizes = true,
        },
    },

    elegant = {
        animations = { enabled = true },
        general = {
            gaps_out = 16,
            gaps_in = 6,
            border_size = 2,
            col = {
                active_border   = border_colors.active,
                inactive_border = border_colors.inactive,
            },
        },
        decoration = {
            rounding = 14,
            active_opacity = 1.0,
            inactive_opacity = 1.0,
            shadow = {
                enabled = true,
                range = 30,
                render_power = 3,
                color = 0x40000000,
            },
            blur = {
                enabled = true,
                -- Large and soft: behind light glass the wallpaper reads as colour, not detail
                size = 12,
                passes = 4,
                vibrancy = 0.1696,
                brightness = 1.0,
                contrast = 0.7,
                popups = true,
            },
        },
        misc = {
            animate_mouse_windowdragging = true,
            animate_manual_resizes = true,
        },
    },
}

-- Overrides the active profile; resets opacities a profile may have lowered.
local game = {
    animations = { enabled = false },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
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
}

-------------------------------------------------------
-- State
-------------------------------------------------------

local HOME = os.getenv("HOME") or ""

-- Persists the profile across reloads and reboots; gamemode deliberately not.
local PROFILE_FILE = HOME .. "/.local/state/desktop-profile/name"
local PROFILE_CMD = HOME .. "/.local/bin/desktop-profile"

--- @return string
local function read_profile()
    local f = io.open(PROFILE_FILE, "r")
    if not f then return "normal" end
    local name = (f:read("*l") or ""):gsub("%s", "")
    f:close()
    return profiles[name] and name or "normal"
end

local profile = read_profile()
local gamemode = false

local function apply_appearance()
    hl.config(gamemode and game or profiles[profile])

    -- Re-apply live Noctalia border colours over the static ones above.
    require("conf.noctalia").apply()

    -- After hl.config, so listeners read the new decoration values.
    for _, fn in ipairs(listeners) do
        fn(gamemode)
    end
end

-------------------------------------------------------
-- Session side effects
-------------------------------------------------------

--- Not called from apply_appearance(): reloads would clobber a manual DND or
--- caffeine state.
--- @param is_on boolean
local function apply_session(is_on)
    hl.exec_cmd(string.format(
        "noctalia msg notification-dnd-set %s; noctalia msg caffeine-%s",
        is_on and "on" or "off",
        is_on and "enable" or "disable"
    ))
end

-------------------------------------------------------
-- Toggle
-------------------------------------------------------

local function toggle_gamemode()
    gamemode = not gamemode
    apply_appearance()
    apply_session(gamemode)
    if gamemode then
        notify.success("Gamemode enabled")
    else
        notify.info("Gamemode disabled")
    end
end

--- Used via `hyprctl eval` after resume from hibernation.
local function disable_gamemode()
    if gamemode then
        toggle_gamemode()
    end
end

--- @param name string  key of `profiles`
local function set_profile(name)
    if not profiles[name] then
        notify.error("Unknown profile: " .. tostring(name))
        return
    end
    profile = name
    apply_appearance()
    hl.exec_cmd(string.format('[ -x "%s" ] && "%s" %s', PROFILE_CMD, PROFILE_CMD, name))
    notify.info((name:gsub("^%l", string.upper)) .. " profile"
        .. (gamemode and " (after gamemode)" or ""))
end

local function toggle_profile()
    set_profile(profile == "elegant" and "normal" or "elegant")
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

-- The only place gaps/rounding/borders are set, so it must run on every load.
hl.on("config.reloaded", function()
    apply_appearance()
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
    disable_gamemode = disable_gamemode,
    is_gamemode = function() return gamemode end,
    on_gamemode_change = on_gamemode_change,
    set_profile = set_profile,
    toggle_profile = toggle_profile,
    get_profile = function() return profile end,
}
