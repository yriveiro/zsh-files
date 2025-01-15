#!/usr/bin/env bash

# ZSH Configuration Installer
# This script installs the ZSH configuration by:
# 1. Checking for required dependencies
# 2. Backing up any existing configuration
# 3. Cloning the configuration repository
# 4. Creating necessary symlinks
#
# Usage:
#   curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/yriveiro/zsh-files/main/install.sh | sh
#
# Author: Yago Riveiro
# License: MIT

#------------------------------------------------------------------------------
# Color and Icon Configuration
#------------------------------------------------------------------------------

# ANSI color codes for output formatting
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Unicode emojis for visual feedback
ROCKET="🚀"   # Installation start/completion
PACKAGE="📦"  # Dependencies
GEAR="⚙️"    # Operations/Info
WARNING="⚠️" # Warnings
ERROR="❌"    # Errors
CHECK="✅"    # Success
LINK="🔗"     # Symlink operations
ZSH_ICON="🐚" # Shell-related operations

#------------------------------------------------------------------------------
# Configuration Variables
#------------------------------------------------------------------------------

# Installation directories and repository URL
CONFIG_DIR="${HOME}/.config/zsh"
BACKUP_DIR="${HOME}/.config/zsh.backup.$(date +%Y%m%d_%H%M%S)"
REPO_URL="https://github.com/yriveiro/zsh-files.git"

#------------------------------------------------------------------------------
# Logging Functions
#------------------------------------------------------------------------------

# Display informational message
# Args:
#   $1 - Message to display
log_info() {
  printf "%b%b%b %s\n" "${BLUE}" "${GEAR}" "${RESET}" "$1"
}

# Display success message
# Args:
#   $1 - Message to display
log_success() {
  printf "%b%b%b %s\n" "${GREEN}" "${CHECK}" "${RESET}" "$1"
}

# Display warning message
# Args:
#   $1 - Message to display
log_warning() {
  printf "%b%b%b %s\n" "${YELLOW}" "${WARNING}" "${RESET}" "$1"
}

# Display error message and return error code
# Args:
#   $1 - Error message to display
log_error() {
  printf "%b%b%b %s\n" "${RED}" "${ERROR}" "${RESET}" "$1"
}

#------------------------------------------------------------------------------
# Installation Functions
#------------------------------------------------------------------------------

# Check if required dependencies are installed
# Returns:
#   0 if all dependencies are present, 1 otherwise
check_dependencies() {
  local missing_deps=0

  for cmd in zsh git curl; do
    if ! command -v "$cmd" &>/dev/null; then
      log_error "$cmd is required but not installed"
      missing_deps=1
    fi
  done

  if [[ $missing_deps -eq 1 ]]; then
    log_error "Please install missing dependencies and try again"
    exit 1
  fi

  log_success "All dependencies are installed"
}

# Backup existing ZSH configuration if present
# Creates a timestamped backup directory
backup_existing() {
  if [[ -d "$CONFIG_DIR" ]]; then
    log_warning "Existing configuration found, creating backup at ${BACKUP_DIR}"

    mv "$CONFIG_DIR" "$BACKUP_DIR" || log_error "Failed to create backup"
  fi
}

# Create symlink for zshrc file
# Backs up existing .zshrc if present
create_symlink() {
  if [[ -f "${HOME}/.zshrc" ]] || [[ -L "${HOME}/.zshrc" ]]; then
    log_warning "Existing .zshrc found, creating backup"

    mv "${HOME}/.zshrc" "${HOME}/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  fi

  ln -s "${CONFIG_DIR}/zshrc" "${HOME}/.zshrc" || log_error "Failed to create symlink"

  log_success "Created .zshrc symlink"
}

#------------------------------------------------------------------------------
# Main Installation Process
#------------------------------------------------------------------------------

# Main installation function
# Orchestrates the entire installation process
main() {
  printf "\n%s Installing ZSH configuration...\n\n" "${ROCKET}"

  printf "%s Checking dependencies...\n" "${PACKAGE}"
  check_dependencies

  printf "\n%s Preparing installation...\n" "${GEAR}"
  backup_existing

  printf "\n%s Cloning zsh-files repository...\n" "${ZSH_ICON}"
  git clone --quiet "$REPO_URL" "$CONFIG_DIR" || log_error "Failed to clone repository"
  log_success "Repository cloned successfully"

  printf "\n%s Setting up configuration...\n" "${LINK}"
  create_symlink

  printf "\n%s Installation completed successfully!\n" "${ROCKET}"
  printf "%s Please restart your shell or run: source ~/.zshrc\n\n" "${ZSH_ICON}"
}

# Start the installation
main
