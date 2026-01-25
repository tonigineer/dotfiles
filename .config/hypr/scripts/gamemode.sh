#!/usr/bin/env bash

readonly CFG_FILE=~/.config/noctalia/settings.json

tmp="$(mktemp)"
trap '$tmp' EXIT

if [ "$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')" = 1 ]; then
    jq --indent 4 '.general.animationDisabled = true' "$CFG_FILE" >"$tmp" &&
        mv -- "$tmp" "$CFG_FILE"

    hyprctl --batch "\
        keyword animations:enabled 0; \
        keyword animation borderangle,0; \
        keyword decoration:shadow:enabled 0; \
        keyword decoration:blur:enabled 0; \
	keyword decoration:fullscreen_opacity 1; \
        keyword general:gaps_in 0; \
        keyword general:gaps_out 0; \
        keyword general:border_size 0; \
        keyword decoration:rounding 0"

    notify-send "Gamemode ON" "All animations and some vanity settings are disabled." --icon ~/.config/hypr/scripts/assets/gamemode-on.svg --app-name="Hyprland"

    exit 0
else
    jq --indent 4 '.general.animationDisabled = false' "$CFG_FILE" >"$tmp" &&
        mv -- "$tmp" "$CFG_FILE"

    hyprctl reload
    notify-send "Gamemode Off" "Default configuration is restored." --icon ~/.config/hypr/scripts/assets/gamemode-off.svg --app-name="Hyprland"

    exit 0
fi
