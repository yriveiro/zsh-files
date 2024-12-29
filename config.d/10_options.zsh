#!/bin/zsh -f

# Remove duplicates in these arrays
typeset -U path cdpath fpath manpath

####################
# Input/Terminal Control
####################
setopt noflowcontrol     # Disable flow control (ctrl-s/ctrl-q)
setopt nobeep           # No beeping
setopt interactivecomments # Allow comments in interactive shells
setopt prompt_subst     # Allow substitution in prompt

####################
# History (Atuin Optimized)
####################
setopt extended_history    # Save timestamp and duration
setopt inc_append_history  # Write immediately, better for Atuin integration
setopt hist_verify        # Don't execute immediately upon history expansion

####################
# Directory Navigation
####################
setopt auto_cd            # Auto change to a dir without typing cd
setopt auto_pushd         # Make cd push the old directory onto the stack
setopt pushd_ignore_dups  # Don't push multiple copies
setopt pushd_minus        # Exchanges meanings of +/- when using cd -/+N
setopt pushd_silent       # Don't print directory stack after pushd/popd

####################
# Completion
####################
setopt hash_list_all      # Hash entire command path first
setopt completeinword     # Allow completion from within a word
setopt always_to_end      # Move cursor to end of word after completion
setopt auto_menu          # Show completion menu on successive tab press
setopt auto_list          # Automatically list choices on ambiguous completion
setopt auto_param_slash   # If completed parameter is a directory, add a trailing slash
setopt no_list_beep       # Don't beep on an ambiguous completion

####################
# Globbing and Files
####################
setopt extended_glob      # Use extended globbing syntax
setopt nonomatch         # Try to avoid 'no matches found...'
setopt noglobdots        # Don't match dotfiles without explicit dot
setopt numeric_glob_sort  # Sort filenames numerically when relevant
setopt rm_star_wait      # 10 second wait if you do 'rm *'
setopt noshwordsplit     # Use zsh style word splitting

####################
# Job Control
####################
setopt longlistjobs      # Display PID when suspending processes
setopt notify            # Report status of background jobs immediately
setopt auto_resume       # Attempt to resume existing job before creating new one

####################
# Error Prevention & Safety
####################
setopt unset             # Don't error out when unset parameters are used
setopt no_clobber       # Don't overwrite files with > (use >! to override)
setopt path_dirs        # Perform path search even on command names with slashes
