#!/usr/bin/env bash

status() {
    false
}

install() {
    echo "No install"

    pause_any
}

uninstall() {
    echo "No uninstall"

    pause_any
}

# {
#     "name": "SDDM Theme",
#     "category": "grub",
#     "packages": ["sddm", "qt6-svg", "qt6-virtualkeyboard", "qt6-multimedia-ffmpeg", "qt6-wayland", "layer-shell-qt", "layer-shell-qt5"],
#     "configs": ["sddm"],
#     "checks": ["[ -d /usr/share/sddm/themes/sddm-astronaut-theme/ ] && true || false",
#     "[ -d /var/lib/sddm/.config/hypr/ ] && true || false"],
#     "prior_install": [],
#     "post_install": [
#         "sudo ln -s $HOME/.config/sddm/themes/sddm-astronaut-theme/ /usr/share/sddm/themes",
#         "sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/",
#         "sudo cp $HOME/.config/sddm/sddm.conf /etc/",
#         "sudo cp -r $HOME/.config/sddm/sddm.conf.d/ /etc/",
#         "sudo mkdir -p /var/lib/sddm/.config/hypr",
#         "sudo cp $HOME/.config/hypr/hyprland.conf /var/lib/sddm/.config/hypr/",
#         "sudo systemctl enable sddm.service"
#     ]
