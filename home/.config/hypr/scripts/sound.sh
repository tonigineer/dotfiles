#!/usr/bin/env bash

is_muted() {
	# https://wiki.archlinux.org/title/PipeWire#Audio
	pactl get-sink-mute @DEFAULT_SINK@ | grep "Mute: " | cut -d " " -f 2
}

show_volume_bar() {
	if pgrep -x "eww" >/dev/null; then
		~/.config/eww/scripts/notify.sh --volume-bar
	fi
}

volume() {
	pactl get-sink-volume @DEFAULT_SINK@ | grep -o -P '[0-9]*(\.[0-9]*)?(?=%)' | head -1
}

up() {
	pactl set-sink-volume @DEFAULT_SINK@ +2%
}

down() {
	pactl set-sink-volume @DEFAULT_SINK@ -2%
}

mute_toggle() {
	pactl set-sink-mute @DEFAULT_SINK@ toggle
}

case $1 in
--gui | -g)
	pavucontrol
	;;
--volume | -v)
	volume
	;;
--is-muted | -im)
	is_muted
	;;
--up | -u)
	up
	show_volume_bar
	;;
--down | -d)
	down
	show_volume_bar
	;;
--mute | -m)
	mute_toggle
	show_volume_bar
	;;
*)
	echo "Usage:
    $0 {--gui|--volume|--is-muted|--up|--down|--mute}
    $0 {-g|-v|-im|-u|-d|-m}"
	exit 1
	;;
esac
