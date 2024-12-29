#!/bin/zsh -f
# ==============================================================================
# Common Aliases Configuration
# Purpose: Define common shell aliases shared across platforms
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Shell Navigation and Basic Commands
# Basic shell navigation and command shortcuts
# ------------------------------------------------------------------------------
alias c="clear"
alias cls="clear"
alias __="nvim"
alias vim="nvim"
alias :q="exit"
alias ..="cd .."

# ------------------------------------------------------------------------------
# File Listing Enhancements
# Modern alternatives to ls command using exa if available
# ------------------------------------------------------------------------------
if command exa &> /dev/null; then
    alias l="exa -l --icons"
    alias la="exa -la --icons"
    alias ll="exa -l -L=2 -T --icons"
    alias lll="exa -l -L=3 -T --icons"
fi

# ------------------------------------------------------------------------------
# Git Aliases
# Shortcuts for common git operations
# ------------------------------------------------------------------------------
alias g="git"
alias gap="git ap ."
alias gci="git ci -S -m "
alias gitstamp="cat ~/.localgit.cfg > .git/config"
alias gpl="git pull"
alias gps="git push"
alias gst="git st"
alias gw="git worktree"
alias gwl="git worktree list"
alias lg="lazygit --use-config-dir ${HOME}/.config/lazygit/"

# ------------------------------------------------------------------------------
# Configuration Reload
# Quick reload of shell configuration
# ------------------------------------------------------------------------------
alias reload="source ~/.zshrc"

# ------------------------------------------------------------------------------
# Development Tool Aliases
# Shortcuts for various development tools when available
# ------------------------------------------------------------------------------
# Terraform shortcuts
if command terraform -version &> /dev/null; then
    alias tfv="terraform validate"
    alias tfp="terraform plan"
    alias tfa="terraform apply"
    alias tfc="terraform console"
fi

# Kubernetes shortcuts
if command kubectl &> /dev/null; then
    alias k="kubectl"
    alias ka="kubectl apply"
    alias kc="kubectl create"
    alias kg="kubectl get"
    alias kl="kubectl logs"
    alias kr="kubectl delete"
fi

# tmux shortcuts
if command tmux -V &> /dev/null; then
    alias mu="tmux"
    alias mua="tmux attach"
    alias muls="tmux ls"
fi

# Minikube shortcuts
if command minikube &> /dev/null; then
    alias mk="minikube kubectl --"
fi

# YubiKey utilities
alias yubikey-scan="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"
