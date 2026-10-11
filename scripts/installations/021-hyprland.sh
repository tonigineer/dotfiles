# ── Hyprland — compositor + portals + theming ───────────────────────────

# shellcheck disable=SC2154  # $dotfiles_dir is provided by install.sh
pkgs=(
    archlinux-xdg-menu
    brightnessctl
    grim
    # No hypridle/hyprlock: idle + lock are handled by the qylock module
    # (052-greeter-qylock) and Noctalia. See keybinds.lua CTRL+ALT+L.
    #
    # No hyprpolkitagent: Noctalia ships a built-in authentication agent
    # (compiled into noctalia-qs, not the QML tree). It is off by default —
    # enable it under Settings → Security → "Polkit Agent", which writes the
    # toggle into ~/.local/state/noctalia/settings.toml. Note it needs logind or
    # elogind; on a seatd-only setup it cannot register graphical prompts.
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
    # SUPER+F4 cursor cycle (see .config/hypr/conf/themes.lua).
    bibata-cursor-git
    nordzy-cursors
    nordzy-hyprcursors
    rose-pine-hyprcursor
    sweet-cursors-hyprcursor-git
    apple_hyprcursor
)

remove_pkgs=(
    hyprland
    hyprpaper
    hypr-zoom
    win11-icon-theme-git
    bibata-cursor-git
    nordzy-cursors
    nordzy-hyprcursors
    rose-pine-hyprcursor
    sweet-cursors-hyprcursor-git
    apple_hyprcursor
)

links=(
    .config/hypr
    .config/mpv
    # SUPER+F6 desktop profile switch, called from .config/hypr/conf/vanity.lua
    .local/bin/desktop-profile
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    ln -sf "$dotfiles_dir/assets/avatar.jpg" ~/.face
    safe_symlink .config/gtk-3.0/gtk.css
    # gtk.css imports the desktop profile's GTK overrides (desktop-profile,
    # SUPER+F6); start on normal so the import resolves before the first switch.
    [ -e ~/.config/gtk-3.0/profile.css ] ||
        ln -s "$dotfiles_dir/.config/gtk-3.0/profiles/normal.css" ~/.config/gtk-3.0/profile.css

    # Keep paru's status: fc-cache always succeeds, so letting it be the last
    # command would hide a failed cursor-theme install until `status` runs.
    local rc=0
    paru_install "${_pkgs_theme[@]}" || rc=$?
    fc-cache -v
    return "$rc"
}

mod_check() {
    paru_check "${_pkgs_theme[@]}" &&
        [ -L ~/.config/gtk-3.0/gtk.css ]
}

mod_post_uninstall() {
    rm -rf ~/.config/hypr ~/.config/mpv
}
