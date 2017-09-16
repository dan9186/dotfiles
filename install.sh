#!/bin/bash

function link_file () {
	if (( $# > 0 )); then
		FILE=$1
		if [ -f "$HOME/.$FILE" ]; then
			echo "$FILE dotfile found, moving it out of the way"
			mv "$HOME/.$FILE" "$HOME/.$FILE.old"
		fi

		echo "Linking $FILE to \$HOME/.$FILE"
		ln -s "$PWD/$FILE" "$HOME/.$FILE"
	fi
}

$(hash git 2>/dev/null) && link_file gitconfig
$(hash git 2>/dev/null) && link_file projects
$(hash tmux 2>/dev/null) && link_file tmux.conf
$(hash zsh 2>/dev/null) && link_file zprofile && link_file zshrc
