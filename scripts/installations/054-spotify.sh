#!/usr/bin/env bash

pkgs=(
    spotify
    spicetify-cli
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.config/spicetify/Themes ]
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .config/spicetify/Themes

    spicetify backup apply enable-devtools
    spicetify config current_theme Comfy
    spicetify apply
}

uninstall() {
    yay_uninstall "${pkgs[@]}"
}
