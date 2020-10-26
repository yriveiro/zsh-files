setopt extended_glob

autoload -Uz promptinit bashcompinit
promptinit
bashcompinit

# Extra zsh variables - history, auto-completion etc...
HISTFILE=~/.zsh_history         # where to store zsh config
HISTSIZE=10240000               # big history
SAVEHIST=10240000               # big history
LISTMAX=999999

for f in ~/.config/zsh/config.d/*; do
  source $f
done

export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"


#
# Custom options
#

# source every .zsh in dotfiles rep
DOT_FILES=$HOME/Development/github/dotfiles
for config_file ($DOT_FILES/**/*.zsh) source $config_file


complete -o nospace -C /usr/local/bin/consul consul

# Google Cloud SDK
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
