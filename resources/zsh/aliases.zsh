#!/usr/bin/env zsh

alias dog="doggo"
alias fd="fd --follow --hidden"
alias l="ls --all --long --group"
alias ls="eza"
alias lsblk="lsblk --output NAME,TYPE,SIZE,PARTLABEL,LABEL,FSTYPE,MOUNTPOINTS"
alias parallel="parallel --bar"
alias rg="rg --follow --hidden --smart-case"
alias tx="tmux attach"
alias which="which -as"

if [ "$NIXOS_MACHINE_TYPE" = "desktop" ]; then
  alias open="xdg-open"
  alias play="ffplay -autoexit -nodisp"
  alias py="python3"
  alias tl="tldr"
fi
