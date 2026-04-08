#!/bin/zsh -f

# ==============================================================================
# Linux-specific Aliases Configuration
# Purpose: Define aliases specific to Linux environment
# Author: Yago Riveiro
# ==============================================================================

# Only load if running on Linux
[[ "${OSTYPE}" == "linux"* ]] || return

# ------------------------------------------------------------------------------
# Development Directory Shortcuts
# Quick access to development directories
# ------------------------------------------------------------------------------
alias github="cd ${DEV_ROOT}/github.com"
alias gist="cd ${DEV_ROOT}/gist"
alias devel="cd ${DEV_ROOT}"

# ------------------------------------------------------------------------------
# System Maintenance
# Package management shortcuts
# ------------------------------------------------------------------------------
alias aptup="sudo apt update; sudo apt upgrade"
