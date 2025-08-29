# ~/.zshrc
# Main ZSH configuration file with detailed documentation

#------------------------------------------------------------------------------
# Basic Shell Configuration
#------------------------------------------------------------------------------

export TERM=xterm-kitty

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
  for f in "${HOME}/.config/zsh/config.local.d/"*; do
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
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

#------------------------------------------------------------------------------
# Development Tools Configuration
#------------------------------------------------------------------------------

# Configure Google Cloud SDK for macOS
# Only load if running on macOS system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Define Homebrew installation path
    local gcloud_path="$(brew --prefix)/share/google-cloud-sdk"

    # Source Google Cloud SDK files if they exist
    if [[ -d "$gcloud_path" ]]; then
        source "${gcloud_path}/path.zsh.inc"
        source "${gcloud_path}/completion.zsh.inc"
    fi
fi

#------------------------------------------------------------------------------
# Command Completion Setup
#------------------------------------------------------------------------------

# Initialize bash completion compatibility
# This is required for some tools that only provide bash completions
autoload -U +X bashcompinit && bashcompinit

#------------------------------------------------------------------------------
# Shell History Management
#------------------------------------------------------------------------------

# Initialize Atuin for enhanced shell history
# Atuin provides a better history search and sync capability
eval "$(atuin init zsh)"
source <(switcher init zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yagoriveiro/Dump/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yagoriveiro/Dump/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yagoriveiro/Dump/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yagoriveiro/Dump/google-cloud-sdk/completion.zsh.inc'; fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
