#!/bin/zsh -f

# ==============================================================================
# ZSH Darwin Environment Configuration
# Purpose: Configure environment variables specific to macOS
# Author: Yago Riveiro
# ==============================================================================

# Skip if not running on Darwin
[[ "${OSTYPE}" == "darwin"* ]] || return

# ------------------------------------------------------------------------------
# Development Root Directory
# ------------------------------------------------------------------------------
export DEV_ROOT="${HOME}/Development"

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Get Homebrew prefix for consistent path references
HOMEBREW_PREFIX="$(brew --prefix)"
# Configure dynamic library path for macOS
export DYLD_LIBRARY_PATH="${HOMEBREW_PREFIX}/lib:${DYLD_LIBRARY_PATH}"

# ------------------------------------------------------------------------------
# Development Tools Configuration
# ------------------------------------------------------------------------------
# Rust configuration
export RUST_SRC_PATH="/usr/local/src/rustc/src"
# Java configuration
export JAVA_HOME="${HOMEBREW_PREFIX}/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
# LSP configuration
export JDTLS_HOME="${HOME}/.local/share/nvim/lsp_servers/jdtls"

# ------------------------------------------------------------------------------
# PATH Configuration
# ------------------------------------------------------------------------------
# Define additional PATH entries
PATH_ADDITIONS=(
    "/usr/local/bin/go"                            # Go binary
    "${HOMEBREW_PREFIX}/opt/gnu-getopt/bin"        # GNU getopt
    "${HOME}/.krew/bin"                            # Kubernetes krew plugin
    "${HOME}/.local/bin"                           # User local binaries
)
# Join array elements with ':' and add to PATH
export PATH="${(j/:/)PATH_ADDITIONS}:${PATH}"
