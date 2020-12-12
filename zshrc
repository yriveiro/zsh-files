setopt extended_glob

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


# Custom options

autoload -Uz compinit
compinit


# Google Cloud SDK

if [[ "$OSTYPE" == "darwin"* ]]; then
	source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
	source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
fi

# End of lines added by compinstall
