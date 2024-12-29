#!/bin/zsh -f

# Skip if not running on Linux
[[ "${OSTYPE}" == "linux"* ]] || return

autoload -Uz compinit

if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit;
else
    compinit -C;
fi;
