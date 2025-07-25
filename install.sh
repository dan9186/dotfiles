#!/bin/bash

function link_file () {
	if (( $# > 0 )); then
		FILE=$1
		DEST=$FILE

		if [ -n "$2" ]; then
			DEST=$2
		fi

		if [ -L "$HOME/.$DEST" ]; then
			echo "$FILE already symlinked, skipping."
		else
			if [ -f "$HOME/.$DEST" ]; then
				echo "$FILE dotfile found, moving it out of the way"
				mv "$HOME/.$DEST" "$HOME/.$DEST.old"
			else
				mkdir -p "$HOME/.$(dirname $DEST)"
			fi

			echo "Linking $FILE to \$HOME/.$DEST"
			ln -s "$PWD/$FILE" "$HOME/.$DEST"
		fi

		echo -ne "\n"
	fi
}

function install_font () {
	if (( $# > 0 )); then
		submodule nerd-font

		FONT=$1
		echo "Installing font $FONT"

		./fonts/install.sh $FONT 2>&1>/dev/null

		echo -ne "\n"
	fi
}

function submodule () {
	if (( $# > 0 )); then
		MOD=$1

		deps git grep cut && \
			$(git submodule status | grep $MOD | cut -d " " -f 1 | grep -v '^-')
	fi
}

function deps () {
	for dep in $@; do
		$(hash $dep 2>/dev/null)
	done
}


deps ack && link_file ackrc
deps git && link_file gitconfig
deps gpg-agent && link_file gpg-agent.conf gnupg/gpg-agent.conf
deps ssh && link_file sshconfig ssh/config
deps tmux && link_file tmux.conf
deps wget && link_file wgetrc
deps zsh && link_file zprofile && link_file zshrc.omz zshrc

# TODO: setup check for osx application
link_file alacritty.toml
link_file alacritty_themes alacritty/themes

install_font 'DejaVuSansMono'
