#!/usr/bin/env bash

show_brightness_indicator() {
	if pgrep -x "eww" >/dev/null; then
		~/.config/eww/scripts/notify.sh --brightness
	fi
}

brightness() {
	brightnessctl | grep Current | cut -d" " -f3
}

up() {
	brightnessctl set 10%+ -e 2.5
}

down() {
	brightnessctl set 10%- -e 2.5
}

case $1 in
--brightness | -b)
	brightness
	;;
--up | -u)
	up
	sleep 0.25
	show_brightness_indicator
	;;
--down | -d)
	down
	sleep 0.25
	show_brightness_indicator
	;;
*)
	echo "Usage:
    $0 {--brightness|--up|--down}
    $0 {-b|-u|-d}"
	exit 1
	;;
esac
