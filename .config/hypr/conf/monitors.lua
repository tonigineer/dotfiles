--
-- conf/monitors.lua
-- Monitor profiles and configuration rules
-- Reference: https://wiki.hypr.land/Configuring/Basics/Monitors/
--

local notify = require("conf.notify")
local host = require("conf.host")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

--- Named monitor profiles for the machine this runs on.
--- Defined per host in conf/hosts/<hostname>.lua; see conf/host.lua for how
--- that file is picked.
--- `desc` must match the output of `hyprctl monitors` (without the port suffix).
--- `role` marks which monitor is primary and which is secondary per setup.
local host_profile, host_name = host.profile()
local profiles = host_profile.monitors or {}

if not next(profiles) then
    notify.info("No monitor profile for host '" .. host.name ..
        "' (loaded " .. host_name .. ") — falling back to the catch-all rule")
end

--- Fallback rule for any monitor not matched above (a host profile may
--- override it with its own `fallback` table).
local fallback = host_profile.fallback or {
    mode     = "preferred",
    position = "auto",
    scale    = "1.0",
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Build the `desc:` output string used by hl.monitor().
--- @param desc string
--- @return string
local function desc_output(desc)
    return "desc:" .. desc
end

--- Get a set of currently connected monitor descriptions.
--- @return table<string, boolean>
local function get_connected_descs()
    local descs = {}
    local monitors = hl.get_monitors()
    if not monitors then return descs end
    for _, m in ipairs(monitors) do
        if m.description then
            local clean = tostring(m.description):gsub("%s*%([^)]+%)%s*$", "")
            descs[clean] = true
        end
    end
    return descs
end

--- Resolve primary and secondary monitors from connected profiles.
--- @return string|nil primary   desc: string for the primary monitor
--- @return string|nil secondary desc: string for the secondary monitor (if any)
local function resolve_active_monitors()
    local connected = get_connected_descs()
    local primary, secondary = nil, nil

    for _, profile in pairs(profiles) do
        if connected[profile.desc] then
            local output = desc_output(profile.desc)
            if profile.role == "primary" and not primary then
                primary = output
            elseif profile.role == "secondary" and not secondary then
                secondary = output
            end
        end
    end

    -- A lone secondary display acts as the primary, so workspaces stay on it
    if not primary then
        primary, secondary = secondary, nil
    end

    return primary, secondary
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

-- Register a rule for every known profile (declarative — applies whenever the monitor connects)
for _, profile in pairs(profiles) do
    hl.monitor({
        output   = desc_output(profile.desc),
        mode     = profile.mode,
        position = profile.position,
        scale    = profile.scale,
    })
end

-- Catch-all for unknown monitors
hl.monitor({
    output   = "",
    mode     = fallback.mode,
    position = fallback.position,
    scale    = fallback.scale,
})

-- Report
-- local connected = get_connected_descs()
-- for name, profile in pairs(profiles) do
--     if connected[profile.desc] then
--         notify.info(name .. " connected (" .. profile.role .. ")")
--     end
-- end

-------------------------------------------------------
-- Exports
-------------------------------------------------------

-- `resolve` is a function, not a snapshot: no monitor is connected yet while
-- this file is being parsed at compositor startup, so callers have to ask again
-- once `hyprland.start` / `monitor.added` has fired.
return {
    resolve = resolve_active_monitors,
}
