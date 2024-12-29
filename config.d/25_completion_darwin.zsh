#!/bin/zsh -f

# Skip if not running on Darwin
[[ "${OSTYPE}" == "darwin"* ]] || return

autoload -Uz compinit

if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi
