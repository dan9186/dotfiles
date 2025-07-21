if (( ! $+commands[forge] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `forge`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_forge" ]]; then
  typeset -g -A _comps
  autoload -Uz _forge
  _comps[forge]=_forge
fi

# Generate and load forge completion
forge completion zsh >! "$ZSH_CACHE_DIR/completions/_forge" &|
