--
-- conf/workspaces.lua
-- Workspace rules, monitor assignments, and naming
-- Reference: https://wiki.hypr.land/Configuring/Workspace-Rules/
--

local notify = require("conf.notify")
local mon = require("conf.monitors")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local ws_labels = {
    numeric = { "1", "2", "3", "4", "5" },
    chinese = { "一", "二", "三", "四", "五" },
}

local primary = mon.primary
local secondary = mon.secondary

-- stylua: ignore start
local ws_rules = {
    { workspace = "1", monitor = primary, default = true, persistent = true, layout = "master"    },
    { workspace = "2", monitor = primary,                 persistent = true, layout = "scrolling" },
    { workspace = "3", monitor = primary,                 persistent = true, layout = "scrolling" },
    { workspace = "4", monitor = primary,                 persistent = true, layout = "master"    },
    { workspace = "5", monitor = secondary or primary,    persistent = true, layout = "master"    },
    { workspace = "special:scratchpad" },
    { workspace = "special:media" }}
-- stylua: ignore end

--- Gaps applied to single-window workspaces 2-5
local single_window_gaps = { top = 150, bottom = 150, left = 150, right = 150 }

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

local use_chinese = true

--- Apply workspace names from a given label set.
--- @param labels string[]
local function apply_names(labels)
    for i, name in ipairs(labels) do
        -- TODO: Function does not work
        hl.dsp.workspace.rename({ workspace = i, name = name })
    end
end

--- Toggle between numeric and Chinese workspace names.
local function toggle_chinese_names()
    use_chinese = not use_chinese
    local labels = use_chinese and ws_labels.chinese or ws_labels.numeric
    apply_names(labels)
    notify.info(use_chinese and "Workspace names: Chinese" or "Workspace names: numeric")
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

for _, rule in ipairs(ws_rules) do
    hl.workspace_rule(rule)
end

hl.workspace_rule({
    workspace = "r[3-5] w[t1]",
    gaps_out = single_window_gaps,
})

-- Set initial workspace names
apply_names(ws_labels.numeric)

-------------------------------------------------------
-- Exports
-------------------------------------------------------

return {
    toggle_chinese_names = toggle_chinese_names,
}
