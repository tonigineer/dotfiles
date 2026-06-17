#!/usr/bin/env bash
#
# Declarative module engine.
#
# A module (installations/NNN-name.sh) is pure data plus optional hooks — it
# contains NO top-level logic, only these assignments/functions (all optional):
#
#   pkgs=( foo bar )                 # packages to install with yay
#   remove_pkgs=( foo )              # packages to remove on uninstall
#   links=( .bashrc .config/kitty )  # symlink $dotfiles_dir/X -> $HOME/X
#
#   mod_pre_install()    { … }       # runs BEFORE packages (e.g. clear conflicts)
#   mod_post_install()   { … }       # runs AFTER packages+links
#   mod_check()          { … }       # extra status assertions (return 0 = ok)
#   mod_pre_uninstall()  { … }       # runs before links/pkgs are removed
#   mod_post_uninstall() { … }       # runs after links/pkgs are removed
#
# The engine derives install / status / uninstall from the above. Anything that
# doesn't fit "install these packages, link these files" lives in a hook.
#
# Requires common.sh (yay_*, safe_symlink, unlink_dotfile) to be sourced first.

# ── Actions ─────────────────────────────────────────────────────────────

# install = pre hook, packages, links, post hook. Failures in any step
# propagate (so the caller sees a non-zero rc).
engine_install() {
    declare -F mod_pre_install >/dev/null && { mod_pre_install || return 1; }

    if [ "${#pkgs[@]}" -gt 0 ]; then
        yay_install "${pkgs[@]}" || return 1
    fi

    local rel
    for rel in "${links[@]}"; do
        safe_symlink "$rel" || return 1
    done

    if declare -F mod_post_install >/dev/null; then
        mod_post_install
        return $?
    fi

    return 0
}

# status = all packages present AND all links live AND mod_check (if any).
engine_status() {
    if [ "${#pkgs[@]}" -gt 0 ]; then
        yay_check "${pkgs[@]}" || return 1
    fi

    local rel
    for rel in "${links[@]}"; do
        [ -L "$HOME/$rel" ] && [ -e "$HOME/$rel" ] || return 1
    done

    if declare -F mod_check >/dev/null; then
        mod_check || return 1
    fi

    return 0
}

# uninstall = pre hook, drop links, remove packages, post hook. Best-effort:
# one failing step shouldn't stop the rest, so this always returns 0.
engine_uninstall() {
    declare -F mod_pre_uninstall >/dev/null && { mod_pre_uninstall || true; }

    local rel
    for rel in "${links[@]}"; do
        unlink_dotfile "$rel"
    done

    if [ "${#remove_pkgs[@]}" -gt 0 ]; then
        yay_uninstall "${remove_pkgs[@]}" || true
    fi

    declare -F mod_post_uninstall >/dev/null && { mod_post_uninstall || true; }

    return 0
}

# ── Dispatch ────────────────────────────────────────────────────────────

# Run one action against a module file in an ISOLATED subshell, so its data and
# hooks never leak into the engine or into other modules.
#   run_module <file> install|status|uninstall
run_module() {
    local file="$1" action="$2"
    (
        pkgs=()
        remove_pkgs=()
        links=()
        # shellcheck disable=SC1090
        . "$file"

        case "$action" in
        install) engine_install ;;
        status) engine_status ;;
        uninstall) engine_uninstall ;;
        *)
            echo "unknown action: $action" >&2
            exit 2
            ;;
        esac
    )
}
