setopt extended_glob

# Extra zsh variables - history, auto-completion etc...
HISTFILE=~/.zsh_history         # where to store zsh config
HISTSIZE=10240000               # big history
SAVEHIST=10240000               # big history
LISTMAX=999999

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

for f in ~/.config/zsh/config.d/*; do
    source $f
done




### End of Zinit's installer chunk

export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

# Google Cloud SDK

if [[ "$OSTYPE" == "darwin"* ]]; then
    local brew_path="/opt/homebrew/Caskroom"

    if [[ $(sw_vers -productVersion) =~ ^10.15.* ]]; then
      local brew_path="/usr/local/Caskroom"
    fi

    source "${brew_path}/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    source "${brew_path}/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi
