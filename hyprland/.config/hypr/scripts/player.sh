#!/usr/bin/env bash

get_metadata() {
    local key="$1"
    playerctl metadata --format "{{ $key }}" 2>/dev/null
}

get_source_info() {
    local trackid
    trackid=$(get_metadata "mpris:trackid")

    case "$trackid" in
    *"firefox"*) echo "󰈹   Firefox" ;;
    *"spotify"*) echo "   Spotify" ;;
    *) echo "" ;;
    esac
}

case "$1" in
--title)
    title=$(get_metadata "xesam:title")
    [[ -n "$title" ]] && echo "${title:0:50}" || echo ""
    ;;
--artist)
    artist=$(get_metadata "xesam:artist")
    [[ -n "$artist" ]] && echo "${artist:0:50}" || echo ""
    ;;
--album)
    album=$(get_metadata "xesam:album")
    echo "${album:0:50}"
    ;;
--length)
    length=$(get_metadata "mpris:length")
    if [[ -n "$length" && "$length" =~ ^[0-9]+$ ]]; then
        printf "%.2f m\n" "$(bc <<<"$length / 1000000 / 60")"
    else
        echo ""
    fi
    ;;
--status)
    status=$(playerctl status 2>/dev/null)
    case "$status" in
    "Playing") echo "󰎆" ;;
    "Paused") echo "󱑽" ;;
    *) echo "" ;;
    esac
    ;;
--arturl)
    url=$(get_metadata "mpris:artUrl")
    [[ -z "$url" ]] && echo "" && exit 0

    if [[ "$url" == file://* ]]; then
        echo "${url#file://}"
    elif [[ "$url" == https://* ]]; then
        wget -q -4 "$url" -O /tmp/cover.png && mogrify -format png /tmp/cover.png
        echo "/tmp/cover.png"
    else
        echo ""
    fi
    ;;
--source)
    get_source_info
    ;;
*)
    echo "Usage:
    $0 --title     | -t   # Song title
    $0 --artist    | -a   # Artist name
    $0 --album     | -l   # Album name
    $0 --length    | -n   # Song length in minutes
    $0 --status    | -s   # Player status icon
    $0 --arturl    | -u   # Artwork image path
    $0 --source    |      # Source application (e.g. Spotify)"
    exit 1
    ;;
esac
