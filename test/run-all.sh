#!/usr/bin/env bash
#
# Drive the REAL installer (scripts/install.sh) once per module and report
# whether each executed correctly. Per module:
#
#   install:  install.sh <name>        must exit 0
#   status:   install.sh --status <name>   must exit 0  (the module's own
#                                            packages-present + links-live check)
#
# Each module is a fresh `install.sh` process, so there's no state bleed. The
# image shims host-only commands (systemctl/mkinitcpio/bootctl/grub/spicetify/
# xdg-settings); 001-pacman enables multilib and refreshes the db itself. The
# suite never aborts on a failure — it runs everything and prints a matrix.
#
set -uo pipefail

repo_root="$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
install_sh="$repo_root/scripts/install.sh"
modules_dir="$repo_root/scripts/installations"
log_dir="$(mktemp -d)"

names=()
declare -A INSTALL_RC STATUS_RC

printf '\033[1mDriving install.sh for every module (real installs, slow)…\033[0m\n'
for module in "$modules_dir"/*.sh; do
    name="$(basename "$module")"
    key="${name%.sh}"
    log="$log_dir/$name.log"

    {
        echo "===== install.sh $key ====="
        bash "$install_sh" "$key"
        echo "INSTALL_RC=$?"
        echo "===== install.sh --status $key ====="
        bash "$install_sh" --status "$key"
        echo "STATUS_RC=$?"
    } >"$log" 2>&1

    names+=("$name")
    INSTALL_RC[$name]="$(grep -oP 'INSTALL_RC=\K.*' "$log" | tail -1)"
    STATUS_RC[$name]="$(grep -oP 'STATUS_RC=\K.*' "$log" | tail -1)"
    printf '  %-26s install=%s status=%s\n' \
        "$name" "${INSTALL_RC[$name]:-?}" "${STATUS_RC[$name]:-?}"
done

# ── Report ──────────────────────────────────────────────────────────────
printf '\n\033[1m%-26s %-9s %-9s %s\033[0m\n' MODULE INSTALL STATUS RESULT
fails=0
for name in "${names[@]}"; do
    irc="${INSTALL_RC[$name]:-?}"
    src="${STATUS_RC[$name]:-?}"

    if [ "$irc" = 0 ] && [ "$src" = 0 ]; then
        result=PASS color=32
    else
        result=FAIL color=31
        fails=$((fails + 1))
    fi

    printf '%-26s %-9s %-9s \033[%sm%s\033[0m\n' \
        "$name" "rc=$irc" "rc=$src" "$color" "$result"
done

# Dump the logs of failed modules so the cause is visible without re-running.
if [ "$fails" -gt 0 ]; then
    for name in "${names[@]}"; do
        if [ "${INSTALL_RC[$name]:-1}" != 0 ] || [ "${STATUS_RC[$name]:-1}" != 0 ]; then
            printf '\n\033[1m----- %s -----\033[0m\n' "$name"
            tail -n 25 "$log_dir/$name.log"
        fi
    done
fi

printf '\nLogs: %s\n' "$log_dir"
if [ "$fails" -eq 0 ]; then
    printf '\033[32mAll %d modules executed correctly.\033[0m\n' "${#names[@]}"
    exit 0
else
    printf '\033[31m%d/%d module(s) did not execute correctly (see logs).\033[0m\n' \
        "$fails" "${#names[@]}"
    exit 1
fi
