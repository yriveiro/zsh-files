# ~/.zshrc
# Main ZSH configuration file with detailed documentation

#------------------------------------------------------------------------------
# Basic Shell Configuration
#------------------------------------------------------------------------------

export TERM=wezterm

# Enable extended pattern matching features
# This allows for more advanced file globbing patterns
setopt extended_glob

#------------------------------------------------------------------------------
# Zinit Plugin Manager Setup
#------------------------------------------------------------------------------

# Auto-install Zinit if not present
if [[ ! -e "${HOME}/.zinit/bin/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Initialize Zinit and its completion system
source "${HOME}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#------------------------------------------------------------------------------
# Configuration Loading System
#------------------------------------------------------------------------------

# Load all configuration files from the main config directory
# These files should contain the core configuration
for f in "${HOME}/.config/zsh/config.d"/*.zsh(N); do
    source "${f}"
done

# Load machine-specific local configurations if they exist
# This allows for custom settings per machine without affecting the main config
if [[ -d "${HOME}/.config/zsh/config.local.d/" ]]; then
  for f in ${HOME}/.config/zsh/config.local.d/*(N); do
      source "${f}"
  done
fi

#------------------------------------------------------------------------------
# User Interface Configuration
#------------------------------------------------------------------------------

# Disable syntax highlighting for pasted text
# This prevents unexpected color changes when pasting commands
zle_highlight=('paste:none')

# Configure and initialize Starship prompt
# Starship provides a minimal, fast, and customizable prompt
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
() {
    local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/starship-init.zsh"
    local _bin="${commands[starship]}"
    if [[ -n "$_bin" && ( ! -f "$_cache" || "$_bin" -nt "$_cache" ) ]]; then
        mkdir -p "${_cache:h}"
        starship init zsh >| "$_cache"
    fi
    [[ -f "$_cache" ]] && source "$_cache"
}

#------------------------------------------------------------------------------
# Development Tools Configuration
#------------------------------------------------------------------------------

# Configure Google Cloud SDK for macOS
# Only load if running on macOS system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Define Homebrew installation path
    gcloud_path="${HOMEBREW_PREFIX}/share/google-cloud-sdk"

    # Source Google Cloud SDK files if they exist
    if [[ -d "$gcloud_path" ]]; then
        source "${gcloud_path}/path.zsh.inc"
        source "${gcloud_path}/completion.zsh.inc"
    fi
fi

#------------------------------------------------------------------------------
# Shell History Management
#------------------------------------------------------------------------------

# Initialize Atuin for enhanced shell history
# Atuin provides a better history search and sync capability
() {
    local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/atuin-init.zsh"
    local _bin="${commands[atuin]}"
    if [[ -n "$_bin" && ( ! -f "$_cache" || "$_bin" -nt "$_cache" ) ]]; then
        mkdir -p "${_cache:h}"
        atuin init zsh >| "$_cache"
    fi
    [[ -f "$_cache" ]] && source "$_cache"
}

() {
    local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/switcher-init.zsh"
    local _bin="${commands[switcher]}"
    if [[ -n "$_bin" && ( ! -f "$_cache" || "$_bin" -nt "$_cache" ) ]]; then
        mkdir -p "${_cache:h}"
        switcher init zsh >| "$_cache"
    fi
    [[ -f "$_cache" ]] && source "$_cache"
}

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/yagoriveiro/Dump/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yagoriveiro/Dump/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/yagoriveiro/Dump/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yagoriveiro/Dump/google-cloud-sdk/completion.zsh.inc'; fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# bun completions
[ -s "/Users/yagoriveiro/.bun/_bun" ] && source "/Users/yagoriveiro/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" $path)

# zoxide
() {
    local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zoxide-init.zsh"
    local _bin="${commands[zoxide]}"
    if [[ -n "$_bin" && ( ! -f "$_cache" || "$_bin" -nt "$_cache" ) ]]; then
        mkdir -p "${_cache:h}"
        zoxide init zsh --cmd j >| "$_cache"
    fi
    [[ -f "$_cache" ]] && source "$_cache"
}
