#!/bin/bash

function link_file () {
	if (( $# > 0 )); then
		FILE=$1
		if [ -f "$HOME/.$FILE" ]; then
			mv "$HOME/.$FILE" "$HOME/.$FILE.old"
		fi
		ln -s "$PWD/$FILE" "$HOME/.$FILE"
	fi
}

if [ ! $(hash git 2>/dev/null) ]; then
	link_file gitconfig
fi

if [ ! $(hash tmux 2>/dev/null) ]; then
	link_file tmux.conf
fi

if [ ! $(hash zsh 2>/dev/null) ]; then
	link_file zprofile
	link_file zshrc
fi
