typeset -g -A key

# Default key bindings
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^L" backward-word
bindkey "^P" forward-word
bindkey "^[[24~" delete-word
