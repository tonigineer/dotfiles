#!/usr/bin/env bash

input_file=$1

if [[ ! -f "$input_file" ]]; then
    notify-send "Custom Capture Error" "Input file: $input_file does not exist"

    echo "Error: Input file '$input_file' not found"
    exit 1
fi

readonly OUTPUT_DIR=~/Pictures/gifs
mkdir -p "$OUTPUT_DIR"

show_menu() {
    local options="good\nbetter\nbest\ncancel"

    if command -v walker >/dev/null 2>&1; then
        echo -e "$options" | walker -d "Gif Quality Menu"
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

convert() {
    readonly fps=$1
    readonly scale=$2
    readonly max_colors=$3
    readonly gifsicle_lossy=$4

    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    readonly PALETTE_FILE="$TMP_DIR/palette.png"
    readonly GIF_FILE="$TMP_DIR/out.gif"
    readonly OPTIMIZED_GIF="$TMP_DIR/out_optimized.gif"

    # 1) Optional: pick a short segment (-ss start, -t duration), downscale & make a palette
    ffmpeg -ss 00:00:00 -i "$input_file" \
        -vf "fps=$fps,scale=$scale:-1:flags=lanczos,palettegen=stats_mode=full:max_colors=$max_colors" \
        -y "$PALETTE_FILE"

    # 2) Use the palette to create the GIF (with efficient dithering)
    ffmpeg -ss 00:00:00 -i "$input_file" -i "$PALETTE_FILE" \
        -lavfi "fps=$fps,scale=$scale:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5" \
        -loop 0 "$GIF_FILE"

    # 3) Squeeze a bit more
    gifsicle -O3 --lossy="$gifsicle_lossy" -o "$OPTIMIZED_GIF" "$GIF_FILE"

    filename="$OUTPUT_DIR/$(basename -- "$input_file").gif"
    mv "$OPTIMIZED_GIF" "$filename"

    echo "$filename"
}

main() {
    choice=$(show_menu)

    case "$choice" in
    "good")
        FPS=8
        SCALE=640
        MAX_COLORS=64
        GIFSICLE_LOSSY=50
        ;;
    "better")
        FPS=12
        SCALE=960
        MAX_COLORS=128
        GIFSICLE_LOSSY=30
        ;;
    "best")
        FPS=15
        SCALE=1280
        MAX_COLORS=256
        GIFSICLE_LOSSY=10
        ;;
    "cancel" | *)
        echo "Conversion cancelled"
        exit 0
        ;;
    esac

    notify-send "Creating gif" \
        "Quality '$choice' chosen." \
        --app-name="Custom Capture" \
        --icon ~/.config/hypr/scripts/assets/convert2gif.svg \
        -t 2000

    filename=$(convert "$FPS" "$SCALE" $MAX_COLORS $GIFSICLE_LOSSY)
    new_filename="${filename/.mkv/_$choice}"
    mv "$filename" "$new_filename"
    echo "$new_filename" | wl-copy

    action="$(
        notify-send \
            "Gif created" \
            "💾📋 $new_filename" \
            --action=copy-image='Copy' \
            --action=open-image='Open' \
            --app-name="Custom Capture" \
            --icon="$new_filename"
    )"

    case "$action" in
    "copy-image")
        wl-copy --type image/gif <"$new_filename"
        ;;
    "open-image")
        xdg-open "$new_filename"
        ;;
    esac
}

main "$@"
