alias __="nvim"
alias vim="nvim"
alias gitstamp="cat ~/.localgit.cfg >> .git/config"

alias l="exa -l"
alias ll="exa -l -L=2 -T"
alias lll="exa -l -L=3 -T"

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias github="~/Development/github"
  alias gist="~/Development/gist"
  alias brewup="brew update && brew upgrade && brew cleanup"
  alias devel="cd ~/Development"
  alias kc="kubectl"
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  alias github="cd /data/Development/github"
  alias gist="cd /data/Development/gist"
  alias devel="cd /data/Development"

  # microk8s aliases
  alias mc='microk8s kubectl'
  alias mcg='microk8s kubectl get'
fi
