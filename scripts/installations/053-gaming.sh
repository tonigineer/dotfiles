#!/usr/bin/env bash

pkgs=(
    gamescope
    lib32-fontconfig
    mangohud
    steam
    ttf-liberation
    vesktop-bin
    wqy-microhei
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.config/mangohud ]
}

install() {
    yay_install "${pkgs[@]}"

    safe_symlink .config/mangohud

    fc-cache -v

    # Exemplary start command for The Witcher 3, Red Dead Redemption 2
    # - Set custom mangohud config dir and use --mangoapp
    # - Set --force-grab-cursor to get rid of mouse problems in wayland
    #
    #
    # MANGOHUD_CONFIG="read_cfg" MANGOHUD_CONFIGFILE="$HOME/.config/mangohud/mangohud.conf" \
    #   gamescope -f -w 3840 -h 2160 -r 160 --adaptive-sync --rt --immediate-flips --force-grab-cursor --mangoapp \
    #   -- %command%
    #
    # Current Settings
    # DOTA2: WLR_NO_HARDWARE_CURSORS=1 MANGOHUD_CONFIG="read_cfg" MANGOHUD_CONFIGFILE="$HOME/.config/mangohud/mangohud.conf" mangohud %command%
}

uninstall() {
    local pkgs=(steam mangohud gamescope)
    yay_uninstall "${pkgs[@]}"

    rm -rf .config/mangohud
}
