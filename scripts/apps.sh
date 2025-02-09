#!/usr/bin/env bash

source "./scripts/utils.sh"
source "./scripts/brew.sh"

install_applications() {
    print_info "Starting applications installation..."

    # Install Homebrew and packages
    install_homebrew
    install_packages

    # Configure Git
    source "./scripts/git.sh"
    configure_git

    print_success "Applications installation completed!"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_applications
fi 