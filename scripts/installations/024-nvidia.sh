#!/usr/bin/env bash

nvidia_conf=/etc/modprobe.d/nvidia.conf

pkgs=(
    nvidia
    nvidia-utils
)

status() {
    yay_check "${pkgs[@]}" &&
        grep -qF 'options nvidia_drm modeset=1' $nvidia_conf &&
        grep -qF 'nvidia nvidia_modeset nvidia_uvm nvidia_drm' /etc/mkinitcpio.conf
}

install() {
    yay_install "${pkgs[@]}"

    echo "options nvidia_drm modeset=1" >$nvidia_conf
    sed -i s/MODULES=\(\)/MODULES=\(nvidia nvidia_modeset nvidia_uvm nvidia_drm\)/ /etc/mkinitcpio.conf

    sudo mkinitcpio -P
}

uninstall() {
    yay_uninstall "${pkgs[@]}"
}
