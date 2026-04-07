#!/bin/zsh -f

# ==============================================================================
# ZSH Darwin Environment Configuration
# Purpose: Configure environment variables specific to macOS
# Author: Yago Riveiro
# ==============================================================================

# Skip if not running on Darwin
[[ "${OSTYPE}" == "darwin"* ]] || return

# Remove duplicates in these arrays before any PATH mutations
typeset -U path cdpath fpath manpath

# Static Homebrew prefix selection
if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
else
    export HOMEBREW_PREFIX="/usr/local"
fi

# ------------------------------------------------------------------------------
# Development Root Directory
# ------------------------------------------------------------------------------
export DEV_ROOT="${HOME}/Development"

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# 
# This configurations is troublesome.
#
# Get Homebrew prefix for consistent path references
# HOMEBREW_PREFIX="$(/opt/homebrew/bin/brew --prefix)"
# Configure dynamic library path for macOS
export DYLD_LIBRARY_PATH=${HOMEBREW_PREFIX}/lib:${DYLD_LIBRARY_PATH}

# ------------------------------------------------------------------------------
# Development Tools Configuration
# ------------------------------------------------------------------------------
# Rust configuration
export RUST_SRC_PATH="/usr/local/src/rustc/src"

# LSP configuration
export JDTLS_HOME="${HOME}/.local/share/nvim/mason/packages/jdtls"

# ------------------------------------------------------------------------------
# PATH Configuration
# ------------------------------------------------------------------------------
# Define additional PATH entries
PATH_ADDITIONS=(
    "${HOMEBREW_PREFIX}/bin"                       # Brew
    "${HOMEBREW_PREFIX}/opt/gnu-getopt/bin"        # GNU getopt
    "${HOMEBREW_PREFIX}/opt/php@8.3/bin"           # PHP
    "${HOMEBREW_PREFIX}/opt/php@8.3/sbin"           # PHP
    "${HOME}/.krew/bin"                            # Kubernetes krew plugin
    "${HOME}/.local/bin"                           # User local binaries
    "/usr/local/bin/go"                            # Go binary
)
# Prepend PATH_ADDITIONS to path array
path=("${PATH_ADDITIONS[@]}" $path)

# ------------------------------------------------------------------------------
# External Services Configuration
# ------------------------------------------------------------------------------
# Configure Ollama API endpoint for AI model interactions
export OLLAMA_API_BASE=https://ollama.4425017.work

# Configure Docker to use Colima runtime instead of Docker Desktop
export DOCKER_HOST=unix:///Users/yagoriveiro/.colima/default/docker.sock

export OPENCODE_EXPERIMENTAL=true
