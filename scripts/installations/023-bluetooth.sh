# ── Bluetooth — bluez + service ─────────────────────────────────────────

pkgs=(
    bluez
    bluez-utils
)

remove_pkgs=(
    "${pkgs[@]}"
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
}

mod_check() {
    systemctl --quiet is-active bluetooth.service
}
