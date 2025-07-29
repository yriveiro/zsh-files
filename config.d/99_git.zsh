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
  git worktree list 2>/dev/null | awk '{print $1; exit}' || {
    err "Not inside a git repository"
    return 1
  }
}

# ------------------------------------------------------------------------------
# Get Default Branch Name
# Description: Determines the default branch (main or master) from remote origins
# Returns: Branch name string, defaults to "main" if none found
# ------------------------------------------------------------------------------
_default_branch() {
    git branch -r | grep -E 'origin/(main|master)$' | head -1 | cut -d/ -f2 || echo "main"
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
function gc() {
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
    *) err "Protocol ${RED}${protocol}${RESET} not supported" ||return 1
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

  branch=$(_default_branch)

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

  if [[ "${remote}" == true ]]; then
    git show-ref --verify --quiet "refs/remotes/origin/${branch}" || {
      err "Remote branch ${YELLOW}origin/${branch}${RESET} does not exist"
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

  local commit=$(git -C . log -1 --oneline)

  info "${YELLOW}dev${RESET} is now ${MAGENTA}${commit}${RESET}"
}

# ------------------------------------------------------------------------------
# Git Worktree Remove
# Description: Safely removes a git worktree and its associated local branch.
#              Automatically moves to repository root before removal to avoid conflicts.
#              Only removes local branches - remote branches are preserved for safety.
# Parameters 
#   branch_name       : Name of the worktree/branch to remove (required)
# Safety Features:
#   - Moves to git root before removal to avoid "current directory" conflicts
#   - Validates worktree exists before attempting removal
#   - Only removes local branches, never touches remote branches
#   - Provides clear feedback on each operation
# Examples:
#   gwr feature-branch          # Remove feature-branch worktree and local branch
#   gwr old-experiment          # Clean up completed work
# ------------------------------------------------------------------------------
function gwr() {
  local branch=${1:?"Branch name is required"}
  local root=$(_find_git_root)
  local repository="${root:t}"
  local wt="${root:h}/${repository}-worktrees"

  _validate_git_repo || return 1


  [[ ! -d "${wt}/${branch}" ]] && {
    err "Worktree ${YELLOW}${branch}${RESET} does not exist at ${YELLOW}${repository}-worktrees/${branch}${RESET}"
    return 1
  }

  cd "${root}" || {
    err "Failed to move to repository root"
    return 1
  }

  git worktree remove "${wt}/${branch}" || {
    err "Failed to remove worktree ${YELLOW}${branch}${RESET}"
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

  cd "$wt/${branch}" && success "Switched to worktree ${YELLOW}${branch}${RESET}"
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
