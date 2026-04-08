#!/bin/zsh -f

# ==============================================================================
# Custom Completions Loader
# Purpose: Add custom completions directory to fpath before zinit loads
# Author: Yago Riveiro
# ==============================================================================

fpath+=("${ZSH_CONFIG_ROOT:-${HOME}/.config/zsh}/completions")
