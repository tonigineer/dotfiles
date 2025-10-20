#!/usr/bin/env bash

pkgs=(
    pavucontrol
    pipewire
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    playerctl
    wireplumber
)

status() {
    yay_check "${pkgs[@]}"
}

install() {
    yay_install "${pkgs[@]}"
}

uninstall() {
    yay_uninstall "${pkgs[@]}"
}
