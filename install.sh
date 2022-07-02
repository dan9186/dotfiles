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

$(hash ack 2>/dev/null) && link_file ackrc
$(hash git 2>/dev/null) && link_file gitconfig
$(hash tmux 2>/dev/null) && link_file tmux.conf
$(hash wget 2>/dev/null) && link_file wgetrc
$(hash zsh 2>/dev/null) && link_file zprofile \
	&& link_file zshrc
$(hash ssh 2>/dev/null) && link_file sshconfig ssh/config

# vim: filetype=config noexpandtab
