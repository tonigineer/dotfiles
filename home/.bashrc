#!/usr/bin/env bash

[[ -f "$HOME/.bash_aliases" ]] && . "$HOME/.bash_aliases"
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"

export PROMPT_DIRTRIM=3

# Remove NerdFont icons for tty's
[[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && ic1="sh" || ic1=
[[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && ic2="git" || ic2=
[[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && ic3="|" || ic3=⌜
[[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && ic4="|" || ic4=⌟
[[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && ic5=">" || ic5=❯
[[ $(tty) == '/dev/tty1' && ! $DISPLAY ]] && setfont ter-132n

function custom_prompt {
    BRANCH=$(git status 2>/dev/null | grep "On branch " | rev | cut -d " " -f1 | rev)

    local field1 field2 field3 field5
    field1="$(tput setaf 255)${ic1}$(tput sgr0)"
    field2="$(tput setaf 6)\u$(tput sgr0)$(tput setaf 8):$(tput sgr0)$(tput setaf 3)\h$(tput sgr0)"
    field3="$(tput setaf 255)\w$(tput sgr0)"
    field5="${ic5} "

    local prpt_git
    prpt_git=$([[ ! "$BRANCH" = "" ]] && echo "$(tput setaf 8)${ic3}$(tput sgr0)$(tput setaf 1)${ic2} $(tput sgr0)${BRANCH}$(tput setaf 8)${ic4}$(tput sgr0)" || echo "")

    PS1=$"${field1} ${field2} ${field3} ${prpt_git}"$'\n'"${field5}"
}

PROMPT_COMMAND="custom_prompt; ${PROMPT_COMMAND}"
