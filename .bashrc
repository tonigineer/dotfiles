#!/usr/bin/env bash
#
# ~/.bashrc -- executed by bash(1) for interactive non-login shells.

# Bail out for non-interactive shells.
[[ $- != *i* ]] && return

# ——— Sourced Files ————————————————————————————————————————————————————————————

[[ -f "$HOME/.aliases" ]] && . "$HOME/.aliases"

# ——— Path —————————————————————————————————————————————————————————————————————

[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"
export PATH

# ——— Shell Options ————————————————————————————————————————————————————————————

export PROMPT_DIRTRIM=3

shopt -s checkwinsize # update LINES/COLUMNS after each command
shopt -s histappend   # append to history rather than overwriting

# ——— Prompt ———————————————————————————————————————————————————————————————————

# Strip NerdFont glyphs when running on a bare tty (no font support).
if [[ $(tty) == /dev/tty1 && -z $DISPLAY ]]; then
    _ic_sh="sh"
    _ic_git="git"
    _ic_lbr="|"
    _ic_rbr="|"
    _ic_arr=">"
else
    _ic_sh=""
    _ic_git=""
    _ic_lbr="⌜"
    _ic_rbr="⌟"
    _ic_arr="❯"
fi

# Cache tput sequences once instead of forking on every prompt redraw.
_c_white=$(tput setaf 255)
_c_cyan=$(tput setaf 6)
_c_yellow=$(tput setaf 3)
_c_red=$(tput setaf 1)
_c_gray=$(tput setaf 8)
_c_reset=$(tput sgr0)

custom_prompt() {
    local branch field1 field2 field3 field5 git_seg
    branch=$(git branch --show-current 2>/dev/null)

    field1="${_c_white}${_ic_sh}${_c_reset}"
    field2="${_c_cyan}\u${_c_reset}${_c_gray}:${_c_reset}${_c_yellow}\h${_c_reset}"
    field3="${_c_white}\w${_c_reset}"
    field5="${_ic_arr} "

    if [[ -n $branch ]]; then
        git_seg="${_c_gray}${_ic_lbr}${_c_reset}${_c_red}${_ic_git} ${_c_reset}${branch}${_c_gray}${_ic_rbr}${_c_reset}"
    else
        git_seg=""
    fi

    printf '\e[5 q'  # blinking bar cursor
    # printf '\e[6 q'  # steady bar cursor
    PS1="${field1} ${field2} ${field3} ${git_seg}"$'\n'"${field5}"
}

PROMPT_COMMAND="custom_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ——— Optional Shells ——————————————————————————————————————————————————————————

[[ -t 1 && $(ps -o comm= -p $PPID) != zsh ]] && command -v zsh >/dev/null && exec zsh
