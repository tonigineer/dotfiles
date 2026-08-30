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

# ── Retry ───────────────────────────────────────────────────────────────

# Fetching from aur.archlinux.org drops connections intermittently ("OpenSSL
# SSL_read: … unexpected eof while reading", git "exit status 128"), which
# fails an install for a reason that has nothing to do with it. Wrap those
# calls so a dropped connection costs a retry instead of the whole run.
aur_retries=${aur_retries:-3}
aur_retry_delay=${aur_retry_delay:-5}

# retry <cmd> [args…] — rerun until it succeeds or the attempts run out,
# keeping the last exit status. Only for idempotent commands.
retry() {
    local rc=0 attempt=1

    while :; do
        rc=0
        "$@" || rc=$?
        [ "$rc" -eq 0 ] && break
        [ "$attempt" -ge "$aur_retries" ] && break

        echo "${1} failed (rc=$rc); retrying in ${aur_retry_delay}s (attempt $((attempt + 1))/$aur_retries)…" >&2
        sleep "$aur_retry_delay"
        attempt=$((attempt + 1))
    done

    return "$rc"
}

# ── Packages (yay) ──────────────────────────────────────────────────────

yay_check() {
    yay -Q "$@" &>/dev/null
}

# Both keep yay's exit status: `pause_any` is only a prompt, so letting it be
# the last command would make every install/uninstall look successful and
# `engine_install`'s `|| return 1` unreachable.

# The sync is retried: `yay -S` is idempotent, so a PKGBUILD clone that got
# dropped mid-run costs a retry rather than the whole module.
yay_install() {
    local rc=0
    retry yay -S "$@" --noconfirm || rc=$?
    pause_any
    return "$rc"
}

yay_uninstall() {
    local rc=0
    yay -Rns "$@" --noconfirm || rc=$?
    pause_any
    return "$rc"
}

# ── Symlinks ────────────────────────────────────────────────────────────

# Link $dotfiles_dir/<rel> -> $HOME/<rel>, backing up any existing target to
# .bak. Idempotent: a correct existing link is left untouched.
# A second argument overrides the source, so a file can be linked under a
# different name than it carries in the repo (see safe_symlink_host).
safe_symlink() {
    local source_path="$dotfiles_dir/${2:-$1}" target_path="$HOME/$1"

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

# ── Per-host files ──────────────────────────────────────────────────────
#
# The machines sharing this repo differ in a few files (monitor layout, panel
# widgets, scaling). Those are stored side by side as <name>.<host>.<ext> with
# a <name>.default.<ext> for every machine that has no variant of its own, and
# linked to the plain <name>.<ext> the application expects.

# Name of this machine: $DOTFILES_HOST, else the static hostname, else default.
dotfiles_host() {
    local host="${DOTFILES_HOST:-}"
    [ -n "$host" ] || host="$(cat /etc/hostname 2>/dev/null)"
    printf '%s\n' "${host:-default}"
}

# Repo path of the variant that applies to this machine, or empty when the
# file has neither a host variant nor a default.
host_variant() {
    local rel="$1" base="${1%.*}" ext="${1##*.}" candidate
    for candidate in "$base.$(dotfiles_host).$ext" "$base.default.$ext"; do
        if [ -e "$dotfiles_dir/$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

# Link this machine's variant of <rel> to $HOME/<rel>.
safe_symlink_host() {
    local rel="$1" source_rel

    if ! source_rel="$(host_variant "$rel")"; then
        local base="${rel%.*}" ext="${rel##*.}"
        printf '%sno variant of %s for host %s%s\n' \
            "$RED" "$rel" "$(dotfiles_host)" "$RESET" >&2
        printf 'seed one from an existing machine, e.g.\n  cp %s %s\n' \
            "$dotfiles_dir/$base.<other-host>.$ext" \
            "$dotfiles_dir/$base.$(dotfiles_host).$ext" >&2
        return 1
    fi

    safe_symlink "$rel" "$source_rel"
}

# True when $HOME/<rel> links to the variant this machine should be using.
host_link_ok() {
    local rel="$1" source_rel
    source_rel="$(host_variant "$rel")" || return 1
    [ -L "$HOME/$rel" ] || return 1
    [ "$(realpath -m -- "$HOME/$rel")" = "$(realpath -m -- "$dotfiles_dir/$source_rel")" ]
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

        # Clear the target first: a clone killed mid-transfer can leave a
        # partial directory behind, and cloning into a non-empty path fails.
        # shellcheck disable=SC2329  # invoked indirectly, via `retry`
        clone_yay() {
            rm -rf -- "$tmp/yay" &&
                git clone https://aur.archlinux.org/yay.git "$tmp/yay"
        }

        retry clone_yay
        pushd "$tmp/yay" >/dev/null || exit
        makepkg -si --noconfirm
        popd >/dev/null || exit
    )

    echo "yay installed successfully."
}
