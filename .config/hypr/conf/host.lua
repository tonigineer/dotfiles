--
-- conf/host.lua
-- Machine identity and per-host profile (conf/hosts/<hostname>.lua)
-- $DOTFILES_HOST overrides /etc/hostname, e.g. to test another machine's setup.
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Detection
-------------------------------------------------------

--- Read /etc/hostname rather than `hostnamectl` to avoid a subprocess at parse time.
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

M.name = detect()

--- This machine's profile, or conf/hosts/default.lua.
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

--- @param name string
--- @return boolean
function M.is(name)
    return M.name == name
end

return M
