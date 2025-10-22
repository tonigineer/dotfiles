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
        [ -f ~/.config/zed/settings.json ] &&
        [ -f ~/.config/zed/keymap.json ]
}

install() {
    yay_install "${pkgs[@]}"

    # safe_symlink .config/zed

    # Note: Zed's hot-reload does not work with symlinks.
    ln -f .config/zed/keymap.json ~/.config/zed/keymap.json
    ln -f .config/zed/settings.json ~/.config/zed/settings.json
    ln -f ~/.local/state/caelestia/theme/zed.json ~/.config/zed/themes/caelestia.json
}

uninstall() {
    local pkgs=(zed)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/zed
}
