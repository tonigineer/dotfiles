#!/usr/bin/env bash
# POSIX compliant aliases for bash and zsh

# Defaults, kind of
alias grep='grep --color=auto'

# Listing stuff with exa
if command -v exa &>/dev/null; then
	alias ls="exa --grid --color=auto --icons"
	alias la="exa -a --grid --color=auto --icons"
	alias ll="exa -l --icons --no-user --group-directories-first  --time-style long-iso -T -L2"
	alias lla="exa -la --icons --no-user --group-directories-first  --time-style long-iso -T -L2"
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

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

alias mkdir='mkdir -p'
