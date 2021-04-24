alias __="nvim"
alias vim="nvim"
alias gitstamp="cat ~/.localgit.cfg >> .git/config"

alias l="exa -l"
alias la="exa -la"
alias ll="exa -l -L=2 -T"
alias lll="exa -l -L=3 -T"
alias ..="cd .."

if command kubectl 2>&1 > /dev/null; then
  alias k="kubectl"
  alias ka="kubectl apply"
  alias kc="kubectl create"
  alias kd="kubectl describe"
  alias kg="kubectl get"
  alias kl="kubectl logs"
  alias kr="kubectl delete"
fi

if test is-darwin; then
  alias github="~/Development/github"
  alias gist="~/Development/gist"
  alias brewup="brew update && brew upgrade && brew cleanup"
  alias devel="cd ~/Development"
  alias kc="kubectl"
fi

if test is-linux; then
  alias github="cd /data/Development/github.com"
  alias gist="cd /data/Development/gist"
  alias devel="cd /data/Development"
  alias aptup="sudo apt update; sudo apt upgrade"
fi
