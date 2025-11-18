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

    mkdir -p ~/.config/zed/themes
    ln -f ~/.local/state/caelestia/theme/zed.json ~/.config/zed/themes/caelestia.json
}

uninstall() {
    local pkgs=(zed)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/zed
}
