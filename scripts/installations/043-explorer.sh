#!/usr/bin/env bash

pkgs=(
    evince
    ffmpegthumbnailer
    imv
    libopenraw
    libgsf
    libheif
    poppler-glib
    thunar
    tumbler
    webp-pixbuf-loader
)

status() {
    yay_check "${pkgs[@]}"
}

install() {
    yay_install "${pkgs[@]}"

    mkdir -p ~/.config/Thunar

    echo '<?xml version="1.0" encoding="UTF-8"?>
<actions>
<action>
<icon>utilities-terminal</icon>
<name>Open Terminal Here</name>
<submenu></submenu>
<unique-id>1763564326697889-1</unique-id>
<command>kitty --directory %f *</command>
<description>Open a terminal in this folder</description>
<range></range>
<patterns>*</patterns>
<startup-notify/>
<directories/>
</action>
</actions>' >~/.config/Thunar/uca.xml
}

uninstall() {
    local pkgs=(thunar)
    yay_uninstall "${pkgs[@]}"
}
