#!/usr/bin/env bash

BATTERY_NAME="BAT0"

SOC_ICONS=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹")
CHARGE_ICON="󰂄"
FULL_ICON="󱟢"
POWERED_ICON="󰚥"

function has_battery() {
	if [ -d "/sys/class/power_supply/$BATTERY_NAME" ]; then
		echo true
	else
		echo false
	fi
}

function battery_state() {
	echo $(cat /sys/class/power_supply/$BATTERY_NAME/status)
}

function battery_soc() {
	echo $(cat /sys/class/power_supply/$BATTERY_NAME/capacity)
}

function battery_icon() {
	if ! $(has_battery); then
		echo $POWERED_ICON
		exit 0
	fi

	case $(battery_state) in
	"Charging")
		echo $CHARGE_ICON
		;;
	"Full")
		echo $FULL_ICON
		;;
	*)
		soc=$(battery_soc)
		idx=$((soc / 10))
		echo ${SOC_ICONS[idx]}
		;;
	esac
}

case $1 in
--icon | -i)
	battery_icon
	;;
--value | -v)
	if ! $(has_battery); then
		echo 100
		exit 0
	fi
	battery_soc
	;;
*)
	echo "Usage:
    $0 {-i|-v}
    $0 {--icon|--value}"
	exit 1
	;;
esac
