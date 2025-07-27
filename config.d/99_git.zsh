#!/bin/zsh

# Source color definitions
source "${0:A:h}/00_colors.zsh"

# Debug flag
DEBUG_GW=${DEBUG_GW:-false}
_debug() { [[ "$DEBUG_GW" == "true" ]] && echo "Debug: $*" }

# =============================================================================
# CONSTANTS & CONFIGURATION
# =============================================================================

# Git worktree specific icons
WT_MAIN="🏠"
WT_FEATURE="✨" 
WT_HOTFIX="🔥"
WT_RELEASE="🚀"
WT_DEVELOP="🚧"
WT_DEFAULT="🌿"
WT_TREE="🌳"

# Global git context cache
typeset -gA GP

# =============================================================================
# CORE UTILITIES
# =============================================================================

# Enhanced git execution wrapper with better error handling
_git() {
  local cmd="$1" success_msg="$2" error_msg="$3" quiet=${4:-false}
  local exit_code=0

  _debug "Executing: $cmd"

  if [[ $quiet == true ]]; then
    eval "$cmd" &>/dev/null
    exit_code=$?
  else
    eval "$cmd" 2>&1 | sed 's/^/|-> /'
    exit_code=${PIPESTATUS[1]}
  fi

  if (( exit_code == 0 )); then
    [[ -n "$success_msg" ]] && success "$success_msg"
    return 0
  else
    err "${error_msg:-Git command failed (exit: $exit_code)}"
    return $exit_code
  fi
}

# Centralized git repository initialization and validation
_init_git_context() {
  # Return early if already initialized and valid
  if [[ -n "${GP[git_dir]}" && -d "${GP[git_dir]}" ]]; then
    return 0
  fi

  # Validate git repository
  if ! git rev-parse --git-dir &>/dev/null; then
    err "Not in a git repository"
    return 1
  fi

  local git_dir=$(git rev-parse --git-dir 2>/dev/null)
  local is_bare=$(git rev-parse --is-bare-repository 2>/dev/null)
  local abs_git=${git_dir:A}

  # Initialize git context
  GP[git_dir]="$abs_git"
  GP[is_bare]="$is_bare"

  if [[ "$is_bare" == "true" ]]; then
    GP[name]="${abs_git:t}"
    GP[root]="$abs_git"
  else
    # Get main worktree for proper naming
    local main_wt=$(git worktree list --porcelain | awk '/^worktree / {print $2; exit}')
    GP[name]="${main_wt:t}"
    GP[root]="$main_wt"
  fi

  GP[wt_base]="${GP[root]:h}/${GP[name]}-worktree"
  
  # Cache current branch
  GP[current_branch]=$(git branch --show-current 2>/dev/null || echo "")
  
  _debug "Git context initialized: root=${GP[root]}, base=${GP[wt_base]}, current=${GP[current_branch]}"
  return 0
}

# Get worktree path for a branch
_get_worktree_path() {
  local branch="$1"
  [[ -z "$branch" ]] && return 1
  
  _init_git_context || return 1
  echo "${GP[wt_base]}/$branch"
}

# Get current branch with caching
_get_current_branch() {
  _init_git_context || return 1
  
  # Refresh if empty or if we might have switched
  if [[ -z "${GP[current_branch]}" ]]; then
    GP[current_branch]=$(git branch --show-current 2>/dev/null || echo "")
  fi
  
  echo "${GP[current_branch]}"
}

# Unified existence checker with better error handling
_exists() {
  local type="$1" name="$2" remote="${3:-origin}"

  _init_git_context || return 1

  case "$type" in
    branch)
      git show-ref --verify --quiet "refs/heads/$name"
      ;;
    remote-branch)
      git show-ref --verify --quiet "refs/remotes/$remote/$name"
      ;;
    worktree)
      [[ -n "$(_find_worktree "$name")" ]]
      ;;
    remote)
      git remote | grep -q "^$name$"
      ;;
    directory)
      [[ -d "$name" ]]
      ;;
    *)
      err "Invalid existence check type: $type"
      return 2
      ;;
  esac
}

# Optimized worktree finder with caching
_find_worktree() {
  local branch="$1"
  [[ -z "$branch" ]] && return 1

  # Check organized path first (most common case)
  local organized=$(_get_worktree_path "$branch")
  if _exists directory "$organized" && [[ -f "$organized/.git" ]]; then
    echo "$organized"
    return 0
  fi

  # Fallback to git worktree list parsing
  git worktree list --porcelain | awk -v branch="$branch" '
    /^worktree / { path = $2 }
    /^branch / { 
      if ($2 == "refs/heads/" branch) {
        print path
        exit 0
      }
    }
  '
}

