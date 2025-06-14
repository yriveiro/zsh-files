#!/bin/zsh -f

# ==============================================================================
# Common Aliases Configuration
# Purpose: Define common shell aliases shared across platforms
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Shell Navigation and Basic Commands
# ------------------------------------------------------------------------------
# Basic shell navigation and command shortcuts for improved productivity.
# These aliases provide shorter commands for frequently used operations.
#
# ALIASES:
#   c, cls          Clear terminal screen (alternative to 'clear')
#   __, vim         Open Neovim editor (modernized Vim alternative)
#   :q              Exit shell (Vim-style quit command)
#   ..              Navigate to parent directory
#
# USAGE EXAMPLES:
#   $ c              # Clear screen
#   $ __ file.txt    # Open file in Neovim
#   $ :q             # Exit current shell
#   $ ..             # Move up one directory level
#
# NOTES:
#   - 'cls' provides Windows-style clear command compatibility
#   - '__' offers a quick two-character editor shortcut
#   - ':q' enables Vim users to exit shell using familiar command
# ------------------------------------------------------------------------------
alias c="clear"
alias cls="clear"
alias __="nvim"
alias vim="nvim"
alias :q="exit"
alias ..="cd .."

# ------------------------------------------------------------------------------
# File Listing Enhancements
# ------------------------------------------------------------------------------
# Modern alternatives to the traditional 'ls' command using eza (formerly exa).
# These aliases provide enhanced file listing with icons, colors, and tree views.
#
# REQUIREMENTS:
#   - eza command must be installed and available in PATH
#   - Terminal must support icons and colors for optimal display
#
# ALIASES:
#   l               Long format listing with icons
#   la              Long format listing including hidden files with icons
#   ll              Tree view with 2 levels depth and icons
#   lll             Tree view with 3 levels depth and icons
#
# USAGE EXAMPLES:
#   $ l              # List files in long format with icons
#   $ la             # List all files including hidden ones
#   $ ll             # Show directory tree (2 levels deep)
#   $ lll            # Show directory tree (3 levels deep)
#
# FEATURES:
#   - Icons for different file types and folders
#   - Color-coded output for better readability
#   - Tree structure visualization for directory hierarchies
#   - Conditional loading only if eza is available
#
# FALLBACK:
#   If eza is not installed, these aliases are not created and the system
#   will fall back to the standard 'ls' command behavior.
# ------------------------------------------------------------------------------
if command eza &> /dev/null; then
    alias l="eza -l --icons"
    alias la="eza -la --icons"
    alias ll="eza -l -L=2 -T --icons"
    alias lll="eza -l -L=3 -T --icons"
fi

# ------------------------------------------------------------------------------
# Git Aliases
# ------------------------------------------------------------------------------
# Shortcuts for common git operations to improve development workflow efficiency.
# These aliases cover the most frequently used git commands with shorter syntax.
#
# BASIC GIT ALIASES:
#   g               Short alias for 'git' command
#   gst             Git status (show working tree status)
#   gpl             Git pull (fetch and merge from remote)
#   gps             Git push (upload local changes to remote)
#
# ADVANCED GIT ALIASES:
#   gap             Git add all changes in current directory (git ap .)
#   gci             Git commit with GPG signing and message prompt
#   gitstamp        Apply local git configuration from ~/.localgit.cfg
#
# GIT WORKTREE ALIASES:
#   gw              Git worktree (manage multiple working trees)
#   gwl             Git worktree list (show all worktrees)
#
# EXTERNAL TOOLS:
#   lg              Launch lazygit with custom configuration directory
#
# USAGE EXAMPLES:
#   $ g status       # Equivalent to 'git status'
#   $ gap            # Stage all changes
#   $ gci "fix bug"  # Commit with GPG signature and message
#   $ gpl            # Pull latest changes
#   $ gps            # Push local commits
#   $ gwl            # List all git worktrees
#   $ lg             # Open lazygit interface
#
# NOTES:
#   - 'gci' creates signed commits using GPG (-S flag)
#   - 'gitstamp' applies personal git configuration for the current repository
#   - 'lg' requires lazygit to be installed and configured
#   - Git worktree commands help manage multiple branches simultaneously
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
# ------------------------------------------------------------------------------
# Quick reload of shell configuration without restarting the terminal session.
#
# ALIAS:
#   reload          Source ~/.zshrc to reload ZSH configuration
#
# USAGE:
#   $ reload         # Reload ZSH configuration immediately
#
# BENEFITS:
#   - Apply configuration changes without opening a new terminal
#   - Test new aliases and functions immediately
#   - Useful during shell configuration development and debugging
#
# NOTES:
#   - Sources the main ZSH configuration file (~/.zshrc)
#   - All exported variables and functions will be refreshed
#   - History and current directory are preserved
# ------------------------------------------------------------------------------
alias reload="source ~/.zshrc"

