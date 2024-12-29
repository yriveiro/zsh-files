#!/bin/zsh -f

# ==============================================================================
# Zinit Configuration optimized for Atuin
# Purpose: Configure Zinit plugins with focus on modern shell experience
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Core Annexes
# These are required for Zinit's extended functionality
# ------------------------------------------------------------------------------
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

# ------------------------------------------------------------------------------
# Core Functionality and Completions
# Essential completion systems and custom completions
# ------------------------------------------------------------------------------
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zsh-users/zsh-completions \
        yriveiro/zsh-completions

# ------------------------------------------------------------------------------
# Development Tool Completions
# Completions for specific development tools
# ------------------------------------------------------------------------------
zinit wait lucid as"completion" for \
    dwaynebradley/k3d-oh-my-zsh-plugin \
    MenkeTechnologies/zsh-cargo-completion \
    sudosubin/zsh-poetry

# ------------------------------------------------------------------------------
# Cloud Tool Completions
# Completions for cloud-related tools
# ------------------------------------------------------------------------------
zinit wait lucid for \
    atinit"autoload -Uz bashcompinit && bashcompinit" \
    'https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion'

# ------------------------------------------------------------------------------
# Navigation and Utility Enhancements
# Tools for improved navigation and kubernetes aliases
# ------------------------------------------------------------------------------
zinit wait lucid for \
    agkozak/zsh-z

# ------------------------------------------------------------------------------
# User Experience
# Plugins for improved command-line experience
# Note: Order matters for these plugins
# ------------------------------------------------------------------------------
zinit wait lucid for \
    zsh-users/zsh-history-substring-search \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting
