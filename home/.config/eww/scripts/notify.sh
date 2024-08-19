#!/usr/bin/env bash

# Script that contains the wrapper for all notification
# applications, configured.
#
# 	Examples:
#		notify.sh --volume
# 			Evokes the wrapper to `eww open notify-volume`
#
active_screen=$(~/.config/hypr/scripts/monitor.sh -m $(~/.config/hypr/scripts/monitor.sh -A))

function show_volume_bar() {
	# This is a wrapper script for the volume window.
	# Its main purpose is to automatically close the
	# window after a certain duration. The duration
	# restarts whenever a volume change is commanded.
	EWW_WINDOW_NAME=notify-volume

	if eww active-windows | grep -q "$EWW_WINDOW_NAME"; then
		date +%s >/tmp/timeout_eww_volume
		exit 0
	fi
	echo $active_screen
	eww open "$EWW_WINDOW_NAME" --screen "$active_screen"
	date +%s >/tmp/timeout_eww_volume

	while "true"; do
		if [ $(expr $(date +%s) - 2) -gt $(</tmp/timeout_eww_volume) ]; then
			eww close "$EWW_WINDOW_NAME"
			exit 0
		fi

		sleep 0.1
	done
}

function show_brightness_indicator() {
	# This is a wrapper script for the volume window.
	# Its main purpose is to automatically close the
	# window after a certain duration. The duration
	# restarts whenever a volume change is commanded.
	EWW_WINDOW_NAME=notify-brightness

	if eww active-windows | grep -q "$EWW_WINDOW_NAME"; then
		date +%s >/tmp/timeout_eww_brightness
		exit 0
	fi

	eww open "$EWW_WINDOW_NAME" --screen $active_screen
	date +%s >/tmp/timeout_eww_brightness

	while "true"; do
		if [ $(expr $(date +%s) - 2) -gt $(</tmp/timeout_eww_brightness) ]; then
			eww close "$EWW_WINDOW_NAME"
			exit 0
		fi

		sleep 0.1
	done
}

case $1 in
--volume | -v)
	show_volume_bar
	sleep 0.15
	;;
--brightness | -b)
	show_brightness_indicator
	sleep 0.15
	;;
*)
	echo "USAGE:
	- notify.sh --volume		show $(eww open notify-volume) for a limited time
	- notify.sh --brightness	show $(eww open notify-volume) for a limited time"
	;;
esac
