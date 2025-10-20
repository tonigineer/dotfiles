#!/usr/bin/env bash

repo_noctalia=https://github.com/noctalia-dev/noctalia-shell.git
repo_caelestia=https://github.com/caelestia-dots/shell.git

pkgs=(
    matugen-git
    quickshell-git
    caelestia-shell-git
)

status() {
    yay_check "${pkgs[@]}" &&
        [[ $(git -C ~/.config/quickshell/caelestia/ remote get-url origin 2>/dev/null) == "$repo_caelestia" ]] &&
        [[ $(git -C ~/.config/quickshell/noctalia/ remote get-url origin 2>/dev/null) == "$repo_noctalia" ]] &&
        [ -L ~/.config/noctalia ] &&
        [ -L ~/.config/caelestia ] &&
        [ -L ~/.config/matugen ]
}

install() {
    yay_install "${pkgs[@]}"

    git clone $repo_caelestia ~/.config/quickshell/caelestia
    git clone $repo_noctalia ~/.config/quickshell/noctalia/

    safe_symlink .config/noctalia
    safe_symlink .config/caelestia
    safe_symlink .config/matugen
}

uninstall() {
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/quickshell

    rm -rf ~/.config/noctalia
    rm -rf ~/.config/caelestia
    rm -rf ~/.config/matugen
}
