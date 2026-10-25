--
-- conf/inputs.lua
-- Keyboard layout, repeat rate, and pointer behavior
-- Reference: https://wiki.hypr.land/Configuring/Variables/#input
--

-------------------------------------------------------
-- XKB environment
-------------------------------------------------------

local xkb = {
    { "XKB_DEFAULT_LAYOUT",    "us"                              },
    { "XKB_DEFAULT_VARIANT",   "altgr-intl"                      },
    { "XKB_DEFAULT_OPTIONS",   "compose:menu,level3:ralt_switch" },
}

for _, var in ipairs(xkb) do
    hl.env(var[1], var[2])
end

-------------------------------------------------------
-- Input configuration
-------------------------------------------------------

hl.config({
    input = {
        kb_layout   = "us",
        kb_options  = "compose:ralt, ctrl:nocaps",
        repeat_delay = 200,
        repeat_rate  = 75,

        -- Pointer
        follow_mouse = 1,
        scroll_factor = 2.5,
        sensitivity   = -0.60,
        accel_profile = "adaptive",

        -- 0: off | 1: tiled <-> floating | 2: also floating <-> floating
        float_switch_override_focus = 0,

        -- 0: next candidate | 1: under cursor | 2: most recently used
        focus_on_close = 1,

        touchpad = {
            disable_while_typing    = true,
            natural_scroll          = true,
            middle_button_emulation = false,
            scroll_factor           = 0.5,
        },
    },
})
