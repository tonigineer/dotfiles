# ── Gaming — Steam, gamescope, MangoHud, Vesktop ────────────────────────

# Needs multilib (enabled by 001-pacman) for steam + lib32-* packages.
pkgs=(
    gamescope
    lib32-fontconfig
    mangohud
    steam
    ttf-liberation
    vesktop-bin
    wqy-microhei
)

remove_pkgs=(
    steam
    mangohud
    gamescope
)

links=(
    .config/mangohud
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    fc-cache -v
}

mod_post_uninstall() {
    rm -rf ~/.config/mangohud
}
