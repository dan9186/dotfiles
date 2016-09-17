# Homebrew
export HOMEBREW_PATH="/usr/local/bin:/usr/local/sbin"

# Golang
export GOPATH="$HOME/go"
export GOBINPATH="$GOPATH/bin"

# Docker
export DOCKER_DEV="-v $HOME/.ssh:/home/dan9186/.ssh -v $HOME/.gitconfig:/home/dan9186/.gitconfig -v $GOPATH/src:/gopath/src"

# RVM
export RVM_PATH="$HOME/.rvm/bin"

# PATH
export PATH="$PATH:$HOMEBREW_PATH"
export PATH="$PATH:$GOBINPATH"
export PATH="$PATH:$RVM_PATH"
