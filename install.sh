#!/usr/bin/env bash

# macOS Nix Configuration Installer
# A script to set up a complete Nix environment on fresh macOS systems

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
# 🔧 IMPORTANT: Update this URL to point to your dotfiles repository
REPO_URL="git@github.com:ranokay/dotfiles.git"  # ← Change this to your repo!
DOTFILES_DIR="$HOME/dotfiles"
NIX_DIR="$DOTFILES_DIR/nix"

print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    macOS Nix Configuration                     ║"
    echo "║                        Installer Script                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}==> ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ ${1}${NC}"
}

check_macos() {
    print_step "Checking macOS compatibility"

    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi

    # Check macOS version
    macos_version=$(sw_vers -productVersion)
    print_success "Running on macOS ${macos_version}"
}

check_prerequisites() {
    print_step "Checking prerequisites"

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "Please do not run this script as root"
        exit 1
    fi

    # Check if git is available
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Xcode Command Line Tools first:"
        print_info "Run: xcode-select --install"
        exit 1
    fi

    print_success "Prerequisites check passed"
}

install_determinate_nix() {
    print_step "Installing Determinate Nix"

    if command -v nix &> /dev/null; then
        print_warning "Nix is already installed"
        nix --version
        return
    fi

    print_info "Downloading and installing Determinate Nix..."
    print_info "This will install Nix with flakes enabled and Determinate enhancements"

    # Install Determinate Nix
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

    # Source nix environment
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    print_success "Determinate Nix installed successfully"
    nix --version
}

setup_git_config() {
    print_step "Setting up Git configuration"

    # Check if Git is already configured
    if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
        local current_name=$(git config --global user.name)
        local current_email=$(git config --global user.email)
        print_info "Git is already configured:"
        print_info "  Name: ${current_name}"
        print_info "  Email: ${current_email}"

        read -p "Do you want to reconfigure Git? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    # Configure Git
    read -p "Enter your Git username: " git_name
    read -p "Enter your Git email: " git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase true

    print_success "Git configured successfully"
}

clone_dotfiles() {
    print_step "Setting up dotfiles repository"

    # Check if dotfiles directory already exists
    if [[ -d "$DOTFILES_DIR" ]]; then
        print_warning "Dotfiles directory already exists at $DOTFILES_DIR"
        read -p "Do you want to backup and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Backing up existing directory..."
            mv "$DOTFILES_DIR" "${DOTFILES_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        else
            print_info "Using existing dotfiles directory"
            return
        fi
    fi

    print_info "Cloning dotfiles repository..."

    # Try SSH first, fall back to HTTPS
    if ! git clone "$REPO_URL" "$DOTFILES_DIR" 2>/dev/null; then
        print_warning "SSH clone failed, trying HTTPS..."
        HTTPS_URL=$(echo "$REPO_URL" | sed 's/git@github.com:/https:\/\/github.com\//')
        git clone "$HTTPS_URL" "$DOTFILES_DIR"
    fi

    print_success "Dotfiles cloned to $DOTFILES_DIR"
}

install_dependencies() {
    print_step "Installing essential dependencies"

    # Install just (task runner)
    if ! command -v just &> /dev/null; then
        print_info "Installing just (task runner)..."
        nix profile install nixpkgs#just
        print_success "Just installed"
    else
        print_info "Just is already installed"
    fi

    # Add other essential tools if needed
    print_info "Installing additional development tools..."
    nix profile install nixpkgs#alejandra nixpkgs#nil

    print_success "Dependencies installed"
}

configure_shell() {
    print_step "Configuring shell environment"

    # Add Nix to shell profile if not already present
    local shell_profile
    case "$SHELL" in
        */zsh) shell_profile="$HOME/.zshrc" ;;
        */bash) shell_profile="$HOME/.bashrc" ;;
        *) shell_profile="$HOME/.profile" ;;
    esac

    # Check if nix is already in PATH
    if ! echo "$PATH" | grep -q "/nix/var/nix/profiles/default/bin"; then
        print_info "Adding Nix to shell profile: $shell_profile"
        echo "" >> "$shell_profile"
        echo "# Nix environment" >> "$shell_profile"
        echo 'if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then' >> "$shell_profile"
        echo '  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' >> "$shell_profile"
        echo 'fi' >> "$shell_profile"
    fi

    print_success "Shell environment configured"
}

