#!/usr/bin/env bash
# POSIX compliant aliases for bash and zsh

# Defaults, kind of
alias grep='grep --color=auto'

# Listing stuff with exa
if command -v eza &>/dev/null; then
    alias ls="eza --grid --color=auto --icons"
    alias la="eza -a --grid --color=auto --icons"
    alias ll="eza -l --icons --no-user --group-directories-first  --time-style long-iso -T -L2"
    alias lla="eza -la --icons --no-user --group-directories-first  --time-style long-iso -T -L2"
    alias llt="eza -la --icons --no-user --group-directories-first  --time-style long-iso -T -L4"
fi

# Program
if command -v nvim &>/dev/null; then
    alias v="nvim"
fi

# Extracting files
extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) rar x $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 -d ${1%.*} ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Extras
if command -v tty-clock &>/dev/null; then
    alias clock="tty-clock -c -C 1"
fi

if command -v cmatrix &>/dev/null; then
    alias matrix="cmatrix -ab -C red"
fi

if command -v cbonsai &>/dev/null; then
    alias bonsai="cbonsai -l -i"
fi

if command -v asciiquarium &>/dev/null; then
    alias aquarium="asciiquarium -t"
fi

alias weather="hyprctl dispatch fullscreen 1; clear; curl -s wttr.in; echo; read
-k1 -s '?Press any key to exit...'; echo; exit"

alias welcome="figlet 'Welcome back' | lolcat -p 0.5"

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

alias mkdir="mkdir -p"
