#!/usr/bin/env bash

caelestia_scheme=~/.local/state/caelestia/scheme.json

#
# Changing kitty persistently
#
kitty_theme=~/.config/kitty/theme/current.conf

mkdir -p "$(dirname "$kitty_theme")"

jq -r '
  "background           #" + .colours.base,
  "foreground           #" + .colours.text,
  "cursor               #" + .colours.subtext1,
  "selection_background #" + .colours.surfaceContainerHigh,
  "selection_foreground #" + .colours.text,
  "color0               #" + .colours.term0,
  "color1               #" + .colours.term1,
  "color2               #" + .colours.term2,
  "color3               #" + .colours.term3,
  "color4               #" + .colours.term4,
  "color5               #" + .colours.term5,
  "color6               #" + .colours.term6,
  "color7               #" + .colours.term7,
  "color8               #" + .colours.term8,
  "color9               #" + .colours.term9,
  "color10              #" + .colours.term10,
  "color11              #" + .colours.term11,
  "color12              #" + .colours.term12,
  "color13              #" + .colours.term13,
  "color14              #" + .colours.term14,
  "color15              #" + .colours.term15
' "$caelestia_scheme" >"$kitty_theme"

kitty @ set-colors --all --configured "$kitty_theme" >/dev/null 2>&1 || true

#
# Adapting Vencord/Vesktop
#

discord_theme=/home/toni/.config/vesktop/themes/caelestia.theme.css
sed -i 's/--font: "figtree";/--font: "Monaspace Krypton";/' "$discord_theme"
sed -z -E -i 's/(--top-bar-height:[[:space:]]*)var\([[:space:]]*--gap[[:space:]]*\)/\1var(--gap * 2)/g' "$discord_theme"

#
# Override Icon Theme
#
# Caelestia has the icon theme hardcoded into its CLI repo.
# https://github.com/caelestia-dots/cli/blob/d0f8a06e5959326f04ccf535b1b5c8bd15f6aa89/src/caelestia/utils/theme.py#L180
#
# In this file there is a loopo for all the different Discord clients, which can be edited to prevent the creation of all the unnecessary clients I don't use.
#
# /usr/lib64/python3.13/site-packages/caelestia/utils/theme.py

gsettings set org.gnome.desktop.interface icon-theme 'Win11'
