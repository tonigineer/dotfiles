#!/usr/bin/env bash
#
# Dotfiles installer.
#
#   install.sh                  interactive fzf menu (toggle install/uninstall)
#   install.sh <name>...        install the named module(s), non-interactively
#   install.sh --all            install every module, in order
#   install.sh --uninstall <name>...   uninstall the named module(s)
#   install.sh --status <name>  exit 0 if <name> is installed, else 1
#
# <name> matches a module by filename, basename, or label (e.g. 002-bash.sh,
# 002-bash, bash, or Bash).
#
set -uo pipefail

script_dir="$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC2034  # re-derived in common.sh; kept here for parity
dotfiles_dir="$(realpath -e -- "$(dirname -- "$script_dir")")"

# shellcheck source=common.sh
source "$script_dir/common.sh"
# shellcheck source=lib/engine.sh
source "$script_dir/lib/engine.sh"

modules_dir="$script_dir/installations"

# ── Module resolution ───────────────────────────────────────────────────

# Resolve a user-supplied name to a module file path (prints it), else fail.
resolve_module() {
    local arg="$1" file base
    for file in "$modules_dir"/*.sh; do
        [ -f "$file" ] || continue
        base="$(basename -- "$file")"
        if [ "$arg" = "$base" ] ||
            [ "$arg" = "${base%.sh}" ] ||
            [ "$arg" = "$(to_label "$file")" ]; then
            printf '%s\n' "$file"
            return 0
        fi
    done
    return 1
}

# ── Interactive menu ────────────────────────────────────────────────────

install_list() {
    local file
    for file in "$modules_dir"/*.sh; do
        [ -f "$file" ] || continue

        # RAW_STATE \t RAW_FILE \t FZF_STRING
        if run_module "$file" status >/dev/null 2>&1; then
            printf 'ok\t%s\t%s %s\n' "$file" "$OK" "$(to_label "$file")"
        else
            printf 'no\t%s\t%s %s\n' "$file" "$NO" "$(to_label "$file")"
        fi
    done
}

selection_menu() {
    local selection state file
    selection="$(
        install_list | fzf --ansi --delimiter=$'\t' --with-nth=3 --no-sort --prompt='Tool> '
    )" || exit 1

    state="$(printf '%s' "$selection" | cut -f1)"
    file="$(printf '%s' "$selection" | cut -f2)"

    case "$state" in
    ok)
        printf 'Remove installation: %s\n' "$RED$(to_label "$file")$RESET"
        pause_any
        run_module "$file" uninstall
        ;;
    no)
        printf 'Continue with installation: %s\n' "$GREEN$(to_label "$file")$RESET"
        pause_any
        run_module "$file" install
        ;;
    *) echo "unknown state: $state" ;;
    esac
}

# ── Non-interactive actions ─────────────────────────────────────────────

# Resolve each name, run an action, keep going on failure, return worst rc.
batch() {
    local action="$1" rc=0 name file
    shift
    for name in "$@"; do
        if ! file="$(resolve_module "$name")"; then
            printf '%sunknown module: %s%s\n' "$RED" "$name" "$RESET" >&2
            rc=1
            continue
        fi
        printf '\n%s %s\n' "$action" "$(to_label "$file")"
        run_module "$file" "$action" || rc=1
    done
    return "$rc"
}

install_all() {
    local rc=0 file
    for file in "$modules_dir"/*.sh; do
        [ -f "$file" ] || continue
        printf '\n=== %s ===\n' "$(to_label "$file")"
        if run_module "$file" status >/dev/null 2>&1; then
            printf 'already installed, skipping\n'
            continue
        fi
        run_module "$file" install || rc=1
    done
    return "$rc"
}

# ── Entry point ─────────────────────────────────────────────────────────

main() {
    bootstrap_yay

    if [ "$#" -eq 0 ]; then
        while true; do
            selection_menu
        done
    fi

    # Non-interactive: never block on prompts.
    pause_any() { :; }

    case "$1" in
    --all) install_all ;;
    --status)
        [ "$#" -ge 2 ] || { echo "usage: install.sh --status <name>" >&2; exit 2; }
        local file
        file="$(resolve_module "$2")" || { echo "unknown module: $2" >&2; exit 2; }
        run_module "$file" status
        ;;
    --uninstall)
        shift
        batch uninstall "$@"
        ;;
    -*)
        echo "unknown option: $1" >&2
        exit 2
        ;;
    *)
        batch install "$@"
        ;;
    esac
}

main "$@"
