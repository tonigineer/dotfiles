# ── Browser — Zen + portals ─────────────────────────────────────────────

# NOTE: the userChrome/userContent theming previously linked from the caelestia
# state dir was dropped along with caelestia. Re-add it here as a hook once the
# Noctalia zen template path is settled.

pkgs=(
    zen-browser-bin
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

remove_pkgs=(
    zen-browser-bin
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    xdg-settings set default-web-browser zen.desktop || true
}
