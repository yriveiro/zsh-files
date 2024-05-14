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

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Define icons
CHECK_MARK="\u2714"
CROSS_MARK="\u2716"


function ec () {
  if [[ -z "${1}" ]]; then
    err "Context can't be empty"
    return
  fi

  local ctx_dir="${HOME}/.config/${1}"

  if [[ ! -d "${ctx_dir}" ]]; then
    err "No configuration found for context: \e[1;33m${1}\e[0m"
  fi

  cd "${ctx_dir}"
  nvim
}
