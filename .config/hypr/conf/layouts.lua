--
-- conf/layouts.lua
-- Tiling layouts, gaps and borders
-- Reference: https://wiki.hypr.land/Configuring/Basics/Variables/
--

hl.config({
    general = {
        -- Do not jump to another window when none is in that direction
        no_focus_fallback = true,

        -- TODO: implement logic here to change
        -- layout = "master",
        -- layout = "dwindle",
        layout = "scrolling",

        gaps_out = 0,
        gaps_in = 0,
        border_size = 0
        -- ["col.active_border"] = "rgb(" .. primary_paletteKeyColor .. ")",
        -- ["col.inactive_border"] = "rgb(" .. surfaceContainerHigh .. ")",
    },

    dwindle = {
        preserve_split = true,
        -- Window scale on special workspaces (extra gaps)
        -- special_scale_factor = 0.95,
        force_split = 2,
    },

    master = {
        new_on_top = true,
        new_status = "master",
        -- special_scale_factor = 0.5,
    },

    scrolling = {
        -- explicit_column_widths = "0.5, 1.0",
        column_width = 0.5,

        fullscreen_on_one_column = true,

        -- Fraction of a window that must be visible for focus to follow (1.0: input only)
        -- follow_min_visible = 1.0,
        -- focus_fit_method = 1,             -- 0: center | 1: fill screen
    },
})
