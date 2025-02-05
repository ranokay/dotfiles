#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
	echo -e "${BLUE}[INFO]${NC} $1" >&2
}

print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

install_xcode_tools() {
	print_info "Checking for Xcode Command Line Tools..."

	# Check if already installed
	if xcode-select -p &>/dev/null; then
		print_success "Xcode Command Line Tools already installed"
		return 0
	fi

	# Try to install
	print_info "Installing Xcode Command Line Tools..."
	if ! xcode-select --install 2>/dev/null; then
		print_error "Failed to install Xcode Command Line Tools"
		return 1
	fi

	# Wait for installation to complete
	print_info "Waiting for installation to complete..."
	while ! xcode-select -p &>/dev/null; do
		sleep 1
	done

	print_success "Xcode Command Line Tools installed"
	return 0
}

install_rosetta() {
	# Only needed on Apple Silicon
	if [[ "$(uname -m)" != "arm64" ]]; then
		print_info "Rosetta not required on this architecture"
		return 0
	fi

	print_info "Checking for Rosetta..."

	# Check if already installed
	if /usr/bin/pgrep -q oahd; then
		print_success "Rosetta already installed"
		return 0
	fi

	# Try to install
	print_info "Installing Rosetta..."
	if ! softwareupdate --install-rosetta --agree-to-license &>/dev/null; then
		print_error "Failed to install Rosetta"
		return 1
	fi

	# Verify installation
	if ! /usr/bin/pgrep -q oahd; then
		print_error "Rosetta installation could not be verified"
		return 1
	fi

	print_success "Rosetta installed"
	return 0
}
