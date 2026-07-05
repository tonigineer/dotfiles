--
-- conf/notify.lua
-- Notification helpers wrapping hl.notification.create()
-- Reference: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Notifications/
--

local M = {}

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local defaults = {
    duration = 5000,
    font_size = 8,
}

local levels = {
    success = { icon = "ok",      color = "rgb(07ffca)", duration = 2000              },
    warning = { icon = "warning", color = "rgb(ffcc00)", duration = defaults.duration },
    error   = { icon = "error",   color = "rgb(ff6767)", duration = 10000             },
    info    = { icon = "info",    color = "rgb(7aa2f7)", duration = 1500 },
}

-- hyprctl notify icon codes, for M.shell() (see `hyprctl notify --help`).
local hyprctl_icons = {
    success = 5, -- OK
    warning = 0, -- WARNING
    error   = 3, -- ERROR
    info    = 1, -- INFO
}

-------------------------------------------------------
-- API
-------------------------------------------------------

--- Send a notification at the given level.
--- @param level string "success"|"warning"|"error"|"info"
--- @param text string
--- @param opts? table Override duration, font_size, etc.
local function notify(level, text, opts)
    local cfg = levels[level] or levels.info
    opts = opts or {}
    hl.notification.create({
        text = " " .. text,
        timeout = opts.duration or cfg.duration,
        icon = opts.icon or cfg.icon,
        color = opts.color or cfg.color,
        font_size = opts.font_size or defaults.font_size,
    })
end

function M.success(text, opts) notify("success", text, opts) end
function M.warning(text, opts) notify("warning", text, opts) end
function M.error(text, opts)   notify("error", text, opts) end
function M.info(text, opts)    notify("info", text, opts) end

--- Single-quote a string for safe embedding in a shell command.
--- @param s string
--- @return string
local function shquote(s)
    return "'" .. s:gsub("'", [['\'']]) .. "'"
end

--- Build a shell command that fires an equivalent notification via `hyprctl notify`.
--- Use this inside hl.exec_cmd() shell chains (e.g. `cmd || notify.shell(...)`),
--- where the in-process hl.notification.create() API is not reachable.
--- @param level string "success"|"warning"|"error"|"info"
--- @param text string
--- @return string
function M.shell(level, text)
    local cfg = levels[level] or levels.info
    local icon = hyprctl_icons[level] or hyprctl_icons.info
    -- `fontsize:N` prefix matches the in-process font size; without it hyprctl
    -- notify falls back to Hyprland's (larger) default.
    local body = string.format("fontsize:%d %s", defaults.font_size, " " .. text)
    return string.format(
        "hyprctl notify %d %d %s %s",
        icon, cfg.duration, shquote(cfg.color), shquote(body)
    )
end

return M
