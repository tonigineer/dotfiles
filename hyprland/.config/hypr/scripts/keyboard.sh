#!/usr/bin/env bash

KEYBOARD_ICON=""

get_layout() {
    local line
    line=$(grep '=' /etc/vconsole.conf | head -n1) || return 1
    echo "${line#*=}" | xargs
}

case "$1" in
--icon | -i)
    echo "$KEYBOARD_ICON"
    ;;
--layout | -l)
    get_layout
    ;;
*)
    echo "Usage:
    $0 {-i|--icon}
    $0 {-l|--layout}"
    exit 1
    ;;
esac
