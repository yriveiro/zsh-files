#!/usr/bin/env bash

# ZSH Configuration Installer
# This script installs the ZSH configuration by:
# 1. Checking for required dependencies
# 2. Backing up any existing configuration
# 3. Cloning the configuration repository
# 4. Creating necessary symlinks
#
# Usage:
#   curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/yriveiro/zsh-files/main/install.sh | bash
#   ./install.sh validate
#   ./install.sh warmup
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

run_validation_check() {
  local description=$1

  shift

  if "$@"; then
    log_success "$description"

    return 0
  fi

  log_error "$description"

  return 1
}

require_validation_path() {
  local path=$1

  [[ -e "$path" ]]
}

assert_pattern_present() {
  local description=$1
  local pattern=$2

  shift 2

  if grep -Eq "$pattern" "$@"; then
    log_success "$description"

    return 0
  fi

  log_error "$description"

  return 1
}

assert_pattern_absent() {
  local description=$1
  local pattern=$2

  shift 2

  if grep -En "$pattern" "$@" >/dev/null; then
    log_error "$description"
    grep -En "$pattern" "$@"

    return 1
  fi

  log_success "$description"

  return 0
}

validate_repo() {
  local repo_root
  local zshrc_path
  local install_path
  local zinit_path
  local -a config_files

  repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  zshrc_path="${repo_root}/zshrc"
  install_path="${repo_root}/install.sh"
  zinit_path="${repo_root}/config.d/05_zinit.zsh"
  config_files=("${repo_root}"/config.d/*.zsh)

  printf "\n%s Validating repository state...\n\n" "${GEAR}"

  run_validation_check "Found repo-local zshrc" require_validation_path "$zshrc_path" || return 1
  run_validation_check "Found repo-local install entrypoint" require_validation_path "$install_path" || return 1
  run_validation_check "Found repo-local zinit config" require_validation_path "$zinit_path" || return 1
  run_validation_check "Found shared config fragments" require_validation_path "${config_files[0]}" || return 1

  run_validation_check "install.sh parses with bash" bash -n "$install_path" || return 1
  run_validation_check "zshrc and config.d parse with zsh" zsh -n "$zshrc_path" "${config_files[@]}" || return 1

  assert_pattern_absent \
    "zshrc does not bootstrap zinit during startup" \
    'git clone.*zinit|curl.*zinit|wget.*zinit|github\.com/.*/zinit|zdharma-continuum/zinit' \
    "$zshrc_path" || return 1

  assert_pattern_present \
    "zshrc sources only config.local.d/*.zsh for local overrides" \
    'for f in "\$\{ZSH_CONFIG_ROOT\}/config\.local\.d"/\*\.zsh\(N\); do' \
    "$zshrc_path" || return 1

  assert_pattern_present \
    "zinit completion init path remains zicompinit; zicdreplay" \
    'zicompinit; zicdreplay' \
    "$zinit_path" || return 1

  assert_pattern_absent \
    'config.d does not use ${0:A:h}' \
    '\$\{0:A:h\}' \
    "${config_files[@]}" || return 1

  assert_pattern_absent \
    'config.d does not use bashcompinit' \
    '\bbashcompinit\b' \
    "${config_files[@]}" || return 1

  assert_pattern_absent \
    'config.d does not contain hardcoded user home paths' \
    '/Users/|/home/' \
    "${config_files[@]}" || return 1

  assert_pattern_absent \
    'tracked files do not reference removed helper validation scripts' \
    'scripts/validate\.zsh|validate\.zsh' \
    "$install_path" "$zshrc_path" "$zinit_path" "${repo_root}/README.md" || return 1

  printf "\n%s Validation completed successfully.\n\n" "${CHECK}"
}

warmup_repo() {
  local repo_root
  local cache_root
  local zcompdump_path
  local zcompdump_quoted
  local completion_cache_dir
  local state_dir
  local -a compile_targets
  local file

  repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  cache_root="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
  zcompdump_path="${cache_root}/.zcompdump"
  zcompdump_quoted=$(printf '%q' "${zcompdump_path}")
  completion_cache_dir="${cache_root}/completion"
  state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh"
  compile_targets=(
    "${repo_root}/zshrc"
    "${repo_root}"/config.d/*.zsh
  )

  printf "\n%s Warming up repository state...\n\n" "${GEAR}"

  validate_repo || return 1

  mkdir -p "${completion_cache_dir}" "${state_dir}" || return 1
  log_success "Prepared zsh cache and state directories"

  if [[ -r "${HOME}/.zinit/bin/zinit.zsh" ]]; then
    if ZDOTDIR="${repo_root}" zsh -ic '[[ -n ${ZSH_VERSION:-} ]]' >/dev/null 2>&1; then
      log_success "Warmed zsh completion state via interactive startup"
    else
      log_warning "Skipped interactive zsh warmup"
    fi
  else
    log_warning "Skipped interactive zsh warmup because zinit is not installed"
  fi

  if ZDOTDIR="${repo_root}" zsh -ic "autoload -Uz compinit && compinit -d ${zcompdump_quoted}" >/dev/null 2>&1 && [[ -f "${zcompdump_path}" ]]; then
    log_success "Generated completion dump at ${zcompdump_path}"
  elif [[ -f "${zcompdump_path}" ]]; then
    log_success "Detected completion dump at ${zcompdump_path}"
  else
    log_warning "Skipped completion dump generation"
  fi

  for file in "${compile_targets[@]}"; do
    [[ -f "${file}" ]] || continue

    if zsh -fc "zcompile ${file:q}" >/dev/null 2>&1; then
      log_success "Compiled $(basename -- "${file}")"
    else
      log_warning "Skipped compilation for $(basename -- "${file}")"
    fi
  done

  printf "\n%s Warmup completed.\n\n" "${CHECK}"
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
  log_warning "Install zinit separately if you want plugin-managed completions and plugins"
  printf "%s Please restart your shell or run: source ~/.zshrc\n\n" "${ZSH_ICON}"
}

if [[ "${1:-}" == "validate" ]]; then
  validate_repo
elif [[ "${1:-}" == "warmup" ]]; then
  warmup_repo
else
  main
fi
