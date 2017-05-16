# Homebrew
export HOMEBREW_PATH="/usr/local/bin:/usr/local/sbin"

# Golang
export GOPATH="$HOME/go"
export GOBINPATH="$GOPATH/bin"

# Rust
export RUST_PATH="$HOME/.cargo/bin"

# AWS
AWS_ENVS=`for env in $(cat ~/.aws/credentials | grep -i -A 2 "\[default\]" | tail -n 2 | sed 's/\ =\ /=/'); do echo "-e $(echo $env | cut -d "=" -f 1 | tr '[:lower:]' '[:upper:]')=$(echo $env | cut -d "=" -f 2)"; done | tr '\n' ' '`
export AWSPATH="$HOME/.aws"

# Docker
export DOCKER_DEV_VOLS="-v $HOME/.ssh:/home/dan9186/.ssh -v $HOME/.ionchannel:/home/dan9186/.ionchannel -v $GOPATH/src:/gopath/src"
export DOCKER_DEV_ENVS="$AWS_ENVS"
export DOCKER_DEV="$DOCKER_DEV_VOLS $DOCKER_DEV_ENVS"

# RVM
export RVM_PATH="$HOME/.rvm/bin"

# PATH
export PATH="$PATH:$HOMEBREW_PATH"
export PATH="$PATH:$GOBINPATH"
export PATH="$PATH:$RVM_PATH"
export PATH="$PATH:$RUST_PATH"

# vim: filetype=exports noexpandtab
