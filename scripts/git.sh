#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Function to check if git config matches expected value
check_git_config() {
    local key="$1"
    local expected_value="$2"
    local current_value

    current_value=$(git config --global --get "$key")

    if [[ "$current_value" == "$expected_value" ]]; then
        return 0  # Config matches
    else
        return 1  # Config doesn't match
    fi
}

# Function to set git config if it doesn't match
set_git_config() {
    local key="$1"
    local value="$2"
    local description="$3"

    if ! check_git_config "$key" "$value"; then
        git config --global "$key" "$value"
        print_success "Updated $description"
    fi
}

configure_git() {
    print_info "Checking Git configuration..."

    # Basic Git configuration
    set_git_config "user.name" "ranokay" "Git username"
    set_git_config "user.email" "github@ranokay.com" "Git email"

    # Configure commit signing with 1Password
    set_git_config "gpg.format" "ssh" "GPG format"
    set_git_config "user.signingkey" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOlQ9WC58WUVNYtM0tL1YJHDtCMpnLBhtZ3UcQH3dwj" "Signing key"
    set_git_config "commit.gpgsign" "true" "Commit signing"

    # Configure 1Password SSH signing based on OS
    local op_ssh_sign_path
    if [[ "$(uname)" == "Darwin" ]]; then
        op_ssh_sign_path="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

        # Validate 1Password installation
        if [[ ! -f "$op_ssh_sign_path" ]]; then
            handle_warning "1Password SSH signing program not found at expected location" "Install 1Password from https://1password.com or update the path in scripts/git.sh"

            # Check if 1Password is installed elsewhere
            if [[ -d "/Applications/1Password.app" ]]; then
                print_info "1Password app found but SSH signing binary is missing"
            else
                print_info "1Password app not installed - commit signing will not work"
            fi

            # Ask user if they want to continue without 1Password
            if ! prompt_with_default "Continue without 1Password SSH signing?" "n"; then
                handle_error 1 "1Password SSH signing required but not available" "false" "Install 1Password or disable commit signing"
                return 1
            else
                print_info "Skipping 1Password SSH signing configuration"
                return 0
            fi
        fi
    else
        # Assuming Linux path from your Nix configuration
        op_ssh_sign_path="$(which 1password-gui 2>/dev/null)/bin/op-ssh-sign"

        if [[ ! -f "$op_ssh_sign_path" ]]; then
            handle_warning "1Password not found on Linux system" "Install 1Password or configure SSH signing manually"
            return 0
        fi
    fi

    set_git_config "gpg.ssh.program" "$op_ssh_sign_path" "SSH signing program"

    print_success "Git configuration completed"
}