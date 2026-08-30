--
-- conf/host.lua
-- Machine identity — this config is shared between several computers
--
-- Anything that differs per machine (monitors, scaling, …) lives in
-- conf/hosts/<hostname>.lua. This module resolves which one applies:
--
--   1. $DOTFILES_HOST, when set (useful for testing another machine's setup)
--   2. the static hostname from /etc/hostname
--   3. "default", when neither yields a name
--
-- A host without its own file falls back to conf/hosts/default.lua, so a new
-- machine works out of the box and only needs a file once it differs.
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Detection
-------------------------------------------------------

--- Read the static hostname. Uses /etc/hostname rather than `hostnamectl`
--- so config parsing never waits on a subprocess.
--- @return string
local function detect()
    local override = os.getenv("DOTFILES_HOST")
    if override and override ~= "" then
        return override
    end

    local handle = io.open("/etc/hostname", "r")
    if handle then
        local line = handle:read("*l")
        handle:close()
        if line then
            line = line:gsub("%s", "")
            if line ~= "" then
                return line
            end
        end
    end

    return "default"
end

-------------------------------------------------------
-- Profile lookup
-------------------------------------------------------

local M = {}

--- Name of the machine this config is running on.
M.name = detect()

--- The host profile table for this machine (conf/hosts/<name>.lua), or the
--- default profile when the machine has no file of its own.
--- @return table profile
--- @return string source  name of the host file that was loaded
function M.profile()
    for _, name in ipairs({ M.name, "default" }) do
        local ok, mod = pcall(require, "conf.hosts." .. name)
        if ok and type(mod) == "table" then
            return mod, name
        end
    end

    notify.error("No host profile found for " .. M.name)
    return {}, "none"
end

--- True when running on the named machine.
--- @param name string
--- @return boolean
function M.is(name)
    return M.name == name
end

return M
