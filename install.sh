#!/usr/bin/env bash

# Source utility functions
source "./scripts/utils.sh"

# Perform initial checks
source "./scripts/checks.sh"
check_system
check_xcode

# Install Homebrew and packages
source "./scripts/brew.sh"
install_homebrew
install_packages

# Configure Git
source "./scripts/git.sh"
configure_git

# Prompt for system configuration
if ask_confirmation "Do you want to apply macOS system configuration?"; then
    source "./scripts/macos.sh"
    apply_macos_configuration
else
    print_success "Installation completed successfully!"
fi 