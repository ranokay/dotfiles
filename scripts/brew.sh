#!/usr/bin/env bash

source "./scripts/utils.sh"

install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    print_success "Homebrew installed"
}

install_packages() {
    print_info "Installing packages from Brewfile..."
    
    # Check if Brewfile exists
    if [[ ! -f "config/Brewfile" ]]; then
        print_error "Brewfile not found"
        exit 1
    fi

    # Check for packages to uninstall
    print_info "Checking for packages to uninstall..."
    local cleanup_list
    cleanup_list=$(brew bundle cleanup --file="config/Brewfile")
    
    if [[ -n "$cleanup_list" ]]; then
        print_info "The following packages will be uninstalled:"
        printf "%s\n\n" "$cleanup_list"
        
        if ask_confirmation "Do you want to proceed with uninstallation?"; then
            print_info "Cleaning up packages..."
            if ! brew bundle cleanup --force --file="config/Brewfile"; then
                print_error "Failed to clean up some packages"
                exit 1
            fi
            print_success "Packages cleaned up"
        else
            print_info "Skipping cleanup"
        fi
    else
        print_info "No packages to uninstall"
    fi

    # Install packages
    if ! brew bundle --file="config/Brewfile"; then
        print_error "Failed to install some packages"
        exit 1
    fi

    print_success "Packages installed successfully"
} 