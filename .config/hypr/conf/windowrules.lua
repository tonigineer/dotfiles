--
-- conf/windowrules.lua
-- Event handlers and window rules
-- Reference: https://wiki.hypr.land/Configuring/Window-Rules/
--

local border_colors = require("conf.vanity").border_colors
local notify = require("conf.notify")

-------------------------------------------------------
-- Event Handlers
-------------------------------------------------------

hl.on("window.open", function(win)
    if not win.xwayland then return end
    notify.warning("XWayland: " .. (win.class ~= "" and win.class or win.title), { duration = 5000 })
end)

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

-- Covers ruled-window focus changes hide_special_on_workspace_change misses.
hl.on("workspace.active", function()
    if hl.get_active_special_workspace() then
        hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
    end
end)

-------------------------------------------------------
-- Window Rules
-------------------------------------------------------

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

hl.window_rule({
    name = "Portal file pickers",
    match = { class = "xdg-desktop-portal-gtk|xdg-desktop-portal-kde" },
    float = true,
    center = true,
})

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
    -- Factorio's bundled SDL3 sets this app ID
    { class = "^(?i)(com\\.factorio\\.)?factorio$", workspace = "4" },
    { class = "^(?i)teamspeak-client$", workspace = "special:communication" },
    { class = "^(?i)Discord|Vesktop$", workspace = "special:communication", silent = true },
    { class = "^(?i)spotify$", workspace = "special:communication", silent = true },
}

for _, rule in ipairs(workspace_rules) do
    hl.window_rule({
        match = { class = rule.class },
        -- Suppress activation, or focus_on_activate pulls the special workspace
        -- into view whenever e.g. Spotify relaunches.
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

hl.window_rule({
    name = "Steam Friends",
    match = { title = "^(?i)Friends List$" },
    workspace = "4",
    tile = true,
    border_size = 0,
    rounding = 5,
})

-- No layout supports a static split ratio, so size the Friends column on open.
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

-- Battle.net UI is drawn at 2x (bottle DPI 192) and gets cut off in a half tile.
hl.window_rule({
    name = "Battle.net",
    match = { class = "^(?i)battle\\.net\\.exe$" },
    workspace = "4",
})

hl.window_rule({
    name = "Battle.net Main Window",
    match = { class = "^(?i)battle\\.net\\.exe$", title = "^Battle\\.net$" },
    maximize = true,
})

-------------------------------------------------------
-- Application Overrides
-------------------------------------------------------

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

-- stay_focused stops follow_mouse from handing focus back to the file view.
local thunar_rename = { class = "^(?i)thunar$", title = '^Rename ".*"$' }

hl.window_rule({
    name = "Thunar Rename",
    match = thunar_rename,
    float = true,
    center = true,
    stay_focused = true,
    border_color = border_colors.floating,
    border_size = 2,
})

hl.on("window.open", function(win)
    if not (win.class:match("^[Tt]hunar$") and win.title:match('^Rename ".*"$')) then return end
    hl.dispatch(hl.dsp.focus({ window = "address:" .. win.address }))
    hl.dispatch(hl.dsp.cursor.move({
        x = math.floor(win.at.x + win.size.x / 2),
        y = math.floor(win.at.y + win.size.y / 2),
    }))
end)

hl.window_rule({
    name = "XArchiver",
    match = { class = "^xarchiver$" },
    float = true,
    center = true,
    border_color = "#0000FF #00FF00",
    border_size = 2,
    size = "monitor_w*0.40 monitor_h*0.40",
})

-- Zen: rounding above 5 cuts off tooltip corners.
require("conf.vanity").on_gamemode_change(function(is_on)
    local rounding = is_on and 0
        or math.min(hl.get_config("decoration.rounding"), 5)

    hl.window_rule({
        name = "ZenBrowserRounding",
        match = { class = "zen" },
        rounding = rounding,
    })
end)

-- Electron/Chromium cannot draw a translucent background, so the elegant
-- profile fades the whole window instead, content included.
local glass_rules = {}
for _, app in ipairs({
    { name = "Code - OSS glass", class = "^code-oss$", opacity = 0.85 },
    { name = "Brave glass", class = "^brave-browser$", opacity = 0.92 },
}) do
    table.insert(glass_rules, hl.window_rule({
        name = app.name,
        match = { class = app.class },
        opacity = app.opacity,
    }))
end

require("conf.vanity").on_gamemode_change(function(is_on)
    local enabled = not is_on and require("conf.vanity").get_profile() == "elegant"
    for _, rule in ipairs(glass_rules) do
        rule:set_enabled(enabled)
    end
end)

-------------------------------------------------------
-- Tag definition
-------------------------------------------------------

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
-- Layer Rules
-------------------------------------------------------

-- The global `layers` animation fights skwd's own transitions.
hl.layer_rule({
    name = "skwd-wall",
    match = { namespace = "^skwd-(wall|paper|wall-vk)$" },
    no_anim = true,
})

-- Only visible in the elegant profile (the one with decoration.blur on).
hl.layer_rule({
    name = "noctalia-blur",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.5,
})
