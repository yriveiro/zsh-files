#!/bin/zsh -f

# ==============================================================================
# ZSH Linux Environment Configuration
# Purpose: Configure environment variables specific to Linux
# Author: Yago Riveiro
# ==============================================================================

# Skip if not running on Linux
[[ "${OSTYPE}" == "linux"* ]] || return

# ------------------------------------------------------------------------------
# Development Root Directory
# ------------------------------------------------------------------------------
export DEV_ROOT="/data/Development"

# ------------------------------------------------------------------------------
# Development Tools Configuration
# ------------------------------------------------------------------------------
# Java configuration
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
# Docker configuration
export DOCKER_DEFAULT_PLATFORM="linux/amd64"

# ------------------------------------------------------------------------------
# PATH Configuration
# ------------------------------------------------------------------------------
# Define additional PATH entries
PATH_ADDITIONS=(
    "/usr/local/go/bin" # Go binary
)

# Add kubebuilder to PATH if directory exists
[[ -d "/usr/local/kubebuilder/bin" ]] && PATH_ADDITIONS+=("/usr/local/kubebuilder/bin")

# Join array elements with ':' and add to PATH
export PATH="${PATH}:${(j/:/)PATH_ADDITIONS}"
