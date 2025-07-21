if (( ! $+commands[concord] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `concord`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_concord" ]]; then
  typeset -g -A _comps
  autoload -Uz _concord
  _comps[concord]=_concord
fi

# Generate and load concord completion
concord completion zsh >! "$ZSH_CACHE_DIR/completions/_concord" &|
