#!/bin/bash

setup_homebrew() {
	print_info "Checking for Homebrew..."

	# Check if Homebrew is already installed
	if command -v brew &>/dev/null; then
		print_success "Homebrew already installed"
		return 0
	fi

	print_info "Installing Homebrew..."

	# Check curl is available
	if ! command -v curl &>/dev/null; then
		print_error "curl is required but not installed"
		return 1
	fi

	# Download and install Homebrew
	if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
		print_error "Failed to install Homebrew"
		return 1
	fi

	# Configure Homebrew for Apple Silicon
	if [[ "$(uname -m)" == "arm64" ]]; then
		print_info "Configuring Homebrew for Apple Silicon..."

		# Check if .zprofile exists
		if [ ! -f "$HOME/.zprofile" ]; then
			touch "$HOME/.zprofile" || {
				print_error "Failed to create .zprofile"
				return 1
			}
		fi

		# Add Homebrew to PATH
		if ! echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"; then
			print_error "Failed to update .zprofile"
			return 1
		fi

		# Source Homebrew environment
		if ! eval "$(/opt/homebrew/bin/brew shellenv)"; then
			print_error "Failed to initialize Homebrew environment"
			return 1
		fi
	fi

	print_success "Homebrew installed and configured"
	return 0
}

install_brew_packages() {
	print_info "Installing Homebrew packages..."

	# Check if Homebrew is installed
	if ! command -v brew &>/dev/null; then
		print_error "Homebrew is not installed"
		return 1
	fi

	# Check if Brewfile exists
	if [ ! -f "$SCRIPT_DIR/config/Brewfile" ]; then
		print_error "Brewfile not found at $SCRIPT_DIR/config/Brewfile"
		return 1
	fi

	# Update Homebrew
	print_info "Updating Homebrew..."
	if ! brew update; then
		print_error "Failed to update Homebrew"
		return 1
	fi

	# Install from Brewfile
	print_info "Installing packages from Brewfile..."
	if ! brew bundle --file="$SCRIPT_DIR/config/Brewfile"; then
		print_error "Failed to install packages from Brewfile"
		return 1
	fi

	# Cleanup old versions
	print_info "Cleaning up old versions..."
	if ! brew cleanup; then
		print_warning "Failed to cleanup old versions"
	fi

	print_success "Homebrew packages installed successfully"
	return 0
}
