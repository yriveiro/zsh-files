#!/bin/zsh -f

if [[ "$OSTYPE" == "darwin"* ]]; then
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  bindkey '\eOA' history-substring-search-up
  bindkey '\eOB' history-substring-search-down
fi
