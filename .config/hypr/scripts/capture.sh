#!/usr/bin/env bash

readonly SCREENSHOT_DIR=~/Pictures/Screenshots/
readonly RECORDINGS_DIR=~/Videos/Recordings/
readonly PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/wf-recorder.pid"

declare monitor
monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

if [ ! -d "$SCREENSHOT_DIR" ]; then
    mkdir -p "$SCREENSHOT_DIR"
fi

if [ ! -d "$RECORDINGS_DIR" ]; then
    mkdir -p "$RECORDINGS_DIR"
fi

show_menu() {
    local options="Screenshot monitor\nScreenshot selection\nRecord monitor\nRecord selection"

    if command -v walker >/dev/null 2>&1; then
        echo -e "$options" | walker -d "Capture Menu" --minheight 4
    else
        notify-send \
            "Custom Capture Error" \
            "Command 'walker' not found. Install via 'yay -Syu walker'." \
            --app-name="Custom Capture" \
            --icon=dialog-error \
            -u critical
        echo "Error: command walker not found" >&2
        exit 1
    fi
}

take_screenshot() {
    readonly mode="$1"

    declare filename
    filename="$SCREENSHOT_DIR$(date +'screenshot_%Y%m%d_%H%M%S.png')"

    if [[ "$mode" == "screen" ]]; then
        grim -o "$monitor" - | magick - -shave 1x1 PNG:- | wl-copy
    else
        grim -g "$(slurp)" - | magick - -shave 1x1 PNG:- | wl-copy
    fi

    # Create file and copy path immediately as default
    wl-paste >"$filename"
    echo "$filename" | wl-copy

    action="$(
        notify-send \
            "Screenshot taken" \
            "💾📋 $filename" \
            --action=copy-image='Copy' \
            --action=open-image='Open' \
            --action=edit-image='Edit' \
            --app-name="Custom Capture" \
            --icon=~/.config/hypr/scripts/assets/recording-started.svg
    )"

    case "$action" in
    "copy-image")
        wl-copy --type image/png <"$filename"
        ;;
    "open-image")
        xdg-open "$filename"
        ;;
    "edit-image")
        swappy -f "$filename"
        ;;
    esac
}

record_video() {
    filename="$RECORDINGS_DIR$(date +'recording_%Y%m%d_%H%M%S.mkv')"

    if [[ "$mode" == "screen" ]]; then
        wf-recorder --output "$monitor" --file="$filename" &
    else
        wf-recorder -g "$(slurp)" --file="$filename" &
    fi

    echo $! >"$PIDFILE"
    notify-send "Recording started" \
        --app-name="Custom Capture" \
        -t 2000 \
        --icon ~/.config/hypr/scripts/assets/recording-started.svg
}

stop_recording() {
    if [[ -r "$PIDFILE" ]]; then
        pid="$(cat "$PIDFILE")"
        rm -f "$PIDFILE"

        kill -INT "$pid" 2>/dev/null || true
        # wait for it to finalize the file
        wait "$pid" 2>/dev/null || true

        filename="$RECORDINGS_DIR$(ls -1t -- "$RECORDINGS_DIR" | head -n 1)"
        echo "$filename" | wl-copy

        action="$(
            notify-send \
                "Recording stopped" \
                "💾📋 $filename" \
                --action=play-video='Play' \
                --action=convert-gif='Make .gif' \
                --app-name="Custom Capture" \
                --icon ~/.config/hypr/scripts/assets/recording-stopped.svg
        )"

        case "$action" in
        "play-video")
            xdg-open "$filename"
            ;;
        "convert-gif")
            ~/.config/hypr/scripts/convert.sh "$filename"
            ;;
        esac

        exit 0
    fi
}

main() {
    stop_recording

    declare choice
    choice=$(show_menu)

    case $choice in
    "Screenshot monitor")
        type="screenshot"
        mode="screen"
        ;;
    "Screenshot selection")
        type="screenshot"
        mode="selection"
        ;;
    "Record monitor")
        type="video"
        mode="screen"
        ;;
    "Record selection")
        type="video"
        mode="selection"
        ;;
    esac

    case $type in
    "screenshot")
        take_screenshot "$mode"
        ;;
    "video")
        record_video "$mode"
        ;;
    esac
}

main "$@"
