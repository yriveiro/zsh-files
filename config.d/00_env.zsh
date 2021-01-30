export LSCOLORS='exfxcxdxbxegedabagacad'
export CLICOLOR=true

export EDITOR=nvim

if [[ "$OSTYPE" == "darwin"* ]]; then
  export RUST_SRC_PATH="/usr/local/src/rustc/src"
  export PATH=$PATH:/usr/local/bin/go
  export GOPATH=~/Development/go/bin
  export CLOUDSDK_PYTHON=/usr/local/Cellar/python@3.8/3.8.6_1/bin/python3.8
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  export PATH=$PATH:/usr/local/go/bin:/data/Development/go/bin:/usr/local/kubebuilder/bin
  export GOPATH=/data/Development/go

  if [[ -d /usr/local/kubebuilder/bin ]]; then
    export PATH=$PATH:/usr/local/kubebuilder/bin
  fi
fi

export GPG_TTY=$(tty)

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
