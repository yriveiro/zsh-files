#!/bin/zsh -f

# ==============================================================================
# Docker Completion Configuration
# Purpose: Configure completion settings for Docker commands and subcommands
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Docker Command Completion Settings
# Configure completion behavior for docker commands and their options
# ------------------------------------------------------------------------------

# Enable option stacking for all docker-related commands
# This allows combining multiple options (e.g., 'docker run -it')
zstyle ':completion:*:docker-*:*' option-stacking yes

# Force list display for docker commands
# Shows all available options even when there's only one match
zstyle ':completion:*:docker:*' force-list always

# Enable option stacking for docker base command
# Consistent with docker-* subcommands behavior
zstyle ':completion:*:docker:*:' option-stacking yes

# Remove trailing whitespace from docker completions
zstyle ':completion:*:docker:*' squeeze-slashes true

# Group docker completions by type
zstyle ':completion:*:docker:*' group-name docker

# Add descriptions to docker completion options
zstyle ':completion:*:docker:*' description true
