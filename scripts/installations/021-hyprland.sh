# ── Hyprland — compositor + portals + theming ───────────────────────────

# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh
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
    wl-clipboard
    yt-dlp
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

_pkgs_theme=(
    win11-icon-theme-git
    otf-monaspace
    rose-pine-cursor
    rose-pine-hyprcursor
)

remove_pkgs=(
    hyprland
    hyprpaper
    hypridle
    hyprlock
    hyprpolkitagent
    hypr-zoom
    win11-icon-theme-git
    rose-pine-cursor
    rose-pine-hyprcursor
)

links=(
    .config/hypr
    .config/mpv
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    ln -sf "$dotfiles_dir/assets/avatar.jpg" ~/.face
    safe_symlink .config/gtk-3.0/gtk.css

    yay_install "${_pkgs_theme[@]}"
    fc-cache -v
}

mod_check() {
    yay_check "${_pkgs_theme[@]}" &&
        [ -L ~/.config/gtk-3.0/gtk.css ]
}

mod_post_uninstall() {
    rm -rf ~/.config/hypr ~/.config/mpv
}
