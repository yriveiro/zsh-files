#!/bin/zsh -f

# ==============================================================================
# Git Repository Management Functions
# Purpose: Provide utility functions for git repository cloning and worktree management
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Source color definitions
# ------------------------------------------------------------------------------
source "${0:A:h}/00_colors.zsh"

# ------------------------------------------------------------------------------
# Git Clone Bare
# Clones a Git repository in bare mode with customizable service host and protocol
# ------------------------------------------------------------------------------
# Usage: gcb <repository_path> [service_host] [protocol]
# Args:
#   repository_path: Path to the repository (e.g., username/repo)
#   service_host: Git service host (default: github.com)
#   protocol: Clone protocol (ssh or https, default: ssh)
function gcb() {
  local repository_path=${1:-}
  local service_host=${2:-github.com}
  local protocol=${3:-ssh}

  # Validate required arguments
  if [[ -z "${repository_path}" ]]; then 
    err "Repository path is required"
    info "usage: gcb repository_path service_host protocol"
    return 1
  fi

  # Validate protocol
  if [[ "${protocol}" != "ssh" && "${protocol}" != "https" ]]; then 
    err "Invalid protocol, use ssh or https"
    info "usage: gcb repository_path service_host protocol"
    return 1
  fi

  # Construct repository URL based on protocol
  local url
  if [[ "${protocol}" == "ssh" ]]; then
    url="git@${service_host}:${repository_path}.git"
  else
    url="https://${service_host}/${repository_path}.git"
  fi

  local repository="${repository_path##*/}"

  # Clone repository in bare mode
  git clone --quiet --bare "${url}" "${repository}" || {
    err "Failed to clone ${YELLOW}${repository}${RESET}"
    return 1
  }
  
  success "Cloned ${YELLOW}${repository_path}${RESET} to ${YELLOW}${repository}${RESET}"

  # Change to repository directory
  cd "${repository}" || {
    err "Failed to enter ${YELLOW}${repository}${RESET}"
    return 1
  }

  # Determine default branch (main or master)
  local branch_name="main"
  if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
    branch_name="master"
    if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
      err "Neither 'main' nor 'master' branches found"
      return 1
    fi
  fi

  # Setup worktree for default branch
  git worktree add -q "${branch_name}" || {
    err "Failed to add worktree for ${YELLOW}${branch_name}${RESET}"
    return 1
  }

  cd "${branch_name}" || {
    err "Failed to enter ${YELLOW}${branch_name}${RESET}"
    return 1
  }

  # Configure git repository
  git config advice.setUpstreamFailure false
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  success "${YELLOW}${branch_name}${RESET} ready to track ${YELLOW}origin/${branch_name}${RESET}"

  # Setup tracking
  git fetch -q origin &> /dev/null
  git branch -q --set-upstream-to="origin/${branch_name}" "${branch_name}"

  success "${YELLOW}${repository}${RESET} ready to use"
}

# ------------------------------------------------------------------------------
# Git Worktree Add
# Adds a new worktree for the specified branch
# ------------------------------------------------------------------------------
# Usage: gwa <branch_name>
# Args:
#   branch_name: Name of the branch for the new worktree
function gwa() {
  local branch=${1}

  if [[ -z "${branch}" ]]; then
    err "Worktree name is required"
    return 1
  fi

  git worktree add -q "${branch}" || {
    err "Failed to add worktree for ${YELLOW}${branch}${RESET}"
    return 1
  }

  success "${YELLOW}${branch}${RESET} ready to use"
  cd "${branch}" || {
    err "Failed to enter ${YELLOW}${branch}${RESET}"
    return 1
  }
}
