#!/usr/bin/env bash

readonly HYPR_CONFIG_FILE=~/.config/hypr/conf.d/init/config.conf

config_path="$(qs list --all 2>/dev/null | awk -F': ' '/^  Config path:/{print $2; exit}')"
config="$(basename "$(dirname "$config_path")")"

case "$config" in
caelestia)
	killall -9 qs

	sed -i -E '/^[[:space:]]*\$HYPR_NOCTALIA[[:space:]]*=.*/c\$HYPR_NOCTALIA = 1' "$HYPR_CONFIG_FILE"
	sed -i -E '/^[[:space:]]*\$HYPR_CAELESTIA[[:space:]]*=.*/c\$HYPR_CAELESTIA =' "$HYPR_CONFIG_FILE"
	hyprctl reload  # redundant, but sometimes string manip does not lead to reload

	qs -c noctalia
	;;
noctalia)
	killall -9 qs

	sed -i -E '/^[[:space:]]*\$HYPR_NOCTALIA[[:space:]]*=.*/c\$HYPR_NOCTALIA =' "$HYPR_CONFIG_FILE"
	sed -i -E '/^[[:space:]]*\$HYPR_CAELESTIA[[:space:]]*=.*/c\$HYPR_CAELESTIA = 1' "$HYPR_CONFIG_FILE"
	hyprctl reload  # redundant, but sometimes string manip does not lead to reload

	qs -c caelestia

	# Workaround: Sometime the wallpaper is not loaded.
	pause 0.25
	# caelestia wallpaper -h
	# caelestia wallpaper -r ~/Wallpaper
	# caelestia scheme set -n dynamic
	#
	# Note: Replace symlink path with folder in home
	caelestia wallpaper -f ~/Wallpaper/$(basename -- "$(caelestia wallpaper)")
	;;
*)
	notify-sent "Unknown shell" "Current quickshell config $($config_path) is not implemented."
	exit 2
	;;
esac
