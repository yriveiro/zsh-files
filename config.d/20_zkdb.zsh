typeset -g -A key

# Default key bindings
bindkey "^[[3~" delete-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1;2H" backward-word
bindkey "^[[1;2F" forward-word
