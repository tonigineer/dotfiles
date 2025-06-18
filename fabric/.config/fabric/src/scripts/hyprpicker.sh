#!/usr/bin/env bash
# pick.sh  [-rgb | -hex | -hsv]

magick -size 64x64 xc:"#FFFFFF" /tmp/color.png
notify-send -u low -t 1000 "HEX color picked" "#FFFFFF" -i /tmp/color.png -a "Hyprpicker"
rm /tmp/color.png
