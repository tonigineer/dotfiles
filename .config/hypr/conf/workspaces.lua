--
-- conf/workspaces.lua
-- Workspace rules, monitor assignments, and naming
-- Reference: https://wiki.hypr.land/Configuring/Workspace-Rules/
--
-- The startup-placement reconciliation this file used to carry was dropped in
-- favour of `persistent = true` below; if workspaces come up on the wrong screen
-- after a cold boot, restore it from ~/.cache/hypr-workspaces-with-placement.lua.bak
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

--- Per-workspace settings. `display` is resolved to an actual monitor at apply
--- time: "secondary" falls back to the primary when only one screen is
--- connected, so a single-monitor setup keeps workspaces 1-5 together.
-- stylua: ignore start
local ws_defs = {
    { workspace = "1", display = "primary",   layout = "master"    },
    { workspace = "2", display = "primary",   layout = "scrolling" },
    { workspace = "3", display = "primary",   layout = "scrolling" },
    { workspace = "4", display = "primary",   layout = "master"    },
    { workspace = "5", display = "secondary", layout = "master"    },
}
-- stylua: ignore end

local special_rules = {
    { workspace = "special:media" },
    { workspace = "special:scratchpad" },
}

--- Gaps applied to single-window workspaces 2-5
local single_window_gaps = { top = 150, bottom = 150, left = 150, right = 150 }

--- Delay before a rename. One issued in the same tick a workspace is created is
--- silently dropped, and a freshly registered rule needs a tick to take.
local rename_ms = 50

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- The label set in use; `toggle_chinese_names` swaps it.
local labels = ws_labels.chinese

--- Rule handles from the last apply, disabled before re-applying.
local active_rules = {}

--- Monitor pair the current rules were built for; re-registering is skipped
--- while it is unchanged, since sync() runs on several overlapping triggers.
local applied_signature = nil

--- Label one workspace, a tick late so the rename is not dropped.
--- @param id integer
local function rename(id)
    if not labels[id] then return end
    hl.timer(function()
        hl.dispatch(hl.dsp.workspace.rename({ workspace = id, name = labels[id] }))
    end, { timeout = rename_ms, type = "oneshot" })
end

--- Label every workspace in the active set.
local function rename_all()
    for id = 1, #labels do rename(id) end
end

--- (Re)register the workspace rules for the monitors currently connected.
--- @return boolean applied  false when no monitor has been resolved yet
local function apply_rules()
    local primary, secondary = mon.resolve()
    if not primary then return false end

    local signature = primary .. "\0" .. (secondary or "")
    if signature == applied_signature then return true end
    applied_signature = signature

    for _, rule in ipairs(active_rules) do rule:set_enabled(false) end
    active_rules = {}

    -- Registered back to front so workspace 1's rule lands last and wins as the
    -- primary monitor's default.
    for i = #ws_defs, 1, -1 do
        local def = ws_defs[i]
        local on_second = def.display == "secondary" and secondary or nil
        active_rules[i] = hl.workspace_rule({
            workspace  = def.workspace,
            monitor    = on_second or primary,
            layout     = def.layout,
            default    = on_second ~= nil or def.workspace == "1",
            persistent = true,
        })
    end

    return true
end

--- Re-apply everything that depends on which monitors are connected.
local function sync()
    if apply_rules() then rename_all() end
end

--- Toggle between numeric and Chinese workspace names.
local function toggle_chinese_names()
    labels = labels == ws_labels.chinese and ws_labels.numeric or ws_labels.chinese
    rename_all()
    notify.info(labels == ws_labels.chinese and "Workspace names: Chinese" or "Workspace names: numeric")
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

for _, rule in ipairs(special_rules) do
    hl.workspace_rule(rule)
end

hl.workspace_rule({
    workspace = "r[3-5] w[t1]",
    gaps_out = single_window_gaps,
})

-- No monitor is connected yet during startup parsing, so this only takes effect
-- on `hyprctl reload`; the events below cover the startup and hotplug cases.
sync()

hl.on("workspace.created", function(ws)
    if ws and not ws.special then rename(ws.id) end
end)
hl.on("hyprland.start", sync)
hl.on("monitor.added", sync)
hl.on("monitor.removed", sync)

-------------------------------------------------------
-- Exports
-------------------------------------------------------

return {
    toggle_chinese_names = toggle_chinese_names,
}
