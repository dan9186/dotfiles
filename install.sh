#!/bin/bash

cd "$(dirname "$0")"

function relink () {
	# Symlinks $1 to $2. An existing correct symlink is left alone, a wrong or
	# broken symlink is replaced, and a real file or directory is moved to
	# <dest>.old first.
	if (( $# > 1 )); then
		local src=$1
		local dest=$2
		local label=${3:-$(basename "$dest")}

		if [ -L "$dest" ]; then
			if [ "$(readlink "$dest")" = "$src" ]; then
				echo "  ✓ $label already linked, skipping."
				return
			fi
			echo "  ↻ $label linked elsewhere, re-pointing"
			rm "$dest"
		elif [ -e "$dest" ]; then
			echo "  ⚠ $label exists, moving it out of the way"
			mv "$dest" "${dest}.old"
		else
			echo "  → Linking $label"
		fi

		mkdir -p "$(dirname "$dest")"
		ln -s "$src" "$dest"
	fi
}

function link_skill () {
	# Links skill leaf directory $1 into each target skills root ($2...).
	if (( $# > 1 )); then
		local skill_path=$1
		shift
		local skill_name
		skill_name=$(basename "$skill_path")

		local src="$skill_path"
		[ "${src#/}" = "$src" ] && src="$PWD/$skill_path"

		local root
		for root in "$@"; do
			relink "$src" "$root/$skill_name" "Skill $skill_name ($(basename "$(dirname "$root")"))"
		done

		echo
	fi
}

function link_skills_recursive () {
	# Recursively finds skill leaf directories under $1 (a directory
	# containing a SKILL.md file directly is a leaf; anything else is an
	# organizational category folder to recurse into) and links each leaf into
	# every target skills root ($2...).
	# _linked_skill_names tracks "name:path" entries seen so far (newline
	# separated) to warn on and skip basename collisions across the tree.
	# Uses plain string tracking rather than associative arrays for bash 3.2
	# compatibility (default /bin/bash on macOS).
	if (( $# > 1 )); then
		local dir=$1
		shift

		[ -d "$dir" ] || return

		if [ -f "$dir/SKILL.md" ]; then
			local skill_name
			skill_name=$(basename "$dir")

			local existing
			existing=$(printf '%s\n' "$_linked_skill_names" | grep "^${skill_name}:" | cut -d: -f2-)
			if [ -n "$existing" ]; then
				echo "  ⚠ Skill $skill_name already found at $existing, skipping duplicate at $dir"
				echo
				return
			fi
			_linked_skill_names="${_linked_skill_names}
${skill_name}:${dir}"
			link_skill "$dir" "$@"
			return
		fi

		local sub
		for sub in "$dir"/*/; do
			[ -d "$sub" ] && link_skills_recursive "${sub%/}" "$@"
		done
	fi
}

function agent_skill_targets () {
	# Prints the skills root of each installed agent tool, one per line.
	hash copilot 2>/dev/null && echo "$HOME/.copilot/skills"
	hash claude 2>/dev/null && echo "$HOME/.claude/skills"
	return 0
}

function link_file () {
	if (( $# > 0 )); then
		FILE=$1
		DEST=$FILE

		if [ -n "$2" ]; then
			DEST=$2
		fi

		relink "$PWD/$FILE" "$HOME/.$DEST" "$FILE"

		echo
	fi
}

function install_font () {
	if (( $# > 0 )); then
		submodule nerd-font

		FONT=$1
		echo "  → Installing font $FONT"

		./fonts/install.sh "$FONT" >/dev/null 2>&1

		echo
	fi
}

function submodule () {
	if (( $# > 0 )); then
		MOD=$1

		deps git grep cut && \
			$(git submodule status | grep "$MOD" | cut -d " " -f 1 | grep -v '^-')
	fi
}

function deps () {
	for dep in "$@"; do
		hash "$dep" 2>/dev/null || return 1
	done
}

deps ack && link_file ackrc
deps rg && link_file ripgreprc
deps git && link_file gitconfig
deps gpg-agent && link_file gpg-agent.conf gnupg/gpg-agent.conf
deps ssh && link_file sshconfig ssh/config
deps tmux && link_file tmux.conf
deps wget && link_file wgetrc
deps zsh && \
  link_file zprofile && \
  link_file zshrc.omz zshrc
deps copilot && {
  link_file agents/instructions.md copilot/copilot-instructions.md
  link_file agents/copilot/lsp-config.json copilot/lsp-config.json
  link_file agents/mcp.json copilot/mcp-config.json
}
deps claude && {
  link_file agents/instructions.md claude/CLAUDE.md
  for rule in agents/.github/instructions/*.instructions.md; do
    link_file "$rule" "claude/rules/$(basename "$rule" .instructions.md).md"
  done
  ./agents/sync.sh
  echo
}

SKILL_TARGETS=()
while IFS= read -r target; do
  SKILL_TARGETS+=("$target")
done < <(agent_skill_targets)
if (( ${#SKILL_TARGETS[@]} > 0 )); then
  _linked_skill_names=""
  link_skills_recursive agents/skills "${SKILL_TARGETS[@]}"
fi

# TODO: setup check for osx application
link_file alacritty.toml
link_file alacritty_themes alacritty/themes

install_font 'DejaVuSansMono'
