#!/usr/bin/env bash

pkgs=(
    kitty
    lazygit
    otf-monaspace
    ttf-joypixels
    yazi
)

pkgs_tools=(
    btop
    cava
    fastfetch
)

status() {
    yay_check "${pkgs[@]}" && yay_check "${pkgs_tools[@]}" &&
        [ -L ~/.config/btop ] &&
        [ -L ~/.config/fastfetch ] &&
        [ -L ~/.config/kitty ] &&
        [ -L ~/.config/yazi ]
}

install() {
    yay_install "${pkgs[@]}"
    yay_install "${pkgs_tools[@]}"

    safe_symlink .config/btop
    safe_symlink .config/fastfetch
    safe_symlink .config/kitty
    safe_symlink .config/yazi

    fc-cache -v

    ya pkg add yazi-rs/plugins:no-status
    ya pkg add yazi-rs/plugins:git
    ya pkg add yazi-rs/plugins:smart-enter
    # ya pkg add marcosvnmelo/kanagawa-dragon

    local CAVA_TEMPLATE=/usr/lib64/python3.13/site-packages/caelestia/data/templates/cava.conf
    sudo sed -i 's/bars = 64/max_height = 80\
bar_width = 1\
bar_spacing = 0\
sensitivity = 50/' "$CAVA_TEMPLATE"
    sudo sed -i 's/gravity = 120/gravity = 50/' "$CAVA_TEMPLATE"
    sudo sed -i 's/framerate = 60/framerate = 80/' "$CAVA_TEMPLATE"
}

uninstall() {
    local pkgs=(kitty yazi)
    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/btop
    rm -rf ~/.config/fastfetch
    rm -rf ~/.config/kitty
    rm -rf ~/.config/yazi
}
