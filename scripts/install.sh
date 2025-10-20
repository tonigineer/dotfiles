#!/usr/bin/env bash
set -euo pipefail

script_dir="$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")")"
dotfiles_dir="$(realpath -e -- "$(dirname -- "$script_dir")")"

source "$script_dir/common.sh"

install_list() {
    for file in "$script_dir"/installations/*; do
        [ -f "$file" ] || continue

        dynamic_source "$file"

        # RAW_STATE \t RAW_FILE \t FZF_STRING
        if status; then
            printf 'ok\t%s\t%s %s\n' "$file" "$OK" "$(to_label "$file")"
        else
            printf 'no\t%s\t%s %s\n' "$file" "$NO" "$(to_label "$file")"
        fi
    done
}

selection_menu() {
    selection="$(
        install_list | fzf --ansi --delimiter=$'\t' --with-nth=3 --no-sort --prompt='Tool> '
    )" || exit 1

    local state
    local file

    state="$(printf '%s' "$selection" | cut -f1)"
    file="$(printf '%s' "$selection" | cut -f2)"

    dynamic_source "$file"

    case "$state" in
    ok)
        printf 'Remove installation: %s\n' "$RED$(to_label "$file")$RESET"
        pause_any
        uninstall
        ;;
    no)
        printf 'Continue with installation: %s\n' "$GREEN$(to_label "$file")$RESET"
        pause_any
        install
        ;;
    *) echo "unknown state: $state" ;;
    esac
}

main() {
    bootstrap_yay

    while true; do
        selection_menu
    done
}

main "$@"
