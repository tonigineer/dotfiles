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

-- Profiles live in conf/hosts/<hostname>.lua. `desc` must match
-- `hyprctl monitors` without the port suffix.
local host_profile, host_name = host.profile()
local profiles = host_profile.monitors or {}

if not next(profiles) then
    notify.info("No monitor profile for host '" .. host.name ..
        "' (loaded " .. host_name .. ") — falling back to the catch-all rule")
end

local fallback = host_profile.fallback or {
    mode     = "preferred",
    position = "auto",
    scale    = "1.0",
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- @param desc string
--- @return string
local function desc_output(desc)
    return "desc:" .. desc
end

--- Set of connected monitor descriptions.
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
--- @return string|nil primary
--- @return string|nil secondary
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

for _, profile in pairs(profiles) do
    hl.monitor({
        output   = desc_output(profile.desc),
        mode     = profile.mode,
        position = profile.position,
        scale    = profile.scale,
    })
end

hl.monitor({
    output   = "",
    mode     = fallback.mode,
    position = fallback.position,
    scale    = fallback.scale,
})

-- local connected = get_connected_descs()
-- for name, profile in pairs(profiles) do
--     if connected[profile.desc] then
--         notify.info(name .. " connected (" .. profile.role .. ")")
--     end
-- end

-------------------------------------------------------
-- Exports
-------------------------------------------------------

-- A function, not a snapshot: no monitor is connected yet at startup parse.
return {
    resolve = resolve_active_monitors,
}
