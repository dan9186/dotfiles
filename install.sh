#!/bin/bash

cd "$(dirname "$0")"

function link_file () {
	if (( $# > 0 )); then
		FILE=$1
		DEST=$FILE

		if [ -n "$2" ]; then
			DEST=$2
		fi

		if [ -L "$HOME/.$DEST" ]; then
			echo "  ✓ $FILE already symlinked, skipping."
		else
			if [ -f "$HOME/.$DEST" ] || [ -d "$HOME/.$DEST" ]; then
				echo "  ⚠ $FILE exists, moving it out of the way"
				mv "$HOME/.$DEST" "$HOME/.$DEST.old"
			fi
			mkdir -p "$HOME/.$(dirname "$DEST")"

			echo "  → Linking $FILE to \$HOME/.$DEST"
			ln -s "$PWD/$FILE" "$HOME/.$DEST"
		fi

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
	for dep in $@; do
		$(hash $dep 2>/dev/null)
	done
}

function link_skill () {
	if (( $# > 0 )); then
		local skill_path=$1
		local skill_name
		skill_name=$(basename "$skill_path")
		local target="$HOME/.copilot/skills/$skill_name"

		if [ -L "$target" ]; then
			echo "  ✓ Skill $skill_name already linked, skipping."
		else
			if [ -e "$target" ]; then
				echo "  ⚠ Skill $skill_name exists, moving it out of the way"
				mv "$target" "${target}.old"
			fi
			echo "  → Linking skill $skill_name"
			ln -s "$PWD/$skill_path" "$target"
		fi

		echo
	fi
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
  link_file copilot/copilot-instructions.md copilot/copilot-instructions.md
  link_file copilot/lsp-config.json copilot/lsp-config.json
  link_file copilot/mcp-config.json copilot/mcp-config.json
  mkdir -p "$HOME/.copilot/skills"
  for skill_dir in copilot/skills/*/; do
    [ -d "$skill_dir" ] && link_skill "$skill_dir"
  done
}

# TODO: setup check for osx application
link_file alacritty.toml
link_file alacritty_themes alacritty/themes

install_font 'DejaVuSansMono'
