#!/bin/zsh -f

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit wait lucid light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node \
    zsh-users/zsh-history-substring-search \
    Dbz/kube-aliases \
  atinit"autoload -Uz bashcompinit && bashcompinit" \
    'https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion' \
  atinit"zicompinit; zicdreplay" \
      zdharma/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions
