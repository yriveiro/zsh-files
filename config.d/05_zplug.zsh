#!/bin/zsh -f

source /usr/local/opt/zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug "mafredri/zsh-async", from:"github", use:"async.zsh"

# Oh My ZSH plugings
zplug "plugins/gpg-agent", from:oh-my-zsh
zplug "plugins/pass", from:oh-my-zsh
zplug "plugins/kubctl", from:oh-my-zsh
zplug "plugins/minikube", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "greymd/docker-zsh-completion", from:github

# ZSH Users plugings
zplug "zsh-users/zsh-completions", from:github
zplug "zsh-users/zsh-autosuggestions", from:github
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:2  # zsh-syntax-highlighting must be loaded after executing compinit command
zplug "zsh-users/zsh-history-substring-search", from:github, defer:3

# Then, source plugins and add commands to $PATH
zplug load
