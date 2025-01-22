#!/usr/bin/env bash

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Autostart hyprland directly after booting into Arch tty
# [[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && exec bash ~/.local/bin/hyprland
