--
-- conf/rules.lua
-- Event handlers and window rules
-- Reference: https://wiki.hypr.land/Configuring/Window-Rules/
--

local border_colors = require("conf.vanity").border_colors

-------------------------------------------------------
-- Event Handlers
-------------------------------------------------------

-- Constrain pinned floating windows to 25% of monitor dimensions
hl.on("window.pin", function(win)
    if not win.floating then return end

    local mon = win.monitor
    if not mon then return end

    local mw = mon.size and mon.size.x or 1920
    local mh = mon.size and mon.size.y or 1080
    local limit_w = math.floor(mw * 0.25)
    local limit_h = math.floor(mh * 0.25)

    local ww = win.size and win.size.x or 0
    local wh = win.size and win.size.y or 0

    if ww > limit_w or wh > limit_h then
        hl.dispatch(hl.dsp.window.resize({
            window = "address:" .. win.address,
            x = math.min(ww, limit_w),
            y = math.min(wh, limit_h),
            exact = true,
        }))
        hl.dispatch(hl.dsp.window.center({
            window = "address:" .. win.address,
        }))
    end
end)

-- Close special workspace on workspace switch.
-- Covers ruled-window focus changes that
-- hide_special_on_workspace_change:true misses.
hl.on("workspace.active", function()
    if hl.get_active_special_workspace() then
        hl.dsp.workspace.toggle_special("scratchpad")
    end
end)

-------------------------------------------------------
-- Window Rules
-------------------------------------------------------

-- Appearance: pinned vs floating
hl.window_rule({
    name = "Pinned windows",
    match = { pin = true },
    border_size = 2,
    border_color = border_colors.pinned,
    opacity = 1.0,
})

hl.window_rule({
    name = "Floating windows",
    match = { float = true, pin = false },
    border_size = 2,
    border_color = border_colors.floating,
    opacity = 1.0,
})

-- Portal file pickers
hl.window_rule({
    name = "Portal file pickers",
    match = { class = "xdg-desktop-portal-gtk|xdg-desktop-portal-kde" },
    float = true,
    center = true,
})

-- Generic dialog-like titles
hl.window_rule({
    name = "Dialog titles",
    match = { title = "^(Open|Save|Save As|Choose|Select|Export|Import)(.*)$" },
    float = true,
    center = true,
    size = "monitor_w*0.40 monitor_h*0.40",
})

-------------------------------------------------------
-- Workspace Assignments
-------------------------------------------------------

local workspace_rules = {
    { class = "^(?i)dev.zed.Zed$", workspace = "2" },
    { class = "^(?i)steam$", workspace = "4" },
    { class = "^(?i)steam_app_\\d+$", workspace = "4" },
    { class = "^(?i)dota2$", workspace = "4" },
    { class = "^(?i)factorio$", workspace = "4" },
    { class = "^(?i)teamspeak-client$", workspace = "special:communication" },
    { class = "^(?i)Discord|Vesktop$", workspace = "special:communication", silent = true },
    { class = "^(?i)spotify$", workspace = "special:communication", silent = true },
}

for _, rule in ipairs(workspace_rules) do
    hl.window_rule({
        match = { class = rule.class },
        -- `silent`: assign to the (special) workspace without switching to it, and
        -- drop the app's self-activation requests. Otherwise focus_on_activate
        -- (misc, settings.lua) lets a relaunch — e.g. Spotify restarting on a
        -- wallpaper change — yank the special workspace into view every time.
        workspace = rule.silent and (rule.workspace .. " silent") or rule.workspace,
        suppress_event = rule.silent and "activate activatefocus" or nil,
    })
end

-------------------------------------------------------
-- Gaming
-------------------------------------------------------

hl.window_rule({
    name = "Bottles",
    match = { title = "^(?i)Bottles$" },
    workspace = "4",
    float = true,
})

hl.window_rule({
    name = "Steam Library",
    match = { class = "^(?i)steam$", title = "^Steam$" },
    workspace = "4",
    tile = true,
    border_size = 0,
    rounding = 5,
})

-- Friends list: tiled; width pinned to 1/4 by the handler below
hl.window_rule({
    name = "Steam Friends",
    match = { title = "^(?i)Friends List$" },
    workspace = "4",
    tile = true,
    border_size = 0,
    rounding = 5,
})

-- No layout here supports a static tiled split ratio, so pin the Friends
-- column to 20% of the monitor width on open (the library reflows to fill the rest).
hl.on("window.open", function(win)
    if win.title ~= "Friends List" then return end

    local mon = win.monitor
    local mw = mon and mon.size and mon.size.x or 1920
    local mh = mon and mon.size and mon.size.y or 1080

    hl.dispatch(hl.dsp.window.resize({
        window = "address:" .. win.address,
        x = math.floor(mw * 0.20),
        y = mh,
        exact = true,
    }))
end)

-- Any other Steam window (settings, dialogs, …): float + center
hl.window_rule({
    name = "Steam Other Windows",
    match = { class = "^(?i)steam$", title = "negative:^(?i)(Steam|Friends List)$" },
    workspace = "4",
    float = true,
    border_size = 0,
    center = true,
    rounding = 5,
})

hl.window_rule({
    name = "Ubisoft Connect",
    match = { class = "^(?i)Ubisoft Connect$" },
    float = true,
})

-------------------------------------------------------
-- Application Overrides
-------------------------------------------------------

-- Thunar: float by default, tile when it's the main window
hl.window_rule({
    name = "Thunar Other Windows",
    match = { class = ".*thunar.*", title = "negative:.* - Thunar.*" },
    float = true,
    border_color = border_colors.floating,
    border_size = 2,
})

hl.window_rule({
    name = "Thunar Main Window",
    match = { title = ".* - Thunar.*" },
    tile = true,
})

-- XArchiver
hl.window_rule({
    name = "XArchiver",
    match = { class = "^xarchiver$" },
    float = true,
    center = true,
    border_color = "#0000FF #00FF00",
    border_size = 2,
    size = "monitor_w*0.40 monitor_h*0.40",
})

-- Zen Browser
-- Limit the rounding to 5 to avoid cut off tooltip corners
require("conf.vanity").on_gamemode_change(function(is_on)
    local rounding = is_on and 0
        or math.min(hl.get_config("decoration.rounding"), 5)

    hl.window_rule({
        name = "ZenBrowserRounding",
        match = { class = "zen" },
        rounding = rounding,
    })
end)

-------------------------------------------------------
-- Tag definition
-------------------------------------------------------

-- Pinned
hl.window_rule({
    match = {
        initial_title = "pinned",
    },
    tag = "+pinned",
})

hl.window_rule({
    match = {
        tag = "pinned",
    },
    float = true,
    pin = true,
    size = { "monitor_w * 0.25", "monitor_h * 0.25" },
    keep_aspect_ratio = true,
    border_size = 2,
    move = { "monitor_w - (monitor_w * 0.3) + 80", "45" },
})

-------------------------------------------------------
-- XWayland marker (last, so it wins over floating/pinned)
-------------------------------------------------------

-- Distinct border so XWayland windows are easy to spot
hl.window_rule({
    name = "XWayland windows",
    match = { xwayland = true },
    border_size = 2,
    border_color = border_colors.xwayland,
})
