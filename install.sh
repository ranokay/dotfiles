#!/bin/bash

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper scripts
source "$SCRIPT_DIR/scripts/setup.sh"
source "$SCRIPT_DIR/scripts/brew.sh"
source "$SCRIPT_DIR/scripts/macos.sh"

# Print colored output
print_info "Starting installation..."

# Check and install Xcode Command Line Tools
install_xcode_tools

# Check and install Rosetta 2 (if on Apple Silicon)
install_rosetta

# Install and configure Homebrew
setup_homebrew

# Install applications from Brewfile
install_brew_packages

# Configure macOS settings
configure_macos

print_success "Installation complete! Some changes may require a restart to take effect."
