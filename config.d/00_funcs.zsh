#!/bin/zsh -f

# Messages with log level
function info
{
  printf "\e[36m[INFO]\e[0m: ${1}\n" 2>&1
}

function err
{
  printf "\e[31m[ERR]\e[0m: ${1}\n" 2>&1
}

function ec () {
  local ctx=$1

  if [[ -z "${ctx}" ]]; then
    err "Context can't be empty"
    return
  fi

  if [[ -e "${HOME}/.config/${ctx}" ]]; then
    cd "${HOME}/.config/${ctx}"
    nvim
  else
    err "No configuration found for context: \e[1;33m${ctx}\e[0m"
  fi
}
