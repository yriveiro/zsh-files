#!/bin/zsh -f

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit wait lucid light-mode for \
    jeffreytse/zsh-vi-mode \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node \
    zsh-users/zsh-history-substring-search \
    Dbz/kube-aliases \
    agkozak/zsh-z \
    webyneter/docker-aliases \
  atinit"autoload -Uz bashcompinit && bashcompinit" \
    'https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion' \
  atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions \
      yriveiro/zsh-completions \
  as"completion" \
      OMZP::aws/aws.plugin.zsh \
      dwaynebradley/k3d-oh-my-zsh-plugin \
      MenkeTechnologies/zsh-cargo-completion \
      sudosubin/zsh-poetry
