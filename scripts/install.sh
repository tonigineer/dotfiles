#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/utils.sh"

cd $SCRIPT_DIR/..
git submodule update --init --recursive

setup=$1

install_base() {
    yay -S hyprland-git \
        hyprpicker-git hyprlock-git hyprpaper-git hypridle-git \
        rofi-lbonn-wayland-only-git \
        aylurs-gtk-shell-git bun-bin sass gnome-bluetooth-3.0 \
        socat net-tools inetutils iwd jq \
        polkit-gnome terminus-font dmidecode brightnessctl \
        firefox vesktop \
        grim-git slurp-git vlc wf-recorder swappy wl-clipboard imagemagick \
        mpvpaper-git yt-dlp \
        kando-bin

    create_symlink .config/ags
    create_symlink .config/hypr
    create_symlink .config/mpv
    create_symlink .config/rofi

    mkdir -p "/home/$USER/.local/share"
    create_symlink .local/share/backgrounds

    yay -S thunar thunar-volman gvfs xdg-user-dirs tumbler
    xdg-user-dirs-update
}

install_audio() {
    # https://wiki.archlinux.org/title/bluetooth
    yay -S bluez bluez-utils

    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service

    # https://wiki.archlinux.org/title/PipeWire
    yay -S pipewire wireplumber pipewire-audio pipewire-alsa pipewire-pulse \
        pipewire-jack pipewire-audio pavucontrol playerctl
}

install_theme() {
    yay -S gnome-shell \
        candy-icons rose-pine-cursor rose-pine-hyprcursor \
        tokyonight-gtk-theme-git ttf-cascadia-code-nerd

    # currently, needed to pull the repo manually for the icons to work
    # https://github.com/EliverLara/candy-icons

    # Apply theme right now

    source "$SCRIPT_DIR/../home/.config/hypr/scripts/theme.sh" \
        Tokyonight-Dark \
        candy-icons \
        BreezeX-RosePine-Linux 24 \
        "CaskaydiaCove Nerd Font 10"
}

install_terminal() {
    yay -S kitty \
        neovim vim zsh yazi \
        curl eza unzip tar wget zip \
        btop cava cmatrix-git fastfetch tty-clock \
        ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd

    # Link all configs
    create_symlink .bashrc
    create_symlink .bash_profile
    create_symlink .bash_aliases

    create_symlink .local/bin

    create_symlink .config/kitty
    create_symlink .config/btop
    create_symlink .config/cava
    create_symlink .config/fastfetch
    create_symlink .config/nvim
    create_symlink .config/yazi

    create_symlink .config/zsh
    ln -s ~/.config/zsh/.zshrc ~/.zshrc

    # Install dependencies for nvim config
    sudo pacman -S fd luarocks npm python-pip python-pynvim \
        ripgrep rustup yarn wl-clipboard
    rustup default stable

    yay -S fswatch

    yarn global add tree-sitter-cli
    cargo install tree-sitter-cli
    sudo npm install -g tree-sitter-cli
}

case $setup in

all)
    install_base
    install_terminal
    install_audio
    install_theme
    ;;

base)
    install_base
    ;;

terminal)
    install_terminal
    ;;

audio)
    install_audio
    ;;

theme)
    install_theme
    ;;

*)
    echo "Provide an argument: ./install.sh all|base|terminal|audio|theme"
    ;;
esac
