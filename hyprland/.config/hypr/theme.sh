#!/usr/bin/env bash

# https://wiki.archlinux.org/title/GTK

THEME=$1
ICONS=$2
CURSOR=$3
CURSOR_SIZE=$4
FONT=$5

[ ! -d ~/.config/gtk-3.0 ] && mkdir ~/.config/gtk-3.0

# GTK 2
echo \
	"gtk-icon-theme-name = \"${ICONS}\"
gtk-theme-name = \"${THEME}\"
gtk-font-name = \"${FONT}\"
gtk-cursor-theme-name = \"${CURSOR}\"
gtk-cursor-theme-size = \"${CURSOR_SIZE}\"
" >~/.gtkrc-2.0

# GTK 3
echo \
	"[Settings]
gtk-icon-theme-name = ${ICONS}
gtk-theme-name = ${THEME}
gtk-font-name = ${FONT}
gtk-cursor-theme-name = ${CURSOR}
gtk-cursor-theme-size = ${CURSOR_SIZE}
gtk-application-prefer-dark-theme = true" >~/.config/gtk-3.0/settings.ini

# GTK 4
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICONS"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"
gsettings set org.gnome.desktop.interface font-name "$FONT"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Apply system wide
# ln -s "$HOME/.gtkrc-2.0" /etc/gtk-2.0/gtkrc
# ln -s "$HOME/.config/gtk-3.0/settings.ini" /etc/gtk-3.0/settings.ini
