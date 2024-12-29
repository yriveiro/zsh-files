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
  echo -e "${BLUE}${GEAR}${RESET} $1"
}

# Display success message
# Args:
#   $1 - Message to display
log_success() {
  echo -e "${GREEN}${CHECK}${RESET} $1"
}

# Display warning message
# Args:
#   $1 - Message to display
log_warning() {
  echo -e "${YELLOW}${WARNING}${RESET} $1"
}

# Display error message and return error code
# Args:
#   $1 - Error message to display
log_error() {
  echo -e "${RED}${ERROR}${RESET} $1"
  return 1
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
  echo -e "\n${ROCKET} Installing ZSH configuration...\n"

  echo -e "${PACKAGE} Checking dependencies..."
  check_dependencies

  echo -e "\n${GEAR} Preparing installation..."
  backup_existing

  echo -e "\n${ZSH_ICON} Cloning zsh-files repository..."
  git clone --quiet "$REPO_URL" "$CONFIG_DIR" || log_error "Failed to clone repository"
  log_success "Repository cloned successfully"

  echo -e "\n${LINK} Setting up configuration..."
  create_symlink

  echo -e "\n${ROCKET} Installation completed successfully!"
  echo -e "${ZSH_ICON} Please restart your shell or run: source ~/.zshrc\n"
}

# Start the installation
main
