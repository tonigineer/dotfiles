#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 --title | --arturl | --artist | --length | --album | --source"
    exit 1
fi

get_metadata() {
    key=$1
    playerctl metadata --format "{{ $key }}" 2>/dev/null
}

get_source_info() {
    trackid=$(get_metadata "mpris:trackid")
    if [[ "$trackid" == *"firefox"* ]]; then
        echo -e "󰈹   Firefox"
    elif [[ "$trackid" == *"spotify"* ]]; then
        echo -e "   Spotify"
    else
        echo ""
    fi
}

# Parse the argument
case "$1" in
--title)
    title=$(get_metadata "xesam:title")
    if [ -z "$title" ]; then
        echo ""
    else
        echo "${title:0:50}"
    fi
    ;;
--arturl)
    url=$(get_metadata "mpris:artUrl")
    if [ -z "$url" ]; then
        echo ""
    else
        if [[ "$url" == file://* ]]; then
            url=${url#file://}
        elif [[ "$url" == https://* ]]; then
            wget -q -4 "$url" -O /tmp/cover.png
            mogrify -format png /tmp/cover.png
            url="/tmp/cover.png"
        fi
        echo "$url"
    fi
    ;;
--artist)
    artist=$(get_metadata "xesam:artist")
    if [ -z "$artist" ]; then
        echo ""
    else
        echo "${artist:0:50}"
    fi
    ;;
--length)
    length=$(get_metadata "mpris:length")
    if [ -z "$length" ]; then
        echo ""
    else
        # Convert length from microseconds to a more readable format (seconds)
        echo "$(echo "scale=2; $length / 1000000 / 60" | bc) m"
    fi
    ;;
--status)
    status=$(playerctl status 2>/dev/null)
    if [[ $status == "Playing" ]]; then
        echo "󰎆"
    elif [[ $status == "Paused" ]]; then
        echo "󱑽"
    else
        echo ""
    fi
    ;;
--album)
    album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
    if [[ -n $album ]]; then
        echo "$album"
    else
        status=$(playerctl status 2>/dev/null)
        if [[ -n $status ]]; then
            echo ""
        else
            echo ""
        fi
    fi
    ;;
--source)
    get_source_info
    ;;
*)
    echo "Usage:
    $0 {-t|-u|-a|-l|-r|-s}
    $0 {--title|--url|--artist|--length|--album|--source}"
    exit 1
    ;;
esac
