--
-- https://wiki.hypr.land/Configuring/Basics/Variables/
--

hl.config({
    general = {
        -- if true, will not fall back to the next available window
        -- when moving focus in a direction where no window was found
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

        -- specifies the scale factor of windows on the special workspace
        -- AKA extra gaps for special workspaces
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

        -- when a window is focused, require that at least
        -- a given fraction of it is visible for focus to follow. [0.0 - 1.0]
        -- 1.0 -> follow only on hard input
        -- follow_min_visible = 1.0,
        -- 0: focus new window in center
        -- 1: fill screen
        -- focus_fit_method = 1,
    },
})
