#!/usr/bin/env bash

BATTERY_NAME="BAT0"

SOC_ICONS=(󰂃 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰁹)
CHARGE_ICON="󰂄"
FULL_ICON="󱟢"
POWERED_ICON="󰚥"

has_battery() {
    [[ -d "/sys/class/power_supply/$BATTERY_NAME" ]]
}

battery_state() {
    cat "/sys/class/power_supply/$BATTERY_NAME/status"
}

battery_soc() {
    cat "/sys/class/power_supply/$BATTERY_NAME/capacity"
}

battery_icon() {
    if ! has_battery; then
        echo "$POWERED_ICON"
        return
    fi

    local state
    state=$(battery_state)

    case "$state" in
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
            ((idx > 9)) && idx=9
            echo "${SOC_ICONS[idx]}"
            ;;
    esac
}

case "$1" in
    --icon | -i)
        battery_icon
        ;;
    --value | -v)
        if has_battery; then
            echo "$(battery_soc)%"
        else
            echo ""
        fi
        ;;
    *)
        echo "Usage:
    $0 {-i|--icon}   # Show battery icon
    $0 {-v|--value}  # Show battery percentage"
        exit 1
        ;;
esac
