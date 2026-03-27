#!/bin/bash

OS="$(uname -s 2>/dev/null || echo "Windows")"

clone_dotfiles () {
	git clone https://github.com/dan9186/dotfiles.git "$HOME/dotfiles"
}

base_ssh_dir="$HOME/.ssh"

update_linux_package_manager () {
	if command -v apt-get &>/dev/null; then
		echo "Updating apt"
		sudo apt-get update -y
	elif command -v dnf &>/dev/null; then
		echo "Updating dnf"
		sudo dnf check-update -y || true
	elif command -v yum &>/dev/null; then
		echo "Updating yum"
		sudo yum check-update -y || true
	elif command -v pacman &>/dev/null; then
		echo "Syncing pacman"
		sudo pacman -Sy
	elif command -v zypper &>/dev/null; then
		echo "Refreshing zypper"
		sudo zypper refresh
	else
		echo "No supported package manager found on Linux"
		return 1
	fi
}

update_winget () {
	if command -v winget &>/dev/null; then
		echo "Updating winget packages"
		winget upgrade --all
	else
		echo "winget not found — install App Installer from the Microsoft Store: https://aka.ms/getwinget"
		return 1
	fi
}

install_package_manager () {
	case "$OS" in
		Darwin)
			echo "Installing Homebrew"
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			;;
		Linux)
			update_linux_package_manager
			;;
		CYGWIN*|MINGW*|MSYS*)
			update_winget
			;;
		*)
			echo "Unknown OS ($OS), skipping package manager installation"
			;;
	esac
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

	case "$OS" in
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
			echo "Unknown OS ($OS), skipping hostname change"
			;;
	esac
}

clone_dotfiles
install_package_manager
install_omz
init_ssh
set_hostname
