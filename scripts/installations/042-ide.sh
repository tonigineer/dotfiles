# ── IDE — Zed editor + portals ──────────────────────────────────────────

# NOTE: the caelestia zed theme link was dropped with caelestia; theming now
# comes from the desktop shell.

pkgs=(
    gnome-keyring
    libsecret
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
    zed
)

remove_pkgs=(
    zed
)

links=(
    .config/zed/keymap.json
    .config/zed/settings.json
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_uninstall() {
    rm -rf ~/.config/zed
}
