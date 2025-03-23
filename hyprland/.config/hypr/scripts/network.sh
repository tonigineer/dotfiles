#!/usr/bin/env bash

function get_network_adapter() {
    echo $(ip route | grep default | awk '{print $5}' | head -n 1)
}

function determine_network_icon() {
    # NOTE: Ethernet adapter is only confirmed via grep with `en`
    get_network_adapter | grep -q 'en' && echo "󰈀 " && exit 0

    wireless_status="$(nmcli general status | grep -oh "\w*connect\w*")"
    [ "$wireless_status" == "disconnected" ] && echo "󰤮 " && exit 0
    [ "$wireless_status" == "connecting" ] && echo "󱍸 " && exit 0

    signal_strength=$(awk 'NR==3 {print $3 "00 %"}''' /proc/net/wireless | cut -d '.' -f1)
    SIGNAL_ICONS=("󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 ")
    icon_index=$(((signal_strength + 14) / 15))

    echo "${SIGNAL_ICONS[icon_index]}"
}

function count_transmitting_bytes {
    tx_start=$(cat /sys/class/net/$1/statistics/tx_bytes)
    sleep $2
    tx_end=$(cat /sys/class/net/$1/statistics/tx_bytes)
    echo $(expr $(expr $tx_end - $tx_start))
}

function count_receiving_bytes {
    rx_start=$(cat /sys/class/net/$1/statistics/rx_bytes)
    sleep $2
    rx_end=$(cat /sys/class/net/$1/statistics/rx_bytes)
    echo $(expr $(expr $rx_end - $rx_start))
}

duration="$2"
[[ -z "$2" ]] && duration="1"

adapter=$3
[[ -z $3 ]] && adapter=$(get_network_adapter)

case $1 in
--transmitting | -tx)
    count_transmitting_bytes $adapter $duration
    ;;
--receiving | -rx)
    count_receiving_bytes $adapter $duration
    ;;
--icon | -i)
    determine_network_icon
    ;;
--adapter | -a)
    name=$(get_network_adapter)
    echo "${name:0:5}"
    ;;
*)
    echo "Usage:
    $0 {-i|-a|-tx|-rx}
    $0 {-icon|-adapter|-transmitting|-receiving}"
    exit 1
    ;;
esac
