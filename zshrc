setopt extended_glob

# Extra zsh variables - history, auto-completion etc...
HISTFILE=~/.zsh_history         # where to store zsh config
HISTSIZE=10240000               # big history
SAVEHIST=10240000               # big history
LISTMAX=999999

### Added by Zinit's installer
if [[ ! -e "${HOME}/.zinit/bin/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "${HOME}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

for f in "${HOME}/.config/zsh/config.d"/*; do
    source "${f}"
done

# load local content if exists 
if [[ -d "${HOME}/.config/zsh/config.local.d/" ]]; then
  for f in "${HOME}/.config/zsh/config.local.d/"*; do
      source "${f}"
  done
fi

### End of Zinit's installer chunk

zle_highlight=('paste:none')

export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

# Google Cloud SDK

if [[ "$OSTYPE" == "darwin"* ]]; then
    local brew_path="/opt/homebrew/"

    source "${brew_path}share/google-cloud-sdk/path.zsh.inc"
    source "${brew_path}share/google-cloud-sdk/completion.zsh.inc"
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

eval "$(atuin init zsh)"
