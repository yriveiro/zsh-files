#!/bin/zsh -f

# ==============================================================================
# macOS-specific Aliases Configuration
# Purpose: Define aliases specific to macOS environment
# Author: Yago Riveiro
# ==============================================================================

# Only load if running on macOS
[[ "${OSTYPE}" == "darwin"* ]] || return

# ------------------------------------------------------------------------------
# Development Directory Shortcuts
# Quick access to development directories
# ------------------------------------------------------------------------------
alias github="~/Development/github"
alias gist="~/Development/gist"
alias devel="cd ~/Development"

# ------------------------------------------------------------------------------
# System Maintenance
# Homebrew update and cleanup
# ------------------------------------------------------------------------------
alias brewup="brew update && brew upgrade && brew cleanup && brew autoremove"

# ------------------------------------------------------------------------------
# Network Utilities
# macOS-specific network tools
# ------------------------------------------------------------------------------
alias net-speed="networkQuality -v -p"
alias mk="make"
