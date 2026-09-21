#!/usr/bin/env bash
#
# Open the skwd-wall-v2 picker through conf/wallpaper.lua, so animations are
# off, the monitors are cleared and the Noctalia bar is hidden before it
# starts. Called by the Noctalia bar widget, whose actions cannot safely carry
# the quoting `hyprctl eval` needs.
#
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
