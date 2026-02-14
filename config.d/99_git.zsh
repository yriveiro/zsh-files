#!/bin/zsh -f

# ==============================================================================
# Git Repository Management Functions
# Purpose: Provide utility functions for git repository cloning and worktree management
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Find Git Root Directory
# Description: Locates the root directory of the current git repository using worktree list
# Returns: Path to git root directory or exits with error if not in a git repo
# ------------------------------------------------------------------------------
_find_git_root() {
  local root
  root=$(git worktree list 2>/dev/null | awk '{print $1; exit}')

  [[ -z "${root}" ]] && {
    err "Not inside a git repository"
    return 1
  }

  echo "${root}"
}

# ------------------------------------------------------------------------------
# Get Default Branch Name
# Description: Determines the default branch (main or master) from remote origins
# Returns: Branch name string, defaults to "main" if none found
# ------------------------------------------------------------------------------
_default_branch() {
  local branch
  branch=$(git branch -r 2>/dev/null | grep -E '^[[:space:]]*origin/(main|master)$' | head -1 | cut -d/ -f2)

  echo "${branch:-main}"
}

_validate_git_repo() {
  local root=$(_find_git_root)

  [[ ! -d "${root}" ]] && {
    err "Not in a git repository"
    return 1
  }

  return 0
}

_get_worktree_dir() {
  local root=$(_find_git_root)
  local repository="${root:t}"

  echo "${root:h}/${repository}-worktrees"
}

# Check if local branch exists - used in both gwa() and gwr()
_local_branch_exists() {
  local branch=$1
  git show-ref --verify --quiet "refs/heads/${branch}"
}

# ------------------------------------------------------------------------------
# Git Clone (Bare or Standard)
# Description: Clones a Git repository with support for bare mode, configurable host and protocol.
#              Sets up remote configuration and creates initial worktree for bare repos.
# Parameters:
#   -s, --standard    : Clone as standard repository (default is bare)
#   repository_path   : Repository path in format "username/repo" (required)
#   service_host      : Git service hostname (default: github.com)
#   protocol          : Clone protocol - "ssh" or "https" (default: ssh)
# Examples:
#   gc username/repo
#   gc -s username/repo gitlab.com https
#   gc username/repo github.com ssh
# ------------------------------------------------------------------------------
function gwc() {
  local params="--bare"

  while [[ $# -gt 0 ]]; do
    case $1 in
      -s|--standard) params=""; shift ;;
      -*) err "Invalid option: $1"; return 1 ;;
      *) break ;;
    esac
  done

  local repository=${1:?"Repository path required"}
  local name=${repository##*/}
  local host=${2:-github.com}
  local protocol=${3:-ssh}

  [[ $protocol == (ssh|https) ]] || {
    err "Protocol must be ssh or https";
    return 1
  }

  local url

  case $protocol in
    ssh) url="git@${host}:${repository}.git" ;;
    https) url="https://${host}/${repository}.git" ;;
  esac

  git clone $params -q "$url" "$name" && cd "$name" || {
    err "clone failed"
    return 1
  }

  success "Repository ${YELLOW}$name${RESET} cloned"

  git config advice.setUpstreamFailure false
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git config push.autoSetupRemote true
  git fetch -q origin

  local branch=$(_default_branch)

  gwa $branch
}

