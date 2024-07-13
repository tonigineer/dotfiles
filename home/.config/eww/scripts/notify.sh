#!/usr/bin/env bash

# Script that contains the wrapper for all notification
# applications, configured.
#
# 	Examples:
#		notify.sh --volume
# 			Evokes the wrapper to `eww open notify-volume`
#

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

	eww open "$EWW_WINDOW_NAME"
	date +%s >/tmp/timeout_eww_volume

	while "true"; do
		if [ $(expr $(date +%s) - 2) -gt $(</tmp/timeout_eww_volume) ]; then
			eww close "$EWW_WINDOW_NAME"
			exit 0
		fi

		sleep 0.1
	done
}

case $1 in
--volume-bar | -vb)
	show_volume_bar
	;;
*)
	echo "USAGE:
	- notify.sh --volume		show $(eww open notify-volume) for a limited time"
	;;
esac
