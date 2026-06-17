# ── Shells — Noctalia desktop shell ─────────────────────────────────────

pkgs=(
    noctalia-shell
)

remove_pkgs=(
    "${pkgs[@]}"
)

links=(
    .config/noctalia
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_uninstall() {
    rm -rf ~/.config/noctalia
}
