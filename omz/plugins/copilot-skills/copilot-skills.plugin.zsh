if (( ! $+commands[copilot] )); then
  return
fi

function _copilot_find_skill_leaves() {
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
    _copilot_find_skill_leaves "${sub%/}"
  done
}

function _copilot_max_skill_width() {
  local -a dirs=("$@")
  local max=20
  local name len
  local -a leaves

  for dir in "${dirs[@]}"; do
    leaves=("${(f)"$(_copilot_find_skill_leaves "$dir")"}")
    for skill_dir in "${leaves[@]}"; do
      [[ -n "$skill_dir" ]] || continue
      name=$(basename "$skill_dir")
      len=${#name}
      (( len > max )) && max=$len
    done
  done

  echo $(( max + 2 ))
}

function _copilot_link_skills_from() {
  local skills_src="$1"
  local -i _col_width="${2:-20}"
  local skills_home="$HOME/.copilot/skills"

  [[ -d "$skills_src" ]] || return

  local -a leaves
  leaves=("${(f)"$(_copilot_find_skill_leaves "$skills_src")"}")

  local skill_name
  local target
  for skill_dir in "${leaves[@]}"; do
    [[ -n "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")

    if (( ${+_seen_skill_names[$skill_name]} )); then
      printf "  %-${_col_width}s %s\n" "$skill_name" "${fg[yellow]}⚠ duplicate name — keeping ${_seen_skill_names[$skill_name]}, skipping${reset_color}"
      (( _cnt_conflict++ ))
      continue
    fi
    _seen_skill_names[$skill_name]="$skill_dir"

    target="$skills_home/$skill_name"
    (( _cnt_exists++ ))

    if [[ -L "$target" ]]; then
      if [[ "$(readlink "$target")" != "$skill_dir" ]]; then
        printf "  %-${_col_width}s %s\n" "$skill_name" "${fg[yellow]}⚠ conflict — linked elsewhere${reset_color}"
        (( _cnt_conflict++ ))
      else
        printf "  %-${_col_width}s %s\n" "$skill_name" "${fg[green]}✓${reset_color}"
        (( _cnt_already++ ))
      fi
    else
      [[ -e "$target" ]] && mv "$target" "${target}.old"
      ln -s "$skill_dir" "$target"
      printf "  %-${_col_width}s %s\n" "$skill_name" "${fg[cyan]}→ linked${reset_color}"
      (( _cnt_new++ ))
    fi
  done
}

function _copilot_unlink_skills() {
  local skills_home="$HOME/.copilot/skills"

  [[ -d "$skills_home" ]] || return

  setopt local_options nullglob

  local -i _cnt_removed=0 _cnt_skipped=0
  local name

  for entry in "$skills_home"/*(N); do
    name=$(basename "$entry")
    if [[ -L "$entry" ]]; then
      rm "$entry"
      printf "  %-20s %s\n" "$name" "${fg[red]}✗ unlinked${reset_color}"
      (( _cnt_removed++ ))
    else
      printf "  %-20s %s\n" "$name" "${fg[yellow]}⚠ not a symlink, skipping${reset_color}"
      (( _cnt_skipped++ ))
    fi
  done

  local _summary="${fg[red]}${_cnt_removed} unlinked${reset_color}"
  [[ $_cnt_skipped -gt 0 ]] && _summary+="  ${fg[yellow]}${_cnt_skipped} skipped${reset_color}"
  printf "\n  %s\n" "$_summary"
}

function skills-sync() {
  if [[ "$1" == "unlink" ]]; then
    _copilot_unlink_skills
    return
  elif [[ -n "$1" ]]; then
    echo "Usage: skills-sync [unlink]" >&2
    return 1
  fi

  local dotfiles="${ZSH_CUSTOM%/omz}"
  local skills_home="$HOME/.copilot/skills"

  mkdir -p "$skills_home"

  setopt local_options nullglob

  local -i _cnt_exists=0 _cnt_already=0 _cnt_new=0 _cnt_removed=0 _cnt_conflict=0
  local -A _seen_skill_names=()

  # Compute column width from all skill sources
  local -a _skill_dirs=("$dotfiles/copilot/skills")
  if [[ -n "$PRIVATE_DOTFILES" ]]; then
    _skill_dirs+=("$PRIVATE_DOTFILES/copilot/work_skills")
    _skill_dirs+=("$PRIVATE_DOTFILES/copilot/private_skills")
  fi
  local -i _col_width
  _col_width=$(_copilot_max_skill_width "${_skill_dirs[@]}")

  # Prune broken symlinks
  for link in "$skills_home"/*/; do
    if [[ -L "${link%/}" && ! -e "${link%/}" ]]; then
      printf "  %-${_col_width}s %s\n" "$(basename "${link%/}")" "${fg[red]}✗ removed${reset_color}"
      rm "${link%/}"
      (( _cnt_removed++ ))
    fi
  done

  # Link personal skills
  _copilot_link_skills_from "$dotfiles/copilot/skills" "$_col_width"

  # Link work and private skills if PRIVATE_DOTFILES is set
  if [[ -n "$PRIVATE_DOTFILES" ]]; then
    _copilot_link_skills_from "$PRIVATE_DOTFILES/copilot/work_skills" "$_col_width"
    _copilot_link_skills_from "$PRIVATE_DOTFILES/copilot/private_skills" "$_col_width"
  fi

  local -i _cnt_linked=$(( _cnt_already + _cnt_new ))
  local _summary="${fg[white]}${_cnt_exists} total${reset_color}"
  _summary+="  ${fg[green]}${_cnt_linked} linked${reset_color}"
  _summary+="  ${fg[cyan]}${_cnt_new} new${reset_color}"
  _summary+="  ${fg[red]}${_cnt_removed} removed${reset_color}"
  [[ $_cnt_conflict -gt 0 ]] && _summary+="  ${fg[yellow]}${_cnt_conflict} conflict${reset_color}"
  printf "\n  %s\n" "$_summary"
}
