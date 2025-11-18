#!/usr/bin/env bash

script_dir="$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")")"
dotfiles_dir="$(realpath -e -- "$(dirname -- "$script_dir")")"

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'

export OK="${GREEN}✓${RESET}"
export NO="${RED}✗${RESET}"

pause_any() {
    read -rsn1 -p "Press any key to continue …"
    echo
}

to_label() {
    local path="$1"
    local base
    base="$(basename -- "$path")"
    base="${base%.*}"
    printf '%s\n' "${base^}"
}

dynamic_source() {
    [ -r "$1" ] || return
    # shellcheck disable=SC1090,SC1091
    . "$1"
}

bootstrap_yay() {
    if command -v yay >/dev/null 2>&1; then
        echo "yay is already installed."
        return 0
    fi

    sudo pacman -S --needed --noconfirm base-devel git fzf

    local tmp
    tmp="$(mktemp -d)"

    (
        trap 'rm -rf "$tmp"' EXIT

        git clone https://aur.archlinux.org/yay.git "$tmp/yay"
        pushd "$tmp/yay" >/dev/null || exit
        makepkg -si --noconfirm
        popd >/dev/null || exit
    )

    echo "yay installed successfully."
}

safe_symlink() {
    local source_path="$dotfiles_dir/$1" target_path="$HOME/$1"

    if [ -L "$target_path" ]; then
        current_path="$(readlink -- "$target_path")"

        target_abs="$(realpath -m -- "$current_path" 2>/dev/null || echo "$current_path")"
        src_abs="$(realpath -m -- "$source_path" 2>/dev/null || echo "$source_path")"

        if [ "$target_abs" = "$src_abs" ]; then
            echo "OK: $target_path already links to $source_path"
            return 0
        fi
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        local backup
        backup="${target_path}.bak"

        mv -v -- "$target_path" "$backup"
    fi

    ln -s -- "$source_path" "$target_path"
    echo "Linked: $target_path -> $source_path"

}

yay_check() {
    local pkgs=("$@")
    yay -Q "${pkgs[@]}" &>/dev/null
}

yay_install() {
    local pkgs=("$@")
    yay -S "${pkgs[@]}" --noconfirm

    pause_any
}

yay_uninstall() {
    local pkgs=("$@")
    yay -Rns "${pkgs[@]}" --noconfirm

    pause_any
}
