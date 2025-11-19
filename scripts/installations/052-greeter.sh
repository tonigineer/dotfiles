#!/usr/bin/env bash

set -euo pipefail

readonly TMP="$(mktemp -d)"
readonly DATE=$(date +%s)

readonly THEME_REPO="https://github.com/Keyitdev/sddm-astronaut-theme.git"
readonly THEME_NAME="sddm-astronaut-theme"
readonly THEMES_DIR="/usr/share/sddm/themes"
readonly PATH_TO_GIT_CLONE="$TMP/$THEME_NAME"
readonly METADATA="$THEMES_DIR/$THEME_NAME/metadata.desktop"

pkgs=(
    sddm
    qt6-svg
    qt6-virtualkeyboard
    qt6-multimedia-ffmpeg
)

spin() {
    local title="$1"
    shift
    if command -v gum &>/dev/null; then
        gum spin --spinner="dot" --title="$title" -- "$@"
    else
        echo "$title"
        "$@"
    fi
}

preview_theme() {
    sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/ 2>/dev/null &
    greeter_pid=$!

    for _ in {1..3}; do
        if ! kill -0 "$greeter_pid" 2>/dev/null; then
            break
        fi
        sleep 1
    done

    if kill -0 "$greeter_pid" 2>/dev/null; then
        kill "$greeter_pid"
    fi
}

theme_install() {
    [[ -d "$PATH_TO_GIT_CLONE" ]] && mv "$PATH_TO_GIT_CLONE" "${PATH_TO_GIT_CLONE}_$DATE"
    spin "Cloning repository..." git clone -b master --depth 1 "$THEME_REPO" "$PATH_TO_GIT_CLONE"

    local source_dir="$HOME/$THEME_NAME"
    local target_dir="$THEMES_DIR/$THEME_NAME"

    [[ ! -d "$source_dir" ]] && {
        error "Clone repository first"
        return 1
    }

    # Backup and copy
    [[ -d "$target_dir" ]] && sudo mv "$target_dir" "${target_dir}_$DATE"
    sudo mkdir -p "$target_dir"
    spin "Copying files..." sudo cp -r "$source_dir"/* "$target_dir"/

    [[ -d "$target_dir/Fonts" ]] && spin "Installing fonts..." sudo cp -r "$target_dir/Fonts"/* /usr/share/fonts/

    # Configure SDDM
    echo "[Theme]
    Current=$THEME_NAME" | sudo tee /etc/sddm.conf >/dev/null

    sudo mkdir -p /etc/sddm.conf.d
    echo "[General]
    InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

    sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/pixel_sakura.conf|" "$METADATA"

    sudo systemctl disable display-manager.service 2>/dev/null || true
    sudo systemctl enable sddm.service
}

status() {
    yay_check "${pkgs[@]}" &&
        systemctl --quiet is-active sddm.service
}

install() {
    yay_install "${pkgs[@]}"

    theme_install
    preview_theme

    sudo mkdir -p /var/lib/sddm/.config/hypr
    sudo cp "$dotfiles_dir/.config/sddm/hyprland.conf" /var/lib/sddm/.config/hypr/hyprland.conf

}

uninstall() {
    sudo systemctl disable sddm.service

    readonly PGKS=(sddm)
    yay_uninstall "${PGKS[@]}"
}
