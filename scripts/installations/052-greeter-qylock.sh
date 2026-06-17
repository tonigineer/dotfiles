# ── Greeter — SDDM + qylock lockscreen ──────────────────────────────────

pkgs=(
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
}

mod_check() {
    systemctl --quiet is-active sddm.service
}

mod_post_uninstall() {
    sudo systemctl disable sddm.service
    sudo rm -rf /opt/qylock/
}
