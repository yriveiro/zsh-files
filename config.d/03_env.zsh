#!/bin/zsh -f

# ==============================================================================
# ZSH Common Environment Configuration
# Purpose: Configure common environment variables for all platforms
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Global Environment Variables
# These settings apply to all platforms
# ------------------------------------------------------------------------------
# Define colors for ls command output
export LSCOLORS='exfxcxdxbxegedabagacad'
# Enable color support in terminal
export CLICOLOR=true
# Set neovim as the default editor
export EDITOR=nvim
# Configure gpg agent to handle ssh keys
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# Set GPG TTY for GPG key operations
export GPG_TTY=$(tty)
# Set locale settings for consistent UTF-8 encoding
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# HACK: Python setuptools configuration hack for >=3.11 compiled packages
export SETUPTOOLS_USE_DISTUTILS=local
# Prevent automatic updates during package install
export HOMEBREW_NO_AUTO_UPDATE=1
# Use bat for brew info/cat if available
export HOMEBREW_BAT=1


# ------------------------------------------------------------------------------
# Common Development Paths
# These paths are common across platforms but use platform-specific base dirs
# ------------------------------------------------------------------------------
# Set Go workspace directory
export GOPATH="${DEV_ROOT}/go"
# Add Go binary directory to PATH
export PATH="${GOPATH}/bin:${PATH}"

# ------------------------------------------------------------------------------
# Conditional Tool Configurations
# Only set if specific tools are installed
# ------------------------------------------------------------------------------
# Configure .NET if installed
if command -v dotnet &> /dev/null; then
    export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
fi
