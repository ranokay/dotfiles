#!/usr/bin/env bash

source "./scripts/utils.sh"

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
    else
        # Assuming Linux path from your Nix configuration
        op_ssh_sign_path="$(which 1password-gui)/bin/op-ssh-sign"
    fi

    set_git_config "gpg.ssh.program" "$op_ssh_sign_path" "SSH signing program"

    print_success "Git configuration completed"
} 