#!/bin/bash

clone_dotfiles () {
	git clone https://github.com/dan9186/dotfiles.git $HOME/dotfiles
}

base_ssh_dir="$HOME/.ssh"

install_brew () {
	echo "Installing Brew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_omz () {
  echo "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

init_ssh_dir () {
  if [ -z "$1" ]; then
    return
  fi

  local name=$1

	echo "Creating ssh $name directory"
	mkdir -p "$base_ssh_dir/$name"
	chmod 700 "$base_ssh_dir/$name"
}

init_service_ssh_key () {
  if [ -z "$1" ]; then
    return
  fi

  local service=$1

  echo "Init ssh keys for $service"

  until [ -n "$email" ]; do
    echo -n "Email: "
    read email
  done

  echo "Generating key for $service with $email"
  ssh-keygen -t ed25519 -C "$email" -f "$base_ssh_dir/$service" -q -N ""
}

init_default_ssh_key () {
  echo "Generating default rsa key"
  ssh-keygen -f "$base_ssh_dir/id_rsa" -q -N ""
}

init_ssh () {
  init_ssh_dir "home"
  init_ssh_dir "work"
  init_service_ssh_key "github"
  init_default_ssh_key
}

set_hostname () {
	local hostname=""
	until [ -n "$hostname" ]; do
		echo -n "Hostname: "
		read hostname
	done

	local os
	os="$(uname -s 2>/dev/null || echo "Windows")"

	case "$os" in
		Darwin)
			echo "Setting hostname on macOS: $hostname"
			sudo scutil --set HostName "$hostname"
			sudo scutil --set LocalHostName "$hostname"
			sudo scutil --set ComputerName "$hostname"
			;;
		Linux)
			echo "Setting hostname on Linux: $hostname"
			if command -v hostnamectl &>/dev/null; then
				sudo hostnamectl set-hostname "$hostname"
			else
				echo "$hostname" | sudo tee /etc/hostname > /dev/null
				sudo hostname "$hostname"
			fi
			;;
		CYGWIN*|MINGW*|MSYS*)
			echo "Setting hostname on Windows: $hostname"
			powershell.exe -Command "Rename-Computer -NewName '$hostname' -Force"
			;;
		*)
			echo "Unknown OS ($os), skipping hostname change"
			;;
	esac
}

clone_dotfiles
install_brew
install_omz
init_ssh
set_hostname
