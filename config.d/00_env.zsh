# Global exports
export LSCOLORS='exfxcxdxbxegedabagacad'
export CLICOLOR=true
export EDITOR=nvim
export GPG_TTY=$(tty)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export SETUPTOOLS_USE_DISTUTILS=stdlib

if [[ "$OSTYPE" == "darwin"* ]]; then
  export RUST_SRC_PATH="/usr/local/src/rustc/src"
  export GOPATH=~/Development/go
  export JAVA_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home/
  export JDTLS_HOME=/Users/yriveiro/.local/share/nvim/lsp_servers/jdtls

  export PATH=/usr/local/bin/go:~/Development/go/bin:/opt/homebrew/opt/gnu-getopt/bin:~/.krew/bin:$PATH
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  export PATH=$PATH:/usr/local/go/bin:/data/Development/go/bin:/usr/local/kubebuilder/bin
  export GOPATH=/data/Development/go
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

  if [[ -d /usr/local/kubebuilder/bin ]]; then
    export PATH=$PATH:/usr/local/kubebuilder/bin
  fi
fi
