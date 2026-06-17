#!/usr/bin/env bash
#
# Shared helpers for install.sh and the module engine. Sourced, not executed.

script_dir="$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")")"
dotfiles_dir="$(realpath -e -- "$(dirname -- "$script_dir")")"

# ── Colors & symbols ────────────────────────────────────────────────────

GREEN=$'\033[32m'
RED=$'\033[31m'
RESET=$'\033[0m'

export OK="${GREEN}✓${RESET}"
export NO="${RED}✗${RESET}"

# ── Prompts ─────────────────────────────────────────────────────────────

pause_any() {
    read -rsn1 -p "Press any key to continue …"
    echo
}

# ── Labels ──────────────────────────────────────────────────────────────

# Human label for a module file, e.g. "002-bash.sh" -> "002-bash".
to_label() {
    local base
    base="$(basename -- "$1")"
    base="${base%.*}"
    printf '%s\n' "${base^}"
}

# ── Packages (yay) ──────────────────────────────────────────────────────

yay_check() {
    yay -Q "$@" &>/dev/null
}

yay_install() {
    yay -S "$@" --noconfirm
    pause_any
}

yay_uninstall() {
    yay -Rns "$@" --noconfirm
    pause_any
}

# ── Symlinks ────────────────────────────────────────────────────────────

# Link $dotfiles_dir/<rel> -> $HOME/<rel>, backing up any existing target to
# .bak. Idempotent: a correct existing link is left untouched.
safe_symlink() {
    local source_path="$dotfiles_dir/$1" target_path="$HOME/$1"

    if [ -L "$target_path" ]; then
        local current_path target_abs src_abs
        current_path="$(readlink -- "$target_path")"
        target_abs="$(realpath -m -- "$current_path" 2>/dev/null || echo "$current_path")"
        src_abs="$(realpath -m -- "$source_path" 2>/dev/null || echo "$source_path")"

        if [ "$target_abs" = "$src_abs" ]; then
            echo "OK: $target_path already links to $source_path"
            return 0
        fi
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        mv -v -- "$target_path" "${target_path}.bak"
    fi

    mkdir -p -- "$(dirname -- "$target_path")"
    ln -s -- "$source_path" "$target_path"
    echo "Linked: $target_path -> $source_path"
}

# Reverse safe_symlink: drop the symlink and restore a .bak if one exists.
unlink_dotfile() {
    local target_path="$HOME/$1"

    [ -L "$target_path" ] && rm -- "$target_path"
    [ -e "${target_path}.bak" ] && mv -v -- "${target_path}.bak" "$target_path"

    return 0
}

# ── Bootstrap ───────────────────────────────────────────────────────────

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
