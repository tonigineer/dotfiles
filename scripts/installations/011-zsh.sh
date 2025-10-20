#!/usr/bin/env bash

repo=https://github.com/tonigineer/zsh

pkgs=(
    ttf-jetbrains-mono-nerd
    ttf-cascadia-code-nerd
    otf-monaspace
    zsh
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.zshrc ] &&
        [[ $(git -C ~/.config/zsh remote get-url origin 2>/dev/null) == "$repo" ]]
}

install() {
    yay_install "${pkgs[@]}"

    git clone $repo ~/.config/zsh
    ln -s ~/.config/zsh/.zshrc ~/.zshrc
}

uninstall() {
    yay_uninstall zsh

    rm -rf ~/.config/zsh
    rm ~/.zshrc
}
