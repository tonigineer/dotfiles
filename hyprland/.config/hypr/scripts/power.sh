#!/usr/bin/env bash

BATTERY_NAME="BAT0"

SOC_ICONS=(󰂃 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰁹)
CHARGE_ICON="󰂄"
FULL_ICON="󱟢"
POWERED_ICON="󰚥"

# Check if battery directory exists
has_battery() {
    [[ -d "/sys/class/power_supply/$BATTERY_NAME" ]]
}

# Get battery state
battery_state() {
    <"/sys/class/power_supply/$BATTERY_NAME/status"
}

# Get battery percentage
battery_soc() {
    <"/sys/class/power_supply/$BATTERY_NAME/capacity"
}

# Get battery icon based on charge state
battery_icon() {
    if ! has_battery; then
        echo "$POWERED_ICON"
        return
    fi

    case "$(battery_state)" in
    "Charging")
        echo "$CHARGE_ICON"
        ;;
    "Full")
        echo "$FULL_ICON"
        ;;
    *)
        local soc
        soc=$(battery_soc)
        local idx=$((soc / 10))
        echo "${SOC_ICONS[idx]}"
        ;;
    esac
}

case "$1" in
--icon | -i)
    battery_icon
    ;;
--value | -v)
    if ! has_battery; then
        echo ""
    else
        echo "$(battery_soc)%"
    fi
    ;;
*)
    echo "Usage:
    $0 {-i|--icon}
    $0 {-v|--value}"
    exit 1
    ;;
esac
