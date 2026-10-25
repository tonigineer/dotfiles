--
-- hyprland.lua
-- Entry point — loads all configuration modules
-- Reference: https://wiki.hypr.land/Configuring/Start/
--

-- An error in one require() does not stop the others.

-- Environment & hardware
require("conf.env")
require("conf.hostfiles")
require("conf.monitors")
require("conf.nvidia")

-- Appearance
require("conf.themes")
require("conf.vanity")

-- Behavior
require("conf.devices")
require("conf.dvdbounce")
require("conf.inputs")
require("conf.layouts")
require("conf.settings")
require("conf.workspaces")
require("conf.windowrules")
require("conf.wallpaper")

-- Keybinds
require("conf.keybinds")

-- Startup
require("conf.autostart")

-- Noctalia colours
require("conf.noctalia")
