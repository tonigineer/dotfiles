#!/usr/bin/env bash

pkgs=(
    librewolf-bin
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.librewolf ]
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .librewolf

    xdg-settings set default-web-browser librewolf.desktop
}

uninstall() {
    local pkgs=(librewolf-bin)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.librewolf
}
