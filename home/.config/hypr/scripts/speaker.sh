#!/usr/bin/env bash

SPEAKER_MAC="88:C6:26:C9:C2:65"

check_speaker_connection() {
    if bluetoothctl info "$SPEAKER_MAC" | grep -q "Connected: yes"; then
        echo true
    else
        echo false
    fi
}

connect_speaker() {
    alacritty --title "float" -e "bluetoothctl"
}

case "$1" in
--info | -i)
    check_speaker_connection
    ;;
--connect | -c)
    connect_speaker
    ;;
*)
    echo "Usage:
    $0 {--info|--connect}"
    exit 1
    ;;
esac
