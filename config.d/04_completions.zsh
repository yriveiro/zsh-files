#!/bin/zsh -f

# ==============================================================================
# Custom Completions Loader
# Purpose: Add custom completions directory to fpath before zinit loads
# Author: Yago Riveiro
# ==============================================================================

# Add custom completions directory to fpath
# This must be done before zinit calls zicompinit
fpath+=("${HOME}/.config/zsh/completions")
