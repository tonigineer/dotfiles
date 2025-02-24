#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/utils.sh"

cd $SCRIPT_DIR/..
git submodule update --init --recursive

install_base() {
    yay -S hyprland \
        hyprpicker hyprlock hyprpaper hypridle \
        aylurs-gtk-shell-git bun-bin sass sassc gnome-bluetooth-3.0 libdbusmenu-gtk3 \
        socat inetutils iwd jq \
        polkit-gnome terminus-font swaync \
        firefox vesktop \
        hyprshot grim-git slurp-git vlc wf-recorder swappy wl-clipboard imagemagick \
        mpvpaper-git yt-dlp \
        kando-bin

    create_symlink .config/ags
    create_symlink .config/hypr
    create_symlink .config/kando
    create_symlink .config/mpv

    mkdir -p "/home/$USER/.local/share"
    create_symlink .local/share/backgrounds

    yay -S xdg-user-dirs
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

case $1 in
-f | --full)
    install_base
    install_terminal
    install_audio
    install_theme
    ;;
-b | --base)
    install_base
    ;;
-c | --cli)
    install_terminal
    ;;
-a | --audio)
    install_audio
    ;;
-t | --theme)
    install_theme
    ;;
-h | --help | *)
    echo -e "Installation script \033[31mhttps://github.com/tonigineer/dotfiles\033[0m"
    echo ""
    echo -e "\033[33mUSAGE\033[0m     install.sh [OPTION]"
    echo ""
    echo "  -h, --help      Show help"
    echo -e "  -f, --full   Install everything (\033[32mrecommended\033[0m)"
    echo "  -b, --base      Install basic hyprland with AGS"
    echo "  -c, --cli       Setup up terminal with zsh, nvim, etc."
    echo "  -t, --theme     Install themes, icons, cursors"
    echo "  -a, --audio     Install audio stuff"
    ;;
esac
