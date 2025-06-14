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
# ------------------------------------------------------------------------------
# Configuration Editor Function
# ------------------------------------------------------------------------------
# This function provides quick access to edit configuration files for different
# contexts stored in the ~/.config directory structure.
#
# USAGE:
#   ec <context_name>    Edit configuration files for the specified context
#
# FEATURES:
#   - Validates context directory existence before opening
#   - Changes to the context directory for proper file navigation
#   - Opens nvim editor with full directory context
#   - Comprehensive error handling with colored messages
#
# ENVIRONMENT:
#   Expects configuration directories to be organized under:
#   ~/.config/<context_name>/
#
# EXAMPLES:
#   $ ec nvim           # Edit Neovim configuration files
#   $ ec zsh            # Edit ZSH configuration files
#   $ ec tmux           # Edit Tmux configuration files
#
# ERROR HANDLING:
#   - Returns 1 if no context name provided
#   - Returns 1 if context directory doesn't exist
#   - Returns 1 if directory change fails
#   - Returns 1 if nvim fails to open
#
# NOTES:
#   - Runs in a subshell to avoid changing current working directory
#   - Uses colored output for error messages via shared color configuration
# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------
# Git Bare Repository Patch Function
# ------------------------------------------------------------------------------
# This function configures a git repository to fetch all remote branch references,
# which is particularly useful for bare repositories or repositories that need
# to track all remote branches.
#
# USAGE:
#   patch_bare          Configure current repository to fetch all remote refs
#
# FEATURES:
#   - Validates that current directory is a git repository
#   - Configures remote.origin.fetch to include all remote branches
#   - Provides informative success and error messages
#   - Safe execution with proper error handling
#
# CONFIGURATION:
#   Sets git config: remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
#   This allows fetching all remote branches into local remote-tracking branches
#
# EXAMPLES:
#   $ cd my-git-repo
#   $ patch_bare        # Configure repository to fetch all remote branches
#   ✓ Patch repository /path/to/my-git-repo
#
# ERROR HANDLING:
#   - Returns 1 if not executed within a git repository
#   - Returns 1 if git config command fails
#
# NOTES:
#   - Must be executed from within a git repository working tree
#   - Modifies git configuration for the current repository only
#   - Particularly useful for maintaining comprehensive remote branch tracking
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Wezterm Workspace Rename Function
# ------------------------------------------------------------------------------
# This function provides a convenient interface to rename the current Wezterm
# workspace with proper error handling and user feedback.
#
# USAGE:
#   wtr <workspace_name>    Rename current Wezterm workspace
#
# FEATURES:
#   - Validates workspace name is provided
#   - Uses Wezterm CLI to perform the rename operation
#   - Provides success confirmation with colored output
#   - Comprehensive error handling for failed operations
#
# REQUIREMENTS:
#   - Must be running within a Wezterm terminal session
#   - Wezterm CLI must be available in PATH
#
# EXAMPLES:
#   $ wtr development      # Rename workspace to "development"
#   ✓ Wezterm workspace renamed to development
#   
#   $ wtr "my project"     # Rename workspace with spaces
#   ✓ Wezterm workspace renamed to my project
#
# ERROR HANDLING:
#   - Returns 1 if no workspace name provided
#   - Returns 1 if Wezterm CLI command fails
#
# NOTES:
#   - Workspace name can contain spaces and special characters
#   - Changes are immediate and affect the current terminal session
#   - Uses colored output for success messages via shared color configuration
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# UV Virtual Environment Management Function
# ------------------------------------------------------------------------------
# This function extends the standard UV command with enhanced shell capabilities
# for more intuitive virtual environment management.
#
# USAGE:
#   uv shell                Create/activate a virtual environment in .venv
#   uv [standard commands]  Pass through to standard UV functionality
#
# FEATURES:
#   - Automatically creates .venv if it doesn't exist
#   - Smart activation with project-based prompt customization
#   - Clean deactivation with ctrl+d
#   - Visual emoji indicators for each operation
#
# ENVIRONMENT:
#   Sets the following environment variables when activated:
#   - VIRTUAL_ENV: Path to the activated virtual environment
#   - VIRTUAL_ENV_PROMPT: Custom prompt showing project name and Python version
#
# EXAMPLES:
#   $ cd my-project
#   $ uv shell           # Creates and activates .venv with custom prompt
#   🐍 my-project-py3.10 $ # Now in the virtual environment
#   🐍 my-project-py3.10 $ # Press ctrl+d to exit
#   $ # Back to normal prompt
#
#   $ uv pip install requests  # Standard UV command passthrough
#
# NOTES:
#   - Uses bash emulation for activation, compatible with various shells
#   - Project name is derived from the current directory
#   - Automatically cleans up environment variables on exit
# ------------------------------------------------------------------------------
function uv() {
    if [[ "$1" == "shell" ]]; then
        local venv_path=".venv"
        local project_name=${PWD##*/}  # Extract current directory name
        # Check if .venv directory exists
        if [[ ! -d "$venv_path" ]]; then
            # Create new virtual environment if it doesn't exist
            echo "🔧 Creating new virtual environment..."
            command uv venv "$venv_path"
        fi
        # Check if .venv directory exists
        if [[ -d "$venv_path" ]]; then
            # Activate existing virtual environment using bash emulation
            echo "🚀 Activating virtual environment at $venv_path"
            # Print deactivation instructions
            echo "💡 To deactivate, hit ctrl + d"
            # Get Python version
            local py_version=$($venv_path/bin/python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
            # Export these variables to the new shell
            export VIRTUAL_ENV="$PWD/$venv_path"
            export VIRTUAL_ENV_PROMPT="🐍 $project_name-py$py_version"
            # Activate and spawn new shell
            $SHELL -c "emulate bash -c '. $venv_path/bin/activate'; exec $SHELL"
            # After hit ctrl + d, clean up the prompt
            if [[ -n "$VIRTUAL_ENV" ]]; then 
                echo "👋 Deactivated virtual environment"
                unset VIRTUAL_ENV
                unset VIRTUAL_ENV_PROMPT
            fi
        else
            echo "❌ Failed to create virtual environment at $venv_path"
        fi
    else
        # Forward all other commands to the actual uv command
        echo "⚡ Running uv command..."
        command uv "$@"
    fi
}