# ------------------------------------------------------------------------------
# Git Worktree Add
# Description: Creates a new git worktree in a standardized directory structure.
#              Supports both local and remote branch creation with automatic upstream tracking.
#              Worktrees are organized in a parallel directory structure for easy management.
# Parameters:
#   -r, --remote      : Create worktree from existing remote branch with tracking
#   branch_name       : Name of the branch/worktree to create (required)
# Directory Structure:
#   repo.git/         (bare repository)
#   repo-worktrees/   (worktrees container)
#   ├── main/         (default branch worktree)
#   ├── feature1/     (feature branch worktree)
#   └── bugfix/       (bugfix branch worktree)
# Examples:
#   gwa feature-branch          # Create new local branch
#   gwa -r origin-feature       # Create from existing remote branch
# ------------------------------------------------------------------------------
function gwa() {
  local remote=false
  local branch

  while [[ $# -gt 0 ]]; do
    case $1 in
      -r|--remote) remote=true; shift ;;
      -*) err "Invalid option: $1"; return 1 ;;
      *) branch=$1; break ;;
    esac
  done

  [[ -z "${branch}" ]] && { err "Branch name is required"; return 1; }

  _validate_git_repo || return 1

  local wt=$(_get_worktree_dir)

  [[ ! -d "${wt}" ]] && {
    mkdir -p "${wt}" || { 
      err "Unable to create ${RED}${wt}${RESET}"
      return 1
    }
  }

  [[ -d "${wt}/${branch}" ]] && {
    err "Worktree ${YELLOW}${branch}${RESET} already exists at ${YELLOW}${wt:t}/$branch${RESET}"
    return 1
  }

  info "Fetching latest remote state..."
  git fetch origin --prune || { warn "Failed to fetch from origin"; }

  local default=$(_default_branch)

  if [[ -d "${wt}/${default}" ]]; then
    info "Pulling latest changes in ${YELLOW}${default}${RESET}..."
    git -C "${wt}/${default}" pull --ff-only || { warn "Failed to pull latest changes in ${YELLOW}${default}${RESET}"; }
  fi

  if [[ "${remote}" == true ]]; then
    git show-ref --verify --quiet "refs/remotes/origin/${branch}" || {
      err "Remote branch ${YELLOW}origin/${branch}${RESET} does not exist"
      return 1
    }

    _local_branch_exists "$branch" && {
      err "Local branch ${YELLOW}${branch}${RESET} already exists. Use a different name or delete the local branch first."
      return 1
    }

    git worktree add -b "${branch}" "${wt}/${branch}" "origin/${branch}" >/dev/null 2>&1

    git branch -q --set-upstream-to="origin/${branch}" "${branch}" 2>/dev/null && {
      info "Tracking set to ${YELLOW}origin/${branch}${RESET}"
    } || {
      warn "Could not set tracking to ${YELLOW}origin/${branch}${RESET}"
    }
  else
    if _local_branch_exists "$branch"; then
      info "Using existing ${YELLOW}${branch}${RESET} from current HEAD"
      git worktree add -q "${wt}/${branch}" "${branch}"
    else
      info "Creating new branch ${YELLOW}${branch}${RESET} from current HEAD"
      git worktree add -q -b "${branch}" "${wt}/${branch}"
    fi
  fi || { 
    err "Failed to add worktree for ${YELLOW}${branch}${RESET}"
    return 1
  }

  success "${YELLOW}${branch}${RESET} worktree created at ${YELLOW}${wt:t}/${branch}${RESET}"

  cd "${wt}/${branch}" || {
    err "Failed to enter ${YELLOW}${branch}${RESET}"
    return 1
  }

  local commit=$(git log -1 --oneline)

  info "${YELLOW}${branch}${RESET} worktree HEAD points now to: ${MAGENTA}${commit}${RESET}"
}

# ------------------------------------------------------------------------------
# Git Worktree Remove
# Description: Safely removes a git worktree and its associated local branch.
#              Automatically moves to repository root before removal to avoid conflicts.
#              Only removes local branches - remote branches are preserved for safety.
# Parameters:
#   branch_name       : Name of the worktree/branch to remove (required)
#   --force           : Force removal even with uncommitted changes (optional)
# Safety Features:
#   - Moves to git root before removal to avoid "current directory" conflicts
#   - Validates worktree exists before attempting removal
#   - Only removes local branches, never touches remote branches
#   - Provides clear feedback on each operation
# Examples:
#   gwr feature-branch          # Remove feature-branch worktree and local branch
#   gwr feature-branch --force  # Force remove worktree with uncommitted changes
#   gwr old-experiment          # Clean up completed work
# ------------------------------------------------------------------------------
function gwr() {
  local force=false
  local branch

  while [[ $# -gt 0 ]]; do
    case $1 in
      --force) force=true; shift ;;
      -*) err "Invalid option: $1"; return 1 ;;
      *) branch="${branch:-$1}"; shift ;;
    esac
  done

  [[ -z "${branch}" ]] && { err "Branch name is required"; return 1; }

  _validate_git_repo || return 1

  local wt=$(_get_worktree_dir)

  [[ ! -d "${wt}/${branch}" ]] && {
    err "Worktree ${YELLOW}${branch}${RESET} does not exist at ${YELLOW}${wt:t}/${branch}${RESET}"
    return 1
  }

  local root=$(_find_git_root)

  cd "${root}" || {
    err "Failed to move to repository root"
    return 1
  }

  local remove_args=("${wt}/${branch}")
  ${force} && remove_args+=(--force)

  git worktree remove "${remove_args[@]}" || {
    err "Failed to remove worktree ${YELLOW}${branch}${RESET}"
    ${force} || info "Use ${YELLOW}gwr ${branch} --force${RESET} to remove with uncommitted changes"

    cd "${wt}/${branch}" || {
      err "Failed to move back to ${YELLOW}${wt}/${branch}${RESET} worktree"
    }

    return 1
  }

  success "Worktree ${YELLOW}${branch}${RESET} removed"

  if _local_branch_exists "$branch"; then
    git branch -q -D "${branch}" 2>/dev/null && {
      success "Local branch ${YELLOW}${branch}${RESET} removed"
    } || {
      warn "Could not remove local branch ${YELLOW}${branch}${RESET}"
    }
  else
    info "No local branch ${YELLOW}${branch}${RESET} to remove"
  fi
}

