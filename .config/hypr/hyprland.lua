--
-- hyprland.lua
-- Entry point — loads all configuration modules
-- Reference: https://wiki.hypr.land/Configuring/Start/
--

-------------------------------------------------------
-- Each require() runs in its own scope, so an error
-- in one module does not stop execution of the others.
-------------------------------------------------------

-- Environment & hardware
require("conf.env")
require("conf.monitors")
require("conf.nvidia")

-- Appearance
require("conf.themes")
require("conf.vanity")

-- Behavior
require("conf.devices")
require("conf.inputs")
require("conf.layouts")
require("conf.settings")
require("conf.workspaces")
require("conf.windowrules")

-- Keybinds
require("conf.keybinds")

-- Startup
require("conf.autostart")
