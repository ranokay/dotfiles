#!/usr/bin/env bash

source "./scripts/utils.sh"

check_system() {
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is only for macOS"
        exit 1
    fi

    # Check macOS version
    if [[ "$(sw_vers -productVersion)" < "12.0.0" ]]; then
        print_error "This script requires macOS 12.0 or later"
        exit 1
    fi

    print_success "System checks passed"
}

check_xcode() {
    # Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        print_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation to complete
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
    fi

    print_success "Xcode Command Line Tools installed"
} 