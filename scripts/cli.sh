#!/usr/bin/env bash

# Install essential CLI tools (Bash and Git) from Homebrew
# These should be installed first for the best experience

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_essential_cli() {
    print_step "Essential CLI Tools Installation"
    print_info "Installing modern Bash and Git from Homebrew..."

    # Check if Homebrew is installed
    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please run './setup.sh brew' first or install Homebrew manually."
        return 1
    fi

    # Install Bash
    print_substep "Installing Bash..."
    if brew list bash &>/dev/null; then
        print_success "Bash already installed"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would install bash"
        else
            if brew install bash; then
                print_success "Bash installed successfully"
            else
                handle_error 1 "Failed to install Bash" "true" "Try running: brew install bash"
            fi
        fi
    fi

    # Install Git
    print_substep "Installing Git..."
    if brew list git &>/dev/null; then
        print_success "Git already installed"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would install git"
        else
            if brew install git; then
                print_success "Git installed successfully"
            else
                handle_error 1 "Failed to install Git" "true" "Try running: brew install git"
            fi
        fi
    fi

    # Get installed paths
    local bash_path=$(brew --prefix)/bin/bash
    local git_path=$(brew --prefix)/bin/git

    print_success "Essential CLI tools installed"
    echo ""

    print_step "Installation Details"
    print_info "Bash: $bash_path"
    print_info "Git: $git_path"
    print_info ""
    print_info "Since /opt/homebrew/bin is in your PATH, scripts will automatically"
    print_info "use these newer versions after you restart your terminal."

    # Verify installations
    echo ""
    print_step "Verification"
    print_success "✓ Bash: $($bash_path --version | head -1)"
    print_success "✓ Git: $($git_path --version)"

    echo ""
    print_success "🎉 Essential CLI tools installed!"
    echo ""
    print_info "Next steps:"
    print_info "  1. Restart your terminal session"
    print_info "  2. Verify: bash --version  (should show 5.3+)"
    print_info "  3. Verify: git --version   (should show Homebrew version)"
    print_info "  4. Run: ./setup.sh symlinks"
    print_info "  5. Run: ./setup.sh brew"
    echo ""
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_essential_cli
fi

