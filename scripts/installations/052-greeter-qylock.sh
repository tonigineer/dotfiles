# ── Greeter — SDDM + qylock lockscreen ──────────────────────────────────
#
# qylock also replaces Noctalia's locker on the way into suspend/hibernate.
# Noctalia's own "lock before suspend" is turned off in its settings.toml;
# the piece that takes over is a pair of units, because the lock has to be
# raised from root (logind runs sleep.target) into this user's graphical
# session:
#
#   /etc/systemd/system/qylock-lock-before-sleep.service   (written here)
#     Before=/WantedBy=sleep.target, so logind waits for it — the window is
#     InhibitDelayMaxSec (5s by default), hence the short settle wait rather
#     than a long one.
#   ~/.config/systemd/user/qylock-lock.service             (linked below)
#     runs lock.sh in the session the user manager already has the Wayland
#     environment for.
#
# `systemctl --user --machine=<user>@.host` is what bridges the two.

# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh
pkgs=(
    # qylock's lock.sh is a Quickshell shell. Noctalia used to drag Quickshell
    # in as a dependency; since its 5.0 native rewrite it no longer does, so
    # list it here — without it lock.sh dies with "quickshell: command not
    # found" and nothing locks.
    quickshell
    qt6-declarative
    qt6-5compat
    qt6-multimedia
    qt6-multimedia-ffmpeg
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    fzf
)

remove_pkgs=(
    "${pkgs[@]}"
)

links=(
    .config/systemd/user/qylock-lock.service
)

_sleep_unit=/etc/systemd/system/qylock-lock-before-sleep.service

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    local tmp
    tmp="$(mktemp -d)"

    git clone https://github.com/Darkkal44/qylock.git "$tmp/qylock"
    sudo cp -r "$tmp/qylock" /opt/qylock/

    (
        cd /opt/qylock/ || return 1
        sudo chmod +x sddm.sh quickshell.sh
        sudo ./sddm.sh
        ./quickshell.sh
    )

    sudo systemctl enable sddm.service

    # Preview the lockscreen if it's available (no-op otherwise).
    [ -x ~/.local/share/quickshell-lockscreen/lock.sh ] &&
        ~/.local/share/quickshell-lockscreen/lock.sh || true

    # Copy config files for hyprland compositor used by sddm
    if [ -f "$dotfiles_dir/.config/sddm/10-wayland.conf" ]; then
        sudo mkdir -p /etc/sddm.conf.d
        sudo cp -f "$dotfiles_dir/.config/sddm/10-wayland.conf" /etc/sddm.conf.d/10-wayland.conf
    fi

    if [ -f "$dotfiles_dir/.config/sddm/hyprland.lua" ]; then
        sudo mkdir -p /var/lib/sddm/.config/hypr
        sudo cp -f "$dotfiles_dir/.config/sddm/hyprland.lua" /var/lib/sddm/.config/hypr/hyprland.lua
    fi

    # Lock with qylock before the machine goes to sleep. `systemctl start` on
    # the Type=exec user unit returns once lock.sh has been exec'd, which is
    # before Quickshell has taken the ext-session-lock — the settle wait
    # covers that gap so the hibernation image is written with the screen
    # already locked. Neither Hyprland nor qylock exposes the lock state
    # (LockedHint stays "no"), so there is nothing better to poll for; 2s is
    # far more than Quickshell needs and still inside logind's
    # InhibitDelayMaxSec, which is 5s by default.
    sudo tee "$_sleep_unit" >/dev/null <<EOF
[Unit]
Description=Lock the session with qylock before sleep
Documentation=https://github.com/Darkkal44/qylock
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl --user --machine=$USER@.host start qylock-lock.service
ExecStartPost=/usr/bin/sleep 2
TimeoutStartSec=4

[Install]
WantedBy=sleep.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable qylock-lock-before-sleep.service
    systemctl --user daemon-reload
}

mod_check() {
    systemctl --quiet is-active sddm.service &&
        systemctl --quiet is-enabled qylock-lock-before-sleep.service
}

mod_post_uninstall() {
    sudo systemctl disable sddm.service
    sudo systemctl disable qylock-lock-before-sleep.service
    sudo rm -f "$_sleep_unit"
    sudo systemctl daemon-reload
    sudo rm -rf /opt/qylock/
}