# ------------------------------------------------------------------------------
# Development Tool Aliases
# ------------------------------------------------------------------------------
# Conditional shortcuts for various development tools. These aliases are only
# created if the corresponding tools are installed and available in the system.
# This approach ensures compatibility across different development environments.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Terraform Infrastructure Management Aliases
# ------------------------------------------------------------------------------
# Shortcuts for HashiCorp Terraform infrastructure as code operations.
# These aliases streamline common Terraform workflow commands.
#
# REQUIREMENTS:
#   - Terraform must be installed and available in PATH
#
# ALIASES:
#   tf              Short alias for 'terraform' command
#   tfv             Terraform validate (check configuration syntax)
#   tfp             Terraform plan (preview infrastructure changes)
#   tfa             Terraform apply (execute infrastructure changes)
#   tfc             Terraform console (interactive expression evaluation)
#
# USAGE EXAMPLES:
#   $ tf init        # Initialize Terraform working directory
#   $ tfv            # Validate configuration files
#   $ tfp            # Preview planned changes
#   $ tfa            # Apply changes to infrastructure
#   $ tfc            # Open Terraform console for testing expressions
#
# WORKFLOW:
#   Typical Terraform workflow: tf init → tfv → tfp → tfa
#
# NOTES:
#   - Always run 'tfv' before 'tfp' to catch syntax errors early
#   - Review 'tfp' output carefully before running 'tfa'
#   - 'tfc' is useful for debugging complex expressions and functions
# ------------------------------------------------------------------------------
if command terraform -version &> /dev/null; then
    alias tf="terraform"
    alias tfv="terraform validate"
    alias tfp="terraform plan"
    alias tfa="terraform apply"
    alias tfc="terraform console"
fi

# ------------------------------------------------------------------------------
# Kubernetes Container Orchestration Aliases
# ------------------------------------------------------------------------------
# Essential shortcuts for Kubernetes cluster management and application deployment.
# These aliases cover the most common kubectl operations for daily development work.
#
# REQUIREMENTS:
#   - kubectl must be installed and configured with cluster access
#
# CORE KUBECTL ALIASES:
#   k               Short alias for 'kubectl' command
#   ka              Kubectl apply (create/update resources from files)
#   kc              Kubectl create (create resources)
#   kg              Kubectl get (list resources)
#   kl              Kubectl logs (view container logs)
#   kr              Kubectl delete (remove resources)
#
# CONTEXT SWITCHING ALIASES:
#   kctx            Switch between Kubernetes contexts (requires switcher)
#   kns             Switch between Kubernetes namespaces (requires switcher)
#
# USAGE EXAMPLES:
#   $ k get pods           # List all pods in current namespace
#   $ ka deployment.yaml   # Apply deployment configuration
#   $ kl my-pod           # View logs from specific pod
#   $ kg svc              # List all services
#   $ kctx production     # Switch to production context
#   $ kns kube-system     # Switch to kube-system namespace
#
# NOTES:
#   - Context switching aliases require the 'switcher' tool to be installed
#   - Always verify current context before applying changes to avoid accidents
#   - Use namespaces to organize and isolate resources effectively
# ------------------------------------------------------------------------------
if command kubectl &> /dev/null; then
    alias k="kubectl"
    alias ka="kubectl apply"
    alias kc="kubectl create"
    alias kg="kubectl get"
    alias kl="kubectl logs"
    alias kr="kubectl delete"
fi

if command switcher -v &> /dev/null; then
    alias kctx="switcher"
    alias kns="switcher namespace"
fi

# ------------------------------------------------------------------------------
# Terminal Multiplexer (tmux) Aliases
# ------------------------------------------------------------------------------
# Convenient shortcuts for tmux session management and terminal multiplexing.
# These aliases simplify common tmux operations for improved productivity.
#
# REQUIREMENTS:
#   - tmux must be installed and available in PATH
#
# ALIASES:
#   mu              Short alias for 'tmux' command
#   mua             Tmux attach (connect to existing session)
#   muls            Tmux list sessions (show all active sessions)
#
# USAGE EXAMPLES:
#   $ mu new -s work      # Create new session named 'work'
#   $ mua -t work         # Attach to 'work' session
#   $ muls                # List all tmux sessions
#   $ mua                 # Attach to most recent session
#
# WORKFLOW:
#   Common tmux workflow: mu (create) → detach → mua (reattach)
#
# NOTES:
#   - Sessions persist even when terminal is closed
#   - Use descriptive session names for better organization
#   - Tmux allows multiple terminals within a single session
#   - Sessions can be shared between different terminal windows
# ------------------------------------------------------------------------------
if command tmux -V &> /dev/null; then
    alias mu="tmux"
    alias mua="tmux attach"
    alias muls="tmux ls"
fi

# ------------------------------------------------------------------------------
# Security and Utility Aliases
# ------------------------------------------------------------------------------
# Specialized aliases for security tools and common utility operations.
# These shortcuts improve workflow efficiency for security and file management tasks.
#
# YUBIKEY SECURITY ALIASES:
#   yubikey-scan    Refresh YubiKey GPG card detection and key learning
#
# DIRECTORY SHORTCUTS:
#   dump            Quick navigation to ~/Dump directory
#
# USAGE EXAMPLES:
#   $ yubikey-scan        # Reconnect and refresh YubiKey GPG functionality
#   $ dump                # Navigate to dump/temporary files directory
#
# YUBIKEY FUNCTIONALITY:
#   The yubikey-scan alias performs two operations:
#   1. 'scd serialno' - Connects to the smart card daemon and reads serial number
#   2. 'learn --force' - Forces GPG to relearn all keys from the card
#
# NOTES:
#   - yubikey-scan is useful when YubiKey stops responding or after reconnection
#   - dump directory is typically used for temporary files and downloads
#   - GPG operations may require YubiKey PIN entry
#   - Smart card operations require gpg-agent to be running
# ------------------------------------------------------------------------------
alias yubikey-scan="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"
