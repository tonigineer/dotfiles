#!/usr/bin/env bash

info=$(hyprctl monitors -j | jq -r 'sort_by(.x)')

function left_order_index() {
    # Return to index of the monitor from left to right
    echo "$info" | jq --argjson ID $1 ' [.[].id] | index($ID)'
}

function number_monitors() {
    echo "$info" | jq length
}

function get_refresh_rate() {
    echo "$info" | jq --argjson ID $1 '.[] | select(.id == $ID).refreshRate'
}

function get_resolution() {
    width=$(echo "$info" | jq --argjson ID $1 '.[] | select(.id == $ID).width')
    height=$(echo "$info" | jq --argjson ID $1 '.[] | select(.id == $ID).height')
    echo ${width}x${height}
}

function get_name() {
    # Return name of monitor such as `DP-1`
    echo "$info" | jq --argjson ID $1 '.[] | select(.id == $ID).name'
}

function get_model() {
    # Return model name of monitor as in the product name
    echo "$info" | jq --argjson ID $1 '.[] | select(.id == $ID).model'
}

function is_enabled() {
    case $(echo "$info" | jq --argjson ID $1 '.[] | select(.id == $ID).disabled') in
    false)
        echo 1
        ;;
    true)
        echo 0
        ;;
    esac
}

function active_monitor() {
    # Get ID of monitor with active window
    hyprctl activewindow | grep monitor: | cut -d" " -f 2 | head -n 1
}

case $1 in
--number | -n)
    number_monitors
    ;;
--active | -A)
    active_monitor $2
    ;;
--is_enabeld | -a)
    is_enabled $2
    ;;
--refresh | -r)
    get_refresh_rate $2
    ;;
--resolution | -R)
    get_resolution $2
    ;;
--model | -m)
    get_model $2
    ;;
--name | -N)
    get_name $2
    ;;
--order-index | -i)
    left_order_index $2
    ;;
*)
    echo "Usage: monitor.sh [options] <MONITOR-ID>

Helper script for monitor control.

Options:
  -n, --number              output number of connected monitors
  -N, --name <ID>           get name of monitor (e.g., DP-1)
  -a, --is_enabled <ID>     if monitor is enabled (1)
  -A, --active              get ID of monitor with active workspace (hyprctl activeworkspace)
  -r, --refresh <ID>        get refreshrate of monitor
  -R, --resolution <ID>     get resolution of monitor
  -m, --model <ID>          get model name of monitor (product name)
  -i, --order-index <ID>    get index of left to right order (base on x position)

  -h, --help            display help for command"
    ;;
esac
