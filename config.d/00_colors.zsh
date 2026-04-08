#!/bin/zsh -f

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[0;37m'
RESET='\033[0m'

CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
INFO="ℹ️"
QUESTION="❓"
EXCLAMATION="❗"

ROCKET="🚀"
WORKING="🛠️"
GEAR="⚙️"
HOURGLASS="⌛"
LOADING="🔄"
SEARCH="🔍"
LINK="🔗"
LOCK="🔒"
UNLOCK="🔓"
KEY="🔑"

PACKAGE="📦"
BUG="🐛"
DEBUG_ICON="🔧"
ZSH_ICON="🐚"
CODE="💻"
DATABASE="🗄️"
CLOUD="☁️"
SERVER="🖥️"
NETWORK="🌐"

FILE="📄"
FOLDER="📁"
ZIP="🗜️"
TRASH="🗑️"
CLIPBOARD="📋"
MEMO="📝"

SUCCESS="💚"
ERROR="💔"
ALERT="🚨"
BELL="🔔"
MAIL="📧"
BATTERY="🔋"
PLUG="🔌"

CLOCK="🕐"
CALENDAR="📅"
STOPWATCH="⏱️"
TIMER="⏲️"

CROSS="${RED}${CROSS_MARK}${RESET}"
CHECK="${GREEN}${CHECK_MARK}${RESET}"
WARN="${YELLOW}${WARNING}${RESET}"
NOTE="${BLUE}${INFO}${RESET}"

info() {
  printf "%b%s%b: %s\n" "${CYAN}" "${BELL} [INFO]" "${RESET}" "$1"
}

err() {
  printf "%b%s%b: %s\n" "${RED}" "${ERROR} [ERR]" "${RESET}" "$1"
}

warn() {
  printf "%b%s%b: %s\n" "${YELLOW}" "${WARNING} [WARN]" "${RESET}" "$1"
}

debug() {
  case "${ZSH_DEBUG:-0}" in
    1|true|TRUE|yes|YES|on|ON) ;;
    *) return 0 ;;
  esac

  printf "%b%s%b: %s\n" "${MAGENTA}" "${DEBUG_ICON} [DEBUG]" "${RESET}" "$1" >&2
}

success() {
  printf "%b%s%b: %s\n" "${GREEN}" "${SUCCESS} [SUCCESS]" "${RESET}" "$1"
}
