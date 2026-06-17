# ── Zsh — zsh + external config repo ────────────────────────────────────

_repo=https://github.com/tonigineer/zsh

pkgs=(
    ttf-jetbrains-mono-nerd
    ttf-cascadia-code-nerd
    otf-monaspace
    zsh
)

remove_pkgs=(
    zsh
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    [ -d ~/.config/zsh ] || git clone "$_repo" ~/.config/zsh
    ln -sf ~/.config/zsh/.zshrc ~/.zshrc
}

mod_check() {
    [ -L ~/.zshrc ] &&
        [ "$(git -C ~/.config/zsh remote get-url origin 2>/dev/null)" = "$_repo" ]
}

mod_pre_uninstall() {
    rm -rf ~/.config/zsh ~/.zshrc
}
