--
-- conf/env.lua
-- Environment variables set before display server init
-- Reference: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--

local notify = require("conf.notify")

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local HOME = os.getenv("HOME") or ""

local nvidia_env = {
    -- Force GBM as the buffer API backend (required for Nvidia ≥495 on Wayland)
    { "GBM_BACKEND",                "nvidia-drm"                  },
    -- Use nvidia-vaapi-driver for hardware video acceleration (needs libva-nvidia-driver)
    { "LIBVA_DRIVER_NAME",          "nvidia"                      },
    -- Route GLX calls through the Nvidia vendor library (may break XWayland screenshare)
    { "__GLX_VENDOR_LIBRARY_NAME",  "nvidia"                      },
    -- Use direct backend for nvidia-vaapi-driver (avoids Firefox/Electron decode issues)
    { "NVD_BACKEND",                "direct"                      },
    -- Disable G-Sync VRR at the driver level (managed by Hyprland's misc.vrr instead)
    { "__GL_GSYNC_ALLOWED",         "0"                           },
    -- Disable Adaptive Sync at the driver level (avoids glitches in some games)
    { "__GL_VRR_ALLOWED",           "0"                           },

    -- Vulkan -------------------------------------------------
    -- Force vkd3d-proton (D3D12→Vulkan) to pick the Nvidia GPU on multi-GPU systems
    { "VKD3D_FILTER_DEVICE_NAME",   "NVIDIA"                                  },
    -- Point the Vulkan loader directly at the Nvidia ICD manifest (skips auto-discovery)
    { "VK_ICD_FILENAMES",           "/usr/share/vulkan/icd.d/nvidia_icd.json" },

    -- Shader cache -------------------------------------------
    -- Explicitly enable the GL shader disk cache (on by default for non-root, but be sure)
    { "__GL_SHADER_DISK_CACHE",              "1"                  },
    -- Bypass the 256 MB cache size limit — prevents eviction of compiled shaders (useful for Wine/DXVK)
    { "__GL_SHADER_DISK_CACHE_SKIP_CLEANUP", "1"                  },
    -- Store shader cache in a dedicated directory instead of the default ~/.nv/GLCache
    { "__GL_SHADER_DISK_CACHE_PATH",         HOME .. "/.cache/nv" },
}

local hyprland_env = {
    -- Disable Hyprland's realtime (SCHED_RR) thread priority — let ananicy-cpp handle scheduling
    { "HYPRLAND_NO_RT",         "1" },
    -- Disable explicit sync on multi-GPU buffers (Aquamarine workaround for some Nvidia setups)
    { "AQ_MGPU_NO_EXPLICIT",    "1" },
}

local wayland_env = {
    -- Allow GPU-accelerated media decoding without the RDD sandbox (Nvidia workaround)
    { "MOZ_DISABLE_RDD_SANDBOX",    "1" },
    -- Tell EGL to target Wayland instead of X11
    { "EGL_PLATFORM",               "wayland" },
    -- Enable Firefox's native Wayland backend
    { "MOZ_ENABLE_WAYLAND",         "1" },
}

-------------------------------------------------------
-- Helpers
-------------------------------------------------------

--- Check if an Nvidia GPU is present via lspci.
--- @return boolean
local function has_nvidia_gpu()
    local handle = io.popen("lspci 2>/dev/null | grep -qi nvidia && echo y || echo n")
    if not handle then return false end
    local result = handle:read("*l")
    handle:close()
    return result == "y"
end

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

apply_env(wayland_env)
apply_env(hyprland_env)

if has_nvidia_gpu() then
    apply_env(nvidia_env)
    notify.info("Nvidia GPU detected — driver environment loaded")
else
    notify.warning("No Nvidia GPU found — skipping driver environment")
end
