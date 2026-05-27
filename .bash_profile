#!/usr/bin/env bash
#
# ~/.bash_profile -- executed by bash(1) for login shells.

# ——— Shell Init ———————————————————————————————————————————————————————————————

[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"

# ——— TTY Autostart ————————————————————————————————————————————————————————————

# Launch Hyprland automatically when logging in on tty1.
# [[ $(tty) == /dev/tty1 && -z $DISPLAY ]] && exec ~/.local/bin/hyprland