# Enhanced branch name validation with better error messages
_validate_branch_name() {
  local branch="$1"

  [[ -n "$branch" ]] || {
    err "Branch name is required"
    return 1
  }

  # Check for invalid patterns
  local invalid_patterns=(
    '^[.-]'           'cannot start with . or -'
    '[.-]$'           'cannot end with . or -'
    '\.\.'            'cannot contain consecutive dots'
    '//'              'cannot contain consecutive slashes'
    '[ ~^:?*\[\]]'    'cannot contain special characters'
    '^$'              'cannot be empty'
  )

  local i
  for (( i = 1; i <= ${#invalid_patterns[@]}; i += 2 )); do
    if [[ "$branch" =~ ${invalid_patterns[i]} ]]; then
      err "Invalid branch name '$branch': ${invalid_patterns[i+1]}"
      return 1
    fi
  done

  return 0
}

# Consolidated validation with operation-specific checks
_validate_operation() {
  local branch="$1" operation="$2"

  _init_git_context || return 1
  _validate_branch_name "$branch" || return 1

  local wt_path=$(_get_worktree_path "$branch")

  case "$operation" in
    create)
      if _exists branch "$branch"; then
        err "Branch '$branch' already exists"
        return 1
      fi
      if _exists directory "$wt_path"; then
        err "Directory '$wt_path' already exists"
        return 1
      fi
      ;;
    switch|remove)
      if ! _exists worktree "$branch"; then
        err "Worktree for branch '$branch' not found"
        return 1
      fi
      ;;
    *)
      err "Invalid operation: $operation"
      return 2
      ;;
  esac

  return 0
}

# Standardized error handling for common scenarios
_handle_directory_error() {
  local operation="$1" target="$2" context="$3"
  
  case "$operation" in
    create)
      err "Failed to create directory: $target${context:+ ($context)}"
      ;;
    access)
      err "Directory does not exist: $target${context:+ ($context)}"
      ;;
    change)
      err "Failed to change to directory: $target${context:+ ($context)}"
      ;;
    *)
      err "Directory operation failed: $target${context:+ ($context)}"
      ;;
  esac
}

# Single line confirmation
_confirm_destructive_action() {
  local branch="$1"
  
  # Skip confirmation if not interactive
  [[ ! -t 0 ]] && return 0

  echo -n "${YELLOW}Delete worktree '${RED}$branch${YELLOW}'? Type '${CYAN}$branch${YELLOW}' to confirm: ${RESET}"
  
  local reply
  read -r reply

  case "$reply" in
    "$branch")
      return 0
      ;;
    *)
      info "Cancelled (must type exact branch name to confirm)"
      return 1
      ;;
  esac
}

# Helper to safely change directory with standardized error handling
_safe_cd() {
  local target="$1" context="$2"

  if ! _exists directory "$target"; then
    _handle_directory_error "access" "$target" "$context"
    return 1
  fi

  if ! cd "$target" 2>/dev/null; then
    _handle_directory_error "change" "$target" "$context"
    return 1
  fi

  return 0
}

# Ensure directory exists with proper error handling
_ensure_directory() {
  local dir="$1" context="$2"
  
  if ! _exists directory "$dir"; then
    if ! mkdir -p "$dir" 2>/dev/null; then
      _handle_directory_error "create" "$dir" "$context"
      return 1
    fi
  fi
  return 0
}

# Check if currently in target worktree
_in_target_worktree() {
  local branch="$1"
  local current_branch=$(_get_current_branch)
  local wt_path=$(_find_worktree "$branch")
  
  [[ "$current_branch" == "$branch" ]] || [[ -n "$wt_path" && "$PWD" == "$wt_path"* ]]
}

# Move to safe location (main repository)
_move_to_safe_location() {
  _init_git_context || return 1
  _safe_cd "${GP[root]}" "main repository" || return 1
  info "Moved to main repository"
}

# Validate remote with helpful error message
_validate_remote() {
  local remote="$1"
  
  if ! _exists remote "$remote"; then
    err "Remote '$remote' does not exist"
    info "Available remotes: $(git remote | tr '\n' ' ')"
    return 1
  fi
  return 0
}

# =============================================================================
# MAIN COMMANDS
# =============================================================================

