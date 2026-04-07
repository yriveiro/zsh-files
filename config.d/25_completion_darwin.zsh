#!/bin/zsh -f

# Skip if not running on Darwin
[[ "${OSTYPE}" == "darwin"* ]] || return

autoload -Uz compinit

_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zcompdump:h}"

if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
    compinit -d "$_zcompdump"
else
    compinit -C -d "$_zcompdump"
fi
