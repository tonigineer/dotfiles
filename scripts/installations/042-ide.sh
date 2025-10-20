#!/usr/bin/env bash

pkgs=(
    gnome-keyring
    libsecret
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
    zed
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.config/zed ]
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .config/zed
}

uninstall() {
    local pkgs=(zed)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/zed
}
