#!/usr/bin/env bash

readonly WALLPAPER_DIR="$HOME/Wallpaper"

function main() {
  local selected
  selected="$(find -L "$WALLPAPER_DIR" -type f -iregex '.*\.\(gif\|mp4\|mkv\|webm\|mov\|avi\|m4v\|flv\|ts\)$' -printf '%P\n' |
    LC_ALL=C sort |
    fzf --prompt="Select Live-Background > " --height=100% --border --cycle --reverse)" || exit 1

  local monitors
  monitors=$(hyprctl monitors | awk '/^Monitor /{print $2}')

  pkill -x mpvpaper 2>/dev/null || true

  # if command -v caelestia >/dev/null 2>&1; then
  #   caelestia shell wallpaper set "" || true
  # fi

  for m in $monitors; do
    setsid -f mpvpaper -p -f \
      -o --loop-file=inf \
      "$m" "$WALLPAPER_DIR/$selected" >/dev/null 2>&1 &
  done
}

main "$@"
