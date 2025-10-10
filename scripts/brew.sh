#!/usr/bin/env bash

source "./scripts/utils.sh"

# Validate Brewfile syntax and package availability
validate_brewfile() {
    local brewfile="$1"
    
    print_info "Validating Brewfile syntax and package availability..."
    
    # Check if Brewfile exists and is readable
    if [[ ! -f "$brewfile" ]]; then
        print_error "Brewfile not found at $brewfile"
        return 1
    fi
    
    if [[ ! -r "$brewfile" ]]; then
        print_error "Brewfile is not readable"
        return 1
    fi
    
    # Basic syntax validation
    if ! ruby -c "$brewfile" >/dev/null 2>&1; then
        print_error "Brewfile has syntax errors"
        return 1
    fi
    
    # Test dry-run to catch issues early
    if ! brew bundle check --file="$brewfile" --verbose >/dev/null 2>&1; then
        print_info "Some packages in Brewfile are not installed (this is normal for initial setup)"
    fi
    
    print_success "Brewfile validation completed"
    return 0
}

install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would install Homebrew"
            return 0
        fi
        
        # Add to rollback stack
        add_to_rollback "system" "Homebrew installation" "rm -rf /opt/homebrew || rm -rf /usr/local/Homebrew"
        
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            handle_error 1 "Failed to install Homebrew"
            return 1
        fi
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    # Update Homebrew and upgrade packages
    update_homebrew
    
    print_success "Homebrew installed and updated"
}

# Update Homebrew and check for issues
update_homebrew() {
    print_info "Updating Homebrew..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_dry_run "Would update Homebrew formulae and casks"
        return 0
    fi
    
    # Update Homebrew itself and all formulae
    if ! brew update 2>&1 | tail -10; then
        handle_error 1 "Failed to update Homebrew" "true"
        return 1
    fi
    print_success "Homebrew updated"
    
    # Check for issues (optional health check)
    print_info "Checking Homebrew installation health..."
    local doctor_output
    doctor_output=$(brew doctor 2>&1)
    local doctor_exit_code=$?
    
    if [[ $doctor_exit_code -ne 0 ]]; then
        print_error "Homebrew doctor found some issues:"
        echo "$doctor_output" | head -15
        print_info "These issues may not be critical - continuing anyway"
        print_info "Run 'brew doctor' manually to see full report"
        ((ERROR_COUNT++))
    else
        print_success "Homebrew health check passed"
    fi
}

# Manage Homebrew services
manage_services() {
    print_info "Managing Homebrew services..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_dry_run "Would check and start/stop Homebrew services"
        return 0
    fi
    
    # List current services
    local services_output
    services_output=$(brew services list 2>/dev/null || true)
    
    if [[ -n "$services_output" ]]; then
        print_info "Current Homebrew services:"
        echo "$services_output" | while IFS= read -r line; do
            print_info "  $line"
        done
        
        # Start essential services if they're not running
        local essential_services=("tailscale")
        
        for service in "${essential_services[@]}"; do
            if echo "$services_output" | grep -q "$service.*stopped"; then
                print_info "Starting service: $service"
                brew services start "$service" || print_error "Failed to start $service"
            fi
        done
    fi
}

# Check for outdated packages
check_outdated() {
    print_info "Checking for outdated packages..."
    
    local outdated_formulae
    local outdated_casks
    
    outdated_formulae=$(brew outdated --formulae 2>/dev/null || true)
    outdated_casks=$(brew outdated --casks 2>/dev/null || true)
    
    if [[ -n "$outdated_formulae" ]]; then
        print_info "Outdated formulae:"
        echo "$outdated_formulae" | while IFS= read -r line; do
            print_info "  📦 $line"
        done
        
        if [[ "$DRY_RUN" != "true" ]] && ask_confirmation "Would you like to upgrade outdated formulae?"; then
            brew upgrade --formulae
            print_success "Formulae upgraded"
        fi
    else
        print_success "All formulae are up to date"
    fi
    
    if [[ -n "$outdated_casks" ]]; then
        print_info "Outdated casks:"
        echo "$outdated_casks" | while IFS= read -r line; do
            print_info "  📱 $line"
        done
        
        if [[ "$DRY_RUN" != "true" ]] && ask_confirmation "Would you like to upgrade outdated casks?"; then
            brew upgrade --casks
            print_success "Casks upgraded"
        fi
    else
        print_success "All casks are up to date"
    fi
}

