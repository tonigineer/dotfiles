#!/usr/bin/env bash

repo=https://github.com/Patato777/dotfiles.git
grub_cfg=/boot/grub/grub.cfg

status() {
    grep -qF 'set theme=($root)/grub/themes/virtuaverse/theme.txt' $grub_cfg
}

install() {
    tmp="$(mktemp -d)"
    git clone --depth=1 --single-branch "$repo" "$tmp"

    cd "$tmp/grub" || exit
    sudo "$tmp/grub/install_script_grub.sh"
}

uninstall() {
    echo "No uninstall defined. Edit /etc/default/grub and run grub-mkconfig ..."

    pause_any
}
