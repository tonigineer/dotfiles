#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if ! command -v yay &>/dev/null; then
    echo " Bootstrapping yay ..."
    echo "  - installing dependencies"
    sudo pacman -S git base-devel vim
    cd /opt
    sudo git clone https://aur.archlinux.org/yay.git
    sudo chown -R $USER:wheel ./yay
    cd yay 
    makepkg -si

    yay -Syu
fi

if ! command -v cargo &>/dev/null; then
    echo "Bootstrapping rust ... "
    yay -S rustup
    echo " - configuring"
    rustup default stable
fi

if ! command -v stow &>/dev/null; then
    echo "Bootstrapping stow ..."
    yay -S stow
fi

cd "$SCRIPT_DIR/assets/install" || exit 1

cargo run --release
