# Dota 2 on Hyprland (native Wayland, 4K)

Steam launch options:

```
SDL_VIDEO_DRIVER=wayland,x11 SDL_VIDEO_WAYLAND_SCALE_TO_DISPLAY=1 MANGOHUD_CONFIGFILE="$HOME/.config/mangohud/mangohud.conf" mangohud %command% -vulkan
```

Compatibility → **"Force the use of a specific Steam Play compatibility tool" must be off.**

## Why each part

- **No Proton.** Dota 2 has a native Linux build. Under Proton, VAC can't verify the
  session and matchmaking is blocked.
- `SDL_VIDEO_DRIVER=wayland` — Dota ships **SDL3**, which renamed the SDL2 hint
  `SDL_VIDEODRIVER`. The SDL2 spelling is silently ignored. `game/dota.sh` defaults to
  `x11` only when the var is unset, so setting it is the supported path. A comma-separated
  fallback list works — `wayland,x11` still lands on Wayland, and degrades to X11 instead
  of failing to start if a future update breaks the Wayland backend.
- `SDL_VIDEO_WAYLAND_SCALE_TO_DISPLAY=1` — monitors are 3840x2160 at `scale 2.00`, so a
  Wayland client is handed a 1920x1080 logical canvas and the resolution list caps there.
  This makes SDL render at the display's real pixel size.

## Verify

```bash
hyprctl clients | grep -A9 'class: dota2' | grep xwayland   # want: xwayland: 0
```

For render resolution, add `resolution` to the MangoHud config — it reports the swapchain
size (want `3840x2160`).

## gamescope

Works (`gamescope -W 3840 -H 2160 -r 160 -f -- %command% -vulkan`) but unnecessary, and
the game then runs on gamescope's internal Xwayland. Don't combine it with
`SDL_VIDEO_DRIVER=wayland` — that crashes Dota. `-r` must match the panel: DP-1 is 160 Hz,
DP-3 is 144 Hz.
