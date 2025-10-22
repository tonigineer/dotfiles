#!/usr/bin/env bash

readonly HYPR_CONFIG_FILE=~/.config/hypr/conf.d/init/config.conf

config_path="$(qs list --all 2>/dev/null | awk -F': ' '/^  Config path:/{print $2; exit}')"
config="$(basename "$(dirname "$config_path")")"

case "$config" in
caelestia)
    killall -9 qs
    sed -i 's/$HYPR_NOCTALIA =/$HYPR_NOCTALIA = 1/' "$HYPR_CONFIG_FILE"
    sed -i 's/$HYPR_CAELESTIA = 1/$HYPR_CAELESTIA =/' "$HYPR_CONFIG_FILE"
    qs -c noctalia
    ;;
noctalia)
    killall -9 qs
    sed -i 's/$HYPR_NOCTALIA = 1/$HYPR_NOCTALIA =/' "$HYPR_CONFIG_FILE"
    sed -i 's/$HYPR_CAELESTIA =/$HYPR_CAELESTIA = 1/' "$HYPR_CONFIG_FILE"
    qs -c caelestia
    ;;
*)
    notify-sent "Unknown shell" "Current quickshell config $($config_path) is not implemented."
    exit 2
    ;;
esac

hyprctl reload
