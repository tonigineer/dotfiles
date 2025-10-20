#!/usr/bin/env bash

repo=https://github.com/tonigineer/nvim

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

status() {
    yay_check "${pkgs[@]}" &&
        [[ $(git -C ~/.config/nvim remote get-url origin 2>/dev/null) == "$repo" ]]
}

install() {
    yay_install "${pkgs[@]}"

    git clone $repo ~/.config/zsh
    sudo npm install -g tree-sitter-cli
}

uninstall() {
    local pkgs=(luarocks lua51 neovim npm)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/nvim
}
