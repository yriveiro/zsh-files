#!/bin/zsh -f

# Define a global associative array for key mappings
typeset -g -A key

# Standard terminal key bindings
# Delete key - removes character under cursor
bindkey "^[[3~" delete-char

# Home key - moves cursor to beginning of line
# Supports multiple terminal escape sequences
bindkey "^[[H" beginning-of-line   # xterm
bindkey "^[[1~" beginning-of-line  # vt100

# End key - moves cursor to end of line
# Supports multiple terminal escape sequences
bindkey "^[[F" end-of-line   # xterm
bindkey "^[[4~" end-of-line  # vt100

# Custom word navigation
bindkey "^L" backward-word  # Ctrl+L moves cursor one word left
bindkey "^P" forward-word   # Ctrl+P moves cursor one word right

# Function key
bindkey "^[[24~" delete-word  # F12 deletes word under/after cursor
