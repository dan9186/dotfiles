# Custom and additional completions
[ -f "$HOME/.completions/completions" ] && source "$HOME/.completions/completions"

# Homebrew
export HOMEBREW_PATH="/usr/local/bin:/usr/local/sbin"
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

# Golang
export GOPATH="$HOME/go"
export GOBINPATH="$GOPATH/bin"
export GOPRIVATE="github.com/dan9186,github.com/gomicro,github.com/hemlocklabs"

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
. "/usr/local/opt/nvm/nvm.sh"

# RVM
export RVM_PATH="$HOME/.rvm/bin"

# PATH
export PATH="$PATH:$HOMEBREW_PATH"
export PATH="$PATH:$GOBINPATH"
export PATH="$PATH:$RVM_PATH"
export PATH="$PATH:$RUST_PATH"
export PATH="$PATH:$NODE_PATH"

# Private Envs
if [ -f "$HOME/.private_envs" ]; then
	[ $(stat -f %A "$HOME/.private_envs") != "600" ] && echo "Warning: permissions for .private_envs is too permissive"
	source "$HOME/.private_envs"
fi

#  Work Envs
if [ -f "$HOME/.work_envs" ]; then
	[ $(stat -f %A "$HOME/.work_envs") != "600" ] && echo "Warning: permissions for .work_envs is too permissive"
	source "$HOME/.work_envs"
fi

# vim: filetype=exports noexpandtab