# ------------------------------------------------------------------------------
# Git Worktree Switch
# Description: Quickly navigate to an existing worktree directory.
#              Validates worktree exists before switching and provides clear feedback.
#              Useful for rapidly switching between different feature branches or contexts.
# Parameters:
#   branch_name: Name of the worktree/branch to switch to (required)
# Prerequisites:
#   - Must be run from within a git repository
#   - Target worktree must exist (created via gwa)
# Safety Features:
#   - Validates git repository context before execution
#   - Confirms worktree directory exists before attempting to switch
#   - Provides clear error messages for troubleshooting
# Examples:
#   gws main           # Switch to main worktree
#   gws feature-auth   # Switch to feature-auth worktree
#   gws bugfix-123     # Switch to bugfix worktree
# Related:
#   Use 'gwl' to list available worktrees
#   Use 'gwa' to create new worktrees
#   Use 'gwr' to remove worktrees
# ------------------------------------------------------------------------------
gws() {
  local branch=${1:?"Branch name is required"}

  _validate_git_repo || return 1

  local wt=$(_get_worktree_dir)

  [[ ! -d "${wt}/${branch}" ]] && {
    err "Worktree ${YELLOW}${branch}${RESET} does not exist"
    return 1
  }

  cd "$wt/${branch}" || {
    err "Failed to switch to worktree ${YELLOW}${branch}${RESET}"
    return 1
  }

  success "Switched to worktree ${YELLOW}${branch}${RESET}"

  local default=$(_default_branch)

  if [[ "${branch}" == "${default}" ]]; then
    info "Pulling latest changes for ${YELLOW}${default}${RESET}..."
    git pull --ff-only || warn "Failed to pull latest changes"
  fi
}

