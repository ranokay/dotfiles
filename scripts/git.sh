#!/usr/bin/env bash

source "./scripts/utils.sh"

configure_git() {
    print_info "Configuring Git settings..."

    # Basic Git configuration
    git config --global user.name "Yuuta"
    git config --global user.email "github@ranokay.com"

    # Configure commit signing with 1Password
    git config --global gpg.format ssh
    git config --global user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOlQ9WC58WUVNYtM0tL1YJHDtCMpnLBhtZ3UcQH3dwj"
    git config --global commit.gpgsign true

    # Configure 1Password SSH signing based on OS
    if [[ "$(uname)" == "Darwin" ]]; then
        git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
        # Assuming Linux path from your Nix configuration
        git config --global gpg.ssh.program "$(which 1password-gui)/bin/op-ssh-sign"
    fi

    print_success "Git configuration completed"
} 