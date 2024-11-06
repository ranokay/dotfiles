#!/bin/bash

# Function to print messages with colors
print_success() { echo -e "\033[32m[SUCCESS]\033[0m $1"; }
print_info() { echo -e "\033[34m[INFO]\033[0m $1"; }
print_warning() { echo -e "\033[33m[WARNING]\033[0m $1"; }
print_error() { echo -e "\033[31m[ERROR]\033[0m $1"; }

# Step 1: Install Xcode Command Line Tools
print_info "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    print_info "Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    if [ $? -eq 0 ]; then
        print_success "Xcode Command Line Tools installed successfully."
    else
        print_error "Failed to install Xcode Command Line Tools."
        exit 1
    fi
else
    print_success "Xcode Command Line Tools are already installed."
fi

# Step 2: Install Rosetta for Apple Silicon if needed
if [[ "$(uname -m)" == "arm64" ]]; then
    print_info "Checking for Rosetta on Apple Silicon..."
    if /usr/bin/pgrep -q oahd; then
        print_success "Rosetta is already installed."
    else
        print_info "Rosetta not found. Installing..."
        softwareupdate --install-rosetta --agree-to-license
        if [ $? -eq 0 ]; then
            print_success "Rosetta installed successfully."
        else
            print_error "Failed to install Rosetta."
            exit 1
        fi
    fi
else
    print_warning "Rosetta installation skipped (not required for Intel Macs)."
fi

# Step 3: Install Nix using Determinate Systems' install script
print_info "Checking if Nix is installed..."
if ! command -v nix &>/dev/null; then
    print_info "Nix not found. Installing using Determinate Systems' installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    if [ $? -eq 0 ]; then
        print_success "Nix installed successfully."
    else
        print_error "Failed to install Nix."
        exit 1
    fi
else
    print_success "Nix is already installed."
fi

print_success "Pre-installation steps completed successfully. Please restart your terminal to ensure Nix is available."
