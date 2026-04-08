#!/bin/zsh -f

# ==============================================================================
# ZSH Darwin Environment Configuration
# Purpose: Configure environment variables specific to macOS
# Author: Yago Riveiro
# ==============================================================================

# Skip if not running on Darwin
[[ "${OSTYPE}" == "darwin"* ]] || return

# Remove duplicates in these arrays before any PATH mutations
typeset -U path cdpath fpath manpath

# Static Homebrew prefix selection
if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
else
    export HOMEBREW_PREFIX="/usr/local"
fi

export DYLD_LIBRARY_PATH=${HOMEBREW_PREFIX}/lib:${DYLD_LIBRARY_PATH}

# ------------------------------------------------------------------------------
# Development Tools Configuration
# ------------------------------------------------------------------------------
# Rust configuration
export RUST_SRC_PATH="/usr/local/src/rustc/src"

# LSP configuration
export JDTLS_HOME="${HOME}/.local/share/nvim/mason/packages/jdtls"

# ------------------------------------------------------------------------------
# PATH Configuration
# ------------------------------------------------------------------------------
# Define additional PATH entries
PATH_ADDITIONS=(
    "${HOMEBREW_PREFIX}/bin"                       # Brew
    "${HOMEBREW_PREFIX}/opt/gnu-getopt/bin"        # GNU getopt
    "${HOMEBREW_PREFIX}/opt/php@8.3/bin"           # PHP
    "${HOMEBREW_PREFIX}/opt/php@8.3/sbin"           # PHP
    "${HOME}/.krew/bin"                            # Kubernetes krew plugin
    "${HOME}/.local/bin"                           # User local binaries
    "/usr/local/bin/go"                            # Go binary
)
# Prepend PATH_ADDITIONS to path array
path=("${PATH_ADDITIONS[@]}" $path)

() {
    local gcloud_path="${HOMEBREW_PREFIX}/share/google-cloud-sdk"

    [[ -d "${gcloud_path}" ]] || return

    _load_gcloud_shell() {
        unset -f _load_gcloud_shell gcloud gsutil bq
        [[ -r "${gcloud_path}/path.zsh.inc" ]] && source "${gcloud_path}/path.zsh.inc"
        [[ -r "${gcloud_path}/completion.zsh.inc" ]] && source "${gcloud_path}/completion.zsh.inc"
    }

    gcloud() {
        _load_gcloud_shell
        gcloud "$@"
    }

    gsutil() {
        _load_gcloud_shell
        gsutil "$@"
    }

    bq() {
        _load_gcloud_shell
        bq "$@"
    }
}
