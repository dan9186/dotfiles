#!/bin/bash

if [ $(hash git 2>/dev/null) ]; then
	ln -s $PWD/gitconfig $HOME/.gitconfig
fi

if [ $(hash tmux 2>/dev/null) ]; then
	ln -s $PWD/tmux.conf $HOME/.tmux.conf
fi

if [ $(hash zsh 2>/dev/null) ]; then
	ln -s $PWD/zprofile $HOME/.zprofile
	ln -s $PWD/zshrc $HOME/.zshrc
fi
