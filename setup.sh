#!/usr/bin/env bash

# Enhanced dotfiles setup script with selective configuration support

set -eo pipefail  # Remove -u flag to avoid issues with associative arrays

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_MODULES=("checks" "brew" "git" "shell" "macos-general" "macos-input" "macos-screen" "macos-finder" "macos-dock" "macos-apps")

# Parse command line arguments
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [MODULES...]

Enhanced dotfiles setup script with selective configuration support.

OPTIONS:
    -h, --help          Show this help message
    -d, --dry-run       Show what would be done without making changes
    -l, --list          List available configuration modules
    -a, --all           Run all configuration modules (default)
    -v, --verbose       Enable verbose output
    --skip-checks       Skip system requirement checks
    --log-file FILE     Custom log file location

MODULES:
    checks              System validation (macOS version, Xcode CLI tools)
    brew                Homebrew and package installation
    git                 Git configuration with 1Password signing
    shell               Shell configuration (zsh, fish, dotfile linking)
    macos-general       General macOS UI/UX settings
    macos-input         Input device configuration
    macos-screen        Screen and screenshot settings
    macos-finder        Finder customization
    macos-dock          Dock and hot corner configuration
    macos-apps          Application-specific settings

EXAMPLES:
    $0                          # Run full setup
    $0 --dry-run                # Show what would be changed
    $0 brew git                 # Only install packages and configure Git
    $0 --dry-run macos-dock     # Preview Dock changes
    $0 --skip-checks macos-*    # Configure all macOS settings

EOF
}

list_modules() {
    echo "Available configuration modules:"
    for module in "${ALL_MODULES[@]}"; do
        case "$module" in
            "checks")
                echo "  $module        - System validation (macOS version, Xcode CLI tools)"
                ;;
            "brew")
                echo "  $module          - Homebrew and package installation"
                ;;
            "git")
                echo "  $module           - Git configuration with 1Password signing"
                ;;
            "shell")
                echo "  $module         - Shell configuration (zsh, fish, dotfile linking)"
                ;;
            "macos-general")
                echo "  $module   - General macOS UI/UX settings"
                ;;
            "macos-input")
                echo "  $module     - Input device configuration"
                ;;
            "macos-screen")
                echo "  $module    - Screen and screenshot settings"
                ;;
            "macos-finder")
                echo "  $module    - Finder customization"
                ;;
            "macos-dock")
                echo "  $module      - Dock and hot corner configuration"
                ;;
            "macos-apps")
                echo "  $module     - Application-specific settings"
                ;;
        esac
    done
}

# Parse arguments
SELECTED_MODULES=()
SKIP_CHECKS=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -l|--list)
            list_modules
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            export DRY_RUN
            shift
            ;;
        -a|--all)
            SELECTED_MODULES=("${ALL_MODULES[@]}")
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --skip-checks)
            SKIP_CHECKS=true
            shift
            ;;
        --log-file)
            LOG_FILE="$2"
            export LOG_FILE
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            # Support glob patterns like macos-*
            if [[ "$1" == *"*"* ]]; then
                pattern="$1"
                for module in "${ALL_MODULES[@]}"; do
                    if [[ $module == $pattern ]]; then
                        SELECTED_MODULES+=("$module")
                    fi
                done
            else
                SELECTED_MODULES+=("$1")
            fi
            shift
            ;;
    esac
done

# Default to all modules if none specified
if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then
    SELECTED_MODULES=("${ALL_MODULES[@]}")
fi

# Validate selected modules
for module in "${SELECTED_MODULES[@]}"; do
    if [[ ! " ${ALL_MODULES[*]} " =~ " ${module} " ]]; then
        echo "Error: Unknown module '$module'" >&2
        echo "Run '$0 --list' to see available modules" >&2
        exit 1
    fi
done

# Initialize logging
init_logging

# Set up error handling
setup_error_handling

# Create automatic backup before making changes (DISABLED - backup.sh has syntax issues)
# Uncomment and fix backup.sh to re-enable
# if [[ "$DRY_RUN" != "true" ]] && [[ "${ENABLE_BACKUP:-false}" == "true" ]]; then
#     print_info "Creating automatic backup before making changes..."
#     source "$SCRIPT_DIR/scripts/backup.sh"
#     backup_settings 2>/dev/null || print_warning "Backup failed (non-critical)"
#     AUTO_BACKUP_DIR="$CURRENT_BACKUP_DIR"
#     export AUTO_BACKUP_DIR
# else
#     if [[ "$DRY_RUN" != "true" ]]; then
#         print_info "Automatic backup disabled (set ENABLE_BACKUP=true to enable)"
#     fi
# fi

if [[ "$DRY_RUN" != "true" ]]; then
    print_info "Automatic backup is currently disabled"
fi

# Print configuration
if [[ "$VERBOSE" == "true" ]]; then
    print_info "Configuration:"
    print_info "  Dry run: $DRY_RUN"
    print_info "  Skip checks: $SKIP_CHECKS"
    print_info "  Log file: $LOG_FILE"
    print_info "  Selected modules: ${SELECTED_MODULES[*]}"
fi

# Execute selected modules
total_modules=${#SELECTED_MODULES[@]}
current_module=0

for module in "${SELECTED_MODULES[@]}"; do
    ((current_module++))
    echo ""
    print_progress "$current_module" "$total_modules" "Running $module"

    case "$module" in
        "checks")
            if [[ "$SKIP_CHECKS" == "false" ]]; then
                source "$SCRIPT_DIR/scripts/checks.sh"
                check_system
                check_xcode
                print_success "✓ Module '$module' completed"
            else
                print_info "Skipping system checks"
            fi
            ;;
        "brew")
            source "$SCRIPT_DIR/scripts/brew.sh"
            install_homebrew
            install_packages
            print_success "✓ Module '$module' completed"
            ;;
        "git")
            source "$SCRIPT_DIR/scripts/git.sh"
            configure_git
            print_success "✓ Module '$module' completed"
            ;;
        "shell")
            source "$SCRIPT_DIR/scripts/shell.sh"
            configure_shell
            print_success "✓ Module '$module' completed"
            ;;
        "macos-general")
            source "$SCRIPT_DIR/scripts/macos.sh"
            configure_general
            print_success "✓ Module '$module' completed"
            ;;
        "macos-input")
            source "$SCRIPT_DIR/scripts/macos.sh"
            configure_input
            print_success "✓ Module '$module' completed"
            ;;
        "macos-screen")
            source "$SCRIPT_DIR/scripts/macos.sh"
            configure_screen
            print_success "✓ Module '$module' completed"
            ;;
        "macos-finder")
            source "$SCRIPT_DIR/scripts/macos.sh"
            configure_finder
            print_success "✓ Module '$module' completed"
            ;;
        "macos-dock")
            source "$SCRIPT_DIR/scripts/macos.sh"
            configure_dock
            print_success "✓ Module '$module' completed"
            ;;
        "macos-apps")
            source "$SCRIPT_DIR/scripts/macos.sh"
            configure_time_machine
            configure_activity_monitor
            configure_textedit
            configure_quicktime
            configure_photos
            print_success "✓ Module '$module' completed"
            ;;
    esac
done

echo ""
print_step "All Modules Completed"
print_info "Executed modules: ${SELECTED_MODULES[*]}"
print_info "Total modules: $total_modules"

# Show summary
show_summary

if [[ "$DRY_RUN" == "true" ]]; then
    print_info "This was a dry run. No actual changes were made."
    print_info "Run without --dry-run to apply the changes."
fi