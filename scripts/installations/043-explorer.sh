#!/usr/bin/env bash

pkgs=(
    evince
    ffmpegthumbnailer
    imv
    libopenraw
    libgsf
    libheif
    poppler-glib
    thunar
    tumbler
    webp-pixbuf-loader
)

status() {
    yay_check "${pkgs[@]}"
}

install() {
    yay_install "${pkgs[@]}"

    mkdir -p ~/.config/Thunar

    echo "utilities-terminal Open Terminal Here 1760453846169004-1 kitty --directory %f *" >~/.config/Thunar/uca.xml
}

uninstall() {
    local pkgs=(thunar)
    yay_uninstall "${pkgs[@]}"
}
