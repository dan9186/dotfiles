if (( ! $+commands[id62] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `id62`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_id62" ]]; then
  typeset -g -A _comps
  autoload -Uz _id62
  _comps[id62]=_id62
fi

# Generate and load id62 completion
id62 completion zsh >! "$ZSH_CACHE_DIR/completions/_id62" &|
