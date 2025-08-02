#!/bin/zsh -f

# ==============================================================================
# macOS-specific Aliases Configuration
# Purpose: Define aliases specific to macOS environment
# Author: Yago Riveiro
# ==============================================================================

# ------------------------------------------------------------------------------
# Platform Compatibility Check
# ------------------------------------------------------------------------------
# Only load these aliases if running on macOS (Darwin-based systems).
# This ensures cross-platform compatibility and prevents errors on other systems.
#
# COMPATIBILITY:
#   - Checks OSTYPE environment variable for Darwin prefix
#   - Early return prevents alias loading on non-macOS systems
#   - Maintains clean separation between platform-specific configurations
#
# NOTES:
#   - Darwin is the core operating system underlying macOS
#   - OSTYPE examples: darwin23.0.0 (macOS Sonoma), darwin22.0.0 (macOS Ventura)
#   - This check prevents conflicts with Linux or Windows-specific aliases
# ------------------------------------------------------------------------------
[[ "${OSTYPE}" == "darwin"* ]] || return

# ------------------------------------------------------------------------------
# Development Directory Shortcuts
# ------------------------------------------------------------------------------
# Quick navigation shortcuts to common development directories in the macOS
# filesystem hierarchy. These aliases streamline access to frequently used
# development workspaces and project locations.
#
# DIRECTORY STRUCTURE:
#   ~/Development/          Main development workspace
#   ├── github/            GitHub repositories and projects
#   ├── gist/              GitHub Gists and code snippets
#   └── [other projects]   Additional development projects
#   
#   ~/Dump/                Temporary files and downloads
#
# ALIASES:
#   github          Navigate to GitHub projects directory
#   gist            Navigate to GitHub Gists directory  
#   devel           Navigate to main Development directory
#   dump            Navigate to temporary Dump directory
#
# USAGE EXAMPLES:
#   $ github         # cd ~/Development/github
#   $ gist           # cd ~/Development/gist
#   $ devel          # cd ~/Development
#   $ dump           # cd ~/Dump
#
# WORKFLOW BENEFITS:
#   - Rapid project switching during development
#   - Consistent directory organization across macOS systems
#   - Quick access to temporary file storage location
#   - Supports organized version control repository management
#
# NOTES:
#   - These directories should be created manually if they don't exist
#   - GitHub and Gist directories can be organized by username or project type
#   - Dump directory is ideal for temporary downloads and file processing
# ------------------------------------------------------------------------------
alias github="cd ~/Development/github"
alias gist="cd ~/Development/gist"
alias devel="cd ~/Development"
alias dump="cd ~/Dump"

# ------------------------------------------------------------------------------
# System Maintenance
# ------------------------------------------------------------------------------
# Comprehensive Homebrew package management and system cleanup operations.
# This alias chains multiple Homebrew commands for complete system maintenance
# in a single command execution.
#
# HOMEBREW MAINTENANCE OPERATIONS:
#   brew update         Update Homebrew itself and formula definitions
#   brew upgrade        Upgrade all installed packages to latest versions
#   brew cleanup        Remove old versions and cached downloads
#   brew autoremove     Remove orphaned dependencies no longer needed
#
# ALIAS:
#   brewup              Execute complete Homebrew maintenance cycle
#
# USAGE:
#   $ brewup            # Perform full Homebrew system update and cleanup
#
# EXECUTION SEQUENCE:
#   1. Updates Homebrew formulae and cask definitions from repositories
#   2. Upgrades all outdated installed packages to their latest versions
#   3. Removes old package versions and clears download cache
#   4. Automatically removes unused dependencies and orphaned packages
#
# BENEFITS:
#   - Maintains system security with latest package versions
#   - Frees disk space by removing outdated files and caches
#   - Ensures optimal system performance and stability
#   - Prevents dependency conflicts and version mismatches
#
# TIMING RECOMMENDATIONS:
#   - Run weekly for active development systems
#   - Run before major project deployments
#   - Execute during scheduled maintenance windows
#
# NOTES:
#   - Process may take several minutes depending on package count
#   - Requires active internet connection for updates
#   - Some packages may require system restart after upgrade
#   - Command execution stops if any individual command fails
# ------------------------------------------------------------------------------
alias brewup="brew update && brew upgrade && brew cleanup && brew autoremove"

