if (( ! $+commands[align] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `align`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_align" ]]; then
  typeset -g -A _comps
  autoload -Uz _align
  _comps[align]=_align
fi

# Generate and load align completion
align completion zsh >! "$ZSH_CACHE_DIR/completions/_align" &|
