export TERM=wezterm
setopt extended_glob

export ZSH_CONFIG_ROOT="${${(%):-%N}:A:h}"
export ZSH_ZINIT_HOME="${ZSH_ZINIT_HOME:-${HOME}/.zinit/bin}"
export ZSH_ZINIT_SCRIPT="${ZSH_ZINIT_HOME}/zinit.zsh"
export ZSH_ZINIT_AVAILABLE=0

if [[ "${ZSH_PROFILE_STARTUP:-0}" == "1" ]]; then
  zmodload zsh/zprof
fi

if [[ -r "${ZSH_ZINIT_SCRIPT}" ]]; then
  source "${ZSH_ZINIT_SCRIPT}"
  export ZSH_ZINIT_AVAILABLE=1
else
  print -u2 -- "zshrc: zinit not found at ${ZSH_ZINIT_SCRIPT}; skipping plugin load"
fi

for f in "${ZSH_CONFIG_ROOT}/config.d"/*.zsh(N); do
  source "${f}"
done

for f in "${ZSH_CONFIG_ROOT}/config.local.d"/*.zsh(N); do
  source "${f}"
done

zle_highlight=('paste:none')
