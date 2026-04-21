#!/bin/bash

# macOS system preferences profile
# Applied during bootstrap to establish consistent system settings across all macOS setups.
# Add new settings here organized by category.

# =============================================================================
# Bluetooth
# =============================================================================

set_bluetooth_remote_wake () {
	echo "  → Enabling Bluetooth remote wake"
	defaults -currentHost write com.apple.bluetooth RemoteWakeEnabled 1
}

set_bluetooth_menu_bar () {
	echo "  → Showing Bluetooth in menu bar"
	defaults -currentHost write com.apple.controlcenter Bluetooth -int 2
}

# =============================================================================
# Battery
# =============================================================================

set_battery_show_percentage () {
	echo "  → Showing battery percentage"
	defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
}

# =============================================================================
# Finder
# =============================================================================

set_finder_show_hard_drives () {
	echo "  → Showing hard drives on desktop"
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
}

set_finder_show_all_extensions () {
	echo "  → Showing all file extensions"
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
}

# =============================================================================
# Security
# =============================================================================

set_security_filevault () {
	echo "  → Enabling FileVault disk encryption"
	if fdesetup status | grep -q "FileVault is On"; then
		echo "    FileVault already enabled, skipping"
		return
	fi
	sudo fdesetup enable
	echo "    FileVault enabled — a restart is required to complete encryption"
}

set_security_screensaver_timeout () {
	echo "  → Setting screensaver idle time to 10 minutes"
	defaults -currentHost write com.apple.screensaver idleTime -int 600
}

set_security_screensaver_password () {
	echo "  → Requiring password immediately on screensaver or sleep"
	defaults -currentHost write com.apple.screensaver askForPassword -int 1
	defaults -currentHost write com.apple.screensaver askForPasswordDelay -int 0
}

# =============================================================================
# Network
# =============================================================================

set_network_dns () {
	echo "  → Setting DNS servers to 8.8.8.8 and 1.1.1.1 on all network services"
	local services
	services=$(networksetup -listallnetworkservices | tail -n +2)
	while IFS= read -r svc; do
		networksetup -setdnsservers "$svc" 8.8.8.8 1.1.1.1
	done <<< "$services"
}

# =============================================================================
# Apply
# =============================================================================

echo "Applying macOS preferences"
echo

echo "Bluetooth"
set_bluetooth_remote_wake
set_bluetooth_menu_bar
echo

echo "Battery"
set_battery_show_percentage
echo

echo "Finder"
set_finder_show_hard_drives
set_finder_show_all_extensions
echo

echo "Security"
set_security_filevault
set_security_screensaver_timeout
set_security_screensaver_password
echo

echo "Network"
set_network_dns
echo

killall Finder 2>/dev/null || true
