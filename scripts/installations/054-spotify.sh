# ── Spotify — Spotify + spicetify ───────────────────────────────────────

pkgs=(
    spotify
    spicetify-cli
)

remove_pkgs=(
    "${pkgs[@]}"
)

links=(
    .config/spicetify/Themes
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    spicetify backup apply enable-devtools
    spicetify config current_theme Comfy
    spicetify apply
}
