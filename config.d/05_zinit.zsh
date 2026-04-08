#!/bin/zsh -f

# ==============================================================================
# Zinit Configuration optimized for Atuin
# Purpose: Configure Zinit plugins with focus on modern shell experience
# Author: Yago Riveiro
# ==============================================================================

(( ${ZSH_ZINIT_AVAILABLE:-0} )) || return

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

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
    MenkeTechnologies/zsh-cargo-completion

# ------------------------------------------------------------------------------
# Navigation and Utility Enhancements
# Tools for improved navigation and kubernetes aliases
# ------------------------------------------------------------------------------
# zinit wait lucid for \
#     agkozak/zsh-z

# ------------------------------------------------------------------------------
# User Experience
# Plugins for improved command-line experience
# Note: Order matters for these plugins
# ------------------------------------------------------------------------------
zinit wait lucid for \
    zsh-users/zsh-history-substring-search \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        zdharma-continuum/fast-syntax-highlighting
