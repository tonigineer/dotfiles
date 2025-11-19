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
        [ -L ~/.config/zed/keymap.json ] &&
        [ -L ~/.config/zed/settings.json ] &&
        [ -f ~/.config/zed/themes/caelestia.json ]
}

install() {
    yay_install "${pkgs[@]}"

    mkdir -p ~/.config/zed/themes

    safe_symlink .config/zed/keymap.json
    safe_symlink .config/zed/settings.json

    ln -f ~/.local/state/caelestia/theme/zed.json ~/.config/zed/themes/caelestia.json
}

uninstall() {
    local pkgs=(zed)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/zed
}
