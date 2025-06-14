#!/bin/zsh -f

# ==============================================================================
# ZSH Common Functions Configuration
# Purpose: Define common utility functions for messages and configuration editing
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Common Color Configuration
# Source shared color and icon definitions for consistent styling
# ------------------------------------------------------------------------------
source "${0:A:h}/00_colors.zsh"

# ------------------------------------------------------------------------------
# Configuration Navigation Functions
# These functions help navigate and edit configuration directories
# ------------------------------------------------------------------------------
# Edit configuration in specified context directory under ~/.config
# Usage: ec <context_name>
function ec() {
  if [[ -z "${1}" ]]; then
    err "Context can't be empty"
    return 1
  fi

  local ctx_dir="${HOME}/.config/${1}"

  if [[ ! -d "${ctx_dir}" ]]; then
    err "No configuration found for context: ${YELLOW}${1}${RESET}"
    return 1
  fi

  (
    cd "${ctx_dir}" || {
      err "Failed to change to directory: ${YELLOW}${ctx_dir}${RESET}"
      return 1
    }

    nvim || {
      err "Failed to open nvim"
      return 1
    }
  )
}

# ------------------------------------------------------------------------------
# Git Repository Functions
# These functions help manage git repository configurations
# ------------------------------------------------------------------------------
# Configure bare git repository to fetch all remote references
# Must be executed within a git repository
function patch_bare() {
  command git rev-parse --is-inside-work-tree &>/dev/null || {
    err "Not in a git repository"
    return 1
  }

  info "Patch repository ${PWD}"
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" || {
    err "Failed to patch repository"
    return 1
  }
}

function wtr() {
  if [[ -z "${1}" ]]; then
    err "Workspace name can't be empty"
    return 1
  fi

  local name="${1}"

  command wezterm cli rename-workspace "${name}" &> /dev/null || {
    err "Failed to rename Wezterm workspace"
    return 1
  }

  success "Wezterm workspace renamed to ${name}"
}
