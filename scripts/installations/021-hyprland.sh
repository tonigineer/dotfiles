pkgs=(
    archlinux-xdg-menu
    brightnessctl
    grim
    hyprland
    hyprpaper
    hypridle
    hyprlock
    hyprpolkitagent
    hyprshot
    hypr-zoom
    imagemagick
    iwd
    jq
    libnewt
    libdbusmenu-gtk3
    mpv
    otf-monaspace
    qt5ct
    qt5-wayland
    qt6ct
    qt6-wayland
    slurp
    socat
    swaync
    wl-clipboard
    yt-dlp
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

pkgs_theme=(
    win11-icon-theme-git
    otf-monaspace
    rose-pine-cursor
    rose-pine-hyprcursor
)

status() {
    yay_check "${pkgs[@]}" &&
        yay_check "${pkgs_theme[@]}" &&
        [ -L ~/.config/hypr ] &&
        [ -L ~/.config/gtk-3.0/gtk.css ] &&
        [ -L ~/.config/mpv ] &&
        [ -L ~/.config/swaync ]
}

install() {
    yay_install "${pkgs[@]}"

    ln -sf $dotfiles_dir/assets/avatar.jpg ~/.face

    mkdir ~/.config/gtk-3.0
    ln -sf $dotfiles_dir/.config/gtk-3.0/gtk.css ~/.config/gtk-3.0

    safe_symlink .config/hypr
    safe_symlink .config/mpv
    safe_symlink .config/swaync

    yay_install "${pkgs_theme[@]}"

    fc-cache -v

    ~/.config/hypr/scripts/theme.sh \
        "" \
        Win11 \
        BreezeX-RosePine-Linux \
        32 \
        'Monaspace Krypton Bold 10'
}

uninstall() {
    local pkgs=(hyprland hyprpaper hypridle hyprlock
        hyprpolkitagent hypr-zoom
        gtk-theme-material-black win11-icon-theme-git
        rose-pine-cursor rose-pine-hyprcursor
    )

    yay_uninstall "${pkgs[@]}"

    rm -rf ~/.config/hypr
    rm -rf ~/.config/mpv
    rm -rf ~/.config/swaync
}
