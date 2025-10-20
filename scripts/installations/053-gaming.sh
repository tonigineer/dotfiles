#!/usr/bin/env bash

pkgs=(
    gamescope
    lib32-fontconfig
    mangohud
    steam
    ttf-liberation
    vesktop-bin
    wqy-microhei
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.config/mangohud ]
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .config/mangohud

    fc-cache -v
}

uninstall() {
    local pkgs=(steam mangohud gamescope)
    yay_uninstall "${pkgs[@]}"

    rm -rf .config/mangohud
}
