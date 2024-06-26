#!/bin/zsh -f

# System
alias c="clear"
alias cls="clear"
alias __="nvim"
alias vim="nvim"
alias :q="exit"

alias ..="cd .."

if command exa 2>&1 > /dev/null; then
    alias l="exa -l"
    alias la="exa -la"
    alias ll="exa -l -L=2 -T"
    alias lll="exa -l -L=3 -T"
fi

if command terraform -version 2>&1 > /dev/null; then
    alias tfv="terraform validate"
    alias tfp="terraform plan"
    alias tfa="terraform apply"
    alias tfc="terraform console"
fi

# Git

alias g="git"
alias gap="git ap ."
alias gci="git ci -S -m "
alias gitstamp="cat ~/.localgit.cfg >> .git/config"
alias gpl="git pull"
alias gps="git push"
alias gst="git st"
alias gw="git worktree"
alias gwl="git worktree list"
alias lg="lazygit --use-config-dir ${HOME}/.config/lazygit/"

# others

alias reload="source ~/.zshrc"

if command kubectl 2>&1 > /dev/null; then
    alias k="kubectl"
    alias ka="kubectl apply"
    alias kc="kubectl create"
    alias kg="kubectl get"
    alias kl="kubectl logs"
    alias kr="kubectl delete"
fi

if command tmux -V 2>&1 > /dev/null; then
    alias mu="tmux"
    alias mua="tmux attach"
    alias muls="tmux ls"
fi

if [[ "$OSTYPE" == darwin* ]]; then
    alias github="~/Development/github"
    alias gist="~/Development/gist"
    alias brewup="brew update && brew upgrade && brew cleanup"
    alias devel="cd ~/Development"
fi

if [[ "$OSTYPE" == linux* ]]; then
    alias github="cd /data/Development/github.com"
    alias gist="cd /data/Development/gist"
    alias devel="cd /data/Development"
    alias aptup="sudo apt update; sudo apt upgrade"
fi

if command minikube 2>&1 > /dev/null; then
    alias mk="minikube kubectl --"
fi

alias yubikey-scan="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"
alias net-speed="networkQuality -v -p"
