#!/usr/bin/env bash

readonly TMP="$(mktemp -d)"

pkgs=(
    greetd
)


preview_theme() {
    CTOS_DEBUG=1 CTOS_MODE=test quickshell --path /opt/ctos/Greeter
}

theme_install() {
    git clone  https://github.com/TSM-061/ctOS $TMP/ctos
    sudo cp -r $TMP/ctos /opt/ctos/

    sudo cp "$dotfiles_dir/.config/greetd/config.toml" /etc/greetd/config.toml
    sudo cp "$dotfiles_dir/.config/greetd/greeter.config.json" /etc/ctos/greeter.config.json
    sudo cp "$dotfiles_dir/.config/greetd/greeter.hyprland.conf" /etc/ctos/greeter.hyprland.conf

    systemctl enable greetd.service
}

status() {
    yay_check "${pkgs[@]}" &&
        systemctl --quiet is-active greetd.service
}

install() {
    yay_install "${pkgs[@]}"

    theme_install
    preview_theme
}

uninstall() {
    sudo systemctl disable greetd.service

    readonly PGKS=(greetd)
    yay_uninstall "${PGKS[@]}"
}
