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
# Python setuptools compatibility for >=3.11 compiled packages
export SETUPTOOLS_USE_DISTUTILS=local
# Prevent automatic updates during package install
export HOMEBREW_NO_AUTO_UPDATE=1
# Use bat for brew info/cat if available
export HOMEBREW_BAT=1

# ------------------------------------------------------------------------------
# Telemetry / Analytics Disable Flags
# Disable telemetry for various tools
# ------------------------------------------------------------------------------
export LIGHTPANDA_DISABLE_TELEMETRY=true


# ------------------------------------------------------------------------------
# Common Tool Initialization
# Initialize shared prompt, history, navigation, and runtime helpers
# ------------------------------------------------------------------------------
_zsh_eval_init() {
    local tool="$1"
    shift

    (( ${+commands[$tool]} )) || return 0
    eval "$("${tool}" "$@")"
}

export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

_zsh_eval_init starship init zsh
_zsh_eval_init atuin init zsh
_zsh_eval_init zoxide init zsh --cmd j

if (( ${+commands[switcher]} )); then
    # Defer switcher setup until the first `switch` invocation.
    switch() {
        unset -f switch
        eval "$(switcher init zsh)"
        switch "$@"
    }
fi

export SDKMAN_DIR="${HOME}/.sdkman"
if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    # Defer sdkman until the first explicit `sdk` invocation.
    sdk() {
        unset -f sdk
        source "${SDKMAN_DIR}/bin/sdkman-init.sh"
        sdk "$@"
    }
fi

export BUN_INSTALL="${HOME}/.bun"
[[ -s "${BUN_INSTALL}/_bun" ]] && source "${BUN_INSTALL}/_bun"
path=("${BUN_INSTALL}/bin" $path)

unfunction _zsh_eval_init


# ------------------------------------------------------------------------------
# Common Development Paths
# These paths are common across platforms but use platform-specific base dirs
# ------------------------------------------------------------------------------
export DEV_ROOT="${DEV_ROOT:-${HOME}/Development}"

# Set Go workspace directory
export GOPATH="${DEV_ROOT}/go"
# Add Go binary directory to path array
path=("${GOPATH}/bin" $path)

# ------------------------------------------------------------------------------
# Conditional Tool Configurations
# Only set if specific tools are installed
# ------------------------------------------------------------------------------
# Configure .NET if installed
if (( ${+commands[dotnet]} )); then
    export DOTNET_ROOT="${HOMEBREW_PREFIX}/opt/dotnet/libexec"
fi
