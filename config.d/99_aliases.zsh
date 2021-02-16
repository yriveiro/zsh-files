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
  alias github="cd /data/Development/github.com"
  alias gist="cd /data/Development/gist"
  alias devel="cd /data/Development"

  if command kubectl 2>&1 > /dev/null; then
      alias kc="kubectl"
      alias kca="kubectl apply"
      alias kcc="kubectl create"
      alias kcd="kubectl describe"
      alias kcg="kubectl get"
      alias kcl="kubectl logs"
      alias kcr="kubectl delete"
  fi
fi
