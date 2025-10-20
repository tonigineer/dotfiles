#!/usr/bin/env bash

pkgs=(
    evince
    thunar
    ffmpegthumbnailer
    imv
)

status() {
    yay_check "${pkgs[@]}"
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .config/Thunar

    mkdir -p ~/.config/Thunar
    echo "utilities-terminal Open Terminal Here 1760453846169004-1 kitty --directory %f *" >~/.config/Thunar/uca.xml
}

uninstall() {
    local pkgs=(thunar)
    yay_uninstall "${pkgs[@]}"
}
