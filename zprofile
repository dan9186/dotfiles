# Homebrew
export HOMEBREW_PATH="/usr/local/bin:/usr/local/sbin"

# Golang
export GOPATH="$HOME/go"
export GOBINPATH="$GOPATH/bin"

# AWS
export AWSPATH="$HOME/.aws"

# Docker
export DOCKER_DEV_VOLS="-v $HOME/.ssh:/home/dan9186/.ssh -v $HOME/.gitconfig:/home/dan9186/.gitconfig -v $GOPATH/src:/gopath/src -v $AWSPATH:/home/dan9186/.aws"
export DOCKER_DEV_ENVS=""
export DOCKER_DEV="$DOCKER_DEV_VOLS $DOCKER_DEV_ENVS"

# RVM
export RVM_PATH="$HOME/.rvm/bin"

# PATH
export PATH="$PATH:$HOMEBREW_PATH"
export PATH="$PATH:$GOBINPATH"
export PATH="$PATH:$RVM_PATH"
