if (( ! $+commands[copilot] && ! $+commands[claude] )); then
  return
fi

function _agent_skill_homes() {
  # Prints the skills root of each installed agent tool, one per line. Keep in
  # sync with agent_skill_targets in lib/agent-links.sh.
  (( $+commands[copilot] )) && print -r -- "$HOME/.copilot/skills"
  (( $+commands[claude] )) && print -r -- "$HOME/.claude/skills"
  return 0
}

function _agent_find_skill_leaves() {
  # Recursively finds skill leaf directories under $1 (a directory containing a
  # SKILL.md file directly is a leaf; anything else is an organizational
  # category folder to recurse into) and prints each leaf path on its own
  # line. Callers capture output with zsh's `(f)` flag to split into an
  # array (zsh has no bash-style nameref support for out params).
  local dir="$1"

  [[ -d "$dir" ]] || return

  setopt local_options nullglob

  if [[ -f "$dir/SKILL.md" ]]; then
    print -r -- "$dir"
    return
  fi

  local sub
  for sub in "$dir"/*/; do
    [[ -d "$sub" ]] || continue
    _agent_find_skill_leaves "${sub%/}"
  done
}

function _agent_max_skill_width() {
  local -a dirs=("$@")
  local max=20
  local name len
  local -a leaves

  for dir in "${dirs[@]}"; do
    leaves=("${(f)"$(_agent_find_skill_leaves "$dir")"}")
    for skill_dir in "${leaves[@]}"; do
      [[ -n "$skill_dir" ]] || continue
      name=$(basename "$skill_dir")
      len=${#name}
      (( len > max )) && max=$len
    done
  done

  echo $(( max + 2 ))
}

function _agent_link_skills_from() {
  # Links every skill leaf under $1 into each skills home in $_skill_homes,
  # printing one row per skill with a status per home.
  local skills_src="$1"
  local -i _col_width="${2:-20}"

  [[ -d "$skills_src" ]] || return

  local -a leaves
  leaves=("${(f)"$(_agent_find_skill_leaves "$skills_src")"}")

  local skill_name target home row
  for skill_dir in "${leaves[@]}"; do
    [[ -n "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")

    if (( ${+_seen_skill_names[$skill_name]} )); then
      printf "  %-${_col_width}s %s\n" "$skill_name" "${fg[yellow]}⚠ duplicate name — keeping ${_seen_skill_names[$skill_name]}, skipping${reset_color}"
      (( _cnt_conflict++ ))
      continue
    fi
    _seen_skill_names[$skill_name]="$skill_dir"
    (( _cnt_exists++ ))

    row=""
    for home in "${_skill_homes[@]}"; do
      target="$home/$skill_name"
      row+="${home:h:t}: "

      if [[ -L "$target" ]]; then
        if [[ "$(readlink "$target")" != "$skill_dir" ]]; then
          row+="${fg[yellow]}⚠ conflict — linked elsewhere${reset_color}  "
          (( _cnt_conflict++ ))
        else
          row+="${fg[green]}✓${reset_color}  "
          (( _cnt_already++ ))
        fi
      else
        [[ -e "$target" ]] && mv "$target" "${target}.old"
        ln -s "$skill_dir" "$target"
        row+="${fg[cyan]}→ linked${reset_color}  "
        (( _cnt_new++ ))
      fi
    done

    printf "  %-${_col_width}s %s\n" "$skill_name" "$row"
  done
}

function _agent_unlink_skills() {
  setopt local_options nullglob

  local -i _cnt_removed=0 _cnt_skipped=0
  local name home

  for home in "${(f)"$(_agent_skill_homes)"}"; do
    [[ -d "$home" ]] || continue

    for entry in "$home"/*(N); do
      name=$(basename "$entry")
      if [[ -L "$entry" ]]; then
        rm "$entry"
        printf "  %-20s %s\n" "$name" "${fg[red]}✗ unlinked from ${home:h:t}${reset_color}"
        (( _cnt_removed++ ))
      elif [[ "$name" != "synced" ]]; then
        printf "  %-20s %s\n" "$name" "${fg[yellow]}⚠ not a symlink in ${home:h:t}, skipping${reset_color}"
        (( _cnt_skipped++ ))
      fi
    done
  done

  local _summary="${fg[red]}${_cnt_removed} unlinked${reset_color}"
  [[ $_cnt_skipped -gt 0 ]] && _summary+="  ${fg[yellow]}${_cnt_skipped} skipped${reset_color}"
  printf "\n  %s\n" "$_summary"
}

function skills-sync() {
  if [[ "$1" == "unlink" ]]; then
    _agent_unlink_skills
    return
  elif [[ -n "$1" ]]; then
    echo "Usage: skills-sync [unlink]" >&2
    return 1
  fi

  local dotfiles="${ZSH_CUSTOM%/omz}"
  local -a _skill_homes=("${(f)"$(_agent_skill_homes)"}")

  setopt local_options nullglob

  local -i _cnt_exists=0 _cnt_already=0 _cnt_new=0 _cnt_removed=0 _cnt_conflict=0
  local -A _seen_skill_names=()

  # Compute column width from all skill sources
  local -a _skill_dirs=("$dotfiles/agents/skills")
  if [[ -n "$PRIVATE_DOTFILES" ]]; then
    _skill_dirs+=("$PRIVATE_DOTFILES/agents/work_skills")
    _skill_dirs+=("$PRIVATE_DOTFILES/agents/private_skills")
  fi
  local -i _col_width
  _col_width=$(_agent_max_skill_width "${_skill_dirs[@]}")

  # Prune broken symlinks
  local home
  for home in "${_skill_homes[@]}"; do
    mkdir -p "$home"
    for link in "$home"/*(N@); do
      if [[ ! -e "$link" ]]; then
        printf "  %-${_col_width}s %s\n" "$(basename "$link")" "${fg[red]}✗ removed from ${home:h:t}${reset_color}"
        rm "$link"
        (( _cnt_removed++ ))
      fi
    done
  done

  # Link personal, then work and private skills
  local src
  for src in "${_skill_dirs[@]}"; do
    _agent_link_skills_from "$src" "$_col_width"
  done

  local _summary="${fg[white]}${_cnt_exists} skills${reset_color}"
  _summary+="  ${fg[green]}${_cnt_already} linked${reset_color}"
  _summary+="  ${fg[cyan]}${_cnt_new} new${reset_color}"
  _summary+="  ${fg[red]}${_cnt_removed} removed${reset_color}"
  [[ $_cnt_conflict -gt 0 ]] && _summary+="  ${fg[yellow]}${_cnt_conflict} conflict${reset_color}"
  printf "\n  %s\n" "$_summary"
}

function agents-sync() {
  # Syncs MCP servers and the shell allowlist into Claude Code.
  "${ZSH_CUSTOM%/omz}/agents/sync.sh"
}
