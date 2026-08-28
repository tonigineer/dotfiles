# ── Kraken LCD — NZXT Kraken Elite 360 RGB screen ───────────────────────
#
# The cooler's 640x640 LCD is driven by liquidctl, not OpenRGB (which is
# lighting-only and does not even enumerate this device). Sensors need nothing
# extra: the in-kernel `nzxt_kraken3` driver already exposes coolant temp and
# pump/fan RPM through hwmon, so `sensors` reports them out of the box.
#
# liquidctl ships /usr/lib/udev/rules.d/71-liquidctl.rules, which grants the
# logged-in user write access — no sudo, no polkit, nothing to add here. That
# matters because the caller is a Hyprland listener with no tty.
#
# `kraken-lcd {doom|pixel}` is invoked from .config/hypr/conf/autostart.lua,
# which subscribes to the vanity gamemode toggle (SUPER+F1). It is deliberately
# idempotent: that listener also fires on every config reload, and a push is a
# multi-MB USB transfer taking seconds.
#
# NOTE: the animations themselves live in ~/Pictures/#Animations and are user
# data, intentionally not tracked here — they are far too large for the repo.
# The script degrades safely if they are missing (liquidctl fails, it retries,
# then logs FAILED and exits non-zero).

pkgs=(
    liquidctl
)

remove_pkgs=(
    liquidctl
)

links=(
    .local/bin/kraken-lcd
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_check() {
    [ -x ~/.local/bin/kraken-lcd ]
}