install_packages() {
    print_info "Installing packages from Brewfile..."
    
    local brewfile="config/Brewfile"
    
    # Validate Brewfile before proceeding
    if ! validate_brewfile "$brewfile"; then
        print_error "Brewfile validation failed"
        exit 1
    fi

    # Check for packages to uninstall
    print_step "Package Cleanup Check"
    print_substep "Analyzing installed packages vs Brewfile..."
    
    local cleanup_list
    local cleanup_exit_code=0
    
    # Capture output and exit code separately (brew returns 1 when packages need cleanup)
    cleanup_list=$(brew bundle cleanup --file="$brewfile" 2>&1) || cleanup_exit_code=$?
    
    # Exit code 1 means packages were found that need cleanup (expected behavior)
    # Exit code 0 means no packages need cleanup
    # Other exit codes indicate actual errors
    if [[ $cleanup_exit_code -gt 1 ]]; then
        print_error "Failed to check cleanup status (exit code: $cleanup_exit_code)"
        print_error "Output: $cleanup_list"
        exit 1
    fi
    
    # Check if there are packages to clean up
    if [[ $cleanup_exit_code -eq 1 ]] && [[ -n "$cleanup_list" ]]; then
        # Count packages to remove
        local cask_count=$(echo "$cleanup_list" | grep -c "Would uninstall casks:" || echo "0")
        local formula_count=$(echo "$cleanup_list" | grep -c "Would uninstall formulae:" || echo "0")
        local tap_count=$(echo "$cleanup_list" | grep -c "Would untap:" || echo "0")
        
        print_warning "Found packages not defined in Brewfile"
        echo ""
        printf "%s\n\n" "$cleanup_list"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would prompt to remove these packages"
            print_info "Re-run without --dry-run to clean up these packages"
        elif ask_confirmation "\nDo you want to remove these packages?"; then
            print_substep "Removing packages..."
            if ! brew bundle cleanup --force --file="$brewfile" 2>&1; then
                print_error "Failed to remove some packages"
                exit 1
            fi
            print_success "Packages removed successfully"
        else
            print_info "Cleanup skipped - packages will remain installed"
            print_info "You can clean them up later by running: brew bundle cleanup --force --file=$brewfile"
        fi
    else
        print_success "No orphaned packages found - everything is in sync with Brewfile"
    fi

    # Install packages
    print_step "Package Installation Phase"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_dry_run "Would install/update packages from $brewfile"
        print_substep "Checking what would be installed..."
        
        # Use brew bundle check instead of --dry-run (which doesn't exist)
        if brew bundle check --file="$brewfile" --verbose 2>&1 | grep -E "(would be installed|is satisfied|missing)"; then
            print_success "Dry-run check completed"
        else
            print_success "All packages in Brewfile are already installed"
        fi
        print_info "Run without --dry-run to install missing packages"
    else
        print_substep "Installing/updating packages..."
        local bundle_output
        local bundle_exit_code=0
        
        # Show progress while installing
        bundle_output=$(brew bundle --file="$brewfile" --verbose 2>&1) || bundle_exit_code=$?
        
        if [[ $bundle_exit_code -ne 0 ]]; then
            print_error "Failed to install some packages (exit code: $bundle_exit_code)"
            echo "" 
            print_info "Last 20 lines of output:"
            echo "$bundle_output" | tail -20
            echo ""
            print_info "Full log available at: $LOG_FILE"
            exit 1
        fi
        
        # Count what was installed
        local installed_count=$(echo "$bundle_output" | grep -c "Installing" || echo "0")
        local upgraded_count=$(echo "$bundle_output" | grep -c "Upgrading" || echo "0")
        
        if [[ $installed_count -gt 0 ]] || [[ $upgraded_count -gt 0 ]]; then
            print_success "Installed: $installed_count packages, Upgraded: $upgraded_count packages"
        else
            print_success "All packages already up to date"
        fi
    fi
    
    # Post-installation tasks
    manage_services
    check_outdated
    cleanup_homebrew
}

# Cleanup Homebrew
cleanup_homebrew() {
    print_info "Cleaning up Homebrew..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_dry_run "Would clean up Homebrew cache and remove old versions"
        return 0
    fi
    
    # Remove old versions and cleanup cache
    brew cleanup --prune=30 2>/dev/null || print_error "Cleanup encountered some issues (non-critical)"
    
    # Show cache size
    local cache_size
    cache_size=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "unknown")
    print_info "Homebrew cache size: $cache_size"
    
    print_success "Homebrew cleanup completed"
}
