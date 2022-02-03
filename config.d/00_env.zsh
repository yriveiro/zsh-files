# Global exports
export LSCOLORS='exfxcxdxbxegedabagacad'
export CLICOLOR=true
export EDITOR=nvim
export GPG_TTY=$(tty)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if [[ "$OSTYPE" == "darwin"* ]]; then
  export RUST_SRC_PATH="/usr/local/src/rustc/src"
  export GOPATH=~/Development/go
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/graalvm-ce-java17-22.0.0.2/Contents/Home

  export PATH=$PATH:/usr/local/bin/go:~/Development/go/bin:/Library/Java/JavaVirtualMachines/graalvm-ce-java17-22.0.0.2/Contents/Home/bin
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  export PATH=$PATH:/usr/local/go/bin:/data/Development/go/bin:/usr/local/kubebuilder/bin
  export GOPATH=/data/Development/go
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

  if [[ -d /usr/local/kubebuilder/bin ]]; then
    export PATH=$PATH:/usr/local/kubebuilder/bin
  fi
fi
