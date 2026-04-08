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

    if [[ -L "$target" ]]; then
      if [[ "$(readlink "$target")" != "$skill_dir" ]]; then
        printf "  %-30s %s\n" "$skill_name" "${fg[yellow]}⚠ conflict — linked elsewhere${reset_color}"
      else
        printf "  %-30s %s\n" "$skill_name" "${fg[green]}✓${reset_color}"
      fi
    else
      [[ -e "$target" ]] && mv "$target" "${target}.old"
      ln -s "$skill_dir" "$target"
      printf "  %-30s %s\n" "$skill_name" "${fg[cyan]}→ linked${reset_color}"
    fi
  done
}

function skills-sync() {
  local dotfiles="${ZSH_CUSTOM%/omz}"
  local skills_home="$HOME/.copilot/skills"

  mkdir -p "$skills_home"

  setopt local_options nullglob

  # Prune broken symlinks
  for link in "$skills_home"/*/; do
    if [[ -L "${link%/}" && ! -e "${link%/}" ]]; then
      printf "  %-30s %s\n" "$(basename "${link%/}")" "${fg[red]}✗ removed${reset_color}"
      rm "${link%/}"
    fi
  done

  # Link personal skills
  _copilot_link_skills_from "$dotfiles/copilot/skills"

  # Link work skills if PRIVATE_DOTFILES is set
  if [[ -n "$PRIVATE_DOTFILES" ]]; then
    _copilot_link_skills_from "$PRIVATE_DOTFILES/copilot/work_skills"
  fi
}