run_initial_build() {
    print_step "Running initial system configuration"

    cd "$NIX_DIR"

    # Check flake syntax
    print_info "Checking flake configuration..."
    nix flake check --show-trace

    # Build the configuration (dry run first)
    print_info "Performing dry run..."
    just dry-run

    print_info "Building and applying configuration..."
    print_warning "This step requires sudo access for system changes"

    # Build and switch
    just rebuild

    print_success "Initial configuration applied successfully"
}

setup_additional_tools() {
    print_step "Setting up additional macOS tools"

    # Enable TouchID for sudo (if not already enabled)
    if ! grep -q "pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
        print_info "TouchID for sudo authentication will be configured by nix-darwin"
    fi

    # Install Xcode Command Line Tools if not present
    if ! xcode-select -p &> /dev/null; then
        print_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        print_warning "Please complete the Xcode Command Line Tools installation before continuing"
        read -p "Press Enter when installation is complete..."
    fi

    print_success "Additional tools setup complete"
}

print_next_steps() {
    print_step "Installation Complete!"

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                        SUCCESS!                                ║"
    echo "║              Your Nix configuration is ready                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "${YELLOW}1.${NC} Restart your terminal or run: source ~/.zshrc"
    echo -e "${YELLOW}2.${NC} Navigate to your nix configuration: cd $NIX_DIR"
    echo -e "${YELLOW}3.${NC} View available commands: just --list"
    echo -e "${YELLOW}4.${NC} Customize your configuration by editing the files in:"
    echo -e "   • ${BLUE}hosts/mbp/${NC} - Host-specific settings"
    echo -e "   • ${BLUE}home/profiles/${NC} - User environment profiles"
    echo -e "   • ${BLUE}profiles/${NC} - System profiles"
    echo ""
    echo -e "${CYAN}Useful Commands:${NC}"
    echo -e "${YELLOW}•${NC} just rebuild    - Apply configuration changes"
    echo -e "${YELLOW}•${NC} just check      - Check configuration for errors"
    echo -e "${YELLOW}•${NC} just up         - Update all flake inputs"
    echo -e "${YELLOW}•${NC} just gc         - Clean up old generations"
    echo -e "${YELLOW}•${NC} just new-host   - Add a new machine configuration"
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    echo -e "${YELLOW}•${NC} README: $NIX_DIR/README.md"
    echo -e "${YELLOW}•${NC} Improvements: $NIX_DIR/IMPROVEMENTS.md"
    echo ""
    echo -e "${GREEN}Enjoy your new Nix-powered macOS setup! 🎉${NC}"
}

handle_error() {
    print_error "Installation failed at step: $1"
    print_info "Check the output above for error details"
    print_info "You can re-run this script to continue from where it failed"
    exit 1
}

# Main installation flow
main() {
    print_header

    # Trap errors
    trap 'handle_error "${BASH_COMMAND}"' ERR

    # Pre-installation checks
    check_macos
    check_prerequisites

    # Get user confirmation
    echo -e "${CYAN}This script will:${NC}"
    echo -e "${YELLOW}•${NC} Install Determinate Nix (if not already installed)"
    echo -e "${YELLOW}•${NC} Clone your dotfiles repository"
    echo -e "${YELLOW}•${NC} Install essential dependencies (just, alejandra, nil)"
    echo -e "${YELLOW}•${NC} Configure your shell environment"
    echo -e "${YELLOW}•${NC} Apply your Nix configuration"
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled by user"
        exit 0
    fi

    # Installation steps
    install_determinate_nix
    setup_git_config
    clone_dotfiles
    install_dependencies
    configure_shell
    setup_additional_tools
    run_initial_build

    # Success
    print_next_steps
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --dry-run      Show what would be done without executing"
        echo ""
        echo "This script installs and configures a complete Nix environment on macOS"
        exit 0
        ;;
    --dry-run)
        echo "DRY RUN MODE - No changes will be made"
        echo "This would:"
        echo "1. Install Determinate Nix"
        echo "2. Setup Git configuration"
        echo "3. Clone dotfiles repository"
        echo "4. Install dependencies (just, alejandra, nil)"
        echo "5. Configure shell environment"
        echo "6. Apply Nix configuration"
        exit 0
        ;;
    "")
        # No arguments, proceed with installation
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac