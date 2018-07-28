# Homebrew
export HOMEBREW_PATH="/usr/local/bin:/usr/local/sbin"

# Golang
export GOPATH="$HOME/go"
export GOBINPATH="$GOPATH/bin"

# Rust
export RUST_PATH="$HOME/.cargo/bin"

# Npm
[ -f "~/.npmjs/credentials" ] && export NPM_TOKEN=$(cat ~/.npmjs/credentials)

# AWS
[ -f "~/.aws/credentials" ] && AWS_ENVS=`for env in $(cat ~/.aws/credentials | grep -i -A 2 "\[default\]" | tail -n 2 | sed 's/\ =\ /=/'); do echo "-e $(echo $env | cut -d "=" -f 1 | tr '[:lower:]' '[:upper:]')=$(echo $env | cut -d "=" -f 2)"; done | tr '\n' ' '`
export AWSPATH="$HOME/.aws"

# GCP
[ -f '/Users/danielhess/google-cloud-sdk/path.zsh.inc' ] && source '/Users/danielhess/google-cloud-sdk/path.zsh.inc'
[ -f '/Users/danielhess/google-cloud-sdk/completion.zsh.inc' ] && source '/Users/danielhess/google-cloud-sdk/completion.zsh.inc'
if [ -f "~/.gcp/credentials.json" ]; then
	export GCLOUD_KEYFILE_JSON=$(cat ~/.gcp/credentials.json)
	export GOOGLE_CREDENTIALS="$HOME/.gcp/credentials.json"
	export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_CREDENTIALS
fi

# GODADDY
[ -f "~/.godaddy/credentials" ] && source $HOME/.godaddy/credentials

# Docker
export DOCKER_DEV_VOLS="-v $HOME/.ssh:/home/dan9186/.ssh -v $HOME/.ionchannel:/home/dan9186/.ionchannel -v $GOPATH/src:/gopath/src"
export DOCKER_DEV_ENVS="$AWS_ENVS"
export DOCKER_DEV="$DOCKER_DEV_VOLS $DOCKER_DEV_ENVS"

# RVM
export RVM_PATH="$HOME/.rvm/bin"

# Travis
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

# PATH
export PATH="$PATH:$HOMEBREW_PATH"
export PATH="$PATH:$GOBINPATH"
export PATH="$PATH:$RVM_PATH"
export PATH="$PATH:$RUST_PATH"
export PATH="$PATH:$NODE_PATH"

# Private Envs
[ -f "$HOME/.private_envs" ] && source "$HOME/.private_envs"

# vim: filetype=exports noexpandtab
