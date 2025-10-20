#!/usr/bin/env bash

pkgs=(
    bluez
    bluez-utils
)

status() {
    yay_check "${pkgs[@]}" &&
        systemctl --quiet is-active bluetooth.service
}

install() {
    yay_install "${pkgs[@]}"

    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
}

uninstall() {
    yay_uninstall "${pkgs[@]}"
}