# Add worktree (improved error handling and atomicity)
gwa() {
  local branch="$1" base_branch="${2:-HEAD}"

  _validate_operation "$branch" create || return 1

  local wt_path=$(_get_worktree_path "$branch")

  # Ensure base directory exists
  _ensure_directory "${GP[wt_base]}" "worktree base" || return 1

  # Create worktree silently and capture HEAD info
  local git_output
  git_output=$(git worktree add -b "$branch" "$wt_path" "$base_branch" 2>&1)
  local exit_code=$?

  if (( exit_code != 0 )); then
    # Cleanup on failure
    _exists directory "$wt_path" && rm -rf "$wt_path"
    err "Failed to create worktree for branch '$branch'"
    return 1
  fi

  # Extract HEAD info from git output
  local head_info=$(echo "$git_output" | grep "HEAD is now at" | head -1)
  
  _safe_cd "$wt_path" "new worktree" || return 1

  # Update current branch cache
  GP[current_branch]="$branch"

  success "Created worktree for branch '$branch'"
  [[ -n "$head_info" ]] && info "$head_info"
  info "Use 'gpush' to push upstream when ready"
}

# Switch worktree
gws() {
  local branch="$1"

  _validate_operation "$branch" switch || return 1

  local wt_path=$(_find_worktree "$branch")
  if [[ -z "$wt_path" ]]; then
    err "Could not locate worktree for branch '$branch'"
    return 1
  fi

  _safe_cd "$wt_path" "worktree for $branch" || return 1
  
  # Update current branch cache
  GP[current_branch]="$branch"
  
  success "Switched to worktree: $branch"
}

