#!/bin/bash

echo "Installing Brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Creating ssh home directory"
mkdir -p ~/.ssh/home
chmod 700 ~/.ssh/home

echo "Creating ssh work directory"
mkdir -p ~/.ssh/work
chmod 700 ~/.ssh/work

# TODO: prompt for email
echo "Generating github key"
ssh-keygen -t ed25519 -C "dan9186@gmail.com" -f ~/.ssh/github -q -N ""

echo "Generating default rsa key"
ssh-keygen -f ~/.ssh/id_rsa -q -N ""

# vim: filetype=config noexpandtab
