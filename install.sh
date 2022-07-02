#!/bin/bash

function link_file () {
	if (( $# > 0 )); then
		FILE=$1
		LINK=$FILE

		if [ -n "$2" ]; then
			LINK=$2
		fi

		if [ -f "$HOME/.$FILE" ]; then
			echo "$FILE dotfile found, moving it out of the way"
			mv "$HOME/.$FILE" "$HOME/.$FILE.old"
		fi

		echo "Linking $FILE to \$HOME/.$LINK"
		ln -s "$PWD/$FILE" "$HOME/.$LINK"

		echo -ne "\n"
	fi
}

$(hash ack 2>/dev/null) && link_file ackrc
$(hash git 2>/dev/null) && link_file gitconfig
$(hash tmux 2>/dev/null) && link_file tmux.conf
$(hash wget 2>/dev/null) && link_file wgetrc
$(hash zsh 2>/dev/null) && link_file zprofile && link_file zshrc

$(hash ssh 2>/dev/null) && mkdir -p "$HOME/.ssh" && ln -s "$PWD/sshconfig" "$HOME/.ssh/config"
