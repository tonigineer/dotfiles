# ── Neovim — neovim + external config repo ──────────────────────────────

_repo=https://github.com/tonigineer/nvim

pkgs=(
    fd
    go
    lazygit
    lua51
    luarocks
    neovim
    npm
    python-pip
    python-pynvim
    ripgrep
    wget
    wl-clipboard
)

remove_pkgs=(
    luarocks
    lua51
    neovim
    npm
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    [ -d ~/.config/nvim ] || git clone "$_repo" ~/.config/nvim
    sudo npm install -g tree-sitter-cli
}

mod_check() {
    [ "$(git -C ~/.config/nvim remote get-url origin 2>/dev/null)" = "$_repo" ]
}

mod_pre_uninstall() {
    rm -rf ~/.config/nvim
}
