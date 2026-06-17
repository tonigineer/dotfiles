# ── Terminal — kitty + yazi + CLI tools ─────────────────────────────────

pkgs=(
    kitty
    lazygit
    otf-monaspace
    ttf-joypixels
    yazi
    btop
    cava
    fastfetch
)

remove_pkgs=(
    kitty
    yazi
)

links=(
    .config/btop
    .config/fastfetch
    .config/kitty
    .config/yazi
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    fc-cache -v

    # Declare the plugins (ignore "already exists"), then install whatever
    # package.toml lists. Both are best-effort so a re-run never fails here.
    ya pkg add yazi-rs/plugins:no-status || true
    ya pkg add yazi-rs/plugins:git || true
    ya pkg add yazi-rs/plugins:smart-enter || true
    ya pkg install || true
}

mod_post_uninstall() {
    rm -rf ~/.config/btop ~/.config/fastfetch ~/.config/kitty ~/.config/yazi
}