# Remove worktree (improved safety and cleanup)
gwr() {
  local branch="$1"

  _validate_operation "$branch" remove || return 1

  # Build removal list with user-friendly paths
  local items=()
  local wt_path=$(_find_worktree "$branch")

  if [[ -n "$wt_path" ]]; then
    # Show relative path or just the worktree name for cleaner output
    local display_path
    if [[ "$wt_path" == "${GP[wt_base]}"/* ]]; then
      # If it's in our standard worktree location, just show the name
      display_path="${GP[name]}-worktree/${wt_path:t}"
    else
      # For non-standard locations, show relative to current directory if possible
      display_path="${wt_path/#$PWD\//./}"
      # If that didn't help, show relative to home
      display_path="${display_path/#$HOME/~}"
    fi
    items+=("Worktree directory: $display_path")
  fi
  
  _exists branch "$branch" && items+=("Local branch: $branch")

  if (( ${#items[@]} == 0 )); then
    warn "Nothing to remove for branch '$branch'"
    return 0
  fi

  _confirm_destructive_action "$branch" "${items[@]}" || return 1

  if _in_target_worktree "$branch"; then
    _move_to_safe_location || return 1
  fi

  if [[ -n "$wt_path" ]] && _git "git worktree remove --force '$wt_path'" "" "" true; then
    info "Removed worktree ${YELLOW}$wt_path${RESET}"
  fi

  if _exists branch "$branch" && _git "git branch -D '$branch'" "" "" true; then
    info "Removed local branch ${YELLOW}$branch${RESET}"
  fi

  success "Cleanup completed for '$branch'"

  # Refresh current branch cache
  GP[current_branch]=$(_get_current_branch)
}

# Push with upstream tracking (enhanced remote handling)
gpush() {
  local remote="${1:-origin}"

  _init_git_context || return 1
  
  local current_branch=$(_get_current_branch)
  if [[ -z "$current_branch" ]]; then
    err "Not currently on any branch (detached HEAD?)"
    return 1
  fi
  
  # Validate remote
  _validate_remote "$remote" || return 1
  
  # Fetch quietly to ensure we have latest remote info
  _git "git fetch -q '$remote'" "Fetched from $remote" "" true || {
    warn "Failed to fetch from remote, continuing anyway..."
  }
  
  # Check if remote branch already exists
  if _exists remote-branch "$current_branch" "$remote"; then
    err "Remote branch '$remote/$current_branch' already exists"
    info "Use: git push $remote $current_branch (to update it)"
    return 1
  fi
  
  # Push with upstream tracking
  _git "git push -u '$remote' '$current_branch'" \
       "Pushed '$current_branch' to '$remote' with tracking"
}

# Enhanced worktree listing with better formatting
gwlist() {
  _init_git_context || return 1

  echo ""
  echo -n "${PACKAGE} ${YELLOW} Repository: ${CYAN}${GP[name]}${RESET}"
  echo ""
  echo -n "${WT_TREE} ${YELLOW} Worktree:   ${CYAN}${GP[wt_base]:t}${RESET}"
  echo ""
  echo ""
  
  # Parse worktree list more robustly
  local -A worktree_info
  local current_path current_commit current_branch
  
  # Use porcelain format for reliable parsing
  while IFS= read -r line; do
    case "$line" in
      "worktree "*)
        current_path="${line#worktree }"
        ;;
      "HEAD "*)
        current_commit="${line#HEAD }"
        ;;
      "branch "*)
        current_branch="${line#branch refs/heads/}"
        # Store complete info when we have all parts
        if [[ -n "$current_path" && -n "$current_commit" && -n "$current_branch" ]]; then
          worktree_info["$current_branch"]="$current_path|$current_commit"
        fi
        ;;
      "bare")
        # Skip bare repositories in listing
        current_path="" current_commit="" current_branch=""
        ;;
      "")
        # Reset for next entry
        current_path="" current_commit="" current_branch=""
        ;;
    esac
  done < <(git worktree list --porcelain)
  
  # Display sorted worktrees
  local branch
  for branch in ${(ko)worktree_info}; do
    local info=(${(s:|:)worktree_info[$branch]})
    local wt_path="$info[1]"
    local commit="$info[2]"
    
    # Current worktree indicator
    local current_indicator=""
    [[ "$PWD" == "$wt_path" ]] && current_indicator=" ${MAGENTA}← current${RESET}"
    
    # Branch-specific icon using constants
    local icon="$WT_DEFAULT"
    case "$branch" in
      main|master) icon="$WT_MAIN" ;;
      develop|dev) icon="$WT_DEVELOP" ;;
      feature/*) icon="$WT_FEATURE" ;;
      hotfix/*) icon="$WT_HOTFIX" ;;
      release/*) icon="$WT_RELEASE" ;;
    esac
    
    # Format the output line
    local wt_name="${wt_path:t}"
    local short_commit="${commit:0:8}"
    echo "  $icon ${BLUE}${wt_name}${RESET} ${YELLOW}${short_commit}${RESET} ${GREEN}$branch${RESET}$current_indicator"
  done
  
  echo
  info "Use 'gws <branch>' to switch worktrees"
}

# Enhanced cleanup with dry-run option
gwclean() {
  local dry_run=false
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        shift
        ;;
      -h|--help)
        echo "Usage: gwclean [-n|--dry-run] [-h|--help]"
        echo "Clean up orphaned worktrees"
        echo "  -n, --dry-run    Show what would be cleaned without doing it"
        return 0
        ;;
      *)
        err "Unknown option: $1"
        return 1
        ;;
    esac
  done
  
  _init_git_context || return 1
  
  # Check what would be pruned
  local prune_output=$(git worktree prune --dry-run 2>/dev/null)
  
  if [[ -z "$prune_output" ]]; then
    success "No orphaned worktrees found"
    return 0
  fi
  
  if [[ "$dry_run" == true ]]; then
    echo "${YELLOW}Would clean:${RESET}"
    echo "$prune_output" | sed 's/^/  /'
    return 0
  fi
  
  echo "${YELLOW}Cleaning orphaned worktrees:${RESET}"
  echo "$prune_output" | sed 's/^/  /'
  
  if _git "git worktree prune" "Cleaned orphaned worktrees"; then
    success "Cleanup completed"
  else
    err "Cleanup failed"
    return 1
  fi
}

gwhelp() {
  echo "${PACKAGE} Git Worktree Manager v${GW_VERSION}"
  echo
  echo "${BLUE}Commands:${RESET}"
  echo "  ${GREEN}gwa <branch> [base]${RESET}    Add new worktree for branch (from base, default: HEAD)"
  echo "  ${GREEN}gws <branch>${RESET}           Switch to existing worktree"
  echo "  ${GREEN}gwr <branch>${RESET}           Remove worktree and branch (with confirmation)"
  echo "  ${GREEN}gpush [remote]${RESET}         Push current branch with upstream tracking (default: origin)"
  echo "  ${GREEN}gwlist${RESET}                 List all worktrees with status"
  echo "  ${GREEN}gwclean [-n]${RESET}           Clean orphaned worktrees (-n for dry-run)"
  echo "  ${GREEN}gwhelp${RESET}                 Show this help message"
  echo
  echo "${BLUE}Environment:${RESET}"
  echo "  ${YELLOW}DEBUG_GW=true${RESET}         Enable debug output"
  echo
  echo "${BLUE}Examples:${RESET}"
  echo "  gwa feature/new-ui              # Create worktree for new branch"
  echo "  gwa hotfix/urgent-fix main      # Create from main branch"
  echo "  gws feature/new-ui              # Switch to existing worktree"
  echo "  gwr old-feature                 # Remove worktree and branch"
  echo "  gpush upstream                  # Push to upstream remote"
  echo
}
