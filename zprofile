# Custom and additional completions
[ -f "$HOME/.completions/completions" ] && source "$HOME/.completions/completions"

# Homebrew
export HOMEBREW_ROOT="/usr/local"
if [ -s "/opt/homebrew/bin/brew" ]; then
	export HOMEBREW_ROOT="/opt/homebrew"
fi
eval $("$HOMEBREW_ROOT/bin/brew" shellenv)

# GPG
export GPG_TTY=$(tty)

# Golang
export GOPATH="$HOME/go"
export GOBINPATH="$GOPATH/bin"
export GOPRIVATE="github.com/dan9186,github.com/gomicro,github.com/hemlocklabs,github.com/pentops"

# Rust
export RUST_PATH="$HOME/.cargo/bin"

# AWS
export AWSPATH="$HOME/.aws"
export AWS_SDK_LOAD_CONFIG=1

# GCP
[ -f '/Users/danielhess/google-cloud-sdk/path.zsh.inc' ] && source '/Users/danielhess/google-cloud-sdk/path.zsh.inc'
[ -f '/Users/danielhess/google-cloud-sdk/completion.zsh.inc' ] && source '/Users/danielhess/google-cloud-sdk/completion.zsh.inc'
if [ -f "~/.gcp/credentials.json" ]; then
	export GCLOUD_KEYFILE_JSON=$(cat ~/.gcp/credentials.json)
	export GOOGLE_CREDENTIALS="$HOME/.gcp/credentials.json"
	export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_CREDENTIALS
fi

# Docker
export DOCKER_DEV_VOLS="-v $HOME/.ssh:/home/dan9186/.ssh -v $HOME/.ionchannel:/home/dan9186/.ionchannel -v $GOPATH/src:/gopath/src"
export DOCKER_DEV_ENVS=""
export DOCKER_DEV="$DOCKER_DEV_VOLS $DOCKER_DEV_ENVS"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_ROOT/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_ROOT/opt/nvm/nvm.sh"

# RVM
export RVM_PATH="$HOME/.rvm/bin"

# Java
export PATH="$HOMEBREW_ROOT/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I$HOMEBREW_ROOT/opt/openjdk/include"

# PATH
export PATH="$GOBINPATH:$PATH"
export PATH="$PATH:$RVM_PATH"
export PATH="$PATH:$RUST_PATH"
export PATH="$PATH:$NODE_PATH"

# Private Env Secrets
if [ -f "$HOME/.private_env_secrets" ]; then
	[ $(stat -f %A "$HOME/.private_env_secrets") != "600" ] && echo "Warning: permissions for .private_env_secrets is too permissive"
	source "$HOME/.private_env_secrets"
fi

#  Work Zprofile
[ -f "$HOME/.work_zprofile" ] && source "$HOME/.work_zprofile"

# vim: filetype=exports noexpandtab
