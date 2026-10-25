--
-- conf/hostfiles.lua
-- Links this machine's per-host app settings into $HOME; warns on an unknown host
-- Reference: https://wiki.hypr.land/Configuring/Start/
--

local host = require("conf.host")
local notify = require("conf.notify")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local HOME = os.getenv("HOME") or ""

--- Target in $HOME -> per-host source in the repo (%s = hostname).
local links = {
    { target = "/.local/state/noctalia/settings.toml", source = "/.local/state/noctalia/settings.%s.toml" },
    { target = "/.config/skwd-wall-v2/config.json",    source = "/.config/skwd-wall-v2/config.%s.json" },
}

local warning_ms = 30000

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- @param s string
--- @return string
local function shquote(s)
    return "'" .. s:gsub("'", [['\'']]) .. "'"
end

--- First line of a shell command's output, or nil.
--- @param cmd string
--- @return string|nil
local function capture(cmd)
    local p = io.popen(cmd .. " 2>/dev/null")
    if not p then return nil end
    local line = p:read("*l")
    p:close()
    return line ~= "" and line or nil
end

--- @param path string
--- @return boolean
local function exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
end

--- Repo root, from where ~/.config/hypr really lives.
--- @return string|nil
local function repo_root()
    local hypr = capture("readlink -f " .. shquote(HOME .. "/.config/hypr"))
    return hypr and hypr:match("^(.*)/%.config/hypr$")
end

--- Point `target` at `source`; an existing file that is not that link is kept as .bak.
--- @param target string
--- @param source string
local function link(target, source)
    if capture("readlink -- " .. shquote(target)) == source then
        return
    end
    os.execute(string.format(
        "mkdir -p %s && { [ -L %s ] || [ ! -e %s ] || mv -f %s %s; } && ln -sfn %s %s",
        shquote(target:match("^(.*)/")), shquote(target), shquote(target),
        shquote(target), shquote(target .. ".bak"), shquote(source), shquote(target)
    ))
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

local _, profile_source = host.profile()
local known = profile_source == host.name
local root = repo_root()
local missing = {}

if not known then
    table.insert(missing, "conf/hosts/" .. host.name .. ".lua")
end

for _, l in ipairs(links) do
    local rel = l.source:format(host.name)
    if root and exists(root .. rel) then
        link(HOME .. l.target, root .. rel)
    else
        table.insert(missing, rel:sub(2))
    end
end

if #missing > 0 then
    hl.on("hyprland.start", function()
        notify.warning(string.format(
            "%s '%s', running on defaults. Missing: %s",
            known and "Incomplete host" or "Unknown host",
            host.name, table.concat(missing, ", ")
        ), { duration = warning_ms })
    end)
end
