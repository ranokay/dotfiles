#!/bin/bash

# Helper function to safely write defaults
write_default() {
	local domain="$1"
	local key="$2"
	local type="$3"
	local value="$4"

	# Check if domain exists
	if ! defaults read "$domain" >/dev/null 2>&1; then
		print_error "Domain '$domain' does not exist"
		return 1
	fi

	# Try to write the default
	if ! defaults write "$domain" "$key" "$type" "$value" 2>/dev/null; then
		print_error "Failed to write setting: $domain $key"
		return 1
	fi

	# Verify the write was successful
	if ! defaults read "$domain" "$key" >/dev/null 2>&1; then
		print_error "Failed to verify setting: $domain $key"
		return 1
	fi

	return 0
}

# Helper function to write defaults with error tracking
configure_setting() {
	local description="$1"
	shift

	print_info "Setting $description..."
	if write_default "$@"; then
		return 0
	else
		print_error "Failed to set $description"
		return 1
	fi
}

configure_macos() {
	print_info "Configuring macOS settings..."
	local errors=0

	# Dock settings
	local dock_settings=(
		"Dock auto-hide:com.apple.dock:autohide:-bool:true"
		"Dock auto-hide delay:com.apple.dock:autohide-delay:-float:0"
		"Dock auto-hide animation:com.apple.dock:autohide-time-modifier:-float:0.4"
		"Dock magnification:com.apple.dock:magnification:-bool:true"
		"Dock large size:com.apple.dock:largesize:-int:52"
		"Dock size:com.apple.dock:tilesize:-int:32"
		"Dock hidden apps:com.apple.dock:showhidden:-bool:true"
		"Dock recents:com.apple.dock:show-recents:-bool:false"
		"Dock static only:com.apple.dock:static-only:-bool:true"
	)

	for setting in "${dock_settings[@]}"; do
		IFS=: read -r description domain key type value <<<"$setting"
		configure_setting "$description" "$domain" "$key" "$type" "$value" || ((errors++))
	done

	# Finder settings
	local finder_settings=(
		"Finder view style:com.apple.finder:FXPreferredViewStyle:-string:Nlsv"
		"Finder path in title:com.apple.finder:_FXShowPosixPathInTitle:-bool:false"
		"Finder sort folders first:com.apple.finder:_FXSortFoldersFirst:-bool:true"
		"Finder search scope:com.apple.finder:FXDefaultSearchScope:-string:SCcf"
		"Finder path bar:com.apple.finder:ShowPathbar:-bool:true"
		"Finder status bar:com.apple.finder:ShowStatusBar:-bool:true"
		"Finder hidden files:com.apple.finder:AppleShowAllFiles:-bool:true"
		"Finder file extensions:com.apple.finder:AppleShowAllExtensions:-bool:true"
	)

	for setting in "${finder_settings[@]}"; do
		IFS=: read -r description domain key type value <<<"$setting"
		configure_setting "$description" "$domain" "$key" "$type" "$value" || ((errors++))
	done

	# Global settings
	local global_settings=(
		"Global show extensions:NSGlobalDomain:AppleShowAllExtensions:-bool:true"
		"Global 24-hour time:NSGlobalDomain:AppleICUForce24HourTime:-bool:true"
		"Global key hold:NSGlobalDomain:ApplePressAndHoldEnabled:-bool:false"
		"Global dark mode:NSGlobalDomain:AppleInterfaceStyle:-string:Dark"
		"Global key repeat:NSGlobalDomain:KeyRepeat:-int:2"
		"Global initial key repeat:NSGlobalDomain:InitialKeyRepeat:-int:15"
		"Global tap behavior:NSGlobalDomain:com.apple.mouse.tapBehavior:-int:1"
	)

	for setting in "${global_settings[@]}"; do
		IFS=: read -r description domain key type value <<<"$setting"
		configure_setting "$description" "$domain" "$key" "$type" "$value" || ((errors++))
	done

	# Trackpad settings
	local trackpad_settings=(
		"Trackpad clicking:com.apple.driver.AppleBluetoothMultitouch.trackpad:Clicking:-bool:true"
		"Trackpad three finger drag:com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadThreeFingerDrag:-bool:true"
	)

	for setting in "${trackpad_settings[@]}"; do
		IFS=: read -r description domain key type value <<<"$setting"
		configure_setting "$description" "$domain" "$key" "$type" "$value" || ((errors++))
	done

	# Login window settings (requires sudo)
	if [ "$EUID" -eq 0 ]; then
		local login_settings=(
			"Login window text:/Library/Preferences/com.apple.loginwindow:LoginwindowText:-string:contact@ranokay.com"
			"Login window guest:/Library/Preferences/com.apple.loginwindow:GuestEnabled:-bool:false"
		)

		for setting in "${login_settings[@]}"; do
			IFS=: read -r description domain key type value <<<"$setting"
			configure_setting "$description" "$domain" "$key" "$type" "$value" || ((errors++))
		done
	else
		print_warning "Skipping login window settings (requires root privileges)"
	fi

	# Enable Touch ID for sudo
	if [ "$EUID" -eq 0 ]; then
		print_info "Configuring Touch ID for sudo..."
		if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
			if ! sudo sed -i '' '2i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo; then
				print_error "Failed to enable Touch ID for sudo"
				((errors++))
			fi
		else
			print_success "Touch ID for sudo already configured"
		fi
	else
		print_warning "Skipping Touch ID configuration (requires root privileges)"
	fi

	# Restart affected applications
	print_info "Restarting affected applications..."
	local apps=("Dock" "Finder" "SystemUIServer")
	for app in "${apps[@]}"; do
		if pgrep "$app" >/dev/null; then
			if ! killall "$app" 2>/dev/null; then
				print_error "Failed to restart $app"
				((errors++))
			fi
		else
			print_warning "$app is not running"
		fi
	done

	if [ "$errors" -eq 0 ]; then
		print_success "macOS settings configured successfully"
		return 0
	else
		print_error "macOS settings configured with $errors error(s)"
		return 1
	fi
}
