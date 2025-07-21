if (( ! $+commands[flow] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `flow`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_flow" ]]; then
  typeset -g -A _comps
  autoload -Uz _flow
  _comps[flow]=_flow
fi

# Generate and load flow completion
flow completion zsh >! "$ZSH_CACHE_DIR/completions/_flow" &|
