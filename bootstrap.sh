#!/bin/bash

OS="$(uname -s 2>/dev/null || echo "Windows")"

ensure_sudo () {
	if command -v sudo &>/dev/null; then
		return
	fi

	echo "Installing sudo"
	case "$OS" in
		Linux)
			if [ "$(id -u)" -ne 0 ]; then
				echo "sudo not found and not running as root — install sudo or re-run as root"
				return 1
			fi
			if command -v apt-get &>/dev/null; then
				apt-get update -y && apt-get install -y sudo
			elif command -v dnf &>/dev/null; then
				dnf install -y sudo
			elif command -v yum &>/dev/null; then
				yum install -y sudo
			elif command -v pacman &>/dev/null; then
				pacman -Sy --noconfirm sudo
			elif command -v zypper &>/dev/null; then
				zypper refresh && zypper install -y sudo
			else
				echo "No supported package manager found, cannot install sudo"
				return 1
			fi
			;;
		CYGWIN*|MINGW*|MSYS*)
			;;
	esac
}

ensure_curl () {
	if command -v curl &>/dev/null; then
		return
	fi

	echo "Installing curl"
	case "$OS" in
		Linux)
			if command -v apt-get &>/dev/null; then
				sudo apt-get install -y curl
			elif command -v dnf &>/dev/null; then
				sudo dnf install -y curl
			elif command -v yum &>/dev/null; then
				sudo yum install -y curl
			elif command -v pacman &>/dev/null; then
				sudo pacman -S --noconfirm curl
			elif command -v zypper &>/dev/null; then
				sudo zypper install -y curl
			else
				echo "No supported package manager found, cannot install curl"
				return 1
			fi
			;;
		CYGWIN*|MINGW*|MSYS*)
			pacman -S --noconfirm curl
			;;
		*)
			echo "curl not found and cannot be installed automatically on $OS"
			return 1
			;;
	esac
}

ensure_git () {
	if command -v git &>/dev/null; then
		return
	fi

	echo "Installing git"
	case "$OS" in
		Darwin)
			xcode-select --install
			echo "Xcode Command Line Tools installation started — re-run bootstrap once it completes"
			exit 0
			;;
		Linux)
			if command -v apt-get &>/dev/null; then
				sudo apt-get install -y git
			elif command -v dnf &>/dev/null; then
				sudo dnf install -y git
			elif command -v yum &>/dev/null; then
				sudo yum install -y git
			elif command -v pacman &>/dev/null; then
				sudo pacman -S --noconfirm git
			elif command -v zypper &>/dev/null; then
				sudo zypper install -y git
			else
				echo "No supported package manager found, cannot install git"
				return 1
			fi
			;;
		CYGWIN*|MINGW*|MSYS*)
			pacman -S --noconfirm git
			;;
		*)
			echo "git not found and cannot be installed automatically on $OS"
			return 1
			;;
	esac
}

clone_dotfiles () {
	if [ -d "$HOME/dotfiles" ]; then
		echo "dotfiles already cloned, skipping"
		return
	fi
	git clone https://github.com/dan9186/dotfiles.git "$HOME/dotfiles"
}

ensure_prerequisites () {
	ensure_sudo
	ensure_curl
	ensure_git
	ensure_ssh_keygen
}

ensure_ssh_keygen () {
	if command -v ssh-keygen &>/dev/null; then
		return
	fi

	echo "Installing ssh-keygen"
	case "$OS" in
		Linux)
			if command -v apt-get &>/dev/null; then
				sudo apt-get install -y openssh-client
			elif command -v dnf &>/dev/null; then
				sudo dnf install -y openssh-clients
			elif command -v yum &>/dev/null; then
				sudo yum install -y openssh-clients
			elif command -v pacman &>/dev/null; then
				sudo pacman -S --noconfirm openssh
			elif command -v zypper &>/dev/null; then
				sudo zypper install -y openssh
			else
				echo "No supported package manager found, cannot install ssh-keygen"
				return 1
			fi
			;;
		CYGWIN*|MINGW*|MSYS*)
			pacman -S --noconfirm openssh
			;;
		*)
			echo "ssh-keygen not found and cannot be installed automatically on $OS"
			return 1
			;;
	esac
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
			if command -v brew &>/dev/null; then
				echo "Homebrew already installed, skipping"
				return
			fi
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

ensure_zsh () {
	if command -v zsh &>/dev/null; then
		return
	fi

	echo "Installing zsh"
	case "$OS" in
		Linux)
			if command -v apt-get &>/dev/null; then
				sudo apt-get install -y zsh
			elif command -v dnf &>/dev/null; then
				sudo dnf install -y zsh
			elif command -v yum &>/dev/null; then
				sudo yum install -y zsh
			elif command -v pacman &>/dev/null; then
				sudo pacman -S --noconfirm zsh
			elif command -v zypper &>/dev/null; then
				sudo zypper install -y zsh
			else
				echo "No supported package manager found, cannot install zsh"
				return 1
			fi
			;;
		CYGWIN*|MINGW*|MSYS*)
			pacman -S --noconfirm zsh
			;;
	esac
}

install_packages () {
	case "$OS" in
		Darwin)
			echo "Installing packages from Brewfile"
			brew bundle --file="$HOME/dotfiles/Brewfile"
			;;
		*)
			echo "Package installation via Brewfile not supported on $OS, skipping"
			;;
	esac
}

install_omz () {
	if [ -d "$HOME/.oh-my-zsh" ]; then
		echo "Oh My Zsh already installed, skipping"
		return
	fi
	echo "Installing Oh My Zsh"
	ensure_zsh
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

  if [ -f "$base_ssh_dir/$service" ]; then
    echo "SSH key for $service already exists, skipping"
    return
  fi

  echo "Init ssh keys for $service"

  until [ -n "$email" ]; do
    echo -n "Email: "
    read email
  done

  echo "Generating key for $service with $email"
  ssh-keygen -t ed25519 -C "$email" -f "$base_ssh_dir/$service" -q -N ""
}

init_default_ssh_key () {
  if [ -f "$base_ssh_dir/id_rsa" ]; then
    echo "Default SSH key already exists, skipping"
    return
  fi
  echo "Generating default rsa key"
  ssh-keygen -f "$base_ssh_dir/id_rsa" -q -N ""
}

init_ssh () {
  init_ssh_dir "home"
  init_ssh_dir "work"
  init_service_ssh_key "github"
  init_default_ssh_key
}

in_container () {
	[ -f /.dockerenv ] || \
	[ -f /run/.containerenv ] || \
	grep -qE 'docker|lxc|containerd' /proc/1/cgroup 2>/dev/null
}

set_hostname () {
	if in_container; then
		echo "Running in a container, skipping hostname change"
		return
	fi

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
			local set=false
			if command -v hostnamectl &>/dev/null; then
				sudo hostnamectl set-hostname "$hostname" && set=true
			fi
			if [ "$set" = false ]; then
				echo "$hostname" | sudo tee /etc/hostname > /dev/null
				sudo hostname "$hostname" \
					|| echo "Warning: hostname written to /etc/hostname but runtime change failed — a reboot is required to apply it"
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

ensure_prerequisites
install_package_manager
clone_dotfiles
install_packages
install_omz
init_ssh
set_hostname