# ------------------------------------------------------------------------------
# Network Utilities
# ------------------------------------------------------------------------------
# macOS-specific network diagnostic and performance measurement tools.
# These aliases provide quick access to built-in macOS network utilities
# for troubleshooting and performance analysis.
#
# NETWORK PERFORMANCE TESTING:
#   net-speed           Comprehensive network quality assessment tool
#
# BUILD SYSTEM SHORTCUTS:
#   mk                  Short alias for make build system
#
# NETWORK SPEED TESTING:
# The networkQuality tool (available in macOS Monterey 12.0+) provides:
#   - Upload and download speed measurements
#   - Network responsiveness testing (Round-Trip Time)
#   - Connection quality assessment
#   - Verbose output with detailed metrics
#   - Privacy-focused testing (no data collection)
#
# USAGE EXAMPLES:
#   $ net-speed         # Test comprehensive network performance
#   $ mk clean          # Execute make clean command
#   $ mk install        # Execute make install command
#
# NETWORKQUALITY FLAGS:
#   -v                  Verbose output with detailed progress and metrics
#   -p                  Pretty-print results in human-readable format
#
# OUTPUT INCLUDES:
#   - Download/Upload capacity (Mbps)
#   - Download/Upload responsiveness (RPM - Round-trips Per Minute)
#   - Overall network quality rating
#   - Testing methodology and server information
#
# BENEFITS:
#   - Native macOS tool (no third-party installation required)
#   - Privacy-focused (doesn't send personal data)
#   - Comprehensive network quality assessment
#   - Useful for troubleshooting connectivity issues
#
# REQUIREMENTS:
#   - macOS Monterey (12.0) or later
#   - Active internet connection
#   - Network access to Apple's testing servers
#
# NOTES:
#   - Testing duration varies based on network conditions (typically 10-30 seconds)
#   - Results may vary throughout the day due to network congestion
#   - Tool measures real-world performance, not theoretical maximum speeds
# ------------------------------------------------------------------------------
alias net-speed="networkQuality -v -p"
alias mk="make"

# ------------------------------------------------------------------------------
# Security Hardware Utilities
# ------------------------------------------------------------------------------
# YubiKey hardware security token management and GPG integration utilities.
# These aliases provide quick access to YubiKey troubleshooting and
# reconnection operations for cryptographic operations.
#
# YUBIKEY GPG OPERATIONS:
#   yubikey-scan        Refresh YubiKey GPG smart card detection and key learning
#
# YUBIKEY FUNCTIONALITY:
# The yubikey-scan alias executes a sequence of GPG smart card operations:
#   1. 'scd serialno'   - Smart Card Daemon serial number detection
#   2. 'learn --force'  - Force GPG to relearn all keys from the hardware token
#   3. '/bye'          - Cleanly terminate the GPG agent connection
#
# USAGE SCENARIOS:
#   $ yubikey-scan      # Refresh YubiKey connection after hardware issues
#                      # Reconnect after system sleep/wake cycles
#                      # Resolve GPG key detection problems
#                      # Initialize YubiKey after first connection
#
# TROUBLESHOOTING APPLICATIONS:
#   - YubiKey not detected by GPG operations
#   - Smart card errors during signing or encryption
#   - Key unavailable errors after system sleep
#   - GPG agent connection timeouts or failures
#   - Hardware token reconnection after USB disconnect
#
# TECHNICAL DETAILS:
#   - Interfaces with gpg-connect-agent for smart card communication
#   - Requires gpg-agent service to be running and accessible
#   - Compatible with YubiKey 4, 5, and newer hardware tokens
#   - Supports both OpenPGP and PIV smart card applications
#
# SECURITY CONSIDERATIONS:
#   - May prompt for YubiKey PIN entry during execution
#   - PIN attempts are limited (typically 3 attempts before lockout)
#   - Admin PIN may be required for certain recovery operations
#   - Operations logged in system security logs
#
# REQUIREMENTS:
#   - YubiKey hardware token properly configured with GPG keys
#   - GnuPG (gpg) installed with smart card support enabled
#   - gpg-agent running with smart card daemon functionality
#   - Proper USB/NFC connection to YubiKey device
#
# NOTES:
#   - Command execution may take 5-10 seconds to complete
#   - LED on YubiKey may blink during smart card operations
#   - Some operations may require physical touch confirmation on YubiKey
#   - Compatible with both GPG and SSH authentication workflows
# ------------------------------------------------------------------------------
alias yubikey-scan="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"
