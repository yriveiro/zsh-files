#!/bin/zsh -f

# ANSI color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[0;37m'
RESET='\033[0m'

# Status Symbols
CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
INFO="ℹ️"
QUESTION="❓"
EXCLAMATION="❗"

# Progress and Actions
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

# Development and System
PACKAGE="📦"
BUG="🐛"
DEBUG="🔧"
ZSH_ICON="🐚"  # Using ZSH_ICON instead of SHELL to avoid conflicts
CODE="💻"
DATABASE="🗄️"
CLOUD="☁️"
SERVER="🖥️"
NETWORK="🌐"

# File Operations
FILE="📄"
FOLDER="📁"
ZIP="🗜️"
TRASH="🗑️"
CLIPBOARD="📋"
MEMO="📝"

# Status and Notifications
SUCCESS="💚"
ERROR="💔"
ALERT="🚨"
BELL="🔔"
MAIL="📧"
BATTERY="🔋"
PLUG="🔌"

# Time and Progress
CLOCK="🕐"
CALENDAR="📅"
STOPWATCH="⏱️"
TIMER="⏲️"

# Predefined color + symbol combinations
CROSS="${RED}${CROSS_MARK}${RESET}"
CHECK="${GREEN}${CHECK_MARK}${RESET}"
WARN="${YELLOW}${WARNING}${RESET}"
NOTE="${BLUE}${INFO}${RESET}"

# Info and error message functions with consistent styling
function info() {
  printf "${CYAN}${BELL} [INFO]${RESET}: ${1}\n" 2>&1
}

function err() {
  printf "${RED}${ERROR} [ERR]${RESET}: ${1}\n" 2>&1
}

function warn() {
  printf "${YELLOW}${WARNING} [WARN]${RESET}: ${1}\n" 2>&1
}

function debug() {
  printf "${MAGENTA}${DEBUG} [DEBUG]${RESET}: ${1}\n" 2>&1
}

function success() {
  printf "${GREEN}${SUCCESS} [SUCCESS]${RESET}: ${1}\n" 2>&1
}