# ------------------------------------------------------------------------------
# Git Worktree Rebase
# Description: Rebases the current worktree branch onto the latest default branch (main/master).
#              Fetches and updates the default branch before rebasing to ensure a clean rebase.
#              Must be run from within a worktree (not the bare repo root).
# Parameters:
#   None                      : Takes no arguments, operates on current worktree branch
# Prerequisites:
#   - Must be run from within a git worktree (not the bare repo)
#   - The default branch worktree (main/master) must exist
# Workflow:
#   1. Validates git repository context
#   2. Detects the current branch and ensures it's not the default branch
#   3. Fetches latest remote state
#   4. Updates the default branch worktree with latest changes
#   5. Rebases the current branch onto the updated default branch
# Safety Features:
#   - Auto-stashes uncommitted changes before rebasing and restores them after
#   - Prevents rebasing the default branch onto itself
#   - Validates worktree and branch state before proceeding
#   - Provides clear feedback at each step
#   - On rebase conflict, advises the user on how to proceed
# Examples:
#   gwb                        # Rebase current worktree branch onto main
# Related:
#   Use 'gws <branch>' to switch to a worktree before rebasing
#   Use 'gwl' to list available worktrees
# ------------------------------------------------------------------------------
gwb() {
  _validate_git_repo || return 1

  local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  [[ -z "${current_branch}" ]] && {
    err "Could not determine current branch"
    return 1
  }

  local default=$(_default_branch)
  local wt=$(_get_worktree_dir)
  local rebase_target="${default}"

  [[ "${current_branch}" == "${default}" ]] && {
    err "Cannot rebase ${YELLOW}${default}${RESET} onto itself"
    return 1
  }

  info "Fetching latest remote state..."
  git fetch origin --prune || { warn "Failed to fetch from origin"; }

  if [[ -d "${wt}/${default}" ]]; then
    info "Updating ${YELLOW}${default}${RESET} worktree..."
    git -C "${wt}/${default}" pull --ff-only || {
      warn "Failed to fast-forward ${YELLOW}${default}${RESET}, rebase will use current local state"
    }
  else
    warn "Default branch worktree ${YELLOW}${default}${RESET} not found at ${YELLOW}${wt:t}/${default}${RESET}"
    rebase_target="origin/${default}"
    info "Rebasing onto ${YELLOW}${rebase_target}${RESET} directly"
  fi

  local stashed=false
  if ! git diff --quiet || ! git diff --cached --quiet; then
    info "Stashing uncommitted changes..."
    git stash push -m "gwb: auto-stash before rebase onto ${rebase_target}" || {
      err "Failed to stash changes, aborting rebase"
      return 1
    }
    stashed=true
  fi

  info "Rebasing ${YELLOW}${current_branch}${RESET} onto ${YELLOW}${rebase_target}${RESET}..."

  git rebase "${rebase_target}" && {
    local commit=$(git log -1 --oneline)
    success "${YELLOW}${current_branch}${RESET} rebased onto ${YELLOW}${rebase_target}${RESET}"
    info "HEAD now at: ${MAGENTA}${commit}${RESET}"
  } || {
    warn "Rebase encountered conflicts"
    info "Resolve conflicts, then run ${YELLOW}git rebase --continue${RESET}"
    info "To abort the rebase, run ${YELLOW}git rebase --abort${RESET}"
    ${stashed} && info "Stashed changes will need to be restored with ${YELLOW}git stash pop${RESET} after resolving"
    return 1
  }

  ${stashed} && {
    info "Restoring stashed changes..."
    git stash pop || {
      warn "Failed to restore stashed changes, they remain in the stash"
    }
  }
}

# ------------------------------------------------------------------------------
# Git Worktree List
# Description: Displays all git worktrees in a clean, organized format with color coding.
#              Shows the relationship between worktree directories and their associated branches.
#              Useful for getting an overview of all active development contexts.
# Parameters:
#   None                      : Takes no arguments
# Prerequisites:
#   - Must be run from within a git repository
#   - Worktrees must exist (bare repositories show all worktrees)
# Output Format:
#   Git worktrees:
#     directory-name -> branch-name
#     main -> main
#     feature-auth -> feature/authentication
# Color Coding:
#   - Directory names displayed in cyan for easy identification
#   - Branch names displayed in yellow to distinguish from directories
#   - Clear visual separation with arrow notation
# Examples:
#   gwl                        # List all worktrees in current repository
# Use Cases:
#   - Quick overview of all active development branches
#   - Verify worktree structure before switching contexts
#   - Identify which directories correspond to which branches
# Related:
#   Use 'gws <branch>' to switch to a specific worktree
#   Use 'gwa <branch>' to create new worktrees
#   Use 'gwr <branch>' to remove worktrees
# ------------------------------------------------------------------------------
gwl() {
  _validate_git_repo || return 1

  local -a out
  out=("${(@f)$(git worktree list)}")

  for line in "${out[@]}"; do
    local -a segments=("${=line}")

    # Extract branch name: get 2nd element, strip [ and ] brackets
    local branch="${${${segments[3]:-}#\[}%\]}"

    [[ -n "$branch" && "$branch" != "(bare)" ]] && {
      # Display: split path by /, take segments -2 to -1, join with /, format as "$project_worktree_base/worktree -> branch"
      echo -e "  ${CYAN}${(j:/:)${(@s:/:)segments[1]}[-2,-1]}${RESET} -> ${YELLOW}${branch}${RESET}"
    }
  done
}
