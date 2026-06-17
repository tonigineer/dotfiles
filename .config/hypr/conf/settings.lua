--
-- conf/settings.lua
-- General Hyprland settings and behavior
-- Reference: https://wiki.hypr.land/Configuring/Variables/
--

-------------------------------------------------------
-- Settings
-------------------------------------------------------

hl.config({
    general = {
        resize_on_border = false,
        allow_tearing = false,                  -- https://wiki.hyprland.org/Configuring/Tearing/
        snap = {
            enabled = true,
            window_gap = 0,
        },
    },
    cursor = {
        hide_on_key_press = false,
        no_hardware_cursors = true,
        inactive_timeout = 10,
        enable_hyprcursor = true,
    },
    ecosystem = {
        no_update_news = false,
        no_donation_nag = true,                 -- already doing my part
    },
	debug = {
		-- enable_stdout_logs = true,
		disable_logs = false,                   -- $ hyprctl rollinglog -f | grep Lua
	},
    render = {
        cm_enabled = true,                      -- color management pipeline (requires restart)
        send_content_type = false,              -- monitor profile autoswitch (may flash black)
    },
    misc = {
        disable_autoreload = false,
        disable_xdg_env_checks = true,
        disable_watchdog_warning = true,
        disable_splash_rendering = true,
        disable_hyprland_guiutils_check = true,
        disable_hyprland_logo = true,
        animate_mouse_windowdragging = true,
        animate_manual_resizes = true,
        middle_click_paste = false,
        force_default_wallpaper = 0,
        focus_on_activate = true,
        enable_anr_dialog = false,              -- 0: ignore (keep fullscreen) | 1: takes over | 2: unfullscreen
        on_focus_under_fullscreen = 1,          -- 0: off | 1: on | 2: fullscreen only | 3: fullscreen + video/game content
        vrr = 3,
        background_color = "rgb(cc6666)",
        allow_session_lock_restore = true,
    },
    xwayland = {
        enabled = true,
        force_zero_scaling = true,
        use_nearest_neighbor = false,
    },
})
