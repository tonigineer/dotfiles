#!/usr/bin/env sh

readonly CFG_FILE=~/.config/caelestia/shell.json

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    echo "$( jq --indent 4 '.border.rounding = 0 | .border.thickness = 0' "$CFG_FILE" )" > "$CFG_FILE"
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword animation borderangle,0; \
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
	    keyword decoration:fullscreen_opacity 1;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 0;\
        keyword decoration:rounding 0"
    hyprctl notify 1 5000 "rgb(40a02b)" "Gamemode [ON]"
    exit
else
    hyprctl notify 1 5000 "rgb(d20f39)" "Gamemode [OFF]"
    echo "$( jq --indent 4 '.border.rounding = 25 | .border.thickness = 10' $CFG_FILE)" > "$CFG_FILE"
    hyprctl reload
    exit 0
fi

exit 1
