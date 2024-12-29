#!/bin/zsh -f

# ==============================================================================
# ZSH Common Completion Configuration
# Purpose: Define common completion settings shared across platforms
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Core Completion Settings
# Basic settings for how completions behave
# ------------------------------------------------------------------------------
# Enable completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion"

# Completion menu behavior
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' menu yes select interactive
zstyle ':completion:*' show-completer true  # Show message while waiting
zstyle ':completion:*' verbose true         # Provide verbose completion information
zstyle ':completion:*' insert-tab false     # Don't insert tab when empty
zstyle ':completion:*' accept-exact-dirs true  # No parent path completion for existing dirs

# ------------------------------------------------------------------------------
# Completion Matching and Grouping
# Configure how completions are matched and grouped
# ------------------------------------------------------------------------------
# Smart matching including dashed values
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Fuzzy matching of completions
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3)) numeric)'

# Grouping and formatting
zstyle ':completion:*' group-name ''        # Group matches by category
zstyle ':completion:*:matches' group 'yes'  # Group matches and describe
zstyle ':completion:*' list-dirs-first true # Separate directories from files

# ------------------------------------------------------------------------------
# Visual Formatting
# Configure the appearance of completions
# ------------------------------------------------------------------------------
# Formatting messages and descriptions
zstyle ':completion:*:messages' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# Colors in completion menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Prettier process selection
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:*:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# ------------------------------------------------------------------------------
# Directory Navigation
# Settings specific to directory navigation
# ------------------------------------------------------------------------------
# cd command completion behavior
zstyle ':completion:*:*:cd:*:directory-stack' force-list always
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select=0 search

# Pagination prompts
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# ------------------------------------------------------------------------------
# Man Page Completion
# Configure how man page completions are displayed
# ------------------------------------------------------------------------------
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# ------------------------------------------------------------------------------
# Search and Filter Settings
# Configure search behavior in completions
# ------------------------------------------------------------------------------
zstyle ':filter-select:highlight' matched fg=red
zstyle ':filter-select' max-lines 1000
zstyle ':filter-select' rotate-list yes
zstyle ':filter-select' case-insensitive yes

# Exclude /etc/hosts from hostname completion
zstyle -e ':completion:*' hosts 'reply=()'

# Show message for ignored matches
zstyle ':completion:*' single-ignored show

# Automatically update PATH entries
zstyle ':completion:*' rehash true
