#!/usr/bin/env bash

pkgs=(
    cmatrix
    curl
    eza
    fontconfig
    otf-monaspace
    tar
    terminus-font
    ttf-cascadia-code-nerd
    tty-clock
    unzip
    wget
    zip
)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.bashrc ] &&
        [ -L ~/.bash_aliases ] &&
        [ -L ~/.bash_profile ]
}

install() {
    yay_install "${pkgs[@]}"

    git config --global credential.helper store

    safe_symlink .bashrc
    safe_symlink .bash_aliases
    safe_symlink .bash_profile

    fc-cache -v
}

uninstall() {
    mv ~/.bashrc.bak ~/.bashrc
    mv ~/.bash_aliases.bak ~/.bash_aliases
    mv ~/.bash_profile.bak ~/.bash_profile
}
