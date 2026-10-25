#!/usr/bin/env bash
#
# Open the skwd-wall-v2 picker via conf/wallpaper.lua (wraps the quoting
# `hyprctl eval` needs, which Noctalia bar actions cannot carry).
# Usage: skwd-open.sh [--mixer]

set -euo pipefail

case "${1:-}" in
"") hyprctl eval 'require("conf.wallpaper").open()' ;;
--mixer) hyprctl eval 'require("conf.wallpaper").open("--mixer")' ;;
*)
    echo "usage: ${0##*/} [--mixer]" >&2
    exit 2
    ;;
esac
