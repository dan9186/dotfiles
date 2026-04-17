if (( ! $+commands[copilot] )); then
  return
fi

function _copilot_link_skills_from() {
  local skills_src="$1"
  local skills_home="$HOME/.copilot/skills"

  [[ -d "$skills_src" ]] || return

  setopt local_options nullglob

  local skill_name
  local target
  for skill_dir in "$skills_src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    target="$skills_home/$skill_name"
    (( _cnt_exists++ ))

    if [[ -L "$target" ]]; then
      if [[ "$(readlink "$target")" != "$skill_dir" ]]; then
        printf "  %-30s %s\n" "$skill_name" "${fg[yellow]}⚠ conflict — linked elsewhere${reset_color}"
        (( _cnt_conflict++ ))
      else
        printf "  %-30s %s\n" "$skill_name" "${fg[green]}✓${reset_color}"
        (( _cnt_already++ ))
      fi
    else
      [[ -e "$target" ]] && mv "$target" "${target}.old"
      ln -s "$skill_dir" "$target"
      printf "  %-30s %s\n" "$skill_name" "${fg[cyan]}→ linked${reset_color}"
      (( _cnt_new++ ))
    fi
  done
}

function skills-sync() {
  local dotfiles="${ZSH_CUSTOM%/omz}"
  local skills_home="$HOME/.copilot/skills"

  mkdir -p "$skills_home"

  setopt local_options nullglob

  local -i _cnt_exists=0 _cnt_already=0 _cnt_new=0 _cnt_removed=0 _cnt_conflict=0

  # Prune broken symlinks
  for link in "$skills_home"/*/; do
    if [[ -L "${link%/}" && ! -e "${link%/}" ]]; then
      printf "  %-30s %s\n" "$(basename "${link%/}")" "${fg[red]}✗ removed${reset_color}"
      rm "${link%/}"
      (( _cnt_removed++ ))
    fi
  done

  # Link personal skills
  _copilot_link_skills_from "$dotfiles/copilot/skills"

  # Link work skills if PRIVATE_DOTFILES is set
  if [[ -n "$PRIVATE_DOTFILES" ]]; then
    _copilot_link_skills_from "$PRIVATE_DOTFILES/copilot/work_skills"
  fi

  local -i _cnt_linked=$(( _cnt_already + _cnt_new ))
  local _summary="${fg[white]}${_cnt_exists} total${reset_color}"
  _summary+="  ${fg[green]}${_cnt_linked} linked${reset_color}"
  _summary+="  ${fg[cyan]}${_cnt_new} new${reset_color}"
  _summary+="  ${fg[red]}${_cnt_removed} removed${reset_color}"
  [[ $_cnt_conflict -gt 0 ]] && _summary+="  ${fg[yellow]}${_cnt_conflict} conflict${reset_color}"
  printf "\n  %s\n" "$_summary"
}
