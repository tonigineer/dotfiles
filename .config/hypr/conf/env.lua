--
-- conf/env.lua
-- Environment variables for Wayland, Qt, and XDG
-- Reference: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local general_env = {
    -- Electron
    { "ELECTRON_OZONE_PLATFORM_HINT",           "auto"          },

    -- Qt
    { "QT_AUTO_SCREEN_SCALE_FACTOR",            "1"             },
    { "QT_WAYLAND_DISABLE_WINDOWDECORATION",    "1"             },
    { "QT_QPA_PLATFORM",                        "wayland;xcb"   },
    { "QT_QPA_PLATFORMTHEME",                   "qt6ct"         },

    -- XDG
    { "XDG_MENU_PREFIX",                        "arch-"         },
    { "XDG_SESSION_TYPE",                       "wayland"       },
    { "XDG_CURRENT_DESKTOP",                    "Hyprland"      },
    { "XDG_SESSION_DESKTOP",                    "Hyprland"      },

    -- Misc
    { "_JAVA_AWT_WM_NONEREPARENTING",           "1"             },
    { "CLUTTER_BACKEND",                        "wayland"       },
    { "TERMINAL",                               "kitty"         },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Apply a list of environment variables.
--- @param vars table[] { { key, value }, ... }
local function apply_env(vars)
    for _, entry in ipairs(vars) do
        hl.env(entry[1], entry[2])
    end
end

-------------------------------------------------------
-- Apply
-------------------------------------------------------

apply_env(general_env)
