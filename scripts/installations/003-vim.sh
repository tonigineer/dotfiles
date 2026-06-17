# ── Vim — config, shared with root ──────────────────────────────────────

links=(
    .vimrc
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    sudo ln -sf "$HOME/.vimrc" /root/.vimrc
}

mod_check() {
    sudo test -L /root/.vimrc
}

mod_pre_uninstall() {
    sudo rm -f /root/.vimrc
}
